"""
author : Team2
description : 팀프로젝트 소규모 카페 앱
date : 2025-06-11
version : 1.3 (수정본)
"""

from fastapi import HTTPException, Form, Path, APIRouter
import pymysql
from fastapi.responses import JSONResponse
from typing import Optional
from datetime import datetime
import base64

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host='127.0.0.1',
        user='root',
        password='qwer1234',
        db='pick_caffeine',
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor 
    )
    return conn

# 관리자 조회
@router.get('/select')
async def admin_select():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'select * from admin'
        curs.execute(sql)
        rows = curs.fetchall()
        return {'status': 'success', 'data': rows}
    except Exception as e:
        print(f'Error: {e}')
        return {'status': 'error', 'message': str(e), 'data': []}
    finally:
        if conn:
            conn.close()

# 전체 신고 조회
@router.get('/declarations')
async def get_all_declarations():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {"status": "success", "data": rows}
        
    except Exception as e:
        print(f"❌ 신고 조회 오류: {e}")
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

# 개별 신고 조회
@router.get('/declarations/{review_num}')
async def get_declaration(review_num: int):
    conn = None
    try:
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
        
        if row:
            return {"status": "success", "data": row}
        return {"status": "error", "message": "신고 내역을 찾을 수 없습니다"}
        
    except Exception as e:
        print(f'Error: {e}')
        return {"status": "error", "message": str(e)}
    finally:
        if conn:
            conn.close()

# 신고 등록 (중복 처리 및 안정성 강화)
@router.post('/declaration_insert')
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

    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        if conn:
            conn.rollback()
        raise
    except Exception as ex:
        if conn:
            conn.rollback()
        error_msg = f"제재 처리 실패: {str(ex)}"
        print(f"❌ {error_msg}")
        raise HTTPException(status_code=500, detail=error_msg)
    finally:
        if conn:
            conn.close()

# 신고 수정(제재 내용 포함)
@router.put('/declarations/{review_num}')
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

    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        UPDATE declaration SET
            user_id=%s,
            declaration_date=%s,
            declaration_content=%s,
            declaration_state=%s,
            sanction_content=%s,
            sanction_date=%s
        WHERE review_num=%s
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
        
        return {"status": "success", "message": "신고 수정 완료"}
        
    except Exception as ex:
        print("Error:", ex)
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        if conn:
            conn.close()

# 신고 삭제
@router.delete('/declarations/{review_num}')
async def delete_declaration(review_num: int):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        sql = 'DELETE FROM declaration WHERE review_num = %s'
        curs.execute(sql, (review_num,))
        conn.commit()
        
        return {'status': 'success', 'message': '신고 삭제 완료'}
        
    except Exception as e:
        print('Error:', e)
        if conn:
            conn.rollback()
        return {'status': 'error', 'message': str(e)}
    finally:
        if conn:
            conn.close()

# 통계 정보 조회
@router.get('/stats')
async def get_stats():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {
            'status': 'success',
            'data': {
                'user_count': user_count,
                'store_count': store_count,
                'sanctioned_user_count': sanctioned_count
            }
        }
    except Exception as e:
        print('Error:', e)
        return {
            'status': 'error',
            'message': str(e),
            'data': {
                'user_count': 0,
                'store_count': 0,
                'sanctioned_user_count': 0
            }
        }
    finally:
        if conn:
            conn.close()

# 제재 유저 목록 조회
@router.get('/sanctioned_users')
async def get_sanctioned_users():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {"status": "success", "data": rows}
        
    except Exception as e:
        print('Error:', e)
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

# 제재 해제
@router.put('/release_sanction/{user_id}')
async def release_sanction(user_id: str):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {
            "status": "success",
            "message": f"사용자 {user_id}의 제재가 완전히 해제되었습니다.",
            "data": {
                "user_id": user_id,
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
        if conn:
            conn.rollback()
        error_msg = f'제재 해제 오류: {e}'
        print(f'❌ {error_msg}')
        return {
            "status": "error", 
            "message": error_msg
        }
    finally:
        if conn:
            conn.close()

# 전체 문의 조회
@router.get('/inquiries')
async def get_all_inquiries():
    conn = None
    try:
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
        
        return {'status': 'success', 'data': rows}
        
    except Exception as e:
        print(f'Error: {e}')
        return {'status': 'error', 'message': str(e), 'data': []}
    finally:
        if conn:
            conn.close()

# 개별 문의 조회
@router.get('/inquiries/{inquiry_num}')
async def get_inquiry(inquiry_num: int):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        sql = 'SELECT * FROM inquiry WHERE inquiry_num = %s'
        curs.execute(sql, (inquiry_num,))
        row = curs.fetchone()
        
        if row is None:
            return {
                'status': 'error',
                'message': '해당 문의를 찾을 수 없습니다',
                'inquiry_num': inquiry_num
            }
            
        return {"status": "success", "data": row}
        
    except Exception as e:
        print(f'Error: {e}')
        return {'status': 'error', 'message': str(e)}
    finally:
        if conn:
            conn.close()

# 문의 등록
@router.post('/inquiry_insert')
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

    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        sql = '''
        INSERT INTO inquiry (
            user_id,
            inquiry_date,
            inquiry_content,
            inquiry_state,
            response,
            response_date
        ) VALUES (%s, %s, %s, %s, %s, %s)
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
        
        return {"status": "success", "message": "문의 등록 성공"}
        
    except Exception as ex:
        print("Error:", ex)
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        if conn:
            conn.close()

# 문의 수정
@router.put('/inquiries/{inquiry_num}')
async def update_inquiry(
    inquiry_num: int = Path(...),
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

    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        sql = '''
        UPDATE inquiry SET
            user_id = %s,
            inquiry_date = %s,
            inquiry_content = %s,
            inquiry_state = %s,
            response = %s,
            response_date = %s
        WHERE inquiry_num = %s
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
        
        return {"status": "success", "message": "문의 수정 완료"}
        
    except Exception as ex:
        print(f"Error: {ex}")
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        if conn:
            conn.close()

# 문의 삭제
@router.delete('/inquiries/{inquiry_num}')
async def delete_inquiry(inquiry_num: int):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        sql = 'DELETE FROM inquiry WHERE inquiry_num = %s'
        curs.execute(sql, (inquiry_num,))
        conn.commit()
        
        return {'status': 'success', 'message': '문의 삭제 완료'}
        
    except Exception as ex:
        print('Error:', ex)
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        if conn:
            conn.close()

# 전체 매장 조회
@router.get('/stores')
async def get_all_stores():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {"status": "success", "data": rows}
        
    except Exception as e:
        print('Error:', e)
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

# 개별 매장 조회
@router.get('/stores/{store_id}')
async def get_store(store_id: str):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        if row:
            return {"status": "success", "data": row}
        return {"status": "error", "message": "매장을 찾을 수 없습니다"}
        
    except Exception as e:
        print('Error:', e)
        return {"status": "error", "message": str(e)}
    finally:
        if conn:
            conn.close()

# 매장별 리뷰 조회
@router.get('/stores/{store_id}/reviews')
async def get_store_reviews(store_id: str):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {"status": "success", "data": rows}
        
    except Exception as e:
        print('Error:', e)
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

# 전체 리뷰 조회
@router.get('/reviews')
async def get_all_reviews():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
            d.sanction_content,
            d.sanction_date,
            d.declaration_state,
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
            AND d.sanction_content IS NOT NULL
        ORDER BY r.review_date DESC
        '''
        curs.execute(sql)
        rows = curs.fetchall()
        
        print(f"✅ 리뷰 조회 완료: {len(rows)}개")
        
        # 제재된 리뷰 수 로그
        sanctioned_count = sum(1 for row in rows if row.get('sanction_content'))
        print(f"🚨 제재된 리뷰: {sanctioned_count}개")
        
        return {"status": "success", "data": rows}
        
    except Exception as e:
        print(f'❌ 리뷰 조회 오류: {e}')
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

# 리뷰 상태 업데이트
@router.put('/reviews/{review_num}/status')
async def update_review_status(
    review_num: int,
    review_state: str = Form(...),
    reason: Optional[str] = Form(None)
):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {"status": "success", "message": "리뷰 상태 업데이트 완료"}
        
    except Exception as e:
        print('Error:', e)
        if conn:
            conn.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        if conn:
            conn.close()

# 관리자 통계 정보 조회
@router.get('/admin_stats')
async def get_admin_stats():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        # 매장 수 조회
        sql_stores = 'SELECT COUNT(*) as count FROM store'
        curs.execute(sql_stores)
        store_count = curs.fetchone()['count']
        
        # 유저 수 조회
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
        WHERE YEAR(store_create_date) = YEAR(NOW()) 
        AND MONTH(store_create_date) = MONTH(NOW())
        '''
        try:
            curs.execute(sql_monthly_stores)
            monthly_store_count = curs.fetchone()['count']
        except:
            monthly_store_count = 0
        
        return {
            'status': 'success',
            'data': {
                'store_count': store_count,
                'user_count': user_count,
                'review_count': review_count,
                'sanctioned_user_count': sanctioned_count,
                'today_review_count': today_review_count,
                'monthly_store_count': monthly_store_count
            }
        }
    except Exception as e:
        print('Error:', e)
        return {
            'status': 'error',
            'message': str(e),
            'data': {
                'store_count': 0,
                'user_count': 0,
                'review_count': 0,
                'sanctioned_user_count': 0,
                'today_review_count': 0,
                'monthly_store_count': 0
            }
        }
    finally:
        if conn:
            conn.close()

# 매장 통계 정보 조회
@router.get('/store_stats')
async def get_store_stats():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {"status": "success", "data": rows}
        
    except Exception as e:
        print('Error:', e)
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

# 대시보드용 요약 정보
@router.get('/dashboard_summary')
async def get_dashboard_summary():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
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
        
        return {
            "status": "success",
            "data": {
                "stats": stats,
                "recent_activities": recent_activities
            }
        }
        
    except Exception as e:
        print('Error:', e)
        return {
            "status": "error",
            "message": str(e),
            "data": {
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
        }
    finally:
        if conn:
            conn.close()
