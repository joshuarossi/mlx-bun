import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.st178.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 178 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g178__g179` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1569`, the merged state `PRE_first_tail_x15_r0_body.s1570`,
the site template `PRE_first_tail_x15_r0_body.st178` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1571`: the merge.
The footprint's facts are in `SiteF178`, the compaction's in `SiteC178`, `SiteK178`, `SiteNa178`, `SiteNb178`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso178 : PRE_first_tail_x15_r0_body.st178.s0 = { PRE_first_tail_x15_r0_body.s1569 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs178 : List Frame := PRE_first_tail_x15_r0_body.s1569.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_178 : PRE_first_tail_x15_r0_body.S1569.tab.length = 7688
kernel_rfl PRE_first_tail_x15_r0_body.tab0_178 : PRE_first_tail_x15_r0_body.st178.S0.tab = PRE_first_tail_x15_r0_body.S1569.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws178 : List Nat := [4016, 4017]
kernel_rfl PRE_first_tail_x15_r0_body.fresh178 : (PRE_first_tail_x15_r0_body.S1569.tab.all fun e => PRE_first_tail_x15_r0_body.ws178.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1569.oracle.all fun q => PRE_first_tail_x15_r0_body.ws178.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab178 : PRE_first_tail_x15_r0_body.S1570.tab = PRE_first_tail_x15_r0_body.S1569.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws178
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen178 : PRE_first_tail_x15_r0_body.st178.S2.tab.length - PRE_first_tail_x15_r0_body.st178.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged178`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap178 : PRE_first_tail_x15_r0_body.s1570.heap = PRE_first_tail_x15_r0_body.st178.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext178 : PRE_first_tail_x15_r0_body.s1570.next = PRE_first_tail_x15_r0_body.st178.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl178 : PRE_first_tail_x15_r0_body.s1570.ctl = PRE_first_tail_x15_r0_body.st178.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack178 : PRE_first_tail_x15_r0_body.s1570.stack = PRE_first_tail_x15_r0_body.st178.s2.stack ++ PRE_first_tail_x15_r0_body.s1569.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs178 : PRE_first_tail_x15_r0_body.s1570.jobs = PRE_first_tail_x15_r0_body.st178.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi178 : PRE_first_tail_x15_r0_body.s1570.ffi = PRE_first_tail_x15_r0_body.st178.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace178 : PRE_first_tail_x15_r0_body.s1570.trace = PRE_first_tail_x15_r0_body.st178.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores178 : PRE_first_tail_x15_r0_body.s1570.stores = PRE_first_tail_x15_r0_body.st178.s2.stores

end Host.Load.Run.Tpl
