import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.a4pre_first_tail_x15_r0_body.st87.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 87 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g87__g88` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s776`, the merged state `PRE_first_tail_x15_r0_body.s777`,
the site template `PRE_first_tail_x15_r0_body.st87` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s778`: the merge.
The footprint's facts are in `SiteF87`, the compaction's in `SiteC87`, `SiteK87`, `SiteNa87`, `SiteNb87`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso87 : PRE_first_tail_x15_r0_body.st87.s0 = { PRE_first_tail_x15_r0_body.s776 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs87 : List Frame := PRE_first_tail_x15_r0_body.s776.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_87 : PRE_first_tail_x15_r0_body.S776.tab.length = 3803
kernel_rfl PRE_first_tail_x15_r0_body.tab0_87 : PRE_first_tail_x15_r0_body.st87.S0.tab = PRE_first_tail_x15_r0_body.S776.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws87 : List Nat := [2447, 2448, 2449, 2450, 2451, 2452, 2453, 2454, 2455, 2456, 2457, 2458, 2459, 2460, 2461, 2462, 2463, 2464, 2465, 2466, 2467, 2468, 2469, 2470, 2471, 2472, 2473, 2474, 2475, 2476, 2477]
kernel_rfl PRE_first_tail_x15_r0_body.fresh87 : (PRE_first_tail_x15_r0_body.S776.tab.all fun e => PRE_first_tail_x15_r0_body.ws87.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S776.oracle.all fun q => PRE_first_tail_x15_r0_body.ws87.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab87 : PRE_first_tail_x15_r0_body.S777.tab = PRE_first_tail_x15_r0_body.S776.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws87
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen87 : PRE_first_tail_x15_r0_body.st87.S3.tab.length - PRE_first_tail_x15_r0_body.st87.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged87`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap87 : PRE_first_tail_x15_r0_body.s777.heap = PRE_first_tail_x15_r0_body.st87.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext87 : PRE_first_tail_x15_r0_body.s777.next = PRE_first_tail_x15_r0_body.st87.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl87 : PRE_first_tail_x15_r0_body.s777.ctl = PRE_first_tail_x15_r0_body.st87.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack87 : PRE_first_tail_x15_r0_body.s777.stack = PRE_first_tail_x15_r0_body.st87.s3.stack ++ PRE_first_tail_x15_r0_body.s776.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs87 : PRE_first_tail_x15_r0_body.s777.jobs = PRE_first_tail_x15_r0_body.st87.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi87 : PRE_first_tail_x15_r0_body.s777.ffi = PRE_first_tail_x15_r0_body.st87.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace87 : PRE_first_tail_x15_r0_body.s777.trace = PRE_first_tail_x15_r0_body.st87.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores87 : PRE_first_tail_x15_r0_body.s777.stores = PRE_first_tail_x15_r0_body.st87.s3.stores

end Host.Load.Run.Tpl
