import metal.Elab
import metal.Frontend
import metal.Launch

namespace Metal
open Core Inference.Contracts.Mlx

/-- The model of a compiled kernel: MLX's assembled source text (what follows
the `metal::utils()` preamble) through the frontend and elaboration. -/
def compile (text : List Char) : Option Kernel := (frontend text).bind elaborate

/-- MLX's buffers for a launch: the inputs, then the outputs (fresh device
allocations of the given sizes, with contents `initial` — MLX does not
initialize them, custom_kernel.cpp:24-31 — and base alignment `align`). -/
def buffers (inputs : List Buffer) (sizes : List Nat) (align : Nat) (initial : Nat → ByteMemory.Bytes) : List Buffer :=
  inputs ++ sizes.zipIdx.map fun (size, i) => ⟨.device, size, align, initial i⟩

/-- The outputs' contents after a run, within their sizes. -/
def outputs (r : Result) (inputs : Nat) (sizes : List Nat) : List ByteMemory.Bytes :=
  sizes.zipIdx.map fun (size, i) b => if b < size then r.buffers (inputs + i) b else 0

/-! # The GPU assumption

The one premise about GPU execution, for every program. MLX compiles the
preamble followed by `text` and dispatches it with `dispatchThreads(grid,
min(tg, grid))` on the input buffers and fresh output buffers. If the model's
run of `compile text` completes — no undefined behavior, no divergent barrier
or collective — race-free, with the same outputs whatever the unwritten
memory holds, then the GPU produces those outputs.

The backend's choice to fuse each contraction site of the compiled program
is the hardware's (`fusion`); kernel theorems hold for every choice. The
operations themselves are those of `C`. Output buffers are fresh MLX allocations
(`allocator::malloc`, Metal buffers whose base is at least 16-byte aligned). The threadgroup must fit the compiled
pipeline's limit (`maxThreads`), which MLX checks (custom_kernel.cpp:84-91). -/
structure Gpu (C : M1Max.Contract) where
  execute : (text : List Char) → (grid threadgroup : Nat × Nat × Nat) → (inputs : List Buffer) →
    (sizes : List Nat) → Option (List ByteMemory.Bytes)
  maxThreads : List Char → Nat
  fusion : List Char → Nat → Bool
  runs_as_modeled : ∀ text kernel grid threadgroup inputs sizes fuel rounds barriers out,
    compile text = some kernel →
    threadgroup.1 * threadgroup.2.1 * threadgroup.2.2 ≤ maxThreads text →
    (∀ (initial : Nat → ByteMemory.Bytes) (garbage : Garbage), ∃ r,
      runLaunch C (fusion text) ⟨kernel, grid, threadgroup, buffers inputs sizes 16 initial⟩ garbage
        fuel rounds barriers = some r ∧
      RaceFree ⟨kernel, grid, threadgroup, buffers inputs sizes 16 initial⟩ r ∧
      outputs r inputs.length sizes = out) →
    execute text grid threadgroup inputs sizes = some out

end Metal
