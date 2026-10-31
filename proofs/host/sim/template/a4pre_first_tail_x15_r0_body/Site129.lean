import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.st129.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 129 of chain `PRE_first_tail_x15_r0_body`: `kvW__g129__g130` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1142`, the merged state `PRE_first_tail_x15_r0_body.s1143`,
the site template `PRE_first_tail_x15_r0_body.st129` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1144`: the merge.
The footprint's facts are in `SiteF129`, the compaction's in `SiteC129`, `SiteK129`, `SiteNa129`, `SiteNb129`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso129 : PRE_first_tail_x15_r0_body.st129.s0 = { PRE_first_tail_x15_r0_body.s1142 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs129 : List Frame := PRE_first_tail_x15_r0_body.s1142.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_129 : PRE_first_tail_x15_r0_body.S1142.tab.length = 5604
kernel_rfl PRE_first_tail_x15_r0_body.tab0_129 : PRE_first_tail_x15_r0_body.st129.S0.tab = PRE_first_tail_x15_r0_body.S1142.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws129 : List Nat := [3158, 3159, 3160, 3161, 3162, 3163, 3164, 3165, 3166, 3167, 3168, 3169, 3170, 3171, 3172, 3173, 3174]
kernel_rfl PRE_first_tail_x15_r0_body.fresh129 : (PRE_first_tail_x15_r0_body.S1142.tab.all fun e => PRE_first_tail_x15_r0_body.ws129.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1142.oracle.all fun q => PRE_first_tail_x15_r0_body.ws129.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab129 : PRE_first_tail_x15_r0_body.S1143.tab = PRE_first_tail_x15_r0_body.S1142.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws129
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen129 : PRE_first_tail_x15_r0_body.st129.S2.tab.length - PRE_first_tail_x15_r0_body.st129.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged129`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap129 : PRE_first_tail_x15_r0_body.s1143.heap = PRE_first_tail_x15_r0_body.st129.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext129 : PRE_first_tail_x15_r0_body.s1143.next = PRE_first_tail_x15_r0_body.st129.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl129 : PRE_first_tail_x15_r0_body.s1143.ctl = PRE_first_tail_x15_r0_body.st129.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack129 : PRE_first_tail_x15_r0_body.s1143.stack = PRE_first_tail_x15_r0_body.st129.s2.stack ++ PRE_first_tail_x15_r0_body.s1142.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs129 : PRE_first_tail_x15_r0_body.s1143.jobs = PRE_first_tail_x15_r0_body.st129.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi129 : PRE_first_tail_x15_r0_body.s1143.ffi = PRE_first_tail_x15_r0_body.st129.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace129 : PRE_first_tail_x15_r0_body.s1143.trace = PRE_first_tail_x15_r0_body.st129.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores129 : PRE_first_tail_x15_r0_body.s1143.stores = PRE_first_tail_x15_r0_body.st129.s2.stores

end Host.Load.Run.Tpl
