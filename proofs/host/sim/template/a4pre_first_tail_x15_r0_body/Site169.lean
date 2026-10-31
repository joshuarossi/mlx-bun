import host.sim.template.a4pre_first_tail_x15_r0_body.H51
import host.sim.template.a4pre_first_tail_x15_r0_body.st169.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 169 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g169__g170` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1634`, the merged state `PRE_first_tail_x15_r0_body.s1635`,
the site template `PRE_first_tail_x15_r0_body.st169` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1636`: the merge.
The footprint's facts are in `SiteF169`, the compaction's in `SiteC169`, `SiteK169`, `SiteNa169`, `SiteNb169`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso169 : PRE_first_tail_x15_r0_body.st169.s0 = { PRE_first_tail_x15_r0_body.s1634 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs169 : List Frame := PRE_first_tail_x15_r0_body.s1634.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_169 : PRE_first_tail_x15_r0_body.S1634.tab.length = 7304
kernel_rfl PRE_first_tail_x15_r0_body.tab0_169 : PRE_first_tail_x15_r0_body.st169.S0.tab = PRE_first_tail_x15_r0_body.S1634.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws169 : List Nat := [3859, 3860]
kernel_rfl PRE_first_tail_x15_r0_body.fresh169 : (PRE_first_tail_x15_r0_body.S1634.tab.all fun e => PRE_first_tail_x15_r0_body.ws169.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1634.oracle.all fun q => PRE_first_tail_x15_r0_body.ws169.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab169 : PRE_first_tail_x15_r0_body.S1635.tab = PRE_first_tail_x15_r0_body.S1634.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws169
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen169 : PRE_first_tail_x15_r0_body.st169.S2.tab.length - PRE_first_tail_x15_r0_body.st169.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged169`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap169 : PRE_first_tail_x15_r0_body.s1635.heap = PRE_first_tail_x15_r0_body.st169.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext169 : PRE_first_tail_x15_r0_body.s1635.next = PRE_first_tail_x15_r0_body.st169.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl169 : PRE_first_tail_x15_r0_body.s1635.ctl = PRE_first_tail_x15_r0_body.st169.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack169 : PRE_first_tail_x15_r0_body.s1635.stack = PRE_first_tail_x15_r0_body.st169.s2.stack ++ PRE_first_tail_x15_r0_body.s1634.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs169 : PRE_first_tail_x15_r0_body.s1635.jobs = PRE_first_tail_x15_r0_body.st169.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi169 : PRE_first_tail_x15_r0_body.s1635.ffi = PRE_first_tail_x15_r0_body.st169.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace169 : PRE_first_tail_x15_r0_body.s1635.trace = PRE_first_tail_x15_r0_body.st169.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores169 : PRE_first_tail_x15_r0_body.s1635.stores = PRE_first_tail_x15_r0_body.st169.s2.stores

end Host.Load.Run.Tpl
