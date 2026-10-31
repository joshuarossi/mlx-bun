import host.sim.template.a4pre_first_tail_x15_r0_body.H44
import host.sim.template.a4pre_first_tail_x15_r0_body.st146.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 146 of chain `PRE_first_tail_x15_r0_body`: `plan__g146__g147` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1408`, the merged state `PRE_first_tail_x15_r0_body.s1409`,
the site template `PRE_first_tail_x15_r0_body.st146` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1410`: the merge.
The footprint's facts are in `SiteF146`, the compaction's in `SiteC146`, `SiteK146`, `SiteNa146`, `SiteNb146`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso146 : PRE_first_tail_x15_r0_body.st146.s0 = { PRE_first_tail_x15_r0_body.s1408 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs146 : List Frame := PRE_first_tail_x15_r0_body.s1408.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_146 : PRE_first_tail_x15_r0_body.S1408.tab.length = 6295
kernel_rfl PRE_first_tail_x15_r0_body.tab0_146 : PRE_first_tail_x15_r0_body.st146.S0.tab = PRE_first_tail_x15_r0_body.S1408.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws146 : List Nat := [3451, 3452, 3453, 3454, 3455, 3456, 3457, 3458, 3459]
kernel_rfl PRE_first_tail_x15_r0_body.fresh146 : (PRE_first_tail_x15_r0_body.S1408.tab.all fun e => PRE_first_tail_x15_r0_body.ws146.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1408.oracle.all fun q => PRE_first_tail_x15_r0_body.ws146.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab146 : PRE_first_tail_x15_r0_body.S1409.tab = PRE_first_tail_x15_r0_body.S1408.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws146
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen146 : PRE_first_tail_x15_r0_body.st146.S2.tab.length - PRE_first_tail_x15_r0_body.st146.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged146`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap146 : PRE_first_tail_x15_r0_body.s1409.heap = PRE_first_tail_x15_r0_body.st146.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext146 : PRE_first_tail_x15_r0_body.s1409.next = PRE_first_tail_x15_r0_body.st146.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl146 : PRE_first_tail_x15_r0_body.s1409.ctl = PRE_first_tail_x15_r0_body.st146.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack146 : PRE_first_tail_x15_r0_body.s1409.stack = PRE_first_tail_x15_r0_body.st146.s2.stack ++ PRE_first_tail_x15_r0_body.s1408.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs146 : PRE_first_tail_x15_r0_body.s1409.jobs = PRE_first_tail_x15_r0_body.st146.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi146 : PRE_first_tail_x15_r0_body.s1409.ffi = PRE_first_tail_x15_r0_body.st146.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace146 : PRE_first_tail_x15_r0_body.s1409.trace = PRE_first_tail_x15_r0_body.st146.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores146 : PRE_first_tail_x15_r0_body.s1409.stores = PRE_first_tail_x15_r0_body.st146.s2.stores

end Host.Load.Run.Tpl
