import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.st34.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 34 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g34__g35` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s309`, the merged state `PRE_first_tail_x15_r0_body.s310`,
the site template `PRE_first_tail_x15_r0_body.st34` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s311`: the merge.
The footprint's facts are in `SiteF34`, the compaction's in `SiteC34`, `SiteK34`, `SiteNa34`, `SiteNb34`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso34 : PRE_first_tail_x15_r0_body.st34.s0 = { PRE_first_tail_x15_r0_body.s309 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs34 : List Frame := PRE_first_tail_x15_r0_body.s309.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_34 : PRE_first_tail_x15_r0_body.S309.tab.length = 1532
kernel_rfl PRE_first_tail_x15_r0_body.tab0_34 : PRE_first_tail_x15_r0_body.st34.S0.tab = PRE_first_tail_x15_r0_body.S309.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws34 : List Nat := [1580, 1581]
kernel_rfl PRE_first_tail_x15_r0_body.fresh34 : (PRE_first_tail_x15_r0_body.S309.tab.all fun e => PRE_first_tail_x15_r0_body.ws34.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S309.oracle.all fun q => PRE_first_tail_x15_r0_body.ws34.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab34 : PRE_first_tail_x15_r0_body.S310.tab = PRE_first_tail_x15_r0_body.S309.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws34
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen34 : PRE_first_tail_x15_r0_body.st34.S2.tab.length - PRE_first_tail_x15_r0_body.st34.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged34`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap34 : PRE_first_tail_x15_r0_body.s310.heap = PRE_first_tail_x15_r0_body.st34.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext34 : PRE_first_tail_x15_r0_body.s310.next = PRE_first_tail_x15_r0_body.st34.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl34 : PRE_first_tail_x15_r0_body.s310.ctl = PRE_first_tail_x15_r0_body.st34.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack34 : PRE_first_tail_x15_r0_body.s310.stack = PRE_first_tail_x15_r0_body.st34.s2.stack ++ PRE_first_tail_x15_r0_body.s309.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs34 : PRE_first_tail_x15_r0_body.s310.jobs = PRE_first_tail_x15_r0_body.st34.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi34 : PRE_first_tail_x15_r0_body.s310.ffi = PRE_first_tail_x15_r0_body.st34.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace34 : PRE_first_tail_x15_r0_body.s310.trace = PRE_first_tail_x15_r0_body.st34.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores34 : PRE_first_tail_x15_r0_body.s310.stores = PRE_first_tail_x15_r0_body.st34.s2.stores

end Host.Load.Run.Tpl
