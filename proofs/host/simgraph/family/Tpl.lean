import host.simgraph.family.Eval
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # Row families written once

`RowTpl κ` is a row family's templates over any `Backend`: its builder is the
graph instance (`RowTpl.ops : RowOps κ`, so `familyGraph`, `PromptTemplate`
and `prompt_template_step` apply), its reference computation the value
instance (`forwardT T (valueB …)`). `RowTpl.Simulates` (each template's graph
instance carries its value instance, `Sim`) gives `forward_sim`: the family's
expected graph holds the reference computation's output and cache values
(`familyGraph_eval`). -/

/-- A row family's templates: the KV branch signature, the embedding, one
layer at chain position `p` with layout `s` (control offset `o`, rows `n`),
the head. -/
structure RowTpl (κ : Type) where
  sig : Option Nat → Nat → Nat → KvSig
  embed : {δ : Type} → {m : Type → Type} → [Monad m] → {α : Type} → Backend δ κ m α → (PDim → δ) → m α
  layer : {δ : Type} → {m : Type → Type} → [Monad m] → {α : Type} → Backend δ κ m α → (PDim → δ) →
    Nat → Nat → Nat → StageLayout → α → m (α × α × α)
  final : {δ : Type} → {m : Type → Type} → [Monad m] → {α : Type} → Backend δ κ m α → (PDim → δ) → α → m α

section
variable {κ : Type} (T : RowTpl κ) {δ : Type} {m : Type → Type} [Monad m] {α : Type} (B : Backend δ κ m α)
  (I : PDim → δ) (o n : Nat)

/-- The layers from chain position `p` at any backend. -/
def chainT : Nat → List StageLayout → α → m (α × List (α × α))
  | _, [], x => pure (x, [])
  | p, s :: ss, x => do
    let (y, c1, c2) ← T.layer B I o n p s x
    let (z, cs) ← chainT (p + 1) ss y
    pure (z, (c1, c2) :: cs)

/-- The family's step at any backend: the head's output and the cache handles. -/
def forwardT (ss : List StageLayout) : m (α × List (α × α)) := do
  let x ← T.embed B I
  let (y, cs) ← chainT T B I o n 0 ss x
  let r ← T.final B I y
  pure (r, cs)

end

/-- The family's builder: the graph instance. -/
def RowTpl.ops {κ : Type} (T : RowTpl κ) : RowOps κ where
  sig := T.sig
  embed I := T.embed graphB I
  layer I o n p s x := T.layer graphB I o n p s x
  final I y := T.final graphB I y

theorem chainP_ops {κ : Type} (T : RowTpl κ) {δ : Type} (I : PDim → δ) (o n : Nat) :
    ∀ (p : Nat) (ss : List StageLayout) (x : Nat), chainP T.ops I o n p ss x = chainT T graphB I o n p ss x
  | _, [], _ => rfl
  | p, s :: ss, x => by
    show (T.layer graphB I o n p s x >>= _) = (T.layer graphB I o n p s x >>= _)
    congr 1; funext r
    obtain ⟨y, c1, c2⟩ := r
    dsimp only
    rw [chainP_ops T I o n (p + 1) ss y]

theorem forwardP_ops {κ : Type} (T : RowTpl κ) {δ : Type} (I : PDim → δ) (o n : Nat) (ss : List StageLayout) :
    forwardP T.ops I o n ss = forwardT T graphB I o n ss := by
  unfold forwardP forwardT
  congr 1; funext x
  rw [chainP_ops T I o n 0 ss x]
  rfl

/-! ## The reference computation -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

/-- Each template's graph instance carries its value instance. -/
structure RowTpl.Simulates (T : RowTpl κ) : Prop where
  embed : ∀ (ν : Nat → Int) (fs : List (Nat × Value)),
    Sim P K env ks fs (T.embed graphB (PDim.eval ν)) (T.embed (valueB P K env ks) (PDim.eval ν))
  layer : ∀ (ν : Nat → Int) (o n p : Nat) (s : StageLayout) (x : Nat) (v : Value) (fs : List (Nat × Value)),
    (x, v) ∈ fs → Sim P K env ks fs (T.layer graphB (PDim.eval ν) o n p s x)
      (T.layer (valueB P K env ks) (PDim.eval ν) o n p s v)
  final : ∀ (ν : Nat → Int) (y : Nat) (v : Value) (fs : List (Nat × Value)),
    (y, v) ∈ fs → Sim P K env ks fs (T.final graphB (PDim.eval ν) y) (T.final (valueB P K env ks) (PDim.eval ν) v)

variable {P K env ks}

theorem chain_sim (T : RowTpl κ) (hS : T.Simulates P K env ks) (ν : Nat → Int) (o n : Nat) :
    ∀ (p : Nat) (ss : List StageLayout) (x : Nat) (v : Value) (fs : List (Nat × Value)), (x, v) ∈ fs →
      Sim P K env ks fs (chainT T graphB (PDim.eval ν) o n p ss x) (chainT T (valueB P K env ks) (PDim.eval ν) o n p ss v)
  | _, [], x, v, fs, h => sim_pure (by intro q hq; simp [Handle.facts] at hq; rcases hq with rfl; exact h)
  | p, s :: ss, x, v, fs, h => by
    refine sim_bind (hS.layer ν o n p s x v fs h) fun ⟨y, c1, c2⟩ ⟨vy, vc1, vc2⟩ => ?_
    dsimp only
    refine sim_bind (chain_sim T hS ν o n (p + 1) ss y vy _ (by simp [Handle.facts])) fun ⟨z, cs⟩ ⟨vz, vcs⟩ => ?_
    dsimp only
    refine sim_pure fun q hq => ?_
    simp only [Handle.facts, List.zip_cons_cons, List.flatMap_cons, List.mem_append] at hq ⊢
    rcases hq with hq | (hq | hq) | hq <;> simp_all

/-- **The family's step carries its reference computation.** -/
theorem forward_sim (T : RowTpl κ) (hS : T.Simulates P K env ks) (ν : Nat → Int) (o n : Nat) (ss : List StageLayout) :
    Sim P K env ks [] (forwardT T graphB (PDim.eval ν) o n ss) (forwardT T (valueB P K env ks) (PDim.eval ν) o n ss) := by
  refine sim_bind (hS.embed ν []) fun x vx => ?_
  refine sim_bind (chain_sim T hS ν o n 0 ss x vx _ (by simp [Handle.facts])) fun ⟨y, cs⟩ ⟨vy, vcs⟩ => ?_
  dsimp only
  refine sim_bind (hS.final ν y vy _ (by simp [Handle.facts])) fun r vr => ?_
  refine sim_pure fun q hq => ?_
  simp only [Handle.facts, List.mem_append] at hq ⊢
  rcases hq with hq | hq <;> simp_all

/-- **The family's expected graph holds the reference values**: when the
reference computation returns the output `out` and caches `cs`, the expected
graph's output node holds `out` and its cache nodes hold `cs`. -/
theorem familyGraph_eval (T : RowTpl κ) (hS : T.Simulates P K env ks) (ν : Nat → Int) (o n : Nat)
    (ss : List StageLayout) (out : Value) (cs : List (Value × Value))
    (hv : forwardT T (valueB P K env ks) (PDim.eval ν) o n ss = some (out, cs)) :
    AllEvE P K env ks (familyGraph T.ops (PDim.eval ν) o n ss).1
      (Handle.facts (familyGraph T.ops (PDim.eval ν) o n ss).2 (out, cs)) := by
  have h := forward_sim T hS ν o n ss [] (fun _ h => by cases h) (out, cs) hv
  unfold familyGraph
  rw [forwardP_ops]
  obtain ⟨h1, _⟩ := h
  exact h1.mono P K env ks fun q hq => List.mem_append_left _ hq

end

end Host.Mlx.SimGraph
