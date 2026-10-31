import host.sim.template.a4pre_first_tail_x15_r0_body.H16
import host.sim.template.a4pre_first_tail_x15_r0_body.st59.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 59 of chain `PRE_first_tail_x15_r0_body`: `plan__g59__g60` (`plan`), the call state `PRE_first_tail_x15_r0_body.s523`, the merged state `PRE_first_tail_x15_r0_body.s524`,
the site template `PRE_first_tail_x15_r0_body.st59` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s525`: the merge.
The footprint's facts are in `SiteF59`, the compaction's in `SiteC59`, `SiteK59`, `SiteNa59`, `SiteNb59`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso59 : PRE_first_tail_x15_r0_body.st59.s0 = { PRE_first_tail_x15_r0_body.s523 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs59 : List Frame := PRE_first_tail_x15_r0_body.s523.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_59 : PRE_first_tail_x15_r0_body.S523.tab.length = 2575
kernel_rfl PRE_first_tail_x15_r0_body.tab0_59 : PRE_first_tail_x15_r0_body.st59.S0.tab = PRE_first_tail_x15_r0_body.S523.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws59 : List Nat := [2004, 2005, 2006]
kernel_rfl PRE_first_tail_x15_r0_body.fresh59 : (PRE_first_tail_x15_r0_body.S523.tab.all fun e => PRE_first_tail_x15_r0_body.ws59.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S523.oracle.all fun q => PRE_first_tail_x15_r0_body.ws59.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab59 : PRE_first_tail_x15_r0_body.S524.tab = PRE_first_tail_x15_r0_body.S523.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws59
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen59 : PRE_first_tail_x15_r0_body.st59.S2.tab.length - PRE_first_tail_x15_r0_body.st59.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged59`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap59 : PRE_first_tail_x15_r0_body.s524.heap = PRE_first_tail_x15_r0_body.st59.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext59 : PRE_first_tail_x15_r0_body.s524.next = PRE_first_tail_x15_r0_body.st59.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl59 : PRE_first_tail_x15_r0_body.s524.ctl = PRE_first_tail_x15_r0_body.st59.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack59 : PRE_first_tail_x15_r0_body.s524.stack = PRE_first_tail_x15_r0_body.st59.s2.stack ++ PRE_first_tail_x15_r0_body.s523.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs59 : PRE_first_tail_x15_r0_body.s524.jobs = PRE_first_tail_x15_r0_body.st59.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi59 : PRE_first_tail_x15_r0_body.s524.ffi = PRE_first_tail_x15_r0_body.st59.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace59 : PRE_first_tail_x15_r0_body.s524.trace = PRE_first_tail_x15_r0_body.st59.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores59 : PRE_first_tail_x15_r0_body.s524.stores = PRE_first_tail_x15_r0_body.st59.s2.stores

end Host.Load.Run.Tpl
