import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.st56.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 56 of chain `PRE_first_tail_x15_r0_body`: `plan__g56__g57` (`plan`), the call state `PRE_first_tail_x15_r0_body.s546`, the merged state `PRE_first_tail_x15_r0_body.s547`,
the site template `PRE_first_tail_x15_r0_body.st56` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s548`: the merge.
The footprint's facts are in `SiteF56`, the compaction's in `SiteC56`, `SiteK56`, `SiteNa56`, `SiteNb56`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso56 : PRE_first_tail_x15_r0_body.st56.s0 = { PRE_first_tail_x15_r0_body.s546 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs56 : List Frame := PRE_first_tail_x15_r0_body.s546.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_56 : PRE_first_tail_x15_r0_body.S546.tab.length = 2449
kernel_rfl PRE_first_tail_x15_r0_body.tab0_56 : PRE_first_tail_x15_r0_body.st56.S0.tab = PRE_first_tail_x15_r0_body.S546.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws56 : List Nat := [1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975]
kernel_rfl PRE_first_tail_x15_r0_body.fresh56 : (PRE_first_tail_x15_r0_body.S546.tab.all fun e => PRE_first_tail_x15_r0_body.ws56.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S546.oracle.all fun q => PRE_first_tail_x15_r0_body.ws56.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab56 : PRE_first_tail_x15_r0_body.S547.tab = PRE_first_tail_x15_r0_body.S546.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws56
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen56 : PRE_first_tail_x15_r0_body.st56.S2.tab.length - PRE_first_tail_x15_r0_body.st56.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged56`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap56 : PRE_first_tail_x15_r0_body.s547.heap = PRE_first_tail_x15_r0_body.st56.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext56 : PRE_first_tail_x15_r0_body.s547.next = PRE_first_tail_x15_r0_body.st56.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl56 : PRE_first_tail_x15_r0_body.s547.ctl = PRE_first_tail_x15_r0_body.st56.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack56 : PRE_first_tail_x15_r0_body.s547.stack = PRE_first_tail_x15_r0_body.st56.s2.stack ++ PRE_first_tail_x15_r0_body.s546.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs56 : PRE_first_tail_x15_r0_body.s547.jobs = PRE_first_tail_x15_r0_body.st56.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi56 : PRE_first_tail_x15_r0_body.s547.ffi = PRE_first_tail_x15_r0_body.st56.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace56 : PRE_first_tail_x15_r0_body.s547.trace = PRE_first_tail_x15_r0_body.st56.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores56 : PRE_first_tail_x15_r0_body.s547.stores = PRE_first_tail_x15_r0_body.st56.s2.stores

end Host.Load.Run.Tpl
