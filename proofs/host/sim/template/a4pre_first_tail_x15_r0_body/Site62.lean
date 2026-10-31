import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.st62.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 62 of chain `PRE_first_tail_x15_r0_body`: `plan__g62__g63` (`plan`), the call state `PRE_first_tail_x15_r0_body.s550`, the merged state `PRE_first_tail_x15_r0_body.s551`,
the site template `PRE_first_tail_x15_r0_body.st62` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s552`: the merge.
The footprint's facts are in `SiteF62`, the compaction's in `SiteC62`, `SiteK62`, `SiteNa62`, `SiteNb62`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso62 : PRE_first_tail_x15_r0_body.st62.s0 = { PRE_first_tail_x15_r0_body.s550 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs62 : List Frame := PRE_first_tail_x15_r0_body.s550.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_62 : PRE_first_tail_x15_r0_body.S550.tab.length = 2704
kernel_rfl PRE_first_tail_x15_r0_body.tab0_62 : PRE_first_tail_x15_r0_body.st62.S0.tab = PRE_first_tail_x15_r0_body.S550.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws62 : List Nat := [2058, 2059, 2060]
kernel_rfl PRE_first_tail_x15_r0_body.fresh62 : (PRE_first_tail_x15_r0_body.S550.tab.all fun e => PRE_first_tail_x15_r0_body.ws62.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S550.oracle.all fun q => PRE_first_tail_x15_r0_body.ws62.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab62 : PRE_first_tail_x15_r0_body.S551.tab = PRE_first_tail_x15_r0_body.S550.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws62
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen62 : PRE_first_tail_x15_r0_body.st62.S2.tab.length - PRE_first_tail_x15_r0_body.st62.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged62`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap62 : PRE_first_tail_x15_r0_body.s551.heap = PRE_first_tail_x15_r0_body.st62.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext62 : PRE_first_tail_x15_r0_body.s551.next = PRE_first_tail_x15_r0_body.st62.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl62 : PRE_first_tail_x15_r0_body.s551.ctl = PRE_first_tail_x15_r0_body.st62.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack62 : PRE_first_tail_x15_r0_body.s551.stack = PRE_first_tail_x15_r0_body.st62.s2.stack ++ PRE_first_tail_x15_r0_body.s550.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs62 : PRE_first_tail_x15_r0_body.s551.jobs = PRE_first_tail_x15_r0_body.st62.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi62 : PRE_first_tail_x15_r0_body.s551.ffi = PRE_first_tail_x15_r0_body.st62.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace62 : PRE_first_tail_x15_r0_body.s551.trace = PRE_first_tail_x15_r0_body.st62.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores62 : PRE_first_tail_x15_r0_body.s551.stores = PRE_first_tail_x15_r0_body.st62.s2.stores

end Host.Load.Run.Tpl
