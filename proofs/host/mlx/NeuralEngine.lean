namespace Host.Mlx

/-! # The Neural Engine as the platform evaluates our programs

The Neural Engine forwards (prompt pieces of 224 to 2048 rows) run part of
each MLP and of the affine projections on the Apple Neural Engine through our
bridge (packages/inference/native/ane-bridge.m; TypeScript
src/kernels/ane/linear.ts, src/layers/ane-prefill-split.ts). Apple's private
framework (AppleNeuralEngine.framework: `_ANEInMemoryModel` compile, load and
`evaluateWithQoS:options:request:error:`) and the hardware are trusted, like
MLX: `NeuralEngine` names their evaluation of a loaded program on its input
buffers as an uninterpreted operation. Nothing about it is proved.

It is a structure next to `MlxPrefillContract`, not one of its fields: it is
a different trusted component (Apple's framework, compiler and hardware, not
MLX v0.32.2), with its own sources and failure modes, and the decode
statements over `MlxContract` neither use nor assume it.

What the host model of the bridge (another workstream, after a probe) is
expected to supply, per call the route makes (linear.ts:207-240,
ane-bridge.m:239-284):

* `mbane_program_create(mil, 0 weight files, …, inputCount, inputBytes,
  outputBytes, share, …)` (graph construction, the load route): a handle for
  the `AneProgram` it names, with input buffers and an output buffer of the
  declared sizes rounded up to 64 KiB, or `share`'s buffers (and `share`'s
  handle when the program is identical).
* `mbane_input(h, i)`: the base address of input buffer `i`, write-locked;
  `mbane_output(h)`: the output buffer's base address, read-locked.
* `MlxArray.fromPointer` = `mlx_array_new_data_managed_payload(address, shape,
  ndim, float16, 0, free)` on those addresses: an MLX array whose value is the
  buffer's bytes at the time MLX evaluates a reader (zero-copy, not a copy at
  wrap time); the route's Metal kernels (`mlx_bun_ane_trellis_fill*`,
  `mlx_bun_ane_write_half`) write through such an input array, and the output
  wrap is sliced, reshaped and cast by MLX operations.
* `mbane_eval_async(h)`: 1 and the locks released when no evaluation is
  pending (0 otherwise); the evaluation reads the input buffers as they are
  then (the route evaluates every writer before the call and none after).
* `mbane_wait(h, err, n)`: joins the evaluation; with `NeuralEngine.eval prog
  inputs = some out` returns 1 and the output buffer's first
  `prog.outputBytes` bytes are `out`; with `none` returns 0 and writes the
  error text.
* `mbane_free(h)` (dispose only): releases a holder. -/

/-- A program as `mbane_program_create` receives it: the MIL text, the weight
files it embeds (name, blob bytes; none on the route, whose programs stream
every weight through an input), the input buffers' byte sizes in MIL symbol
order (input names sorted: wd, wg, wu, x for an MLP slice; w, x for a
streamed matmul) and the output buffer's. -/
structure AneProgram where
  mil : List Char
  weights : List (List Char × List Nat)
  inputBytes : List Nat
  outputBytes : Nat
deriving DecidableEq

/-- An IOSurface buffer's contents: the byte at each offset. -/
abbrev Surface := Nat → Nat

/-- The Neural Engine platform: Apple's framework, its compiler's compiled
model for the program and the hardware's evaluation. -/
structure NeuralEngine where
  /-- `evaluateWithQoS:options:request:error:` of the loaded program `prog`
  (the bridge's `run`): the output buffer's first `prog.outputBytes` bytes
  from the input buffers' contents in MIL symbol order, or `none` when the
  framework reports an error. -/
  eval : AneProgram → List Surface → Option Surface

end Host.Mlx
