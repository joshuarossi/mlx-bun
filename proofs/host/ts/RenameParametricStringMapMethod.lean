import host.ts.RenameParametricMethod
import host.ts.RenameParametricLookup
import host.ts.RenameParametricStringMap

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem step_map_method_eq (F : Ffi) (s : St F.S) (a b : Nat) (o p : Obj)
    (vs : List (Val × Val)) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (v : Val) (w e : Bool) (fs : List Frame)
    (hc : s.ctl = .ret (.obj a))
    (hf : s.stack = .c (.member (.str name) args env optObj optCall)::fs)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .map vs)
    (notSize : keyEq (.str name) (.str chars!"size") = false)
    (hp : findProp (.str name) o.props = none) (hproto : o.proto = .obj b)
    (hb : s.heap.get b = some (.obj p)) (hbk : p.kind = .ordinary)
    (hbp : findProp (.str name) p.props = some (.data v w e)) :
    step F s = M.pure (({s with stack := fs}.push (.c (.method (.obj a) args env optCall))).ret v) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retC,isNullish,Bool.and_false,Bool.cond_false,
    getV,lookup,getChain,St.obj?,St.push,ho,ownGet,hk,notSize,hp,hproto,hb,hbk,hbp,M.bind,M.pure,readProp]

/-- Resolve an inherited map method through the actual receiver and its
ordinary prototype. Neither target property lookup nor target execution is a
premise. The selected string key excludes the map's special size property. -/
theorem step_map_method_from_source_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a b : Nat) (o₀ p₀ : Obj) (vs₀ : List (Val × Val)) (name : Name) (args : List Elem)
    (env : Env) (optObj optCall : Bool) (v₀ : Val) (w e : Bool) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a))
    (hf₀ : s₀.stack = .c (.member (.str name) args env optObj optCall)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .map vs₀)
    (notSize : keyEq (.str name) (.str chars!"size") = false)
    (hp₀ : findProp (.str name) o₀.props = none) (hproto₀ : o₀.proto = .obj b)
    (hb₀ : s₀.heap.get b = some (.obj p₀)) (hbk₀ : p₀.kind = .ordinary)
    (hbp₀ : findProp (.str name) p₀.props = some (.data v₀ w e)) :
    ∃ value frames, s.stack = .c (.member (.str name) args (R.env env) optObj optCall)::frames ∧
      interpC (step F s₀).run C₀ =
        some (({s₀ with stack := fs₀}.push (.c (.method (.obj a) args env optCall))).ret v₀,C₀) ∧
      interpC (step F s).run C = some (({s with stack := frames}.push (.c (.method (.obj (R.a a)) args (R.env env) optCall))).ret value,C) ∧
      StateR NR FR R live framed before after old old'
        (({s₀ with stack := fs₀}.push (.c (.method (.obj a) args env optCall))).ret v₀)
        (({s with stack := frames}.push (.c (.method (.obj (R.a a)) args (R.env env) optCall))).ret value) ∧
      ValueR NR R v₀ value := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.callMember_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,ho,hor,hos⟩ := h.heap.readObject a o₀ ha (h.heap.map_notFramed a o₀ vs₀ ha ho₀ hk₀) ho₀
  have hkind := hor.kind
  rw [hk₀] at hkind
  obtain ⟨vs,hk,_⟩ := kind_string_map hkind
  have hp : findProp (.str name) o.props = none := by
    have hh := hor.properties.find_string name
    rw [hp₀] at hh
    generalize he : findProp (.str name) o.props = found at hh
    cases hh
    rfl
  have hproto : o.proto = .obj (R.a b) := by
    have hh := hor.prototype
    rw [hproto₀] at hh
    generalize he : o.proto = proto at hh
    cases hh
    rfl
  have hb : live b := by have hl := hos.2.1; rw [hproto₀] at hl; exact hl
  obtain ⟨p,hpb,hpr,hps⟩ := h.heap.readOrdinary b p₀ hb hb₀ hbk₀
  obtain ⟨v,hpp,hvr⟩ := hpr.properties.find_data name v₀ w e hbp₀
  have hvl := (PropsR.support_find hps.2.2.1 name hbp₀).1
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
  refine ⟨v,fs,hf,?_,?_,?_,hvr⟩
  · rw [step_map_method_eq F s₀ a b o₀ p₀ vs₀ name args env optObj optCall v₀ w e fs₀
      hc₀ hf₀ ho₀ hk₀ notSize hp₀ hproto₀ hb₀ hbk₀ hbp₀]; rfl
  · rw [step_map_method_eq F s (R.a a) (R.a b) o p vs name args (R.env env) optObj optCall v w e fs
      hc hf ho hk notSize hp hproto hpb (hpr.ordinary hbk₀) hpp]; rfl
  · simpa only [St.push,St.ret,St.go] using hpost

end Host.Ts.Owned.Parametric
