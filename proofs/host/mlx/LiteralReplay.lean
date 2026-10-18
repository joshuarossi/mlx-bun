import host.mlx.ClosedGeometry
import host.mlx.AnnotatedReplay

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi.NativeRoles

/-- A local replay-inference witness for a fixed geometric schema. All
metadata is obtained from live annotated nodes; the original target inference
equation is derived from the source primitive and exact literal dimensions. -/
theorem literal_node_transport {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H N tail s s')
    (n closure : Nat) (nd nd' : Node) (m : List (Nat × Nat)) (metadata' : List (List Dim × Nat))
    (hr : NodeRel roles ν₀ ν C₀ C R boundary n nd nd') (full : ¬ boundary n)
    (primitive : Primitive) (captured : List Nat)
    (graph : (roles n).graph = some (primitive,captured))
    (fixed : ∀ p, primitive.Holds ν C R p → p = nd.prim)
    (inputs : listSupport N (nd.ins.map (substOf m)))
    (bounds : listSupport (· < s.nnext) nd.ins)
    (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m)
    (metadata : List (List Int × Nat)) (shape : List Int) (dtype : Nat)
    (metadataExact : listSupport (fun a => listSupport (fun i => F64.toInt? (F64.ofInt i) = some i) a.1) metadata)
    (shapeExact : listSupport (fun i => F64.toInt? (F64.ofInt i) = some i) shape)
    (read : shapesOf s (nd.ins.map (substOf m)) = some (literalMetadata metadata))
    (schema : inputRoles roles (nd.ins.map (substOf m)) = closedMetadata metadata)
    (inferred : infer nd.prim (literalMetadata metadata) = M.pure (some (.node (shape.map Dim.lit) dtype)))
    (freshRole : roles s.nnext = ⟨closedShape shape,dtype,
      some (.replayed closure primitive,nd.ins.map (substOf m))⟩)
    (targetRead : shapesOf s' (nd'.ins.map (substOf (mapSubst R.node m))) = some metadata') :
    ∃ shape', infer nd'.prim metadata' = M.pure (some (.node shape' dtype)) ∧
      NodeRel roles ν₀ ν C₀ C R boundary s.nnext
        ⟨.replayed closure nd.prim,nd.ins.map (substOf m),shape.map Dim.lit,dtype⟩
        ⟨.replayed (R.handle closure) nd'.prim,nd'.ins.map (substOf (mapSubst R.node m)),shape',dtype⟩ := by
  have mapped : nd'.ins.map (substOf (mapSubst R.node m)) = (nd.ins.map (substOf m)).map R.node := by
    rw [(hr.base.graph.resolve_left full).2]
    exact subst_inputs_map R.node s.nnext h.nodeMap.injective m keys nd.ins bounds
  obtain ⟨actual,ha,_,hh⟩ := shapesOf_roles h _ _ inputs read
  have targetRead' : shapesOf s' ((nd.ins.map (substOf m)).map R.node) = some metadata' := by
    rw [← mapped]
    exact targetRead
  have he : actual = metadata' := Option.some.inj (ha.symm.trans targetRead')
  subst actual
  rw [schema] at hh
  have hmeta := closedMetadata_unique metadata metadataExact hh
  have hp := fixed nd'.prim (hr.target.graph primitive captured graph).1
  refine ⟨shape.map Dim.lit,?_,hr.inferred closure primitive captured _ _ (closedShape shape)
    (shape.map Dim.lit) (shape.map Dim.lit) dtype graph freshRole mapped
      (closedShape_holds ν₀ C₀ shape shapeExact) (closedShape_holds ν C shape shapeExact)⟩
  rw [hp,hmeta]
  exact inferred

end Host.Mlx.Ffi.Annotated
