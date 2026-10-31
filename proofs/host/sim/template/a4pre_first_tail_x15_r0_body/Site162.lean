import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.st162.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 162 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g162__g163` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1569`, the merged state `PRE_first_tail_x15_r0_body.s1570`,
the site template `PRE_first_tail_x15_r0_body.st162` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1571`: the merge.
The footprint's facts are in `SiteF162`, the compaction's in `SiteC162`, `SiteK162`, `SiteNa162`, `SiteNb162`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso162 : PRE_first_tail_x15_r0_body.st162.s0 = { PRE_first_tail_x15_r0_body.s1569 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs162 : List Frame := PRE_first_tail_x15_r0_body.s1569.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_162 : PRE_first_tail_x15_r0_body.S1569.tab.length = 7010
kernel_rfl PRE_first_tail_x15_r0_body.tab0_162 : PRE_first_tail_x15_r0_body.st162.S0.tab = PRE_first_tail_x15_r0_body.S1569.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws162 : List Nat := [3713, 3714, 3715, 3716, 3717, 3718, 3719, 3720, 3721, 3722, 3723, 3724, 3725, 3726, 3727, 3728, 3729, 3730, 3731, 3732, 3733, 3734, 3735, 3736, 3737, 3738, 3739, 3740, 3741, 3742, 3743]
kernel_rfl PRE_first_tail_x15_r0_body.fresh162 : (PRE_first_tail_x15_r0_body.S1569.tab.all fun e => PRE_first_tail_x15_r0_body.ws162.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1569.oracle.all fun q => PRE_first_tail_x15_r0_body.ws162.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab162 : PRE_first_tail_x15_r0_body.S1570.tab = PRE_first_tail_x15_r0_body.S1569.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws162
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen162 : PRE_first_tail_x15_r0_body.st162.S5.tab.length - PRE_first_tail_x15_r0_body.st162.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged162`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap162 : PRE_first_tail_x15_r0_body.s1570.heap = PRE_first_tail_x15_r0_body.st162.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext162 : PRE_first_tail_x15_r0_body.s1570.next = PRE_first_tail_x15_r0_body.st162.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl162 : PRE_first_tail_x15_r0_body.s1570.ctl = PRE_first_tail_x15_r0_body.st162.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack162 : PRE_first_tail_x15_r0_body.s1570.stack = PRE_first_tail_x15_r0_body.st162.s5.stack ++ PRE_first_tail_x15_r0_body.s1569.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs162 : PRE_first_tail_x15_r0_body.s1570.jobs = PRE_first_tail_x15_r0_body.st162.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi162 : PRE_first_tail_x15_r0_body.s1570.ffi = PRE_first_tail_x15_r0_body.st162.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace162 : PRE_first_tail_x15_r0_body.s1570.trace = PRE_first_tail_x15_r0_body.st162.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores162 : PRE_first_tail_x15_r0_body.s1570.stores = PRE_first_tail_x15_r0_body.st162.s5.stores

end Host.Load.Run.Tpl
