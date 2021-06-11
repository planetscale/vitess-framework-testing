#  Django's guide on Model layer
#  https://docs.djangoproject.com/en/3.2/topics/db/models/#relationships
#  https://docs.djangoproject.com/en/3.2/topics/db/examples/many_to_many/

from django.test import TestCase
from testApp.models import Book, Author
from datetime import date

# testing many_to_many relationship with help of example of a book and author
# how multiple authors can write one book and an author can write multiple books


class TestManyToMany(TestCase):
    
    def setUp(self):
        self.test_book = Book.objects.create(title="TEST BOOK")
        self.test_author_1 = Author.objects.create(first_name="John", last_name="Doe")
        self.test_author_2 = Author.objects.create(first_name="Jane", last_name="Doe")
        self.test_author_3 = Author.objects.create(
            first_name="Jack", last_name="Sparrow"
        )
        # adding multiple authors to a book
        self.test_book.authors.set([self.test_author_1.pk, self.test_author_2.pk])


    def test_many_to_many(self):
        # books can access its authors
        self.assertEqual(self.test_book.authors.count(), 2)

        # authors can access their books
        self.test_author_3.book_set.add(self.test_book)
        self.assertEqual(self.test_book.authors.count(), 3)

    def test_value_error(self):
        #  you can’t associate it with a Author until it’s been saved
        b1 = Book(title='Django made easy')
        try:
            b1.authors.add(self.test_author_1)
        except ValueError:
            pass
    
    def test_type_error(self):
        # adding an object of the wrong type raises TypeError
        b1 = Book.objects.create(title='Django made easy')
        try:
            b1.authors.add(self.test_book)
        except TypeError:
            pass

    def test_create_and_add_new_authors_using_books(self):
        # we can create and add a Publication to an Article in one step using create()
        new_author = self.test_book.authors.create(first_name="Davi", last_name="Jones")
        
        self.assertEqual(Author.objects.all().count(), 4)

    def test_queries(self):
        new_book = Book.objects.create(title="Django made easy - 2")
        new_book.authors.set([ self.test_author_1.pk, self.test_author_2.pk])

        # many-to-many relationships can be queried using lookups across relationships
        book_query_set = Book.objects.filter(authors__pk = self.test_author_1.pk)
        self.assertEqual(len(book_query_set), 2)
        book_query_set = Book.objects.filter(authors = self.test_author_1)
        self.assertEqual(len(book_query_set), 2)

        book_query_set = Book.objects.filter(authors__last_name__startswith = 'Doe')
        self.assertEqual(len(book_query_set), 4)

        book_query_set = Book.objects.filter(authors__last_name__startswith = 'Doe').distinct()
        self.assertEqual(len(book_query_set), 2)
        
        # testing reverse m2m query
        author_query_set = Author.objects.filter(book__pk = self.test_book.pk)
        self.assertEqual(
            author_query_set[0].first_name,
            "John"
        )

        author_query_set = Author.objects.filter(book__in = [self.test_book,new_book]).distinct()
        self.assertEqual(
            len(author_query_set),
            2
        )

    def test_delete_query(self):
        
        # setting up data
        test_book_1 = Book.objects.create(title='Django made easy 1')
        test_author_1 = Author.objects.create(first_name='jesse', last_name='pinkman')
        test_book_1.authors.add(test_author_1)

        test_book_2 = Book.objects.create(title='Django made easy 2')
        test_author_2 = Author.objects.create(first_name='walter', last_name='white')
        test_book_2.authors.add(test_author_2)

        test_book_3 = Book.objects.create(title='Django made easy 3')
        test_book_4 = Book.objects.create(title='Django made easy 4')
        
        # if we delete an author its book wont be able to access it
        test_author_1.delete()
        self.assertEqual(
            len(test_book_1.authors.all()), 
            0
        )

        # if we delete a book its wont be able to access it
        test_book_2.delete()
        self.assertEqual(
            len(test_author_2.book_set.all()),
            0
        )

        # test bulk delete
        Book.objects.filter(title__startswith = 'Django made easy').delete()
        self.assertEqual(
            len(Book.objects.filter(title__startswith = 'Django made easy').distinct().all()),
            0
        )

    def test_removing_related_objects(self):
        # removing author from book
        self.test_book.authors.remove(self.test_author_1)
        self.assertEqual(len(self.test_book.authors.all()), 1)

        # removing book from author
        self.test_author_2.book_set.remove(self.test_book)
        self.assertEqual(len(self.test_author_2.book_set.all()), 0)

    def test_set_clear(self):

        # clearing books of an author
        self.test_author_1.book_set.clear()
        self.assertEqual(len(self.test_author_1.book_set.all()), 0)

        # clearing authors of a book
        self.test_book.authors.clear()
        self.assertEqual(len(self.test_book.authors.all()), 0)
