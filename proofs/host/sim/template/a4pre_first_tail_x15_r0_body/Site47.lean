import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.a4pre_first_tail_x15_r0_body.st47.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 47 of chain `PRE_first_tail_x15_r0_body`: `plan__g47__g48` (`plan`), the call state `PRE_first_tail_x15_r0_body.s418`, the merged state `PRE_first_tail_x15_r0_body.s419`,
the site template `PRE_first_tail_x15_r0_body.st47` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s420`: the merge.
The footprint's facts are in `SiteF47`, the compaction's in `SiteC47`, `SiteK47`, `SiteNa47`, `SiteNb47`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso47 : PRE_first_tail_x15_r0_body.st47.s0 = { PRE_first_tail_x15_r0_body.s418 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs47 : List Frame := PRE_first_tail_x15_r0_body.s418.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_47 : PRE_first_tail_x15_r0_body.S418.tab.length = 2062
kernel_rfl PRE_first_tail_x15_r0_body.tab0_47 : PRE_first_tail_x15_r0_body.st47.S0.tab = PRE_first_tail_x15_r0_body.S418.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws47 : List Nat := [1787, 1788, 1789, 1790, 1791, 1792, 1793, 1794, 1795]
kernel_rfl PRE_first_tail_x15_r0_body.fresh47 : (PRE_first_tail_x15_r0_body.S418.tab.all fun e => PRE_first_tail_x15_r0_body.ws47.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S418.oracle.all fun q => PRE_first_tail_x15_r0_body.ws47.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab47 : PRE_first_tail_x15_r0_body.S419.tab = PRE_first_tail_x15_r0_body.S418.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws47
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen47 : PRE_first_tail_x15_r0_body.st47.S2.tab.length - PRE_first_tail_x15_r0_body.st47.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged47`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap47 : PRE_first_tail_x15_r0_body.s419.heap = PRE_first_tail_x15_r0_body.st47.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext47 : PRE_first_tail_x15_r0_body.s419.next = PRE_first_tail_x15_r0_body.st47.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl47 : PRE_first_tail_x15_r0_body.s419.ctl = PRE_first_tail_x15_r0_body.st47.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack47 : PRE_first_tail_x15_r0_body.s419.stack = PRE_first_tail_x15_r0_body.st47.s2.stack ++ PRE_first_tail_x15_r0_body.s418.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs47 : PRE_first_tail_x15_r0_body.s419.jobs = PRE_first_tail_x15_r0_body.st47.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi47 : PRE_first_tail_x15_r0_body.s419.ffi = PRE_first_tail_x15_r0_body.st47.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace47 : PRE_first_tail_x15_r0_body.s419.trace = PRE_first_tail_x15_r0_body.st47.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores47 : PRE_first_tail_x15_r0_body.s419.stores = PRE_first_tail_x15_r0_body.st47.s2.stores

end Host.Load.Run.Tpl
