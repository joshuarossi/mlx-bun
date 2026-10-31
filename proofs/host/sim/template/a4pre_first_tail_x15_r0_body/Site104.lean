import host.sim.template.a4pre_first_tail_x15_r0_body.H28
import host.sim.template.a4pre_first_tail_x15_r0_body.st104.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 104 of chain `PRE_first_tail_x15_r0_body`: `plan__g104__g105` (`plan`), the call state `PRE_first_tail_x15_r0_body.s919`, the merged state `PRE_first_tail_x15_r0_body.s920`,
the site template `PRE_first_tail_x15_r0_body.st104` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s921`: the merge.
The footprint's facts are in `SiteF104`, the compaction's in `SiteC104`, `SiteK104`, `SiteNa104`, `SiteNb104`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso104 : PRE_first_tail_x15_r0_body.st104.s0 = { PRE_first_tail_x15_r0_body.s919 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs104 : List Frame := PRE_first_tail_x15_r0_body.s919.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_104 : PRE_first_tail_x15_r0_body.S919.tab.length = 4501
kernel_rfl PRE_first_tail_x15_r0_body.tab0_104 : PRE_first_tail_x15_r0_body.st104.S0.tab = PRE_first_tail_x15_r0_body.S919.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws104 : List Nat := [2769, 2770, 2771]
kernel_rfl PRE_first_tail_x15_r0_body.fresh104 : (PRE_first_tail_x15_r0_body.S919.tab.all fun e => PRE_first_tail_x15_r0_body.ws104.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S919.oracle.all fun q => PRE_first_tail_x15_r0_body.ws104.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab104 : PRE_first_tail_x15_r0_body.S920.tab = PRE_first_tail_x15_r0_body.S919.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws104
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen104 : PRE_first_tail_x15_r0_body.st104.S2.tab.length - PRE_first_tail_x15_r0_body.st104.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged104`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap104 : PRE_first_tail_x15_r0_body.s920.heap = PRE_first_tail_x15_r0_body.st104.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext104 : PRE_first_tail_x15_r0_body.s920.next = PRE_first_tail_x15_r0_body.st104.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl104 : PRE_first_tail_x15_r0_body.s920.ctl = PRE_first_tail_x15_r0_body.st104.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack104 : PRE_first_tail_x15_r0_body.s920.stack = PRE_first_tail_x15_r0_body.st104.s2.stack ++ PRE_first_tail_x15_r0_body.s919.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs104 : PRE_first_tail_x15_r0_body.s920.jobs = PRE_first_tail_x15_r0_body.st104.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi104 : PRE_first_tail_x15_r0_body.s920.ffi = PRE_first_tail_x15_r0_body.st104.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace104 : PRE_first_tail_x15_r0_body.s920.trace = PRE_first_tail_x15_r0_body.st104.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores104 : PRE_first_tail_x15_r0_body.s920.stores = PRE_first_tail_x15_r0_body.st104.s2.stores

end Host.Load.Run.Tpl
