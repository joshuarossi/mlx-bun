import host.ts.RenameParametricDefaults
import host.ts.RenameParametricViews

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem step_parameter_id_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (f : Func) (name : Name) (ps : List Pat) (args₀ : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.params f (.id name::ps) args₀ env)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ = some (parameterArgument {s₀ with stack := fs₀} f name ps args₀ env,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (parameterArgument {s₀ with stack := fs₀} f name ps args₀ env) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨frame,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨args,hfe,_⟩ := hfr.params_view
  rw [hfe] at hf
  exact ⟨_,step_parameter_id_roles F NR FR R C₀ C live framed before after old old' s₀ s h
    v₀ v f name ps args₀ args env fs₀ fs hc₀ hc hf₀ hf⟩

theorem step_parameter_default_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (f : Func) (p : Pat) (d : Expr) (ps : List Pat) (args₀ : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.params f (.dflt p d::ps) args₀ env)::fs₀)
    (hv₀ : nthD .undef args₀ 0 = .undef) :
    ∃ result, interpC (step F s₀).run C₀ = some (parameterDefault {s₀ with stack := fs₀} f p d ps args₀ env,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (parameterDefault {s₀ with stack := fs₀} f p d ps args₀ env) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨frame,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨args,hfe,_⟩ := hfr.params_view
  rw [hfe] at hf
  exact ⟨_,step_parameter_default_roles F NR FR R C₀ C live framed before after old old' s₀ s h
    v₀ v f p d ps args₀ args env fs₀ fs hc₀ hc hf₀ hf hv₀⟩

theorem FrameR.paramDefault_view {NR : NumV → NumV → Prop} {R : Ren}
    {fn : Func} {p : Pat} {ps : List Pat} {args : List Val} {env : Env} {f : Frame}
    (h : FrameR NR R (.k (.paramDflt fn p ps args env)) f) :
    ∃ args', f = .k (.paramDflt fn p ps args' (R.env env)) ∧ ListR (ValueR NR R) args args' := by
  obtain ⟨fn',rfl,hh⟩ := h.k_view
  have ht := hh.tag_eq
  cases fn' <;> simp only [Encode.fnF,treeTag] at ht
  all_goals try contradiction
  case paramDflt fn' p' ps' args' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hf hs =>
        cases hs with | cons hp hs =>
          cases hs with | cons hps hs =>
            cases hs with | cons ha hs =>
              cases hs with | cons he hs =>
                cases hf; cases hp; cases hps
                obtain rfl := env_eq_map he
                exact ⟨args',rfl,vals_roles_of ha⟩

theorem step_parameter_default_return_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (f : Func) (p : Pat) (ps : List Pat) (args₀ : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.paramDflt f p ps args₀ env)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (parameterDefaultReturn {s₀ with stack := fs₀} f p ps args₀ env v₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (parameterDefaultReturn {s₀ with stack := fs₀} f p ps args₀ env v₀) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨frame,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨args,hfe,_⟩ := hfr.paramDefault_view
  rw [hfe] at hf
  exact ⟨_,step_parameter_default_return_roles F NR FR R C₀ C live framed before after old old' s₀ s h
    v₀ v f p ps args₀ args env fs₀ fs hc₀ hc hf₀ hf⟩

theorem step_parameter_body_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (name : Option Name) (params : List Pat) (ss : List Stmt)
    (args₀ : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .k (.params (.mk name params none (.block ss) false false []) [] args₀ env)::fs₀)
    (hi : noInitFunctions ss = true)
    (hs : s₀.next + (blockNames ss).length ≤ 2^64) (ht : s.next + (blockNames ss).length ≤ 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some (enterBlock {s₀ with stack := fs₀} ss env,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R (CellsLive live s₀.next (blockNames ss)) framed before after old old'
        (enterBlock {s₀ with stack := fs₀} ss env) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨frame,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨args,hfe,_⟩ := hfr.params_view
  rw [hfe] at hf
  exact ⟨_,step_parameter_body_roles F NR FR R C₀ C live framed before after old old' s₀ s h
    v₀ v name params ss args₀ args env fs₀ fs hc₀ hc hf₀ hf hi hs ht⟩

end Host.Ts.Owned.Parametric
