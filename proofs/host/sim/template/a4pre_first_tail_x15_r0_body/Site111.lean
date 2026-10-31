import host.sim.template.a4pre_first_tail_x15_r0_body.H33
import host.sim.template.a4pre_first_tail_x15_r0_body.st111.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 111 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g111__g112` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1080`, the merged state `PRE_first_tail_x15_r0_body.s1081`,
the site template `PRE_first_tail_x15_r0_body.st111` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1082`: the merge.
The footprint's facts are in `SiteF111`, the compaction's in `SiteC111`, `SiteK111`, `SiteNa111`, `SiteNb111`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso111 : PRE_first_tail_x15_r0_body.st111.s0 = { PRE_first_tail_x15_r0_body.s1080 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs111 : List Frame := PRE_first_tail_x15_r0_body.s1080.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_111 : PRE_first_tail_x15_r0_body.S1080.tab.length = 4829
kernel_rfl PRE_first_tail_x15_r0_body.tab0_111 : PRE_first_tail_x15_r0_body.st111.S0.tab = PRE_first_tail_x15_r0_body.S1080.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws111 : List Nat := [2857, 2858, 2859, 2860, 2861, 2862, 2863, 2864, 2865, 2866, 2867, 2868, 2869, 2870, 2871, 2872, 2873, 2874, 2875, 2876, 2877, 2878, 2879, 2880, 2881, 2882, 2883, 2884, 2885, 2886, 2887]
kernel_rfl PRE_first_tail_x15_r0_body.fresh111 : (PRE_first_tail_x15_r0_body.S1080.tab.all fun e => PRE_first_tail_x15_r0_body.ws111.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1080.oracle.all fun q => PRE_first_tail_x15_r0_body.ws111.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab111 : PRE_first_tail_x15_r0_body.S1081.tab = PRE_first_tail_x15_r0_body.S1080.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws111
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen111 : PRE_first_tail_x15_r0_body.st111.S5.tab.length - PRE_first_tail_x15_r0_body.st111.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged111`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap111 : PRE_first_tail_x15_r0_body.s1081.heap = PRE_first_tail_x15_r0_body.st111.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext111 : PRE_first_tail_x15_r0_body.s1081.next = PRE_first_tail_x15_r0_body.st111.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl111 : PRE_first_tail_x15_r0_body.s1081.ctl = PRE_first_tail_x15_r0_body.st111.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack111 : PRE_first_tail_x15_r0_body.s1081.stack = PRE_first_tail_x15_r0_body.st111.s5.stack ++ PRE_first_tail_x15_r0_body.s1080.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs111 : PRE_first_tail_x15_r0_body.s1081.jobs = PRE_first_tail_x15_r0_body.st111.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi111 : PRE_first_tail_x15_r0_body.s1081.ffi = PRE_first_tail_x15_r0_body.st111.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace111 : PRE_first_tail_x15_r0_body.s1081.trace = PRE_first_tail_x15_r0_body.st111.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores111 : PRE_first_tail_x15_r0_body.s1081.stores = PRE_first_tail_x15_r0_body.st111.s5.stores

end Host.Load.Run.Tpl
