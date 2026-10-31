import host.sim.template.a4pre_first_tail_x15_r0_body.H4
import host.sim.template.a4pre_first_tail_x15_r0_body.st17.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 17 of chain `PRE_first_tail_x15_r0_body`: `plan__g17__g18` (`plan`), the call state `PRE_first_tail_x15_r0_body.s157`, the merged state `PRE_first_tail_x15_r0_body.s158`,
the site template `PRE_first_tail_x15_r0_body.st17` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s159`: the merge.
The footprint's facts are in `SiteF17`, the compaction's in `SiteC17`, `SiteK17`, `SiteNa17`, `SiteNb17`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso17 : PRE_first_tail_x15_r0_body.st17.s0 = { PRE_first_tail_x15_r0_body.s157 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs17 : List Frame := PRE_first_tail_x15_r0_body.s157.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_17 : PRE_first_tail_x15_r0_body.S157.tab.length = 781
kernel_rfl PRE_first_tail_x15_r0_body.tab0_17 : PRE_first_tail_x15_r0_body.st17.S0.tab = PRE_first_tail_x15_r0_body.S157.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws17 : List Nat := [1304, 1305, 1306]
kernel_rfl PRE_first_tail_x15_r0_body.fresh17 : (PRE_first_tail_x15_r0_body.S157.tab.all fun e => PRE_first_tail_x15_r0_body.ws17.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S157.oracle.all fun q => PRE_first_tail_x15_r0_body.ws17.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab17 : PRE_first_tail_x15_r0_body.S158.tab = PRE_first_tail_x15_r0_body.S157.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws17
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen17 : PRE_first_tail_x15_r0_body.st17.S2.tab.length - PRE_first_tail_x15_r0_body.st17.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged17`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap17 : PRE_first_tail_x15_r0_body.s158.heap = PRE_first_tail_x15_r0_body.st17.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext17 : PRE_first_tail_x15_r0_body.s158.next = PRE_first_tail_x15_r0_body.st17.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl17 : PRE_first_tail_x15_r0_body.s158.ctl = PRE_first_tail_x15_r0_body.st17.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack17 : PRE_first_tail_x15_r0_body.s158.stack = PRE_first_tail_x15_r0_body.st17.s2.stack ++ PRE_first_tail_x15_r0_body.s157.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs17 : PRE_first_tail_x15_r0_body.s158.jobs = PRE_first_tail_x15_r0_body.st17.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi17 : PRE_first_tail_x15_r0_body.s158.ffi = PRE_first_tail_x15_r0_body.st17.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace17 : PRE_first_tail_x15_r0_body.s158.trace = PRE_first_tail_x15_r0_body.st17.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores17 : PRE_first_tail_x15_r0_body.s158.stores = PRE_first_tail_x15_r0_body.st17.s2.stores

end Host.Load.Run.Tpl
