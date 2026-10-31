import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.a4pre_first_tail_x15_r0_body.st85.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 85 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g85__g86` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s829`, the merged state `PRE_first_tail_x15_r0_body.s830`,
the site template `PRE_first_tail_x15_r0_body.st85` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s831`: the merge.
The footprint's facts are in `SiteF85`, the compaction's in `SiteC85`, `SiteK85`, `SiteNa85`, `SiteNb85`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso85 : PRE_first_tail_x15_r0_body.st85.s0 = { PRE_first_tail_x15_r0_body.s829 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs85 : List Frame := PRE_first_tail_x15_r0_body.s829.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_85 : PRE_first_tail_x15_r0_body.S829.tab.length = 3713
kernel_rfl PRE_first_tail_x15_r0_body.tab0_85 : PRE_first_tail_x15_r0_body.st85.S0.tab = PRE_first_tail_x15_r0_body.S829.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws85 : List Nat := [2442, 2443]
kernel_rfl PRE_first_tail_x15_r0_body.fresh85 : (PRE_first_tail_x15_r0_body.S829.tab.all fun e => PRE_first_tail_x15_r0_body.ws85.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S829.oracle.all fun q => PRE_first_tail_x15_r0_body.ws85.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab85 : PRE_first_tail_x15_r0_body.S830.tab = PRE_first_tail_x15_r0_body.S829.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws85
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen85 : PRE_first_tail_x15_r0_body.st85.S2.tab.length - PRE_first_tail_x15_r0_body.st85.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged85`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap85 : PRE_first_tail_x15_r0_body.s830.heap = PRE_first_tail_x15_r0_body.st85.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext85 : PRE_first_tail_x15_r0_body.s830.next = PRE_first_tail_x15_r0_body.st85.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl85 : PRE_first_tail_x15_r0_body.s830.ctl = PRE_first_tail_x15_r0_body.st85.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack85 : PRE_first_tail_x15_r0_body.s830.stack = PRE_first_tail_x15_r0_body.st85.s2.stack ++ PRE_first_tail_x15_r0_body.s829.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs85 : PRE_first_tail_x15_r0_body.s830.jobs = PRE_first_tail_x15_r0_body.st85.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi85 : PRE_first_tail_x15_r0_body.s830.ffi = PRE_first_tail_x15_r0_body.st85.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace85 : PRE_first_tail_x15_r0_body.s830.trace = PRE_first_tail_x15_r0_body.st85.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores85 : PRE_first_tail_x15_r0_body.s830.stores = PRE_first_tail_x15_r0_body.st85.s2.stores

end Host.Load.Run.Tpl
