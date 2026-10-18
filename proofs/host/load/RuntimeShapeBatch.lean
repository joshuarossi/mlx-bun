import host.load.RuntimePrefix
import host.ts.renameOrdinary.DriverPreparation
import host.ts.RenameRetainedChain
import host.ts.RenameRuntimeBatch
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedShapeBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  for (name,value) in [(`initialObject32,mkConst ``Preparation32.sourceValue),(`initialObject34,mkConst ``Preparation34.sourceValue)] do
    let address ← Parametric.Driver.field value ``Val.obj 1 0
    Parametric.Driver.addData ((← getCurrNamespace) ++ name) address

theorem first_initial_cell : P.RestStream.micro0.micro0.s14.heap.get Preparation32.address =
    some (.cell (some (.obj initialObject32))) := by host_kernel_rfl
theorem second_initial_cell : P.RestStream.micro0.micro0.s14.heap.get Preparation34.address =
    some (.cell (some (.obj initialObject34))) := by host_kernel_rfl
theorem namespace_initial_cell : P.RestStream.micro0.micro0.s14.heap.get Preparation28.address =
    some (.cell (some (.obj 607))) := by host_kernel_rfl
theorem export_initial_cell : P.RestStream.micro0.micro0.s14.heap.get 518 =
    some (.cell (some (.obj 2790))) := by host_kernel_rfl

host_runtime_begin
host_source_step P.F, P.RestStream.micro0.micro0.s14 using P.RestStream.micro0.micro0.S14 to P.RestStream.micro0.micro0.s15 using P.RestStream.micro0.micro0.S15 as Step14
host_source_step P.F, P.RestStream.micro0.micro0.s15 using P.RestStream.micro0.micro0.S15 to P.RestStream.micro0.micro0.s16 using P.RestStream.micro0.micro0.S16 as Step15
host_source_step P.F, P.RestStream.micro0.micro0.s16 using P.RestStream.micro0.micro0.S16 to P.RestStream.micro0.micro0.s17 using P.RestStream.micro0.micro0.S17 as Step16
host_source_step P.F, P.RestStream.micro0.micro0.s17 using P.RestStream.micro0.micro0.S17 to P.RestStream.micro0.micro0.s18 using P.RestStream.micro0.micro0.S18 as Step17
host_source_step P.F, P.RestStream.micro0.micro0.s18 using P.RestStream.micro0.micro0.S18 to P.RestStream.micro0.micro0.s19 using P.RestStream.micro0.micro0.S19 as Step18
host_source_step P.F, P.RestStream.micro0.micro0.s19 using P.RestStream.micro0.micro0.S19 to P.RestStream.micro0.micro0.s20 using P.RestStream.micro0.micro0.S20 as Step19
host_source_step P.F, P.RestStream.micro0.micro0.s20 using P.RestStream.micro0.micro0.S20 to P.RestStream.micro0.micro0.s21 using P.RestStream.micro0.micro0.S21 as Step20
host_source_step P.F, P.RestStream.micro0.micro0.s21 using P.RestStream.micro0.micro0.S21 to P.RestStream.micro0.micro0.s22 using P.RestStream.micro0.micro0.S22 as Step21
host_source_step P.F, P.RestStream.micro0.micro0.s22 using P.RestStream.micro0.micro0.S22 to P.RestStream.micro0.micro0.s23 using P.RestStream.micro0.micro0.S23 as Step22
host_source_step P.F, P.RestStream.micro0.micro0.s23 using P.RestStream.micro0.micro0.S23 to P.RestStream.micro0.micro0.s24 using P.RestStream.micro0.micro0.S24 as Step23
host_source_step P.F, P.RestStream.micro0.micro0.s24 using P.RestStream.micro0.micro0.S24 to P.RestStream.micro0.micro0.s25 using P.RestStream.micro0.micro0.S25 as Step24
host_source_step P.F, P.RestStream.micro0.micro0.s25 using P.RestStream.micro0.micro0.S25 to P.RestStream.micro0.micro0.s26 using P.RestStream.micro0.micro0.S26 as Step25
host_source_step P.F, P.RestStream.micro0.micro0.s26 using P.RestStream.micro0.micro0.S26 to P.RestStream.micro0.micro0.s27 using P.RestStream.micro0.micro0.S27 as Step26
host_source_step P.F, P.RestStream.micro0.micro0.s27 using P.RestStream.micro0.micro0.S27 to P.RestStream.micro0.micro0.s28 using P.RestStream.micro0.micro0.S28 as Step27
host_source_step P.F, P.RestStream.micro0.micro0.s28 using P.RestStream.micro0.micro0.S28 to P.RestStream.micro0.micro0.s29 using P.RestStream.micro0.micro0.S29 as Step28
host_source_step P.F, P.RestStream.micro0.micro0.s29 using P.RestStream.micro0.micro0.S29 to P.RestStream.micro0.micro0.s30 using P.RestStream.micro0.micro0.S30 as Step29
host_source_step P.F, P.RestStream.micro0.micro0.s30 using P.RestStream.micro0.micro0.S30 to P.RestStream.micro0.micro0.s31 using P.RestStream.micro0.micro0.S31 as Step30
host_source_step P.F, P.RestStream.micro0.micro0.s31 using P.RestStream.micro0.micro0.S31 to P.RestStream.micro0.micro0.s32 using P.RestStream.micro0.micro0.S32 as Step31
host_source_step P.F, P.RestStream.micro0.micro0.s32 using P.RestStream.micro0.micro0.S32 to P.RestStream.micro0.micro0.s33 using P.RestStream.micro0.micro0.S33 as Step32
host_source_step P.F, P.RestStream.micro0.micro0.s33 using P.RestStream.micro0.micro0.S33 to P.RestStream.micro0.micro0.s34 using P.RestStream.micro0.micro0.S34 as Step33
host_source_step P.F, P.RestStream.micro0.micro0.s34 using P.RestStream.micro0.micro0.S34 to P.RestStream.micro0.micro0.s35 using P.RestStream.micro0.micro0.S35 as Step34
host_source_step P.F, P.RestStream.micro0.micro0.s35 using P.RestStream.micro0.micro0.S35 to P.RestStream.micro0.micro0.s36 using P.RestStream.micro0.micro0.S36 as Step35
host_source_step P.F, P.RestStream.micro0.micro0.s36 using P.RestStream.micro0.micro0.S36 to P.RestStream.micro0.micro0.s37 using P.RestStream.micro0.micro0.S37 as Step36
host_source_step P.F, P.RestStream.micro0.micro0.s37 using P.RestStream.micro0.micro0.S37 to P.RestStream.micro0.micro0.s38 using P.RestStream.micro0.micro0.S38 as Step37
host_source_step P.F, P.RestStream.micro0.micro0.s38 using P.RestStream.micro0.micro0.S38 to P.RestStream.micro0.micro0.s39 using P.RestStream.micro0.micro0.S39 as Step38

host_retained_theorem composed := fun (notes : RetainedNotes) (caller : List Annotated.Tree) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S14) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s14 s)
    (inventory : RetainedInventory (RetainedShapePrefix.EndNotes notes caller
      [.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 10240))])
      ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s14 s)
    (budget : s.next + 32 ≤ 2^64)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (exportEntry : notes.runtime.cells.cells 518 = some (.obj 2790))
    (namespaceEntry : notes.runtime.cells.cells Preparation28.address = some (.obj 607))
    (firstEntry : notes.runtime.cells.cells Preparation32.address = some (.obj initialObject32))
    (secondEntry : notes.runtime.cells.cells Preparation34.address = some (.obj initialObject34)) => by
  host_retained_chain P.F, [Step14.retained_transport,Step15.retained_transport,Step16.retained_transport,Step17.retained_transport,Step18.retained_transport,Step19.retained_transport,Step20.retained_transport,Step21.retained_transport,Step22.retained_transport,Step23.retained_transport,Step24.retained_transport,Step25.retained_transport,Step26.retained_transport,Step27.retained_transport,Step28.retained_transport,Step29.retained_transport,Step30.retained_transport,Step31.retained_transport,Step32.retained_transport,Step33.retained_transport,Step34.retained_transport,Step35.retained_transport,Step36.retained_transport,Step37.retained_transport,Step38.retained_transport] using h, inventory, inst
host_runtime_export composed as shape_to_concat
end Host.Load.Run.Full.Ordinary.RetainedShapeBatch
