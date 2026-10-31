import host.sim.template.a4pre_first_tail_x15_r0_body.H15
import host.sim.template.a4pre_first_tail_x15_r0_body.st50.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 50 of chain `PRE_first_tail_x15_r0_body`: `plan__g50__g51` (`plan`), the call state `PRE_first_tail_x15_r0_body.s488`, the merged state `PRE_first_tail_x15_r0_body.s489`,
the site template `PRE_first_tail_x15_r0_body.st50` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s490`: the merge.
The footprint's facts are in `SiteF50`, the compaction's in `SiteC50`, `SiteK50`, `SiteNa50`, `SiteNb50`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso50 : PRE_first_tail_x15_r0_body.st50.s0 = { PRE_first_tail_x15_r0_body.s488 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs50 : List Frame := PRE_first_tail_x15_r0_body.s488.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_50 : PRE_first_tail_x15_r0_body.S488.tab.length = 2191
kernel_rfl PRE_first_tail_x15_r0_body.tab0_50 : PRE_first_tail_x15_r0_body.st50.S0.tab = PRE_first_tail_x15_r0_body.S488.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws50 : List Nat := [1847, 1848, 1849, 1850, 1851, 1852, 1853, 1854, 1855]
kernel_rfl PRE_first_tail_x15_r0_body.fresh50 : (PRE_first_tail_x15_r0_body.S488.tab.all fun e => PRE_first_tail_x15_r0_body.ws50.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S488.oracle.all fun q => PRE_first_tail_x15_r0_body.ws50.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab50 : PRE_first_tail_x15_r0_body.S489.tab = PRE_first_tail_x15_r0_body.S488.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws50
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen50 : PRE_first_tail_x15_r0_body.st50.S2.tab.length - PRE_first_tail_x15_r0_body.st50.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged50`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap50 : PRE_first_tail_x15_r0_body.s489.heap = PRE_first_tail_x15_r0_body.st50.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext50 : PRE_first_tail_x15_r0_body.s489.next = PRE_first_tail_x15_r0_body.st50.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl50 : PRE_first_tail_x15_r0_body.s489.ctl = PRE_first_tail_x15_r0_body.st50.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack50 : PRE_first_tail_x15_r0_body.s489.stack = PRE_first_tail_x15_r0_body.st50.s2.stack ++ PRE_first_tail_x15_r0_body.s488.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs50 : PRE_first_tail_x15_r0_body.s489.jobs = PRE_first_tail_x15_r0_body.st50.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi50 : PRE_first_tail_x15_r0_body.s489.ffi = PRE_first_tail_x15_r0_body.st50.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace50 : PRE_first_tail_x15_r0_body.s489.trace = PRE_first_tail_x15_r0_body.st50.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores50 : PRE_first_tail_x15_r0_body.s489.stores = PRE_first_tail_x15_r0_body.st50.s2.stores

end Host.Load.Run.Tpl
