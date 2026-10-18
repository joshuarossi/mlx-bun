import host.ts.RenameParametricNumbers
namespace Host.Ts.Owned.Parametric

/-- Actual `Number(nativeSize)` dispatch. Size is an ordinary integer result,
not an owned native handle. -/
theorem step_number_big_eq (F : Ffi) (s : St F.S) (fn : Nat) (receiver : Val) (i : Int)
    (o : Obj) (data : List Val)
    (hc : s.ctl = .call (.obj fn) receiver [.big i]) (ho : s.obj? fn = some o)
    (hk : o.kind = .fn (.native (.num .number) data)) :
    step F s = M.pure (s.ret (intV i)) := by
  funext β k
  simp only [step,hc,callStep,ho,hk,callNative,numN,retS]

/-- The true numeric conversion can round large integers. Its role records the
actual `F64.ofInt` result and requires no unjustified exact-integer bound. -/
theorem step_number_big_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (C₀ C : CSrv) (fn₀ fn : Nat) (receiver₀ receiver : Val) (i₀ i : Int)
    (o₀ o : Obj) (data₀ data : List Val)
    (hc₀ : s₀.ctl = .call (.obj fn₀) receiver₀ [.big i₀])
    (hc : s.ctl = .call (.obj fn) receiver [.big i])
    (ho₀ : s₀.obj? fn₀ = some o₀) (ho : s.obj? fn = some o)
    (hk₀ : o₀.kind = .fn (.native (.num .number) data₀))
    (hk : o.kind = .fn (.native (.num .number) data))
    (hn : NR (.lit (F64.ofInt i₀)) (.lit (F64.ofInt i))) :
    interpC (step F s₀).run C₀ = some (s₀.ret (intV i₀),C₀) ∧
    interpC (step F s).run C = some (s.ret (intV i),C) ∧
    StateR NR FR R live framed before after old old' (s₀.ret (intV i₀)) (s.ret (intV i)) := by
  refine ⟨?_,?_,h.go (.node _ (.cons (.value (.num hn)) .nil)) ⟨True.intro,True.intro⟩⟩
  · rw [step_number_big_eq F s₀ fn₀ receiver₀ i₀ o₀ data₀ hc₀ ho₀ hk₀]
    rfl
  · rw [step_number_big_eq F s fn receiver i o data hc ho hk]
    rfl

/-- Actual `BigInt(number)` accepts a literal integral number. The interpreter
explicitly rejects unresolved numeric references on this path. -/
theorem step_bigint_number_eq (F : Ffi) (s : St F.S) (fn : Nat) (receiver : Val) (x : F64) (i : Int)
    (o : Obj) (data : List Val)
    (hc : s.ctl = .call (.obj fn) receiver [.num (.lit x)]) (ho : s.obj? fn = some o)
    (hk : o.kind = .fn (.native (.num .bigint) data)) (hi : F64.toInt? x = some i) :
    step F s = M.pure (s.ret (.big i)) := by
  funext β k
  simp only [step,hc,callStep,ho,hk,callNative,numN,Host.Ts.arg,nthD,hi,retS]

/-- Integer packing is related only after the literal conversions and each
roundtrip have been proved. No arithmetic law for rounded integers is assumed. -/
theorem step_bigint_number_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (C₀ C : CSrv) (fn₀ fn : Nat) (receiver₀ receiver : Val) (x₀ x : F64) (i₀ i : Int)
    (o₀ o : Obj) (data₀ data : List Val)
    (hc₀ : s₀.ctl = .call (.obj fn₀) receiver₀ [.num (.lit x₀)])
    (hc : s.ctl = .call (.obj fn) receiver [.num (.lit x)])
    (ho₀ : s₀.obj? fn₀ = some o₀) (ho : s.obj? fn = some o)
    (hk₀ : o₀.kind = .fn (.native (.num .bigint) data₀))
    (hk : o.kind = .fn (.native (.num .bigint) data))
    (hi₀ : F64.toInt? x₀ = some i₀) (hi : F64.toInt? x = some i)
    (hx₀ : F64.ofInt i₀ = x₀) (hx : F64.ofInt i = x) (hn : NR (.lit x₀) (.lit x)) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.big i₀),C₀) ∧
    interpC (step F s).run C = some (s.ret (.big i),C) ∧
    StateR NR FR R live framed before after old old' (s₀.ret (.big i₀)) (s.ret (.big i)) := by
  have hn' : NR (.lit (F64.ofInt i₀)) (.lit (F64.ofInt i)) := by simpa only [hx₀,hx] using hn
  refine ⟨?_,?_,h.go (.node _ (.cons (.value (.numericInteger hn')) .nil)) ⟨True.intro,True.intro⟩⟩
  · rw [step_bigint_number_eq F s₀ fn₀ receiver₀ x₀ i₀ o₀ data₀ hc₀ ho₀ hk₀ hi₀]
    rfl
  · rw [step_bigint_number_eq F s fn receiver x i o data hc ho hk hi]
    rfl

end Host.Ts.Owned.Parametric
