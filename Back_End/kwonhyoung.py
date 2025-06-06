"""
author      : Lee KwonHyoung
description : 소규모 카페 앱(관리자 파트 및 장바구니 드롭다운 적용, 메뉴 슬라이더블 )
date        : 2025.06.05
version     : 1
"""
# ----------------------------------------------------------------------------------- #
from fastapi import APIRouter
import pymysql
# 아래 모듈 추가(6.5)
from fastapi.responses import JSONResponse, Response
from typing import Optional
from datetime import datetime
import base64
# -------------------------------- Property  ---------------------------------------- #
#선언될 ip
ip = "127.0.0.1"
router = APIRouter()

# MySQL server host
def connect():
    return pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="qwer1234",
        db="mydb",
        charset="utf8"
    )
# ----------------------------------------------------------------------------------- #

# 전체 신고 조회
@app.get('/declarations')
async def get_all_declarations():
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
    ORDER BY d.declaration_date DESC
    '''
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()

    return {"declarations": rows}

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

# 신고 등록
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
        sql = '''
        INSERT INTO declaration (
            user_id, review_num,
            declaration_date, declaration_content,
            declaration_state, sanction_content,
            sanction_date
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        '''
        curs.execute(sql, (
            userId,
            reviewNum,
            declarationDate,
            declarationContent,
            declarationState,
            sanctionContent,
            sanctionDate
        ))
        conn.commit()
        return {"result": "신고 등록 성공", "status": "success"}
    except Exception as ex:
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        conn.close()

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

# 제재 해제
@app.put('/release_sanction/{user_id}')
async def release_sanction(user_id: str):
    conn = connect()
    curs = conn.cursor()
    
    try:
        # 사용자 상태를 '활성'으로 변경
        sql = '''
        UPDATE users 
        SET user_state = '활성'
        WHERE user_id = %s
        '''
        curs.execute(sql, (user_id,))
        conn.commit()
        conn.close()
        
        return {"result": "제재 해제 완료", "status": "success"}
    except Exception as e:
        print('Error:', e)
        conn.close()
        return {"result": "제재 해제 실패", "status": "error"}

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------- #

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

# ------------------------------(장바구니 엔드 포인트)-------------------------------- #

# 장바구니 구매 및 옵션 드롭다운
import json
import logging

@app.post("/order/select_menu")
async def insert_selected_menu(
    menuNum: int = Form(...),
    selectedOptions: str = Form(...),  # JSON 문자열로 받기
    selectedQuantity: int = Form(...),
    totalPrice: int = Form(...),
    purchaseNum: int = Form(...)
):
    conn = None
    curs = None
    
    try:
        # 입력 데이터 검증
        if not all([menuNum, selectedQuantity, totalPrice, purchaseNum]):
            return {"error": "필수 필드가 누락되었습니다"}
        
        if selectedQuantity <= 0 or totalPrice <= 0:
            return {"error": "수량과 가격은 0보다 커야 합니다"}
        
        # JSON 문자열 검증 및 정리
        try:
            if selectedOptions:
                # JSON이 올바른 형식인지 확인
                json_data = json.loads(selectedOptions)
                # 다시 JSON 문자열로 변환 (안전하게)
                clean_json = json.dumps(json_data, ensure_ascii=False)
            else:
                clean_json = "{}"
        except json.JSONDecodeError as e:
            logging.warning(f"JSON 파싱 오류: {e}, 원본 문자열 사용: {selectedOptions}")
            # JSON이 아닌 경우 원본 문자열 그대로 사용
            clean_json = selectedOptions if selectedOptions else "{}"
        except Exception as e:
            logging.error(f"JSON 처리 중 예상치 못한 오류: {e}")
            clean_json = "{}"
        
        # 데이터베이스 연결
        conn = connect()
        curs = conn.cursor()
       블 삭제)----------------------------------- #

# 메뉴 삭제
@app.delete('/delete_menu/{menu_num}')
async def delete_menu_indivisual(menu_num: int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = 'delete from menu where menu_num = %s'
        curs.execute(sql, (menu_num,))
        conn.commit()
        return {'삭제결과': "삭제함"}
    except Exception as ex:
        print('Error:', ex)
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        conn.close()


if __name__=='__main__':
    import uvicorn
    uvicorn.run(app, host='192.168.50.236', port=8000)
