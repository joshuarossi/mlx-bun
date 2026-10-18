import host.load.run.full.FirstCertificate
namespace Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
theorem first_token_carrier : certAt firstCarriers Expected.tokenNode = 17776 := by rfl

theorem first_cache_carriers :
    Expected.cacheOutputs.map (fun (a,b) => (some (certAt firstCarriers a), some (certAt firstCarriers b))) =
      firstChoice.cache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) := by rfl

end Host.Load.Run.Full
