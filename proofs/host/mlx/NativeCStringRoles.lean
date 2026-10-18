import host.mlx.NativeSymbol

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles.Arguments
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The original C-string parser only consumes literal bytes. Symbolic cell
parts remain unsupported on both sides of the live byte relation. -/
theorem cstrBytes_roles {NR : NumV → NumV → Prop} {R : Ren}
    (fuel : Nat) {source target : List Byte} (h : ListR (Parametric.ByteR NR R) source target) :
    cstrBytes fuel source = cstrBytes fuel target := by
  induction fuel generalizing source target with
  | zero => rfl
  | succ fuel ih =>
    cases h with
    | nil => rfl
    | cons hb hs =>
      cases hb with
      | lit b => simp only [cstrBytes,ih hs]
      | part k i hc => rfl

theorem cstrArg_roles {NR : NumV → NumV → Prop} {R : Ren}
    (b off : Nat) {source target : List Byte} (h : ListR (Parametric.ByteR NR R) source target) :
    cstrArg (.jsPtr b off source) = cstrArg (.jsPtr (R.a b) off target) := by
  have hl : source.length = target.length := by
    induction h with
    | nil => rfl
    | cons _ _ ih => exact congrArg Nat.succ ih
  simp only [cstrArg,← hl]
  exact cstrBytes_roles _ h

theorem decode_cstring_pointer (F : Host.Ts.Ffi) (s : Host.Ts.St F.S) (b off : Nat) (bs : List Byte)
    (hb : bufBytes F s b = some bs) :
    decodeArg F s chars!"cstring" (.ptr (.js b) off) = M.pure (some (.jsPtr b off (bs.drop off))) := by
  have hp : (nameEq chars!"cstring" chars!"ptr" || nameEq chars!"cstring" chars!"pointer" ||
    nameEq chars!"cstring" chars!"buffer" || nameEq chars!"cstring" chars!"cstring") = true := by decide +kernel
  simp only [decodeArg,hp,Bool.cond_true,hb,Option.map_some]

end Host.Mlx.Ffi.NativeRoles.Arguments
