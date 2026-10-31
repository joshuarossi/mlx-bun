import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.a4pre_first_tail_x15_r0_body.st3.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 3 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g3__g4` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s45`, the merged state `PRE_first_tail_x15_r0_body.s46`,
the site template `PRE_first_tail_x15_r0_body.st3` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s47`: the merge.
The footprint's facts are in `SiteF3`, the compaction's in `SiteC3`, `SiteK3`, `SiteNa3`, `SiteNb3`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso3 : PRE_first_tail_x15_r0_body.st3.s0 = { PRE_first_tail_x15_r0_body.s45 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs3 : List Frame := PRE_first_tail_x15_r0_body.s45.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_3 : PRE_first_tail_x15_r0_body.S45.tab.length = 212
kernel_rfl PRE_first_tail_x15_r0_body.tab0_3 : PRE_first_tail_x15_r0_body.st3.S0.tab = PRE_first_tail_x15_r0_body.S45.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws3 : List Nat := [1060, 1061, 1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 1086, 1087, 1088, 1089, 1090]
kernel_rfl PRE_first_tail_x15_r0_body.fresh3 : (PRE_first_tail_x15_r0_body.S45.tab.all fun e => PRE_first_tail_x15_r0_body.ws3.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S45.oracle.all fun q => PRE_first_tail_x15_r0_body.ws3.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab3 : PRE_first_tail_x15_r0_body.S46.tab = PRE_first_tail_x15_r0_body.S45.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws3
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen3 : PRE_first_tail_x15_r0_body.st3.S5.tab.length - PRE_first_tail_x15_r0_body.st3.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged3`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap3 : PRE_first_tail_x15_r0_body.s46.heap = PRE_first_tail_x15_r0_body.st3.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext3 : PRE_first_tail_x15_r0_body.s46.next = PRE_first_tail_x15_r0_body.st3.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl3 : PRE_first_tail_x15_r0_body.s46.ctl = PRE_first_tail_x15_r0_body.st3.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack3 : PRE_first_tail_x15_r0_body.s46.stack = PRE_first_tail_x15_r0_body.st3.s5.stack ++ PRE_first_tail_x15_r0_body.s45.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs3 : PRE_first_tail_x15_r0_body.s46.jobs = PRE_first_tail_x15_r0_body.st3.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi3 : PRE_first_tail_x15_r0_body.s46.ffi = PRE_first_tail_x15_r0_body.st3.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace3 : PRE_first_tail_x15_r0_body.s46.trace = PRE_first_tail_x15_r0_body.st3.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores3 : PRE_first_tail_x15_r0_body.s46.stores = PRE_first_tail_x15_r0_body.st3.s5.stores

end Host.Load.Run.Tpl
