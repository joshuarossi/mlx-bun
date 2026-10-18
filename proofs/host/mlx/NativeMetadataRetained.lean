import host.mlx.NativeVectorDataHost
import host.ts.RenameParametricRankNative
import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeArguments

set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary.MetadataInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated

/-- The current handle occurrence determines the original native rank return.
Fixed indexed graph and object annotations, and all retained host families, survive unchanged. -/
theorem retained_ndim_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types handle : Nat) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (node : Host.Mlx.Ffi.Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_array_ndim",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (owned : H handle)
    (sourceNode : s₀.ffi.mlx.node? handle = some node)
    (fnRole thisRole : Value) (note : notes.runtime.control = callNote fnRole thisRole [.handle handle]) :
    interpC (step Host.Load.ffi s₀).run C₀ = some (finishBig s₀ s₀.ffi chars!"mlx_array_ndim" [.big (Int.ofNat handle)] (Int.ofNat (len node.shape)),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishBig s s.ffi chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len node.shape)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' (finishBig s₀ s₀.ffi chars!"mlx_array_ndim" [.big (Int.ofNat handle)] (Int.ofNat (len node.shape))) (finishBig s s.ffi chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len node.shape))) ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.ordinaryBig (Int.ofNat (len node.shape))),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (finishBig s₀ s₀.ffi chars!"mlx_array_ndim" [.big (Int.ofNat handle)] (Int.ofNat (len node.shape))) (finishBig s s.ffi chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len node.shape))) := by
  have argument := (inventory.runtime.call_argument_role fnRole thisRole [.handle handle] (.obj fn) receiver _ control note 0 (.handle handle) rfl).2
  obtain ⟨left,right,post⟩ := step_ndim_from_source (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
    R C₀ C ν live framed before after old old' s₀ s h
    (NodeRel roles ν₀ ν C₀ C R boundary) (ObjectRel objects ν₀ ν C₀ C R) H N tail h.native.2
    (fun _ _ _ paired => paired.base.shape)
    fn types handle function signatureObject returns receiver node control read kind signatureRead signatureKind signatureFrame owned sourceNode argument
  have runtime : RuntimeInventory ⟨returnNote (.ordinaryBig (Int.ofNat (len node.shape))),notes.runtime.stack,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      (finishBig s₀ s₀.ffi chars!"mlx_array_ndim" [.big (Int.ofNat handle)] (Int.ofNat (len node.shape))) (finishBig s s.ffi chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len node.shape))) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.ordinaryBig _),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.ordinaryBig _),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨left,right,post,runtime,
    inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
    inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩

/-- The current handle occurrence determines the original native shape pointer return.
Fixed indexed graph and object annotations, and all retained host families, survive unchanged. -/
theorem retained_shape_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types handle : Nat) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (node : Host.Mlx.Ffi.Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_array_shape",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (owned : H handle)
    (sourceNode : s₀.ffi.mlx.node? handle = some node)
    (region : R.region (4*handle) = 4*R.handle handle)
    (fnRole thisRole : Value) (note : notes.runtime.control = callNote fnRole thisRole [.handle handle]) :
    interpC (step Host.Load.ffi s₀).run C₀ = some (finishPointer s₀ s₀.ffi chars!"mlx_array_shape" [.big (Int.ofNat handle)] (4*handle) 0,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishPointer s s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle handle))] (R.region (4*handle)) 0,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' (finishPointer s₀ s₀.ffi chars!"mlx_array_shape" [.big (Int.ofNat handle)] (4*handle) 0) (finishPointer s s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle handle))] (R.region (4*handle)) 0) ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.ptr (.ext (4*handle)) 0),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (finishPointer s₀ s₀.ffi chars!"mlx_array_shape" [.big (Int.ofNat handle)] (4*handle) 0) (finishPointer s s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle handle))] (R.region (4*handle)) 0) := by
  have argument := (inventory.runtime.call_argument_role fnRole thisRole [.handle handle] (.obj fn) receiver _ control note 0 (.handle handle) rfl).2
  obtain ⟨left,right,post⟩ := step_shape_from_source (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
    R C₀ C ν live framed before after old old' s₀ s h
    (NodeRel roles ν₀ ν C₀ C R boundary) (ObjectRel objects ν₀ ν C₀ C R) H N tail h.native.2
    fn types handle function signatureObject returns receiver node control read kind signatureRead signatureKind signatureFrame owned sourceNode region argument
  have runtime : RuntimeInventory ⟨returnNote (.ptr (.ext (4*handle)) 0),notes.runtime.stack,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      (finishPointer s₀ s₀.ffi chars!"mlx_array_shape" [.big (Int.ofNat handle)] (4*handle) 0) (finishPointer s s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle handle))] (R.region (4*handle)) 0) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.ptr _ _),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.ptr _ _),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨left,right,post,runtime,
    inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
    inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩

end Host.Load.Run.Full.Ordinary.MetadataInventory
