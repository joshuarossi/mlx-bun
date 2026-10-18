import host.mlx.DimRoles
import host.mlx.NativeOutputs

set_option Elab.async false

namespace Host.Mlx.Ffi.InferenceRoles
open Host.Ts Host.Ts.Owned

inductive OutR (NR : NumV → NumV → Prop) : Out → Out → Prop where
  | node {s s' : List Dim} (dt : Nat) : Parametric.ShapeR NR s s' →
      OutR NR (.node s dt) (.node s' dt)
  | same (i : Nat) : OutR NR (.same i) (.same i)

theorem nthD_roles {rel : α → β → Prop} {xs : List α} {ys : List β}
    {d : α} {d' : β} (h : ListR rel xs ys) (hd : rel d d') (i : Nat) :
    rel (nthD d xs i) (nthD d' ys i) := by
  induction h generalizing i with
  | nil => cases i <;> exact hd
  | cons hr hs ih => cases i with
    | zero => exact hr
    | succ i => exact ih i

theorem setAt_roles {rel : α → β → Prop} {xs : List α} {ys : List β}
    {d : α} {d' : β} (h : ListR rel xs ys) (hd : rel d d') (i : Nat) :
    ListR rel (setAt xs i d) (setAt ys i d') := by
  induction i generalizing xs ys with
  | zero => cases h with
    | nil => exact .nil
    | cons hr hs => exact .cons hd hs
  | succ i ih => cases h with
    | nil => exact .nil
    | cons hr hs => exact .cons hr (ih hs)

theorem select_axes_roles {NR : NumV → NumV → Prop} {s s' : List Dim}
    (h : Parametric.ShapeR NR s s') (zero : NR (Dim.lit 0).num (Dim.lit 0).num) (axes : List Nat) :
    Parametric.ShapeR NR (axes.map (nthD (.lit 0) s)) (axes.map (nthD (.lit 0) s')) := by
  induction axes with
  | nil => exact .nil
  | cons a axes ih => exact .cons (nthD_roles h zero a) ih

theorem dEq_self (d : Dim) : dEq d d = M.pure true := by
  cases d <;> simp only [dEq, decide_true]
  rfl

theorem broadcast_same (s : List Dim) : broadcast s s = M.pure (some s) := by
  have go : ∀ s : List Dim, broadcast.go s s = M.pure (some s.reverse) := by
    intro s
    induction s with
    | nil => rfl
    | cons d ds ih =>
      simp only [broadcast.go, dEq_self]
      change ((broadcast.go ds ds).bind (fun r => M.pure (r.map (· ++ [d])))) = M.pure (some (d::ds).reverse)
      rw [ih]
      simp only [List.reverse_cons]
      rfl
  unfold broadcast
  rw [go, List.reverse_reverse]
  rfl

theorem broadcast_scalar (s : List Dim) : broadcast s [] = M.pure (some s) := by
  have go : ∀ s : List Dim, broadcast.go s [] = M.pure (some s.reverse) := by
    intro s; cases s <;> rfl
  unfold broadcast
  rw [List.reverse_nil, go, List.reverse_reverse]
  rfl

theorem binary_same {NR : NumV → NumV → Prop} (op : List Char) (s s' : List Dim) (da db : Nat)
    (h : Parametric.ShapeR NR s s') :
    infer (.binary op) [(s,da),(s,db)] = M.pure (some (.node s (binaryDtype op da db))) ∧
      infer (.binary op) [(s',da),(s',db)] = M.pure (some (.node s' (binaryDtype op da db))) ∧
      OutR NR (.node s (binaryDtype op da db)) (.node s' (binaryDtype op da db)) := by
  refine ⟨?_, ?_, .node _ h⟩ <;> simp only [infer, broadcast_same] <;> rfl

theorem binary_scalar {NR : NumV → NumV → Prop} (op : List Char) (s s' : List Dim) (da db : Nat)
    (h : Parametric.ShapeR NR s s') :
    infer (.binary op) [(s,da),([],db)] = M.pure (some (.node s (binaryDtype op da db))) ∧
      infer (.binary op) [(s',da),([],db)] = M.pure (some (.node s' (binaryDtype op da db))) ∧
      OutR NR (.node s (binaryDtype op da db)) (.node s' (binaryDtype op da db)) := by
  refine ⟨?_, ?_, .node _ h⟩ <;> simp only [infer, broadcast_scalar] <;> rfl

theorem unary {NR : NumV → NumV → Prop} (op : List Char) (s s' : List Dim) (dt : Nat)
    (h : Parametric.ShapeR NR s s') :
    infer (.unary op) [(s,dt)] = M.pure (some (.node s (unaryDtype op dt))) ∧
      infer (.unary op) [(s',dt)] = M.pure (some (.node s' (unaryDtype op dt))) ∧
      OutR NR (.node s (unaryDtype op dt)) (.node s' (unaryDtype op dt)) :=
  ⟨rfl, rfl, .node _ h⟩

theorem astype {NR : NumV → NumV → Prop} (s s' : List Dim) (dt old old' : Nat)
    (h : Parametric.ShapeR NR s s') :
    infer (.astype dt) [(s,old)] = M.pure (some (.node s dt)) ∧
      infer (.astype dt) [(s',old')] = M.pure (some (.node s' dt)) ∧
      OutR NR (.node s dt) (.node s' dt) := ⟨rfl, rfl, .node _ h⟩

theorem contiguous {NR : NumV → NumV → Prop} (s s' : List Dim) (dt : Nat)
    (h : Parametric.ShapeR NR s s') :
    infer .contiguous [(s,dt)] = M.pure (some (.node s dt)) ∧
      infer .contiguous [(s',dt)] = M.pure (some (.node s' dt)) ∧
      OutR NR (.node s dt) (.node s' dt) := ⟨rfl, rfl, .node _ h⟩

theorem transpose {NR : NumV → NumV → Prop} (axes : List Nat) (s s' : List Dim) (dt : Nat)
    (h : Parametric.ShapeR NR s s') (zero : NR (Dim.lit 0).num (Dim.lit 0).num)
    (guard : (Nat.beq (len axes) (len s) &&
      (List.range (len s)).all (fun a => axes.any (Nat.beq a))) = true) :
    infer (.transpose axes) [(s,dt)] = M.pure (some (.node (axes.map (nthD (.lit 0) s)) dt)) ∧
      infer (.transpose axes) [(s',dt)] = M.pure (some (.node (axes.map (nthD (.lit 0) s')) dt)) ∧
      OutR NR (.node (axes.map (nthD (.lit 0) s)) dt) (.node (axes.map (nthD (.lit 0) s')) dt) := by
  refine ⟨?_, ?_, .node _ (select_axes_roles h zero axes)⟩
  · simp only [infer, guard]; rfl
  · have guard' := guard
    rw [h.len_eq] at guard'
    simp only [infer, guard']; rfl

theorem take_axis {NR : NumV → NumV → Prop} (axis : Nat) (s s' ids ids' : List Dim) (dt di : Nat)
    (h : Parametric.ShapeR NR s s') (hi : Parametric.ShapeR NR ids ids')
    (guard : (Nat.blt axis (len s) && isInteger di) = true) :
    infer (.take axis) [(s,dt),(ids,di)] =
        M.pure (some (.node (s.take axis ++ ids ++ s.drop (axis+1)) dt)) ∧
      infer (.take axis) [(s',dt),(ids',di)] =
        M.pure (some (.node (s'.take axis ++ ids' ++ s'.drop (axis+1)) dt)) ∧
      OutR NR (.node (s.take axis ++ ids ++ s.drop (axis+1)) dt)
        (.node (s'.take axis ++ ids' ++ s'.drop (axis+1)) dt) := by
  refine ⟨?_, ?_, .node _ (((h.take axis).append hi).append (h.drop (axis+1)))⟩
  · simp only [infer, guard]; rfl
  · have guard' := guard
    rw [h.len_eq] at guard'
    simp only [infer, guard']; rfl

theorem sdpa {NR : NumV → NumV → Prop} (scale scale' : NumV) (mask : List Char)
    (q q' k k' v v' : List Dim) (dq dk dv : Nat)
    (hq : Parametric.ShapeR NR q q') (hk : Parametric.ShapeR NR k k') (hv : Parametric.ShapeR NR v v')
    (zero : NR (Dim.lit 0).num (Dim.lit 0).num)
    (guard : (Nat.beq (len q) 4 && Nat.beq (len k) 4 && Nat.beq (len v) 4) = true) :
    infer (.sdpa scale mask) [(q,dq),(k,dk),(v,dv)] =
        M.pure (some (.node (setAt q 3 (nthD (.lit 0) v 3)) (promote dq (promote dk dv)))) ∧
      infer (.sdpa scale' mask) [(q',dq),(k',dk),(v',dv)] =
        M.pure (some (.node (setAt q' 3 (nthD (.lit 0) v' 3)) (promote dq (promote dk dv)))) ∧
      OutR NR (.node (setAt q 3 (nthD (.lit 0) v 3)) (promote dq (promote dk dv)))
        (.node (setAt q' 3 (nthD (.lit 0) v' 3)) (promote dq (promote dk dv))) := by
  refine ⟨?_, ?_, .node _ (setAt_roles hq (nthD_roles hv zero 3) 3)⟩
  · simp only [infer, guard]; rfl
  · have guard' := guard
    rw [hq.len_eq, hk.len_eq, hv.len_eq] at guard'
    simp only [infer, guard']; rfl

theorem rope {NR : NumV → NumV → Prop} (dims : Nat) (traditional : Bool) (base base' : Arg)
    (scale scale' offset offset' : NumV) (s s' : List Dim) (dt : Nat)
    (h : Parametric.ShapeR NR s s') (guard : Nat.ble 3 (len s) = true) :
    infer (.rope dims traditional base scale offset) [(s,dt)] = M.pure (some (.node s dt)) ∧
      infer (.rope dims traditional base' scale' offset') [(s',dt)] = M.pure (some (.node s' dt)) ∧
      OutR NR (.node s dt) (.node s' dt) := by
  refine ⟨?_, ?_, .node _ h⟩
  · simp only [infer, guard]; rfl
  · have guard' := guard
    rw [h.len_eq] at guard'
    simp only [infer, guard']; rfl

theorem rmsNorm_unweighted {NR : NumV → NumV → Prop} (eps eps' : NumV)
    (s s' : List Dim) (dt : Nat) (h : Parametric.ShapeR NR s s') (guard : isFloat dt = true) :
    infer (.rmsNorm eps) [(s,dt)] = M.pure (some (.node s dt)) ∧
      infer (.rmsNorm eps') [(s',dt)] = M.pure (some (.node s' dt)) ∧
      OutR NR (.node s dt) (.node s' dt) := by
  refine ⟨?_, ?_, .node _ h⟩ <;> simp only [infer, guard] <;> rfl

theorem rmsNorm_weighted {NR : NumV → NumV → Prop} (eps eps' : NumV)
    (s s' : List Dim) (n n' : Dim) (dt dw : Nat) (h : Parametric.ShapeR NR s s')
    (equal : dEq n (nthD (.lit 0) s (len s-1)) = M.pure true)
    (equal' : dEq n' (nthD (.lit 0) s' (len s'-1)) = M.pure true)
    (guard : isFloat (promote dt dw) = true) :
    infer (.rmsNorm eps) [(s,dt),([n],dw)] = M.pure (some (.node s (promote dt dw))) ∧
      infer (.rmsNorm eps') [(s',dt),([n'],dw)] = M.pure (some (.node s' (promote dt dw))) ∧
      OutR NR (.node s (promote dt dw)) (.node s' (promote dt dw)) := by
  refine ⟨?_, ?_, .node _ h⟩
  · simp only [infer, equal]
    change (bif true && isFloat (promote dt dw) then M.pure (some (Out.node s (promote dt dw))) else M.pure none) = _
    rw [guard]; rfl
  · simp only [infer, equal']
    change (bif true && isFloat (promote dt dw) then M.pure (some (Out.node s' (promote dt dw))) else M.pure none) = _
    rw [guard]; rfl

theorem sliceDynamic {NR : NumV → NumV → Prop} (axes : List Nat)
    (sizes sizes' s s' start start' : List Dim) (dt ds : Nat)
    (hsize : Parametric.ShapeR NR sizes sizes') (hs : Parametric.ShapeR NR s s')
    (hst : Parametric.ShapeR NR start start')
    (guard : (Nat.beq (len sizes) (len s) && isInteger ds && Nat.ble (len start) 1 &&
      axes.all (Nat.blt · (len s))) = true) :
    infer (.sliceDynamic axes sizes) [(s,dt),(start,ds)] = M.pure (some (.node sizes dt)) ∧
      infer (.sliceDynamic axes sizes') [(s',dt),(start',ds)] = M.pure (some (.node sizes' dt)) ∧
      OutR NR (.node sizes dt) (.node sizes' dt) := by
  refine ⟨?_, ?_, .node _ hsize⟩
  · simp only [infer, guard]; rfl
  · have guard' := guard
    rw [hsize.len_eq, hs.len_eq, hst.len_eq] at guard'
    simp only [infer, guard']; rfl

theorem conv1d {NR : NumV → NumV → Prop} (stride pad dil groups : Nat)
    (batch batch' out out' : Dim) (l k c ci : Int) (dt dw : Nat)
    (hbatch : NR batch.num batch'.num) (hout : NR out.num out'.num)
    (hlength : NR (Dim.lit ((l + 2*pad - dil*(k-1) - 1) / stride + 1)).num
      (Dim.lit ((l + 2*pad - dil*(k-1) - 1) / stride + 1)).num)
    (guard : decide (0 < stride ∧ 0 < groups ∧ c = ci*groups) = true) :
    infer (.conv1d stride pad dil groups)
        [([batch,.lit l,.lit c],dt),([out,.lit k,.lit ci],dw)] =
      M.pure (some (.node [batch,.lit ((l + 2*pad - dil*(k-1) - 1) / stride + 1),out] (promote dt dw))) ∧
      infer (.conv1d stride pad dil groups)
        [([batch',.lit l,.lit c],dt),([out',.lit k,.lit ci],dw)] =
      M.pure (some (.node [batch',.lit ((l + 2*pad - dil*(k-1) - 1) / stride + 1),out'] (promote dt dw))) ∧
      OutR NR (.node [batch,.lit ((l + 2*pad - dil*(k-1) - 1) / stride + 1),out] (promote dt dw))
        (.node [batch',.lit ((l + 2*pad - dil*(k-1) - 1) / stride + 1),out'] (promote dt dw)) := by
  refine ⟨?_, ?_, .node _ (.cons hbatch (.cons hlength (.cons hout .nil)))⟩ <;>
    simp only [infer, guard] <;> rfl

end Host.Mlx.Ffi.InferenceRoles
