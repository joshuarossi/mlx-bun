import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.a4pre_first_tail_x15_r0_body.st122.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 122 of chain `PRE_first_tail_x15_r0_body`: `plan__g122__g123` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1178`, the merged state `PRE_first_tail_x15_r0_body.s1179`,
the site template `PRE_first_tail_x15_r0_body.st122` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1180`: the merge.
The footprint's facts are in `SiteF122`, the compaction's in `SiteC122`, `SiteK122`, `SiteNa122`, `SiteNb122`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso122 : PRE_first_tail_x15_r0_body.st122.s0 = { PRE_first_tail_x15_r0_body.s1178 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs122 : List Frame := PRE_first_tail_x15_r0_body.s1178.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_122 : PRE_first_tail_x15_r0_body.S1178.tab.length = 5269
kernel_rfl PRE_first_tail_x15_r0_body.tab0_122 : PRE_first_tail_x15_r0_body.st122.S0.tab = PRE_first_tail_x15_r0_body.S1178.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws122 : List Nat := [3047, 3048, 3049]
kernel_rfl PRE_first_tail_x15_r0_body.fresh122 : (PRE_first_tail_x15_r0_body.S1178.tab.all fun e => PRE_first_tail_x15_r0_body.ws122.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1178.oracle.all fun q => PRE_first_tail_x15_r0_body.ws122.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab122 : PRE_first_tail_x15_r0_body.S1179.tab = PRE_first_tail_x15_r0_body.S1178.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws122
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen122 : PRE_first_tail_x15_r0_body.st122.S2.tab.length - PRE_first_tail_x15_r0_body.st122.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged122`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap122 : PRE_first_tail_x15_r0_body.s1179.heap = PRE_first_tail_x15_r0_body.st122.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext122 : PRE_first_tail_x15_r0_body.s1179.next = PRE_first_tail_x15_r0_body.st122.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl122 : PRE_first_tail_x15_r0_body.s1179.ctl = PRE_first_tail_x15_r0_body.st122.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack122 : PRE_first_tail_x15_r0_body.s1179.stack = PRE_first_tail_x15_r0_body.st122.s2.stack ++ PRE_first_tail_x15_r0_body.s1178.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs122 : PRE_first_tail_x15_r0_body.s1179.jobs = PRE_first_tail_x15_r0_body.st122.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi122 : PRE_first_tail_x15_r0_body.s1179.ffi = PRE_first_tail_x15_r0_body.st122.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace122 : PRE_first_tail_x15_r0_body.s1179.trace = PRE_first_tail_x15_r0_body.st122.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores122 : PRE_first_tail_x15_r0_body.s1179.stores = PRE_first_tail_x15_r0_body.st122.s2.stores

end Host.Load.Run.Tpl
