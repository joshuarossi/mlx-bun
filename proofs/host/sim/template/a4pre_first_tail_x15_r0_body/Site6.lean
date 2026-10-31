import host.sim.template.a4pre_first_tail_x15_r0_body.H2
import host.sim.template.a4pre_first_tail_x15_r0_body.st6.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 6 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g6__g7` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s74`, the merged state `PRE_first_tail_x15_r0_body.s75`,
the site template `PRE_first_tail_x15_r0_body.st6` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s76`: the merge.
The footprint's facts are in `SiteF6`, the compaction's in `SiteC6`, `SiteK6`, `SiteNa6`, `SiteNb6`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso6 : PRE_first_tail_x15_r0_body.st6.s0 = { PRE_first_tail_x15_r0_body.s74 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs6 : List Frame := PRE_first_tail_x15_r0_body.s74.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_6 : PRE_first_tail_x15_r0_body.S74.tab.length = 341
kernel_rfl PRE_first_tail_x15_r0_body.tab0_6 : PRE_first_tail_x15_r0_body.st6.S0.tab = PRE_first_tail_x15_r0_body.S74.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws6 : List Nat := [1114, 1115, 1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1131, 1132, 1133, 1134, 1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 1144]
kernel_rfl PRE_first_tail_x15_r0_body.fresh6 : (PRE_first_tail_x15_r0_body.S74.tab.all fun e => PRE_first_tail_x15_r0_body.ws6.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S74.oracle.all fun q => PRE_first_tail_x15_r0_body.ws6.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab6 : PRE_first_tail_x15_r0_body.S75.tab = PRE_first_tail_x15_r0_body.S74.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws6
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen6 : PRE_first_tail_x15_r0_body.st6.S5.tab.length - PRE_first_tail_x15_r0_body.st6.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged6`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap6 : PRE_first_tail_x15_r0_body.s75.heap = PRE_first_tail_x15_r0_body.st6.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext6 : PRE_first_tail_x15_r0_body.s75.next = PRE_first_tail_x15_r0_body.st6.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl6 : PRE_first_tail_x15_r0_body.s75.ctl = PRE_first_tail_x15_r0_body.st6.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack6 : PRE_first_tail_x15_r0_body.s75.stack = PRE_first_tail_x15_r0_body.st6.s5.stack ++ PRE_first_tail_x15_r0_body.s74.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs6 : PRE_first_tail_x15_r0_body.s75.jobs = PRE_first_tail_x15_r0_body.st6.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi6 : PRE_first_tail_x15_r0_body.s75.ffi = PRE_first_tail_x15_r0_body.st6.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace6 : PRE_first_tail_x15_r0_body.s75.trace = PRE_first_tail_x15_r0_body.st6.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores6 : PRE_first_tail_x15_r0_body.s75.stores = PRE_first_tail_x15_r0_body.st6.s5.stores

end Host.Load.Run.Tpl
