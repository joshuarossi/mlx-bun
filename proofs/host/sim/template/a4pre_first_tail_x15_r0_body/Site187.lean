import host.sim.template.a4pre_first_tail_x15_r0_body.H56
import host.sim.template.a4pre_first_tail_x15_r0_body.st187.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 187 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g187__g188` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1807`, the merged state `PRE_first_tail_x15_r0_body.s1808`,
the site template `PRE_first_tail_x15_r0_body.st187` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1809`: the merge.
The footprint's facts are in `SiteF187`, the compaction's in `SiteC187`, `SiteK187`, `SiteNa187`, `SiteNb187`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso187 : PRE_first_tail_x15_r0_body.st187.s0 = { PRE_first_tail_x15_r0_body.s1807 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs187 : List Frame := PRE_first_tail_x15_r0_body.s1807.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_187 : PRE_first_tail_x15_r0_body.S1807.tab.length = 8075
kernel_rfl PRE_first_tail_x15_r0_body.tab0_187 : PRE_first_tail_x15_r0_body.st187.S0.tab = PRE_first_tail_x15_r0_body.S1807.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws187 : List Nat := [4196, 4197]
kernel_rfl PRE_first_tail_x15_r0_body.fresh187 : (PRE_first_tail_x15_r0_body.S1807.tab.all fun e => PRE_first_tail_x15_r0_body.ws187.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1807.oracle.all fun q => PRE_first_tail_x15_r0_body.ws187.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab187 : PRE_first_tail_x15_r0_body.S1808.tab = PRE_first_tail_x15_r0_body.S1807.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws187
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen187 : PRE_first_tail_x15_r0_body.st187.S2.tab.length - PRE_first_tail_x15_r0_body.st187.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged187`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap187 : PRE_first_tail_x15_r0_body.s1808.heap = PRE_first_tail_x15_r0_body.st187.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext187 : PRE_first_tail_x15_r0_body.s1808.next = PRE_first_tail_x15_r0_body.st187.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl187 : PRE_first_tail_x15_r0_body.s1808.ctl = PRE_first_tail_x15_r0_body.st187.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack187 : PRE_first_tail_x15_r0_body.s1808.stack = PRE_first_tail_x15_r0_body.st187.s2.stack ++ PRE_first_tail_x15_r0_body.s1807.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs187 : PRE_first_tail_x15_r0_body.s1808.jobs = PRE_first_tail_x15_r0_body.st187.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi187 : PRE_first_tail_x15_r0_body.s1808.ffi = PRE_first_tail_x15_r0_body.st187.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace187 : PRE_first_tail_x15_r0_body.s1808.trace = PRE_first_tail_x15_r0_body.st187.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores187 : PRE_first_tail_x15_r0_body.s1808.stores = PRE_first_tail_x15_r0_body.st187.s2.stores

end Host.Load.Run.Tpl
