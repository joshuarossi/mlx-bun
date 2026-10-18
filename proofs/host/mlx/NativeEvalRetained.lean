import host.mlx.NativeEvalExact
import host.mlx.NativeBufferInventory
import host.mlx.NativeAnnotationPolicy
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeArguments

set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary.EvalInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated

/-- The current handle occurrence determines the original native evaluation status return.
Fixed indexed graph and object annotations, and all retained host families, survive unchanged. -/
theorem retained_from_source {notes : RetainedNotes}
    (kind : EvalHost.Mode) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types handle : Nat) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str kind.name,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (owned : H handle)
    (sourceInput : kind.Input s₀.ffi.mlx handle)
    (fnRole thisRole : Value) (note : notes.runtime.control = callNote fnRole thisRole [.handle handle]) :
    interpC (step Host.Load.ffi s₀).run C₀ = some (finishStatus s₀ s₀.ffi kind.name [.big (Int.ofNat handle)],C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishStatus s s.ffi kind.name [.big (Int.ofNat (R.handle handle))],C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' (finishStatus s₀ s₀.ffi kind.name [.big (Int.ofNat handle)]) (finishStatus s s.ffi kind.name [.big (Int.ofNat (R.handle handle))]) ∧
      RetainedInventory (notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (finishStatus s₀ s₀.ffi kind.name [.big (Int.ofNat handle)]) (finishStatus s s.ffi kind.name [.big (Int.ofNat (R.handle handle))]) := by
  have argument := (inventory.runtime.call_argument_role fnRole thisRole [.handle handle] (.obj fn) receiver _ control note 0 (.handle handle) rfl).2
  obtain ⟨left,right,post⟩ := EvalHost.from_source_exact kind ν₀ ν C₀ C R roles boundary objects H N tail host
    live framed before after old old' s₀ s h fn types handle function signatureObject returns receiver
    control read functionKind signatureRead signatureKind signatureFrame owned sourceInput argument
  have runtime : RuntimeInventory ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      (finishStatus s₀ s₀.ffi kind.name [.big (Int.ofNat handle)]) (finishStatus s s.ffi kind.name [.big (Int.ofNat (R.handle handle))]) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (nativeStatusRole_holds ν₀ C₀ identity),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (nativeStatusRole_holds ν C R),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨left,right,post,runtime,
    inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
    inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩

end Host.Load.Run.Full.Ordinary.EvalInventory
