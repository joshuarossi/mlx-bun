import host.sim.template.a4pre_first_tail_x15_r0_body.H19
import host.sim.template.a4pre_first_tail_x15_r0_body.st65.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 65 of chain `PRE_first_tail_x15_r0_body`: `plan__g65__g66` (`plan`), the call state `PRE_first_tail_x15_r0_body.s632`, the merged state `PRE_first_tail_x15_r0_body.s633`,
the site template `PRE_first_tail_x15_r0_body.st65` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s634`: the merge.
The footprint's facts are in `SiteF65`, the compaction's in `SiteC65`, `SiteK65`, `SiteNa65`, `SiteNb65`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso65 : PRE_first_tail_x15_r0_body.st65.s0 = { PRE_first_tail_x15_r0_body.s632 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs65 : List Frame := PRE_first_tail_x15_r0_body.s632.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_65 : PRE_first_tail_x15_r0_body.S632.tab.length = 2833
kernel_rfl PRE_first_tail_x15_r0_body.tab0_65 : PRE_first_tail_x15_r0_body.st65.S0.tab = PRE_first_tail_x15_r0_body.S632.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws65 : List Nat := [2112, 2113, 2114]
kernel_rfl PRE_first_tail_x15_r0_body.fresh65 : (PRE_first_tail_x15_r0_body.S632.tab.all fun e => PRE_first_tail_x15_r0_body.ws65.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S632.oracle.all fun q => PRE_first_tail_x15_r0_body.ws65.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab65 : PRE_first_tail_x15_r0_body.S633.tab = PRE_first_tail_x15_r0_body.S632.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws65
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen65 : PRE_first_tail_x15_r0_body.st65.S2.tab.length - PRE_first_tail_x15_r0_body.st65.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged65`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap65 : PRE_first_tail_x15_r0_body.s633.heap = PRE_first_tail_x15_r0_body.st65.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext65 : PRE_first_tail_x15_r0_body.s633.next = PRE_first_tail_x15_r0_body.st65.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl65 : PRE_first_tail_x15_r0_body.s633.ctl = PRE_first_tail_x15_r0_body.st65.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack65 : PRE_first_tail_x15_r0_body.s633.stack = PRE_first_tail_x15_r0_body.st65.s2.stack ++ PRE_first_tail_x15_r0_body.s632.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs65 : PRE_first_tail_x15_r0_body.s633.jobs = PRE_first_tail_x15_r0_body.st65.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi65 : PRE_first_tail_x15_r0_body.s633.ffi = PRE_first_tail_x15_r0_body.st65.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace65 : PRE_first_tail_x15_r0_body.s633.trace = PRE_first_tail_x15_r0_body.st65.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores65 : PRE_first_tail_x15_r0_body.s633.stores = PRE_first_tail_x15_r0_body.st65.s2.stores

end Host.Load.Run.Tpl
