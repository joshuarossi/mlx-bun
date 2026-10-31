import host.sim.template.a4pre_first_tail_x15_r0_body.H57
import host.sim.template.a4pre_first_tail_x15_r0_body.st191.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 191 of chain `PRE_first_tail_x15_r0_body`: `plan__g191__g192` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1839`, the merged state `PRE_first_tail_x15_r0_body.s1840`,
the site template `PRE_first_tail_x15_r0_body.st191` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1841`: the merge.
The footprint's facts are in `SiteF191`, the compaction's in `SiteC191`, `SiteK191`, `SiteNa191`, `SiteNb191`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso191 : PRE_first_tail_x15_r0_body.st191.s0 = { PRE_first_tail_x15_r0_body.s1839 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs191 : List Frame := PRE_first_tail_x15_r0_body.s1839.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_191 : PRE_first_tail_x15_r0_body.S1839.tab.length = 8218
kernel_rfl PRE_first_tail_x15_r0_body.tab0_191 : PRE_first_tail_x15_r0_body.st191.S0.tab = PRE_first_tail_x15_r0_body.S1839.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws191 : List Nat := [4229, 4230, 4231]
kernel_rfl PRE_first_tail_x15_r0_body.fresh191 : (PRE_first_tail_x15_r0_body.S1839.tab.all fun e => PRE_first_tail_x15_r0_body.ws191.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1839.oracle.all fun q => PRE_first_tail_x15_r0_body.ws191.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab191 : PRE_first_tail_x15_r0_body.S1840.tab = PRE_first_tail_x15_r0_body.S1839.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws191
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen191 : PRE_first_tail_x15_r0_body.st191.S2.tab.length - PRE_first_tail_x15_r0_body.st191.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged191`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap191 : PRE_first_tail_x15_r0_body.s1840.heap = PRE_first_tail_x15_r0_body.st191.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext191 : PRE_first_tail_x15_r0_body.s1840.next = PRE_first_tail_x15_r0_body.st191.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl191 : PRE_first_tail_x15_r0_body.s1840.ctl = PRE_first_tail_x15_r0_body.st191.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack191 : PRE_first_tail_x15_r0_body.s1840.stack = PRE_first_tail_x15_r0_body.st191.s2.stack ++ PRE_first_tail_x15_r0_body.s1839.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs191 : PRE_first_tail_x15_r0_body.s1840.jobs = PRE_first_tail_x15_r0_body.st191.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi191 : PRE_first_tail_x15_r0_body.s1840.ffi = PRE_first_tail_x15_r0_body.st191.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace191 : PRE_first_tail_x15_r0_body.s1840.trace = PRE_first_tail_x15_r0_body.st191.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores191 : PRE_first_tail_x15_r0_body.s1840.stores = PRE_first_tail_x15_r0_body.st191.s2.stores

end Host.Load.Run.Tpl
