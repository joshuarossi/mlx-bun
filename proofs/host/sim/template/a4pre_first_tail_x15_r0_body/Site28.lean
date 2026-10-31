import host.sim.template.a4pre_first_tail_x15_r0_body.H8
import host.sim.template.a4pre_first_tail_x15_r0_body.st28.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 28 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g28__g29` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s283`, the merged state `PRE_first_tail_x15_r0_body.s284`,
the site template `PRE_first_tail_x15_r0_body.st28` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s285`: the merge.
The footprint's facts are in `SiteF28`, the compaction's in `SiteC28`, `SiteK28`, `SiteNa28`, `SiteNb28`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso28 : PRE_first_tail_x15_r0_body.st28.s0 = { PRE_first_tail_x15_r0_body.s283 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs28 : List Frame := PRE_first_tail_x15_r0_body.s283.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_28 : PRE_first_tail_x15_r0_body.S283.tab.length = 1277
kernel_rfl PRE_first_tail_x15_r0_body.tab0_28 : PRE_first_tail_x15_r0_body.st28.S0.tab = PRE_first_tail_x15_r0_body.S283.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws28 : List Nat := [1495, 1496]
kernel_rfl PRE_first_tail_x15_r0_body.fresh28 : (PRE_first_tail_x15_r0_body.S283.tab.all fun e => PRE_first_tail_x15_r0_body.ws28.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S283.oracle.all fun q => PRE_first_tail_x15_r0_body.ws28.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab28 : PRE_first_tail_x15_r0_body.S284.tab = PRE_first_tail_x15_r0_body.S283.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws28
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen28 : PRE_first_tail_x15_r0_body.st28.S2.tab.length - PRE_first_tail_x15_r0_body.st28.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged28`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap28 : PRE_first_tail_x15_r0_body.s284.heap = PRE_first_tail_x15_r0_body.st28.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext28 : PRE_first_tail_x15_r0_body.s284.next = PRE_first_tail_x15_r0_body.st28.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl28 : PRE_first_tail_x15_r0_body.s284.ctl = PRE_first_tail_x15_r0_body.st28.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack28 : PRE_first_tail_x15_r0_body.s284.stack = PRE_first_tail_x15_r0_body.st28.s2.stack ++ PRE_first_tail_x15_r0_body.s283.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs28 : PRE_first_tail_x15_r0_body.s284.jobs = PRE_first_tail_x15_r0_body.st28.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi28 : PRE_first_tail_x15_r0_body.s284.ffi = PRE_first_tail_x15_r0_body.st28.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace28 : PRE_first_tail_x15_r0_body.s284.trace = PRE_first_tail_x15_r0_body.st28.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores28 : PRE_first_tail_x15_r0_body.s284.stores = PRE_first_tail_x15_r0_body.st28.s2.stores

end Host.Load.Run.Tpl
