import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.a4pre_first_tail_x15_r0_body.st81.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 81 of chain `PRE_first_tail_x15_r0_body`: `kvW__g81__g82` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s792`, the merged state `PRE_first_tail_x15_r0_body.s793`,
the site template `PRE_first_tail_x15_r0_body.st81` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s794`: the merge.
The footprint's facts are in `SiteF81`, the compaction's in `SiteC81`, `SiteK81`, `SiteNa81`, `SiteNb81`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso81 : PRE_first_tail_x15_r0_body.st81.s0 = { PRE_first_tail_x15_r0_body.s792 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs81 : List Frame := PRE_first_tail_x15_r0_body.s792.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_81 : PRE_first_tail_x15_r0_body.S792.tab.length = 3552
kernel_rfl PRE_first_tail_x15_r0_body.tab0_81 : PRE_first_tail_x15_r0_body.st81.S0.tab = PRE_first_tail_x15_r0_body.S792.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws81 : List Nat := [2362, 2363, 2364, 2365, 2366, 2367, 2368, 2369, 2370, 2371, 2372, 2373, 2374, 2375, 2376, 2377, 2378]
kernel_rfl PRE_first_tail_x15_r0_body.fresh81 : (PRE_first_tail_x15_r0_body.S792.tab.all fun e => PRE_first_tail_x15_r0_body.ws81.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S792.oracle.all fun q => PRE_first_tail_x15_r0_body.ws81.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab81 : PRE_first_tail_x15_r0_body.S793.tab = PRE_first_tail_x15_r0_body.S792.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws81
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen81 : PRE_first_tail_x15_r0_body.st81.S3.tab.length - PRE_first_tail_x15_r0_body.st81.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged81`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap81 : PRE_first_tail_x15_r0_body.s793.heap = PRE_first_tail_x15_r0_body.st81.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext81 : PRE_first_tail_x15_r0_body.s793.next = PRE_first_tail_x15_r0_body.st81.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl81 : PRE_first_tail_x15_r0_body.s793.ctl = PRE_first_tail_x15_r0_body.st81.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack81 : PRE_first_tail_x15_r0_body.s793.stack = PRE_first_tail_x15_r0_body.st81.s3.stack ++ PRE_first_tail_x15_r0_body.s792.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs81 : PRE_first_tail_x15_r0_body.s793.jobs = PRE_first_tail_x15_r0_body.st81.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi81 : PRE_first_tail_x15_r0_body.s793.ffi = PRE_first_tail_x15_r0_body.st81.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace81 : PRE_first_tail_x15_r0_body.s793.trace = PRE_first_tail_x15_r0_body.st81.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores81 : PRE_first_tail_x15_r0_body.s793.stores = PRE_first_tail_x15_r0_body.st81.s3.stores

end Host.Load.Run.Tpl
