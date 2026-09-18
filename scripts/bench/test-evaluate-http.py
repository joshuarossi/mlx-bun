"""Model-free checks for benchmark stream accounting and failure preservation."""
import importlib.util
import fcntl
import json
import os
from pathlib import Path
import tempfile
import subprocess
import sys
import threading
import unittest
from unittest.mock import patch
from http.server import BaseHTTPRequestHandler, HTTPServer

spec = importlib.util.spec_from_file_location('evaluate_http', Path(__file__).with_name('evaluate-http.py'))
bench = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bench)


class Handler(BaseHTTPRequestHandler):
    chunks = []

    def do_POST(self):
        body = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        self.server.received = body
        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream')
        self.end_headers()
        for value in self.chunks:
            self.wfile.write(('data: ' + (value if isinstance(value, str) else json.dumps(value)) + '\n\n').encode())
            self.wfile.flush()

    def log_message(self, *_args):
        pass


class MeasurementTests(unittest.TestCase):
    def run_stream(self, chunks):
        Handler.chunks = chunks
        server = HTTPServer(('127.0.0.1', 0), Handler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            with tempfile.TemporaryDirectory() as tmp:
                out = Path(tmp) / 'item.result.json'
                result = bench.generate({'baseUrl': f'http://127.0.0.1:{server.server_port}/v1',
                                         'request': {'model': 'fixture', 'max_tokens': 20}, 'timeoutSeconds': 5},
                                        {'id': 'gsm8k/test', 'suite': 'gsm8k', 'answer': '42',
                                         'messages': [{'role': 'user', 'content': 'fixture'}]}, out, os.getpid())
                self.assertEqual(json.loads(out.read_text()), result)
                self.assertTrue(out.with_suffix('.sse').exists())
                self.assertTrue(server.received['stream_options']['include_usage'])
                return result
        finally:
            server.shutdown()
            server.server_close()
            thread.join()

    def test_reasoning_role_usage_and_answer_are_distinct(self):
        result = self.run_stream([
            {'choices': [{'delta': {'role': 'assistant'}}]},
            {'choices': [{'delta': {'reasoning_content': 'Work it out'}}]},
            {'choices': [{'delta': {'content': '#### 42'}}]},
            {'choices': [{'delta': {}, 'finish_reason': 'stop'}]},
            {'choices': [], 'usage': {'prompt_tokens': 8, 'completion_tokens': 12}}, '[DONE]'])
        self.assertEqual(result['status'], 'completed')
        self.assertEqual(result['reasoning'], 'Work it out')
        self.assertEqual(result['content'], '#### 42')
        self.assertTrue(result['score']['correct'])
        self.assertLessEqual(result['firstOutputSeconds'], result['firstAnswerSeconds'])
        self.assertEqual(result['usage']['completion_tokens'], 12)
        self.assertIsNone(result['decodeTokensPerSecond'])

    def test_truncated_stream_is_not_a_success(self):
        result = self.run_stream([{'choices': [{'delta': {'content': '#### 42'}}]}])
        self.assertEqual(result['status'], 'error')
        self.assertNotIn('score', result)
        self.assertEqual(result['content'], '#### 42')

    def test_length_finish_is_not_scored_as_completed(self):
        result = self.run_stream([{'choices': [{'delta': {'content': '#### 42'}, 'finish_reason': 'length'}]}, '[DONE]'])
        self.assertEqual(result['status'], 'truncated')
        self.assertNotIn('score', result)

    def test_sse_framing(self):
        self.assertEqual(list(bench.events([b': comment\n', b'data: first\r\n', b'data: second\n', b'\n', b'data: final'])),
                         ['first\nsecond', 'final'])

    def test_gsm_protocol_requires_explicit_final_answer(self):
        self.assertFalse(bench.gsm_score('The question contains 42', '42')['correct'])
        self.assertTrue(bench.gsm_score('#### 1,200.0', '1200')['correct'])

    def test_completed_wrong_answer_is_never_retried(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / 'item.result.json'
            previous = {'id': 'item', 'status': 'completed', 'score': {'correct': False}}
            bench.atomic_json(out, previous)
            with patch.object(bench, 'generate') as generate:
                self.assertEqual(bench.run_item({}, {'id': 'item'}, out, 1, True), previous)
                generate.assert_not_called()

    def test_recovery_preserves_original_and_is_limited_to_one(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / 'item.result.json'
            previous = {'id': 'item', 'status': 'error', 'content': 'partial'}
            bench.atomic_json(out, previous)
            out.with_suffix('.sse').write_text('original wire bytes')
            with patch.object(bench, 'generate', return_value={'id': 'item', 'status': 'error'}) as generate:
                self.assertEqual(bench.run_item({}, {'id': 'item'}, out, 1), previous)
                generate.assert_not_called()
                bench.run_item({}, {'id': 'item'}, out, 1, True)
                generate.assert_called_once()
            history = out.parent / 'attempts' / out.stem / 'attempt-1'
            self.assertEqual(json.loads((history / out.name).read_text()), previous)
            self.assertEqual((history / out.with_suffix('.sse').name).read_text(), 'original wire bytes')
            bench.atomic_json(out, previous)
            with self.assertRaisesRegex(RuntimeError, 'already used'):
                bench.run_item({}, {'id': 'item'}, out, 1, True)

    def test_interrupted_wire_is_preserved_before_resuming(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / 'item.result.json'
            out.with_suffix('.sse').write_text('interrupted')
            with patch.object(bench, 'generate'):
                bench.run_item({}, {'id': 'item'}, out, 1)
            history = out.parent / 'attempts' / out.stem / 'attempt-1'
            self.assertEqual((history / out.with_suffix('.sse').name).read_text(), 'interrupted')

    def test_resume_identity_and_exclusive_writer(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config, items, out = root / 'config.json', root / 'items.jsonl', root / 'out'
            config.write_text('{"request": {"seed": 42}}')
            items.write_text('')
            command = [sys.executable, str(Path(bench.__file__).resolve()), '--config', str(config),
                       '--items', str(items), '--out', str(out), '--pid', str(os.getpid())]
            def run():
                return subprocess.run(command, capture_output=True, text=True, timeout=10)
            self.assertEqual(run().returncode, 0)
            manifest = (out / 'manifest.json').read_bytes()
            self.assertEqual(run().returncode, 0)
            self.assertEqual((out / 'manifest.json').read_bytes(), manifest)
            config.write_text('{"request": {"seed": 43}}')
            rejected = run()
            self.assertNotEqual(rejected.returncode, 0)
            self.assertIn('Refusing resume', rejected.stderr)
            self.assertEqual((out / 'manifest.json').read_bytes(), manifest)
            config.write_text('{"request": {"seed": 42}}')
            with (out / '.runner.lock').open('a') as lock:
                fcntl.flock(lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
                self.assertNotEqual(run().returncode, 0)
            self.assertEqual(run().returncode, 0)


if __name__ == '__main__':
    unittest.main()
