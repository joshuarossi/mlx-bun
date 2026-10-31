import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.a4pre_first_tail_x15_r0_body.st39.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 39 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g39__g40` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s356`, the merged state `PRE_first_tail_x15_r0_body.s357`,
the site template `PRE_first_tail_x15_r0_body.st39` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s358`: the merge.
The footprint's facts are in `SiteF39`, the compaction's in `SiteC39`, `SiteK39`, `SiteNa39`, `SiteNb39`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso39 : PRE_first_tail_x15_r0_body.st39.s0 = { PRE_first_tail_x15_r0_body.s356 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs39 : List Frame := PRE_first_tail_x15_r0_body.s356.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_39 : PRE_first_tail_x15_r0_body.S356.tab.length = 1751
kernel_rfl PRE_first_tail_x15_r0_body.tab0_39 : PRE_first_tail_x15_r0_body.st39.S0.tab = PRE_first_tail_x15_r0_body.S356.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws39 : List Nat := [1645, 1646, 1647, 1648, 1649, 1650, 1651, 1652, 1653, 1654, 1655, 1656, 1657, 1658, 1659, 1660, 1661, 1662, 1663, 1664, 1665, 1666, 1667, 1668, 1669, 1670, 1671, 1672, 1673, 1674, 1675]
kernel_rfl PRE_first_tail_x15_r0_body.fresh39 : (PRE_first_tail_x15_r0_body.S356.tab.all fun e => PRE_first_tail_x15_r0_body.ws39.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S356.oracle.all fun q => PRE_first_tail_x15_r0_body.ws39.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab39 : PRE_first_tail_x15_r0_body.S357.tab = PRE_first_tail_x15_r0_body.S356.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws39
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen39 : PRE_first_tail_x15_r0_body.st39.S3.tab.length - PRE_first_tail_x15_r0_body.st39.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged39`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap39 : PRE_first_tail_x15_r0_body.s357.heap = PRE_first_tail_x15_r0_body.st39.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext39 : PRE_first_tail_x15_r0_body.s357.next = PRE_first_tail_x15_r0_body.st39.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl39 : PRE_first_tail_x15_r0_body.s357.ctl = PRE_first_tail_x15_r0_body.st39.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack39 : PRE_first_tail_x15_r0_body.s357.stack = PRE_first_tail_x15_r0_body.st39.s3.stack ++ PRE_first_tail_x15_r0_body.s356.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs39 : PRE_first_tail_x15_r0_body.s357.jobs = PRE_first_tail_x15_r0_body.st39.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi39 : PRE_first_tail_x15_r0_body.s357.ffi = PRE_first_tail_x15_r0_body.st39.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace39 : PRE_first_tail_x15_r0_body.s357.trace = PRE_first_tail_x15_r0_body.st39.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores39 : PRE_first_tail_x15_r0_body.s357.stores = PRE_first_tail_x15_r0_body.st39.s3.stores

end Host.Load.Run.Tpl
