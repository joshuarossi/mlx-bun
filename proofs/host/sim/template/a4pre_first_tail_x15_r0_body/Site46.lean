import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.a4pre_first_tail_x15_r0_body.st46.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 46 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g46__g47` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s414`, the merged state `PRE_first_tail_x15_r0_body.s415`,
the site template `PRE_first_tail_x15_r0_body.st46` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s416`: the merge.
The footprint's facts are in `SiteF46`, the compaction's in `SiteC46`, `SiteK46`, `SiteNa46`, `SiteNb46`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso46 : PRE_first_tail_x15_r0_body.st46.s0 = { PRE_first_tail_x15_r0_body.s414 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs46 : List Frame := PRE_first_tail_x15_r0_body.s414.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_46 : PRE_first_tail_x15_r0_body.S414.tab.length = 2045
kernel_rfl PRE_first_tail_x15_r0_body.tab0_46 : PRE_first_tail_x15_r0_body.st46.S0.tab = PRE_first_tail_x15_r0_body.S414.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws46 : List Nat := [1785, 1786]
kernel_rfl PRE_first_tail_x15_r0_body.fresh46 : (PRE_first_tail_x15_r0_body.S414.tab.all fun e => PRE_first_tail_x15_r0_body.ws46.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S414.oracle.all fun q => PRE_first_tail_x15_r0_body.ws46.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab46 : PRE_first_tail_x15_r0_body.S415.tab = PRE_first_tail_x15_r0_body.S414.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws46
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen46 : PRE_first_tail_x15_r0_body.st46.S2.tab.length - PRE_first_tail_x15_r0_body.st46.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged46`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap46 : PRE_first_tail_x15_r0_body.s415.heap = PRE_first_tail_x15_r0_body.st46.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext46 : PRE_first_tail_x15_r0_body.s415.next = PRE_first_tail_x15_r0_body.st46.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl46 : PRE_first_tail_x15_r0_body.s415.ctl = PRE_first_tail_x15_r0_body.st46.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack46 : PRE_first_tail_x15_r0_body.s415.stack = PRE_first_tail_x15_r0_body.st46.s2.stack ++ PRE_first_tail_x15_r0_body.s414.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs46 : PRE_first_tail_x15_r0_body.s415.jobs = PRE_first_tail_x15_r0_body.st46.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi46 : PRE_first_tail_x15_r0_body.s415.ffi = PRE_first_tail_x15_r0_body.st46.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace46 : PRE_first_tail_x15_r0_body.s415.trace = PRE_first_tail_x15_r0_body.st46.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores46 : PRE_first_tail_x15_r0_body.s415.stores = PRE_first_tail_x15_r0_body.st46.s2.stores

end Host.Load.Run.Tpl
