import host.load.run.full.link.Run
import host.load.run.full.G0
set_option Elab.async false
namespace Host.Load.Run.Full
open Host.Ts Host.Load

set_option maxRecDepth 1000000 in
kernel_rfl link_join : Link.L.x840.st = P.s0

theorem P.boot_eq : P.boot = some P.s0 := by
  rw [Link.L.booted 2000 (by decide)]
  exact congrArg some link_join

set_option maxRecDepth 1000000 in
theorem P.srv_eq : P.srv = P.S0 := by rfl

end Host.Load.Run.Full
