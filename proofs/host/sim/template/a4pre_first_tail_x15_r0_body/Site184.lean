import host.sim.template.a4pre_first_tail_x15_r0_body.H55
import host.sim.template.a4pre_first_tail_x15_r0_body.st184.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 184 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g184__g185` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1778`, the merged state `PRE_first_tail_x15_r0_body.s1779`,
the site template `PRE_first_tail_x15_r0_body.st184` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1780`: the merge.
The footprint's facts are in `SiteF184`, the compaction's in `SiteC184`, `SiteK184`, `SiteNa184`, `SiteNb184`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso184 : PRE_first_tail_x15_r0_body.st184.s0 = { PRE_first_tail_x15_r0_body.s1778 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs184 : List Frame := PRE_first_tail_x15_r0_body.s1778.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_184 : PRE_first_tail_x15_r0_body.S1778.tab.length = 7946
kernel_rfl PRE_first_tail_x15_r0_body.tab0_184 : PRE_first_tail_x15_r0_body.st184.S0.tab = PRE_first_tail_x15_r0_body.S1778.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws184 : List Nat := [4136, 4137]
kernel_rfl PRE_first_tail_x15_r0_body.fresh184 : (PRE_first_tail_x15_r0_body.S1778.tab.all fun e => PRE_first_tail_x15_r0_body.ws184.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1778.oracle.all fun q => PRE_first_tail_x15_r0_body.ws184.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab184 : PRE_first_tail_x15_r0_body.S1779.tab = PRE_first_tail_x15_r0_body.S1778.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws184
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen184 : PRE_first_tail_x15_r0_body.st184.S2.tab.length - PRE_first_tail_x15_r0_body.st184.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged184`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap184 : PRE_first_tail_x15_r0_body.s1779.heap = PRE_first_tail_x15_r0_body.st184.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext184 : PRE_first_tail_x15_r0_body.s1779.next = PRE_first_tail_x15_r0_body.st184.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl184 : PRE_first_tail_x15_r0_body.s1779.ctl = PRE_first_tail_x15_r0_body.st184.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack184 : PRE_first_tail_x15_r0_body.s1779.stack = PRE_first_tail_x15_r0_body.st184.s2.stack ++ PRE_first_tail_x15_r0_body.s1778.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs184 : PRE_first_tail_x15_r0_body.s1779.jobs = PRE_first_tail_x15_r0_body.st184.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi184 : PRE_first_tail_x15_r0_body.s1779.ffi = PRE_first_tail_x15_r0_body.st184.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace184 : PRE_first_tail_x15_r0_body.s1779.trace = PRE_first_tail_x15_r0_body.st184.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores184 : PRE_first_tail_x15_r0_body.s1779.stores = PRE_first_tail_x15_r0_body.st184.s2.stores

end Host.Load.Run.Tpl
