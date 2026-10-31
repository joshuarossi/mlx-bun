import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.st152.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 152 of chain `PRE_first_tail_x15_r0_body`: `plan__g152__g153` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1339`, the merged state `PRE_first_tail_x15_r0_body.s1340`,
the site template `PRE_first_tail_x15_r0_body.st152` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1341`: the merge.
The footprint's facts are in `SiteF152`, the compaction's in `SiteC152`, `SiteK152`, `SiteNa152`, `SiteNb152`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso152 : PRE_first_tail_x15_r0_body.st152.s0 = { PRE_first_tail_x15_r0_body.s1339 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs152 : List Frame := PRE_first_tail_x15_r0_body.s1339.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_152 : PRE_first_tail_x15_r0_body.S1339.tab.length = 6553
kernel_rfl PRE_first_tail_x15_r0_body.tab0_152 : PRE_first_tail_x15_r0_body.st152.S0.tab = PRE_first_tail_x15_r0_body.S1339.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws152 : List Nat := [3571, 3572, 3573]
kernel_rfl PRE_first_tail_x15_r0_body.fresh152 : (PRE_first_tail_x15_r0_body.S1339.tab.all fun e => PRE_first_tail_x15_r0_body.ws152.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1339.oracle.all fun q => PRE_first_tail_x15_r0_body.ws152.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab152 : PRE_first_tail_x15_r0_body.S1340.tab = PRE_first_tail_x15_r0_body.S1339.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws152
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen152 : PRE_first_tail_x15_r0_body.st152.S2.tab.length - PRE_first_tail_x15_r0_body.st152.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged152`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap152 : PRE_first_tail_x15_r0_body.s1340.heap = PRE_first_tail_x15_r0_body.st152.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext152 : PRE_first_tail_x15_r0_body.s1340.next = PRE_first_tail_x15_r0_body.st152.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl152 : PRE_first_tail_x15_r0_body.s1340.ctl = PRE_first_tail_x15_r0_body.st152.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack152 : PRE_first_tail_x15_r0_body.s1340.stack = PRE_first_tail_x15_r0_body.st152.s2.stack ++ PRE_first_tail_x15_r0_body.s1339.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs152 : PRE_first_tail_x15_r0_body.s1340.jobs = PRE_first_tail_x15_r0_body.st152.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi152 : PRE_first_tail_x15_r0_body.s1340.ffi = PRE_first_tail_x15_r0_body.st152.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace152 : PRE_first_tail_x15_r0_body.s1340.trace = PRE_first_tail_x15_r0_body.st152.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores152 : PRE_first_tail_x15_r0_body.s1340.stores = PRE_first_tail_x15_r0_body.st152.s2.stores

end Host.Load.Run.Tpl
