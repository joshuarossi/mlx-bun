import host.sim.template.base.S
import host.sim.template.Split
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Case `FINALE` of the loop template: EOS read in the final iteration (no cache clear),
from `finalStart Tpl.Base.s0 112` to halt, natively chosen boundaries every 10 000 steps
and at the epilogue spread (`FINALE.ia`, `host.sim.template.Split`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_case_split FINALE from Base : "FINALE"

end Host.Load.Run.Tpl
