import host.sim.template.a4pre_first_tail_x15_r0_body.H23
import host.sim.template.a4pre_first_tail_x15_r0_body.st86.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 86 of chain `PRE_first_tail_x15_r0_body`: `plan__g86__g87` (`plan`), the call state `PRE_first_tail_x15_r0_body.s760`, the merged state `PRE_first_tail_x15_r0_body.s761`,
the site template `PRE_first_tail_x15_r0_body.st86` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s762`: the merge.
The footprint's facts are in `SiteF86`, the compaction's in `SiteC86`, `SiteK86`, `SiteNa86`, `SiteNb86`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso86 : PRE_first_tail_x15_r0_body.st86.s0 = { PRE_first_tail_x15_r0_body.s760 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs86 : List Frame := PRE_first_tail_x15_r0_body.s760.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_86 : PRE_first_tail_x15_r0_body.S760.tab.length = 3730
kernel_rfl PRE_first_tail_x15_r0_body.tab0_86 : PRE_first_tail_x15_r0_body.st86.S0.tab = PRE_first_tail_x15_r0_body.S760.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws86 : List Nat := [2444, 2445, 2446]
kernel_rfl PRE_first_tail_x15_r0_body.fresh86 : (PRE_first_tail_x15_r0_body.S760.tab.all fun e => PRE_first_tail_x15_r0_body.ws86.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S760.oracle.all fun q => PRE_first_tail_x15_r0_body.ws86.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab86 : PRE_first_tail_x15_r0_body.S761.tab = PRE_first_tail_x15_r0_body.S760.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws86
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen86 : PRE_first_tail_x15_r0_body.st86.S2.tab.length - PRE_first_tail_x15_r0_body.st86.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged86`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap86 : PRE_first_tail_x15_r0_body.s761.heap = PRE_first_tail_x15_r0_body.st86.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext86 : PRE_first_tail_x15_r0_body.s761.next = PRE_first_tail_x15_r0_body.st86.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl86 : PRE_first_tail_x15_r0_body.s761.ctl = PRE_first_tail_x15_r0_body.st86.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack86 : PRE_first_tail_x15_r0_body.s761.stack = PRE_first_tail_x15_r0_body.st86.s2.stack ++ PRE_first_tail_x15_r0_body.s760.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs86 : PRE_first_tail_x15_r0_body.s761.jobs = PRE_first_tail_x15_r0_body.st86.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi86 : PRE_first_tail_x15_r0_body.s761.ffi = PRE_first_tail_x15_r0_body.st86.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace86 : PRE_first_tail_x15_r0_body.s761.trace = PRE_first_tail_x15_r0_body.st86.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores86 : PRE_first_tail_x15_r0_body.s761.stores = PRE_first_tail_x15_r0_body.st86.s2.stores

end Host.Load.Run.Tpl
