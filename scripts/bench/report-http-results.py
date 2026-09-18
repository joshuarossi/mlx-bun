#!/usr/bin/env python3
"""Build per-suite quality and runtime tables from verified scored generations.

Spec: {"candidates": [{"name": "...", "run": "...", "scores": "..."}]}.
Rates exclude engine startup, recovery attempts and evaluator execution. Backend
prefill/decode rates remain explicitly backend-reported, not portable measures.
"""
import argparse
import hashlib
import json
import math
import random
from pathlib import Path


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def percentile(values, fraction):
    values = sorted(x for x in values if x is not None)
    if not values:
        return None
    position = (len(values) - 1) * fraction
    lower = math.floor(position)
    upper = math.ceil(position)
    return values[lower] + (values[upper] - values[lower]) * (position - lower)


def wilson(correct, count):
    if not count:
        return None
    z = 1.959963984540054
    rate = correct / count
    denominator = 1 + z * z / count
    center = (rate + z * z / (2 * count)) / denominator
    half = z * math.sqrt(rate * (1 - rate) / count + z * z / (4 * count * count)) / denominator
    return [max(0, center - half), min(1, center + half)]


def paired_accuracy(reference, competitor, samples=2000):
    if not reference or set(reference) != set(competitor):
        raise ValueError('Paired comparison requires identical nonempty item IDs')
    differences = [int(reference[key]) - int(competitor[key]) for key in sorted(reference)]
    count = len(differences)
    better, worse = differences.count(1), differences.count(-1)
    discordant = better + worse
    exact_p = min(1.0, 2 * sum(math.comb(discordant, k) for k in range(min(better, worse) + 1)) / 2 ** discordant)
    rng = random.Random(42)
    bootstrap = [sum(rng.choices(differences, k=count)) / count for _ in range(samples)]
    return {'items': count, 'referenceOnlyCorrect': better, 'competitorOnlyCorrect': worse,
            'bothCorrect': sum(reference[key] and competitor[key] for key in reference),
            'accuracyDifference': sum(differences) / count,
            'pairedBootstrap95': [percentile(bootstrap, .025), percentile(bootstrap, .975)],
            'exactMcNemarTwoSidedP': exact_p, 'bootstrapSamples': samples, 'bootstrapSeed': 42,
            'scope': 'reference minus competitor on matched items; resamples tasks, not decoding seeds; pointwise exploratory interval, no multiple-comparison adjustment; zero observed discordance does not prove equivalence'}


def summarize(rows):
    count = len(rows)
    correct = sum(score['correct'] for score, _ in rows)
    elapsed = sum(generation['elapsedSeconds'] for _, generation in rows)
    tokens = [generation.get('usage', {}).get('completion_tokens') for _, generation in rows]
    def values(key):
        return [generation.get(key) for _, generation in rows]
    return {'items': count, 'correct': correct, 'accuracy': correct / count,
            'accuracyWilson95': wilson(correct, count),
            'generationSeconds': elapsed, 'correctPerGenerationHour': correct * 3600 / elapsed if elapsed else None,
            'completionTokens': sum(tokens) if all(x is not None for x in tokens) else None,
            'completionTokensPerEndToEndSecond': sum(tokens) / elapsed if elapsed and all(x is not None for x in tokens) else None,
            'firstOutputSeconds': {p: percentile(values('firstOutputSeconds'), q) for p, q in [('p50', .5), ('p95', .95)]},
            'firstAnswerSeconds': {p: percentile(values('firstAnswerSeconds'), q) for p, q in [('p50', .5), ('p95', .95)]},
            'backendPrefillTokensPerSecondMedian': percentile(values('engineReportedPrefillTokensPerSecond'), .5),
            'backendDecodeTokensPerSecondMedian': percentile(values('engineReportedDecodeTokensPerSecond'), .5),
            'peakProcessTreeRssBytes': max((x for x in values('peakProcessTreeRssBytes') if x is not None), default=None),
            'peakProcessTreeFootprintBytes': max((x for x in values('peakProcessTreeFootprintBytes') if x is not None), default=None),
            'statuses': {status: sum(g['status'] == status for _, g in rows) for status in ['completed', 'truncated', 'error']},
            'powerWh': None, 'tokensPerWh': None, 'energyStatus': 'no validated collector'}


def campaign_accounting(run):
    manifest = json.loads((run / 'manifest.json').read_text())
    sources = [Path(entry['path']) for entry in manifest.get('assembly', {}).get('sources', [])] or [run]
    boundaries = []
    for source in sources:
        launches = []
        for path in sorted((source.parent / 'launches').glob('*.json')):
            launch = json.loads(path.read_text())
            if 'finishedUnix' not in launch:
                raise ValueError('Cannot report a still-active server launch: ' + str(path))
            launches.append({'path': str(path.resolve()), 'sha256': sha(path),
                             'startedUnix': launch['startedUnix'], 'finishedUnix': launch['finishedUnix'],
                             'readyUnix': launch.get('readyUnix'), 'evaluationExitCode': launch.get('evaluationExitCode')})
        attempts = list((source / 'attempts').glob('*/attempt-*'))
        failed_seconds = 0
        missing_elapsed = 0
        for attempt in attempts:
            results = list(attempt.glob('*.result.json'))
            if not results:
                missing_elapsed += 1
            else:
                failed_seconds += sum(json.loads(path.read_text())['elapsedSeconds'] for path in results)
        boundaries.append({'source': str(source.resolve()), 'launches': launches,
            'activeServerSeconds': sum(x['finishedUnix'] - x['startedUnix'] for x in launches) if launches else None,
            'endpointReadinessSeconds': sum(x['readyUnix'] - x['startedUnix'] for x in launches)
                                       if launches and all(x['readyUnix'] is not None for x in launches) else None,
            'preservedRecoveryAttempts': len(attempts), 'knownFailedRequestSeconds': failed_seconds,
            'interruptedAttemptsWithoutElapsedResult': missing_elapsed})
    return {'boundaries': boundaries,
            'activeServerSeconds': sum(x['activeServerSeconds'] for x in boundaries)
                                   if all(x['activeServerSeconds'] is not None for x in boundaries) else None,
            'scope': 'Server lifetime includes startup, requests, recovery launches and shutdown. Endpoint readiness does not establish model-loaded readiness. Gaps between source stages and evaluator execution are excluded. Failed-request time is a component, not an additional amount to add to server lifetime.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--spec', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    spec = json.loads(args.spec.read_text())
    excluded = set(spec.get('excludeItemIds', []))
    report = {'reporterSha256': sha(Path(__file__)), 'candidates': {},
              'scope': 'same-item quality and generation runtime; excludes startup/recovery/scoring; not quiet-machine headline evidence',
              'intervalScope': '95% marginal Wilson intervals; no equivalence or superiority conclusion; no multiple-comparison adjustment'}
    dataset_hash = None
    correctness = {}
    for candidate in spec['candidates']:
        run, scores = Path(candidate['run']), Path(candidate['scores'])
        manifest = json.loads((scores / 'manifest.json').read_text())
        if dataset_hash is None:
            dataset_hash = manifest['itemsSha256']
        if manifest['itemsSha256'] != dataset_hash or manifest['runManifestSha256'] != sha(run / 'manifest.json'):
            raise ValueError('Dataset or scored run identity differs')
        grouped, seen, score_hashes = {}, set(), {}
        for path in scores.glob('*.score.json'):
            score = json.loads(path.read_text())
            key = score['id']
            if key in seen:
                raise ValueError('Duplicate scored item: ' + key)
            seen.add(key)
            score_hashes[key] = sha(path)
            generation_path = run / (hashlib.sha256(key.encode()).hexdigest()[:20] + '.result.json')
            if manifest['generations'].get(key) != sha(generation_path):
                raise ValueError('Scored generation changed: ' + key)
            if not score['scored']:
                continue
            generation = json.loads(generation_path.read_text())
            if generation['suite'] != score['suite']:
                raise ValueError('Scored suite differs from generation: ' + key)
            grouped.setdefault(score['suite'], []).append((score, generation))
        if seen != set(manifest['generations']) or sum(len(rows) for rows in grouped.values()) != len(manifest['generations']):
            raise ValueError('Missing scores or unscored fixtures; use a fully scored suite')
        if not excluded <= seen:
            raise ValueError('Excluded item IDs absent from scored dataset')
        if excluded:
            grouped = {suite: [(s, g) for s, g in rows if s['id'] not in excluded]
                       for suite, rows in grouped.items()}
            if any(not rows for rows in grouped.values()):
                raise ValueError('Exclusions remove an entire suite')
        report['candidates'][candidate['name']] = {'suites': {suite: summarize(rows) for suite, rows in grouped.items()},
            'run': str(run.resolve()), 'scores': str(scores.resolve()), 'scoreManifestSha256': sha(scores / 'manifest.json'),
            'scoreHashes': score_hashes, 'campaignAccounting': campaign_accounting(run)}
        summary_path = scores / 'summary.json'
        if summary_path.exists():
            summary = json.loads(summary_path.read_text())
            if summary['identitySha256'] != sha(scores / 'manifest.json'):
                raise ValueError('Scoring summary identity differs')
            report['candidates'][candidate['name']]['scoringAccounting'] = summary.get('scoringAccounting')
            report['candidates'][candidate['name']]['scoreSummarySha256'] = sha(summary_path)
        correctness[candidate['name']] = {suite: {score['id']: score['correct'] for score, _ in rows}
                                          for suite, rows in grouped.items()}
    reference = spec.get('reference', spec['candidates'][0]['name'])
    if reference not in correctness:
        raise ValueError('Unknown paired reference candidate')
    report['pairedReference'] = reference
    report['pairedComparisons'] = {name: {suite: paired_accuracy(correctness[reference][suite], values)
                                        for suite, values in suites.items()}
                                   for name, suites in correctness.items() if name != reference}
    report['itemsSha256'] = dataset_hash
    report['excludedItemIds'] = sorted(excluded)
    if excluded:
        report['scope'] += '; companion subset excluding disclosed development items; server/scoring totals still cover the full source runs'
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    lines = ['# Same-workload benchmark results', '', report['scope'], '',
             '| Candidate | Suite | Correct/items | Accuracy, 95% interval | Generation seconds | Correct/hour | TTFT p50/p95, seconds |',
             '|---|---|---:|---|---:|---:|---|']
    def number(value):
        return 'unavailable' if value is None else f'{value:.2f}'
    for name, candidate in report['candidates'].items():
        for suite, row in candidate['suites'].items():
            low, high = row['accuracyWilson95']
            lines.append(f"| {name} | {suite} | {row['correct']}/{row['items']} | {row['accuracy']:.1%} [{low:.1%}, {high:.1%}] | {row['generationSeconds']:.1f} | {number(row['correctPerGenerationHour'])} | {number(row['firstOutputSeconds']['p50'])}/{number(row['firstOutputSeconds']['p95'])} |")
    lines.extend(['', 'TTFT means first output chunk, including reasoning. First visible answer latency, backend-reported rates, memory and status counts are in report.json. Missing energy is unavailable, never zero.', '', report['intervalScope'], ''])
    lines.extend(['## Server lifetime by candidate', '',
                  '| Candidate | Active server seconds, including startup/recovery/shutdown | Recorded evaluator seconds |', '|---|---:|---:|'])
    for name, candidate in report['candidates'].items():
        scoring = candidate.get('scoringAccounting') or {}
        lines.append(f"| {name} | {number(candidate['campaignAccounting']['activeServerSeconds'])} | {number(scoring.get('completedInvocationSeconds'))} |")
    lines.extend(['', 'These totals include server startup and all recorded launch attempts. They exclude gaps between stages and offline scoring. Request-only rates above use a different denominator. Raw launch boundaries and recovery accounting are in report.json.', ''])
    lines.extend(['## Paired accuracy differences', '', f'Reference: {reference}. Positive differences favor the reference.', '',
                  '| Competitor | Suite | Difference, percentage points | Paired 95% bootstrap interval |', '|---|---|---:|---|'])
    for name, suites in report['pairedComparisons'].items():
        for suite, row in suites.items():
            low, high = row['pairedBootstrap95']
            lines.append(f"| {name} | {suite} | {100 * row['accuracyDifference']:.2f} | [{100 * low:.2f}, {100 * high:.2f}] |")
    lines.extend(['', 'Intervals resample matched tasks, not decoding seeds, using 2,000 draws and seed 42. They are exploratory, unadjusted for multiple comparisons, and cannot establish equivalence from zero observed differences. Discordant counts and exact McNemar p-values are in report.json.', ''])
    (args.out / 'REPORT.md').write_text('\n'.join(lines))


if __name__ == '__main__':
    main()
