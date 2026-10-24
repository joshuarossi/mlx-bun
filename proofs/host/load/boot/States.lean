import host.load.run.prompt.H88
import host.load.boot.Command
set_option Elab.async false
namespace Host.Load.Run.Prompt
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The observer's states at the prompt boot's boundaries (`boot_w_states`) and the boundary states over every
unread readback suffix (`boot_tail_states`). -/

boot_w_states P
boot_tail_states P keep 2

end Host.Load.Run.Prompt
