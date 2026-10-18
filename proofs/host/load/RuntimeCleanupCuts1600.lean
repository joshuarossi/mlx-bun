import host.ts.RenameRuntimeDerivedCuts
import host.ts.renameOrdinary.micro.streamed128.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CleanupSource
open Host.Ts Host.Ts.Owned.Annotated
host_derive_source_cuts P.F, P.RestStream.micro0.s16 using (numberServer P.RestStream.micro0.S16) steps 25 as From1600
host_derive_source_cuts P.F, From1600.s25 using From1600.S25 steps 8 as From1625
end Host.Load.Run.Full.Ordinary.CleanupSource
