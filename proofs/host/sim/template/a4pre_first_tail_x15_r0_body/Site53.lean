import host.sim.template.a4pre_first_tail_x15_r0_body.H16
import host.sim.template.a4pre_first_tail_x15_r0_body.st53.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 53 of chain `PRE_first_tail_x15_r0_body`: `plan__g53__g54` (`plan`), the call state `PRE_first_tail_x15_r0_body.s517`, the merged state `PRE_first_tail_x15_r0_body.s518`,
the site template `PRE_first_tail_x15_r0_body.st53` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s519`: the merge.
The footprint's facts are in `SiteF53`, the compaction's in `SiteC53`, `SiteK53`, `SiteNa53`, `SiteNb53`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso53 : PRE_first_tail_x15_r0_body.st53.s0 = { PRE_first_tail_x15_r0_body.s517 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs53 : List Frame := PRE_first_tail_x15_r0_body.s517.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_53 : PRE_first_tail_x15_r0_body.S517.tab.length = 2320
kernel_rfl PRE_first_tail_x15_r0_body.tab0_53 : PRE_first_tail_x15_r0_body.st53.S0.tab = PRE_first_tail_x15_r0_body.S517.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws53 : List Nat := [1907, 1908, 1909, 1910, 1911, 1912, 1913, 1914, 1915]
kernel_rfl PRE_first_tail_x15_r0_body.fresh53 : (PRE_first_tail_x15_r0_body.S517.tab.all fun e => PRE_first_tail_x15_r0_body.ws53.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S517.oracle.all fun q => PRE_first_tail_x15_r0_body.ws53.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab53 : PRE_first_tail_x15_r0_body.S518.tab = PRE_first_tail_x15_r0_body.S517.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws53
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen53 : PRE_first_tail_x15_r0_body.st53.S2.tab.length - PRE_first_tail_x15_r0_body.st53.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged53`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap53 : PRE_first_tail_x15_r0_body.s518.heap = PRE_first_tail_x15_r0_body.st53.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext53 : PRE_first_tail_x15_r0_body.s518.next = PRE_first_tail_x15_r0_body.st53.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl53 : PRE_first_tail_x15_r0_body.s518.ctl = PRE_first_tail_x15_r0_body.st53.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack53 : PRE_first_tail_x15_r0_body.s518.stack = PRE_first_tail_x15_r0_body.st53.s2.stack ++ PRE_first_tail_x15_r0_body.s517.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs53 : PRE_first_tail_x15_r0_body.s518.jobs = PRE_first_tail_x15_r0_body.st53.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi53 : PRE_first_tail_x15_r0_body.s518.ffi = PRE_first_tail_x15_r0_body.st53.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace53 : PRE_first_tail_x15_r0_body.s518.trace = PRE_first_tail_x15_r0_body.st53.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores53 : PRE_first_tail_x15_r0_body.s518.stores = PRE_first_tail_x15_r0_body.st53.s2.stores

end Host.Load.Run.Tpl
