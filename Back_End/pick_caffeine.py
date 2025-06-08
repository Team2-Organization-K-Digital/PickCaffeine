from fastapi import FastAPI
from changjun import router as changjun_router
from eunjun import router as eunjun_router
from kwonhyoung import router as kwonhyoung_router
from seong import router as seong_router
from seoyun import router as seoyun_router

ip = "127.0.0.1"


app = FastAPI() 
app.include_router(changjun_router,prefix="/changjun",tags=["changjun"])
app.include_router(eunjun_router,prefix="/eunjun",tags=["eunjun"])
app.include_router(kwonhyoung_router,prefix="/kwonhyoung",tags=['kwonhyoung'])
app.include_router(seong_router,prefix="/seong",tags=['seong'])
app.include_router(seoyun_router,prefix="/seoyun",tags=['seoyun'])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app,host=ip,port=8000)