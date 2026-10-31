import host.sim.template.a4pre_first_tail_x15_r0_body.H51
import host.sim.template.a4pre_first_tail_x15_r0_body.st188.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 188 of chain `PRE_first_tail_x15_r0_body`: `plan__g188__g189` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1654`, the merged state `PRE_first_tail_x15_r0_body.s1655`,
the site template `PRE_first_tail_x15_r0_body.st188` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1656`: the merge.
The footprint's facts are in `SiteF188`, the compaction's in `SiteC188`, `SiteK188`, `SiteNa188`, `SiteNb188`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso188 : PRE_first_tail_x15_r0_body.st188.s0 = { PRE_first_tail_x15_r0_body.s1654 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs188 : List Frame := PRE_first_tail_x15_r0_body.s1654.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_188 : PRE_first_tail_x15_r0_body.S1654.tab.length = 8092
kernel_rfl PRE_first_tail_x15_r0_body.tab0_188 : PRE_first_tail_x15_r0_body.st188.S0.tab = PRE_first_tail_x15_r0_body.S1654.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws188 : List Nat := [4198, 4199, 4200]
kernel_rfl PRE_first_tail_x15_r0_body.fresh188 : (PRE_first_tail_x15_r0_body.S1654.tab.all fun e => PRE_first_tail_x15_r0_body.ws188.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1654.oracle.all fun q => PRE_first_tail_x15_r0_body.ws188.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab188 : PRE_first_tail_x15_r0_body.S1655.tab = PRE_first_tail_x15_r0_body.S1654.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws188
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen188 : PRE_first_tail_x15_r0_body.st188.S2.tab.length - PRE_first_tail_x15_r0_body.st188.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged188`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap188 : PRE_first_tail_x15_r0_body.s1655.heap = PRE_first_tail_x15_r0_body.st188.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext188 : PRE_first_tail_x15_r0_body.s1655.next = PRE_first_tail_x15_r0_body.st188.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl188 : PRE_first_tail_x15_r0_body.s1655.ctl = PRE_first_tail_x15_r0_body.st188.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack188 : PRE_first_tail_x15_r0_body.s1655.stack = PRE_first_tail_x15_r0_body.st188.s2.stack ++ PRE_first_tail_x15_r0_body.s1654.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs188 : PRE_first_tail_x15_r0_body.s1655.jobs = PRE_first_tail_x15_r0_body.st188.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi188 : PRE_first_tail_x15_r0_body.s1655.ffi = PRE_first_tail_x15_r0_body.st188.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace188 : PRE_first_tail_x15_r0_body.s1655.trace = PRE_first_tail_x15_r0_body.st188.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores188 : PRE_first_tail_x15_r0_body.s1655.stores = PRE_first_tail_x15_r0_body.st188.s2.stores

end Host.Load.Run.Tpl
