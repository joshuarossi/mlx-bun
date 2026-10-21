import host.ts.renameOrdinary.Frames
import host.load.ReadTail
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

/- `P.ta<k>` for the decode boundaries before the first ordinary readback cut.
Boundary 0 knows the heads `.ref 1, .ref 2`; the command checks that the
abstracted suffix is `Frames`'s `P.tokenBase` (`.ref 3, …, .ref 8`), and
`Frames` supplies `P.ta3272` over the same suffix. Chunk 2973 consumes `.ref 1`. -/
host_read_tail P 0, 3271 keep 2

end Host.Load.Run.Full
