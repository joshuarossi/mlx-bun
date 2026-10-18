import host.ts.RenameParametricExpressionReturns

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem FrameR.binR_view {NR : NumV → NumV → Prop} {R : Ren}
    {op : BinOp} {left : Val} {f : Frame} (h : FrameR NR R (.e (.binR op left)) f) :
    ∃ left', f = .e (.binR op left') ∧ ValueR NR R left left' := by
  obtain ⟨ef',rfl,hh⟩ := h.e_view
  have ht := hh.tag_eq
  cases ef' <;> simp only [Encode.exprF,treeTag] at ht
  all_goals try contradiction
  case binR op' left' =>
    cases hh with | node tag hs =>
      cases hs with | cons hop hs =>
        cases hs with | cons hl hs =>
          cases hop
          cases hl with | value hv => exact ⟨left',rfl,hv⟩

theorem ValueR.num_view {NR : NumV → NumV → Prop} {R : Ren}
    {n : NumV} {v : Val} (h : ValueR NR R (.num n) v) :
    ∃ n', v = .num n' ∧ NR n n' := by
  cases h with | num hn => exact ⟨_,rfl,hn⟩

/-- Arithmetic extracts the common meanings already carried by the two
operands. The target numeric values and their server extensions are derived;
no target result or branch outcome is assumed. -/
theorem step_arithmetic_from_source (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (op : ArithmeticKind) (a₀ b₀ : NumV) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.num b₀))
    (hf₀ : s₀.stack = .e (.binR op.jsOp (.num a₀))::fs₀) :
    ∃ (ea eb : SymE) (v₀ : NumV) (D₀ : CSrv) (v : NumV) (D : CSrv) (fs : List Frame),
      interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (.num v₀),D₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.ret (.num v),D) ∧
      NumRole ν₀ ν D₀ D (.bin op.numOp ea eb) v₀ v ∧
      StateR (NumberRoles ν₀ ν D₀ D) FR R live framed before after old old'
        ({s₀ with stack := fs₀}.ret (.num v₀)) ({s with stack := fs}.ret (.num v)) ∧
      TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨bv,hc,hb⟩ := (h.control_view hc₀).ret_view
  obtain ⟨b,rfl,eb,hbr⟩ := hb.num_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨av,hframe,ha⟩ := hfr.binR_view
  obtain ⟨a,rfl,ea,har⟩ := ha.num_view
  rw [hframe] at hf
  obtain ⟨v₀,D₀,v,D,hr₀,hr,hrole,hpost,he₀,he⟩ := step_arithmetic_roles F FR R ν₀ ν C₀ C
    live framed before after old old' s₀ s h op a₀ a b₀ b ea eb fs₀ fs har hbr hc₀ hc hf₀ hf
  exact ⟨ea,eb,v₀,D₀,v,D,fs,hr₀,hr,hrole,hpost,he₀,he⟩

end Host.Ts.Owned.Parametric
