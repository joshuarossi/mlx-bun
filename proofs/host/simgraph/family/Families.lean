import host.simgraph.family.LayerSim
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # The GPU row families

Each reachable GPU row class of the prefill (prefill-map §2–3) as a
`RowTpl PKey` at the step's symbolic offset and rows `R`:

| family | rows | projections | MLP | attention read |
|---|---|---|---|---|
| `v23` | 2–3 | `affine{3,4}_rows` | codebook MMA, one-block down | causal SDPA |
| `v4` | 4 | `affine_split_mma` | codebook MMA, one-block down | causal SDPA |
| `v58 .causal` | 5 | `affine_split_mma` | codebook MMA, one-block down | causal SDPA |
| `v58 (.folded r)` | 6–8 | `affine_split_mma` | codebook MMA, one-block down | folded |
| `vw mt pass` | 9–223, chunks 64/128 | `affine_split_mma` | wide MMA (`MT`), planned down | causal SDPA |

(D1 is `d1Ops`.) The embedding reads the prompt ids (`PKey.promptIds`),
the head is the final norm (drains and tails compute no logits). Stage `p`'s
inputs are `PKey.base (.stage p ·)`; its host data: `Tin = [r]`
(`cells p 0`), the folded read's key limits `o + (ρ mod r)` (`cells p 1`)
and key positions `0 … o+r-1` (`iota p 2`).

For each family: `IsNatural`, `SigOK` (`RowFamily`), and `Simulates` (the
graph instance carries the value instance), so `familyGraph_eval` applies. -/

/-- The projection kind. -/
inductive ProjKind where
  | rows
  | split
deriving DecidableEq

/-- The MLP kind. -/
inductive MlpKind where
  | codebook
  | wide (mt : Nat) (pass : DownPass)
deriving DecidableEq

section
variable {δ κ : Type} {m : Type → Type} [Monad m] {α : Type} (B : Backend δ κ m α) (I : PDim → δ) (R : Rows)

def projT : ProjKind → LinLayout → (LinKey → κ) → α → m α
  | .rows => rowsProjT B I R
  | .split => splitProjT B I R

def mlpT : MlpKind → MlpLayout → (MlpKey → κ) → α → m α
  | .codebook => codebookMlpT B I R
  | .wide mt pass => wideMlpT B I R mt pass

end

/-- Stage `p`'s inputs. -/
def stageKey (p : Nat) (k : SKey) : PKey := .base (.stage p k)

/-- Stage `p`'s host data at `R` (folded at `r` rows for the limits). -/
def auxKey (R : Rows) (rd : Read) (p : Nat) : Nat → PKey
  | 0 => .cells p 0 [R.nP] [.lit 1]
  | 1 => match rd with
    | .causal => .cells p 1 [] []
    | .folded r => .cells p 1 ((List.range (6 * r)).map fun ρ : Nat => (R.o.add (.const ((ρ % r : Nat) : Int))).toP)
        [.lit (6 * r), .lit 1]
  | _ => .iota p 2 R.onP

/-- A GPU row family at the step's symbolic offset and rows. -/
def rowTpl (R : Rows) (pk : ProjKind) (mk : MlpKind) (rd : Read) : RowTpl PKey where
  sig := kvSigP
  embed B _ := embedT B PKey.promptIds PKey.base
  layer B I o n p s x := match s with
    | .delta d => deltaLayerT B I (projT B I R pk) (mlpT B I R mk) R d (stageKey p) (auxKey R rd p) x
    | .attention a => attentionLayerT B I (projT B I R pk) (mlpT B I R mk) R o n rd a (stageKey p) (auxKey R rd p) x
  final B _ y := normT B (PKey.base .finalNorm) y

def v23 (R : Rows) : RowTpl PKey := rowTpl R .rows .codebook .causal
def v4 (R : Rows) : RowTpl PKey := rowTpl R .split .codebook .causal
def v58 (R : Rows) (rd : Read) : RowTpl PKey := rowTpl R .split .codebook rd
def vw (R : Rows) (mt : Nat) (pass : DownPass) : RowTpl PKey := rowTpl R .split (.wide mt pass) .causal

/-! ## Naturality and branches -/

section
variable (R : Rows) (pk : ProjKind) (mk : MlpKind) (rd : Read)

theorem nat_projT {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (lay : LinLayout) (key : LinKey → PKey) (x : Nat) :
    Natural f (projT graphB I R pk lay key x) (projT graphB (fun d => f (I d)) R pk lay key x) := by
  cases pk
  · exact nat_rowsProjT f I R lay key x
  · exact nat_splitProjT f I R lay key x

theorem nat_mlpT {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (lay : MlpLayout) (key : MlpKey → PKey) (x : Nat) :
    Natural f (mlpT graphB I R mk lay key x) (mlpT graphB (fun d => f (I d)) R mk lay key x) := by
  cases mk
  · exact nat_codebookMlpT f I R lay key x
  · exact nat_wideMlpT f I R _ _ lay key x

theorem rowTpl_natural : (rowTpl R pk mk rd).ops.IsNatural where
  embed f _ := by dsimp only [RowTpl.ops, rowTpl]; exact nat_embedT f PKey.promptIds PKey.base
  layer f I o n p s x := by
    dsimp only [RowTpl.ops, rowTpl]
    cases s with
    | delta d =>
      exact nat_deltaLayerT f _ _ _ _ (nat_projT R pk f I) (nat_mlpT R mk f I) R d _ _ x
    | attention a =>
      exact nat_attentionLayerT f _ _ _ _ (nat_projT R pk f I) (nat_mlpT R mk f I) R o n rd a _ _ x
  final f _ y := by dsimp only [RowTpl.ops, rowTpl]; exact nat_normT f _ y

theorem rowTpl_sigOK : (rowTpl R pk mk rd).ops.SigOK := by
  intro δ I o n o' n' p s s' x h
  cases s with
  | delta d =>
    cases s' with
    | delta d' => cases (h : d = d'); rfl
    | attention _ => exact h.elim
  | attention a =>
    cases s' with
    | delta _ => exact h.elim
    | attention a' => exact attentionLayerT_sig I _ _ R o n o' n' rd a a' h _ _ x

/-- The family with its obligations (for `PromptTemplate`). -/
def rowFamily : RowFamily PKey := ⟨(rowTpl R pk mk rd).ops, rowTpl_natural R pk mk rd, rowTpl_sigOK R pk mk rd⟩

end

/-! ## The reference computation -/

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {K : KernelContract C} {env : Env PKey} {ks : KernelSem}
  (R : Rows) (pk : ProjKind) (mk : MlpKind) (rd : Read)

theorem sim_projT (ν : Nat → Int) (lay : LinLayout) (key : LinKey → PKey) (fs : List (Nat × Value)) (x : Nat)
    (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (projT graphB (PDim.eval ν) R pk lay key x) (projT (valueB P K env ks) (PDim.eval ν) R pk lay key v) := by
  cases pk
  · exact sim_rowsProjT ν R lay key fs x v h
  · exact sim_splitProjT ν R lay key fs x v h

theorem sim_mlpT (ν : Nat → Int) (lay : MlpLayout) (key : MlpKey → PKey) (fs : List (Nat × Value)) (x : Nat)
    (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (mlpT graphB (PDim.eval ν) R mk lay key x) (mlpT (valueB P K env ks) (PDim.eval ν) R mk lay key v) := by
  cases mk
  · exact sim_codebookMlpT ν R lay key fs x v h
  · exact sim_wideMlpT ν R _ _ lay key fs x v h

/-- **The family's builder carries its reference computation.** -/
theorem rowTpl_simulates : (rowTpl R pk mk rd).Simulates P K env ks where
  embed _ fs := by dsimp only [rowTpl]; exact sim_embedT PKey.promptIds PKey.base fs
  layer ν o n p s x v fs h := by
    dsimp only [rowTpl]
    cases s with
    | delta d =>
      exact sim_deltaLayerT ν _ _ _ _ (fun lay key fs x v h => sim_projT R pk ν lay key fs x v h)
        (fun lay key fs x v h => sim_mlpT R mk ν lay key fs x v h) R d _ _ fs x v h
    | attention a =>
      exact sim_attentionLayerT ν _ _ _ _ (fun lay key fs x v h => sim_projT R pk ν lay key fs x v h)
        (fun lay key fs x v h => sim_mlpT R mk ν lay key fs x v h) R o n rd a _ _ fs x v h
  final _ y v fs h := by dsimp only [rowTpl]; exact sim_normT fs _ y v h

/-- **The family's expected graph holds its reference values**: when the
reference computation of the step (`forwardT` at the value backend) returns
the final hidden state `out` and the caches `cs`, the expected graph's output
and cache nodes hold them. -/
theorem rowTpl_eval (ν : Nat → Int) (o n : Nat) (ss : List StageLayout) (out : Value) (cs : List (Value × Value))
    (hv : forwardT (rowTpl R pk mk rd) (valueB P K env ks) (PDim.eval ν) o n ss = some (out, cs)) :
    AllEvE P K env ks (familyGraph (rowTpl R pk mk rd).ops (PDim.eval ν) o n ss).1
      (Handle.facts (familyGraph (rowTpl R pk mk rd).ops (PDim.eval ν) o n ss).2 (out, cs)) :=
  familyGraph_eval (rowTpl R pk mk rd) (rowTpl_simulates R pk mk rd) ν o n ss out cs hv

end

end Host.Mlx.SimGraph
