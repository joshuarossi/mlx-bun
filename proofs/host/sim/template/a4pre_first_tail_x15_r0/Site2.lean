import host.sim.template.a4pre_first_tail_x15_r0.H1
import host.sim.template.a4pre_first_tail_x15_r0.st2.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `PRE_first_tail_x15_r0`: `disp_VW__g1_DTtail_first__g2_first` (`prompt`), the call state `PRE_first_tail_x15_r0.s38`, the merged state `PRE_first_tail_x15_r0.s39`,
the site template `PRE_first_tail_x15_r0.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0.s40`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl PRE_first_tail_x15_r0.iso2 : PRE_first_tail_x15_r0.st2.s0 = { PRE_first_tail_x15_r0.s38 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0.rs2 : List Frame := PRE_first_tail_x15_r0.s38.stack
kernel_rfl PRE_first_tail_x15_r0.n0_2 : PRE_first_tail_x15_r0.S38.tab.length = 18
kernel_rfl PRE_first_tail_x15_r0.tab0_2 : PRE_first_tail_x15_r0.st2.S0.tab = PRE_first_tail_x15_r0.S38.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0.ws2 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0.fresh2 : (PRE_first_tail_x15_r0.S38.tab.all fun e => PRE_first_tail_x15_r0.ws2.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0.S38.oracle.all fun q => PRE_first_tail_x15_r0.ws2.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0.mergeTab2 : PRE_first_tail_x15_r0.S39.tab = PRE_first_tail_x15_r0.S38.tab ++ Conv.resTab PRE_first_tail_x15_r0.ws2
kernel_rfl PRE_first_tail_x15_r0.mergeLen2 : PRE_first_tail_x15_r0.st2.S2.tab.length - PRE_first_tail_x15_r0.st2.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0.merged2`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0.mheap2 : PRE_first_tail_x15_r0.s39.heap = PRE_first_tail_x15_r0.st2.s2.heap
kernel_rfl PRE_first_tail_x15_r0.mnext2 : PRE_first_tail_x15_r0.s39.next = PRE_first_tail_x15_r0.st2.s2.next
kernel_rfl PRE_first_tail_x15_r0.mctl2 : PRE_first_tail_x15_r0.s39.ctl = PRE_first_tail_x15_r0.st2.s2.ctl
kernel_rfl PRE_first_tail_x15_r0.mstack2 : PRE_first_tail_x15_r0.s39.stack = PRE_first_tail_x15_r0.st2.s2.stack ++ PRE_first_tail_x15_r0.s38.stack
kernel_rfl PRE_first_tail_x15_r0.mjobs2 : PRE_first_tail_x15_r0.s39.jobs = PRE_first_tail_x15_r0.st2.s2.jobs
kernel_rfl PRE_first_tail_x15_r0.mffi2 : PRE_first_tail_x15_r0.s39.ffi = PRE_first_tail_x15_r0.st2.s2.ffi
kernel_rfl PRE_first_tail_x15_r0.mtrace2 : PRE_first_tail_x15_r0.s39.trace = PRE_first_tail_x15_r0.st2.s2.trace
kernel_rfl PRE_first_tail_x15_r0.mstores2 : PRE_first_tail_x15_r0.s39.stores = PRE_first_tail_x15_r0.st2.s2.stores

end Host.Load.Run.Tpl
