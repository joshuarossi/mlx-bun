import host.ts.RenameParametricReturns

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

def treeTag (t : Tree) : String := match t with | .node n _ => n | _ => ""

theorem TreeR.tag_eq {NR : NumV → NumV → Prop} {R : Ren} {a b : Tree}
    (h : TreeR NR R a b) : treeTag a = treeTag b := by cases h <;> rfl

theorem ControlR.ev_view {NR : NumV → NumV → Prop} {R : Ren}
    {e : Expr} {env : Env} {c : Ctl} (h : ControlR NR R (.ev e env) c) :
    c = .ev e (R.env env) := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals try contradiction
  case ev e' env' =>
    cases h with | node tag hs =>
      cases hs with | cons he hs =>
        cases hs with | cons henv hs =>
          cases he
          obtain rfl := env_eq_map henv
          rfl

theorem ControlR.ex_view {NR : NumV → NumV → Prop} {R : Ren}
    {st : Stmt} {env : Env} {c : Ctl} (h : ControlR NR R (.ex st env) c) :
    c = .ex st (R.env env) := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals try contradiction
  case ex st' env' =>
    cases h with | node tag hs =>
      cases hs with | cons hst hs =>
        cases hs with | cons henv hs =>
          cases hst
          obtain rfl := env_eq_map henv
          rfl

theorem ControlR.ret_view {NR : NumV → NumV → Prop} {R : Ren}
    {v : Val} {c : Ctl} (h : ControlR NR R (.ret v) c) :
    ∃ v', c = .ret v' ∧ ValueR NR R v v' := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals try contradiction
  case ret v' =>
    cases h with | node tag hs =>
      cases hs with | cons hv hs =>
        cases hv with | value hv => exact ⟨v',rfl,hv⟩

theorem ControlR.abr_view {NR : NumV → NumV → Prop} {R : Ren}
    {a : Abrupt} {c : Ctl} (h : ControlR NR R (.abr a) c) :
    ∃ a', c = .abr a' ∧ TreeR NR R (Encode.abr a) (Encode.abr a') := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals try contradiction
  case abr a' =>
    cases h with | node tag hs =>
      cases hs with | cons ha hs => exact ⟨a',rfl,ha⟩

theorem ControlR.call_view {NR : NumV → NumV → Prop} {R : Ren}
    {f this : Val} {args : List Val} {c : Ctl} (h : ControlR NR R (.call f this args) c) :
    ∃ f' this' args', c = .call f' this' args' ∧ ValueR NR R f f' ∧
      ValueR NR R this this' ∧ ListR (ValueR NR R) args args' := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals try contradiction
  case call f' this' args' =>
    cases h with | node tag hs =>
      cases hs with | cons hf hs =>
        cases hs with | cons hthis hs =>
          cases hs with | cons hargs hs =>
            cases hf with | value hf =>
              cases hthis with | value hthis => exact ⟨f',this',args',rfl,hf,hthis,vals_roles_of hargs⟩

theorem ControlR.construct_view {NR : NumV → NumV → Prop} {R : Ren}
    {f nt : Val} {args : List Val} {c : Ctl} (h : ControlR NR R (.construct f args nt) c) :
    ∃ f' args' nt', c = .construct f' args' nt' ∧ ValueR NR R f f' ∧
      ListR (ValueR NR R) args args' ∧ ValueR NR R nt nt' := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals try contradiction
  case construct f' args' nt' =>
    cases h with | node tag hs =>
      cases hs with | cons hf hs =>
        cases hs with | cons hargs hs =>
          cases hs with | cons hnt hs =>
            cases hf with | value hf =>
              cases hnt with | value hnt => exact ⟨f',args',nt',rfl,hf,vals_roles_of hargs,hnt⟩

theorem ControlR.bind_view {NR : NumV → NumV → Prop} {R : Ren}
    {p : Pat} {v : Val} {env : Env} {mode : BindMode} {kind : DeclKind} {c : Ctl}
    (h : ControlR NR R (.bind p v env mode kind) c) :
    ∃ v', c = .bind p v' (R.env env) mode kind ∧ ValueR NR R v v' := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals try contradiction
  case bind p' v' env' mode' kind' =>
    cases h with | node tag hs =>
      cases hs with | cons hp hs =>
        cases hs with | cons hv hs =>
          cases hs with | cons he hs =>
            cases hs with | cons hm hs =>
              cases hs with | cons hk hs =>
                cases hp
                cases hm
                cases hk
                obtain rfl := env_eq_map he
                cases hv with | value hv => exact ⟨v',rfl,hv⟩

theorem ControlR.short_view {NR : NumV → NumV → Prop} {R : Ren}
    {c : Ctl} (h : ControlR NR R .short c) : c = .short := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals first | contradiction | rfl

theorem ControlR.halt_view {NR : NumV → NumV → Prop} {R : Ren}
    {a : Comp} {c : Ctl} (h : ControlR NR R (.halt a) c) :
    ∃ a', c = .halt a' ∧ TreeR NR R (Encode.comp a) (Encode.comp a') := by
  have ht := h.tag_eq
  cases c <;> simp only [Encode.ctl,treeTag] at ht
  all_goals try contradiction
  case halt a' =>
    cases h with | node tag hs =>
      cases hs with | cons ha hs => exact ⟨a',rfl,ha⟩

theorem frames_cons_view {NR : NumV → NumV → Prop} {R : Ren}
    {f : Frame} {fs target : List Frame} (h : ListR (FrameR NR R) (f::fs) target) :
    ∃ f' fs', target = f'::fs' ∧ FrameR NR R f f' ∧ ListR (FrameR NR R) fs fs' := by
  cases h with | cons hf ht => exact ⟨_,_,rfl,hf,ht⟩

theorem FrameR.k_view {NR : NumV → NumV → Prop} {R : Ren}
    {fn : FnF} {f : Frame} (h : FrameR NR R (.k fn) f) :
    ∃ fn', f = .k fn' ∧ TreeR NR R (Encode.fnF fn) (Encode.fnF fn') := by
  have ht := h.tag_eq
  cases f <;> simp only [Encode.frame,treeTag] at ht
  all_goals try contradiction
  case k fn' =>
    cases h with | node tag hs =>
      cases hs with | cons hh hs => exact ⟨fn',rfl,hh⟩

theorem FrameR.s_view {NR : NumV → NumV → Prop} {R : Ren}
    {st : StmtF} {f : Frame} (h : FrameR NR R (.s st) f) :
    ∃ st', f = .s st' ∧ TreeR NR R (Encode.stmtF st) (Encode.stmtF st') := by
  have ht := h.tag_eq
  cases f <;> simp only [Encode.frame,treeTag] at ht
  all_goals try contradiction
  case s st' =>
    cases h with | node tag hs =>
      cases hs with | cons hh hs => exact ⟨st',rfl,hh⟩

theorem FrameR.params_view {NR : NumV → NumV → Prop} {R : Ren}
    {fn : Func} {ps : List Pat} {args : List Val} {env : Env} {f : Frame}
    (h : FrameR NR R (.k (.params fn ps args env)) f) :
    ∃ args', f = .k (.params fn ps args' (R.env env)) ∧ ListR (ValueR NR R) args args' := by
  obtain ⟨fn',rfl,hh⟩ := h.k_view
  have ht := hh.tag_eq
  cases fn' <;> simp only [Encode.fnF,treeTag] at ht
  all_goals try contradiction
  case params fn' ps' args' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hfn hs =>
        cases hs with | cons hps hs =>
          cases hs with | cons hargs hs =>
            cases hs with | cons henv hs =>
              cases hfn
              cases hps
              obtain rfl := env_eq_map henv
              exact ⟨args',rfl,vals_roles_of hargs⟩

theorem FrameR.paramDflt_view {NR : NumV → NumV → Prop} {R : Ren}
    {fn : Func} {p : Pat} {ps : List Pat} {args : List Val} {env : Env} {f : Frame}
    (h : FrameR NR R (.k (.paramDflt fn p ps args env)) f) :
    ∃ args', f = .k (.paramDflt fn p ps args' (R.env env)) ∧ ListR (ValueR NR R) args args' := by
  obtain ⟨fn',rfl,hh⟩ := h.k_view
  have ht := hh.tag_eq
  cases fn' <;> simp only [Encode.fnF,treeTag] at ht
  all_goals try contradiction
  case paramDflt fn' p' ps' args' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hfn hs =>
        cases hs with | cons hp hs =>
          cases hs with | cons hps hs =>
            cases hs with | cons hargs hs =>
              cases hs with | cons henv hs =>
                cases hfn
                cases hp
                cases hps
                obtain rfl := env_eq_map henv
                exact ⟨args',rfl,vals_roles_of hargs⟩

theorem FrameR.block_view {NR : NumV → NumV → Prop} {R : Ren}
    {ss : List Stmt} {env : Env} {f : Frame} (h : FrameR NR R (.s (.block ss env)) f) :
    f = .s (.block ss (R.env env)) := by
  obtain ⟨st',rfl,hh⟩ := h.s_view
  have ht := hh.tag_eq
  cases st' <;> simp only [Encode.stmtF,treeTag] at ht
  all_goals try contradiction
  case block ss' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hss hs =>
        cases hs with | cons henv hs =>
          cases hss
          obtain rfl := env_eq_map henv
          rfl

theorem FrameR.ret_view {NR : NumV → NumV → Prop} {R : Ren}
    {f : Frame} (h : FrameR NR R (.s .ret) f) : f = .s .ret := by
  obtain ⟨st',rfl,hh⟩ := h.s_view
  have ht := hh.tag_eq
  cases st' <;> simp only [Encode.stmtF,treeTag] at ht
  all_goals first | contradiction | rfl

theorem FrameR.call_view {NR : NumV → NumV → Prop} {R : Ren}
    {f : Frame} (h : FrameR NR R (.k (.fn .call)) f) : f = .k (.fn .call) := by
  obtain ⟨fn',rfl,hh⟩ := h.k_view
  have ht := hh.tag_eq
  cases fn' <;> simp only [Encode.fnF,treeTag] at ht
  all_goals try contradiction
  case fn b =>
    cases hh with | node tag hs =>
      cases hs with | cons hb hs =>
        have ht := hb.tag_eq
        cases b <;> simp only [Encode.bnd,treeTag] at ht
        all_goals first | contradiction | rfl

theorem FrameR.emptyScope_view {NR : NumV → NumV → Prop} {R : Ren}
    {f : Frame} (h : FrameR NR R (.s (.scope [])) f) : f = .s (.scope []) := by
  obtain ⟨st',rfl,hh⟩ := h.s_view
  have ht := hh.tag_eq
  cases st' <;> simp only [Encode.stmtF,treeTag] at ht
  all_goals try contradiction
  case scope res =>
    cases hh with | node tag hs =>
      cases hs with | cons hr hs =>
        cases res with
        | nil => rfl
        | cons p ps => cases hr with | node tag hs => cases hs

namespace StateR
variable {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
  {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}

theorem control_view (h : StateR NR FR R live framed before after old old' s₀ s)
    {c : Ctl} (hc : s₀.ctl = c) : ControlR NR R c s.ctl := hc ▸ h.control

theorem stack_view (h : StateR NR FR R live framed before after old old' s₀ s)
    {f : Frame} {fs : List Frame} (hf : s₀.stack = f::fs) :
    ∃ f' fs', s.stack = f'::fs' ∧ FrameR NR R f f' ∧ ListR (FrameR NR R) fs fs' :=
  frames_cons_view (hf ▸ h.stack)

end StateR
end Host.Ts.Owned.Parametric
