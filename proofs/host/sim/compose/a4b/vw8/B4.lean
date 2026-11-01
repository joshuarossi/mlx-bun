import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x8_r0_body.States
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B19
import host.sim.compose.a4b.vw8.B3
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B34
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw8.VWBodyChain
import host.sim.compose.a4b.vw8.VWBodyMap
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B14
import host.sim.template.CallGen

section -- VWBodyOracles_8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_g32 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g32 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g32) (List.take 3 (List.drop 309 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site32 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site32 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site32) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g33 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g33 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g33) (List.take 28 (List.drop 312 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site33 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site33 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site33) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st33.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g34 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g34 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g34) (List.take 9 (List.drop 340 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site34 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site34 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site34) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st34.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g35 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g35 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g35) (List.take 3 (List.drop 349 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site35 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site35 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site35) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site32 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site32 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site32) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site32
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s316 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s317 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S316 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws32 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso32
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_32
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot32
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup32
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound32
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace32
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged32
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws32.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st32.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S316.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_32]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen32.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh32
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl32 : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s316.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl32 (PRE_first_tail_x8_r0_body.cncl31 bodyNcl31)

theorem bodyClean32 : Conv.JClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s316 :=
  PRE_first_tail_x8_r0_body.gjcl32 (PRE_first_tail_x8_r0_body.cjcl31 bodyClean31)

kernel_rfl bodyJsLe32 : Nat.ble PRE_first_tail_x8_r0_body.s312.next PRE_first_tail_x8_r0_body.s316.next = true
kernel_rfl bodyJsList32 : (PRE_first_tail_x8_r0_body.gjh32 ++ PRE_first_tail_x8_r0_body.cl32).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s316.next) PRE_first_tail_x8_r0_body.s318) = true
theorem bodyJs32 : JsHeapAbove PRE_first_tail_x8_r0_body.s316.next PRE_first_tail_x8_r0_body.s318 :=
  JsHeapAbove.glueSite bodyJs31 (Nat.le_of_ble_eq_true bodyJsLe32) PRE_first_tail_x8_r0_body.gjk32 PRE_first_tail_x8_r0_body.gjbd32 PRE_first_tail_x8_r0_body.cheap32 PRE_first_tail_x8_r0_body.zclbd32 bodyJsList32

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO314 : PRE_first_tail_x8_r0_body.S314.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S314.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr314 : bridgeOf PRE_first_tail_x8_r0_body.s314.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc314 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s314 PRE_first_tail_x8_r0_body.S314) = fun _ _ => true
kernel_rfl bodyAcc315 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s315 PRE_first_tail_x8_r0_body.S315) = fun _ _ => true
kernel_rfl bodyBr316 : bridgeOf PRE_first_tail_x8_r0_body.s316.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt315 : isHalt PRE_first_tail_x8_r0_body.s315.ctl = false
kernel_rfl bodyTop316 : noRetBlock PRE_first_tail_x8_r0_body.s316 = true
kernel_rfl bodyCnt314 : countersOkB PRE_first_tail_x8_r0_body.s314 PRE_first_tail_x8_r0_body.s316 = true

theorem bodyGlue32 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15287, 250, 0, 180⟩ bodyM PRE_first_tail_x8_r0_body.s314 PRE_first_tail_x8_r0_body.S314)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15287, 250, 0, 180⟩ bodyM PRE_first_tail_x8_r0_body.s316 PRE_first_tail_x8_r0_body.S316) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15287, 250, 0, 180⟩) bodyAcc314 PRE_first_tail_x8_r0_body.bodyRunSeg85 bodyAcc315 bodyHalt315 PRE_first_tail_x8_r0_body.bodyStepA86 bodyTop316 (fun _ hm => bodyO314 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr314).trans bodyInactive0) (bodyBr316.trans bodyBr314.symm) bodyCnt314 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift32 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S316.tab.length PRE_first_tail_x8_r0_body.s316.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P32.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P32 1423 PRE_first_tail_x8_r0_body.kappa32 PRE_first_tail_x8_r0_body.s318.ffi PRE_first_tail_x8_r0_body.s317.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_32
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_32
  have hcl : SSt (· < 1423) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s318.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S316.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_32] <;> decide) PRE_first_tail_x8_r0_body.cnodesK32 PRE_first_tail_x8_r0_body.cobjsK32
      PRE_first_tail_x8_r0_body.citemsK32 PRE_first_tail_x8_r0_body.cbd32 PRE_first_tail_x8_r0_body.csst32
  exact PRE_first_tail_x8_r0_body.cshift32 bodyNcl32 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_32] at this; exact this)


kernel_rfl bodyFramesEmpty32 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s317 a).isEmpty) = true
kernel_rfl bodyJsRoots32 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s316.next) PRE_first_tail_x8_r0_body.s318.trace PRE_first_tail_x8_r0_body.s318 = true
kernel_rfl bodyJsNative32 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s318.ffi) = true
kernel_rfl bodyLow32 : (PRE_first_tail_x8_r0_body.cws32 ++ PRE_first_tail_x8_r0_body.ws32).all (Nat.ble 9) = true
kernel_rfl bodyCntM32 : countersOkB PRE_first_tail_x8_r0_body.s316 PRE_first_tail_x8_r0_body.s317 = true
kernel_rfl bodyHi32 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s318.ffi).next setupP.E = true
kernel_rfl bodyNhi32 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s318.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge32 : bridgeOf PRE_first_tail_x8_r0_body.s317.ffi = bridgeOf PRE_first_tail_x8_r0_body.s316.ffi
kernel_rfl bodyNN32 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s316.ffi).nnext PRE_first_tail_x8_r0_body.P32.NL = true
kernel_rfl bodyXn32 : Nat.ble (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s318.ffi).next = true
kernel_rfl bodyLo32 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s318.ffi).next = true
theorem bodyFacts32 : BodySiteFacts PRE_first_tail_x8_r0_body.s316 PRE_first_tail_x8_r0_body.s317 PRE_first_tail_x8_r0_body.s318 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S316 PRE_first_tail_x8_r0_body.S317 PRE_first_tail_x8_r0_body.S318
    PRE_first_tail_x8_r0_body.ws32 PRE_first_tail_x8_r0_body.cws32 PRE_first_tail_x8_r0_body.nr32 PRE_first_tail_x8_r0_body.pl32 PRE_first_tail_x8_r0_body.cl32 2699594 1423 PRE_first_tail_x8_r0_body.kd32 PRE_first_tail_x8_r0_body.kappa32 PRE_first_tail_x8_r0_body.P32
    ⟨18825, 15922, 2699583, 1423⟩ ⟨18825, 15922, 2699584, 1423⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap32
  clean := bodyClean32
  cfix := PRE_first_tail_x8_r0_body.cfix32
  zpl := PRE_first_tail_x8_r0_body.zpl32
  zplnd := PRE_first_tail_x8_r0_body.zplnd32
  zn1 := PRE_first_tail_x8_r0_body.zn132
  zfirst := PRE_first_tail_x8_r0_body.zfirst32
  zscn := PRE_first_tail_x8_r0_body.zscn32
  zsmn := PRE_first_tail_x8_r0_body.zsmn32
  zgrow := PRE_first_tail_x8_r0_body.zgrow32
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab32
  zfresh := PRE_first_tail_x8_r0_body.zfresh32
  zcnd := PRE_first_tail_x8_r0_body.zcnd32
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi32
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt32
  zgP := PRE_first_tail_x8_r0_body.zg32_2665
  zkP := PRE_first_tail_x8_r0_body.zk32_2665
  zmP := PRE_first_tail_x8_r0_body.zm32_2665
  zgC := PRE_first_tail_x8_r0_body.zg32_2673467
  zkC := PRE_first_tail_x8_r0_body.zk32_2673467
  zmC := PRE_first_tail_x8_r0_body.zm32_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw32_2673472
  zwV := PRE_first_tail_x8_r0_body.zw32_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap32
  zclbd := PRE_first_tail_x8_r0_body.zclbd32
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap32 PRE_first_tail_x8_r0_body.stFoot32 PRE_first_tail_x8_r0_body.iso32 PRE_first_tail_x8_r0_body.zwr32
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP32
  csupp := PRE_first_tail_x8_r0_body.csupp32
  cbound := PRE_first_tail_x8_r0_body.cbound32
  zimg := PRE_first_tail_x8_r0_body.zimg32
  zctl := PRE_first_tail_x8_r0_body.zctl32
  zstack := PRE_first_tail_x8_r0_body.zstack32
  zjobs := PRE_first_tail_x8_r0_body.zjobs32
  zstores := PRE_first_tail_x8_r0_body.zstores32
  zroots := PRE_first_tail_x8_r0_body.zroots32
  znC := PRE_first_tail_x8_r0_body.znC32
  ctab := PRE_first_tail_x8_r0_body.ctab32
  zbin := PRE_first_tail_x8_r0_body.zbin32
  cbridge := PRE_first_tail_x8_r0_body.cbridge32
  sbridge := bodyBridge32
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj32
  cshiftR := fun h hNL => bodyCshift32 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN32
  raised := PRE_first_tail_x8_r0_body.raised32
  cbigs := PRE_first_tail_x8_r0_body.cbigs32
  cjcl := PRE_first_tail_x8_r0_body.cjcl32
  xnLe := Nat.le_of_ble_eq_true bodyXn32
  loLe := Nat.le_of_ble_eq_true bodyLo32
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB32
  cntM := bodyCntM32
  hiLe := Nat.le_of_ble_eq_true bodyHi32
  nhiLe := Nat.le_of_ble_eq_true bodyNhi32
  jsHeap := bodyJs32
  jsRoots := bodyJsRoots32
  jsNative := bodyJsNative32
  framesEmpty := bodyFramesEmpty32
  trailOld := by decide
  lowVars := bodyLow32

def bodyQs32 : List (Option Q) := []
noncomputable def bodyEs32 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr32.map fun r => nth? PRE_first_tail_x8_r0_body.st32.S2.tab r
kernel_rfl bodyResChk32 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs32 bodyQs32) = true
kernel_rfl bodyLq32 : bodyQs32.length = PRE_first_tail_x8_r0_body.cws32.length
kernel_rfl bodyNrLo32 : PRE_first_tail_x8_r0_body.nr32.all (Nat.ble PRE_first_tail_x8_r0_body.S316.tab.length) = true
kernel_rfl bodySub32 : (Oracles.PRE_first_tail_x8_r0_body.map_site32.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost32 : postSubB bodyM PRE_first_tail_x8_r0_body.ws32 PRE_first_tail_x8_r0_body.cws32 bodyQs32 = true
kernel_rfl bodyDrop32 : Nat.ble (15287 + (PRE_first_tail_x8_r0_body.s317.next - PRE_first_tail_x8_r0_body.s318.next)) 15297 = true
kernel_rfl bodyDropH32 : Nat.ble (250 + ((mlxOf PRE_first_tail_x8_r0_body.s317.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s318.ffi).next)) 250 = true
kernel_rfl bodyDropN32 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s317.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s318.ffi).nnext)) 0 = true
kernel_rfl bodyDv32 : bodyΘ.1.take 180 = bodyΘ.1.take 180 ++ PRE_first_tail_x8_r0_body.cws32
kernel_rfl bodyDe32 : bodyΘ.2.take 180 = bodyΘ.2.take 180 ++ PRE_first_tail_x8_r0_body.nr32.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st32.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 180) (bodyΘ.2.take 180)))
kernel_rfl bodyDl32 : (bodyΘ.1.take 180).length = (bodyΘ.2.take 180).length
kernel_rfl bodyDold32 : (bodyΘ.1.take 180).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws32).isNone && !PRE_first_tail_x8_r0_body.ws32.contains v) = true
kernel_rfl bodyDfree32 : (bodyΘ.2.take 180).all (fun e => (PRE_first_tail_x8_r0_body.cws32 ++ PRE_first_tail_x8_r0_body.ws32).all fun w => e.noVar w) = true

theorem bodyStep32 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15287, 250, 0, 180⟩ bodyM PRE_first_tail_x8_r0_body.s316 PRE_first_tail_x8_r0_body.S316)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15297, 250, 0, 180⟩ bodyM PRE_first_tail_x8_r0_body.s318 PRE_first_tail_x8_r0_body.S318) (98 + 1) :=
  bodySite bodyFacts32.cfix bodyFacts32.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x8_r0_body.st32.S2.tab) (Es := bodyEs32) (qs := bodyQs32)
    (ok := PRE_first_tail_x8_r0_body.st32.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site32 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts32
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site32 r hr) hi (MapOk.sub hm (sub_of_all bodySub32)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk32 r hr) hi hm ho hq)
    bodyLq32 rfl bodyNrLo32 (postSub_sound bodyPost32)
    (Nat.le_of_ble_eq_true bodyDrop32) (by decide) (Nat.le_of_ble_eq_true bodyDropH32) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN32) (by decide)
    bodyDv32 bodyDe32 bodyDl32 bodyDold32 bodyDfree32 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site33 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site33 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site33) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st33.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site33
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st33.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st33.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s332 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s333 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S332 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws33 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st33.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st33.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso33
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_33
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st33.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot33
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup33
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound33
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace33
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged33
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws33.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st33.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S332.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_33]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen33.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh33
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl33 : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s332.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl33 (PRE_first_tail_x8_r0_body.cncl32 bodyNcl32)

theorem bodyClean33 : Conv.JClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s332 :=
  PRE_first_tail_x8_r0_body.gjcl33 (PRE_first_tail_x8_r0_body.cjcl32 bodyClean32)

kernel_rfl bodyJsLe33 : Nat.ble PRE_first_tail_x8_r0_body.s316.next PRE_first_tail_x8_r0_body.s332.next = true
kernel_rfl bodyJsList33 : (PRE_first_tail_x8_r0_body.gjh33 ++ PRE_first_tail_x8_r0_body.cl33).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s332.next) PRE_first_tail_x8_r0_body.s334) = true
theorem bodyJs33 : JsHeapAbove PRE_first_tail_x8_r0_body.s332.next PRE_first_tail_x8_r0_body.s334 :=
  JsHeapAbove.glueSite bodyJs32 (Nat.le_of_ble_eq_true bodyJsLe33) PRE_first_tail_x8_r0_body.gjk33 PRE_first_tail_x8_r0_body.gjbd33 PRE_first_tail_x8_r0_body.cheap33 PRE_first_tail_x8_r0_body.zclbd33 bodyJsList33

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO318 : PRE_first_tail_x8_r0_body.S318.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S318.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr318 : bridgeOf PRE_first_tail_x8_r0_body.s318.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc318 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s318 PRE_first_tail_x8_r0_body.S318) = fun _ _ => true
kernel_rfl bodyAcc320 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s320 PRE_first_tail_x8_r0_body.S320) = fun _ _ => true
kernel_rfl bodyBr321 : bridgeOf PRE_first_tail_x8_r0_body.s321.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt320 : isHalt PRE_first_tail_x8_r0_body.s320.ctl = false
kernel_rfl bodyTop321 : noRetBlock PRE_first_tail_x8_r0_body.s321 = true
kernel_rfl bodyCnt318 : countersOkB PRE_first_tail_x8_r0_body.s318 PRE_first_tail_x8_r0_body.s321 = true
kernel_rfl bodyO321 : PRE_first_tail_x8_r0_body.S321.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S321.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr322 : bridgeOf PRE_first_tail_x8_r0_body.s322.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt321 : countersOkB PRE_first_tail_x8_r0_body.s321 PRE_first_tail_x8_r0_body.s322 = true
kernel_rfl bodyO322 : PRE_first_tail_x8_r0_body.S322.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S322.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc322 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s322 PRE_first_tail_x8_r0_body.S322) = fun _ _ => true
kernel_rfl bodyAcc324 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s324 PRE_first_tail_x8_r0_body.S324) = fun _ _ => true
kernel_rfl bodyBr325 : bridgeOf PRE_first_tail_x8_r0_body.s325.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt324 : isHalt PRE_first_tail_x8_r0_body.s324.ctl = false
kernel_rfl bodyTop325 : noRetBlock PRE_first_tail_x8_r0_body.s325 = true
kernel_rfl bodyCnt322 : countersOkB PRE_first_tail_x8_r0_body.s322 PRE_first_tail_x8_r0_body.s325 = true
kernel_rfl bodyO325 : PRE_first_tail_x8_r0_body.S325.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S325.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr326 : bridgeOf PRE_first_tail_x8_r0_body.s326.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt325 : countersOkB PRE_first_tail_x8_r0_body.s325 PRE_first_tail_x8_r0_body.s326 = true
kernel_rfl bodyO326 : PRE_first_tail_x8_r0_body.S326.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S326.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc326 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s326 PRE_first_tail_x8_r0_body.S326) = fun _ _ => true
kernel_rfl bodyAcc327 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s327 PRE_first_tail_x8_r0_body.S327) = fun _ _ => true
kernel_rfl bodyBr328 : bridgeOf PRE_first_tail_x8_r0_body.s328.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt327 : isHalt PRE_first_tail_x8_r0_body.s327.ctl = false
kernel_rfl bodyTop328 : noRetBlock PRE_first_tail_x8_r0_body.s328 = true
kernel_rfl bodyCnt326 : countersOkB PRE_first_tail_x8_r0_body.s326 PRE_first_tail_x8_r0_body.s328 = true
kernel_rfl bodyO328 : PRE_first_tail_x8_r0_body.S328.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S328.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr329 : bridgeOf PRE_first_tail_x8_r0_body.s329.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt328 : countersOkB PRE_first_tail_x8_r0_body.s328 PRE_first_tail_x8_r0_body.s329 = true
kernel_rfl bodyO329 : PRE_first_tail_x8_r0_body.S329.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S329.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc329 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s329 PRE_first_tail_x8_r0_body.S329) = fun _ _ => true
kernel_rfl bodyAcc331 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s331 PRE_first_tail_x8_r0_body.S331) = fun _ _ => true
kernel_rfl bodyBr332 : bridgeOf PRE_first_tail_x8_r0_body.s332.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt331 : isHalt PRE_first_tail_x8_r0_body.s331.ctl = false
kernel_rfl bodyTop332 : noRetBlock PRE_first_tail_x8_r0_body.s332 = true
kernel_rfl bodyCnt329 : countersOkB PRE_first_tail_x8_r0_body.s329 PRE_first_tail_x8_r0_body.s332 = true

theorem bodyGlue33 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15297, 250, 0, 180⟩ bodyM PRE_first_tail_x8_r0_body.s318 PRE_first_tail_x8_r0_body.S318)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15297, 250, 0, 180⟩ bodyM PRE_first_tail_x8_r0_body.s332 PRE_first_tail_x8_r0_body.S332) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15297, 250, 0, 180⟩) bodyAcc318 PRE_first_tail_x8_r0_body.bodyRunSeg86 bodyAcc320 bodyHalt320 PRE_first_tail_x8_r0_body.bodyStepA87 bodyTop321 (fun _ hm => bodyO318 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr318).trans bodyInactive0) (bodyBr321.trans bodyBr318.symm) bodyCnt318 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15297, 250, 0, 180⟩) PRE_first_tail_x8_r0_body.sizeA87 PRE_first_tail_x8_r0_body.sizeArgsA87 PRE_first_tail_x8_r0_body.sizeSymA87 PRE_first_tail_x8_r0_body.sizeMlxA87 PRE_first_tail_x8_r0_body.sizePayA87 PRE_first_tail_x8_r0_body.sizeTaA87 PRE_first_tail_x8_r0_body.sizeDecA87 PRE_first_tail_x8_r0_body.sizePreA87 PRE_first_tail_x8_r0_body.bodyPatchB87 (fun _ hm => bodyO321 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr321).trans bodyInactive0) (bodyBr322.trans bodyBr321.symm) bodyCnt321 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15297, 250, 0, 180⟩) bodyAcc322 PRE_first_tail_x8_r0_body.bodyRunSeg87 bodyAcc324 bodyHalt324 PRE_first_tail_x8_r0_body.bodyStepA88 bodyTop325 (fun _ hm => bodyO322 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr322).trans bodyInactive0) (bodyBr325.trans bodyBr322.symm) bodyCnt322 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15297, 250, 0, 180⟩) PRE_first_tail_x8_r0_body.sizeA88 PRE_first_tail_x8_r0_body.sizeArgsA88 PRE_first_tail_x8_r0_body.sizeSymA88 PRE_first_tail_x8_r0_body.sizeMlxA88 PRE_first_tail_x8_r0_body.sizePayA88 PRE_first_tail_x8_r0_body.sizeTaA88 PRE_first_tail_x8_r0_body.sizeDecA88 PRE_first_tail_x8_r0_body.sizePreA88 PRE_first_tail_x8_r0_body.bodyPatchB88 (fun _ hm => bodyO325 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr325).trans bodyInactive0) (bodyBr326.trans bodyBr325.symm) bodyCnt325 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15297, 250, 0, 180⟩) bodyAcc326 PRE_first_tail_x8_r0_body.bodyRunSeg88 bodyAcc327 bodyHalt327 PRE_first_tail_x8_r0_body.bodyStepA89 bodyTop328 (fun _ hm => bodyO326 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr326).trans bodyInactive0) (bodyBr328.trans bodyBr326.symm) bodyCnt326 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15297, 250, 0, 180⟩) PRE_first_tail_x8_r0_body.sizeA89 PRE_first_tail_x8_r0_body.sizeArgsA89 PRE_first_tail_x8_r0_body.sizeSymA89 PRE_first_tail_x8_r0_body.sizeMlxA89 PRE_first_tail_x8_r0_body.sizePayA89 PRE_first_tail_x8_r0_body.sizeTaA89 PRE_first_tail_x8_r0_body.sizeDecA89 PRE_first_tail_x8_r0_body.sizePreA89 PRE_first_tail_x8_r0_body.bodyPatchB89 (fun _ hm => bodyO328 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr328).trans bodyInactive0) (bodyBr329.trans bodyBr328.symm) bodyCnt328 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15297, 250, 0, 180⟩) bodyAcc329 PRE_first_tail_x8_r0_body.bodyRunSeg89 bodyAcc331 bodyHalt331 PRE_first_tail_x8_r0_body.bodyStepA90 bodyTop332 (fun _ hm => bodyO329 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr329).trans bodyInactive0) (bodyBr332.trans bodyBr329.symm) bodyCnt329 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift33 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S332.tab.length PRE_first_tail_x8_r0_body.s332.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P33.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P33 1509 PRE_first_tail_x8_r0_body.kappa33 PRE_first_tail_x8_r0_body.s334.ffi PRE_first_tail_x8_r0_body.s333.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_33
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_33
  have hcl : SSt (· < 1509) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s334.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S332.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_33] <;> decide) PRE_first_tail_x8_r0_body.cnodesK33 PRE_first_tail_x8_r0_body.cobjsK33
      PRE_first_tail_x8_r0_body.citemsK33 PRE_first_tail_x8_r0_body.cbd33 PRE_first_tail_x8_r0_body.csst33
  exact PRE_first_tail_x8_r0_body.cshift33 bodyNcl33 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_33] at this; exact this)


kernel_rfl bodyFramesEmpty33 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s333 a).isEmpty) = true
kernel_rfl bodyJsRoots33 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s332.next) PRE_first_tail_x8_r0_body.s334.trace PRE_first_tail_x8_r0_body.s334 = true
kernel_rfl bodyJsNative33 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s334.ffi) = true
kernel_rfl bodyLow33 : (PRE_first_tail_x8_r0_body.cws33 ++ PRE_first_tail_x8_r0_body.ws33).all (Nat.ble 9) = true
kernel_rfl bodyCntM33 : countersOkB PRE_first_tail_x8_r0_body.s332 PRE_first_tail_x8_r0_body.s333 = true
kernel_rfl bodyHi33 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s334.ffi).next setupP.E = true
kernel_rfl bodyNhi33 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s334.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge33 : bridgeOf PRE_first_tail_x8_r0_body.s333.ffi = bridgeOf PRE_first_tail_x8_r0_body.s332.ffi
kernel_rfl bodyNN33 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s332.ffi).nnext PRE_first_tail_x8_r0_body.P33.NL = true
kernel_rfl bodyXn33 : Nat.ble (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s334.ffi).next = true
kernel_rfl bodyLo33 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s334.ffi).next = true
theorem bodyFacts33 : BodySiteFacts PRE_first_tail_x8_r0_body.s332 PRE_first_tail_x8_r0_body.s333 PRE_first_tail_x8_r0_body.s334 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S332 PRE_first_tail_x8_r0_body.S333 PRE_first_tail_x8_r0_body.S334
    PRE_first_tail_x8_r0_body.ws33 PRE_first_tail_x8_r0_body.cws33 PRE_first_tail_x8_r0_body.nr33 PRE_first_tail_x8_r0_body.pl33 PRE_first_tail_x8_r0_body.cl33 2701685 1509 PRE_first_tail_x8_r0_body.kd33 PRE_first_tail_x8_r0_body.kappa33 PRE_first_tail_x8_r0_body.P33
    ⟨18865, 15950, 2701320, 1500⟩ ⟨18869, 15956, 2701335, 1509⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap33
  clean := bodyClean33
  cfix := PRE_first_tail_x8_r0_body.cfix33
  zpl := PRE_first_tail_x8_r0_body.zpl33
  zplnd := PRE_first_tail_x8_r0_body.zplnd33
  zn1 := PRE_first_tail_x8_r0_body.zn133
  zfirst := PRE_first_tail_x8_r0_body.zfirst33
  zscn := PRE_first_tail_x8_r0_body.zscn33
  zsmn := PRE_first_tail_x8_r0_body.zsmn33
  zgrow := PRE_first_tail_x8_r0_body.zgrow33
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab33
  zfresh := PRE_first_tail_x8_r0_body.zfresh33
  zcnd := PRE_first_tail_x8_r0_body.zcnd33
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi33
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt33
  zgP := PRE_first_tail_x8_r0_body.zg33_2665
  zkP := PRE_first_tail_x8_r0_body.zk33_2665
  zmP := PRE_first_tail_x8_r0_body.zm33_2665
  zgC := PRE_first_tail_x8_r0_body.zg33_2673467
  zkC := PRE_first_tail_x8_r0_body.zk33_2673467
  zmC := PRE_first_tail_x8_r0_body.zm33_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw33_2673472
  zwV := PRE_first_tail_x8_r0_body.zw33_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap33
  zclbd := PRE_first_tail_x8_r0_body.zclbd33
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap33 PRE_first_tail_x8_r0_body.stFoot33 PRE_first_tail_x8_r0_body.iso33 PRE_first_tail_x8_r0_body.zwr33
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP33
  csupp := PRE_first_tail_x8_r0_body.csupp33
  cbound := PRE_first_tail_x8_r0_body.cbound33
  zimg := PRE_first_tail_x8_r0_body.zimg33
  zctl := PRE_first_tail_x8_r0_body.zctl33
  zstack := PRE_first_tail_x8_r0_body.zstack33
  zjobs := PRE_first_tail_x8_r0_body.zjobs33
  zstores := PRE_first_tail_x8_r0_body.zstores33
  zroots := PRE_first_tail_x8_r0_body.zroots33
  znC := PRE_first_tail_x8_r0_body.znC33
  ctab := PRE_first_tail_x8_r0_body.ctab33
  zbin := PRE_first_tail_x8_r0_body.zbin33
  cbridge := PRE_first_tail_x8_r0_body.cbridge33
  sbridge := bodyBridge33
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj33
  cshiftR := fun h hNL => bodyCshift33 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN33
  raised := PRE_first_tail_x8_r0_body.raised33
  cbigs := PRE_first_tail_x8_r0_body.cbigs33
  cjcl := PRE_first_tail_x8_r0_body.cjcl33
  xnLe := Nat.le_of_ble_eq_true bodyXn33
  loLe := Nat.le_of_ble_eq_true bodyLo33
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB33
  cntM := bodyCntM33
  hiLe := Nat.le_of_ble_eq_true bodyHi33
  nhiLe := Nat.le_of_ble_eq_true bodyNhi33
  jsHeap := bodyJs33
  jsRoots := bodyJsRoots33
  jsNative := bodyJsNative33
  framesEmpty := bodyFramesEmpty33
  trailOld := by decide
  lowVars := bodyLow33

def bodyQs33 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs33 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr33.map fun r => nth? PRE_first_tail_x8_r0_body.st33.S3.tab r
kernel_rfl bodyResChk33 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs33 bodyQs33) = true
kernel_rfl bodyLq33 : bodyQs33.length = PRE_first_tail_x8_r0_body.cws33.length
kernel_rfl bodyNrLo33 : PRE_first_tail_x8_r0_body.nr33.all (Nat.ble PRE_first_tail_x8_r0_body.S332.tab.length) = true
kernel_rfl bodySub33 : (Oracles.PRE_first_tail_x8_r0_body.map_site33.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost33 : postSubB bodyM PRE_first_tail_x8_r0_body.ws33 PRE_first_tail_x8_r0_body.cws33 bodyQs33 = true
kernel_rfl bodyDrop33 : Nat.ble (15297 + (PRE_first_tail_x8_r0_body.s333.next - PRE_first_tail_x8_r0_body.s334.next)) 15647 = true
kernel_rfl bodyDropH33 : Nat.ble (250 + ((mlxOf PRE_first_tail_x8_r0_body.s333.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s334.ffi).next)) 252 = true
kernel_rfl bodyDropN33 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s333.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s334.ffi).nnext)) 0 = true
kernel_rfl bodyDv33 : bodyΘ.1.take 189 = bodyΘ.1.take 180 ++ PRE_first_tail_x8_r0_body.cws33
kernel_rfl bodyDe33 : bodyΘ.2.take 189 = bodyΘ.2.take 180 ++ PRE_first_tail_x8_r0_body.nr33.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st33.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 180) (bodyΘ.2.take 180)))
kernel_rfl bodyDl33 : (bodyΘ.1.take 180).length = (bodyΘ.2.take 180).length
kernel_rfl bodyDold33 : (bodyΘ.1.take 180).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws33).isNone && !PRE_first_tail_x8_r0_body.ws33.contains v) = true
kernel_rfl bodyDfree33 : (bodyΘ.2.take 189).all (fun e => (PRE_first_tail_x8_r0_body.cws33 ++ PRE_first_tail_x8_r0_body.ws33).all fun w => e.noVar w) = true

theorem bodyStep33 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15297, 250, 0, 180⟩ bodyM PRE_first_tail_x8_r0_body.s332 PRE_first_tail_x8_r0_body.S332)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15647, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s334 PRE_first_tail_x8_r0_body.S334) (3452 + 1) :=
  bodySite bodyFacts33.cfix bodyFacts33.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x8_r0_body.st33.S3.tab) (Es := bodyEs33) (qs := bodyQs33)
    (ok := PRE_first_tail_x8_r0_body.st33.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site33 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts33
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site33 r hr) hi (MapOk.sub hm (sub_of_all bodySub33)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk33 r hr) hi hm ho hq)
    bodyLq33 rfl bodyNrLo33 (postSub_sound bodyPost33)
    (Nat.le_of_ble_eq_true bodyDrop33) (by decide) (Nat.le_of_ble_eq_true bodyDropH33) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN33) (by decide)
    bodyDv33 bodyDe33 bodyDl33 bodyDold33 bodyDfree33 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site34 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site34 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site34) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st34.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site34
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st34.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st34.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s340 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s341 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S340 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws34 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st34.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st34.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso34
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_34
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st34.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot34
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup34
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound34
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace34
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged34
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws34.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st34.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S340.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_34]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen34.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh34
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl34 : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s340.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl34 (PRE_first_tail_x8_r0_body.cncl33 bodyNcl33)

theorem bodyClean34 : Conv.JClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s340 :=
  PRE_first_tail_x8_r0_body.gjcl34 (PRE_first_tail_x8_r0_body.cjcl33 bodyClean33)

kernel_rfl bodyJsLe34 : Nat.ble PRE_first_tail_x8_r0_body.s332.next PRE_first_tail_x8_r0_body.s340.next = true
kernel_rfl bodyJsList34 : (PRE_first_tail_x8_r0_body.gjh34 ++ PRE_first_tail_x8_r0_body.cl34).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s340.next) PRE_first_tail_x8_r0_body.s342) = true
theorem bodyJs34 : JsHeapAbove PRE_first_tail_x8_r0_body.s340.next PRE_first_tail_x8_r0_body.s342 :=
  JsHeapAbove.glueSite bodyJs33 (Nat.le_of_ble_eq_true bodyJsLe34) PRE_first_tail_x8_r0_body.gjk34 PRE_first_tail_x8_r0_body.gjbd34 PRE_first_tail_x8_r0_body.cheap34 PRE_first_tail_x8_r0_body.zclbd34 bodyJsList34

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO334 : PRE_first_tail_x8_r0_body.S334.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S334.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr334 : bridgeOf PRE_first_tail_x8_r0_body.s334.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc334 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s334 PRE_first_tail_x8_r0_body.S334) = fun _ _ => true
kernel_rfl bodyAcc335 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s335 PRE_first_tail_x8_r0_body.S335) = fun _ _ => true
kernel_rfl bodyBr336 : bridgeOf PRE_first_tail_x8_r0_body.s336.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt335 : isHalt PRE_first_tail_x8_r0_body.s335.ctl = false
kernel_rfl bodyTop336 : noRetBlock PRE_first_tail_x8_r0_body.s336 = true
kernel_rfl bodyCnt334 : countersOkB PRE_first_tail_x8_r0_body.s334 PRE_first_tail_x8_r0_body.s336 = true
kernel_rfl bodyO336 : PRE_first_tail_x8_r0_body.S336.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S336.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr337 : bridgeOf PRE_first_tail_x8_r0_body.s337.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt336 : countersOkB PRE_first_tail_x8_r0_body.s336 PRE_first_tail_x8_r0_body.s337 = true
kernel_rfl bodyO337 : PRE_first_tail_x8_r0_body.S337.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S337.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc337 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s337 PRE_first_tail_x8_r0_body.S337) = fun _ _ => true
kernel_rfl bodyAcc339 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s339 PRE_first_tail_x8_r0_body.S339) = fun _ _ => true
kernel_rfl bodyBr340 : bridgeOf PRE_first_tail_x8_r0_body.s340.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt339 : isHalt PRE_first_tail_x8_r0_body.s339.ctl = false
kernel_rfl bodyTop340 : noRetBlock PRE_first_tail_x8_r0_body.s340 = true
kernel_rfl bodyCnt337 : countersOkB PRE_first_tail_x8_r0_body.s337 PRE_first_tail_x8_r0_body.s340 = true

theorem bodyGlue34 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15647, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s334 PRE_first_tail_x8_r0_body.S334)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15647, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s340 PRE_first_tail_x8_r0_body.S340) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15647, 252, 0, 189⟩) bodyAcc334 PRE_first_tail_x8_r0_body.bodyRunSeg90 bodyAcc335 bodyHalt335 PRE_first_tail_x8_r0_body.bodyStepA91 bodyTop336 (fun _ hm => bodyO334 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr334).trans bodyInactive0) (bodyBr336.trans bodyBr334.symm) bodyCnt334 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15647, 252, 0, 189⟩) PRE_first_tail_x8_r0_body.sizeA91 PRE_first_tail_x8_r0_body.sizeArgsA91 PRE_first_tail_x8_r0_body.sizeSymA91 PRE_first_tail_x8_r0_body.sizeMlxA91 PRE_first_tail_x8_r0_body.sizePayA91 PRE_first_tail_x8_r0_body.sizeTaA91 PRE_first_tail_x8_r0_body.sizeDecA91 PRE_first_tail_x8_r0_body.sizePreA91 PRE_first_tail_x8_r0_body.bodyPatchB91 (fun _ hm => bodyO336 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr336).trans bodyInactive0) (bodyBr337.trans bodyBr336.symm) bodyCnt336 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15647, 252, 0, 189⟩) bodyAcc337 PRE_first_tail_x8_r0_body.bodyRunSeg91 bodyAcc339 bodyHalt339 PRE_first_tail_x8_r0_body.bodyStepA92 bodyTop340 (fun _ hm => bodyO337 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr337).trans bodyInactive0) (bodyBr340.trans bodyBr337.symm) bodyCnt337 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift34 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S340.tab.length PRE_first_tail_x8_r0_body.s340.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P34.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P34 1532 PRE_first_tail_x8_r0_body.kappa34 PRE_first_tail_x8_r0_body.s342.ffi PRE_first_tail_x8_r0_body.s341.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_34
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_34
  have hcl : SSt (· < 1532) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s342.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S340.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_34] <;> decide) PRE_first_tail_x8_r0_body.cnodesK34 PRE_first_tail_x8_r0_body.cobjsK34
      PRE_first_tail_x8_r0_body.citemsK34 PRE_first_tail_x8_r0_body.cbd34 PRE_first_tail_x8_r0_body.csst34
  exact PRE_first_tail_x8_r0_body.cshift34 bodyNcl34 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_34] at this; exact this)


kernel_rfl bodyFramesEmpty34 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s341 a).isEmpty) = true
kernel_rfl bodyJsRoots34 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s340.next) PRE_first_tail_x8_r0_body.s342.trace PRE_first_tail_x8_r0_body.s342 = true
kernel_rfl bodyJsNative34 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s342.ffi) = true
kernel_rfl bodyLow34 : (PRE_first_tail_x8_r0_body.cws34 ++ PRE_first_tail_x8_r0_body.ws34).all (Nat.ble 9) = true
kernel_rfl bodyCntM34 : countersOkB PRE_first_tail_x8_r0_body.s340 PRE_first_tail_x8_r0_body.s341 = true
kernel_rfl bodyHi34 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s342.ffi).next setupP.E = true
kernel_rfl bodyNhi34 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s342.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge34 : bridgeOf PRE_first_tail_x8_r0_body.s341.ffi = bridgeOf PRE_first_tail_x8_r0_body.s340.ffi
kernel_rfl bodyNN34 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s340.ffi).nnext PRE_first_tail_x8_r0_body.P34.NL = true
kernel_rfl bodyXn34 : Nat.ble (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s342.ffi).next = true
kernel_rfl bodyLo34 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s342.ffi).next = true
theorem bodyFacts34 : BodySiteFacts PRE_first_tail_x8_r0_body.s340 PRE_first_tail_x8_r0_body.s341 PRE_first_tail_x8_r0_body.s342 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S340 PRE_first_tail_x8_r0_body.S341 PRE_first_tail_x8_r0_body.S342
    PRE_first_tail_x8_r0_body.ws34 PRE_first_tail_x8_r0_body.cws34 PRE_first_tail_x8_r0_body.nr34 PRE_first_tail_x8_r0_body.pl34 PRE_first_tail_x8_r0_body.cl34 2701919 1532 PRE_first_tail_x8_r0_body.kd34 PRE_first_tail_x8_r0_body.kappa34 PRE_first_tail_x8_r0_body.P34
    ⟨18882, 15966, 2701917, 1532⟩ ⟨18882, 15966, 2701917, 1532⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap34
  clean := bodyClean34
  cfix := PRE_first_tail_x8_r0_body.cfix34
  zpl := PRE_first_tail_x8_r0_body.zpl34
  zplnd := PRE_first_tail_x8_r0_body.zplnd34
  zn1 := PRE_first_tail_x8_r0_body.zn134
  zfirst := PRE_first_tail_x8_r0_body.zfirst34
  zscn := PRE_first_tail_x8_r0_body.zscn34
  zsmn := PRE_first_tail_x8_r0_body.zsmn34
  zgrow := PRE_first_tail_x8_r0_body.zgrow34
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab34
  zfresh := PRE_first_tail_x8_r0_body.zfresh34
  zcnd := PRE_first_tail_x8_r0_body.zcnd34
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi34
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt34
  zgP := PRE_first_tail_x8_r0_body.zg34_2665
  zkP := PRE_first_tail_x8_r0_body.zk34_2665
  zmP := PRE_first_tail_x8_r0_body.zm34_2665
  zgC := PRE_first_tail_x8_r0_body.zg34_2673467
  zkC := PRE_first_tail_x8_r0_body.zk34_2673467
  zmC := PRE_first_tail_x8_r0_body.zm34_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw34_2673472
  zwV := PRE_first_tail_x8_r0_body.zw34_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap34
  zclbd := PRE_first_tail_x8_r0_body.zclbd34
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap34 PRE_first_tail_x8_r0_body.stFoot34 PRE_first_tail_x8_r0_body.iso34 PRE_first_tail_x8_r0_body.zwr34
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP34
  csupp := PRE_first_tail_x8_r0_body.csupp34
  cbound := PRE_first_tail_x8_r0_body.cbound34
  zimg := PRE_first_tail_x8_r0_body.zimg34
  zctl := PRE_first_tail_x8_r0_body.zctl34
  zstack := PRE_first_tail_x8_r0_body.zstack34
  zjobs := PRE_first_tail_x8_r0_body.zjobs34
  zstores := PRE_first_tail_x8_r0_body.zstores34
  zroots := PRE_first_tail_x8_r0_body.zroots34
  znC := PRE_first_tail_x8_r0_body.znC34
  ctab := PRE_first_tail_x8_r0_body.ctab34
  zbin := PRE_first_tail_x8_r0_body.zbin34
  cbridge := PRE_first_tail_x8_r0_body.cbridge34
  sbridge := bodyBridge34
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj34
  cshiftR := fun h hNL => bodyCshift34 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN34
  raised := PRE_first_tail_x8_r0_body.raised34
  cbigs := PRE_first_tail_x8_r0_body.cbigs34
  cjcl := PRE_first_tail_x8_r0_body.cjcl34
  xnLe := Nat.le_of_ble_eq_true bodyXn34
  loLe := Nat.le_of_ble_eq_true bodyLo34
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB34
  cntM := bodyCntM34
  hiLe := Nat.le_of_ble_eq_true bodyHi34
  nhiLe := Nat.le_of_ble_eq_true bodyNhi34
  jsHeap := bodyJs34
  jsRoots := bodyJsRoots34
  jsNative := bodyJsNative34
  framesEmpty := bodyFramesEmpty34
  trailOld := by decide
  lowVars := bodyLow34

def bodyQs34 : List (Option Q) := []
noncomputable def bodyEs34 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr34.map fun r => nth? PRE_first_tail_x8_r0_body.st34.S2.tab r
kernel_rfl bodyResChk34 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs34 bodyQs34) = true
kernel_rfl bodyLq34 : bodyQs34.length = PRE_first_tail_x8_r0_body.cws34.length
kernel_rfl bodyNrLo34 : PRE_first_tail_x8_r0_body.nr34.all (Nat.ble PRE_first_tail_x8_r0_body.S340.tab.length) = true
kernel_rfl bodySub34 : (Oracles.PRE_first_tail_x8_r0_body.map_site34.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost34 : postSubB bodyM PRE_first_tail_x8_r0_body.ws34 PRE_first_tail_x8_r0_body.cws34 bodyQs34 = true
kernel_rfl bodyDrop34 : Nat.ble (15647 + (PRE_first_tail_x8_r0_body.s341.next - PRE_first_tail_x8_r0_body.s342.next)) 15649 = true
kernel_rfl bodyDropH34 : Nat.ble (252 + ((mlxOf PRE_first_tail_x8_r0_body.s341.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s342.ffi).next)) 252 = true
kernel_rfl bodyDropN34 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s341.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s342.ffi).nnext)) 0 = true
kernel_rfl bodyDv34 : bodyΘ.1.take 189 = bodyΘ.1.take 189 ++ PRE_first_tail_x8_r0_body.cws34
kernel_rfl bodyDe34 : bodyΘ.2.take 189 = bodyΘ.2.take 189 ++ PRE_first_tail_x8_r0_body.nr34.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st34.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 189) (bodyΘ.2.take 189)))
kernel_rfl bodyDl34 : (bodyΘ.1.take 189).length = (bodyΘ.2.take 189).length
kernel_rfl bodyDold34 : (bodyΘ.1.take 189).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws34).isNone && !PRE_first_tail_x8_r0_body.ws34.contains v) = true
kernel_rfl bodyDfree34 : (bodyΘ.2.take 189).all (fun e => (PRE_first_tail_x8_r0_body.cws34 ++ PRE_first_tail_x8_r0_body.ws34).all fun w => e.noVar w) = true

theorem bodyStep34 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15647, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s340 PRE_first_tail_x8_r0_body.S340)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15649, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s342 PRE_first_tail_x8_r0_body.S342) (27 + 1) :=
  bodySite bodyFacts34.cfix bodyFacts34.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x8_r0_body.st34.S2.tab) (Es := bodyEs34) (qs := bodyQs34)
    (ok := PRE_first_tail_x8_r0_body.st34.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site34 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts34
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site34 r hr) hi (MapOk.sub hm (sub_of_all bodySub34)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk34 r hr) hi hm ho hq)
    bodyLq34 rfl bodyNrLo34 (postSub_sound bodyPost34)
    (Nat.le_of_ble_eq_true bodyDrop34) (by decide) (Nat.le_of_ble_eq_true bodyDropH34) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN34) (by decide)
    bodyDv34 bodyDe34 bodyDl34 bodyDold34 bodyDfree34 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site35 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site35 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site35) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site35
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s344 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s345 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S344 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws35 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso35
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_35
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot35
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup35
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound35
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace35
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged35
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws35.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st35.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S344.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_35]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen35.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh35
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl35 : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s344.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl35 (PRE_first_tail_x8_r0_body.cncl34 bodyNcl34)

theorem bodyClean35 : Conv.JClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s344 :=
  PRE_first_tail_x8_r0_body.gjcl35 (PRE_first_tail_x8_r0_body.cjcl34 bodyClean34)

kernel_rfl bodyJsLe35 : Nat.ble PRE_first_tail_x8_r0_body.s340.next PRE_first_tail_x8_r0_body.s344.next = true
kernel_rfl bodyJsList35 : (PRE_first_tail_x8_r0_body.gjh35 ++ PRE_first_tail_x8_r0_body.cl35).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s344.next) PRE_first_tail_x8_r0_body.s346) = true
theorem bodyJs35 : JsHeapAbove PRE_first_tail_x8_r0_body.s344.next PRE_first_tail_x8_r0_body.s346 :=
  JsHeapAbove.glueSite bodyJs34 (Nat.le_of_ble_eq_true bodyJsLe35) PRE_first_tail_x8_r0_body.gjk35 PRE_first_tail_x8_r0_body.gjbd35 PRE_first_tail_x8_r0_body.cheap35 PRE_first_tail_x8_r0_body.zclbd35 bodyJsList35

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO342 : PRE_first_tail_x8_r0_body.S342.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S342.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr342 : bridgeOf PRE_first_tail_x8_r0_body.s342.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc342 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s342 PRE_first_tail_x8_r0_body.S342) = fun _ _ => true
kernel_rfl bodyAcc343 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s343 PRE_first_tail_x8_r0_body.S343) = fun _ _ => true
kernel_rfl bodyBr344 : bridgeOf PRE_first_tail_x8_r0_body.s344.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt343 : isHalt PRE_first_tail_x8_r0_body.s343.ctl = false
kernel_rfl bodyTop344 : noRetBlock PRE_first_tail_x8_r0_body.s344 = true
kernel_rfl bodyCnt342 : countersOkB PRE_first_tail_x8_r0_body.s342 PRE_first_tail_x8_r0_body.s344 = true

theorem bodyGlue35 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15649, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s342 PRE_first_tail_x8_r0_body.S342)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15649, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s344 PRE_first_tail_x8_r0_body.S344) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15649, 252, 0, 189⟩) bodyAcc342 PRE_first_tail_x8_r0_body.bodyRunSeg92 bodyAcc343 bodyHalt343 PRE_first_tail_x8_r0_body.bodyStepA93 bodyTop344 (fun _ hm => bodyO342 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr342).trans bodyInactive0) (bodyBr344.trans bodyBr342.symm) bodyCnt342 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift35 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S344.tab.length PRE_first_tail_x8_r0_body.s344.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P35.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P35 1549 PRE_first_tail_x8_r0_body.kappa35 PRE_first_tail_x8_r0_body.s346.ffi PRE_first_tail_x8_r0_body.s345.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_35
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_35
  have hcl : SSt (· < 1549) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s346.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S344.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_35] <;> decide) PRE_first_tail_x8_r0_body.cnodesK35 PRE_first_tail_x8_r0_body.cobjsK35
      PRE_first_tail_x8_r0_body.citemsK35 PRE_first_tail_x8_r0_body.cbd35 PRE_first_tail_x8_r0_body.csst35
  exact PRE_first_tail_x8_r0_body.cshift35 bodyNcl35 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_35] at this; exact this)


kernel_rfl bodyFramesEmpty35 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s345 a).isEmpty) = true
kernel_rfl bodyJsRoots35 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s344.next) PRE_first_tail_x8_r0_body.s346.trace PRE_first_tail_x8_r0_body.s346 = true
kernel_rfl bodyJsNative35 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s346.ffi) = true
kernel_rfl bodyLow35 : (PRE_first_tail_x8_r0_body.cws35 ++ PRE_first_tail_x8_r0_body.ws35).all (Nat.ble 9) = true
kernel_rfl bodyCntM35 : countersOkB PRE_first_tail_x8_r0_body.s344 PRE_first_tail_x8_r0_body.s345 = true
kernel_rfl bodyHi35 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s346.ffi).next setupP.E = true
kernel_rfl bodyNhi35 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s346.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge35 : bridgeOf PRE_first_tail_x8_r0_body.s345.ffi = bridgeOf PRE_first_tail_x8_r0_body.s344.ffi
kernel_rfl bodyNN35 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s344.ffi).nnext PRE_first_tail_x8_r0_body.P35.NL = true
kernel_rfl bodyXn35 : Nat.ble (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s346.ffi).next = true
kernel_rfl bodyLo35 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s346.ffi).next = true
theorem bodyFacts35 : BodySiteFacts PRE_first_tail_x8_r0_body.s344 PRE_first_tail_x8_r0_body.s345 PRE_first_tail_x8_r0_body.s346 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S344 PRE_first_tail_x8_r0_body.S345 PRE_first_tail_x8_r0_body.S346
    PRE_first_tail_x8_r0_body.ws35 PRE_first_tail_x8_r0_body.cws35 PRE_first_tail_x8_r0_body.nr35 PRE_first_tail_x8_r0_body.pl35 PRE_first_tail_x8_r0_body.cl35 2702226 1549 PRE_first_tail_x8_r0_body.kd35 PRE_first_tail_x8_r0_body.kappa35 PRE_first_tail_x8_r0_body.P35
    ⟨18889, 15970, 2702205, 1549⟩ ⟨18889, 15970, 2702206, 1549⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap35
  clean := bodyClean35
  cfix := PRE_first_tail_x8_r0_body.cfix35
  zpl := PRE_first_tail_x8_r0_body.zpl35
  zplnd := PRE_first_tail_x8_r0_body.zplnd35
  zn1 := PRE_first_tail_x8_r0_body.zn135
  zfirst := PRE_first_tail_x8_r0_body.zfirst35
  zscn := PRE_first_tail_x8_r0_body.zscn35
  zsmn := PRE_first_tail_x8_r0_body.zsmn35
  zgrow := PRE_first_tail_x8_r0_body.zgrow35
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab35
  zfresh := PRE_first_tail_x8_r0_body.zfresh35
  zcnd := PRE_first_tail_x8_r0_body.zcnd35
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi35
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt35
  zgP := PRE_first_tail_x8_r0_body.zg35_2665
  zkP := PRE_first_tail_x8_r0_body.zk35_2665
  zmP := PRE_first_tail_x8_r0_body.zm35_2665
  zgC := PRE_first_tail_x8_r0_body.zg35_2673467
  zkC := PRE_first_tail_x8_r0_body.zk35_2673467
  zmC := PRE_first_tail_x8_r0_body.zm35_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw35_2673472
  zwV := PRE_first_tail_x8_r0_body.zw35_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap35
  zclbd := PRE_first_tail_x8_r0_body.zclbd35
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap35 PRE_first_tail_x8_r0_body.stFoot35 PRE_first_tail_x8_r0_body.iso35 PRE_first_tail_x8_r0_body.zwr35
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP35
  csupp := PRE_first_tail_x8_r0_body.csupp35
  cbound := PRE_first_tail_x8_r0_body.cbound35
  zimg := PRE_first_tail_x8_r0_body.zimg35
  zctl := PRE_first_tail_x8_r0_body.zctl35
  zstack := PRE_first_tail_x8_r0_body.zstack35
  zjobs := PRE_first_tail_x8_r0_body.zjobs35
  zstores := PRE_first_tail_x8_r0_body.zstores35
  zroots := PRE_first_tail_x8_r0_body.zroots35
  znC := PRE_first_tail_x8_r0_body.znC35
  ctab := PRE_first_tail_x8_r0_body.ctab35
  zbin := PRE_first_tail_x8_r0_body.zbin35
  cbridge := PRE_first_tail_x8_r0_body.cbridge35
  sbridge := bodyBridge35
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj35
  cshiftR := fun h hNL => bodyCshift35 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN35
  raised := PRE_first_tail_x8_r0_body.raised35
  cbigs := PRE_first_tail_x8_r0_body.cbigs35
  cjcl := PRE_first_tail_x8_r0_body.cjcl35
  xnLe := Nat.le_of_ble_eq_true bodyXn35
  loLe := Nat.le_of_ble_eq_true bodyLo35
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB35
  cntM := bodyCntM35
  hiLe := Nat.le_of_ble_eq_true bodyHi35
  nhiLe := Nat.le_of_ble_eq_true bodyNhi35
  jsHeap := bodyJs35
  jsRoots := bodyJsRoots35
  jsNative := bodyJsNative35
  framesEmpty := bodyFramesEmpty35
  trailOld := by decide
  lowVars := bodyLow35

def bodyQs35 : List (Option Q) := []
noncomputable def bodyEs35 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr35.map fun r => nth? PRE_first_tail_x8_r0_body.st35.S2.tab r
kernel_rfl bodyResChk35 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs35 bodyQs35) = true
kernel_rfl bodyLq35 : bodyQs35.length = PRE_first_tail_x8_r0_body.cws35.length
kernel_rfl bodyNrLo35 : PRE_first_tail_x8_r0_body.nr35.all (Nat.ble PRE_first_tail_x8_r0_body.S344.tab.length) = true
kernel_rfl bodySub35 : (Oracles.PRE_first_tail_x8_r0_body.map_site35.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost35 : postSubB bodyM PRE_first_tail_x8_r0_body.ws35 PRE_first_tail_x8_r0_body.cws35 bodyQs35 = true
kernel_rfl bodyDrop35 : Nat.ble (15649 + (PRE_first_tail_x8_r0_body.s345.next - PRE_first_tail_x8_r0_body.s346.next)) 15669 = true
kernel_rfl bodyDropH35 : Nat.ble (252 + ((mlxOf PRE_first_tail_x8_r0_body.s345.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s346.ffi).next)) 252 = true
kernel_rfl bodyDropN35 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s345.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s346.ffi).nnext)) 0 = true
kernel_rfl bodyDv35 : bodyΘ.1.take 189 = bodyΘ.1.take 189 ++ PRE_first_tail_x8_r0_body.cws35
kernel_rfl bodyDe35 : bodyΘ.2.take 189 = bodyΘ.2.take 189 ++ PRE_first_tail_x8_r0_body.nr35.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st35.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 189) (bodyΘ.2.take 189)))
kernel_rfl bodyDl35 : (bodyΘ.1.take 189).length = (bodyΘ.2.take 189).length
kernel_rfl bodyDold35 : (bodyΘ.1.take 189).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws35).isNone && !PRE_first_tail_x8_r0_body.ws35.contains v) = true
kernel_rfl bodyDfree35 : (bodyΘ.2.take 189).all (fun e => (PRE_first_tail_x8_r0_body.cws35 ++ PRE_first_tail_x8_r0_body.ws35).all fun w => e.noVar w) = true

theorem bodyStep35 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15649, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s344 PRE_first_tail_x8_r0_body.S344)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15669, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s346 PRE_first_tail_x8_r0_body.S346) (214 + 1) :=
  bodySite bodyFacts35.cfix bodyFacts35.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 214) (S2 := PRE_first_tail_x8_r0_body.st35.S2.tab) (Es := bodyEs35) (qs := bodyQs35)
    (ok := PRE_first_tail_x8_r0_body.st35.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site35 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts35
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site35 r hr) hi (MapOk.sub hm (sub_of_all bodySub35)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk35 r hr) hi hm ho hq)
    bodyLq35 rfl bodyNrLo35 (postSub_sound bodyPost35)
    (Nat.le_of_ble_eq_true bodyDrop35) (by decide) (Nat.le_of_ble_eq_true bodyDropH35) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN35) (by decide)
    bodyDv35 bodyDe35 bodyDl35 bodyDold35 bodyDfree35 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyOracles_9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_g36 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g36 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g36) (List.take 16 (List.drop 352 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site36 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site36 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site36) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st36.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g37 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g37 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g37) (List.take 7 (List.drop 368 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site37 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site37 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site37) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st37.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g38 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g38 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g38) (List.take 3 (List.drop 375 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site38 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site38 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site38) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g39 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g39 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g39) (List.take 16 (List.drop 378 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site39 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site39 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site39) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st39.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site36 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site36 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site36) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st36.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site36
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st36.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st36.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s361 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s362 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S361 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws36 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st36.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st36.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso36
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_36
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st36.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot36
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup36
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound36
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace36
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged36
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws36.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st36.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S361.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_36]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen36.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh36
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl36 : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s361.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl36 (PRE_first_tail_x8_r0_body.cncl35 bodyNcl35)

theorem bodyClean36 : Conv.JClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s361 :=
  PRE_first_tail_x8_r0_body.gjcl36 (PRE_first_tail_x8_r0_body.cjcl35 bodyClean35)

kernel_rfl bodyJsLe36 : Nat.ble PRE_first_tail_x8_r0_body.s344.next PRE_first_tail_x8_r0_body.s361.next = true
kernel_rfl bodyJsList36 : (PRE_first_tail_x8_r0_body.gjh36 ++ PRE_first_tail_x8_r0_body.cl36).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s361.next) PRE_first_tail_x8_r0_body.s363) = true
theorem bodyJs36 : JsHeapAbove PRE_first_tail_x8_r0_body.s361.next PRE_first_tail_x8_r0_body.s363 :=
  JsHeapAbove.glueSite bodyJs35 (Nat.le_of_ble_eq_true bodyJsLe36) PRE_first_tail_x8_r0_body.gjk36 PRE_first_tail_x8_r0_body.gjbd36 PRE_first_tail_x8_r0_body.cheap36 PRE_first_tail_x8_r0_body.zclbd36 bodyJsList36

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO346 : PRE_first_tail_x8_r0_body.S346.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S346.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr346 : bridgeOf PRE_first_tail_x8_r0_body.s346.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc346 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s346 PRE_first_tail_x8_r0_body.S346) = fun _ _ => true
kernel_rfl bodyAcc348 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s348 PRE_first_tail_x8_r0_body.S348) = fun _ _ => true
kernel_rfl bodyBr349 : bridgeOf PRE_first_tail_x8_r0_body.s349.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt348 : isHalt PRE_first_tail_x8_r0_body.s348.ctl = false
kernel_rfl bodyTop349 : noRetBlock PRE_first_tail_x8_r0_body.s349 = true
kernel_rfl bodyCnt346 : countersOkB PRE_first_tail_x8_r0_body.s346 PRE_first_tail_x8_r0_body.s349 = true
kernel_rfl bodyO349 : PRE_first_tail_x8_r0_body.S349.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S349.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr350 : bridgeOf PRE_first_tail_x8_r0_body.s350.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt349 : countersOkB PRE_first_tail_x8_r0_body.s349 PRE_first_tail_x8_r0_body.s350 = true
kernel_rfl bodyO350 : PRE_first_tail_x8_r0_body.S350.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S350.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc350 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s350 PRE_first_tail_x8_r0_body.S350) = fun _ _ => true
kernel_rfl bodyAcc351 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s351 PRE_first_tail_x8_r0_body.S351) = fun _ _ => true
kernel_rfl bodyBr352 : bridgeOf PRE_first_tail_x8_r0_body.s352.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt351 : isHalt PRE_first_tail_x8_r0_body.s351.ctl = false
kernel_rfl bodyTop352 : noRetBlock PRE_first_tail_x8_r0_body.s352 = true
kernel_rfl bodyCnt350 : countersOkB PRE_first_tail_x8_r0_body.s350 PRE_first_tail_x8_r0_body.s352 = true
kernel_rfl bodyO352 : PRE_first_tail_x8_r0_body.S352.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S352.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr353 : bridgeOf PRE_first_tail_x8_r0_body.s353.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt352 : countersOkB PRE_first_tail_x8_r0_body.s352 PRE_first_tail_x8_r0_body.s353 = true
kernel_rfl bodyO353 : PRE_first_tail_x8_r0_body.S353.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S353.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc353 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s353 PRE_first_tail_x8_r0_body.S353) = fun _ _ => true
kernel_rfl bodyAcc354 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s354 PRE_first_tail_x8_r0_body.S354) = fun _ _ => true
kernel_rfl bodyBr355 : bridgeOf PRE_first_tail_x8_r0_body.s355.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt354 : isHalt PRE_first_tail_x8_r0_body.s354.ctl = false
kernel_rfl bodyTop355 : noRetBlock PRE_first_tail_x8_r0_body.s355 = true
kernel_rfl bodyCnt353 : countersOkB PRE_first_tail_x8_r0_body.s353 PRE_first_tail_x8_r0_body.s355 = true
kernel_rfl bodyO355 : PRE_first_tail_x8_r0_body.S355.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S355.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr356 : bridgeOf PRE_first_tail_x8_r0_body.s356.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt355 : countersOkB PRE_first_tail_x8_r0_body.s355 PRE_first_tail_x8_r0_body.s356 = true
kernel_rfl bodyO356 : PRE_first_tail_x8_r0_body.S356.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S356.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc356 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s356 PRE_first_tail_x8_r0_body.S356) = fun _ _ => true
kernel_rfl bodyAcc357 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s357 PRE_first_tail_x8_r0_body.S357) = fun _ _ => true
kernel_rfl bodyBr358 : bridgeOf PRE_first_tail_x8_r0_body.s358.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt357 : isHalt PRE_first_tail_x8_r0_body.s357.ctl = false
kernel_rfl bodyTop358 : noRetBlock PRE_first_tail_x8_r0_body.s358 = true
kernel_rfl bodyCnt356 : countersOkB PRE_first_tail_x8_r0_body.s356 PRE_first_tail_x8_r0_body.s358 = true
kernel_rfl bodyO358 : PRE_first_tail_x8_r0_body.S358.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S358.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr359 : bridgeOf PRE_first_tail_x8_r0_body.s359.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt358 : countersOkB PRE_first_tail_x8_r0_body.s358 PRE_first_tail_x8_r0_body.s359 = true
kernel_rfl bodyO359 : PRE_first_tail_x8_r0_body.S359.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S359.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc359 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s359 PRE_first_tail_x8_r0_body.S359) = fun _ _ => true
kernel_rfl bodyAcc360 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s360 PRE_first_tail_x8_r0_body.S360) = fun _ _ => true
kernel_rfl bodyBr361 : bridgeOf PRE_first_tail_x8_r0_body.s361.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt360 : isHalt PRE_first_tail_x8_r0_body.s360.ctl = false
kernel_rfl bodyTop361 : noRetBlock PRE_first_tail_x8_r0_body.s361 = true
kernel_rfl bodyCnt359 : countersOkB PRE_first_tail_x8_r0_body.s359 PRE_first_tail_x8_r0_body.s361 = true

theorem bodyGlue36 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15669, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s346 PRE_first_tail_x8_r0_body.S346)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15669, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s361 PRE_first_tail_x8_r0_body.S361) 14768 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) bodyAcc346 PRE_first_tail_x8_r0_body.bodyRunSeg93 bodyAcc348 bodyHalt348 PRE_first_tail_x8_r0_body.bodyStepA94 bodyTop349 (fun _ hm => bodyO346 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr346).trans bodyInactive0) (bodyBr349.trans bodyBr346.symm) bodyCnt346 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) PRE_first_tail_x8_r0_body.sizeA94 PRE_first_tail_x8_r0_body.sizeArgsA94 PRE_first_tail_x8_r0_body.sizeSymA94 PRE_first_tail_x8_r0_body.sizeMlxA94 PRE_first_tail_x8_r0_body.sizePayA94 PRE_first_tail_x8_r0_body.sizeTaA94 PRE_first_tail_x8_r0_body.sizeDecA94 PRE_first_tail_x8_r0_body.sizePreA94 PRE_first_tail_x8_r0_body.bodyPatchB94 (fun _ hm => bodyO349 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr349).trans bodyInactive0) (bodyBr350.trans bodyBr349.symm) bodyCnt349 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) bodyAcc350 PRE_first_tail_x8_r0_body.bodyRunSeg94 bodyAcc351 bodyHalt351 PRE_first_tail_x8_r0_body.bodyStepA95 bodyTop352 (fun _ hm => bodyO350 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr350).trans bodyInactive0) (bodyBr352.trans bodyBr350.symm) bodyCnt350 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) PRE_first_tail_x8_r0_body.sizeA95 PRE_first_tail_x8_r0_body.sizeArgsA95 PRE_first_tail_x8_r0_body.sizeSymA95 PRE_first_tail_x8_r0_body.sizeMlxA95 PRE_first_tail_x8_r0_body.sizePayA95 PRE_first_tail_x8_r0_body.sizeTaA95 PRE_first_tail_x8_r0_body.sizeDecA95 PRE_first_tail_x8_r0_body.sizePreA95 PRE_first_tail_x8_r0_body.bodyPatchB95 (fun _ hm => bodyO352 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr352).trans bodyInactive0) (bodyBr353.trans bodyBr352.symm) bodyCnt352 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) bodyAcc353 PRE_first_tail_x8_r0_body.bodyRunSeg95 bodyAcc354 bodyHalt354 PRE_first_tail_x8_r0_body.bodyStepA96 bodyTop355 (fun _ hm => bodyO353 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr353).trans bodyInactive0) (bodyBr355.trans bodyBr353.symm) bodyCnt353 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) PRE_first_tail_x8_r0_body.sizeA96 PRE_first_tail_x8_r0_body.sizeArgsA96 PRE_first_tail_x8_r0_body.sizeSymA96 PRE_first_tail_x8_r0_body.sizeMlxA96 PRE_first_tail_x8_r0_body.sizePayA96 PRE_first_tail_x8_r0_body.sizeTaA96 PRE_first_tail_x8_r0_body.sizeDecA96 PRE_first_tail_x8_r0_body.sizePreA96 PRE_first_tail_x8_r0_body.bodyPatchB96 (fun _ hm => bodyO355 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr355).trans bodyInactive0) (bodyBr356.trans bodyBr355.symm) bodyCnt355 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) bodyAcc356 PRE_first_tail_x8_r0_body.bodyRunSeg96 bodyAcc357 bodyHalt357 PRE_first_tail_x8_r0_body.bodyStepA97 bodyTop358 (fun _ hm => bodyO356 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr356).trans bodyInactive0) (bodyBr358.trans bodyBr356.symm) bodyCnt356 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) PRE_first_tail_x8_r0_body.sizeA97 PRE_first_tail_x8_r0_body.sizeArgsA97 PRE_first_tail_x8_r0_body.sizeSymA97 PRE_first_tail_x8_r0_body.sizeMlxA97 PRE_first_tail_x8_r0_body.sizePayA97 PRE_first_tail_x8_r0_body.sizeTaA97 PRE_first_tail_x8_r0_body.sizeDecA97 PRE_first_tail_x8_r0_body.sizePreA97 PRE_first_tail_x8_r0_body.bodyPatchB97 (fun _ hm => bodyO358 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr358).trans bodyInactive0) (bodyBr359.trans bodyBr358.symm) bodyCnt358 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15669, 252, 0, 189⟩) bodyAcc359 PRE_first_tail_x8_r0_body.bodyRunSeg97 bodyAcc360 bodyHalt360 PRE_first_tail_x8_r0_body.bodyStepA98 bodyTop361 (fun _ hm => bodyO359 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr359).trans bodyInactive0) (bodyBr361.trans bodyBr359.symm) bodyCnt359 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift36 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S361.tab.length PRE_first_tail_x8_r0_body.s361.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P36.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P36 1640 PRE_first_tail_x8_r0_body.kappa36 PRE_first_tail_x8_r0_body.s363.ffi PRE_first_tail_x8_r0_body.s362.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_36
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_36
  have hcl : SSt (· < 1640) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s363.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S361.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_36] <;> decide) PRE_first_tail_x8_r0_body.cnodesK36 PRE_first_tail_x8_r0_body.cobjsK36
      PRE_first_tail_x8_r0_body.citemsK36 PRE_first_tail_x8_r0_body.cbd36 PRE_first_tail_x8_r0_body.csst36
  exact PRE_first_tail_x8_r0_body.cshift36 bodyNcl36 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_36] at this; exact this)


kernel_rfl bodyFramesEmpty36 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s362 a).isEmpty) = true
kernel_rfl bodyJsRoots36 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s361.next) PRE_first_tail_x8_r0_body.s363.trace PRE_first_tail_x8_r0_body.s363 = true
kernel_rfl bodyJsNative36 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s363.ffi) = true
kernel_rfl bodyLow36 : (PRE_first_tail_x8_r0_body.cws36 ++ PRE_first_tail_x8_r0_body.ws36).all (Nat.ble 9) = true
kernel_rfl bodyCntM36 : countersOkB PRE_first_tail_x8_r0_body.s361 PRE_first_tail_x8_r0_body.s362 = true
kernel_rfl bodyHi36 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s363.ffi).next setupP.E = true
kernel_rfl bodyNhi36 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s363.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge36 : bridgeOf PRE_first_tail_x8_r0_body.s362.ffi = bridgeOf PRE_first_tail_x8_r0_body.s361.ffi
kernel_rfl bodyNN36 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s361.ffi).nnext PRE_first_tail_x8_r0_body.P36.NL = true
kernel_rfl bodyXn36 : Nat.ble (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s363.ffi).next = true
kernel_rfl bodyLo36 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s363.ffi).next = true
theorem bodyFacts36 : BodySiteFacts PRE_first_tail_x8_r0_body.s361 PRE_first_tail_x8_r0_body.s362 PRE_first_tail_x8_r0_body.s363 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S361 PRE_first_tail_x8_r0_body.S362 PRE_first_tail_x8_r0_body.S363
    PRE_first_tail_x8_r0_body.ws36 PRE_first_tail_x8_r0_body.cws36 PRE_first_tail_x8_r0_body.nr36 PRE_first_tail_x8_r0_body.pl36 PRE_first_tail_x8_r0_body.cl36 2704858 1640 PRE_first_tail_x8_r0_body.kd36 PRE_first_tail_x8_r0_body.kappa36 PRE_first_tail_x8_r0_body.P36
    ⟨18924, 15989, 2703703, 1622⟩ ⟨18927, 16016, 2703709, 1640⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap36
  clean := bodyClean36
  cfix := PRE_first_tail_x8_r0_body.cfix36
  zpl := PRE_first_tail_x8_r0_body.zpl36
  zplnd := PRE_first_tail_x8_r0_body.zplnd36
  zn1 := PRE_first_tail_x8_r0_body.zn136
  zfirst := PRE_first_tail_x8_r0_body.zfirst36
  zscn := PRE_first_tail_x8_r0_body.zscn36
  zsmn := PRE_first_tail_x8_r0_body.zsmn36
  zgrow := PRE_first_tail_x8_r0_body.zgrow36
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab36
  zfresh := PRE_first_tail_x8_r0_body.zfresh36
  zcnd := PRE_first_tail_x8_r0_body.zcnd36
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi36
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt36
  zgP := PRE_first_tail_x8_r0_body.zg36_2665
  zkP := PRE_first_tail_x8_r0_body.zk36_2665
  zmP := PRE_first_tail_x8_r0_body.zm36_2665
  zgC := PRE_first_tail_x8_r0_body.zg36_2673467
  zkC := PRE_first_tail_x8_r0_body.zk36_2673467
  zmC := PRE_first_tail_x8_r0_body.zm36_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw36_2673472
  zwV := PRE_first_tail_x8_r0_body.zw36_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap36
  zclbd := PRE_first_tail_x8_r0_body.zclbd36
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap36 PRE_first_tail_x8_r0_body.stFoot36 PRE_first_tail_x8_r0_body.iso36 PRE_first_tail_x8_r0_body.zwr36
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP36
  csupp := PRE_first_tail_x8_r0_body.csupp36
  cbound := PRE_first_tail_x8_r0_body.cbound36
  zimg := PRE_first_tail_x8_r0_body.zimg36
  zctl := PRE_first_tail_x8_r0_body.zctl36
  zstack := PRE_first_tail_x8_r0_body.zstack36
  zjobs := PRE_first_tail_x8_r0_body.zjobs36
  zstores := PRE_first_tail_x8_r0_body.zstores36
  zroots := PRE_first_tail_x8_r0_body.zroots36
  znC := PRE_first_tail_x8_r0_body.znC36
  ctab := PRE_first_tail_x8_r0_body.ctab36
  zbin := PRE_first_tail_x8_r0_body.zbin36
  cbridge := PRE_first_tail_x8_r0_body.cbridge36
  sbridge := bodyBridge36
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj36
  cshiftR := fun h hNL => bodyCshift36 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN36
  raised := PRE_first_tail_x8_r0_body.raised36
  cbigs := PRE_first_tail_x8_r0_body.cbigs36
  cjcl := PRE_first_tail_x8_r0_body.cjcl36
  xnLe := Nat.le_of_ble_eq_true bodyXn36
  loLe := Nat.le_of_ble_eq_true bodyLo36
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB36
  cntM := bodyCntM36
  hiLe := Nat.le_of_ble_eq_true bodyHi36
  nhiLe := Nat.le_of_ble_eq_true bodyNhi36
  jsHeap := bodyJs36
  jsRoots := bodyJsRoots36
  jsNative := bodyJsNative36
  framesEmpty := bodyFramesEmpty36
  trailOld := by decide
  lowVars := bodyLow36

def bodyQs36 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs36 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr36.map fun r => nth? PRE_first_tail_x8_r0_body.st36.S5.tab r
kernel_rfl bodyResChk36 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs36 bodyQs36) = true
kernel_rfl bodyLq36 : bodyQs36.length = PRE_first_tail_x8_r0_body.cws36.length
kernel_rfl bodyNrLo36 : PRE_first_tail_x8_r0_body.nr36.all (Nat.ble PRE_first_tail_x8_r0_body.S361.tab.length) = true
kernel_rfl bodySub36 : (Oracles.PRE_first_tail_x8_r0_body.map_site36.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost36 : postSubB bodyM PRE_first_tail_x8_r0_body.ws36 PRE_first_tail_x8_r0_body.cws36 bodyQs36 = true
kernel_rfl bodyDrop36 : Nat.ble (15669 + (PRE_first_tail_x8_r0_body.s362.next - PRE_first_tail_x8_r0_body.s363.next)) 16818 = true
kernel_rfl bodyDropH36 : Nat.ble (252 + ((mlxOf PRE_first_tail_x8_r0_body.s362.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s363.ffi).next)) 277 = true
kernel_rfl bodyDropN36 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s362.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s363.ffi).nnext)) 0 = true
kernel_rfl bodyDv36 : bodyΘ.1.take 207 = bodyΘ.1.take 189 ++ PRE_first_tail_x8_r0_body.cws36
kernel_rfl bodyDe36 : bodyΘ.2.take 207 = bodyΘ.2.take 189 ++ PRE_first_tail_x8_r0_body.nr36.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st36.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 189) (bodyΘ.2.take 189)))
kernel_rfl bodyDl36 : (bodyΘ.1.take 189).length = (bodyΘ.2.take 189).length
kernel_rfl bodyDold36 : (bodyΘ.1.take 189).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws36).isNone && !PRE_first_tail_x8_r0_body.ws36.contains v) = true
kernel_rfl bodyDfree36 : (bodyΘ.2.take 207).all (fun e => (PRE_first_tail_x8_r0_body.cws36 ++ PRE_first_tail_x8_r0_body.ws36).all fun w => e.noVar w) = true

theorem bodyStep36 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15669, 252, 0, 189⟩ bodyM PRE_first_tail_x8_r0_body.s361 PRE_first_tail_x8_r0_body.S361)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16818, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s363 PRE_first_tail_x8_r0_body.S363) (11334 + 1) :=
  bodySite bodyFacts36.cfix bodyFacts36.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x8_r0_body.st36.S5.tab) (Es := bodyEs36) (qs := bodyQs36)
    (ok := PRE_first_tail_x8_r0_body.st36.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site36 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts36
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site36 r hr) hi (MapOk.sub hm (sub_of_all bodySub36)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk36 r hr) hi hm ho hq)
    bodyLq36 rfl bodyNrLo36 (postSub_sound bodyPost36)
    (Nat.le_of_ble_eq_true bodyDrop36) (by decide) (Nat.le_of_ble_eq_true bodyDropH36) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN36) (by decide)
    bodyDv36 bodyDe36 bodyDl36 bodyDold36 bodyDfree36 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site37 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site37 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site37) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st37.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site37
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st37.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st37.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s369 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s370 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S369 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws37 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st37.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st37.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso37
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_37
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st37.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot37
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup37
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound37
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace37
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged37
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws37.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st37.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S369.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_37]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen37.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh37
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl37 : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s369.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl37 (PRE_first_tail_x8_r0_body.cncl36 bodyNcl36)

theorem bodyClean37 : Conv.JClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s369 :=
  PRE_first_tail_x8_r0_body.gjcl37 (PRE_first_tail_x8_r0_body.cjcl36 bodyClean36)

kernel_rfl bodyJsLe37 : Nat.ble PRE_first_tail_x8_r0_body.s361.next PRE_first_tail_x8_r0_body.s369.next = true
kernel_rfl bodyJsList37 : (PRE_first_tail_x8_r0_body.gjh37 ++ PRE_first_tail_x8_r0_body.cl37).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s369.next) PRE_first_tail_x8_r0_body.s371) = true
theorem bodyJs37 : JsHeapAbove PRE_first_tail_x8_r0_body.s369.next PRE_first_tail_x8_r0_body.s371 :=
  JsHeapAbove.glueSite bodyJs36 (Nat.le_of_ble_eq_true bodyJsLe37) PRE_first_tail_x8_r0_body.gjk37 PRE_first_tail_x8_r0_body.gjbd37 PRE_first_tail_x8_r0_body.cheap37 PRE_first_tail_x8_r0_body.zclbd37 bodyJsList37

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO363 : PRE_first_tail_x8_r0_body.S363.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S363.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr363 : bridgeOf PRE_first_tail_x8_r0_body.s363.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc363 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s363 PRE_first_tail_x8_r0_body.S363) = fun _ _ => true
kernel_rfl bodyAcc364 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s364 PRE_first_tail_x8_r0_body.S364) = fun _ _ => true
kernel_rfl bodyBr365 : bridgeOf PRE_first_tail_x8_r0_body.s365.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt364 : isHalt PRE_first_tail_x8_r0_body.s364.ctl = false
kernel_rfl bodyTop365 : noRetBlock PRE_first_tail_x8_r0_body.s365 = true
kernel_rfl bodyCnt363 : countersOkB PRE_first_tail_x8_r0_body.s363 PRE_first_tail_x8_r0_body.s365 = true
kernel_rfl bodyO365 : PRE_first_tail_x8_r0_body.S365.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S365.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr366 : bridgeOf PRE_first_tail_x8_r0_body.s366.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt365 : countersOkB PRE_first_tail_x8_r0_body.s365 PRE_first_tail_x8_r0_body.s366 = true
kernel_rfl bodyO366 : PRE_first_tail_x8_r0_body.S366.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S366.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc366 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s366 PRE_first_tail_x8_r0_body.S366) = fun _ _ => true
kernel_rfl bodyAcc368 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s368 PRE_first_tail_x8_r0_body.S368) = fun _ _ => true
kernel_rfl bodyBr369 : bridgeOf PRE_first_tail_x8_r0_body.s369.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt368 : isHalt PRE_first_tail_x8_r0_body.s368.ctl = false
kernel_rfl bodyTop369 : noRetBlock PRE_first_tail_x8_r0_body.s369 = true
kernel_rfl bodyCnt366 : countersOkB PRE_first_tail_x8_r0_body.s366 PRE_first_tail_x8_r0_body.s369 = true

theorem bodyGlue37 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16818, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s363 PRE_first_tail_x8_r0_body.S363)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16818, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s369 PRE_first_tail_x8_r0_body.S369) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16818, 277, 0, 207⟩) bodyAcc363 PRE_first_tail_x8_r0_body.bodyRunSeg98 bodyAcc364 bodyHalt364 PRE_first_tail_x8_r0_body.bodyStepA99 bodyTop365 (fun _ hm => bodyO363 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr363).trans bodyInactive0) (bodyBr365.trans bodyBr363.symm) bodyCnt363 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16818, 277, 0, 207⟩) PRE_first_tail_x8_r0_body.sizeA99 PRE_first_tail_x8_r0_body.sizeArgsA99 PRE_first_tail_x8_r0_body.sizeSymA99 PRE_first_tail_x8_r0_body.sizeMlxA99 PRE_first_tail_x8_r0_body.sizePayA99 PRE_first_tail_x8_r0_body.sizeTaA99 PRE_first_tail_x8_r0_body.sizeDecA99 PRE_first_tail_x8_r0_body.sizePreA99 PRE_first_tail_x8_r0_body.bodyPatchB99 (fun _ hm => bodyO365 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr365).trans bodyInactive0) (bodyBr366.trans bodyBr365.symm) bodyCnt365 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16818, 277, 0, 207⟩) bodyAcc366 PRE_first_tail_x8_r0_body.bodyRunSeg99 bodyAcc368 bodyHalt368 PRE_first_tail_x8_r0_body.bodyStepA100 bodyTop369 (fun _ hm => bodyO366 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr366).trans bodyInactive0) (bodyBr369.trans bodyBr366.symm) bodyCnt366 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift37 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S369.tab.length PRE_first_tail_x8_r0_body.s369.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P37.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P37 1661 PRE_first_tail_x8_r0_body.kappa37 PRE_first_tail_x8_r0_body.s371.ffi PRE_first_tail_x8_r0_body.s370.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_37
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_37
  have hcl : SSt (· < 1661) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s371.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S369.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_37] <;> decide) PRE_first_tail_x8_r0_body.cnodesK37 PRE_first_tail_x8_r0_body.cobjsK37
      PRE_first_tail_x8_r0_body.citemsK37 PRE_first_tail_x8_r0_body.cbd37 PRE_first_tail_x8_r0_body.csst37
  exact PRE_first_tail_x8_r0_body.cshift37 bodyNcl37 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_37] at this; exact this)


kernel_rfl bodyFramesEmpty37 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s370 a).isEmpty) = true
kernel_rfl bodyJsRoots37 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s369.next) PRE_first_tail_x8_r0_body.s371.trace PRE_first_tail_x8_r0_body.s371 = true
kernel_rfl bodyJsNative37 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s371.ffi) = true
kernel_rfl bodyLow37 : (PRE_first_tail_x8_r0_body.cws37 ++ PRE_first_tail_x8_r0_body.ws37).all (Nat.ble 9) = true
kernel_rfl bodyCntM37 : countersOkB PRE_first_tail_x8_r0_body.s369 PRE_first_tail_x8_r0_body.s370 = true
kernel_rfl bodyHi37 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s371.ffi).next setupP.E = true
kernel_rfl bodyNhi37 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s371.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge37 : bridgeOf PRE_first_tail_x8_r0_body.s370.ffi = bridgeOf PRE_first_tail_x8_r0_body.s369.ffi
kernel_rfl bodyNN37 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s369.ffi).nnext PRE_first_tail_x8_r0_body.P37.NL = true
kernel_rfl bodyXn37 : Nat.ble (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s371.ffi).next = true
kernel_rfl bodyLo37 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s371.ffi).next = true
theorem bodyFacts37 : BodySiteFacts PRE_first_tail_x8_r0_body.s369 PRE_first_tail_x8_r0_body.s370 PRE_first_tail_x8_r0_body.s371 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S369 PRE_first_tail_x8_r0_body.S370 PRE_first_tail_x8_r0_body.S371
    PRE_first_tail_x8_r0_body.ws37 PRE_first_tail_x8_r0_body.cws37 PRE_first_tail_x8_r0_body.nr37 PRE_first_tail_x8_r0_body.pl37 PRE_first_tail_x8_r0_body.cl37 2704201 1661 PRE_first_tail_x8_r0_body.kd37 PRE_first_tail_x8_r0_body.kappa37 PRE_first_tail_x8_r0_body.P37
    ⟨18940, 16029, 2704199, 1661⟩ ⟨18940, 16029, 2704199, 1661⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap37
  clean := bodyClean37
  cfix := PRE_first_tail_x8_r0_body.cfix37
  zpl := PRE_first_tail_x8_r0_body.zpl37
  zplnd := PRE_first_tail_x8_r0_body.zplnd37
  zn1 := PRE_first_tail_x8_r0_body.zn137
  zfirst := PRE_first_tail_x8_r0_body.zfirst37
  zscn := PRE_first_tail_x8_r0_body.zscn37
  zsmn := PRE_first_tail_x8_r0_body.zsmn37
  zgrow := PRE_first_tail_x8_r0_body.zgrow37
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab37
  zfresh := PRE_first_tail_x8_r0_body.zfresh37
  zcnd := PRE_first_tail_x8_r0_body.zcnd37
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi37
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt37
  zgP := PRE_first_tail_x8_r0_body.zg37_2665
  zkP := PRE_first_tail_x8_r0_body.zk37_2665
  zmP := PRE_first_tail_x8_r0_body.zm37_2665
  zgC := PRE_first_tail_x8_r0_body.zg37_2673467
  zkC := PRE_first_tail_x8_r0_body.zk37_2673467
  zmC := PRE_first_tail_x8_r0_body.zm37_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw37_2673472
  zwV := PRE_first_tail_x8_r0_body.zw37_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap37
  zclbd := PRE_first_tail_x8_r0_body.zclbd37
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap37 PRE_first_tail_x8_r0_body.stFoot37 PRE_first_tail_x8_r0_body.iso37 PRE_first_tail_x8_r0_body.zwr37
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP37
  csupp := PRE_first_tail_x8_r0_body.csupp37
  cbound := PRE_first_tail_x8_r0_body.cbound37
  zimg := PRE_first_tail_x8_r0_body.zimg37
  zctl := PRE_first_tail_x8_r0_body.zctl37
  zstack := PRE_first_tail_x8_r0_body.zstack37
  zjobs := PRE_first_tail_x8_r0_body.zjobs37
  zstores := PRE_first_tail_x8_r0_body.zstores37
  zroots := PRE_first_tail_x8_r0_body.zroots37
  znC := PRE_first_tail_x8_r0_body.znC37
  ctab := PRE_first_tail_x8_r0_body.ctab37
  zbin := PRE_first_tail_x8_r0_body.zbin37
  cbridge := PRE_first_tail_x8_r0_body.cbridge37
  sbridge := bodyBridge37
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj37
  cshiftR := fun h hNL => bodyCshift37 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN37
  raised := PRE_first_tail_x8_r0_body.raised37
  cbigs := PRE_first_tail_x8_r0_body.cbigs37
  cjcl := PRE_first_tail_x8_r0_body.cjcl37
  xnLe := Nat.le_of_ble_eq_true bodyXn37
  loLe := Nat.le_of_ble_eq_true bodyLo37
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB37
  cntM := bodyCntM37
  hiLe := Nat.le_of_ble_eq_true bodyHi37
  nhiLe := Nat.le_of_ble_eq_true bodyNhi37
  jsHeap := bodyJs37
  jsRoots := bodyJsRoots37
  jsNative := bodyJsNative37
  framesEmpty := bodyFramesEmpty37
  trailOld := by decide
  lowVars := bodyLow37

def bodyQs37 : List (Option Q) := []
noncomputable def bodyEs37 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr37.map fun r => nth? PRE_first_tail_x8_r0_body.st37.S2.tab r
kernel_rfl bodyResChk37 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs37 bodyQs37) = true
kernel_rfl bodyLq37 : bodyQs37.length = PRE_first_tail_x8_r0_body.cws37.length
kernel_rfl bodyNrLo37 : PRE_first_tail_x8_r0_body.nr37.all (Nat.ble PRE_first_tail_x8_r0_body.S369.tab.length) = true
kernel_rfl bodySub37 : (Oracles.PRE_first_tail_x8_r0_body.map_site37.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost37 : postSubB bodyM PRE_first_tail_x8_r0_body.ws37 PRE_first_tail_x8_r0_body.cws37 bodyQs37 = true
kernel_rfl bodyDrop37 : Nat.ble (16818 + (PRE_first_tail_x8_r0_body.s370.next - PRE_first_tail_x8_r0_body.s371.next)) 16820 = true
kernel_rfl bodyDropH37 : Nat.ble (277 + ((mlxOf PRE_first_tail_x8_r0_body.s370.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s371.ffi).next)) 277 = true
kernel_rfl bodyDropN37 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s370.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s371.ffi).nnext)) 0 = true
kernel_rfl bodyDv37 : bodyΘ.1.take 207 = bodyΘ.1.take 207 ++ PRE_first_tail_x8_r0_body.cws37
kernel_rfl bodyDe37 : bodyΘ.2.take 207 = bodyΘ.2.take 207 ++ PRE_first_tail_x8_r0_body.nr37.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st37.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 207) (bodyΘ.2.take 207)))
kernel_rfl bodyDl37 : (bodyΘ.1.take 207).length = (bodyΘ.2.take 207).length
kernel_rfl bodyDold37 : (bodyΘ.1.take 207).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws37).isNone && !PRE_first_tail_x8_r0_body.ws37.contains v) = true
kernel_rfl bodyDfree37 : (bodyΘ.2.take 207).all (fun e => (PRE_first_tail_x8_r0_body.cws37 ++ PRE_first_tail_x8_r0_body.ws37).all fun w => e.noVar w) = true

theorem bodyStep37 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16818, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s369 PRE_first_tail_x8_r0_body.S369)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16820, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s371 PRE_first_tail_x8_r0_body.S371) (27 + 1) :=
  bodySite bodyFacts37.cfix bodyFacts37.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x8_r0_body.st37.S2.tab) (Es := bodyEs37) (qs := bodyQs37)
    (ok := PRE_first_tail_x8_r0_body.st37.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site37 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts37
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site37 r hr) hi (MapOk.sub hm (sub_of_all bodySub37)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk37 r hr) hi hm ho hq)
    bodyLq37 rfl bodyNrLo37 (postSub_sound bodyPost37)
    (Nat.le_of_ble_eq_true bodyDrop37) (by decide) (Nat.le_of_ble_eq_true bodyDropH37) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN37) (by decide)
    bodyDv37 bodyDe37 bodyDl37 bodyDold37 bodyDfree37 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site38 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site38 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site38) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site38
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s373 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s374 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S373 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws38 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso38
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_38
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot38
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup38
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound38
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace38
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged38
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws38.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st38.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S373.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_38]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen38.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh38
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl38 : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s373.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl38 (PRE_first_tail_x8_r0_body.cncl37 bodyNcl37)

theorem bodyClean38 : Conv.JClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s373 :=
  PRE_first_tail_x8_r0_body.gjcl38 (PRE_first_tail_x8_r0_body.cjcl37 bodyClean37)

kernel_rfl bodyJsLe38 : Nat.ble PRE_first_tail_x8_r0_body.s369.next PRE_first_tail_x8_r0_body.s373.next = true
kernel_rfl bodyJsList38 : (PRE_first_tail_x8_r0_body.gjh38 ++ PRE_first_tail_x8_r0_body.cl38).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s373.next) PRE_first_tail_x8_r0_body.s375) = true
theorem bodyJs38 : JsHeapAbove PRE_first_tail_x8_r0_body.s373.next PRE_first_tail_x8_r0_body.s375 :=
  JsHeapAbove.glueSite bodyJs37 (Nat.le_of_ble_eq_true bodyJsLe38) PRE_first_tail_x8_r0_body.gjk38 PRE_first_tail_x8_r0_body.gjbd38 PRE_first_tail_x8_r0_body.cheap38 PRE_first_tail_x8_r0_body.zclbd38 bodyJsList38

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO371 : PRE_first_tail_x8_r0_body.S371.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S371.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr371 : bridgeOf PRE_first_tail_x8_r0_body.s371.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc371 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s371 PRE_first_tail_x8_r0_body.S371) = fun _ _ => true
kernel_rfl bodyAcc372 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s372 PRE_first_tail_x8_r0_body.S372) = fun _ _ => true
kernel_rfl bodyBr373 : bridgeOf PRE_first_tail_x8_r0_body.s373.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt372 : isHalt PRE_first_tail_x8_r0_body.s372.ctl = false
kernel_rfl bodyTop373 : noRetBlock PRE_first_tail_x8_r0_body.s373 = true
kernel_rfl bodyCnt371 : countersOkB PRE_first_tail_x8_r0_body.s371 PRE_first_tail_x8_r0_body.s373 = true

theorem bodyGlue38 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16820, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s371 PRE_first_tail_x8_r0_body.S371)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16820, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s373 PRE_first_tail_x8_r0_body.S373) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16820, 277, 0, 207⟩) bodyAcc371 PRE_first_tail_x8_r0_body.bodyRunSeg100 bodyAcc372 bodyHalt372 PRE_first_tail_x8_r0_body.bodyStepA101 bodyTop373 (fun _ hm => bodyO371 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr371).trans bodyInactive0) (bodyBr373.trans bodyBr371.symm) bodyCnt371 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift38 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S373.tab.length PRE_first_tail_x8_r0_body.s373.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P38.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P38 1678 PRE_first_tail_x8_r0_body.kappa38 PRE_first_tail_x8_r0_body.s375.ffi PRE_first_tail_x8_r0_body.s374.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_38
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_38
  have hcl : SSt (· < 1678) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s375.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S373.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_38] <;> decide) PRE_first_tail_x8_r0_body.cnodesK38 PRE_first_tail_x8_r0_body.cobjsK38
      PRE_first_tail_x8_r0_body.citemsK38 PRE_first_tail_x8_r0_body.cbd38 PRE_first_tail_x8_r0_body.csst38
  exact PRE_first_tail_x8_r0_body.cshift38 bodyNcl38 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_38] at this; exact this)


kernel_rfl bodyFramesEmpty38 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s374 a).isEmpty) = true
kernel_rfl bodyJsRoots38 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s373.next) PRE_first_tail_x8_r0_body.s375.trace PRE_first_tail_x8_r0_body.s375 = true
kernel_rfl bodyJsNative38 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s375.ffi) = true
kernel_rfl bodyLow38 : (PRE_first_tail_x8_r0_body.cws38 ++ PRE_first_tail_x8_r0_body.ws38).all (Nat.ble 9) = true
kernel_rfl bodyCntM38 : countersOkB PRE_first_tail_x8_r0_body.s373 PRE_first_tail_x8_r0_body.s374 = true
kernel_rfl bodyHi38 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s375.ffi).next setupP.E = true
kernel_rfl bodyNhi38 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s375.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge38 : bridgeOf PRE_first_tail_x8_r0_body.s374.ffi = bridgeOf PRE_first_tail_x8_r0_body.s373.ffi
kernel_rfl bodyNN38 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s373.ffi).nnext PRE_first_tail_x8_r0_body.P38.NL = true
kernel_rfl bodyXn38 : Nat.ble (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s375.ffi).next = true
kernel_rfl bodyLo38 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s375.ffi).next = true
theorem bodyFacts38 : BodySiteFacts PRE_first_tail_x8_r0_body.s373 PRE_first_tail_x8_r0_body.s374 PRE_first_tail_x8_r0_body.s375 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S373 PRE_first_tail_x8_r0_body.S374 PRE_first_tail_x8_r0_body.S375
    PRE_first_tail_x8_r0_body.ws38 PRE_first_tail_x8_r0_body.cws38 PRE_first_tail_x8_r0_body.nr38 PRE_first_tail_x8_r0_body.pl38 PRE_first_tail_x8_r0_body.cl38 2704498 1678 PRE_first_tail_x8_r0_body.kd38 PRE_first_tail_x8_r0_body.kappa38 PRE_first_tail_x8_r0_body.P38
    ⟨18947, 16033, 2704487, 1678⟩ ⟨18947, 16033, 2704488, 1678⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap38
  clean := bodyClean38
  cfix := PRE_first_tail_x8_r0_body.cfix38
  zpl := PRE_first_tail_x8_r0_body.zpl38
  zplnd := PRE_first_tail_x8_r0_body.zplnd38
  zn1 := PRE_first_tail_x8_r0_body.zn138
  zfirst := PRE_first_tail_x8_r0_body.zfirst38
  zscn := PRE_first_tail_x8_r0_body.zscn38
  zsmn := PRE_first_tail_x8_r0_body.zsmn38
  zgrow := PRE_first_tail_x8_r0_body.zgrow38
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab38
  zfresh := PRE_first_tail_x8_r0_body.zfresh38
  zcnd := PRE_first_tail_x8_r0_body.zcnd38
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi38
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt38
  zgP := PRE_first_tail_x8_r0_body.zg38_2665
  zkP := PRE_first_tail_x8_r0_body.zk38_2665
  zmP := PRE_first_tail_x8_r0_body.zm38_2665
  zgC := PRE_first_tail_x8_r0_body.zg38_2673467
  zkC := PRE_first_tail_x8_r0_body.zk38_2673467
  zmC := PRE_first_tail_x8_r0_body.zm38_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw38_2673472
  zwV := PRE_first_tail_x8_r0_body.zw38_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap38
  zclbd := PRE_first_tail_x8_r0_body.zclbd38
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap38 PRE_first_tail_x8_r0_body.stFoot38 PRE_first_tail_x8_r0_body.iso38 PRE_first_tail_x8_r0_body.zwr38
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP38
  csupp := PRE_first_tail_x8_r0_body.csupp38
  cbound := PRE_first_tail_x8_r0_body.cbound38
  zimg := PRE_first_tail_x8_r0_body.zimg38
  zctl := PRE_first_tail_x8_r0_body.zctl38
  zstack := PRE_first_tail_x8_r0_body.zstack38
  zjobs := PRE_first_tail_x8_r0_body.zjobs38
  zstores := PRE_first_tail_x8_r0_body.zstores38
  zroots := PRE_first_tail_x8_r0_body.zroots38
  znC := PRE_first_tail_x8_r0_body.znC38
  ctab := PRE_first_tail_x8_r0_body.ctab38
  zbin := PRE_first_tail_x8_r0_body.zbin38
  cbridge := PRE_first_tail_x8_r0_body.cbridge38
  sbridge := bodyBridge38
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj38
  cshiftR := fun h hNL => bodyCshift38 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN38
  raised := PRE_first_tail_x8_r0_body.raised38
  cbigs := PRE_first_tail_x8_r0_body.cbigs38
  cjcl := PRE_first_tail_x8_r0_body.cjcl38
  xnLe := Nat.le_of_ble_eq_true bodyXn38
  loLe := Nat.le_of_ble_eq_true bodyLo38
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB38
  cntM := bodyCntM38
  hiLe := Nat.le_of_ble_eq_true bodyHi38
  nhiLe := Nat.le_of_ble_eq_true bodyNhi38
  jsHeap := bodyJs38
  jsRoots := bodyJsRoots38
  jsNative := bodyJsNative38
  framesEmpty := bodyFramesEmpty38
  trailOld := by decide
  lowVars := bodyLow38

def bodyQs38 : List (Option Q) := []
noncomputable def bodyEs38 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr38.map fun r => nth? PRE_first_tail_x8_r0_body.st38.S2.tab r
kernel_rfl bodyResChk38 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs38 bodyQs38) = true
kernel_rfl bodyLq38 : bodyQs38.length = PRE_first_tail_x8_r0_body.cws38.length
kernel_rfl bodyNrLo38 : PRE_first_tail_x8_r0_body.nr38.all (Nat.ble PRE_first_tail_x8_r0_body.S373.tab.length) = true
kernel_rfl bodySub38 : (Oracles.PRE_first_tail_x8_r0_body.map_site38.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost38 : postSubB bodyM PRE_first_tail_x8_r0_body.ws38 PRE_first_tail_x8_r0_body.cws38 bodyQs38 = true
kernel_rfl bodyDrop38 : Nat.ble (16820 + (PRE_first_tail_x8_r0_body.s374.next - PRE_first_tail_x8_r0_body.s375.next)) 16830 = true
kernel_rfl bodyDropH38 : Nat.ble (277 + ((mlxOf PRE_first_tail_x8_r0_body.s374.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s375.ffi).next)) 277 = true
kernel_rfl bodyDropN38 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s374.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s375.ffi).nnext)) 0 = true
kernel_rfl bodyDv38 : bodyΘ.1.take 207 = bodyΘ.1.take 207 ++ PRE_first_tail_x8_r0_body.cws38
kernel_rfl bodyDe38 : bodyΘ.2.take 207 = bodyΘ.2.take 207 ++ PRE_first_tail_x8_r0_body.nr38.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st38.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 207) (bodyΘ.2.take 207)))
kernel_rfl bodyDl38 : (bodyΘ.1.take 207).length = (bodyΘ.2.take 207).length
kernel_rfl bodyDold38 : (bodyΘ.1.take 207).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws38).isNone && !PRE_first_tail_x8_r0_body.ws38.contains v) = true
kernel_rfl bodyDfree38 : (bodyΘ.2.take 207).all (fun e => (PRE_first_tail_x8_r0_body.cws38 ++ PRE_first_tail_x8_r0_body.ws38).all fun w => e.noVar w) = true

theorem bodyStep38 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16820, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s373 PRE_first_tail_x8_r0_body.S373)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16830, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s375 PRE_first_tail_x8_r0_body.S375) (98 + 1) :=
  bodySite bodyFacts38.cfix bodyFacts38.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x8_r0_body.st38.S2.tab) (Es := bodyEs38) (qs := bodyQs38)
    (ok := PRE_first_tail_x8_r0_body.st38.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site38 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts38
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site38 r hr) hi (MapOk.sub hm (sub_of_all bodySub38)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk38 r hr) hi hm ho hq)
    bodyLq38 rfl bodyNrLo38 (postSub_sound bodyPost38)
    (Nat.le_of_ble_eq_true bodyDrop38) (by decide) (Nat.le_of_ble_eq_true bodyDropH38) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN38) (by decide)
    bodyDv38 bodyDe38 bodyDl38 bodyDold38 bodyDfree38 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site39 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site39 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site39) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st39.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site39
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st39.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st39.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s390 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s391 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S390 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws39 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st39.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st39.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso39
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_39
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st39.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot39
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup39
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound39
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace39
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged39
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws39.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st39.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S390.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_39]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen39.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh39
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl39 : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s390.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl39 (PRE_first_tail_x8_r0_body.cncl38 bodyNcl38)

theorem bodyClean39 : Conv.JClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s390 :=
  PRE_first_tail_x8_r0_body.gjcl39 (PRE_first_tail_x8_r0_body.cjcl38 bodyClean38)

kernel_rfl bodyJsLe39 : Nat.ble PRE_first_tail_x8_r0_body.s373.next PRE_first_tail_x8_r0_body.s390.next = true
kernel_rfl bodyJsList39 : (PRE_first_tail_x8_r0_body.gjh39 ++ PRE_first_tail_x8_r0_body.cl39).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s390.next) PRE_first_tail_x8_r0_body.s392) = true
theorem bodyJs39 : JsHeapAbove PRE_first_tail_x8_r0_body.s390.next PRE_first_tail_x8_r0_body.s392 :=
  JsHeapAbove.glueSite bodyJs38 (Nat.le_of_ble_eq_true bodyJsLe39) PRE_first_tail_x8_r0_body.gjk39 PRE_first_tail_x8_r0_body.gjbd39 PRE_first_tail_x8_r0_body.cheap39 PRE_first_tail_x8_r0_body.zclbd39 bodyJsList39

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO375 : PRE_first_tail_x8_r0_body.S375.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S375.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr375 : bridgeOf PRE_first_tail_x8_r0_body.s375.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc375 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s375 PRE_first_tail_x8_r0_body.S375) = fun _ _ => true
kernel_rfl bodyAcc377 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s377 PRE_first_tail_x8_r0_body.S377) = fun _ _ => true
kernel_rfl bodyBr378 : bridgeOf PRE_first_tail_x8_r0_body.s378.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt377 : isHalt PRE_first_tail_x8_r0_body.s377.ctl = false
kernel_rfl bodyTop378 : noRetBlock PRE_first_tail_x8_r0_body.s378 = true
kernel_rfl bodyCnt375 : countersOkB PRE_first_tail_x8_r0_body.s375 PRE_first_tail_x8_r0_body.s378 = true
kernel_rfl bodyO378 : PRE_first_tail_x8_r0_body.S378.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S378.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr379 : bridgeOf PRE_first_tail_x8_r0_body.s379.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt378 : countersOkB PRE_first_tail_x8_r0_body.s378 PRE_first_tail_x8_r0_body.s379 = true
kernel_rfl bodyO379 : PRE_first_tail_x8_r0_body.S379.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S379.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc379 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s379 PRE_first_tail_x8_r0_body.S379) = fun _ _ => true
kernel_rfl bodyAcc380 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s380 PRE_first_tail_x8_r0_body.S380) = fun _ _ => true
kernel_rfl bodyBr381 : bridgeOf PRE_first_tail_x8_r0_body.s381.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt380 : isHalt PRE_first_tail_x8_r0_body.s380.ctl = false
kernel_rfl bodyTop381 : noRetBlock PRE_first_tail_x8_r0_body.s381 = true
kernel_rfl bodyCnt379 : countersOkB PRE_first_tail_x8_r0_body.s379 PRE_first_tail_x8_r0_body.s381 = true
kernel_rfl bodyO381 : PRE_first_tail_x8_r0_body.S381.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S381.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr382 : bridgeOf PRE_first_tail_x8_r0_body.s382.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt381 : countersOkB PRE_first_tail_x8_r0_body.s381 PRE_first_tail_x8_r0_body.s382 = true
kernel_rfl bodyO382 : PRE_first_tail_x8_r0_body.S382.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S382.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc382 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s382 PRE_first_tail_x8_r0_body.S382) = fun _ _ => true
kernel_rfl bodyAcc383 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s383 PRE_first_tail_x8_r0_body.S383) = fun _ _ => true
kernel_rfl bodyBr384 : bridgeOf PRE_first_tail_x8_r0_body.s384.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt383 : isHalt PRE_first_tail_x8_r0_body.s383.ctl = false
kernel_rfl bodyTop384 : noRetBlock PRE_first_tail_x8_r0_body.s384 = true
kernel_rfl bodyCnt382 : countersOkB PRE_first_tail_x8_r0_body.s382 PRE_first_tail_x8_r0_body.s384 = true
kernel_rfl bodyO384 : PRE_first_tail_x8_r0_body.S384.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S384.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr385 : bridgeOf PRE_first_tail_x8_r0_body.s385.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt384 : countersOkB PRE_first_tail_x8_r0_body.s384 PRE_first_tail_x8_r0_body.s385 = true
kernel_rfl bodyO385 : PRE_first_tail_x8_r0_body.S385.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S385.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc385 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s385 PRE_first_tail_x8_r0_body.S385) = fun _ _ => true
kernel_rfl bodyAcc386 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s386 PRE_first_tail_x8_r0_body.S386) = fun _ _ => true
kernel_rfl bodyBr387 : bridgeOf PRE_first_tail_x8_r0_body.s387.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt386 : isHalt PRE_first_tail_x8_r0_body.s386.ctl = false
kernel_rfl bodyTop387 : noRetBlock PRE_first_tail_x8_r0_body.s387 = true
kernel_rfl bodyCnt385 : countersOkB PRE_first_tail_x8_r0_body.s385 PRE_first_tail_x8_r0_body.s387 = true
kernel_rfl bodyO387 : PRE_first_tail_x8_r0_body.S387.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S387.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr388 : bridgeOf PRE_first_tail_x8_r0_body.s388.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt387 : countersOkB PRE_first_tail_x8_r0_body.s387 PRE_first_tail_x8_r0_body.s388 = true
kernel_rfl bodyO388 : PRE_first_tail_x8_r0_body.S388.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S388.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc388 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s388 PRE_first_tail_x8_r0_body.S388) = fun _ _ => true
kernel_rfl bodyAcc389 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s389 PRE_first_tail_x8_r0_body.S389) = fun _ _ => true
kernel_rfl bodyBr390 : bridgeOf PRE_first_tail_x8_r0_body.s390.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt389 : isHalt PRE_first_tail_x8_r0_body.s389.ctl = false
kernel_rfl bodyTop390 : noRetBlock PRE_first_tail_x8_r0_body.s390 = true
kernel_rfl bodyCnt388 : countersOkB PRE_first_tail_x8_r0_body.s388 PRE_first_tail_x8_r0_body.s390 = true

theorem bodyGlue39 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16830, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s375 PRE_first_tail_x8_r0_body.S375)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16830, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s390 PRE_first_tail_x8_r0_body.S390) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) bodyAcc375 PRE_first_tail_x8_r0_body.bodyRunSeg101 bodyAcc377 bodyHalt377 PRE_first_tail_x8_r0_body.bodyStepA102 bodyTop378 (fun _ hm => bodyO375 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr375).trans bodyInactive0) (bodyBr378.trans bodyBr375.symm) bodyCnt375 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) PRE_first_tail_x8_r0_body.sizeA102 PRE_first_tail_x8_r0_body.sizeArgsA102 PRE_first_tail_x8_r0_body.sizeSymA102 PRE_first_tail_x8_r0_body.sizeMlxA102 PRE_first_tail_x8_r0_body.sizePayA102 PRE_first_tail_x8_r0_body.sizeTaA102 PRE_first_tail_x8_r0_body.sizeDecA102 PRE_first_tail_x8_r0_body.sizePreA102 PRE_first_tail_x8_r0_body.bodyPatchB102 (fun _ hm => bodyO378 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr378).trans bodyInactive0) (bodyBr379.trans bodyBr378.symm) bodyCnt378 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) bodyAcc379 PRE_first_tail_x8_r0_body.bodyRunSeg102 bodyAcc380 bodyHalt380 PRE_first_tail_x8_r0_body.bodyStepA103 bodyTop381 (fun _ hm => bodyO379 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr379).trans bodyInactive0) (bodyBr381.trans bodyBr379.symm) bodyCnt379 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) PRE_first_tail_x8_r0_body.sizeA103 PRE_first_tail_x8_r0_body.sizeArgsA103 PRE_first_tail_x8_r0_body.sizeSymA103 PRE_first_tail_x8_r0_body.sizeMlxA103 PRE_first_tail_x8_r0_body.sizePayA103 PRE_first_tail_x8_r0_body.sizeTaA103 PRE_first_tail_x8_r0_body.sizeDecA103 PRE_first_tail_x8_r0_body.sizePreA103 PRE_first_tail_x8_r0_body.bodyPatchB103 (fun _ hm => bodyO381 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr381).trans bodyInactive0) (bodyBr382.trans bodyBr381.symm) bodyCnt381 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) bodyAcc382 PRE_first_tail_x8_r0_body.bodyRunSeg103 bodyAcc383 bodyHalt383 PRE_first_tail_x8_r0_body.bodyStepA104 bodyTop384 (fun _ hm => bodyO382 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr382).trans bodyInactive0) (bodyBr384.trans bodyBr382.symm) bodyCnt382 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) PRE_first_tail_x8_r0_body.sizeA104 PRE_first_tail_x8_r0_body.sizeArgsA104 PRE_first_tail_x8_r0_body.sizeSymA104 PRE_first_tail_x8_r0_body.sizeMlxA104 PRE_first_tail_x8_r0_body.sizePayA104 PRE_first_tail_x8_r0_body.sizeTaA104 PRE_first_tail_x8_r0_body.sizeDecA104 PRE_first_tail_x8_r0_body.sizePreA104 PRE_first_tail_x8_r0_body.bodyPatchB104 (fun _ hm => bodyO384 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr384).trans bodyInactive0) (bodyBr385.trans bodyBr384.symm) bodyCnt384 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) bodyAcc385 PRE_first_tail_x8_r0_body.bodyRunSeg104 bodyAcc386 bodyHalt386 PRE_first_tail_x8_r0_body.bodyStepA105 bodyTop387 (fun _ hm => bodyO385 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr385).trans bodyInactive0) (bodyBr387.trans bodyBr385.symm) bodyCnt385 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) PRE_first_tail_x8_r0_body.sizeA105 PRE_first_tail_x8_r0_body.sizeArgsA105 PRE_first_tail_x8_r0_body.sizeSymA105 PRE_first_tail_x8_r0_body.sizeMlxA105 PRE_first_tail_x8_r0_body.sizePayA105 PRE_first_tail_x8_r0_body.sizeTaA105 PRE_first_tail_x8_r0_body.sizeDecA105 PRE_first_tail_x8_r0_body.sizePreA105 PRE_first_tail_x8_r0_body.bodyPatchB105 (fun _ hm => bodyO387 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr387).trans bodyInactive0) (bodyBr388.trans bodyBr387.symm) bodyCnt387 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16830, 277, 0, 207⟩) bodyAcc388 PRE_first_tail_x8_r0_body.bodyRunSeg105 bodyAcc389 bodyHalt389 PRE_first_tail_x8_r0_body.bodyStepA106 bodyTop390 (fun _ hm => bodyO388 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr388).trans bodyInactive0) (bodyBr390.trans bodyBr388.symm) bodyCnt388 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift39 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S390.tab.length PRE_first_tail_x8_r0_body.s390.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P39.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P39 1769 PRE_first_tail_x8_r0_body.kappa39 PRE_first_tail_x8_r0_body.s392.ffi PRE_first_tail_x8_r0_body.s391.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_39
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_39
  have hcl : SSt (· < 1769) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s392.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S390.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_39] <;> decide) PRE_first_tail_x8_r0_body.cnodesK39 PRE_first_tail_x8_r0_body.cobjsK39
      PRE_first_tail_x8_r0_body.citemsK39 PRE_first_tail_x8_r0_body.cbd39 PRE_first_tail_x8_r0_body.csst39
  exact PRE_first_tail_x8_r0_body.cshift39 bodyNcl39 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_39] at this; exact this)


kernel_rfl bodyFramesEmpty39 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s391 a).isEmpty) = true
kernel_rfl bodyJsRoots39 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s390.next) PRE_first_tail_x8_r0_body.s392.trace PRE_first_tail_x8_r0_body.s392 = true
kernel_rfl bodyJsNative39 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s392.ffi) = true
kernel_rfl bodyLow39 : (PRE_first_tail_x8_r0_body.cws39 ++ PRE_first_tail_x8_r0_body.ws39).all (Nat.ble 9) = true
kernel_rfl bodyCntM39 : countersOkB PRE_first_tail_x8_r0_body.s390 PRE_first_tail_x8_r0_body.s391 = true
kernel_rfl bodyHi39 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s392.ffi).next setupP.E = true
kernel_rfl bodyNhi39 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s392.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge39 : bridgeOf PRE_first_tail_x8_r0_body.s391.ffi = bridgeOf PRE_first_tail_x8_r0_body.s390.ffi
kernel_rfl bodyNN39 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s390.ffi).nnext PRE_first_tail_x8_r0_body.P39.NL = true
kernel_rfl bodyXn39 : Nat.ble (⟨18984, 16079, 2705965, 1769⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s392.ffi).next = true
kernel_rfl bodyLo39 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s392.ffi).next = true
theorem bodyFacts39 : BodySiteFacts PRE_first_tail_x8_r0_body.s390 PRE_first_tail_x8_r0_body.s391 PRE_first_tail_x8_r0_body.s392 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S390 PRE_first_tail_x8_r0_body.S391 PRE_first_tail_x8_r0_body.S392
    PRE_first_tail_x8_r0_body.ws39 PRE_first_tail_x8_r0_body.cws39 PRE_first_tail_x8_r0_body.nr39 PRE_first_tail_x8_r0_body.pl39 PRE_first_tail_x8_r0_body.cl39 2707114 1769 PRE_first_tail_x8_r0_body.kd39 PRE_first_tail_x8_r0_body.kappa39 PRE_first_tail_x8_r0_body.P39
    ⟨18981, 16052, 2705959, 1751⟩ ⟨18984, 16079, 2705965, 1769⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap39
  clean := bodyClean39
  cfix := PRE_first_tail_x8_r0_body.cfix39
  zpl := PRE_first_tail_x8_r0_body.zpl39
  zplnd := PRE_first_tail_x8_r0_body.zplnd39
  zn1 := PRE_first_tail_x8_r0_body.zn139
  zfirst := PRE_first_tail_x8_r0_body.zfirst39
  zscn := PRE_first_tail_x8_r0_body.zscn39
  zsmn := PRE_first_tail_x8_r0_body.zsmn39
  zgrow := PRE_first_tail_x8_r0_body.zgrow39
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab39
  zfresh := PRE_first_tail_x8_r0_body.zfresh39
  zcnd := PRE_first_tail_x8_r0_body.zcnd39
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi39
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt39
  zgP := PRE_first_tail_x8_r0_body.zg39_2665
  zkP := PRE_first_tail_x8_r0_body.zk39_2665
  zmP := PRE_first_tail_x8_r0_body.zm39_2665
  zgC := PRE_first_tail_x8_r0_body.zg39_2673467
  zkC := PRE_first_tail_x8_r0_body.zk39_2673467
  zmC := PRE_first_tail_x8_r0_body.zm39_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw39_2673472
  zwV := PRE_first_tail_x8_r0_body.zw39_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap39
  zclbd := PRE_first_tail_x8_r0_body.zclbd39
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap39 PRE_first_tail_x8_r0_body.stFoot39 PRE_first_tail_x8_r0_body.iso39 PRE_first_tail_x8_r0_body.zwr39
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP39
  csupp := PRE_first_tail_x8_r0_body.csupp39
  cbound := PRE_first_tail_x8_r0_body.cbound39
  zimg := PRE_first_tail_x8_r0_body.zimg39
  zctl := PRE_first_tail_x8_r0_body.zctl39
  zstack := PRE_first_tail_x8_r0_body.zstack39
  zjobs := PRE_first_tail_x8_r0_body.zjobs39
  zstores := PRE_first_tail_x8_r0_body.zstores39
  zroots := PRE_first_tail_x8_r0_body.zroots39
  znC := PRE_first_tail_x8_r0_body.znC39
  ctab := PRE_first_tail_x8_r0_body.ctab39
  zbin := PRE_first_tail_x8_r0_body.zbin39
  cbridge := PRE_first_tail_x8_r0_body.cbridge39
  sbridge := bodyBridge39
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj39
  cshiftR := fun h hNL => bodyCshift39 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN39
  raised := PRE_first_tail_x8_r0_body.raised39
  cbigs := PRE_first_tail_x8_r0_body.cbigs39
  cjcl := PRE_first_tail_x8_r0_body.cjcl39
  xnLe := Nat.le_of_ble_eq_true bodyXn39
  loLe := Nat.le_of_ble_eq_true bodyLo39
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB39
  cntM := bodyCntM39
  hiLe := Nat.le_of_ble_eq_true bodyHi39
  nhiLe := Nat.le_of_ble_eq_true bodyNhi39
  jsHeap := bodyJs39
  jsRoots := bodyJsRoots39
  jsNative := bodyJsNative39
  framesEmpty := bodyFramesEmpty39
  trailOld := by decide
  lowVars := bodyLow39

def bodyQs39 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs39 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr39.map fun r => nth? PRE_first_tail_x8_r0_body.st39.S5.tab r
kernel_rfl bodyResChk39 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs39 bodyQs39) = true
kernel_rfl bodyLq39 : bodyQs39.length = PRE_first_tail_x8_r0_body.cws39.length
kernel_rfl bodyNrLo39 : PRE_first_tail_x8_r0_body.nr39.all (Nat.ble PRE_first_tail_x8_r0_body.S390.tab.length) = true
kernel_rfl bodySub39 : (Oracles.PRE_first_tail_x8_r0_body.map_site39.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost39 : postSubB bodyM PRE_first_tail_x8_r0_body.ws39 PRE_first_tail_x8_r0_body.cws39 bodyQs39 = true
kernel_rfl bodyDrop39 : Nat.ble (16830 + (PRE_first_tail_x8_r0_body.s391.next - PRE_first_tail_x8_r0_body.s392.next)) 17979 = true
kernel_rfl bodyDropH39 : Nat.ble (277 + ((mlxOf PRE_first_tail_x8_r0_body.s391.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s392.ffi).next)) 302 = true
kernel_rfl bodyDropN39 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s391.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s392.ffi).nnext)) 0 = true
kernel_rfl bodyDv39 : bodyΘ.1.take 225 = bodyΘ.1.take 207 ++ PRE_first_tail_x8_r0_body.cws39
kernel_rfl bodyDe39 : bodyΘ.2.take 225 = bodyΘ.2.take 207 ++ PRE_first_tail_x8_r0_body.nr39.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st39.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 207) (bodyΘ.2.take 207)))
kernel_rfl bodyDl39 : (bodyΘ.1.take 207).length = (bodyΘ.2.take 207).length
kernel_rfl bodyDold39 : (bodyΘ.1.take 207).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws39).isNone && !PRE_first_tail_x8_r0_body.ws39.contains v) = true
kernel_rfl bodyDfree39 : (bodyΘ.2.take 225).all (fun e => (PRE_first_tail_x8_r0_body.cws39 ++ PRE_first_tail_x8_r0_body.ws39).all fun w => e.noVar w) = true

theorem bodyStep39 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16830, 277, 0, 207⟩ bodyM PRE_first_tail_x8_r0_body.s390 PRE_first_tail_x8_r0_body.S390)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x8_r0_body.s392 PRE_first_tail_x8_r0_body.S392) (11334 + 1) :=
  bodySite bodyFacts39.cfix bodyFacts39.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x8_r0_body.st39.S5.tab) (Es := bodyEs39) (qs := bodyQs39)
    (ok := PRE_first_tail_x8_r0_body.st39.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site39 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts39
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site39 r hr) hi (MapOk.sub hm (sub_of_all bodySub39)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk39 r hr) hi hm ho hq)
    bodyLq39 rfl bodyNrLo39 (postSub_sound bodyPost39)
    (Nat.le_of_ble_eq_true bodyDrop39) (by decide) (Nat.le_of_ble_eq_true bodyDropH39) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN39) (by decide)
    bodyDv39 bodyDe39 bodyDl39 bodyDold39 bodyDfree39 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end
