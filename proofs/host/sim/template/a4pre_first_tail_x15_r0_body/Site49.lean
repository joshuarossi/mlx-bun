import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.a4pre_first_tail_x15_r0_body.st49.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 49 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g49__g50` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s441`, the merged state `PRE_first_tail_x15_r0_body.s442`,
the site template `PRE_first_tail_x15_r0_body.st49` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s443`: the merge.
The footprint's facts are in `SiteF49`, the compaction's in `SiteC49`, `SiteK49`, `SiteNa49`, `SiteNb49`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso49 : PRE_first_tail_x15_r0_body.st49.s0 = { PRE_first_tail_x15_r0_body.s441 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs49 : List Frame := PRE_first_tail_x15_r0_body.s441.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_49 : PRE_first_tail_x15_r0_body.S441.tab.length = 2174
kernel_rfl PRE_first_tail_x15_r0_body.tab0_49 : PRE_first_tail_x15_r0_body.st49.S0.tab = PRE_first_tail_x15_r0_body.S441.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws49 : List Nat := [1845, 1846]
kernel_rfl PRE_first_tail_x15_r0_body.fresh49 : (PRE_first_tail_x15_r0_body.S441.tab.all fun e => PRE_first_tail_x15_r0_body.ws49.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S441.oracle.all fun q => PRE_first_tail_x15_r0_body.ws49.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab49 : PRE_first_tail_x15_r0_body.S442.tab = PRE_first_tail_x15_r0_body.S441.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws49
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen49 : PRE_first_tail_x15_r0_body.st49.S2.tab.length - PRE_first_tail_x15_r0_body.st49.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged49`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap49 : PRE_first_tail_x15_r0_body.s442.heap = PRE_first_tail_x15_r0_body.st49.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext49 : PRE_first_tail_x15_r0_body.s442.next = PRE_first_tail_x15_r0_body.st49.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl49 : PRE_first_tail_x15_r0_body.s442.ctl = PRE_first_tail_x15_r0_body.st49.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack49 : PRE_first_tail_x15_r0_body.s442.stack = PRE_first_tail_x15_r0_body.st49.s2.stack ++ PRE_first_tail_x15_r0_body.s441.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs49 : PRE_first_tail_x15_r0_body.s442.jobs = PRE_first_tail_x15_r0_body.st49.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi49 : PRE_first_tail_x15_r0_body.s442.ffi = PRE_first_tail_x15_r0_body.st49.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace49 : PRE_first_tail_x15_r0_body.s442.trace = PRE_first_tail_x15_r0_body.st49.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores49 : PRE_first_tail_x15_r0_body.s442.stores = PRE_first_tail_x15_r0_body.st49.s2.stores

end Host.Load.Run.Tpl
