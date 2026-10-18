import host.load.growth.Geometry
import host.load.growth.Steps
import host.load.Compose
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chain_run_staged Growth256

/-- This is execution from the explicit method entry, not a claim that the
five-token source run reaches capacity 256. -/
theorem Growth256.execution :
    runS Host.Load.ffi 4570 Growth256.entry Growth256.srv = some (Growth256.s5, Growth256.S5) := by
  exact Growth256.run

theorem Growth256.capacity_aligned : Growth.CapacityInvariant 256 := by
  change 0 < 256 ∧ 256 % 256 = 0
  decide

theorem Growth256.caller_preserved : Growth256.s5.stack = Growth256.entry.stack := by rfl

theorem Growth256.offset_after : Growth256.outcome.offset = 257 := by rfl

theorem Growth256.buffer_key_header : Growth.tensorHeader Growth256.outcome.bufferKey [1,4,512,256] := by
  exact ⟨rfl, rfl⟩
theorem Growth256.buffer_value_header : Growth.tensorHeader Growth256.outcome.bufferValue [1,4,512,256] := by
  exact ⟨rfl, rfl⟩
theorem Growth256.fetched_key_header : Growth.tensorHeader Growth256.outcome.fetchedKey [1,4,257,256] := by
  exact ⟨rfl, rfl⟩
theorem Growth256.fetched_value_header : Growth.tensorHeader Growth256.outcome.fetchedValue [1,4,257,256] := by
  exact ⟨rfl, rfl⟩

theorem Growth256.node_count : Growth256.s5.ffi.mlx.nnext = Growth256.entry.ffi.mlx.nnext + 8 := by rfl

end Host.Load.Run.Full
