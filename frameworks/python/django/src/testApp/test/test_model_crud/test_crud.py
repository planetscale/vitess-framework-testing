# These are testse

from django.test import TestCase
from testApp.models import Person

class CrudTestCase(TestCase):

    def setUp(self):
        self.test_person_1 = Person.objects.create(first_name="John", last_name="Doe")
        self.test_person_2 = Person.objects.create(first_name="Jane", last_name="Doe")

    def test_create(self):
        new_person = Person.objects.create(first_name="Alice", last_name="Foo")
        self.assertEqual(self.test_person_1.id, 1)
        self.assertEqual(self.test_person_2.id, 2)
        self.assertEqual(new_person.id, 3)
        
    def test_read(self):
        persons_in_db = Person.objects.all()
        self.assertEqual(len(persons_in_db),2)
        person_1, person_2 = persons_in_db
        self.assertEqual(person_1.first_name,self.test_person_1.first_name)
        self.assertEqual(person_2.first_name,self.test_person_2.first_name)
    
    def test_update(self):
        test_person_1 = Person.objects.get(id=1)
        test_person_1.first_name = "Johnny"
        test_person_1.save()
        test_person_2 = Person.objects.get(id=1)
        self.assertEqual(test_person_2.first_name,"Johnny")

    def test_delete(self):
        test_person_1 = Person.objects.get(id=1)
        test_person_1.delete()
        try:
            test_person_2 = Person.objects.get(id=1)
        except Person.DoesNotExist:
            pass

