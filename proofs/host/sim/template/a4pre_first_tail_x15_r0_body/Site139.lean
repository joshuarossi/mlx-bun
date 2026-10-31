import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.st139.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 139 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g139__g140` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1230`, the merged state `PRE_first_tail_x15_r0_body.s1231`,
the site template `PRE_first_tail_x15_r0_body.st139` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1232`: the merge.
The footprint's facts are in `SiteF139`, the compaction's in `SiteC139`, `SiteK139`, `SiteNa139`, `SiteNb139`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso139 : PRE_first_tail_x15_r0_body.st139.s0 = { PRE_first_tail_x15_r0_body.s1230 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs139 : List Frame := PRE_first_tail_x15_r0_body.s1230.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_139 : PRE_first_tail_x15_r0_body.S1230.tab.length = 6023
kernel_rfl PRE_first_tail_x15_r0_body.tab0_139 : PRE_first_tail_x15_r0_body.st139.S0.tab = PRE_first_tail_x15_r0_body.S1230.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws139 : List Nat := [3352, 3353]
kernel_rfl PRE_first_tail_x15_r0_body.fresh139 : (PRE_first_tail_x15_r0_body.S1230.tab.all fun e => PRE_first_tail_x15_r0_body.ws139.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1230.oracle.all fun q => PRE_first_tail_x15_r0_body.ws139.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab139 : PRE_first_tail_x15_r0_body.S1231.tab = PRE_first_tail_x15_r0_body.S1230.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws139
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen139 : PRE_first_tail_x15_r0_body.st139.S2.tab.length - PRE_first_tail_x15_r0_body.st139.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged139`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap139 : PRE_first_tail_x15_r0_body.s1231.heap = PRE_first_tail_x15_r0_body.st139.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext139 : PRE_first_tail_x15_r0_body.s1231.next = PRE_first_tail_x15_r0_body.st139.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl139 : PRE_first_tail_x15_r0_body.s1231.ctl = PRE_first_tail_x15_r0_body.st139.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack139 : PRE_first_tail_x15_r0_body.s1231.stack = PRE_first_tail_x15_r0_body.st139.s2.stack ++ PRE_first_tail_x15_r0_body.s1230.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs139 : PRE_first_tail_x15_r0_body.s1231.jobs = PRE_first_tail_x15_r0_body.st139.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi139 : PRE_first_tail_x15_r0_body.s1231.ffi = PRE_first_tail_x15_r0_body.st139.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace139 : PRE_first_tail_x15_r0_body.s1231.trace = PRE_first_tail_x15_r0_body.st139.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores139 : PRE_first_tail_x15_r0_body.s1231.stores = PRE_first_tail_x15_r0_body.st139.s2.stores

end Host.Load.Run.Tpl
