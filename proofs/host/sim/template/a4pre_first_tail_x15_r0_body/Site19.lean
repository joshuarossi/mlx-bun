import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.a4pre_first_tail_x15_r0_body.st19.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 19 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g19__g20` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s197`, the merged state `PRE_first_tail_x15_r0_body.s198`,
the site template `PRE_first_tail_x15_r0_body.st19` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s199`: the merge.
The footprint's facts are in `SiteF19`, the compaction's in `SiteC19`, `SiteK19`, `SiteNa19`, `SiteNb19`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso19 : PRE_first_tail_x15_r0_body.st19.s0 = { PRE_first_tail_x15_r0_body.s197 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs19 : List Frame := PRE_first_tail_x15_r0_body.s197.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_19 : PRE_first_tail_x15_r0_body.S197.tab.length = 893
kernel_rfl PRE_first_tail_x15_r0_body.tab0_19 : PRE_first_tail_x15_r0_body.st19.S0.tab = PRE_first_tail_x15_r0_body.S197.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws19 : List Nat := [1356, 1357]
kernel_rfl PRE_first_tail_x15_r0_body.fresh19 : (PRE_first_tail_x15_r0_body.S197.tab.all fun e => PRE_first_tail_x15_r0_body.ws19.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S197.oracle.all fun q => PRE_first_tail_x15_r0_body.ws19.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab19 : PRE_first_tail_x15_r0_body.S198.tab = PRE_first_tail_x15_r0_body.S197.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws19
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen19 : PRE_first_tail_x15_r0_body.st19.S2.tab.length - PRE_first_tail_x15_r0_body.st19.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged19`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap19 : PRE_first_tail_x15_r0_body.s198.heap = PRE_first_tail_x15_r0_body.st19.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext19 : PRE_first_tail_x15_r0_body.s198.next = PRE_first_tail_x15_r0_body.st19.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl19 : PRE_first_tail_x15_r0_body.s198.ctl = PRE_first_tail_x15_r0_body.st19.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack19 : PRE_first_tail_x15_r0_body.s198.stack = PRE_first_tail_x15_r0_body.st19.s2.stack ++ PRE_first_tail_x15_r0_body.s197.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs19 : PRE_first_tail_x15_r0_body.s198.jobs = PRE_first_tail_x15_r0_body.st19.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi19 : PRE_first_tail_x15_r0_body.s198.ffi = PRE_first_tail_x15_r0_body.st19.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace19 : PRE_first_tail_x15_r0_body.s198.trace = PRE_first_tail_x15_r0_body.st19.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores19 : PRE_first_tail_x15_r0_body.s198.stores = PRE_first_tail_x15_r0_body.st19.s2.stores

end Host.Load.Run.Tpl
