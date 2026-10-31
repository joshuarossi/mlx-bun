import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.a4pre_first_tail_x15_r0_body.st91.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 91 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g91__g92` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s810`, the merged state `PRE_first_tail_x15_r0_body.s811`,
the site template `PRE_first_tail_x15_r0_body.st91` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s812`: the merge.
The footprint's facts are in `SiteF91`, the compaction's in `SiteC91`, `SiteK91`, `SiteNa91`, `SiteNb91`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso91 : PRE_first_tail_x15_r0_body.st91.s0 = { PRE_first_tail_x15_r0_body.s810 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs91 : List Frame := PRE_first_tail_x15_r0_body.s810.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_91 : PRE_first_tail_x15_r0_body.S810.tab.length = 3971
kernel_rfl PRE_first_tail_x15_r0_body.tab0_91 : PRE_first_tail_x15_r0_body.st91.S0.tab = PRE_first_tail_x15_r0_body.S810.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws91 : List Nat := [2556, 2557]
kernel_rfl PRE_first_tail_x15_r0_body.fresh91 : (PRE_first_tail_x15_r0_body.S810.tab.all fun e => PRE_first_tail_x15_r0_body.ws91.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S810.oracle.all fun q => PRE_first_tail_x15_r0_body.ws91.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab91 : PRE_first_tail_x15_r0_body.S811.tab = PRE_first_tail_x15_r0_body.S810.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws91
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen91 : PRE_first_tail_x15_r0_body.st91.S2.tab.length - PRE_first_tail_x15_r0_body.st91.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged91`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap91 : PRE_first_tail_x15_r0_body.s811.heap = PRE_first_tail_x15_r0_body.st91.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext91 : PRE_first_tail_x15_r0_body.s811.next = PRE_first_tail_x15_r0_body.st91.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl91 : PRE_first_tail_x15_r0_body.s811.ctl = PRE_first_tail_x15_r0_body.st91.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack91 : PRE_first_tail_x15_r0_body.s811.stack = PRE_first_tail_x15_r0_body.st91.s2.stack ++ PRE_first_tail_x15_r0_body.s810.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs91 : PRE_first_tail_x15_r0_body.s811.jobs = PRE_first_tail_x15_r0_body.st91.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi91 : PRE_first_tail_x15_r0_body.s811.ffi = PRE_first_tail_x15_r0_body.st91.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace91 : PRE_first_tail_x15_r0_body.s811.trace = PRE_first_tail_x15_r0_body.st91.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores91 : PRE_first_tail_x15_r0_body.s811.stores = PRE_first_tail_x15_r0_body.st91.s2.stores

end Host.Load.Run.Tpl
