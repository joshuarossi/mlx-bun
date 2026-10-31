import host.sim.template.a4pre_first_tail_x15_r0_body.H2
import host.sim.template.a4pre_first_tail_x15_r0_body.st7.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 7 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g7__g8` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s82`, the merged state `PRE_first_tail_x15_r0_body.s83`,
the site template `PRE_first_tail_x15_r0_body.st7` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s84`: the merge.
The footprint's facts are in `SiteF7`, the compaction's in `SiteC7`, `SiteK7`, `SiteNa7`, `SiteNb7`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso7 : PRE_first_tail_x15_r0_body.st7.s0 = { PRE_first_tail_x15_r0_body.s82 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs7 : List Frame := PRE_first_tail_x15_r0_body.s82.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_7 : PRE_first_tail_x15_r0_body.S82.tab.length = 380
kernel_rfl PRE_first_tail_x15_r0_body.tab0_7 : PRE_first_tail_x15_r0_body.st7.S0.tab = PRE_first_tail_x15_r0_body.S82.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws7 : List Nat := [1163, 1164]
kernel_rfl PRE_first_tail_x15_r0_body.fresh7 : (PRE_first_tail_x15_r0_body.S82.tab.all fun e => PRE_first_tail_x15_r0_body.ws7.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S82.oracle.all fun q => PRE_first_tail_x15_r0_body.ws7.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab7 : PRE_first_tail_x15_r0_body.S83.tab = PRE_first_tail_x15_r0_body.S82.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws7
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen7 : PRE_first_tail_x15_r0_body.st7.S2.tab.length - PRE_first_tail_x15_r0_body.st7.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged7`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap7 : PRE_first_tail_x15_r0_body.s83.heap = PRE_first_tail_x15_r0_body.st7.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext7 : PRE_first_tail_x15_r0_body.s83.next = PRE_first_tail_x15_r0_body.st7.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl7 : PRE_first_tail_x15_r0_body.s83.ctl = PRE_first_tail_x15_r0_body.st7.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack7 : PRE_first_tail_x15_r0_body.s83.stack = PRE_first_tail_x15_r0_body.st7.s2.stack ++ PRE_first_tail_x15_r0_body.s82.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs7 : PRE_first_tail_x15_r0_body.s83.jobs = PRE_first_tail_x15_r0_body.st7.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi7 : PRE_first_tail_x15_r0_body.s83.ffi = PRE_first_tail_x15_r0_body.st7.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace7 : PRE_first_tail_x15_r0_body.s83.trace = PRE_first_tail_x15_r0_body.st7.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores7 : PRE_first_tail_x15_r0_body.s83.stores = PRE_first_tail_x15_r0_body.st7.s2.stores

end Host.Load.Run.Tpl
