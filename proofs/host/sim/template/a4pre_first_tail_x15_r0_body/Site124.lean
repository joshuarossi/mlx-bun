import host.sim.template.a4pre_first_tail_x15_r0_body.H37
import host.sim.template.a4pre_first_tail_x15_r0_body.st124.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 124 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g124__g125` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1203`, the merged state `PRE_first_tail_x15_r0_body.s1204`,
the site template `PRE_first_tail_x15_r0_body.st124` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1205`: the merge.
The footprint's facts are in `SiteF124`, the compaction's in `SiteC124`, `SiteK124`, `SiteNa124`, `SiteNb124`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso124 : PRE_first_tail_x15_r0_body.st124.s0 = { PRE_first_tail_x15_r0_body.s1203 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs124 : List Frame := PRE_first_tail_x15_r0_body.s1203.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_124 : PRE_first_tail_x15_r0_body.S1203.tab.length = 5381
kernel_rfl PRE_first_tail_x15_r0_body.tab0_124 : PRE_first_tail_x15_r0_body.st124.S0.tab = PRE_first_tail_x15_r0_body.S1203.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws124 : List Nat := [3099, 3100]
kernel_rfl PRE_first_tail_x15_r0_body.fresh124 : (PRE_first_tail_x15_r0_body.S1203.tab.all fun e => PRE_first_tail_x15_r0_body.ws124.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1203.oracle.all fun q => PRE_first_tail_x15_r0_body.ws124.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab124 : PRE_first_tail_x15_r0_body.S1204.tab = PRE_first_tail_x15_r0_body.S1203.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws124
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen124 : PRE_first_tail_x15_r0_body.st124.S2.tab.length - PRE_first_tail_x15_r0_body.st124.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged124`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap124 : PRE_first_tail_x15_r0_body.s1204.heap = PRE_first_tail_x15_r0_body.st124.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext124 : PRE_first_tail_x15_r0_body.s1204.next = PRE_first_tail_x15_r0_body.st124.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl124 : PRE_first_tail_x15_r0_body.s1204.ctl = PRE_first_tail_x15_r0_body.st124.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack124 : PRE_first_tail_x15_r0_body.s1204.stack = PRE_first_tail_x15_r0_body.st124.s2.stack ++ PRE_first_tail_x15_r0_body.s1203.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs124 : PRE_first_tail_x15_r0_body.s1204.jobs = PRE_first_tail_x15_r0_body.st124.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi124 : PRE_first_tail_x15_r0_body.s1204.ffi = PRE_first_tail_x15_r0_body.st124.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace124 : PRE_first_tail_x15_r0_body.s1204.trace = PRE_first_tail_x15_r0_body.st124.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores124 : PRE_first_tail_x15_r0_body.s1204.stores = PRE_first_tail_x15_r0_body.st124.s2.stores

end Host.Load.Run.Tpl
