import host.load.Parameters
namespace Host.Load.Reify
open Host.Mlx Host.Mlx.GlueLayers Host.Mlx.GlueStep
open Inference Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics Inference.Models.Qwen Inference.Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Payload interpretation must preserve the dtype and dimensions declared by
its safetensors header. These are leaf assumptions, independent of model
arithmetic, layer composition, kernel selection and decoding. -/
def VectorShape (v : Value) (n : Nat) : Prop := v.dtype = .bfloat16 ∧ v.shape = [n]

def vector (v : Value) : Fin n → BF := fun i => bf (v.elems i.val)

theorem vector_holds (h : VectorShape v n) : GlueAttention.Vector v n (vector v) := ⟨h.1, h.2, fun _ => rfl⟩

def norm (platform : RmsNorm.Platform) (v : Value) : Blocks.Norm :=
  ⟨platform, vector v, fun _ => 0, 0⟩

noncomputable def headNorm (v : Value) : AttentionHeads.Norm := ⟨M.headNorm, vector v, fun _ => 0, 0⟩

structure Groups (l : GlueLayers.Linear) (steps rows : Nat) : Prop where
  scales : l.scales.dtype = .bfloat16 ∧ l.scales.shape = [rows, steps * 8]
  biases : l.biases.dtype = .bfloat16 ∧ l.biases.shape = [rows, steps * 8]

def LinearShape (kind : Projector) (l : GlueLayers.Linear) (steps rows : Nat) : Prop :=
  Groups l steps rows ∧ l.w.dtype = .uint32 ∧
    ((l.bits = 3 ∧ kind = .affineRow ∧ l.w.shape = [rows, steps * 48]) ∨
      (l.bits = 4 ∧ l.w.shape = [rows, steps * 64]))

noncomputable def projection (kind : Projector) (l : GlueLayers.Linear) : AffineVerifyLinear.Projection steps rows :=
  if l.bits = 3 then .bits3 ⟨K.affine 3 steps rows, fun row => weights3 l.w l.scales l.biases steps row.val⟩
  else .bits4 ⟨match kind with | .plain => M.row | .affineRow => K.affine 4 steps rows,
    fun row => weights4 l.w l.scales l.biases steps row.val⟩

theorem projection_loaded (h : LinearShape kind l steps rows) : Loaded M K (steps := steps) (rows := rows) kind l (projection M K kind l) := by
  obtain ⟨⟨hs, hb⟩, hw, h⟩ := h
  rcases h with ⟨bits, rfl, shape⟩ | ⟨bits, shape⟩
  · simp only [projection, bits, ↓reduceIte, Loaded, true_and]
    exact ⟨⟨hw, shape⟩, ⟨hs.1, hs.2, hb.1, hb.2⟩, fun _ => rfl⟩
  · cases kind <;> simp only [projection, bits, show ¬(4:Nat)=3 by decide, ↓reduceIte, Loaded, true_and] <;>
      exact ⟨⟨hw, shape⟩, ⟨hs.1, hs.2, hb.1, hb.2⟩, fun _ => rfl⟩

structure MlpShape (w : MlpWeights) : Prop where
  norm : VectorShape w.norm 5120
  gate : w.gateBits = 2 ∨ w.gateBits = 3 ∨ w.gateBits = 4
  up : w.upBits = 2 ∨ w.upBits = 3 ∨ w.upBits = 4
  down : w.downBits = 2 ∨ w.downBits = 3 ∨ w.downBits = 4
  gateCodes : w.gateCodes.dtype = .uint32 ∧ w.gateCodes.shape = [17408, 160 * w.gateBits]
  upCodes : w.upCodes.dtype = .uint32 ∧ w.upCodes.shape = [17408, 160 * w.upBits]
  downCodes : w.downCodes.dtype = .uint32 ∧
    w.downCodes.shape = if w.downBits = 3 then [10, 17408, 48] else [17408, 160 * w.downBits]
  scales : w.gateScales.dtype = .float16 ∧ w.gateScales.shape = [17408] ∧ w.upScales.dtype = .float16 ∧
    w.upScales.shape = [17408] ∧ w.downScales.dtype = .float16 ∧ w.downScales.shape = [17408]

noncomputable def mlp (w : MlpWeights) (h : MlpShape w) : ResidualBlocks.Mlp :=
  ⟨norm K.residual w.norm,
    ⟨K.activation w.gateBits w.upBits, C.gateUpPlatform (fun _ => 0) 0 (by decide) (by decide),
      CheckpointTrellis.gateUp w.gateBits h.gate (codes _ w.gateCodes) (trellisScales w.gateScales),
      CheckpointTrellis.gateUp w.upBits h.up (codes _ w.upCodes) (trellisScales w.upScales),
      C.downPlatform (fun _ _ => 0) 0 (by decide) (by decide),
      CheckpointTrellis.down w.downBits h.down (codes _ w.downCodes) (trellisScales w.downScales)⟩⟩

theorem mlp_loaded (w : MlpWeights) (h : MlpShape w) : MlpLoaded K (mlp K w h) w :=
  ⟨vector_holds h.norm, rfl, ⟨rfl, rfl, rfl, h.gateCodes, h.upCodes, h.downCodes, h.scales⟩, rfl, rfl, rfl, rfl, rfl, rfl,
    rfl, rfl⟩

structure DeltaShape (w : DeltaWeights) : Prop where
  inputNorm : VectorShape w.inputNorm 5120
  qkv : LinearShape w.qkvKind w.qkv 10 10240
  z : LinearShape w.zKind w.z 10 6144
  a : LinearShape .plain w.a 10 48
  b : LinearShape .plain w.b 10 48
  out : LinearShape w.outKind w.out 12 5120
  conv : w.conv.dtype = .bfloat16 ∧ w.conv.shape = [10240,4,1]
  aLog : VectorShape w.aLog 48
  dtBias : VectorShape w.dtBias 48
  norm : VectorShape w.norm 128
  qScale : VectorShape w.qScale 128
  kScale : VectorShape w.kScale 128
  mlp : MlpShape w.mlp

noncomputable def delta (w : DeltaWeights) (h : DeltaShape w) : ResidualDelta.Layer where
  inputNorm := norm M.hiddenNorm w.inputNorm
  mixer := {
    qkv := projection M K w.qkvKind w.qkv
    z := projection M K w.zKind w.z
    a := projection M K .plain w.a
    b := projection M K .plain w.b
    out := projection M K w.outKind w.out
    convolutionWeight := fun c tap => bf (w.conv.get [c.val, tap.val, 0])
    aLog := vector w.aLog
    dtBias := vector w.dtBias
    headParams := ⟨vector w.qScale, vector w.kScale, Kernels.Delta.SiluHeads128Output.width, Blocks.eps⟩
    recurrence := ⟨M.convContracted, K.heads,
      ⟨M.decay, M.sigmoid.expAbs, M.sigmoid.expError, M.sigmoid.exponential⟩,
      C.simdSum, C.simdSum_tree, K.flags⟩
    gated := K.gated
    normWeight := vector w.norm }
  suffix := mlp K w.mlp h.mlp
  epsilon := rfl

theorem delta_loaded (w : DeltaWeights) (h : DeltaShape w) : DeltaLoaded M K (delta M K w h) w :=
  ⟨vector_holds h.inputNorm, rfl,
    projection_loaded M K h.qkv, projection_loaded M K h.z,
    projection_loaded M K h.a, projection_loaded M K h.b, projection_loaded M K h.out,
    ⟨h.conv.1, h.conv.2, fun _ _ => rfl⟩, vector_holds h.aLog, vector_holds h.dtBias,
    vector_holds h.norm, vector_holds h.qScale, vector_holds h.kScale,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, mlp_loaded K w.mlp h.mlp⟩

structure AttentionShape (w : AttentionWeights) : Prop where
  inputNorm : VectorShape w.inputNorm 5120
  q : LinearShape w.qKind w.q 10 12288
  k : LinearShape w.kKind w.k 10 1024
  v : LinearShape w.vKind w.v 10 1024
  o : LinearShape w.oKind w.o 12 5120
  qNorm : VectorShape w.qNorm 256
  kNorm : VectorShape w.kNorm 256
  mlp : MlpShape w.mlp

noncomputable def attention (w : AttentionWeights) (h : AttentionShape w) : ResidualAttention.Layer :=
  ⟨norm M.hiddenNorm w.inputNorm,
    ⟨⟨projection M K w.qKind w.q, projection M K w.kKind w.k, projection M K w.vKind w.v⟩,
      ⟨headNorm M w.qNorm, headNorm M w.kNorm, M.angles, M.rotation⟩,
      M.sdpa, M.sigmoid, projection M K w.oKind w.o, arch, M.sdpaMerge⟩,
    mlp K w.mlp h.mlp⟩

theorem attention_loaded (w : AttentionWeights) (h : AttentionShape w) :
    AttentionLoaded M K (attention M K w h) w :=
  ⟨vector_holds h.inputNorm, rfl, projection_loaded M K h.q, projection_loaded M K h.k,
    projection_loaded M K h.v, projection_loaded M K h.o,
    vector_holds h.qNorm, vector_holds h.kNorm,
    ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩, mlp_loaded K w.mlp h.mlp⟩

structure EmbeddingShape (w s b : Value) : Prop where
  words : w.dtype = .uint32 ∧ w.shape = [248320,640]
  bounded : ∀ (t : Fin 248320) (j : Fin 640), w.elems (t.val * 640 + j.val) < 2^32
  scales : s.dtype = .bfloat16 ∧ s.shape = [248320,80]
  biases : b.dtype = .bfloat16 ∧ b.shape = [248320,80]

def embedding (w s b : Value) : QuantizedEmbedding.Layer :=
  ⟨(fun t j => BitVec.ofNat 32 (w.elems (t.val*640+j.val))),
    (fun t g => bf (s.elems (t.val*80+g.val))),
    (fun t g => bf (b.elems (t.val*80+g.val))), M.dequantizeContracted⟩

theorem embedding_loaded (h : EmbeddingShape w s b) : EmbeddingLoaded M (embedding M w s b) w s b := by
  refine ⟨⟨h.words.1, h.words.2, ?_⟩, ⟨h.scales.1, h.scales.2, fun _ _ => rfl⟩,
    ⟨h.biases.1, h.biases.2, fun _ _ => rfl⟩, rfl⟩
  intro t j
  simp only [embedding, BitVec.toNat_ofNat, Nat.mod_eq_of_lt (h.bounded t j)]

/-- Only per-array header/payload facts and checked source selections remain.
No layer arithmetic, whole decode, or `PipelineLoaded` proposition is assumed. -/
structure PayloadShape (w : PipelineWeights) : Prop where
  embedding : EmbeddingShape w.embedWords w.embedScales w.embedBiases
  delta : ∀ i, DeltaShape (w.delta i)
  attention : ∀ i, AttentionShape (w.attention i)
  finalNorm : VectorShape w.finalNorm 5120
  head : LinearShape .affineRow w.head 10 248320
structure SourceSelections (w : PipelineWeights) : Prop where
  deltaProjectors : ∀ i, ((w.delta i).qkvKind, (w.delta i).zKind, (w.delta i).outKind) = oneDelta i
  attentionProjectors : ∀ i, (w.attention i).qKind = .plain ∧ (w.attention i).kKind = .plain ∧
    (w.attention i).vKind = .plain ∧ (w.attention i).oKind = .plain

noncomputable def pipeline (w : PipelineWeights) (h : PayloadShape w) : TokenInference.Pipeline :=
  ⟨embedding M w.embedWords w.embedScales w.embedBiases,
    ⟨(fun i => delta M K (w.delta i) (h.delta i)),
      (fun i => attention M K (w.attention i) (h.attention i)),
      norm M.hiddenNorm w.finalNorm, projection M K .affineRow w.head⟩⟩

theorem pipeline_loaded (w : PipelineWeights) (h : PayloadShape w) (selected : SourceSelections w) :
    PipelineLoaded M K (pipeline M K w h) w :=
  ⟨embedding_loaded M h.embedding, (fun i => delta_loaded M K (w.delta i) (h.delta i)),
    (fun i => attention_loaded M K (w.attention i) (h.attention i)),
    vector_holds h.finalNorm, rfl, projection_loaded M K h.head,
    selected.deltaProjectors, selected.attentionProjectors⟩

end Host.Load.Reify
