from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Signal Engine is running"}
