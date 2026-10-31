import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.st33.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 33 of chain `PRE_first_tail_x15_r0_body`: `kvW__g33__g34` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s302`, the merged state `PRE_first_tail_x15_r0_body.s303`,
the site template `PRE_first_tail_x15_r0_body.st33` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s304`: the merge.
The footprint's facts are in `SiteF33`, the compaction's in `SiteC33`, `SiteK33`, `SiteNa33`, `SiteNb33`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso33 : PRE_first_tail_x15_r0_body.st33.s0 = { PRE_first_tail_x15_r0_body.s302 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs33 : List Frame := PRE_first_tail_x15_r0_body.s302.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_33 : PRE_first_tail_x15_r0_body.S302.tab.length = 1500
kernel_rfl PRE_first_tail_x15_r0_body.tab0_33 : PRE_first_tail_x15_r0_body.st33.S0.tab = PRE_first_tail_x15_r0_body.S302.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws33 : List Nat := [1554, 1555, 1556, 1557, 1558, 1559, 1560, 1561, 1562, 1563, 1564, 1565, 1566, 1567, 1568, 1569, 1570]
kernel_rfl PRE_first_tail_x15_r0_body.fresh33 : (PRE_first_tail_x15_r0_body.S302.tab.all fun e => PRE_first_tail_x15_r0_body.ws33.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S302.oracle.all fun q => PRE_first_tail_x15_r0_body.ws33.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab33 : PRE_first_tail_x15_r0_body.S303.tab = PRE_first_tail_x15_r0_body.S302.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws33
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen33 : PRE_first_tail_x15_r0_body.st33.S2.tab.length - PRE_first_tail_x15_r0_body.st33.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged33`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap33 : PRE_first_tail_x15_r0_body.s303.heap = PRE_first_tail_x15_r0_body.st33.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext33 : PRE_first_tail_x15_r0_body.s303.next = PRE_first_tail_x15_r0_body.st33.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl33 : PRE_first_tail_x15_r0_body.s303.ctl = PRE_first_tail_x15_r0_body.st33.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack33 : PRE_first_tail_x15_r0_body.s303.stack = PRE_first_tail_x15_r0_body.st33.s2.stack ++ PRE_first_tail_x15_r0_body.s302.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs33 : PRE_first_tail_x15_r0_body.s303.jobs = PRE_first_tail_x15_r0_body.st33.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi33 : PRE_first_tail_x15_r0_body.s303.ffi = PRE_first_tail_x15_r0_body.st33.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace33 : PRE_first_tail_x15_r0_body.s303.trace = PRE_first_tail_x15_r0_body.st33.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores33 : PRE_first_tail_x15_r0_body.s303.stores = PRE_first_tail_x15_r0_body.st33.s2.stores

end Host.Load.Run.Tpl
