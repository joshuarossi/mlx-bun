import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.a4pre_first_tail_x15_r0_body.st61.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 61 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g61__g62` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s599`, the merged state `PRE_first_tail_x15_r0_body.s600`,
the site template `PRE_first_tail_x15_r0_body.st61` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s601`: the merge.
The footprint's facts are in `SiteF61`, the compaction's in `SiteC61`, `SiteK61`, `SiteNa61`, `SiteNb61`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso61 : PRE_first_tail_x15_r0_body.st61.s0 = { PRE_first_tail_x15_r0_body.s599 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs61 : List Frame := PRE_first_tail_x15_r0_body.s599.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_61 : PRE_first_tail_x15_r0_body.S599.tab.length = 2687
kernel_rfl PRE_first_tail_x15_r0_body.tab0_61 : PRE_first_tail_x15_r0_body.st61.S0.tab = PRE_first_tail_x15_r0_body.S599.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws61 : List Nat := [2056, 2057]
kernel_rfl PRE_first_tail_x15_r0_body.fresh61 : (PRE_first_tail_x15_r0_body.S599.tab.all fun e => PRE_first_tail_x15_r0_body.ws61.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S599.oracle.all fun q => PRE_first_tail_x15_r0_body.ws61.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab61 : PRE_first_tail_x15_r0_body.S600.tab = PRE_first_tail_x15_r0_body.S599.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws61
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen61 : PRE_first_tail_x15_r0_body.st61.S2.tab.length - PRE_first_tail_x15_r0_body.st61.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged61`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap61 : PRE_first_tail_x15_r0_body.s600.heap = PRE_first_tail_x15_r0_body.st61.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext61 : PRE_first_tail_x15_r0_body.s600.next = PRE_first_tail_x15_r0_body.st61.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl61 : PRE_first_tail_x15_r0_body.s600.ctl = PRE_first_tail_x15_r0_body.st61.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack61 : PRE_first_tail_x15_r0_body.s600.stack = PRE_first_tail_x15_r0_body.st61.s2.stack ++ PRE_first_tail_x15_r0_body.s599.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs61 : PRE_first_tail_x15_r0_body.s600.jobs = PRE_first_tail_x15_r0_body.st61.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi61 : PRE_first_tail_x15_r0_body.s600.ffi = PRE_first_tail_x15_r0_body.st61.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace61 : PRE_first_tail_x15_r0_body.s600.trace = PRE_first_tail_x15_r0_body.st61.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores61 : PRE_first_tail_x15_r0_body.s600.stores = PRE_first_tail_x15_r0_body.st61.s2.stores

end Host.Load.Run.Tpl
