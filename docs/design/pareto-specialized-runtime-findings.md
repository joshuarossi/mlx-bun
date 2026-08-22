# Pareto-specialized runtime findings

## Question

Which parts of mlx-bun should converge on shared infrastructure, and which parts should remain deliberately specialized so cleanup does not turn the runtime into a lowest-common-denominator model host?

This note compares three mature specialization clusters: the Colibri/GLM-5.2 runtime, the Qwen3.8 27B TurboQuant and MTP work, and ORPO training. The evidence says the same thing in all three places: share lifecycle and composition policy, but keep artifact layout and numerical work close to the model or method that owns them.

## Shared control-plane infrastructure

The shared layer decides what runs, owns resources, and records what happened. It does not rewrite the selected computation.

- **Model construction.** `openModel()` recognizes the direct Colibri artifact before ordinary safetensors loading. `createModel()` prefers dedicated and fingerprint-generated model classes before the universal fallback, and explicitly says the generic path must not shadow a dedicated port. This is shared dispatch with specialized implementations, not one universal graph. [Factory dispatch](../../src/model/factory.ts#L30-L150)
- **Concurrency and request composition.** The target is one concurrency-driven engine. One active request uses the B=1 pipelined or compiled fast path; concurrent requests use the general step up to `--batch N`. B=1 is an internal specialization, not a permanent public lane. Features are stackable layers, and scheduling must not replace the selected KV scheme, adapter, draft method, grammar, or sampler. [Unified engine decision](unified-engine-frontier-plan.md#L333-L403) [Composition matrix](unified-engine-frontier-plan.md#L405-L424)
- **Cache lifecycle and capability.** `Cache` owns update, masks, state, rollback, accounting, and disposal. `BatchableCache` adds row merge, extraction, filtering, and byte projection. The scheduler can depend on those capabilities without knowing whether a row contains ordinary KV, recurrent state, TurboQuant tensors, or compressed GLM state. [Cache interface](../../src/model/gemma4-base.ts#L264-L303) [Batchable cache interface](../../src/model/gemma4-base.ts#L347-L357)
- **Resolved KV policy.** `KvScheme` preserves bf16, uniform affine, per-layer affine, and TurboQuant as distinct immutable schemes. It centralizes names, accounting, and current batch capability checks without pretending the schemes have identical storage or kernels. [KV scheme](../../src/kv-scheme.ts#L84-L169)
- **Draft lifecycle.** `DraftProvider` owns server-lifetime machinery and opens a request-scoped `DraftSource`. The source interface carries prompt mode, target taps, draft, commit, rollback-related cache state, and disposal. Assistant, DSpark, Qwen MTP, and native GLM MTP can share speculative orchestration while retaining different state transitions. [Draft source](../../src/spec/source.ts#L31-L101) [Draft provider](../../src/spec/source.ts#L103-L118)
- **Expert residency policy.** The budget equation, stable expert union, lease state, backend contract, telemetry, and pressure correction are reusable. GLM supplies artifact geometry and byte segments to that policy. [Residency planning and union](../../src/expert-residency.ts#L17-L155) [Residency backend](../../src/expert-residency.ts#L157-L170)
- **Offline transform orchestration.** `WeightTransform` separates name/config planning from lazy tensor application. Llama, the Qwen3.5 trunk, and Qwen MTP are real adapters over the same conversion seam. [Weight transform interface](../../src/quantize/weight-transform.ts#L40-L51) [Qwen transform adapters](../../src/quantize/weight-transform.ts#L244-L268)
- **Training orchestration.** `TrainConfig` names independent techniques such as segmented backward, fused or flash CCE, prefix sharing, regularization, and ORPO semantics. `orpoLoop()` composes the selected techniques and chooses the model-specific backward implementation. [Training configuration](../../src/train/trainer.ts#L42-L150) [ORPO composition](../../src/train/trainer.ts#L821-L948)

## Deliberately specialized data-plane code

### Colibri and GLM-5.2

GLM-5.2 is not a descriptor-table variation of a dense transformer. Its graph has MLA, DSA, shared plus routed MoE, native MTP, and compressed cache state. Its public artifact also has a dedicated container and streamed expert layout. The design therefore calls for a dedicated `Glm52Model`, direct artifact support, and a one-read routed-expert kernel rather than repacking into generic projection-major tensors. [Dedicated graph and artifact contract](colibri-glm52-port.md#L323-L357)

The memory contract is also model and artifact specific. A header-only preflight reads the container, derives expert slot layouts, counts DSA and MTP state, and refuses startup when the exact resident weights, expert slabs, compressed KV, verification transients, allocator reserve, Bun reserve, and safety margin exceed the process limit. [GLM geometry and preflight](../../src/model/glm52-memory.ts#L340-L500) The runtime then maps Colibri segments into generic residency leases, but retains GLM-specific slot layouts, MTP slabs, signed-int8 requirements, and routed-SwiGLU executors. [GLM residency binding](../../src/model/glm52-residency.ts#L138-L230) [GLM executor construction](../../src/model/glm52-residency.ts#L300-L459)

That split is intentional. Bun owns residency policy and observability; the native helper owns aligned slabs, `pread`, wiring, and completion fences; the GLM model owns tensor semantics and kernels. [Ownership map](colibri-glm52-port.md#L580-L600)

### Qwen3.8 27B, TurboQuant, and MTP

Qwen3.5/3.8 keeps a dedicated graph because gated DeltaNet recurrence, full attention, MRoPE, output gates, and recurrent speculative rollback are numerical behavior, not configuration decoration. [Qwen graph](../../src/model/qwen3_5.ts#L128-L322) [Qwen model interface](../../src/model/qwen3_5.ts#L512-L673)

Qwen MTP preserves its own artifact and state machine behind `DraftProvider` and `DraftSource`. The provider rejects a non-Qwen target or a hidden-size mismatch. The request source uses tapped pre-final-norm target state, maintains its own KV, samples through the target sampler, and rebuilds accepted rows from verified target hiddens. Those rules must not move into generic speculative orchestration. [Qwen MTP provider](../../src/spec/qwen-mtp-source.ts#L193-L235) [Qwen MTP state machine](../../src/spec/qwen-mtp-source.ts#L237-L430)

TurboQuant KV demonstrates the right form of specialization. `TurboQuantKVCache` implements the shared `Cache` lifecycle, while keeping packed indices, scales, zero points, FWHT-domain values, supported head dimensions, and conversion rules inside the class. [TurboQuant cache](../../src/model/gemma4-base.ts#L1539-L1800) The weight pipeline follows the same rule. `WeightTransform` is shared, but the Qwen corridor map preserves the output gate, recurrent internals, vision-to-residual seam, untied 27B head, and companion MTP basis. [Qwen transform seam](turboquant-weights.md#L80-L87) [Qwen corridor map](turboquant-weights.md#L125-L174)

### ORPO training

ORPO benefits from composition, not one generic backward. The trainer combines prefix sharing, segmented recomputation, fused or flash CCE, LoRA regularization, and objective semantics. The data plane remains specialized where the model topology demands it. Gemma4 segmented ORPO threads per-layer inputs and cross-segment donor KV cotangents; MiniCPM5 uses a simpler segment graph. [Composed ORPO paths](orpo-training.md#L178-L218) [Gemma4 segmented backward](../../src/train/segmented.ts#L1137-L1471)

Flash CCE is a shared quantized-head interface with specialized Metal kernels and explicit shape guards. Its implementation selects Steel, simdgroup, or scalar kernels from actual hidden, vocabulary, group, and tile geometry, and exposes exact-gradient escape hatches. Flattening this into a generic matrix-loss helper would lose the memory and watchdog constraints that justify it. [Flash CCE head](../../src/train/flash-cce.ts#L42-L64) [Forward dispatch](../../src/train/flash-cce.ts#L1033-L1132) [Backward dispatch](../../src/train/flash-cce.ts#L1134-L1234)

Dynamic lambda is not implemented. Its design belongs in the ORPO control plane: validation metrics update a live lambda source in `orpoLoop()`, while every monolithic and segmented loss reads the same value. It should not create another family of backward classes. [Dynamic-lambda status and signals](orpo-dynamic-lambda.md#L1-L27) [Proposed wiring](orpo-dynamic-lambda.md#L163-L180)

## Interfaces that already preserve specialization

| Interface | Shared invariant | Specialization retained behind it |
|---|---|---|
| `RuntimeModel` plus factory dispatch | Construction and serving can hold one model type | Dedicated GLM, Qwen, Gemma, diffusion, MoE, and generated graphs |
| `Cache` / `BatchableCache` | Lifecycle, rollback, row operations, byte projection | Plain, rotating, quantized, TurboQuant, SSM, MLA, and DSA storage |
| `KvScheme` | One resolved KV choice and stable identity | Per-scheme accounting, conversion, persistence, and kernels |
| `DraftProvider` / `DraftSource` | Request lifecycle, target taps, draft and commit | Assistant, DSpark, Qwen MTP, and GLM MTP state machines |
| `ExpertResidencyBackend` | Lease and I/O lifecycle | Colibri container offsets, slot packing, expert kernels, and prediction policy inputs |
| `WeightTransform` | Plan first, apply lazily, record identity | Family-specific exact fold corridors and companion artifacts |
| ORPO trainer configuration | One run composes selected techniques | Model-specific masks, donor topology, VJPs, and Metal kernels |

## Declared profile seam (S2, 2026-08-21)

Model construction now resolves one `ResolvedModelProfile` before opening
weights. An exact artifact declaration binds an immutable external fingerprint,
config fingerprint, fidelity contract, required engine capabilities, and a
loader/graph/loop composition. Exact Qwen3.8 OptiQ and GLM-5.2 Colibri revisions
are pinned; other supported artifacts retain dedicated family resolution and
then the universal dense fallback.

The factory consumes the resolved composition, and the serving context retains
it for library callers. A matched exact declaration with a config or capability
mismatch refuses rather than taking another route. The profile seam does not
own request methods: MTP, KV schemes, adapters, grammar, and sampling remain
independently resolved inputs to completion execution. This keeps the control
plane declarative without turning a model profile into a feature preset.

These interfaces preserve specialization because they describe lifecycle or capability, not tensor algebra. They also have multiple real implementations. That is the useful test for whether an abstraction belongs.

## Rules for steady-state cleanup

1. **Unify control, not math.** Centralize admission, concurrency, cancellation, ownership, accounting, persistence, telemetry, and technique composition. Keep tensor layout, recurrence, cache encoding, model topology, and kernel selection with their owning model, artifact, or method.
2. **Keep one concurrency-driven engine.** B=1 and B>1 are internal step specializations in one engine. `--batch N` is a concurrency cap. Observed placement may be reported, but serial versus batch must not become a permanent public mode or feature-selection interface. Current feature-specific serial routing is capability debt.
3. **Never weaken a resolved composition to fit a path.** If batching lacks TurboQuant, MTP, adapters, grammar, or another selected method, close that capability gap or reject the unsupported composition. Do not silently substitute bf16 KV, disable drafting, or change sampling.
4. **Prefer capability interfaces over family checks.** Scheduling should ask caches whether they can merge or project bytes and draft sources what target state they require. Factory dispatch is the proper place for model identity checks.
5. **Let dedicated ports outrank generic fallbacks.** The universal model path is valuable for ordinary architectures. It must not absorb GLM MLA/DSA, Qwen recurrence, artifact-specific MTP, or another optimized graph merely to reduce class count.
6. **Treat artifacts as executable contracts.** Validate manifests, tensor families, layouts, quantization metadata, companion seeds, and memory equations before allocation. Keep artifact-specific loaders and transforms when repacking would add copies, lose reproducibility, or change arithmetic.
7. **Generalize only after the invariant is visible in two implementations.** Extract lifecycle and capability seams such as `DraftSource` or `WeightTransform`. Do not extract a common tensor algorithm from code that only looks similar but has different masks, state, accumulation order, or oracle.
8. **Compose optimizations at the orchestrator, then test the cross-product.** ORPO proves that prefix sharing, flash CCE, segmented backward, and regularization can stack while model-specific backward code remains intact. Serving needs the same discipline for model graph, KV scheme, MTP, adapters, grammar, sampling, and concurrency.
9. **Bind every specialized path to its own oracle and measured purpose.** A specialized module earns its place through parity, memory, quality, or throughput gates on the artifact and hardware it targets. If the benefit disappears, delete the specialization instead of preserving it as architecture folklore.

## Strongest conclusion

The steady state is not a generic engine with scattered exceptions. It is a shared control plane that carries authoritative compositions through one concurrency-driven engine, plus specialized data planes selected by model, artifact, and numerical method. That structure preserves the project's Pareto advantage: common serving and training behavior where sameness is real, and unapologetically specific code where the result depends on it.
