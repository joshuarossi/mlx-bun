import host.ts.RenameParametricShapeSpread
import host.ts.RenameParametricArguments

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem FrameR.arrayLiteral_view {NR : NumV → NumV → Prop} {R : Ren}
    {acc : List Val} {rest : List Elem} {env : Env} {f : Frame}
    (h : FrameR NR R (.l (.array acc rest env)) f) :
    ∃ acc', f = .l (.array acc' rest (R.env env)) ∧ ListR (ValueR NR R) acc acc' := by
  obtain ⟨lf',rfl,hh⟩ := h.l_view
  have ht := hh.tag_eq
  cases lf' <;> simp only [Encode.litF,treeTag] at ht
  all_goals try contradiction
  case array acc' rest' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons ha hs =>
        cases hs with | cons hr hs =>
          cases hs with | cons he hs =>
            cases hr
            obtain rfl := env_eq_map he
            exact ⟨acc',rfl,vals_roles_of ha⟩

def arrayElement {S : Type} (s : St S) (acc : List Val) (e : Expr) (rest : List Elem) (env : Env) : St S :=
  (s.push (.l (.array acc rest env))).go (.ev e env)

theorem arrayElement_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St S} (h : StateR NR FR R live framed before after old old' s₀ s)
    (acc₀ acc : List Val) (e : Expr) (rest : List Elem) (env : Env)
    (ha : ListR (ValueR NR R) acc₀ acc) (hl : listSupport (valueSupport live) acc₀)
    (he : treeSupport live (Encode.env env)) :
    StateR NR FR R live framed before after old old'
      (arrayElement s₀ acc₀ e rest env) (arrayElement s acc e rest (R.env env)) := by
  have hf : FrameR NR R (.l (.array acc₀ rest env)) (.l (.array acc rest (R.env env))) :=
    .node _ (.cons (.node _ (.cons (vals_roles ha) (.cons (.atom _ _) (.cons (env_roles NR R env) .nil)))) .nil)
  have hfl : treeSupport live (Encode.frame (.l (.array acc₀ rest env))) :=
    ⟨⟨vals_support _ hl,True.intro,he,True.intro⟩,True.intro⟩
  exact (h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩

theorem step_array_entry_eq (F : Ffi) (s : St F.S) (e : Expr) (rest : List Elem) (env : Env)
    (hc : s.ctl = .ev (.array (.expr e::rest)) env) :
    step F s = M.pure (arrayElement s [] e rest env) := by
  simp only [step,hc,evStep,arrayNext,arrayElement]

theorem step_array_entry_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (e : Expr) (rest : List Elem) (env : Env) (hc₀ : s₀.ctl = .ev (.array (.expr e::rest)) env) :
    interpC (step F s₀).run C₀ = some (arrayElement s₀ [] e rest env,C₀) ∧
      interpC (step F s).run C = some (arrayElement s [] e rest (R.env env),C) ∧
      StateR NR FR R live framed before after old old'
        (arrayElement s₀ [] e rest env) (arrayElement s [] e rest (R.env env)) := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  refine ⟨?_,?_,arrayElement_roles h [] [] e rest env .nil True.intro hl.2.1⟩
  · rw [step_array_entry_eq F s₀ e rest env hc₀]; rfl
  · rw [step_array_entry_eq F s e rest (R.env env) hc]; rfl

theorem step_array_next_eq (F : Ffi) (s : St F.S) (v : Val) (acc : List Val)
    (e : Expr) (rest : List Elem) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .l (.array acc (.expr e::rest) env)::fs) :
    step F s = M.pure (arrayElement {s with stack := fs} (v::acc) e rest env) := by
  simp only [step,hc,stepRet,hf,retStep,retL,arrayNext,arrayElement]

theorem step_array_next_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ : Val) (acc₀ : List Val)
    (e : Expr) (rest : List Elem) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .l (.array acc₀ (.expr e::rest) env)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ = some (arrayElement {s₀ with stack := fs₀} (v₀::acc₀) e rest env,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (arrayElement {s₀ with stack := fs₀} (v₀::acc₀) e rest env) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  obtain ⟨acc,hfe,ha⟩ := hfr.arrayLiteral_view
  rw [hfe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hvl := (h.return_values v₀ v hc₀ hc).2
  refine ⟨arrayElement {s with stack := fs} (v::acc) e rest (R.env env),?_,?_,
    arrayElement_roles (h.restack hfs hl.2) (v₀::acc₀) (v::acc) e rest env (.cons hv ha)
      ⟨hvl,vals_support_of _ hl.1.1.1⟩ hl.1.1.2.2.1⟩
  · rw [step_array_next_eq F s₀ v₀ acc₀ e rest env fs₀ hc₀ hf₀]; rfl
  · rw [step_array_next_eq F s v acc e rest (R.env env) fs hc hf]; rfl

theorem step_array_final_eq (F : Ffi) (s : St F.S) (v : Val) (acc : List Val)
    (env : Env) (fs : List Frame) (hc : s.ctl = .ret v) (hf : s.stack = .l (.array acc [] env)::fs) :
    step F s = M.pure (({s with stack := fs}.alloc (valueArray (v::acc).reverse)).2.ret (.obj s.next)) := by
  simp only [step,hc,stepRet,hf,retStep,retL,arrayNext,newArray,St.allocObj,retS,valueArray]
  rfl

theorem step_array_final_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ : Val) (acc₀ : List Val)
    (env : Env) (fs₀ : List Frame) (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .l (.array acc₀ [] env)::fs₀)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (({s₀ with stack := fs₀}.alloc (valueArray (v₀::acc₀).reverse)).2.ret (.obj s₀.next),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
        (({s₀ with stack := fs₀}.alloc (valueArray (v₀::acc₀).reverse)).2.ret (.obj s₀.next)) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  obtain ⟨acc,hfe,ha⟩ := hfr.arrayLiteral_view
  rw [hfe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hvl := (h.return_values v₀ v hc₀ hc).2
  refine ⟨({s with stack := fs}.alloc (valueArray (v::acc).reverse)).2.ret (.obj s.next),?_,?_,
    (h.restack hfs hl.2).alloc_valueArray _ _ (values_reverse_roles (.cons hv ha))
      (listSupport_reverse ⟨hvl,vals_support_of _ hl.1.1.1⟩) hp hpr hs ht⟩
  · rw [step_array_final_eq F s₀ v₀ acc₀ env fs₀ hc₀ hf₀]; rfl
  · rw [step_array_final_eq F s v acc (R.env env) fs hc hf]; rfl

end Host.Ts.Owned.Parametric
