import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.a4pre_first_tail_x15_r0_body.st37.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 37 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g37__g38` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s336`, the merged state `PRE_first_tail_x15_r0_body.s337`,
the site template `PRE_first_tail_x15_r0_body.st37` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s338`: the merge.
The footprint's facts are in `SiteF37`, the compaction's in `SiteC37`, `SiteK37`, `SiteNa37`, `SiteNb37`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso37 : PRE_first_tail_x15_r0_body.st37.s0 = { PRE_first_tail_x15_r0_body.s336 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs37 : List Frame := PRE_first_tail_x15_r0_body.s336.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_37 : PRE_first_tail_x15_r0_body.S336.tab.length = 1661
kernel_rfl PRE_first_tail_x15_r0_body.tab0_37 : PRE_first_tail_x15_r0_body.st37.S0.tab = PRE_first_tail_x15_r0_body.S336.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws37 : List Nat := [1640, 1641]
kernel_rfl PRE_first_tail_x15_r0_body.fresh37 : (PRE_first_tail_x15_r0_body.S336.tab.all fun e => PRE_first_tail_x15_r0_body.ws37.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S336.oracle.all fun q => PRE_first_tail_x15_r0_body.ws37.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab37 : PRE_first_tail_x15_r0_body.S337.tab = PRE_first_tail_x15_r0_body.S336.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws37
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen37 : PRE_first_tail_x15_r0_body.st37.S2.tab.length - PRE_first_tail_x15_r0_body.st37.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged37`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap37 : PRE_first_tail_x15_r0_body.s337.heap = PRE_first_tail_x15_r0_body.st37.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext37 : PRE_first_tail_x15_r0_body.s337.next = PRE_first_tail_x15_r0_body.st37.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl37 : PRE_first_tail_x15_r0_body.s337.ctl = PRE_first_tail_x15_r0_body.st37.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack37 : PRE_first_tail_x15_r0_body.s337.stack = PRE_first_tail_x15_r0_body.st37.s2.stack ++ PRE_first_tail_x15_r0_body.s336.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs37 : PRE_first_tail_x15_r0_body.s337.jobs = PRE_first_tail_x15_r0_body.st37.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi37 : PRE_first_tail_x15_r0_body.s337.ffi = PRE_first_tail_x15_r0_body.st37.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace37 : PRE_first_tail_x15_r0_body.s337.trace = PRE_first_tail_x15_r0_body.st37.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores37 : PRE_first_tail_x15_r0_body.s337.stores = PRE_first_tail_x15_r0_body.st37.s2.stores

end Host.Load.Run.Tpl
