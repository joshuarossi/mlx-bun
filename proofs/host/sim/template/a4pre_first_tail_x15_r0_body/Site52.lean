import host.sim.template.a4pre_first_tail_x15_r0_body.H16
import host.sim.template.a4pre_first_tail_x15_r0_body.st52.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 52 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g52__g53` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s513`, the merged state `PRE_first_tail_x15_r0_body.s514`,
the site template `PRE_first_tail_x15_r0_body.st52` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s515`: the merge.
The footprint's facts are in `SiteF52`, the compaction's in `SiteC52`, `SiteK52`, `SiteNa52`, `SiteNb52`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso52 : PRE_first_tail_x15_r0_body.st52.s0 = { PRE_first_tail_x15_r0_body.s513 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs52 : List Frame := PRE_first_tail_x15_r0_body.s513.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_52 : PRE_first_tail_x15_r0_body.S513.tab.length = 2303
kernel_rfl PRE_first_tail_x15_r0_body.tab0_52 : PRE_first_tail_x15_r0_body.st52.S0.tab = PRE_first_tail_x15_r0_body.S513.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws52 : List Nat := [1905, 1906]
kernel_rfl PRE_first_tail_x15_r0_body.fresh52 : (PRE_first_tail_x15_r0_body.S513.tab.all fun e => PRE_first_tail_x15_r0_body.ws52.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S513.oracle.all fun q => PRE_first_tail_x15_r0_body.ws52.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab52 : PRE_first_tail_x15_r0_body.S514.tab = PRE_first_tail_x15_r0_body.S513.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws52
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen52 : PRE_first_tail_x15_r0_body.st52.S2.tab.length - PRE_first_tail_x15_r0_body.st52.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged52`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap52 : PRE_first_tail_x15_r0_body.s514.heap = PRE_first_tail_x15_r0_body.st52.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext52 : PRE_first_tail_x15_r0_body.s514.next = PRE_first_tail_x15_r0_body.st52.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl52 : PRE_first_tail_x15_r0_body.s514.ctl = PRE_first_tail_x15_r0_body.st52.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack52 : PRE_first_tail_x15_r0_body.s514.stack = PRE_first_tail_x15_r0_body.st52.s2.stack ++ PRE_first_tail_x15_r0_body.s513.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs52 : PRE_first_tail_x15_r0_body.s514.jobs = PRE_first_tail_x15_r0_body.st52.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi52 : PRE_first_tail_x15_r0_body.s514.ffi = PRE_first_tail_x15_r0_body.st52.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace52 : PRE_first_tail_x15_r0_body.s514.trace = PRE_first_tail_x15_r0_body.st52.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores52 : PRE_first_tail_x15_r0_body.s514.stores = PRE_first_tail_x15_r0_body.st52.s2.stores

end Host.Load.Run.Tpl
