import host.load.RuntimeDriver
import host.ts.RenameRetainedChain
import host.ts.renameOrdinary.MlxRegistrySteps

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RuntimePrivateObjectDispatchTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_source_step P.F, P.RestStream.micro0.micro4.s3 using P.RestStream.micro0.micro4.S3
  to P.RestStream.micro0.micro4.s4 using P.RestStream.micro0.micro4.S4 as Token403

host_retained_theorem current_token := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Token403.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Token403.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Token403.input s)
    (head : Annotated.Tree) (tail : List Annotated.Tree)
    (stackNotes : notes.runtime.stack = head::tail) => by
  host_retained_chain P.F, [Token403.retained_transport] using h, inventory, inst

host_assert_retained_schema current_token, 1

end Host.Load.Run.Full.Ordinary.RuntimePrivateObjectDispatchTest
