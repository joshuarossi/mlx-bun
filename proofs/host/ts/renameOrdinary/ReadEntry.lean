import host.ts.RenameLoadReadback
import host.ts.RenameLoopInvariant
import host.load.run.full.H106
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts

noncomputable def objectAt (a : Nat) : Host.Ts.Obj := (P.s3272.obj? a).getD ⟨.ordinary,.undef,[],[],true⟩
noncomputable def currentNode : Host.Mlx.Ffi.Node := (P.s3272.ffi.mlx.node? 25658).getD ⟨.zeros,[],[],0⟩
noncomputable def readBytes : List Byte := match (objectAt 3123575).kind with | .buf bs => bs | _ => []
def remainingReads : List NumV := [.ref 3,.ref 4,.ref 5,.ref 6,.ref 7,.ref 8]

theorem actual_read_control : P.s3272.ctl =
    .call (.obj 4711) (.obj 4817) [.ptr (.js 3123575) 0,.big (Int.ofNat 25658)] := rfl

theorem actual_generated : (LoopPlace.cell 2673316).read P.s3272 = some (natV 1) := rfl
theorem actual_stepIndex : (LoopPlace.cell 2975684).read P.s3272 = some (natV 1) := rfl

noncomputable def afterReadNative : Host.Load.LSt :=
  { P.s3272.ffi with mlx := { P.s3272.ffi.mlx with
      tokens := remainingReads, items := P.s3272.ffi.mlx.items.set 20157 (.ref 2) } }
noncomputable def afterReadBuffer : St Host.Load.LSt :=
  (P.s3272.setFfi afterReadNative).setObj 3123575
    { objectAt 3123575 with kind := .buf (readBytes.take 0 ++ cellParts .u32 (.num (.ref 2)) 4 0 ++ readBytes.drop 4) }
noncomputable def afterRead : St Host.Load.LSt :=
  (afterReadBuffer.setTrace (⟨chars!"mlx_array_item_uint32",
    [.jsPtr 3123575 0 (readBytes.drop 0),.big (Int.ofNat 25658)],Host.Mlx.Ffi.status0⟩ ::
      afterReadBuffer.trace)).ret (.num zeroN)

/-- The actual source entry, including its nonundefined receiver, specializes
through the whole real-world uint32 call, buffer write, trace and status return. -/
theorem actual_read_materialize (C : CSrv) :
    step Host.Load.ffi P.s3272 = M.pure afterRead ∧
      step Host.Load.ffi (materializeStateWith Host.Load.materializeWorld C P.s3272) =
        M.pure (materializeStateWith Host.Load.materializeWorld C afterRead) := by
  exact Host.Load.step_itemU32_materialize C P.s3272
    4711 4415 3123575 0 25658 20157 chars!"i32"
    (objectAt 4711) (objectAt 4415) (objectAt 3123575) readBytes currentNode (.ref 2) remainingReads
    actual_read_control rfl rfl rfl rfl rfl rfl rfl rfl rfl rfl rfl

end Host.Load.Run.Full.Ordinary
