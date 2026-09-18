#!/usr/bin/env python3
"""Assemble disjoint benchmark stages without generating or counting an item twice.

Sources must have identical engine configuration and runner identity. The output
is a scoring view, not evidence of one uninterrupted timing run. Raw artifacts
and recovery attempts remain in the source directories.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def assemble(items_path, sources, out):
    items = [json.loads(line) for line in items_path.read_text().splitlines() if line.strip()]
    wanted = {item['id']: item for item in items}
    if len(wanted) != len(items):
        raise ValueError('Duplicate item ID in requested dataset')
    manifests = [json.loads((source / 'manifest.json').read_text()) for source in sources]
    reference = {key: manifests[0][key] for key in ['config', 'runnerSha256', 'schema']}
    for manifest in manifests:
        if any(manifest[key] != value for key, value in reference.items()):
            raise ValueError('Source execution configuration or runner differs')
    selected = {}
    for source in sources:
        if sha(source / 'runner.py') != reference['runnerSha256']:
            raise ValueError('Source runner snapshot changed')
        for path in source.glob('*.result.json'):
            result = json.loads(path.read_text())
            key = result['id']
            if key not in wanted:
                continue
            if key in selected:
                raise ValueError('Overlapping result ID: ' + key)
            item = wanted[key]
            request_path = path.with_suffix('.request.json')
            expected = dict(reference['config']['request'], messages=item['messages'],
                            stream=True, stream_options={'include_usage': True})
            if json.loads(request_path.read_text()) != expected or result['suite'] != item['suite']:
                raise ValueError('Request or suite differs for ' + key)
            selected[key] = path
    missing = wanted.keys() - selected.keys()
    if missing:
        raise ValueError(f'Missing {len(missing)} required results')
    identity = dict(reference, itemsSha256=sha(items_path), assembly={
        'scriptSha256': sha(Path(__file__)),
        'scope': 'disjoint recorded requests; separate source cold starts and recovery boundaries',
        'sources': [{'path': str(source.resolve()), 'manifestSha256': sha(source / 'manifest.json')}
                    for source in sources],
        'results': {key: {'path': str(path.resolve()), 'sha256': sha(path),
                         'requestSha256': sha(path.with_suffix('.request.json'))}
                    for key, path in selected.items()}})
    manifest_path = out / 'manifest.json'
    if manifest_path.exists() and json.loads(manifest_path.read_text()) != identity:
        raise ValueError('Assembly identity changed; use a new output directory')
    out.mkdir(parents=True, exist_ok=True)
    for key, path in selected.items():
        target = out / path.name
        if target.exists() and sha(target) != sha(path):
            raise ValueError('Assembled result changed: ' + key)
        if not target.exists():
            shutil.copyfile(path, target)
    temporary = out / 'manifest.tmp'
    temporary.write_text(json.dumps(identity, indent=2) + '\n')
    temporary.replace(manifest_path)
    return len(selected)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--items', type=Path, required=True)
    parser.add_argument('--runs', type=Path, nargs='+', required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    print(f'Assembled {assemble(args.items, args.runs, args.out)} recorded requests')
