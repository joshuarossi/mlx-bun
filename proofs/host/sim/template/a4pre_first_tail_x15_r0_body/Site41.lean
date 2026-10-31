import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.a4pre_first_tail_x15_r0_body.st41.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 41 of chain `PRE_first_tail_x15_r0_body`: `plan__g41__g42` (`plan`), the call state `PRE_first_tail_x15_r0_body.s367`, the merged state `PRE_first_tail_x15_r0_body.s368`,
the site template `PRE_first_tail_x15_r0_body.st41` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s369`: the merge.
The footprint's facts are in `SiteF41`, the compaction's in `SiteC41`, `SiteK41`, `SiteNa41`, `SiteNb41`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso41 : PRE_first_tail_x15_r0_body.st41.s0 = { PRE_first_tail_x15_r0_body.s367 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs41 : List Frame := PRE_first_tail_x15_r0_body.s367.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_41 : PRE_first_tail_x15_r0_body.S367.tab.length = 1807
kernel_rfl PRE_first_tail_x15_r0_body.tab0_41 : PRE_first_tail_x15_r0_body.st41.S0.tab = PRE_first_tail_x15_r0_body.S367.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws41 : List Nat := [1696, 1697, 1698, 1699, 1700, 1701, 1702, 1703, 1704]
kernel_rfl PRE_first_tail_x15_r0_body.fresh41 : (PRE_first_tail_x15_r0_body.S367.tab.all fun e => PRE_first_tail_x15_r0_body.ws41.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S367.oracle.all fun q => PRE_first_tail_x15_r0_body.ws41.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab41 : PRE_first_tail_x15_r0_body.S368.tab = PRE_first_tail_x15_r0_body.S367.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws41
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen41 : PRE_first_tail_x15_r0_body.st41.S2.tab.length - PRE_first_tail_x15_r0_body.st41.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged41`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap41 : PRE_first_tail_x15_r0_body.s368.heap = PRE_first_tail_x15_r0_body.st41.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext41 : PRE_first_tail_x15_r0_body.s368.next = PRE_first_tail_x15_r0_body.st41.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl41 : PRE_first_tail_x15_r0_body.s368.ctl = PRE_first_tail_x15_r0_body.st41.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack41 : PRE_first_tail_x15_r0_body.s368.stack = PRE_first_tail_x15_r0_body.st41.s2.stack ++ PRE_first_tail_x15_r0_body.s367.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs41 : PRE_first_tail_x15_r0_body.s368.jobs = PRE_first_tail_x15_r0_body.st41.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi41 : PRE_first_tail_x15_r0_body.s368.ffi = PRE_first_tail_x15_r0_body.st41.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace41 : PRE_first_tail_x15_r0_body.s368.trace = PRE_first_tail_x15_r0_body.st41.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores41 : PRE_first_tail_x15_r0_body.s368.stores = PRE_first_tail_x15_r0_body.st41.s2.stores

end Host.Load.Run.Tpl
