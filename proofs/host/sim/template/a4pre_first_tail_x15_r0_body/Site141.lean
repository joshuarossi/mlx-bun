import host.sim.template.a4pre_first_tail_x15_r0_body.H39
import host.sim.template.a4pre_first_tail_x15_r0_body.st141.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 141 of chain `PRE_first_tail_x15_r0_body`: `kvW__g141__g142` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1247`, the merged state `PRE_first_tail_x15_r0_body.s1248`,
the site template `PRE_first_tail_x15_r0_body.st141` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1249`: the merge.
The footprint's facts are in `SiteF141`, the compaction's in `SiteC141`, `SiteK141`, `SiteNa141`, `SiteNb141`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso141 : PRE_first_tail_x15_r0_body.st141.s0 = { PRE_first_tail_x15_r0_body.s1247 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs141 : List Frame := PRE_first_tail_x15_r0_body.s1247.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_141 : PRE_first_tail_x15_r0_body.S1247.tab.length = 6117
kernel_rfl PRE_first_tail_x15_r0_body.tab0_141 : PRE_first_tail_x15_r0_body.st141.S0.tab = PRE_first_tail_x15_r0_body.S1247.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws141 : List Nat := [3363, 3364, 3365, 3366, 3367, 3368, 3369, 3370, 3371, 3372, 3373, 3374, 3375, 3376, 3377, 3378, 3379]
kernel_rfl PRE_first_tail_x15_r0_body.fresh141 : (PRE_first_tail_x15_r0_body.S1247.tab.all fun e => PRE_first_tail_x15_r0_body.ws141.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1247.oracle.all fun q => PRE_first_tail_x15_r0_body.ws141.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab141 : PRE_first_tail_x15_r0_body.S1248.tab = PRE_first_tail_x15_r0_body.S1247.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws141
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen141 : PRE_first_tail_x15_r0_body.st141.S2.tab.length - PRE_first_tail_x15_r0_body.st141.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged141`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap141 : PRE_first_tail_x15_r0_body.s1248.heap = PRE_first_tail_x15_r0_body.st141.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext141 : PRE_first_tail_x15_r0_body.s1248.next = PRE_first_tail_x15_r0_body.st141.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl141 : PRE_first_tail_x15_r0_body.s1248.ctl = PRE_first_tail_x15_r0_body.st141.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack141 : PRE_first_tail_x15_r0_body.s1248.stack = PRE_first_tail_x15_r0_body.st141.s2.stack ++ PRE_first_tail_x15_r0_body.s1247.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs141 : PRE_first_tail_x15_r0_body.s1248.jobs = PRE_first_tail_x15_r0_body.st141.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi141 : PRE_first_tail_x15_r0_body.s1248.ffi = PRE_first_tail_x15_r0_body.st141.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace141 : PRE_first_tail_x15_r0_body.s1248.trace = PRE_first_tail_x15_r0_body.st141.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores141 : PRE_first_tail_x15_r0_body.s1248.stores = PRE_first_tail_x15_r0_body.st141.s2.stores

end Host.Load.Run.Tpl
