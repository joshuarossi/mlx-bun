import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.a4pre_first_tail_x15_r0_body.st117.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 117 of chain `PRE_first_tail_x15_r0_body`: `kvW__g117__g118` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1037`, the merged state `PRE_first_tail_x15_r0_body.s1038`,
the site template `PRE_first_tail_x15_r0_body.st117` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1039`: the merge.
The footprint's facts are in `SiteF117`, the compaction's in `SiteC117`, `SiteK117`, `SiteNa117`, `SiteNb117`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso117 : PRE_first_tail_x15_r0_body.st117.s0 = { PRE_first_tail_x15_r0_body.s1037 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs117 : List Frame := PRE_first_tail_x15_r0_body.s1037.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_117 : PRE_first_tail_x15_r0_body.S1037.tab.length = 5091
kernel_rfl PRE_first_tail_x15_r0_body.tab0_117 : PRE_first_tail_x15_r0_body.st117.S0.tab = PRE_first_tail_x15_r0_body.S1037.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws117 : List Nat := [2965, 2966, 2967, 2968, 2969, 2970, 2971, 2972, 2973, 2974, 2975, 2976, 2977, 2978, 2979, 2980, 2981]
kernel_rfl PRE_first_tail_x15_r0_body.fresh117 : (PRE_first_tail_x15_r0_body.S1037.tab.all fun e => PRE_first_tail_x15_r0_body.ws117.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1037.oracle.all fun q => PRE_first_tail_x15_r0_body.ws117.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab117 : PRE_first_tail_x15_r0_body.S1038.tab = PRE_first_tail_x15_r0_body.S1037.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws117
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen117 : PRE_first_tail_x15_r0_body.st117.S2.tab.length - PRE_first_tail_x15_r0_body.st117.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged117`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap117 : PRE_first_tail_x15_r0_body.s1038.heap = PRE_first_tail_x15_r0_body.st117.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext117 : PRE_first_tail_x15_r0_body.s1038.next = PRE_first_tail_x15_r0_body.st117.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl117 : PRE_first_tail_x15_r0_body.s1038.ctl = PRE_first_tail_x15_r0_body.st117.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack117 : PRE_first_tail_x15_r0_body.s1038.stack = PRE_first_tail_x15_r0_body.st117.s2.stack ++ PRE_first_tail_x15_r0_body.s1037.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs117 : PRE_first_tail_x15_r0_body.s1038.jobs = PRE_first_tail_x15_r0_body.st117.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi117 : PRE_first_tail_x15_r0_body.s1038.ffi = PRE_first_tail_x15_r0_body.st117.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace117 : PRE_first_tail_x15_r0_body.s1038.trace = PRE_first_tail_x15_r0_body.st117.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores117 : PRE_first_tail_x15_r0_body.s1038.stores = PRE_first_tail_x15_r0_body.st117.s2.stores

end Host.Load.Run.Tpl
