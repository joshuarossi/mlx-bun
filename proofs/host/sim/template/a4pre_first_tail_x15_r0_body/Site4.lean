import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.a4pre_first_tail_x15_r0_body.st4.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 4 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g4__g5` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s53`, the merged state `PRE_first_tail_x15_r0_body.s54`,
the site template `PRE_first_tail_x15_r0_body.st4` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s55`: the merge.
The footprint's facts are in `SiteF4`, the compaction's in `SiteC4`, `SiteK4`, `SiteNa4`, `SiteNb4`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso4 : PRE_first_tail_x15_r0_body.st4.s0 = { PRE_first_tail_x15_r0_body.s53 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs4 : List Frame := PRE_first_tail_x15_r0_body.s53.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_4 : PRE_first_tail_x15_r0_body.S53.tab.length = 251
kernel_rfl PRE_first_tail_x15_r0_body.tab0_4 : PRE_first_tail_x15_r0_body.st4.S0.tab = PRE_first_tail_x15_r0_body.S53.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws4 : List Nat := [1109, 1110]
kernel_rfl PRE_first_tail_x15_r0_body.fresh4 : (PRE_first_tail_x15_r0_body.S53.tab.all fun e => PRE_first_tail_x15_r0_body.ws4.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S53.oracle.all fun q => PRE_first_tail_x15_r0_body.ws4.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab4 : PRE_first_tail_x15_r0_body.S54.tab = PRE_first_tail_x15_r0_body.S53.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws4
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen4 : PRE_first_tail_x15_r0_body.st4.S2.tab.length - PRE_first_tail_x15_r0_body.st4.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged4`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap4 : PRE_first_tail_x15_r0_body.s54.heap = PRE_first_tail_x15_r0_body.st4.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext4 : PRE_first_tail_x15_r0_body.s54.next = PRE_first_tail_x15_r0_body.st4.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl4 : PRE_first_tail_x15_r0_body.s54.ctl = PRE_first_tail_x15_r0_body.st4.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack4 : PRE_first_tail_x15_r0_body.s54.stack = PRE_first_tail_x15_r0_body.st4.s2.stack ++ PRE_first_tail_x15_r0_body.s53.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs4 : PRE_first_tail_x15_r0_body.s54.jobs = PRE_first_tail_x15_r0_body.st4.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi4 : PRE_first_tail_x15_r0_body.s54.ffi = PRE_first_tail_x15_r0_body.st4.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace4 : PRE_first_tail_x15_r0_body.s54.trace = PRE_first_tail_x15_r0_body.st4.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores4 : PRE_first_tail_x15_r0_body.s54.stores = PRE_first_tail_x15_r0_body.st4.s2.stores

end Host.Load.Run.Tpl
