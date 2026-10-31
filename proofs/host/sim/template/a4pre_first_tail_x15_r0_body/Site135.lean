import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.st135.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 135 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g135__g136` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1310`, the merged state `PRE_first_tail_x15_r0_body.s1311`,
the site template `PRE_first_tail_x15_r0_body.st135` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1312`: the merge.
The footprint's facts are in `SiteF135`, the compaction's in `SiteC135`, `SiteK135`, `SiteNa135`, `SiteNb135`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso135 : PRE_first_tail_x15_r0_body.st135.s0 = { PRE_first_tail_x15_r0_body.s1310 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs135 : List Frame := PRE_first_tail_x15_r0_body.s1310.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_135 : PRE_first_tail_x15_r0_body.S1310.tab.length = 5855
kernel_rfl PRE_first_tail_x15_r0_body.tab0_135 : PRE_first_tail_x15_r0_body.st135.S0.tab = PRE_first_tail_x15_r0_body.S1310.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws135 : List Nat := [3243, 3244, 3245, 3246, 3247, 3248, 3249, 3250, 3251, 3252, 3253, 3254, 3255, 3256, 3257, 3258, 3259, 3260, 3261, 3262, 3263, 3264, 3265, 3266, 3267, 3268, 3269, 3270, 3271, 3272, 3273]
kernel_rfl PRE_first_tail_x15_r0_body.fresh135 : (PRE_first_tail_x15_r0_body.S1310.tab.all fun e => PRE_first_tail_x15_r0_body.ws135.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1310.oracle.all fun q => PRE_first_tail_x15_r0_body.ws135.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab135 : PRE_first_tail_x15_r0_body.S1311.tab = PRE_first_tail_x15_r0_body.S1310.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws135
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen135 : PRE_first_tail_x15_r0_body.st135.S5.tab.length - PRE_first_tail_x15_r0_body.st135.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged135`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap135 : PRE_first_tail_x15_r0_body.s1311.heap = PRE_first_tail_x15_r0_body.st135.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext135 : PRE_first_tail_x15_r0_body.s1311.next = PRE_first_tail_x15_r0_body.st135.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl135 : PRE_first_tail_x15_r0_body.s1311.ctl = PRE_first_tail_x15_r0_body.st135.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack135 : PRE_first_tail_x15_r0_body.s1311.stack = PRE_first_tail_x15_r0_body.st135.s5.stack ++ PRE_first_tail_x15_r0_body.s1310.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs135 : PRE_first_tail_x15_r0_body.s1311.jobs = PRE_first_tail_x15_r0_body.st135.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi135 : PRE_first_tail_x15_r0_body.s1311.ffi = PRE_first_tail_x15_r0_body.st135.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace135 : PRE_first_tail_x15_r0_body.s1311.trace = PRE_first_tail_x15_r0_body.st135.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores135 : PRE_first_tail_x15_r0_body.s1311.stores = PRE_first_tail_x15_r0_body.st135.s5.stores

end Host.Load.Run.Tpl
