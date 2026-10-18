import host.mlx.NativeClosedDimensions
import host.mlx.NativeKvViewRetained

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned NativeRoles

/-- Only the selected producer's shape annotation changes. Its primitive,
input IDs and dtype annotations are retained exactly. -/
def nodeShapeRoles (roles : Nat → GraphNode) (selected : Nat) (sizes : List Int) : Nat → GraphNode :=
  nodeWrite roles selected {roles selected with shape := constantShape sizes}

theorem nodeShapeRoles_graph (roles : Nat → GraphNode) (selected : Nat) (sizes : List Int) (i : Nat) :
    (nodeShapeRoles roles selected sizes i).graph = (roles i).graph := by
  by_cases same : i = selected <;> simp only [nodeShapeRoles,nodeWrite,ite_true,ite_false,same]

theorem nodeShapeRoles_dtype (roles : Nat → GraphNode) (selected : Nat) (sizes : List Int) (i : Nat) :
    (nodeShapeRoles roles selected sizes i).dtype = (roles i).dtype := by
  by_cases same : i = selected <;> simp only [nodeShapeRoles,nodeWrite,ite_true,ite_false,same]

theorem nodeShapeRoles_other (roles : Nat → GraphNode) (selected : Nat) (sizes : List Int) (i : Nat)
    (different : i ≠ selected) : nodeShapeRoles roles selected sizes i = roles i := by
  simp only [nodeShapeRoles,nodeWrite,ite_eq_right different]

theorem NodeRel.normalize_closed_shape {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {selected : Nat} {sizes : List Int}
    (values : LiteralDimensions ν₀ (roles selected).shape sizes)
    (closed : closedLiteralShape (roles selected).shape = true)
    {i : Nat} {n₀ n : Node} (held : NodeRel roles ν₀ ν C₀ C R boundary i n₀ n) :
    NodeRel (nodeShapeRoles roles selected sizes) ν₀ ν C₀ C R boundary i n₀ n := by
  by_cases same : i = selected
  · subst i
    have targetValues : LiteralDimensions ν (roles selected).shape sizes := values.closed_transfer closed
    have sourceShape := held.source.shape.literalValues values.literalValues
    have targetShape := held.target.shape.literalValues targetValues.literalValues
    constructor
    · simp only [nodeShapeRoles,nodeWrite,ite_true]
      refine ⟨?_,held.source.dtype,held.source.graph⟩
      rw [sourceShape]
      exact (LiteralDimensions.constants ν₀ sizes values.exact).holds C₀
    · simp only [nodeShapeRoles,nodeWrite,ite_true]
      refine ⟨?_,held.target.dtype,held.target.graph⟩
      rw [targetShape]
      exact (LiteralDimensions.constants ν sizes values.exact).holds C
    · simpa only [nodeShapeRoles,nodeWrite,ite_true] using held.cut
  · exact NodeRel.write_frame same held

theorem ProducerAnnotations.same_graph {roots H N : Nat → Prop} {roles newRoles : Nat → GraphNode} {objects : Nat → Object}
    (policy : ProducerAnnotations roots H N roles objects)
    (same : ∀ i, (newRoles i).graph = (roles i).graph) : ProducerAnnotations roots H N newRoles objects :=
  ⟨policy.objects,fun i none => policy.roots i ((same i).symm.trans none),
    fun i alive primitive inputs graph => policy.nodes i alive primitive inputs ((same i).symm.trans graph)⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem normalize_closed_shape {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {s₀ s : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s₀ s)
    (selected : Nat) (node : Node) (sizes : List Int) (alive : N selected)
    (read : s₀.nodes.get selected = some node) (shape : node.shape = sizes.map Dim.lit)
    (closed : closedLiteralShape (roles selected).shape = true) :
    Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (nodeShapeRoles roles selected sizes) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s₀ s := by
  obtain ⟨_,_,related⟩ := h.node_view alive read
  have values : LiteralDimensions ν₀ (roles selected).shape sizes :=
    .of_holds (by rw [←shape]; exact related.source.shape)
  exact h.mono (fun _ _ held => held) (fun _ _ _ held => held.normalize_closed_shape values closed) (fun _ _ _ held => held)

end Host.Mlx.Ffi.NativeRoles.Live

namespace Host.Load.Run.Full.Ordinary.VectorHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Source bytes/metadata and closed current annotations determine the same
shape in the target valuation. This pure annotation change leaves both
physical states, number tables, object roles and all six inventories intact. -/
theorem normalize_closed_producer {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {host : HostSt → HostSt → Prop}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : Host.Ts.St LSt}
    (h : StateR (NumberRoles ν₀ ν C₀ C) (NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (selected : Nat) (node : Node) (sizes : List Int) (alive : N selected)
    (read : s₀.ffi.mlx.nodes.get selected = some node) (shape : node.shape = sizes.map Dim.lit)
    (closed : closedLiteralShape (roles selected).shape = true)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects) :
    StateR (NumberRoles ν₀ ν C₀ C) (NativeRelation ν₀ ν C₀ C (nodeShapeRoles roles selected sizes) boundary objects H N tail host)
      R live framed before after old old' s₀ s ∧
    RetainedInventory notes ν₀ ν C₀ C R live s₀ s ∧
    ProducerAnnotations roots H N (nodeShapeRoles roles selected sizes) objects ∧
    ProducerSupport roots H N s₀.ffi.mlx := by
  have native := h.native.2.normalize_closed_shape selected node sizes alive read shape closed
  have pair : NativeRelation ν₀ ν C₀ C (nodeShapeRoles roles selected sizes) boundary objects H N tail host R s₀.ffi s.ffi :=
    ⟨h.native.1,native⟩
  have post := h.setFfi s₀.ffi s.ffi pair
  have newPolicy := policy.same_graph (nodeShapeRoles_graph roles selected sizes)
  exact ⟨post,inventory,newPolicy,newPolicy.source native⟩

end Host.Load.Run.Full.Ordinary.VectorHost
