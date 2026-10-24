import host.load.boot.ane.BridgeStates
import host.load.boot.States
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Load.Boot
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Bridge piece 3: the next 548 creates onto `aneB2`. -/

kernel_rfl_eager aneB_step3 : replayOnto aneB2 ((P.oblog2818.drop 548).take 548) = aneB3

end Host.Load.Run.Prompt
