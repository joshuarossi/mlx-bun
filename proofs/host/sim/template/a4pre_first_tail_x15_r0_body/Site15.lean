import host.sim.template.a4pre_first_tail_x15_r0_body.H4
import host.sim.template.a4pre_first_tail_x15_r0_body.st15.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 15 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g15__g16` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s146`, the merged state `PRE_first_tail_x15_r0_body.s147`,
the site template `PRE_first_tail_x15_r0_body.st15` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s148`: the merge.
The footprint's facts are in `SiteF15`, the compaction's in `SiteC15`, `SiteK15`, `SiteNa15`, `SiteNb15`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso15 : PRE_first_tail_x15_r0_body.st15.s0 = { PRE_first_tail_x15_r0_body.s146 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs15 : List Frame := PRE_first_tail_x15_r0_body.s146.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_15 : PRE_first_tail_x15_r0_body.S146.tab.length = 725
kernel_rfl PRE_first_tail_x15_r0_body.tab0_15 : PRE_first_tail_x15_r0_body.st15.S0.tab = PRE_first_tail_x15_r0_body.S146.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws15 : List Nat := [1253, 1254, 1255, 1256, 1257, 1258, 1259, 1260, 1261, 1262, 1263, 1264, 1265, 1266, 1267, 1268, 1269, 1270, 1271, 1272, 1273, 1274, 1275, 1276, 1277, 1278, 1279, 1280, 1281, 1282, 1283]
kernel_rfl PRE_first_tail_x15_r0_body.fresh15 : (PRE_first_tail_x15_r0_body.S146.tab.all fun e => PRE_first_tail_x15_r0_body.ws15.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S146.oracle.all fun q => PRE_first_tail_x15_r0_body.ws15.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab15 : PRE_first_tail_x15_r0_body.S147.tab = PRE_first_tail_x15_r0_body.S146.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws15
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen15 : PRE_first_tail_x15_r0_body.st15.S3.tab.length - PRE_first_tail_x15_r0_body.st15.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged15`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap15 : PRE_first_tail_x15_r0_body.s147.heap = PRE_first_tail_x15_r0_body.st15.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext15 : PRE_first_tail_x15_r0_body.s147.next = PRE_first_tail_x15_r0_body.st15.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl15 : PRE_first_tail_x15_r0_body.s147.ctl = PRE_first_tail_x15_r0_body.st15.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack15 : PRE_first_tail_x15_r0_body.s147.stack = PRE_first_tail_x15_r0_body.st15.s3.stack ++ PRE_first_tail_x15_r0_body.s146.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs15 : PRE_first_tail_x15_r0_body.s147.jobs = PRE_first_tail_x15_r0_body.st15.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi15 : PRE_first_tail_x15_r0_body.s147.ffi = PRE_first_tail_x15_r0_body.st15.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace15 : PRE_first_tail_x15_r0_body.s147.trace = PRE_first_tail_x15_r0_body.st15.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores15 : PRE_first_tail_x15_r0_body.s147.stores = PRE_first_tail_x15_r0_body.st15.s3.stores

end Host.Load.Run.Tpl
