import host.ts.RenameParametricViews
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_empty_object_eq (F : Ffi) (s : St F.S) (env : Env)
    (hc : s.ctl = .ev (.object []) env) :
    step F s = M.pure ((s.alloc (.obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩)).2.ret (.obj s.next)) := by
  simp only [step,hc,evStep,objNext,St.allocObj,retS]
  rfl

/-- The actual object literal creates a fresh ordinary object with the original
intrinsic prototype, preserving the entire caller/native relation. -/
theorem step_empty_object_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s) (env : Env)
    (hc₀ : s₀.ctl = .ev (.object []) env) (hp : live aObjectProto) (hpr : R.a aObjectProto = aObjectProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    let object : HObj := .obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩
    interpC (step F s₀).run C₀ = some ((s₀.alloc object).2.ret (.obj s₀.next),C₀) ∧
    interpC (step F s).run C = some ((s.alloc object).2.ret (.obj s.next),C) ∧
    StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc object).2.ret (.obj s₀.next)) ((s.alloc object).2.ret (.obj s.next)) := by
  dsimp only
  have hc := (h.control_view hc₀).ev_view
  have protoRole : ValueR NR R (.obj aObjectProto) (.obj aObjectProto) := by
    simpa only [hpr] using (ValueR.obj (NR := NR) (R := R) aObjectProto)
  have objects : HeapObjectR NR R (.obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩)
      (.obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩) :=
    .obj (.node _ (.cons (.node _ .nil) (.cons (.value protoRole)
      (.cons (.node _ .nil) (.cons (.node _ .nil) (.cons (.atom _ _) .nil))))))
  have objectLive : treeSupport (LiveAfter live s₀.next)
      (Encode.hobj (.obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩)) :=
    ⟨⟨True.intro,Or.inl hp,True.intro,True.intro,True.intro,True.intro⟩,True.intro⟩
  have allocated := h.alloc _ _ objects objectLive sourceBound targetBound
  have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have value : ValueR NR R (.obj s₀.next) (.obj s.next) := by
    simpa only [fresh] using (ValueR.obj (NR := NR) (R := R) s₀.next)
  refine ⟨?_,?_,allocated.go (.node _ (.cons (.value value) .nil)) ⟨Or.inr rfl,True.intro⟩⟩
  · rw [step_empty_object_eq F s₀ env hc₀]; rfl
  · rw [step_empty_object_eq F s (R.env env) hc]; rfl

end Host.Ts.Owned.Parametric
