import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x8_r0_body.States
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B21
import host.sim.compose.a4b.vw8.B6
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B34
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw8.VWBodyChain
import host.sim.compose.a4b.vw8.VWBodyMap
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B14
import host.sim.template.CallGen

section -- VWBodyOracles_14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_g56 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g56 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g56) (List.take 3 (List.drop 545 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site56 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site56 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site56) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g57 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g57 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g57) (List.take 28 (List.drop 548 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site57 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site57 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site57) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st57.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g58 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g58 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g58) (List.take 9 (List.drop 576 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site58 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site58 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site58) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st58.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g59 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g59 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g59) (List.take 3 (List.drop 585 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site59 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site59 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site59) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site56 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site56 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site56) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site56
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s546 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s547 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S546 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws56 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso56
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_56
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot56
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup56
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound56
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace56
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged56
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws56.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st56.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S546.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_56]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen56.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh56
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl56 : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s546.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl56 (PRE_first_tail_x8_r0_body.cncl55 bodyNcl55)

theorem bodyClean56 : Conv.JClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s546 :=
  PRE_first_tail_x8_r0_body.gjcl56 (PRE_first_tail_x8_r0_body.cjcl55 bodyClean55)

kernel_rfl bodyJsLe56 : Nat.ble PRE_first_tail_x8_r0_body.s542.next PRE_first_tail_x8_r0_body.s546.next = true
kernel_rfl bodyJsList56 : (PRE_first_tail_x8_r0_body.gjh56 ++ PRE_first_tail_x8_r0_body.cl56).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s546.next) PRE_first_tail_x8_r0_body.s548) = true
theorem bodyJs56 : JsHeapAbove PRE_first_tail_x8_r0_body.s546.next PRE_first_tail_x8_r0_body.s548 :=
  JsHeapAbove.glueSite bodyJs55 (Nat.le_of_ble_eq_true bodyJsLe56) PRE_first_tail_x8_r0_body.gjk56 PRE_first_tail_x8_r0_body.gjbd56 PRE_first_tail_x8_r0_body.cheap56 PRE_first_tail_x8_r0_body.zclbd56 bodyJsList56

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO544 : PRE_first_tail_x8_r0_body.S544.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S544.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr544 : bridgeOf PRE_first_tail_x8_r0_body.s544.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc544 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s544 PRE_first_tail_x8_r0_body.S544) = fun _ _ => true
kernel_rfl bodyAcc545 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s545 PRE_first_tail_x8_r0_body.S545) = fun _ _ => true
kernel_rfl bodyBr546 : bridgeOf PRE_first_tail_x8_r0_body.s546.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt545 : isHalt PRE_first_tail_x8_r0_body.s545.ctl = false
kernel_rfl bodyTop546 : noRetBlock PRE_first_tail_x8_r0_body.s546 = true
kernel_rfl bodyCnt544 : countersOkB PRE_first_tail_x8_r0_body.s544 PRE_first_tail_x8_r0_body.s546 = true

theorem bodyGlue56 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23027, 404, 0, 306⟩ bodyM PRE_first_tail_x8_r0_body.s544 PRE_first_tail_x8_r0_body.S544)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23027, 404, 0, 306⟩ bodyM PRE_first_tail_x8_r0_body.s546 PRE_first_tail_x8_r0_body.S546) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23027, 404, 0, 306⟩) bodyAcc544 PRE_first_tail_x8_r0_body.bodyRunSeg147 bodyAcc545 bodyHalt545 PRE_first_tail_x8_r0_body.bodyStepA148 bodyTop546 (fun _ hm => bodyO544 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr544).trans bodyInactive0) (bodyBr546.trans bodyBr544.symm) bodyCnt544 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift56 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S546.tab.length PRE_first_tail_x8_r0_body.s546.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P56.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P56 2449 PRE_first_tail_x8_r0_body.kappa56 PRE_first_tail_x8_r0_body.s548.ffi PRE_first_tail_x8_r0_body.s547.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_56
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_56
  have hcl : SSt (· < 2449) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s548.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S546.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_56] <;> decide) PRE_first_tail_x8_r0_body.cnodesK56 PRE_first_tail_x8_r0_body.cobjsK56
      PRE_first_tail_x8_r0_body.citemsK56 PRE_first_tail_x8_r0_body.cbd56 PRE_first_tail_x8_r0_body.csst56
  exact PRE_first_tail_x8_r0_body.cshift56 bodyNcl56 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_56] at this; exact this)


kernel_rfl bodyFramesEmpty56 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s547 a).isEmpty) = true
kernel_rfl bodyJsRoots56 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s546.next) PRE_first_tail_x8_r0_body.s548.trace PRE_first_tail_x8_r0_body.s548 = true
kernel_rfl bodyJsNative56 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s548.ffi) = true
kernel_rfl bodyLow56 : (PRE_first_tail_x8_r0_body.cws56 ++ PRE_first_tail_x8_r0_body.ws56).all (Nat.ble 9) = true
kernel_rfl bodyCntM56 : countersOkB PRE_first_tail_x8_r0_body.s546 PRE_first_tail_x8_r0_body.s547 = true
kernel_rfl bodyHi56 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s548.ffi).next setupP.E = true
kernel_rfl bodyNhi56 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s548.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge56 : bridgeOf PRE_first_tail_x8_r0_body.s547.ffi = bridgeOf PRE_first_tail_x8_r0_body.s546.ffi
kernel_rfl bodyNN56 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s546.ffi).nnext PRE_first_tail_x8_r0_body.P56.NL = true
kernel_rfl bodyXn56 : Nat.ble (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s548.ffi).next = true
kernel_rfl bodyLo56 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s548.ffi).next = true
theorem bodyFacts56 : BodySiteFacts PRE_first_tail_x8_r0_body.s546 PRE_first_tail_x8_r0_body.s547 PRE_first_tail_x8_r0_body.s548 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S546 PRE_first_tail_x8_r0_body.S547 PRE_first_tail_x8_r0_body.S548
    PRE_first_tail_x8_r0_body.ws56 PRE_first_tail_x8_r0_body.cws56 PRE_first_tail_x8_r0_body.nr56 PRE_first_tail_x8_r0_body.pl56 PRE_first_tail_x8_r0_body.cl56 2718448 2449 PRE_first_tail_x8_r0_body.kd56 PRE_first_tail_x8_r0_body.kappa56 PRE_first_tail_x8_r0_body.P56
    ⟨19297, 16396, 2718427, 2449⟩ ⟨19297, 16396, 2718428, 2449⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap56
  clean := bodyClean56
  cfix := PRE_first_tail_x8_r0_body.cfix56
  zpl := PRE_first_tail_x8_r0_body.zpl56
  zplnd := PRE_first_tail_x8_r0_body.zplnd56
  zn1 := PRE_first_tail_x8_r0_body.zn156
  zfirst := PRE_first_tail_x8_r0_body.zfirst56
  zscn := PRE_first_tail_x8_r0_body.zscn56
  zsmn := PRE_first_tail_x8_r0_body.zsmn56
  zgrow := PRE_first_tail_x8_r0_body.zgrow56
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab56
  zfresh := PRE_first_tail_x8_r0_body.zfresh56
  zcnd := PRE_first_tail_x8_r0_body.zcnd56
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi56
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt56
  zgP := PRE_first_tail_x8_r0_body.zg56_2665
  zkP := PRE_first_tail_x8_r0_body.zk56_2665
  zmP := PRE_first_tail_x8_r0_body.zm56_2665
  zgC := PRE_first_tail_x8_r0_body.zg56_2673467
  zkC := PRE_first_tail_x8_r0_body.zk56_2673467
  zmC := PRE_first_tail_x8_r0_body.zm56_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw56_2673472
  zwV := PRE_first_tail_x8_r0_body.zw56_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap56
  zclbd := PRE_first_tail_x8_r0_body.zclbd56
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap56 PRE_first_tail_x8_r0_body.stFoot56 PRE_first_tail_x8_r0_body.iso56 PRE_first_tail_x8_r0_body.zwr56
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP56
  csupp := PRE_first_tail_x8_r0_body.csupp56
  cbound := PRE_first_tail_x8_r0_body.cbound56
  zimg := PRE_first_tail_x8_r0_body.zimg56
  zctl := PRE_first_tail_x8_r0_body.zctl56
  zstack := PRE_first_tail_x8_r0_body.zstack56
  zjobs := PRE_first_tail_x8_r0_body.zjobs56
  zstores := PRE_first_tail_x8_r0_body.zstores56
  zroots := PRE_first_tail_x8_r0_body.zroots56
  znC := PRE_first_tail_x8_r0_body.znC56
  ctab := PRE_first_tail_x8_r0_body.ctab56
  zbin := PRE_first_tail_x8_r0_body.zbin56
  cbridge := PRE_first_tail_x8_r0_body.cbridge56
  sbridge := bodyBridge56
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj56
  cshiftR := fun h hNL => bodyCshift56 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN56
  raised := PRE_first_tail_x8_r0_body.raised56
  cbigs := PRE_first_tail_x8_r0_body.cbigs56
  cjcl := PRE_first_tail_x8_r0_body.cjcl56
  xnLe := Nat.le_of_ble_eq_true bodyXn56
  loLe := Nat.le_of_ble_eq_true bodyLo56
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB56
  cntM := bodyCntM56
  hiLe := Nat.le_of_ble_eq_true bodyHi56
  nhiLe := Nat.le_of_ble_eq_true bodyNhi56
  jsHeap := bodyJs56
  jsRoots := bodyJsRoots56
  jsNative := bodyJsNative56
  framesEmpty := bodyFramesEmpty56
  trailOld := by decide
  lowVars := bodyLow56

def bodyQs56 : List (Option Q) := []
noncomputable def bodyEs56 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr56.map fun r => nth? PRE_first_tail_x8_r0_body.st56.S2.tab r
kernel_rfl bodyResChk56 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs56 bodyQs56) = true
kernel_rfl bodyLq56 : bodyQs56.length = PRE_first_tail_x8_r0_body.cws56.length
kernel_rfl bodyNrLo56 : PRE_first_tail_x8_r0_body.nr56.all (Nat.ble PRE_first_tail_x8_r0_body.S546.tab.length) = true
kernel_rfl bodySub56 : (Oracles.PRE_first_tail_x8_r0_body.map_site56.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost56 : postSubB bodyM PRE_first_tail_x8_r0_body.ws56 PRE_first_tail_x8_r0_body.cws56 bodyQs56 = true
kernel_rfl bodyDrop56 : Nat.ble (23027 + (PRE_first_tail_x8_r0_body.s547.next - PRE_first_tail_x8_r0_body.s548.next)) 23047 = true
kernel_rfl bodyDropH56 : Nat.ble (404 + ((mlxOf PRE_first_tail_x8_r0_body.s547.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s548.ffi).next)) 404 = true
kernel_rfl bodyDropN56 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s547.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s548.ffi).nnext)) 0 = true
kernel_rfl bodyDv56 : bodyΘ.1.take 306 = bodyΘ.1.take 306 ++ PRE_first_tail_x8_r0_body.cws56
kernel_rfl bodyDe56 : bodyΘ.2.take 306 = bodyΘ.2.take 306 ++ PRE_first_tail_x8_r0_body.nr56.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st56.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 306) (bodyΘ.2.take 306)))
kernel_rfl bodyDl56 : (bodyΘ.1.take 306).length = (bodyΘ.2.take 306).length
kernel_rfl bodyDold56 : (bodyΘ.1.take 306).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws56).isNone && !PRE_first_tail_x8_r0_body.ws56.contains v) = true
kernel_rfl bodyDfree56 : (bodyΘ.2.take 306).all (fun e => (PRE_first_tail_x8_r0_body.cws56 ++ PRE_first_tail_x8_r0_body.ws56).all fun w => e.noVar w) = true

theorem bodyStep56 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23027, 404, 0, 306⟩ bodyM PRE_first_tail_x8_r0_body.s546 PRE_first_tail_x8_r0_body.S546)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23047, 404, 0, 306⟩ bodyM PRE_first_tail_x8_r0_body.s548 PRE_first_tail_x8_r0_body.S548) (214 + 1) :=
  bodySite bodyFacts56.cfix bodyFacts56.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 214) (S2 := PRE_first_tail_x8_r0_body.st56.S2.tab) (Es := bodyEs56) (qs := bodyQs56)
    (ok := PRE_first_tail_x8_r0_body.st56.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site56 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts56
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site56 r hr) hi (MapOk.sub hm (sub_of_all bodySub56)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk56 r hr) hi hm ho hq)
    bodyLq56 rfl bodyNrLo56 (postSub_sound bodyPost56)
    (Nat.le_of_ble_eq_true bodyDrop56) (by decide) (Nat.le_of_ble_eq_true bodyDropH56) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN56) (by decide)
    bodyDv56 bodyDe56 bodyDl56 bodyDold56 bodyDfree56 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site57 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site57 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site57) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st57.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site57
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st57.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st57.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s562 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s563 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S562 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws57 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st57.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st57.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso57
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_57
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st57.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot57
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup57
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound57
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace57
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged57
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws57.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st57.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S562.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_57]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen57.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh57
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl57 : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s562.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl57 (PRE_first_tail_x8_r0_body.cncl56 bodyNcl56)

theorem bodyClean57 : Conv.JClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s562 :=
  PRE_first_tail_x8_r0_body.gjcl57 (PRE_first_tail_x8_r0_body.cjcl56 bodyClean56)

kernel_rfl bodyJsLe57 : Nat.ble PRE_first_tail_x8_r0_body.s546.next PRE_first_tail_x8_r0_body.s562.next = true
kernel_rfl bodyJsList57 : (PRE_first_tail_x8_r0_body.gjh57 ++ PRE_first_tail_x8_r0_body.cl57).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s562.next) PRE_first_tail_x8_r0_body.s564) = true
theorem bodyJs57 : JsHeapAbove PRE_first_tail_x8_r0_body.s562.next PRE_first_tail_x8_r0_body.s564 :=
  JsHeapAbove.glueSite bodyJs56 (Nat.le_of_ble_eq_true bodyJsLe57) PRE_first_tail_x8_r0_body.gjk57 PRE_first_tail_x8_r0_body.gjbd57 PRE_first_tail_x8_r0_body.cheap57 PRE_first_tail_x8_r0_body.zclbd57 bodyJsList57

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO548 : PRE_first_tail_x8_r0_body.S548.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S548.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr548 : bridgeOf PRE_first_tail_x8_r0_body.s548.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc548 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s548 PRE_first_tail_x8_r0_body.S548) = fun _ _ => true
kernel_rfl bodyAcc550 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s550 PRE_first_tail_x8_r0_body.S550) = fun _ _ => true
kernel_rfl bodyBr551 : bridgeOf PRE_first_tail_x8_r0_body.s551.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt550 : isHalt PRE_first_tail_x8_r0_body.s550.ctl = false
kernel_rfl bodyTop551 : noRetBlock PRE_first_tail_x8_r0_body.s551 = true
kernel_rfl bodyCnt548 : countersOkB PRE_first_tail_x8_r0_body.s548 PRE_first_tail_x8_r0_body.s551 = true
kernel_rfl bodyO551 : PRE_first_tail_x8_r0_body.S551.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S551.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr552 : bridgeOf PRE_first_tail_x8_r0_body.s552.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt551 : countersOkB PRE_first_tail_x8_r0_body.s551 PRE_first_tail_x8_r0_body.s552 = true
kernel_rfl bodyO552 : PRE_first_tail_x8_r0_body.S552.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S552.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc552 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s552 PRE_first_tail_x8_r0_body.S552) = fun _ _ => true
kernel_rfl bodyAcc554 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s554 PRE_first_tail_x8_r0_body.S554) = fun _ _ => true
kernel_rfl bodyBr555 : bridgeOf PRE_first_tail_x8_r0_body.s555.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt554 : isHalt PRE_first_tail_x8_r0_body.s554.ctl = false
kernel_rfl bodyTop555 : noRetBlock PRE_first_tail_x8_r0_body.s555 = true
kernel_rfl bodyCnt552 : countersOkB PRE_first_tail_x8_r0_body.s552 PRE_first_tail_x8_r0_body.s555 = true
kernel_rfl bodyO555 : PRE_first_tail_x8_r0_body.S555.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S555.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr556 : bridgeOf PRE_first_tail_x8_r0_body.s556.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt555 : countersOkB PRE_first_tail_x8_r0_body.s555 PRE_first_tail_x8_r0_body.s556 = true
kernel_rfl bodyO556 : PRE_first_tail_x8_r0_body.S556.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S556.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc556 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s556 PRE_first_tail_x8_r0_body.S556) = fun _ _ => true
kernel_rfl bodyAcc557 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s557 PRE_first_tail_x8_r0_body.S557) = fun _ _ => true
kernel_rfl bodyBr558 : bridgeOf PRE_first_tail_x8_r0_body.s558.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt557 : isHalt PRE_first_tail_x8_r0_body.s557.ctl = false
kernel_rfl bodyTop558 : noRetBlock PRE_first_tail_x8_r0_body.s558 = true
kernel_rfl bodyCnt556 : countersOkB PRE_first_tail_x8_r0_body.s556 PRE_first_tail_x8_r0_body.s558 = true
kernel_rfl bodyO558 : PRE_first_tail_x8_r0_body.S558.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S558.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr559 : bridgeOf PRE_first_tail_x8_r0_body.s559.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt558 : countersOkB PRE_first_tail_x8_r0_body.s558 PRE_first_tail_x8_r0_body.s559 = true
kernel_rfl bodyO559 : PRE_first_tail_x8_r0_body.S559.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S559.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc559 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s559 PRE_first_tail_x8_r0_body.S559) = fun _ _ => true
kernel_rfl bodyAcc561 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s561 PRE_first_tail_x8_r0_body.S561) = fun _ _ => true
kernel_rfl bodyBr562 : bridgeOf PRE_first_tail_x8_r0_body.s562.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt561 : isHalt PRE_first_tail_x8_r0_body.s561.ctl = false
kernel_rfl bodyTop562 : noRetBlock PRE_first_tail_x8_r0_body.s562 = true
kernel_rfl bodyCnt559 : countersOkB PRE_first_tail_x8_r0_body.s559 PRE_first_tail_x8_r0_body.s562 = true

theorem bodyGlue57 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23047, 404, 0, 306⟩ bodyM PRE_first_tail_x8_r0_body.s548 PRE_first_tail_x8_r0_body.S548)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23047, 404, 0, 306⟩ bodyM PRE_first_tail_x8_r0_body.s562 PRE_first_tail_x8_r0_body.S562) 17025 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23047, 404, 0, 306⟩) bodyAcc548 PRE_first_tail_x8_r0_body.bodyRunSeg148 bodyAcc550 bodyHalt550 PRE_first_tail_x8_r0_body.bodyStepA149 bodyTop551 (fun _ hm => bodyO548 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr548).trans bodyInactive0) (bodyBr551.trans bodyBr548.symm) bodyCnt548 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23047, 404, 0, 306⟩) PRE_first_tail_x8_r0_body.sizeA149 PRE_first_tail_x8_r0_body.sizeArgsA149 PRE_first_tail_x8_r0_body.sizeSymA149 PRE_first_tail_x8_r0_body.sizeMlxA149 PRE_first_tail_x8_r0_body.sizePayA149 PRE_first_tail_x8_r0_body.sizeTaA149 PRE_first_tail_x8_r0_body.sizeDecA149 PRE_first_tail_x8_r0_body.sizePreA149 PRE_first_tail_x8_r0_body.bodyPatchB149 (fun _ hm => bodyO551 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr551).trans bodyInactive0) (bodyBr552.trans bodyBr551.symm) bodyCnt551 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23047, 404, 0, 306⟩) bodyAcc552 PRE_first_tail_x8_r0_body.bodyRunSeg149 bodyAcc554 bodyHalt554 PRE_first_tail_x8_r0_body.bodyStepA150 bodyTop555 (fun _ hm => bodyO552 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr552).trans bodyInactive0) (bodyBr555.trans bodyBr552.symm) bodyCnt552 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23047, 404, 0, 306⟩) PRE_first_tail_x8_r0_body.sizeA150 PRE_first_tail_x8_r0_body.sizeArgsA150 PRE_first_tail_x8_r0_body.sizeSymA150 PRE_first_tail_x8_r0_body.sizeMlxA150 PRE_first_tail_x8_r0_body.sizePayA150 PRE_first_tail_x8_r0_body.sizeTaA150 PRE_first_tail_x8_r0_body.sizeDecA150 PRE_first_tail_x8_r0_body.sizePreA150 PRE_first_tail_x8_r0_body.bodyPatchB150 (fun _ hm => bodyO555 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr555).trans bodyInactive0) (bodyBr556.trans bodyBr555.symm) bodyCnt555 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23047, 404, 0, 306⟩) bodyAcc556 PRE_first_tail_x8_r0_body.bodyRunSeg150 bodyAcc557 bodyHalt557 PRE_first_tail_x8_r0_body.bodyStepA151 bodyTop558 (fun _ hm => bodyO556 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr556).trans bodyInactive0) (bodyBr558.trans bodyBr556.symm) bodyCnt556 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23047, 404, 0, 306⟩) PRE_first_tail_x8_r0_body.sizeA151 PRE_first_tail_x8_r0_body.sizeArgsA151 PRE_first_tail_x8_r0_body.sizeSymA151 PRE_first_tail_x8_r0_body.sizeMlxA151 PRE_first_tail_x8_r0_body.sizePayA151 PRE_first_tail_x8_r0_body.sizeTaA151 PRE_first_tail_x8_r0_body.sizeDecA151 PRE_first_tail_x8_r0_body.sizePreA151 PRE_first_tail_x8_r0_body.bodyPatchB151 (fun _ hm => bodyO558 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr558).trans bodyInactive0) (bodyBr559.trans bodyBr558.symm) bodyCnt558 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23047, 404, 0, 306⟩) bodyAcc559 PRE_first_tail_x8_r0_body.bodyRunSeg151 bodyAcc561 bodyHalt561 PRE_first_tail_x8_r0_body.bodyStepA152 bodyTop562 (fun _ hm => bodyO559 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr559).trans bodyInactive0) (bodyBr562.trans bodyBr559.symm) bodyCnt559 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift57 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S562.tab.length PRE_first_tail_x8_r0_body.s562.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P57.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P57 2535 PRE_first_tail_x8_r0_body.kappa57 PRE_first_tail_x8_r0_body.s564.ffi PRE_first_tail_x8_r0_body.s563.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_57
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_57
  have hcl : SSt (· < 2535) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s564.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S562.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_57] <;> decide) PRE_first_tail_x8_r0_body.cnodesK57 PRE_first_tail_x8_r0_body.cobjsK57
      PRE_first_tail_x8_r0_body.citemsK57 PRE_first_tail_x8_r0_body.cbd57 PRE_first_tail_x8_r0_body.csst57
  exact PRE_first_tail_x8_r0_body.cshift57 bodyNcl57 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_57] at this; exact this)


kernel_rfl bodyFramesEmpty57 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s563 a).isEmpty) = true
kernel_rfl bodyJsRoots57 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s562.next) PRE_first_tail_x8_r0_body.s564.trace PRE_first_tail_x8_r0_body.s564 = true
kernel_rfl bodyJsNative57 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s564.ffi) = true
kernel_rfl bodyLow57 : (PRE_first_tail_x8_r0_body.cws57 ++ PRE_first_tail_x8_r0_body.ws57).all (Nat.ble 9) = true
kernel_rfl bodyCntM57 : countersOkB PRE_first_tail_x8_r0_body.s562 PRE_first_tail_x8_r0_body.s563 = true
kernel_rfl bodyHi57 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s564.ffi).next setupP.E = true
kernel_rfl bodyNhi57 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s564.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge57 : bridgeOf PRE_first_tail_x8_r0_body.s563.ffi = bridgeOf PRE_first_tail_x8_r0_body.s562.ffi
kernel_rfl bodyNN57 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s562.ffi).nnext PRE_first_tail_x8_r0_body.P57.NL = true
kernel_rfl bodyXn57 : Nat.ble (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s564.ffi).next = true
kernel_rfl bodyLo57 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s564.ffi).next = true
theorem bodyFacts57 : BodySiteFacts PRE_first_tail_x8_r0_body.s562 PRE_first_tail_x8_r0_body.s563 PRE_first_tail_x8_r0_body.s564 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S562 PRE_first_tail_x8_r0_body.S563 PRE_first_tail_x8_r0_body.S564
    PRE_first_tail_x8_r0_body.ws57 PRE_first_tail_x8_r0_body.cws57 PRE_first_tail_x8_r0_body.nr57 PRE_first_tail_x8_r0_body.pl57 PRE_first_tail_x8_r0_body.cl57 2720533 2535 PRE_first_tail_x8_r0_body.kd57 PRE_first_tail_x8_r0_body.kappa57 PRE_first_tail_x8_r0_body.P57
    ⟨19337, 16424, 2720168, 2526⟩ ⟨19341, 16430, 2720183, 2535⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap57
  clean := bodyClean57
  cfix := PRE_first_tail_x8_r0_body.cfix57
  zpl := PRE_first_tail_x8_r0_body.zpl57
  zplnd := PRE_first_tail_x8_r0_body.zplnd57
  zn1 := PRE_first_tail_x8_r0_body.zn157
  zfirst := PRE_first_tail_x8_r0_body.zfirst57
  zscn := PRE_first_tail_x8_r0_body.zscn57
  zsmn := PRE_first_tail_x8_r0_body.zsmn57
  zgrow := PRE_first_tail_x8_r0_body.zgrow57
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab57
  zfresh := PRE_first_tail_x8_r0_body.zfresh57
  zcnd := PRE_first_tail_x8_r0_body.zcnd57
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi57
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt57
  zgP := PRE_first_tail_x8_r0_body.zg57_2665
  zkP := PRE_first_tail_x8_r0_body.zk57_2665
  zmP := PRE_first_tail_x8_r0_body.zm57_2665
  zgC := PRE_first_tail_x8_r0_body.zg57_2673467
  zkC := PRE_first_tail_x8_r0_body.zk57_2673467
  zmC := PRE_first_tail_x8_r0_body.zm57_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw57_2673472
  zwV := PRE_first_tail_x8_r0_body.zw57_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap57
  zclbd := PRE_first_tail_x8_r0_body.zclbd57
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap57 PRE_first_tail_x8_r0_body.stFoot57 PRE_first_tail_x8_r0_body.iso57 PRE_first_tail_x8_r0_body.zwr57
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP57
  csupp := PRE_first_tail_x8_r0_body.csupp57
  cbound := PRE_first_tail_x8_r0_body.cbound57
  zimg := PRE_first_tail_x8_r0_body.zimg57
  zctl := PRE_first_tail_x8_r0_body.zctl57
  zstack := PRE_first_tail_x8_r0_body.zstack57
  zjobs := PRE_first_tail_x8_r0_body.zjobs57
  zstores := PRE_first_tail_x8_r0_body.zstores57
  zroots := PRE_first_tail_x8_r0_body.zroots57
  znC := PRE_first_tail_x8_r0_body.znC57
  ctab := PRE_first_tail_x8_r0_body.ctab57
  zbin := PRE_first_tail_x8_r0_body.zbin57
  cbridge := PRE_first_tail_x8_r0_body.cbridge57
  sbridge := bodyBridge57
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj57
  cshiftR := fun h hNL => bodyCshift57 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN57
  raised := PRE_first_tail_x8_r0_body.raised57
  cbigs := PRE_first_tail_x8_r0_body.cbigs57
  cjcl := PRE_first_tail_x8_r0_body.cjcl57
  xnLe := Nat.le_of_ble_eq_true bodyXn57
  loLe := Nat.le_of_ble_eq_true bodyLo57
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB57
  cntM := bodyCntM57
  hiLe := Nat.le_of_ble_eq_true bodyHi57
  nhiLe := Nat.le_of_ble_eq_true bodyNhi57
  jsHeap := bodyJs57
  jsRoots := bodyJsRoots57
  jsNative := bodyJsNative57
  framesEmpty := bodyFramesEmpty57
  trailOld := by decide
  lowVars := bodyLow57

def bodyQs57 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs57 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr57.map fun r => nth? PRE_first_tail_x8_r0_body.st57.S3.tab r
kernel_rfl bodyResChk57 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs57 bodyQs57) = true
kernel_rfl bodyLq57 : bodyQs57.length = PRE_first_tail_x8_r0_body.cws57.length
kernel_rfl bodyNrLo57 : PRE_first_tail_x8_r0_body.nr57.all (Nat.ble PRE_first_tail_x8_r0_body.S562.tab.length) = true
kernel_rfl bodySub57 : (Oracles.PRE_first_tail_x8_r0_body.map_site57.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost57 : postSubB bodyM PRE_first_tail_x8_r0_body.ws57 PRE_first_tail_x8_r0_body.cws57 bodyQs57 = true
kernel_rfl bodyDrop57 : Nat.ble (23047 + (PRE_first_tail_x8_r0_body.s563.next - PRE_first_tail_x8_r0_body.s564.next)) 23397 = true
kernel_rfl bodyDropH57 : Nat.ble (404 + ((mlxOf PRE_first_tail_x8_r0_body.s563.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s564.ffi).next)) 406 = true
kernel_rfl bodyDropN57 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s563.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s564.ffi).nnext)) 0 = true
kernel_rfl bodyDv57 : bodyΘ.1.take 315 = bodyΘ.1.take 306 ++ PRE_first_tail_x8_r0_body.cws57
kernel_rfl bodyDe57 : bodyΘ.2.take 315 = bodyΘ.2.take 306 ++ PRE_first_tail_x8_r0_body.nr57.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st57.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 306) (bodyΘ.2.take 306)))
kernel_rfl bodyDl57 : (bodyΘ.1.take 306).length = (bodyΘ.2.take 306).length
kernel_rfl bodyDold57 : (bodyΘ.1.take 306).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws57).isNone && !PRE_first_tail_x8_r0_body.ws57.contains v) = true
kernel_rfl bodyDfree57 : (bodyΘ.2.take 315).all (fun e => (PRE_first_tail_x8_r0_body.cws57 ++ PRE_first_tail_x8_r0_body.ws57).all fun w => e.noVar w) = true

theorem bodyStep57 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23047, 404, 0, 306⟩ bodyM PRE_first_tail_x8_r0_body.s562 PRE_first_tail_x8_r0_body.S562)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23397, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s564 PRE_first_tail_x8_r0_body.S564) (3452 + 1) :=
  bodySite bodyFacts57.cfix bodyFacts57.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x8_r0_body.st57.S3.tab) (Es := bodyEs57) (qs := bodyQs57)
    (ok := PRE_first_tail_x8_r0_body.st57.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site57 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts57
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site57 r hr) hi (MapOk.sub hm (sub_of_all bodySub57)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk57 r hr) hi hm ho hq)
    bodyLq57 rfl bodyNrLo57 (postSub_sound bodyPost57)
    (Nat.le_of_ble_eq_true bodyDrop57) (by decide) (Nat.le_of_ble_eq_true bodyDropH57) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN57) (by decide)
    bodyDv57 bodyDe57 bodyDl57 bodyDold57 bodyDfree57 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site58 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site58 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site58) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st58.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site58
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st58.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st58.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s570 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s571 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S570 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws58 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st58.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st58.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso58
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_58
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st58.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot58
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup58
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound58
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace58
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged58
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws58.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st58.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S570.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_58]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen58.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh58
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl58 : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s570.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl58 (PRE_first_tail_x8_r0_body.cncl57 bodyNcl57)

theorem bodyClean58 : Conv.JClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s570 :=
  PRE_first_tail_x8_r0_body.gjcl58 (PRE_first_tail_x8_r0_body.cjcl57 bodyClean57)

kernel_rfl bodyJsLe58 : Nat.ble PRE_first_tail_x8_r0_body.s562.next PRE_first_tail_x8_r0_body.s570.next = true
kernel_rfl bodyJsList58 : (PRE_first_tail_x8_r0_body.gjh58 ++ PRE_first_tail_x8_r0_body.cl58).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s570.next) PRE_first_tail_x8_r0_body.s572) = true
theorem bodyJs58 : JsHeapAbove PRE_first_tail_x8_r0_body.s570.next PRE_first_tail_x8_r0_body.s572 :=
  JsHeapAbove.glueSite bodyJs57 (Nat.le_of_ble_eq_true bodyJsLe58) PRE_first_tail_x8_r0_body.gjk58 PRE_first_tail_x8_r0_body.gjbd58 PRE_first_tail_x8_r0_body.cheap58 PRE_first_tail_x8_r0_body.zclbd58 bodyJsList58

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO564 : PRE_first_tail_x8_r0_body.S564.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S564.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr564 : bridgeOf PRE_first_tail_x8_r0_body.s564.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc564 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s564 PRE_first_tail_x8_r0_body.S564) = fun _ _ => true
kernel_rfl bodyAcc565 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s565 PRE_first_tail_x8_r0_body.S565) = fun _ _ => true
kernel_rfl bodyBr566 : bridgeOf PRE_first_tail_x8_r0_body.s566.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt565 : isHalt PRE_first_tail_x8_r0_body.s565.ctl = false
kernel_rfl bodyTop566 : noRetBlock PRE_first_tail_x8_r0_body.s566 = true
kernel_rfl bodyCnt564 : countersOkB PRE_first_tail_x8_r0_body.s564 PRE_first_tail_x8_r0_body.s566 = true
kernel_rfl bodyO566 : PRE_first_tail_x8_r0_body.S566.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S566.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr567 : bridgeOf PRE_first_tail_x8_r0_body.s567.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt566 : countersOkB PRE_first_tail_x8_r0_body.s566 PRE_first_tail_x8_r0_body.s567 = true
kernel_rfl bodyO567 : PRE_first_tail_x8_r0_body.S567.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S567.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc567 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s567 PRE_first_tail_x8_r0_body.S567) = fun _ _ => true
kernel_rfl bodyAcc569 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s569 PRE_first_tail_x8_r0_body.S569) = fun _ _ => true
kernel_rfl bodyBr570 : bridgeOf PRE_first_tail_x8_r0_body.s570.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt569 : isHalt PRE_first_tail_x8_r0_body.s569.ctl = false
kernel_rfl bodyTop570 : noRetBlock PRE_first_tail_x8_r0_body.s570 = true
kernel_rfl bodyCnt567 : countersOkB PRE_first_tail_x8_r0_body.s567 PRE_first_tail_x8_r0_body.s570 = true

theorem bodyGlue58 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23397, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s564 PRE_first_tail_x8_r0_body.S564)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23397, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s570 PRE_first_tail_x8_r0_body.S570) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23397, 406, 0, 315⟩) bodyAcc564 PRE_first_tail_x8_r0_body.bodyRunSeg152 bodyAcc565 bodyHalt565 PRE_first_tail_x8_r0_body.bodyStepA153 bodyTop566 (fun _ hm => bodyO564 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr564).trans bodyInactive0) (bodyBr566.trans bodyBr564.symm) bodyCnt564 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23397, 406, 0, 315⟩) PRE_first_tail_x8_r0_body.sizeA153 PRE_first_tail_x8_r0_body.sizeArgsA153 PRE_first_tail_x8_r0_body.sizeSymA153 PRE_first_tail_x8_r0_body.sizeMlxA153 PRE_first_tail_x8_r0_body.sizePayA153 PRE_first_tail_x8_r0_body.sizeTaA153 PRE_first_tail_x8_r0_body.sizeDecA153 PRE_first_tail_x8_r0_body.sizePreA153 PRE_first_tail_x8_r0_body.bodyPatchB153 (fun _ hm => bodyO566 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr566).trans bodyInactive0) (bodyBr567.trans bodyBr566.symm) bodyCnt566 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23397, 406, 0, 315⟩) bodyAcc567 PRE_first_tail_x8_r0_body.bodyRunSeg153 bodyAcc569 bodyHalt569 PRE_first_tail_x8_r0_body.bodyStepA154 bodyTop570 (fun _ hm => bodyO567 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr567).trans bodyInactive0) (bodyBr570.trans bodyBr567.symm) bodyCnt567 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift58 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S570.tab.length PRE_first_tail_x8_r0_body.s570.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P58.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P58 2558 PRE_first_tail_x8_r0_body.kappa58 PRE_first_tail_x8_r0_body.s572.ffi PRE_first_tail_x8_r0_body.s571.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_58
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_58
  have hcl : SSt (· < 2558) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s572.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S570.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_58] <;> decide) PRE_first_tail_x8_r0_body.cnodesK58 PRE_first_tail_x8_r0_body.cobjsK58
      PRE_first_tail_x8_r0_body.citemsK58 PRE_first_tail_x8_r0_body.cbd58 PRE_first_tail_x8_r0_body.csst58
  exact PRE_first_tail_x8_r0_body.cshift58 bodyNcl58 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_58] at this; exact this)


kernel_rfl bodyFramesEmpty58 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s571 a).isEmpty) = true
kernel_rfl bodyJsRoots58 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s570.next) PRE_first_tail_x8_r0_body.s572.trace PRE_first_tail_x8_r0_body.s572 = true
kernel_rfl bodyJsNative58 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s572.ffi) = true
kernel_rfl bodyLow58 : (PRE_first_tail_x8_r0_body.cws58 ++ PRE_first_tail_x8_r0_body.ws58).all (Nat.ble 9) = true
kernel_rfl bodyCntM58 : countersOkB PRE_first_tail_x8_r0_body.s570 PRE_first_tail_x8_r0_body.s571 = true
kernel_rfl bodyHi58 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s572.ffi).next setupP.E = true
kernel_rfl bodyNhi58 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s572.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge58 : bridgeOf PRE_first_tail_x8_r0_body.s571.ffi = bridgeOf PRE_first_tail_x8_r0_body.s570.ffi
kernel_rfl bodyNN58 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s570.ffi).nnext PRE_first_tail_x8_r0_body.P58.NL = true
kernel_rfl bodyXn58 : Nat.ble (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s572.ffi).next = true
kernel_rfl bodyLo58 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s572.ffi).next = true
theorem bodyFacts58 : BodySiteFacts PRE_first_tail_x8_r0_body.s570 PRE_first_tail_x8_r0_body.s571 PRE_first_tail_x8_r0_body.s572 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S570 PRE_first_tail_x8_r0_body.S571 PRE_first_tail_x8_r0_body.S572
    PRE_first_tail_x8_r0_body.ws58 PRE_first_tail_x8_r0_body.cws58 PRE_first_tail_x8_r0_body.nr58 PRE_first_tail_x8_r0_body.pl58 PRE_first_tail_x8_r0_body.cl58 2720767 2558 PRE_first_tail_x8_r0_body.kd58 PRE_first_tail_x8_r0_body.kappa58 PRE_first_tail_x8_r0_body.P58
    ⟨19354, 16440, 2720765, 2558⟩ ⟨19354, 16440, 2720765, 2558⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap58
  clean := bodyClean58
  cfix := PRE_first_tail_x8_r0_body.cfix58
  zpl := PRE_first_tail_x8_r0_body.zpl58
  zplnd := PRE_first_tail_x8_r0_body.zplnd58
  zn1 := PRE_first_tail_x8_r0_body.zn158
  zfirst := PRE_first_tail_x8_r0_body.zfirst58
  zscn := PRE_first_tail_x8_r0_body.zscn58
  zsmn := PRE_first_tail_x8_r0_body.zsmn58
  zgrow := PRE_first_tail_x8_r0_body.zgrow58
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab58
  zfresh := PRE_first_tail_x8_r0_body.zfresh58
  zcnd := PRE_first_tail_x8_r0_body.zcnd58
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi58
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt58
  zgP := PRE_first_tail_x8_r0_body.zg58_2665
  zkP := PRE_first_tail_x8_r0_body.zk58_2665
  zmP := PRE_first_tail_x8_r0_body.zm58_2665
  zgC := PRE_first_tail_x8_r0_body.zg58_2673467
  zkC := PRE_first_tail_x8_r0_body.zk58_2673467
  zmC := PRE_first_tail_x8_r0_body.zm58_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw58_2673472
  zwV := PRE_first_tail_x8_r0_body.zw58_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap58
  zclbd := PRE_first_tail_x8_r0_body.zclbd58
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap58 PRE_first_tail_x8_r0_body.stFoot58 PRE_first_tail_x8_r0_body.iso58 PRE_first_tail_x8_r0_body.zwr58
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP58
  csupp := PRE_first_tail_x8_r0_body.csupp58
  cbound := PRE_first_tail_x8_r0_body.cbound58
  zimg := PRE_first_tail_x8_r0_body.zimg58
  zctl := PRE_first_tail_x8_r0_body.zctl58
  zstack := PRE_first_tail_x8_r0_body.zstack58
  zjobs := PRE_first_tail_x8_r0_body.zjobs58
  zstores := PRE_first_tail_x8_r0_body.zstores58
  zroots := PRE_first_tail_x8_r0_body.zroots58
  znC := PRE_first_tail_x8_r0_body.znC58
  ctab := PRE_first_tail_x8_r0_body.ctab58
  zbin := PRE_first_tail_x8_r0_body.zbin58
  cbridge := PRE_first_tail_x8_r0_body.cbridge58
  sbridge := bodyBridge58
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj58
  cshiftR := fun h hNL => bodyCshift58 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN58
  raised := PRE_first_tail_x8_r0_body.raised58
  cbigs := PRE_first_tail_x8_r0_body.cbigs58
  cjcl := PRE_first_tail_x8_r0_body.cjcl58
  xnLe := Nat.le_of_ble_eq_true bodyXn58
  loLe := Nat.le_of_ble_eq_true bodyLo58
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB58
  cntM := bodyCntM58
  hiLe := Nat.le_of_ble_eq_true bodyHi58
  nhiLe := Nat.le_of_ble_eq_true bodyNhi58
  jsHeap := bodyJs58
  jsRoots := bodyJsRoots58
  jsNative := bodyJsNative58
  framesEmpty := bodyFramesEmpty58
  trailOld := by decide
  lowVars := bodyLow58

def bodyQs58 : List (Option Q) := []
noncomputable def bodyEs58 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr58.map fun r => nth? PRE_first_tail_x8_r0_body.st58.S2.tab r
kernel_rfl bodyResChk58 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs58 bodyQs58) = true
kernel_rfl bodyLq58 : bodyQs58.length = PRE_first_tail_x8_r0_body.cws58.length
kernel_rfl bodyNrLo58 : PRE_first_tail_x8_r0_body.nr58.all (Nat.ble PRE_first_tail_x8_r0_body.S570.tab.length) = true
kernel_rfl bodySub58 : (Oracles.PRE_first_tail_x8_r0_body.map_site58.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost58 : postSubB bodyM PRE_first_tail_x8_r0_body.ws58 PRE_first_tail_x8_r0_body.cws58 bodyQs58 = true
kernel_rfl bodyDrop58 : Nat.ble (23397 + (PRE_first_tail_x8_r0_body.s571.next - PRE_first_tail_x8_r0_body.s572.next)) 23399 = true
kernel_rfl bodyDropH58 : Nat.ble (406 + ((mlxOf PRE_first_tail_x8_r0_body.s571.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s572.ffi).next)) 406 = true
kernel_rfl bodyDropN58 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s571.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s572.ffi).nnext)) 0 = true
kernel_rfl bodyDv58 : bodyΘ.1.take 315 = bodyΘ.1.take 315 ++ PRE_first_tail_x8_r0_body.cws58
kernel_rfl bodyDe58 : bodyΘ.2.take 315 = bodyΘ.2.take 315 ++ PRE_first_tail_x8_r0_body.nr58.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st58.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 315) (bodyΘ.2.take 315)))
kernel_rfl bodyDl58 : (bodyΘ.1.take 315).length = (bodyΘ.2.take 315).length
kernel_rfl bodyDold58 : (bodyΘ.1.take 315).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws58).isNone && !PRE_first_tail_x8_r0_body.ws58.contains v) = true
kernel_rfl bodyDfree58 : (bodyΘ.2.take 315).all (fun e => (PRE_first_tail_x8_r0_body.cws58 ++ PRE_first_tail_x8_r0_body.ws58).all fun w => e.noVar w) = true

theorem bodyStep58 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23397, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s570 PRE_first_tail_x8_r0_body.S570)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23399, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s572 PRE_first_tail_x8_r0_body.S572) (27 + 1) :=
  bodySite bodyFacts58.cfix bodyFacts58.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x8_r0_body.st58.S2.tab) (Es := bodyEs58) (qs := bodyQs58)
    (ok := PRE_first_tail_x8_r0_body.st58.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site58 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts58
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site58 r hr) hi (MapOk.sub hm (sub_of_all bodySub58)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk58 r hr) hi hm ho hq)
    bodyLq58 rfl bodyNrLo58 (postSub_sound bodyPost58)
    (Nat.le_of_ble_eq_true bodyDrop58) (by decide) (Nat.le_of_ble_eq_true bodyDropH58) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN58) (by decide)
    bodyDv58 bodyDe58 bodyDl58 bodyDold58 bodyDfree58 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site59 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site59 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site59) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site59
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s574 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s575 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S574 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws59 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso59
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_59
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot59
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup59
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound59
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace59
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged59
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws59.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st59.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S574.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_59]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen59.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh59
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl59 : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s574.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl59 (PRE_first_tail_x8_r0_body.cncl58 bodyNcl58)

theorem bodyClean59 : Conv.JClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s574 :=
  PRE_first_tail_x8_r0_body.gjcl59 (PRE_first_tail_x8_r0_body.cjcl58 bodyClean58)

kernel_rfl bodyJsLe59 : Nat.ble PRE_first_tail_x8_r0_body.s570.next PRE_first_tail_x8_r0_body.s574.next = true
kernel_rfl bodyJsList59 : (PRE_first_tail_x8_r0_body.gjh59 ++ PRE_first_tail_x8_r0_body.cl59).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s574.next) PRE_first_tail_x8_r0_body.s576) = true
theorem bodyJs59 : JsHeapAbove PRE_first_tail_x8_r0_body.s574.next PRE_first_tail_x8_r0_body.s576 :=
  JsHeapAbove.glueSite bodyJs58 (Nat.le_of_ble_eq_true bodyJsLe59) PRE_first_tail_x8_r0_body.gjk59 PRE_first_tail_x8_r0_body.gjbd59 PRE_first_tail_x8_r0_body.cheap59 PRE_first_tail_x8_r0_body.zclbd59 bodyJsList59

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO572 : PRE_first_tail_x8_r0_body.S572.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S572.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr572 : bridgeOf PRE_first_tail_x8_r0_body.s572.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc572 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s572 PRE_first_tail_x8_r0_body.S572) = fun _ _ => true
kernel_rfl bodyAcc573 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s573 PRE_first_tail_x8_r0_body.S573) = fun _ _ => true
kernel_rfl bodyBr574 : bridgeOf PRE_first_tail_x8_r0_body.s574.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt573 : isHalt PRE_first_tail_x8_r0_body.s573.ctl = false
kernel_rfl bodyTop574 : noRetBlock PRE_first_tail_x8_r0_body.s574 = true
kernel_rfl bodyCnt572 : countersOkB PRE_first_tail_x8_r0_body.s572 PRE_first_tail_x8_r0_body.s574 = true

theorem bodyGlue59 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23399, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s572 PRE_first_tail_x8_r0_body.S572)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23399, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s574 PRE_first_tail_x8_r0_body.S574) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23399, 406, 0, 315⟩) bodyAcc572 PRE_first_tail_x8_r0_body.bodyRunSeg154 bodyAcc573 bodyHalt573 PRE_first_tail_x8_r0_body.bodyStepA155 bodyTop574 (fun _ hm => bodyO572 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr572).trans bodyInactive0) (bodyBr574.trans bodyBr572.symm) bodyCnt572 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift59 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S574.tab.length PRE_first_tail_x8_r0_body.s574.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P59.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P59 2575 PRE_first_tail_x8_r0_body.kappa59 PRE_first_tail_x8_r0_body.s576.ffi PRE_first_tail_x8_r0_body.s575.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_59
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_59
  have hcl : SSt (· < 2575) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s576.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S574.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_59] <;> decide) PRE_first_tail_x8_r0_body.cnodesK59 PRE_first_tail_x8_r0_body.cobjsK59
      PRE_first_tail_x8_r0_body.citemsK59 PRE_first_tail_x8_r0_body.cbd59 PRE_first_tail_x8_r0_body.csst59
  exact PRE_first_tail_x8_r0_body.cshift59 bodyNcl59 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_59] at this; exact this)


kernel_rfl bodyFramesEmpty59 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s575 a).isEmpty) = true
kernel_rfl bodyJsRoots59 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s574.next) PRE_first_tail_x8_r0_body.s576.trace PRE_first_tail_x8_r0_body.s576 = true
kernel_rfl bodyJsNative59 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s576.ffi) = true
kernel_rfl bodyLow59 : (PRE_first_tail_x8_r0_body.cws59 ++ PRE_first_tail_x8_r0_body.ws59).all (Nat.ble 9) = true
kernel_rfl bodyCntM59 : countersOkB PRE_first_tail_x8_r0_body.s574 PRE_first_tail_x8_r0_body.s575 = true
kernel_rfl bodyHi59 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s576.ffi).next setupP.E = true
kernel_rfl bodyNhi59 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s576.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge59 : bridgeOf PRE_first_tail_x8_r0_body.s575.ffi = bridgeOf PRE_first_tail_x8_r0_body.s574.ffi
kernel_rfl bodyNN59 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s574.ffi).nnext PRE_first_tail_x8_r0_body.P59.NL = true
kernel_rfl bodyXn59 : Nat.ble (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s576.ffi).next = true
kernel_rfl bodyLo59 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s576.ffi).next = true
theorem bodyFacts59 : BodySiteFacts PRE_first_tail_x8_r0_body.s574 PRE_first_tail_x8_r0_body.s575 PRE_first_tail_x8_r0_body.s576 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S574 PRE_first_tail_x8_r0_body.S575 PRE_first_tail_x8_r0_body.S576
    PRE_first_tail_x8_r0_body.ws59 PRE_first_tail_x8_r0_body.cws59 PRE_first_tail_x8_r0_body.nr59 PRE_first_tail_x8_r0_body.pl59 PRE_first_tail_x8_r0_body.cl59 2721064 2575 PRE_first_tail_x8_r0_body.kd59 PRE_first_tail_x8_r0_body.kappa59 PRE_first_tail_x8_r0_body.P59
    ⟨19361, 16444, 2721053, 2575⟩ ⟨19361, 16444, 2721054, 2575⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap59
  clean := bodyClean59
  cfix := PRE_first_tail_x8_r0_body.cfix59
  zpl := PRE_first_tail_x8_r0_body.zpl59
  zplnd := PRE_first_tail_x8_r0_body.zplnd59
  zn1 := PRE_first_tail_x8_r0_body.zn159
  zfirst := PRE_first_tail_x8_r0_body.zfirst59
  zscn := PRE_first_tail_x8_r0_body.zscn59
  zsmn := PRE_first_tail_x8_r0_body.zsmn59
  zgrow := PRE_first_tail_x8_r0_body.zgrow59
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab59
  zfresh := PRE_first_tail_x8_r0_body.zfresh59
  zcnd := PRE_first_tail_x8_r0_body.zcnd59
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi59
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt59
  zgP := PRE_first_tail_x8_r0_body.zg59_2665
  zkP := PRE_first_tail_x8_r0_body.zk59_2665
  zmP := PRE_first_tail_x8_r0_body.zm59_2665
  zgC := PRE_first_tail_x8_r0_body.zg59_2673467
  zkC := PRE_first_tail_x8_r0_body.zk59_2673467
  zmC := PRE_first_tail_x8_r0_body.zm59_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw59_2673472
  zwV := PRE_first_tail_x8_r0_body.zw59_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap59
  zclbd := PRE_first_tail_x8_r0_body.zclbd59
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap59 PRE_first_tail_x8_r0_body.stFoot59 PRE_first_tail_x8_r0_body.iso59 PRE_first_tail_x8_r0_body.zwr59
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP59
  csupp := PRE_first_tail_x8_r0_body.csupp59
  cbound := PRE_first_tail_x8_r0_body.cbound59
  zimg := PRE_first_tail_x8_r0_body.zimg59
  zctl := PRE_first_tail_x8_r0_body.zctl59
  zstack := PRE_first_tail_x8_r0_body.zstack59
  zjobs := PRE_first_tail_x8_r0_body.zjobs59
  zstores := PRE_first_tail_x8_r0_body.zstores59
  zroots := PRE_first_tail_x8_r0_body.zroots59
  znC := PRE_first_tail_x8_r0_body.znC59
  ctab := PRE_first_tail_x8_r0_body.ctab59
  zbin := PRE_first_tail_x8_r0_body.zbin59
  cbridge := PRE_first_tail_x8_r0_body.cbridge59
  sbridge := bodyBridge59
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj59
  cshiftR := fun h hNL => bodyCshift59 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN59
  raised := PRE_first_tail_x8_r0_body.raised59
  cbigs := PRE_first_tail_x8_r0_body.cbigs59
  cjcl := PRE_first_tail_x8_r0_body.cjcl59
  xnLe := Nat.le_of_ble_eq_true bodyXn59
  loLe := Nat.le_of_ble_eq_true bodyLo59
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB59
  cntM := bodyCntM59
  hiLe := Nat.le_of_ble_eq_true bodyHi59
  nhiLe := Nat.le_of_ble_eq_true bodyNhi59
  jsHeap := bodyJs59
  jsRoots := bodyJsRoots59
  jsNative := bodyJsNative59
  framesEmpty := bodyFramesEmpty59
  trailOld := by decide
  lowVars := bodyLow59

def bodyQs59 : List (Option Q) := []
noncomputable def bodyEs59 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr59.map fun r => nth? PRE_first_tail_x8_r0_body.st59.S2.tab r
kernel_rfl bodyResChk59 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs59 bodyQs59) = true
kernel_rfl bodyLq59 : bodyQs59.length = PRE_first_tail_x8_r0_body.cws59.length
kernel_rfl bodyNrLo59 : PRE_first_tail_x8_r0_body.nr59.all (Nat.ble PRE_first_tail_x8_r0_body.S574.tab.length) = true
kernel_rfl bodySub59 : (Oracles.PRE_first_tail_x8_r0_body.map_site59.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost59 : postSubB bodyM PRE_first_tail_x8_r0_body.ws59 PRE_first_tail_x8_r0_body.cws59 bodyQs59 = true
kernel_rfl bodyDrop59 : Nat.ble (23399 + (PRE_first_tail_x8_r0_body.s575.next - PRE_first_tail_x8_r0_body.s576.next)) 23409 = true
kernel_rfl bodyDropH59 : Nat.ble (406 + ((mlxOf PRE_first_tail_x8_r0_body.s575.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s576.ffi).next)) 406 = true
kernel_rfl bodyDropN59 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s575.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s576.ffi).nnext)) 0 = true
kernel_rfl bodyDv59 : bodyΘ.1.take 315 = bodyΘ.1.take 315 ++ PRE_first_tail_x8_r0_body.cws59
kernel_rfl bodyDe59 : bodyΘ.2.take 315 = bodyΘ.2.take 315 ++ PRE_first_tail_x8_r0_body.nr59.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st59.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 315) (bodyΘ.2.take 315)))
kernel_rfl bodyDl59 : (bodyΘ.1.take 315).length = (bodyΘ.2.take 315).length
kernel_rfl bodyDold59 : (bodyΘ.1.take 315).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws59).isNone && !PRE_first_tail_x8_r0_body.ws59.contains v) = true
kernel_rfl bodyDfree59 : (bodyΘ.2.take 315).all (fun e => (PRE_first_tail_x8_r0_body.cws59 ++ PRE_first_tail_x8_r0_body.ws59).all fun w => e.noVar w) = true

theorem bodyStep59 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23399, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s574 PRE_first_tail_x8_r0_body.S574)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23409, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s576 PRE_first_tail_x8_r0_body.S576) (98 + 1) :=
  bodySite bodyFacts59.cfix bodyFacts59.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x8_r0_body.st59.S2.tab) (Es := bodyEs59) (qs := bodyQs59)
    (ok := PRE_first_tail_x8_r0_body.st59.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site59 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts59
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site59 r hr) hi (MapOk.sub hm (sub_of_all bodySub59)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk59 r hr) hi hm ho hq)
    bodyLq59 rfl bodyNrLo59 (postSub_sound bodyPost59)
    (Nat.le_of_ble_eq_true bodyDrop59) (by decide) (Nat.le_of_ble_eq_true bodyDropH59) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN59) (by decide)
    bodyDv59 bodyDe59 bodyDl59 bodyDold59 bodyDfree59 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyOracles_15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_g60 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g60 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g60) (List.take 16 (List.drop 588 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site60 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site60 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site60) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st60.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g61 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g61 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g61) (List.take 7 (List.drop 604 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site61 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site61 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site61) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st61.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g62 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g62 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g62) (List.take 3 (List.drop 611 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

noncomputable def PRE_first_tail_x8_r0_body.map_site62 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site62 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site62) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.S0.oracle) = true

def PRE_first_tail_x8_r0_body.map_g63 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_g63 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_g63) (List.take 16 (List.drop 614 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.OR))) = true

def PRE_first_tail_x8_r0_body.map_site63 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site63 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site63) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st63.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site60 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site60 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site60) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st60.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site60
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st60.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st60.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s591 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s592 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S591 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws60 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st60.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st60.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso60
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_60
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st60.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot60
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup60
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound60
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace60
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged60
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws60.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st60.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S591.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_60]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen60.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh60
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl60 : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s591.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl60 (PRE_first_tail_x8_r0_body.cncl59 bodyNcl59)

theorem bodyClean60 : Conv.JClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s591 :=
  PRE_first_tail_x8_r0_body.gjcl60 (PRE_first_tail_x8_r0_body.cjcl59 bodyClean59)

kernel_rfl bodyJsLe60 : Nat.ble PRE_first_tail_x8_r0_body.s574.next PRE_first_tail_x8_r0_body.s591.next = true
kernel_rfl bodyJsList60 : (PRE_first_tail_x8_r0_body.gjh60 ++ PRE_first_tail_x8_r0_body.cl60).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s591.next) PRE_first_tail_x8_r0_body.s593) = true
theorem bodyJs60 : JsHeapAbove PRE_first_tail_x8_r0_body.s591.next PRE_first_tail_x8_r0_body.s593 :=
  JsHeapAbove.glueSite bodyJs59 (Nat.le_of_ble_eq_true bodyJsLe60) PRE_first_tail_x8_r0_body.gjk60 PRE_first_tail_x8_r0_body.gjbd60 PRE_first_tail_x8_r0_body.cheap60 PRE_first_tail_x8_r0_body.zclbd60 bodyJsList60

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO576 : PRE_first_tail_x8_r0_body.S576.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S576.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr576 : bridgeOf PRE_first_tail_x8_r0_body.s576.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc576 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s576 PRE_first_tail_x8_r0_body.S576) = fun _ _ => true
kernel_rfl bodyAcc578 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s578 PRE_first_tail_x8_r0_body.S578) = fun _ _ => true
kernel_rfl bodyBr579 : bridgeOf PRE_first_tail_x8_r0_body.s579.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt578 : isHalt PRE_first_tail_x8_r0_body.s578.ctl = false
kernel_rfl bodyTop579 : noRetBlock PRE_first_tail_x8_r0_body.s579 = true
kernel_rfl bodyCnt576 : countersOkB PRE_first_tail_x8_r0_body.s576 PRE_first_tail_x8_r0_body.s579 = true
kernel_rfl bodyO579 : PRE_first_tail_x8_r0_body.S579.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S579.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr580 : bridgeOf PRE_first_tail_x8_r0_body.s580.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt579 : countersOkB PRE_first_tail_x8_r0_body.s579 PRE_first_tail_x8_r0_body.s580 = true
kernel_rfl bodyO580 : PRE_first_tail_x8_r0_body.S580.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S580.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc580 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s580 PRE_first_tail_x8_r0_body.S580) = fun _ _ => true
kernel_rfl bodyAcc581 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s581 PRE_first_tail_x8_r0_body.S581) = fun _ _ => true
kernel_rfl bodyBr582 : bridgeOf PRE_first_tail_x8_r0_body.s582.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt581 : isHalt PRE_first_tail_x8_r0_body.s581.ctl = false
kernel_rfl bodyTop582 : noRetBlock PRE_first_tail_x8_r0_body.s582 = true
kernel_rfl bodyCnt580 : countersOkB PRE_first_tail_x8_r0_body.s580 PRE_first_tail_x8_r0_body.s582 = true
kernel_rfl bodyO582 : PRE_first_tail_x8_r0_body.S582.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S582.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr583 : bridgeOf PRE_first_tail_x8_r0_body.s583.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt582 : countersOkB PRE_first_tail_x8_r0_body.s582 PRE_first_tail_x8_r0_body.s583 = true
kernel_rfl bodyO583 : PRE_first_tail_x8_r0_body.S583.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S583.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc583 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s583 PRE_first_tail_x8_r0_body.S583) = fun _ _ => true
kernel_rfl bodyAcc584 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s584 PRE_first_tail_x8_r0_body.S584) = fun _ _ => true
kernel_rfl bodyBr585 : bridgeOf PRE_first_tail_x8_r0_body.s585.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt584 : isHalt PRE_first_tail_x8_r0_body.s584.ctl = false
kernel_rfl bodyTop585 : noRetBlock PRE_first_tail_x8_r0_body.s585 = true
kernel_rfl bodyCnt583 : countersOkB PRE_first_tail_x8_r0_body.s583 PRE_first_tail_x8_r0_body.s585 = true
kernel_rfl bodyO585 : PRE_first_tail_x8_r0_body.S585.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S585.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr586 : bridgeOf PRE_first_tail_x8_r0_body.s586.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt585 : countersOkB PRE_first_tail_x8_r0_body.s585 PRE_first_tail_x8_r0_body.s586 = true
kernel_rfl bodyO586 : PRE_first_tail_x8_r0_body.S586.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S586.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc586 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s586 PRE_first_tail_x8_r0_body.S586) = fun _ _ => true
kernel_rfl bodyAcc587 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s587 PRE_first_tail_x8_r0_body.S587) = fun _ _ => true
kernel_rfl bodyBr588 : bridgeOf PRE_first_tail_x8_r0_body.s588.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt587 : isHalt PRE_first_tail_x8_r0_body.s587.ctl = false
kernel_rfl bodyTop588 : noRetBlock PRE_first_tail_x8_r0_body.s588 = true
kernel_rfl bodyCnt586 : countersOkB PRE_first_tail_x8_r0_body.s586 PRE_first_tail_x8_r0_body.s588 = true
kernel_rfl bodyO588 : PRE_first_tail_x8_r0_body.S588.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S588.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr589 : bridgeOf PRE_first_tail_x8_r0_body.s589.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt588 : countersOkB PRE_first_tail_x8_r0_body.s588 PRE_first_tail_x8_r0_body.s589 = true
kernel_rfl bodyO589 : PRE_first_tail_x8_r0_body.S589.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S589.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc589 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s589 PRE_first_tail_x8_r0_body.S589) = fun _ _ => true
kernel_rfl bodyAcc590 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s590 PRE_first_tail_x8_r0_body.S590) = fun _ _ => true
kernel_rfl bodyBr591 : bridgeOf PRE_first_tail_x8_r0_body.s591.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt590 : isHalt PRE_first_tail_x8_r0_body.s590.ctl = false
kernel_rfl bodyTop591 : noRetBlock PRE_first_tail_x8_r0_body.s591 = true
kernel_rfl bodyCnt589 : countersOkB PRE_first_tail_x8_r0_body.s589 PRE_first_tail_x8_r0_body.s591 = true

theorem bodyGlue60 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23409, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s576 PRE_first_tail_x8_r0_body.S576)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23409, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s591 PRE_first_tail_x8_r0_body.S591) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) bodyAcc576 PRE_first_tail_x8_r0_body.bodyRunSeg155 bodyAcc578 bodyHalt578 PRE_first_tail_x8_r0_body.bodyStepA156 bodyTop579 (fun _ hm => bodyO576 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr576).trans bodyInactive0) (bodyBr579.trans bodyBr576.symm) bodyCnt576 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) PRE_first_tail_x8_r0_body.sizeA156 PRE_first_tail_x8_r0_body.sizeArgsA156 PRE_first_tail_x8_r0_body.sizeSymA156 PRE_first_tail_x8_r0_body.sizeMlxA156 PRE_first_tail_x8_r0_body.sizePayA156 PRE_first_tail_x8_r0_body.sizeTaA156 PRE_first_tail_x8_r0_body.sizeDecA156 PRE_first_tail_x8_r0_body.sizePreA156 PRE_first_tail_x8_r0_body.bodyPatchB156 (fun _ hm => bodyO579 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr579).trans bodyInactive0) (bodyBr580.trans bodyBr579.symm) bodyCnt579 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) bodyAcc580 PRE_first_tail_x8_r0_body.bodyRunSeg156 bodyAcc581 bodyHalt581 PRE_first_tail_x8_r0_body.bodyStepA157 bodyTop582 (fun _ hm => bodyO580 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr580).trans bodyInactive0) (bodyBr582.trans bodyBr580.symm) bodyCnt580 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) PRE_first_tail_x8_r0_body.sizeA157 PRE_first_tail_x8_r0_body.sizeArgsA157 PRE_first_tail_x8_r0_body.sizeSymA157 PRE_first_tail_x8_r0_body.sizeMlxA157 PRE_first_tail_x8_r0_body.sizePayA157 PRE_first_tail_x8_r0_body.sizeTaA157 PRE_first_tail_x8_r0_body.sizeDecA157 PRE_first_tail_x8_r0_body.sizePreA157 PRE_first_tail_x8_r0_body.bodyPatchB157 (fun _ hm => bodyO582 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr582).trans bodyInactive0) (bodyBr583.trans bodyBr582.symm) bodyCnt582 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) bodyAcc583 PRE_first_tail_x8_r0_body.bodyRunSeg157 bodyAcc584 bodyHalt584 PRE_first_tail_x8_r0_body.bodyStepA158 bodyTop585 (fun _ hm => bodyO583 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr583).trans bodyInactive0) (bodyBr585.trans bodyBr583.symm) bodyCnt583 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) PRE_first_tail_x8_r0_body.sizeA158 PRE_first_tail_x8_r0_body.sizeArgsA158 PRE_first_tail_x8_r0_body.sizeSymA158 PRE_first_tail_x8_r0_body.sizeMlxA158 PRE_first_tail_x8_r0_body.sizePayA158 PRE_first_tail_x8_r0_body.sizeTaA158 PRE_first_tail_x8_r0_body.sizeDecA158 PRE_first_tail_x8_r0_body.sizePreA158 PRE_first_tail_x8_r0_body.bodyPatchB158 (fun _ hm => bodyO585 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr585).trans bodyInactive0) (bodyBr586.trans bodyBr585.symm) bodyCnt585 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) bodyAcc586 PRE_first_tail_x8_r0_body.bodyRunSeg158 bodyAcc587 bodyHalt587 PRE_first_tail_x8_r0_body.bodyStepA159 bodyTop588 (fun _ hm => bodyO586 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr586).trans bodyInactive0) (bodyBr588.trans bodyBr586.symm) bodyCnt586 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) PRE_first_tail_x8_r0_body.sizeA159 PRE_first_tail_x8_r0_body.sizeArgsA159 PRE_first_tail_x8_r0_body.sizeSymA159 PRE_first_tail_x8_r0_body.sizeMlxA159 PRE_first_tail_x8_r0_body.sizePayA159 PRE_first_tail_x8_r0_body.sizeTaA159 PRE_first_tail_x8_r0_body.sizeDecA159 PRE_first_tail_x8_r0_body.sizePreA159 PRE_first_tail_x8_r0_body.bodyPatchB159 (fun _ hm => bodyO588 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr588).trans bodyInactive0) (bodyBr589.trans bodyBr588.symm) bodyCnt588 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23409, 406, 0, 315⟩) bodyAcc589 PRE_first_tail_x8_r0_body.bodyRunSeg159 bodyAcc590 bodyHalt590 PRE_first_tail_x8_r0_body.bodyStepA160 bodyTop591 (fun _ hm => bodyO589 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr589).trans bodyInactive0) (bodyBr591.trans bodyBr589.symm) bodyCnt589 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift60 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S591.tab.length PRE_first_tail_x8_r0_body.s591.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P60.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P60 2666 PRE_first_tail_x8_r0_body.kappa60 PRE_first_tail_x8_r0_body.s593.ffi PRE_first_tail_x8_r0_body.s592.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_60
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_60
  have hcl : SSt (· < 2666) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s593.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S591.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_60] <;> decide) PRE_first_tail_x8_r0_body.cnodesK60 PRE_first_tail_x8_r0_body.cobjsK60
      PRE_first_tail_x8_r0_body.citemsK60 PRE_first_tail_x8_r0_body.cbd60 PRE_first_tail_x8_r0_body.csst60
  exact PRE_first_tail_x8_r0_body.cshift60 bodyNcl60 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_60] at this; exact this)


kernel_rfl bodyFramesEmpty60 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s592 a).isEmpty) = true
kernel_rfl bodyJsRoots60 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s591.next) PRE_first_tail_x8_r0_body.s593.trace PRE_first_tail_x8_r0_body.s593 = true
kernel_rfl bodyJsNative60 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s593.ffi) = true
kernel_rfl bodyLow60 : (PRE_first_tail_x8_r0_body.cws60 ++ PRE_first_tail_x8_r0_body.ws60).all (Nat.ble 9) = true
kernel_rfl bodyCntM60 : countersOkB PRE_first_tail_x8_r0_body.s591 PRE_first_tail_x8_r0_body.s592 = true
kernel_rfl bodyHi60 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s593.ffi).next setupP.E = true
kernel_rfl bodyNhi60 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s593.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge60 : bridgeOf PRE_first_tail_x8_r0_body.s592.ffi = bridgeOf PRE_first_tail_x8_r0_body.s591.ffi
kernel_rfl bodyNN60 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s591.ffi).nnext PRE_first_tail_x8_r0_body.P60.NL = true
kernel_rfl bodyXn60 : Nat.ble (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s593.ffi).next = true
kernel_rfl bodyLo60 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s593.ffi).next = true
theorem bodyFacts60 : BodySiteFacts PRE_first_tail_x8_r0_body.s591 PRE_first_tail_x8_r0_body.s592 PRE_first_tail_x8_r0_body.s593 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S591 PRE_first_tail_x8_r0_body.S592 PRE_first_tail_x8_r0_body.S593
    PRE_first_tail_x8_r0_body.ws60 PRE_first_tail_x8_r0_body.cws60 PRE_first_tail_x8_r0_body.nr60 PRE_first_tail_x8_r0_body.pl60 PRE_first_tail_x8_r0_body.cl60 2723702 2666 PRE_first_tail_x8_r0_body.kd60 PRE_first_tail_x8_r0_body.kappa60 PRE_first_tail_x8_r0_body.P60
    ⟨19396, 16463, 2722547, 2648⟩ ⟨19399, 16490, 2722553, 2666⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap60
  clean := bodyClean60
  cfix := PRE_first_tail_x8_r0_body.cfix60
  zpl := PRE_first_tail_x8_r0_body.zpl60
  zplnd := PRE_first_tail_x8_r0_body.zplnd60
  zn1 := PRE_first_tail_x8_r0_body.zn160
  zfirst := PRE_first_tail_x8_r0_body.zfirst60
  zscn := PRE_first_tail_x8_r0_body.zscn60
  zsmn := PRE_first_tail_x8_r0_body.zsmn60
  zgrow := PRE_first_tail_x8_r0_body.zgrow60
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab60
  zfresh := PRE_first_tail_x8_r0_body.zfresh60
  zcnd := PRE_first_tail_x8_r0_body.zcnd60
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi60
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt60
  zgP := PRE_first_tail_x8_r0_body.zg60_2665
  zkP := PRE_first_tail_x8_r0_body.zk60_2665
  zmP := PRE_first_tail_x8_r0_body.zm60_2665
  zgC := PRE_first_tail_x8_r0_body.zg60_2673467
  zkC := PRE_first_tail_x8_r0_body.zk60_2673467
  zmC := PRE_first_tail_x8_r0_body.zm60_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw60_2673472
  zwV := PRE_first_tail_x8_r0_body.zw60_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap60
  zclbd := PRE_first_tail_x8_r0_body.zclbd60
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap60 PRE_first_tail_x8_r0_body.stFoot60 PRE_first_tail_x8_r0_body.iso60 PRE_first_tail_x8_r0_body.zwr60
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP60
  csupp := PRE_first_tail_x8_r0_body.csupp60
  cbound := PRE_first_tail_x8_r0_body.cbound60
  zimg := PRE_first_tail_x8_r0_body.zimg60
  zctl := PRE_first_tail_x8_r0_body.zctl60
  zstack := PRE_first_tail_x8_r0_body.zstack60
  zjobs := PRE_first_tail_x8_r0_body.zjobs60
  zstores := PRE_first_tail_x8_r0_body.zstores60
  zroots := PRE_first_tail_x8_r0_body.zroots60
  znC := PRE_first_tail_x8_r0_body.znC60
  ctab := PRE_first_tail_x8_r0_body.ctab60
  zbin := PRE_first_tail_x8_r0_body.zbin60
  cbridge := PRE_first_tail_x8_r0_body.cbridge60
  sbridge := bodyBridge60
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj60
  cshiftR := fun h hNL => bodyCshift60 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN60
  raised := PRE_first_tail_x8_r0_body.raised60
  cbigs := PRE_first_tail_x8_r0_body.cbigs60
  cjcl := PRE_first_tail_x8_r0_body.cjcl60
  xnLe := Nat.le_of_ble_eq_true bodyXn60
  loLe := Nat.le_of_ble_eq_true bodyLo60
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB60
  cntM := bodyCntM60
  hiLe := Nat.le_of_ble_eq_true bodyHi60
  nhiLe := Nat.le_of_ble_eq_true bodyNhi60
  jsHeap := bodyJs60
  jsRoots := bodyJsRoots60
  jsNative := bodyJsNative60
  framesEmpty := bodyFramesEmpty60
  trailOld := by decide
  lowVars := bodyLow60

def bodyQs60 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs60 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr60.map fun r => nth? PRE_first_tail_x8_r0_body.st60.S5.tab r
kernel_rfl bodyResChk60 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs60 bodyQs60) = true
kernel_rfl bodyLq60 : bodyQs60.length = PRE_first_tail_x8_r0_body.cws60.length
kernel_rfl bodyNrLo60 : PRE_first_tail_x8_r0_body.nr60.all (Nat.ble PRE_first_tail_x8_r0_body.S591.tab.length) = true
kernel_rfl bodySub60 : (Oracles.PRE_first_tail_x8_r0_body.map_site60.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost60 : postSubB bodyM PRE_first_tail_x8_r0_body.ws60 PRE_first_tail_x8_r0_body.cws60 bodyQs60 = true
kernel_rfl bodyDrop60 : Nat.ble (23409 + (PRE_first_tail_x8_r0_body.s592.next - PRE_first_tail_x8_r0_body.s593.next)) 24558 = true
kernel_rfl bodyDropH60 : Nat.ble (406 + ((mlxOf PRE_first_tail_x8_r0_body.s592.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s593.ffi).next)) 431 = true
kernel_rfl bodyDropN60 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s592.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s593.ffi).nnext)) 0 = true
kernel_rfl bodyDv60 : bodyΘ.1.take 333 = bodyΘ.1.take 315 ++ PRE_first_tail_x8_r0_body.cws60
kernel_rfl bodyDe60 : bodyΘ.2.take 333 = bodyΘ.2.take 315 ++ PRE_first_tail_x8_r0_body.nr60.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st60.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 315) (bodyΘ.2.take 315)))
kernel_rfl bodyDl60 : (bodyΘ.1.take 315).length = (bodyΘ.2.take 315).length
kernel_rfl bodyDold60 : (bodyΘ.1.take 315).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws60).isNone && !PRE_first_tail_x8_r0_body.ws60.contains v) = true
kernel_rfl bodyDfree60 : (bodyΘ.2.take 333).all (fun e => (PRE_first_tail_x8_r0_body.cws60 ++ PRE_first_tail_x8_r0_body.ws60).all fun w => e.noVar w) = true

theorem bodyStep60 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23409, 406, 0, 315⟩ bodyM PRE_first_tail_x8_r0_body.s591 PRE_first_tail_x8_r0_body.S591)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24558, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s593 PRE_first_tail_x8_r0_body.S593) (11334 + 1) :=
  bodySite bodyFacts60.cfix bodyFacts60.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x8_r0_body.st60.S5.tab) (Es := bodyEs60) (qs := bodyQs60)
    (ok := PRE_first_tail_x8_r0_body.st60.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site60 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts60
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site60 r hr) hi (MapOk.sub hm (sub_of_all bodySub60)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk60 r hr) hi hm ho hq)
    bodyLq60 rfl bodyNrLo60 (postSub_sound bodyPost60)
    (Nat.le_of_ble_eq_true bodyDrop60) (by decide) (Nat.le_of_ble_eq_true bodyDropH60) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN60) (by decide)
    bodyDv60 bodyDe60 bodyDl60 bodyDold60 bodyDfree60 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site61 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site61 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site61) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st61.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site61
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st61.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st61.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s599 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s600 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S599 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws61 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st61.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st61.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso61
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_61
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st61.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot61
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup61
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound61
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace61
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged61
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws61.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st61.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S599.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_61]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen61.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh61
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl61 : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s599.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl61 (PRE_first_tail_x8_r0_body.cncl60 bodyNcl60)

theorem bodyClean61 : Conv.JClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s599 :=
  PRE_first_tail_x8_r0_body.gjcl61 (PRE_first_tail_x8_r0_body.cjcl60 bodyClean60)

kernel_rfl bodyJsLe61 : Nat.ble PRE_first_tail_x8_r0_body.s591.next PRE_first_tail_x8_r0_body.s599.next = true
kernel_rfl bodyJsList61 : (PRE_first_tail_x8_r0_body.gjh61 ++ PRE_first_tail_x8_r0_body.cl61).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s599.next) PRE_first_tail_x8_r0_body.s601) = true
theorem bodyJs61 : JsHeapAbove PRE_first_tail_x8_r0_body.s599.next PRE_first_tail_x8_r0_body.s601 :=
  JsHeapAbove.glueSite bodyJs60 (Nat.le_of_ble_eq_true bodyJsLe61) PRE_first_tail_x8_r0_body.gjk61 PRE_first_tail_x8_r0_body.gjbd61 PRE_first_tail_x8_r0_body.cheap61 PRE_first_tail_x8_r0_body.zclbd61 bodyJsList61

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO593 : PRE_first_tail_x8_r0_body.S593.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S593.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr593 : bridgeOf PRE_first_tail_x8_r0_body.s593.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc593 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s593 PRE_first_tail_x8_r0_body.S593) = fun _ _ => true
kernel_rfl bodyAcc594 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s594 PRE_first_tail_x8_r0_body.S594) = fun _ _ => true
kernel_rfl bodyBr595 : bridgeOf PRE_first_tail_x8_r0_body.s595.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt594 : isHalt PRE_first_tail_x8_r0_body.s594.ctl = false
kernel_rfl bodyTop595 : noRetBlock PRE_first_tail_x8_r0_body.s595 = true
kernel_rfl bodyCnt593 : countersOkB PRE_first_tail_x8_r0_body.s593 PRE_first_tail_x8_r0_body.s595 = true
kernel_rfl bodyO595 : PRE_first_tail_x8_r0_body.S595.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S595.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr596 : bridgeOf PRE_first_tail_x8_r0_body.s596.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt595 : countersOkB PRE_first_tail_x8_r0_body.s595 PRE_first_tail_x8_r0_body.s596 = true
kernel_rfl bodyO596 : PRE_first_tail_x8_r0_body.S596.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S596.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc596 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s596 PRE_first_tail_x8_r0_body.S596) = fun _ _ => true
kernel_rfl bodyAcc598 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s598 PRE_first_tail_x8_r0_body.S598) = fun _ _ => true
kernel_rfl bodyBr599 : bridgeOf PRE_first_tail_x8_r0_body.s599.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt598 : isHalt PRE_first_tail_x8_r0_body.s598.ctl = false
kernel_rfl bodyTop599 : noRetBlock PRE_first_tail_x8_r0_body.s599 = true
kernel_rfl bodyCnt596 : countersOkB PRE_first_tail_x8_r0_body.s596 PRE_first_tail_x8_r0_body.s599 = true

theorem bodyGlue61 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24558, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s593 PRE_first_tail_x8_r0_body.S593)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24558, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s599 PRE_first_tail_x8_r0_body.S599) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24558, 431, 0, 333⟩) bodyAcc593 PRE_first_tail_x8_r0_body.bodyRunSeg160 bodyAcc594 bodyHalt594 PRE_first_tail_x8_r0_body.bodyStepA161 bodyTop595 (fun _ hm => bodyO593 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr593).trans bodyInactive0) (bodyBr595.trans bodyBr593.symm) bodyCnt593 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24558, 431, 0, 333⟩) PRE_first_tail_x8_r0_body.sizeA161 PRE_first_tail_x8_r0_body.sizeArgsA161 PRE_first_tail_x8_r0_body.sizeSymA161 PRE_first_tail_x8_r0_body.sizeMlxA161 PRE_first_tail_x8_r0_body.sizePayA161 PRE_first_tail_x8_r0_body.sizeTaA161 PRE_first_tail_x8_r0_body.sizeDecA161 PRE_first_tail_x8_r0_body.sizePreA161 PRE_first_tail_x8_r0_body.bodyPatchB161 (fun _ hm => bodyO595 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr595).trans bodyInactive0) (bodyBr596.trans bodyBr595.symm) bodyCnt595 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24558, 431, 0, 333⟩) bodyAcc596 PRE_first_tail_x8_r0_body.bodyRunSeg161 bodyAcc598 bodyHalt598 PRE_first_tail_x8_r0_body.bodyStepA162 bodyTop599 (fun _ hm => bodyO596 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr596).trans bodyInactive0) (bodyBr599.trans bodyBr596.symm) bodyCnt596 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift61 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S599.tab.length PRE_first_tail_x8_r0_body.s599.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P61.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P61 2687 PRE_first_tail_x8_r0_body.kappa61 PRE_first_tail_x8_r0_body.s601.ffi PRE_first_tail_x8_r0_body.s600.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_61
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_61
  have hcl : SSt (· < 2687) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s601.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S599.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_61] <;> decide) PRE_first_tail_x8_r0_body.cnodesK61 PRE_first_tail_x8_r0_body.cobjsK61
      PRE_first_tail_x8_r0_body.citemsK61 PRE_first_tail_x8_r0_body.cbd61 PRE_first_tail_x8_r0_body.csst61
  exact PRE_first_tail_x8_r0_body.cshift61 bodyNcl61 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_61] at this; exact this)


kernel_rfl bodyFramesEmpty61 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s600 a).isEmpty) = true
kernel_rfl bodyJsRoots61 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s599.next) PRE_first_tail_x8_r0_body.s601.trace PRE_first_tail_x8_r0_body.s601 = true
kernel_rfl bodyJsNative61 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s601.ffi) = true
kernel_rfl bodyLow61 : (PRE_first_tail_x8_r0_body.cws61 ++ PRE_first_tail_x8_r0_body.ws61).all (Nat.ble 9) = true
kernel_rfl bodyCntM61 : countersOkB PRE_first_tail_x8_r0_body.s599 PRE_first_tail_x8_r0_body.s600 = true
kernel_rfl bodyHi61 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s601.ffi).next setupP.E = true
kernel_rfl bodyNhi61 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s601.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge61 : bridgeOf PRE_first_tail_x8_r0_body.s600.ffi = bridgeOf PRE_first_tail_x8_r0_body.s599.ffi
kernel_rfl bodyNN61 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s599.ffi).nnext PRE_first_tail_x8_r0_body.P61.NL = true
kernel_rfl bodyXn61 : Nat.ble (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s601.ffi).next = true
kernel_rfl bodyLo61 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s601.ffi).next = true
theorem bodyFacts61 : BodySiteFacts PRE_first_tail_x8_r0_body.s599 PRE_first_tail_x8_r0_body.s600 PRE_first_tail_x8_r0_body.s601 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S599 PRE_first_tail_x8_r0_body.S600 PRE_first_tail_x8_r0_body.S601
    PRE_first_tail_x8_r0_body.ws61 PRE_first_tail_x8_r0_body.cws61 PRE_first_tail_x8_r0_body.nr61 PRE_first_tail_x8_r0_body.pl61 PRE_first_tail_x8_r0_body.cl61 2723045 2687 PRE_first_tail_x8_r0_body.kd61 PRE_first_tail_x8_r0_body.kappa61 PRE_first_tail_x8_r0_body.P61
    ⟨19412, 16503, 2723043, 2687⟩ ⟨19412, 16503, 2723043, 2687⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap61
  clean := bodyClean61
  cfix := PRE_first_tail_x8_r0_body.cfix61
  zpl := PRE_first_tail_x8_r0_body.zpl61
  zplnd := PRE_first_tail_x8_r0_body.zplnd61
  zn1 := PRE_first_tail_x8_r0_body.zn161
  zfirst := PRE_first_tail_x8_r0_body.zfirst61
  zscn := PRE_first_tail_x8_r0_body.zscn61
  zsmn := PRE_first_tail_x8_r0_body.zsmn61
  zgrow := PRE_first_tail_x8_r0_body.zgrow61
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab61
  zfresh := PRE_first_tail_x8_r0_body.zfresh61
  zcnd := PRE_first_tail_x8_r0_body.zcnd61
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi61
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt61
  zgP := PRE_first_tail_x8_r0_body.zg61_2665
  zkP := PRE_first_tail_x8_r0_body.zk61_2665
  zmP := PRE_first_tail_x8_r0_body.zm61_2665
  zgC := PRE_first_tail_x8_r0_body.zg61_2673467
  zkC := PRE_first_tail_x8_r0_body.zk61_2673467
  zmC := PRE_first_tail_x8_r0_body.zm61_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw61_2673472
  zwV := PRE_first_tail_x8_r0_body.zw61_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap61
  zclbd := PRE_first_tail_x8_r0_body.zclbd61
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap61 PRE_first_tail_x8_r0_body.stFoot61 PRE_first_tail_x8_r0_body.iso61 PRE_first_tail_x8_r0_body.zwr61
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP61
  csupp := PRE_first_tail_x8_r0_body.csupp61
  cbound := PRE_first_tail_x8_r0_body.cbound61
  zimg := PRE_first_tail_x8_r0_body.zimg61
  zctl := PRE_first_tail_x8_r0_body.zctl61
  zstack := PRE_first_tail_x8_r0_body.zstack61
  zjobs := PRE_first_tail_x8_r0_body.zjobs61
  zstores := PRE_first_tail_x8_r0_body.zstores61
  zroots := PRE_first_tail_x8_r0_body.zroots61
  znC := PRE_first_tail_x8_r0_body.znC61
  ctab := PRE_first_tail_x8_r0_body.ctab61
  zbin := PRE_first_tail_x8_r0_body.zbin61
  cbridge := PRE_first_tail_x8_r0_body.cbridge61
  sbridge := bodyBridge61
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj61
  cshiftR := fun h hNL => bodyCshift61 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN61
  raised := PRE_first_tail_x8_r0_body.raised61
  cbigs := PRE_first_tail_x8_r0_body.cbigs61
  cjcl := PRE_first_tail_x8_r0_body.cjcl61
  xnLe := Nat.le_of_ble_eq_true bodyXn61
  loLe := Nat.le_of_ble_eq_true bodyLo61
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB61
  cntM := bodyCntM61
  hiLe := Nat.le_of_ble_eq_true bodyHi61
  nhiLe := Nat.le_of_ble_eq_true bodyNhi61
  jsHeap := bodyJs61
  jsRoots := bodyJsRoots61
  jsNative := bodyJsNative61
  framesEmpty := bodyFramesEmpty61
  trailOld := by decide
  lowVars := bodyLow61

def bodyQs61 : List (Option Q) := []
noncomputable def bodyEs61 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr61.map fun r => nth? PRE_first_tail_x8_r0_body.st61.S2.tab r
kernel_rfl bodyResChk61 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs61 bodyQs61) = true
kernel_rfl bodyLq61 : bodyQs61.length = PRE_first_tail_x8_r0_body.cws61.length
kernel_rfl bodyNrLo61 : PRE_first_tail_x8_r0_body.nr61.all (Nat.ble PRE_first_tail_x8_r0_body.S599.tab.length) = true
kernel_rfl bodySub61 : (Oracles.PRE_first_tail_x8_r0_body.map_site61.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost61 : postSubB bodyM PRE_first_tail_x8_r0_body.ws61 PRE_first_tail_x8_r0_body.cws61 bodyQs61 = true
kernel_rfl bodyDrop61 : Nat.ble (24558 + (PRE_first_tail_x8_r0_body.s600.next - PRE_first_tail_x8_r0_body.s601.next)) 24560 = true
kernel_rfl bodyDropH61 : Nat.ble (431 + ((mlxOf PRE_first_tail_x8_r0_body.s600.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s601.ffi).next)) 431 = true
kernel_rfl bodyDropN61 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s600.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s601.ffi).nnext)) 0 = true
kernel_rfl bodyDv61 : bodyΘ.1.take 333 = bodyΘ.1.take 333 ++ PRE_first_tail_x8_r0_body.cws61
kernel_rfl bodyDe61 : bodyΘ.2.take 333 = bodyΘ.2.take 333 ++ PRE_first_tail_x8_r0_body.nr61.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st61.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 333) (bodyΘ.2.take 333)))
kernel_rfl bodyDl61 : (bodyΘ.1.take 333).length = (bodyΘ.2.take 333).length
kernel_rfl bodyDold61 : (bodyΘ.1.take 333).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws61).isNone && !PRE_first_tail_x8_r0_body.ws61.contains v) = true
kernel_rfl bodyDfree61 : (bodyΘ.2.take 333).all (fun e => (PRE_first_tail_x8_r0_body.cws61 ++ PRE_first_tail_x8_r0_body.ws61).all fun w => e.noVar w) = true

theorem bodyStep61 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24558, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s599 PRE_first_tail_x8_r0_body.S599)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24560, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s601 PRE_first_tail_x8_r0_body.S601) (27 + 1) :=
  bodySite bodyFacts61.cfix bodyFacts61.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x8_r0_body.st61.S2.tab) (Es := bodyEs61) (qs := bodyQs61)
    (ok := PRE_first_tail_x8_r0_body.st61.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site61 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts61
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site61 r hr) hi (MapOk.sub hm (sub_of_all bodySub61)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk61 r hr) hi hm ho hq)
    bodyLq61 rfl bodyNrLo61 (postSub_sound bodyPost61)
    (Nat.le_of_ble_eq_true bodyDrop61) (by decide) (Nat.le_of_ble_eq_true bodyDropH61) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN61) (by decide)
    bodyDv61 bodyDe61 bodyDl61 bodyDold61 bodyDfree61 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x8_r0_body.map_site62 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x8_r0_body.chk_site62 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site62) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site62
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s603 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s604 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S603 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws62 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso62
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_62
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot62
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup62
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound62
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace62
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged62
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws62.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st62.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S603.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_62]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen62.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh62
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl62 : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s603.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl62 (PRE_first_tail_x8_r0_body.cncl61 bodyNcl61)

theorem bodyClean62 : Conv.JClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s603 :=
  PRE_first_tail_x8_r0_body.gjcl62 (PRE_first_tail_x8_r0_body.cjcl61 bodyClean61)

kernel_rfl bodyJsLe62 : Nat.ble PRE_first_tail_x8_r0_body.s599.next PRE_first_tail_x8_r0_body.s603.next = true
kernel_rfl bodyJsList62 : (PRE_first_tail_x8_r0_body.gjh62 ++ PRE_first_tail_x8_r0_body.cl62).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s603.next) PRE_first_tail_x8_r0_body.s605) = true
theorem bodyJs62 : JsHeapAbove PRE_first_tail_x8_r0_body.s603.next PRE_first_tail_x8_r0_body.s605 :=
  JsHeapAbove.glueSite bodyJs61 (Nat.le_of_ble_eq_true bodyJsLe62) PRE_first_tail_x8_r0_body.gjk62 PRE_first_tail_x8_r0_body.gjbd62 PRE_first_tail_x8_r0_body.cheap62 PRE_first_tail_x8_r0_body.zclbd62 bodyJsList62

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO601 : PRE_first_tail_x8_r0_body.S601.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S601.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr601 : bridgeOf PRE_first_tail_x8_r0_body.s601.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc601 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s601 PRE_first_tail_x8_r0_body.S601) = fun _ _ => true
kernel_rfl bodyAcc602 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s602 PRE_first_tail_x8_r0_body.S602) = fun _ _ => true
kernel_rfl bodyBr603 : bridgeOf PRE_first_tail_x8_r0_body.s603.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt602 : isHalt PRE_first_tail_x8_r0_body.s602.ctl = false
kernel_rfl bodyTop603 : noRetBlock PRE_first_tail_x8_r0_body.s603 = true
kernel_rfl bodyCnt601 : countersOkB PRE_first_tail_x8_r0_body.s601 PRE_first_tail_x8_r0_body.s603 = true

theorem bodyGlue62 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24560, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s601 PRE_first_tail_x8_r0_body.S601)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24560, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s603 PRE_first_tail_x8_r0_body.S603) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24560, 431, 0, 333⟩) bodyAcc601 PRE_first_tail_x8_r0_body.bodyRunSeg162 bodyAcc602 bodyHalt602 PRE_first_tail_x8_r0_body.bodyStepA163 bodyTop603 (fun _ hm => bodyO601 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr601).trans bodyInactive0) (bodyBr603.trans bodyBr601.symm) bodyCnt601 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift62 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S603.tab.length PRE_first_tail_x8_r0_body.s603.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P62.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P62 2704 PRE_first_tail_x8_r0_body.kappa62 PRE_first_tail_x8_r0_body.s605.ffi PRE_first_tail_x8_r0_body.s604.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_62
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_62
  have hcl : SSt (· < 2704) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s605.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S603.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_62] <;> decide) PRE_first_tail_x8_r0_body.cnodesK62 PRE_first_tail_x8_r0_body.cobjsK62
      PRE_first_tail_x8_r0_body.citemsK62 PRE_first_tail_x8_r0_body.cbd62 PRE_first_tail_x8_r0_body.csst62
  exact PRE_first_tail_x8_r0_body.cshift62 bodyNcl62 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_62] at this; exact this)


kernel_rfl bodyFramesEmpty62 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s604 a).isEmpty) = true
kernel_rfl bodyJsRoots62 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s603.next) PRE_first_tail_x8_r0_body.s605.trace PRE_first_tail_x8_r0_body.s605 = true
kernel_rfl bodyJsNative62 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s605.ffi) = true
kernel_rfl bodyLow62 : (PRE_first_tail_x8_r0_body.cws62 ++ PRE_first_tail_x8_r0_body.ws62).all (Nat.ble 9) = true
kernel_rfl bodyCntM62 : countersOkB PRE_first_tail_x8_r0_body.s603 PRE_first_tail_x8_r0_body.s604 = true
kernel_rfl bodyHi62 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s605.ffi).next setupP.E = true
kernel_rfl bodyNhi62 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s605.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge62 : bridgeOf PRE_first_tail_x8_r0_body.s604.ffi = bridgeOf PRE_first_tail_x8_r0_body.s603.ffi
kernel_rfl bodyNN62 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s603.ffi).nnext PRE_first_tail_x8_r0_body.P62.NL = true
kernel_rfl bodyXn62 : Nat.ble (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s605.ffi).next = true
kernel_rfl bodyLo62 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s605.ffi).next = true
theorem bodyFacts62 : BodySiteFacts PRE_first_tail_x8_r0_body.s603 PRE_first_tail_x8_r0_body.s604 PRE_first_tail_x8_r0_body.s605 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S603 PRE_first_tail_x8_r0_body.S604 PRE_first_tail_x8_r0_body.S605
    PRE_first_tail_x8_r0_body.ws62 PRE_first_tail_x8_r0_body.cws62 PRE_first_tail_x8_r0_body.nr62 PRE_first_tail_x8_r0_body.pl62 PRE_first_tail_x8_r0_body.cl62 2723342 2704 PRE_first_tail_x8_r0_body.kd62 PRE_first_tail_x8_r0_body.kappa62 PRE_first_tail_x8_r0_body.P62
    ⟨19419, 16507, 2723331, 2704⟩ ⟨19419, 16507, 2723332, 2704⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap62
  clean := bodyClean62
  cfix := PRE_first_tail_x8_r0_body.cfix62
  zpl := PRE_first_tail_x8_r0_body.zpl62
  zplnd := PRE_first_tail_x8_r0_body.zplnd62
  zn1 := PRE_first_tail_x8_r0_body.zn162
  zfirst := PRE_first_tail_x8_r0_body.zfirst62
  zscn := PRE_first_tail_x8_r0_body.zscn62
  zsmn := PRE_first_tail_x8_r0_body.zsmn62
  zgrow := PRE_first_tail_x8_r0_body.zgrow62
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab62
  zfresh := PRE_first_tail_x8_r0_body.zfresh62
  zcnd := PRE_first_tail_x8_r0_body.zcnd62
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi62
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt62
  zgP := PRE_first_tail_x8_r0_body.zg62_2665
  zkP := PRE_first_tail_x8_r0_body.zk62_2665
  zmP := PRE_first_tail_x8_r0_body.zm62_2665
  zgC := PRE_first_tail_x8_r0_body.zg62_2673467
  zkC := PRE_first_tail_x8_r0_body.zk62_2673467
  zmC := PRE_first_tail_x8_r0_body.zm62_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw62_2673472
  zwV := PRE_first_tail_x8_r0_body.zw62_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap62
  zclbd := PRE_first_tail_x8_r0_body.zclbd62
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap62 PRE_first_tail_x8_r0_body.stFoot62 PRE_first_tail_x8_r0_body.iso62 PRE_first_tail_x8_r0_body.zwr62
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP62
  csupp := PRE_first_tail_x8_r0_body.csupp62
  cbound := PRE_first_tail_x8_r0_body.cbound62
  zimg := PRE_first_tail_x8_r0_body.zimg62
  zctl := PRE_first_tail_x8_r0_body.zctl62
  zstack := PRE_first_tail_x8_r0_body.zstack62
  zjobs := PRE_first_tail_x8_r0_body.zjobs62
  zstores := PRE_first_tail_x8_r0_body.zstores62
  zroots := PRE_first_tail_x8_r0_body.zroots62
  znC := PRE_first_tail_x8_r0_body.znC62
  ctab := PRE_first_tail_x8_r0_body.ctab62
  zbin := PRE_first_tail_x8_r0_body.zbin62
  cbridge := PRE_first_tail_x8_r0_body.cbridge62
  sbridge := bodyBridge62
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj62
  cshiftR := fun h hNL => bodyCshift62 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN62
  raised := PRE_first_tail_x8_r0_body.raised62
  cbigs := PRE_first_tail_x8_r0_body.cbigs62
  cjcl := PRE_first_tail_x8_r0_body.cjcl62
  xnLe := Nat.le_of_ble_eq_true bodyXn62
  loLe := Nat.le_of_ble_eq_true bodyLo62
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB62
  cntM := bodyCntM62
  hiLe := Nat.le_of_ble_eq_true bodyHi62
  nhiLe := Nat.le_of_ble_eq_true bodyNhi62
  jsHeap := bodyJs62
  jsRoots := bodyJsRoots62
  jsNative := bodyJsNative62
  framesEmpty := bodyFramesEmpty62
  trailOld := by decide
  lowVars := bodyLow62

def bodyQs62 : List (Option Q) := []
noncomputable def bodyEs62 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr62.map fun r => nth? PRE_first_tail_x8_r0_body.st62.S2.tab r
kernel_rfl bodyResChk62 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs62 bodyQs62) = true
kernel_rfl bodyLq62 : bodyQs62.length = PRE_first_tail_x8_r0_body.cws62.length
kernel_rfl bodyNrLo62 : PRE_first_tail_x8_r0_body.nr62.all (Nat.ble PRE_first_tail_x8_r0_body.S603.tab.length) = true
kernel_rfl bodySub62 : (Oracles.PRE_first_tail_x8_r0_body.map_site62.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost62 : postSubB bodyM PRE_first_tail_x8_r0_body.ws62 PRE_first_tail_x8_r0_body.cws62 bodyQs62 = true
kernel_rfl bodyDrop62 : Nat.ble (24560 + (PRE_first_tail_x8_r0_body.s604.next - PRE_first_tail_x8_r0_body.s605.next)) 24570 = true
kernel_rfl bodyDropH62 : Nat.ble (431 + ((mlxOf PRE_first_tail_x8_r0_body.s604.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s605.ffi).next)) 431 = true
kernel_rfl bodyDropN62 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s604.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s605.ffi).nnext)) 0 = true
kernel_rfl bodyDv62 : bodyΘ.1.take 333 = bodyΘ.1.take 333 ++ PRE_first_tail_x8_r0_body.cws62
kernel_rfl bodyDe62 : bodyΘ.2.take 333 = bodyΘ.2.take 333 ++ PRE_first_tail_x8_r0_body.nr62.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st62.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 333) (bodyΘ.2.take 333)))
kernel_rfl bodyDl62 : (bodyΘ.1.take 333).length = (bodyΘ.2.take 333).length
kernel_rfl bodyDold62 : (bodyΘ.1.take 333).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws62).isNone && !PRE_first_tail_x8_r0_body.ws62.contains v) = true
kernel_rfl bodyDfree62 : (bodyΘ.2.take 333).all (fun e => (PRE_first_tail_x8_r0_body.cws62 ++ PRE_first_tail_x8_r0_body.ws62).all fun w => e.noVar w) = true

theorem bodyStep62 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24560, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s603 PRE_first_tail_x8_r0_body.S603)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24570, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s605 PRE_first_tail_x8_r0_body.S605) (98 + 1) :=
  bodySite bodyFacts62.cfix bodyFacts62.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x8_r0_body.st62.S2.tab) (Es := bodyEs62) (qs := bodyQs62)
    (ok := PRE_first_tail_x8_r0_body.st62.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site62 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts62
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site62 r hr) hi (MapOk.sub hm (sub_of_all bodySub62)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk62 r hr) hi hm ho hq)
    bodyLq62 rfl bodyNrLo62 (postSub_sound bodyPost62)
    (Nat.le_of_ble_eq_true bodyDrop62) (by decide) (Nat.le_of_ble_eq_true bodyDropH62) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN62) (by decide)
    bodyDv62 bodyDe62 bodyDl62 bodyDold62 bodyDfree62 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodySite63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x8_r0_body.map_site63 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n), (1378, Q.n), (1379, Q.n), (1381, Q.n), (1383, Q.n), (1384, Q.n), (1385, Q.n), (1386, Q.n), (1423, Q.n), (1424, Q.n), (1426, Q.n), (1427, Q.n), (1428, Q.n), (1429, Q.n), (1430, Q.n), (1433, Q.n), (1434, Q.n), (1436, Q.n), (1437, Q.n), (1438, Q.n), (1439, Q.n), (1440, Q.n), (1477, Q.n), (1478, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1483, Q.n), (1484, Q.n), (1487, Q.n), (1488, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1493, Q.n), (1494, Q.n), (1531, Q.n), (1532, Q.n), (1534, Q.n), (1535, Q.n), (1536, Q.n), (1537, Q.n), (1538, Q.n), (1541, Q.n), (1542, Q.n), (1544, Q.n), (1545, Q.n), (1546, Q.n), (1547, Q.n), (1548, Q.n), (1571, Q.n), (1572, Q.n), (1574, Q.n), (1576, Q.n), (1577, Q.n), (1578, Q.n), (1579, Q.n), (1622, Q.n), (1623, Q.n), (1625, Q.n), (1626, Q.n), (1627, Q.n), (1628, Q.n), (1629, Q.n), (1632, Q.n), (1633, Q.n), (1635, Q.n), (1636, Q.n), (1637, Q.n), (1638, Q.n), (1639, Q.n), (1676, Q.n), (1677, Q.n), (1679, Q.n), (1680, Q.n), (1681, Q.n), (1682, Q.n), (1683, Q.n), (1686, Q.n), (1687, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1692, Q.n), (1693, Q.n), (1736, Q.n), (1737, Q.n), (1739, Q.n), (1740, Q.n), (1741, Q.n), (1742, Q.n), (1743, Q.n), (1746, Q.n), (1747, Q.n), (1749, Q.n), (1750, Q.n), (1751, Q.n), (1752, Q.n), (1753, Q.n), (1776, Q.n), (1777, Q.n), (1779, Q.n), (1781, Q.n), (1782, Q.n), (1783, Q.n), (1784, Q.n), (1827, Q.n), (1828, Q.n), (1830, Q.n), (1831, Q.n), (1832, Q.n), (1833, Q.n), (1834, Q.n), (1837, Q.n), (1838, Q.n), (1840, Q.n), (1841, Q.n), (1842, Q.n), (1843, Q.n), (1844, Q.n), (1887, Q.n), (1888, Q.n), (1890, Q.n), (1891, Q.n), (1892, Q.n), (1893, Q.n), (1894, Q.n), (1897, Q.n), (1898, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1904, Q.n), (1947, Q.n), (1948, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1953, Q.n), (1954, Q.n), (1957, Q.n), (1958, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1963, Q.n), (1964, Q.n), (1993, Q.n), (1994, Q.n), (1996, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2038, Q.n), (2039, Q.n), (2041, Q.n), (2042, Q.n), (2043, Q.n), (2044, Q.n), (2045, Q.n), (2048, Q.n), (2049, Q.n), (2051, Q.n), (2052, Q.n), (2053, Q.n), (2054, Q.n), (2055, Q.n)]

kernel_rfl PRE_first_tail_x8_r0_body.chk_site63 : ([first_tail_x8.r0, first_tail_x10.r0, first_tail_x12.r0, first_tail_x14.r0, first_tail_x16.r0, first_tail_x18.r0, first_tail_x20.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x8_r0_body.map_site63) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st63.S0.oracle) = true

noncomputable def PRE_first_tail_x8_r0_body.site63
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st63.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st63.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s620 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.s621 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S620 Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws63 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st63.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st63.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.iso63
  tab := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_63
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st63.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.stFoot63
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrNodup63
  bound := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.wrBound63
  trace := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.trace63
  merged := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.merged63
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.ws63.length = (Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.st63.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.S620.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.tab0_63]
    exact Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.mergeLen63.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x8_r0_body.fresh63
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl63 : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s620.ffi).mlx :=
  PRE_first_tail_x8_r0_body.gncl63 (PRE_first_tail_x8_r0_body.cncl62 bodyNcl62)

theorem bodyClean63 : Conv.JClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s620 :=
  PRE_first_tail_x8_r0_body.gjcl63 (PRE_first_tail_x8_r0_body.cjcl62 bodyClean62)

kernel_rfl bodyJsLe63 : Nat.ble PRE_first_tail_x8_r0_body.s603.next PRE_first_tail_x8_r0_body.s620.next = true
kernel_rfl bodyJsList63 : (PRE_first_tail_x8_r0_body.gjh63 ++ PRE_first_tail_x8_r0_body.cl63).all (noBigAtP (jsAboveB PRE_first_tail_x8_r0_body.s620.next) PRE_first_tail_x8_r0_body.s622) = true
theorem bodyJs63 : JsHeapAbove PRE_first_tail_x8_r0_body.s620.next PRE_first_tail_x8_r0_body.s622 :=
  JsHeapAbove.glueSite bodyJs62 (Nat.le_of_ble_eq_true bodyJsLe63) PRE_first_tail_x8_r0_body.gjk63 PRE_first_tail_x8_r0_body.gjbd63 PRE_first_tail_x8_r0_body.cheap63 PRE_first_tail_x8_r0_body.zclbd63 bodyJsList63

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyG63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO605 : PRE_first_tail_x8_r0_body.S605.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S605.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr605 : bridgeOf PRE_first_tail_x8_r0_body.s605.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyAcc605 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s605 PRE_first_tail_x8_r0_body.S605) = fun _ _ => true
kernel_rfl bodyAcc607 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s607 PRE_first_tail_x8_r0_body.S607) = fun _ _ => true
kernel_rfl bodyBr608 : bridgeOf PRE_first_tail_x8_r0_body.s608.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt607 : isHalt PRE_first_tail_x8_r0_body.s607.ctl = false
kernel_rfl bodyTop608 : noRetBlock PRE_first_tail_x8_r0_body.s608 = true
kernel_rfl bodyCnt605 : countersOkB PRE_first_tail_x8_r0_body.s605 PRE_first_tail_x8_r0_body.s608 = true
kernel_rfl bodyO608 : PRE_first_tail_x8_r0_body.S608.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S608.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr609 : bridgeOf PRE_first_tail_x8_r0_body.s609.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt608 : countersOkB PRE_first_tail_x8_r0_body.s608 PRE_first_tail_x8_r0_body.s609 = true
kernel_rfl bodyO609 : PRE_first_tail_x8_r0_body.S609.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S609.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc609 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s609 PRE_first_tail_x8_r0_body.S609) = fun _ _ => true
kernel_rfl bodyAcc610 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s610 PRE_first_tail_x8_r0_body.S610) = fun _ _ => true
kernel_rfl bodyBr611 : bridgeOf PRE_first_tail_x8_r0_body.s611.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt610 : isHalt PRE_first_tail_x8_r0_body.s610.ctl = false
kernel_rfl bodyTop611 : noRetBlock PRE_first_tail_x8_r0_body.s611 = true
kernel_rfl bodyCnt609 : countersOkB PRE_first_tail_x8_r0_body.s609 PRE_first_tail_x8_r0_body.s611 = true
kernel_rfl bodyO611 : PRE_first_tail_x8_r0_body.S611.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S611.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr612 : bridgeOf PRE_first_tail_x8_r0_body.s612.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt611 : countersOkB PRE_first_tail_x8_r0_body.s611 PRE_first_tail_x8_r0_body.s612 = true
kernel_rfl bodyO612 : PRE_first_tail_x8_r0_body.S612.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S612.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc612 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s612 PRE_first_tail_x8_r0_body.S612) = fun _ _ => true
kernel_rfl bodyAcc613 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s613 PRE_first_tail_x8_r0_body.S613) = fun _ _ => true
kernel_rfl bodyBr614 : bridgeOf PRE_first_tail_x8_r0_body.s614.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt613 : isHalt PRE_first_tail_x8_r0_body.s613.ctl = false
kernel_rfl bodyTop614 : noRetBlock PRE_first_tail_x8_r0_body.s614 = true
kernel_rfl bodyCnt612 : countersOkB PRE_first_tail_x8_r0_body.s612 PRE_first_tail_x8_r0_body.s614 = true
kernel_rfl bodyO614 : PRE_first_tail_x8_r0_body.S614.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S614.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr615 : bridgeOf PRE_first_tail_x8_r0_body.s615.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt614 : countersOkB PRE_first_tail_x8_r0_body.s614 PRE_first_tail_x8_r0_body.s615 = true
kernel_rfl bodyO615 : PRE_first_tail_x8_r0_body.S615.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S615.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc615 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s615 PRE_first_tail_x8_r0_body.S615) = fun _ _ => true
kernel_rfl bodyAcc616 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s616 PRE_first_tail_x8_r0_body.S616) = fun _ _ => true
kernel_rfl bodyBr617 : bridgeOf PRE_first_tail_x8_r0_body.s617.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt616 : isHalt PRE_first_tail_x8_r0_body.s616.ctl = false
kernel_rfl bodyTop617 : noRetBlock PRE_first_tail_x8_r0_body.s617 = true
kernel_rfl bodyCnt615 : countersOkB PRE_first_tail_x8_r0_body.s615 PRE_first_tail_x8_r0_body.s617 = true
kernel_rfl bodyO617 : PRE_first_tail_x8_r0_body.S617.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S617.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyBr618 : bridgeOf PRE_first_tail_x8_r0_body.s618.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyCnt617 : countersOkB PRE_first_tail_x8_r0_body.s617 PRE_first_tail_x8_r0_body.s618 = true
kernel_rfl bodyO618 : PRE_first_tail_x8_r0_body.S618.oracle = List.drop (PRE_first_tail_x8_r0_body.OR.length - PRE_first_tail_x8_r0_body.S618.oracle.length) PRE_first_tail_x8_r0_body.OR
kernel_rfl bodyAcc618 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s618 PRE_first_tail_x8_r0_body.S618) = fun _ _ => true
kernel_rfl bodyAcc619 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x8_r0_body.s619 PRE_first_tail_x8_r0_body.S619) = fun _ _ => true
kernel_rfl bodyBr620 : bridgeOf PRE_first_tail_x8_r0_body.s620.ffi = bridgeOf PRE_first_tail_x8_r0_body.s0.ffi
kernel_rfl bodyHalt619 : isHalt PRE_first_tail_x8_r0_body.s619.ctl = false
kernel_rfl bodyTop620 : noRetBlock PRE_first_tail_x8_r0_body.s620 = true
kernel_rfl bodyCnt618 : countersOkB PRE_first_tail_x8_r0_body.s618 PRE_first_tail_x8_r0_body.s620 = true

theorem bodyGlue63 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24570, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s605 PRE_first_tail_x8_r0_body.S605)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24570, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s620 PRE_first_tail_x8_r0_body.S620) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) bodyAcc605 PRE_first_tail_x8_r0_body.bodyRunSeg163 bodyAcc607 bodyHalt607 PRE_first_tail_x8_r0_body.bodyStepA164 bodyTop608 (fun _ hm => bodyO605 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr605).trans bodyInactive0) (bodyBr608.trans bodyBr605.symm) bodyCnt605 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) PRE_first_tail_x8_r0_body.sizeA164 PRE_first_tail_x8_r0_body.sizeArgsA164 PRE_first_tail_x8_r0_body.sizeSymA164 PRE_first_tail_x8_r0_body.sizeMlxA164 PRE_first_tail_x8_r0_body.sizePayA164 PRE_first_tail_x8_r0_body.sizeTaA164 PRE_first_tail_x8_r0_body.sizeDecA164 PRE_first_tail_x8_r0_body.sizePreA164 PRE_first_tail_x8_r0_body.bodyPatchB164 (fun _ hm => bodyO608 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr608).trans bodyInactive0) (bodyBr609.trans bodyBr608.symm) bodyCnt608 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) bodyAcc609 PRE_first_tail_x8_r0_body.bodyRunSeg164 bodyAcc610 bodyHalt610 PRE_first_tail_x8_r0_body.bodyStepA165 bodyTop611 (fun _ hm => bodyO609 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr609).trans bodyInactive0) (bodyBr611.trans bodyBr609.symm) bodyCnt609 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) PRE_first_tail_x8_r0_body.sizeA165 PRE_first_tail_x8_r0_body.sizeArgsA165 PRE_first_tail_x8_r0_body.sizeSymA165 PRE_first_tail_x8_r0_body.sizeMlxA165 PRE_first_tail_x8_r0_body.sizePayA165 PRE_first_tail_x8_r0_body.sizeTaA165 PRE_first_tail_x8_r0_body.sizeDecA165 PRE_first_tail_x8_r0_body.sizePreA165 PRE_first_tail_x8_r0_body.bodyPatchB165 (fun _ hm => bodyO611 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr611).trans bodyInactive0) (bodyBr612.trans bodyBr611.symm) bodyCnt611 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) bodyAcc612 PRE_first_tail_x8_r0_body.bodyRunSeg165 bodyAcc613 bodyHalt613 PRE_first_tail_x8_r0_body.bodyStepA166 bodyTop614 (fun _ hm => bodyO612 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr612).trans bodyInactive0) (bodyBr614.trans bodyBr612.symm) bodyCnt612 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) PRE_first_tail_x8_r0_body.sizeA166 PRE_first_tail_x8_r0_body.sizeArgsA166 PRE_first_tail_x8_r0_body.sizeSymA166 PRE_first_tail_x8_r0_body.sizeMlxA166 PRE_first_tail_x8_r0_body.sizePayA166 PRE_first_tail_x8_r0_body.sizeTaA166 PRE_first_tail_x8_r0_body.sizeDecA166 PRE_first_tail_x8_r0_body.sizePreA166 PRE_first_tail_x8_r0_body.bodyPatchB166 (fun _ hm => bodyO614 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr614).trans bodyInactive0) (bodyBr615.trans bodyBr614.symm) bodyCnt614 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) bodyAcc615 PRE_first_tail_x8_r0_body.bodyRunSeg166 bodyAcc616 bodyHalt616 PRE_first_tail_x8_r0_body.bodyStepA167 bodyTop617 (fun _ hm => bodyO615 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr615).trans bodyInactive0) (bodyBr617.trans bodyBr615.symm) bodyCnt615 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) PRE_first_tail_x8_r0_body.sizeA167 PRE_first_tail_x8_r0_body.sizeArgsA167 PRE_first_tail_x8_r0_body.sizeSymA167 PRE_first_tail_x8_r0_body.sizeMlxA167 PRE_first_tail_x8_r0_body.sizePayA167 PRE_first_tail_x8_r0_body.sizeTaA167 PRE_first_tail_x8_r0_body.sizeDecA167 PRE_first_tail_x8_r0_body.sizePreA167 PRE_first_tail_x8_r0_body.bodyPatchB167 (fun _ hm => bodyO617 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr617).trans bodyInactive0) (bodyBr618.trans bodyBr617.symm) bodyCnt617 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24570, 431, 0, 333⟩) bodyAcc618 PRE_first_tail_x8_r0_body.bodyRunSeg167 bodyAcc619 bodyHalt619 PRE_first_tail_x8_r0_body.bodyStepA168 bodyTop620 (fun _ hm => bodyO618 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr618).trans bodyInactive0) (bodyBr620.trans bodyBr618.symm) bodyCnt618 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW8

end

section -- VWBodyS63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift63 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x8_r0_body.S620.tab.length PRE_first_tail_x8_r0_body.s620.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x8_r0_body.P63.NL) : Conv.FullShiftQ PRE_first_tail_x8_r0_body.P63 2795 PRE_first_tail_x8_r0_body.kappa63 PRE_first_tail_x8_r0_body.s622.ffi PRE_first_tail_x8_r0_body.s621.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x8_r0_body.ofxC_63
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x8_r0_body.okrC_63
  have hcl : SSt (· < 2795) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s622.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x8_r0_body.S620.tab.length) hr.cl (by rw [PRE_first_tail_x8_r0_body.n0_63] <;> decide) PRE_first_tail_x8_r0_body.cnodesK63 PRE_first_tail_x8_r0_body.cobjsK63
      PRE_first_tail_x8_r0_body.citemsK63 PRE_first_tail_x8_r0_body.cbd63 PRE_first_tail_x8_r0_body.csst63
  exact PRE_first_tail_x8_r0_body.cshift63 bodyNcl63 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x8_r0_body.n0_63] at this; exact this)


kernel_rfl bodyFramesEmpty63 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x8_r0_body.s621 a).isEmpty) = true
kernel_rfl bodyJsRoots63 : noBigRootsP (jsAboveB PRE_first_tail_x8_r0_body.s620.next) PRE_first_tail_x8_r0_body.s622.trace PRE_first_tail_x8_r0_body.s622 = true
kernel_rfl bodyJsNative63 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x8_r0_body.s622.ffi) = true
kernel_rfl bodyLow63 : (PRE_first_tail_x8_r0_body.cws63 ++ PRE_first_tail_x8_r0_body.ws63).all (Nat.ble 9) = true
kernel_rfl bodyCntM63 : countersOkB PRE_first_tail_x8_r0_body.s620 PRE_first_tail_x8_r0_body.s621 = true
kernel_rfl bodyHi63 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s622.ffi).next setupP.E = true
kernel_rfl bodyNhi63 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s622.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge63 : bridgeOf PRE_first_tail_x8_r0_body.s621.ffi = bridgeOf PRE_first_tail_x8_r0_body.s620.ffi
kernel_rfl bodyNN63 : Nat.ble (mlxOf PRE_first_tail_x8_r0_body.s620.ffi).nnext PRE_first_tail_x8_r0_body.P63.NL = true
kernel_rfl bodyXn63 : Nat.ble (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x8_r0_body.s622.ffi).next = true
kernel_rfl bodyLo63 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x8_r0_body.s622.ffi).next = true
theorem bodyFacts63 : BodySiteFacts PRE_first_tail_x8_r0_body.s620 PRE_first_tail_x8_r0_body.s621 PRE_first_tail_x8_r0_body.s622 PRE_first_tail_x8_r0_body.s0 PRE_first_tail_x8_r0_body.S620 PRE_first_tail_x8_r0_body.S621 PRE_first_tail_x8_r0_body.S622
    PRE_first_tail_x8_r0_body.ws63 PRE_first_tail_x8_r0_body.cws63 PRE_first_tail_x8_r0_body.nr63 PRE_first_tail_x8_r0_body.pl63 PRE_first_tail_x8_r0_body.cl63 2725958 2795 PRE_first_tail_x8_r0_body.kd63 PRE_first_tail_x8_r0_body.kappa63 PRE_first_tail_x8_r0_body.P63
    ⟨19453, 16526, 2724803, 2777⟩ ⟨19456, 16553, 2724809, 2795⟩ where
  zkap := PRE_first_tail_x8_r0_body.zkap63
  clean := bodyClean63
  cfix := PRE_first_tail_x8_r0_body.cfix63
  zpl := PRE_first_tail_x8_r0_body.zpl63
  zplnd := PRE_first_tail_x8_r0_body.zplnd63
  zn1 := PRE_first_tail_x8_r0_body.zn163
  zfirst := PRE_first_tail_x8_r0_body.zfirst63
  zscn := PRE_first_tail_x8_r0_body.zscn63
  zsmn := PRE_first_tail_x8_r0_body.zsmn63
  zgrow := PRE_first_tail_x8_r0_body.zgrow63
  mergeTab := PRE_first_tail_x8_r0_body.mergeTab63
  zfresh := PRE_first_tail_x8_r0_body.zfresh63
  zcnd := PRE_first_tail_x8_r0_body.zcnd63
  lenc := by rfl
  znrHi := PRE_first_tail_x8_r0_body.znrHi63
  zfrlt := PRE_first_tail_x8_r0_body.zfrlt63
  zgP := PRE_first_tail_x8_r0_body.zg63_2665
  zkP := PRE_first_tail_x8_r0_body.zk63_2665
  zmP := PRE_first_tail_x8_r0_body.zm63_2665
  zgC := PRE_first_tail_x8_r0_body.zg63_2673467
  zkC := PRE_first_tail_x8_r0_body.zk63_2673467
  zmC := PRE_first_tail_x8_r0_body.zm63_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x8_r0_body.zw63_2673472
  zwV := PRE_first_tail_x8_r0_body.zw63_2673473
  cheap := PRE_first_tail_x8_r0_body.cheap63
  zclbd := PRE_first_tail_x8_r0_body.zclbd63
  hml := hoff_of PRE_first_tail_x8_r0_body.mheap63 PRE_first_tail_x8_r0_body.stFoot63 PRE_first_tail_x8_r0_body.iso63 PRE_first_tail_x8_r0_body.zwr63
  ckeepP := PRE_first_tail_x8_r0_body.ckeepP63
  csupp := PRE_first_tail_x8_r0_body.csupp63
  cbound := PRE_first_tail_x8_r0_body.cbound63
  zimg := PRE_first_tail_x8_r0_body.zimg63
  zctl := PRE_first_tail_x8_r0_body.zctl63
  zstack := PRE_first_tail_x8_r0_body.zstack63
  zjobs := PRE_first_tail_x8_r0_body.zjobs63
  zstores := PRE_first_tail_x8_r0_body.zstores63
  zroots := PRE_first_tail_x8_r0_body.zroots63
  znC := PRE_first_tail_x8_r0_body.znC63
  ctab := PRE_first_tail_x8_r0_body.ctab63
  zbin := PRE_first_tail_x8_r0_body.zbin63
  cbridge := PRE_first_tail_x8_r0_body.cbridge63
  sbridge := bodyBridge63
  cwsDisj := PRE_first_tail_x8_r0_body.cwsDisj63
  cshiftR := fun h hNL => bodyCshift63 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN63
  raised := PRE_first_tail_x8_r0_body.raised63
  cbigs := PRE_first_tail_x8_r0_body.cbigs63
  cjcl := PRE_first_tail_x8_r0_body.cjcl63
  xnLe := Nat.le_of_ble_eq_true bodyXn63
  loLe := Nat.le_of_ble_eq_true bodyLo63
  zroots2 := PRE_first_tail_x8_r0_body.zrootsB63
  cntM := bodyCntM63
  hiLe := Nat.le_of_ble_eq_true bodyHi63
  nhiLe := Nat.le_of_ble_eq_true bodyNhi63
  jsHeap := bodyJs63
  jsRoots := bodyJsRoots63
  jsNative := bodyJsNative63
  framesEmpty := bodyFramesEmpty63
  trailOld := by decide
  lowVars := bodyLow63

def bodyQs63 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs63 : List (Option SymE) := PRE_first_tail_x8_r0_body.nr63.map fun r => nth? PRE_first_tail_x8_r0_body.st63.S5.tab r
kernel_rfl bodyResChk63 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs63 bodyQs63) = true
kernel_rfl bodyLq63 : bodyQs63.length = PRE_first_tail_x8_r0_body.cws63.length
kernel_rfl bodyNrLo63 : PRE_first_tail_x8_r0_body.nr63.all (Nat.ble PRE_first_tail_x8_r0_body.S620.tab.length) = true
kernel_rfl bodySub63 : (Oracles.PRE_first_tail_x8_r0_body.map_site63.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost63 : postSubB bodyM PRE_first_tail_x8_r0_body.ws63 PRE_first_tail_x8_r0_body.cws63 bodyQs63 = true
kernel_rfl bodyDrop63 : Nat.ble (24570 + (PRE_first_tail_x8_r0_body.s621.next - PRE_first_tail_x8_r0_body.s622.next)) 25719 = true
kernel_rfl bodyDropH63 : Nat.ble (431 + ((mlxOf PRE_first_tail_x8_r0_body.s621.ffi).next - (mlxOf PRE_first_tail_x8_r0_body.s622.ffi).next)) 456 = true
kernel_rfl bodyDropN63 : Nat.ble (0 + ((mlxOf PRE_first_tail_x8_r0_body.s621.ffi).nnext - (mlxOf PRE_first_tail_x8_r0_body.s622.ffi).nnext)) 0 = true
kernel_rfl bodyDv63 : bodyΘ.1.take 351 = bodyΘ.1.take 333 ++ PRE_first_tail_x8_r0_body.cws63
kernel_rfl bodyDe63 : bodyΘ.2.take 351 = bodyΘ.2.take 333 ++ PRE_first_tail_x8_r0_body.nr63.map (fun r =>
  ((nth? PRE_first_tail_x8_r0_body.st63.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 333) (bodyΘ.2.take 333)))
kernel_rfl bodyDl63 : (bodyΘ.1.take 333).length = (bodyΘ.2.take 333).length
kernel_rfl bodyDold63 : (bodyΘ.1.take 333).all (fun v => (Conv.idx? v PRE_first_tail_x8_r0_body.cws63).isNone && !PRE_first_tail_x8_r0_body.ws63.contains v) = true
kernel_rfl bodyDfree63 : (bodyΘ.2.take 351).all (fun e => (PRE_first_tail_x8_r0_body.cws63 ++ PRE_first_tail_x8_r0_body.ws63).all fun w => e.noVar w) = true

theorem bodyStep63 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24570, 431, 0, 333⟩ bodyM PRE_first_tail_x8_r0_body.s620 PRE_first_tail_x8_r0_body.S620)
      (bodyCut NB T tk π i x0 bodyΘ ⟨25719, 456, 0, 351⟩ bodyM PRE_first_tail_x8_r0_body.s622 PRE_first_tail_x8_r0_body.S622) (11334 + 1) :=
  bodySite bodyFacts63.cfix bodyFacts63.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x8_r0_body.st63.S5.tab) (Es := bodyEs63) (qs := bodyQs63)
    (ok := PRE_first_tail_x8_r0_body.st63.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x8_r0_body.site63 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts63
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x8_r0_body.chk_site63 r hr) hi (MapOk.sub hm (sub_of_all bodySub63)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk63 r hr) hi hm ho hq)
    bodyLq63 rfl bodyNrLo63 (postSub_sound bodyPost63)
    (Nat.le_of_ble_eq_true bodyDrop63) (by decide) (Nat.le_of_ble_eq_true bodyDropH63) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN63) (by decide)
    bodyDv63 bodyDe63 bodyDl63 bodyDold63 bodyDfree63 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW8

end
