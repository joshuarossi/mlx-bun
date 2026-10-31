import host.sim.template.a4pre_first_tail_x15_r0_body.H28
import host.sim.template.a4pre_first_tail_x15_r0_body.st93.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 93 of chain `PRE_first_tail_x15_r0_body`: `kvW__g93__g94` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s907`, the merged state `PRE_first_tail_x15_r0_body.s908`,
the site template `PRE_first_tail_x15_r0_body.st93` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s909`: the merge.
The footprint's facts are in `SiteF93`, the compaction's in `SiteC93`, `SiteK93`, `SiteNa93`, `SiteNb93`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso93 : PRE_first_tail_x15_r0_body.st93.s0 = { PRE_first_tail_x15_r0_body.s907 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs93 : List Frame := PRE_first_tail_x15_r0_body.s907.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_93 : PRE_first_tail_x15_r0_body.S907.tab.length = 4065
kernel_rfl PRE_first_tail_x15_r0_body.tab0_93 : PRE_first_tail_x15_r0_body.st93.S0.tab = PRE_first_tail_x15_r0_body.S907.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws93 : List Nat := [2561, 2562, 2563, 2564, 2565, 2566, 2567, 2568, 2569, 2570, 2571, 2572, 2573, 2574, 2575, 2576, 2577]
kernel_rfl PRE_first_tail_x15_r0_body.fresh93 : (PRE_first_tail_x15_r0_body.S907.tab.all fun e => PRE_first_tail_x15_r0_body.ws93.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S907.oracle.all fun q => PRE_first_tail_x15_r0_body.ws93.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab93 : PRE_first_tail_x15_r0_body.S908.tab = PRE_first_tail_x15_r0_body.S907.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws93
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen93 : PRE_first_tail_x15_r0_body.st93.S3.tab.length - PRE_first_tail_x15_r0_body.st93.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged93`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap93 : PRE_first_tail_x15_r0_body.s908.heap = PRE_first_tail_x15_r0_body.st93.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext93 : PRE_first_tail_x15_r0_body.s908.next = PRE_first_tail_x15_r0_body.st93.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl93 : PRE_first_tail_x15_r0_body.s908.ctl = PRE_first_tail_x15_r0_body.st93.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack93 : PRE_first_tail_x15_r0_body.s908.stack = PRE_first_tail_x15_r0_body.st93.s3.stack ++ PRE_first_tail_x15_r0_body.s907.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs93 : PRE_first_tail_x15_r0_body.s908.jobs = PRE_first_tail_x15_r0_body.st93.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi93 : PRE_first_tail_x15_r0_body.s908.ffi = PRE_first_tail_x15_r0_body.st93.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace93 : PRE_first_tail_x15_r0_body.s908.trace = PRE_first_tail_x15_r0_body.st93.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores93 : PRE_first_tail_x15_r0_body.s908.stores = PRE_first_tail_x15_r0_body.st93.s3.stores

end Host.Load.Run.Tpl
