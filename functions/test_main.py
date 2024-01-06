import unittest
from unittest.mock import Mock, patch
from firebase_functions.https_fn import Request, Response
from main import _update_q_value, _compressed_state, qvalues

class TestMain(unittest.TestCase):

    def test_update_q_value(self):
        q_table = {'state1': {'action1': 0}}
        _update_q_value(q_table, 'state1', 'action1', 'state1', 1, 0.1, 0.9)
        self.assertEqual(q_table['state1']['action1'], 0.1)

    def test_compressed_state(self):
        state_map = {'co2Level': 100, 'renewableDemand': 200, 'renewableSupply': 300}
        result = _compressed_state(state_map)
        self.assertEqual(result, '10_30_20')

if __name__ == '__main__':
    unittest.main()