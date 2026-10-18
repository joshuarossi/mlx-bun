import host.mlx.NativeArguments
import host.ts.RenameParametricNumbers
import host.mlx.NativeAnnotationRebase

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles.Arguments
open Host.Ts Host.Ts.Owned

/-- Numeric ABI types exercised by the ordinary configuration setters. The
u32 branch follows the original interpreter's int32 conversion. -/
inductive NumericDecoder where
  | i32 | u32 | f32 | f64

def NumericDecoder.name : NumericDecoder → Name
  | .i32 => chars!"i32" | .u32 => chars!"u32" | .f32 => chars!"f32" | .f64 => chars!"f64"

def NumericDecoder.action : NumericDecoder → NumV → M NumV
  | .i32 | .u32 => numUn .int32
  | .f32 => numUn .f32
  | .f64 => M.pure

def NumericDecoder.meaning : NumericDecoder → SymE → SymE
  | .i32 | .u32 => .un .int32
  | .f32 => .un .f32
  | .f64 => id

theorem NumericDecoder.decode (kind : NumericDecoder) (F : Host.Ts.Ffi) (s : Host.Ts.St F.S) (a : NumV) :
    decodeArg F s kind.name (.num a) = (kind.action a).bind (fun v => M.pure (some (.num v))) := by
  have hp : (nameEq kind.name chars!"ptr" || nameEq kind.name chars!"pointer" ||
      nameEq kind.name chars!"buffer" || nameEq kind.name chars!"cstring") = false := by
    cases kind <;> decide +kernel
  have hi : (nameEq kind.name chars!"u64" || nameEq kind.name chars!"i64" || nameEq kind.name chars!"usize") = false := by
    cases kind <;> decide +kernel
  cases kind with
  | i32 =>
    simp only [NumericDecoder.name] at hp hi
    have hf : (nameEq chars!"i32" chars!"f32" || nameEq chars!"i32" chars!"float") = false := by decide +kernel
    have hd : (nameEq chars!"i32" chars!"f64" || nameEq chars!"i32" chars!"double") = false := by decide +kernel
    have hb : nameEq chars!"i32" chars!"bool" = false := by decide +kernel
    simp only [decodeArg,hp,hi,NumericDecoder.name,hf,hd,hb,NumericDecoder.action,Bool.cond_false]
  | u32 =>
    simp only [NumericDecoder.name] at hp hi
    have hf : (nameEq chars!"u32" chars!"f32" || nameEq chars!"u32" chars!"float") = false := by decide +kernel
    have hd : (nameEq chars!"u32" chars!"f64" || nameEq chars!"u32" chars!"double") = false := by decide +kernel
    have hb : nameEq chars!"u32" chars!"bool" = false := by decide +kernel
    simp only [decodeArg,hp,hi,NumericDecoder.name,hf,hd,hb,NumericDecoder.action,Bool.cond_false]
  | f32 =>
    simp only [NumericDecoder.name] at hp hi
    have hf : (nameEq chars!"f32" chars!"f32" || nameEq chars!"f32" chars!"float") = true := by decide +kernel
    simp only [decodeArg,hp,hi,NumericDecoder.name,hf,NumericDecoder.action,Bool.cond_false,Bool.cond_true]
  | f64 =>
    simp only [NumericDecoder.name] at hp hi
    have hf : (nameEq chars!"f64" chars!"f32" || nameEq chars!"f64" chars!"float") = false := by decide +kernel
    have hd : (nameEq chars!"f64" chars!"f64" || nameEq chars!"f64" chars!"double") = true := by decide +kernel
    simp only [decodeArg,hp,hi,NumericDecoder.name,hf,hd,NumericDecoder.action,Bool.cond_false,Bool.cond_true]
    rfl

theorem numUn_bind (C : CSrv) (op : NUn) (a : NumV) {α : Type} (next : NumV → M α) :
    interpC ((numUn op a).bind next).run C =
      (interpC (numUn op a).run C).bind (fun (v,D) => interpC (next v).run D) := by
  cases a with
  | lit x => rfl
  | ref i =>
    cases hv : C.val (.ref i) <;>
      simp only [numUn,M.bind,M.run,M.un,M.pure,interpC_un,hv,interpC_pure,Option.bind_none,Option.bind_some]

theorem NumericDecoder.bind_run (kind : NumericDecoder) (C : CSrv) (a : NumV) {α : Type} (next : NumV → M α) :
    interpC ((kind.action a).bind next).run C =
      (interpC (kind.action a).run C).bind (fun (v,D) => interpC (next v).run D) := by
  cases kind with
  | i32 | u32 => exact numUn_bind C .int32 a next
  | f32 => exact numUn_bind C .f32 a next
  | f64 => rfl

/-- Both original decoders run with independent numeric-table extensions.
Their results retain the fixed converted expression. -/
theorem NumericDecoder.roles (kind : NumericDecoder) {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {e : SymE} {a₀ a : NumV} (h : NumRole ν₀ ν C₀ C e a₀ a) :
    ∃ v₀ D₀ v D, interpC (kind.action a₀).run C₀ = some (v₀,D₀) ∧
      interpC (kind.action a).run C = some (v,D) ∧
      NumRole ν₀ ν D₀ D (kind.meaning e) v₀ v ∧ TableExtends C₀ D₀ ∧ TableExtends C D := by
  cases kind with
  | i32 | u32 => exact h.numUn .int32
  | f32 => exact h.numUn .f32
  | f64 => exact ⟨a₀,C₀,a,C,rfl,rfl,h,.refl C₀,.refl C⟩

theorem NumericDecoder.decode_roles (kind : NumericDecoder) (F₀ F : Host.Ts.Ffi)
    (s₀ : Host.Ts.St F₀.S) (s : Host.Ts.St F.S) {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {e : SymE} {a₀ a : NumV} (h : NumRole ν₀ ν C₀ C e a₀ a) :
    ∃ v₀ D₀ v D,
      interpC (decodeArg F₀ s₀ kind.name (.num a₀)).run C₀ = some (some (.num v₀),D₀) ∧
      interpC (decodeArg F s kind.name (.num a)).run C = some (some (.num v),D) ∧
      NumRole ν₀ ν D₀ D (kind.meaning e) v₀ v ∧ TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨v₀,D₀,v,D,hs,ht,hr,he₀,he⟩ := kind.roles h
  refine ⟨v₀,D₀,v,D,?_,?_,hr,he₀,he⟩
  · rw [kind.decode,kind.bind_run,hs]; rfl
  · rw [kind.decode,kind.bind_run,ht]; rfl

theorem NumericDecoder.triple_roles (kind : NumericDecoder) {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {ex ey ez : SymE} {a₀ b₀ c₀ a b c : NumV}
    (ha : NumRole ν₀ ν C₀ C ex a₀ a) (hb : NumRole ν₀ ν C₀ C ey b₀ b) (hc : NumRole ν₀ ν C₀ C ez c₀ c) :
    ∃ x₀ A₀ x A y₀ B₀ y B z₀ D₀ z D,
      interpC (kind.action a₀).run C₀ = some (x₀,A₀) ∧ interpC (kind.action a).run C = some (x,A) ∧
      interpC (kind.action b₀).run A₀ = some (y₀,B₀) ∧ interpC (kind.action b).run A = some (y,B) ∧
      interpC (kind.action c₀).run B₀ = some (z₀,D₀) ∧ interpC (kind.action c).run B = some (z,D) ∧
      NumRole ν₀ ν D₀ D (kind.meaning ex) x₀ x ∧ NumRole ν₀ ν D₀ D (kind.meaning ey) y₀ y ∧
      NumRole ν₀ ν D₀ D (kind.meaning ez) z₀ z ∧ TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨x₀,A₀,x,A,hx₀,hx,rx,ea₀,ea⟩ := kind.roles ha
  obtain ⟨y₀,B₀,y,B,hy₀,hy,ry,eb₀,eb⟩ := kind.roles (hb.mono ea₀ ea)
  obtain ⟨z₀,D₀,z,D,hz₀,hz,rz,ec₀,ec⟩ := kind.roles (hc.mono (ea₀.trans eb₀) (ea.trans eb))
  exact ⟨x₀,A₀,x,A,y₀,B₀,y,B,z₀,D₀,z,D,hx₀,hx,hy₀,hy,hz₀,hz,
    rx.mono (eb₀.trans ec₀) (eb.trans ec),ry.mono ec₀ ec,rz,(ea₀.trans eb₀).trans ec₀,(ea.trans eb).trans ec⟩

theorem NumericDecoder.triple_run (kind : NumericDecoder) {α : Type} (next : NumV → NumV → NumV → M α)
    (a b c x y z : NumV) (C A B D : CSrv)
    (hx : interpC (kind.action a).run C = some (x,A))
    (hy : interpC (kind.action b).run A = some (y,B))
    (hz : interpC (kind.action c).run B = some (z,D)) :
    interpC ((kind.action a).bind fun x => (kind.action b).bind fun y => (kind.action c).bind fun z => next x y z).run C =
      interpC (next x y z).run D := by
  rw [kind.bind_run,hx]
  simp only [Option.bind_some]
  rw [kind.bind_run,hy]
  simp only [Option.bind_some]
  rw [kind.bind_run,hz]
  rfl

theorem NumericDecoder.decode_triple (kind : NumericDecoder) (F : Host.Ts.Ffi) (s : Host.Ts.St F.S)
    (handle : Int) (a b c : NumV) :
    decodeArgs F s [.str chars!"u64",.str kind.name,.str kind.name,.str kind.name] [.big handle,.num a,.num b,.num c] =
      (kind.action a).bind fun x => (kind.action b).bind fun y => (kind.action c).bind fun z =>
        M.pure (some [.big handle,.num x,.num y,.num z]) := by
  funext β k
  simp only [decodeArgs,decode_u64_big,kind.decode,M.bind,M.pure,Option.map_some]

end Host.Mlx.Ffi.NativeRoles.Arguments

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles.Arguments

def Number.convert (op : NUn) : Number → Number
  | .any e => .any (.un op e)
  | .literal e => .literal (.un op e)
  | .reference e => .reference (.un op e)

/-- A cast retains the fixed occurrence's representation requirement as well
as its meaning. Literal and referenced inputs follow their original branches. -/
theorem Number.Holds.numUn {ν : Nat → F64} {C : CSrv} {r : Number} {a : NumV}
    (h : r.Holds ν C a) (op : NUn) :
    ∃ v D, interpC (Host.Ts.numUn op a).run C = some (v,D) ∧
      (r.convert op).Holds ν D v ∧ TableExtends C D := by
  cases h with
  | any e a hd =>
    obtain ⟨v,D,hr,hv,he⟩ := hd.numUn op
    exact ⟨v,D,hr,.any _ _ hv,he⟩
  | literal e x hd =>
    refine ⟨.lit (F64.un op x),C,rfl,.literal _ _ ?_,.refl C⟩
    change some (F64.un op x) = some (F64.un op (e.eval ν))
    rw [Option.some.inj hd]
  | reference e i hd =>
    refine ⟨.ref C.tab.length,⟨C.tab ++ [F64.un op (e.eval ν)]⟩,?_,.reference _ _ ?_,.append C _⟩
    · change interpC (.un op (.ref i) (fun j => .pure (NumV.ref j))) C = _
      rw [interpC_un,hd]
      rfl
    · exact nth?_append_length C.tab _

def Number.decoded (r : Number) : NumericDecoder → Number
  | .i32 | .u32 => r.convert .int32
  | .f32 => r.convert .f32
  | .f64 => r

theorem Number.Holds.decode {ν : Nat → F64} {C : CSrv} {r : Number} {a : NumV}
    (h : r.Holds ν C a) (kind : NumericDecoder) :
    ∃ v D, interpC (kind.action a).run C = some (v,D) ∧ (r.decoded kind).Holds ν D v ∧ TableExtends C D := by
  cases kind with
  | i32 | u32 => exact h.numUn .int32
  | f32 => exact h.numUn .f32
  | f64 => exact ⟨a,C,rfl,h,.refl C⟩

/-- Fixed numeric occurrences in host arguments retain their native
representation requirement. -/
def Number.ValueHolds (r : Number) (ν : Nat → F64) (C : CSrv) (v : Val) : Prop :=
  ∃ n, v = .num n ∧ r.Holds ν C n

theorem Number.Holds.value {ν : Nat → F64} {C : CSrv} {r : Number} {n : NumV}
    (h : r.Holds ν C n) : r.ValueHolds ν C (.num n) := ⟨n,rfl,h⟩

/-- Sequential casts keep each fixed occurrence under the final table, even
when later casts append fresh numeric references. -/
theorem Number.Holds.triple_decode (kind : NumericDecoder) {ν : Nat → F64} {C : CSrv}
    {rx ry rz : Number} {a b c : NumV}
    (ha : rx.Holds ν C a) (hb : ry.Holds ν C b) (hc : rz.Holds ν C c) :
    ∃ x A y B z D,
      interpC (kind.action a).run C = some (x,A) ∧
      interpC (kind.action b).run A = some (y,B) ∧
      interpC (kind.action c).run B = some (z,D) ∧
      (rx.decoded kind).Holds ν D x ∧ (ry.decoded kind).Holds ν D y ∧
      (rz.decoded kind).Holds ν D z ∧ TableExtends C D := by
  obtain ⟨x,A,hx,rx',ea⟩ := ha.decode kind
  obtain ⟨y,B,hy,ry',eb⟩ := (hb.mono ea).decode kind
  obtain ⟨z,D,hz,rz',ec⟩ := (hc.mono (ea.trans eb)).decode kind
  exact ⟨x,A,y,B,z,D,hx,hy,hz,rx'.mono (eb.trans ec),ry'.mono ec,rz',(ea.trans eb).trans ec⟩

end Host.Mlx.Ffi.Annotated
