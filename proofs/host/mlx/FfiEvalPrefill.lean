import host.mlx.FfiEval
import host.mlx.OpsPrefill
namespace Host.Mlx.FfiEval
open Inference.Contracts.Mlx
open Host.Mlx.Ffi (Dim Prim Node Cfg)

/-! # Values of the multi-row forwards' graph

`FfiEval` evaluates the FFI graph with the decode semantics; at the prompt's
multi-row shapes most MLX operations have no value there. This module extends
the evaluation, leaving `resolvePrim`, `primEval` and `evalR` as they are:

* `resolvePrimP`: `resolvePrim`, except that an `mlx_arange` node (int32, a
  literal range, as `Ffi` creates it) resolves to its constant bytes instead
  of `unsupported`.
* `rowsEval`: the values of `OpsPrefill` at the multi-row shapes, and of the
  graph operations `Ffi` records under operation names (`Ffi.graphPrim`):
  `.unary "matmul"`, `.unary "less_equal"` over two arguments, `.unary "where"`
  over three, `.binary (axisName "softmax" last true)` and
  `.binary (axisName "sum_axis" axis false)` over one. `primEvalP` is
  `primEval`, else `rowsEval`.
* `evalRP`: `evalR` with `primEvalP`, compute_g's replayed body at any number
  of rows, and the replayed bodies of the closures `kind` names
  (`closureLeaves`: nn.silu, swiglu, _precise_swiglu as `Ffi` records their
  replay) evaluated as the compiled closure (`compiledValue`). `kind` maps
  closure objects to the TypeScript closure they compile; it is the caller's
  fact about the run.
* `evalR_evalRP`: wherever the decode evaluation has a value, the extended one
  has the same value. -/

/-! ## Resolution -/

/-- Little-endian bytes of an int32 element. -/
def le32 (v : Int) : List Nat :=
  let w := (v % 2^32).toNat
  [w % 256, w / 256 % 256, w / 65536 % 256, w / 16777216 % 256]

/-- `arange(start, ·, step)` of `n` int32 elements (Arange: start + i·step). -/
def arangeBytes (start step : Int) (n : Nat) : List Nat :=
  (List.range n).flatMap fun k => le32 (start + k * step)

/-- `resolvePrim`, with an int32 `arange` node as its constant data. -/
def resolvePrimP {κ : Type} (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Dim) (dtype : Nat) :
    Prim → Option (RPrim Int κ)
  | .arange a _ c => do
    let a ← N.dim a
    let c ← N.dim c
    match ← shape.mapM N.d with
    | [n] => if dtype = Ffi.dtInt32 ∧ 0 ≤ n then pure (.data (arangeBytes a c n.toNat) [n] dtype) else none
    | _ => none
  | .replayed c p => (resolvePrimP N kn shape dtype p).map (RPrim.replayed c)
  | p => resolvePrim N kn shape dtype p

def resolveNodeP {κ : Type} (N : Nums Int) (kn : Nat → Option (List Char)) (nd : Node) : Option (RNode Int κ) :=
  (resolvePrimP N kn nd.shape nd.dtype nd.prim).map (⟨·, nd.ins⟩)

/-- The FFI model's graph, resolved with `resolvePrimP`. -/
def ffiGraphP {κ : Type} (N : Nums Int) (S : KernelSources) (s : Ffi.St) (i : Nat) : Option (RNode Int κ) :=
  (s.nodes.get i).bind (resolveNodeP N (kernelName? S s))

/-- A primitive under its replay tags. -/
def underReplay : Prim → Prim
  | .replayed _ p => underReplay p
  | p => p

/-- Away from `arange`, `resolvePrimP` is `resolvePrim`. -/
theorem resolvePrimP_eq {κ : Type} (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Dim) (dtype : Nat) :
    ∀ p : Prim, (∀ a b c, underReplay p ≠ .arange a b c) →
      (resolvePrimP (κ := κ) N kn shape dtype p) = resolvePrim N kn shape dtype p
  | .arange a b c, h => absurd rfl (h a b c)
  | .replayed c p, h => by
    show (resolvePrimP N kn shape dtype p).map (RPrim.replayed c) = (resolvePrim N kn shape dtype p).map (RPrim.replayed c)
    rw [resolvePrimP_eq N kn shape dtype p h]
  | .data _, _ | .load _ _, _ | .tracer _, _ | .zeros, _ | .reshape _, _ | .transpose _, _
  | .slice _ _ _, _ | .sliceUpdate _ _ _, _ | .sliceDynamic _ _, _ | .concat _, _ | .unary _, _
  | .binary _, _ | .astype _, _ | .contiguous, _ | .rmsNorm _, _ | .rope _ _ _ _ _, _
  | .sdpa _ _, _ | .qmm _ _ _ _, _ | .dequantize _ _ _ _, _ | .take _, _ | .conv1d _ _ _ _, _
  | .logsumexp _ _, _ | .kernel _ _ _, _ => rfl

/-! ## Values at the multi-row shapes -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)

/-- The operations and shapes the decode semantics leaves without a value. -/
noncomputable def rowsEval : RPrim Int κ → List Value → Option Value
  | .unary op, [a, b] =>
    if op = chars!"matmul" then matmulV P a b else if op = chars!"less_equal" then lessEqual a b else none
  | .unary op, [c, x, y] => if op = chars!"where" then select c x y else none
  | .binary op, [a] =>
    if op = Ffi.axisName chars!"softmax" (a.shape.length - 1) true then softmaxV P a
    else match (List.range a.shape.length).find? (fun ax => op = Ffi.axisName chars!"sum_axis" ax false) with
      | some ax => sumV P a ax
      | none => none
  | .binary op, [a, b] => if op = chars!"multiply" then multiplyScalar a b else none
  | .astype d, [v] => (Dtype.ofCode d).bind (astypeV v)
  | .rmsNorm eps, [x, w] => rmsNormNarrow P x w (f32 eps)
  | .rope d t base scale off, [x] => ropeRows P x d t (GlueAttention.optionalFloat base) (f32 scale) off
  | .sdpa scale mask, [q, k, v] => if mask = chars!"causal" then sdpaCausalV P q k v (f32 scale) else none
  | .qmm t g b mode, [x, w, s, bi] => qmmRowsV P x w s bi t g b (String.ofList mode)
  | .dequantize g b mode dt, [w, s, bi] =>
    if g = 64 ∧ mode = chars!"affine" ∧ dt = none then
      if b = 4 then dequantize4 P w s bi else if b = 3 then dequantize3V P w s bi else none
    else none
  | .conv1d s p d g, [x, w] => conv1dRows P x w s p d g
  | .computeG, [aLog, a, dt] => computeGRows P aLog a dt
  | .replayed _ p, xs => if elementwise p then none else rowsEval p xs
  | _, _ => none

/-- `primEval` at the decode contract, else the multi-row value. -/
noncomputable def primEvalP (p : RPrim Int κ) (xs : List Value) : Option Value :=
  (primEval P.toMlxContract K env p xs).orElse fun _ => rowsEval P p xs

/-- compute_g's closure: the decode value, else the rows'. -/
noncomputable def computeGP (xs : List Value) : Option Value :=
  ((closureApply P.toMlxContract .computeG xs).bind single).orElse fun _ => rowsEval P (κ := κ) .computeG xs

end

/-! ## Compiled closures' replayed bodies

As `Ffi` records them (blocks.ts, swiglu.ts), every operation tagged with the
closure: nn.silu `multiply(x, sigmoid(x))`; swiglu
`multiply(multiply(g, sigmoid(g)), u)`; _precise_swiglu
`astype(multiply(multiply(gf, sigmoid(gf)), astype(x, f32)), bf16)` with
`gf = astype(g, f32)`. Each step reads a node of smaller id. -/

section
variable {κ : Type} [DecidableEq κ]

/-- The leaves of closure `cls`'s replayed body at root `r` (primitive `p` under the tag),
reading nodes through `b`. -/
def closureBody (kind : Nat → Option Compiled) (cls : Nat) (p : RPrim Int κ) (r : RNode Int κ)
    (b : Nat → Option (RNode Int κ)) : Option (Compiled × List Nat) := do
  match ← kind cls with
  | .silu =>
    if p = .binary chars!"multiply" then pure () else none
    let (x, sg) ← two? r.ins
    let sn ← b sg
    if sn = ⟨.replayed cls (.unary chars!"sigmoid"), [x]⟩ then pure (.silu, [x]) else none
  | .swiglu =>
    if p = .binary chars!"multiply" then pure () else none
    let (m, u) ← two? r.ins
    let mn ← b m
    if mn.prim = .replayed cls (.binary chars!"multiply") then pure () else none
    let (g, sg) ← two? mn.ins
    let sn ← b sg
    if sn = ⟨.replayed cls (.unary chars!"sigmoid"), [g]⟩ then pure (.swiglu, [g, u]) else none
  | .preciseSwiglu =>
    if p = .astype Ffi.dtBf16 then pure () else none
    let pr ← one? r.ins
    let prn ← b pr
    if prn.prim = .replayed cls (.binary chars!"multiply") then pure () else none
    let (sl, xf) ← two? prn.ins
    let sln ← b sl
    if sln.prim = .replayed cls (.binary chars!"multiply") then pure () else none
    let (gf, sg) ← two? sln.ins
    let sn ← b sg
    if sn = ⟨.replayed cls (.unary chars!"sigmoid"), [gf]⟩ then pure () else none
    let gfn ← b gf
    if gfn.prim = .replayed cls (.astype Ffi.dtF32) then pure () else none
    let g ← one? gfn.ins
    let xfn ← b xf
    if xfn.prim = .replayed cls (.astype Ffi.dtF32) then pure () else none
    let x ← one? xfn.ins
    pure (.preciseSwiglu, [g, x])

/-- The closure kind and leaves of the replayed body at root `r`: a replayed
elementwise node (multiply or astype) of a closure `kind` names. -/
def closureAux (kind : Nat → Option Compiled) (r : RNode Int κ) (b : Nat → Option (RNode Int κ)) :
    Option (Compiled × List Nat) :=
  match r.prim with
  | .replayed cls p => if elementwise p then closureBody kind cls p r b else none
  | _ => none

/-- The closure kind and leaves if node `i` is the root of a named closure's replayed body. -/
def closureLeaves (kind : Nat → Option Compiled) (g : Nat → Option (RNode Int κ)) (i : Nat) :
    Option (Compiled × List Nat) :=
  (g i).bind fun r => closureAux kind r (fun j => if j < i then g j else none)

/-- A closure root is a replayed elementwise node (so the decode evaluation gives it no value). -/
theorem closureAux_root (kind : Nat → Option Compiled) (r : RNode Int κ) (b : Nat → Option (RNode Int κ))
    {x : Compiled × List Nat} (h : closureAux kind r b = some x) :
    ∃ c p, r.prim = .replayed c p ∧ elementwise p = true := by
  unfold closureAux at h
  split at h
  · rename_i c p hr
    by_cases he : elementwise p = true
    · exact ⟨c, p, hr, he⟩
    · simp [he] at h
  · cases h

end

/-! ## The extended evaluation -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ]
  (env : Env κ) (kind : Nat → Option Compiled)

/-- The value of node `i`: compute_g's replayed body as its closure, a named
closure's replayed body as the compiled closure, any other node by
`primEvalP` on its evaluated arguments (each of smaller id). -/
noncomputable def evalRP (g : Nat → Option (RNode Int κ)) (i : Nat) : Option Value :=
  match g i with
  | none => none
  | some nd =>
    match cgLeaves g i with
    | some leaves => do
      let xs ← leaves.mapM fun j => if _h : j < i then evalRP g j else none
      computeGP P (κ := κ) xs
    | none =>
      match closureLeaves kind g i with
      | some (c, leaves) => do
        let xs ← leaves.mapM fun j => if _h : j < i then evalRP g j else none
        compiledValue P c xs
      | none => do
        let xs ← nd.ins.mapM fun j => if _h : j < i then evalRP g j else none
        primEvalP P K env nd.prim xs
termination_by i
decreasing_by all_goals assumption

theorem evalRP_eq (g : Nat → Option (RNode Int κ)) (i : Nat) : evalRP P K env kind g i =
    match g i with
    | none => none
    | some nd =>
      match cgLeaves g i with
      | some leaves => (leaves.mapM fun j => if _h : j < i then evalRP P K env kind g j else none).bind
          (computeGP P (κ := κ))
      | none =>
        match closureLeaves kind g i with
        | some (c, leaves) => (leaves.mapM fun j => if _h : j < i then evalRP P K env kind g j else none).bind
            (compiledValue P c)
        | none => (nd.ins.mapM fun j => if _h : j < i then evalRP P K env kind g j else none).bind
            (primEvalP P K env nd.prim) := by
  rw [evalRP]; rfl

theorem mapM_some_mono {α β : Type} (l : List α) (f h : α → Option β) {ys : List β}
    (e : ∀ x ∈ l, ∀ y, f x = some y → h x = some y) (hf : l.mapM f = some ys) : l.mapM h = some ys := by
  induction l generalizing ys with
  | nil => simpa using hf
  | cons a l ih =>
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.pure_def] at hf ⊢
    cases ha : f a with
    | none => rw [ha] at hf; cases hf
    | some y =>
      rw [ha] at hf
      cases hl : l.mapM f with
      | none => rw [hl] at hf; cases hf
      | some zs =>
        rw [hl] at hf
        rw [e a (List.mem_cons_self ..) y ha, ih (fun x hx => e x (List.mem_cons_of_mem _ hx)) hl]
        exact hf

/-- **Conservative extension**: a node the decode evaluation gives a value has
that value in the extended evaluation. -/
theorem evalR_evalRP (g : Nat → Option (RNode Int κ)) :
    ∀ i v, evalR P.toMlxContract K env g i = some v → evalRP P K env kind g i = some v := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro v hv
  rw [evalR_eq] at hv
  rw [evalRP_eq]
  have hargs : ∀ (l : List Nat) (ys : List Value),
      (l.mapM fun j => if _h : j < i then evalR P.toMlxContract K env g j else none) = some ys →
      (l.mapM fun j => if _h : j < i then evalRP P K env kind g j else none) = some ys := by
    intro l ys hl
    refine mapM_some_mono l _ _ (fun j _ y hy => ?_) hl
    by_cases hj : j < i
    · simp only [hj, ↓reduceDIte] at hy ⊢; exact ih j hj y hy
    · simp only [hj, ↓reduceDIte] at hy; cases hy
  cases hg : g i with
  | none => rw [hg] at hv; cases hv
  | some nd =>
    rw [hg] at hv
    dsimp only at hv ⊢
    cases hc : cgLeaves g i with
    | some leaves =>
      rw [hc] at hv
      dsimp only at hv ⊢
      obtain ⟨xs, hxs, hcl⟩ := Option.bind_eq_some_iff.mp hv
      rw [hargs leaves xs hxs, Option.bind_some, computeGP, hcl]
      rfl
    | none =>
      rw [hc] at hv
      dsimp only at hv ⊢
      obtain ⟨xs, hxs, hp⟩ := Option.bind_eq_some_iff.mp hv
      cases hk : closureLeaves kind g i with
      | some x =>
        exfalso
        have hk' : closureAux kind nd (fun j => if j < i then g j else none) = some x := by
          unfold closureLeaves at hk
          rw [hg] at hk
          exact hk
        obtain ⟨c, p, hr, he⟩ := closureAux_root kind nd _ hk'
        rw [hr] at hp
        change (if elementwise p then none else primEval P.toMlxContract K env p xs) = some v at hp
        rw [he] at hp
        cases hp
      | none =>
        dsimp only
        rw [hargs nd.ins xs hxs, Option.bind_some, primEvalP, hp]
        rfl

end

end Host.Mlx.FfiEval
