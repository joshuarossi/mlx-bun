import host.load.boot.States
import host.sim.template.RestartCmd
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The `loadDone` state for the frame facts

`Ld.s0`: the boot's state at `loadDone` for the empty prompt (`P.a2818 []`, its body), the template of
the `loadDone` cut's JavaScript side (the prompt array at 2665 framed, `Ld.frames`); `Ld.S0` its server.
`tpl_keys Ld`: its unframed present addresses in checked group parts (`Ld.gks`, `Ld.cover`). -/

namespace Host.Load.Run.Prompt
open Lean Elab Command Meta Host.Ts Host.Load in
elab "boot_ld_state" : command => liftTermElabM do
  let v := (← getConstInfo ``P.a2818).value!
  let b := v.beta #[mkApp (mkConst ``List.nil [.zero]) (mkConst ``Val)]
  addDecl (.defnDecl (mkDefinitionValEx `Host.Load.Run.Prompt.Ld.s0 [] (mkApp (mkConst ``St) (mkConst ``LSt)) b
    (.regular 0) .safe [`Host.Load.Run.Prompt.Ld.s0]))

boot_ld_state

/-- The `loadDone` cut's server. -/
noncomputable def Ld.S0 : Host.Ts.SSrv := P.S2818

/-- The framed array: the prompt. -/
def Ld.frames : List Nat := [2665]

tpl_keys Ld

end Host.Load.Run.Prompt
