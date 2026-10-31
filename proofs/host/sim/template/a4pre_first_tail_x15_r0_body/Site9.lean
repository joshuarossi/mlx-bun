import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.a4pre_first_tail_x15_r0_body.st9.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 9 of chain `PRE_first_tail_x15_r0_body`: `kvW__g9__g10` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s102`, the merged state `PRE_first_tail_x15_r0_body.s103`,
the site template `PRE_first_tail_x15_r0_body.st9` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s104`: the merge.
The footprint's facts are in `SiteF9`, the compaction's in `SiteC9`, `SiteK9`, `SiteNa9`, `SiteNb9`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso9 : PRE_first_tail_x15_r0_body.st9.s0 = { PRE_first_tail_x15_r0_body.s102 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs9 : List Frame := PRE_first_tail_x15_r0_body.s102.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_9 : PRE_first_tail_x15_r0_body.S102.tab.length = 474
kernel_rfl PRE_first_tail_x15_r0_body.tab0_9 : PRE_first_tail_x15_r0_body.st9.S0.tab = PRE_first_tail_x15_r0_body.S102.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws9 : List Nat := [1168, 1169, 1170, 1171, 1172, 1173, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184]
kernel_rfl PRE_first_tail_x15_r0_body.fresh9 : (PRE_first_tail_x15_r0_body.S102.tab.all fun e => PRE_first_tail_x15_r0_body.ws9.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S102.oracle.all fun q => PRE_first_tail_x15_r0_body.ws9.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab9 : PRE_first_tail_x15_r0_body.S103.tab = PRE_first_tail_x15_r0_body.S102.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws9
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen9 : PRE_first_tail_x15_r0_body.st9.S3.tab.length - PRE_first_tail_x15_r0_body.st9.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged9`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap9 : PRE_first_tail_x15_r0_body.s103.heap = PRE_first_tail_x15_r0_body.st9.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext9 : PRE_first_tail_x15_r0_body.s103.next = PRE_first_tail_x15_r0_body.st9.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl9 : PRE_first_tail_x15_r0_body.s103.ctl = PRE_first_tail_x15_r0_body.st9.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack9 : PRE_first_tail_x15_r0_body.s103.stack = PRE_first_tail_x15_r0_body.st9.s3.stack ++ PRE_first_tail_x15_r0_body.s102.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs9 : PRE_first_tail_x15_r0_body.s103.jobs = PRE_first_tail_x15_r0_body.st9.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi9 : PRE_first_tail_x15_r0_body.s103.ffi = PRE_first_tail_x15_r0_body.st9.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace9 : PRE_first_tail_x15_r0_body.s103.trace = PRE_first_tail_x15_r0_body.st9.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores9 : PRE_first_tail_x15_r0_body.s103.stores = PRE_first_tail_x15_r0_body.st9.s3.stores

end Host.Load.Run.Tpl
