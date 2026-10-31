import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.a4pre_first_tail_x15_r0_body.st133.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 133 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g133__g134` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1176`, the merged state `PRE_first_tail_x15_r0_body.s1177`,
the site template `PRE_first_tail_x15_r0_body.st133` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1178`: the merge.
The footprint's facts are in `SiteF133`, the compaction's in `SiteC133`, `SiteK133`, `SiteNa133`, `SiteNb133`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso133 : PRE_first_tail_x15_r0_body.st133.s0 = { PRE_first_tail_x15_r0_body.s1176 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs133 : List Frame := PRE_first_tail_x15_r0_body.s1176.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_133 : PRE_first_tail_x15_r0_body.S1176.tab.length = 5765
kernel_rfl PRE_first_tail_x15_r0_body.tab0_133 : PRE_first_tail_x15_r0_body.st133.S0.tab = PRE_first_tail_x15_r0_body.S1176.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws133 : List Nat := [3238, 3239]
kernel_rfl PRE_first_tail_x15_r0_body.fresh133 : (PRE_first_tail_x15_r0_body.S1176.tab.all fun e => PRE_first_tail_x15_r0_body.ws133.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1176.oracle.all fun q => PRE_first_tail_x15_r0_body.ws133.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab133 : PRE_first_tail_x15_r0_body.S1177.tab = PRE_first_tail_x15_r0_body.S1176.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws133
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen133 : PRE_first_tail_x15_r0_body.st133.S2.tab.length - PRE_first_tail_x15_r0_body.st133.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged133`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap133 : PRE_first_tail_x15_r0_body.s1177.heap = PRE_first_tail_x15_r0_body.st133.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext133 : PRE_first_tail_x15_r0_body.s1177.next = PRE_first_tail_x15_r0_body.st133.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl133 : PRE_first_tail_x15_r0_body.s1177.ctl = PRE_first_tail_x15_r0_body.st133.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack133 : PRE_first_tail_x15_r0_body.s1177.stack = PRE_first_tail_x15_r0_body.st133.s2.stack ++ PRE_first_tail_x15_r0_body.s1176.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs133 : PRE_first_tail_x15_r0_body.s1177.jobs = PRE_first_tail_x15_r0_body.st133.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi133 : PRE_first_tail_x15_r0_body.s1177.ffi = PRE_first_tail_x15_r0_body.st133.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace133 : PRE_first_tail_x15_r0_body.s1177.trace = PRE_first_tail_x15_r0_body.st133.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores133 : PRE_first_tail_x15_r0_body.s1177.stores = PRE_first_tail_x15_r0_body.st133.s2.stores

end Host.Load.Run.Tpl
