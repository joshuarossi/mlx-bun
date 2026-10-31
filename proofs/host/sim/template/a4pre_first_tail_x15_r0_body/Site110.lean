import host.sim.template.a4pre_first_tail_x15_r0_body.H30
import host.sim.template.a4pre_first_tail_x15_r0_body.st110.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 110 of chain `PRE_first_tail_x15_r0_body`: `plan__g110__g111` (`plan`), the call state `PRE_first_tail_x15_r0_body.s970`, the merged state `PRE_first_tail_x15_r0_body.s971`,
the site template `PRE_first_tail_x15_r0_body.st110` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s972`: the merge.
The footprint's facts are in `SiteF110`, the compaction's in `SiteC110`, `SiteK110`, `SiteNa110`, `SiteNb110`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso110 : PRE_first_tail_x15_r0_body.st110.s0 = { PRE_first_tail_x15_r0_body.s970 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs110 : List Frame := PRE_first_tail_x15_r0_body.s970.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_110 : PRE_first_tail_x15_r0_body.S970.tab.length = 4756
kernel_rfl PRE_first_tail_x15_r0_body.tab0_110 : PRE_first_tail_x15_r0_body.st110.S0.tab = PRE_first_tail_x15_r0_body.S970.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws110 : List Nat := [2854, 2855, 2856]
kernel_rfl PRE_first_tail_x15_r0_body.fresh110 : (PRE_first_tail_x15_r0_body.S970.tab.all fun e => PRE_first_tail_x15_r0_body.ws110.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S970.oracle.all fun q => PRE_first_tail_x15_r0_body.ws110.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab110 : PRE_first_tail_x15_r0_body.S971.tab = PRE_first_tail_x15_r0_body.S970.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws110
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen110 : PRE_first_tail_x15_r0_body.st110.S2.tab.length - PRE_first_tail_x15_r0_body.st110.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged110`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap110 : PRE_first_tail_x15_r0_body.s971.heap = PRE_first_tail_x15_r0_body.st110.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext110 : PRE_first_tail_x15_r0_body.s971.next = PRE_first_tail_x15_r0_body.st110.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl110 : PRE_first_tail_x15_r0_body.s971.ctl = PRE_first_tail_x15_r0_body.st110.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack110 : PRE_first_tail_x15_r0_body.s971.stack = PRE_first_tail_x15_r0_body.st110.s2.stack ++ PRE_first_tail_x15_r0_body.s970.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs110 : PRE_first_tail_x15_r0_body.s971.jobs = PRE_first_tail_x15_r0_body.st110.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi110 : PRE_first_tail_x15_r0_body.s971.ffi = PRE_first_tail_x15_r0_body.st110.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace110 : PRE_first_tail_x15_r0_body.s971.trace = PRE_first_tail_x15_r0_body.st110.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores110 : PRE_first_tail_x15_r0_body.s971.stores = PRE_first_tail_x15_r0_body.st110.s2.stores

end Host.Load.Run.Tpl
