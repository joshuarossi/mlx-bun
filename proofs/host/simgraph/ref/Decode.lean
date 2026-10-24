import host.mlx.GlueM1Max
namespace Host.Mlx.SimGraph.Ref
open Inference Inference.Contracts.Mlx Inference.Kernels Inference.Models.Qwen Host.Mlx Host.Mlx.GlueStep
open TokenAutoregressive (State)

/-! # The reached context from any state

`GlueM1Max.context`'s `run` starts at time 0 from a token (`TokenAutoregressive.initial`). After a
prompt of `L` tokens the decode starts at time `L - 1` from the state the prefill reaches: the
prompt's last token and the cache after the other `L - 1`. Here the same recurrence from any
state `s0` at any time `t0` of a loaded pipeline:

* `advanceC`: one step of the context (`Logical.advance` at the context's parameters,
  primitives, sampler and RoPE angles);
* `refFrom s0 fill`: the states from `t0` on (`fill` below `t0`, where nothing reads them);
  `refFrom_start`, `refFrom_succ`;
* `advanceC_step`: one MLX decode step (`stepTrace`) from handles holding a state's cache
  returns the next state's token and handles holding its cache (`GlueM1Max.contextStep` from
  any state: the ranges come from the state's own range certificate);
* `advanceC_data`, `refFrom_model`: **against the model's definitions**, the next token is
  `GreedySampling.sample` of the pipeline's logits `TokenInference.Pipeline.run` at the state's
  cache and token and the route's RoPE inputs, the next cache is the pipeline's next cache. -/

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w)
  (parameters : TokenSequenceRanges.Parameters p)

/-- **One step of the reached context** of the loaded pipeline from the state `before`. -/
noncomputable def advanceC {time : Nat} (before : State p time) (supported : time + 1 ≤ 262144) : State p (time + 1) :=
  ReachedTokenContext.Logical.advance p (GlueM1Max.context M K p w hl parameters).parameters
    (GlueM1Max.context M K p w hl parameters).primitive (GlueM1Max.context M K p w hl parameters).sampling
    (GlueM1Max.context M K p w hl parameters).samplingPrimitive before
    ((GlueM1Max.context M K p w hl parameters).angles.value time)
    ((GlueM1Max.context M K p w hl parameters).angles.ranges time (by omega)) supported
    ((GlueM1Max.context M K p w hl parameters).angles.target time)
    ((GlueM1Max.context M K p w hl parameters).angles.error time)
    ((GlueM1Max.context M K p w hl parameters).angles.accuracy time (by omega))
    ((GlueM1Max.context M K p w hl parameters).angles.base time (by omega))

/-- **The step against the model's definitions**: the next token is the greedy sample of the
pipeline's logits, the next cache the pipeline's next cache. -/
theorem advanceC_data {time : Nat} (before : State p time) (supported : time + 1 ≤ 262144) :
    (advanceC M K p w hl parameters before supported).token.val =
        Sampling.GreedySampling.sample K.sampling
          (p.run before.cache before.token (RopeInputConstruction.inputs time)).1 ∧
      (advanceC M K p w hl parameters before supported).cache =
        (p.run before.cache before.token (RopeInputConstruction.inputs time)).2 := ⟨rfl, rfl⟩

/-- **One MLX decode step from a state** (`GlueM1Max.contextStep` from any state): from handles
holding the state's cache, the step's trace returns the next state's token and handles holding
its cache. -/
theorem advanceC_step {time : Nat} (before : State p time) (supported : time + 1 ≤ 262144) (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs before.cache) :
    ∃ hs', stepTrace M K w time before.token.val hs =
        some ((advanceC M K p w hl parameters before supported).token.val, hs') ∧
      ChainHolds p.graph.stages hs' (advanceC M K p w hl parameters before supported).cache := by
  let ctx := GlueM1Max.context M K p w hl parameters
  have lt : time < 262144 := by omega
  have ranges := ReachedSequenceRanges.Token.checked p ctx.parameters ctx.primitive before.cache before.cacheBound
    before.token (RopeInputConstruction.inputs time) (RopeInputConstruction.inputs_bound time lt) supported
  have numeric := ReachedSequenceRanges.Token.run_correct p ctx.parameters ctx.primitive before.cache
    before.cacheBound before.targetCache before.errorCache before.cacheError before.token
    (RopeInputConstruction.inputs time) (RopeInputConstruction.inputs_bound time lt) supported
    (RopeInputConstruction.target time) RopeInputConstruction.error (RopeInputConstruction.input_error time lt)
    (RopeInputConstruction.target_base_nonnegative time)
  obtain ⟨hs', e, h'⟩ := GlueStep.step M K p w hl before.cache hs hh before.token ranges.graph
    ctx.samplingPrimitive numeric.2.2.1
  obtain ⟨et, ec⟩ := advanceC_data M K p w hl parameters before supported
  refine ⟨hs', ?_, ?_⟩
  · rw [et]; exact e
  · rw [ec]; exact h'

/-- **The reference from the state `s0` at time `t0`**: `s0` at `t0`, then the context's steps;
`fill` below `t0`. -/
noncomputable def refFrom {t0 : Nat} (s0 : State p t0) (fill : (t : Nat) → t ≤ 262144 → State p t) :
    (time : Nat) → time ≤ 262144 → State p time
  | 0, h => if e : t0 = 0 then cast (congrArg (State p) e) s0 else fill 0 h
  | t + 1, h =>
    if e : t0 = t + 1 then cast (congrArg (State p) e) s0
    else if t0 ≤ t then advanceC M K p w hl parameters (refFrom s0 fill t (by omega)) h
    else fill (t + 1) h

variable {M K p w hl parameters}

theorem refFrom_start {t0 : Nat} (s0 : State p t0) (fill : (t : Nat) → t ≤ 262144 → State p t)
    (h : t0 ≤ 262144) : refFrom M K p w hl parameters s0 fill t0 h = s0 := by
  cases t0 with
  | zero => simp only [refFrom, ↓reduceDIte, cast_eq]
  | succ t => simp only [refFrom, ↓reduceDIte, cast_eq]

theorem refFrom_succ {t0 : Nat} (s0 : State p t0) (fill : (t : Nat) → t ≤ 262144 → State p t) {t : Nat}
    (ht : t0 ≤ t) (h : t + 1 ≤ 262144) :
    refFrom M K p w hl parameters s0 fill (t + 1) h =
      advanceC M K p w hl parameters (refFrom M K p w hl parameters s0 fill t (by omega)) h := by
  show (if e : t0 = t + 1 then _ else _) = _
  have hne : ¬ t0 = t + 1 := by omega
  simp only [hne, ↓reduceDIte, ht, ↓reduceIte]

/-- **The reference decodes from `t0` on**: from handles holding its cache at a time `≥ t0`,
one MLX decode step returns its next token and handles holding its next cache. -/
theorem refFrom_step {t0 : Nat} (s0 : State p t0) (fill : (t : Nat) → t ≤ 262144 → State p t) {time : Nat}
    (ht : t0 ≤ time) (h : time + 1 ≤ 262144) (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs (refFrom M K p w hl parameters s0 fill time (by omega)).cache) :
    ∃ hs', stepTrace M K w time (refFrom M K p w hl parameters s0 fill time (by omega)).token.val hs =
        some ((refFrom M K p w hl parameters s0 fill (time + 1) h).token.val, hs') ∧
      ChainHolds p.graph.stages hs' (refFrom M K p w hl parameters s0 fill (time + 1) h).cache := by
  rw [refFrom_succ s0 fill ht h]
  exact advanceC_step M K p w hl parameters _ h hs hh

/-- **The reference against the model's definitions**: from `t0` on, each next token is the greedy
sample of the pipeline's logits at the reference's cache and token (RoPE inputs of the time), each
next cache the pipeline's next cache. -/
theorem refFrom_model {t0 : Nat} (s0 : State p t0) (fill : (t : Nat) → t ≤ 262144 → State p t) {time : Nat}
    (ht : t0 ≤ time) (h : time + 1 ≤ 262144) :
    (refFrom M K p w hl parameters s0 fill (time + 1) h).token.val =
        Sampling.GreedySampling.sample K.sampling
          (p.run (refFrom M K p w hl parameters s0 fill time (by omega)).cache
            (refFrom M K p w hl parameters s0 fill time (by omega)).token (RopeInputConstruction.inputs time)).1 ∧
      (refFrom M K p w hl parameters s0 fill (time + 1) h).cache =
        (p.run (refFrom M K p w hl parameters s0 fill time (by omega)).cache
          (refFrom M K p w hl parameters s0 fill time (by omega)).token (RopeInputConstruction.inputs time)).2 := by
  rw [refFrom_succ s0 fill ht h]
  exact advanceC_data M K p w hl parameters _ h

end Host.Mlx.SimGraph.Ref
