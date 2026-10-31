import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.st140.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 140 of chain `PRE_first_tail_x15_r0_body`: `plan__g140__g141` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1234`, the merged state `PRE_first_tail_x15_r0_body.s1235`,
the site template `PRE_first_tail_x15_r0_body.st140` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1236`: the merge.
The footprint's facts are in `SiteF140`, the compaction's in `SiteC140`, `SiteK140`, `SiteNa140`, `SiteNb140`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso140 : PRE_first_tail_x15_r0_body.st140.s0 = { PRE_first_tail_x15_r0_body.s1234 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs140 : List Frame := PRE_first_tail_x15_r0_body.s1234.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_140 : PRE_first_tail_x15_r0_body.S1234.tab.length = 6040
kernel_rfl PRE_first_tail_x15_r0_body.tab0_140 : PRE_first_tail_x15_r0_body.st140.S0.tab = PRE_first_tail_x15_r0_body.S1234.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws140 : List Nat := [3354, 3355, 3356, 3357, 3358, 3359, 3360, 3361, 3362]
kernel_rfl PRE_first_tail_x15_r0_body.fresh140 : (PRE_first_tail_x15_r0_body.S1234.tab.all fun e => PRE_first_tail_x15_r0_body.ws140.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1234.oracle.all fun q => PRE_first_tail_x15_r0_body.ws140.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab140 : PRE_first_tail_x15_r0_body.S1235.tab = PRE_first_tail_x15_r0_body.S1234.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws140
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen140 : PRE_first_tail_x15_r0_body.st140.S2.tab.length - PRE_first_tail_x15_r0_body.st140.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged140`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap140 : PRE_first_tail_x15_r0_body.s1235.heap = PRE_first_tail_x15_r0_body.st140.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext140 : PRE_first_tail_x15_r0_body.s1235.next = PRE_first_tail_x15_r0_body.st140.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl140 : PRE_first_tail_x15_r0_body.s1235.ctl = PRE_first_tail_x15_r0_body.st140.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack140 : PRE_first_tail_x15_r0_body.s1235.stack = PRE_first_tail_x15_r0_body.st140.s2.stack ++ PRE_first_tail_x15_r0_body.s1234.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs140 : PRE_first_tail_x15_r0_body.s1235.jobs = PRE_first_tail_x15_r0_body.st140.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi140 : PRE_first_tail_x15_r0_body.s1235.ffi = PRE_first_tail_x15_r0_body.st140.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace140 : PRE_first_tail_x15_r0_body.s1235.trace = PRE_first_tail_x15_r0_body.st140.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores140 : PRE_first_tail_x15_r0_body.s1235.stores = PRE_first_tail_x15_r0_body.st140.s2.stores

end Host.Load.Run.Tpl
