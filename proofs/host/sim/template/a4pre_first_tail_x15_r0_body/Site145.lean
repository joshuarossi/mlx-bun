import host.sim.template.a4pre_first_tail_x15_r0_body.H40
import host.sim.template.a4pre_first_tail_x15_r0_body.st145.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 145 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g145__g146` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1281`, the merged state `PRE_first_tail_x15_r0_body.s1282`,
the site template `PRE_first_tail_x15_r0_body.st145` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1283`: the merge.
The footprint's facts are in `SiteF145`, the compaction's in `SiteC145`, `SiteK145`, `SiteNa145`, `SiteNb145`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso145 : PRE_first_tail_x15_r0_body.st145.s0 = { PRE_first_tail_x15_r0_body.s1281 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs145 : List Frame := PRE_first_tail_x15_r0_body.s1281.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_145 : PRE_first_tail_x15_r0_body.S1281.tab.length = 6278
kernel_rfl PRE_first_tail_x15_r0_body.tab0_145 : PRE_first_tail_x15_r0_body.st145.S0.tab = PRE_first_tail_x15_r0_body.S1281.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws145 : List Nat := [3449, 3450]
kernel_rfl PRE_first_tail_x15_r0_body.fresh145 : (PRE_first_tail_x15_r0_body.S1281.tab.all fun e => PRE_first_tail_x15_r0_body.ws145.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1281.oracle.all fun q => PRE_first_tail_x15_r0_body.ws145.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab145 : PRE_first_tail_x15_r0_body.S1282.tab = PRE_first_tail_x15_r0_body.S1281.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws145
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen145 : PRE_first_tail_x15_r0_body.st145.S2.tab.length - PRE_first_tail_x15_r0_body.st145.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged145`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap145 : PRE_first_tail_x15_r0_body.s1282.heap = PRE_first_tail_x15_r0_body.st145.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext145 : PRE_first_tail_x15_r0_body.s1282.next = PRE_first_tail_x15_r0_body.st145.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl145 : PRE_first_tail_x15_r0_body.s1282.ctl = PRE_first_tail_x15_r0_body.st145.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack145 : PRE_first_tail_x15_r0_body.s1282.stack = PRE_first_tail_x15_r0_body.st145.s2.stack ++ PRE_first_tail_x15_r0_body.s1281.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs145 : PRE_first_tail_x15_r0_body.s1282.jobs = PRE_first_tail_x15_r0_body.st145.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi145 : PRE_first_tail_x15_r0_body.s1282.ffi = PRE_first_tail_x15_r0_body.st145.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace145 : PRE_first_tail_x15_r0_body.s1282.trace = PRE_first_tail_x15_r0_body.st145.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores145 : PRE_first_tail_x15_r0_body.s1282.stores = PRE_first_tail_x15_r0_body.st145.s2.stores

end Host.Load.Run.Tpl
