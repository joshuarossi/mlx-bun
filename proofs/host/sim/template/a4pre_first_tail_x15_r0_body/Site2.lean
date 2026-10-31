import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st2.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `PRE_first_tail_x15_r0_body`: `plan__g2__g3` (`plan`), the call state `PRE_first_tail_x15_r0_body.s28`, the merged state `PRE_first_tail_x15_r0_body.s29`,
the site template `PRE_first_tail_x15_r0_body.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s30`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso2 : PRE_first_tail_x15_r0_body.st2.s0 = { PRE_first_tail_x15_r0_body.s28 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs2 : List Frame := PRE_first_tail_x15_r0_body.s28.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_2 : PRE_first_tail_x15_r0_body.S28.tab.length = 139
kernel_rfl PRE_first_tail_x15_r0_body.tab0_2 : PRE_first_tail_x15_r0_body.st2.S0.tab = PRE_first_tail_x15_r0_body.S28.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws2 : List Nat := [1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059]
kernel_rfl PRE_first_tail_x15_r0_body.fresh2 : (PRE_first_tail_x15_r0_body.S28.tab.all fun e => PRE_first_tail_x15_r0_body.ws2.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S28.oracle.all fun q => PRE_first_tail_x15_r0_body.ws2.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab2 : PRE_first_tail_x15_r0_body.S29.tab = PRE_first_tail_x15_r0_body.S28.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws2
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen2 : PRE_first_tail_x15_r0_body.st2.S2.tab.length - PRE_first_tail_x15_r0_body.st2.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged2`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap2 : PRE_first_tail_x15_r0_body.s29.heap = PRE_first_tail_x15_r0_body.st2.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext2 : PRE_first_tail_x15_r0_body.s29.next = PRE_first_tail_x15_r0_body.st2.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl2 : PRE_first_tail_x15_r0_body.s29.ctl = PRE_first_tail_x15_r0_body.st2.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack2 : PRE_first_tail_x15_r0_body.s29.stack = PRE_first_tail_x15_r0_body.st2.s2.stack ++ PRE_first_tail_x15_r0_body.s28.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs2 : PRE_first_tail_x15_r0_body.s29.jobs = PRE_first_tail_x15_r0_body.st2.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi2 : PRE_first_tail_x15_r0_body.s29.ffi = PRE_first_tail_x15_r0_body.st2.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace2 : PRE_first_tail_x15_r0_body.s29.trace = PRE_first_tail_x15_r0_body.st2.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores2 : PRE_first_tail_x15_r0_body.s29.stores = PRE_first_tail_x15_r0_body.st2.s2.stores

end Host.Load.Run.Tpl
