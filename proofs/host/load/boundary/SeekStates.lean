import host.load.boundary.growth.Parameters
import host.load.boundary.fill.Parameters
import host.load.Micro
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full
namespace BoundarySeek
noncomputable def F := P.F
def ks : List Nat := [10000]
noncomputable def s0 := P.s3273
noncomputable def S0 := P.S3273
noncomputable def s1 := P.s3274
noncomputable def S1 := P.S3274
end BoundarySeek
-- Only the first 2056 steps are proved in Seek. The final remainder is
-- untrusted choice data and introduces no additional execution claim.
host_micro_states BoundarySeek 0, 1000 chunks [1000,1000,56,7944]
end Host.Load.Run.Full
