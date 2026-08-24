# mlx-bun serving

mlx-bun serving runs local model completions and reports how each request uses the inference runtime.

## Language

**Completion execution**:
A single model completion attempt, including its generated output, resource lifetime, usage accounting, and observed scheduling placement.
_Avoid_: Generation request, serve transaction

**Execution composition**:
The exact combination of model runtime, numeric scheme, acceleration methods, and request features used for a workload. Explicit choices and resolved defaults are authoritative.
_Avoid_: Configuration bundle, inferred mode

**Model profile**:
A declaration that identifies an external model artifact, the engine capabilities required to run it, and the measured execution composition recommended for a device or workload. The profile does not bundle or own the model weights.
It selects model construction; request methods such as MTP, KV schemes, adapters, grammar, and sampling remain independent explicit or default-resolved choices.
_Avoid_: Generic model preset

**Fidelity contract**:
The oracle and verification claim attached to an execution composition, such as bit-exact parity with an external implementation or measured evidence when no matching oracle exists.
L1 means bit-exact mlx-lm parity, L2 means bit-exact mlx-optiq parity, and L3 means measured evidence without a matching oracle.
_Avoid_: Execution mode, optimization tier

**Artifact fingerprint**:
An immutable external revision identity used to bind evidence and a model profile to exact weights and metadata. A mutable alias or local directory name is not an artifact fingerprint.
_Avoid_: Model path, model family

**Scheduling mechanism**:
The executor that receives an already-resolved execution composition. `serial` is the preserved strict or dedicated executor. `continuous` admits the request to the scheduler, which chooses a B=1 fast path or B=N step from its active row count. Placement never changes the composition.
_Avoid_: Inferred lane, inferred mode

**Concurrency cap**:
The maximum rows admitted to the continuous scheduler. `--batch` declares this cap; `1` pins the serial mechanism. It does not select MTP, a KV scheme, TurboQuant, grammar, adapters, or sampling.
_Avoid_: Batch method, quality mode

**B=1 fast path**:
The continuous scheduler's one-active-row specialization. It adopts serial-class caches and uses the parity- and latency-gated single-row graph. It is not the strict serial mechanism selected by `--batch 1` or required by a dedicated composition.
_Avoid_: Serial fallback, batch prediction
