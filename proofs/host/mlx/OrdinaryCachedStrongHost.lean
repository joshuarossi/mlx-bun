import host.mlx.OrdinaryCachedHost
import host.mlx.OrdinaryCachedStrong

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedStrongHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def NativeRelation (ν₀ ν : Nat → F64) (C₀ C : CSrv) (base : Nat → GraphNode)
    (objects : Nat → Object) (H N : Nat → Prop) (tail : List NumV)
    (host : HostSt → HostSt → Prop) (R : Ren) (s₀ s : LSt) : Prop :=
  host s₀.host s.host ∧
    Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel (CachedCall.roles (CachedCall.coupledRoles base)) ν₀ ν C₀ C R CachedCall.boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s₀.mlx s.mlx

/-- The actual ordinary host call retains every selected fixed native object
annotation, including numeric configuration and captured callback payloads.
The result-vector annotation is updated to the three replayed output nodes. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (objects : Nat → Object) (H frame : Nat → Prop) (tail : List NumV)
    (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (NativeRelation ν₀ ν C₀ C base objects H (fun i => CachedCall.N0 i ∨ frame i) tail host)
      R live framed before after old old' CachedHost.input s)
    (closureRole : (Host.Ts.Owned.Annotated.Value.handle 1354).Holds ν C R (callArgument s.ctl 1))
    (vectorRole : (Host.Ts.Owned.Annotated.Value.handle 29376).Holds ν C R (callArgument s.ctl 2))
    (slotRole : (slotKindRole 29377).Holds ν C R (objectKindAt s (R.a 3126924)))
    (signatureFrame : ¬ framed 4557)
    (closureLive : H 1354) (vectorLive : H 29376) (outputLive : H 29377)
    (nodesBound : s.ffi.mlx.nnext + CachedCall.trace.order.length < 2^64)
    (handlesBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ t, interpC (step CachedHost.F CachedHost.input).run C₀ = some (CachedHost.output,C₀) ∧
      interpC (step CachedHost.F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (NativeRelation ν₀ ν C₀ C base (CachedCall.outputObjectRoles objects) H
          (fun i => CachedCall.N3 i ∨ frame i) tail host)
        R live framed before after old old' CachedHost.output t ∧
      (slotKindRole 29377).Holds ν C R (objectKindAt t (R.a 3126924)) := by
  have hn := h.native.2
  change Live _ R _ _ H (fun i => CachedCall.N0 i ∨ frame i) tail CachedCall.source s.ffi.mlx at hn
  obtain ⟨nt,_,htCall,hnAfter,_⟩ := CachedCall.cached_call_objects frame base objects hn
    closureLive vectorLive outputLive nodesBound handlesBound
  let native' : LSt := {s.ffi with mlx := nt.setObj (R.handle 29377) (.vec ([22591,22592,22593].map R.node))}
  have hn' : NativeRelation ν₀ ν C₀ C base (CachedCall.outputObjectRoles objects) H
      (fun i => CachedCall.N3 i ∨ frame i) tail host R CachedHost.sourceNative native' :=
    ⟨h.native.1,hnAfter⟩
  exact CachedHost.dispatch_native ν₀ ν C₀ C R live framed before after old old' s h native' hn'
    (by simpa only [CachedHost.F,native'] using CachedHost.load_call_cached s.ffi _ _ _ htCall)
    closureRole vectorRole slotRole signatureFrame heapBound

end Host.Load.Run.Full.Ordinary.CachedStrongHost
