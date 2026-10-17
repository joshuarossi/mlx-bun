import host.mlx.Ops
import models.qwen.Attention

namespace Host.Mlx.GlueLayout
open Inference Inference.Models.Qwen

/-! Gaps 1 and 8: the layout op sequences of blocks.ts forwardPositioned,
with the TS constant arguments, realize the model's folded index maps
(AttentionHeads.queryIndex/gateIndex/kvIndex, Attention.headIndex). Views
are values: a transposed or sliced operand is the row-major value of its
logical shape, whatever strides MLX gives it. -/

-- qp = q_proj(x) [1,1,12288]; reshape [1,1,24,512]; ops.split(qpr,[256],-1)
-- issues slice [0,0,0,0]→[1,1,24,256] and [0,0,0,256]→[1,1,24,512];
-- reshape(gateHeads, [1,1,6144]).
theorem query_split (qp : Value) (q : Fin 12288 → BF) (hq : Row qp 12288 q) :
    ∃ qpr qh gh g, reshape qp [1,1,24,512] = some qpr ∧ slice qpr [0,0,0,0] [1,1,24,256] = some qh ∧
      slice qpr [0,0,0,256] [1,1,24,512] = some gh ∧ reshape gh [1,1,6144] = some g ∧
      Tensor4 qh 1 24 256 (fun _ h i => q (AttentionHeads.queryIndex h i)) ∧
      Row g 6144 (fun j => q (AttentionHeads.gateIndex (Attention.headIndex j) (Attention.coordinate j))) := by
  have qe := Row.elems hq
  have hr := reshape_some qp [1,1,24,512] (by rw [hq.2.1]; rfl)
  obtain ⟨qh, hqh⟩ := slice_defined { qp with shape := [1,1,24,512] } [0,0,0,0] [1,1,24,256] ⟨rfl, rfl, rfl⟩
  obtain ⟨gh, hgh⟩ := slice_defined { qp with shape := [1,1,24,512] } [0,0,0,256] [1,1,24,512] ⟨rfl, rfl, rfl⟩
  obtain ⟨qd, qs, qget⟩ := slice_spec _ _ _ _ hqh
  obtain ⟨gd, gs, gget⟩ := slice_spec _ _ _ _ hgh
  norm_num [List.zipWith] at qs gs
  have hg := reshape_some gh [1,1,6144] (by rw [gs]; rfl)
  refine ⟨_, qh, gh, _, hr, hqh, hgh, hg, ?_, ?_⟩
  · apply Tensor4.mk (by rw [qd]; exact hq.1) qs
    intro x h i
    have hx : x.val = 0 := by omega
    have e := qget [0, x.val, h.val, i.val] (by rw [qs]; exact within4 (by omega) x.isLt h.isLt i.isLt)
    simp only [List.zipWith, Nat.zero_add] at e
    rw [get4 qh qs, get4 { qp with shape := [1,1,24,512] } rfl] at e
    simp only [hx] at e ⊢
    norm_num at e ⊢
    rw [e]
    have := qe ⟨h.val*512+i.val, by omega⟩
    simpa [AttentionHeads.queryIndex] using this
  · apply Row.mk (by change gh.dtype = _; rw [gd]; exact hq.1) rfl
    intro j
    have hj := j.isLt
    change bf (gh.elems j.val) = _
    have e := gget [0, 0, j.val/256, j.val%256]
      (by rw [gs]; exact within4 (by omega) (by omega) (by omega) (Nat.mod_lt _ (by omega)))
    simp only [List.zipWith, Nat.zero_add] at e
    rw [get4 gh gs, get4 { qp with shape := [1,1,24,512] } rfl] at e
    have i1 : j.val = ((0*1+0)*24+j.val/256)*256+j.val%256 := by omega
    have i2 : ((0*1+0)*24+j.val/256)*512+(256+j.val%256) =
        (AttentionHeads.gateIndex (Attention.headIndex j) (Attention.coordinate j)).val := by
      simp only [AttentionHeads.gateIndex, Attention.headIndex, Attention.coordinate]; omega
    rw [i1, e, i2]
    exact qe _

-- k = k_proj(x) [1,1,1024]; reshape [1,1,4,256] (likewise v).
theorem kv_heads (kp : Value) (k : Fin 1024 → BF) (hk : Row kp 1024 k) :
    ∃ kr, reshape kp [1,1,4,256] = some kr ∧ Tensor4 kr 1 4 256 (fun _ h i => k (AttentionHeads.kvIndex h i)) := by
  have ke := Row.elems hk
  refine ⟨_, reshape_some kp [1,1,4,256] (by rw [hk.2.1]; rfl), ?_⟩
  apply Tensor4.mk (v := { kp with shape := [1,1,4,256] }) hk.1 rfl
  intro x h i
  have hx : x.val = 0 := by omega
  have := ke ⟨h.val*256+i.val, by omega⟩
  simp only [hx]
  simpa [AttentionHeads.kvIndex] using this

-- transpose_axes(v, [0,2,1,3]) swaps the head and time axes.
theorem transpose_heads (v : Value) (f : Fin a → Fin b → Fin c → BF) (hv : Tensor4 v a b c f) :
    ∃ w, transpose v [0,2,1,3] = some w ∧ Tensor4 w b a c (fun y x z => f x y z) := by
  obtain ⟨w, hw⟩ := transpose_defined v [0,2,1,3] (by rw [hv.2.1]; exact ⟨rfl, rfl⟩)
  obtain ⟨wd, ws, wget⟩ := transpose_spec _ _ _ hw
  rw [hv.2.1] at ws
  simp only [List.map, List.getD] at ws
  refine ⟨w, hw, wd.trans hv.1, ws, fun y x z => ?_⟩
  rw [wget _ (by rw [ws]; exact within4 Nat.zero_lt_one y.isLt x.isLt z.isLt), hv.2.1]
  exact hv.2.2 x y z

-- reshape(x, [B, L, -1]): MLX infers the -1 axis from the size.
def reshapeInfer (v : Value) (shape : List Int) : Option Value :=
  let known := (shape.filter (· ≠ -1)).foldr (fun d p => d.toNat * p) 1
  if shape.count (-1) = 1 ∧ 0 < known ∧ v.size % known = 0 then
    reshape v (shape.map fun d => if d = -1 then v.size / known else d.toNat)
  else none

theorem reshapeInfer_merge (v : Value) : reshapeInfer v [1, 1, -1] = reshape v [1, 1, v.size] := by
  simp [reshapeInfer, Nat.mod_one]

-- attn [1,24,1,256]; transpose_axes [0,2,1,3]; reshape [1,1,-1] → [1,1,6144].
theorem merge (attn : Value) (f : Fin 24 → Fin 256 → BF) (ha : Tensor4 attn 24 1 256 (fun h _ i => f h i)) :
    ∃ t m, transpose attn [0,2,1,3] = some t ∧ reshapeInfer t [1, 1, -1] = some m ∧
      Row m 6144 (fun j => f (Attention.headIndex j) (Attention.coordinate j)) := by
  obtain ⟨t, ht, tt⟩ := transpose_heads attn _ ha
  have size : t.size = 6144 := by rw [Value.size_eq, tt.2.1]; rfl
  refine ⟨t, _, ht, by rw [reshapeInfer_merge, size]; exact reshape_some t _ (by rw [tt.2.1]; rfl), ?_⟩
  apply Row.mk (v := { t with shape := [1,1,6144] }) tt.1 rfl
  intro j
  have hj := j.isLt
  have e := Tensor4.elems tt 0 (Attention.headIndex j) (Attention.coordinate j)
  have i1 : ((0 : Fin 1).val*24+(Attention.headIndex j).val)*256+(Attention.coordinate j).val = j.val := by
    simp only [Attention.headIndex, Attention.coordinate, Fin.val_zero]; omega
  rw [i1] at e
  exact e

end Host.Mlx.GlueLayout
