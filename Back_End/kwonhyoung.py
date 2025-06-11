"""
author : Team2
description : 팀프로젝트 소규모 사업자 카페 앱 (개선된 버전)
date : 2025-06-10
version : 1.2
"""

from fastapi import FastAPI, HTTPException, Form, Path
import pymysql
from fastapi.responses import JSONResponse, Response
from typing import Optional
from datetime import datetime
import base64

app = FastAPI()

def connect():
    conn = pymysql.connect(
        # host='192.168.20.26',
        host='192.168.50.236',
        user='root',
        password='qwer1234',
        db='pick_caffeine',
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )
    return conn

# 관리자 조회
@app.get('/select')
async def admin_select():
    conn = connect()
    curs = conn.cursor()

    sql = 'select * from admin'
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()

    return {'admin' : rows}

# 전체 신고 조회 (개선된 버전)
@app.get('/declarations')
async def get_all_declarations():
    conn = connect()
    curs = conn.cursor()

    try:
        sql = '''
        SELECT 
            d.user_id,
            d.review_num,
            d.declaration_date,
            d.declaration_content,
            d.declaration_state,
            d.sanction_content,
            d.sanction_date,
            u.user_nickname,
            u.user_image,
            u.user_state
        FROM declaration d
        LEFT JOIN users u ON d.user_id = u.user_id
        ORDER BY 
            CASE WHEN d.sanction_date IS NOT NULL THEN d.sanction_date 
                 ELSE d.declaration_date END DESC
        '''
        curs.execute(sql)
        rows = curs.fetchall()
        
        print(f"✅ 신고 조회 완료: {len(rows)}개")
        
        # 제재 건수 로그
        sanction_count = sum(1 for row in rows if row.get('sanction_content'))
        print(f"🚨 제재 건수: {sanction_count}개")
        
        # 데이터 샘플 로그 (처음 3개)
        for i, row in enumerate(rows[:3]):
            if row.get('sanction_content'):
                print(f"📋 제재 샘플 {i+1}: {row['user_id']} - {row['sanction_content']}")
        
        conn.close()
        return {"declarations": rows}
        
    except Exception as e:
        print(f"❌ 신고 조회 오류: {e}")
        conn.close()
        return {"declarations": []}

# 개별 신고 조회
@app.get('/declarations_indi/{review_num}')
async def get_declaration(review_num: int):
    conn = connect()
    curs = conn.cursor()

    sql = '''
    SELECT 
        d.*,
        u.user_nickname,
        u.user_image,
        u.user_state
    FROM declaration d
    LEFT JOIN users u ON d.user_id = u.user_id
    WHERE d.review_num = %s
    '''
    curs.execute(sql, (review_num,))
    row = curs.fetchone()
    conn.close()

    if row:
        return row
    return {"error": "신고 내역 없음"}

# 신고 등록 (수정된 버전 - 중복 처리 및 안정성 강화)
@app.post("/declaration_insert")
async def declaration_insert(
    userId: str = Form(...),
    reviewNum: int = Form(...),
    declarationContent: str = Form(...),
    declarationDate: str = Form(..., description="YYYY-MM-DD 형식으로 입력해주세요"),
    declarationState: str = Form(...),
    sanctionContent: Optional[str] = Form(None),
    sanctionDate: Optional[str] = Form(None, description="YYYY-MM-DD 형식으로 입력해주세요")
):
    # 빈 문자열 -> None 처리
    sanctionContent = sanctionContent if sanctionContent else None
    sanctionDate = sanctionDate if sanctionDate else None

    # 날짜 형식 검증
    try:
        datetime.strptime(declarationDate, "%Y-%m-%d")
        if sanctionDate:
            datetime.strptime(sanctionDate, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(status_code=400, detail="날짜는 YYYY-MM-DD 형식이어야 합니다")

    conn = connect()
    curs = conn.cursor()
    
    try:
        # 트랜잭션 시작
        conn.begin()
        
        # 사용자 존재 여부 확인
        user_check_sql = "SELECT user_id FROM users WHERE user_id = %s"
        curs.execute(user_check_sql, (userId,))
        if not curs.fetchone():
            raise HTTPException(status_code=404, detail=f"사용자 {userId}를 찾을 수 없습니다")
        
        # 리뷰 존재 여부 확인
        review_check_sql = "SELECT review_num FROM review WHERE review_num = %s"
        curs.execute(review_check_sql, (reviewNum,))
        if not curs.fetchone():
            raise HTTPException(status_code=404, detail=f"리뷰 {reviewNum}를 찾을 수 없습니다")
        
        # 기존 declaration 확인
        check_sql = '''
        SELECT declaration_state, sanction_content FROM declaration 
        WHERE user_id = %s AND review_num = %s
        '''
        curs.execute(check_sql, (userId, reviewNum))
        existing = curs.fetchone()
        
        if existing:
            # 기존 declaration 업데이트
            update_sql = '''
            UPDATE declaration SET
                declaration_content = %s,
                declaration_state = %s,
                sanction_content = %s,
                sanction_date = %s
            WHERE user_id = %s AND review_num = %s
            '''
            curs.execute(update_sql, (
                declarationContent,
                declarationState,
                sanctionContent,
                sanctionDate,
                userId,
                reviewNum
            ))
            print(f"✅ 기존 신고 업데이트 - 사용자: {userId}, 리뷰: {reviewNum}")
        else:
            # 새 declaration 삽입
            insert_sql = '''
            INSERT INTO declaration (
                user_id, review_num, declaration_date, 
                declaration_content, declaration_state, 
                sanction_content, sanction_date
            ) VALUES (%s, %s, %s, %s, %s, %s, %s)
            '''
            curs.execute(insert_sql, (
                userId, reviewNum, declarationDate,
                declarationContent, declarationState,
                sanctionContent, sanctionDate
            ))
            print(f"✅ 새 신고 삽입 - 사용자: {userId}, 리뷰: {reviewNum}")
        
        # 제재 처리인 경우에만 사용자/리뷰 상태 업데이트
        if sanctionContent and sanctionDate:
            # 사용자 상태 업데이트
            update_user_sql = "UPDATE users SET user_state = '제재중' WHERE user_id = %s"
            user_rows = curs.execute(update_user_sql, (userId,))
            print(f"✅ 사용자 상태 업데이트 - {userId}: {user_rows}행 영향")
            
            # 리뷰 상태 업데이트  
            update_review_sql = "UPDATE review SET review_state = '제재' WHERE review_num = %s"
            review_rows = curs.execute(update_review_sql, (reviewNum,))
            print(f"✅ 리뷰 상태 업데이트 - {reviewNum}: {review_rows}행 영향")
        
        # 트랜잭션 커밋
        conn.commit()
        
        # 저장된 데이터 확인
        verify_sql = '''
        SELECT d.*, u.user_nickname, u.user_state 
        FROM declaration d 
        JOIN users u ON d.user_id = u.user_id 
        WHERE d.user_id = %s AND d.review_num = %s
        '''
        curs.execute(verify_sql, (userId, reviewNum))
        saved_data = curs.fetchone()
        
        return {
            "status": "success",
            "result": "제재 처리 완료",
            "message": f"사용자 {userId}에 대한 제재가 성공적으로 처리되었습니다",
            "data": {
                "user_id": userId,
                "review_num": reviewNum,
                "sanction_content": sanctionContent,
                "sanction_date": sanctionDate,
                "user_state": saved_data.get('user_state') if saved_data else None
            }
        }
        
    except HTTPException:
        conn.rollback()
        raise
    except Exception as ex:
        conn.rollback()
        error_msg = f"제재 처리 실패: {str(ex)}"
        print(f"❌ {error_msg}")
        raise HTTPException(status_code=500, detail=error_msg)
    finally:
        conn.close()

# 신고 수정(제재 내용 포함)
@app.put('/declarations/{review_num}')
async def update_declaration(
    review_num: int,
    userId: str = Form(...),
    declarationDate: str = Form(..., description="YYYY-MM-DD 형식으로 입력해주세요"),
    declarationContent: str = Form(...),
    declarationState: str = Form(...),
    sanctionContent: Optional[str] = Form(None),
    sanctionDate: Optional[str] = Form(None, description="YYYY-MM-DD 형식으로 입력해주세요")
):
    # 빈 문자열 None 처리
    sanctionContent = sanctionContent if sanctionContent else None
    sanctionDate = sanctionDate if sanctionDate else None

    # 날짜 형식 검증
    try:
        datetime.strptime(declarationDate, "%Y-%m-%d")
        if sanctionDate:
            datetime.strptime(sanctionDate, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(status_code=400, detail="날짜는 YYYY-MM-DD 형식이어야 합니다")

    conn = connect()
    curs = conn.cursor()

    try:
        # 제재 처리 시 사용자 상태도 업데이트
        if sanctionContent and sanctionDate:
            # 사용자 상태를 '제재중'으로 변경
            update_user_sql = '''
            UPDATE users 
            SET user_state = '제재중'
            WHERE user_id = %s
            '''
            curs.execute(update_user_sql, (userId,))

        sql = '''
        update declaration set
        user_id=%s,
        declaration_date=%s,
        declaration_content=%s,
        declaration_state=%s,
        sanction_content=%s,
        sanction_date=%s
        where review_num=%s
        '''
        curs.execute(sql, (
            userId,
            declarationDate,
            declarationContent,
            declarationState,
            sanctionContent,
            sanctionDate,
            review_num
        ))
        conn.commit()
        return {"result": "신고 수정 완료", "status": "success"}
    except Exception as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        conn.close()

# 신고 삭제
@app.delete('/declarations_delete/{review_num}')
async def delete(review_num: int):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = 'delete from declaration where review_num = %s'
        curs.execute(sql, (review_num))
        conn.commit()
        conn.close()
        return {'result':'OK', 'status': 'success'}
    except Exception as e:
        print('Error:', e)
        return{'result':'Error', 'status': 'error'}

# 통계 정보 조회
@app.get('/stats')
async def get_stats():
    conn = connect()
    curs = conn.cursor()
    
    try:
        # 유저 수 조회
        sql_users = 'SELECT COUNT(*) as count FROM users'
        curs.execute(sql_users)
        user_count = curs.fetchone()['count']
        
        # 매장 수 조회
        sql_stores = 'SELECT COUNT(*) as count FROM store'
        curs.execute(sql_stores)
        store_count = curs.fetchone()['count']
        
        # 제재중인 유저 수 조회
        sql_sanctioned = "SELECT COUNT(*) as count FROM users WHERE user_state = '제재중'"
        curs.execute(sql_sanctioned)
        sanctioned_count = curs.fetchone()['count']
        
        conn.close()
        
        return {
            'user_count': user_count,
            'store_count': store_count,
            'sanctioned_user_count': sanctioned_count
        }
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {
            'user_count': 0,
            'store_count': 0,
            'sanctioned_user_count': 0
        }

# 제재 유저 목록 조회
@app.get('/sanctioned_users')
async def get_sanctioned_users():
    conn = connect()
    curs = conn.cursor()
    
    try:
        sql = '''
        SELECT 
            u.user_id,
            u.user_nickname,
            u.user_state,
            u.user_image,
            d.declaration_date,
            d.declaration_content,
            d.sanction_content,
            d.sanction_date,
            d.review_num
        FROM users u
        INNER JOIN declaration d ON u.user_id = d.user_id
        WHERE u.user_state = '제재중' AND d.sanction_content IS NOT NULL
        ORDER BY d.sanction_date DESC
        '''
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()
        
        return {"sanctioned_users": rows}
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {"sanctioned_users": []}

# 제재 해제 (개선된 버전 - 리뷰 상태 완전 복원)
@app.put('/release_sanction/{user_id}')
async def release_sanction(user_id: str):
    conn = connect()
    curs = conn.cursor()
    
    try:
        # 트랜잭션 시작
        conn.begin()
        
        print(f"🔓 제재 해제 시작 - 사용자: {user_id}")
        
        # 1. 해당 사용자의 제재된 리뷰 번호들 조회
        get_reviews_sql = '''
        SELECT DISTINCT d.review_num 
        FROM declaration d 
        WHERE d.user_id = %s AND d.sanction_content IS NOT NULL
        '''
        curs.execute(get_reviews_sql, (user_id,))
        sanctioned_reviews = [row['review_num'] for row in curs.fetchall()]
        
        print(f"📋 제재된 리뷰 목록: {sanctioned_reviews}")
        
        # 2. 사용자 상태를 '활성'으로 변경
        update_user_sql = '''
        UPDATE users 
        SET user_state = '활성'
        WHERE user_id = %s
        '''
        user_rows = curs.execute(update_user_sql, (user_id,))
        print(f"✅ 사용자 상태 업데이트 - 영향받은 행: {user_rows}")
        
        # 3. 해당 사용자의 제재 내용을 제거
        update_declaration_sql = '''
        UPDATE declaration 
        SET sanction_content = NULL, sanction_date = NULL
        WHERE user_id = %s AND sanction_content IS NOT NULL
        '''
        decl_rows = curs.execute(update_declaration_sql, (user_id,))
        print(f"✅ 제재 내용 제거 - 영향받은 행: {decl_rows}")
        
        # 4. 해당 사용자의 모든 제재된 리뷰들을 정상 상태로 변경
        review_rows = 0
        if sanctioned_reviews:
            placeholders = ','.join(['%s'] * len(sanctioned_reviews))
            update_reviews_sql = f'''
            UPDATE review r
            JOIN purchase_list p ON r.purchase_num = p.purchase_num
            SET r.review_state = '정상'
            WHERE p.user_id = %s AND r.review_num IN ({placeholders}) AND r.review_state = '제재'
            '''
            review_rows = curs.execute(update_reviews_sql, [user_id] + sanctioned_reviews)
            print(f"✅ 리뷰 상태 복원 - 영향받은 행: {review_rows}")
        
        # 5. 추가로 해당 사용자의 모든 제재된 리뷰 복원 (안전장치)
        additional_review_sql = '''
        UPDATE review r
        JOIN purchase_list p ON r.purchase_num = p.purchase_num
        SET r.review_state = '정상'
        WHERE p.user_id = %s AND r.review_state = '제재'
        '''
        additional_rows = curs.execute(additional_review_sql, (user_id,))
        print(f"✅ 추가 리뷰 상태 복원 - 영향받은 행: {additional_rows}")
        
        # 트랜잭션 커밋
        conn.commit()
        
        # 6. 결과 검증
        verify_sql = '''
        SELECT 
            u.user_state,
            COUNT(CASE WHEN d.sanction_content IS NOT NULL THEN 1 END) as remaining_sanctions,
            COUNT(CASE WHEN r.review_state = '제재' THEN 1 END) as remaining_sanctioned_reviews
        FROM users u
        LEFT JOIN declaration d ON u.user_id = d.user_id
        LEFT JOIN purchase_list p ON u.user_id = p.user_id
        LEFT JOIN review r ON p.purchase_num = r.purchase_num
        WHERE u.user_id = %s
        GROUP BY u.user_id, u.user_state
        '''
        curs.execute(verify_sql, (user_id,))
        verification = curs.fetchone()
        
        print(f"🔍 제재 해제 결과 검증:")
        print(f"   👤 사용자 상태: {verification['user_state'] if verification else 'Not Found'}")
        print(f"   📋 남은 제재: {verification['remaining_sanctions'] if verification else 0}개")
        print(f"   📝 남은 제재 리뷰: {verification['remaining_sanctioned_reviews'] if verification else 0}개")
        
        conn.close()
        
        return {
            "result": "제재 해제 완료", 
            "status": "success",
            "user_id": user_id,
            "message": f"사용자 {user_id}의 제재가 완전히 해제되었습니다.",
            "details": {
                "user_rows_updated": user_rows,
                "declaration_rows_updated": decl_rows,
                "review_rows_updated": review_rows + additional_rows,
                "sanctioned_reviews_count": len(sanctioned_reviews),
                "final_user_state": verification['user_state'] if verification else None,
                "remaining_sanctions": verification['remaining_sanctions'] if verification else 0
            }
        }
        
    except Exception as e:
        # 롤백
        conn.rollback()
        conn.close()
        error_msg = f'제재 해제 오류: {e}'
        print(f'❌ {error_msg}')
        return {
            "result": "제재 해제 실패", 
            "status": "error",
            "error": error_msg
        }


# 전체 문의 조회
@app.get('/inquiries')
async def get_all_inquiries():
    conn = connect()
    curs = conn.cursor()

    sql = '''
        SELECT 
            i.*,
            u.user_nickname
        FROM inquiry i
        LEFT JOIN users u ON i.user_id = u.user_id
        ORDER BY i.inquiry_date DESC
        '''
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()

    return {'inquiries': rows}

# 개별 문의 조회
@app.get('/inquiries_indi/{inquiry_num}')
async def get_inquiries(inquiry_num: int):
    conn = connect()
    curs = conn.cursor()

    sql = 'select * from inquiry where inquiry_num = %s'
    curs.execute(sql, (inquiry_num,))
    row = curs.fetchone()
    if row is None:
        return {'조회 실패': '해당 문의를 조회할 수 없습니다', 'inqury_num':inquiry_num }
    conn.close()

    return {"결과": row}

# 문의 등록
@app.post('/inquiry_insert')
async def inquiry_insert(
    userId: str = Form(...),
    inquiryDate: str = Form(..., description='YYYY-MM-DD 형식으로 입력'),
    inquiryContent: str = Form(...),
    inquiryState: str = Form(...),
    response: Optional[str] = Form(None),
    responseDate: Optional[str] = Form(None),
):
    # 날짜 형식 검증
    response = response if response else None
    responseDate = responseDate if responseDate else None

    try:
        datetime.strptime(inquiryDate, '%Y-%m-%d')
        if responseDate:
            datetime.strptime(responseDate, '%Y-%m-%d')
    except ValueError:
        raise HTTPException(status_code=400, detail="날짜는 YYYY-MM-DD 형식이어야 합니다")

    conn = connect()
    curs = conn.cursor()
    try:
        sql = '''
        insert into inquiry (
            user_id,
            inquiry_date,
            inquiry_content,
            inquiry_state,
            response,
            response_date
        ) values (%s, %s, %s, %s, %s, %s)
        '''
        curs.execute(sql, (
            userId,
            inquiryDate,
            inquiryContent,
            inquiryState,
            response,
            responseDate
        ))
        conn.commit()
        return {"result": "문의 등록 성공"}
    except Exception as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        conn.close()

# 문의 수정
@app.put('/inquiry/{inquiry_num}')
async def update_inquiry(
    inquiry_num: int = Path(..., alias="inquiry_num"),
    userId: str = Form(...),
    inquiryDate: str = Form(...),
    inquiryContent: str = Form(...),
    inquiryState: str = Form(...),
    response: Optional[str] = Form(None),
    responseDate: Optional[str] = Form(None)
):
    # 빈 문자열을 None으로 처리
    response = response if response else None
    responseDate = responseDate if responseDate else None

    try:
        datetime.strptime(inquiryDate, '%Y-%m-%d')
        if responseDate:
            datetime.strptime(responseDate, '%Y-%m-%d')
    except ValueError:
        raise HTTPException(status_code=400, detail="날짜는 YYYY-MM-DD 형식이어야 합니다")

    conn = connect()
    curs = conn.cursor()
    try:
        sql = '''
        update inquiry set
            user_id = %s,
            inquiry_date = %s,
            inquiry_content = %s,
            inquiry_state = %s,
            response = %s,
            response_date = %s
        where inquiry_num = %s
        '''
        curs.execute(sql, (
            userId,
            inquiryDate,
            inquiryContent,
            inquiryState,
            response,
            responseDate,
            inquiry_num
        ))
        conn.commit()
        return {"result": "문의 수정 완료"}
    except Exception as ex:
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        conn.close()

# 문의 삭제
@app.delete('/inquirise/{inquiry_num}')
async def delete_inquiry(inquiry_num: int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = 'delete from inquiry where inquiry_num = %s'
        curs.execute(sql, (inquiry_num,))
        conn.commit()
        return {'result': 'OK'}
    except Exception as ex:
        print('Error:', ex)
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        conn.close()

# =============== 개선된 매장 및 리뷰 관리 API ===============

# 전체 매장 조회 (개선된 버전)
@app.get('/stores')
async def get_all_stores():
    conn = connect()
    curs = conn.cursor()

    try:
        sql = '''
        SELECT 
            store_id,
            store_name,
            store_business_num,
            store_address,
            store_phone,
            store_state,
            store_content,
            (SELECT COUNT(*) FROM review r 
             JOIN purchase_list p ON r.purchase_num = p.purchase_num 
             WHERE p.store_id = s.store_id) as review_count
        FROM store s
        ORDER BY store_id ASC
        '''
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()

        return {"stores": rows}
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {"stores": []}

# 개별 매장 조회 (개선된 버전)
@app.get('/stores/{store_id}')
async def get_store(store_id: str):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = '''
        SELECT 
            s.*,
            COUNT(DISTINCT r.review_num) as total_reviews,
            AVG(CASE WHEN r.review_state = '정상' THEN 5 ELSE NULL END) as avg_rating
        FROM store s
        LEFT JOIN purchase_list p ON s.store_id = p.store_id
        LEFT JOIN review r ON p.purchase_num = r.purchase_num
        WHERE s.store_id = %s
        GROUP BY s.store_id
        '''
        curs.execute(sql, (store_id,))
        row = curs.fetchone()
        conn.close()

        if row:
            return {"store": row}
        return {"error": "매장을 찾을 수 없습니다"}
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {"error": "매장 조회 실패"}

# 매장별 리뷰 조회 (개선된 버전)
@app.get('/stores/{store_id}/reviews')
async def get_store_reviews(store_id: str):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = '''
        SELECT 
            r.review_num,
            r.purchase_num,
            r.review_content,
            r.review_image,
            r.review_date,
            r.review_state,
            p.user_id,
            u.user_nickname,
            u.user_image,
            u.user_state,
            p.store_id,
            s.store_name,
            -- 제재 정보 추가
            d.sanction_content,
            d.sanction_date,
            d.declaration_state
        FROM review r
        LEFT JOIN purchase_list p ON r.purchase_num = p.purchase_num
        LEFT JOIN users u ON p.user_id = u.user_id
        LEFT JOIN store s ON p.store_id = s.store_id
        LEFT JOIN declaration d ON r.review_num = d.review_num
        WHERE p.store_id = %s
        ORDER BY r.review_date DESC
        '''
        curs.execute(sql, (store_id,))
        rows = curs.fetchall()
        conn.close()

        return {"reviews": rows}
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {"reviews": []}

# 전체 리뷰 조회 (개선된 버전 - 최신 제재 상태 포함)
@app.get('/reviews')
async def get_all_reviews():
    conn = connect()
    curs = conn.cursor()

    try:
        sql = '''
        SELECT 
            r.review_num,
            r.purchase_num,
            r.review_content,
            r.review_image,
            r.review_date,
            r.review_state,
            p.user_id,
            u.user_nickname,
            u.user_image,
            u.user_state,
            p.store_id,
            s.store_name,
            s.store_address,
            -- 최신 제재 정보 (NULL이면 제재 해제된 상태)
            d.sanction_content,
            d.sanction_date,
            d.declaration_state,
            -- 제재 여부 확인
            CASE 
                WHEN d.sanction_content IS NOT NULL AND d.sanction_content != '' 
                THEN 'sanctioned'
                ELSE 'normal'
            END as current_sanction_status
        FROM review r
        LEFT JOIN purchase_list p ON r.purchase_num = p.purchase_num
        LEFT JOIN users u ON p.user_id = u.user_id
        LEFT JOIN store s ON p.store_id = s.store_id
        LEFT JOIN declaration d ON r.review_num = d.review_num 
            AND d.sanction_content IS NOT NULL  -- 제재 중인 것만
        ORDER BY r.review_date DESC
        '''
        curs.execute(sql)
        rows = curs.fetchall()
        
        print(f"✅ 리뷰 조회 완료: {len(rows)}개")
        
        # 제재된 리뷰 수 로그
        sanctioned_count = sum(1 for row in rows if row.get('sanction_content'))
        print(f"🚨 제재된 리뷰: {sanctioned_count}개")
        
        conn.close()
        return {"reviews": rows}
        
    except Exception as e:
        print(f'❌ 리뷰 조회 오류: {e}')
        conn.close()
        return {"reviews": []}

# 리뷰 상태 업데이트 (제재용)
@app.put('/reviews/{review_num}/status')
async def update_review_status(
    review_num: int,
    review_state: str = Form(...),
    reason: Optional[str] = Form(None)
):
    conn = connect()
    curs = conn.cursor()

    try:
        # 리뷰 상태 업데이트
        sql = '''
        UPDATE review 
        SET review_state = %s
        WHERE review_num = %s
        '''
        curs.execute(sql, (review_state, review_num))
        
        # 제재인 경우 로그 기록
        if review_state in ['제재', '삭제'] and reason:
            log_sql = '''
            INSERT INTO admin_log (action_type, target_id, reason, action_date)
            VALUES ('review_sanction', %s, %s, NOW())
            '''
            try:
                curs.execute(log_sql, (review_num, reason))
            except:
                pass  # 로그 테이블이 없어도 계속 진행
        
        conn.commit()
        conn.close()
        
        return {"result": "리뷰 상태 업데이트 완료", "status": "success"}
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {"result": "리뷰 상태 업데이트 실패", "status": "error"}

# 관리자 통계 정보 조회 (개선된 버전)
@app.get('/admin_stats')
async def get_admin_stats():
    conn = connect()
    curs = conn.cursor()
    
    try:
        # 매장 수 조회
        sql_stores = 'SELECT COUNT(*) as count FROM store'
        curs.execute(sql_stores)
        store_count = curs.fetchone()['count']
        
        # 유저 수 조회 (회원가입한 유저)
        sql_users = 'SELECT COUNT(*) as count FROM users'
        curs.execute(sql_users)
        user_count = curs.fetchone()['count']
        
        # 전체 리뷰 수 조회
        sql_reviews = 'SELECT COUNT(*) as count FROM review'
        curs.execute(sql_reviews)
        review_count = curs.fetchone()['count']
        
        # 제재중인 유저 수 조회
        sql_sanctioned = "SELECT COUNT(*) as count FROM users WHERE user_state = '제재중'"
        curs.execute(sql_sanctioned)
        sanctioned_count = curs.fetchone()['count']
        
        # 오늘 등록된 리뷰 수
        sql_today_reviews = '''
        SELECT COUNT(*) as count FROM review 
        WHERE DATE(review_date) = CURDATE()
        '''
        curs.execute(sql_today_reviews)
        today_review_count = curs.fetchone()['count']
        
        # 이번 달 등록된 매장 수
        sql_monthly_stores = '''
        SELECT COUNT(*) as count FROM store 
        WHERE YEAR(store_id) = YEAR(NOW()) AND MONTH(store_id) = MONTH(NOW())
        '''
        try:
            curs.execute(sql_monthly_stores)
            monthly_store_count = curs.fetchone()['count']
        except:
            monthly_store_count = 0
        
        conn.close()
        
        return {
            'store_count': store_count,
            'user_count': user_count,
            'review_count': review_count,
            'sanctioned_user_count': sanctioned_count,
            'today_review_count': today_review_count,
            'monthly_store_count': monthly_store_count
        }
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {
            'store_count': 0,
            'user_count': 0,
            'review_count': 0,
            'sanctioned_user_count': 0,
            'today_review_count': 0,
            'monthly_store_count': 0
        }

# 매장 통계 정보 조회 (매장별 리뷰 수, 평점 등)
@app.get('/store_stats')
async def get_store_stats():
    conn = connect()
    curs = conn.cursor()
    
    try:
        sql = '''
        SELECT 
            s.store_id,
            s.store_name,
            COUNT(r.review_num) as review_count,
            COUNT(CASE WHEN r.review_state = '정상' THEN 1 END) as normal_review_count,
            COUNT(CASE WHEN r.review_state = '제재' THEN 1 END) as sanctioned_review_count,
            COUNT(CASE WHEN DATE(r.review_date) = CURDATE() THEN 1 END) as today_review_count
        FROM store s
        LEFT JOIN purchase_list p ON s.store_id = p.store_id
        LEFT JOIN review r ON p.purchase_num = r.purchase_num
        GROUP BY s.store_id, s.store_name
        ORDER BY review_count DESC
        '''
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()
        
        return {"store_stats": rows}
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {"store_stats": []}

# 대시보드용 요약 정보
@app.get('/dashboard_summary')
async def get_dashboard_summary():
    conn = connect()
    curs = conn.cursor()
    
    try:
        # 기본 통계
        stats_sql = '''
        SELECT 
            (SELECT COUNT(*) FROM store) as total_stores,
            (SELECT COUNT(*) FROM users) as total_users,
            (SELECT COUNT(*) FROM review) as total_reviews,
            (SELECT COUNT(*) FROM users WHERE user_state = '제재중') as sanctioned_users,
            (SELECT COUNT(*) FROM review WHERE DATE(review_date) = CURDATE()) as today_reviews,
            (SELECT COUNT(*) FROM declaration WHERE sanction_content IS NOT NULL) as total_sanctions
        '''
        curs.execute(stats_sql)
        stats = curs.fetchone()
        
        # 최근 활동
        recent_sql = '''
        SELECT 
            'review' as type,
            r.review_content as content,
            u.user_nickname as user_name,
            r.review_date as created_at
        FROM review r
        LEFT JOIN purchase_list p ON r.purchase_num = p.purchase_num
        LEFT JOIN users u ON p.user_id = u.user_id
        ORDER BY r.review_date DESC
        LIMIT 5
        '''
        curs.execute(recent_sql)
        recent_activities = curs.fetchall()
        
        conn.close()
        
        return {
            "stats": stats,
            "recent_activities": recent_activities
        }
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {
            "stats": {
                "total_stores": 0,
                "total_users": 0,
                "total_reviews": 0,
                "sanctioned_users": 0,
                "today_reviews": 0,
                "total_sanctions": 0
            },
            "recent_activities": []
        }

if __name__=='__main__':
    import uvicorn
    uvicorn.run(app, host='192.168.50.236', port=8000)
