import host.sim.template.a4pre_first_tail_x15_r0_body.H52
import host.sim.template.a4pre_first_tail_x15_r0_body.st173.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 173 of chain `PRE_first_tail_x15_r0_body`: `plan__g173__g174` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1667`, the merged state `PRE_first_tail_x15_r0_body.s1668`,
the site template `PRE_first_tail_x15_r0_body.st173` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1669`: the merge.
The footprint's facts are in `SiteF173`, the compaction's in `SiteC173`, `SiteK173`, `SiteNa173`, `SiteNb173`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso173 : PRE_first_tail_x15_r0_body.st173.s0 = { PRE_first_tail_x15_r0_body.s1667 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs173 : List Frame := PRE_first_tail_x15_r0_body.s1667.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_173 : PRE_first_tail_x15_r0_body.S1667.tab.length = 7450
kernel_rfl PRE_first_tail_x15_r0_body.tab0_173 : PRE_first_tail_x15_r0_body.st173.S0.tab = PRE_first_tail_x15_r0_body.S1667.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws173 : List Nat := [3921, 3922, 3923, 3924, 3925, 3926, 3927, 3928, 3929]
kernel_rfl PRE_first_tail_x15_r0_body.fresh173 : (PRE_first_tail_x15_r0_body.S1667.tab.all fun e => PRE_first_tail_x15_r0_body.ws173.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1667.oracle.all fun q => PRE_first_tail_x15_r0_body.ws173.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab173 : PRE_first_tail_x15_r0_body.S1668.tab = PRE_first_tail_x15_r0_body.S1667.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws173
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen173 : PRE_first_tail_x15_r0_body.st173.S2.tab.length - PRE_first_tail_x15_r0_body.st173.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged173`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap173 : PRE_first_tail_x15_r0_body.s1668.heap = PRE_first_tail_x15_r0_body.st173.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext173 : PRE_first_tail_x15_r0_body.s1668.next = PRE_first_tail_x15_r0_body.st173.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl173 : PRE_first_tail_x15_r0_body.s1668.ctl = PRE_first_tail_x15_r0_body.st173.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack173 : PRE_first_tail_x15_r0_body.s1668.stack = PRE_first_tail_x15_r0_body.st173.s2.stack ++ PRE_first_tail_x15_r0_body.s1667.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs173 : PRE_first_tail_x15_r0_body.s1668.jobs = PRE_first_tail_x15_r0_body.st173.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi173 : PRE_first_tail_x15_r0_body.s1668.ffi = PRE_first_tail_x15_r0_body.st173.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace173 : PRE_first_tail_x15_r0_body.s1668.trace = PRE_first_tail_x15_r0_body.st173.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores173 : PRE_first_tail_x15_r0_body.s1668.stores = PRE_first_tail_x15_r0_body.st173.s2.stores

end Host.Load.Run.Tpl
