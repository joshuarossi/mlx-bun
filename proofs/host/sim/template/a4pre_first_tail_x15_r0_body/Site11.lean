import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.a4pre_first_tail_x15_r0_body.st11.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 11 of chain `PRE_first_tail_x15_r0_body`: `plan__g11__g12` (`plan`), the call state `PRE_first_tail_x15_r0_body.s114`, the merged state `PRE_first_tail_x15_r0_body.s115`,
the site template `PRE_first_tail_x15_r0_body.st11` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s116`: the merge.
The footprint's facts are in `SiteF11`, the compaction's in `SiteC11`, `SiteK11`, `SiteNa11`, `SiteNb11`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso11 : PRE_first_tail_x15_r0_body.st11.s0 = { PRE_first_tail_x15_r0_body.s114 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs11 : List Frame := PRE_first_tail_x15_r0_body.s114.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_11 : PRE_first_tail_x15_r0_body.S114.tab.length = 523
kernel_rfl PRE_first_tail_x15_r0_body.tab0_11 : PRE_first_tail_x15_r0_body.st11.S0.tab = PRE_first_tail_x15_r0_body.S114.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws11 : List Nat := [1196, 1197, 1198]
kernel_rfl PRE_first_tail_x15_r0_body.fresh11 : (PRE_first_tail_x15_r0_body.S114.tab.all fun e => PRE_first_tail_x15_r0_body.ws11.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S114.oracle.all fun q => PRE_first_tail_x15_r0_body.ws11.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab11 : PRE_first_tail_x15_r0_body.S115.tab = PRE_first_tail_x15_r0_body.S114.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws11
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen11 : PRE_first_tail_x15_r0_body.st11.S2.tab.length - PRE_first_tail_x15_r0_body.st11.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged11`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap11 : PRE_first_tail_x15_r0_body.s115.heap = PRE_first_tail_x15_r0_body.st11.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext11 : PRE_first_tail_x15_r0_body.s115.next = PRE_first_tail_x15_r0_body.st11.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl11 : PRE_first_tail_x15_r0_body.s115.ctl = PRE_first_tail_x15_r0_body.st11.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack11 : PRE_first_tail_x15_r0_body.s115.stack = PRE_first_tail_x15_r0_body.st11.s2.stack ++ PRE_first_tail_x15_r0_body.s114.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs11 : PRE_first_tail_x15_r0_body.s115.jobs = PRE_first_tail_x15_r0_body.st11.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi11 : PRE_first_tail_x15_r0_body.s115.ffi = PRE_first_tail_x15_r0_body.st11.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace11 : PRE_first_tail_x15_r0_body.s115.trace = PRE_first_tail_x15_r0_body.st11.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores11 : PRE_first_tail_x15_r0_body.s115.stores = PRE_first_tail_x15_r0_body.st11.s2.stores

end Host.Load.Run.Tpl
