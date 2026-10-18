import host.ts.RenameParametricArguments

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem FrameR.e_view {NR : NumV → NumV → Prop} {R : Ren}
    {ef : ExprF} {f : Frame} (h : FrameR NR R (.e ef) f) :
    ∃ ef', f = .e ef' ∧ TreeR NR R (Encode.exprF ef) (Encode.exprF ef') := by
  have ht := h.tag_eq
  cases f <;> simp only [Encode.frame,treeTag] at ht
  all_goals try contradiction
  case e ef' =>
    cases h with | node tag hs =>
      cases hs with | cons hh hs => exact ⟨ef',rfl,hh⟩

theorem FrameR.binL_view {NR : NumV → NumV → Prop} {R : Ren}
    {op : BinOp} {right : Expr} {env : Env} {f : Frame}
    (h : FrameR NR R (.e (.binL op right env)) f) : f = .e (.binL op right (R.env env)) := by
  obtain ⟨ef',rfl,hh⟩ := h.e_view
  have ht := hh.tag_eq
  cases ef' <;> simp only [Encode.exprF,treeTag] at ht
  all_goals try contradiction
  case binL op' right' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hop hs =>
        cases hs with | cons hr hs =>
          cases hs with | cons he hs =>
            cases hop
            cases hr
            obtain rfl := env_eq_map he
            rfl

def binaryLeftState {S : Type} (s : St S) (op : BinOp) (right : Expr) (env : Env) (v : Val) : St S :=
  (s.push (.e (.binR op v))).go (.ev right env)

theorem step_binary_left_eq (F : Ffi) (s : St F.S) (v : Val) (op : BinOp) (right : Expr)
    (env : Env) (fs : List Frame) (hc : s.ctl = .ret v)
    (hf : s.stack = .e (.binL op right env)::fs) :
    step F s = M.pure (binaryLeftState {s with stack := fs} op right env v) := by
  simp only [step,hc,stepRet,hf,retStep,retE,binaryLeftState]

/-- Actual binary evaluation preserves the related left value while starting
the source right-hand expression. No numeric meaning is newly selected. -/
theorem step_binary_left_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ : Val)
    (op : BinOp) (right : Expr) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .e (.binL op right env)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (binaryLeftState {s₀ with stack := fs₀} op right env v₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (binaryLeftState {s₀ with stack := fs₀} op right env v₀) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  rw [hfr.binL_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.1
  have hvl := (h.return_values v₀ v hc₀ hc).2
  have hnew : FrameR NR R (.e (.binR op v₀)) (.e (.binR op v)) :=
    .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.value hv) .nil))) .nil)
  have hnewl : treeSupport live (Encode.frame (.e (.binR op v₀))) :=
    ⟨⟨True.intro,hvl,True.intro⟩,True.intro⟩
  refine ⟨binaryLeftState {s with stack := fs} op right (R.env env) v,?_,?_,
    (h.restack (.cons hnew htail) ⟨hnewl,hl.2⟩).go
      (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,hel,True.intro⟩⟩
  · rw [step_binary_left_eq F s₀ v₀ op right env fs₀ hc₀ hf₀]; rfl
  · rw [step_binary_left_eq F s v op right (R.env env) fs hc hf]; rfl

end Host.Ts.Owned.Parametric
