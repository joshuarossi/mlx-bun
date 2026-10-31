import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.st55.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 55 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g55__g56` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s542`, the merged state `PRE_first_tail_x15_r0_body.s543`,
the site template `PRE_first_tail_x15_r0_body.st55` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s544`: the merge.
The footprint's facts are in `SiteF55`, the compaction's in `SiteC55`, `SiteK55`, `SiteNa55`, `SiteNb55`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso55 : PRE_first_tail_x15_r0_body.st55.s0 = { PRE_first_tail_x15_r0_body.s542 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs55 : List Frame := PRE_first_tail_x15_r0_body.s542.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_55 : PRE_first_tail_x15_r0_body.S542.tab.length = 2432
kernel_rfl PRE_first_tail_x15_r0_body.tab0_55 : PRE_first_tail_x15_r0_body.st55.S0.tab = PRE_first_tail_x15_r0_body.S542.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws55 : List Nat := [1965, 1966]
kernel_rfl PRE_first_tail_x15_r0_body.fresh55 : (PRE_first_tail_x15_r0_body.S542.tab.all fun e => PRE_first_tail_x15_r0_body.ws55.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S542.oracle.all fun q => PRE_first_tail_x15_r0_body.ws55.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab55 : PRE_first_tail_x15_r0_body.S543.tab = PRE_first_tail_x15_r0_body.S542.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws55
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen55 : PRE_first_tail_x15_r0_body.st55.S2.tab.length - PRE_first_tail_x15_r0_body.st55.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged55`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap55 : PRE_first_tail_x15_r0_body.s543.heap = PRE_first_tail_x15_r0_body.st55.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext55 : PRE_first_tail_x15_r0_body.s543.next = PRE_first_tail_x15_r0_body.st55.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl55 : PRE_first_tail_x15_r0_body.s543.ctl = PRE_first_tail_x15_r0_body.st55.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack55 : PRE_first_tail_x15_r0_body.s543.stack = PRE_first_tail_x15_r0_body.st55.s2.stack ++ PRE_first_tail_x15_r0_body.s542.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs55 : PRE_first_tail_x15_r0_body.s543.jobs = PRE_first_tail_x15_r0_body.st55.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi55 : PRE_first_tail_x15_r0_body.s543.ffi = PRE_first_tail_x15_r0_body.st55.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace55 : PRE_first_tail_x15_r0_body.s543.trace = PRE_first_tail_x15_r0_body.st55.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores55 : PRE_first_tail_x15_r0_body.s543.stores = PRE_first_tail_x15_r0_body.st55.s2.stores

end Host.Load.Run.Tpl
