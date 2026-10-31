import host.sim.template.a4pre_first_tail_x15_r0_body.H20
import host.sim.template.a4pre_first_tail_x15_r0_body.st68.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 68 of chain `PRE_first_tail_x15_r0_body`: `plan__g68__g69` (`plan`), the call state `PRE_first_tail_x15_r0_body.s661`, the merged state `PRE_first_tail_x15_r0_body.s662`,
the site template `PRE_first_tail_x15_r0_body.st68` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s663`: the merge.
The footprint's facts are in `SiteF68`, the compaction's in `SiteC68`, `SiteK68`, `SiteNa68`, `SiteNb68`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso68 : PRE_first_tail_x15_r0_body.st68.s0 = { PRE_first_tail_x15_r0_body.s661 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs68 : List Frame := PRE_first_tail_x15_r0_body.s661.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_68 : PRE_first_tail_x15_r0_body.S661.tab.length = 2962
kernel_rfl PRE_first_tail_x15_r0_body.tab0_68 : PRE_first_tail_x15_r0_body.st68.S0.tab = PRE_first_tail_x15_r0_body.S661.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws68 : List Nat := [2166, 2167, 2168]
kernel_rfl PRE_first_tail_x15_r0_body.fresh68 : (PRE_first_tail_x15_r0_body.S661.tab.all fun e => PRE_first_tail_x15_r0_body.ws68.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S661.oracle.all fun q => PRE_first_tail_x15_r0_body.ws68.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab68 : PRE_first_tail_x15_r0_body.S662.tab = PRE_first_tail_x15_r0_body.S661.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws68
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen68 : PRE_first_tail_x15_r0_body.st68.S2.tab.length - PRE_first_tail_x15_r0_body.st68.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged68`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap68 : PRE_first_tail_x15_r0_body.s662.heap = PRE_first_tail_x15_r0_body.st68.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext68 : PRE_first_tail_x15_r0_body.s662.next = PRE_first_tail_x15_r0_body.st68.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl68 : PRE_first_tail_x15_r0_body.s662.ctl = PRE_first_tail_x15_r0_body.st68.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack68 : PRE_first_tail_x15_r0_body.s662.stack = PRE_first_tail_x15_r0_body.st68.s2.stack ++ PRE_first_tail_x15_r0_body.s661.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs68 : PRE_first_tail_x15_r0_body.s662.jobs = PRE_first_tail_x15_r0_body.st68.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi68 : PRE_first_tail_x15_r0_body.s662.ffi = PRE_first_tail_x15_r0_body.st68.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace68 : PRE_first_tail_x15_r0_body.s662.trace = PRE_first_tail_x15_r0_body.st68.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores68 : PRE_first_tail_x15_r0_body.s662.stores = PRE_first_tail_x15_r0_body.st68.s2.stores

end Host.Load.Run.Tpl
