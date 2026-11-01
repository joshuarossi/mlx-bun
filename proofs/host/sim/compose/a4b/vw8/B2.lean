import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x8_r0_body.States
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B17
import host.sim.compose.a4b.vw8.B1
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B34
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw8.VWBodyChain
import host.sim.compose.a4b.vw8.VWBodyMap
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B14
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B18

section -- VWBodyOracles_4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_g16 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g16 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g16) (List.take 7 (List.drop 158 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site16 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site16 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site16) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st16.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g17 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g17 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g17) (List.take 3 (List.drop 165 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site17 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site17 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site17) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g18 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g18 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g18) (List.take 16 (List.drop 168 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site18 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site18 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site18) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st18.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g19 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g19 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g19) (List.take 7 (List.drop 184 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site19 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site19 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site19) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st19.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site16 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site16 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site16) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st16.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site16
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st16.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st16.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s168 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s169 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S168 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws16 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st16.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st16.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso16
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_16
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st16.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot16
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup16
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound16
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace16
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged16
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws16.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st16.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S168.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_16]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen16.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh16
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl16 : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s168.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl16 (PRE_first_tail_x8_r0_body.cncl15 bodyNcl15)

theorem bodyClean16 : Conv.JClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s168 :=
  PRE_first_tail_x8_r0_body.gjcl16 (PRE_first_tail_x8_r0_body.cjcl15 bodyClean15)

kernel_rfl bodyJsLe16 : Nat.ble PRE_first_tail_x8_r0_body.s160.next PRE_first_tail_x8_r0_body.s168.next = true
kernel_rfl bodyJsList16 : (PRE_first_tail_x8_r0_body.gjh16 ++ PRE_first_tail_x8_r0_body.cl16).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s168.next) PRE_first_tail_x8_r0_body.s170) = true
theorem bodyJs16 : JsHeapAbove PRE_first_tail_x8_r0_body.s168.next PRE_first_tail_x8_r0_body.s170 :=
  JsHeapAbove.glueSite bodyJs15 (Nat.le_of_ble_eq_true bodyJsLe16) PRE_first_tail_x8_r0_body.gjk16 PRE_first_tail_x8_r0_body.gjbd16 PRE_first_tail_x8_r0_body.cheap16 PRE_first_tail_x8_r0_body.zclbd16 bodyJsList16

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO162 : PRE_first_tail_x8_r0_body.S162.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S162.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr162 : bridgeOf PRE_first_tail_x8_r0_body.s162.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc162 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s162 PRE_first_tail_x8_r0_body.S162) = fun _ _ => true
kernel_rfl bodyAcc163 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s163 PRE_first_tail_x8_r0_body.S163) = fun _ _ => true
kernel_rfl bodyBr164 : bridgeOf PRE_first_tail_x8_r0_body.s164.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt163 : isHalt PRE_first_tail_x8_r0_body.s163.ctl = false
kernel_rfl bodyTop164 : noRetBlock PRE_first_tail_x8_r0_body.s164 = true
kernel_rfl bodyCnt162 : countersOkB PRE_first_tail_x8_r0_body.s162 PRE_first_tail_x8_r0_body.s164 = true
kernel_rfl bodyO164 : PRE_first_tail_x8_r0_body.S164.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S164.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr165 : bridgeOf PRE_first_tail_x8_r0_body.s165.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt164 : countersOkB PRE_first_tail_x8_r0_body.s164 PRE_first_tail_x8_r0_body.s165 = true
kernel_rfl bodyO165 : PRE_first_tail_x8_r0_body.S165.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S165.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc165 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s165 PRE_first_tail_x8_r0_body.S165) = fun _ _ => true
kernel_rfl bodyAcc167 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s167 PRE_first_tail_x8_r0_body.S167) = fun _ _ => true
kernel_rfl bodyBr168 : bridgeOf PRE_first_tail_x8_r0_body.s168.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt167 : isHalt PRE_first_tail_x8_r0_body.s167.ctl = false
kernel_rfl bodyTop168 : noRetBlock PRE_first_tail_x8_r0_body.s168 = true
kernel_rfl bodyCnt165 : countersOkB PRE_first_tail_x8_r0_body.s165 PRE_first_tail_x8_r0_body.s168 = true

theorem bodyGlue16 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10279, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s162 PRE_first_tail_x8_r0_body.S162)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10279, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s168 PRE_first_tail_x8_r0_body.S168) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10279, 148, 0, 99⟩) bodyAcc162 PRE_first_tail_x8_r0_body.bodyRunSeg44 bodyAcc163 bodyHalt163 PRE_first_tail_x8_r0_body.bodyStepA45 bodyTop164 (fun _ hm => bodyO162 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr162).trans bodyInactive0) (bodyBr164.trans bodyBr162.symm) bodyCnt162 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10279, 148, 0, 99⟩) PRE_first_tail_x8_r0_body.sizeA45 PRE_first_tail_x8_r0_body.sizeArgsA45 PRE_first_tail_x8_r0_body.sizeSymA45 PRE_first_tail_x8_r0_body.sizeMlxA45 PRE_first_tail_x8_r0_body.sizePayA45 PRE_first_tail_x8_r0_body.sizeTaA45 PRE_first_tail_x8_r0_body.sizeDecA45 PRE_first_tail_x8_r0_body.sizePreA45 PRE_first_tail_x8_r0_body.bodyPatchB45 (fun _ hm => bodyO164 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr164).trans bodyInactive0) (bodyBr165.trans bodyBr164.symm) bodyCnt164 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10279, 148, 0, 99⟩) bodyAcc165 PRE_first_tail_x8_r0_body.bodyRunSeg45 bodyAcc167 bodyHalt167 PRE_first_tail_x8_r0_body.bodyStepA46 bodyTop168 (fun _ hm => bodyO165 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr165).trans bodyInactive0) (bodyBr168.trans bodyBr165.symm) bodyCnt165 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift16 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S168.tab.length PRE_first_tail_x8_r0_body.s168.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P16.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P16 764 PRE_first_tail_x8_r0_body.kappa16 PRE_first_tail_x8_r0_body.s170.ffi PRE_first_tail_x8_r0_body.s169.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_16
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_16
  have hcl : SSt (· < 764) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s170.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S168.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_16] <;> decide) PRE_first_tail_x8_r0_body.cnodesK16 PRE_first_tail_x8_r0_body.cobjsK16
      PRE_first_tail_x8_r0_body.citemsK16 PRE_first_tail_x8_r0_body.cbd16 PRE_first_tail_x8_r0_body.csst16
  exact PRE_first_tail_x8_r0_body.cshift16 bodyNcl16 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_16] at this; exact this)


kernel_rfl bodyFramesEmpty16 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s169 a).isEmpty) = true
kernel_rfl bodyJsRoots16 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s168.next) PRE_first_tail_x8_r0_body.s170.trace PRE_first_tail_x8_r0_body.s170 = true
kernel_rfl bodyJsNative16 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s170.ffi) = true
kernel_rfl bodyLow16 : (PRE_first_tail_x8_r0_body.cws16 ++ PRE_first_tail_x8_r0_body.ws16).all (Nat.ble 9) = true
kernel_rfl bodyCntM16 : countersOkB PRE_first_tail_x8_r0_body.s168 PRE_first_tail_x8_r0_body.s169 = true
kernel_rfl bodyHi16 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s170.ffi).next setupP.E = true
kernel_rfl bodyNhi16 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s170.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge16 : bridgeOf PRE_first_tail_x8_r0_body.s169.ffi = bridgeOf PRE_first_tail_x8_r0_body.s168.ffi
kernel_rfl bodyNN16 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s168.ffi).nnext PRE_first_tail_x8_r0_body.P16.NL = true
kernel_rfl bodyXn16 : Nat.ble (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s170.ffi).next = true
kernel_rfl bodyLo16 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s170.ffi).next = true
theorem bodyFacts16 : BodySiteFacts PRE_first_tail_x8_r0_body.s168 PRE_first_tail_x8_r0_body.s169 PRE_first_tail_x8_r0_body.s170 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S168 PRE_first_tail_x8_r0_body.S169 PRE_first_tail_x8_r0_body.S170
    PRE_first_tail_x8_r0_body.ws16 PRE_first_tail_x8_r0_body.cws16 PRE_first_tail_x8_r0_body.nr16 PRE_first_tail_x8_r0_body.pl16 PRE_first_tail_x8_r0_body.cl16 2687629 764 PRE_first_tail_x8_r0_body.kd16 PRE_first_tail_x8_r0_body.kappa16 PRE_first_tail_x8_r0_body.P16
    ⟨18525, 15618, 2687627, 764⟩ ⟨18525, 15618, 2687627, 764⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap16
  clean := bodyClean16
  cfix := PRE_first_tail_x8_r0_body.cfix16
  zpl := PRE_first_tail_x8_r0_body.zpl16
  zplnd := PRE_first_tail_x8_r0_body.zplnd16
  zn1 := PRE_first_tail_x8_r0_body.zn116
  zfirst := PRE_first_tail_x8_r0_body.zfirst16
  zscn := PRE_first_tail_x8_r0_body.zscn16
  zsmn := PRE_first_tail_x8_r0_body.zsmn16
  zgrow := PRE_first_tail_x8_r0_body.zgrow16
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab16
  zfresh := PRE_first_tail_x8_r0_body.zfresh16
  zcnd := PRE_first_tail_x8_r0_body.zcnd16
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi16
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt16
  zgP := PRE_first_tail_x8_r0_body.zg16_2665
  zkP := PRE_first_tail_x8_r0_body.zk16_2665
  zmP := PRE_first_tail_x8_r0_body.zm16_2665
  zgC := PRE_first_tail_x8_r0_body.zg16_2673467
  zkC := PRE_first_tail_x8_r0_body.zk16_2673467
  zmC := PRE_first_tail_x8_r0_body.zm16_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw16_2673472
  zwV := PRE_first_tail_x8_r0_body.zw16_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap16
  zclbd := PRE_first_tail_x8_r0_body.zclbd16
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap16 PRE_first_tail_x8_r0_body.stFoot16 PRE_first_tail_x8_r0_body.iso16 PRE_first_tail_x8_r0_body.zwr16
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP16
  csupp := PRE_first_tail_x8_r0_body.csupp16
  cbound := PRE_first_tail_x8_r0_body.cbound16
  zimg := PRE_first_tail_x8_r0_body.zimg16
  zctl := PRE_first_tail_x8_r0_body.zctl16
  zstack := PRE_first_tail_x8_r0_body.zstack16
  zjobs := PRE_first_tail_x8_r0_body.zjobs16
  zstores := PRE_first_tail_x8_r0_body.zstores16
  zroots := PRE_first_tail_x8_r0_body.zroots16
  znC := PRE_first_tail_x8_r0_body.znC16
  ctab := PRE_first_tail_x8_r0_body.ctab16
  zbin := PRE_first_tail_x8_r0_body.zbin16
  cbridge := PRE_first_tail_x8_r0_body.cbridge16
  sbridge := bodyBridge16
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj16
  cshiftR := fun h hNL => bodyCshift16 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN16
  raised := PRE_first_tail_x8_r0_body.raised16
  cbigs := PRE_first_tail_x8_r0_body.cbigs16
  cjcl := PRE_first_tail_x8_r0_body.cjcl16
  xnLe := Nat.le_of_ble_eq_true bodyXn16
  loLe := Nat.le_of_ble_eq_true bodyLo16
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB16
  cntM := bodyCntM16
  hiLe := Nat.le_of_ble_eq_true bodyHi16
  nhiLe := Nat.le_of_ble_eq_true bodyNhi16
  jsHeap := bodyJs16
  jsRoots := bodyJsRoots16
  jsNative := bodyJsNative16
  framesEmpty := bodyFramesEmpty16
  trailOld := by decide
  lowVars := bodyLow16

def bodyQs16 : List (Option Q) := []
noncomputable def bodyEs16 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr16.map fun r => nth? PRE_first_tail_x8_r0_body.st16.S2.tab r
kernel_rfl bodyResChk16 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs16 bodyQs16) = true
kernel_rfl bodyLq16 : bodyQs16.length = PRE_first_tail_x8_r0_body.cws16.length
kernel_rfl bodyNrLo16 : PRE_first_tail_x8_r0_body.nr16.all (Nat.ble PRE_first_tail_x8_r0_body.S168.tab.length) = true
kernel_rfl bodySub16 : (Oracles.PRE_first_tail_x8_r0_body.map_site16.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost16 : postSubB bodyM PRE_first_tail_x8_r0_body.ws16 PRE_first_tail_x8_r0_body.cws16 bodyQs16 = true
kernel_rfl bodyDrop16 : Nat.ble (10279 + (PRE_first_tail_x8_r0_body.s169.next - PRE_first_tail_x8_r0_body.s170.next)) 10281 = true
kernel_rfl bodyDropH16 : Nat.ble (148 + ((mlxOf PRE_first_tail_x8_r0_body.s169.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s170.ffi).next)) 148 = true
kernel_rfl bodyDropN16 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s169.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s170.ffi).nnext)) 0 = true
kernel_rfl bodyDv16 : bodyΘ.1.take 99 = bodyΘ.1.take 99 ++ PRE_first_tail_x8_r0_body.cws16
kernel_rfl bodyDe16 : bodyΘ.2.take 99 = bodyΘ.2.take 99 ++ PRE_first_tail_x8_r0_body.nr16.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st16.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 99) (bodyΘ.2.take 99)))
kernel_rfl bodyDl16 : (bodyΘ.1.take 99).length = (bodyΘ.2.take 99).length
kernel_rfl bodyDold16 : (bodyΘ.1.take 99).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws16).isNone && !PRE_first_tail_x8_r0_body.ws16.contains v) = true
kernel_rfl bodyDfree16 : (bodyΘ.2.take 99).all (fun e => (PRE_first_tail_x8_r0_body.cws16 ++ PRE_first_tail_x8_r0_body.ws16).all fun w => e.noVar w) = true

theorem bodyStep16 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10279, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s168 PRE_first_tail_x8_r0_body.S168)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10281, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s170 PRE_first_tail_x8_r0_body.S170) (27 + 1) :=
  bodySite bodyFacts16.cfix bodyFacts16.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x8_r0_body.st16.S2.tab) (Es := bodyEs16) (qs := bodyQs16)
    (ok := PRE_first_tail_x8_r0_body.st16.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site16 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts16
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site16 r hr) hi (MapOk.sub hm (sub_of_all bodySub16)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk16 r hr) hi hm ho hq)
    bodyLq16 rfl bodyNrLo16 (postSub_sound bodyPost16)
    (Nat.le_of_ble_eq_true bodyDrop16) (by decide) (Nat.le_of_ble_eq_true bodyDropH16) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN16) (by decide)
    bodyDv16 bodyDe16 bodyDl16 bodyDold16 bodyDfree16 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site17 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site17 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site17) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site17
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s172 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s173 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S172 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws17 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso17
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_17
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot17
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup17
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound17
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace17
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged17
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws17.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st17.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S172.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_17]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen17.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh17
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl17 : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s172.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl17 (PRE_first_tail_x8_r0_body.cncl16 bodyNcl16)

theorem bodyClean17 : Conv.JClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s172 :=
  PRE_first_tail_x8_r0_body.gjcl17 (PRE_first_tail_x8_r0_body.cjcl16 bodyClean16)

kernel_rfl bodyJsLe17 : Nat.ble PRE_first_tail_x8_r0_body.s168.next PRE_first_tail_x8_r0_body.s172.next = true
kernel_rfl bodyJsList17 : (PRE_first_tail_x8_r0_body.gjh17 ++ PRE_first_tail_x8_r0_body.cl17).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s172.next) PRE_first_tail_x8_r0_body.s174) = true
theorem bodyJs17 : JsHeapAbove PRE_first_tail_x8_r0_body.s172.next PRE_first_tail_x8_r0_body.s174 :=
  JsHeapAbove.glueSite bodyJs16 (Nat.le_of_ble_eq_true bodyJsLe17) PRE_first_tail_x8_r0_body.gjk17 PRE_first_tail_x8_r0_body.gjbd17 PRE_first_tail_x8_r0_body.cheap17 PRE_first_tail_x8_r0_body.zclbd17 bodyJsList17

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO170 : PRE_first_tail_x8_r0_body.S170.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S170.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr170 : bridgeOf PRE_first_tail_x8_r0_body.s170.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc170 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s170 PRE_first_tail_x8_r0_body.S170) = fun _ _ => true
kernel_rfl bodyAcc171 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s171 PRE_first_tail_x8_r0_body.S171) = fun _ _ => true
kernel_rfl bodyBr172 : bridgeOf PRE_first_tail_x8_r0_body.s172.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt171 : isHalt PRE_first_tail_x8_r0_body.s171.ctl = false
kernel_rfl bodyTop172 : noRetBlock PRE_first_tail_x8_r0_body.s172 = true
kernel_rfl bodyCnt170 : countersOkB PRE_first_tail_x8_r0_body.s170 PRE_first_tail_x8_r0_body.s172 = true

theorem bodyGlue17 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10281, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s170 PRE_first_tail_x8_r0_body.S170)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10281, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s172 PRE_first_tail_x8_r0_body.S172) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10281, 148, 0, 99⟩) bodyAcc170 PRE_first_tail_x8_r0_body.bodyRunSeg46 bodyAcc171 bodyHalt171 PRE_first_tail_x8_r0_body.bodyStepA47 bodyTop172 (fun _ hm => bodyO170 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr170).trans bodyInactive0) (bodyBr172.trans bodyBr170.symm) bodyCnt170 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift17 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S172.tab.length PRE_first_tail_x8_r0_body.s172.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P17.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P17 781 PRE_first_tail_x8_r0_body.kappa17 PRE_first_tail_x8_r0_body.s174.ffi PRE_first_tail_x8_r0_body.s173.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_17
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_17
  have hcl : SSt (· < 781) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s174.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S172.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_17] <;> decide) PRE_first_tail_x8_r0_body.cnodesK17 PRE_first_tail_x8_r0_body.cobjsK17
      PRE_first_tail_x8_r0_body.citemsK17 PRE_first_tail_x8_r0_body.cbd17 PRE_first_tail_x8_r0_body.csst17
  exact PRE_first_tail_x8_r0_body.cshift17 bodyNcl17 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_17] at this; exact this)


kernel_rfl bodyFramesEmpty17 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s173 a).isEmpty) = true
kernel_rfl bodyJsRoots17 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s172.next) PRE_first_tail_x8_r0_body.s174.trace PRE_first_tail_x8_r0_body.s174 = true
kernel_rfl bodyJsNative17 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s174.ffi) = true
kernel_rfl bodyLow17 : (PRE_first_tail_x8_r0_body.cws17 ++ PRE_first_tail_x8_r0_body.ws17).all (Nat.ble 9) = true
kernel_rfl bodyCntM17 : countersOkB PRE_first_tail_x8_r0_body.s172 PRE_first_tail_x8_r0_body.s173 = true
kernel_rfl bodyHi17 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s174.ffi).next setupP.E = true
kernel_rfl bodyNhi17 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s174.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge17 : bridgeOf PRE_first_tail_x8_r0_body.s173.ffi = bridgeOf PRE_first_tail_x8_r0_body.s172.ffi
kernel_rfl bodyNN17 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s172.ffi).nnext PRE_first_tail_x8_r0_body.P17.NL = true
kernel_rfl bodyXn17 : Nat.ble (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s174.ffi).next = true
kernel_rfl bodyLo17 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s174.ffi).next = true
theorem bodyFacts17 : BodySiteFacts PRE_first_tail_x8_r0_body.s172 PRE_first_tail_x8_r0_body.s173 PRE_first_tail_x8_r0_body.s174 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S172 PRE_first_tail_x8_r0_body.S173 PRE_first_tail_x8_r0_body.S174
    PRE_first_tail_x8_r0_body.ws17 PRE_first_tail_x8_r0_body.cws17 PRE_first_tail_x8_r0_body.nr17 PRE_first_tail_x8_r0_body.pl17 PRE_first_tail_x8_r0_body.cl17 2687926 781 PRE_first_tail_x8_r0_body.kd17 PRE_first_tail_x8_r0_body.kappa17 PRE_first_tail_x8_r0_body.P17
    ⟨18532, 15622, 2687915, 781⟩ ⟨18532, 15622, 2687916, 781⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap17
  clean := bodyClean17
  cfix := PRE_first_tail_x8_r0_body.cfix17
  zpl := PRE_first_tail_x8_r0_body.zpl17
  zplnd := PRE_first_tail_x8_r0_body.zplnd17
  zn1 := PRE_first_tail_x8_r0_body.zn117
  zfirst := PRE_first_tail_x8_r0_body.zfirst17
  zscn := PRE_first_tail_x8_r0_body.zscn17
  zsmn := PRE_first_tail_x8_r0_body.zsmn17
  zgrow := PRE_first_tail_x8_r0_body.zgrow17
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab17
  zfresh := PRE_first_tail_x8_r0_body.zfresh17
  zcnd := PRE_first_tail_x8_r0_body.zcnd17
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi17
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt17
  zgP := PRE_first_tail_x8_r0_body.zg17_2665
  zkP := PRE_first_tail_x8_r0_body.zk17_2665
  zmP := PRE_first_tail_x8_r0_body.zm17_2665
  zgC := PRE_first_tail_x8_r0_body.zg17_2673467
  zkC := PRE_first_tail_x8_r0_body.zk17_2673467
  zmC := PRE_first_tail_x8_r0_body.zm17_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw17_2673472
  zwV := PRE_first_tail_x8_r0_body.zw17_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap17
  zclbd := PRE_first_tail_x8_r0_body.zclbd17
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap17 PRE_first_tail_x8_r0_body.stFoot17 PRE_first_tail_x8_r0_body.iso17 PRE_first_tail_x8_r0_body.zwr17
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP17
  csupp := PRE_first_tail_x8_r0_body.csupp17
  cbound := PRE_first_tail_x8_r0_body.cbound17
  zimg := PRE_first_tail_x8_r0_body.zimg17
  zctl := PRE_first_tail_x8_r0_body.zctl17
  zstack := PRE_first_tail_x8_r0_body.zstack17
  zjobs := PRE_first_tail_x8_r0_body.zjobs17
  zstores := PRE_first_tail_x8_r0_body.zstores17
  zroots := PRE_first_tail_x8_r0_body.zroots17
  znC := PRE_first_tail_x8_r0_body.znC17
  ctab := PRE_first_tail_x8_r0_body.ctab17
  zbin := PRE_first_tail_x8_r0_body.zbin17
  cbridge := PRE_first_tail_x8_r0_body.cbridge17
  sbridge := bodyBridge17
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj17
  cshiftR := fun h hNL => bodyCshift17 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN17
  raised := PRE_first_tail_x8_r0_body.raised17
  cbigs := PRE_first_tail_x8_r0_body.cbigs17
  cjcl := PRE_first_tail_x8_r0_body.cjcl17
  xnLe := Nat.le_of_ble_eq_true bodyXn17
  loLe := Nat.le_of_ble_eq_true bodyLo17
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB17
  cntM := bodyCntM17
  hiLe := Nat.le_of_ble_eq_true bodyHi17
  nhiLe := Nat.le_of_ble_eq_true bodyNhi17
  jsHeap := bodyJs17
  jsRoots := bodyJsRoots17
  jsNative := bodyJsNative17
  framesEmpty := bodyFramesEmpty17
  trailOld := by decide
  lowVars := bodyLow17

def bodyQs17 : List (Option Q) := []
noncomputable def bodyEs17 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr17.map fun r => nth? PRE_first_tail_x8_r0_body.st17.S2.tab r
kernel_rfl bodyResChk17 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs17 bodyQs17) = true
kernel_rfl bodyLq17 : bodyQs17.length = PRE_first_tail_x8_r0_body.cws17.length
kernel_rfl bodyNrLo17 : PRE_first_tail_x8_r0_body.nr17.all (Nat.ble PRE_first_tail_x8_r0_body.S172.tab.length) = true
kernel_rfl bodySub17 : (Oracles.PRE_first_tail_x8_r0_body.map_site17.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost17 : postSubB bodyM PRE_first_tail_x8_r0_body.ws17 PRE_first_tail_x8_r0_body.cws17 bodyQs17 = true
kernel_rfl bodyDrop17 : Nat.ble (10281 + (PRE_first_tail_x8_r0_body.s173.next - PRE_first_tail_x8_r0_body.s174.next)) 10291 = true
kernel_rfl bodyDropH17 : Nat.ble (148 + ((mlxOf PRE_first_tail_x8_r0_body.s173.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s174.ffi).next)) 148 = true
kernel_rfl bodyDropN17 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s173.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s174.ffi).nnext)) 0 = true
kernel_rfl bodyDv17 : bodyΘ.1.take 99 = bodyΘ.1.take 99 ++ PRE_first_tail_x8_r0_body.cws17
kernel_rfl bodyDe17 : bodyΘ.2.take 99 = bodyΘ.2.take 99 ++ PRE_first_tail_x8_r0_body.nr17.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st17.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 99) (bodyΘ.2.take 99)))
kernel_rfl bodyDl17 : (bodyΘ.1.take 99).length = (bodyΘ.2.take 99).length
kernel_rfl bodyDold17 : (bodyΘ.1.take 99).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws17).isNone && !PRE_first_tail_x8_r0_body.ws17.contains v) = true
kernel_rfl bodyDfree17 : (bodyΘ.2.take 99).all (fun e => (PRE_first_tail_x8_r0_body.cws17 ++ PRE_first_tail_x8_r0_body.ws17).all fun w => e.noVar w) = true

theorem bodyStep17 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10281, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s172 PRE_first_tail_x8_r0_body.S172)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10291, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s174 PRE_first_tail_x8_r0_body.S174) (98 + 1) :=
  bodySite bodyFacts17.cfix bodyFacts17.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x8_r0_body.st17.S2.tab) (Es := bodyEs17) (qs := bodyQs17)
    (ok := PRE_first_tail_x8_r0_body.st17.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site17 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts17
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site17 r hr) hi (MapOk.sub hm (sub_of_all bodySub17)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk17 r hr) hi hm ho hq)
    bodyLq17 rfl bodyNrLo17 (postSub_sound bodyPost17)
    (Nat.le_of_ble_eq_true bodyDrop17) (by decide) (Nat.le_of_ble_eq_true bodyDropH17) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN17) (by decide)
    bodyDv17 bodyDe17 bodyDl17 bodyDold17 bodyDfree17 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site18 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site18 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site18) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st18.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site18
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st18.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st18.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s189 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s190 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S189 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws18 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st18.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st18.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso18
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_18
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st18.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot18
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup18
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound18
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace18
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged18
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws18.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st18.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S189.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_18]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen18.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh18
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl18 : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s189.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl18 (PRE_first_tail_x8_r0_body.cncl17 bodyNcl17)

theorem bodyClean18 : Conv.JClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s189 :=
  PRE_first_tail_x8_r0_body.gjcl18 (PRE_first_tail_x8_r0_body.cjcl17 bodyClean17)

kernel_rfl bodyJsLe18 : Nat.ble PRE_first_tail_x8_r0_body.s172.next PRE_first_tail_x8_r0_body.s189.next = true
kernel_rfl bodyJsList18 : (PRE_first_tail_x8_r0_body.gjh18 ++ PRE_first_tail_x8_r0_body.cl18).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s189.next) PRE_first_tail_x8_r0_body.s191) = true
theorem bodyJs18 : JsHeapAbove PRE_first_tail_x8_r0_body.s189.next PRE_first_tail_x8_r0_body.s191 :=
  JsHeapAbove.glueSite bodyJs17 (Nat.le_of_ble_eq_true bodyJsLe18) PRE_first_tail_x8_r0_body.gjk18 PRE_first_tail_x8_r0_body.gjbd18 PRE_first_tail_x8_r0_body.cheap18 PRE_first_tail_x8_r0_body.zclbd18 bodyJsList18

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO174 : PRE_first_tail_x8_r0_body.S174.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S174.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr174 : bridgeOf PRE_first_tail_x8_r0_body.s174.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc174 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s174 PRE_first_tail_x8_r0_body.S174) = fun _ _ => true
kernel_rfl bodyAcc176 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s176 PRE_first_tail_x8_r0_body.S176) = fun _ _ => true
kernel_rfl bodyBr177 : bridgeOf PRE_first_tail_x8_r0_body.s177.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt176 : isHalt PRE_first_tail_x8_r0_body.s176.ctl = false
kernel_rfl bodyTop177 : noRetBlock PRE_first_tail_x8_r0_body.s177 = true
kernel_rfl bodyCnt174 : countersOkB PRE_first_tail_x8_r0_body.s174 PRE_first_tail_x8_r0_body.s177 = true
kernel_rfl bodyO177 : PRE_first_tail_x8_r0_body.S177.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S177.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr178 : bridgeOf PRE_first_tail_x8_r0_body.s178.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt177 : countersOkB PRE_first_tail_x8_r0_body.s177 PRE_first_tail_x8_r0_body.s178 = true
kernel_rfl bodyO178 : PRE_first_tail_x8_r0_body.S178.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S178.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc178 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s178 PRE_first_tail_x8_r0_body.S178) = fun _ _ => true
kernel_rfl bodyAcc179 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s179 PRE_first_tail_x8_r0_body.S179) = fun _ _ => true
kernel_rfl bodyBr180 : bridgeOf PRE_first_tail_x8_r0_body.s180.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt179 : isHalt PRE_first_tail_x8_r0_body.s179.ctl = false
kernel_rfl bodyTop180 : noRetBlock PRE_first_tail_x8_r0_body.s180 = true
kernel_rfl bodyCnt178 : countersOkB PRE_first_tail_x8_r0_body.s178 PRE_first_tail_x8_r0_body.s180 = true
kernel_rfl bodyO180 : PRE_first_tail_x8_r0_body.S180.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S180.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr181 : bridgeOf PRE_first_tail_x8_r0_body.s181.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt180 : countersOkB PRE_first_tail_x8_r0_body.s180 PRE_first_tail_x8_r0_body.s181 = true
kernel_rfl bodyO181 : PRE_first_tail_x8_r0_body.S181.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S181.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc181 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s181 PRE_first_tail_x8_r0_body.S181) = fun _ _ => true
kernel_rfl bodyAcc182 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s182 PRE_first_tail_x8_r0_body.S182) = fun _ _ => true
kernel_rfl bodyBr183 : bridgeOf PRE_first_tail_x8_r0_body.s183.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt182 : isHalt PRE_first_tail_x8_r0_body.s182.ctl = false
kernel_rfl bodyTop183 : noRetBlock PRE_first_tail_x8_r0_body.s183 = true
kernel_rfl bodyCnt181 : countersOkB PRE_first_tail_x8_r0_body.s181 PRE_first_tail_x8_r0_body.s183 = true
kernel_rfl bodyO183 : PRE_first_tail_x8_r0_body.S183.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S183.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr184 : bridgeOf PRE_first_tail_x8_r0_body.s184.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt183 : countersOkB PRE_first_tail_x8_r0_body.s183 PRE_first_tail_x8_r0_body.s184 = true
kernel_rfl bodyO184 : PRE_first_tail_x8_r0_body.S184.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S184.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc184 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s184 PRE_first_tail_x8_r0_body.S184) = fun _ _ => true
kernel_rfl bodyAcc185 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s185 PRE_first_tail_x8_r0_body.S185) = fun _ _ => true
kernel_rfl bodyBr186 : bridgeOf PRE_first_tail_x8_r0_body.s186.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt185 : isHalt PRE_first_tail_x8_r0_body.s185.ctl = false
kernel_rfl bodyTop186 : noRetBlock PRE_first_tail_x8_r0_body.s186 = true
kernel_rfl bodyCnt184 : countersOkB PRE_first_tail_x8_r0_body.s184 PRE_first_tail_x8_r0_body.s186 = true
kernel_rfl bodyO186 : PRE_first_tail_x8_r0_body.S186.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S186.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr187 : bridgeOf PRE_first_tail_x8_r0_body.s187.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt186 : countersOkB PRE_first_tail_x8_r0_body.s186 PRE_first_tail_x8_r0_body.s187 = true
kernel_rfl bodyO187 : PRE_first_tail_x8_r0_body.S187.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S187.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc187 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s187 PRE_first_tail_x8_r0_body.S187) = fun _ _ => true
kernel_rfl bodyAcc188 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s188 PRE_first_tail_x8_r0_body.S188) = fun _ _ => true
kernel_rfl bodyBr189 : bridgeOf PRE_first_tail_x8_r0_body.s189.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt188 : isHalt PRE_first_tail_x8_r0_body.s188.ctl = false
kernel_rfl bodyTop189 : noRetBlock PRE_first_tail_x8_r0_body.s189 = true
kernel_rfl bodyCnt187 : countersOkB PRE_first_tail_x8_r0_body.s187 PRE_first_tail_x8_r0_body.s189 = true

theorem bodyGlue18 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10291, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s174 PRE_first_tail_x8_r0_body.S174)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10291, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s189 PRE_first_tail_x8_r0_body.S189) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) bodyAcc174 PRE_first_tail_x8_r0_body.bodyRunSeg47 bodyAcc176 bodyHalt176 PRE_first_tail_x8_r0_body.bodyStepA48 bodyTop177 (fun _ hm => bodyO174 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr174).trans bodyInactive0) (bodyBr177.trans bodyBr174.symm) bodyCnt174 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) PRE_first_tail_x8_r0_body.sizeA48 PRE_first_tail_x8_r0_body.sizeArgsA48 PRE_first_tail_x8_r0_body.sizeSymA48 PRE_first_tail_x8_r0_body.sizeMlxA48 PRE_first_tail_x8_r0_body.sizePayA48 PRE_first_tail_x8_r0_body.sizeTaA48 PRE_first_tail_x8_r0_body.sizeDecA48 PRE_first_tail_x8_r0_body.sizePreA48 PRE_first_tail_x8_r0_body.bodyPatchB48 (fun _ hm => bodyO177 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr177).trans bodyInactive0) (bodyBr178.trans bodyBr177.symm) bodyCnt177 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) bodyAcc178 PRE_first_tail_x8_r0_body.bodyRunSeg48 bodyAcc179 bodyHalt179 PRE_first_tail_x8_r0_body.bodyStepA49 bodyTop180 (fun _ hm => bodyO178 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr178).trans bodyInactive0) (bodyBr180.trans bodyBr178.symm) bodyCnt178 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) PRE_first_tail_x8_r0_body.sizeA49 PRE_first_tail_x8_r0_body.sizeArgsA49 PRE_first_tail_x8_r0_body.sizeSymA49 PRE_first_tail_x8_r0_body.sizeMlxA49 PRE_first_tail_x8_r0_body.sizePayA49 PRE_first_tail_x8_r0_body.sizeTaA49 PRE_first_tail_x8_r0_body.sizeDecA49 PRE_first_tail_x8_r0_body.sizePreA49 PRE_first_tail_x8_r0_body.bodyPatchB49 (fun _ hm => bodyO180 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr180).trans bodyInactive0) (bodyBr181.trans bodyBr180.symm) bodyCnt180 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) bodyAcc181 PRE_first_tail_x8_r0_body.bodyRunSeg49 bodyAcc182 bodyHalt182 PRE_first_tail_x8_r0_body.bodyStepA50 bodyTop183 (fun _ hm => bodyO181 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr181).trans bodyInactive0) (bodyBr183.trans bodyBr181.symm) bodyCnt181 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) PRE_first_tail_x8_r0_body.sizeA50 PRE_first_tail_x8_r0_body.sizeArgsA50 PRE_first_tail_x8_r0_body.sizeSymA50 PRE_first_tail_x8_r0_body.sizeMlxA50 PRE_first_tail_x8_r0_body.sizePayA50 PRE_first_tail_x8_r0_body.sizeTaA50 PRE_first_tail_x8_r0_body.sizeDecA50 PRE_first_tail_x8_r0_body.sizePreA50 PRE_first_tail_x8_r0_body.bodyPatchB50 (fun _ hm => bodyO183 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr183).trans bodyInactive0) (bodyBr184.trans bodyBr183.symm) bodyCnt183 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) bodyAcc184 PRE_first_tail_x8_r0_body.bodyRunSeg50 bodyAcc185 bodyHalt185 PRE_first_tail_x8_r0_body.bodyStepA51 bodyTop186 (fun _ hm => bodyO184 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr184).trans bodyInactive0) (bodyBr186.trans bodyBr184.symm) bodyCnt184 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) PRE_first_tail_x8_r0_body.sizeA51 PRE_first_tail_x8_r0_body.sizeArgsA51 PRE_first_tail_x8_r0_body.sizeSymA51 PRE_first_tail_x8_r0_body.sizeMlxA51 PRE_first_tail_x8_r0_body.sizePayA51 PRE_first_tail_x8_r0_body.sizeTaA51 PRE_first_tail_x8_r0_body.sizeDecA51 PRE_first_tail_x8_r0_body.sizePreA51 PRE_first_tail_x8_r0_body.bodyPatchB51 (fun _ hm => bodyO186 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr186).trans bodyInactive0) (bodyBr187.trans bodyBr186.symm) bodyCnt186 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10291, 148, 0, 99⟩) bodyAcc187 PRE_first_tail_x8_r0_body.bodyRunSeg51 bodyAcc188 bodyHalt188 PRE_first_tail_x8_r0_body.bodyStepA52 bodyTop189 (fun _ hm => bodyO187 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr187).trans bodyInactive0) (bodyBr189.trans bodyBr187.symm) bodyCnt187 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift18 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S189.tab.length PRE_first_tail_x8_r0_body.s189.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P18.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P18 872 PRE_first_tail_x8_r0_body.kappa18 PRE_first_tail_x8_r0_body.s191.ffi PRE_first_tail_x8_r0_body.s190.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_18
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_18
  have hcl : SSt (· < 872) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s191.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S189.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_18] <;> decide) PRE_first_tail_x8_r0_body.cnodesK18 PRE_first_tail_x8_r0_body.cobjsK18
      PRE_first_tail_x8_r0_body.citemsK18 PRE_first_tail_x8_r0_body.cbd18 PRE_first_tail_x8_r0_body.csst18
  exact PRE_first_tail_x8_r0_body.cshift18 bodyNcl18 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_18] at this; exact this)


kernel_rfl bodyFramesEmpty18 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s190 a).isEmpty) = true
kernel_rfl bodyJsRoots18 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s189.next) PRE_first_tail_x8_r0_body.s191.trace PRE_first_tail_x8_r0_body.s191 = true
kernel_rfl bodyJsNative18 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s191.ffi) = true
kernel_rfl bodyLow18 : (PRE_first_tail_x8_r0_body.cws18 ++ PRE_first_tail_x8_r0_body.ws18).all (Nat.ble 9) = true
kernel_rfl bodyCntM18 : countersOkB PRE_first_tail_x8_r0_body.s189 PRE_first_tail_x8_r0_body.s190 = true
kernel_rfl bodyHi18 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s191.ffi).next setupP.E = true
kernel_rfl bodyNhi18 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s191.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge18 : bridgeOf PRE_first_tail_x8_r0_body.s190.ffi = bridgeOf PRE_first_tail_x8_r0_body.s189.ffi
kernel_rfl bodyNN18 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s189.ffi).nnext PRE_first_tail_x8_r0_body.P18.NL = true
kernel_rfl bodyXn18 : Nat.ble (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s191.ffi).next = true
kernel_rfl bodyLo18 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s191.ffi).next = true
theorem bodyFacts18 : BodySiteFacts PRE_first_tail_x8_r0_body.s189 PRE_first_tail_x8_r0_body.s190 PRE_first_tail_x8_r0_body.s191 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S189 PRE_first_tail_x8_r0_body.S190 PRE_first_tail_x8_r0_body.S191
    PRE_first_tail_x8_r0_body.ws18 PRE_first_tail_x8_r0_body.cws18 PRE_first_tail_x8_r0_body.nr18 PRE_first_tail_x8_r0_body.pl18 PRE_first_tail_x8_r0_body.cl18 2690542 872 PRE_first_tail_x8_r0_body.kd18 PRE_first_tail_x8_r0_body.kappa18 PRE_first_tail_x8_r0_body.P18
    ⟨18566, 15641, 2689387, 854⟩ ⟨18569, 15668, 2689393, 872⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap18
  clean := bodyClean18
  cfix := PRE_first_tail_x8_r0_body.cfix18
  zpl := PRE_first_tail_x8_r0_body.zpl18
  zplnd := PRE_first_tail_x8_r0_body.zplnd18
  zn1 := PRE_first_tail_x8_r0_body.zn118
  zfirst := PRE_first_tail_x8_r0_body.zfirst18
  zscn := PRE_first_tail_x8_r0_body.zscn18
  zsmn := PRE_first_tail_x8_r0_body.zsmn18
  zgrow := PRE_first_tail_x8_r0_body.zgrow18
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab18
  zfresh := PRE_first_tail_x8_r0_body.zfresh18
  zcnd := PRE_first_tail_x8_r0_body.zcnd18
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi18
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt18
  zgP := PRE_first_tail_x8_r0_body.zg18_2665
  zkP := PRE_first_tail_x8_r0_body.zk18_2665
  zmP := PRE_first_tail_x8_r0_body.zm18_2665
  zgC := PRE_first_tail_x8_r0_body.zg18_2673467
  zkC := PRE_first_tail_x8_r0_body.zk18_2673467
  zmC := PRE_first_tail_x8_r0_body.zm18_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw18_2673472
  zwV := PRE_first_tail_x8_r0_body.zw18_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap18
  zclbd := PRE_first_tail_x8_r0_body.zclbd18
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap18 PRE_first_tail_x8_r0_body.stFoot18 PRE_first_tail_x8_r0_body.iso18 PRE_first_tail_x8_r0_body.zwr18
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP18
  csupp := PRE_first_tail_x8_r0_body.csupp18
  cbound := PRE_first_tail_x8_r0_body.cbound18
  zimg := PRE_first_tail_x8_r0_body.zimg18
  zctl := PRE_first_tail_x8_r0_body.zctl18
  zstack := PRE_first_tail_x8_r0_body.zstack18
  zjobs := PRE_first_tail_x8_r0_body.zjobs18
  zstores := PRE_first_tail_x8_r0_body.zstores18
  zroots := PRE_first_tail_x8_r0_body.zroots18
  znC := PRE_first_tail_x8_r0_body.znC18
  ctab := PRE_first_tail_x8_r0_body.ctab18
  zbin := PRE_first_tail_x8_r0_body.zbin18
  cbridge := PRE_first_tail_x8_r0_body.cbridge18
  sbridge := bodyBridge18
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj18
  cshiftR := fun h hNL => bodyCshift18 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN18
  raised := PRE_first_tail_x8_r0_body.raised18
  cbigs := PRE_first_tail_x8_r0_body.cbigs18
  cjcl := PRE_first_tail_x8_r0_body.cjcl18
  xnLe := Nat.le_of_ble_eq_true bodyXn18
  loLe := Nat.le_of_ble_eq_true bodyLo18
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB18
  cntM := bodyCntM18
  hiLe := Nat.le_of_ble_eq_true bodyHi18
  nhiLe := Nat.le_of_ble_eq_true bodyNhi18
  jsHeap := bodyJs18
  jsRoots := bodyJsRoots18
  jsNative := bodyJsNative18
  framesEmpty := bodyFramesEmpty18
  trailOld := by decide
  lowVars := bodyLow18

def bodyQs18 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs18 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr18.map fun r => nth? PRE_first_tail_x8_r0_body.st18.S5.tab r
kernel_rfl bodyResChk18 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs18 bodyQs18) = true
kernel_rfl bodyLq18 : bodyQs18.length = PRE_first_tail_x8_r0_body.cws18.length
kernel_rfl bodyNrLo18 : PRE_first_tail_x8_r0_body.nr18.all (Nat.ble PRE_first_tail_x8_r0_body.S189.tab.length) = true
kernel_rfl bodySub18 : (Oracles.PRE_first_tail_x8_r0_body.map_site18.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost18 : postSubB bodyM PRE_first_tail_x8_r0_body.ws18 PRE_first_tail_x8_r0_body.cws18 bodyQs18 = true
kernel_rfl bodyDrop18 : Nat.ble (10291 + (PRE_first_tail_x8_r0_body.s190.next - PRE_first_tail_x8_r0_body.s191.next)) 11440 = true
kernel_rfl bodyDropH18 : Nat.ble (148 + ((mlxOf PRE_first_tail_x8_r0_body.s190.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s191.ffi).next)) 173 = true
kernel_rfl bodyDropN18 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s190.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s191.ffi).nnext)) 0 = true
kernel_rfl bodyDv18 : bodyΘ.1.take 117 = bodyΘ.1.take 99 ++ PRE_first_tail_x8_r0_body.cws18
kernel_rfl bodyDe18 : bodyΘ.2.take 117 = bodyΘ.2.take 99 ++ PRE_first_tail_x8_r0_body.nr18.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st18.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 99) (bodyΘ.2.take 99)))
kernel_rfl bodyDl18 : (bodyΘ.1.take 99).length = (bodyΘ.2.take 99).length
kernel_rfl bodyDold18 : (bodyΘ.1.take 99).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws18).isNone && !PRE_first_tail_x8_r0_body.ws18.contains v) = true
kernel_rfl bodyDfree18 : (bodyΘ.2.take 117).all (fun e => (PRE_first_tail_x8_r0_body.cws18 ++ PRE_first_tail_x8_r0_body.ws18).all fun w => e.noVar w) = true

theorem bodyStep18 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10291, 148, 0, 99⟩ bodyM PRE_first_tail_x8_r0_body.s189 PRE_first_tail_x8_r0_body.S189)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11440, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s191 PRE_first_tail_x8_r0_body.S191) (11334 + 1) :=
  bodySite bodyFacts18.cfix bodyFacts18.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x8_r0_body.st18.S5.tab) (Es := bodyEs18) (qs := bodyQs18)
    (ok := PRE_first_tail_x8_r0_body.st18.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site18 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts18
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site18 r hr) hi (MapOk.sub hm (sub_of_all bodySub18)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk18 r hr) hi hm ho hq)
    bodyLq18 rfl bodyNrLo18 (postSub_sound bodyPost18)
    (Nat.le_of_ble_eq_true bodyDrop18) (by decide) (Nat.le_of_ble_eq_true bodyDropH18) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN18) (by decide)
    bodyDv18 bodyDe18 bodyDl18 bodyDold18 bodyDfree18 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site19 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site19 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site19) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st19.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site19
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st19.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st19.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s197 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s198 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S197 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws19 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st19.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st19.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso19
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_19
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st19.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot19
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup19
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound19
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace19
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged19
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws19.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st19.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S197.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_19]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen19.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh19
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl19 : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s197.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl19 (PRE_first_tail_x8_r0_body.cncl18 bodyNcl18)

theorem bodyClean19 : Conv.JClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s197 :=
  PRE_first_tail_x8_r0_body.gjcl19 (PRE_first_tail_x8_r0_body.cjcl18 bodyClean18)

kernel_rfl bodyJsLe19 : Nat.ble PRE_first_tail_x8_r0_body.s189.next PRE_first_tail_x8_r0_body.s197.next = true
kernel_rfl bodyJsList19 : (PRE_first_tail_x8_r0_body.gjh19 ++ PRE_first_tail_x8_r0_body.cl19).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s197.next) PRE_first_tail_x8_r0_body.s199) = true
theorem bodyJs19 : JsHeapAbove PRE_first_tail_x8_r0_body.s197.next PRE_first_tail_x8_r0_body.s199 :=
  JsHeapAbove.glueSite bodyJs18 (Nat.le_of_ble_eq_true bodyJsLe19) PRE_first_tail_x8_r0_body.gjk19 PRE_first_tail_x8_r0_body.gjbd19 PRE_first_tail_x8_r0_body.cheap19 PRE_first_tail_x8_r0_body.zclbd19 bodyJsList19

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO191 : PRE_first_tail_x8_r0_body.S191.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S191.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr191 : bridgeOf PRE_first_tail_x8_r0_body.s191.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc191 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s191 PRE_first_tail_x8_r0_body.S191) = fun _ _ => true
kernel_rfl bodyAcc192 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s192 PRE_first_tail_x8_r0_body.S192) = fun _ _ => true
kernel_rfl bodyBr193 : bridgeOf PRE_first_tail_x8_r0_body.s193.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt192 : isHalt PRE_first_tail_x8_r0_body.s192.ctl = false
kernel_rfl bodyTop193 : noRetBlock PRE_first_tail_x8_r0_body.s193 = true
kernel_rfl bodyCnt191 : countersOkB PRE_first_tail_x8_r0_body.s191 PRE_first_tail_x8_r0_body.s193 = true
kernel_rfl bodyO193 : PRE_first_tail_x8_r0_body.S193.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S193.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr194 : bridgeOf PRE_first_tail_x8_r0_body.s194.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt193 : countersOkB PRE_first_tail_x8_r0_body.s193 PRE_first_tail_x8_r0_body.s194 = true
kernel_rfl bodyO194 : PRE_first_tail_x8_r0_body.S194.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S194.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc194 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s194 PRE_first_tail_x8_r0_body.S194) = fun _ _ => true
kernel_rfl bodyAcc196 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s196 PRE_first_tail_x8_r0_body.S196) = fun _ _ => true
kernel_rfl bodyBr197 : bridgeOf PRE_first_tail_x8_r0_body.s197.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt196 : isHalt PRE_first_tail_x8_r0_body.s196.ctl = false
kernel_rfl bodyTop197 : noRetBlock PRE_first_tail_x8_r0_body.s197 = true
kernel_rfl bodyCnt194 : countersOkB PRE_first_tail_x8_r0_body.s194 PRE_first_tail_x8_r0_body.s197 = true

theorem bodyGlue19 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11440, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s191 PRE_first_tail_x8_r0_body.S191)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11440, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s197 PRE_first_tail_x8_r0_body.S197) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11440, 173, 0, 117⟩) bodyAcc191 PRE_first_tail_x8_r0_body.bodyRunSeg52 bodyAcc192 bodyHalt192 PRE_first_tail_x8_r0_body.bodyStepA53 bodyTop193 (fun _ hm => bodyO191 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr191).trans bodyInactive0) (bodyBr193.trans bodyBr191.symm) bodyCnt191 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11440, 173, 0, 117⟩) PRE_first_tail_x8_r0_body.sizeA53 PRE_first_tail_x8_r0_body.sizeArgsA53 PRE_first_tail_x8_r0_body.sizeSymA53 PRE_first_tail_x8_r0_body.sizeMlxA53 PRE_first_tail_x8_r0_body.sizePayA53 PRE_first_tail_x8_r0_body.sizeTaA53 PRE_first_tail_x8_r0_body.sizeDecA53 PRE_first_tail_x8_r0_body.sizePreA53 PRE_first_tail_x8_r0_body.bodyPatchB53 (fun _ hm => bodyO193 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr193).trans bodyInactive0) (bodyBr194.trans bodyBr193.symm) bodyCnt193 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11440, 173, 0, 117⟩) bodyAcc194 PRE_first_tail_x8_r0_body.bodyRunSeg53 bodyAcc196 bodyHalt196 PRE_first_tail_x8_r0_body.bodyStepA54 bodyTop197 (fun _ hm => bodyO194 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr194).trans bodyInactive0) (bodyBr197.trans bodyBr194.symm) bodyCnt194 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift19 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S197.tab.length PRE_first_tail_x8_r0_body.s197.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P19.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P19 893 PRE_first_tail_x8_r0_body.kappa19 PRE_first_tail_x8_r0_body.s199.ffi PRE_first_tail_x8_r0_body.s198.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_19
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_19
  have hcl : SSt (· < 893) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s199.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S197.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_19] <;> decide) PRE_first_tail_x8_r0_body.cnodesK19 PRE_first_tail_x8_r0_body.cobjsK19
      PRE_first_tail_x8_r0_body.citemsK19 PRE_first_tail_x8_r0_body.cbd19 PRE_first_tail_x8_r0_body.csst19
  exact PRE_first_tail_x8_r0_body.cshift19 bodyNcl19 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_19] at this; exact this)


kernel_rfl bodyFramesEmpty19 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s198 a).isEmpty) = true
kernel_rfl bodyJsRoots19 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s197.next) PRE_first_tail_x8_r0_body.s199.trace PRE_first_tail_x8_r0_body.s199 = true
kernel_rfl bodyJsNative19 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s199.ffi) = true
kernel_rfl bodyLow19 : (PRE_first_tail_x8_r0_body.cws19 ++ PRE_first_tail_x8_r0_body.ws19).all (Nat.ble 9) = true
kernel_rfl bodyCntM19 : countersOkB PRE_first_tail_x8_r0_body.s197 PRE_first_tail_x8_r0_body.s198 = true
kernel_rfl bodyHi19 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s199.ffi).next setupP.E = true
kernel_rfl bodyNhi19 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s199.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge19 : bridgeOf PRE_first_tail_x8_r0_body.s198.ffi = bridgeOf PRE_first_tail_x8_r0_body.s197.ffi
kernel_rfl bodyNN19 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s197.ffi).nnext PRE_first_tail_x8_r0_body.P19.NL = true
kernel_rfl bodyXn19 : Nat.ble (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s199.ffi).next = true
kernel_rfl bodyLo19 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s199.ffi).next = true
theorem bodyFacts19 : BodySiteFacts PRE_first_tail_x8_r0_body.s197 PRE_first_tail_x8_r0_body.s198 PRE_first_tail_x8_r0_body.s199 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S197 PRE_first_tail_x8_r0_body.S198 PRE_first_tail_x8_r0_body.S199
    PRE_first_tail_x8_r0_body.ws19 PRE_first_tail_x8_r0_body.cws19 PRE_first_tail_x8_r0_body.nr19 PRE_first_tail_x8_r0_body.pl19 PRE_first_tail_x8_r0_body.cl19 2689885 893 PRE_first_tail_x8_r0_body.kd19 PRE_first_tail_x8_r0_body.kappa19 PRE_first_tail_x8_r0_body.P19
    ⟨18582, 15681, 2689883, 893⟩ ⟨18582, 15681, 2689883, 893⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap19
  clean := bodyClean19
  cfix := PRE_first_tail_x8_r0_body.cfix19
  zpl := PRE_first_tail_x8_r0_body.zpl19
  zplnd := PRE_first_tail_x8_r0_body.zplnd19
  zn1 := PRE_first_tail_x8_r0_body.zn119
  zfirst := PRE_first_tail_x8_r0_body.zfirst19
  zscn := PRE_first_tail_x8_r0_body.zscn19
  zsmn := PRE_first_tail_x8_r0_body.zsmn19
  zgrow := PRE_first_tail_x8_r0_body.zgrow19
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab19
  zfresh := PRE_first_tail_x8_r0_body.zfresh19
  zcnd := PRE_first_tail_x8_r0_body.zcnd19
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi19
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt19
  zgP := PRE_first_tail_x8_r0_body.zg19_2665
  zkP := PRE_first_tail_x8_r0_body.zk19_2665
  zmP := PRE_first_tail_x8_r0_body.zm19_2665
  zgC := PRE_first_tail_x8_r0_body.zg19_2673467
  zkC := PRE_first_tail_x8_r0_body.zk19_2673467
  zmC := PRE_first_tail_x8_r0_body.zm19_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw19_2673472
  zwV := PRE_first_tail_x8_r0_body.zw19_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap19
  zclbd := PRE_first_tail_x8_r0_body.zclbd19
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap19 PRE_first_tail_x8_r0_body.stFoot19 PRE_first_tail_x8_r0_body.iso19 PRE_first_tail_x8_r0_body.zwr19
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP19
  csupp := PRE_first_tail_x8_r0_body.csupp19
  cbound := PRE_first_tail_x8_r0_body.cbound19
  zimg := PRE_first_tail_x8_r0_body.zimg19
  zctl := PRE_first_tail_x8_r0_body.zctl19
  zstack := PRE_first_tail_x8_r0_body.zstack19
  zjobs := PRE_first_tail_x8_r0_body.zjobs19
  zstores := PRE_first_tail_x8_r0_body.zstores19
  zroots := PRE_first_tail_x8_r0_body.zroots19
  znC := PRE_first_tail_x8_r0_body.znC19
  ctab := PRE_first_tail_x8_r0_body.ctab19
  zbin := PRE_first_tail_x8_r0_body.zbin19
  cbridge := PRE_first_tail_x8_r0_body.cbridge19
  sbridge := bodyBridge19
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj19
  cshiftR := fun h hNL => bodyCshift19 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN19
  raised := PRE_first_tail_x8_r0_body.raised19
  cbigs := PRE_first_tail_x8_r0_body.cbigs19
  cjcl := PRE_first_tail_x8_r0_body.cjcl19
  xnLe := Nat.le_of_ble_eq_true bodyXn19
  loLe := Nat.le_of_ble_eq_true bodyLo19
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB19
  cntM := bodyCntM19
  hiLe := Nat.le_of_ble_eq_true bodyHi19
  nhiLe := Nat.le_of_ble_eq_true bodyNhi19
  jsHeap := bodyJs19
  jsRoots := bodyJsRoots19
  jsNative := bodyJsNative19
  framesEmpty := bodyFramesEmpty19
  trailOld := by decide
  lowVars := bodyLow19

def bodyQs19 : List (Option Q) := []
noncomputable def bodyEs19 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr19.map fun r => nth? PRE_first_tail_x8_r0_body.st19.S2.tab r
kernel_rfl bodyResChk19 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs19 bodyQs19) = true
kernel_rfl bodyLq19 : bodyQs19.length = PRE_first_tail_x8_r0_body.cws19.length
kernel_rfl bodyNrLo19 : PRE_first_tail_x8_r0_body.nr19.all (Nat.ble PRE_first_tail_x8_r0_body.S197.tab.length) = true
kernel_rfl bodySub19 : (Oracles.PRE_first_tail_x8_r0_body.map_site19.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost19 : postSubB bodyM PRE_first_tail_x8_r0_body.ws19 PRE_first_tail_x8_r0_body.cws19 bodyQs19 = true
kernel_rfl bodyDrop19 : Nat.ble (11440 + (PRE_first_tail_x8_r0_body.s198.next - PRE_first_tail_x8_r0_body.s199.next)) 11442 = true
kernel_rfl bodyDropH19 : Nat.ble (173 + ((mlxOf PRE_first_tail_x8_r0_body.s198.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s199.ffi).next)) 173 = true
kernel_rfl bodyDropN19 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s198.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s199.ffi).nnext)) 0 = true
kernel_rfl bodyDv19 : bodyΘ.1.take 117 = bodyΘ.1.take 117 ++ PRE_first_tail_x8_r0_body.cws19
kernel_rfl bodyDe19 : bodyΘ.2.take 117 = bodyΘ.2.take 117 ++ PRE_first_tail_x8_r0_body.nr19.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st19.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 117) (bodyΘ.2.take 117)))
kernel_rfl bodyDl19 : (bodyΘ.1.take 117).length = (bodyΘ.2.take 117).length
kernel_rfl bodyDold19 : (bodyΘ.1.take 117).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws19).isNone && !PRE_first_tail_x8_r0_body.ws19.contains v) = true
kernel_rfl bodyDfree19 : (bodyΘ.2.take 117).all (fun e => (PRE_first_tail_x8_r0_body.cws19 ++ PRE_first_tail_x8_r0_body.ws19).all fun w => e.noVar w) = true

theorem bodyStep19 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11440, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s197 PRE_first_tail_x8_r0_body.S197)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11442, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s199 PRE_first_tail_x8_r0_body.S199) (27 + 1) :=
  bodySite bodyFacts19.cfix bodyFacts19.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x8_r0_body.st19.S2.tab) (Es := bodyEs19) (qs := bodyQs19)
    (ok := PRE_first_tail_x8_r0_body.st19.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site19 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts19
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site19 r hr) hi (MapOk.sub hm (sub_of_all bodySub19)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk19 r hr) hi hm ho hq)
    bodyLq19 rfl bodyNrLo19 (postSub_sound bodyPost19)
    (Nat.le_of_ble_eq_true bodyDrop19) (by decide) (Nat.le_of_ble_eq_true bodyDropH19) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN19) (by decide)
    bodyDv19 bodyDe19 bodyDl19 bodyDold19 bodyDfree19 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyOracles_5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_g20 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g20 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g20) (List.take 3 (List.drop 191 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site20 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site20 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site20) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g21 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g21 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g21) (List.take 28 (List.drop 194 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site21 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site21 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site21) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st21.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g22 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g22 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g22) (List.take 9 (List.drop 222 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site22 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site22 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site22) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st22.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g23 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g23 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g23) (List.take 3 (List.drop 231 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site23 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site23 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site23) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site20 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site20 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site20) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site20
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s201 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s202 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S201 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws20 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso20
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_20
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot20
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup20
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound20
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace20
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged20
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws20.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st20.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S201.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_20]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen20.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh20
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl20 : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s201.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl20 (PRE_first_tail_x8_r0_body.cncl19 bodyNcl19)

theorem bodyClean20 : Conv.JClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s201 :=
  PRE_first_tail_x8_r0_body.gjcl20 (PRE_first_tail_x8_r0_body.cjcl19 bodyClean19)

kernel_rfl bodyJsLe20 : Nat.ble PRE_first_tail_x8_r0_body.s197.next PRE_first_tail_x8_r0_body.s201.next = true
kernel_rfl bodyJsList20 : (PRE_first_tail_x8_r0_body.gjh20 ++ PRE_first_tail_x8_r0_body.cl20).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s201.next) PRE_first_tail_x8_r0_body.s203) = true
theorem bodyJs20 : JsHeapAbove PRE_first_tail_x8_r0_body.s201.next PRE_first_tail_x8_r0_body.s203 :=
  JsHeapAbove.glueSite bodyJs19 (Nat.le_of_ble_eq_true bodyJsLe20) PRE_first_tail_x8_r0_body.gjk20 PRE_first_tail_x8_r0_body.gjbd20 PRE_first_tail_x8_r0_body.cheap20 PRE_first_tail_x8_r0_body.zclbd20 bodyJsList20

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO199 : PRE_first_tail_x8_r0_body.S199.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S199.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr199 : bridgeOf PRE_first_tail_x8_r0_body.s199.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc199 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s199 PRE_first_tail_x8_r0_body.S199) = fun _ _ => true
kernel_rfl bodyAcc200 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s200 PRE_first_tail_x8_r0_body.S200) = fun _ _ => true
kernel_rfl bodyBr201 : bridgeOf PRE_first_tail_x8_r0_body.s201.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt200 : isHalt PRE_first_tail_x8_r0_body.s200.ctl = false
kernel_rfl bodyTop201 : noRetBlock PRE_first_tail_x8_r0_body.s201 = true
kernel_rfl bodyCnt199 : countersOkB PRE_first_tail_x8_r0_body.s199 PRE_first_tail_x8_r0_body.s201 = true

theorem bodyGlue20 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11442, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s199 PRE_first_tail_x8_r0_body.S199)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11442, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s201 PRE_first_tail_x8_r0_body.S201) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11442, 173, 0, 117⟩) bodyAcc199 PRE_first_tail_x8_r0_body.bodyRunSeg54 bodyAcc200 bodyHalt200 PRE_first_tail_x8_r0_body.bodyStepA55 bodyTop201 (fun _ hm => bodyO199 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr199).trans bodyInactive0) (bodyBr201.trans bodyBr199.symm) bodyCnt199 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift20 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S201.tab.length PRE_first_tail_x8_r0_body.s201.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P20.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P20 910 PRE_first_tail_x8_r0_body.kappa20 PRE_first_tail_x8_r0_body.s203.ffi PRE_first_tail_x8_r0_body.s202.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_20
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_20
  have hcl : SSt (· < 910) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s203.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S201.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_20] <;> decide) PRE_first_tail_x8_r0_body.cnodesK20 PRE_first_tail_x8_r0_body.cobjsK20
      PRE_first_tail_x8_r0_body.citemsK20 PRE_first_tail_x8_r0_body.cbd20 PRE_first_tail_x8_r0_body.csst20
  exact PRE_first_tail_x8_r0_body.cshift20 bodyNcl20 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_20] at this; exact this)


kernel_rfl bodyFramesEmpty20 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s202 a).isEmpty) = true
kernel_rfl bodyJsRoots20 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s201.next) PRE_first_tail_x8_r0_body.s203.trace PRE_first_tail_x8_r0_body.s203 = true
kernel_rfl bodyJsNative20 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s203.ffi) = true
kernel_rfl bodyLow20 : (PRE_first_tail_x8_r0_body.cws20 ++ PRE_first_tail_x8_r0_body.ws20).all (Nat.ble 9) = true
kernel_rfl bodyCntM20 : countersOkB PRE_first_tail_x8_r0_body.s201 PRE_first_tail_x8_r0_body.s202 = true
kernel_rfl bodyHi20 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s203.ffi).next setupP.E = true
kernel_rfl bodyNhi20 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s203.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge20 : bridgeOf PRE_first_tail_x8_r0_body.s202.ffi = bridgeOf PRE_first_tail_x8_r0_body.s201.ffi
kernel_rfl bodyNN20 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s201.ffi).nnext PRE_first_tail_x8_r0_body.P20.NL = true
kernel_rfl bodyXn20 : Nat.ble (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s203.ffi).next = true
kernel_rfl bodyLo20 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s203.ffi).next = true
theorem bodyFacts20 : BodySiteFacts PRE_first_tail_x8_r0_body.s201 PRE_first_tail_x8_r0_body.s202 PRE_first_tail_x8_r0_body.s203 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S201 PRE_first_tail_x8_r0_body.S202 PRE_first_tail_x8_r0_body.S203
    PRE_first_tail_x8_r0_body.ws20 PRE_first_tail_x8_r0_body.cws20 PRE_first_tail_x8_r0_body.nr20 PRE_first_tail_x8_r0_body.pl20 PRE_first_tail_x8_r0_body.cl20 2690182 910 PRE_first_tail_x8_r0_body.kd20 PRE_first_tail_x8_r0_body.kappa20 PRE_first_tail_x8_r0_body.P20
    ⟨18589, 15685, 2690171, 910⟩ ⟨18589, 15685, 2690172, 910⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap20
  clean := bodyClean20
  cfix := PRE_first_tail_x8_r0_body.cfix20
  zpl := PRE_first_tail_x8_r0_body.zpl20
  zplnd := PRE_first_tail_x8_r0_body.zplnd20
  zn1 := PRE_first_tail_x8_r0_body.zn120
  zfirst := PRE_first_tail_x8_r0_body.zfirst20
  zscn := PRE_first_tail_x8_r0_body.zscn20
  zsmn := PRE_first_tail_x8_r0_body.zsmn20
  zgrow := PRE_first_tail_x8_r0_body.zgrow20
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab20
  zfresh := PRE_first_tail_x8_r0_body.zfresh20
  zcnd := PRE_first_tail_x8_r0_body.zcnd20
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi20
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt20
  zgP := PRE_first_tail_x8_r0_body.zg20_2665
  zkP := PRE_first_tail_x8_r0_body.zk20_2665
  zmP := PRE_first_tail_x8_r0_body.zm20_2665
  zgC := PRE_first_tail_x8_r0_body.zg20_2673467
  zkC := PRE_first_tail_x8_r0_body.zk20_2673467
  zmC := PRE_first_tail_x8_r0_body.zm20_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw20_2673472
  zwV := PRE_first_tail_x8_r0_body.zw20_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap20
  zclbd := PRE_first_tail_x8_r0_body.zclbd20
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap20 PRE_first_tail_x8_r0_body.stFoot20 PRE_first_tail_x8_r0_body.iso20 PRE_first_tail_x8_r0_body.zwr20
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP20
  csupp := PRE_first_tail_x8_r0_body.csupp20
  cbound := PRE_first_tail_x8_r0_body.cbound20
  zimg := PRE_first_tail_x8_r0_body.zimg20
  zctl := PRE_first_tail_x8_r0_body.zctl20
  zstack := PRE_first_tail_x8_r0_body.zstack20
  zjobs := PRE_first_tail_x8_r0_body.zjobs20
  zstores := PRE_first_tail_x8_r0_body.zstores20
  zroots := PRE_first_tail_x8_r0_body.zroots20
  znC := PRE_first_tail_x8_r0_body.znC20
  ctab := PRE_first_tail_x8_r0_body.ctab20
  zbin := PRE_first_tail_x8_r0_body.zbin20
  cbridge := PRE_first_tail_x8_r0_body.cbridge20
  sbridge := bodyBridge20
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj20
  cshiftR := fun h hNL => bodyCshift20 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN20
  raised := PRE_first_tail_x8_r0_body.raised20
  cbigs := PRE_first_tail_x8_r0_body.cbigs20
  cjcl := PRE_first_tail_x8_r0_body.cjcl20
  xnLe := Nat.le_of_ble_eq_true bodyXn20
  loLe := Nat.le_of_ble_eq_true bodyLo20
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB20
  cntM := bodyCntM20
  hiLe := Nat.le_of_ble_eq_true bodyHi20
  nhiLe := Nat.le_of_ble_eq_true bodyNhi20
  jsHeap := bodyJs20
  jsRoots := bodyJsRoots20
  jsNative := bodyJsNative20
  framesEmpty := bodyFramesEmpty20
  trailOld := by decide
  lowVars := bodyLow20

def bodyQs20 : List (Option Q) := []
noncomputable def bodyEs20 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr20.map fun r => nth? PRE_first_tail_x8_r0_body.st20.S2.tab r
kernel_rfl bodyResChk20 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs20 bodyQs20) = true
kernel_rfl bodyLq20 : bodyQs20.length = PRE_first_tail_x8_r0_body.cws20.length
kernel_rfl bodyNrLo20 : PRE_first_tail_x8_r0_body.nr20.all (Nat.ble PRE_first_tail_x8_r0_body.S201.tab.length) = true
kernel_rfl bodySub20 : (Oracles.PRE_first_tail_x8_r0_body.map_site20.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost20 : postSubB bodyM PRE_first_tail_x8_r0_body.ws20 PRE_first_tail_x8_r0_body.cws20 bodyQs20 = true
kernel_rfl bodyDrop20 : Nat.ble (11442 + (PRE_first_tail_x8_r0_body.s202.next - PRE_first_tail_x8_r0_body.s203.next)) 11452 = true
kernel_rfl bodyDropH20 : Nat.ble (173 + ((mlxOf PRE_first_tail_x8_r0_body.s202.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s203.ffi).next)) 173 = true
kernel_rfl bodyDropN20 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s202.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s203.ffi).nnext)) 0 = true
kernel_rfl bodyDv20 : bodyΘ.1.take 117 = bodyΘ.1.take 117 ++ PRE_first_tail_x8_r0_body.cws20
kernel_rfl bodyDe20 : bodyΘ.2.take 117 = bodyΘ.2.take 117 ++ PRE_first_tail_x8_r0_body.nr20.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st20.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 117) (bodyΘ.2.take 117)))
kernel_rfl bodyDl20 : (bodyΘ.1.take 117).length = (bodyΘ.2.take 117).length
kernel_rfl bodyDold20 : (bodyΘ.1.take 117).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws20).isNone && !PRE_first_tail_x8_r0_body.ws20.contains v) = true
kernel_rfl bodyDfree20 : (bodyΘ.2.take 117).all (fun e => (PRE_first_tail_x8_r0_body.cws20 ++ PRE_first_tail_x8_r0_body.ws20).all fun w => e.noVar w) = true

theorem bodyStep20 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11442, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s201 PRE_first_tail_x8_r0_body.S201)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11452, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s203 PRE_first_tail_x8_r0_body.S203) (98 + 1) :=
  bodySite bodyFacts20.cfix bodyFacts20.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x8_r0_body.st20.S2.tab) (Es := bodyEs20) (qs := bodyQs20)
    (ok := PRE_first_tail_x8_r0_body.st20.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site20 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts20
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site20 r hr) hi (MapOk.sub hm (sub_of_all bodySub20)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk20 r hr) hi hm ho hq)
    bodyLq20 rfl bodyNrLo20 (postSub_sound bodyPost20)
    (Nat.le_of_ble_eq_true bodyDrop20) (by decide) (Nat.le_of_ble_eq_true bodyDropH20) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN20) (by decide)
    bodyDv20 bodyDe20 bodyDl20 bodyDold20 bodyDfree20 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site21 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site21 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site21) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st21.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site21
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st21.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st21.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s217 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s218 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S217 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws21 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st21.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st21.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso21
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_21
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st21.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot21
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup21
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound21
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace21
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged21
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws21.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st21.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S217.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_21]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen21.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh21
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl21 : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s217.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl21 (PRE_first_tail_x8_r0_body.cncl20 bodyNcl20)

theorem bodyClean21 : Conv.JClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s217 :=
  PRE_first_tail_x8_r0_body.gjcl21 (PRE_first_tail_x8_r0_body.cjcl20 bodyClean20)

kernel_rfl bodyJsLe21 : Nat.ble PRE_first_tail_x8_r0_body.s201.next PRE_first_tail_x8_r0_body.s217.next = true
kernel_rfl bodyJsList21 : (PRE_first_tail_x8_r0_body.gjh21 ++ PRE_first_tail_x8_r0_body.cl21).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s217.next) PRE_first_tail_x8_r0_body.s219) = true
theorem bodyJs21 : JsHeapAbove PRE_first_tail_x8_r0_body.s217.next PRE_first_tail_x8_r0_body.s219 :=
  JsHeapAbove.glueSite bodyJs20 (Nat.le_of_ble_eq_true bodyJsLe21) PRE_first_tail_x8_r0_body.gjk21 PRE_first_tail_x8_r0_body.gjbd21 PRE_first_tail_x8_r0_body.cheap21 PRE_first_tail_x8_r0_body.zclbd21 bodyJsList21

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO203 : PRE_first_tail_x8_r0_body.S203.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S203.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr203 : bridgeOf PRE_first_tail_x8_r0_body.s203.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc203 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s203 PRE_first_tail_x8_r0_body.S203) = fun _ _ => true
kernel_rfl bodyAcc205 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s205 PRE_first_tail_x8_r0_body.S205) = fun _ _ => true
kernel_rfl bodyBr206 : bridgeOf PRE_first_tail_x8_r0_body.s206.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt205 : isHalt PRE_first_tail_x8_r0_body.s205.ctl = false
kernel_rfl bodyTop206 : noRetBlock PRE_first_tail_x8_r0_body.s206 = true
kernel_rfl bodyCnt203 : countersOkB PRE_first_tail_x8_r0_body.s203 PRE_first_tail_x8_r0_body.s206 = true
kernel_rfl bodyO206 : PRE_first_tail_x8_r0_body.S206.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S206.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr207 : bridgeOf PRE_first_tail_x8_r0_body.s207.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt206 : countersOkB PRE_first_tail_x8_r0_body.s206 PRE_first_tail_x8_r0_body.s207 = true
kernel_rfl bodyO207 : PRE_first_tail_x8_r0_body.S207.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S207.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc207 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s207 PRE_first_tail_x8_r0_body.S207) = fun _ _ => true
kernel_rfl bodyAcc209 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s209 PRE_first_tail_x8_r0_body.S209) = fun _ _ => true
kernel_rfl bodyBr210 : bridgeOf PRE_first_tail_x8_r0_body.s210.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt209 : isHalt PRE_first_tail_x8_r0_body.s209.ctl = false
kernel_rfl bodyTop210 : noRetBlock PRE_first_tail_x8_r0_body.s210 = true
kernel_rfl bodyCnt207 : countersOkB PRE_first_tail_x8_r0_body.s207 PRE_first_tail_x8_r0_body.s210 = true
kernel_rfl bodyO210 : PRE_first_tail_x8_r0_body.S210.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S210.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr211 : bridgeOf PRE_first_tail_x8_r0_body.s211.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt210 : countersOkB PRE_first_tail_x8_r0_body.s210 PRE_first_tail_x8_r0_body.s211 = true
kernel_rfl bodyO211 : PRE_first_tail_x8_r0_body.S211.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S211.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc211 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s211 PRE_first_tail_x8_r0_body.S211) = fun _ _ => true
kernel_rfl bodyAcc212 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s212 PRE_first_tail_x8_r0_body.S212) = fun _ _ => true
kernel_rfl bodyBr213 : bridgeOf PRE_first_tail_x8_r0_body.s213.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt212 : isHalt PRE_first_tail_x8_r0_body.s212.ctl = false
kernel_rfl bodyTop213 : noRetBlock PRE_first_tail_x8_r0_body.s213 = true
kernel_rfl bodyCnt211 : countersOkB PRE_first_tail_x8_r0_body.s211 PRE_first_tail_x8_r0_body.s213 = true
kernel_rfl bodyO213 : PRE_first_tail_x8_r0_body.S213.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S213.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr214 : bridgeOf PRE_first_tail_x8_r0_body.s214.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt213 : countersOkB PRE_first_tail_x8_r0_body.s213 PRE_first_tail_x8_r0_body.s214 = true
kernel_rfl bodyO214 : PRE_first_tail_x8_r0_body.S214.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S214.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc214 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s214 PRE_first_tail_x8_r0_body.S214) = fun _ _ => true
kernel_rfl bodyAcc216 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s216 PRE_first_tail_x8_r0_body.S216) = fun _ _ => true
kernel_rfl bodyBr217 : bridgeOf PRE_first_tail_x8_r0_body.s217.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt216 : isHalt PRE_first_tail_x8_r0_body.s216.ctl = false
kernel_rfl bodyTop217 : noRetBlock PRE_first_tail_x8_r0_body.s217 = true
kernel_rfl bodyCnt214 : countersOkB PRE_first_tail_x8_r0_body.s214 PRE_first_tail_x8_r0_body.s217 = true

theorem bodyGlue21 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11452, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s203 PRE_first_tail_x8_r0_body.S203)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11452, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s217 PRE_first_tail_x8_r0_body.S217) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11452, 173, 0, 117⟩) bodyAcc203 PRE_first_tail_x8_r0_body.bodyRunSeg55 bodyAcc205 bodyHalt205 PRE_first_tail_x8_r0_body.bodyStepA56 bodyTop206 (fun _ hm => bodyO203 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr203).trans bodyInactive0) (bodyBr206.trans bodyBr203.symm) bodyCnt203 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11452, 173, 0, 117⟩) PRE_first_tail_x8_r0_body.sizeA56 PRE_first_tail_x8_r0_body.sizeArgsA56 PRE_first_tail_x8_r0_body.sizeSymA56 PRE_first_tail_x8_r0_body.sizeMlxA56 PRE_first_tail_x8_r0_body.sizePayA56 PRE_first_tail_x8_r0_body.sizeTaA56 PRE_first_tail_x8_r0_body.sizeDecA56 PRE_first_tail_x8_r0_body.sizePreA56 PRE_first_tail_x8_r0_body.bodyPatchB56 (fun _ hm => bodyO206 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr206).trans bodyInactive0) (bodyBr207.trans bodyBr206.symm) bodyCnt206 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11452, 173, 0, 117⟩) bodyAcc207 PRE_first_tail_x8_r0_body.bodyRunSeg56 bodyAcc209 bodyHalt209 PRE_first_tail_x8_r0_body.bodyStepA57 bodyTop210 (fun _ hm => bodyO207 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr207).trans bodyInactive0) (bodyBr210.trans bodyBr207.symm) bodyCnt207 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11452, 173, 0, 117⟩) PRE_first_tail_x8_r0_body.sizeA57 PRE_first_tail_x8_r0_body.sizeArgsA57 PRE_first_tail_x8_r0_body.sizeSymA57 PRE_first_tail_x8_r0_body.sizeMlxA57 PRE_first_tail_x8_r0_body.sizePayA57 PRE_first_tail_x8_r0_body.sizeTaA57 PRE_first_tail_x8_r0_body.sizeDecA57 PRE_first_tail_x8_r0_body.sizePreA57 PRE_first_tail_x8_r0_body.bodyPatchB57 (fun _ hm => bodyO210 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr210).trans bodyInactive0) (bodyBr211.trans bodyBr210.symm) bodyCnt210 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11452, 173, 0, 117⟩) bodyAcc211 PRE_first_tail_x8_r0_body.bodyRunSeg57 bodyAcc212 bodyHalt212 PRE_first_tail_x8_r0_body.bodyStepA58 bodyTop213 (fun _ hm => bodyO211 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr211).trans bodyInactive0) (bodyBr213.trans bodyBr211.symm) bodyCnt211 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11452, 173, 0, 117⟩) PRE_first_tail_x8_r0_body.sizeA58 PRE_first_tail_x8_r0_body.sizeArgsA58 PRE_first_tail_x8_r0_body.sizeSymA58 PRE_first_tail_x8_r0_body.sizeMlxA58 PRE_first_tail_x8_r0_body.sizePayA58 PRE_first_tail_x8_r0_body.sizeTaA58 PRE_first_tail_x8_r0_body.sizeDecA58 PRE_first_tail_x8_r0_body.sizePreA58 PRE_first_tail_x8_r0_body.bodyPatchB58 (fun _ hm => bodyO213 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr213).trans bodyInactive0) (bodyBr214.trans bodyBr213.symm) bodyCnt213 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11452, 173, 0, 117⟩) bodyAcc214 PRE_first_tail_x8_r0_body.bodyRunSeg58 bodyAcc216 bodyHalt216 PRE_first_tail_x8_r0_body.bodyStepA59 bodyTop217 (fun _ hm => bodyO214 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr214).trans bodyInactive0) (bodyBr217.trans bodyBr214.symm) bodyCnt214 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift21 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S217.tab.length PRE_first_tail_x8_r0_body.s217.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P21.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P21 996 PRE_first_tail_x8_r0_body.kappa21 PRE_first_tail_x8_r0_body.s219.ffi PRE_first_tail_x8_r0_body.s218.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_21
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_21
  have hcl : SSt (· < 996) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s219.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S217.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_21] <;> decide) PRE_first_tail_x8_r0_body.cnodesK21 PRE_first_tail_x8_r0_body.cobjsK21
      PRE_first_tail_x8_r0_body.citemsK21 PRE_first_tail_x8_r0_body.cbd21 PRE_first_tail_x8_r0_body.csst21
  exact PRE_first_tail_x8_r0_body.cshift21 bodyNcl21 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_21] at this; exact this)


kernel_rfl bodyFramesEmpty21 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s218 a).isEmpty) = true
kernel_rfl bodyJsRoots21 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s217.next) PRE_first_tail_x8_r0_body.s219.trace PRE_first_tail_x8_r0_body.s219 = true
kernel_rfl bodyJsNative21 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s219.ffi) = true
kernel_rfl bodyLow21 : (PRE_first_tail_x8_r0_body.cws21 ++ PRE_first_tail_x8_r0_body.ws21).all (Nat.ble 9) = true
kernel_rfl bodyCntM21 : countersOkB PRE_first_tail_x8_r0_body.s217 PRE_first_tail_x8_r0_body.s218 = true
kernel_rfl bodyHi21 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s219.ffi).next setupP.E = true
kernel_rfl bodyNhi21 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s219.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge21 : bridgeOf PRE_first_tail_x8_r0_body.s218.ffi = bridgeOf PRE_first_tail_x8_r0_body.s217.ffi
kernel_rfl bodyNN21 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s217.ffi).nnext PRE_first_tail_x8_r0_body.P21.NL = true
kernel_rfl bodyXn21 : Nat.ble (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s219.ffi).next = true
kernel_rfl bodyLo21 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s219.ffi).next = true
theorem bodyFacts21 : BodySiteFacts PRE_first_tail_x8_r0_body.s217 PRE_first_tail_x8_r0_body.s218 PRE_first_tail_x8_r0_body.s219 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S217 PRE_first_tail_x8_r0_body.S218 PRE_first_tail_x8_r0_body.S219
    PRE_first_tail_x8_r0_body.ws21 PRE_first_tail_x8_r0_body.cws21 PRE_first_tail_x8_r0_body.nr21 PRE_first_tail_x8_r0_body.pl21 PRE_first_tail_x8_r0_body.cl21 2692273 996 PRE_first_tail_x8_r0_body.kd21 PRE_first_tail_x8_r0_body.kappa21 PRE_first_tail_x8_r0_body.P21
    ⟨18629, 15713, 2691908, 987⟩ ⟨18633, 15719, 2691923, 996⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap21
  clean := bodyClean21
  cfix := PRE_first_tail_x8_r0_body.cfix21
  zpl := PRE_first_tail_x8_r0_body.zpl21
  zplnd := PRE_first_tail_x8_r0_body.zplnd21
  zn1 := PRE_first_tail_x8_r0_body.zn121
  zfirst := PRE_first_tail_x8_r0_body.zfirst21
  zscn := PRE_first_tail_x8_r0_body.zscn21
  zsmn := PRE_first_tail_x8_r0_body.zsmn21
  zgrow := PRE_first_tail_x8_r0_body.zgrow21
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab21
  zfresh := PRE_first_tail_x8_r0_body.zfresh21
  zcnd := PRE_first_tail_x8_r0_body.zcnd21
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi21
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt21
  zgP := PRE_first_tail_x8_r0_body.zg21_2665
  zkP := PRE_first_tail_x8_r0_body.zk21_2665
  zmP := PRE_first_tail_x8_r0_body.zm21_2665
  zgC := PRE_first_tail_x8_r0_body.zg21_2673467
  zkC := PRE_first_tail_x8_r0_body.zk21_2673467
  zmC := PRE_first_tail_x8_r0_body.zm21_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw21_2673472
  zwV := PRE_first_tail_x8_r0_body.zw21_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap21
  zclbd := PRE_first_tail_x8_r0_body.zclbd21
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap21 PRE_first_tail_x8_r0_body.stFoot21 PRE_first_tail_x8_r0_body.iso21 PRE_first_tail_x8_r0_body.zwr21
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP21
  csupp := PRE_first_tail_x8_r0_body.csupp21
  cbound := PRE_first_tail_x8_r0_body.cbound21
  zimg := PRE_first_tail_x8_r0_body.zimg21
  zctl := PRE_first_tail_x8_r0_body.zctl21
  zstack := PRE_first_tail_x8_r0_body.zstack21
  zjobs := PRE_first_tail_x8_r0_body.zjobs21
  zstores := PRE_first_tail_x8_r0_body.zstores21
  zroots := PRE_first_tail_x8_r0_body.zroots21
  znC := PRE_first_tail_x8_r0_body.znC21
  ctab := PRE_first_tail_x8_r0_body.ctab21
  zbin := PRE_first_tail_x8_r0_body.zbin21
  cbridge := PRE_first_tail_x8_r0_body.cbridge21
  sbridge := bodyBridge21
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj21
  cshiftR := fun h hNL => bodyCshift21 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN21
  raised := PRE_first_tail_x8_r0_body.raised21
  cbigs := PRE_first_tail_x8_r0_body.cbigs21
  cjcl := PRE_first_tail_x8_r0_body.cjcl21
  xnLe := Nat.le_of_ble_eq_true bodyXn21
  loLe := Nat.le_of_ble_eq_true bodyLo21
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB21
  cntM := bodyCntM21
  hiLe := Nat.le_of_ble_eq_true bodyHi21
  nhiLe := Nat.le_of_ble_eq_true bodyNhi21
  jsHeap := bodyJs21
  jsRoots := bodyJsRoots21
  jsNative := bodyJsNative21
  framesEmpty := bodyFramesEmpty21
  trailOld := by decide
  lowVars := bodyLow21

def bodyQs21 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs21 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr21.map fun r => nth? PRE_first_tail_x8_r0_body.st21.S3.tab r
kernel_rfl bodyResChk21 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs21 bodyQs21) = true
kernel_rfl bodyLq21 : bodyQs21.length = PRE_first_tail_x8_r0_body.cws21.length
kernel_rfl bodyNrLo21 : PRE_first_tail_x8_r0_body.nr21.all (Nat.ble PRE_first_tail_x8_r0_body.S217.tab.length) = true
kernel_rfl bodySub21 : (Oracles.PRE_first_tail_x8_r0_body.map_site21.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost21 : postSubB bodyM PRE_first_tail_x8_r0_body.ws21 PRE_first_tail_x8_r0_body.cws21 bodyQs21 = true
kernel_rfl bodyDrop21 : Nat.ble (11452 + (PRE_first_tail_x8_r0_body.s218.next - PRE_first_tail_x8_r0_body.s219.next)) 11802 = true
kernel_rfl bodyDropH21 : Nat.ble (173 + ((mlxOf PRE_first_tail_x8_r0_body.s218.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s219.ffi).next)) 175 = true
kernel_rfl bodyDropN21 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s218.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s219.ffi).nnext)) 0 = true
kernel_rfl bodyDv21 : bodyΘ.1.take 126 = bodyΘ.1.take 117 ++ PRE_first_tail_x8_r0_body.cws21
kernel_rfl bodyDe21 : bodyΘ.2.take 126 = bodyΘ.2.take 117 ++ PRE_first_tail_x8_r0_body.nr21.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st21.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 117) (bodyΘ.2.take 117)))
kernel_rfl bodyDl21 : (bodyΘ.1.take 117).length = (bodyΘ.2.take 117).length
kernel_rfl bodyDold21 : (bodyΘ.1.take 117).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws21).isNone && !PRE_first_tail_x8_r0_body.ws21.contains v) = true
kernel_rfl bodyDfree21 : (bodyΘ.2.take 126).all (fun e => (PRE_first_tail_x8_r0_body.cws21 ++ PRE_first_tail_x8_r0_body.ws21).all fun w => e.noVar w) = true

theorem bodyStep21 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11452, 173, 0, 117⟩ bodyM PRE_first_tail_x8_r0_body.s217 PRE_first_tail_x8_r0_body.S217)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11802, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s219 PRE_first_tail_x8_r0_body.S219) (3452 + 1) :=
  bodySite bodyFacts21.cfix bodyFacts21.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x8_r0_body.st21.S3.tab) (Es := bodyEs21) (qs := bodyQs21)
    (ok := PRE_first_tail_x8_r0_body.st21.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site21 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts21
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site21 r hr) hi (MapOk.sub hm (sub_of_all bodySub21)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk21 r hr) hi hm ho hq)
    bodyLq21 rfl bodyNrLo21 (postSub_sound bodyPost21)
    (Nat.le_of_ble_eq_true bodyDrop21) (by decide) (Nat.le_of_ble_eq_true bodyDropH21) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN21) (by decide)
    bodyDv21 bodyDe21 bodyDl21 bodyDold21 bodyDfree21 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site22 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site22 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site22) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st22.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site22
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st22.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st22.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s225 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s226 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S225 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws22 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st22.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st22.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso22
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_22
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st22.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot22
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup22
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound22
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace22
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged22
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws22.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st22.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S225.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_22]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen22.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh22
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl22 : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s225.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl22 (PRE_first_tail_x8_r0_body.cncl21 bodyNcl21)

theorem bodyClean22 : Conv.JClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s225 :=
  PRE_first_tail_x8_r0_body.gjcl22 (PRE_first_tail_x8_r0_body.cjcl21 bodyClean21)

kernel_rfl bodyJsLe22 : Nat.ble PRE_first_tail_x8_r0_body.s217.next PRE_first_tail_x8_r0_body.s225.next = true
kernel_rfl bodyJsList22 : (PRE_first_tail_x8_r0_body.gjh22 ++ PRE_first_tail_x8_r0_body.cl22).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s225.next) PRE_first_tail_x8_r0_body.s227) = true
theorem bodyJs22 : JsHeapAbove PRE_first_tail_x8_r0_body.s225.next PRE_first_tail_x8_r0_body.s227 :=
  JsHeapAbove.glueSite bodyJs21 (Nat.le_of_ble_eq_true bodyJsLe22) PRE_first_tail_x8_r0_body.gjk22 PRE_first_tail_x8_r0_body.gjbd22 PRE_first_tail_x8_r0_body.cheap22 PRE_first_tail_x8_r0_body.zclbd22 bodyJsList22

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO219 : PRE_first_tail_x8_r0_body.S219.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S219.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr219 : bridgeOf PRE_first_tail_x8_r0_body.s219.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc219 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s219 PRE_first_tail_x8_r0_body.S219) = fun _ _ => true
kernel_rfl bodyAcc220 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s220 PRE_first_tail_x8_r0_body.S220) = fun _ _ => true
kernel_rfl bodyBr221 : bridgeOf PRE_first_tail_x8_r0_body.s221.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt220 : isHalt PRE_first_tail_x8_r0_body.s220.ctl = false
kernel_rfl bodyTop221 : noRetBlock PRE_first_tail_x8_r0_body.s221 = true
kernel_rfl bodyCnt219 : countersOkB PRE_first_tail_x8_r0_body.s219 PRE_first_tail_x8_r0_body.s221 = true
kernel_rfl bodyO221 : PRE_first_tail_x8_r0_body.S221.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S221.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr222 : bridgeOf PRE_first_tail_x8_r0_body.s222.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt221 : countersOkB PRE_first_tail_x8_r0_body.s221 PRE_first_tail_x8_r0_body.s222 = true
kernel_rfl bodyO222 : PRE_first_tail_x8_r0_body.S222.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S222.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc222 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s222 PRE_first_tail_x8_r0_body.S222) = fun _ _ => true
kernel_rfl bodyAcc224 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s224 PRE_first_tail_x8_r0_body.S224) = fun _ _ => true
kernel_rfl bodyBr225 : bridgeOf PRE_first_tail_x8_r0_body.s225.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt224 : isHalt PRE_first_tail_x8_r0_body.s224.ctl = false
kernel_rfl bodyTop225 : noRetBlock PRE_first_tail_x8_r0_body.s225 = true
kernel_rfl bodyCnt222 : countersOkB PRE_first_tail_x8_r0_body.s222 PRE_first_tail_x8_r0_body.s225 = true

theorem bodyGlue22 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11802, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s219 PRE_first_tail_x8_r0_body.S219)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11802, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s225 PRE_first_tail_x8_r0_body.S225) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11802, 175, 0, 126⟩) bodyAcc219 PRE_first_tail_x8_r0_body.bodyRunSeg59 bodyAcc220 bodyHalt220 PRE_first_tail_x8_r0_body.bodyStepA60 bodyTop221 (fun _ hm => bodyO219 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr219).trans bodyInactive0) (bodyBr221.trans bodyBr219.symm) bodyCnt219 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11802, 175, 0, 126⟩) PRE_first_tail_x8_r0_body.sizeA60 PRE_first_tail_x8_r0_body.sizeArgsA60 PRE_first_tail_x8_r0_body.sizeSymA60 PRE_first_tail_x8_r0_body.sizeMlxA60 PRE_first_tail_x8_r0_body.sizePayA60 PRE_first_tail_x8_r0_body.sizeTaA60 PRE_first_tail_x8_r0_body.sizeDecA60 PRE_first_tail_x8_r0_body.sizePreA60 PRE_first_tail_x8_r0_body.bodyPatchB60 (fun _ hm => bodyO221 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr221).trans bodyInactive0) (bodyBr222.trans bodyBr221.symm) bodyCnt221 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11802, 175, 0, 126⟩) bodyAcc222 PRE_first_tail_x8_r0_body.bodyRunSeg60 bodyAcc224 bodyHalt224 PRE_first_tail_x8_r0_body.bodyStepA61 bodyTop225 (fun _ hm => bodyO222 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr222).trans bodyInactive0) (bodyBr225.trans bodyBr222.symm) bodyCnt222 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift22 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S225.tab.length PRE_first_tail_x8_r0_body.s225.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P22.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P22 1019 PRE_first_tail_x8_r0_body.kappa22 PRE_first_tail_x8_r0_body.s227.ffi PRE_first_tail_x8_r0_body.s226.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_22
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_22
  have hcl : SSt (· < 1019) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s227.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S225.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_22] <;> decide) PRE_first_tail_x8_r0_body.cnodesK22 PRE_first_tail_x8_r0_body.cobjsK22
      PRE_first_tail_x8_r0_body.citemsK22 PRE_first_tail_x8_r0_body.cbd22 PRE_first_tail_x8_r0_body.csst22
  exact PRE_first_tail_x8_r0_body.cshift22 bodyNcl22 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_22] at this; exact this)


kernel_rfl bodyFramesEmpty22 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s226 a).isEmpty) = true
kernel_rfl bodyJsRoots22 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s225.next) PRE_first_tail_x8_r0_body.s227.trace PRE_first_tail_x8_r0_body.s227 = true
kernel_rfl bodyJsNative22 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s227.ffi) = true
kernel_rfl bodyLow22 : (PRE_first_tail_x8_r0_body.cws22 ++ PRE_first_tail_x8_r0_body.ws22).all (Nat.ble 9) = true
kernel_rfl bodyCntM22 : countersOkB PRE_first_tail_x8_r0_body.s225 PRE_first_tail_x8_r0_body.s226 = true
kernel_rfl bodyHi22 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s227.ffi).next setupP.E = true
kernel_rfl bodyNhi22 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s227.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge22 : bridgeOf PRE_first_tail_x8_r0_body.s226.ffi = bridgeOf PRE_first_tail_x8_r0_body.s225.ffi
kernel_rfl bodyNN22 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s225.ffi).nnext PRE_first_tail_x8_r0_body.P22.NL = true
kernel_rfl bodyXn22 : Nat.ble (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s227.ffi).next = true
kernel_rfl bodyLo22 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s227.ffi).next = true
theorem bodyFacts22 : BodySiteFacts PRE_first_tail_x8_r0_body.s225 PRE_first_tail_x8_r0_body.s226 PRE_first_tail_x8_r0_body.s227 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S225 PRE_first_tail_x8_r0_body.S226 PRE_first_tail_x8_r0_body.S227
    PRE_first_tail_x8_r0_body.ws22 PRE_first_tail_x8_r0_body.cws22 PRE_first_tail_x8_r0_body.nr22 PRE_first_tail_x8_r0_body.pl22 PRE_first_tail_x8_r0_body.cl22 2692507 1019 PRE_first_tail_x8_r0_body.kd22 PRE_first_tail_x8_r0_body.kappa22 PRE_first_tail_x8_r0_body.P22
    ⟨18646, 15729, 2692505, 1019⟩ ⟨18646, 15729, 2692505, 1019⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap22
  clean := bodyClean22
  cfix := PRE_first_tail_x8_r0_body.cfix22
  zpl := PRE_first_tail_x8_r0_body.zpl22
  zplnd := PRE_first_tail_x8_r0_body.zplnd22
  zn1 := PRE_first_tail_x8_r0_body.zn122
  zfirst := PRE_first_tail_x8_r0_body.zfirst22
  zscn := PRE_first_tail_x8_r0_body.zscn22
  zsmn := PRE_first_tail_x8_r0_body.zsmn22
  zgrow := PRE_first_tail_x8_r0_body.zgrow22
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab22
  zfresh := PRE_first_tail_x8_r0_body.zfresh22
  zcnd := PRE_first_tail_x8_r0_body.zcnd22
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi22
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt22
  zgP := PRE_first_tail_x8_r0_body.zg22_2665
  zkP := PRE_first_tail_x8_r0_body.zk22_2665
  zmP := PRE_first_tail_x8_r0_body.zm22_2665
  zgC := PRE_first_tail_x8_r0_body.zg22_2673467
  zkC := PRE_first_tail_x8_r0_body.zk22_2673467
  zmC := PRE_first_tail_x8_r0_body.zm22_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw22_2673472
  zwV := PRE_first_tail_x8_r0_body.zw22_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap22
  zclbd := PRE_first_tail_x8_r0_body.zclbd22
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap22 PRE_first_tail_x8_r0_body.stFoot22 PRE_first_tail_x8_r0_body.iso22 PRE_first_tail_x8_r0_body.zwr22
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP22
  csupp := PRE_first_tail_x8_r0_body.csupp22
  cbound := PRE_first_tail_x8_r0_body.cbound22
  zimg := PRE_first_tail_x8_r0_body.zimg22
  zctl := PRE_first_tail_x8_r0_body.zctl22
  zstack := PRE_first_tail_x8_r0_body.zstack22
  zjobs := PRE_first_tail_x8_r0_body.zjobs22
  zstores := PRE_first_tail_x8_r0_body.zstores22
  zroots := PRE_first_tail_x8_r0_body.zroots22
  znC := PRE_first_tail_x8_r0_body.znC22
  ctab := PRE_first_tail_x8_r0_body.ctab22
  zbin := PRE_first_tail_x8_r0_body.zbin22
  cbridge := PRE_first_tail_x8_r0_body.cbridge22
  sbridge := bodyBridge22
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj22
  cshiftR := fun h hNL => bodyCshift22 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN22
  raised := PRE_first_tail_x8_r0_body.raised22
  cbigs := PRE_first_tail_x8_r0_body.cbigs22
  cjcl := PRE_first_tail_x8_r0_body.cjcl22
  xnLe := Nat.le_of_ble_eq_true bodyXn22
  loLe := Nat.le_of_ble_eq_true bodyLo22
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB22
  cntM := bodyCntM22
  hiLe := Nat.le_of_ble_eq_true bodyHi22
  nhiLe := Nat.le_of_ble_eq_true bodyNhi22
  jsHeap := bodyJs22
  jsRoots := bodyJsRoots22
  jsNative := bodyJsNative22
  framesEmpty := bodyFramesEmpty22
  trailOld := by decide
  lowVars := bodyLow22

def bodyQs22 : List (Option Q) := []
noncomputable def bodyEs22 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr22.map fun r => nth? PRE_first_tail_x8_r0_body.st22.S2.tab r
kernel_rfl bodyResChk22 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs22 bodyQs22) = true
kernel_rfl bodyLq22 : bodyQs22.length = PRE_first_tail_x8_r0_body.cws22.length
kernel_rfl bodyNrLo22 : PRE_first_tail_x8_r0_body.nr22.all (Nat.ble PRE_first_tail_x8_r0_body.S225.tab.length) = true
kernel_rfl bodySub22 : (Oracles.PRE_first_tail_x8_r0_body.map_site22.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost22 : postSubB bodyM PRE_first_tail_x8_r0_body.ws22 PRE_first_tail_x8_r0_body.cws22 bodyQs22 = true
kernel_rfl bodyDrop22 : Nat.ble (11802 + (PRE_first_tail_x8_r0_body.s226.next - PRE_first_tail_x8_r0_body.s227.next)) 11804 = true
kernel_rfl bodyDropH22 : Nat.ble (175 + ((mlxOf PRE_first_tail_x8_r0_body.s226.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s227.ffi).next)) 175 = true
kernel_rfl bodyDropN22 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s226.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s227.ffi).nnext)) 0 = true
kernel_rfl bodyDv22 : bodyΘ.1.take 126 = bodyΘ.1.take 126 ++ PRE_first_tail_x8_r0_body.cws22
kernel_rfl bodyDe22 : bodyΘ.2.take 126 = bodyΘ.2.take 126 ++ PRE_first_tail_x8_r0_body.nr22.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st22.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 126) (bodyΘ.2.take 126)))
kernel_rfl bodyDl22 : (bodyΘ.1.take 126).length = (bodyΘ.2.take 126).length
kernel_rfl bodyDold22 : (bodyΘ.1.take 126).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws22).isNone && !PRE_first_tail_x8_r0_body.ws22.contains v) = true
kernel_rfl bodyDfree22 : (bodyΘ.2.take 126).all (fun e => (PRE_first_tail_x8_r0_body.cws22 ++ PRE_first_tail_x8_r0_body.ws22).all fun w => e.noVar w) = true

theorem bodyStep22 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11802, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s225 PRE_first_tail_x8_r0_body.S225)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11804, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s227 PRE_first_tail_x8_r0_body.S227) (27 + 1) :=
  bodySite bodyFacts22.cfix bodyFacts22.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x8_r0_body.st22.S2.tab) (Es := bodyEs22) (qs := bodyQs22)
    (ok := PRE_first_tail_x8_r0_body.st22.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site22 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts22
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site22 r hr) hi (MapOk.sub hm (sub_of_all bodySub22)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk22 r hr) hi hm ho hq)
    bodyLq22 rfl bodyNrLo22 (postSub_sound bodyPost22)
    (Nat.le_of_ble_eq_true bodyDrop22) (by decide) (Nat.le_of_ble_eq_true bodyDropH22) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN22) (by decide)
    bodyDv22 bodyDe22 bodyDl22 bodyDold22 bodyDfree22 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site23 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site23 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site23) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site23
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s229 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s230 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S229 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws23 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso23
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_23
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot23
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup23
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound23
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace23
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged23
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws23.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st23.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S229.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_23]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen23.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh23
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl23 : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s229.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl23 (PRE_first_tail_x8_r0_body.cncl22 bodyNcl22)

theorem bodyClean23 : Conv.JClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s229 :=
  PRE_first_tail_x8_r0_body.gjcl23 (PRE_first_tail_x8_r0_body.cjcl22 bodyClean22)

kernel_rfl bodyJsLe23 : Nat.ble PRE_first_tail_x8_r0_body.s225.next PRE_first_tail_x8_r0_body.s229.next = true
kernel_rfl bodyJsList23 : (PRE_first_tail_x8_r0_body.gjh23 ++ PRE_first_tail_x8_r0_body.cl23).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s229.next) PRE_first_tail_x8_r0_body.s231) = true
theorem bodyJs23 : JsHeapAbove PRE_first_tail_x8_r0_body.s229.next PRE_first_tail_x8_r0_body.s231 :=
  JsHeapAbove.glueSite bodyJs22 (Nat.le_of_ble_eq_true bodyJsLe23) PRE_first_tail_x8_r0_body.gjk23 PRE_first_tail_x8_r0_body.gjbd23 PRE_first_tail_x8_r0_body.cheap23 PRE_first_tail_x8_r0_body.zclbd23 bodyJsList23

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO227 : PRE_first_tail_x8_r0_body.S227.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S227.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr227 : bridgeOf PRE_first_tail_x8_r0_body.s227.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc227 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s227 PRE_first_tail_x8_r0_body.S227) = fun _ _ => true
kernel_rfl bodyAcc228 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s228 PRE_first_tail_x8_r0_body.S228) = fun _ _ => true
kernel_rfl bodyBr229 : bridgeOf PRE_first_tail_x8_r0_body.s229.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt228 : isHalt PRE_first_tail_x8_r0_body.s228.ctl = false
kernel_rfl bodyTop229 : noRetBlock PRE_first_tail_x8_r0_body.s229 = true
kernel_rfl bodyCnt227 : countersOkB PRE_first_tail_x8_r0_body.s227 PRE_first_tail_x8_r0_body.s229 = true

theorem bodyGlue23 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11804, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s227 PRE_first_tail_x8_r0_body.S227)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11804, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s229 PRE_first_tail_x8_r0_body.S229) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11804, 175, 0, 126⟩) bodyAcc227 PRE_first_tail_x8_r0_body.bodyRunSeg61 bodyAcc228 bodyHalt228 PRE_first_tail_x8_r0_body.bodyStepA62 bodyTop229 (fun _ hm => bodyO227 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr227).trans bodyInactive0) (bodyBr229.trans bodyBr227.symm) bodyCnt227 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift23 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S229.tab.length PRE_first_tail_x8_r0_body.s229.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P23.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P23 1036 PRE_first_tail_x8_r0_body.kappa23 PRE_first_tail_x8_r0_body.s231.ffi PRE_first_tail_x8_r0_body.s230.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_23
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_23
  have hcl : SSt (· < 1036) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s231.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S229.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_23] <;> decide) PRE_first_tail_x8_r0_body.cnodesK23 PRE_first_tail_x8_r0_body.cobjsK23
      PRE_first_tail_x8_r0_body.citemsK23 PRE_first_tail_x8_r0_body.cbd23 PRE_first_tail_x8_r0_body.csst23
  exact PRE_first_tail_x8_r0_body.cshift23 bodyNcl23 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_23] at this; exact this)


kernel_rfl bodyFramesEmpty23 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s230 a).isEmpty) = true
kernel_rfl bodyJsRoots23 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s229.next) PRE_first_tail_x8_r0_body.s231.trace PRE_first_tail_x8_r0_body.s231 = true
kernel_rfl bodyJsNative23 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s231.ffi) = true
kernel_rfl bodyLow23 : (PRE_first_tail_x8_r0_body.cws23 ++ PRE_first_tail_x8_r0_body.ws23).all (Nat.ble 9) = true
kernel_rfl bodyCntM23 : countersOkB PRE_first_tail_x8_r0_body.s229 PRE_first_tail_x8_r0_body.s230 = true
kernel_rfl bodyHi23 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s231.ffi).next setupP.E = true
kernel_rfl bodyNhi23 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s231.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge23 : bridgeOf PRE_first_tail_x8_r0_body.s230.ffi = bridgeOf PRE_first_tail_x8_r0_body.s229.ffi
kernel_rfl bodyNN23 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s229.ffi).nnext PRE_first_tail_x8_r0_body.P23.NL = true
kernel_rfl bodyXn23 : Nat.ble (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s231.ffi).next = true
kernel_rfl bodyLo23 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s231.ffi).next = true
theorem bodyFacts23 : BodySiteFacts PRE_first_tail_x8_r0_body.s229 PRE_first_tail_x8_r0_body.s230 PRE_first_tail_x8_r0_body.s231 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S229 PRE_first_tail_x8_r0_body.S230 PRE_first_tail_x8_r0_body.S231
    PRE_first_tail_x8_r0_body.ws23 PRE_first_tail_x8_r0_body.cws23 PRE_first_tail_x8_r0_body.nr23 PRE_first_tail_x8_r0_body.pl23 PRE_first_tail_x8_r0_body.cl23 2692804 1036 PRE_first_tail_x8_r0_body.kd23 PRE_first_tail_x8_r0_body.kappa23 PRE_first_tail_x8_r0_body.P23
    ⟨18653, 15733, 2692793, 1036⟩ ⟨18653, 15733, 2692794, 1036⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap23
  clean := bodyClean23
  cfix := PRE_first_tail_x8_r0_body.cfix23
  zpl := PRE_first_tail_x8_r0_body.zpl23
  zplnd := PRE_first_tail_x8_r0_body.zplnd23
  zn1 := PRE_first_tail_x8_r0_body.zn123
  zfirst := PRE_first_tail_x8_r0_body.zfirst23
  zscn := PRE_first_tail_x8_r0_body.zscn23
  zsmn := PRE_first_tail_x8_r0_body.zsmn23
  zgrow := PRE_first_tail_x8_r0_body.zgrow23
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab23
  zfresh := PRE_first_tail_x8_r0_body.zfresh23
  zcnd := PRE_first_tail_x8_r0_body.zcnd23
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi23
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt23
  zgP := PRE_first_tail_x8_r0_body.zg23_2665
  zkP := PRE_first_tail_x8_r0_body.zk23_2665
  zmP := PRE_first_tail_x8_r0_body.zm23_2665
  zgC := PRE_first_tail_x8_r0_body.zg23_2673467
  zkC := PRE_first_tail_x8_r0_body.zk23_2673467
  zmC := PRE_first_tail_x8_r0_body.zm23_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw23_2673472
  zwV := PRE_first_tail_x8_r0_body.zw23_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap23
  zclbd := PRE_first_tail_x8_r0_body.zclbd23
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap23 PRE_first_tail_x8_r0_body.stFoot23 PRE_first_tail_x8_r0_body.iso23 PRE_first_tail_x8_r0_body.zwr23
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP23
  csupp := PRE_first_tail_x8_r0_body.csupp23
  cbound := PRE_first_tail_x8_r0_body.cbound23
  zimg := PRE_first_tail_x8_r0_body.zimg23
  zctl := PRE_first_tail_x8_r0_body.zctl23
  zstack := PRE_first_tail_x8_r0_body.zstack23
  zjobs := PRE_first_tail_x8_r0_body.zjobs23
  zstores := PRE_first_tail_x8_r0_body.zstores23
  zroots := PRE_first_tail_x8_r0_body.zroots23
  znC := PRE_first_tail_x8_r0_body.znC23
  ctab := PRE_first_tail_x8_r0_body.ctab23
  zbin := PRE_first_tail_x8_r0_body.zbin23
  cbridge := PRE_first_tail_x8_r0_body.cbridge23
  sbridge := bodyBridge23
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj23
  cshiftR := fun h hNL => bodyCshift23 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN23
  raised := PRE_first_tail_x8_r0_body.raised23
  cbigs := PRE_first_tail_x8_r0_body.cbigs23
  cjcl := PRE_first_tail_x8_r0_body.cjcl23
  xnLe := Nat.le_of_ble_eq_true bodyXn23
  loLe := Nat.le_of_ble_eq_true bodyLo23
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB23
  cntM := bodyCntM23
  hiLe := Nat.le_of_ble_eq_true bodyHi23
  nhiLe := Nat.le_of_ble_eq_true bodyNhi23
  jsHeap := bodyJs23
  jsRoots := bodyJsRoots23
  jsNative := bodyJsNative23
  framesEmpty := bodyFramesEmpty23
  trailOld := by decide
  lowVars := bodyLow23

def bodyQs23 : List (Option Q) := []
noncomputable def bodyEs23 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr23.map fun r => nth? PRE_first_tail_x8_r0_body.st23.S2.tab r
kernel_rfl bodyResChk23 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs23 bodyQs23) = true
kernel_rfl bodyLq23 : bodyQs23.length = PRE_first_tail_x8_r0_body.cws23.length
kernel_rfl bodyNrLo23 : PRE_first_tail_x8_r0_body.nr23.all (Nat.ble PRE_first_tail_x8_r0_body.S229.tab.length) = true
kernel_rfl bodySub23 : (Oracles.PRE_first_tail_x8_r0_body.map_site23.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost23 : postSubB bodyM PRE_first_tail_x8_r0_body.ws23 PRE_first_tail_x8_r0_body.cws23 bodyQs23 = true
kernel_rfl bodyDrop23 : Nat.ble (11804 + (PRE_first_tail_x8_r0_body.s230.next - PRE_first_tail_x8_r0_body.s231.next)) 11814 = true
kernel_rfl bodyDropH23 : Nat.ble (175 + ((mlxOf PRE_first_tail_x8_r0_body.s230.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s231.ffi).next)) 175 = true
kernel_rfl bodyDropN23 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s230.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s231.ffi).nnext)) 0 = true
kernel_rfl bodyDv23 : bodyΘ.1.take 126 = bodyΘ.1.take 126 ++ PRE_first_tail_x8_r0_body.cws23
kernel_rfl bodyDe23 : bodyΘ.2.take 126 = bodyΘ.2.take 126 ++ PRE_first_tail_x8_r0_body.nr23.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st23.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 126) (bodyΘ.2.take 126)))
kernel_rfl bodyDl23 : (bodyΘ.1.take 126).length = (bodyΘ.2.take 126).length
kernel_rfl bodyDold23 : (bodyΘ.1.take 126).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws23).isNone && !PRE_first_tail_x8_r0_body.ws23.contains v) = true
kernel_rfl bodyDfree23 : (bodyΘ.2.take 126).all (fun e => (PRE_first_tail_x8_r0_body.cws23 ++ PRE_first_tail_x8_r0_body.ws23).all fun w => e.noVar w) = true

theorem bodyStep23 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11804, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s229 PRE_first_tail_x8_r0_body.S229)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11814, 175, 0, 126⟩ bodyM PRE_first_tail_x8_r0_body.s231 PRE_first_tail_x8_r0_body.S231) (98 + 1) :=
  bodySite bodyFacts23.cfix bodyFacts23.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x8_r0_body.st23.S2.tab) (Es := bodyEs23) (qs := bodyQs23)
    (ok := PRE_first_tail_x8_r0_body.st23.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site23 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts23
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site23 r hr) hi (MapOk.sub hm (sub_of_all bodySub23)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk23 r hr) hi hm ho hq)
    bodyLq23 rfl bodyNrLo23 (postSub_sound bodyPost23)
    (Nat.le_of_ble_eq_true bodyDrop23) (by decide) (Nat.le_of_ble_eq_true bodyDropH23) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN23) (by decide)
    bodyDv23 bodyDe23 bodyDl23 bodyDold23 bodyDfree23 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end
