import host.mlx.GlueKernels
import host.mlx.GlueConv

namespace Host.Mlx.GlueLayers
open Inference Inference.Contracts.Mlx Inference.Kernels Inference.Layers
open Inference.Models.Qwen WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-! ## Projections

The graph binds each projection to `AffineRowLinear` (our affine_row
kernel) or `QuantizedLinearPlain` (mlx_quantized_matmul), written per layer
in the m1max graph's `#one` table. LoRA's `delta.forward` returns its
argument on the route (GlueRoute.lora_identity). -/

inductive Projector where
  | affineRow | plain
  deriving DecidableEq

-- An affine-quantized weight handle triple and its bit width.
structure Linear where
  w : Value
  scales : Value
  biases : Value
  bits : Nat

-- affine-verify-linear.ts AffineRowLinear.forward / quantized-linear.ts
-- QuantizedLinearPlain.forward (no bias on the route). The launch reads K from
-- x and N from the scales (affine-row.ts affineRow); on the route x has K =
-- scales.shape[1]·64 (affineRowEligible), the form taken here so the launch
-- configuration is a function of the loaded weights.
noncomputable def project : Projector → Linear → Value → Option Value
  | .affineRow, l, x => do
    let [y] ← K.apply .affineRow [x, l.w, l.scales, l.biases]
      (affineConfig (l.scales.shape.getD 1 0 * 64) (l.scales.shape.headD 0) l.bits) | none
    pure y
  | .plain, l, x => quantizedMatmul M x l.w l.scales l.biases true 64 l.bits "affine"

-- The loaded handles encode the projection, on the platform its kernel runs.
def Loaded : Projector → Linear → AffineVerifyLinear.Projection steps rows → Prop
  | .affineRow, l, .bits3 q => l.bits = 3 ∧ q.platform = K.affine 3 steps rows ∧ Affine3 q l.w l.scales l.biases
  | .affineRow, l, .bits4 q => l.bits = 4 ∧ q.platform = K.affine 4 steps rows ∧ Affine4 q l.w l.scales l.biases
  | .plain, l, .bits4 q => l.bits = 4 ∧ q.platform = M.row ∧ Affine4 q l.w l.scales l.biases
  | .plain, _, .bits3 _ => False

theorem quantized_row (q : AffineVerifyLinear.Projection4 steps rows) (hp : q.platform = M.row) (w scales biases : Value)
    (hw : Affine4 q w scales biases) (x : Value) (input : Fin (steps*512) → BF) (hx : Row x (steps*512) input) :
    ∃ y, quantizedMatmul M x w scales biases true 64 4 "affine" = some y ∧ Row y rows (q.forward input) := by
  obtain ⟨⟨wd, ws⟩, ⟨sd, ss, bd, bs⟩, weights⟩ := hw
  simp only [quantizedMatmul, hx.2.1, ws]
  rw [if_pos ⟨hx.1, wd, trivial, trivial, trivial, trivial, by omega, by congr 2; omega, by rw [ss]; congr 2; omega,
    by rw [bs]; congr 2; omega⟩]
  refine ⟨_, rfl, Row.mk rfl rfl fun j => ?_⟩
  dsimp only
  rw [dif_pos j.isLt, bf_word]
  generalize hg : steps*512/512 = s
  have hs : steps = s := by omega
  subst hs
  have hin : (fun j : Fin (steps*512) => bf (x.elems j.val)) = input := funext (Row.elems hx)
  have hq : ({ platform := M.row, weights := fun row => weights4 w scales biases steps row.val } :
      AffineVerifyLinear.Projection4 steps rows) = q := by
    cases q with
    | mk platform qw =>
      simp only at hp weights
      subst hp
      congr
      funext row
      exact (weights row).symm
  rw [hin, hq, AffineVerifyLinear.Projection4.plain_eq]

-- Small projections (Delta a/b, 48 rows) are never affine_row-eligible.
theorem plain_row (l : Linear) (p : AffineVerifyLinear.Projection steps rows) (hl : Loaded M K .plain l p) (x : Value)
    (input : Fin (steps*512) → BF) (hx : Row x (steps*512) input) :
    ∃ y, project M K .plain l x = some y ∧ Row y rows (p.forward input) := by
  cases p with
  | bits3 q => exact hl.elim
  | bits4 q =>
    obtain ⟨hb, hp, hw⟩ := hl
    obtain ⟨y, ha, hy⟩ := quantized_row M q hp l.w l.scales l.biases hw x input hx
    exact ⟨y, by simp only [project, hb]; exact ha, hy⟩

theorem project_row (kind : Projector) (l : Linear) {blocks : Nat} (p : AffineVerifyLinear.Projection steps (4*(blocks*16)))
    (hl : Loaded M K kind l p) (route : kind = .affineRow → AffineRoute steps blocks) (x : Value)
    (input : Fin (steps*512) → BF) (hx : Row x (steps*512) input) (hf : p.Finite input) :
    ∃ y, project M K kind l x = some y ∧ Row y (4*(blocks*16)) (p.forward input) := by
  cases kind
  · cases p with
    | bits3 q =>
      obtain ⟨hb, hp, hw⟩ := hl
      obtain ⟨y, ha, hy⟩ := GlueKernels.affine_row3 K q input x l.w l.scales l.biases hp hx hw hf (route rfl)
      have hn : l.scales.shape.headD 0 = 4*(blocks*16) := by rw [hw.groups.2.1]; rfl
      have hk : l.scales.shape.getD 1 0 * 64 = steps*512 := by rw [hw.groups.2.1]; simp only [List.getD_cons_succ, List.getD_cons_zero]; omega
      refine ⟨y, ?_, hy⟩
      simp only [project, hk, hn, hb, ha]; rfl
    | bits4 q =>
      obtain ⟨hb, hp, hw⟩ := hl
      obtain ⟨y, ha, hy⟩ := GlueKernels.affine_row4 K q input x l.w l.scales l.biases hp hx hw hf (route rfl)
      have hn : l.scales.shape.headD 0 = 4*(blocks*16) := by rw [hw.groups.2.1]; rfl
      have hk : l.scales.shape.getD 1 0 * 64 = steps*512 := by rw [hw.groups.2.1]; simp only [List.getD_cons_succ, List.getD_cons_zero]; omega
      refine ⟨y, ?_, hy⟩
      simp only [project, hk, hn, hb, ha]; rfl
  · exact plain_row M K l p hl x input hx

/-! ## Layout helpers -/

theorem tensor_flat (h : Tensor4 v 1 H 128 (fun _ => f)) : Flat v [1,1,H,128] (Delta.GatedInputs.flatten f) :=
  ⟨h.1, h.2.1, fun j => by
    have hj := j.isLt
    have e := Tensor4.elems h 0 ⟨j.val/128, by omega⟩ ⟨j.val%128, by omega⟩
    simp only [Fin.val_zero, Nat.zero_mul, Nat.zero_add] at e
    rw [show j.val/128*128+j.val%128 = j.val by omega] at e
    exact e⟩

-- reshape(z, [1,1,48,128]) of a [1,1,6144] projection.
theorem reshape_heads (v : Value) (f : Fin 6144 → BF) (hv : Row v 6144 f) :
    ∃ u, reshape v [1,1,48,128] = some u ∧
      Flat u [1,1,48,128] (Delta.GatedInputs.flatten (fun h i => f (DeltaNet.channel h i))) :=
  ⟨_, reshape_some v _ (by rw [hv.2.1]; rfl), hv.1, rfl, fun j => by
    have hj := j.isLt
    have hc : DeltaNet.channel ⟨j.val/128, by omega⟩ ⟨j.val%128, by omega⟩ = ⟨j.val, hj⟩ :=
      Fin.ext (by simp only [DeltaNet.channel]; omega)
    change bf (v.elems j.val) = f (DeltaNet.channel ⟨j.val/128, by omega⟩ ⟨j.val%128, by omega⟩)
    rw [hc]
    exact Row.elems hv ⟨j.val, hj⟩⟩

-- reshape(gated, [1,1,6144]).
theorem reshape_merge (v : Value) (f : Fin 6144 → BF) (hv : Flat v [1,1,48,128] f) :
    ∃ u, reshape v [1,1,6144] = some u ∧ Row u 6144 f :=
  ⟨_, reshape_some v _ (by rw [hv.2.1]; rfl), Row.mk hv.1 rfl hv.2.2⟩

theorem row_flat48 (h : Row v 48 f) : Flat v [1,1,48] f := ⟨h.1, h.2.1, Row.elems h⟩

/-! ## The Delta layer

blocks.ts QwenResidualDeltaLayer.forward with the QwenFusedHeadsDeltaNet
mixer (GatedDeltaNet.forward, SSMCache.#recur, gatedDeltaUpdate) and the
written GateDownMLP(CodebookSplitGateUpRow, CodebookDown(K3i)Row). -/

structure MlpWeights where
  norm : Value
  gateCodes : Value
  gateScales : Value
  upCodes : Value
  upScales : Value
  downCodes : Value
  downScales : Value
  gateBits : Nat
  upBits : Nat
  downBits : Nat

structure DeltaWeights where
  inputNorm : Value
  qkv : Linear
  z : Linear
  a : Linear
  b : Linear
  out : Linear
  qkvKind : Projector
  zKind : Projector
  outKind : Projector
  conv : Value
  aLog : Value
  dtBias : Value
  norm : Value
  qScale : Value
  kScale : Value
  mlp : MlpWeights

-- Loaded weight handles encode the model's parameters, and each model
-- platform is the one its kernel runs on.
structure MlpLoaded (s : ResidualBlocks.Mlp) (w : MlpWeights) : Prop where
  norm : GlueAttention.Vector w.norm 5120 s.norm.weight
  platform : s.norm.platform = K.residual
  trellis : Trellis s.mlp w.gateCodes w.gateScales w.upCodes w.upScales w.downCodes w.downScales
  gateBits : w.gateBits = s.mlp.gate.width
  upBits : w.upBits = s.mlp.up.width
  downBits : w.downBits = s.mlp.down.width
  gateLoad : s.mlp.gatePlatform.load = C.threadgroupLoad
  gateReduce : s.mlp.gatePlatform.reduce = C.simdSum
  downLoad : s.mlp.downPlatform.load = C.threadgroupLoad
  downReduce : s.mlp.downPlatform.reduce = C.simdSum
  activation : s.mlp.activation = K.activation s.mlp.gate.width s.mlp.up.width

structure DeltaLoaded (l : ResidualDelta.Layer) (w : DeltaWeights) : Prop where
  inputNorm : GlueAttention.Vector w.inputNorm 5120 l.inputNorm.weight
  inputPlatform : l.inputNorm.platform = M.hiddenNorm
  qkv : Loaded M K w.qkvKind w.qkv l.mixer.qkv
  z : Loaded M K w.zKind w.z l.mixer.z
  a : Loaded M K .plain w.a l.mixer.a
  b : Loaded M K .plain w.b l.mixer.b
  out : Loaded M K w.outKind w.out l.mixer.out
  conv : GlueConv.ConvWeight w.conv l.mixer.convolutionWeight
  aLog : GlueAttention.Vector w.aLog 48 l.mixer.aLog
  dtBias : GlueAttention.Vector w.dtBias 48 l.mixer.dtBias
  norm : GlueAttention.Vector w.norm 128 l.mixer.normWeight
  qScale : GlueAttention.Vector w.qScale 128 l.mixer.headParams.qScale
  kScale : GlueAttention.Vector w.kScale 128 l.mixer.headParams.kScale
  convContracted : l.mixer.recurrence.convolutionContracted = M.convContracted
  heads : l.mixer.recurrence.heads = K.heads
  decay : l.mixer.recurrence.gates.decay = M.decay
  beta : l.mixer.recurrence.gates.expAbs = M.sigmoid.expAbs
  reduce : l.mixer.recurrence.reduce = C.simdSum
  flags : l.mixer.recurrence.flags = K.flags
  gated : l.mixer.gated = K.gated
  width : l.mixer.headParams.width = Delta.SiluHeads128Output.width
  suffix : MlpLoaded K l.suffix w.mlp

-- SSMCache slots: absent before the first step (zeros), then the arrays.
def HistoryHolds : Option Value → (Fin 3 → Fin 10240 → BF) → Prop
  | none, h => h = InitialState.delta.history
  | some v, h => Tensor3 v 3 10240 h
def StateHolds : Option Value → (Fin 48 → Fin 128 → Fin 128 → Float32) → Prop
  | none, s => s = InitialState.delta.recurrent
  | some v, s => GlueConv.F32Tensor4 v 48 128 128 s

theorem history_value (conv : Option Value) (h : Fin 3 → Fin 10240 → BF) (hc : HistoryHolds conv h) :
    Tensor3 (conv.getD (zeros [1,3,10240] .bfloat16)) 3 10240 h := by
  cases conv with
  | none =>
    have hh : h = InitialState.delta.history := hc
    subst hh
    exact GlueConv.initial_history
  | some v => exact hc

theorem state_value (rec : Option Value) (s : Fin 48 → Fin 128 → Fin 128 → Float32) (hr : StateHolds rec s) :
    (rec.getD (zeros [1,48,128,128] .float32)).dtype = .float32 ∧ (rec.getD (zeros [1,48,128,128] .float32)).shape = [1,48,128,128] ∧
      ∀ h r c, f32 ((rec.getD (zeros [1,48,128,128] .float32)).elems (Delta.GatedStores.stateIndex h r c)) = s h r c := by
  have tensor : GlueConv.F32Tensor4 (rec.getD (zeros [1,48,128,128] .float32)) 48 128 128 s := by
    cases rec with
    | none =>
      have hs : s = InitialState.delta.recurrent := hr
      subst hs
      exact GlueConv.initial_recurrent
    | some v => exact hr
  refine ⟨tensor.1, tensor.2.1, fun h r c => ?_⟩
  have e := tensor.2.2 h r c
  rw [get4 _ tensor.2.1] at e
  simpa [Delta.GatedStores.stateIndex] using e

noncomputable def deltaMixerTrace (w : DeltaWeights) (conv rec : Option Value) (x : Value) :
    Option (Value × Value × Value) := do
  let qkv ← project M K w.qkvKind w.qkv x
  let z0 ← project M K w.zKind w.z x
  let z ← reshape z0 [1,1,48,128]
  let b ← project M K .plain w.b x
  let a ← project M K .plain w.a x
  let joined ← concatenate (conv.getD (zeros [1,3,10240] .bfloat16)) qkv 1
  let view ← slice joined [0,1,0] [1,4,10240]
  let tail ← sliceDynamic view GlueConv.zeroIndex [0] [1,3,10240]
  let c ← conv1d M joined w.conv 1 0 1 10240
  let [q, k, v] ← KernelClosure.eval K .siluRmsHeads [c, w.qScale, w.kScale] | none
  let beta ← sigmoid M b
  let [g] ← closureApply M .computeG [w.aLog, a, w.dtBias] | none
  let [y, s] ← K.apply .gatedDeltaStep [q, k, v, g, beta, rec.getD (zeros [1,48,128,128] .float32),
    ⟨.int32, [1], fun _ => 1⟩] gatedConfig | none
  let [gated] ← KernelClosure.eval K .gatedRmsNorm [y, z, w.norm] | none
  let merged ← reshape gated [1,1,6144]
  let mixed ← project M K w.outKind w.out merged
  pure (mixed, tail, s)

-- The mixer's kernel inputs are finite where the model's range certificate
-- `DeltaNet.Layer.Finite` says so (one decode token: time 0).
theorem delta_mixer (l : ResidualDelta.Layer) (w : DeltaWeights) (hl : DeltaLoaded M K l w)
    (cache : DeltaNet.Cache) (conv rec : Option Value) (hc : HistoryHolds conv cache.history)
    (hr : StateHolds rec cache.recurrent) (xv : Value) (x : Fin 5120 → BF) (hx : Row xv 5120 x)
    (hf : DeltaNet.Layer.Finite l.mixer cache (fun _ => x) 0) :
    ∃ mixed tail s, deltaMixerTrace M K w conv rec xv = some (mixed, tail, s) ∧
      Row mixed 5120 (l.mixer.forward cache (fun _ => x) 0) ∧
      Tensor3 tail 3 10240 (DeltaCache.after l.mixer cache (fun _ => x) 1).history ∧
      GlueConv.F32Tensor4 s 48 128 128 (DeltaCache.after l.mixer cache (fun _ => x) 1).recurrent := by
  have finite : ∀ h, Model.isFinite (Delta.Decay.biased (l.mixer.a.forward x h) (l.mixer.dtBias h)) = true :=
    fun h => BFloat16Arithmetic.finite_flush _ ((hf.recurrence.gates 0 le_rfl).decay h).sumFinite
  obtain ⟨qkv, e1, tqkv⟩ := project_row M K w.qkvKind w.qkv (blocks := 160) l.mixer.qkv hl.qkv
    (fun _ => by unfold AffineRoute; decide) xv x hx (hf.projections.qkv 0)
  obtain ⟨z0, e2, tz0⟩ := project_row M K w.zKind w.z (blocks := 96) l.mixer.z hl.z
    (fun _ => by unfold AffineRoute; decide) xv x hx (hf.projections.z 0)
  obtain ⟨z, e3, tz⟩ := reshape_heads z0 _ tz0
  obtain ⟨bv, e4, tb⟩ := plain_row M K w.b l.mixer.b hl.b xv x hx
  obtain ⟨av, e5, ta⟩ := plain_row M K w.a l.mixer.a hl.a xv x hx
  obtain ⟨joined, view, tail, c, e6, e7, e8, e9, ttail, tc⟩ := GlueConv.convolve M _ qkv w.conv cache.history
    (fun _ => l.mixer.qkv.forward x) l.mixer.convolutionWeight (history_value conv _ hc) tqkv hl.conv
  have heps : Delta.SiluHeads128Output.epsilon = Blocks.eps := rfl
  obtain ⟨q, k, v, e10, tq, tk, tv⟩ := GlueKernels.silu_rms_heads K _ _ _ c w.qScale w.kScale tc hl.qScale hl.kScale (by
    have h := hf.recurrence.heads 0 le_rfl
    unfold State.Ssm.HeadFinite State.Ssm.convolved State.Ssm.window DeltaNet.convData at h
    rw [hl.heads, hl.convContracted, hl.width, l.epsilon, ← heps] at h
    exact h)
  obtain ⟨beta, e11, tbeta⟩ := GlueAttention.sigmoid_row M bv _ tb
  obtain ⟨g, e12, tg⟩ := GlueRoute.computeG_closure M w.aLog av w.dtBias _ _ _ hl.aLog ta hl.dtBias finite
  let heads := DeltaHeads.forward K.heads (fun _ : Fin 1 => fun ch => Delta.Convolution.value M.convContracted
    (Delta.Convolution.window (fun j => cache.history j ch) (fun t => (fun _ => l.mixer.qkv.forward x) t ch) 0)
    (l.mixer.convolutionWeight ch)) l.mixer.headParams.qScale l.mixer.headParams.kScale
    Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon
  let values : Delta.GatedInputs.Values := ⟨heads.k 0, heads.q 0, heads.v 0,
    fun h => Delta.Decay.value M.decay (BFloat16.widen (l.mixer.aLog h)) (l.mixer.a.forward x h) (l.mixer.dtBias h),
    fun h => Attention.OutputGate.sigmoid M.sigmoid (l.mixer.b.forward x h)⟩
  have hinputs : values.inputs = fun h r => DeltaNet.inputs l.mixer cache (fun _ => x) h r 0 := by
    funext h r
    unfold Delta.GatedInputs.Values.inputs DeltaNet.inputs State.Ssm.inputs Delta.Inputs.actual State.Ssm.projected
      State.Ssm.heads State.Ssm.convolved State.Ssm.window DeltaNet.convData DeltaNet.gates
    rw [hl.heads, hl.decay, hl.beta, hl.convContracted, hl.width, l.epsilon]
    simp only [values, heads, heps, Attention.OutputGate.sigmoid]
  obtain ⟨y, s, e13, ty, sd, ss, se⟩ := GlueKernels.gated_delta_step K _ l.mixer.recurrence.reduction hl.reduce
    cache.recurrent values q k v g beta _
    (tensor_flat tq) (tensor_flat tk) (tensor_flat tv) tg (row_flat48 tbeta) (state_value rec _ hr) (fun h r => by
      have e := hf.recurrence.output h r
      rw [hl.flags] at e
      rw [hinputs]
      exact e)
  have hX : Delta.GatedDevice.producedOutput C.simdSum K.flags cache.recurrent values.inputs =
      DeltaNet.recurrentOutput l.mixer cache (fun _ => x) 0 := by
    rw [hinputs, ← hl.reduce, ← hl.flags]; unfold Delta.GatedDevice.producedOutput; rfl
  have hS : Delta.GatedDevice.producedState C.simdSum K.flags cache.recurrent values.inputs =
      (DeltaCache.after l.mixer cache (fun _ => x) 1).recurrent := by
    rw [hinputs, ← hl.reduce, ← hl.flags]; unfold Delta.GatedDevice.producedState; rfl
  have hw : Normalization.GatedRms128TailSource.width = l.mixer.headParams.width := by rw [hl.width]; rfl
  have he : FloatMemory.decode (BitVec.ofNat 32 epsWord) = l.mixer.headParams.eps := by rw [l.epsilon]; rfl
  obtain ⟨gated, e14, tgated⟩ := GlueKernels.gated_rms_norm K _ _ l.mixer.normWeight y z w.norm (tensor_flat ty) tz hl.norm
    (fun h => by rw [hX, hw, he, ← hl.gated]; exact hf.gated.normalization h)
    (fun h i => by rw [hX, hw, he, ← hl.gated]; exact hf.gated.tail h i)
  obtain ⟨merged, e15, tm⟩ := reshape_merge gated _ tgated
  have hm : Delta.GatedInputs.flatten (fun h => GatedRmsNorm.value K.gated
      (Delta.GatedDevice.producedOutput C.simdSum K.flags cache.recurrent values.inputs h)
      (fun i => l.mixer.z.forward x (DeltaNet.channel h i)) l.mixer.normWeight Normalization.GatedRms128TailSource.width
      (FloatMemory.decode (BitVec.ofNat 32 epsWord))) = DeltaNet.merged l.mixer cache (fun _ => x) 0 := by
    funext i
    simp only [Delta.GatedInputs.flatten, DeltaNet.merged, DeltaNet.gatedOutput, DeltaNet.headOf,
      DeltaNet.valueOf, hX, hw, he, hl.gated]
    rfl
  have tm' : Row merged 6144 (DeltaNet.merged l.mixer cache (fun _ => x) 0) := hm ▸ tm
  obtain ⟨mixed, e16, tmixed⟩ := project_row M K w.outKind w.out (blocks := 80) l.mixer.out hl.out
    (fun _ => by unfold AffineRoute; decide) merged _ tm' hf.output
  refine ⟨mixed, tail, s, ?_, tmixed, ttail, sd, ss, fun h r c => ?_⟩
  · unfold deltaMixerTrace
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
    rw [e16]; rfl
  · rw [get4 s ss]
    have := se h r c
    simp only [Delta.GatedStores.stateIndex] at this
    simp only [Nat.zero_mul, Nat.zero_add]
    rw [this, hS]

theorem add_row (a b : Value) (x y : Fin m → BF) (ha : Row a m x) (hb : Row b m y) :
    ∃ p, add a b = some p ∧ Row p m (fun j => BFloat16Arithmetic.add (x j) (y j)) := by
  have op : add a b = some { a with elems := fun i => bfWord (BFloat16Arithmetic.add (bf (a.elems i)) (bf (b.elems i))) } := by
    rw [add_same a b (ha.2.1.trans hb.2.1.symm)]
    unfold map2; rw [ite_eq_left ⟨ha.1, hb.1, ha.2.1.trans hb.2.1.symm⟩]
  refine ⟨_, op, Row.mk ha.1 ha.2.1 fun j => ?_⟩
  dsimp only
  rw [bf_word, Row.elems ha j, Row.elems hb j]

noncomputable def suffixTrace (w : MlpWeights) (x mixed : Value) : Option Value := do
  let [h, n] ← KernelClosure.eval K .residualRmsNorm [x, mixed, w.norm] | none
  let x2 ← reshape n [1,5120]
  let [mid] ← K.apply .gateUp [x2, w.gateCodes, w.gateScales, w.upCodes, w.upScales] (gateUpConfig w.gateBits w.upBits) | none
  let mid1 ← reshape mid [1,1,17408]
  let mid2 ← reshape mid1 [1,17408]
  let [part] ← K.apply .downPartial [mid2, w.downCodes, w.downScales] (downConfig w.downBits) | none
  let [o] ← K.apply .downFold [part] foldConfig | none
  let hidden ← reshape o [1,1,5120]
  add h hidden

theorem suffix (s : ResidualBlocks.Mlp) (w : MlpWeights) (hl : MlpLoaded K s w) (xv uv : Value) (x u : Fin 5120 → BF)
    (hx : Row xv 5120 x) (hu : Row uv 5120 u) (hf : s.Finite x u) :
    ∃ out, suffixTrace K w xv uv = some out ∧ Row out 5120 (s.forward x u) := by
  obtain ⟨h, n, e1, th, tn⟩ := GlueKernels.residual_rms_norm K x u s.norm.weight xv uv w.norm hx hu hl.norm
    hf.addition (hl.platform ▸ hf.normalization) s.norm.scratch s.norm.base
  have e2 := reshape_some n [1,5120] (by rw [tn.2.1]; rfl)
  have tx2 : Flat { n with shape := [1,5120] } [1,5120] (s.normalized x u) := by
    refine ⟨tn.1, rfl, fun j => ?_⟩
    have := Row.elems tn j
    rw [← hl.platform] at this
    exact this
  obtain ⟨mid, part, o, e3, e4, e5, ms, tO⟩ := GlueKernels.trellis_mlp K s.mlp (s.normalized x u) _ w.gateCodes w.gateScales
    w.upCodes w.upScales w.downCodes w.downScales hl.gateReduce hl.downReduce hl.activation
    hl.trellis tx2 hf.mlp
  have e6 := reshape_some mid [1,1,17408] (by rw [ms]; rfl)
  have e7 := reshape_some { mid with shape := [1,1,17408] } [1,17408] rfl
  have hmid : ({ { mid with shape := [1,1,17408] } with shape := [1,17408] } : Value) = mid := by
    cases mid; simp only at ms; subst ms; rfl
  have e8 := reshape_some o [1,1,5120] (by rw [tO.2.1]; rfl)
  obtain ⟨out, e9, tout⟩ := add_row h { o with shape := [1,1,5120] } _ _ th (Row.mk tO.1 rfl tO.2.2)
  refine ⟨out, ?_, tout⟩
  unfold suffixTrace
  rw [e1]; dsimp only [bind, Option.bind]
  rw [e2]; dsimp only [bind, Option.bind]
  rw [hl.gateBits, hl.upBits, e3]; dsimp only [bind, Option.bind]
  rw [e6]; dsimp only [bind, Option.bind]
  rw [e7]; dsimp only [bind, Option.bind]
  rw [hmid, hl.downBits, e4]; dsimp only [bind, Option.bind]
  rw [e5]; dsimp only [bind, Option.bind]
  rw [e8]; dsimp only [bind, Option.bind]
  exact e9

noncomputable def deltaLayerTrace (w : DeltaWeights) (conv rec : Option Value) (x : Value) :
    Option (Value × Value × Value) := do
  let normed ← rmsNorm M.hiddenNorm x w.inputNorm (f32 0x358637bd)
  let (mixed, tail, s) ← deltaMixerTrace M K w conv rec normed
  let out ← suffixTrace K w.mlp x mixed
  pure (out, tail, s)

-- QwenResidualDeltaLayer.forward for one decode token: the output and both
-- replaced SSMCache slots encode the model's stage output and cache.
theorem delta_layer (l : ResidualDelta.Layer) (w : DeltaWeights) (hl : DeltaLoaded M K l w)
    (cache : DeltaNet.Cache) (conv rec : Option Value) (hc : HistoryHolds conv cache.history)
    (hr : StateHolds rec cache.recurrent) (xv : Value) (x : Fin 5120 → BF) (hx : Row xv 5120 x)
    (hf : l.Finite cache (fun _ => x) 0) :
    ∃ out tail s, deltaLayerTrace M K w conv rec xv = some (out, tail, s) ∧
      Row out 5120 (l.forward cache (fun _ => x) 0) ∧
      HistoryHolds (some tail) (l.cacheAfter cache (fun _ => x) 1).history ∧
      StateHolds (some s) (l.cacheAfter cache (fun _ => x) 1).recurrent := by
  obtain ⟨normed, e1, tn⟩ := GlueAttention.hidden_norm M l.inputNorm hl.inputPlatform xv w.inputNorm x hx hl.inputNorm
  obtain ⟨mixed, tail, s, e2, tm, tt, ts⟩ := delta_mixer M K l w hl cache conv rec hc hr normed _ tn hf.mixer
  obtain ⟨out, e3, tout⟩ := suffix K l.suffix w.mlp hl.suffix xv mixed x _ hx tm hf.suffix
  refine ⟨out, tail, s, ?_, tout, tt, ts⟩
  unfold deltaLayerTrace
  rw [GlueAttention.eps_word, e1]; dsimp only [bind, Option.bind]
  rw [e2]; dsimp only [bind, Option.bind]
  rw [e3]; rfl

/-! ## The attention layer

blocks.ts QwenResidualAttentionLayer.forward with Qwen3TextAttention
(forwardText → forwardPositioned, GlueAttention.attentionTrace) and the
same written MLP suffix. -/

structure AttentionWeights where
  inputNorm : Value
  q : Linear
  k : Linear
  v : Linear
  o : Linear
  qKind : Projector
  kKind : Projector
  vKind : Projector
  oKind : Projector
  qNorm : Value
  kNorm : Value
  mlp : MlpWeights

structure AttentionLoaded (l : ResidualAttention.Layer) (w : AttentionWeights) : Prop where
  inputNorm : GlueAttention.Vector w.inputNorm 5120 l.inputNorm.weight
  inputPlatform : l.inputNorm.platform = M.hiddenNorm
  q : Loaded M K w.qKind w.q l.mixer.projections.q
  k : Loaded M K w.kKind w.k l.mixer.projections.k
  v : Loaded M K w.vKind w.v l.mixer.projections.v
  o : Loaded M K w.oKind w.o l.mixer.output
  qNorm : GlueAttention.Vector w.qNorm 256 l.mixer.preparation.qNorm.weight
  kNorm : GlueAttention.Vector w.kNorm 256 l.mixer.preparation.kNorm.weight
  bound : GlueAttention.Bound M l.mixer
  suffix : MlpLoaded K l.suffix w.mlp

noncomputable def attentionLayerTrace (w : AttentionWeights) (kb vb : Option Value) (n : Nat) (x : Value) :
    Option (Value × Value × Value) := do
  let normed ← rmsNorm M.hiddenNorm x w.inputNorm (f32 0x358637bd)
  let qp ← project M K w.qKind w.q normed
  let kp ← project M K w.kKind w.k normed
  let vp ← project M K w.vKind w.v normed
  let (gated, kb', vb') ← GlueAttention.attentionTrace M qp kp vp w.qNorm w.kNorm kb vb n
  let mixed ← project M K w.oKind w.o gated
  let out ← suffixTrace K w.mlp x mixed
  pure (out, kb', vb')

-- attention_trace extended by the input norm, q/k/v projections, o_proj,
-- the residual norm, the MLP and the residual add.
theorem attention_layer (l : ResidualAttention.Layer) (w : AttentionWeights) (hl : AttentionLoaded M K l w)
    (cache : State.Kv.Cache BF n) (kb vb : Option Value)
    (hk : GlueKv.State kb n cache.keys) (hv : GlueKv.State vb n cache.values)
    (xv : Value) (x : Fin 5120 → BF) (hx : Row xv 5120 x) (hf : l.Finite x (RopeInputConstruction.inputs n) cache)
    (plain : w.qKind = .plain ∧ w.kKind = .plain ∧ w.vKind = .plain) :
    ∃ out kb' vb', attentionLayerTrace M K w kb vb n xv = some (out, kb', vb') ∧
      Row out 5120 (l.forward x (RopeInputConstruction.inputs n) cache) ∧
      GlueKv.State (some kb') (n+1) (l.cacheAfter x (RopeInputConstruction.inputs n) cache).keys ∧
      GlueKv.State (some vb') (n+1) (l.cacheAfter x (RopeInputConstruction.inputs n) cache).values := by
  obtain ⟨normed, e1, tn⟩ := GlueAttention.hidden_norm M l.inputNorm hl.inputPlatform xv w.inputNorm x hx hl.inputNorm
  obtain ⟨qp, e2, tq⟩ := project_row M K w.qKind w.q (blocks := 192) l.mixer.projections.q hl.q
    (fun h => absurd (h.symm.trans plain.1) (by decide)) normed _ tn hf.mixer.projections.q
  obtain ⟨kp, e3, tk⟩ := project_row M K w.kKind w.k (blocks := 16) l.mixer.projections.k hl.k
    (fun h => absurd (h.symm.trans plain.2.1) (by decide)) normed _ tn hf.mixer.projections.k
  obtain ⟨vp, e4, tv⟩ := project_row M K w.vKind w.v (blocks := 16) l.mixer.projections.v hl.v
    (fun h => absurd (h.symm.trans plain.2.2) (by decide)) normed _ tn hf.mixer.projections.v
  obtain ⟨gated, kb', vb', e5, tg, sk, sv⟩ := GlueAttention.attention_trace M l.mixer hl.bound _ cache kb vb hk hv
    qp kp vp w.qNorm w.kNorm tq tk tv hl.qNorm hl.kNorm
  obtain ⟨mixed, e6, tm⟩ := project_row M K w.oKind w.o (blocks := 80) l.mixer.output hl.o
    (fun _ => by unfold AffineRoute; decide) gated _ tg hf.mixer.output
  obtain ⟨out, e7, tout⟩ := suffix K l.suffix w.mlp hl.suffix xv mixed x _ hx tm hf.suffix
  refine ⟨out, kb', vb', ?_, tout, sk, sv⟩
  unfold attentionLayerTrace
  rw [GlueAttention.eps_word, e1]; dsimp only [bind, Option.bind]
  rw [e2]; dsimp only [bind, Option.bind]
  rw [e3]; dsimp only [bind, Option.bind]
  rw [e4]; dsimp only [bind, Option.bind]
  rw [e5]; dsimp only [bind, Option.bind]
  rw [e6]; dsimp only [bind, Option.bind]
  rw [e7]; rfl

end Host.Mlx.GlueLayers
