import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.a4pre_first_tail_x15_r0_body.st42.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 42 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g42__g43` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s419`, the merged state `PRE_first_tail_x15_r0_body.s420`,
the site template `PRE_first_tail_x15_r0_body.st42` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s421`: the merge.
The footprint's facts are in `SiteF42`, the compaction's in `SiteC42`, `SiteK42`, `SiteNa42`, `SiteNb42`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso42 : PRE_first_tail_x15_r0_body.st42.s0 = { PRE_first_tail_x15_r0_body.s419 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs42 : List Frame := PRE_first_tail_x15_r0_body.s419.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_42 : PRE_first_tail_x15_r0_body.S419.tab.length = 1880
kernel_rfl PRE_first_tail_x15_r0_body.tab0_42 : PRE_first_tail_x15_r0_body.st42.S0.tab = PRE_first_tail_x15_r0_body.S419.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws42 : List Nat := [1705, 1706, 1707, 1708, 1709, 1710, 1711, 1712, 1713, 1714, 1715, 1716, 1717, 1718, 1719, 1720, 1721, 1722, 1723, 1724, 1725, 1726, 1727, 1728, 1729, 1730, 1731, 1732, 1733, 1734, 1735]
kernel_rfl PRE_first_tail_x15_r0_body.fresh42 : (PRE_first_tail_x15_r0_body.S419.tab.all fun e => PRE_first_tail_x15_r0_body.ws42.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S419.oracle.all fun q => PRE_first_tail_x15_r0_body.ws42.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab42 : PRE_first_tail_x15_r0_body.S420.tab = PRE_first_tail_x15_r0_body.S419.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws42
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen42 : PRE_first_tail_x15_r0_body.st42.S5.tab.length - PRE_first_tail_x15_r0_body.st42.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged42`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap42 : PRE_first_tail_x15_r0_body.s420.heap = PRE_first_tail_x15_r0_body.st42.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext42 : PRE_first_tail_x15_r0_body.s420.next = PRE_first_tail_x15_r0_body.st42.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl42 : PRE_first_tail_x15_r0_body.s420.ctl = PRE_first_tail_x15_r0_body.st42.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack42 : PRE_first_tail_x15_r0_body.s420.stack = PRE_first_tail_x15_r0_body.st42.s5.stack ++ PRE_first_tail_x15_r0_body.s419.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs42 : PRE_first_tail_x15_r0_body.s420.jobs = PRE_first_tail_x15_r0_body.st42.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi42 : PRE_first_tail_x15_r0_body.s420.ffi = PRE_first_tail_x15_r0_body.st42.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace42 : PRE_first_tail_x15_r0_body.s420.trace = PRE_first_tail_x15_r0_body.st42.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores42 : PRE_first_tail_x15_r0_body.s420.stores = PRE_first_tail_x15_r0_body.st42.s5.stores

end Host.Load.Run.Tpl
