import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.a4pre_first_tail_x15_r0_body.st24.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 24 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g24__g25` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s246`, the merged state `PRE_first_tail_x15_r0_body.s247`,
the site template `PRE_first_tail_x15_r0_body.st24` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s248`: the merge.
The footprint's facts are in `SiteF24`, the compaction's in `SiteC24`, `SiteK24`, `SiteNa24`, `SiteNb24`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso24 : PRE_first_tail_x15_r0_body.st24.s0 = { PRE_first_tail_x15_r0_body.s246 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs24 : List Frame := PRE_first_tail_x15_r0_body.s246.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_24 : PRE_first_tail_x15_r0_body.S246.tab.length = 1109
kernel_rfl PRE_first_tail_x15_r0_body.tab0_24 : PRE_first_tail_x15_r0_body.st24.S0.tab = PRE_first_tail_x15_r0_body.S246.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws24 : List Nat := [1392, 1393, 1394, 1395, 1396, 1397, 1398, 1399, 1400, 1401, 1402, 1403, 1404, 1405, 1406, 1407, 1408, 1409, 1410, 1411, 1412, 1413, 1414, 1415, 1416, 1417, 1418, 1419, 1420, 1421, 1422]
kernel_rfl PRE_first_tail_x15_r0_body.fresh24 : (PRE_first_tail_x15_r0_body.S246.tab.all fun e => PRE_first_tail_x15_r0_body.ws24.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S246.oracle.all fun q => PRE_first_tail_x15_r0_body.ws24.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab24 : PRE_first_tail_x15_r0_body.S247.tab = PRE_first_tail_x15_r0_body.S246.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws24
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen24 : PRE_first_tail_x15_r0_body.st24.S5.tab.length - PRE_first_tail_x15_r0_body.st24.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged24`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap24 : PRE_first_tail_x15_r0_body.s247.heap = PRE_first_tail_x15_r0_body.st24.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext24 : PRE_first_tail_x15_r0_body.s247.next = PRE_first_tail_x15_r0_body.st24.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl24 : PRE_first_tail_x15_r0_body.s247.ctl = PRE_first_tail_x15_r0_body.st24.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack24 : PRE_first_tail_x15_r0_body.s247.stack = PRE_first_tail_x15_r0_body.st24.s5.stack ++ PRE_first_tail_x15_r0_body.s246.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs24 : PRE_first_tail_x15_r0_body.s247.jobs = PRE_first_tail_x15_r0_body.st24.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi24 : PRE_first_tail_x15_r0_body.s247.ffi = PRE_first_tail_x15_r0_body.st24.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace24 : PRE_first_tail_x15_r0_body.s247.trace = PRE_first_tail_x15_r0_body.st24.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores24 : PRE_first_tail_x15_r0_body.s247.stores = PRE_first_tail_x15_r0_body.st24.s5.stores

end Host.Load.Run.Tpl
