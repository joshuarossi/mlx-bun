import host.sim.template.a4pre_first_tail_x15_r0_body.H52
import host.sim.template.a4pre_first_tail_x15_r0_body.st190.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 190 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g190__g191` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1674`, the merged state `PRE_first_tail_x15_r0_body.s1675`,
the site template `PRE_first_tail_x15_r0_body.st190` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1676`: the merge.
The footprint's facts are in `SiteF190`, the compaction's in `SiteC190`, `SiteK190`, `SiteNa190`, `SiteNb190`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso190 : PRE_first_tail_x15_r0_body.st190.s0 = { PRE_first_tail_x15_r0_body.s1674 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs190 : List Frame := PRE_first_tail_x15_r0_body.s1674.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_190 : PRE_first_tail_x15_r0_body.S1674.tab.length = 8201
kernel_rfl PRE_first_tail_x15_r0_body.tab0_190 : PRE_first_tail_x15_r0_body.st190.S0.tab = PRE_first_tail_x15_r0_body.S1674.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws190 : List Nat := [4227, 4228]
kernel_rfl PRE_first_tail_x15_r0_body.fresh190 : (PRE_first_tail_x15_r0_body.S1674.tab.all fun e => PRE_first_tail_x15_r0_body.ws190.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1674.oracle.all fun q => PRE_first_tail_x15_r0_body.ws190.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab190 : PRE_first_tail_x15_r0_body.S1675.tab = PRE_first_tail_x15_r0_body.S1674.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws190
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen190 : PRE_first_tail_x15_r0_body.st190.S2.tab.length - PRE_first_tail_x15_r0_body.st190.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged190`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap190 : PRE_first_tail_x15_r0_body.s1675.heap = PRE_first_tail_x15_r0_body.st190.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext190 : PRE_first_tail_x15_r0_body.s1675.next = PRE_first_tail_x15_r0_body.st190.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl190 : PRE_first_tail_x15_r0_body.s1675.ctl = PRE_first_tail_x15_r0_body.st190.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack190 : PRE_first_tail_x15_r0_body.s1675.stack = PRE_first_tail_x15_r0_body.st190.s2.stack ++ PRE_first_tail_x15_r0_body.s1674.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs190 : PRE_first_tail_x15_r0_body.s1675.jobs = PRE_first_tail_x15_r0_body.st190.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi190 : PRE_first_tail_x15_r0_body.s1675.ffi = PRE_first_tail_x15_r0_body.st190.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace190 : PRE_first_tail_x15_r0_body.s1675.trace = PRE_first_tail_x15_r0_body.st190.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores190 : PRE_first_tail_x15_r0_body.s1675.stores = PRE_first_tail_x15_r0_body.st190.s2.stores

end Host.Load.Run.Tpl
