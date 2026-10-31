import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.st151.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 151 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g151__g152` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1335`, the merged state `PRE_first_tail_x15_r0_body.s1336`,
the site template `PRE_first_tail_x15_r0_body.st151` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1337`: the merge.
The footprint's facts are in `SiteF151`, the compaction's in `SiteC151`, `SiteK151`, `SiteNa151`, `SiteNb151`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso151 : PRE_first_tail_x15_r0_body.st151.s0 = { PRE_first_tail_x15_r0_body.s1335 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs151 : List Frame := PRE_first_tail_x15_r0_body.s1335.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_151 : PRE_first_tail_x15_r0_body.S1335.tab.length = 6536
kernel_rfl PRE_first_tail_x15_r0_body.tab0_151 : PRE_first_tail_x15_r0_body.st151.S0.tab = PRE_first_tail_x15_r0_body.S1335.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws151 : List Nat := [3569, 3570]
kernel_rfl PRE_first_tail_x15_r0_body.fresh151 : (PRE_first_tail_x15_r0_body.S1335.tab.all fun e => PRE_first_tail_x15_r0_body.ws151.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1335.oracle.all fun q => PRE_first_tail_x15_r0_body.ws151.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab151 : PRE_first_tail_x15_r0_body.S1336.tab = PRE_first_tail_x15_r0_body.S1335.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws151
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen151 : PRE_first_tail_x15_r0_body.st151.S2.tab.length - PRE_first_tail_x15_r0_body.st151.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged151`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap151 : PRE_first_tail_x15_r0_body.s1336.heap = PRE_first_tail_x15_r0_body.st151.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext151 : PRE_first_tail_x15_r0_body.s1336.next = PRE_first_tail_x15_r0_body.st151.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl151 : PRE_first_tail_x15_r0_body.s1336.ctl = PRE_first_tail_x15_r0_body.st151.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack151 : PRE_first_tail_x15_r0_body.s1336.stack = PRE_first_tail_x15_r0_body.st151.s2.stack ++ PRE_first_tail_x15_r0_body.s1335.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs151 : PRE_first_tail_x15_r0_body.s1336.jobs = PRE_first_tail_x15_r0_body.st151.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi151 : PRE_first_tail_x15_r0_body.s1336.ffi = PRE_first_tail_x15_r0_body.st151.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace151 : PRE_first_tail_x15_r0_body.s1336.trace = PRE_first_tail_x15_r0_body.st151.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores151 : PRE_first_tail_x15_r0_body.s1336.stores = PRE_first_tail_x15_r0_body.st151.s2.stores

end Host.Load.Run.Tpl
