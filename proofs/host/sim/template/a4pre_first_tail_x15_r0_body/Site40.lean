import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.a4pre_first_tail_x15_r0_body.st40.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 40 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g40__g41` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s363`, the merged state `PRE_first_tail_x15_r0_body.s364`,
the site template `PRE_first_tail_x15_r0_body.st40` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s365`: the merge.
The footprint's facts are in `SiteF40`, the compaction's in `SiteC40`, `SiteK40`, `SiteNa40`, `SiteNb40`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso40 : PRE_first_tail_x15_r0_body.st40.s0 = { PRE_first_tail_x15_r0_body.s363 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs40 : List Frame := PRE_first_tail_x15_r0_body.s363.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_40 : PRE_first_tail_x15_r0_body.S363.tab.length = 1790
kernel_rfl PRE_first_tail_x15_r0_body.tab0_40 : PRE_first_tail_x15_r0_body.st40.S0.tab = PRE_first_tail_x15_r0_body.S363.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws40 : List Nat := [1694, 1695]
kernel_rfl PRE_first_tail_x15_r0_body.fresh40 : (PRE_first_tail_x15_r0_body.S363.tab.all fun e => PRE_first_tail_x15_r0_body.ws40.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S363.oracle.all fun q => PRE_first_tail_x15_r0_body.ws40.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab40 : PRE_first_tail_x15_r0_body.S364.tab = PRE_first_tail_x15_r0_body.S363.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws40
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen40 : PRE_first_tail_x15_r0_body.st40.S2.tab.length - PRE_first_tail_x15_r0_body.st40.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged40`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap40 : PRE_first_tail_x15_r0_body.s364.heap = PRE_first_tail_x15_r0_body.st40.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext40 : PRE_first_tail_x15_r0_body.s364.next = PRE_first_tail_x15_r0_body.st40.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl40 : PRE_first_tail_x15_r0_body.s364.ctl = PRE_first_tail_x15_r0_body.st40.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack40 : PRE_first_tail_x15_r0_body.s364.stack = PRE_first_tail_x15_r0_body.st40.s2.stack ++ PRE_first_tail_x15_r0_body.s363.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs40 : PRE_first_tail_x15_r0_body.s364.jobs = PRE_first_tail_x15_r0_body.st40.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi40 : PRE_first_tail_x15_r0_body.s364.ffi = PRE_first_tail_x15_r0_body.st40.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace40 : PRE_first_tail_x15_r0_body.s364.trace = PRE_first_tail_x15_r0_body.st40.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores40 : PRE_first_tail_x15_r0_body.s364.stores = PRE_first_tail_x15_r0_body.st40.s2.stores

end Host.Load.Run.Tpl
