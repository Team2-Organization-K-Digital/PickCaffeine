"""
author      :  Gam Seong
description : 
date        : 2025.06.05
version     : 1
"""
# ----------------------------------------------------------------------------------- #
from fastapi import APIRouter
import pymysql
import json
from pydantic import BaseModel
from typing import Optional
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
    store_state:bool
    store_business_num:int
    store_regular_holiday:str
    store_temporary_holiday:str
    store_business_hour:str


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
            False,                      # 상태
            '',                         # 정기휴무
            '',                         # 임시휴무
            '',                         # 영업시간
            
        ))
        conn.commit()
        return {'result' : 'OK'}
    except Exception as ex:
        return {'result':'Error'}
    finally:
        conn.close()
    
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

@router.get("/mystore")
async def mystore():
    try:  
        conn = connect()
        curs = conn.cursor()
        sql = "select user_id,store_id from my_store"
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()
    except Exception as e:
        return {"result": "Error", "detail": str(e)}
    finally:
        conn.close()


