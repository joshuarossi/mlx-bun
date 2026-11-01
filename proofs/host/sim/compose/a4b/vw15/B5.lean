import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
import host.sim.compose.a4b.vw15.B4
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw15.VWBodyChain
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B14
import host.sim.template.CallGen

section -- VWBodyOracles_10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_g40 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g40 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g40) (List.take 7 (List.drop 394 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site40 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site40 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site40) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st40.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g41 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g41 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g41) (List.take 3 (List.drop 401 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

noncomputable def PRE_first_tail_x15_r0_body.map_site41 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site41 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site41) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g42 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g42 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g42) (List.take 16 (List.drop 404 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site42 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site42 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site42) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st42.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g43 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g43 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g43) (List.take 7 (List.drop 420 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site43 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site43 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site43) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st43.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site40 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site40 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site40) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st40.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site40
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st40.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st40.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s398 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s399 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S398 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws40 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st40.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st40.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso40
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_40
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st40.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot40
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup40
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound40
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace40
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged40
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws40.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st40.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S398.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_40]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen40.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh40
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl40 : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s398.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl40 (PRE_first_tail_x15_r0_body.cncl39 bodyNcl39)

theorem bodyClean40 : Conv.JClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s398 :=
  PRE_first_tail_x15_r0_body.gjcl40 (PRE_first_tail_x15_r0_body.cjcl39 bodyClean39)

kernel_rfl bodyJsLe40 : Nat.ble PRE_first_tail_x15_r0_body.s390.next PRE_first_tail_x15_r0_body.s398.next = true
kernel_rfl bodyJsList40 : (PRE_first_tail_x15_r0_body.gjh40 ++ PRE_first_tail_x15_r0_body.cl40).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s398.next) PRE_first_tail_x15_r0_body.s400) = true
theorem bodyJs40 : JsHeapAbove PRE_first_tail_x15_r0_body.s398.next PRE_first_tail_x15_r0_body.s400 :=
  JsHeapAbove.glueSite bodyJs39 (Nat.le_of_ble_eq_true bodyJsLe40) PRE_first_tail_x15_r0_body.gjk40 PRE_first_tail_x15_r0_body.gjbd40 PRE_first_tail_x15_r0_body.cheap40 PRE_first_tail_x15_r0_body.zclbd40 bodyJsList40

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO392 : PRE_first_tail_x15_r0_body.S392.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S392.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr392 : bridgeOf PRE_first_tail_x15_r0_body.s392.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc392 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.S392) = fun _ _ => true
kernel_rfl bodyAcc393 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s393 PRE_first_tail_x15_r0_body.S393) = fun _ _ => true
kernel_rfl bodyBr394 : bridgeOf PRE_first_tail_x15_r0_body.s394.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt393 : isHalt PRE_first_tail_x15_r0_body.s393.ctl = false
kernel_rfl bodyTop394 : noRetBlock PRE_first_tail_x15_r0_body.s394 = true
kernel_rfl bodyCnt392 : countersOkB PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.s394 = true
kernel_rfl bodyO394 : PRE_first_tail_x15_r0_body.S394.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S394.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr395 : bridgeOf PRE_first_tail_x15_r0_body.s395.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt394 : countersOkB PRE_first_tail_x15_r0_body.s394 PRE_first_tail_x15_r0_body.s395 = true
kernel_rfl bodyO395 : PRE_first_tail_x15_r0_body.S395.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S395.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc395 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s395 PRE_first_tail_x15_r0_body.S395) = fun _ _ => true
kernel_rfl bodyAcc397 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s397 PRE_first_tail_x15_r0_body.S397) = fun _ _ => true
kernel_rfl bodyBr398 : bridgeOf PRE_first_tail_x15_r0_body.s398.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt397 : isHalt PRE_first_tail_x15_r0_body.s397.ctl = false
kernel_rfl bodyTop398 : noRetBlock PRE_first_tail_x15_r0_body.s398 = true
kernel_rfl bodyCnt395 : countersOkB PRE_first_tail_x15_r0_body.s395 PRE_first_tail_x15_r0_body.s398 = true

theorem bodyGlue40 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17977, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.S392)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17977, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.S398) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17977, 302, 0, 225⟩) bodyAcc392 PRE_first_tail_x15_r0_body.bodyRunSeg106 bodyAcc393 bodyHalt393 PRE_first_tail_x15_r0_body.bodyStepA107 bodyTop394 (fun _ hm => bodyO392 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr392).trans bodyInactive0) (bodyBr394.trans bodyBr392.symm) bodyCnt392 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17977, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA107 PRE_first_tail_x15_r0_body.sizeArgsA107 PRE_first_tail_x15_r0_body.sizeSymA107 PRE_first_tail_x15_r0_body.sizeMlxA107 PRE_first_tail_x15_r0_body.sizePayA107 PRE_first_tail_x15_r0_body.sizeTaA107 PRE_first_tail_x15_r0_body.sizeDecA107 PRE_first_tail_x15_r0_body.sizePreA107 PRE_first_tail_x15_r0_body.bodyPatchB107 (fun _ hm => bodyO394 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr394).trans bodyInactive0) (bodyBr395.trans bodyBr394.symm) bodyCnt394 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17977, 302, 0, 225⟩) bodyAcc395 PRE_first_tail_x15_r0_body.bodyRunSeg107 bodyAcc397 bodyHalt397 PRE_first_tail_x15_r0_body.bodyStepA108 bodyTop398 (fun _ hm => bodyO395 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr395).trans bodyInactive0) (bodyBr398.trans bodyBr395.symm) bodyCnt395 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift40 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S398.tab.length PRE_first_tail_x15_r0_body.s398.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P40.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P40 1790 PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.s400.ffi PRE_first_tail_x15_r0_body.s399.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_40
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_40
  have hcl : SSt (· < 1790) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s400.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S398.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_40] <;> decide) PRE_first_tail_x15_r0_body.cnodesK40 PRE_first_tail_x15_r0_body.cobjsK40
      PRE_first_tail_x15_r0_body.citemsK40 PRE_first_tail_x15_r0_body.cbd40 PRE_first_tail_x15_r0_body.csst40
  exact PRE_first_tail_x15_r0_body.cshift40 bodyNcl40 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_40] at this; exact this)


kernel_rfl bodyFramesEmpty40 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s399 a).isEmpty) = true
kernel_rfl bodyJsRoots40 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s398.next) PRE_first_tail_x15_r0_body.s400.trace PRE_first_tail_x15_r0_body.s400 = true
kernel_rfl bodyJsNative40 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s400.ffi) = true
kernel_rfl bodyLow40 : (PRE_first_tail_x15_r0_body.cws40 ++ PRE_first_tail_x15_r0_body.ws40).all (Nat.ble 9) = true
kernel_rfl bodyCntM40 : countersOkB PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.s399 = true
kernel_rfl bodyHi40 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).next setupP.E = true
kernel_rfl bodyNhi40 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge40 : bridgeOf PRE_first_tail_x15_r0_body.s399.ffi = bridgeOf PRE_first_tail_x15_r0_body.s398.ffi
kernel_rfl bodyNN40 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s398.ffi).nnext PRE_first_tail_x15_r0_body.P40.NL = true
kernel_rfl bodyXn40 : Nat.ble (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).next = true
kernel_rfl bodyLo40 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).next = true
theorem bodyFacts40 : BodySiteFacts PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.s399 PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S398 PRE_first_tail_x15_r0_body.S399 PRE_first_tail_x15_r0_body.S400
    PRE_first_tail_x15_r0_body.ws40 PRE_first_tail_x15_r0_body.cws40 PRE_first_tail_x15_r0_body.nr40 PRE_first_tail_x15_r0_body.pl40 PRE_first_tail_x15_r0_body.cl40 2706457 1790 PRE_first_tail_x15_r0_body.kd40 PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.P40
    ⟨18997, 16092, 2706455, 1790⟩ ⟨18997, 16092, 2706455, 1790⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap40
  clean := bodyClean40
  cfix := PRE_first_tail_x15_r0_body.cfix40
  zpl := PRE_first_tail_x15_r0_body.zpl40
  zplnd := PRE_first_tail_x15_r0_body.zplnd40
  zn1 := PRE_first_tail_x15_r0_body.zn140
  zfirst := PRE_first_tail_x15_r0_body.zfirst40
  zscn := PRE_first_tail_x15_r0_body.zscn40
  zsmn := PRE_first_tail_x15_r0_body.zsmn40
  zgrow := PRE_first_tail_x15_r0_body.zgrow40
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab40
  zfresh := PRE_first_tail_x15_r0_body.zfresh40
  zcnd := PRE_first_tail_x15_r0_body.zcnd40
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi40
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt40
  zgP := PRE_first_tail_x15_r0_body.zg40_2665
  zkP := PRE_first_tail_x15_r0_body.zk40_2665
  zmP := PRE_first_tail_x15_r0_body.zm40_2665
  zgC := PRE_first_tail_x15_r0_body.zg40_2673467
  zkC := PRE_first_tail_x15_r0_body.zk40_2673467
  zmC := PRE_first_tail_x15_r0_body.zm40_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw40_2673472
  zwV := PRE_first_tail_x15_r0_body.zw40_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap40
  zclbd := PRE_first_tail_x15_r0_body.zclbd40
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap40 PRE_first_tail_x15_r0_body.stFoot40 PRE_first_tail_x15_r0_body.iso40 PRE_first_tail_x15_r0_body.zwr40
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP40
  csupp := PRE_first_tail_x15_r0_body.csupp40
  cbound := PRE_first_tail_x15_r0_body.cbound40
  zimg := PRE_first_tail_x15_r0_body.zimg40
  zctl := PRE_first_tail_x15_r0_body.zctl40
  zstack := PRE_first_tail_x15_r0_body.zstack40
  zjobs := PRE_first_tail_x15_r0_body.zjobs40
  zstores := PRE_first_tail_x15_r0_body.zstores40
  zroots := PRE_first_tail_x15_r0_body.zroots40
  znC := PRE_first_tail_x15_r0_body.znC40
  ctab := PRE_first_tail_x15_r0_body.ctab40
  zbin := PRE_first_tail_x15_r0_body.zbin40
  cbridge := PRE_first_tail_x15_r0_body.cbridge40
  sbridge := bodyBridge40
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj40
  cshiftR := fun h hNL => bodyCshift40 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN40
  raised := PRE_first_tail_x15_r0_body.raised40
  cbigs := PRE_first_tail_x15_r0_body.cbigs40
  cjcl := PRE_first_tail_x15_r0_body.cjcl40
  xnLe := Nat.le_of_ble_eq_true bodyXn40
  loLe := Nat.le_of_ble_eq_true bodyLo40
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB40
  cntM := bodyCntM40
  hiLe := Nat.le_of_ble_eq_true bodyHi40
  nhiLe := Nat.le_of_ble_eq_true bodyNhi40
  jsHeap := bodyJs40
  jsRoots := bodyJsRoots40
  jsNative := bodyJsNative40
  framesEmpty := bodyFramesEmpty40
  trailOld := by decide
  lowVars := bodyLow40

def bodyQs40 : List (Option Q) := []
noncomputable def bodyEs40 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr40.map fun r => nth? PRE_first_tail_x15_r0_body.st40.S2.tab r
kernel_rfl bodyResChk40 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs40 bodyQs40) = true
kernel_rfl bodyLq40 : bodyQs40.length = PRE_first_tail_x15_r0_body.cws40.length
kernel_rfl bodyNrLo40 : PRE_first_tail_x15_r0_body.nr40.all (Nat.ble PRE_first_tail_x15_r0_body.S398.tab.length) = true
kernel_rfl bodySub40 : (Oracles.PRE_first_tail_x15_r0_body.map_site40.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost40 : postSubB bodyM PRE_first_tail_x15_r0_body.ws40 PRE_first_tail_x15_r0_body.cws40 bodyQs40 = true
kernel_rfl bodyDrop40 : Nat.ble (17977 + (PRE_first_tail_x15_r0_body.s399.next - PRE_first_tail_x15_r0_body.s400.next)) 17979 = true
kernel_rfl bodyDropH40 : Nat.ble (302 + ((mlxOf PRE_first_tail_x15_r0_body.s399.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).next)) 302 = true
kernel_rfl bodyDropN40 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s399.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).nnext)) 0 = true
kernel_rfl bodyDv40 : bodyΘ.1.take 225 = bodyΘ.1.take 225 ++ PRE_first_tail_x15_r0_body.cws40
kernel_rfl bodyDe40 : bodyΘ.2.take 225 = bodyΘ.2.take 225 ++ PRE_first_tail_x15_r0_body.nr40.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st40.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 225) (bodyΘ.2.take 225)))
kernel_rfl bodyDl40 : (bodyΘ.1.take 225).length = (bodyΘ.2.take 225).length
kernel_rfl bodyDold40 : (bodyΘ.1.take 225).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws40).isNone && !PRE_first_tail_x15_r0_body.ws40.contains v) = true
kernel_rfl bodyDfree40 : (bodyΘ.2.take 225).all (fun e => (PRE_first_tail_x15_r0_body.cws40 ++ PRE_first_tail_x15_r0_body.ws40).all fun w => e.noVar w) = true

theorem bodyStep40 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17977, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.S398)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.S400) (27 + 1) :=
  bodySite bodyFacts40.cfix bodyFacts40.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st40.S2.tab) (Es := bodyEs40) (qs := bodyQs40)
    (ok := PRE_first_tail_x15_r0_body.st40.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site40 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts40
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site40 r hr) hi (MapOk.sub hm (sub_of_all bodySub40)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk40 r hr) hi hm ho hq)
    bodyLq40 rfl bodyNrLo40 (postSub_sound bodyPost40)
    (Nat.le_of_ble_eq_true bodyDrop40) (by decide) (Nat.le_of_ble_eq_true bodyDropH40) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN40) (by decide)
    bodyDv40 bodyDe40 bodyDl40 bodyDold40 bodyDfree40 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x15_r0_body.map_site41 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site41 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site41) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site41
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s402 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s403 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S402 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws41 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso41
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_41
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot41
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup41
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound41
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace41
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged41
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws41.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st41.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S402.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_41]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen41.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh41
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl41 : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl41 (PRE_first_tail_x15_r0_body.cncl40 bodyNcl40)

theorem bodyClean41 : Conv.JClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s402 :=
  PRE_first_tail_x15_r0_body.gjcl41 (PRE_first_tail_x15_r0_body.cjcl40 bodyClean40)

kernel_rfl bodyJsLe41 : Nat.ble PRE_first_tail_x15_r0_body.s398.next PRE_first_tail_x15_r0_body.s402.next = true
kernel_rfl bodyJsList41 : (PRE_first_tail_x15_r0_body.gjh41 ++ PRE_first_tail_x15_r0_body.cl41).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s402.next) PRE_first_tail_x15_r0_body.s404) = true
theorem bodyJs41 : JsHeapAbove PRE_first_tail_x15_r0_body.s402.next PRE_first_tail_x15_r0_body.s404 :=
  JsHeapAbove.glueSite bodyJs40 (Nat.le_of_ble_eq_true bodyJsLe41) PRE_first_tail_x15_r0_body.gjk41 PRE_first_tail_x15_r0_body.gjbd41 PRE_first_tail_x15_r0_body.cheap41 PRE_first_tail_x15_r0_body.zclbd41 bodyJsList41

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO400 : PRE_first_tail_x15_r0_body.S400.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S400.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr400 : bridgeOf PRE_first_tail_x15_r0_body.s400.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc400 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.S400) = fun _ _ => true
kernel_rfl bodyAcc401 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s401 PRE_first_tail_x15_r0_body.S401) = fun _ _ => true
kernel_rfl bodyBr402 : bridgeOf PRE_first_tail_x15_r0_body.s402.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt401 : isHalt PRE_first_tail_x15_r0_body.s401.ctl = false
kernel_rfl bodyTop402 : noRetBlock PRE_first_tail_x15_r0_body.s402 = true
kernel_rfl bodyCnt400 : countersOkB PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.s402 = true

theorem bodyGlue41 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.S400)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.S402) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17979, 302, 0, 225⟩) bodyAcc400 PRE_first_tail_x15_r0_body.bodyRunSeg108 bodyAcc401 bodyHalt401 PRE_first_tail_x15_r0_body.bodyStepA109 bodyTop402 (fun _ hm => bodyO400 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr400).trans bodyInactive0) (bodyBr402.trans bodyBr400.symm) bodyCnt400 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift41 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S402.tab.length PRE_first_tail_x15_r0_body.s402.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P41.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P41 1807 PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.s404.ffi PRE_first_tail_x15_r0_body.s403.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_41
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_41
  have hcl : SSt (· < 1807) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S402.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_41] <;> decide) PRE_first_tail_x15_r0_body.cnodesK41 PRE_first_tail_x15_r0_body.cobjsK41
      PRE_first_tail_x15_r0_body.citemsK41 PRE_first_tail_x15_r0_body.cbd41 PRE_first_tail_x15_r0_body.csst41
  exact PRE_first_tail_x15_r0_body.cshift41 bodyNcl41 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_41] at this; exact this)


kernel_rfl bodyFramesEmpty41 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s403 a).isEmpty) = true
kernel_rfl bodyJsRoots41 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s402.next) PRE_first_tail_x15_r0_body.s404.trace PRE_first_tail_x15_r0_body.s404 = true
kernel_rfl bodyJsNative41 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s404.ffi) = true
kernel_rfl bodyLow41 : (PRE_first_tail_x15_r0_body.cws41 ++ PRE_first_tail_x15_r0_body.ws41).all (Nat.ble 9) = true
kernel_rfl bodyCntM41 : countersOkB PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.s403 = true
kernel_rfl bodyHi41 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).next setupP.E = true
kernel_rfl bodyNhi41 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge41 : bridgeOf PRE_first_tail_x15_r0_body.s403.ffi = bridgeOf PRE_first_tail_x15_r0_body.s402.ffi
kernel_rfl bodyNN41 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s402.ffi).nnext PRE_first_tail_x15_r0_body.P41.NL = true
kernel_rfl bodyXn41 : Nat.ble (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).next = true
kernel_rfl bodyLo41 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).next = true
theorem bodyFacts41 : BodySiteFacts PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.s403 PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S402 PRE_first_tail_x15_r0_body.S403 PRE_first_tail_x15_r0_body.S404
    PRE_first_tail_x15_r0_body.ws41 PRE_first_tail_x15_r0_body.cws41 PRE_first_tail_x15_r0_body.nr41 PRE_first_tail_x15_r0_body.pl41 PRE_first_tail_x15_r0_body.cl41 2706763 1807 PRE_first_tail_x15_r0_body.kd41 PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.P41
    ⟨19004, 16096, 2706743, 1807⟩ ⟨19004, 16096, 2706744, 1807⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap41
  clean := bodyClean41
  cfix := PRE_first_tail_x15_r0_body.cfix41
  zpl := PRE_first_tail_x15_r0_body.zpl41
  zplnd := PRE_first_tail_x15_r0_body.zplnd41
  zn1 := PRE_first_tail_x15_r0_body.zn141
  zfirst := PRE_first_tail_x15_r0_body.zfirst41
  zscn := PRE_first_tail_x15_r0_body.zscn41
  zsmn := PRE_first_tail_x15_r0_body.zsmn41
  zgrow := PRE_first_tail_x15_r0_body.zgrow41
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab41
  zfresh := PRE_first_tail_x15_r0_body.zfresh41
  zcnd := PRE_first_tail_x15_r0_body.zcnd41
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi41
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt41
  zgP := PRE_first_tail_x15_r0_body.zg41_2665
  zkP := PRE_first_tail_x15_r0_body.zk41_2665
  zmP := PRE_first_tail_x15_r0_body.zm41_2665
  zgC := PRE_first_tail_x15_r0_body.zg41_2673467
  zkC := PRE_first_tail_x15_r0_body.zk41_2673467
  zmC := PRE_first_tail_x15_r0_body.zm41_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw41_2673472
  zwV := PRE_first_tail_x15_r0_body.zw41_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap41
  zclbd := PRE_first_tail_x15_r0_body.zclbd41
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap41 PRE_first_tail_x15_r0_body.stFoot41 PRE_first_tail_x15_r0_body.iso41 PRE_first_tail_x15_r0_body.zwr41
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP41
  csupp := PRE_first_tail_x15_r0_body.csupp41
  cbound := PRE_first_tail_x15_r0_body.cbound41
  zimg := PRE_first_tail_x15_r0_body.zimg41
  zctl := PRE_first_tail_x15_r0_body.zctl41
  zstack := PRE_first_tail_x15_r0_body.zstack41
  zjobs := PRE_first_tail_x15_r0_body.zjobs41
  zstores := PRE_first_tail_x15_r0_body.zstores41
  zroots := PRE_first_tail_x15_r0_body.zroots41
  znC := PRE_first_tail_x15_r0_body.znC41
  ctab := PRE_first_tail_x15_r0_body.ctab41
  zbin := PRE_first_tail_x15_r0_body.zbin41
  cbridge := PRE_first_tail_x15_r0_body.cbridge41
  sbridge := bodyBridge41
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj41
  cshiftR := fun h hNL => bodyCshift41 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN41
  raised := PRE_first_tail_x15_r0_body.raised41
  cbigs := PRE_first_tail_x15_r0_body.cbigs41
  cjcl := PRE_first_tail_x15_r0_body.cjcl41
  xnLe := Nat.le_of_ble_eq_true bodyXn41
  loLe := Nat.le_of_ble_eq_true bodyLo41
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB41
  cntM := bodyCntM41
  hiLe := Nat.le_of_ble_eq_true bodyHi41
  nhiLe := Nat.le_of_ble_eq_true bodyNhi41
  jsHeap := bodyJs41
  jsRoots := bodyJsRoots41
  jsNative := bodyJsNative41
  framesEmpty := bodyFramesEmpty41
  trailOld := by decide
  lowVars := bodyLow41

def bodyQs41 : List (Option Q) := []
noncomputable def bodyEs41 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr41.map fun r => nth? PRE_first_tail_x15_r0_body.st41.S2.tab r
kernel_rfl bodyResChk41 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs41 bodyQs41) = true
kernel_rfl bodyLq41 : bodyQs41.length = PRE_first_tail_x15_r0_body.cws41.length
kernel_rfl bodyNrLo41 : PRE_first_tail_x15_r0_body.nr41.all (Nat.ble PRE_first_tail_x15_r0_body.S402.tab.length) = true
kernel_rfl bodySub41 : (Oracles.PRE_first_tail_x15_r0_body.map_site41.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost41 : postSubB bodyM PRE_first_tail_x15_r0_body.ws41 PRE_first_tail_x15_r0_body.cws41 bodyQs41 = true
kernel_rfl bodyDrop41 : Nat.ble (17979 + (PRE_first_tail_x15_r0_body.s403.next - PRE_first_tail_x15_r0_body.s404.next)) 17998 = true
kernel_rfl bodyDropH41 : Nat.ble (302 + ((mlxOf PRE_first_tail_x15_r0_body.s403.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).next)) 302 = true
kernel_rfl bodyDropN41 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s403.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).nnext)) 0 = true
kernel_rfl bodyDv41 : bodyΘ.1.take 225 = bodyΘ.1.take 225 ++ PRE_first_tail_x15_r0_body.cws41
kernel_rfl bodyDe41 : bodyΘ.2.take 225 = bodyΘ.2.take 225 ++ PRE_first_tail_x15_r0_body.nr41.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st41.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 225) (bodyΘ.2.take 225)))
kernel_rfl bodyDl41 : (bodyΘ.1.take 225).length = (bodyΘ.2.take 225).length
kernel_rfl bodyDold41 : (bodyΘ.1.take 225).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws41).isNone && !PRE_first_tail_x15_r0_body.ws41.contains v) = true
kernel_rfl bodyDfree41 : (bodyΘ.2.take 225).all (fun e => (PRE_first_tail_x15_r0_body.cws41 ++ PRE_first_tail_x15_r0_body.ws41).all fun w => e.noVar w) = true

theorem bodyStep41 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.S402)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17998, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.S404) (206 + 1) :=
  bodySite bodyFacts41.cfix bodyFacts41.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st41.S2.tab) (Es := bodyEs41) (qs := bodyQs41)
    (ok := PRE_first_tail_x15_r0_body.st41.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site41 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts41
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site41 r hr) hi (MapOk.sub hm (sub_of_all bodySub41)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk41 r hr) hi hm ho hq)
    bodyLq41 rfl bodyNrLo41 (postSub_sound bodyPost41)
    (Nat.le_of_ble_eq_true bodyDrop41) (by decide) (Nat.le_of_ble_eq_true bodyDropH41) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN41) (by decide)
    bodyDv41 bodyDe41 bodyDl41 bodyDold41 bodyDfree41 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site42 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site42 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site42) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st42.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site42
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st42.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st42.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s419 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s420 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S419 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws42 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st42.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st42.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso42
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_42
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st42.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot42
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup42
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound42
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace42
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged42
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws42.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st42.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S419.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_42]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen42.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh42
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl42 : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s419.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl42 (PRE_first_tail_x15_r0_body.cncl41 bodyNcl41)

theorem bodyClean42 : Conv.JClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s419 :=
  PRE_first_tail_x15_r0_body.gjcl42 (PRE_first_tail_x15_r0_body.cjcl41 bodyClean41)

kernel_rfl bodyJsLe42 : Nat.ble PRE_first_tail_x15_r0_body.s402.next PRE_first_tail_x15_r0_body.s419.next = true
kernel_rfl bodyJsList42 : (PRE_first_tail_x15_r0_body.gjh42 ++ PRE_first_tail_x15_r0_body.cl42).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s419.next) PRE_first_tail_x15_r0_body.s421) = true
theorem bodyJs42 : JsHeapAbove PRE_first_tail_x15_r0_body.s419.next PRE_first_tail_x15_r0_body.s421 :=
  JsHeapAbove.glueSite bodyJs41 (Nat.le_of_ble_eq_true bodyJsLe42) PRE_first_tail_x15_r0_body.gjk42 PRE_first_tail_x15_r0_body.gjbd42 PRE_first_tail_x15_r0_body.cheap42 PRE_first_tail_x15_r0_body.zclbd42 bodyJsList42

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO404 : PRE_first_tail_x15_r0_body.S404.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S404.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr404 : bridgeOf PRE_first_tail_x15_r0_body.s404.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc404 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.S404) = fun _ _ => true
kernel_rfl bodyAcc406 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s406 PRE_first_tail_x15_r0_body.S406) = fun _ _ => true
kernel_rfl bodyBr407 : bridgeOf PRE_first_tail_x15_r0_body.s407.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt406 : isHalt PRE_first_tail_x15_r0_body.s406.ctl = false
kernel_rfl bodyTop407 : noRetBlock PRE_first_tail_x15_r0_body.s407 = true
kernel_rfl bodyCnt404 : countersOkB PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.s407 = true
kernel_rfl bodyO407 : PRE_first_tail_x15_r0_body.S407.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S407.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr408 : bridgeOf PRE_first_tail_x15_r0_body.s408.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt407 : countersOkB PRE_first_tail_x15_r0_body.s407 PRE_first_tail_x15_r0_body.s408 = true
kernel_rfl bodyO408 : PRE_first_tail_x15_r0_body.S408.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S408.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc408 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s408 PRE_first_tail_x15_r0_body.S408) = fun _ _ => true
kernel_rfl bodyAcc409 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s409 PRE_first_tail_x15_r0_body.S409) = fun _ _ => true
kernel_rfl bodyBr410 : bridgeOf PRE_first_tail_x15_r0_body.s410.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt409 : isHalt PRE_first_tail_x15_r0_body.s409.ctl = false
kernel_rfl bodyTop410 : noRetBlock PRE_first_tail_x15_r0_body.s410 = true
kernel_rfl bodyCnt408 : countersOkB PRE_first_tail_x15_r0_body.s408 PRE_first_tail_x15_r0_body.s410 = true
kernel_rfl bodyO410 : PRE_first_tail_x15_r0_body.S410.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S410.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr411 : bridgeOf PRE_first_tail_x15_r0_body.s411.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt410 : countersOkB PRE_first_tail_x15_r0_body.s410 PRE_first_tail_x15_r0_body.s411 = true
kernel_rfl bodyO411 : PRE_first_tail_x15_r0_body.S411.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S411.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc411 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s411 PRE_first_tail_x15_r0_body.S411) = fun _ _ => true
kernel_rfl bodyAcc412 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s412 PRE_first_tail_x15_r0_body.S412) = fun _ _ => true
kernel_rfl bodyBr413 : bridgeOf PRE_first_tail_x15_r0_body.s413.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt412 : isHalt PRE_first_tail_x15_r0_body.s412.ctl = false
kernel_rfl bodyTop413 : noRetBlock PRE_first_tail_x15_r0_body.s413 = true
kernel_rfl bodyCnt411 : countersOkB PRE_first_tail_x15_r0_body.s411 PRE_first_tail_x15_r0_body.s413 = true
kernel_rfl bodyO413 : PRE_first_tail_x15_r0_body.S413.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S413.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr414 : bridgeOf PRE_first_tail_x15_r0_body.s414.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt413 : countersOkB PRE_first_tail_x15_r0_body.s413 PRE_first_tail_x15_r0_body.s414 = true
kernel_rfl bodyO414 : PRE_first_tail_x15_r0_body.S414.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S414.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc414 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s414 PRE_first_tail_x15_r0_body.S414) = fun _ _ => true
kernel_rfl bodyAcc415 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s415 PRE_first_tail_x15_r0_body.S415) = fun _ _ => true
kernel_rfl bodyBr416 : bridgeOf PRE_first_tail_x15_r0_body.s416.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt415 : isHalt PRE_first_tail_x15_r0_body.s415.ctl = false
kernel_rfl bodyTop416 : noRetBlock PRE_first_tail_x15_r0_body.s416 = true
kernel_rfl bodyCnt414 : countersOkB PRE_first_tail_x15_r0_body.s414 PRE_first_tail_x15_r0_body.s416 = true
kernel_rfl bodyO416 : PRE_first_tail_x15_r0_body.S416.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S416.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr417 : bridgeOf PRE_first_tail_x15_r0_body.s417.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt416 : countersOkB PRE_first_tail_x15_r0_body.s416 PRE_first_tail_x15_r0_body.s417 = true
kernel_rfl bodyO417 : PRE_first_tail_x15_r0_body.S417.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S417.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc417 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s417 PRE_first_tail_x15_r0_body.S417) = fun _ _ => true
kernel_rfl bodyAcc418 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s418 PRE_first_tail_x15_r0_body.S418) = fun _ _ => true
kernel_rfl bodyBr419 : bridgeOf PRE_first_tail_x15_r0_body.s419.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt418 : isHalt PRE_first_tail_x15_r0_body.s418.ctl = false
kernel_rfl bodyTop419 : noRetBlock PRE_first_tail_x15_r0_body.s419 = true
kernel_rfl bodyCnt417 : countersOkB PRE_first_tail_x15_r0_body.s417 PRE_first_tail_x15_r0_body.s419 = true

theorem bodyGlue42 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17998, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.S404)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17998, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s419 PRE_first_tail_x15_r0_body.S419) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc404 PRE_first_tail_x15_r0_body.bodyRunSeg109 bodyAcc406 bodyHalt406 PRE_first_tail_x15_r0_body.bodyStepA110 bodyTop407 (fun _ hm => bodyO404 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr404).trans bodyInactive0) (bodyBr407.trans bodyBr404.symm) bodyCnt404 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA110 PRE_first_tail_x15_r0_body.sizeArgsA110 PRE_first_tail_x15_r0_body.sizeSymA110 PRE_first_tail_x15_r0_body.sizeMlxA110 PRE_first_tail_x15_r0_body.sizePayA110 PRE_first_tail_x15_r0_body.sizeTaA110 PRE_first_tail_x15_r0_body.sizeDecA110 PRE_first_tail_x15_r0_body.sizePreA110 PRE_first_tail_x15_r0_body.bodyPatchB110 (fun _ hm => bodyO407 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr407).trans bodyInactive0) (bodyBr408.trans bodyBr407.symm) bodyCnt407 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc408 PRE_first_tail_x15_r0_body.bodyRunSeg110 bodyAcc409 bodyHalt409 PRE_first_tail_x15_r0_body.bodyStepA111 bodyTop410 (fun _ hm => bodyO408 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr408).trans bodyInactive0) (bodyBr410.trans bodyBr408.symm) bodyCnt408 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA111 PRE_first_tail_x15_r0_body.sizeArgsA111 PRE_first_tail_x15_r0_body.sizeSymA111 PRE_first_tail_x15_r0_body.sizeMlxA111 PRE_first_tail_x15_r0_body.sizePayA111 PRE_first_tail_x15_r0_body.sizeTaA111 PRE_first_tail_x15_r0_body.sizeDecA111 PRE_first_tail_x15_r0_body.sizePreA111 PRE_first_tail_x15_r0_body.bodyPatchB111 (fun _ hm => bodyO410 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr410).trans bodyInactive0) (bodyBr411.trans bodyBr410.symm) bodyCnt410 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc411 PRE_first_tail_x15_r0_body.bodyRunSeg111 bodyAcc412 bodyHalt412 PRE_first_tail_x15_r0_body.bodyStepA112 bodyTop413 (fun _ hm => bodyO411 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr411).trans bodyInactive0) (bodyBr413.trans bodyBr411.symm) bodyCnt411 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA112 PRE_first_tail_x15_r0_body.sizeArgsA112 PRE_first_tail_x15_r0_body.sizeSymA112 PRE_first_tail_x15_r0_body.sizeMlxA112 PRE_first_tail_x15_r0_body.sizePayA112 PRE_first_tail_x15_r0_body.sizeTaA112 PRE_first_tail_x15_r0_body.sizeDecA112 PRE_first_tail_x15_r0_body.sizePreA112 PRE_first_tail_x15_r0_body.bodyPatchB112 (fun _ hm => bodyO413 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr413).trans bodyInactive0) (bodyBr414.trans bodyBr413.symm) bodyCnt413 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc414 PRE_first_tail_x15_r0_body.bodyRunSeg112 bodyAcc415 bodyHalt415 PRE_first_tail_x15_r0_body.bodyStepA113 bodyTop416 (fun _ hm => bodyO414 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr414).trans bodyInactive0) (bodyBr416.trans bodyBr414.symm) bodyCnt414 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA113 PRE_first_tail_x15_r0_body.sizeArgsA113 PRE_first_tail_x15_r0_body.sizeSymA113 PRE_first_tail_x15_r0_body.sizeMlxA113 PRE_first_tail_x15_r0_body.sizePayA113 PRE_first_tail_x15_r0_body.sizeTaA113 PRE_first_tail_x15_r0_body.sizeDecA113 PRE_first_tail_x15_r0_body.sizePreA113 PRE_first_tail_x15_r0_body.bodyPatchB113 (fun _ hm => bodyO416 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr416).trans bodyInactive0) (bodyBr417.trans bodyBr416.symm) bodyCnt416 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc417 PRE_first_tail_x15_r0_body.bodyRunSeg113 bodyAcc418 bodyHalt418 PRE_first_tail_x15_r0_body.bodyStepA114 bodyTop419 (fun _ hm => bodyO417 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr417).trans bodyInactive0) (bodyBr419.trans bodyBr417.symm) bodyCnt417 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift42 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S419.tab.length PRE_first_tail_x15_r0_body.s419.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P42.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P42 1898 PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.s421.ffi PRE_first_tail_x15_r0_body.s420.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_42
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_42
  have hcl : SSt (· < 1898) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s421.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S419.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_42] <;> decide) PRE_first_tail_x15_r0_body.cnodesK42 PRE_first_tail_x15_r0_body.cobjsK42
      PRE_first_tail_x15_r0_body.citemsK42 PRE_first_tail_x15_r0_body.cbd42 PRE_first_tail_x15_r0_body.csst42
  exact PRE_first_tail_x15_r0_body.cshift42 bodyNcl42 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_42] at this; exact this)


kernel_rfl bodyFramesEmpty42 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s420 a).isEmpty) = true
kernel_rfl bodyJsRoots42 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s419.next) PRE_first_tail_x15_r0_body.s421.trace PRE_first_tail_x15_r0_body.s421 = true
kernel_rfl bodyJsNative42 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s421.ffi) = true
kernel_rfl bodyLow42 : (PRE_first_tail_x15_r0_body.cws42 ++ PRE_first_tail_x15_r0_body.ws42).all (Nat.ble 9) = true
kernel_rfl bodyCntM42 : countersOkB PRE_first_tail_x15_r0_body.s419 PRE_first_tail_x15_r0_body.s420 = true
kernel_rfl bodyHi42 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).next setupP.E = true
kernel_rfl bodyNhi42 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge42 : bridgeOf PRE_first_tail_x15_r0_body.s420.ffi = bridgeOf PRE_first_tail_x15_r0_body.s419.ffi
kernel_rfl bodyNN42 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s419.ffi).nnext PRE_first_tail_x15_r0_body.P42.NL = true
kernel_rfl bodyXn42 : Nat.ble (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).next = true
kernel_rfl bodyLo42 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).next = true
theorem bodyFacts42 : BodySiteFacts PRE_first_tail_x15_r0_body.s419 PRE_first_tail_x15_r0_body.s420 PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S419 PRE_first_tail_x15_r0_body.S420 PRE_first_tail_x15_r0_body.S421
    PRE_first_tail_x15_r0_body.ws42 PRE_first_tail_x15_r0_body.cws42 PRE_first_tail_x15_r0_body.nr42 PRE_first_tail_x15_r0_body.pl42 PRE_first_tail_x15_r0_body.cl42 2709374 1898 PRE_first_tail_x15_r0_body.kd42 PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.P42
    ⟨19038, 16115, 2708219, 1880⟩ ⟨19041, 16142, 2708225, 1898⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap42
  clean := bodyClean42
  cfix := PRE_first_tail_x15_r0_body.cfix42
  zpl := PRE_first_tail_x15_r0_body.zpl42
  zplnd := PRE_first_tail_x15_r0_body.zplnd42
  zn1 := PRE_first_tail_x15_r0_body.zn142
  zfirst := PRE_first_tail_x15_r0_body.zfirst42
  zscn := PRE_first_tail_x15_r0_body.zscn42
  zsmn := PRE_first_tail_x15_r0_body.zsmn42
  zgrow := PRE_first_tail_x15_r0_body.zgrow42
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab42
  zfresh := PRE_first_tail_x15_r0_body.zfresh42
  zcnd := PRE_first_tail_x15_r0_body.zcnd42
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi42
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt42
  zgP := PRE_first_tail_x15_r0_body.zg42_2665
  zkP := PRE_first_tail_x15_r0_body.zk42_2665
  zmP := PRE_first_tail_x15_r0_body.zm42_2665
  zgC := PRE_first_tail_x15_r0_body.zg42_2673467
  zkC := PRE_first_tail_x15_r0_body.zk42_2673467
  zmC := PRE_first_tail_x15_r0_body.zm42_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw42_2673472
  zwV := PRE_first_tail_x15_r0_body.zw42_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap42
  zclbd := PRE_first_tail_x15_r0_body.zclbd42
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap42 PRE_first_tail_x15_r0_body.stFoot42 PRE_first_tail_x15_r0_body.iso42 PRE_first_tail_x15_r0_body.zwr42
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP42
  csupp := PRE_first_tail_x15_r0_body.csupp42
  cbound := PRE_first_tail_x15_r0_body.cbound42
  zimg := PRE_first_tail_x15_r0_body.zimg42
  zctl := PRE_first_tail_x15_r0_body.zctl42
  zstack := PRE_first_tail_x15_r0_body.zstack42
  zjobs := PRE_first_tail_x15_r0_body.zjobs42
  zstores := PRE_first_tail_x15_r0_body.zstores42
  zroots := PRE_first_tail_x15_r0_body.zroots42
  znC := PRE_first_tail_x15_r0_body.znC42
  ctab := PRE_first_tail_x15_r0_body.ctab42
  zbin := PRE_first_tail_x15_r0_body.zbin42
  cbridge := PRE_first_tail_x15_r0_body.cbridge42
  sbridge := bodyBridge42
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj42
  cshiftR := fun h hNL => bodyCshift42 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN42
  raised := PRE_first_tail_x15_r0_body.raised42
  cbigs := PRE_first_tail_x15_r0_body.cbigs42
  cjcl := PRE_first_tail_x15_r0_body.cjcl42
  xnLe := Nat.le_of_ble_eq_true bodyXn42
  loLe := Nat.le_of_ble_eq_true bodyLo42
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB42
  cntM := bodyCntM42
  hiLe := Nat.le_of_ble_eq_true bodyHi42
  nhiLe := Nat.le_of_ble_eq_true bodyNhi42
  jsHeap := bodyJs42
  jsRoots := bodyJsRoots42
  jsNative := bodyJsNative42
  framesEmpty := bodyFramesEmpty42
  trailOld := by decide
  lowVars := bodyLow42

def bodyQs42 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs42 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr42.map fun r => nth? PRE_first_tail_x15_r0_body.st42.S5.tab r
kernel_rfl bodyResChk42 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs42 bodyQs42) = true
kernel_rfl bodyLq42 : bodyQs42.length = PRE_first_tail_x15_r0_body.cws42.length
kernel_rfl bodyNrLo42 : PRE_first_tail_x15_r0_body.nr42.all (Nat.ble PRE_first_tail_x15_r0_body.S419.tab.length) = true
kernel_rfl bodySub42 : (Oracles.PRE_first_tail_x15_r0_body.map_site42.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost42 : postSubB bodyM PRE_first_tail_x15_r0_body.ws42 PRE_first_tail_x15_r0_body.cws42 bodyQs42 = true
kernel_rfl bodyDrop42 : Nat.ble (17998 + (PRE_first_tail_x15_r0_body.s420.next - PRE_first_tail_x15_r0_body.s421.next)) 19147 = true
kernel_rfl bodyDropH42 : Nat.ble (302 + ((mlxOf PRE_first_tail_x15_r0_body.s420.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).next)) 327 = true
kernel_rfl bodyDropN42 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s420.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).nnext)) 0 = true
kernel_rfl bodyDv42 : bodyΘ.1.take 243 = bodyΘ.1.take 225 ++ PRE_first_tail_x15_r0_body.cws42
kernel_rfl bodyDe42 : bodyΘ.2.take 243 = bodyΘ.2.take 225 ++ PRE_first_tail_x15_r0_body.nr42.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st42.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 225) (bodyΘ.2.take 225)))
kernel_rfl bodyDl42 : (bodyΘ.1.take 225).length = (bodyΘ.2.take 225).length
kernel_rfl bodyDold42 : (bodyΘ.1.take 225).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws42).isNone && !PRE_first_tail_x15_r0_body.ws42.contains v) = true
kernel_rfl bodyDfree42 : (bodyΘ.2.take 243).all (fun e => (PRE_first_tail_x15_r0_body.cws42 ++ PRE_first_tail_x15_r0_body.ws42).all fun w => e.noVar w) = true

theorem bodyStep42 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17998, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s419 PRE_first_tail_x15_r0_body.S419)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19147, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.S421) (11334 + 1) :=
  bodySite bodyFacts42.cfix bodyFacts42.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st42.S5.tab) (Es := bodyEs42) (qs := bodyQs42)
    (ok := PRE_first_tail_x15_r0_body.st42.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site42 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts42
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site42 r hr) hi (MapOk.sub hm (sub_of_all bodySub42)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk42 r hr) hi hm ho hq)
    bodyLq42 rfl bodyNrLo42 (postSub_sound bodyPost42)
    (Nat.le_of_ble_eq_true bodyDrop42) (by decide) (Nat.le_of_ble_eq_true bodyDropH42) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN42) (by decide)
    bodyDv42 bodyDe42 bodyDl42 bodyDold42 bodyDfree42 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site43 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site43 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site43) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st43.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site43
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s427 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s428 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S427 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws43 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st43.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st43.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso43
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_43
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st43.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot43
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup43
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound43
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace43
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged43
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws43.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st43.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S427.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_43]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen43.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh43
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl43 : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl43 (PRE_first_tail_x15_r0_body.cncl42 bodyNcl42)

theorem bodyClean43 : Conv.JClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s427 :=
  PRE_first_tail_x15_r0_body.gjcl43 (PRE_first_tail_x15_r0_body.cjcl42 bodyClean42)

kernel_rfl bodyJsLe43 : Nat.ble PRE_first_tail_x15_r0_body.s419.next PRE_first_tail_x15_r0_body.s427.next = true
kernel_rfl bodyJsList43 : (PRE_first_tail_x15_r0_body.gjh43 ++ PRE_first_tail_x15_r0_body.cl43).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s427.next) PRE_first_tail_x15_r0_body.s429) = true
theorem bodyJs43 : JsHeapAbove PRE_first_tail_x15_r0_body.s427.next PRE_first_tail_x15_r0_body.s429 :=
  JsHeapAbove.glueSite bodyJs42 (Nat.le_of_ble_eq_true bodyJsLe43) PRE_first_tail_x15_r0_body.gjk43 PRE_first_tail_x15_r0_body.gjbd43 PRE_first_tail_x15_r0_body.cheap43 PRE_first_tail_x15_r0_body.zclbd43 bodyJsList43

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO421 : PRE_first_tail_x15_r0_body.S421.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S421.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr421 : bridgeOf PRE_first_tail_x15_r0_body.s421.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc421 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.S421) = fun _ _ => true
kernel_rfl bodyAcc422 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s422 PRE_first_tail_x15_r0_body.S422) = fun _ _ => true
kernel_rfl bodyBr423 : bridgeOf PRE_first_tail_x15_r0_body.s423.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt422 : isHalt PRE_first_tail_x15_r0_body.s422.ctl = false
kernel_rfl bodyTop423 : noRetBlock PRE_first_tail_x15_r0_body.s423 = true
kernel_rfl bodyCnt421 : countersOkB PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.s423 = true
kernel_rfl bodyO423 : PRE_first_tail_x15_r0_body.S423.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S423.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr424 : bridgeOf PRE_first_tail_x15_r0_body.s424.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt423 : countersOkB PRE_first_tail_x15_r0_body.s423 PRE_first_tail_x15_r0_body.s424 = true
kernel_rfl bodyO424 : PRE_first_tail_x15_r0_body.S424.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S424.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc424 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s424 PRE_first_tail_x15_r0_body.S424) = fun _ _ => true
kernel_rfl bodyAcc426 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s426 PRE_first_tail_x15_r0_body.S426) = fun _ _ => true
kernel_rfl bodyBr427 : bridgeOf PRE_first_tail_x15_r0_body.s427.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt426 : isHalt PRE_first_tail_x15_r0_body.s426.ctl = false
kernel_rfl bodyTop427 : noRetBlock PRE_first_tail_x15_r0_body.s427 = true
kernel_rfl bodyCnt424 : countersOkB PRE_first_tail_x15_r0_body.s424 PRE_first_tail_x15_r0_body.s427 = true

theorem bodyGlue43 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19147, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.S421)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19147, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.S427) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19147, 327, 0, 243⟩) bodyAcc421 PRE_first_tail_x15_r0_body.bodyRunSeg114 bodyAcc422 bodyHalt422 PRE_first_tail_x15_r0_body.bodyStepA115 bodyTop423 (fun _ hm => bodyO421 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr421).trans bodyInactive0) (bodyBr423.trans bodyBr421.symm) bodyCnt421 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19147, 327, 0, 243⟩) PRE_first_tail_x15_r0_body.sizeA115 PRE_first_tail_x15_r0_body.sizeArgsA115 PRE_first_tail_x15_r0_body.sizeSymA115 PRE_first_tail_x15_r0_body.sizeMlxA115 PRE_first_tail_x15_r0_body.sizePayA115 PRE_first_tail_x15_r0_body.sizeTaA115 PRE_first_tail_x15_r0_body.sizeDecA115 PRE_first_tail_x15_r0_body.sizePreA115 PRE_first_tail_x15_r0_body.bodyPatchB115 (fun _ hm => bodyO423 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr423).trans bodyInactive0) (bodyBr424.trans bodyBr423.symm) bodyCnt423 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19147, 327, 0, 243⟩) bodyAcc424 PRE_first_tail_x15_r0_body.bodyRunSeg115 bodyAcc426 bodyHalt426 PRE_first_tail_x15_r0_body.bodyStepA116 bodyTop427 (fun _ hm => bodyO424 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr424).trans bodyInactive0) (bodyBr427.trans bodyBr424.symm) bodyCnt424 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift43 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S427.tab.length PRE_first_tail_x15_r0_body.s427.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P43.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P43 1919 PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.s429.ffi PRE_first_tail_x15_r0_body.s428.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_43
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_43
  have hcl : SSt (· < 1919) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S427.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_43] <;> decide) PRE_first_tail_x15_r0_body.cnodesK43 PRE_first_tail_x15_r0_body.cobjsK43
      PRE_first_tail_x15_r0_body.citemsK43 PRE_first_tail_x15_r0_body.cbd43 PRE_first_tail_x15_r0_body.csst43
  exact PRE_first_tail_x15_r0_body.cshift43 bodyNcl43 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_43] at this; exact this)


kernel_rfl bodyFramesEmpty43 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s428 a).isEmpty) = true
kernel_rfl bodyJsRoots43 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s427.next) PRE_first_tail_x15_r0_body.s429.trace PRE_first_tail_x15_r0_body.s429 = true
kernel_rfl bodyJsNative43 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s429.ffi) = true
kernel_rfl bodyLow43 : (PRE_first_tail_x15_r0_body.cws43 ++ PRE_first_tail_x15_r0_body.ws43).all (Nat.ble 9) = true
kernel_rfl bodyCntM43 : countersOkB PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.s428 = true
kernel_rfl bodyHi43 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).next setupP.E = true
kernel_rfl bodyNhi43 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge43 : bridgeOf PRE_first_tail_x15_r0_body.s428.ffi = bridgeOf PRE_first_tail_x15_r0_body.s427.ffi
kernel_rfl bodyNN43 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s427.ffi).nnext PRE_first_tail_x15_r0_body.P43.NL = true
kernel_rfl bodyXn43 : Nat.ble (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).next = true
kernel_rfl bodyLo43 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).next = true
theorem bodyFacts43 : BodySiteFacts PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.s428 PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S427 PRE_first_tail_x15_r0_body.S428 PRE_first_tail_x15_r0_body.S429
    PRE_first_tail_x15_r0_body.ws43 PRE_first_tail_x15_r0_body.cws43 PRE_first_tail_x15_r0_body.nr43 PRE_first_tail_x15_r0_body.pl43 PRE_first_tail_x15_r0_body.cl43 2708717 1919 PRE_first_tail_x15_r0_body.kd43 PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.P43
    ⟨19054, 16155, 2708715, 1919⟩ ⟨19054, 16155, 2708715, 1919⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap43
  clean := bodyClean43
  cfix := PRE_first_tail_x15_r0_body.cfix43
  zpl := PRE_first_tail_x15_r0_body.zpl43
  zplnd := PRE_first_tail_x15_r0_body.zplnd43
  zn1 := PRE_first_tail_x15_r0_body.zn143
  zfirst := PRE_first_tail_x15_r0_body.zfirst43
  zscn := PRE_first_tail_x15_r0_body.zscn43
  zsmn := PRE_first_tail_x15_r0_body.zsmn43
  zgrow := PRE_first_tail_x15_r0_body.zgrow43
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab43
  zfresh := PRE_first_tail_x15_r0_body.zfresh43
  zcnd := PRE_first_tail_x15_r0_body.zcnd43
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi43
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt43
  zgP := PRE_first_tail_x15_r0_body.zg43_2665
  zkP := PRE_first_tail_x15_r0_body.zk43_2665
  zmP := PRE_first_tail_x15_r0_body.zm43_2665
  zgC := PRE_first_tail_x15_r0_body.zg43_2673467
  zkC := PRE_first_tail_x15_r0_body.zk43_2673467
  zmC := PRE_first_tail_x15_r0_body.zm43_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw43_2673472
  zwV := PRE_first_tail_x15_r0_body.zw43_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap43
  zclbd := PRE_first_tail_x15_r0_body.zclbd43
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap43 PRE_first_tail_x15_r0_body.stFoot43 PRE_first_tail_x15_r0_body.iso43 PRE_first_tail_x15_r0_body.zwr43
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP43
  csupp := PRE_first_tail_x15_r0_body.csupp43
  cbound := PRE_first_tail_x15_r0_body.cbound43
  zimg := PRE_first_tail_x15_r0_body.zimg43
  zctl := PRE_first_tail_x15_r0_body.zctl43
  zstack := PRE_first_tail_x15_r0_body.zstack43
  zjobs := PRE_first_tail_x15_r0_body.zjobs43
  zstores := PRE_first_tail_x15_r0_body.zstores43
  zroots := PRE_first_tail_x15_r0_body.zroots43
  znC := PRE_first_tail_x15_r0_body.znC43
  ctab := PRE_first_tail_x15_r0_body.ctab43
  zbin := PRE_first_tail_x15_r0_body.zbin43
  cbridge := PRE_first_tail_x15_r0_body.cbridge43
  sbridge := bodyBridge43
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj43
  cshiftR := fun h hNL => bodyCshift43 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN43
  raised := PRE_first_tail_x15_r0_body.raised43
  cbigs := PRE_first_tail_x15_r0_body.cbigs43
  cjcl := PRE_first_tail_x15_r0_body.cjcl43
  xnLe := Nat.le_of_ble_eq_true bodyXn43
  loLe := Nat.le_of_ble_eq_true bodyLo43
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB43
  cntM := bodyCntM43
  hiLe := Nat.le_of_ble_eq_true bodyHi43
  nhiLe := Nat.le_of_ble_eq_true bodyNhi43
  jsHeap := bodyJs43
  jsRoots := bodyJsRoots43
  jsNative := bodyJsNative43
  framesEmpty := bodyFramesEmpty43
  trailOld := by decide
  lowVars := bodyLow43

def bodyQs43 : List (Option Q) := []
noncomputable def bodyEs43 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr43.map fun r => nth? PRE_first_tail_x15_r0_body.st43.S2.tab r
kernel_rfl bodyResChk43 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs43 bodyQs43) = true
kernel_rfl bodyLq43 : bodyQs43.length = PRE_first_tail_x15_r0_body.cws43.length
kernel_rfl bodyNrLo43 : PRE_first_tail_x15_r0_body.nr43.all (Nat.ble PRE_first_tail_x15_r0_body.S427.tab.length) = true
kernel_rfl bodySub43 : (Oracles.PRE_first_tail_x15_r0_body.map_site43.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost43 : postSubB bodyM PRE_first_tail_x15_r0_body.ws43 PRE_first_tail_x15_r0_body.cws43 bodyQs43 = true
kernel_rfl bodyDrop43 : Nat.ble (19147 + (PRE_first_tail_x15_r0_body.s428.next - PRE_first_tail_x15_r0_body.s429.next)) 19149 = true
kernel_rfl bodyDropH43 : Nat.ble (327 + ((mlxOf PRE_first_tail_x15_r0_body.s428.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).next)) 327 = true
kernel_rfl bodyDropN43 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s428.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).nnext)) 0 = true
kernel_rfl bodyDv43 : bodyΘ.1.take 243 = bodyΘ.1.take 243 ++ PRE_first_tail_x15_r0_body.cws43
kernel_rfl bodyDe43 : bodyΘ.2.take 243 = bodyΘ.2.take 243 ++ PRE_first_tail_x15_r0_body.nr43.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st43.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 243) (bodyΘ.2.take 243)))
kernel_rfl bodyDl43 : (bodyΘ.1.take 243).length = (bodyΘ.2.take 243).length
kernel_rfl bodyDold43 : (bodyΘ.1.take 243).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws43).isNone && !PRE_first_tail_x15_r0_body.ws43.contains v) = true
kernel_rfl bodyDfree43 : (bodyΘ.2.take 243).all (fun e => (PRE_first_tail_x15_r0_body.cws43 ++ PRE_first_tail_x15_r0_body.ws43).all fun w => e.noVar w) = true

theorem bodyStep43 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19147, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.S427)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19149, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.S429) (27 + 1) :=
  bodySite bodyFacts43.cfix bodyFacts43.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st43.S2.tab) (Es := bodyEs43) (qs := bodyQs43)
    (ok := PRE_first_tail_x15_r0_body.st43.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site43 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts43
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site43 r hr) hi (MapOk.sub hm (sub_of_all bodySub43)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk43 r hr) hi hm ho hq)
    bodyLq43 rfl bodyNrLo43 (postSub_sound bodyPost43)
    (Nat.le_of_ble_eq_true bodyDrop43) (by decide) (Nat.le_of_ble_eq_true bodyDropH43) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN43) (by decide)
    bodyDv43 bodyDe43 bodyDl43 bodyDold43 bodyDfree43 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyOracles_11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_g44 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g44 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g44) (List.take 3 (List.drop 427 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

noncomputable def PRE_first_tail_x15_r0_body.map_site44 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site44 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site44) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g45 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g45 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g45) (List.take 28 (List.drop 430 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site45 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site45 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site45) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st45.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g46 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g46 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g46) (List.take 9 (List.drop 458 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site46 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site46 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site46) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st46.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g47 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g47 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g47) (List.take 3 (List.drop 467 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

noncomputable def PRE_first_tail_x15_r0_body.map_site47 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site47 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site47) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x15_r0_body.map_site44 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site44 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site44) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site44
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s431 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s432 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S431 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws44 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso44
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_44
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot44
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup44
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound44
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace44
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged44
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws44.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st44.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S431.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_44]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen44.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh44
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl44 : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl44 (PRE_first_tail_x15_r0_body.cncl43 bodyNcl43)

theorem bodyClean44 : Conv.JClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s431 :=
  PRE_first_tail_x15_r0_body.gjcl44 (PRE_first_tail_x15_r0_body.cjcl43 bodyClean43)

kernel_rfl bodyJsLe44 : Nat.ble PRE_first_tail_x15_r0_body.s427.next PRE_first_tail_x15_r0_body.s431.next = true
kernel_rfl bodyJsList44 : (PRE_first_tail_x15_r0_body.gjh44 ++ PRE_first_tail_x15_r0_body.cl44).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s431.next) PRE_first_tail_x15_r0_body.s433) = true
theorem bodyJs44 : JsHeapAbove PRE_first_tail_x15_r0_body.s431.next PRE_first_tail_x15_r0_body.s433 :=
  JsHeapAbove.glueSite bodyJs43 (Nat.le_of_ble_eq_true bodyJsLe44) PRE_first_tail_x15_r0_body.gjk44 PRE_first_tail_x15_r0_body.gjbd44 PRE_first_tail_x15_r0_body.cheap44 PRE_first_tail_x15_r0_body.zclbd44 bodyJsList44

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO429 : PRE_first_tail_x15_r0_body.S429.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S429.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr429 : bridgeOf PRE_first_tail_x15_r0_body.s429.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc429 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.S429) = fun _ _ => true
kernel_rfl bodyAcc430 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s430 PRE_first_tail_x15_r0_body.S430) = fun _ _ => true
kernel_rfl bodyBr431 : bridgeOf PRE_first_tail_x15_r0_body.s431.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt430 : isHalt PRE_first_tail_x15_r0_body.s430.ctl = false
kernel_rfl bodyTop431 : noRetBlock PRE_first_tail_x15_r0_body.s431 = true
kernel_rfl bodyCnt429 : countersOkB PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.s431 = true

theorem bodyGlue44 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19149, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.S429)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19149, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.S431) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19149, 327, 0, 243⟩) bodyAcc429 PRE_first_tail_x15_r0_body.bodyRunSeg116 bodyAcc430 bodyHalt430 PRE_first_tail_x15_r0_body.bodyStepA117 bodyTop431 (fun _ hm => bodyO429 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr429).trans bodyInactive0) (bodyBr431.trans bodyBr429.symm) bodyCnt429 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift44 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S431.tab.length PRE_first_tail_x15_r0_body.s431.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P44.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.s433.ffi PRE_first_tail_x15_r0_body.s432.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_44
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_44
  have hcl : SSt (· < 1936) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S431.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_44] <;> decide) PRE_first_tail_x15_r0_body.cnodesK44 PRE_first_tail_x15_r0_body.cobjsK44
      PRE_first_tail_x15_r0_body.citemsK44 PRE_first_tail_x15_r0_body.cbd44 PRE_first_tail_x15_r0_body.csst44
  exact PRE_first_tail_x15_r0_body.cshift44 bodyNcl44 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_44] at this; exact this)


kernel_rfl bodyFramesEmpty44 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s432 a).isEmpty) = true
kernel_rfl bodyJsRoots44 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s431.next) PRE_first_tail_x15_r0_body.s433.trace PRE_first_tail_x15_r0_body.s433 = true
kernel_rfl bodyJsNative44 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s433.ffi) = true
kernel_rfl bodyLow44 : (PRE_first_tail_x15_r0_body.cws44 ++ PRE_first_tail_x15_r0_body.ws44).all (Nat.ble 9) = true
kernel_rfl bodyCntM44 : countersOkB PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.s432 = true
kernel_rfl bodyHi44 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).next setupP.E = true
kernel_rfl bodyNhi44 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge44 : bridgeOf PRE_first_tail_x15_r0_body.s432.ffi = bridgeOf PRE_first_tail_x15_r0_body.s431.ffi
kernel_rfl bodyNN44 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s431.ffi).nnext PRE_first_tail_x15_r0_body.P44.NL = true
kernel_rfl bodyXn44 : Nat.ble (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).next = true
kernel_rfl bodyLo44 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).next = true
theorem bodyFacts44 : BodySiteFacts PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.s432 PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S431 PRE_first_tail_x15_r0_body.S432 PRE_first_tail_x15_r0_body.S433
    PRE_first_tail_x15_r0_body.ws44 PRE_first_tail_x15_r0_body.cws44 PRE_first_tail_x15_r0_body.nr44 PRE_first_tail_x15_r0_body.pl44 PRE_first_tail_x15_r0_body.cl44 2709014 1936 PRE_first_tail_x15_r0_body.kd44 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.P44
    ⟨19061, 16159, 2709003, 1936⟩ ⟨19061, 16159, 2709004, 1936⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap44
  clean := bodyClean44
  cfix := PRE_first_tail_x15_r0_body.cfix44
  zpl := PRE_first_tail_x15_r0_body.zpl44
  zplnd := PRE_first_tail_x15_r0_body.zplnd44
  zn1 := PRE_first_tail_x15_r0_body.zn144
  zfirst := PRE_first_tail_x15_r0_body.zfirst44
  zscn := PRE_first_tail_x15_r0_body.zscn44
  zsmn := PRE_first_tail_x15_r0_body.zsmn44
  zgrow := PRE_first_tail_x15_r0_body.zgrow44
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab44
  zfresh := PRE_first_tail_x15_r0_body.zfresh44
  zcnd := PRE_first_tail_x15_r0_body.zcnd44
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi44
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt44
  zgP := PRE_first_tail_x15_r0_body.zg44_2665
  zkP := PRE_first_tail_x15_r0_body.zk44_2665
  zmP := PRE_first_tail_x15_r0_body.zm44_2665
  zgC := PRE_first_tail_x15_r0_body.zg44_2673467
  zkC := PRE_first_tail_x15_r0_body.zk44_2673467
  zmC := PRE_first_tail_x15_r0_body.zm44_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw44_2673472
  zwV := PRE_first_tail_x15_r0_body.zw44_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap44
  zclbd := PRE_first_tail_x15_r0_body.zclbd44
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap44 PRE_first_tail_x15_r0_body.stFoot44 PRE_first_tail_x15_r0_body.iso44 PRE_first_tail_x15_r0_body.zwr44
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP44
  csupp := PRE_first_tail_x15_r0_body.csupp44
  cbound := PRE_first_tail_x15_r0_body.cbound44
  zimg := PRE_first_tail_x15_r0_body.zimg44
  zctl := PRE_first_tail_x15_r0_body.zctl44
  zstack := PRE_first_tail_x15_r0_body.zstack44
  zjobs := PRE_first_tail_x15_r0_body.zjobs44
  zstores := PRE_first_tail_x15_r0_body.zstores44
  zroots := PRE_first_tail_x15_r0_body.zroots44
  znC := PRE_first_tail_x15_r0_body.znC44
  ctab := PRE_first_tail_x15_r0_body.ctab44
  zbin := PRE_first_tail_x15_r0_body.zbin44
  cbridge := PRE_first_tail_x15_r0_body.cbridge44
  sbridge := bodyBridge44
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj44
  cshiftR := fun h hNL => bodyCshift44 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN44
  raised := PRE_first_tail_x15_r0_body.raised44
  cbigs := PRE_first_tail_x15_r0_body.cbigs44
  cjcl := PRE_first_tail_x15_r0_body.cjcl44
  xnLe := Nat.le_of_ble_eq_true bodyXn44
  loLe := Nat.le_of_ble_eq_true bodyLo44
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB44
  cntM := bodyCntM44
  hiLe := Nat.le_of_ble_eq_true bodyHi44
  nhiLe := Nat.le_of_ble_eq_true bodyNhi44
  jsHeap := bodyJs44
  jsRoots := bodyJsRoots44
  jsNative := bodyJsNative44
  framesEmpty := bodyFramesEmpty44
  trailOld := by decide
  lowVars := bodyLow44

def bodyQs44 : List (Option Q) := []
noncomputable def bodyEs44 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr44.map fun r => nth? PRE_first_tail_x15_r0_body.st44.S2.tab r
kernel_rfl bodyResChk44 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs44 bodyQs44) = true
kernel_rfl bodyLq44 : bodyQs44.length = PRE_first_tail_x15_r0_body.cws44.length
kernel_rfl bodyNrLo44 : PRE_first_tail_x15_r0_body.nr44.all (Nat.ble PRE_first_tail_x15_r0_body.S431.tab.length) = true
kernel_rfl bodySub44 : (Oracles.PRE_first_tail_x15_r0_body.map_site44.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost44 : postSubB bodyM PRE_first_tail_x15_r0_body.ws44 PRE_first_tail_x15_r0_body.cws44 bodyQs44 = true
kernel_rfl bodyDrop44 : Nat.ble (19149 + (PRE_first_tail_x15_r0_body.s432.next - PRE_first_tail_x15_r0_body.s433.next)) 19159 = true
kernel_rfl bodyDropH44 : Nat.ble (327 + ((mlxOf PRE_first_tail_x15_r0_body.s432.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).next)) 327 = true
kernel_rfl bodyDropN44 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s432.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).nnext)) 0 = true
kernel_rfl bodyDv44 : bodyΘ.1.take 243 = bodyΘ.1.take 243 ++ PRE_first_tail_x15_r0_body.cws44
kernel_rfl bodyDe44 : bodyΘ.2.take 243 = bodyΘ.2.take 243 ++ PRE_first_tail_x15_r0_body.nr44.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st44.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 243) (bodyΘ.2.take 243)))
kernel_rfl bodyDl44 : (bodyΘ.1.take 243).length = (bodyΘ.2.take 243).length
kernel_rfl bodyDold44 : (bodyΘ.1.take 243).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws44).isNone && !PRE_first_tail_x15_r0_body.ws44.contains v) = true
kernel_rfl bodyDfree44 : (bodyΘ.2.take 243).all (fun e => (PRE_first_tail_x15_r0_body.cws44 ++ PRE_first_tail_x15_r0_body.ws44).all fun w => e.noVar w) = true

theorem bodyStep44 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19149, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.S431)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19159, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.S433) (98 + 1) :=
  bodySite bodyFacts44.cfix bodyFacts44.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st44.S2.tab) (Es := bodyEs44) (qs := bodyQs44)
    (ok := PRE_first_tail_x15_r0_body.st44.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site44 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts44
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site44 r hr) hi (MapOk.sub hm (sub_of_all bodySub44)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk44 r hr) hi hm ho hq)
    bodyLq44 rfl bodyNrLo44 (postSub_sound bodyPost44)
    (Nat.le_of_ble_eq_true bodyDrop44) (by decide) (Nat.le_of_ble_eq_true bodyDropH44) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN44) (by decide)
    bodyDv44 bodyDe44 bodyDl44 bodyDold44 bodyDfree44 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site45 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site45 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site45) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st45.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site45
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s447 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s448 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S447 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws45 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st45.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st45.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso45
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_45
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st45.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot45
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup45
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound45
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace45
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged45
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws45.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st45.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S447.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_45]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen45.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh45
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl45 : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl45 (PRE_first_tail_x15_r0_body.cncl44 bodyNcl44)

theorem bodyClean45 : Conv.JClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s447 :=
  PRE_first_tail_x15_r0_body.gjcl45 (PRE_first_tail_x15_r0_body.cjcl44 bodyClean44)

kernel_rfl bodyJsLe45 : Nat.ble PRE_first_tail_x15_r0_body.s431.next PRE_first_tail_x15_r0_body.s447.next = true
kernel_rfl bodyJsList45 : (PRE_first_tail_x15_r0_body.gjh45 ++ PRE_first_tail_x15_r0_body.cl45).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s447.next) PRE_first_tail_x15_r0_body.s449) = true
theorem bodyJs45 : JsHeapAbove PRE_first_tail_x15_r0_body.s447.next PRE_first_tail_x15_r0_body.s449 :=
  JsHeapAbove.glueSite bodyJs44 (Nat.le_of_ble_eq_true bodyJsLe45) PRE_first_tail_x15_r0_body.gjk45 PRE_first_tail_x15_r0_body.gjbd45 PRE_first_tail_x15_r0_body.cheap45 PRE_first_tail_x15_r0_body.zclbd45 bodyJsList45

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO433 : PRE_first_tail_x15_r0_body.S433.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S433.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr433 : bridgeOf PRE_first_tail_x15_r0_body.s433.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc433 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.S433) = fun _ _ => true
kernel_rfl bodyAcc435 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s435 PRE_first_tail_x15_r0_body.S435) = fun _ _ => true
kernel_rfl bodyBr436 : bridgeOf PRE_first_tail_x15_r0_body.s436.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt435 : isHalt PRE_first_tail_x15_r0_body.s435.ctl = false
kernel_rfl bodyTop436 : noRetBlock PRE_first_tail_x15_r0_body.s436 = true
kernel_rfl bodyCnt433 : countersOkB PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.s436 = true
kernel_rfl bodyO436 : PRE_first_tail_x15_r0_body.S436.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S436.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr437 : bridgeOf PRE_first_tail_x15_r0_body.s437.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt436 : countersOkB PRE_first_tail_x15_r0_body.s436 PRE_first_tail_x15_r0_body.s437 = true
kernel_rfl bodyO437 : PRE_first_tail_x15_r0_body.S437.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S437.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc437 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s437 PRE_first_tail_x15_r0_body.S437) = fun _ _ => true
kernel_rfl bodyAcc439 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s439 PRE_first_tail_x15_r0_body.S439) = fun _ _ => true
kernel_rfl bodyBr440 : bridgeOf PRE_first_tail_x15_r0_body.s440.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt439 : isHalt PRE_first_tail_x15_r0_body.s439.ctl = false
kernel_rfl bodyTop440 : noRetBlock PRE_first_tail_x15_r0_body.s440 = true
kernel_rfl bodyCnt437 : countersOkB PRE_first_tail_x15_r0_body.s437 PRE_first_tail_x15_r0_body.s440 = true
kernel_rfl bodyO440 : PRE_first_tail_x15_r0_body.S440.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S440.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr441 : bridgeOf PRE_first_tail_x15_r0_body.s441.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt440 : countersOkB PRE_first_tail_x15_r0_body.s440 PRE_first_tail_x15_r0_body.s441 = true
kernel_rfl bodyO441 : PRE_first_tail_x15_r0_body.S441.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S441.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc441 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s441 PRE_first_tail_x15_r0_body.S441) = fun _ _ => true
kernel_rfl bodyAcc442 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s442 PRE_first_tail_x15_r0_body.S442) = fun _ _ => true
kernel_rfl bodyBr443 : bridgeOf PRE_first_tail_x15_r0_body.s443.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt442 : isHalt PRE_first_tail_x15_r0_body.s442.ctl = false
kernel_rfl bodyTop443 : noRetBlock PRE_first_tail_x15_r0_body.s443 = true
kernel_rfl bodyCnt441 : countersOkB PRE_first_tail_x15_r0_body.s441 PRE_first_tail_x15_r0_body.s443 = true
kernel_rfl bodyO443 : PRE_first_tail_x15_r0_body.S443.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S443.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr444 : bridgeOf PRE_first_tail_x15_r0_body.s444.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt443 : countersOkB PRE_first_tail_x15_r0_body.s443 PRE_first_tail_x15_r0_body.s444 = true
kernel_rfl bodyO444 : PRE_first_tail_x15_r0_body.S444.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S444.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc444 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s444 PRE_first_tail_x15_r0_body.S444) = fun _ _ => true
kernel_rfl bodyAcc446 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s446 PRE_first_tail_x15_r0_body.S446) = fun _ _ => true
kernel_rfl bodyBr447 : bridgeOf PRE_first_tail_x15_r0_body.s447.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt446 : isHalt PRE_first_tail_x15_r0_body.s446.ctl = false
kernel_rfl bodyTop447 : noRetBlock PRE_first_tail_x15_r0_body.s447 = true
kernel_rfl bodyCnt444 : countersOkB PRE_first_tail_x15_r0_body.s444 PRE_first_tail_x15_r0_body.s447 = true

theorem bodyGlue45 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19159, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.S433)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19159, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.S447) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) bodyAcc433 PRE_first_tail_x15_r0_body.bodyRunSeg117 bodyAcc435 bodyHalt435 PRE_first_tail_x15_r0_body.bodyStepA118 bodyTop436 (fun _ hm => bodyO433 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr433).trans bodyInactive0) (bodyBr436.trans bodyBr433.symm) bodyCnt433 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) PRE_first_tail_x15_r0_body.sizeA118 PRE_first_tail_x15_r0_body.sizeArgsA118 PRE_first_tail_x15_r0_body.sizeSymA118 PRE_first_tail_x15_r0_body.sizeMlxA118 PRE_first_tail_x15_r0_body.sizePayA118 PRE_first_tail_x15_r0_body.sizeTaA118 PRE_first_tail_x15_r0_body.sizeDecA118 PRE_first_tail_x15_r0_body.sizePreA118 PRE_first_tail_x15_r0_body.bodyPatchB118 (fun _ hm => bodyO436 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr436).trans bodyInactive0) (bodyBr437.trans bodyBr436.symm) bodyCnt436 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) bodyAcc437 PRE_first_tail_x15_r0_body.bodyRunSeg118 bodyAcc439 bodyHalt439 PRE_first_tail_x15_r0_body.bodyStepA119 bodyTop440 (fun _ hm => bodyO437 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr437).trans bodyInactive0) (bodyBr440.trans bodyBr437.symm) bodyCnt437 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) PRE_first_tail_x15_r0_body.sizeA119 PRE_first_tail_x15_r0_body.sizeArgsA119 PRE_first_tail_x15_r0_body.sizeSymA119 PRE_first_tail_x15_r0_body.sizeMlxA119 PRE_first_tail_x15_r0_body.sizePayA119 PRE_first_tail_x15_r0_body.sizeTaA119 PRE_first_tail_x15_r0_body.sizeDecA119 PRE_first_tail_x15_r0_body.sizePreA119 PRE_first_tail_x15_r0_body.bodyPatchB119 (fun _ hm => bodyO440 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr440).trans bodyInactive0) (bodyBr441.trans bodyBr440.symm) bodyCnt440 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) bodyAcc441 PRE_first_tail_x15_r0_body.bodyRunSeg119 bodyAcc442 bodyHalt442 PRE_first_tail_x15_r0_body.bodyStepA120 bodyTop443 (fun _ hm => bodyO441 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr441).trans bodyInactive0) (bodyBr443.trans bodyBr441.symm) bodyCnt441 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) PRE_first_tail_x15_r0_body.sizeA120 PRE_first_tail_x15_r0_body.sizeArgsA120 PRE_first_tail_x15_r0_body.sizeSymA120 PRE_first_tail_x15_r0_body.sizeMlxA120 PRE_first_tail_x15_r0_body.sizePayA120 PRE_first_tail_x15_r0_body.sizeTaA120 PRE_first_tail_x15_r0_body.sizeDecA120 PRE_first_tail_x15_r0_body.sizePreA120 PRE_first_tail_x15_r0_body.bodyPatchB120 (fun _ hm => bodyO443 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr443).trans bodyInactive0) (bodyBr444.trans bodyBr443.symm) bodyCnt443 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) bodyAcc444 PRE_first_tail_x15_r0_body.bodyRunSeg120 bodyAcc446 bodyHalt446 PRE_first_tail_x15_r0_body.bodyStepA121 bodyTop447 (fun _ hm => bodyO444 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr444).trans bodyInactive0) (bodyBr447.trans bodyBr444.symm) bodyCnt444 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift45 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S447.tab.length PRE_first_tail_x15_r0_body.s447.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P45.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.s449.ffi PRE_first_tail_x15_r0_body.s448.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_45
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_45
  have hcl : SSt (· < 2022) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S447.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_45] <;> decide) PRE_first_tail_x15_r0_body.cnodesK45 PRE_first_tail_x15_r0_body.cobjsK45
      PRE_first_tail_x15_r0_body.citemsK45 PRE_first_tail_x15_r0_body.cbd45 PRE_first_tail_x15_r0_body.csst45
  exact PRE_first_tail_x15_r0_body.cshift45 bodyNcl45 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_45] at this; exact this)


kernel_rfl bodyFramesEmpty45 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s448 a).isEmpty) = true
kernel_rfl bodyJsRoots45 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s447.next) PRE_first_tail_x15_r0_body.s449.trace PRE_first_tail_x15_r0_body.s449 = true
kernel_rfl bodyJsNative45 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s449.ffi) = true
kernel_rfl bodyLow45 : (PRE_first_tail_x15_r0_body.cws45 ++ PRE_first_tail_x15_r0_body.ws45).all (Nat.ble 9) = true
kernel_rfl bodyCntM45 : countersOkB PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.s448 = true
kernel_rfl bodyHi45 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).next setupP.E = true
kernel_rfl bodyNhi45 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge45 : bridgeOf PRE_first_tail_x15_r0_body.s448.ffi = bridgeOf PRE_first_tail_x15_r0_body.s447.ffi
kernel_rfl bodyNN45 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s447.ffi).nnext PRE_first_tail_x15_r0_body.P45.NL = true
kernel_rfl bodyXn45 : Nat.ble (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).next = true
kernel_rfl bodyLo45 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).next = true
theorem bodyFacts45 : BodySiteFacts PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.s448 PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S447 PRE_first_tail_x15_r0_body.S448 PRE_first_tail_x15_r0_body.S449
    PRE_first_tail_x15_r0_body.ws45 PRE_first_tail_x15_r0_body.cws45 PRE_first_tail_x15_r0_body.nr45 PRE_first_tail_x15_r0_body.pl45 PRE_first_tail_x15_r0_body.cl45 2711105 2022 PRE_first_tail_x15_r0_body.kd45 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.P45
    ⟨19101, 16187, 2710740, 2013⟩ ⟨19105, 16193, 2710755, 2022⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap45
  clean := bodyClean45
  cfix := PRE_first_tail_x15_r0_body.cfix45
  zpl := PRE_first_tail_x15_r0_body.zpl45
  zplnd := PRE_first_tail_x15_r0_body.zplnd45
  zn1 := PRE_first_tail_x15_r0_body.zn145
  zfirst := PRE_first_tail_x15_r0_body.zfirst45
  zscn := PRE_first_tail_x15_r0_body.zscn45
  zsmn := PRE_first_tail_x15_r0_body.zsmn45
  zgrow := PRE_first_tail_x15_r0_body.zgrow45
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab45
  zfresh := PRE_first_tail_x15_r0_body.zfresh45
  zcnd := PRE_first_tail_x15_r0_body.zcnd45
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi45
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt45
  zgP := PRE_first_tail_x15_r0_body.zg45_2665
  zkP := PRE_first_tail_x15_r0_body.zk45_2665
  zmP := PRE_first_tail_x15_r0_body.zm45_2665
  zgC := PRE_first_tail_x15_r0_body.zg45_2673467
  zkC := PRE_first_tail_x15_r0_body.zk45_2673467
  zmC := PRE_first_tail_x15_r0_body.zm45_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw45_2673472
  zwV := PRE_first_tail_x15_r0_body.zw45_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap45
  zclbd := PRE_first_tail_x15_r0_body.zclbd45
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap45 PRE_first_tail_x15_r0_body.stFoot45 PRE_first_tail_x15_r0_body.iso45 PRE_first_tail_x15_r0_body.zwr45
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP45
  csupp := PRE_first_tail_x15_r0_body.csupp45
  cbound := PRE_first_tail_x15_r0_body.cbound45
  zimg := PRE_first_tail_x15_r0_body.zimg45
  zctl := PRE_first_tail_x15_r0_body.zctl45
  zstack := PRE_first_tail_x15_r0_body.zstack45
  zjobs := PRE_first_tail_x15_r0_body.zjobs45
  zstores := PRE_first_tail_x15_r0_body.zstores45
  zroots := PRE_first_tail_x15_r0_body.zroots45
  znC := PRE_first_tail_x15_r0_body.znC45
  ctab := PRE_first_tail_x15_r0_body.ctab45
  zbin := PRE_first_tail_x15_r0_body.zbin45
  cbridge := PRE_first_tail_x15_r0_body.cbridge45
  sbridge := bodyBridge45
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj45
  cshiftR := fun h hNL => bodyCshift45 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN45
  raised := PRE_first_tail_x15_r0_body.raised45
  cbigs := PRE_first_tail_x15_r0_body.cbigs45
  cjcl := PRE_first_tail_x15_r0_body.cjcl45
  xnLe := Nat.le_of_ble_eq_true bodyXn45
  loLe := Nat.le_of_ble_eq_true bodyLo45
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB45
  cntM := bodyCntM45
  hiLe := Nat.le_of_ble_eq_true bodyHi45
  nhiLe := Nat.le_of_ble_eq_true bodyNhi45
  jsHeap := bodyJs45
  jsRoots := bodyJsRoots45
  jsNative := bodyJsNative45
  framesEmpty := bodyFramesEmpty45
  trailOld := by decide
  lowVars := bodyLow45

def bodyQs45 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs45 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr45.map fun r => nth? PRE_first_tail_x15_r0_body.st45.S3.tab r
kernel_rfl bodyResChk45 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs45 bodyQs45) = true
kernel_rfl bodyLq45 : bodyQs45.length = PRE_first_tail_x15_r0_body.cws45.length
kernel_rfl bodyNrLo45 : PRE_first_tail_x15_r0_body.nr45.all (Nat.ble PRE_first_tail_x15_r0_body.S447.tab.length) = true
kernel_rfl bodySub45 : (Oracles.PRE_first_tail_x15_r0_body.map_site45.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost45 : postSubB bodyM PRE_first_tail_x15_r0_body.ws45 PRE_first_tail_x15_r0_body.cws45 bodyQs45 = true
kernel_rfl bodyDrop45 : Nat.ble (19159 + (PRE_first_tail_x15_r0_body.s448.next - PRE_first_tail_x15_r0_body.s449.next)) 19509 = true
kernel_rfl bodyDropH45 : Nat.ble (327 + ((mlxOf PRE_first_tail_x15_r0_body.s448.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).next)) 329 = true
kernel_rfl bodyDropN45 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s448.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).nnext)) 0 = true
kernel_rfl bodyDv45 : bodyΘ.1.take 252 = bodyΘ.1.take 243 ++ PRE_first_tail_x15_r0_body.cws45
kernel_rfl bodyDe45 : bodyΘ.2.take 252 = bodyΘ.2.take 243 ++ PRE_first_tail_x15_r0_body.nr45.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st45.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 243) (bodyΘ.2.take 243)))
kernel_rfl bodyDl45 : (bodyΘ.1.take 243).length = (bodyΘ.2.take 243).length
kernel_rfl bodyDold45 : (bodyΘ.1.take 243).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws45).isNone && !PRE_first_tail_x15_r0_body.ws45.contains v) = true
kernel_rfl bodyDfree45 : (bodyΘ.2.take 252).all (fun e => (PRE_first_tail_x15_r0_body.cws45 ++ PRE_first_tail_x15_r0_body.ws45).all fun w => e.noVar w) = true

theorem bodyStep45 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19159, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.S447)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19509, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.S449) (3452 + 1) :=
  bodySite bodyFacts45.cfix bodyFacts45.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st45.S3.tab) (Es := bodyEs45) (qs := bodyQs45)
    (ok := PRE_first_tail_x15_r0_body.st45.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site45 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts45
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site45 r hr) hi (MapOk.sub hm (sub_of_all bodySub45)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk45 r hr) hi hm ho hq)
    bodyLq45 rfl bodyNrLo45 (postSub_sound bodyPost45)
    (Nat.le_of_ble_eq_true bodyDrop45) (by decide) (Nat.le_of_ble_eq_true bodyDropH45) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN45) (by decide)
    bodyDv45 bodyDe45 bodyDl45 bodyDold45 bodyDfree45 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site46 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site46 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site46) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st46.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site46
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s455 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s456 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S455 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws46 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st46.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st46.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso46
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_46
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st46.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot46
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup46
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound46
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace46
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged46
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws46.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st46.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S455.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_46]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen46.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh46
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl46 : Conv.NClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl46 (PRE_first_tail_x15_r0_body.cncl45 bodyNcl45)

theorem bodyClean46 : Conv.JClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s455 :=
  PRE_first_tail_x15_r0_body.gjcl46 (PRE_first_tail_x15_r0_body.cjcl45 bodyClean45)

kernel_rfl bodyJsLe46 : Nat.ble PRE_first_tail_x15_r0_body.s447.next PRE_first_tail_x15_r0_body.s455.next = true
kernel_rfl bodyJsList46 : (PRE_first_tail_x15_r0_body.gjh46 ++ PRE_first_tail_x15_r0_body.cl46).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s455.next) PRE_first_tail_x15_r0_body.s457) = true
theorem bodyJs46 : JsHeapAbove PRE_first_tail_x15_r0_body.s455.next PRE_first_tail_x15_r0_body.s457 :=
  JsHeapAbove.glueSite bodyJs45 (Nat.le_of_ble_eq_true bodyJsLe46) PRE_first_tail_x15_r0_body.gjk46 PRE_first_tail_x15_r0_body.gjbd46 PRE_first_tail_x15_r0_body.cheap46 PRE_first_tail_x15_r0_body.zclbd46 bodyJsList46

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO449 : PRE_first_tail_x15_r0_body.S449.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S449.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr449 : bridgeOf PRE_first_tail_x15_r0_body.s449.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc449 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.S449) = fun _ _ => true
kernel_rfl bodyAcc450 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s450 PRE_first_tail_x15_r0_body.S450) = fun _ _ => true
kernel_rfl bodyBr451 : bridgeOf PRE_first_tail_x15_r0_body.s451.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt450 : isHalt PRE_first_tail_x15_r0_body.s450.ctl = false
kernel_rfl bodyTop451 : noRetBlock PRE_first_tail_x15_r0_body.s451 = true
kernel_rfl bodyCnt449 : countersOkB PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.s451 = true
kernel_rfl bodyO451 : PRE_first_tail_x15_r0_body.S451.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S451.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr452 : bridgeOf PRE_first_tail_x15_r0_body.s452.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt451 : countersOkB PRE_first_tail_x15_r0_body.s451 PRE_first_tail_x15_r0_body.s452 = true
kernel_rfl bodyO452 : PRE_first_tail_x15_r0_body.S452.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S452.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc452 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s452 PRE_first_tail_x15_r0_body.S452) = fun _ _ => true
kernel_rfl bodyAcc454 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s454 PRE_first_tail_x15_r0_body.S454) = fun _ _ => true
kernel_rfl bodyBr455 : bridgeOf PRE_first_tail_x15_r0_body.s455.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt454 : isHalt PRE_first_tail_x15_r0_body.s454.ctl = false
kernel_rfl bodyTop455 : noRetBlock PRE_first_tail_x15_r0_body.s455 = true
kernel_rfl bodyCnt452 : countersOkB PRE_first_tail_x15_r0_body.s452 PRE_first_tail_x15_r0_body.s455 = true

theorem bodyGlue46 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19509, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.S449)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19509, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.S455) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19509, 329, 0, 252⟩) bodyAcc449 PRE_first_tail_x15_r0_body.bodyRunSeg121 bodyAcc450 bodyHalt450 PRE_first_tail_x15_r0_body.bodyStepA122 bodyTop451 (fun _ hm => bodyO449 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr449).trans bodyInactive0) (bodyBr451.trans bodyBr449.symm) bodyCnt449 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19509, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA122 PRE_first_tail_x15_r0_body.sizeArgsA122 PRE_first_tail_x15_r0_body.sizeSymA122 PRE_first_tail_x15_r0_body.sizeMlxA122 PRE_first_tail_x15_r0_body.sizePayA122 PRE_first_tail_x15_r0_body.sizeTaA122 PRE_first_tail_x15_r0_body.sizeDecA122 PRE_first_tail_x15_r0_body.sizePreA122 PRE_first_tail_x15_r0_body.bodyPatchB122 (fun _ hm => bodyO451 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr451).trans bodyInactive0) (bodyBr452.trans bodyBr451.symm) bodyCnt451 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19509, 329, 0, 252⟩) bodyAcc452 PRE_first_tail_x15_r0_body.bodyRunSeg122 bodyAcc454 bodyHalt454 PRE_first_tail_x15_r0_body.bodyStepA123 bodyTop455 (fun _ hm => bodyO452 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr452).trans bodyInactive0) (bodyBr455.trans bodyBr452.symm) bodyCnt452 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift46 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S455.tab.length PRE_first_tail_x15_r0_body.s455.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P46.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P46 2045 PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.s457.ffi PRE_first_tail_x15_r0_body.s456.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_46
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_46
  have hcl : SSt (· < 2045) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S455.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_46] <;> decide) PRE_first_tail_x15_r0_body.cnodesK46 PRE_first_tail_x15_r0_body.cobjsK46
      PRE_first_tail_x15_r0_body.citemsK46 PRE_first_tail_x15_r0_body.cbd46 PRE_first_tail_x15_r0_body.csst46
  exact PRE_first_tail_x15_r0_body.cshift46 bodyNcl46 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_46] at this; exact this)


kernel_rfl bodyFramesEmpty46 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s456 a).isEmpty) = true
kernel_rfl bodyJsRoots46 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s455.next) PRE_first_tail_x15_r0_body.s457.trace PRE_first_tail_x15_r0_body.s457 = true
kernel_rfl bodyJsNative46 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s457.ffi) = true
kernel_rfl bodyLow46 : (PRE_first_tail_x15_r0_body.cws46 ++ PRE_first_tail_x15_r0_body.ws46).all (Nat.ble 9) = true
kernel_rfl bodyCntM46 : countersOkB PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.s456 = true
kernel_rfl bodyHi46 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).next setupP.E = true
kernel_rfl bodyNhi46 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge46 : bridgeOf PRE_first_tail_x15_r0_body.s456.ffi = bridgeOf PRE_first_tail_x15_r0_body.s455.ffi
kernel_rfl bodyNN46 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s455.ffi).nnext PRE_first_tail_x15_r0_body.P46.NL = true
kernel_rfl bodyXn46 : Nat.ble (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).next = true
kernel_rfl bodyLo46 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).next = true
theorem bodyFacts46 : BodySiteFacts PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.s456 PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S455 PRE_first_tail_x15_r0_body.S456 PRE_first_tail_x15_r0_body.S457
    PRE_first_tail_x15_r0_body.ws46 PRE_first_tail_x15_r0_body.cws46 PRE_first_tail_x15_r0_body.nr46 PRE_first_tail_x15_r0_body.pl46 PRE_first_tail_x15_r0_body.cl46 2711339 2045 PRE_first_tail_x15_r0_body.kd46 PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.P46
    ⟨19118, 16203, 2711337, 2045⟩ ⟨19118, 16203, 2711337, 2045⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap46
  clean := bodyClean46
  cfix := PRE_first_tail_x15_r0_body.cfix46
  zpl := PRE_first_tail_x15_r0_body.zpl46
  zplnd := PRE_first_tail_x15_r0_body.zplnd46
  zn1 := PRE_first_tail_x15_r0_body.zn146
  zfirst := PRE_first_tail_x15_r0_body.zfirst46
  zscn := PRE_first_tail_x15_r0_body.zscn46
  zsmn := PRE_first_tail_x15_r0_body.zsmn46
  zgrow := PRE_first_tail_x15_r0_body.zgrow46
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab46
  zfresh := PRE_first_tail_x15_r0_body.zfresh46
  zcnd := PRE_first_tail_x15_r0_body.zcnd46
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi46
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt46
  zgP := PRE_first_tail_x15_r0_body.zg46_2665
  zkP := PRE_first_tail_x15_r0_body.zk46_2665
  zmP := PRE_first_tail_x15_r0_body.zm46_2665
  zgC := PRE_first_tail_x15_r0_body.zg46_2673467
  zkC := PRE_first_tail_x15_r0_body.zk46_2673467
  zmC := PRE_first_tail_x15_r0_body.zm46_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw46_2673472
  zwV := PRE_first_tail_x15_r0_body.zw46_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap46
  zclbd := PRE_first_tail_x15_r0_body.zclbd46
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap46 PRE_first_tail_x15_r0_body.stFoot46 PRE_first_tail_x15_r0_body.iso46 PRE_first_tail_x15_r0_body.zwr46
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP46
  csupp := PRE_first_tail_x15_r0_body.csupp46
  cbound := PRE_first_tail_x15_r0_body.cbound46
  zimg := PRE_first_tail_x15_r0_body.zimg46
  zctl := PRE_first_tail_x15_r0_body.zctl46
  zstack := PRE_first_tail_x15_r0_body.zstack46
  zjobs := PRE_first_tail_x15_r0_body.zjobs46
  zstores := PRE_first_tail_x15_r0_body.zstores46
  zroots := PRE_first_tail_x15_r0_body.zroots46
  znC := PRE_first_tail_x15_r0_body.znC46
  ctab := PRE_first_tail_x15_r0_body.ctab46
  zbin := PRE_first_tail_x15_r0_body.zbin46
  cbridge := PRE_first_tail_x15_r0_body.cbridge46
  sbridge := bodyBridge46
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj46
  cshiftR := fun h hNL => bodyCshift46 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN46
  raised := PRE_first_tail_x15_r0_body.raised46
  cbigs := PRE_first_tail_x15_r0_body.cbigs46
  cjcl := PRE_first_tail_x15_r0_body.cjcl46
  xnLe := Nat.le_of_ble_eq_true bodyXn46
  loLe := Nat.le_of_ble_eq_true bodyLo46
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB46
  cntM := bodyCntM46
  hiLe := Nat.le_of_ble_eq_true bodyHi46
  nhiLe := Nat.le_of_ble_eq_true bodyNhi46
  jsHeap := bodyJs46
  jsRoots := bodyJsRoots46
  jsNative := bodyJsNative46
  framesEmpty := bodyFramesEmpty46
  trailOld := by decide
  lowVars := bodyLow46

def bodyQs46 : List (Option Q) := []
noncomputable def bodyEs46 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr46.map fun r => nth? PRE_first_tail_x15_r0_body.st46.S2.tab r
kernel_rfl bodyResChk46 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs46 bodyQs46) = true
kernel_rfl bodyLq46 : bodyQs46.length = PRE_first_tail_x15_r0_body.cws46.length
kernel_rfl bodyNrLo46 : PRE_first_tail_x15_r0_body.nr46.all (Nat.ble PRE_first_tail_x15_r0_body.S455.tab.length) = true
kernel_rfl bodySub46 : (Oracles.PRE_first_tail_x15_r0_body.map_site46.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost46 : postSubB bodyM PRE_first_tail_x15_r0_body.ws46 PRE_first_tail_x15_r0_body.cws46 bodyQs46 = true
kernel_rfl bodyDrop46 : Nat.ble (19509 + (PRE_first_tail_x15_r0_body.s456.next - PRE_first_tail_x15_r0_body.s457.next)) 19511 = true
kernel_rfl bodyDropH46 : Nat.ble (329 + ((mlxOf PRE_first_tail_x15_r0_body.s456.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).next)) 329 = true
kernel_rfl bodyDropN46 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s456.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).nnext)) 0 = true
kernel_rfl bodyDv46 : bodyΘ.1.take 252 = bodyΘ.1.take 252 ++ PRE_first_tail_x15_r0_body.cws46
kernel_rfl bodyDe46 : bodyΘ.2.take 252 = bodyΘ.2.take 252 ++ PRE_first_tail_x15_r0_body.nr46.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st46.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 252) (bodyΘ.2.take 252)))
kernel_rfl bodyDl46 : (bodyΘ.1.take 252).length = (bodyΘ.2.take 252).length
kernel_rfl bodyDold46 : (bodyΘ.1.take 252).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws46).isNone && !PRE_first_tail_x15_r0_body.ws46.contains v) = true
kernel_rfl bodyDfree46 : (bodyΘ.2.take 252).all (fun e => (PRE_first_tail_x15_r0_body.cws46 ++ PRE_first_tail_x15_r0_body.ws46).all fun w => e.noVar w) = true

theorem bodyStep46 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19509, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.S455)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19511, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.S457) (27 + 1) :=
  bodySite bodyFacts46.cfix bodyFacts46.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st46.S2.tab) (Es := bodyEs46) (qs := bodyQs46)
    (ok := PRE_first_tail_x15_r0_body.st46.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site46 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts46
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site46 r hr) hi (MapOk.sub hm (sub_of_all bodySub46)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk46 r hr) hi hm ho hq)
    bodyLq46 rfl bodyNrLo46 (postSub_sound bodyPost46)
    (Nat.le_of_ble_eq_true bodyDrop46) (by decide) (Nat.le_of_ble_eq_true bodyDropH46) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN46) (by decide)
    bodyDv46 bodyDe46 bodyDl46 bodyDold46 bodyDfree46 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x15_r0_body.map_site47 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site47 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site47) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site47
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s459 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s460 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S459 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws47 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso47
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_47
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot47
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup47
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound47
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace47
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged47
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws47.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st47.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S459.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_47]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen47.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh47
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl47 : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl47 (PRE_first_tail_x15_r0_body.cncl46 bodyNcl46)

theorem bodyClean47 : Conv.JClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s459 :=
  PRE_first_tail_x15_r0_body.gjcl47 (PRE_first_tail_x15_r0_body.cjcl46 bodyClean46)

kernel_rfl bodyJsLe47 : Nat.ble PRE_first_tail_x15_r0_body.s455.next PRE_first_tail_x15_r0_body.s459.next = true
kernel_rfl bodyJsList47 : (PRE_first_tail_x15_r0_body.gjh47 ++ PRE_first_tail_x15_r0_body.cl47).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s459.next) PRE_first_tail_x15_r0_body.s461) = true
theorem bodyJs47 : JsHeapAbove PRE_first_tail_x15_r0_body.s459.next PRE_first_tail_x15_r0_body.s461 :=
  JsHeapAbove.glueSite bodyJs46 (Nat.le_of_ble_eq_true bodyJsLe47) PRE_first_tail_x15_r0_body.gjk47 PRE_first_tail_x15_r0_body.gjbd47 PRE_first_tail_x15_r0_body.cheap47 PRE_first_tail_x15_r0_body.zclbd47 bodyJsList47

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO457 : PRE_first_tail_x15_r0_body.S457.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S457.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr457 : bridgeOf PRE_first_tail_x15_r0_body.s457.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc457 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.S457) = fun _ _ => true
kernel_rfl bodyAcc458 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s458 PRE_first_tail_x15_r0_body.S458) = fun _ _ => true
kernel_rfl bodyBr459 : bridgeOf PRE_first_tail_x15_r0_body.s459.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt458 : isHalt PRE_first_tail_x15_r0_body.s458.ctl = false
kernel_rfl bodyTop459 : noRetBlock PRE_first_tail_x15_r0_body.s459 = true
kernel_rfl bodyCnt457 : countersOkB PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.s459 = true

theorem bodyGlue47 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19511, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.S457)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19511, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.S459) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19511, 329, 0, 252⟩) bodyAcc457 PRE_first_tail_x15_r0_body.bodyRunSeg123 bodyAcc458 bodyHalt458 PRE_first_tail_x15_r0_body.bodyStepA124 bodyTop459 (fun _ hm => bodyO457 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr457).trans bodyInactive0) (bodyBr459.trans bodyBr457.symm) bodyCnt457 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift47 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S459.tab.length PRE_first_tail_x15_r0_body.s459.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P47.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.s461.ffi PRE_first_tail_x15_r0_body.s460.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_47
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_47
  have hcl : SSt (· < 2062) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S459.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_47] <;> decide) PRE_first_tail_x15_r0_body.cnodesK47 PRE_first_tail_x15_r0_body.cobjsK47
      PRE_first_tail_x15_r0_body.citemsK47 PRE_first_tail_x15_r0_body.cbd47 PRE_first_tail_x15_r0_body.csst47
  exact PRE_first_tail_x15_r0_body.cshift47 bodyNcl47 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_47] at this; exact this)


kernel_rfl bodyFramesEmpty47 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s460 a).isEmpty) = true
kernel_rfl bodyJsRoots47 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s459.next) PRE_first_tail_x15_r0_body.s461.trace PRE_first_tail_x15_r0_body.s461 = true
kernel_rfl bodyJsNative47 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s461.ffi) = true
kernel_rfl bodyLow47 : (PRE_first_tail_x15_r0_body.cws47 ++ PRE_first_tail_x15_r0_body.ws47).all (Nat.ble 9) = true
kernel_rfl bodyCntM47 : countersOkB PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.s460 = true
kernel_rfl bodyHi47 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).next setupP.E = true
kernel_rfl bodyNhi47 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge47 : bridgeOf PRE_first_tail_x15_r0_body.s460.ffi = bridgeOf PRE_first_tail_x15_r0_body.s459.ffi
kernel_rfl bodyNN47 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s459.ffi).nnext PRE_first_tail_x15_r0_body.P47.NL = true
kernel_rfl bodyXn47 : Nat.ble (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).next = true
kernel_rfl bodyLo47 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).next = true
theorem bodyFacts47 : BodySiteFacts PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.s460 PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S459 PRE_first_tail_x15_r0_body.S460 PRE_first_tail_x15_r0_body.S461
    PRE_first_tail_x15_r0_body.ws47 PRE_first_tail_x15_r0_body.cws47 PRE_first_tail_x15_r0_body.nr47 PRE_first_tail_x15_r0_body.pl47 PRE_first_tail_x15_r0_body.cl47 2711645 2062 PRE_first_tail_x15_r0_body.kd47 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.P47
    ⟨19125, 16207, 2711625, 2062⟩ ⟨19125, 16207, 2711626, 2062⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap47
  clean := bodyClean47
  cfix := PRE_first_tail_x15_r0_body.cfix47
  zpl := PRE_first_tail_x15_r0_body.zpl47
  zplnd := PRE_first_tail_x15_r0_body.zplnd47
  zn1 := PRE_first_tail_x15_r0_body.zn147
  zfirst := PRE_first_tail_x15_r0_body.zfirst47
  zscn := PRE_first_tail_x15_r0_body.zscn47
  zsmn := PRE_first_tail_x15_r0_body.zsmn47
  zgrow := PRE_first_tail_x15_r0_body.zgrow47
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab47
  zfresh := PRE_first_tail_x15_r0_body.zfresh47
  zcnd := PRE_first_tail_x15_r0_body.zcnd47
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi47
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt47
  zgP := PRE_first_tail_x15_r0_body.zg47_2665
  zkP := PRE_first_tail_x15_r0_body.zk47_2665
  zmP := PRE_first_tail_x15_r0_body.zm47_2665
  zgC := PRE_first_tail_x15_r0_body.zg47_2673467
  zkC := PRE_first_tail_x15_r0_body.zk47_2673467
  zmC := PRE_first_tail_x15_r0_body.zm47_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw47_2673472
  zwV := PRE_first_tail_x15_r0_body.zw47_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap47
  zclbd := PRE_first_tail_x15_r0_body.zclbd47
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap47 PRE_first_tail_x15_r0_body.stFoot47 PRE_first_tail_x15_r0_body.iso47 PRE_first_tail_x15_r0_body.zwr47
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP47
  csupp := PRE_first_tail_x15_r0_body.csupp47
  cbound := PRE_first_tail_x15_r0_body.cbound47
  zimg := PRE_first_tail_x15_r0_body.zimg47
  zctl := PRE_first_tail_x15_r0_body.zctl47
  zstack := PRE_first_tail_x15_r0_body.zstack47
  zjobs := PRE_first_tail_x15_r0_body.zjobs47
  zstores := PRE_first_tail_x15_r0_body.zstores47
  zroots := PRE_first_tail_x15_r0_body.zroots47
  znC := PRE_first_tail_x15_r0_body.znC47
  ctab := PRE_first_tail_x15_r0_body.ctab47
  zbin := PRE_first_tail_x15_r0_body.zbin47
  cbridge := PRE_first_tail_x15_r0_body.cbridge47
  sbridge := bodyBridge47
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj47
  cshiftR := fun h hNL => bodyCshift47 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN47
  raised := PRE_first_tail_x15_r0_body.raised47
  cbigs := PRE_first_tail_x15_r0_body.cbigs47
  cjcl := PRE_first_tail_x15_r0_body.cjcl47
  xnLe := Nat.le_of_ble_eq_true bodyXn47
  loLe := Nat.le_of_ble_eq_true bodyLo47
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB47
  cntM := bodyCntM47
  hiLe := Nat.le_of_ble_eq_true bodyHi47
  nhiLe := Nat.le_of_ble_eq_true bodyNhi47
  jsHeap := bodyJs47
  jsRoots := bodyJsRoots47
  jsNative := bodyJsNative47
  framesEmpty := bodyFramesEmpty47
  trailOld := by decide
  lowVars := bodyLow47

def bodyQs47 : List (Option Q) := []
noncomputable def bodyEs47 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr47.map fun r => nth? PRE_first_tail_x15_r0_body.st47.S2.tab r
kernel_rfl bodyResChk47 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs47 bodyQs47) = true
kernel_rfl bodyLq47 : bodyQs47.length = PRE_first_tail_x15_r0_body.cws47.length
kernel_rfl bodyNrLo47 : PRE_first_tail_x15_r0_body.nr47.all (Nat.ble PRE_first_tail_x15_r0_body.S459.tab.length) = true
kernel_rfl bodySub47 : (Oracles.PRE_first_tail_x15_r0_body.map_site47.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost47 : postSubB bodyM PRE_first_tail_x15_r0_body.ws47 PRE_first_tail_x15_r0_body.cws47 bodyQs47 = true
kernel_rfl bodyDrop47 : Nat.ble (19511 + (PRE_first_tail_x15_r0_body.s460.next - PRE_first_tail_x15_r0_body.s461.next)) 19530 = true
kernel_rfl bodyDropH47 : Nat.ble (329 + ((mlxOf PRE_first_tail_x15_r0_body.s460.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).next)) 329 = true
kernel_rfl bodyDropN47 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s460.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).nnext)) 0 = true
kernel_rfl bodyDv47 : bodyΘ.1.take 252 = bodyΘ.1.take 252 ++ PRE_first_tail_x15_r0_body.cws47
kernel_rfl bodyDe47 : bodyΘ.2.take 252 = bodyΘ.2.take 252 ++ PRE_first_tail_x15_r0_body.nr47.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st47.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 252) (bodyΘ.2.take 252)))
kernel_rfl bodyDl47 : (bodyΘ.1.take 252).length = (bodyΘ.2.take 252).length
kernel_rfl bodyDold47 : (bodyΘ.1.take 252).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws47).isNone && !PRE_first_tail_x15_r0_body.ws47.contains v) = true
kernel_rfl bodyDfree47 : (bodyΘ.2.take 252).all (fun e => (PRE_first_tail_x15_r0_body.cws47 ++ PRE_first_tail_x15_r0_body.ws47).all fun w => e.noVar w) = true

theorem bodyStep47 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19511, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.S459)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19530, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.S461) (206 + 1) :=
  bodySite bodyFacts47.cfix bodyFacts47.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st47.S2.tab) (Es := bodyEs47) (qs := bodyQs47)
    (ok := PRE_first_tail_x15_r0_body.st47.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site47 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts47
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site47 r hr) hi (MapOk.sub hm (sub_of_all bodySub47)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk47 r hr) hi hm ho hq)
    bodyLq47 rfl bodyNrLo47 (postSub_sound bodyPost47)
    (Nat.le_of_ble_eq_true bodyDrop47) (by decide) (Nat.le_of_ble_eq_true bodyDropH47) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN47) (by decide)
    bodyDv47 bodyDe47 bodyDl47 bodyDold47 bodyDfree47 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end
