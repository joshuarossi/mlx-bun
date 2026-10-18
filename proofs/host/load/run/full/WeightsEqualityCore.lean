import host.load.run.full.WeightsCoverage
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers
macro "parameter_congr " h:ident : tactic => `(tactic|
  repeat' first
    | exact $h _ (by parameter_coverage)
    | congr 1)

end Host.Load.Run.Full
