"""
author      : ChangJun Lee
description : blackmarket_app 과 연동되는 database 를 사용 할 CRUD 기능을 가진 함수 class 
date        : 2025.05.17
version     : 1
"""
# ----------------------------------------------------------------------------------- #
from fastapi import APIRouter
import pymysql
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
        db="mydb",
        charset="utf8"
    )
# ----------------------------------------------------------------------------------- #