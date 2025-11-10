from database import DB
from models import User, Order

class UserService:
    @staticmethod
    def create_user(user: User):
        DB["users"].append(user.dict())
        return user

@staticmethod
def list_users():
    return DB["users"]

class OrderService:
    @staticmethod
    def create_order(order: Order):
        DB["orders"].append(order.dict())
        return order

@staticmethod
def list_orders():
    return DB["orders"]
