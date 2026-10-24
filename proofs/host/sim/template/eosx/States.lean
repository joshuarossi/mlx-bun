import host.sim.template.base.S
import host.sim.template.Split
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Case `EOSX` of the loop template: EOS read at a loop cut, from `Tpl.Base.s0` to halt,
natively chosen boundaries every 10 000 steps and at the epilogue spread (`EOSX.ia`,
`host.sim.template.Split`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_case_split EOSX from Base : "EOSX"

end Host.Load.Run.Tpl
