import host.simgraph.mach.TotalKernels
import host.mlx.FfiEval
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Mach
open Metal Inference Inference.Contracts.Mlx Inference.Kernels Inference.Models.Qwen
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers Host.Mlx.FfiEval

/-! # The decode step is defined on well-typed handles, under the GPU assumption

The D1 trace (`stepTrace`) composes the MLX operations (`TotalOps`: defined on typed arguments) and the decode
kernels (`TotalKernels`: defined on typed arguments when `K.apply` is MLX's launch run by `G`). So on weights of
the checkpoint's dtypes and shapes (`PipeTy`, from `PipelineLoaded`) and handles of the route's types
(`HandleTy n`: Delta conv and recurrent states absent or typed, KV buffers at offset `n`, `KvAt`), the step is
defined, its token is a vocabulary index (`TotalArgmax`) and its handles have the route's types at `n + 1`. No
value premise enters.

* `LinTy`, `MlpTy`, `DeltaTy`, `AttnTy`, `StageTy`, `PipeTy`: the weights' types; `pipeTy_of_loaded`.
* `HandleTy`; `shapesOk_of_ty`: typed handles have the route's shapes (`ShapesOk`).
* `project_ty`, `suffix_ty`, `deltaMixer_ty`, `deltaLayer_ty`, `attentionTrace_ty`, `attentionLayer_ty`,
  `stage_ty`, `chain_ty`, `embed_ty`, `stepTrace_ty`: each trace is defined and typed. -/

variable {C : M1Max.Contract}

/-! ## Types of weights and handles -/

/-- An optional value: absent, or of the dtype and shape. -/
def OptTy (o : Option Value) (d : Dtype) (sh : List Nat) : Prop := ∀ v, o = some v → Ty v d sh

theorem OptTy.getD {o : Option Value} {d : Dtype} {sh : List Nat} (h : OptTy o d sh) :
    Ty (o.getD (zeros sh d)) d sh := by
  cases o with
  | none => exact ⟨rfl, rfl⟩
  | some v => exact h v rfl

/-- A projection's handles at `steps` blocks of 512 inputs and `rows` outputs: the affine row launch at an
`AffineRoute` shape and width 3 or 4, or MLX's 4-bit `quantized_matmul`. -/
def LinTy : Projector → Linear → Nat → Nat → Prop
  | .affineRow, l, steps, rows => (l.bits = 3 ∨ l.bits = 4) ∧ Ty l.w .uint32 [rows, steps * (16 * l.bits)] ∧
      Ty l.scales .bfloat16 [rows, steps * 8] ∧ Ty l.biases .bfloat16 [rows, steps * 8] ∧
      ∃ blocks, rows = 4 * (blocks * 16) ∧ AffineRoute steps blocks
  | .plain, l, steps, rows => l.bits = 4 ∧ Ty l.w .uint32 [rows, steps * 64] ∧ Ty l.scales .bfloat16 [rows, steps * 8] ∧
      Ty l.biases .bfloat16 [rows, steps * 8]

structure MlpTy (w : MlpWeights) : Prop where
  norm : Ty w.norm .bfloat16 [5120]
  gateBits : w.gateBits = 2 ∨ w.gateBits = 3 ∨ w.gateBits = 4
  upBits : w.upBits = 2 ∨ w.upBits = 3 ∨ w.upBits = 4
  downBits : w.downBits = 2 ∨ w.downBits = 3 ∨ w.downBits = 4
  gateCodes : Ty w.gateCodes .uint32 [17408, 160 * w.gateBits]
  gateScales : Ty w.gateScales .float16 [17408]
  upCodes : Ty w.upCodes .uint32 [17408, 160 * w.upBits]
  upScales : Ty w.upScales .float16 [17408]
  downCodes : Ty w.downCodes .uint32 (if w.downBits = 3 then [10, 17408, 48] else [17408, 160 * w.downBits])
  downScales : Ty w.downScales .float16 [17408]

structure DeltaTy (w : DeltaWeights) : Prop where
  inputNorm : Ty w.inputNorm .bfloat16 [5120]
  qkv : LinTy w.qkvKind w.qkv 10 10240
  z : LinTy w.zKind w.z 10 6144
  a : LinTy .plain w.a 10 48
  b : LinTy .plain w.b 10 48
  out : LinTy w.outKind w.out 12 5120
  conv : Ty w.conv .bfloat16 [10240, 4, 1]
  aLog : Ty w.aLog .bfloat16 [48]
  dtBias : Ty w.dtBias .bfloat16 [48]
  norm : Ty w.norm .bfloat16 [128]
  qScale : Ty w.qScale .bfloat16 [128]
  kScale : Ty w.kScale .bfloat16 [128]
  mlp : MlpTy w.mlp

structure AttnTy (w : AttentionWeights) : Prop where
  inputNorm : Ty w.inputNorm .bfloat16 [5120]
  q : LinTy w.qKind w.q 10 12288
  k : LinTy w.kKind w.k 10 1024
  v : LinTy w.vKind w.v 10 1024
  o : LinTy w.oKind w.o 12 5120
  qNorm : Ty w.qNorm .bfloat16 [256]
  kNorm : Ty w.kNorm .bfloat16 [256]
  mlp : MlpTy w.mlp

def StageTy : StageWeights → Prop
  | .delta w => DeltaTy w
  | .attention w => AttnTy w

structure PipeTy (w : PipelineWeights) : Prop where
  words : Ty w.embedWords .uint32 [248320, 640]
  scales : Ty w.embedScales .bfloat16 [248320, 80]
  biases : Ty w.embedBiases .bfloat16 [248320, 80]
  finalNorm : Ty w.finalNorm .bfloat16 [5120]
  head : LinTy .affineRow w.head 10 248320
  stages : ∀ s ∈ stageWeights w, StageTy s

/-- **The route's handle types at offset `n`**, for a KV buffer invariant `KV`: a Delta layer's conv and recurrent
states absent or typed, an attention layer's KV buffers at offset `n` (`KV n`). -/
def HandleTyK (KV : Nat → Option Value → Prop) (n : Nat) : StageWeights → Handles → Prop
  | .delta _, .delta conv rec => OptTy conv .bfloat16 [1, 3, 10240] ∧ OptTy rec .float32 [1, 48, 128, 128]
  | .attention _, .attention kb vb => KV n kb ∧ KV n vb
  | _, _ => False

/-- The decode's handle types: KV buffers at offset `n` (`KvAt`). -/
abbrev HandleTy (n : Nat) : StageWeights → Handles → Prop := HandleTyK KvAt n

/-- A KV buffer invariant the one-row append keeps. -/
def KvSteps (KV : Nat → Option Value → Prop) : Prop :=
  ∀ n b k, KV n b → Ty k .bfloat16 [1, 4, 1, 256] →
    ∃ b' v, GlueKv.step b n k = some (b', v) ∧ KV (n + 1) (some b') ∧ Ty v .bfloat16 [1, 4, n + 1, 256]

theorem kvAt_steps : KvSteps KvAt := fun _ _ _ hb hk => kvStep_ty hb hk

theorem bufShape_of {n : Nat} : ∀ {b : Option Value}, KvAt n b → BufShape b
  | none, _ => fun _ e => nomatch e
  | some _, ⟨_, _, ht, _⟩ => fun _ e => by cases e; rw [ht.2]; rfl

/-- **Typed handles have the route's shapes.** -/
theorem shapesOk_of_ty {n : Nat} : ∀ (ws : List StageWeights) (hs : List Handles), (∀ s ∈ ws, StageTy s) →
    List.Forall₂ (HandleTy n) ws hs → ShapesOk ws hs
  | [], [], _, _ => trivial
  | .delta w :: ws, .delta _ _ :: hs, hw, .cons _ hr =>
    ⟨(hw (.delta w) (List.mem_cons.2 (.inl rfl)) : DeltaTy w).inputNorm.2,
      shapesOk_of_ty ws hs (fun s m => hw s (List.mem_cons.2 (.inr m))) hr⟩
  | .attention w :: ws, .attention _ _ :: hs, hw, .cons ⟨hk, hv⟩ hr =>
    have ha : AttnTy w := hw (.attention w) (List.mem_cons.2 (.inl rfl))
    ⟨⟨ha.inputNorm.2, ha.qNorm.2, ha.kNorm.2, bufShape_of hk, bufShape_of hv⟩,
      shapesOk_of_ty ws hs (fun s m => hw s (List.mem_cons.2 (.inr m))) hr⟩
  | .delta _ :: _, .attention _ _ :: _, _, .cons h _ => h.elim
  | .attention _ :: _, .delta _ _ :: _, _, .cons h _ => h.elim

/-! ## The weights' types from the loaded checkpoint -/

section Loaded
variable (M : MlxContract C) (K : KernelContract C)

theorem linTy_of_loaded {kind : Projector} {l : Linear} {steps rows : Nat}
    {q : Layers.AffineVerifyLinear.Projection steps rows} (h : Loaded M K kind l q)
    (route : kind = .affineRow → ∃ blocks, rows = 4 * (blocks * 16) ∧ AffineRoute steps blocks) :
    LinTy kind l steps rows := by
  cases kind with
  | affineRow =>
    obtain ⟨blocks, hr, hroute⟩ := route rfl
    cases q with
    | bits3 q =>
      obtain ⟨hb, _, hw⟩ := h
      exact ⟨.inl hb, ⟨hw.words.1, by rw [hw.words.2, hb]⟩, ⟨hw.groups.1, hw.groups.2.1⟩,
        ⟨hw.groups.2.2.1, hw.groups.2.2.2⟩, blocks, hr, hroute⟩
    | bits4 q =>
      obtain ⟨hb, _, hw⟩ := h
      exact ⟨.inr hb, ⟨hw.words.1, by rw [hw.words.2, hb]⟩, ⟨hw.groups.1, hw.groups.2.1⟩,
        ⟨hw.groups.2.2.1, hw.groups.2.2.2⟩, blocks, hr, hroute⟩
  | plain =>
    cases q with
    | bits3 q => exact h.elim
    | bits4 q =>
      obtain ⟨hb, _, hw⟩ := h
      exact ⟨hb, hw.words, ⟨hw.groups.1, hw.groups.2.1⟩, ⟨hw.groups.2.2.1, hw.groups.2.2.2⟩⟩

theorem mlpTy_of_loaded {s : ResidualBlocks.Mlp} {w : MlpWeights} (hl : MlpLoaded K s w) : MlpTy w where
  norm := ⟨hl.norm.1, hl.norm.2.1⟩
  gateBits := by rw [hl.gateBits]; exact s.mlp.gate.validWidth
  upBits := by rw [hl.upBits]; exact s.mlp.up.validWidth
  downBits := by rw [hl.downBits]; exact s.mlp.down.validWidth
  gateCodes := ⟨hl.trellis.gateCodes.1, by rw [hl.trellis.gateCodes.2, hl.gateBits]⟩
  gateScales := ⟨hl.trellis.scales.1, hl.trellis.scales.2.1⟩
  upCodes := ⟨hl.trellis.upCodes.1, by rw [hl.trellis.upCodes.2, hl.upBits]⟩
  upScales := ⟨hl.trellis.scales.2.2.1, hl.trellis.scales.2.2.2.1⟩
  downCodes := ⟨hl.trellis.downCodes.1, by rw [hl.trellis.downCodes.2, hl.downBits]⟩
  downScales := ⟨hl.trellis.scales.2.2.2.2.1, hl.trellis.scales.2.2.2.2.2⟩

theorem deltaTy_of_loaded {l : ResidualDelta.Layer} {w : DeltaWeights} (hl : DeltaLoaded M K l w) : DeltaTy w where
  inputNorm := ⟨hl.inputNorm.1, hl.inputNorm.2.1⟩
  qkv := linTy_of_loaded M K hl.qkv fun _ => ⟨160, rfl, by unfold AffineRoute; decide⟩
  z := linTy_of_loaded M K hl.z fun _ => ⟨96, rfl, by unfold AffineRoute; decide⟩
  a := linTy_of_loaded M K hl.a fun h => nomatch h
  b := linTy_of_loaded M K hl.b fun h => nomatch h
  out := linTy_of_loaded M K hl.out fun _ => ⟨80, rfl, by unfold AffineRoute; decide⟩
  conv := ⟨hl.conv.1, hl.conv.2.1⟩
  aLog := ⟨hl.aLog.1, hl.aLog.2.1⟩
  dtBias := ⟨hl.dtBias.1, hl.dtBias.2.1⟩
  norm := ⟨hl.norm.1, hl.norm.2.1⟩
  qScale := ⟨hl.qScale.1, hl.qScale.2.1⟩
  kScale := ⟨hl.kScale.1, hl.kScale.2.1⟩
  mlp := mlpTy_of_loaded K hl.suffix

theorem attnTy_of_loaded {l : ResidualAttention.Layer} {w : AttentionWeights} (hl : AttentionLoaded M K l w)
    (plain : w.qKind = .plain ∧ w.kKind = .plain ∧ w.vKind = .plain ∧ w.oKind = .plain) : AttnTy w where
  inputNorm := ⟨hl.inputNorm.1, hl.inputNorm.2.1⟩
  q := linTy_of_loaded M K hl.q fun h => by rw [plain.1] at h; cases h
  k := linTy_of_loaded M K hl.k fun h => by rw [plain.2.1] at h; cases h
  v := linTy_of_loaded M K hl.v fun h => by rw [plain.2.2.1] at h; cases h
  o := linTy_of_loaded M K hl.o fun _ => ⟨80, rfl, by unfold AffineRoute; decide⟩
  qNorm := ⟨hl.qNorm.1, hl.qNorm.2.1⟩
  kNorm := ⟨hl.kNorm.1, hl.kNorm.2.1⟩
  mlp := mlpTy_of_loaded K hl.suffix

/-- **The loaded checkpoint's handles have the route's types.** -/
theorem pipeTy_of_loaded {p : TokenInference.Pipeline} {w : PipelineWeights} (hl : PipelineLoaded M K p w) :
    PipeTy w := by
  have hd : ∀ i, StageTy (.delta (w.delta i)) := fun i => deltaTy_of_loaded M K (hl.delta i)
  have ha : ∀ i, StageTy (.attention (w.attention i)) := fun i =>
    attnTy_of_loaded M K (hl.attention i) (hl.attentionProjectors i)
  refine ⟨⟨hl.embedding.words.1, hl.embedding.words.2.1⟩, ⟨hl.embedding.scales.1, hl.embedding.scales.2.1⟩,
    ⟨hl.embedding.biases.1, hl.embedding.biases.2.1⟩, ⟨hl.finalNorm.1, hl.finalNorm.2.1⟩,
    linTy_of_loaded M K hl.head fun _ => ⟨3880, rfl, by unfold AffineRoute; decide⟩, ?_⟩
  simp only [stageWeights, List.mem_cons, List.not_mem_nil, or_false, forall_eq_or_imp, forall_eq, hd, ha,
    true_and]

end Loaded

/-! ## The MLX-only part of attention -/

theorem attentionTrace_ty (M : MlxContract C) (KV : Nat → Option Value → Prop) (hkv : KvSteps KV) {qp kp vp qw kw : Value}
    (hq : Ty qp .bfloat16 [1, 1, 12288])
    (hk : Ty kp .bfloat16 [1, 1, 1024]) (hv : Ty vp .bfloat16 [1, 1, 1024]) (hqw : Ty qw .bfloat16 [256])
    (hkw : Ty kw .bfloat16 [256]) {kb vb : Option Value} {n : Nat} (hkb : KV n kb) (hvb : KV n vb) :
    ∃ gated kb' vb', GlueAttention.attentionTrace M qp kp vp qw kw kb vb n = some (gated, kb', vb') ∧
      Ty gated .bfloat16 [1, 1, 6144] ∧ KV (n + 1) (some kb') ∧ KV (n + 1) (some vb') := by
  obtain ⟨qpr, e1, t1⟩ := reshape_ty hq [1, 1, 24, 512] rfl
  obtain ⟨qh, e2, t2⟩ := slice_ty t1 [0, 0, 0, 0] [1, 1, 24, 256] (by decide)
  obtain ⟨gh, e3, t3⟩ := slice_ty t1 [0, 0, 0, 256] [1, 1, 24, 512] (by decide)
  have t2' : Ty qh .bfloat16 [1, 1, 24, 256] := t2
  have t3' : Ty gh .bfloat16 [1, 1, 24, 256] := t3
  obtain ⟨gate, e4, t4⟩ := reshape_ty t3' [1, 1, 6144] rfl
  obtain ⟨kr, e5, t5⟩ := reshape_ty hk [1, 1, 4, 256] rfl
  obtain ⟨vr, e6, t6⟩ := reshape_ty hv [1, 1, 4, 256] rfl
  obtain ⟨qn, e7, t7⟩ := rmsNorm_ty M.headNorm (f32 0x358637bd) t2' hqw rfl (by decide)
  obtain ⟨qt, e8, t8⟩ := transpose_ty t7 [0, 2, 1, 3] (by decide)
  obtain ⟨kn, e9, t9⟩ := rmsNorm_ty M.headNorm (f32 0x358637bd) t5 hkw rfl (by decide)
  obtain ⟨kt, e10, t10⟩ := transpose_ty t9 [0, 2, 1, 3] (by decide)
  obtain ⟨vt, e11, t11⟩ := transpose_ty t6 [0, 2, 1, 3] (by decide)
  have t8' : Ty qt .bfloat16 [1, 24, 1, 256] := t8
  have t10' : Ty kt .bfloat16 [1, 4, 1, 256] := t10
  have t11' : Ty vt .bfloat16 [1, 4, 1, 256] := t11
  obtain ⟨q, e12, t12⟩ := rope_ty M (Float32.ofBits 0x4b189680) (f32 0x3f800000) n t8' rfl rfl rfl
  obtain ⟨k, e13, t13⟩ := rope_ty M (Float32.ofBits 0x4b189680) (f32 0x3f800000) n t10' rfl rfl rfl
  obtain ⟨kb', keys, e14, h14, t14⟩ := hkv n kb k hkb t13
  obtain ⟨vb', values, e15, h15, t15⟩ := hkv n vb vt hvb t11'
  obtain ⟨attn, e16, t16⟩ := sdpa_ty M t12 t14 t15
  obtain ⟨attnT, e17, t17⟩ := transpose_ty t16 [0, 2, 1, 3] (by decide)
  obtain ⟨merged, e18, t18⟩ := reshapeInfer_ty t17
  have t18' : Ty merged .bfloat16 [1, 1, 6144] := t18
  obtain ⟨sig, e19, t19⟩ := map1_ty (Attention.OutputGate.sigmoid M.sigmoid) t4
  obtain ⟨gated, e20, t20⟩ := map2_ty BFloat16Arithmetic.mul t18' t19
  have e19' : sigmoid M gate = some sig := e19
  have e20' : multiply merged sig = some gated := e20
  refine ⟨gated, kb', vb', ?_, t20, h14, h15⟩
  unfold GlueAttention.attentionTrace
  rw [GlueAttention.base_word, GlueAttention.sdpa_scale_word]
  rw [e1]; dsimp only [bind, Option.bind]
  rw [e2]; dsimp only [bind, Option.bind]
  rw [e3]; dsimp only [bind, Option.bind]
  rw [e4]; dsimp only [bind, Option.bind]
  rw [e5]; dsimp only [bind, Option.bind]
  rw [e6]; dsimp only [bind, Option.bind]
  rw [e7]; dsimp only [bind, Option.bind]
  rw [e8]; dsimp only [bind, Option.bind]
  rw [e9]; dsimp only [bind, Option.bind]
  rw [e10]; dsimp only [bind, Option.bind]
  rw [e11]; dsimp only [bind, Option.bind]
  rw [e12]; dsimp only [bind, Option.bind]
  rw [e13]; dsimp only [bind, Option.bind]
  rw [e14]; dsimp only [bind, Option.bind]
  rw [e15]; dsimp only [bind, Option.bind]
  rw [e16]; dsimp only [bind, Option.bind]
  rw [e17]; dsimp only [bind, Option.bind]
  rw [e18]; dsimp only [bind, Option.bind]
  rw [e19']; dsimp only [bind, Option.bind]
  rw [e20']; rfl

/-! ## The layers under the GPU assumption -/

section Gpu
variable (M : MlxContract C) (K : KernelContract C) {G : Gpu C} (P : KernelGpu.RoutePipelines G)
  (hK : K.apply = KernelGpu.apply G)
include P hK

theorem project_ty {kind : Projector} {l : Linear} {steps rows : Nat} (hl : LinTy kind l steps rows) {x : Value}
    (hx : Ty x .bfloat16 [1, 1, steps * 512]) :
    ∃ y, project M K kind l x = some y ∧ Ty y .bfloat16 [1, 1, rows] := by
  cases kind with
  | affineRow =>
    obtain ⟨hbits, hw, hs, hb, blocks, rfl, route⟩ := hl
    obtain ⟨y, e, hy⟩ := affineRow_ty G P route hbits hx hw hs hb
    have hcfg : affineConfig (l.scales.shape.getD 1 0 * 64) (l.scales.shape.headD 0) l.bits =
        affineConfig (steps * 512) (4 * (blocks * 16)) l.bits := by
      rw [hs.2]
      show affineConfig (steps * 8 * 64) (4 * (blocks * 16)) l.bits = _
      rw [show steps * 8 * 64 = steps * 512 by ring]
    refine ⟨y, ?_, hy⟩
    simp only [project]
    rw [hK, hcfg, e]
    rfl
  | plain =>
    obtain ⟨hbits, hw, hs, hb⟩ := hl
    simp only [project]
    rw [hbits]
    exact quantizedMatmul_ty M (steps * 512) rows hx (by rw [show steps * 512 / 8 = steps * 64 by omega]; exact hw)
      (by rw [hs.2, show steps * 512 / 64 = steps * 8 by omega]) (by rw [hb.2, show steps * 512 / 64 = steps * 8 by omega])
      (by omega)

theorem suffix_ty {w : MlpWeights} (hw : MlpTy w) {x u : Value} (hx : Ty x .bfloat16 [1, 1, 5120])
    (hu : Ty u .bfloat16 [1, 1, 5120]) : ∃ out, suffixTrace K w x u = some out ∧ Ty out .bfloat16 [1, 1, 5120] := by
  obtain ⟨h, n, e1, th, tn⟩ := residualNorm_ty G P hx hu hw.norm
  obtain ⟨x2, e2, t2⟩ := reshape_ty tn [1, 5120] rfl
  obtain ⟨mid, e3, tm⟩ := gateUp_ty G P hw.gateBits hw.upBits t2 hw.gateCodes hw.gateScales hw.upCodes hw.upScales
  obtain ⟨mid1, e4, t4⟩ := reshape_ty tm [1, 1, 17408] rfl
  obtain ⟨mid2, e5, t5⟩ := reshape_ty t4 [1, 17408] rfl
  obtain ⟨part, e6, t6⟩ := downPartial_ty G P hw.downBits t5 hw.downCodes hw.downScales
  obtain ⟨o, e7, t7⟩ := downFold_ty G P t6
  obtain ⟨hidden, e8, t8⟩ := reshape_ty t7 [1, 1, 5120] rfl
  obtain ⟨out, e9, t9⟩ := add_ty th t8
  have e1' : KernelClosure.eval K .residualRmsNorm [x, u, w.norm] = some [h, n] := by
    show K.apply _ _ _ = _
    rw [hK]; exact e1
  have e3' : K.apply .gateUp [x2, w.gateCodes, w.gateScales, w.upCodes, w.upScales]
      (gateUpConfig w.gateBits w.upBits) = some [mid] := by rw [hK]; exact e3
  have e6' : K.apply .downPartial [mid2, w.downCodes, w.downScales] (downConfig w.downBits) = some [part] := by
    rw [hK]; exact e6
  have e7' : K.apply .downFold [part] foldConfig = some [o] := by rw [hK]; exact e7
  refine ⟨out, ?_, t9⟩
  simp only [suffixTrace, e1', e2, e3', e4, e5, e6', e7', e8, e9, Option.bind_eq_bind, Option.bind_some]

theorem deltaMixer_ty {w : DeltaWeights} (hw : DeltaTy w) {conv rec : Option Value}
    (hc : OptTy conv .bfloat16 [1, 3, 10240]) (hr : OptTy rec .float32 [1, 48, 128, 128]) {x : Value}
    (hx : Ty x .bfloat16 [1, 1, 5120]) :
    ∃ mixed tail s, deltaMixerTrace M K w conv rec x = some (mixed, tail, s) ∧ Ty mixed .bfloat16 [1, 1, 5120] ∧
      Ty tail .bfloat16 [1, 3, 10240] ∧ Ty s .float32 [1, 48, 128, 128] := by
  obtain ⟨qkv, e1, t1⟩ := project_ty M K P hK hw.qkv hx
  obtain ⟨z0, e2, t2⟩ := project_ty M K P hK hw.z hx
  obtain ⟨z, e3, t3⟩ := reshape_ty t2 [1, 1, 48, 128] rfl
  obtain ⟨bv, e4, t4⟩ := project_ty M K P hK hw.b hx
  obtain ⟨av, e5, t5⟩ := project_ty M K P hK hw.a hx
  obtain ⟨joined, e6, t6⟩ := concatenate_ty hc.getD t1 1 (by decide)
  have t6' : Ty joined .bfloat16 [1, 4, 10240] := t6
  obtain ⟨view, e7, t7⟩ := slice_ty t6' [0, 1, 0] [1, 4, 10240] (by decide)
  have t7' : Ty view .bfloat16 [1, 3, 10240] := t7
  obtain ⟨tail, e8, t8⟩ := sliceDynamic_tail_ty t7'
  obtain ⟨c, e9, t9⟩ := conv1d_ty M 10240 t6' hw.conv (by decide)
  obtain ⟨q, k, v, e10, tq, tk, tv⟩ := heads_ty G P t9 hw.qScale hw.kScale
  obtain ⟨beta, e11, t11⟩ := map1_ty (Attention.OutputGate.sigmoid M.sigmoid) t4
  obtain ⟨g, e12, t12⟩ := computeG_ty M hw.aLog.1 t5 hw.dtBias.1
  obtain ⟨y, s, e13, t13, t13'⟩ := gatedDelta_ty G P tq tk tv t12 t11 hr.getD
  obtain ⟨gated, e14, t14⟩ := gatedNorm_ty G P t13 t3 hw.norm
  obtain ⟨merged, e15, t15⟩ := reshape_ty t14 [1, 1, 6144] rfl
  obtain ⟨mixed, e16, t16⟩ := project_ty M K P hK hw.out t15
  have e10' : KernelClosure.eval K .siluRmsHeads [c, w.qScale, w.kScale] = some [q, k, v] := by
    show K.apply _ _ _ = _
    rw [hK]; exact e10
  have e14' : KernelClosure.eval K .gatedRmsNorm [y, z, w.norm] = some [gated] := by
    show K.apply _ _ _ = _
    rw [hK]; exact e14
  have e11' : sigmoid M bv = some beta := e11
  refine ⟨mixed, tail, s, ?_, t16, t8, t13'⟩
  simp only [deltaMixerTrace, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10', e11', e12, hK, e13, e14', e15, e16,
    Option.bind_eq_bind, Option.bind_some, Option.pure_def]

theorem deltaLayer_ty {w : DeltaWeights} (hw : DeltaTy w) {conv rec : Option Value}
    (hc : OptTy conv .bfloat16 [1, 3, 10240]) (hr : OptTy rec .float32 [1, 48, 128, 128]) {x : Value}
    (hx : Ty x .bfloat16 [1, 1, 5120]) :
    ∃ out tail s, deltaLayerTrace M K w conv rec x = some (out, tail, s) ∧ Ty out .bfloat16 [1, 1, 5120] ∧
      Ty tail .bfloat16 [1, 3, 10240] ∧ Ty s .float32 [1, 48, 128, 128] := by
  obtain ⟨normed, e1, t1⟩ := rmsNorm_ty M.hiddenNorm (f32 0x358637bd) hx hw.inputNorm rfl (by decide)
  obtain ⟨mixed, tail, s, e2, t2, t3, t4⟩ := deltaMixer_ty M K P hK hw hc hr t1
  obtain ⟨out, e3, t5⟩ := suffix_ty K P hK hw.mlp hx t2
  refine ⟨out, tail, s, ?_, t5, t3, t4⟩
  simp only [deltaLayerTrace, e1, e2, e3, Option.bind_eq_bind, Option.bind_some, Option.pure_def]

theorem attentionLayer_ty (KV : Nat → Option Value → Prop) (hkv : KvSteps KV) {w : AttentionWeights} (hw : AttnTy w)
    {kb vb : Option Value} {n : Nat} (hkb : KV n kb)
    (hvb : KV n vb) {x : Value} (hx : Ty x .bfloat16 [1, 1, 5120]) :
    ∃ out kb' vb', attentionLayerTrace M K w kb vb n x = some (out, kb', vb') ∧ Ty out .bfloat16 [1, 1, 5120] ∧
      KV (n + 1) (some kb') ∧ KV (n + 1) (some vb') := by
  obtain ⟨normed, e1, t1⟩ := rmsNorm_ty M.hiddenNorm (f32 0x358637bd) hx hw.inputNorm rfl (by decide)
  obtain ⟨qp, e2, t2⟩ := project_ty M K P hK hw.q t1
  obtain ⟨kp, e3, t3⟩ := project_ty M K P hK hw.k t1
  obtain ⟨vp, e4, t4⟩ := project_ty M K P hK hw.v t1
  obtain ⟨gated, kb', vb', e5, t5, h5, h5'⟩ := attentionTrace_ty M KV hkv t2 t3 t4 hw.qNorm hw.kNorm hkb hvb
  obtain ⟨mixed, e6, t6⟩ := project_ty M K P hK hw.o t5
  obtain ⟨out, e7, t7⟩ := suffix_ty K P hK hw.mlp hx t6
  refine ⟨out, kb', vb', ?_, t7, h5, h5'⟩
  simp only [attentionLayerTrace, e1, e2, e3, e4, e5, e6, e7, Option.bind_eq_bind, Option.bind_some, Option.pure_def]

theorem stage_ty (KV : Nat → Option Value → Prop) (hkv : KvSteps KV) {s : StageWeights} (hs : StageTy s) {h : Handles}
    {n : Nat} (hh : HandleTyK KV n s h) {x : Value}
    (hx : Ty x .bfloat16 [1, 1, 5120]) :
    ∃ y h', stageTrace M K n s h x = some (y, h') ∧ Ty y .bfloat16 [1, 1, 5120] ∧ HandleTyK KV (n + 1) s h' := by
  cases s with
  | delta w =>
    cases h with
    | attention _ _ => exact hh.elim
    | delta conv rec =>
      obtain ⟨out, tail, st, e, t1, t2, t3⟩ := deltaLayer_ty M K P hK hs hh.1 hh.2 hx
      refine ⟨out, .delta (some tail) (some st), ?_, t1, fun v hv => ?_, fun v hv => ?_⟩
      · show Option.map _ (deltaLayerTrace M K w conv rec x) = _
        rw [e]; rfl
      · cases hv; exact t2
      · cases hv; exact t3
  | attention w =>
    cases h with
    | delta _ _ => exact hh.elim
    | attention kb vb =>
      obtain ⟨out, kb', vb', e, t1, h1, h2⟩ := attentionLayer_ty M K P hK KV hkv hs hh.1 hh.2 hx
      refine ⟨out, .attention (some kb') (some vb'), ?_, t1, h1, h2⟩
      show Option.map _ (attentionLayerTrace M K w kb vb n x) = _
      rw [e]; rfl

theorem chain_ty (KV : Nat → Option Value → Prop) (hkv : KvSteps KV) {n : Nat} :
    ∀ (ws : List StageWeights) (hs : List Handles), (∀ s ∈ ws, StageTy s) →
    List.Forall₂ (HandleTyK KV n) ws hs → ∀ x, Ty x .bfloat16 [1, 1, 5120] →
    ∃ y hs', chainTrace M K n ws hs x = some (y, hs') ∧ Ty y .bfloat16 [1, 1, 5120] ∧
      List.Forall₂ (HandleTyK KV (n + 1)) ws hs'
  | [], [], _, _, x, hx => ⟨x, [], rfl, hx, .nil⟩
  | s :: ws, h :: hs, hw, .cons hh hr, x, hx => by
    obtain ⟨y, h', e1, t1, hh'⟩ := stage_ty M K P hK KV hkv (hw s (List.mem_cons.2 (.inl rfl))) hh hx
    obtain ⟨z, hs', e2, t2, hr'⟩ := chain_ty KV hkv ws hs (fun s' m => hw s' (List.mem_cons.2 (.inr m))) hr y t1
    refine ⟨z, h' :: hs', ?_, t2, .cons hh' hr'⟩
    simp only [chainTrace, e1, e2, Option.bind_eq_bind, Option.bind_some, Option.pure_def]
  | [], _ :: _, _, h, _, _ => nomatch h
  | _ :: _, [], _, h, _, _ => nomatch h

end Gpu

theorem embed_ty (M : MlxContract C) {w : PipelineWeights} (hw : PipeTy w) (token : Nat) :
    ∃ x, embedTrace M w.embedWords w.embedScales w.embedBiases token = some x ∧ Ty x .bfloat16 [1, 1, 5120] := by
  obtain ⟨rows, e1, t1⟩ := takeAxis0_ty hw.words (ids := tokenIds token) rfl
  obtain ⟨sc, e2, t2⟩ := takeAxis0_ty hw.scales (ids := tokenIds token) rfl
  obtain ⟨bi, e3, t3⟩ := takeAxis0_ty hw.biases (ids := tokenIds token) rfl
  obtain ⟨x, e4, t4⟩ := dequantizeRow_ty M (w := rows) t1 t2.2 t3.2
  exact ⟨x, by simp only [embedTrace, e1, e2, e3, e4, Option.bind_eq_bind, Option.bind_some], t4⟩

section Gpu
variable (M : MlxContract C) (K : KernelContract C) {G : Gpu C} (P : KernelGpu.RoutePipelines G)
  (hK : K.apply = KernelGpu.apply G)
include P hK

theorem argmax_K {l : Value} (hl : Ty l .bfloat16 [1, 248320]) :
    ∃ r, KernelClosure.eval K .normalizedArgmax [l] = some [r] ∧ Ty r .uint32 [1] ∧ r.elems 0 < 248320 := by
  obtain ⟨s, e1, t1⟩ := logsumexp_ty K.sampling hl
  obtain ⟨values, indices, token, e2, e3, t3, h3⟩ := argmax_ty G P hl t1
  have e4 : reshape token [1] = some { token with shape := [1] } := reshape_some token [1] (by rw [t3.2])
  refine ⟨{ token with shape := [1] }, ?_, ⟨t3.1, rfl⟩, h3⟩
  simp only [KernelClosure.eval, e1, hK, e2, e3, e4, Option.bind_eq_bind, Option.bind_some, Option.map_some]

/-- **The decode step is defined on typed handles**, its token is a vocabulary index and its handles are typed at
the next offset. -/
theorem stepTrace_ty {w : PipelineWeights} (hw : PipeTy w) {n : Nat} (token : Nat) {hs : List Handles}
    (hh : List.Forall₂ (HandleTy n) (stageWeights w) hs) :
    ∃ tok hs', stepTrace M K w n token hs = some (tok, hs') ∧ List.Forall₂ (HandleTy (n + 1)) (stageWeights w) hs' ∧
      tok < 248320 := by
  obtain ⟨x, e1, t1⟩ := embed_ty M hw token
  obtain ⟨y, hs', e2, t2, hh'⟩ := chain_ty M K P hK KvAt kvAt_steps (stageWeights w) hs hw.stages hh x t1
  obtain ⟨h, e3, t3⟩ := rmsNorm_ty M.hiddenNorm (f32 0x358637bd) t2 hw.finalNorm rfl (by decide)
  obtain ⟨logits, e4, t4⟩ := project_ty M K P hK hw.head t3
  obtain ⟨l, e5, t5⟩ := reshape_ty t4 [1, 248320] rfl
  obtain ⟨r, e6, t6, h6⟩ := argmax_K K P hK t5
  have e7 : itemUint32 r = some (r.elems 0) := by
    unfold itemUint32
    rw [ite_eq_left ⟨t6.1, by rw [t6.size]; rfl⟩]
  exact ⟨r.elems 0, hs', by simp only [stepTrace, e1, e2, e3, e4, e5, e6, e7, Option.bind_eq_bind, Option.bind_some, Option.pure_def],
    hh', h6⟩

end Gpu

end Host.Mlx.SimGraph.Mach
