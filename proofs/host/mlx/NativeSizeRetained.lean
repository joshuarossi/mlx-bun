import host.mlx.NativeSizeHost
import host.mlx.NativeSizeValues
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeArguments
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.MetadataSizeInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated

theorem retained_size_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types handle input : Nat) (function signature : Obj) (returns : Name) (receiver : Val) (node : Host.Mlx.Ffi.Node)
    (sourceDims targetDims : List Nat)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str SizeHost.symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signature))
    (signatureKind : signature.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (owned : H handle)
    (producer : s₀.ffi.mlx.arrs.get handle = some input) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (sourceGeometry : NaturalSize ν₀ (roles input).shape sourceDims)
    (targetGeometry : NaturalSize ν (roles input).shape targetDims)
    (fnRole thisRole : Value) (note : notes.runtime.control = callNote fnRole thisRole [.handle handle]) :
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ =
        some (finishBig s₀ s₀.ffi SizeHost.symbol [.big (Int.ofNat handle)] (SizeHost.product sourceDims),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R live framed before after old old'
        (finishBig s₀ s₀.ffi SizeHost.symbol [.big (Int.ofNat handle)] (SizeHost.product sourceDims)) t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.exactInteger (roles input).shape.sizeMeaning),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (finishBig s₀ s₀.ffi SizeHost.symbol [.big (Int.ofNat handle)] (SizeHost.product sourceDims)) t ∧
      t.ffi = s.ffi := by
  have argument := (inventory.runtime.call_argument_role fnRole thisRole [.handle handle] (.obj fn) receiver _ control note 0 (.handle handle) rfl).2
  obtain ⟨t,left,right,post,native,heap,next,stack,ctl,role⟩ := SizeHost.from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed
    before after old old' s₀ s h fn types handle input function signature returns receiver node sourceDims targetDims
    control read kind signatureRead signatureKind signatureFrame owned producer sourceNode sourceGeometry targetGeometry argument
  have runtime : RuntimeInventory ⟨returnNote (.exactInteger (roles input).shape.sizeMeaning),notes.runtime.stack,notes.runtime.cells⟩
      ν₀ ν C₀ C R live (finishBig s₀ s₀.ffi SizeHost.symbol [.big (Int.ofNat handle)] (SizeHost.product sourceDims)) t :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds sourceGeometry.exactInteger,inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨by rw [ctl]; exact returnNote_holds role,
        by rw [stack]; exact inventory.runtime.target.stack,
        inventory.runtime.target.cells.frame (fun _ _ _ => by rw [heap])⟩⟩
  exact ⟨t,left,right,post,inventory.heap_step runtime rfl heap (.refl C₀) (.refl C),native⟩

/-- This closed-shape candidate obtains source dimensions from the selected
current producer and transfers their meanings to every target valuation. -/
theorem current_closed_geometry
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {s₀ s : Host.Mlx.Ffi.St}
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel roles ν₀ ν C₀ C R boundary) (ObjectRel objects ν₀ ν C₀ C R) H N tail s₀ s)
    (input : Nat) (node : Host.Mlx.Ffi.Node) (dims : List Nat)
    (alive : N input) (read : s₀.nodes.get input = some node)
    (shape : node.shape = dims.map (fun n => .lit (Int.ofNat n)))
    (bounds : NaturalSizeBounds dims) (closed : closedLiteralShape (roles input).shape = true) :
    NaturalSize ν₀ (roles input).shape dims ∧ NaturalSize ν (roles input).shape dims := by
  obtain ⟨_,_,related⟩ := native.node_view alive read
  have values : LiteralDimensions ν₀ (roles input).shape (dims.map Int.ofNat) :=
    .of_holds (by simpa only [List.map_map] using shape ▸ related.source.shape)
  have source := NaturalSize.of_values values bounds
  exact ⟨source,source.closed_transfer closed⟩
end Host.Load.Run.Full.Ordinary.MetadataSizeInventory
