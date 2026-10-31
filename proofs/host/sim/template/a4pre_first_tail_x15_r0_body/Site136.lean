import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.st136.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 136 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g136__g137` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1318`, the merged state `PRE_first_tail_x15_r0_body.s1319`,
the site template `PRE_first_tail_x15_r0_body.st136` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1320`: the merge.
The footprint's facts are in `SiteF136`, the compaction's in `SiteC136`, `SiteK136`, `SiteNa136`, `SiteNb136`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso136 : PRE_first_tail_x15_r0_body.st136.s0 = { PRE_first_tail_x15_r0_body.s1318 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs136 : List Frame := PRE_first_tail_x15_r0_body.s1318.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_136 : PRE_first_tail_x15_r0_body.S1318.tab.length = 5894
kernel_rfl PRE_first_tail_x15_r0_body.tab0_136 : PRE_first_tail_x15_r0_body.st136.S0.tab = PRE_first_tail_x15_r0_body.S1318.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws136 : List Nat := [3292, 3293]
kernel_rfl PRE_first_tail_x15_r0_body.fresh136 : (PRE_first_tail_x15_r0_body.S1318.tab.all fun e => PRE_first_tail_x15_r0_body.ws136.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1318.oracle.all fun q => PRE_first_tail_x15_r0_body.ws136.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab136 : PRE_first_tail_x15_r0_body.S1319.tab = PRE_first_tail_x15_r0_body.S1318.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws136
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen136 : PRE_first_tail_x15_r0_body.st136.S2.tab.length - PRE_first_tail_x15_r0_body.st136.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged136`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap136 : PRE_first_tail_x15_r0_body.s1319.heap = PRE_first_tail_x15_r0_body.st136.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext136 : PRE_first_tail_x15_r0_body.s1319.next = PRE_first_tail_x15_r0_body.st136.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl136 : PRE_first_tail_x15_r0_body.s1319.ctl = PRE_first_tail_x15_r0_body.st136.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack136 : PRE_first_tail_x15_r0_body.s1319.stack = PRE_first_tail_x15_r0_body.st136.s2.stack ++ PRE_first_tail_x15_r0_body.s1318.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs136 : PRE_first_tail_x15_r0_body.s1319.jobs = PRE_first_tail_x15_r0_body.st136.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi136 : PRE_first_tail_x15_r0_body.s1319.ffi = PRE_first_tail_x15_r0_body.st136.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace136 : PRE_first_tail_x15_r0_body.s1319.trace = PRE_first_tail_x15_r0_body.st136.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores136 : PRE_first_tail_x15_r0_body.s1319.stores = PRE_first_tail_x15_r0_body.st136.s2.stores

end Host.Load.Run.Tpl
