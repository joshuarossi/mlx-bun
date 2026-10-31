import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.st126.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 126 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g126__g127` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1224`, the merged state `PRE_first_tail_x15_r0_body.s1225`,
the site template `PRE_first_tail_x15_r0_body.st126` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1226`: the merge.
The footprint's facts are in `SiteF126`, the compaction's in `SiteC126`, `SiteK126`, `SiteNa126`, `SiteNb126`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso126 : PRE_first_tail_x15_r0_body.st126.s0 = { PRE_first_tail_x15_r0_body.s1224 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs126 : List Frame := PRE_first_tail_x15_r0_body.s1224.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_126 : PRE_first_tail_x15_r0_body.S1224.tab.length = 5471
kernel_rfl PRE_first_tail_x15_r0_body.tab0_126 : PRE_first_tail_x15_r0_body.st126.S0.tab = PRE_first_tail_x15_r0_body.S1224.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws126 : List Nat := [3104, 3105, 3106, 3107, 3108, 3109, 3110, 3111, 3112, 3113, 3114, 3115, 3116, 3117, 3118, 3119, 3120, 3121, 3122, 3123, 3124, 3125, 3126, 3127, 3128, 3129, 3130, 3131, 3132, 3133, 3134]
kernel_rfl PRE_first_tail_x15_r0_body.fresh126 : (PRE_first_tail_x15_r0_body.S1224.tab.all fun e => PRE_first_tail_x15_r0_body.ws126.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1224.oracle.all fun q => PRE_first_tail_x15_r0_body.ws126.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab126 : PRE_first_tail_x15_r0_body.S1225.tab = PRE_first_tail_x15_r0_body.S1224.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws126
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen126 : PRE_first_tail_x15_r0_body.st126.S5.tab.length - PRE_first_tail_x15_r0_body.st126.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged126`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap126 : PRE_first_tail_x15_r0_body.s1225.heap = PRE_first_tail_x15_r0_body.st126.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext126 : PRE_first_tail_x15_r0_body.s1225.next = PRE_first_tail_x15_r0_body.st126.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl126 : PRE_first_tail_x15_r0_body.s1225.ctl = PRE_first_tail_x15_r0_body.st126.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack126 : PRE_first_tail_x15_r0_body.s1225.stack = PRE_first_tail_x15_r0_body.st126.s5.stack ++ PRE_first_tail_x15_r0_body.s1224.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs126 : PRE_first_tail_x15_r0_body.s1225.jobs = PRE_first_tail_x15_r0_body.st126.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi126 : PRE_first_tail_x15_r0_body.s1225.ffi = PRE_first_tail_x15_r0_body.st126.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace126 : PRE_first_tail_x15_r0_body.s1225.trace = PRE_first_tail_x15_r0_body.st126.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores126 : PRE_first_tail_x15_r0_body.s1225.stores = PRE_first_tail_x15_r0_body.st126.s5.stores

end Host.Load.Run.Tpl
