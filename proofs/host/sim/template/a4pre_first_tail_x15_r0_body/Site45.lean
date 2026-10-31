import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.a4pre_first_tail_x15_r0_body.st45.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 45 of chain `PRE_first_tail_x15_r0_body`: `kvW__g45__g46` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s407`, the merged state `PRE_first_tail_x15_r0_body.s408`,
the site template `PRE_first_tail_x15_r0_body.st45` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s409`: the merge.
The footprint's facts are in `SiteF45`, the compaction's in `SiteC45`, `SiteK45`, `SiteNa45`, `SiteNb45`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso45 : PRE_first_tail_x15_r0_body.st45.s0 = { PRE_first_tail_x15_r0_body.s407 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs45 : List Frame := PRE_first_tail_x15_r0_body.s407.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_45 : PRE_first_tail_x15_r0_body.S407.tab.length = 2013
kernel_rfl PRE_first_tail_x15_r0_body.tab0_45 : PRE_first_tail_x15_r0_body.st45.S0.tab = PRE_first_tail_x15_r0_body.S407.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws45 : List Nat := [1759, 1760, 1761, 1762, 1763, 1764, 1765, 1766, 1767, 1768, 1769, 1770, 1771, 1772, 1773, 1774, 1775]
kernel_rfl PRE_first_tail_x15_r0_body.fresh45 : (PRE_first_tail_x15_r0_body.S407.tab.all fun e => PRE_first_tail_x15_r0_body.ws45.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S407.oracle.all fun q => PRE_first_tail_x15_r0_body.ws45.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab45 : PRE_first_tail_x15_r0_body.S408.tab = PRE_first_tail_x15_r0_body.S407.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws45
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen45 : PRE_first_tail_x15_r0_body.st45.S2.tab.length - PRE_first_tail_x15_r0_body.st45.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged45`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap45 : PRE_first_tail_x15_r0_body.s408.heap = PRE_first_tail_x15_r0_body.st45.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext45 : PRE_first_tail_x15_r0_body.s408.next = PRE_first_tail_x15_r0_body.st45.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl45 : PRE_first_tail_x15_r0_body.s408.ctl = PRE_first_tail_x15_r0_body.st45.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack45 : PRE_first_tail_x15_r0_body.s408.stack = PRE_first_tail_x15_r0_body.st45.s2.stack ++ PRE_first_tail_x15_r0_body.s407.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs45 : PRE_first_tail_x15_r0_body.s408.jobs = PRE_first_tail_x15_r0_body.st45.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi45 : PRE_first_tail_x15_r0_body.s408.ffi = PRE_first_tail_x15_r0_body.st45.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace45 : PRE_first_tail_x15_r0_body.s408.trace = PRE_first_tail_x15_r0_body.st45.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores45 : PRE_first_tail_x15_r0_body.s408.stores = PRE_first_tail_x15_r0_body.st45.s2.stores

end Host.Load.Run.Tpl
