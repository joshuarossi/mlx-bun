import host.mlx.OrdinaryCachedAnnotations
import host.mlx.NativeObjectAnnotations

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

noncomputable section

namespace Host.Load.Run.Full.Ordinary.CachedCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

noncomputable def traceRole : Host.Mlx.Ffi.Annotated.Trace := ⟨trace.ins,trace.outs,trace.order⟩

def payloadRole : Host.Ts.Owned.Annotated.Tree :=
  .node "Arg.num" [.number (.lit (.fin false 2 0))]

noncomputable def kernelObjectRole : Host.Mlx.Ffi.Annotated.Object := match source.obj? 18182 with
  | some (.kernel name body header inputs outputs) => .kernel name body header inputs outputs
  | _ => .vec []

noncomputable def objectRoles (rest : Nat → Host.Mlx.Ffi.Annotated.Object)
    (handle : Nat) : Host.Mlx.Ffi.Annotated.Object := match handle with
  | 1354 => .closure (.compiled 281474976715599 payloadRole false [traceRole])
  | 29376 => .vec inputs
  | 29377 => .vec []
  | 18182 => kernelObjectRole
  | _ => rest handle

noncomputable def initialObject (handle : Nat) : Host.Mlx.Ffi.Obj := (source.obj? handle).getD (.vec [])

theorem trace_annotation : traceRole.Holds Host.Ts.Owned.Annotated.identity trace := ⟨rfl,rfl,rfl⟩

theorem payload_annotation (ν : Nat → F64) (C : CSrv) :
    payloadRole.Holds ν C Host.Ts.Owned.Annotated.identity (Host.Ts.Owned.Parametric.arg payload) :=
  .node _ (.cons (.number _ _ rfl) .nil)

theorem initial_object_lookup (handle : Nat) (live : requiredHandles handle) :
    source.obj? handle = some (initialObject handle) := by
  simp [requiredHandles] at live
  rcases live with rfl | rfl | rfl | rfl <;> host_kernel_rfl

/-- The closure's fixed payload and ordered trace, the live input and output
vectors, and the captured kernel's complete source and header are checked. -/
theorem initial_object_annotations (ν : Nat → F64) (C : CSrv)
    (rest : Nat → Host.Mlx.Ffi.Annotated.Object) (handle : Nat) (live : requiredHandles handle) :
    (objectRoles rest handle).Holds ν C Host.Ts.Owned.Annotated.identity (initialObject handle) := by
  simp [requiredHandles] at live
  rcases live with rfl | rfl | rfl | rfl
  · exact .closure (.compiled 281474976715599 false (payload_annotation ν C) (.cons trace_annotation .nil))
  · exact .vec inputs
  · exact .vec []
  · exact .kernel _ _ _ _ _

theorem initial_object_relation {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (rest : Nat → Host.Mlx.Ffi.Annotated.Object) (handle : Nat) (live : requiredHandles handle)
    (obj obj' : Host.Mlx.Ffi.Obj) (lookup : source.obj? handle = some obj)
    (target : (objectRoles rest handle).Holds ν C R obj') :
    Host.Mlx.Ffi.Annotated.ObjectRel (objectRoles rest) ν₀ ν C₀ C R handle obj obj' := by
  have he : initialObject handle = obj := Option.some.inj ((initial_object_lookup handle live).symm.trans lookup)
  subst obj
  exact ⟨initial_object_annotations ν₀ C₀ rest handle live,target⟩

end Host.Load.Run.Full.Ordinary.CachedCall
