import host.sim.template.a4pre_first_tail_x15_r0.H0
import host.sim.template.a4pre_first_tail_x15_r0.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_first_tail_x15_r0`: `chunk_K2048__g0a__g0b` (`chunkSize`), the call state `PRE_first_tail_x15_r0.s4`, the merged state `PRE_first_tail_x15_r0.s5`,
the site template `PRE_first_tail_x15_r0.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0.s6`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl PRE_first_tail_x15_r0.iso0 : PRE_first_tail_x15_r0.st0.s0 = { PRE_first_tail_x15_r0.s4 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0.rs0 : List Frame := PRE_first_tail_x15_r0.s4.stack
kernel_rfl PRE_first_tail_x15_r0.n0_0 : PRE_first_tail_x15_r0.S4.tab.length = 10
kernel_rfl PRE_first_tail_x15_r0.tab0_0 : PRE_first_tail_x15_r0.st0.S0.tab = PRE_first_tail_x15_r0.S4.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0.ws0 : List Nat := [1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079]
kernel_rfl PRE_first_tail_x15_r0.fresh0 : (PRE_first_tail_x15_r0.S4.tab.all fun e => PRE_first_tail_x15_r0.ws0.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0.S4.oracle.all fun q => PRE_first_tail_x15_r0.ws0.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0.mergeTab0 : PRE_first_tail_x15_r0.S5.tab = PRE_first_tail_x15_r0.S4.tab ++ Conv.resTab PRE_first_tail_x15_r0.ws0
kernel_rfl PRE_first_tail_x15_r0.mergeLen0 : PRE_first_tail_x15_r0.st0.S2.tab.length - PRE_first_tail_x15_r0.st0.S0.tab.length = 80

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0.merged0`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0.mheap0 : PRE_first_tail_x15_r0.s5.heap = PRE_first_tail_x15_r0.st0.s2.heap
kernel_rfl PRE_first_tail_x15_r0.mnext0 : PRE_first_tail_x15_r0.s5.next = PRE_first_tail_x15_r0.st0.s2.next
kernel_rfl PRE_first_tail_x15_r0.mctl0 : PRE_first_tail_x15_r0.s5.ctl = PRE_first_tail_x15_r0.st0.s2.ctl
kernel_rfl PRE_first_tail_x15_r0.mstack0 : PRE_first_tail_x15_r0.s5.stack = PRE_first_tail_x15_r0.st0.s2.stack ++ PRE_first_tail_x15_r0.s4.stack
kernel_rfl PRE_first_tail_x15_r0.mjobs0 : PRE_first_tail_x15_r0.s5.jobs = PRE_first_tail_x15_r0.st0.s2.jobs
kernel_rfl PRE_first_tail_x15_r0.mffi0 : PRE_first_tail_x15_r0.s5.ffi = PRE_first_tail_x15_r0.st0.s2.ffi
kernel_rfl PRE_first_tail_x15_r0.mtrace0 : PRE_first_tail_x15_r0.s5.trace = PRE_first_tail_x15_r0.st0.s2.trace
kernel_rfl PRE_first_tail_x15_r0.mstores0 : PRE_first_tail_x15_r0.s5.stores = PRE_first_tail_x15_r0.st0.s2.stores

end Host.Load.Run.Tpl
