import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.a4pre_first_tail_x15_r0_body.st10.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 10 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g10__g11` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s99`, the merged state `PRE_first_tail_x15_r0_body.s100`,
the site template `PRE_first_tail_x15_r0_body.st10` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s101`: the merge.
The footprint's facts are in `SiteF10`, the compaction's in `SiteC10`, `SiteK10`, `SiteNa10`, `SiteNb10`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso10 : PRE_first_tail_x15_r0_body.st10.s0 = { PRE_first_tail_x15_r0_body.s99 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs10 : List Frame := PRE_first_tail_x15_r0_body.s99.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_10 : PRE_first_tail_x15_r0_body.S99.tab.length = 506
kernel_rfl PRE_first_tail_x15_r0_body.tab0_10 : PRE_first_tail_x15_r0_body.st10.S0.tab = PRE_first_tail_x15_r0_body.S99.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws10 : List Nat := [1194, 1195]
kernel_rfl PRE_first_tail_x15_r0_body.fresh10 : (PRE_first_tail_x15_r0_body.S99.tab.all fun e => PRE_first_tail_x15_r0_body.ws10.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S99.oracle.all fun q => PRE_first_tail_x15_r0_body.ws10.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab10 : PRE_first_tail_x15_r0_body.S100.tab = PRE_first_tail_x15_r0_body.S99.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws10
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen10 : PRE_first_tail_x15_r0_body.st10.S2.tab.length - PRE_first_tail_x15_r0_body.st10.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged10`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap10 : PRE_first_tail_x15_r0_body.s100.heap = PRE_first_tail_x15_r0_body.st10.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext10 : PRE_first_tail_x15_r0_body.s100.next = PRE_first_tail_x15_r0_body.st10.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl10 : PRE_first_tail_x15_r0_body.s100.ctl = PRE_first_tail_x15_r0_body.st10.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack10 : PRE_first_tail_x15_r0_body.s100.stack = PRE_first_tail_x15_r0_body.st10.s2.stack ++ PRE_first_tail_x15_r0_body.s99.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs10 : PRE_first_tail_x15_r0_body.s100.jobs = PRE_first_tail_x15_r0_body.st10.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi10 : PRE_first_tail_x15_r0_body.s100.ffi = PRE_first_tail_x15_r0_body.st10.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace10 : PRE_first_tail_x15_r0_body.s100.trace = PRE_first_tail_x15_r0_body.st10.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores10 : PRE_first_tail_x15_r0_body.s100.stores = PRE_first_tail_x15_r0_body.st10.s2.stores

end Host.Load.Run.Tpl
