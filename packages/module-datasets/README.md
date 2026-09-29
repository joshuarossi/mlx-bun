# @mlx-bun/module-datasets

Template-driven dataset generation, as an application module
(`AppModule<"jobs" | "storage" | "modelHost">`, design: [Modular application](../../ARCHITECTURE.md#modular-application)).
It declares two routes at their shipped root paths (`GET /api/dataset/templates`,
`POST /api/dataset/submit`), one `dataset` job kind (`task` isolation, `gpu:
"shared"`), one storage entry (`datasets/` under `MLX_BUN_HOME`, one directory per
job) and no verbs, sockets or panel. The mlx-bun app installs it; nothing here
imports an app or another module. The manifest (`src/manifest.ts`) is data.

## Templates and jobs

`src/registry.ts` owns the thirteen template definitions and the 90/10 JSONL
split, `src/generators.ts` the generators (Hugging Face import included), and
`src/routes.ts` template discovery and submission: a submission creates the
job through the host's `jobs` service with `{ template_id, inputs, output_dir,
model_name }` and returns `{ ok, job_id, output_dir }`. The runner
(`src/runner.ts`) runs in the host process. LLM-driven templates lease the served
model through the `modelHost` service's `generate` operation on their first request
and release it when the job ends, so each inference request joins the scheduler
like any client's: the job holds no exclusive GPU lease. Job shutdown aborts
active requests and retry waits, and the host joins the task before closing job
storage.

All thirteen templates are enabled. `verified_code` keeps main's prompt, code
extraction and rows: every extracted program is kept with `metadata.verified`,
`language`, and `verify_error` (a failure's first 400 characters of stderr, else
stdout, or `unverified (<reason>): <diagnostic>`); other languages are not run.
Main ran the code with the host's `python3`. Here `src/python-verifier.ts`
owns the only execution path, `verifyPython(source, signal)`, used by the dataset
job and by `scripts/verify-python.ts`; there is no host-Python fallback, and
verification takes no inference lease.

Each program runs in a new container created with `--pull=never` for linux/arm64
from the digest-pinned image: no network, shared memory, mounts, environment
or log driver; a read-only root with a 16 MiB non-executable `/tmp` tmpfs;
user 65534 with every capability dropped and
`no-new-privileges`; Docker's default seccomp profile; 256 MiB of memory without
swap, 64 processes and one CPU. The program arrives on stdin. The docker CLI
receives only `PATH` and, when set, `DOCKER_HOST`. Fixed limits: 15 s per run,
64 KiB of combined output, 20 s for each create, inspect and remove. The
verifier owns every docker CLI process group and the container: a timeout,
cancellation (job shutdown) or output overflow kills and joins the CLI, then
`docker rm --force` removes the container, since killing the CLI does not stop
it; exit status and OOM come from `docker inspect`. Only a zero exit within every
limit, with removal confirmed, counts as verified. Containers are not created
with `--rm`, because the exit state is read after the program ends; each carries
an `mlx-bun.python-verifier.owner=<hostname>:<pid>` label instead, and a
verifier's first run removes labelled containers whose owner process on this
host is gone, such as those left when the app was killed mid-verification. A missing docker CLI, an
unreachable daemon, a missing or unpinned image, a timeout, cancellation, output
overflow, an OOM kill or an unconfirmed removal leaves `verified: false` with
that reason.

`PYTHON_VERIFIER_IMAGE` pins the linux/arm64 manifest of the official
`python:3.14-slim` image (3.14.7-slim-trixie, read from Docker Hub on
2026-09-27). The verifier never pulls, so a machine without that image leaves
rows unverified (`image-missing`). Provision it once:

```sh
docker pull --platform linux/arm64 python@sha256:67994a05c712036dbfc4385b4bceafc0ce20df950f54b9ea355582c153bf6157
```

To move to a newer image, read its linux/arm64 manifest digest
(`docker buildx imagetools inspect python:3.14-slim`), pull exactly that and
update the constant. An `--image` override without a digest is refused
(`image-unpinned`).

Without Docker Desktop's default socket, set
`DOCKER_HOST=unix://$HOME/.docker/run/docker.sock`. `bun packages/module-datasets/scripts/verify-python.ts
[--image <ref>] [file]` verifies one program by hand (`--help`).

The [lifecycle tests](tests/lifecycle.test.ts) run the module over stand-in core
services (an in-memory job service, a served model, temporary storage) with
synthetic HTTP responses, without a model or download; the app's
[job tests](../../apps/mlx-bun/tests/dataset/lifecycle.test.ts) run it on the real
job host and SQLite store (rows, logs, no GPU lease, shutdown order).
[Generator tests](tests/generation.test.ts) cover the non-LLM generators, the
split and verified_code's row policy, and [verifier tests](tests/python-verifier.test.ts)
drive the container lifecycle against a scripted docker CLI. The opt-in
[Docker acceptance](tests/python-verifier-docker.test.ts)
(`MLX_BUN_TEST_DOCKER_VERIFIER=1 MLX_BUN_TEST_DOCKER_IMAGE=python@sha256:<digest> bun test tests/python-verifier-docker.test.ts`
from this package) runs real containers for pass, fail, a missing image, file, host,
environment, privilege and network isolation, flooding, timeout, cancellation, OOM and
the runner's SIGTERM, and leftover removal, and checks that each container is removed.
It passes on Docker Desktop 29.8.0 (linux/arm64, M1 Max) with the pinned image.

## Not in the module yet

The browser panel (`apps/mlx-bun/src/web/browser/dataset.ts`) stays in the app: it is
written against the app shell's helpers (`api`, `jobStream`, `toast`, `pushToHub`,
the active model) and the static markup in `app.html`, so it does not load without
them. It moves when the web shell package exists, as a `mlx-datasets-panel` custom
element. Pushing a dataset to Hugging Face (`POST /api/dataset/push`) belongs to
publishing.
