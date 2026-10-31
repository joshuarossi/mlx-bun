import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.a4pre_first_tail_x15_r0_body.st134.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 134 of chain `PRE_first_tail_x15_r0_body`: `plan__g134__g135` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1180`, the merged state `PRE_first_tail_x15_r0_body.s1181`,
the site template `PRE_first_tail_x15_r0_body.st134` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1182`: the merge.
The footprint's facts are in `SiteF134`, the compaction's in `SiteC134`, `SiteK134`, `SiteNa134`, `SiteNb134`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso134 : PRE_first_tail_x15_r0_body.st134.s0 = { PRE_first_tail_x15_r0_body.s1180 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs134 : List Frame := PRE_first_tail_x15_r0_body.s1180.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_134 : PRE_first_tail_x15_r0_body.S1180.tab.length = 5782
kernel_rfl PRE_first_tail_x15_r0_body.tab0_134 : PRE_first_tail_x15_r0_body.st134.S0.tab = PRE_first_tail_x15_r0_body.S1180.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws134 : List Nat := [3240, 3241, 3242]
kernel_rfl PRE_first_tail_x15_r0_body.fresh134 : (PRE_first_tail_x15_r0_body.S1180.tab.all fun e => PRE_first_tail_x15_r0_body.ws134.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1180.oracle.all fun q => PRE_first_tail_x15_r0_body.ws134.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab134 : PRE_first_tail_x15_r0_body.S1181.tab = PRE_first_tail_x15_r0_body.S1180.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws134
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen134 : PRE_first_tail_x15_r0_body.st134.S2.tab.length - PRE_first_tail_x15_r0_body.st134.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged134`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap134 : PRE_first_tail_x15_r0_body.s1181.heap = PRE_first_tail_x15_r0_body.st134.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext134 : PRE_first_tail_x15_r0_body.s1181.next = PRE_first_tail_x15_r0_body.st134.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl134 : PRE_first_tail_x15_r0_body.s1181.ctl = PRE_first_tail_x15_r0_body.st134.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack134 : PRE_first_tail_x15_r0_body.s1181.stack = PRE_first_tail_x15_r0_body.st134.s2.stack ++ PRE_first_tail_x15_r0_body.s1180.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs134 : PRE_first_tail_x15_r0_body.s1181.jobs = PRE_first_tail_x15_r0_body.st134.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi134 : PRE_first_tail_x15_r0_body.s1181.ffi = PRE_first_tail_x15_r0_body.st134.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace134 : PRE_first_tail_x15_r0_body.s1181.trace = PRE_first_tail_x15_r0_body.st134.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores134 : PRE_first_tail_x15_r0_body.s1181.stores = PRE_first_tail_x15_r0_body.st134.s2.stores

end Host.Load.Run.Tpl
