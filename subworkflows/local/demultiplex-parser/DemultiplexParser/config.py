from os import environ
class FlaskConfig:
    DEBUG = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_DATABASE_URI = environ.get('SQL_DBB_MAIN', 'postgresql://postgres:gon@localhost:5433/template_dbb')
    SQLALCHEMY_BINDS = {
        'secondary': environ.get('SQL_DBB_SECONDARY', 'postgresql://postgres:gon@localhost:5433/secondary')
    }

class Config:
    MONGODB_SETTINGS = {
            "db" : environ.get('NoSQL_DBB_MAIN', 'template_db'),
            "host" : environ.get('MONGO_HOST', 'localhost'),
            "port" : environ.get('MONGO_PUERTO', 27017)
        }
    ELASTIC_SETTINGS = {
        'host' : environ.get('ELASTIC_HOST', 'localhost'),
        'port' : environ.get('ELASTIC_PORT', 9200),
        #If credentals 'users' :  os.environ.get('ELASTIC_USER', 'user'),
        #If credentals 'password' :  os.environ.get('ELASTIC_PASSWORD', 'password'),
    }
