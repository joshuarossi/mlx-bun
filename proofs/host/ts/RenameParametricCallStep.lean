import host.ts.RenameParametricCalls

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem vals_support_of {live : Nat → Prop} (xs : List Val) (h : treeSupport live (Encode.vals xs)) :
    listSupport (valueSupport live) xs := by
  induction xs with
  | nil => exact True.intro
  | cons v vs ih => exact ⟨h.1,ih h.2⟩

theorem env_eq_map {NR : NumV → NumV → Prop} {R : Ren} {env env' : Env}
    (h : TreeR NR R (Encode.env env) (Encode.env env')) : env' = R.env env := by
  induction env generalizing env' with
  | nil => cases env' with
    | nil => rfl
    | cons x xs => cases h with | node tag hs => cases hs
  | cons x xs ih =>
    obtain ⟨name,a⟩ := x
    cases env' with
    | nil => cases h with | node tag hs => cases hs
    | cons y ys =>
      obtain ⟨name',a'⟩ := y
      cases h with | node tag hs =>
        cases hs with | cons head tail =>
          cases head with | node tag hs =>
            cases hs with | cons hn hs =>
              cases hs with | cons ha hs =>
                cases hn
                cases ha
                have ht := ih (.node _ tail)
                simpa only [Ren.env,List.map_cons] using congrArg ((name,R.a a)::·) ht

private def tag (t : Tree) : String := match t with | .node n _ => n | _ => ""
private theorem tag_eq {NR : NumV → NumV → Prop} {R : Ren} {a b : Tree} (h : TreeR NR R a b) :
    tag a = tag b := by cases h <;> rfl

theorem kind_closure {NR : NumV → NumV → Prop} {R : Ren} {f : Func} {env : Env}
    {arrow : Bool} {home : Val} {k : Kind}
    (h : TreeR NR R (Encode.kind (.fn (.closure f env arrow home))) (Encode.kind k)) :
    ∃ home', k = .fn (.closure f (R.env env) arrow home') ∧ ValueR NR R home home' := by
  have ht := tag_eq h
  cases k <;> simp only [Encode.kind,tag] at ht
  all_goals try contradiction
  case fn c =>
    cases h with | node tag hs =>
      cases hs with | cons hc hs =>
        have ht := tag_eq hc
        cases c <;> simp only [Encode.code,tag] at ht
        all_goals try contradiction
        case closure f' env' arrow' home' =>
          cases hc with | node tag hs =>
            cases hs with | cons hf hs =>
              cases hs with | cons he hs =>
                cases hs with | cons ha hs =>
                  cases hs with | cons hh hs =>
                    cases hf
                    cases ha
                    cases hh with | value hv =>
                      obtain rfl := env_eq_map he
                      exact ⟨_,rfl,hv⟩

def ClosureLive (live : Nat → Prop) (start : Nat) (arrow : Bool) (home : Val) (f : Func) : Nat → Prop :=
  if arrow then CellsLive live start (paramNames f) else
    match home with
    | .undef => CellsLive (LiveAfter live start) (start+1) (paramNames f)
    | _ => CellsLive (LiveAfter (LiveAfter live start) (start+1)) (start+2) (paramNames f)

theorem step_closure_eq (F : Ffi) (s : St F.S) (a : Nat) (o : Obj) (f : Func) (env : Env)
    (arrow : Bool) (home this : Val) (args : List Val)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.heap.get a = some (.obj o))
    (hk : o.kind = .fn (.closure f env arrow home)) :
    step F s = enterClosure F s f env arrow home this args .call := by
  simp only [step,hc,callStep,St.obj?,ho,hk]

/-- Actual JS closure dispatch obtains the target closure and its captured
environment from the live heap, then executes entry on both sides. -/
theorem step_closure_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (f : Func) (env : Env) (arrow : Bool) (home₀ this₀ this : Val) (args₀ args : List Val)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ args₀)
    (hc : s.ctl = .call (.obj (R.a a)) this args)
    (ha : live a) (hn : ¬ framed a) (ho : s₀.heap.get a = some (.obj o₀))
    (hk : o₀.kind = .fn (.closure f env arrow home₀))
    (hrthis : ValueR NR R this₀ this) (hrargs : ListR (ValueR NR R) args₀ args)
    (hs : s₀.next + 2 + (paramNames f).length ≤ 2^64)
    (ht : s.next + 2 + (paramNames f).length ≤ 2^64) :
    ∃ result₀ result, interpC (step F s₀).run C₀ = some (result₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R (ClosureLive live s₀.next arrow home₀ f) framed before after old old' result₀ result := by
  obtain ⟨o,ho',hr,hl⟩ := h.heap.readObject a o₀ ha hn ho
  have hkind := hr.kind
  rw [hk] at hkind
  obtain ⟨home,hk',hhome⟩ := kind_closure hkind
  have hkl : treeSupport live (Encode.kind (.fn (.closure f env arrow home₀))) := by
    simpa only [hk] using hl.1
  have henv : treeSupport live (Encode.env env) := hkl.1.2.1
  have hhomel : valueSupport live home₀ := hkl.1.2.2.2.1
  have hcl := h.controlLive
  rw [hc₀] at hcl
  have hthisl : valueSupport live this₀ := hcl.2.1
  have hargsl : listSupport (valueSupport live) args₀ := vals_support_of _ hcl.2.2.1
  rw [step_closure_eq F s₀ a o₀ f env arrow home₀ this₀ args₀ hc₀ ho hk,
    step_closure_eq F s (R.a a) o f (R.env env) arrow home this args hc ho' hk']
  cases arrow
  · by_cases homeEq : home₀ = .undef
    · subst home₀
      have homeEq' := hhome.undef_iff.mp rfl
      subst home
      exact enterClosure_plain_roles F NR FR R C₀ C live framed before after old old' s₀ s h f env
        this₀ this args₀ args .call .call hrthis hthisl (.node _ .nil) hrargs True.intro hargsl henv (by omega) (by omega)
    · have result := enterClosure_home_roles F NR FR R C₀ C live framed before after old old' s₀ s h f env
        home₀ home this₀ this args₀ args .call .call hhome homeEq hhomel hrthis hthisl
        (.node _ .nil) hrargs True.intro hargsl henv hs ht
      cases home₀ <;> first | exact False.elim (homeEq rfl) | exact result
  · exact enterClosure_arrow_roles F NR FR R C₀ C live framed before after old old' s₀ s h f env
      home₀ home this₀ this args₀ args .call .call (.node _ .nil) hrargs True.intro hargsl henv (by omega) (by omega)

theorem vals_roles_of {NR : NumV → NumV → Prop} {R : Ren} {xs ys : List Val}
    (h : TreeR NR R (Encode.vals xs) (Encode.vals ys)) : ListR (ValueR NR R) xs ys := by
  induction xs generalizing ys with
  | nil => cases ys with
    | nil => exact .nil
    | cons v vs => cases h with | node tag hs => cases hs
  | cons v vs ih => cases ys with
    | nil => cases h with | node tag hs => cases hs
    | cons w ws => cases h with | node tag hs =>
      cases hs with | cons hv ht =>
        cases hv with | value hv => exact .cons hv (ih (.node _ ht))

theorem call_arguments {NR : NumV → NumV → Prop} {R : Ren} {f₀ f this₀ this : Val} {args₀ args : List Val}
    (h : ControlR NR R (.call f₀ this₀ args₀) (.call f this args)) :
    ValueR NR R this₀ this ∧ ListR (ValueR NR R) args₀ args := by
  cases h with | node tag hs =>
    cases hs with | cons hf hs =>
      cases hs with | cons ht hs =>
        cases hs with | cons ha hs =>
          cases ht with | value ht => exact ⟨ht,vals_roles_of ha⟩

theorem HeapR.function_notFramed {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (h : HeapR NR R live framed before after s₀ s) (a : Nat) (o : Obj) (code : Code)
    (ha : live a) (ho : s₀.heap.get a = some (.obj o)) (hk : o.kind = .fn code) : ¬ framed a := by
  have hr := h.lookup a ha
  rw [ho] at hr
  generalize hh : s.heap.get (R.a a) = target at hr
  cases hr with
  | regular hf => exact hf
  | framed hf hk₀ => rw [hk] at hk₀; cases hk₀

theorem step_closure_from_state (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (f : Func) (env : Env) (arrow : Bool) (home₀ this₀ this : Val) (args₀ args : List Val)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ args₀) (hc : s.ctl = .call (.obj (R.a a)) this args)
    (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .fn (.closure f env arrow home₀))
    (hs : s₀.next + 2 + (paramNames f).length ≤ 2^64) (ht : s.next + 2 + (paramNames f).length ≤ 2^64) :
    ∃ result₀ result, interpC (step F s₀).run C₀ = some (result₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R (ClosureLive live s₀.next arrow home₀ f) framed before after old old' result₀ result := by
  have hcR := h.control
  rw [hc₀,hc] at hcR
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have hv := call_arguments hcR
  exact step_closure_roles F NR FR R C₀ C live framed before after old old' s₀ s h a o₀ f env arrow
    home₀ this₀ this args₀ args hc₀ hc ha (h.heap.function_notFramed a o₀ _ ha ho hk) ho hk hv.1 hv.2 hs ht

end Host.Ts.Owned.Parametric
