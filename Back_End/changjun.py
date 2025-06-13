"""
author      : ChangJun Lee
description : Pick_Caffeine 앱과 연동되는 mySQL database 에서 
#           : sql 문을 통해 data 를 추출하기 위한 Python sheet
date        : 2025.06.05
version     : 1
"""
# ----------------------------------------------------------------------------------- #
from fastapi import APIRouter, FastAPI, Form
import pymysql
from datetime import datetime 
import base64
# -------------------------------- Property  ---------------------------------------- #
#선언될 ip
ip = "127.0.0.1"
router = APIRouter()

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

# ------------------------------- Functions ----------------------------------------- #

# -------------------------- chart_handler.dart ------------------------------------- #
# 1. 기간 (연도, 월, 일, 시간) 별의 해당 매장 매출을 chart 화 하기 위한 data 를 불러오는 함수
#    연도 : 전체 연도, 월 : 해당 날짜의 연도 전체 월, 일 : 해당 날짜 월의 전체 일, 시간 : 해당 날짜 일의 전체 시간 을 기준으로 불러온다.

@router.get('/select/{chartState}/{store_id}')
async def selectChartData(chartState : str,store_id : str):
# ---------------------------------------------- #
    # 연도, 월, 일 별 chartState 폼
    state_format = {
    "year": "%%Y",
    "month": "%%Y-%%m",
    "day": "%%Y-%%m-%%d",
    "hour": "%%Y-%%m-%%d-%%H"
    }
    selectedState = state_format[chartState]
# ---------------------------------------------- #
# 현재 날짜를 기준으로 chart 로 불러올 data 의 기준을 정하기 위한 변수
    now = datetime.now()
    year = now.year
    month = now.month
    day = now.day

    date_filter = ""
    if chartState == "month":
        date_filter = f"AND YEAR(purchase_date) = {year}"
    elif chartState == "day":
        date_filter = f"AND YEAR(purchase_date) = {year} AND MONTH(purchase_date) = {month}"
    elif chartState == "hour":
        date_filter = f"AND DATE(purchase_date) = '{year}-{str(month).zfill(2)}-{str(day).zfill(2)}'"

# ---------------------------------------------- #
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            f"""
            SELECT DATE_FORMAT(purchase_date, '{selectedState}')AS hourly, SUM(total_price)
            FROM purchase_list, selected_menu
            WHERE purchase_list.purchase_num=selected_menu.purchase_num
            AND purchase_list.store_id = %s
            AND purchase_state = '수령완료'
            {date_filter}
            GROUP BY hourly
            order BY hourly
            """, (store_id,)
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #
# 1-1. 사용자의 전체 연별 총 매출 data 를 연도별로 추출하는 함수
@router.get('/select/year/{store_id}')
async def selectChartYearData(store_id : str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            f"""
            SELECT DATE_FORMAT(purchase_date, '%%Y')AS hourly, SUM(total_price)
            FROM purchase_list, selected_menu
            WHERE purchase_list.purchase_num=selected_menu.purchase_num
            AND purchase_list.store_id = %s
            AND purchase_state = '수령완료'
            GROUP BY hourly
            order BY hourly
            """, (store_id,)
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #
# 1-2. 사용자의 전체 월별 총 매출 data 를 연도별로 추출하는 함수
@router.get('/select/month/{store_id}/{year}')
async def selectChartMonthData(store_id : str, year : str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            f"""
            SELECT DATE_FORMAT(purchase_date, '%%m')AS hourly, SUM(total_price)
            FROM purchase_list, selected_menu
            WHERE purchase_list.purchase_num=selected_menu.purchase_num
            AND purchase_list.store_id = %s
            AND YEAR(purchase_date) = %s
            AND purchase_state = '수령완료'
            GROUP BY hourly
            order BY hourly
            """, (store_id,year)
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #
# 1-3. 사용자의 전체 일별 총 매출 data 를 연도별로 추출하는 함수
@router.get('/select/day/{store_id}/{year}/{month}')
async def selectChartDayData(store_id : str, year : str, month : str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            f"""
            SELECT DATE_FORMAT(purchase_date, '%%d')AS hourly, SUM(total_price)
            FROM purchase_list, selected_menu
            WHERE purchase_list.purchase_num=selected_menu.purchase_num
            AND purchase_list.store_id = %s
            AND YEAR(purchase_date) = %s AND MONTH(purchase_date) = %s
            AND purchase_state = '수령완료'
            GROUP BY hourly
            order BY hourly
            """, (store_id,year,month)
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #
# 1-4. 사용자의 전체 시간 별 총 매출 data 를 시간별로 추출하는 함수
@router.get('/select/day/{store_id}/{year}/{month}/{day}')
async def selectChartDayData(store_id : str, year : str, month : str, day : str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            f"""
            SELECT DATE_FORMAT(purchase_date, '%%H')AS hourly, SUM(total_price)
            FROM purchase_list, selected_menu
            WHERE purchase_list.purchase_num=selected_menu.purchase_num
            AND purchase_list.store_id = %s
            AND DATE(purchase_date) = '{year}-{month}-{day}'
            AND purchase_state = '수령완료'
            GROUP BY hourly
            order BY hourly
            """, (store_id,)
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}

# ----------------------------------------------------------------------------------- #
# 2-1. 매장의 id 와 선택한 연, 월 값을 통해 해당 월에 매장에서 판매 한 각 제품의 제품명, 총 매출액, 판매 수량을 추출하는 함수
@router.get('/selectProduct/month/{store_id}/{year}/{month}')
async def selectProductMonthData(store_id : str, year : str, month : str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            f"""
            SELECT menu_name, SUM(total_price)AS total, Sum(selected_quantity) AS quantity
            FROM purchase_list, selected_menu, menu
            WHERE purchase_list.purchase_num = selected_menu.purchase_num
            AND selected_menu.menu_num = menu.menu_num
            AND purchase_list.store_id = '{store_id}'
            AND YEAR(purchase_date) = {year}
            AND MONTH(purchase_date) = {month}
            AND purchase_state = '수령완료'
            GROUP BY menu_name
            ORDER BY total AND quantity DESC
            """
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #
# 2-2. 매장의 id 와 선택한 연도 값을 통해 해당 연도에 매장에서 판매 한 각 제품의 제품명, 총 매출액, 판매 수량을 추출하는 함수
@router.get('/selectProduct/year/{store_id}/{year}')
async def selectProductMonthData(store_id : str, year : str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            f"""
            SELECT menu_name, SUM(total_price)AS total, Sum(selected_quantity) AS quantity
            FROM purchase_list, selected_menu, menu
            WHERE purchase_list.purchase_num = selected_menu.purchase_num
            AND selected_menu.menu_num = menu.menu_num
            AND purchase_list.store_id = '{store_id}'
            AND YEAR(purchase_date) = {year}
            AND purchase_state = '수령완료'
            GROUP BY menu_name
            ORDER BY total AND quantity DESC
            """
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #
# 2-3. 매장의 id 와 선택한 연, 월, 일 값을 통해 해당 일에 매장에서 판매 한 각 제품의 제품명, 총 매출액, 판매 수량을 추출하는 함수
@router.get('/selectProduct/day/{store_id}/{year}/{month}/{day}')
async def selectProductMonthData(store_id : str, year : str, month : str, day : str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            f"""
            SELECT menu_name, SUM(total_price)AS total, Sum(selected_quantity) AS quantity
            FROM purchase_list, selected_menu, menu
            WHERE purchase_list.purchase_num = selected_menu.purchase_num
            AND selected_menu.menu_num = menu.menu_num
            AND purchase_list.store_id = '{store_id}'
            AND DATE(purchase_date) = '{year}-{month}-{day}'
            AND purchase_state = '수령완료'
            GROUP BY menu_name
            ORDER BY total AND quantity DESC
            """
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #

# 2. 매장 id 와 생성 년도, 월을 통해 각 연도-월 에 해당하는 제품명과 매출을 추출하는 함수
@router.get('/selectProduct/{store_id}/{year}/{month}/{menu_num}')
async def selectProductData(store_id : str, year : str, month : str, menu_num: str = None):
# ---------------------------------------------- #
    try:
        conn = connect()
        curs = conn.cursor()
        if menu_num  in ["", None, " "]:  # 예외적 허용
            query = f"""
                SELECT menu_name, SUM(total_price)
                FROM purchase_list, selected_menu, menu
                WHERE purchase_list.purchase_num = selected_menu.purchase_num
                AND selected_menu.menu_num = menu.menu_num
                AND purchase_list.store_id = '{store_id}'
                AND YEAR(purchase_date) = {year}
                AND MONTH(purchase_date) = {month}
                GROUP BY menu_name
                ORDER BY menu_name
            """
        else:
            query = f"""
                SELECT menu_name, SUM(total_price)
                FROM purchase_list, selected_menu, menu
                WHERE purchase_list.purchase_num = selected_menu.purchase_num
                AND selected_menu.menu_num = menu.menu_num
                AND purchase_list.store_id = '{store_id}'
                AND YEAR(purchase_date) = {year} 
                AND MONTH(purchase_date) = {month}
                AND menu.menu_num = {menu_num}
                GROUP BY menu_name
                ORDER BY menu_name
            """
        curs.execute(query)
        rows = curs.fetchall()
        conn.close()
        results = [{'productName': row[0], 'totalPrice': row[1]}for row in rows]
        return{'results': results}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# -------------------------------------------------------------------------------- #
# 3. 사용자가 가입한 일자의 연도와 월을 추출하는 함수
@router.get('/selectDuration/{store_id}')
async def selectDuration(store_id : str):
# ---------------------------------------------- #
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            """
            SELECT YEAR(store_create_date), Month(store_create_date)
            FROM store
            WHERE store_id = %s
            """, (store_id, )
            )
        rows = curs.fetchall()
        results = [{'year' : row[0], 'month' : row[1]}for row in rows]
        conn.close()
        return{'results': results}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# -------------------------------------------------------------------------------- #
# 4. 사용자가 가입한 연도를 추출하는 함수
@router.get('/selectDuration/year/{store_id}')
async def selectDurationYear(store_id : str):
# ---------------------------------------------- #
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            """
            SELECT YEAR(store_create_date)
            FROM store
            WHERE store_id = %s
            """, (store_id, )
            )
        rows = curs.fetchall()
        results = [{'year' : row[0]}for row in rows]
        conn.close()
        return{'results': results}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# -------------------------------------------------------------------------------- #
# 4. 해당하는 store_id 를 가진 카테고리에 속한 menu 들의 menu_num (PK) 과 menu_name 을 추출하는 함수
@router.get('/selectMenu/{store_id}')
async def selectMenu(store_id : str):
# ---------------------------------------------- #
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            """
            SELECT menu_num,menu_name
            FROM menu as m, menu_category as mc
            WHERE m.category_num = mc.category_num
            AND mc.store_id = %s
            ORDER BY m.menu_name
            """, (store_id, )
            )
        row = curs.fetchall()
        conn.close()
        return{'results': row}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}

# -------------------------------------------------------------------------------- #
# 5. 매장 id 와 생성 년도, 월을 통해 각 연도-월 에 해당하는 제품명과 판매 수량을 추출하는 함수
@router.get('/selectQuantity/{store_id}/{year}/{month}/{menu_num}')
async def selectQuantityData(store_id : str, year : str, month : str, menu_num: str = None):
# ---------------------------------------------- #
    try:
        conn = connect()
        curs = conn.cursor()
        if menu_num  in ["", None, " "]:  # 예외적 허용
            query = f"""
                SELECT menu_name, SUM(selected_quantity)
                FROM purchase_list, selected_menu, menu
                WHERE purchase_list.purchase_num = selected_menu.purchase_num
                AND selected_menu.menu_num = menu.menu_num
                AND purchase_list.store_id = '{store_id}'
                AND YEAR(purchase_date) = {year}
                AND MONTH(purchase_date) = {month}
                GROUP BY menu_name
                ORDER BY menu_name
            """
        else:
            query = f"""
                SELECT menu_name, SUM(selected_quantity)
                FROM purchase_list, selected_menu, menu
                WHERE purchase_list.purchase_num = selected_menu.purchase_num
                AND selected_menu.menu_num = menu.menu_num
                AND purchase_list.store_id = '{store_id}'
                AND YEAR(purchase_date) = {year} 
                AND MONTH(purchase_date) = {month}
                AND menu.menu_num = {menu_num}
                GROUP BY menu_name
                ORDER BY menu_name
            """
        curs.execute(query)
        rows = curs.fetchall()
        conn.close()
        results = [{'productName': row[0], 'totalQuantity': row[1]}for row in rows]
        return{'results': results}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #
# 6. 고객이 처음 로그인 하였을 때 나타날 매장 data 를 추출하는 함수
@router.get('/select/store')
async def selectStore():
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            """
            SELECT 
            s.store_id,
            s.store_name,
            s.store_latitude,
            s.store_longitude,
            COUNT(DISTINCT ms.store_id) AS zzim,
            COUNT(DISTINCT r.review_num) AS review,
            s.store_state,
            si.image_1
            FROM store AS s
            LEFT JOIN my_store AS ms ON s.store_id = ms.store_id
            LEFT JOIN purchase_list AS p ON s.store_id = p.store_id
            LEFT JOIN review AS r ON r.purchase_num = p.purchase_num
            LEFT JOIN store_image AS si ON s.store_id = si.store_id
            GROUP BY s.store_id
            """
            )
        rows = curs.fetchall()
        
        results = []
        for row in rows:
            store_id,store_name,store_latitude,store_longitude,zzim,review,store_state,image_1 = row
            # image_1이 있다면 base64로 인코딩
            if image_1:
                storeimage = base64.b64encode(image_1).decode('utf-8')
            else:
                storeimage = None
            results.append({'store_id':store_id,'store_name':store_name,'store_latitude':store_latitude,'store_longitude':store_longitude,'zzim':zzim,'review':review,'store_state':store_state,'storeimage':storeimage})
        conn.close()
        return{'results': results}
    except Exception as e:
        print("Error :", e)
        return{'result' : 'Error'}
# ----------------------------------------------------------------------------------- #

# -------------------------- account_handler.dart ----------------------------------- #
# 1. 사용자가 입력한 값을 database 에 insert 함 으로써 계정을 생성하는 함수
@router.post("/insertUserAccount")
async def insertUserAccount(
    userid : str=Form(...), nickname : str=Form(...), userPw : str=Form(...),  phone : str=Form(...), 
    userEmail: str=Form(...), userState : str=Form(...), createDate : str=Form(...), gender : str=Form(...)):
        try:
            conn = connect()
            curs = conn.cursor()
            sql = 'INSERT INTO users (user_id, user_nickname, user_password, user_phone, user_email, user_state, user_create_date, user_gender) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)'
            curs.execute(sql, (userid, nickname, userPw, phone, userEmail, userState, createDate, gender))
            conn.commit()
            conn.close()
            return {'result' : 'OK'}
        except Exception as e :
            print("Error : ", e)
            return {"result" : "Error" }
# ----------------------------------------------------------------------------------- #
# 1-1. 사용자가 회원가입을 할 때 아이디의 중복을 확인하기 위해 Database 에 입력한 Id값의 유무를 확인하는 함수
@router.get('/select/userid/doubleCheck/{userid}')
async def selectUseridDoubleCheck(userid : str):
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT count(*) FROM users WHERE user_id =%s", (userid, ))
    rows = curs.fetchall()
    conn.close()
    result = [{'count' : row[0]}for row in rows]
    return {'results' : result}
# ----------------------------------------------------------------------------------- #
# 1-2. 사용자가 회원가입을 할 때 닉네임의 중복을 확인하기 위해 Database 에 입력 nickName값의 유무를 확인하는 함수
@router.get('/select/usernickname/doubleCheck/{usernickname}')
async def selectUsernickNameDoubleCheck(usernickname : str):
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT count(*) FROM users WHERE user_nickname =%s", (usernickname, ))
    rows = curs.fetchall()
    conn.close()
    result = [{'count' : row[0]}for row in rows]
    return {'results' : result}
# ----------------------------------------------------------------------------------- #
# 2. 사용자가 로그인을 진행 할 때 입력한 id 와 pw 값을 users table 에 select 하는 함수
@router.get("/select/loginUser/{userId}/{userPw}")
async def selectUser(userId : str, userPw : str):
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT count(*) FROM users WHERE user_id =%s and user_password =%s", (userId, userPw))
    rows = curs.fetchall()
    conn.close()
    result = [{'count':row[0]} for row in rows]
    return {'results' : result}
# ----------------------------------------------------------------------------------- #
# 3. 사용자가 로그인을 진행 할 때 입력한 id 와 pw 값을 store table 에 select 하는 함수
@router.get("/select/loginStore/{storeId}/{storePw}")
async def selectStore(storeId : str, storePw : str):
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT count(*) FROM store WHERE store_id =%s and store_password =%s", (storeId, storePw))
    rows = curs.fetchall()
    conn.close()
    result = [{'count':row[0]} for row in rows]
    return {'results' : result}
# ----------------------------------------------------------------------------------- #
# 4. 사용자가 로그인을 진행 할 때 입력한 id 와 pw 값을 admin table 에 select 하는 함수
@router.get("/select/loginAdmin/{adminId}/{adminPw}")
async def selectAdmin(adminId : str, adminPw : str):
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT count(*) FROM admin WHERE admin_id =%s and admin_password =%s", (adminId, adminPw))
    rows = curs.fetchall()
    conn.close()
    result = [{'count':row[0]} for row in rows]
    return {'results' : result}
# ----------------------------------------------------------------------------------- #