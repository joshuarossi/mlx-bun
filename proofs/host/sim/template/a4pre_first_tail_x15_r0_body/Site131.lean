import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.a4pre_first_tail_x15_r0_body.st131.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 131 of chain `PRE_first_tail_x15_r0_body`: `plan__g131__g132` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1153`, the merged state `PRE_first_tail_x15_r0_body.s1154`,
the site template `PRE_first_tail_x15_r0_body.st131` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1155`: the merge.
The footprint's facts are in `SiteF131`, the compaction's in `SiteC131`, `SiteK131`, `SiteNa131`, `SiteNb131`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso131 : PRE_first_tail_x15_r0_body.st131.s0 = { PRE_first_tail_x15_r0_body.s1153 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs131 : List Frame := PRE_first_tail_x15_r0_body.s1153.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_131 : PRE_first_tail_x15_r0_body.S1153.tab.length = 5653
kernel_rfl PRE_first_tail_x15_r0_body.tab0_131 : PRE_first_tail_x15_r0_body.st131.S0.tab = PRE_first_tail_x15_r0_body.S1153.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws131 : List Nat := [3186, 3187, 3188]
kernel_rfl PRE_first_tail_x15_r0_body.fresh131 : (PRE_first_tail_x15_r0_body.S1153.tab.all fun e => PRE_first_tail_x15_r0_body.ws131.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1153.oracle.all fun q => PRE_first_tail_x15_r0_body.ws131.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab131 : PRE_first_tail_x15_r0_body.S1154.tab = PRE_first_tail_x15_r0_body.S1153.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws131
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen131 : PRE_first_tail_x15_r0_body.st131.S2.tab.length - PRE_first_tail_x15_r0_body.st131.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged131`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap131 : PRE_first_tail_x15_r0_body.s1154.heap = PRE_first_tail_x15_r0_body.st131.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext131 : PRE_first_tail_x15_r0_body.s1154.next = PRE_first_tail_x15_r0_body.st131.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl131 : PRE_first_tail_x15_r0_body.s1154.ctl = PRE_first_tail_x15_r0_body.st131.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack131 : PRE_first_tail_x15_r0_body.s1154.stack = PRE_first_tail_x15_r0_body.st131.s2.stack ++ PRE_first_tail_x15_r0_body.s1153.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs131 : PRE_first_tail_x15_r0_body.s1154.jobs = PRE_first_tail_x15_r0_body.st131.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi131 : PRE_first_tail_x15_r0_body.s1154.ffi = PRE_first_tail_x15_r0_body.st131.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace131 : PRE_first_tail_x15_r0_body.s1154.trace = PRE_first_tail_x15_r0_body.st131.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores131 : PRE_first_tail_x15_r0_body.s1154.stores = PRE_first_tail_x15_r0_body.st131.s2.stores

end Host.Load.Run.Tpl
