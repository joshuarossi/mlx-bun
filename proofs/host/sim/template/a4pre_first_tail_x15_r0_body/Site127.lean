import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.st127.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 127 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g127__g128` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1125`, the merged state `PRE_first_tail_x15_r0_body.s1126`,
the site template `PRE_first_tail_x15_r0_body.st127` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1127`: the merge.
The footprint's facts are in `SiteF127`, the compaction's in `SiteC127`, `SiteK127`, `SiteNa127`, `SiteNb127`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso127 : PRE_first_tail_x15_r0_body.st127.s0 = { PRE_first_tail_x15_r0_body.s1125 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs127 : List Frame := PRE_first_tail_x15_r0_body.s1125.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_127 : PRE_first_tail_x15_r0_body.S1125.tab.length = 5510
kernel_rfl PRE_first_tail_x15_r0_body.tab0_127 : PRE_first_tail_x15_r0_body.st127.S0.tab = PRE_first_tail_x15_r0_body.S1125.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws127 : List Nat := [3153, 3154]
kernel_rfl PRE_first_tail_x15_r0_body.fresh127 : (PRE_first_tail_x15_r0_body.S1125.tab.all fun e => PRE_first_tail_x15_r0_body.ws127.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1125.oracle.all fun q => PRE_first_tail_x15_r0_body.ws127.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab127 : PRE_first_tail_x15_r0_body.S1126.tab = PRE_first_tail_x15_r0_body.S1125.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws127
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen127 : PRE_first_tail_x15_r0_body.st127.S2.tab.length - PRE_first_tail_x15_r0_body.st127.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged127`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap127 : PRE_first_tail_x15_r0_body.s1126.heap = PRE_first_tail_x15_r0_body.st127.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext127 : PRE_first_tail_x15_r0_body.s1126.next = PRE_first_tail_x15_r0_body.st127.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl127 : PRE_first_tail_x15_r0_body.s1126.ctl = PRE_first_tail_x15_r0_body.st127.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack127 : PRE_first_tail_x15_r0_body.s1126.stack = PRE_first_tail_x15_r0_body.st127.s2.stack ++ PRE_first_tail_x15_r0_body.s1125.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs127 : PRE_first_tail_x15_r0_body.s1126.jobs = PRE_first_tail_x15_r0_body.st127.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi127 : PRE_first_tail_x15_r0_body.s1126.ffi = PRE_first_tail_x15_r0_body.st127.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace127 : PRE_first_tail_x15_r0_body.s1126.trace = PRE_first_tail_x15_r0_body.st127.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores127 : PRE_first_tail_x15_r0_body.s1126.stores = PRE_first_tail_x15_r0_body.st127.s2.stores

end Host.Load.Run.Tpl
