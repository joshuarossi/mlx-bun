import host.ts.RenameParametricMethod
import host.ts.RenameParametricLookup
import host.ts.RenameParametricNativeCall
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_method_lookup_eq (F : Ffi) (s : St F.S) (a : Nat) (name : Name)
    (args : List Elem) (env : Env) (optObj optCall : Bool) (p : Option PropV) (fs : List Frame)
    (hc : s.ctl = .ret (.obj a))
    (hf : s.stack = .c (.member (.str name) args env optObj optCall)::fs)
    (hl : getChain F (({s with stack := fs}.push (.c (.method (.obj a) args env optCall)))) (.str name) 16 a = M.pure p) :
    step F s = M.pure (Host.Ts.readProp F (({s with stack := fs}.push (.c (.method (.obj a) args env optCall)))) (.obj a) p) := by
  cases s with | mk heap next ctl stack aux =>
    change ctl = .ret (.obj a) at hc
    change stack = .c (.member (.str name) args env optObj optCall)::fs at hf
    subst ctl
    subst stack
    funext β k
    simp only [step,stepRet,retStep,retC,isNullish,Bool.and_false,Bool.cond_false,getV,lookup]
    rw [hl]
    rfl

/-- Resolve the real inherited ordinary method path before evaluating call
arguments. Every target descriptor is derived by the source prototype path. -/
theorem step_method_lookup_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (p₀ : Option PropV) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a))
    (hf₀ : s₀.stack = .c (.member (.str name) args env optObj optCall)::fs₀)
    (path : OrdinaryLookup s₀ name 16 a p₀) :
    ∃ p fs,
      interpC (step F s₀).run C₀ = some (Host.Ts.readProp F (({s₀ with stack := fs₀}.push (.c (.method (.obj a) args env optCall)))) (.obj a) p₀,C₀) ∧
      interpC (step F s).run C = some (Host.Ts.readProp F (({s with stack := fs}.push (.c (.method (.obj (R.a a)) args (R.env env) optCall)))) (.obj (R.a a)) p,C) ∧
      StateR NR FR R live framed before after old old'
        (Host.Ts.readProp F (({s₀ with stack := fs₀}.push (.c (.method (.obj a) args env optCall)))) (.obj a) p₀)
        (Host.Ts.readProp F (({s with stack := fs}.push (.c (.method (.obj (R.a a)) args (R.env env) optCall)))) (.obj (R.a a)) p) := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  rw [hfr.callMember_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have hl := h.stackLive
  rw [hf₀] at hl
  have he := hl.1.1.2.2.1
  have methodRole : FrameR NR R (.c (.method (.obj a) args env optCall))
      (.c (.method (.obj (R.a a)) args (R.env env) optCall)) := by
    repeat first | exact env_roles NR R env | constructor
  have methodLive : treeSupport live (Encode.frame (.c (.method (.obj a) args env optCall))) :=
    ⟨⟨ha,True.intro,he,True.intro,True.intro⟩,True.intro⟩
  have popped := h.restack (.cons methodRole htail) ⟨methodLive,hl.2⟩
  obtain ⟨p,hget₀,hget,hp,hpl⟩ := (path.withStack ((.c (.method (.obj a) args env optCall))::fs₀)).transport F popped.heap name ha
  refine ⟨p,fs,?_,?_,?_⟩
  · rw [step_method_lookup_eq F s₀ a name args env optObj optCall p₀ fs₀ hc₀ hf₀ hget₀]; rfl
  · rw [step_method_lookup_eq F s (R.a a) name args (R.env env) optObj optCall p fs hc hf hget]; rfl
  · cases hp with
    | none => exact popped.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
    | some hp => exact popped.readProp F (.obj a) (.obj (R.a a)) (.obj a) ha _ _ hp (hpl _ rfl)

/-- Finalization registration follows the original pure builtin semantics;
it cannot change native ownership, heap contents or invoke its callback. -/
theorem step_finalization_register_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (data₀ : List Val) (this₀ : Val) (args₀ : List Val)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ args₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .fn (.native (.fn .finRegister) data₀)) :
    interpC (step F s₀).run C₀ = some (s₀.ret .undef,C₀) ∧
      interpC (step F s).run C = some (s.ret .undef,C) ∧
      StateR NR FR R live framed before after old old' (s₀.ret .undef) (s.ret .undef) := by
  obtain ⟨o,data,this,args,hc,ho,hk,_,_,_⟩ := h.native_call_view a o₀ (.fn .finRegister) data₀ this₀ args₀ hc₀ ho₀ hk₀
  refine ⟨?_,?_,h.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩⟩
  · rw [step_native_eq F s₀ a o₀ (.fn .finRegister) data₀ this₀ args₀ hc₀ ho₀ hk₀]; rfl
  · rw [step_native_eq F s (R.a a) o (.fn .finRegister) data this args hc ho hk]; rfl

theorem FrameR.constructorBoundary_view {NR : NumV → NumV → Prop} {R : Ren}
    {receiver : Val} {f : Frame} (h : FrameR NR R (.k (.fn (.ctor receiver))) f) :
    ∃ receiver', f = .k (.fn (.ctor receiver')) ∧ ValueR NR R receiver receiver' := by
  obtain ⟨fn',rfl,hh⟩ := h.k_view
  have ht := hh.tag_eq
  cases fn' <;> simp only [Encode.fnF,treeTag] at ht
  all_goals try contradiction
  case fn b =>
    cases hh with | node tag hs =>
      cases hs with | cons hb hs =>
        have ht := hb.tag_eq
        cases b <;> simp only [Encode.bnd,treeTag] at ht
        all_goals try contradiction
        case ctor receiver' =>
          cases hb with | node tag bs =>
            cases bs with | cons hv bs =>
              cases hv with | value hv => exact ⟨receiver',rfl,hv⟩

theorem step_constructor_return_eq (F : Ffi) (s : St F.S) (v receiver : Val) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .k (.fn (.ctor receiver))::fs) :
    step F s = M.pure ({s with stack := fs}.ret receiver) := by
  simp only [step,hc,stepRet,hf,retStep,retK,boundaryRet,retS]

/-- Implicit constructor completion returns its existing receiver, deriving
its target identity from the constructor boundary in StateR. -/
theorem step_constructor_return_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ receiver₀ : Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.fn (.ctor receiver₀))::fs₀) :
    ∃ receiver fs,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret receiver₀,C₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.ret receiver,C) ∧
      StateR NR FR R live framed before after old old' ({s₀ with stack := fs₀}.ret receiver₀) ({s with stack := fs}.ret receiver) := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  obtain ⟨receiver,hframe,hr⟩ := hfr.constructorBoundary_view
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have receiverLive := hl.1.1.1.1
  refine ⟨receiver,fs,?_,?_,(h.restack htail hl.2).go (.node _ (.cons (.value hr) .nil)) ⟨receiverLive,True.intro⟩⟩
  · rw [step_constructor_return_eq F s₀ v₀ receiver₀ fs₀ hc₀ hf₀]; rfl
  · rw [step_constructor_return_eq F s v receiver fs hc hf]; rfl

end Host.Ts.Owned.Parametric
