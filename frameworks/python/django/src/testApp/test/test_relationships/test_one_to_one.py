#  Django's guide on Model layer
#  https://docs.djangoproject.com/en/3.2/topics/db/models/#relationships
#  https://docs.djangoproject.com/en/3.2/topics/db/examples/one_to_one/

from django.test import TestCase
from testApp.models import HQAddress,Company
from django.core.exceptions import ObjectDoesNotExist

class TestOneToOne(TestCase):
    @classmethod

    def setUpTestData(cls):
        
        cls.test_hq = HQAddress.objects.create(
            house_no = "1",
            street = "TEST STREET",
            city = "TEST CITY"
        )
        
        cls.test_company = Company.objects.create(
            name = "TEST COMPANY",
            hq_address = cls.test_hq
        )
    
    def  test_one_to_one(self):
        # company can access its hq_address
        self.assertEqual(
            str(self.test_company.hq_address),
            "'1', 'TEST STREET', 'TEST CITY'"
        )
        # a hq_address can access its company
        self.assertEqual(
            str(self.test_hq.company),
            'TEST COMPANY'
        )

    def test_object_does_not_exist(self):
        # if an address doesnot have associated company, 
        # and its is accessed then object_does_not_exist exception is thrown
        hq_add_1 = HQAddress.objects.create(
            house_no = '1',
            street = '2',
            city = 'amsterdam'
        )
        try :
            company = hq_add_1.company
        except ObjectDoesNotExist :
            self.assertFalse(hasattr(hq_add_1, 'company'))
    
    def test_one_to_one_assignment(self):
        hq_add_1 = HQAddress.objects.create(
            house_no = '1',
            street = '2',
            city = 'amsterdam'
        )
        # set the address of a company using assignment notation
        self.test_company.hq_address = hq_add_1
        self.test_company.save()
        self.assertEqual(
            str(self.test_company.hq_address),
            str(hq_add_1)
        )
        # set the company of an address using assignment notation
        self.test_hq.company = self.test_company
        self.test_hq.save()
        self.assertEqual(
            self.test_hq.company,
            self.test_company
        )

    def test_value_error(self):
        hq_add_1 = HQAddress(
            house_no = '1',
            street = '2',
            city = 'amsterdam'
        )
        
        try : 
            self.test_company.hq_address = hq_add_1
            self.test_company.save()
        except ValueError:
            pass

    def test_queries(self):
        # test filter queryset
        company_set = Company.objects.filter(hq_address__street__startswith='TEST')
        self.assertEqual(len(company_set), 1)

        # test reverse query
        test_company = Company.objects.get(hq_address = self.test_hq)
        self.assertEqual(test_company.hq_address, self.test_hq)
