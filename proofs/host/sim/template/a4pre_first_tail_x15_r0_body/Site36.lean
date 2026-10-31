import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.a4pre_first_tail_x15_r0_body.st36.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 36 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g36__g37` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s361`, the merged state `PRE_first_tail_x15_r0_body.s362`,
the site template `PRE_first_tail_x15_r0_body.st36` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s363`: the merge.
The footprint's facts are in `SiteF36`, the compaction's in `SiteC36`, `SiteK36`, `SiteNa36`, `SiteNb36`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso36 : PRE_first_tail_x15_r0_body.st36.s0 = { PRE_first_tail_x15_r0_body.s361 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs36 : List Frame := PRE_first_tail_x15_r0_body.s361.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_36 : PRE_first_tail_x15_r0_body.S361.tab.length = 1622
kernel_rfl PRE_first_tail_x15_r0_body.tab0_36 : PRE_first_tail_x15_r0_body.st36.S0.tab = PRE_first_tail_x15_r0_body.S361.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws36 : List Nat := [1591, 1592, 1593, 1594, 1595, 1596, 1597, 1598, 1599, 1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613, 1614, 1615, 1616, 1617, 1618, 1619, 1620, 1621]
kernel_rfl PRE_first_tail_x15_r0_body.fresh36 : (PRE_first_tail_x15_r0_body.S361.tab.all fun e => PRE_first_tail_x15_r0_body.ws36.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S361.oracle.all fun q => PRE_first_tail_x15_r0_body.ws36.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab36 : PRE_first_tail_x15_r0_body.S362.tab = PRE_first_tail_x15_r0_body.S361.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws36
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen36 : PRE_first_tail_x15_r0_body.st36.S5.tab.length - PRE_first_tail_x15_r0_body.st36.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged36`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap36 : PRE_first_tail_x15_r0_body.s362.heap = PRE_first_tail_x15_r0_body.st36.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext36 : PRE_first_tail_x15_r0_body.s362.next = PRE_first_tail_x15_r0_body.st36.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl36 : PRE_first_tail_x15_r0_body.s362.ctl = PRE_first_tail_x15_r0_body.st36.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack36 : PRE_first_tail_x15_r0_body.s362.stack = PRE_first_tail_x15_r0_body.st36.s5.stack ++ PRE_first_tail_x15_r0_body.s361.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs36 : PRE_first_tail_x15_r0_body.s362.jobs = PRE_first_tail_x15_r0_body.st36.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi36 : PRE_first_tail_x15_r0_body.s362.ffi = PRE_first_tail_x15_r0_body.st36.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace36 : PRE_first_tail_x15_r0_body.s362.trace = PRE_first_tail_x15_r0_body.st36.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores36 : PRE_first_tail_x15_r0_body.s362.stores = PRE_first_tail_x15_r0_body.st36.s5.stores

end Host.Load.Run.Tpl
