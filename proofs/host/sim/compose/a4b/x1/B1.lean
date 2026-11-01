import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x1_r0_body.States
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B15
import host.sim.compose.a4b.x1.B0
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B23
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.x1.VWBodyChain
import host.sim.compose.a4b.x1.VWBodyMap
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B13
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B12
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B16

section -- VWBodyOracles_2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_g8 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g8 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g8) (List.take 35 (List.drop 267 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site8 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site8 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site8) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st8.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g9 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g9) (List.take 32 (List.drop 302 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site9 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st9.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g10 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g10) (List.take 32 (List.drop 334 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site10 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site10) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st10.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g11 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g11 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g11) (List.take 43 (List.drop 366 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site11 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site11 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site11) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st11.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site8 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site8 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site8) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st8.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site8
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st8.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st8.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s191 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s192 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S191 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws8 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st8.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st8.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso8
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_8
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st8.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot8
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup8
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound8
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace8
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged8
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws8.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st8.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S191.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_8]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen8.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh8
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl8 : Conv.NClean (⟨18691, 15752, 2694327, 1003⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s191.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl8 (PRE_first_tail_x1_r0_body.cncl7 bodyNcl7)

theorem bodyClean8 : Conv.JClean (⟨18691, 15752, 2694327, 1003⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s191 :=
  PRE_first_tail_x1_r0_body.gjcl8 (PRE_first_tail_x1_r0_body.cjcl7 bodyClean7)

kernel_rfl bodyJsLe8 : Nat.ble PRE_first_tail_x1_r0_body.s169.next PRE_first_tail_x1_r0_body.s191.next = true
kernel_rfl bodyJsList8 : (PRE_first_tail_x1_r0_body.gjh8 ++ PRE_first_tail_x1_r0_body.cl8).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s191.next) PRE_first_tail_x1_r0_body.s193) = true
theorem bodyJs8 : JsHeapAbove PRE_first_tail_x1_r0_body.s191.next PRE_first_tail_x1_r0_body.s193 :=
  JsHeapAbove.glueSite bodyJs7 (Nat.le_of_ble_eq_true bodyJsLe8) PRE_first_tail_x1_r0_body.gjk8 PRE_first_tail_x1_r0_body.gjbd8 PRE_first_tail_x1_r0_body.cheap8 PRE_first_tail_x1_r0_body.zclbd8 bodyJsList8

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO171 : PRE_first_tail_x1_r0_body.S171.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S171.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr171 : bridgeOf PRE_first_tail_x1_r0_body.s171.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc171 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s171 PRE_first_tail_x1_r0_body.S171) = fun _ _ => true
kernel_rfl bodyAcc172 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s172 PRE_first_tail_x1_r0_body.S172) = fun _ _ => true
kernel_rfl bodyBr173 : bridgeOf PRE_first_tail_x1_r0_body.s173.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt172 : isHalt PRE_first_tail_x1_r0_body.s172.ctl = false
kernel_rfl bodyTop173 : noRetBlock PRE_first_tail_x1_r0_body.s173 = true
kernel_rfl bodyCnt171 : countersOkB PRE_first_tail_x1_r0_body.s171 PRE_first_tail_x1_r0_body.s173 = true
kernel_rfl bodyO173 : PRE_first_tail_x1_r0_body.S173.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S173.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr174 : bridgeOf PRE_first_tail_x1_r0_body.s174.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt173 : countersOkB PRE_first_tail_x1_r0_body.s173 PRE_first_tail_x1_r0_body.s174 = true
kernel_rfl bodyO174 : PRE_first_tail_x1_r0_body.S174.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S174.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc174 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s174 PRE_first_tail_x1_r0_body.S174) = fun _ _ => true
kernel_rfl bodyAcc178 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s178 PRE_first_tail_x1_r0_body.S178) = fun _ _ => true
kernel_rfl bodyBr179 : bridgeOf PRE_first_tail_x1_r0_body.s179.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt178 : isHalt PRE_first_tail_x1_r0_body.s178.ctl = false
kernel_rfl bodyTop179 : noRetBlock PRE_first_tail_x1_r0_body.s179 = true
kernel_rfl bodyCnt174 : countersOkB PRE_first_tail_x1_r0_body.s174 PRE_first_tail_x1_r0_body.s179 = true
kernel_rfl bodyO179 : PRE_first_tail_x1_r0_body.S179.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S179.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr180 : bridgeOf PRE_first_tail_x1_r0_body.s180.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt179 : countersOkB PRE_first_tail_x1_r0_body.s179 PRE_first_tail_x1_r0_body.s180 = true
kernel_rfl bodyO180 : PRE_first_tail_x1_r0_body.S180.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S180.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc180 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s180 PRE_first_tail_x1_r0_body.S180) = fun _ _ => true
kernel_rfl bodyAcc181 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s181 PRE_first_tail_x1_r0_body.S181) = fun _ _ => true
kernel_rfl bodyBr182 : bridgeOf PRE_first_tail_x1_r0_body.s182.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt181 : isHalt PRE_first_tail_x1_r0_body.s181.ctl = false
kernel_rfl bodyTop182 : noRetBlock PRE_first_tail_x1_r0_body.s182 = true
kernel_rfl bodyCnt180 : countersOkB PRE_first_tail_x1_r0_body.s180 PRE_first_tail_x1_r0_body.s182 = true
kernel_rfl bodyO182 : PRE_first_tail_x1_r0_body.S182.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S182.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr183 : bridgeOf PRE_first_tail_x1_r0_body.s183.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt182 : countersOkB PRE_first_tail_x1_r0_body.s182 PRE_first_tail_x1_r0_body.s183 = true
kernel_rfl bodyO183 : PRE_first_tail_x1_r0_body.S183.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S183.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc183 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s183 PRE_first_tail_x1_r0_body.S183) = fun _ _ => true
kernel_rfl bodyAcc184 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s184 PRE_first_tail_x1_r0_body.S184) = fun _ _ => true
kernel_rfl bodyBr185 : bridgeOf PRE_first_tail_x1_r0_body.s185.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt184 : isHalt PRE_first_tail_x1_r0_body.s184.ctl = false
kernel_rfl bodyTop185 : noRetBlock PRE_first_tail_x1_r0_body.s185 = true
kernel_rfl bodyCnt183 : countersOkB PRE_first_tail_x1_r0_body.s183 PRE_first_tail_x1_r0_body.s185 = true
kernel_rfl bodyO185 : PRE_first_tail_x1_r0_body.S185.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S185.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr186 : bridgeOf PRE_first_tail_x1_r0_body.s186.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt185 : countersOkB PRE_first_tail_x1_r0_body.s185 PRE_first_tail_x1_r0_body.s186 = true
kernel_rfl bodyO186 : PRE_first_tail_x1_r0_body.S186.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S186.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc186 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s186 PRE_first_tail_x1_r0_body.S186) = fun _ _ => true
kernel_rfl bodyAcc187 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s187 PRE_first_tail_x1_r0_body.S187) = fun _ _ => true
kernel_rfl bodyBr188 : bridgeOf PRE_first_tail_x1_r0_body.s188.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt187 : isHalt PRE_first_tail_x1_r0_body.s187.ctl = false
kernel_rfl bodyTop188 : noRetBlock PRE_first_tail_x1_r0_body.s188 = true
kernel_rfl bodyCnt186 : countersOkB PRE_first_tail_x1_r0_body.s186 PRE_first_tail_x1_r0_body.s188 = true
kernel_rfl bodyO188 : PRE_first_tail_x1_r0_body.S188.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S188.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr189 : bridgeOf PRE_first_tail_x1_r0_body.s189.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt188 : countersOkB PRE_first_tail_x1_r0_body.s188 PRE_first_tail_x1_r0_body.s189 = true
kernel_rfl bodyO189 : PRE_first_tail_x1_r0_body.S189.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S189.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc189 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s189 PRE_first_tail_x1_r0_body.S189) = fun _ _ => true
kernel_rfl bodyAcc190 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s190 PRE_first_tail_x1_r0_body.S190) = fun _ _ => true
kernel_rfl bodyBr191 : bridgeOf PRE_first_tail_x1_r0_body.s191.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt190 : isHalt PRE_first_tail_x1_r0_body.s190.ctl = false
kernel_rfl bodyTop191 : noRetBlock PRE_first_tail_x1_r0_body.s191 = true
kernel_rfl bodyCnt189 : countersOkB PRE_first_tail_x1_r0_body.s189 PRE_first_tail_x1_r0_body.s191 = true

theorem bodyGlue8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 126⟩ bodyM PRE_first_tail_x1_r0_body.s171 PRE_first_tail_x1_r0_body.S171)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 126⟩ bodyM PRE_first_tail_x1_r0_body.s191 PRE_first_tail_x1_r0_body.S191) 23475 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc171 PRE_first_tail_x1_r0_body.bodyRunSeg45 bodyAcc172 bodyHalt172 PRE_first_tail_x1_r0_body.bodyStepA46 bodyTop173 (fun _ hm => bodyO171 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr171).trans bodyInactive0) (bodyBr173.trans bodyBr171.symm) bodyCnt171 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x1_r0_body.sizeA46 PRE_first_tail_x1_r0_body.sizeArgsA46 PRE_first_tail_x1_r0_body.sizeSymA46 PRE_first_tail_x1_r0_body.sizeMlxA46 PRE_first_tail_x1_r0_body.sizePayA46 PRE_first_tail_x1_r0_body.sizeTaA46 PRE_first_tail_x1_r0_body.sizeDecA46 PRE_first_tail_x1_r0_body.sizePreA46 PRE_first_tail_x1_r0_body.bodyPatchB46 (fun _ hm => bodyO173 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr173).trans bodyInactive0) (bodyBr174.trans bodyBr173.symm) bodyCnt173 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc174 PRE_first_tail_x1_r0_body.bodyRunSeg46 bodyAcc178 bodyHalt178 PRE_first_tail_x1_r0_body.bodyStepA47 bodyTop179 (fun _ hm => bodyO174 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr174).trans bodyInactive0) (bodyBr179.trans bodyBr174.symm) bodyCnt174 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x1_r0_body.sizeA47 PRE_first_tail_x1_r0_body.sizeArgsA47 PRE_first_tail_x1_r0_body.sizeSymA47 PRE_first_tail_x1_r0_body.sizeMlxA47 PRE_first_tail_x1_r0_body.sizePayA47 PRE_first_tail_x1_r0_body.sizeTaA47 PRE_first_tail_x1_r0_body.sizeDecA47 PRE_first_tail_x1_r0_body.sizePreA47 PRE_first_tail_x1_r0_body.bodyPatchB47 (fun _ hm => bodyO179 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr179).trans bodyInactive0) (bodyBr180.trans bodyBr179.symm) bodyCnt179 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc180 PRE_first_tail_x1_r0_body.bodyRunSeg47 bodyAcc181 bodyHalt181 PRE_first_tail_x1_r0_body.bodyStepA48 bodyTop182 (fun _ hm => bodyO180 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr180).trans bodyInactive0) (bodyBr182.trans bodyBr180.symm) bodyCnt180 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x1_r0_body.sizeA48 PRE_first_tail_x1_r0_body.sizeArgsA48 PRE_first_tail_x1_r0_body.sizeSymA48 PRE_first_tail_x1_r0_body.sizeMlxA48 PRE_first_tail_x1_r0_body.sizePayA48 PRE_first_tail_x1_r0_body.sizeTaA48 PRE_first_tail_x1_r0_body.sizeDecA48 PRE_first_tail_x1_r0_body.sizePreA48 PRE_first_tail_x1_r0_body.bodyPatchB48 (fun _ hm => bodyO182 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr182).trans bodyInactive0) (bodyBr183.trans bodyBr182.symm) bodyCnt182 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc183 PRE_first_tail_x1_r0_body.bodyRunSeg48 bodyAcc184 bodyHalt184 PRE_first_tail_x1_r0_body.bodyStepA49 bodyTop185 (fun _ hm => bodyO183 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr183).trans bodyInactive0) (bodyBr185.trans bodyBr183.symm) bodyCnt183 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x1_r0_body.sizeA49 PRE_first_tail_x1_r0_body.sizeArgsA49 PRE_first_tail_x1_r0_body.sizeSymA49 PRE_first_tail_x1_r0_body.sizeMlxA49 PRE_first_tail_x1_r0_body.sizePayA49 PRE_first_tail_x1_r0_body.sizeTaA49 PRE_first_tail_x1_r0_body.sizeDecA49 PRE_first_tail_x1_r0_body.sizePreA49 PRE_first_tail_x1_r0_body.bodyPatchB49 (fun _ hm => bodyO185 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr185).trans bodyInactive0) (bodyBr186.trans bodyBr185.symm) bodyCnt185 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc186 PRE_first_tail_x1_r0_body.bodyRunSeg49 bodyAcc187 bodyHalt187 PRE_first_tail_x1_r0_body.bodyStepA50 bodyTop188 (fun _ hm => bodyO186 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr186).trans bodyInactive0) (bodyBr188.trans bodyBr186.symm) bodyCnt186 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x1_r0_body.sizeA50 PRE_first_tail_x1_r0_body.sizeArgsA50 PRE_first_tail_x1_r0_body.sizeSymA50 PRE_first_tail_x1_r0_body.sizeMlxA50 PRE_first_tail_x1_r0_body.sizePayA50 PRE_first_tail_x1_r0_body.sizeTaA50 PRE_first_tail_x1_r0_body.sizeDecA50 PRE_first_tail_x1_r0_body.sizePreA50 PRE_first_tail_x1_r0_body.bodyPatchB50 (fun _ hm => bodyO188 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr188).trans bodyInactive0) (bodyBr189.trans bodyBr188.symm) bodyCnt188 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc189 PRE_first_tail_x1_r0_body.bodyRunSeg50 bodyAcc190 bodyHalt190 PRE_first_tail_x1_r0_body.bodyStepA51 bodyTop191 (fun _ hm => bodyO189 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr189).trans bodyInactive0) (bodyBr191.trans bodyBr189.symm) bodyCnt189 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift8 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S191.tab.length PRE_first_tail_x1_r0_body.s191.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P8.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P8 1021 PRE_first_tail_x1_r0_body.kappa8 PRE_first_tail_x1_r0_body.s193.ffi PRE_first_tail_x1_r0_body.s192.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_8
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_8
  have hcl : SSt (· < 1021) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s193.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S191.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_8] <;> decide) PRE_first_tail_x1_r0_body.cnodesK8 PRE_first_tail_x1_r0_body.cobjsK8
      PRE_first_tail_x1_r0_body.citemsK8 PRE_first_tail_x1_r0_body.cbd8 PRE_first_tail_x1_r0_body.csst8
  exact PRE_first_tail_x1_r0_body.cshift8 bodyNcl8 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_8] at this; exact this)


kernel_rfl bodyFramesEmpty8 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s192 a).isEmpty) = true
kernel_rfl bodyJsRoots8 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s191.next) PRE_first_tail_x1_r0_body.s193.trace PRE_first_tail_x1_r0_body.s193 = true
kernel_rfl bodyJsNative8 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s193.ffi) = true
kernel_rfl bodyLow8 : (PRE_first_tail_x1_r0_body.cws8 ++ PRE_first_tail_x1_r0_body.ws8).all (Nat.ble 9) = true
kernel_rfl bodyCntM8 : countersOkB PRE_first_tail_x1_r0_body.s191 PRE_first_tail_x1_r0_body.s192 = true
kernel_rfl bodyHi8 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s193.ffi).next setupP.E = true
kernel_rfl bodyNhi8 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s193.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge8 : bridgeOf PRE_first_tail_x1_r0_body.s192.ffi = bridgeOf PRE_first_tail_x1_r0_body.s191.ffi
kernel_rfl bodyNN8 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s191.ffi).nnext PRE_first_tail_x1_r0_body.P8.NL = true
kernel_rfl bodyXn8 : Nat.ble (⟨18694, 15779, 2694333, 1021⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s193.ffi).next = true
kernel_rfl bodyLo8 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s193.ffi).next = true
theorem bodyFacts8 : BodySiteFacts PRE_first_tail_x1_r0_body.s191 PRE_first_tail_x1_r0_body.s192 PRE_first_tail_x1_r0_body.s193 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S191 PRE_first_tail_x1_r0_body.S192 PRE_first_tail_x1_r0_body.S193
    PRE_first_tail_x1_r0_body.ws8 PRE_first_tail_x1_r0_body.cws8 PRE_first_tail_x1_r0_body.nr8 PRE_first_tail_x1_r0_body.pl8 PRE_first_tail_x1_r0_body.cl8 2695482 1021 PRE_first_tail_x1_r0_body.kd8 PRE_first_tail_x1_r0_body.kappa8 PRE_first_tail_x1_r0_body.P8
    ⟨18691, 15752, 2694327, 1003⟩ ⟨18694, 15779, 2694333, 1021⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap8
  clean := bodyClean8
  cfix := PRE_first_tail_x1_r0_body.cfix8
  zpl := PRE_first_tail_x1_r0_body.zpl8
  zplnd := PRE_first_tail_x1_r0_body.zplnd8
  zn1 := PRE_first_tail_x1_r0_body.zn18
  zfirst := PRE_first_tail_x1_r0_body.zfirst8
  zscn := PRE_first_tail_x1_r0_body.zscn8
  zsmn := PRE_first_tail_x1_r0_body.zsmn8
  zgrow := PRE_first_tail_x1_r0_body.zgrow8
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab8
  zfresh := PRE_first_tail_x1_r0_body.zfresh8
  zcnd := PRE_first_tail_x1_r0_body.zcnd8
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi8
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt8
  zgP := PRE_first_tail_x1_r0_body.zg8_2665
  zkP := PRE_first_tail_x1_r0_body.zk8_2665
  zmP := PRE_first_tail_x1_r0_body.zm8_2665
  zgC := PRE_first_tail_x1_r0_body.zg8_2673467
  zkC := PRE_first_tail_x1_r0_body.zk8_2673467
  zmC := PRE_first_tail_x1_r0_body.zm8_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw8_2673472
  zwV := PRE_first_tail_x1_r0_body.zw8_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap8
  zclbd := PRE_first_tail_x1_r0_body.zclbd8
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap8 PRE_first_tail_x1_r0_body.stFoot8 PRE_first_tail_x1_r0_body.iso8 PRE_first_tail_x1_r0_body.zwr8
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP8
  csupp := PRE_first_tail_x1_r0_body.csupp8
  cbound := PRE_first_tail_x1_r0_body.cbound8
  zimg := PRE_first_tail_x1_r0_body.zimg8
  zctl := PRE_first_tail_x1_r0_body.zctl8
  zstack := PRE_first_tail_x1_r0_body.zstack8
  zjobs := PRE_first_tail_x1_r0_body.zjobs8
  zstores := PRE_first_tail_x1_r0_body.zstores8
  zroots := PRE_first_tail_x1_r0_body.zroots8
  znC := PRE_first_tail_x1_r0_body.znC8
  ctab := PRE_first_tail_x1_r0_body.ctab8
  zbin := PRE_first_tail_x1_r0_body.zbin8
  cbridge := PRE_first_tail_x1_r0_body.cbridge8
  sbridge := bodyBridge8
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj8
  cshiftR := fun h hNL => bodyCshift8 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN8
  raised := PRE_first_tail_x1_r0_body.raised8
  cbigs := PRE_first_tail_x1_r0_body.cbigs8
  cjcl := PRE_first_tail_x1_r0_body.cjcl8
  xnLe := Nat.le_of_ble_eq_true bodyXn8
  loLe := Nat.le_of_ble_eq_true bodyLo8
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB8
  cntM := bodyCntM8
  hiLe := Nat.le_of_ble_eq_true bodyHi8
  nhiLe := Nat.le_of_ble_eq_true bodyNhi8
  jsHeap := bodyJs8
  jsRoots := bodyJsRoots8
  jsNative := bodyJsNative8
  framesEmpty := bodyFramesEmpty8
  trailOld := by decide
  lowVars := bodyLow8

def bodyQs8 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs8 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr8.map fun r => nth? PRE_first_tail_x1_r0_body.st8.S5.tab r
kernel_rfl bodyResChk8 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs8 bodyQs8) = true
kernel_rfl bodyLq8 : bodyQs8.length = PRE_first_tail_x1_r0_body.cws8.length
kernel_rfl bodyNrLo8 : PRE_first_tail_x1_r0_body.nr8.all (Nat.ble PRE_first_tail_x1_r0_body.S191.tab.length) = true
kernel_rfl bodySub8 : (Oracles.PRE_first_tail_x1_r0_body.map_site8.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost8 : postSubB bodyM PRE_first_tail_x1_r0_body.ws8 PRE_first_tail_x1_r0_body.cws8 bodyQs8 = true
kernel_rfl bodyDrop8 : Nat.ble (11708 + (PRE_first_tail_x1_r0_body.s192.next - PRE_first_tail_x1_r0_body.s193.next)) 12857 = true
kernel_rfl bodyDropH8 : Nat.ble (175 + ((mlxOf PRE_first_tail_x1_r0_body.s192.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s193.ffi).next)) 200 = true
kernel_rfl bodyDropN8 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s192.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s193.ffi).nnext)) 0 = true
kernel_rfl bodyDv8 : bodyΘ.1.take 144 = bodyΘ.1.take 126 ++ PRE_first_tail_x1_r0_body.cws8
kernel_rfl bodyDe8 : bodyΘ.2.take 144 = bodyΘ.2.take 126 ++ PRE_first_tail_x1_r0_body.nr8.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st8.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 126) (bodyΘ.2.take 126)))
kernel_rfl bodyDl8 : (bodyΘ.1.take 126).length = (bodyΘ.2.take 126).length
kernel_rfl bodyDold8 : (bodyΘ.1.take 126).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws8).isNone && !PRE_first_tail_x1_r0_body.ws8.contains v) = true
kernel_rfl bodyDfree8 : (bodyΘ.2.take 144).all (fun e => (PRE_first_tail_x1_r0_body.cws8 ++ PRE_first_tail_x1_r0_body.ws8).all fun w => e.noVar w) = true

theorem bodyStep8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 126⟩ bodyM PRE_first_tail_x1_r0_body.s191 PRE_first_tail_x1_r0_body.S191)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 144⟩ bodyM PRE_first_tail_x1_r0_body.s193 PRE_first_tail_x1_r0_body.S193) (11334 + 1) :=
  bodySite bodyFacts8.cfix bodyFacts8.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st8.S5.tab) (Es := bodyEs8) (qs := bodyQs8)
    (ok := PRE_first_tail_x1_r0_body.st8.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site8 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts8
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site8 r hr) hi (MapOk.sub hm (sub_of_all bodySub8)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk8 r hr) hi hm ho hq)
    bodyLq8 rfl bodyNrLo8 (postSub_sound bodyPost8)
    (Nat.le_of_ble_eq_true bodyDrop8) (by decide) (Nat.le_of_ble_eq_true bodyDropH8) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN8) (by decide)
    bodyDv8 bodyDe8 bodyDl8 bodyDold8 bodyDfree8 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site9 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st9.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site9
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st9.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st9.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s213 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s214 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S213 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws9 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st9.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st9.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso9
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_9
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st9.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot9
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup9
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound9
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace9
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged9
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws9.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st9.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S213.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_9]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen9.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh9
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl9 : Conv.NClean (⟨18748, 15815, 2696575, 1119⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s213.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl9 (PRE_first_tail_x1_r0_body.cncl8 bodyNcl8)

theorem bodyClean9 : Conv.JClean (⟨18748, 15815, 2696575, 1119⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s213 :=
  PRE_first_tail_x1_r0_body.gjcl9 (PRE_first_tail_x1_r0_body.cjcl8 bodyClean8)

kernel_rfl bodyJsLe9 : Nat.ble PRE_first_tail_x1_r0_body.s191.next PRE_first_tail_x1_r0_body.s213.next = true
kernel_rfl bodyJsList9 : (PRE_first_tail_x1_r0_body.gjh9 ++ PRE_first_tail_x1_r0_body.cl9).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s213.next) PRE_first_tail_x1_r0_body.s215) = true
theorem bodyJs9 : JsHeapAbove PRE_first_tail_x1_r0_body.s213.next PRE_first_tail_x1_r0_body.s215 :=
  JsHeapAbove.glueSite bodyJs8 (Nat.le_of_ble_eq_true bodyJsLe9) PRE_first_tail_x1_r0_body.gjk9 PRE_first_tail_x1_r0_body.gjbd9 PRE_first_tail_x1_r0_body.cheap9 PRE_first_tail_x1_r0_body.zclbd9 bodyJsList9

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO193 : PRE_first_tail_x1_r0_body.S193.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S193.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr193 : bridgeOf PRE_first_tail_x1_r0_body.s193.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc193 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s193 PRE_first_tail_x1_r0_body.S193) = fun _ _ => true
kernel_rfl bodyAcc194 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s194 PRE_first_tail_x1_r0_body.S194) = fun _ _ => true
kernel_rfl bodyBr195 : bridgeOf PRE_first_tail_x1_r0_body.s195.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt194 : isHalt PRE_first_tail_x1_r0_body.s194.ctl = false
kernel_rfl bodyTop195 : noRetBlock PRE_first_tail_x1_r0_body.s195 = true
kernel_rfl bodyCnt193 : countersOkB PRE_first_tail_x1_r0_body.s193 PRE_first_tail_x1_r0_body.s195 = true
kernel_rfl bodyO195 : PRE_first_tail_x1_r0_body.S195.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S195.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr196 : bridgeOf PRE_first_tail_x1_r0_body.s196.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt195 : countersOkB PRE_first_tail_x1_r0_body.s195 PRE_first_tail_x1_r0_body.s196 = true
kernel_rfl bodyO196 : PRE_first_tail_x1_r0_body.S196.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S196.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc196 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s196 PRE_first_tail_x1_r0_body.S196) = fun _ _ => true
kernel_rfl bodyAcc200 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s200 PRE_first_tail_x1_r0_body.S200) = fun _ _ => true
kernel_rfl bodyBr201 : bridgeOf PRE_first_tail_x1_r0_body.s201.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt200 : isHalt PRE_first_tail_x1_r0_body.s200.ctl = false
kernel_rfl bodyTop201 : noRetBlock PRE_first_tail_x1_r0_body.s201 = true
kernel_rfl bodyCnt196 : countersOkB PRE_first_tail_x1_r0_body.s196 PRE_first_tail_x1_r0_body.s201 = true
kernel_rfl bodyO201 : PRE_first_tail_x1_r0_body.S201.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S201.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr202 : bridgeOf PRE_first_tail_x1_r0_body.s202.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt201 : countersOkB PRE_first_tail_x1_r0_body.s201 PRE_first_tail_x1_r0_body.s202 = true
kernel_rfl bodyO202 : PRE_first_tail_x1_r0_body.S202.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S202.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc202 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s202 PRE_first_tail_x1_r0_body.S202) = fun _ _ => true
kernel_rfl bodyAcc203 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s203 PRE_first_tail_x1_r0_body.S203) = fun _ _ => true
kernel_rfl bodyBr204 : bridgeOf PRE_first_tail_x1_r0_body.s204.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt203 : isHalt PRE_first_tail_x1_r0_body.s203.ctl = false
kernel_rfl bodyTop204 : noRetBlock PRE_first_tail_x1_r0_body.s204 = true
kernel_rfl bodyCnt202 : countersOkB PRE_first_tail_x1_r0_body.s202 PRE_first_tail_x1_r0_body.s204 = true
kernel_rfl bodyO204 : PRE_first_tail_x1_r0_body.S204.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S204.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr205 : bridgeOf PRE_first_tail_x1_r0_body.s205.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt204 : countersOkB PRE_first_tail_x1_r0_body.s204 PRE_first_tail_x1_r0_body.s205 = true
kernel_rfl bodyO205 : PRE_first_tail_x1_r0_body.S205.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S205.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc205 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s205 PRE_first_tail_x1_r0_body.S205) = fun _ _ => true
kernel_rfl bodyAcc206 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s206 PRE_first_tail_x1_r0_body.S206) = fun _ _ => true
kernel_rfl bodyBr207 : bridgeOf PRE_first_tail_x1_r0_body.s207.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt206 : isHalt PRE_first_tail_x1_r0_body.s206.ctl = false
kernel_rfl bodyTop207 : noRetBlock PRE_first_tail_x1_r0_body.s207 = true
kernel_rfl bodyCnt205 : countersOkB PRE_first_tail_x1_r0_body.s205 PRE_first_tail_x1_r0_body.s207 = true
kernel_rfl bodyO207 : PRE_first_tail_x1_r0_body.S207.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S207.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr208 : bridgeOf PRE_first_tail_x1_r0_body.s208.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt207 : countersOkB PRE_first_tail_x1_r0_body.s207 PRE_first_tail_x1_r0_body.s208 = true
kernel_rfl bodyO208 : PRE_first_tail_x1_r0_body.S208.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S208.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc208 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s208 PRE_first_tail_x1_r0_body.S208) = fun _ _ => true
kernel_rfl bodyAcc209 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s209 PRE_first_tail_x1_r0_body.S209) = fun _ _ => true
kernel_rfl bodyBr210 : bridgeOf PRE_first_tail_x1_r0_body.s210.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt209 : isHalt PRE_first_tail_x1_r0_body.s209.ctl = false
kernel_rfl bodyTop210 : noRetBlock PRE_first_tail_x1_r0_body.s210 = true
kernel_rfl bodyCnt208 : countersOkB PRE_first_tail_x1_r0_body.s208 PRE_first_tail_x1_r0_body.s210 = true
kernel_rfl bodyO210 : PRE_first_tail_x1_r0_body.S210.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S210.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr211 : bridgeOf PRE_first_tail_x1_r0_body.s211.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt210 : countersOkB PRE_first_tail_x1_r0_body.s210 PRE_first_tail_x1_r0_body.s211 = true
kernel_rfl bodyO211 : PRE_first_tail_x1_r0_body.S211.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S211.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc211 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s211 PRE_first_tail_x1_r0_body.S211) = fun _ _ => true
kernel_rfl bodyAcc212 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s212 PRE_first_tail_x1_r0_body.S212) = fun _ _ => true
kernel_rfl bodyBr213 : bridgeOf PRE_first_tail_x1_r0_body.s213.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt212 : isHalt PRE_first_tail_x1_r0_body.s212.ctl = false
kernel_rfl bodyTop213 : noRetBlock PRE_first_tail_x1_r0_body.s213 = true
kernel_rfl bodyCnt211 : countersOkB PRE_first_tail_x1_r0_body.s211 PRE_first_tail_x1_r0_body.s213 = true

theorem bodyGlue9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 144⟩ bodyM PRE_first_tail_x1_r0_body.s193 PRE_first_tail_x1_r0_body.S193)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 144⟩ bodyM PRE_first_tail_x1_r0_body.s213 PRE_first_tail_x1_r0_body.S213) 22362 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc193 PRE_first_tail_x1_r0_body.bodyRunSeg51 bodyAcc194 bodyHalt194 PRE_first_tail_x1_r0_body.bodyStepA52 bodyTop195 (fun _ hm => bodyO193 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr193).trans bodyInactive0) (bodyBr195.trans bodyBr193.symm) bodyCnt193 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x1_r0_body.sizeA52 PRE_first_tail_x1_r0_body.sizeArgsA52 PRE_first_tail_x1_r0_body.sizeSymA52 PRE_first_tail_x1_r0_body.sizeMlxA52 PRE_first_tail_x1_r0_body.sizePayA52 PRE_first_tail_x1_r0_body.sizeTaA52 PRE_first_tail_x1_r0_body.sizeDecA52 PRE_first_tail_x1_r0_body.sizePreA52 PRE_first_tail_x1_r0_body.bodyPatchB52 (fun _ hm => bodyO195 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr195).trans bodyInactive0) (bodyBr196.trans bodyBr195.symm) bodyCnt195 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc196 PRE_first_tail_x1_r0_body.bodyRunSeg52 bodyAcc200 bodyHalt200 PRE_first_tail_x1_r0_body.bodyStepA53 bodyTop201 (fun _ hm => bodyO196 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr196).trans bodyInactive0) (bodyBr201.trans bodyBr196.symm) bodyCnt196 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x1_r0_body.sizeA53 PRE_first_tail_x1_r0_body.sizeArgsA53 PRE_first_tail_x1_r0_body.sizeSymA53 PRE_first_tail_x1_r0_body.sizeMlxA53 PRE_first_tail_x1_r0_body.sizePayA53 PRE_first_tail_x1_r0_body.sizeTaA53 PRE_first_tail_x1_r0_body.sizeDecA53 PRE_first_tail_x1_r0_body.sizePreA53 PRE_first_tail_x1_r0_body.bodyPatchB53 (fun _ hm => bodyO201 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr201).trans bodyInactive0) (bodyBr202.trans bodyBr201.symm) bodyCnt201 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc202 PRE_first_tail_x1_r0_body.bodyRunSeg53 bodyAcc203 bodyHalt203 PRE_first_tail_x1_r0_body.bodyStepA54 bodyTop204 (fun _ hm => bodyO202 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr202).trans bodyInactive0) (bodyBr204.trans bodyBr202.symm) bodyCnt202 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x1_r0_body.sizeA54 PRE_first_tail_x1_r0_body.sizeArgsA54 PRE_first_tail_x1_r0_body.sizeSymA54 PRE_first_tail_x1_r0_body.sizeMlxA54 PRE_first_tail_x1_r0_body.sizePayA54 PRE_first_tail_x1_r0_body.sizeTaA54 PRE_first_tail_x1_r0_body.sizeDecA54 PRE_first_tail_x1_r0_body.sizePreA54 PRE_first_tail_x1_r0_body.bodyPatchB54 (fun _ hm => bodyO204 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr204).trans bodyInactive0) (bodyBr205.trans bodyBr204.symm) bodyCnt204 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc205 PRE_first_tail_x1_r0_body.bodyRunSeg54 bodyAcc206 bodyHalt206 PRE_first_tail_x1_r0_body.bodyStepA55 bodyTop207 (fun _ hm => bodyO205 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr205).trans bodyInactive0) (bodyBr207.trans bodyBr205.symm) bodyCnt205 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x1_r0_body.sizeA55 PRE_first_tail_x1_r0_body.sizeArgsA55 PRE_first_tail_x1_r0_body.sizeSymA55 PRE_first_tail_x1_r0_body.sizeMlxA55 PRE_first_tail_x1_r0_body.sizePayA55 PRE_first_tail_x1_r0_body.sizeTaA55 PRE_first_tail_x1_r0_body.sizeDecA55 PRE_first_tail_x1_r0_body.sizePreA55 PRE_first_tail_x1_r0_body.bodyPatchB55 (fun _ hm => bodyO207 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr207).trans bodyInactive0) (bodyBr208.trans bodyBr207.symm) bodyCnt207 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc208 PRE_first_tail_x1_r0_body.bodyRunSeg55 bodyAcc209 bodyHalt209 PRE_first_tail_x1_r0_body.bodyStepA56 bodyTop210 (fun _ hm => bodyO208 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr208).trans bodyInactive0) (bodyBr210.trans bodyBr208.symm) bodyCnt208 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x1_r0_body.sizeA56 PRE_first_tail_x1_r0_body.sizeArgsA56 PRE_first_tail_x1_r0_body.sizeSymA56 PRE_first_tail_x1_r0_body.sizeMlxA56 PRE_first_tail_x1_r0_body.sizePayA56 PRE_first_tail_x1_r0_body.sizeTaA56 PRE_first_tail_x1_r0_body.sizeDecA56 PRE_first_tail_x1_r0_body.sizePreA56 PRE_first_tail_x1_r0_body.bodyPatchB56 (fun _ hm => bodyO210 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr210).trans bodyInactive0) (bodyBr211.trans bodyBr210.symm) bodyCnt210 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc211 PRE_first_tail_x1_r0_body.bodyRunSeg56 bodyAcc212 bodyHalt212 PRE_first_tail_x1_r0_body.bodyStepA57 bodyTop213 (fun _ hm => bodyO211 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr211).trans bodyInactive0) (bodyBr213.trans bodyBr211.symm) bodyCnt211 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift9 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S213.tab.length PRE_first_tail_x1_r0_body.s213.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P9.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P9 1137 PRE_first_tail_x1_r0_body.kappa9 PRE_first_tail_x1_r0_body.s215.ffi PRE_first_tail_x1_r0_body.s214.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_9
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_9
  have hcl : SSt (· < 1137) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s215.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S213.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_9] <;> decide) PRE_first_tail_x1_r0_body.cnodesK9 PRE_first_tail_x1_r0_body.cobjsK9
      PRE_first_tail_x1_r0_body.citemsK9 PRE_first_tail_x1_r0_body.cbd9 PRE_first_tail_x1_r0_body.csst9
  exact PRE_first_tail_x1_r0_body.cshift9 bodyNcl9 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_9] at this; exact this)


kernel_rfl bodyFramesEmpty9 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s214 a).isEmpty) = true
kernel_rfl bodyJsRoots9 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s213.next) PRE_first_tail_x1_r0_body.s215.trace PRE_first_tail_x1_r0_body.s215 = true
kernel_rfl bodyJsNative9 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s215.ffi) = true
kernel_rfl bodyLow9 : (PRE_first_tail_x1_r0_body.cws9 ++ PRE_first_tail_x1_r0_body.ws9).all (Nat.ble 9) = true
kernel_rfl bodyCntM9 : countersOkB PRE_first_tail_x1_r0_body.s213 PRE_first_tail_x1_r0_body.s214 = true
kernel_rfl bodyHi9 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s215.ffi).next setupP.E = true
kernel_rfl bodyNhi9 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s215.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge9 : bridgeOf PRE_first_tail_x1_r0_body.s214.ffi = bridgeOf PRE_first_tail_x1_r0_body.s213.ffi
kernel_rfl bodyNN9 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s213.ffi).nnext PRE_first_tail_x1_r0_body.P9.NL = true
kernel_rfl bodyXn9 : Nat.ble (⟨18751, 15842, 2696581, 1137⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s215.ffi).next = true
kernel_rfl bodyLo9 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s215.ffi).next = true
theorem bodyFacts9 : BodySiteFacts PRE_first_tail_x1_r0_body.s213 PRE_first_tail_x1_r0_body.s214 PRE_first_tail_x1_r0_body.s215 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S213 PRE_first_tail_x1_r0_body.S214 PRE_first_tail_x1_r0_body.S215
    PRE_first_tail_x1_r0_body.ws9 PRE_first_tail_x1_r0_body.cws9 PRE_first_tail_x1_r0_body.nr9 PRE_first_tail_x1_r0_body.pl9 PRE_first_tail_x1_r0_body.cl9 2697730 1137 PRE_first_tail_x1_r0_body.kd9 PRE_first_tail_x1_r0_body.kappa9 PRE_first_tail_x1_r0_body.P9
    ⟨18748, 15815, 2696575, 1119⟩ ⟨18751, 15842, 2696581, 1137⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap9
  clean := bodyClean9
  cfix := PRE_first_tail_x1_r0_body.cfix9
  zpl := PRE_first_tail_x1_r0_body.zpl9
  zplnd := PRE_first_tail_x1_r0_body.zplnd9
  zn1 := PRE_first_tail_x1_r0_body.zn19
  zfirst := PRE_first_tail_x1_r0_body.zfirst9
  zscn := PRE_first_tail_x1_r0_body.zscn9
  zsmn := PRE_first_tail_x1_r0_body.zsmn9
  zgrow := PRE_first_tail_x1_r0_body.zgrow9
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab9
  zfresh := PRE_first_tail_x1_r0_body.zfresh9
  zcnd := PRE_first_tail_x1_r0_body.zcnd9
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi9
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt9
  zgP := PRE_first_tail_x1_r0_body.zg9_2665
  zkP := PRE_first_tail_x1_r0_body.zk9_2665
  zmP := PRE_first_tail_x1_r0_body.zm9_2665
  zgC := PRE_first_tail_x1_r0_body.zg9_2673467
  zkC := PRE_first_tail_x1_r0_body.zk9_2673467
  zmC := PRE_first_tail_x1_r0_body.zm9_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw9_2673472
  zwV := PRE_first_tail_x1_r0_body.zw9_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap9
  zclbd := PRE_first_tail_x1_r0_body.zclbd9
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap9 PRE_first_tail_x1_r0_body.stFoot9 PRE_first_tail_x1_r0_body.iso9 PRE_first_tail_x1_r0_body.zwr9
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP9
  csupp := PRE_first_tail_x1_r0_body.csupp9
  cbound := PRE_first_tail_x1_r0_body.cbound9
  zimg := PRE_first_tail_x1_r0_body.zimg9
  zctl := PRE_first_tail_x1_r0_body.zctl9
  zstack := PRE_first_tail_x1_r0_body.zstack9
  zjobs := PRE_first_tail_x1_r0_body.zjobs9
  zstores := PRE_first_tail_x1_r0_body.zstores9
  zroots := PRE_first_tail_x1_r0_body.zroots9
  znC := PRE_first_tail_x1_r0_body.znC9
  ctab := PRE_first_tail_x1_r0_body.ctab9
  zbin := PRE_first_tail_x1_r0_body.zbin9
  cbridge := PRE_first_tail_x1_r0_body.cbridge9
  sbridge := bodyBridge9
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj9
  cshiftR := fun h hNL => bodyCshift9 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN9
  raised := PRE_first_tail_x1_r0_body.raised9
  cbigs := PRE_first_tail_x1_r0_body.cbigs9
  cjcl := PRE_first_tail_x1_r0_body.cjcl9
  xnLe := Nat.le_of_ble_eq_true bodyXn9
  loLe := Nat.le_of_ble_eq_true bodyLo9
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB9
  cntM := bodyCntM9
  hiLe := Nat.le_of_ble_eq_true bodyHi9
  nhiLe := Nat.le_of_ble_eq_true bodyNhi9
  jsHeap := bodyJs9
  jsRoots := bodyJsRoots9
  jsNative := bodyJsNative9
  framesEmpty := bodyFramesEmpty9
  trailOld := by decide
  lowVars := bodyLow9

def bodyQs9 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs9 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr9.map fun r => nth? PRE_first_tail_x1_r0_body.st9.S5.tab r
kernel_rfl bodyResChk9 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs9 bodyQs9) = true
kernel_rfl bodyLq9 : bodyQs9.length = PRE_first_tail_x1_r0_body.cws9.length
kernel_rfl bodyNrLo9 : PRE_first_tail_x1_r0_body.nr9.all (Nat.ble PRE_first_tail_x1_r0_body.S213.tab.length) = true
kernel_rfl bodySub9 : (Oracles.PRE_first_tail_x1_r0_body.map_site9.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost9 : postSubB bodyM PRE_first_tail_x1_r0_body.ws9 PRE_first_tail_x1_r0_body.cws9 bodyQs9 = true
kernel_rfl bodyDrop9 : Nat.ble (12857 + (PRE_first_tail_x1_r0_body.s214.next - PRE_first_tail_x1_r0_body.s215.next)) 14006 = true
kernel_rfl bodyDropH9 : Nat.ble (200 + ((mlxOf PRE_first_tail_x1_r0_body.s214.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s215.ffi).next)) 225 = true
kernel_rfl bodyDropN9 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s214.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s215.ffi).nnext)) 0 = true
kernel_rfl bodyDv9 : bodyΘ.1.take 162 = bodyΘ.1.take 144 ++ PRE_first_tail_x1_r0_body.cws9
kernel_rfl bodyDe9 : bodyΘ.2.take 162 = bodyΘ.2.take 144 ++ PRE_first_tail_x1_r0_body.nr9.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st9.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 144) (bodyΘ.2.take 144)))
kernel_rfl bodyDl9 : (bodyΘ.1.take 144).length = (bodyΘ.2.take 144).length
kernel_rfl bodyDold9 : (bodyΘ.1.take 144).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws9).isNone && !PRE_first_tail_x1_r0_body.ws9.contains v) = true
kernel_rfl bodyDfree9 : (bodyΘ.2.take 162).all (fun e => (PRE_first_tail_x1_r0_body.cws9 ++ PRE_first_tail_x1_r0_body.ws9).all fun w => e.noVar w) = true

theorem bodyStep9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 144⟩ bodyM PRE_first_tail_x1_r0_body.s213 PRE_first_tail_x1_r0_body.S213)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 162⟩ bodyM PRE_first_tail_x1_r0_body.s215 PRE_first_tail_x1_r0_body.S215) (11334 + 1) :=
  bodySite bodyFacts9.cfix bodyFacts9.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st9.S5.tab) (Es := bodyEs9) (qs := bodyQs9)
    (ok := PRE_first_tail_x1_r0_body.st9.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site9 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts9
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site9 r hr) hi (MapOk.sub hm (sub_of_all bodySub9)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk9 r hr) hi hm ho hq)
    bodyLq9 rfl bodyNrLo9 (postSub_sound bodyPost9)
    (Nat.le_of_ble_eq_true bodyDrop9) (by decide) (Nat.le_of_ble_eq_true bodyDropH9) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN9) (by decide)
    bodyDv9 bodyDe9 bodyDl9 bodyDold9 bodyDfree9 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site10 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site10) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st10.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site10
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st10.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st10.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s235 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s236 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S235 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws10 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st10.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st10.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso10
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_10
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st10.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot10
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup10
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound10
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace10
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged10
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws10.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st10.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S235.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_10]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen10.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh10
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl10 : Conv.NClean (⟨18805, 15878, 2698823, 1235⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s235.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl10 (PRE_first_tail_x1_r0_body.cncl9 bodyNcl9)

theorem bodyClean10 : Conv.JClean (⟨18805, 15878, 2698823, 1235⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s235 :=
  PRE_first_tail_x1_r0_body.gjcl10 (PRE_first_tail_x1_r0_body.cjcl9 bodyClean9)

kernel_rfl bodyJsLe10 : Nat.ble PRE_first_tail_x1_r0_body.s213.next PRE_first_tail_x1_r0_body.s235.next = true
kernel_rfl bodyJsList10 : (PRE_first_tail_x1_r0_body.gjh10 ++ PRE_first_tail_x1_r0_body.cl10).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s235.next) PRE_first_tail_x1_r0_body.s237) = true
theorem bodyJs10 : JsHeapAbove PRE_first_tail_x1_r0_body.s235.next PRE_first_tail_x1_r0_body.s237 :=
  JsHeapAbove.glueSite bodyJs9 (Nat.le_of_ble_eq_true bodyJsLe10) PRE_first_tail_x1_r0_body.gjk10 PRE_first_tail_x1_r0_body.gjbd10 PRE_first_tail_x1_r0_body.cheap10 PRE_first_tail_x1_r0_body.zclbd10 bodyJsList10

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO215 : PRE_first_tail_x1_r0_body.S215.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S215.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr215 : bridgeOf PRE_first_tail_x1_r0_body.s215.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc215 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s215 PRE_first_tail_x1_r0_body.S215) = fun _ _ => true
kernel_rfl bodyAcc216 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s216 PRE_first_tail_x1_r0_body.S216) = fun _ _ => true
kernel_rfl bodyBr217 : bridgeOf PRE_first_tail_x1_r0_body.s217.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt216 : isHalt PRE_first_tail_x1_r0_body.s216.ctl = false
kernel_rfl bodyTop217 : noRetBlock PRE_first_tail_x1_r0_body.s217 = true
kernel_rfl bodyCnt215 : countersOkB PRE_first_tail_x1_r0_body.s215 PRE_first_tail_x1_r0_body.s217 = true
kernel_rfl bodyO217 : PRE_first_tail_x1_r0_body.S217.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S217.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr218 : bridgeOf PRE_first_tail_x1_r0_body.s218.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt217 : countersOkB PRE_first_tail_x1_r0_body.s217 PRE_first_tail_x1_r0_body.s218 = true
kernel_rfl bodyO218 : PRE_first_tail_x1_r0_body.S218.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S218.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc218 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s218 PRE_first_tail_x1_r0_body.S218) = fun _ _ => true
kernel_rfl bodyAcc222 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s222 PRE_first_tail_x1_r0_body.S222) = fun _ _ => true
kernel_rfl bodyBr223 : bridgeOf PRE_first_tail_x1_r0_body.s223.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt222 : isHalt PRE_first_tail_x1_r0_body.s222.ctl = false
kernel_rfl bodyTop223 : noRetBlock PRE_first_tail_x1_r0_body.s223 = true
kernel_rfl bodyCnt218 : countersOkB PRE_first_tail_x1_r0_body.s218 PRE_first_tail_x1_r0_body.s223 = true
kernel_rfl bodyO223 : PRE_first_tail_x1_r0_body.S223.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S223.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr224 : bridgeOf PRE_first_tail_x1_r0_body.s224.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt223 : countersOkB PRE_first_tail_x1_r0_body.s223 PRE_first_tail_x1_r0_body.s224 = true
kernel_rfl bodyO224 : PRE_first_tail_x1_r0_body.S224.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S224.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc224 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s224 PRE_first_tail_x1_r0_body.S224) = fun _ _ => true
kernel_rfl bodyAcc225 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s225 PRE_first_tail_x1_r0_body.S225) = fun _ _ => true
kernel_rfl bodyBr226 : bridgeOf PRE_first_tail_x1_r0_body.s226.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt225 : isHalt PRE_first_tail_x1_r0_body.s225.ctl = false
kernel_rfl bodyTop226 : noRetBlock PRE_first_tail_x1_r0_body.s226 = true
kernel_rfl bodyCnt224 : countersOkB PRE_first_tail_x1_r0_body.s224 PRE_first_tail_x1_r0_body.s226 = true
kernel_rfl bodyO226 : PRE_first_tail_x1_r0_body.S226.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S226.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr227 : bridgeOf PRE_first_tail_x1_r0_body.s227.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt226 : countersOkB PRE_first_tail_x1_r0_body.s226 PRE_first_tail_x1_r0_body.s227 = true
kernel_rfl bodyO227 : PRE_first_tail_x1_r0_body.S227.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S227.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc227 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s227 PRE_first_tail_x1_r0_body.S227) = fun _ _ => true
kernel_rfl bodyAcc228 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s228 PRE_first_tail_x1_r0_body.S228) = fun _ _ => true
kernel_rfl bodyBr229 : bridgeOf PRE_first_tail_x1_r0_body.s229.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt228 : isHalt PRE_first_tail_x1_r0_body.s228.ctl = false
kernel_rfl bodyTop229 : noRetBlock PRE_first_tail_x1_r0_body.s229 = true
kernel_rfl bodyCnt227 : countersOkB PRE_first_tail_x1_r0_body.s227 PRE_first_tail_x1_r0_body.s229 = true
kernel_rfl bodyO229 : PRE_first_tail_x1_r0_body.S229.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S229.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr230 : bridgeOf PRE_first_tail_x1_r0_body.s230.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt229 : countersOkB PRE_first_tail_x1_r0_body.s229 PRE_first_tail_x1_r0_body.s230 = true
kernel_rfl bodyO230 : PRE_first_tail_x1_r0_body.S230.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S230.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc230 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s230 PRE_first_tail_x1_r0_body.S230) = fun _ _ => true
kernel_rfl bodyAcc231 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s231 PRE_first_tail_x1_r0_body.S231) = fun _ _ => true
kernel_rfl bodyBr232 : bridgeOf PRE_first_tail_x1_r0_body.s232.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt231 : isHalt PRE_first_tail_x1_r0_body.s231.ctl = false
kernel_rfl bodyTop232 : noRetBlock PRE_first_tail_x1_r0_body.s232 = true
kernel_rfl bodyCnt230 : countersOkB PRE_first_tail_x1_r0_body.s230 PRE_first_tail_x1_r0_body.s232 = true
kernel_rfl bodyO232 : PRE_first_tail_x1_r0_body.S232.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S232.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr233 : bridgeOf PRE_first_tail_x1_r0_body.s233.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt232 : countersOkB PRE_first_tail_x1_r0_body.s232 PRE_first_tail_x1_r0_body.s233 = true
kernel_rfl bodyO233 : PRE_first_tail_x1_r0_body.S233.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S233.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc233 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s233 PRE_first_tail_x1_r0_body.S233) = fun _ _ => true
kernel_rfl bodyAcc234 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s234 PRE_first_tail_x1_r0_body.S234) = fun _ _ => true
kernel_rfl bodyBr235 : bridgeOf PRE_first_tail_x1_r0_body.s235.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt234 : isHalt PRE_first_tail_x1_r0_body.s234.ctl = false
kernel_rfl bodyTop235 : noRetBlock PRE_first_tail_x1_r0_body.s235 = true
kernel_rfl bodyCnt233 : countersOkB PRE_first_tail_x1_r0_body.s233 PRE_first_tail_x1_r0_body.s235 = true

theorem bodyGlue10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 162⟩ bodyM PRE_first_tail_x1_r0_body.s215 PRE_first_tail_x1_r0_body.S215)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 162⟩ bodyM PRE_first_tail_x1_r0_body.s235 PRE_first_tail_x1_r0_body.S235) 22362 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc215 PRE_first_tail_x1_r0_body.bodyRunSeg57 bodyAcc216 bodyHalt216 PRE_first_tail_x1_r0_body.bodyStepA58 bodyTop217 (fun _ hm => bodyO215 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr215).trans bodyInactive0) (bodyBr217.trans bodyBr215.symm) bodyCnt215 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x1_r0_body.sizeA58 PRE_first_tail_x1_r0_body.sizeArgsA58 PRE_first_tail_x1_r0_body.sizeSymA58 PRE_first_tail_x1_r0_body.sizeMlxA58 PRE_first_tail_x1_r0_body.sizePayA58 PRE_first_tail_x1_r0_body.sizeTaA58 PRE_first_tail_x1_r0_body.sizeDecA58 PRE_first_tail_x1_r0_body.sizePreA58 PRE_first_tail_x1_r0_body.bodyPatchB58 (fun _ hm => bodyO217 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr217).trans bodyInactive0) (bodyBr218.trans bodyBr217.symm) bodyCnt217 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc218 PRE_first_tail_x1_r0_body.bodyRunSeg58 bodyAcc222 bodyHalt222 PRE_first_tail_x1_r0_body.bodyStepA59 bodyTop223 (fun _ hm => bodyO218 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr218).trans bodyInactive0) (bodyBr223.trans bodyBr218.symm) bodyCnt218 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x1_r0_body.sizeA59 PRE_first_tail_x1_r0_body.sizeArgsA59 PRE_first_tail_x1_r0_body.sizeSymA59 PRE_first_tail_x1_r0_body.sizeMlxA59 PRE_first_tail_x1_r0_body.sizePayA59 PRE_first_tail_x1_r0_body.sizeTaA59 PRE_first_tail_x1_r0_body.sizeDecA59 PRE_first_tail_x1_r0_body.sizePreA59 PRE_first_tail_x1_r0_body.bodyPatchB59 (fun _ hm => bodyO223 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr223).trans bodyInactive0) (bodyBr224.trans bodyBr223.symm) bodyCnt223 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc224 PRE_first_tail_x1_r0_body.bodyRunSeg59 bodyAcc225 bodyHalt225 PRE_first_tail_x1_r0_body.bodyStepA60 bodyTop226 (fun _ hm => bodyO224 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr224).trans bodyInactive0) (bodyBr226.trans bodyBr224.symm) bodyCnt224 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x1_r0_body.sizeA60 PRE_first_tail_x1_r0_body.sizeArgsA60 PRE_first_tail_x1_r0_body.sizeSymA60 PRE_first_tail_x1_r0_body.sizeMlxA60 PRE_first_tail_x1_r0_body.sizePayA60 PRE_first_tail_x1_r0_body.sizeTaA60 PRE_first_tail_x1_r0_body.sizeDecA60 PRE_first_tail_x1_r0_body.sizePreA60 PRE_first_tail_x1_r0_body.bodyPatchB60 (fun _ hm => bodyO226 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr226).trans bodyInactive0) (bodyBr227.trans bodyBr226.symm) bodyCnt226 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc227 PRE_first_tail_x1_r0_body.bodyRunSeg60 bodyAcc228 bodyHalt228 PRE_first_tail_x1_r0_body.bodyStepA61 bodyTop229 (fun _ hm => bodyO227 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr227).trans bodyInactive0) (bodyBr229.trans bodyBr227.symm) bodyCnt227 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x1_r0_body.sizeA61 PRE_first_tail_x1_r0_body.sizeArgsA61 PRE_first_tail_x1_r0_body.sizeSymA61 PRE_first_tail_x1_r0_body.sizeMlxA61 PRE_first_tail_x1_r0_body.sizePayA61 PRE_first_tail_x1_r0_body.sizeTaA61 PRE_first_tail_x1_r0_body.sizeDecA61 PRE_first_tail_x1_r0_body.sizePreA61 PRE_first_tail_x1_r0_body.bodyPatchB61 (fun _ hm => bodyO229 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr229).trans bodyInactive0) (bodyBr230.trans bodyBr229.symm) bodyCnt229 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc230 PRE_first_tail_x1_r0_body.bodyRunSeg61 bodyAcc231 bodyHalt231 PRE_first_tail_x1_r0_body.bodyStepA62 bodyTop232 (fun _ hm => bodyO230 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr230).trans bodyInactive0) (bodyBr232.trans bodyBr230.symm) bodyCnt230 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x1_r0_body.sizeA62 PRE_first_tail_x1_r0_body.sizeArgsA62 PRE_first_tail_x1_r0_body.sizeSymA62 PRE_first_tail_x1_r0_body.sizeMlxA62 PRE_first_tail_x1_r0_body.sizePayA62 PRE_first_tail_x1_r0_body.sizeTaA62 PRE_first_tail_x1_r0_body.sizeDecA62 PRE_first_tail_x1_r0_body.sizePreA62 PRE_first_tail_x1_r0_body.bodyPatchB62 (fun _ hm => bodyO232 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr232).trans bodyInactive0) (bodyBr233.trans bodyBr232.symm) bodyCnt232 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc233 PRE_first_tail_x1_r0_body.bodyRunSeg62 bodyAcc234 bodyHalt234 PRE_first_tail_x1_r0_body.bodyStepA63 bodyTop235 (fun _ hm => bodyO233 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr233).trans bodyInactive0) (bodyBr235.trans bodyBr233.symm) bodyCnt233 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift10 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S235.tab.length PRE_first_tail_x1_r0_body.s235.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P10.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P10 1253 PRE_first_tail_x1_r0_body.kappa10 PRE_first_tail_x1_r0_body.s237.ffi PRE_first_tail_x1_r0_body.s236.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_10
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_10
  have hcl : SSt (· < 1253) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s237.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S235.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_10] <;> decide) PRE_first_tail_x1_r0_body.cnodesK10 PRE_first_tail_x1_r0_body.cobjsK10
      PRE_first_tail_x1_r0_body.citemsK10 PRE_first_tail_x1_r0_body.cbd10 PRE_first_tail_x1_r0_body.csst10
  exact PRE_first_tail_x1_r0_body.cshift10 bodyNcl10 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_10] at this; exact this)


kernel_rfl bodyFramesEmpty10 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s236 a).isEmpty) = true
kernel_rfl bodyJsRoots10 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s235.next) PRE_first_tail_x1_r0_body.s237.trace PRE_first_tail_x1_r0_body.s237 = true
kernel_rfl bodyJsNative10 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s237.ffi) = true
kernel_rfl bodyLow10 : (PRE_first_tail_x1_r0_body.cws10 ++ PRE_first_tail_x1_r0_body.ws10).all (Nat.ble 9) = true
kernel_rfl bodyCntM10 : countersOkB PRE_first_tail_x1_r0_body.s235 PRE_first_tail_x1_r0_body.s236 = true
kernel_rfl bodyHi10 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s237.ffi).next setupP.E = true
kernel_rfl bodyNhi10 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s237.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge10 : bridgeOf PRE_first_tail_x1_r0_body.s236.ffi = bridgeOf PRE_first_tail_x1_r0_body.s235.ffi
kernel_rfl bodyNN10 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s235.ffi).nnext PRE_first_tail_x1_r0_body.P10.NL = true
kernel_rfl bodyXn10 : Nat.ble (⟨18808, 15905, 2698829, 1253⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s237.ffi).next = true
kernel_rfl bodyLo10 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s237.ffi).next = true
theorem bodyFacts10 : BodySiteFacts PRE_first_tail_x1_r0_body.s235 PRE_first_tail_x1_r0_body.s236 PRE_first_tail_x1_r0_body.s237 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S235 PRE_first_tail_x1_r0_body.S236 PRE_first_tail_x1_r0_body.S237
    PRE_first_tail_x1_r0_body.ws10 PRE_first_tail_x1_r0_body.cws10 PRE_first_tail_x1_r0_body.nr10 PRE_first_tail_x1_r0_body.pl10 PRE_first_tail_x1_r0_body.cl10 2699978 1253 PRE_first_tail_x1_r0_body.kd10 PRE_first_tail_x1_r0_body.kappa10 PRE_first_tail_x1_r0_body.P10
    ⟨18805, 15878, 2698823, 1235⟩ ⟨18808, 15905, 2698829, 1253⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap10
  clean := bodyClean10
  cfix := PRE_first_tail_x1_r0_body.cfix10
  zpl := PRE_first_tail_x1_r0_body.zpl10
  zplnd := PRE_first_tail_x1_r0_body.zplnd10
  zn1 := PRE_first_tail_x1_r0_body.zn110
  zfirst := PRE_first_tail_x1_r0_body.zfirst10
  zscn := PRE_first_tail_x1_r0_body.zscn10
  zsmn := PRE_first_tail_x1_r0_body.zsmn10
  zgrow := PRE_first_tail_x1_r0_body.zgrow10
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab10
  zfresh := PRE_first_tail_x1_r0_body.zfresh10
  zcnd := PRE_first_tail_x1_r0_body.zcnd10
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi10
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt10
  zgP := PRE_first_tail_x1_r0_body.zg10_2665
  zkP := PRE_first_tail_x1_r0_body.zk10_2665
  zmP := PRE_first_tail_x1_r0_body.zm10_2665
  zgC := PRE_first_tail_x1_r0_body.zg10_2673467
  zkC := PRE_first_tail_x1_r0_body.zk10_2673467
  zmC := PRE_first_tail_x1_r0_body.zm10_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw10_2673472
  zwV := PRE_first_tail_x1_r0_body.zw10_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap10
  zclbd := PRE_first_tail_x1_r0_body.zclbd10
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap10 PRE_first_tail_x1_r0_body.stFoot10 PRE_first_tail_x1_r0_body.iso10 PRE_first_tail_x1_r0_body.zwr10
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP10
  csupp := PRE_first_tail_x1_r0_body.csupp10
  cbound := PRE_first_tail_x1_r0_body.cbound10
  zimg := PRE_first_tail_x1_r0_body.zimg10
  zctl := PRE_first_tail_x1_r0_body.zctl10
  zstack := PRE_first_tail_x1_r0_body.zstack10
  zjobs := PRE_first_tail_x1_r0_body.zjobs10
  zstores := PRE_first_tail_x1_r0_body.zstores10
  zroots := PRE_first_tail_x1_r0_body.zroots10
  znC := PRE_first_tail_x1_r0_body.znC10
  ctab := PRE_first_tail_x1_r0_body.ctab10
  zbin := PRE_first_tail_x1_r0_body.zbin10
  cbridge := PRE_first_tail_x1_r0_body.cbridge10
  sbridge := bodyBridge10
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj10
  cshiftR := fun h hNL => bodyCshift10 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN10
  raised := PRE_first_tail_x1_r0_body.raised10
  cbigs := PRE_first_tail_x1_r0_body.cbigs10
  cjcl := PRE_first_tail_x1_r0_body.cjcl10
  xnLe := Nat.le_of_ble_eq_true bodyXn10
  loLe := Nat.le_of_ble_eq_true bodyLo10
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB10
  cntM := bodyCntM10
  hiLe := Nat.le_of_ble_eq_true bodyHi10
  nhiLe := Nat.le_of_ble_eq_true bodyNhi10
  jsHeap := bodyJs10
  jsRoots := bodyJsRoots10
  jsNative := bodyJsNative10
  framesEmpty := bodyFramesEmpty10
  trailOld := by decide
  lowVars := bodyLow10

def bodyQs10 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs10 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr10.map fun r => nth? PRE_first_tail_x1_r0_body.st10.S5.tab r
kernel_rfl bodyResChk10 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs10 bodyQs10) = true
kernel_rfl bodyLq10 : bodyQs10.length = PRE_first_tail_x1_r0_body.cws10.length
kernel_rfl bodyNrLo10 : PRE_first_tail_x1_r0_body.nr10.all (Nat.ble PRE_first_tail_x1_r0_body.S235.tab.length) = true
kernel_rfl bodySub10 : (Oracles.PRE_first_tail_x1_r0_body.map_site10.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost10 : postSubB bodyM PRE_first_tail_x1_r0_body.ws10 PRE_first_tail_x1_r0_body.cws10 bodyQs10 = true
kernel_rfl bodyDrop10 : Nat.ble (14006 + (PRE_first_tail_x1_r0_body.s236.next - PRE_first_tail_x1_r0_body.s237.next)) 15155 = true
kernel_rfl bodyDropH10 : Nat.ble (225 + ((mlxOf PRE_first_tail_x1_r0_body.s236.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s237.ffi).next)) 250 = true
kernel_rfl bodyDropN10 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s236.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s237.ffi).nnext)) 0 = true
kernel_rfl bodyDv10 : bodyΘ.1.take 180 = bodyΘ.1.take 162 ++ PRE_first_tail_x1_r0_body.cws10
kernel_rfl bodyDe10 : bodyΘ.2.take 180 = bodyΘ.2.take 162 ++ PRE_first_tail_x1_r0_body.nr10.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st10.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 162) (bodyΘ.2.take 162)))
kernel_rfl bodyDl10 : (bodyΘ.1.take 162).length = (bodyΘ.2.take 162).length
kernel_rfl bodyDold10 : (bodyΘ.1.take 162).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws10).isNone && !PRE_first_tail_x1_r0_body.ws10.contains v) = true
kernel_rfl bodyDfree10 : (bodyΘ.2.take 180).all (fun e => (PRE_first_tail_x1_r0_body.cws10 ++ PRE_first_tail_x1_r0_body.ws10).all fun w => e.noVar w) = true

theorem bodyStep10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 162⟩ bodyM PRE_first_tail_x1_r0_body.s235 PRE_first_tail_x1_r0_body.S235)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 180⟩ bodyM PRE_first_tail_x1_r0_body.s237 PRE_first_tail_x1_r0_body.S237) (11334 + 1) :=
  bodySite bodyFacts10.cfix bodyFacts10.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st10.S5.tab) (Es := bodyEs10) (qs := bodyQs10)
    (ok := PRE_first_tail_x1_r0_body.st10.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site10 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts10
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site10 r hr) hi (MapOk.sub hm (sub_of_all bodySub10)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk10 r hr) hi hm ho hq)
    bodyLq10 rfl bodyNrLo10 (postSub_sound bodyPost10)
    (Nat.le_of_ble_eq_true bodyDrop10) (by decide) (Nat.le_of_ble_eq_true bodyDropH10) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN10) (by decide)
    bodyDv10 bodyDe10 bodyDl10 bodyDold10 bodyDfree10 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site11 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site11 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site11) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st11.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site11
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st11.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st11.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s256 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s257 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S256 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws11 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st11.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st11.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso11
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_11
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st11.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot11
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup11
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound11
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace11
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged11
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws11.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st11.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S256.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_11]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen11.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh11
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl11 : Conv.NClean (⟨18868, 15950, 2701334, 1357⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s256.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl11 (PRE_first_tail_x1_r0_body.cncl10 bodyNcl10)

theorem bodyClean11 : Conv.JClean (⟨18868, 15950, 2701334, 1357⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s256 :=
  PRE_first_tail_x1_r0_body.gjcl11 (PRE_first_tail_x1_r0_body.cjcl10 bodyClean10)

kernel_rfl bodyJsLe11 : Nat.ble PRE_first_tail_x1_r0_body.s235.next PRE_first_tail_x1_r0_body.s256.next = true
kernel_rfl bodyJsList11 : (PRE_first_tail_x1_r0_body.gjh11 ++ PRE_first_tail_x1_r0_body.cl11).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s256.next) PRE_first_tail_x1_r0_body.s258) = true
theorem bodyJs11 : JsHeapAbove PRE_first_tail_x1_r0_body.s256.next PRE_first_tail_x1_r0_body.s258 :=
  JsHeapAbove.glueSite bodyJs10 (Nat.le_of_ble_eq_true bodyJsLe11) PRE_first_tail_x1_r0_body.gjk11 PRE_first_tail_x1_r0_body.gjbd11 PRE_first_tail_x1_r0_body.cheap11 PRE_first_tail_x1_r0_body.zclbd11 bodyJsList11

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO237 : PRE_first_tail_x1_r0_body.S237.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S237.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr237 : bridgeOf PRE_first_tail_x1_r0_body.s237.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc237 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s237 PRE_first_tail_x1_r0_body.S237) = fun _ _ => true
kernel_rfl bodyAcc238 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s238 PRE_first_tail_x1_r0_body.S238) = fun _ _ => true
kernel_rfl bodyBr239 : bridgeOf PRE_first_tail_x1_r0_body.s239.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt238 : isHalt PRE_first_tail_x1_r0_body.s238.ctl = false
kernel_rfl bodyTop239 : noRetBlock PRE_first_tail_x1_r0_body.s239 = true
kernel_rfl bodyCnt237 : countersOkB PRE_first_tail_x1_r0_body.s237 PRE_first_tail_x1_r0_body.s239 = true
kernel_rfl bodyO239 : PRE_first_tail_x1_r0_body.S239.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S239.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr240 : bridgeOf PRE_first_tail_x1_r0_body.s240.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt239 : countersOkB PRE_first_tail_x1_r0_body.s239 PRE_first_tail_x1_r0_body.s240 = true
kernel_rfl bodyO240 : PRE_first_tail_x1_r0_body.S240.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S240.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc240 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s240 PRE_first_tail_x1_r0_body.S240) = fun _ _ => true
kernel_rfl bodyAcc244 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s244 PRE_first_tail_x1_r0_body.S244) = fun _ _ => true
kernel_rfl bodyBr245 : bridgeOf PRE_first_tail_x1_r0_body.s245.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt244 : isHalt PRE_first_tail_x1_r0_body.s244.ctl = false
kernel_rfl bodyTop245 : noRetBlock PRE_first_tail_x1_r0_body.s245 = true
kernel_rfl bodyCnt240 : countersOkB PRE_first_tail_x1_r0_body.s240 PRE_first_tail_x1_r0_body.s245 = true
kernel_rfl bodyO245 : PRE_first_tail_x1_r0_body.S245.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S245.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr246 : bridgeOf PRE_first_tail_x1_r0_body.s246.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt245 : countersOkB PRE_first_tail_x1_r0_body.s245 PRE_first_tail_x1_r0_body.s246 = true
kernel_rfl bodyO246 : PRE_first_tail_x1_r0_body.S246.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S246.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc246 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s246 PRE_first_tail_x1_r0_body.S246) = fun _ _ => true
kernel_rfl bodyAcc248 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s248 PRE_first_tail_x1_r0_body.S248) = fun _ _ => true
kernel_rfl bodyBr249 : bridgeOf PRE_first_tail_x1_r0_body.s249.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt248 : isHalt PRE_first_tail_x1_r0_body.s248.ctl = false
kernel_rfl bodyTop249 : noRetBlock PRE_first_tail_x1_r0_body.s249 = true
kernel_rfl bodyCnt246 : countersOkB PRE_first_tail_x1_r0_body.s246 PRE_first_tail_x1_r0_body.s249 = true
kernel_rfl bodyO249 : PRE_first_tail_x1_r0_body.S249.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S249.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr250 : bridgeOf PRE_first_tail_x1_r0_body.s250.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt249 : countersOkB PRE_first_tail_x1_r0_body.s249 PRE_first_tail_x1_r0_body.s250 = true
kernel_rfl bodyO250 : PRE_first_tail_x1_r0_body.S250.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S250.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc250 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s250 PRE_first_tail_x1_r0_body.S250) = fun _ _ => true
kernel_rfl bodyAcc251 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s251 PRE_first_tail_x1_r0_body.S251) = fun _ _ => true
kernel_rfl bodyBr252 : bridgeOf PRE_first_tail_x1_r0_body.s252.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt251 : isHalt PRE_first_tail_x1_r0_body.s251.ctl = false
kernel_rfl bodyTop252 : noRetBlock PRE_first_tail_x1_r0_body.s252 = true
kernel_rfl bodyCnt250 : countersOkB PRE_first_tail_x1_r0_body.s250 PRE_first_tail_x1_r0_body.s252 = true
kernel_rfl bodyO252 : PRE_first_tail_x1_r0_body.S252.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S252.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr253 : bridgeOf PRE_first_tail_x1_r0_body.s253.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt252 : countersOkB PRE_first_tail_x1_r0_body.s252 PRE_first_tail_x1_r0_body.s253 = true
kernel_rfl bodyO253 : PRE_first_tail_x1_r0_body.S253.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S253.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc253 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s253 PRE_first_tail_x1_r0_body.S253) = fun _ _ => true
kernel_rfl bodyAcc255 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s255 PRE_first_tail_x1_r0_body.S255) = fun _ _ => true
kernel_rfl bodyBr256 : bridgeOf PRE_first_tail_x1_r0_body.s256.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt255 : isHalt PRE_first_tail_x1_r0_body.s255.ctl = false
kernel_rfl bodyTop256 : noRetBlock PRE_first_tail_x1_r0_body.s256 = true
kernel_rfl bodyCnt253 : countersOkB PRE_first_tail_x1_r0_body.s253 PRE_first_tail_x1_r0_body.s256 = true

theorem bodyGlue11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 180⟩ bodyM PRE_first_tail_x1_r0_body.s237 PRE_first_tail_x1_r0_body.S237)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 180⟩ bodyM PRE_first_tail_x1_r0_body.s256 PRE_first_tail_x1_r0_body.S256) 24808 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc237 PRE_first_tail_x1_r0_body.bodyRunSeg63 bodyAcc238 bodyHalt238 PRE_first_tail_x1_r0_body.bodyStepA64 bodyTop239 (fun _ hm => bodyO237 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr237).trans bodyInactive0) (bodyBr239.trans bodyBr237.symm) bodyCnt237 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) PRE_first_tail_x1_r0_body.sizeA64 PRE_first_tail_x1_r0_body.sizeArgsA64 PRE_first_tail_x1_r0_body.sizeSymA64 PRE_first_tail_x1_r0_body.sizeMlxA64 PRE_first_tail_x1_r0_body.sizePayA64 PRE_first_tail_x1_r0_body.sizeTaA64 PRE_first_tail_x1_r0_body.sizeDecA64 PRE_first_tail_x1_r0_body.sizePreA64 PRE_first_tail_x1_r0_body.bodyPatchB64 (fun _ hm => bodyO239 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr239).trans bodyInactive0) (bodyBr240.trans bodyBr239.symm) bodyCnt239 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc240 PRE_first_tail_x1_r0_body.bodyRunSeg64 bodyAcc244 bodyHalt244 PRE_first_tail_x1_r0_body.bodyStepA65 bodyTop245 (fun _ hm => bodyO240 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr240).trans bodyInactive0) (bodyBr245.trans bodyBr240.symm) bodyCnt240 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) PRE_first_tail_x1_r0_body.sizeA65 PRE_first_tail_x1_r0_body.sizeArgsA65 PRE_first_tail_x1_r0_body.sizeSymA65 PRE_first_tail_x1_r0_body.sizeMlxA65 PRE_first_tail_x1_r0_body.sizePayA65 PRE_first_tail_x1_r0_body.sizeTaA65 PRE_first_tail_x1_r0_body.sizeDecA65 PRE_first_tail_x1_r0_body.sizePreA65 PRE_first_tail_x1_r0_body.bodyPatchB65 (fun _ hm => bodyO245 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr245).trans bodyInactive0) (bodyBr246.trans bodyBr245.symm) bodyCnt245 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc246 PRE_first_tail_x1_r0_body.bodyRunSeg65 bodyAcc248 bodyHalt248 PRE_first_tail_x1_r0_body.bodyStepA66 bodyTop249 (fun _ hm => bodyO246 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr246).trans bodyInactive0) (bodyBr249.trans bodyBr246.symm) bodyCnt246 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) PRE_first_tail_x1_r0_body.sizeA66 PRE_first_tail_x1_r0_body.sizeArgsA66 PRE_first_tail_x1_r0_body.sizeSymA66 PRE_first_tail_x1_r0_body.sizeMlxA66 PRE_first_tail_x1_r0_body.sizePayA66 PRE_first_tail_x1_r0_body.sizeTaA66 PRE_first_tail_x1_r0_body.sizeDecA66 PRE_first_tail_x1_r0_body.sizePreA66 PRE_first_tail_x1_r0_body.bodyPatchB66 (fun _ hm => bodyO249 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr249).trans bodyInactive0) (bodyBr250.trans bodyBr249.symm) bodyCnt249 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc250 PRE_first_tail_x1_r0_body.bodyRunSeg66 bodyAcc251 bodyHalt251 PRE_first_tail_x1_r0_body.bodyStepA67 bodyTop252 (fun _ hm => bodyO250 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr250).trans bodyInactive0) (bodyBr252.trans bodyBr250.symm) bodyCnt250 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) PRE_first_tail_x1_r0_body.sizeA67 PRE_first_tail_x1_r0_body.sizeArgsA67 PRE_first_tail_x1_r0_body.sizeSymA67 PRE_first_tail_x1_r0_body.sizeMlxA67 PRE_first_tail_x1_r0_body.sizePayA67 PRE_first_tail_x1_r0_body.sizeTaA67 PRE_first_tail_x1_r0_body.sizeDecA67 PRE_first_tail_x1_r0_body.sizePreA67 PRE_first_tail_x1_r0_body.bodyPatchB67 (fun _ hm => bodyO252 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr252).trans bodyInactive0) (bodyBr253.trans bodyBr252.symm) bodyCnt252 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc253 PRE_first_tail_x1_r0_body.bodyRunSeg67 bodyAcc255 bodyHalt255 PRE_first_tail_x1_r0_body.bodyStepA68 bodyTop256 (fun _ hm => bodyO253 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr253).trans bodyInactive0) (bodyBr256.trans bodyBr253.symm) bodyCnt253 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift11 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S256.tab.length PRE_first_tail_x1_r0_body.s256.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P11.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P11 1366 PRE_first_tail_x1_r0_body.kappa11 PRE_first_tail_x1_r0_body.s258.ffi PRE_first_tail_x1_r0_body.s257.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_11
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_11
  have hcl : SSt (· < 1366) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s258.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S256.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_11] <;> decide) PRE_first_tail_x1_r0_body.cnodesK11 PRE_first_tail_x1_r0_body.cobjsK11
      PRE_first_tail_x1_r0_body.citemsK11 PRE_first_tail_x1_r0_body.cbd11 PRE_first_tail_x1_r0_body.csst11
  exact PRE_first_tail_x1_r0_body.cshift11 bodyNcl11 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_11] at this; exact this)


kernel_rfl bodyFramesEmpty11 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s257 a).isEmpty) = true
kernel_rfl bodyJsRoots11 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s256.next) PRE_first_tail_x1_r0_body.s258.trace PRE_first_tail_x1_r0_body.s258 = true
kernel_rfl bodyJsNative11 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s258.ffi) = true
kernel_rfl bodyLow11 : (PRE_first_tail_x1_r0_body.cws11 ++ PRE_first_tail_x1_r0_body.ws11).all (Nat.ble 9) = true
kernel_rfl bodyCntM11 : countersOkB PRE_first_tail_x1_r0_body.s256 PRE_first_tail_x1_r0_body.s257 = true
kernel_rfl bodyHi11 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s258.ffi).next setupP.E = true
kernel_rfl bodyNhi11 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s258.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge11 : bridgeOf PRE_first_tail_x1_r0_body.s257.ffi = bridgeOf PRE_first_tail_x1_r0_body.s256.ffi
kernel_rfl bodyNN11 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s256.ffi).nnext PRE_first_tail_x1_r0_body.P11.NL = true
kernel_rfl bodyXn11 : Nat.ble (⟨18872, 15956, 2701349, 1366⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s258.ffi).next = true
kernel_rfl bodyLo11 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s258.ffi).next = true
theorem bodyFacts11 : BodySiteFacts PRE_first_tail_x1_r0_body.s256 PRE_first_tail_x1_r0_body.s257 PRE_first_tail_x1_r0_body.s258 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S256 PRE_first_tail_x1_r0_body.S257 PRE_first_tail_x1_r0_body.S258
    PRE_first_tail_x1_r0_body.ws11 PRE_first_tail_x1_r0_body.cws11 PRE_first_tail_x1_r0_body.nr11 PRE_first_tail_x1_r0_body.pl11 PRE_first_tail_x1_r0_body.cl11 2701699 1366 PRE_first_tail_x1_r0_body.kd11 PRE_first_tail_x1_r0_body.kappa11 PRE_first_tail_x1_r0_body.P11
    ⟨18868, 15950, 2701334, 1357⟩ ⟨18872, 15956, 2701349, 1366⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap11
  clean := bodyClean11
  cfix := PRE_first_tail_x1_r0_body.cfix11
  zpl := PRE_first_tail_x1_r0_body.zpl11
  zplnd := PRE_first_tail_x1_r0_body.zplnd11
  zn1 := PRE_first_tail_x1_r0_body.zn111
  zfirst := PRE_first_tail_x1_r0_body.zfirst11
  zscn := PRE_first_tail_x1_r0_body.zscn11
  zsmn := PRE_first_tail_x1_r0_body.zsmn11
  zgrow := PRE_first_tail_x1_r0_body.zgrow11
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab11
  zfresh := PRE_first_tail_x1_r0_body.zfresh11
  zcnd := PRE_first_tail_x1_r0_body.zcnd11
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi11
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt11
  zgP := PRE_first_tail_x1_r0_body.zg11_2665
  zkP := PRE_first_tail_x1_r0_body.zk11_2665
  zmP := PRE_first_tail_x1_r0_body.zm11_2665
  zgC := PRE_first_tail_x1_r0_body.zg11_2673467
  zkC := PRE_first_tail_x1_r0_body.zk11_2673467
  zmC := PRE_first_tail_x1_r0_body.zm11_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw11_2673472
  zwV := PRE_first_tail_x1_r0_body.zw11_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap11
  zclbd := PRE_first_tail_x1_r0_body.zclbd11
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap11 PRE_first_tail_x1_r0_body.stFoot11 PRE_first_tail_x1_r0_body.iso11 PRE_first_tail_x1_r0_body.zwr11
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP11
  csupp := PRE_first_tail_x1_r0_body.csupp11
  cbound := PRE_first_tail_x1_r0_body.cbound11
  zimg := PRE_first_tail_x1_r0_body.zimg11
  zctl := PRE_first_tail_x1_r0_body.zctl11
  zstack := PRE_first_tail_x1_r0_body.zstack11
  zjobs := PRE_first_tail_x1_r0_body.zjobs11
  zstores := PRE_first_tail_x1_r0_body.zstores11
  zroots := PRE_first_tail_x1_r0_body.zroots11
  znC := PRE_first_tail_x1_r0_body.znC11
  ctab := PRE_first_tail_x1_r0_body.ctab11
  zbin := PRE_first_tail_x1_r0_body.zbin11
  cbridge := PRE_first_tail_x1_r0_body.cbridge11
  sbridge := bodyBridge11
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj11
  cshiftR := fun h hNL => bodyCshift11 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN11
  raised := PRE_first_tail_x1_r0_body.raised11
  cbigs := PRE_first_tail_x1_r0_body.cbigs11
  cjcl := PRE_first_tail_x1_r0_body.cjcl11
  xnLe := Nat.le_of_ble_eq_true bodyXn11
  loLe := Nat.le_of_ble_eq_true bodyLo11
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB11
  cntM := bodyCntM11
  hiLe := Nat.le_of_ble_eq_true bodyHi11
  nhiLe := Nat.le_of_ble_eq_true bodyNhi11
  jsHeap := bodyJs11
  jsRoots := bodyJsRoots11
  jsNative := bodyJsNative11
  framesEmpty := bodyFramesEmpty11
  trailOld := by decide
  lowVars := bodyLow11

def bodyQs11 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs11 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr11.map fun r => nth? PRE_first_tail_x1_r0_body.st11.S3.tab r
kernel_rfl bodyResChk11 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs11 bodyQs11) = true
kernel_rfl bodyLq11 : bodyQs11.length = PRE_first_tail_x1_r0_body.cws11.length
kernel_rfl bodyNrLo11 : PRE_first_tail_x1_r0_body.nr11.all (Nat.ble PRE_first_tail_x1_r0_body.S256.tab.length) = true
kernel_rfl bodySub11 : (Oracles.PRE_first_tail_x1_r0_body.map_site11.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost11 : postSubB bodyM PRE_first_tail_x1_r0_body.ws11 PRE_first_tail_x1_r0_body.cws11 bodyQs11 = true
kernel_rfl bodyDrop11 : Nat.ble (15155 + (PRE_first_tail_x1_r0_body.s257.next - PRE_first_tail_x1_r0_body.s258.next)) 15505 = true
kernel_rfl bodyDropH11 : Nat.ble (250 + ((mlxOf PRE_first_tail_x1_r0_body.s257.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s258.ffi).next)) 252 = true
kernel_rfl bodyDropN11 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s257.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s258.ffi).nnext)) 0 = true
kernel_rfl bodyDv11 : bodyΘ.1.take 189 = bodyΘ.1.take 180 ++ PRE_first_tail_x1_r0_body.cws11
kernel_rfl bodyDe11 : bodyΘ.2.take 189 = bodyΘ.2.take 180 ++ PRE_first_tail_x1_r0_body.nr11.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st11.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 180) (bodyΘ.2.take 180)))
kernel_rfl bodyDl11 : (bodyΘ.1.take 180).length = (bodyΘ.2.take 180).length
kernel_rfl bodyDold11 : (bodyΘ.1.take 180).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws11).isNone && !PRE_first_tail_x1_r0_body.ws11.contains v) = true
kernel_rfl bodyDfree11 : (bodyΘ.2.take 189).all (fun e => (PRE_first_tail_x1_r0_body.cws11 ++ PRE_first_tail_x1_r0_body.ws11).all fun w => e.noVar w) = true

theorem bodyStep11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 180⟩ bodyM PRE_first_tail_x1_r0_body.s256 PRE_first_tail_x1_r0_body.S256)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 189⟩ bodyM PRE_first_tail_x1_r0_body.s258 PRE_first_tail_x1_r0_body.S258) (3452 + 1) :=
  bodySite bodyFacts11.cfix bodyFacts11.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x1_r0_body.st11.S3.tab) (Es := bodyEs11) (qs := bodyQs11)
    (ok := PRE_first_tail_x1_r0_body.st11.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site11 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts11
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site11 r hr) hi (MapOk.sub hm (sub_of_all bodySub11)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk11 r hr) hi hm ho hq)
    bodyLq11 rfl bodyNrLo11 (postSub_sound bodyPost11)
    (Nat.le_of_ble_eq_true bodyDrop11) (by decide) (Nat.le_of_ble_eq_true bodyDropH11) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN11) (by decide)
    bodyDv11 bodyDe11 bodyDl11 bodyDold11 bodyDfree11 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyOracles_3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_g12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g12 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g12) (List.take 35 (List.drop 409 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site12 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st12.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g13 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g13) (List.take 32 (List.drop 444 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site13 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st13.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g14 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g14 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g14) (List.take 32 (List.drop 476 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site14 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site14 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st14.S0.oracle) = true

def PRE_first_tail_x1_r0_body.map_g15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_g15 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_g15) (List.take 43 (List.drop 508 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.OR))) = true

def PRE_first_tail_x1_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site15 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st15.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site12 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st12.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site12
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st12.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st12.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s278 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s279 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S278 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws12 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st12.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st12.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso12
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_12
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st12.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot12
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup12
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound12
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace12
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged12
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws12.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st12.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S278.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_12]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen12.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh12
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl12 : Conv.NClean (⟨18927, 15989, 2703709, 1467⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s278.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl12 (PRE_first_tail_x1_r0_body.cncl11 bodyNcl11)

theorem bodyClean12 : Conv.JClean (⟨18927, 15989, 2703709, 1467⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s278 :=
  PRE_first_tail_x1_r0_body.gjcl12 (PRE_first_tail_x1_r0_body.cjcl11 bodyClean11)

kernel_rfl bodyJsLe12 : Nat.ble PRE_first_tail_x1_r0_body.s256.next PRE_first_tail_x1_r0_body.s278.next = true
kernel_rfl bodyJsList12 : (PRE_first_tail_x1_r0_body.gjh12 ++ PRE_first_tail_x1_r0_body.cl12).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s278.next) PRE_first_tail_x1_r0_body.s280) = true
theorem bodyJs12 : JsHeapAbove PRE_first_tail_x1_r0_body.s278.next PRE_first_tail_x1_r0_body.s280 :=
  JsHeapAbove.glueSite bodyJs11 (Nat.le_of_ble_eq_true bodyJsLe12) PRE_first_tail_x1_r0_body.gjk12 PRE_first_tail_x1_r0_body.gjbd12 PRE_first_tail_x1_r0_body.cheap12 PRE_first_tail_x1_r0_body.zclbd12 bodyJsList12

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO258 : PRE_first_tail_x1_r0_body.S258.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S258.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr258 : bridgeOf PRE_first_tail_x1_r0_body.s258.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc258 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s258 PRE_first_tail_x1_r0_body.S258) = fun _ _ => true
kernel_rfl bodyAcc259 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s259 PRE_first_tail_x1_r0_body.S259) = fun _ _ => true
kernel_rfl bodyBr260 : bridgeOf PRE_first_tail_x1_r0_body.s260.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt259 : isHalt PRE_first_tail_x1_r0_body.s259.ctl = false
kernel_rfl bodyTop260 : noRetBlock PRE_first_tail_x1_r0_body.s260 = true
kernel_rfl bodyCnt258 : countersOkB PRE_first_tail_x1_r0_body.s258 PRE_first_tail_x1_r0_body.s260 = true
kernel_rfl bodyO260 : PRE_first_tail_x1_r0_body.S260.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S260.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr261 : bridgeOf PRE_first_tail_x1_r0_body.s261.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt260 : countersOkB PRE_first_tail_x1_r0_body.s260 PRE_first_tail_x1_r0_body.s261 = true
kernel_rfl bodyO261 : PRE_first_tail_x1_r0_body.S261.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S261.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc261 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s261 PRE_first_tail_x1_r0_body.S261) = fun _ _ => true
kernel_rfl bodyAcc265 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s265 PRE_first_tail_x1_r0_body.S265) = fun _ _ => true
kernel_rfl bodyBr266 : bridgeOf PRE_first_tail_x1_r0_body.s266.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt265 : isHalt PRE_first_tail_x1_r0_body.s265.ctl = false
kernel_rfl bodyTop266 : noRetBlock PRE_first_tail_x1_r0_body.s266 = true
kernel_rfl bodyCnt261 : countersOkB PRE_first_tail_x1_r0_body.s261 PRE_first_tail_x1_r0_body.s266 = true
kernel_rfl bodyO266 : PRE_first_tail_x1_r0_body.S266.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S266.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr267 : bridgeOf PRE_first_tail_x1_r0_body.s267.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt266 : countersOkB PRE_first_tail_x1_r0_body.s266 PRE_first_tail_x1_r0_body.s267 = true
kernel_rfl bodyO267 : PRE_first_tail_x1_r0_body.S267.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S267.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc267 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s267 PRE_first_tail_x1_r0_body.S267) = fun _ _ => true
kernel_rfl bodyAcc268 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s268 PRE_first_tail_x1_r0_body.S268) = fun _ _ => true
kernel_rfl bodyBr269 : bridgeOf PRE_first_tail_x1_r0_body.s269.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt268 : isHalt PRE_first_tail_x1_r0_body.s268.ctl = false
kernel_rfl bodyTop269 : noRetBlock PRE_first_tail_x1_r0_body.s269 = true
kernel_rfl bodyCnt267 : countersOkB PRE_first_tail_x1_r0_body.s267 PRE_first_tail_x1_r0_body.s269 = true
kernel_rfl bodyO269 : PRE_first_tail_x1_r0_body.S269.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S269.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr270 : bridgeOf PRE_first_tail_x1_r0_body.s270.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt269 : countersOkB PRE_first_tail_x1_r0_body.s269 PRE_first_tail_x1_r0_body.s270 = true
kernel_rfl bodyO270 : PRE_first_tail_x1_r0_body.S270.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S270.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc270 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s270 PRE_first_tail_x1_r0_body.S270) = fun _ _ => true
kernel_rfl bodyAcc271 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s271 PRE_first_tail_x1_r0_body.S271) = fun _ _ => true
kernel_rfl bodyBr272 : bridgeOf PRE_first_tail_x1_r0_body.s272.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt271 : isHalt PRE_first_tail_x1_r0_body.s271.ctl = false
kernel_rfl bodyTop272 : noRetBlock PRE_first_tail_x1_r0_body.s272 = true
kernel_rfl bodyCnt270 : countersOkB PRE_first_tail_x1_r0_body.s270 PRE_first_tail_x1_r0_body.s272 = true
kernel_rfl bodyO272 : PRE_first_tail_x1_r0_body.S272.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S272.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr273 : bridgeOf PRE_first_tail_x1_r0_body.s273.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt272 : countersOkB PRE_first_tail_x1_r0_body.s272 PRE_first_tail_x1_r0_body.s273 = true
kernel_rfl bodyO273 : PRE_first_tail_x1_r0_body.S273.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S273.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc273 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s273 PRE_first_tail_x1_r0_body.S273) = fun _ _ => true
kernel_rfl bodyAcc274 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s274 PRE_first_tail_x1_r0_body.S274) = fun _ _ => true
kernel_rfl bodyBr275 : bridgeOf PRE_first_tail_x1_r0_body.s275.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt274 : isHalt PRE_first_tail_x1_r0_body.s274.ctl = false
kernel_rfl bodyTop275 : noRetBlock PRE_first_tail_x1_r0_body.s275 = true
kernel_rfl bodyCnt273 : countersOkB PRE_first_tail_x1_r0_body.s273 PRE_first_tail_x1_r0_body.s275 = true
kernel_rfl bodyO275 : PRE_first_tail_x1_r0_body.S275.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S275.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr276 : bridgeOf PRE_first_tail_x1_r0_body.s276.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt275 : countersOkB PRE_first_tail_x1_r0_body.s275 PRE_first_tail_x1_r0_body.s276 = true
kernel_rfl bodyO276 : PRE_first_tail_x1_r0_body.S276.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S276.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc276 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s276 PRE_first_tail_x1_r0_body.S276) = fun _ _ => true
kernel_rfl bodyAcc277 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s277 PRE_first_tail_x1_r0_body.S277) = fun _ _ => true
kernel_rfl bodyBr278 : bridgeOf PRE_first_tail_x1_r0_body.s278.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt277 : isHalt PRE_first_tail_x1_r0_body.s277.ctl = false
kernel_rfl bodyTop278 : noRetBlock PRE_first_tail_x1_r0_body.s278 = true
kernel_rfl bodyCnt276 : countersOkB PRE_first_tail_x1_r0_body.s276 PRE_first_tail_x1_r0_body.s278 = true

theorem bodyGlue12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 189⟩ bodyM PRE_first_tail_x1_r0_body.s258 PRE_first_tail_x1_r0_body.S258)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 189⟩ bodyM PRE_first_tail_x1_r0_body.s278 PRE_first_tail_x1_r0_body.S278) 23510 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc258 PRE_first_tail_x1_r0_body.bodyRunSeg68 bodyAcc259 bodyHalt259 PRE_first_tail_x1_r0_body.bodyStepA69 bodyTop260 (fun _ hm => bodyO258 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr258).trans bodyInactive0) (bodyBr260.trans bodyBr258.symm) bodyCnt258 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x1_r0_body.sizeA69 PRE_first_tail_x1_r0_body.sizeArgsA69 PRE_first_tail_x1_r0_body.sizeSymA69 PRE_first_tail_x1_r0_body.sizeMlxA69 PRE_first_tail_x1_r0_body.sizePayA69 PRE_first_tail_x1_r0_body.sizeTaA69 PRE_first_tail_x1_r0_body.sizeDecA69 PRE_first_tail_x1_r0_body.sizePreA69 PRE_first_tail_x1_r0_body.bodyPatchB69 (fun _ hm => bodyO260 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr260).trans bodyInactive0) (bodyBr261.trans bodyBr260.symm) bodyCnt260 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc261 PRE_first_tail_x1_r0_body.bodyRunSeg69 bodyAcc265 bodyHalt265 PRE_first_tail_x1_r0_body.bodyStepA70 bodyTop266 (fun _ hm => bodyO261 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr261).trans bodyInactive0) (bodyBr266.trans bodyBr261.symm) bodyCnt261 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x1_r0_body.sizeA70 PRE_first_tail_x1_r0_body.sizeArgsA70 PRE_first_tail_x1_r0_body.sizeSymA70 PRE_first_tail_x1_r0_body.sizeMlxA70 PRE_first_tail_x1_r0_body.sizePayA70 PRE_first_tail_x1_r0_body.sizeTaA70 PRE_first_tail_x1_r0_body.sizeDecA70 PRE_first_tail_x1_r0_body.sizePreA70 PRE_first_tail_x1_r0_body.bodyPatchB70 (fun _ hm => bodyO266 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr266).trans bodyInactive0) (bodyBr267.trans bodyBr266.symm) bodyCnt266 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc267 PRE_first_tail_x1_r0_body.bodyRunSeg70 bodyAcc268 bodyHalt268 PRE_first_tail_x1_r0_body.bodyStepA71 bodyTop269 (fun _ hm => bodyO267 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr267).trans bodyInactive0) (bodyBr269.trans bodyBr267.symm) bodyCnt267 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x1_r0_body.sizeA71 PRE_first_tail_x1_r0_body.sizeArgsA71 PRE_first_tail_x1_r0_body.sizeSymA71 PRE_first_tail_x1_r0_body.sizeMlxA71 PRE_first_tail_x1_r0_body.sizePayA71 PRE_first_tail_x1_r0_body.sizeTaA71 PRE_first_tail_x1_r0_body.sizeDecA71 PRE_first_tail_x1_r0_body.sizePreA71 PRE_first_tail_x1_r0_body.bodyPatchB71 (fun _ hm => bodyO269 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr269).trans bodyInactive0) (bodyBr270.trans bodyBr269.symm) bodyCnt269 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc270 PRE_first_tail_x1_r0_body.bodyRunSeg71 bodyAcc271 bodyHalt271 PRE_first_tail_x1_r0_body.bodyStepA72 bodyTop272 (fun _ hm => bodyO270 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr270).trans bodyInactive0) (bodyBr272.trans bodyBr270.symm) bodyCnt270 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x1_r0_body.sizeA72 PRE_first_tail_x1_r0_body.sizeArgsA72 PRE_first_tail_x1_r0_body.sizeSymA72 PRE_first_tail_x1_r0_body.sizeMlxA72 PRE_first_tail_x1_r0_body.sizePayA72 PRE_first_tail_x1_r0_body.sizeTaA72 PRE_first_tail_x1_r0_body.sizeDecA72 PRE_first_tail_x1_r0_body.sizePreA72 PRE_first_tail_x1_r0_body.bodyPatchB72 (fun _ hm => bodyO272 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr272).trans bodyInactive0) (bodyBr273.trans bodyBr272.symm) bodyCnt272 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc273 PRE_first_tail_x1_r0_body.bodyRunSeg72 bodyAcc274 bodyHalt274 PRE_first_tail_x1_r0_body.bodyStepA73 bodyTop275 (fun _ hm => bodyO273 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr273).trans bodyInactive0) (bodyBr275.trans bodyBr273.symm) bodyCnt273 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x1_r0_body.sizeA73 PRE_first_tail_x1_r0_body.sizeArgsA73 PRE_first_tail_x1_r0_body.sizeSymA73 PRE_first_tail_x1_r0_body.sizeMlxA73 PRE_first_tail_x1_r0_body.sizePayA73 PRE_first_tail_x1_r0_body.sizeTaA73 PRE_first_tail_x1_r0_body.sizeDecA73 PRE_first_tail_x1_r0_body.sizePreA73 PRE_first_tail_x1_r0_body.bodyPatchB73 (fun _ hm => bodyO275 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr275).trans bodyInactive0) (bodyBr276.trans bodyBr275.symm) bodyCnt275 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc276 PRE_first_tail_x1_r0_body.bodyRunSeg73 bodyAcc277 bodyHalt277 PRE_first_tail_x1_r0_body.bodyStepA74 bodyTop278 (fun _ hm => bodyO276 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr276).trans bodyInactive0) (bodyBr278.trans bodyBr276.symm) bodyCnt276 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift12 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S278.tab.length PRE_first_tail_x1_r0_body.s278.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P12.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P12 1485 PRE_first_tail_x1_r0_body.kappa12 PRE_first_tail_x1_r0_body.s280.ffi PRE_first_tail_x1_r0_body.s279.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_12
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_12
  have hcl : SSt (· < 1485) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s280.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S278.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_12] <;> decide) PRE_first_tail_x1_r0_body.cnodesK12 PRE_first_tail_x1_r0_body.cobjsK12
      PRE_first_tail_x1_r0_body.citemsK12 PRE_first_tail_x1_r0_body.cbd12 PRE_first_tail_x1_r0_body.csst12
  exact PRE_first_tail_x1_r0_body.cshift12 bodyNcl12 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_12] at this; exact this)


kernel_rfl bodyFramesEmpty12 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s279 a).isEmpty) = true
kernel_rfl bodyJsRoots12 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s278.next) PRE_first_tail_x1_r0_body.s280.trace PRE_first_tail_x1_r0_body.s280 = true
kernel_rfl bodyJsNative12 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s280.ffi) = true
kernel_rfl bodyLow12 : (PRE_first_tail_x1_r0_body.cws12 ++ PRE_first_tail_x1_r0_body.ws12).all (Nat.ble 9) = true
kernel_rfl bodyCntM12 : countersOkB PRE_first_tail_x1_r0_body.s278 PRE_first_tail_x1_r0_body.s279 = true
kernel_rfl bodyHi12 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s280.ffi).next setupP.E = true
kernel_rfl bodyNhi12 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s280.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge12 : bridgeOf PRE_first_tail_x1_r0_body.s279.ffi = bridgeOf PRE_first_tail_x1_r0_body.s278.ffi
kernel_rfl bodyNN12 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s278.ffi).nnext PRE_first_tail_x1_r0_body.P12.NL = true
kernel_rfl bodyXn12 : Nat.ble (⟨18930, 16016, 2703715, 1485⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s280.ffi).next = true
kernel_rfl bodyLo12 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s280.ffi).next = true
theorem bodyFacts12 : BodySiteFacts PRE_first_tail_x1_r0_body.s278 PRE_first_tail_x1_r0_body.s279 PRE_first_tail_x1_r0_body.s280 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S278 PRE_first_tail_x1_r0_body.S279 PRE_first_tail_x1_r0_body.S280
    PRE_first_tail_x1_r0_body.ws12 PRE_first_tail_x1_r0_body.cws12 PRE_first_tail_x1_r0_body.nr12 PRE_first_tail_x1_r0_body.pl12 PRE_first_tail_x1_r0_body.cl12 2704864 1485 PRE_first_tail_x1_r0_body.kd12 PRE_first_tail_x1_r0_body.kappa12 PRE_first_tail_x1_r0_body.P12
    ⟨18927, 15989, 2703709, 1467⟩ ⟨18930, 16016, 2703715, 1485⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap12
  clean := bodyClean12
  cfix := PRE_first_tail_x1_r0_body.cfix12
  zpl := PRE_first_tail_x1_r0_body.zpl12
  zplnd := PRE_first_tail_x1_r0_body.zplnd12
  zn1 := PRE_first_tail_x1_r0_body.zn112
  zfirst := PRE_first_tail_x1_r0_body.zfirst12
  zscn := PRE_first_tail_x1_r0_body.zscn12
  zsmn := PRE_first_tail_x1_r0_body.zsmn12
  zgrow := PRE_first_tail_x1_r0_body.zgrow12
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab12
  zfresh := PRE_first_tail_x1_r0_body.zfresh12
  zcnd := PRE_first_tail_x1_r0_body.zcnd12
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi12
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt12
  zgP := PRE_first_tail_x1_r0_body.zg12_2665
  zkP := PRE_first_tail_x1_r0_body.zk12_2665
  zmP := PRE_first_tail_x1_r0_body.zm12_2665
  zgC := PRE_first_tail_x1_r0_body.zg12_2673467
  zkC := PRE_first_tail_x1_r0_body.zk12_2673467
  zmC := PRE_first_tail_x1_r0_body.zm12_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw12_2673472
  zwV := PRE_first_tail_x1_r0_body.zw12_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap12
  zclbd := PRE_first_tail_x1_r0_body.zclbd12
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap12 PRE_first_tail_x1_r0_body.stFoot12 PRE_first_tail_x1_r0_body.iso12 PRE_first_tail_x1_r0_body.zwr12
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP12
  csupp := PRE_first_tail_x1_r0_body.csupp12
  cbound := PRE_first_tail_x1_r0_body.cbound12
  zimg := PRE_first_tail_x1_r0_body.zimg12
  zctl := PRE_first_tail_x1_r0_body.zctl12
  zstack := PRE_first_tail_x1_r0_body.zstack12
  zjobs := PRE_first_tail_x1_r0_body.zjobs12
  zstores := PRE_first_tail_x1_r0_body.zstores12
  zroots := PRE_first_tail_x1_r0_body.zroots12
  znC := PRE_first_tail_x1_r0_body.znC12
  ctab := PRE_first_tail_x1_r0_body.ctab12
  zbin := PRE_first_tail_x1_r0_body.zbin12
  cbridge := PRE_first_tail_x1_r0_body.cbridge12
  sbridge := bodyBridge12
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj12
  cshiftR := fun h hNL => bodyCshift12 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN12
  raised := PRE_first_tail_x1_r0_body.raised12
  cbigs := PRE_first_tail_x1_r0_body.cbigs12
  cjcl := PRE_first_tail_x1_r0_body.cjcl12
  xnLe := Nat.le_of_ble_eq_true bodyXn12
  loLe := Nat.le_of_ble_eq_true bodyLo12
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB12
  cntM := bodyCntM12
  hiLe := Nat.le_of_ble_eq_true bodyHi12
  nhiLe := Nat.le_of_ble_eq_true bodyNhi12
  jsHeap := bodyJs12
  jsRoots := bodyJsRoots12
  jsNative := bodyJsNative12
  framesEmpty := bodyFramesEmpty12
  trailOld := by decide
  lowVars := bodyLow12

def bodyQs12 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs12 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr12.map fun r => nth? PRE_first_tail_x1_r0_body.st12.S5.tab r
kernel_rfl bodyResChk12 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs12 bodyQs12) = true
kernel_rfl bodyLq12 : bodyQs12.length = PRE_first_tail_x1_r0_body.cws12.length
kernel_rfl bodyNrLo12 : PRE_first_tail_x1_r0_body.nr12.all (Nat.ble PRE_first_tail_x1_r0_body.S278.tab.length) = true
kernel_rfl bodySub12 : (Oracles.PRE_first_tail_x1_r0_body.map_site12.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost12 : postSubB bodyM PRE_first_tail_x1_r0_body.ws12 PRE_first_tail_x1_r0_body.cws12 bodyQs12 = true
kernel_rfl bodyDrop12 : Nat.ble (15505 + (PRE_first_tail_x1_r0_body.s279.next - PRE_first_tail_x1_r0_body.s280.next)) 16654 = true
kernel_rfl bodyDropH12 : Nat.ble (252 + ((mlxOf PRE_first_tail_x1_r0_body.s279.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s280.ffi).next)) 277 = true
kernel_rfl bodyDropN12 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s279.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s280.ffi).nnext)) 0 = true
kernel_rfl bodyDv12 : bodyΘ.1.take 207 = bodyΘ.1.take 189 ++ PRE_first_tail_x1_r0_body.cws12
kernel_rfl bodyDe12 : bodyΘ.2.take 207 = bodyΘ.2.take 189 ++ PRE_first_tail_x1_r0_body.nr12.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st12.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 189) (bodyΘ.2.take 189)))
kernel_rfl bodyDl12 : (bodyΘ.1.take 189).length = (bodyΘ.2.take 189).length
kernel_rfl bodyDold12 : (bodyΘ.1.take 189).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws12).isNone && !PRE_first_tail_x1_r0_body.ws12.contains v) = true
kernel_rfl bodyDfree12 : (bodyΘ.2.take 207).all (fun e => (PRE_first_tail_x1_r0_body.cws12 ++ PRE_first_tail_x1_r0_body.ws12).all fun w => e.noVar w) = true

theorem bodyStep12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 189⟩ bodyM PRE_first_tail_x1_r0_body.s278 PRE_first_tail_x1_r0_body.S278)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 207⟩ bodyM PRE_first_tail_x1_r0_body.s280 PRE_first_tail_x1_r0_body.S280) (11334 + 1) :=
  bodySite bodyFacts12.cfix bodyFacts12.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st12.S5.tab) (Es := bodyEs12) (qs := bodyQs12)
    (ok := PRE_first_tail_x1_r0_body.st12.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site12 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts12
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site12 r hr) hi (MapOk.sub hm (sub_of_all bodySub12)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk12 r hr) hi hm ho hq)
    bodyLq12 rfl bodyNrLo12 (postSub_sound bodyPost12)
    (Nat.le_of_ble_eq_true bodyDrop12) (by decide) (Nat.le_of_ble_eq_true bodyDropH12) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN12) (by decide)
    bodyDv12 bodyDe12 bodyDl12 bodyDold12 bodyDfree12 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site13 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st13.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site13
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st13.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st13.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s300 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s301 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S300 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws13 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st13.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st13.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso13
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_13
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st13.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot13
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup13
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound13
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace13
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged13
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws13.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st13.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S300.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_13]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen13.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh13
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl13 : Conv.NClean (⟨18984, 16052, 2705957, 1583⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s300.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl13 (PRE_first_tail_x1_r0_body.cncl12 bodyNcl12)

theorem bodyClean13 : Conv.JClean (⟨18984, 16052, 2705957, 1583⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s300 :=
  PRE_first_tail_x1_r0_body.gjcl13 (PRE_first_tail_x1_r0_body.cjcl12 bodyClean12)

kernel_rfl bodyJsLe13 : Nat.ble PRE_first_tail_x1_r0_body.s278.next PRE_first_tail_x1_r0_body.s300.next = true
kernel_rfl bodyJsList13 : (PRE_first_tail_x1_r0_body.gjh13 ++ PRE_first_tail_x1_r0_body.cl13).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s300.next) PRE_first_tail_x1_r0_body.s302) = true
theorem bodyJs13 : JsHeapAbove PRE_first_tail_x1_r0_body.s300.next PRE_first_tail_x1_r0_body.s302 :=
  JsHeapAbove.glueSite bodyJs12 (Nat.le_of_ble_eq_true bodyJsLe13) PRE_first_tail_x1_r0_body.gjk13 PRE_first_tail_x1_r0_body.gjbd13 PRE_first_tail_x1_r0_body.cheap13 PRE_first_tail_x1_r0_body.zclbd13 bodyJsList13

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO280 : PRE_first_tail_x1_r0_body.S280.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S280.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr280 : bridgeOf PRE_first_tail_x1_r0_body.s280.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc280 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s280 PRE_first_tail_x1_r0_body.S280) = fun _ _ => true
kernel_rfl bodyAcc281 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s281 PRE_first_tail_x1_r0_body.S281) = fun _ _ => true
kernel_rfl bodyBr282 : bridgeOf PRE_first_tail_x1_r0_body.s282.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt281 : isHalt PRE_first_tail_x1_r0_body.s281.ctl = false
kernel_rfl bodyTop282 : noRetBlock PRE_first_tail_x1_r0_body.s282 = true
kernel_rfl bodyCnt280 : countersOkB PRE_first_tail_x1_r0_body.s280 PRE_first_tail_x1_r0_body.s282 = true
kernel_rfl bodyO282 : PRE_first_tail_x1_r0_body.S282.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S282.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr283 : bridgeOf PRE_first_tail_x1_r0_body.s283.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt282 : countersOkB PRE_first_tail_x1_r0_body.s282 PRE_first_tail_x1_r0_body.s283 = true
kernel_rfl bodyO283 : PRE_first_tail_x1_r0_body.S283.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S283.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc283 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s283 PRE_first_tail_x1_r0_body.S283) = fun _ _ => true
kernel_rfl bodyAcc287 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s287 PRE_first_tail_x1_r0_body.S287) = fun _ _ => true
kernel_rfl bodyBr288 : bridgeOf PRE_first_tail_x1_r0_body.s288.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt287 : isHalt PRE_first_tail_x1_r0_body.s287.ctl = false
kernel_rfl bodyTop288 : noRetBlock PRE_first_tail_x1_r0_body.s288 = true
kernel_rfl bodyCnt283 : countersOkB PRE_first_tail_x1_r0_body.s283 PRE_first_tail_x1_r0_body.s288 = true
kernel_rfl bodyO288 : PRE_first_tail_x1_r0_body.S288.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S288.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr289 : bridgeOf PRE_first_tail_x1_r0_body.s289.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt288 : countersOkB PRE_first_tail_x1_r0_body.s288 PRE_first_tail_x1_r0_body.s289 = true
kernel_rfl bodyO289 : PRE_first_tail_x1_r0_body.S289.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S289.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc289 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s289 PRE_first_tail_x1_r0_body.S289) = fun _ _ => true
kernel_rfl bodyAcc290 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s290 PRE_first_tail_x1_r0_body.S290) = fun _ _ => true
kernel_rfl bodyBr291 : bridgeOf PRE_first_tail_x1_r0_body.s291.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt290 : isHalt PRE_first_tail_x1_r0_body.s290.ctl = false
kernel_rfl bodyTop291 : noRetBlock PRE_first_tail_x1_r0_body.s291 = true
kernel_rfl bodyCnt289 : countersOkB PRE_first_tail_x1_r0_body.s289 PRE_first_tail_x1_r0_body.s291 = true
kernel_rfl bodyO291 : PRE_first_tail_x1_r0_body.S291.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S291.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr292 : bridgeOf PRE_first_tail_x1_r0_body.s292.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt291 : countersOkB PRE_first_tail_x1_r0_body.s291 PRE_first_tail_x1_r0_body.s292 = true
kernel_rfl bodyO292 : PRE_first_tail_x1_r0_body.S292.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S292.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc292 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s292 PRE_first_tail_x1_r0_body.S292) = fun _ _ => true
kernel_rfl bodyAcc293 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s293 PRE_first_tail_x1_r0_body.S293) = fun _ _ => true
kernel_rfl bodyBr294 : bridgeOf PRE_first_tail_x1_r0_body.s294.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt293 : isHalt PRE_first_tail_x1_r0_body.s293.ctl = false
kernel_rfl bodyTop294 : noRetBlock PRE_first_tail_x1_r0_body.s294 = true
kernel_rfl bodyCnt292 : countersOkB PRE_first_tail_x1_r0_body.s292 PRE_first_tail_x1_r0_body.s294 = true
kernel_rfl bodyO294 : PRE_first_tail_x1_r0_body.S294.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S294.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr295 : bridgeOf PRE_first_tail_x1_r0_body.s295.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt294 : countersOkB PRE_first_tail_x1_r0_body.s294 PRE_first_tail_x1_r0_body.s295 = true
kernel_rfl bodyO295 : PRE_first_tail_x1_r0_body.S295.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S295.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc295 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s295 PRE_first_tail_x1_r0_body.S295) = fun _ _ => true
kernel_rfl bodyAcc296 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s296 PRE_first_tail_x1_r0_body.S296) = fun _ _ => true
kernel_rfl bodyBr297 : bridgeOf PRE_first_tail_x1_r0_body.s297.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt296 : isHalt PRE_first_tail_x1_r0_body.s296.ctl = false
kernel_rfl bodyTop297 : noRetBlock PRE_first_tail_x1_r0_body.s297 = true
kernel_rfl bodyCnt295 : countersOkB PRE_first_tail_x1_r0_body.s295 PRE_first_tail_x1_r0_body.s297 = true
kernel_rfl bodyO297 : PRE_first_tail_x1_r0_body.S297.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S297.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr298 : bridgeOf PRE_first_tail_x1_r0_body.s298.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt297 : countersOkB PRE_first_tail_x1_r0_body.s297 PRE_first_tail_x1_r0_body.s298 = true
kernel_rfl bodyO298 : PRE_first_tail_x1_r0_body.S298.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S298.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc298 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s298 PRE_first_tail_x1_r0_body.S298) = fun _ _ => true
kernel_rfl bodyAcc299 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s299 PRE_first_tail_x1_r0_body.S299) = fun _ _ => true
kernel_rfl bodyBr300 : bridgeOf PRE_first_tail_x1_r0_body.s300.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt299 : isHalt PRE_first_tail_x1_r0_body.s299.ctl = false
kernel_rfl bodyTop300 : noRetBlock PRE_first_tail_x1_r0_body.s300 = true
kernel_rfl bodyCnt298 : countersOkB PRE_first_tail_x1_r0_body.s298 PRE_first_tail_x1_r0_body.s300 = true

theorem bodyGlue13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 207⟩ bodyM PRE_first_tail_x1_r0_body.s280 PRE_first_tail_x1_r0_body.S280)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 207⟩ bodyM PRE_first_tail_x1_r0_body.s300 PRE_first_tail_x1_r0_body.S300) 22362 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc280 PRE_first_tail_x1_r0_body.bodyRunSeg74 bodyAcc281 bodyHalt281 PRE_first_tail_x1_r0_body.bodyStepA75 bodyTop282 (fun _ hm => bodyO280 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr280).trans bodyInactive0) (bodyBr282.trans bodyBr280.symm) bodyCnt280 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x1_r0_body.sizeA75 PRE_first_tail_x1_r0_body.sizeArgsA75 PRE_first_tail_x1_r0_body.sizeSymA75 PRE_first_tail_x1_r0_body.sizeMlxA75 PRE_first_tail_x1_r0_body.sizePayA75 PRE_first_tail_x1_r0_body.sizeTaA75 PRE_first_tail_x1_r0_body.sizeDecA75 PRE_first_tail_x1_r0_body.sizePreA75 PRE_first_tail_x1_r0_body.bodyPatchB75 (fun _ hm => bodyO282 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr282).trans bodyInactive0) (bodyBr283.trans bodyBr282.symm) bodyCnt282 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc283 PRE_first_tail_x1_r0_body.bodyRunSeg75 bodyAcc287 bodyHalt287 PRE_first_tail_x1_r0_body.bodyStepA76 bodyTop288 (fun _ hm => bodyO283 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr283).trans bodyInactive0) (bodyBr288.trans bodyBr283.symm) bodyCnt283 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x1_r0_body.sizeA76 PRE_first_tail_x1_r0_body.sizeArgsA76 PRE_first_tail_x1_r0_body.sizeSymA76 PRE_first_tail_x1_r0_body.sizeMlxA76 PRE_first_tail_x1_r0_body.sizePayA76 PRE_first_tail_x1_r0_body.sizeTaA76 PRE_first_tail_x1_r0_body.sizeDecA76 PRE_first_tail_x1_r0_body.sizePreA76 PRE_first_tail_x1_r0_body.bodyPatchB76 (fun _ hm => bodyO288 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr288).trans bodyInactive0) (bodyBr289.trans bodyBr288.symm) bodyCnt288 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc289 PRE_first_tail_x1_r0_body.bodyRunSeg76 bodyAcc290 bodyHalt290 PRE_first_tail_x1_r0_body.bodyStepA77 bodyTop291 (fun _ hm => bodyO289 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr289).trans bodyInactive0) (bodyBr291.trans bodyBr289.symm) bodyCnt289 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x1_r0_body.sizeA77 PRE_first_tail_x1_r0_body.sizeArgsA77 PRE_first_tail_x1_r0_body.sizeSymA77 PRE_first_tail_x1_r0_body.sizeMlxA77 PRE_first_tail_x1_r0_body.sizePayA77 PRE_first_tail_x1_r0_body.sizeTaA77 PRE_first_tail_x1_r0_body.sizeDecA77 PRE_first_tail_x1_r0_body.sizePreA77 PRE_first_tail_x1_r0_body.bodyPatchB77 (fun _ hm => bodyO291 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr291).trans bodyInactive0) (bodyBr292.trans bodyBr291.symm) bodyCnt291 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc292 PRE_first_tail_x1_r0_body.bodyRunSeg77 bodyAcc293 bodyHalt293 PRE_first_tail_x1_r0_body.bodyStepA78 bodyTop294 (fun _ hm => bodyO292 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr292).trans bodyInactive0) (bodyBr294.trans bodyBr292.symm) bodyCnt292 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x1_r0_body.sizeA78 PRE_first_tail_x1_r0_body.sizeArgsA78 PRE_first_tail_x1_r0_body.sizeSymA78 PRE_first_tail_x1_r0_body.sizeMlxA78 PRE_first_tail_x1_r0_body.sizePayA78 PRE_first_tail_x1_r0_body.sizeTaA78 PRE_first_tail_x1_r0_body.sizeDecA78 PRE_first_tail_x1_r0_body.sizePreA78 PRE_first_tail_x1_r0_body.bodyPatchB78 (fun _ hm => bodyO294 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr294).trans bodyInactive0) (bodyBr295.trans bodyBr294.symm) bodyCnt294 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc295 PRE_first_tail_x1_r0_body.bodyRunSeg78 bodyAcc296 bodyHalt296 PRE_first_tail_x1_r0_body.bodyStepA79 bodyTop297 (fun _ hm => bodyO295 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr295).trans bodyInactive0) (bodyBr297.trans bodyBr295.symm) bodyCnt295 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x1_r0_body.sizeA79 PRE_first_tail_x1_r0_body.sizeArgsA79 PRE_first_tail_x1_r0_body.sizeSymA79 PRE_first_tail_x1_r0_body.sizeMlxA79 PRE_first_tail_x1_r0_body.sizePayA79 PRE_first_tail_x1_r0_body.sizeTaA79 PRE_first_tail_x1_r0_body.sizeDecA79 PRE_first_tail_x1_r0_body.sizePreA79 PRE_first_tail_x1_r0_body.bodyPatchB79 (fun _ hm => bodyO297 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr297).trans bodyInactive0) (bodyBr298.trans bodyBr297.symm) bodyCnt297 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc298 PRE_first_tail_x1_r0_body.bodyRunSeg79 bodyAcc299 bodyHalt299 PRE_first_tail_x1_r0_body.bodyStepA80 bodyTop300 (fun _ hm => bodyO298 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr298).trans bodyInactive0) (bodyBr300.trans bodyBr298.symm) bodyCnt298 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift13 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S300.tab.length PRE_first_tail_x1_r0_body.s300.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P13.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P13 1601 PRE_first_tail_x1_r0_body.kappa13 PRE_first_tail_x1_r0_body.s302.ffi PRE_first_tail_x1_r0_body.s301.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_13
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_13
  have hcl : SSt (· < 1601) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s302.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S300.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_13] <;> decide) PRE_first_tail_x1_r0_body.cnodesK13 PRE_first_tail_x1_r0_body.cobjsK13
      PRE_first_tail_x1_r0_body.citemsK13 PRE_first_tail_x1_r0_body.cbd13 PRE_first_tail_x1_r0_body.csst13
  exact PRE_first_tail_x1_r0_body.cshift13 bodyNcl13 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_13] at this; exact this)


kernel_rfl bodyFramesEmpty13 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s301 a).isEmpty) = true
kernel_rfl bodyJsRoots13 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s300.next) PRE_first_tail_x1_r0_body.s302.trace PRE_first_tail_x1_r0_body.s302 = true
kernel_rfl bodyJsNative13 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s302.ffi) = true
kernel_rfl bodyLow13 : (PRE_first_tail_x1_r0_body.cws13 ++ PRE_first_tail_x1_r0_body.ws13).all (Nat.ble 9) = true
kernel_rfl bodyCntM13 : countersOkB PRE_first_tail_x1_r0_body.s300 PRE_first_tail_x1_r0_body.s301 = true
kernel_rfl bodyHi13 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s302.ffi).next setupP.E = true
kernel_rfl bodyNhi13 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s302.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge13 : bridgeOf PRE_first_tail_x1_r0_body.s301.ffi = bridgeOf PRE_first_tail_x1_r0_body.s300.ffi
kernel_rfl bodyNN13 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s300.ffi).nnext PRE_first_tail_x1_r0_body.P13.NL = true
kernel_rfl bodyXn13 : Nat.ble (⟨18987, 16079, 2705963, 1601⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s302.ffi).next = true
kernel_rfl bodyLo13 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s302.ffi).next = true
theorem bodyFacts13 : BodySiteFacts PRE_first_tail_x1_r0_body.s300 PRE_first_tail_x1_r0_body.s301 PRE_first_tail_x1_r0_body.s302 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S300 PRE_first_tail_x1_r0_body.S301 PRE_first_tail_x1_r0_body.S302
    PRE_first_tail_x1_r0_body.ws13 PRE_first_tail_x1_r0_body.cws13 PRE_first_tail_x1_r0_body.nr13 PRE_first_tail_x1_r0_body.pl13 PRE_first_tail_x1_r0_body.cl13 2707112 1601 PRE_first_tail_x1_r0_body.kd13 PRE_first_tail_x1_r0_body.kappa13 PRE_first_tail_x1_r0_body.P13
    ⟨18984, 16052, 2705957, 1583⟩ ⟨18987, 16079, 2705963, 1601⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap13
  clean := bodyClean13
  cfix := PRE_first_tail_x1_r0_body.cfix13
  zpl := PRE_first_tail_x1_r0_body.zpl13
  zplnd := PRE_first_tail_x1_r0_body.zplnd13
  zn1 := PRE_first_tail_x1_r0_body.zn113
  zfirst := PRE_first_tail_x1_r0_body.zfirst13
  zscn := PRE_first_tail_x1_r0_body.zscn13
  zsmn := PRE_first_tail_x1_r0_body.zsmn13
  zgrow := PRE_first_tail_x1_r0_body.zgrow13
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab13
  zfresh := PRE_first_tail_x1_r0_body.zfresh13
  zcnd := PRE_first_tail_x1_r0_body.zcnd13
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi13
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt13
  zgP := PRE_first_tail_x1_r0_body.zg13_2665
  zkP := PRE_first_tail_x1_r0_body.zk13_2665
  zmP := PRE_first_tail_x1_r0_body.zm13_2665
  zgC := PRE_first_tail_x1_r0_body.zg13_2673467
  zkC := PRE_first_tail_x1_r0_body.zk13_2673467
  zmC := PRE_first_tail_x1_r0_body.zm13_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw13_2673472
  zwV := PRE_first_tail_x1_r0_body.zw13_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap13
  zclbd := PRE_first_tail_x1_r0_body.zclbd13
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap13 PRE_first_tail_x1_r0_body.stFoot13 PRE_first_tail_x1_r0_body.iso13 PRE_first_tail_x1_r0_body.zwr13
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP13
  csupp := PRE_first_tail_x1_r0_body.csupp13
  cbound := PRE_first_tail_x1_r0_body.cbound13
  zimg := PRE_first_tail_x1_r0_body.zimg13
  zctl := PRE_first_tail_x1_r0_body.zctl13
  zstack := PRE_first_tail_x1_r0_body.zstack13
  zjobs := PRE_first_tail_x1_r0_body.zjobs13
  zstores := PRE_first_tail_x1_r0_body.zstores13
  zroots := PRE_first_tail_x1_r0_body.zroots13
  znC := PRE_first_tail_x1_r0_body.znC13
  ctab := PRE_first_tail_x1_r0_body.ctab13
  zbin := PRE_first_tail_x1_r0_body.zbin13
  cbridge := PRE_first_tail_x1_r0_body.cbridge13
  sbridge := bodyBridge13
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj13
  cshiftR := fun h hNL => bodyCshift13 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN13
  raised := PRE_first_tail_x1_r0_body.raised13
  cbigs := PRE_first_tail_x1_r0_body.cbigs13
  cjcl := PRE_first_tail_x1_r0_body.cjcl13
  xnLe := Nat.le_of_ble_eq_true bodyXn13
  loLe := Nat.le_of_ble_eq_true bodyLo13
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB13
  cntM := bodyCntM13
  hiLe := Nat.le_of_ble_eq_true bodyHi13
  nhiLe := Nat.le_of_ble_eq_true bodyNhi13
  jsHeap := bodyJs13
  jsRoots := bodyJsRoots13
  jsNative := bodyJsNative13
  framesEmpty := bodyFramesEmpty13
  trailOld := by decide
  lowVars := bodyLow13

def bodyQs13 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs13 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr13.map fun r => nth? PRE_first_tail_x1_r0_body.st13.S5.tab r
kernel_rfl bodyResChk13 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs13 bodyQs13) = true
kernel_rfl bodyLq13 : bodyQs13.length = PRE_first_tail_x1_r0_body.cws13.length
kernel_rfl bodyNrLo13 : PRE_first_tail_x1_r0_body.nr13.all (Nat.ble PRE_first_tail_x1_r0_body.S300.tab.length) = true
kernel_rfl bodySub13 : (Oracles.PRE_first_tail_x1_r0_body.map_site13.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost13 : postSubB bodyM PRE_first_tail_x1_r0_body.ws13 PRE_first_tail_x1_r0_body.cws13 bodyQs13 = true
kernel_rfl bodyDrop13 : Nat.ble (16654 + (PRE_first_tail_x1_r0_body.s301.next - PRE_first_tail_x1_r0_body.s302.next)) 17803 = true
kernel_rfl bodyDropH13 : Nat.ble (277 + ((mlxOf PRE_first_tail_x1_r0_body.s301.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s302.ffi).next)) 302 = true
kernel_rfl bodyDropN13 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s301.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s302.ffi).nnext)) 0 = true
kernel_rfl bodyDv13 : bodyΘ.1.take 225 = bodyΘ.1.take 207 ++ PRE_first_tail_x1_r0_body.cws13
kernel_rfl bodyDe13 : bodyΘ.2.take 225 = bodyΘ.2.take 207 ++ PRE_first_tail_x1_r0_body.nr13.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st13.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 207) (bodyΘ.2.take 207)))
kernel_rfl bodyDl13 : (bodyΘ.1.take 207).length = (bodyΘ.2.take 207).length
kernel_rfl bodyDold13 : (bodyΘ.1.take 207).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws13).isNone && !PRE_first_tail_x1_r0_body.ws13.contains v) = true
kernel_rfl bodyDfree13 : (bodyΘ.2.take 225).all (fun e => (PRE_first_tail_x1_r0_body.cws13 ++ PRE_first_tail_x1_r0_body.ws13).all fun w => e.noVar w) = true

theorem bodyStep13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 207⟩ bodyM PRE_first_tail_x1_r0_body.s300 PRE_first_tail_x1_r0_body.S300)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 225⟩ bodyM PRE_first_tail_x1_r0_body.s302 PRE_first_tail_x1_r0_body.S302) (11334 + 1) :=
  bodySite bodyFacts13.cfix bodyFacts13.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st13.S5.tab) (Es := bodyEs13) (qs := bodyQs13)
    (ok := PRE_first_tail_x1_r0_body.st13.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site13 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts13
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site13 r hr) hi (MapOk.sub hm (sub_of_all bodySub13)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk13 r hr) hi hm ho hq)
    bodyLq13 rfl bodyNrLo13 (postSub_sound bodyPost13)
    (Nat.le_of_ble_eq_true bodyDrop13) (by decide) (Nat.le_of_ble_eq_true bodyDropH13) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN13) (by decide)
    bodyDv13 bodyDe13 bodyDl13 bodyDold13 bodyDfree13 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site14 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site14 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st14.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site14
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st14.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st14.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s322 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s323 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S322 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws14 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st14.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st14.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso14
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_14
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st14.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot14
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup14
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound14
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace14
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged14
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws14.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st14.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S322.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_14]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen14.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh14
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl14 : Conv.NClean (⟨19041, 16115, 2708209, 1699⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s322.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl14 (PRE_first_tail_x1_r0_body.cncl13 bodyNcl13)

theorem bodyClean14 : Conv.JClean (⟨19041, 16115, 2708209, 1699⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s322 :=
  PRE_first_tail_x1_r0_body.gjcl14 (PRE_first_tail_x1_r0_body.cjcl13 bodyClean13)

kernel_rfl bodyJsLe14 : Nat.ble PRE_first_tail_x1_r0_body.s300.next PRE_first_tail_x1_r0_body.s322.next = true
kernel_rfl bodyJsList14 : (PRE_first_tail_x1_r0_body.gjh14 ++ PRE_first_tail_x1_r0_body.cl14).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s322.next) PRE_first_tail_x1_r0_body.s324) = true
theorem bodyJs14 : JsHeapAbove PRE_first_tail_x1_r0_body.s322.next PRE_first_tail_x1_r0_body.s324 :=
  JsHeapAbove.glueSite bodyJs13 (Nat.le_of_ble_eq_true bodyJsLe14) PRE_first_tail_x1_r0_body.gjk14 PRE_first_tail_x1_r0_body.gjbd14 PRE_first_tail_x1_r0_body.cheap14 PRE_first_tail_x1_r0_body.zclbd14 bodyJsList14

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO302 : PRE_first_tail_x1_r0_body.S302.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S302.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr302 : bridgeOf PRE_first_tail_x1_r0_body.s302.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc302 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s302 PRE_first_tail_x1_r0_body.S302) = fun _ _ => true
kernel_rfl bodyAcc303 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s303 PRE_first_tail_x1_r0_body.S303) = fun _ _ => true
kernel_rfl bodyBr304 : bridgeOf PRE_first_tail_x1_r0_body.s304.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt303 : isHalt PRE_first_tail_x1_r0_body.s303.ctl = false
kernel_rfl bodyTop304 : noRetBlock PRE_first_tail_x1_r0_body.s304 = true
kernel_rfl bodyCnt302 : countersOkB PRE_first_tail_x1_r0_body.s302 PRE_first_tail_x1_r0_body.s304 = true
kernel_rfl bodyO304 : PRE_first_tail_x1_r0_body.S304.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S304.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr305 : bridgeOf PRE_first_tail_x1_r0_body.s305.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt304 : countersOkB PRE_first_tail_x1_r0_body.s304 PRE_first_tail_x1_r0_body.s305 = true
kernel_rfl bodyO305 : PRE_first_tail_x1_r0_body.S305.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S305.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc305 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s305 PRE_first_tail_x1_r0_body.S305) = fun _ _ => true
kernel_rfl bodyAcc309 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s309 PRE_first_tail_x1_r0_body.S309) = fun _ _ => true
kernel_rfl bodyBr310 : bridgeOf PRE_first_tail_x1_r0_body.s310.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt309 : isHalt PRE_first_tail_x1_r0_body.s309.ctl = false
kernel_rfl bodyTop310 : noRetBlock PRE_first_tail_x1_r0_body.s310 = true
kernel_rfl bodyCnt305 : countersOkB PRE_first_tail_x1_r0_body.s305 PRE_first_tail_x1_r0_body.s310 = true
kernel_rfl bodyO310 : PRE_first_tail_x1_r0_body.S310.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S310.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr311 : bridgeOf PRE_first_tail_x1_r0_body.s311.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt310 : countersOkB PRE_first_tail_x1_r0_body.s310 PRE_first_tail_x1_r0_body.s311 = true
kernel_rfl bodyO311 : PRE_first_tail_x1_r0_body.S311.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S311.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc311 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s311 PRE_first_tail_x1_r0_body.S311) = fun _ _ => true
kernel_rfl bodyAcc312 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s312 PRE_first_tail_x1_r0_body.S312) = fun _ _ => true
kernel_rfl bodyBr313 : bridgeOf PRE_first_tail_x1_r0_body.s313.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt312 : isHalt PRE_first_tail_x1_r0_body.s312.ctl = false
kernel_rfl bodyTop313 : noRetBlock PRE_first_tail_x1_r0_body.s313 = true
kernel_rfl bodyCnt311 : countersOkB PRE_first_tail_x1_r0_body.s311 PRE_first_tail_x1_r0_body.s313 = true
kernel_rfl bodyO313 : PRE_first_tail_x1_r0_body.S313.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S313.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr314 : bridgeOf PRE_first_tail_x1_r0_body.s314.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt313 : countersOkB PRE_first_tail_x1_r0_body.s313 PRE_first_tail_x1_r0_body.s314 = true
kernel_rfl bodyO314 : PRE_first_tail_x1_r0_body.S314.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S314.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc314 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s314 PRE_first_tail_x1_r0_body.S314) = fun _ _ => true
kernel_rfl bodyAcc315 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s315 PRE_first_tail_x1_r0_body.S315) = fun _ _ => true
kernel_rfl bodyBr316 : bridgeOf PRE_first_tail_x1_r0_body.s316.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt315 : isHalt PRE_first_tail_x1_r0_body.s315.ctl = false
kernel_rfl bodyTop316 : noRetBlock PRE_first_tail_x1_r0_body.s316 = true
kernel_rfl bodyCnt314 : countersOkB PRE_first_tail_x1_r0_body.s314 PRE_first_tail_x1_r0_body.s316 = true
kernel_rfl bodyO316 : PRE_first_tail_x1_r0_body.S316.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S316.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr317 : bridgeOf PRE_first_tail_x1_r0_body.s317.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt316 : countersOkB PRE_first_tail_x1_r0_body.s316 PRE_first_tail_x1_r0_body.s317 = true
kernel_rfl bodyO317 : PRE_first_tail_x1_r0_body.S317.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S317.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc317 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s317 PRE_first_tail_x1_r0_body.S317) = fun _ _ => true
kernel_rfl bodyAcc318 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s318 PRE_first_tail_x1_r0_body.S318) = fun _ _ => true
kernel_rfl bodyBr319 : bridgeOf PRE_first_tail_x1_r0_body.s319.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt318 : isHalt PRE_first_tail_x1_r0_body.s318.ctl = false
kernel_rfl bodyTop319 : noRetBlock PRE_first_tail_x1_r0_body.s319 = true
kernel_rfl bodyCnt317 : countersOkB PRE_first_tail_x1_r0_body.s317 PRE_first_tail_x1_r0_body.s319 = true
kernel_rfl bodyO319 : PRE_first_tail_x1_r0_body.S319.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S319.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr320 : bridgeOf PRE_first_tail_x1_r0_body.s320.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt319 : countersOkB PRE_first_tail_x1_r0_body.s319 PRE_first_tail_x1_r0_body.s320 = true
kernel_rfl bodyO320 : PRE_first_tail_x1_r0_body.S320.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S320.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc320 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s320 PRE_first_tail_x1_r0_body.S320) = fun _ _ => true
kernel_rfl bodyAcc321 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s321 PRE_first_tail_x1_r0_body.S321) = fun _ _ => true
kernel_rfl bodyBr322 : bridgeOf PRE_first_tail_x1_r0_body.s322.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt321 : isHalt PRE_first_tail_x1_r0_body.s321.ctl = false
kernel_rfl bodyTop322 : noRetBlock PRE_first_tail_x1_r0_body.s322 = true
kernel_rfl bodyCnt320 : countersOkB PRE_first_tail_x1_r0_body.s320 PRE_first_tail_x1_r0_body.s322 = true

theorem bodyGlue14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 225⟩ bodyM PRE_first_tail_x1_r0_body.s302 PRE_first_tail_x1_r0_body.S302)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 225⟩ bodyM PRE_first_tail_x1_r0_body.s322 PRE_first_tail_x1_r0_body.S322) 22397 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc302 PRE_first_tail_x1_r0_body.bodyRunSeg80 bodyAcc303 bodyHalt303 PRE_first_tail_x1_r0_body.bodyStepA81 bodyTop304 (fun _ hm => bodyO302 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr302).trans bodyInactive0) (bodyBr304.trans bodyBr302.symm) bodyCnt302 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x1_r0_body.sizeA81 PRE_first_tail_x1_r0_body.sizeArgsA81 PRE_first_tail_x1_r0_body.sizeSymA81 PRE_first_tail_x1_r0_body.sizeMlxA81 PRE_first_tail_x1_r0_body.sizePayA81 PRE_first_tail_x1_r0_body.sizeTaA81 PRE_first_tail_x1_r0_body.sizeDecA81 PRE_first_tail_x1_r0_body.sizePreA81 PRE_first_tail_x1_r0_body.bodyPatchB81 (fun _ hm => bodyO304 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr304).trans bodyInactive0) (bodyBr305.trans bodyBr304.symm) bodyCnt304 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc305 PRE_first_tail_x1_r0_body.bodyRunSeg81 bodyAcc309 bodyHalt309 PRE_first_tail_x1_r0_body.bodyStepA82 bodyTop310 (fun _ hm => bodyO305 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr305).trans bodyInactive0) (bodyBr310.trans bodyBr305.symm) bodyCnt305 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x1_r0_body.sizeA82 PRE_first_tail_x1_r0_body.sizeArgsA82 PRE_first_tail_x1_r0_body.sizeSymA82 PRE_first_tail_x1_r0_body.sizeMlxA82 PRE_first_tail_x1_r0_body.sizePayA82 PRE_first_tail_x1_r0_body.sizeTaA82 PRE_first_tail_x1_r0_body.sizeDecA82 PRE_first_tail_x1_r0_body.sizePreA82 PRE_first_tail_x1_r0_body.bodyPatchB82 (fun _ hm => bodyO310 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr310).trans bodyInactive0) (bodyBr311.trans bodyBr310.symm) bodyCnt310 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc311 PRE_first_tail_x1_r0_body.bodyRunSeg82 bodyAcc312 bodyHalt312 PRE_first_tail_x1_r0_body.bodyStepA83 bodyTop313 (fun _ hm => bodyO311 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr311).trans bodyInactive0) (bodyBr313.trans bodyBr311.symm) bodyCnt311 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x1_r0_body.sizeA83 PRE_first_tail_x1_r0_body.sizeArgsA83 PRE_first_tail_x1_r0_body.sizeSymA83 PRE_first_tail_x1_r0_body.sizeMlxA83 PRE_first_tail_x1_r0_body.sizePayA83 PRE_first_tail_x1_r0_body.sizeTaA83 PRE_first_tail_x1_r0_body.sizeDecA83 PRE_first_tail_x1_r0_body.sizePreA83 PRE_first_tail_x1_r0_body.bodyPatchB83 (fun _ hm => bodyO313 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr313).trans bodyInactive0) (bodyBr314.trans bodyBr313.symm) bodyCnt313 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc314 PRE_first_tail_x1_r0_body.bodyRunSeg83 bodyAcc315 bodyHalt315 PRE_first_tail_x1_r0_body.bodyStepA84 bodyTop316 (fun _ hm => bodyO314 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr314).trans bodyInactive0) (bodyBr316.trans bodyBr314.symm) bodyCnt314 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x1_r0_body.sizeA84 PRE_first_tail_x1_r0_body.sizeArgsA84 PRE_first_tail_x1_r0_body.sizeSymA84 PRE_first_tail_x1_r0_body.sizeMlxA84 PRE_first_tail_x1_r0_body.sizePayA84 PRE_first_tail_x1_r0_body.sizeTaA84 PRE_first_tail_x1_r0_body.sizeDecA84 PRE_first_tail_x1_r0_body.sizePreA84 PRE_first_tail_x1_r0_body.bodyPatchB84 (fun _ hm => bodyO316 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr316).trans bodyInactive0) (bodyBr317.trans bodyBr316.symm) bodyCnt316 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc317 PRE_first_tail_x1_r0_body.bodyRunSeg84 bodyAcc318 bodyHalt318 PRE_first_tail_x1_r0_body.bodyStepA85 bodyTop319 (fun _ hm => bodyO317 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr317).trans bodyInactive0) (bodyBr319.trans bodyBr317.symm) bodyCnt317 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x1_r0_body.sizeA85 PRE_first_tail_x1_r0_body.sizeArgsA85 PRE_first_tail_x1_r0_body.sizeSymA85 PRE_first_tail_x1_r0_body.sizeMlxA85 PRE_first_tail_x1_r0_body.sizePayA85 PRE_first_tail_x1_r0_body.sizeTaA85 PRE_first_tail_x1_r0_body.sizeDecA85 PRE_first_tail_x1_r0_body.sizePreA85 PRE_first_tail_x1_r0_body.bodyPatchB85 (fun _ hm => bodyO319 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr319).trans bodyInactive0) (bodyBr320.trans bodyBr319.symm) bodyCnt319 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc320 PRE_first_tail_x1_r0_body.bodyRunSeg85 bodyAcc321 bodyHalt321 PRE_first_tail_x1_r0_body.bodyStepA86 bodyTop322 (fun _ hm => bodyO320 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr320).trans bodyInactive0) (bodyBr322.trans bodyBr320.symm) bodyCnt320 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift14 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S322.tab.length PRE_first_tail_x1_r0_body.s322.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P14.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P14 1717 PRE_first_tail_x1_r0_body.kappa14 PRE_first_tail_x1_r0_body.s324.ffi PRE_first_tail_x1_r0_body.s323.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_14
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_14
  have hcl : SSt (· < 1717) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s324.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S322.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_14] <;> decide) PRE_first_tail_x1_r0_body.cnodesK14 PRE_first_tail_x1_r0_body.cobjsK14
      PRE_first_tail_x1_r0_body.citemsK14 PRE_first_tail_x1_r0_body.cbd14 PRE_first_tail_x1_r0_body.csst14
  exact PRE_first_tail_x1_r0_body.cshift14 bodyNcl14 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_14] at this; exact this)


kernel_rfl bodyFramesEmpty14 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s323 a).isEmpty) = true
kernel_rfl bodyJsRoots14 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s322.next) PRE_first_tail_x1_r0_body.s324.trace PRE_first_tail_x1_r0_body.s324 = true
kernel_rfl bodyJsNative14 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s324.ffi) = true
kernel_rfl bodyLow14 : (PRE_first_tail_x1_r0_body.cws14 ++ PRE_first_tail_x1_r0_body.ws14).all (Nat.ble 9) = true
kernel_rfl bodyCntM14 : countersOkB PRE_first_tail_x1_r0_body.s322 PRE_first_tail_x1_r0_body.s323 = true
kernel_rfl bodyHi14 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s324.ffi).next setupP.E = true
kernel_rfl bodyNhi14 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s324.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge14 : bridgeOf PRE_first_tail_x1_r0_body.s323.ffi = bridgeOf PRE_first_tail_x1_r0_body.s322.ffi
kernel_rfl bodyNN14 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s322.ffi).nnext PRE_first_tail_x1_r0_body.P14.NL = true
kernel_rfl bodyXn14 : Nat.ble (⟨19044, 16142, 2708215, 1717⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s324.ffi).next = true
kernel_rfl bodyLo14 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s324.ffi).next = true
theorem bodyFacts14 : BodySiteFacts PRE_first_tail_x1_r0_body.s322 PRE_first_tail_x1_r0_body.s323 PRE_first_tail_x1_r0_body.s324 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S322 PRE_first_tail_x1_r0_body.S323 PRE_first_tail_x1_r0_body.S324
    PRE_first_tail_x1_r0_body.ws14 PRE_first_tail_x1_r0_body.cws14 PRE_first_tail_x1_r0_body.nr14 PRE_first_tail_x1_r0_body.pl14 PRE_first_tail_x1_r0_body.cl14 2709364 1717 PRE_first_tail_x1_r0_body.kd14 PRE_first_tail_x1_r0_body.kappa14 PRE_first_tail_x1_r0_body.P14
    ⟨19041, 16115, 2708209, 1699⟩ ⟨19044, 16142, 2708215, 1717⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap14
  clean := bodyClean14
  cfix := PRE_first_tail_x1_r0_body.cfix14
  zpl := PRE_first_tail_x1_r0_body.zpl14
  zplnd := PRE_first_tail_x1_r0_body.zplnd14
  zn1 := PRE_first_tail_x1_r0_body.zn114
  zfirst := PRE_first_tail_x1_r0_body.zfirst14
  zscn := PRE_first_tail_x1_r0_body.zscn14
  zsmn := PRE_first_tail_x1_r0_body.zsmn14
  zgrow := PRE_first_tail_x1_r0_body.zgrow14
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab14
  zfresh := PRE_first_tail_x1_r0_body.zfresh14
  zcnd := PRE_first_tail_x1_r0_body.zcnd14
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi14
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt14
  zgP := PRE_first_tail_x1_r0_body.zg14_2665
  zkP := PRE_first_tail_x1_r0_body.zk14_2665
  zmP := PRE_first_tail_x1_r0_body.zm14_2665
  zgC := PRE_first_tail_x1_r0_body.zg14_2673467
  zkC := PRE_first_tail_x1_r0_body.zk14_2673467
  zmC := PRE_first_tail_x1_r0_body.zm14_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw14_2673472
  zwV := PRE_first_tail_x1_r0_body.zw14_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap14
  zclbd := PRE_first_tail_x1_r0_body.zclbd14
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap14 PRE_first_tail_x1_r0_body.stFoot14 PRE_first_tail_x1_r0_body.iso14 PRE_first_tail_x1_r0_body.zwr14
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP14
  csupp := PRE_first_tail_x1_r0_body.csupp14
  cbound := PRE_first_tail_x1_r0_body.cbound14
  zimg := PRE_first_tail_x1_r0_body.zimg14
  zctl := PRE_first_tail_x1_r0_body.zctl14
  zstack := PRE_first_tail_x1_r0_body.zstack14
  zjobs := PRE_first_tail_x1_r0_body.zjobs14
  zstores := PRE_first_tail_x1_r0_body.zstores14
  zroots := PRE_first_tail_x1_r0_body.zroots14
  znC := PRE_first_tail_x1_r0_body.znC14
  ctab := PRE_first_tail_x1_r0_body.ctab14
  zbin := PRE_first_tail_x1_r0_body.zbin14
  cbridge := PRE_first_tail_x1_r0_body.cbridge14
  sbridge := bodyBridge14
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj14
  cshiftR := fun h hNL => bodyCshift14 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN14
  raised := PRE_first_tail_x1_r0_body.raised14
  cbigs := PRE_first_tail_x1_r0_body.cbigs14
  cjcl := PRE_first_tail_x1_r0_body.cjcl14
  xnLe := Nat.le_of_ble_eq_true bodyXn14
  loLe := Nat.le_of_ble_eq_true bodyLo14
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB14
  cntM := bodyCntM14
  hiLe := Nat.le_of_ble_eq_true bodyHi14
  nhiLe := Nat.le_of_ble_eq_true bodyNhi14
  jsHeap := bodyJs14
  jsRoots := bodyJsRoots14
  jsNative := bodyJsNative14
  framesEmpty := bodyFramesEmpty14
  trailOld := by decide
  lowVars := bodyLow14

def bodyQs14 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs14 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr14.map fun r => nth? PRE_first_tail_x1_r0_body.st14.S5.tab r
kernel_rfl bodyResChk14 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs14 bodyQs14) = true
kernel_rfl bodyLq14 : bodyQs14.length = PRE_first_tail_x1_r0_body.cws14.length
kernel_rfl bodyNrLo14 : PRE_first_tail_x1_r0_body.nr14.all (Nat.ble PRE_first_tail_x1_r0_body.S322.tab.length) = true
kernel_rfl bodySub14 : (Oracles.PRE_first_tail_x1_r0_body.map_site14.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost14 : postSubB bodyM PRE_first_tail_x1_r0_body.ws14 PRE_first_tail_x1_r0_body.cws14 bodyQs14 = true
kernel_rfl bodyDrop14 : Nat.ble (17803 + (PRE_first_tail_x1_r0_body.s323.next - PRE_first_tail_x1_r0_body.s324.next)) 18952 = true
kernel_rfl bodyDropH14 : Nat.ble (302 + ((mlxOf PRE_first_tail_x1_r0_body.s323.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s324.ffi).next)) 327 = true
kernel_rfl bodyDropN14 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s323.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s324.ffi).nnext)) 0 = true
kernel_rfl bodyDv14 : bodyΘ.1.take 243 = bodyΘ.1.take 225 ++ PRE_first_tail_x1_r0_body.cws14
kernel_rfl bodyDe14 : bodyΘ.2.take 243 = bodyΘ.2.take 225 ++ PRE_first_tail_x1_r0_body.nr14.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st14.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 225) (bodyΘ.2.take 225)))
kernel_rfl bodyDl14 : (bodyΘ.1.take 225).length = (bodyΘ.2.take 225).length
kernel_rfl bodyDold14 : (bodyΘ.1.take 225).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws14).isNone && !PRE_first_tail_x1_r0_body.ws14.contains v) = true
kernel_rfl bodyDfree14 : (bodyΘ.2.take 243).all (fun e => (PRE_first_tail_x1_r0_body.cws14 ++ PRE_first_tail_x1_r0_body.ws14).all fun w => e.noVar w) = true

theorem bodyStep14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 225⟩ bodyM PRE_first_tail_x1_r0_body.s322 PRE_first_tail_x1_r0_body.S322)
      (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 243⟩ bodyM PRE_first_tail_x1_r0_body.s324 PRE_first_tail_x1_r0_body.S324) (11334 + 1) :=
  bodySite bodyFacts14.cfix bodyFacts14.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x1_r0_body.st14.S5.tab) (Es := bodyEs14) (qs := bodyQs14)
    (ok := PRE_first_tail_x1_r0_body.st14.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site14 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts14
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site14 r hr) hi (MapOk.sub hm (sub_of_all bodySub14)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk14 r hr) hi hm ho hq)
    bodyLq14 rfl bodyNrLo14 (postSub_sound bodyPost14)
    (Nat.le_of_ble_eq_true bodyDrop14) (by decide) (Nat.le_of_ble_eq_true bodyDropH14) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN14) (by decide)
    bodyDv14 bodyDe14 bodyDl14 bodyDold14 bodyDfree14 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodySite15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x1_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n)]

kernel_rfl PRE_first_tail_x1_r0_body.chk_site15 : ([first_tail_x1.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x1_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st15.S0.oracle) = true

noncomputable def PRE_first_tail_x1_r0_body.site15
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st15.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st15.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s343 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.s344 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S343 Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws15 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st15.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st15.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.iso15
  tab := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_15
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st15.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.stFoot15
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrNodup15
  bound := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.wrBound15
  trace := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.trace15
  merged := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.merged15
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.ws15.length = (Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.st15.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.S343.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.tab0_15]
    exact Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.mergeLen15.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x1_r0_body.fresh15
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl15 : Conv.NClean (⟨19104, 16187, 2710720, 1821⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s343.ffi).mlx :=
  PRE_first_tail_x1_r0_body.gncl15 (PRE_first_tail_x1_r0_body.cncl14 bodyNcl14)

theorem bodyClean15 : Conv.JClean (⟨19104, 16187, 2710720, 1821⟩ : Conv.Cnt) PRE_first_tail_x1_r0_body.s343 :=
  PRE_first_tail_x1_r0_body.gjcl15 (PRE_first_tail_x1_r0_body.cjcl14 bodyClean14)

kernel_rfl bodyJsLe15 : Nat.ble PRE_first_tail_x1_r0_body.s322.next PRE_first_tail_x1_r0_body.s343.next = true
kernel_rfl bodyJsList15 : (PRE_first_tail_x1_r0_body.gjh15 ++ PRE_first_tail_x1_r0_body.cl15).all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s343.next) PRE_first_tail_x1_r0_body.s345) = true
theorem bodyJs15 : JsHeapAbove PRE_first_tail_x1_r0_body.s343.next PRE_first_tail_x1_r0_body.s345 :=
  JsHeapAbove.glueSite bodyJs14 (Nat.le_of_ble_eq_true bodyJsLe15) PRE_first_tail_x1_r0_body.gjk15 PRE_first_tail_x1_r0_body.gjbd15 PRE_first_tail_x1_r0_body.cheap15 PRE_first_tail_x1_r0_body.zclbd15 bodyJsList15

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyG15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO324 : PRE_first_tail_x1_r0_body.S324.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S324.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr324 : bridgeOf PRE_first_tail_x1_r0_body.s324.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyAcc324 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s324 PRE_first_tail_x1_r0_body.S324) = fun _ _ => true
kernel_rfl bodyAcc325 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s325 PRE_first_tail_x1_r0_body.S325) = fun _ _ => true
kernel_rfl bodyBr326 : bridgeOf PRE_first_tail_x1_r0_body.s326.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt325 : isHalt PRE_first_tail_x1_r0_body.s325.ctl = false
kernel_rfl bodyTop326 : noRetBlock PRE_first_tail_x1_r0_body.s326 = true
kernel_rfl bodyCnt324 : countersOkB PRE_first_tail_x1_r0_body.s324 PRE_first_tail_x1_r0_body.s326 = true
kernel_rfl bodyO326 : PRE_first_tail_x1_r0_body.S326.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S326.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr327 : bridgeOf PRE_first_tail_x1_r0_body.s327.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt326 : countersOkB PRE_first_tail_x1_r0_body.s326 PRE_first_tail_x1_r0_body.s327 = true
kernel_rfl bodyO327 : PRE_first_tail_x1_r0_body.S327.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S327.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc327 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s327 PRE_first_tail_x1_r0_body.S327) = fun _ _ => true
kernel_rfl bodyAcc331 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s331 PRE_first_tail_x1_r0_body.S331) = fun _ _ => true
kernel_rfl bodyBr332 : bridgeOf PRE_first_tail_x1_r0_body.s332.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt331 : isHalt PRE_first_tail_x1_r0_body.s331.ctl = false
kernel_rfl bodyTop332 : noRetBlock PRE_first_tail_x1_r0_body.s332 = true
kernel_rfl bodyCnt327 : countersOkB PRE_first_tail_x1_r0_body.s327 PRE_first_tail_x1_r0_body.s332 = true
kernel_rfl bodyO332 : PRE_first_tail_x1_r0_body.S332.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S332.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr333 : bridgeOf PRE_first_tail_x1_r0_body.s333.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt332 : countersOkB PRE_first_tail_x1_r0_body.s332 PRE_first_tail_x1_r0_body.s333 = true
kernel_rfl bodyO333 : PRE_first_tail_x1_r0_body.S333.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S333.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc333 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s333 PRE_first_tail_x1_r0_body.S333) = fun _ _ => true
kernel_rfl bodyAcc335 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s335 PRE_first_tail_x1_r0_body.S335) = fun _ _ => true
kernel_rfl bodyBr336 : bridgeOf PRE_first_tail_x1_r0_body.s336.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt335 : isHalt PRE_first_tail_x1_r0_body.s335.ctl = false
kernel_rfl bodyTop336 : noRetBlock PRE_first_tail_x1_r0_body.s336 = true
kernel_rfl bodyCnt333 : countersOkB PRE_first_tail_x1_r0_body.s333 PRE_first_tail_x1_r0_body.s336 = true
kernel_rfl bodyO336 : PRE_first_tail_x1_r0_body.S336.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S336.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr337 : bridgeOf PRE_first_tail_x1_r0_body.s337.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt336 : countersOkB PRE_first_tail_x1_r0_body.s336 PRE_first_tail_x1_r0_body.s337 = true
kernel_rfl bodyO337 : PRE_first_tail_x1_r0_body.S337.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S337.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc337 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s337 PRE_first_tail_x1_r0_body.S337) = fun _ _ => true
kernel_rfl bodyAcc338 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s338 PRE_first_tail_x1_r0_body.S338) = fun _ _ => true
kernel_rfl bodyBr339 : bridgeOf PRE_first_tail_x1_r0_body.s339.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt338 : isHalt PRE_first_tail_x1_r0_body.s338.ctl = false
kernel_rfl bodyTop339 : noRetBlock PRE_first_tail_x1_r0_body.s339 = true
kernel_rfl bodyCnt337 : countersOkB PRE_first_tail_x1_r0_body.s337 PRE_first_tail_x1_r0_body.s339 = true
kernel_rfl bodyO339 : PRE_first_tail_x1_r0_body.S339.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S339.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyBr340 : bridgeOf PRE_first_tail_x1_r0_body.s340.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyCnt339 : countersOkB PRE_first_tail_x1_r0_body.s339 PRE_first_tail_x1_r0_body.s340 = true
kernel_rfl bodyO340 : PRE_first_tail_x1_r0_body.S340.oracle = List.drop (PRE_first_tail_x1_r0_body.OR.length - PRE_first_tail_x1_r0_body.S340.oracle.length) PRE_first_tail_x1_r0_body.OR
kernel_rfl bodyAcc340 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s340 PRE_first_tail_x1_r0_body.S340) = fun _ _ => true
kernel_rfl bodyAcc342 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x1_r0_body.s342 PRE_first_tail_x1_r0_body.S342) = fun _ _ => true
kernel_rfl bodyBr343 : bridgeOf PRE_first_tail_x1_r0_body.s343.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi
kernel_rfl bodyHalt342 : isHalt PRE_first_tail_x1_r0_body.s342.ctl = false
kernel_rfl bodyTop343 : noRetBlock PRE_first_tail_x1_r0_body.s343 = true
kernel_rfl bodyCnt340 : countersOkB PRE_first_tail_x1_r0_body.s340 PRE_first_tail_x1_r0_body.s343 = true

theorem bodyGlue15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 243⟩ bodyM PRE_first_tail_x1_r0_body.s324 PRE_first_tail_x1_r0_body.S324)
      (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 243⟩ bodyM PRE_first_tail_x1_r0_body.s343 PRE_first_tail_x1_r0_body.S343) 24808 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc324 PRE_first_tail_x1_r0_body.bodyRunSeg86 bodyAcc325 bodyHalt325 PRE_first_tail_x1_r0_body.bodyStepA87 bodyTop326 (fun _ hm => bodyO324 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr324).trans bodyInactive0) (bodyBr326.trans bodyBr324.symm) bodyCnt324 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) PRE_first_tail_x1_r0_body.sizeA87 PRE_first_tail_x1_r0_body.sizeArgsA87 PRE_first_tail_x1_r0_body.sizeSymA87 PRE_first_tail_x1_r0_body.sizeMlxA87 PRE_first_tail_x1_r0_body.sizePayA87 PRE_first_tail_x1_r0_body.sizeTaA87 PRE_first_tail_x1_r0_body.sizeDecA87 PRE_first_tail_x1_r0_body.sizePreA87 PRE_first_tail_x1_r0_body.bodyPatchB87 (fun _ hm => bodyO326 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr326).trans bodyInactive0) (bodyBr327.trans bodyBr326.symm) bodyCnt326 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc327 PRE_first_tail_x1_r0_body.bodyRunSeg87 bodyAcc331 bodyHalt331 PRE_first_tail_x1_r0_body.bodyStepA88 bodyTop332 (fun _ hm => bodyO327 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr327).trans bodyInactive0) (bodyBr332.trans bodyBr327.symm) bodyCnt327 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) PRE_first_tail_x1_r0_body.sizeA88 PRE_first_tail_x1_r0_body.sizeArgsA88 PRE_first_tail_x1_r0_body.sizeSymA88 PRE_first_tail_x1_r0_body.sizeMlxA88 PRE_first_tail_x1_r0_body.sizePayA88 PRE_first_tail_x1_r0_body.sizeTaA88 PRE_first_tail_x1_r0_body.sizeDecA88 PRE_first_tail_x1_r0_body.sizePreA88 PRE_first_tail_x1_r0_body.bodyPatchB88 (fun _ hm => bodyO332 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr332).trans bodyInactive0) (bodyBr333.trans bodyBr332.symm) bodyCnt332 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc333 PRE_first_tail_x1_r0_body.bodyRunSeg88 bodyAcc335 bodyHalt335 PRE_first_tail_x1_r0_body.bodyStepA89 bodyTop336 (fun _ hm => bodyO333 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr333).trans bodyInactive0) (bodyBr336.trans bodyBr333.symm) bodyCnt333 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) PRE_first_tail_x1_r0_body.sizeA89 PRE_first_tail_x1_r0_body.sizeArgsA89 PRE_first_tail_x1_r0_body.sizeSymA89 PRE_first_tail_x1_r0_body.sizeMlxA89 PRE_first_tail_x1_r0_body.sizePayA89 PRE_first_tail_x1_r0_body.sizeTaA89 PRE_first_tail_x1_r0_body.sizeDecA89 PRE_first_tail_x1_r0_body.sizePreA89 PRE_first_tail_x1_r0_body.bodyPatchB89 (fun _ hm => bodyO336 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr336).trans bodyInactive0) (bodyBr337.trans bodyBr336.symm) bodyCnt336 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc337 PRE_first_tail_x1_r0_body.bodyRunSeg89 bodyAcc338 bodyHalt338 PRE_first_tail_x1_r0_body.bodyStepA90 bodyTop339 (fun _ hm => bodyO337 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr337).trans bodyInactive0) (bodyBr339.trans bodyBr337.symm) bodyCnt337 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) PRE_first_tail_x1_r0_body.sizeA90 PRE_first_tail_x1_r0_body.sizeArgsA90 PRE_first_tail_x1_r0_body.sizeSymA90 PRE_first_tail_x1_r0_body.sizeMlxA90 PRE_first_tail_x1_r0_body.sizePayA90 PRE_first_tail_x1_r0_body.sizeTaA90 PRE_first_tail_x1_r0_body.sizeDecA90 PRE_first_tail_x1_r0_body.sizePreA90 PRE_first_tail_x1_r0_body.bodyPatchB90 (fun _ hm => bodyO339 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr339).trans bodyInactive0) (bodyBr340.trans bodyBr339.symm) bodyCnt339 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc340 PRE_first_tail_x1_r0_body.bodyRunSeg90 bodyAcc342 bodyHalt342 PRE_first_tail_x1_r0_body.bodyStepA91 bodyTop343 (fun _ hm => bodyO340 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr340).trans bodyInactive0) (bodyBr343.trans bodyBr340.symm) bodyCnt340 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X1

end

section -- VWBodyS15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift15 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x1_r0_body.S343.tab.length PRE_first_tail_x1_r0_body.s343.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x1_r0_body.P15.NL) : Conv.FullShiftQ PRE_first_tail_x1_r0_body.P15 1830 PRE_first_tail_x1_r0_body.kappa15 PRE_first_tail_x1_r0_body.s345.ffi PRE_first_tail_x1_r0_body.s344.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x1_r0_body.ofxC_15
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x1_r0_body.okrC_15
  have hcl : SSt (· < 1830) (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_body.s345.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x1_r0_body.S343.tab.length) hr.cl (by rw [PRE_first_tail_x1_r0_body.n0_15] <;> decide) PRE_first_tail_x1_r0_body.cnodesK15 PRE_first_tail_x1_r0_body.cobjsK15
      PRE_first_tail_x1_r0_body.citemsK15 PRE_first_tail_x1_r0_body.cbd15 PRE_first_tail_x1_r0_body.csst15
  exact PRE_first_tail_x1_r0_body.cshift15 bodyNcl15 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x1_r0_body.n0_15] at this; exact this)


kernel_rfl bodyFramesEmpty15 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x1_r0_body.s344 a).isEmpty) = true
kernel_rfl bodyJsRoots15 : noBigRootsP (jsAboveB PRE_first_tail_x1_r0_body.s343.next) PRE_first_tail_x1_r0_body.s345.trace PRE_first_tail_x1_r0_body.s345 = true
kernel_rfl bodyJsNative15 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0_body.s345.ffi) = true
kernel_rfl bodyLow15 : (PRE_first_tail_x1_r0_body.cws15 ++ PRE_first_tail_x1_r0_body.ws15).all (Nat.ble 9) = true
kernel_rfl bodyCntM15 : countersOkB PRE_first_tail_x1_r0_body.s343 PRE_first_tail_x1_r0_body.s344 = true
kernel_rfl bodyHi15 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s345.ffi).next setupP.E = true
kernel_rfl bodyNhi15 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s345.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge15 : bridgeOf PRE_first_tail_x1_r0_body.s344.ffi = bridgeOf PRE_first_tail_x1_r0_body.s343.ffi
kernel_rfl bodyNN15 : Nat.ble (mlxOf PRE_first_tail_x1_r0_body.s343.ffi).nnext PRE_first_tail_x1_r0_body.P15.NL = true
kernel_rfl bodyXn15 : Nat.ble (⟨19108, 16193, 2710735, 1830⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x1_r0_body.s345.ffi).next = true
kernel_rfl bodyLo15 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x1_r0_body.s345.ffi).next = true
theorem bodyFacts15 : BodySiteFacts PRE_first_tail_x1_r0_body.s343 PRE_first_tail_x1_r0_body.s344 PRE_first_tail_x1_r0_body.s345 PRE_first_tail_x1_r0_body.s0 PRE_first_tail_x1_r0_body.S343 PRE_first_tail_x1_r0_body.S344 PRE_first_tail_x1_r0_body.S345
    PRE_first_tail_x1_r0_body.ws15 PRE_first_tail_x1_r0_body.cws15 PRE_first_tail_x1_r0_body.nr15 PRE_first_tail_x1_r0_body.pl15 PRE_first_tail_x1_r0_body.cl15 2711085 1830 PRE_first_tail_x1_r0_body.kd15 PRE_first_tail_x1_r0_body.kappa15 PRE_first_tail_x1_r0_body.P15
    ⟨19104, 16187, 2710720, 1821⟩ ⟨19108, 16193, 2710735, 1830⟩ where
  zkap := PRE_first_tail_x1_r0_body.zkap15
  clean := bodyClean15
  cfix := PRE_first_tail_x1_r0_body.cfix15
  zpl := PRE_first_tail_x1_r0_body.zpl15
  zplnd := PRE_first_tail_x1_r0_body.zplnd15
  zn1 := PRE_first_tail_x1_r0_body.zn115
  zfirst := PRE_first_tail_x1_r0_body.zfirst15
  zscn := PRE_first_tail_x1_r0_body.zscn15
  zsmn := PRE_first_tail_x1_r0_body.zsmn15
  zgrow := PRE_first_tail_x1_r0_body.zgrow15
  mergeTab := PRE_first_tail_x1_r0_body.mergeTab15
  zfresh := PRE_first_tail_x1_r0_body.zfresh15
  zcnd := PRE_first_tail_x1_r0_body.zcnd15
  lenc := by rfl
  znrHi := PRE_first_tail_x1_r0_body.znrHi15
  zfrlt := PRE_first_tail_x1_r0_body.zfrlt15
  zgP := PRE_first_tail_x1_r0_body.zg15_2665
  zkP := PRE_first_tail_x1_r0_body.zk15_2665
  zmP := PRE_first_tail_x1_r0_body.zm15_2665
  zgC := PRE_first_tail_x1_r0_body.zg15_2673467
  zkC := PRE_first_tail_x1_r0_body.zk15_2673467
  zmC := PRE_first_tail_x1_r0_body.zm15_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x1_r0_body.zw15_2673472
  zwV := PRE_first_tail_x1_r0_body.zw15_2673473
  cheap := PRE_first_tail_x1_r0_body.cheap15
  zclbd := PRE_first_tail_x1_r0_body.zclbd15
  hml := hoff_of PRE_first_tail_x1_r0_body.mheap15 PRE_first_tail_x1_r0_body.stFoot15 PRE_first_tail_x1_r0_body.iso15 PRE_first_tail_x1_r0_body.zwr15
  ckeepP := PRE_first_tail_x1_r0_body.ckeepP15
  csupp := PRE_first_tail_x1_r0_body.csupp15
  cbound := PRE_first_tail_x1_r0_body.cbound15
  zimg := PRE_first_tail_x1_r0_body.zimg15
  zctl := PRE_first_tail_x1_r0_body.zctl15
  zstack := PRE_first_tail_x1_r0_body.zstack15
  zjobs := PRE_first_tail_x1_r0_body.zjobs15
  zstores := PRE_first_tail_x1_r0_body.zstores15
  zroots := PRE_first_tail_x1_r0_body.zroots15
  znC := PRE_first_tail_x1_r0_body.znC15
  ctab := PRE_first_tail_x1_r0_body.ctab15
  zbin := PRE_first_tail_x1_r0_body.zbin15
  cbridge := PRE_first_tail_x1_r0_body.cbridge15
  sbridge := bodyBridge15
  cwsDisj := PRE_first_tail_x1_r0_body.cwsDisj15
  cshiftR := fun h hNL => bodyCshift15 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN15
  raised := PRE_first_tail_x1_r0_body.raised15
  cbigs := PRE_first_tail_x1_r0_body.cbigs15
  cjcl := PRE_first_tail_x1_r0_body.cjcl15
  xnLe := Nat.le_of_ble_eq_true bodyXn15
  loLe := Nat.le_of_ble_eq_true bodyLo15
  zroots2 := PRE_first_tail_x1_r0_body.zrootsB15
  cntM := bodyCntM15
  hiLe := Nat.le_of_ble_eq_true bodyHi15
  nhiLe := Nat.le_of_ble_eq_true bodyNhi15
  jsHeap := bodyJs15
  jsRoots := bodyJsRoots15
  jsNative := bodyJsNative15
  framesEmpty := bodyFramesEmpty15
  trailOld := by decide
  lowVars := bodyLow15

def bodyQs15 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs15 : List (Option SymE) := PRE_first_tail_x1_r0_body.nr15.map fun r => nth? PRE_first_tail_x1_r0_body.st15.S3.tab r
kernel_rfl bodyResChk15 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs15 bodyQs15) = true
kernel_rfl bodyLq15 : bodyQs15.length = PRE_first_tail_x1_r0_body.cws15.length
kernel_rfl bodyNrLo15 : PRE_first_tail_x1_r0_body.nr15.all (Nat.ble PRE_first_tail_x1_r0_body.S343.tab.length) = true
kernel_rfl bodySub15 : (Oracles.PRE_first_tail_x1_r0_body.map_site15.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost15 : postSubB bodyM PRE_first_tail_x1_r0_body.ws15 PRE_first_tail_x1_r0_body.cws15 bodyQs15 = true
kernel_rfl bodyDrop15 : Nat.ble (18952 + (PRE_first_tail_x1_r0_body.s344.next - PRE_first_tail_x1_r0_body.s345.next)) 19302 = true
kernel_rfl bodyDropH15 : Nat.ble (327 + ((mlxOf PRE_first_tail_x1_r0_body.s344.ffi).next - (mlxOf PRE_first_tail_x1_r0_body.s345.ffi).next)) 329 = true
kernel_rfl bodyDropN15 : Nat.ble (0 + ((mlxOf PRE_first_tail_x1_r0_body.s344.ffi).nnext - (mlxOf PRE_first_tail_x1_r0_body.s345.ffi).nnext)) 0 = true
kernel_rfl bodyDv15 : bodyΘ.1.take 252 = bodyΘ.1.take 243 ++ PRE_first_tail_x1_r0_body.cws15
kernel_rfl bodyDe15 : bodyΘ.2.take 252 = bodyΘ.2.take 243 ++ PRE_first_tail_x1_r0_body.nr15.map (fun r =>
  ((nth? PRE_first_tail_x1_r0_body.st15.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 243) (bodyΘ.2.take 243)))
kernel_rfl bodyDl15 : (bodyΘ.1.take 243).length = (bodyΘ.2.take 243).length
kernel_rfl bodyDold15 : (bodyΘ.1.take 243).all (fun v => (Conv.idx? v PRE_first_tail_x1_r0_body.cws15).isNone && !PRE_first_tail_x1_r0_body.ws15.contains v) = true
kernel_rfl bodyDfree15 : (bodyΘ.2.take 252).all (fun e => (PRE_first_tail_x1_r0_body.cws15 ++ PRE_first_tail_x1_r0_body.ws15).all fun w => e.noVar w) = true

theorem bodyStep15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 243⟩ bodyM PRE_first_tail_x1_r0_body.s343 PRE_first_tail_x1_r0_body.S343)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19302, 329, 0, 252⟩ bodyM PRE_first_tail_x1_r0_body.s345 PRE_first_tail_x1_r0_body.S345) (3452 + 1) :=
  bodySite bodyFacts15.cfix bodyFacts15.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x1_r0_body.st15.S3.tab) (Es := bodyEs15) (qs := bodyQs15)
    (ok := PRE_first_tail_x1_r0_body.st15.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x1_r0_body.site15 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts15
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x1_r0_body.chk_site15 r hr) hi (MapOk.sub hm (sub_of_all bodySub15)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk15 r hr) hi hm ho hq)
    bodyLq15 rfl bodyNrLo15 (postSub_sound bodyPost15)
    (Nat.le_of_ble_eq_true bodyDrop15) (by decide) (Nat.le_of_ble_eq_true bodyDropH15) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN15) (by decide)
    bodyDv15 bodyDe15 bodyDl15 bodyDold15 bodyDfree15 hR hB

end Host.Ts.Sim.Compose.VWFirst.X1

end
