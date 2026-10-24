import host.simgraph.family.MatchEmbed
import host.simgraph.family.Families
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # A multi-row step from a checked family template

`FamilyTemplate F` is `PromptTemplate F` with the closure-aware check
(`MatchesED`, its closure objects named by `kind`). For an iteration's graph
`G` that embeds the template graph evaluated at `ν` (`Embeds σ cl`, closures
renamed by `cl`, named by `kind'` with `kind' ∘ cl = kind`):

* `family_template_matches`: `G` carries the family's graph at `ν`;
* `family_template_step`: every value the family's graph has at `ν` is the
  value (`evalRP`) of its carrier in `G`, given the input carriers hold the
  inputs and the kernel nodes evaluate as `ks`;
* `rowTpl_graph_step`: for a GPU row family, when the reference computation
  returns the final hidden state `out` and the caches `cs`, `G`'s carriers of
  the output and of every cache hold them — the forward stage's graph
  postcondition ("inputs and caches in, graph and caches out"). -/

/-- A multi-row step template of family `F`, checked once with its closures. -/
structure FamilyTemplate {κ : Type} [DecidableEq κ] (F : RowFamily κ) where
  o₀ : Nat
  n₀ : Nat
  ss₀ : List StageLayout
  Gs : Nat → Option (RNode PDim κ)
  kind : Nat → Option Compiled
  cert : List Nat
  checked : MatchesED kind Gs (familyGraph F.ops id o₀ n₀ ss₀).1 cert = true
  length : (familyGraph F.ops id o₀ n₀ ss₀).1.length ≤ cert.length

section
variable {κ : Type} [DecidableEq κ] {F : RowFamily κ} (T : FamilyTemplate F) (ν : Nat → Int) (o n : Nat)
  (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR F.ops.sig T.o₀ T.n₀ o n) T.ss₀ ss)
include hsig

theorem family_template_length :
    (familyGraph F.ops (PDim.eval ν) o n ss).1.length ≤ T.cert.length := by
  rw [← congrArg Prod.fst (family_eval F T.o₀ T.n₀ T.ss₀ ν o n ss hsig), List.length_map]
  exact T.length

theorem family_template_matches (G : Nat → Option (RNode Int κ)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G) (kind' : Nat → Option Compiled)
    (hk : ∀ c, kind' (cl c) = T.kind c) :
    MatchesED kind' G (familyGraph F.ops (PDim.eval ν) o n ss).1 (T.cert.map σ) = true := by
  rw [← congrArg Prod.fst (family_eval F T.o₀ T.n₀ T.ss₀ ν o n ss hsig)]
  exact matchesED_embed T.kind kind' hk _ G emb _ _ (by rw [List.length_map]; exact T.length)
    (matchesED_map (PDim.eval ν) T.kind T.Gs _ T.cert T.checked)

/-- **The graph side of a multi-row step.** -/
theorem family_template_step {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) (env : Env κ)
    (ks : KernelSem) (G : Nat → Option (RNode Int κ)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G) (kind' : Nat → Option Compiled)
    (hk : ∀ c, kind' (cl c) = T.kind c)
    (hin : InputsHeldE P K env kind' G (familyGraph F.ops (PDim.eval ν) o n ss).1 (T.cert.map σ))
    (hks : KernelsAgree P K env ks) (i : Nat) (v : Value)
    (hv : EvE P K env ks (familyGraph F.ops (PDim.eval ν) o n ss).1 i v) :
    evalRP P K env kind' G (σ (certAt T.cert i)) = some v := by
  have hm := family_template_matches T ν o n ss hsig G σ cl emb kind' hk
  have hl := family_template_length T ν o n ss hsig
  rw [← certAt_map σ T.cert i (by have := hv.1; omega)]
  exact matches_evalE P K env ks kind' G _ _ hm hin hks i hv.1 v hv.2

end

/-! ## The GPU row families -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) (env : Env PKey) (ks : KernelSem)
  (R : Rows) (pk : ProjKind) (mk : MlpKind) (rd : Read)

/-- **The forward stage's graph postcondition** for a GPU row family: the
iteration's graph carries the family's graph (from the checked template),
and when the step's reference computation returns the final hidden state
`out` and the layers' caches `cs`, the carriers of the output node and of
every cache node hold them. -/
theorem rowTpl_graph_step (T : FamilyTemplate (rowFamily R pk mk rd)) (ν : Nat → Int) (o n : Nat)
    (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR kvSigP T.o₀ T.n₀ o n) T.ss₀ ss)
    (G : Nat → Option (RNode Int PKey)) (σ cl : Nat → Nat) (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G)
    (kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = T.kind c)
    (hin : InputsHeldE P K env kind' G (familyGraph (rowTpl R pk mk rd).ops (PDim.eval ν) o n ss).1 (T.cert.map σ))
    (hks : KernelsAgree P K env ks) (out : Value) (cs : List (Value × Value))
    (hv : forwardT (rowTpl R pk mk rd) (valueB P K env ks) (PDim.eval ν) o n ss = some (out, cs)) :
    ∀ q ∈ Handle.facts (familyGraph (rowTpl R pk mk rd).ops (PDim.eval ν) o n ss).2 (out, cs),
      evalRP P K env kind' G (σ (certAt T.cert q.1)) = some q.2 := by
  intro q hq
  have hall := rowTpl_eval (P := P) (K := K) (env := env) (ks := ks) R pk mk rd ν o n ss out cs hv
  exact family_template_step T ν o n ss hsig P K env ks G σ cl emb kind' hk hin hks q.1 q.2 (hall q hq)

end

end Host.Mlx.SimGraph
