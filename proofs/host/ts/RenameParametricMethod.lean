import host.ts.RenameParametricCallStart

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem step_method_descent_eq (F : Ffi) (s : St F.S) (obj : Expr) (name : Name)
    (args : List Elem) (env : Env) (optObj optCall : Bool)
    (hc : s.ctl = .ev (.call (.member obj name optObj) args optCall) env) :
    step F s = M.pure ((s.push (.c (.member (.str name) args env optObj optCall))).go (.ev obj env)) := by
  simp only [step,hc,evStep,evCall]

theorem step_method_descent_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (obj : Expr) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (hc₀ : s₀.ctl = .ev (.call (.member obj name optObj) args optCall) env) :
    interpC (step F s₀).run C₀ = some
        ((s₀.push (.c (.member (.str name) args env optObj optCall))).go (.ev obj env),C₀) ∧
      interpC (step F s).run C = some
        ((s.push (.c (.member (.str name) args (R.env env) optObj optCall))).go (.ev obj (R.env env)),C) ∧
      StateR NR FR R live framed before after old old'
        ((s₀.push (.c (.member (.str name) args env optObj optCall))).go (.ev obj env))
        ((s.push (.c (.member (.str name) args (R.env env) optObj optCall))).go (.ev obj (R.env env))) := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have he := hl.2.1
  have hf : FrameR NR R (.c (.member (.str name) args env optObj optCall))
      (.c (.member (.str name) args (R.env env) optObj optCall)) :=
    .node _ (.cons (.node _ (.cons (.node _ (.cons (.atom _ _) .nil)) (.cons (.atom _ _)
      (.cons (env_roles NR R env) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))))) .nil)
  have hfl : treeSupport live (Encode.frame (.c (.member (.str name) args env optObj optCall))) :=
    ⟨⟨⟨True.intro,True.intro⟩,True.intro,he,True.intro,True.intro,True.intro⟩,True.intro⟩
  refine ⟨?_,?_,(h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩⟩
  · rw [step_method_descent_eq F s₀ obj name args env optObj optCall hc₀]; rfl
  · rw [step_method_descent_eq F s obj name args (R.env env) optObj optCall hc]; rfl

theorem FrameR.callMember_view {NR : NumV → NumV → Prop} {R : Ren}
    {name : Name} {args : List Elem} {env : Env} {optObj optCall : Bool} {f : Frame}
    (h : FrameR NR R (.c (.member (.str name) args env optObj optCall)) f) :
    f = .c (.member (.str name) args (R.env env) optObj optCall) := by
  obtain ⟨cf',rfl,hh⟩ := h.c_view
  have ht := hh.tag_eq
  cases cf' <;> simp only [Encode.callF,treeTag] at ht
  all_goals try contradiction
  case member key args' env' optObj' optCall' =>
    cases hh with | node tag hs =>
      cases hs with | cons hk hs =>
        cases hs with | cons ha hs =>
          cases hs with | cons he hs =>
            cases hs with | cons ho hs =>
              cases hs with | cons hc hs =>
                cases ha; cases ho; cases hc
                obtain rfl := env_eq_map he
                have hkey : key = .str name := by
                  cases key with
                  | str name' => cases hk with | node tag ks => cases ks with | cons hname ks => cases hname; rfl
                  | sym a => have ht := hk.tag_eq; simp only [Encode.key,treeTag] at ht; contradiction
                rw [hkey]

theorem step_method_data_eq (F : Ffi) (s : St F.S) (a : Nat) (o : Obj) (name : Name)
    (args : List Elem) (env : Env) (optObj optCall : Bool) (v : Val) (w e : Bool) (fs : List Frame)
    (hc : s.ctl = .ret (.obj a))
    (hf : s.stack = .c (.member (.str name) args env optObj optCall)::fs)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (hp : findProp (.str name) o.props = some (.data v w e)) :
    step F s = M.pure (({s with stack := fs}.push (.c (.method (.obj a) args env optCall))).ret v) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retC,isNullish,Bool.and_false,Bool.cond_false,
    getV,lookup,getChain,St.obj?,St.push,ho,ownGet,hk,hp,M.bind,M.pure,readProp]

/-- Resolve an actual own-data method from the source heap. The target method
descriptor, receiver, optional guards and execution are all derived. -/
theorem step_method_data_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (v₀ : Val) (w e : Bool) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a))
    (hf₀ : s₀.stack = .c (.member (.str name) args env optObj optCall)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .ordinary)
    (hp₀ : findProp (.str name) o₀.props = some (.data v₀ w e)) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (({s₀ with stack := fs₀}.push (.c (.method (.obj a) args env optCall))).ret v₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (({s₀ with stack := fs₀}.push (.c (.method (.obj a) args env optCall))).ret v₀) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.callMember_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,ho,hor,hos⟩ := h.heap.readOrdinary a o₀ ha ho₀ hk₀
  obtain ⟨v,hp,hvr⟩ := hor.properties.find_data name v₀ w e hp₀
  have hvl := (PropsR.support_find hos.2.2.1 name hp₀).1
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel := hl.1.1.2.2.1
  have hnew : FrameR NR R (.c (.method (.obj a) args env optCall))
      (.c (.method (.obj (R.a a)) args (R.env env) optCall)) :=
    .node _ (.cons (.node _ (.cons (.value (.obj a)) (.cons (.atom _ _)
      (.cons (env_roles NR R env) (.cons (.atom _ _) .nil))))) .nil)
  have hnewl : treeSupport live (Encode.frame (.c (.method (.obj a) args env optCall))) :=
    ⟨⟨ha,True.intro,hel,True.intro,True.intro⟩,True.intro⟩
  have hpost := (h.restack (.cons hnew hfs) ⟨hnewl,hl.2⟩).go (c := .ret v₀) (c' := .ret v)
    (.node _ (.cons (.value hvr) .nil)) ⟨hvl,True.intro⟩
  refine ⟨({s with stack := fs}.push (.c (.method (.obj (R.a a)) args (R.env env) optCall))).ret v,?_,?_,?_⟩
  · rw [step_method_data_eq F s₀ a o₀ name args env optObj optCall v₀ w e fs₀ hc₀ hf₀ ho₀ hk₀ hp₀]; rfl
  · rw [step_method_data_eq F s (R.a a) o name args (R.env env) optObj optCall v w e fs hc hf ho (hor.ordinary hk₀) hp]; rfl
  · simpa only [St.push,St.ret,St.go] using hpost

end Host.Ts.Owned.Parametric
