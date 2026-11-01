import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
import host.sim.compose.a4b.vw15.B5
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw15.VWBodyChain
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B14
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21

section -- VWBodyOracles_12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_g48 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g48 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g48) (List.take 16 (List.drop 470 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site48 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site48 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site48) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st48.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g49 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g49 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g49) (List.take 7 (List.drop 486 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site49 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site49 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site49) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st49.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g50 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g50 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g50) (List.take 3 (List.drop 493 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

noncomputable def PRE_first_tail_x15_r0_body.map_site50 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site50 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site50) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g51 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g51 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g51) (List.take 16 (List.drop 496 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site51 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site51 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site51) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st51.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site48 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site48 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site48) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st48.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site48
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s476 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s477 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S476 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws48 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st48.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st48.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso48
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_48
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st48.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot48
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup48
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound48
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace48
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged48
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws48.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st48.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S476.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_48]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen48.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh48
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl48 : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl48 (PRE_first_tail_x15_r0_body.cncl47 bodyNcl47)

theorem bodyClean48 : Conv.JClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s476 :=
  PRE_first_tail_x15_r0_body.gjcl48 (PRE_first_tail_x15_r0_body.cjcl47 bodyClean47)

kernel_rfl bodyJsLe48 : Nat.ble PRE_first_tail_x15_r0_body.s459.next PRE_first_tail_x15_r0_body.s476.next = true
kernel_rfl bodyJsList48 : (PRE_first_tail_x15_r0_body.gjh48 ++ PRE_first_tail_x15_r0_body.cl48).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s476.next) PRE_first_tail_x15_r0_body.s478) = true
theorem bodyJs48 : JsHeapAbove PRE_first_tail_x15_r0_body.s476.next PRE_first_tail_x15_r0_body.s478 :=
  JsHeapAbove.glueSite bodyJs47 (Nat.le_of_ble_eq_true bodyJsLe48) PRE_first_tail_x15_r0_body.gjk48 PRE_first_tail_x15_r0_body.gjbd48 PRE_first_tail_x15_r0_body.cheap48 PRE_first_tail_x15_r0_body.zclbd48 bodyJsList48

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO461 : PRE_first_tail_x15_r0_body.S461.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S461.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr461 : bridgeOf PRE_first_tail_x15_r0_body.s461.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc461 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.S461) = fun _ _ => true
kernel_rfl bodyAcc463 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s463 PRE_first_tail_x15_r0_body.S463) = fun _ _ => true
kernel_rfl bodyBr464 : bridgeOf PRE_first_tail_x15_r0_body.s464.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt463 : isHalt PRE_first_tail_x15_r0_body.s463.ctl = false
kernel_rfl bodyTop464 : noRetBlock PRE_first_tail_x15_r0_body.s464 = true
kernel_rfl bodyCnt461 : countersOkB PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.s464 = true
kernel_rfl bodyO464 : PRE_first_tail_x15_r0_body.S464.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S464.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr465 : bridgeOf PRE_first_tail_x15_r0_body.s465.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt464 : countersOkB PRE_first_tail_x15_r0_body.s464 PRE_first_tail_x15_r0_body.s465 = true
kernel_rfl bodyO465 : PRE_first_tail_x15_r0_body.S465.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S465.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc465 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s465 PRE_first_tail_x15_r0_body.S465) = fun _ _ => true
kernel_rfl bodyAcc466 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s466 PRE_first_tail_x15_r0_body.S466) = fun _ _ => true
kernel_rfl bodyBr467 : bridgeOf PRE_first_tail_x15_r0_body.s467.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt466 : isHalt PRE_first_tail_x15_r0_body.s466.ctl = false
kernel_rfl bodyTop467 : noRetBlock PRE_first_tail_x15_r0_body.s467 = true
kernel_rfl bodyCnt465 : countersOkB PRE_first_tail_x15_r0_body.s465 PRE_first_tail_x15_r0_body.s467 = true
kernel_rfl bodyO467 : PRE_first_tail_x15_r0_body.S467.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S467.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr468 : bridgeOf PRE_first_tail_x15_r0_body.s468.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt467 : countersOkB PRE_first_tail_x15_r0_body.s467 PRE_first_tail_x15_r0_body.s468 = true
kernel_rfl bodyO468 : PRE_first_tail_x15_r0_body.S468.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S468.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc468 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s468 PRE_first_tail_x15_r0_body.S468) = fun _ _ => true
kernel_rfl bodyAcc469 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s469 PRE_first_tail_x15_r0_body.S469) = fun _ _ => true
kernel_rfl bodyBr470 : bridgeOf PRE_first_tail_x15_r0_body.s470.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt469 : isHalt PRE_first_tail_x15_r0_body.s469.ctl = false
kernel_rfl bodyTop470 : noRetBlock PRE_first_tail_x15_r0_body.s470 = true
kernel_rfl bodyCnt468 : countersOkB PRE_first_tail_x15_r0_body.s468 PRE_first_tail_x15_r0_body.s470 = true
kernel_rfl bodyO470 : PRE_first_tail_x15_r0_body.S470.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S470.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr471 : bridgeOf PRE_first_tail_x15_r0_body.s471.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt470 : countersOkB PRE_first_tail_x15_r0_body.s470 PRE_first_tail_x15_r0_body.s471 = true
kernel_rfl bodyO471 : PRE_first_tail_x15_r0_body.S471.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S471.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc471 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s471 PRE_first_tail_x15_r0_body.S471) = fun _ _ => true
kernel_rfl bodyAcc472 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s472 PRE_first_tail_x15_r0_body.S472) = fun _ _ => true
kernel_rfl bodyBr473 : bridgeOf PRE_first_tail_x15_r0_body.s473.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt472 : isHalt PRE_first_tail_x15_r0_body.s472.ctl = false
kernel_rfl bodyTop473 : noRetBlock PRE_first_tail_x15_r0_body.s473 = true
kernel_rfl bodyCnt471 : countersOkB PRE_first_tail_x15_r0_body.s471 PRE_first_tail_x15_r0_body.s473 = true
kernel_rfl bodyO473 : PRE_first_tail_x15_r0_body.S473.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S473.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr474 : bridgeOf PRE_first_tail_x15_r0_body.s474.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt473 : countersOkB PRE_first_tail_x15_r0_body.s473 PRE_first_tail_x15_r0_body.s474 = true
kernel_rfl bodyO474 : PRE_first_tail_x15_r0_body.S474.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S474.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc474 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.S474) = fun _ _ => true
kernel_rfl bodyAcc475 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s475 PRE_first_tail_x15_r0_body.S475) = fun _ _ => true
kernel_rfl bodyBr476 : bridgeOf PRE_first_tail_x15_r0_body.s476.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt475 : isHalt PRE_first_tail_x15_r0_body.s475.ctl = false
kernel_rfl bodyTop476 : noRetBlock PRE_first_tail_x15_r0_body.s476 = true
kernel_rfl bodyCnt474 : countersOkB PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.s476 = true

theorem bodyGlue48 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19530, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.S461)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19530, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.S476) 14768 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc461 PRE_first_tail_x15_r0_body.bodyRunSeg124 bodyAcc463 bodyHalt463 PRE_first_tail_x15_r0_body.bodyStepA125 bodyTop464 (fun _ hm => bodyO461 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr461).trans bodyInactive0) (bodyBr464.trans bodyBr461.symm) bodyCnt461 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA125 PRE_first_tail_x15_r0_body.sizeArgsA125 PRE_first_tail_x15_r0_body.sizeSymA125 PRE_first_tail_x15_r0_body.sizeMlxA125 PRE_first_tail_x15_r0_body.sizePayA125 PRE_first_tail_x15_r0_body.sizeTaA125 PRE_first_tail_x15_r0_body.sizeDecA125 PRE_first_tail_x15_r0_body.sizePreA125 PRE_first_tail_x15_r0_body.bodyPatchB125 (fun _ hm => bodyO464 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr464).trans bodyInactive0) (bodyBr465.trans bodyBr464.symm) bodyCnt464 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc465 PRE_first_tail_x15_r0_body.bodyRunSeg125 bodyAcc466 bodyHalt466 PRE_first_tail_x15_r0_body.bodyStepA126 bodyTop467 (fun _ hm => bodyO465 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr465).trans bodyInactive0) (bodyBr467.trans bodyBr465.symm) bodyCnt465 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA126 PRE_first_tail_x15_r0_body.sizeArgsA126 PRE_first_tail_x15_r0_body.sizeSymA126 PRE_first_tail_x15_r0_body.sizeMlxA126 PRE_first_tail_x15_r0_body.sizePayA126 PRE_first_tail_x15_r0_body.sizeTaA126 PRE_first_tail_x15_r0_body.sizeDecA126 PRE_first_tail_x15_r0_body.sizePreA126 PRE_first_tail_x15_r0_body.bodyPatchB126 (fun _ hm => bodyO467 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr467).trans bodyInactive0) (bodyBr468.trans bodyBr467.symm) bodyCnt467 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc468 PRE_first_tail_x15_r0_body.bodyRunSeg126 bodyAcc469 bodyHalt469 PRE_first_tail_x15_r0_body.bodyStepA127 bodyTop470 (fun _ hm => bodyO468 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr468).trans bodyInactive0) (bodyBr470.trans bodyBr468.symm) bodyCnt468 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA127 PRE_first_tail_x15_r0_body.sizeArgsA127 PRE_first_tail_x15_r0_body.sizeSymA127 PRE_first_tail_x15_r0_body.sizeMlxA127 PRE_first_tail_x15_r0_body.sizePayA127 PRE_first_tail_x15_r0_body.sizeTaA127 PRE_first_tail_x15_r0_body.sizeDecA127 PRE_first_tail_x15_r0_body.sizePreA127 PRE_first_tail_x15_r0_body.bodyPatchB127 (fun _ hm => bodyO470 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr470).trans bodyInactive0) (bodyBr471.trans bodyBr470.symm) bodyCnt470 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc471 PRE_first_tail_x15_r0_body.bodyRunSeg127 bodyAcc472 bodyHalt472 PRE_first_tail_x15_r0_body.bodyStepA128 bodyTop473 (fun _ hm => bodyO471 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr471).trans bodyInactive0) (bodyBr473.trans bodyBr471.symm) bodyCnt471 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA128 PRE_first_tail_x15_r0_body.sizeArgsA128 PRE_first_tail_x15_r0_body.sizeSymA128 PRE_first_tail_x15_r0_body.sizeMlxA128 PRE_first_tail_x15_r0_body.sizePayA128 PRE_first_tail_x15_r0_body.sizeTaA128 PRE_first_tail_x15_r0_body.sizeDecA128 PRE_first_tail_x15_r0_body.sizePreA128 PRE_first_tail_x15_r0_body.bodyPatchB128 (fun _ hm => bodyO473 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr473).trans bodyInactive0) (bodyBr474.trans bodyBr473.symm) bodyCnt473 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc474 PRE_first_tail_x15_r0_body.bodyRunSeg128 bodyAcc475 bodyHalt475 PRE_first_tail_x15_r0_body.bodyStepA129 bodyTop476 (fun _ hm => bodyO474 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr474).trans bodyInactive0) (bodyBr476.trans bodyBr474.symm) bodyCnt474 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift48 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S476.tab.length PRE_first_tail_x15_r0_body.s476.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P48.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.s478.ffi PRE_first_tail_x15_r0_body.s477.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_48
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_48
  have hcl : SSt (· < 2153) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S476.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_48] <;> decide) PRE_first_tail_x15_r0_body.cnodesK48 PRE_first_tail_x15_r0_body.cobjsK48
      PRE_first_tail_x15_r0_body.citemsK48 PRE_first_tail_x15_r0_body.cbd48 PRE_first_tail_x15_r0_body.csst48
  exact PRE_first_tail_x15_r0_body.cshift48 bodyNcl48 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_48] at this; exact this)


kernel_rfl bodyFramesEmpty48 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s477 a).isEmpty) = true
kernel_rfl bodyJsRoots48 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s476.next) PRE_first_tail_x15_r0_body.s478.trace PRE_first_tail_x15_r0_body.s478 = true
kernel_rfl bodyJsNative48 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s478.ffi) = true
kernel_rfl bodyLow48 : (PRE_first_tail_x15_r0_body.cws48 ++ PRE_first_tail_x15_r0_body.ws48).all (Nat.ble 9) = true
kernel_rfl bodyCntM48 : countersOkB PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.s477 = true
kernel_rfl bodyHi48 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).next setupP.E = true
kernel_rfl bodyNhi48 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge48 : bridgeOf PRE_first_tail_x15_r0_body.s477.ffi = bridgeOf PRE_first_tail_x15_r0_body.s476.ffi
kernel_rfl bodyNN48 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s476.ffi).nnext PRE_first_tail_x15_r0_body.P48.NL = true
kernel_rfl bodyXn48 : Nat.ble (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).next = true
kernel_rfl bodyLo48 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).next = true
theorem bodyFacts48 : BodySiteFacts PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.s477 PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S476 PRE_first_tail_x15_r0_body.S477 PRE_first_tail_x15_r0_body.S478
    PRE_first_tail_x15_r0_body.ws48 PRE_first_tail_x15_r0_body.cws48 PRE_first_tail_x15_r0_body.nr48 PRE_first_tail_x15_r0_body.pl48 PRE_first_tail_x15_r0_body.cl48 2714278 2153 PRE_first_tail_x15_r0_body.kd48 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.P48
    ⟨19160, 16226, 2713123, 2135⟩ ⟨19163, 16253, 2713129, 2153⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap48
  clean := bodyClean48
  cfix := PRE_first_tail_x15_r0_body.cfix48
  zpl := PRE_first_tail_x15_r0_body.zpl48
  zplnd := PRE_first_tail_x15_r0_body.zplnd48
  zn1 := PRE_first_tail_x15_r0_body.zn148
  zfirst := PRE_first_tail_x15_r0_body.zfirst48
  zscn := PRE_first_tail_x15_r0_body.zscn48
  zsmn := PRE_first_tail_x15_r0_body.zsmn48
  zgrow := PRE_first_tail_x15_r0_body.zgrow48
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab48
  zfresh := PRE_first_tail_x15_r0_body.zfresh48
  zcnd := PRE_first_tail_x15_r0_body.zcnd48
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi48
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt48
  zgP := PRE_first_tail_x15_r0_body.zg48_2665
  zkP := PRE_first_tail_x15_r0_body.zk48_2665
  zmP := PRE_first_tail_x15_r0_body.zm48_2665
  zgC := PRE_first_tail_x15_r0_body.zg48_2673467
  zkC := PRE_first_tail_x15_r0_body.zk48_2673467
  zmC := PRE_first_tail_x15_r0_body.zm48_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw48_2673472
  zwV := PRE_first_tail_x15_r0_body.zw48_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap48
  zclbd := PRE_first_tail_x15_r0_body.zclbd48
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap48 PRE_first_tail_x15_r0_body.stFoot48 PRE_first_tail_x15_r0_body.iso48 PRE_first_tail_x15_r0_body.zwr48
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP48
  csupp := PRE_first_tail_x15_r0_body.csupp48
  cbound := PRE_first_tail_x15_r0_body.cbound48
  zimg := PRE_first_tail_x15_r0_body.zimg48
  zctl := PRE_first_tail_x15_r0_body.zctl48
  zstack := PRE_first_tail_x15_r0_body.zstack48
  zjobs := PRE_first_tail_x15_r0_body.zjobs48
  zstores := PRE_first_tail_x15_r0_body.zstores48
  zroots := PRE_first_tail_x15_r0_body.zroots48
  znC := PRE_first_tail_x15_r0_body.znC48
  ctab := PRE_first_tail_x15_r0_body.ctab48
  zbin := PRE_first_tail_x15_r0_body.zbin48
  cbridge := PRE_first_tail_x15_r0_body.cbridge48
  sbridge := bodyBridge48
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj48
  cshiftR := fun h hNL => bodyCshift48 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN48
  raised := PRE_first_tail_x15_r0_body.raised48
  cbigs := PRE_first_tail_x15_r0_body.cbigs48
  cjcl := PRE_first_tail_x15_r0_body.cjcl48
  xnLe := Nat.le_of_ble_eq_true bodyXn48
  loLe := Nat.le_of_ble_eq_true bodyLo48
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB48
  cntM := bodyCntM48
  hiLe := Nat.le_of_ble_eq_true bodyHi48
  nhiLe := Nat.le_of_ble_eq_true bodyNhi48
  jsHeap := bodyJs48
  jsRoots := bodyJsRoots48
  jsNative := bodyJsNative48
  framesEmpty := bodyFramesEmpty48
  trailOld := by decide
  lowVars := bodyLow48

def bodyQs48 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs48 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr48.map fun r => nth? PRE_first_tail_x15_r0_body.st48.S5.tab r
kernel_rfl bodyResChk48 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs48 bodyQs48) = true
kernel_rfl bodyLq48 : bodyQs48.length = PRE_first_tail_x15_r0_body.cws48.length
kernel_rfl bodyNrLo48 : PRE_first_tail_x15_r0_body.nr48.all (Nat.ble PRE_first_tail_x15_r0_body.S476.tab.length) = true
kernel_rfl bodySub48 : (Oracles.PRE_first_tail_x15_r0_body.map_site48.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost48 : postSubB bodyM PRE_first_tail_x15_r0_body.ws48 PRE_first_tail_x15_r0_body.cws48 bodyQs48 = true
kernel_rfl bodyDrop48 : Nat.ble (19530 + (PRE_first_tail_x15_r0_body.s477.next - PRE_first_tail_x15_r0_body.s478.next)) 20679 = true
kernel_rfl bodyDropH48 : Nat.ble (329 + ((mlxOf PRE_first_tail_x15_r0_body.s477.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).next)) 354 = true
kernel_rfl bodyDropN48 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s477.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).nnext)) 0 = true
kernel_rfl bodyDv48 : bodyΘ.1.take 270 = bodyΘ.1.take 252 ++ PRE_first_tail_x15_r0_body.cws48
kernel_rfl bodyDe48 : bodyΘ.2.take 270 = bodyΘ.2.take 252 ++ PRE_first_tail_x15_r0_body.nr48.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st48.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 252) (bodyΘ.2.take 252)))
kernel_rfl bodyDl48 : (bodyΘ.1.take 252).length = (bodyΘ.2.take 252).length
kernel_rfl bodyDold48 : (bodyΘ.1.take 252).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws48).isNone && !PRE_first_tail_x15_r0_body.ws48.contains v) = true
kernel_rfl bodyDfree48 : (bodyΘ.2.take 270).all (fun e => (PRE_first_tail_x15_r0_body.cws48 ++ PRE_first_tail_x15_r0_body.ws48).all fun w => e.noVar w) = true

theorem bodyStep48 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19530, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.S476)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20679, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.S478) (11334 + 1) :=
  bodySite bodyFacts48.cfix bodyFacts48.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st48.S5.tab) (Es := bodyEs48) (qs := bodyQs48)
    (ok := PRE_first_tail_x15_r0_body.st48.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site48 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts48
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site48 r hr) hi (MapOk.sub hm (sub_of_all bodySub48)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk48 r hr) hi hm ho hq)
    bodyLq48 rfl bodyNrLo48 (postSub_sound bodyPost48)
    (Nat.le_of_ble_eq_true bodyDrop48) (by decide) (Nat.le_of_ble_eq_true bodyDropH48) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN48) (by decide)
    bodyDv48 bodyDe48 bodyDl48 bodyDold48 bodyDfree48 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site49 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site49 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site49) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st49.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site49
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s484 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s485 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S484 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws49 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st49.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st49.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso49
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_49
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st49.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot49
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup49
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound49
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace49
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged49
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws49.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st49.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S484.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_49]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen49.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh49
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl49 : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl49 (PRE_first_tail_x15_r0_body.cncl48 bodyNcl48)

theorem bodyClean49 : Conv.JClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s484 :=
  PRE_first_tail_x15_r0_body.gjcl49 (PRE_first_tail_x15_r0_body.cjcl48 bodyClean48)

kernel_rfl bodyJsLe49 : Nat.ble PRE_first_tail_x15_r0_body.s476.next PRE_first_tail_x15_r0_body.s484.next = true
kernel_rfl bodyJsList49 : (PRE_first_tail_x15_r0_body.gjh49 ++ PRE_first_tail_x15_r0_body.cl49).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s484.next) PRE_first_tail_x15_r0_body.s486) = true
theorem bodyJs49 : JsHeapAbove PRE_first_tail_x15_r0_body.s484.next PRE_first_tail_x15_r0_body.s486 :=
  JsHeapAbove.glueSite bodyJs48 (Nat.le_of_ble_eq_true bodyJsLe49) PRE_first_tail_x15_r0_body.gjk49 PRE_first_tail_x15_r0_body.gjbd49 PRE_first_tail_x15_r0_body.cheap49 PRE_first_tail_x15_r0_body.zclbd49 bodyJsList49

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO478 : PRE_first_tail_x15_r0_body.S478.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S478.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr478 : bridgeOf PRE_first_tail_x15_r0_body.s478.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc478 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.S478) = fun _ _ => true
kernel_rfl bodyAcc479 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s479 PRE_first_tail_x15_r0_body.S479) = fun _ _ => true
kernel_rfl bodyBr480 : bridgeOf PRE_first_tail_x15_r0_body.s480.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt479 : isHalt PRE_first_tail_x15_r0_body.s479.ctl = false
kernel_rfl bodyTop480 : noRetBlock PRE_first_tail_x15_r0_body.s480 = true
kernel_rfl bodyCnt478 : countersOkB PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.s480 = true
kernel_rfl bodyO480 : PRE_first_tail_x15_r0_body.S480.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S480.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr481 : bridgeOf PRE_first_tail_x15_r0_body.s481.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt480 : countersOkB PRE_first_tail_x15_r0_body.s480 PRE_first_tail_x15_r0_body.s481 = true
kernel_rfl bodyO481 : PRE_first_tail_x15_r0_body.S481.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S481.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc481 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s481 PRE_first_tail_x15_r0_body.S481) = fun _ _ => true
kernel_rfl bodyAcc483 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s483 PRE_first_tail_x15_r0_body.S483) = fun _ _ => true
kernel_rfl bodyBr484 : bridgeOf PRE_first_tail_x15_r0_body.s484.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt483 : isHalt PRE_first_tail_x15_r0_body.s483.ctl = false
kernel_rfl bodyTop484 : noRetBlock PRE_first_tail_x15_r0_body.s484 = true
kernel_rfl bodyCnt481 : countersOkB PRE_first_tail_x15_r0_body.s481 PRE_first_tail_x15_r0_body.s484 = true

theorem bodyGlue49 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20679, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.S478)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20679, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.S484) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20679, 354, 0, 270⟩) bodyAcc478 PRE_first_tail_x15_r0_body.bodyRunSeg129 bodyAcc479 bodyHalt479 PRE_first_tail_x15_r0_body.bodyStepA130 bodyTop480 (fun _ hm => bodyO478 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr478).trans bodyInactive0) (bodyBr480.trans bodyBr478.symm) bodyCnt478 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20679, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA130 PRE_first_tail_x15_r0_body.sizeArgsA130 PRE_first_tail_x15_r0_body.sizeSymA130 PRE_first_tail_x15_r0_body.sizeMlxA130 PRE_first_tail_x15_r0_body.sizePayA130 PRE_first_tail_x15_r0_body.sizeTaA130 PRE_first_tail_x15_r0_body.sizeDecA130 PRE_first_tail_x15_r0_body.sizePreA130 PRE_first_tail_x15_r0_body.bodyPatchB130 (fun _ hm => bodyO480 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr480).trans bodyInactive0) (bodyBr481.trans bodyBr480.symm) bodyCnt480 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20679, 354, 0, 270⟩) bodyAcc481 PRE_first_tail_x15_r0_body.bodyRunSeg130 bodyAcc483 bodyHalt483 PRE_first_tail_x15_r0_body.bodyStepA131 bodyTop484 (fun _ hm => bodyO481 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr481).trans bodyInactive0) (bodyBr484.trans bodyBr481.symm) bodyCnt481 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift49 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S484.tab.length PRE_first_tail_x15_r0_body.s484.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P49.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.s486.ffi PRE_first_tail_x15_r0_body.s485.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_49
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_49
  have hcl : SSt (· < 2174) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S484.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_49] <;> decide) PRE_first_tail_x15_r0_body.cnodesK49 PRE_first_tail_x15_r0_body.cobjsK49
      PRE_first_tail_x15_r0_body.citemsK49 PRE_first_tail_x15_r0_body.cbd49 PRE_first_tail_x15_r0_body.csst49
  exact PRE_first_tail_x15_r0_body.cshift49 bodyNcl49 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_49] at this; exact this)


kernel_rfl bodyFramesEmpty49 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s485 a).isEmpty) = true
kernel_rfl bodyJsRoots49 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s484.next) PRE_first_tail_x15_r0_body.s486.trace PRE_first_tail_x15_r0_body.s486 = true
kernel_rfl bodyJsNative49 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s486.ffi) = true
kernel_rfl bodyLow49 : (PRE_first_tail_x15_r0_body.cws49 ++ PRE_first_tail_x15_r0_body.ws49).all (Nat.ble 9) = true
kernel_rfl bodyCntM49 : countersOkB PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.s485 = true
kernel_rfl bodyHi49 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).next setupP.E = true
kernel_rfl bodyNhi49 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge49 : bridgeOf PRE_first_tail_x15_r0_body.s485.ffi = bridgeOf PRE_first_tail_x15_r0_body.s484.ffi
kernel_rfl bodyNN49 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s484.ffi).nnext PRE_first_tail_x15_r0_body.P49.NL = true
kernel_rfl bodyXn49 : Nat.ble (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).next = true
kernel_rfl bodyLo49 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).next = true
theorem bodyFacts49 : BodySiteFacts PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.s485 PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S484 PRE_first_tail_x15_r0_body.S485 PRE_first_tail_x15_r0_body.S486
    PRE_first_tail_x15_r0_body.ws49 PRE_first_tail_x15_r0_body.cws49 PRE_first_tail_x15_r0_body.nr49 PRE_first_tail_x15_r0_body.pl49 PRE_first_tail_x15_r0_body.cl49 2713621 2174 PRE_first_tail_x15_r0_body.kd49 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.P49
    ⟨19176, 16266, 2713619, 2174⟩ ⟨19176, 16266, 2713619, 2174⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap49
  clean := bodyClean49
  cfix := PRE_first_tail_x15_r0_body.cfix49
  zpl := PRE_first_tail_x15_r0_body.zpl49
  zplnd := PRE_first_tail_x15_r0_body.zplnd49
  zn1 := PRE_first_tail_x15_r0_body.zn149
  zfirst := PRE_first_tail_x15_r0_body.zfirst49
  zscn := PRE_first_tail_x15_r0_body.zscn49
  zsmn := PRE_first_tail_x15_r0_body.zsmn49
  zgrow := PRE_first_tail_x15_r0_body.zgrow49
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab49
  zfresh := PRE_first_tail_x15_r0_body.zfresh49
  zcnd := PRE_first_tail_x15_r0_body.zcnd49
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi49
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt49
  zgP := PRE_first_tail_x15_r0_body.zg49_2665
  zkP := PRE_first_tail_x15_r0_body.zk49_2665
  zmP := PRE_first_tail_x15_r0_body.zm49_2665
  zgC := PRE_first_tail_x15_r0_body.zg49_2673467
  zkC := PRE_first_tail_x15_r0_body.zk49_2673467
  zmC := PRE_first_tail_x15_r0_body.zm49_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw49_2673472
  zwV := PRE_first_tail_x15_r0_body.zw49_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap49
  zclbd := PRE_first_tail_x15_r0_body.zclbd49
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap49 PRE_first_tail_x15_r0_body.stFoot49 PRE_first_tail_x15_r0_body.iso49 PRE_first_tail_x15_r0_body.zwr49
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP49
  csupp := PRE_first_tail_x15_r0_body.csupp49
  cbound := PRE_first_tail_x15_r0_body.cbound49
  zimg := PRE_first_tail_x15_r0_body.zimg49
  zctl := PRE_first_tail_x15_r0_body.zctl49
  zstack := PRE_first_tail_x15_r0_body.zstack49
  zjobs := PRE_first_tail_x15_r0_body.zjobs49
  zstores := PRE_first_tail_x15_r0_body.zstores49
  zroots := PRE_first_tail_x15_r0_body.zroots49
  znC := PRE_first_tail_x15_r0_body.znC49
  ctab := PRE_first_tail_x15_r0_body.ctab49
  zbin := PRE_first_tail_x15_r0_body.zbin49
  cbridge := PRE_first_tail_x15_r0_body.cbridge49
  sbridge := bodyBridge49
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj49
  cshiftR := fun h hNL => bodyCshift49 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN49
  raised := PRE_first_tail_x15_r0_body.raised49
  cbigs := PRE_first_tail_x15_r0_body.cbigs49
  cjcl := PRE_first_tail_x15_r0_body.cjcl49
  xnLe := Nat.le_of_ble_eq_true bodyXn49
  loLe := Nat.le_of_ble_eq_true bodyLo49
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB49
  cntM := bodyCntM49
  hiLe := Nat.le_of_ble_eq_true bodyHi49
  nhiLe := Nat.le_of_ble_eq_true bodyNhi49
  jsHeap := bodyJs49
  jsRoots := bodyJsRoots49
  jsNative := bodyJsNative49
  framesEmpty := bodyFramesEmpty49
  trailOld := by decide
  lowVars := bodyLow49

def bodyQs49 : List (Option Q) := []
noncomputable def bodyEs49 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr49.map fun r => nth? PRE_first_tail_x15_r0_body.st49.S2.tab r
kernel_rfl bodyResChk49 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs49 bodyQs49) = true
kernel_rfl bodyLq49 : bodyQs49.length = PRE_first_tail_x15_r0_body.cws49.length
kernel_rfl bodyNrLo49 : PRE_first_tail_x15_r0_body.nr49.all (Nat.ble PRE_first_tail_x15_r0_body.S484.tab.length) = true
kernel_rfl bodySub49 : (Oracles.PRE_first_tail_x15_r0_body.map_site49.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost49 : postSubB bodyM PRE_first_tail_x15_r0_body.ws49 PRE_first_tail_x15_r0_body.cws49 bodyQs49 = true
kernel_rfl bodyDrop49 : Nat.ble (20679 + (PRE_first_tail_x15_r0_body.s485.next - PRE_first_tail_x15_r0_body.s486.next)) 20681 = true
kernel_rfl bodyDropH49 : Nat.ble (354 + ((mlxOf PRE_first_tail_x15_r0_body.s485.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).next)) 354 = true
kernel_rfl bodyDropN49 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s485.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).nnext)) 0 = true
kernel_rfl bodyDv49 : bodyΘ.1.take 270 = bodyΘ.1.take 270 ++ PRE_first_tail_x15_r0_body.cws49
kernel_rfl bodyDe49 : bodyΘ.2.take 270 = bodyΘ.2.take 270 ++ PRE_first_tail_x15_r0_body.nr49.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st49.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 270) (bodyΘ.2.take 270)))
kernel_rfl bodyDl49 : (bodyΘ.1.take 270).length = (bodyΘ.2.take 270).length
kernel_rfl bodyDold49 : (bodyΘ.1.take 270).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws49).isNone && !PRE_first_tail_x15_r0_body.ws49.contains v) = true
kernel_rfl bodyDfree49 : (bodyΘ.2.take 270).all (fun e => (PRE_first_tail_x15_r0_body.cws49 ++ PRE_first_tail_x15_r0_body.ws49).all fun w => e.noVar w) = true

theorem bodyStep49 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20679, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.S484)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20681, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.S486) (27 + 1) :=
  bodySite bodyFacts49.cfix bodyFacts49.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st49.S2.tab) (Es := bodyEs49) (qs := bodyQs49)
    (ok := PRE_first_tail_x15_r0_body.st49.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site49 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts49
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site49 r hr) hi (MapOk.sub hm (sub_of_all bodySub49)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk49 r hr) hi hm ho hq)
    bodyLq49 rfl bodyNrLo49 (postSub_sound bodyPost49)
    (Nat.le_of_ble_eq_true bodyDrop49) (by decide) (Nat.le_of_ble_eq_true bodyDropH49) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN49) (by decide)
    bodyDv49 bodyDe49 bodyDl49 bodyDold49 bodyDfree49 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x15_r0_body.map_site50 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site50 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site50) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site50
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s488 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s489 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S488 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws50 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso50
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_50
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot50
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup50
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound50
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace50
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged50
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws50.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st50.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S488.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_50]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen50.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh50
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl50 : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl50 (PRE_first_tail_x15_r0_body.cncl49 bodyNcl49)

theorem bodyClean50 : Conv.JClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s488 :=
  PRE_first_tail_x15_r0_body.gjcl50 (PRE_first_tail_x15_r0_body.cjcl49 bodyClean49)

kernel_rfl bodyJsLe50 : Nat.ble PRE_first_tail_x15_r0_body.s484.next PRE_first_tail_x15_r0_body.s488.next = true
kernel_rfl bodyJsList50 : (PRE_first_tail_x15_r0_body.gjh50 ++ PRE_first_tail_x15_r0_body.cl50).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s488.next) PRE_first_tail_x15_r0_body.s490) = true
theorem bodyJs50 : JsHeapAbove PRE_first_tail_x15_r0_body.s488.next PRE_first_tail_x15_r0_body.s490 :=
  JsHeapAbove.glueSite bodyJs49 (Nat.le_of_ble_eq_true bodyJsLe50) PRE_first_tail_x15_r0_body.gjk50 PRE_first_tail_x15_r0_body.gjbd50 PRE_first_tail_x15_r0_body.cheap50 PRE_first_tail_x15_r0_body.zclbd50 bodyJsList50

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO486 : PRE_first_tail_x15_r0_body.S486.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S486.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr486 : bridgeOf PRE_first_tail_x15_r0_body.s486.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc486 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.S486) = fun _ _ => true
kernel_rfl bodyAcc487 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s487 PRE_first_tail_x15_r0_body.S487) = fun _ _ => true
kernel_rfl bodyBr488 : bridgeOf PRE_first_tail_x15_r0_body.s488.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt487 : isHalt PRE_first_tail_x15_r0_body.s487.ctl = false
kernel_rfl bodyTop488 : noRetBlock PRE_first_tail_x15_r0_body.s488 = true
kernel_rfl bodyCnt486 : countersOkB PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.s488 = true

theorem bodyGlue50 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20681, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.S486)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20681, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.S488) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20681, 354, 0, 270⟩) bodyAcc486 PRE_first_tail_x15_r0_body.bodyRunSeg131 bodyAcc487 bodyHalt487 PRE_first_tail_x15_r0_body.bodyStepA132 bodyTop488 (fun _ hm => bodyO486 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr486).trans bodyInactive0) (bodyBr488.trans bodyBr486.symm) bodyCnt486 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift50 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S488.tab.length PRE_first_tail_x15_r0_body.s488.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P50.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.s490.ffi PRE_first_tail_x15_r0_body.s489.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_50
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_50
  have hcl : SSt (· < 2191) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S488.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_50] <;> decide) PRE_first_tail_x15_r0_body.cnodesK50 PRE_first_tail_x15_r0_body.cobjsK50
      PRE_first_tail_x15_r0_body.citemsK50 PRE_first_tail_x15_r0_body.cbd50 PRE_first_tail_x15_r0_body.csst50
  exact PRE_first_tail_x15_r0_body.cshift50 bodyNcl50 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_50] at this; exact this)


kernel_rfl bodyFramesEmpty50 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s489 a).isEmpty) = true
kernel_rfl bodyJsRoots50 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s488.next) PRE_first_tail_x15_r0_body.s490.trace PRE_first_tail_x15_r0_body.s490 = true
kernel_rfl bodyJsNative50 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s490.ffi) = true
kernel_rfl bodyLow50 : (PRE_first_tail_x15_r0_body.cws50 ++ PRE_first_tail_x15_r0_body.ws50).all (Nat.ble 9) = true
kernel_rfl bodyCntM50 : countersOkB PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.s489 = true
kernel_rfl bodyHi50 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).next setupP.E = true
kernel_rfl bodyNhi50 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge50 : bridgeOf PRE_first_tail_x15_r0_body.s489.ffi = bridgeOf PRE_first_tail_x15_r0_body.s488.ffi
kernel_rfl bodyNN50 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s488.ffi).nnext PRE_first_tail_x15_r0_body.P50.NL = true
kernel_rfl bodyXn50 : Nat.ble (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).next = true
kernel_rfl bodyLo50 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).next = true
theorem bodyFacts50 : BodySiteFacts PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.s489 PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S488 PRE_first_tail_x15_r0_body.S489 PRE_first_tail_x15_r0_body.S490
    PRE_first_tail_x15_r0_body.ws50 PRE_first_tail_x15_r0_body.cws50 PRE_first_tail_x15_r0_body.nr50 PRE_first_tail_x15_r0_body.pl50 PRE_first_tail_x15_r0_body.cl50 2713927 2191 PRE_first_tail_x15_r0_body.kd50 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.P50
    ⟨19183, 16270, 2713907, 2191⟩ ⟨19183, 16270, 2713908, 2191⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap50
  clean := bodyClean50
  cfix := PRE_first_tail_x15_r0_body.cfix50
  zpl := PRE_first_tail_x15_r0_body.zpl50
  zplnd := PRE_first_tail_x15_r0_body.zplnd50
  zn1 := PRE_first_tail_x15_r0_body.zn150
  zfirst := PRE_first_tail_x15_r0_body.zfirst50
  zscn := PRE_first_tail_x15_r0_body.zscn50
  zsmn := PRE_first_tail_x15_r0_body.zsmn50
  zgrow := PRE_first_tail_x15_r0_body.zgrow50
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab50
  zfresh := PRE_first_tail_x15_r0_body.zfresh50
  zcnd := PRE_first_tail_x15_r0_body.zcnd50
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi50
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt50
  zgP := PRE_first_tail_x15_r0_body.zg50_2665
  zkP := PRE_first_tail_x15_r0_body.zk50_2665
  zmP := PRE_first_tail_x15_r0_body.zm50_2665
  zgC := PRE_first_tail_x15_r0_body.zg50_2673467
  zkC := PRE_first_tail_x15_r0_body.zk50_2673467
  zmC := PRE_first_tail_x15_r0_body.zm50_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw50_2673472
  zwV := PRE_first_tail_x15_r0_body.zw50_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap50
  zclbd := PRE_first_tail_x15_r0_body.zclbd50
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap50 PRE_first_tail_x15_r0_body.stFoot50 PRE_first_tail_x15_r0_body.iso50 PRE_first_tail_x15_r0_body.zwr50
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP50
  csupp := PRE_first_tail_x15_r0_body.csupp50
  cbound := PRE_first_tail_x15_r0_body.cbound50
  zimg := PRE_first_tail_x15_r0_body.zimg50
  zctl := PRE_first_tail_x15_r0_body.zctl50
  zstack := PRE_first_tail_x15_r0_body.zstack50
  zjobs := PRE_first_tail_x15_r0_body.zjobs50
  zstores := PRE_first_tail_x15_r0_body.zstores50
  zroots := PRE_first_tail_x15_r0_body.zroots50
  znC := PRE_first_tail_x15_r0_body.znC50
  ctab := PRE_first_tail_x15_r0_body.ctab50
  zbin := PRE_first_tail_x15_r0_body.zbin50
  cbridge := PRE_first_tail_x15_r0_body.cbridge50
  sbridge := bodyBridge50
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj50
  cshiftR := fun h hNL => bodyCshift50 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN50
  raised := PRE_first_tail_x15_r0_body.raised50
  cbigs := PRE_first_tail_x15_r0_body.cbigs50
  cjcl := PRE_first_tail_x15_r0_body.cjcl50
  xnLe := Nat.le_of_ble_eq_true bodyXn50
  loLe := Nat.le_of_ble_eq_true bodyLo50
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB50
  cntM := bodyCntM50
  hiLe := Nat.le_of_ble_eq_true bodyHi50
  nhiLe := Nat.le_of_ble_eq_true bodyNhi50
  jsHeap := bodyJs50
  jsRoots := bodyJsRoots50
  jsNative := bodyJsNative50
  framesEmpty := bodyFramesEmpty50
  trailOld := by decide
  lowVars := bodyLow50

def bodyQs50 : List (Option Q) := []
noncomputable def bodyEs50 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr50.map fun r => nth? PRE_first_tail_x15_r0_body.st50.S2.tab r
kernel_rfl bodyResChk50 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs50 bodyQs50) = true
kernel_rfl bodyLq50 : bodyQs50.length = PRE_first_tail_x15_r0_body.cws50.length
kernel_rfl bodyNrLo50 : PRE_first_tail_x15_r0_body.nr50.all (Nat.ble PRE_first_tail_x15_r0_body.S488.tab.length) = true
kernel_rfl bodySub50 : (Oracles.PRE_first_tail_x15_r0_body.map_site50.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost50 : postSubB bodyM PRE_first_tail_x15_r0_body.ws50 PRE_first_tail_x15_r0_body.cws50 bodyQs50 = true
kernel_rfl bodyDrop50 : Nat.ble (20681 + (PRE_first_tail_x15_r0_body.s489.next - PRE_first_tail_x15_r0_body.s490.next)) 20700 = true
kernel_rfl bodyDropH50 : Nat.ble (354 + ((mlxOf PRE_first_tail_x15_r0_body.s489.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).next)) 354 = true
kernel_rfl bodyDropN50 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s489.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).nnext)) 0 = true
kernel_rfl bodyDv50 : bodyΘ.1.take 270 = bodyΘ.1.take 270 ++ PRE_first_tail_x15_r0_body.cws50
kernel_rfl bodyDe50 : bodyΘ.2.take 270 = bodyΘ.2.take 270 ++ PRE_first_tail_x15_r0_body.nr50.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st50.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 270) (bodyΘ.2.take 270)))
kernel_rfl bodyDl50 : (bodyΘ.1.take 270).length = (bodyΘ.2.take 270).length
kernel_rfl bodyDold50 : (bodyΘ.1.take 270).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws50).isNone && !PRE_first_tail_x15_r0_body.ws50.contains v) = true
kernel_rfl bodyDfree50 : (bodyΘ.2.take 270).all (fun e => (PRE_first_tail_x15_r0_body.cws50 ++ PRE_first_tail_x15_r0_body.ws50).all fun w => e.noVar w) = true

theorem bodyStep50 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20681, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.S488)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20700, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.S490) (206 + 1) :=
  bodySite bodyFacts50.cfix bodyFacts50.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st50.S2.tab) (Es := bodyEs50) (qs := bodyQs50)
    (ok := PRE_first_tail_x15_r0_body.st50.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site50 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts50
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site50 r hr) hi (MapOk.sub hm (sub_of_all bodySub50)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk50 r hr) hi hm ho hq)
    bodyLq50 rfl bodyNrLo50 (postSub_sound bodyPost50)
    (Nat.le_of_ble_eq_true bodyDrop50) (by decide) (Nat.le_of_ble_eq_true bodyDropH50) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN50) (by decide)
    bodyDv50 bodyDe50 bodyDl50 bodyDold50 bodyDfree50 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site51 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site51 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site51) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st51.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site51
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s505 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s506 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S505 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws51 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st51.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st51.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso51
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_51
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st51.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot51
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup51
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound51
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace51
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged51
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws51.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st51.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S505.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_51]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen51.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh51
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl51 : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl51 (PRE_first_tail_x15_r0_body.cncl50 bodyNcl50)

theorem bodyClean51 : Conv.JClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s505 :=
  PRE_first_tail_x15_r0_body.gjcl51 (PRE_first_tail_x15_r0_body.cjcl50 bodyClean50)

kernel_rfl bodyJsLe51 : Nat.ble PRE_first_tail_x15_r0_body.s488.next PRE_first_tail_x15_r0_body.s505.next = true
kernel_rfl bodyJsList51 : (PRE_first_tail_x15_r0_body.gjh51 ++ PRE_first_tail_x15_r0_body.cl51).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s505.next) PRE_first_tail_x15_r0_body.s507) = true
theorem bodyJs51 : JsHeapAbove PRE_first_tail_x15_r0_body.s505.next PRE_first_tail_x15_r0_body.s507 :=
  JsHeapAbove.glueSite bodyJs50 (Nat.le_of_ble_eq_true bodyJsLe51) PRE_first_tail_x15_r0_body.gjk51 PRE_first_tail_x15_r0_body.gjbd51 PRE_first_tail_x15_r0_body.cheap51 PRE_first_tail_x15_r0_body.zclbd51 bodyJsList51

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO490 : PRE_first_tail_x15_r0_body.S490.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S490.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr490 : bridgeOf PRE_first_tail_x15_r0_body.s490.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc490 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.S490) = fun _ _ => true
kernel_rfl bodyAcc492 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s492 PRE_first_tail_x15_r0_body.S492) = fun _ _ => true
kernel_rfl bodyBr493 : bridgeOf PRE_first_tail_x15_r0_body.s493.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt492 : isHalt PRE_first_tail_x15_r0_body.s492.ctl = false
kernel_rfl bodyTop493 : noRetBlock PRE_first_tail_x15_r0_body.s493 = true
kernel_rfl bodyCnt490 : countersOkB PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.s493 = true
kernel_rfl bodyO493 : PRE_first_tail_x15_r0_body.S493.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S493.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr494 : bridgeOf PRE_first_tail_x15_r0_body.s494.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt493 : countersOkB PRE_first_tail_x15_r0_body.s493 PRE_first_tail_x15_r0_body.s494 = true
kernel_rfl bodyO494 : PRE_first_tail_x15_r0_body.S494.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S494.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc494 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s494 PRE_first_tail_x15_r0_body.S494) = fun _ _ => true
kernel_rfl bodyAcc495 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s495 PRE_first_tail_x15_r0_body.S495) = fun _ _ => true
kernel_rfl bodyBr496 : bridgeOf PRE_first_tail_x15_r0_body.s496.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt495 : isHalt PRE_first_tail_x15_r0_body.s495.ctl = false
kernel_rfl bodyTop496 : noRetBlock PRE_first_tail_x15_r0_body.s496 = true
kernel_rfl bodyCnt494 : countersOkB PRE_first_tail_x15_r0_body.s494 PRE_first_tail_x15_r0_body.s496 = true
kernel_rfl bodyO496 : PRE_first_tail_x15_r0_body.S496.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S496.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr497 : bridgeOf PRE_first_tail_x15_r0_body.s497.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt496 : countersOkB PRE_first_tail_x15_r0_body.s496 PRE_first_tail_x15_r0_body.s497 = true
kernel_rfl bodyO497 : PRE_first_tail_x15_r0_body.S497.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S497.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc497 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s497 PRE_first_tail_x15_r0_body.S497) = fun _ _ => true
kernel_rfl bodyAcc498 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s498 PRE_first_tail_x15_r0_body.S498) = fun _ _ => true
kernel_rfl bodyBr499 : bridgeOf PRE_first_tail_x15_r0_body.s499.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt498 : isHalt PRE_first_tail_x15_r0_body.s498.ctl = false
kernel_rfl bodyTop499 : noRetBlock PRE_first_tail_x15_r0_body.s499 = true
kernel_rfl bodyCnt497 : countersOkB PRE_first_tail_x15_r0_body.s497 PRE_first_tail_x15_r0_body.s499 = true
kernel_rfl bodyO499 : PRE_first_tail_x15_r0_body.S499.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S499.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr500 : bridgeOf PRE_first_tail_x15_r0_body.s500.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt499 : countersOkB PRE_first_tail_x15_r0_body.s499 PRE_first_tail_x15_r0_body.s500 = true
kernel_rfl bodyO500 : PRE_first_tail_x15_r0_body.S500.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S500.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc500 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s500 PRE_first_tail_x15_r0_body.S500) = fun _ _ => true
kernel_rfl bodyAcc501 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s501 PRE_first_tail_x15_r0_body.S501) = fun _ _ => true
kernel_rfl bodyBr502 : bridgeOf PRE_first_tail_x15_r0_body.s502.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt501 : isHalt PRE_first_tail_x15_r0_body.s501.ctl = false
kernel_rfl bodyTop502 : noRetBlock PRE_first_tail_x15_r0_body.s502 = true
kernel_rfl bodyCnt500 : countersOkB PRE_first_tail_x15_r0_body.s500 PRE_first_tail_x15_r0_body.s502 = true
kernel_rfl bodyO502 : PRE_first_tail_x15_r0_body.S502.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S502.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr503 : bridgeOf PRE_first_tail_x15_r0_body.s503.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt502 : countersOkB PRE_first_tail_x15_r0_body.s502 PRE_first_tail_x15_r0_body.s503 = true
kernel_rfl bodyO503 : PRE_first_tail_x15_r0_body.S503.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S503.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc503 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s503 PRE_first_tail_x15_r0_body.S503) = fun _ _ => true
kernel_rfl bodyAcc504 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s504 PRE_first_tail_x15_r0_body.S504) = fun _ _ => true
kernel_rfl bodyBr505 : bridgeOf PRE_first_tail_x15_r0_body.s505.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt504 : isHalt PRE_first_tail_x15_r0_body.s504.ctl = false
kernel_rfl bodyTop505 : noRetBlock PRE_first_tail_x15_r0_body.s505 = true
kernel_rfl bodyCnt503 : countersOkB PRE_first_tail_x15_r0_body.s503 PRE_first_tail_x15_r0_body.s505 = true

theorem bodyGlue51 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20700, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.S490)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20700, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.S505) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc490 PRE_first_tail_x15_r0_body.bodyRunSeg132 bodyAcc492 bodyHalt492 PRE_first_tail_x15_r0_body.bodyStepA133 bodyTop493 (fun _ hm => bodyO490 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr490).trans bodyInactive0) (bodyBr493.trans bodyBr490.symm) bodyCnt490 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA133 PRE_first_tail_x15_r0_body.sizeArgsA133 PRE_first_tail_x15_r0_body.sizeSymA133 PRE_first_tail_x15_r0_body.sizeMlxA133 PRE_first_tail_x15_r0_body.sizePayA133 PRE_first_tail_x15_r0_body.sizeTaA133 PRE_first_tail_x15_r0_body.sizeDecA133 PRE_first_tail_x15_r0_body.sizePreA133 PRE_first_tail_x15_r0_body.bodyPatchB133 (fun _ hm => bodyO493 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr493).trans bodyInactive0) (bodyBr494.trans bodyBr493.symm) bodyCnt493 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc494 PRE_first_tail_x15_r0_body.bodyRunSeg133 bodyAcc495 bodyHalt495 PRE_first_tail_x15_r0_body.bodyStepA134 bodyTop496 (fun _ hm => bodyO494 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr494).trans bodyInactive0) (bodyBr496.trans bodyBr494.symm) bodyCnt494 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA134 PRE_first_tail_x15_r0_body.sizeArgsA134 PRE_first_tail_x15_r0_body.sizeSymA134 PRE_first_tail_x15_r0_body.sizeMlxA134 PRE_first_tail_x15_r0_body.sizePayA134 PRE_first_tail_x15_r0_body.sizeTaA134 PRE_first_tail_x15_r0_body.sizeDecA134 PRE_first_tail_x15_r0_body.sizePreA134 PRE_first_tail_x15_r0_body.bodyPatchB134 (fun _ hm => bodyO496 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr496).trans bodyInactive0) (bodyBr497.trans bodyBr496.symm) bodyCnt496 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc497 PRE_first_tail_x15_r0_body.bodyRunSeg134 bodyAcc498 bodyHalt498 PRE_first_tail_x15_r0_body.bodyStepA135 bodyTop499 (fun _ hm => bodyO497 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr497).trans bodyInactive0) (bodyBr499.trans bodyBr497.symm) bodyCnt497 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA135 PRE_first_tail_x15_r0_body.sizeArgsA135 PRE_first_tail_x15_r0_body.sizeSymA135 PRE_first_tail_x15_r0_body.sizeMlxA135 PRE_first_tail_x15_r0_body.sizePayA135 PRE_first_tail_x15_r0_body.sizeTaA135 PRE_first_tail_x15_r0_body.sizeDecA135 PRE_first_tail_x15_r0_body.sizePreA135 PRE_first_tail_x15_r0_body.bodyPatchB135 (fun _ hm => bodyO499 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr499).trans bodyInactive0) (bodyBr500.trans bodyBr499.symm) bodyCnt499 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc500 PRE_first_tail_x15_r0_body.bodyRunSeg135 bodyAcc501 bodyHalt501 PRE_first_tail_x15_r0_body.bodyStepA136 bodyTop502 (fun _ hm => bodyO500 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr500).trans bodyInactive0) (bodyBr502.trans bodyBr500.symm) bodyCnt500 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA136 PRE_first_tail_x15_r0_body.sizeArgsA136 PRE_first_tail_x15_r0_body.sizeSymA136 PRE_first_tail_x15_r0_body.sizeMlxA136 PRE_first_tail_x15_r0_body.sizePayA136 PRE_first_tail_x15_r0_body.sizeTaA136 PRE_first_tail_x15_r0_body.sizeDecA136 PRE_first_tail_x15_r0_body.sizePreA136 PRE_first_tail_x15_r0_body.bodyPatchB136 (fun _ hm => bodyO502 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr502).trans bodyInactive0) (bodyBr503.trans bodyBr502.symm) bodyCnt502 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc503 PRE_first_tail_x15_r0_body.bodyRunSeg136 bodyAcc504 bodyHalt504 PRE_first_tail_x15_r0_body.bodyStepA137 bodyTop505 (fun _ hm => bodyO503 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr503).trans bodyInactive0) (bodyBr505.trans bodyBr503.symm) bodyCnt503 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift51 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S505.tab.length PRE_first_tail_x15_r0_body.s505.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P51.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.s507.ffi PRE_first_tail_x15_r0_body.s506.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_51
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_51
  have hcl : SSt (· < 2282) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S505.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_51] <;> decide) PRE_first_tail_x15_r0_body.cnodesK51 PRE_first_tail_x15_r0_body.cobjsK51
      PRE_first_tail_x15_r0_body.citemsK51 PRE_first_tail_x15_r0_body.cbd51 PRE_first_tail_x15_r0_body.csst51
  exact PRE_first_tail_x15_r0_body.cshift51 bodyNcl51 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_51] at this; exact this)


kernel_rfl bodyFramesEmpty51 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s506 a).isEmpty) = true
kernel_rfl bodyJsRoots51 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s505.next) PRE_first_tail_x15_r0_body.s507.trace PRE_first_tail_x15_r0_body.s507 = true
kernel_rfl bodyJsNative51 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s507.ffi) = true
kernel_rfl bodyLow51 : (PRE_first_tail_x15_r0_body.cws51 ++ PRE_first_tail_x15_r0_body.ws51).all (Nat.ble 9) = true
kernel_rfl bodyCntM51 : countersOkB PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.s506 = true
kernel_rfl bodyHi51 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).next setupP.E = true
kernel_rfl bodyNhi51 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge51 : bridgeOf PRE_first_tail_x15_r0_body.s506.ffi = bridgeOf PRE_first_tail_x15_r0_body.s505.ffi
kernel_rfl bodyNN51 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s505.ffi).nnext PRE_first_tail_x15_r0_body.P51.NL = true
kernel_rfl bodyXn51 : Nat.ble (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).next = true
kernel_rfl bodyLo51 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).next = true
theorem bodyFacts51 : BodySiteFacts PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.s506 PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S505 PRE_first_tail_x15_r0_body.S506 PRE_first_tail_x15_r0_body.S507
    PRE_first_tail_x15_r0_body.ws51 PRE_first_tail_x15_r0_body.cws51 PRE_first_tail_x15_r0_body.nr51 PRE_first_tail_x15_r0_body.pl51 PRE_first_tail_x15_r0_body.cl51 2716538 2282 PRE_first_tail_x15_r0_body.kd51 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.P51
    ⟨19217, 16289, 2715383, 2264⟩ ⟨19220, 16316, 2715389, 2282⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap51
  clean := bodyClean51
  cfix := PRE_first_tail_x15_r0_body.cfix51
  zpl := PRE_first_tail_x15_r0_body.zpl51
  zplnd := PRE_first_tail_x15_r0_body.zplnd51
  zn1 := PRE_first_tail_x15_r0_body.zn151
  zfirst := PRE_first_tail_x15_r0_body.zfirst51
  zscn := PRE_first_tail_x15_r0_body.zscn51
  zsmn := PRE_first_tail_x15_r0_body.zsmn51
  zgrow := PRE_first_tail_x15_r0_body.zgrow51
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab51
  zfresh := PRE_first_tail_x15_r0_body.zfresh51
  zcnd := PRE_first_tail_x15_r0_body.zcnd51
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi51
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt51
  zgP := PRE_first_tail_x15_r0_body.zg51_2665
  zkP := PRE_first_tail_x15_r0_body.zk51_2665
  zmP := PRE_first_tail_x15_r0_body.zm51_2665
  zgC := PRE_first_tail_x15_r0_body.zg51_2673467
  zkC := PRE_first_tail_x15_r0_body.zk51_2673467
  zmC := PRE_first_tail_x15_r0_body.zm51_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw51_2673472
  zwV := PRE_first_tail_x15_r0_body.zw51_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap51
  zclbd := PRE_first_tail_x15_r0_body.zclbd51
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap51 PRE_first_tail_x15_r0_body.stFoot51 PRE_first_tail_x15_r0_body.iso51 PRE_first_tail_x15_r0_body.zwr51
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP51
  csupp := PRE_first_tail_x15_r0_body.csupp51
  cbound := PRE_first_tail_x15_r0_body.cbound51
  zimg := PRE_first_tail_x15_r0_body.zimg51
  zctl := PRE_first_tail_x15_r0_body.zctl51
  zstack := PRE_first_tail_x15_r0_body.zstack51
  zjobs := PRE_first_tail_x15_r0_body.zjobs51
  zstores := PRE_first_tail_x15_r0_body.zstores51
  zroots := PRE_first_tail_x15_r0_body.zroots51
  znC := PRE_first_tail_x15_r0_body.znC51
  ctab := PRE_first_tail_x15_r0_body.ctab51
  zbin := PRE_first_tail_x15_r0_body.zbin51
  cbridge := PRE_first_tail_x15_r0_body.cbridge51
  sbridge := bodyBridge51
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj51
  cshiftR := fun h hNL => bodyCshift51 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN51
  raised := PRE_first_tail_x15_r0_body.raised51
  cbigs := PRE_first_tail_x15_r0_body.cbigs51
  cjcl := PRE_first_tail_x15_r0_body.cjcl51
  xnLe := Nat.le_of_ble_eq_true bodyXn51
  loLe := Nat.le_of_ble_eq_true bodyLo51
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB51
  cntM := bodyCntM51
  hiLe := Nat.le_of_ble_eq_true bodyHi51
  nhiLe := Nat.le_of_ble_eq_true bodyNhi51
  jsHeap := bodyJs51
  jsRoots := bodyJsRoots51
  jsNative := bodyJsNative51
  framesEmpty := bodyFramesEmpty51
  trailOld := by decide
  lowVars := bodyLow51

def bodyQs51 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs51 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr51.map fun r => nth? PRE_first_tail_x15_r0_body.st51.S5.tab r
kernel_rfl bodyResChk51 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs51 bodyQs51) = true
kernel_rfl bodyLq51 : bodyQs51.length = PRE_first_tail_x15_r0_body.cws51.length
kernel_rfl bodyNrLo51 : PRE_first_tail_x15_r0_body.nr51.all (Nat.ble PRE_first_tail_x15_r0_body.S505.tab.length) = true
kernel_rfl bodySub51 : (Oracles.PRE_first_tail_x15_r0_body.map_site51.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost51 : postSubB bodyM PRE_first_tail_x15_r0_body.ws51 PRE_first_tail_x15_r0_body.cws51 bodyQs51 = true
kernel_rfl bodyDrop51 : Nat.ble (20700 + (PRE_first_tail_x15_r0_body.s506.next - PRE_first_tail_x15_r0_body.s507.next)) 21849 = true
kernel_rfl bodyDropH51 : Nat.ble (354 + ((mlxOf PRE_first_tail_x15_r0_body.s506.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).next)) 379 = true
kernel_rfl bodyDropN51 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s506.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).nnext)) 0 = true
kernel_rfl bodyDv51 : bodyΘ.1.take 288 = bodyΘ.1.take 270 ++ PRE_first_tail_x15_r0_body.cws51
kernel_rfl bodyDe51 : bodyΘ.2.take 288 = bodyΘ.2.take 270 ++ PRE_first_tail_x15_r0_body.nr51.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st51.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 270) (bodyΘ.2.take 270)))
kernel_rfl bodyDl51 : (bodyΘ.1.take 270).length = (bodyΘ.2.take 270).length
kernel_rfl bodyDold51 : (bodyΘ.1.take 270).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws51).isNone && !PRE_first_tail_x15_r0_body.ws51.contains v) = true
kernel_rfl bodyDfree51 : (bodyΘ.2.take 288).all (fun e => (PRE_first_tail_x15_r0_body.cws51 ++ PRE_first_tail_x15_r0_body.ws51).all fun w => e.noVar w) = true

theorem bodyStep51 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20700, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.S505)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21849, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.S507) (11334 + 1) :=
  bodySite bodyFacts51.cfix bodyFacts51.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st51.S5.tab) (Es := bodyEs51) (qs := bodyQs51)
    (ok := PRE_first_tail_x15_r0_body.st51.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site51 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts51
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site51 r hr) hi (MapOk.sub hm (sub_of_all bodySub51)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk51 r hr) hi hm ho hq)
    bodyLq51 rfl bodyNrLo51 (postSub_sound bodyPost51)
    (Nat.le_of_ble_eq_true bodyDrop51) (by decide) (Nat.le_of_ble_eq_true bodyDropH51) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN51) (by decide)
    bodyDv51 bodyDe51 bodyDl51 bodyDold51 bodyDfree51 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyOracles_13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_g52 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g52 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g52) (List.take 7 (List.drop 512 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site52 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site52 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site52) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st52.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g53 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g53 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g53) (List.take 3 (List.drop 519 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

noncomputable def PRE_first_tail_x15_r0_body.map_site53 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site53 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site53) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g54 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g54 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g54) (List.take 16 (List.drop 522 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site54 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site54 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site54) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st54.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g55 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g55 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g55) (List.take 7 (List.drop 538 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site55 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site55 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site55) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st55.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site52 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site52 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site52) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st52.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site52
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s513 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s514 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S513 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws52 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st52.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st52.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso52
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_52
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st52.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot52
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup52
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound52
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace52
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged52
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws52.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st52.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S513.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_52]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen52.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh52
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl52 : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl52 (PRE_first_tail_x15_r0_body.cncl51 bodyNcl51)

theorem bodyClean52 : Conv.JClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s513 :=
  PRE_first_tail_x15_r0_body.gjcl52 (PRE_first_tail_x15_r0_body.cjcl51 bodyClean51)

kernel_rfl bodyJsLe52 : Nat.ble PRE_first_tail_x15_r0_body.s505.next PRE_first_tail_x15_r0_body.s513.next = true
kernel_rfl bodyJsList52 : (PRE_first_tail_x15_r0_body.gjh52 ++ PRE_first_tail_x15_r0_body.cl52).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s513.next) PRE_first_tail_x15_r0_body.s515) = true
theorem bodyJs52 : JsHeapAbove PRE_first_tail_x15_r0_body.s513.next PRE_first_tail_x15_r0_body.s515 :=
  JsHeapAbove.glueSite bodyJs51 (Nat.le_of_ble_eq_true bodyJsLe52) PRE_first_tail_x15_r0_body.gjk52 PRE_first_tail_x15_r0_body.gjbd52 PRE_first_tail_x15_r0_body.cheap52 PRE_first_tail_x15_r0_body.zclbd52 bodyJsList52

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO507 : PRE_first_tail_x15_r0_body.S507.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S507.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr507 : bridgeOf PRE_first_tail_x15_r0_body.s507.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc507 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.S507) = fun _ _ => true
kernel_rfl bodyAcc508 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s508 PRE_first_tail_x15_r0_body.S508) = fun _ _ => true
kernel_rfl bodyBr509 : bridgeOf PRE_first_tail_x15_r0_body.s509.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt508 : isHalt PRE_first_tail_x15_r0_body.s508.ctl = false
kernel_rfl bodyTop509 : noRetBlock PRE_first_tail_x15_r0_body.s509 = true
kernel_rfl bodyCnt507 : countersOkB PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.s509 = true
kernel_rfl bodyO509 : PRE_first_tail_x15_r0_body.S509.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S509.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr510 : bridgeOf PRE_first_tail_x15_r0_body.s510.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt509 : countersOkB PRE_first_tail_x15_r0_body.s509 PRE_first_tail_x15_r0_body.s510 = true
kernel_rfl bodyO510 : PRE_first_tail_x15_r0_body.S510.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S510.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc510 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s510 PRE_first_tail_x15_r0_body.S510) = fun _ _ => true
kernel_rfl bodyAcc512 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s512 PRE_first_tail_x15_r0_body.S512) = fun _ _ => true
kernel_rfl bodyBr513 : bridgeOf PRE_first_tail_x15_r0_body.s513.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt512 : isHalt PRE_first_tail_x15_r0_body.s512.ctl = false
kernel_rfl bodyTop513 : noRetBlock PRE_first_tail_x15_r0_body.s513 = true
kernel_rfl bodyCnt510 : countersOkB PRE_first_tail_x15_r0_body.s510 PRE_first_tail_x15_r0_body.s513 = true

theorem bodyGlue52 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21849, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.S507)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21849, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s513 PRE_first_tail_x15_r0_body.S513) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21849, 379, 0, 288⟩) bodyAcc507 PRE_first_tail_x15_r0_body.bodyRunSeg137 bodyAcc508 bodyHalt508 PRE_first_tail_x15_r0_body.bodyStepA138 bodyTop509 (fun _ hm => bodyO507 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr507).trans bodyInactive0) (bodyBr509.trans bodyBr507.symm) bodyCnt507 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21849, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA138 PRE_first_tail_x15_r0_body.sizeArgsA138 PRE_first_tail_x15_r0_body.sizeSymA138 PRE_first_tail_x15_r0_body.sizeMlxA138 PRE_first_tail_x15_r0_body.sizePayA138 PRE_first_tail_x15_r0_body.sizeTaA138 PRE_first_tail_x15_r0_body.sizeDecA138 PRE_first_tail_x15_r0_body.sizePreA138 PRE_first_tail_x15_r0_body.bodyPatchB138 (fun _ hm => bodyO509 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr509).trans bodyInactive0) (bodyBr510.trans bodyBr509.symm) bodyCnt509 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21849, 379, 0, 288⟩) bodyAcc510 PRE_first_tail_x15_r0_body.bodyRunSeg138 bodyAcc512 bodyHalt512 PRE_first_tail_x15_r0_body.bodyStepA139 bodyTop513 (fun _ hm => bodyO510 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr510).trans bodyInactive0) (bodyBr513.trans bodyBr510.symm) bodyCnt510 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift52 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S513.tab.length PRE_first_tail_x15_r0_body.s513.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P52.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P52 2303 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.s515.ffi PRE_first_tail_x15_r0_body.s514.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_52
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_52
  have hcl : SSt (· < 2303) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S513.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_52] <;> decide) PRE_first_tail_x15_r0_body.cnodesK52 PRE_first_tail_x15_r0_body.cobjsK52
      PRE_first_tail_x15_r0_body.citemsK52 PRE_first_tail_x15_r0_body.cbd52 PRE_first_tail_x15_r0_body.csst52
  exact PRE_first_tail_x15_r0_body.cshift52 bodyNcl52 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_52] at this; exact this)


kernel_rfl bodyFramesEmpty52 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s514 a).isEmpty) = true
kernel_rfl bodyJsRoots52 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s513.next) PRE_first_tail_x15_r0_body.s515.trace PRE_first_tail_x15_r0_body.s515 = true
kernel_rfl bodyJsNative52 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s515.ffi) = true
kernel_rfl bodyLow52 : (PRE_first_tail_x15_r0_body.cws52 ++ PRE_first_tail_x15_r0_body.ws52).all (Nat.ble 9) = true
kernel_rfl bodyCntM52 : countersOkB PRE_first_tail_x15_r0_body.s513 PRE_first_tail_x15_r0_body.s514 = true
kernel_rfl bodyHi52 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s515.ffi).next setupP.E = true
kernel_rfl bodyNhi52 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s515.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge52 : bridgeOf PRE_first_tail_x15_r0_body.s514.ffi = bridgeOf PRE_first_tail_x15_r0_body.s513.ffi
kernel_rfl bodyNN52 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s513.ffi).nnext PRE_first_tail_x15_r0_body.P52.NL = true
kernel_rfl bodyXn52 : Nat.ble (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s515.ffi).next = true
kernel_rfl bodyLo52 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s515.ffi).next = true
theorem bodyFacts52 : BodySiteFacts PRE_first_tail_x15_r0_body.s513 PRE_first_tail_x15_r0_body.s514 PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S513 PRE_first_tail_x15_r0_body.S514 PRE_first_tail_x15_r0_body.S515
    PRE_first_tail_x15_r0_body.ws52 PRE_first_tail_x15_r0_body.cws52 PRE_first_tail_x15_r0_body.nr52 PRE_first_tail_x15_r0_body.pl52 PRE_first_tail_x15_r0_body.cl52 2715881 2303 PRE_first_tail_x15_r0_body.kd52 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.P52
    ⟨19233, 16329, 2715879, 2303⟩ ⟨19233, 16329, 2715879, 2303⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap52
  clean := bodyClean52
  cfix := PRE_first_tail_x15_r0_body.cfix52
  zpl := PRE_first_tail_x15_r0_body.zpl52
  zplnd := PRE_first_tail_x15_r0_body.zplnd52
  zn1 := PRE_first_tail_x15_r0_body.zn152
  zfirst := PRE_first_tail_x15_r0_body.zfirst52
  zscn := PRE_first_tail_x15_r0_body.zscn52
  zsmn := PRE_first_tail_x15_r0_body.zsmn52
  zgrow := PRE_first_tail_x15_r0_body.zgrow52
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab52
  zfresh := PRE_first_tail_x15_r0_body.zfresh52
  zcnd := PRE_first_tail_x15_r0_body.zcnd52
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi52
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt52
  zgP := PRE_first_tail_x15_r0_body.zg52_2665
  zkP := PRE_first_tail_x15_r0_body.zk52_2665
  zmP := PRE_first_tail_x15_r0_body.zm52_2665
  zgC := PRE_first_tail_x15_r0_body.zg52_2673467
  zkC := PRE_first_tail_x15_r0_body.zk52_2673467
  zmC := PRE_first_tail_x15_r0_body.zm52_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw52_2673472
  zwV := PRE_first_tail_x15_r0_body.zw52_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap52
  zclbd := PRE_first_tail_x15_r0_body.zclbd52
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap52 PRE_first_tail_x15_r0_body.stFoot52 PRE_first_tail_x15_r0_body.iso52 PRE_first_tail_x15_r0_body.zwr52
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP52
  csupp := PRE_first_tail_x15_r0_body.csupp52
  cbound := PRE_first_tail_x15_r0_body.cbound52
  zimg := PRE_first_tail_x15_r0_body.zimg52
  zctl := PRE_first_tail_x15_r0_body.zctl52
  zstack := PRE_first_tail_x15_r0_body.zstack52
  zjobs := PRE_first_tail_x15_r0_body.zjobs52
  zstores := PRE_first_tail_x15_r0_body.zstores52
  zroots := PRE_first_tail_x15_r0_body.zroots52
  znC := PRE_first_tail_x15_r0_body.znC52
  ctab := PRE_first_tail_x15_r0_body.ctab52
  zbin := PRE_first_tail_x15_r0_body.zbin52
  cbridge := PRE_first_tail_x15_r0_body.cbridge52
  sbridge := bodyBridge52
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj52
  cshiftR := fun h hNL => bodyCshift52 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN52
  raised := PRE_first_tail_x15_r0_body.raised52
  cbigs := PRE_first_tail_x15_r0_body.cbigs52
  cjcl := PRE_first_tail_x15_r0_body.cjcl52
  xnLe := Nat.le_of_ble_eq_true bodyXn52
  loLe := Nat.le_of_ble_eq_true bodyLo52
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB52
  cntM := bodyCntM52
  hiLe := Nat.le_of_ble_eq_true bodyHi52
  nhiLe := Nat.le_of_ble_eq_true bodyNhi52
  jsHeap := bodyJs52
  jsRoots := bodyJsRoots52
  jsNative := bodyJsNative52
  framesEmpty := bodyFramesEmpty52
  trailOld := by decide
  lowVars := bodyLow52

def bodyQs52 : List (Option Q) := []
noncomputable def bodyEs52 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr52.map fun r => nth? PRE_first_tail_x15_r0_body.st52.S2.tab r
kernel_rfl bodyResChk52 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs52 bodyQs52) = true
kernel_rfl bodyLq52 : bodyQs52.length = PRE_first_tail_x15_r0_body.cws52.length
kernel_rfl bodyNrLo52 : PRE_first_tail_x15_r0_body.nr52.all (Nat.ble PRE_first_tail_x15_r0_body.S513.tab.length) = true
kernel_rfl bodySub52 : (Oracles.PRE_first_tail_x15_r0_body.map_site52.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost52 : postSubB bodyM PRE_first_tail_x15_r0_body.ws52 PRE_first_tail_x15_r0_body.cws52 bodyQs52 = true
kernel_rfl bodyDrop52 : Nat.ble (21849 + (PRE_first_tail_x15_r0_body.s514.next - PRE_first_tail_x15_r0_body.s515.next)) 21851 = true
kernel_rfl bodyDropH52 : Nat.ble (379 + ((mlxOf PRE_first_tail_x15_r0_body.s514.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s515.ffi).next)) 379 = true
kernel_rfl bodyDropN52 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s514.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s515.ffi).nnext)) 0 = true
kernel_rfl bodyDv52 : bodyΘ.1.take 288 = bodyΘ.1.take 288 ++ PRE_first_tail_x15_r0_body.cws52
kernel_rfl bodyDe52 : bodyΘ.2.take 288 = bodyΘ.2.take 288 ++ PRE_first_tail_x15_r0_body.nr52.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st52.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 288) (bodyΘ.2.take 288)))
kernel_rfl bodyDl52 : (bodyΘ.1.take 288).length = (bodyΘ.2.take 288).length
kernel_rfl bodyDold52 : (bodyΘ.1.take 288).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws52).isNone && !PRE_first_tail_x15_r0_body.ws52.contains v) = true
kernel_rfl bodyDfree52 : (bodyΘ.2.take 288).all (fun e => (PRE_first_tail_x15_r0_body.cws52 ++ PRE_first_tail_x15_r0_body.ws52).all fun w => e.noVar w) = true

theorem bodyStep52 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21849, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s513 PRE_first_tail_x15_r0_body.S513)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21851, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.S515) (27 + 1) :=
  bodySite bodyFacts52.cfix bodyFacts52.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st52.S2.tab) (Es := bodyEs52) (qs := bodyQs52)
    (ok := PRE_first_tail_x15_r0_body.st52.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site52 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts52
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site52 r hr) hi (MapOk.sub hm (sub_of_all bodySub52)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk52 r hr) hi hm ho hq)
    bodyLq52 rfl bodyNrLo52 (postSub_sound bodyPost52)
    (Nat.le_of_ble_eq_true bodyDrop52) (by decide) (Nat.le_of_ble_eq_true bodyDropH52) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN52) (by decide)
    bodyDv52 bodyDe52 bodyDl52 bodyDold52 bodyDfree52 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x15_r0_body.map_site53 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site53 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site53) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site53
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s517 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s518 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S517 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws53 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso53
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_53
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot53
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup53
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound53
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace53
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged53
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws53.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st53.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S517.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_53]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen53.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh53
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl53 : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl53 (PRE_first_tail_x15_r0_body.cncl52 bodyNcl52)

theorem bodyClean53 : Conv.JClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s517 :=
  PRE_first_tail_x15_r0_body.gjcl53 (PRE_first_tail_x15_r0_body.cjcl52 bodyClean52)

kernel_rfl bodyJsLe53 : Nat.ble PRE_first_tail_x15_r0_body.s513.next PRE_first_tail_x15_r0_body.s517.next = true
kernel_rfl bodyJsList53 : (PRE_first_tail_x15_r0_body.gjh53 ++ PRE_first_tail_x15_r0_body.cl53).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s517.next) PRE_first_tail_x15_r0_body.s519) = true
theorem bodyJs53 : JsHeapAbove PRE_first_tail_x15_r0_body.s517.next PRE_first_tail_x15_r0_body.s519 :=
  JsHeapAbove.glueSite bodyJs52 (Nat.le_of_ble_eq_true bodyJsLe53) PRE_first_tail_x15_r0_body.gjk53 PRE_first_tail_x15_r0_body.gjbd53 PRE_first_tail_x15_r0_body.cheap53 PRE_first_tail_x15_r0_body.zclbd53 bodyJsList53

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO515 : PRE_first_tail_x15_r0_body.S515.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S515.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr515 : bridgeOf PRE_first_tail_x15_r0_body.s515.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc515 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.S515) = fun _ _ => true
kernel_rfl bodyAcc516 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s516 PRE_first_tail_x15_r0_body.S516) = fun _ _ => true
kernel_rfl bodyBr517 : bridgeOf PRE_first_tail_x15_r0_body.s517.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt516 : isHalt PRE_first_tail_x15_r0_body.s516.ctl = false
kernel_rfl bodyTop517 : noRetBlock PRE_first_tail_x15_r0_body.s517 = true
kernel_rfl bodyCnt515 : countersOkB PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.s517 = true

theorem bodyGlue53 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21851, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.S515)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21851, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.S517) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21851, 379, 0, 288⟩) bodyAcc515 PRE_first_tail_x15_r0_body.bodyRunSeg139 bodyAcc516 bodyHalt516 PRE_first_tail_x15_r0_body.bodyStepA140 bodyTop517 (fun _ hm => bodyO515 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr515).trans bodyInactive0) (bodyBr517.trans bodyBr515.symm) bodyCnt515 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift53 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S517.tab.length PRE_first_tail_x15_r0_body.s517.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P53.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.s519.ffi PRE_first_tail_x15_r0_body.s518.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_53
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_53
  have hcl : SSt (· < 2320) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S517.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_53] <;> decide) PRE_first_tail_x15_r0_body.cnodesK53 PRE_first_tail_x15_r0_body.cobjsK53
      PRE_first_tail_x15_r0_body.citemsK53 PRE_first_tail_x15_r0_body.cbd53 PRE_first_tail_x15_r0_body.csst53
  exact PRE_first_tail_x15_r0_body.cshift53 bodyNcl53 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_53] at this; exact this)


kernel_rfl bodyFramesEmpty53 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s518 a).isEmpty) = true
kernel_rfl bodyJsRoots53 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s517.next) PRE_first_tail_x15_r0_body.s519.trace PRE_first_tail_x15_r0_body.s519 = true
kernel_rfl bodyJsNative53 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s519.ffi) = true
kernel_rfl bodyLow53 : (PRE_first_tail_x15_r0_body.cws53 ++ PRE_first_tail_x15_r0_body.ws53).all (Nat.ble 9) = true
kernel_rfl bodyCntM53 : countersOkB PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.s518 = true
kernel_rfl bodyHi53 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).next setupP.E = true
kernel_rfl bodyNhi53 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge53 : bridgeOf PRE_first_tail_x15_r0_body.s518.ffi = bridgeOf PRE_first_tail_x15_r0_body.s517.ffi
kernel_rfl bodyNN53 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s517.ffi).nnext PRE_first_tail_x15_r0_body.P53.NL = true
kernel_rfl bodyXn53 : Nat.ble (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).next = true
kernel_rfl bodyLo53 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).next = true
theorem bodyFacts53 : BodySiteFacts PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.s518 PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S517 PRE_first_tail_x15_r0_body.S518 PRE_first_tail_x15_r0_body.S519
    PRE_first_tail_x15_r0_body.ws53 PRE_first_tail_x15_r0_body.cws53 PRE_first_tail_x15_r0_body.nr53 PRE_first_tail_x15_r0_body.pl53 PRE_first_tail_x15_r0_body.cl53 2716187 2320 PRE_first_tail_x15_r0_body.kd53 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.P53
    ⟨19240, 16333, 2716167, 2320⟩ ⟨19240, 16333, 2716168, 2320⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap53
  clean := bodyClean53
  cfix := PRE_first_tail_x15_r0_body.cfix53
  zpl := PRE_first_tail_x15_r0_body.zpl53
  zplnd := PRE_first_tail_x15_r0_body.zplnd53
  zn1 := PRE_first_tail_x15_r0_body.zn153
  zfirst := PRE_first_tail_x15_r0_body.zfirst53
  zscn := PRE_first_tail_x15_r0_body.zscn53
  zsmn := PRE_first_tail_x15_r0_body.zsmn53
  zgrow := PRE_first_tail_x15_r0_body.zgrow53
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab53
  zfresh := PRE_first_tail_x15_r0_body.zfresh53
  zcnd := PRE_first_tail_x15_r0_body.zcnd53
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi53
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt53
  zgP := PRE_first_tail_x15_r0_body.zg53_2665
  zkP := PRE_first_tail_x15_r0_body.zk53_2665
  zmP := PRE_first_tail_x15_r0_body.zm53_2665
  zgC := PRE_first_tail_x15_r0_body.zg53_2673467
  zkC := PRE_first_tail_x15_r0_body.zk53_2673467
  zmC := PRE_first_tail_x15_r0_body.zm53_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw53_2673472
  zwV := PRE_first_tail_x15_r0_body.zw53_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap53
  zclbd := PRE_first_tail_x15_r0_body.zclbd53
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap53 PRE_first_tail_x15_r0_body.stFoot53 PRE_first_tail_x15_r0_body.iso53 PRE_first_tail_x15_r0_body.zwr53
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP53
  csupp := PRE_first_tail_x15_r0_body.csupp53
  cbound := PRE_first_tail_x15_r0_body.cbound53
  zimg := PRE_first_tail_x15_r0_body.zimg53
  zctl := PRE_first_tail_x15_r0_body.zctl53
  zstack := PRE_first_tail_x15_r0_body.zstack53
  zjobs := PRE_first_tail_x15_r0_body.zjobs53
  zstores := PRE_first_tail_x15_r0_body.zstores53
  zroots := PRE_first_tail_x15_r0_body.zroots53
  znC := PRE_first_tail_x15_r0_body.znC53
  ctab := PRE_first_tail_x15_r0_body.ctab53
  zbin := PRE_first_tail_x15_r0_body.zbin53
  cbridge := PRE_first_tail_x15_r0_body.cbridge53
  sbridge := bodyBridge53
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj53
  cshiftR := fun h hNL => bodyCshift53 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN53
  raised := PRE_first_tail_x15_r0_body.raised53
  cbigs := PRE_first_tail_x15_r0_body.cbigs53
  cjcl := PRE_first_tail_x15_r0_body.cjcl53
  xnLe := Nat.le_of_ble_eq_true bodyXn53
  loLe := Nat.le_of_ble_eq_true bodyLo53
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB53
  cntM := bodyCntM53
  hiLe := Nat.le_of_ble_eq_true bodyHi53
  nhiLe := Nat.le_of_ble_eq_true bodyNhi53
  jsHeap := bodyJs53
  jsRoots := bodyJsRoots53
  jsNative := bodyJsNative53
  framesEmpty := bodyFramesEmpty53
  trailOld := by decide
  lowVars := bodyLow53

def bodyQs53 : List (Option Q) := []
noncomputable def bodyEs53 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr53.map fun r => nth? PRE_first_tail_x15_r0_body.st53.S2.tab r
kernel_rfl bodyResChk53 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs53 bodyQs53) = true
kernel_rfl bodyLq53 : bodyQs53.length = PRE_first_tail_x15_r0_body.cws53.length
kernel_rfl bodyNrLo53 : PRE_first_tail_x15_r0_body.nr53.all (Nat.ble PRE_first_tail_x15_r0_body.S517.tab.length) = true
kernel_rfl bodySub53 : (Oracles.PRE_first_tail_x15_r0_body.map_site53.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost53 : postSubB bodyM PRE_first_tail_x15_r0_body.ws53 PRE_first_tail_x15_r0_body.cws53 bodyQs53 = true
kernel_rfl bodyDrop53 : Nat.ble (21851 + (PRE_first_tail_x15_r0_body.s518.next - PRE_first_tail_x15_r0_body.s519.next)) 21870 = true
kernel_rfl bodyDropH53 : Nat.ble (379 + ((mlxOf PRE_first_tail_x15_r0_body.s518.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).next)) 379 = true
kernel_rfl bodyDropN53 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s518.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).nnext)) 0 = true
kernel_rfl bodyDv53 : bodyΘ.1.take 288 = bodyΘ.1.take 288 ++ PRE_first_tail_x15_r0_body.cws53
kernel_rfl bodyDe53 : bodyΘ.2.take 288 = bodyΘ.2.take 288 ++ PRE_first_tail_x15_r0_body.nr53.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st53.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 288) (bodyΘ.2.take 288)))
kernel_rfl bodyDl53 : (bodyΘ.1.take 288).length = (bodyΘ.2.take 288).length
kernel_rfl bodyDold53 : (bodyΘ.1.take 288).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws53).isNone && !PRE_first_tail_x15_r0_body.ws53.contains v) = true
kernel_rfl bodyDfree53 : (bodyΘ.2.take 288).all (fun e => (PRE_first_tail_x15_r0_body.cws53 ++ PRE_first_tail_x15_r0_body.ws53).all fun w => e.noVar w) = true

theorem bodyStep53 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21851, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.S517)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21870, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.S519) (206 + 1) :=
  bodySite bodyFacts53.cfix bodyFacts53.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st53.S2.tab) (Es := bodyEs53) (qs := bodyQs53)
    (ok := PRE_first_tail_x15_r0_body.st53.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site53 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts53
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site53 r hr) hi (MapOk.sub hm (sub_of_all bodySub53)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk53 r hr) hi hm ho hq)
    bodyLq53 rfl bodyNrLo53 (postSub_sound bodyPost53)
    (Nat.le_of_ble_eq_true bodyDrop53) (by decide) (Nat.le_of_ble_eq_true bodyDropH53) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN53) (by decide)
    bodyDv53 bodyDe53 bodyDl53 bodyDold53 bodyDfree53 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site54 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site54 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site54) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st54.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site54
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s534 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s535 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S534 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws54 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st54.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st54.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso54
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_54
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st54.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot54
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup54
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound54
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace54
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged54
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws54.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st54.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S534.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_54]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen54.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh54
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl54 : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl54 (PRE_first_tail_x15_r0_body.cncl53 bodyNcl53)

theorem bodyClean54 : Conv.JClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s534 :=
  PRE_first_tail_x15_r0_body.gjcl54 (PRE_first_tail_x15_r0_body.cjcl53 bodyClean53)

kernel_rfl bodyJsLe54 : Nat.ble PRE_first_tail_x15_r0_body.s517.next PRE_first_tail_x15_r0_body.s534.next = true
kernel_rfl bodyJsList54 : (PRE_first_tail_x15_r0_body.gjh54 ++ PRE_first_tail_x15_r0_body.cl54).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s534.next) PRE_first_tail_x15_r0_body.s536) = true
theorem bodyJs54 : JsHeapAbove PRE_first_tail_x15_r0_body.s534.next PRE_first_tail_x15_r0_body.s536 :=
  JsHeapAbove.glueSite bodyJs53 (Nat.le_of_ble_eq_true bodyJsLe54) PRE_first_tail_x15_r0_body.gjk54 PRE_first_tail_x15_r0_body.gjbd54 PRE_first_tail_x15_r0_body.cheap54 PRE_first_tail_x15_r0_body.zclbd54 bodyJsList54

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO519 : PRE_first_tail_x15_r0_body.S519.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S519.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr519 : bridgeOf PRE_first_tail_x15_r0_body.s519.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc519 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.S519) = fun _ _ => true
kernel_rfl bodyAcc521 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s521 PRE_first_tail_x15_r0_body.S521) = fun _ _ => true
kernel_rfl bodyBr522 : bridgeOf PRE_first_tail_x15_r0_body.s522.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt521 : isHalt PRE_first_tail_x15_r0_body.s521.ctl = false
kernel_rfl bodyTop522 : noRetBlock PRE_first_tail_x15_r0_body.s522 = true
kernel_rfl bodyCnt519 : countersOkB PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.s522 = true
kernel_rfl bodyO522 : PRE_first_tail_x15_r0_body.S522.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S522.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr523 : bridgeOf PRE_first_tail_x15_r0_body.s523.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt522 : countersOkB PRE_first_tail_x15_r0_body.s522 PRE_first_tail_x15_r0_body.s523 = true
kernel_rfl bodyO523 : PRE_first_tail_x15_r0_body.S523.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S523.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc523 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s523 PRE_first_tail_x15_r0_body.S523) = fun _ _ => true
kernel_rfl bodyAcc524 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s524 PRE_first_tail_x15_r0_body.S524) = fun _ _ => true
kernel_rfl bodyBr525 : bridgeOf PRE_first_tail_x15_r0_body.s525.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt524 : isHalt PRE_first_tail_x15_r0_body.s524.ctl = false
kernel_rfl bodyTop525 : noRetBlock PRE_first_tail_x15_r0_body.s525 = true
kernel_rfl bodyCnt523 : countersOkB PRE_first_tail_x15_r0_body.s523 PRE_first_tail_x15_r0_body.s525 = true
kernel_rfl bodyO525 : PRE_first_tail_x15_r0_body.S525.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S525.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr526 : bridgeOf PRE_first_tail_x15_r0_body.s526.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt525 : countersOkB PRE_first_tail_x15_r0_body.s525 PRE_first_tail_x15_r0_body.s526 = true
kernel_rfl bodyO526 : PRE_first_tail_x15_r0_body.S526.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S526.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc526 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s526 PRE_first_tail_x15_r0_body.S526) = fun _ _ => true
kernel_rfl bodyAcc527 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s527 PRE_first_tail_x15_r0_body.S527) = fun _ _ => true
kernel_rfl bodyBr528 : bridgeOf PRE_first_tail_x15_r0_body.s528.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt527 : isHalt PRE_first_tail_x15_r0_body.s527.ctl = false
kernel_rfl bodyTop528 : noRetBlock PRE_first_tail_x15_r0_body.s528 = true
kernel_rfl bodyCnt526 : countersOkB PRE_first_tail_x15_r0_body.s526 PRE_first_tail_x15_r0_body.s528 = true
kernel_rfl bodyO528 : PRE_first_tail_x15_r0_body.S528.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S528.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr529 : bridgeOf PRE_first_tail_x15_r0_body.s529.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt528 : countersOkB PRE_first_tail_x15_r0_body.s528 PRE_first_tail_x15_r0_body.s529 = true
kernel_rfl bodyO529 : PRE_first_tail_x15_r0_body.S529.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S529.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc529 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s529 PRE_first_tail_x15_r0_body.S529) = fun _ _ => true
kernel_rfl bodyAcc530 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s530 PRE_first_tail_x15_r0_body.S530) = fun _ _ => true
kernel_rfl bodyBr531 : bridgeOf PRE_first_tail_x15_r0_body.s531.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt530 : isHalt PRE_first_tail_x15_r0_body.s530.ctl = false
kernel_rfl bodyTop531 : noRetBlock PRE_first_tail_x15_r0_body.s531 = true
kernel_rfl bodyCnt529 : countersOkB PRE_first_tail_x15_r0_body.s529 PRE_first_tail_x15_r0_body.s531 = true
kernel_rfl bodyO531 : PRE_first_tail_x15_r0_body.S531.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S531.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr532 : bridgeOf PRE_first_tail_x15_r0_body.s532.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt531 : countersOkB PRE_first_tail_x15_r0_body.s531 PRE_first_tail_x15_r0_body.s532 = true
kernel_rfl bodyO532 : PRE_first_tail_x15_r0_body.S532.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S532.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc532 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s532 PRE_first_tail_x15_r0_body.S532) = fun _ _ => true
kernel_rfl bodyAcc533 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s533 PRE_first_tail_x15_r0_body.S533) = fun _ _ => true
kernel_rfl bodyBr534 : bridgeOf PRE_first_tail_x15_r0_body.s534.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt533 : isHalt PRE_first_tail_x15_r0_body.s533.ctl = false
kernel_rfl bodyTop534 : noRetBlock PRE_first_tail_x15_r0_body.s534 = true
kernel_rfl bodyCnt532 : countersOkB PRE_first_tail_x15_r0_body.s532 PRE_first_tail_x15_r0_body.s534 = true

theorem bodyGlue54 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21870, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.S519)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21870, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.S534) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc519 PRE_first_tail_x15_r0_body.bodyRunSeg140 bodyAcc521 bodyHalt521 PRE_first_tail_x15_r0_body.bodyStepA141 bodyTop522 (fun _ hm => bodyO519 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr519).trans bodyInactive0) (bodyBr522.trans bodyBr519.symm) bodyCnt519 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA141 PRE_first_tail_x15_r0_body.sizeArgsA141 PRE_first_tail_x15_r0_body.sizeSymA141 PRE_first_tail_x15_r0_body.sizeMlxA141 PRE_first_tail_x15_r0_body.sizePayA141 PRE_first_tail_x15_r0_body.sizeTaA141 PRE_first_tail_x15_r0_body.sizeDecA141 PRE_first_tail_x15_r0_body.sizePreA141 PRE_first_tail_x15_r0_body.bodyPatchB141 (fun _ hm => bodyO522 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr522).trans bodyInactive0) (bodyBr523.trans bodyBr522.symm) bodyCnt522 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc523 PRE_first_tail_x15_r0_body.bodyRunSeg141 bodyAcc524 bodyHalt524 PRE_first_tail_x15_r0_body.bodyStepA142 bodyTop525 (fun _ hm => bodyO523 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr523).trans bodyInactive0) (bodyBr525.trans bodyBr523.symm) bodyCnt523 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA142 PRE_first_tail_x15_r0_body.sizeArgsA142 PRE_first_tail_x15_r0_body.sizeSymA142 PRE_first_tail_x15_r0_body.sizeMlxA142 PRE_first_tail_x15_r0_body.sizePayA142 PRE_first_tail_x15_r0_body.sizeTaA142 PRE_first_tail_x15_r0_body.sizeDecA142 PRE_first_tail_x15_r0_body.sizePreA142 PRE_first_tail_x15_r0_body.bodyPatchB142 (fun _ hm => bodyO525 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr525).trans bodyInactive0) (bodyBr526.trans bodyBr525.symm) bodyCnt525 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc526 PRE_first_tail_x15_r0_body.bodyRunSeg142 bodyAcc527 bodyHalt527 PRE_first_tail_x15_r0_body.bodyStepA143 bodyTop528 (fun _ hm => bodyO526 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr526).trans bodyInactive0) (bodyBr528.trans bodyBr526.symm) bodyCnt526 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA143 PRE_first_tail_x15_r0_body.sizeArgsA143 PRE_first_tail_x15_r0_body.sizeSymA143 PRE_first_tail_x15_r0_body.sizeMlxA143 PRE_first_tail_x15_r0_body.sizePayA143 PRE_first_tail_x15_r0_body.sizeTaA143 PRE_first_tail_x15_r0_body.sizeDecA143 PRE_first_tail_x15_r0_body.sizePreA143 PRE_first_tail_x15_r0_body.bodyPatchB143 (fun _ hm => bodyO528 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr528).trans bodyInactive0) (bodyBr529.trans bodyBr528.symm) bodyCnt528 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc529 PRE_first_tail_x15_r0_body.bodyRunSeg143 bodyAcc530 bodyHalt530 PRE_first_tail_x15_r0_body.bodyStepA144 bodyTop531 (fun _ hm => bodyO529 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr529).trans bodyInactive0) (bodyBr531.trans bodyBr529.symm) bodyCnt529 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA144 PRE_first_tail_x15_r0_body.sizeArgsA144 PRE_first_tail_x15_r0_body.sizeSymA144 PRE_first_tail_x15_r0_body.sizeMlxA144 PRE_first_tail_x15_r0_body.sizePayA144 PRE_first_tail_x15_r0_body.sizeTaA144 PRE_first_tail_x15_r0_body.sizeDecA144 PRE_first_tail_x15_r0_body.sizePreA144 PRE_first_tail_x15_r0_body.bodyPatchB144 (fun _ hm => bodyO531 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr531).trans bodyInactive0) (bodyBr532.trans bodyBr531.symm) bodyCnt531 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc532 PRE_first_tail_x15_r0_body.bodyRunSeg144 bodyAcc533 bodyHalt533 PRE_first_tail_x15_r0_body.bodyStepA145 bodyTop534 (fun _ hm => bodyO532 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr532).trans bodyInactive0) (bodyBr534.trans bodyBr532.symm) bodyCnt532 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift54 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S534.tab.length PRE_first_tail_x15_r0_body.s534.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P54.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.s536.ffi PRE_first_tail_x15_r0_body.s535.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_54
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_54
  have hcl : SSt (· < 2411) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S534.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_54] <;> decide) PRE_first_tail_x15_r0_body.cnodesK54 PRE_first_tail_x15_r0_body.cobjsK54
      PRE_first_tail_x15_r0_body.citemsK54 PRE_first_tail_x15_r0_body.cbd54 PRE_first_tail_x15_r0_body.csst54
  exact PRE_first_tail_x15_r0_body.cshift54 bodyNcl54 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_54] at this; exact this)


kernel_rfl bodyFramesEmpty54 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s535 a).isEmpty) = true
kernel_rfl bodyJsRoots54 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s534.next) PRE_first_tail_x15_r0_body.s536.trace PRE_first_tail_x15_r0_body.s536 = true
kernel_rfl bodyJsNative54 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s536.ffi) = true
kernel_rfl bodyLow54 : (PRE_first_tail_x15_r0_body.cws54 ++ PRE_first_tail_x15_r0_body.ws54).all (Nat.ble 9) = true
kernel_rfl bodyCntM54 : countersOkB PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.s535 = true
kernel_rfl bodyHi54 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).next setupP.E = true
kernel_rfl bodyNhi54 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge54 : bridgeOf PRE_first_tail_x15_r0_body.s535.ffi = bridgeOf PRE_first_tail_x15_r0_body.s534.ffi
kernel_rfl bodyNN54 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s534.ffi).nnext PRE_first_tail_x15_r0_body.P54.NL = true
kernel_rfl bodyXn54 : Nat.ble (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).next = true
kernel_rfl bodyLo54 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).next = true
theorem bodyFacts54 : BodySiteFacts PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.s535 PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S534 PRE_first_tail_x15_r0_body.S535 PRE_first_tail_x15_r0_body.S536
    PRE_first_tail_x15_r0_body.ws54 PRE_first_tail_x15_r0_body.cws54 PRE_first_tail_x15_r0_body.nr54 PRE_first_tail_x15_r0_body.pl54 PRE_first_tail_x15_r0_body.cl54 2718798 2411 PRE_first_tail_x15_r0_body.kd54 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.P54
    ⟨19274, 16352, 2717643, 2393⟩ ⟨19277, 16379, 2717649, 2411⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap54
  clean := bodyClean54
  cfix := PRE_first_tail_x15_r0_body.cfix54
  zpl := PRE_first_tail_x15_r0_body.zpl54
  zplnd := PRE_first_tail_x15_r0_body.zplnd54
  zn1 := PRE_first_tail_x15_r0_body.zn154
  zfirst := PRE_first_tail_x15_r0_body.zfirst54
  zscn := PRE_first_tail_x15_r0_body.zscn54
  zsmn := PRE_first_tail_x15_r0_body.zsmn54
  zgrow := PRE_first_tail_x15_r0_body.zgrow54
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab54
  zfresh := PRE_first_tail_x15_r0_body.zfresh54
  zcnd := PRE_first_tail_x15_r0_body.zcnd54
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi54
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt54
  zgP := PRE_first_tail_x15_r0_body.zg54_2665
  zkP := PRE_first_tail_x15_r0_body.zk54_2665
  zmP := PRE_first_tail_x15_r0_body.zm54_2665
  zgC := PRE_first_tail_x15_r0_body.zg54_2673467
  zkC := PRE_first_tail_x15_r0_body.zk54_2673467
  zmC := PRE_first_tail_x15_r0_body.zm54_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw54_2673472
  zwV := PRE_first_tail_x15_r0_body.zw54_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap54
  zclbd := PRE_first_tail_x15_r0_body.zclbd54
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap54 PRE_first_tail_x15_r0_body.stFoot54 PRE_first_tail_x15_r0_body.iso54 PRE_first_tail_x15_r0_body.zwr54
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP54
  csupp := PRE_first_tail_x15_r0_body.csupp54
  cbound := PRE_first_tail_x15_r0_body.cbound54
  zimg := PRE_first_tail_x15_r0_body.zimg54
  zctl := PRE_first_tail_x15_r0_body.zctl54
  zstack := PRE_first_tail_x15_r0_body.zstack54
  zjobs := PRE_first_tail_x15_r0_body.zjobs54
  zstores := PRE_first_tail_x15_r0_body.zstores54
  zroots := PRE_first_tail_x15_r0_body.zroots54
  znC := PRE_first_tail_x15_r0_body.znC54
  ctab := PRE_first_tail_x15_r0_body.ctab54
  zbin := PRE_first_tail_x15_r0_body.zbin54
  cbridge := PRE_first_tail_x15_r0_body.cbridge54
  sbridge := bodyBridge54
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj54
  cshiftR := fun h hNL => bodyCshift54 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN54
  raised := PRE_first_tail_x15_r0_body.raised54
  cbigs := PRE_first_tail_x15_r0_body.cbigs54
  cjcl := PRE_first_tail_x15_r0_body.cjcl54
  xnLe := Nat.le_of_ble_eq_true bodyXn54
  loLe := Nat.le_of_ble_eq_true bodyLo54
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB54
  cntM := bodyCntM54
  hiLe := Nat.le_of_ble_eq_true bodyHi54
  nhiLe := Nat.le_of_ble_eq_true bodyNhi54
  jsHeap := bodyJs54
  jsRoots := bodyJsRoots54
  jsNative := bodyJsNative54
  framesEmpty := bodyFramesEmpty54
  trailOld := by decide
  lowVars := bodyLow54

def bodyQs54 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs54 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr54.map fun r => nth? PRE_first_tail_x15_r0_body.st54.S5.tab r
kernel_rfl bodyResChk54 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs54 bodyQs54) = true
kernel_rfl bodyLq54 : bodyQs54.length = PRE_first_tail_x15_r0_body.cws54.length
kernel_rfl bodyNrLo54 : PRE_first_tail_x15_r0_body.nr54.all (Nat.ble PRE_first_tail_x15_r0_body.S534.tab.length) = true
kernel_rfl bodySub54 : (Oracles.PRE_first_tail_x15_r0_body.map_site54.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost54 : postSubB bodyM PRE_first_tail_x15_r0_body.ws54 PRE_first_tail_x15_r0_body.cws54 bodyQs54 = true
kernel_rfl bodyDrop54 : Nat.ble (21870 + (PRE_first_tail_x15_r0_body.s535.next - PRE_first_tail_x15_r0_body.s536.next)) 23019 = true
kernel_rfl bodyDropH54 : Nat.ble (379 + ((mlxOf PRE_first_tail_x15_r0_body.s535.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).next)) 404 = true
kernel_rfl bodyDropN54 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s535.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).nnext)) 0 = true
kernel_rfl bodyDv54 : bodyΘ.1.take 306 = bodyΘ.1.take 288 ++ PRE_first_tail_x15_r0_body.cws54
kernel_rfl bodyDe54 : bodyΘ.2.take 306 = bodyΘ.2.take 288 ++ PRE_first_tail_x15_r0_body.nr54.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st54.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 288) (bodyΘ.2.take 288)))
kernel_rfl bodyDl54 : (bodyΘ.1.take 288).length = (bodyΘ.2.take 288).length
kernel_rfl bodyDold54 : (bodyΘ.1.take 288).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws54).isNone && !PRE_first_tail_x15_r0_body.ws54.contains v) = true
kernel_rfl bodyDfree54 : (bodyΘ.2.take 306).all (fun e => (PRE_first_tail_x15_r0_body.cws54 ++ PRE_first_tail_x15_r0_body.ws54).all fun w => e.noVar w) = true

theorem bodyStep54 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21870, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.S534)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23019, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.S536) (11334 + 1) :=
  bodySite bodyFacts54.cfix bodyFacts54.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st54.S5.tab) (Es := bodyEs54) (qs := bodyQs54)
    (ok := PRE_first_tail_x15_r0_body.st54.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site54 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts54
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site54 r hr) hi (MapOk.sub hm (sub_of_all bodySub54)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk54 r hr) hi hm ho hq)
    bodyLq54 rfl bodyNrLo54 (postSub_sound bodyPost54)
    (Nat.le_of_ble_eq_true bodyDrop54) (by decide) (Nat.le_of_ble_eq_true bodyDropH54) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN54) (by decide)
    bodyDv54 bodyDe54 bodyDl54 bodyDold54 bodyDfree54 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodySite55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site55 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site55 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site55) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st55.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site55
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s542 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s543 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S542 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws55 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st55.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st55.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso55
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_55
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st55.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot55
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup55
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound55
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace55
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged55
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws55.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st55.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S542.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_55]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen55.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh55
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl55 : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl55 (PRE_first_tail_x15_r0_body.cncl54 bodyNcl54)

theorem bodyClean55 : Conv.JClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s542 :=
  PRE_first_tail_x15_r0_body.gjcl55 (PRE_first_tail_x15_r0_body.cjcl54 bodyClean54)

kernel_rfl bodyJsLe55 : Nat.ble PRE_first_tail_x15_r0_body.s534.next PRE_first_tail_x15_r0_body.s542.next = true
kernel_rfl bodyJsList55 : (PRE_first_tail_x15_r0_body.gjh55 ++ PRE_first_tail_x15_r0_body.cl55).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s542.next) PRE_first_tail_x15_r0_body.s544) = true
theorem bodyJs55 : JsHeapAbove PRE_first_tail_x15_r0_body.s542.next PRE_first_tail_x15_r0_body.s544 :=
  JsHeapAbove.glueSite bodyJs54 (Nat.le_of_ble_eq_true bodyJsLe55) PRE_first_tail_x15_r0_body.gjk55 PRE_first_tail_x15_r0_body.gjbd55 PRE_first_tail_x15_r0_body.cheap55 PRE_first_tail_x15_r0_body.zclbd55 bodyJsList55

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyG55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO536 : PRE_first_tail_x15_r0_body.S536.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S536.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr536 : bridgeOf PRE_first_tail_x15_r0_body.s536.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc536 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.S536) = fun _ _ => true
kernel_rfl bodyAcc537 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s537 PRE_first_tail_x15_r0_body.S537) = fun _ _ => true
kernel_rfl bodyBr538 : bridgeOf PRE_first_tail_x15_r0_body.s538.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt537 : isHalt PRE_first_tail_x15_r0_body.s537.ctl = false
kernel_rfl bodyTop538 : noRetBlock PRE_first_tail_x15_r0_body.s538 = true
kernel_rfl bodyCnt536 : countersOkB PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.s538 = true
kernel_rfl bodyO538 : PRE_first_tail_x15_r0_body.S538.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S538.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr539 : bridgeOf PRE_first_tail_x15_r0_body.s539.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt538 : countersOkB PRE_first_tail_x15_r0_body.s538 PRE_first_tail_x15_r0_body.s539 = true
kernel_rfl bodyO539 : PRE_first_tail_x15_r0_body.S539.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S539.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc539 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s539 PRE_first_tail_x15_r0_body.S539) = fun _ _ => true
kernel_rfl bodyAcc541 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s541 PRE_first_tail_x15_r0_body.S541) = fun _ _ => true
kernel_rfl bodyBr542 : bridgeOf PRE_first_tail_x15_r0_body.s542.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt541 : isHalt PRE_first_tail_x15_r0_body.s541.ctl = false
kernel_rfl bodyTop542 : noRetBlock PRE_first_tail_x15_r0_body.s542 = true
kernel_rfl bodyCnt539 : countersOkB PRE_first_tail_x15_r0_body.s539 PRE_first_tail_x15_r0_body.s542 = true

theorem bodyGlue55 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23019, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.S536)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23019, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.S542) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23019, 404, 0, 306⟩) bodyAcc536 PRE_first_tail_x15_r0_body.bodyRunSeg145 bodyAcc537 bodyHalt537 PRE_first_tail_x15_r0_body.bodyStepA146 bodyTop538 (fun _ hm => bodyO536 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr536).trans bodyInactive0) (bodyBr538.trans bodyBr536.symm) bodyCnt536 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23019, 404, 0, 306⟩) PRE_first_tail_x15_r0_body.sizeA146 PRE_first_tail_x15_r0_body.sizeArgsA146 PRE_first_tail_x15_r0_body.sizeSymA146 PRE_first_tail_x15_r0_body.sizeMlxA146 PRE_first_tail_x15_r0_body.sizePayA146 PRE_first_tail_x15_r0_body.sizeTaA146 PRE_first_tail_x15_r0_body.sizeDecA146 PRE_first_tail_x15_r0_body.sizePreA146 PRE_first_tail_x15_r0_body.bodyPatchB146 (fun _ hm => bodyO538 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr538).trans bodyInactive0) (bodyBr539.trans bodyBr538.symm) bodyCnt538 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23019, 404, 0, 306⟩) bodyAcc539 PRE_first_tail_x15_r0_body.bodyRunSeg146 bodyAcc541 bodyHalt541 PRE_first_tail_x15_r0_body.bodyStepA147 bodyTop542 (fun _ hm => bodyO539 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr539).trans bodyInactive0) (bodyBr542.trans bodyBr539.symm) bodyCnt539 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15

end

section -- VWBodyS55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift55 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S542.tab.length PRE_first_tail_x15_r0_body.s542.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P55.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.s544.ffi PRE_first_tail_x15_r0_body.s543.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_55
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_55
  have hcl : SSt (· < 2432) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S542.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_55] <;> decide) PRE_first_tail_x15_r0_body.cnodesK55 PRE_first_tail_x15_r0_body.cobjsK55
      PRE_first_tail_x15_r0_body.citemsK55 PRE_first_tail_x15_r0_body.cbd55 PRE_first_tail_x15_r0_body.csst55
  exact PRE_first_tail_x15_r0_body.cshift55 bodyNcl55 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_55] at this; exact this)


kernel_rfl bodyFramesEmpty55 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s543 a).isEmpty) = true
kernel_rfl bodyJsRoots55 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s542.next) PRE_first_tail_x15_r0_body.s544.trace PRE_first_tail_x15_r0_body.s544 = true
kernel_rfl bodyJsNative55 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s544.ffi) = true
kernel_rfl bodyLow55 : (PRE_first_tail_x15_r0_body.cws55 ++ PRE_first_tail_x15_r0_body.ws55).all (Nat.ble 9) = true
kernel_rfl bodyCntM55 : countersOkB PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.s543 = true
kernel_rfl bodyHi55 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).next setupP.E = true
kernel_rfl bodyNhi55 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge55 : bridgeOf PRE_first_tail_x15_r0_body.s543.ffi = bridgeOf PRE_first_tail_x15_r0_body.s542.ffi
kernel_rfl bodyNN55 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s542.ffi).nnext PRE_first_tail_x15_r0_body.P55.NL = true
kernel_rfl bodyXn55 : Nat.ble (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).next = true
kernel_rfl bodyLo55 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).next = true
theorem bodyFacts55 : BodySiteFacts PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.s543 PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S542 PRE_first_tail_x15_r0_body.S543 PRE_first_tail_x15_r0_body.S544
    PRE_first_tail_x15_r0_body.ws55 PRE_first_tail_x15_r0_body.cws55 PRE_first_tail_x15_r0_body.nr55 PRE_first_tail_x15_r0_body.pl55 PRE_first_tail_x15_r0_body.cl55 2718141 2432 PRE_first_tail_x15_r0_body.kd55 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.P55
    ⟨19290, 16392, 2718139, 2432⟩ ⟨19290, 16392, 2718139, 2432⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap55
  clean := bodyClean55
  cfix := PRE_first_tail_x15_r0_body.cfix55
  zpl := PRE_first_tail_x15_r0_body.zpl55
  zplnd := PRE_first_tail_x15_r0_body.zplnd55
  zn1 := PRE_first_tail_x15_r0_body.zn155
  zfirst := PRE_first_tail_x15_r0_body.zfirst55
  zscn := PRE_first_tail_x15_r0_body.zscn55
  zsmn := PRE_first_tail_x15_r0_body.zsmn55
  zgrow := PRE_first_tail_x15_r0_body.zgrow55
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab55
  zfresh := PRE_first_tail_x15_r0_body.zfresh55
  zcnd := PRE_first_tail_x15_r0_body.zcnd55
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi55
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt55
  zgP := PRE_first_tail_x15_r0_body.zg55_2665
  zkP := PRE_first_tail_x15_r0_body.zk55_2665
  zmP := PRE_first_tail_x15_r0_body.zm55_2665
  zgC := PRE_first_tail_x15_r0_body.zg55_2673467
  zkC := PRE_first_tail_x15_r0_body.zk55_2673467
  zmC := PRE_first_tail_x15_r0_body.zm55_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw55_2673472
  zwV := PRE_first_tail_x15_r0_body.zw55_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap55
  zclbd := PRE_first_tail_x15_r0_body.zclbd55
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap55 PRE_first_tail_x15_r0_body.stFoot55 PRE_first_tail_x15_r0_body.iso55 PRE_first_tail_x15_r0_body.zwr55
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP55
  csupp := PRE_first_tail_x15_r0_body.csupp55
  cbound := PRE_first_tail_x15_r0_body.cbound55
  zimg := PRE_first_tail_x15_r0_body.zimg55
  zctl := PRE_first_tail_x15_r0_body.zctl55
  zstack := PRE_first_tail_x15_r0_body.zstack55
  zjobs := PRE_first_tail_x15_r0_body.zjobs55
  zstores := PRE_first_tail_x15_r0_body.zstores55
  zroots := PRE_first_tail_x15_r0_body.zroots55
  znC := PRE_first_tail_x15_r0_body.znC55
  ctab := PRE_first_tail_x15_r0_body.ctab55
  zbin := PRE_first_tail_x15_r0_body.zbin55
  cbridge := PRE_first_tail_x15_r0_body.cbridge55
  sbridge := bodyBridge55
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj55
  cshiftR := fun h hNL => bodyCshift55 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN55
  raised := PRE_first_tail_x15_r0_body.raised55
  cbigs := PRE_first_tail_x15_r0_body.cbigs55
  cjcl := PRE_first_tail_x15_r0_body.cjcl55
  xnLe := Nat.le_of_ble_eq_true bodyXn55
  loLe := Nat.le_of_ble_eq_true bodyLo55
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB55
  cntM := bodyCntM55
  hiLe := Nat.le_of_ble_eq_true bodyHi55
  nhiLe := Nat.le_of_ble_eq_true bodyNhi55
  jsHeap := bodyJs55
  jsRoots := bodyJsRoots55
  jsNative := bodyJsNative55
  framesEmpty := bodyFramesEmpty55
  trailOld := by decide
  lowVars := bodyLow55

def bodyQs55 : List (Option Q) := []
noncomputable def bodyEs55 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr55.map fun r => nth? PRE_first_tail_x15_r0_body.st55.S2.tab r
kernel_rfl bodyResChk55 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs55 bodyQs55) = true
kernel_rfl bodyLq55 : bodyQs55.length = PRE_first_tail_x15_r0_body.cws55.length
kernel_rfl bodyNrLo55 : PRE_first_tail_x15_r0_body.nr55.all (Nat.ble PRE_first_tail_x15_r0_body.S542.tab.length) = true
kernel_rfl bodySub55 : (Oracles.PRE_first_tail_x15_r0_body.map_site55.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost55 : postSubB bodyM PRE_first_tail_x15_r0_body.ws55 PRE_first_tail_x15_r0_body.cws55 bodyQs55 = true
kernel_rfl bodyDrop55 : Nat.ble (23019 + (PRE_first_tail_x15_r0_body.s543.next - PRE_first_tail_x15_r0_body.s544.next)) 23021 = true
kernel_rfl bodyDropH55 : Nat.ble (404 + ((mlxOf PRE_first_tail_x15_r0_body.s543.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).next)) 404 = true
kernel_rfl bodyDropN55 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s543.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).nnext)) 0 = true
kernel_rfl bodyDv55 : bodyΘ.1.take 306 = bodyΘ.1.take 306 ++ PRE_first_tail_x15_r0_body.cws55
kernel_rfl bodyDe55 : bodyΘ.2.take 306 = bodyΘ.2.take 306 ++ PRE_first_tail_x15_r0_body.nr55.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st55.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 306) (bodyΘ.2.take 306)))
kernel_rfl bodyDl55 : (bodyΘ.1.take 306).length = (bodyΘ.2.take 306).length
kernel_rfl bodyDold55 : (bodyΘ.1.take 306).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws55).isNone && !PRE_first_tail_x15_r0_body.ws55.contains v) = true
kernel_rfl bodyDfree55 : (bodyΘ.2.take 306).all (fun e => (PRE_first_tail_x15_r0_body.cws55 ++ PRE_first_tail_x15_r0_body.ws55).all fun w => e.noVar w) = true

theorem bodyStep55 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23019, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.S542)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23021, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.S544) (27 + 1) :=
  bodySite bodyFacts55.cfix bodyFacts55.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st55.S2.tab) (Es := bodyEs55) (qs := bodyQs55)
    (ok := PRE_first_tail_x15_r0_body.st55.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site55 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts55
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site55 r hr) hi (MapOk.sub hm (sub_of_all bodySub55)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk55 r hr) hi hm ho hq)
    bodyLq55 rfl bodyNrLo55 (postSub_sound bodyPost55)
    (Nat.le_of_ble_eq_true bodyDrop55) (by decide) (Nat.le_of_ble_eq_true bodyDropH55) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN55) (by decide)
    bodyDv55 bodyDe55 bodyDl55 bodyDold55 bodyDfree55 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15

end
