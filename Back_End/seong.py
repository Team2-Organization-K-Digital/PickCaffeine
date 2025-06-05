"""
author      : Jung SeoYun
description : 
date        : 2025.06.05
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