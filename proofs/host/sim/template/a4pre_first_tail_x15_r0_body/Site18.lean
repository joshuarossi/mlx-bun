import host.sim.template.a4pre_first_tail_x15_r0_body.H5
import host.sim.template.a4pre_first_tail_x15_r0_body.st18.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 18 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g18__g19` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s173`, the merged state `PRE_first_tail_x15_r0_body.s174`,
the site template `PRE_first_tail_x15_r0_body.st18` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s175`: the merge.
The footprint's facts are in `SiteF18`, the compaction's in `SiteC18`, `SiteK18`, `SiteNa18`, `SiteNb18`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso18 : PRE_first_tail_x15_r0_body.st18.s0 = { PRE_first_tail_x15_r0_body.s173 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs18 : List Frame := PRE_first_tail_x15_r0_body.s173.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_18 : PRE_first_tail_x15_r0_body.S173.tab.length = 854
kernel_rfl PRE_first_tail_x15_r0_body.tab0_18 : PRE_first_tail_x15_r0_body.st18.S0.tab = PRE_first_tail_x15_r0_body.S173.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws18 : List Nat := [1307, 1308, 1309, 1310, 1311, 1312, 1313, 1314, 1315, 1316, 1317, 1318, 1319, 1320, 1321, 1322, 1323, 1324, 1325, 1326, 1327, 1328, 1329, 1330, 1331, 1332, 1333, 1334, 1335, 1336, 1337]
kernel_rfl PRE_first_tail_x15_r0_body.fresh18 : (PRE_first_tail_x15_r0_body.S173.tab.all fun e => PRE_first_tail_x15_r0_body.ws18.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S173.oracle.all fun q => PRE_first_tail_x15_r0_body.ws18.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab18 : PRE_first_tail_x15_r0_body.S174.tab = PRE_first_tail_x15_r0_body.S173.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws18
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen18 : PRE_first_tail_x15_r0_body.st18.S3.tab.length - PRE_first_tail_x15_r0_body.st18.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged18`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap18 : PRE_first_tail_x15_r0_body.s174.heap = PRE_first_tail_x15_r0_body.st18.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext18 : PRE_first_tail_x15_r0_body.s174.next = PRE_first_tail_x15_r0_body.st18.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl18 : PRE_first_tail_x15_r0_body.s174.ctl = PRE_first_tail_x15_r0_body.st18.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack18 : PRE_first_tail_x15_r0_body.s174.stack = PRE_first_tail_x15_r0_body.st18.s3.stack ++ PRE_first_tail_x15_r0_body.s173.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs18 : PRE_first_tail_x15_r0_body.s174.jobs = PRE_first_tail_x15_r0_body.st18.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi18 : PRE_first_tail_x15_r0_body.s174.ffi = PRE_first_tail_x15_r0_body.st18.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace18 : PRE_first_tail_x15_r0_body.s174.trace = PRE_first_tail_x15_r0_body.st18.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores18 : PRE_first_tail_x15_r0_body.s174.stores = PRE_first_tail_x15_r0_body.st18.s3.stores

end Host.Load.Run.Tpl
