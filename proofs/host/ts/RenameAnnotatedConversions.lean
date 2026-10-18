import host.ts.RenameAnnotationResources
import host.ts.RenameParametricConversions
namespace Host.Ts.Owned.Annotated

/-- Literal role annotations justify the actual conversion, including the
accepted representation and the exact integer result. -/
theorem bigint_literal (F : Ffi) (s : St F.S) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (e : SymE) (v : Val) (hv : (Value.literal e).Holds ν C R v) (i : Int)
    (hi : F64.toInt? (e.eval ν) = some i) (hx : F64.ofInt i = e.eval ν)
    (fn : Nat) (receiver : Val) (o : Obj) (data : List Val)
    (hc : s.ctl = .call (.obj fn) receiver [v]) (ho : s.obj? fn = some o)
    (hk : o.kind = .fn (.native (.num .bigint) data)) :
    step F s = M.pure (s.ret (.big i)) ∧ (Value.exactInteger e).Holds ν C R (.big i) := by
  cases hv with
  | literal _ x h =>
    have he : x = e.eval ν := by exact Option.some.inj h
    refine ⟨Parametric.step_bigint_number_eq F s fn receiver x i o data hc ho hk ?_,.exactInteger e i ?_ hi⟩
    · rw [he]; exact hi
    · change some (F64.ofInt i) = some (e.eval ν)
      exact congrArg some hx

/-- Native sizes may be rounded. The Number conversion returns a literal with
that rounded meaning; it does not promote it to an exact-integer annotation. -/
theorem number_integer (F : Ffi) (s : St F.S) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (e : SymE) (i : Int) (hv : (Value.numericInteger e).Holds ν C R (.big i))
    (fn : Nat) (receiver : Val) (o : Obj) (data : List Val)
    (hc : s.ctl = .call (.obj fn) receiver [.big i]) (ho : s.obj? fn = some o)
    (hk : o.kind = .fn (.native (.num .number) data)) :
    step F s = M.pure (s.ret (intV i)) ∧ (Value.literal e).Holds ν C R (intV i) := by
  cases hv with
  | numericInteger _ _ h =>
    exact ⟨Parametric.step_number_big_eq F s fn receiver i o data hc ho hk,.literal e _ h⟩

/-- A numeric denotation cannot justify this source call: unresolved references
are rejected even when their concrete server entry exists. -/
theorem bigint_reference_fails (F : Ffi) (s : St F.S) (fn : Nat) (receiver : Val)
    (n : Nat) (o : Obj) (data : List Val)
    (hc : s.ctl = .call (.obj fn) receiver [.num (.ref n)]) (ho : s.obj? fn = some o)
    (hk : o.kind = .fn (.native (.num .bigint) data)) :
    step F s = .fail "BigInt of a symbolic number" := by
  funext β k
  simp only [step,hc,callStep,ho,hk,callNative,numN,Host.Ts.arg,nthD]

end Host.Ts.Owned.Annotated
