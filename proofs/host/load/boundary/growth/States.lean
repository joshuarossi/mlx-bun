import host.load.BoundaryCommand
import host.load.run.full.H102
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

-- A 64-layer source entry specialization; reachability and incoming contents
-- are separate obligations of the general source loop invariant.
host_cache_boundary Growth64 : P.s3273, P.S3273, Decode.valuation, 256, 10000, 1000

end Host.Load.Run.Full
