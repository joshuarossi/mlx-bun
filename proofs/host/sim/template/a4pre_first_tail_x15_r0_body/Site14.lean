import host.sim.template.a4pre_first_tail_x15_r0_body.H4
import host.sim.template.a4pre_first_tail_x15_r0_body.st14.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 14 of chain `PRE_first_tail_x15_r0_body`: `plan__g14__g15` (`plan`), the call state `PRE_first_tail_x15_r0_body.s143`, the merged state `PRE_first_tail_x15_r0_body.s144`,
the site template `PRE_first_tail_x15_r0_body.st14` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s145`: the merge.
The footprint's facts are in `SiteF14`, the compaction's in `SiteC14`, `SiteK14`, `SiteNa14`, `SiteNb14`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso14 : PRE_first_tail_x15_r0_body.st14.s0 = { PRE_first_tail_x15_r0_body.s143 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs14 : List Frame := PRE_first_tail_x15_r0_body.s143.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_14 : PRE_first_tail_x15_r0_body.S143.tab.length = 652
kernel_rfl PRE_first_tail_x15_r0_body.tab0_14 : PRE_first_tail_x15_r0_body.st14.S0.tab = PRE_first_tail_x15_r0_body.S143.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws14 : List Nat := [1250, 1251, 1252]
kernel_rfl PRE_first_tail_x15_r0_body.fresh14 : (PRE_first_tail_x15_r0_body.S143.tab.all fun e => PRE_first_tail_x15_r0_body.ws14.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S143.oracle.all fun q => PRE_first_tail_x15_r0_body.ws14.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab14 : PRE_first_tail_x15_r0_body.S144.tab = PRE_first_tail_x15_r0_body.S143.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws14
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen14 : PRE_first_tail_x15_r0_body.st14.S2.tab.length - PRE_first_tail_x15_r0_body.st14.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged14`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap14 : PRE_first_tail_x15_r0_body.s144.heap = PRE_first_tail_x15_r0_body.st14.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext14 : PRE_first_tail_x15_r0_body.s144.next = PRE_first_tail_x15_r0_body.st14.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl14 : PRE_first_tail_x15_r0_body.s144.ctl = PRE_first_tail_x15_r0_body.st14.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack14 : PRE_first_tail_x15_r0_body.s144.stack = PRE_first_tail_x15_r0_body.st14.s2.stack ++ PRE_first_tail_x15_r0_body.s143.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs14 : PRE_first_tail_x15_r0_body.s144.jobs = PRE_first_tail_x15_r0_body.st14.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi14 : PRE_first_tail_x15_r0_body.s144.ffi = PRE_first_tail_x15_r0_body.st14.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace14 : PRE_first_tail_x15_r0_body.s144.trace = PRE_first_tail_x15_r0_body.st14.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores14 : PRE_first_tail_x15_r0_body.s144.stores = PRE_first_tail_x15_r0_body.st14.s2.stores

end Host.Load.Run.Tpl
