import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.st128.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 128 of chain `PRE_first_tail_x15_r0_body`: `plan__g128__g129` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1129`, the merged state `PRE_first_tail_x15_r0_body.s1130`,
the site template `PRE_first_tail_x15_r0_body.st128` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1131`: the merge.
The footprint's facts are in `SiteF128`, the compaction's in `SiteC128`, `SiteK128`, `SiteNa128`, `SiteNb128`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso128 : PRE_first_tail_x15_r0_body.st128.s0 = { PRE_first_tail_x15_r0_body.s1129 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs128 : List Frame := PRE_first_tail_x15_r0_body.s1129.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_128 : PRE_first_tail_x15_r0_body.S1129.tab.length = 5527
kernel_rfl PRE_first_tail_x15_r0_body.tab0_128 : PRE_first_tail_x15_r0_body.st128.S0.tab = PRE_first_tail_x15_r0_body.S1129.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws128 : List Nat := [3155, 3156, 3157]
kernel_rfl PRE_first_tail_x15_r0_body.fresh128 : (PRE_first_tail_x15_r0_body.S1129.tab.all fun e => PRE_first_tail_x15_r0_body.ws128.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1129.oracle.all fun q => PRE_first_tail_x15_r0_body.ws128.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab128 : PRE_first_tail_x15_r0_body.S1130.tab = PRE_first_tail_x15_r0_body.S1129.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws128
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen128 : PRE_first_tail_x15_r0_body.st128.S2.tab.length - PRE_first_tail_x15_r0_body.st128.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged128`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap128 : PRE_first_tail_x15_r0_body.s1130.heap = PRE_first_tail_x15_r0_body.st128.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext128 : PRE_first_tail_x15_r0_body.s1130.next = PRE_first_tail_x15_r0_body.st128.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl128 : PRE_first_tail_x15_r0_body.s1130.ctl = PRE_first_tail_x15_r0_body.st128.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack128 : PRE_first_tail_x15_r0_body.s1130.stack = PRE_first_tail_x15_r0_body.st128.s2.stack ++ PRE_first_tail_x15_r0_body.s1129.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs128 : PRE_first_tail_x15_r0_body.s1130.jobs = PRE_first_tail_x15_r0_body.st128.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi128 : PRE_first_tail_x15_r0_body.s1130.ffi = PRE_first_tail_x15_r0_body.st128.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace128 : PRE_first_tail_x15_r0_body.s1130.trace = PRE_first_tail_x15_r0_body.st128.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores128 : PRE_first_tail_x15_r0_body.s1130.stores = PRE_first_tail_x15_r0_body.st128.s2.stores

end Host.Load.Run.Tpl
