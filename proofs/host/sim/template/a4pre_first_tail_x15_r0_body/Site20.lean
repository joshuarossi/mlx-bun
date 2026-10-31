import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.a4pre_first_tail_x15_r0_body.st20.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 20 of chain `PRE_first_tail_x15_r0_body`: `plan__g20__g21` (`plan`), the call state `PRE_first_tail_x15_r0_body.s201`, the merged state `PRE_first_tail_x15_r0_body.s202`,
the site template `PRE_first_tail_x15_r0_body.st20` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s203`: the merge.
The footprint's facts are in `SiteF20`, the compaction's in `SiteC20`, `SiteK20`, `SiteNa20`, `SiteNb20`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso20 : PRE_first_tail_x15_r0_body.st20.s0 = { PRE_first_tail_x15_r0_body.s201 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs20 : List Frame := PRE_first_tail_x15_r0_body.s201.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_20 : PRE_first_tail_x15_r0_body.S201.tab.length = 910
kernel_rfl PRE_first_tail_x15_r0_body.tab0_20 : PRE_first_tail_x15_r0_body.st20.S0.tab = PRE_first_tail_x15_r0_body.S201.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws20 : List Nat := [1358, 1359, 1360]
kernel_rfl PRE_first_tail_x15_r0_body.fresh20 : (PRE_first_tail_x15_r0_body.S201.tab.all fun e => PRE_first_tail_x15_r0_body.ws20.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S201.oracle.all fun q => PRE_first_tail_x15_r0_body.ws20.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab20 : PRE_first_tail_x15_r0_body.S202.tab = PRE_first_tail_x15_r0_body.S201.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws20
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen20 : PRE_first_tail_x15_r0_body.st20.S2.tab.length - PRE_first_tail_x15_r0_body.st20.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged20`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap20 : PRE_first_tail_x15_r0_body.s202.heap = PRE_first_tail_x15_r0_body.st20.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext20 : PRE_first_tail_x15_r0_body.s202.next = PRE_first_tail_x15_r0_body.st20.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl20 : PRE_first_tail_x15_r0_body.s202.ctl = PRE_first_tail_x15_r0_body.st20.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack20 : PRE_first_tail_x15_r0_body.s202.stack = PRE_first_tail_x15_r0_body.st20.s2.stack ++ PRE_first_tail_x15_r0_body.s201.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs20 : PRE_first_tail_x15_r0_body.s202.jobs = PRE_first_tail_x15_r0_body.st20.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi20 : PRE_first_tail_x15_r0_body.s202.ffi = PRE_first_tail_x15_r0_body.st20.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace20 : PRE_first_tail_x15_r0_body.s202.trace = PRE_first_tail_x15_r0_body.st20.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores20 : PRE_first_tail_x15_r0_body.s202.stores = PRE_first_tail_x15_r0_body.st20.s2.stores

end Host.Load.Run.Tpl
