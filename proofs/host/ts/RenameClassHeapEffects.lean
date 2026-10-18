import host.ts.RenameParametricClassValues
import host.ts.RenameParametricPrivateAssign
import host.ts.RenameClosureEffects
import host.ts.RenameParametricConstructorBody
import host.ts.RenameParametricEmptyObject
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem ClassFieldsR.private_target {NR : NumV → NumV → Prop} {R : Ren} {xs ys : List InstMember}
    (h : ClassFieldsR NR R xs ys) (hp : PrivateFields xs) : PrivateFields ys := by
  induction hp generalizing ys with
  | nil => rw [h.nil_view]; exact .nil
  | cons brand name init rest ih =>
    obtain ⟨tail,rfl,hr⟩ := h.private_view
    exact .cons (R.a brand) name init (ih hr)

/-- Private field initialization writes only its receiver. Every other address
is framed through the actual recursive initializer machine. -/
theorem fieldsNext_private_heap_other (F : Ffi) (s result : St F.S) (C D : CSrv)
    (a : Nat) (members : List InstMember) (env : Env) (onlyPrivate : PrivateFields members)
    (bound : a < 2^64) (run : interpC (fieldsNext F s a members env).run C = some (result,D))
    (m : Nat) (other : m ≠ a) : result.heap.get m = s.heap.get m := by
  induction onlyPrivate generalizing s with
  | nil =>
    change some (s.ret .undef,C) = some (result,D) at run
    have he := congrArg Prod.fst (Option.some.inj run)
    dsimp only at he
    rw [← he]
    rfl
  | @cons brand name init rest hp ih =>
    cases init with
    | some expr =>
      change some ((s.push (.k (.privVal a brand name rest env))).go (.ev expr env),C) = some (result,D) at run
      have he := congrArg Prod.fst (Option.some.inj run)
      dsimp only at he
      rw [← he]
      rfl
    | none =>
      cases ho : s.obj? a with
      | none =>
        simp only [fieldsNext,ho] at run
        contradiction
      | some o =>
        simp only [fieldsNext,ho] at run
        have hh := ih _ run
        exact hh.trans (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right other])

/-- The actual field scheduler preserves a selected address other than the
new instance; target fields and initializer syntax are derived from StateR. -/
theorem step_class_fields_heap_other (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (a : Nat) (members : List InstMember) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.fields a members env)::fs₀)
    (onlyPrivate : PrivateFields members) (bound : s.next ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) (m : Nat) (other : m ≠ R.a a) :
    result.heap.get m = s.heap.get m := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨members',hframe,hm⟩ := hfr.fields_view
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha : live a := hl.1.1.1
  rw [step_class_fields_eq F s v (R.a a) members' (R.env env) fs hc hf] at run
  exact fieldsNext_private_heap_other F {s with stack := fs} result C D (R.a a) members' (R.env env)
    (hm.private_target onlyPrivate) (Nat.lt_of_lt_of_le (h.heap.targetBound a ha) bound) run m other

/-- Initializer return writes its receiver and then executes the remaining
private field scheduler, framing every distinct address. -/
theorem step_private_initializer_heap_other (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (a brand : Nat) (name : Name) (o₀ : Obj) (members : List InstMember) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.privVal a brand name members env)::fs₀)
    (onlyPrivate : PrivateFields members) (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .ordinary)
    (bound : s.next ≤ 2^64) (run : interpC (step F s).run C = some (result,D))
    (m : Nat) (other : m ≠ R.a a) : result.heap.get m = s.heap.get m := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨members',hframe,hm⟩ := hfr.privateInitializer_view
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha : live a := hl.1.1.1
  obtain ⟨o,ho,_,_⟩ := h.heap.readOrdinary a o₀ ha ho₀ hk₀
  rw [step_private_initializer_eq F s (R.a a) (R.a brand) name members' (R.env env) fs o v hc hf ho] at run
  have addressBound := Nat.lt_of_lt_of_le (h.heap.targetBound a ha) bound
  have hh := fieldsNext_private_heap_other F _ result C D (R.a a) members' (R.env env)
    (hm.private_target onlyPrivate) addressBound run m other
  exact hh.trans (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ addressBound,ite_eq_right other])

theorem baseClassEntry_heap_below {S : Type} (s : St S) (ctor : Func) (env : Env)
    (members : List InstMember) (args : List Val) (proto m : Nat)
    (below : m < s.next) (bound : s.next+2 ≤ 2^64) :
    (baseClassEntry s ctor env members args proto).heap.get m = s.heap.get m := by
  let object : HObj := .obj ⟨.ordinary,.obj proto,[],[],true⟩
  have first := alloc_heap_below s object m below (by omega)
  have second := alloc_heap_below (s.alloc object).2 (.cell (some (.obj s.next))) m
    (by change m < s.next+1; omega) (by change s.next+1 < 2^64; omega)
  exact second.trans first

theorem step_base_class_heap_below (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a proto : Nat) (o : Obj) (ctor : Func) (env : Env) (members : List InstMember)
    (args₀ : List Val) (w e : Bool)
    (hc₀ : s₀.ctl = .construct (.obj a) args₀ (.obj a))
    (ho₀ : s₀.heap.get a = some (.obj o)) (hk₀ : o.kind = .fn (.klass (some ctor) env .null members))
    (hp₀ : findProp kPrototype o.props = some (.data (.obj proto) w e))
    (sourceBound : s₀.next+2 ≤ 2^64) (targetBound : s.next+2 ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) :
    ∀ m, m < s.next → result.heap.get m = s.heap.get m := by
  obtain ⟨args,members',_,_,hr,_⟩ := step_base_class_entry_from_source F NR FR R C₀ C live framed before after old old'
    s₀ s h a proto o ctor env members args₀ w e hc₀ ho₀ hk₀ hp₀ sourceBound targetBound
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  dsimp only at he
  rw [he]
  exact fun m below => baseClassEntry_heap_below s ctor (R.env env) members' args (R.a proto) m below targetBound

theorem step_constructor_body_heap_below (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ receiver₀ : Val) (fn : Func) (env : Env) (args₀ : List Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.ctorBody receiver₀ fn env args₀)::fs₀)
    (bound : s.next+2+(paramNames fn).length ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) :
    ∀ m, m < s.next → result.heap.get m = s.heap.get m := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨receiver,args,hframe,_,_⟩ := hfr.constructorBody_view
  rw [hframe] at hf
  rw [step_constructor_body_eq F s v receiver fn (R.env env) args fs hc hf] at run
  exact enterClosure_heap_below F {s with stack := fs} result C D fn (R.env env) false .undef receiver args
    (.ctor receiver) bound run

theorem step_private_store_heap_other (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (oldTrace oldTrace' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after oldTrace oldTrace' s₀ s)
    (a brand : Nat) (name : Name) (v₀ prior₀ old : Val) (e : Bool) (o₀ : Obj) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .a (.put none (.priv (.obj a) brand name) prior₀)::fs₀)
    (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .ordinary)
    (hp : findPriv brand name o₀.priv = some (.data old true e))
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) (m : Nat) (other : m ≠ R.a a) :
    result.heap.get m = s.heap.get m := by
  obtain ⟨v,o,fs,_,_,hr,_⟩ := step_private_store_from_source F NR FR R C₀ C live framed before after oldTrace oldTrace'
    s₀ s h a brand name v₀ prior₀ old e o₀ fs₀ hc₀ hf₀ ho hk hp sourceBound targetBound
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  dsimp only at he
  rw [he]
  have hl := h.stackLive
  rw [hf₀] at hl
  have ha : live a := hl.1.1.2.1.1
  simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ (Nat.lt_of_lt_of_le (h.heap.targetBound a ha) targetBound),ite_eq_right other]

theorem step_empty_object_heap_below (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (env : Env) (hc₀ : s₀.ctl = .ev (.object []) env) (bound : s.next < 2^64)
    (run : interpC (step F s).run C = some (result,D)) :
    ∀ m, m < s.next → result.heap.get m = s.heap.get m := by
  have hc := (h.control_view hc₀).ev_view
  rw [step_empty_object_eq F s (R.env env) hc] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [← he]
  exact fun m below => alloc_heap_below s _ m below bound

end Host.Ts.Owned.Parametric
