import host.ts.RenameParametricArguments

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem FrameR.decl_view {NR : NumV → NumV → Prop} {R : Ren}
    {kind : DeclKind} {p : Pat} {rest : List (Pat × Option Expr)} {env : Env} {f : Frame}
    (h : FrameR NR R (.s (.decl kind p rest env)) f) :
    f = .s (.decl kind p rest (R.env env)) := by
  obtain ⟨st',rfl,hh⟩ := h.s_view
  have ht := hh.tag_eq
  cases st' <;> simp only [Encode.stmtF,treeTag] at ht
  all_goals try contradiction
  case decl kind' p' rest' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hk hs =>
        cases hs with | cons hp hs =>
          cases hs with | cons hr hs =>
            cases hs with | cons he hs =>
              cases hk
              cases hp
              cases hr
              obtain rfl := env_eq_map he
              rfl

theorem FrameR.declNext_view {NR : NumV → NumV → Prop} {R : Ren}
    {kind : DeclKind} {rest : List (Pat × Option Expr)} {env : Env} {f : Frame}
    (h : FrameR NR R (.s (.declNext kind rest env)) f) :
    f = .s (.declNext kind rest (R.env env)) := by
  obtain ⟨st',rfl,hh⟩ := h.s_view
  have ht := hh.tag_eq
  cases st' <;> simp only [Encode.stmtF,treeTag] at ht
  all_goals try contradiction
  case declNext kind' rest' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hk hs =>
        cases hs with | cons hr hs =>
          cases hs with | cons he hs =>
            cases hk
            cases hr
            obtain rfl := env_eq_map he
            rfl

def declarationValue {S : Type} (s : St S) (kind : DeclKind) (p : Pat)
    (rest : List (Pat × Option Expr)) (env : Env) (v : Val) : St S :=
  (s.push (.s (.declNext kind rest env))).go (.bind p v env .init kind)

theorem step_declaration_value_eq (F : Ffi) (s : St F.S) (v : Val) (kind : DeclKind)
    (p : Pat) (rest : List (Pat × Option Expr)) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .s (.decl kind p rest env)::fs)
    (hk : isUsing kind = false) :
    step F s = M.pure (declarationValue {s with stack := fs} kind p rest env v) := by
  simp only [step,hc,stepRet,hf,retStep,retSt,hk,Bool.cond_false,declarationValue]
  rfl

theorem step_declaration_value_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ : Val)
    (kind : DeclKind) (p : Pat) (rest : List (Pat × Option Expr)) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.decl kind p rest env)::fs₀)
    (hk : isUsing kind = false) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (declarationValue {s₀ with stack := fs₀} kind p rest env v₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (declarationValue {s₀ with stack := fs₀} kind p rest env v₀) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.decl_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.1
  have hvl := (h.return_values v₀ v hc₀ hc).2
  have hnew : FrameR NR R (.s (.declNext kind rest env)) (.s (.declNext kind rest (R.env env))) :=
    .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _) (.cons (env_roles NR R env) .nil)))) .nil)
  have hnewl : treeSupport live (Encode.frame (.s (.declNext kind rest env))) :=
    ⟨⟨True.intro,True.intro,hel,True.intro⟩,True.intro⟩
  refine ⟨declarationValue {s with stack := fs} kind p rest (R.env env) v,?_,?_,
    (h.restack (.cons hnew hfs) ⟨hnewl,hl.2⟩).go
      (.node _ (.cons (.atom _ _) (.cons (.value hv) (.cons (env_roles NR R env)
        (.cons (.atom _ _) (.cons (.atom _ _) .nil))))))
      ⟨True.intro,hvl,hel,True.intro,True.intro,True.intro⟩⟩
  · rw [step_declaration_value_eq F s₀ v₀ kind p rest env fs₀ hc₀ hf₀ hk]; rfl
  · rw [step_declaration_value_eq F s v kind p rest (R.env env) fs hc hf hk]; rfl

def declarationAction (kind : DeclKind) : List (Pat × Option Expr) → StatementAction
  | [] => .declarationEmpty kind
  | (p,some e)::rest => .declarationInit kind p e rest
  | (p,none)::rest => .declarationUndef kind p rest

theorem declNext_action_eq (F : Ffi) (s : St F.S) (kind : DeclKind)
    (rest : List (Pat × Option Expr)) (env : Env) :
    declNext F s kind rest env = M.pure ((declarationAction kind rest).advance s env) := by
  cases rest with
  | nil => rfl
  | cons p rest => obtain ⟨p,e⟩ := p; cases e <;> rfl

theorem step_declaration_next_eq (F : Ffi) (s : St F.S) (v : Val) (kind : DeclKind)
    (rest : List (Pat × Option Expr)) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .s (.declNext kind rest env)::fs) :
    step F s = M.pure ((declarationAction kind rest).advance {s with stack := fs} env) := by
  simp only [step,hc,stepRet,hf,retStep,retSt]
  exact declNext_action_eq F _ kind rest env

theorem step_declaration_next_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ : Val)
    (kind : DeclKind) (rest : List (Pat × Option Expr)) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.declNext kind rest env)::fs₀) :
    ∃ fs, interpC (step F s₀).run C₀ =
        some ((declarationAction kind rest).advance {s₀ with stack := fs₀} env,C₀) ∧
      interpC (step F s).run C =
        some ((declarationAction kind rest).advance {s with stack := fs} (R.env env),C) ∧
      StateR NR FR R live framed before after old old'
        ((declarationAction kind rest).advance {s₀ with stack := fs₀} env)
        ((declarationAction kind rest).advance {s with stack := fs} (R.env env)) := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.declNext_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.1
  refine ⟨fs,?_,?_,(declarationAction kind rest).advance_roles (h.restack hfs hl.2) env hel⟩
  · rw [step_declaration_next_eq F s₀ v₀ kind rest env fs₀ hc₀ hf₀]; rfl
  · rw [step_declaration_next_eq F s v kind rest (R.env env) fs hc hf]; rfl

end Host.Ts.Owned.Parametric
