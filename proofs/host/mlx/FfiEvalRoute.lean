import host.mlx.PrefillKernels
namespace Host.Mlx.FfiEval
open Inference.Contracts.Mlx
open Host.Mlx.PrefillSources (PrefillKernel)

/-! # Values of the graph's prefill kernel nodes

A layer over the multi-row evaluation (`FfiEvalPrefill`: `primEvalP`, `evalRP`, unchanged), at a route kernel
contract `K` (`RouteKernelContract`): a kernel node naming a prefill kernel (`prefillOf`) is its launch, output
`out` of `K.applyP`, or for an in-place kernel (the trellis fills, the half writer) of `K.inPlace.launchAll` (every
buffer's final contents, the outputs after the inputs) read back with the call's dtype and shape
(`FfiAneEval.outValue`). `primEvalR` is `primEvalP` at `K`'s decode contract, else that launch; `evalRR` is
`evalRP` with `primEvalR`. Nodes are resolved with the route's kernel table (`ffiGraphR`).

* `evalRP_evalRR`: wherever the multi-row evaluation has a value, the route evaluation has the same value (on the
  same graph).
* `evalRR_ffi`: on a state none of whose kernel objects resolves to a prefill kernel (`DecodeOnly`) the table- and
  decode-resolved graphs are equal, so its nodes evaluate as before.
* `routeKernelSem K`: the same launch of any route kernel by name, resolved configuration and output, the shape of
  `SimGraph.KernelSem` (host/simgraph/family/Eval.lean). -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ)

/-- Output `out` of a prefill kernel's launch on `xs` at `cfg`. -/
noncomputable def prefillLaunch (k : PrefillKernel) (cfg : Config) (out : Nat) (xs : List Value) : Option Value :=
  match k.inPlace? with
  | some ip => do
    let res ← K.inPlace.launchAll ip xs cfg
    let o ← cfg.outputs[out]?
    let b ← res[xs.length + out]?
    pure (FfiAneEval.outValue b o)
  | none => do
    let ys ← K.applyP k xs cfg
    ys[out]?

/-- A route kernel's launch by name, resolved configuration and output (decode kernels through `K.apply`). -/
noncomputable def routeKernelSem (name : List Char) (c : RCfg Int) (out : Nat) (xs : List Value) : Option Value := do
  let cfg ← toConfig c
  match routeKernelOf name with
  | some (.decode d) => do let ys ← K.apply d xs cfg; ys[out]?
  | some (.prefill k) => prefillLaunch K k cfg out xs
  | none => none

/-- A prefill kernel node's value. -/
noncomputable def prefillEval : RPrim Int κ → List Value → Option Value
  | .kernel name c out, xs => do
    let k ← prefillOf name
    let cfg ← toConfig c
    prefillLaunch K k cfg out xs
  | _, _ => none

/-- `primEvalP` at the decode contract, else a prefill kernel's launch. -/
noncomputable def primEvalR (p : RPrim Int κ) (xs : List Value) : Option Value :=
  (primEvalP P K.toKernelContract env p xs).orElse fun _ => prefillEval K p xs

theorem primEvalR_of {p : RPrim Int κ} {xs : List Value} {v : Value}
    (h : primEvalP P K.toKernelContract env p xs = some v) : primEvalR P K env p xs = some v := by
  simp [primEvalR, h, Option.orElse]

/-- A prefill kernel node, the decode evaluation having no value for it, is its launch. -/
theorem primEvalR_kernel {name : List Char} {c : RCfg Int} {out : Nat} {xs : List Value} {k : PrefillKernel}
    {cfg : Config} (hn : primEvalP P K.toKernelContract env (.kernel name c out) xs = none)
    (hk : prefillOf name = some k) (hc : toConfig c = some cfg) :
    primEvalR P K env (.kernel name c out) xs = prefillLaunch K k cfg out xs := by
  simp [primEvalR, hn, Option.orElse, prefillEval, hk, hc]

/-- A primitive that is no prefill kernel's node (the route evaluation gives it the decode evaluation's value). -/
def NoPrefill (p : RPrim Int κ) : Prop := ∀ name c out, p = .kernel name c out → prefillOf name = none

theorem prefillEval_noPrefill {p : RPrim Int κ} {xs : List Value} (h : NoPrefill p) : prefillEval K p xs = none := by
  cases p with
  | kernel name c out => simp [prefillEval, h name c out rfl]
  | _ => rfl

theorem primEvalR_noPrefill {p : RPrim Int κ} {xs : List Value} (h : NoPrefill p) :
    primEvalR P K env p xs = primEvalP P K.toKernelContract env p xs := by
  unfold primEvalR
  rw [prefillEval_noPrefill K h]
  cases primEvalP P K.toKernelContract env p xs <;> rfl

theorem noPrefill_of_kernel {name : List Char} {c : RCfg Int} {out : Nat} (h : (kernelOf name).isSome) :
    NoPrefill (κ := κ) (.kernel name c out) := by
  intro name' c' out' he
  cases he
  cases hp : prefillOf name with
  | none => rfl
  | some k =>
    have := kernelOf_prefill k
    rw [prefillOf_name hp] at this
    rw [this] at h
    cases h

/-- The decode evaluation has no value for a prefill kernel's node (`FfiEval.kernelOf` reads no prefill name, and the
multi-row operations no kernel). -/
theorem primEvalP_prefill {name : List Char} {c : RCfg Int} {out : Nat} {xs : List Value} {k : PrefillKernel}
    (hk : prefillOf name = some k) : primEvalP P K.toKernelContract env (.kernel name c out) xs = none := by
  have hn : kernelOf name = none := by rw [← prefillOf_name hk]; exact kernelOf_prefill k
  simp [primEvalP, primEval, hn, rowsEval, Option.orElse]

end

/-! ## The extended evaluation -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} [DecidableEq κ]
  (env : Env κ) (kind : Nat → Option Compiled)

/-- `evalRP` with `primEvalR`. -/
noncomputable def evalRR (g : Nat → Option (RNode Int κ)) (i : Nat) : Option Value :=
  match g i with
  | none => none
  | some nd =>
    match cgLeaves g i with
    | some leaves => do
      let xs ← leaves.mapM fun j => if _h : j < i then evalRR g j else none
      computeGP P (κ := κ) xs
    | none =>
      match closureLeaves kind g i with
      | some (c, leaves) => do
        let xs ← leaves.mapM fun j => if _h : j < i then evalRR g j else none
        compiledValue P c xs
      | none => do
        let xs ← nd.ins.mapM fun j => if _h : j < i then evalRR g j else none
        primEvalR P K env nd.prim xs
termination_by i
decreasing_by all_goals assumption

theorem evalRR_eq (g : Nat → Option (RNode Int κ)) (i : Nat) : evalRR P K env kind g i =
    match g i with
    | none => none
    | some nd =>
      match cgLeaves g i with
      | some leaves => (leaves.mapM fun j => if _h : j < i then evalRR P K env kind g j else none).bind
          (computeGP P (κ := κ))
      | none =>
        match closureLeaves kind g i with
        | some (c, leaves) => (leaves.mapM fun j => if _h : j < i then evalRR P K env kind g j else none).bind
            (compiledValue P c)
        | none => (nd.ins.mapM fun j => if _h : j < i then evalRR P K env kind g j else none).bind
            (primEvalR P K env nd.prim) := by
  rw [evalRR]; rfl

/-- **Conservative extension**: a node the multi-row evaluation gives a value has that value in the route
evaluation. -/
theorem evalRP_evalRR (g : Nat → Option (RNode Int κ)) :
    ∀ i v, evalRP P K.toKernelContract env kind g i = some v → evalRR P K env kind g i = some v := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro v hv
  rw [evalRP_eq] at hv
  rw [evalRR_eq]
  have hargs : ∀ (l : List Nat) (ys : List Value),
      (l.mapM fun j => if _h : j < i then evalRP P K.toKernelContract env kind g j else none) = some ys →
      (l.mapM fun j => if _h : j < i then evalRR P K env kind g j else none) = some ys := by
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
      rw [hargs leaves xs hxs, Option.bind_some, hcl]
    | none =>
      rw [hc] at hv
      dsimp only at hv ⊢
      cases hk : closureLeaves kind g i with
      | some x =>
        obtain ⟨c, leaves⟩ := x
        rw [hk] at hv
        dsimp only at hv ⊢
        obtain ⟨xs, hxs, hcl⟩ := Option.bind_eq_some_iff.mp hv
        rw [hargs leaves xs hxs, Option.bind_some, hcl]
      | none =>
        rw [hk] at hv
        dsimp only at hv ⊢
        obtain ⟨xs, hxs, hp⟩ := Option.bind_eq_some_iff.mp hv
        rw [hargs nd.ins xs hxs, Option.bind_some]
        exact primEvalR_of P K env hp

/-- **Decode-only states evaluate as before**: on the table-resolved graph of a state whose kernel objects resolve
only to decode kernels, every node the multi-row evaluation of the decode-resolved graph gives a value has that
value. -/
theorem evalRR_ffi (N : Nums Int) {S : KernelSources} {s : Ffi.St} (hd : DecodeOnly S s) (i : Nat) (v : Value)
    (h : evalRP P K.toKernelContract env kind (ffiGraphP N S s) i = some v) :
    evalRR P K env kind (ffiGraphR N S s) i = some v := by
  rw [ffiGraphR_decodeOnly N hd]
  exact evalRP_evalRR P K env kind _ i v h


/-- **On a graph with no prefill kernel node the route evaluation is the multi-row evaluation.** -/
theorem evalRR_eq_evalRP (g : Nat → Option (RNode Int κ)) (hg : ∀ j nd, g j = some nd → NoPrefill nd.prim) :
    ∀ i, evalRR P K env kind g i = evalRP P K.toKernelContract env kind g i := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  have hargs : ∀ l : List Nat, (l.mapM fun j => if _h : j < i then evalRR P K env kind g j else none) =
      (l.mapM fun j => if _h : j < i then evalRP P K.toKernelContract env kind g j else none) := fun l =>
    mapM_congr' l _ _ fun j _ => by
      by_cases hj : j < i
      · simp only [hj, ↓reduceDIte]; exact ih j hj
      · simp only [hj, ↓reduceDIte]
  rw [evalRR_eq, evalRP_eq]
  cases hgi : g i with
  | none => rfl
  | some nd =>
    dsimp only
    cases cgLeaves g i with
    | some leaves => dsimp only; rw [hargs]
    | none =>
      dsimp only
      cases closureLeaves kind g i with
      | some x => dsimp only; rw [hargs]
      | none =>
        dsimp only
        rw [hargs]
        congr 1
        funext xs
        exact primEvalR_noPrefill P K env (hg i nd hgi)

omit [DecidableEq κ] in
/-- `resolvePrim` makes a kernel node only of a kernel object `kn` names. -/
theorem resolvePrim_kernel (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) {name : List Char} {c : RCfg Int} {out : Nat},
      resolvePrim (κ := κ) N kn shape dtype p = some (.kernel name c out) → ∃ h, kn h = some name := by
  intro p name c out h
  cases p with
  | kernel k c' i =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def,
      Option.some.injEq] at h
    obtain ⟨n, hn, rc, _, he⟩ := h
    injection he with h1
    exact ⟨k, h1 ▸ hn⟩
  | replayed c' q =>
    simp only [resolvePrim, Option.map_eq_some_iff] at h
    obtain ⟨_, _, he⟩ := h
    cases he
  | _ => simp [resolvePrim, Option.bind_eq_some_iff, Option.map_eq_some_iff] at h

omit [DecidableEq κ] in
theorem resolvePrimP_kernel (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) {name : List Char} {c : RCfg Int} {out : Nat},
      resolvePrimP (κ := κ) N kn shape dtype p = some (.kernel name c out) → ∃ h, kn h = some name := by
  intro p name c out h
  cases p with
  | arange a b c' =>
    simp only [resolvePrimP, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def] at h
    aesop
  | replayed c' q =>
    simp only [resolvePrimP, Option.map_eq_some_iff] at h
    obtain ⟨_, _, he⟩ := h
    cases he
  | _ => exact resolvePrim_kernel N kn shape dtype _ h

/-- A decode name the decode resolution gives a kernel object. -/
theorem kernelName?_isSome {S : KernelSources} {s : Ffi.St} {h : Nat} {name : List Char}
    (hk : kernelName? S s h = some name) : (kernelOf name).isSome := by
  unfold kernelName? at hk
  split at hk
  · rename_i nm src hdr _ _ _
    cases hkk : kernelOf nm with
    | none => rw [hkk] at hk; cases hk
    | some k =>
      rw [hkk] at hk
      simp only [Option.bind_some] at hk
      split at hk
      · cases hk; rw [hkk]; rfl
      · cases hk
  · cases hk

omit [DecidableEq κ] in
/-- A decode-only state's table-resolved graph has no prefill kernel node. -/
theorem ffiGraphR_noPrefill (N : Nums Int) {S : KernelSources} {s : Ffi.St} (hd : DecodeOnly S s) :
    ∀ j (nd : RNode Int κ), ffiGraphR N S s j = some nd → NoPrefill nd.prim := by
  intro j nd h name c out hp
  rw [ffiGraphR_decodeOnly N hd] at h
  unfold ffiGraphP at h
  obtain ⟨n, _, hr⟩ := Option.bind_eq_some_iff.mp h
  unfold resolveNodeP at hr
  obtain ⟨p, hpe, rfl⟩ := Option.map_eq_some_iff.mp hr
  simp only at hp
  subst hp
  obtain ⟨kh, hkh⟩ := resolvePrimP_kernel N _ n.shape n.dtype n.prim hpe
  exact noPrefill_of_kernel (κ := κ) (c := c) (out := out) (kernelName?_isSome hkh) name c out rfl

end

end Host.Mlx.FfiEval
