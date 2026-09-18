#!/usr/bin/env python3
"""Select finalists from completed common-core results using a fixed rule.

Keep named mandatory candidates, all tied leaders in each suite's accuracy,
the fastest complete core run, and non-dominated quality/time/size/memory rows.
This is exploratory selection, not a statistical claim that a leader is better.
"""
import argparse
import hashlib
import json
from pathlib import Path


def select(rows, mandatory):
    reasons = {key: [] for key in rows}
    for key in mandatory:
        if key not in rows:
            raise ValueError('Missing mandatory candidate: ' + key)
        reasons[key].append('predeclared mandatory candidate')
    suites = list(next(iter(rows.values()))['accuracy'])
    for suite in suites:
        best = max(row['accuracy'][suite] for row in rows.values())
        for key, row in rows.items():
            if row['accuracy'][suite] == best:
                reasons[key].append('highest core accuracy, including ties: ' + suite)
    fastest = min(row['elapsedSeconds'] for row in rows.values())
    for key, row in rows.items():
        if row['elapsedSeconds'] == fastest:
            reasons[key].append('lowest core generation elapsed time, including ties')

    def vector(row):
        if row['peakFootprintBytes'] is None:
            return None
        return ([-row['accuracy'][suite] for suite in suites] +
                [row['elapsedSeconds'], row['artifactBytes'], row['peakFootprintBytes']])

    for key, row in rows.items():
        value = vector(row)
        if value is None:
            reasons[key].append('memory unavailable; cannot establish domination')
            continue
        dominated = False
        for other_key, other_row in rows.items():
            other = vector(other_row)
            if other_key == key or other is None:
                continue
            if all(a <= b for a, b in zip(other, value)) and any(a < b for a, b in zip(other, value)):
                dominated = True
                break
        if not dominated:
            reasons[key].append('not dominated across per-suite accuracy, time, artifact bytes and footprint')
    return {key: value for key, value in reasons.items() if value}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['plan', 'items', 'core-root', 'score-root', 'out']:
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--mandatory', nargs='+', required=True)
    args = parser.parse_args()
    plan = json.loads(args.plan.read_text())
    items = [json.loads(line) for line in args.items.read_text().splitlines() if line.strip()]
    expected = {}
    for item in items:
        expected[item['suite']] = expected.get(item['suite'], 0) + 1
    rows, evidence = {}, {}
    for job in plan['jobs']:
        name = job['id'].replace('-screen', '-core')
        run = args.core_root / name
        scores = args.score_root / name
        summary = json.loads((scores / 'summary.json').read_text())
        manifest = json.loads((scores / 'manifest.json').read_text())
        if summary['identitySha256'] != hashlib.sha256((scores / 'manifest.json').read_bytes()).hexdigest():
            raise ValueError('Score summary identity differs: ' + name)
        if manifest['runManifestSha256'] != hashlib.sha256((run / 'manifest.json').read_bytes()).hexdigest():
            raise ValueError('Scored run identity differs: ' + name)
        if manifest['itemsSha256'] != hashlib.sha256(args.items.read_bytes()).hexdigest():
            raise ValueError('Scored dataset differs: ' + name)
        for suite, count in expected.items():
            if summary['suites'][suite]['items'] != count or summary['suites'][suite]['accuracy'] is None:
                raise ValueError('Incomplete or unscored core: ' + name)
        generations = {}
        for path in run.glob('*.result.json'):
            generation = json.loads(path.read_text())
            key = generation['id']
            if key in generations or manifest['generations'].get(key) != hashlib.sha256(path.read_bytes()).hexdigest():
                raise ValueError('Generation differs from scored evidence: ' + key)
            generations[key] = generation
        if set(generations) != {item['id'] for item in items}:
            raise ValueError('Core result IDs differ: ' + name)
        footprints = [row.get('peakProcessTreeFootprintBytes') for row in generations.values()]
        rows[job['id']] = {
            'accuracy': {suite: summary['suites'][suite]['accuracy'] for suite in expected},
            'elapsedSeconds': sum(row['elapsedSeconds'] for row in generations.values()),
            'artifactBytes': sum(artifact['bytes'] for artifact in job['artifacts']),
            'peakFootprintBytes': max(footprints) if all(value is not None for value in footprints) else None}
        evidence[job['id']] = {str(path.resolve()): hashlib.sha256(path.read_bytes()).hexdigest()
                              for path in [scores / 'summary.json', scores / 'manifest.json', run / 'manifest.json']}
    result = {'selectorSha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'mandatory': args.mandatory, 'rows': rows, 'evidence': evidence,
              'selected': select(rows, args.mandatory),
              'scope': 'descriptive core selection before held-out full-suite results; not significance testing'}
    if args.out.exists() and json.loads(args.out.read_text()) != result:
        raise ValueError('Selection changed; preserve existing result and investigate')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result['selected'], indent=2))


if __name__ == '__main__':
    main()
