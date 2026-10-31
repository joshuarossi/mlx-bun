import host.sim.template.a4pre_first_tail_x15_r0_body.H33
import host.sim.template.a4pre_first_tail_x15_r0_body.st121.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 121 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g121__g122` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1071`, the merged state `PRE_first_tail_x15_r0_body.s1072`,
the site template `PRE_first_tail_x15_r0_body.st121` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1073`: the merge.
The footprint's facts are in `SiteF121`, the compaction's in `SiteC121`, `SiteK121`, `SiteNa121`, `SiteNb121`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso121 : PRE_first_tail_x15_r0_body.st121.s0 = { PRE_first_tail_x15_r0_body.s1071 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs121 : List Frame := PRE_first_tail_x15_r0_body.s1071.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_121 : PRE_first_tail_x15_r0_body.S1071.tab.length = 5252
kernel_rfl PRE_first_tail_x15_r0_body.tab0_121 : PRE_first_tail_x15_r0_body.st121.S0.tab = PRE_first_tail_x15_r0_body.S1071.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws121 : List Nat := [3045, 3046]
kernel_rfl PRE_first_tail_x15_r0_body.fresh121 : (PRE_first_tail_x15_r0_body.S1071.tab.all fun e => PRE_first_tail_x15_r0_body.ws121.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1071.oracle.all fun q => PRE_first_tail_x15_r0_body.ws121.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab121 : PRE_first_tail_x15_r0_body.S1072.tab = PRE_first_tail_x15_r0_body.S1071.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws121
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen121 : PRE_first_tail_x15_r0_body.st121.S2.tab.length - PRE_first_tail_x15_r0_body.st121.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged121`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap121 : PRE_first_tail_x15_r0_body.s1072.heap = PRE_first_tail_x15_r0_body.st121.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext121 : PRE_first_tail_x15_r0_body.s1072.next = PRE_first_tail_x15_r0_body.st121.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl121 : PRE_first_tail_x15_r0_body.s1072.ctl = PRE_first_tail_x15_r0_body.st121.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack121 : PRE_first_tail_x15_r0_body.s1072.stack = PRE_first_tail_x15_r0_body.st121.s2.stack ++ PRE_first_tail_x15_r0_body.s1071.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs121 : PRE_first_tail_x15_r0_body.s1072.jobs = PRE_first_tail_x15_r0_body.st121.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi121 : PRE_first_tail_x15_r0_body.s1072.ffi = PRE_first_tail_x15_r0_body.st121.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace121 : PRE_first_tail_x15_r0_body.s1072.trace = PRE_first_tail_x15_r0_body.st121.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores121 : PRE_first_tail_x15_r0_body.s1072.stores = PRE_first_tail_x15_r0_body.st121.s2.stores

end Host.Load.Run.Tpl
