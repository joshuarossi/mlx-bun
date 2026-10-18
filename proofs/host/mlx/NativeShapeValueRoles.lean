import host.mlx.NativeAnnotations

set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- Shape reads retain the numeric representation fixed at the native node.
A general or reference number never acquires a literal ABI role by reading it. -/
def Number.valueRole : Number → Owned.Annotated.Value
  | .any meaning => .num meaning
  | .literal meaning => .literal meaning
  | .reference meaning => .num meaning

theorem Number.Holds.valueRole {ν : Nat → F64} {C : CSrv} {r : Number} {n : NumV}
    (held : r.Holds ν C n) (R : Ren) : r.valueRole.Holds ν C R (.num n) := by
  cases held with
  | any e n meaning => exact .num e n meaning
  | literal e x meaning => exact .literal e x meaning
  | reference e i meaning => exact .num e (.ref i) meaning

def Dimension.valueRole : Dimension → Owned.Annotated.Value
  | .literal meaning => .literal meaning
  | .symbolic number => number.valueRole

theorem Dimension.Holds.valueRole {ν : Nat → F64} {C : CSrv} {r : Dimension} {dimension : Dim}
    (held : r.Holds ν C dimension) (R : Ren) : r.valueRole.Holds ν C R (.num dimension.num) := by
  cases held with
  | literal e i meaning exact => exact .literal e (F64.ofInt i) meaning
  | symbolic meaning => exact meaning.valueRole R

def Shape.valueRoles (roles : Shape) : List Owned.Annotated.Value := roles.map Dimension.valueRole

theorem Shape.Holds.valueRoles {ν : Nat → F64} {C : CSrv} {roles : Shape} {dimensions : List Dim}
    (held : Shape.Holds ν C roles dimensions) (R : Ren) :
    ListR (fun role value => role.Holds ν C R value) roles.valueRoles (dimensions.map (fun d => Val.num d.num)) := by
  induction held with
  | nil => exact .nil
  | cons head _ ih => exact .cons (head.valueRole R) ih

end Host.Mlx.Ffi.Annotated
