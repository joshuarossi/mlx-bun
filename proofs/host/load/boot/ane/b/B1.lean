import host.load.boot.ane.BridgeStates
import host.load.boot.States
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Load.Boot
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Bridge piece 1: the oldest 548 creates onto the empty bridge. -/

kernel_rfl_eager aneB_step1 : replayOnto Host.Mlx.FfiAne.St.empty (P.oblog2818.drop 1644) = aneB1

end Host.Load.Run.Prompt
