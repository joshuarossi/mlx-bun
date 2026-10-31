import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.st138.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 138 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g138__g139` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1339`, the merged state `PRE_first_tail_x15_r0_body.s1340`,
the site template `PRE_first_tail_x15_r0_body.st138` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1341`: the merge.
The footprint's facts are in `SiteF138`, the compaction's in `SiteC138`, `SiteK138`, `SiteNa138`, `SiteNb138`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso138 : PRE_first_tail_x15_r0_body.st138.s0 = { PRE_first_tail_x15_r0_body.s1339 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs138 : List Frame := PRE_first_tail_x15_r0_body.s1339.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_138 : PRE_first_tail_x15_r0_body.S1339.tab.length = 5984
kernel_rfl PRE_first_tail_x15_r0_body.tab0_138 : PRE_first_tail_x15_r0_body.st138.S0.tab = PRE_first_tail_x15_r0_body.S1339.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws138 : List Nat := [3303, 3304, 3305, 3306, 3307, 3308, 3309, 3310, 3311, 3312, 3313, 3314, 3315, 3316, 3317, 3318, 3319, 3320, 3321, 3322, 3323, 3324, 3325, 3326, 3327, 3328, 3329, 3330, 3331, 3332, 3333]
kernel_rfl PRE_first_tail_x15_r0_body.fresh138 : (PRE_first_tail_x15_r0_body.S1339.tab.all fun e => PRE_first_tail_x15_r0_body.ws138.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1339.oracle.all fun q => PRE_first_tail_x15_r0_body.ws138.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab138 : PRE_first_tail_x15_r0_body.S1340.tab = PRE_first_tail_x15_r0_body.S1339.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws138
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen138 : PRE_first_tail_x15_r0_body.st138.S5.tab.length - PRE_first_tail_x15_r0_body.st138.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged138`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap138 : PRE_first_tail_x15_r0_body.s1340.heap = PRE_first_tail_x15_r0_body.st138.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext138 : PRE_first_tail_x15_r0_body.s1340.next = PRE_first_tail_x15_r0_body.st138.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl138 : PRE_first_tail_x15_r0_body.s1340.ctl = PRE_first_tail_x15_r0_body.st138.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack138 : PRE_first_tail_x15_r0_body.s1340.stack = PRE_first_tail_x15_r0_body.st138.s5.stack ++ PRE_first_tail_x15_r0_body.s1339.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs138 : PRE_first_tail_x15_r0_body.s1340.jobs = PRE_first_tail_x15_r0_body.st138.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi138 : PRE_first_tail_x15_r0_body.s1340.ffi = PRE_first_tail_x15_r0_body.st138.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace138 : PRE_first_tail_x15_r0_body.s1340.trace = PRE_first_tail_x15_r0_body.st138.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores138 : PRE_first_tail_x15_r0_body.s1340.stores = PRE_first_tail_x15_r0_body.st138.s5.stores

end Host.Load.Run.Tpl
