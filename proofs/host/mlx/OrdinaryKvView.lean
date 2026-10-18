import host.mlx.OrdinaryKvViewSource
import host.mlx.NativeKvViewFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.KvView
open Host.Ts Host.Mlx.Ffi

host_retained_kvView Host.Load.ffi, KvViewSource.input using KvViewSource.initialServer
  to KvViewSource.output using KvViewSource.nextServer as Source50036

theorem source_geometry : Source50036.node.shape = ([1,4,256,256] : List Int).map Dim.lit := rfl
theorem source_producer_id : Source50036.producer = 22672 := rfl
theorem source_branch : Source50036.kind = NativeRoles.SliceResult.fresh := rfl
theorem source_counters : Source50036.output.ffi.mlx.next = Source50036.input.ffi.mlx.next+1 ∧
    Source50036.output.ffi.mlx.nnext = Source50036.input.ffi.mlx.nnext+1 := ⟨rfl,rfl⟩

/-- error: host_retained_kvView: expected source call -/
#guard_msgs in
host_retained_kvView Host.Load.ffi, Source50036.output using KvViewSource.nextServer
  to Source50036.output using KvViewSource.nextServer as RejectReturn

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_kvView Host.Load.ffi, Source50036.input using KvViewSource.initialServer to Source50036.input using KvViewSource.initialServer as RejectWrongEndpoint"
  finally Lean.setEnv saved

end Host.Load.Run.Full.Ordinary.KvView
