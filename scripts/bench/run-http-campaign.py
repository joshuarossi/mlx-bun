#!/usr/bin/env python3
"""Serial HTTP benchmark jobs with a GPU-owner lock and durable launch evidence.

A plan lists jobs with id, command, environment, healthUrl, config and items.
All paths are absolute. Prerequisite process waits belong outside this runner.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import time
import urllib.parse
import urllib.request


def save(path, value):
    temporary = path.with_suffix('.tmp')
    with temporary.open('w') as handle:
        json.dump(value, handle, indent=2)
        handle.write('\n')
        handle.flush()
        os.fsync(handle.fileno())
    temporary.replace(path)


def stop_server(server):
    if server.poll() is None:
        os.killpg(server.pid, signal.SIGTERM)
        try:
            server.wait(timeout=60)
        except subprocess.TimeoutExpired:
            os.killpg(server.pid, signal.SIGKILL)
            server.wait(timeout=10)


def run_job(job, root, runner):
    out = root / job['id']
    out.mkdir(parents=True, exist_ok=True)
    identity = {'job': job, 'itemsSha256': hashlib.sha256(Path(job['items']).read_bytes()).hexdigest(),
                'runnerSha256': hashlib.sha256(runner.read_bytes()).hexdigest()}
    manifest = out / 'job.json'
    if manifest.exists() and json.loads(manifest.read_text()) != identity:
        raise ValueError('Changed job identity: ' + job['id'])
    save(manifest, identity)
    save(out / 'config.json', job['config'])
    launches = out / 'launches'
    launches.mkdir(exist_ok=True)
    # Reuse completed items through the evaluator, but do not reload a completed job.
    if (out / 'exit.json').exists() and json.loads((out / 'exit.json').read_text())['exitCode'] == 0:
        return
    for artifact in job.get('artifacts', []):
        stat = Path(artifact['path']).stat()
        if stat.st_size != artifact['bytes'] or stat.st_mtime_ns != artifact['mtimeNs']:
            raise ValueError('Artifact changed since hashing: ' + artifact['path'])
    used = len(list(launches.glob('*.json')))
    if used >= 2:
        raise RuntimeError('Recovery launch budget exhausted: ' + job['id'])
    for attempt in range(used, 2):
        # Never attach a new measurement to an unrelated process on the same port.
        url = urllib.parse.urlparse(job['healthUrl'])
        with socket.socket() as probe:
            probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            probe.bind((url.hostname, url.port))
        started = time.time()
        with (out / f'server-{attempt + 1}.log').open('ab') as log:
            server = subprocess.Popen(job['command'], env=dict(os.environ, **job.get('environment', {})),
                                      stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
            launch = {'pid': server.pid, 'startedUnix': started, 'command': job['command'],
                      'environment': job.get('environment', {}), 'attempt': attempt + 1}
            save(launches / f'{attempt + 1}.json', launch)
            code = 2
            try:
                ready = False
                deadline = time.monotonic() + job.get('startupTimeoutSeconds', 300)
                while time.monotonic() < deadline and server.poll() is None:
                    try:
                        with urllib.request.urlopen(job['healthUrl'], timeout=2) as response:
                            ready = response.status == 200
                    except Exception:
                        pass
                    if ready:
                        break
                    time.sleep(1)
                if not ready:
                    raise RuntimeError('Server did not become ready')
                launch['readyUnix'] = time.time()
                save(launches / f'{attempt + 1}.json', launch)
                command = [sys.executable, str(runner), '--config', str(out / 'config.json'),
                           '--items', job['items'], '--out', str(out / 'generations'), '--pid', str(server.pid)]
                if attempt:
                    command.append('--retry-errors')
                code = subprocess.call(command)
            except Exception as error:
                launch['error'] = repr(error)
            finally:
                stop_server(server)
                launch.update(finishedUnix=time.time(), evaluationExitCode=code, serverExitCode=server.returncode)
                save(launches / f'{attempt + 1}.json', launch)
            save(out / 'exit.json', {'exitCode': code, 'attempts': attempt + 1, 'finishedUnix': time.time()})
            if code == 0:
                return
    raise RuntimeError('Job failed after recovery: ' + job['id'])


def main():
    def interrupted(_signum, _frame):
        raise KeyboardInterrupt('Campaign interrupted')
    signal.signal(signal.SIGTERM, interrupted)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    root = args.out.resolve()
    root.mkdir(parents=True, exist_ok=True)
    with (root.parent / '.benchmark-gpu.lock').open('a') as lock:
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        plan = json.loads(args.plan.read_text())
        frozen = root / 'plan.json'
        if frozen.exists() and json.loads(frozen.read_text()) != plan:
            raise ValueError('Campaign plan changed')
        save(frozen, plan)
        runner = root / 'evaluate-http.py'
        if not runner.exists():
            runner.write_bytes(Path(__file__).with_name('evaluate-http.py').read_bytes())
        for job in plan['jobs']:
            print('Starting ' + job['id'], flush=True)
            run_job(job, root, runner)
            print('Finished ' + job['id'], flush=True)
        save(root / 'exit.json', {'exitCode': 0, 'finishedUnix': time.time()})


if __name__ == '__main__':
    main()
