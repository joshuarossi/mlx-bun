import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.a4pre_first_tail_x15_r0_body.st22.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 22 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g22__g23` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s225`, the merged state `PRE_first_tail_x15_r0_body.s226`,
the site template `PRE_first_tail_x15_r0_body.st22` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s227`: the merge.
The footprint's facts are in `SiteF22`, the compaction's in `SiteC22`, `SiteK22`, `SiteNa22`, `SiteNb22`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso22 : PRE_first_tail_x15_r0_body.st22.s0 = { PRE_first_tail_x15_r0_body.s225 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs22 : List Frame := PRE_first_tail_x15_r0_body.s225.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_22 : PRE_first_tail_x15_r0_body.S225.tab.length = 1019
kernel_rfl PRE_first_tail_x15_r0_body.tab0_22 : PRE_first_tail_x15_r0_body.st22.S0.tab = PRE_first_tail_x15_r0_body.S225.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws22 : List Nat := [1387, 1388]
kernel_rfl PRE_first_tail_x15_r0_body.fresh22 : (PRE_first_tail_x15_r0_body.S225.tab.all fun e => PRE_first_tail_x15_r0_body.ws22.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S225.oracle.all fun q => PRE_first_tail_x15_r0_body.ws22.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab22 : PRE_first_tail_x15_r0_body.S226.tab = PRE_first_tail_x15_r0_body.S225.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws22
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen22 : PRE_first_tail_x15_r0_body.st22.S2.tab.length - PRE_first_tail_x15_r0_body.st22.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged22`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap22 : PRE_first_tail_x15_r0_body.s226.heap = PRE_first_tail_x15_r0_body.st22.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext22 : PRE_first_tail_x15_r0_body.s226.next = PRE_first_tail_x15_r0_body.st22.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl22 : PRE_first_tail_x15_r0_body.s226.ctl = PRE_first_tail_x15_r0_body.st22.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack22 : PRE_first_tail_x15_r0_body.s226.stack = PRE_first_tail_x15_r0_body.st22.s2.stack ++ PRE_first_tail_x15_r0_body.s225.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs22 : PRE_first_tail_x15_r0_body.s226.jobs = PRE_first_tail_x15_r0_body.st22.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi22 : PRE_first_tail_x15_r0_body.s226.ffi = PRE_first_tail_x15_r0_body.st22.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace22 : PRE_first_tail_x15_r0_body.s226.trace = PRE_first_tail_x15_r0_body.st22.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores22 : PRE_first_tail_x15_r0_body.s226.stores = PRE_first_tail_x15_r0_body.st22.s2.stores

end Host.Load.Run.Tpl
