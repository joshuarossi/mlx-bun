import host.ts.RenameParametricCallStep
import host.ts.RenameParametricNativeCall
import host.ts.RenameParametricPropWrites
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Fixed constructor argument retained below field-initializer frames. -/
def classBodyArgument : List Frame → Val
  | .k (.ctorBody _ _ _ args)::_ => nthD .undef args 0
  | _::rest => classBodyArgument rest
  | [] => .undef

theorem kind_base_class {NR : NumV → NumV → Prop} {R : Ren}
    {ctor : Func} {env : Env} {members : List InstMember} {k : Kind}
    (h : TreeR NR R (Encode.kind (.fn (.klass (some ctor) env .null members))) (Encode.kind k)) :
    ∃ members', k = .fn (.klass (some ctor) (R.env env) .null members') ∧
      TreeR NR R (Encode.seq (members.map Encode.inst)) (Encode.seq (members'.map Encode.inst)) := by
  have ht := h.tag_eq
  cases k <;> simp only [Encode.kind,treeTag] at ht
  all_goals try contradiction
  case fn c =>
    cases h with | node tag hs =>
      cases hs with | cons hc hs =>
        have ht := hc.tag_eq
        cases c <;> simp only [Encode.code,treeTag] at ht
        all_goals try contradiction
        case klass ctor' env' parent' members' =>
          cases hc with | node tag hs =>
            cases hs with | cons hctor hs =>
              cases hs with | cons he hs =>
                cases hs with | cons hp hs =>
                  cases hs with | cons hm hs =>
                    cases hctor
                    obtain rfl := env_eq_map he
                    cases hp with | value hp =>
                      cases hp
                      exact ⟨members',rfl,hm⟩

theorem dataOf_function_own (F : Ffi) (s : St F.S) (a : Nat) (o : Obj) (c : Code)
    (name : Name) (v : Val) (w e : Bool)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .fn c)
    (hp : findProp (.str name) o.props = some (.data v w e)) :
    dataOf F s (.obj a) (.str name) = M.pure (some v) := by
  funext β k
  simp only [dataOf,lookup,getChain,St.obj?,ho,ownGet,hk,hp,M.bind,M.pure]

def baseClassEntry {S : Type} (s : St S) (ctor : Func) (env : Env)
    (members : List InstMember) (args : List Val) (proto : Nat) : St S :=
  let (o,s) := s.allocObj .ordinary (.obj proto) []
  let (tc,s) := s.alloc (.cell (some (.obj o)))
  ((s.push (.k (.ctorBody (.obj o) ctor env args))).push (.k (.fields o members ((nThis,tc)::env)))).ret .undef

theorem step_base_class_entry_eq (F : Ffi) (s : St F.S) (a proto : Nat) (o : Obj)
    (ctor : Func) (env : Env) (members : List InstMember) (args : List Val) (w e : Bool)
    (hc : s.ctl = .construct (.obj a) args (.obj a))
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .fn (.klass (some ctor) env .null members))
    (hp : findProp kPrototype o.props = some (.data (.obj proto) w e)) :
    step F s = M.pure (baseClassEntry s ctor env members args proto) := by
  have hd : dataOf F s (.obj a) kPrototype = M.pure (some (.obj proto)) :=
    dataOf_function_own F s a o (.klass (some ctor) env .null members) chars!"prototype" (.obj proto) w e ho hk hp
  simp only [step,hc,constructStep,St.obj?,ho,hk,hd]
  rfl

def BaseClassLive (live : Nat → Prop) (start : Nat) : Nat → Prop := LiveAfter (LiveAfter live start) (start+1)

/-- The actual base-class constructor allocates the instance and its this cell,
then installs the original constructor and field continuations. The class,
prototype, captured environment and instance members are derived from the live
source object, including private-brand resource roles. -/
theorem step_base_class_entry_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (a proto : Nat) (o : Obj) (ctor : Func) (env : Env) (members : List InstMember)
    (args₀ : List Val) (w e : Bool)
    (hc₀ : s₀.ctl = .construct (.obj a) args₀ (.obj a))
    (ho₀ : s₀.heap.get a = some (.obj o)) (hk₀ : o.kind = .fn (.klass (some ctor) env .null members))
    (hp₀ : findProp kPrototype o.props = some (.data (.obj proto) w e))
    (sourceBound : s₀.next+2 ≤ 2^64) (targetBound : s.next+2 ≤ 2^64) :
    ∃ args members', s.ctl = .construct (.obj (R.a a)) args (.obj (R.a a)) ∧
      interpC (step F s₀).run C₀ = some (baseClassEntry s₀ ctor env members args₀ proto,C₀) ∧
      interpC (step F s).run C = some (baseClassEntry s ctor (R.env env) members' args (R.a proto),C) ∧
      StateR NR FR R (BaseClassLive live s₀.next) framed before after old old'
        (baseClassEntry s₀ ctor env members args₀ proto) (baseClassEntry s ctor (R.env env) members' args (R.a proto)) := by
  obtain ⟨callee,args,nt,hc,hcallee,hargs,hnt⟩ := (h.control_view hc₀).construct_view
  cases hcallee
  cases hnt
  have hl := h.controlLive
  rw [hc₀] at hl
  have ha : live a := hl.1
  obtain ⟨o',ho,hor,hol⟩ := h.heap.readObject a o ha (h.heap.function_notFramed a o _ ha ho₀ hk₀) ho₀
  have hrk := hor.kind
  rw [hk₀] at hrk
  obtain ⟨members',hk,hm⟩ := kind_base_class hrk
  obtain ⟨p,hp,hpr⟩ := hor.properties.find_data chars!"prototype" (.obj proto) w e hp₀
  cases hpr
  have hpl : live proto := (PropsR.support_find hol.2.2.1 chars!"prototype" hp₀).1
  have hle : treeSupport live (Encode.env env) := by
    have hkSupport := hol.1
    rw [hk₀] at hkSupport
    exact hkSupport.1.2.1
  have hml : treeSupport live (Encode.seq (members.map Encode.inst)) := by
    have hkSupport := hol.1
    rw [hk₀] at hkSupport
    exact hkSupport.1.2.2.2.1
  let obj₀ : HObj := .obj ⟨.ordinary,.obj proto,[],[],true⟩
  let obj : HObj := .obj ⟨.ordinary,.obj (R.a proto),[],[],true⟩
  have objRoles : HeapObjectR NR R obj₀ obj := .obj (.node _ (.cons (.node _ .nil)
    (.cons (.value (.obj proto)) (.cons (.node _ .nil) (.cons (.node _ .nil) (.cons (.atom _ _) .nil))))))
  have objLive : treeSupport (LiveAfter live s₀.next) (Encode.hobj obj₀) :=
    ⟨⟨True.intro,Or.inl hpl,True.intro,True.intro,True.intro,True.intro⟩,True.intro⟩
  have h1 := h.alloc obj₀ obj objRoles objLive (by omega) (by omega)
  have fresh0 : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have fresh1 : R.a (s₀.next+1) = s.next+1 := h.heap.fresh 1
  have thisRole : HeapObjectR NR R (.cell (some (.obj s₀.next))) (.cell (some (.obj s.next))) := by
    rw [← fresh0]
    exact .cell (.obj s₀.next)
  have thisLive : treeSupport (BaseClassLive live s₀.next) (Encode.hobj (.cell (some (.obj s₀.next)))) :=
    ⟨Or.inl (Or.inr rfl),True.intro⟩
  have h2 := h1.alloc (.cell (some (.obj s₀.next))) (.cell (some (.obj s.next))) thisRole thisLive (by change s₀.next+1 < 2^64; omega) (by change s.next+1 < 2^64; omega)
  have grow : ∀ a, live a → BaseClassLive live s₀.next a := fun _ ha => Or.inl (Or.inl ha)
  have fieldEnv : R.env ((nThis,s₀.next+1)::env) = (nThis,s.next+1)::R.env env := by simp only [Ren.env,List.map_cons,fresh1]
  have fenvLive : treeSupport (BaseClassLive live s₀.next) (Encode.env ((nThis,s₀.next+1)::env)) :=
    ⟨⟨True.intro,Or.inr rfl,True.intro⟩,treeSupport_mono grow _ hle⟩
  have argvLive : listSupport (valueSupport live) args₀ := vals_support_of args₀ hl.2.1
  have bodyFrame : FrameR NR R (.k (.ctorBody (.obj s₀.next) ctor env args₀))
      (.k (.ctorBody (.obj s.next) ctor (R.env env) args)) := by
    rw [← fresh0]
    exact .node _ (.cons (.node _ (.cons (.value (.obj s₀.next)) (.cons (.atom _ _)
      (.cons (env_roles NR R env) (.cons (vals_roles hargs) .nil))))) .nil)
  have fieldsFrame : FrameR NR R (.k (.fields s₀.next members ((nThis,s₀.next+1)::env)))
      (.k (.fields s.next members' ((nThis,s.next+1)::R.env env))) := by
    rw [← fieldEnv,← fresh0]
    exact .node _ (.cons (.node _ (.cons (.address _) (.cons hm (.cons (env_roles NR R _) .nil)))) .nil)
  have bodyLive : treeSupport (BaseClassLive live s₀.next) (Encode.frame (.k (.ctorBody (.obj s₀.next) ctor env args₀))) :=
    ⟨⟨Or.inl (Or.inr rfl),True.intro,treeSupport_mono grow _ hle,vals_support _ (listSupport_mono (valueSupport_mono grow) _ argvLive),True.intro⟩,True.intro⟩
  have fieldsLive : treeSupport (BaseClassLive live s₀.next) (Encode.frame (.k (.fields s₀.next members ((nThis,s₀.next+1)::env)))) :=
    ⟨⟨Or.inl (Or.inr rfl),treeSupport_mono grow _ hml,fenvLive,True.intro⟩,True.intro⟩
  have hs := (h2.restack (.cons fieldsFrame (.cons bodyFrame h2.stack)) ⟨fieldsLive,bodyLive,h2.stackLive⟩).go (c := .ret .undef) (c' := .ret .undef)
    (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
  refine ⟨args,members',hc,?_,?_,hs⟩
  · rw [step_base_class_entry_eq F s₀ a proto o ctor env members args₀ w e hc₀ ho₀ hk₀ hp₀]; rfl
  · rw [step_base_class_entry_eq F s (R.a a) (R.a proto) o' ctor (R.env env) members' args w e hc ho hk hp]; rfl

end Host.Ts.Owned.Parametric
