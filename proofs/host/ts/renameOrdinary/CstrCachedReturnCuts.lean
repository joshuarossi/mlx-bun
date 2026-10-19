import host.ts.renameOrdinary.CstrCachedStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CstrCachedStates
host_derive_source_cuts P.F, Body.s25 using Body.S25 steps 5 as Return
end Host.Load.Run.Full.Ordinary.CstrCachedStates
