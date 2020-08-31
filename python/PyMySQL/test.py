import os
import urllib.parse

import pymysql

url = os.environ.get('DATABASE_URL')
if(url is None):
	print("DATABASE_URL must be set")
	exit(1)

parsed = urllib.parse.urlparse(os.environ.get('DATABASE_URL'))
print(parsed)

connection = pymysql.connect(
	host = parsed.hostname,
	port = 3306 if parsed.port == '' else parsed.port,
	user = parsed.username,
	password = parsed.password,
	db = parsed.path.strip('/')
)

try:
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
finally:
	connection.close()

