import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.st58.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 58 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g58__g59` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s570`, the merged state `PRE_first_tail_x15_r0_body.s571`,
the site template `PRE_first_tail_x15_r0_body.st58` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s572`: the merge.
The footprint's facts are in `SiteF58`, the compaction's in `SiteC58`, `SiteK58`, `SiteNa58`, `SiteNb58`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso58 : PRE_first_tail_x15_r0_body.st58.s0 = { PRE_first_tail_x15_r0_body.s570 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs58 : List Frame := PRE_first_tail_x15_r0_body.s570.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_58 : PRE_first_tail_x15_r0_body.S570.tab.length = 2558
kernel_rfl PRE_first_tail_x15_r0_body.tab0_58 : PRE_first_tail_x15_r0_body.st58.S0.tab = PRE_first_tail_x15_r0_body.S570.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws58 : List Nat := [2002, 2003]
kernel_rfl PRE_first_tail_x15_r0_body.fresh58 : (PRE_first_tail_x15_r0_body.S570.tab.all fun e => PRE_first_tail_x15_r0_body.ws58.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S570.oracle.all fun q => PRE_first_tail_x15_r0_body.ws58.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab58 : PRE_first_tail_x15_r0_body.S571.tab = PRE_first_tail_x15_r0_body.S570.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws58
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen58 : PRE_first_tail_x15_r0_body.st58.S2.tab.length - PRE_first_tail_x15_r0_body.st58.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged58`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap58 : PRE_first_tail_x15_r0_body.s571.heap = PRE_first_tail_x15_r0_body.st58.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext58 : PRE_first_tail_x15_r0_body.s571.next = PRE_first_tail_x15_r0_body.st58.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl58 : PRE_first_tail_x15_r0_body.s571.ctl = PRE_first_tail_x15_r0_body.st58.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack58 : PRE_first_tail_x15_r0_body.s571.stack = PRE_first_tail_x15_r0_body.st58.s2.stack ++ PRE_first_tail_x15_r0_body.s570.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs58 : PRE_first_tail_x15_r0_body.s571.jobs = PRE_first_tail_x15_r0_body.st58.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi58 : PRE_first_tail_x15_r0_body.s571.ffi = PRE_first_tail_x15_r0_body.st58.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace58 : PRE_first_tail_x15_r0_body.s571.trace = PRE_first_tail_x15_r0_body.st58.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores58 : PRE_first_tail_x15_r0_body.s571.stores = PRE_first_tail_x15_r0_body.st58.s2.stores

end Host.Load.Run.Tpl
