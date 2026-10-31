import host.sim.template.a4pre_first_tail_x15_r0_body.H47
import host.sim.template.a4pre_first_tail_x15_r0_body.st156.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 156 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g156__g157` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1511`, the merged state `PRE_first_tail_x15_r0_body.s1512`,
the site template `PRE_first_tail_x15_r0_body.st156` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1513`: the merge.
The footprint's facts are in `SiteF156`, the compaction's in `SiteC156`, `SiteK156`, `SiteNa156`, `SiteNb156`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso156 : PRE_first_tail_x15_r0_body.st156.s0 = { PRE_first_tail_x15_r0_body.s1511 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs156 : List Frame := PRE_first_tail_x15_r0_body.s1511.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_156 : PRE_first_tail_x15_r0_body.S1511.tab.length = 6752
kernel_rfl PRE_first_tail_x15_r0_body.tab0_156 : PRE_first_tail_x15_r0_body.st156.S0.tab = PRE_first_tail_x15_r0_body.S1511.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws156 : List Nat := [3605, 3606, 3607, 3608, 3609, 3610, 3611, 3612, 3613, 3614, 3615, 3616, 3617, 3618, 3619, 3620, 3621, 3622, 3623, 3624, 3625, 3626, 3627, 3628, 3629, 3630, 3631, 3632, 3633, 3634, 3635]
kernel_rfl PRE_first_tail_x15_r0_body.fresh156 : (PRE_first_tail_x15_r0_body.S1511.tab.all fun e => PRE_first_tail_x15_r0_body.ws156.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1511.oracle.all fun q => PRE_first_tail_x15_r0_body.ws156.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab156 : PRE_first_tail_x15_r0_body.S1512.tab = PRE_first_tail_x15_r0_body.S1511.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws156
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen156 : PRE_first_tail_x15_r0_body.st156.S5.tab.length - PRE_first_tail_x15_r0_body.st156.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged156`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap156 : PRE_first_tail_x15_r0_body.s1512.heap = PRE_first_tail_x15_r0_body.st156.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext156 : PRE_first_tail_x15_r0_body.s1512.next = PRE_first_tail_x15_r0_body.st156.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl156 : PRE_first_tail_x15_r0_body.s1512.ctl = PRE_first_tail_x15_r0_body.st156.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack156 : PRE_first_tail_x15_r0_body.s1512.stack = PRE_first_tail_x15_r0_body.st156.s5.stack ++ PRE_first_tail_x15_r0_body.s1511.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs156 : PRE_first_tail_x15_r0_body.s1512.jobs = PRE_first_tail_x15_r0_body.st156.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi156 : PRE_first_tail_x15_r0_body.s1512.ffi = PRE_first_tail_x15_r0_body.st156.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace156 : PRE_first_tail_x15_r0_body.s1512.trace = PRE_first_tail_x15_r0_body.st156.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores156 : PRE_first_tail_x15_r0_body.s1512.stores = PRE_first_tail_x15_r0_body.st156.s5.stores

end Host.Load.Run.Tpl
