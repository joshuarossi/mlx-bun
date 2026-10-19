import host.load.RuntimeNamespacedDecodePlan1286
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated

host_retained_theorem rank_to_shape_call := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Meta1285.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' At1285.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live At1285.s0 s)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle Meta1285.handle])
    (numberFnRole numberThisRole : Annotated.Value)
    (retNote blockNote scopeNote boundaryNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
    (stackNotes : notes.runtime.stack =
      argumentFrameNote false 0 numberFnRole numberThisRole [] [] Plan1286.Block0.sourceArgEnv ::
      retNote::blockNote::scopeNote::boundaryNote::callerNotes)
    (receiverEntry : notes.runtime.cells.cells Plan1286.Block24.sourceAddress =
      some (.obj Plan1286.Block26.sourceOwner))
    (privateEntry : notes.privates.owners Plan1286.Block26.sourceOwner =
      some ⟨Plan1286.Block26.sourceBrand,Plan1286.Block26.sourceHandleName,.handle Meta1285.handle⟩)
    (budget : s.next+16 ≤ 2^64)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Meta1285.types) (owned : H Meta1285.handle) => by
  have numberRole : IntegerNumberRole (.ordinaryBig (Int.ofNat (len Meta1285.node.shape)))
      (.lit (F64.ofInt (Int.ofNat (len Meta1285.node.shape)))) := .ordinary _
  host_retained_plan_chain P.F, RankToShapeCall using state, inventory, inst

host_assert_retained_schema rank_to_shape_call, 45

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema rank_to_shape_call, 46

end Host.Load.Run.Full.Ordinary.NamespacedDecode
