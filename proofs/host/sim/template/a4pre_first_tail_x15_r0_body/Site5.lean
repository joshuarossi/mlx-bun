import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.a4pre_first_tail_x15_r0_body.st5.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 5 of chain `PRE_first_tail_x15_r0_body`: `plan__g5__g6` (`plan`), the call state `PRE_first_tail_x15_r0_body.s52`, the merged state `PRE_first_tail_x15_r0_body.s53`,
the site template `PRE_first_tail_x15_r0_body.st5` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s54`: the merge.
The footprint's facts are in `SiteF5`, the compaction's in `SiteC5`, `SiteK5`, `SiteNa5`, `SiteNb5`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso5 : PRE_first_tail_x15_r0_body.st5.s0 = { PRE_first_tail_x15_r0_body.s52 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs5 : List Frame := PRE_first_tail_x15_r0_body.s52.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_5 : PRE_first_tail_x15_r0_body.S52.tab.length = 268
kernel_rfl PRE_first_tail_x15_r0_body.tab0_5 : PRE_first_tail_x15_r0_body.st5.S0.tab = PRE_first_tail_x15_r0_body.S52.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws5 : List Nat := [1111, 1112, 1113]
kernel_rfl PRE_first_tail_x15_r0_body.fresh5 : (PRE_first_tail_x15_r0_body.S52.tab.all fun e => PRE_first_tail_x15_r0_body.ws5.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S52.oracle.all fun q => PRE_first_tail_x15_r0_body.ws5.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab5 : PRE_first_tail_x15_r0_body.S53.tab = PRE_first_tail_x15_r0_body.S52.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws5
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen5 : PRE_first_tail_x15_r0_body.st5.S2.tab.length - PRE_first_tail_x15_r0_body.st5.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged5`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap5 : PRE_first_tail_x15_r0_body.s53.heap = PRE_first_tail_x15_r0_body.st5.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext5 : PRE_first_tail_x15_r0_body.s53.next = PRE_first_tail_x15_r0_body.st5.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl5 : PRE_first_tail_x15_r0_body.s53.ctl = PRE_first_tail_x15_r0_body.st5.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack5 : PRE_first_tail_x15_r0_body.s53.stack = PRE_first_tail_x15_r0_body.st5.s2.stack ++ PRE_first_tail_x15_r0_body.s52.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs5 : PRE_first_tail_x15_r0_body.s53.jobs = PRE_first_tail_x15_r0_body.st5.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi5 : PRE_first_tail_x15_r0_body.s53.ffi = PRE_first_tail_x15_r0_body.st5.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace5 : PRE_first_tail_x15_r0_body.s53.trace = PRE_first_tail_x15_r0_body.st5.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores5 : PRE_first_tail_x15_r0_body.s53.stores = PRE_first_tail_x15_r0_body.st5.s2.stores

end Host.Load.Run.Tpl
