import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x1_r0_body.States
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B16
import host.sim.compose.a4b.x1.B1
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B23
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.x1.VWBodyChain
import host.sim.compose.a4b.x1.VWBodyMap
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B13
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B00
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B17

section -- VWBodyOracles_4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_g16 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g16 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g16) (List.take 35 (List.drop 551 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site16 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site16 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site16) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st16.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g17 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g17 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g17) (List.take 32 (List.drop 586 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site17 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site17 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site17) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st17.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g18 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g18 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g18) (List.take 32 (List.drop 618 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site18 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site18 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site18) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st18.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g19 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g19 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g19) (List.take 43 (List.drop 650 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site19 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site19 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site19) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st19.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site16 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site16 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site16) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st16.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site16
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st16.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st16.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s365 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s366 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S365 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws16 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st16.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st16.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso16
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_16
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st16.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot16
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup16
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound16
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace16
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged16
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws16.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st16.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S365.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_16]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen16.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh16
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl16 : Conv.NClean (⟨19163, 16226, 2713095, 1931⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s365.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl16 (PRE_first_tail_x1_r0_body.cncl15 bodyNcl15)

theorem bodyClean16 : Conv.JClean (⟨19163, 16226, 2713095, 1931⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s365 :=
  PRE_first_tail_x1_r0_body.gjcl16 (PRE_first_tail_x1_r0_body.cjcl15 bodyClean15)

kernel_rfl bodyJsLe16 : Nat.ble PRE_first_tail_x1_r0_body.s343.next PRE_first_tail_x1_r0_body.s365.next = true
kernel_rfl bodyJsList16 : (PRE_first_tail_x1_r0_body.gjh16 ++ PRE_first_tail_x1_r0_body.cl16).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s365.next) PRE_first_tail_x1_r0_body.s367) = true
theorem bodyJs16 : JsHeapAbove PRE_first_tail_x1_r0_body.s365.next PRE_first_tail_x1_r0_body.s367 :=
  JsHeapAbove.glueSite bodyJs15 (Nat.le_of_ble_eq_true bodyJsLe16) PRE_first_tail_x1_r0_body.gjk16 PRE_first_tail_x1_r0_body.gjbd16 PRE_first_tail_x1_r0_body.cheap16 PRE_first_tail_x1_r0_body.zclbd16 bodyJsList16

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO345 : PRE_first_tail_x1_r0_body.S345.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S345.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr345 : bridgeOf PRE_first_tail_x1_r0_body.s345.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc345 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s345 PRE_first_tail_x1_r0_body.S345) = fun _ _ => true
kernel_rfl bodyAcc346 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s346 PRE_first_tail_x1_r0_body.S346) = fun _ _ => true
kernel_rfl bodyBr347 : bridgeOf PRE_first_tail_x1_r0_body.s347.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt346 : isHalt PRE_first_tail_x1_r0_body.s346.ctl = false
kernel_rfl bodyTop347 : noRetBlock PRE_first_tail_x1_r0_body.s347 = true
kernel_rfl bodyCnt345 : countersOkB PRE_first_tail_x1_r0_body.s345 PRE_first_tail_x1_r0_body.s347 = true
kernel_rfl bodyO347 : PRE_first_tail_x1_r0_body.S347.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S347.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr348 : bridgeOf PRE_first_tail_x1_r0_body.s348.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt347 : countersOkB PRE_first_tail_x1_r0_body.s347 PRE_first_tail_x1_r0_body.s348 = true
kernel_rfl bodyO348 : PRE_first_tail_x1_r0_body.S348.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S348.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc348 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s348 PRE_first_tail_x1_r0_body.S348) = fun _ _ => true
kernel_rfl bodyAcc352 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s352 PRE_first_tail_x1_r0_body.S352) = fun _ _ => true
kernel_rfl bodyBr353 : bridgeOf PRE_first_tail_x1_r0_body.s353.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt352 : isHalt PRE_first_tail_x1_r0_body.s352.ctl = false
kernel_rfl bodyTop353 : noRetBlock PRE_first_tail_x1_r0_body.s353 = true
kernel_rfl bodyCnt348 : countersOkB PRE_first_tail_x1_r0_body.s348 PRE_first_tail_x1_r0_body.s353 = true
kernel_rfl bodyO353 : PRE_first_tail_x1_r0_body.S353.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S353.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr354 : bridgeOf PRE_first_tail_x1_r0_body.s354.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt353 : countersOkB PRE_first_tail_x1_r0_body.s353 PRE_first_tail_x1_r0_body.s354 = true
kernel_rfl bodyO354 : PRE_first_tail_x1_r0_body.S354.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S354.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc354 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s354 PRE_first_tail_x1_r0_body.S354) = fun _ _ => true
kernel_rfl bodyAcc355 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s355 PRE_first_tail_x1_r0_body.S355) = fun _ _ => true
kernel_rfl bodyBr356 : bridgeOf PRE_first_tail_x1_r0_body.s356.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt355 : isHalt PRE_first_tail_x1_r0_body.s355.ctl = false
kernel_rfl bodyTop356 : noRetBlock PRE_first_tail_x1_r0_body.s356 = true
kernel_rfl bodyCnt354 : countersOkB PRE_first_tail_x1_r0_body.s354 PRE_first_tail_x1_r0_body.s356 = true
kernel_rfl bodyO356 : PRE_first_tail_x1_r0_body.S356.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S356.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr357 : bridgeOf PRE_first_tail_x1_r0_body.s357.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt356 : countersOkB PRE_first_tail_x1_r0_body.s356 PRE_first_tail_x1_r0_body.s357 = true
kernel_rfl bodyO357 : PRE_first_tail_x1_r0_body.S357.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S357.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc357 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s357 PRE_first_tail_x1_r0_body.S357) = fun _ _ => true
kernel_rfl bodyAcc358 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s358 PRE_first_tail_x1_r0_body.S358) = fun _ _ => true
kernel_rfl bodyBr359 : bridgeOf PRE_first_tail_x1_r0_body.s359.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt358 : isHalt PRE_first_tail_x1_r0_body.s358.ctl = false
kernel_rfl bodyTop359 : noRetBlock PRE_first_tail_x1_r0_body.s359 = true
kernel_rfl bodyCnt357 : countersOkB PRE_first_tail_x1_r0_body.s357 PRE_first_tail_x1_r0_body.s359 = true
kernel_rfl bodyO359 : PRE_first_tail_x1_r0_body.S359.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S359.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr360 : bridgeOf PRE_first_tail_x1_r0_body.s360.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt359 : countersOkB PRE_first_tail_x1_r0_body.s359 PRE_first_tail_x1_r0_body.s360 = true
kernel_rfl bodyO360 : PRE_first_tail_x1_r0_body.S360.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S360.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc360 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s360 PRE_first_tail_x1_r0_body.S360) = fun _ _ => true
kernel_rfl bodyAcc361 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s361 PRE_first_tail_x1_r0_body.S361) = fun _ _ => true
kernel_rfl bodyBr362 : bridgeOf PRE_first_tail_x1_r0_body.s362.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt361 : isHalt PRE_first_tail_x1_r0_body.s361.ctl = false
kernel_rfl bodyTop362 : noRetBlock PRE_first_tail_x1_r0_body.s362 = true
kernel_rfl bodyCnt360 : countersOkB PRE_first_tail_x1_r0_body.s360 PRE_first_tail_x1_r0_body.s362 = true
kernel_rfl bodyO362 : PRE_first_tail_x1_r0_body.S362.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S362.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr363 : bridgeOf PRE_first_tail_x1_r0_body.s363.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt362 : countersOkB PRE_first_tail_x1_r0_body.s362 PRE_first_tail_x1_r0_body.s363 = true
kernel_rfl bodyO363 : PRE_first_tail_x1_r0_body.S363.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S363.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc363 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s363 PRE_first_tail_x1_r0_body.S363) = fun _ _ => true
kernel_rfl bodyAcc364 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s364 PRE_first_tail_x1_r0_body.S364) = fun _ _ => true
kernel_rfl bodyBr365 : bridgeOf PRE_first_tail_x1_r0_body.s365.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt364 : isHalt PRE_first_tail_x1_r0_body.s364.ctl = false
kernel_rfl bodyTop365 : noRetBlock PRE_first_tail_x1_r0_body.s365 = true
kernel_rfl bodyCnt363 : countersOkB PRE_first_tail_x1_r0_body.s363 PRE_first_tail_x1_r0_body.s365 = true

theorem bodyGlue16 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19302, 329, 0, 252⟩ bodyM PRE_first_tail_x1_r0_body.s345 PRE_first_tail_x1_r0_body.S345)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19302, 329, 0, 252⟩ bodyM PRE_first_tail_x1_r0_body.s365 PRE_first_tail_x1_r0_body.S365) 23510 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) bodyAcc345 PRE_first_tail_x1_r0_body.bodyRunSeg91 bodyAcc346 bodyHalt346 PRE_first_tail_x1_r0_body.bodyStepA92 bodyTop347 (fun _ hm => bodyO345 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr345).trans bodyInactive0) (bodyBr347.trans bodyBr345.symm) bodyCnt345 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) PRE_first_tail_x1_r0_body.sizeA92 PRE_first_tail_x1_r0_body.sizeArgsA92 PRE_first_tail_x1_r0_body.sizeSymA92 PRE_first_tail_x1_r0_body.sizeMlxA92 PRE_first_tail_x1_r0_body.sizePayA92 PRE_first_tail_x1_r0_body.sizeTaA92 PRE_first_tail_x1_r0_body.sizeDecA92 PRE_first_tail_x1_r0_body.sizePreA92 PRE_first_tail_x1_r0_body.bodyPatchB92 (fun _ hm => bodyO347 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr347).trans bodyInactive0) (bodyBr348.trans bodyBr347.symm) bodyCnt347 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) bodyAcc348 PRE_first_tail_x1_r0_body.bodyRunSeg92 bodyAcc352 bodyHalt352 PRE_first_tail_x1_r0_body.bodyStepA93 bodyTop353 (fun _ hm => bodyO348 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr348).trans bodyInactive0) (bodyBr353.trans bodyBr348.symm) bodyCnt348 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) PRE_first_tail_x1_r0_body.sizeA93 PRE_first_tail_x1_r0_body.sizeArgsA93 PRE_first_tail_x1_r0_body.sizeSymA93 PRE_first_tail_x1_r0_body.sizeMlxA93 PRE_first_tail_x1_r0_body.sizePayA93 PRE_first_tail_x1_r0_body.sizeTaA93 PRE_first_tail_x1_r0_body.sizeDecA93 PRE_first_tail_x1_r0_body.sizePreA93 PRE_first_tail_x1_r0_body.bodyPatchB93 (fun _ hm => bodyO353 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr353).trans bodyInactive0) (bodyBr354.trans bodyBr353.symm) bodyCnt353 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) bodyAcc354 PRE_first_tail_x1_r0_body.bodyRunSeg93 bodyAcc355 bodyHalt355 PRE_first_tail_x1_r0_body.bodyStepA94 bodyTop356 (fun _ hm => bodyO354 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr354).trans bodyInactive0) (bodyBr356.trans bodyBr354.symm) bodyCnt354 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) PRE_first_tail_x1_r0_body.sizeA94 PRE_first_tail_x1_r0_body.sizeArgsA94 PRE_first_tail_x1_r0_body.sizeSymA94 PRE_first_tail_x1_r0_body.sizeMlxA94 PRE_first_tail_x1_r0_body.sizePayA94 PRE_first_tail_x1_r0_body.sizeTaA94 PRE_first_tail_x1_r0_body.sizeDecA94 PRE_first_tail_x1_r0_body.sizePreA94 PRE_first_tail_x1_r0_body.bodyPatchB94 (fun _ hm => bodyO356 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr356).trans bodyInactive0) (bodyBr357.trans bodyBr356.symm) bodyCnt356 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) bodyAcc357 PRE_first_tail_x1_r0_body.bodyRunSeg94 bodyAcc358 bodyHalt358 PRE_first_tail_x1_r0_body.bodyStepA95 bodyTop359 (fun _ hm => bodyO357 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr357).trans bodyInactive0) (bodyBr359.trans bodyBr357.symm) bodyCnt357 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) PRE_first_tail_x1_r0_body.sizeA95 PRE_first_tail_x1_r0_body.sizeArgsA95 PRE_first_tail_x1_r0_body.sizeSymA95 PRE_first_tail_x1_r0_body.sizeMlxA95 PRE_first_tail_x1_r0_body.sizePayA95 PRE_first_tail_x1_r0_body.sizeTaA95 PRE_first_tail_x1_r0_body.sizeDecA95 PRE_first_tail_x1_r0_body.sizePreA95 PRE_first_tail_x1_r0_body.bodyPatchB95 (fun _ hm => bodyO359 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr359).trans bodyInactive0) (bodyBr360.trans bodyBr359.symm) bodyCnt359 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) bodyAcc360 PRE_first_tail_x1_r0_body.bodyRunSeg95 bodyAcc361 bodyHalt361 PRE_first_tail_x1_r0_body.bodyStepA96 bodyTop362 (fun _ hm => bodyO360 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr360).trans bodyInactive0) (bodyBr362.trans bodyBr360.symm) bodyCnt360 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) PRE_first_tail_x1_r0_body.sizeA96 PRE_first_tail_x1_r0_body.sizeArgsA96 PRE_first_tail_x1_r0_body.sizeSymA96 PRE_first_tail_x1_r0_body.sizeMlxA96 PRE_first_tail_x1_r0_body.sizePayA96 PRE_first_tail_x1_r0_body.sizeTaA96 PRE_first_tail_x1_r0_body.sizeDecA96 PRE_first_tail_x1_r0_body.sizePreA96 PRE_first_tail_x1_r0_body.bodyPatchB96 (fun _ hm => bodyO362 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr362).trans bodyInactive0) (bodyBr363.trans bodyBr362.symm) bodyCnt362 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19302, 329, 0, 252⟩) bodyAcc363 PRE_first_tail_x1_r0_body.bodyRunSeg96 bodyAcc364 bodyHalt364 PRE_first_tail_x1_r0_body.bodyStepA97 bodyTop365 (fun _ hm => bodyO363 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr363).trans bodyInactive0) (bodyBr365.trans bodyBr363.symm) bodyCnt363 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift16 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S365.tab.length PRE_first_tail_x1_r0_body.s365.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P16.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P16 1949 PRE_first_tail_x1_r0_body.kappa16 PRE_first_tail_x1_r0_body.s367.ffi PRE_first_tail_x1_r0_body.s366.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_16
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_16
  have hcl : SSt (· < 1949) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s367.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S365.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_16] <;> decide) PRE_first_tail_x1_r0_body.cnodesK16 PRE_first_tail_x1_r0_body.cobjsK16
      PRE_first_tail_x1_r0_body.citemsK16 PRE_first_tail_x1_r0_body.cbd16 PRE_first_tail_x1_r0_body.csst16
  exact PRE_first_tail_x1_r0_body.cshift16 bodyNcl16 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_16] at this; exact this)


kernel_rfl bodyFramesEmpty16 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s366 a).isEmpty) = true
kernel_rfl bodyJsRoots16 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s365.next) PRE_first_tail_x1_r0_body.s367.trace PRE_first_tail_x1_r0_body.s367 = true
kernel_rfl bodyJsNative16 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s367.ffi) = true
kernel_rfl bodyLow16 : (PRE_first_tail_x1_r0_body.cws16 ++ PRE_first_tail_x1_r0_body.ws16).all (Nat.ble 9) = true
kernel_rfl bodyCntM16 : countersOkB PRE_first_tail_x1_r0_body.s365 PRE_first_tail_x1_r0_body.s366 = true
kernel_rfl bodyHi16 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s367.ffi).next setupP.E = true
kernel_rfl bodyNhi16 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s367.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge16 : bridgeOf PRE_first_tail_x1_r0_body.s366.ffi = bridgeOf PRE_first_tail_x1_r0_body.s365.ffi
kernel_rfl bodyNN16 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s365.ffi).nnext PRE_first_tail_x1_r0_body.P16.NL = true
kernel_rfl bodyXn16 : Nat.ble (⟨19166, 16253, 2713101, 1949⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s367.ffi).next = true
kernel_rfl bodyLo16 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s367.ffi).next = true
theorem bodyFacts16 : BodySiteFacts PRE_first_tail_x1_r0_body.s365 PRE_first_tail_x1_r0_body.s366 PRE_first_tail_x1_r0_body.s367 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S365 PRE_first_tail_x1_r0_body.S366 PRE_first_tail_x1_r0_body.S367
    PRE_first_tail_x1_r0_body.ws16 PRE_first_tail_x1_r0_body.cws16 PRE_first_tail_x1_r0_body.nr16 PRE_first_tail_x1_r0_body.pl16 PRE_first_tail_x1_r0_body.cl16 2714250 1949 PRE_first_tail_x1_r0_body.kd16 PRE_first_tail_x1_r0_body.kappa16 PRE_first_tail_x1_r0_body.P16
    ⟨19163, 16226, 2713095, 1931⟩ ⟨19166, 16253, 2713101, 1949⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap16
  clean := bodyClean16
  cfix := PRE_first_tail_x1_r0_body.cfix16
  zpl := PRE_first_tail_x1_r0_body.zpl16
  zplnd := PRE_first_tail_x1_r0_body.zplnd16
  zn1 := PRE_first_tail_x1_r0_body.zn116
  zfirst := PRE_first_tail_x1_r0_body.zfirst16
  zscn := PRE_first_tail_x1_r0_body.zscn16
  zsmn := PRE_first_tail_x1_r0_body.zsmn16
  zgrow := PRE_first_tail_x1_r0_body.zgrow16
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab16
  zfresh := PRE_first_tail_x1_r0_body.zfresh16
  zcnd := PRE_first_tail_x1_r0_body.zcnd16
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi16
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt16
  zgP := PRE_first_tail_x1_r0_body.zg16_2665
  zkP := PRE_first_tail_x1_r0_body.zk16_2665
  zmP := PRE_first_tail_x1_r0_body.zm16_2665
  zgC := PRE_first_tail_x1_r0_body.zg16_2673467
  zkC := PRE_first_tail_x1_r0_body.zk16_2673467
  zmC := PRE_first_tail_x1_r0_body.zm16_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw16_2673472
  zwV := PRE_first_tail_x1_r0_body.zw16_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap16
  zclbd := PRE_first_tail_x1_r0_body.zclbd16
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap16 PRE_first_tail_x1_r0_body.stFoot16 PRE_first_tail_x1_r0_body.iso16 PRE_first_tail_x1_r0_body.zwr16
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP16
  csupp := PRE_first_tail_x1_r0_body.csupp16
  cbound := PRE_first_tail_x1_r0_body.cbound16
  zimg := PRE_first_tail_x1_r0_body.zimg16
  zctl := PRE_first_tail_x1_r0_body.zctl16
  zstack := PRE_first_tail_x1_r0_body.zstack16
  zjobs := PRE_first_tail_x1_r0_body.zjobs16
  zstores := PRE_first_tail_x1_r0_body.zstores16
  zroots := PRE_first_tail_x1_r0_body.zroots16
  znC := PRE_first_tail_x1_r0_body.znC16
  ctab := PRE_first_tail_x1_r0_body.ctab16
  zbin := PRE_first_tail_x1_r0_body.zbin16
  cbridge := PRE_first_tail_x1_r0_body.cbridge16
  sbridge := bodyBridge16
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj16
  cshiftR := fun h hNL => bodyCshift16 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN16
  raised := PRE_first_tail_x1_r0_body.raised16
  cbigs := PRE_first_tail_x1_r0_body.cbigs16
  cjcl := PRE_first_tail_x1_r0_body.cjcl16
  xnLe := Nat.le_of_ble_eq_true bodyXn16
  loLe := Nat.le_of_ble_eq_true bodyLo16
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB16
  cntM := bodyCntM16
  hiLe := Nat.le_of_ble_eq_true bodyHi16
  nhiLe := Nat.le_of_ble_eq_true bodyNhi16
  jsHeap := bodyJs16
  jsRoots := bodyJsRoots16
  jsNative := bodyJsNative16
  framesEmpty := bodyFramesEmpty16
  trailOld := by decide
  lowVars := bodyLow16

def bodyQs16 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs16 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr16.map fun r => nth? PRE_first_tail_x1_r0_body.st16.S5.tab r
kernel_rfl bodyResChk16 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs16 bodyQs16) = true
kernel_rfl bodyLq16 : bodyQs16.length = PRE_first_tail_x1_r0_body.cws16.length
kernel_rfl bodyNrLo16 : PRE_first_tail_x1_r0_body.nr16.all (Nat.ble PRE_first_tail_x1_r0_body.S365.tab.length) = true
kernel_rfl bodySub16 : (Oracles.PRE_first_tail_x1_r0_body.map_site16.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost16 : postSubB bodyM PRE_first_tail_x1_r0_body.ws16 PRE_first_tail_x1_r0_body.cws16 bodyQs16 = true
kernel_rfl bodyDrop16 : Nat.ble (19302 + (PRE_first_tail_x1_r0_body.s366.next - PRE_first_tail_x1_r0_body.s367.next)) 20451 = true
kernel_rfl bodyDropH16 : Nat.ble (329 + ((mlxOf PRE_first_tail_x1_r0_body.s366.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s367.ffi).next)) 354 = true
kernel_rfl bodyDropN16 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s366.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s367.ffi).nnext)) 0 = true
kernel_rfl bodyDv16 : bodyΘ.1.take 270 = bodyΘ.1.take 252 ++ PRE_first_tail_x1_r0_body.cws16
kernel_rfl bodyDe16 : bodyΘ.2.take 270 = bodyΘ.2.take 252 ++ PRE_first_tail_x1_r0_body.nr16.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st16.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 252) (bodyΘ.2.take 252)))
kernel_rfl bodyDl16 : (bodyΘ.1.take 252).length = (bodyΘ.2.take 252).length
kernel_rfl bodyDold16 : (bodyΘ.1.take 252).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws16).isNone && !PRE_first_tail_x1_r0_body.ws16.contains v) = true
kernel_rfl bodyDfree16 : (bodyΘ.2.take 270).all (fun e => (PRE_first_tail_x1_r0_body.cws16 ++ PRE_first_tail_x1_r0_body.ws16).all fun w => e.noVar w) = true

theorem bodyStep16 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19302, 329, 0, 252⟩ bodyM PRE_first_tail_x1_r0_body.s365 PRE_first_tail_x1_r0_body.S365)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20451, 354, 0, 270⟩ bodyM PRE_first_tail_x1_r0_body.s367 PRE_first_tail_x1_r0_body.S367) (11334 + 1) :=
  bodySite bodyFacts16.cfix bodyFacts16.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st16.S5.tab) (Es := bodyEs16) (qs := bodyQs16)
    (ok := PRE_first_tail_x1_r0_body.st16.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site16 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts16
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site16 r hr) hi (MapOk.sub hm (sub_of_all bodySub16)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk16 r hr) hi hm ho hq)
    bodyLq16 rfl bodyNrLo16 (postSub_sound bodyPost16)
    (Nat.le_of_ble_eq_true bodyDrop16) (by decide) (Nat.le_of_ble_eq_true bodyDropH16) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN16) (by decide)
    bodyDv16 bodyDe16 bodyDl16 bodyDold16 bodyDfree16 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site17 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site17 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site17) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st17.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site17
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st17.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st17.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s387 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s388 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S387 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws17 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st17.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st17.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso17
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_17
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st17.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot17
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup17
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound17
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace17
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged17
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws17.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st17.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S387.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_17]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen17.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh17
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl17 : Conv.NClean (⟨19220, 16289, 2715347, 2047⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s387.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl17 (PRE_first_tail_x1_r0_body.cncl16 bodyNcl16)

theorem bodyClean17 : Conv.JClean (⟨19220, 16289, 2715347, 2047⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s387 :=
  PRE_first_tail_x1_r0_body.gjcl17 (PRE_first_tail_x1_r0_body.cjcl16 bodyClean16)

kernel_rfl bodyJsLe17 : Nat.ble PRE_first_tail_x1_r0_body.s365.next PRE_first_tail_x1_r0_body.s387.next = true
kernel_rfl bodyJsList17 : (PRE_first_tail_x1_r0_body.gjh17 ++ PRE_first_tail_x1_r0_body.cl17).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s387.next) PRE_first_tail_x1_r0_body.s389) = true
theorem bodyJs17 : JsHeapAbove PRE_first_tail_x1_r0_body.s387.next PRE_first_tail_x1_r0_body.s389 :=
  JsHeapAbove.glueSite bodyJs16 (Nat.le_of_ble_eq_true bodyJsLe17) PRE_first_tail_x1_r0_body.gjk17 PRE_first_tail_x1_r0_body.gjbd17 PRE_first_tail_x1_r0_body.cheap17 PRE_first_tail_x1_r0_body.zclbd17 bodyJsList17

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO367 : PRE_first_tail_x1_r0_body.S367.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S367.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr367 : bridgeOf PRE_first_tail_x1_r0_body.s367.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc367 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s367 PRE_first_tail_x1_r0_body.S367) = fun _ _ => true
kernel_rfl bodyAcc368 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s368 PRE_first_tail_x1_r0_body.S368) = fun _ _ => true
kernel_rfl bodyBr369 : bridgeOf PRE_first_tail_x1_r0_body.s369.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt368 : isHalt PRE_first_tail_x1_r0_body.s368.ctl = false
kernel_rfl bodyTop369 : noRetBlock PRE_first_tail_x1_r0_body.s369 = true
kernel_rfl bodyCnt367 : countersOkB PRE_first_tail_x1_r0_body.s367 PRE_first_tail_x1_r0_body.s369 = true
kernel_rfl bodyO369 : PRE_first_tail_x1_r0_body.S369.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S369.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr370 : bridgeOf PRE_first_tail_x1_r0_body.s370.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt369 : countersOkB PRE_first_tail_x1_r0_body.s369 PRE_first_tail_x1_r0_body.s370 = true
kernel_rfl bodyO370 : PRE_first_tail_x1_r0_body.S370.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S370.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc370 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s370 PRE_first_tail_x1_r0_body.S370) = fun _ _ => true
kernel_rfl bodyAcc374 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s374 PRE_first_tail_x1_r0_body.S374) = fun _ _ => true
kernel_rfl bodyBr375 : bridgeOf PRE_first_tail_x1_r0_body.s375.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt374 : isHalt PRE_first_tail_x1_r0_body.s374.ctl = false
kernel_rfl bodyTop375 : noRetBlock PRE_first_tail_x1_r0_body.s375 = true
kernel_rfl bodyCnt370 : countersOkB PRE_first_tail_x1_r0_body.s370 PRE_first_tail_x1_r0_body.s375 = true
kernel_rfl bodyO375 : PRE_first_tail_x1_r0_body.S375.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S375.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr376 : bridgeOf PRE_first_tail_x1_r0_body.s376.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt375 : countersOkB PRE_first_tail_x1_r0_body.s375 PRE_first_tail_x1_r0_body.s376 = true
kernel_rfl bodyO376 : PRE_first_tail_x1_r0_body.S376.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S376.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc376 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s376 PRE_first_tail_x1_r0_body.S376) = fun _ _ => true
kernel_rfl bodyAcc377 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s377 PRE_first_tail_x1_r0_body.S377) = fun _ _ => true
kernel_rfl bodyBr378 : bridgeOf PRE_first_tail_x1_r0_body.s378.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt377 : isHalt PRE_first_tail_x1_r0_body.s377.ctl = false
kernel_rfl bodyTop378 : noRetBlock PRE_first_tail_x1_r0_body.s378 = true
kernel_rfl bodyCnt376 : countersOkB PRE_first_tail_x1_r0_body.s376 PRE_first_tail_x1_r0_body.s378 = true
kernel_rfl bodyO378 : PRE_first_tail_x1_r0_body.S378.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S378.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr379 : bridgeOf PRE_first_tail_x1_r0_body.s379.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt378 : countersOkB PRE_first_tail_x1_r0_body.s378 PRE_first_tail_x1_r0_body.s379 = true
kernel_rfl bodyO379 : PRE_first_tail_x1_r0_body.S379.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S379.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc379 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s379 PRE_first_tail_x1_r0_body.S379) = fun _ _ => true
kernel_rfl bodyAcc380 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s380 PRE_first_tail_x1_r0_body.S380) = fun _ _ => true
kernel_rfl bodyBr381 : bridgeOf PRE_first_tail_x1_r0_body.s381.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt380 : isHalt PRE_first_tail_x1_r0_body.s380.ctl = false
kernel_rfl bodyTop381 : noRetBlock PRE_first_tail_x1_r0_body.s381 = true
kernel_rfl bodyCnt379 : countersOkB PRE_first_tail_x1_r0_body.s379 PRE_first_tail_x1_r0_body.s381 = true
kernel_rfl bodyO381 : PRE_first_tail_x1_r0_body.S381.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S381.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr382 : bridgeOf PRE_first_tail_x1_r0_body.s382.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt381 : countersOkB PRE_first_tail_x1_r0_body.s381 PRE_first_tail_x1_r0_body.s382 = true
kernel_rfl bodyO382 : PRE_first_tail_x1_r0_body.S382.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S382.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc382 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s382 PRE_first_tail_x1_r0_body.S382) = fun _ _ => true
kernel_rfl bodyAcc383 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s383 PRE_first_tail_x1_r0_body.S383) = fun _ _ => true
kernel_rfl bodyBr384 : bridgeOf PRE_first_tail_x1_r0_body.s384.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt383 : isHalt PRE_first_tail_x1_r0_body.s383.ctl = false
kernel_rfl bodyTop384 : noRetBlock PRE_first_tail_x1_r0_body.s384 = true
kernel_rfl bodyCnt382 : countersOkB PRE_first_tail_x1_r0_body.s382 PRE_first_tail_x1_r0_body.s384 = true
kernel_rfl bodyO384 : PRE_first_tail_x1_r0_body.S384.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S384.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr385 : bridgeOf PRE_first_tail_x1_r0_body.s385.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt384 : countersOkB PRE_first_tail_x1_r0_body.s384 PRE_first_tail_x1_r0_body.s385 = true
kernel_rfl bodyO385 : PRE_first_tail_x1_r0_body.S385.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S385.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc385 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s385 PRE_first_tail_x1_r0_body.S385) = fun _ _ => true
kernel_rfl bodyAcc386 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s386 PRE_first_tail_x1_r0_body.S386) = fun _ _ => true
kernel_rfl bodyBr387 : bridgeOf PRE_first_tail_x1_r0_body.s387.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt386 : isHalt PRE_first_tail_x1_r0_body.s386.ctl = false
kernel_rfl bodyTop387 : noRetBlock PRE_first_tail_x1_r0_body.s387 = true
kernel_rfl bodyCnt385 : countersOkB PRE_first_tail_x1_r0_body.s385 PRE_first_tail_x1_r0_body.s387 = true

theorem bodyGlue17 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20451, 354, 0, 270⟩ bodyM PRE_first_tail_x1_r0_body.s367 PRE_first_tail_x1_r0_body.S367)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20451, 354, 0, 270⟩ bodyM PRE_first_tail_x1_r0_body.s387 PRE_first_tail_x1_r0_body.S387) 22397 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) bodyAcc367 PRE_first_tail_x1_r0_body.bodyRunSeg97 bodyAcc368 bodyHalt368 PRE_first_tail_x1_r0_body.bodyStepA98 bodyTop369 (fun _ hm => bodyO367 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr367).trans bodyInactive0) (bodyBr369.trans bodyBr367.symm) bodyCnt367 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) PRE_first_tail_x1_r0_body.sizeA98 PRE_first_tail_x1_r0_body.sizeArgsA98 PRE_first_tail_x1_r0_body.sizeSymA98 PRE_first_tail_x1_r0_body.sizeMlxA98 PRE_first_tail_x1_r0_body.sizePayA98 PRE_first_tail_x1_r0_body.sizeTaA98 PRE_first_tail_x1_r0_body.sizeDecA98 PRE_first_tail_x1_r0_body.sizePreA98 PRE_first_tail_x1_r0_body.bodyPatchB98 (fun _ hm => bodyO369 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr369).trans bodyInactive0) (bodyBr370.trans bodyBr369.symm) bodyCnt369 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) bodyAcc370 PRE_first_tail_x1_r0_body.bodyRunSeg98 bodyAcc374 bodyHalt374 PRE_first_tail_x1_r0_body.bodyStepA99 bodyTop375 (fun _ hm => bodyO370 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr370).trans bodyInactive0) (bodyBr375.trans bodyBr370.symm) bodyCnt370 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) PRE_first_tail_x1_r0_body.sizeA99 PRE_first_tail_x1_r0_body.sizeArgsA99 PRE_first_tail_x1_r0_body.sizeSymA99 PRE_first_tail_x1_r0_body.sizeMlxA99 PRE_first_tail_x1_r0_body.sizePayA99 PRE_first_tail_x1_r0_body.sizeTaA99 PRE_first_tail_x1_r0_body.sizeDecA99 PRE_first_tail_x1_r0_body.sizePreA99 PRE_first_tail_x1_r0_body.bodyPatchB99 (fun _ hm => bodyO375 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr375).trans bodyInactive0) (bodyBr376.trans bodyBr375.symm) bodyCnt375 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) bodyAcc376 PRE_first_tail_x1_r0_body.bodyRunSeg99 bodyAcc377 bodyHalt377 PRE_first_tail_x1_r0_body.bodyStepA100 bodyTop378 (fun _ hm => bodyO376 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr376).trans bodyInactive0) (bodyBr378.trans bodyBr376.symm) bodyCnt376 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) PRE_first_tail_x1_r0_body.sizeA100 PRE_first_tail_x1_r0_body.sizeArgsA100 PRE_first_tail_x1_r0_body.sizeSymA100 PRE_first_tail_x1_r0_body.sizeMlxA100 PRE_first_tail_x1_r0_body.sizePayA100 PRE_first_tail_x1_r0_body.sizeTaA100 PRE_first_tail_x1_r0_body.sizeDecA100 PRE_first_tail_x1_r0_body.sizePreA100 PRE_first_tail_x1_r0_body.bodyPatchB100 (fun _ hm => bodyO378 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr378).trans bodyInactive0) (bodyBr379.trans bodyBr378.symm) bodyCnt378 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) bodyAcc379 PRE_first_tail_x1_r0_body.bodyRunSeg100 bodyAcc380 bodyHalt380 PRE_first_tail_x1_r0_body.bodyStepA101 bodyTop381 (fun _ hm => bodyO379 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr379).trans bodyInactive0) (bodyBr381.trans bodyBr379.symm) bodyCnt379 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) PRE_first_tail_x1_r0_body.sizeA101 PRE_first_tail_x1_r0_body.sizeArgsA101 PRE_first_tail_x1_r0_body.sizeSymA101 PRE_first_tail_x1_r0_body.sizeMlxA101 PRE_first_tail_x1_r0_body.sizePayA101 PRE_first_tail_x1_r0_body.sizeTaA101 PRE_first_tail_x1_r0_body.sizeDecA101 PRE_first_tail_x1_r0_body.sizePreA101 PRE_first_tail_x1_r0_body.bodyPatchB101 (fun _ hm => bodyO381 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr381).trans bodyInactive0) (bodyBr382.trans bodyBr381.symm) bodyCnt381 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) bodyAcc382 PRE_first_tail_x1_r0_body.bodyRunSeg101 bodyAcc383 bodyHalt383 PRE_first_tail_x1_r0_body.bodyStepA102 bodyTop384 (fun _ hm => bodyO382 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr382).trans bodyInactive0) (bodyBr384.trans bodyBr382.symm) bodyCnt382 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) PRE_first_tail_x1_r0_body.sizeA102 PRE_first_tail_x1_r0_body.sizeArgsA102 PRE_first_tail_x1_r0_body.sizeSymA102 PRE_first_tail_x1_r0_body.sizeMlxA102 PRE_first_tail_x1_r0_body.sizePayA102 PRE_first_tail_x1_r0_body.sizeTaA102 PRE_first_tail_x1_r0_body.sizeDecA102 PRE_first_tail_x1_r0_body.sizePreA102 PRE_first_tail_x1_r0_body.bodyPatchB102 (fun _ hm => bodyO384 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr384).trans bodyInactive0) (bodyBr385.trans bodyBr384.symm) bodyCnt384 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20451, 354, 0, 270⟩) bodyAcc385 PRE_first_tail_x1_r0_body.bodyRunSeg102 bodyAcc386 bodyHalt386 PRE_first_tail_x1_r0_body.bodyStepA103 bodyTop387 (fun _ hm => bodyO385 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr385).trans bodyInactive0) (bodyBr387.trans bodyBr385.symm) bodyCnt385 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift17 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S387.tab.length PRE_first_tail_x1_r0_body.s387.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P17.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P17 2065 PRE_first_tail_x1_r0_body.kappa17 PRE_first_tail_x1_r0_body.s389.ffi PRE_first_tail_x1_r0_body.s388.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_17
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_17
  have hcl : SSt (· < 2065) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s389.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S387.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_17] <;> decide) PRE_first_tail_x1_r0_body.cnodesK17 PRE_first_tail_x1_r0_body.cobjsK17
      PRE_first_tail_x1_r0_body.citemsK17 PRE_first_tail_x1_r0_body.cbd17 PRE_first_tail_x1_r0_body.csst17
  exact PRE_first_tail_x1_r0_body.cshift17 bodyNcl17 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_17] at this; exact this)


kernel_rfl bodyFramesEmpty17 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s388 a).isEmpty) = true
kernel_rfl bodyJsRoots17 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s387.next) PRE_first_tail_x1_r0_body.s389.trace PRE_first_tail_x1_r0_body.s389 = true
kernel_rfl bodyJsNative17 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s389.ffi) = true
kernel_rfl bodyLow17 : (PRE_first_tail_x1_r0_body.cws17 ++ PRE_first_tail_x1_r0_body.ws17).all (Nat.ble 9) = true
kernel_rfl bodyCntM17 : countersOkB PRE_first_tail_x1_r0_body.s387 PRE_first_tail_x1_r0_body.s388 = true
kernel_rfl bodyHi17 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s389.ffi).next setupP.E = true
kernel_rfl bodyNhi17 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s389.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge17 : bridgeOf PRE_first_tail_x1_r0_body.s388.ffi = bridgeOf PRE_first_tail_x1_r0_body.s387.ffi
kernel_rfl bodyNN17 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s387.ffi).nnext PRE_first_tail_x1_r0_body.P17.NL = true
kernel_rfl bodyXn17 : Nat.ble (⟨19223, 16316, 2715353, 2065⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s389.ffi).next = true
kernel_rfl bodyLo17 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s389.ffi).next = true
theorem bodyFacts17 : BodySiteFacts PRE_first_tail_x1_r0_body.s387 PRE_first_tail_x1_r0_body.s388 PRE_first_tail_x1_r0_body.s389 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S387 PRE_first_tail_x1_r0_body.S388 PRE_first_tail_x1_r0_body.S389
    PRE_first_tail_x1_r0_body.ws17 PRE_first_tail_x1_r0_body.cws17 PRE_first_tail_x1_r0_body.nr17 PRE_first_tail_x1_r0_body.pl17 PRE_first_tail_x1_r0_body.cl17 2716502 2065 PRE_first_tail_x1_r0_body.kd17 PRE_first_tail_x1_r0_body.kappa17 PRE_first_tail_x1_r0_body.P17
    ⟨19220, 16289, 2715347, 2047⟩ ⟨19223, 16316, 2715353, 2065⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap17
  clean := bodyClean17
  cfix := PRE_first_tail_x1_r0_body.cfix17
  zpl := PRE_first_tail_x1_r0_body.zpl17
  zplnd := PRE_first_tail_x1_r0_body.zplnd17
  zn1 := PRE_first_tail_x1_r0_body.zn117
  zfirst := PRE_first_tail_x1_r0_body.zfirst17
  zscn := PRE_first_tail_x1_r0_body.zscn17
  zsmn := PRE_first_tail_x1_r0_body.zsmn17
  zgrow := PRE_first_tail_x1_r0_body.zgrow17
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab17
  zfresh := PRE_first_tail_x1_r0_body.zfresh17
  zcnd := PRE_first_tail_x1_r0_body.zcnd17
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi17
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt17
  zgP := PRE_first_tail_x1_r0_body.zg17_2665
  zkP := PRE_first_tail_x1_r0_body.zk17_2665
  zmP := PRE_first_tail_x1_r0_body.zm17_2665
  zgC := PRE_first_tail_x1_r0_body.zg17_2673467
  zkC := PRE_first_tail_x1_r0_body.zk17_2673467
  zmC := PRE_first_tail_x1_r0_body.zm17_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw17_2673472
  zwV := PRE_first_tail_x1_r0_body.zw17_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap17
  zclbd := PRE_first_tail_x1_r0_body.zclbd17
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap17 PRE_first_tail_x1_r0_body.stFoot17 PRE_first_tail_x1_r0_body.iso17 PRE_first_tail_x1_r0_body.zwr17
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP17
  csupp := PRE_first_tail_x1_r0_body.csupp17
  cbound := PRE_first_tail_x1_r0_body.cbound17
  zimg := PRE_first_tail_x1_r0_body.zimg17
  zctl := PRE_first_tail_x1_r0_body.zctl17
  zstack := PRE_first_tail_x1_r0_body.zstack17
  zjobs := PRE_first_tail_x1_r0_body.zjobs17
  zstores := PRE_first_tail_x1_r0_body.zstores17
  zroots := PRE_first_tail_x1_r0_body.zroots17
  znC := PRE_first_tail_x1_r0_body.znC17
  ctab := PRE_first_tail_x1_r0_body.ctab17
  zbin := PRE_first_tail_x1_r0_body.zbin17
  cbridge := PRE_first_tail_x1_r0_body.cbridge17
  sbridge := bodyBridge17
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj17
  cshiftR := fun h hNL => bodyCshift17 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN17
  raised := PRE_first_tail_x1_r0_body.raised17
  cbigs := PRE_first_tail_x1_r0_body.cbigs17
  cjcl := PRE_first_tail_x1_r0_body.cjcl17
  xnLe := Nat.le_of_ble_eq_true bodyXn17
  loLe := Nat.le_of_ble_eq_true bodyLo17
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB17
  cntM := bodyCntM17
  hiLe := Nat.le_of_ble_eq_true bodyHi17
  nhiLe := Nat.le_of_ble_eq_true bodyNhi17
  jsHeap := bodyJs17
  jsRoots := bodyJsRoots17
  jsNative := bodyJsNative17
  framesEmpty := bodyFramesEmpty17
  trailOld := by decide
  lowVars := bodyLow17

def bodyQs17 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs17 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr17.map fun r => nth? PRE_first_tail_x1_r0_body.st17.S5.tab r
kernel_rfl bodyResChk17 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs17 bodyQs17) = true
kernel_rfl bodyLq17 : bodyQs17.length = PRE_first_tail_x1_r0_body.cws17.length
kernel_rfl bodyNrLo17 : PRE_first_tail_x1_r0_body.nr17.all (Nat.ble PRE_first_tail_x1_r0_body.S387.tab.length) = true
kernel_rfl bodySub17 : (Oracles.PRE_first_tail_x1_r0_body.map_site17.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost17 : postSubB bodyM PRE_first_tail_x1_r0_body.ws17 PRE_first_tail_x1_r0_body.cws17 bodyQs17 = true
kernel_rfl bodyDrop17 : Nat.ble (20451 + (PRE_first_tail_x1_r0_body.s388.next - PRE_first_tail_x1_r0_body.s389.next)) 21600 = true
kernel_rfl bodyDropH17 : Nat.ble (354 + ((mlxOf PRE_first_tail_x1_r0_body.s388.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s389.ffi).next)) 379 = true
kernel_rfl bodyDropN17 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s388.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s389.ffi).nnext)) 0 = true
kernel_rfl bodyDv17 : bodyΘ.1.take 288 = bodyΘ.1.take 270 ++ PRE_first_tail_x1_r0_body.cws17
kernel_rfl bodyDe17 : bodyΘ.2.take 288 = bodyΘ.2.take 270 ++ PRE_first_tail_x1_r0_body.nr17.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st17.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 270) (bodyΘ.2.take 270)))
kernel_rfl bodyDl17 : (bodyΘ.1.take 270).length = (bodyΘ.2.take 270).length
kernel_rfl bodyDold17 : (bodyΘ.1.take 270).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws17).isNone && !PRE_first_tail_x1_r0_body.ws17.contains v) = true
kernel_rfl bodyDfree17 : (bodyΘ.2.take 288).all (fun e => (PRE_first_tail_x1_r0_body.cws17 ++ PRE_first_tail_x1_r0_body.ws17).all fun w => e.noVar w) = true

theorem bodyStep17 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20451, 354, 0, 270⟩ bodyM PRE_first_tail_x1_r0_body.s387 PRE_first_tail_x1_r0_body.S387)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21600, 379, 0, 288⟩ bodyM PRE_first_tail_x1_r0_body.s389 PRE_first_tail_x1_r0_body.S389) (11334 + 1) :=
  bodySite bodyFacts17.cfix bodyFacts17.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st17.S5.tab) (Es := bodyEs17) (qs := bodyQs17)
    (ok := PRE_first_tail_x1_r0_body.st17.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site17 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts17
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site17 r hr) hi (MapOk.sub hm (sub_of_all bodySub17)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk17 r hr) hi hm ho hq)
    bodyLq17 rfl bodyNrLo17 (postSub_sound bodyPost17)
    (Nat.le_of_ble_eq_true bodyDrop17) (by decide) (Nat.le_of_ble_eq_true bodyDropH17) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN17) (by decide)
    bodyDv17 bodyDe17 bodyDl17 bodyDold17 bodyDfree17 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site18 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site18 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site18) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st18.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site18
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st18.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st18.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s409 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s410 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S409 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws18 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st18.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st18.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso18
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_18
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st18.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot18
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup18
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound18
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace18
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged18
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws18.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st18.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S409.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_18]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen18.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh18
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl18 : Conv.NClean (⟨19277, 16352, 2717599, 2163⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s409.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl18 (PRE_first_tail_x1_r0_body.cncl17 bodyNcl17)

theorem bodyClean18 : Conv.JClean (⟨19277, 16352, 2717599, 2163⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s409 :=
  PRE_first_tail_x1_r0_body.gjcl18 (PRE_first_tail_x1_r0_body.cjcl17 bodyClean17)

kernel_rfl bodyJsLe18 : Nat.ble PRE_first_tail_x1_r0_body.s387.next PRE_first_tail_x1_r0_body.s409.next = true
kernel_rfl bodyJsList18 : (PRE_first_tail_x1_r0_body.gjh18 ++ PRE_first_tail_x1_r0_body.cl18).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s409.next) PRE_first_tail_x1_r0_body.s411) = true
theorem bodyJs18 : JsHeapAbove PRE_first_tail_x1_r0_body.s409.next PRE_first_tail_x1_r0_body.s411 :=
  JsHeapAbove.glueSite bodyJs17 (Nat.le_of_ble_eq_true bodyJsLe18) PRE_first_tail_x1_r0_body.gjk18 PRE_first_tail_x1_r0_body.gjbd18 PRE_first_tail_x1_r0_body.cheap18 PRE_first_tail_x1_r0_body.zclbd18 bodyJsList18

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO389 : PRE_first_tail_x1_r0_body.S389.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S389.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr389 : bridgeOf PRE_first_tail_x1_r0_body.s389.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc389 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s389 PRE_first_tail_x1_r0_body.S389) = fun _ _ => true
kernel_rfl bodyAcc390 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s390 PRE_first_tail_x1_r0_body.S390) = fun _ _ => true
kernel_rfl bodyBr391 : bridgeOf PRE_first_tail_x1_r0_body.s391.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt390 : isHalt PRE_first_tail_x1_r0_body.s390.ctl = false
kernel_rfl bodyTop391 : noRetBlock PRE_first_tail_x1_r0_body.s391 = true
kernel_rfl bodyCnt389 : countersOkB PRE_first_tail_x1_r0_body.s389 PRE_first_tail_x1_r0_body.s391 = true
kernel_rfl bodyO391 : PRE_first_tail_x1_r0_body.S391.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S391.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr392 : bridgeOf PRE_first_tail_x1_r0_body.s392.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt391 : countersOkB PRE_first_tail_x1_r0_body.s391 PRE_first_tail_x1_r0_body.s392 = true
kernel_rfl bodyO392 : PRE_first_tail_x1_r0_body.S392.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S392.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc392 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s392 PRE_first_tail_x1_r0_body.S392) = fun _ _ => true
kernel_rfl bodyAcc396 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s396 PRE_first_tail_x1_r0_body.S396) = fun _ _ => true
kernel_rfl bodyBr397 : bridgeOf PRE_first_tail_x1_r0_body.s397.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt396 : isHalt PRE_first_tail_x1_r0_body.s396.ctl = false
kernel_rfl bodyTop397 : noRetBlock PRE_first_tail_x1_r0_body.s397 = true
kernel_rfl bodyCnt392 : countersOkB PRE_first_tail_x1_r0_body.s392 PRE_first_tail_x1_r0_body.s397 = true
kernel_rfl bodyO397 : PRE_first_tail_x1_r0_body.S397.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S397.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr398 : bridgeOf PRE_first_tail_x1_r0_body.s398.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt397 : countersOkB PRE_first_tail_x1_r0_body.s397 PRE_first_tail_x1_r0_body.s398 = true
kernel_rfl bodyO398 : PRE_first_tail_x1_r0_body.S398.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S398.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc398 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s398 PRE_first_tail_x1_r0_body.S398) = fun _ _ => true
kernel_rfl bodyAcc399 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s399 PRE_first_tail_x1_r0_body.S399) = fun _ _ => true
kernel_rfl bodyBr400 : bridgeOf PRE_first_tail_x1_r0_body.s400.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt399 : isHalt PRE_first_tail_x1_r0_body.s399.ctl = false
kernel_rfl bodyTop400 : noRetBlock PRE_first_tail_x1_r0_body.s400 = true
kernel_rfl bodyCnt398 : countersOkB PRE_first_tail_x1_r0_body.s398 PRE_first_tail_x1_r0_body.s400 = true
kernel_rfl bodyO400 : PRE_first_tail_x1_r0_body.S400.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S400.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr401 : bridgeOf PRE_first_tail_x1_r0_body.s401.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt400 : countersOkB PRE_first_tail_x1_r0_body.s400 PRE_first_tail_x1_r0_body.s401 = true
kernel_rfl bodyO401 : PRE_first_tail_x1_r0_body.S401.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S401.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc401 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s401 PRE_first_tail_x1_r0_body.S401) = fun _ _ => true
kernel_rfl bodyAcc402 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s402 PRE_first_tail_x1_r0_body.S402) = fun _ _ => true
kernel_rfl bodyBr403 : bridgeOf PRE_first_tail_x1_r0_body.s403.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt402 : isHalt PRE_first_tail_x1_r0_body.s402.ctl = false
kernel_rfl bodyTop403 : noRetBlock PRE_first_tail_x1_r0_body.s403 = true
kernel_rfl bodyCnt401 : countersOkB PRE_first_tail_x1_r0_body.s401 PRE_first_tail_x1_r0_body.s403 = true
kernel_rfl bodyO403 : PRE_first_tail_x1_r0_body.S403.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S403.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr404 : bridgeOf PRE_first_tail_x1_r0_body.s404.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt403 : countersOkB PRE_first_tail_x1_r0_body.s403 PRE_first_tail_x1_r0_body.s404 = true
kernel_rfl bodyO404 : PRE_first_tail_x1_r0_body.S404.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S404.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc404 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s404 PRE_first_tail_x1_r0_body.S404) = fun _ _ => true
kernel_rfl bodyAcc405 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s405 PRE_first_tail_x1_r0_body.S405) = fun _ _ => true
kernel_rfl bodyBr406 : bridgeOf PRE_first_tail_x1_r0_body.s406.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt405 : isHalt PRE_first_tail_x1_r0_body.s405.ctl = false
kernel_rfl bodyTop406 : noRetBlock PRE_first_tail_x1_r0_body.s406 = true
kernel_rfl bodyCnt404 : countersOkB PRE_first_tail_x1_r0_body.s404 PRE_first_tail_x1_r0_body.s406 = true
kernel_rfl bodyO406 : PRE_first_tail_x1_r0_body.S406.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S406.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr407 : bridgeOf PRE_first_tail_x1_r0_body.s407.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt406 : countersOkB PRE_first_tail_x1_r0_body.s406 PRE_first_tail_x1_r0_body.s407 = true
kernel_rfl bodyO407 : PRE_first_tail_x1_r0_body.S407.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S407.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc407 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s407 PRE_first_tail_x1_r0_body.S407) = fun _ _ => true
kernel_rfl bodyAcc408 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s408 PRE_first_tail_x1_r0_body.S408) = fun _ _ => true
kernel_rfl bodyBr409 : bridgeOf PRE_first_tail_x1_r0_body.s409.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt408 : isHalt PRE_first_tail_x1_r0_body.s408.ctl = false
kernel_rfl bodyTop409 : noRetBlock PRE_first_tail_x1_r0_body.s409 = true
kernel_rfl bodyCnt407 : countersOkB PRE_first_tail_x1_r0_body.s407 PRE_first_tail_x1_r0_body.s409 = true

theorem bodyGlue18 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21600, 379, 0, 288⟩ bodyM PRE_first_tail_x1_r0_body.s389 PRE_first_tail_x1_r0_body.S389)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21600, 379, 0, 288⟩ bodyM PRE_first_tail_x1_r0_body.s409 PRE_first_tail_x1_r0_body.S409) 22397 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) bodyAcc389 PRE_first_tail_x1_r0_body.bodyRunSeg103 bodyAcc390 bodyHalt390 PRE_first_tail_x1_r0_body.bodyStepA104 bodyTop391 (fun _ hm => bodyO389 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr389).trans bodyInactive0) (bodyBr391.trans bodyBr389.symm) bodyCnt389 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) PRE_first_tail_x1_r0_body.sizeA104 PRE_first_tail_x1_r0_body.sizeArgsA104 PRE_first_tail_x1_r0_body.sizeSymA104 PRE_first_tail_x1_r0_body.sizeMlxA104 PRE_first_tail_x1_r0_body.sizePayA104 PRE_first_tail_x1_r0_body.sizeTaA104 PRE_first_tail_x1_r0_body.sizeDecA104 PRE_first_tail_x1_r0_body.sizePreA104 PRE_first_tail_x1_r0_body.bodyPatchB104 (fun _ hm => bodyO391 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr391).trans bodyInactive0) (bodyBr392.trans bodyBr391.symm) bodyCnt391 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) bodyAcc392 PRE_first_tail_x1_r0_body.bodyRunSeg104 bodyAcc396 bodyHalt396 PRE_first_tail_x1_r0_body.bodyStepA105 bodyTop397 (fun _ hm => bodyO392 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr392).trans bodyInactive0) (bodyBr397.trans bodyBr392.symm) bodyCnt392 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) PRE_first_tail_x1_r0_body.sizeA105 PRE_first_tail_x1_r0_body.sizeArgsA105 PRE_first_tail_x1_r0_body.sizeSymA105 PRE_first_tail_x1_r0_body.sizeMlxA105 PRE_first_tail_x1_r0_body.sizePayA105 PRE_first_tail_x1_r0_body.sizeTaA105 PRE_first_tail_x1_r0_body.sizeDecA105 PRE_first_tail_x1_r0_body.sizePreA105 PRE_first_tail_x1_r0_body.bodyPatchB105 (fun _ hm => bodyO397 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr397).trans bodyInactive0) (bodyBr398.trans bodyBr397.symm) bodyCnt397 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) bodyAcc398 PRE_first_tail_x1_r0_body.bodyRunSeg105 bodyAcc399 bodyHalt399 PRE_first_tail_x1_r0_body.bodyStepA106 bodyTop400 (fun _ hm => bodyO398 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr398).trans bodyInactive0) (bodyBr400.trans bodyBr398.symm) bodyCnt398 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) PRE_first_tail_x1_r0_body.sizeA106 PRE_first_tail_x1_r0_body.sizeArgsA106 PRE_first_tail_x1_r0_body.sizeSymA106 PRE_first_tail_x1_r0_body.sizeMlxA106 PRE_first_tail_x1_r0_body.sizePayA106 PRE_first_tail_x1_r0_body.sizeTaA106 PRE_first_tail_x1_r0_body.sizeDecA106 PRE_first_tail_x1_r0_body.sizePreA106 PRE_first_tail_x1_r0_body.bodyPatchB106 (fun _ hm => bodyO400 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr400).trans bodyInactive0) (bodyBr401.trans bodyBr400.symm) bodyCnt400 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) bodyAcc401 PRE_first_tail_x1_r0_body.bodyRunSeg106 bodyAcc402 bodyHalt402 PRE_first_tail_x1_r0_body.bodyStepA107 bodyTop403 (fun _ hm => bodyO401 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr401).trans bodyInactive0) (bodyBr403.trans bodyBr401.symm) bodyCnt401 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) PRE_first_tail_x1_r0_body.sizeA107 PRE_first_tail_x1_r0_body.sizeArgsA107 PRE_first_tail_x1_r0_body.sizeSymA107 PRE_first_tail_x1_r0_body.sizeMlxA107 PRE_first_tail_x1_r0_body.sizePayA107 PRE_first_tail_x1_r0_body.sizeTaA107 PRE_first_tail_x1_r0_body.sizeDecA107 PRE_first_tail_x1_r0_body.sizePreA107 PRE_first_tail_x1_r0_body.bodyPatchB107 (fun _ hm => bodyO403 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr403).trans bodyInactive0) (bodyBr404.trans bodyBr403.symm) bodyCnt403 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) bodyAcc404 PRE_first_tail_x1_r0_body.bodyRunSeg107 bodyAcc405 bodyHalt405 PRE_first_tail_x1_r0_body.bodyStepA108 bodyTop406 (fun _ hm => bodyO404 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr404).trans bodyInactive0) (bodyBr406.trans bodyBr404.symm) bodyCnt404 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) PRE_first_tail_x1_r0_body.sizeA108 PRE_first_tail_x1_r0_body.sizeArgsA108 PRE_first_tail_x1_r0_body.sizeSymA108 PRE_first_tail_x1_r0_body.sizeMlxA108 PRE_first_tail_x1_r0_body.sizePayA108 PRE_first_tail_x1_r0_body.sizeTaA108 PRE_first_tail_x1_r0_body.sizeDecA108 PRE_first_tail_x1_r0_body.sizePreA108 PRE_first_tail_x1_r0_body.bodyPatchB108 (fun _ hm => bodyO406 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr406).trans bodyInactive0) (bodyBr407.trans bodyBr406.symm) bodyCnt406 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21600, 379, 0, 288⟩) bodyAcc407 PRE_first_tail_x1_r0_body.bodyRunSeg108 bodyAcc408 bodyHalt408 PRE_first_tail_x1_r0_body.bodyStepA109 bodyTop409 (fun _ hm => bodyO407 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr407).trans bodyInactive0) (bodyBr409.trans bodyBr407.symm) bodyCnt407 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift18 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S409.tab.length PRE_first_tail_x1_r0_body.s409.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P18.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P18 2181 PRE_first_tail_x1_r0_body.kappa18 PRE_first_tail_x1_r0_body.s411.ffi PRE_first_tail_x1_r0_body.s410.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_18
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_18
  have hcl : SSt (· < 2181) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s411.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S409.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_18] <;> decide) PRE_first_tail_x1_r0_body.cnodesK18 PRE_first_tail_x1_r0_body.cobjsK18
      PRE_first_tail_x1_r0_body.citemsK18 PRE_first_tail_x1_r0_body.cbd18 PRE_first_tail_x1_r0_body.csst18
  exact PRE_first_tail_x1_r0_body.cshift18 bodyNcl18 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_18] at this; exact this)


kernel_rfl bodyFramesEmpty18 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s410 a).isEmpty) = true
kernel_rfl bodyJsRoots18 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s409.next) PRE_first_tail_x1_r0_body.s411.trace PRE_first_tail_x1_r0_body.s411 = true
kernel_rfl bodyJsNative18 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s411.ffi) = true
kernel_rfl bodyLow18 : (PRE_first_tail_x1_r0_body.cws18 ++ PRE_first_tail_x1_r0_body.ws18).all (Nat.ble 9) = true
kernel_rfl bodyCntM18 : countersOkB PRE_first_tail_x1_r0_body.s409 PRE_first_tail_x1_r0_body.s410 = true
kernel_rfl bodyHi18 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s411.ffi).next setupP.E = true
kernel_rfl bodyNhi18 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s411.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge18 : bridgeOf PRE_first_tail_x1_r0_body.s410.ffi = bridgeOf PRE_first_tail_x1_r0_body.s409.ffi
kernel_rfl bodyNN18 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s409.ffi).nnext PRE_first_tail_x1_r0_body.P18.NL = true
kernel_rfl bodyXn18 : Nat.ble (⟨19280, 16379, 2717605, 2181⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s411.ffi).next = true
kernel_rfl bodyLo18 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s411.ffi).next = true
theorem bodyFacts18 : BodySiteFacts PRE_first_tail_x1_r0_body.s409 PRE_first_tail_x1_r0_body.s410 PRE_first_tail_x1_r0_body.s411 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S409 PRE_first_tail_x1_r0_body.S410 PRE_first_tail_x1_r0_body.S411
    PRE_first_tail_x1_r0_body.ws18 PRE_first_tail_x1_r0_body.cws18 PRE_first_tail_x1_r0_body.nr18 PRE_first_tail_x1_r0_body.pl18 PRE_first_tail_x1_r0_body.cl18 2718754 2181 PRE_first_tail_x1_r0_body.kd18 PRE_first_tail_x1_r0_body.kappa18 PRE_first_tail_x1_r0_body.P18
    ⟨19277, 16352, 2717599, 2163⟩ ⟨19280, 16379, 2717605, 2181⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap18
  clean := bodyClean18
  cfix := PRE_first_tail_x1_r0_body.cfix18
  zpl := PRE_first_tail_x1_r0_body.zpl18
  zplnd := PRE_first_tail_x1_r0_body.zplnd18
  zn1 := PRE_first_tail_x1_r0_body.zn118
  zfirst := PRE_first_tail_x1_r0_body.zfirst18
  zscn := PRE_first_tail_x1_r0_body.zscn18
  zsmn := PRE_first_tail_x1_r0_body.zsmn18
  zgrow := PRE_first_tail_x1_r0_body.zgrow18
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab18
  zfresh := PRE_first_tail_x1_r0_body.zfresh18
  zcnd := PRE_first_tail_x1_r0_body.zcnd18
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi18
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt18
  zgP := PRE_first_tail_x1_r0_body.zg18_2665
  zkP := PRE_first_tail_x1_r0_body.zk18_2665
  zmP := PRE_first_tail_x1_r0_body.zm18_2665
  zgC := PRE_first_tail_x1_r0_body.zg18_2673467
  zkC := PRE_first_tail_x1_r0_body.zk18_2673467
  zmC := PRE_first_tail_x1_r0_body.zm18_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw18_2673472
  zwV := PRE_first_tail_x1_r0_body.zw18_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap18
  zclbd := PRE_first_tail_x1_r0_body.zclbd18
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap18 PRE_first_tail_x1_r0_body.stFoot18 PRE_first_tail_x1_r0_body.iso18 PRE_first_tail_x1_r0_body.zwr18
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP18
  csupp := PRE_first_tail_x1_r0_body.csupp18
  cbound := PRE_first_tail_x1_r0_body.cbound18
  zimg := PRE_first_tail_x1_r0_body.zimg18
  zctl := PRE_first_tail_x1_r0_body.zctl18
  zstack := PRE_first_tail_x1_r0_body.zstack18
  zjobs := PRE_first_tail_x1_r0_body.zjobs18
  zstores := PRE_first_tail_x1_r0_body.zstores18
  zroots := PRE_first_tail_x1_r0_body.zroots18
  znC := PRE_first_tail_x1_r0_body.znC18
  ctab := PRE_first_tail_x1_r0_body.ctab18
  zbin := PRE_first_tail_x1_r0_body.zbin18
  cbridge := PRE_first_tail_x1_r0_body.cbridge18
  sbridge := bodyBridge18
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj18
  cshiftR := fun h hNL => bodyCshift18 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN18
  raised := PRE_first_tail_x1_r0_body.raised18
  cbigs := PRE_first_tail_x1_r0_body.cbigs18
  cjcl := PRE_first_tail_x1_r0_body.cjcl18
  xnLe := Nat.le_of_ble_eq_true bodyXn18
  loLe := Nat.le_of_ble_eq_true bodyLo18
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB18
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
noncomputable def bodyEs18 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr18.map fun r => nth? PRE_first_tail_x1_r0_body.st18.S5.tab r
kernel_rfl bodyResChk18 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs18 bodyQs18) = true
kernel_rfl bodyLq18 : bodyQs18.length = PRE_first_tail_x1_r0_body.cws18.length
kernel_rfl bodyNrLo18 : PRE_first_tail_x1_r0_body.nr18.all (Nat.ble PRE_first_tail_x1_r0_body.S409.tab.length) = true
kernel_rfl bodySub18 : (Oracles.PRE_first_tail_x1_r0_body.map_site18.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost18 : postSubB bodyM PRE_first_tail_x1_r0_body.ws18 PRE_first_tail_x1_r0_body.cws18 bodyQs18 = true
kernel_rfl bodyDrop18 : Nat.ble (21600 + (PRE_first_tail_x1_r0_body.s410.next - PRE_first_tail_x1_r0_body.s411.next)) 22749 = true
kernel_rfl bodyDropH18 : Nat.ble (379 + ((mlxOf PRE_first_tail_x1_r0_body.s410.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s411.ffi).next)) 404 = true
kernel_rfl bodyDropN18 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s410.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s411.ffi).nnext)) 0 = true
kernel_rfl bodyDv18 : bodyΘ.1.take 306 = bodyΘ.1.take 288 ++ PRE_first_tail_x1_r0_body.cws18
kernel_rfl bodyDe18 : bodyΘ.2.take 306 = bodyΘ.2.take 288 ++ PRE_first_tail_x1_r0_body.nr18.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st18.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 288) (bodyΘ.2.take 288)))
kernel_rfl bodyDl18 : (bodyΘ.1.take 288).length = (bodyΘ.2.take 288).length
kernel_rfl bodyDold18 : (bodyΘ.1.take 288).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws18).isNone && !PRE_first_tail_x1_r0_body.ws18.contains v) = true
kernel_rfl bodyDfree18 : (bodyΘ.2.take 306).all (fun e => (PRE_first_tail_x1_r0_body.cws18 ++ PRE_first_tail_x1_r0_body.ws18).all fun w => e.noVar w) = true

theorem bodyStep18 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21600, 379, 0, 288⟩ bodyM PRE_first_tail_x1_r0_body.s409 PRE_first_tail_x1_r0_body.S409)
      (bodyCut NB T tk π i x0 bodyΘ ⟨22749, 404, 0, 306⟩ bodyM PRE_first_tail_x1_r0_body.s411 PRE_first_tail_x1_r0_body.S411) (11334 + 1) :=
  bodySite bodyFacts18.cfix bodyFacts18.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st18.S5.tab) (Es := bodyEs18) (qs := bodyQs18)
    (ok := PRE_first_tail_x1_r0_body.st18.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site18 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts18
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site18 r hr) hi (MapOk.sub hm (sub_of_all bodySub18)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk18 r hr) hi hm ho hq)
    bodyLq18 rfl bodyNrLo18 (postSub_sound bodyPost18)
    (Nat.le_of_ble_eq_true bodyDrop18) (by decide) (Nat.le_of_ble_eq_true bodyDropH18) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN18) (by decide)
    bodyDv18 bodyDe18 bodyDl18 bodyDold18 bodyDfree18 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site19 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site19 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site19) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st19.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site19
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st19.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st19.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s430 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s431 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S430 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws19 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st19.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st19.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso19
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_19
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st19.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot19
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup19
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound19
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace19
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged19
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws19.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st19.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S430.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_19]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen19.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh19
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl19 : Conv.NClean (⟨19340, 16424, 2720114, 2285⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s430.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl19 (PRE_first_tail_x1_r0_body.cncl18 bodyNcl18)

theorem bodyClean19 : Conv.JClean (⟨19340, 16424, 2720114, 2285⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s430 :=
  PRE_first_tail_x1_r0_body.gjcl19 (PRE_first_tail_x1_r0_body.cjcl18 bodyClean18)

kernel_rfl bodyJsLe19 : Nat.ble PRE_first_tail_x1_r0_body.s409.next PRE_first_tail_x1_r0_body.s430.next = true
kernel_rfl bodyJsList19 : (PRE_first_tail_x1_r0_body.gjh19 ++ PRE_first_tail_x1_r0_body.cl19).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s430.next) PRE_first_tail_x1_r0_body.s432) = true
theorem bodyJs19 : JsHeapAbove PRE_first_tail_x1_r0_body.s430.next PRE_first_tail_x1_r0_body.s432 :=
  JsHeapAbove.glueSite bodyJs18 (Nat.le_of_ble_eq_true bodyJsLe19) PRE_first_tail_x1_r0_body.gjk19 PRE_first_tail_x1_r0_body.gjbd19 PRE_first_tail_x1_r0_body.cheap19 PRE_first_tail_x1_r0_body.zclbd19 bodyJsList19

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO411 : PRE_first_tail_x1_r0_body.S411.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S411.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr411 : bridgeOf PRE_first_tail_x1_r0_body.s411.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc411 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s411 PRE_first_tail_x1_r0_body.S411) = fun _ _ => true
kernel_rfl bodyAcc412 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s412 PRE_first_tail_x1_r0_body.S412) = fun _ _ => true
kernel_rfl bodyBr413 : bridgeOf PRE_first_tail_x1_r0_body.s413.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt412 : isHalt PRE_first_tail_x1_r0_body.s412.ctl = false
kernel_rfl bodyTop413 : noRetBlock PRE_first_tail_x1_r0_body.s413 = true
kernel_rfl bodyCnt411 : countersOkB PRE_first_tail_x1_r0_body.s411 PRE_first_tail_x1_r0_body.s413 = true
kernel_rfl bodyO413 : PRE_first_tail_x1_r0_body.S413.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S413.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr414 : bridgeOf PRE_first_tail_x1_r0_body.s414.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt413 : countersOkB PRE_first_tail_x1_r0_body.s413 PRE_first_tail_x1_r0_body.s414 = true
kernel_rfl bodyO414 : PRE_first_tail_x1_r0_body.S414.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S414.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc414 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s414 PRE_first_tail_x1_r0_body.S414) = fun _ _ => true
kernel_rfl bodyAcc418 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s418 PRE_first_tail_x1_r0_body.S418) = fun _ _ => true
kernel_rfl bodyBr419 : bridgeOf PRE_first_tail_x1_r0_body.s419.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt418 : isHalt PRE_first_tail_x1_r0_body.s418.ctl = false
kernel_rfl bodyTop419 : noRetBlock PRE_first_tail_x1_r0_body.s419 = true
kernel_rfl bodyCnt414 : countersOkB PRE_first_tail_x1_r0_body.s414 PRE_first_tail_x1_r0_body.s419 = true
kernel_rfl bodyO419 : PRE_first_tail_x1_r0_body.S419.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S419.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr420 : bridgeOf PRE_first_tail_x1_r0_body.s420.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt419 : countersOkB PRE_first_tail_x1_r0_body.s419 PRE_first_tail_x1_r0_body.s420 = true
kernel_rfl bodyO420 : PRE_first_tail_x1_r0_body.S420.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S420.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc420 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s420 PRE_first_tail_x1_r0_body.S420) = fun _ _ => true
kernel_rfl bodyAcc422 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s422 PRE_first_tail_x1_r0_body.S422) = fun _ _ => true
kernel_rfl bodyBr423 : bridgeOf PRE_first_tail_x1_r0_body.s423.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt422 : isHalt PRE_first_tail_x1_r0_body.s422.ctl = false
kernel_rfl bodyTop423 : noRetBlock PRE_first_tail_x1_r0_body.s423 = true
kernel_rfl bodyCnt420 : countersOkB PRE_first_tail_x1_r0_body.s420 PRE_first_tail_x1_r0_body.s423 = true
kernel_rfl bodyO423 : PRE_first_tail_x1_r0_body.S423.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S423.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr424 : bridgeOf PRE_first_tail_x1_r0_body.s424.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt423 : countersOkB PRE_first_tail_x1_r0_body.s423 PRE_first_tail_x1_r0_body.s424 = true
kernel_rfl bodyO424 : PRE_first_tail_x1_r0_body.S424.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S424.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc424 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s424 PRE_first_tail_x1_r0_body.S424) = fun _ _ => true
kernel_rfl bodyAcc425 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s425 PRE_first_tail_x1_r0_body.S425) = fun _ _ => true
kernel_rfl bodyBr426 : bridgeOf PRE_first_tail_x1_r0_body.s426.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt425 : isHalt PRE_first_tail_x1_r0_body.s425.ctl = false
kernel_rfl bodyTop426 : noRetBlock PRE_first_tail_x1_r0_body.s426 = true
kernel_rfl bodyCnt424 : countersOkB PRE_first_tail_x1_r0_body.s424 PRE_first_tail_x1_r0_body.s426 = true
kernel_rfl bodyO426 : PRE_first_tail_x1_r0_body.S426.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S426.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr427 : bridgeOf PRE_first_tail_x1_r0_body.s427.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt426 : countersOkB PRE_first_tail_x1_r0_body.s426 PRE_first_tail_x1_r0_body.s427 = true
kernel_rfl bodyO427 : PRE_first_tail_x1_r0_body.S427.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S427.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc427 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s427 PRE_first_tail_x1_r0_body.S427) = fun _ _ => true
kernel_rfl bodyAcc429 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s429 PRE_first_tail_x1_r0_body.S429) = fun _ _ => true
kernel_rfl bodyBr430 : bridgeOf PRE_first_tail_x1_r0_body.s430.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt429 : isHalt PRE_first_tail_x1_r0_body.s429.ctl = false
kernel_rfl bodyTop430 : noRetBlock PRE_first_tail_x1_r0_body.s430 = true
kernel_rfl bodyCnt427 : countersOkB PRE_first_tail_x1_r0_body.s427 PRE_first_tail_x1_r0_body.s430 = true

theorem bodyGlue19 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨22749, 404, 0, 306⟩ bodyM PRE_first_tail_x1_r0_body.s411 PRE_first_tail_x1_r0_body.S411)
      (bodyCut NB T tk π i x0 bodyΘ ⟨22749, 404, 0, 306⟩ bodyM PRE_first_tail_x1_r0_body.s430 PRE_first_tail_x1_r0_body.S430) 24843 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) bodyAcc411 PRE_first_tail_x1_r0_body.bodyRunSeg109 bodyAcc412 bodyHalt412 PRE_first_tail_x1_r0_body.bodyStepA110 bodyTop413 (fun _ hm => bodyO411 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr411).trans bodyInactive0) (bodyBr413.trans bodyBr411.symm) bodyCnt411 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) PRE_first_tail_x1_r0_body.sizeA110 PRE_first_tail_x1_r0_body.sizeArgsA110 PRE_first_tail_x1_r0_body.sizeSymA110 PRE_first_tail_x1_r0_body.sizeMlxA110 PRE_first_tail_x1_r0_body.sizePayA110 PRE_first_tail_x1_r0_body.sizeTaA110 PRE_first_tail_x1_r0_body.sizeDecA110 PRE_first_tail_x1_r0_body.sizePreA110 PRE_first_tail_x1_r0_body.bodyPatchB110 (fun _ hm => bodyO413 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr413).trans bodyInactive0) (bodyBr414.trans bodyBr413.symm) bodyCnt413 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) bodyAcc414 PRE_first_tail_x1_r0_body.bodyRunSeg110 bodyAcc418 bodyHalt418 PRE_first_tail_x1_r0_body.bodyStepA111 bodyTop419 (fun _ hm => bodyO414 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr414).trans bodyInactive0) (bodyBr419.trans bodyBr414.symm) bodyCnt414 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) PRE_first_tail_x1_r0_body.sizeA111 PRE_first_tail_x1_r0_body.sizeArgsA111 PRE_first_tail_x1_r0_body.sizeSymA111 PRE_first_tail_x1_r0_body.sizeMlxA111 PRE_first_tail_x1_r0_body.sizePayA111 PRE_first_tail_x1_r0_body.sizeTaA111 PRE_first_tail_x1_r0_body.sizeDecA111 PRE_first_tail_x1_r0_body.sizePreA111 PRE_first_tail_x1_r0_body.bodyPatchB111 (fun _ hm => bodyO419 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr419).trans bodyInactive0) (bodyBr420.trans bodyBr419.symm) bodyCnt419 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) bodyAcc420 PRE_first_tail_x1_r0_body.bodyRunSeg111 bodyAcc422 bodyHalt422 PRE_first_tail_x1_r0_body.bodyStepA112 bodyTop423 (fun _ hm => bodyO420 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr420).trans bodyInactive0) (bodyBr423.trans bodyBr420.symm) bodyCnt420 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) PRE_first_tail_x1_r0_body.sizeA112 PRE_first_tail_x1_r0_body.sizeArgsA112 PRE_first_tail_x1_r0_body.sizeSymA112 PRE_first_tail_x1_r0_body.sizeMlxA112 PRE_first_tail_x1_r0_body.sizePayA112 PRE_first_tail_x1_r0_body.sizeTaA112 PRE_first_tail_x1_r0_body.sizeDecA112 PRE_first_tail_x1_r0_body.sizePreA112 PRE_first_tail_x1_r0_body.bodyPatchB112 (fun _ hm => bodyO423 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr423).trans bodyInactive0) (bodyBr424.trans bodyBr423.symm) bodyCnt423 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) bodyAcc424 PRE_first_tail_x1_r0_body.bodyRunSeg112 bodyAcc425 bodyHalt425 PRE_first_tail_x1_r0_body.bodyStepA113 bodyTop426 (fun _ hm => bodyO424 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr424).trans bodyInactive0) (bodyBr426.trans bodyBr424.symm) bodyCnt424 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) PRE_first_tail_x1_r0_body.sizeA113 PRE_first_tail_x1_r0_body.sizeArgsA113 PRE_first_tail_x1_r0_body.sizeSymA113 PRE_first_tail_x1_r0_body.sizeMlxA113 PRE_first_tail_x1_r0_body.sizePayA113 PRE_first_tail_x1_r0_body.sizeTaA113 PRE_first_tail_x1_r0_body.sizeDecA113 PRE_first_tail_x1_r0_body.sizePreA113 PRE_first_tail_x1_r0_body.bodyPatchB113 (fun _ hm => bodyO426 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr426).trans bodyInactive0) (bodyBr427.trans bodyBr426.symm) bodyCnt426 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨22749, 404, 0, 306⟩) bodyAcc427 PRE_first_tail_x1_r0_body.bodyRunSeg113 bodyAcc429 bodyHalt429 PRE_first_tail_x1_r0_body.bodyStepA114 bodyTop430 (fun _ hm => bodyO427 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr427).trans bodyInactive0) (bodyBr430.trans bodyBr427.symm) bodyCnt427 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift19 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S430.tab.length PRE_first_tail_x1_r0_body.s430.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P19.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P19 2294 PRE_first_tail_x1_r0_body.kappa19 PRE_first_tail_x1_r0_body.s432.ffi PRE_first_tail_x1_r0_body.s431.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_19
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_19
  have hcl : SSt (· < 2294) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s432.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S430.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_19] <;> decide) PRE_first_tail_x1_r0_body.cnodesK19 PRE_first_tail_x1_r0_body.cobjsK19
      PRE_first_tail_x1_r0_body.citemsK19 PRE_first_tail_x1_r0_body.cbd19 PRE_first_tail_x1_r0_body.csst19
  exact PRE_first_tail_x1_r0_body.cshift19 bodyNcl19 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_19] at this; exact this)


kernel_rfl bodyFramesEmpty19 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s431 a).isEmpty) = true
kernel_rfl bodyJsRoots19 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s430.next) PRE_first_tail_x1_r0_body.s432.trace PRE_first_tail_x1_r0_body.s432 = true
kernel_rfl bodyJsNative19 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s432.ffi) = true
kernel_rfl bodyLow19 : (PRE_first_tail_x1_r0_body.cws19 ++ PRE_first_tail_x1_r0_body.ws19).all (Nat.ble 9) = true
kernel_rfl bodyCntM19 : countersOkB PRE_first_tail_x1_r0_body.s430 PRE_first_tail_x1_r0_body.s431 = true
kernel_rfl bodyHi19 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s432.ffi).next setupP.E = true
kernel_rfl bodyNhi19 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s432.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge19 : bridgeOf PRE_first_tail_x1_r0_body.s431.ffi = bridgeOf PRE_first_tail_x1_r0_body.s430.ffi
kernel_rfl bodyNN19 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s430.ffi).nnext PRE_first_tail_x1_r0_body.P19.NL = true
kernel_rfl bodyXn19 : Nat.ble (⟨19344, 16430, 2720129, 2294⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s432.ffi).next = true
kernel_rfl bodyLo19 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s432.ffi).next = true
theorem bodyFacts19 : BodySiteFacts PRE_first_tail_x1_r0_body.s430 PRE_first_tail_x1_r0_body.s431 PRE_first_tail_x1_r0_body.s432 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S430 PRE_first_tail_x1_r0_body.S431 PRE_first_tail_x1_r0_body.S432
    PRE_first_tail_x1_r0_body.ws19 PRE_first_tail_x1_r0_body.cws19 PRE_first_tail_x1_r0_body.nr19 PRE_first_tail_x1_r0_body.pl19 PRE_first_tail_x1_r0_body.cl19 2720479 2294 PRE_first_tail_x1_r0_body.kd19 PRE_first_tail_x1_r0_body.kappa19 PRE_first_tail_x1_r0_body.P19
    ⟨19340, 16424, 2720114, 2285⟩ ⟨19344, 16430, 2720129, 2294⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap19
  clean := bodyClean19
  cfix := PRE_first_tail_x1_r0_body.cfix19
  zpl := PRE_first_tail_x1_r0_body.zpl19
  zplnd := PRE_first_tail_x1_r0_body.zplnd19
  zn1 := PRE_first_tail_x1_r0_body.zn119
  zfirst := PRE_first_tail_x1_r0_body.zfirst19
  zscn := PRE_first_tail_x1_r0_body.zscn19
  zsmn := PRE_first_tail_x1_r0_body.zsmn19
  zgrow := PRE_first_tail_x1_r0_body.zgrow19
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab19
  zfresh := PRE_first_tail_x1_r0_body.zfresh19
  zcnd := PRE_first_tail_x1_r0_body.zcnd19
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi19
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt19
  zgP := PRE_first_tail_x1_r0_body.zg19_2665
  zkP := PRE_first_tail_x1_r0_body.zk19_2665
  zmP := PRE_first_tail_x1_r0_body.zm19_2665
  zgC := PRE_first_tail_x1_r0_body.zg19_2673467
  zkC := PRE_first_tail_x1_r0_body.zk19_2673467
  zmC := PRE_first_tail_x1_r0_body.zm19_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw19_2673472
  zwV := PRE_first_tail_x1_r0_body.zw19_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap19
  zclbd := PRE_first_tail_x1_r0_body.zclbd19
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap19 PRE_first_tail_x1_r0_body.stFoot19 PRE_first_tail_x1_r0_body.iso19 PRE_first_tail_x1_r0_body.zwr19
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP19
  csupp := PRE_first_tail_x1_r0_body.csupp19
  cbound := PRE_first_tail_x1_r0_body.cbound19
  zimg := PRE_first_tail_x1_r0_body.zimg19
  zctl := PRE_first_tail_x1_r0_body.zctl19
  zstack := PRE_first_tail_x1_r0_body.zstack19
  zjobs := PRE_first_tail_x1_r0_body.zjobs19
  zstores := PRE_first_tail_x1_r0_body.zstores19
  zroots := PRE_first_tail_x1_r0_body.zroots19
  znC := PRE_first_tail_x1_r0_body.znC19
  ctab := PRE_first_tail_x1_r0_body.ctab19
  zbin := PRE_first_tail_x1_r0_body.zbin19
  cbridge := PRE_first_tail_x1_r0_body.cbridge19
  sbridge := bodyBridge19
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj19
  cshiftR := fun h hNL => bodyCshift19 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN19
  raised := PRE_first_tail_x1_r0_body.raised19
  cbigs := PRE_first_tail_x1_r0_body.cbigs19
  cjcl := PRE_first_tail_x1_r0_body.cjcl19
  xnLe := Nat.le_of_ble_eq_true bodyXn19
  loLe := Nat.le_of_ble_eq_true bodyLo19
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB19
  cntM := bodyCntM19
  hiLe := Nat.le_of_ble_eq_true bodyHi19
  nhiLe := Nat.le_of_ble_eq_true bodyNhi19
  jsHeap := bodyJs19
  jsRoots := bodyJsRoots19
  jsNative := bodyJsNative19
  framesEmpty := bodyFramesEmpty19
  trailOld := by decide
  lowVars := bodyLow19

def bodyQs19 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs19 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr19.map fun r => nth? PRE_first_tail_x1_r0_body.st19.S3.tab r
kernel_rfl bodyResChk19 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs19 bodyQs19) = true
kernel_rfl bodyLq19 : bodyQs19.length = PRE_first_tail_x1_r0_body.cws19.length
kernel_rfl bodyNrLo19 : PRE_first_tail_x1_r0_body.nr19.all (Nat.ble PRE_first_tail_x1_r0_body.S430.tab.length) = true
kernel_rfl bodySub19 : (Oracles.PRE_first_tail_x1_r0_body.map_site19.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost19 : postSubB bodyM PRE_first_tail_x1_r0_body.ws19 PRE_first_tail_x1_r0_body.cws19 bodyQs19 = true
kernel_rfl bodyDrop19 : Nat.ble (22749 + (PRE_first_tail_x1_r0_body.s431.next - PRE_first_tail_x1_r0_body.s432.next)) 23099 = true
kernel_rfl bodyDropH19 : Nat.ble (404 + ((mlxOf PRE_first_tail_x1_r0_body.s431.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s432.ffi).next)) 406 = true
kernel_rfl bodyDropN19 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s431.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s432.ffi).nnext)) 0 = true
kernel_rfl bodyDv19 : bodyΘ.1.take 315 = bodyΘ.1.take 306 ++ PRE_first_tail_x1_r0_body.cws19
kernel_rfl bodyDe19 : bodyΘ.2.take 315 = bodyΘ.2.take 306 ++ PRE_first_tail_x1_r0_body.nr19.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st19.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 306) (bodyΘ.2.take 306)))
kernel_rfl bodyDl19 : (bodyΘ.1.take 306).length = (bodyΘ.2.take 306).length
kernel_rfl bodyDold19 : (bodyΘ.1.take 306).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws19).isNone && !PRE_first_tail_x1_r0_body.ws19.contains v) = true
kernel_rfl bodyDfree19 : (bodyΘ.2.take 315).all (fun e => (PRE_first_tail_x1_r0_body.cws19 ++ PRE_first_tail_x1_r0_body.ws19).all fun w => e.noVar w) = true

theorem bodyStep19 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨22749, 404, 0, 306⟩ bodyM PRE_first_tail_x1_r0_body.s430 PRE_first_tail_x1_r0_body.S430)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23099, 406, 0, 315⟩ bodyM PRE_first_tail_x1_r0_body.s432 PRE_first_tail_x1_r0_body.S432) (3452 + 1) :=
  bodySite bodyFacts19.cfix bodyFacts19.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x1_r0_body.st19.S3.tab) (Es := bodyEs19) (qs := bodyQs19)
    (ok := PRE_first_tail_x1_r0_body.st19.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site19 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts19
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site19 r hr) hi (MapOk.sub hm (sub_of_all bodySub19)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk19 r hr) hi hm ho hq)
    bodyLq19 rfl bodyNrLo19 (postSub_sound bodyPost19)
    (Nat.le_of_ble_eq_true bodyDrop19) (by decide) (Nat.le_of_ble_eq_true bodyDropH19) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN19) (by decide)
    bodyDv19 bodyDe19 bodyDl19 bodyDold19 bodyDfree19 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyOracles_5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_g20 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g20 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g20) (List.take 35 (List.drop 693 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site20 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site20 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site20) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st20.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g21 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g21 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g21) (List.take 32 (List.drop 728 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site21 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site21 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site21) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st21.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g22 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n), (1945, Q.n), (1946, Q.n), (1948, Q.n), (1949, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1955, Q.n), (1956, Q.n), (1958, Q.n), (1959, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g22 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g22) (List.take 32 (List.drop 760 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site22 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n), (1945, Q.n), (1946, Q.n), (1948, Q.n), (1949, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1955, Q.n), (1956, Q.n), (1958, Q.n), (1959, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site22 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site22) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st22.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g23 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n), (1945, Q.n), (1946, Q.n), (1948, Q.n), (1949, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1955, Q.n), (1956, Q.n), (1958, Q.n), (1959, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1994, Q.n), (1995, Q.n), (1997, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2004, Q.n), (2005, Q.n), (2007, Q.n), (2008, Q.n), (2009, Q.n), (2010, Q.n), (2011, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g23 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g23) (List.take 43 (List.drop 792 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site23 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n), (1945, Q.n), (1946, Q.n), (1948, Q.n), (1949, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1955, Q.n), (1956, Q.n), (1958, Q.n), (1959, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1994, Q.n), (1995, Q.n), (1997, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2004, Q.n), (2005, Q.n), (2007, Q.n), (2008, Q.n), (2009, Q.n), (2010, Q.n), (2011, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site23 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site23) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st23.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site20 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site20 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site20) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st20.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site20
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st20.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st20.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s452 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s453 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S452 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws20 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st20.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st20.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso20
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_20
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st20.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot20
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup20
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound20
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace20
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged20
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws20.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st20.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S452.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_20]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen20.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh20
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl20 : Conv.NClean (⟨19399, 16463, 2722485, 2395⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s452.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl20 (PRE_first_tail_x1_r0_body.cncl19 bodyNcl19)

theorem bodyClean20 : Conv.JClean (⟨19399, 16463, 2722485, 2395⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s452 :=
  PRE_first_tail_x1_r0_body.gjcl20 (PRE_first_tail_x1_r0_body.cjcl19 bodyClean19)

kernel_rfl bodyJsLe20 : Nat.ble PRE_first_tail_x1_r0_body.s430.next PRE_first_tail_x1_r0_body.s452.next = true
kernel_rfl bodyJsList20 : (PRE_first_tail_x1_r0_body.gjh20 ++ PRE_first_tail_x1_r0_body.cl20).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s452.next) PRE_first_tail_x1_r0_body.s454) = true
theorem bodyJs20 : JsHeapAbove PRE_first_tail_x1_r0_body.s452.next PRE_first_tail_x1_r0_body.s454 :=
  JsHeapAbove.glueSite bodyJs19 (Nat.le_of_ble_eq_true bodyJsLe20) PRE_first_tail_x1_r0_body.gjk20 PRE_first_tail_x1_r0_body.gjbd20 PRE_first_tail_x1_r0_body.cheap20 PRE_first_tail_x1_r0_body.zclbd20 bodyJsList20

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO432 : PRE_first_tail_x1_r0_body.S432.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S432.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr432 : bridgeOf PRE_first_tail_x1_r0_body.s432.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc432 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s432 PRE_first_tail_x1_r0_body.S432) = fun _ _ => true
kernel_rfl bodyAcc433 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s433 PRE_first_tail_x1_r0_body.S433) = fun _ _ => true
kernel_rfl bodyBr434 : bridgeOf PRE_first_tail_x1_r0_body.s434.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt433 : isHalt PRE_first_tail_x1_r0_body.s433.ctl = false
kernel_rfl bodyTop434 : noRetBlock PRE_first_tail_x1_r0_body.s434 = true
kernel_rfl bodyCnt432 : countersOkB PRE_first_tail_x1_r0_body.s432 PRE_first_tail_x1_r0_body.s434 = true
kernel_rfl bodyO434 : PRE_first_tail_x1_r0_body.S434.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S434.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr435 : bridgeOf PRE_first_tail_x1_r0_body.s435.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt434 : countersOkB PRE_first_tail_x1_r0_body.s434 PRE_first_tail_x1_r0_body.s435 = true
kernel_rfl bodyO435 : PRE_first_tail_x1_r0_body.S435.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S435.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc435 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s435 PRE_first_tail_x1_r0_body.S435) = fun _ _ => true
kernel_rfl bodyAcc439 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s439 PRE_first_tail_x1_r0_body.S439) = fun _ _ => true
kernel_rfl bodyBr440 : bridgeOf PRE_first_tail_x1_r0_body.s440.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt439 : isHalt PRE_first_tail_x1_r0_body.s439.ctl = false
kernel_rfl bodyTop440 : noRetBlock PRE_first_tail_x1_r0_body.s440 = true
kernel_rfl bodyCnt435 : countersOkB PRE_first_tail_x1_r0_body.s435 PRE_first_tail_x1_r0_body.s440 = true
kernel_rfl bodyO440 : PRE_first_tail_x1_r0_body.S440.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S440.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr441 : bridgeOf PRE_first_tail_x1_r0_body.s441.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt440 : countersOkB PRE_first_tail_x1_r0_body.s440 PRE_first_tail_x1_r0_body.s441 = true
kernel_rfl bodyO441 : PRE_first_tail_x1_r0_body.S441.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S441.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc441 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s441 PRE_first_tail_x1_r0_body.S441) = fun _ _ => true
kernel_rfl bodyAcc442 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s442 PRE_first_tail_x1_r0_body.S442) = fun _ _ => true
kernel_rfl bodyBr443 : bridgeOf PRE_first_tail_x1_r0_body.s443.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt442 : isHalt PRE_first_tail_x1_r0_body.s442.ctl = false
kernel_rfl bodyTop443 : noRetBlock PRE_first_tail_x1_r0_body.s443 = true
kernel_rfl bodyCnt441 : countersOkB PRE_first_tail_x1_r0_body.s441 PRE_first_tail_x1_r0_body.s443 = true
kernel_rfl bodyO443 : PRE_first_tail_x1_r0_body.S443.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S443.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr444 : bridgeOf PRE_first_tail_x1_r0_body.s444.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt443 : countersOkB PRE_first_tail_x1_r0_body.s443 PRE_first_tail_x1_r0_body.s444 = true
kernel_rfl bodyO444 : PRE_first_tail_x1_r0_body.S444.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S444.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc444 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s444 PRE_first_tail_x1_r0_body.S444) = fun _ _ => true
kernel_rfl bodyAcc445 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s445 PRE_first_tail_x1_r0_body.S445) = fun _ _ => true
kernel_rfl bodyBr446 : bridgeOf PRE_first_tail_x1_r0_body.s446.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt445 : isHalt PRE_first_tail_x1_r0_body.s445.ctl = false
kernel_rfl bodyTop446 : noRetBlock PRE_first_tail_x1_r0_body.s446 = true
kernel_rfl bodyCnt444 : countersOkB PRE_first_tail_x1_r0_body.s444 PRE_first_tail_x1_r0_body.s446 = true
kernel_rfl bodyO446 : PRE_first_tail_x1_r0_body.S446.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S446.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr447 : bridgeOf PRE_first_tail_x1_r0_body.s447.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt446 : countersOkB PRE_first_tail_x1_r0_body.s446 PRE_first_tail_x1_r0_body.s447 = true
kernel_rfl bodyO447 : PRE_first_tail_x1_r0_body.S447.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S447.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc447 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s447 PRE_first_tail_x1_r0_body.S447) = fun _ _ => true
kernel_rfl bodyAcc448 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s448 PRE_first_tail_x1_r0_body.S448) = fun _ _ => true
kernel_rfl bodyBr449 : bridgeOf PRE_first_tail_x1_r0_body.s449.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt448 : isHalt PRE_first_tail_x1_r0_body.s448.ctl = false
kernel_rfl bodyTop449 : noRetBlock PRE_first_tail_x1_r0_body.s449 = true
kernel_rfl bodyCnt447 : countersOkB PRE_first_tail_x1_r0_body.s447 PRE_first_tail_x1_r0_body.s449 = true
kernel_rfl bodyO449 : PRE_first_tail_x1_r0_body.S449.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S449.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr450 : bridgeOf PRE_first_tail_x1_r0_body.s450.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt449 : countersOkB PRE_first_tail_x1_r0_body.s449 PRE_first_tail_x1_r0_body.s450 = true
kernel_rfl bodyO450 : PRE_first_tail_x1_r0_body.S450.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S450.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc450 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s450 PRE_first_tail_x1_r0_body.S450) = fun _ _ => true
kernel_rfl bodyAcc451 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s451 PRE_first_tail_x1_r0_body.S451) = fun _ _ => true
kernel_rfl bodyBr452 : bridgeOf PRE_first_tail_x1_r0_body.s452.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt451 : isHalt PRE_first_tail_x1_r0_body.s451.ctl = false
kernel_rfl bodyTop452 : noRetBlock PRE_first_tail_x1_r0_body.s452 = true
kernel_rfl bodyCnt450 : countersOkB PRE_first_tail_x1_r0_body.s450 PRE_first_tail_x1_r0_body.s452 = true

theorem bodyGlue20 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23099, 406, 0, 315⟩ bodyM PRE_first_tail_x1_r0_body.s432 PRE_first_tail_x1_r0_body.S432)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23099, 406, 0, 315⟩ bodyM PRE_first_tail_x1_r0_body.s452 PRE_first_tail_x1_r0_body.S452) 23475 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) bodyAcc432 PRE_first_tail_x1_r0_body.bodyRunSeg114 bodyAcc433 bodyHalt433 PRE_first_tail_x1_r0_body.bodyStepA115 bodyTop434 (fun _ hm => bodyO432 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr432).trans bodyInactive0) (bodyBr434.trans bodyBr432.symm) bodyCnt432 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) PRE_first_tail_x1_r0_body.sizeA115 PRE_first_tail_x1_r0_body.sizeArgsA115 PRE_first_tail_x1_r0_body.sizeSymA115 PRE_first_tail_x1_r0_body.sizeMlxA115 PRE_first_tail_x1_r0_body.sizePayA115 PRE_first_tail_x1_r0_body.sizeTaA115 PRE_first_tail_x1_r0_body.sizeDecA115 PRE_first_tail_x1_r0_body.sizePreA115 PRE_first_tail_x1_r0_body.bodyPatchB115 (fun _ hm => bodyO434 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr434).trans bodyInactive0) (bodyBr435.trans bodyBr434.symm) bodyCnt434 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) bodyAcc435 PRE_first_tail_x1_r0_body.bodyRunSeg115 bodyAcc439 bodyHalt439 PRE_first_tail_x1_r0_body.bodyStepA116 bodyTop440 (fun _ hm => bodyO435 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr435).trans bodyInactive0) (bodyBr440.trans bodyBr435.symm) bodyCnt435 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) PRE_first_tail_x1_r0_body.sizeA116 PRE_first_tail_x1_r0_body.sizeArgsA116 PRE_first_tail_x1_r0_body.sizeSymA116 PRE_first_tail_x1_r0_body.sizeMlxA116 PRE_first_tail_x1_r0_body.sizePayA116 PRE_first_tail_x1_r0_body.sizeTaA116 PRE_first_tail_x1_r0_body.sizeDecA116 PRE_first_tail_x1_r0_body.sizePreA116 PRE_first_tail_x1_r0_body.bodyPatchB116 (fun _ hm => bodyO440 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr440).trans bodyInactive0) (bodyBr441.trans bodyBr440.symm) bodyCnt440 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) bodyAcc441 PRE_first_tail_x1_r0_body.bodyRunSeg116 bodyAcc442 bodyHalt442 PRE_first_tail_x1_r0_body.bodyStepA117 bodyTop443 (fun _ hm => bodyO441 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr441).trans bodyInactive0) (bodyBr443.trans bodyBr441.symm) bodyCnt441 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) PRE_first_tail_x1_r0_body.sizeA117 PRE_first_tail_x1_r0_body.sizeArgsA117 PRE_first_tail_x1_r0_body.sizeSymA117 PRE_first_tail_x1_r0_body.sizeMlxA117 PRE_first_tail_x1_r0_body.sizePayA117 PRE_first_tail_x1_r0_body.sizeTaA117 PRE_first_tail_x1_r0_body.sizeDecA117 PRE_first_tail_x1_r0_body.sizePreA117 PRE_first_tail_x1_r0_body.bodyPatchB117 (fun _ hm => bodyO443 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr443).trans bodyInactive0) (bodyBr444.trans bodyBr443.symm) bodyCnt443 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) bodyAcc444 PRE_first_tail_x1_r0_body.bodyRunSeg117 bodyAcc445 bodyHalt445 PRE_first_tail_x1_r0_body.bodyStepA118 bodyTop446 (fun _ hm => bodyO444 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr444).trans bodyInactive0) (bodyBr446.trans bodyBr444.symm) bodyCnt444 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) PRE_first_tail_x1_r0_body.sizeA118 PRE_first_tail_x1_r0_body.sizeArgsA118 PRE_first_tail_x1_r0_body.sizeSymA118 PRE_first_tail_x1_r0_body.sizeMlxA118 PRE_first_tail_x1_r0_body.sizePayA118 PRE_first_tail_x1_r0_body.sizeTaA118 PRE_first_tail_x1_r0_body.sizeDecA118 PRE_first_tail_x1_r0_body.sizePreA118 PRE_first_tail_x1_r0_body.bodyPatchB118 (fun _ hm => bodyO446 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr446).trans bodyInactive0) (bodyBr447.trans bodyBr446.symm) bodyCnt446 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) bodyAcc447 PRE_first_tail_x1_r0_body.bodyRunSeg118 bodyAcc448 bodyHalt448 PRE_first_tail_x1_r0_body.bodyStepA119 bodyTop449 (fun _ hm => bodyO447 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr447).trans bodyInactive0) (bodyBr449.trans bodyBr447.symm) bodyCnt447 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) PRE_first_tail_x1_r0_body.sizeA119 PRE_first_tail_x1_r0_body.sizeArgsA119 PRE_first_tail_x1_r0_body.sizeSymA119 PRE_first_tail_x1_r0_body.sizeMlxA119 PRE_first_tail_x1_r0_body.sizePayA119 PRE_first_tail_x1_r0_body.sizeTaA119 PRE_first_tail_x1_r0_body.sizeDecA119 PRE_first_tail_x1_r0_body.sizePreA119 PRE_first_tail_x1_r0_body.bodyPatchB119 (fun _ hm => bodyO449 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr449).trans bodyInactive0) (bodyBr450.trans bodyBr449.symm) bodyCnt449 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23099, 406, 0, 315⟩) bodyAcc450 PRE_first_tail_x1_r0_body.bodyRunSeg119 bodyAcc451 bodyHalt451 PRE_first_tail_x1_r0_body.bodyStepA120 bodyTop452 (fun _ hm => bodyO450 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr450).trans bodyInactive0) (bodyBr452.trans bodyBr450.symm) bodyCnt450 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift20 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S452.tab.length PRE_first_tail_x1_r0_body.s452.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P20.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P20 2413 PRE_first_tail_x1_r0_body.kappa20 PRE_first_tail_x1_r0_body.s454.ffi PRE_first_tail_x1_r0_body.s453.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_20
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_20
  have hcl : SSt (· < 2413) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s454.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S452.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_20] <;> decide) PRE_first_tail_x1_r0_body.cnodesK20 PRE_first_tail_x1_r0_body.cobjsK20
      PRE_first_tail_x1_r0_body.citemsK20 PRE_first_tail_x1_r0_body.cbd20 PRE_first_tail_x1_r0_body.csst20
  exact PRE_first_tail_x1_r0_body.cshift20 bodyNcl20 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_20] at this; exact this)


kernel_rfl bodyFramesEmpty20 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s453 a).isEmpty) = true
kernel_rfl bodyJsRoots20 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s452.next) PRE_first_tail_x1_r0_body.s454.trace PRE_first_tail_x1_r0_body.s454 = true
kernel_rfl bodyJsNative20 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s454.ffi) = true
kernel_rfl bodyLow20 : (PRE_first_tail_x1_r0_body.cws20 ++ PRE_first_tail_x1_r0_body.ws20).all (Nat.ble 9) = true
kernel_rfl bodyCntM20 : countersOkB PRE_first_tail_x1_r0_body.s452 PRE_first_tail_x1_r0_body.s453 = true
kernel_rfl bodyHi20 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s454.ffi).next setupP.E = true
kernel_rfl bodyNhi20 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s454.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge20 : bridgeOf PRE_first_tail_x1_r0_body.s453.ffi = bridgeOf PRE_first_tail_x1_r0_body.s452.ffi
kernel_rfl bodyNN20 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s452.ffi).nnext PRE_first_tail_x1_r0_body.P20.NL = true
kernel_rfl bodyXn20 : Nat.ble (⟨19402, 16490, 2722491, 2413⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s454.ffi).next = true
kernel_rfl bodyLo20 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s454.ffi).next = true
theorem bodyFacts20 : BodySiteFacts PRE_first_tail_x1_r0_body.s452 PRE_first_tail_x1_r0_body.s453 PRE_first_tail_x1_r0_body.s454 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S452 PRE_first_tail_x1_r0_body.S453 PRE_first_tail_x1_r0_body.S454
    PRE_first_tail_x1_r0_body.ws20 PRE_first_tail_x1_r0_body.cws20 PRE_first_tail_x1_r0_body.nr20 PRE_first_tail_x1_r0_body.pl20 PRE_first_tail_x1_r0_body.cl20 2723640 2413 PRE_first_tail_x1_r0_body.kd20 PRE_first_tail_x1_r0_body.kappa20 PRE_first_tail_x1_r0_body.P20
    ⟨19399, 16463, 2722485, 2395⟩ ⟨19402, 16490, 2722491, 2413⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap20
  clean := bodyClean20
  cfix := PRE_first_tail_x1_r0_body.cfix20
  zpl := PRE_first_tail_x1_r0_body.zpl20
  zplnd := PRE_first_tail_x1_r0_body.zplnd20
  zn1 := PRE_first_tail_x1_r0_body.zn120
  zfirst := PRE_first_tail_x1_r0_body.zfirst20
  zscn := PRE_first_tail_x1_r0_body.zscn20
  zsmn := PRE_first_tail_x1_r0_body.zsmn20
  zgrow := PRE_first_tail_x1_r0_body.zgrow20
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab20
  zfresh := PRE_first_tail_x1_r0_body.zfresh20
  zcnd := PRE_first_tail_x1_r0_body.zcnd20
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi20
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt20
  zgP := PRE_first_tail_x1_r0_body.zg20_2665
  zkP := PRE_first_tail_x1_r0_body.zk20_2665
  zmP := PRE_first_tail_x1_r0_body.zm20_2665
  zgC := PRE_first_tail_x1_r0_body.zg20_2673467
  zkC := PRE_first_tail_x1_r0_body.zk20_2673467
  zmC := PRE_first_tail_x1_r0_body.zm20_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw20_2673472
  zwV := PRE_first_tail_x1_r0_body.zw20_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap20
  zclbd := PRE_first_tail_x1_r0_body.zclbd20
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap20 PRE_first_tail_x1_r0_body.stFoot20 PRE_first_tail_x1_r0_body.iso20 PRE_first_tail_x1_r0_body.zwr20
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP20
  csupp := PRE_first_tail_x1_r0_body.csupp20
  cbound := PRE_first_tail_x1_r0_body.cbound20
  zimg := PRE_first_tail_x1_r0_body.zimg20
  zctl := PRE_first_tail_x1_r0_body.zctl20
  zstack := PRE_first_tail_x1_r0_body.zstack20
  zjobs := PRE_first_tail_x1_r0_body.zjobs20
  zstores := PRE_first_tail_x1_r0_body.zstores20
  zroots := PRE_first_tail_x1_r0_body.zroots20
  znC := PRE_first_tail_x1_r0_body.znC20
  ctab := PRE_first_tail_x1_r0_body.ctab20
  zbin := PRE_first_tail_x1_r0_body.zbin20
  cbridge := PRE_first_tail_x1_r0_body.cbridge20
  sbridge := bodyBridge20
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj20
  cshiftR := fun h hNL => bodyCshift20 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN20
  raised := PRE_first_tail_x1_r0_body.raised20
  cbigs := PRE_first_tail_x1_r0_body.cbigs20
  cjcl := PRE_first_tail_x1_r0_body.cjcl20
  xnLe := Nat.le_of_ble_eq_true bodyXn20
  loLe := Nat.le_of_ble_eq_true bodyLo20
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB20
  cntM := bodyCntM20
  hiLe := Nat.le_of_ble_eq_true bodyHi20
  nhiLe := Nat.le_of_ble_eq_true bodyNhi20
  jsHeap := bodyJs20
  jsRoots := bodyJsRoots20
  jsNative := bodyJsNative20
  framesEmpty := bodyFramesEmpty20
  trailOld := by decide
  lowVars := bodyLow20

def bodyQs20 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs20 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr20.map fun r => nth? PRE_first_tail_x1_r0_body.st20.S5.tab r
kernel_rfl bodyResChk20 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs20 bodyQs20) = true
kernel_rfl bodyLq20 : bodyQs20.length = PRE_first_tail_x1_r0_body.cws20.length
kernel_rfl bodyNrLo20 : PRE_first_tail_x1_r0_body.nr20.all (Nat.ble PRE_first_tail_x1_r0_body.S452.tab.length) = true
kernel_rfl bodySub20 : (Oracles.PRE_first_tail_x1_r0_body.map_site20.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost20 : postSubB bodyM PRE_first_tail_x1_r0_body.ws20 PRE_first_tail_x1_r0_body.cws20 bodyQs20 = true
kernel_rfl bodyDrop20 : Nat.ble (23099 + (PRE_first_tail_x1_r0_body.s453.next - PRE_first_tail_x1_r0_body.s454.next)) 24248 = true
kernel_rfl bodyDropH20 : Nat.ble (406 + ((mlxOf PRE_first_tail_x1_r0_body.s453.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s454.ffi).next)) 431 = true
kernel_rfl bodyDropN20 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s453.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s454.ffi).nnext)) 0 = true
kernel_rfl bodyDv20 : bodyΘ.1.take 333 = bodyΘ.1.take 315 ++ PRE_first_tail_x1_r0_body.cws20
kernel_rfl bodyDe20 : bodyΘ.2.take 333 = bodyΘ.2.take 315 ++ PRE_first_tail_x1_r0_body.nr20.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st20.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 315) (bodyΘ.2.take 315)))
kernel_rfl bodyDl20 : (bodyΘ.1.take 315).length = (bodyΘ.2.take 315).length
kernel_rfl bodyDold20 : (bodyΘ.1.take 315).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws20).isNone && !PRE_first_tail_x1_r0_body.ws20.contains v) = true
kernel_rfl bodyDfree20 : (bodyΘ.2.take 333).all (fun e => (PRE_first_tail_x1_r0_body.cws20 ++ PRE_first_tail_x1_r0_body.ws20).all fun w => e.noVar w) = true

theorem bodyStep20 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23099, 406, 0, 315⟩ bodyM PRE_first_tail_x1_r0_body.s452 PRE_first_tail_x1_r0_body.S452)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24248, 431, 0, 333⟩ bodyM PRE_first_tail_x1_r0_body.s454 PRE_first_tail_x1_r0_body.S454) (11334 + 1) :=
  bodySite bodyFacts20.cfix bodyFacts20.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st20.S5.tab) (Es := bodyEs20) (qs := bodyQs20)
    (ok := PRE_first_tail_x1_r0_body.st20.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site20 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts20
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site20 r hr) hi (MapOk.sub hm (sub_of_all bodySub20)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk20 r hr) hi hm ho hq)
    bodyLq20 rfl bodyNrLo20 (postSub_sound bodyPost20)
    (Nat.le_of_ble_eq_true bodyDrop20) (by decide) (Nat.le_of_ble_eq_true bodyDropH20) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN20) (by decide)
    bodyDv20 bodyDe20 bodyDl20 bodyDold20 bodyDfree20 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site21 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site21 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site21) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st21.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site21
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st21.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st21.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s474 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s475 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S474 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws21 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st21.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st21.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso21
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_21
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st21.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot21
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup21
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound21
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace21
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged21
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws21.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st21.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S474.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_21]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen21.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh21
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl21 : Conv.NClean (⟨19456, 16526, 2724733, 2511⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s474.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl21 (PRE_first_tail_x1_r0_body.cncl20 bodyNcl20)

theorem bodyClean21 : Conv.JClean (⟨19456, 16526, 2724733, 2511⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s474 :=
  PRE_first_tail_x1_r0_body.gjcl21 (PRE_first_tail_x1_r0_body.cjcl20 bodyClean20)

kernel_rfl bodyJsLe21 : Nat.ble PRE_first_tail_x1_r0_body.s452.next PRE_first_tail_x1_r0_body.s474.next = true
kernel_rfl bodyJsList21 : (PRE_first_tail_x1_r0_body.gjh21 ++ PRE_first_tail_x1_r0_body.cl21).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s474.next) PRE_first_tail_x1_r0_body.s476) = true
theorem bodyJs21 : JsHeapAbove PRE_first_tail_x1_r0_body.s474.next PRE_first_tail_x1_r0_body.s476 :=
  JsHeapAbove.glueSite bodyJs20 (Nat.le_of_ble_eq_true bodyJsLe21) PRE_first_tail_x1_r0_body.gjk21 PRE_first_tail_x1_r0_body.gjbd21 PRE_first_tail_x1_r0_body.cheap21 PRE_first_tail_x1_r0_body.zclbd21 bodyJsList21

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO454 : PRE_first_tail_x1_r0_body.S454.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S454.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr454 : bridgeOf PRE_first_tail_x1_r0_body.s454.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc454 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s454 PRE_first_tail_x1_r0_body.S454) = fun _ _ => true
kernel_rfl bodyAcc455 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s455 PRE_first_tail_x1_r0_body.S455) = fun _ _ => true
kernel_rfl bodyBr456 : bridgeOf PRE_first_tail_x1_r0_body.s456.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt455 : isHalt PRE_first_tail_x1_r0_body.s455.ctl = false
kernel_rfl bodyTop456 : noRetBlock PRE_first_tail_x1_r0_body.s456 = true
kernel_rfl bodyCnt454 : countersOkB PRE_first_tail_x1_r0_body.s454 PRE_first_tail_x1_r0_body.s456 = true
kernel_rfl bodyO456 : PRE_first_tail_x1_r0_body.S456.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S456.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr457 : bridgeOf PRE_first_tail_x1_r0_body.s457.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt456 : countersOkB PRE_first_tail_x1_r0_body.s456 PRE_first_tail_x1_r0_body.s457 = true
kernel_rfl bodyO457 : PRE_first_tail_x1_r0_body.S457.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S457.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc457 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s457 PRE_first_tail_x1_r0_body.S457) = fun _ _ => true
kernel_rfl bodyAcc461 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s461 PRE_first_tail_x1_r0_body.S461) = fun _ _ => true
kernel_rfl bodyBr462 : bridgeOf PRE_first_tail_x1_r0_body.s462.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt461 : isHalt PRE_first_tail_x1_r0_body.s461.ctl = false
kernel_rfl bodyTop462 : noRetBlock PRE_first_tail_x1_r0_body.s462 = true
kernel_rfl bodyCnt457 : countersOkB PRE_first_tail_x1_r0_body.s457 PRE_first_tail_x1_r0_body.s462 = true
kernel_rfl bodyO462 : PRE_first_tail_x1_r0_body.S462.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S462.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr463 : bridgeOf PRE_first_tail_x1_r0_body.s463.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt462 : countersOkB PRE_first_tail_x1_r0_body.s462 PRE_first_tail_x1_r0_body.s463 = true
kernel_rfl bodyO463 : PRE_first_tail_x1_r0_body.S463.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S463.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc463 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s463 PRE_first_tail_x1_r0_body.S463) = fun _ _ => true
kernel_rfl bodyAcc464 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s464 PRE_first_tail_x1_r0_body.S464) = fun _ _ => true
kernel_rfl bodyBr465 : bridgeOf PRE_first_tail_x1_r0_body.s465.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt464 : isHalt PRE_first_tail_x1_r0_body.s464.ctl = false
kernel_rfl bodyTop465 : noRetBlock PRE_first_tail_x1_r0_body.s465 = true
kernel_rfl bodyCnt463 : countersOkB PRE_first_tail_x1_r0_body.s463 PRE_first_tail_x1_r0_body.s465 = true
kernel_rfl bodyO465 : PRE_first_tail_x1_r0_body.S465.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S465.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr466 : bridgeOf PRE_first_tail_x1_r0_body.s466.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt465 : countersOkB PRE_first_tail_x1_r0_body.s465 PRE_first_tail_x1_r0_body.s466 = true
kernel_rfl bodyO466 : PRE_first_tail_x1_r0_body.S466.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S466.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc466 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s466 PRE_first_tail_x1_r0_body.S466) = fun _ _ => true
kernel_rfl bodyAcc467 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s467 PRE_first_tail_x1_r0_body.S467) = fun _ _ => true
kernel_rfl bodyBr468 : bridgeOf PRE_first_tail_x1_r0_body.s468.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt467 : isHalt PRE_first_tail_x1_r0_body.s467.ctl = false
kernel_rfl bodyTop468 : noRetBlock PRE_first_tail_x1_r0_body.s468 = true
kernel_rfl bodyCnt466 : countersOkB PRE_first_tail_x1_r0_body.s466 PRE_first_tail_x1_r0_body.s468 = true
kernel_rfl bodyO468 : PRE_first_tail_x1_r0_body.S468.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S468.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr469 : bridgeOf PRE_first_tail_x1_r0_body.s469.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt468 : countersOkB PRE_first_tail_x1_r0_body.s468 PRE_first_tail_x1_r0_body.s469 = true
kernel_rfl bodyO469 : PRE_first_tail_x1_r0_body.S469.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S469.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc469 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s469 PRE_first_tail_x1_r0_body.S469) = fun _ _ => true
kernel_rfl bodyAcc470 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s470 PRE_first_tail_x1_r0_body.S470) = fun _ _ => true
kernel_rfl bodyBr471 : bridgeOf PRE_first_tail_x1_r0_body.s471.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt470 : isHalt PRE_first_tail_x1_r0_body.s470.ctl = false
kernel_rfl bodyTop471 : noRetBlock PRE_first_tail_x1_r0_body.s471 = true
kernel_rfl bodyCnt469 : countersOkB PRE_first_tail_x1_r0_body.s469 PRE_first_tail_x1_r0_body.s471 = true
kernel_rfl bodyO471 : PRE_first_tail_x1_r0_body.S471.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S471.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr472 : bridgeOf PRE_first_tail_x1_r0_body.s472.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt471 : countersOkB PRE_first_tail_x1_r0_body.s471 PRE_first_tail_x1_r0_body.s472 = true
kernel_rfl bodyO472 : PRE_first_tail_x1_r0_body.S472.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S472.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc472 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s472 PRE_first_tail_x1_r0_body.S472) = fun _ _ => true
kernel_rfl bodyAcc473 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s473 PRE_first_tail_x1_r0_body.S473) = fun _ _ => true
kernel_rfl bodyBr474 : bridgeOf PRE_first_tail_x1_r0_body.s474.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt473 : isHalt PRE_first_tail_x1_r0_body.s473.ctl = false
kernel_rfl bodyTop474 : noRetBlock PRE_first_tail_x1_r0_body.s474 = true
kernel_rfl bodyCnt472 : countersOkB PRE_first_tail_x1_r0_body.s472 PRE_first_tail_x1_r0_body.s474 = true

theorem bodyGlue21 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24248, 431, 0, 333⟩ bodyM PRE_first_tail_x1_r0_body.s454 PRE_first_tail_x1_r0_body.S454)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24248, 431, 0, 333⟩ bodyM PRE_first_tail_x1_r0_body.s474 PRE_first_tail_x1_r0_body.S474) 22362 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) bodyAcc454 PRE_first_tail_x1_r0_body.bodyRunSeg120 bodyAcc455 bodyHalt455 PRE_first_tail_x1_r0_body.bodyStepA121 bodyTop456 (fun _ hm => bodyO454 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr454).trans bodyInactive0) (bodyBr456.trans bodyBr454.symm) bodyCnt454 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) PRE_first_tail_x1_r0_body.sizeA121 PRE_first_tail_x1_r0_body.sizeArgsA121 PRE_first_tail_x1_r0_body.sizeSymA121 PRE_first_tail_x1_r0_body.sizeMlxA121 PRE_first_tail_x1_r0_body.sizePayA121 PRE_first_tail_x1_r0_body.sizeTaA121 PRE_first_tail_x1_r0_body.sizeDecA121 PRE_first_tail_x1_r0_body.sizePreA121 PRE_first_tail_x1_r0_body.bodyPatchB121 (fun _ hm => bodyO456 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr456).trans bodyInactive0) (bodyBr457.trans bodyBr456.symm) bodyCnt456 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) bodyAcc457 PRE_first_tail_x1_r0_body.bodyRunSeg121 bodyAcc461 bodyHalt461 PRE_first_tail_x1_r0_body.bodyStepA122 bodyTop462 (fun _ hm => bodyO457 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr457).trans bodyInactive0) (bodyBr462.trans bodyBr457.symm) bodyCnt457 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) PRE_first_tail_x1_r0_body.sizeA122 PRE_first_tail_x1_r0_body.sizeArgsA122 PRE_first_tail_x1_r0_body.sizeSymA122 PRE_first_tail_x1_r0_body.sizeMlxA122 PRE_first_tail_x1_r0_body.sizePayA122 PRE_first_tail_x1_r0_body.sizeTaA122 PRE_first_tail_x1_r0_body.sizeDecA122 PRE_first_tail_x1_r0_body.sizePreA122 PRE_first_tail_x1_r0_body.bodyPatchB122 (fun _ hm => bodyO462 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr462).trans bodyInactive0) (bodyBr463.trans bodyBr462.symm) bodyCnt462 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) bodyAcc463 PRE_first_tail_x1_r0_body.bodyRunSeg122 bodyAcc464 bodyHalt464 PRE_first_tail_x1_r0_body.bodyStepA123 bodyTop465 (fun _ hm => bodyO463 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr463).trans bodyInactive0) (bodyBr465.trans bodyBr463.symm) bodyCnt463 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) PRE_first_tail_x1_r0_body.sizeA123 PRE_first_tail_x1_r0_body.sizeArgsA123 PRE_first_tail_x1_r0_body.sizeSymA123 PRE_first_tail_x1_r0_body.sizeMlxA123 PRE_first_tail_x1_r0_body.sizePayA123 PRE_first_tail_x1_r0_body.sizeTaA123 PRE_first_tail_x1_r0_body.sizeDecA123 PRE_first_tail_x1_r0_body.sizePreA123 PRE_first_tail_x1_r0_body.bodyPatchB123 (fun _ hm => bodyO465 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr465).trans bodyInactive0) (bodyBr466.trans bodyBr465.symm) bodyCnt465 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) bodyAcc466 PRE_first_tail_x1_r0_body.bodyRunSeg123 bodyAcc467 bodyHalt467 PRE_first_tail_x1_r0_body.bodyStepA124 bodyTop468 (fun _ hm => bodyO466 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr466).trans bodyInactive0) (bodyBr468.trans bodyBr466.symm) bodyCnt466 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) PRE_first_tail_x1_r0_body.sizeA124 PRE_first_tail_x1_r0_body.sizeArgsA124 PRE_first_tail_x1_r0_body.sizeSymA124 PRE_first_tail_x1_r0_body.sizeMlxA124 PRE_first_tail_x1_r0_body.sizePayA124 PRE_first_tail_x1_r0_body.sizeTaA124 PRE_first_tail_x1_r0_body.sizeDecA124 PRE_first_tail_x1_r0_body.sizePreA124 PRE_first_tail_x1_r0_body.bodyPatchB124 (fun _ hm => bodyO468 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr468).trans bodyInactive0) (bodyBr469.trans bodyBr468.symm) bodyCnt468 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) bodyAcc469 PRE_first_tail_x1_r0_body.bodyRunSeg124 bodyAcc470 bodyHalt470 PRE_first_tail_x1_r0_body.bodyStepA125 bodyTop471 (fun _ hm => bodyO469 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr469).trans bodyInactive0) (bodyBr471.trans bodyBr469.symm) bodyCnt469 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) PRE_first_tail_x1_r0_body.sizeA125 PRE_first_tail_x1_r0_body.sizeArgsA125 PRE_first_tail_x1_r0_body.sizeSymA125 PRE_first_tail_x1_r0_body.sizeMlxA125 PRE_first_tail_x1_r0_body.sizePayA125 PRE_first_tail_x1_r0_body.sizeTaA125 PRE_first_tail_x1_r0_body.sizeDecA125 PRE_first_tail_x1_r0_body.sizePreA125 PRE_first_tail_x1_r0_body.bodyPatchB125 (fun _ hm => bodyO471 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr471).trans bodyInactive0) (bodyBr472.trans bodyBr471.symm) bodyCnt471 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24248, 431, 0, 333⟩) bodyAcc472 PRE_first_tail_x1_r0_body.bodyRunSeg125 bodyAcc473 bodyHalt473 PRE_first_tail_x1_r0_body.bodyStepA126 bodyTop474 (fun _ hm => bodyO472 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr472).trans bodyInactive0) (bodyBr474.trans bodyBr472.symm) bodyCnt472 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift21 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S474.tab.length PRE_first_tail_x1_r0_body.s474.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P21.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P21 2529 PRE_first_tail_x1_r0_body.kappa21 PRE_first_tail_x1_r0_body.s476.ffi PRE_first_tail_x1_r0_body.s475.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_21
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_21
  have hcl : SSt (· < 2529) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s476.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S474.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_21] <;> decide) PRE_first_tail_x1_r0_body.cnodesK21 PRE_first_tail_x1_r0_body.cobjsK21
      PRE_first_tail_x1_r0_body.citemsK21 PRE_first_tail_x1_r0_body.cbd21 PRE_first_tail_x1_r0_body.csst21
  exact PRE_first_tail_x1_r0_body.cshift21 bodyNcl21 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_21] at this; exact this)


kernel_rfl bodyFramesEmpty21 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s475 a).isEmpty) = true
kernel_rfl bodyJsRoots21 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s474.next) PRE_first_tail_x1_r0_body.s476.trace PRE_first_tail_x1_r0_body.s476 = true
kernel_rfl bodyJsNative21 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s476.ffi) = true
kernel_rfl bodyLow21 : (PRE_first_tail_x1_r0_body.cws21 ++ PRE_first_tail_x1_r0_body.ws21).all (Nat.ble 9) = true
kernel_rfl bodyCntM21 : countersOkB PRE_first_tail_x1_r0_body.s474 PRE_first_tail_x1_r0_body.s475 = true
kernel_rfl bodyHi21 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s476.ffi).next setupP.E = true
kernel_rfl bodyNhi21 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s476.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge21 : bridgeOf PRE_first_tail_x1_r0_body.s475.ffi = bridgeOf PRE_first_tail_x1_r0_body.s474.ffi
kernel_rfl bodyNN21 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s474.ffi).nnext PRE_first_tail_x1_r0_body.P21.NL = true
kernel_rfl bodyXn21 : Nat.ble (⟨19459, 16553, 2724739, 2529⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s476.ffi).next = true
kernel_rfl bodyLo21 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s476.ffi).next = true
theorem bodyFacts21 : BodySiteFacts PRE_first_tail_x1_r0_body.s474 PRE_first_tail_x1_r0_body.s475 PRE_first_tail_x1_r0_body.s476 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S474 PRE_first_tail_x1_r0_body.S475 PRE_first_tail_x1_r0_body.S476
    PRE_first_tail_x1_r0_body.ws21 PRE_first_tail_x1_r0_body.cws21 PRE_first_tail_x1_r0_body.nr21 PRE_first_tail_x1_r0_body.pl21 PRE_first_tail_x1_r0_body.cl21 2725888 2529 PRE_first_tail_x1_r0_body.kd21 PRE_first_tail_x1_r0_body.kappa21 PRE_first_tail_x1_r0_body.P21
    ⟨19456, 16526, 2724733, 2511⟩ ⟨19459, 16553, 2724739, 2529⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap21
  clean := bodyClean21
  cfix := PRE_first_tail_x1_r0_body.cfix21
  zpl := PRE_first_tail_x1_r0_body.zpl21
  zplnd := PRE_first_tail_x1_r0_body.zplnd21
  zn1 := PRE_first_tail_x1_r0_body.zn121
  zfirst := PRE_first_tail_x1_r0_body.zfirst21
  zscn := PRE_first_tail_x1_r0_body.zscn21
  zsmn := PRE_first_tail_x1_r0_body.zsmn21
  zgrow := PRE_first_tail_x1_r0_body.zgrow21
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab21
  zfresh := PRE_first_tail_x1_r0_body.zfresh21
  zcnd := PRE_first_tail_x1_r0_body.zcnd21
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi21
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt21
  zgP := PRE_first_tail_x1_r0_body.zg21_2665
  zkP := PRE_first_tail_x1_r0_body.zk21_2665
  zmP := PRE_first_tail_x1_r0_body.zm21_2665
  zgC := PRE_first_tail_x1_r0_body.zg21_2673467
  zkC := PRE_first_tail_x1_r0_body.zk21_2673467
  zmC := PRE_first_tail_x1_r0_body.zm21_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw21_2673472
  zwV := PRE_first_tail_x1_r0_body.zw21_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap21
  zclbd := PRE_first_tail_x1_r0_body.zclbd21
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap21 PRE_first_tail_x1_r0_body.stFoot21 PRE_first_tail_x1_r0_body.iso21 PRE_first_tail_x1_r0_body.zwr21
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP21
  csupp := PRE_first_tail_x1_r0_body.csupp21
  cbound := PRE_first_tail_x1_r0_body.cbound21
  zimg := PRE_first_tail_x1_r0_body.zimg21
  zctl := PRE_first_tail_x1_r0_body.zctl21
  zstack := PRE_first_tail_x1_r0_body.zstack21
  zjobs := PRE_first_tail_x1_r0_body.zjobs21
  zstores := PRE_first_tail_x1_r0_body.zstores21
  zroots := PRE_first_tail_x1_r0_body.zroots21
  znC := PRE_first_tail_x1_r0_body.znC21
  ctab := PRE_first_tail_x1_r0_body.ctab21
  zbin := PRE_first_tail_x1_r0_body.zbin21
  cbridge := PRE_first_tail_x1_r0_body.cbridge21
  sbridge := bodyBridge21
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj21
  cshiftR := fun h hNL => bodyCshift21 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN21
  raised := PRE_first_tail_x1_r0_body.raised21
  cbigs := PRE_first_tail_x1_r0_body.cbigs21
  cjcl := PRE_first_tail_x1_r0_body.cjcl21
  xnLe := Nat.le_of_ble_eq_true bodyXn21
  loLe := Nat.le_of_ble_eq_true bodyLo21
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB21
  cntM := bodyCntM21
  hiLe := Nat.le_of_ble_eq_true bodyHi21
  nhiLe := Nat.le_of_ble_eq_true bodyNhi21
  jsHeap := bodyJs21
  jsRoots := bodyJsRoots21
  jsNative := bodyJsNative21
  framesEmpty := bodyFramesEmpty21
  trailOld := by decide
  lowVars := bodyLow21

def bodyQs21 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs21 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr21.map fun r => nth? PRE_first_tail_x1_r0_body.st21.S5.tab r
kernel_rfl bodyResChk21 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs21 bodyQs21) = true
kernel_rfl bodyLq21 : bodyQs21.length = PRE_first_tail_x1_r0_body.cws21.length
kernel_rfl bodyNrLo21 : PRE_first_tail_x1_r0_body.nr21.all (Nat.ble PRE_first_tail_x1_r0_body.S474.tab.length) = true
kernel_rfl bodySub21 : (Oracles.PRE_first_tail_x1_r0_body.map_site21.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost21 : postSubB bodyM PRE_first_tail_x1_r0_body.ws21 PRE_first_tail_x1_r0_body.cws21 bodyQs21 = true
kernel_rfl bodyDrop21 : Nat.ble (24248 + (PRE_first_tail_x1_r0_body.s475.next - PRE_first_tail_x1_r0_body.s476.next)) 25397 = true
kernel_rfl bodyDropH21 : Nat.ble (431 + ((mlxOf PRE_first_tail_x1_r0_body.s475.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s476.ffi).next)) 456 = true
kernel_rfl bodyDropN21 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s475.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s476.ffi).nnext)) 0 = true
kernel_rfl bodyDv21 : bodyΘ.1.take 351 = bodyΘ.1.take 333 ++ PRE_first_tail_x1_r0_body.cws21
kernel_rfl bodyDe21 : bodyΘ.2.take 351 = bodyΘ.2.take 333 ++ PRE_first_tail_x1_r0_body.nr21.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st21.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 333) (bodyΘ.2.take 333)))
kernel_rfl bodyDl21 : (bodyΘ.1.take 333).length = (bodyΘ.2.take 333).length
kernel_rfl bodyDold21 : (bodyΘ.1.take 333).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws21).isNone && !PRE_first_tail_x1_r0_body.ws21.contains v) = true
kernel_rfl bodyDfree21 : (bodyΘ.2.take 351).all (fun e => (PRE_first_tail_x1_r0_body.cws21 ++ PRE_first_tail_x1_r0_body.ws21).all fun w => e.noVar w) = true

theorem bodyStep21 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24248, 431, 0, 333⟩ bodyM PRE_first_tail_x1_r0_body.s474 PRE_first_tail_x1_r0_body.S474)
      (bodyCut NB T tk π i x0 bodyΘ ⟨25397, 456, 0, 351⟩ bodyM PRE_first_tail_x1_r0_body.s476 PRE_first_tail_x1_r0_body.S476) (11334 + 1) :=
  bodySite bodyFacts21.cfix bodyFacts21.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st21.S5.tab) (Es := bodyEs21) (qs := bodyQs21)
    (ok := PRE_first_tail_x1_r0_body.st21.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site21 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts21
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site21 r hr) hi (MapOk.sub hm (sub_of_all bodySub21)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk21 r hr) hi hm ho hq)
    bodyLq21 rfl bodyNrLo21 (postSub_sound bodyPost21)
    (Nat.le_of_ble_eq_true bodyDrop21) (by decide) (Nat.le_of_ble_eq_true bodyDropH21) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN21) (by decide)
    bodyDv21 bodyDe21 bodyDl21 bodyDold21 bodyDfree21 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site22 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n), (1945, Q.n), (1946, Q.n), (1948, Q.n), (1949, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1955, Q.n), (1956, Q.n), (1958, Q.n), (1959, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site22 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site22) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st22.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site22
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st22.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st22.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s496 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s497 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S496 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws22 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st22.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st22.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso22
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_22
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st22.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot22
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup22
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound22
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace22
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged22
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws22.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st22.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S496.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_22]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen22.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh22
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl22 : Conv.NClean (⟨19513, 16589, 2726981, 2627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s496.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl22 (PRE_first_tail_x1_r0_body.cncl21 bodyNcl21)

theorem bodyClean22 : Conv.JClean (⟨19513, 16589, 2726981, 2627⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s496 :=
  PRE_first_tail_x1_r0_body.gjcl22 (PRE_first_tail_x1_r0_body.cjcl21 bodyClean21)

kernel_rfl bodyJsLe22 : Nat.ble PRE_first_tail_x1_r0_body.s474.next PRE_first_tail_x1_r0_body.s496.next = true
kernel_rfl bodyJsList22 : (PRE_first_tail_x1_r0_body.gjh22 ++ PRE_first_tail_x1_r0_body.cl22).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s496.next) PRE_first_tail_x1_r0_body.s498) = true
theorem bodyJs22 : JsHeapAbove PRE_first_tail_x1_r0_body.s496.next PRE_first_tail_x1_r0_body.s498 :=
  JsHeapAbove.glueSite bodyJs21 (Nat.le_of_ble_eq_true bodyJsLe22) PRE_first_tail_x1_r0_body.gjk22 PRE_first_tail_x1_r0_body.gjbd22 PRE_first_tail_x1_r0_body.cheap22 PRE_first_tail_x1_r0_body.zclbd22 bodyJsList22

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO476 : PRE_first_tail_x1_r0_body.S476.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S476.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr476 : bridgeOf PRE_first_tail_x1_r0_body.s476.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc476 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s476 PRE_first_tail_x1_r0_body.S476) = fun _ _ => true
kernel_rfl bodyAcc477 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s477 PRE_first_tail_x1_r0_body.S477) = fun _ _ => true
kernel_rfl bodyBr478 : bridgeOf PRE_first_tail_x1_r0_body.s478.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt477 : isHalt PRE_first_tail_x1_r0_body.s477.ctl = false
kernel_rfl bodyTop478 : noRetBlock PRE_first_tail_x1_r0_body.s478 = true
kernel_rfl bodyCnt476 : countersOkB PRE_first_tail_x1_r0_body.s476 PRE_first_tail_x1_r0_body.s478 = true
kernel_rfl bodyO478 : PRE_first_tail_x1_r0_body.S478.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S478.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr479 : bridgeOf PRE_first_tail_x1_r0_body.s479.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt478 : countersOkB PRE_first_tail_x1_r0_body.s478 PRE_first_tail_x1_r0_body.s479 = true
kernel_rfl bodyO479 : PRE_first_tail_x1_r0_body.S479.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S479.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc479 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s479 PRE_first_tail_x1_r0_body.S479) = fun _ _ => true
kernel_rfl bodyAcc483 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s483 PRE_first_tail_x1_r0_body.S483) = fun _ _ => true
kernel_rfl bodyBr484 : bridgeOf PRE_first_tail_x1_r0_body.s484.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt483 : isHalt PRE_first_tail_x1_r0_body.s483.ctl = false
kernel_rfl bodyTop484 : noRetBlock PRE_first_tail_x1_r0_body.s484 = true
kernel_rfl bodyCnt479 : countersOkB PRE_first_tail_x1_r0_body.s479 PRE_first_tail_x1_r0_body.s484 = true
kernel_rfl bodyO484 : PRE_first_tail_x1_r0_body.S484.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S484.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr485 : bridgeOf PRE_first_tail_x1_r0_body.s485.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt484 : countersOkB PRE_first_tail_x1_r0_body.s484 PRE_first_tail_x1_r0_body.s485 = true
kernel_rfl bodyO485 : PRE_first_tail_x1_r0_body.S485.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S485.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc485 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s485 PRE_first_tail_x1_r0_body.S485) = fun _ _ => true
kernel_rfl bodyAcc486 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s486 PRE_first_tail_x1_r0_body.S486) = fun _ _ => true
kernel_rfl bodyBr487 : bridgeOf PRE_first_tail_x1_r0_body.s487.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt486 : isHalt PRE_first_tail_x1_r0_body.s486.ctl = false
kernel_rfl bodyTop487 : noRetBlock PRE_first_tail_x1_r0_body.s487 = true
kernel_rfl bodyCnt485 : countersOkB PRE_first_tail_x1_r0_body.s485 PRE_first_tail_x1_r0_body.s487 = true
kernel_rfl bodyO487 : PRE_first_tail_x1_r0_body.S487.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S487.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr488 : bridgeOf PRE_first_tail_x1_r0_body.s488.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt487 : countersOkB PRE_first_tail_x1_r0_body.s487 PRE_first_tail_x1_r0_body.s488 = true
kernel_rfl bodyO488 : PRE_first_tail_x1_r0_body.S488.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S488.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc488 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s488 PRE_first_tail_x1_r0_body.S488) = fun _ _ => true
kernel_rfl bodyAcc489 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s489 PRE_first_tail_x1_r0_body.S489) = fun _ _ => true
kernel_rfl bodyBr490 : bridgeOf PRE_first_tail_x1_r0_body.s490.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt489 : isHalt PRE_first_tail_x1_r0_body.s489.ctl = false
kernel_rfl bodyTop490 : noRetBlock PRE_first_tail_x1_r0_body.s490 = true
kernel_rfl bodyCnt488 : countersOkB PRE_first_tail_x1_r0_body.s488 PRE_first_tail_x1_r0_body.s490 = true
kernel_rfl bodyO490 : PRE_first_tail_x1_r0_body.S490.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S490.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr491 : bridgeOf PRE_first_tail_x1_r0_body.s491.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt490 : countersOkB PRE_first_tail_x1_r0_body.s490 PRE_first_tail_x1_r0_body.s491 = true
kernel_rfl bodyO491 : PRE_first_tail_x1_r0_body.S491.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S491.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc491 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s491 PRE_first_tail_x1_r0_body.S491) = fun _ _ => true
kernel_rfl bodyAcc492 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s492 PRE_first_tail_x1_r0_body.S492) = fun _ _ => true
kernel_rfl bodyBr493 : bridgeOf PRE_first_tail_x1_r0_body.s493.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt492 : isHalt PRE_first_tail_x1_r0_body.s492.ctl = false
kernel_rfl bodyTop493 : noRetBlock PRE_first_tail_x1_r0_body.s493 = true
kernel_rfl bodyCnt491 : countersOkB PRE_first_tail_x1_r0_body.s491 PRE_first_tail_x1_r0_body.s493 = true
kernel_rfl bodyO493 : PRE_first_tail_x1_r0_body.S493.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S493.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr494 : bridgeOf PRE_first_tail_x1_r0_body.s494.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt493 : countersOkB PRE_first_tail_x1_r0_body.s493 PRE_first_tail_x1_r0_body.s494 = true
kernel_rfl bodyO494 : PRE_first_tail_x1_r0_body.S494.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S494.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc494 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s494 PRE_first_tail_x1_r0_body.S494) = fun _ _ => true
kernel_rfl bodyAcc495 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s495 PRE_first_tail_x1_r0_body.S495) = fun _ _ => true
kernel_rfl bodyBr496 : bridgeOf PRE_first_tail_x1_r0_body.s496.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt495 : isHalt PRE_first_tail_x1_r0_body.s495.ctl = false
kernel_rfl bodyTop496 : noRetBlock PRE_first_tail_x1_r0_body.s496 = true
kernel_rfl bodyCnt494 : countersOkB PRE_first_tail_x1_r0_body.s494 PRE_first_tail_x1_r0_body.s496 = true

theorem bodyGlue22 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨25397, 456, 0, 351⟩ bodyM PRE_first_tail_x1_r0_body.s476 PRE_first_tail_x1_r0_body.S476)
      (bodyCut NB T tk π i x0 bodyΘ ⟨25397, 456, 0, 351⟩ bodyM PRE_first_tail_x1_r0_body.s496 PRE_first_tail_x1_r0_body.S496) 22362 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) bodyAcc476 PRE_first_tail_x1_r0_body.bodyRunSeg126 bodyAcc477 bodyHalt477 PRE_first_tail_x1_r0_body.bodyStepA127 bodyTop478 (fun _ hm => bodyO476 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr476).trans bodyInactive0) (bodyBr478.trans bodyBr476.symm) bodyCnt476 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) PRE_first_tail_x1_r0_body.sizeA127 PRE_first_tail_x1_r0_body.sizeArgsA127 PRE_first_tail_x1_r0_body.sizeSymA127 PRE_first_tail_x1_r0_body.sizeMlxA127 PRE_first_tail_x1_r0_body.sizePayA127 PRE_first_tail_x1_r0_body.sizeTaA127 PRE_first_tail_x1_r0_body.sizeDecA127 PRE_first_tail_x1_r0_body.sizePreA127 PRE_first_tail_x1_r0_body.bodyPatchB127 (fun _ hm => bodyO478 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr478).trans bodyInactive0) (bodyBr479.trans bodyBr478.symm) bodyCnt478 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) bodyAcc479 PRE_first_tail_x1_r0_body.bodyRunSeg127 bodyAcc483 bodyHalt483 PRE_first_tail_x1_r0_body.bodyStepA128 bodyTop484 (fun _ hm => bodyO479 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr479).trans bodyInactive0) (bodyBr484.trans bodyBr479.symm) bodyCnt479 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) PRE_first_tail_x1_r0_body.sizeA128 PRE_first_tail_x1_r0_body.sizeArgsA128 PRE_first_tail_x1_r0_body.sizeSymA128 PRE_first_tail_x1_r0_body.sizeMlxA128 PRE_first_tail_x1_r0_body.sizePayA128 PRE_first_tail_x1_r0_body.sizeTaA128 PRE_first_tail_x1_r0_body.sizeDecA128 PRE_first_tail_x1_r0_body.sizePreA128 PRE_first_tail_x1_r0_body.bodyPatchB128 (fun _ hm => bodyO484 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr484).trans bodyInactive0) (bodyBr485.trans bodyBr484.symm) bodyCnt484 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) bodyAcc485 PRE_first_tail_x1_r0_body.bodyRunSeg128 bodyAcc486 bodyHalt486 PRE_first_tail_x1_r0_body.bodyStepA129 bodyTop487 (fun _ hm => bodyO485 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr485).trans bodyInactive0) (bodyBr487.trans bodyBr485.symm) bodyCnt485 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) PRE_first_tail_x1_r0_body.sizeA129 PRE_first_tail_x1_r0_body.sizeArgsA129 PRE_first_tail_x1_r0_body.sizeSymA129 PRE_first_tail_x1_r0_body.sizeMlxA129 PRE_first_tail_x1_r0_body.sizePayA129 PRE_first_tail_x1_r0_body.sizeTaA129 PRE_first_tail_x1_r0_body.sizeDecA129 PRE_first_tail_x1_r0_body.sizePreA129 PRE_first_tail_x1_r0_body.bodyPatchB129 (fun _ hm => bodyO487 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr487).trans bodyInactive0) (bodyBr488.trans bodyBr487.symm) bodyCnt487 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) bodyAcc488 PRE_first_tail_x1_r0_body.bodyRunSeg129 bodyAcc489 bodyHalt489 PRE_first_tail_x1_r0_body.bodyStepA130 bodyTop490 (fun _ hm => bodyO488 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr488).trans bodyInactive0) (bodyBr490.trans bodyBr488.symm) bodyCnt488 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) PRE_first_tail_x1_r0_body.sizeA130 PRE_first_tail_x1_r0_body.sizeArgsA130 PRE_first_tail_x1_r0_body.sizeSymA130 PRE_first_tail_x1_r0_body.sizeMlxA130 PRE_first_tail_x1_r0_body.sizePayA130 PRE_first_tail_x1_r0_body.sizeTaA130 PRE_first_tail_x1_r0_body.sizeDecA130 PRE_first_tail_x1_r0_body.sizePreA130 PRE_first_tail_x1_r0_body.bodyPatchB130 (fun _ hm => bodyO490 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr490).trans bodyInactive0) (bodyBr491.trans bodyBr490.symm) bodyCnt490 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) bodyAcc491 PRE_first_tail_x1_r0_body.bodyRunSeg130 bodyAcc492 bodyHalt492 PRE_first_tail_x1_r0_body.bodyStepA131 bodyTop493 (fun _ hm => bodyO491 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr491).trans bodyInactive0) (bodyBr493.trans bodyBr491.symm) bodyCnt491 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) PRE_first_tail_x1_r0_body.sizeA131 PRE_first_tail_x1_r0_body.sizeArgsA131 PRE_first_tail_x1_r0_body.sizeSymA131 PRE_first_tail_x1_r0_body.sizeMlxA131 PRE_first_tail_x1_r0_body.sizePayA131 PRE_first_tail_x1_r0_body.sizeTaA131 PRE_first_tail_x1_r0_body.sizeDecA131 PRE_first_tail_x1_r0_body.sizePreA131 PRE_first_tail_x1_r0_body.bodyPatchB131 (fun _ hm => bodyO493 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr493).trans bodyInactive0) (bodyBr494.trans bodyBr493.symm) bodyCnt493 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25397, 456, 0, 351⟩) bodyAcc494 PRE_first_tail_x1_r0_body.bodyRunSeg131 bodyAcc495 bodyHalt495 PRE_first_tail_x1_r0_body.bodyStepA132 bodyTop496 (fun _ hm => bodyO494 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr494).trans bodyInactive0) (bodyBr496.trans bodyBr494.symm) bodyCnt494 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift22 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S496.tab.length PRE_first_tail_x1_r0_body.s496.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P22.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P22 2645 PRE_first_tail_x1_r0_body.kappa22 PRE_first_tail_x1_r0_body.s498.ffi PRE_first_tail_x1_r0_body.s497.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_22
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_22
  have hcl : SSt (· < 2645) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s498.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S496.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_22] <;> decide) PRE_first_tail_x1_r0_body.cnodesK22 PRE_first_tail_x1_r0_body.cobjsK22
      PRE_first_tail_x1_r0_body.citemsK22 PRE_first_tail_x1_r0_body.cbd22 PRE_first_tail_x1_r0_body.csst22
  exact PRE_first_tail_x1_r0_body.cshift22 bodyNcl22 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_22] at this; exact this)


kernel_rfl bodyFramesEmpty22 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s497 a).isEmpty) = true
kernel_rfl bodyJsRoots22 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s496.next) PRE_first_tail_x1_r0_body.s498.trace PRE_first_tail_x1_r0_body.s498 = true
kernel_rfl bodyJsNative22 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s498.ffi) = true
kernel_rfl bodyLow22 : (PRE_first_tail_x1_r0_body.cws22 ++ PRE_first_tail_x1_r0_body.ws22).all (Nat.ble 9) = true
kernel_rfl bodyCntM22 : countersOkB PRE_first_tail_x1_r0_body.s496 PRE_first_tail_x1_r0_body.s497 = true
kernel_rfl bodyHi22 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s498.ffi).next setupP.E = true
kernel_rfl bodyNhi22 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s498.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge22 : bridgeOf PRE_first_tail_x1_r0_body.s497.ffi = bridgeOf PRE_first_tail_x1_r0_body.s496.ffi
kernel_rfl bodyNN22 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s496.ffi).nnext PRE_first_tail_x1_r0_body.P22.NL = true
kernel_rfl bodyXn22 : Nat.ble (⟨19516, 16616, 2726987, 2645⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s498.ffi).next = true
kernel_rfl bodyLo22 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s498.ffi).next = true
theorem bodyFacts22 : BodySiteFacts PRE_first_tail_x1_r0_body.s496 PRE_first_tail_x1_r0_body.s497 PRE_first_tail_x1_r0_body.s498 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S496 PRE_first_tail_x1_r0_body.S497 PRE_first_tail_x1_r0_body.S498
    PRE_first_tail_x1_r0_body.ws22 PRE_first_tail_x1_r0_body.cws22 PRE_first_tail_x1_r0_body.nr22 PRE_first_tail_x1_r0_body.pl22 PRE_first_tail_x1_r0_body.cl22 2728136 2645 PRE_first_tail_x1_r0_body.kd22 PRE_first_tail_x1_r0_body.kappa22 PRE_first_tail_x1_r0_body.P22
    ⟨19513, 16589, 2726981, 2627⟩ ⟨19516, 16616, 2726987, 2645⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap22
  clean := bodyClean22
  cfix := PRE_first_tail_x1_r0_body.cfix22
  zpl := PRE_first_tail_x1_r0_body.zpl22
  zplnd := PRE_first_tail_x1_r0_body.zplnd22
  zn1 := PRE_first_tail_x1_r0_body.zn122
  zfirst := PRE_first_tail_x1_r0_body.zfirst22
  zscn := PRE_first_tail_x1_r0_body.zscn22
  zsmn := PRE_first_tail_x1_r0_body.zsmn22
  zgrow := PRE_first_tail_x1_r0_body.zgrow22
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab22
  zfresh := PRE_first_tail_x1_r0_body.zfresh22
  zcnd := PRE_first_tail_x1_r0_body.zcnd22
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi22
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt22
  zgP := PRE_first_tail_x1_r0_body.zg22_2665
  zkP := PRE_first_tail_x1_r0_body.zk22_2665
  zmP := PRE_first_tail_x1_r0_body.zm22_2665
  zgC := PRE_first_tail_x1_r0_body.zg22_2673467
  zkC := PRE_first_tail_x1_r0_body.zk22_2673467
  zmC := PRE_first_tail_x1_r0_body.zm22_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw22_2673472
  zwV := PRE_first_tail_x1_r0_body.zw22_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap22
  zclbd := PRE_first_tail_x1_r0_body.zclbd22
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap22 PRE_first_tail_x1_r0_body.stFoot22 PRE_first_tail_x1_r0_body.iso22 PRE_first_tail_x1_r0_body.zwr22
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP22
  csupp := PRE_first_tail_x1_r0_body.csupp22
  cbound := PRE_first_tail_x1_r0_body.cbound22
  zimg := PRE_first_tail_x1_r0_body.zimg22
  zctl := PRE_first_tail_x1_r0_body.zctl22
  zstack := PRE_first_tail_x1_r0_body.zstack22
  zjobs := PRE_first_tail_x1_r0_body.zjobs22
  zstores := PRE_first_tail_x1_r0_body.zstores22
  zroots := PRE_first_tail_x1_r0_body.zroots22
  znC := PRE_first_tail_x1_r0_body.znC22
  ctab := PRE_first_tail_x1_r0_body.ctab22
  zbin := PRE_first_tail_x1_r0_body.zbin22
  cbridge := PRE_first_tail_x1_r0_body.cbridge22
  sbridge := bodyBridge22
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj22
  cshiftR := fun h hNL => bodyCshift22 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN22
  raised := PRE_first_tail_x1_r0_body.raised22
  cbigs := PRE_first_tail_x1_r0_body.cbigs22
  cjcl := PRE_first_tail_x1_r0_body.cjcl22
  xnLe := Nat.le_of_ble_eq_true bodyXn22
  loLe := Nat.le_of_ble_eq_true bodyLo22
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB22
  cntM := bodyCntM22
  hiLe := Nat.le_of_ble_eq_true bodyHi22
  nhiLe := Nat.le_of_ble_eq_true bodyNhi22
  jsHeap := bodyJs22
  jsRoots := bodyJsRoots22
  jsNative := bodyJsNative22
  framesEmpty := bodyFramesEmpty22
  trailOld := by decide
  lowVars := bodyLow22

def bodyQs22 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs22 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr22.map fun r => nth? PRE_first_tail_x1_r0_body.st22.S5.tab r
kernel_rfl bodyResChk22 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs22 bodyQs22) = true
kernel_rfl bodyLq22 : bodyQs22.length = PRE_first_tail_x1_r0_body.cws22.length
kernel_rfl bodyNrLo22 : PRE_first_tail_x1_r0_body.nr22.all (Nat.ble PRE_first_tail_x1_r0_body.S496.tab.length) = true
kernel_rfl bodySub22 : (Oracles.PRE_first_tail_x1_r0_body.map_site22.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost22 : postSubB bodyM PRE_first_tail_x1_r0_body.ws22 PRE_first_tail_x1_r0_body.cws22 bodyQs22 = true
kernel_rfl bodyDrop22 : Nat.ble (25397 + (PRE_first_tail_x1_r0_body.s497.next - PRE_first_tail_x1_r0_body.s498.next)) 26546 = true
kernel_rfl bodyDropH22 : Nat.ble (456 + ((mlxOf PRE_first_tail_x1_r0_body.s497.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s498.ffi).next)) 481 = true
kernel_rfl bodyDropN22 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s497.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s498.ffi).nnext)) 0 = true
kernel_rfl bodyDv22 : bodyΘ.1.take 369 = bodyΘ.1.take 351 ++ PRE_first_tail_x1_r0_body.cws22
kernel_rfl bodyDe22 : bodyΘ.2.take 369 = bodyΘ.2.take 351 ++ PRE_first_tail_x1_r0_body.nr22.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st22.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 351) (bodyΘ.2.take 351)))
kernel_rfl bodyDl22 : (bodyΘ.1.take 351).length = (bodyΘ.2.take 351).length
kernel_rfl bodyDold22 : (bodyΘ.1.take 351).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws22).isNone && !PRE_first_tail_x1_r0_body.ws22.contains v) = true
kernel_rfl bodyDfree22 : (bodyΘ.2.take 369).all (fun e => (PRE_first_tail_x1_r0_body.cws22 ++ PRE_first_tail_x1_r0_body.ws22).all fun w => e.noVar w) = true

theorem bodyStep22 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨25397, 456, 0, 351⟩ bodyM PRE_first_tail_x1_r0_body.s496 PRE_first_tail_x1_r0_body.S496)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26546, 481, 0, 369⟩ bodyM PRE_first_tail_x1_r0_body.s498 PRE_first_tail_x1_r0_body.S498) (11334 + 1) :=
  bodySite bodyFacts22.cfix bodyFacts22.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st22.S5.tab) (Es := bodyEs22) (qs := bodyQs22)
    (ok := PRE_first_tail_x1_r0_body.st22.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site22 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts22
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site22 r hr) hi (MapOk.sub hm (sub_of_all bodySub22)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk22 r hr) hi hm ho hq)
    bodyLq22 rfl bodyNrLo22 (postSub_sound bodyPost22)
    (Nat.le_of_ble_eq_true bodyDrop22) (by decide) (Nat.le_of_ble_eq_true bodyDropH22) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN22) (by decide)
    bodyDv22 bodyDe22 bodyDl22 bodyDold22 bodyDfree22 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site23 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n), (1683, Q.n), (1684, Q.n), (1686, Q.n), (1688, Q.n), (1689, Q.n), (1690, Q.n), (1691, Q.n), (1723, Q.n), (1724, Q.n), (1726, Q.n), (1727, Q.n), (1728, Q.n), (1729, Q.n), (1730, Q.n), (1733, Q.n), (1734, Q.n), (1736, Q.n), (1737, Q.n), (1738, Q.n), (1739, Q.n), (1740, Q.n), (1772, Q.n), (1773, Q.n), (1775, Q.n), (1776, Q.n), (1777, Q.n), (1778, Q.n), (1779, Q.n), (1782, Q.n), (1783, Q.n), (1785, Q.n), (1786, Q.n), (1787, Q.n), (1788, Q.n), (1789, Q.n), (1821, Q.n), (1822, Q.n), (1824, Q.n), (1825, Q.n), (1826, Q.n), (1827, Q.n), (1828, Q.n), (1831, Q.n), (1832, Q.n), (1834, Q.n), (1835, Q.n), (1836, Q.n), (1837, Q.n), (1838, Q.n), (1856, Q.n), (1857, Q.n), (1859, Q.n), (1861, Q.n), (1862, Q.n), (1863, Q.n), (1864, Q.n), (1896, Q.n), (1897, Q.n), (1899, Q.n), (1900, Q.n), (1901, Q.n), (1902, Q.n), (1903, Q.n), (1906, Q.n), (1907, Q.n), (1909, Q.n), (1910, Q.n), (1911, Q.n), (1912, Q.n), (1913, Q.n), (1945, Q.n), (1946, Q.n), (1948, Q.n), (1949, Q.n), (1950, Q.n), (1951, Q.n), (1952, Q.n), (1955, Q.n), (1956, Q.n), (1958, Q.n), (1959, Q.n), (1960, Q.n), (1961, Q.n), (1962, Q.n), (1994, Q.n), (1995, Q.n), (1997, Q.n), (1998, Q.n), (1999, Q.n), (2000, Q.n), (2001, Q.n), (2004, Q.n), (2005, Q.n), (2007, Q.n), (2008, Q.n), (2009, Q.n), (2010, Q.n), (2011, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site23 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site23) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st23.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site23
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st23.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st23.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s517 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s518 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S517 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws23 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st23.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st23.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso23
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_23
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st23.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot23
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup23
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound23
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace23
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged23
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws23.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st23.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S517.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_23]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen23.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh23
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl23 : Conv.NClean (⟨19576, 16661, 2729492, 2749⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s517.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl23 (PRE_first_tail_x1_r0_body.cncl22 bodyNcl22)

theorem bodyClean23 : Conv.JClean (⟨19576, 16661, 2729492, 2749⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s517 :=
  PRE_first_tail_x1_r0_body.gjcl23 (PRE_first_tail_x1_r0_body.cjcl22 bodyClean22)

kernel_rfl bodyJsLe23 : Nat.ble PRE_first_tail_x1_r0_body.s496.next PRE_first_tail_x1_r0_body.s517.next = true
kernel_rfl bodyJsList23 : (PRE_first_tail_x1_r0_body.gjh23 ++ PRE_first_tail_x1_r0_body.cl23).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s517.next) PRE_first_tail_x1_r0_body.s519) = true
theorem bodyJs23 : JsHeapAbove PRE_first_tail_x1_r0_body.s517.next PRE_first_tail_x1_r0_body.s519 :=
  JsHeapAbove.glueSite bodyJs22 (Nat.le_of_ble_eq_true bodyJsLe23) PRE_first_tail_x1_r0_body.gjk23 PRE_first_tail_x1_r0_body.gjbd23 PRE_first_tail_x1_r0_body.cheap23 PRE_first_tail_x1_r0_body.zclbd23 bodyJsList23

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO498 : PRE_first_tail_x1_r0_body.S498.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S498.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr498 : bridgeOf PRE_first_tail_x1_r0_body.s498.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc498 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s498 PRE_first_tail_x1_r0_body.S498) = fun _ _ => true
kernel_rfl bodyAcc499 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s499 PRE_first_tail_x1_r0_body.S499) = fun _ _ => true
kernel_rfl bodyBr500 : bridgeOf PRE_first_tail_x1_r0_body.s500.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt499 : isHalt PRE_first_tail_x1_r0_body.s499.ctl = false
kernel_rfl bodyTop500 : noRetBlock PRE_first_tail_x1_r0_body.s500 = true
kernel_rfl bodyCnt498 : countersOkB PRE_first_tail_x1_r0_body.s498 PRE_first_tail_x1_r0_body.s500 = true
kernel_rfl bodyO500 : PRE_first_tail_x1_r0_body.S500.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S500.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr501 : bridgeOf PRE_first_tail_x1_r0_body.s501.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt500 : countersOkB PRE_first_tail_x1_r0_body.s500 PRE_first_tail_x1_r0_body.s501 = true
kernel_rfl bodyO501 : PRE_first_tail_x1_r0_body.S501.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S501.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc501 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s501 PRE_first_tail_x1_r0_body.S501) = fun _ _ => true
kernel_rfl bodyAcc505 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s505 PRE_first_tail_x1_r0_body.S505) = fun _ _ => true
kernel_rfl bodyBr506 : bridgeOf PRE_first_tail_x1_r0_body.s506.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt505 : isHalt PRE_first_tail_x1_r0_body.s505.ctl = false
kernel_rfl bodyTop506 : noRetBlock PRE_first_tail_x1_r0_body.s506 = true
kernel_rfl bodyCnt501 : countersOkB PRE_first_tail_x1_r0_body.s501 PRE_first_tail_x1_r0_body.s506 = true
kernel_rfl bodyO506 : PRE_first_tail_x1_r0_body.S506.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S506.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr507 : bridgeOf PRE_first_tail_x1_r0_body.s507.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt506 : countersOkB PRE_first_tail_x1_r0_body.s506 PRE_first_tail_x1_r0_body.s507 = true
kernel_rfl bodyO507 : PRE_first_tail_x1_r0_body.S507.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S507.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc507 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s507 PRE_first_tail_x1_r0_body.S507) = fun _ _ => true
kernel_rfl bodyAcc509 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s509 PRE_first_tail_x1_r0_body.S509) = fun _ _ => true
kernel_rfl bodyBr510 : bridgeOf PRE_first_tail_x1_r0_body.s510.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt509 : isHalt PRE_first_tail_x1_r0_body.s509.ctl = false
kernel_rfl bodyTop510 : noRetBlock PRE_first_tail_x1_r0_body.s510 = true
kernel_rfl bodyCnt507 : countersOkB PRE_first_tail_x1_r0_body.s507 PRE_first_tail_x1_r0_body.s510 = true
kernel_rfl bodyO510 : PRE_first_tail_x1_r0_body.S510.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S510.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr511 : bridgeOf PRE_first_tail_x1_r0_body.s511.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt510 : countersOkB PRE_first_tail_x1_r0_body.s510 PRE_first_tail_x1_r0_body.s511 = true
kernel_rfl bodyO511 : PRE_first_tail_x1_r0_body.S511.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S511.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc511 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s511 PRE_first_tail_x1_r0_body.S511) = fun _ _ => true
kernel_rfl bodyAcc512 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s512 PRE_first_tail_x1_r0_body.S512) = fun _ _ => true
kernel_rfl bodyBr513 : bridgeOf PRE_first_tail_x1_r0_body.s513.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt512 : isHalt PRE_first_tail_x1_r0_body.s512.ctl = false
kernel_rfl bodyTop513 : noRetBlock PRE_first_tail_x1_r0_body.s513 = true
kernel_rfl bodyCnt511 : countersOkB PRE_first_tail_x1_r0_body.s511 PRE_first_tail_x1_r0_body.s513 = true
kernel_rfl bodyO513 : PRE_first_tail_x1_r0_body.S513.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S513.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr514 : bridgeOf PRE_first_tail_x1_r0_body.s514.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt513 : countersOkB PRE_first_tail_x1_r0_body.s513 PRE_first_tail_x1_r0_body.s514 = true
kernel_rfl bodyO514 : PRE_first_tail_x1_r0_body.S514.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S514.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc514 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s514 PRE_first_tail_x1_r0_body.S514) = fun _ _ => true
kernel_rfl bodyAcc516 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s516 PRE_first_tail_x1_r0_body.S516) = fun _ _ => true
kernel_rfl bodyBr517 : bridgeOf PRE_first_tail_x1_r0_body.s517.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt516 : isHalt PRE_first_tail_x1_r0_body.s516.ctl = false
kernel_rfl bodyTop517 : noRetBlock PRE_first_tail_x1_r0_body.s517 = true
kernel_rfl bodyCnt514 : countersOkB PRE_first_tail_x1_r0_body.s514 PRE_first_tail_x1_r0_body.s517 = true

theorem bodyGlue23 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26546, 481, 0, 369⟩ bodyM PRE_first_tail_x1_r0_body.s498 PRE_first_tail_x1_r0_body.S498)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26546, 481, 0, 369⟩ bodyM PRE_first_tail_x1_r0_body.s517 PRE_first_tail_x1_r0_body.S517) 24808 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) bodyAcc498 PRE_first_tail_x1_r0_body.bodyRunSeg132 bodyAcc499 bodyHalt499 PRE_first_tail_x1_r0_body.bodyStepA133 bodyTop500 (fun _ hm => bodyO498 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr498).trans bodyInactive0) (bodyBr500.trans bodyBr498.symm) bodyCnt498 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) PRE_first_tail_x1_r0_body.sizeA133 PRE_first_tail_x1_r0_body.sizeArgsA133 PRE_first_tail_x1_r0_body.sizeSymA133 PRE_first_tail_x1_r0_body.sizeMlxA133 PRE_first_tail_x1_r0_body.sizePayA133 PRE_first_tail_x1_r0_body.sizeTaA133 PRE_first_tail_x1_r0_body.sizeDecA133 PRE_first_tail_x1_r0_body.sizePreA133 PRE_first_tail_x1_r0_body.bodyPatchB133 (fun _ hm => bodyO500 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr500).trans bodyInactive0) (bodyBr501.trans bodyBr500.symm) bodyCnt500 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) bodyAcc501 PRE_first_tail_x1_r0_body.bodyRunSeg133 bodyAcc505 bodyHalt505 PRE_first_tail_x1_r0_body.bodyStepA134 bodyTop506 (fun _ hm => bodyO501 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr501).trans bodyInactive0) (bodyBr506.trans bodyBr501.symm) bodyCnt501 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) PRE_first_tail_x1_r0_body.sizeA134 PRE_first_tail_x1_r0_body.sizeArgsA134 PRE_first_tail_x1_r0_body.sizeSymA134 PRE_first_tail_x1_r0_body.sizeMlxA134 PRE_first_tail_x1_r0_body.sizePayA134 PRE_first_tail_x1_r0_body.sizeTaA134 PRE_first_tail_x1_r0_body.sizeDecA134 PRE_first_tail_x1_r0_body.sizePreA134 PRE_first_tail_x1_r0_body.bodyPatchB134 (fun _ hm => bodyO506 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr506).trans bodyInactive0) (bodyBr507.trans bodyBr506.symm) bodyCnt506 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) bodyAcc507 PRE_first_tail_x1_r0_body.bodyRunSeg134 bodyAcc509 bodyHalt509 PRE_first_tail_x1_r0_body.bodyStepA135 bodyTop510 (fun _ hm => bodyO507 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr507).trans bodyInactive0) (bodyBr510.trans bodyBr507.symm) bodyCnt507 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) PRE_first_tail_x1_r0_body.sizeA135 PRE_first_tail_x1_r0_body.sizeArgsA135 PRE_first_tail_x1_r0_body.sizeSymA135 PRE_first_tail_x1_r0_body.sizeMlxA135 PRE_first_tail_x1_r0_body.sizePayA135 PRE_first_tail_x1_r0_body.sizeTaA135 PRE_first_tail_x1_r0_body.sizeDecA135 PRE_first_tail_x1_r0_body.sizePreA135 PRE_first_tail_x1_r0_body.bodyPatchB135 (fun _ hm => bodyO510 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr510).trans bodyInactive0) (bodyBr511.trans bodyBr510.symm) bodyCnt510 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) bodyAcc511 PRE_first_tail_x1_r0_body.bodyRunSeg135 bodyAcc512 bodyHalt512 PRE_first_tail_x1_r0_body.bodyStepA136 bodyTop513 (fun _ hm => bodyO511 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr511).trans bodyInactive0) (bodyBr513.trans bodyBr511.symm) bodyCnt511 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) PRE_first_tail_x1_r0_body.sizeA136 PRE_first_tail_x1_r0_body.sizeArgsA136 PRE_first_tail_x1_r0_body.sizeSymA136 PRE_first_tail_x1_r0_body.sizeMlxA136 PRE_first_tail_x1_r0_body.sizePayA136 PRE_first_tail_x1_r0_body.sizeTaA136 PRE_first_tail_x1_r0_body.sizeDecA136 PRE_first_tail_x1_r0_body.sizePreA136 PRE_first_tail_x1_r0_body.bodyPatchB136 (fun _ hm => bodyO513 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr513).trans bodyInactive0) (bodyBr514.trans bodyBr513.symm) bodyCnt513 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26546, 481, 0, 369⟩) bodyAcc514 PRE_first_tail_x1_r0_body.bodyRunSeg136 bodyAcc516 bodyHalt516 PRE_first_tail_x1_r0_body.bodyStepA137 bodyTop517 (fun _ hm => bodyO514 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr514).trans bodyInactive0) (bodyBr517.trans bodyBr514.symm) bodyCnt514 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift23 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S517.tab.length PRE_first_tail_x1_r0_body.s517.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P23.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P23 2758 PRE_first_tail_x1_r0_body.kappa23 PRE_first_tail_x1_r0_body.s519.ffi PRE_first_tail_x1_r0_body.s518.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_23
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_23
  have hcl : SSt (· < 2758) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s519.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S517.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_23] <;> decide) PRE_first_tail_x1_r0_body.cnodesK23 PRE_first_tail_x1_r0_body.cobjsK23
      PRE_first_tail_x1_r0_body.citemsK23 PRE_first_tail_x1_r0_body.cbd23 PRE_first_tail_x1_r0_body.csst23
  exact PRE_first_tail_x1_r0_body.cshift23 bodyNcl23 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_23] at this; exact this)


kernel_rfl bodyFramesEmpty23 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s518 a).isEmpty) = true
kernel_rfl bodyJsRoots23 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s517.next) PRE_first_tail_x1_r0_body.s519.trace PRE_first_tail_x1_r0_body.s519 = true
kernel_rfl bodyJsNative23 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s519.ffi) = true
kernel_rfl bodyLow23 : (PRE_first_tail_x1_r0_body.cws23 ++ PRE_first_tail_x1_r0_body.ws23).all (Nat.ble 9) = true
kernel_rfl bodyCntM23 : countersOkB PRE_first_tail_x1_r0_body.s517 PRE_first_tail_x1_r0_body.s518 = true
kernel_rfl bodyHi23 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s519.ffi).next setupP.E = true
kernel_rfl bodyNhi23 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s519.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge23 : bridgeOf PRE_first_tail_x1_r0_body.s518.ffi = bridgeOf PRE_first_tail_x1_r0_body.s517.ffi
kernel_rfl bodyNN23 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s517.ffi).nnext PRE_first_tail_x1_r0_body.P23.NL = true
kernel_rfl bodyXn23 : Nat.ble (⟨19580, 16667, 2729507, 2758⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s519.ffi).next = true
kernel_rfl bodyLo23 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s519.ffi).next = true
theorem bodyFacts23 : BodySiteFacts PRE_first_tail_x1_r0_body.s517 PRE_first_tail_x1_r0_body.s518 PRE_first_tail_x1_r0_body.s519 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S517 PRE_first_tail_x1_r0_body.S518 PRE_first_tail_x1_r0_body.S519
    PRE_first_tail_x1_r0_body.ws23 PRE_first_tail_x1_r0_body.cws23 PRE_first_tail_x1_r0_body.nr23 PRE_first_tail_x1_r0_body.pl23 PRE_first_tail_x1_r0_body.cl23 2729857 2758 PRE_first_tail_x1_r0_body.kd23 PRE_first_tail_x1_r0_body.kappa23 PRE_first_tail_x1_r0_body.P23
    ⟨19576, 16661, 2729492, 2749⟩ ⟨19580, 16667, 2729507, 2758⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap23
  clean := bodyClean23
  cfix := PRE_first_tail_x1_r0_body.cfix23
  zpl := PRE_first_tail_x1_r0_body.zpl23
  zplnd := PRE_first_tail_x1_r0_body.zplnd23
  zn1 := PRE_first_tail_x1_r0_body.zn123
  zfirst := PRE_first_tail_x1_r0_body.zfirst23
  zscn := PRE_first_tail_x1_r0_body.zscn23
  zsmn := PRE_first_tail_x1_r0_body.zsmn23
  zgrow := PRE_first_tail_x1_r0_body.zgrow23
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab23
  zfresh := PRE_first_tail_x1_r0_body.zfresh23
  zcnd := PRE_first_tail_x1_r0_body.zcnd23
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi23
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt23
  zgP := PRE_first_tail_x1_r0_body.zg23_2665
  zkP := PRE_first_tail_x1_r0_body.zk23_2665
  zmP := PRE_first_tail_x1_r0_body.zm23_2665
  zgC := PRE_first_tail_x1_r0_body.zg23_2673467
  zkC := PRE_first_tail_x1_r0_body.zk23_2673467
  zmC := PRE_first_tail_x1_r0_body.zm23_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw23_2673472
  zwV := PRE_first_tail_x1_r0_body.zw23_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap23
  zclbd := PRE_first_tail_x1_r0_body.zclbd23
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap23 PRE_first_tail_x1_r0_body.stFoot23 PRE_first_tail_x1_r0_body.iso23 PRE_first_tail_x1_r0_body.zwr23
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP23
  csupp := PRE_first_tail_x1_r0_body.csupp23
  cbound := PRE_first_tail_x1_r0_body.cbound23
  zimg := PRE_first_tail_x1_r0_body.zimg23
  zctl := PRE_first_tail_x1_r0_body.zctl23
  zstack := PRE_first_tail_x1_r0_body.zstack23
  zjobs := PRE_first_tail_x1_r0_body.zjobs23
  zstores := PRE_first_tail_x1_r0_body.zstores23
  zroots := PRE_first_tail_x1_r0_body.zroots23
  znC := PRE_first_tail_x1_r0_body.znC23
  ctab := PRE_first_tail_x1_r0_body.ctab23
  zbin := PRE_first_tail_x1_r0_body.zbin23
  cbridge := PRE_first_tail_x1_r0_body.cbridge23
  sbridge := bodyBridge23
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj23
  cshiftR := fun h hNL => bodyCshift23 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN23
  raised := PRE_first_tail_x1_r0_body.raised23
  cbigs := PRE_first_tail_x1_r0_body.cbigs23
  cjcl := PRE_first_tail_x1_r0_body.cjcl23
  xnLe := Nat.le_of_ble_eq_true bodyXn23
  loLe := Nat.le_of_ble_eq_true bodyLo23
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB23
  cntM := bodyCntM23
  hiLe := Nat.le_of_ble_eq_true bodyHi23
  nhiLe := Nat.le_of_ble_eq_true bodyNhi23
  jsHeap := bodyJs23
  jsRoots := bodyJsRoots23
  jsNative := bodyJsNative23
  framesEmpty := bodyFramesEmpty23
  trailOld := by decide
  lowVars := bodyLow23

def bodyQs23 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs23 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr23.map fun r => nth? PRE_first_tail_x1_r0_body.st23.S3.tab r
kernel_rfl bodyResChk23 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs23 bodyQs23) = true
kernel_rfl bodyLq23 : bodyQs23.length = PRE_first_tail_x1_r0_body.cws23.length
kernel_rfl bodyNrLo23 : PRE_first_tail_x1_r0_body.nr23.all (Nat.ble PRE_first_tail_x1_r0_body.S517.tab.length) = true
kernel_rfl bodySub23 : (Oracles.PRE_first_tail_x1_r0_body.map_site23.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost23 : postSubB bodyM PRE_first_tail_x1_r0_body.ws23 PRE_first_tail_x1_r0_body.cws23 bodyQs23 = true
kernel_rfl bodyDrop23 : Nat.ble (26546 + (PRE_first_tail_x1_r0_body.s518.next - PRE_first_tail_x1_r0_body.s519.next)) 26896 = true
kernel_rfl bodyDropH23 : Nat.ble (481 + ((mlxOf PRE_first_tail_x1_r0_body.s518.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s519.ffi).next)) 483 = true
kernel_rfl bodyDropN23 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s518.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s519.ffi).nnext)) 0 = true
kernel_rfl bodyDv23 : bodyΘ.1.take 378 = bodyΘ.1.take 369 ++ PRE_first_tail_x1_r0_body.cws23
kernel_rfl bodyDe23 : bodyΘ.2.take 378 = bodyΘ.2.take 369 ++ PRE_first_tail_x1_r0_body.nr23.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st23.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 369) (bodyΘ.2.take 369)))
kernel_rfl bodyDl23 : (bodyΘ.1.take 369).length = (bodyΘ.2.take 369).length
kernel_rfl bodyDold23 : (bodyΘ.1.take 369).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws23).isNone && !PRE_first_tail_x1_r0_body.ws23.contains v) = true
kernel_rfl bodyDfree23 : (bodyΘ.2.take 378).all (fun e => (PRE_first_tail_x1_r0_body.cws23 ++ PRE_first_tail_x1_r0_body.ws23).all fun w => e.noVar w) = true

theorem bodyStep23 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26546, 481, 0, 369⟩ bodyM PRE_first_tail_x1_r0_body.s517 PRE_first_tail_x1_r0_body.S517)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26896, 483, 0, 378⟩ bodyM PRE_first_tail_x1_r0_body.s519 PRE_first_tail_x1_r0_body.S519) (3452 + 1) :=
  bodySite bodyFacts23.cfix bodyFacts23.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x1_r0_body.st23.S3.tab) (Es := bodyEs23) (qs := bodyQs23)
    (ok := PRE_first_tail_x1_r0_body.st23.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site23 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts23
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site23 r hr) hi (MapOk.sub hm (sub_of_all bodySub23)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk23 r hr) hi hm ho hq)
    bodyLq23 rfl bodyNrLo23 (postSub_sound bodyPost23)
    (Nat.le_of_ble_eq_true bodyDrop23) (by decide) (Nat.le_of_ble_eq_true bodyDropH23) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN23) (by decide)
    bodyDv23 bodyDe23 bodyDl23 bodyDold23 bodyDfree23 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end
