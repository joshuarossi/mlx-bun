import host.load.boot.ane.BridgeStates
import host.load.boot.States
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Load.Boot
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Bridge piece 4: the newest 548 creates onto `aneB3`. -/

kernel_rfl_eager aneB_step4 : replayOnto aneB3 (P.oblog2818.take 548) = aneB4

end Host.Load.Run.Prompt
