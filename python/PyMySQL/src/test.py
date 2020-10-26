import os
import urllib.parse

import pymysql

args = {}

args['host'] = os.environ.get('VT_HOST')
if(args['host'] is None):
	print('VT_HOST must be set')
	os.Exit(1)

port = os.environ.get('VT_PORT')
if(port is None):
	args['port'] = 3306
else:
	args['port'] = int(port)

args['user'] = os.environ.get('VT_USERNAME')
if(args['user'] is None):
	print('VT_USERNAME must be set')
	os.Exit(2)

password = os.environ.get('VT_PASSWORD')
if(password is not None):
	args['password'] = password

args['db'] = os.environ.get('VT_DATABASE')
if(args['db'] is None):
	print('VT_DATABASE must be set')
	os.Exit(3)

connection = pymysql.connect(**args)

with connection.cursor() as cursor:
	query = 'CREATE TABLE people (id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL)'
	cursor.execute(query)
connection.commit()

with connection.cursor() as cursor:
	query = 'INSERT INTO people VALUES (DEFAULT, %s)'
	cursor.execute(query, ('Vitess User 1',))
	cursor.execute(query, ('Vitess User 2',))
	cursor.execute(query, ('Vitess User 3',))
connection.commit()

with connection.cursor() as cursor:
	query = 'SELECT * FROM people'
	cursor.execute(query)
	assert(cursor.fetchone() == (1, 'Vitess User 1'))
	assert(cursor.fetchone() == (2, 'Vitess User 2'))
	assert(cursor.fetchone() == (3, 'Vitess User 3'))
	assert(cursor.fetchone() is None)

with connection.cursor() as cursor:
	query = 'UPDATE people SET name = %s WHERE id = %s'
	cursor.execute(query, ('NotVitess User', 2))
connection.commit()

with connection.cursor() as cursor:
	query = 'SELECT * FROM people'
	cursor.execute(query)
	assert(cursor.fetchone() == (1, 'Vitess User 1'))
	assert(cursor.fetchone() == (2, 'NotVitess User'))
	assert(cursor.fetchone() == (3, 'Vitess User 3'))
	assert(cursor.fetchone() is None)

with connection.cursor() as cursor:
	query = 'DELETE FROM people WHERE id = %s'
	cursor.execute(query, (2,))
connection.commit()

with connection.cursor() as cursor:
	query = 'SELECT * FROM people'
	cursor.execute(query)
	assert(cursor.fetchone() == (1, 'Vitess User 1'))
	assert(cursor.fetchone() == (3, 'Vitess User 3'))
	assert(cursor.fetchone() is None)

with connection.cursor() as cursor:
	query = 'DROP TABLE people'
	cursor.execute(query)
connection.commit()

