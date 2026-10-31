import host.sim.template.a4pre_first_tail_x15_r0_body.H20
import host.sim.template.a4pre_first_tail_x15_r0_body.st73.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 73 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g73__g74` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s651`, the merged state `PRE_first_tail_x15_r0_body.s652`,
the site template `PRE_first_tail_x15_r0_body.st73` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s653`: the merge.
The footprint's facts are in `SiteF73`, the compaction's in `SiteC73`, `SiteK73`, `SiteNa73`, `SiteNb73`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso73 : PRE_first_tail_x15_r0_body.st73.s0 = { PRE_first_tail_x15_r0_body.s651 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs73 : List Frame := PRE_first_tail_x15_r0_body.s651.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_73 : PRE_first_tail_x15_r0_body.S651.tab.length = 3200
kernel_rfl PRE_first_tail_x15_r0_body.tab0_73 : PRE_first_tail_x15_r0_body.st73.S0.tab = PRE_first_tail_x15_r0_body.S651.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws73 : List Nat := [2249, 2250]
kernel_rfl PRE_first_tail_x15_r0_body.fresh73 : (PRE_first_tail_x15_r0_body.S651.tab.all fun e => PRE_first_tail_x15_r0_body.ws73.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S651.oracle.all fun q => PRE_first_tail_x15_r0_body.ws73.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab73 : PRE_first_tail_x15_r0_body.S652.tab = PRE_first_tail_x15_r0_body.S651.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws73
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen73 : PRE_first_tail_x15_r0_body.st73.S2.tab.length - PRE_first_tail_x15_r0_body.st73.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged73`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap73 : PRE_first_tail_x15_r0_body.s652.heap = PRE_first_tail_x15_r0_body.st73.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext73 : PRE_first_tail_x15_r0_body.s652.next = PRE_first_tail_x15_r0_body.st73.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl73 : PRE_first_tail_x15_r0_body.s652.ctl = PRE_first_tail_x15_r0_body.st73.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack73 : PRE_first_tail_x15_r0_body.s652.stack = PRE_first_tail_x15_r0_body.st73.s2.stack ++ PRE_first_tail_x15_r0_body.s651.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs73 : PRE_first_tail_x15_r0_body.s652.jobs = PRE_first_tail_x15_r0_body.st73.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi73 : PRE_first_tail_x15_r0_body.s652.ffi = PRE_first_tail_x15_r0_body.st73.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace73 : PRE_first_tail_x15_r0_body.s652.trace = PRE_first_tail_x15_r0_body.st73.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores73 : PRE_first_tail_x15_r0_body.s652.stores = PRE_first_tail_x15_r0_body.st73.s2.stores

end Host.Load.Run.Tpl
