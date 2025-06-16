"""
author : Team2
description : 팀프로젝트 소규모 카페 앱
date : 2025-06-12
version : 1.4 (매장 리스트, 리뷰, 이미지 갱신 수정)
"""

from fastapi import HTTPException, Form, Path, APIRouter
import pymysql
from fastapi.responses import JSONResponse
from datetime import datetime
import base64
from typing import List, Optional
import json



ip = "192.168.50.2"
router = APIRouter()

# MySQL server host
def connect():
    return pymysql.connect(
        host=ip,
        user="root",
        password="qwer1234qwer1234",
        db="pick_caffeine",
        charset="utf8"
    )
# =================== 로그인 관련 API ===================

from fastapi import APIRouter, Form, HTTPException
import pymysql

router = APIRouter()

def connect():
    return pymysql.connect(
        host='127.0.0.1',
        user='root',
        password='qwer1234',
        db='pick_caffeine',
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )

@router.post('/admin_login')
async def admin_login(
    admin_id: str = Form(...),
    admin_password: str = Form(...)
):
    """관리자 로그인"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'SELECT * FROM admin WHERE admin_id = %s AND admin_password = %s'
        curs.execute(sql, (admin_id, admin_password))
        admin = curs.fetchone()
        if admin:
            return {
                "status": "success",
                "message": "로그인 성공",
                "data": {
                    "admin_id": admin['admin_id'],
                    "admin_name": admin.get('admin_name', admin_id)
                }
            }
        else:
            return {
                "status": "error",
                "message": "아이디 또는 비밀번호가 올바르지 않습니다."
            }
    except Exception as e:
        return {
            "status": "error",
            "message": f"로그인 처리 중 오류: {str(e)}"
        }
    finally:
        if conn:
            conn.close()


@router.post('/admin_logout')
async def admin_logout(
    admin_id: str = Form(...)
):
    """관리자 로그아웃"""
    try:
        return {
            "status": "success",
            "message": "로그아웃 완료"
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"로그아웃 처리 중 오류: {str(e)}"
        }

# =================== 기본 관리자 API ===================

@router.get('/select')
async def admin_select():
    """전체 관리자 목록 조회"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'SELECT * FROM admin'
        curs.execute(sql)
        rows = curs.fetchall()
        return {'status': 'success', 'data': rows}
    except Exception as e:
        return {'status': 'error', 'message': str(e), 'data': []}
    finally:
        if conn:
            conn.close()

# =================== 매장 관련 API ===================

@router.get('/stores')
async def get_all_stores():
    """전체 매장 목록 조회 - 안정성 강화 및 오류 해결"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        # 먼저 store 테이블만으로 기본 조회 시도
        basic_sql = '''
        SELECT
            s.store_id,
            s.store_name,
            s.store_business_num,
            s.store_address,
            s.store_address_detail,
            s.store_phone,
            s.store_content,
            s.store_state
        FROM store s
        ORDER BY s.store_id ASC
        '''
        
        curs.execute(basic_sql)
        basic_rows = curs.fetchall()
        
        if not basic_rows:
            return {
                "status": "success",
                "data": [],
                "total_count": 0,
                "message": "등록된 매장이 없습니다."
            }

        processed_stores = []
        for index, row in enumerate(basic_rows):
            try:
                store_data = dict(row)
                
                # 기본 필드 안전 처리
                store_data['store_id'] = str(store_data.get('store_id', ''))
                store_data['store_name'] = str(store_data.get('store_name', '매장명 없음'))
                store_data['store_business_num'] = str(store_data.get('store_business_num', '정보 없음'))
                store_data['store_address'] = str(store_data.get('store_address', '주소 정보 없음'))
                store_data['store_address_detail'] = str(store_data.get('store_address_detail', ''))
                store_data['store_phone'] = str(store_data.get('store_phone', '')) if store_data.get('store_phone') else None
                store_data['store_content'] = str(store_data.get('store_content', ''))
                store_data['store_state'] = str(store_data.get('store_state', '연결 안됨'))
                
                # 추가 필드 기본값 설정
                store_data['store_latitude'] = 0.0
                store_data['store_longitude'] = 0.0
                store_data['store_regular_holiday'] = ''
                store_data['store_temporary_holiday'] = ''
                store_data['store_business_hour'] = ''
                store_data['store_created_date'] = None
                store_data['store_image'] = None
                store_data['store_image_base64'] = None
                store_data['review_count'] = 0
                
                # 리뷰 수 계산 (안전하게)
                try:
                    review_sql = '''
                    SELECT COUNT(*) as count FROM review r
                    JOIN purchase_list p ON r.purchase_num = p.purchase_num
                    WHERE p.store_id = %s
                    '''
                    curs.execute(review_sql, (store_data['store_id'],))
                    review_result = curs.fetchone()
                    store_data['review_count'] = int(review_result['count']) if review_result else 0
                except:
                    store_data['review_count'] = 0
                
                # 이미지 처리 (안전하게)
                try:
                    image_sql = 'SELECT image_1 FROM store_image WHERE store_id = %s'
                    curs.execute(image_sql, (store_data['store_id'],))
                    image_result = curs.fetchone()
                    
                    if image_result and image_result['image_1']:
                        image_blob = image_result['image_1']
                        if isinstance(image_blob, bytes) and len(image_blob) > 0:
                            base64_string = base64.b64encode(image_blob).decode('utf-8')
                            store_data['store_image'] = base64_string
                            store_data['store_image_base64'] = base64_string
                except:
                    # 이미지 처리 실패해도 매장 정보는 유지
                    pass
                
                # 추가 필드 조회 (안전하게)
                try:
                    detail_sql = '''
                    SELECT 
                        store_latitude, 
                        store_longitude, 
                        store_regular_holiday, 
                        store_temporary_holiday, 
                        store_business_hour, 
                        store_created_date
                    FROM store WHERE store_id = %s
                    '''
                    curs.execute(detail_sql, (store_data['store_id'],))
                    detail_result = curs.fetchone()
                    
                    if detail_result:
                        store_data['store_latitude'] = float(detail_result.get('store_latitude', 0.0)) if detail_result.get('store_latitude') else 0.0
                        store_data['store_longitude'] = float(detail_result.get('store_longitude', 0.0)) if detail_result.get('store_longitude') else 0.0
                        store_data['store_regular_holiday'] = str(detail_result.get('store_regular_holiday', ''))
                        store_data['store_temporary_holiday'] = str(detail_result.get('store_temporary_holiday', ''))
                        store_data['store_business_hour'] = str(detail_result.get('store_business_hour', ''))
                        store_data['store_created_date'] = detail_result.get('store_created_date')
                except:
                    # 추가 필드 조회 실패해도 기본 정보는 유지
                    pass
                
                processed_stores.append(store_data)
                
            except Exception as store_error:
                # 개별 매장 처리 실패 시에도 기본 정보라도 제공
                error_store = {
                    'store_id': str(row.get('store_id', f'error_store_{index}')),
                    'store_name': str(row.get('store_name', '매장 정보 오류')),
                    'store_business_num': str(row.get('store_business_num', '정보 없음')),
                    'store_address': str(row.get('store_address', '주소 정보 없음')),
                    'store_address_detail': str(row.get('store_address_detail', '')),
                    'store_phone': None,
                    'store_content': str(row.get('store_content', '')),
                    'store_state': str(row.get('store_state', '연결 안됨')),
                    'store_latitude': 0.0,
                    'store_longitude': 0.0,
                    'store_regular_holiday': '',
                    'store_temporary_holiday': '',
                    'store_business_hour': '',
                    'store_created_date': None,
                    'review_count': 0,
                    'store_image': None,
                    'store_image_base64': None
                }
                processed_stores.append(error_store)
                continue

        return {
            "status": "success",
            "data": processed_stores,
            "total_count": len(processed_stores),
            "message": f"{len(processed_stores)}개의 매장을 조회했습니다."
        }

    except Exception as e:
        error_msg = f"매장 목록 조회 중 오류 발생: {str(e)}"
        print(f"Store API Error: {error_msg}")  # 서버 로그용
        
        # 최소한의 응답이라도 제공
        return {
            "status": "error",
            "message": error_msg,
            "data": [],
            "total_count": 0,
            "debug_info": str(e)  # 디버깅용 정보 추가
        }
    finally:
        if conn:
            conn.close()

# 개별 매장 조회
@router.get('/stores/{store_id}')
async def get_store(store_id: str):
    """개별 매장 상세 정보 조회"""
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
        return {"status": "error", "message": str(e)}
    finally:
        if conn:
            conn.close()

# 강제 새로고침
@router.post('/stores/refresh')
async def refresh_stores():
    """매장 데이터를 강제로 새로고침하는 API"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        curs.execute("SHOW TABLES LIKE 'store'")
        if not curs.fetchone():
            return {"status": "error", "message": "store 테이블이 존재하지 않습니다."}

        curs.execute("SELECT COUNT(*) as count FROM store")
        store_count = curs.fetchone()['count']
        
        curs.execute("""
            SELECT COUNT(*) as count 
            FROM store s 
            JOIN store_image si ON s.store_id = si.store_id 
            WHERE si.image_2 IS NOT NULL
        """)
        image_count = curs.fetchone()['count']

        return {
            "status": "success",
            "message": f"매장 데이터 새로고침 완료. 총 {store_count}개 매장 확인됨 (이미지: {image_count}개)",
            "store_count": store_count,
            "image_count": image_count
        }

    except Exception as e:
        return {"status": "error", "message": f"새로고침 실패: {str(e)}"}
    finally:
        if conn:
            conn.close()

# =================== 리뷰 관련 API ===================

@router.get('/reviews')
async def get_all_reviews():
    """전체 리뷰 목록 조회 - 이미지 처리 개선"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql_reviews = '''
        SELECT
            r.review_num,
            r.purchase_num,
            r.review_content,
            r.review_image,
            r.review_date,
            r.review_state
        FROM review r
        ORDER BY r.review_date DESC
        '''
        curs.execute(sql_reviews)
        reviews = curs.fetchall()

        enriched_reviews = []
        for review in reviews:
            try:
                review_image_base64 = None
                if review.get('review_image') and isinstance(review['review_image'], bytes):
                    try:
                        review_image_base64 = base64.b64encode(review['review_image']).decode('utf-8')
                    except Exception:
                        review_image_base64 = None

                sql_purchase = 'SELECT user_id, store_id FROM purchase_list WHERE purchase_num = %s'
                curs.execute(sql_purchase, (review['purchase_num'],))
                purchase = curs.fetchone()

                if purchase:
                    sql_user = 'SELECT user_nickname, user_image, user_state FROM users WHERE user_id = %s'
                    curs.execute(sql_user, (purchase['user_id'],))
                    user = curs.fetchone()

                    sql_store = 'SELECT store_name, store_address FROM store WHERE store_id = %s'
                    curs.execute(sql_store, (purchase['store_id'],))
                    store = curs.fetchone()

                    sql_declaration = 'SELECT sanction_content, sanction_date, declaration_state FROM declaration WHERE review_num = %s'
                    curs.execute(sql_declaration, (review['review_num'],))
                    declaration = curs.fetchone()

                    enriched_review = {
                        'review_num': review['review_num'],
                        'purchase_num': review['purchase_num'],
                        'review_content': review['review_content'],
                        'review_image': review_image_base64,
                        'review_date': review['review_date'],
                        'review_state': review['review_state'],
                        'user_id': purchase['user_id'],
                        'store_id': purchase['store_id'],
                        'user_nickname': user['user_nickname'] if user else purchase['user_id'],
                        'user_image': user['user_image'] if user else None,
                        'user_state': user['user_state'] if user else '알수없음',
                        'store_name': store['store_name'] if store else '알수없는 매장',
                        'store_address': store['store_address'] if store else '',
                        'sanction_content': declaration['sanction_content'] if declaration else None,
                        'sanction_date': declaration['sanction_date'] if declaration else None,
                        'declaration_state': declaration['declaration_state'] if declaration else None,
                        'current_sanction_status': 'sanctioned' if (declaration and declaration['sanction_content']) else 'normal'
                    }
                    enriched_reviews.append(enriched_review)
                else:
                    enriched_review = {
                        'review_num': review['review_num'],
                        'purchase_num': review['purchase_num'],
                        'review_content': review['review_content'],
                        'review_image': review_image_base64,
                        'review_date': review['review_date'],
                        'review_state': review['review_state'],
                        'user_id': 'unknown',
                        'store_id': 'unknown',
                        'user_nickname': 'unknown',
                        'user_image': None,
                        'user_state': 'unknown',
                        'store_name': 'unknown',
                        'store_address': '',
                        'sanction_content': None,
                        'sanction_date': None,
                        'declaration_state': None,
                        'current_sanction_status': 'normal'
                    }
                    enriched_reviews.append(enriched_review)
            except Exception as e:
                continue

        return {"status": "success", "data": enriched_reviews}
    except Exception as e:
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

@router.get('/stores/{store_id}/reviews')
async def get_store_reviews(store_id: str):
    """특정 매장의 리뷰 목록 조회"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = '''
        SELECT
            r.review_num, r.purchase_num, r.review_content, r.review_image,
            r.review_date, r.review_state, p.user_id, p.store_id,
            COALESCE(u.user_nickname, p.user_id) as user_nickname,
            u.user_image, COALESCE(u.user_state, '알수없음') as user_state,
            s.store_name, s.store_address, d.sanction_content, d.sanction_date,
            d.declaration_state,
            CASE
                WHEN d.sanction_content IS NOT NULL AND d.sanction_content != ''
                THEN 'sanctioned'
                ELSE 'normal'
            END as current_sanction_status
        FROM review r
        INNER JOIN purchase_list p ON r.purchase_num = p.purchase_num
        LEFT JOIN users u ON p.user_id = u.user_id
        LEFT JOIN store s ON p.store_id = s.store_id
        LEFT JOIN declaration d ON r.review_num = d.review_num
        WHERE p.store_id = %s
        ORDER BY r.review_date DESC
        '''
        curs.execute(sql, (store_id,))
        rows = curs.fetchall()

        processed_reviews = []
        for row in rows:
            review_data = dict(row)
            if review_data.get('review_image') and isinstance(review_data['review_image'], bytes):
                try:
                    review_data['review_image'] = base64.b64encode(review_data['review_image']).decode('utf-8')
                except Exception:
                    review_data['review_image'] = None
            else:
                review_data['review_image'] = None
            processed_reviews.append(review_data)

        return {"status": "success", "data": processed_reviews}
    except Exception as e:
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

@router.put('/reviews/{review_num}/status')
async def update_review_status(
    review_num: int,
    review_state: str = Form(...),
    reason: Optional[str] = Form(None)
):
    """리뷰 상태 업데이트"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = '''
        UPDATE review
        SET review_state = %s
        WHERE review_num = %s
        '''
        curs.execute(sql, (review_state, review_num))

        if review_state in ['제재', '삭제'] and reason:
            log_sql = '''
            INSERT INTO admin_log (action_type, target_id, reason, action_date)
            VALUES ('review_sanction', %s, %s, NOW())
            '''
            try:
                curs.execute(log_sql, (review_num, reason))
            except:
                pass

        conn.commit()
        return {"status": "success", "message": "리뷰 상태 업데이트 완료"}
    except Exception as e:
        if conn:
            conn.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        if conn:
            conn.close()

# =================== 신고 관련 API ===================

@router.get('/declarations')
async def get_all_declarations():
    """전체 신고 목록 조회"""
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
            COALESCE(u.user_nickname, d.user_id) as user_nickname,
            u.user_image,
            COALESCE(u.user_state, '알수없음') as user_state
        FROM declaration d
        LEFT JOIN users u ON d.user_id = u.user_id
        ORDER BY
            CASE WHEN d.sanction_date IS NOT NULL THEN d.sanction_date
                 ELSE d.declaration_date END DESC
        '''
        curs.execute(sql)
        rows = curs.fetchall()

        return {"status": "success", "data": rows}
    except Exception as e:
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

@router.get('/declarations/{review_num}')
async def get_declaration(review_num: int):
    """개별 신고 상세 정보 조회"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        SELECT
            d.*,
            COALESCE(u.user_nickname, d.user_id) as user_nickname,
            u.user_image,
            COALESCE(u.user_state, '알수없음') as user_state
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
        return {"status": "error", "message": str(e)}
    finally:
        if conn:
            conn.close()

@router.post('/declaration_insert')
async def declaration_insert(
    userId: str = Form(...),
    reviewNum: int = Form(...),
    declarationContent: str = Form(...),
    declarationDate: str = Form(...),
    declarationState: str = Form(...),
    sanctionContent: Optional[str] = Form(None),
    sanctionDate: Optional[str] = Form(None)
):
    """신고 등록 - 제재 처리 포함"""
    sanctionContent = sanctionContent if sanctionContent else None
    sanctionDate = sanctionDate if sanctionDate else None

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

        conn.begin()

        user_check_sql = "SELECT user_id FROM users WHERE user_id = %s"
        curs.execute(user_check_sql, (userId,))
        if not curs.fetchone():
            raise HTTPException(status_code=404, detail=f"사용자 {userId}를 찾을 수 없습니다")

        review_check_sql = "SELECT review_num FROM review WHERE review_num = %s"
        curs.execute(review_check_sql, (reviewNum,))
        if not curs.fetchone():
            raise HTTPException(status_code=404, detail=f"리뷰 {reviewNum}를 찾을 수 없습니다")

        check_sql = '''
        SELECT declaration_state, sanction_content FROM declaration
        WHERE user_id = %s AND review_num = %s
        '''
        curs.execute(check_sql, (userId, reviewNum))
        existing = curs.fetchone()

        if existing:
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
        else:
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

        if sanctionContent and sanctionDate:
            update_user_sql = "UPDATE users SET user_state = '제재중' WHERE user_id = %s"
            curs.execute(update_user_sql, (userId,))

            update_review_sql = "UPDATE review SET review_state = '제재' WHERE review_num = %s"
            curs.execute(update_review_sql, (reviewNum,))

        conn.commit()

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
        raise HTTPException(status_code=500, detail=error_msg)
    finally:
        if conn:
            conn.close()

@router.put('/declarations/{review_num}')
async def update_declaration(
    review_num: int,
    userId: str = Form(...),
    declarationDate: str = Form(...),
    declarationContent: str = Form(...),
    declarationState: str = Form(...),
    sanctionContent: Optional[str] = Form(None),
    sanctionDate: Optional[str] = Form(None)
):
    """신고 수정 - 제재 내용 포함"""
    sanctionContent = sanctionContent if sanctionContent else None
    sanctionDate = sanctionDate if sanctionDate else None

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

        if sanctionContent and sanctionDate:
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
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        if conn:
            conn.close()

@router.delete('/declarations/{review_num}')
async def delete_declaration(review_num: int):
    """신고 삭제"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'DELETE FROM declaration WHERE review_num = %s'
        curs.execute(sql, (review_num,))
        conn.commit()
        return {'status': 'success', 'message': '신고 삭제 완료'}
    except Exception as e:
        if conn:
            conn.rollback()
        return {'status': 'error', 'message': str(e)}
    finally:
        if conn:
            conn.close()

# =================== 제재 관련 API ===================

@router.get('/sanctioned_users')
async def get_sanctioned_users():
    """제재된 유저 목록 조회"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        SELECT
            u.user_id,
            COALESCE(u.user_nickname, u.user_id) as user_nickname,
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
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()


# 제재 해제 (안정성 강화)
@router.put('/release_sanction/{user_id}')
async def release_sanction(user_id: str):
    """사용자 제재 해제"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        # 트랜잭션 시작
        conn.begin()

        # 1. 해당 사용자의 제재된 리뷰 번호들 조회
        get_reviews_sql = '''
        SELECT DISTINCT d.review_num
        FROM declaration d
        WHERE d.user_id = %s AND d.sanction_content IS NOT NULL
        '''
        curs.execute(get_reviews_sql, (user_id,))
        sanctioned_reviews = [row['review_num'] for row in curs.fetchall()]

        # 2. 사용자 상태를 '활성'으로 변경
        update_user_sql = '''
        UPDATE users
        SET user_state = '활성'
        WHERE user_id = %s
        '''
        user_rows = curs.execute(update_user_sql, (user_id,))

        # 3. 해당 사용자의 제재 내용을 제거
        update_declaration_sql = '''
        UPDATE declaration
        SET sanction_content = NULL, sanction_date = NULL
        WHERE user_id = %s AND sanction_content IS NOT NULL
        '''
        decl_rows = curs.execute(update_declaration_sql, (user_id,))

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

        # 5. 추가로 해당 사용자의 모든 제재된 리뷰 복원 (안전장치)
        additional_review_sql = '''
        UPDATE review r
        JOIN purchase_list p ON r.purchase_num = p.purchase_num
        SET r.review_state = '정상'
        WHERE p.user_id = %s AND r.review_state = '제재'
        '''
        additional_rows = curs.execute(additional_review_sql, (user_id,))

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
        return {
            "status": "error",
            "message": error_msg
        }
    finally:
        if conn:
            conn.close()

# =================== 통계 관련 API ===================

# 기본 통계 정보 조회
@router.get('/stats')
async def get_stats():
    """기본 통계 정보 조회"""
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

# 관리자 통계 정보 조회
@router.get('/admin_stats')
async def get_admin_stats():
    """관리자용 상세 통계 정보 조회"""
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
        WHERE YEAR(store_created_date) = YEAR(NOW())
        AND MONTH(store_created_date) = MONTH(NOW())
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
    """매장별 통계 정보 조회"""
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
        return {"status": "error", "message": str(e), "data": []}
    finally:
        if conn:
            conn.close()

# 대시보드용 요약 정보
@router.get('/dashboard_summary')
async def get_dashboard_summary():
    """대시보드용 요약 정보 조회"""
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
            COALESCE(u.user_nickname, p.user_id) as user_name,
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

# =================== 문의 관련 API ===================

# 전체 문의 조회
@router.get('/inquiries')
async def get_all_inquiries():
    """전체 문의 목록 조회"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        SELECT
            i.*,
            COALESCE(u.user_nickname, i.user_id) as user_nickname
        FROM inquiry i
        LEFT JOIN users u ON i.user_id = u.user_id
        ORDER BY i.inquiry_date DESC
        '''
        curs.execute(sql)
        rows = curs.fetchall()
        return {'status': 'success', 'data': rows}
    except Exception as e:
        return {'status': 'error', 'message': str(e), 'data': []}
    finally:
        if conn:
            conn.close()

# 개별 문의 조회
@router.get('/inquiries/{inquiry_num}')
async def get_inquiry(inquiry_num: int):
    """개별 문의 상세 정보 조회"""
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
    """문의 등록"""
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
    """문의 수정"""
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
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        if conn:
            conn.close()

# 문의 삭제
@router.delete('/inquiries/{inquiry_num}')
async def delete_inquiry(inquiry_num: int):
    """문의 삭제"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'DELETE FROM inquiry WHERE inquiry_num = %s'
        curs.execute(sql, (inquiry_num,))
        conn.commit()
        return {'status': 'success', 'message': '문의 삭제 완료'}
    except Exception as ex:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(ex))
    finally:
        if conn:
            conn.close()

# =================== 이미지 관련 API ===================

# store_image 테이블에서 이미지 조회 - image_2 우선순위로 수정
@router.get('/stores/{store_id}/images')
async def get_store_images(store_id: str):
    """매장 이미지 조회"""
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
        SELECT store_id, image_1, image_2, image_3, image_4, image_5
        FROM store_image
        WHERE store_id = %s
        '''
        curs.execute(sql, (store_id,))
        row = curs.fetchone()

        if row:
            # BLOB 데이터를 base64로 변환
            images = {}
            for i in range(1, 6):  # image_1부터 image_5까지
                blob_data = row.get(f'image_{i}')
                if blob_data:
                    # BLOB을 base64 문자열로 변환
                    base64_string = base64.b64encode(blob_data).decode('utf-8')
                    images[f'image_{i}'] = f'data:image/jpeg;base64,{base64_string}'
                else:
                    images[f'image_{i}'] = None

            result = {
                'store_id': row['store_id'],
                'images': images,
                'primary_image': images.get('image_2') or images.get('image_1')  # image_2 우선, 없으면 image_1
            }

            return {"status": "success", "data": result}
        else:
            return {"status": "error", "message": "해당 매장의 이미지를 찾을 수 없습니다"}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        if conn:
            conn.close()

# store_image 테이블에 이미지 업로드
@router.post('/stores/{store_id}/upload_image')
async def upload_store_image(
    store_id: str,
    image_slot: int = Form(..., description="이미지 슬롯 (1-5)"),
    image_data: str = Form(..., description="base64 인코딩된 이미지 데이터")
):
    """매장 이미지 업로드"""
    if image_slot < 1 or image_slot > 5:
        raise HTTPException(status_code=400, detail="이미지 슬롯은 1-5 사이여야 합니다")

    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        # base64 데이터를 BLOB로 변환
        try:
            # data:image/jpeg;base64, 부분 제거
            if image_data.startswith('data:image'):
                image_data = image_data.split(',')[1]
            blob_data = base64.b64decode(image_data)
        except Exception as e:
            raise HTTPException(status_code=400, detail="잘못된 base64 이미지 데이터")

        # 매장 존재 확인
        check_sql = "SELECT store_id FROM store WHERE store_id = %s"
        curs.execute(check_sql, (store_id,))
        if not curs.fetchone():
            raise HTTPException(status_code=404, detail="매장을 찾을 수 없습니다")

        # store_image 테이블에 데이터 존재 확인
        check_image_sql = "SELECT store_id FROM store_image WHERE store_id = %s"
        curs.execute(check_image_sql, (store_id,))
        exists = curs.fetchone()

        column_name = f'image_{image_slot}'

        if exists:
            # 기존 레코드 업데이트
            update_sql = f'''
            UPDATE store_image
            SET {column_name} = %s
            WHERE store_id = %s
            '''
            curs.execute(update_sql, (blob_data, store_id))
        else:
            # 새 레코드 삽입
            insert_sql = f'''
            INSERT INTO store_image (store_id, {column_name})
            VALUES (%s, %s)
            '''
            curs.execute(insert_sql, (store_id, blob_data))

        conn.commit()

        return {
            "status": "success",
            "message": f"매장 {store_id}의 이미지 {image_slot}이 업로드되었습니다"
        }
    except HTTPException:
        if conn:
            conn.rollback()
        raise
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()

# store_image 테이블에서 이미지 삭제
@router.delete('/stores/{store_id}/images/{image_slot}')
async def delete_store_image(store_id: str, image_slot: int):
    """매장 이미지 삭제"""
    if image_slot < 1 or image_slot > 5:
        raise HTTPException(status_code=400, detail="이미지 슬롯은 1-5 사이여야 합니다")

    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        column_name = f'image_{image_slot}'
        sql = f'''
        UPDATE store_image
        SET {column_name} = NULL
        WHERE store_id = %s
        '''
        curs.execute(sql, (store_id,))
        conn.commit()

        return {
            "status": "success",
            "message": f"매장 {store_id}의 이미지 {image_slot}이 삭제되었습니다"
        }
    except Exception as e:
        if conn:
            conn.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        if conn:
            conn.close()

