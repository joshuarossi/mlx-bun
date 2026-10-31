import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.st112.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 112 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g112__g113` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s993`, the merged state `PRE_first_tail_x15_r0_body.s994`,
the site template `PRE_first_tail_x15_r0_body.st112` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s995`: the merge.
The footprint's facts are in `SiteF112`, the compaction's in `SiteC112`, `SiteK112`, `SiteNa112`, `SiteNb112`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso112 : PRE_first_tail_x15_r0_body.st112.s0 = { PRE_first_tail_x15_r0_body.s993 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs112 : List Frame := PRE_first_tail_x15_r0_body.s993.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_112 : PRE_first_tail_x15_r0_body.S993.tab.length = 4868
kernel_rfl PRE_first_tail_x15_r0_body.tab0_112 : PRE_first_tail_x15_r0_body.st112.S0.tab = PRE_first_tail_x15_r0_body.S993.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws112 : List Nat := [2906, 2907]
kernel_rfl PRE_first_tail_x15_r0_body.fresh112 : (PRE_first_tail_x15_r0_body.S993.tab.all fun e => PRE_first_tail_x15_r0_body.ws112.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S993.oracle.all fun q => PRE_first_tail_x15_r0_body.ws112.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab112 : PRE_first_tail_x15_r0_body.S994.tab = PRE_first_tail_x15_r0_body.S993.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws112
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen112 : PRE_first_tail_x15_r0_body.st112.S2.tab.length - PRE_first_tail_x15_r0_body.st112.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged112`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap112 : PRE_first_tail_x15_r0_body.s994.heap = PRE_first_tail_x15_r0_body.st112.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext112 : PRE_first_tail_x15_r0_body.s994.next = PRE_first_tail_x15_r0_body.st112.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl112 : PRE_first_tail_x15_r0_body.s994.ctl = PRE_first_tail_x15_r0_body.st112.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack112 : PRE_first_tail_x15_r0_body.s994.stack = PRE_first_tail_x15_r0_body.st112.s2.stack ++ PRE_first_tail_x15_r0_body.s993.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs112 : PRE_first_tail_x15_r0_body.s994.jobs = PRE_first_tail_x15_r0_body.st112.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi112 : PRE_first_tail_x15_r0_body.s994.ffi = PRE_first_tail_x15_r0_body.st112.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace112 : PRE_first_tail_x15_r0_body.s994.trace = PRE_first_tail_x15_r0_body.st112.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores112 : PRE_first_tail_x15_r0_body.s994.stores = PRE_first_tail_x15_r0_body.st112.s2.stores

end Host.Load.Run.Tpl
