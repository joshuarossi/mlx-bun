import host.sim.template.a4pre_first_tail_x15_r0_body.H39
import host.sim.template.a4pre_first_tail_x15_r0_body.st144.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 144 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g144__g145` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1274`, the merged state `PRE_first_tail_x15_r0_body.s1275`,
the site template `PRE_first_tail_x15_r0_body.st144` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1276`: the merge.
The footprint's facts are in `SiteF144`, the compaction's in `SiteC144`, `SiteK144`, `SiteNa144`, `SiteNb144`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso144 : PRE_first_tail_x15_r0_body.st144.s0 = { PRE_first_tail_x15_r0_body.s1274 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs144 : List Frame := PRE_first_tail_x15_r0_body.s1274.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_144 : PRE_first_tail_x15_r0_body.S1274.tab.length = 6239
kernel_rfl PRE_first_tail_x15_r0_body.tab0_144 : PRE_first_tail_x15_r0_body.st144.S0.tab = PRE_first_tail_x15_r0_body.S1274.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws144 : List Nat := [3400, 3401, 3402, 3403, 3404, 3405, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413, 3414, 3415, 3416, 3417, 3418, 3419, 3420, 3421, 3422, 3423, 3424, 3425, 3426, 3427, 3428, 3429, 3430]
kernel_rfl PRE_first_tail_x15_r0_body.fresh144 : (PRE_first_tail_x15_r0_body.S1274.tab.all fun e => PRE_first_tail_x15_r0_body.ws144.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1274.oracle.all fun q => PRE_first_tail_x15_r0_body.ws144.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab144 : PRE_first_tail_x15_r0_body.S1275.tab = PRE_first_tail_x15_r0_body.S1274.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws144
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen144 : PRE_first_tail_x15_r0_body.st144.S3.tab.length - PRE_first_tail_x15_r0_body.st144.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged144`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap144 : PRE_first_tail_x15_r0_body.s1275.heap = PRE_first_tail_x15_r0_body.st144.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext144 : PRE_first_tail_x15_r0_body.s1275.next = PRE_first_tail_x15_r0_body.st144.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl144 : PRE_first_tail_x15_r0_body.s1275.ctl = PRE_first_tail_x15_r0_body.st144.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack144 : PRE_first_tail_x15_r0_body.s1275.stack = PRE_first_tail_x15_r0_body.st144.s3.stack ++ PRE_first_tail_x15_r0_body.s1274.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs144 : PRE_first_tail_x15_r0_body.s1275.jobs = PRE_first_tail_x15_r0_body.st144.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi144 : PRE_first_tail_x15_r0_body.s1275.ffi = PRE_first_tail_x15_r0_body.st144.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace144 : PRE_first_tail_x15_r0_body.s1275.trace = PRE_first_tail_x15_r0_body.st144.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores144 : PRE_first_tail_x15_r0_body.s1275.stores = PRE_first_tail_x15_r0_body.st144.s3.stores

end Host.Load.Run.Tpl
