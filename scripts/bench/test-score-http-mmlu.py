#!/usr/bin/env python3
"""Generated MMLU answer extraction and failure-denominator regression checks."""
import importlib.util
import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('score_http', Path(__file__).with_name('score-http.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class MmluScoring(unittest.TestCase):
    def score(self, content, status='completed', reasoning='#### A'):
        return module.score_mmlu({'answer': 'A'}, {'status': status, 'content': content, 'reasoning': reasoning})

    def test_final_answer_and_whitespace(self):
        self.assertTrue(self.score('Explanation\n####\tA \n\n')['correct'])
        self.assertFalse(self.score('#### A\n#### B')['correct'])
        self.assertFalse(self.score('#### A\nFurther text')['correct'])

    def test_reasoning_and_malformed_answers_cannot_pass(self):
        for text in ['', 'A', '#### a', '#### A or B', '```\n#### A\n```', '#### A\u2028extra']:
            with self.subTest(text=text):
                self.assertFalse(self.score(text)['correct'])

    def test_noncompleted_answers_fail_even_with_matching_letter(self):
        for status in ['truncated', 'error']:
            self.assertFalse(self.score('#### A', status=status)['correct'])

    def test_invalid_key_rejected(self):
        with self.assertRaises(ValueError):
            module.score_mmlu({'answer': 'E'}, {'status': 'completed', 'content': '#### E'})

    def test_cli_aggregation_resume_and_identity(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            run, out, items = root / 'run', root / 'scores', root / 'items.jsonl'
            run.mkdir()
            (run / 'manifest.json').write_text('{}')
            rows = [{'id': str(i), 'suite': 'mmlu', 'subject': 'small' if i == 3 else 'large',
                     'answer': 'A'} for i in range(4)]
            items.write_text(''.join(json.dumps(row) + '\n' for row in rows))
            for i, status in enumerate(['completed', 'truncated', 'error', 'completed']):
                (run / f'{i}.result.json').write_text(json.dumps({'id': str(i), 'status': status,
                    'content': '#### A', 'reasoning': '', 'elapsedSeconds': 10,
                    'usage': {'completion_tokens': 5}}))
            argv = ['score-http.py', '--items', str(items), '--run', str(run), '--out', str(out)]
            with patch('sys.argv', argv), patch.object(module.importlib.metadata, 'version', return_value='test'), contextlib.redirect_stdout(io.StringIO()):
                module.main()
                first = json.loads((out / 'summary.json').read_text())['suites']['mmlu']
                self.assertEqual((first['correct'], first['items'], first['accuracy']), (2, 4, .5))
                self.assertAlmostEqual(first['subjectMacroAccuracy'], 2 / 3)
                self.assertEqual(first['subjects']['large']['items'], 3)
                module.main()
                self.assertEqual(first, json.loads((out / 'summary.json').read_text())['suites']['mmlu'])
                path = run / '0.result.json'
                original = path.read_bytes()
                path.write_text(path.read_text().replace('#### A', '#### B'))
                with self.assertRaisesRegex(ValueError, 'identity changed'):
                    module.main()
                path.write_bytes(original)
                (run / '1.result.json').unlink()
                with self.assertRaisesRegex(ValueError, 'Incomplete generation set'):
                    module.main()


if __name__ == '__main__':
    unittest.main()
