import host.sim.template.a4pre_setup_native32.B2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Load.Boot

kernel_rfl_eager PREBridgeParts.checked3 :
  replayOnto PREBridgeParts.b2 ((Host.Load.Run.Prompt.P.oblog2818.drop 548).take 548) =
    PREBridgeParts.b3

end Host.Load.Run.Tpl
