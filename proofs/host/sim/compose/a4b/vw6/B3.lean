import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x6_r0_body.States
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B18
import host.sim.compose.a4b.vw6.B2
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B34
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw6.VWBodyChain
import host.sim.compose.a4b.vw6.VWBodyMap
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B14
import host.sim.template.CallGen

section -- VWBodyOracles_6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_g24 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g24 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g24) (List.take 16 (List.drop 234 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site24 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site24 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site24) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st24.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g25 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g25 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g25) (List.take 7 (List.drop 250 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site25 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site25 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site25) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st25.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g26 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g26 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g26) (List.take 3 (List.drop 257 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

noncomputable def PRE_first_tail_x6_r0_body.map_site26 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site26 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site26) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g27 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g27 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g27) (List.take 16 (List.drop 260 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site27 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site27 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site27) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st27.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site24 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site24 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site24) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st24.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site24
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st24.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s246 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s247 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S246 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws24 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st24.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st24.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso24
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_24
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st24.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot24
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup24
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound24
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace24
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged24
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws24.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st24.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S246.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_24]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen24.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh24
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl24 : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s246.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl24 (PRE_first_tail_x6_r0_body.cncl23 bodyNcl23)

theorem bodyClean24 : Conv.JClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s246 :=
  PRE_first_tail_x6_r0_body.gjcl24 (PRE_first_tail_x6_r0_body.cjcl23 bodyClean23)

kernel_rfl bodyJsLe24 : Nat.ble PRE_first_tail_x6_r0_body.s229.next PRE_first_tail_x6_r0_body.s246.next = true
kernel_rfl bodyJsList24 : (PRE_first_tail_x6_r0_body.gjh24 ++ PRE_first_tail_x6_r0_body.cl24).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s246.next) PRE_first_tail_x6_r0_body.s248) = true
theorem bodyJs24 : JsHeapAbove PRE_first_tail_x6_r0_body.s246.next PRE_first_tail_x6_r0_body.s248 :=
  JsHeapAbove.glueSite bodyJs23 (Nat.le_of_ble_eq_true bodyJsLe24) PRE_first_tail_x6_r0_body.gjk24 PRE_first_tail_x6_r0_body.gjbd24 PRE_first_tail_x6_r0_body.cheap24 PRE_first_tail_x6_r0_body.zclbd24 bodyJsList24

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO231 : PRE_first_tail_x6_r0_body.S231.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S231.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr231 : bridgeOf PRE_first_tail_x6_r0_body.s231.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc231 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s231 PRE_first_tail_x6_r0_body.S231) = fun _ _ => true
kernel_rfl bodyAcc233 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s233 PRE_first_tail_x6_r0_body.S233) = fun _ _ => true
kernel_rfl bodyBr234 : bridgeOf PRE_first_tail_x6_r0_body.s234.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt233 : isHalt PRE_first_tail_x6_r0_body.s233.ctl = false
kernel_rfl bodyTop234 : noRetBlock PRE_first_tail_x6_r0_body.s234 = true
kernel_rfl bodyCnt231 : countersOkB PRE_first_tail_x6_r0_body.s231 PRE_first_tail_x6_r0_body.s234 = true
kernel_rfl bodyO234 : PRE_first_tail_x6_r0_body.S234.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S234.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr235 : bridgeOf PRE_first_tail_x6_r0_body.s235.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt234 : countersOkB PRE_first_tail_x6_r0_body.s234 PRE_first_tail_x6_r0_body.s235 = true
kernel_rfl bodyO235 : PRE_first_tail_x6_r0_body.S235.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S235.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc235 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s235 PRE_first_tail_x6_r0_body.S235) = fun _ _ => true
kernel_rfl bodyAcc236 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s236 PRE_first_tail_x6_r0_body.S236) = fun _ _ => true
kernel_rfl bodyBr237 : bridgeOf PRE_first_tail_x6_r0_body.s237.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt236 : isHalt PRE_first_tail_x6_r0_body.s236.ctl = false
kernel_rfl bodyTop237 : noRetBlock PRE_first_tail_x6_r0_body.s237 = true
kernel_rfl bodyCnt235 : countersOkB PRE_first_tail_x6_r0_body.s235 PRE_first_tail_x6_r0_body.s237 = true
kernel_rfl bodyO237 : PRE_first_tail_x6_r0_body.S237.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S237.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr238 : bridgeOf PRE_first_tail_x6_r0_body.s238.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt237 : countersOkB PRE_first_tail_x6_r0_body.s237 PRE_first_tail_x6_r0_body.s238 = true
kernel_rfl bodyO238 : PRE_first_tail_x6_r0_body.S238.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S238.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc238 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s238 PRE_first_tail_x6_r0_body.S238) = fun _ _ => true
kernel_rfl bodyAcc239 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s239 PRE_first_tail_x6_r0_body.S239) = fun _ _ => true
kernel_rfl bodyBr240 : bridgeOf PRE_first_tail_x6_r0_body.s240.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt239 : isHalt PRE_first_tail_x6_r0_body.s239.ctl = false
kernel_rfl bodyTop240 : noRetBlock PRE_first_tail_x6_r0_body.s240 = true
kernel_rfl bodyCnt238 : countersOkB PRE_first_tail_x6_r0_body.s238 PRE_first_tail_x6_r0_body.s240 = true
kernel_rfl bodyO240 : PRE_first_tail_x6_r0_body.S240.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S240.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr241 : bridgeOf PRE_first_tail_x6_r0_body.s241.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt240 : countersOkB PRE_first_tail_x6_r0_body.s240 PRE_first_tail_x6_r0_body.s241 = true
kernel_rfl bodyO241 : PRE_first_tail_x6_r0_body.S241.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S241.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc241 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s241 PRE_first_tail_x6_r0_body.S241) = fun _ _ => true
kernel_rfl bodyAcc242 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s242 PRE_first_tail_x6_r0_body.S242) = fun _ _ => true
kernel_rfl bodyBr243 : bridgeOf PRE_first_tail_x6_r0_body.s243.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt242 : isHalt PRE_first_tail_x6_r0_body.s242.ctl = false
kernel_rfl bodyTop243 : noRetBlock PRE_first_tail_x6_r0_body.s243 = true
kernel_rfl bodyCnt241 : countersOkB PRE_first_tail_x6_r0_body.s241 PRE_first_tail_x6_r0_body.s243 = true
kernel_rfl bodyO243 : PRE_first_tail_x6_r0_body.S243.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S243.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr244 : bridgeOf PRE_first_tail_x6_r0_body.s244.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt243 : countersOkB PRE_first_tail_x6_r0_body.s243 PRE_first_tail_x6_r0_body.s244 = true
kernel_rfl bodyO244 : PRE_first_tail_x6_r0_body.S244.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S244.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc244 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s244 PRE_first_tail_x6_r0_body.S244) = fun _ _ => true
kernel_rfl bodyAcc245 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s245 PRE_first_tail_x6_r0_body.S245) = fun _ _ => true
kernel_rfl bodyBr246 : bridgeOf PRE_first_tail_x6_r0_body.s246.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt245 : isHalt PRE_first_tail_x6_r0_body.s245.ctl = false
kernel_rfl bodyTop246 : noRetBlock PRE_first_tail_x6_r0_body.s246 = true
kernel_rfl bodyCnt244 : countersOkB PRE_first_tail_x6_r0_body.s244 PRE_first_tail_x6_r0_body.s246 = true

theorem bodyGlue24 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11813, 175, 0, 126⟩ bodyM PRE_first_tail_x6_r0_body.s231 PRE_first_tail_x6_r0_body.S231)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11813, 175, 0, 126⟩ bodyM PRE_first_tail_x6_r0_body.s246 PRE_first_tail_x6_r0_body.S246) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc231 PRE_first_tail_x6_r0_body.bodyRunSeg62 bodyAcc233 bodyHalt233 PRE_first_tail_x6_r0_body.bodyStepA63 bodyTop234 (fun _ hm => bodyO231 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr231).trans bodyInactive0) (bodyBr234.trans bodyBr231.symm) bodyCnt231 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) PRE_first_tail_x6_r0_body.sizeA63 PRE_first_tail_x6_r0_body.sizeArgsA63 PRE_first_tail_x6_r0_body.sizeSymA63 PRE_first_tail_x6_r0_body.sizeMlxA63 PRE_first_tail_x6_r0_body.sizePayA63 PRE_first_tail_x6_r0_body.sizeTaA63 PRE_first_tail_x6_r0_body.sizeDecA63 PRE_first_tail_x6_r0_body.sizePreA63 PRE_first_tail_x6_r0_body.bodyPatchB63 (fun _ hm => bodyO234 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr234).trans bodyInactive0) (bodyBr235.trans bodyBr234.symm) bodyCnt234 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc235 PRE_first_tail_x6_r0_body.bodyRunSeg63 bodyAcc236 bodyHalt236 PRE_first_tail_x6_r0_body.bodyStepA64 bodyTop237 (fun _ hm => bodyO235 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr235).trans bodyInactive0) (bodyBr237.trans bodyBr235.symm) bodyCnt235 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) PRE_first_tail_x6_r0_body.sizeA64 PRE_first_tail_x6_r0_body.sizeArgsA64 PRE_first_tail_x6_r0_body.sizeSymA64 PRE_first_tail_x6_r0_body.sizeMlxA64 PRE_first_tail_x6_r0_body.sizePayA64 PRE_first_tail_x6_r0_body.sizeTaA64 PRE_first_tail_x6_r0_body.sizeDecA64 PRE_first_tail_x6_r0_body.sizePreA64 PRE_first_tail_x6_r0_body.bodyPatchB64 (fun _ hm => bodyO237 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr237).trans bodyInactive0) (bodyBr238.trans bodyBr237.symm) bodyCnt237 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc238 PRE_first_tail_x6_r0_body.bodyRunSeg64 bodyAcc239 bodyHalt239 PRE_first_tail_x6_r0_body.bodyStepA65 bodyTop240 (fun _ hm => bodyO238 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr238).trans bodyInactive0) (bodyBr240.trans bodyBr238.symm) bodyCnt238 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) PRE_first_tail_x6_r0_body.sizeA65 PRE_first_tail_x6_r0_body.sizeArgsA65 PRE_first_tail_x6_r0_body.sizeSymA65 PRE_first_tail_x6_r0_body.sizeMlxA65 PRE_first_tail_x6_r0_body.sizePayA65 PRE_first_tail_x6_r0_body.sizeTaA65 PRE_first_tail_x6_r0_body.sizeDecA65 PRE_first_tail_x6_r0_body.sizePreA65 PRE_first_tail_x6_r0_body.bodyPatchB65 (fun _ hm => bodyO240 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr240).trans bodyInactive0) (bodyBr241.trans bodyBr240.symm) bodyCnt240 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc241 PRE_first_tail_x6_r0_body.bodyRunSeg65 bodyAcc242 bodyHalt242 PRE_first_tail_x6_r0_body.bodyStepA66 bodyTop243 (fun _ hm => bodyO241 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr241).trans bodyInactive0) (bodyBr243.trans bodyBr241.symm) bodyCnt241 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) PRE_first_tail_x6_r0_body.sizeA66 PRE_first_tail_x6_r0_body.sizeArgsA66 PRE_first_tail_x6_r0_body.sizeSymA66 PRE_first_tail_x6_r0_body.sizeMlxA66 PRE_first_tail_x6_r0_body.sizePayA66 PRE_first_tail_x6_r0_body.sizeTaA66 PRE_first_tail_x6_r0_body.sizeDecA66 PRE_first_tail_x6_r0_body.sizePreA66 PRE_first_tail_x6_r0_body.bodyPatchB66 (fun _ hm => bodyO243 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr243).trans bodyInactive0) (bodyBr244.trans bodyBr243.symm) bodyCnt243 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc244 PRE_first_tail_x6_r0_body.bodyRunSeg66 bodyAcc245 bodyHalt245 PRE_first_tail_x6_r0_body.bodyStepA67 bodyTop246 (fun _ hm => bodyO244 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr244).trans bodyInactive0) (bodyBr246.trans bodyBr244.symm) bodyCnt244 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift24 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S246.tab.length PRE_first_tail_x6_r0_body.s246.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P24.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P24 1127 PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.s248.ffi PRE_first_tail_x6_r0_body.s247.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_24
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_24
  have hcl : SSt (· < 1127) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s248.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S246.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_24] <;> decide) PRE_first_tail_x6_r0_body.cnodesK24 PRE_first_tail_x6_r0_body.cobjsK24
      PRE_first_tail_x6_r0_body.citemsK24 PRE_first_tail_x6_r0_body.cbd24 PRE_first_tail_x6_r0_body.csst24
  exact PRE_first_tail_x6_r0_body.cshift24 bodyNcl24 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_24] at this; exact this)


kernel_rfl bodyFramesEmpty24 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s247 a).isEmpty) = true
kernel_rfl bodyJsRoots24 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s246.next) PRE_first_tail_x6_r0_body.s248.trace PRE_first_tail_x6_r0_body.s248 = true
kernel_rfl bodyJsNative24 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s248.ffi) = true
kernel_rfl bodyLow24 : (PRE_first_tail_x6_r0_body.cws24 ++ PRE_first_tail_x6_r0_body.ws24).all (Nat.ble 9) = true
kernel_rfl bodyCntM24 : countersOkB PRE_first_tail_x6_r0_body.s246 PRE_first_tail_x6_r0_body.s247 = true
kernel_rfl bodyHi24 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s248.ffi).next setupP.E = true
kernel_rfl bodyNhi24 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s248.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge24 : bridgeOf PRE_first_tail_x6_r0_body.s247.ffi = bridgeOf PRE_first_tail_x6_r0_body.s246.ffi
kernel_rfl bodyNN24 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s246.ffi).nnext PRE_first_tail_x6_r0_body.P24.NL = true
kernel_rfl bodyXn24 : Nat.ble (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s248.ffi).next = true
kernel_rfl bodyLo24 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s248.ffi).next = true
theorem bodyFacts24 : BodySiteFacts PRE_first_tail_x6_r0_body.s246 PRE_first_tail_x6_r0_body.s247 PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S246 PRE_first_tail_x6_r0_body.S247 PRE_first_tail_x6_r0_body.S248
    PRE_first_tail_x6_r0_body.ws24 PRE_first_tail_x6_r0_body.cws24 PRE_first_tail_x6_r0_body.nr24 PRE_first_tail_x6_r0_body.pl24 PRE_first_tail_x6_r0_body.cl24 2695442 1127 PRE_first_tail_x6_r0_body.kd24 PRE_first_tail_x6_r0_body.kappa24 PRE_first_tail_x6_r0_body.P24
    ⟨18688, 15752, 2694287, 1109⟩ ⟨18691, 15779, 2694293, 1127⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap24
  clean := bodyClean24
  cfix := PRE_first_tail_x6_r0_body.cfix24
  zpl := PRE_first_tail_x6_r0_body.zpl24
  zplnd := PRE_first_tail_x6_r0_body.zplnd24
  zn1 := PRE_first_tail_x6_r0_body.zn124
  zfirst := PRE_first_tail_x6_r0_body.zfirst24
  zscn := PRE_first_tail_x6_r0_body.zscn24
  zsmn := PRE_first_tail_x6_r0_body.zsmn24
  zgrow := PRE_first_tail_x6_r0_body.zgrow24
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab24
  zfresh := PRE_first_tail_x6_r0_body.zfresh24
  zcnd := PRE_first_tail_x6_r0_body.zcnd24
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi24
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt24
  zgP := PRE_first_tail_x6_r0_body.zg24_2665
  zkP := PRE_first_tail_x6_r0_body.zk24_2665
  zmP := PRE_first_tail_x6_r0_body.zm24_2665
  zgC := PRE_first_tail_x6_r0_body.zg24_2673467
  zkC := PRE_first_tail_x6_r0_body.zk24_2673467
  zmC := PRE_first_tail_x6_r0_body.zm24_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw24_2673472
  zwV := PRE_first_tail_x6_r0_body.zw24_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap24
  zclbd := PRE_first_tail_x6_r0_body.zclbd24
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap24 PRE_first_tail_x6_r0_body.stFoot24 PRE_first_tail_x6_r0_body.iso24 PRE_first_tail_x6_r0_body.zwr24
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP24
  csupp := PRE_first_tail_x6_r0_body.csupp24
  cbound := PRE_first_tail_x6_r0_body.cbound24
  zimg := PRE_first_tail_x6_r0_body.zimg24
  zctl := PRE_first_tail_x6_r0_body.zctl24
  zstack := PRE_first_tail_x6_r0_body.zstack24
  zjobs := PRE_first_tail_x6_r0_body.zjobs24
  zstores := PRE_first_tail_x6_r0_body.zstores24
  zroots := PRE_first_tail_x6_r0_body.zroots24
  znC := PRE_first_tail_x6_r0_body.znC24
  ctab := PRE_first_tail_x6_r0_body.ctab24
  zbin := PRE_first_tail_x6_r0_body.zbin24
  cbridge := PRE_first_tail_x6_r0_body.cbridge24
  sbridge := bodyBridge24
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj24
  cshiftR := fun h hNL => bodyCshift24 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN24
  raised := PRE_first_tail_x6_r0_body.raised24
  cbigs := PRE_first_tail_x6_r0_body.cbigs24
  cjcl := PRE_first_tail_x6_r0_body.cjcl24
  xnLe := Nat.le_of_ble_eq_true bodyXn24
  loLe := Nat.le_of_ble_eq_true bodyLo24
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB24
  cntM := bodyCntM24
  hiLe := Nat.le_of_ble_eq_true bodyHi24
  nhiLe := Nat.le_of_ble_eq_true bodyNhi24
  jsHeap := bodyJs24
  jsRoots := bodyJsRoots24
  jsNative := bodyJsNative24
  framesEmpty := bodyFramesEmpty24
  trailOld := by decide
  lowVars := bodyLow24

def bodyQs24 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs24 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr24.map fun r => nth? PRE_first_tail_x6_r0_body.st24.S5.tab r
kernel_rfl bodyResChk24 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs24 bodyQs24) = true
kernel_rfl bodyLq24 : bodyQs24.length = PRE_first_tail_x6_r0_body.cws24.length
kernel_rfl bodyNrLo24 : PRE_first_tail_x6_r0_body.nr24.all (Nat.ble PRE_first_tail_x6_r0_body.S246.tab.length) = true
kernel_rfl bodySub24 : (Oracles.PRE_first_tail_x6_r0_body.map_site24.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost24 : postSubB bodyM PRE_first_tail_x6_r0_body.ws24 PRE_first_tail_x6_r0_body.cws24 bodyQs24 = true
kernel_rfl bodyDrop24 : Nat.ble (11813 + (PRE_first_tail_x6_r0_body.s247.next - PRE_first_tail_x6_r0_body.s248.next)) 12962 = true
kernel_rfl bodyDropH24 : Nat.ble (175 + ((mlxOf PRE_first_tail_x6_r0_body.s247.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s248.ffi).next)) 200 = true
kernel_rfl bodyDropN24 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s247.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s248.ffi).nnext)) 0 = true
kernel_rfl bodyDv24 : bodyΘ.1.take 144 = bodyΘ.1.take 126 ++ PRE_first_tail_x6_r0_body.cws24
kernel_rfl bodyDe24 : bodyΘ.2.take 144 = bodyΘ.2.take 126 ++ PRE_first_tail_x6_r0_body.nr24.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st24.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 126) (bodyΘ.2.take 126)))
kernel_rfl bodyDl24 : (bodyΘ.1.take 126).length = (bodyΘ.2.take 126).length
kernel_rfl bodyDold24 : (bodyΘ.1.take 126).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws24).isNone && !PRE_first_tail_x6_r0_body.ws24.contains v) = true
kernel_rfl bodyDfree24 : (bodyΘ.2.take 144).all (fun e => (PRE_first_tail_x6_r0_body.cws24 ++ PRE_first_tail_x6_r0_body.ws24).all fun w => e.noVar w) = true

theorem bodyStep24 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11813, 175, 0, 126⟩ bodyM PRE_first_tail_x6_r0_body.s246 PRE_first_tail_x6_r0_body.S246)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12962, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.S248) (11334 + 1) :=
  bodySite bodyFacts24.cfix bodyFacts24.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x6_r0_body.st24.S5.tab) (Es := bodyEs24) (qs := bodyQs24)
    (ok := PRE_first_tail_x6_r0_body.st24.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site24 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts24
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site24 r hr) hi (MapOk.sub hm (sub_of_all bodySub24)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk24 r hr) hi hm ho hq)
    bodyLq24 rfl bodyNrLo24 (postSub_sound bodyPost24)
    (Nat.le_of_ble_eq_true bodyDrop24) (by decide) (Nat.le_of_ble_eq_true bodyDropH24) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN24) (by decide)
    bodyDv24 bodyDe24 bodyDl24 bodyDold24 bodyDfree24 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site25 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site25 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site25) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st25.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site25
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st25.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s254 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s255 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S254 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws25 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st25.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st25.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso25
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_25
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st25.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot25
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup25
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound25
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace25
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged25
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws25.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st25.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S254.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_25]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen25.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh25
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl25 : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s254.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl25 (PRE_first_tail_x6_r0_body.cncl24 bodyNcl24)

theorem bodyClean25 : Conv.JClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s254 :=
  PRE_first_tail_x6_r0_body.gjcl25 (PRE_first_tail_x6_r0_body.cjcl24 bodyClean24)

kernel_rfl bodyJsLe25 : Nat.ble PRE_first_tail_x6_r0_body.s246.next PRE_first_tail_x6_r0_body.s254.next = true
kernel_rfl bodyJsList25 : (PRE_first_tail_x6_r0_body.gjh25 ++ PRE_first_tail_x6_r0_body.cl25).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s254.next) PRE_first_tail_x6_r0_body.s256) = true
theorem bodyJs25 : JsHeapAbove PRE_first_tail_x6_r0_body.s254.next PRE_first_tail_x6_r0_body.s256 :=
  JsHeapAbove.glueSite bodyJs24 (Nat.le_of_ble_eq_true bodyJsLe25) PRE_first_tail_x6_r0_body.gjk25 PRE_first_tail_x6_r0_body.gjbd25 PRE_first_tail_x6_r0_body.cheap25 PRE_first_tail_x6_r0_body.zclbd25 bodyJsList25

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO248 : PRE_first_tail_x6_r0_body.S248.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S248.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr248 : bridgeOf PRE_first_tail_x6_r0_body.s248.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc248 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.S248) = fun _ _ => true
kernel_rfl bodyAcc249 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s249 PRE_first_tail_x6_r0_body.S249) = fun _ _ => true
kernel_rfl bodyBr250 : bridgeOf PRE_first_tail_x6_r0_body.s250.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt249 : isHalt PRE_first_tail_x6_r0_body.s249.ctl = false
kernel_rfl bodyTop250 : noRetBlock PRE_first_tail_x6_r0_body.s250 = true
kernel_rfl bodyCnt248 : countersOkB PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.s250 = true
kernel_rfl bodyO250 : PRE_first_tail_x6_r0_body.S250.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S250.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr251 : bridgeOf PRE_first_tail_x6_r0_body.s251.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt250 : countersOkB PRE_first_tail_x6_r0_body.s250 PRE_first_tail_x6_r0_body.s251 = true
kernel_rfl bodyO251 : PRE_first_tail_x6_r0_body.S251.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S251.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc251 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s251 PRE_first_tail_x6_r0_body.S251) = fun _ _ => true
kernel_rfl bodyAcc253 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s253 PRE_first_tail_x6_r0_body.S253) = fun _ _ => true
kernel_rfl bodyBr254 : bridgeOf PRE_first_tail_x6_r0_body.s254.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt253 : isHalt PRE_first_tail_x6_r0_body.s253.ctl = false
kernel_rfl bodyTop254 : noRetBlock PRE_first_tail_x6_r0_body.s254 = true
kernel_rfl bodyCnt251 : countersOkB PRE_first_tail_x6_r0_body.s251 PRE_first_tail_x6_r0_body.s254 = true

theorem bodyGlue25 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12962, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s248 PRE_first_tail_x6_r0_body.S248)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12962, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s254 PRE_first_tail_x6_r0_body.S254) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12962, 200, 0, 144⟩) bodyAcc248 PRE_first_tail_x6_r0_body.bodyRunSeg67 bodyAcc249 bodyHalt249 PRE_first_tail_x6_r0_body.bodyStepA68 bodyTop250 (fun _ hm => bodyO248 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr248).trans bodyInactive0) (bodyBr250.trans bodyBr248.symm) bodyCnt248 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12962, 200, 0, 144⟩) PRE_first_tail_x6_r0_body.sizeA68 PRE_first_tail_x6_r0_body.sizeArgsA68 PRE_first_tail_x6_r0_body.sizeSymA68 PRE_first_tail_x6_r0_body.sizeMlxA68 PRE_first_tail_x6_r0_body.sizePayA68 PRE_first_tail_x6_r0_body.sizeTaA68 PRE_first_tail_x6_r0_body.sizeDecA68 PRE_first_tail_x6_r0_body.sizePreA68 PRE_first_tail_x6_r0_body.bodyPatchB68 (fun _ hm => bodyO250 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr250).trans bodyInactive0) (bodyBr251.trans bodyBr250.symm) bodyCnt250 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12962, 200, 0, 144⟩) bodyAcc251 PRE_first_tail_x6_r0_body.bodyRunSeg68 bodyAcc253 bodyHalt253 PRE_first_tail_x6_r0_body.bodyStepA69 bodyTop254 (fun _ hm => bodyO251 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr251).trans bodyInactive0) (bodyBr254.trans bodyBr251.symm) bodyCnt251 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift25 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S254.tab.length PRE_first_tail_x6_r0_body.s254.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P25.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P25 1148 PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.s256.ffi PRE_first_tail_x6_r0_body.s255.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_25
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_25
  have hcl : SSt (· < 1148) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s256.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S254.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_25] <;> decide) PRE_first_tail_x6_r0_body.cnodesK25 PRE_first_tail_x6_r0_body.cobjsK25
      PRE_first_tail_x6_r0_body.citemsK25 PRE_first_tail_x6_r0_body.cbd25 PRE_first_tail_x6_r0_body.csst25
  exact PRE_first_tail_x6_r0_body.cshift25 bodyNcl25 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_25] at this; exact this)


kernel_rfl bodyFramesEmpty25 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s255 a).isEmpty) = true
kernel_rfl bodyJsRoots25 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s254.next) PRE_first_tail_x6_r0_body.s256.trace PRE_first_tail_x6_r0_body.s256 = true
kernel_rfl bodyJsNative25 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s256.ffi) = true
kernel_rfl bodyLow25 : (PRE_first_tail_x6_r0_body.cws25 ++ PRE_first_tail_x6_r0_body.ws25).all (Nat.ble 9) = true
kernel_rfl bodyCntM25 : countersOkB PRE_first_tail_x6_r0_body.s254 PRE_first_tail_x6_r0_body.s255 = true
kernel_rfl bodyHi25 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s256.ffi).next setupP.E = true
kernel_rfl bodyNhi25 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s256.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge25 : bridgeOf PRE_first_tail_x6_r0_body.s255.ffi = bridgeOf PRE_first_tail_x6_r0_body.s254.ffi
kernel_rfl bodyNN25 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s254.ffi).nnext PRE_first_tail_x6_r0_body.P25.NL = true
kernel_rfl bodyXn25 : Nat.ble (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s256.ffi).next = true
kernel_rfl bodyLo25 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s256.ffi).next = true
theorem bodyFacts25 : BodySiteFacts PRE_first_tail_x6_r0_body.s254 PRE_first_tail_x6_r0_body.s255 PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S254 PRE_first_tail_x6_r0_body.S255 PRE_first_tail_x6_r0_body.S256
    PRE_first_tail_x6_r0_body.ws25 PRE_first_tail_x6_r0_body.cws25 PRE_first_tail_x6_r0_body.nr25 PRE_first_tail_x6_r0_body.pl25 PRE_first_tail_x6_r0_body.cl25 2694785 1148 PRE_first_tail_x6_r0_body.kd25 PRE_first_tail_x6_r0_body.kappa25 PRE_first_tail_x6_r0_body.P25
    ⟨18704, 15792, 2694783, 1148⟩ ⟨18704, 15792, 2694783, 1148⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap25
  clean := bodyClean25
  cfix := PRE_first_tail_x6_r0_body.cfix25
  zpl := PRE_first_tail_x6_r0_body.zpl25
  zplnd := PRE_first_tail_x6_r0_body.zplnd25
  zn1 := PRE_first_tail_x6_r0_body.zn125
  zfirst := PRE_first_tail_x6_r0_body.zfirst25
  zscn := PRE_first_tail_x6_r0_body.zscn25
  zsmn := PRE_first_tail_x6_r0_body.zsmn25
  zgrow := PRE_first_tail_x6_r0_body.zgrow25
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab25
  zfresh := PRE_first_tail_x6_r0_body.zfresh25
  zcnd := PRE_first_tail_x6_r0_body.zcnd25
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi25
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt25
  zgP := PRE_first_tail_x6_r0_body.zg25_2665
  zkP := PRE_first_tail_x6_r0_body.zk25_2665
  zmP := PRE_first_tail_x6_r0_body.zm25_2665
  zgC := PRE_first_tail_x6_r0_body.zg25_2673467
  zkC := PRE_first_tail_x6_r0_body.zk25_2673467
  zmC := PRE_first_tail_x6_r0_body.zm25_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw25_2673472
  zwV := PRE_first_tail_x6_r0_body.zw25_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap25
  zclbd := PRE_first_tail_x6_r0_body.zclbd25
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap25 PRE_first_tail_x6_r0_body.stFoot25 PRE_first_tail_x6_r0_body.iso25 PRE_first_tail_x6_r0_body.zwr25
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP25
  csupp := PRE_first_tail_x6_r0_body.csupp25
  cbound := PRE_first_tail_x6_r0_body.cbound25
  zimg := PRE_first_tail_x6_r0_body.zimg25
  zctl := PRE_first_tail_x6_r0_body.zctl25
  zstack := PRE_first_tail_x6_r0_body.zstack25
  zjobs := PRE_first_tail_x6_r0_body.zjobs25
  zstores := PRE_first_tail_x6_r0_body.zstores25
  zroots := PRE_first_tail_x6_r0_body.zroots25
  znC := PRE_first_tail_x6_r0_body.znC25
  ctab := PRE_first_tail_x6_r0_body.ctab25
  zbin := PRE_first_tail_x6_r0_body.zbin25
  cbridge := PRE_first_tail_x6_r0_body.cbridge25
  sbridge := bodyBridge25
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj25
  cshiftR := fun h hNL => bodyCshift25 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN25
  raised := PRE_first_tail_x6_r0_body.raised25
  cbigs := PRE_first_tail_x6_r0_body.cbigs25
  cjcl := PRE_first_tail_x6_r0_body.cjcl25
  xnLe := Nat.le_of_ble_eq_true bodyXn25
  loLe := Nat.le_of_ble_eq_true bodyLo25
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB25
  cntM := bodyCntM25
  hiLe := Nat.le_of_ble_eq_true bodyHi25
  nhiLe := Nat.le_of_ble_eq_true bodyNhi25
  jsHeap := bodyJs25
  jsRoots := bodyJsRoots25
  jsNative := bodyJsNative25
  framesEmpty := bodyFramesEmpty25
  trailOld := by decide
  lowVars := bodyLow25

def bodyQs25 : List (Option Q) := []
noncomputable def bodyEs25 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr25.map fun r => nth? PRE_first_tail_x6_r0_body.st25.S2.tab r
kernel_rfl bodyResChk25 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs25 bodyQs25) = true
kernel_rfl bodyLq25 : bodyQs25.length = PRE_first_tail_x6_r0_body.cws25.length
kernel_rfl bodyNrLo25 : PRE_first_tail_x6_r0_body.nr25.all (Nat.ble PRE_first_tail_x6_r0_body.S254.tab.length) = true
kernel_rfl bodySub25 : (Oracles.PRE_first_tail_x6_r0_body.map_site25.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost25 : postSubB bodyM PRE_first_tail_x6_r0_body.ws25 PRE_first_tail_x6_r0_body.cws25 bodyQs25 = true
kernel_rfl bodyDrop25 : Nat.ble (12962 + (PRE_first_tail_x6_r0_body.s255.next - PRE_first_tail_x6_r0_body.s256.next)) 12964 = true
kernel_rfl bodyDropH25 : Nat.ble (200 + ((mlxOf PRE_first_tail_x6_r0_body.s255.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s256.ffi).next)) 200 = true
kernel_rfl bodyDropN25 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s255.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s256.ffi).nnext)) 0 = true
kernel_rfl bodyDv25 : bodyΘ.1.take 144 = bodyΘ.1.take 144 ++ PRE_first_tail_x6_r0_body.cws25
kernel_rfl bodyDe25 : bodyΘ.2.take 144 = bodyΘ.2.take 144 ++ PRE_first_tail_x6_r0_body.nr25.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st25.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 144) (bodyΘ.2.take 144)))
kernel_rfl bodyDl25 : (bodyΘ.1.take 144).length = (bodyΘ.2.take 144).length
kernel_rfl bodyDold25 : (bodyΘ.1.take 144).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws25).isNone && !PRE_first_tail_x6_r0_body.ws25.contains v) = true
kernel_rfl bodyDfree25 : (bodyΘ.2.take 144).all (fun e => (PRE_first_tail_x6_r0_body.cws25 ++ PRE_first_tail_x6_r0_body.ws25).all fun w => e.noVar w) = true

theorem bodyStep25 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12962, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s254 PRE_first_tail_x6_r0_body.S254)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12964, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.S256) (27 + 1) :=
  bodySite bodyFacts25.cfix bodyFacts25.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x6_r0_body.st25.S2.tab) (Es := bodyEs25) (qs := bodyQs25)
    (ok := PRE_first_tail_x6_r0_body.st25.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site25 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts25
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site25 r hr) hi (MapOk.sub hm (sub_of_all bodySub25)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk25 r hr) hi hm ho hq)
    bodyLq25 rfl bodyNrLo25 (postSub_sound bodyPost25)
    (Nat.le_of_ble_eq_true bodyDrop25) (by decide) (Nat.le_of_ble_eq_true bodyDropH25) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN25) (by decide)
    bodyDv25 bodyDe25 bodyDl25 bodyDold25 bodyDfree25 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x6_r0_body.map_site26 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site26 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site26) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site26
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s258 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s259 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S258 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws26 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso26
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_26
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot26
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup26
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound26
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace26
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged26
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws26.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st26.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S258.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_26]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen26.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh26
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl26 : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s258.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl26 (PRE_first_tail_x6_r0_body.cncl25 bodyNcl25)

theorem bodyClean26 : Conv.JClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s258 :=
  PRE_first_tail_x6_r0_body.gjcl26 (PRE_first_tail_x6_r0_body.cjcl25 bodyClean25)

kernel_rfl bodyJsLe26 : Nat.ble PRE_first_tail_x6_r0_body.s254.next PRE_first_tail_x6_r0_body.s258.next = true
kernel_rfl bodyJsList26 : (PRE_first_tail_x6_r0_body.gjh26 ++ PRE_first_tail_x6_r0_body.cl26).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s258.next) PRE_first_tail_x6_r0_body.s260) = true
theorem bodyJs26 : JsHeapAbove PRE_first_tail_x6_r0_body.s258.next PRE_first_tail_x6_r0_body.s260 :=
  JsHeapAbove.glueSite bodyJs25 (Nat.le_of_ble_eq_true bodyJsLe26) PRE_first_tail_x6_r0_body.gjk26 PRE_first_tail_x6_r0_body.gjbd26 PRE_first_tail_x6_r0_body.cheap26 PRE_first_tail_x6_r0_body.zclbd26 bodyJsList26

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO256 : PRE_first_tail_x6_r0_body.S256.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S256.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr256 : bridgeOf PRE_first_tail_x6_r0_body.s256.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc256 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.S256) = fun _ _ => true
kernel_rfl bodyAcc257 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s257 PRE_first_tail_x6_r0_body.S257) = fun _ _ => true
kernel_rfl bodyBr258 : bridgeOf PRE_first_tail_x6_r0_body.s258.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt257 : isHalt PRE_first_tail_x6_r0_body.s257.ctl = false
kernel_rfl bodyTop258 : noRetBlock PRE_first_tail_x6_r0_body.s258 = true
kernel_rfl bodyCnt256 : countersOkB PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.s258 = true

theorem bodyGlue26 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12964, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s256 PRE_first_tail_x6_r0_body.S256)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12964, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s258 PRE_first_tail_x6_r0_body.S258) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12964, 200, 0, 144⟩) bodyAcc256 PRE_first_tail_x6_r0_body.bodyRunSeg69 bodyAcc257 bodyHalt257 PRE_first_tail_x6_r0_body.bodyStepA70 bodyTop258 (fun _ hm => bodyO256 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr256).trans bodyInactive0) (bodyBr258.trans bodyBr256.symm) bodyCnt256 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift26 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S258.tab.length PRE_first_tail_x6_r0_body.s258.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P26.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P26 1165 PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.s260.ffi PRE_first_tail_x6_r0_body.s259.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_26
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_26
  have hcl : SSt (· < 1165) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s260.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S258.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_26] <;> decide) PRE_first_tail_x6_r0_body.cnodesK26 PRE_first_tail_x6_r0_body.cobjsK26
      PRE_first_tail_x6_r0_body.citemsK26 PRE_first_tail_x6_r0_body.cbd26 PRE_first_tail_x6_r0_body.csst26
  exact PRE_first_tail_x6_r0_body.cshift26 bodyNcl26 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_26] at this; exact this)


kernel_rfl bodyFramesEmpty26 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s259 a).isEmpty) = true
kernel_rfl bodyJsRoots26 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s258.next) PRE_first_tail_x6_r0_body.s260.trace PRE_first_tail_x6_r0_body.s260 = true
kernel_rfl bodyJsNative26 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s260.ffi) = true
kernel_rfl bodyLow26 : (PRE_first_tail_x6_r0_body.cws26 ++ PRE_first_tail_x6_r0_body.ws26).all (Nat.ble 9) = true
kernel_rfl bodyCntM26 : countersOkB PRE_first_tail_x6_r0_body.s258 PRE_first_tail_x6_r0_body.s259 = true
kernel_rfl bodyHi26 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s260.ffi).next setupP.E = true
kernel_rfl bodyNhi26 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s260.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge26 : bridgeOf PRE_first_tail_x6_r0_body.s259.ffi = bridgeOf PRE_first_tail_x6_r0_body.s258.ffi
kernel_rfl bodyNN26 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s258.ffi).nnext PRE_first_tail_x6_r0_body.P26.NL = true
kernel_rfl bodyXn26 : Nat.ble (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s260.ffi).next = true
kernel_rfl bodyLo26 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s260.ffi).next = true
theorem bodyFacts26 : BodySiteFacts PRE_first_tail_x6_r0_body.s258 PRE_first_tail_x6_r0_body.s259 PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S258 PRE_first_tail_x6_r0_body.S259 PRE_first_tail_x6_r0_body.S260
    PRE_first_tail_x6_r0_body.ws26 PRE_first_tail_x6_r0_body.cws26 PRE_first_tail_x6_r0_body.nr26 PRE_first_tail_x6_r0_body.pl26 PRE_first_tail_x6_r0_body.cl26 2695082 1165 PRE_first_tail_x6_r0_body.kd26 PRE_first_tail_x6_r0_body.kappa26 PRE_first_tail_x6_r0_body.P26
    ⟨18711, 15796, 2695071, 1165⟩ ⟨18711, 15796, 2695072, 1165⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap26
  clean := bodyClean26
  cfix := PRE_first_tail_x6_r0_body.cfix26
  zpl := PRE_first_tail_x6_r0_body.zpl26
  zplnd := PRE_first_tail_x6_r0_body.zplnd26
  zn1 := PRE_first_tail_x6_r0_body.zn126
  zfirst := PRE_first_tail_x6_r0_body.zfirst26
  zscn := PRE_first_tail_x6_r0_body.zscn26
  zsmn := PRE_first_tail_x6_r0_body.zsmn26
  zgrow := PRE_first_tail_x6_r0_body.zgrow26
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab26
  zfresh := PRE_first_tail_x6_r0_body.zfresh26
  zcnd := PRE_first_tail_x6_r0_body.zcnd26
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi26
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt26
  zgP := PRE_first_tail_x6_r0_body.zg26_2665
  zkP := PRE_first_tail_x6_r0_body.zk26_2665
  zmP := PRE_first_tail_x6_r0_body.zm26_2665
  zgC := PRE_first_tail_x6_r0_body.zg26_2673467
  zkC := PRE_first_tail_x6_r0_body.zk26_2673467
  zmC := PRE_first_tail_x6_r0_body.zm26_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw26_2673472
  zwV := PRE_first_tail_x6_r0_body.zw26_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap26
  zclbd := PRE_first_tail_x6_r0_body.zclbd26
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap26 PRE_first_tail_x6_r0_body.stFoot26 PRE_first_tail_x6_r0_body.iso26 PRE_first_tail_x6_r0_body.zwr26
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP26
  csupp := PRE_first_tail_x6_r0_body.csupp26
  cbound := PRE_first_tail_x6_r0_body.cbound26
  zimg := PRE_first_tail_x6_r0_body.zimg26
  zctl := PRE_first_tail_x6_r0_body.zctl26
  zstack := PRE_first_tail_x6_r0_body.zstack26
  zjobs := PRE_first_tail_x6_r0_body.zjobs26
  zstores := PRE_first_tail_x6_r0_body.zstores26
  zroots := PRE_first_tail_x6_r0_body.zroots26
  znC := PRE_first_tail_x6_r0_body.znC26
  ctab := PRE_first_tail_x6_r0_body.ctab26
  zbin := PRE_first_tail_x6_r0_body.zbin26
  cbridge := PRE_first_tail_x6_r0_body.cbridge26
  sbridge := bodyBridge26
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj26
  cshiftR := fun h hNL => bodyCshift26 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN26
  raised := PRE_first_tail_x6_r0_body.raised26
  cbigs := PRE_first_tail_x6_r0_body.cbigs26
  cjcl := PRE_first_tail_x6_r0_body.cjcl26
  xnLe := Nat.le_of_ble_eq_true bodyXn26
  loLe := Nat.le_of_ble_eq_true bodyLo26
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB26
  cntM := bodyCntM26
  hiLe := Nat.le_of_ble_eq_true bodyHi26
  nhiLe := Nat.le_of_ble_eq_true bodyNhi26
  jsHeap := bodyJs26
  jsRoots := bodyJsRoots26
  jsNative := bodyJsNative26
  framesEmpty := bodyFramesEmpty26
  trailOld := by decide
  lowVars := bodyLow26

def bodyQs26 : List (Option Q) := []
noncomputable def bodyEs26 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr26.map fun r => nth? PRE_first_tail_x6_r0_body.st26.S2.tab r
kernel_rfl bodyResChk26 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs26 bodyQs26) = true
kernel_rfl bodyLq26 : bodyQs26.length = PRE_first_tail_x6_r0_body.cws26.length
kernel_rfl bodyNrLo26 : PRE_first_tail_x6_r0_body.nr26.all (Nat.ble PRE_first_tail_x6_r0_body.S258.tab.length) = true
kernel_rfl bodySub26 : (Oracles.PRE_first_tail_x6_r0_body.map_site26.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost26 : postSubB bodyM PRE_first_tail_x6_r0_body.ws26 PRE_first_tail_x6_r0_body.cws26 bodyQs26 = true
kernel_rfl bodyDrop26 : Nat.ble (12964 + (PRE_first_tail_x6_r0_body.s259.next - PRE_first_tail_x6_r0_body.s260.next)) 12974 = true
kernel_rfl bodyDropH26 : Nat.ble (200 + ((mlxOf PRE_first_tail_x6_r0_body.s259.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s260.ffi).next)) 200 = true
kernel_rfl bodyDropN26 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s259.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s260.ffi).nnext)) 0 = true
kernel_rfl bodyDv26 : bodyΘ.1.take 144 = bodyΘ.1.take 144 ++ PRE_first_tail_x6_r0_body.cws26
kernel_rfl bodyDe26 : bodyΘ.2.take 144 = bodyΘ.2.take 144 ++ PRE_first_tail_x6_r0_body.nr26.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st26.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 144) (bodyΘ.2.take 144)))
kernel_rfl bodyDl26 : (bodyΘ.1.take 144).length = (bodyΘ.2.take 144).length
kernel_rfl bodyDold26 : (bodyΘ.1.take 144).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws26).isNone && !PRE_first_tail_x6_r0_body.ws26.contains v) = true
kernel_rfl bodyDfree26 : (bodyΘ.2.take 144).all (fun e => (PRE_first_tail_x6_r0_body.cws26 ++ PRE_first_tail_x6_r0_body.ws26).all fun w => e.noVar w) = true

theorem bodyStep26 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12964, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s258 PRE_first_tail_x6_r0_body.S258)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12974, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.S260) (98 + 1) :=
  bodySite bodyFacts26.cfix bodyFacts26.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x6_r0_body.st26.S2.tab) (Es := bodyEs26) (qs := bodyQs26)
    (ok := PRE_first_tail_x6_r0_body.st26.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site26 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts26
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site26 r hr) hi (MapOk.sub hm (sub_of_all bodySub26)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk26 r hr) hi hm ho hq)
    bodyLq26 rfl bodyNrLo26 (postSub_sound bodyPost26)
    (Nat.le_of_ble_eq_true bodyDrop26) (by decide) (Nat.le_of_ble_eq_true bodyDropH26) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN26) (by decide)
    bodyDv26 bodyDe26 bodyDl26 bodyDold26 bodyDfree26 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site27 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site27 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site27) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st27.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site27
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st27.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s275 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s276 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S275 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws27 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st27.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st27.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso27
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_27
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st27.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot27
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup27
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound27
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace27
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged27
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws27.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st27.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S275.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_27]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen27.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh27
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl27 : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s275.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl27 (PRE_first_tail_x6_r0_body.cncl26 bodyNcl26)

theorem bodyClean27 : Conv.JClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s275 :=
  PRE_first_tail_x6_r0_body.gjcl27 (PRE_first_tail_x6_r0_body.cjcl26 bodyClean26)

kernel_rfl bodyJsLe27 : Nat.ble PRE_first_tail_x6_r0_body.s258.next PRE_first_tail_x6_r0_body.s275.next = true
kernel_rfl bodyJsList27 : (PRE_first_tail_x6_r0_body.gjh27 ++ PRE_first_tail_x6_r0_body.cl27).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s275.next) PRE_first_tail_x6_r0_body.s277) = true
theorem bodyJs27 : JsHeapAbove PRE_first_tail_x6_r0_body.s275.next PRE_first_tail_x6_r0_body.s277 :=
  JsHeapAbove.glueSite bodyJs26 (Nat.le_of_ble_eq_true bodyJsLe27) PRE_first_tail_x6_r0_body.gjk27 PRE_first_tail_x6_r0_body.gjbd27 PRE_first_tail_x6_r0_body.cheap27 PRE_first_tail_x6_r0_body.zclbd27 bodyJsList27

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO260 : PRE_first_tail_x6_r0_body.S260.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S260.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr260 : bridgeOf PRE_first_tail_x6_r0_body.s260.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc260 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.S260) = fun _ _ => true
kernel_rfl bodyAcc262 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s262 PRE_first_tail_x6_r0_body.S262) = fun _ _ => true
kernel_rfl bodyBr263 : bridgeOf PRE_first_tail_x6_r0_body.s263.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt262 : isHalt PRE_first_tail_x6_r0_body.s262.ctl = false
kernel_rfl bodyTop263 : noRetBlock PRE_first_tail_x6_r0_body.s263 = true
kernel_rfl bodyCnt260 : countersOkB PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.s263 = true
kernel_rfl bodyO263 : PRE_first_tail_x6_r0_body.S263.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S263.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr264 : bridgeOf PRE_first_tail_x6_r0_body.s264.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt263 : countersOkB PRE_first_tail_x6_r0_body.s263 PRE_first_tail_x6_r0_body.s264 = true
kernel_rfl bodyO264 : PRE_first_tail_x6_r0_body.S264.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S264.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc264 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s264 PRE_first_tail_x6_r0_body.S264) = fun _ _ => true
kernel_rfl bodyAcc265 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s265 PRE_first_tail_x6_r0_body.S265) = fun _ _ => true
kernel_rfl bodyBr266 : bridgeOf PRE_first_tail_x6_r0_body.s266.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt265 : isHalt PRE_first_tail_x6_r0_body.s265.ctl = false
kernel_rfl bodyTop266 : noRetBlock PRE_first_tail_x6_r0_body.s266 = true
kernel_rfl bodyCnt264 : countersOkB PRE_first_tail_x6_r0_body.s264 PRE_first_tail_x6_r0_body.s266 = true
kernel_rfl bodyO266 : PRE_first_tail_x6_r0_body.S266.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S266.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr267 : bridgeOf PRE_first_tail_x6_r0_body.s267.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt266 : countersOkB PRE_first_tail_x6_r0_body.s266 PRE_first_tail_x6_r0_body.s267 = true
kernel_rfl bodyO267 : PRE_first_tail_x6_r0_body.S267.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S267.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc267 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s267 PRE_first_tail_x6_r0_body.S267) = fun _ _ => true
kernel_rfl bodyAcc268 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s268 PRE_first_tail_x6_r0_body.S268) = fun _ _ => true
kernel_rfl bodyBr269 : bridgeOf PRE_first_tail_x6_r0_body.s269.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt268 : isHalt PRE_first_tail_x6_r0_body.s268.ctl = false
kernel_rfl bodyTop269 : noRetBlock PRE_first_tail_x6_r0_body.s269 = true
kernel_rfl bodyCnt267 : countersOkB PRE_first_tail_x6_r0_body.s267 PRE_first_tail_x6_r0_body.s269 = true
kernel_rfl bodyO269 : PRE_first_tail_x6_r0_body.S269.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S269.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr270 : bridgeOf PRE_first_tail_x6_r0_body.s270.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt269 : countersOkB PRE_first_tail_x6_r0_body.s269 PRE_first_tail_x6_r0_body.s270 = true
kernel_rfl bodyO270 : PRE_first_tail_x6_r0_body.S270.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S270.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc270 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s270 PRE_first_tail_x6_r0_body.S270) = fun _ _ => true
kernel_rfl bodyAcc271 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s271 PRE_first_tail_x6_r0_body.S271) = fun _ _ => true
kernel_rfl bodyBr272 : bridgeOf PRE_first_tail_x6_r0_body.s272.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt271 : isHalt PRE_first_tail_x6_r0_body.s271.ctl = false
kernel_rfl bodyTop272 : noRetBlock PRE_first_tail_x6_r0_body.s272 = true
kernel_rfl bodyCnt270 : countersOkB PRE_first_tail_x6_r0_body.s270 PRE_first_tail_x6_r0_body.s272 = true
kernel_rfl bodyO272 : PRE_first_tail_x6_r0_body.S272.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S272.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr273 : bridgeOf PRE_first_tail_x6_r0_body.s273.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt272 : countersOkB PRE_first_tail_x6_r0_body.s272 PRE_first_tail_x6_r0_body.s273 = true
kernel_rfl bodyO273 : PRE_first_tail_x6_r0_body.S273.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S273.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc273 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s273 PRE_first_tail_x6_r0_body.S273) = fun _ _ => true
kernel_rfl bodyAcc274 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s274 PRE_first_tail_x6_r0_body.S274) = fun _ _ => true
kernel_rfl bodyBr275 : bridgeOf PRE_first_tail_x6_r0_body.s275.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt274 : isHalt PRE_first_tail_x6_r0_body.s274.ctl = false
kernel_rfl bodyTop275 : noRetBlock PRE_first_tail_x6_r0_body.s275 = true
kernel_rfl bodyCnt273 : countersOkB PRE_first_tail_x6_r0_body.s273 PRE_first_tail_x6_r0_body.s275 = true

theorem bodyGlue27 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12974, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s260 PRE_first_tail_x6_r0_body.S260)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12974, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s275 PRE_first_tail_x6_r0_body.S275) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc260 PRE_first_tail_x6_r0_body.bodyRunSeg70 bodyAcc262 bodyHalt262 PRE_first_tail_x6_r0_body.bodyStepA71 bodyTop263 (fun _ hm => bodyO260 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr260).trans bodyInactive0) (bodyBr263.trans bodyBr260.symm) bodyCnt260 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) PRE_first_tail_x6_r0_body.sizeA71 PRE_first_tail_x6_r0_body.sizeArgsA71 PRE_first_tail_x6_r0_body.sizeSymA71 PRE_first_tail_x6_r0_body.sizeMlxA71 PRE_first_tail_x6_r0_body.sizePayA71 PRE_first_tail_x6_r0_body.sizeTaA71 PRE_first_tail_x6_r0_body.sizeDecA71 PRE_first_tail_x6_r0_body.sizePreA71 PRE_first_tail_x6_r0_body.bodyPatchB71 (fun _ hm => bodyO263 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr263).trans bodyInactive0) (bodyBr264.trans bodyBr263.symm) bodyCnt263 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc264 PRE_first_tail_x6_r0_body.bodyRunSeg71 bodyAcc265 bodyHalt265 PRE_first_tail_x6_r0_body.bodyStepA72 bodyTop266 (fun _ hm => bodyO264 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr264).trans bodyInactive0) (bodyBr266.trans bodyBr264.symm) bodyCnt264 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) PRE_first_tail_x6_r0_body.sizeA72 PRE_first_tail_x6_r0_body.sizeArgsA72 PRE_first_tail_x6_r0_body.sizeSymA72 PRE_first_tail_x6_r0_body.sizeMlxA72 PRE_first_tail_x6_r0_body.sizePayA72 PRE_first_tail_x6_r0_body.sizeTaA72 PRE_first_tail_x6_r0_body.sizeDecA72 PRE_first_tail_x6_r0_body.sizePreA72 PRE_first_tail_x6_r0_body.bodyPatchB72 (fun _ hm => bodyO266 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr266).trans bodyInactive0) (bodyBr267.trans bodyBr266.symm) bodyCnt266 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc267 PRE_first_tail_x6_r0_body.bodyRunSeg72 bodyAcc268 bodyHalt268 PRE_first_tail_x6_r0_body.bodyStepA73 bodyTop269 (fun _ hm => bodyO267 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr267).trans bodyInactive0) (bodyBr269.trans bodyBr267.symm) bodyCnt267 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) PRE_first_tail_x6_r0_body.sizeA73 PRE_first_tail_x6_r0_body.sizeArgsA73 PRE_first_tail_x6_r0_body.sizeSymA73 PRE_first_tail_x6_r0_body.sizeMlxA73 PRE_first_tail_x6_r0_body.sizePayA73 PRE_first_tail_x6_r0_body.sizeTaA73 PRE_first_tail_x6_r0_body.sizeDecA73 PRE_first_tail_x6_r0_body.sizePreA73 PRE_first_tail_x6_r0_body.bodyPatchB73 (fun _ hm => bodyO269 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr269).trans bodyInactive0) (bodyBr270.trans bodyBr269.symm) bodyCnt269 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc270 PRE_first_tail_x6_r0_body.bodyRunSeg73 bodyAcc271 bodyHalt271 PRE_first_tail_x6_r0_body.bodyStepA74 bodyTop272 (fun _ hm => bodyO270 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr270).trans bodyInactive0) (bodyBr272.trans bodyBr270.symm) bodyCnt270 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) PRE_first_tail_x6_r0_body.sizeA74 PRE_first_tail_x6_r0_body.sizeArgsA74 PRE_first_tail_x6_r0_body.sizeSymA74 PRE_first_tail_x6_r0_body.sizeMlxA74 PRE_first_tail_x6_r0_body.sizePayA74 PRE_first_tail_x6_r0_body.sizeTaA74 PRE_first_tail_x6_r0_body.sizeDecA74 PRE_first_tail_x6_r0_body.sizePreA74 PRE_first_tail_x6_r0_body.bodyPatchB74 (fun _ hm => bodyO272 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr272).trans bodyInactive0) (bodyBr273.trans bodyBr272.symm) bodyCnt272 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc273 PRE_first_tail_x6_r0_body.bodyRunSeg74 bodyAcc274 bodyHalt274 PRE_first_tail_x6_r0_body.bodyStepA75 bodyTop275 (fun _ hm => bodyO273 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr273).trans bodyInactive0) (bodyBr275.trans bodyBr273.symm) bodyCnt273 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift27 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S275.tab.length PRE_first_tail_x6_r0_body.s275.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P27.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P27 1256 PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.s277.ffi PRE_first_tail_x6_r0_body.s276.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_27
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_27
  have hcl : SSt (· < 1256) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s277.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S275.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_27] <;> decide) PRE_first_tail_x6_r0_body.cnodesK27 PRE_first_tail_x6_r0_body.cobjsK27
      PRE_first_tail_x6_r0_body.citemsK27 PRE_first_tail_x6_r0_body.cbd27 PRE_first_tail_x6_r0_body.csst27
  exact PRE_first_tail_x6_r0_body.cshift27 bodyNcl27 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_27] at this; exact this)


kernel_rfl bodyFramesEmpty27 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s276 a).isEmpty) = true
kernel_rfl bodyJsRoots27 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s275.next) PRE_first_tail_x6_r0_body.s277.trace PRE_first_tail_x6_r0_body.s277 = true
kernel_rfl bodyJsNative27 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s277.ffi) = true
kernel_rfl bodyLow27 : (PRE_first_tail_x6_r0_body.cws27 ++ PRE_first_tail_x6_r0_body.ws27).all (Nat.ble 9) = true
kernel_rfl bodyCntM27 : countersOkB PRE_first_tail_x6_r0_body.s275 PRE_first_tail_x6_r0_body.s276 = true
kernel_rfl bodyHi27 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s277.ffi).next setupP.E = true
kernel_rfl bodyNhi27 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s277.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge27 : bridgeOf PRE_first_tail_x6_r0_body.s276.ffi = bridgeOf PRE_first_tail_x6_r0_body.s275.ffi
kernel_rfl bodyNN27 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s275.ffi).nnext PRE_first_tail_x6_r0_body.P27.NL = true
kernel_rfl bodyXn27 : Nat.ble (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s277.ffi).next = true
kernel_rfl bodyLo27 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s277.ffi).next = true
theorem bodyFacts27 : BodySiteFacts PRE_first_tail_x6_r0_body.s275 PRE_first_tail_x6_r0_body.s276 PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S275 PRE_first_tail_x6_r0_body.S276 PRE_first_tail_x6_r0_body.S277
    PRE_first_tail_x6_r0_body.ws27 PRE_first_tail_x6_r0_body.cws27 PRE_first_tail_x6_r0_body.nr27 PRE_first_tail_x6_r0_body.pl27 PRE_first_tail_x6_r0_body.cl27 2697698 1256 PRE_first_tail_x6_r0_body.kd27 PRE_first_tail_x6_r0_body.kappa27 PRE_first_tail_x6_r0_body.P27
    ⟨18745, 15815, 2696543, 1238⟩ ⟨18748, 15842, 2696549, 1256⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap27
  clean := bodyClean27
  cfix := PRE_first_tail_x6_r0_body.cfix27
  zpl := PRE_first_tail_x6_r0_body.zpl27
  zplnd := PRE_first_tail_x6_r0_body.zplnd27
  zn1 := PRE_first_tail_x6_r0_body.zn127
  zfirst := PRE_first_tail_x6_r0_body.zfirst27
  zscn := PRE_first_tail_x6_r0_body.zscn27
  zsmn := PRE_first_tail_x6_r0_body.zsmn27
  zgrow := PRE_first_tail_x6_r0_body.zgrow27
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab27
  zfresh := PRE_first_tail_x6_r0_body.zfresh27
  zcnd := PRE_first_tail_x6_r0_body.zcnd27
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi27
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt27
  zgP := PRE_first_tail_x6_r0_body.zg27_2665
  zkP := PRE_first_tail_x6_r0_body.zk27_2665
  zmP := PRE_first_tail_x6_r0_body.zm27_2665
  zgC := PRE_first_tail_x6_r0_body.zg27_2673467
  zkC := PRE_first_tail_x6_r0_body.zk27_2673467
  zmC := PRE_first_tail_x6_r0_body.zm27_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw27_2673472
  zwV := PRE_first_tail_x6_r0_body.zw27_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap27
  zclbd := PRE_first_tail_x6_r0_body.zclbd27
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap27 PRE_first_tail_x6_r0_body.stFoot27 PRE_first_tail_x6_r0_body.iso27 PRE_first_tail_x6_r0_body.zwr27
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP27
  csupp := PRE_first_tail_x6_r0_body.csupp27
  cbound := PRE_first_tail_x6_r0_body.cbound27
  zimg := PRE_first_tail_x6_r0_body.zimg27
  zctl := PRE_first_tail_x6_r0_body.zctl27
  zstack := PRE_first_tail_x6_r0_body.zstack27
  zjobs := PRE_first_tail_x6_r0_body.zjobs27
  zstores := PRE_first_tail_x6_r0_body.zstores27
  zroots := PRE_first_tail_x6_r0_body.zroots27
  znC := PRE_first_tail_x6_r0_body.znC27
  ctab := PRE_first_tail_x6_r0_body.ctab27
  zbin := PRE_first_tail_x6_r0_body.zbin27
  cbridge := PRE_first_tail_x6_r0_body.cbridge27
  sbridge := bodyBridge27
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj27
  cshiftR := fun h hNL => bodyCshift27 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN27
  raised := PRE_first_tail_x6_r0_body.raised27
  cbigs := PRE_first_tail_x6_r0_body.cbigs27
  cjcl := PRE_first_tail_x6_r0_body.cjcl27
  xnLe := Nat.le_of_ble_eq_true bodyXn27
  loLe := Nat.le_of_ble_eq_true bodyLo27
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB27
  cntM := bodyCntM27
  hiLe := Nat.le_of_ble_eq_true bodyHi27
  nhiLe := Nat.le_of_ble_eq_true bodyNhi27
  jsHeap := bodyJs27
  jsRoots := bodyJsRoots27
  jsNative := bodyJsNative27
  framesEmpty := bodyFramesEmpty27
  trailOld := by decide
  lowVars := bodyLow27

def bodyQs27 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs27 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr27.map fun r => nth? PRE_first_tail_x6_r0_body.st27.S5.tab r
kernel_rfl bodyResChk27 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs27 bodyQs27) = true
kernel_rfl bodyLq27 : bodyQs27.length = PRE_first_tail_x6_r0_body.cws27.length
kernel_rfl bodyNrLo27 : PRE_first_tail_x6_r0_body.nr27.all (Nat.ble PRE_first_tail_x6_r0_body.S275.tab.length) = true
kernel_rfl bodySub27 : (Oracles.PRE_first_tail_x6_r0_body.map_site27.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost27 : postSubB bodyM PRE_first_tail_x6_r0_body.ws27 PRE_first_tail_x6_r0_body.cws27 bodyQs27 = true
kernel_rfl bodyDrop27 : Nat.ble (12974 + (PRE_first_tail_x6_r0_body.s276.next - PRE_first_tail_x6_r0_body.s277.next)) 14123 = true
kernel_rfl bodyDropH27 : Nat.ble (200 + ((mlxOf PRE_first_tail_x6_r0_body.s276.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s277.ffi).next)) 225 = true
kernel_rfl bodyDropN27 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s276.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s277.ffi).nnext)) 0 = true
kernel_rfl bodyDv27 : bodyΘ.1.take 162 = bodyΘ.1.take 144 ++ PRE_first_tail_x6_r0_body.cws27
kernel_rfl bodyDe27 : bodyΘ.2.take 162 = bodyΘ.2.take 144 ++ PRE_first_tail_x6_r0_body.nr27.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st27.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 144) (bodyΘ.2.take 144)))
kernel_rfl bodyDl27 : (bodyΘ.1.take 144).length = (bodyΘ.2.take 144).length
kernel_rfl bodyDold27 : (bodyΘ.1.take 144).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws27).isNone && !PRE_first_tail_x6_r0_body.ws27.contains v) = true
kernel_rfl bodyDfree27 : (bodyΘ.2.take 162).all (fun e => (PRE_first_tail_x6_r0_body.cws27 ++ PRE_first_tail_x6_r0_body.ws27).all fun w => e.noVar w) = true

theorem bodyStep27 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12974, 200, 0, 144⟩ bodyM PRE_first_tail_x6_r0_body.s275 PRE_first_tail_x6_r0_body.S275)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14123, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.S277) (11334 + 1) :=
  bodySite bodyFacts27.cfix bodyFacts27.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x6_r0_body.st27.S5.tab) (Es := bodyEs27) (qs := bodyQs27)
    (ok := PRE_first_tail_x6_r0_body.st27.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site27 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts27
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site27 r hr) hi (MapOk.sub hm (sub_of_all bodySub27)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk27 r hr) hi hm ho hq)
    bodyLq27 rfl bodyNrLo27 (postSub_sound bodyPost27)
    (Nat.le_of_ble_eq_true bodyDrop27) (by decide) (Nat.le_of_ble_eq_true bodyDropH27) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN27) (by decide)
    bodyDv27 bodyDe27 bodyDl27 bodyDold27 bodyDfree27 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyOracles_7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_g28 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g28 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g28) (List.take 7 (List.drop 276 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site28 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site28 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site28) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st28.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g29 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g29 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g29) (List.take 3 (List.drop 283 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

noncomputable def PRE_first_tail_x6_r0_body.map_site29 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site29 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site29) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g30 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g30 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g30) (List.take 16 (List.drop 286 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site30 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site30 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site30) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st30.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g31 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g31 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g31) (List.take 7 (List.drop 302 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site31 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site31 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site31) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st31.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site28 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site28 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site28) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st28.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site28
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st28.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s283 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s284 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S283 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws28 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st28.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st28.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso28
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_28
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st28.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot28
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup28
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound28
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace28
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged28
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws28.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st28.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S283.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_28]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen28.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh28
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl28 : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s283.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl28 (PRE_first_tail_x6_r0_body.cncl27 bodyNcl27)

theorem bodyClean28 : Conv.JClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s283 :=
  PRE_first_tail_x6_r0_body.gjcl28 (PRE_first_tail_x6_r0_body.cjcl27 bodyClean27)

kernel_rfl bodyJsLe28 : Nat.ble PRE_first_tail_x6_r0_body.s275.next PRE_first_tail_x6_r0_body.s283.next = true
kernel_rfl bodyJsList28 : (PRE_first_tail_x6_r0_body.gjh28 ++ PRE_first_tail_x6_r0_body.cl28).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s283.next) PRE_first_tail_x6_r0_body.s285) = true
theorem bodyJs28 : JsHeapAbove PRE_first_tail_x6_r0_body.s283.next PRE_first_tail_x6_r0_body.s285 :=
  JsHeapAbove.glueSite bodyJs27 (Nat.le_of_ble_eq_true bodyJsLe28) PRE_first_tail_x6_r0_body.gjk28 PRE_first_tail_x6_r0_body.gjbd28 PRE_first_tail_x6_r0_body.cheap28 PRE_first_tail_x6_r0_body.zclbd28 bodyJsList28

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO277 : PRE_first_tail_x6_r0_body.S277.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S277.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr277 : bridgeOf PRE_first_tail_x6_r0_body.s277.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc277 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.S277) = fun _ _ => true
kernel_rfl bodyAcc278 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s278 PRE_first_tail_x6_r0_body.S278) = fun _ _ => true
kernel_rfl bodyBr279 : bridgeOf PRE_first_tail_x6_r0_body.s279.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt278 : isHalt PRE_first_tail_x6_r0_body.s278.ctl = false
kernel_rfl bodyTop279 : noRetBlock PRE_first_tail_x6_r0_body.s279 = true
kernel_rfl bodyCnt277 : countersOkB PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.s279 = true
kernel_rfl bodyO279 : PRE_first_tail_x6_r0_body.S279.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S279.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr280 : bridgeOf PRE_first_tail_x6_r0_body.s280.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt279 : countersOkB PRE_first_tail_x6_r0_body.s279 PRE_first_tail_x6_r0_body.s280 = true
kernel_rfl bodyO280 : PRE_first_tail_x6_r0_body.S280.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S280.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc280 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s280 PRE_first_tail_x6_r0_body.S280) = fun _ _ => true
kernel_rfl bodyAcc282 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s282 PRE_first_tail_x6_r0_body.S282) = fun _ _ => true
kernel_rfl bodyBr283 : bridgeOf PRE_first_tail_x6_r0_body.s283.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt282 : isHalt PRE_first_tail_x6_r0_body.s282.ctl = false
kernel_rfl bodyTop283 : noRetBlock PRE_first_tail_x6_r0_body.s283 = true
kernel_rfl bodyCnt280 : countersOkB PRE_first_tail_x6_r0_body.s280 PRE_first_tail_x6_r0_body.s283 = true

theorem bodyGlue28 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14123, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s277 PRE_first_tail_x6_r0_body.S277)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14123, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s283 PRE_first_tail_x6_r0_body.S283) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14123, 225, 0, 162⟩) bodyAcc277 PRE_first_tail_x6_r0_body.bodyRunSeg75 bodyAcc278 bodyHalt278 PRE_first_tail_x6_r0_body.bodyStepA76 bodyTop279 (fun _ hm => bodyO277 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr277).trans bodyInactive0) (bodyBr279.trans bodyBr277.symm) bodyCnt277 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14123, 225, 0, 162⟩) PRE_first_tail_x6_r0_body.sizeA76 PRE_first_tail_x6_r0_body.sizeArgsA76 PRE_first_tail_x6_r0_body.sizeSymA76 PRE_first_tail_x6_r0_body.sizeMlxA76 PRE_first_tail_x6_r0_body.sizePayA76 PRE_first_tail_x6_r0_body.sizeTaA76 PRE_first_tail_x6_r0_body.sizeDecA76 PRE_first_tail_x6_r0_body.sizePreA76 PRE_first_tail_x6_r0_body.bodyPatchB76 (fun _ hm => bodyO279 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr279).trans bodyInactive0) (bodyBr280.trans bodyBr279.symm) bodyCnt279 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14123, 225, 0, 162⟩) bodyAcc280 PRE_first_tail_x6_r0_body.bodyRunSeg76 bodyAcc282 bodyHalt282 PRE_first_tail_x6_r0_body.bodyStepA77 bodyTop283 (fun _ hm => bodyO280 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr280).trans bodyInactive0) (bodyBr283.trans bodyBr280.symm) bodyCnt280 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift28 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S283.tab.length PRE_first_tail_x6_r0_body.s283.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P28.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P28 1277 PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.s285.ffi PRE_first_tail_x6_r0_body.s284.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_28
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_28
  have hcl : SSt (· < 1277) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s285.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S283.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_28] <;> decide) PRE_first_tail_x6_r0_body.cnodesK28 PRE_first_tail_x6_r0_body.cobjsK28
      PRE_first_tail_x6_r0_body.citemsK28 PRE_first_tail_x6_r0_body.cbd28 PRE_first_tail_x6_r0_body.csst28
  exact PRE_first_tail_x6_r0_body.cshift28 bodyNcl28 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_28] at this; exact this)


kernel_rfl bodyFramesEmpty28 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s284 a).isEmpty) = true
kernel_rfl bodyJsRoots28 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s283.next) PRE_first_tail_x6_r0_body.s285.trace PRE_first_tail_x6_r0_body.s285 = true
kernel_rfl bodyJsNative28 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s285.ffi) = true
kernel_rfl bodyLow28 : (PRE_first_tail_x6_r0_body.cws28 ++ PRE_first_tail_x6_r0_body.ws28).all (Nat.ble 9) = true
kernel_rfl bodyCntM28 : countersOkB PRE_first_tail_x6_r0_body.s283 PRE_first_tail_x6_r0_body.s284 = true
kernel_rfl bodyHi28 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s285.ffi).next setupP.E = true
kernel_rfl bodyNhi28 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s285.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge28 : bridgeOf PRE_first_tail_x6_r0_body.s284.ffi = bridgeOf PRE_first_tail_x6_r0_body.s283.ffi
kernel_rfl bodyNN28 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s283.ffi).nnext PRE_first_tail_x6_r0_body.P28.NL = true
kernel_rfl bodyXn28 : Nat.ble (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s285.ffi).next = true
kernel_rfl bodyLo28 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s285.ffi).next = true
theorem bodyFacts28 : BodySiteFacts PRE_first_tail_x6_r0_body.s283 PRE_first_tail_x6_r0_body.s284 PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S283 PRE_first_tail_x6_r0_body.S284 PRE_first_tail_x6_r0_body.S285
    PRE_first_tail_x6_r0_body.ws28 PRE_first_tail_x6_r0_body.cws28 PRE_first_tail_x6_r0_body.nr28 PRE_first_tail_x6_r0_body.pl28 PRE_first_tail_x6_r0_body.cl28 2697041 1277 PRE_first_tail_x6_r0_body.kd28 PRE_first_tail_x6_r0_body.kappa28 PRE_first_tail_x6_r0_body.P28
    ⟨18761, 15855, 2697039, 1277⟩ ⟨18761, 15855, 2697039, 1277⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap28
  clean := bodyClean28
  cfix := PRE_first_tail_x6_r0_body.cfix28
  zpl := PRE_first_tail_x6_r0_body.zpl28
  zplnd := PRE_first_tail_x6_r0_body.zplnd28
  zn1 := PRE_first_tail_x6_r0_body.zn128
  zfirst := PRE_first_tail_x6_r0_body.zfirst28
  zscn := PRE_first_tail_x6_r0_body.zscn28
  zsmn := PRE_first_tail_x6_r0_body.zsmn28
  zgrow := PRE_first_tail_x6_r0_body.zgrow28
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab28
  zfresh := PRE_first_tail_x6_r0_body.zfresh28
  zcnd := PRE_first_tail_x6_r0_body.zcnd28
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi28
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt28
  zgP := PRE_first_tail_x6_r0_body.zg28_2665
  zkP := PRE_first_tail_x6_r0_body.zk28_2665
  zmP := PRE_first_tail_x6_r0_body.zm28_2665
  zgC := PRE_first_tail_x6_r0_body.zg28_2673467
  zkC := PRE_first_tail_x6_r0_body.zk28_2673467
  zmC := PRE_first_tail_x6_r0_body.zm28_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw28_2673472
  zwV := PRE_first_tail_x6_r0_body.zw28_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap28
  zclbd := PRE_first_tail_x6_r0_body.zclbd28
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap28 PRE_first_tail_x6_r0_body.stFoot28 PRE_first_tail_x6_r0_body.iso28 PRE_first_tail_x6_r0_body.zwr28
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP28
  csupp := PRE_first_tail_x6_r0_body.csupp28
  cbound := PRE_first_tail_x6_r0_body.cbound28
  zimg := PRE_first_tail_x6_r0_body.zimg28
  zctl := PRE_first_tail_x6_r0_body.zctl28
  zstack := PRE_first_tail_x6_r0_body.zstack28
  zjobs := PRE_first_tail_x6_r0_body.zjobs28
  zstores := PRE_first_tail_x6_r0_body.zstores28
  zroots := PRE_first_tail_x6_r0_body.zroots28
  znC := PRE_first_tail_x6_r0_body.znC28
  ctab := PRE_first_tail_x6_r0_body.ctab28
  zbin := PRE_first_tail_x6_r0_body.zbin28
  cbridge := PRE_first_tail_x6_r0_body.cbridge28
  sbridge := bodyBridge28
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj28
  cshiftR := fun h hNL => bodyCshift28 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN28
  raised := PRE_first_tail_x6_r0_body.raised28
  cbigs := PRE_first_tail_x6_r0_body.cbigs28
  cjcl := PRE_first_tail_x6_r0_body.cjcl28
  xnLe := Nat.le_of_ble_eq_true bodyXn28
  loLe := Nat.le_of_ble_eq_true bodyLo28
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB28
  cntM := bodyCntM28
  hiLe := Nat.le_of_ble_eq_true bodyHi28
  nhiLe := Nat.le_of_ble_eq_true bodyNhi28
  jsHeap := bodyJs28
  jsRoots := bodyJsRoots28
  jsNative := bodyJsNative28
  framesEmpty := bodyFramesEmpty28
  trailOld := by decide
  lowVars := bodyLow28

def bodyQs28 : List (Option Q) := []
noncomputable def bodyEs28 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr28.map fun r => nth? PRE_first_tail_x6_r0_body.st28.S2.tab r
kernel_rfl bodyResChk28 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs28 bodyQs28) = true
kernel_rfl bodyLq28 : bodyQs28.length = PRE_first_tail_x6_r0_body.cws28.length
kernel_rfl bodyNrLo28 : PRE_first_tail_x6_r0_body.nr28.all (Nat.ble PRE_first_tail_x6_r0_body.S283.tab.length) = true
kernel_rfl bodySub28 : (Oracles.PRE_first_tail_x6_r0_body.map_site28.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost28 : postSubB bodyM PRE_first_tail_x6_r0_body.ws28 PRE_first_tail_x6_r0_body.cws28 bodyQs28 = true
kernel_rfl bodyDrop28 : Nat.ble (14123 + (PRE_first_tail_x6_r0_body.s284.next - PRE_first_tail_x6_r0_body.s285.next)) 14125 = true
kernel_rfl bodyDropH28 : Nat.ble (225 + ((mlxOf PRE_first_tail_x6_r0_body.s284.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s285.ffi).next)) 225 = true
kernel_rfl bodyDropN28 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s284.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s285.ffi).nnext)) 0 = true
kernel_rfl bodyDv28 : bodyΘ.1.take 162 = bodyΘ.1.take 162 ++ PRE_first_tail_x6_r0_body.cws28
kernel_rfl bodyDe28 : bodyΘ.2.take 162 = bodyΘ.2.take 162 ++ PRE_first_tail_x6_r0_body.nr28.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st28.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 162) (bodyΘ.2.take 162)))
kernel_rfl bodyDl28 : (bodyΘ.1.take 162).length = (bodyΘ.2.take 162).length
kernel_rfl bodyDold28 : (bodyΘ.1.take 162).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws28).isNone && !PRE_first_tail_x6_r0_body.ws28.contains v) = true
kernel_rfl bodyDfree28 : (bodyΘ.2.take 162).all (fun e => (PRE_first_tail_x6_r0_body.cws28 ++ PRE_first_tail_x6_r0_body.ws28).all fun w => e.noVar w) = true

theorem bodyStep28 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14123, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s283 PRE_first_tail_x6_r0_body.S283)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14125, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.S285) (27 + 1) :=
  bodySite bodyFacts28.cfix bodyFacts28.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x6_r0_body.st28.S2.tab) (Es := bodyEs28) (qs := bodyQs28)
    (ok := PRE_first_tail_x6_r0_body.st28.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site28 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts28
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site28 r hr) hi (MapOk.sub hm (sub_of_all bodySub28)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk28 r hr) hi hm ho hq)
    bodyLq28 rfl bodyNrLo28 (postSub_sound bodyPost28)
    (Nat.le_of_ble_eq_true bodyDrop28) (by decide) (Nat.le_of_ble_eq_true bodyDropH28) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN28) (by decide)
    bodyDv28 bodyDe28 bodyDl28 bodyDold28 bodyDfree28 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x6_r0_body.map_site29 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site29 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site29) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site29
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s287 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s288 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S287 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws29 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso29
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_29
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot29
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup29
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound29
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace29
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged29
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws29.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st29.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S287.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_29]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen29.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh29
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl29 : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s287.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl29 (PRE_first_tail_x6_r0_body.cncl28 bodyNcl28)

theorem bodyClean29 : Conv.JClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s287 :=
  PRE_first_tail_x6_r0_body.gjcl29 (PRE_first_tail_x6_r0_body.cjcl28 bodyClean28)

kernel_rfl bodyJsLe29 : Nat.ble PRE_first_tail_x6_r0_body.s283.next PRE_first_tail_x6_r0_body.s287.next = true
kernel_rfl bodyJsList29 : (PRE_first_tail_x6_r0_body.gjh29 ++ PRE_first_tail_x6_r0_body.cl29).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s287.next) PRE_first_tail_x6_r0_body.s289) = true
theorem bodyJs29 : JsHeapAbove PRE_first_tail_x6_r0_body.s287.next PRE_first_tail_x6_r0_body.s289 :=
  JsHeapAbove.glueSite bodyJs28 (Nat.le_of_ble_eq_true bodyJsLe29) PRE_first_tail_x6_r0_body.gjk29 PRE_first_tail_x6_r0_body.gjbd29 PRE_first_tail_x6_r0_body.cheap29 PRE_first_tail_x6_r0_body.zclbd29 bodyJsList29

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO285 : PRE_first_tail_x6_r0_body.S285.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S285.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr285 : bridgeOf PRE_first_tail_x6_r0_body.s285.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc285 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.S285) = fun _ _ => true
kernel_rfl bodyAcc286 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s286 PRE_first_tail_x6_r0_body.S286) = fun _ _ => true
kernel_rfl bodyBr287 : bridgeOf PRE_first_tail_x6_r0_body.s287.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt286 : isHalt PRE_first_tail_x6_r0_body.s286.ctl = false
kernel_rfl bodyTop287 : noRetBlock PRE_first_tail_x6_r0_body.s287 = true
kernel_rfl bodyCnt285 : countersOkB PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.s287 = true

theorem bodyGlue29 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14125, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s285 PRE_first_tail_x6_r0_body.S285)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14125, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s287 PRE_first_tail_x6_r0_body.S287) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14125, 225, 0, 162⟩) bodyAcc285 PRE_first_tail_x6_r0_body.bodyRunSeg77 bodyAcc286 bodyHalt286 PRE_first_tail_x6_r0_body.bodyStepA78 bodyTop287 (fun _ hm => bodyO285 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr285).trans bodyInactive0) (bodyBr287.trans bodyBr285.symm) bodyCnt285 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift29 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S287.tab.length PRE_first_tail_x6_r0_body.s287.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P29.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P29 1294 PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.s289.ffi PRE_first_tail_x6_r0_body.s288.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_29
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_29
  have hcl : SSt (· < 1294) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s289.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S287.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_29] <;> decide) PRE_first_tail_x6_r0_body.cnodesK29 PRE_first_tail_x6_r0_body.cobjsK29
      PRE_first_tail_x6_r0_body.citemsK29 PRE_first_tail_x6_r0_body.cbd29 PRE_first_tail_x6_r0_body.csst29
  exact PRE_first_tail_x6_r0_body.cshift29 bodyNcl29 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_29] at this; exact this)


kernel_rfl bodyFramesEmpty29 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s288 a).isEmpty) = true
kernel_rfl bodyJsRoots29 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s287.next) PRE_first_tail_x6_r0_body.s289.trace PRE_first_tail_x6_r0_body.s289 = true
kernel_rfl bodyJsNative29 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s289.ffi) = true
kernel_rfl bodyLow29 : (PRE_first_tail_x6_r0_body.cws29 ++ PRE_first_tail_x6_r0_body.ws29).all (Nat.ble 9) = true
kernel_rfl bodyCntM29 : countersOkB PRE_first_tail_x6_r0_body.s287 PRE_first_tail_x6_r0_body.s288 = true
kernel_rfl bodyHi29 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s289.ffi).next setupP.E = true
kernel_rfl bodyNhi29 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s289.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge29 : bridgeOf PRE_first_tail_x6_r0_body.s288.ffi = bridgeOf PRE_first_tail_x6_r0_body.s287.ffi
kernel_rfl bodyNN29 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s287.ffi).nnext PRE_first_tail_x6_r0_body.P29.NL = true
kernel_rfl bodyXn29 : Nat.ble (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s289.ffi).next = true
kernel_rfl bodyLo29 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s289.ffi).next = true
theorem bodyFacts29 : BodySiteFacts PRE_first_tail_x6_r0_body.s287 PRE_first_tail_x6_r0_body.s288 PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S287 PRE_first_tail_x6_r0_body.S288 PRE_first_tail_x6_r0_body.S289
    PRE_first_tail_x6_r0_body.ws29 PRE_first_tail_x6_r0_body.cws29 PRE_first_tail_x6_r0_body.nr29 PRE_first_tail_x6_r0_body.pl29 PRE_first_tail_x6_r0_body.cl29 2697338 1294 PRE_first_tail_x6_r0_body.kd29 PRE_first_tail_x6_r0_body.kappa29 PRE_first_tail_x6_r0_body.P29
    ⟨18768, 15859, 2697327, 1294⟩ ⟨18768, 15859, 2697328, 1294⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap29
  clean := bodyClean29
  cfix := PRE_first_tail_x6_r0_body.cfix29
  zpl := PRE_first_tail_x6_r0_body.zpl29
  zplnd := PRE_first_tail_x6_r0_body.zplnd29
  zn1 := PRE_first_tail_x6_r0_body.zn129
  zfirst := PRE_first_tail_x6_r0_body.zfirst29
  zscn := PRE_first_tail_x6_r0_body.zscn29
  zsmn := PRE_first_tail_x6_r0_body.zsmn29
  zgrow := PRE_first_tail_x6_r0_body.zgrow29
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab29
  zfresh := PRE_first_tail_x6_r0_body.zfresh29
  zcnd := PRE_first_tail_x6_r0_body.zcnd29
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi29
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt29
  zgP := PRE_first_tail_x6_r0_body.zg29_2665
  zkP := PRE_first_tail_x6_r0_body.zk29_2665
  zmP := PRE_first_tail_x6_r0_body.zm29_2665
  zgC := PRE_first_tail_x6_r0_body.zg29_2673467
  zkC := PRE_first_tail_x6_r0_body.zk29_2673467
  zmC := PRE_first_tail_x6_r0_body.zm29_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw29_2673472
  zwV := PRE_first_tail_x6_r0_body.zw29_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap29
  zclbd := PRE_first_tail_x6_r0_body.zclbd29
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap29 PRE_first_tail_x6_r0_body.stFoot29 PRE_first_tail_x6_r0_body.iso29 PRE_first_tail_x6_r0_body.zwr29
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP29
  csupp := PRE_first_tail_x6_r0_body.csupp29
  cbound := PRE_first_tail_x6_r0_body.cbound29
  zimg := PRE_first_tail_x6_r0_body.zimg29
  zctl := PRE_first_tail_x6_r0_body.zctl29
  zstack := PRE_first_tail_x6_r0_body.zstack29
  zjobs := PRE_first_tail_x6_r0_body.zjobs29
  zstores := PRE_first_tail_x6_r0_body.zstores29
  zroots := PRE_first_tail_x6_r0_body.zroots29
  znC := PRE_first_tail_x6_r0_body.znC29
  ctab := PRE_first_tail_x6_r0_body.ctab29
  zbin := PRE_first_tail_x6_r0_body.zbin29
  cbridge := PRE_first_tail_x6_r0_body.cbridge29
  sbridge := bodyBridge29
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj29
  cshiftR := fun h hNL => bodyCshift29 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN29
  raised := PRE_first_tail_x6_r0_body.raised29
  cbigs := PRE_first_tail_x6_r0_body.cbigs29
  cjcl := PRE_first_tail_x6_r0_body.cjcl29
  xnLe := Nat.le_of_ble_eq_true bodyXn29
  loLe := Nat.le_of_ble_eq_true bodyLo29
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB29
  cntM := bodyCntM29
  hiLe := Nat.le_of_ble_eq_true bodyHi29
  nhiLe := Nat.le_of_ble_eq_true bodyNhi29
  jsHeap := bodyJs29
  jsRoots := bodyJsRoots29
  jsNative := bodyJsNative29
  framesEmpty := bodyFramesEmpty29
  trailOld := by decide
  lowVars := bodyLow29

def bodyQs29 : List (Option Q) := []
noncomputable def bodyEs29 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr29.map fun r => nth? PRE_first_tail_x6_r0_body.st29.S2.tab r
kernel_rfl bodyResChk29 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs29 bodyQs29) = true
kernel_rfl bodyLq29 : bodyQs29.length = PRE_first_tail_x6_r0_body.cws29.length
kernel_rfl bodyNrLo29 : PRE_first_tail_x6_r0_body.nr29.all (Nat.ble PRE_first_tail_x6_r0_body.S287.tab.length) = true
kernel_rfl bodySub29 : (Oracles.PRE_first_tail_x6_r0_body.map_site29.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost29 : postSubB bodyM PRE_first_tail_x6_r0_body.ws29 PRE_first_tail_x6_r0_body.cws29 bodyQs29 = true
kernel_rfl bodyDrop29 : Nat.ble (14125 + (PRE_first_tail_x6_r0_body.s288.next - PRE_first_tail_x6_r0_body.s289.next)) 14135 = true
kernel_rfl bodyDropH29 : Nat.ble (225 + ((mlxOf PRE_first_tail_x6_r0_body.s288.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s289.ffi).next)) 225 = true
kernel_rfl bodyDropN29 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s288.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s289.ffi).nnext)) 0 = true
kernel_rfl bodyDv29 : bodyΘ.1.take 162 = bodyΘ.1.take 162 ++ PRE_first_tail_x6_r0_body.cws29
kernel_rfl bodyDe29 : bodyΘ.2.take 162 = bodyΘ.2.take 162 ++ PRE_first_tail_x6_r0_body.nr29.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st29.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 162) (bodyΘ.2.take 162)))
kernel_rfl bodyDl29 : (bodyΘ.1.take 162).length = (bodyΘ.2.take 162).length
kernel_rfl bodyDold29 : (bodyΘ.1.take 162).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws29).isNone && !PRE_first_tail_x6_r0_body.ws29.contains v) = true
kernel_rfl bodyDfree29 : (bodyΘ.2.take 162).all (fun e => (PRE_first_tail_x6_r0_body.cws29 ++ PRE_first_tail_x6_r0_body.ws29).all fun w => e.noVar w) = true

theorem bodyStep29 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14125, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s287 PRE_first_tail_x6_r0_body.S287)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14135, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.S289) (98 + 1) :=
  bodySite bodyFacts29.cfix bodyFacts29.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x6_r0_body.st29.S2.tab) (Es := bodyEs29) (qs := bodyQs29)
    (ok := PRE_first_tail_x6_r0_body.st29.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site29 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts29
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site29 r hr) hi (MapOk.sub hm (sub_of_all bodySub29)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk29 r hr) hi hm ho hq)
    bodyLq29 rfl bodyNrLo29 (postSub_sound bodyPost29)
    (Nat.le_of_ble_eq_true bodyDrop29) (by decide) (Nat.le_of_ble_eq_true bodyDropH29) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN29) (by decide)
    bodyDv29 bodyDe29 bodyDl29 bodyDold29 bodyDfree29 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site30 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site30 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site30) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st30.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site30
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st30.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s304 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s305 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S304 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws30 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st30.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st30.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso30
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_30
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st30.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot30
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup30
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound30
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace30
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged30
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws30.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st30.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S304.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_30]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen30.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh30
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl30 : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s304.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl30 (PRE_first_tail_x6_r0_body.cncl29 bodyNcl29)

theorem bodyClean30 : Conv.JClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s304 :=
  PRE_first_tail_x6_r0_body.gjcl30 (PRE_first_tail_x6_r0_body.cjcl29 bodyClean29)

kernel_rfl bodyJsLe30 : Nat.ble PRE_first_tail_x6_r0_body.s287.next PRE_first_tail_x6_r0_body.s304.next = true
kernel_rfl bodyJsList30 : (PRE_first_tail_x6_r0_body.gjh30 ++ PRE_first_tail_x6_r0_body.cl30).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s304.next) PRE_first_tail_x6_r0_body.s306) = true
theorem bodyJs30 : JsHeapAbove PRE_first_tail_x6_r0_body.s304.next PRE_first_tail_x6_r0_body.s306 :=
  JsHeapAbove.glueSite bodyJs29 (Nat.le_of_ble_eq_true bodyJsLe30) PRE_first_tail_x6_r0_body.gjk30 PRE_first_tail_x6_r0_body.gjbd30 PRE_first_tail_x6_r0_body.cheap30 PRE_first_tail_x6_r0_body.zclbd30 bodyJsList30

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO289 : PRE_first_tail_x6_r0_body.S289.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S289.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr289 : bridgeOf PRE_first_tail_x6_r0_body.s289.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc289 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.S289) = fun _ _ => true
kernel_rfl bodyAcc291 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s291 PRE_first_tail_x6_r0_body.S291) = fun _ _ => true
kernel_rfl bodyBr292 : bridgeOf PRE_first_tail_x6_r0_body.s292.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt291 : isHalt PRE_first_tail_x6_r0_body.s291.ctl = false
kernel_rfl bodyTop292 : noRetBlock PRE_first_tail_x6_r0_body.s292 = true
kernel_rfl bodyCnt289 : countersOkB PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.s292 = true
kernel_rfl bodyO292 : PRE_first_tail_x6_r0_body.S292.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S292.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr293 : bridgeOf PRE_first_tail_x6_r0_body.s293.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt292 : countersOkB PRE_first_tail_x6_r0_body.s292 PRE_first_tail_x6_r0_body.s293 = true
kernel_rfl bodyO293 : PRE_first_tail_x6_r0_body.S293.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S293.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc293 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s293 PRE_first_tail_x6_r0_body.S293) = fun _ _ => true
kernel_rfl bodyAcc294 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s294 PRE_first_tail_x6_r0_body.S294) = fun _ _ => true
kernel_rfl bodyBr295 : bridgeOf PRE_first_tail_x6_r0_body.s295.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt294 : isHalt PRE_first_tail_x6_r0_body.s294.ctl = false
kernel_rfl bodyTop295 : noRetBlock PRE_first_tail_x6_r0_body.s295 = true
kernel_rfl bodyCnt293 : countersOkB PRE_first_tail_x6_r0_body.s293 PRE_first_tail_x6_r0_body.s295 = true
kernel_rfl bodyO295 : PRE_first_tail_x6_r0_body.S295.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S295.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr296 : bridgeOf PRE_first_tail_x6_r0_body.s296.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt295 : countersOkB PRE_first_tail_x6_r0_body.s295 PRE_first_tail_x6_r0_body.s296 = true
kernel_rfl bodyO296 : PRE_first_tail_x6_r0_body.S296.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S296.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc296 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s296 PRE_first_tail_x6_r0_body.S296) = fun _ _ => true
kernel_rfl bodyAcc297 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s297 PRE_first_tail_x6_r0_body.S297) = fun _ _ => true
kernel_rfl bodyBr298 : bridgeOf PRE_first_tail_x6_r0_body.s298.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt297 : isHalt PRE_first_tail_x6_r0_body.s297.ctl = false
kernel_rfl bodyTop298 : noRetBlock PRE_first_tail_x6_r0_body.s298 = true
kernel_rfl bodyCnt296 : countersOkB PRE_first_tail_x6_r0_body.s296 PRE_first_tail_x6_r0_body.s298 = true
kernel_rfl bodyO298 : PRE_first_tail_x6_r0_body.S298.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S298.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr299 : bridgeOf PRE_first_tail_x6_r0_body.s299.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt298 : countersOkB PRE_first_tail_x6_r0_body.s298 PRE_first_tail_x6_r0_body.s299 = true
kernel_rfl bodyO299 : PRE_first_tail_x6_r0_body.S299.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S299.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc299 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s299 PRE_first_tail_x6_r0_body.S299) = fun _ _ => true
kernel_rfl bodyAcc300 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s300 PRE_first_tail_x6_r0_body.S300) = fun _ _ => true
kernel_rfl bodyBr301 : bridgeOf PRE_first_tail_x6_r0_body.s301.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt300 : isHalt PRE_first_tail_x6_r0_body.s300.ctl = false
kernel_rfl bodyTop301 : noRetBlock PRE_first_tail_x6_r0_body.s301 = true
kernel_rfl bodyCnt299 : countersOkB PRE_first_tail_x6_r0_body.s299 PRE_first_tail_x6_r0_body.s301 = true
kernel_rfl bodyO301 : PRE_first_tail_x6_r0_body.S301.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S301.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr302 : bridgeOf PRE_first_tail_x6_r0_body.s302.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt301 : countersOkB PRE_first_tail_x6_r0_body.s301 PRE_first_tail_x6_r0_body.s302 = true
kernel_rfl bodyO302 : PRE_first_tail_x6_r0_body.S302.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S302.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc302 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s302 PRE_first_tail_x6_r0_body.S302) = fun _ _ => true
kernel_rfl bodyAcc303 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s303 PRE_first_tail_x6_r0_body.S303) = fun _ _ => true
kernel_rfl bodyBr304 : bridgeOf PRE_first_tail_x6_r0_body.s304.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt303 : isHalt PRE_first_tail_x6_r0_body.s303.ctl = false
kernel_rfl bodyTop304 : noRetBlock PRE_first_tail_x6_r0_body.s304 = true
kernel_rfl bodyCnt302 : countersOkB PRE_first_tail_x6_r0_body.s302 PRE_first_tail_x6_r0_body.s304 = true

theorem bodyGlue30 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14135, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s289 PRE_first_tail_x6_r0_body.S289)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14135, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s304 PRE_first_tail_x6_r0_body.S304) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc289 PRE_first_tail_x6_r0_body.bodyRunSeg78 bodyAcc291 bodyHalt291 PRE_first_tail_x6_r0_body.bodyStepA79 bodyTop292 (fun _ hm => bodyO289 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr289).trans bodyInactive0) (bodyBr292.trans bodyBr289.symm) bodyCnt289 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) PRE_first_tail_x6_r0_body.sizeA79 PRE_first_tail_x6_r0_body.sizeArgsA79 PRE_first_tail_x6_r0_body.sizeSymA79 PRE_first_tail_x6_r0_body.sizeMlxA79 PRE_first_tail_x6_r0_body.sizePayA79 PRE_first_tail_x6_r0_body.sizeTaA79 PRE_first_tail_x6_r0_body.sizeDecA79 PRE_first_tail_x6_r0_body.sizePreA79 PRE_first_tail_x6_r0_body.bodyPatchB79 (fun _ hm => bodyO292 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr292).trans bodyInactive0) (bodyBr293.trans bodyBr292.symm) bodyCnt292 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc293 PRE_first_tail_x6_r0_body.bodyRunSeg79 bodyAcc294 bodyHalt294 PRE_first_tail_x6_r0_body.bodyStepA80 bodyTop295 (fun _ hm => bodyO293 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr293).trans bodyInactive0) (bodyBr295.trans bodyBr293.symm) bodyCnt293 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) PRE_first_tail_x6_r0_body.sizeA80 PRE_first_tail_x6_r0_body.sizeArgsA80 PRE_first_tail_x6_r0_body.sizeSymA80 PRE_first_tail_x6_r0_body.sizeMlxA80 PRE_first_tail_x6_r0_body.sizePayA80 PRE_first_tail_x6_r0_body.sizeTaA80 PRE_first_tail_x6_r0_body.sizeDecA80 PRE_first_tail_x6_r0_body.sizePreA80 PRE_first_tail_x6_r0_body.bodyPatchB80 (fun _ hm => bodyO295 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr295).trans bodyInactive0) (bodyBr296.trans bodyBr295.symm) bodyCnt295 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc296 PRE_first_tail_x6_r0_body.bodyRunSeg80 bodyAcc297 bodyHalt297 PRE_first_tail_x6_r0_body.bodyStepA81 bodyTop298 (fun _ hm => bodyO296 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr296).trans bodyInactive0) (bodyBr298.trans bodyBr296.symm) bodyCnt296 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) PRE_first_tail_x6_r0_body.sizeA81 PRE_first_tail_x6_r0_body.sizeArgsA81 PRE_first_tail_x6_r0_body.sizeSymA81 PRE_first_tail_x6_r0_body.sizeMlxA81 PRE_first_tail_x6_r0_body.sizePayA81 PRE_first_tail_x6_r0_body.sizeTaA81 PRE_first_tail_x6_r0_body.sizeDecA81 PRE_first_tail_x6_r0_body.sizePreA81 PRE_first_tail_x6_r0_body.bodyPatchB81 (fun _ hm => bodyO298 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr298).trans bodyInactive0) (bodyBr299.trans bodyBr298.symm) bodyCnt298 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc299 PRE_first_tail_x6_r0_body.bodyRunSeg81 bodyAcc300 bodyHalt300 PRE_first_tail_x6_r0_body.bodyStepA82 bodyTop301 (fun _ hm => bodyO299 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr299).trans bodyInactive0) (bodyBr301.trans bodyBr299.symm) bodyCnt299 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) PRE_first_tail_x6_r0_body.sizeA82 PRE_first_tail_x6_r0_body.sizeArgsA82 PRE_first_tail_x6_r0_body.sizeSymA82 PRE_first_tail_x6_r0_body.sizeMlxA82 PRE_first_tail_x6_r0_body.sizePayA82 PRE_first_tail_x6_r0_body.sizeTaA82 PRE_first_tail_x6_r0_body.sizeDecA82 PRE_first_tail_x6_r0_body.sizePreA82 PRE_first_tail_x6_r0_body.bodyPatchB82 (fun _ hm => bodyO301 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr301).trans bodyInactive0) (bodyBr302.trans bodyBr301.symm) bodyCnt301 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc302 PRE_first_tail_x6_r0_body.bodyRunSeg82 bodyAcc303 bodyHalt303 PRE_first_tail_x6_r0_body.bodyStepA83 bodyTop304 (fun _ hm => bodyO302 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr302).trans bodyInactive0) (bodyBr304.trans bodyBr302.symm) bodyCnt302 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift30 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S304.tab.length PRE_first_tail_x6_r0_body.s304.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P30.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P30 1385 PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.s306.ffi PRE_first_tail_x6_r0_body.s305.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_30
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_30
  have hcl : SSt (· < 1385) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s306.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S304.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_30] <;> decide) PRE_first_tail_x6_r0_body.cnodesK30 PRE_first_tail_x6_r0_body.cobjsK30
      PRE_first_tail_x6_r0_body.citemsK30 PRE_first_tail_x6_r0_body.cbd30 PRE_first_tail_x6_r0_body.csst30
  exact PRE_first_tail_x6_r0_body.cshift30 bodyNcl30 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_30] at this; exact this)


kernel_rfl bodyFramesEmpty30 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s305 a).isEmpty) = true
kernel_rfl bodyJsRoots30 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s304.next) PRE_first_tail_x6_r0_body.s306.trace PRE_first_tail_x6_r0_body.s306 = true
kernel_rfl bodyJsNative30 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s306.ffi) = true
kernel_rfl bodyLow30 : (PRE_first_tail_x6_r0_body.cws30 ++ PRE_first_tail_x6_r0_body.ws30).all (Nat.ble 9) = true
kernel_rfl bodyCntM30 : countersOkB PRE_first_tail_x6_r0_body.s304 PRE_first_tail_x6_r0_body.s305 = true
kernel_rfl bodyHi30 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s306.ffi).next setupP.E = true
kernel_rfl bodyNhi30 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s306.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge30 : bridgeOf PRE_first_tail_x6_r0_body.s305.ffi = bridgeOf PRE_first_tail_x6_r0_body.s304.ffi
kernel_rfl bodyNN30 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s304.ffi).nnext PRE_first_tail_x6_r0_body.P30.NL = true
kernel_rfl bodyXn30 : Nat.ble (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s306.ffi).next = true
kernel_rfl bodyLo30 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s306.ffi).next = true
theorem bodyFacts30 : BodySiteFacts PRE_first_tail_x6_r0_body.s304 PRE_first_tail_x6_r0_body.s305 PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S304 PRE_first_tail_x6_r0_body.S305 PRE_first_tail_x6_r0_body.S306
    PRE_first_tail_x6_r0_body.ws30 PRE_first_tail_x6_r0_body.cws30 PRE_first_tail_x6_r0_body.nr30 PRE_first_tail_x6_r0_body.pl30 PRE_first_tail_x6_r0_body.cl30 2699954 1385 PRE_first_tail_x6_r0_body.kd30 PRE_first_tail_x6_r0_body.kappa30 PRE_first_tail_x6_r0_body.P30
    ⟨18802, 15878, 2698799, 1367⟩ ⟨18805, 15905, 2698805, 1385⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap30
  clean := bodyClean30
  cfix := PRE_first_tail_x6_r0_body.cfix30
  zpl := PRE_first_tail_x6_r0_body.zpl30
  zplnd := PRE_first_tail_x6_r0_body.zplnd30
  zn1 := PRE_first_tail_x6_r0_body.zn130
  zfirst := PRE_first_tail_x6_r0_body.zfirst30
  zscn := PRE_first_tail_x6_r0_body.zscn30
  zsmn := PRE_first_tail_x6_r0_body.zsmn30
  zgrow := PRE_first_tail_x6_r0_body.zgrow30
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab30
  zfresh := PRE_first_tail_x6_r0_body.zfresh30
  zcnd := PRE_first_tail_x6_r0_body.zcnd30
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi30
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt30
  zgP := PRE_first_tail_x6_r0_body.zg30_2665
  zkP := PRE_first_tail_x6_r0_body.zk30_2665
  zmP := PRE_first_tail_x6_r0_body.zm30_2665
  zgC := PRE_first_tail_x6_r0_body.zg30_2673467
  zkC := PRE_first_tail_x6_r0_body.zk30_2673467
  zmC := PRE_first_tail_x6_r0_body.zm30_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw30_2673472
  zwV := PRE_first_tail_x6_r0_body.zw30_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap30
  zclbd := PRE_first_tail_x6_r0_body.zclbd30
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap30 PRE_first_tail_x6_r0_body.stFoot30 PRE_first_tail_x6_r0_body.iso30 PRE_first_tail_x6_r0_body.zwr30
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP30
  csupp := PRE_first_tail_x6_r0_body.csupp30
  cbound := PRE_first_tail_x6_r0_body.cbound30
  zimg := PRE_first_tail_x6_r0_body.zimg30
  zctl := PRE_first_tail_x6_r0_body.zctl30
  zstack := PRE_first_tail_x6_r0_body.zstack30
  zjobs := PRE_first_tail_x6_r0_body.zjobs30
  zstores := PRE_first_tail_x6_r0_body.zstores30
  zroots := PRE_first_tail_x6_r0_body.zroots30
  znC := PRE_first_tail_x6_r0_body.znC30
  ctab := PRE_first_tail_x6_r0_body.ctab30
  zbin := PRE_first_tail_x6_r0_body.zbin30
  cbridge := PRE_first_tail_x6_r0_body.cbridge30
  sbridge := bodyBridge30
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj30
  cshiftR := fun h hNL => bodyCshift30 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN30
  raised := PRE_first_tail_x6_r0_body.raised30
  cbigs := PRE_first_tail_x6_r0_body.cbigs30
  cjcl := PRE_first_tail_x6_r0_body.cjcl30
  xnLe := Nat.le_of_ble_eq_true bodyXn30
  loLe := Nat.le_of_ble_eq_true bodyLo30
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB30
  cntM := bodyCntM30
  hiLe := Nat.le_of_ble_eq_true bodyHi30
  nhiLe := Nat.le_of_ble_eq_true bodyNhi30
  jsHeap := bodyJs30
  jsRoots := bodyJsRoots30
  jsNative := bodyJsNative30
  framesEmpty := bodyFramesEmpty30
  trailOld := by decide
  lowVars := bodyLow30

def bodyQs30 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs30 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr30.map fun r => nth? PRE_first_tail_x6_r0_body.st30.S5.tab r
kernel_rfl bodyResChk30 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs30 bodyQs30) = true
kernel_rfl bodyLq30 : bodyQs30.length = PRE_first_tail_x6_r0_body.cws30.length
kernel_rfl bodyNrLo30 : PRE_first_tail_x6_r0_body.nr30.all (Nat.ble PRE_first_tail_x6_r0_body.S304.tab.length) = true
kernel_rfl bodySub30 : (Oracles.PRE_first_tail_x6_r0_body.map_site30.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost30 : postSubB bodyM PRE_first_tail_x6_r0_body.ws30 PRE_first_tail_x6_r0_body.cws30 bodyQs30 = true
kernel_rfl bodyDrop30 : Nat.ble (14135 + (PRE_first_tail_x6_r0_body.s305.next - PRE_first_tail_x6_r0_body.s306.next)) 15284 = true
kernel_rfl bodyDropH30 : Nat.ble (225 + ((mlxOf PRE_first_tail_x6_r0_body.s305.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s306.ffi).next)) 250 = true
kernel_rfl bodyDropN30 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s305.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s306.ffi).nnext)) 0 = true
kernel_rfl bodyDv30 : bodyΘ.1.take 180 = bodyΘ.1.take 162 ++ PRE_first_tail_x6_r0_body.cws30
kernel_rfl bodyDe30 : bodyΘ.2.take 180 = bodyΘ.2.take 162 ++ PRE_first_tail_x6_r0_body.nr30.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st30.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 162) (bodyΘ.2.take 162)))
kernel_rfl bodyDl30 : (bodyΘ.1.take 162).length = (bodyΘ.2.take 162).length
kernel_rfl bodyDold30 : (bodyΘ.1.take 162).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws30).isNone && !PRE_first_tail_x6_r0_body.ws30.contains v) = true
kernel_rfl bodyDfree30 : (bodyΘ.2.take 180).all (fun e => (PRE_first_tail_x6_r0_body.cws30 ++ PRE_first_tail_x6_r0_body.ws30).all fun w => e.noVar w) = true

theorem bodyStep30 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14135, 225, 0, 162⟩ bodyM PRE_first_tail_x6_r0_body.s304 PRE_first_tail_x6_r0_body.S304)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15284, 250, 0, 180⟩ bodyM PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.S306) (11334 + 1) :=
  bodySite bodyFacts30.cfix bodyFacts30.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x6_r0_body.st30.S5.tab) (Es := bodyEs30) (qs := bodyQs30)
    (ok := PRE_first_tail_x6_r0_body.st30.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site30 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts30
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site30 r hr) hi (MapOk.sub hm (sub_of_all bodySub30)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk30 r hr) hi hm ho hq)
    bodyLq30 rfl bodyNrLo30 (postSub_sound bodyPost30)
    (Nat.le_of_ble_eq_true bodyDrop30) (by decide) (Nat.le_of_ble_eq_true bodyDropH30) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN30) (by decide)
    bodyDv30 bodyDe30 bodyDl30 bodyDold30 bodyDfree30 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site31 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site31 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site31) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st31.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site31
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st31.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s312 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s313 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S312 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws31 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st31.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st31.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso31
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_31
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st31.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot31
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup31
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound31
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace31
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged31
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws31.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st31.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S312.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_31]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen31.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh31
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl31 : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s312.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl31 (PRE_first_tail_x6_r0_body.cncl30 bodyNcl30)

theorem bodyClean31 : Conv.JClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s312 :=
  PRE_first_tail_x6_r0_body.gjcl31 (PRE_first_tail_x6_r0_body.cjcl30 bodyClean30)

kernel_rfl bodyJsLe31 : Nat.ble PRE_first_tail_x6_r0_body.s304.next PRE_first_tail_x6_r0_body.s312.next = true
kernel_rfl bodyJsList31 : (PRE_first_tail_x6_r0_body.gjh31 ++ PRE_first_tail_x6_r0_body.cl31).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s312.next) PRE_first_tail_x6_r0_body.s314) = true
theorem bodyJs31 : JsHeapAbove PRE_first_tail_x6_r0_body.s312.next PRE_first_tail_x6_r0_body.s314 :=
  JsHeapAbove.glueSite bodyJs30 (Nat.le_of_ble_eq_true bodyJsLe31) PRE_first_tail_x6_r0_body.gjk31 PRE_first_tail_x6_r0_body.gjbd31 PRE_first_tail_x6_r0_body.cheap31 PRE_first_tail_x6_r0_body.zclbd31 bodyJsList31

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO306 : PRE_first_tail_x6_r0_body.S306.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S306.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr306 : bridgeOf PRE_first_tail_x6_r0_body.s306.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc306 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.S306) = fun _ _ => true
kernel_rfl bodyAcc307 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s307 PRE_first_tail_x6_r0_body.S307) = fun _ _ => true
kernel_rfl bodyBr308 : bridgeOf PRE_first_tail_x6_r0_body.s308.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt307 : isHalt PRE_first_tail_x6_r0_body.s307.ctl = false
kernel_rfl bodyTop308 : noRetBlock PRE_first_tail_x6_r0_body.s308 = true
kernel_rfl bodyCnt306 : countersOkB PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.s308 = true
kernel_rfl bodyO308 : PRE_first_tail_x6_r0_body.S308.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S308.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr309 : bridgeOf PRE_first_tail_x6_r0_body.s309.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt308 : countersOkB PRE_first_tail_x6_r0_body.s308 PRE_first_tail_x6_r0_body.s309 = true
kernel_rfl bodyO309 : PRE_first_tail_x6_r0_body.S309.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S309.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc309 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s309 PRE_first_tail_x6_r0_body.S309) = fun _ _ => true
kernel_rfl bodyAcc311 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s311 PRE_first_tail_x6_r0_body.S311) = fun _ _ => true
kernel_rfl bodyBr312 : bridgeOf PRE_first_tail_x6_r0_body.s312.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt311 : isHalt PRE_first_tail_x6_r0_body.s311.ctl = false
kernel_rfl bodyTop312 : noRetBlock PRE_first_tail_x6_r0_body.s312 = true
kernel_rfl bodyCnt309 : countersOkB PRE_first_tail_x6_r0_body.s309 PRE_first_tail_x6_r0_body.s312 = true

theorem bodyGlue31 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15284, 250, 0, 180⟩ bodyM PRE_first_tail_x6_r0_body.s306 PRE_first_tail_x6_r0_body.S306)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15284, 250, 0, 180⟩ bodyM PRE_first_tail_x6_r0_body.s312 PRE_first_tail_x6_r0_body.S312) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15284, 250, 0, 180⟩) bodyAcc306 PRE_first_tail_x6_r0_body.bodyRunSeg83 bodyAcc307 bodyHalt307 PRE_first_tail_x6_r0_body.bodyStepA84 bodyTop308 (fun _ hm => bodyO306 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr306).trans bodyInactive0) (bodyBr308.trans bodyBr306.symm) bodyCnt306 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15284, 250, 0, 180⟩) PRE_first_tail_x6_r0_body.sizeA84 PRE_first_tail_x6_r0_body.sizeArgsA84 PRE_first_tail_x6_r0_body.sizeSymA84 PRE_first_tail_x6_r0_body.sizeMlxA84 PRE_first_tail_x6_r0_body.sizePayA84 PRE_first_tail_x6_r0_body.sizeTaA84 PRE_first_tail_x6_r0_body.sizeDecA84 PRE_first_tail_x6_r0_body.sizePreA84 PRE_first_tail_x6_r0_body.bodyPatchB84 (fun _ hm => bodyO308 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr308).trans bodyInactive0) (bodyBr309.trans bodyBr308.symm) bodyCnt308 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15284, 250, 0, 180⟩) bodyAcc309 PRE_first_tail_x6_r0_body.bodyRunSeg84 bodyAcc311 bodyHalt311 PRE_first_tail_x6_r0_body.bodyStepA85 bodyTop312 (fun _ hm => bodyO309 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr309).trans bodyInactive0) (bodyBr312.trans bodyBr309.symm) bodyCnt309 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift31 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S312.tab.length PRE_first_tail_x6_r0_body.s312.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P31.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P31 1406 PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.s314.ffi PRE_first_tail_x6_r0_body.s313.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_31
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_31
  have hcl : SSt (· < 1406) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s314.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S312.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_31] <;> decide) PRE_first_tail_x6_r0_body.cnodesK31 PRE_first_tail_x6_r0_body.cobjsK31
      PRE_first_tail_x6_r0_body.citemsK31 PRE_first_tail_x6_r0_body.cbd31 PRE_first_tail_x6_r0_body.csst31
  exact PRE_first_tail_x6_r0_body.cshift31 bodyNcl31 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_31] at this; exact this)


kernel_rfl bodyFramesEmpty31 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s313 a).isEmpty) = true
kernel_rfl bodyJsRoots31 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s312.next) PRE_first_tail_x6_r0_body.s314.trace PRE_first_tail_x6_r0_body.s314 = true
kernel_rfl bodyJsNative31 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s314.ffi) = true
kernel_rfl bodyLow31 : (PRE_first_tail_x6_r0_body.cws31 ++ PRE_first_tail_x6_r0_body.ws31).all (Nat.ble 9) = true
kernel_rfl bodyCntM31 : countersOkB PRE_first_tail_x6_r0_body.s312 PRE_first_tail_x6_r0_body.s313 = true
kernel_rfl bodyHi31 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s314.ffi).next setupP.E = true
kernel_rfl bodyNhi31 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s314.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge31 : bridgeOf PRE_first_tail_x6_r0_body.s313.ffi = bridgeOf PRE_first_tail_x6_r0_body.s312.ffi
kernel_rfl bodyNN31 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s312.ffi).nnext PRE_first_tail_x6_r0_body.P31.NL = true
kernel_rfl bodyXn31 : Nat.ble (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s314.ffi).next = true
kernel_rfl bodyLo31 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s314.ffi).next = true
theorem bodyFacts31 : BodySiteFacts PRE_first_tail_x6_r0_body.s312 PRE_first_tail_x6_r0_body.s313 PRE_first_tail_x6_r0_body.s314 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S312 PRE_first_tail_x6_r0_body.S313 PRE_first_tail_x6_r0_body.S314
    PRE_first_tail_x6_r0_body.ws31 PRE_first_tail_x6_r0_body.cws31 PRE_first_tail_x6_r0_body.nr31 PRE_first_tail_x6_r0_body.pl31 PRE_first_tail_x6_r0_body.cl31 2699297 1406 PRE_first_tail_x6_r0_body.kd31 PRE_first_tail_x6_r0_body.kappa31 PRE_first_tail_x6_r0_body.P31
    ⟨18818, 15918, 2699295, 1406⟩ ⟨18818, 15918, 2699295, 1406⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap31
  clean := bodyClean31
  cfix := PRE_first_tail_x6_r0_body.cfix31
  zpl := PRE_first_tail_x6_r0_body.zpl31
  zplnd := PRE_first_tail_x6_r0_body.zplnd31
  zn1 := PRE_first_tail_x6_r0_body.zn131
  zfirst := PRE_first_tail_x6_r0_body.zfirst31
  zscn := PRE_first_tail_x6_r0_body.zscn31
  zsmn := PRE_first_tail_x6_r0_body.zsmn31
  zgrow := PRE_first_tail_x6_r0_body.zgrow31
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab31
  zfresh := PRE_first_tail_x6_r0_body.zfresh31
  zcnd := PRE_first_tail_x6_r0_body.zcnd31
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi31
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt31
  zgP := PRE_first_tail_x6_r0_body.zg31_2665
  zkP := PRE_first_tail_x6_r0_body.zk31_2665
  zmP := PRE_first_tail_x6_r0_body.zm31_2665
  zgC := PRE_first_tail_x6_r0_body.zg31_2673467
  zkC := PRE_first_tail_x6_r0_body.zk31_2673467
  zmC := PRE_first_tail_x6_r0_body.zm31_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw31_2673472
  zwV := PRE_first_tail_x6_r0_body.zw31_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap31
  zclbd := PRE_first_tail_x6_r0_body.zclbd31
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap31 PRE_first_tail_x6_r0_body.stFoot31 PRE_first_tail_x6_r0_body.iso31 PRE_first_tail_x6_r0_body.zwr31
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP31
  csupp := PRE_first_tail_x6_r0_body.csupp31
  cbound := PRE_first_tail_x6_r0_body.cbound31
  zimg := PRE_first_tail_x6_r0_body.zimg31
  zctl := PRE_first_tail_x6_r0_body.zctl31
  zstack := PRE_first_tail_x6_r0_body.zstack31
  zjobs := PRE_first_tail_x6_r0_body.zjobs31
  zstores := PRE_first_tail_x6_r0_body.zstores31
  zroots := PRE_first_tail_x6_r0_body.zroots31
  znC := PRE_first_tail_x6_r0_body.znC31
  ctab := PRE_first_tail_x6_r0_body.ctab31
  zbin := PRE_first_tail_x6_r0_body.zbin31
  cbridge := PRE_first_tail_x6_r0_body.cbridge31
  sbridge := bodyBridge31
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj31
  cshiftR := fun h hNL => bodyCshift31 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN31
  raised := PRE_first_tail_x6_r0_body.raised31
  cbigs := PRE_first_tail_x6_r0_body.cbigs31
  cjcl := PRE_first_tail_x6_r0_body.cjcl31
  xnLe := Nat.le_of_ble_eq_true bodyXn31
  loLe := Nat.le_of_ble_eq_true bodyLo31
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB31
  cntM := bodyCntM31
  hiLe := Nat.le_of_ble_eq_true bodyHi31
  nhiLe := Nat.le_of_ble_eq_true bodyNhi31
  jsHeap := bodyJs31
  jsRoots := bodyJsRoots31
  jsNative := bodyJsNative31
  framesEmpty := bodyFramesEmpty31
  trailOld := by decide
  lowVars := bodyLow31

def bodyQs31 : List (Option Q) := []
noncomputable def bodyEs31 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr31.map fun r => nth? PRE_first_tail_x6_r0_body.st31.S2.tab r
kernel_rfl bodyResChk31 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs31 bodyQs31) = true
kernel_rfl bodyLq31 : bodyQs31.length = PRE_first_tail_x6_r0_body.cws31.length
kernel_rfl bodyNrLo31 : PRE_first_tail_x6_r0_body.nr31.all (Nat.ble PRE_first_tail_x6_r0_body.S312.tab.length) = true
kernel_rfl bodySub31 : (Oracles.PRE_first_tail_x6_r0_body.map_site31.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost31 : postSubB bodyM PRE_first_tail_x6_r0_body.ws31 PRE_first_tail_x6_r0_body.cws31 bodyQs31 = true
kernel_rfl bodyDrop31 : Nat.ble (15284 + (PRE_first_tail_x6_r0_body.s313.next - PRE_first_tail_x6_r0_body.s314.next)) 15286 = true
kernel_rfl bodyDropH31 : Nat.ble (250 + ((mlxOf PRE_first_tail_x6_r0_body.s313.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s314.ffi).next)) 250 = true
kernel_rfl bodyDropN31 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s313.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s314.ffi).nnext)) 0 = true
kernel_rfl bodyDv31 : bodyΘ.1.take 180 = bodyΘ.1.take 180 ++ PRE_first_tail_x6_r0_body.cws31
kernel_rfl bodyDe31 : bodyΘ.2.take 180 = bodyΘ.2.take 180 ++ PRE_first_tail_x6_r0_body.nr31.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st31.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 180) (bodyΘ.2.take 180)))
kernel_rfl bodyDl31 : (bodyΘ.1.take 180).length = (bodyΘ.2.take 180).length
kernel_rfl bodyDold31 : (bodyΘ.1.take 180).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws31).isNone && !PRE_first_tail_x6_r0_body.ws31.contains v) = true
kernel_rfl bodyDfree31 : (bodyΘ.2.take 180).all (fun e => (PRE_first_tail_x6_r0_body.cws31 ++ PRE_first_tail_x6_r0_body.ws31).all fun w => e.noVar w) = true

theorem bodyStep31 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15284, 250, 0, 180⟩ bodyM PRE_first_tail_x6_r0_body.s312 PRE_first_tail_x6_r0_body.S312)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15286, 250, 0, 180⟩ bodyM PRE_first_tail_x6_r0_body.s314 PRE_first_tail_x6_r0_body.S314) (27 + 1) :=
  bodySite bodyFacts31.cfix bodyFacts31.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x6_r0_body.st31.S2.tab) (Es := bodyEs31) (qs := bodyQs31)
    (ok := PRE_first_tail_x6_r0_body.st31.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site31 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts31
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site31 r hr) hi (MapOk.sub hm (sub_of_all bodySub31)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk31 r hr) hi hm ho hq)
    bodyLq31 rfl bodyNrLo31 (postSub_sound bodyPost31)
    (Nat.le_of_ble_eq_true bodyDrop31) (by decide) (Nat.le_of_ble_eq_true bodyDropH31) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN31) (by decide)
    bodyDv31 bodyDe31 bodyDl31 bodyDold31 bodyDfree31 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end
