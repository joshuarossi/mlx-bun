# serve h2h — 2026-07-06

machine: Apple M1 Max · 32 GB · loadavg { 4.09 4.64 3.73 } · 2026-07-06T14:21:59.405Z
commit: 6fc281d

All numbers over HTTP against REAL servers at their real defaults
(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;
warm = exact repeat (each stack's own prompt cache). ctx figures from
ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.
mixed-KV: perf = mlx-bun-mixed vs mlx-bun (same engine, scheme on/off);
correctness = script-driven optiq goldens. No optiq-mixed HTTP arm —
optiq serve's kv-quant is inert on this mlx-lm (lab/repro/
optiq-mixed-kv-inert), so that arm would just re-benchmark mlx-lm bf16.

## MiniCPM5-1B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 266.0 | 266 | 27 (626) | 2357 | 15853 | 1472 | 120.9 | 46 | 172 (15852) | 451.6 | 1822 | 1.1 | 1.0 |
| mlx-bun-serial | 263.8 | 250 | 30 (627) | 2510 | 15818 | 1496 | 123.2 | 59 | 165 (15817) | 231.3 | 1641 | 0.9 | 0.8 |
| mlx-lm (stabilized top3of7) | 200.4 | 318 | 81 (625) | 1967 | 15884 | 1486 | 97.5 | 123 | 10296 (0) | 188.1 | 1215 | 1.9 | 1.7 |
| mlx-bun-mixed | 203.6 | 307 | 53 (626) | 2044 | 15854 | 1009 | 127.3 | 46 | 157 (15853) | 404.9 | 1546 | 0.9 | 0.8 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 308 · warmup 308 · parity 1205 · decode 1251 · ttft1k 1257 · ctx 1326 · restart 1822 · agg 1251 · peak 1822
- mlx-bun-serial: idle 314 · warmup 1206 · parity 1213 · decode 1259 · ttft1k 1259 · ctx 1362 · restart 1641 · agg 1263 · peak 1641
- mlx-lm: idle 1152 · warmup 1167 · parity 1178 · decode 1179 · ttft1k 1179 · ctx 1194 · restart 1215 · agg 1213 · peak 1215
- mlx-bun-mixed: idle 309 · warmup 309 · parity 1219 · decode 1248 · ttft1k 1253 · ctx 1337 · restart 1546 · agg 1264 · peak 1546
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ✗** bf16 drop-in (vs mlx-lm) [completion-probe]: same prompt bits (prompt_tokens 7 both), diverged at char 0: …` 2, 3, 5, 7, 11, 13,` vs …`2, 3, 5, 7, 11, 13, `
- **parity ✓** bf16 drop-in (vs mlx-lm) [chat-probe]: 64 greedy tokens identical (prompt_tokens 27 both)
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 7 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 27 both)

- kv-quant check ⚠ — mlx-bun-mixed ctx-leg RSS 1337 MB vs mlx-bun 1326 MB (expect mixed < bf16 — SUSPECT SILENT BF16: quantization hooks may not be live on the measured path)

## gemma-4-e4b

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 61.2 | 825 | 80 (657) | 799 | 15976 | 845 | 44.5 | 466 | 925 (15975) | 99.6 | 7445 | 2.5 | 1.2 |
| mlx-bun-serial | 61.2 | 774 | 47 (659) | 853 | 15938 | 862 | 41.5 | 279 | 825 (15937) | 59.2 | 7702 | 1.7 | 1.2 |
| mlx-lm | 52.4 | 976 | 259 (667) | 684 | 15726 | 878 | 42.5 | 314 | 19861 (0) | 73.1 | 7373 | 3.8 | 1.5 |
| mlx-bun-mixed | 57.6 | 804 | 85 (660) | 822 | 15903 | 789 | 48.2 | 369 | 814 (15902) | 97.1 | 7338 | 1.8 | 1.2 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 588 · warmup 6837 · parity 6852 · decode 6817 · ttft1k 6691 · ctx 7419 · restart 7445 · agg 6964 · peak 7445
- mlx-bun-serial: idle 589 · warmup 4369 · parity 6894 · decode 6956 · ttft1k 7053 · ctx 7615 · restart 7702 · agg 6958 · peak 7702
- mlx-lm: idle 1120 · warmup 7310 · parity 6725 · decode 6724 · ttft1k 6725 · ctx 6731 · restart 7373 · agg 6768 · peak 7373
- mlx-bun-mixed: idle 586 · warmup 4677 · parity 6889 · decode 6919 · ttft1k 6960 · ctx 7262 · restart 7338 · agg 6979 · peak 7338
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ✓** bf16 drop-in (vs mlx-lm) [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✗** bf16 drop-in (vs mlx-lm) [chat-probe]: same prompt bits (prompt_tokens 32 both), diverged at char 0: …`Here's a thinking pr` vs …`
Here's a thinking p`
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)

- kv-quant check ✓ — mlx-bun-mixed ctx-leg RSS 7262 MB vs mlx-bun 7419 MB (expect mixed < bf16)

## gemma-4-12B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 29.7 | 3524 | 207 (664) | 188 | 15798 | 186 | 28.4 | 705 | 3617 (15794) | 40.2 | 9819 | 2.7 | 1.2 |
| mlx-bun-serial | 29.2 | 3495 | 213 (661) | 190 | 15871 | 184 | 28.2 | 484 | 1750 (15867) | 27.5 | 9947 | 2.5 | 1.4 |
| mlx-lm (via optiq register, rerun ‡) | 26.1 | 3719 | 397 (667) | 180 | 15725 | 181 | 25.0 | 400 | 89376 (0) | 32.9 | 9561 | 7.6 | 1.7 |
| mlx-bun-mixed | 28.5 | 3610 | 164 (664) | 184 | 15795 | 171 | 24.5 | 621 | 1422 (15791) | 39.7 | 9507 | 2.3 | 1.2 |

- ‡ plain `mlx_lm.server` CANNOT load this model (`ValueError: Model type
  gemma4_unified not supported` — worker thread dies, HTTP front zombies;
  full traceback below). The row above is the bf16 baseline measured in a
  same-day solo rerun (benchmarks-serve-2026-07-06c) via `optiq serve`
  WITHOUT --kv-config: optiq register()s the architecture, fp16 KV default,
  kv-quant hooks never run. Original failed-cell records kept below.
- † mlx-lm: **warmup** phase failed (TimeoutError: The operation timed out. — retry: TimeoutError: The operation timed out.) — "—" cells above; stderr tail in failures section
- † mlx-lm: **parity** phase failed (TimeoutError: The operation timed out. — server unresponsive, respawn already used) — "—" cells above; stderr tail in failures section
- † mlx-lm: **decode** phase failed (TimeoutError: The operation timed out. — server unresponsive, respawn already used) — "—" cells above; stderr tail in failures section
- † mlx-lm: **ttft1k** phase failed (TimeoutError: The operation timed out. — server unresponsive, respawn already used) — "—" cells above; stderr tail in failures section
- † mlx-lm: **ctx** phase failed (TimeoutError: The operation timed out. — server unresponsive, respawn already used) — "—" cells above; stderr tail in failures section
- † mlx-lm: **agg** phase failed (TimeoutError: The operation timed out. — server unresponsive, respawn already used) — "—" cells above; stderr tail in failures section

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 591 · warmup 8592 · parity 8792 · decode 9297 · ttft1k 9511 · ctx 9819 · restart 8107 · agg 4894 · peak 9819
- mlx-bun-serial: idle 586 · warmup 9058 · parity 9241 · decode 9646 · ttft1k 9851 · ctx 9947 · restart 9071 · agg 9477 · peak 9947
- mlx-lm: idle 103 · warmup 103 · parity 102 · decode 102 · ttft1k 103 · ctx 103 · restart 103 · agg 103 · peak 103
- mlx-bun-mixed: idle 643 · warmup 9118 · parity 9147 · decode 9221 · ttft1k 9405 · ctx 9507 · restart 8787 · agg 9198 · peak 9507
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ?** bf16 drop-in (vs mlx-lm) [completion-probe]: probe missing on second arm — not attempted
- **parity ?** bf16 drop-in (vs mlx-lm) [chat-probe]: probe missing on second arm — not attempted
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)

- kv-quant check ✓ — mlx-bun-mixed ctx-leg RSS 9507 MB vs mlx-bun 9819 MB (expect mixed < bf16)

## failures

- 12B/mlx-lm [phase warmup]: TimeoutError: The operation timed out. — retry: TimeoutError: The operation timed out.
  stderr tail (last 30 lines):
  ```
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 385, in load_default
      self.load("default_model", None, "default_model")
      ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 394, in load
      self._load(*model_key)
      ~~~~~~~~~~^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 349, in _load
      model, tokenizer = load(
                         ~~~~^
          model_path,
          ^^^^^^^^^^^
          adapter_path=adapter_path,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^
          tokenizer_config=self._tokenizer_config,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      )
      ^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 491, in load
      model, config = load_model(model_path, lazy, model_config=model_config)
                      ~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 334, in load_model
      model_class, model_args_class = get_model_classes(config=config)
                                      ~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 191, in _get_classes
      raise ValueError(msg)
  ValueError: Model type gemma4_unified not supported.
  /Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py:1723: UserWarning: mlx_lm.server is not recommended for production as it only implements basic security checks.
    warnings.warn(
  2026-07-06 08:36:16,575 - INFO - Starting httpd at 127.0.0.1 on port 8971...
  127.0.0.1 - - [06/Jul/2026 08:36:16] "GET /v1/models HTTP/1.1" 200 -
  ```
- 12B/mlx-lm [phase parity]: TimeoutError: The operation timed out. — server unresponsive, respawn already used
  stderr tail (last 30 lines):
  ```
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 385, in load_default
      self.load("default_model", None, "default_model")
      ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 394, in load
      self._load(*model_key)
      ~~~~~~~~~~^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 349, in _load
      model, tokenizer = load(
                         ~~~~^
          model_path,
          ^^^^^^^^^^^
          adapter_path=adapter_path,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^
          tokenizer_config=self._tokenizer_config,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      )
      ^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 491, in load
      model, config = load_model(model_path, lazy, model_config=model_config)
                      ~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 334, in load_model
      model_class, model_args_class = get_model_classes(config=config)
                                      ~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 191, in _get_classes
      raise ValueError(msg)
  ValueError: Model type gemma4_unified not supported.
  /Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py:1723: UserWarning: mlx_lm.server is not recommended for production as it only implements basic security checks.
    warnings.warn(
  2026-07-06 08:36:16,575 - INFO - Starting httpd at 127.0.0.1 on port 8971...
  127.0.0.1 - - [06/Jul/2026 08:36:16] "GET /v1/models HTTP/1.1" 200 -
  ```
- 12B/mlx-lm [phase decode]: TimeoutError: The operation timed out. — server unresponsive, respawn already used
  stderr tail (last 30 lines):
  ```
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 385, in load_default
      self.load("default_model", None, "default_model")
      ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 394, in load
      self._load(*model_key)
      ~~~~~~~~~~^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 349, in _load
      model, tokenizer = load(
                         ~~~~^
          model_path,
          ^^^^^^^^^^^
          adapter_path=adapter_path,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^
          tokenizer_config=self._tokenizer_config,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      )
      ^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 491, in load
      model, config = load_model(model_path, lazy, model_config=model_config)
                      ~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 334, in load_model
      model_class, model_args_class = get_model_classes(config=config)
                                      ~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 191, in _get_classes
      raise ValueError(msg)
  ValueError: Model type gemma4_unified not supported.
  /Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py:1723: UserWarning: mlx_lm.server is not recommended for production as it only implements basic security checks.
    warnings.warn(
  2026-07-06 08:36:16,575 - INFO - Starting httpd at 127.0.0.1 on port 8971...
  127.0.0.1 - - [06/Jul/2026 08:36:16] "GET /v1/models HTTP/1.1" 200 -
  ```
- 12B/mlx-lm [phase ttft1k]: TimeoutError: The operation timed out. — server unresponsive, respawn already used
  stderr tail (last 30 lines):
  ```
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 385, in load_default
      self.load("default_model", None, "default_model")
      ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 394, in load
      self._load(*model_key)
      ~~~~~~~~~~^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 349, in _load
      model, tokenizer = load(
                         ~~~~^
          model_path,
          ^^^^^^^^^^^
          adapter_path=adapter_path,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^
          tokenizer_config=self._tokenizer_config,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      )
      ^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 491, in load
      model, config = load_model(model_path, lazy, model_config=model_config)
                      ~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 334, in load_model
      model_class, model_args_class = get_model_classes(config=config)
                                      ~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 191, in _get_classes
      raise ValueError(msg)
  ValueError: Model type gemma4_unified not supported.
  /Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py:1723: UserWarning: mlx_lm.server is not recommended for production as it only implements basic security checks.
    warnings.warn(
  2026-07-06 08:36:16,575 - INFO - Starting httpd at 127.0.0.1 on port 8971...
  127.0.0.1 - - [06/Jul/2026 08:36:16] "GET /v1/models HTTP/1.1" 200 -
  ```
- 12B/mlx-lm [phase ctx]: TimeoutError: The operation timed out. — server unresponsive, respawn already used
  stderr tail (last 30 lines):
  ```
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 385, in load_default
      self.load("default_model", None, "default_model")
      ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 394, in load
      self._load(*model_key)
      ~~~~~~~~~~^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 349, in _load
      model, tokenizer = load(
                         ~~~~^
          model_path,
          ^^^^^^^^^^^
          adapter_path=adapter_path,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^
          tokenizer_config=self._tokenizer_config,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      )
      ^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 491, in load
      model, config = load_model(model_path, lazy, model_config=model_config)
                      ~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 334, in load_model
      model_class, model_args_class = get_model_classes(config=config)
                                      ~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 191, in _get_classes
      raise ValueError(msg)
  ValueError: Model type gemma4_unified not supported.
  /Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py:1723: UserWarning: mlx_lm.server is not recommended for production as it only implements basic security checks.
    warnings.warn(
  2026-07-06 08:36:16,575 - INFO - Starting httpd at 127.0.0.1 on port 8971...
  127.0.0.1 - - [06/Jul/2026 08:36:16] "GET /v1/models HTTP/1.1" 200 -
  ```
- 12B/mlx-lm [phase agg]: TimeoutError: The operation timed out. — server unresponsive, respawn already used
  stderr tail (last 30 lines):
  ```
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 385, in load_default
      self.load("default_model", None, "default_model")
      ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 394, in load
      self._load(*model_key)
      ~~~~~~~~~~^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py", line 349, in _load
      model, tokenizer = load(
                         ~~~~^
          model_path,
          ^^^^^^^^^^^
          adapter_path=adapter_path,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^
          tokenizer_config=self._tokenizer_config,
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      )
      ^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 491, in load
      model, config = load_model(model_path, lazy, model_config=model_config)
                      ~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 334, in load_model
      model_class, model_args_class = get_model_classes(config=config)
                                      ~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^
    File "/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/utils.py", line 191, in _get_classes
      raise ValueError(msg)
  ValueError: Model type gemma4_unified not supported.
  /Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/mlx_lm/server.py:1723: UserWarning: mlx_lm.server is not recommended for production as it only implements basic security checks.
    warnings.warn(
  2026-07-06 08:36:16,575 - INFO - Starting httpd at 127.0.0.1 on port 8971...
  127.0.0.1 - - [06/Jul/2026 08:36:16] "GET /v1/models HTTP/1.1" 200 -
  ```
