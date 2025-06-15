"""
author      : Jeong Seoyun 
description : 고객 / 매장 - 주문 내역과 고객의 찜한 매장 목록  
date        : 2025.06.05
version     : 1
"""
# ----------------------------------------------------------------------------------- #
from fastapi import APIRouter, Form, File, UploadFile
from pydantic import BaseModel
from datetime import datetime
import pymysql
import base64
# -------------------------------- Property  ---------------------------------------- #
#선언될 ip
ip = "127.0.0.1"
router = APIRouter()

# Model
class Order(BaseModel):
    purchase_num: int
    user_id: str
    store_id: str
    purchase_date: str
    purchase_request: str
    purchase_state: str


# MySQL server host
def connect():
    return pymysql.connect(
        host=ip,
        user="root",
        password="qwer1234",
        db="pick_caffeine",
        charset="utf8"
    )
# ----------------------------------------------------------------------------------- #
# 주문내역 - 고객
@router.get("/select/purchase_list/{id}")
async def select_parchase(id:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM purchase_list where user_id = %s ORDER BY purchase_date DESC"
    curs.execute(sql,(id))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows} 

# 주문내역 - 매장
@router.get("/select/purchase_list_store/{id}")
async def select_parchase(id:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM purchase_list where store_id = %s"
    curs.execute(sql,(id))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows} 

# 메장이름, 번호
@router.get("/select/purchase_list/storeinfo/{id}")
async def select_parchase(id:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = '''
    SELECT s.store_name , s.store_phone ,s.store_id
    FROM purchase_list as pl , store as s 
    where pl.user_id = %s 
    and pl.store_id = s.store_id;
    '''
    curs.execute(sql,(id,))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows} 

# 고객 이름, 번호
@router.get("/select/purchase_list/userinfo/{id}")
async def select_parchase(id:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = '''
    SELECT u.user_nickname , u.user_phone 
    FROM purchase_list as pl , users as u 
    where pl.store_id = %s 
    and pl.user_id = u.user_id;
    '''
    curs.execute(sql,(id,))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows} 

# 메뉴이름 / 메뉴 + 옵션가격 / 옵션 내역 - 고객
@router.get("/select/detail_menu/{id}/{num}")
async def select_detail_menu(id:str, num:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = '''SELECT m.menu_name , sm.selected_options , sm.total_price , sm.selected_quantity
    FROM purchase_list AS pl , selected_menu AS sm , menu AS m 
    WHERE pl.user_id = %s AND pl.purchase_num = %s AND pl.purchase_num = sm.purchase_num AND sm.menu_num = m.menu_num;
    '''
    curs.execute(sql,(id, num))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows} 

# 메뉴이름 / 메뉴 + 옵션가격 / 옵션 내역 - 매장
@router.get("/select/detail_menu/store/{id}/{num}")
async def select_detail_menu_store(id:str, num:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = '''SELECT m.menu_name , sm.selected_options , sm.total_price , sm.selected_quantity
    FROM purchase_list AS pl , selected_menu AS sm , menu AS m 
    WHERE pl.store_id = %s 
    AND pl.purchase_num = %s
    AND pl.purchase_num = sm.purchase_num 
    AND sm.menu_num = m.menu_num;
    '''
    curs.execute(sql,(id, num))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows} 

# 메뉴이름 / 총 가격 - 고객
@router.get("/select/menu/{id}")
async def select_menu(id: str):
    conn = connect()
    curs = conn.cursor()

    sql = '''
    SELECT 
        m.menu_name, pl.purchase_num,
        (sm.total_price * sm.selected_quantity) AS menu_total_price,
        SUM(sm.total_price * sm.selected_quantity) OVER (partition by purchase_num) AS purchase_price
    FROM 
        purchase_list AS pl, selected_menu AS sm, menu AS m
    WHERE 
        pl.user_id = %s AND 
        
        pl.purchase_num = sm.purchase_num AND 
        sm.menu_num = m.menu_num;
    '''

    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows}

# 메뉴이름 / 총 가격 - 매장
@router.get("/select/menu/store/{id}")
async def select_menu(id: str):
    conn = connect()
    curs = conn.cursor()

    sql = '''
    SELECT 
        m.menu_name, pl.purchase_num,
        (sm.total_price * sm.selected_quantity) AS menu_total_price,
        SUM(sm.total_price * sm.selected_quantity) OVER (partition by purchase_num) AS purchase_price
    FROM 
        purchase_list AS pl, selected_menu AS sm, menu AS m
    WHERE 
        pl.store_id = %s AND 
        
        pl.purchase_num = sm.purchase_num AND 
        sm.menu_num = m.menu_num;
    '''

    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows}


# 리뷰 유무
@router.get("/select/review/{id}")
async def select_review(id:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = '''SELECT review.purchase_num 
    FROM pick_caffeine.review, pick_caffeine.purchase_list 
    where purchase_list.user_id = %s group by review.purchase_num;
    '''
    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows} 

# 주문 상태 업데이트
@router.post("/update/state/{state}/{num}")
async def update_state(state:int,num:int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "UPDATE purchase_list SET purchase_state=%s WHERE purchase_num=%s;"
        curs.execute(sql, (state, num))
        conn.commit()
        conn.close()
        return {'result':'OK'}  
    except Exception as ex:
            conn.close()
            print("Error :", ex)
            return {'result':'Error'}

# 후기작성
@router.post("/insert/review")
async def insert_review(
    purchase_num: int = Form(...),
    review_text: str = Form(...),
    review_date: str = Form(None), 
    image_data: UploadFile = File(None)
):
    # ✅ 날짜 처리
    if review_date:
        try:
            review_date_parsed = datetime.strptime(review_date, '%Y-%m-%d')
        except ValueError:
            return {'result': 'Error', 'message': 'Invalid date format'}
    else:
        review_date_parsed = datetime.today()  # ✅ 오늘 날짜 자동 입력

    image_bytes = await image_data.read() if image_data else None

    conn = connect()
    curs = conn.cursor()

    try:
        sql = '''
        INSERT INTO review(purchase_num, review_content, review_image, review_date) 
        VALUES (%s, %s, %s, %s);
        '''
        curs.execute(sql, (purchase_num, review_text, image_bytes, review_date_parsed))
        conn.commit()
        return {'result': 'OK'}
    except Exception as ex:
        print("Error:", ex)
        return {'result': 'Error', 'message': str(ex)}
    finally:
        conn.close()


# 찜한 매장 띄우기
@router.get("/select/my_store/{id}")
async def select_mystore(id: str):
    conn = connect()
    curs = conn.cursor()

    sql = '''SELECT 
        s.store_id,
        (SELECT store_name FROM store WHERE store_id = s.store_id) AS store_name,
        (SELECT image_1 FROM store_image WHERE store_id = s.store_id LIMIT 1) AS image_1,
        (SELECT COUNT(*) FROM my_store WHERE store_id = s.store_id) AS store_like_count,
        (SELECT COUNT(*) 
        FROM purchase_list 
        WHERE store_id = s.store_id 
        AND purchase_num IN (SELECT purchase_num FROM review)) AS review_count
    FROM my_store s
    WHERE s.user_id = %s
    ORDER BY s.selected_date DESC;
    '''
    curs.execute(sql, (id,))
    rows = curs.fetchall()
    conn.close()

    results = []
    for row in rows:
        store_id, store_name, image_blob, like_count, review_count = row

        if image_blob:
            image_base64 = base64.b64encode(image_blob).decode('utf-8')
        else:
            image_base64 = None

        results.append({
            "store_id": store_id,
            "store_name": store_name,
            "image_1": image_base64,
            "store_like_count": like_count,
            "review_count": review_count
        })

    return {"results": results}