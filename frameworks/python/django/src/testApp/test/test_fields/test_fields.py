#  Django's guide on Model layer fields
#  https://docs.djangoproject.com/en/3.2/topics/db/models/#fields

from django.test import TestCase
from testApp.models import Person, Event, Server
from django.core.files.uploadedfile import SimpleUploadedFile
from pprint import pprint
from model_bakery import baker
from datetime import date, datetime, timedelta, time
from uuid import UUID
from decimal import Decimal


class FieldsTestCase(TestCase):
    @classmethod
    def setUpTestData(cls):
        small_gif = (
            b"\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x00\x00\x00\x21\xf9\x04"
            b"\x01\x0a\x00\x01\x00\x2c\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02"
            b"\x02\x4c\x01\x00\x3b"
        )
        cls.test_image = SimpleUploadedFile(
            "small.gif", small_gif, content_type="image/gif"
        )
        cls.test_event = baker.make("testApp.Event", title="TEST EVENT")
        cls.test_server = baker.make("testApp.Server", name="TEST SERVER")

    def test_event_model(self):
        event_1 = Event.objects.get(title="TEST EVENT")

        # testing big auto field as a primary key
        self.assertEqual(event_1.id, 1)

        # testing website field with default null value
        self.assertIsNone(event_1.website)

        # testing fields with choices
        self.assertIn(event_1.t_size, ("S", "M", "L"))
        event_1.brochure = self.test_image
        print(event_1.id)

        # testing float field with blank = true and a set default value
        self.assertIsNotNone(event_1.rating)
        self.assertEquals(event_1.rating, 5.0)
        self.assertIsInstance(event_1.rating, float)

        # testing date and datetime fields
        self.assertIsNotNone(event_1.start_date_time)
        self.assertIsInstance(event_1.start_date_time, datetime)
        self.assertIsNotNone(event_1.start_date)
        self.assertIsInstance(event_1.start_date, date)

        # testing duration field
        self.assertIsNotNone(event_1.duration)
        self.assertIsInstance(event_1.duration, timedelta)

        # testing email field
        self.assertIsNotNone(event_1.organiser_email)
        self.assertIsInstance(event_1.organiser_email, str)

        # testing slug field
        self.assertIsNotNone(event_1.slug)
        self.assertIsInstance(event_1.slug, str)

        # testing big integer field
        self.assertIsNotNone(event_1.no_of_views)
        self.assertIsInstance(event_1.no_of_views, int)

        # testing integer field
        self.assertIsNotNone(event_1.no_of_attendees)
        self.assertIsInstance(event_1.no_of_attendees, int)

        # testing time field
        self.assertIsNotNone(event_1.start_time)
        self.assertIsInstance(event_1.start_time, time)

        # testing text field
        self.assertIsNotNone(event_1.summary)
        self.assertIsInstance(event_1.summary, str)

        # testing boolean field
        self.assertIsNotNone(event_1.is_accepting_registration)
        self.assertIsInstance(event_1.is_accepting_registration, bool)

        # testing image field
        event_1.banner = self.test_image
        self.assertIsNotNone(event_1.banner)

        # testing file field
        event_1.brochure = self.test_image
        self.assertIsNotNone(event_1.brochure)

    def test_server_model(self):
        test_server = Server.objects.get(name="TEST SERVER")

        # testing UUID Fields
        self.assertIsNotNone(test_server.uuid)
        self.assertIsInstance(test_server.uuid, UUID)

        # testing generic ip field
        self.assertIsNotNone(test_server.ip)
        self.assertIsInstance(test_server.ip, str)

        # testing positive big integer field
        self.assertIsNotNone(test_server.memory_in_mb)
        self.assertIsInstance(test_server.memory_in_mb, int)

        # testing positive small integer field
        self.assertIsNotNone(test_server.no_of_cores)
        self.assertIsInstance(test_server.no_of_cores, int)

        # testing small integer field
        self.assertIsNotNone(test_server.freq_in_ghz)
        self.assertIsInstance(test_server.freq_in_ghz, int)

        # testing positive integer field
        self.assertIsNotNone(test_server.no_of_threads)
        self.assertIsInstance(test_server.no_of_threads, int)

        # testing binary field
        self.assertIsNotNone(test_server.binary_sig)
        self.assertIsInstance(test_server.binary_sig, bytes)

        # testing decimal field
        self.assertIsNotNone(test_server.cache_size)
        self.assertIsInstance(test_server.cache_size, Decimal)
