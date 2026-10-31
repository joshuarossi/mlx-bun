import host.sim.template.a4pre_first_tail_x15_r0_body.H50
import host.sim.template.a4pre_first_tail_x15_r0_body.st167.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 167 of chain `PRE_first_tail_x15_r0_body`: `plan__g167__g168` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1609`, the merged state `PRE_first_tail_x15_r0_body.s1610`,
the site template `PRE_first_tail_x15_r0_body.st167` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1611`: the merge.
The footprint's facts are in `SiteF167`, the compaction's in `SiteC167`, `SiteK167`, `SiteNa167`, `SiteNb167`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso167 : PRE_first_tail_x15_r0_body.st167.s0 = { PRE_first_tail_x15_r0_body.s1609 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs167 : List Frame := PRE_first_tail_x15_r0_body.s1609.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_167 : PRE_first_tail_x15_r0_body.S1609.tab.length = 7192
kernel_rfl PRE_first_tail_x15_r0_body.tab0_167 : PRE_first_tail_x15_r0_body.st167.S0.tab = PRE_first_tail_x15_r0_body.S1609.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws167 : List Nat := [3801, 3802, 3803, 3804, 3805, 3806, 3807, 3808, 3809]
kernel_rfl PRE_first_tail_x15_r0_body.fresh167 : (PRE_first_tail_x15_r0_body.S1609.tab.all fun e => PRE_first_tail_x15_r0_body.ws167.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1609.oracle.all fun q => PRE_first_tail_x15_r0_body.ws167.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab167 : PRE_first_tail_x15_r0_body.S1610.tab = PRE_first_tail_x15_r0_body.S1609.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws167
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen167 : PRE_first_tail_x15_r0_body.st167.S2.tab.length - PRE_first_tail_x15_r0_body.st167.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged167`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap167 : PRE_first_tail_x15_r0_body.s1610.heap = PRE_first_tail_x15_r0_body.st167.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext167 : PRE_first_tail_x15_r0_body.s1610.next = PRE_first_tail_x15_r0_body.st167.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl167 : PRE_first_tail_x15_r0_body.s1610.ctl = PRE_first_tail_x15_r0_body.st167.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack167 : PRE_first_tail_x15_r0_body.s1610.stack = PRE_first_tail_x15_r0_body.st167.s2.stack ++ PRE_first_tail_x15_r0_body.s1609.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs167 : PRE_first_tail_x15_r0_body.s1610.jobs = PRE_first_tail_x15_r0_body.st167.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi167 : PRE_first_tail_x15_r0_body.s1610.ffi = PRE_first_tail_x15_r0_body.st167.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace167 : PRE_first_tail_x15_r0_body.s1610.trace = PRE_first_tail_x15_r0_body.st167.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores167 : PRE_first_tail_x15_r0_body.s1610.stores = PRE_first_tail_x15_r0_body.st167.s2.stores

end Host.Load.Run.Tpl
