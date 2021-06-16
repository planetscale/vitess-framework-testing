#  Django's guide on Model layer
#  https://docs.djangoproject.com/en/3.2/topics/db/models/#model-inheritance

from django.test import TestCase
from testApp.models import (
    CommonInfo,
    Worker,
    Student,
    Post,
    Restaurant,
    Place,
    Chef,
)
from django.core.exceptions import FieldError


class TestModelInheritance(TestCase):
    def setUp(self):
        self.test_worker_1 = Worker.objects.create(name="John", age=45, job="tester")
        self.test_worker_2 = Worker.objects.create(name="Jane", age=40, job="QnA")

        self.test_student_1 = Student.objects.create(
            name="Bobby", age=15, school_class="9A"
        )
        self.test_student_2 = Student.objects.create(
            name="Sunny", age=17, school_class="12B"
        )

    @classmethod
    def setUpTestData(cls):
        cls.restaurant = Restaurant.objects.create(
            name="Central Perk",
            address="123 NYC",
            serves_hot_dogs=True,
            serves_pizza=False,
            rating=2,
        )

        chef = Chef.objects.create(name="Ted")

        cls.another_restaurant = Restaurant.objects.create(
            name="McLarens",
            address="1234 NYC",
            serves_hot_dogs=False,
            serves_pizza=False,
            rating=4,
            chef=chef,
        )

    def test_basic_inheritance(self):
        # this tests that both worker and student class inherited
        # the __str__() of the base class.
        self.assertEqual(str(self.test_worker_1), "Worker John")
        self.assertEqual(str(self.test_student_1), "Student Bobby")

    def test_meta_inheritance_ordering(self):
        # this tests that both worker and student class inherited
        # the ordering from the meta subclasses of parent class
        workers_age_list = Worker.objects.values("age")
        self.assertSequenceEqual(
            workers_age_list,
            [
                {"age": 40},
                {"age": 45},
            ],
        )

    def test_abstract_model_creation(self):
        # abstract base classes can't create model instances of their own
        with self.assertRaisesMessage(
            AttributeError, "'CommonInfo' has no attribute 'objects'"
        ):
            CommonInfo.objects.all()

    def test_model_with_distinct_related_query_name(self):
        self.assertQuerysetEqual(
            Post.objects.filter(testapp_comments__is_spam=True), []
        )

        # The Post model doesn't have a related query accessor based on
        # related_name (testapp_comment_set).
        msg = "Cannot resolve keyword 'testapp_comment_set' into field."
        with self.assertRaisesMessage(FieldError, msg):
            Post.objects.filter(testapp_comment_set__is_spam=True)

    def test_multi_table_inheritance_equality(self):
        # Equality doesn't transfer in multi-table inheritance.
        self.assertNotEqual(Place(id=1), Restaurant(id=1))
        self.assertNotEqual(Restaurant(id=1), Place(id=1))

    def test_multi_table_inheritance_parent_child_one_to_one_link(self):
        # multi-table inheritance relationship introduces links between the child model and
        # each of its parents via an automatically-created OneToOneField
        self.assertEqual(
            Place.objects.get(name="Central Perk").restaurant,
            Restaurant.objects.get(name="Central Perk"),
        )
        self.assertEqual(
            Place.objects.get(name="McLarens").restaurant,
            Restaurant.objects.get(name="McLarens"),
        )
        