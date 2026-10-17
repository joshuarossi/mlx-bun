import host.mlx.GlueContext
import models.qwen.RopeInputConstruction
namespace Host.Mlx.GlueM1Max
open Inference Inference.Contracts.Mlx Inference.Kernels Inference.Layers
open Inference.Models.Qwen WrittenLayers GlueLayers GlueStep
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open ReachedTokenContext.Primitive
set_option maxRecDepth 10000
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-! ## Native division selection and range records from the contract

Every platform of a loaded pipeline is built from C (PipelineLoaded), so
ReachedTokenContext's Selections and Other records follow from C's
operation-level clauses and the one Proposed clause. -/

theorem selected : GraphDivisionPrimitives.Selected C.fdiv := C.fdiv_model

theorem loaded_selected (kind : Projector) (l : Linear) (q : AffineVerifyLinear.Projection steps rows)
    (h : Loaded M K kind l q) : GraphDivisionPrimitives.AffineSelected q := by
  cases kind <;> cases q <;> simp only [Loaded] at h
  all_goals rw [GraphDivisionPrimitives.AffineSelected, GraphDivisionPrimitives.tileDivide, h.2.1]; exact selected

theorem mlp_selected (s : ResidualBlocks.Mlp) (w : MlpWeights) (hl : MlpLoaded K s w) :
    GraphDivisionPrimitives.Selected s.norm.platform.divide := by
  rw [hl.platform]; exact selected

theorem delta_selected (l : ResidualDelta.Layer) (w : DeltaWeights) (hl : DeltaLoaded M K l w) :
    ResidualDeltaSelected l where
  mixer := {
    normalization := by rw [hl.inputPlatform]; exact selected
    qkv := loaded_selected M K _ _ _ hl.qkv
    z := loaded_selected M K _ _ _ hl.z
    a := loaded_selected M K _ _ _ hl.a
    b := loaded_selected M K _ _ _ hl.b
    heads := by rw [hl.heads]; exact selected
    gated := by rw [hl.gated]; exact selected
    output := loaded_selected M K _ _ _ hl.out }
  suffix := mlp_selected K _ _ hl.suffix

theorem attention_selected (l : ResidualAttention.Layer) (w : AttentionWeights) (hl : AttentionLoaded M K l w) :
    ResidualAttentionSelected l where
  mixer := {
    normalization := by rw [hl.inputPlatform]; exact selected
    q := loaded_selected M K _ _ _ hl.q
    k := loaded_selected M K _ _ _ hl.k
    v := loaded_selected M K _ _ _ hl.v
    queryNormalization := by rw [hl.bound.qNorm]; exact selected
    keyNormalization := by rw [hl.bound.kNorm]; exact selected
    angle := by rw [hl.bound.angles]; exact selected
    attention := by rw [hl.bound.attention]; exact selected
    output := loaded_selected M K _ _ _ hl.o }
  suffix := mlp_selected K _ _ hl.suffix

theorem selections (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w) :
    Selections p.graph where
  delta i := delta_selected M K _ _ (hl.delta i)
  attention i := attention_selected M K _ _ (hl.attention i)
  normalization := by rw [hl.finalPlatform]; exact selected
  output := loaded_selected M K _ _ _ hl.head

theorem root : RsqrtEpsilonBounds.NormalEnvelope C.rsqrt 2 := C.rsqrtEnvelope 2 (by norm_num)

noncomputable def activationPrimitive (gate up : Nat) : TrellisMlpRanges.ActivationPrimitive (trellisActivation C gate up) := by
  unfold trellisActivation
  split
  · exact ⟨M1Max.Contract.expAbsError C.fastExpAbs, C.fastExpAbs_contract, C.fastExpAbs_exponential⟩
  · exact ⟨_, C.expNeg_contract, C.expNeg_exponential⟩

noncomputable def mlpOther (s : ResidualBlocks.Mlp) (w : MlpWeights) (hl : MlpLoaded K s w) : MlpOther s where
  root := by rw [hl.platform]; exact root
  activation := hl.activation ▸ activationPrimitive _ _

private theorem fp (e : Int) (lo : -149 ≤ e) (hi : e ≤ 100) :
    Contracts.Mlx.Numerics.real (DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using (DyadicBounds.ceiling_range 1 e (by decide) lo hi).2

theorem decay (P : M1Max.Proposed C) :
    Delta.DecayRanges.PrimitiveRanges M.decay DeltaGateRanges.profile :=
  C.decayRanges P M.logAddExp DeltaGateRanges.profile
    (by rw [show DeltaGateRanges.profile.aLogCap = DyadicBounds.ceiling 1 3 from rfl, fp 3 (by decide) (by decide)]; norm_num)
    (by rw [show DeltaGateRanges.profile.scaleCap = DyadicBounds.ceiling 1 12 from rfl, fp 12 (by decide) (by decide)]; norm_num)

noncomputable def deltaOther (P : M1Max.Proposed C) (l : ResidualDelta.Layer) (w : DeltaWeights) (hl : DeltaLoaded M K l w) :
    ResidualDeltaOther l where
  mixer := {
    normalizationRoot := by rw [hl.inputPlatform]; exact root
    headExp := by rw [hl.heads]; exact C.fastExpAbs_exponential
    headRoot := by rw [hl.heads]; exact C.rsqrtEnvelope _ le_rfl
    decay := by rw [hl.decay]; exact decay M P
    beta := by rw [hl.beta]; exact C.preciseExpAbs_exponential
    gatedRoot := by rw [hl.gated]; exact root
    gatedExp := by rw [hl.gated]; exact C.gatedExpAbs_exponential }
  suffix := mlpOther K _ _ hl.suffix

noncomputable def attentionOther (l : ResidualAttention.Layer) (w : AttentionWeights) (hl : AttentionLoaded M K l w) :
    ResidualAttentionOther l where
  mixer := {
    normalizationRoot := by rw [hl.inputPlatform]; exact root
    queryRoot := by rw [hl.bound.qNorm]; exact root
    keyRoot := by rw [hl.bound.kNorm]; exact root
    frequency := by rw [hl.bound.angles]; exact C.exp2Range
    rotation := by rw [hl.bound.rotation]; exact C.trigRanges _ _
    angleDomain := by intro θ _ hd; rw [hl.bound.rotation]; exact hd
    maximum := by rw [hl.bound.attention]; exact C.sdpaMaximum _ _ _
    exponential := by rw [hl.bound.attention]; exact C.sdpaExponent _ _
    gate := by rw [hl.bound.gate]; exact C.preciseExpAbs_exponential }
  suffix := mlpOther K _ _ hl.suffix

noncomputable def other (P : M1Max.Proposed C) (p : TokenInference.Pipeline) (w : PipelineWeights)
    (hl : PipelineLoaded M K p w) : Other p.graph where
  delta i := deltaOther M K P _ _ (hl.delta i)
  attention i := attentionOther M K _ _ (hl.attention i)
  root := by rw [hl.finalPlatform]; exact root

/-! ## The reached context of the loaded pipeline -/

-- Context.run does not read the memory-level locals.
def noLocals : Nat → TokenReadyMemory.Locals := fun _ => ⟨fun _ => 0, fun _ _ => 0, fun _ => 0⟩

-- The reached token context of the loaded pipeline: its primitive contracts
-- are proved from C (and P), its sampler is the MLX logsumexp platform, its
-- angles are the route's RoPE inputs (rope.cpp position and log2 base).
noncomputable def context (P : M1Max.Proposed C) (p : TokenInference.Pipeline) (w : PipelineWeights)
    (hl : PipelineLoaded M K p w) (parameters : TokenSequenceRanges.Parameters p) : ReachedTokenContext.Context p :=
  ReachedTokenContext.ofNormal parameters (selections M K p w hl) (other M K P p w hl) K.sampling
    (C.logSumExpPrimitives K.lseSum K.lseNumerator) RopeInputConstruction.angles noLocals

-- The reached ranges of every Delta layer include its finite a + dt_bias.
theorem decayOk (s : DecodeStage.Stage) (c : DecodeStage.Cache s n) (x : Fin 5120 → BF) (a : Attention.RopeAngles.Inputs)
    (hf : DecodeStage.Finite s c x a) : DecayOk s x := by
  cases s with
  | delta l =>
    intro h
    exact BFloat16Arithmetic.finite_flush _ ((hf.mixer.recurrence.gates 0 le_rfl).decay h).sumFinite
  | attention _ => trivial

theorem decayFinite : (stages : List DecodeStage.Stage) → (c : DecodeChain.Caches stages n) →
    (x : Fin 5120 → BF) → (a : Attention.RopeAngles.Inputs) → DecodeChain.Ranges stages c x a → DecayFinite stages c x a
  | [], _, _, _, _ => trivial
  | s :: rest, c, x, a, hr => ⟨decayOk s c.1 x a hr.1, decayFinite rest c.2 _ a hr.2⟩

/-- One decode step of the loaded pipeline on the M1 Max: from handles holding
the reached context's cache at `time`, the MLX trace returns the context's
next token and handles holding its next cache. Premises: the operation-level
contract C and its proposed clause P, the MLX statements M and K (operation
semantics; contraction and tie choices are free fields), the loaded pipeline,
its checkpoint parameter ranges, and the handles' cache. -/
theorem contextStep (P : M1Max.Proposed C) (p : TokenInference.Pipeline) (w : PipelineWeights)
    (hl : PipelineLoaded M K p w) (parameters : TokenSequenceRanges.Parameters p)
    (token : Fin 248320) (time : Nat) (supported : time+1 ≤ 262144) (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs ((context M K P p w hl parameters).run token time (by omega)).cache) :
    ∃ hs', stepTrace M K w time ((context M K P p w hl parameters).run token time (by omega)).token.val hs =
        some (((context M K P p w hl parameters).run token (time+1) supported).token.val, hs') ∧
      ChainHolds p.graph.stages hs' ((context M K P p w hl parameters).run token (time+1) supported).cache := by
  let ctx := context M K P p w hl parameters
  let state := ctx.run token time (by omega)
  have lt : time < 262144 := by omega
  have ranges := ReachedSequenceRanges.Token.checked p ctx.parameters ctx.primitive state.cache state.cacheBound
    state.token (RopeInputConstruction.inputs time) (RopeInputConstruction.inputs_bound time lt) supported
  have numeric := ReachedSequenceRanges.Token.run_correct p ctx.parameters ctx.primitive state.cache state.cacheBound
    state.targetCache state.errorCache state.cacheError state.token (RopeInputConstruction.inputs time)
    (RopeInputConstruction.inputs_bound time lt) supported (RopeInputConstruction.target time) RopeInputConstruction.error
    (RopeInputConstruction.input_error time lt) (RopeInputConstruction.target_base_nonnegative time)
  exact GlueContext.context_step M K p w hl ctx rfl token time supported rfl hs hh
    (decayFinite _ _ _ _ ranges.graph.chain) numeric.2.2.1

end Host.Mlx.GlueM1Max
