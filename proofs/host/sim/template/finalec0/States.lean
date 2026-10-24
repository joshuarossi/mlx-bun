import host.sim.template.base.S
import host.sim.template.Split
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Case `FINALEC0` of the loop template: EOS read in the final iteration after the cache
clear of the yielded token (`(T - 2) % 256 = 0`), from `finalStart Tpl.Base.s0 112` to halt,
natively chosen boundaries every 10 000 steps and at the epilogue spread (`FINALEC0.ia`,
`host.sim.template.Split`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_case_split FINALEC0 from Base : "FINALEC0"

end Host.Load.Run.Tpl
