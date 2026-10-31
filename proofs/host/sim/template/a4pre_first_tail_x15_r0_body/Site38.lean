import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.a4pre_first_tail_x15_r0_body.st38.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 38 of chain `PRE_first_tail_x15_r0_body`: `plan__g38__g39` (`plan`), the call state `PRE_first_tail_x15_r0_body.s340`, the merged state `PRE_first_tail_x15_r0_body.s341`,
the site template `PRE_first_tail_x15_r0_body.st38` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s342`: the merge.
The footprint's facts are in `SiteF38`, the compaction's in `SiteC38`, `SiteK38`, `SiteNa38`, `SiteNb38`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso38 : PRE_first_tail_x15_r0_body.st38.s0 = { PRE_first_tail_x15_r0_body.s340 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs38 : List Frame := PRE_first_tail_x15_r0_body.s340.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_38 : PRE_first_tail_x15_r0_body.S340.tab.length = 1678
kernel_rfl PRE_first_tail_x15_r0_body.tab0_38 : PRE_first_tail_x15_r0_body.st38.S0.tab = PRE_first_tail_x15_r0_body.S340.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws38 : List Nat := [1642, 1643, 1644]
kernel_rfl PRE_first_tail_x15_r0_body.fresh38 : (PRE_first_tail_x15_r0_body.S340.tab.all fun e => PRE_first_tail_x15_r0_body.ws38.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S340.oracle.all fun q => PRE_first_tail_x15_r0_body.ws38.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab38 : PRE_first_tail_x15_r0_body.S341.tab = PRE_first_tail_x15_r0_body.S340.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws38
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen38 : PRE_first_tail_x15_r0_body.st38.S2.tab.length - PRE_first_tail_x15_r0_body.st38.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged38`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap38 : PRE_first_tail_x15_r0_body.s341.heap = PRE_first_tail_x15_r0_body.st38.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext38 : PRE_first_tail_x15_r0_body.s341.next = PRE_first_tail_x15_r0_body.st38.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl38 : PRE_first_tail_x15_r0_body.s341.ctl = PRE_first_tail_x15_r0_body.st38.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack38 : PRE_first_tail_x15_r0_body.s341.stack = PRE_first_tail_x15_r0_body.st38.s2.stack ++ PRE_first_tail_x15_r0_body.s340.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs38 : PRE_first_tail_x15_r0_body.s341.jobs = PRE_first_tail_x15_r0_body.st38.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi38 : PRE_first_tail_x15_r0_body.s341.ffi = PRE_first_tail_x15_r0_body.st38.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace38 : PRE_first_tail_x15_r0_body.s341.trace = PRE_first_tail_x15_r0_body.st38.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores38 : PRE_first_tail_x15_r0_body.s341.stores = PRE_first_tail_x15_r0_body.st38.s2.stores

end Host.Load.Run.Tpl
