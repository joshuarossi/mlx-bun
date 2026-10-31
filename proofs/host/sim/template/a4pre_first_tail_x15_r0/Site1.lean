import host.sim.template.a4pre_first_tail_x15_r0.H0
import host.sim.template.a4pre_first_tail_x15_r0.st1.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `PRE_first_tail_x15_r0`: `nps_DTtail_first__g0b__g1_DTtail_first` (`nextPrefillStep`), the call state `PRE_first_tail_x15_r0.s17`, the merged state `PRE_first_tail_x15_r0.s18`,
the site template `PRE_first_tail_x15_r0.st1` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0.s19`: the merge.
The footprint's facts are in `SiteF1`, the compaction's in `SiteC1`, `SiteK1`, `SiteNa1`, `SiteNb1`. -/

kernel_rfl PRE_first_tail_x15_r0.iso1 : PRE_first_tail_x15_r0.st1.s0 = { PRE_first_tail_x15_r0.s17 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0.rs1 : List Frame := PRE_first_tail_x15_r0.s17.stack
kernel_rfl PRE_first_tail_x15_r0.n0_1 : PRE_first_tail_x15_r0.S17.tab.length = 14
kernel_rfl PRE_first_tail_x15_r0.tab0_1 : PRE_first_tail_x15_r0.st1.S0.tab = PRE_first_tail_x15_r0.S17.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0.ws1 : List Nat := [1080, 1081, 1082, 1083, 1084, 1085, 1086]
kernel_rfl PRE_first_tail_x15_r0.fresh1 : (PRE_first_tail_x15_r0.S17.tab.all fun e => PRE_first_tail_x15_r0.ws1.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0.S17.oracle.all fun q => PRE_first_tail_x15_r0.ws1.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0.mergeTab1 : PRE_first_tail_x15_r0.S18.tab = PRE_first_tail_x15_r0.S17.tab ++ Conv.resTab PRE_first_tail_x15_r0.ws1
kernel_rfl PRE_first_tail_x15_r0.mergeLen1 : PRE_first_tail_x15_r0.st1.S2.tab.length - PRE_first_tail_x15_r0.st1.S0.tab.length = 7

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0.merged1`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0.mheap1 : PRE_first_tail_x15_r0.s18.heap = PRE_first_tail_x15_r0.st1.s2.heap
kernel_rfl PRE_first_tail_x15_r0.mnext1 : PRE_first_tail_x15_r0.s18.next = PRE_first_tail_x15_r0.st1.s2.next
kernel_rfl PRE_first_tail_x15_r0.mctl1 : PRE_first_tail_x15_r0.s18.ctl = PRE_first_tail_x15_r0.st1.s2.ctl
kernel_rfl PRE_first_tail_x15_r0.mstack1 : PRE_first_tail_x15_r0.s18.stack = PRE_first_tail_x15_r0.st1.s2.stack ++ PRE_first_tail_x15_r0.s17.stack
kernel_rfl PRE_first_tail_x15_r0.mjobs1 : PRE_first_tail_x15_r0.s18.jobs = PRE_first_tail_x15_r0.st1.s2.jobs
kernel_rfl PRE_first_tail_x15_r0.mffi1 : PRE_first_tail_x15_r0.s18.ffi = PRE_first_tail_x15_r0.st1.s2.ffi
kernel_rfl PRE_first_tail_x15_r0.mtrace1 : PRE_first_tail_x15_r0.s18.trace = PRE_first_tail_x15_r0.st1.s2.trace
kernel_rfl PRE_first_tail_x15_r0.mstores1 : PRE_first_tail_x15_r0.s18.stores = PRE_first_tail_x15_r0.st1.s2.stores

end Host.Load.Run.Tpl
