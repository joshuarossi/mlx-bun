import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.a4pre_first_tail_x15_r0_body.st159.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 159 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g159__g160` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1540`, the merged state `PRE_first_tail_x15_r0_body.s1541`,
the site template `PRE_first_tail_x15_r0_body.st159` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1542`: the merge.
The footprint's facts are in `SiteF159`, the compaction's in `SiteC159`, `SiteK159`, `SiteNa159`, `SiteNb159`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso159 : PRE_first_tail_x15_r0_body.st159.s0 = { PRE_first_tail_x15_r0_body.s1540 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs159 : List Frame := PRE_first_tail_x15_r0_body.s1540.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_159 : PRE_first_tail_x15_r0_body.S1540.tab.length = 6881
kernel_rfl PRE_first_tail_x15_r0_body.tab0_159 : PRE_first_tail_x15_r0_body.st159.S0.tab = PRE_first_tail_x15_r0_body.S1540.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws159 : List Nat := [3659, 3660, 3661, 3662, 3663, 3664, 3665, 3666, 3667, 3668, 3669, 3670, 3671, 3672, 3673, 3674, 3675, 3676, 3677, 3678, 3679, 3680, 3681, 3682, 3683, 3684, 3685, 3686, 3687, 3688, 3689]
kernel_rfl PRE_first_tail_x15_r0_body.fresh159 : (PRE_first_tail_x15_r0_body.S1540.tab.all fun e => PRE_first_tail_x15_r0_body.ws159.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1540.oracle.all fun q => PRE_first_tail_x15_r0_body.ws159.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab159 : PRE_first_tail_x15_r0_body.S1541.tab = PRE_first_tail_x15_r0_body.S1540.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws159
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen159 : PRE_first_tail_x15_r0_body.st159.S5.tab.length - PRE_first_tail_x15_r0_body.st159.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged159`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap159 : PRE_first_tail_x15_r0_body.s1541.heap = PRE_first_tail_x15_r0_body.st159.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext159 : PRE_first_tail_x15_r0_body.s1541.next = PRE_first_tail_x15_r0_body.st159.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl159 : PRE_first_tail_x15_r0_body.s1541.ctl = PRE_first_tail_x15_r0_body.st159.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack159 : PRE_first_tail_x15_r0_body.s1541.stack = PRE_first_tail_x15_r0_body.st159.s5.stack ++ PRE_first_tail_x15_r0_body.s1540.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs159 : PRE_first_tail_x15_r0_body.s1541.jobs = PRE_first_tail_x15_r0_body.st159.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi159 : PRE_first_tail_x15_r0_body.s1541.ffi = PRE_first_tail_x15_r0_body.st159.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace159 : PRE_first_tail_x15_r0_body.s1541.trace = PRE_first_tail_x15_r0_body.st159.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores159 : PRE_first_tail_x15_r0_body.s1541.stores = PRE_first_tail_x15_r0_body.st159.s5.stores

end Host.Load.Run.Tpl
