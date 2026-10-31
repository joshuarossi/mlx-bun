import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.a4pre_first_tail_x15_r0_body.st21.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 21 of chain `PRE_first_tail_x15_r0_body`: `kvW__g21__g22` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s217`, the merged state `PRE_first_tail_x15_r0_body.s218`,
the site template `PRE_first_tail_x15_r0_body.st21` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s219`: the merge.
The footprint's facts are in `SiteF21`, the compaction's in `SiteC21`, `SiteK21`, `SiteNa21`, `SiteNb21`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso21 : PRE_first_tail_x15_r0_body.st21.s0 = { PRE_first_tail_x15_r0_body.s217 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs21 : List Frame := PRE_first_tail_x15_r0_body.s217.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_21 : PRE_first_tail_x15_r0_body.S217.tab.length = 987
kernel_rfl PRE_first_tail_x15_r0_body.tab0_21 : PRE_first_tail_x15_r0_body.st21.S0.tab = PRE_first_tail_x15_r0_body.S217.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws21 : List Nat := [1361, 1362, 1363, 1364, 1365, 1366, 1367, 1368, 1369, 1370, 1371, 1372, 1373, 1374, 1375, 1376, 1377]
kernel_rfl PRE_first_tail_x15_r0_body.fresh21 : (PRE_first_tail_x15_r0_body.S217.tab.all fun e => PRE_first_tail_x15_r0_body.ws21.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S217.oracle.all fun q => PRE_first_tail_x15_r0_body.ws21.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab21 : PRE_first_tail_x15_r0_body.S218.tab = PRE_first_tail_x15_r0_body.S217.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws21
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen21 : PRE_first_tail_x15_r0_body.st21.S3.tab.length - PRE_first_tail_x15_r0_body.st21.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged21`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap21 : PRE_first_tail_x15_r0_body.s218.heap = PRE_first_tail_x15_r0_body.st21.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext21 : PRE_first_tail_x15_r0_body.s218.next = PRE_first_tail_x15_r0_body.st21.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl21 : PRE_first_tail_x15_r0_body.s218.ctl = PRE_first_tail_x15_r0_body.st21.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack21 : PRE_first_tail_x15_r0_body.s218.stack = PRE_first_tail_x15_r0_body.st21.s3.stack ++ PRE_first_tail_x15_r0_body.s217.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs21 : PRE_first_tail_x15_r0_body.s218.jobs = PRE_first_tail_x15_r0_body.st21.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi21 : PRE_first_tail_x15_r0_body.s218.ffi = PRE_first_tail_x15_r0_body.st21.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace21 : PRE_first_tail_x15_r0_body.s218.trace = PRE_first_tail_x15_r0_body.st21.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores21 : PRE_first_tail_x15_r0_body.s218.stores = PRE_first_tail_x15_r0_body.st21.s3.stores

end Host.Load.Run.Tpl
