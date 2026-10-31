import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.st103.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 103 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g103__g104` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1002`, the merged state `PRE_first_tail_x15_r0_body.s1003`,
the site template `PRE_first_tail_x15_r0_body.st103` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1004`: the merge.
The footprint's facts are in `SiteF103`, the compaction's in `SiteC103`, `SiteK103`, `SiteNa103`, `SiteNb103`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso103 : PRE_first_tail_x15_r0_body.st103.s0 = { PRE_first_tail_x15_r0_body.s1002 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs103 : List Frame := PRE_first_tail_x15_r0_body.s1002.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_103 : PRE_first_tail_x15_r0_body.S1002.tab.length = 4484
kernel_rfl PRE_first_tail_x15_r0_body.tab0_103 : PRE_first_tail_x15_r0_body.st103.S0.tab = PRE_first_tail_x15_r0_body.S1002.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws103 : List Nat := [2767, 2768]
kernel_rfl PRE_first_tail_x15_r0_body.fresh103 : (PRE_first_tail_x15_r0_body.S1002.tab.all fun e => PRE_first_tail_x15_r0_body.ws103.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1002.oracle.all fun q => PRE_first_tail_x15_r0_body.ws103.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab103 : PRE_first_tail_x15_r0_body.S1003.tab = PRE_first_tail_x15_r0_body.S1002.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws103
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen103 : PRE_first_tail_x15_r0_body.st103.S2.tab.length - PRE_first_tail_x15_r0_body.st103.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged103`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap103 : PRE_first_tail_x15_r0_body.s1003.heap = PRE_first_tail_x15_r0_body.st103.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext103 : PRE_first_tail_x15_r0_body.s1003.next = PRE_first_tail_x15_r0_body.st103.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl103 : PRE_first_tail_x15_r0_body.s1003.ctl = PRE_first_tail_x15_r0_body.st103.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack103 : PRE_first_tail_x15_r0_body.s1003.stack = PRE_first_tail_x15_r0_body.st103.s2.stack ++ PRE_first_tail_x15_r0_body.s1002.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs103 : PRE_first_tail_x15_r0_body.s1003.jobs = PRE_first_tail_x15_r0_body.st103.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi103 : PRE_first_tail_x15_r0_body.s1003.ffi = PRE_first_tail_x15_r0_body.st103.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace103 : PRE_first_tail_x15_r0_body.s1003.trace = PRE_first_tail_x15_r0_body.st103.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores103 : PRE_first_tail_x15_r0_body.s1003.stores = PRE_first_tail_x15_r0_body.st103.s2.stores

end Host.Load.Run.Tpl
