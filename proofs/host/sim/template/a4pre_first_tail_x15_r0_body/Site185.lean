import host.sim.template.a4pre_first_tail_x15_r0_body.H50
import host.sim.template.a4pre_first_tail_x15_r0_body.st185.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 185 of chain `PRE_first_tail_x15_r0_body`: `plan__g185__g186` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1627`, the merged state `PRE_first_tail_x15_r0_body.s1628`,
the site template `PRE_first_tail_x15_r0_body.st185` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1629`: the merge.
The footprint's facts are in `SiteF185`, the compaction's in `SiteC185`, `SiteK185`, `SiteNa185`, `SiteNb185`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso185 : PRE_first_tail_x15_r0_body.st185.s0 = { PRE_first_tail_x15_r0_body.s1627 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs185 : List Frame := PRE_first_tail_x15_r0_body.s1627.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_185 : PRE_first_tail_x15_r0_body.S1627.tab.length = 7963
kernel_rfl PRE_first_tail_x15_r0_body.tab0_185 : PRE_first_tail_x15_r0_body.st185.S0.tab = PRE_first_tail_x15_r0_body.S1627.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws185 : List Nat := [4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146]
kernel_rfl PRE_first_tail_x15_r0_body.fresh185 : (PRE_first_tail_x15_r0_body.S1627.tab.all fun e => PRE_first_tail_x15_r0_body.ws185.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1627.oracle.all fun q => PRE_first_tail_x15_r0_body.ws185.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab185 : PRE_first_tail_x15_r0_body.S1628.tab = PRE_first_tail_x15_r0_body.S1627.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws185
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen185 : PRE_first_tail_x15_r0_body.st185.S2.tab.length - PRE_first_tail_x15_r0_body.st185.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged185`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap185 : PRE_first_tail_x15_r0_body.s1628.heap = PRE_first_tail_x15_r0_body.st185.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext185 : PRE_first_tail_x15_r0_body.s1628.next = PRE_first_tail_x15_r0_body.st185.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl185 : PRE_first_tail_x15_r0_body.s1628.ctl = PRE_first_tail_x15_r0_body.st185.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack185 : PRE_first_tail_x15_r0_body.s1628.stack = PRE_first_tail_x15_r0_body.st185.s2.stack ++ PRE_first_tail_x15_r0_body.s1627.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs185 : PRE_first_tail_x15_r0_body.s1628.jobs = PRE_first_tail_x15_r0_body.st185.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi185 : PRE_first_tail_x15_r0_body.s1628.ffi = PRE_first_tail_x15_r0_body.st185.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace185 : PRE_first_tail_x15_r0_body.s1628.trace = PRE_first_tail_x15_r0_body.st185.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores185 : PRE_first_tail_x15_r0_body.s1628.stores = PRE_first_tail_x15_r0_body.st185.s2.stores

end Host.Load.Run.Tpl
