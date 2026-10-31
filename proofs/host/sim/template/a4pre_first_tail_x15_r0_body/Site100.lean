import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.st100.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 100 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g100__g101` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s888`, the merged state `PRE_first_tail_x15_r0_body.s889`,
the site template `PRE_first_tail_x15_r0_body.st100` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s890`: the merge.
The footprint's facts are in `SiteF100`, the compaction's in `SiteC100`, `SiteK100`, `SiteNa100`, `SiteNb100`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso100 : PRE_first_tail_x15_r0_body.st100.s0 = { PRE_first_tail_x15_r0_body.s888 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs100 : List Frame := PRE_first_tail_x15_r0_body.s888.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_100 : PRE_first_tail_x15_r0_body.S888.tab.length = 4355
kernel_rfl PRE_first_tail_x15_r0_body.tab0_100 : PRE_first_tail_x15_r0_body.st100.S0.tab = PRE_first_tail_x15_r0_body.S888.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws100 : List Nat := [2707, 2708]
kernel_rfl PRE_first_tail_x15_r0_body.fresh100 : (PRE_first_tail_x15_r0_body.S888.tab.all fun e => PRE_first_tail_x15_r0_body.ws100.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S888.oracle.all fun q => PRE_first_tail_x15_r0_body.ws100.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab100 : PRE_first_tail_x15_r0_body.S889.tab = PRE_first_tail_x15_r0_body.S888.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws100
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen100 : PRE_first_tail_x15_r0_body.st100.S2.tab.length - PRE_first_tail_x15_r0_body.st100.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged100`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap100 : PRE_first_tail_x15_r0_body.s889.heap = PRE_first_tail_x15_r0_body.st100.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext100 : PRE_first_tail_x15_r0_body.s889.next = PRE_first_tail_x15_r0_body.st100.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl100 : PRE_first_tail_x15_r0_body.s889.ctl = PRE_first_tail_x15_r0_body.st100.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack100 : PRE_first_tail_x15_r0_body.s889.stack = PRE_first_tail_x15_r0_body.st100.s2.stack ++ PRE_first_tail_x15_r0_body.s888.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs100 : PRE_first_tail_x15_r0_body.s889.jobs = PRE_first_tail_x15_r0_body.st100.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi100 : PRE_first_tail_x15_r0_body.s889.ffi = PRE_first_tail_x15_r0_body.st100.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace100 : PRE_first_tail_x15_r0_body.s889.trace = PRE_first_tail_x15_r0_body.st100.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores100 : PRE_first_tail_x15_r0_body.s889.stores = PRE_first_tail_x15_r0_body.st100.s2.stores

end Host.Load.Run.Tpl
