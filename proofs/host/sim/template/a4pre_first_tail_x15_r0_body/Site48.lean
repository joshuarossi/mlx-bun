import host.sim.template.a4pre_first_tail_x15_r0_body.H14
import host.sim.template.a4pre_first_tail_x15_r0_body.st48.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 48 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g48__g49` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s476`, the merged state `PRE_first_tail_x15_r0_body.s477`,
the site template `PRE_first_tail_x15_r0_body.st48` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s478`: the merge.
The footprint's facts are in `SiteF48`, the compaction's in `SiteC48`, `SiteK48`, `SiteNa48`, `SiteNb48`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso48 : PRE_first_tail_x15_r0_body.st48.s0 = { PRE_first_tail_x15_r0_body.s476 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs48 : List Frame := PRE_first_tail_x15_r0_body.s476.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_48 : PRE_first_tail_x15_r0_body.S476.tab.length = 2135
kernel_rfl PRE_first_tail_x15_r0_body.tab0_48 : PRE_first_tail_x15_r0_body.st48.S0.tab = PRE_first_tail_x15_r0_body.S476.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws48 : List Nat := [1796, 1797, 1798, 1799, 1800, 1801, 1802, 1803, 1804, 1805, 1806, 1807, 1808, 1809, 1810, 1811, 1812, 1813, 1814, 1815, 1816, 1817, 1818, 1819, 1820, 1821, 1822, 1823, 1824, 1825, 1826]
kernel_rfl PRE_first_tail_x15_r0_body.fresh48 : (PRE_first_tail_x15_r0_body.S476.tab.all fun e => PRE_first_tail_x15_r0_body.ws48.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S476.oracle.all fun q => PRE_first_tail_x15_r0_body.ws48.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab48 : PRE_first_tail_x15_r0_body.S477.tab = PRE_first_tail_x15_r0_body.S476.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws48
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen48 : PRE_first_tail_x15_r0_body.st48.S5.tab.length - PRE_first_tail_x15_r0_body.st48.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged48`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap48 : PRE_first_tail_x15_r0_body.s477.heap = PRE_first_tail_x15_r0_body.st48.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext48 : PRE_first_tail_x15_r0_body.s477.next = PRE_first_tail_x15_r0_body.st48.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl48 : PRE_first_tail_x15_r0_body.s477.ctl = PRE_first_tail_x15_r0_body.st48.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack48 : PRE_first_tail_x15_r0_body.s477.stack = PRE_first_tail_x15_r0_body.st48.s5.stack ++ PRE_first_tail_x15_r0_body.s476.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs48 : PRE_first_tail_x15_r0_body.s477.jobs = PRE_first_tail_x15_r0_body.st48.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi48 : PRE_first_tail_x15_r0_body.s477.ffi = PRE_first_tail_x15_r0_body.st48.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace48 : PRE_first_tail_x15_r0_body.s477.trace = PRE_first_tail_x15_r0_body.st48.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores48 : PRE_first_tail_x15_r0_body.s477.stores = PRE_first_tail_x15_r0_body.st48.s5.stores

end Host.Load.Run.Tpl
