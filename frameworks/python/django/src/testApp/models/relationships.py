from django.db import models

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