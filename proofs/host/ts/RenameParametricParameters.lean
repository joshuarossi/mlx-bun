import host.ts.RenameParametricHoist

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem env_lookup_live {live : Nat → Prop} (name : Name) (env : Env) (a : Nat)
    (hl : treeSupport live (Encode.env env)) (he : lookupEnv name env = some a) : live a := by
  induction env with
  | nil => cases he
  | cons p rest ih =>
    obtain ⟨n,b⟩ := p
    change (True ∧ live b ∧ True) ∧ treeSupport live (Encode.env rest) at hl
    change brec (Nat.beq (pack name) (pack n)) (some b) (lookupEnv name rest) = some a at he
    cases hb : Nat.beq (pack name) (pack n) <;> rw [hb] at he
    · exact ih hl.2 he
    · have hba : b = a := Option.some.inj he
      exact hba ▸ hl.1.2.1

theorem HeapR.cell_notFramed {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (h : HeapR NR R live framed before after s₀ s) (a : Nat) (v : Option Val)
    (ha : live a) (ho : s₀.heap.get a = some (.cell v)) : ¬ framed a := by
  have hr := h.lookup a ha
  rw [ho] at hr
  generalize hh : s.heap.get (R.a a) = target at hr
  cases hr with | regular hf => exact hf

theorem step_bind_init_eq (F : Ffi) (s : St F.S) (name : Name) (v : Val) (env : Env)
    (kind : DeclKind) (a : Nat) (hc : s.ctl = .bind (.id name) v env .init kind)
    (he : lookupEnv name env = some a) : step F s = M.pure ((s.setCell a v).ret .undef) := by
  simp only [step,hc,bindStep,he,retS]

/-- Parameter and lexical initialization uses the actual environment lookup
and cell store, deriving target lookup and preserving all other live cells. -/
theorem step_bind_init_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (v₀ v : Val) (env : Env) (kind : DeclKind) (a : Nat) (prior : Option Val)
    (hc₀ : s₀.ctl = .bind (.id name) v₀ env .init kind)
    (hc : s.ctl = .bind (.id name) v (R.env env) .init kind)
    (he : lookupEnv name env = some a) (ho : s₀.heap.get a = some (.cell prior))
    (hs : s₀.next ≤ 2^64) (ht : s.next ≤ 2^64) :
    interpC (step F s₀).run C₀ = some ((s₀.setCell a v₀).ret .undef,C₀) ∧
    interpC (step F s).run C = some ((s.setCell (R.a a) v).ret .undef,C) ∧
    StateR NR FR R live framed before after old old'
      ((s₀.setCell a v₀).ret .undef) ((s.setCell (R.a a) v).ret .undef) := by
  have hcl := h.controlLive
  rw [hc₀] at hcl
  have ha := env_lookup_live name env a hcl.2.2.1 he
  have hn := h.heap.cell_notFramed a prior ha ho
  have hv : ValueR NR R v₀ v := by
    have hr := h.control
    rw [hc₀,hc] at hr
    cases hr with | node tag hs =>
      cases hs with | cons hp hs =>
        cases hs with | cons hv hs =>
          cases hv with | value hv => exact hv
  have hsb : a < 2^64 := Nat.lt_of_lt_of_le (h.heap.sourceBound a ha) hs
  have htb : R.a a < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound a ha) ht
  have he' : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,he]; rfl
  refine ⟨?_,?_,(h.setCell a v₀ v ha hn hv hcl.2.1 hsb htb).go
    (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩⟩
  · rw [step_bind_init_eq F s₀ name v₀ env kind a hc₀ he]; rfl
  · rw [step_bind_init_eq F s name v (R.env env) kind (R.a a) hc he']; rfl

theorem parameter_args_roles {NR : NumV → NumV → Prop} {R : Ren} {args₀ args : List Val}
    (h : ListR (ValueR NR R) args₀ args) :
    ValueR NR R (nthD .undef args₀ 0) (nthD .undef args 0) ∧ ListR (ValueR NR R) args₀.tail args.tail := by
  cases h with
  | nil => exact ⟨.undef,.nil⟩
  | cons hv hs => exact ⟨hv,hs⟩

theorem parameter_args_live {live : Nat → Prop} (args : List Val)
    (h : listSupport (valueSupport live) args) :
    valueSupport live (nthD .undef args 0) ∧ listSupport (valueSupport live) args.tail := by
  cases args with
  | nil => exact ⟨True.intro,True.intro⟩
  | cons v vs => exact h

def parameterArgument {S : Type} (s : St S) (f : Func) (name : Name) (ps : List Pat) (args : List Val) (env : Env) : St S :=
  (s.push (.k (.params f ps args.tail env))).go (.bind (.id name) (nthD .undef args 0) env .init .let_)

theorem step_parameter_id_eq (F : Ffi) (s : St F.S) (v : Val) (f : Func) (name : Name)
    (ps : List Pat) (args : List Val) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .k (.params f (.id name::ps) args env)::fs) :
    step F s = M.pure (parameterArgument {s with stack := fs} f name ps args env) := by
  simp only [step,hc,stepRet,hf,retStep,retK,paramsNext,parameterArgument]

theorem step_parameter_id_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v : Val) (f : Func) (name : Name) (ps : List Pat) (args₀ args : List Val) (env : Env) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .k (.params f (.id name::ps) args₀ env)::fs₀)
    (hf : s.stack = .k (.params f (.id name::ps) args (R.env env))::fs) :
    interpC (step F s₀).run C₀ = some (parameterArgument {s₀ with stack := fs₀} f name ps args₀ env,C₀) ∧
    interpC (step F s).run C = some (parameterArgument {s with stack := fs} f name ps args (R.env env),C) ∧
    StateR NR FR R live framed before after old old'
      (parameterArgument {s₀ with stack := fs₀} f name ps args₀ env)
      (parameterArgument {s with stack := fs} f name ps args (R.env env)) := by
  have hfs := h.stack
  rw [hf₀,hf] at hfs
  have hfl := h.stackLive
  rw [hf₀] at hfl
  cases hfs with | cons hhead htail =>
    have hargs : ListR (ValueR NR R) args₀ args := by
      cases hhead with | node tag hs =>
        cases hs with | cons hp hs =>
          cases hp with | node tag hs =>
            cases hs with | cons hf hs =>
              cases hs with | cons hps hs =>
                cases hs with | cons ha hs => exact vals_roles_of ha
    have hargl : listSupport (valueSupport live) args₀ := vals_support_of _ hfl.1.1.2.2.1
    have hel : treeSupport live (Encode.env env) := hfl.1.1.2.2.2.1
    have hfirst := parameter_args_roles hargs
    have hfirstl := parameter_args_live args₀ hargl
    have hparam : FrameR NR R (.k (.params f ps args₀.tail env)) (.k (.params f ps args.tail (R.env env))) :=
      .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _)
        (.cons (vals_roles hfirst.2) (.cons (env_roles NR R _) .nil))))) .nil)
    have hparaml : treeSupport live (Encode.frame (.k (.params f ps args₀.tail env))) :=
      ⟨⟨True.intro,True.intro,vals_support _ hfirstl.2,hel,True.intro⟩,True.intro⟩
    have hh := h.restack (.cons hparam htail) ⟨hparaml,hfl.2⟩
    refine ⟨?_,?_,hh.go (.node _ (.cons (.atom _ _) (.cons (.value hfirst.1)
      (.cons (env_roles NR R _) (.cons (.atom _ _) (.cons (.atom _ _) .nil))))))
      ⟨True.intro,hfirstl.1,hel,True.intro,True.intro,True.intro⟩⟩
    · rw [step_parameter_id_eq F s₀ v₀ f name ps args₀ env fs₀ hc₀ hf₀]; rfl
    · rw [step_parameter_id_eq F s v f name ps args (R.env env) fs hc hf]; rfl

end Host.Ts.Owned.Parametric
