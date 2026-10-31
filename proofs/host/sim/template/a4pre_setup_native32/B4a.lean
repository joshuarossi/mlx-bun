import host.sim.template.a4pre_setup_native32.B3
import host.sim.template.a4pre_setup_native32.BridgeTailData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Load.Boot

kernel_rfl_eager PREBridgeParts.checked4a :
  replayOnto PREBridgeParts.b3 ((Host.Load.Run.Prompt.P.oblog2818.take 548).drop 274) =
    PREBridgeTail.b4a

end Host.Load.Run.Tpl
