import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.a4pre_first_tail_x15_r0_body.st77.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 77 of chain `PRE_first_tail_x15_r0_body`: `plan__g77__g78` (`plan`), the call state `PRE_first_tail_x15_r0_body.s682`, the merged state `PRE_first_tail_x15_r0_body.s683`,
the site template `PRE_first_tail_x15_r0_body.st77` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s684`: the merge.
The footprint's facts are in `SiteF77`, the compaction's in `SiteC77`, `SiteK77`, `SiteNa77`, `SiteNb77`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso77 : PRE_first_tail_x15_r0_body.st77.s0 = { PRE_first_tail_x15_r0_body.s682 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs77 : List Frame := PRE_first_tail_x15_r0_body.s682.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_77 : PRE_first_tail_x15_r0_body.S682.tab.length = 3346
kernel_rfl PRE_first_tail_x15_r0_body.tab0_77 : PRE_first_tail_x15_r0_body.st77.S0.tab = PRE_first_tail_x15_r0_body.S682.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws77 : List Nat := [2305, 2306, 2307]
kernel_rfl PRE_first_tail_x15_r0_body.fresh77 : (PRE_first_tail_x15_r0_body.S682.tab.all fun e => PRE_first_tail_x15_r0_body.ws77.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S682.oracle.all fun q => PRE_first_tail_x15_r0_body.ws77.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab77 : PRE_first_tail_x15_r0_body.S683.tab = PRE_first_tail_x15_r0_body.S682.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws77
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen77 : PRE_first_tail_x15_r0_body.st77.S2.tab.length - PRE_first_tail_x15_r0_body.st77.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged77`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap77 : PRE_first_tail_x15_r0_body.s683.heap = PRE_first_tail_x15_r0_body.st77.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext77 : PRE_first_tail_x15_r0_body.s683.next = PRE_first_tail_x15_r0_body.st77.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl77 : PRE_first_tail_x15_r0_body.s683.ctl = PRE_first_tail_x15_r0_body.st77.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack77 : PRE_first_tail_x15_r0_body.s683.stack = PRE_first_tail_x15_r0_body.st77.s2.stack ++ PRE_first_tail_x15_r0_body.s682.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs77 : PRE_first_tail_x15_r0_body.s683.jobs = PRE_first_tail_x15_r0_body.st77.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi77 : PRE_first_tail_x15_r0_body.s683.ffi = PRE_first_tail_x15_r0_body.st77.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace77 : PRE_first_tail_x15_r0_body.s683.trace = PRE_first_tail_x15_r0_body.st77.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores77 : PRE_first_tail_x15_r0_body.s683.stores = PRE_first_tail_x15_r0_body.st77.s2.stores

end Host.Load.Run.Tpl
