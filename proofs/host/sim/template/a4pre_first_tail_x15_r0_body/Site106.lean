import host.sim.template.a4pre_first_tail_x15_r0_body.H29
import host.sim.template.a4pre_first_tail_x15_r0_body.st106.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 106 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g106__g107` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s939`, the merged state `PRE_first_tail_x15_r0_body.s940`,
the site template `PRE_first_tail_x15_r0_body.st106` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s941`: the merge.
The footprint's facts are in `SiteF106`, the compaction's in `SiteC106`, `SiteK106`, `SiteNa106`, `SiteNb106`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso106 : PRE_first_tail_x15_r0_body.st106.s0 = { PRE_first_tail_x15_r0_body.s939 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs106 : List Frame := PRE_first_tail_x15_r0_body.s939.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_106 : PRE_first_tail_x15_r0_body.S939.tab.length = 4610
kernel_rfl PRE_first_tail_x15_r0_body.tab0_106 : PRE_first_tail_x15_r0_body.st106.S0.tab = PRE_first_tail_x15_r0_body.S939.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws106 : List Nat := [2798, 2799]
kernel_rfl PRE_first_tail_x15_r0_body.fresh106 : (PRE_first_tail_x15_r0_body.S939.tab.all fun e => PRE_first_tail_x15_r0_body.ws106.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S939.oracle.all fun q => PRE_first_tail_x15_r0_body.ws106.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab106 : PRE_first_tail_x15_r0_body.S940.tab = PRE_first_tail_x15_r0_body.S939.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws106
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen106 : PRE_first_tail_x15_r0_body.st106.S2.tab.length - PRE_first_tail_x15_r0_body.st106.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged106`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap106 : PRE_first_tail_x15_r0_body.s940.heap = PRE_first_tail_x15_r0_body.st106.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext106 : PRE_first_tail_x15_r0_body.s940.next = PRE_first_tail_x15_r0_body.st106.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl106 : PRE_first_tail_x15_r0_body.s940.ctl = PRE_first_tail_x15_r0_body.st106.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack106 : PRE_first_tail_x15_r0_body.s940.stack = PRE_first_tail_x15_r0_body.st106.s2.stack ++ PRE_first_tail_x15_r0_body.s939.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs106 : PRE_first_tail_x15_r0_body.s940.jobs = PRE_first_tail_x15_r0_body.st106.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi106 : PRE_first_tail_x15_r0_body.s940.ffi = PRE_first_tail_x15_r0_body.st106.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace106 : PRE_first_tail_x15_r0_body.s940.trace = PRE_first_tail_x15_r0_body.st106.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores106 : PRE_first_tail_x15_r0_body.s940.stores = PRE_first_tail_x15_r0_body.st106.s2.stores

end Host.Load.Run.Tpl
