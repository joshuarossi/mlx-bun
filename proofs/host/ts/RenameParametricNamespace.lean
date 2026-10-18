import host.ts.RenameParametricMethod

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem findExport_eq_lookupEnv (name : Name) (exports : Env) :
    findExport name exports = lookupEnv name exports := by
  induction exports with
  | nil => rfl
  | cons p xs ih =>
    obtain ⟨n,a⟩ := p
    simp only [findExport,lookupEnv,nameEq,ih]
    cases Nat.beq (pack name) (pack n) <;> rfl

theorem kind_namespace {NR : NumV → NumV → Prop} {R : Ren} {exports : Env} {k : Kind}
    (h : TreeR NR R (Encode.kind (.ns exports)) (Encode.kind k)) : k = .ns (R.env exports) := by
  have ht := h.tag_eq
  cases k <;> simp only [Encode.kind,treeTag] at ht
  all_goals try contradiction
  case ns exports' =>
    cases h with | node tag hs =>
      cases hs with | cons he hs => obtain rfl := env_eq_map he; rfl

theorem HeapR.read_namespace {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (h : HeapR NR R live framed before after s₀ s) (a : Nat) (o : Obj) (exports : Env)
    (ha : live a) (ho : s₀.heap.get a = some (.obj o)) (hk : o.kind = .ns exports) :
    ∃ o', s.heap.get (R.a a) = some (.obj o') ∧ o'.kind = .ns (R.env exports) ∧
      treeSupport live (Encode.env exports) := by
  have hr := h.lookup a ha
  rw [ho] at hr
  generalize he : s.heap.get (R.a a) = target at hr
  cases hr with
  | regular hf hr hl =>
    cases hr with | obj hr =>
      have hkind := hr.kind
      rw [hk] at hkind
      have hkl : treeSupport live (Encode.kind (.ns exports)) := by simpa only [hk] using hl.1.1
      exact ⟨_,rfl,kind_namespace hkind,hkl.1⟩
  | framed hf hkind => rw [hk] at hkind; cases hkind

theorem step_namespace_method_eq (F : Ffi) (s : St F.S) (a : Nat) (o : Obj) (exports : Env)
    (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool) (cell : Nat) (v : Val) (fs : List Frame)
    (hc : s.ctl = .ret (.obj a))
    (hf : s.stack = .c (.member (.str name) args env optObj optCall)::fs)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ns exports)
    (he : findExport name exports = some cell) (hv : s.heap.get cell = some (.cell (some v))) :
    step F s = M.pure (({s with stack := fs}.push (.c (.method (.obj a) args env optCall))).ret v) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retC,isNullish,Bool.and_false,Bool.cond_false,
    getV,lookup,getChain,St.obj?,St.push,ho,ownGet,hk,he,St.cell?,hv,M.bind,M.pure,readProp]

/-- A namespace method lookup reads its live export cell. Neither the target
namespace binding nor its method value is supplied as a premise. -/
theorem step_namespace_method_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o : Obj) (exports : Env) (name : Name) (args : List Elem) (env : Env)
    (optObj optCall : Bool) (cell : Nat) (v₀ : Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a))
    (hf₀ : s₀.stack = .c (.member (.str name) args env optObj optCall)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o)) (hk₀ : o.kind = .ns exports)
    (he₀ : findExport name exports = some cell) (hv₀ : s₀.heap.get cell = some (.cell (some v₀))) :
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
  obtain ⟨o',ho',hk',helive⟩ := h.heap.read_namespace a o exports ha ho₀ hk₀
  have hcell : live cell := env_lookup_live name exports cell helive (by rw [← findExport_eq_lookupEnv]; exact he₀)
  obtain ⟨value,hcell',hvr,hvl⟩ := h.heap.readCell cell v₀ hcell hv₀
  have he' : findExport name (R.env exports) = some (R.a cell) := by
    rw [findExport_eq_lookupEnv,lookupEnv_map,← findExport_eq_lookupEnv,he₀]; rfl
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel := hl.1.1.2.2.1
  have hnew : FrameR NR R (.c (.method (.obj a) args env optCall))
      (.c (.method (.obj (R.a a)) args (R.env env) optCall)) :=
    .node _ (.cons (.node _ (.cons (.value (.obj a)) (.cons (.atom _ _)
      (.cons (env_roles NR R env) (.cons (.atom _ _) .nil))))) .nil)
  have hnewl : treeSupport live (Encode.frame (.c (.method (.obj a) args env optCall))) :=
    ⟨⟨ha,True.intro,hel,True.intro,True.intro⟩,True.intro⟩
  have hpost := (h.restack (.cons hnew hfs) ⟨hnewl,hl.2⟩).go (c := .ret v₀) (c' := .ret value)
    (.node _ (.cons (.value hvr) .nil)) ⟨hvl,True.intro⟩
  refine ⟨({s with stack := fs}.push (.c (.method (.obj (R.a a)) args (R.env env) optCall))).ret value,?_,?_,?_⟩
  · rw [step_namespace_method_eq F s₀ a o exports name args env optObj optCall cell v₀ fs₀ hc₀ hf₀ ho₀ hk₀ he₀ hv₀]; rfl
  · rw [step_namespace_method_eq F s (R.a a) o' (R.env exports) name args (R.env env) optObj optCall
      (R.a cell) value fs hc hf ho' hk' he' hcell']; rfl
  · simpa only [St.push,St.ret,St.go] using hpost

end Host.Ts.Owned.Parametric
