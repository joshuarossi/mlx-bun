import host.load.RuntimeShapeBatch
import host.ts.renameOrdinary.DriverParameters
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedParameterBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let value ← Parametric.Driver.field (mkConst ``Parameter45.sourceValue) ``Val.big 1 0
  Parametric.Driver.addData ((← getCurrNamespace) ++ `defaultStreamHandle) value

theorem default_stream_initial_cell : P.RestStream.micro0.micro0.s14.heap.get Parameter45.address =
    some (.cell (some (.big defaultStreamHandle))) := by host_kernel_rfl

theorem default_stream_handle : defaultStreamHandle.toNat = 2 := by host_kernel_rfl

host_source_step P.F, P.RestStream.micro0.micro0.s39 using P.RestStream.micro0.micro0.S39 to P.RestStream.micro0.micro0.s40 using P.RestStream.micro0.micro0.S40 as Step39
host_source_step P.F, P.RestStream.micro0.micro0.s40 using P.RestStream.micro0.micro0.S40 to P.RestStream.micro0.micro0.s41 using P.RestStream.micro0.micro0.S41 as Step40
host_source_step P.F, P.RestStream.micro0.micro0.s41 using P.RestStream.micro0.micro0.S41 to P.RestStream.micro0.micro0.s42 using P.RestStream.micro0.micro0.S42 as Step41
host_source_step P.F, P.RestStream.micro0.micro0.s42 using P.RestStream.micro0.micro0.S42 to P.RestStream.micro0.micro0.s43 using P.RestStream.micro0.micro0.S43 as Step42
host_source_step P.F, P.RestStream.micro0.micro0.s43 using P.RestStream.micro0.micro0.S43 to P.RestStream.micro0.micro0.s44 using P.RestStream.micro0.micro0.S44 as Step43
host_source_step P.F, P.RestStream.micro0.micro0.s44 using P.RestStream.micro0.micro0.S44 to P.RestStream.micro0.micro0.s45 using P.RestStream.micro0.micro0.S45 as Step44
host_source_step P.F, P.RestStream.micro0.micro0.s45 using P.RestStream.micro0.micro0.S45 to P.RestStream.micro0.micro0.s46 using P.RestStream.micro0.micro0.S46 as Step45
host_source_step P.F, P.RestStream.micro0.micro0.s46 using P.RestStream.micro0.micro0.S46 to P.RestStream.micro0.micro0.s47 using P.RestStream.micro0.micro0.S47 as Step46
host_source_step P.F, P.RestStream.micro0.micro0.s47 using P.RestStream.micro0.micro0.S47 to P.RestStream.micro0.micro0.s48 using P.RestStream.micro0.micro0.S48 as Step47
host_source_step P.F, P.RestStream.micro0.micro0.s48 using P.RestStream.micro0.micro0.S48 to P.RestStream.micro0.micro0.s49 using P.RestStream.micro0.micro0.S49 as Step48

host_retained_theorem composed := fun (notes : RetainedNotes) (caller : List Annotated.Tree) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S14) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s14 s)
    (inventory : RetainedInventory (RetainedShapePrefix.EndNotes notes caller
      [.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 10240))])
      ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s14 s)
    (budget : s.next + 64 ≤ 2^64)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (exportEntry : notes.runtime.cells.cells 518 = some (.obj 2790))
    (namespaceEntry : notes.runtime.cells.cells Preparation28.address = some (.obj 607))
    (firstEntry : notes.runtime.cells.cells Preparation32.address = some (.obj initialObject32))
    (secondEntry : notes.runtime.cells.cells Preparation34.address = some (.obj initialObject34))
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Parameter45.address = some (.handle defaultStreamHandle.toNat)) => by
  have earlier := RetainedShapeBatch.shape_to_concat notes caller ν₀ ν C₀ C R FR live framed
    before after old old' s inst h inventory (by omega) arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry
  have post39 := Classical.choose_spec earlier
  have run39 := post39.1
  have h39 := post39.2.1
  have inv39 := post39.2.2.1
  have inst39 := post39.2.2.2
  host_retained_chain_after P.F, [Step39.retained_transport,Step40.retained_transport,Step41.retained_transport,Step42.retained_transport,Step43.retained_transport,Step44.retained_transport,Step45.retained_transport,Step46.retained_transport,Step47.retained_transport,Step48.retained_transport]
    using h39, inv39, inst39 continuing_run run39 initial_relation h
host_retained_theorem shape_to_body := composed
host_assert_retained_schema shape_to_body, 35
end Host.Load.Run.Full.Ordinary.RetainedParameterBatch
