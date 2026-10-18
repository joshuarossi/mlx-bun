import host.mlx.NativeAnnotationRebase
import host.mlx.OwnedMetadata

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- Fixed dimension representations which the original int32 buffer decoder
can recover. Literal dimensions may vary with the numeric valuation. -/
def Dimension.Decodable : Dimension → Prop
  | .literal _ | .symbolic (.reference _) => True
  | _ => False

theorem Dimension.Holds.dimOf_num {ν : Nat → F64} {C : CSrv} {role : Dimension} {d : Dim}
    (h : role.Holds ν C d) (hd : role.Decodable) : dimOf d.num = d := by
  cases h with
  | literal e i he hi =>
    have hx : F64.ofInt i = e.eval ν := Option.some.inj he
    simp only [Dim.num,dimOf,hx,hi]
  | symbolic hn =>
    cases hn with
    | any e n _ => cases hd
    | literal e x _ => cases hd
    | reference e i _ => rfl

abbrev Shape.Decodable (roles : Shape) := listSupport Dimension.Decodable roles

theorem Dimension.decodable_subst (role : Dimension) (θ : Nat → SymE) :
    (role.subst θ).Decodable ↔ role.Decodable := by
  cases role with
  | literal _ => rfl
  | symbolic n => cases n <;> rfl

theorem Shape.decodable_subst (roles : Shape) (θ : Nat → SymE) :
    (Shape.subst θ roles).Decodable ↔ roles.Decodable := by
  induction roles with
  | nil => rfl
  | cons r rs ih =>
    change ((r.subst θ).Decodable ∧ (Shape.subst θ rs).Decodable) ↔ _
    rw [Dimension.decodable_subst,ih]
    rfl

theorem Shape.Holds.dimOf_num {ν : Nat → F64} {C : CSrv} {roles : Shape} {shape : List Dim}
    (h : Shape.Holds ν C roles shape) (hd : roles.Decodable) : (shape.map Dim.num).map dimOf = shape := by
  induction h with
  | nil => rfl
  | cons hh ht ih => simp only [List.map_cons,hh.dimOf_num hd.1,ih hd.2]

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Arguments
open Host.Ts

/-- Tagged int32 cells decode through the original coherent-byte path. -/
theorem cellsI32_shapeBytes (shape : List Dim) :
    cellsI32 shape.length (shapeBytes shape) = some (shape.map Dim.num) := by
  induction shape with
  | nil => rfl
  | cons d ds ih =>
    have hread : readCell .i32 (shapeBytes (d :: ds)) = some (.num d.num) := rfl
    have hdrop : (shapeBytes (d :: ds)).drop 4 = shapeBytes ds := rfl
    simp only [List.length_cons,cellsI32,hread,hdrop,ih,Option.map_some,List.map_cons]

theorem dimsArg_shapeBytes {ν : Nat → F64} {C : CSrv} {roles : Annotated.Shape} {shape : List Dim}
    (h : Annotated.Shape.Holds ν C roles shape) (hd : roles.Decodable) (b off : Nat) :
    dimsArg (.jsPtr b off (shapeBytes shape)) (.big (Int.ofNat roles.length)) = some shape := by
  have hl : roles.length = shape.length := by
    clear hd
    induction h with
    | nil => rfl
    | cons _ _ ih => exact congrArg Nat.succ ih
  simp only [dimsArg,argNat_big_nat,hl]
  cases shape with
  | nil => rfl
  | cons d ds =>
    change (cellsI32 (d :: ds).length (shapeBytes (d :: ds))).map (List.map dimOf) = some (d :: ds)
    rw [cellsI32_shapeBytes]
    exact congrArg some (h.dimOf_num hd)

end Host.Mlx.Ffi.NativeRoles.Arguments

namespace Host.Mlx.Ffi.Annotated.ShapeBuffer
open Host.Ts Host.Ts.Owned

/-- A fixed buffer occurrence records its dimension annotations and tagged
int32 layout independently of FFI decoding or native execution. -/
def Holds (roles : Shape) (ν : Nat → F64) (C : CSrv) (bytes : List Byte) : Prop :=
  ∃ shape, Shape.Holds ν C roles shape ∧ bytes = shapeBytes shape

def bytesAt {S : Type} (s : Host.Ts.St S) (b : Nat) : List Byte :=
  match s.obj? b with
  | some o => match o.kind with | .buf bytes => bytes | _ => []
  | none => []

theorem Holds.of_dimensions {roles : Shape} {ν : Nat → F64} {C : CSrv} {shape : List Dim}
    (h : Shape.Holds ν C roles shape) : Holds roles ν C (shapeBytes shape) := ⟨shape,h,rfl⟩

theorem Holds.mono {roles : Shape} {ν : Nat → F64} {C D : CSrv} {bytes : List Byte}
    (h : Holds roles ν C bytes) (he : TableExtends C D) : Holds roles ν D bytes := by
  obtain ⟨shape,hs,hb⟩ := h
  exact ⟨shape,hs.mono he,hb⟩

theorem Holds.subst (roles : Shape) (θ : Nat → SymE) (ν : Nat → F64) (C : CSrv) (bytes : List Byte) :
    Holds (Shape.subst θ roles) ν C bytes ↔ Holds roles (Owned.Annotated.nextValuation θ ν) C bytes := by
  constructor
  · rintro ⟨shape,hs,hb⟩
    exact ⟨shape,(Shape.holds_subst θ roles shape).mp hs,hb⟩
  · rintro ⟨shape,hs,hb⟩
    exact ⟨shape,(Shape.holds_subst θ roles shape).mpr hs,hb⟩

/-- A literal Number cell becomes a literal dimension only with exact integer
recovery. This excludes a rounded bigint or fractional value shortcut. -/
theorem Holds.of_literal_cells {ν : Nat → F64} {C : CSrv} {roles : List SymE} {values : List F64}
    (h : ListR (fun e x => NumDenote ν C e (.lit x)) roles values)
    (exactInteger : listSupport (fun e => ∃ i, F64.ofInt i = e.eval ν ∧ F64.toInt? (e.eval ν) = some i) roles) :
    Holds (roles.map Dimension.literal) ν C (cellBytes .i32 (values.map fun x => .num (.lit x))) := by
  induction h with
  | nil => exact ⟨[],.nil,rfl⟩
  | cons hh ht ih =>
    obtain ⟨i,hi,hr⟩ := exactInteger.1
    obtain ⟨shape,hs,hb⟩ := ih exactInteger.2
    refine ⟨.lit i :: shape,.cons (.literal _ _ ?_ hr) hs,?_⟩
    · change some (F64.ofInt i) = some _
      rw [hi]
    · have hx := (Option.some.inj hh).trans hi.symm
      simp only [List.map_cons,cellBytes,shapeBytes,Dim.num,hx] at hb ⊢
      rw [hb]

theorem Holds.decode {roles : Shape} {ν : Nat → F64} {C : CSrv} {bytes : List Byte}
    (h : Holds roles ν C bytes) (hd : roles.Decodable) (b off : Nat) :
    ∃ shape, Shape.Holds ν C roles shape ∧
      dimsArg (.jsPtr b off bytes) (.big (Int.ofNat roles.length)) = some shape := by
  obtain ⟨shape,hs,rfl⟩ := h
  exact ⟨shape,hs,NativeRoles.Arguments.dimsArg_shapeBytes hs hd b off⟩

end Host.Mlx.Ffi.Annotated.ShapeBuffer
