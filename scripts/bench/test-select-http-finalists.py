#!/usr/bin/env python3
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('selector', Path(__file__).with_name('select-http-finalists.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class SelectionTests(unittest.TestCase):
    def test_mandatory_ties_and_tradeoffs(self):
        def row(score, seconds, size=12, memory=16):
            return {'accuracy': {'coding': score, 'math': score}, 'elapsedSeconds': seconds,
                    'artifactBytes': size, 'peakFootprintBytes': memory}
        rows = {'ours': row(.7, 20), 'baseline': row(.6, 25), 'quality': row(.9, 30),
                'quality-tie': row(.9, 35), 'fast': row(.8, 10), 'dominated': row(.5, 40),
                'small': row(.6, 25, 8), 'unknown': row(.5, 40, memory=None)}
        chosen = module.select(rows, ['ours', 'baseline'])
        self.assertEqual(set(chosen), set(rows) - {'dominated'})
        with self.assertRaisesRegex(ValueError, 'mandatory'):
            module.select(rows, ['absent'])


if __name__ == '__main__':
    unittest.main()
