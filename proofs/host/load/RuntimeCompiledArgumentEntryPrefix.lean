import host.ts.renameOrdinary.micro.streamed128.H0
import host.ts.RenameRuntimeDerivedCuts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
-- Actual source steps 2000–2056 from the existing s20/S20 boundary.
-- The native release at 2056 is materialized separately.
host_derive_source_cuts P.F, P.RestStream.micro0.s20 using P.RestStream.micro0.S20 steps 25 as From2000
host_derive_source_cuts P.F, From2000.s25 using From2000.S25 steps 25 as From2025
host_derive_source_cuts P.F, From2025.s25 using From2025.S25 steps 6 as From2050
end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
