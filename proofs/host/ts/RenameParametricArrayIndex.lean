import host.ts.RenameParametricArrayBinding
import host.ts.RenameParametricExpressionReturns

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem listR_nth_some {α β : Type} {rel : α → β → Prop} {xs : List α} {ys : List β}
    (h : ListR rel xs ys) (i : Nat) (x : α) (hx : nth? xs i = some x) :
    ∃ y, nth? ys i = some y ∧ rel x y := by
  induction h generalizing i with
  | nil => cases hx
  | cons hr ht ih => cases i with
    | zero => obtain rfl := Option.some.inj hx; exact ⟨_,rfl,hr⟩
    | succ i => exact ih i hx

theorem listSupport_nth {α : Type} (p : α → Prop) (xs : List α) (h : listSupport p xs)
    (i : Nat) (x : α) (hx : nth? xs i = some x) : p x := by
  induction xs generalizing i with
  | nil => cases hx
  | cons a xs ih => cases i with
    | zero => obtain rfl := Option.some.inj hx; exact h.1
    | succ i => exact ih h.2 i hx

theorem FrameR.indexLeft_view {NR : NumV → NumV → Prop} {R : Ren}
    {key : Expr} {env : Env} {f : Frame}
    (h : FrameR NR R (.e (.indexL key env false)) f) : f = .e (.indexL key (R.env env) false) := by
  obtain ⟨ef,rfl,hh⟩ := h.e_view
  have ht := hh.tag_eq
  cases ef <;> simp only [Encode.exprF,treeTag] at ht
  all_goals try contradiction
  case indexL key' env' opt' =>
    cases hh with | node tag hs =>
      cases hs with | cons hk hs =>
        cases hs with | cons he hs =>
          cases hs with | cons ho hs =>
            cases hk; cases ho
            obtain rfl := env_eq_map he
            rfl

theorem FrameR.indexRight_view {NR : NumV → NumV → Prop} {R : Ren}
    {receiver : Val} {f : Frame} (h : FrameR NR R (.e (.indexR receiver)) f) :
    ∃ receiver', f = .e (.indexR receiver') ∧ ValueR NR R receiver receiver' := by
  obtain ⟨ef,rfl,hh⟩ := h.e_view
  have ht := hh.tag_eq
  cases ef <;> simp only [Encode.exprF,treeTag] at ht
  all_goals try contradiction
  case indexR receiver' =>
    cases hh with | node tag hs =>
      cases hs with | cons hv hs =>
        cases hv with | value hr => exact ⟨receiver',rfl,hr⟩

theorem step_index_left_eq (F : Ffi) (s : St F.S) (receiver : Val) (key : Expr)
    (env : Env) (fs : List Frame) (hc : s.ctl = .ret receiver)
    (hf : s.stack = .e (.indexL key env false)::fs) :
    step F s = M.pure (({s with stack := fs}.push (.e (.indexR receiver))).go (.ev key env)) := by
  simp only [step,hc,stepRet,hf,retStep,retE,Bool.false_and,Bool.cond_false]

theorem step_index_left_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (receiver₀ : Val) (key : Expr) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret receiver₀) (hf₀ : s₀.stack = .e (.indexL key env false)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (({s₀ with stack := fs₀}.push (.e (.indexR receiver₀))).go (.ev key env),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (({s₀ with stack := fs₀}.push (.e (.indexR receiver₀))).go (.ev key env)) result := by
  obtain ⟨receiver,hc,hr⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.indexLeft_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel := hl.1.1.2.1
  have hrl := (h.return_values receiver₀ receiver hc₀ hc).2
  have hnew : FrameR NR R (.e (.indexR receiver₀)) (.e (.indexR receiver)) := by
    repeat first | exact hr | constructor
  have hnewl : treeSupport live (Encode.frame (.e (.indexR receiver₀))) := ⟨⟨hrl,True.intro⟩,True.intro⟩
  have hpost := (h.restack (.cons hnew hfs) ⟨hnewl,hl.2⟩).go (c := .ev key env) (c' := .ev key (R.env env))
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,hel,True.intro⟩
  refine ⟨({s with stack := fs}.push (.e (.indexR receiver))).go (.ev key (R.env env)),?_,?_,?_⟩
  · rw [step_index_left_eq F s₀ receiver₀ key env fs₀ hc₀ hf₀]; rfl
  · rw [step_index_left_eq F s receiver key (R.env env) fs hc hf]; rfl
  · simpa only [St.push,St.go] using hpost

theorem step_array_index_eq (F : Ffi) (s : St F.S) (key : Val) (a i : Nat)
    (o : Obj) (values : List Val) (value : Val) (fs : List Frame)
    (hc : s.ctl = .ret key) (hf : s.stack = .e (.indexR (.obj a))::fs)
    (hi : numIndex key = some i) (ho : s.heap.get a = some (.obj o))
    (hk : o.kind = .array values) (hv : nth? values i = some value) :
    step F s = M.pure ({s with stack := fs}.ret value) := by
  obtain ⟨kind,proto,props,priv,extensible⟩ := o
  dsimp only at hk
  subst kind
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,getIndex,hi,isIndexable,elemAt,
    St.obj?,ho,Bool.cond_true,hv,M.bind,M.pure,retS]

/-- A fixed evaluated index selects related elements of the actual owned
array. The target array read, element and step are all derived. -/
theorem step_array_index_from_source_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (key : Val) (a i : Nat) (o₀ : Obj) (values₀ : List Val) (value₀ : Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret key) (hf₀ : s₀.stack = .e (.indexR (.obj a))::fs₀)
    (hi : numIndex key = some i) (ho₀ : s₀.heap.get a = some (.obj o₀))
    (hk₀ : o₀.kind = .array values₀) (hv₀ : nth? values₀ i = some value₀)
    (notFramed : ¬ framed a) (hc : s.ctl = .ret key) :
    ∃ value result, interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret value₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ({s₀ with stack := fs₀}.ret value₀) result ∧
      result.ctl = .ret value ∧ ValueR NR R value₀ value ∧ result.heap = s.heap := by
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  obtain ⟨receiver,hframe,hr⟩ := hfr.indexRight_view
  cases hr
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha : live a := hl.1.1.1
  obtain ⟨o,values,ho,hk,hvalues,hvaluesl⟩ := h.heap.read_array a o₀ values₀ ha notFramed ho₀ hk₀
  obtain ⟨value,hv,hr⟩ := listR_nth_some hvalues i value₀ hv₀
  have hvl := listSupport_nth (valueSupport live) values₀ hvaluesl i value₀ hv₀
  refine ⟨value,{s with stack := fs}.ret value,?_,?_,?_,rfl,hr,rfl⟩
  · rw [step_array_index_eq F s₀ key a i o₀ values₀ value₀ fs₀ hc₀ hf₀ hi ho₀ hk₀ hv₀]; rfl
  · rw [step_array_index_eq F s key (R.a a) i o values value fs hc hf hi ho hk hv]; rfl
  · exact (h.restack hfs hl.2).go (.node _ (.cons (.value hr) .nil)) ⟨hvl,True.intro⟩

theorem step_array_index_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (key : Val) (a i : Nat) (o₀ : Obj) (values₀ : List Val) (value₀ : Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret key) (hf₀ : s₀.stack = .e (.indexR (.obj a))::fs₀)
    (hi : numIndex key = some i) (ho₀ : s₀.heap.get a = some (.obj o₀))
    (hk₀ : o₀.kind = .array values₀) (hv₀ : nth? values₀ i = some value₀)
    (notFramed : ¬ framed a) (hc : s.ctl = .ret key) :
    ∃ value result, interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret value₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ({s₀ with stack := fs₀}.ret value₀) result ∧
      result.ctl = .ret value ∧ ValueR NR R value₀ value := by
  obtain ⟨value,result,hr₀,hr,hpost,hc,hrv,_⟩ := step_array_index_from_source_fields F NR FR R C₀ C
    live framed before after old old' s₀ s h key a i o₀ values₀ value₀ fs₀
    hc₀ hf₀ hi ho₀ hk₀ hv₀ notFramed hc
  exact ⟨value,result,hr₀,hr,hpost,hc,hrv⟩

end Host.Ts.Owned.Parametric
