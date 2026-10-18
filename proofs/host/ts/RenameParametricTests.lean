import host.ts.RenameParametricNumbers
namespace Host.Ts.Owned.Parametric

private theorem requestTest_map {α : Type} (C : CSrv) (op : NTest) (a b : NumV) (f : Bool → α) :
    interpC (.test op a b (fun r => .pure (f r))) C =
      (interpC (.test op a b .pure) C).map (fun (r,D) => (f r,D)) := by
  cases ha : C.val a <;> cases hb : C.val b <;>
    simp only [interpC_test,ha,hb,interpC_pure,Option.map_none,Option.map_some]

theorem numTest_map {α : Type} (C : CSrv) (op : NTest) (a b : NumV) (f : Bool → α) :
    interpC ((numTest op a b).bind (fun r => M.pure (f r))).run C =
      (interpC (numTest op a b).run C).map (fun (r,D) => (f r,D)) := by
  cases a with
  | lit x => cases b with
    | lit y => rfl
    | ref i => exact requestTest_map C op (.lit x) (.ref i) f
  | ref i => exact requestTest_map C op (.ref i) b f

inductive ComparisonKind where
  | lt | le | seq | sne | eq | ne

def ComparisonKind.jsOp : ComparisonKind → BinOp
  | .lt => .lt | .le => .le | .seq => .seq | .sne => .sne | .eq => .eq | .ne => .ne

def ComparisonKind.numOp : ComparisonKind → NTest
  | .lt => .lt | .le => .le | .seq | .sne | .eq | .ne => .eq

def ComparisonKind.result : ComparisonKind → Bool → Bool
  | .sne | .ne => Bool.not
  | _ => id

/-- The source comparison dispatches through the actual numeric primitive. -/
theorem step_comparison_eq (F : Ffi) (s : St F.S) (op : ComparisonKind) (a b : NumV) (fs : List Frame)
    (hc : s.ctl = .ret (.num b)) (hf : s.stack = .e (.binR op.jsOp (.num a)) :: fs) :
    step F s = (numTest op.numOp a b).bind
      (fun r => M.pure ({s with stack := fs}.ret (.bool (op.result r)))) := by
  cases op <;> funext β k <;>
    simp only [step,hc,stepRet,hf,retStep,retE,ComparisonKind.jsOp,ComparisonKind.numOp,
      ComparisonKind.result,binOp,compare,strictEq,looseEq,toNum,M.bind,M.pure,retS,
      Bool.cond_true,Bool.cond_false,id_eq]

/-- Both concrete valuations must establish the same guard. This transports
an actual numeric comparison while keeping every live runtime component. -/
theorem step_comparison_roles (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (op : ComparisonKind) (a₀ a b₀ b : NumV) (ea eb : SymE) (fs₀ fs : List Frame)
    (ha : NumRole ν₀ ν C₀ C ea a₀ a) (hb : NumRole ν₀ ν C₀ C eb b₀ b)
    (hc₀ : s₀.ctl = .ret (.num b₀)) (hc : s.ctl = .ret (.num b))
    (hf₀ : s₀.stack = .e (.binR op.jsOp (.num a₀)) :: fs₀)
    (hf : s.stack = .e (.binR op.jsOp (.num a)) :: fs)
    (r : Bool) (hg₀ : F64.test op.numOp (ea.eval ν₀) (eb.eval ν₀) = r)
    (hg : F64.test op.numOp (ea.eval ν) (eb.eval ν) = r) :
    interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (.bool (op.result r)),C₀) ∧
    interpC (step F s).run C = some ({s with stack := fs}.ret (.bool (op.result r)),C) ∧
    StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      ({s₀ with stack := fs₀}.ret (.bool (op.result r)))
      ({s with stack := fs}.ret (.bool (op.result r))) := by
  obtain ⟨hr₀,hr⟩ := ha.numTest hb op.numOp r hg₀ hg
  refine ⟨?_,?_,?_⟩
  · rw [step_comparison_eq F s₀ op a₀ b₀ fs₀ hc₀ hf₀,numTest_map,hr₀]
    rfl
  · rw [step_comparison_eq F s op a b fs hc hf,numTest_map,hr]
    rfl
  · have hfs := h.stack
    have hfl := h.stackLive
    rw [hf₀,hf] at hfs
    cases hfs with
    | cons hhead htail =>
      have hl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
        rw [hf₀] at hfl
        exact hfl.2
      exact (h.restack htail hl).go (.node _ (.cons (.value (.bool _)) .nil)) ⟨True.intro,True.intro⟩

end Host.Ts.Owned.Parametric
