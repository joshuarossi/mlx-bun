import host.sim.template.base.S
import host.sim.template.Split
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Case `FINALC0` of the loop template: the final iteration from
`finalStart Tpl.Base.s0 112` to halt, natively chosen boundaries every 10 000 steps
and at the epilogue spread (`FINALC0.ia`, `host.sim.template.Split`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_case_split FINALC0 from Base : "FINALC0"

end Host.Load.Run.Tpl
