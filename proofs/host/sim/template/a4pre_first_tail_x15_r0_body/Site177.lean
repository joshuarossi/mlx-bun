import host.sim.template.a4pre_first_tail_x15_r0_body.H53
import host.sim.template.a4pre_first_tail_x15_r0_body.st177.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 177 of chain `PRE_first_tail_x15_r0_body`: `kvW__g177__g178` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1712`, the merged state `PRE_first_tail_x15_r0_body.s1713`,
the site template `PRE_first_tail_x15_r0_body.st177` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1714`: the merge.
The footprint's facts are in `SiteF177`, the compaction's in `SiteC177`, `SiteK177`, `SiteNa177`, `SiteNb177`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso177 : PRE_first_tail_x15_r0_body.st177.s0 = { PRE_first_tail_x15_r0_body.s1712 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs177 : List Frame := PRE_first_tail_x15_r0_body.s1712.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_177 : PRE_first_tail_x15_r0_body.S1712.tab.length = 7656
kernel_rfl PRE_first_tail_x15_r0_body.tab0_177 : PRE_first_tail_x15_r0_body.st177.S0.tab = PRE_first_tail_x15_r0_body.S1712.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws177 : List Nat := [3990, 3991, 3992, 3993, 3994, 3995, 3996, 3997, 3998, 3999, 4000, 4001, 4002, 4003, 4004, 4005, 4006]
kernel_rfl PRE_first_tail_x15_r0_body.fresh177 : (PRE_first_tail_x15_r0_body.S1712.tab.all fun e => PRE_first_tail_x15_r0_body.ws177.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1712.oracle.all fun q => PRE_first_tail_x15_r0_body.ws177.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab177 : PRE_first_tail_x15_r0_body.S1713.tab = PRE_first_tail_x15_r0_body.S1712.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws177
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen177 : PRE_first_tail_x15_r0_body.st177.S3.tab.length - PRE_first_tail_x15_r0_body.st177.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged177`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap177 : PRE_first_tail_x15_r0_body.s1713.heap = PRE_first_tail_x15_r0_body.st177.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext177 : PRE_first_tail_x15_r0_body.s1713.next = PRE_first_tail_x15_r0_body.st177.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl177 : PRE_first_tail_x15_r0_body.s1713.ctl = PRE_first_tail_x15_r0_body.st177.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack177 : PRE_first_tail_x15_r0_body.s1713.stack = PRE_first_tail_x15_r0_body.st177.s3.stack ++ PRE_first_tail_x15_r0_body.s1712.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs177 : PRE_first_tail_x15_r0_body.s1713.jobs = PRE_first_tail_x15_r0_body.st177.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi177 : PRE_first_tail_x15_r0_body.s1713.ffi = PRE_first_tail_x15_r0_body.st177.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace177 : PRE_first_tail_x15_r0_body.s1713.trace = PRE_first_tail_x15_r0_body.st177.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores177 : PRE_first_tail_x15_r0_body.s1713.stores = PRE_first_tail_x15_r0_body.st177.s3.stores

end Host.Load.Run.Tpl
