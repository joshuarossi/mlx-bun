import host.sim.template.a4pre_first_tail_x15_r0_body.H20
import host.sim.template.a4pre_first_tail_x15_r0_body.st74.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 74 of chain `PRE_first_tail_x15_r0_body`: `plan__g74__g75` (`plan`), the call state `PRE_first_tail_x15_r0_body.s655`, the merged state `PRE_first_tail_x15_r0_body.s656`,
the site template `PRE_first_tail_x15_r0_body.st74` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s657`: the merge.
The footprint's facts are in `SiteF74`, the compaction's in `SiteC74`, `SiteK74`, `SiteNa74`, `SiteNb74`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso74 : PRE_first_tail_x15_r0_body.st74.s0 = { PRE_first_tail_x15_r0_body.s655 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs74 : List Frame := PRE_first_tail_x15_r0_body.s655.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_74 : PRE_first_tail_x15_r0_body.S655.tab.length = 3217
kernel_rfl PRE_first_tail_x15_r0_body.tab0_74 : PRE_first_tail_x15_r0_body.st74.S0.tab = PRE_first_tail_x15_r0_body.S655.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws74 : List Nat := [2251, 2252, 2253]
kernel_rfl PRE_first_tail_x15_r0_body.fresh74 : (PRE_first_tail_x15_r0_body.S655.tab.all fun e => PRE_first_tail_x15_r0_body.ws74.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S655.oracle.all fun q => PRE_first_tail_x15_r0_body.ws74.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab74 : PRE_first_tail_x15_r0_body.S656.tab = PRE_first_tail_x15_r0_body.S655.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws74
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen74 : PRE_first_tail_x15_r0_body.st74.S2.tab.length - PRE_first_tail_x15_r0_body.st74.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged74`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap74 : PRE_first_tail_x15_r0_body.s656.heap = PRE_first_tail_x15_r0_body.st74.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext74 : PRE_first_tail_x15_r0_body.s656.next = PRE_first_tail_x15_r0_body.st74.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl74 : PRE_first_tail_x15_r0_body.s656.ctl = PRE_first_tail_x15_r0_body.st74.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack74 : PRE_first_tail_x15_r0_body.s656.stack = PRE_first_tail_x15_r0_body.st74.s2.stack ++ PRE_first_tail_x15_r0_body.s655.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs74 : PRE_first_tail_x15_r0_body.s656.jobs = PRE_first_tail_x15_r0_body.st74.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi74 : PRE_first_tail_x15_r0_body.s656.ffi = PRE_first_tail_x15_r0_body.st74.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace74 : PRE_first_tail_x15_r0_body.s656.trace = PRE_first_tail_x15_r0_body.st74.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores74 : PRE_first_tail_x15_r0_body.s656.stores = PRE_first_tail_x15_r0_body.st74.s2.stores

end Host.Load.Run.Tpl
