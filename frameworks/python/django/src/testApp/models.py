from django.db import models

class Person(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)

    def __str__(self):
        return self.first_name

class Event(models.Model):
    id = models.BigAutoField(primary_key=True)

    title = models.CharField(max_length=150)
    start_date = models.DateField()
    start_date_time = models.DateTimeField()
    duration = models.DurationField()
    organiser_email = models.EmailField()
    banner = models.ImageField()
    slug = models.SlugField()
    no_of_attendees = models.IntegerField()
    no_of_views = models.BigIntegerField()
    website = models.URLField(null=True)
    start_time = models.TimeField()
    summary = models.TextField()
    brochure = models.FileField()
    rating = models.FloatField(blank=True, default="5.0")
    is_accepting_registration = models.BooleanField()
    SHIRT_SIZES = (
        ("S", "Small"),
        ("M", "Medium"),
        ("L", "Large"),
    )
    t_size = models.CharField(max_length=20, choices=SHIRT_SIZES)

    def __str__(self):
        return self.title


class Server(models.Model):
    uuid = models.UUIDField()
    ip = models.GenericIPAddressField()
    memory_in_mb = models.PositiveBigIntegerField()
    no_of_cores = models.PositiveSmallIntegerField()
    freq_in_ghz = models.SmallIntegerField()
    no_of_threads = models.PositiveIntegerField()
    binary_sig = models.BinaryField()
    cache_size = models.DecimalField(max_digits=25, decimal_places=10)
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

#  https://docs.djangoproject.com/en/3.2/topics/db/models/#model-inheritance

class CommonInfo(models.Model):
    name = models.CharField(max_length=50)
    age = models.PositiveIntegerField()

    class Meta:
        abstract = True
        ordering = ["age"]

    def __str__(self):
        return "%s %s" % (self.__class__.__name__, self.name)


class Worker(CommonInfo):
    job = models.CharField(max_length=50)


class Unmanaged(models.Model):
    guardian = models.CharField(max_length=100)

    class Meta:
        abstract = True
        ordering = ["guardian"]
        managed = False


class Student(CommonInfo):
    school_class = models.CharField(max_length=10)

    class Meta(CommonInfo.Meta):
        pass


# Abstract base classes with related models


class Post(models.Model):
    title = models.CharField(max_length=50)


class Attachment(models.Model):
    post = models.ForeignKey(
        Post,
        models.CASCADE,
        
        related_name="%(app_label)s_%(class)s_related",
        related_query_name="%(app_label)s_%(class)ss"
    )
    content = models.TextField()

    class Meta:
        abstract = True


class Comment(Attachment):
    is_spam = models.BooleanField(default=False)


class Link(Attachment):
    url = models.URLField()


# multi-table inheritance


class Chef(models.Model):
    name = models.CharField(max_length=50)


class Place(models.Model):
    name = models.CharField(max_length=50)
    address = models.CharField(max_length=80)


class Rating(models.Model):
    rating = models.IntegerField(null=True, blank=True)

    class Meta:
        abstract = True
        ordering = ["-rating"]


class Restaurant(Place, Rating):
    serves_hot_dogs = models.BooleanField(default=False)
    serves_pizza = models.BooleanField(default=False)
    chef = models.ForeignKey(Chef, models.SET_NULL, null=True, blank=True)

    class Meta(Rating.Meta):
        db_table = "my_restaurant"
=======
class HQAddress(models.Model):
    house_no = models.CharField(max_length=100)
    street = models.CharField(max_length=100)
    city = models.CharField(max_length=100)

    def __str__(self):
        return "'%s', '%s', '%s'" % (self.house_no, self.street, self.city)


class Company(models.Model):
    name = models.CharField(max_length=100)
    hq_address = models.OneToOneField(HQAddress, on_delete=models.CASCADE)

    def __str__(self):
        return self.name


class Reporter(models.Model):
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    email = models.EmailField()

    def __str__(self):
        return "%s %s" % (self.first_name, self.last_name)


class Article(models.Model):
    headline = models.CharField(max_length=100)
    pub_date = models.DateField()
    reporter = models.ForeignKey(Reporter, on_delete=models.CASCADE)

    def __str__(self):
        return self.headline


class Author(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)


class Book(models.Model):
    title = models.CharField(max_length=100)
    authors = models.ManyToManyField(to=Author)