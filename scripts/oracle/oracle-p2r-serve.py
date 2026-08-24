#!/usr/bin/env python3
"""Benchmark-only mlx-lm launcher with prompt-to-response timing spans.

Imports the pinned oracle, wraps semantic boundaries, then calls its untouched
CLI main. The installed venv is never edited. Enable collection by sending an
`x-mlx-bun-trace-id` request header. Records are written to stderr as one
`[p2r] {json}` line after each response.
"""

from __future__ import annotations

import json
import importlib
import os
import sys
import threading
import time
from typing import Any

generate_module = importlib.import_module("mlx_lm.generate")
server_module = importlib.import_module("mlx_lm.server")
cache_module = importlib.import_module("mlx_lm.models.cache")
mx = importlib.import_module("mlx.core")


PREFIX = "[p2r] "
VERSION = 1
_local = threading.local()
_uid_traces: dict[int, "Trace"] = {}


class Trace:
    def __init__(self, trace_id: str, request_id: str, route: str):
        self.trace_id = trace_id
        self.request_id = request_id
        self.route = route
        self.started = time.monotonic_ns()
        self.events: list[dict[str, Any]] = []
        self.finished = False
        self.prefill_started: int | None = None
        self.token_zero_started: int | None = None
        self.close_admission = None
        self.lock = threading.Lock()

    def _ms(self, ns: int) -> float:
        return ns / 1_000_000

    def begin(self, phase: str, attributes: dict[str, Any] | None = None):
        started = time.monotonic_ns()
        closed = False

        def close():
            nonlocal closed
            with self.lock:
                if closed or self.finished:
                    return
                closed = True
                ended = time.monotonic_ns()
                event = {
                    "phase": phase,
                    "startMs": self._ms(started - self.started),
                    "durationMs": self._ms(ended - started),
                }
                if attributes:
                    event["attributes"] = attributes
                self.events.append(event)

        return close

    def add(self, phase: str, started: int, ended: int, attributes=None):
        with self.lock:
            if self.finished:
                return
            event = {
                "phase": phase,
                "startMs": self._ms(started - self.started),
                "durationMs": self._ms(ended - started),
            }
            if attributes:
                event["attributes"] = attributes
            self.events.append(event)

    def mark(self, phase: str, attributes=None):
        now = time.monotonic_ns()
        self.add(phase, now, now, attributes)

    def finish(self, outcome: str):
        with self.lock:
            if self.finished:
                return
            self.finished = True
            record = {
                "version": VERSION,
                "traceId": self.trace_id,
                "requestId": self.request_id,
                "route": self.route,
                "clock": "monotonic-ms",
                "outcome": outcome,
                "totalMs": self._ms(time.monotonic_ns() - self.started),
                "events": sorted(self.events, key=lambda e: e["startMs"]),
            }
        print(PREFIX + json.dumps(record, separators=(",", ":")), file=sys.stderr, flush=True)


def _attach_trace(handler, request, route):
    trace_id = handler.headers.get("x-mlx-bun-trace-id")
    if trace_id:
        request._p2r_trace = Trace(trace_id, handler.request_id, route)
    return request


_chat = server_module.APIHandler.handle_chat_completions


def handle_chat(self):
    return _attach_trace(self, _chat(self), "/v1/chat/completions")


server_module.APIHandler.handle_chat_completions = handle_chat

_text = server_module.APIHandler.handle_text_completions


def handle_text(self):
    return _attach_trace(self, _text(self), "/v1/completions")


server_module.APIHandler.handle_text_completions = handle_text

_tokenize = server_module.ResponseGenerator._tokenize


def tokenize(self, tokenizer, request, args):
    trace = getattr(request, "_p2r_trace", None)
    if trace and trace.close_admission:
        trace.close_admission()
        trace.close_admission = None
    _local.trace = trace
    close = trace.begin("request.prompt_prepare") if trace else None
    try:
        return _tokenize(self, tokenizer, request, args)
    finally:
        if close:
            close()


server_module.ResponseGenerator._tokenize = tokenize

_fetch_cache = cache_module.LRUPromptCache.fetch_nearest_cache


def fetch_cache(self, *args, **kwargs):
    trace = getattr(_local, "trace", None)
    close = trace.begin("cache.lookup_restore", {"mechanism": "continuous"}) if trace else None
    try:
        return _fetch_cache(self, *args, **kwargs)
    finally:
        if close:
            close()


cache_module.LRUPromptCache.fetch_nearest_cache = fetch_cache

_insert_segments = generate_module.BatchGenerator.insert_segments


def insert_segments(self, *args, **kwargs):
    trace = getattr(_local, "trace", None)
    uids = _insert_segments(self, *args, **kwargs)
    if trace:
        for uid in uids:
            _uid_traces[uid] = trace
        trace.prefill_started = time.monotonic_ns()
    _local.trace = None
    return uids


generate_module.BatchGenerator.insert_segments = insert_segments

_make_batch = generate_module.BatchGenerator._make_batch


def make_batch(self, n):
    traces = []
    for sequence in list(self._unprocessed_sequences)[:n]:
        trace = _uid_traces.get(sequence[0])
        if trace:
            traces.append(trace)
    started = time.monotonic_ns()
    result = _make_batch(self, n)
    if os.environ.get("MLX_BUN_P2R_SYNC") == "1":
        mx.synchronize()
    ended = time.monotonic_ns()
    for trace in traces:
        trace.add("prefill.batch_setup", started, ended, {"mechanism": "continuous"})
    return result


generate_module.BatchGenerator._make_batch = make_batch

_prompt_generate = generate_module.PromptProcessingBatch.generate


def prompt_generate(self, *args, **kwargs):
    started = time.monotonic_ns()
    for uid in self.uids:
        trace = _uid_traces.get(uid)
        if not trace:
            continue
        if trace.prefill_started is not None:
            trace.add(
                "prefill.total",
                trace.prefill_started,
                started,
                {"mechanism": "continuous"},
            )
            trace.prefill_started = None
        trace.token_zero_started = started
    result = _prompt_generate(self, *args, **kwargs)
    if os.environ.get("MLX_BUN_P2R_SYNC") == "1":
        mx.synchronize()
    return result


generate_module.PromptProcessingBatch.generate = prompt_generate

_prompt = generate_module.PromptProcessingBatch.prompt


def prompt(self, *args, **kwargs):
    started = time.monotonic_ns()
    result = _prompt(self, *args, **kwargs)
    if os.environ.get("MLX_BUN_P2R_SYNC") == "1":
        mx.synchronize()
    ended = time.monotonic_ns()
    for uid in self.uids:
        trace = _uid_traces.get(uid)
        if trace:
            trace.add("prefill.chunk", started, ended, {"mechanism": "continuous"})
    return result


generate_module.PromptProcessingBatch.prompt = prompt

_next = generate_module.BatchGenerator.next


def next_step(self, *args, **kwargs):
    started = time.monotonic_ns()
    prompt_responses, gen_responses = _next(self, *args, **kwargs)
    ended = time.monotonic_ns()
    for response in gen_responses:
        trace = _uid_traces.get(response.uid)
        if not trace:
            continue
        if trace.token_zero_started is not None:
            trace.add(
                "token_zero.total",
                trace.token_zero_started,
                ended,
                {"mechanism": "continuous"},
            )
            trace.token_zero_started = None
    return prompt_responses, gen_responses


generate_module.BatchGenerator.next = next_step

_generate = server_module.ResponseGenerator.generate


def generate(self, request, generation_args, progress_callback=None):
    trace = getattr(request, "_p2r_trace", None)
    close_admission = trace.begin("engine.admission_wait", {"mechanism": "continuous"}) if trace else None
    if trace:
        trace.close_admission = close_admission
    try:
        context, responses = _generate(self, request, generation_args, progress_callback)
    except Exception:
        if close_admission:
            close_admission()
        if trace:
            trace.finish("error")
        raise
    if trace and trace.close_admission:
        close_admission()
        trace.close_admission = None

    def traced_responses():
        first = True
        outcome = "success"
        try:
            for response in responses:
                if first:
                    first = False
                    trace.mark("response.first_write")
                yield response
        except GeneratorExit:
            outcome = "abort"
            raise
        except Exception:
            outcome = "error"
            raise
        finally:
            trace.mark("response.final_write")
            trace.finish(outcome)
            for uid, candidate in list(_uid_traces.items()):
                if candidate is trace:
                    _uid_traces.pop(uid, None)

    return context, traced_responses() if trace else responses


server_module.ResponseGenerator.generate = generate


if __name__ == "__main__":
    if "--optiq-serve" in sys.argv:
        sys.argv.remove("--optiq-serve")
        sys.argv.insert(1, "serve")
        from optiq.cli import cli

        cli()
    else:
        server_module.main()
