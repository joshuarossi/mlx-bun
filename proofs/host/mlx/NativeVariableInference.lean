import host.mlx.AnnotatedInference
import host.mlx.AnnotatedReplay
import host.mlx.AnnotatedInputs

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric NativeRoles

/-- The actual shapeless graph adds a width vector to a batch-shaped tensor.
Only the shared suffix must have literal dimensions; leading dimensions keep
their fixed symbolic meanings and may vary between the two executions. -/
theorem binary_leading {ν : Nat → F64} {C : CSrv} {R : Ren} {suffix leading : Shape} {da db : Nat}
    (op : List Char) {primitive : Prim} {inputs : List (List Dim × Nat)}
    (literal : suffix.Literal) (held : Primitive.Holds ν C R (.binary op) primitive)
    (metadata : Metadata.Holds ν C [(leading++suffix,da),(suffix,db)] inputs) :
    PureInference ν C (leading++suffix,binaryDtype op da db) primitive inputs := by
  cases held
  obtain ⟨a,b,equal,left,right⟩ := Metadata.pair metadata
  obtain ⟨leadingValue,suffixValue,split,prefixHolds,suffixHolds⟩ := Shape.split leading suffix a left
  have same := Shape.literal_unique literal suffixHolds right
  subst suffixValue
  subst inputs
  rw [split]
  refine ⟨leadingValue++b,?_,prefixHolds.append right⟩
  simp only [infer,InferenceRoles.broadcast_leading]
  rfl

/-- Uniform local inference law for a fixed primitive and input/output
annotation schema. It quantifies over interpretations and actual metadata;
it is a primitive theorem, not an assumed future target execution. -/
def InferenceSchema (primitive : Primitive) (inputs : Metadata) (output : Shape × Nat) : Prop :=
  ∀ (ν : Nat → F64) (C : CSrv) (R : Ren) (p : Prim) (metadata : List (List Dim × Nat)),
    primitive.Holds ν C R p → Metadata.Holds ν C inputs metadata → PureInference ν C output p metadata

/-- Transport one changed replay node using a uniform primitive schema.
Both output geometries follow from current indexed input annotations and the
original source inference; no target output shape or role is a premise. -/
theorem variable_node_transport {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary H N : Nat → Prop} {tail : List NumV} {source target : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (fun _ => ObjectR (NumberRoles ν₀ ν C₀ C) R) H N tail source target)
    (n closure : Nat) (node node' : Node) (substitutions : List (Nat × Nat))
    (metadata metadata' : List (List Dim × Nat)) (shape : List Dim) (dtype : Nat)
    (related : NodeRel roles ν₀ ν C₀ C R boundary n node node') (full : ¬ boundary n)
    (primitive : Primitive) (captured : List Nat) (inputSchema : Metadata) (outputShape : Shape)
    (graph : (roles n).graph = some (primitive,captured))
    (law : InferenceSchema primitive inputSchema (outputShape,dtype))
    (supported : listSupport N (node.ins.map (substOf substitutions)))
    (bounds : listSupport (· < source.nnext) node.ins)
    (keys : listSupport (fun p : Nat × Nat => p.1 < source.nnext) substitutions)
    (read : Ffi.shapesOf source (node.ins.map (substOf substitutions)) = some metadata)
    (schema : inputRoles roles (node.ins.map (substOf substitutions)) = inputSchema)
    (inferred : infer node.prim metadata = M.pure (some (.node shape dtype)))
    (freshRole : roles source.nnext = ⟨outputShape,dtype,some (.replayed closure primitive,node.ins.map (substOf substitutions))⟩)
    (targetRead : Ffi.shapesOf target (node'.ins.map (substOf (mapSubst R.node substitutions))) = some metadata') :
    ∃ shape', infer node'.prim metadata' = M.pure (some (.node shape' dtype)) ∧
      NodeRel roles ν₀ ν C₀ C R boundary source.nnext
        ⟨.replayed closure node.prim,node.ins.map (substOf substitutions),shape,dtype⟩
        ⟨.replayed (R.handle closure) node'.prim,node'.ins.map (substOf (mapSubst R.node substitutions)),shape',dtype⟩ := by
  have mapped : node'.ins.map (substOf (mapSubst R.node substitutions)) =
      (node.ins.map (substOf substitutions)).map R.node := by
    rw [(related.base.graph.resolve_left full).2]
    exact subst_inputs_map R.node source.nnext h.nodeMap.injective substitutions keys node.ins bounds
  obtain ⟨actual,actualRead,sourceMetadata,targetMetadata⟩ := shapesOf_roles h _ _ supported read
  have sameMetadata : actual = metadata' := by
    rw [←mapped] at actualRead
    exact Option.some.inj (actualRead.symm.trans targetRead)
  subst actual
  rw [schema] at sourceMetadata targetMetadata
  obtain ⟨sourceShape,sourceInference,sourceHolds⟩ := law ν₀ C₀ Owned.Annotated.identity node.prim metadata
    (related.source.graph primitive captured graph).1 sourceMetadata
  have sameShape : sourceShape = shape := by
    have equal := congrArg M.run (sourceInference.symm.trans inferred)
    cases equal
    rfl
  subst sourceShape
  obtain ⟨targetShape,targetInference,targetHolds⟩ := law ν C R node'.prim metadata'
    (related.target.graph primitive captured graph).1 targetMetadata
  exact ⟨targetShape,targetInference,related.inferred closure primitive captured _ _ outputShape shape targetShape dtype
    graph freshRole mapped sourceHolds targetHolds⟩

end Host.Mlx.Ffi.Annotated
