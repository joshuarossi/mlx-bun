import host.sim.template.a4pre_first_tail_x15_r0_body.H8
import host.sim.template.a4pre_first_tail_x15_r0_body.st27.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 27 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g27__g28` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s275`, the merged state `PRE_first_tail_x15_r0_body.s276`,
the site template `PRE_first_tail_x15_r0_body.st27` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s277`: the merge.
The footprint's facts are in `SiteF27`, the compaction's in `SiteC27`, `SiteK27`, `SiteNa27`, `SiteNb27`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso27 : PRE_first_tail_x15_r0_body.st27.s0 = { PRE_first_tail_x15_r0_body.s275 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs27 : List Frame := PRE_first_tail_x15_r0_body.s275.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_27 : PRE_first_tail_x15_r0_body.S275.tab.length = 1238
kernel_rfl PRE_first_tail_x15_r0_body.tab0_27 : PRE_first_tail_x15_r0_body.st27.S0.tab = PRE_first_tail_x15_r0_body.S275.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws27 : List Nat := [1446, 1447, 1448, 1449, 1450, 1451, 1452, 1453, 1454, 1455, 1456, 1457, 1458, 1459, 1460, 1461, 1462, 1463, 1464, 1465, 1466, 1467, 1468, 1469, 1470, 1471, 1472, 1473, 1474, 1475, 1476]
kernel_rfl PRE_first_tail_x15_r0_body.fresh27 : (PRE_first_tail_x15_r0_body.S275.tab.all fun e => PRE_first_tail_x15_r0_body.ws27.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S275.oracle.all fun q => PRE_first_tail_x15_r0_body.ws27.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab27 : PRE_first_tail_x15_r0_body.S276.tab = PRE_first_tail_x15_r0_body.S275.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws27
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen27 : PRE_first_tail_x15_r0_body.st27.S5.tab.length - PRE_first_tail_x15_r0_body.st27.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged27`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap27 : PRE_first_tail_x15_r0_body.s276.heap = PRE_first_tail_x15_r0_body.st27.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext27 : PRE_first_tail_x15_r0_body.s276.next = PRE_first_tail_x15_r0_body.st27.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl27 : PRE_first_tail_x15_r0_body.s276.ctl = PRE_first_tail_x15_r0_body.st27.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack27 : PRE_first_tail_x15_r0_body.s276.stack = PRE_first_tail_x15_r0_body.st27.s5.stack ++ PRE_first_tail_x15_r0_body.s275.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs27 : PRE_first_tail_x15_r0_body.s276.jobs = PRE_first_tail_x15_r0_body.st27.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi27 : PRE_first_tail_x15_r0_body.s276.ffi = PRE_first_tail_x15_r0_body.st27.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace27 : PRE_first_tail_x15_r0_body.s276.trace = PRE_first_tail_x15_r0_body.st27.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores27 : PRE_first_tail_x15_r0_body.s276.stores = PRE_first_tail_x15_r0_body.st27.s5.stores

end Host.Load.Run.Tpl
