import host.ts.RenameRuntimeDerivedCuts
import host.ts.renameOrdinary.micro.streamed128.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.SizeSource
open Host.Ts Host.Ts.Owned.Annotated
host_derive_source_cuts P.F, P.RestStream.micro0.s93 using (numberServer P.RestStream.micro0.S93) steps 25 as From9300
host_derive_source_cuts P.F, From9300.s25 using From9300.S25 steps 12 as From9325
end Host.Load.Run.Full.Ordinary.SizeSource
