"""
author      :  Gam Seong
description : 
date        : 2025.06.05
version     : 1
"""
# ----------------------------------------------------------------------------------- #
from fastapi import APIRouter, Path
import pymysql
import json
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
# -------------------------------- Property  ---------------------------------------- #
#선언될 ip 권형님 , py 창준님 어드민변경햇음 525
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
# 로그인 할떄 스토어를 하나만드는것. 로그인시 입력하는데이터값만 따로저장. 
# 저장후 아래 업데이트스토어등에서는 기본표시로

class Createstore(BaseModel):
    store_id:str
    store_password:str
    store_name:str
    store_phone:str
    store_business_num:int
    store_address:str
    store_address_detail:str


class StoreHome(BaseModel):
    store_id:str
    store_password:str
    store_name:str
    store_phone:str
    store_address:str
    store_address_detail:str
    store_latitude:float
    store_longitude:float
    store_content:str
    store_state:int
    store_business_num:int
    store_regular_holiday:str
    store_temporary_holiday:str
    store_business_hour:str

# 리뷰 기본 겟 . 리뷰에만 데이터가 잘 들어가는걸 단순히 보는용도
# 
class review_model(BaseModel):
    review_num:int
    purchase_num:int
    review_content:str
    review_date:str
    review_state:str
    review_image:Optional[str] = None

# 내정보에있는 리뷰
class informationreview(BaseModel):
    user_nickname:str
    user_image:Optional[str] = None
    review_num:int
    purchase_num:int
    review_content:str
    review_date:str
    review_state:str
    review_image:Optional[str] = None

# 내정보
class information(BaseModel):
    user_id:str
    user_nickname:str
    user_password:str
    user_phone:str
    user_email:str
    user_state:str
    user_create_date:datetime
    user_image:Optional[str] = None

#업데이트 유저정보
class updateinformation(BaseModel):
    user_id: str #리드온리
    user_nickname: Optional[str] = None
    user_password: Optional[str] = None
    user_phone: Optional[str] = None
    user_email: Optional[str] = None
    user_image: Optional[str] = None

    
# 유저정보들이 들어있는인포
@router.get("/user/information")
async def information():
    conn = connect()
    curs = conn.cursor()
    try:
        sql =   """
                select user_id,user_nickname,user_password,
                user_phone,user_email,user_state,user_create_date,
                user_image
                from users
                """
        curs.execute(sql,)
        rows = curs.fetchall()
        return {"result": "OK", "data": rows}
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()


# 유저 개인정보 내정보화면
@router.get("/user/information/{user_id}")
async def informationuserid(user_id: str):
    conn = connect()
    curs = conn.cursor()
    try:
            sql =   """
            select user_id,user_nickname,user_password,
            user_phone,user_email,user_state,user_create_date,
            user_image
            from users
            where user_id = %s
            """
            curs.execute(sql, (user_id,))
            rows = curs.fetchall()
            return {"result": "OK", "data": rows}
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()
    


# 업데이틍 유저 정보
@router.put("/update/user/information")
async def updateinformation(update: updateinformation):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        UPDATE users SET 
            user_nickname = %s,
            user_password = %s,
            user_phone = %s,
            user_email = %s,
            user_image = %s
        WHERE user_id = %s
        """
        curs.execute(sql, (
            update.user_nickname,
            update.user_password,
            update.user_phone,
            update.user_email,
            update.user_image,
            update.user_id,
        ))
        conn.commit()
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()


# 디비확인용. 
@router.get("selectreview")
async def selectreview():
    conn = connect()
    curs = conn.cursor()
    try:
        sql =   """
                select review_num,purchase_num,review_content,
                review_image,review_date,review_state from review
                
                """
        curs.execute(sql)
        rows = curs.fetchall()
        return {"result": "OK", "data": rows}
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()

@router.get("/user/reviews/{user_id}")
async def userreviews(user_id: str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
            SELECT r.review_num,
                r.review_content,
                r.review_image,
                r.review_date,
                r.review_state,
                p.store_id
            FROM review r
            JOIN purchase_list p ON r.purchase_num = p.purchase_num
            WHERE p.user_id = %s
        """
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        return {"result": "OK", "data": rows}
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()

# 매장 유저 내정보에 올라가는 기본리뷰
# 유저리뷰
@router.get("/users/informationreview")
async def informationreview(user_id: str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql =   """
                select u.user_nickname, u.user_image,
                r.review_num, r.purchase_num, r.review_content,
                r.review_image, r.review_date, r.review_state,
                from review r
                join purchase_list p on r.purchase_num = p.purchase_num
                join users u on p.user_id = u.user_id
                where p.user_id =%s
                order by r.review_date desc
                """
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        return {"result": "OK", "data": rows}
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()

# ** //  새로운스토어만들기 //  **
# 로그인시 나오는데이터를 기본베이스로 만들어서 Text로만표기햇고. 포스나머지 0.0 '' 등은 
# sql문에맞춰서 순서만만든것 . 포스트방식이기때문에 기본 null값으로잡고 페이지를 하나만들어서넣음.
# 빈페이지. 껍데기만있는페이지에 로그인시넣는데이터만들어간상태로 페이지를하나만듬.
@router.post("/createstore")
async def createstore(createstore:Createstore):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "insert into store(store_id,store_password,store_name,store_phone,store_business_num,store_address,store_address_detail,store_latitude, store_longitude, store_content,store_state, store_regular_holiday, store_temporary_holiday, store_business_hour)values(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
        curs.execute(sql, (
            createstore.store_id,
            createstore.store_password,
            createstore.store_name,
            createstore.store_phone,
            createstore.store_business_num,
            createstore.store_address,
            createstore.store_address_detail,
            0.0,                        # 위도 (기본값)
            0.0,                        # 경도 (기본값)
            '',                         # 매장 설명
            -1,                         # 상태
            '',                         # 정기휴무
            '',                         # 임시휴무
            '',                         # 영업시간
            
        ))
        conn.commit()
        return {'result' : 'OK'}
    except Exception as ex:
        print("❗ INSERT 오류:", ex)
        return {'result': 'Error', 'detail': str(ex)}
    finally:
        conn.close()
    
    #매장회원가입할떄 아이디를 Db에있는지 체크하는용도. 중복확인
@router.get("/checkid/{store_id}")
def checkid(store_id: str):
    conn = connect()
    curs = conn.cursor()
    try:
        curs.execute("select * from store where store_id = %s", (store_id,))
        result = curs.fetchone()
        return {"exists": bool(result)}
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()
@router.get('/myinformation/checknickname/{usernickname}')
async def myinformationchecknickname(usernickname : str):
    conn = connect()
    curs = conn.cursor()
    curs.execute(
        "SELECT count(*) FROM users where user_nickname =%s", (usernickname, ))
    rows = curs.fetchall()
    conn.close()
    result = [{'count' : row[0]}for row in rows]
    return {'results' : result}


# **//개인db저장용 // **
# 스토어에 있는정보를 순서대로넣기위해서 만든스토어용
@router.get("/selectstore")
async def selectstore():
    conn = connect()
    curs = conn.cursor()
    sql = "select store_name, store_content, store_business_hour, store_regular_holiday, store_temporary_holiday, store_phone, store_latitude, store_longitude, store_business_num ,store_id, store_state from store"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    result = [
        {   
            "store_name": row[0],
            "store_content": row[1],
            "store_business_hour": row[2],
            "store_regular_holiday": row[3],
            "store_temporary_holiday": row[4],
            "store_phone": row[5],
            "store_latitude": row[6],
            "store_longitude": row[7],
            "store_business_num": row[8],
            "store_id": row[9],
            "store_state": row[10],
        }
        for row in rows
    ]

    return {"results": result}

@router.get("/getstore/{storeId}")
async def selectstore(storeId:str):
    conn = connect()
    curs = conn.cursor()
    sql = "select store_name, store_content, store_business_hour, store_regular_holiday, store_temporary_holiday, store_phone, store_latitude, store_longitude, store_business_num ,store_id, store_state,store_address,store_address_detail,store_phone from store where store_id = %s"
    curs.execute(sql,(storeId))
    rows = curs.fetchall()
    conn.close()
    result = [
        {   
            "store_name": row[0],
            "store_content": row[1],
            "store_business_hour": row[2],
            "store_regular_holiday": row[3],
            "store_temporary_holiday": row[4],
            "store_phone": row[5],
            "store_latitude": row[6],
            "store_longitude": row[7],
            "store_business_num": row[8],
            "store_id": row[9],
            "store_state": row[10],
            "store_address":row[11],
            "store_address_detail":row[12],
            "store_phone":row[13]
        }
        for row in rows
    ]

    return {"results": result}


@router.get("/selectlikestore/{userId}")
async def selectlikestore(userId:str):
    conn = connect()
    curs = conn.cursor()
    sql = "select s.store_name, s.store_content, s.store_business_hour, s.store_regular_holiday, s.store_temporary_holiday, s.store_phone, s.store_latitude, s.store_longitude, s.store_business_num ,s.store_id, s.store_state from store s, my_store ms where s.store_id = ms.store_id and ms.user_id = %s"
    curs.execute(sql,userId)
    rows = curs.fetchall()
    conn.close()
    result = [
        {   
            "store_name": row[0],
            "store_content": row[1],
            "store_business_hour": row[2],
            "store_regular_holiday": row[3],
            "store_temporary_holiday": row[4],
            "store_phone": row[5],
            "store_latitude": row[6],
            "store_longitude": row[7],
            "store_business_num": row[8],
            "store_id": row[9],
            "store_state": row[10],
        }
        for row in rows
    ]

    return {"results": result}


@router.get("/select/likeStore/{userId}")
async def selectstore(userId:str):
    conn = connect()
    curs = conn.cursor()
    sql = "select store_id from my_store where user_id=%s"
    curs.execute(sql,(userId,))
    rows = curs.fetchall()
    results = [{'my_store':row[0]}for row in rows]
    conn.close()
    return {"results": results }



# 스토어 업데이트용. 스토어 아이디 Pk값안에있는 내용들을불러옴.
# 패스워드 네임등 회원가입시만든페이지에 있는 것들은text로 리드온리로표현할것.
@router.post("/updatestore")
async def updatestore(store: StoreHome):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "update store set store_password=%s, store_name=%s, store_phone=%s, store_business_num=%s, store_address=%s, store_address_detail=%s, store_latitude=%s, store_longitude=%s, store_content=%s, store_state=%s, store_regular_holiday=%s, store_temporary_holiday=%s, store_business_hour=%s where store_id=%s"
        curs.execute(sql, (store.store_password, store.store_name, store.store_phone, store.store_business_num, store.store_address, store.store_address_detail, store.store_latitude, store.store_longitude, store.store_content, store.store_state, store.store_regular_holiday, store.store_temporary_holiday, store.store_business_hour, store.store_id))
        conn.commit()
        return {"result": "OK"}
    except Exception as ex:
        return {"result": "Error", "message": str(ex)}
    finally:
        conn.close()

# 찜목록모델설정. 모델설정후 찜한목록이 지도예뜨나 확인용
@router.get("/mystore")
async def mystore():
    try:  
        conn = connect()
        curs = conn.cursor()
        sql = "select u.name AS user_name, s.store_name, m.selected_date from my_store m join users u  m.user_id = u.user_id join store s on m.store_id = s.store_id"
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()

# @router.get("myinforrmation")
# async def myinformation():
#     try:  
#        conn = connect()
#        curs = conn.cursor()
#       sql = "select u.name AS user_name, s.store_name, m.selected_date from my_store m join user u  m.user_id = u.user_id join store s on m.store_id = s.store_id;"
#      curs.execute(sql)
#     rows = curs.fetchall()
#except Exception as e:
#   return {"result": "Error", "detail": str(e)}
    #finally:
#   conn.close()

# # 스토어에서 보는화면.
# @router.get("/store/storeview")
# async def storeview(store_id:str):
#     conn = connect()
#     curs = conn.cursor()
#     try:
#         sql =   """
#                 select user_nickname,user_image,store_id,
#                 review_num,purchase_num,purchase_list.purchase_date,review_content,review_image,review_date,review_state
#                 from review
#                 join user on review.user_id = user.user_id
#                 join purchase_list on review.purchase_num = purchase_list.purchase_num
#                 where review.store_id =%s
#                 """
#         curs.execute(sql, (store_id,))
#         rows = curs.fetchall()
#         return {"result": "OK", "data": rows}
#     except Exception as e:
#         return {"result": "Error", "detail": str(e)}
#     finally:
#         conn.close()

# # 고객 리뷰작성
# @router.post("/store/custumreview")
# async def custumreview(purchase_num: int, user_id: str):
#     try:
#         sql = """
#             select u.user_nickname, u.user_image
#             from purchase_list p
#             join user u on p.user_id = u.user_id
#             where p.purchase_num = %s and p.user_id = %s
#         """
#         curs.execute(sql, (purchase_num, user_id))
#         result = curs.fetchone()
#         return {"result": "OK", "data": result}
#     except Exception as e:
#         return {"result": "Error", "detail": str(e)}



# # 고객이 보는화면
# @router.get("/user/storeview")
# async def storeview(store_id:str):
#     conn = connect()
#     curs = conn.cursor()
#     try:
#         sql =   """
#                 select user_nickname,user_image,store_id,
#                 review_num,purchase_num,review_content,
#                 review_image,review_date,review_state
#                 from review
#                 join user on review.user_id = user.user_id
#                 where review.store_id =%s
#                 """
#         curs.execute(sql, (store_id,))
#         rows = curs.fetchall()
#         return {"result": "OK", "data": rows}
#     except Exception as e:
#         return {"result": "Error", "detail": str(e)}
#     finally:
#         conn.close()

# # 고객과 매장 화면에서 보이는정보. get방식으로 매장에서는 보이게만.
# # 고객화면에서는 보이는것하나. 작성하나. 작성은 post방식을사용함.
# class review_mainview_model(BaseModel):
#     user_nickname:str
#     user_image:Optional[str] = None
#     store_id:str
#     review_num:int
#     purchase_num:int
#     purchase_date:str
#     review_content:str
#     review_date:str
#     review_state:str
#     review_image:Optional[str] = None
