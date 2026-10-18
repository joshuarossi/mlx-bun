import host.mlx.InferenceRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.InferenceRoles
open Host.Ts Host.Ts.Owned

theorem broadcast_suffix (shape leading : List Dim) :
    broadcast shape (leading ++ shape) = M.pure (some (leading ++ shape)) := by
  have go : ∀ shape leading : List Dim,
      broadcast.go shape (shape ++ leading) = M.pure (some ((shape ++ leading).reverse)) := by
    intro shape
    induction shape with
    | nil => intro leading; rfl
    | cons d ds ih =>
      intro leading
      simp only [List.cons_append,broadcast.go,dEq_self]
      change (broadcast.go ds (ds ++ leading)).bind
        (fun r => M.pure (r.map (· ++ [d]))) = _
      rw [ih]
      simp only [List.reverse_cons]
      rfl
  unfold broadcast
  rw [List.reverse_append,go]
  simp only [List.reverse_append,List.reverse_reverse]
  rfl

theorem binary_suffix {NR : NumV → NumV → Prop} (op : List Char)
    (shape shape' leading leading' : List Dim) (da db : Nat)
    (hs : Parametric.ShapeR NR shape shape') (hp : Parametric.ShapeR NR leading leading') :
    infer (.binary op) [(shape,da),(leading++shape,db)] =
        M.pure (some (.node (leading++shape) (binaryDtype op da db))) ∧
      infer (.binary op) [(shape',da),(leading'++shape',db)] =
        M.pure (some (.node (leading'++shape') (binaryDtype op da db))) ∧
      OutR NR (.node (leading++shape) (binaryDtype op da db))
        (.node (leading'++shape') (binaryDtype op da db)) := by
  refine ⟨?_,?_,.node _ (hp.append hs)⟩ <;> simp only [infer,broadcast_suffix] <;> rfl

/-- The cached sampler's reduction preserves related dimensions. The only
new dimension is the exact kept-axis literal one. -/
theorem logsumexp_keep {NR : NumV → NumV → Prop} (shape shape' : List Dim) (dt axis : Nat)
    (hs : Parametric.ShapeR NR shape shape')
    (one : NR (Dim.lit 1).num (Dim.lit 1).num) (bound : Nat.blt axis (len shape) = true) :
    infer (.logsumexp axis true) [(shape,dt)] =
        M.pure (some (.node (setAt shape axis (.lit 1)) (atLeastFloat dt))) ∧
      infer (.logsumexp axis true) [(shape',dt)] =
        M.pure (some (.node (setAt shape' axis (.lit 1)) (atLeastFloat dt))) ∧
      OutR NR (.node (setAt shape axis (.lit 1)) (atLeastFloat dt))
        (.node (setAt shape' axis (.lit 1)) (atLeastFloat dt)) := by
  have bound' : Nat.blt axis (len shape') = true := by rw [← hs.len_eq]; exact bound
  refine ⟨?_,?_,.node _ (setAt_roles hs one axis)⟩ <;> simp only [infer,bound,bound'] <;> rfl

theorem logsumexp_drop {NR : NumV → NumV → Prop} (shape shape' : List Dim) (dt axis : Nat)
    (hs : Parametric.ShapeR NR shape shape') (bound : Nat.blt axis (len shape) = true) :
    infer (.logsumexp axis false) [(shape,dt)] =
        M.pure (some (.node (shape.take axis ++ shape.drop (axis+1)) (atLeastFloat dt))) ∧
      infer (.logsumexp axis false) [(shape',dt)] =
        M.pure (some (.node (shape'.take axis ++ shape'.drop (axis+1)) (atLeastFloat dt))) ∧
      OutR NR (.node (shape.take axis ++ shape.drop (axis+1)) (atLeastFloat dt))
        (.node (shape'.take axis ++ shape'.drop (axis+1)) (atLeastFloat dt)) := by
  have bound' : Nat.blt axis (len shape') = true := by rw [← hs.len_eq]; exact bound
  refine ⟨?_,?_,.node _ ((hs.take axis).append (hs.drop (axis+1)))⟩ <;>
    simp only [infer,bound,bound'] <;> rfl

theorem reshape_singleton_one (dt : Nat) :
    infer (.reshape [.lit 1]) [([.lit 1],dt)] = M.pure (some (.node [.lit 1] dt)) := by
  rfl

end Host.Mlx.Ffi.InferenceRoles
