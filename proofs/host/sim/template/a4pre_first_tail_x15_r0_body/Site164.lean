import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.st164.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 164 of chain `PRE_first_tail_x15_r0_body`: `plan__g164__g165` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1581`, the merged state `PRE_first_tail_x15_r0_body.s1582`,
the site template `PRE_first_tail_x15_r0_body.st164` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1583`: the merge.
The footprint's facts are in `SiteF164`, the compaction's in `SiteC164`, `SiteK164`, `SiteNa164`, `SiteNb164`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso164 : PRE_first_tail_x15_r0_body.st164.s0 = { PRE_first_tail_x15_r0_body.s1581 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs164 : List Frame := PRE_first_tail_x15_r0_body.s1581.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_164 : PRE_first_tail_x15_r0_body.S1581.tab.length = 7066
kernel_rfl PRE_first_tail_x15_r0_body.tab0_164 : PRE_first_tail_x15_r0_body.st164.S0.tab = PRE_first_tail_x15_r0_body.S1581.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws164 : List Nat := [3764, 3765, 3766, 3767, 3768, 3769, 3770, 3771, 3772]
kernel_rfl PRE_first_tail_x15_r0_body.fresh164 : (PRE_first_tail_x15_r0_body.S1581.tab.all fun e => PRE_first_tail_x15_r0_body.ws164.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1581.oracle.all fun q => PRE_first_tail_x15_r0_body.ws164.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab164 : PRE_first_tail_x15_r0_body.S1582.tab = PRE_first_tail_x15_r0_body.S1581.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws164
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen164 : PRE_first_tail_x15_r0_body.st164.S2.tab.length - PRE_first_tail_x15_r0_body.st164.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged164`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap164 : PRE_first_tail_x15_r0_body.s1582.heap = PRE_first_tail_x15_r0_body.st164.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext164 : PRE_first_tail_x15_r0_body.s1582.next = PRE_first_tail_x15_r0_body.st164.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl164 : PRE_first_tail_x15_r0_body.s1582.ctl = PRE_first_tail_x15_r0_body.st164.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack164 : PRE_first_tail_x15_r0_body.s1582.stack = PRE_first_tail_x15_r0_body.st164.s2.stack ++ PRE_first_tail_x15_r0_body.s1581.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs164 : PRE_first_tail_x15_r0_body.s1582.jobs = PRE_first_tail_x15_r0_body.st164.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi164 : PRE_first_tail_x15_r0_body.s1582.ffi = PRE_first_tail_x15_r0_body.st164.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace164 : PRE_first_tail_x15_r0_body.s1582.trace = PRE_first_tail_x15_r0_body.st164.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores164 : PRE_first_tail_x15_r0_body.s1582.stores = PRE_first_tail_x15_r0_body.st164.s2.stores

end Host.Load.Run.Tpl
