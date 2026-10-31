import host.sim.template.a4pre_first_tail_x15_r0_body.H50
import host.sim.template.a4pre_first_tail_x15_r0_body.st168.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 168 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g168__g169` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1626`, the merged state `PRE_first_tail_x15_r0_body.s1627`,
the site template `PRE_first_tail_x15_r0_body.st168` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1628`: the merge.
The footprint's facts are in `SiteF168`, the compaction's in `SiteC168`, `SiteK168`, `SiteNa168`, `SiteNb168`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso168 : PRE_first_tail_x15_r0_body.st168.s0 = { PRE_first_tail_x15_r0_body.s1626 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs168 : List Frame := PRE_first_tail_x15_r0_body.s1626.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_168 : PRE_first_tail_x15_r0_body.S1626.tab.length = 7265
kernel_rfl PRE_first_tail_x15_r0_body.tab0_168 : PRE_first_tail_x15_r0_body.st168.S0.tab = PRE_first_tail_x15_r0_body.S1626.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws168 : List Nat := [3810, 3811, 3812, 3813, 3814, 3815, 3816, 3817, 3818, 3819, 3820, 3821, 3822, 3823, 3824, 3825, 3826, 3827, 3828, 3829, 3830, 3831, 3832, 3833, 3834, 3835, 3836, 3837, 3838, 3839, 3840]
kernel_rfl PRE_first_tail_x15_r0_body.fresh168 : (PRE_first_tail_x15_r0_body.S1626.tab.all fun e => PRE_first_tail_x15_r0_body.ws168.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1626.oracle.all fun q => PRE_first_tail_x15_r0_body.ws168.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab168 : PRE_first_tail_x15_r0_body.S1627.tab = PRE_first_tail_x15_r0_body.S1626.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws168
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen168 : PRE_first_tail_x15_r0_body.st168.S5.tab.length - PRE_first_tail_x15_r0_body.st168.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged168`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap168 : PRE_first_tail_x15_r0_body.s1627.heap = PRE_first_tail_x15_r0_body.st168.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext168 : PRE_first_tail_x15_r0_body.s1627.next = PRE_first_tail_x15_r0_body.st168.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl168 : PRE_first_tail_x15_r0_body.s1627.ctl = PRE_first_tail_x15_r0_body.st168.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack168 : PRE_first_tail_x15_r0_body.s1627.stack = PRE_first_tail_x15_r0_body.st168.s5.stack ++ PRE_first_tail_x15_r0_body.s1626.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs168 : PRE_first_tail_x15_r0_body.s1627.jobs = PRE_first_tail_x15_r0_body.st168.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi168 : PRE_first_tail_x15_r0_body.s1627.ffi = PRE_first_tail_x15_r0_body.st168.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace168 : PRE_first_tail_x15_r0_body.s1627.trace = PRE_first_tail_x15_r0_body.st168.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores168 : PRE_first_tail_x15_r0_body.s1627.stores = PRE_first_tail_x15_r0_body.st168.s5.stores

end Host.Load.Run.Tpl
