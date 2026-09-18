#!/usr/bin/env python3
"""Resumable B1 chat evaluation with raw SSE and same-run timing/RSS evidence.

Python standard library only. Input is a frozen JSONL of id/suite/messages/answer.
Model/engine/runtime identity and request parameters come from a JSON config.
This records generations; executable-code and IFEval scoring run separately.
"""
import argparse
import ctypes
import ctypes.util
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import threading
import time
import urllib.request


def digest(data):
    return hashlib.sha256(data).hexdigest()


def atomic_json(path, value):
    tmp = path.with_suffix(path.suffix + '.tmp')
    with tmp.open('w') as f:
        json.dump(value, f, indent=2)
        f.write('\n')
        f.flush()
        os.fsync(f.fileno())
    tmp.replace(path)


def memory_sample(pid):
    """RSS sum for root and descendants. Unified allocations may overlap."""
    lines = subprocess.check_output(['ps', '-axo', 'pid=,ppid=,rss='], text=True).splitlines()
    rows = [tuple(map(int, line.split())) for line in lines if line.strip()]
    included = {pid}
    while True:
        children = {p for p, parent, _ in rows if parent in included}
        expanded = included | children
        if expanded == included:
            break
        included = expanded
    footprints = [physical_footprint(p) for p in included]
    return {'monotonic': time.monotonic(), 'rssBytes': sum(r * 1024 for p, _, r in rows if p in included),
            'pids': sorted(included), 'footprintBytes': sum(x for x in footprints if x is not None)
            if all(x is not None for x in footprints) else None}


def physical_footprint(pid):
    # Darwin rusage_info_v2 layout from sys/resource.h. Never add this to RSS.
    class RUsage(ctypes.Structure):
        _fields_ = [('uuid', ctypes.c_uint8 * 16)] + [(name, ctypes.c_uint64) for name in
            ['user', 'system', 'idle', 'interrupt', 'pageins', 'wired', 'resident', 'footprint',
             'start', 'exit', 'child_user', 'child_system', 'child_idle', 'child_interrupt',
             'child_pageins', 'child_elapsed', 'read', 'written']]
    try:
        lib = ctypes.CDLL(ctypes.util.find_library('proc'))
        fn = lib.proc_pid_rusage
        fn.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_void_p]
        value = RUsage()
        return value.footprint if fn(pid, 2, ctypes.byref(value)) == 0 else None
    except (OSError, AttributeError, TypeError):
        return None


def swap_usage():
    try:
        text = subprocess.check_output(['sysctl', '-n', 'vm.swapusage'], text=True).strip()
        match = re.search(r'used\s*=\s*([\d.]+)([KMG])', text)
        return {'raw': text, 'usedBytes': float(match[1]) * {'K': 1024, 'M': 1024**2, 'G': 1024**3}[match[2]]
                if match else None}
    except (OSError, subprocess.CalledProcessError):
        return None


def events(lines):
    """SSE framing, including multi-line data and EOF without a blank line."""
    data = []
    for line in lines:
        line = line.decode('utf-8').rstrip('\r\n')
        if not line:
            if data:
                yield '\n'.join(data)
                data = []
        elif line.startswith('data:'):
            data.append(line[5:].lstrip(' '))
    if data:
        yield '\n'.join(data)


def gsm_score(text, expected):
    # Frozen protocol explicitly requires #### followed by the final number.
    found = re.findall(r'####\s*([-+]?\d[\d,]*(?:\.\d+)?)', text)
    if not found:
        return {'correct': False, 'extracted': None, 'parser': 'gsm8k-hash-final-v1'}
    from decimal import Decimal, InvalidOperation
    try:
        got = Decimal(found[-1].replace(',', ''))
        want = Decimal(str(expected).replace(',', '').strip())
        return {'correct': got == want, 'extracted': str(got), 'parser': 'gsm8k-hash-final-v1'}
    except InvalidOperation:
        return {'correct': False, 'extracted': found[-1], 'parser': 'gsm8k-hash-final-v1'}


def run_item(config, item, out, pid, retry_errors=False):
    """Preserve interrupted/failed attempts; never retry a completed answer."""
    if out.exists():
        previous = json.loads(out.read_text())
        if previous['id'] != item['id']:
            raise ValueError('Saved result has the wrong item ID')
        if previous['status'] != 'error' or not retry_errors:
            return previous
    artifacts = [out, out.with_suffix('.request.json'), out.with_suffix('.sse'),
                 out.with_suffix('.events.jsonl')]
    existing = [path for path in artifacts if path.exists()]
    history = out.parent / 'attempts' / out.stem
    if existing:
        attempts = list(history.glob('attempt-*')) if history.exists() else []
        if attempts:
            raise RuntimeError('One recovery attempt already used for this item')
        destination = history / 'attempt-1'
        destination.mkdir(parents=True)
        for path in existing:
            path.rename(destination / path.name)
    return generate(config, item, out, pid)


def generate(config, item, out, pid):
    swap_before = swap_usage()
    started = time.monotonic()
    result = {'id': item['id'], 'suite': item['suite'], 'status': 'running',
              'startedUnix': time.time(), 'content': '', 'reasoning': '', 'usage': {},
              'finishReason': None, 'firstOutputSeconds': None, 'firstAnswerSeconds': None,
              'powerWh': None, 'powerStatus': 'no validated power collector',
              'prefillTokensPerSecond': None, 'decodeTokensPerSecond': None}
    stop = threading.Event()
    samples = []
    def monitor():
        while not stop.is_set():
            try:
                samples.append(memory_sample(pid))
            except Exception as e:
                samples.append({'error': str(e), 'monotonic': time.monotonic()})
            stop.wait(1)
    thread = threading.Thread(target=monitor, daemon=True)
    thread.start()
    body = dict(config['request'], messages=item['messages'], stream=True,
                stream_options={'include_usage': True})
    atomic_json(out.with_suffix('.request.json'), body)
    last_output = None
    saw_done = False
    def timeout_handler(_signum, _frame):
        raise TimeoutError('Declared total item deadline exceeded')
    old_handler = signal.signal(signal.SIGALRM, timeout_handler)
    timeout = config.get('timeoutSeconds', 7200)
    signal.setitimer(signal.ITIMER_REAL, timeout)
    try:
        req = urllib.request.Request(config['baseUrl'].rstrip('/') + '/chat/completions',
                                     data=json.dumps(body).encode(), headers={'Content-Type': 'application/json'})
        with urllib.request.urlopen(req, timeout=timeout) as response, out.with_suffix('.sse').open('wb') as wire, out.with_suffix('.events.jsonl').open('w') as event_file:
            def lines():
                for line in response:
                    wire.write(line)
                    wire.flush()
                    yield line
            for data in events(lines()):
                elapsed = time.monotonic() - started
                event_file.write(json.dumps({'seconds': elapsed, 'data': data}) + '\n')
                event_file.flush()
                if data == '[DONE]':
                    saw_done = True
                    break
                value = json.loads(data)
                if value.get('error'):
                    raise RuntimeError(json.dumps(value['error']))
                if value.get('usage'):
                    result['usage'] = value['usage']
                if value.get('timings'):
                    result['engineTimings'] = value['timings']
                for choice in value.get('choices', []):
                    delta = choice.get('delta') or {}
                    content = delta.get('content') or ''
                    reasoning = delta.get('reasoning_content') or delta.get('reasoning') or ''
                    # Store structured tool deltas intact in raw SSE; count first arrival only.
                    if content or reasoning or delta.get('tool_calls'):
                        if result['firstOutputSeconds'] is None:
                            result['firstOutputSeconds'] = elapsed
                        last_output = elapsed
                    if content and result['firstAnswerSeconds'] is None:
                        result['firstAnswerSeconds'] = elapsed
                    result['content'] += content
                    result['reasoning'] += reasoning
                    if choice.get('finish_reason'):
                        result['finishReason'] = choice['finish_reason']
        if not saw_done or result['finishReason'] is None:
            raise RuntimeError('Incomplete stream: missing DONE or finish reason')
        result['status'] = 'truncated' if result['finishReason'] == 'length' else 'completed'
    except Exception as e:
        result['status'] = 'error'
        result['error'] = f'{type(e).__name__}: {e}'
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)
        signal.signal(signal.SIGALRM, old_handler)
        stop.set()
        thread.join(timeout=5)
    result['elapsedSeconds'] = time.monotonic() - started
    result['lastOutputSeconds'] = last_output
    result['swapBefore'] = swap_before
    result['swapAfter'] = swap_usage()
    result['memorySamples'] = samples
    result['peakProcessTreeRssBytes'] = max((s.get('rssBytes', 0) for s in samples), default=0) or None
    result['peakProcessTreeFootprintBytes'] = max((s.get('footprintBytes') or 0 for s in samples), default=0) or None
    result['memoryScope'] = 'sampled RSS sum, 1 second cadence; not unique physical memory or GPU allocation'
    tokens = result['usage'].get('completion_tokens')
    result['generatedTokensPerEndToEndSecond'] = tokens / result['elapsedSeconds'] if tokens else None
    result['timingScope'] = 'SSE chunk arrival; buffered output is not a per-token latency measurement'
    timings = result.get('engineTimings', {})
    # Preserve backend definitions separately from portable arrival measurements.
    result['engineReportedPrefillTokensPerSecond'] = timings.get('prompt_per_second',
        result['usage'].get('prompt_tokens_per_second'))
    result['engineReportedDecodeTokensPerSecond'] = timings.get('predicted_per_second',
        result['usage'].get('generation_tokens_per_second'))
    if item['suite'] == 'gsm8k' and result['status'] == 'completed':
        result['score'] = gsm_score(result['content'], item['answer'])
    atomic_json(out, result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=Path, required=True)
    parser.add_argument('--items', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--pid', type=int, required=True)
    parser.add_argument('--retry-errors', action='store_true',
                        help='Allow one recovery attempt, preserving the original artifacts')
    args = parser.parse_args()
    config = json.loads(args.config.read_text())
    items = [json.loads(line) for line in args.items.read_text().splitlines() if line.strip()]
    if len({x['id'] for x in items}) != len(items):
        raise ValueError('Duplicate item IDs')
    args.out.mkdir(parents=True, exist_ok=True)
    # A lock file alone is not liveness evidence; the OS lock is released on exit.
    lock = (args.out / '.runner.lock').open('a')
    fcntl.flock(lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    identity = {'config': config, 'itemsSha256': digest(args.items.read_bytes()),
                'runnerSha256': digest(Path(__file__).read_bytes()), 'schema': 1}
    manifest = args.out / 'manifest.json'
    if manifest.exists() and json.loads(manifest.read_text()) != identity:
        raise ValueError('Refusing resume with changed configuration, items or runner')
    atomic_json(manifest, identity)
    (args.out / 'runner.py').write_bytes(Path(__file__).read_bytes())
    for index, item in enumerate(items):
        out = args.out / (digest(item['id'].encode())[:20] + '.result.json')
        result = run_item(config, item, out, args.pid, args.retry_errors)
        progress = {'lastId': item['id'], 'lastStatus': result['status'], 'finishedItems': index + 1,
                    'totalItems': len(items), 'lastElapsedSeconds': result['elapsedSeconds']}
        atomic_json(args.out / 'progress.json', progress)
        print(json.dumps(progress), flush=True)
        # Stop on infrastructure failure; never silently run an entire suite against a dead server.
        if result['status'] == 'error':
            raise SystemExit(2)


if __name__ == '__main__':
    main()
