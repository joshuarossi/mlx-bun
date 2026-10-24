import host.simgraph.family.KernelSlot
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Ts Inference.Contracts.Mlx

/-! # The folded read's host arrays

folded-attention.ts builds two int32 arrays from host numbers at `N = o + r`
keys, `L = r` queries and `rep = 6` query heads a KV head:

* `limits = ops.fromInt32(Array.from({ length: rep·L }, (_, row) => N − L + (row mod L)), [rep·L, 1])`;
* `cols = ops.arange(0, N, 1, int32)` (ops.ts `arange`): below `N = 65536` an
  `Int32Array` with `data[i] = i` through `MlxArray.fromInt32`, from 65536 on
  the native `mlx_arange` of `N` elements (cached by `start|step|n|dtype`)
  sliced to `[0, N)`.

The template run cannot build these at a symbolic `N` (the loop's trip count
and the cells are dimensions), so, as the prompt ids' bridge B-newdata exports
the bytes `mlx_array_new_data` received, the forward stage supplies the
iteration's nodes as host-side facts: `HostInt32` (an `Int32Array` through
`mlx_array_new_data`) and `HostArange` (the native range's slice). From them:

* `folded_limits`: the limits node holds the folded read's input
  `cells p 1` (`auxKey R (.folded r) p 1`);
* `folded_cols_data`, `folded_cols_arange`: the cols node holds its input
  `iota p 2` (`auxKey R rd p 2`), on either path. -/

/-- `MlxArray.fromInt32(new Int32Array(cs), sh)` as `mlx_array_new_data`
records it in the iteration's state `t`: node `j` is an int32 data node whose
bytes resolve to the cells `cs` and whose shape to `sh`. -/
def HostInt32 (Nn : Nums Int) (t : Ffi.St) (j : Nat) (cs sh : List Int) : Prop :=
  ∃ bytes shape, t.nodes.get j = some ⟨.data bytes, [], shape, Ffi.dtInt32⟩ ∧
    bytes.mapM Nn.byte = some (cellsBytes cs) ∧ shape.mapM Nn.d = some sh

/-- ops.ts `arange(0, N, 1, int32)` at `N ≥ 65536`: node `j` is the slice
`[0, N)` (unit stride) of node `a < j`, the native int32 `mlx_arange` of `N`
elements from 0 by 1. -/
def HostArange (Nn : Nums Int) (t : Ffi.St) (j : Nat) (N : Nat) : Prop :=
  ∃ a st sp sr shape x y z sha, a < j ∧ t.nodes.get j = some ⟨.slice st sp sr, [a], shape, Ffi.dtInt32⟩ ∧
    st.mapM Nn.d = some [0] ∧ sp.mapM Nn.d = some [(N : Int)] ∧ sr.mapM Nn.d = some [1] ∧
    t.nodes.get a = some ⟨.arange x y z, [], sha, Ffi.dtInt32⟩ ∧ Nn.dim x = some 0 ∧ Nn.dim z = some 1 ∧
    sha.mapM Nn.d = some [(N : Int)]

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} [DecidableEq κ]
  (env : Env κ) (kind : Nat → Option Compiled)

/-- A data node's value is its bytes'. -/
theorem evalRR_data (g : Nat → Option (RNode Int κ)) (j : Nat) (bs : List Nat) (sh : List Int) (dt : Nat)
    (hg : g j = some ⟨.data bs sh dt, []⟩) : evalRR P K env kind g j = dataValue bs sh dt := by
  rw [evalRR_eq, hg]
  dsimp only
  rw [cgLeaves_none g j _ hg rfl]
  dsimp only
  have hc : closureLeaves kind g j = none := by simp [closureLeaves, hg, closureAux]
  rw [hc]
  dsimp only
  simp only [List.mapM_nil, Option.pure_def, Option.bind_some]
  cases hd : dataValue bs sh dt <;>
    simp [primEvalR, primEvalP, primEval, hd, Option.orElse, rowsEval, prefillEval]

theorem ffiGraphR_data (Nn : Nums Int) (S : KernelSources) (t : Ffi.St) (j : Nat) (bytes : List Byte)
    (shape : List Ffi.Dim) (bs : List Nat) (sh : List Int)
    (hn : t.nodes.get j = some ⟨.data bytes, [], shape, Ffi.dtInt32⟩) (hb : bytes.mapM Nn.byte = some bs)
    (hs : shape.mapM Nn.d = some sh) :
    ffiGraphR (κ := κ) Nn S t j = some ⟨.data bs sh Ffi.dtInt32, []⟩ := by
  simp only [ffiGraphR, hn, Option.bind_some, resolveNodeP]
  rw [resolvePrimP_eq Nn _ shape Ffi.dtInt32 (.data bytes) (by intro a b c h; cases h)]
  simp [resolvePrim, hb, hs]

/-- **An `Int32Array` node holds its cells.** -/
theorem hostInt32_eval (Nn : Nums Int) (S : KernelSources) (t : Ffi.St) (j : Nat) (cs sh : List Int)
    (h : HostInt32 Nn t j cs sh) : evalRR P K env kind (ffiGraphR Nn S t) j = cellsValue cs sh := by
  obtain ⟨bytes, shape, hn, hb, hs⟩ := h
  rw [evalRR_data P K env kind _ j _ _ _ (ffiGraphR_data Nn S t j bytes shape _ sh hn hb hs)]
  rfl

theorem le32_eq (v : Int) : le32 v = i32Bytes v := by
  simp only [le32, i32Bytes, F64.modNat, leBytes, Nat.div_div_eq_div_mul]
  rfl

theorem arangeBytes_range (N : Nat) : arangeBytes 0 1 N = cellsBytes ((List.range N).map Int.ofNat) := by
  simp [arangeBytes, cellsBytes, List.flatMap_map, le32_eq, ← List.map_eq_flatMap]

/-- **The native range's slice holds `0 … N−1`.** -/
theorem hostArange_eval (Nn : Nums Int) (S : KernelSources) (t : Ffi.St) (j N : Nat) (h : HostArange Nn t j N) :
    evalRR P K env kind (ffiGraphR Nn S t) j = cellsValue ((List.range N).map Int.ofNat) [(N : Int)] := by
  obtain ⟨a, st, sp, sr, shape, x, y, z, sha, haj, hn, hst, hsp, hsr, ha, hx, hz, hsa⟩ := h
  have hga : ffiGraphR (κ := κ) Nn S t a = some ⟨.data (arangeBytes 0 1 N) [(N : Int)] Ffi.dtInt32, []⟩ := by
    simp [ffiGraphR, ha, resolveNodeP, resolvePrimP, hx, hz, hsa]
  have hgj : ffiGraphR (κ := κ) Nn S t j = some ⟨.slice [0] [(N : Int)] [1], [a]⟩ := by
    simp only [ffiGraphR, hn, Option.bind_some, resolveNodeP]
    rw [resolvePrimP_eq Nn _ shape Ffi.dtInt32 (.slice st sp sr) (by intro a b c h; cases h)]
    simp [resolvePrim, hst, hsp, hsr]
  have hva := evalRR_data P K env kind _ a _ _ _ hga
  rw [evalRR_eq, hgj]
  dsimp only
  rw [cgLeaves_none _ j _ hgj rfl]
  dsimp only
  have hc : closureLeaves kind (ffiGraphR (κ := κ) Nn S t) j = none := by simp [closureLeaves, hgj, closureAux]
  rw [hc]
  dsimp only
  simp only [List.mapM_cons, List.mapM_nil, haj, ↓reduceDIte, hva, arangeBytes_range]
  simp [primEvalR, primEvalP, primEval, Option.orElse, unitStrides, natShape, cellsValue, dataValue,
    Dtype.ofCode, Ffi.dtInt32, slice, flat, unflat, strides, extent]

end

/-! ## The folded read's inputs -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (env : Env PKey)
  (kind : Nat → Option Compiled) (Nn : Nums Int) (S : KernelSources) (t : Ffi.St)
  (base : InKey → Option Value) (ids : Value) (ν : Nat → Int) (R : Rows) (p : Nat)

/-- **The key limits** `N − L + (row mod L)` at `N = o + r`, `L = r` (rows
`0 … 6r−1`, shape `[6r, 1]`) hold the folded read's input `cells p 1`. -/
theorem folded_limits (r o : Nat) (ho : R.oP.eval ν = o) (j : Nat)
    (h : HostInt32 Nn t j ((List.range (6 * r)).map fun row => ((o + r : Nat) : Int) - r + ((row % r : Nat) : Int))
      [((6 * r : Nat) : Int), 1]) :
    evalRR P K env kind (ffiGraphR Nn S t) j = promptInputs base ids ν (auxKey R (.folded r) p 1) := by
  rw [hostInt32_eval P K env kind Nn S t j _ _ h]
  simp only [auxKey, promptInputs, List.map_map, List.map_cons, List.map_nil]
  congr 1
  · apply List.map_congr_left
    intro row _
    simp only [Function.comp, Aff.eval_toP, Aff.eval_add, Aff.eval_const]
    have : R.o.toP.eval ν = o := ho
    rw [Aff.eval_toP] at this
    rw [this]; push_cast; ring

/-- The key positions of the data path (`N < 65536`) hold `iota p 2`. -/
theorem folded_cols_data (rd : Read) (N : Nat) (hN : R.onP.eval ν = N) (j : Nat)
    (h : HostInt32 Nn t j ((List.range N).map Int.ofNat) [(N : Int)]) :
    evalRR P K env kind (ffiGraphR Nn S t) j = promptInputs base ids ν (auxKey R rd p 2) := by
  rw [hostInt32_eval P K env kind Nn S t j _ _ h]
  simp only [auxKey, promptInputs, hN, Int.toNat_natCast]

/-- The key positions of the native path (`N ≥ 65536`) hold `iota p 2`. -/
theorem folded_cols_arange (rd : Read) (N : Nat) (hN : R.onP.eval ν = N) (j : Nat) (h : HostArange Nn t j N) :
    evalRR P K env kind (ffiGraphR Nn S t) j = promptInputs base ids ν (auxKey R rd p 2) := by
  rw [hostArange_eval P K env kind Nn S t j N h]
  simp only [auxKey, promptInputs, hN, Int.toNat_natCast]

end

end Host.Mlx.SimGraph
