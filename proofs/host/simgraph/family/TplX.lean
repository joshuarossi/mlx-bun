import host.simgraph.family.Tpl
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # Row families with taps

A Neural Engine layer hands some of its intermediate arrays to in-place
writers (the split's `writeHalf` sources), which the expected graph does not
contain; the effect segment needs those arrays' values. `RowTplX κ` is a
`RowTpl κ` whose layers also return such taps. `toTpl` drops them: its graph
is the taps run's graph (`forwardT_toTpl`), and `familyGraphX_eval` gives the
expected graph's values at the output, the caches and every tap. -/

/-- A row family's templates whose layers also return taps. -/
structure RowTplX (κ : Type) where
  sig : Option Nat → Nat → Nat → KvSig
  embed : {δ : Type} → {m : Type → Type} → [Monad m] → {α : Type} → Backend δ κ m α → (PDim → δ) → m α
  layer : {δ : Type} → {m : Type → Type} → [Monad m] → {α : Type} → Backend δ κ m α → (PDim → δ) →
    Nat → Nat → Nat → StageLayout → α → m ((α × α × α) × List (List α))
  final : {δ : Type} → {m : Type → Type} → [Monad m] → {α : Type} → Backend δ κ m α → (PDim → δ) → α → m α

/-- The family without its taps. -/
def RowTplX.toTpl {κ : Type} (T : RowTplX κ) : RowTpl κ where
  sig := T.sig
  embed B I := T.embed B I
  layer B I o n p s x := Prod.fst <$> T.layer B I o n p s x
  final B I y := T.final B I y

section
variable {κ : Type} (T : RowTplX κ) {δ : Type} {m : Type → Type} [Monad m] {α : Type} (B : Backend δ κ m α)
  (I : PDim → δ) (o n : Nat)

/-- The layers from chain position `p`, with every layer's taps. -/
def chainTX : Nat → List StageLayout → α → m (α × List (α × α) × List (List (List α)))
  | _, [], x => pure (x, [], [])
  | p, s :: ss, x => do
    let ((y, c1, c2), ts) ← T.layer B I o n p s x
    let (z, cs, tss) ← chainTX (p + 1) ss y
    pure (z, (c1, c2) :: cs, ts :: tss)

/-- The family's step with the layers' taps. -/
def forwardTX (ss : List StageLayout) : m ((α × List (α × α)) × List (List (List α))) := do
  let x ← T.embed B I
  let (y, cs, tss) ← chainTX T B I o n 0 ss x
  let r ← T.final B I y
  pure ((r, cs), tss)

end

@[simp] theorem RowTplX.toTpl_layer {κ : Type} (T : RowTplX κ) {δ : Type} {m : Type → Type} [Monad m] {α : Type}
    (B : Backend δ κ m α) (I : PDim → δ) (o n p : Nat) (s : StageLayout) (x : α) :
    T.toTpl.layer B I o n p s x = Prod.fst <$> T.layer B I o n p s x := rfl

@[simp] theorem RowTplX.toTpl_embed {κ : Type} (T : RowTplX κ) {δ : Type} {m : Type → Type} [Monad m] {α : Type}
    (B : Backend δ κ m α) (I : PDim → δ) : T.toTpl.embed B I = T.embed B I := rfl

@[simp] theorem RowTplX.toTpl_final {κ : Type} (T : RowTplX κ) {δ : Type} {m : Type → Type} [Monad m] {α : Type}
    (B : Backend δ κ m α) (I : PDim → δ) (y : α) : T.toTpl.final B I y = T.final B I y := rfl

theorem chainT_toTpl {κ : Type} (T : RowTplX κ) {δ : Type} {m : Type → Type} [Monad m] [LawfulMonad m] {α : Type}
    (B : Backend δ κ m α) (I : PDim → δ) (o n : Nat) : ∀ (p : Nat) (ss : List StageLayout) (x : α),
      chainT T.toTpl B I o n p ss x = (fun r => (r.1, r.2.1)) <$> chainTX T B I o n p ss x
  | _, [], x => by simp [chainT, chainTX]
  | p, s :: ss, x => by
    simp only [chainT, chainTX, RowTplX.toTpl_layer, bind_map_left, map_bind]
    congr 1; funext r
    obtain ⟨⟨y, c1, c2⟩, ts⟩ := r
    rw [chainT_toTpl T B I o n (p + 1) ss y]
    simp only [bind_map_left, map_pure]

theorem forwardT_toTpl {κ : Type} (T : RowTplX κ) {δ : Type} {m : Type → Type} [Monad m] [LawfulMonad m] {α : Type}
    (B : Backend δ κ m α) (I : PDim → δ) (o n : Nat) (ss : List StageLayout) :
    forwardT T.toTpl B I o n ss = Prod.fst <$> forwardTX T B I o n ss := by
  simp only [forwardT, forwardTX, RowTplX.toTpl_embed, RowTplX.toTpl_final, map_bind]
  congr 1; funext x
  rw [chainT_toTpl T B I o n 0 ss x]
  simp only [bind_map_left, map_pure]

/-! ## The family's obligations from its layers' -/

/-- Each template is natural in the dimension type. -/
structure RowTplX.IsNatural {κ : Type} (T : RowTplX κ) : Prop where
  embed : ∀ {δ δ' : Type} (f : δ → δ') (I : PDim → δ), Natural f (T.embed graphB I) (T.embed graphB fun d => f (I d))
  layer : ∀ {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (o n p : Nat) (s : StageLayout) (x : Nat),
    Natural f (T.layer graphB I o n p s x) (T.layer graphB (fun d => f (I d)) o n p s x)
  final : ∀ {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (y : Nat),
    Natural f (T.final graphB I y) (T.final graphB (fun d => f (I d)) y)

/-- The layers depend on the control only through the branch signature. -/
def RowTplX.SigOK {κ : Type} (T : RowTplX κ) : Prop :=
  ∀ {δ : Type} (I : PDim → δ) (o n o' n' p : Nat) (s s' : StageLayout) (x : Nat),
    SigRelR T.sig o n o' n' s s' → T.layer graphB I o n p s x = T.layer graphB I o' n' p s' x

theorem RowTplX.toTpl_natural {κ : Type} (T : RowTplX κ) (h : T.IsNatural) : T.toTpl.ops.IsNatural where
  embed f I := h.embed f I
  layer f I o n p s x := natural_map Prod.fst (h.layer f I o n p s x)
  final f I y := h.final f I y

theorem RowTplX.toTpl_sigOK {κ : Type} (T : RowTplX κ) (h : T.SigOK) : T.toTpl.ops.SigOK := by
  intro δ I o n o' n' p s s' x hs
  show Prod.fst <$> T.layer graphB I o n p s x = Prod.fst <$> T.layer graphB I o' n' p s' x
  rw [h I o n o' n' p s s' x hs]

/-- The family without taps as a row family. -/
def RowTplX.family {κ : Type} (T : RowTplX κ) (h1 : T.IsNatural) (h2 : T.SigOK) : RowFamily κ :=
  ⟨T.toTpl.ops, T.toTpl_natural h1, T.toTpl_sigOK h2⟩

/-! ## The reference computation with taps -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

/-- Each template's graph instance carries its value instance. -/
structure RowTplX.Simulates (T : RowTplX κ) : Prop where
  embed : ∀ (ν : Nat → Int) (fs : List (Nat × Value)),
    Sim P K env ks fs (T.embed graphB (PDim.eval ν)) (T.embed (valueB P K env ks) (PDim.eval ν))
  layer : ∀ (ν : Nat → Int) (o n p : Nat) (s : StageLayout) (x : Nat) (v : Value) (fs : List (Nat × Value)),
    (x, v) ∈ fs → Sim P K env ks fs (T.layer graphB (PDim.eval ν) o n p s x)
      (T.layer (valueB P K env ks) (PDim.eval ν) o n p s v)
  final : ∀ (ν : Nat → Int) (y : Nat) (v : Value) (fs : List (Nat × Value)),
    (y, v) ∈ fs → Sim P K env ks fs (T.final graphB (PDim.eval ν) y) (T.final (valueB P K env ks) (PDim.eval ν) v)

variable {P K env ks}

theorem RowTplX.toTpl_simulates (T : RowTplX κ) (hS : T.Simulates P K env ks) : T.toTpl.Simulates P K env ks where
  embed ν fs := hS.embed ν fs
  layer ν o n p s x v fs h := sim_map Prod.fst Prod.fst (hS.layer ν o n p s x v fs h) fun a w q hq => by
    simp only [Handle.facts, List.mem_append] at hq ⊢
    rcases hq with hq | hq | hq <;> simp_all
  final ν y v fs h := hS.final ν y v fs h

theorem chainX_sim (T : RowTplX κ) (hS : T.Simulates P K env ks) (ν : Nat → Int) (o n : Nat) :
    ∀ (p : Nat) (ss : List StageLayout) (x : Nat) (v : Value) (fs : List (Nat × Value)), (x, v) ∈ fs →
      Sim P K env ks fs (chainTX T graphB (PDim.eval ν) o n p ss x)
        (chainTX T (valueB P K env ks) (PDim.eval ν) o n p ss v)
  | _, [], x, v, fs, h => sim_pure (by intro q hq; simp [Handle.facts] at hq; rcases hq with rfl; exact h)
  | p, s :: ss, x, v, fs, h => by
    refine sim_bind (hS.layer ν o n p s x v fs h) fun ⟨⟨y, c1, c2⟩, ts⟩ ⟨⟨vy, vc1, vc2⟩, vts⟩ => ?_
    dsimp only
    refine sim_bind (chainX_sim T hS ν o n (p + 1) ss y vy _ (by simp [Handle.facts]))
      fun ⟨z, cs, tss⟩ ⟨vz, vcs, vtss⟩ => ?_
    dsimp only
    refine sim_pure fun q hq => ?_
    simp only [Handle.facts, List.zip_cons_cons, List.flatMap_cons, List.mem_append] at hq ⊢
    rcases hq with hq | ((hq | hq) | hq) | (hq | hq) <;> simp_all

theorem forwardX_sim (T : RowTplX κ) (hS : T.Simulates P K env ks) (ν : Nat → Int) (o n : Nat)
    (ss : List StageLayout) :
    Sim P K env ks [] (forwardTX T graphB (PDim.eval ν) o n ss) (forwardTX T (valueB P K env ks) (PDim.eval ν) o n ss) := by
  refine sim_bind (hS.embed ν []) fun x vx => ?_
  refine sim_bind (chainX_sim T hS ν o n 0 ss x vx _ (by simp [Handle.facts])) fun ⟨y, cs, tss⟩ ⟨vy, vcs, vtss⟩ => ?_
  dsimp only
  refine sim_bind (hS.final ν y vy _ (by simp [Handle.facts])) fun r vr => ?_
  refine sim_pure fun q hq => ?_
  simp only [Handle.facts, List.mem_append] at hq ⊢
  rcases hq with (hq | hq) | hq <;> simp_all

/-- The taps' nodes in the family's graph. -/
def RowTplX.tapsOf (T : RowTplX κ) (I : PDim → Int) (o n : Nat) (ss : List StageLayout) : List (List (List Nat)) :=
  (run (forwardTX T graphB I o n ss) []).1.2

theorem familyGraph_toTpl (T : RowTplX κ) {δ : Type} (I : PDim → δ) (o n : Nat) (ss : List StageLayout) :
    familyGraph T.toTpl.ops I o n ss =
      ((run (forwardTX T graphB I o n ss) []).2, (run (forwardTX T graphB I o n ss) []).1.1) := by
  unfold familyGraph
  rw [forwardP_ops, forwardT_toTpl]
  rfl

/-- **The expected graph holds the reference values with the taps'**: when the
reference computation returns the output `out`, the caches `cs` and the taps
`taps`, the family's graph holds them at its output, cache and tap nodes. -/
theorem familyGraphX_eval (T : RowTplX κ) (hS : T.Simulates P K env ks) (ν : Nat → Int) (o n : Nat)
    (ss : List StageLayout) (out : Value) (cs : List (Value × Value)) (taps : List (List (List Value)))
    (hv : forwardTX T (valueB P K env ks) (PDim.eval ν) o n ss = some ((out, cs), taps)) :
    AllEvE P K env ks (familyGraph T.toTpl.ops (PDim.eval ν) o n ss).1
      (Handle.facts (familyGraph T.toTpl.ops (PDim.eval ν) o n ss).2 (out, cs) ++
        Handle.facts (T.tapsOf (PDim.eval ν) o n ss) taps) := by
  have h := forwardX_sim T hS ν o n ss [] (fun _ h => by cases h) ((out, cs), taps) hv
  rw [familyGraph_toTpl]
  obtain ⟨h1, _⟩ := h
  exact h1.mono P K env ks fun q hq => List.mem_append_left _ hq

theorem forwardT_toTpl_value (T : RowTplX κ) (ν : Nat → Int) (o n : Nat) (ss : List StageLayout) (out : Value)
    (cs : List (Value × Value)) (taps : List (List (List Value)))
    (hv : forwardTX T (valueB P K env ks) (PDim.eval ν) o n ss = some ((out, cs), taps)) :
    forwardT T.toTpl (valueB P K env ks) (PDim.eval ν) o n ss = some (out, cs) := by
  rw [forwardT_toTpl, hv]; rfl

end

end Host.Mlx.SimGraph
