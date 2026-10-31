import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.a4pre_first_tail_x15_r0_body.st44.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 44 of chain `PRE_first_tail_x15_r0_body`: `plan__g44__g45` (`plan`), the call state `PRE_first_tail_x15_r0_body.s394`, the merged state `PRE_first_tail_x15_r0_body.s395`,
the site template `PRE_first_tail_x15_r0_body.st44` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s396`: the merge.
The footprint's facts are in `SiteF44`, the compaction's in `SiteC44`, `SiteK44`, `SiteNa44`, `SiteNb44`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso44 : PRE_first_tail_x15_r0_body.st44.s0 = { PRE_first_tail_x15_r0_body.s394 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs44 : List Frame := PRE_first_tail_x15_r0_body.s394.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_44 : PRE_first_tail_x15_r0_body.S394.tab.length = 1936
kernel_rfl PRE_first_tail_x15_r0_body.tab0_44 : PRE_first_tail_x15_r0_body.st44.S0.tab = PRE_first_tail_x15_r0_body.S394.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws44 : List Nat := [1756, 1757, 1758]
kernel_rfl PRE_first_tail_x15_r0_body.fresh44 : (PRE_first_tail_x15_r0_body.S394.tab.all fun e => PRE_first_tail_x15_r0_body.ws44.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S394.oracle.all fun q => PRE_first_tail_x15_r0_body.ws44.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab44 : PRE_first_tail_x15_r0_body.S395.tab = PRE_first_tail_x15_r0_body.S394.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws44
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen44 : PRE_first_tail_x15_r0_body.st44.S2.tab.length - PRE_first_tail_x15_r0_body.st44.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged44`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap44 : PRE_first_tail_x15_r0_body.s395.heap = PRE_first_tail_x15_r0_body.st44.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext44 : PRE_first_tail_x15_r0_body.s395.next = PRE_first_tail_x15_r0_body.st44.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl44 : PRE_first_tail_x15_r0_body.s395.ctl = PRE_first_tail_x15_r0_body.st44.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack44 : PRE_first_tail_x15_r0_body.s395.stack = PRE_first_tail_x15_r0_body.st44.s2.stack ++ PRE_first_tail_x15_r0_body.s394.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs44 : PRE_first_tail_x15_r0_body.s395.jobs = PRE_first_tail_x15_r0_body.st44.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi44 : PRE_first_tail_x15_r0_body.s395.ffi = PRE_first_tail_x15_r0_body.st44.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace44 : PRE_first_tail_x15_r0_body.s395.trace = PRE_first_tail_x15_r0_body.st44.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores44 : PRE_first_tail_x15_r0_body.s395.stores = PRE_first_tail_x15_r0_body.st44.s2.stores

end Host.Load.Run.Tpl
