from django.db import models


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
