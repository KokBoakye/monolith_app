from fastapi import FastAPI
from models import User, Order
from services import UserService, OrderService

app = FastAPI()

@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.post("/users")
def create_user(user: User):
    return UserService.create_user(user)

@app.get("/users")
def list_users():
    return UserService.list_users()

@app.post("/orders")
def create_order(order: Order):
    return OrderService.create_order(order)

@app.get("/orders")
def list_orders():
    return OrderService.list_orders()
