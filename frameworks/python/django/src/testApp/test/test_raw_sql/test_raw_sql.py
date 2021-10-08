# Django's guide on raw sql query
# https://docs.djangoproject.com/en/3.2/topics/db/sql/
from django.test import TestCase
from testApp.models import Person,Author
from django.db import connection, connections
from collections import namedtuple

class TestRawQueryWithManager(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.test_person_1 = Person.objects.create(first_name='John', last_name='Doe')
        cls.test_person_2 = Person.objects.create(first_name='Jane', last_name='Doe')
        cls.test_author_1 = Author.objects.create(first_name='Ted', last_name='Mosby')
    def test_raw_query_with_manager(self):
        raw_query_list = Person.objects.raw('SELECT * FROM testApp_person')
        self.assertEqual(len(raw_query_list), 2)
    def test_raw_query_with_manager_on_another_table(self):
        # we can explicitly map fields of one table on another table's object manager queryset
        # or if the fields are same then django does it implicitly
        raw_query_list = Person.objects.raw(
            'SELECT * FROM testApp_author'
        )
        self.assertEqual(len(raw_query_list), 1)
        self.assertIsInstance(raw_query_list[0], Person)
    def test_raw_query_deferring(self):
        # although only first_name is collected in raw_query
        # django runs internally another query to fetch last_name
        person = Person.objects.raw('SELECT id, first_name FROM testApp_person')[0]
        self.assertEqual(person.last_name, 'Doe')
    def test_passing_query_params(self):
        lname = 'Doe'
        raw_query_list = Person.objects.raw('SELECT * FROM testApp_person WHERE last_name = %s', [lname])
        self.assertEqual(len(raw_query_list), 2)


class TestDirectSQL(TestCase):
    @classmethod
    def setUpTestData(cls):
        test_person_1 = Person.objects.create(first_name='John', last_name='Doe')
        test_person_2 = Person.objects.create(first_name='Jane', last_name='Doe')
        test_author_1 = Author.objects.create(first_name='Ted', last_name='Mosby')
    
    def dictfetchall(cursor):
        # Return all rows from a cursor as a dict
        columns = [col[0] for col in cursor.description]
        return [
            dict(zip(columns, row))
            for row in cursor.fetchall()
        ]
    
    def namedtuplefetchall(cursor):
        # Return all rows from a cursor as a namedtuple
        desc = cursor.description
        nt_result = namedtuple('Result', [col[0] for col in desc])
        return [nt_result(*row) for row in cursor.fetchall()]
    
    def test_simple_raw_query(self):
        
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM testApp_person ") 
            row_tuples = cursor.fetchall()
            self.assertEqual(len(row_tuples),2)

    def test_db_alias(self):

        with connections['default'].cursor() as cursor:
            cursor.execute("SELECT * FROM testApp_person ") 
            row_tuples = cursor.fetchall()
            self.assertEqual(len(row_tuples),2)