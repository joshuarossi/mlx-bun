import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.a4pre_first_tail_x15_r0_body.st154.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 154 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g154__g155` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1490`, the merged state `PRE_first_tail_x15_r0_body.s1491`,
the site template `PRE_first_tail_x15_r0_body.st154` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1492`: the merge.
The footprint's facts are in `SiteF154`, the compaction's in `SiteC154`, `SiteK154`, `SiteNa154`, `SiteNb154`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso154 : PRE_first_tail_x15_r0_body.st154.s0 = { PRE_first_tail_x15_r0_body.s1490 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs154 : List Frame := PRE_first_tail_x15_r0_body.s1490.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_154 : PRE_first_tail_x15_r0_body.S1490.tab.length = 6662
kernel_rfl PRE_first_tail_x15_r0_body.tab0_154 : PRE_first_tail_x15_r0_body.st154.S0.tab = PRE_first_tail_x15_r0_body.S1490.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws154 : List Nat := [3600, 3601]
kernel_rfl PRE_first_tail_x15_r0_body.fresh154 : (PRE_first_tail_x15_r0_body.S1490.tab.all fun e => PRE_first_tail_x15_r0_body.ws154.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1490.oracle.all fun q => PRE_first_tail_x15_r0_body.ws154.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab154 : PRE_first_tail_x15_r0_body.S1491.tab = PRE_first_tail_x15_r0_body.S1490.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws154
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen154 : PRE_first_tail_x15_r0_body.st154.S2.tab.length - PRE_first_tail_x15_r0_body.st154.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged154`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap154 : PRE_first_tail_x15_r0_body.s1491.heap = PRE_first_tail_x15_r0_body.st154.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext154 : PRE_first_tail_x15_r0_body.s1491.next = PRE_first_tail_x15_r0_body.st154.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl154 : PRE_first_tail_x15_r0_body.s1491.ctl = PRE_first_tail_x15_r0_body.st154.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack154 : PRE_first_tail_x15_r0_body.s1491.stack = PRE_first_tail_x15_r0_body.st154.s2.stack ++ PRE_first_tail_x15_r0_body.s1490.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs154 : PRE_first_tail_x15_r0_body.s1491.jobs = PRE_first_tail_x15_r0_body.st154.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi154 : PRE_first_tail_x15_r0_body.s1491.ffi = PRE_first_tail_x15_r0_body.st154.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace154 : PRE_first_tail_x15_r0_body.s1491.trace = PRE_first_tail_x15_r0_body.st154.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores154 : PRE_first_tail_x15_r0_body.s1491.stores = PRE_first_tail_x15_r0_body.st154.s2.stores

end Host.Load.Run.Tpl
