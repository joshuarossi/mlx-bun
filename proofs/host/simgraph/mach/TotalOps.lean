import host.mlx.GlueStep
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Inference.Kernels Host.Mlx Host.Mlx.GlueStep

/-! # The MLX operations are defined on well-typed arguments

Every MLX operation of the decode trace (Ops.lean, Value.lean, GlueKv.lean) is a definition guarded by its
arguments' dtypes and shapes only: on typed arguments it is defined, and its result's type is the
operation's (`Ty`: dtype and shape). No value premise (finiteness, range) enters — the values are whatever
the operation computes. -/

/-- A value's dtype and shape. -/
def Ty (v : Value) (d : Dtype) (sh : List Nat) : Prop := v.dtype = d ∧ v.shape = sh

theorem Ty.size {v : Value} {d : Dtype} {sh : List Nat} (h : Ty v d sh) : v.size = extent sh := by
  rw [Value.size, h.2]; rfl

theorem reshape_ty {v : Value} {d : Dtype} {sh : List Nat} (h : Ty v d sh) (sh' : List Nat) (he : extent sh' = extent sh) :
    ∃ y, reshape v sh' = some y ∧ Ty y d sh' :=
  ⟨_, reshape_some v sh' (by rw [he, h.2]), h.1, rfl⟩

theorem slice_ty {v : Value} {d : Dtype} {sh : List Nat} (h : Ty v d sh) (start stop : List Nat)
    (hc : start.length = sh.length ∧ stop.length = sh.length ∧
      (List.zip start (List.zip stop sh)).all (fun (a, b, n) => a ≤ b ∧ b ≤ n)) :
    ∃ y, slice v start stop = some y ∧ Ty y d (List.zipWith (· - ·) stop start) := by
  rw [← h.2] at hc
  obtain ⟨y, hy⟩ := slice_defined v start stop hc
  obtain ⟨hd, hs, _⟩ := slice_spec v y start stop hy
  exact ⟨y, hy, hd.trans h.1, hs⟩

theorem transpose_ty {v : Value} {d : Dtype} {sh : List Nat} (h : Ty v d sh) (axes : List Nat)
    (hc : axes.length = sh.length ∧ (List.range sh.length).all (fun a => axes.contains a)) :
    ∃ y, transpose v axes = some y ∧ Ty y d (axes.map fun a => sh.getD a 0) := by
  unfold transpose
  rw [h.2, ite_eq_left hc]
  exact ⟨_, rfl, h.1, rfl⟩

theorem concatenate_ty {a b : Value} {d : Dtype} {sa sb : List Nat} (ha : Ty a d sa) (hb : Ty b d sb) (axis : Nat)
    (hc : sa.length = sb.length ∧ axis < sa.length ∧
      (List.range sa.length).all (fun k => k = axis ∨ sa.getD k 0 = sb.getD k 0)) :
    ∃ y, concatenate a b axis = some y ∧ Ty y d (sa.set axis (sa.getD axis 0 + sb.getD axis 0)) := by
  unfold concatenate
  rw [ha.1, hb.1, ha.2, hb.2, ite_eq_left ⟨rfl, hc⟩]
  exact ⟨_, rfl, rfl, rfl⟩

theorem sliceUpdateRange_ty {v u : Value} {d : Dtype} {sv su : List Nat} (hv : Ty v d sv) (hu : Ty u d su)
    (start stop : List Nat) (hr : List.zipWith (· - ·) stop start = su)
    (hc : start.length = sv.length ∧ su.length = sv.length ∧
      (List.zip start (List.zip su sv)).all (fun (a, n, m) => a + n ≤ m)) :
    ∃ y, sliceUpdateRange v u start stop = some y ∧ Ty y d sv := by
  have hc' : u.dtype = v.dtype ∧ start.length = v.shape.length ∧ u.shape.length = v.shape.length ∧
      (List.zip start (List.zip u.shape v.shape)).all (fun (a, n, m) => a + n ≤ m) := by
    rw [hu.1, hv.1, hu.2, hv.2]; exact ⟨rfl, hc⟩
  obtain ⟨y, hy⟩ := sliceUpdate_defined v u start hc'
  obtain ⟨hd, hs, _⟩ := sliceUpdate_spec v u y start hy
  refine ⟨y, ?_, hd.trans hv.1, hs.trans hv.2⟩
  unfold sliceUpdateRange
  rw [hu.2, ite_eq_left hr]
  exact hy

theorem map1_ty (op : BF → BF) {v : Value} {sh : List Nat} (h : Ty v .bfloat16 sh) :
    ∃ y, map1 op v = some y ∧ Ty y .bfloat16 sh := by
  unfold map1
  rw [ite_eq_left h.1]
  exact ⟨_, rfl, h.1, h.2⟩

theorem map2_ty (op : BF → BF → BF) {a b : Value} {sh : List Nat} (ha : Ty a .bfloat16 sh) (hb : Ty b .bfloat16 sh) :
    ∃ y, map2 op a b = some y ∧ Ty y .bfloat16 sh := by
  unfold map2
  rw [ite_eq_left ⟨ha.1, hb.1, ha.2.trans hb.2.symm⟩]
  exact ⟨_, rfl, ha.1, ha.2⟩

theorem add_ty {a b : Value} {sh : List Nat} (ha : Ty a .bfloat16 sh) (hb : Ty b .bfloat16 sh) :
    ∃ y, add a b = some y ∧ Ty y .bfloat16 sh := by
  rw [add_same a b (ha.2.trans hb.2.symm)]
  exact map2_ty _ ha hb

theorem rowwise_ty (w : Nat) (f : Nat → (Fin w → BF) → Fin w → BF) {v : Value} {sh : List Nat}
    (h : Ty v .bfloat16 sh) (hl : sh.getLast? = some w) (hw : 0 < w) :
    ∃ y, rowwise w f v = some y ∧ Ty y .bfloat16 sh := by
  unfold rowwise
  rw [dite_cond_eq_true (by simp [h.1, h.2, hl, hw])]
  exact ⟨_, rfl, h.1, h.2⟩

theorem rmsNorm_ty (P : RmsNorm.Platform) {x weight : Value} {sh : List Nat} {w : Nat} (eps : Float32)
    (hx : Ty x .bfloat16 sh) (hwt : Ty weight .bfloat16 [w]) (hl : sh.getLast? = some w) (hw : 0 < w) :
    ∃ y, rmsNorm P x weight eps = some y ∧ Ty y .bfloat16 sh := by
  unfold rmsNorm
  rw [hwt.1, hwt.2]
  exact rowwise_ty w _ hx hl hw

theorem rope_ty {C : M1Max.Contract} (M : MlxContract C) {x : Value} {sh : List Nat} (b : Float32) (scale : Float32)
    (offset : Int) (hx : Ty x .bfloat16 sh) (h4 : sh.length = 4) (h1 : sh.getD 2 0 = 1) (hl : sh.getLast? = some 256) :
    ∃ y, rope M x 64 false (some b) scale offset = some y ∧ Ty y .bfloat16 sh := by
  unfold rope
  dsimp only
  rw [ite_eq_left ⟨rfl, rfl, by rw [hx.2]; exact h4, by rw [hx.2]; exact h1⟩]
  exact rowwise_ty 256 _ hx hl (by decide)

theorem sdpa_ty {C : M1Max.Contract} (M : MlxContract C) {q k v : Value} {n : Nat}
    (hq : Ty q .bfloat16 [1, 24, 1, 256]) (hk : Ty k .bfloat16 [1, 4, n, 256]) (hv : Ty v .bfloat16 [1, 4, n, 256]) :
    ∃ y, sdpa M q k v Attention.SdpaScore.scale = some y ∧ Ty y .bfloat16 [1, 24, 1, 256] := by
  simp [sdpa, hq.1, hq.2, hk.1, hk.2, hv.1, hv.2, Ty]

theorem conv1d_ty {C : M1Max.Contract} (M : MlxContract C) {input weight : Value} (c : Nat)
    (hi : Ty input .bfloat16 [1, 4, c]) (hw : Ty weight .bfloat16 [c, 4, 1])
    (hs : Delta.Convolution.depthwiseSelected c c c 1 1 1 0 false = true) :
    ∃ y, conv1d M input weight 1 0 1 c = some y ∧ Ty y .bfloat16 [1, 1, c] := by
  simp [conv1d, hi.1, hi.2, hw.1, hw.2, hs, Ty]

theorem quantizedMatmul_ty {C : M1Max.Contract} (M : MlxContract C) {x w scales biases : Value} (k rows : Nat)
    (hx : Ty x .bfloat16 [1, 1, k]) (hw : Ty w .uint32 [rows, k / 8]) (hs : scales.shape = [rows, k / 64])
    (hb : biases.shape = [rows, k / 64]) (hk : k % 512 = 0) :
    ∃ y, quantizedMatmul M x w scales biases true 64 4 "affine" = some y ∧ Ty y .bfloat16 [1, 1, rows] := by
  simp [quantizedMatmul, hx.1, hx.2, hw.1, hw.2, hs, hb, hk, Ty]

theorem dequantizeRow_ty {C : M1Max.Contract} (M : MlxContract C) {w scales biases : Value}
    (hw : Ty w .uint32 [1, 1, 640]) (hs : scales.shape = [1, 1, 80]) (hb : biases.shape = [1, 1, 80]) :
    ∃ y, dequantizeRow M w scales biases = some y ∧ Ty y .bfloat16 [1, 1, 5120] := by
  unfold dequantizeRow
  rw [ite_eq_left ⟨hw.1, hw.2, hs, hb⟩]
  exact ⟨_, rfl, rfl, rfl⟩

theorem takeAxis0_ty {table ids : Value} {d : Dtype} {rows cols : Nat} (ht : Ty table d [rows, cols])
    (hi : ids.dtype = .uint32) :
    ∃ y, takeAxis0 table ids = some y ∧ Ty y d (ids.shape ++ [cols]) := by
  unfold takeAxis0
  rw [if_pos hi]
  unfold takeRows
  rw [ht.2]
  exact ⟨_, rfl, ht.1, rfl⟩

/-- The conv state's new tail: `sliceDynamic` of the `[1, 3, 10240]` view at the zero index. -/
theorem sliceDynamic_tail_ty {v : Value} {d : Dtype} (h : Ty v d [1, 3, 10240]) :
    ∃ y, sliceDynamic v GlueConv.zeroIndex [0] [1, 3, 10240] = some y ∧ Ty y d [1, 3, 10240] := by
  have e : sliceDynamic v GlueConv.zeroIndex [0] [1, 3, 10240] = slice v [0, 0, 0] [1, 3, 10240] := by
    unfold sliceDynamic
    rw [h.2]
    rfl
  rw [e]
  exact slice_ty h _ _ (by decide)

theorem reshapeInfer_ty {v : Value} {d : Dtype} {sh : List Nat} (h : Ty v d sh) :
    ∃ y, GlueLayout.reshapeInfer v [1, 1, -1] = some y ∧ Ty y d [1, 1, extent sh] := by
  rw [GlueLayout.reshapeInfer_merge, h.size]
  exact reshape_ty h [1, 1, extent sh] (by simp [extent])

theorem computeG_ty {C : M1Max.Contract} (M : MlxContract C) {aLog a dt : Value} (ha : aLog.dtype = .bfloat16)
    (hx : Ty a .bfloat16 [1, 1, 48]) (hd : dt.dtype = .bfloat16) :
    ∃ g, closureApply M .computeG [aLog, a, dt] = some [g] ∧ Ty g .float32 [1, 1, 48] := by
  unfold closureApply Closure.eval
  dsimp only
  rw [ite_eq_left ⟨ha, hx.1, hd, hx.2⟩]
  exact ⟨_, rfl, rfl, rfl⟩

theorem logsumexp_ty (P : Sampling.LogSumExpRanges.Platform) {v : Value} (h : Ty v .bfloat16 [1, 248320]) :
    ∃ s, logsumexp P v = some s ∧ Ty s .bfloat16 [1, 1] := by
  unfold logsumexp
  rw [ite_eq_left (show v.dtype = .bfloat16 ∧ v.shape = [1, 248320] from h)]
  exact ⟨_, rfl, rfl, rfl⟩

/-- A KV buffer at offset `n`: none at `0`, else a bf16 `[1, 4, cap, 256]` with `cap` a multiple of 256, `n ≤ cap`. -/
def KvAt (n : Nat) : Option Value → Prop
  | none => n = 0
  | some b => ∃ cap, cap % 256 = 0 ∧ Ty b .bfloat16 [1, 4, cap, 256] ∧ n ≤ cap

/-- kv.ts `updateAndFetch` of one row is defined on a buffer at offset `n` and a `[1, 4, 1, 256]` row: the buffer
at `n + 1` and the view `[1, 4, n + 1, 256]`. -/
theorem kvStep_ty {buf : Option Value} {n : Nat} (hb : KvAt n buf) {k : Value} (hk : Ty k .bfloat16 [1, 4, 1, 256]) :
    ∃ b v, GlueKv.step buf n k = some (b, v) ∧ KvAt (n + 1) (some b) ∧ Ty v .bfloat16 [1, 4, n + 1, 256] := by
  have hs : GlueKv.State buf n (fun h t i => bf (match buf with
      | some b => b.get [0, h.val, t.val, i.val]
      | none => 0)) := by
    cases buf with
    | none => exact hb
    | some b =>
      obtain ⟨cap, hc, ht, hn⟩ := hb
      exact ⟨cap, hc, ht.1, ht.2, hn, fun _ _ _ => rfl⟩
  obtain ⟨b, v, e, ⟨cap, hc, hd, hsh, hn, _⟩, vd, vs, _⟩ := GlueKv.step_correct buf _ hs k
    (fun h i => bf (k.get [0, h.val, 0, i.val])) ⟨hk.1, hk.2, fun _ y _ => by rw [Fin.fin_one_eq_zero y]; rfl⟩
  exact ⟨b, v, e, ⟨cap, hc, ⟨hd, hsh⟩, hn⟩, vd, vs⟩

end Host.Mlx.SimGraph.Mach
