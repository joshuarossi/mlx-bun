import host.load.boot.ane.BridgeStates
import host.load.boot.States
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Load.Boot
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Bridge piece 2: the next 548 creates onto `aneB1`. -/

kernel_rfl_eager aneB_step2 : replayOnto aneB1 ((P.oblog2818.drop 1096).take 548) = aneB2

end Host.Load.Run.Prompt
