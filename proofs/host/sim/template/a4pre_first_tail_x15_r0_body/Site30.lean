import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.st30.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 30 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g30__g31` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s304`, the merged state `PRE_first_tail_x15_r0_body.s305`,
the site template `PRE_first_tail_x15_r0_body.st30` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s306`: the merge.
The footprint's facts are in `SiteF30`, the compaction's in `SiteC30`, `SiteK30`, `SiteNa30`, `SiteNb30`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso30 : PRE_first_tail_x15_r0_body.st30.s0 = { PRE_first_tail_x15_r0_body.s304 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs30 : List Frame := PRE_first_tail_x15_r0_body.s304.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_30 : PRE_first_tail_x15_r0_body.S304.tab.length = 1367
kernel_rfl PRE_first_tail_x15_r0_body.tab0_30 : PRE_first_tail_x15_r0_body.st30.S0.tab = PRE_first_tail_x15_r0_body.S304.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws30 : List Nat := [1500, 1501, 1502, 1503, 1504, 1505, 1506, 1507, 1508, 1509, 1510, 1511, 1512, 1513, 1514, 1515, 1516, 1517, 1518, 1519, 1520, 1521, 1522, 1523, 1524, 1525, 1526, 1527, 1528, 1529, 1530]
kernel_rfl PRE_first_tail_x15_r0_body.fresh30 : (PRE_first_tail_x15_r0_body.S304.tab.all fun e => PRE_first_tail_x15_r0_body.ws30.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S304.oracle.all fun q => PRE_first_tail_x15_r0_body.ws30.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab30 : PRE_first_tail_x15_r0_body.S305.tab = PRE_first_tail_x15_r0_body.S304.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws30
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen30 : PRE_first_tail_x15_r0_body.st30.S5.tab.length - PRE_first_tail_x15_r0_body.st30.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged30`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap30 : PRE_first_tail_x15_r0_body.s305.heap = PRE_first_tail_x15_r0_body.st30.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext30 : PRE_first_tail_x15_r0_body.s305.next = PRE_first_tail_x15_r0_body.st30.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl30 : PRE_first_tail_x15_r0_body.s305.ctl = PRE_first_tail_x15_r0_body.st30.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack30 : PRE_first_tail_x15_r0_body.s305.stack = PRE_first_tail_x15_r0_body.st30.s5.stack ++ PRE_first_tail_x15_r0_body.s304.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs30 : PRE_first_tail_x15_r0_body.s305.jobs = PRE_first_tail_x15_r0_body.st30.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi30 : PRE_first_tail_x15_r0_body.s305.ffi = PRE_first_tail_x15_r0_body.st30.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace30 : PRE_first_tail_x15_r0_body.s305.trace = PRE_first_tail_x15_r0_body.st30.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores30 : PRE_first_tail_x15_r0_body.s305.stores = PRE_first_tail_x15_r0_body.st30.s5.stores

end Host.Load.Run.Tpl
