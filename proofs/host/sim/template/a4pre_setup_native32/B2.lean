import host.sim.template.a4pre_setup_native32.B1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Load.Boot

kernel_rfl_eager PREBridgeParts.checked2 :
  replayOnto PREBridgeParts.b1 ((Host.Load.Run.Prompt.P.oblog2818.drop 1096).take 548) =
    PREBridgeParts.b2

end Host.Load.Run.Tpl
