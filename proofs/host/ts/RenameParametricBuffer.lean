import host.ts.RenameParametricVariables
namespace Host.Ts.Owned.Parametric

theorem cellVal_related {NR : NumV → NumV → Prop} {R : Ren} {c c' : Cell}
    (h : CellR NR R c c') : ValueR NR R (cellVal c) (cellVal c') := by
  cases h with
  | num h => exact .num h
  | ordinaryBig i => exact .ordinaryBig i
  | numericInteger h => exact .numericInteger h
  | handle h => exact .handle h
  | pointerInteger m off => exact .pointerInteger m off

private def identityRen : Ren := ⟨id,id,id,id,id⟩

private theorem identityCell (c : Cell) : Owned.CellR identityRen c c := by
  cases c with
  | num n => cases n <;> exact .num _
  | big i => exact .ordinaryBig i

/-- Actual typed-view element-zero evaluation, reusing the proved coherent-byte
read rule at the identity resource map. No target-state equation is assumed. -/
theorem step_typed_zero_eq (F : Ffi) (s : St F.S) (a b : Nat) (o : Obj)
    (k : EltK) (c : Cell) (fs : List Frame)
    (hc : s.ctl = .ret (.num zeroN)) (hf : s.stack = .e (.indexR (.obj a)) :: fs)
    (ho : s.obj? a = some o) (hk : o.kind = .typed k b 0 1)
    (hb : bufBytes F s b = some (cellParts k c k.size 0)) :
    step F s = M.pure ({s with stack := fs}.ret (cellVal c)) :=
  (Owned.step_indexTyped0_roles F identityRen s s a b o o k c c fs fs (identityCell c)
    hc hc hf hf ho hk ho hk hb hb).1

/-- The source `[0]` read transports numeric token, ordinary integer, packed
integer, handle and pointer cell roles while preserving the complete state. -/
theorem step_typed_zero_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a b : Nat) (o₀ o : Obj) (k : EltK) (c₀ c : Cell) (fs₀ fs : List Frame)
    (hr : CellR NR R c₀ c)
    (hc₀ : s₀.ctl = .ret (.num zeroN)) (hc : s.ctl = .ret (.num zeroN))
    (hf₀ : s₀.stack = .e (.indexR (.obj a)) :: fs₀)
    (hf : s.stack = .e (.indexR (.obj (R.a a))) :: fs)
    (ho₀ : s₀.obj? a = some o₀) (hk₀ : o₀.kind = .typed k b 0 1)
    (ho : s.obj? (R.a a) = some o) (hk : o.kind = .typed k (R.a b) 0 1)
    (hb₀ : bufBytes F s₀ b = some (cellParts k c₀ k.size 0))
    (hb : bufBytes F s (R.a b) = some (cellParts k c k.size 0)) :
    interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (cellVal c₀),C₀) ∧
    interpC (step F s).run C = some ({s with stack := fs}.ret (cellVal c),C) ∧
    StateR NR FR R live framed before after old old'
      ({s₀ with stack := fs₀}.ret (cellVal c₀)) ({s with stack := fs}.ret (cellVal c)) := by
  have hl : valueSupport live (cellVal c₀) := by cases c₀ <;> exact True.intro
  refine ⟨?_,?_,h.popRet hf₀ hf (cellVal_related hr) hl⟩
  · rw [step_typed_zero_eq F s₀ a b o₀ k c₀ fs₀ hc₀ hf₀ ho₀ hk₀ hb₀]; rfl
  · rw [step_typed_zero_eq F s (R.a a) (R.a b) o k c fs hc hf ho hk hb]; rfl

end Host.Ts.Owned.Parametric
