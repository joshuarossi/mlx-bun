import host.sim.template.a4pre_first_tail_x15_r0_body.H52
import host.sim.template.a4pre_first_tail_x15_r0_body.st172.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 172 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g172__g173` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1663`, the merged state `PRE_first_tail_x15_r0_body.s1664`,
the site template `PRE_first_tail_x15_r0_body.st172` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1665`: the merge.
The footprint's facts are in `SiteF172`, the compaction's in `SiteC172`, `SiteK172`, `SiteNa172`, `SiteNb172`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso172 : PRE_first_tail_x15_r0_body.st172.s0 = { PRE_first_tail_x15_r0_body.s1663 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs172 : List Frame := PRE_first_tail_x15_r0_body.s1663.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_172 : PRE_first_tail_x15_r0_body.S1663.tab.length = 7433
kernel_rfl PRE_first_tail_x15_r0_body.tab0_172 : PRE_first_tail_x15_r0_body.st172.S0.tab = PRE_first_tail_x15_r0_body.S1663.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws172 : List Nat := [3919, 3920]
kernel_rfl PRE_first_tail_x15_r0_body.fresh172 : (PRE_first_tail_x15_r0_body.S1663.tab.all fun e => PRE_first_tail_x15_r0_body.ws172.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1663.oracle.all fun q => PRE_first_tail_x15_r0_body.ws172.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab172 : PRE_first_tail_x15_r0_body.S1664.tab = PRE_first_tail_x15_r0_body.S1663.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws172
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen172 : PRE_first_tail_x15_r0_body.st172.S2.tab.length - PRE_first_tail_x15_r0_body.st172.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged172`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap172 : PRE_first_tail_x15_r0_body.s1664.heap = PRE_first_tail_x15_r0_body.st172.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext172 : PRE_first_tail_x15_r0_body.s1664.next = PRE_first_tail_x15_r0_body.st172.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl172 : PRE_first_tail_x15_r0_body.s1664.ctl = PRE_first_tail_x15_r0_body.st172.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack172 : PRE_first_tail_x15_r0_body.s1664.stack = PRE_first_tail_x15_r0_body.st172.s2.stack ++ PRE_first_tail_x15_r0_body.s1663.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs172 : PRE_first_tail_x15_r0_body.s1664.jobs = PRE_first_tail_x15_r0_body.st172.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi172 : PRE_first_tail_x15_r0_body.s1664.ffi = PRE_first_tail_x15_r0_body.st172.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace172 : PRE_first_tail_x15_r0_body.s1664.trace = PRE_first_tail_x15_r0_body.st172.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores172 : PRE_first_tail_x15_r0_body.s1664.stores = PRE_first_tail_x15_r0_body.st172.s2.stores

end Host.Load.Run.Tpl
