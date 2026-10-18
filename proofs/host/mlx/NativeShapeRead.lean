import host.mlx.NativeInputs
import host.mlx.NativeAnnotations
import host.mlx.OwnedMetadata

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

private theorem shape_nth {NR : NumV → NumV → Prop} {xs ys : List Dim}
    (h : Parametric.ShapeR NR xs ys) : ∀ i d, nth? xs i = some d →
      ∃ d', nth? ys i = some d' ∧ NR d.num d'.num := by
  induction h with
  | nil => intro i d hi; cases i <;> cases hi
  | cons hd ht ih =>
    intro i d hi
    cases i with
    | zero =>
      have he := Option.some.inj hi
      subst d
      exact ⟨_,rfl,hd⟩
    | succ i => exact ih i d hi

/-- The native graph invariant determines both original shape-memory reads.
Dimensions may have different numeric meanings and representations. -/
theorem Live.read_shape {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s')
    (shape : ∀ i n n', NodeRel i n n' → Parametric.ShapeR NR n.shape n'.shape)
    (handle : Nat) (live : H handle) (node : Node) (source : s.node? handle = some node)
    (off count : Nat) :
    ∃ bs bs', read s (4*handle) off count = some bs ∧
      read s' (4*R.handle handle) off count = some bs' ∧
      ListR (Host.Ts.Owned.Parametric.ByteR NR R) bs bs' := by
  obtain ⟨i,node',_,hn,hr⟩ := h.node? live source
  exact Parametric.read_shape_roles R s s' handle node node' source hn (shape i node node' hr) off count

end Host.Mlx.Ffi.NativeRoles

namespace Host.Load.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi
open Host.Ts.Owned.Parametric
open Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

theorem node_shape {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {roles : Nat → GraphNode}
    {ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop}
    {boundary H N : Nat → Prop} {tail : List NumV} {s s' : LSt}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s.mlx s'.mlx)
    (handle : Nat) (live : H handle) (node : Node) (source : s.mlx.node? handle = some node) :
    ∃ i node', s.mlx.arrs.get handle = some i ∧ s'.mlx.node? (R.handle handle) = some node' ∧
      NodeRel roles ν₀ ν C₀ C R boundary i node node' ∧
      Host.Mlx.Ffi.Parametric.ShapeR (NumberRoles ν₀ ν C₀ C) node.shape node'.shape ∧
      len node'.shape = len node.shape := by
  obtain ⟨i,node',hi,hn,hr⟩ := h.node? live source
  exact ⟨i,node',hi,hn,hr,hr.base.shape,hr.base.shape.len_eq.symm⟩

/-- A live owned native array supplies paired shape-memory bytes in the full
load-world FFI. No target read equation is a premise. -/
theorem read_shape {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {roles : Nat → GraphNode}
    {ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop} {boundary H N : Nat → Prop} {tail : List NumV} {s s' : LSt}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s.mlx s'.mlx)
    (handle : Nat) (live : H handle) (node : Node) (source : s.mlx.node? handle = some node)
    (off count : Nat) :
    ∃ bs bs', Host.Load.read s (4*handle) off count = some bs ∧
      Host.Load.read s' (4*R.handle handle) off count = some bs' ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R) bs bs' := by
  obtain ⟨i,node',_,hn,hr⟩ := h.node? live source
  exact ⟨_,_,Host.Load.Owned.read_shape s handle node source off count,
    Host.Load.Owned.read_shape s' (R.handle handle) node' hn off count,
    ((Host.Mlx.Ffi.Parametric.shapeBytes_roles R hr.base.shape).drop off).take count⟩

/-- The native shape-region ownership law turns the derived target read into
a read at the resource-renamed pointer used by the host buffer view. -/
theorem read_shape_region {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {roles : Nat → GraphNode}
    {ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop}
    {boundary H N : Nat → Prop} {tail : List NumV} {s s' : LSt}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s.mlx s'.mlx)
    (handle : Nat) (live : H handle) (node : Node) (source : s.mlx.node? handle = some node)
    (region : R.region (4*handle) = 4*R.handle handle) (off count : Nat) :
    ∃ node' bs bs', s'.mlx.node? (R.handle handle) = some node' ∧
      Host.Mlx.Ffi.Parametric.ShapeR (NumberRoles ν₀ ν C₀ C) node.shape node'.shape ∧
      len node'.shape = len node.shape ∧
      Host.Load.read s (4*handle) off count = some bs ∧
      Host.Load.read s' (R.region (4*handle)) off count = some bs' ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R) bs bs' := by
  obtain ⟨i,node',_,hn,hr⟩ := h.node? live source
  refine ⟨node',_,_,hn,hr.base.shape,hr.base.shape.len_eq.symm,
    Host.Load.Owned.read_shape s handle node source off count,?_,
    ((Host.Mlx.Ffi.Parametric.shapeBytes_roles R hr.base.shape).drop off).take count⟩
  rw [region]
  exact Host.Load.Owned.read_shape s' (R.handle handle) node' hn off count

/-- A dimension selected by the source index has a derived target dimension,
related numeric cells and the exact native reads of their tagged int32 bytes. -/
theorem read_dimension {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {roles : Nat → GraphNode}
    {ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop} {boundary H N : Nat → Prop} {tail : List NumV} {s s' : LSt}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s.mlx s'.mlx)
    (handle : Nat) (live : H handle) (node : Node) (source : s.mlx.node? handle = some node)
    (index : Nat) (dimension : Dim) (dimensionAt : nth? node.shape index = some dimension) :
    ∃ node' dimension', s'.mlx.node? (R.handle handle) = some node' ∧
      nth? node'.shape index = some dimension' ∧
      Host.Load.read s (4*handle) (index*4) 4 = some (cellParts .i32 (.num dimension.num) 4 0) ∧
      Host.Load.read s' (4*R.handle handle) (index*4) 4 = some (cellParts .i32 (.num dimension'.num) 4 0) ∧
      Host.Ts.Owned.Parametric.CellR (NumberRoles ν₀ ν C₀ C) R (.num dimension.num) (.num dimension'.num) ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
        (cellParts .i32 (.num dimension.num) 4 0) (cellParts .i32 (.num dimension'.num) 4 0) := by
  obtain ⟨i,node',_,hn,hr⟩ := h.node? live source
  obtain ⟨dimension',ha,hd⟩ := NativeRoles.shape_nth hr.base.shape index dimension dimensionAt
  exact ⟨node',dimension',hn,ha,Host.Load.Owned.read_shape_dimension s handle node source index dimension dimensionAt,
    Host.Load.Owned.read_shape_dimension s' (R.handle handle) node' hn index dimension' ha,
    .num hd,Host.Mlx.Ffi.Parametric.cellParts_roles (.num hd) .i32 4 0⟩

end Host.Load.Annotated
