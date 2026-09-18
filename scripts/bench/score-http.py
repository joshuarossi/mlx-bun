#!/usr/bin/env python3
"""Score frozen HTTP generations with pinned EvalPlus and lm-eval IFEval.

Run coding evaluation under OS isolation. This script does not provide a sandbox.
Incomplete or truncated generations count as failures, never silent omissions.
"""
import argparse
import hashlib
import importlib.metadata
import json
import random
import re
from pathlib import Path
import time


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    tmp = path.with_suffix('.tmp')
    tmp.write_text(json.dumps(value, indent=2) + '\n')
    tmp.replace(path)


def score_mmlu(item, generation):
    """Declared generated-answer protocol; reasoning is never an answer source."""
    if item['answer'] not in ('A', 'B', 'C', 'D'):
        raise ValueError('Invalid MMLU answer key')
    lines = [line for line in generation.get('content', '').split('\n') if line.strip()]
    match = re.fullmatch(r'####[ \t]*([ABCD])[ \t]*', lines[-1]) if lines else None
    predicted = match.group(1) if match else None
    return {'predicted': predicted, 'expected': item['answer'],
            'correct': generation['status'] == 'completed' and predicted == item['answer']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--items', type=Path, required=True)
    parser.add_argument('--run', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    items = [json.loads(s) for s in args.items.read_text().splitlines() if s.strip()]
    generations = {json.loads(p.read_text())['id']: p for p in args.run.glob('*.result.json')}
    missing = [x['id'] for x in items if x['id'] not in generations]
    if missing:
        raise ValueError(f'Incomplete generation set: {len(missing)} items missing')
    args.out.mkdir(parents=True, exist_ok=True)
    identity = {'itemsSha256': sha(args.items), 'runManifestSha256': sha(args.run / 'manifest.json'),
                'scorerSha256': sha(Path(__file__)), 'generations': {x['id']: sha(generations[x['id']]) for x in items},
                'packages': {name: importlib.metadata.version(name) for name in ['evalplus', 'lm_eval', 'nltk']},
                'policy': 'truncated/error generations fail; pending generations prevent scoring; final content only'}
    identity['evaluatorRandomSeeds'] = {'pythonPerItem': 0, 'langdetect': 0}
    # Load only evaluators used by this dataset; letter scoring needs no model libraries.
    suites = {x['suite'] for x in items}
    coding_suites = suites & {'humanevalplus', 'mbppplus'}
    evaluator_modules = []
    if coding_suites:
        import evalplus.evaluate as coding
        import evalplus.sanitize as sanitizer
        from evalplus.data import get_human_eval_plus, get_mbpp_plus
        from evalplus.eval._special_oracle import MBPP_OUTPUT_NOT_NONE_TASKS
        evaluator_modules.extend([coding, sanitizer])
    if 'ifeval' in suites:
        import nltk
        from langdetect import DetectorFactory
        DetectorFactory.seed = 0
        nltk.data.find('tokenizers/punkt_tab')
        from lm_eval.tasks.ifeval import utils as instruction
        evaluator_modules.append(instruction)
    identity['evaluatorSourceHashes'] = {str(Path(m.__file__).resolve()): sha(Path(m.__file__))
                                         for m in evaluator_modules}
    manifest = args.out / 'manifest.json'
    if manifest.exists() and json.loads(manifest.read_text()) != identity:
        raise ValueError('Scoring identity changed; use a separate output directory')
    save(manifest, identity)
    invocation_started = time.monotonic()
    invocation_dir = args.out / 'invocations'
    invocation_dir.mkdir(exist_ok=True)
    invocation_path = invocation_dir / (str(time.time_ns()) + '.json')
    invocation = {'startedUnix': time.time(), 'status': 'running', 'identitySha256': sha(manifest)}
    save(invocation_path, invocation)
    (args.out / 'scorer.py').write_bytes(Path(__file__).read_bytes())
    if coding_suites:
        coding.CACHE_DIR = str(args.out / 'groundtruth')
    problems, expected = {}, {}
    for suite in coding_suites:
        all_problems = get_human_eval_plus() if suite == 'humanevalplus' else get_mbpp_plus()
        selected = {x['id']: all_problems[x['id']] for x in items if x['suite'] == suite}
        dataset_hash = hashlib.sha256(json.dumps(selected, sort_keys=True).encode()).hexdigest()
        save(args.out / (suite + '-dataset.json'), {'subsetSha256': dataset_hash, 'ids': list(selected)})
        expected.update(coding.get_groundtruth(selected, dataset_hash, [] if suite == 'humanevalplus' else MBPP_OUTPUT_NOT_NONE_TASKS))
        problems.update(selected)
    rows = []
    for item in items:
        key = item['id']
        generation = json.loads(generations[key].read_text())
        result_path = args.out / (hashlib.sha256(key.encode()).hexdigest()[:20] + '.score.json')
        if result_path.exists():
            row = json.loads(result_path.read_text())
        else:
            item_score_started = time.monotonic()
            random.seed(0)  # Resume/order-independent defaults in instruction checker construction.
            row = {'id': key, 'suite': item['suite'], 'generationStatus': generation['status'],
                   'correct': False, 'scored': True}
            if generation['status'] == 'completed':
                if item['suite'] == 'gsm8k':
                    # This parser is recorded in each generation by the frozen runner.
                    row['correct'] = generation['score']['correct']
                    row['details'] = generation['score']
                elif item['suite'] == 'mmlu':
                    row['details'] = score_mmlu(item, generation)
                    row['correct'] = row['details']['correct']
                elif item['suite'] == 'ifeval':
                    doc = dict(item['evaluator'], prompt=item['messages'][-1]['content'])
                    row['details'] = instruction.process_results(doc, [generation['content']])
                    row['correct'] = row['details']['prompt_level_strict_acc']
                elif item['suite'] in coding_suites:
                    solution = sanitizer.sanitize(generation['content'], entrypoint=item['entry_point'])
                    result = coding.check_correctness('humaneval' if item['suite'] == 'humanevalplus' else 'mbpp',
                        0, problems[key], solution, expected[key], identifier=key)
                    row['solution'] = solution
                    row['details'] = {tier: {'status': result[tier][0], 'tests': list(map(bool, result[tier][1]))}
                                      for tier in ['base', 'plus']}
                    row['correct'] = result['base'][0] == result['plus'][0] == 'pass'
                else:
                    row['scored'] = False
                    row['reason'] = 'No declared scorer for this development fixture'
            row['scoringSeconds'] = time.monotonic() - item_score_started
            save(result_path, row)
        rows.append((row, generation))
        print(json.dumps({'id': key, 'correct': row['correct'], 'scored': row['scored']}), flush=True)
    summary = {'createdUnix': time.time(), 'identitySha256': sha(manifest), 'suites': {}}
    for suite in sorted({x['suite'] for x in items}):
        subset = [(r, g) for r, g in rows if r['suite'] == suite]
        elapsed = sum(g['elapsedSeconds'] for _, g in subset)
        count = len(subset)
        scored = all(r['scored'] for r, _ in subset)
        correct = sum(r['correct'] for r, _ in subset) if scored else None
        summary['suites'][suite] = {'items': count, 'correct': correct, 'accuracy': correct / count if scored else None,
            'elapsedSeconds': elapsed, 'correctPerHour': correct * 3600 / elapsed if scored and elapsed else None,
            'completionTokens': sum(g.get('usage', {}).get('completion_tokens', 0) for _, g in subset),
            'generationStatuses': {status: sum(g['status'] == status for _, g in subset)
                                   for status in ['completed', 'truncated', 'error']},
            'powerWh': None, 'energyStatus': 'no validated collector',
            'scope': 'quality and elapsed generation time from the same items; backend timing and memory remain in raw results'}
        summary['suites'][suite]['itemScoringSeconds'] = sum(r.get('scoringSeconds', 0) for r, _ in subset)
        if suite == 'mmlu':
            subjects = {item['id']: item['subject'] for item in items if item['suite'] == suite}
            by_subject = {}
            for row, _ in subset:
                subject = subjects[row['id']]
                bucket = by_subject.setdefault(subject, {'items': 0, 'correct': 0})
                bucket['items'] += 1
                bucket['correct'] += int(row['correct'])
            for bucket in by_subject.values():
                bucket['accuracy'] = bucket['correct'] / bucket['items']
            summary['suites'][suite]['subjects'] = by_subject
            summary['suites'][suite]['subjectMacroAccuracy'] = sum(b['accuracy'] for b in by_subject.values()) / len(by_subject)
    invocation.update(status='completed', finishedUnix=time.time(), elapsedSeconds=time.monotonic() - invocation_started)
    save(invocation_path, invocation)
    invocations = [json.loads(path.read_text()) for path in invocation_dir.glob('*.json')]
    summary['scoringAccounting'] = {
        'completedInvocationSeconds': sum(row.get('elapsedSeconds', 0) for row in invocations if row['status'] == 'completed'),
        'incompleteInvocations': sum(row['status'] != 'completed' for row in invocations),
        'scope': 'Timed after manifest validation through scoring/summary preparation; includes ground-truth preparation and cached-score reads, excludes Python startup/imports. Incomplete invocations have unknown total duration.'}
    save(args.out / 'summary.json', summary)


if __name__ == '__main__':
    main()
