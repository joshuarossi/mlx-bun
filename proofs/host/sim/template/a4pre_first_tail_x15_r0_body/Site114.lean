import host.sim.template.a4pre_first_tail_x15_r0_body.H34
import host.sim.template.a4pre_first_tail_x15_r0_body.st114.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 114 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g114__g115` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1109`, the merged state `PRE_first_tail_x15_r0_body.s1110`,
the site template `PRE_first_tail_x15_r0_body.st114` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1111`: the merge.
The footprint's facts are in `SiteF114`, the compaction's in `SiteC114`, `SiteK114`, `SiteNa114`, `SiteNb114`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso114 : PRE_first_tail_x15_r0_body.st114.s0 = { PRE_first_tail_x15_r0_body.s1109 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs114 : List Frame := PRE_first_tail_x15_r0_body.s1109.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_114 : PRE_first_tail_x15_r0_body.S1109.tab.length = 4958
kernel_rfl PRE_first_tail_x15_r0_body.tab0_114 : PRE_first_tail_x15_r0_body.st114.S0.tab = PRE_first_tail_x15_r0_body.S1109.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws114 : List Nat := [2911, 2912, 2913, 2914, 2915, 2916, 2917, 2918, 2919, 2920, 2921, 2922, 2923, 2924, 2925, 2926, 2927, 2928, 2929, 2930, 2931, 2932, 2933, 2934, 2935, 2936, 2937, 2938, 2939, 2940, 2941]
kernel_rfl PRE_first_tail_x15_r0_body.fresh114 : (PRE_first_tail_x15_r0_body.S1109.tab.all fun e => PRE_first_tail_x15_r0_body.ws114.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1109.oracle.all fun q => PRE_first_tail_x15_r0_body.ws114.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab114 : PRE_first_tail_x15_r0_body.S1110.tab = PRE_first_tail_x15_r0_body.S1109.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws114
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen114 : PRE_first_tail_x15_r0_body.st114.S5.tab.length - PRE_first_tail_x15_r0_body.st114.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged114`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap114 : PRE_first_tail_x15_r0_body.s1110.heap = PRE_first_tail_x15_r0_body.st114.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext114 : PRE_first_tail_x15_r0_body.s1110.next = PRE_first_tail_x15_r0_body.st114.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl114 : PRE_first_tail_x15_r0_body.s1110.ctl = PRE_first_tail_x15_r0_body.st114.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack114 : PRE_first_tail_x15_r0_body.s1110.stack = PRE_first_tail_x15_r0_body.st114.s5.stack ++ PRE_first_tail_x15_r0_body.s1109.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs114 : PRE_first_tail_x15_r0_body.s1110.jobs = PRE_first_tail_x15_r0_body.st114.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi114 : PRE_first_tail_x15_r0_body.s1110.ffi = PRE_first_tail_x15_r0_body.st114.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace114 : PRE_first_tail_x15_r0_body.s1110.trace = PRE_first_tail_x15_r0_body.st114.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores114 : PRE_first_tail_x15_r0_body.s1110.stores = PRE_first_tail_x15_r0_body.st114.s5.stores

end Host.Load.Run.Tpl
