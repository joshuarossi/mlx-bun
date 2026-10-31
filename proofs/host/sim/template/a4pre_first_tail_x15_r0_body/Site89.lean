import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.a4pre_first_tail_x15_r0_body.st89.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 89 of chain `PRE_first_tail_x15_r0_body`: `plan__g89__g90` (`plan`), the call state `PRE_first_tail_x15_r0_body.s787`, the merged state `PRE_first_tail_x15_r0_body.s788`,
the site template `PRE_first_tail_x15_r0_body.st89` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s789`: the merge.
The footprint's facts are in `SiteF89`, the compaction's in `SiteC89`, `SiteK89`, `SiteNa89`, `SiteNb89`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso89 : PRE_first_tail_x15_r0_body.st89.s0 = { PRE_first_tail_x15_r0_body.s787 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs89 : List Frame := PRE_first_tail_x15_r0_body.s787.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_89 : PRE_first_tail_x15_r0_body.S787.tab.length = 3859
kernel_rfl PRE_first_tail_x15_r0_body.tab0_89 : PRE_first_tail_x15_r0_body.st89.S0.tab = PRE_first_tail_x15_r0_body.S787.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws89 : List Nat := [2498, 2499, 2500, 2501, 2502, 2503, 2504, 2505, 2506]
kernel_rfl PRE_first_tail_x15_r0_body.fresh89 : (PRE_first_tail_x15_r0_body.S787.tab.all fun e => PRE_first_tail_x15_r0_body.ws89.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S787.oracle.all fun q => PRE_first_tail_x15_r0_body.ws89.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab89 : PRE_first_tail_x15_r0_body.S788.tab = PRE_first_tail_x15_r0_body.S787.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws89
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen89 : PRE_first_tail_x15_r0_body.st89.S2.tab.length - PRE_first_tail_x15_r0_body.st89.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged89`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap89 : PRE_first_tail_x15_r0_body.s788.heap = PRE_first_tail_x15_r0_body.st89.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext89 : PRE_first_tail_x15_r0_body.s788.next = PRE_first_tail_x15_r0_body.st89.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl89 : PRE_first_tail_x15_r0_body.s788.ctl = PRE_first_tail_x15_r0_body.st89.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack89 : PRE_first_tail_x15_r0_body.s788.stack = PRE_first_tail_x15_r0_body.st89.s2.stack ++ PRE_first_tail_x15_r0_body.s787.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs89 : PRE_first_tail_x15_r0_body.s788.jobs = PRE_first_tail_x15_r0_body.st89.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi89 : PRE_first_tail_x15_r0_body.s788.ffi = PRE_first_tail_x15_r0_body.st89.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace89 : PRE_first_tail_x15_r0_body.s788.trace = PRE_first_tail_x15_r0_body.st89.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores89 : PRE_first_tail_x15_r0_body.s788.stores = PRE_first_tail_x15_r0_body.st89.s2.stores

end Host.Load.Run.Tpl
