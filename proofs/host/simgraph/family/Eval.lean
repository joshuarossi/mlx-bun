import host.simgraph.prompt.PromptBuild
import host.mlx.FfiEvalPrefill
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # Values of a row family's expected graph

A family's expected graph `E` (`familyGraph`) is a straight-line program:
each node applies a primitive to earlier nodes. `evalE` evaluates it:

* MLX built-ins by `primEvalP` (the multi-row semantics over
  `MlxPrefillContract`), `compute_g` by `computeGP`;
* a compiled closure (`nn.silu`, `swiglu`, `_precise_swiglu`) is one
  expected node `closureP c` (the FFI graph holds its replayed body), valued
  by `compiledValue`;
* a custom kernel node by an abstract kernel semantics `ks` (the launch of a
  route kernel by name, resolved configuration and output): the kernel
  contract's fields slot in for it, so the families are stated before those
  fields exist.

Templates are written once against a `Backend` and instantiated twice: the
graph backend `graphB` emits nodes (the family's builder, `RowOps`), the
value backend `valueB` computes values (the family's reference computation).
`Sim fs b bv` relates a builder to its value computation: from a graph whose
nodes hold the facts `fs`, the builder's result nodes hold the value
computation's results (`sim_bind`, `sim_op`, `sim_inp`, `sim_pure`; the
tactic `sim_peel` chains them). -/

/-! ## Compiled closures as expected nodes -/

def closureName : Compiled → List Char
  | .silu => chars!"compiled:silu"
  | .swiglu => chars!"compiled:swiglu"
  | .preciseSwiglu => chars!"compiled:precise_swiglu"

/-- The expected node of compiled closure `c` (an operation name MLX never records). -/
def closureP {δ κ : Type} (c : Compiled) : RPrim δ κ := .unary (closureName c)

/-- The closure an expected primitive names. -/
def closureOf? {δ κ : Type} : RPrim δ κ → Option Compiled
  | .unary op =>
    if op = closureName .silu then some .silu
    else if op = closureName .swiglu then some .swiglu
    else if op = closureName .preciseSwiglu then some .preciseSwiglu
    else none
  | _ => none

theorem closureOf_closureP {δ κ : Type} (c : Compiled) : closureOf? (closureP (δ := δ) (κ := κ) c) = some c := by
  cases c <;> rfl

/-! ## Evaluation -/

/-- A custom kernel's launch: route name, resolved configuration, output index,
inputs. -/
abbrev KernelSem := List Char → RCfg Int → Nat → List Value → Option Value

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

/-- An expected node's primitive on its arguments' values. -/
noncomputable def primEvalE (p : RPrim Int κ) (xs : List Value) : Option Value :=
  match p with
  | .kernel name c out => ks name c out xs
  | .computeG => computeGP P (κ := κ) xs
  | p => match closureOf? p with
    | some c => compiledValue P c xs
    | none => primEvalP P K env p xs

/-- The value of expected node `i` (arguments of smaller id). -/
noncomputable def evalE (g : Nat → Option (RNode Int κ)) (i : Nat) : Option Value :=
  match g i with
  | none => none
  | some nd => (nd.ins.mapM fun j => if _h : j < i then evalE g j else none).bind (primEvalE P K env ks nd.prim)
termination_by i

theorem evalE_eq (g : Nat → Option (RNode Int κ)) (i : Nat) : evalE P K env ks g i =
    match g i with
    | none => none
    | some nd => (nd.ins.mapM fun j => if _h : j < i then evalE P K env ks g j else none).bind
        (primEvalE P K env ks nd.prim) := by
  rw [evalE]

theorem evalE_append (g t : List (RNode Int κ)) :
    ∀ i, i < g.length → evalE P K env ks (listGraph (g ++ t)) i = evalE P K env ks (listGraph g) i := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro hi
  have hl : listGraph (g ++ t) i = listGraph g i := List.getElem?_append_left hi
  have hf : (fun j => if _h : j < i then evalE P K env ks (listGraph (g ++ t)) j else none) =
      (fun j => if _h : j < i then evalE P K env ks (listGraph g) j else none) := by
    funext j
    by_cases h : j < i
    · rw [dite_eq_left h, dite_eq_left h, ih j h (by omega)]
    · rw [dite_eq_right h, dite_eq_right h]
  rw [evalE_eq, evalE_eq, hl, hf]

/-- Node `i` of `g` has value `v` (in every extension of `g`). -/
def EvE (g : List (RNode Int κ)) (i : Nat) (v : Value) : Prop :=
  i < g.length ∧ evalE P K env ks (listGraph g) i = some v

theorem EvE.app {g : List (RNode Int κ)} {i : Nat} {v : Value} (h : EvE P K env ks g i v) (t : List (RNode Int κ)) :
    EvE P K env ks (g ++ t) i v :=
  ⟨by have := h.1; rw [List.length_append]; omega, by rw [evalE_append P K env ks g t i h.1]; exact h.2⟩

/-- The facts `fs` hold in `g`. -/
def AllEvE (g : List (RNode Int κ)) (fs : List (Nat × Value)) : Prop := ∀ q ∈ fs, EvE P K env ks g q.1 q.2

theorem AllEvE.app {g : List (RNode Int κ)} {fs : List (Nat × Value)} (h : AllEvE P K env ks g fs)
    (t : List (RNode Int κ)) : AllEvE P K env ks (g ++ t) fs := fun q hq => (h q hq).app P K env ks t

theorem AllEvE.mono {g : List (RNode Int κ)} {fs fs' : List (Nat × Value)} (h : AllEvE P K env ks g fs)
    (hs : ∀ q ∈ fs', q ∈ fs) : AllEvE P K env ks g fs' := fun q hq => h q (hs q hq)

end

/-! ## Backends -/

/-- An operation backend: graph building (handles are node ids) or evaluation
(handles are values). -/
structure Backend (δ κ : Type) (m : Type → Type) (α : Type) where
  op : RPrim δ κ → List α → m α
  inp : κ → m α

/-- Building the expected graph. -/
@[reducible] def graphB {δ κ : Type} : Backend δ κ (Build δ κ) Nat := ⟨emit, fun k => emit (.input k) []⟩

/-- Computing the values. -/
@[reducible] noncomputable def valueB {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type}
    (env : Env κ) (ks : KernelSem) : Backend Int κ Option Value :=
  ⟨primEvalE P K env ks, env.inputs⟩

/-! ## Builders and their value computations -/

/-- How a builder's result relates to its value computation's: the facts
`(node, value)` it contributes. -/
class Handle (α β : Type) where
  facts : α → β → List (Nat × Value)

instance : Handle Nat Value := ⟨fun i v => [(i, v)]⟩
instance {α β α' β' : Type} [Handle α β] [Handle α' β'] : Handle (α × α') (β × β') :=
  ⟨fun a b => Handle.facts a.1 b.1 ++ Handle.facts a.2 b.2⟩
instance {α β : Type} [Handle α β] : Handle (List α) (List β) :=
  ⟨fun as bs => (List.zip as bs).flatMap fun p => Handle.facts p.1 p.2⟩

@[simp] theorem facts_nat (i : Nat) (v : Value) : Handle.facts i v = [(i, v)] := rfl
@[simp] theorem facts_prod {α β α' β' : Type} [Handle α β] [Handle α' β'] (a : α × α') (b : β × β') :
    Handle.facts a b = Handle.facts a.1 b.1 ++ Handle.facts a.2 b.2 := rfl
@[simp] theorem facts_list {α β : Type} [Handle α β] (as : List α) (bs : List β) :
    Handle.facts as bs = (List.zip as bs).flatMap fun p => Handle.facts p.1 p.2 := rfl

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

/-- From a graph holding `fs`, the builder `b`'s result holds `bv`'s value (and `fs` stays). -/
def Sim {α β : Type} [Handle α β] (fs : List (Nat × Value)) (b : Build Int κ α) (bv : Option β) : Prop :=
  ∀ g, AllEvE P K env ks g fs → ∀ v, bv = some v →
    Spec b g (fun a g' => AllEvE P K env ks g' (Handle.facts a v ++ fs) ∧ ∃ t, g' = g ++ t)

variable {P K env ks}

theorem sim_bind {α β γ ε : Type} [Handle α β] [Handle γ ε] {fs : List (Nat × Value)} {x : Build Int κ α}
    {xv : Option β} {k : α → Build Int κ γ} {kv : β → Option ε} (hx : Sim P K env ks fs x xv)
    (hk : ∀ a v, Sim P K env ks (Handle.facts a v ++ fs) (k a) (kv v)) :
    Sim P K env ks fs (x >>= k) (xv >>= kv) := by
  intro g hg w hw
  obtain ⟨v, hv, hkv⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨h1, t1, ht1⟩ := hx g hg v hv
  obtain ⟨h2, t2, ht2⟩ := hk (run x g).1 v (run x g).2 h1 w hkv
  refine ⟨h2.mono P K env ks fun q hq => ?_, t1 ++ t2, ?_⟩
  · rcases List.mem_append.mp hq with hq | hq
    · exact List.mem_append_left _ hq
    · exact List.mem_append_right _ (List.mem_append_right _ hq)
  · show (run (k (run x g).1) (run x g).2).2 = _
    rw [ht2, ht1, List.append_assoc]

theorem sim_pure {α β : Type} [Handle α β] {fs : List (Nat × Value)} {a : α} {v : β}
    (h : ∀ q ∈ Handle.facts a v, q ∈ fs) : Sim P K env ks fs (pure a) (some v) := by
  intro g hg w hw
  cases hw
  refine ⟨fun q hq => ?_, [], by simp [run, pure, StateT.pure]⟩
  rcases List.mem_append.mp hq with hq | hq
  · exact hg q (h q hq)
  · exact hg q hq

theorem sim_emit {fs : List (Nat × Value)} (p : RPrim Int κ) (ins : List Nat) (vs : List Value)
    (hargs : List.Forall₂ (fun i v => (i, v) ∈ fs) ins vs) :
    Sim P K env ks fs (emit p ins) (primEvalE P K env ks p vs) := by
  intro g hg w hw
  have hmap0 : ∀ (t : List (RNode Int κ)) (js : List Nat) (us : List Value),
      List.Forall₂ (fun i v => (i, v) ∈ fs) js us →
      (js.mapM fun j => if _h : j < g.length then evalE P K env ks (listGraph (g ++ t)) j else none) = some us := by
    intro t js us h
    induction h with
    | nil => rfl
    | @cons j v js vs' hjv _ ih =>
      have hj := hg _ hjv
      rw [List.mapM_cons, dite_eq_left hj.1, evalE_append P K env ks g _ j hj.1, hj.2, ih]
      rfl
  have hmap := hmap0 [⟨p, ins⟩] ins vs hargs
  have hE : EvE P K env ks (g ++ [⟨p, ins⟩]) g.length w := by
    refine ⟨by simp, ?_⟩
    rw [evalE_eq]
    have hl : listGraph (g ++ [⟨p, ins⟩]) g.length = some ⟨p, ins⟩ := by simp [listGraph]
    rw [hl]
    simp only
    rw [hmap]
    exact hw
  refine ⟨fun q hq => ?_, [⟨p, ins⟩], rfl⟩
  rcases List.mem_cons.mp hq with rfl | hq
  · exact hE
  · exact (hg q hq).app P K env ks _

theorem sim_op {fs : List (Nat × Value)} (p : RPrim Int κ) (ins : List Nat) (vs : List Value)
    (hargs : List.Forall₂ (fun i v => (i, v) ∈ fs) ins vs) :
    Sim P K env ks fs (graphB.op p ins) ((valueB P K env ks).op p vs) :=
  sim_emit p ins vs hargs

theorem sim_inp {fs : List (Nat × Value)} (k : κ) :
    Sim P K env ks fs (graphB.inp k) ((valueB P K env ks).inp k) := by
  show Sim P K env ks fs (emit (.input k) []) (env.inputs k)
  have : primEvalE P K env ks (.input k) [] = env.inputs k := by
    simp only [primEvalE, closureOf?, primEvalP, primEval, Option.orElse]
    cases env.inputs k <;> rfl
  rw [← this]
  exact sim_emit _ [] [] .nil

theorem sim_ite {α β : Type} [Handle α β] {fs : List (Nat × Value)} (c : Prop) [Decidable c]
    {b₁ b₂ : Build Int κ α} {v₁ v₂ : Option β} (h₁ : c → Sim P K env ks fs b₁ v₁) (h₂ : ¬ c → Sim P K env ks fs b₂ v₂) :
    Sim P K env ks fs (if c then b₁ else b₂) (if c then v₁ else v₂) := by
  by_cases hc : c
  · simp only [hc, ↓reduceIte]; exact h₁ hc
  · simp only [hc, ↓reduceIte]; exact h₂ hc

theorem sim_map {α β γ ε : Type} [Handle α β] [Handle γ ε] {fs : List (Nat × Value)} {x : Build Int κ α}
    {xv : Option β} (g : α → γ) (h : β → ε) (hx : Sim P K env ks fs x xv)
    (hg : ∀ a v, ∀ q ∈ Handle.facts (g a) (h v), q ∈ Handle.facts a v ++ fs) :
    Sim P K env ks fs (g <$> x) (h <$> xv) := by
  intro gr hgr w hw
  obtain ⟨v, hv, rfl⟩ := Option.map_eq_some_iff.mp hw
  obtain ⟨h1, t, ht⟩ := hx gr hgr v hv
  refine ⟨fun q hq => ?_, t, ht⟩
  rcases List.mem_append.mp hq with hq | hq
  · exact h1 q (hg _ _ q hq)
  · exact h1 q (List.mem_append_right _ hq)

theorem sim_weaken {α β : Type} [Handle α β] {fs fs' : List (Nat × Value)} {b : Build Int κ α} {bv : Option β}
    (h : Sim P K env ks fs' b bv) (hs : ∀ q ∈ fs', q ∈ fs) : Sim P K env ks fs b bv := by
  intro g hg v hv
  obtain ⟨h1, t, ht⟩ := h g (hg.mono P K env ks hs) v hv
  refine ⟨fun q hq => ?_, t, ht⟩
  rcases List.mem_append.mp hq with hq | hq
  · exact h1 q (List.mem_append_left _ hq)
  · rw [ht]; exact (hg q hq).app P K env ks t

end

theorem subset_nil {γ : Type} (l : List γ) : ∀ q ∈ ([] : List γ), q ∈ l := fun _ h => by cases h

theorem subset_cons_of {γ : Type} {a : γ} {l₁ l₂ : List γ} (ha : a ∈ l₂) (h : ∀ q ∈ l₁, q ∈ l₂) :
    ∀ q ∈ a :: l₁, q ∈ l₂ := by
  intro q hq
  rcases List.mem_cons.mp hq with rfl | hq
  · exact ha
  · exact h q hq

/-- Membership in a list of facts: a listed fact or a hypothesis. -/
syntax "mem_facts" : tactic
macro_rules
  | `(tactic| mem_facts) => `(tactic| first
      | apply List.mem_cons_self
      | assumption
      | (apply List.mem_cons_of_mem; mem_facts))

/-- Flatten the facts, then find the member. -/
macro "mem_tac" : tactic => `(tactic|
  ((try simp only [facts_nat, facts_prod, List.cons_append, List.nil_append, List.append_assoc]); mem_facts))

/-- The argument facts of an operation (`Forall₂` of memberships). -/
macro "args_mem" : tactic => `(tactic|
  ((first | exact List.Forall₂.nil | refine List.Forall₂.cons ?_ ?_) <;>
    (repeat' (first | exact List.Forall₂.nil | refine List.Forall₂.cons ?_ ?_)) <;>
    (first | done | mem_tac)))

/-- Facts contained in the known facts. -/
macro "facts_sub" : tactic => `(tactic|
  ((try simp only [facts_nat, facts_prod, List.cons_append, List.nil_append, List.append_assoc]);
    (first | exact subset_nil _ | refine subset_cons_of ?_ ?_) <;>
    (repeat' (first | exact subset_nil _ | refine subset_cons_of ?_ ?_)) <;>
    (first | done | mem_facts)))

/-- Chain the steps of a builder and its value computation: operations,
inputs, mapped results and the final result, closing the argument and
result facts by membership. Stops at a sub-template that does not begin with
an operation. -/
macro "sim_peel" : tactic => `(tactic| ((repeat' (first
  | refine sim_bind (sim_op _ _ _ ?_) fun _ _ => ?_
  | refine sim_bind (sim_inp _) fun _ _ => ?_
  | refine sim_map _ _ (sim_op _ _ _ ?_) (fun _ _ => ?_)
  | refine sim_pure ?_
  | refine sim_op _ _ _ ?_
  | exact sim_inp _
  | args_mem
  | facts_sub))))

end Host.Mlx.SimGraph
