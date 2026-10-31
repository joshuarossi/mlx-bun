import host.sim.template.a4pre_first_tail_x15_r0_body.H26
import host.sim.template.a4pre_first_tail_x15_r0_body.st95.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 95 of chain `PRE_first_tail_x15_r0_body`: `plan__g95__g96` (`plan`), the call state `PRE_first_tail_x15_r0_body.s838`, the merged state `PRE_first_tail_x15_r0_body.s839`,
the site template `PRE_first_tail_x15_r0_body.st95` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s840`: the merge.
The footprint's facts are in `SiteF95`, the compaction's in `SiteC95`, `SiteK95`, `SiteNa95`, `SiteNb95`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso95 : PRE_first_tail_x15_r0_body.st95.s0 = { PRE_first_tail_x15_r0_body.s838 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs95 : List Frame := PRE_first_tail_x15_r0_body.s838.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_95 : PRE_first_tail_x15_r0_body.S838.tab.length = 4114
kernel_rfl PRE_first_tail_x15_r0_body.tab0_95 : PRE_first_tail_x15_r0_body.st95.S0.tab = PRE_first_tail_x15_r0_body.S838.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws95 : List Nat := [2589, 2590, 2591, 2592, 2593, 2594, 2595, 2596, 2597]
kernel_rfl PRE_first_tail_x15_r0_body.fresh95 : (PRE_first_tail_x15_r0_body.S838.tab.all fun e => PRE_first_tail_x15_r0_body.ws95.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S838.oracle.all fun q => PRE_first_tail_x15_r0_body.ws95.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab95 : PRE_first_tail_x15_r0_body.S839.tab = PRE_first_tail_x15_r0_body.S838.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws95
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen95 : PRE_first_tail_x15_r0_body.st95.S2.tab.length - PRE_first_tail_x15_r0_body.st95.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged95`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap95 : PRE_first_tail_x15_r0_body.s839.heap = PRE_first_tail_x15_r0_body.st95.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext95 : PRE_first_tail_x15_r0_body.s839.next = PRE_first_tail_x15_r0_body.st95.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl95 : PRE_first_tail_x15_r0_body.s839.ctl = PRE_first_tail_x15_r0_body.st95.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack95 : PRE_first_tail_x15_r0_body.s839.stack = PRE_first_tail_x15_r0_body.st95.s2.stack ++ PRE_first_tail_x15_r0_body.s838.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs95 : PRE_first_tail_x15_r0_body.s839.jobs = PRE_first_tail_x15_r0_body.st95.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi95 : PRE_first_tail_x15_r0_body.s839.ffi = PRE_first_tail_x15_r0_body.st95.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace95 : PRE_first_tail_x15_r0_body.s839.trace = PRE_first_tail_x15_r0_body.st95.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores95 : PRE_first_tail_x15_r0_body.s839.stores = PRE_first_tail_x15_r0_body.st95.s2.stores

end Host.Load.Run.Tpl
