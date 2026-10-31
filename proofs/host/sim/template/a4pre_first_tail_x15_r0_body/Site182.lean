import host.sim.template.a4pre_first_tail_x15_r0_body.H54
import host.sim.template.a4pre_first_tail_x15_r0_body.st182.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 182 of chain `PRE_first_tail_x15_r0_body`: `plan__g182__g183` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1753`, the merged state `PRE_first_tail_x15_r0_body.s1754`,
the site template `PRE_first_tail_x15_r0_body.st182` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1755`: the merge.
The footprint's facts are in `SiteF182`, the compaction's in `SiteC182`, `SiteK182`, `SiteNa182`, `SiteNb182`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso182 : PRE_first_tail_x15_r0_body.st182.s0 = { PRE_first_tail_x15_r0_body.s1753 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs182 : List Frame := PRE_first_tail_x15_r0_body.s1753.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_182 : PRE_first_tail_x15_r0_body.S1753.tab.length = 7834
kernel_rfl PRE_first_tail_x15_r0_body.tab0_182 : PRE_first_tail_x15_r0_body.st182.S0.tab = PRE_first_tail_x15_r0_body.S1753.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws182 : List Nat := [4078, 4079, 4080, 4081, 4082, 4083, 4084, 4085, 4086]
kernel_rfl PRE_first_tail_x15_r0_body.fresh182 : (PRE_first_tail_x15_r0_body.S1753.tab.all fun e => PRE_first_tail_x15_r0_body.ws182.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1753.oracle.all fun q => PRE_first_tail_x15_r0_body.ws182.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab182 : PRE_first_tail_x15_r0_body.S1754.tab = PRE_first_tail_x15_r0_body.S1753.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws182
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen182 : PRE_first_tail_x15_r0_body.st182.S2.tab.length - PRE_first_tail_x15_r0_body.st182.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged182`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap182 : PRE_first_tail_x15_r0_body.s1754.heap = PRE_first_tail_x15_r0_body.st182.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext182 : PRE_first_tail_x15_r0_body.s1754.next = PRE_first_tail_x15_r0_body.st182.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl182 : PRE_first_tail_x15_r0_body.s1754.ctl = PRE_first_tail_x15_r0_body.st182.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack182 : PRE_first_tail_x15_r0_body.s1754.stack = PRE_first_tail_x15_r0_body.st182.s2.stack ++ PRE_first_tail_x15_r0_body.s1753.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs182 : PRE_first_tail_x15_r0_body.s1754.jobs = PRE_first_tail_x15_r0_body.st182.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi182 : PRE_first_tail_x15_r0_body.s1754.ffi = PRE_first_tail_x15_r0_body.st182.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace182 : PRE_first_tail_x15_r0_body.s1754.trace = PRE_first_tail_x15_r0_body.st182.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores182 : PRE_first_tail_x15_r0_body.s1754.stores = PRE_first_tail_x15_r0_body.st182.s2.stores

end Host.Load.Run.Tpl
