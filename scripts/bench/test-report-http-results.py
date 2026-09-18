#!/usr/bin/env python3
import importlib.util
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('reporter', Path(__file__).with_name('report-http-results.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class MetricTests(unittest.TestCase):
    def test_paired_results_use_matched_ids_and_preserve_direction(self):
        a = {'a': True, 'b': True, 'c': False, 'd': True}
        b = {'d': True, 'c': True, 'b': False, 'a': False}
        result = module.paired_accuracy(a, b)
        self.assertEqual(result['referenceOnlyCorrect'], 2)
        self.assertEqual(result['competitorOnlyCorrect'], 1)
        self.assertEqual(result['accuracyDifference'], .25)
        self.assertEqual(result, module.paired_accuracy(a, b))
        self.assertEqual(module.paired_accuracy(a, a)['exactMcNemarTwoSidedP'], 1)
        with self.assertRaisesRegex(ValueError, 'identical'):
            module.paired_accuracy(a, {'other': True})

    def test_recovery_is_in_server_lifetime_without_double_counting(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            run = root / 'generations'
            run.mkdir()
            (run / 'manifest.json').write_text('{}')
            launches = root / 'launches'
            launches.mkdir()
            for i, start, ready, end in [(1, 0, 1, 10), (2, 15, 17, 35)]:
                (launches / f'{i}.json').write_text(json.dumps(
                    {'startedUnix': start, 'readyUnix': ready, 'finishedUnix': end}))
            attempt = run / 'attempts/item.result/attempt-1'
            attempt.mkdir(parents=True)
            (attempt / 'item.result.json').write_text(json.dumps({'elapsedSeconds': 3}))
            result = module.campaign_accounting(run)
            self.assertEqual(result['activeServerSeconds'], 30)
            self.assertEqual(result['boundaries'][0]['endpointReadinessSeconds'], 3)
            self.assertEqual(result['boundaries'][0]['knownFailedRequestSeconds'], 3)
            self.assertEqual(result['boundaries'][0]['preservedRecoveryAttempts'], 1)

    def test_cli_verifies_generation_identity(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            run, scores = root / 'run', root / 'scores'
            run.mkdir()
            scores.mkdir()
            (run / 'manifest.json').write_text('{}')
            identity = {'itemsSha256': 'fixed-fixture', 'runManifestSha256': module.sha(run / 'manifest.json'),
                        'generations': {}}
            for i, correct in enumerate([True, False]):
                key = f'fixture/{i}'
                stem = hashlib.sha256(key.encode()).hexdigest()[:20]
                generation = {'id': key, 'suite': 'fixture', 'status': 'completed',
                              'elapsedSeconds': 10, 'usage': {'completion_tokens': 100}}
                path = run / (stem + '.result.json')
                path.write_text(json.dumps(generation))
                identity['generations'][key] = module.sha(path)
                (scores / (stem + '.score.json')).write_text(json.dumps(
                    {'id': key, 'suite': 'fixture', 'scored': True, 'correct': correct}))
            (scores / 'manifest.json').write_text(json.dumps(identity))
            spec_path = root / 'spec.json'
            spec_path.write_text(json.dumps({'candidates': [{'name': 'fixture', 'run': str(run), 'scores': str(scores)}]}))
            command = [sys.executable, str(Path(module.__file__)), '--spec', str(spec_path), '--out', str(root / 'report')]
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads((root / 'report/report.json').read_text())
            self.assertEqual(report['candidates']['fixture']['suites']['fixture']['accuracy'], .5)
            subset_spec = json.loads(spec_path.read_text())
            subset_spec['excludeItemIds'] = ['fixture/1']
            spec_path.write_text(json.dumps(subset_spec))
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            subset = json.loads((root / 'report/report.json').read_text())
            self.assertEqual(subset['candidates']['fixture']['suites']['fixture']['accuracy'], 1)
            self.assertEqual(subset['candidates']['fixture']['suites']['fixture']['items'], 1)
            self.assertEqual(subset['excludedItemIds'], ['fixture/1'])
            self.assertIn('full source runs', subset['scope'])
            generation['elapsedSeconds'] = 1
            path.write_text(json.dumps(generation))
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('Scored generation changed', result.stderr)

    def test_failures_stay_in_denominator_and_missing_stays_missing(self):
        rows = [({'correct': True}, {'elapsedSeconds': 10, 'status': 'completed',
                                     'usage': {'completion_tokens': 100}, 'firstOutputSeconds': 1}),
                ({'correct': False}, {'elapsedSeconds': 20, 'status': 'truncated',
                                      'usage': {}, 'firstOutputSeconds': 3})]
        result = module.summarize(rows)
        self.assertEqual(result['accuracy'], .5)
        self.assertEqual(result['correctPerGenerationHour'], 120)
        self.assertIsNone(result['completionTokens'])
        self.assertIsNone(result['peakProcessTreeFootprintBytes'])
        self.assertIsNone(result['tokensPerWh'])
        self.assertEqual(result['firstOutputSeconds']['p50'], 2)
        low, high = result['accuracyWilson95']
        self.assertAlmostEqual(low, 1 - high)
        self.assertLess(low, .5)
        self.assertGreater(high, .5)
        self.assertEqual(result['statuses']['truncated'], 1)


if __name__ == '__main__':
    unittest.main()
