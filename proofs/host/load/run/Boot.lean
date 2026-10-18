import host.load.link.States
import host.load.run.S0.States
namespace Host.Load.Run
open Host.Ts

-- The linked machine is segment 0's first state.
set_option maxRecDepth 1000000 in
kernel_rfl boot_join : Host.Load.Link.L.x42.st = S0.P.s0

end Host.Load.Run
