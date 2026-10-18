import host.load.run.full.FirstSource
import host.mlx.ReadbackValues
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
open Host.Ts Host.Mlx Host.Mlx.Ffi Host.Mlx.FfiEval

/-- The actual first producing node is memoized under the first read symbol. -/
theorem first_read_symbol : P.s2974.ffi.mlx.items.get 17776 = some (.ref 1) := by rfl

theorem first_read_memo : P.s2974.ffi.mlx.items = (PTrie.nil.set 17776 (.ref 1)) := by rfl

theorem first_read_expression : P.S2974.val (.ref 1) = some (.var 1) := by rfl

/-- The next decode reuses the device token through a reshape. -/
theorem first_feedback_node : P.s2975.ffi.mlx.nodes.get 17777 = some
    ⟨.reshape (lits [1,1]), [17776], lits [1,1], 3⟩ := by rfl

end Host.Load.Run.Full
