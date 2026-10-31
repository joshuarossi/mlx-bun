import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.st102.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 102 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g102__g103` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s994`, the merged state `PRE_first_tail_x15_r0_body.s995`,
the site template `PRE_first_tail_x15_r0_body.st102` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s996`: the merge.
The footprint's facts are in `SiteF102`, the compaction's in `SiteC102`, `SiteK102`, `SiteNa102`, `SiteNb102`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso102 : PRE_first_tail_x15_r0_body.st102.s0 = { PRE_first_tail_x15_r0_body.s994 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs102 : List Frame := PRE_first_tail_x15_r0_body.s994.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_102 : PRE_first_tail_x15_r0_body.S994.tab.length = 4445
kernel_rfl PRE_first_tail_x15_r0_body.tab0_102 : PRE_first_tail_x15_r0_body.st102.S0.tab = PRE_first_tail_x15_r0_body.S994.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws102 : List Nat := [2718, 2719, 2720, 2721, 2722, 2723, 2724, 2725, 2726, 2727, 2728, 2729, 2730, 2731, 2732, 2733, 2734, 2735, 2736, 2737, 2738, 2739, 2740, 2741, 2742, 2743, 2744, 2745, 2746, 2747, 2748]
kernel_rfl PRE_first_tail_x15_r0_body.fresh102 : (PRE_first_tail_x15_r0_body.S994.tab.all fun e => PRE_first_tail_x15_r0_body.ws102.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S994.oracle.all fun q => PRE_first_tail_x15_r0_body.ws102.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab102 : PRE_first_tail_x15_r0_body.S995.tab = PRE_first_tail_x15_r0_body.S994.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws102
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen102 : PRE_first_tail_x15_r0_body.st102.S5.tab.length - PRE_first_tail_x15_r0_body.st102.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged102`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap102 : PRE_first_tail_x15_r0_body.s995.heap = PRE_first_tail_x15_r0_body.st102.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext102 : PRE_first_tail_x15_r0_body.s995.next = PRE_first_tail_x15_r0_body.st102.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl102 : PRE_first_tail_x15_r0_body.s995.ctl = PRE_first_tail_x15_r0_body.st102.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack102 : PRE_first_tail_x15_r0_body.s995.stack = PRE_first_tail_x15_r0_body.st102.s5.stack ++ PRE_first_tail_x15_r0_body.s994.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs102 : PRE_first_tail_x15_r0_body.s995.jobs = PRE_first_tail_x15_r0_body.st102.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi102 : PRE_first_tail_x15_r0_body.s995.ffi = PRE_first_tail_x15_r0_body.st102.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace102 : PRE_first_tail_x15_r0_body.s995.trace = PRE_first_tail_x15_r0_body.st102.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores102 : PRE_first_tail_x15_r0_body.s995.stores = PRE_first_tail_x15_r0_body.st102.s5.stores

end Host.Load.Run.Tpl
