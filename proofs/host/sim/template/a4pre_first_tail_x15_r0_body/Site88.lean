import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.a4pre_first_tail_x15_r0_body.st88.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 88 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g88__g89` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s783`, the merged state `PRE_first_tail_x15_r0_body.s784`,
the site template `PRE_first_tail_x15_r0_body.st88` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s785`: the merge.
The footprint's facts are in `SiteF88`, the compaction's in `SiteC88`, `SiteK88`, `SiteNa88`, `SiteNb88`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso88 : PRE_first_tail_x15_r0_body.st88.s0 = { PRE_first_tail_x15_r0_body.s783 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs88 : List Frame := PRE_first_tail_x15_r0_body.s783.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_88 : PRE_first_tail_x15_r0_body.S783.tab.length = 3842
kernel_rfl PRE_first_tail_x15_r0_body.tab0_88 : PRE_first_tail_x15_r0_body.st88.S0.tab = PRE_first_tail_x15_r0_body.S783.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws88 : List Nat := [2496, 2497]
kernel_rfl PRE_first_tail_x15_r0_body.fresh88 : (PRE_first_tail_x15_r0_body.S783.tab.all fun e => PRE_first_tail_x15_r0_body.ws88.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S783.oracle.all fun q => PRE_first_tail_x15_r0_body.ws88.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab88 : PRE_first_tail_x15_r0_body.S784.tab = PRE_first_tail_x15_r0_body.S783.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws88
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen88 : PRE_first_tail_x15_r0_body.st88.S2.tab.length - PRE_first_tail_x15_r0_body.st88.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged88`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap88 : PRE_first_tail_x15_r0_body.s784.heap = PRE_first_tail_x15_r0_body.st88.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext88 : PRE_first_tail_x15_r0_body.s784.next = PRE_first_tail_x15_r0_body.st88.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl88 : PRE_first_tail_x15_r0_body.s784.ctl = PRE_first_tail_x15_r0_body.st88.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack88 : PRE_first_tail_x15_r0_body.s784.stack = PRE_first_tail_x15_r0_body.st88.s2.stack ++ PRE_first_tail_x15_r0_body.s783.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs88 : PRE_first_tail_x15_r0_body.s784.jobs = PRE_first_tail_x15_r0_body.st88.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi88 : PRE_first_tail_x15_r0_body.s784.ffi = PRE_first_tail_x15_r0_body.st88.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace88 : PRE_first_tail_x15_r0_body.s784.trace = PRE_first_tail_x15_r0_body.st88.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores88 : PRE_first_tail_x15_r0_body.s784.stores = PRE_first_tail_x15_r0_body.st88.s2.stores

end Host.Load.Run.Tpl
