'''
Functions:
  - connect_to_mysql(): connect_to_mysql is used to connect to mysql
  - select_mysql(<query>): select_mysql is used to run a select statement in mysql and return its result
  - dml_mysql(<query>): dml_mysql is used to run a insert, delete or update statement in mysql

  Functions implemented by @GuptaManan10 (Manan Gupta)
'''

import mysql.connector
from mysql.connector import Error

# connect_to_mysql is used to connect to mysql
def connect_to_mysql():
    try:
        conn = mysql.connector.connect( host=os.environ['VT_HOST'],
                                        database=os.environ['VT_DATABASE'],
                                        user=os.environ['VT_USERNAME'],
                                        password=os.environ['VT_PASSWORD'],
                                        port=os.environ['VT_PORT'])
        if conn.is_connected():
            return conn
    except Error as e:
        sys.exit(e)

# select_mysql is used to run a select statement in mysql and return its result
def select_mysql(query):
    try:
        conn = connect_to_mysql()
        cursor = conn.cursor()
        cursor.execute(query)
        rows = cursor.fetchall()
        return rows
    except Error as e:
        sys.exit(e)
    finally:
        cursor.close()
        conn.close()

# dml_mysql is used to run a insert, delete or update statement in mysql
def dml_mysql(query):
    try:
        conn = connect_to_mysql()
        cursor = conn.cursor()
        cursor.execute(query)
        conn.commit()
    except Error as e:
        sys.exit(e)
    finally:
        cursor.close()
        conn.close()
