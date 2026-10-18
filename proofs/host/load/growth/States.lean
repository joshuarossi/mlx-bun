import host.load.GrowthCommand
import host.load.run.full.H102
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

-- This is a method-local entry specialization, not a reachable loop cut.
-- Growth.Entry and Growth.Contents describe the invariant obligations.
host_growth_fragment Growth256 from P.s3272, P.S3272
  valuation Host.Load.Decode.valuation seek 300000 width 1000

end Host.Load.Run.Full
