#  Django's guide on Model layer
#  https://docs.djangoproject.com/en/3.2/topics/db/models/#relationships
#  https://docs.djangoproject.com/en/3.2/topics/db/examples/one_to_one/

from django.test import TestCase
from testApp.models import HQAddress, Company


class TestOneToOne(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.test_hq = HQAddress.objects.create(
            house_no="1", street="TEST STREET", city="TEST CITY"
        )
        cls.test_company = Company.objects.create(
            name="TEST COMPANY", hq_address=cls.test_hq
        )

    def test_one_to_one(self):
        # company can have an unique hqaddress
        self.assertEqual(str(self.test_company.hq_address), "1 ,TEST STREET ,TEST CITY")
        # hq_address can have a unique company
        self.assertEqual(self.test_hq.company.name, "TEST COMPANY")
