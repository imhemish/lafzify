from pymongo import MongoClient

from ..settings import settings

import certifi
ca = certifi.where()

# MongoDB setup
client = MongoClient(settings.mongo_url, tlsCAFile=ca)
db = client[settings.mongo_db_name]
