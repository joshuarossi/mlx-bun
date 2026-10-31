import host.sim.template.a4pre_first_tail_x15_r0_body.H33
import host.sim.template.a4pre_first_tail_x15_r0_body.st109.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 109 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g109__g110` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1059`, the merged state `PRE_first_tail_x15_r0_body.s1060`,
the site template `PRE_first_tail_x15_r0_body.st109` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1061`: the merge.
The footprint's facts are in `SiteF109`, the compaction's in `SiteC109`, `SiteK109`, `SiteNa109`, `SiteNb109`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso109 : PRE_first_tail_x15_r0_body.st109.s0 = { PRE_first_tail_x15_r0_body.s1059 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs109 : List Frame := PRE_first_tail_x15_r0_body.s1059.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_109 : PRE_first_tail_x15_r0_body.S1059.tab.length = 4739
kernel_rfl PRE_first_tail_x15_r0_body.tab0_109 : PRE_first_tail_x15_r0_body.st109.S0.tab = PRE_first_tail_x15_r0_body.S1059.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws109 : List Nat := [2852, 2853]
kernel_rfl PRE_first_tail_x15_r0_body.fresh109 : (PRE_first_tail_x15_r0_body.S1059.tab.all fun e => PRE_first_tail_x15_r0_body.ws109.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1059.oracle.all fun q => PRE_first_tail_x15_r0_body.ws109.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab109 : PRE_first_tail_x15_r0_body.S1060.tab = PRE_first_tail_x15_r0_body.S1059.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws109
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen109 : PRE_first_tail_x15_r0_body.st109.S2.tab.length - PRE_first_tail_x15_r0_body.st109.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged109`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap109 : PRE_first_tail_x15_r0_body.s1060.heap = PRE_first_tail_x15_r0_body.st109.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext109 : PRE_first_tail_x15_r0_body.s1060.next = PRE_first_tail_x15_r0_body.st109.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl109 : PRE_first_tail_x15_r0_body.s1060.ctl = PRE_first_tail_x15_r0_body.st109.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack109 : PRE_first_tail_x15_r0_body.s1060.stack = PRE_first_tail_x15_r0_body.st109.s2.stack ++ PRE_first_tail_x15_r0_body.s1059.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs109 : PRE_first_tail_x15_r0_body.s1060.jobs = PRE_first_tail_x15_r0_body.st109.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi109 : PRE_first_tail_x15_r0_body.s1060.ffi = PRE_first_tail_x15_r0_body.st109.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace109 : PRE_first_tail_x15_r0_body.s1060.trace = PRE_first_tail_x15_r0_body.st109.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores109 : PRE_first_tail_x15_r0_body.s1060.stores = PRE_first_tail_x15_r0_body.st109.s2.stores

end Host.Load.Run.Tpl
