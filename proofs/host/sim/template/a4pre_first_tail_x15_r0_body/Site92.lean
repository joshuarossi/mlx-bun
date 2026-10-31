import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.st92.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 92 of chain `PRE_first_tail_x15_r0_body`: `plan__g92__g93` (`plan`), the call state `PRE_first_tail_x15_r0_body.s891`, the merged state `PRE_first_tail_x15_r0_body.s892`,
the site template `PRE_first_tail_x15_r0_body.st92` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s893`: the merge.
The footprint's facts are in `SiteF92`, the compaction's in `SiteC92`, `SiteK92`, `SiteNa92`, `SiteNb92`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso92 : PRE_first_tail_x15_r0_body.st92.s0 = { PRE_first_tail_x15_r0_body.s891 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs92 : List Frame := PRE_first_tail_x15_r0_body.s891.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_92 : PRE_first_tail_x15_r0_body.S891.tab.length = 3988
kernel_rfl PRE_first_tail_x15_r0_body.tab0_92 : PRE_first_tail_x15_r0_body.st92.S0.tab = PRE_first_tail_x15_r0_body.S891.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws92 : List Nat := [2558, 2559, 2560]
kernel_rfl PRE_first_tail_x15_r0_body.fresh92 : (PRE_first_tail_x15_r0_body.S891.tab.all fun e => PRE_first_tail_x15_r0_body.ws92.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S891.oracle.all fun q => PRE_first_tail_x15_r0_body.ws92.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab92 : PRE_first_tail_x15_r0_body.S892.tab = PRE_first_tail_x15_r0_body.S891.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws92
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen92 : PRE_first_tail_x15_r0_body.st92.S2.tab.length - PRE_first_tail_x15_r0_body.st92.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged92`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap92 : PRE_first_tail_x15_r0_body.s892.heap = PRE_first_tail_x15_r0_body.st92.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext92 : PRE_first_tail_x15_r0_body.s892.next = PRE_first_tail_x15_r0_body.st92.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl92 : PRE_first_tail_x15_r0_body.s892.ctl = PRE_first_tail_x15_r0_body.st92.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack92 : PRE_first_tail_x15_r0_body.s892.stack = PRE_first_tail_x15_r0_body.st92.s2.stack ++ PRE_first_tail_x15_r0_body.s891.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs92 : PRE_first_tail_x15_r0_body.s892.jobs = PRE_first_tail_x15_r0_body.st92.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi92 : PRE_first_tail_x15_r0_body.s892.ffi = PRE_first_tail_x15_r0_body.st92.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace92 : PRE_first_tail_x15_r0_body.s892.trace = PRE_first_tail_x15_r0_body.st92.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores92 : PRE_first_tail_x15_r0_body.s892.stores = PRE_first_tail_x15_r0_body.st92.s2.stores

end Host.Load.Run.Tpl
