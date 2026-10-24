import host.simgraph.ref.Chain
import host.simgraph.family.KernelSlot
namespace Host.Mlx.SimGraph.Ref
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep Host.Mlx.SimGraph Inference.Contracts.Mlx
open Host.Ts.Sim.Prefill (Phase)

/-! # The route's step semantics from the forward families' value instances

A prefill step of `n` rows at offset `o` runs the forward its dispatch selects (phase-dispatch.ts:76,
the model's `prompt`/`promptChunk` ranges, models/qwen/qwen38-27b-trellis-m1max.ts:1180-1181; prefill
map §2). Its value semantics here:

* one row (the final step, a one-row tail): D1, the decode chain `chainTrace` at offset `o` on the
  embedding of `π[o]` (`d1Sem`; the D1 family is the decode step, `forwardP_d1`);
* `2 … 223` rows (tails) and whole chunks of 64 or 128 rows: the GPU row family's value instance
  `forwardT T (valueB P K env' (ksR P K env'))` (`rowSem`, `gpuFamily`), at the step's environment
  (`stepEnv`: the decode step's inputs from the handles, the prompt ids of the rows, the
  dimension-valued data, `promptInputs`) and the handles' layouts, its caches read back as handles
  (`handlesOf`). The dimensions are read at the canonical representation `refRows` (offset at
  position 0, rows at 1) and valuation `refNu o n`;
* the Neural Engine buckets (224–2048-row tails, 256–2048-row chunks): `host.simgraph.ref.Ane`.

VW's MLP takes `rowBlocks r` (gate-up-mma-wide.ts:122) and the down pass `downPlan r`
(down-mma-wide.ts `plan`, row-major layout; the interleaved layers' one-block pass is the family's). -/

/-- The canonical rows representation of the reference: the offset at position 0, the rows at 1. -/
def refRows : Rows := ⟨Aff.var 0, Aff.var 1⟩

/-- The valuation of a step at offset `o` with `n` rows. -/
def refNu (o n : Nat) (x : Nat) : Int := if x = 0 then o else if x = 1 then n else 0

theorem refRows_o (o n : Nat) : refRows.oP.eval (refNu o n) = o := by
  simp [refRows, Rows.oP, Aff.eval_toP, Aff.eval_var, refNu]

theorem refRows_n (o n : Nat) : refRows.nP.eval (refNu o n) = n := by
  simp [refRows, Rows.nP, Aff.eval_toP, Aff.eval_var, refNu]

/-- `down-mma-wide.ts` `plan("rowMajor", M)` (binary64 costs `0.6`, `1`, `1.44` per pass of `⌈M/(8·MT)⌉`,
the later on a tie), at the rows VW reaches: 9–223 and the chunks 64, 128 (tabulated from the
TypeScript's arithmetic). -/
def downPlan (r : Nat) : DownPass :=
  if r ≤ 8 then ⟨16, 1⟩
  else if r ≤ 16 then ⟨8, 2⟩ else if r ≤ 24 then ⟨8, 3⟩ else if r ≤ 32 then ⟨8, 2⟩ else if r ≤ 48 then ⟨8, 3⟩
  else if r ≤ 64 then ⟨8, 2⟩ else if r ≤ 72 then ⟨8, 3⟩ else if r ≤ 80 then ⟨8, 2⟩ else if r ≤ 96 then ⟨8, 3⟩
  else if r ≤ 112 then ⟨8, 2⟩ else if r ≤ 120 then ⟨8, 3⟩ else if r ≤ 128 then ⟨8, 2⟩ else if r ≤ 144 then ⟨8, 3⟩
  else if r ≤ 160 then ⟨8, 2⟩ else if r ≤ 168 then ⟨8, 3⟩ else if r ≤ 176 then ⟨8, 2⟩ else if r ≤ 216 then ⟨8, 3⟩
  else ⟨8, 2⟩

/-- **The GPU row family** of a step of `n ≥ 2` rows and phase `ph` (none: a Neural Engine class). -/
def gpuFamily (ph : Phase) (n : Nat) : Option (RowTpl PKey) :=
  match ph with
  | .chunk => if n = 64 ∨ n = 128 then some (vw refRows (Metal.Kernels.GateUpMmaWide.rowBlocks n) (downPlan n)) else none
  | _ =>
    if n ≤ 3 then some (v23 refRows) else if n = 4 then some (v4 refRows)
    else if n = 5 then some (v58 refRows .causal) else if n ≤ 8 then some (v58 refRows (.folded n))
    else if n ≤ 223 then some (vw refRows (Metal.Kernels.GateUpMmaWide.rowBlocks n) (downPlan n)) else none

/-- The layers' caches as handles (SSM: conv state, recurrent state; KV: keys, values). -/
def handlesOf : List StageWeights → List (Value × Value) → Option (List Handles)
  | [], [] => some []
  | .delta _ :: ws, (a, b) :: cs => (handlesOf ws cs).map (.delta (some a) (some b) :: ·)
  | .attention _ :: ws, (a, b) :: cs => (handlesOf ws cs).map (.attention (some a) (some b) :: ·)
  | _, _ => none

/-- The prompt ids of rows `[o, o + n)`: the int32 `[1, n]` array the step builds
(`ops.fromInt32(chunk, [1, len])`, generation/prefill.ts:24; the B-newdata node's value). -/
def rowIds (π : List Nat) (o n : Nat) : Option Value :=
  cellsValue (((π.drop o).take n).map Int.ofNat) [1, n]

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (w : PipelineWeights) (π : List Nat)

/-- A multi-row step's environment: the checkpoint, the decode step's inputs from the handles, the
rows' prompt ids and the dimension-valued data at the step's valuation. -/
def stepEnv (o n : Nat) (ids : Value) (hs : List Handles) : Env PKey :=
  ⟨weights, promptInputs (stepInputs w 0 hs) ids (refNu o n)⟩

/-- **A GPU row family's step**: its value instance at the step's environment and the handles'
layouts; the caches it returns, as handles. -/
noncomputable def rowSem (T : RowTpl PKey) (o n : Nat) (hs : List Handles) : Option (List Handles) := do
  let ids ← rowIds π o n
  let env' := stepEnv weights w o n ids hs
  let r ← forwardT T (valueB P K.toKernelContract env' (ksR P K env')) (PDim.eval (refNu o n)) o n
    (chainLayout (stageWeights w) hs)
  handlesOf (stageWeights w) r.2

/-- **A D1 step**: the decode chain at offset `o` on the embedding of the row's token. -/
noncomputable def d1Sem (o : Nat) (hs : List Handles) : Option (List Handles) := do
  let x ← embedTrace P.toMlxContract w.embedWords w.embedScales w.embedBiases (π.getD o 0)
  let r ← chainTrace P.toMlxContract K.toKernelContract o (stageWeights w) hs x
  pure r.2

end


/-- The GPU classes cover every tail of 2–223 rows. -/
theorem gpuFamily_tail {n : Nat} (ph : Phase) (hph : ph ≠ .chunk) (h : n ≤ 223) : (gpuFamily ph n).isSome := by
  cases ph with
  | chunk => exact absurd rfl hph
  | tail | decode =>
    simp only [gpuFamily]
    split_ifs <;> rfl

end Host.Mlx.SimGraph.Ref
