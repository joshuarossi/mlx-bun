import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.a4pre_first_tail_x15_r0_body.st67.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 67 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g67__g68` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s600`, the merged state `PRE_first_tail_x15_r0_body.s601`,
the site template `PRE_first_tail_x15_r0_body.st67` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s602`: the merge.
The footprint's facts are in `SiteF67`, the compaction's in `SiteC67`, `SiteK67`, `SiteNa67`, `SiteNb67`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso67 : PRE_first_tail_x15_r0_body.st67.s0 = { PRE_first_tail_x15_r0_body.s600 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs67 : List Frame := PRE_first_tail_x15_r0_body.s600.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_67 : PRE_first_tail_x15_r0_body.S600.tab.length = 2945
kernel_rfl PRE_first_tail_x15_r0_body.tab0_67 : PRE_first_tail_x15_r0_body.st67.S0.tab = PRE_first_tail_x15_r0_body.S600.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws67 : List Nat := [2164, 2165]
kernel_rfl PRE_first_tail_x15_r0_body.fresh67 : (PRE_first_tail_x15_r0_body.S600.tab.all fun e => PRE_first_tail_x15_r0_body.ws67.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S600.oracle.all fun q => PRE_first_tail_x15_r0_body.ws67.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab67 : PRE_first_tail_x15_r0_body.S601.tab = PRE_first_tail_x15_r0_body.S600.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws67
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen67 : PRE_first_tail_x15_r0_body.st67.S2.tab.length - PRE_first_tail_x15_r0_body.st67.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged67`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap67 : PRE_first_tail_x15_r0_body.s601.heap = PRE_first_tail_x15_r0_body.st67.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext67 : PRE_first_tail_x15_r0_body.s601.next = PRE_first_tail_x15_r0_body.st67.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl67 : PRE_first_tail_x15_r0_body.s601.ctl = PRE_first_tail_x15_r0_body.st67.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack67 : PRE_first_tail_x15_r0_body.s601.stack = PRE_first_tail_x15_r0_body.st67.s2.stack ++ PRE_first_tail_x15_r0_body.s600.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs67 : PRE_first_tail_x15_r0_body.s601.jobs = PRE_first_tail_x15_r0_body.st67.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi67 : PRE_first_tail_x15_r0_body.s601.ffi = PRE_first_tail_x15_r0_body.st67.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace67 : PRE_first_tail_x15_r0_body.s601.trace = PRE_first_tail_x15_r0_body.st67.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores67 : PRE_first_tail_x15_r0_body.s601.stores = PRE_first_tail_x15_r0_body.st67.s2.stores

end Host.Load.Run.Tpl
