import host.sim.template.a4pre_setup_native32.B4b
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Load.Boot

theorem PRENative32.bridge_exact :
    replay Host.Load.Run.Prompt.P.oblog2818 = PRENative32.s0.ffi.1.1.bridge := by
  have h1 : (Host.Load.Run.Prompt.P.oblog2818.drop 548).drop 548 =
      Host.Load.Run.Prompt.P.oblog2818.drop 1096 := by rw [List.drop_drop]
  have h2 : (Host.Load.Run.Prompt.P.oblog2818.drop 1096).drop 548 =
      Host.Load.Run.Prompt.P.oblog2818.drop 1644 := by rw [List.drop_drop]
  rw [replay_onto, replayOnto_split _ _ 548,
    replayOnto_split _ (Host.Load.Run.Prompt.P.oblog2818.drop 548) 548, h1,
    replayOnto_split _ (Host.Load.Run.Prompt.P.oblog2818.drop 1096) 548, h2,
    PREBridgeParts.checked1, PREBridgeParts.checked2, PREBridgeParts.checked3,
    PREBridgeParts.checked4]

end Host.Load.Run.Tpl
