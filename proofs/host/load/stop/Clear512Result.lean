import host.load.stop.Clear512States
import host.load.stop.Clear256Result
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chunk Clear512 0
host_chain_run_staged Clear512

theorem Clear512.execution :
    runS Host.Load.ffi 32 Clear512.entry Clear512.srv = some (Clear512.s1, Clear512.S1) :=
  Clear512.run

theorem Clear512.source_control :
    Clear512.entry.ctl = .ex Clear256.statement Clear256.localEnv := by rfl

theorem Clear512.generated_value :
    Clear512.entry.cell? Clear256.generatedCell = some (some (.num (.lit (F64.ofNat 513)))) := by rfl

theorem Clear512.periodic : (513 - 1) % 256 = 0 := by decide

theorem Clear512.after_clear : Stop.afterClear Clear512.s1 = true := by rfl

theorem Clear512.native_state_preserved : Clear512.s1.ffi = Clear512.entry.ffi := by rfl

theorem Clear512.caller_preserved : Clear512.s1.stack.tail = Clear512.entry.stack.tail := by rfl

theorem Clear512.heap_extension :
    Clear512.s1.heap = Clear512.entry.heap.set Clear512.entry.next (.cell (some .undef)) := by rfl

theorem Clear512.old_heap_preserved (i : Nat) (hi : i < Clear512.entry.next) :
    Clear512.s1.heap.get i = Clear512.entry.heap.get i := by
  rw [Clear512.heap_extension]
  exact PTrie.get_set_ne _ _ _ (by decide) i (Nat.ne_of_lt hi)

theorem Clear512.one_event : Clear512.s1.trace.tail = Clear512.entry.trace := by rfl

theorem Clear512.clear_called :
    (Clear512.s1.trace.head?.map (·.sym)) = some chars!"mlx_clear_cache" := by rfl

end Host.Load.Run.Full
