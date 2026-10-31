import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.a4pre_first_tail_x15_r0_body.st12.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 12 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g12__g13` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s119`, the merged state `PRE_first_tail_x15_r0_body.s120`,
the site template `PRE_first_tail_x15_r0_body.st12` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s121`: the merge.
The footprint's facts are in `SiteF12`, the compaction's in `SiteC12`, `SiteK12`, `SiteNa12`, `SiteNb12`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso12 : PRE_first_tail_x15_r0_body.st12.s0 = { PRE_first_tail_x15_r0_body.s119 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs12 : List Frame := PRE_first_tail_x15_r0_body.s119.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_12 : PRE_first_tail_x15_r0_body.S119.tab.length = 596
kernel_rfl PRE_first_tail_x15_r0_body.tab0_12 : PRE_first_tail_x15_r0_body.st12.S0.tab = PRE_first_tail_x15_r0_body.S119.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws12 : List Nat := [1199, 1200, 1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 1218, 1219, 1220, 1221, 1222, 1223, 1224, 1225, 1226, 1227, 1228, 1229]
kernel_rfl PRE_first_tail_x15_r0_body.fresh12 : (PRE_first_tail_x15_r0_body.S119.tab.all fun e => PRE_first_tail_x15_r0_body.ws12.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S119.oracle.all fun q => PRE_first_tail_x15_r0_body.ws12.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab12 : PRE_first_tail_x15_r0_body.S120.tab = PRE_first_tail_x15_r0_body.S119.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws12
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen12 : PRE_first_tail_x15_r0_body.st12.S3.tab.length - PRE_first_tail_x15_r0_body.st12.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged12`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap12 : PRE_first_tail_x15_r0_body.s120.heap = PRE_first_tail_x15_r0_body.st12.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext12 : PRE_first_tail_x15_r0_body.s120.next = PRE_first_tail_x15_r0_body.st12.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl12 : PRE_first_tail_x15_r0_body.s120.ctl = PRE_first_tail_x15_r0_body.st12.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack12 : PRE_first_tail_x15_r0_body.s120.stack = PRE_first_tail_x15_r0_body.st12.s3.stack ++ PRE_first_tail_x15_r0_body.s119.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs12 : PRE_first_tail_x15_r0_body.s120.jobs = PRE_first_tail_x15_r0_body.st12.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi12 : PRE_first_tail_x15_r0_body.s120.ffi = PRE_first_tail_x15_r0_body.st12.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace12 : PRE_first_tail_x15_r0_body.s120.trace = PRE_first_tail_x15_r0_body.st12.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores12 : PRE_first_tail_x15_r0_body.s120.stores = PRE_first_tail_x15_r0_body.st12.s3.stores

end Host.Load.Run.Tpl
