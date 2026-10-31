import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.st116.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 116 of chain `PRE_first_tail_x15_r0_body`: `plan__g116__g117` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1121`, the merged state `PRE_first_tail_x15_r0_body.s1122`,
the site template `PRE_first_tail_x15_r0_body.st116` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1123`: the merge.
The footprint's facts are in `SiteF116`, the compaction's in `SiteC116`, `SiteK116`, `SiteNa116`, `SiteNb116`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso116 : PRE_first_tail_x15_r0_body.st116.s0 = { PRE_first_tail_x15_r0_body.s1121 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs116 : List Frame := PRE_first_tail_x15_r0_body.s1121.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_116 : PRE_first_tail_x15_r0_body.S1121.tab.length = 5014
kernel_rfl PRE_first_tail_x15_r0_body.tab0_116 : PRE_first_tail_x15_r0_body.st116.S0.tab = PRE_first_tail_x15_r0_body.S1121.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws116 : List Nat := [2962, 2963, 2964]
kernel_rfl PRE_first_tail_x15_r0_body.fresh116 : (PRE_first_tail_x15_r0_body.S1121.tab.all fun e => PRE_first_tail_x15_r0_body.ws116.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1121.oracle.all fun q => PRE_first_tail_x15_r0_body.ws116.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab116 : PRE_first_tail_x15_r0_body.S1122.tab = PRE_first_tail_x15_r0_body.S1121.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws116
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen116 : PRE_first_tail_x15_r0_body.st116.S2.tab.length - PRE_first_tail_x15_r0_body.st116.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged116`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap116 : PRE_first_tail_x15_r0_body.s1122.heap = PRE_first_tail_x15_r0_body.st116.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext116 : PRE_first_tail_x15_r0_body.s1122.next = PRE_first_tail_x15_r0_body.st116.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl116 : PRE_first_tail_x15_r0_body.s1122.ctl = PRE_first_tail_x15_r0_body.st116.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack116 : PRE_first_tail_x15_r0_body.s1122.stack = PRE_first_tail_x15_r0_body.st116.s2.stack ++ PRE_first_tail_x15_r0_body.s1121.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs116 : PRE_first_tail_x15_r0_body.s1122.jobs = PRE_first_tail_x15_r0_body.st116.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi116 : PRE_first_tail_x15_r0_body.s1122.ffi = PRE_first_tail_x15_r0_body.st116.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace116 : PRE_first_tail_x15_r0_body.s1122.trace = PRE_first_tail_x15_r0_body.st116.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores116 : PRE_first_tail_x15_r0_body.s1122.stores = PRE_first_tail_x15_r0_body.st116.s2.stores

end Host.Load.Run.Tpl
