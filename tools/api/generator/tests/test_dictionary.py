"""Tests for apigen.dictionary."""

#pylint: disable=too-many-public-methods,import-error,too-few-public-methods,missing-docstring,unused-variable,multiple-imports
import sys
import unittest


from apigen.dictionary import Dictionary

class TestTictionary(unittest.TestCase):
    def test_unset_mandatory_fields_are_detected(self):
        # test for `date`
        d = Dictionary('lat-deu')
        d['headwords'] = 80
        d['edition'] = '0.1.2'
        self.assertFalse(d.is_complete())

    def test_is_complete_recognizes_all_mandatory_fields(self):
        # test for `date`
        d = Dictionary('lat-deu')
        d['headwords'] = 80
        d['edition'] = '0.1.2'
        d['date'] = '1871-12-13'
        self.assertTrue(d.is_complete())

