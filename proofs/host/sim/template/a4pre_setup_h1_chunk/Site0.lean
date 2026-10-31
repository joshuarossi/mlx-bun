import host.sim.template.a4pre_setup_h1_chunk.H0
import host.sim.template.a4pre_setup_h1_chunk.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_setup_h1_chunk`: `chunk_K1024__start__g1` (`chunkSize`), the call state `PRE_setup_h1_chunk.s0`, the merged state `PRE_setup_h1_chunk.s1`,
the site template `PRE_setup_h1_chunk.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_setup_h1_chunk.s2`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl PRE_setup_h1_chunk.iso0 : PRE_setup_h1_chunk.st0.s0 = { PRE_setup_h1_chunk.s0 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_setup_h1_chunk.rs0 : List Frame := PRE_setup_h1_chunk.s0.stack
kernel_rfl PRE_setup_h1_chunk.n0_0 : PRE_setup_h1_chunk.S0.tab.length = 10
kernel_rfl PRE_setup_h1_chunk.tab0_0 : PRE_setup_h1_chunk.st0.S0.tab = PRE_setup_h1_chunk.S0.tab

/-- The fresh variables of the stage's results. -/
def PRE_setup_h1_chunk.ws0 : List Nat := [1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 1086, 1087, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 1096, 1097, 1098, 1099, 1100, 1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1131, 1132, 1133, 1134, 1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 1144, 1145, 1146, 1147, 1148, 1149, 1150, 1151, 1152, 1153, 1154, 1155, 1156, 1157, 1158, 1159]
kernel_rfl PRE_setup_h1_chunk.fresh0 : (PRE_setup_h1_chunk.S0.tab.all fun e => PRE_setup_h1_chunk.ws0.all fun v => e.noVar v) &&
    (PRE_setup_h1_chunk.S0.oracle.all fun q => PRE_setup_h1_chunk.ws0.all fun v => q.noVar v) = true
kernel_rfl PRE_setup_h1_chunk.mergeTab0 : PRE_setup_h1_chunk.S1.tab = PRE_setup_h1_chunk.S0.tab ++ Conv.resTab PRE_setup_h1_chunk.ws0
kernel_rfl PRE_setup_h1_chunk.mergeLen0 : PRE_setup_h1_chunk.st0.S3.tab.length - PRE_setup_h1_chunk.st0.S0.tab.length = 160

-- The merged state: the instance's return state with the caller's frames (`PRE_setup_h1_chunk.merged0`, `merged_relB`).
kernel_rfl PRE_setup_h1_chunk.mheap0 : PRE_setup_h1_chunk.s1.heap = PRE_setup_h1_chunk.st0.s3.heap
kernel_rfl PRE_setup_h1_chunk.mnext0 : PRE_setup_h1_chunk.s1.next = PRE_setup_h1_chunk.st0.s3.next
kernel_rfl PRE_setup_h1_chunk.mctl0 : PRE_setup_h1_chunk.s1.ctl = PRE_setup_h1_chunk.st0.s3.ctl
kernel_rfl PRE_setup_h1_chunk.mstack0 : PRE_setup_h1_chunk.s1.stack = PRE_setup_h1_chunk.st0.s3.stack ++ PRE_setup_h1_chunk.s0.stack
kernel_rfl PRE_setup_h1_chunk.mjobs0 : PRE_setup_h1_chunk.s1.jobs = PRE_setup_h1_chunk.st0.s3.jobs
kernel_rfl PRE_setup_h1_chunk.mffi0 : PRE_setup_h1_chunk.s1.ffi = PRE_setup_h1_chunk.st0.s3.ffi
kernel_rfl PRE_setup_h1_chunk.mtrace0 : PRE_setup_h1_chunk.s1.trace = PRE_setup_h1_chunk.st0.s3.trace
kernel_rfl PRE_setup_h1_chunk.mstores0 : PRE_setup_h1_chunk.s1.stores = PRE_setup_h1_chunk.st0.s3.stores

end Host.Load.Run.Tpl
