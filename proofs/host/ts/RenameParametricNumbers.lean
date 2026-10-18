import host.ts.RenameParametricState
import host.ts.RenameNumericRole
namespace Host.Ts.Owned.Parametric

def NumberRoles (ν₀ ν : Nat → F64) (C₀ C : CSrv) (a₀ a : NumV) : Prop :=
  ∃ e, NumRole ν₀ ν C₀ C e a₀ a

theorem NumberRoles.mono {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv}
    (h₀ : TableExtends C₀ D₀) (h : TableExtends C D) :
    ∀ a₀ a, NumberRoles ν₀ ν C₀ C a₀ a → NumberRoles ν₀ ν D₀ D a₀ a := by
  intro a₀ a ⟨e,hr⟩
  exact ⟨e,hr.mono h₀ h⟩

private theorem requestBin_map {α : Type} (C : CSrv) (op : NBin) (a b : NumV) (f : NumV → α) :
    interpC (.bin op a b (fun i => .pure (f (.ref i)))) C =
      (interpC (.bin op a b (fun i => .pure (.ref i))) C).map (fun (v,D) => (f v,D)) := by
  cases ha : C.val a <;> cases hb : C.val b <;>
    simp only [interpC_bin,ha,hb,interpC_pure,Option.map_none,Option.map_some]

/-- The actual numeric primitive's continuation, including either literal
folding or a fresh reference, commutes with interpreting and returning a state. -/
theorem numBin_map {α : Type} (C : CSrv) (op : NBin) (a b : NumV) (f : NumV → α) :
    interpC ((numBin op a b).bind (fun v => M.pure (f v))).run C =
      (interpC (numBin op a b).run C).map (fun (v,D) => (f v,D)) := by
  cases a with
  | lit x => cases b with
    | lit y => rfl
    | ref i => exact requestBin_map C op (.lit x) (.ref i) f
  | ref i => exact requestBin_map C op (.ref i) b f

inductive ArithmeticKind where
  | add | sub | mul | div | rem | band | bor | bxor | shl | shr | ushr

def ArithmeticKind.jsOp : ArithmeticKind → BinOp
  | .add => .add | .sub => .sub | .mul => .mul | .div => .div | .rem => .mod
  | .band => .band | .bor => .bor | .bxor => .bxor | .shl => .shl | .shr => .shr | .ushr => .ushr

def ArithmeticKind.numOp : ArithmeticKind → NBin
  | .add => .add | .sub => .sub | .mul => .mul | .div => .div | .rem => .rem
  | .band => .band | .bor => .bor | .bxor => .bxor | .shl => .shl | .shr => .shr | .ushr => .ushr

/-- Dispatch of all source numeric arithmetic operators through the real
interpreter. Bigint operators have their separate occurrence roles. -/
theorem step_arithmetic_eq (F : Ffi) (s : St F.S) (op : ArithmeticKind) (a b : NumV) (fs : List Frame)
    (hc : s.ctl = .ret (.num b)) (hf : s.stack = .e (.binR op.jsOp (.num a)) :: fs) :
    step F s = (numBin op.numOp a b).bind (fun v => M.pure ({s with stack := fs}.ret (.num v))) := by
  cases op <;> funext β k <;>
    simp only [step,hc,stepRet,hf,retStep,retE,ArithmeticKind.jsOp,ArithmeticKind.numOp,
      binOp,addOp,arith,toNum,numOp?,M.bind,M.pure,retS]

/-- A complete arithmetic machine step transports numeric occurrence roles
between independently growing concrete number servers. Source and target
literals, reference indices and numbers of allocations can all differ. -/
theorem step_arithmetic_roles (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (op : ArithmeticKind) (a₀ a b₀ b : NumV) (ea eb : SymE) (fs₀ fs : List Frame)
    (ha : NumRole ν₀ ν C₀ C ea a₀ a) (hb : NumRole ν₀ ν C₀ C eb b₀ b)
    (hc₀ : s₀.ctl = .ret (.num b₀)) (hc : s.ctl = .ret (.num b))
    (hf₀ : s₀.stack = .e (.binR op.jsOp (.num a₀)) :: fs₀)
    (hf : s.stack = .e (.binR op.jsOp (.num a)) :: fs) :
    ∃ v₀ D₀ v D,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (.num v₀),D₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.ret (.num v),D) ∧
      NumRole ν₀ ν D₀ D (.bin op.numOp ea eb) v₀ v ∧
      StateR (NumberRoles ν₀ ν D₀ D) FR R live framed before after old old'
        ({s₀ with stack := fs₀}.ret (.num v₀)) ({s with stack := fs}.ret (.num v)) ∧
      TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨v₀,D₀,v,D,hr₀,hr,hrole,he₀,he⟩ := ha.numBin hb op.numOp
  refine ⟨v₀,D₀,v,D,?_,?_,hrole,?_,he₀,he⟩
  · rw [step_arithmetic_eq F s₀ op a₀ b₀ fs₀ hc₀ hf₀,numBin_map,hr₀]
    rfl
  · rw [step_arithmetic_eq F s op a b fs hc hf,numBin_map,hr]
    rfl
  · have hm := h.mono (NumberRoles.mono he₀ he) id
    have hfs := hm.stack
    have hfl := hm.stackLive
    rw [hf₀,hf] at hfs
    cases hfs with
    | cons hhead htail =>
      have hl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
        rw [hf₀] at hfl
        exact hfl.2
      exact (hm.restack htail hl).go (.node _ (.cons (.value (.num ⟨_,hrole⟩)) .nil)) ⟨True.intro,True.intro⟩

namespace HeapR
variable {S : Type} {NR : NumV → NumV → Prop} {R : Ren} {live framed : Nat → Prop}
  {before after : List Val} {s s' : St S}

theorem setCell (h : HeapR NR R live framed before after s s') (a : Nat) (v v' : Val)
    (ha : live a) (hf : ¬ framed a) (hr : ValueR NR R v v')
    (hl : valueSupport live v) (hs : a < 2 ^ 64) (ht : R.a a < 2 ^ 64) :
    HeapR NR R live framed before after (s.setCell a v) (s'.setCell (R.a a) v') := by
  constructor
  · intro b hb
    by_cases he : b = a
    · subst b
      simp only [St.setCell,PTrie.get_set_u64 _ _ _ hs,PTrie.get_set_u64 _ _ _ ht]
      exact .regular hf (.cell hr) ⟨hl,True.intro⟩
    · have hne : R.a b ≠ R.a a := fun heq => he (h.inj b a hb ha heq)
      simpa only [St.setCell,PTrie.get_set_u64 _ _ _ hs,PTrie.get_set_u64 _ _ _ ht,
        ite_eq_right he,ite_eq_right hne] using h.lookup b hb
  · exact h.sourceBound
  · exact h.targetBound
  · exact h.prefixLive
  · exact h.inj
  · exact h.fresh

end HeapR

namespace StateR
variable {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
  {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s s' : St S}

theorem setCell (h : StateR NR FR R live framed before after old old' s s')
    (a : Nat) (v v' : Val) (ha : live a) (hf : ¬ framed a) (hr : ValueR NR R v v')
    (hl : valueSupport live v) (hs : a < 2 ^ 64) (ht : R.a a < 2 ^ 64) :
    StateR NR FR R live framed before after old old' (s.setCell a v) (s'.setCell (R.a a) v') :=
  ⟨h.heap.setCell a v v' ha hf hr hl hs ht,h.control,h.controlLive,h.stack,h.stackLive,
    h.jobs,h.jobsLive,h.stores,h.storesLive,h.native,h.trace⟩

end StateR

/-- The real postfix variable update, before choosing a numeric server. -/
theorem step_postinc_eq (F : Ffi) (s : St F.S) (a : NumV) (fs : List Frame)
    (name : Name) (env : Env) (address : Nat)
    (hc : s.ctl = .ret (.num a))
    (hf : s.stack = .a (.updOld true false (.var name env)) :: fs)
    (he : lookupEnv name env = some address) (hcell : s.cell? address = some (some (.num a))) :
    step F s = (numBin .add a one).bind (fun v => M.pure
      { s.setCell address (.num v) with ctl := .ret (.num v), stack := .e (.const (.num a)) :: fs }) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retA,toNum,M.bind,M.pure,Bool.cond_true,Bool.cond_false,
    storeTarget,writeVar,he,cell?_control,hcell,retS,St.push,St.ret,St.setCell]

/-- The actual `generated++` source operation preserves the full parameterized
runtime relation, writes each independently represented successor to its live
cell, and keeps the old value in the postfix continuation. -/
theorem step_postinc_roles (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a₀ a : NumV) (ea : SymE) (fs₀ fs : List Frame) (name : Name) (env₀ env : Env) (address : Nat)
    (ha : NumRole ν₀ ν C₀ C ea a₀ a)
    (hc₀ : s₀.ctl = .ret (.num a₀)) (hc : s.ctl = .ret (.num a))
    (hf₀ : s₀.stack = .a (.updOld true false (.var name env₀)) :: fs₀)
    (hf : s.stack = .a (.updOld true false (.var name env)) :: fs)
    (he₀ : lookupEnv name env₀ = some address) (he : lookupEnv name env = some (R.a address))
    (hcell₀ : s₀.cell? address = some (some (.num a₀)))
    (hcell : s.cell? (R.a address) = some (some (.num a)))
    (hlive : live address) (hframe : ¬ framed address)
    (hs : address < 2 ^ 64) (ht : R.a address < 2 ^ 64) :
    ∃ v₀ D₀ v D,
      let t₀ := { s₀.setCell address (.num v₀) with ctl := .ret (.num v₀), stack := .e (.const (.num a₀)) :: fs₀ }
      let t := { s.setCell (R.a address) (.num v) with ctl := .ret (.num v), stack := .e (.const (.num a)) :: fs }
      interpC (step F s₀).run C₀ = some (t₀,D₀) ∧ interpC (step F s).run C = some (t,D) ∧
      NumRole ν₀ ν D₀ D (.bin .add ea (.lit (F64.ofNat 1))) v₀ v ∧
      StateR (NumberRoles ν₀ ν D₀ D) FR R live framed before after old old' t₀ t ∧
      TableExtends C₀ D₀ ∧ TableExtends C D := by
  have h1 : NumRole ν₀ ν C₀ C (.lit (F64.ofNat 1)) one one := .literal ν₀ ν C₀ C _
  obtain ⟨v₀,D₀,v,D,hr₀,hr,hrole,hext₀,hext⟩ := ha.numBin h1 .add
  refine ⟨v₀,D₀,v,D,?_,?_,hrole,?_,hext₀,hext⟩
  · rw [step_postinc_eq F s₀ a₀ fs₀ name env₀ address hc₀ hf₀ he₀ hcell₀,numBin_map,hr₀]
    rfl
  · rw [step_postinc_eq F s a fs name env (R.a address) hc hf he hcell,numBin_map,hr]
    rfl
  · have hm := h.mono (NumberRoles.mono hext₀ hext) id
    have hfs := hm.stack
    have hfl := hm.stackLive
    rw [hf₀,hf] at hfs
    cases hfs with
    | cons hhead htail =>
      have hl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
        rw [hf₀] at hfl
        exact hfl.2
      have hold : FrameR (NumberRoles ν₀ ν D₀ D) R (.e (.const (.num a₀))) (.e (.const (.num a))) :=
        .node _ (.cons (.node _ (.cons (.value (.num ⟨ea,ha.mono hext₀ hext⟩)) .nil)) .nil)
      have hh := hm.setCell address (.num v₀) (.num v) hlive hframe (.num ⟨_,hrole⟩) True.intro hs ht
      have hh := hh.restack (.cons hold htail) ⟨⟨⟨True.intro,True.intro⟩,True.intro⟩,hl⟩
      exact hh.go (.node _ (.cons (.value (.num ⟨_,hrole⟩)) .nil)) ⟨True.intro,True.intro⟩

end Host.Ts.Owned.Parametric
