import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.a4pre_first_tail_x15_r0_body.st71.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 71 of chain `PRE_first_tail_x15_r0_body`: `plan__g71__g72` (`plan`), the call state `PRE_first_tail_x15_r0_body.s689`, the merged state `PRE_first_tail_x15_r0_body.s690`,
the site template `PRE_first_tail_x15_r0_body.st71` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s691`: the merge.
The footprint's facts are in `SiteF71`, the compaction's in `SiteC71`, `SiteK71`, `SiteNa71`, `SiteNb71`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso71 : PRE_first_tail_x15_r0_body.st71.s0 = { PRE_first_tail_x15_r0_body.s689 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs71 : List Frame := PRE_first_tail_x15_r0_body.s689.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_71 : PRE_first_tail_x15_r0_body.S689.tab.length = 3088
kernel_rfl PRE_first_tail_x15_r0_body.tab0_71 : PRE_first_tail_x15_r0_body.st71.S0.tab = PRE_first_tail_x15_r0_body.S689.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws71 : List Nat := [2197, 2198, 2199]
kernel_rfl PRE_first_tail_x15_r0_body.fresh71 : (PRE_first_tail_x15_r0_body.S689.tab.all fun e => PRE_first_tail_x15_r0_body.ws71.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S689.oracle.all fun q => PRE_first_tail_x15_r0_body.ws71.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab71 : PRE_first_tail_x15_r0_body.S690.tab = PRE_first_tail_x15_r0_body.S689.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws71
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen71 : PRE_first_tail_x15_r0_body.st71.S2.tab.length - PRE_first_tail_x15_r0_body.st71.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged71`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap71 : PRE_first_tail_x15_r0_body.s690.heap = PRE_first_tail_x15_r0_body.st71.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext71 : PRE_first_tail_x15_r0_body.s690.next = PRE_first_tail_x15_r0_body.st71.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl71 : PRE_first_tail_x15_r0_body.s690.ctl = PRE_first_tail_x15_r0_body.st71.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack71 : PRE_first_tail_x15_r0_body.s690.stack = PRE_first_tail_x15_r0_body.st71.s2.stack ++ PRE_first_tail_x15_r0_body.s689.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs71 : PRE_first_tail_x15_r0_body.s690.jobs = PRE_first_tail_x15_r0_body.st71.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi71 : PRE_first_tail_x15_r0_body.s690.ffi = PRE_first_tail_x15_r0_body.st71.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace71 : PRE_first_tail_x15_r0_body.s690.trace = PRE_first_tail_x15_r0_body.st71.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores71 : PRE_first_tail_x15_r0_body.s690.stores = PRE_first_tail_x15_r0_body.st71.s2.stores

end Host.Load.Run.Tpl
