import host.ts.RenameAnnotatedLoop
import host.ts.RenameParametricPropWrites
namespace Host.Ts.Owned.Parametric

private def offsetTarget (a : Nat) : Target := .prop (.obj a) (.str chars!"offset")
private def afterOffsetAdd {S : Type} (s : St S) (a n : Nat) (fs : List Frame) : St S :=
  {s with ctl := .ret (natV (n+1)), stack := .a (.put none (offsetTarget a) (natV n))::fs}

private theorem offset_add_eq (F : Ffi) (s : St F.S) (a n : Nat) (fs : List Frame)
    (hc : s.ctl = .ret (natV 1))
    (hf : s.stack = .a (.put (some .add) (offsetTarget a) (natV n))::fs)
    (hn : n+1 < 2^53) : step F s = M.pure (afterOffsetAdd s a n fs) := by
  have hadd := F64.add_ofNat53 n 1 hn
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retA,binOp,addOp,arith,toNum,numOp?,numBin,M.bind,M.pure,retS,
    natV,St.push,St.ret,St.go,afterOffsetAdd,F64.bin,hadd]

private theorem runC_two (F : Ffi) (s₀ s₁ s₂ : St F.S) (C₀ C₁ C₂ : CSrv)
    (hhalt₀ : isHalt s₀.ctl = false) (hhalt₁ : isHalt s₁.ctl = false)
    (h₀ : interpC (step F s₀).run C₀ = some (s₁,C₁))
    (h₁ : interpC (step F s₁).run C₁ = some (s₂,C₂)) : runC F 2 s₀ C₀ = some (s₂,C₂) := by
  change runWith F interpC (1+1) s₀ C₀ = _
  rw [runWith_succ,hhalt₀,Bool.cond_false,h₀]
  dsimp only
  rw [St.rebuild_eq,runWith_succ,hhalt₁,Bool.cond_false,h₁]
  dsimp only
  rw [St.rebuild_eq]
  rfl

/-- Complete two-step source `cache.offset += 1` block. The arithmetic folds
actual literals, the writable-property rule stores each successor, and both
executions retain the fixed symbolic meaning `oldOffset+1`. -/
theorem offset_block (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a n₀ n : Nat) (meaning : SymE) (o₀ : Obj) (enum : Bool) (fs₀ fs : List Frame)
    (ha : live a) (hn₀ : n₀+1 < 2^53) (hn : n+1 < 2^53)
    (number : NumRole ν₀ ν C₀ C meaning (.lit (F64.ofNat n₀)) (.lit (F64.ofNat n)))
    (hc₀ : s₀.ctl = .ret (natV 1)) (hc : s.ctl = .ret (natV 1))
    (hf₀ : s₀.stack = .a (.put (some .add) (offsetTarget a) (natV n₀))::fs₀)
    (hf : s.stack = .a (.put (some .add) (offsetTarget (R.a a)) (natV n))::fs)
    (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .ordinary)
    (hp : findProp (.str chars!"offset") o₀.props = some (.data (natV n₀) true enum))
    (hs : a < 2^64) (ht : R.a a < 2^64) :
    ∃ (o : Obj), let t₀ := ({s₀ with stack := fs₀}.setObj a
        {o₀ with props := setPropL (.str chars!"offset") (.data (natV (n₀+1)) true enum) o₀.props}).ret (natV (n₀+1))
      let t := ({s with stack := fs}.setObj (R.a a)
        {o with props := setPropL (.str chars!"offset") (.data (natV (n+1)) true enum) o.props}).ret (natV (n+1))
      runC F 2 s₀ C₀ = some (t₀,C₀) ∧ runC F 2 s C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      NumRole ν₀ ν C₀ C (.bin .add meaning (.lit (F64.ofNat 1)))
        (.lit (F64.ofNat (n₀+1))) (.lit (F64.ofNat (n+1))) := by
  have he₀ : F64.ofNat n₀ = meaning.eval ν₀ := Option.some.inj number.left
  have he : F64.ofNat n = meaning.eval ν := Option.some.inj number.right
  have numberNext : NumRole ν₀ ν C₀ C (.bin .add meaning (.lit (F64.ofNat 1)))
      (.lit (F64.ofNat (n₀+1))) (.lit (F64.ofNat (n+1))) := by
    constructor
    · change some (F64.ofNat (n₀+1)) = some (F64.add (meaning.eval ν₀) (F64.ofNat 1))
      rw [← he₀,F64.add_ofNat53 n₀ 1 hn₀]
    · change some (F64.ofNat (n+1)) = some (F64.add (meaning.eval ν) (F64.ofNat 1))
      rw [← he,F64.add_ofNat53 n 1 hn]
  have hOld : ValueR (NumberRoles ν₀ ν C₀ C) R (natV n₀) (natV n) := .num ⟨meaning,number⟩
  have hNew : ValueR (NumberRoles ν₀ ν C₀ C) R (natV (n₀+1)) (natV (n+1)) := .num ⟨_,numberNext⟩
  have hFrame : FrameR (NumberRoles ν₀ ν C₀ C) R
      (.a (.put none (offsetTarget a) (natV n₀))) (.a (.put none (offsetTarget (R.a a)) (natV n))) := by
    dsimp only [Encode.frame,Encode.asgF,Encode.opt,Encode.target,offsetTarget,Encode.key,Encode.val,Encode.atom]
    repeat first | exact hOld | exact (ValueR.obj (NR := NumberRoles ν₀ ν C₀ C) (R := R) a) | constructor
  have hFrameLive : treeSupport live (Encode.frame (.a (.put none (offsetTarget a) (natV n₀)))) := by
    dsimp only [Encode.frame,Encode.asgF,Encode.opt,Encode.target,offsetTarget,Encode.key,Encode.val,Encode.atom,
      natV,treeSupport,forestSupport,valueSupport]
    repeat first | exact ha | constructor
  have hfs : ListR (FrameR (NumberRoles ν₀ ν C₀ C) R) fs₀ fs := by
    have hh := h.stack
    rw [hf₀,hf] at hh
    cases hh with | cons hh ht => exact ht
  have hfl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
    have hh := h.stackLive
    rw [hf₀] at hh
    exact hh.2
  have hAdded : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (afterOffsetAdd s₀ a n₀ fs₀) (afterOffsetAdd s (R.a a) n fs) :=
    (h.restack (.cons hFrame hfs) ⟨hFrameLive,hfl⟩).go (.node _ (.cons (.value hNew) .nil)) ⟨True.intro,True.intro⟩
  obtain ⟨o,hr₀,hr,hpost⟩ := step_property_store_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' (afterOffsetAdd s₀ a n₀ fs₀) (afterOffsetAdd s (R.a a) n fs) hAdded
    a chars!"offset" (natV (n₀+1)) (natV (n+1)) (natV n₀) (natV n) (natV n₀) enum o₀ fs₀ fs
    hNew rfl rfl rfl rfl ha ho hk hp hs ht
  refine ⟨o,?_,?_,hpost,numberNext⟩
  · apply runC_two F s₀ (afterOffsetAdd s₀ a n₀ fs₀) _ C₀ C₀ C₀
    · rw [hc₀]; rfl
    · rfl
    · rw [offset_add_eq F s₀ a n₀ fs₀ hc₀ hf₀ hn₀]; rfl
    · exact hr₀
  · apply runC_two F s (afterOffsetAdd s (R.a a) n fs) _ C C C
    · rw [hc]; rfl
    · rfl
    · rw [offset_add_eq F s (R.a a) n fs hc hf hn]; rfl
    · exact hr

end Host.Ts.Owned.Parametric
