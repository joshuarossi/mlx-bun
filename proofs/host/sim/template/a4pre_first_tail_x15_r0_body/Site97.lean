import host.sim.template.a4pre_first_tail_x15_r0_body.H26
import host.sim.template.a4pre_first_tail_x15_r0_body.st97.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 97 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g97__g98` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s861`, the merged state `PRE_first_tail_x15_r0_body.s862`,
the site template `PRE_first_tail_x15_r0_body.st97` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s863`: the merge.
The footprint's facts are in `SiteF97`, the compaction's in `SiteC97`, `SiteK97`, `SiteNa97`, `SiteNb97`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso97 : PRE_first_tail_x15_r0_body.st97.s0 = { PRE_first_tail_x15_r0_body.s861 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs97 : List Frame := PRE_first_tail_x15_r0_body.s861.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_97 : PRE_first_tail_x15_r0_body.S861.tab.length = 4226
kernel_rfl PRE_first_tail_x15_r0_body.tab0_97 : PRE_first_tail_x15_r0_body.st97.S0.tab = PRE_first_tail_x15_r0_body.S861.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws97 : List Nat := [2647, 2648]
kernel_rfl PRE_first_tail_x15_r0_body.fresh97 : (PRE_first_tail_x15_r0_body.S861.tab.all fun e => PRE_first_tail_x15_r0_body.ws97.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S861.oracle.all fun q => PRE_first_tail_x15_r0_body.ws97.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab97 : PRE_first_tail_x15_r0_body.S862.tab = PRE_first_tail_x15_r0_body.S861.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws97
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen97 : PRE_first_tail_x15_r0_body.st97.S2.tab.length - PRE_first_tail_x15_r0_body.st97.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged97`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap97 : PRE_first_tail_x15_r0_body.s862.heap = PRE_first_tail_x15_r0_body.st97.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext97 : PRE_first_tail_x15_r0_body.s862.next = PRE_first_tail_x15_r0_body.st97.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl97 : PRE_first_tail_x15_r0_body.s862.ctl = PRE_first_tail_x15_r0_body.st97.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack97 : PRE_first_tail_x15_r0_body.s862.stack = PRE_first_tail_x15_r0_body.st97.s2.stack ++ PRE_first_tail_x15_r0_body.s861.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs97 : PRE_first_tail_x15_r0_body.s862.jobs = PRE_first_tail_x15_r0_body.st97.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi97 : PRE_first_tail_x15_r0_body.s862.ffi = PRE_first_tail_x15_r0_body.st97.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace97 : PRE_first_tail_x15_r0_body.s862.trace = PRE_first_tail_x15_r0_body.st97.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores97 : PRE_first_tail_x15_r0_body.s862.stores = PRE_first_tail_x15_r0_body.st97.s2.stores

end Host.Load.Run.Tpl
