import host.mlx.NativeAnnotationPolicy

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- An absent native object has no payload meaning to discard. Reannotating
that single slot keeps every present object's fixed occurrence annotations. -/
theorem reannotate_absent_object {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (slot : Nat) (role : Object) (absent : s.objs.get slot = none) :
    Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel (objectWrite objects slot role) ν₀ ν C₀ C R) H N tail s s' := by
  refine {h with objs := ?_}
  intro i alive
  by_cases same : i = slot
  · subst i
    have old := h.objs slot alive
    rw [absent] at old
    have targetNone : s'.objs.get (R.handle slot) = none := by
      cases targetRead : s'.objs.get (R.handle slot) with
      | none => rfl
      | some object => rw [targetRead] at old; cases old
    rw [absent,targetNone]
    exact .none
  · exact (h.objs i alive).mono (fun _ _ old =>
      ⟨by simpa only [objectWrite,ite_eq_right same] using old.source,
       by simpa only [objectWrite,ite_eq_right same] using old.target⟩)

end Host.Mlx.Ffi.NativeRoles.Live
