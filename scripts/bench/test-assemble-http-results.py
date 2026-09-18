#!/usr/bin/env python3
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('assemble', Path(__file__).with_name('assemble-http-results.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class AssemblyTests(unittest.TestCase):
    def test_disjoint_reuse_and_identity_rejections(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            items = [{'id': str(i), 'suite': 'gsm8k', 'messages': [{'role': 'user', 'content': str(i)}]}
                     for i in range(2)]
            dataset = root / 'items.jsonl'
            dataset.write_text('\n'.join(map(json.dumps, items)))
            sources = [root / 'screen', root / 'core']
            runner = b'# frozen runner\n'
            config = {'request': {'temperature': 0.6}, 'engine': 'fixture'}
            for source, item in zip(sources, items):
                source.mkdir()
                (source / 'runner.py').write_bytes(runner)
                (source / 'manifest.json').write_text(json.dumps({'schema': 1, 'config': config,
                    'runnerSha256': hashlib.sha256(runner).hexdigest(), 'itemsSha256': item['id']}))
                (source / (item['id'] + '.result.json')).write_text(json.dumps(dict(item,
                    status='completed', elapsedSeconds=10, content='original answer')))
                request = dict(config['request'], messages=item['messages'], stream=True,
                               stream_options={'include_usage': True})
                (source / (item['id'] + '.result.request.json')).write_text(json.dumps(request))
            out = root / 'assembled'
            self.assertEqual(module.assemble(dataset, sources, out), 2)
            self.assertEqual(module.assemble(dataset, sources, out), 2)
            self.assertEqual(len(list(out.glob('*.result.json'))), 2)
            with self.assertRaisesRegex(ValueError, 'Missing'):
                module.assemble(dataset, sources[:1], root / 'missing')
            with self.assertRaisesRegex(ValueError, 'Overlapping'):
                module.assemble(dataset, sources + sources[:1], root / 'duplicate')
            request_file = sources[1] / '1.result.request.json'
            original = request_file.read_text()
            request = json.loads(original)
            request['messages'][0]['content'] = 'different prompt'
            request_file.write_text(json.dumps(request))
            with self.assertRaisesRegex(ValueError, 'Request'):
                module.assemble(dataset, sources, root / 'prompt-change')
            request_file.write_text(original)
            manifest_path = sources[1] / 'manifest.json'
            manifest = json.loads(manifest_path.read_text())
            manifest['config']['request']['temperature'] = 0.9
            manifest_path.write_text(json.dumps(manifest))
            with self.assertRaisesRegex(ValueError, 'configuration'):
                module.assemble(dataset, sources, root / 'config-change')


if __name__ == '__main__':
    unittest.main()
