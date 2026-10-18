import host.mlx.FixedNativeRoles
import host.mlx.NativeDecodeRoles

set_option Elab.async false
set_option maxRecDepth 1000000

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- A numeric ABI occurrence can vary while surrounding structural arguments
remain fixed. Its annotation retains its representation and fixed meaning. -/
inductive ArgumentPattern where
  | fixed (role : Owned.Annotated.FixedArgument)
  | numeric (role : Number)

def ArgumentPattern.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) : ArgumentPattern → Val → Prop
  | .fixed role,v => role.role.Holds ν C R v
  | .numeric role,v => role.ValueHolds ν C v

def ArgumentPattern.subst (θ : Nat → SymE) : ArgumentPattern → ArgumentPattern
  | .fixed r => .fixed r
  | .numeric r => .numeric (r.subst θ)

theorem ArgumentPattern.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (r : ArgumentPattern) (v : Val) :
    (r.subst θ).Holds ν C R v ↔ r.Holds (Owned.Annotated.nextValuation θ ν) C R v := by
  cases r with
  | fixed r =>
    have unchanged : r.role.subst θ = r.role := by cases r <;> rfl
    simpa only [ArgumentPattern.subst,ArgumentPattern.Holds,unchanged] using
      (Owned.Annotated.Value.holds_subst θ r.role v)
  | numeric r =>
    simp only [ArgumentPattern.subst,ArgumentPattern.Holds,Number.ValueHolds,Number.holds_subst]

theorem ArgumentPattern.Holds.mono {ν : Nat → F64} {C D : CSrv} {R : Ren}
    {r : ArgumentPattern} {v : Val} (h : r.Holds ν C R v) (ext : TableExtends C D) : r.Holds ν D R v := by
  cases r with
  | fixed r => exact Owned.Annotated.Value.Holds.mono ext h
  | numeric r => obtain ⟨n,eq,hr⟩ := h; exact ⟨n,eq,hr.mono ext⟩

theorem ArgumentPattern.fixed_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (roles : List Owned.Annotated.FixedArgument) {values : List Val}
    (h : ListR (ArgumentPattern.Holds ν C R) (roles.map .fixed) values) :
    values = roles.map (·.value R) := by
  induction roles generalizing values with
  | nil => cases h; rfl
  | cons role roles ih =>
    cases h with
    | cons hv ht => rw [Owned.Annotated.FixedArgument.exact hv,ih ht]; rfl

theorem ArgumentPattern.one_numeric_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (before after : List Owned.Annotated.FixedArgument) (role : Number) {values : List Val}
    (h : ListR (ArgumentPattern.Holds ν C R) (before.map .fixed ++ [.numeric role] ++ after.map .fixed) values) :
    ∃ n, values = before.map (·.value R) ++ [.num n] ++ after.map (·.value R) ∧ role.Holds ν C n := by
  induction before generalizing values with
  | nil =>
    cases h with
    | cons hn ht =>
      obtain ⟨n,eq,hr⟩ := hn
      cases eq
      exact ⟨n,by rw [fixed_exact after ht]; rfl,hr⟩
  | cons r rs ih =>
    cases h with
    | cons hv ht =>
      obtain ⟨n,eq,hr⟩ := ih ht
      exact ⟨n,by rw [Owned.Annotated.FixedArgument.exact hv,eq]; rfl,hr⟩

end Host.Mlx.Ffi.Annotated
