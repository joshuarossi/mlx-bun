import host.sim.template.a4pre_first_tail_x15_r0_body.H44
import host.sim.template.a4pre_first_tail_x15_r0_body.st147.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 147 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g147__g148` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1425`, the merged state `PRE_first_tail_x15_r0_body.s1426`,
the site template `PRE_first_tail_x15_r0_body.st147` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1427`: the merge.
The footprint's facts are in `SiteF147`, the compaction's in `SiteC147`, `SiteK147`, `SiteNa147`, `SiteNb147`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso147 : PRE_first_tail_x15_r0_body.st147.s0 = { PRE_first_tail_x15_r0_body.s1425 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs147 : List Frame := PRE_first_tail_x15_r0_body.s1425.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_147 : PRE_first_tail_x15_r0_body.S1425.tab.length = 6368
kernel_rfl PRE_first_tail_x15_r0_body.tab0_147 : PRE_first_tail_x15_r0_body.st147.S0.tab = PRE_first_tail_x15_r0_body.S1425.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws147 : List Nat := [3460, 3461, 3462, 3463, 3464, 3465, 3466, 3467, 3468, 3469, 3470, 3471, 3472, 3473, 3474, 3475, 3476, 3477, 3478, 3479, 3480, 3481, 3482, 3483, 3484, 3485, 3486, 3487, 3488, 3489, 3490]
kernel_rfl PRE_first_tail_x15_r0_body.fresh147 : (PRE_first_tail_x15_r0_body.S1425.tab.all fun e => PRE_first_tail_x15_r0_body.ws147.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1425.oracle.all fun q => PRE_first_tail_x15_r0_body.ws147.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab147 : PRE_first_tail_x15_r0_body.S1426.tab = PRE_first_tail_x15_r0_body.S1425.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws147
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen147 : PRE_first_tail_x15_r0_body.st147.S5.tab.length - PRE_first_tail_x15_r0_body.st147.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged147`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap147 : PRE_first_tail_x15_r0_body.s1426.heap = PRE_first_tail_x15_r0_body.st147.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext147 : PRE_first_tail_x15_r0_body.s1426.next = PRE_first_tail_x15_r0_body.st147.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl147 : PRE_first_tail_x15_r0_body.s1426.ctl = PRE_first_tail_x15_r0_body.st147.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack147 : PRE_first_tail_x15_r0_body.s1426.stack = PRE_first_tail_x15_r0_body.st147.s5.stack ++ PRE_first_tail_x15_r0_body.s1425.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs147 : PRE_first_tail_x15_r0_body.s1426.jobs = PRE_first_tail_x15_r0_body.st147.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi147 : PRE_first_tail_x15_r0_body.s1426.ffi = PRE_first_tail_x15_r0_body.st147.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace147 : PRE_first_tail_x15_r0_body.s1426.trace = PRE_first_tail_x15_r0_body.st147.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores147 : PRE_first_tail_x15_r0_body.s1426.stores = PRE_first_tail_x15_r0_body.st147.s5.stores

end Host.Load.Run.Tpl
