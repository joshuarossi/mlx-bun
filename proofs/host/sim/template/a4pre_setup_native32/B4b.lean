import host.sim.template.a4pre_setup_native32.B4a
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Load.Boot

kernel_rfl_eager PREBridgeParts.checked4b :
  replayOnto PREBridgeTail.b4a ((Host.Load.Run.Prompt.P.oblog2818.take 548).take 274) =
    PRENative32.s0.ffi.1.1.bridge

theorem PREBridgeParts.checked4 :
    replayOnto PREBridgeParts.b3 (Host.Load.Run.Prompt.P.oblog2818.take 548) =
      PRENative32.s0.ffi.1.1.bridge := by
  rw [replayOnto_split _ _ 274, PREBridgeParts.checked4a, PREBridgeParts.checked4b]

end Host.Load.Run.Tpl
