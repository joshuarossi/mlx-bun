import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.st35.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 35 of chain `PRE_first_tail_x15_r0_body`: `plan__g35__g36` (`plan`), the call state `PRE_first_tail_x15_r0_body.s313`, the merged state `PRE_first_tail_x15_r0_body.s314`,
the site template `PRE_first_tail_x15_r0_body.st35` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s315`: the merge.
The footprint's facts are in `SiteF35`, the compaction's in `SiteC35`, `SiteK35`, `SiteNa35`, `SiteNb35`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso35 : PRE_first_tail_x15_r0_body.st35.s0 = { PRE_first_tail_x15_r0_body.s313 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs35 : List Frame := PRE_first_tail_x15_r0_body.s313.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_35 : PRE_first_tail_x15_r0_body.S313.tab.length = 1549
kernel_rfl PRE_first_tail_x15_r0_body.tab0_35 : PRE_first_tail_x15_r0_body.st35.S0.tab = PRE_first_tail_x15_r0_body.S313.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws35 : List Nat := [1582, 1583, 1584, 1585, 1586, 1587, 1588, 1589, 1590]
kernel_rfl PRE_first_tail_x15_r0_body.fresh35 : (PRE_first_tail_x15_r0_body.S313.tab.all fun e => PRE_first_tail_x15_r0_body.ws35.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S313.oracle.all fun q => PRE_first_tail_x15_r0_body.ws35.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab35 : PRE_first_tail_x15_r0_body.S314.tab = PRE_first_tail_x15_r0_body.S313.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws35
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen35 : PRE_first_tail_x15_r0_body.st35.S2.tab.length - PRE_first_tail_x15_r0_body.st35.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged35`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap35 : PRE_first_tail_x15_r0_body.s314.heap = PRE_first_tail_x15_r0_body.st35.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext35 : PRE_first_tail_x15_r0_body.s314.next = PRE_first_tail_x15_r0_body.st35.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl35 : PRE_first_tail_x15_r0_body.s314.ctl = PRE_first_tail_x15_r0_body.st35.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack35 : PRE_first_tail_x15_r0_body.s314.stack = PRE_first_tail_x15_r0_body.st35.s2.stack ++ PRE_first_tail_x15_r0_body.s313.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs35 : PRE_first_tail_x15_r0_body.s314.jobs = PRE_first_tail_x15_r0_body.st35.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi35 : PRE_first_tail_x15_r0_body.s314.ffi = PRE_first_tail_x15_r0_body.st35.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace35 : PRE_first_tail_x15_r0_body.s314.trace = PRE_first_tail_x15_r0_body.st35.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores35 : PRE_first_tail_x15_r0_body.s314.stores = PRE_first_tail_x15_r0_body.st35.s2.stores

end Host.Load.Run.Tpl
