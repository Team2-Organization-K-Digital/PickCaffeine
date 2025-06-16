"""
author      : Kim EunJun
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
import base64
# -------------------------------- Property  ---------------------------------------- #
#선언될 ip
ip = "127.0.0.1"
router = APIRouter()


def connect(): 
    conn = pymysql.connect(
        host=ip,
        user='root',
        password='qwer1234',
        db='pick_caffeine',
        charset='utf8'
    )
    return conn



class Menu(BaseModel):
    category_num:int
    menu_name:str
    menu_content:str
    menu_price:int
    menu_image: Optional[str]=None
    menu_state:int

class MenuUpdate(Menu):
    menu_num:int
    


class Option(BaseModel):
    menu_num:int
    option_title:str
    option_name:str
    option_price:int
    option_division:int


class OptionUpdate(Option):
    option_num:int


class Category(BaseModel):
    store_id:str
    category_name:str



class MenuCategoryUpdate(BaseModel):
    originNum:int
    selectNum:int


class SeletedMenu(BaseModel):
    menu_num:int
    selected_options : dict
    total_price:int
    purchase_num:int
    selected_quantity: int


class Purchase(BaseModel):
    purchase_num:int
    user_id:str
    store_id:str
    purchase_date:str
    purchase_request:str
    purchase_state: int


class MyStores(BaseModel):
    user_id:str
    store_id:str
    selected_date:str

# 매장 메뉴 (메뉴 리스트 , 메뉴 추가, 메뉴 수정, 메뉴 삭제, 카테고리 리스트, 카테고리 추가,
#          카테고리 수정, 메뉴 옵션 추가, 메뉴 옵션 삭제, 메뉴 옵션 수정 , 메뉴 옵션 리스트)
# ======================================================
@router.get("/select/menu")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM menu as m, menu_category mc where m.category_num = mc.category_num and mc.store_id = %s group by menu"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()

    return {'results': rows} 
    



@router.get("/selectMax/{storeid}")
async def selectMax(storeid:str):
    conn = connect()
    curs = conn.cursor()
    sql = "select max(menu_num) from menu m, menu_category mc, store s where m.category_num = mc.category_num and mc.store_id = s.store_id and s.store_id=%s"
    curs.execute(sql,(storeid))
    rows = curs.fetchall()
    conn.close()
    result = [{"max":row[0]} for row in rows]
    return {'results':result}

@router.get("/category/{store}")
async def select(store:str):
    conn = connect()
    curs = conn.cursor()
    sql = """SELECT * from menu_category where store_id = %s"""
    curs.execute(sql,(store))
    rows = curs.fetchall()
    conn.close()
    result = [{"category_num":row[0],"store_id":row[1],"category_name":row[2]} for row in rows]
    print(result)
    return {'results':result}


@router.get("/Menu/store={store}")
async def select(store:str):
    conn = connect()
    curs = conn.cursor()
    sql = """SELECT m.menu_num,m.category_num, m.menu_name, m.menu_content, m.menu_price, m.menu_image ,m.menu_state 
                FROM menu as m, menu_category mc 
                where m.category_num = mc.category_num 
                and mc.store_id = %s
                and m.menu_state not in (-1)
                """
    curs.execute(sql,(store,))
    rows = curs.fetchall()
    conn.close()
    result = [{"menu_num":row[0],"category_num":row[1],"menu_name":row[2],"menu_content":row[3],"menu_price":row[4],"menu_image":row[5],"menu_state":row[6]} for row in rows]
    return {'results':result}

@router.get("/selectMenu/{menu_num}")
async def selectMenu(menu_num: int):
    conn = connect()
    curs = conn.cursor()
    sql = "select * from menu where menu_num = %s"
    curs.execute(sql,(menu_num,))
    rows = curs.fetchall()

    conn.close()
    result = [{"menu_num":row[0],"category_num":row[1],"menu_name":row[2],"menu_content":row[3],"menu_price":row[4],"menu_image":row[5],"menu_state":row[6]} for row in rows]
    return {'results':result}

@router.get("/selectOption/{menu_num}")
async def selectMenu(menu_num: int):
    conn = connect()
    curs = conn.cursor()
    sql = "select * from menu_option where menu_num = %s"
    curs.execute(sql,(menu_num,))
    rows = curs.fetchall()
    conn.close()
    results = [{"option_num":row[0],"menu_num":row[1],"option_title":row[2],"option_name":row[3],"option_price":row[4],"option_division":row[5]} for row in rows]

    return {'results':results}


@router.get("/select/categoryNum/{categoryname}/{storeid}")
async def selectCategoryNum(categoryname:str, storeid:str):
    conn = connect()
    curs = conn.cursor()
    sql = "select mc.category_num from menu_category mc, store s where mc.store_id = s.store_id and s.store_id = %s and mc.category_name = %s"
    curs.execute(sql,(storeid,categoryname))
    rows = curs.fetchall()
    conn.close()
    result = [{"num":row[0]} for row in rows]
    return {'results':result}


@router.post("/insert/Menu")
async def insert(menu:Menu):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "insert into menu (category_num,menu_name,menu_content,menu_price,menu_image,menu_state) values (%s,%s,%s,%s,%s,%s)"
        curs.execute(sql, (menu.category_num,menu.menu_name,menu.menu_content,menu.menu_price,menu.menu_image,menu.menu_state))
        conn.commit()
        conn.close()
        
        return {'result':'OK'}
        
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
    
    
@router.post("/insert/menuoptions")
async def insertOption(option:Option):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "insert into menu_option (menu_num,option_title,option_name,option_price,option_division) values(%s,%s,%s,%s,%s)"
        curs.execute(sql, (option.menu_num,option.option_title,option.option_name,option.option_price,option.option_division))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
    


@router.post("/update/menu")
async def updateMenu(menu: MenuUpdate):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "update menu set menu_name=%s,menu_content=%s,menu_price=%s where menu_num=%s"
        curs.execute(sql, (menu.menu_name,menu.menu_content,menu.menu_price,menu.menu_num))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
    
@router.post("/updateAll/menu")
async def updateMenuAll(menu: MenuUpdate):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "update menu set menu_name=%s,menu_content=%s,menu_price=%s,menu_image=%s where menu_num=%s"
        curs.execute(sql, (menu.menu_name,menu.menu_content,menu.menu_price,menu.menu_image,menu.menu_num))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
    
@router.post("/update/menuoptions")
async def updateOption(option:OptionUpdate):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "update menu_option set menu_num=%s, option_title=%s,option_name=%s,option_price=%s,option_division=%s where option_num =%s"
        curs.execute(sql, (option.menu_num,option.option_title,option.option_name,option.option_price,option.option_division,option.option_num))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
    

@router.delete("/delete/optionTitle/{title}")
async def deleteOptionTitle(title:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장

    sql = "delete from menu_option where option_num in (select option_num from (select * from menu_option where option_title = %s) as resulttabe)"
    curs.execute(sql,(title,))
    conn.commit()
    conn.close()
    return {'result':'OK'}


@router.delete("/delete/option/{num}")
async def deleteOption(num:int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장

    sql = "delete from menu_option where option_num = %s"
    curs.execute(sql,(num,))
    conn.commit()
    conn.close()
    return {'result':'OK'}


@router.post("/insert/category")
async def insert(category:Category):
    conn = connect()
    curs = conn.cursor()

    sql = "insert menu_category (store_id,category_name) values (%s,%s)"
    curs.execute(sql,(category.store_id,category.category_name))
    conn.commit()
    conn.close()
        
    return {'result':'OK'}

@router.delete("/delete/category/{num}")
async def deleteCategroy(num:int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장

    sql = "delete from menu_category where category_num = %s"
    curs.execute(sql,(num,))
    conn.commit()
    conn.close()
    return {'result':'OK'}


@router.post("/update/menuCategory")
async def updateMenuCategory(menuCategory:MenuCategoryUpdate):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "update menu set category_num=%s where category_num=%s"
        curs.execute(sql, (menuCategory.selectNum,menuCategory.originNum))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}


@router.post("/update/menuState")
async def updateMenuState(menuCategory:MenuCategoryUpdate):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "update menu set menu_state=%s where menu_num=%s"
        curs.execute(sql, (menuCategory.selectNum,menuCategory.originNum))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}



# 유저 매뉴 구매
# ---------------------------------------------------------------------

@router.get("/select/menus")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM menu"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()

    return {'results': rows} 


@router.get("/select/optioncount/num={num}")
async def select(num:int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = '''SELECT distinct(option_title),option_division
    FROM menu_option mo , menu m 
    where mo.menu_num = m.menu_num
    and mo.menu_num = %s
    '''
    curs.execute(sql,(num))
    rows = curs.fetchall()
    conn.close()


    return {'results': rows}


@router.get("/select/selecmenu")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM selected_menu"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()

    return {'results': rows}

@router.get("/select/selecoptions/selectnum={selectnum}")
async def select(selectnum : int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT selected_options FROM selected_menu where selected_num = %s"
    curs.execute(sql,(selectnum))
    rows = curs.fetchall()
    conn.close()

    return {'results': rows}

@router.post("/insert/selecedMenu")
async def insert(selcet:SeletedMenu):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    
    selected_options_array = [{k: v} for k, v in selcet.selected_options.items() if v]
    selected_options_json = json.dumps(selected_options_array)
    # SQL 문장
    try:
        sql = "insert into selected_menu (menu_num,selected_options,total_price,purchase_num,selected_quantity) values(%s,%s,%s,%s,%s)"
        curs.execute(sql, (selcet.menu_num,selected_options_json,selcet.total_price,selcet.purchase_num,selcet.selected_quantity))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
    

@router.get("/select/shoppingmenu/{purchaseNum}")
async def select(purchaseNum:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM selected_menu where purchase_num = %s"
    curs.execute(sql,(str(purchaseNum),))
    rows = curs.fetchall()
    conn.close()

    return {'results': rows}


@router.post("/update/selectMenu{selected_num}/quantity{selected_quantity}&totalprice{total_price}")
async def updateMenuState(selected_num:int, selected_quantity:int,total_price:int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "update selected_menu set selected_quantity=%s, total_price=%s where selected_num=%s"
        curs.execute(sql, (selected_quantity,total_price, selected_num))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}



@router.delete("/delete/selectedMenu/{num}")
async def delete(num:int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장

    sql = "delete from selected_menu where selected_num = %s"
    curs.execute(sql,(num,))
    conn.commit()
    conn.close()
    return {'result':'OK'}

@router.get("/select/shoppingprice/{purchaseNum}")
async def select(purchaseNum:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT sum(total_price) FROM selected_menu where purchase_num = %s"
    curs.execute(sql,(str(purchaseNum),))
    rows = curs.fetchone()
    conn.close()

    return {'results': rows}

@router.delete("/delete/purchase/{num}")
async def delete(num:int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장

    sql = "delete from selected_menu where purchase_num = %s"
    curs.execute(sql,(num,))
    conn.commit()
    conn.close()
    return {'result':'OK'}


@router.post("/insert/purchase")
async def insert(purchase:Purchase):
    conn = connect()
    curs = conn.cursor()

    sql = "insert purchase_list (purchase_num,user_id,store_id,purchase_date,purchase_request,purchase_state) values (%s,%s,%s,%s,%s,%s)"
    curs.execute(sql,(purchase.purchase_num,purchase.user_id,purchase.store_id,purchase.purchase_date,purchase.purchase_request,purchase.purchase_state))
    conn.commit()
    conn.close()
        
    return {'result':'OK'}





# 매장 info (매장 상세 정보)
# =====================================


@router.get("/select/store/{storeid}")
async def select(storeid : str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * from store where store_id = %s"
    curs.execute(sql,(storeid))
    rows = curs.fetchone()
    conn.close()
    results = [{"store_id":rows[0],"store_password":rows[1],"store_name":rows[2],"store_phone":rows[3],"store_address":rows[4],"store_address_detail":rows[5],"store_latitude":rows[6],"store_longitude":rows[7],"store_content":rows[8],"store_state":rows[9],"store_business_num":rows[10],"store_regular_holiday":rows[11],"store_temporary_holiday":rows[12],"store_business_hour":rows[13],"store_created_date":rows[14]}]
    return {'results': results}



@router.post("/update/store{store_id}/state{store_state}")
async def updateMenuState(store_id: str, store_state:int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장
    try:
        sql = "update store set store_state=%s where store_id=%s"
        curs.execute(sql, (store_state,store_id))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}


# 매장 image 
# =====================================

@router.get("/select/storeImage/{storeId}")
async def select(storeId : str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * from store_image where store_id = %s"
    curs.execute(sql,(storeId,))
    rows = curs.fetchall()
    
    results = []
    for row in rows:
            store_id,image_1,image_2,image_3,image_4,image_5 = row
            # image_1이 있다면 base64로 인코딩
            if image_1:
                store_image_1 = base64.b64encode(image_1).decode('utf-8')
            else:
                store_image_1 = None
            if image_2:
                store_image_2 = base64.b64encode(image_2).decode('utf-8')
            else:
                store_image_2 = None
            if image_3:
                store_image_3 = base64.b64encode(image_3).decode('utf-8')
            else:
                store_image_3 = None
            if image_4:
                store_image_4 = base64.b64encode(image_4).decode('utf-8')
            else:
                store_image_4 = None
            if image_5:
                store_image_5 = base64.b64encode(image_5).decode('utf-8')
            else:
                store_image_5 = None
            
            results.append([store_id,store_image_1,store_image_2,store_image_3,store_image_4,store_image_5])
    conn.close()
    return {'results': results}


# customer 장바구니 번호

@router.get('/select/maxpurchasenum')
async def select():
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "select max(purchase_num) from selected_menu"
    curs.execute(sql)
    rows = curs.fetchone()
    conn.close()
    return {'results': rows}


# 찜 매장 추가, 삭제
# ============================

@router.get("/select/mystores/{user_id}")
async def select(user_id : str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * from my_store where user_id = %s"
    curs.execute(sql,(user_id,))
    rows = curs.fetchall()
    conn.close()
    return {'results': rows}

@router.post("/insert/mystores")
async def insert(mystores:MyStores):
    conn = connect()
    curs = conn.cursor()

    sql = "insert my_store (user_id,store_id,selected_date) values (%s,%s,%s)"
    curs.execute(sql,(mystores.user_id,mystores.store_id,mystores.selected_date))
    conn.commit()
    conn.close()
        
    return {'result':'OK'}


@router.delete("/delete/mystores/{store_id}")
async def delete(store_id:str):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()
    # SQL 문장

    sql = "delete from my_store where store_id = %s"
    curs.execute(sql,(store_id,))
    conn.commit()
    conn.close()
    return {'result':'OK'}



# 카테고리 순서 변경
# =========================================



# @router.post("/update/store{store_id}/state{store_state}")
# async def updateMenuState(store_id: str, store_state:int):
#     # Connection으로 부터 Cursor 생성
#     conn = connect()
#     curs = conn.cursor()
#     # SQL 문장
#     try:
#         sql = """UPDATE menu_category
#                     SET category_name = 
#                     CASE category_num
#                     WHEN 24 THEN 'Dasani'
#                     WHEN 25 THEN 'aaa'
#                     ELSE category_name
#                     END
#                 WHERE category_num IN (24, 25);"""
#         curs.execute(sql, (store_state,store_id))
#         conn.commit()
#         conn.close()
#         return {'result':'OK'}
#     except Exception as ex:
#         conn.close()
#         print("Error :", ex)
#         return {'result':'Error'}
