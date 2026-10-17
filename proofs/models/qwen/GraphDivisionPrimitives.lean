import contracts.mlx.NativeDivisionDomain
import models.qwen.TokenReadyMemory

namespace Inference.Models.Qwen.GraphDivisionPrimitives
open Contracts.Mlx Contracts.Mlx.Numerics Layers.AffineVerifyLinear
open Qwen38TrellisM1Max Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- Instruction selection on admitted operands, not a complete kernel output
-- assumption. The mathematical division envelopes follow from the proved
-- logical IEEE/FTZ implementation; compiled M1 Max selection remains explicit.
abbrev Selected (divide : Float32 → Float32 → Float32) : Prop :=
  ∀ x y, x.isFinite=true → y.isFinite=true → Division.DivisorDomain y → divide x y=FlushToZero.div x y

theorem logical_selected : Selected FlushToZero.div := by
  intro x y _ _ _
  rfl

def tileDivide : Projection steps rows → Float32 → Float32 → Float32
  | .bits3 p => p.platform.tile.divide
  | .bits4 p => p.platform.tile.divide

abbrev AffineSelected (projection : Projection steps rows) : Prop := Selected (tileDivide projection)

theorem normalizedAffine (projection : Projection 10 rows) (selected : AffineSelected projection) :
    NormalizedAffineProjection.DivisionContract projection := by
  cases projection <;> exact NativeDivisionDomain.of_selection _ selected

theorem outputAffine (projection : Projection 12 5120) (selected : AffineSelected projection) :
    DeltaOutputRanges.Divisions projection := by
  cases projection <;> exact NativeDivisionDomain.of_selection _ selected

structure MlpOther (layer : ResidualBlocks.Mlp) where
  root : RsqrtBounds.Envelope layer.norm.platform.rsqrt
  expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value
  expError : BFloat16Arithmetic.Value → ℝ
  activation : layer.mlp.activation=.split expAbs
  exponential : Kernels.Trellis.GateUpSplitTail.ExpAbsContract expAbs expError
  expRange : Kernels.Trellis.SigmoidRanges.ExponentialRange expAbs

def mlp (selected : Selected layer.norm.platform.divide) (other : MlpOther layer) :
    ResidualMlpRanges.Primitives layer where
  division := NativeDivisionDomain.of_selection _ selected
  root := other.root
  expAbs := other.expAbs
  expError := other.expError
  selected := other.activation
  exponential := other.exponential
  expRange := other.expRange

structure DeltaSelected (norm : Blocks.Norm) (layer : DeltaNet.Layer) : Prop where
  normalization : Selected norm.platform.divide
  qkv : AffineSelected layer.qkv
  z : AffineSelected layer.z
  a : AffineSelected layer.a
  b : AffineSelected layer.b
  heads : Selected layer.recurrence.heads.divide
  gated : Selected layer.gated.divide
  output : AffineSelected layer.out

-- No division range record occurs here. The sharper head envelope also
-- supplies its old coarse envelope, so the caller need not supply both.
structure DeltaOther (norm : Blocks.Norm) (layer : DeltaNet.Layer) where
  normalizationRoot : RsqrtBounds.Envelope norm.platform.rsqrt
  headExp : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs
  headRoot : RsqrtRelativeBounds.Envelope layer.recurrence.heads.rsqrt (17/16)
  decay : Kernels.Delta.DecayRanges.PrimitiveRanges layer.recurrence.gates.decay DeltaGateRanges.profile
  beta : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.gates.expAbs
  gatedRoot : RsqrtBounds.Envelope layer.gated.rsqrt
  gatedExp : Kernels.StableSigmoidRanges.ExponentialRange layer.gated.expAbs

theorem head128 (selected : Selected divide) (x : Float32) (hx : x.isFinite=true) :
    divide x (Float32.ofInt 128)=FlushToZero.div x (Float32.ofInt 128) :=
  selected x _ hx (NativeNormalizationDivision.divisor_finite .deltaHead)
    (NativeNormalizationDivision.divisor_domain .deltaHead)

def delta {norm : Blocks.Norm} (selected : DeltaSelected norm layer) (other : DeltaOther norm layer) :
    DeltaDecodeRanges.Primitives norm layer where
  normalizationDivision := NativeDivisionDomain.of_selection _ selected.normalization
  normalizationRoot := other.normalizationRoot
  projections := ⟨normalizedAffine _ selected.qkv,normalizedAffine _ selected.z,
    normalizedAffine _ selected.a,normalizedAffine _ selected.b⟩
  headExp := other.headExp
  headDivision := NativeDivisionDomain.of_selection _ selected.heads
  headRoot := RsqrtRelativeBounds.weaken _ _ other.headRoot (by norm_num)
  decay := other.decay
  beta := other.beta
  gatedDivision := NativeDivisionDomain.of_selection _ selected.gated
  gatedRoot := other.gatedRoot
  gatedExp := other.gatedExp
  output := outputAffine _ selected.output
  headRootTight := other.headRoot
  headDivisionNative := head128 selected.heads

structure AttentionSelected (norm : Blocks.Norm) (layer : Attention.Layer) : Prop where
  normalization : Selected norm.platform.divide
  q : AffineSelected layer.projections.q
  k : AffineSelected layer.projections.k
  v : AffineSelected layer.projections.v
  queryNormalization : Selected layer.preparation.qNorm.platform.divide
  keyNormalization : Selected layer.preparation.kNorm.platform.divide
  angle : Selected layer.preparation.angles.divide
  attention : Selected layer.attention.normalization.divide
  output : AffineSelected layer.output

structure AttentionOther (norm : Blocks.Norm) (layer : Attention.Layer) where
  normalizationRoot : RsqrtBounds.Envelope norm.platform.rsqrt
  queryRoot : RsqrtBounds.Envelope layer.preparation.qNorm.platform.rsqrt
  keyRoot : RsqrtBounds.Envelope layer.preparation.kNorm.platform.rsqrt
  frequency : RopeAnglesRanges.Exp2Range layer.preparation.angles
  rotation : RopeRanges.TrigRanges layer.preparation.rotation
  angleDomain : AttentionSequenceHeadsRanges.AngleDomain layer.preparation
  maximum : SdpaInitialLoopRanges.Maximum layer.attention
  exponential : SdpaExponentRanges.Primitive layer.attention.merge.scalar
  gate : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.gate.expAbs

def attention {norm : Blocks.Norm} (selected : AttentionSelected norm layer) (other : AttentionOther norm layer) :
    AttentionSequenceRanges.Primitives norm layer where
  normalization := NativeDivisionDomain.of_selection _ selected.normalization
  root := other.normalizationRoot
  projections := ⟨normalizedAffine _ selected.q,normalizedAffine _ selected.k,normalizedAffine _ selected.v⟩
  heads := {
    queryDivision := NativeDivisionDomain.of_selection _ selected.queryNormalization
    queryRoot := other.queryRoot
    keyDivision := NativeDivisionDomain.of_selection _ selected.keyNormalization
    keyRoot := other.keyRoot
    angleDivision := (NativeDivisionDomain.of_selection _ selected.angle).toContract
    frequency := other.frequency
    rotation := other.rotation
    zeroDomain := by
      intro theta finite zero
      apply other.angleDomain theta finite
      rw [zero,abs_zero]
      positivity }
  attention := {
    maximum := other.maximum
    exponential := other.exponential
    division := (NativeDivisionDomain.of_selection _ selected.attention).toContract }
  gate := other.gate
  output := outputAffine _ selected.output
  angleDomain := other.angleDomain
  attentionDivision := NativeDivisionDomain.of_selection _ selected.attention

structure ResidualDeltaSelected (layer : ResidualDelta.Layer) : Prop where
  mixer : DeltaSelected layer.inputNorm layer.mixer
  suffix : Selected layer.suffix.norm.platform.divide

structure ResidualDeltaOther (layer : ResidualDelta.Layer) where
  mixer : DeltaOther layer.inputNorm layer.mixer
  suffix : MlpOther layer.suffix

def residualDelta (selected : ResidualDeltaSelected layer) (other : ResidualDeltaOther layer) :
    ResidualDeltaDecodeRanges.Primitives layer := ⟨delta selected.mixer other.mixer,mlp selected.suffix other.suffix⟩

structure ResidualAttentionSelected (layer : ResidualAttention.Layer) : Prop where
  mixer : AttentionSelected layer.inputNorm layer.mixer
  suffix : Selected layer.suffix.norm.platform.divide

structure ResidualAttentionOther (layer : ResidualAttention.Layer) where
  mixer : AttentionOther layer.inputNorm layer.mixer
  suffix : MlpOther layer.suffix

def residualAttention (selected : ResidualAttentionSelected layer) (other : ResidualAttentionOther layer) :
    ResidualAttentionSequenceRanges.Primitives layer := ⟨attention selected.mixer other.mixer,mlp selected.suffix other.suffix⟩

structure Selections (graph : Graph) : Prop where
  delta : ∀ i, ResidualDeltaSelected (graph.delta i)
  attention : ∀ i, ResidualAttentionSelected (graph.attention i)
  normalization : Selected graph.finalNorm.platform.divide
  output : AffineSelected graph.output

structure Other (graph : Graph) where
  delta : ∀ i, ResidualDeltaOther (graph.delta i)
  attention : ∀ i, ResidualAttentionOther (graph.attention i)
  root : RsqrtBounds.Envelope graph.finalNorm.platform.rsqrt

-- Directly accepted by every existing sequence/checkpoint/context primitive
-- argument. Its inputs contain no old assembled Primitives record and no
-- mathematical division envelopes; all divide fields are proved here.
def graphPrimitives (selected : Selections graph) (other : Other graph) :
    Qwen38TrellisM1MaxSequenceRanges.Primitives graph where
  delta i := residualDelta (selected.delta i) (other.delta i)
  attention i := residualAttention (selected.attention i) (other.attention i)
  normalization := NativeDivisionDomain.of_selection _ selected.normalization
  root := other.root
  output := normalizedAffine _ selected.output

def context (parameters : TokenSequenceRanges.Parameters pipeline)
    (selected : Selections pipeline.graph) (other : Other pipeline.graph)
    (sampling : Kernels.Sampling.LogSumExpRanges.Platform)
    (samplingPrimitive : Kernels.Sampling.LogSumExpRanges.Primitives sampling)
    (angles : TokenAutoregressive.Angles) (locals : Nat → TokenReadyMemory.Locals) :
    TokenReadyMemory.Context pipeline where
  parameters := parameters
  primitive := graphPrimitives selected other
  sampling := sampling
  samplingPrimitive := samplingPrimitive
  angles := angles
  locals := locals

theorem context_primitive (parameters : TokenSequenceRanges.Parameters pipeline)
    (selected : Selections pipeline.graph) (other : Other pipeline.graph)
    (sampling : Kernels.Sampling.LogSumExpRanges.Platform)
    (samplingPrimitive : Kernels.Sampling.LogSumExpRanges.Primitives sampling)
    (angles : TokenAutoregressive.Angles) (locals : Nat → TokenReadyMemory.Locals) :
    (context parameters selected other sampling samplingPrimitive angles locals).primitive=graphPrimitives selected other := rfl

end Inference.Models.Qwen.GraphDivisionPrimitives
