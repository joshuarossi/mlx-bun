import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.st29.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 29 of chain `PRE_first_tail_x15_r0_body`: `plan__g29__g30` (`plan`), the call state `PRE_first_tail_x15_r0_body.s287`, the merged state `PRE_first_tail_x15_r0_body.s288`,
the site template `PRE_first_tail_x15_r0_body.st29` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s289`: the merge.
The footprint's facts are in `SiteF29`, the compaction's in `SiteC29`, `SiteK29`, `SiteNa29`, `SiteNb29`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso29 : PRE_first_tail_x15_r0_body.st29.s0 = { PRE_first_tail_x15_r0_body.s287 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs29 : List Frame := PRE_first_tail_x15_r0_body.s287.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_29 : PRE_first_tail_x15_r0_body.S287.tab.length = 1294
kernel_rfl PRE_first_tail_x15_r0_body.tab0_29 : PRE_first_tail_x15_r0_body.st29.S0.tab = PRE_first_tail_x15_r0_body.S287.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws29 : List Nat := [1497, 1498, 1499]
kernel_rfl PRE_first_tail_x15_r0_body.fresh29 : (PRE_first_tail_x15_r0_body.S287.tab.all fun e => PRE_first_tail_x15_r0_body.ws29.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S287.oracle.all fun q => PRE_first_tail_x15_r0_body.ws29.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab29 : PRE_first_tail_x15_r0_body.S288.tab = PRE_first_tail_x15_r0_body.S287.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws29
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen29 : PRE_first_tail_x15_r0_body.st29.S2.tab.length - PRE_first_tail_x15_r0_body.st29.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged29`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap29 : PRE_first_tail_x15_r0_body.s288.heap = PRE_first_tail_x15_r0_body.st29.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext29 : PRE_first_tail_x15_r0_body.s288.next = PRE_first_tail_x15_r0_body.st29.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl29 : PRE_first_tail_x15_r0_body.s288.ctl = PRE_first_tail_x15_r0_body.st29.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack29 : PRE_first_tail_x15_r0_body.s288.stack = PRE_first_tail_x15_r0_body.st29.s2.stack ++ PRE_first_tail_x15_r0_body.s287.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs29 : PRE_first_tail_x15_r0_body.s288.jobs = PRE_first_tail_x15_r0_body.st29.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi29 : PRE_first_tail_x15_r0_body.s288.ffi = PRE_first_tail_x15_r0_body.st29.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace29 : PRE_first_tail_x15_r0_body.s288.trace = PRE_first_tail_x15_r0_body.st29.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores29 : PRE_first_tail_x15_r0_body.s288.stores = PRE_first_tail_x15_r0_body.st29.s2.stores

end Host.Load.Run.Tpl
