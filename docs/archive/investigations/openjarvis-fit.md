# OpenJarvis research and fit with mlx-bun

Inspected September 8, 2026. OpenJarvis source revision
[`e25e77d36ee487aa456978e7a7f19a7f6d712260`](https://github.com/open-jarvis/OpenJarvis/tree/e25e77d36ee487aa456978e7a7f19a7f6d712260).
mlx-bun revision `673b43f39b88d8f6438e625aaaceca00851d0fbf`.
This is a source/documentation review, not a reproduced benchmark or a verified
live integration. No servers, model downloads, inference, or training ran.

OpenJarvis is useful both as a possible consumer of mlx-bun and as prior work
for the local adaptation research. Its most useful architectural idea is a
versioned configuration that can be evaluated and changed across model,
agent, tools, memory, and runtime settings. mlx-bun already supplies several
of those components. The remaining opportunity is to connect them through
replayable task evidence and controlled updates.

## What the diagram means for this project

The [architecture documentation][architecture] separates five configurable
components. Interfaces and hardware surround them. The table maps those
roles to documented mlx-bun capabilities; it does not claim identical scope.

| OpenJarvis component | Existing mlx-bun contribution | Work above or around the engine |
|---|---|---|
| Intelligence | Supported model graphs, model discovery, quantization and adapters | Task-aware model/adapter selection, with measured loading and switching costs |
| Engine | Native MLX inference, HTTP serving, TypeScript library, caching and batching | An OpenJarvis compatibility check and an adapter for richer runtime measurements |
| Agents | Built-in Pi and integration with an external Pi | Compare task loops, including bounded RLM, outside numerical inference code |
| Tools and memory | Pi tools, embeddings, personal Markdown wiki and synthesis | Common tool contracts, evidence provenance and replayable memory snapshots |
| Learning | LoRA SFT/DPO/ORPO training and adapter serving | Verified data collection, candidate evaluation, retention tests and promotion |
| User interfaces | CLI and browser application | Messaging/desktop integrations only when a concrete workload needs them |

Local sources: [CLI](../../reference/cli.md),
[library API](../../reference/library-api.md),
[server API](../../reference/server-api.md),
[memory](../../reference/memory.md), [training](../../reference/training.md).
The Dreaming is memory synthesis, not weight training. Its current
[`runPipeline`](../../../src/memory/pipeline.ts) assumes conversations are
already ingested; closing that ingestion gap remains existing work.
Serving a model does not imply its architecture supports every training path.

## RLM implementation and its limits

OpenJarvis includes a concrete [`RLMAgent`][rlm] with a persistent Python
[`RLMRepl`][repl]. It installs external context in a variable, executes
model-written code, exposes `llm_query` and `llm_batch`, and can return an
answer through `FINAL`, `FINAL_VAR`, or the `answer` dictionary.

This is a useful reference for the bounded external-context experiment in
the existing `harness_research/RESEARCH_PROGRAM.md`. It belongs in the task
execution loop. A separate optimizer could improve its prompt, decomposition
rules or tool configuration over time.

The inspected implementation has several details an experiment must account for:

- `llm_batch` runs subqueries sequentially. Its name does not imply engine
  batching or parallel execution.
- Subqueries call `engine.generate` directly and can resolve one round of
  returned tool calls. They do not create child REPL agents. This path should
  not be described as arbitrary-depth recursive RLM execution.
- `AgentResult.metadata` accumulates root-call usage. `_make_sub_query`
  returns text and does not add leaf or follow-up usage to that accumulator.
  Measure every backend request independently for whole-task accounting.
- Root turns and per-call output tokens have limits, but these methods do not
  impose one shared subcall/token/deadline budget. A single REPL program can
  request many leaves. Enforce shared admission limits in a request broker.
- The REPL checks prohibited substrings and then invokes in-process Python
  `exec`. Output truncation happens after execution. These mechanisms are not
  process isolation or a hard execution/memory deadline. The project has
  separate sandbox facilities; a benchmark must explicitly select isolation
  and keep authoritative evaluation data outside the candidate environment.
- `_resolve_context` reads `AgentContext.metadata["context"]` or memory
  results, while the normal user input still enters the root prompt.
  Put the large corpus in the external-context field, not the user question.
  Existing conversation messages are also retained by
  [`BaseAgent._build_messages`][base-agent].

The appropriate comparison remains retrieval versus an external-context
REPL without subcalls versus bounded depth-1 RLM, on dense document
aggregation. Small lookup tasks establish connectivity but give weak
evidence about RLM's value. On a serial Mac GPU, extra model calls can erase
the benefit of smaller contexts; measure complete tasks.

## Self-improvement is several separate implementations

| Mechanism | What the inspected source establishes |
|---|---|
| Learned routing | [`LearnedRouterPolicy`][routing] maps coarse query classes to models using trace outcomes and feedback. This is distinct from training language-model weights. |
| Configuration search | [`SpecSearchOrchestrator`][search] connects diagnosis, typed edit planning, execution, evaluation and recording. Runtime dependencies must be supplied. |
| Candidate gate | [`BenchmarkGate`][gate] compares overall score and per-cluster regressions using a versioned benchmark and repeatable subsample seed. |
| Weight training | [`SFTTrainer`][sft] delegates LoRA training to a separate trainer. [`GRPOTrainer`][grpo] contains a Torch/Transformers training loop with policy and reference models. Neither was executed in this review. |
| Weight updates inside spec search | [`LoraStubApplier`][lora-stub] rejects `LORA_FINETUNE` and raises `NotImplementedError` if applied. Separate trainers do not establish an integrated spec-search training cycle. |

The [spec-search guide][search-guide] describes a teacher diagnosing local
student failures and proposing changes. Its quickstart uses fake
teacher/student/judge components. It illustrates the orchestration, not
measured improvement by a deployed learning system.

There is documentation drift worth preserving in a reproduction. The guide's
gate predicate requires improvement on the targeted failure cluster. The
inspected `BenchmarkGate.evaluate` instead requires improvement in overall
score and rejects excessive per-cluster regressions; it receives no target
cluster argument. Its constructor defaults to a 0.05 regression allowance,
while the guide's configuration uses 0.01. `from_config` forwards the supplied
value. Pin the actual configuration and predicate instead of assuming that
the prose, constructor defaults, and configured execution are interchangeable.

The [learning architecture page][learning] also describes older router names
and a GRPO router stub. Current learned routing is consolidated in
`learning/routing/learned_router.py`, while the separate intelligence GRPO
trainer has implementation code. A blanket claim that "GRPO is a stub"
would therefore be misleading.

The [paper][paper] is close prior work for the research program: it studies
typed specifications and teacher-guided edits across several components,
with local inference after search. Its reported experiments span multiple
models and hardware classes, including Macs and larger workstations.
They do not establish the same gains on our M1 Max or M4 Pro, or prove that
the checked-out code reproduces every reported experiment. Its acknowledged
limitations include judge bias, statistical precision and search convergence.
We should reproduce a bounded comparison before adopting performance claims.

## Integration path

The current [engine registry][engines] already registers `MLXEngine` through
the shared [`_OpenAICompatibleEngine`][http-engine]. That class accepts a
host URL, probes `/v1/models`, and calls `/v1/chat/completions`. The generic
`OpenAICompatEngine` offers the same interface for explicit endpoints.
This makes using mlx-bun as the inference backend a plausible small
integration, without importing OpenJarvis into the inference engine.

For a future smoke test, construct the generic engine with mlx-bun's origin
URL, without `/v1`, and choose the exact model ID from `list_models()`.
Check plain completion, tool-call round trips, streaming completion/error
handling, cancellation, reasoning output, model identity and usage against
raw HTTP responses. This review did not perform that test.

Two adapter behaviors need special attention:

- Synchronous generation retries a tool-bearing HTTP 400 without `tools`
  and `tool_choice`. A successful retry does not establish tool compatibility.
- It takes the maximum of reported prompt tokens and an estimate, and labels
  reported prompt tokens as `prompt_tokens_evaluated`. Those fields cannot
  establish actual prefill work or cache reuse. Retain raw server measurements.

Use HTTP for the first comparison. A direct TypeScript implementation can
later use mlx-bun's library if measured requirements justify it.

## Recommended direction

Keep mlx-bun responsible for inference correctness, resource management,
training execution and adapter lifecycle. Keep experimental task loops and
the process that changes them in `harness_research` initially. Use the same
backend for Pi, a controlled loop and OpenJarvis comparisons.

The next useful steps extend the existing research program:

1. Complete the already proposed repeated-failure-feedback experiment in
   `harness_research/NEXT_EXPERIMENT.md`. OpenJarvis strengthens the case for
   including both a prompt-only comparison and executable loop changes.
2. Define an immutable run identity covering model artifact, quantization,
   adapter, agent code, prompts, tools, memory snapshot, runtime settings,
   task revision and evaluation revision. Record all root/leaf/teacher calls.
3. Add an OpenJarvis baseline through HTTP after the compatibility checks.
   Preserve its full configuration and raw request trace.
4. Run the separate RLM ablation with one shared request budget, isolated
   execution and serial GPU admission. Include forced finalization in costs.
5. Introduce typed candidate edits, frozen evaluation and rollback. Start with
   bounded prompt/tool/loop changes before searching many dimensions together.
6. Connect verified examples to existing LoRA training only after the fixed
   task loop is measurable. Compare frozen, controller-only, adapter-only and
   combined adaptation, including retention and collection/training/eval cost.

Personal memory, task scratch state, training data and learned adapters need
separate identities. A useful memory article is not automatically a training
example, and a plausible answer is not automatically a verified success.
Background synthesis, judging and training all consume the same Mac budget.
The existing serialized scheduling proposal remains appropriate for the first
study; this research supplies no evidence for concurrent training and serving.

The opportunity is a local system that improves verified task outcomes while
remaining usable on a personal Mac. OpenJarvis provides a close comparison
and concrete implementation ideas. Our differentiator must be demonstrated
through that complete operating loop, including its costs and failures.

[architecture]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/docs/architecture/overview.md
[learning]: https://open-jarvis.github.io/OpenJarvis/architecture/learning/
[paper]: https://arxiv.org/html/2605.17172v1
[rlm]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/agents/rlm.py
[repl]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/agents/rlm_repl.py
[base-agent]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/agents/_stubs.py
[routing]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/learning/routing/learned_router.py
[search]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/learning/spec_search/orchestrator.py
[gate]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/learning/spec_search/gate/benchmark_gate.py
[sft]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/learning/intelligence/sft_trainer.py
[grpo]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/learning/intelligence/grpo_trainer.py
[lora-stub]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/learning/spec_search/execute/appliers/lora_stub.py
[search-guide]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/docs/user-guide/llm-guided-spec-search.md
[engines]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/engine/openai_compat_engines.py
[http-engine]: https://github.com/open-jarvis/OpenJarvis/blob/e25e77d36ee487aa456978e7a7f19a7f6d712260/src/openjarvis/engine/_openai_compat.py
