import host.sim.template.a4pre_first_tail_x15_r0_body.H22
import host.sim.template.a4pre_first_tail_x15_r0_body.st82.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 82 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g82__g83` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s729`, the merged state `PRE_first_tail_x15_r0_body.s730`,
the site template `PRE_first_tail_x15_r0_body.st82` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s731`: the merge.
The footprint's facts are in `SiteF82`, the compaction's in `SiteC82`, `SiteK82`, `SiteNa82`, `SiteNb82`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso82 : PRE_first_tail_x15_r0_body.st82.s0 = { PRE_first_tail_x15_r0_body.s729 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs82 : List Frame := PRE_first_tail_x15_r0_body.s729.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_82 : PRE_first_tail_x15_r0_body.S729.tab.length = 3584
kernel_rfl PRE_first_tail_x15_r0_body.tab0_82 : PRE_first_tail_x15_r0_body.st82.S0.tab = PRE_first_tail_x15_r0_body.S729.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws82 : List Nat := [2388, 2389]
kernel_rfl PRE_first_tail_x15_r0_body.fresh82 : (PRE_first_tail_x15_r0_body.S729.tab.all fun e => PRE_first_tail_x15_r0_body.ws82.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S729.oracle.all fun q => PRE_first_tail_x15_r0_body.ws82.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab82 : PRE_first_tail_x15_r0_body.S730.tab = PRE_first_tail_x15_r0_body.S729.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws82
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen82 : PRE_first_tail_x15_r0_body.st82.S2.tab.length - PRE_first_tail_x15_r0_body.st82.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged82`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap82 : PRE_first_tail_x15_r0_body.s730.heap = PRE_first_tail_x15_r0_body.st82.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext82 : PRE_first_tail_x15_r0_body.s730.next = PRE_first_tail_x15_r0_body.st82.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl82 : PRE_first_tail_x15_r0_body.s730.ctl = PRE_first_tail_x15_r0_body.st82.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack82 : PRE_first_tail_x15_r0_body.s730.stack = PRE_first_tail_x15_r0_body.st82.s2.stack ++ PRE_first_tail_x15_r0_body.s729.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs82 : PRE_first_tail_x15_r0_body.s730.jobs = PRE_first_tail_x15_r0_body.st82.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi82 : PRE_first_tail_x15_r0_body.s730.ffi = PRE_first_tail_x15_r0_body.st82.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace82 : PRE_first_tail_x15_r0_body.s730.trace = PRE_first_tail_x15_r0_body.st82.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores82 : PRE_first_tail_x15_r0_body.s730.stores = PRE_first_tail_x15_r0_body.st82.s2.stores

end Host.Load.Run.Tpl
