import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.st163.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 163 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g163__g164` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1577`, the merged state `PRE_first_tail_x15_r0_body.s1578`,
the site template `PRE_first_tail_x15_r0_body.st163` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1579`: the merge.
The footprint's facts are in `SiteF163`, the compaction's in `SiteC163`, `SiteK163`, `SiteNa163`, `SiteNb163`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso163 : PRE_first_tail_x15_r0_body.st163.s0 = { PRE_first_tail_x15_r0_body.s1577 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs163 : List Frame := PRE_first_tail_x15_r0_body.s1577.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_163 : PRE_first_tail_x15_r0_body.S1577.tab.length = 7049
kernel_rfl PRE_first_tail_x15_r0_body.tab0_163 : PRE_first_tail_x15_r0_body.st163.S0.tab = PRE_first_tail_x15_r0_body.S1577.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws163 : List Nat := [3762, 3763]
kernel_rfl PRE_first_tail_x15_r0_body.fresh163 : (PRE_first_tail_x15_r0_body.S1577.tab.all fun e => PRE_first_tail_x15_r0_body.ws163.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1577.oracle.all fun q => PRE_first_tail_x15_r0_body.ws163.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab163 : PRE_first_tail_x15_r0_body.S1578.tab = PRE_first_tail_x15_r0_body.S1577.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws163
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen163 : PRE_first_tail_x15_r0_body.st163.S2.tab.length - PRE_first_tail_x15_r0_body.st163.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged163`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap163 : PRE_first_tail_x15_r0_body.s1578.heap = PRE_first_tail_x15_r0_body.st163.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext163 : PRE_first_tail_x15_r0_body.s1578.next = PRE_first_tail_x15_r0_body.st163.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl163 : PRE_first_tail_x15_r0_body.s1578.ctl = PRE_first_tail_x15_r0_body.st163.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack163 : PRE_first_tail_x15_r0_body.s1578.stack = PRE_first_tail_x15_r0_body.st163.s2.stack ++ PRE_first_tail_x15_r0_body.s1577.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs163 : PRE_first_tail_x15_r0_body.s1578.jobs = PRE_first_tail_x15_r0_body.st163.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi163 : PRE_first_tail_x15_r0_body.s1578.ffi = PRE_first_tail_x15_r0_body.st163.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace163 : PRE_first_tail_x15_r0_body.s1578.trace = PRE_first_tail_x15_r0_body.st163.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores163 : PRE_first_tail_x15_r0_body.s1578.stores = PRE_first_tail_x15_r0_body.st163.s2.stores

end Host.Load.Run.Tpl
