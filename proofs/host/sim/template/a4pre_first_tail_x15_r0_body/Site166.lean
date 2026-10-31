import host.sim.template.a4pre_first_tail_x15_r0_body.H45
import host.sim.template.a4pre_first_tail_x15_r0_body.st166.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 166 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g166__g167` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1464`, the merged state `PRE_first_tail_x15_r0_body.s1465`,
the site template `PRE_first_tail_x15_r0_body.st166` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1466`: the merge.
The footprint's facts are in `SiteF166`, the compaction's in `SiteC166`, `SiteK166`, `SiteNa166`, `SiteNb166`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso166 : PRE_first_tail_x15_r0_body.st166.s0 = { PRE_first_tail_x15_r0_body.s1464 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs166 : List Frame := PRE_first_tail_x15_r0_body.s1464.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_166 : PRE_first_tail_x15_r0_body.S1464.tab.length = 7175
kernel_rfl PRE_first_tail_x15_r0_body.tab0_166 : PRE_first_tail_x15_r0_body.st166.S0.tab = PRE_first_tail_x15_r0_body.S1464.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws166 : List Nat := [3799, 3800]
kernel_rfl PRE_first_tail_x15_r0_body.fresh166 : (PRE_first_tail_x15_r0_body.S1464.tab.all fun e => PRE_first_tail_x15_r0_body.ws166.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1464.oracle.all fun q => PRE_first_tail_x15_r0_body.ws166.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab166 : PRE_first_tail_x15_r0_body.S1465.tab = PRE_first_tail_x15_r0_body.S1464.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws166
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen166 : PRE_first_tail_x15_r0_body.st166.S2.tab.length - PRE_first_tail_x15_r0_body.st166.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged166`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap166 : PRE_first_tail_x15_r0_body.s1465.heap = PRE_first_tail_x15_r0_body.st166.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext166 : PRE_first_tail_x15_r0_body.s1465.next = PRE_first_tail_x15_r0_body.st166.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl166 : PRE_first_tail_x15_r0_body.s1465.ctl = PRE_first_tail_x15_r0_body.st166.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack166 : PRE_first_tail_x15_r0_body.s1465.stack = PRE_first_tail_x15_r0_body.st166.s2.stack ++ PRE_first_tail_x15_r0_body.s1464.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs166 : PRE_first_tail_x15_r0_body.s1465.jobs = PRE_first_tail_x15_r0_body.st166.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi166 : PRE_first_tail_x15_r0_body.s1465.ffi = PRE_first_tail_x15_r0_body.st166.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace166 : PRE_first_tail_x15_r0_body.s1465.trace = PRE_first_tail_x15_r0_body.st166.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores166 : PRE_first_tail_x15_r0_body.s1465.stores = PRE_first_tail_x15_r0_body.st166.s2.stores

end Host.Load.Run.Tpl
