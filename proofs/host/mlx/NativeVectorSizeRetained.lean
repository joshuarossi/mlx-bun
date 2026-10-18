import host.mlx.NativeVectorSizeHost
import host.mlx.NativeAnnotationPolicy
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeArguments

set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary.VectorSizeInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated

/-- The current handle occurrence determines the original native vector length return.
Fixed indexed graph and object annotations, and all retained host families, survive unchanged. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types handle : Nat) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (entries : List Nat)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_vector_array_size",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (owned : H handle)
    (sourceVector : s₀.ffi.mlx.obj? handle = some (.vec entries))
    (fnRole thisRole : Value) (note : notes.runtime.control = callNote fnRole thisRole [.handle handle]) :
    interpC (step Host.Load.ffi s₀).run C₀ = some (finishBig s₀ s₀.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] (Int.ofNat (len entries)),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishBig s s.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len entries)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' (finishBig s₀ s₀.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] (Int.ofNat (len entries))) (finishBig s s.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len entries))) ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.ordinaryBig (Int.ofNat (len entries))),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (finishBig s₀ s₀.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] (Int.ofNat (len entries))) (finishBig s s.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len entries))) := by
  have argument := (inventory.runtime.call_argument_role fnRole thisRole [.handle handle] (.obj fn) receiver _ control note 0 (.handle handle) rfl).2
  obtain ⟨left,right,post⟩ := VectorSizeHost.from_source ν₀ ν C₀ C R roles boundary objects H N tail host
    live framed before after old old' s₀ s h fn types handle function signatureObject returns receiver entries
    control read kind signatureRead signatureKind signatureFrame owned sourceVector argument
  have runtime : RuntimeInventory ⟨returnNote (.ordinaryBig (Int.ofNat (len entries))),notes.runtime.stack,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      (finishBig s₀ s₀.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat handle)] (Int.ofNat (len entries))) (finishBig s s.ffi chars!"mlx_vector_array_size" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len entries))) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.ordinaryBig _),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.ordinaryBig _),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨left,right,post,runtime,
    inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
    inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩

end Host.Load.Run.Full.Ordinary.VectorSizeInventory
