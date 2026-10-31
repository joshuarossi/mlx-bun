import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.st119.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 119 of chain `PRE_first_tail_x15_r0_body`: `plan__g119__g120` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1149`, the merged state `PRE_first_tail_x15_r0_body.s1150`,
the site template `PRE_first_tail_x15_r0_body.st119` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1151`: the merge.
The footprint's facts are in `SiteF119`, the compaction's in `SiteC119`, `SiteK119`, `SiteNa119`, `SiteNb119`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso119 : PRE_first_tail_x15_r0_body.st119.s0 = { PRE_first_tail_x15_r0_body.s1149 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs119 : List Frame := PRE_first_tail_x15_r0_body.s1149.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_119 : PRE_first_tail_x15_r0_body.S1149.tab.length = 5140
kernel_rfl PRE_first_tail_x15_r0_body.tab0_119 : PRE_first_tail_x15_r0_body.st119.S0.tab = PRE_first_tail_x15_r0_body.S1149.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws119 : List Nat := [2993, 2994, 2995]
kernel_rfl PRE_first_tail_x15_r0_body.fresh119 : (PRE_first_tail_x15_r0_body.S1149.tab.all fun e => PRE_first_tail_x15_r0_body.ws119.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1149.oracle.all fun q => PRE_first_tail_x15_r0_body.ws119.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab119 : PRE_first_tail_x15_r0_body.S1150.tab = PRE_first_tail_x15_r0_body.S1149.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws119
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen119 : PRE_first_tail_x15_r0_body.st119.S2.tab.length - PRE_first_tail_x15_r0_body.st119.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged119`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap119 : PRE_first_tail_x15_r0_body.s1150.heap = PRE_first_tail_x15_r0_body.st119.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext119 : PRE_first_tail_x15_r0_body.s1150.next = PRE_first_tail_x15_r0_body.st119.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl119 : PRE_first_tail_x15_r0_body.s1150.ctl = PRE_first_tail_x15_r0_body.st119.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack119 : PRE_first_tail_x15_r0_body.s1150.stack = PRE_first_tail_x15_r0_body.st119.s2.stack ++ PRE_first_tail_x15_r0_body.s1149.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs119 : PRE_first_tail_x15_r0_body.s1150.jobs = PRE_first_tail_x15_r0_body.st119.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi119 : PRE_first_tail_x15_r0_body.s1150.ffi = PRE_first_tail_x15_r0_body.st119.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace119 : PRE_first_tail_x15_r0_body.s1150.trace = PRE_first_tail_x15_r0_body.st119.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores119 : PRE_first_tail_x15_r0_body.s1150.stores = PRE_first_tail_x15_r0_body.st119.s2.stores

end Host.Load.Run.Tpl
