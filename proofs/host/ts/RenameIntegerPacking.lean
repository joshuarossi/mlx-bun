import host.ts.RenameParametricConversions
import host.ts.RenameBounded
import Init.Data.Nat.Bitwise.Lemmas
namespace Host.Ts.F64

/-- Integers below 2^53 are represented exactly by this binary64 model. -/
theorem ofNat_exact53 (n : Nat) (h : n < 2 ^ 53) : ofNat n = natExact n := by
  have hsmall : Nat.blt n (Nat.pow 2 53) = true := by rw [Nat.blt_eq]; exact h
  have hlog : Nat.log2 n < 1024 := by
    by_cases hn : n = 0
    · subst n; decide
    · have hh : Nat.log2 n < 53 := (Nat.log2_lt hn).mpr h
      omega
  have htop : ilt (Int.add (Nat.log2 n : Int) 0) 1024 = true := by
    change Nat.blt (Nat.log2 n) 1024 = true
    rw [Nat.blt_eq]
    exact hlog
  change round b64 false n 1 0 = _
  simp only [round,b64,hsmall,htop]
  change norm false n 0 = _
  unfold norm natExact
  by_cases hn : n = 0
  · subst n; rfl
  · have hb : Nat.beq n 0 = false := by
      cases hq : Nat.beq n 0
      · rfl
      · exact False.elim (hn (Nat.eq_of_beq_eq_true hq))
    have hs : Nat.blt n small = true := hsmall
    simp only [hb,hs,ite_eq_right hn]
    rfl

theorem toInt_ofNat53 (n : Nat) (h : n < 2 ^ 53) : toInt? (ofNat n) = some (n : Int) := by
  rw [ofNat_exact53 n h,toInt_natExact]

theorem add_natExact53 (m n : Nat) (h : m + n < 2 ^ 53) :
    add (natExact m) (natExact n) = natExact (m + n) := by
  cases m with
  | zero => cases n <;> simp [natExact,add]
  | succ m => cases n with
    | zero => simp [natExact,add]
    | succ n =>
      have hs : Nat.blt (m + 1 + (n + 1)) small = true := by rw [Nat.blt_eq]; exact h
      change (bif Nat.blt (m + 1 + (n + 1)) small then fin false (m + 1 + (n + 1)) 0
        else round b64 false (m + 1 + (n + 1)) 1 0) = fin false (m + 1 + (n + 1)) 0
      rw [hs]
      rfl

theorem add_ofNat53 (m n : Nat) (h : m + n < 2 ^ 53) :
    add (ofNat m) (ofNat n) = ofNat (m + n) := by
  have hm : m < 2 ^ 53 := by omega
  have hn : n < 2 ^ 53 := by omega
  rw [ofNat_exact53 m hm,ofNat_exact53 n hn,ofNat_exact53 (m+n) h]
  exact add_natExact53 m n h

end Host.Ts.F64
namespace Host.Ts

/-- The exact ordinary bigint produced by mlx-bun's optional-int packing. -/
def packedOptInt (n : Nat) : Nat := Nat.lor (Nat.land n (2 ^ 32 - 1)) (2 ^ 32)

theorem packedOptInt_eq (n : Nat) (h : n < 2 ^ 32) : packedOptInt n = n + 2 ^ 32 := by
  unfold packedOptInt
  change (n &&& (2 ^ 32 - 1)) ||| 2 ^ 32 = n + 2 ^ 32
  rw [Nat.and_two_pow_sub_one_of_lt_two_pow h,Nat.or_two_pow_eq_add_of_lt h]

theorem packedOptInt_bound (n : Nat) (h : n < 2 ^ 32) : packedOptInt n < 2 ^ 33 := by
  rw [packedOptInt_eq n h]
  omega

/-- Packing is a numeric symbolic role, distinct from an address or owned handle.
The exact integer result is below 2^33 and therefore its Number conversion is exact. -/
theorem NumRole.packOptInt {ν₀ ν : Nat → F64} {C₀ C : CSrv} {e : SymE} {n₀ n : Nat}
    (hr : NumRole ν₀ ν C₀ C e (.lit (F64.ofNat n₀)) (.lit (F64.ofNat n)))
    (h₀ : n₀ < 2 ^ 32) (h : n < 2 ^ 32) :
    NumRole ν₀ ν C₀ C (.bin .add e (.lit (F64.ofNat (2 ^ 32))))
      (.lit (F64.ofNat (packedOptInt n₀))) (.lit (F64.ofNat (packedOptInt n))) := by
  have he₀ : e.eval ν₀ = F64.ofNat n₀ := Option.some.inj hr.left.symm
  have he : e.eval ν = F64.ofNat n := Option.some.inj hr.right.symm
  constructor
  · change some (F64.ofNat (packedOptInt n₀)) = some (F64.add (e.eval ν₀) (F64.ofNat (2 ^ 32)))
    rw [he₀,packedOptInt_eq n₀ h₀,F64.add_ofNat53 n₀ (2 ^ 32) (by omega)]
  · change some (F64.ofNat (packedOptInt n)) = some (F64.add (e.eval ν) (F64.ofNat (2 ^ 32)))
    rw [he,packedOptInt_eq n h,F64.add_ofNat53 n (2 ^ 32) (by omega)]

/-- Real bigint AND dispatch for the optional unsigned argument. -/
theorem step_optInt_mask (F : Ffi) (s : St F.S) (n : Nat) (fs : List Frame) (hn : n < 2 ^ 32)
    (hc : s.ctl = .ret (.big (Int.ofNat (2 ^ 32 - 1))))
    (hf : s.stack = .e (.binR .band (.big (Int.ofNat n))) :: fs) :
    step F s = M.pure ({s with stack := fs}.ret (.big (Int.ofNat n))) := by
  have hmask : Nat.land n (2 ^ 32 - 1) = n := Nat.and_two_pow_sub_one_of_lt_two_pow hn
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,binOp,arith,bigOp,bigNat2,hmask,retS]
  rfl

/-- The high presence bit is computed by the real bigint shift operator. -/
theorem step_optInt_flag (F : Ffi) (s : St F.S) (fs : List Frame)
    (hc : s.ctl = .ret (.big (Int.ofNat 32)))
    (hf : s.stack = .e (.binR .shl (.big (Int.ofNat 1))) :: fs) :
    step F s = M.pure ({s with stack := fs}.ret (.big (Int.ofNat (2 ^ 32)))) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,binOp,arith,bigOp,retS]
  rfl

/-- The source OR combines disjoint bounded unsigned bits and the presence bit. -/
theorem step_optInt_or (F : Ffi) (s : St F.S) (n : Nat) (fs : List Frame) (hn : n < 2 ^ 32)
    (hc : s.ctl = .ret (.big (Int.ofNat (2 ^ 32))))
    (hf : s.stack = .e (.binR .bor (.big (Int.ofNat n))) :: fs) :
    step F s = M.pure ({s with stack := fs}.ret (.big (Int.ofNat (packedOptInt n)))) := by
  have hor : Nat.lor n (2 ^ 32) = packedOptInt n := by
    rw [packedOptInt_eq n hn]
    exact Nat.or_two_pow_eq_add_of_lt hn
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,binOp,arith,bigOp,bigNat2,hor,retS]
  rfl

end Host.Ts

namespace Host.Ts.Owned.Parametric

/-- A completed source expression may discard its related top continuation;
all remaining stack frames and live heap/native components are retained. -/
theorem StateR.popRet {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    {f₀ f : Frame} {fs₀ fs : List Frame} (hf₀ : s₀.stack = f₀ :: fs₀) (hf : s.stack = f :: fs)
    {v₀ v : Val} (hv : ValueR NR R v₀ v) (hl : valueSupport live v₀) :
    StateR NR FR R live framed before after old old'
      ({s₀ with stack := fs₀}.ret v₀) ({s with stack := fs}.ret v) := by
  have hs := h.stack
  have hsl := h.stackLive
  rw [hf₀,hf] at hs
  cases hs with
  | cons hhead htail =>
    have hlfs : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
      rw [hf₀] at hsl
      exact hsl.2
    exact (h.restack htail hlfs).go (.node _ (.cons (.value hv) .nil)) ⟨hl,True.intro⟩

/-- Actual bigint masking preserves the complete numeric-role runtime. -/
theorem step_optInt_mask_roles (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (n₀ n : Nat) (e : SymE) (fs₀ fs : List Frame) (hn₀ : n₀ < 2 ^ 32) (hn : n < 2 ^ 32)
    (hr : NumRole ν₀ ν C₀ C e (.lit (F64.ofNat n₀)) (.lit (F64.ofNat n)))
    (hc₀ : s₀.ctl = .ret (.big (Int.ofNat (2 ^ 32 - 1))))
    (hc : s.ctl = .ret (.big (Int.ofNat (2 ^ 32 - 1))))
    (hf₀ : s₀.stack = .e (.binR .band (.big (Int.ofNat n₀))) :: fs₀)
    (hf : s.stack = .e (.binR .band (.big (Int.ofNat n))) :: fs) :
    interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (.big (Int.ofNat n₀)),C₀) ∧
    interpC (step F s).run C = some ({s with stack := fs}.ret (.big (Int.ofNat n)),C) ∧
    StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      ({s₀ with stack := fs₀}.ret (.big (Int.ofNat n₀)))
      ({s with stack := fs}.ret (.big (Int.ofNat n))) := by
  refine ⟨?_,?_,h.popRet hf₀ hf (.numericInteger ⟨e,hr⟩) True.intro⟩
  · rw [step_optInt_mask F s₀ n₀ fs₀ hn₀ hc₀ hf₀]; rfl
  · rw [step_optInt_mask F s n fs hn hc hf]; rfl

/-- The source presence-bit shift is ordinary bigint arithmetic, never a handle
operation, and preserves every live state component. -/
theorem step_optInt_flag_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret (.big (Int.ofNat 32))) (hc : s.ctl = .ret (.big (Int.ofNat 32)))
    (hf₀ : s₀.stack = .e (.binR .shl (.big (Int.ofNat 1))) :: fs₀)
    (hf : s.stack = .e (.binR .shl (.big (Int.ofNat 1))) :: fs) :
    interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (.big (Int.ofNat (2 ^ 32))),C₀) ∧
    interpC (step F s).run C = some ({s with stack := fs}.ret (.big (Int.ofNat (2 ^ 32))),C) ∧
    StateR NR FR R live framed before after old old'
      ({s₀ with stack := fs₀}.ret (.big (Int.ofNat (2 ^ 32))))
      ({s with stack := fs}.ret (.big (Int.ofNat (2 ^ 32)))) := by
  refine ⟨?_,?_,h.popRet hf₀ hf (.ordinaryBig _) True.intro⟩
  · rw [step_optInt_flag F s₀ fs₀ hc₀ hf₀]; rfl
  · rw [step_optInt_flag F s fs hc hf]; rfl

/-- Full-state source closure for the final optional-int OR, with its exact
symbolic packed-value role proved from the bounded unsigned operand. -/
theorem step_optInt_or_roles (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (n₀ n : Nat) (e : SymE) (fs₀ fs : List Frame) (hn₀ : n₀ < 2 ^ 32) (hn : n < 2 ^ 32)
    (hr : NumRole ν₀ ν C₀ C e (.lit (F64.ofNat n₀)) (.lit (F64.ofNat n)))
    (hc₀ : s₀.ctl = .ret (.big (Int.ofNat (2 ^ 32))))
    (hc : s.ctl = .ret (.big (Int.ofNat (2 ^ 32))))
    (hf₀ : s₀.stack = .e (.binR .bor (.big (Int.ofNat n₀))) :: fs₀)
    (hf : s.stack = .e (.binR .bor (.big (Int.ofNat n))) :: fs) :
    interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (.big (Int.ofNat (packedOptInt n₀))),C₀) ∧
    interpC (step F s).run C = some ({s with stack := fs}.ret (.big (Int.ofNat (packedOptInt n))),C) ∧
    StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      ({s₀ with stack := fs₀}.ret (.big (Int.ofNat (packedOptInt n₀))))
      ({s with stack := fs}.ret (.big (Int.ofNat (packedOptInt n)))) := by
  have hp := hr.packOptInt hn₀ hn
  refine ⟨?_,?_,h.popRet hf₀ hf (.numericInteger ⟨_,hp⟩) True.intro⟩
  · rw [step_optInt_or F s₀ n₀ fs₀ hn₀ hc₀ hf₀]; rfl
  · rw [step_optInt_or F s n fs hn hc hf]; rfl

end Host.Ts.Owned.Parametric
