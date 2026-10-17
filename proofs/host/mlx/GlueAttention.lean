import host.mlx.GlueLayout
import host.mlx.GlueKv
import models.qwen.RopeInputConstruction

namespace Host.Mlx.GlueAttention
open Inference Inference.Models.Qwen Inference.Kernels.Attention Inference.Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

variable {C : M1Max.Contract} (M : MlxContract C)

-- A bf16 [n] vector (q_norm/k_norm/norm weights).
def Vector (v : Value) (n : Nat) (f : Fin n → BF) : Prop :=
  v.dtype = .bfloat16 ∧ v.shape = [n] ∧ ∀ i : Fin n, bf (v.elems i.val) = f i

/-! ## Gap 4: RoPE argument binding

blocks.ts forwardText calls ops.rope(value, ropeDims, ropeBase, cache.offset,
null) with ropeDims = trunc(256·0.25) = 64 and ropeBase = 1e7; ops.ts:147
issues mlx_fast_rope(o, x, 64, false, optFloat(1e7), 1.0, offset, 0, s).
ffi.ts optFloat packs the f32 word in the low 32 bits and has_value at bit
32; bun:ffi converts 1.0 to f32 and cache.offset to i32. -/

def optionalFloat (word : Nat) : Option Float32 :=
  if word / 2^32 % 2 = 1 then some (f32 (word % 2^32)) else none

theorem base_word : optionalFloat (0x4b189680 + 2^32) = some (Float32.ofBits 0x4b189680) := by
  unfold optionalFloat; decide +kernel
theorem scale_word : f32 0x3f800000 = 1 := by decide +kernel
theorem eps_word : f32 0x358637bd = Blocks.eps := by decide +kernel
theorem sdpa_scale_word : f32 0x3d800000 = SdpaScore.scale := by decide +kernel

-- Exactly the model's position constructor for every supported offset.
theorem rope_inputs (n : Nat) :
    (⟨M.log2 (Float32.ofBits 0x4b189680), Float32.ofInt (n : Int), f32 0x3f800000⟩ : RopeAngles.Inputs) =
      RopeInputConstruction.inputs n := by
  rw [M.log2_route, scale_word]; rfl

/-! ## Numeric operations on the route's tensors -/

theorem rmsNorm_rows (P : RmsNorm.Platform) (x weight : Value) (eps : Float32) (wt : Fin w → BF)
    (hw : Vector weight w wt) (hx : x.dtype = .bfloat16) (hl : x.shape.getLast? = some w) (pos : 0 < w) :
    ∃ u, rmsNorm P x weight eps = some u ∧ u.dtype = .bfloat16 ∧ u.shape = x.shape ∧
      ∀ (r : Nat) (j : Fin w), bf (u.elems (r*w+j.val)) =
        RmsNorm.value P (fun k => BFloat16.widen (bf (x.elems (r*w+k.val)))) wt (Float32.ofNat w) eps (fun _ => 0) 0 j := by
  have defined : ∃ u, rowwise w (fun _ row => Layers.Normalization.value P (fun k => BFloat16.widen (row k))
      (fun k => bf (weight.elems k.val)) false (Float32.ofNat w) eps (fun _ => 0) 0) x = some u := by
    unfold rowwise; rw [dite_eq_left ⟨hx, hl, pos⟩]; exact ⟨_, rfl⟩
  obtain ⟨u, hu⟩ := defined
  have op : rmsNorm P x weight eps = some u := by unfold rmsNorm; rw [hw.1, hw.2.1]; exact hu
  obtain ⟨ud, us, _⟩ := rowwise_elems _ _ _ _ hu 0 ⟨0, pos⟩
  have wf : (fun k : Fin w => bf (weight.elems k.val)) = wt := funext hw.2.2
  refine ⟨u, op, ud.trans hx, us, fun r j => ?_⟩
  obtain ⟨_, _, e⟩ := rowwise_elems _ _ _ _ hu r j
  rw [e, wf]
  rfl

theorem width_word : Float32.ofNat 256 = AttentionHeads.width := by decide +kernel
theorem hidden_width_word : Float32.ofNat 5120 = Blocks.width := by decide +kernel

-- q_norm/k_norm forward (layers RMSNorm → ops.rmsNorm(x, w, 1e-6)) per head.
theorem head_norm (n : AttentionHeads.Norm) (hp : n.platform = M.headNorm) (x weight : Value)
    (f : Fin 1 → Fin H → Fin 256 → BF) (hx : Tensor4 x 1 H 256 f) (hw : Vector weight 256 n.weight) :
    ∃ u, rmsNorm M.headNorm x weight Blocks.eps = some u ∧ Tensor4 u 1 H 256 (fun a h => n.forward (f a h)) := by
  obtain ⟨u, op, ud, us, ue⟩ := rmsNorm_rows M.headNorm x weight Blocks.eps n.weight hw hx.1
    (by rw [hx.2.1]; rfl) (by decide)
  refine ⟨u, op, Tensor4.mk ud (us.trans hx.2.1) fun a h i => ?_⟩
  have e := ue (a.val*H+h.val) i
  rw [e, width_word, rmsValue_scratch _ _ _ _ _ _ n.scratch 0 n.base]
  unfold AttentionHeads.Norm.forward Layers.Normalization.value
  rw [hp]
  have hin : (fun k : Fin 256 => BFloat16.widen (bf (x.elems ((a.val*H+h.val)*256+k.val)))) =
      (fun k => BFloat16.widen (f a h k)) := funext fun k => by rw [Tensor4.elems hx a h k]
  rw [hin]
  rfl

-- The final/hidden RMSNorm on [1,1,5120].
theorem hidden_norm (n : Blocks.Norm) (hp : n.platform = M.hiddenNorm) (x weight : Value)
    (f : Fin 5120 → BF) (hx : Row x 5120 f) (hw : Vector weight 5120 n.weight) :
    ∃ u, rmsNorm M.hiddenNorm x weight Blocks.eps = some u ∧ Row u 5120 (n.forward f) := by
  obtain ⟨u, op, ud, us, ue⟩ := rmsNorm_rows M.hiddenNorm x weight Blocks.eps n.weight hw hx.1
    (by rw [hx.2.1]; rfl) (by decide)
  refine ⟨u, op, Row.mk ud (us.trans hx.2.1) fun j => ?_⟩
  have e := ue 0 j
  simp only [Nat.zero_mul, Nat.zero_add] at e
  rw [e, hidden_width_word, rmsValue_scratch _ _ _ _ _ _ n.scratch 0 n.base]
  unfold Blocks.Norm.forward Layers.Normalization.value
  rw [hp]
  have hin : (fun k : Fin 5120 => BFloat16.widen (bf (x.elems k.val))) = (fun k => BFloat16.widen (f k)) :=
    funext fun k => by rw [Row.elems hx k]
  rw [hin]
  rfl

-- fast_rope on [1,H,1,256] (T = 1): every row rotates with position offset.
theorem rope_rows (x : Value) (f : Fin H → Fin 1 → Fin 256 → BF) (hx : Tensor4 x H 1 256 f)
    (b s : Float32) (off : Int) :
    ∃ u, rope M x 64 false (some b) s off = some u ∧ Tensor4 u H 1 256 (fun h t =>
      Rope.head M.rotation (f h t) (RopeAngles.value M.angles ⟨M.log2 b, Float32.ofInt off, s⟩)) := by
  have defined : ∃ u, rowwise 256 (fun _ row => Rope.head M.rotation row
      (RopeAngles.value M.angles ⟨M.log2 b, Float32.ofInt off, s⟩)) x = some u := by
    unfold rowwise; rw [dite_eq_left ⟨hx.1, by rw [hx.2.1]; rfl, by decide⟩]; exact ⟨_, rfl⟩
  obtain ⟨u, hu⟩ := defined
  have op : rope M x 64 false (some b) s off = some u := by
    unfold rope
    exact (ite_eq_left (show 64 = 64 ∧ false = false ∧ x.shape.length = 4 ∧ x.shape.getD 2 0 = 1 from
      ⟨rfl, rfl, by rw [hx.2.1]; rfl, by rw [hx.2.1]; rfl⟩)).trans hu
  obtain ⟨ud, us, _⟩ := rowwise_elems _ _ _ _ hu 0 0
  refine ⟨u, op, Tensor4.mk (ud.trans hx.1) (us.trans hx.2.1) fun h t i => ?_⟩
  have ht : t.val = 0 := by omega
  obtain ⟨_, _, e⟩ := rowwise_elems _ _ _ _ hu h.val i
  simp only [ht, Nat.mul_one, Nat.add_zero]
  rw [e]
  congr 1
  funext k
  have := Tensor4.elems hx h t k
  simp only [ht, Nat.mul_one, Nat.add_zero] at this
  rw [this]

-- fast_scaled_dot_product_attention(q, k, v, 1/16, "") on the cache views.
theorem sdpa_heads (q k v : Value) (query : Fin 24 → Fin 256 → BF) (keys values : Fin 4 → Fin n → Fin 256 → BF)
    (hq : Tensor4 q 24 1 256 (fun h _ => query h)) (hk : Tensor4 k 4 n 256 keys) (hv : Tensor4 v 4 n 256 values) :
    ∃ o, sdpa M q k v SdpaScore.scale = some o ∧ Tensor4 o 24 1 256 (fun h _ =>
      SdpaDispatched.forward M.sdpa M.sdpaMerge arch (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h))) := by
  have op : sdpa M q k v SdpaScore.scale = some { q with elems := (fun i =>
      bfWord (sdpaAt M q k v n ⟨i / 256 % 24, Nat.mod_lt _ (by decide)⟩ ⟨i % 256, Nat.mod_lt _ (by decide)⟩)) } := by
    unfold sdpa; rw [hk.2.1]
    exact ite_eq_left ⟨hq.1, hk.1, hv.1, hq.2.1, hv.2.1, rfl⟩
  refine ⟨_, op, Tensor4.mk hq.1 hq.2.1 fun h t c => ?_⟩
  have ht : t.val = 0 := by omega
  have e1 : (⟨((h.val*1+t.val)*256+c.val) / 256 % 24, Nat.mod_lt _ (by decide)⟩ : Fin 24) = h :=
    Fin.ext (by simp only [ht]; omega)
  have e2 : (⟨((h.val*1+t.val)*256+c.val) % 256, Nat.mod_lt _ (by decide)⟩ : Fin 256) = c :=
    Fin.ext (by simp only [ht]; omega)
  dsimp only
  rw [bf_word, e1, e2]
  have hq' : (fun c' : Fin 256 => bf (q.get [0, h.val, 0, c'.val])) = query h := funext fun c' => hq.2.2 h 0 c'
  have hk' : (fun (t' : Fin n) (c' : Fin 256) => bf (k.get [0, (SdpaScore.kvHead h).val, t'.val, c'.val])) =
      keys (SdpaScore.kvHead h) := funext fun t' => funext fun c' => hk.2.2 _ t' c'
  have hv' : (fun (t' : Fin n) (c' : Fin 256) => bf (v.get [0, (SdpaScore.kvHead h).val, t'.val, c'.val])) =
      values (SdpaScore.kvHead h) := funext fun t' => funext fun c' => hv.2.2 _ t' c'
  unfold sdpaAt
  dsimp only
  rw [hq', hk', hv']

theorem sigmoid_row (g : Value) (gate : Fin m → BF) (hg : Row g m gate) :
    ∃ s, sigmoid M g = some s ∧ Row s m (fun j => OutputGate.sigmoid M.sigmoid (gate j)) := by
  have op : sigmoid M g = some { g with elems := fun i => bfWord (OutputGate.sigmoid M.sigmoid (bf (g.elems i))) } := by
    unfold sigmoid map1; rw [ite_eq_left hg.1]
  refine ⟨_, op, Row.mk hg.1 hg.2.1 fun j => ?_⟩
  dsimp only
  rw [bf_word, Row.elems hg j]

theorem multiply_row (a b : Value) (x y : Fin m → BF) (ha : Row a m x) (hb : Row b m y) :
    ∃ p, multiply a b = some p ∧ Row p m (fun j => BFloat16Arithmetic.mul (x j) (y j)) := by
  have op : multiply a b = some { a with elems := fun i => bfWord (BFloat16Arithmetic.mul (bf (a.elems i)) (bf (b.elems i))) } := by
    unfold multiply map2; rw [ite_eq_left ⟨ha.1, hb.1, ha.2.1.trans hb.2.1.symm⟩]
  refine ⟨_, op, Row.mk ha.1 ha.2.1 fun j => ?_⟩
  dsimp only
  rw [bf_word, Row.elems ha j, Row.elems hb j]

theorem Tensor4.congr (h : Tensor4 v a b c f) (e : f = g) : Tensor4 v a b c g := e ▸ h
theorem Row.congr (h : Row v n f) (e : f = g) : Row v n g := e ▸ h

/-! ## The attention block as issued (gaps 1, 2, 4, 8)

blocks.ts Qwen3Attention.forwardPositioned for one text token, from the
q/k/v projection outputs to the gated value fed to o_proj, with the TS
constant arguments as the FFI words bun:ffi passes. -/

noncomputable def attentionTrace (qp kp vp qw kw : Value) (kb vb : Option Value) (n : Nat) :
    Option (Value × Value × Value) := do
  let qpr ← reshape qp [1,1,24,512]
  let qh ← slice qpr [0,0,0,0] [1,1,24,256]
  let gh ← slice qpr [0,0,0,256] [1,1,24,512]
  let gate ← reshape gh [1,1,6144]
  let kr ← reshape kp [1,1,4,256]
  let vr ← reshape vp [1,1,4,256]
  let qn ← rmsNorm M.headNorm qh qw (f32 0x358637bd)
  let qt ← transpose qn [0,2,1,3]
  let kn ← rmsNorm M.headNorm kr kw (f32 0x358637bd)
  let kt ← transpose kn [0,2,1,3]
  let vt ← transpose vr [0,2,1,3]
  let q ← rope M qt 64 false (optionalFloat (0x4b189680 + 2^32)) (f32 0x3f800000) n
  let k ← rope M kt 64 false (optionalFloat (0x4b189680 + 2^32)) (f32 0x3f800000) n
  let (kb', keys) ← GlueKv.step kb n k
  let (vb', values) ← GlueKv.step vb n vt
  let attn ← sdpa M q keys values (f32 0x3d800000)
  let attnT ← transpose attn [0,2,1,3]
  let merged ← GlueLayout.reshapeInfer attnT [1,1,-1]
  let sig ← sigmoid M gate
  let gated ← multiply merged sig
  pure (gated, kb', vb')

-- The layer's platforms are the ones MLX runs.
structure Bound (l : Attention.Layer) : Prop where
  qNorm : l.preparation.qNorm.platform = M.headNorm
  kNorm : l.preparation.kNorm.platform = M.headNorm
  angles : l.preparation.angles = M.angles
  rotation : l.preparation.rotation = M.rotation
  attention : l.attention = M.sdpa
  merge : l.mergeContracted = M.sdpaMerge
  arch : l.architectureSuffix = arch
  gate : l.gate = M.sigmoid

theorem attention_trace (l : Attention.Layer) (hb : Bound M l) (x : Fin 5120 → BF)
    (cache : State.Kv.Cache BF n) (kb vb : Option Value)
    (hk : GlueKv.State kb n cache.keys) (hv : GlueKv.State vb n cache.values)
    (qp kp vp qw kw : Value) (hqp : Row qp 12288 (l.projections.q.forward x))
    (hkp : Row kp 1024 (l.projections.k.forward x)) (hvp : Row vp 1024 (l.projections.v.forward x))
    (hqw : Vector qw 256 l.preparation.qNorm.weight) (hkw : Vector kw 256 l.preparation.kNorm.weight) :
    ∃ gated kb' vb', attentionTrace M qp kp vp qw kw kb vb n = some (gated, kb', vb') ∧
      Row gated 6144 (l.merged x (RopeInputConstruction.inputs n) cache) ∧
      GlueKv.State (some kb') (n+1) (l.cacheAfter x (RopeInputConstruction.inputs n) cache).keys ∧
      GlueKv.State (some vb') (n+1) (l.cacheAfter x (RopeInputConstruction.inputs n) cache).values := by
  let angle := RopeInputConstruction.inputs n
  let heads := l.heads x angle
  obtain ⟨qpr, qh, gh, g, e1, e2, e3, e4, tq, tg⟩ := GlueLayout.query_split qp _ hqp
  obtain ⟨kr, e5, tk⟩ := GlueLayout.kv_heads kp _ hkp
  obtain ⟨vr, e6, tv⟩ := GlueLayout.kv_heads vp _ hvp
  obtain ⟨qn, e7, tqn⟩ := head_norm M l.preparation.qNorm hb.qNorm qh qw _ tq hqw
  obtain ⟨qt, e8, tqt⟩ := GlueLayout.transpose_heads qn _ tqn
  obtain ⟨kn, e9, tkn⟩ := head_norm M l.preparation.kNorm hb.kNorm kr kw _ tk hkw
  obtain ⟨kt, e10, tkt⟩ := GlueLayout.transpose_heads kn _ tkn
  obtain ⟨vt, e11, tvt⟩ := GlueLayout.transpose_heads vr _ tv
  obtain ⟨q, e12, tqr⟩ := rope_rows M qt _ tqt (Float32.ofBits 0x4b189680) (f32 0x3f800000) n
  obtain ⟨k, e13, tkr⟩ := rope_rows M kt _ tkt (Float32.ofBits 0x4b189680) (f32 0x3f800000) n
  have tq' : Tensor4 q 24 1 256 (fun h _ => heads.query h) := Tensor4.congr tqr (by
    funext h t
    rw [rope_inputs M n, ← hb.rotation, ← hb.angles]
    rfl)
  have tk' : Tensor4 k 4 1 256 (fun h _ i => heads.key h i) := Tensor4.congr tkr (by
    funext h t
    rw [rope_inputs M n, ← hb.rotation, ← hb.angles]
    rfl)
  have tv' : Tensor4 vt 4 1 256 (fun h _ i => heads.value h i) := Tensor4.congr tvt rfl
  obtain ⟨kb', kview, vb', vview, e14, e15, sk, sv, tkv, tvv⟩ :=
    GlueKv.update_and_fetch kb vb cache hk hv k vt heads.key heads.value tk' tv'
  obtain ⟨o, e16, ho⟩ := sdpa_heads M q kview vview (fun h => heads.query h) _ _ tq' tkv tvv
  obtain ⟨ot, m, e17, e18, tm⟩ := GlueLayout.merge o _ ho
  obtain ⟨sg, e19, ts⟩ := sigmoid_row M g _ tg
  obtain ⟨gated, e20, tgd⟩ := multiply_row m sg _ _ tm ts
  refine ⟨gated, kb', vb', ?_, Row.congr tgd ?_, sk, sv⟩
  · rw [← eps_word] at e7 e9
    rw [← base_word] at e12 e13
    rw [← sdpa_scale_word] at e16
    unfold attentionTrace
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
    rw [e19]; dsimp only [bind, Option.bind]
    rw [e20]; rfl
  · funext j
    rw [← hb.gate, ← hb.attention, ← hb.merge, ← hb.arch]
    rfl

end Host.Mlx.GlueAttention
