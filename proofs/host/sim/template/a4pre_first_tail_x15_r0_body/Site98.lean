import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.st98.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 98 of chain `PRE_first_tail_x15_r0_body`: `plan__g98__g99` (`plan`), the call state `PRE_first_tail_x15_r0_body.s865`, the merged state `PRE_first_tail_x15_r0_body.s866`,
the site template `PRE_first_tail_x15_r0_body.st98` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s867`: the merge.
The footprint's facts are in `SiteF98`, the compaction's in `SiteC98`, `SiteK98`, `SiteNa98`, `SiteNb98`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso98 : PRE_first_tail_x15_r0_body.st98.s0 = { PRE_first_tail_x15_r0_body.s865 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs98 : List Frame := PRE_first_tail_x15_r0_body.s865.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_98 : PRE_first_tail_x15_r0_body.S865.tab.length = 4243
kernel_rfl PRE_first_tail_x15_r0_body.tab0_98 : PRE_first_tail_x15_r0_body.st98.S0.tab = PRE_first_tail_x15_r0_body.S865.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws98 : List Nat := [2649, 2650, 2651, 2652, 2653, 2654, 2655, 2656, 2657]
kernel_rfl PRE_first_tail_x15_r0_body.fresh98 : (PRE_first_tail_x15_r0_body.S865.tab.all fun e => PRE_first_tail_x15_r0_body.ws98.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S865.oracle.all fun q => PRE_first_tail_x15_r0_body.ws98.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab98 : PRE_first_tail_x15_r0_body.S866.tab = PRE_first_tail_x15_r0_body.S865.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws98
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen98 : PRE_first_tail_x15_r0_body.st98.S2.tab.length - PRE_first_tail_x15_r0_body.st98.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged98`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap98 : PRE_first_tail_x15_r0_body.s866.heap = PRE_first_tail_x15_r0_body.st98.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext98 : PRE_first_tail_x15_r0_body.s866.next = PRE_first_tail_x15_r0_body.st98.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl98 : PRE_first_tail_x15_r0_body.s866.ctl = PRE_first_tail_x15_r0_body.st98.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack98 : PRE_first_tail_x15_r0_body.s866.stack = PRE_first_tail_x15_r0_body.st98.s2.stack ++ PRE_first_tail_x15_r0_body.s865.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs98 : PRE_first_tail_x15_r0_body.s866.jobs = PRE_first_tail_x15_r0_body.st98.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi98 : PRE_first_tail_x15_r0_body.s866.ffi = PRE_first_tail_x15_r0_body.st98.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace98 : PRE_first_tail_x15_r0_body.s866.trace = PRE_first_tail_x15_r0_body.st98.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores98 : PRE_first_tail_x15_r0_body.s866.stores = PRE_first_tail_x15_r0_body.st98.s2.stores

end Host.Load.Run.Tpl
