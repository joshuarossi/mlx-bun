import host.ts.RenameParametricReads
import host.ts.RenameRouteHeapFields
import host.ts.RenameParametricMethod
import host.ts.RenameParametricGlobal
namespace Host.Ts.Owned.Parametric

theorem StateR.native_map {S : Type} {NR : NumV → NumV → Prop}
    {FR GR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (f : ∀ r a b, FR r a b → GR r a b) : StateR NR GR R live framed before after old old' s₀ s :=
  ⟨h.heap,h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,
    f R s₀.ffi s.ffi h.native,h.trace⟩

theorem readProp_heap (F : Ffi) (s : St F.S) (receiver : Val) (p : Option PropV) :
    (Host.Ts.readProp F s receiver p).heap = s.heap := by
  cases p with
  | none => rfl
  | some p => cases p with
    | data v w e => rfl
    | acc getter setter e => cases getter <;> rfl

theorem step_variable_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (v₀ : Val)
    (hc₀ : s₀.ctl = .ev (.id name) env) (he : lookupEnv name env = some a)
    (hv : s₀.heap.get a = some (.cell (some v₀)))
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  obtain ⟨_,_,hr,_,_⟩ := step_variable_roles F NR FR R C₀ C live framed before after old old' s₀ s h
    name env a v₀ hc₀ hc he (env_lookup_live name env a hl.2.1 he) hv
  have heq := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  have hh := congrArg St.heap heq
  exact hh

theorem step_this_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (env : Env) (a : Nat) (v₀ : Val)
    (hc₀ : s₀.ctl = .ev .this env) (he : lookupEnv nThis env = some a)
    (hv : s₀.heap.get a = some (.cell (some v₀)))
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨_,_,hr,_,_⟩ := step_this_from_source F NR FR R C₀ C live framed before after old old' s₀ s h env a v₀ hc₀ he hv
  have hh := congrArg St.heap (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_method_descent_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (obj : Expr) (name : Name) (args : List Elem) (env : Env) (oo oc : Bool)
    (hc₀ : s₀.ctl = .ev (.call (.member obj name oo) args oc) env)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨_,hr,_⟩ := step_method_descent_from_source F NR FR R C₀ C live framed before after old old' s₀ s h obj name args env oo oc hc₀
  have hh := congrArg St.heap (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_callStart_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (mode : CallStart) (a : Nat) (this : Val) (args : List Elem) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = mode.frame this args env::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨t,hft,_⟩ := hfr.callStart_view mode
  rw [hft] at hf
  rw [step_callStart_eq F s mode (R.a a) t args (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  have hh := congrArg St.heap he
  rw [argumentState_heap] at hh
  exact hh.symm
theorem step_method_data_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (name : Name) (args : List Elem) (env : Env) (oo oc : Bool)
    (v₀ : Val) (w e : Bool) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a))
    (hf₀ : s₀.stack = .c (.member (.str name) args env oo oc)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .ordinary)
    (hp₀ : findProp (.str name) o₀.props = some (.data v₀ w e))
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.callMember_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,ho,hor,_⟩ := h.heap.readOrdinary a o₀ ha ho₀ hk₀
  obtain ⟨v,hp,_⟩ := hor.properties.find_data name v₀ w e hp₀
  rw [step_method_data_eq F s (R.a a) o name args (R.env env) oo oc v w e fs hc hf ho
    (hor.ordinary hk₀) hp] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.heap he).symm
theorem step_global_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (o₀ : Obj) (v₀ : Val) (w e : Bool)
    (hc₀ : s₀.ctl = .ev (.id name) env) (he₀ : lookupEnv name env = none)
    (ho₀ : s₀.heap.get aGlobal = some (.obj o₀)) (hk₀ : o₀.kind = .ordinary)
    (hp₀ : findProp (.str name) o₀.props = some (.data v₀ w e))
    (hg : live aGlobal) (hgf : R.a aGlobal = aGlobal)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨_,_,hr,_,_⟩ := step_global_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
    name env o₀ v₀ w e hc₀ he₀ ho₀ hk₀ hp₀ hg hgf
  have hh := congrArg St.heap (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh
end Host.Ts.Owned.Parametric
