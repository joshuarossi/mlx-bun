import host.mlx.InferenceRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.InferenceRoles
open Host.Ts Host.Ts.Owned

theorem allEq_self (s : List Dim) : allEq s s = M.pure true := by
  induction s with
  | nil => rfl
  | cons d ds ih =>
    simp only [allEq, dEq_self]
    exact ih

/-- The quantized matrix multiplication used by the source has a two-axis
uint32 weight and matching scale/bias shapes. Its remaining dimension equality
and floating dtype check are explicit native guards. -/
theorem qmm_affine (tr : Bool) (group bits : Nat) (x scales : List Dim)
    (rows cols : Int) (dx ds db : Nat)
    (bitsNonzero : Nat.beq bits 0 = false)
    (inner : dEq (nthD (.lit 0) x (len x-1)) (.lit (bif tr then cols*32/bits else rows)) = M.pure true)
    (float : isFloat (promote dx (promote ds db)) = true) :
    infer (.qmm tr group bits chars!"affine")
      [(x,dx),([.lit rows,.lit cols],dtUint32),(scales,ds),(scales,db)] =
      M.pure (some (.node (setAt x (len x-1) (.lit (bif tr then rows else cols*32/bits)))
        (promote dx (promote ds db)))) := by
  have mode : nameEq chars!"affine" chars!"affine" = true := by decide +kernel
  have word : Nat.beq dtUint32 dtUint32 = true := rfl
  simp only [infer, mode, word, bitsNonzero]
  change ((dEq (nthD (.lit 0) x (len x-1)) (.lit (bif tr then cols*32/bits else rows))).bind
    (fun e => (allEq scales scales).bind (fun sb =>
      bif e && sb && Nat.ble 2 2 && isFloat (promote dx (promote ds db)) then
        M.pure (some (Out.node (setAt x (len x-1) (.lit (bif tr then rows else cols*32/bits)))
          (promote dx (promote ds db)))) else M.pure none))) = _
  rw [inner, allEq_self]
  change (bif isFloat (promote dx (promote ds db)) then
    M.pure (some (Out.node (setAt x (len x-1) (.lit (bif tr then rows else cols*32/bits)))
      (promote dx (promote ds db)))) else M.pure none) = _
  rw [float]
  rfl

theorem qmm_affine_roles {NR : NumV → NumV → Prop} (tr : Bool) (group bits : Nat)
    (x x' scales scales' : List Dim) (rows cols : Int) (dx ds db : Nat)
    (hx : Parametric.ShapeR NR x x')
    (outer : NR (Dim.lit (bif tr then rows else cols*32/bits)).num
      (Dim.lit (bif tr then rows else cols*32/bits)).num)
    (bitsNonzero : Nat.beq bits 0 = false)
    (inner : dEq (nthD (.lit 0) x (len x-1)) (.lit (bif tr then cols*32/bits else rows)) = M.pure true)
    (inner' : dEq (nthD (.lit 0) x' (len x'-1)) (.lit (bif tr then cols*32/bits else rows)) = M.pure true)
    (float : isFloat (promote dx (promote ds db)) = true) :
    infer (.qmm tr group bits chars!"affine")
        [(x,dx),([.lit rows,.lit cols],dtUint32),(scales,ds),(scales,db)] =
        M.pure (some (.node (setAt x (len x-1) (.lit (bif tr then rows else cols*32/bits)))
          (promote dx (promote ds db)))) ∧
      infer (.qmm tr group bits chars!"affine")
        [(x',dx),([.lit rows,.lit cols],dtUint32),(scales',ds),(scales',db)] =
        M.pure (some (.node (setAt x' (len x'-1) (.lit (bif tr then rows else cols*32/bits)))
          (promote dx (promote ds db)))) ∧
      OutR NR (.node (setAt x (len x-1) (.lit (bif tr then rows else cols*32/bits)))
        (promote dx (promote ds db)))
        (.node (setAt x' (len x'-1) (.lit (bif tr then rows else cols*32/bits)))
          (promote dx (promote ds db))) := by
  refine ⟨qmm_affine tr group bits x scales rows cols dx ds db bitsNonzero inner float,
    qmm_affine tr group bits x' scales' rows cols dx ds db bitsNonzero inner' float, .node _ ?_⟩
  rw [← hx.len_eq]
  exact setAt_roles hx outer (len x-1)

end Host.Mlx.Ffi.InferenceRoles
