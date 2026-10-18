import host.ts.RenameParametricArrayBinding
import host.ts.RenameParametricExpressionReturns
import host.ts.RenameParametricTypedElements

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem listR_length_eq {α β : Type} {rel : α → β → Prop} {as : List α} {bs : List β}
    (h : ListR rel as bs) : as.length = bs.length := by
  induction h with
  | nil => rfl
  | cons _ _ ih => exact congrArg Nat.succ ih

theorem FrameR.member_view {NR : NumV → NumV → Prop} {R : Ren}
    {name : Name} {opt : Bool} {f : Frame}
    (h : FrameR NR R (.e (.member (.str name) opt)) f) : f = .e (.member (.str name) opt) := by
  obtain ⟨ef,rfl,hh⟩ := h.e_view
  have ht := hh.tag_eq
  cases ef <;> simp only [Encode.exprF,treeTag] at ht
  all_goals try contradiction
  case member name' opt' =>
    cases hh with | node tag hs =>
      cases hs with | cons hn hs =>
        cases hs with | cons ho hs =>
          cases ho
          have hkey : name' = .str name := by
            cases name' with
            | str name' => cases hn with | node tag ks => cases ks with | cons hname ks => cases hname; rfl
            | sym a => have ht := hn.tag_eq; simp only [Encode.key,treeTag] at ht; contradiction
          rw [hkey]

theorem step_array_length_eq (F : Ffi) (s : St F.S) (a : Nat) (o : Obj) (vs : List Val)
    (opt : Bool) (fs : List Frame) (hc : s.ctl = .ret (.obj a))
    (hf : s.stack = .e (.member kLength opt)::fs)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .array vs) :
    step F s = M.pure ({s with stack := fs}.ret (natV (len vs))) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,isNullish,Bool.and_false,Bool.cond_false,
    getV,lookup,getChain,St.obj?,ho,ownGet,hk,
    show keyIndex kLength = none from rfl,
    show keyEq kLength kLength = true from rfl,M.bind,M.pure,readProp]
  rfl

/-- An owned array's actual length getter returns the same literal length.
The target array and its elements are recovered from the heap relation. -/
theorem step_array_length_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (vs₀ : List Val) (opt : Bool) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a))
    (hf₀ : s₀.stack = .e (.member kLength opt)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .array vs₀)
    (hn : ¬ framed a) (hnr : NR (.lit (F64.ofNat (len vs₀))) (.lit (F64.ofNat (len vs₀)))) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (natV (len vs₀)),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        ({s₀ with stack := fs₀}.ret (natV (len vs₀))) result ∧ result.ctl = .ret (natV (len vs₀)) := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.member_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,vs,ho,hk,hvs,_⟩ := h.heap.read_array a o₀ vs₀ ha hn ho₀ hk₀
  have hlen : len vs = len vs₀ := by simpa only [len_list_length] using (listR_length_eq hvs).symm
  have hl := h.stackLive
  rw [hf₀] at hl
  refine ⟨({s with stack := fs}.ret (natV (len vs₀))),?_,?_,?_,rfl⟩
  · rw [step_array_length_eq F s₀ a o₀ vs₀ opt fs₀ hc₀ hf₀ ho₀ hk₀]; rfl
  · rw [step_array_length_eq F s (R.a a) o vs opt fs hc hf ho hk,hlen]; rfl
  · simpa only [St.ret,St.go] using
      (h.restack hfs hl.2).go (c := .ret (natV (len vs₀))) (c' := .ret (natV (len vs₀)))
        (.node _ (.cons (.value (.num hnr)) .nil)) ⟨True.intro,True.intro⟩

end Host.Ts.Owned.Parametric
