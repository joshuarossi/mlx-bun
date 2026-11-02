import host.sim.compose.a4b.Fill_DEC4_ord_Fixed
import host.route.cert.Dec.Ord.End
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Dec
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Compose

/-! # The decode ends at the fixed list -/

noncomputable def ordEnd (b0 : BSt) (NB : Nat) : EndGM inputs (DEC4_ord.endFixed b0 NB) :=
  let en := Ord.endGM b0 NB
  { outT := en.outT, outs := en.outs, read := en.read, fed := en.fed, caches := en.caches, h1read := en.h1read,
    h1pread := en.h1pread, s1tok := en.s1tok, pout := en.pout, pouts := en.pouts }

end Host.Route.Cert.Dec
