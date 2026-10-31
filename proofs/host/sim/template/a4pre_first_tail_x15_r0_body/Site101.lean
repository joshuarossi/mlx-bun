import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.st101.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 101 of chain `PRE_first_tail_x15_r0_body`: `plan__g101__g102` (`plan`), the call state `PRE_first_tail_x15_r0_body.s892`, the merged state `PRE_first_tail_x15_r0_body.s893`,
the site template `PRE_first_tail_x15_r0_body.st101` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s894`: the merge.
The footprint's facts are in `SiteF101`, the compaction's in `SiteC101`, `SiteK101`, `SiteNa101`, `SiteNb101`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso101 : PRE_first_tail_x15_r0_body.st101.s0 = { PRE_first_tail_x15_r0_body.s892 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs101 : List Frame := PRE_first_tail_x15_r0_body.s892.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_101 : PRE_first_tail_x15_r0_body.S892.tab.length = 4372
kernel_rfl PRE_first_tail_x15_r0_body.tab0_101 : PRE_first_tail_x15_r0_body.st101.S0.tab = PRE_first_tail_x15_r0_body.S892.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws101 : List Nat := [2709, 2710, 2711, 2712, 2713, 2714, 2715, 2716, 2717]
kernel_rfl PRE_first_tail_x15_r0_body.fresh101 : (PRE_first_tail_x15_r0_body.S892.tab.all fun e => PRE_first_tail_x15_r0_body.ws101.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S892.oracle.all fun q => PRE_first_tail_x15_r0_body.ws101.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab101 : PRE_first_tail_x15_r0_body.S893.tab = PRE_first_tail_x15_r0_body.S892.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws101
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen101 : PRE_first_tail_x15_r0_body.st101.S2.tab.length - PRE_first_tail_x15_r0_body.st101.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged101`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap101 : PRE_first_tail_x15_r0_body.s893.heap = PRE_first_tail_x15_r0_body.st101.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext101 : PRE_first_tail_x15_r0_body.s893.next = PRE_first_tail_x15_r0_body.st101.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl101 : PRE_first_tail_x15_r0_body.s893.ctl = PRE_first_tail_x15_r0_body.st101.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack101 : PRE_first_tail_x15_r0_body.s893.stack = PRE_first_tail_x15_r0_body.st101.s2.stack ++ PRE_first_tail_x15_r0_body.s892.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs101 : PRE_first_tail_x15_r0_body.s893.jobs = PRE_first_tail_x15_r0_body.st101.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi101 : PRE_first_tail_x15_r0_body.s893.ffi = PRE_first_tail_x15_r0_body.st101.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace101 : PRE_first_tail_x15_r0_body.s893.trace = PRE_first_tail_x15_r0_body.st101.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores101 : PRE_first_tail_x15_r0_body.s893.stores = PRE_first_tail_x15_r0_body.st101.s2.stores

end Host.Load.Run.Tpl
