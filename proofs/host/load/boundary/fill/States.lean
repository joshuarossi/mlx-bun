import host.load.BoundaryCommand
import host.load.run.full.H102
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

-- Filling the last available row follows the no-growth path and aliases
-- both full fetched buffers. This is an explicit source entry, not a claim
-- that the five-token route reaches position 255.
host_cache_boundary Fill64 : P.s3273, P.S3273, Decode.valuation, 255, 10000, 1000

end Host.Load.Run.Full
