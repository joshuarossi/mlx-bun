import host.sim.template.a4pre_first_tail_x15_r0_body.H34
import host.sim.template.a4pre_first_tail_x15_r0_body.st113.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 113 of chain `PRE_first_tail_x15_r0_body`: `plan__g113__g114` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1092`, the merged state `PRE_first_tail_x15_r0_body.s1093`,
the site template `PRE_first_tail_x15_r0_body.st113` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1094`: the merge.
The footprint's facts are in `SiteF113`, the compaction's in `SiteC113`, `SiteK113`, `SiteNa113`, `SiteNb113`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso113 : PRE_first_tail_x15_r0_body.st113.s0 = { PRE_first_tail_x15_r0_body.s1092 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs113 : List Frame := PRE_first_tail_x15_r0_body.s1092.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_113 : PRE_first_tail_x15_r0_body.S1092.tab.length = 4885
kernel_rfl PRE_first_tail_x15_r0_body.tab0_113 : PRE_first_tail_x15_r0_body.st113.S0.tab = PRE_first_tail_x15_r0_body.S1092.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws113 : List Nat := [2908, 2909, 2910]
kernel_rfl PRE_first_tail_x15_r0_body.fresh113 : (PRE_first_tail_x15_r0_body.S1092.tab.all fun e => PRE_first_tail_x15_r0_body.ws113.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1092.oracle.all fun q => PRE_first_tail_x15_r0_body.ws113.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab113 : PRE_first_tail_x15_r0_body.S1093.tab = PRE_first_tail_x15_r0_body.S1092.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws113
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen113 : PRE_first_tail_x15_r0_body.st113.S2.tab.length - PRE_first_tail_x15_r0_body.st113.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged113`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap113 : PRE_first_tail_x15_r0_body.s1093.heap = PRE_first_tail_x15_r0_body.st113.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext113 : PRE_first_tail_x15_r0_body.s1093.next = PRE_first_tail_x15_r0_body.st113.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl113 : PRE_first_tail_x15_r0_body.s1093.ctl = PRE_first_tail_x15_r0_body.st113.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack113 : PRE_first_tail_x15_r0_body.s1093.stack = PRE_first_tail_x15_r0_body.st113.s2.stack ++ PRE_first_tail_x15_r0_body.s1092.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs113 : PRE_first_tail_x15_r0_body.s1093.jobs = PRE_first_tail_x15_r0_body.st113.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi113 : PRE_first_tail_x15_r0_body.s1093.ffi = PRE_first_tail_x15_r0_body.st113.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace113 : PRE_first_tail_x15_r0_body.s1093.trace = PRE_first_tail_x15_r0_body.st113.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores113 : PRE_first_tail_x15_r0_body.s1093.stores = PRE_first_tail_x15_r0_body.st113.s2.stores

end Host.Load.Run.Tpl
