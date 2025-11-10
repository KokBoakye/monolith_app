from pydantic import BaseModel

class User(BaseModel):
    id: int
    name: str

class Order(BaseModel):
    id: int
    user_id: int
    item: str
