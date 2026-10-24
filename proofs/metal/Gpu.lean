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

/-- Buffer `i`'s contents after a run, within its size (inputs first, then outputs). -/
def final (r : Result) (inputs : List Buffer) (sizes : List Nat) (i : Nat) : ByteMemory.Bytes :=
  fun b => if b < ((inputs.map (·.size) ++ sizes)[i]?.getD 0) then r.buffers i b else 0

/-! # The GPU assumption

The one premise about GPU execution, for every program. MLX compiles the
preamble followed by `text` and dispatches it with `dispatchThreads(grid,
min(tg, grid))` on the input buffers and fresh output buffers. If the model's
run of `compile text` completes — no undefined behavior, no divergent barrier
or collective — race-free, and leaves the same contents in a set `S` of the
launch's buffers whatever the unwritten memory holds, then the GPU leaves those
contents in those buffers. `S` is usually the outputs; a kernel that writes
through an input (a zero-copy wrap of shared memory) includes that input.

The backend's choice to fuse each contraction site of the compiled program
is the hardware's (`fusion`); kernel theorems hold for every choice. The
operations themselves are those of `C`. Output buffers are fresh MLX allocations
(`allocator::malloc`, Metal buffers whose base is at least 16-byte aligned). The threadgroup must fit the compiled
pipeline's limit (`maxThreads`), which MLX checks (custom_kernel.cpp:84-91). -/
structure Gpu (C : M1Max.Contract) where
  /-- Every buffer's contents after the launch, inputs then outputs. -/
  executeAll : (text : List Char) → (grid threadgroup : Nat × Nat × Nat) → (inputs : List Buffer) →
    (sizes : List Nat) → Option (List ByteMemory.Bytes)
  maxThreads : List Char → Nat
  fusion : List Char → Nat → Bool
  runs_as_modeled : ∀ text kernel grid threadgroup inputs sizes (S : Nat → Prop) (out : Nat → ByteMemory.Bytes),
    compile text = some kernel →
    threadgroup.1 * threadgroup.2.1 * threadgroup.2.2 ≤ maxThreads text →
    (∀ (initial : Nat → ByteMemory.Bytes) (garbage : Garbage), ∃ fuel rounds barriers r,
      runLaunch C (fusion text) ⟨kernel, grid, threadgroup, buffers inputs sizes 16 initial⟩ garbage
        fuel rounds barriers = some r ∧
      RaceFree ⟨kernel, grid, threadgroup, buffers inputs sizes 16 initial⟩ r ∧
      ∀ i, S i → final r inputs sizes i = out i) →
    ∃ res, executeAll text grid threadgroup inputs sizes = some res ∧
      res.length = inputs.length + sizes.length ∧ ∀ i (h : i < res.length), S i → res[i] = out i

/-- The outputs of a launch: the arrays MLX returns. -/
def Gpu.execute {C : M1Max.Contract} (G : Gpu C) (text : List Char) (grid threadgroup : Nat × Nat × Nat)
    (inputs : List Buffer) (sizes : List Nat) : Option (List ByteMemory.Bytes) :=
  (G.executeAll text grid threadgroup inputs sizes).map (·.drop inputs.length)

theorem final_output (r : Result) (inputs : List Buffer) (sizes : List Nat) (j : Nat) (hj : j < sizes.length) :
    final r inputs sizes (inputs.length + j) = (outputs r inputs.length sizes).getD j 0 := by
  have hs : (inputs.map (·.size) ++ sizes)[inputs.length + j]?.getD 0 = sizes[j] := by
    rw [List.getElem?_append_right (by simp)]
    simp [hj]
  have ho : (outputs r inputs.length sizes)[j]? =
      some (fun b => if b < sizes[j] then r.buffers (inputs.length + j) b else 0) := by
    simp [outputs, List.getElem?_zipIdx, List.getElem?_eq_getElem hj]
  funext b
  rw [List.getD_eq_getElem?_getD, ho]
  simp [final, hs]

/-- The assumption for the outputs alone. -/
theorem Gpu.runs_as_modeled_outputs {C : M1Max.Contract} (G : Gpu C) :
    ∀ text kernel grid threadgroup inputs sizes out,
    compile text = some kernel →
    threadgroup.1 * threadgroup.2.1 * threadgroup.2.2 ≤ G.maxThreads text →
    (∀ (initial : Nat → ByteMemory.Bytes) (garbage : Garbage), ∃ fuel rounds barriers r,
      runLaunch C (G.fusion text) ⟨kernel, grid, threadgroup, buffers inputs sizes 16 initial⟩ garbage
        fuel rounds barriers = some r ∧
      RaceFree ⟨kernel, grid, threadgroup, buffers inputs sizes 16 initial⟩ r ∧
      outputs r inputs.length sizes = out) →
    G.execute text grid threadgroup inputs sizes = some out := by
  intro text kernel grid threadgroup inputs sizes out hc hmax h
  -- Every run's outputs are `out`; in particular `out` has one entry per output.
  have hlen : out.length = sizes.length := by
    obtain ⟨_, _, _, r, _, _, ho⟩ := h (fun _ => 0) ⟨fun _ _ => 0, fun _ _ => 0⟩
    rw [← ho]; simp [outputs]
  let O : Nat → ByteMemory.Bytes := fun i => out.getD (i - inputs.length) 0
  obtain ⟨res, he, hl, hr⟩ := G.runs_as_modeled text kernel grid threadgroup inputs sizes
    (fun i => inputs.length ≤ i) O hc hmax (by
      intro initial garbage
      obtain ⟨fuel, rounds, barriers, r, hrun, hrf, ho⟩ := h initial garbage
      refine ⟨fuel, rounds, barriers, r, hrun, hrf, fun i hi => ?_⟩
      obtain ⟨j, rfl⟩ : ∃ j, i = inputs.length + j := ⟨i - inputs.length, by omega⟩
      by_cases hj : j < sizes.length
      · rw [final_output r inputs sizes j hj, ho]
        simp only [O, Nat.add_sub_cancel_left]
      · funext b
        have hs : (inputs.map (·.size) ++ sizes)[inputs.length + j]?.getD 0 = 0 := by
          rw [List.getElem?_append_right (by simp)]
          simp [show sizes.length ≤ j by omega]
        simp only [final, hs, Nat.not_lt_zero, ite_false, O, Nat.add_sub_cancel_left]
        rw [List.getD_eq_default _ _ (by omega)]; rfl)
  unfold Gpu.execute
  rw [he, Option.map_some]
  congr 1
  apply List.ext_getElem
  · simp [hl, hlen]
  · intro j h1 h2
    rw [List.getElem_drop]
    rw [hr _ (by simp at h1; omega) (by omega)]
    simp only [O, Nat.add_sub_cancel_left]
    rw [List.getD_eq_getElem _ _ h2]

end Metal
