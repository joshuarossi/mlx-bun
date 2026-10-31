import host.sim.template.a4pre_first_tail_x15_r0_body.H37
import host.sim.template.a4pre_first_tail_x15_r0_body.st123.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 123 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g123__g124` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1195`, the merged state `PRE_first_tail_x15_r0_body.s1196`,
the site template `PRE_first_tail_x15_r0_body.st123` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1197`: the merge.
The footprint's facts are in `SiteF123`, the compaction's in `SiteC123`, `SiteK123`, `SiteNa123`, `SiteNb123`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso123 : PRE_first_tail_x15_r0_body.st123.s0 = { PRE_first_tail_x15_r0_body.s1195 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs123 : List Frame := PRE_first_tail_x15_r0_body.s1195.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_123 : PRE_first_tail_x15_r0_body.S1195.tab.length = 5342
kernel_rfl PRE_first_tail_x15_r0_body.tab0_123 : PRE_first_tail_x15_r0_body.st123.S0.tab = PRE_first_tail_x15_r0_body.S1195.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws123 : List Nat := [3050, 3051, 3052, 3053, 3054, 3055, 3056, 3057, 3058, 3059, 3060, 3061, 3062, 3063, 3064, 3065, 3066, 3067, 3068, 3069, 3070, 3071, 3072, 3073, 3074, 3075, 3076, 3077, 3078, 3079, 3080]
kernel_rfl PRE_first_tail_x15_r0_body.fresh123 : (PRE_first_tail_x15_r0_body.S1195.tab.all fun e => PRE_first_tail_x15_r0_body.ws123.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1195.oracle.all fun q => PRE_first_tail_x15_r0_body.ws123.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab123 : PRE_first_tail_x15_r0_body.S1196.tab = PRE_first_tail_x15_r0_body.S1195.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws123
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen123 : PRE_first_tail_x15_r0_body.st123.S5.tab.length - PRE_first_tail_x15_r0_body.st123.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged123`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap123 : PRE_first_tail_x15_r0_body.s1196.heap = PRE_first_tail_x15_r0_body.st123.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext123 : PRE_first_tail_x15_r0_body.s1196.next = PRE_first_tail_x15_r0_body.st123.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl123 : PRE_first_tail_x15_r0_body.s1196.ctl = PRE_first_tail_x15_r0_body.st123.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack123 : PRE_first_tail_x15_r0_body.s1196.stack = PRE_first_tail_x15_r0_body.st123.s5.stack ++ PRE_first_tail_x15_r0_body.s1195.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs123 : PRE_first_tail_x15_r0_body.s1196.jobs = PRE_first_tail_x15_r0_body.st123.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi123 : PRE_first_tail_x15_r0_body.s1196.ffi = PRE_first_tail_x15_r0_body.st123.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace123 : PRE_first_tail_x15_r0_body.s1196.trace = PRE_first_tail_x15_r0_body.st123.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores123 : PRE_first_tail_x15_r0_body.s1196.stores = PRE_first_tail_x15_r0_body.st123.s5.stores

end Host.Load.Run.Tpl
