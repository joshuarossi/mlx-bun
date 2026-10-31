import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.a4pre_first_tail_x15_r0_body.st160.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 160 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g160__g161` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1548`, the merged state `PRE_first_tail_x15_r0_body.s1549`,
the site template `PRE_first_tail_x15_r0_body.st160` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1550`: the merge.
The footprint's facts are in `SiteF160`, the compaction's in `SiteC160`, `SiteK160`, `SiteNa160`, `SiteNb160`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso160 : PRE_first_tail_x15_r0_body.st160.s0 = { PRE_first_tail_x15_r0_body.s1548 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs160 : List Frame := PRE_first_tail_x15_r0_body.s1548.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_160 : PRE_first_tail_x15_r0_body.S1548.tab.length = 6920
kernel_rfl PRE_first_tail_x15_r0_body.tab0_160 : PRE_first_tail_x15_r0_body.st160.S0.tab = PRE_first_tail_x15_r0_body.S1548.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws160 : List Nat := [3708, 3709]
kernel_rfl PRE_first_tail_x15_r0_body.fresh160 : (PRE_first_tail_x15_r0_body.S1548.tab.all fun e => PRE_first_tail_x15_r0_body.ws160.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1548.oracle.all fun q => PRE_first_tail_x15_r0_body.ws160.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab160 : PRE_first_tail_x15_r0_body.S1549.tab = PRE_first_tail_x15_r0_body.S1548.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws160
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen160 : PRE_first_tail_x15_r0_body.st160.S2.tab.length - PRE_first_tail_x15_r0_body.st160.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged160`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap160 : PRE_first_tail_x15_r0_body.s1549.heap = PRE_first_tail_x15_r0_body.st160.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext160 : PRE_first_tail_x15_r0_body.s1549.next = PRE_first_tail_x15_r0_body.st160.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl160 : PRE_first_tail_x15_r0_body.s1549.ctl = PRE_first_tail_x15_r0_body.st160.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack160 : PRE_first_tail_x15_r0_body.s1549.stack = PRE_first_tail_x15_r0_body.st160.s2.stack ++ PRE_first_tail_x15_r0_body.s1548.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs160 : PRE_first_tail_x15_r0_body.s1549.jobs = PRE_first_tail_x15_r0_body.st160.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi160 : PRE_first_tail_x15_r0_body.s1549.ffi = PRE_first_tail_x15_r0_body.st160.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace160 : PRE_first_tail_x15_r0_body.s1549.trace = PRE_first_tail_x15_r0_body.st160.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores160 : PRE_first_tail_x15_r0_body.s1549.stores = PRE_first_tail_x15_r0_body.st160.s2.stores

end Host.Load.Run.Tpl
