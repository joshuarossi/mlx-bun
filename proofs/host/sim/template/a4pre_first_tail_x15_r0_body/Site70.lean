import host.sim.template.a4pre_first_tail_x15_r0_body.H19
import host.sim.template.a4pre_first_tail_x15_r0_body.st70.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 70 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g70__g71` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s624`, the merged state `PRE_first_tail_x15_r0_body.s625`,
the site template `PRE_first_tail_x15_r0_body.st70` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s626`: the merge.
The footprint's facts are in `SiteF70`, the compaction's in `SiteC70`, `SiteK70`, `SiteNa70`, `SiteNb70`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso70 : PRE_first_tail_x15_r0_body.st70.s0 = { PRE_first_tail_x15_r0_body.s624 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs70 : List Frame := PRE_first_tail_x15_r0_body.s624.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_70 : PRE_first_tail_x15_r0_body.S624.tab.length = 3071
kernel_rfl PRE_first_tail_x15_r0_body.tab0_70 : PRE_first_tail_x15_r0_body.st70.S0.tab = PRE_first_tail_x15_r0_body.S624.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws70 : List Nat := [2195, 2196]
kernel_rfl PRE_first_tail_x15_r0_body.fresh70 : (PRE_first_tail_x15_r0_body.S624.tab.all fun e => PRE_first_tail_x15_r0_body.ws70.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S624.oracle.all fun q => PRE_first_tail_x15_r0_body.ws70.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab70 : PRE_first_tail_x15_r0_body.S625.tab = PRE_first_tail_x15_r0_body.S624.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws70
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen70 : PRE_first_tail_x15_r0_body.st70.S2.tab.length - PRE_first_tail_x15_r0_body.st70.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged70`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap70 : PRE_first_tail_x15_r0_body.s625.heap = PRE_first_tail_x15_r0_body.st70.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext70 : PRE_first_tail_x15_r0_body.s625.next = PRE_first_tail_x15_r0_body.st70.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl70 : PRE_first_tail_x15_r0_body.s625.ctl = PRE_first_tail_x15_r0_body.st70.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack70 : PRE_first_tail_x15_r0_body.s625.stack = PRE_first_tail_x15_r0_body.st70.s2.stack ++ PRE_first_tail_x15_r0_body.s624.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs70 : PRE_first_tail_x15_r0_body.s625.jobs = PRE_first_tail_x15_r0_body.st70.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi70 : PRE_first_tail_x15_r0_body.s625.ffi = PRE_first_tail_x15_r0_body.st70.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace70 : PRE_first_tail_x15_r0_body.s625.trace = PRE_first_tail_x15_r0_body.st70.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores70 : PRE_first_tail_x15_r0_body.s625.stores = PRE_first_tail_x15_r0_body.st70.s2.stores

end Host.Load.Run.Tpl
