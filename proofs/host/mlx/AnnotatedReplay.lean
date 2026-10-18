import host.mlx.NativeAnnotations
import host.mlx.ReplayPlan

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- A replayed kernel keeps the captured node's annotated geometry and
primitive fields, while replacing its inputs and recording the closure. -/
def GraphNode.replayRole (r : GraphNode) (closure : Nat) (primitive : Primitive) (inputs : List Nat) : GraphNode :=
  { r with graph := some (.replayed closure primitive,inputs) }

theorem GraphNode.Holds.replayed {ν : Nat → F64} {C : CSrv} {R : Ren}
    {r : GraphNode} {n : Node} (h : r.Holds ν C R n)
    (closure : Nat) (primitive : Primitive) (captured inputs : List Nat)
    (graph : r.graph = some (primitive,captured)) :
    (r.replayRole closure primitive inputs).Holds ν C R
      ⟨.replayed (R.handle closure) n.prim,inputs.map R.node,n.shape,n.dtype⟩ := by
  refine ⟨h.shape,h.dtype,?_⟩
  intro p ins hg
  have he : (.replayed closure primitive,inputs) = (p,ins) := Option.some.inj hg
  cases he
  exact ⟨.replayed closure (h.graph primitive captured graph).1,rfl⟩

/-- The annotation for the fresh replay node is selected once by source ID.
Its target interpretation follows from the captured node and mapped inputs. -/
theorem NodeRel.replayed {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {i fresh : Nat} {n₀ n : Node}
    (h : NodeRel roles ν₀ ν C₀ C R boundary i n₀ n)
    (closure : Nat) (primitive : Primitive) (captured inputs targetInputs : List Nat)
    (graph : (roles i).graph = some (primitive,captured))
    (freshRole : roles fresh = (roles i).replayRole closure primitive inputs)
    (mapped : targetInputs = inputs.map R.node) :
    NodeRel roles ν₀ ν C₀ C R boundary fresh
      ⟨.replayed closure n₀.prim,inputs,n₀.shape,n₀.dtype⟩
      ⟨.replayed (R.handle closure) n.prim,targetInputs,n.shape,n.dtype⟩ := by
  refine ⟨?_,?_,?_⟩
  · rw [freshRole]
    have identityHandle : Owned.Annotated.identity.handle closure = closure := by rfl
    have source := h.source.replayed closure primitive captured inputs graph
    rw [identityHandle] at source
    simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using source
  · rw [freshRole,mapped]
    exact h.target.replayed closure primitive captured inputs graph
  · intro absent
    rw [freshRole] at absent
    cases absent

theorem NodeRel.inferred {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {i fresh : Nat} {n₀ n : Node}
    (h : NodeRel roles ν₀ ν C₀ C R boundary i n₀ n)
    (closure : Nat) (primitive : Primitive) (captured inputs targetInputs : List Nat)
    (shapeRole : Shape) (shape₀ shape : List Dim) (dtype : Nat)
    (graph : (roles i).graph = some (primitive,captured))
    (freshRole : roles fresh = ⟨shapeRole,dtype,some (.replayed closure primitive,inputs)⟩)
    (mapped : targetInputs = inputs.map R.node)
    (sourceShape : Shape.Holds ν₀ C₀ shapeRole shape₀) (targetShape : Shape.Holds ν C shapeRole shape) :
    NodeRel roles ν₀ ν C₀ C R boundary fresh
      ⟨.replayed closure n₀.prim,inputs,shape₀,dtype⟩
      ⟨.replayed (R.handle closure) n.prim,targetInputs,shape,dtype⟩ := by
  refine ⟨?_,?_,?_⟩
  · rw [freshRole]
    refine ⟨sourceShape,rfl,?_⟩
    intro p ins he
    have eq : (.replayed closure primitive,inputs) = (p,ins) := Option.some.inj he
    cases eq
    have hp := Primitive.Holds.replayed closure (h.source.graph primitive captured graph).1
    have identityHandle : Owned.Annotated.identity.handle closure = closure := by rfl
    rw [identityHandle] at hp
    exact ⟨hp,by simp only [Owned.Annotated.identity,List.map_id_fun,id_eq]⟩
  · rw [freshRole]
    refine ⟨targetShape,rfl,?_⟩
    intro p ins he
    have eq : (.replayed closure primitive,inputs) = (p,ins) := Option.some.inj he
    cases eq
    exact ⟨.replayed closure (h.target.graph primitive captured graph).1,mapped⟩
  · intro absent
    rw [freshRole] at absent
    cases absent

def withReplayRole (roles : Nat → GraphNode) (old fresh closure : Nat) (inputs : List Nat) : Nat → GraphNode :=
  fun i => if i = fresh then match (roles old).graph with
    | some (p,_) => (roles old).replayRole closure p inputs
    | none => roles old
  else roles i

def GraphNode.capturedReplay (role : GraphNode) (closure : Nat) (inputs : List Nat) : GraphNode :=
  match role.graph with
  | some (p,_) => role.replayRole closure p inputs
  | none => role

theorem GraphNode.capturedReplay_shape (role : GraphNode) (closure : Nat) (inputs : List Nat) :
    (role.capturedReplay closure inputs).shape = role.shape := by
  cases hg : role.graph <;> simp [capturedReplay,hg,replayRole]

theorem GraphNode.capturedReplay_dtype (role : GraphNode) (closure : Nat) (inputs : List Nat) :
    (role.capturedReplay closure inputs).dtype = role.dtype := by
  cases hg : role.graph <;> simp [capturedReplay,hg,replayRole]

theorem NodeRel.captured_replayed {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {old fresh closure : Nat} {inputs targetInputs : List Nat} {n₀ n : Node}
    (h : NodeRel roles ν₀ ν C₀ C R boundary old n₀ n) (full : ¬ boundary old)
    (freshRole : roles fresh = (roles old).capturedReplay closure inputs)
    (mapped : targetInputs = inputs.map R.node) :
    NodeRel roles ν₀ ν C₀ C R boundary fresh
      ⟨.replayed closure n₀.prim,inputs,n₀.shape,n₀.dtype⟩
      ⟨.replayed (R.handle closure) n.prim,targetInputs,n.shape,n.dtype⟩ := by
  cases hg : (roles old).graph with
  | none => exact False.elim (full (h.cut hg))
  | some pair =>
    rcases pair with ⟨p,captured⟩
    exact h.replayed closure p captured inputs targetInputs hg
      (by rw [freshRole,GraphNode.capturedReplay,hg]) mapped

/-- The fresh annotation is computed from the captured annotation before
interpretation. A fully related traced node supplies its primitive role. -/
theorem NodeRel.fresh_replayed {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {old fresh closure : Nat} {inputs targetInputs : List Nat} {n₀ n : Node}
    (different : old ≠ fresh) (full : ¬ boundary old)
    (h : NodeRel (withReplayRole roles old fresh closure inputs) ν₀ ν C₀ C R boundary old n₀ n)
    (mapped : targetInputs = inputs.map R.node) :
    NodeRel (withReplayRole roles old fresh closure inputs) ν₀ ν C₀ C R boundary fresh
      ⟨.replayed closure n₀.prim,inputs,n₀.shape,n₀.dtype⟩
      ⟨.replayed (R.handle closure) n.prim,targetInputs,n.shape,n.dtype⟩ := by
  cases hg : (roles old).graph with
  | none =>
    have absent : (withReplayRole roles old fresh closure inputs old).graph = none := by
      simp only [withReplayRole,ite_eq_right different,hg]
    exact False.elim (full (h.cut absent))
  | some pair =>
    rcases pair with ⟨p,captured⟩
    exact h.replayed closure p captured inputs targetInputs
      (by simp only [withReplayRole,ite_eq_right different,hg])
      (by simp only [withReplayRole,ite_true,ite_eq_right different,hg]) mapped

end Host.Mlx.Ffi.Annotated
