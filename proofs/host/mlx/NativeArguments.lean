import host.mlx.DimRoles
import host.ts.RenameAnnotations

set_option Elab.async false
set_option maxRecDepth 1000000

namespace Host.Mlx.Ffi.NativeRoles.Arguments
open Host.Ts Host.Ts.Owned

/-- Native integer decoding requires a literal representation. The stronger
occurrence annotation supplies that fact independently of numeric denotation. -/
theorem literal_argInt {ν : Nat → F64} {C : CSrv} {R : Ren} {e : SymE} {n : NumV}
    (h : Annotated.Value.Holds ν C R (.literal e) (.num n)) :
    argInt (.num n) = F64.toInt? (e.eval ν) := by
  cases h with
  | literal e x hd =>
    have he : x = e.eval ν := Option.some.inj hd
    exact congrArg F64.toInt? he

/-- Rounded Number(bigint) roles alone do not establish this equality. The
exact-integer annotation additionally records successful integer recovery. -/
theorem exact_argInt {ν : Nat → F64} {C : CSrv} {R : Ren} {e : SymE} {i : Int}
    (h : Annotated.Value.Holds ν C R (.exactInteger e) (.big i)) :
    argInt (.big i) = F64.toInt? (e.eval ν) := by
  cases h with
  | exactInteger e i hd hi => exact hi.symm

theorem literal_argNat {ν : Nat → F64} {C : CSrv} {R : Ren} {e : SymE} {n : NumV} (i : Int)
    (h : Annotated.Value.Holds ν C R (.literal e) (.num n))
    (hi : F64.toInt? (e.eval ν) = some i) (nonnegative : 0 ≤ i) :
    argNat (.num n) = some i.toNat := by
  unfold argNat
  rw [literal_argInt h,hi]
  simp only [Option.bind_some,nonnegative,decide_true]
  rfl

theorem exact_argNat {ν : Nat → F64} {C : CSrv} {R : Ren} {e : SymE} {i : Int}
    (j : Int) (h : Annotated.Value.Holds ν C R (.exactInteger e) (.big i))
    (hj : F64.toInt? (e.eval ν) = some j) (nonnegative : 0 ≤ j) :
    argNat (.big i) = some j.toNat := by
  unfold argNat
  rw [exact_argInt h,hj]
  simp only [Option.bind_some,nonnegative,decide_true]
  rfl

theorem handle_argNat {ν : Nat → F64} {C : CSrv} {R : Ren} {a : Nat} {i : Int}
    (h : Annotated.Value.Holds ν C R (.handle a) (.big i)) :
    argNat (.big i) = some (R.handle a) := by
  cases h with
  | handle a => exact argNat_big_nat _

/-- Literal dimensions decode through the actual `dimOf` conversion, with
the same explicit binary64 exactness bound used by native shape arithmetic. -/
theorem literal_dimOf_natural {ν : Nat → F64} {C : CSrv} {R : Ren} {e : SymE} {n : NumV}
    (value : Nat) (h : Annotated.Value.Holds ν C R (.literal e) (.num n))
    (hv : e.eval ν = F64.ofNat value) (bound : value < 2^53) :
    dimOf n = .lit (Int.ofNat value) := by
  cases h with
  | literal e x hd =>
    have he : x = F64.ofNat value := (Option.some.inj hd).trans hv
    rw [he]
    exact DimRoles.dimOf_natural53 value bound

theorem decode_i32_literal (F : Ffi) (s : Host.Ts.St F.S) (x : F64) :
    decodeArg F s chars!"i32" (.num (.lit x)) = M.pure (some (.num (.lit (F64.un .int32 x)))) := by
  have hp : (nameEq chars!"i32" chars!"ptr" || nameEq chars!"i32" chars!"pointer" ||
    nameEq chars!"i32" chars!"buffer" || nameEq chars!"i32" chars!"cstring") = false := by decide +kernel
  have hi : (nameEq chars!"i32" chars!"u64" || nameEq chars!"i32" chars!"i64" ||
    nameEq chars!"i32" chars!"usize") = false := by decide +kernel
  have hf : (nameEq chars!"i32" chars!"f32" || nameEq chars!"i32" chars!"float") = false := by decide +kernel
  have hd : (nameEq chars!"i32" chars!"f64" || nameEq chars!"i32" chars!"double") = false := by decide +kernel
  have hb : nameEq chars!"i32" chars!"bool" = false := by decide +kernel
  simp only [decodeArg,hp,hi,hf,hd,hb]
  rfl

theorem decode_f32_literal (F : Ffi) (s : Host.Ts.St F.S) (x : F64) :
    decodeArg F s chars!"f32" (.num (.lit x)) = M.pure (some (.num (.lit (F64.un .f32 x)))) := by
  have hp : (nameEq chars!"f32" chars!"ptr" || nameEq chars!"f32" chars!"pointer" ||
    nameEq chars!"f32" chars!"buffer" || nameEq chars!"f32" chars!"cstring") = false := by decide +kernel
  have hi : (nameEq chars!"f32" chars!"u64" || nameEq chars!"f32" chars!"i64" ||
    nameEq chars!"f32" chars!"usize") = false := by decide +kernel
  have hf : (nameEq chars!"f32" chars!"f32" || nameEq chars!"f32" chars!"float") = true := by decide +kernel
  simp only [decodeArg,hp,hi,hf]
  rfl

theorem decode_f64_literal (F : Ffi) (s : Host.Ts.St F.S) (x : F64) :
    decodeArg F s chars!"f64" (.num (.lit x)) = M.pure (some (.num (.lit x))) := by
  have hp : (nameEq chars!"f64" chars!"ptr" || nameEq chars!"f64" chars!"pointer" ||
    nameEq chars!"f64" chars!"buffer" || nameEq chars!"f64" chars!"cstring") = false := by decide +kernel
  have hi : (nameEq chars!"f64" chars!"u64" || nameEq chars!"f64" chars!"i64" ||
    nameEq chars!"f64" chars!"usize") = false := by decide +kernel
  have hf : (nameEq chars!"f64" chars!"f32" || nameEq chars!"f64" chars!"float") = false := by decide +kernel
  have hd : (nameEq chars!"f64" chars!"f64" || nameEq chars!"f64" chars!"double") = true := by decide +kernel
  simp only [decodeArg,hp,hi,hf,hd]
  rfl

theorem decode_u64_big (F : Ffi) (s : Host.Ts.St F.S) (i : Int) :
    decodeArg F s chars!"u64" (.big i) = M.pure (some (.big i)) := by
  have hp : (nameEq chars!"u64" chars!"ptr" || nameEq chars!"u64" chars!"pointer" ||
    nameEq chars!"u64" chars!"buffer" || nameEq chars!"u64" chars!"cstring") = false := by decide +kernel
  have hi : (nameEq chars!"u64" chars!"u64" || nameEq chars!"u64" chars!"i64" ||
    nameEq chars!"u64" chars!"usize") = true := by decide +kernel
  simp only [decodeArg,hp,hi]
  rfl

/-- The real Bun integer decoder folds a literal and retains a literal
annotation with the common int32 expression. It cannot silently become a
number reference at the native integer boundary. -/
theorem literal_decode_i32 (F : Ffi) (s : Host.Ts.St F.S)
    {ν : Nat → F64} {C : CSrv} {R : Ren} {e : SymE} {n : NumV}
    (h : Annotated.Value.Holds ν C R (.literal e) (.num n)) :
    ∃ x, decodeArg F s chars!"i32" (.num n) = M.pure (some (.num (.lit x))) ∧
      Annotated.Value.Holds ν C R (.literal (.un .int32 e)) (.num (.lit x)) := by
  cases h with
  | literal e x hd =>
    have hx : x = e.eval ν := Option.some.inj hd
    refine ⟨F64.un .int32 x,decode_i32_literal F s x,.literal _ _ ?_⟩
    change some (F64.un .int32 x) = some (F64.un .int32 (e.eval ν))
    rw [hx]

theorem literal_decode_f32 (F : Ffi) (s : Host.Ts.St F.S)
    {ν : Nat → F64} {C : CSrv} {R : Ren} {e : SymE} {n : NumV}
    (h : Annotated.Value.Holds ν C R (.literal e) (.num n)) :
    ∃ x, decodeArg F s chars!"f32" (.num n) = M.pure (some (.num (.lit x))) ∧
      Annotated.Value.Holds ν C R (.literal (.un .f32 e)) (.num (.lit x)) := by
  cases h with
  | literal e x hd =>
    have hx : x = e.eval ν := Option.some.inj hd
    refine ⟨F64.un .f32 x,decode_f32_literal F s x,.literal _ _ ?_⟩
    change some (F64.un .f32 x) = some (F64.un .f32 (e.eval ν))
    rw [hx]

theorem optInt_packed (n : Nat) (bound : n < 2^32) :
    optIntArg (.big (Int.ofNat (packedOptInt n))) = some (some n) := by
  unfold optIntArg
  rw [argNat_big_nat]
  simp only [Option.map_some]
  have flag : packedOptInt n / 2^32 % 2 = 1 := by rw [packedOptInt_eq n bound]; omega
  have payload : packedOptInt n % 2^32 = n := by rw [packedOptInt_eq n bound]; omega
  rw [flag,payload]
  rfl

/-- Exact integer annotations carry the real optional-int packing through
native decoding, with its presence bit and unsigned payload verified. -/
theorem exact_optInt_packed {ν : Nat → F64} {C : CSrv} {R : Ren} {e : SymE} {i : Int}
    (n : Nat) (h : Annotated.Value.Holds ν C R (.exactInteger e) (.big i))
    (meaning : e.eval ν = F64.ofNat (packedOptInt n)) (bound : n < 2^32) :
    optIntArg (.big i) = some (some n) := by
  have packedBound : packedOptInt n < 2^53 := by have := packedOptInt_bound n bound; omega
  have exact := exact_argInt h
  rw [meaning,F64.toInt_ofNat53 _ packedBound] at exact
  have hi : i = Int.ofNat (packedOptInt n) := Option.some.inj exact
  rw [hi]
  exact optInt_packed n bound

end Host.Mlx.Ffi.NativeRoles.Arguments
