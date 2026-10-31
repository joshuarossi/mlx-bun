import host.sim.template.a4pre_first_tail_x15_r0_body.H45
import host.sim.template.a4pre_first_tail_x15_r0_body.st150.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 150 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g150__g151` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1454`, the merged state `PRE_first_tail_x15_r0_body.s1455`,
the site template `PRE_first_tail_x15_r0_body.st150` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1456`: the merge.
The footprint's facts are in `SiteF150`, the compaction's in `SiteC150`, `SiteK150`, `SiteNa150`, `SiteNb150`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso150 : PRE_first_tail_x15_r0_body.st150.s0 = { PRE_first_tail_x15_r0_body.s1454 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs150 : List Frame := PRE_first_tail_x15_r0_body.s1454.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_150 : PRE_first_tail_x15_r0_body.S1454.tab.length = 6497
kernel_rfl PRE_first_tail_x15_r0_body.tab0_150 : PRE_first_tail_x15_r0_body.st150.S0.tab = PRE_first_tail_x15_r0_body.S1454.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws150 : List Nat := [3520, 3521, 3522, 3523, 3524, 3525, 3526, 3527, 3528, 3529, 3530, 3531, 3532, 3533, 3534, 3535, 3536, 3537, 3538, 3539, 3540, 3541, 3542, 3543, 3544, 3545, 3546, 3547, 3548, 3549, 3550]
kernel_rfl PRE_first_tail_x15_r0_body.fresh150 : (PRE_first_tail_x15_r0_body.S1454.tab.all fun e => PRE_first_tail_x15_r0_body.ws150.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1454.oracle.all fun q => PRE_first_tail_x15_r0_body.ws150.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab150 : PRE_first_tail_x15_r0_body.S1455.tab = PRE_first_tail_x15_r0_body.S1454.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws150
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen150 : PRE_first_tail_x15_r0_body.st150.S5.tab.length - PRE_first_tail_x15_r0_body.st150.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged150`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap150 : PRE_first_tail_x15_r0_body.s1455.heap = PRE_first_tail_x15_r0_body.st150.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext150 : PRE_first_tail_x15_r0_body.s1455.next = PRE_first_tail_x15_r0_body.st150.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl150 : PRE_first_tail_x15_r0_body.s1455.ctl = PRE_first_tail_x15_r0_body.st150.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack150 : PRE_first_tail_x15_r0_body.s1455.stack = PRE_first_tail_x15_r0_body.st150.s5.stack ++ PRE_first_tail_x15_r0_body.s1454.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs150 : PRE_first_tail_x15_r0_body.s1455.jobs = PRE_first_tail_x15_r0_body.st150.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi150 : PRE_first_tail_x15_r0_body.s1455.ffi = PRE_first_tail_x15_r0_body.st150.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace150 : PRE_first_tail_x15_r0_body.s1455.trace = PRE_first_tail_x15_r0_body.st150.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores150 : PRE_first_tail_x15_r0_body.s1455.stores = PRE_first_tail_x15_r0_body.st150.s5.stores

end Host.Load.Run.Tpl
