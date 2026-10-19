import host.ts.RenameRuntimeDerivedCuts
import host.ts.renameOrdinary.micro.streamed128.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.OptIntSource
open Host.Ts Host.Ts.Owned.Annotated
host_derive_source_cuts P.F, P.RestStream.micro0.s81 using (numberServer P.RestStream.micro0.S81) steps 25 as From8100
host_derive_source_cuts P.F, From8100.s25 using From8100.S25 steps 25 as From8125
host_derive_source_cuts P.F, From8125.s25 using From8125.S25 steps 25 as From8150
host_derive_source_cuts P.F, From8150.s25 using From8150.S25 steps 1 as From8175
end Host.Load.Run.Full.Ordinary.OptIntSource
