import host.sim.template.a4dec_ord.H0
import host.sim.template.a4dec_ord.st1.H4
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `DEC_ord`: `fwd_D1_warm_DFit__g1__g2` (`#2671709`), the call state `DEC_ord.s4`, the merged state `DEC_ord.s5`,
the site template `DEC_ord.st1` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_ord.s6`: the merge.
The footprint's facts are in `SiteF1`, the compaction's in `SiteC1`, `SiteK1`, `SiteNa1`, `SiteNb1`. -/

kernel_rfl DEC_ord.iso1 : DEC_ord.st1.s0 = { DEC_ord.s4 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_ord.rs1 : List Frame := DEC_ord.s4.stack
kernel_rfl DEC_ord.n0_1 : DEC_ord.S4.tab.length = 129
kernel_rfl DEC_ord.tab0_1 : DEC_ord.st1.S0.tab = DEC_ord.S4.tab

/-- The fresh variables of the stage's results. -/
def DEC_ord.ws1 : List Nat := [1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 1086, 1087, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 1096, 1097, 1098, 1099, 1100, 1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1131, 1132, 1133, 1134, 1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 1144, 1145, 1146, 1147, 1148, 1149, 1150, 1151, 1152, 1153, 1154, 1155, 1156, 1157, 1158, 1159, 1160, 1161, 1162, 1163, 1164, 1165, 1166, 1167, 1168, 1169, 1170, 1171, 1172, 1173, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184, 1185, 1186, 1187, 1188, 1189, 1190, 1191, 1192, 1193, 1194, 1195, 1196, 1197, 1198, 1199, 1200, 1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 1218, 1219, 1220, 1221, 1222, 1223, 1224, 1225, 1226, 1227, 1228, 1229, 1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1239, 1240, 1241, 1242, 1243, 1244, 1245, 1246, 1247, 1248, 1249, 1250, 1251, 1252, 1253, 1254, 1255, 1256, 1257, 1258, 1259, 1260, 1261, 1262, 1263, 1264, 1265, 1266, 1267, 1268, 1269, 1270, 1271]
kernel_rfl DEC_ord.fresh1 : (DEC_ord.S4.tab.all fun e => DEC_ord.ws1.all fun v => e.noVar v) &&
    (DEC_ord.S4.oracle.all fun q => DEC_ord.ws1.all fun v => q.noVar v) = true
kernel_rfl DEC_ord.mergeTab1 : DEC_ord.S5.tab = DEC_ord.S4.tab ++ Conv.resTab DEC_ord.ws1
kernel_rfl DEC_ord.mergeLen1 : DEC_ord.st1.S150.tab.length - DEC_ord.st1.S0.tab.length = 272

-- The merged state: the instance's return state with the caller's frames (`DEC_ord.merged1`, `merged_relB`).
kernel_rfl DEC_ord.mheap1 : DEC_ord.s5.heap = DEC_ord.st1.s150.heap
kernel_rfl DEC_ord.mnext1 : DEC_ord.s5.next = DEC_ord.st1.s150.next
kernel_rfl DEC_ord.mctl1 : DEC_ord.s5.ctl = DEC_ord.st1.s150.ctl
kernel_rfl DEC_ord.mstack1 : DEC_ord.s5.stack = DEC_ord.st1.s150.stack ++ DEC_ord.s4.stack
kernel_rfl DEC_ord.mjobs1 : DEC_ord.s5.jobs = DEC_ord.st1.s150.jobs
kernel_rfl DEC_ord.mffi1 : DEC_ord.s5.ffi = DEC_ord.st1.s150.ffi
kernel_rfl DEC_ord.mtrace1 : DEC_ord.s5.trace = DEC_ord.st1.s150.trace
kernel_rfl DEC_ord.mstores1 : DEC_ord.s5.stores = DEC_ord.st1.s150.stores

end Host.Load.Run.Tpl
