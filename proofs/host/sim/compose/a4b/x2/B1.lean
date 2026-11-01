import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x2_r0_body.States
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B15
import host.sim.compose.a4b.x2.B0
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B23
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.x2.VWBodyChain
import host.sim.compose.a4b.x2.VWBodyMap
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B13
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B12
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B16

section -- VWBodyOracles_2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_g8 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g8 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g8) (List.take 30 (List.drop 230 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site8 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site8 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site8) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st8.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g9 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g9) (List.take 27 (List.drop 260 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site9 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st9.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g10 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g10) (List.take 27 (List.drop 287 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site10 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site10) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st10.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g11 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g11 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g11) (List.take 39 (List.drop 314 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site11 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site11 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site11) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st11.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site8 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site8 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site8) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st8.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site8
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st8.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st8.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s190 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s191 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S190 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws8 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st8.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st8.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso8
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_8
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st8.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot8
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup8
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound8
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace8
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged8
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws8.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st8.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S190.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_8]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen8.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh8
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl8 : Conv.NClean (⟨18688, 15752, 2694143, 1087⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s190.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl8 (PRE_first_tail_x2_r0_body.cncl7 bodyNcl7)

theorem bodyClean8 : Conv.JClean (⟨18688, 15752, 2694143, 1087⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s190 :=
  PRE_first_tail_x2_r0_body.gjcl8 (PRE_first_tail_x2_r0_body.cjcl7 bodyClean7)

kernel_rfl bodyJsLe8 : Nat.ble PRE_first_tail_x2_r0_body.s168.next PRE_first_tail_x2_r0_body.s190.next = true
kernel_rfl bodyJsList8 : (PRE_first_tail_x2_r0_body.gjh8 ++ PRE_first_tail_x2_r0_body.cl8).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s190.next) PRE_first_tail_x2_r0_body.s192) = true
theorem bodyJs8 : JsHeapAbove PRE_first_tail_x2_r0_body.s190.next PRE_first_tail_x2_r0_body.s192 :=
  JsHeapAbove.glueSite bodyJs7 (Nat.le_of_ble_eq_true bodyJsLe8) PRE_first_tail_x2_r0_body.gjk8 PRE_first_tail_x2_r0_body.gjbd8 PRE_first_tail_x2_r0_body.cheap8 PRE_first_tail_x2_r0_body.zclbd8 bodyJsList8

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO170 : PRE_first_tail_x2_r0_body.S170.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S170.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr170 : bridgeOf PRE_first_tail_x2_r0_body.s170.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc170 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s170 PRE_first_tail_x2_r0_body.S170) = fun _ _ => true
kernel_rfl bodyAcc171 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s171 PRE_first_tail_x2_r0_body.S171) = fun _ _ => true
kernel_rfl bodyBr172 : bridgeOf PRE_first_tail_x2_r0_body.s172.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt171 : isHalt PRE_first_tail_x2_r0_body.s171.ctl = false
kernel_rfl bodyTop172 : noRetBlock PRE_first_tail_x2_r0_body.s172 = true
kernel_rfl bodyCnt170 : countersOkB PRE_first_tail_x2_r0_body.s170 PRE_first_tail_x2_r0_body.s172 = true
kernel_rfl bodyO172 : PRE_first_tail_x2_r0_body.S172.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S172.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr173 : bridgeOf PRE_first_tail_x2_r0_body.s173.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt172 : countersOkB PRE_first_tail_x2_r0_body.s172 PRE_first_tail_x2_r0_body.s173 = true
kernel_rfl bodyO173 : PRE_first_tail_x2_r0_body.S173.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S173.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc173 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s173 PRE_first_tail_x2_r0_body.S173) = fun _ _ => true
kernel_rfl bodyAcc177 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s177 PRE_first_tail_x2_r0_body.S177) = fun _ _ => true
kernel_rfl bodyBr178 : bridgeOf PRE_first_tail_x2_r0_body.s178.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt177 : isHalt PRE_first_tail_x2_r0_body.s177.ctl = false
kernel_rfl bodyTop178 : noRetBlock PRE_first_tail_x2_r0_body.s178 = true
kernel_rfl bodyCnt173 : countersOkB PRE_first_tail_x2_r0_body.s173 PRE_first_tail_x2_r0_body.s178 = true
kernel_rfl bodyO178 : PRE_first_tail_x2_r0_body.S178.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S178.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr179 : bridgeOf PRE_first_tail_x2_r0_body.s179.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt178 : countersOkB PRE_first_tail_x2_r0_body.s178 PRE_first_tail_x2_r0_body.s179 = true
kernel_rfl bodyO179 : PRE_first_tail_x2_r0_body.S179.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S179.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc179 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s179 PRE_first_tail_x2_r0_body.S179) = fun _ _ => true
kernel_rfl bodyAcc180 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s180 PRE_first_tail_x2_r0_body.S180) = fun _ _ => true
kernel_rfl bodyBr181 : bridgeOf PRE_first_tail_x2_r0_body.s181.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt180 : isHalt PRE_first_tail_x2_r0_body.s180.ctl = false
kernel_rfl bodyTop181 : noRetBlock PRE_first_tail_x2_r0_body.s181 = true
kernel_rfl bodyCnt179 : countersOkB PRE_first_tail_x2_r0_body.s179 PRE_first_tail_x2_r0_body.s181 = true
kernel_rfl bodyO181 : PRE_first_tail_x2_r0_body.S181.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S181.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr182 : bridgeOf PRE_first_tail_x2_r0_body.s182.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt181 : countersOkB PRE_first_tail_x2_r0_body.s181 PRE_first_tail_x2_r0_body.s182 = true
kernel_rfl bodyO182 : PRE_first_tail_x2_r0_body.S182.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S182.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc182 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s182 PRE_first_tail_x2_r0_body.S182) = fun _ _ => true
kernel_rfl bodyAcc183 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s183 PRE_first_tail_x2_r0_body.S183) = fun _ _ => true
kernel_rfl bodyBr184 : bridgeOf PRE_first_tail_x2_r0_body.s184.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt183 : isHalt PRE_first_tail_x2_r0_body.s183.ctl = false
kernel_rfl bodyTop184 : noRetBlock PRE_first_tail_x2_r0_body.s184 = true
kernel_rfl bodyCnt182 : countersOkB PRE_first_tail_x2_r0_body.s182 PRE_first_tail_x2_r0_body.s184 = true
kernel_rfl bodyO184 : PRE_first_tail_x2_r0_body.S184.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S184.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr185 : bridgeOf PRE_first_tail_x2_r0_body.s185.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt184 : countersOkB PRE_first_tail_x2_r0_body.s184 PRE_first_tail_x2_r0_body.s185 = true
kernel_rfl bodyO185 : PRE_first_tail_x2_r0_body.S185.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S185.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc185 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s185 PRE_first_tail_x2_r0_body.S185) = fun _ _ => true
kernel_rfl bodyAcc186 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s186 PRE_first_tail_x2_r0_body.S186) = fun _ _ => true
kernel_rfl bodyBr187 : bridgeOf PRE_first_tail_x2_r0_body.s187.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt186 : isHalt PRE_first_tail_x2_r0_body.s186.ctl = false
kernel_rfl bodyTop187 : noRetBlock PRE_first_tail_x2_r0_body.s187 = true
kernel_rfl bodyCnt185 : countersOkB PRE_first_tail_x2_r0_body.s185 PRE_first_tail_x2_r0_body.s187 = true
kernel_rfl bodyO187 : PRE_first_tail_x2_r0_body.S187.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S187.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr188 : bridgeOf PRE_first_tail_x2_r0_body.s188.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt187 : countersOkB PRE_first_tail_x2_r0_body.s187 PRE_first_tail_x2_r0_body.s188 = true
kernel_rfl bodyO188 : PRE_first_tail_x2_r0_body.S188.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S188.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc188 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s188 PRE_first_tail_x2_r0_body.S188) = fun _ _ => true
kernel_rfl bodyAcc189 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s189 PRE_first_tail_x2_r0_body.S189) = fun _ _ => true
kernel_rfl bodyBr190 : bridgeOf PRE_first_tail_x2_r0_body.s190.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt189 : isHalt PRE_first_tail_x2_r0_body.s189.ctl = false
kernel_rfl bodyTop190 : noRetBlock PRE_first_tail_x2_r0_body.s190 = true
kernel_rfl bodyCnt188 : countersOkB PRE_first_tail_x2_r0_body.s188 PRE_first_tail_x2_r0_body.s190 = true

theorem bodyGlue8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 126⟩ bodyM PRE_first_tail_x2_r0_body.s170 PRE_first_tail_x2_r0_body.S170)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 126⟩ bodyM PRE_first_tail_x2_r0_body.s190 PRE_first_tail_x2_r0_body.S190) 23330 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc170 PRE_first_tail_x2_r0_body.bodyRunSeg45 bodyAcc171 bodyHalt171 PRE_first_tail_x2_r0_body.bodyStepA46 bodyTop172 (fun _ hm => bodyO170 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr170).trans bodyInactive0) (bodyBr172.trans bodyBr170.symm) bodyCnt170 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x2_r0_body.sizeA46 PRE_first_tail_x2_r0_body.sizeArgsA46 PRE_first_tail_x2_r0_body.sizeSymA46 PRE_first_tail_x2_r0_body.sizeMlxA46 PRE_first_tail_x2_r0_body.sizePayA46 PRE_first_tail_x2_r0_body.sizeTaA46 PRE_first_tail_x2_r0_body.sizeDecA46 PRE_first_tail_x2_r0_body.sizePreA46 PRE_first_tail_x2_r0_body.bodyPatchB46 (fun _ hm => bodyO172 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr172).trans bodyInactive0) (bodyBr173.trans bodyBr172.symm) bodyCnt172 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc173 PRE_first_tail_x2_r0_body.bodyRunSeg46 bodyAcc177 bodyHalt177 PRE_first_tail_x2_r0_body.bodyStepA47 bodyTop178 (fun _ hm => bodyO173 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr173).trans bodyInactive0) (bodyBr178.trans bodyBr173.symm) bodyCnt173 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x2_r0_body.sizeA47 PRE_first_tail_x2_r0_body.sizeArgsA47 PRE_first_tail_x2_r0_body.sizeSymA47 PRE_first_tail_x2_r0_body.sizeMlxA47 PRE_first_tail_x2_r0_body.sizePayA47 PRE_first_tail_x2_r0_body.sizeTaA47 PRE_first_tail_x2_r0_body.sizeDecA47 PRE_first_tail_x2_r0_body.sizePreA47 PRE_first_tail_x2_r0_body.bodyPatchB47 (fun _ hm => bodyO178 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr178).trans bodyInactive0) (bodyBr179.trans bodyBr178.symm) bodyCnt178 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc179 PRE_first_tail_x2_r0_body.bodyRunSeg47 bodyAcc180 bodyHalt180 PRE_first_tail_x2_r0_body.bodyStepA48 bodyTop181 (fun _ hm => bodyO179 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr179).trans bodyInactive0) (bodyBr181.trans bodyBr179.symm) bodyCnt179 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x2_r0_body.sizeA48 PRE_first_tail_x2_r0_body.sizeArgsA48 PRE_first_tail_x2_r0_body.sizeSymA48 PRE_first_tail_x2_r0_body.sizeMlxA48 PRE_first_tail_x2_r0_body.sizePayA48 PRE_first_tail_x2_r0_body.sizeTaA48 PRE_first_tail_x2_r0_body.sizeDecA48 PRE_first_tail_x2_r0_body.sizePreA48 PRE_first_tail_x2_r0_body.bodyPatchB48 (fun _ hm => bodyO181 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr181).trans bodyInactive0) (bodyBr182.trans bodyBr181.symm) bodyCnt181 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc182 PRE_first_tail_x2_r0_body.bodyRunSeg48 bodyAcc183 bodyHalt183 PRE_first_tail_x2_r0_body.bodyStepA49 bodyTop184 (fun _ hm => bodyO182 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr182).trans bodyInactive0) (bodyBr184.trans bodyBr182.symm) bodyCnt182 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x2_r0_body.sizeA49 PRE_first_tail_x2_r0_body.sizeArgsA49 PRE_first_tail_x2_r0_body.sizeSymA49 PRE_first_tail_x2_r0_body.sizeMlxA49 PRE_first_tail_x2_r0_body.sizePayA49 PRE_first_tail_x2_r0_body.sizeTaA49 PRE_first_tail_x2_r0_body.sizeDecA49 PRE_first_tail_x2_r0_body.sizePreA49 PRE_first_tail_x2_r0_body.bodyPatchB49 (fun _ hm => bodyO184 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr184).trans bodyInactive0) (bodyBr185.trans bodyBr184.symm) bodyCnt184 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc185 PRE_first_tail_x2_r0_body.bodyRunSeg49 bodyAcc186 bodyHalt186 PRE_first_tail_x2_r0_body.bodyStepA50 bodyTop187 (fun _ hm => bodyO185 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr185).trans bodyInactive0) (bodyBr187.trans bodyBr185.symm) bodyCnt185 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) PRE_first_tail_x2_r0_body.sizeA50 PRE_first_tail_x2_r0_body.sizeArgsA50 PRE_first_tail_x2_r0_body.sizeSymA50 PRE_first_tail_x2_r0_body.sizeMlxA50 PRE_first_tail_x2_r0_body.sizePayA50 PRE_first_tail_x2_r0_body.sizeTaA50 PRE_first_tail_x2_r0_body.sizeDecA50 PRE_first_tail_x2_r0_body.sizePreA50 PRE_first_tail_x2_r0_body.bodyPatchB50 (fun _ hm => bodyO187 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr187).trans bodyInactive0) (bodyBr188.trans bodyBr187.symm) bodyCnt187 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 126⟩) bodyAcc188 PRE_first_tail_x2_r0_body.bodyRunSeg50 bodyAcc189 bodyHalt189 PRE_first_tail_x2_r0_body.bodyStepA51 bodyTop190 (fun _ hm => bodyO188 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr188).trans bodyInactive0) (bodyBr190.trans bodyBr188.symm) bodyCnt188 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift8 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S190.tab.length PRE_first_tail_x2_r0_body.s190.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P8.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P8 1105 PRE_first_tail_x2_r0_body.kappa8 PRE_first_tail_x2_r0_body.s192.ffi PRE_first_tail_x2_r0_body.s191.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_8
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_8
  have hcl : SSt (· < 1105) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s192.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S190.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_8] <;> decide) PRE_first_tail_x2_r0_body.cnodesK8 PRE_first_tail_x2_r0_body.cobjsK8
      PRE_first_tail_x2_r0_body.citemsK8 PRE_first_tail_x2_r0_body.cbd8 PRE_first_tail_x2_r0_body.csst8
  exact PRE_first_tail_x2_r0_body.cshift8 bodyNcl8 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_8] at this; exact this)


kernel_rfl bodyFramesEmpty8 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s191 a).isEmpty) = true
kernel_rfl bodyJsRoots8 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s190.next) PRE_first_tail_x2_r0_body.s192.trace PRE_first_tail_x2_r0_body.s192 = true
kernel_rfl bodyJsNative8 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s192.ffi) = true
kernel_rfl bodyLow8 : (PRE_first_tail_x2_r0_body.cws8 ++ PRE_first_tail_x2_r0_body.ws8).all (Nat.ble 9) = true
kernel_rfl bodyCntM8 : countersOkB PRE_first_tail_x2_r0_body.s190 PRE_first_tail_x2_r0_body.s191 = true
kernel_rfl bodyHi8 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s192.ffi).next setupP.E = true
kernel_rfl bodyNhi8 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s192.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge8 : bridgeOf PRE_first_tail_x2_r0_body.s191.ffi = bridgeOf PRE_first_tail_x2_r0_body.s190.ffi
kernel_rfl bodyNN8 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s190.ffi).nnext PRE_first_tail_x2_r0_body.P8.NL = true
kernel_rfl bodyXn8 : Nat.ble (⟨18691, 15779, 2694149, 1105⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s192.ffi).next = true
kernel_rfl bodyLo8 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s192.ffi).next = true
theorem bodyFacts8 : BodySiteFacts PRE_first_tail_x2_r0_body.s190 PRE_first_tail_x2_r0_body.s191 PRE_first_tail_x2_r0_body.s192 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S190 PRE_first_tail_x2_r0_body.S191 PRE_first_tail_x2_r0_body.S192
    PRE_first_tail_x2_r0_body.ws8 PRE_first_tail_x2_r0_body.cws8 PRE_first_tail_x2_r0_body.nr8 PRE_first_tail_x2_r0_body.pl8 PRE_first_tail_x2_r0_body.cl8 2695298 1105 PRE_first_tail_x2_r0_body.kd8 PRE_first_tail_x2_r0_body.kappa8 PRE_first_tail_x2_r0_body.P8
    ⟨18688, 15752, 2694143, 1087⟩ ⟨18691, 15779, 2694149, 1105⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap8
  clean := bodyClean8
  cfix := PRE_first_tail_x2_r0_body.cfix8
  zpl := PRE_first_tail_x2_r0_body.zpl8
  zplnd := PRE_first_tail_x2_r0_body.zplnd8
  zn1 := PRE_first_tail_x2_r0_body.zn18
  zfirst := PRE_first_tail_x2_r0_body.zfirst8
  zscn := PRE_first_tail_x2_r0_body.zscn8
  zsmn := PRE_first_tail_x2_r0_body.zsmn8
  zgrow := PRE_first_tail_x2_r0_body.zgrow8
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab8
  zfresh := PRE_first_tail_x2_r0_body.zfresh8
  zcnd := PRE_first_tail_x2_r0_body.zcnd8
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi8
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt8
  zgP := PRE_first_tail_x2_r0_body.zg8_2665
  zkP := PRE_first_tail_x2_r0_body.zk8_2665
  zmP := PRE_first_tail_x2_r0_body.zm8_2665
  zgC := PRE_first_tail_x2_r0_body.zg8_2673467
  zkC := PRE_first_tail_x2_r0_body.zk8_2673467
  zmC := PRE_first_tail_x2_r0_body.zm8_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw8_2673472
  zwV := PRE_first_tail_x2_r0_body.zw8_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap8
  zclbd := PRE_first_tail_x2_r0_body.zclbd8
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap8 PRE_first_tail_x2_r0_body.stFoot8 PRE_first_tail_x2_r0_body.iso8 PRE_first_tail_x2_r0_body.zwr8
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP8
  csupp := PRE_first_tail_x2_r0_body.csupp8
  cbound := PRE_first_tail_x2_r0_body.cbound8
  zimg := PRE_first_tail_x2_r0_body.zimg8
  zctl := PRE_first_tail_x2_r0_body.zctl8
  zstack := PRE_first_tail_x2_r0_body.zstack8
  zjobs := PRE_first_tail_x2_r0_body.zjobs8
  zstores := PRE_first_tail_x2_r0_body.zstores8
  zroots := PRE_first_tail_x2_r0_body.zroots8
  znC := PRE_first_tail_x2_r0_body.znC8
  ctab := PRE_first_tail_x2_r0_body.ctab8
  zbin := PRE_first_tail_x2_r0_body.zbin8
  cbridge := PRE_first_tail_x2_r0_body.cbridge8
  sbridge := bodyBridge8
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj8
  cshiftR := fun h hNL => bodyCshift8 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN8
  raised := PRE_first_tail_x2_r0_body.raised8
  cbigs := PRE_first_tail_x2_r0_body.cbigs8
  cjcl := PRE_first_tail_x2_r0_body.cjcl8
  xnLe := Nat.le_of_ble_eq_true bodyXn8
  loLe := Nat.le_of_ble_eq_true bodyLo8
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB8
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
noncomputable def bodyEs8 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr8.map fun r => nth? PRE_first_tail_x2_r0_body.st8.S5.tab r
kernel_rfl bodyResChk8 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs8 bodyQs8) = true
kernel_rfl bodyLq8 : bodyQs8.length = PRE_first_tail_x2_r0_body.cws8.length
kernel_rfl bodyNrLo8 : PRE_first_tail_x2_r0_body.nr8.all (Nat.ble PRE_first_tail_x2_r0_body.S190.tab.length) = true
kernel_rfl bodySub8 : (Oracles.PRE_first_tail_x2_r0_body.map_site8.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost8 : postSubB bodyM PRE_first_tail_x2_r0_body.ws8 PRE_first_tail_x2_r0_body.cws8 bodyQs8 = true
kernel_rfl bodyDrop8 : Nat.ble (11708 + (PRE_first_tail_x2_r0_body.s191.next - PRE_first_tail_x2_r0_body.s192.next)) 12857 = true
kernel_rfl bodyDropH8 : Nat.ble (175 + ((mlxOf PRE_first_tail_x2_r0_body.s191.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s192.ffi).next)) 200 = true
kernel_rfl bodyDropN8 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s191.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s192.ffi).nnext)) 0 = true
kernel_rfl bodyDv8 : bodyΘ.1.take 144 = bodyΘ.1.take 126 ++ PRE_first_tail_x2_r0_body.cws8
kernel_rfl bodyDe8 : bodyΘ.2.take 144 = bodyΘ.2.take 126 ++ PRE_first_tail_x2_r0_body.nr8.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st8.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 126) (bodyΘ.2.take 126)))
kernel_rfl bodyDl8 : (bodyΘ.1.take 126).length = (bodyΘ.2.take 126).length
kernel_rfl bodyDold8 : (bodyΘ.1.take 126).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws8).isNone && !PRE_first_tail_x2_r0_body.ws8.contains v) = true
kernel_rfl bodyDfree8 : (bodyΘ.2.take 144).all (fun e => (PRE_first_tail_x2_r0_body.cws8 ++ PRE_first_tail_x2_r0_body.ws8).all fun w => e.noVar w) = true

theorem bodyStep8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 126⟩ bodyM PRE_first_tail_x2_r0_body.s190 PRE_first_tail_x2_r0_body.S190)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 144⟩ bodyM PRE_first_tail_x2_r0_body.s192 PRE_first_tail_x2_r0_body.S192) (11334 + 1) :=
  bodySite bodyFacts8.cfix bodyFacts8.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st8.S5.tab) (Es := bodyEs8) (qs := bodyQs8)
    (ok := PRE_first_tail_x2_r0_body.st8.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site8 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts8
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site8 r hr) hi (MapOk.sub hm (sub_of_all bodySub8)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk8 r hr) hi hm ho hq)
    bodyLq8 rfl bodyNrLo8 (postSub_sound bodyPost8)
    (Nat.le_of_ble_eq_true bodyDrop8) (by decide) (Nat.le_of_ble_eq_true bodyDropH8) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN8) (by decide)
    bodyDv8 bodyDe8 bodyDl8 bodyDold8 bodyDfree8 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site9 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st9.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site9
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st9.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st9.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s212 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s213 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S212 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws9 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st9.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st9.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso9
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_9
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st9.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot9
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup9
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound9
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace9
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged9
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws9.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st9.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S212.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_9]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen9.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh9
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl9 : Conv.NClean (⟨18745, 15815, 2696381, 1213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s212.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl9 (PRE_first_tail_x2_r0_body.cncl8 bodyNcl8)

theorem bodyClean9 : Conv.JClean (⟨18745, 15815, 2696381, 1213⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s212 :=
  PRE_first_tail_x2_r0_body.gjcl9 (PRE_first_tail_x2_r0_body.cjcl8 bodyClean8)

kernel_rfl bodyJsLe9 : Nat.ble PRE_first_tail_x2_r0_body.s190.next PRE_first_tail_x2_r0_body.s212.next = true
kernel_rfl bodyJsList9 : (PRE_first_tail_x2_r0_body.gjh9 ++ PRE_first_tail_x2_r0_body.cl9).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s212.next) PRE_first_tail_x2_r0_body.s214) = true
theorem bodyJs9 : JsHeapAbove PRE_first_tail_x2_r0_body.s212.next PRE_first_tail_x2_r0_body.s214 :=
  JsHeapAbove.glueSite bodyJs8 (Nat.le_of_ble_eq_true bodyJsLe9) PRE_first_tail_x2_r0_body.gjk9 PRE_first_tail_x2_r0_body.gjbd9 PRE_first_tail_x2_r0_body.cheap9 PRE_first_tail_x2_r0_body.zclbd9 bodyJsList9

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO192 : PRE_first_tail_x2_r0_body.S192.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S192.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr192 : bridgeOf PRE_first_tail_x2_r0_body.s192.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc192 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s192 PRE_first_tail_x2_r0_body.S192) = fun _ _ => true
kernel_rfl bodyAcc193 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s193 PRE_first_tail_x2_r0_body.S193) = fun _ _ => true
kernel_rfl bodyBr194 : bridgeOf PRE_first_tail_x2_r0_body.s194.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt193 : isHalt PRE_first_tail_x2_r0_body.s193.ctl = false
kernel_rfl bodyTop194 : noRetBlock PRE_first_tail_x2_r0_body.s194 = true
kernel_rfl bodyCnt192 : countersOkB PRE_first_tail_x2_r0_body.s192 PRE_first_tail_x2_r0_body.s194 = true
kernel_rfl bodyO194 : PRE_first_tail_x2_r0_body.S194.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S194.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr195 : bridgeOf PRE_first_tail_x2_r0_body.s195.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt194 : countersOkB PRE_first_tail_x2_r0_body.s194 PRE_first_tail_x2_r0_body.s195 = true
kernel_rfl bodyO195 : PRE_first_tail_x2_r0_body.S195.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S195.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc195 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s195 PRE_first_tail_x2_r0_body.S195) = fun _ _ => true
kernel_rfl bodyAcc199 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s199 PRE_first_tail_x2_r0_body.S199) = fun _ _ => true
kernel_rfl bodyBr200 : bridgeOf PRE_first_tail_x2_r0_body.s200.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt199 : isHalt PRE_first_tail_x2_r0_body.s199.ctl = false
kernel_rfl bodyTop200 : noRetBlock PRE_first_tail_x2_r0_body.s200 = true
kernel_rfl bodyCnt195 : countersOkB PRE_first_tail_x2_r0_body.s195 PRE_first_tail_x2_r0_body.s200 = true
kernel_rfl bodyO200 : PRE_first_tail_x2_r0_body.S200.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S200.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr201 : bridgeOf PRE_first_tail_x2_r0_body.s201.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt200 : countersOkB PRE_first_tail_x2_r0_body.s200 PRE_first_tail_x2_r0_body.s201 = true
kernel_rfl bodyO201 : PRE_first_tail_x2_r0_body.S201.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S201.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc201 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s201 PRE_first_tail_x2_r0_body.S201) = fun _ _ => true
kernel_rfl bodyAcc202 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s202 PRE_first_tail_x2_r0_body.S202) = fun _ _ => true
kernel_rfl bodyBr203 : bridgeOf PRE_first_tail_x2_r0_body.s203.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt202 : isHalt PRE_first_tail_x2_r0_body.s202.ctl = false
kernel_rfl bodyTop203 : noRetBlock PRE_first_tail_x2_r0_body.s203 = true
kernel_rfl bodyCnt201 : countersOkB PRE_first_tail_x2_r0_body.s201 PRE_first_tail_x2_r0_body.s203 = true
kernel_rfl bodyO203 : PRE_first_tail_x2_r0_body.S203.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S203.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr204 : bridgeOf PRE_first_tail_x2_r0_body.s204.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt203 : countersOkB PRE_first_tail_x2_r0_body.s203 PRE_first_tail_x2_r0_body.s204 = true
kernel_rfl bodyO204 : PRE_first_tail_x2_r0_body.S204.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S204.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc204 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s204 PRE_first_tail_x2_r0_body.S204) = fun _ _ => true
kernel_rfl bodyAcc205 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s205 PRE_first_tail_x2_r0_body.S205) = fun _ _ => true
kernel_rfl bodyBr206 : bridgeOf PRE_first_tail_x2_r0_body.s206.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt205 : isHalt PRE_first_tail_x2_r0_body.s205.ctl = false
kernel_rfl bodyTop206 : noRetBlock PRE_first_tail_x2_r0_body.s206 = true
kernel_rfl bodyCnt204 : countersOkB PRE_first_tail_x2_r0_body.s204 PRE_first_tail_x2_r0_body.s206 = true
kernel_rfl bodyO206 : PRE_first_tail_x2_r0_body.S206.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S206.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr207 : bridgeOf PRE_first_tail_x2_r0_body.s207.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt206 : countersOkB PRE_first_tail_x2_r0_body.s206 PRE_first_tail_x2_r0_body.s207 = true
kernel_rfl bodyO207 : PRE_first_tail_x2_r0_body.S207.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S207.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc207 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s207 PRE_first_tail_x2_r0_body.S207) = fun _ _ => true
kernel_rfl bodyAcc208 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s208 PRE_first_tail_x2_r0_body.S208) = fun _ _ => true
kernel_rfl bodyBr209 : bridgeOf PRE_first_tail_x2_r0_body.s209.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt208 : isHalt PRE_first_tail_x2_r0_body.s208.ctl = false
kernel_rfl bodyTop209 : noRetBlock PRE_first_tail_x2_r0_body.s209 = true
kernel_rfl bodyCnt207 : countersOkB PRE_first_tail_x2_r0_body.s207 PRE_first_tail_x2_r0_body.s209 = true
kernel_rfl bodyO209 : PRE_first_tail_x2_r0_body.S209.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S209.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr210 : bridgeOf PRE_first_tail_x2_r0_body.s210.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt209 : countersOkB PRE_first_tail_x2_r0_body.s209 PRE_first_tail_x2_r0_body.s210 = true
kernel_rfl bodyO210 : PRE_first_tail_x2_r0_body.S210.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S210.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc210 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s210 PRE_first_tail_x2_r0_body.S210) = fun _ _ => true
kernel_rfl bodyAcc211 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s211 PRE_first_tail_x2_r0_body.S211) = fun _ _ => true
kernel_rfl bodyBr212 : bridgeOf PRE_first_tail_x2_r0_body.s212.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt211 : isHalt PRE_first_tail_x2_r0_body.s211.ctl = false
kernel_rfl bodyTop212 : noRetBlock PRE_first_tail_x2_r0_body.s212 = true
kernel_rfl bodyCnt210 : countersOkB PRE_first_tail_x2_r0_body.s210 PRE_first_tail_x2_r0_body.s212 = true

theorem bodyGlue9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 144⟩ bodyM PRE_first_tail_x2_r0_body.s192 PRE_first_tail_x2_r0_body.S192)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 144⟩ bodyM PRE_first_tail_x2_r0_body.s212 PRE_first_tail_x2_r0_body.S212) 22217 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc192 PRE_first_tail_x2_r0_body.bodyRunSeg51 bodyAcc193 bodyHalt193 PRE_first_tail_x2_r0_body.bodyStepA52 bodyTop194 (fun _ hm => bodyO192 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr192).trans bodyInactive0) (bodyBr194.trans bodyBr192.symm) bodyCnt192 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x2_r0_body.sizeA52 PRE_first_tail_x2_r0_body.sizeArgsA52 PRE_first_tail_x2_r0_body.sizeSymA52 PRE_first_tail_x2_r0_body.sizeMlxA52 PRE_first_tail_x2_r0_body.sizePayA52 PRE_first_tail_x2_r0_body.sizeTaA52 PRE_first_tail_x2_r0_body.sizeDecA52 PRE_first_tail_x2_r0_body.sizePreA52 PRE_first_tail_x2_r0_body.bodyPatchB52 (fun _ hm => bodyO194 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr194).trans bodyInactive0) (bodyBr195.trans bodyBr194.symm) bodyCnt194 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc195 PRE_first_tail_x2_r0_body.bodyRunSeg52 bodyAcc199 bodyHalt199 PRE_first_tail_x2_r0_body.bodyStepA53 bodyTop200 (fun _ hm => bodyO195 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr195).trans bodyInactive0) (bodyBr200.trans bodyBr195.symm) bodyCnt195 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x2_r0_body.sizeA53 PRE_first_tail_x2_r0_body.sizeArgsA53 PRE_first_tail_x2_r0_body.sizeSymA53 PRE_first_tail_x2_r0_body.sizeMlxA53 PRE_first_tail_x2_r0_body.sizePayA53 PRE_first_tail_x2_r0_body.sizeTaA53 PRE_first_tail_x2_r0_body.sizeDecA53 PRE_first_tail_x2_r0_body.sizePreA53 PRE_first_tail_x2_r0_body.bodyPatchB53 (fun _ hm => bodyO200 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr200).trans bodyInactive0) (bodyBr201.trans bodyBr200.symm) bodyCnt200 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc201 PRE_first_tail_x2_r0_body.bodyRunSeg53 bodyAcc202 bodyHalt202 PRE_first_tail_x2_r0_body.bodyStepA54 bodyTop203 (fun _ hm => bodyO201 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr201).trans bodyInactive0) (bodyBr203.trans bodyBr201.symm) bodyCnt201 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x2_r0_body.sizeA54 PRE_first_tail_x2_r0_body.sizeArgsA54 PRE_first_tail_x2_r0_body.sizeSymA54 PRE_first_tail_x2_r0_body.sizeMlxA54 PRE_first_tail_x2_r0_body.sizePayA54 PRE_first_tail_x2_r0_body.sizeTaA54 PRE_first_tail_x2_r0_body.sizeDecA54 PRE_first_tail_x2_r0_body.sizePreA54 PRE_first_tail_x2_r0_body.bodyPatchB54 (fun _ hm => bodyO203 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr203).trans bodyInactive0) (bodyBr204.trans bodyBr203.symm) bodyCnt203 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc204 PRE_first_tail_x2_r0_body.bodyRunSeg54 bodyAcc205 bodyHalt205 PRE_first_tail_x2_r0_body.bodyStepA55 bodyTop206 (fun _ hm => bodyO204 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr204).trans bodyInactive0) (bodyBr206.trans bodyBr204.symm) bodyCnt204 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x2_r0_body.sizeA55 PRE_first_tail_x2_r0_body.sizeArgsA55 PRE_first_tail_x2_r0_body.sizeSymA55 PRE_first_tail_x2_r0_body.sizeMlxA55 PRE_first_tail_x2_r0_body.sizePayA55 PRE_first_tail_x2_r0_body.sizeTaA55 PRE_first_tail_x2_r0_body.sizeDecA55 PRE_first_tail_x2_r0_body.sizePreA55 PRE_first_tail_x2_r0_body.bodyPatchB55 (fun _ hm => bodyO206 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr206).trans bodyInactive0) (bodyBr207.trans bodyBr206.symm) bodyCnt206 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc207 PRE_first_tail_x2_r0_body.bodyRunSeg55 bodyAcc208 bodyHalt208 PRE_first_tail_x2_r0_body.bodyStepA56 bodyTop209 (fun _ hm => bodyO207 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr207).trans bodyInactive0) (bodyBr209.trans bodyBr207.symm) bodyCnt207 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) PRE_first_tail_x2_r0_body.sizeA56 PRE_first_tail_x2_r0_body.sizeArgsA56 PRE_first_tail_x2_r0_body.sizeSymA56 PRE_first_tail_x2_r0_body.sizeMlxA56 PRE_first_tail_x2_r0_body.sizePayA56 PRE_first_tail_x2_r0_body.sizeTaA56 PRE_first_tail_x2_r0_body.sizeDecA56 PRE_first_tail_x2_r0_body.sizePreA56 PRE_first_tail_x2_r0_body.bodyPatchB56 (fun _ hm => bodyO209 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr209).trans bodyInactive0) (bodyBr210.trans bodyBr209.symm) bodyCnt209 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 144⟩) bodyAcc210 PRE_first_tail_x2_r0_body.bodyRunSeg56 bodyAcc211 bodyHalt211 PRE_first_tail_x2_r0_body.bodyStepA57 bodyTop212 (fun _ hm => bodyO210 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr210).trans bodyInactive0) (bodyBr212.trans bodyBr210.symm) bodyCnt210 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift9 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S212.tab.length PRE_first_tail_x2_r0_body.s212.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P9.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P9 1231 PRE_first_tail_x2_r0_body.kappa9 PRE_first_tail_x2_r0_body.s214.ffi PRE_first_tail_x2_r0_body.s213.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_9
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_9
  have hcl : SSt (· < 1231) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s214.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S212.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_9] <;> decide) PRE_first_tail_x2_r0_body.cnodesK9 PRE_first_tail_x2_r0_body.cobjsK9
      PRE_first_tail_x2_r0_body.citemsK9 PRE_first_tail_x2_r0_body.cbd9 PRE_first_tail_x2_r0_body.csst9
  exact PRE_first_tail_x2_r0_body.cshift9 bodyNcl9 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_9] at this; exact this)


kernel_rfl bodyFramesEmpty9 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s213 a).isEmpty) = true
kernel_rfl bodyJsRoots9 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s212.next) PRE_first_tail_x2_r0_body.s214.trace PRE_first_tail_x2_r0_body.s214 = true
kernel_rfl bodyJsNative9 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s214.ffi) = true
kernel_rfl bodyLow9 : (PRE_first_tail_x2_r0_body.cws9 ++ PRE_first_tail_x2_r0_body.ws9).all (Nat.ble 9) = true
kernel_rfl bodyCntM9 : countersOkB PRE_first_tail_x2_r0_body.s212 PRE_first_tail_x2_r0_body.s213 = true
kernel_rfl bodyHi9 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s214.ffi).next setupP.E = true
kernel_rfl bodyNhi9 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s214.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge9 : bridgeOf PRE_first_tail_x2_r0_body.s213.ffi = bridgeOf PRE_first_tail_x2_r0_body.s212.ffi
kernel_rfl bodyNN9 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s212.ffi).nnext PRE_first_tail_x2_r0_body.P9.NL = true
kernel_rfl bodyXn9 : Nat.ble (⟨18748, 15842, 2696387, 1231⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s214.ffi).next = true
kernel_rfl bodyLo9 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s214.ffi).next = true
theorem bodyFacts9 : BodySiteFacts PRE_first_tail_x2_r0_body.s212 PRE_first_tail_x2_r0_body.s213 PRE_first_tail_x2_r0_body.s214 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S212 PRE_first_tail_x2_r0_body.S213 PRE_first_tail_x2_r0_body.S214
    PRE_first_tail_x2_r0_body.ws9 PRE_first_tail_x2_r0_body.cws9 PRE_first_tail_x2_r0_body.nr9 PRE_first_tail_x2_r0_body.pl9 PRE_first_tail_x2_r0_body.cl9 2697536 1231 PRE_first_tail_x2_r0_body.kd9 PRE_first_tail_x2_r0_body.kappa9 PRE_first_tail_x2_r0_body.P9
    ⟨18745, 15815, 2696381, 1213⟩ ⟨18748, 15842, 2696387, 1231⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap9
  clean := bodyClean9
  cfix := PRE_first_tail_x2_r0_body.cfix9
  zpl := PRE_first_tail_x2_r0_body.zpl9
  zplnd := PRE_first_tail_x2_r0_body.zplnd9
  zn1 := PRE_first_tail_x2_r0_body.zn19
  zfirst := PRE_first_tail_x2_r0_body.zfirst9
  zscn := PRE_first_tail_x2_r0_body.zscn9
  zsmn := PRE_first_tail_x2_r0_body.zsmn9
  zgrow := PRE_first_tail_x2_r0_body.zgrow9
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab9
  zfresh := PRE_first_tail_x2_r0_body.zfresh9
  zcnd := PRE_first_tail_x2_r0_body.zcnd9
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi9
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt9
  zgP := PRE_first_tail_x2_r0_body.zg9_2665
  zkP := PRE_first_tail_x2_r0_body.zk9_2665
  zmP := PRE_first_tail_x2_r0_body.zm9_2665
  zgC := PRE_first_tail_x2_r0_body.zg9_2673467
  zkC := PRE_first_tail_x2_r0_body.zk9_2673467
  zmC := PRE_first_tail_x2_r0_body.zm9_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw9_2673472
  zwV := PRE_first_tail_x2_r0_body.zw9_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap9
  zclbd := PRE_first_tail_x2_r0_body.zclbd9
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap9 PRE_first_tail_x2_r0_body.stFoot9 PRE_first_tail_x2_r0_body.iso9 PRE_first_tail_x2_r0_body.zwr9
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP9
  csupp := PRE_first_tail_x2_r0_body.csupp9
  cbound := PRE_first_tail_x2_r0_body.cbound9
  zimg := PRE_first_tail_x2_r0_body.zimg9
  zctl := PRE_first_tail_x2_r0_body.zctl9
  zstack := PRE_first_tail_x2_r0_body.zstack9
  zjobs := PRE_first_tail_x2_r0_body.zjobs9
  zstores := PRE_first_tail_x2_r0_body.zstores9
  zroots := PRE_first_tail_x2_r0_body.zroots9
  znC := PRE_first_tail_x2_r0_body.znC9
  ctab := PRE_first_tail_x2_r0_body.ctab9
  zbin := PRE_first_tail_x2_r0_body.zbin9
  cbridge := PRE_first_tail_x2_r0_body.cbridge9
  sbridge := bodyBridge9
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj9
  cshiftR := fun h hNL => bodyCshift9 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN9
  raised := PRE_first_tail_x2_r0_body.raised9
  cbigs := PRE_first_tail_x2_r0_body.cbigs9
  cjcl := PRE_first_tail_x2_r0_body.cjcl9
  xnLe := Nat.le_of_ble_eq_true bodyXn9
  loLe := Nat.le_of_ble_eq_true bodyLo9
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB9
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
noncomputable def bodyEs9 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr9.map fun r => nth? PRE_first_tail_x2_r0_body.st9.S5.tab r
kernel_rfl bodyResChk9 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs9 bodyQs9) = true
kernel_rfl bodyLq9 : bodyQs9.length = PRE_first_tail_x2_r0_body.cws9.length
kernel_rfl bodyNrLo9 : PRE_first_tail_x2_r0_body.nr9.all (Nat.ble PRE_first_tail_x2_r0_body.S212.tab.length) = true
kernel_rfl bodySub9 : (Oracles.PRE_first_tail_x2_r0_body.map_site9.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost9 : postSubB bodyM PRE_first_tail_x2_r0_body.ws9 PRE_first_tail_x2_r0_body.cws9 bodyQs9 = true
kernel_rfl bodyDrop9 : Nat.ble (12857 + (PRE_first_tail_x2_r0_body.s213.next - PRE_first_tail_x2_r0_body.s214.next)) 14006 = true
kernel_rfl bodyDropH9 : Nat.ble (200 + ((mlxOf PRE_first_tail_x2_r0_body.s213.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s214.ffi).next)) 225 = true
kernel_rfl bodyDropN9 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s213.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s214.ffi).nnext)) 0 = true
kernel_rfl bodyDv9 : bodyΘ.1.take 162 = bodyΘ.1.take 144 ++ PRE_first_tail_x2_r0_body.cws9
kernel_rfl bodyDe9 : bodyΘ.2.take 162 = bodyΘ.2.take 144 ++ PRE_first_tail_x2_r0_body.nr9.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st9.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 144) (bodyΘ.2.take 144)))
kernel_rfl bodyDl9 : (bodyΘ.1.take 144).length = (bodyΘ.2.take 144).length
kernel_rfl bodyDold9 : (bodyΘ.1.take 144).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws9).isNone && !PRE_first_tail_x2_r0_body.ws9.contains v) = true
kernel_rfl bodyDfree9 : (bodyΘ.2.take 162).all (fun e => (PRE_first_tail_x2_r0_body.cws9 ++ PRE_first_tail_x2_r0_body.ws9).all fun w => e.noVar w) = true

theorem bodyStep9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 144⟩ bodyM PRE_first_tail_x2_r0_body.s212 PRE_first_tail_x2_r0_body.S212)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 162⟩ bodyM PRE_first_tail_x2_r0_body.s214 PRE_first_tail_x2_r0_body.S214) (11334 + 1) :=
  bodySite bodyFacts9.cfix bodyFacts9.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st9.S5.tab) (Es := bodyEs9) (qs := bodyQs9)
    (ok := PRE_first_tail_x2_r0_body.st9.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site9 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts9
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site9 r hr) hi (MapOk.sub hm (sub_of_all bodySub9)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk9 r hr) hi hm ho hq)
    bodyLq9 rfl bodyNrLo9 (postSub_sound bodyPost9)
    (Nat.le_of_ble_eq_true bodyDrop9) (by decide) (Nat.le_of_ble_eq_true bodyDropH9) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN9) (by decide)
    bodyDv9 bodyDe9 bodyDl9 bodyDold9 bodyDfree9 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site10 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site10) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st10.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site10
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st10.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st10.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s234 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s235 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S234 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws10 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st10.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st10.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso10
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_10
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st10.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot10
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup10
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound10
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace10
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged10
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws10.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st10.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S234.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_10]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen10.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh10
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl10 : Conv.NClean (⟨18802, 15878, 2698619, 1339⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s234.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl10 (PRE_first_tail_x2_r0_body.cncl9 bodyNcl9)

theorem bodyClean10 : Conv.JClean (⟨18802, 15878, 2698619, 1339⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s234 :=
  PRE_first_tail_x2_r0_body.gjcl10 (PRE_first_tail_x2_r0_body.cjcl9 bodyClean9)

kernel_rfl bodyJsLe10 : Nat.ble PRE_first_tail_x2_r0_body.s212.next PRE_first_tail_x2_r0_body.s234.next = true
kernel_rfl bodyJsList10 : (PRE_first_tail_x2_r0_body.gjh10 ++ PRE_first_tail_x2_r0_body.cl10).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s234.next) PRE_first_tail_x2_r0_body.s236) = true
theorem bodyJs10 : JsHeapAbove PRE_first_tail_x2_r0_body.s234.next PRE_first_tail_x2_r0_body.s236 :=
  JsHeapAbove.glueSite bodyJs9 (Nat.le_of_ble_eq_true bodyJsLe10) PRE_first_tail_x2_r0_body.gjk10 PRE_first_tail_x2_r0_body.gjbd10 PRE_first_tail_x2_r0_body.cheap10 PRE_first_tail_x2_r0_body.zclbd10 bodyJsList10

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO214 : PRE_first_tail_x2_r0_body.S214.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S214.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr214 : bridgeOf PRE_first_tail_x2_r0_body.s214.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc214 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s214 PRE_first_tail_x2_r0_body.S214) = fun _ _ => true
kernel_rfl bodyAcc215 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s215 PRE_first_tail_x2_r0_body.S215) = fun _ _ => true
kernel_rfl bodyBr216 : bridgeOf PRE_first_tail_x2_r0_body.s216.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt215 : isHalt PRE_first_tail_x2_r0_body.s215.ctl = false
kernel_rfl bodyTop216 : noRetBlock PRE_first_tail_x2_r0_body.s216 = true
kernel_rfl bodyCnt214 : countersOkB PRE_first_tail_x2_r0_body.s214 PRE_first_tail_x2_r0_body.s216 = true
kernel_rfl bodyO216 : PRE_first_tail_x2_r0_body.S216.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S216.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr217 : bridgeOf PRE_first_tail_x2_r0_body.s217.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt216 : countersOkB PRE_first_tail_x2_r0_body.s216 PRE_first_tail_x2_r0_body.s217 = true
kernel_rfl bodyO217 : PRE_first_tail_x2_r0_body.S217.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S217.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc217 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s217 PRE_first_tail_x2_r0_body.S217) = fun _ _ => true
kernel_rfl bodyAcc221 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s221 PRE_first_tail_x2_r0_body.S221) = fun _ _ => true
kernel_rfl bodyBr222 : bridgeOf PRE_first_tail_x2_r0_body.s222.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt221 : isHalt PRE_first_tail_x2_r0_body.s221.ctl = false
kernel_rfl bodyTop222 : noRetBlock PRE_first_tail_x2_r0_body.s222 = true
kernel_rfl bodyCnt217 : countersOkB PRE_first_tail_x2_r0_body.s217 PRE_first_tail_x2_r0_body.s222 = true
kernel_rfl bodyO222 : PRE_first_tail_x2_r0_body.S222.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S222.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr223 : bridgeOf PRE_first_tail_x2_r0_body.s223.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt222 : countersOkB PRE_first_tail_x2_r0_body.s222 PRE_first_tail_x2_r0_body.s223 = true
kernel_rfl bodyO223 : PRE_first_tail_x2_r0_body.S223.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S223.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc223 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s223 PRE_first_tail_x2_r0_body.S223) = fun _ _ => true
kernel_rfl bodyAcc224 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s224 PRE_first_tail_x2_r0_body.S224) = fun _ _ => true
kernel_rfl bodyBr225 : bridgeOf PRE_first_tail_x2_r0_body.s225.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt224 : isHalt PRE_first_tail_x2_r0_body.s224.ctl = false
kernel_rfl bodyTop225 : noRetBlock PRE_first_tail_x2_r0_body.s225 = true
kernel_rfl bodyCnt223 : countersOkB PRE_first_tail_x2_r0_body.s223 PRE_first_tail_x2_r0_body.s225 = true
kernel_rfl bodyO225 : PRE_first_tail_x2_r0_body.S225.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S225.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr226 : bridgeOf PRE_first_tail_x2_r0_body.s226.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt225 : countersOkB PRE_first_tail_x2_r0_body.s225 PRE_first_tail_x2_r0_body.s226 = true
kernel_rfl bodyO226 : PRE_first_tail_x2_r0_body.S226.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S226.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc226 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s226 PRE_first_tail_x2_r0_body.S226) = fun _ _ => true
kernel_rfl bodyAcc227 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s227 PRE_first_tail_x2_r0_body.S227) = fun _ _ => true
kernel_rfl bodyBr228 : bridgeOf PRE_first_tail_x2_r0_body.s228.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt227 : isHalt PRE_first_tail_x2_r0_body.s227.ctl = false
kernel_rfl bodyTop228 : noRetBlock PRE_first_tail_x2_r0_body.s228 = true
kernel_rfl bodyCnt226 : countersOkB PRE_first_tail_x2_r0_body.s226 PRE_first_tail_x2_r0_body.s228 = true
kernel_rfl bodyO228 : PRE_first_tail_x2_r0_body.S228.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S228.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr229 : bridgeOf PRE_first_tail_x2_r0_body.s229.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt228 : countersOkB PRE_first_tail_x2_r0_body.s228 PRE_first_tail_x2_r0_body.s229 = true
kernel_rfl bodyO229 : PRE_first_tail_x2_r0_body.S229.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S229.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc229 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s229 PRE_first_tail_x2_r0_body.S229) = fun _ _ => true
kernel_rfl bodyAcc230 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s230 PRE_first_tail_x2_r0_body.S230) = fun _ _ => true
kernel_rfl bodyBr231 : bridgeOf PRE_first_tail_x2_r0_body.s231.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt230 : isHalt PRE_first_tail_x2_r0_body.s230.ctl = false
kernel_rfl bodyTop231 : noRetBlock PRE_first_tail_x2_r0_body.s231 = true
kernel_rfl bodyCnt229 : countersOkB PRE_first_tail_x2_r0_body.s229 PRE_first_tail_x2_r0_body.s231 = true
kernel_rfl bodyO231 : PRE_first_tail_x2_r0_body.S231.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S231.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr232 : bridgeOf PRE_first_tail_x2_r0_body.s232.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt231 : countersOkB PRE_first_tail_x2_r0_body.s231 PRE_first_tail_x2_r0_body.s232 = true
kernel_rfl bodyO232 : PRE_first_tail_x2_r0_body.S232.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S232.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc232 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s232 PRE_first_tail_x2_r0_body.S232) = fun _ _ => true
kernel_rfl bodyAcc233 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s233 PRE_first_tail_x2_r0_body.S233) = fun _ _ => true
kernel_rfl bodyBr234 : bridgeOf PRE_first_tail_x2_r0_body.s234.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt233 : isHalt PRE_first_tail_x2_r0_body.s233.ctl = false
kernel_rfl bodyTop234 : noRetBlock PRE_first_tail_x2_r0_body.s234 = true
kernel_rfl bodyCnt232 : countersOkB PRE_first_tail_x2_r0_body.s232 PRE_first_tail_x2_r0_body.s234 = true

theorem bodyGlue10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 162⟩ bodyM PRE_first_tail_x2_r0_body.s214 PRE_first_tail_x2_r0_body.S214)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 162⟩ bodyM PRE_first_tail_x2_r0_body.s234 PRE_first_tail_x2_r0_body.S234) 22217 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc214 PRE_first_tail_x2_r0_body.bodyRunSeg57 bodyAcc215 bodyHalt215 PRE_first_tail_x2_r0_body.bodyStepA58 bodyTop216 (fun _ hm => bodyO214 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr214).trans bodyInactive0) (bodyBr216.trans bodyBr214.symm) bodyCnt214 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x2_r0_body.sizeA58 PRE_first_tail_x2_r0_body.sizeArgsA58 PRE_first_tail_x2_r0_body.sizeSymA58 PRE_first_tail_x2_r0_body.sizeMlxA58 PRE_first_tail_x2_r0_body.sizePayA58 PRE_first_tail_x2_r0_body.sizeTaA58 PRE_first_tail_x2_r0_body.sizeDecA58 PRE_first_tail_x2_r0_body.sizePreA58 PRE_first_tail_x2_r0_body.bodyPatchB58 (fun _ hm => bodyO216 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr216).trans bodyInactive0) (bodyBr217.trans bodyBr216.symm) bodyCnt216 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc217 PRE_first_tail_x2_r0_body.bodyRunSeg58 bodyAcc221 bodyHalt221 PRE_first_tail_x2_r0_body.bodyStepA59 bodyTop222 (fun _ hm => bodyO217 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr217).trans bodyInactive0) (bodyBr222.trans bodyBr217.symm) bodyCnt217 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x2_r0_body.sizeA59 PRE_first_tail_x2_r0_body.sizeArgsA59 PRE_first_tail_x2_r0_body.sizeSymA59 PRE_first_tail_x2_r0_body.sizeMlxA59 PRE_first_tail_x2_r0_body.sizePayA59 PRE_first_tail_x2_r0_body.sizeTaA59 PRE_first_tail_x2_r0_body.sizeDecA59 PRE_first_tail_x2_r0_body.sizePreA59 PRE_first_tail_x2_r0_body.bodyPatchB59 (fun _ hm => bodyO222 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr222).trans bodyInactive0) (bodyBr223.trans bodyBr222.symm) bodyCnt222 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc223 PRE_first_tail_x2_r0_body.bodyRunSeg59 bodyAcc224 bodyHalt224 PRE_first_tail_x2_r0_body.bodyStepA60 bodyTop225 (fun _ hm => bodyO223 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr223).trans bodyInactive0) (bodyBr225.trans bodyBr223.symm) bodyCnt223 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x2_r0_body.sizeA60 PRE_first_tail_x2_r0_body.sizeArgsA60 PRE_first_tail_x2_r0_body.sizeSymA60 PRE_first_tail_x2_r0_body.sizeMlxA60 PRE_first_tail_x2_r0_body.sizePayA60 PRE_first_tail_x2_r0_body.sizeTaA60 PRE_first_tail_x2_r0_body.sizeDecA60 PRE_first_tail_x2_r0_body.sizePreA60 PRE_first_tail_x2_r0_body.bodyPatchB60 (fun _ hm => bodyO225 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr225).trans bodyInactive0) (bodyBr226.trans bodyBr225.symm) bodyCnt225 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc226 PRE_first_tail_x2_r0_body.bodyRunSeg60 bodyAcc227 bodyHalt227 PRE_first_tail_x2_r0_body.bodyStepA61 bodyTop228 (fun _ hm => bodyO226 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr226).trans bodyInactive0) (bodyBr228.trans bodyBr226.symm) bodyCnt226 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x2_r0_body.sizeA61 PRE_first_tail_x2_r0_body.sizeArgsA61 PRE_first_tail_x2_r0_body.sizeSymA61 PRE_first_tail_x2_r0_body.sizeMlxA61 PRE_first_tail_x2_r0_body.sizePayA61 PRE_first_tail_x2_r0_body.sizeTaA61 PRE_first_tail_x2_r0_body.sizeDecA61 PRE_first_tail_x2_r0_body.sizePreA61 PRE_first_tail_x2_r0_body.bodyPatchB61 (fun _ hm => bodyO228 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr228).trans bodyInactive0) (bodyBr229.trans bodyBr228.symm) bodyCnt228 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc229 PRE_first_tail_x2_r0_body.bodyRunSeg61 bodyAcc230 bodyHalt230 PRE_first_tail_x2_r0_body.bodyStepA62 bodyTop231 (fun _ hm => bodyO229 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr229).trans bodyInactive0) (bodyBr231.trans bodyBr229.symm) bodyCnt229 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) PRE_first_tail_x2_r0_body.sizeA62 PRE_first_tail_x2_r0_body.sizeArgsA62 PRE_first_tail_x2_r0_body.sizeSymA62 PRE_first_tail_x2_r0_body.sizeMlxA62 PRE_first_tail_x2_r0_body.sizePayA62 PRE_first_tail_x2_r0_body.sizeTaA62 PRE_first_tail_x2_r0_body.sizeDecA62 PRE_first_tail_x2_r0_body.sizePreA62 PRE_first_tail_x2_r0_body.bodyPatchB62 (fun _ hm => bodyO231 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr231).trans bodyInactive0) (bodyBr232.trans bodyBr231.symm) bodyCnt231 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 162⟩) bodyAcc232 PRE_first_tail_x2_r0_body.bodyRunSeg62 bodyAcc233 bodyHalt233 PRE_first_tail_x2_r0_body.bodyStepA63 bodyTop234 (fun _ hm => bodyO232 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr232).trans bodyInactive0) (bodyBr234.trans bodyBr232.symm) bodyCnt232 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift10 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S234.tab.length PRE_first_tail_x2_r0_body.s234.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P10.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P10 1357 PRE_first_tail_x2_r0_body.kappa10 PRE_first_tail_x2_r0_body.s236.ffi PRE_first_tail_x2_r0_body.s235.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_10
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_10
  have hcl : SSt (· < 1357) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s236.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S234.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_10] <;> decide) PRE_first_tail_x2_r0_body.cnodesK10 PRE_first_tail_x2_r0_body.cobjsK10
      PRE_first_tail_x2_r0_body.citemsK10 PRE_first_tail_x2_r0_body.cbd10 PRE_first_tail_x2_r0_body.csst10
  exact PRE_first_tail_x2_r0_body.cshift10 bodyNcl10 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_10] at this; exact this)


kernel_rfl bodyFramesEmpty10 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s235 a).isEmpty) = true
kernel_rfl bodyJsRoots10 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s234.next) PRE_first_tail_x2_r0_body.s236.trace PRE_first_tail_x2_r0_body.s236 = true
kernel_rfl bodyJsNative10 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s236.ffi) = true
kernel_rfl bodyLow10 : (PRE_first_tail_x2_r0_body.cws10 ++ PRE_first_tail_x2_r0_body.ws10).all (Nat.ble 9) = true
kernel_rfl bodyCntM10 : countersOkB PRE_first_tail_x2_r0_body.s234 PRE_first_tail_x2_r0_body.s235 = true
kernel_rfl bodyHi10 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s236.ffi).next setupP.E = true
kernel_rfl bodyNhi10 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s236.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge10 : bridgeOf PRE_first_tail_x2_r0_body.s235.ffi = bridgeOf PRE_first_tail_x2_r0_body.s234.ffi
kernel_rfl bodyNN10 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s234.ffi).nnext PRE_first_tail_x2_r0_body.P10.NL = true
kernel_rfl bodyXn10 : Nat.ble (⟨18805, 15905, 2698625, 1357⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s236.ffi).next = true
kernel_rfl bodyLo10 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s236.ffi).next = true
theorem bodyFacts10 : BodySiteFacts PRE_first_tail_x2_r0_body.s234 PRE_first_tail_x2_r0_body.s235 PRE_first_tail_x2_r0_body.s236 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S234 PRE_first_tail_x2_r0_body.S235 PRE_first_tail_x2_r0_body.S236
    PRE_first_tail_x2_r0_body.ws10 PRE_first_tail_x2_r0_body.cws10 PRE_first_tail_x2_r0_body.nr10 PRE_first_tail_x2_r0_body.pl10 PRE_first_tail_x2_r0_body.cl10 2699774 1357 PRE_first_tail_x2_r0_body.kd10 PRE_first_tail_x2_r0_body.kappa10 PRE_first_tail_x2_r0_body.P10
    ⟨18802, 15878, 2698619, 1339⟩ ⟨18805, 15905, 2698625, 1357⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap10
  clean := bodyClean10
  cfix := PRE_first_tail_x2_r0_body.cfix10
  zpl := PRE_first_tail_x2_r0_body.zpl10
  zplnd := PRE_first_tail_x2_r0_body.zplnd10
  zn1 := PRE_first_tail_x2_r0_body.zn110
  zfirst := PRE_first_tail_x2_r0_body.zfirst10
  zscn := PRE_first_tail_x2_r0_body.zscn10
  zsmn := PRE_first_tail_x2_r0_body.zsmn10
  zgrow := PRE_first_tail_x2_r0_body.zgrow10
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab10
  zfresh := PRE_first_tail_x2_r0_body.zfresh10
  zcnd := PRE_first_tail_x2_r0_body.zcnd10
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi10
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt10
  zgP := PRE_first_tail_x2_r0_body.zg10_2665
  zkP := PRE_first_tail_x2_r0_body.zk10_2665
  zmP := PRE_first_tail_x2_r0_body.zm10_2665
  zgC := PRE_first_tail_x2_r0_body.zg10_2673467
  zkC := PRE_first_tail_x2_r0_body.zk10_2673467
  zmC := PRE_first_tail_x2_r0_body.zm10_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw10_2673472
  zwV := PRE_first_tail_x2_r0_body.zw10_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap10
  zclbd := PRE_first_tail_x2_r0_body.zclbd10
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap10 PRE_first_tail_x2_r0_body.stFoot10 PRE_first_tail_x2_r0_body.iso10 PRE_first_tail_x2_r0_body.zwr10
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP10
  csupp := PRE_first_tail_x2_r0_body.csupp10
  cbound := PRE_first_tail_x2_r0_body.cbound10
  zimg := PRE_first_tail_x2_r0_body.zimg10
  zctl := PRE_first_tail_x2_r0_body.zctl10
  zstack := PRE_first_tail_x2_r0_body.zstack10
  zjobs := PRE_first_tail_x2_r0_body.zjobs10
  zstores := PRE_first_tail_x2_r0_body.zstores10
  zroots := PRE_first_tail_x2_r0_body.zroots10
  znC := PRE_first_tail_x2_r0_body.znC10
  ctab := PRE_first_tail_x2_r0_body.ctab10
  zbin := PRE_first_tail_x2_r0_body.zbin10
  cbridge := PRE_first_tail_x2_r0_body.cbridge10
  sbridge := bodyBridge10
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj10
  cshiftR := fun h hNL => bodyCshift10 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN10
  raised := PRE_first_tail_x2_r0_body.raised10
  cbigs := PRE_first_tail_x2_r0_body.cbigs10
  cjcl := PRE_first_tail_x2_r0_body.cjcl10
  xnLe := Nat.le_of_ble_eq_true bodyXn10
  loLe := Nat.le_of_ble_eq_true bodyLo10
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB10
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
noncomputable def bodyEs10 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr10.map fun r => nth? PRE_first_tail_x2_r0_body.st10.S5.tab r
kernel_rfl bodyResChk10 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs10 bodyQs10) = true
kernel_rfl bodyLq10 : bodyQs10.length = PRE_first_tail_x2_r0_body.cws10.length
kernel_rfl bodyNrLo10 : PRE_first_tail_x2_r0_body.nr10.all (Nat.ble PRE_first_tail_x2_r0_body.S234.tab.length) = true
kernel_rfl bodySub10 : (Oracles.PRE_first_tail_x2_r0_body.map_site10.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost10 : postSubB bodyM PRE_first_tail_x2_r0_body.ws10 PRE_first_tail_x2_r0_body.cws10 bodyQs10 = true
kernel_rfl bodyDrop10 : Nat.ble (14006 + (PRE_first_tail_x2_r0_body.s235.next - PRE_first_tail_x2_r0_body.s236.next)) 15155 = true
kernel_rfl bodyDropH10 : Nat.ble (225 + ((mlxOf PRE_first_tail_x2_r0_body.s235.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s236.ffi).next)) 250 = true
kernel_rfl bodyDropN10 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s235.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s236.ffi).nnext)) 0 = true
kernel_rfl bodyDv10 : bodyΘ.1.take 180 = bodyΘ.1.take 162 ++ PRE_first_tail_x2_r0_body.cws10
kernel_rfl bodyDe10 : bodyΘ.2.take 180 = bodyΘ.2.take 162 ++ PRE_first_tail_x2_r0_body.nr10.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st10.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 162) (bodyΘ.2.take 162)))
kernel_rfl bodyDl10 : (bodyΘ.1.take 162).length = (bodyΘ.2.take 162).length
kernel_rfl bodyDold10 : (bodyΘ.1.take 162).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws10).isNone && !PRE_first_tail_x2_r0_body.ws10.contains v) = true
kernel_rfl bodyDfree10 : (bodyΘ.2.take 180).all (fun e => (PRE_first_tail_x2_r0_body.cws10 ++ PRE_first_tail_x2_r0_body.ws10).all fun w => e.noVar w) = true

theorem bodyStep10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 162⟩ bodyM PRE_first_tail_x2_r0_body.s234 PRE_first_tail_x2_r0_body.S234)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 180⟩ bodyM PRE_first_tail_x2_r0_body.s236 PRE_first_tail_x2_r0_body.S236) (11334 + 1) :=
  bodySite bodyFacts10.cfix bodyFacts10.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st10.S5.tab) (Es := bodyEs10) (qs := bodyQs10)
    (ok := PRE_first_tail_x2_r0_body.st10.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site10 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts10
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site10 r hr) hi (MapOk.sub hm (sub_of_all bodySub10)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk10 r hr) hi hm ho hq)
    bodyLq10 rfl bodyNrLo10 (postSub_sound bodyPost10)
    (Nat.le_of_ble_eq_true bodyDrop10) (by decide) (Nat.le_of_ble_eq_true bodyDropH10) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN10) (by decide)
    bodyDv10 bodyDe10 bodyDl10 bodyDold10 bodyDfree10 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site11 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site11 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site11) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st11.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site11
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st11.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st11.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s255 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s256 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S255 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws11 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st11.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st11.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso11
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_11
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st11.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot11
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup11
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound11
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace11
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged11
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws11.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st11.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S255.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_11]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen11.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh11
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl11 : Conv.NClean (⟨18865, 15950, 2701122, 1469⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s255.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl11 (PRE_first_tail_x2_r0_body.cncl10 bodyNcl10)

theorem bodyClean11 : Conv.JClean (⟨18865, 15950, 2701122, 1469⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s255 :=
  PRE_first_tail_x2_r0_body.gjcl11 (PRE_first_tail_x2_r0_body.cjcl10 bodyClean10)

kernel_rfl bodyJsLe11 : Nat.ble PRE_first_tail_x2_r0_body.s234.next PRE_first_tail_x2_r0_body.s255.next = true
kernel_rfl bodyJsList11 : (PRE_first_tail_x2_r0_body.gjh11 ++ PRE_first_tail_x2_r0_body.cl11).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s255.next) PRE_first_tail_x2_r0_body.s257) = true
theorem bodyJs11 : JsHeapAbove PRE_first_tail_x2_r0_body.s255.next PRE_first_tail_x2_r0_body.s257 :=
  JsHeapAbove.glueSite bodyJs10 (Nat.le_of_ble_eq_true bodyJsLe11) PRE_first_tail_x2_r0_body.gjk11 PRE_first_tail_x2_r0_body.gjbd11 PRE_first_tail_x2_r0_body.cheap11 PRE_first_tail_x2_r0_body.zclbd11 bodyJsList11

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO236 : PRE_first_tail_x2_r0_body.S236.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S236.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr236 : bridgeOf PRE_first_tail_x2_r0_body.s236.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc236 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s236 PRE_first_tail_x2_r0_body.S236) = fun _ _ => true
kernel_rfl bodyAcc237 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s237 PRE_first_tail_x2_r0_body.S237) = fun _ _ => true
kernel_rfl bodyBr238 : bridgeOf PRE_first_tail_x2_r0_body.s238.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt237 : isHalt PRE_first_tail_x2_r0_body.s237.ctl = false
kernel_rfl bodyTop238 : noRetBlock PRE_first_tail_x2_r0_body.s238 = true
kernel_rfl bodyCnt236 : countersOkB PRE_first_tail_x2_r0_body.s236 PRE_first_tail_x2_r0_body.s238 = true
kernel_rfl bodyO238 : PRE_first_tail_x2_r0_body.S238.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S238.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr239 : bridgeOf PRE_first_tail_x2_r0_body.s239.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt238 : countersOkB PRE_first_tail_x2_r0_body.s238 PRE_first_tail_x2_r0_body.s239 = true
kernel_rfl bodyO239 : PRE_first_tail_x2_r0_body.S239.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S239.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc239 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s239 PRE_first_tail_x2_r0_body.S239) = fun _ _ => true
kernel_rfl bodyAcc243 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s243 PRE_first_tail_x2_r0_body.S243) = fun _ _ => true
kernel_rfl bodyBr244 : bridgeOf PRE_first_tail_x2_r0_body.s244.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt243 : isHalt PRE_first_tail_x2_r0_body.s243.ctl = false
kernel_rfl bodyTop244 : noRetBlock PRE_first_tail_x2_r0_body.s244 = true
kernel_rfl bodyCnt239 : countersOkB PRE_first_tail_x2_r0_body.s239 PRE_first_tail_x2_r0_body.s244 = true
kernel_rfl bodyO244 : PRE_first_tail_x2_r0_body.S244.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S244.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr245 : bridgeOf PRE_first_tail_x2_r0_body.s245.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt244 : countersOkB PRE_first_tail_x2_r0_body.s244 PRE_first_tail_x2_r0_body.s245 = true
kernel_rfl bodyO245 : PRE_first_tail_x2_r0_body.S245.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S245.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc245 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s245 PRE_first_tail_x2_r0_body.S245) = fun _ _ => true
kernel_rfl bodyAcc247 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s247 PRE_first_tail_x2_r0_body.S247) = fun _ _ => true
kernel_rfl bodyBr248 : bridgeOf PRE_first_tail_x2_r0_body.s248.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt247 : isHalt PRE_first_tail_x2_r0_body.s247.ctl = false
kernel_rfl bodyTop248 : noRetBlock PRE_first_tail_x2_r0_body.s248 = true
kernel_rfl bodyCnt245 : countersOkB PRE_first_tail_x2_r0_body.s245 PRE_first_tail_x2_r0_body.s248 = true
kernel_rfl bodyO248 : PRE_first_tail_x2_r0_body.S248.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S248.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr249 : bridgeOf PRE_first_tail_x2_r0_body.s249.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt248 : countersOkB PRE_first_tail_x2_r0_body.s248 PRE_first_tail_x2_r0_body.s249 = true
kernel_rfl bodyO249 : PRE_first_tail_x2_r0_body.S249.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S249.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc249 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s249 PRE_first_tail_x2_r0_body.S249) = fun _ _ => true
kernel_rfl bodyAcc250 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s250 PRE_first_tail_x2_r0_body.S250) = fun _ _ => true
kernel_rfl bodyBr251 : bridgeOf PRE_first_tail_x2_r0_body.s251.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt250 : isHalt PRE_first_tail_x2_r0_body.s250.ctl = false
kernel_rfl bodyTop251 : noRetBlock PRE_first_tail_x2_r0_body.s251 = true
kernel_rfl bodyCnt249 : countersOkB PRE_first_tail_x2_r0_body.s249 PRE_first_tail_x2_r0_body.s251 = true
kernel_rfl bodyO251 : PRE_first_tail_x2_r0_body.S251.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S251.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr252 : bridgeOf PRE_first_tail_x2_r0_body.s252.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt251 : countersOkB PRE_first_tail_x2_r0_body.s251 PRE_first_tail_x2_r0_body.s252 = true
kernel_rfl bodyO252 : PRE_first_tail_x2_r0_body.S252.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S252.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc252 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s252 PRE_first_tail_x2_r0_body.S252) = fun _ _ => true
kernel_rfl bodyAcc254 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s254 PRE_first_tail_x2_r0_body.S254) = fun _ _ => true
kernel_rfl bodyBr255 : bridgeOf PRE_first_tail_x2_r0_body.s255.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt254 : isHalt PRE_first_tail_x2_r0_body.s254.ctl = false
kernel_rfl bodyTop255 : noRetBlock PRE_first_tail_x2_r0_body.s255 = true
kernel_rfl bodyCnt252 : countersOkB PRE_first_tail_x2_r0_body.s252 PRE_first_tail_x2_r0_body.s255 = true

theorem bodyGlue11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 180⟩ bodyM PRE_first_tail_x2_r0_body.s236 PRE_first_tail_x2_r0_body.S236)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 180⟩ bodyM PRE_first_tail_x2_r0_body.s255 PRE_first_tail_x2_r0_body.S255) 24692 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc236 PRE_first_tail_x2_r0_body.bodyRunSeg63 bodyAcc237 bodyHalt237 PRE_first_tail_x2_r0_body.bodyStepA64 bodyTop238 (fun _ hm => bodyO236 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr236).trans bodyInactive0) (bodyBr238.trans bodyBr236.symm) bodyCnt236 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) PRE_first_tail_x2_r0_body.sizeA64 PRE_first_tail_x2_r0_body.sizeArgsA64 PRE_first_tail_x2_r0_body.sizeSymA64 PRE_first_tail_x2_r0_body.sizeMlxA64 PRE_first_tail_x2_r0_body.sizePayA64 PRE_first_tail_x2_r0_body.sizeTaA64 PRE_first_tail_x2_r0_body.sizeDecA64 PRE_first_tail_x2_r0_body.sizePreA64 PRE_first_tail_x2_r0_body.bodyPatchB64 (fun _ hm => bodyO238 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr238).trans bodyInactive0) (bodyBr239.trans bodyBr238.symm) bodyCnt238 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc239 PRE_first_tail_x2_r0_body.bodyRunSeg64 bodyAcc243 bodyHalt243 PRE_first_tail_x2_r0_body.bodyStepA65 bodyTop244 (fun _ hm => bodyO239 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr239).trans bodyInactive0) (bodyBr244.trans bodyBr239.symm) bodyCnt239 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) PRE_first_tail_x2_r0_body.sizeA65 PRE_first_tail_x2_r0_body.sizeArgsA65 PRE_first_tail_x2_r0_body.sizeSymA65 PRE_first_tail_x2_r0_body.sizeMlxA65 PRE_first_tail_x2_r0_body.sizePayA65 PRE_first_tail_x2_r0_body.sizeTaA65 PRE_first_tail_x2_r0_body.sizeDecA65 PRE_first_tail_x2_r0_body.sizePreA65 PRE_first_tail_x2_r0_body.bodyPatchB65 (fun _ hm => bodyO244 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr244).trans bodyInactive0) (bodyBr245.trans bodyBr244.symm) bodyCnt244 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc245 PRE_first_tail_x2_r0_body.bodyRunSeg65 bodyAcc247 bodyHalt247 PRE_first_tail_x2_r0_body.bodyStepA66 bodyTop248 (fun _ hm => bodyO245 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr245).trans bodyInactive0) (bodyBr248.trans bodyBr245.symm) bodyCnt245 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) PRE_first_tail_x2_r0_body.sizeA66 PRE_first_tail_x2_r0_body.sizeArgsA66 PRE_first_tail_x2_r0_body.sizeSymA66 PRE_first_tail_x2_r0_body.sizeMlxA66 PRE_first_tail_x2_r0_body.sizePayA66 PRE_first_tail_x2_r0_body.sizeTaA66 PRE_first_tail_x2_r0_body.sizeDecA66 PRE_first_tail_x2_r0_body.sizePreA66 PRE_first_tail_x2_r0_body.bodyPatchB66 (fun _ hm => bodyO248 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr248).trans bodyInactive0) (bodyBr249.trans bodyBr248.symm) bodyCnt248 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc249 PRE_first_tail_x2_r0_body.bodyRunSeg66 bodyAcc250 bodyHalt250 PRE_first_tail_x2_r0_body.bodyStepA67 bodyTop251 (fun _ hm => bodyO249 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr249).trans bodyInactive0) (bodyBr251.trans bodyBr249.symm) bodyCnt249 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) PRE_first_tail_x2_r0_body.sizeA67 PRE_first_tail_x2_r0_body.sizeArgsA67 PRE_first_tail_x2_r0_body.sizeSymA67 PRE_first_tail_x2_r0_body.sizeMlxA67 PRE_first_tail_x2_r0_body.sizePayA67 PRE_first_tail_x2_r0_body.sizeTaA67 PRE_first_tail_x2_r0_body.sizeDecA67 PRE_first_tail_x2_r0_body.sizePreA67 PRE_first_tail_x2_r0_body.bodyPatchB67 (fun _ hm => bodyO251 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr251).trans bodyInactive0) (bodyBr252.trans bodyBr251.symm) bodyCnt251 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 180⟩) bodyAcc252 PRE_first_tail_x2_r0_body.bodyRunSeg67 bodyAcc254 bodyHalt254 PRE_first_tail_x2_r0_body.bodyStepA68 bodyTop255 (fun _ hm => bodyO252 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr252).trans bodyInactive0) (bodyBr255.trans bodyBr252.symm) bodyCnt252 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift11 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S255.tab.length PRE_first_tail_x2_r0_body.s255.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P11.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P11 1478 PRE_first_tail_x2_r0_body.kappa11 PRE_first_tail_x2_r0_body.s257.ffi PRE_first_tail_x2_r0_body.s256.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_11
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_11
  have hcl : SSt (· < 1478) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s257.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S255.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_11] <;> decide) PRE_first_tail_x2_r0_body.cnodesK11 PRE_first_tail_x2_r0_body.cobjsK11
      PRE_first_tail_x2_r0_body.citemsK11 PRE_first_tail_x2_r0_body.cbd11 PRE_first_tail_x2_r0_body.csst11
  exact PRE_first_tail_x2_r0_body.cshift11 bodyNcl11 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_11] at this; exact this)


kernel_rfl bodyFramesEmpty11 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s256 a).isEmpty) = true
kernel_rfl bodyJsRoots11 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s255.next) PRE_first_tail_x2_r0_body.s257.trace PRE_first_tail_x2_r0_body.s257 = true
kernel_rfl bodyJsNative11 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s257.ffi) = true
kernel_rfl bodyLow11 : (PRE_first_tail_x2_r0_body.cws11 ++ PRE_first_tail_x2_r0_body.ws11).all (Nat.ble 9) = true
kernel_rfl bodyCntM11 : countersOkB PRE_first_tail_x2_r0_body.s255 PRE_first_tail_x2_r0_body.s256 = true
kernel_rfl bodyHi11 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s257.ffi).next setupP.E = true
kernel_rfl bodyNhi11 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s257.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge11 : bridgeOf PRE_first_tail_x2_r0_body.s256.ffi = bridgeOf PRE_first_tail_x2_r0_body.s255.ffi
kernel_rfl bodyNN11 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s255.ffi).nnext PRE_first_tail_x2_r0_body.P11.NL = true
kernel_rfl bodyXn11 : Nat.ble (⟨18869, 15956, 2701137, 1478⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s257.ffi).next = true
kernel_rfl bodyLo11 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s257.ffi).next = true
theorem bodyFacts11 : BodySiteFacts PRE_first_tail_x2_r0_body.s255 PRE_first_tail_x2_r0_body.s256 PRE_first_tail_x2_r0_body.s257 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S255 PRE_first_tail_x2_r0_body.S256 PRE_first_tail_x2_r0_body.S257
    PRE_first_tail_x2_r0_body.ws11 PRE_first_tail_x2_r0_body.cws11 PRE_first_tail_x2_r0_body.nr11 PRE_first_tail_x2_r0_body.pl11 PRE_first_tail_x2_r0_body.cl11 2701487 1478 PRE_first_tail_x2_r0_body.kd11 PRE_first_tail_x2_r0_body.kappa11 PRE_first_tail_x2_r0_body.P11
    ⟨18865, 15950, 2701122, 1469⟩ ⟨18869, 15956, 2701137, 1478⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap11
  clean := bodyClean11
  cfix := PRE_first_tail_x2_r0_body.cfix11
  zpl := PRE_first_tail_x2_r0_body.zpl11
  zplnd := PRE_first_tail_x2_r0_body.zplnd11
  zn1 := PRE_first_tail_x2_r0_body.zn111
  zfirst := PRE_first_tail_x2_r0_body.zfirst11
  zscn := PRE_first_tail_x2_r0_body.zscn11
  zsmn := PRE_first_tail_x2_r0_body.zsmn11
  zgrow := PRE_first_tail_x2_r0_body.zgrow11
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab11
  zfresh := PRE_first_tail_x2_r0_body.zfresh11
  zcnd := PRE_first_tail_x2_r0_body.zcnd11
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi11
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt11
  zgP := PRE_first_tail_x2_r0_body.zg11_2665
  zkP := PRE_first_tail_x2_r0_body.zk11_2665
  zmP := PRE_first_tail_x2_r0_body.zm11_2665
  zgC := PRE_first_tail_x2_r0_body.zg11_2673467
  zkC := PRE_first_tail_x2_r0_body.zk11_2673467
  zmC := PRE_first_tail_x2_r0_body.zm11_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw11_2673472
  zwV := PRE_first_tail_x2_r0_body.zw11_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap11
  zclbd := PRE_first_tail_x2_r0_body.zclbd11
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap11 PRE_first_tail_x2_r0_body.stFoot11 PRE_first_tail_x2_r0_body.iso11 PRE_first_tail_x2_r0_body.zwr11
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP11
  csupp := PRE_first_tail_x2_r0_body.csupp11
  cbound := PRE_first_tail_x2_r0_body.cbound11
  zimg := PRE_first_tail_x2_r0_body.zimg11
  zctl := PRE_first_tail_x2_r0_body.zctl11
  zstack := PRE_first_tail_x2_r0_body.zstack11
  zjobs := PRE_first_tail_x2_r0_body.zjobs11
  zstores := PRE_first_tail_x2_r0_body.zstores11
  zroots := PRE_first_tail_x2_r0_body.zroots11
  znC := PRE_first_tail_x2_r0_body.znC11
  ctab := PRE_first_tail_x2_r0_body.ctab11
  zbin := PRE_first_tail_x2_r0_body.zbin11
  cbridge := PRE_first_tail_x2_r0_body.cbridge11
  sbridge := bodyBridge11
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj11
  cshiftR := fun h hNL => bodyCshift11 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN11
  raised := PRE_first_tail_x2_r0_body.raised11
  cbigs := PRE_first_tail_x2_r0_body.cbigs11
  cjcl := PRE_first_tail_x2_r0_body.cjcl11
  xnLe := Nat.le_of_ble_eq_true bodyXn11
  loLe := Nat.le_of_ble_eq_true bodyLo11
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB11
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
noncomputable def bodyEs11 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr11.map fun r => nth? PRE_first_tail_x2_r0_body.st11.S3.tab r
kernel_rfl bodyResChk11 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs11 bodyQs11) = true
kernel_rfl bodyLq11 : bodyQs11.length = PRE_first_tail_x2_r0_body.cws11.length
kernel_rfl bodyNrLo11 : PRE_first_tail_x2_r0_body.nr11.all (Nat.ble PRE_first_tail_x2_r0_body.S255.tab.length) = true
kernel_rfl bodySub11 : (Oracles.PRE_first_tail_x2_r0_body.map_site11.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost11 : postSubB bodyM PRE_first_tail_x2_r0_body.ws11 PRE_first_tail_x2_r0_body.cws11 bodyQs11 = true
kernel_rfl bodyDrop11 : Nat.ble (15155 + (PRE_first_tail_x2_r0_body.s256.next - PRE_first_tail_x2_r0_body.s257.next)) 15505 = true
kernel_rfl bodyDropH11 : Nat.ble (250 + ((mlxOf PRE_first_tail_x2_r0_body.s256.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s257.ffi).next)) 252 = true
kernel_rfl bodyDropN11 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s256.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s257.ffi).nnext)) 0 = true
kernel_rfl bodyDv11 : bodyΘ.1.take 189 = bodyΘ.1.take 180 ++ PRE_first_tail_x2_r0_body.cws11
kernel_rfl bodyDe11 : bodyΘ.2.take 189 = bodyΘ.2.take 180 ++ PRE_first_tail_x2_r0_body.nr11.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st11.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 180) (bodyΘ.2.take 180)))
kernel_rfl bodyDl11 : (bodyΘ.1.take 180).length = (bodyΘ.2.take 180).length
kernel_rfl bodyDold11 : (bodyΘ.1.take 180).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws11).isNone && !PRE_first_tail_x2_r0_body.ws11.contains v) = true
kernel_rfl bodyDfree11 : (bodyΘ.2.take 189).all (fun e => (PRE_first_tail_x2_r0_body.cws11 ++ PRE_first_tail_x2_r0_body.ws11).all fun w => e.noVar w) = true

theorem bodyStep11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 180⟩ bodyM PRE_first_tail_x2_r0_body.s255 PRE_first_tail_x2_r0_body.S255)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 189⟩ bodyM PRE_first_tail_x2_r0_body.s257 PRE_first_tail_x2_r0_body.S257) (3452 + 1) :=
  bodySite bodyFacts11.cfix bodyFacts11.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x2_r0_body.st11.S3.tab) (Es := bodyEs11) (qs := bodyQs11)
    (ok := PRE_first_tail_x2_r0_body.st11.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site11 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts11
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site11 r hr) hi (MapOk.sub hm (sub_of_all bodySub11)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk11 r hr) hi hm ho hq)
    bodyLq11 rfl bodyNrLo11 (postSub_sound bodyPost11)
    (Nat.le_of_ble_eq_true bodyDrop11) (by decide) (Nat.le_of_ble_eq_true bodyDropH11) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN11) (by decide)
    bodyDv11 bodyDe11 bodyDl11 bodyDold11 bodyDfree11 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyOracles_3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_g12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g12 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g12) (List.take 30 (List.drop 353 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site12 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st12.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g13 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g13) (List.take 27 (List.drop 383 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site13 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st13.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g14 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g14 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g14) (List.take 27 (List.drop 410 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site14 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site14 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st14.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g15 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g15) (List.take 39 (List.drop 437 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site15 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st15.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site12 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st12.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site12
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st12.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st12.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s277 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s278 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S277 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws12 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st12.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st12.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso12
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_12
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st12.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot12
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup12
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound12
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace12
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged12
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws12.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st12.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S277.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_12]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen12.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh12
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl12 : Conv.NClean (⟨18924, 15989, 2703487, 1589⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s277.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl12 (PRE_first_tail_x2_r0_body.cncl11 bodyNcl11)

theorem bodyClean12 : Conv.JClean (⟨18924, 15989, 2703487, 1589⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s277 :=
  PRE_first_tail_x2_r0_body.gjcl12 (PRE_first_tail_x2_r0_body.cjcl11 bodyClean11)

kernel_rfl bodyJsLe12 : Nat.ble PRE_first_tail_x2_r0_body.s255.next PRE_first_tail_x2_r0_body.s277.next = true
kernel_rfl bodyJsList12 : (PRE_first_tail_x2_r0_body.gjh12 ++ PRE_first_tail_x2_r0_body.cl12).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s277.next) PRE_first_tail_x2_r0_body.s279) = true
theorem bodyJs12 : JsHeapAbove PRE_first_tail_x2_r0_body.s277.next PRE_first_tail_x2_r0_body.s279 :=
  JsHeapAbove.glueSite bodyJs11 (Nat.le_of_ble_eq_true bodyJsLe12) PRE_first_tail_x2_r0_body.gjk12 PRE_first_tail_x2_r0_body.gjbd12 PRE_first_tail_x2_r0_body.cheap12 PRE_first_tail_x2_r0_body.zclbd12 bodyJsList12

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO257 : PRE_first_tail_x2_r0_body.S257.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S257.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr257 : bridgeOf PRE_first_tail_x2_r0_body.s257.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc257 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s257 PRE_first_tail_x2_r0_body.S257) = fun _ _ => true
kernel_rfl bodyAcc258 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s258 PRE_first_tail_x2_r0_body.S258) = fun _ _ => true
kernel_rfl bodyBr259 : bridgeOf PRE_first_tail_x2_r0_body.s259.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt258 : isHalt PRE_first_tail_x2_r0_body.s258.ctl = false
kernel_rfl bodyTop259 : noRetBlock PRE_first_tail_x2_r0_body.s259 = true
kernel_rfl bodyCnt257 : countersOkB PRE_first_tail_x2_r0_body.s257 PRE_first_tail_x2_r0_body.s259 = true
kernel_rfl bodyO259 : PRE_first_tail_x2_r0_body.S259.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S259.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr260 : bridgeOf PRE_first_tail_x2_r0_body.s260.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt259 : countersOkB PRE_first_tail_x2_r0_body.s259 PRE_first_tail_x2_r0_body.s260 = true
kernel_rfl bodyO260 : PRE_first_tail_x2_r0_body.S260.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S260.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc260 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s260 PRE_first_tail_x2_r0_body.S260) = fun _ _ => true
kernel_rfl bodyAcc264 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s264 PRE_first_tail_x2_r0_body.S264) = fun _ _ => true
kernel_rfl bodyBr265 : bridgeOf PRE_first_tail_x2_r0_body.s265.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt264 : isHalt PRE_first_tail_x2_r0_body.s264.ctl = false
kernel_rfl bodyTop265 : noRetBlock PRE_first_tail_x2_r0_body.s265 = true
kernel_rfl bodyCnt260 : countersOkB PRE_first_tail_x2_r0_body.s260 PRE_first_tail_x2_r0_body.s265 = true
kernel_rfl bodyO265 : PRE_first_tail_x2_r0_body.S265.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S265.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr266 : bridgeOf PRE_first_tail_x2_r0_body.s266.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt265 : countersOkB PRE_first_tail_x2_r0_body.s265 PRE_first_tail_x2_r0_body.s266 = true
kernel_rfl bodyO266 : PRE_first_tail_x2_r0_body.S266.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S266.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc266 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s266 PRE_first_tail_x2_r0_body.S266) = fun _ _ => true
kernel_rfl bodyAcc267 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s267 PRE_first_tail_x2_r0_body.S267) = fun _ _ => true
kernel_rfl bodyBr268 : bridgeOf PRE_first_tail_x2_r0_body.s268.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt267 : isHalt PRE_first_tail_x2_r0_body.s267.ctl = false
kernel_rfl bodyTop268 : noRetBlock PRE_first_tail_x2_r0_body.s268 = true
kernel_rfl bodyCnt266 : countersOkB PRE_first_tail_x2_r0_body.s266 PRE_first_tail_x2_r0_body.s268 = true
kernel_rfl bodyO268 : PRE_first_tail_x2_r0_body.S268.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S268.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr269 : bridgeOf PRE_first_tail_x2_r0_body.s269.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt268 : countersOkB PRE_first_tail_x2_r0_body.s268 PRE_first_tail_x2_r0_body.s269 = true
kernel_rfl bodyO269 : PRE_first_tail_x2_r0_body.S269.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S269.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc269 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s269 PRE_first_tail_x2_r0_body.S269) = fun _ _ => true
kernel_rfl bodyAcc270 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s270 PRE_first_tail_x2_r0_body.S270) = fun _ _ => true
kernel_rfl bodyBr271 : bridgeOf PRE_first_tail_x2_r0_body.s271.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt270 : isHalt PRE_first_tail_x2_r0_body.s270.ctl = false
kernel_rfl bodyTop271 : noRetBlock PRE_first_tail_x2_r0_body.s271 = true
kernel_rfl bodyCnt269 : countersOkB PRE_first_tail_x2_r0_body.s269 PRE_first_tail_x2_r0_body.s271 = true
kernel_rfl bodyO271 : PRE_first_tail_x2_r0_body.S271.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S271.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr272 : bridgeOf PRE_first_tail_x2_r0_body.s272.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt271 : countersOkB PRE_first_tail_x2_r0_body.s271 PRE_first_tail_x2_r0_body.s272 = true
kernel_rfl bodyO272 : PRE_first_tail_x2_r0_body.S272.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S272.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc272 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s272 PRE_first_tail_x2_r0_body.S272) = fun _ _ => true
kernel_rfl bodyAcc273 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s273 PRE_first_tail_x2_r0_body.S273) = fun _ _ => true
kernel_rfl bodyBr274 : bridgeOf PRE_first_tail_x2_r0_body.s274.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt273 : isHalt PRE_first_tail_x2_r0_body.s273.ctl = false
kernel_rfl bodyTop274 : noRetBlock PRE_first_tail_x2_r0_body.s274 = true
kernel_rfl bodyCnt272 : countersOkB PRE_first_tail_x2_r0_body.s272 PRE_first_tail_x2_r0_body.s274 = true
kernel_rfl bodyO274 : PRE_first_tail_x2_r0_body.S274.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S274.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr275 : bridgeOf PRE_first_tail_x2_r0_body.s275.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt274 : countersOkB PRE_first_tail_x2_r0_body.s274 PRE_first_tail_x2_r0_body.s275 = true
kernel_rfl bodyO275 : PRE_first_tail_x2_r0_body.S275.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S275.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc275 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s275 PRE_first_tail_x2_r0_body.S275) = fun _ _ => true
kernel_rfl bodyAcc276 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s276 PRE_first_tail_x2_r0_body.S276) = fun _ _ => true
kernel_rfl bodyBr277 : bridgeOf PRE_first_tail_x2_r0_body.s277.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt276 : isHalt PRE_first_tail_x2_r0_body.s276.ctl = false
kernel_rfl bodyTop277 : noRetBlock PRE_first_tail_x2_r0_body.s277 = true
kernel_rfl bodyCnt275 : countersOkB PRE_first_tail_x2_r0_body.s275 PRE_first_tail_x2_r0_body.s277 = true

theorem bodyGlue12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 189⟩ bodyM PRE_first_tail_x2_r0_body.s257 PRE_first_tail_x2_r0_body.S257)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 189⟩ bodyM PRE_first_tail_x2_r0_body.s277 PRE_first_tail_x2_r0_body.S277) 23365 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc257 PRE_first_tail_x2_r0_body.bodyRunSeg68 bodyAcc258 bodyHalt258 PRE_first_tail_x2_r0_body.bodyStepA69 bodyTop259 (fun _ hm => bodyO257 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr257).trans bodyInactive0) (bodyBr259.trans bodyBr257.symm) bodyCnt257 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x2_r0_body.sizeA69 PRE_first_tail_x2_r0_body.sizeArgsA69 PRE_first_tail_x2_r0_body.sizeSymA69 PRE_first_tail_x2_r0_body.sizeMlxA69 PRE_first_tail_x2_r0_body.sizePayA69 PRE_first_tail_x2_r0_body.sizeTaA69 PRE_first_tail_x2_r0_body.sizeDecA69 PRE_first_tail_x2_r0_body.sizePreA69 PRE_first_tail_x2_r0_body.bodyPatchB69 (fun _ hm => bodyO259 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr259).trans bodyInactive0) (bodyBr260.trans bodyBr259.symm) bodyCnt259 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc260 PRE_first_tail_x2_r0_body.bodyRunSeg69 bodyAcc264 bodyHalt264 PRE_first_tail_x2_r0_body.bodyStepA70 bodyTop265 (fun _ hm => bodyO260 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr260).trans bodyInactive0) (bodyBr265.trans bodyBr260.symm) bodyCnt260 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x2_r0_body.sizeA70 PRE_first_tail_x2_r0_body.sizeArgsA70 PRE_first_tail_x2_r0_body.sizeSymA70 PRE_first_tail_x2_r0_body.sizeMlxA70 PRE_first_tail_x2_r0_body.sizePayA70 PRE_first_tail_x2_r0_body.sizeTaA70 PRE_first_tail_x2_r0_body.sizeDecA70 PRE_first_tail_x2_r0_body.sizePreA70 PRE_first_tail_x2_r0_body.bodyPatchB70 (fun _ hm => bodyO265 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr265).trans bodyInactive0) (bodyBr266.trans bodyBr265.symm) bodyCnt265 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc266 PRE_first_tail_x2_r0_body.bodyRunSeg70 bodyAcc267 bodyHalt267 PRE_first_tail_x2_r0_body.bodyStepA71 bodyTop268 (fun _ hm => bodyO266 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr266).trans bodyInactive0) (bodyBr268.trans bodyBr266.symm) bodyCnt266 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x2_r0_body.sizeA71 PRE_first_tail_x2_r0_body.sizeArgsA71 PRE_first_tail_x2_r0_body.sizeSymA71 PRE_first_tail_x2_r0_body.sizeMlxA71 PRE_first_tail_x2_r0_body.sizePayA71 PRE_first_tail_x2_r0_body.sizeTaA71 PRE_first_tail_x2_r0_body.sizeDecA71 PRE_first_tail_x2_r0_body.sizePreA71 PRE_first_tail_x2_r0_body.bodyPatchB71 (fun _ hm => bodyO268 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr268).trans bodyInactive0) (bodyBr269.trans bodyBr268.symm) bodyCnt268 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc269 PRE_first_tail_x2_r0_body.bodyRunSeg71 bodyAcc270 bodyHalt270 PRE_first_tail_x2_r0_body.bodyStepA72 bodyTop271 (fun _ hm => bodyO269 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr269).trans bodyInactive0) (bodyBr271.trans bodyBr269.symm) bodyCnt269 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x2_r0_body.sizeA72 PRE_first_tail_x2_r0_body.sizeArgsA72 PRE_first_tail_x2_r0_body.sizeSymA72 PRE_first_tail_x2_r0_body.sizeMlxA72 PRE_first_tail_x2_r0_body.sizePayA72 PRE_first_tail_x2_r0_body.sizeTaA72 PRE_first_tail_x2_r0_body.sizeDecA72 PRE_first_tail_x2_r0_body.sizePreA72 PRE_first_tail_x2_r0_body.bodyPatchB72 (fun _ hm => bodyO271 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr271).trans bodyInactive0) (bodyBr272.trans bodyBr271.symm) bodyCnt271 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc272 PRE_first_tail_x2_r0_body.bodyRunSeg72 bodyAcc273 bodyHalt273 PRE_first_tail_x2_r0_body.bodyStepA73 bodyTop274 (fun _ hm => bodyO272 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr272).trans bodyInactive0) (bodyBr274.trans bodyBr272.symm) bodyCnt272 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) PRE_first_tail_x2_r0_body.sizeA73 PRE_first_tail_x2_r0_body.sizeArgsA73 PRE_first_tail_x2_r0_body.sizeSymA73 PRE_first_tail_x2_r0_body.sizeMlxA73 PRE_first_tail_x2_r0_body.sizePayA73 PRE_first_tail_x2_r0_body.sizeTaA73 PRE_first_tail_x2_r0_body.sizeDecA73 PRE_first_tail_x2_r0_body.sizePreA73 PRE_first_tail_x2_r0_body.bodyPatchB73 (fun _ hm => bodyO274 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr274).trans bodyInactive0) (bodyBr275.trans bodyBr274.symm) bodyCnt274 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 189⟩) bodyAcc275 PRE_first_tail_x2_r0_body.bodyRunSeg73 bodyAcc276 bodyHalt276 PRE_first_tail_x2_r0_body.bodyStepA74 bodyTop277 (fun _ hm => bodyO275 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr275).trans bodyInactive0) (bodyBr277.trans bodyBr275.symm) bodyCnt275 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift12 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S277.tab.length PRE_first_tail_x2_r0_body.s277.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P12.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P12 1607 PRE_first_tail_x2_r0_body.kappa12 PRE_first_tail_x2_r0_body.s279.ffi PRE_first_tail_x2_r0_body.s278.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_12
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_12
  have hcl : SSt (· < 1607) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s279.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S277.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_12] <;> decide) PRE_first_tail_x2_r0_body.cnodesK12 PRE_first_tail_x2_r0_body.cobjsK12
      PRE_first_tail_x2_r0_body.citemsK12 PRE_first_tail_x2_r0_body.cbd12 PRE_first_tail_x2_r0_body.csst12
  exact PRE_first_tail_x2_r0_body.cshift12 bodyNcl12 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_12] at this; exact this)


kernel_rfl bodyFramesEmpty12 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s278 a).isEmpty) = true
kernel_rfl bodyJsRoots12 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s277.next) PRE_first_tail_x2_r0_body.s279.trace PRE_first_tail_x2_r0_body.s279 = true
kernel_rfl bodyJsNative12 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s279.ffi) = true
kernel_rfl bodyLow12 : (PRE_first_tail_x2_r0_body.cws12 ++ PRE_first_tail_x2_r0_body.ws12).all (Nat.ble 9) = true
kernel_rfl bodyCntM12 : countersOkB PRE_first_tail_x2_r0_body.s277 PRE_first_tail_x2_r0_body.s278 = true
kernel_rfl bodyHi12 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s279.ffi).next setupP.E = true
kernel_rfl bodyNhi12 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s279.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge12 : bridgeOf PRE_first_tail_x2_r0_body.s278.ffi = bridgeOf PRE_first_tail_x2_r0_body.s277.ffi
kernel_rfl bodyNN12 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s277.ffi).nnext PRE_first_tail_x2_r0_body.P12.NL = true
kernel_rfl bodyXn12 : Nat.ble (⟨18927, 16016, 2703493, 1607⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s279.ffi).next = true
kernel_rfl bodyLo12 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s279.ffi).next = true
theorem bodyFacts12 : BodySiteFacts PRE_first_tail_x2_r0_body.s277 PRE_first_tail_x2_r0_body.s278 PRE_first_tail_x2_r0_body.s279 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S277 PRE_first_tail_x2_r0_body.S278 PRE_first_tail_x2_r0_body.S279
    PRE_first_tail_x2_r0_body.ws12 PRE_first_tail_x2_r0_body.cws12 PRE_first_tail_x2_r0_body.nr12 PRE_first_tail_x2_r0_body.pl12 PRE_first_tail_x2_r0_body.cl12 2704642 1607 PRE_first_tail_x2_r0_body.kd12 PRE_first_tail_x2_r0_body.kappa12 PRE_first_tail_x2_r0_body.P12
    ⟨18924, 15989, 2703487, 1589⟩ ⟨18927, 16016, 2703493, 1607⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap12
  clean := bodyClean12
  cfix := PRE_first_tail_x2_r0_body.cfix12
  zpl := PRE_first_tail_x2_r0_body.zpl12
  zplnd := PRE_first_tail_x2_r0_body.zplnd12
  zn1 := PRE_first_tail_x2_r0_body.zn112
  zfirst := PRE_first_tail_x2_r0_body.zfirst12
  zscn := PRE_first_tail_x2_r0_body.zscn12
  zsmn := PRE_first_tail_x2_r0_body.zsmn12
  zgrow := PRE_first_tail_x2_r0_body.zgrow12
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab12
  zfresh := PRE_first_tail_x2_r0_body.zfresh12
  zcnd := PRE_first_tail_x2_r0_body.zcnd12
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi12
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt12
  zgP := PRE_first_tail_x2_r0_body.zg12_2665
  zkP := PRE_first_tail_x2_r0_body.zk12_2665
  zmP := PRE_first_tail_x2_r0_body.zm12_2665
  zgC := PRE_first_tail_x2_r0_body.zg12_2673467
  zkC := PRE_first_tail_x2_r0_body.zk12_2673467
  zmC := PRE_first_tail_x2_r0_body.zm12_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw12_2673472
  zwV := PRE_first_tail_x2_r0_body.zw12_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap12
  zclbd := PRE_first_tail_x2_r0_body.zclbd12
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap12 PRE_first_tail_x2_r0_body.stFoot12 PRE_first_tail_x2_r0_body.iso12 PRE_first_tail_x2_r0_body.zwr12
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP12
  csupp := PRE_first_tail_x2_r0_body.csupp12
  cbound := PRE_first_tail_x2_r0_body.cbound12
  zimg := PRE_first_tail_x2_r0_body.zimg12
  zctl := PRE_first_tail_x2_r0_body.zctl12
  zstack := PRE_first_tail_x2_r0_body.zstack12
  zjobs := PRE_first_tail_x2_r0_body.zjobs12
  zstores := PRE_first_tail_x2_r0_body.zstores12
  zroots := PRE_first_tail_x2_r0_body.zroots12
  znC := PRE_first_tail_x2_r0_body.znC12
  ctab := PRE_first_tail_x2_r0_body.ctab12
  zbin := PRE_first_tail_x2_r0_body.zbin12
  cbridge := PRE_first_tail_x2_r0_body.cbridge12
  sbridge := bodyBridge12
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj12
  cshiftR := fun h hNL => bodyCshift12 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN12
  raised := PRE_first_tail_x2_r0_body.raised12
  cbigs := PRE_first_tail_x2_r0_body.cbigs12
  cjcl := PRE_first_tail_x2_r0_body.cjcl12
  xnLe := Nat.le_of_ble_eq_true bodyXn12
  loLe := Nat.le_of_ble_eq_true bodyLo12
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB12
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
noncomputable def bodyEs12 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr12.map fun r => nth? PRE_first_tail_x2_r0_body.st12.S5.tab r
kernel_rfl bodyResChk12 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs12 bodyQs12) = true
kernel_rfl bodyLq12 : bodyQs12.length = PRE_first_tail_x2_r0_body.cws12.length
kernel_rfl bodyNrLo12 : PRE_first_tail_x2_r0_body.nr12.all (Nat.ble PRE_first_tail_x2_r0_body.S277.tab.length) = true
kernel_rfl bodySub12 : (Oracles.PRE_first_tail_x2_r0_body.map_site12.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost12 : postSubB bodyM PRE_first_tail_x2_r0_body.ws12 PRE_first_tail_x2_r0_body.cws12 bodyQs12 = true
kernel_rfl bodyDrop12 : Nat.ble (15505 + (PRE_first_tail_x2_r0_body.s278.next - PRE_first_tail_x2_r0_body.s279.next)) 16654 = true
kernel_rfl bodyDropH12 : Nat.ble (252 + ((mlxOf PRE_first_tail_x2_r0_body.s278.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s279.ffi).next)) 277 = true
kernel_rfl bodyDropN12 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s278.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s279.ffi).nnext)) 0 = true
kernel_rfl bodyDv12 : bodyΘ.1.take 207 = bodyΘ.1.take 189 ++ PRE_first_tail_x2_r0_body.cws12
kernel_rfl bodyDe12 : bodyΘ.2.take 207 = bodyΘ.2.take 189 ++ PRE_first_tail_x2_r0_body.nr12.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st12.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 189) (bodyΘ.2.take 189)))
kernel_rfl bodyDl12 : (bodyΘ.1.take 189).length = (bodyΘ.2.take 189).length
kernel_rfl bodyDold12 : (bodyΘ.1.take 189).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws12).isNone && !PRE_first_tail_x2_r0_body.ws12.contains v) = true
kernel_rfl bodyDfree12 : (bodyΘ.2.take 207).all (fun e => (PRE_first_tail_x2_r0_body.cws12 ++ PRE_first_tail_x2_r0_body.ws12).all fun w => e.noVar w) = true

theorem bodyStep12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 189⟩ bodyM PRE_first_tail_x2_r0_body.s277 PRE_first_tail_x2_r0_body.S277)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 207⟩ bodyM PRE_first_tail_x2_r0_body.s279 PRE_first_tail_x2_r0_body.S279) (11334 + 1) :=
  bodySite bodyFacts12.cfix bodyFacts12.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st12.S5.tab) (Es := bodyEs12) (qs := bodyQs12)
    (ok := PRE_first_tail_x2_r0_body.st12.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site12 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts12
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site12 r hr) hi (MapOk.sub hm (sub_of_all bodySub12)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk12 r hr) hi hm ho hq)
    bodyLq12 rfl bodyNrLo12 (postSub_sound bodyPost12)
    (Nat.le_of_ble_eq_true bodyDrop12) (by decide) (Nat.le_of_ble_eq_true bodyDropH12) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN12) (by decide)
    bodyDv12 bodyDe12 bodyDl12 bodyDold12 bodyDfree12 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site13 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st13.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site13
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st13.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st13.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s299 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s300 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S299 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws13 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st13.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st13.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso13
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_13
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st13.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot13
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup13
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound13
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace13
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged13
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws13.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st13.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S299.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_13]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen13.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh13
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl13 : Conv.NClean (⟨18981, 16052, 2705725, 1715⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s299.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl13 (PRE_first_tail_x2_r0_body.cncl12 bodyNcl12)

theorem bodyClean13 : Conv.JClean (⟨18981, 16052, 2705725, 1715⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s299 :=
  PRE_first_tail_x2_r0_body.gjcl13 (PRE_first_tail_x2_r0_body.cjcl12 bodyClean12)

kernel_rfl bodyJsLe13 : Nat.ble PRE_first_tail_x2_r0_body.s277.next PRE_first_tail_x2_r0_body.s299.next = true
kernel_rfl bodyJsList13 : (PRE_first_tail_x2_r0_body.gjh13 ++ PRE_first_tail_x2_r0_body.cl13).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s299.next) PRE_first_tail_x2_r0_body.s301) = true
theorem bodyJs13 : JsHeapAbove PRE_first_tail_x2_r0_body.s299.next PRE_first_tail_x2_r0_body.s301 :=
  JsHeapAbove.glueSite bodyJs12 (Nat.le_of_ble_eq_true bodyJsLe13) PRE_first_tail_x2_r0_body.gjk13 PRE_first_tail_x2_r0_body.gjbd13 PRE_first_tail_x2_r0_body.cheap13 PRE_first_tail_x2_r0_body.zclbd13 bodyJsList13

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO279 : PRE_first_tail_x2_r0_body.S279.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S279.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr279 : bridgeOf PRE_first_tail_x2_r0_body.s279.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc279 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s279 PRE_first_tail_x2_r0_body.S279) = fun _ _ => true
kernel_rfl bodyAcc280 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s280 PRE_first_tail_x2_r0_body.S280) = fun _ _ => true
kernel_rfl bodyBr281 : bridgeOf PRE_first_tail_x2_r0_body.s281.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt280 : isHalt PRE_first_tail_x2_r0_body.s280.ctl = false
kernel_rfl bodyTop281 : noRetBlock PRE_first_tail_x2_r0_body.s281 = true
kernel_rfl bodyCnt279 : countersOkB PRE_first_tail_x2_r0_body.s279 PRE_first_tail_x2_r0_body.s281 = true
kernel_rfl bodyO281 : PRE_first_tail_x2_r0_body.S281.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S281.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr282 : bridgeOf PRE_first_tail_x2_r0_body.s282.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt281 : countersOkB PRE_first_tail_x2_r0_body.s281 PRE_first_tail_x2_r0_body.s282 = true
kernel_rfl bodyO282 : PRE_first_tail_x2_r0_body.S282.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S282.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc282 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s282 PRE_first_tail_x2_r0_body.S282) = fun _ _ => true
kernel_rfl bodyAcc286 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s286 PRE_first_tail_x2_r0_body.S286) = fun _ _ => true
kernel_rfl bodyBr287 : bridgeOf PRE_first_tail_x2_r0_body.s287.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt286 : isHalt PRE_first_tail_x2_r0_body.s286.ctl = false
kernel_rfl bodyTop287 : noRetBlock PRE_first_tail_x2_r0_body.s287 = true
kernel_rfl bodyCnt282 : countersOkB PRE_first_tail_x2_r0_body.s282 PRE_first_tail_x2_r0_body.s287 = true
kernel_rfl bodyO287 : PRE_first_tail_x2_r0_body.S287.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S287.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr288 : bridgeOf PRE_first_tail_x2_r0_body.s288.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt287 : countersOkB PRE_first_tail_x2_r0_body.s287 PRE_first_tail_x2_r0_body.s288 = true
kernel_rfl bodyO288 : PRE_first_tail_x2_r0_body.S288.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S288.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc288 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s288 PRE_first_tail_x2_r0_body.S288) = fun _ _ => true
kernel_rfl bodyAcc289 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s289 PRE_first_tail_x2_r0_body.S289) = fun _ _ => true
kernel_rfl bodyBr290 : bridgeOf PRE_first_tail_x2_r0_body.s290.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt289 : isHalt PRE_first_tail_x2_r0_body.s289.ctl = false
kernel_rfl bodyTop290 : noRetBlock PRE_first_tail_x2_r0_body.s290 = true
kernel_rfl bodyCnt288 : countersOkB PRE_first_tail_x2_r0_body.s288 PRE_first_tail_x2_r0_body.s290 = true
kernel_rfl bodyO290 : PRE_first_tail_x2_r0_body.S290.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S290.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr291 : bridgeOf PRE_first_tail_x2_r0_body.s291.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt290 : countersOkB PRE_first_tail_x2_r0_body.s290 PRE_first_tail_x2_r0_body.s291 = true
kernel_rfl bodyO291 : PRE_first_tail_x2_r0_body.S291.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S291.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc291 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s291 PRE_first_tail_x2_r0_body.S291) = fun _ _ => true
kernel_rfl bodyAcc292 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s292 PRE_first_tail_x2_r0_body.S292) = fun _ _ => true
kernel_rfl bodyBr293 : bridgeOf PRE_first_tail_x2_r0_body.s293.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt292 : isHalt PRE_first_tail_x2_r0_body.s292.ctl = false
kernel_rfl bodyTop293 : noRetBlock PRE_first_tail_x2_r0_body.s293 = true
kernel_rfl bodyCnt291 : countersOkB PRE_first_tail_x2_r0_body.s291 PRE_first_tail_x2_r0_body.s293 = true
kernel_rfl bodyO293 : PRE_first_tail_x2_r0_body.S293.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S293.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr294 : bridgeOf PRE_first_tail_x2_r0_body.s294.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt293 : countersOkB PRE_first_tail_x2_r0_body.s293 PRE_first_tail_x2_r0_body.s294 = true
kernel_rfl bodyO294 : PRE_first_tail_x2_r0_body.S294.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S294.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc294 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s294 PRE_first_tail_x2_r0_body.S294) = fun _ _ => true
kernel_rfl bodyAcc295 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s295 PRE_first_tail_x2_r0_body.S295) = fun _ _ => true
kernel_rfl bodyBr296 : bridgeOf PRE_first_tail_x2_r0_body.s296.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt295 : isHalt PRE_first_tail_x2_r0_body.s295.ctl = false
kernel_rfl bodyTop296 : noRetBlock PRE_first_tail_x2_r0_body.s296 = true
kernel_rfl bodyCnt294 : countersOkB PRE_first_tail_x2_r0_body.s294 PRE_first_tail_x2_r0_body.s296 = true
kernel_rfl bodyO296 : PRE_first_tail_x2_r0_body.S296.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S296.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr297 : bridgeOf PRE_first_tail_x2_r0_body.s297.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt296 : countersOkB PRE_first_tail_x2_r0_body.s296 PRE_first_tail_x2_r0_body.s297 = true
kernel_rfl bodyO297 : PRE_first_tail_x2_r0_body.S297.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S297.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc297 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s297 PRE_first_tail_x2_r0_body.S297) = fun _ _ => true
kernel_rfl bodyAcc298 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s298 PRE_first_tail_x2_r0_body.S298) = fun _ _ => true
kernel_rfl bodyBr299 : bridgeOf PRE_first_tail_x2_r0_body.s299.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt298 : isHalt PRE_first_tail_x2_r0_body.s298.ctl = false
kernel_rfl bodyTop299 : noRetBlock PRE_first_tail_x2_r0_body.s299 = true
kernel_rfl bodyCnt297 : countersOkB PRE_first_tail_x2_r0_body.s297 PRE_first_tail_x2_r0_body.s299 = true

theorem bodyGlue13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 207⟩ bodyM PRE_first_tail_x2_r0_body.s279 PRE_first_tail_x2_r0_body.S279)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 207⟩ bodyM PRE_first_tail_x2_r0_body.s299 PRE_first_tail_x2_r0_body.S299) 22217 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc279 PRE_first_tail_x2_r0_body.bodyRunSeg74 bodyAcc280 bodyHalt280 PRE_first_tail_x2_r0_body.bodyStepA75 bodyTop281 (fun _ hm => bodyO279 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr279).trans bodyInactive0) (bodyBr281.trans bodyBr279.symm) bodyCnt279 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x2_r0_body.sizeA75 PRE_first_tail_x2_r0_body.sizeArgsA75 PRE_first_tail_x2_r0_body.sizeSymA75 PRE_first_tail_x2_r0_body.sizeMlxA75 PRE_first_tail_x2_r0_body.sizePayA75 PRE_first_tail_x2_r0_body.sizeTaA75 PRE_first_tail_x2_r0_body.sizeDecA75 PRE_first_tail_x2_r0_body.sizePreA75 PRE_first_tail_x2_r0_body.bodyPatchB75 (fun _ hm => bodyO281 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr281).trans bodyInactive0) (bodyBr282.trans bodyBr281.symm) bodyCnt281 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc282 PRE_first_tail_x2_r0_body.bodyRunSeg75 bodyAcc286 bodyHalt286 PRE_first_tail_x2_r0_body.bodyStepA76 bodyTop287 (fun _ hm => bodyO282 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr282).trans bodyInactive0) (bodyBr287.trans bodyBr282.symm) bodyCnt282 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x2_r0_body.sizeA76 PRE_first_tail_x2_r0_body.sizeArgsA76 PRE_first_tail_x2_r0_body.sizeSymA76 PRE_first_tail_x2_r0_body.sizeMlxA76 PRE_first_tail_x2_r0_body.sizePayA76 PRE_first_tail_x2_r0_body.sizeTaA76 PRE_first_tail_x2_r0_body.sizeDecA76 PRE_first_tail_x2_r0_body.sizePreA76 PRE_first_tail_x2_r0_body.bodyPatchB76 (fun _ hm => bodyO287 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr287).trans bodyInactive0) (bodyBr288.trans bodyBr287.symm) bodyCnt287 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc288 PRE_first_tail_x2_r0_body.bodyRunSeg76 bodyAcc289 bodyHalt289 PRE_first_tail_x2_r0_body.bodyStepA77 bodyTop290 (fun _ hm => bodyO288 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr288).trans bodyInactive0) (bodyBr290.trans bodyBr288.symm) bodyCnt288 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x2_r0_body.sizeA77 PRE_first_tail_x2_r0_body.sizeArgsA77 PRE_first_tail_x2_r0_body.sizeSymA77 PRE_first_tail_x2_r0_body.sizeMlxA77 PRE_first_tail_x2_r0_body.sizePayA77 PRE_first_tail_x2_r0_body.sizeTaA77 PRE_first_tail_x2_r0_body.sizeDecA77 PRE_first_tail_x2_r0_body.sizePreA77 PRE_first_tail_x2_r0_body.bodyPatchB77 (fun _ hm => bodyO290 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr290).trans bodyInactive0) (bodyBr291.trans bodyBr290.symm) bodyCnt290 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc291 PRE_first_tail_x2_r0_body.bodyRunSeg77 bodyAcc292 bodyHalt292 PRE_first_tail_x2_r0_body.bodyStepA78 bodyTop293 (fun _ hm => bodyO291 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr291).trans bodyInactive0) (bodyBr293.trans bodyBr291.symm) bodyCnt291 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x2_r0_body.sizeA78 PRE_first_tail_x2_r0_body.sizeArgsA78 PRE_first_tail_x2_r0_body.sizeSymA78 PRE_first_tail_x2_r0_body.sizeMlxA78 PRE_first_tail_x2_r0_body.sizePayA78 PRE_first_tail_x2_r0_body.sizeTaA78 PRE_first_tail_x2_r0_body.sizeDecA78 PRE_first_tail_x2_r0_body.sizePreA78 PRE_first_tail_x2_r0_body.bodyPatchB78 (fun _ hm => bodyO293 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr293).trans bodyInactive0) (bodyBr294.trans bodyBr293.symm) bodyCnt293 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc294 PRE_first_tail_x2_r0_body.bodyRunSeg78 bodyAcc295 bodyHalt295 PRE_first_tail_x2_r0_body.bodyStepA79 bodyTop296 (fun _ hm => bodyO294 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr294).trans bodyInactive0) (bodyBr296.trans bodyBr294.symm) bodyCnt294 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) PRE_first_tail_x2_r0_body.sizeA79 PRE_first_tail_x2_r0_body.sizeArgsA79 PRE_first_tail_x2_r0_body.sizeSymA79 PRE_first_tail_x2_r0_body.sizeMlxA79 PRE_first_tail_x2_r0_body.sizePayA79 PRE_first_tail_x2_r0_body.sizeTaA79 PRE_first_tail_x2_r0_body.sizeDecA79 PRE_first_tail_x2_r0_body.sizePreA79 PRE_first_tail_x2_r0_body.bodyPatchB79 (fun _ hm => bodyO296 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr296).trans bodyInactive0) (bodyBr297.trans bodyBr296.symm) bodyCnt296 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 207⟩) bodyAcc297 PRE_first_tail_x2_r0_body.bodyRunSeg79 bodyAcc298 bodyHalt298 PRE_first_tail_x2_r0_body.bodyStepA80 bodyTop299 (fun _ hm => bodyO297 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr297).trans bodyInactive0) (bodyBr299.trans bodyBr297.symm) bodyCnt297 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift13 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S299.tab.length PRE_first_tail_x2_r0_body.s299.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P13.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P13 1733 PRE_first_tail_x2_r0_body.kappa13 PRE_first_tail_x2_r0_body.s301.ffi PRE_first_tail_x2_r0_body.s300.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_13
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_13
  have hcl : SSt (· < 1733) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s301.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S299.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_13] <;> decide) PRE_first_tail_x2_r0_body.cnodesK13 PRE_first_tail_x2_r0_body.cobjsK13
      PRE_first_tail_x2_r0_body.citemsK13 PRE_first_tail_x2_r0_body.cbd13 PRE_first_tail_x2_r0_body.csst13
  exact PRE_first_tail_x2_r0_body.cshift13 bodyNcl13 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_13] at this; exact this)


kernel_rfl bodyFramesEmpty13 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s300 a).isEmpty) = true
kernel_rfl bodyJsRoots13 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s299.next) PRE_first_tail_x2_r0_body.s301.trace PRE_first_tail_x2_r0_body.s301 = true
kernel_rfl bodyJsNative13 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s301.ffi) = true
kernel_rfl bodyLow13 : (PRE_first_tail_x2_r0_body.cws13 ++ PRE_first_tail_x2_r0_body.ws13).all (Nat.ble 9) = true
kernel_rfl bodyCntM13 : countersOkB PRE_first_tail_x2_r0_body.s299 PRE_first_tail_x2_r0_body.s300 = true
kernel_rfl bodyHi13 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s301.ffi).next setupP.E = true
kernel_rfl bodyNhi13 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s301.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge13 : bridgeOf PRE_first_tail_x2_r0_body.s300.ffi = bridgeOf PRE_first_tail_x2_r0_body.s299.ffi
kernel_rfl bodyNN13 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s299.ffi).nnext PRE_first_tail_x2_r0_body.P13.NL = true
kernel_rfl bodyXn13 : Nat.ble (⟨18984, 16079, 2705731, 1733⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s301.ffi).next = true
kernel_rfl bodyLo13 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s301.ffi).next = true
theorem bodyFacts13 : BodySiteFacts PRE_first_tail_x2_r0_body.s299 PRE_first_tail_x2_r0_body.s300 PRE_first_tail_x2_r0_body.s301 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S299 PRE_first_tail_x2_r0_body.S300 PRE_first_tail_x2_r0_body.S301
    PRE_first_tail_x2_r0_body.ws13 PRE_first_tail_x2_r0_body.cws13 PRE_first_tail_x2_r0_body.nr13 PRE_first_tail_x2_r0_body.pl13 PRE_first_tail_x2_r0_body.cl13 2706880 1733 PRE_first_tail_x2_r0_body.kd13 PRE_first_tail_x2_r0_body.kappa13 PRE_first_tail_x2_r0_body.P13
    ⟨18981, 16052, 2705725, 1715⟩ ⟨18984, 16079, 2705731, 1733⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap13
  clean := bodyClean13
  cfix := PRE_first_tail_x2_r0_body.cfix13
  zpl := PRE_first_tail_x2_r0_body.zpl13
  zplnd := PRE_first_tail_x2_r0_body.zplnd13
  zn1 := PRE_first_tail_x2_r0_body.zn113
  zfirst := PRE_first_tail_x2_r0_body.zfirst13
  zscn := PRE_first_tail_x2_r0_body.zscn13
  zsmn := PRE_first_tail_x2_r0_body.zsmn13
  zgrow := PRE_first_tail_x2_r0_body.zgrow13
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab13
  zfresh := PRE_first_tail_x2_r0_body.zfresh13
  zcnd := PRE_first_tail_x2_r0_body.zcnd13
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi13
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt13
  zgP := PRE_first_tail_x2_r0_body.zg13_2665
  zkP := PRE_first_tail_x2_r0_body.zk13_2665
  zmP := PRE_first_tail_x2_r0_body.zm13_2665
  zgC := PRE_first_tail_x2_r0_body.zg13_2673467
  zkC := PRE_first_tail_x2_r0_body.zk13_2673467
  zmC := PRE_first_tail_x2_r0_body.zm13_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw13_2673472
  zwV := PRE_first_tail_x2_r0_body.zw13_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap13
  zclbd := PRE_first_tail_x2_r0_body.zclbd13
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap13 PRE_first_tail_x2_r0_body.stFoot13 PRE_first_tail_x2_r0_body.iso13 PRE_first_tail_x2_r0_body.zwr13
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP13
  csupp := PRE_first_tail_x2_r0_body.csupp13
  cbound := PRE_first_tail_x2_r0_body.cbound13
  zimg := PRE_first_tail_x2_r0_body.zimg13
  zctl := PRE_first_tail_x2_r0_body.zctl13
  zstack := PRE_first_tail_x2_r0_body.zstack13
  zjobs := PRE_first_tail_x2_r0_body.zjobs13
  zstores := PRE_first_tail_x2_r0_body.zstores13
  zroots := PRE_first_tail_x2_r0_body.zroots13
  znC := PRE_first_tail_x2_r0_body.znC13
  ctab := PRE_first_tail_x2_r0_body.ctab13
  zbin := PRE_first_tail_x2_r0_body.zbin13
  cbridge := PRE_first_tail_x2_r0_body.cbridge13
  sbridge := bodyBridge13
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj13
  cshiftR := fun h hNL => bodyCshift13 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN13
  raised := PRE_first_tail_x2_r0_body.raised13
  cbigs := PRE_first_tail_x2_r0_body.cbigs13
  cjcl := PRE_first_tail_x2_r0_body.cjcl13
  xnLe := Nat.le_of_ble_eq_true bodyXn13
  loLe := Nat.le_of_ble_eq_true bodyLo13
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB13
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
noncomputable def bodyEs13 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr13.map fun r => nth? PRE_first_tail_x2_r0_body.st13.S5.tab r
kernel_rfl bodyResChk13 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs13 bodyQs13) = true
kernel_rfl bodyLq13 : bodyQs13.length = PRE_first_tail_x2_r0_body.cws13.length
kernel_rfl bodyNrLo13 : PRE_first_tail_x2_r0_body.nr13.all (Nat.ble PRE_first_tail_x2_r0_body.S299.tab.length) = true
kernel_rfl bodySub13 : (Oracles.PRE_first_tail_x2_r0_body.map_site13.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost13 : postSubB bodyM PRE_first_tail_x2_r0_body.ws13 PRE_first_tail_x2_r0_body.cws13 bodyQs13 = true
kernel_rfl bodyDrop13 : Nat.ble (16654 + (PRE_first_tail_x2_r0_body.s300.next - PRE_first_tail_x2_r0_body.s301.next)) 17803 = true
kernel_rfl bodyDropH13 : Nat.ble (277 + ((mlxOf PRE_first_tail_x2_r0_body.s300.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s301.ffi).next)) 302 = true
kernel_rfl bodyDropN13 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s300.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s301.ffi).nnext)) 0 = true
kernel_rfl bodyDv13 : bodyΘ.1.take 225 = bodyΘ.1.take 207 ++ PRE_first_tail_x2_r0_body.cws13
kernel_rfl bodyDe13 : bodyΘ.2.take 225 = bodyΘ.2.take 207 ++ PRE_first_tail_x2_r0_body.nr13.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st13.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 207) (bodyΘ.2.take 207)))
kernel_rfl bodyDl13 : (bodyΘ.1.take 207).length = (bodyΘ.2.take 207).length
kernel_rfl bodyDold13 : (bodyΘ.1.take 207).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws13).isNone && !PRE_first_tail_x2_r0_body.ws13.contains v) = true
kernel_rfl bodyDfree13 : (bodyΘ.2.take 225).all (fun e => (PRE_first_tail_x2_r0_body.cws13 ++ PRE_first_tail_x2_r0_body.ws13).all fun w => e.noVar w) = true

theorem bodyStep13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 207⟩ bodyM PRE_first_tail_x2_r0_body.s299 PRE_first_tail_x2_r0_body.S299)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 225⟩ bodyM PRE_first_tail_x2_r0_body.s301 PRE_first_tail_x2_r0_body.S301) (11334 + 1) :=
  bodySite bodyFacts13.cfix bodyFacts13.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st13.S5.tab) (Es := bodyEs13) (qs := bodyQs13)
    (ok := PRE_first_tail_x2_r0_body.st13.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site13 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts13
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site13 r hr) hi (MapOk.sub hm (sub_of_all bodySub13)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk13 r hr) hi hm ho hq)
    bodyLq13 rfl bodyNrLo13 (postSub_sound bodyPost13)
    (Nat.le_of_ble_eq_true bodyDrop13) (by decide) (Nat.le_of_ble_eq_true bodyDropH13) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN13) (by decide)
    bodyDv13 bodyDe13 bodyDl13 bodyDold13 bodyDfree13 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site14 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site14 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st14.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site14
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st14.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st14.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s321 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s322 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S321 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws14 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st14.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st14.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso14
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_14
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st14.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot14
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup14
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound14
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace14
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged14
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws14.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st14.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S321.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_14]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen14.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh14
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl14 : Conv.NClean (⟨19038, 16115, 2707967, 1841⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s321.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl14 (PRE_first_tail_x2_r0_body.cncl13 bodyNcl13)

theorem bodyClean14 : Conv.JClean (⟨19038, 16115, 2707967, 1841⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s321 :=
  PRE_first_tail_x2_r0_body.gjcl14 (PRE_first_tail_x2_r0_body.cjcl13 bodyClean13)

kernel_rfl bodyJsLe14 : Nat.ble PRE_first_tail_x2_r0_body.s299.next PRE_first_tail_x2_r0_body.s321.next = true
kernel_rfl bodyJsList14 : (PRE_first_tail_x2_r0_body.gjh14 ++ PRE_first_tail_x2_r0_body.cl14).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s321.next) PRE_first_tail_x2_r0_body.s323) = true
theorem bodyJs14 : JsHeapAbove PRE_first_tail_x2_r0_body.s321.next PRE_first_tail_x2_r0_body.s323 :=
  JsHeapAbove.glueSite bodyJs13 (Nat.le_of_ble_eq_true bodyJsLe14) PRE_first_tail_x2_r0_body.gjk14 PRE_first_tail_x2_r0_body.gjbd14 PRE_first_tail_x2_r0_body.cheap14 PRE_first_tail_x2_r0_body.zclbd14 bodyJsList14

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO301 : PRE_first_tail_x2_r0_body.S301.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S301.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr301 : bridgeOf PRE_first_tail_x2_r0_body.s301.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc301 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s301 PRE_first_tail_x2_r0_body.S301) = fun _ _ => true
kernel_rfl bodyAcc302 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s302 PRE_first_tail_x2_r0_body.S302) = fun _ _ => true
kernel_rfl bodyBr303 : bridgeOf PRE_first_tail_x2_r0_body.s303.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt302 : isHalt PRE_first_tail_x2_r0_body.s302.ctl = false
kernel_rfl bodyTop303 : noRetBlock PRE_first_tail_x2_r0_body.s303 = true
kernel_rfl bodyCnt301 : countersOkB PRE_first_tail_x2_r0_body.s301 PRE_first_tail_x2_r0_body.s303 = true
kernel_rfl bodyO303 : PRE_first_tail_x2_r0_body.S303.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S303.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr304 : bridgeOf PRE_first_tail_x2_r0_body.s304.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt303 : countersOkB PRE_first_tail_x2_r0_body.s303 PRE_first_tail_x2_r0_body.s304 = true
kernel_rfl bodyO304 : PRE_first_tail_x2_r0_body.S304.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S304.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc304 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s304 PRE_first_tail_x2_r0_body.S304) = fun _ _ => true
kernel_rfl bodyAcc308 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s308 PRE_first_tail_x2_r0_body.S308) = fun _ _ => true
kernel_rfl bodyBr309 : bridgeOf PRE_first_tail_x2_r0_body.s309.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt308 : isHalt PRE_first_tail_x2_r0_body.s308.ctl = false
kernel_rfl bodyTop309 : noRetBlock PRE_first_tail_x2_r0_body.s309 = true
kernel_rfl bodyCnt304 : countersOkB PRE_first_tail_x2_r0_body.s304 PRE_first_tail_x2_r0_body.s309 = true
kernel_rfl bodyO309 : PRE_first_tail_x2_r0_body.S309.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S309.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr310 : bridgeOf PRE_first_tail_x2_r0_body.s310.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt309 : countersOkB PRE_first_tail_x2_r0_body.s309 PRE_first_tail_x2_r0_body.s310 = true
kernel_rfl bodyO310 : PRE_first_tail_x2_r0_body.S310.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S310.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc310 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s310 PRE_first_tail_x2_r0_body.S310) = fun _ _ => true
kernel_rfl bodyAcc311 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s311 PRE_first_tail_x2_r0_body.S311) = fun _ _ => true
kernel_rfl bodyBr312 : bridgeOf PRE_first_tail_x2_r0_body.s312.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt311 : isHalt PRE_first_tail_x2_r0_body.s311.ctl = false
kernel_rfl bodyTop312 : noRetBlock PRE_first_tail_x2_r0_body.s312 = true
kernel_rfl bodyCnt310 : countersOkB PRE_first_tail_x2_r0_body.s310 PRE_first_tail_x2_r0_body.s312 = true
kernel_rfl bodyO312 : PRE_first_tail_x2_r0_body.S312.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S312.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr313 : bridgeOf PRE_first_tail_x2_r0_body.s313.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt312 : countersOkB PRE_first_tail_x2_r0_body.s312 PRE_first_tail_x2_r0_body.s313 = true
kernel_rfl bodyO313 : PRE_first_tail_x2_r0_body.S313.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S313.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc313 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s313 PRE_first_tail_x2_r0_body.S313) = fun _ _ => true
kernel_rfl bodyAcc314 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s314 PRE_first_tail_x2_r0_body.S314) = fun _ _ => true
kernel_rfl bodyBr315 : bridgeOf PRE_first_tail_x2_r0_body.s315.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt314 : isHalt PRE_first_tail_x2_r0_body.s314.ctl = false
kernel_rfl bodyTop315 : noRetBlock PRE_first_tail_x2_r0_body.s315 = true
kernel_rfl bodyCnt313 : countersOkB PRE_first_tail_x2_r0_body.s313 PRE_first_tail_x2_r0_body.s315 = true
kernel_rfl bodyO315 : PRE_first_tail_x2_r0_body.S315.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S315.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr316 : bridgeOf PRE_first_tail_x2_r0_body.s316.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt315 : countersOkB PRE_first_tail_x2_r0_body.s315 PRE_first_tail_x2_r0_body.s316 = true
kernel_rfl bodyO316 : PRE_first_tail_x2_r0_body.S316.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S316.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc316 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s316 PRE_first_tail_x2_r0_body.S316) = fun _ _ => true
kernel_rfl bodyAcc317 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s317 PRE_first_tail_x2_r0_body.S317) = fun _ _ => true
kernel_rfl bodyBr318 : bridgeOf PRE_first_tail_x2_r0_body.s318.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt317 : isHalt PRE_first_tail_x2_r0_body.s317.ctl = false
kernel_rfl bodyTop318 : noRetBlock PRE_first_tail_x2_r0_body.s318 = true
kernel_rfl bodyCnt316 : countersOkB PRE_first_tail_x2_r0_body.s316 PRE_first_tail_x2_r0_body.s318 = true
kernel_rfl bodyO318 : PRE_first_tail_x2_r0_body.S318.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S318.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr319 : bridgeOf PRE_first_tail_x2_r0_body.s319.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt318 : countersOkB PRE_first_tail_x2_r0_body.s318 PRE_first_tail_x2_r0_body.s319 = true
kernel_rfl bodyO319 : PRE_first_tail_x2_r0_body.S319.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S319.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc319 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s319 PRE_first_tail_x2_r0_body.S319) = fun _ _ => true
kernel_rfl bodyAcc320 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s320 PRE_first_tail_x2_r0_body.S320) = fun _ _ => true
kernel_rfl bodyBr321 : bridgeOf PRE_first_tail_x2_r0_body.s321.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt320 : isHalt PRE_first_tail_x2_r0_body.s320.ctl = false
kernel_rfl bodyTop321 : noRetBlock PRE_first_tail_x2_r0_body.s321 = true
kernel_rfl bodyCnt319 : countersOkB PRE_first_tail_x2_r0_body.s319 PRE_first_tail_x2_r0_body.s321 = true

theorem bodyGlue14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 225⟩ bodyM PRE_first_tail_x2_r0_body.s301 PRE_first_tail_x2_r0_body.S301)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 225⟩ bodyM PRE_first_tail_x2_r0_body.s321 PRE_first_tail_x2_r0_body.S321) 22252 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc301 PRE_first_tail_x2_r0_body.bodyRunSeg80 bodyAcc302 bodyHalt302 PRE_first_tail_x2_r0_body.bodyStepA81 bodyTop303 (fun _ hm => bodyO301 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr301).trans bodyInactive0) (bodyBr303.trans bodyBr301.symm) bodyCnt301 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x2_r0_body.sizeA81 PRE_first_tail_x2_r0_body.sizeArgsA81 PRE_first_tail_x2_r0_body.sizeSymA81 PRE_first_tail_x2_r0_body.sizeMlxA81 PRE_first_tail_x2_r0_body.sizePayA81 PRE_first_tail_x2_r0_body.sizeTaA81 PRE_first_tail_x2_r0_body.sizeDecA81 PRE_first_tail_x2_r0_body.sizePreA81 PRE_first_tail_x2_r0_body.bodyPatchB81 (fun _ hm => bodyO303 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr303).trans bodyInactive0) (bodyBr304.trans bodyBr303.symm) bodyCnt303 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc304 PRE_first_tail_x2_r0_body.bodyRunSeg81 bodyAcc308 bodyHalt308 PRE_first_tail_x2_r0_body.bodyStepA82 bodyTop309 (fun _ hm => bodyO304 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr304).trans bodyInactive0) (bodyBr309.trans bodyBr304.symm) bodyCnt304 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x2_r0_body.sizeA82 PRE_first_tail_x2_r0_body.sizeArgsA82 PRE_first_tail_x2_r0_body.sizeSymA82 PRE_first_tail_x2_r0_body.sizeMlxA82 PRE_first_tail_x2_r0_body.sizePayA82 PRE_first_tail_x2_r0_body.sizeTaA82 PRE_first_tail_x2_r0_body.sizeDecA82 PRE_first_tail_x2_r0_body.sizePreA82 PRE_first_tail_x2_r0_body.bodyPatchB82 (fun _ hm => bodyO309 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr309).trans bodyInactive0) (bodyBr310.trans bodyBr309.symm) bodyCnt309 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc310 PRE_first_tail_x2_r0_body.bodyRunSeg82 bodyAcc311 bodyHalt311 PRE_first_tail_x2_r0_body.bodyStepA83 bodyTop312 (fun _ hm => bodyO310 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr310).trans bodyInactive0) (bodyBr312.trans bodyBr310.symm) bodyCnt310 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x2_r0_body.sizeA83 PRE_first_tail_x2_r0_body.sizeArgsA83 PRE_first_tail_x2_r0_body.sizeSymA83 PRE_first_tail_x2_r0_body.sizeMlxA83 PRE_first_tail_x2_r0_body.sizePayA83 PRE_first_tail_x2_r0_body.sizeTaA83 PRE_first_tail_x2_r0_body.sizeDecA83 PRE_first_tail_x2_r0_body.sizePreA83 PRE_first_tail_x2_r0_body.bodyPatchB83 (fun _ hm => bodyO312 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr312).trans bodyInactive0) (bodyBr313.trans bodyBr312.symm) bodyCnt312 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc313 PRE_first_tail_x2_r0_body.bodyRunSeg83 bodyAcc314 bodyHalt314 PRE_first_tail_x2_r0_body.bodyStepA84 bodyTop315 (fun _ hm => bodyO313 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr313).trans bodyInactive0) (bodyBr315.trans bodyBr313.symm) bodyCnt313 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x2_r0_body.sizeA84 PRE_first_tail_x2_r0_body.sizeArgsA84 PRE_first_tail_x2_r0_body.sizeSymA84 PRE_first_tail_x2_r0_body.sizeMlxA84 PRE_first_tail_x2_r0_body.sizePayA84 PRE_first_tail_x2_r0_body.sizeTaA84 PRE_first_tail_x2_r0_body.sizeDecA84 PRE_first_tail_x2_r0_body.sizePreA84 PRE_first_tail_x2_r0_body.bodyPatchB84 (fun _ hm => bodyO315 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr315).trans bodyInactive0) (bodyBr316.trans bodyBr315.symm) bodyCnt315 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc316 PRE_first_tail_x2_r0_body.bodyRunSeg84 bodyAcc317 bodyHalt317 PRE_first_tail_x2_r0_body.bodyStepA85 bodyTop318 (fun _ hm => bodyO316 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr316).trans bodyInactive0) (bodyBr318.trans bodyBr316.symm) bodyCnt316 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) PRE_first_tail_x2_r0_body.sizeA85 PRE_first_tail_x2_r0_body.sizeArgsA85 PRE_first_tail_x2_r0_body.sizeSymA85 PRE_first_tail_x2_r0_body.sizeMlxA85 PRE_first_tail_x2_r0_body.sizePayA85 PRE_first_tail_x2_r0_body.sizeTaA85 PRE_first_tail_x2_r0_body.sizeDecA85 PRE_first_tail_x2_r0_body.sizePreA85 PRE_first_tail_x2_r0_body.bodyPatchB85 (fun _ hm => bodyO318 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr318).trans bodyInactive0) (bodyBr319.trans bodyBr318.symm) bodyCnt318 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 225⟩) bodyAcc319 PRE_first_tail_x2_r0_body.bodyRunSeg85 bodyAcc320 bodyHalt320 PRE_first_tail_x2_r0_body.bodyStepA86 bodyTop321 (fun _ hm => bodyO319 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr319).trans bodyInactive0) (bodyBr321.trans bodyBr319.symm) bodyCnt319 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift14 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S321.tab.length PRE_first_tail_x2_r0_body.s321.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P14.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P14 1859 PRE_first_tail_x2_r0_body.kappa14 PRE_first_tail_x2_r0_body.s323.ffi PRE_first_tail_x2_r0_body.s322.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_14
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_14
  have hcl : SSt (· < 1859) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s323.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S321.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_14] <;> decide) PRE_first_tail_x2_r0_body.cnodesK14 PRE_first_tail_x2_r0_body.cobjsK14
      PRE_first_tail_x2_r0_body.citemsK14 PRE_first_tail_x2_r0_body.cbd14 PRE_first_tail_x2_r0_body.csst14
  exact PRE_first_tail_x2_r0_body.cshift14 bodyNcl14 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_14] at this; exact this)


kernel_rfl bodyFramesEmpty14 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s322 a).isEmpty) = true
kernel_rfl bodyJsRoots14 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s321.next) PRE_first_tail_x2_r0_body.s323.trace PRE_first_tail_x2_r0_body.s323 = true
kernel_rfl bodyJsNative14 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s323.ffi) = true
kernel_rfl bodyLow14 : (PRE_first_tail_x2_r0_body.cws14 ++ PRE_first_tail_x2_r0_body.ws14).all (Nat.ble 9) = true
kernel_rfl bodyCntM14 : countersOkB PRE_first_tail_x2_r0_body.s321 PRE_first_tail_x2_r0_body.s322 = true
kernel_rfl bodyHi14 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s323.ffi).next setupP.E = true
kernel_rfl bodyNhi14 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s323.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge14 : bridgeOf PRE_first_tail_x2_r0_body.s322.ffi = bridgeOf PRE_first_tail_x2_r0_body.s321.ffi
kernel_rfl bodyNN14 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s321.ffi).nnext PRE_first_tail_x2_r0_body.P14.NL = true
kernel_rfl bodyXn14 : Nat.ble (⟨19041, 16142, 2707973, 1859⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s323.ffi).next = true
kernel_rfl bodyLo14 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s323.ffi).next = true
theorem bodyFacts14 : BodySiteFacts PRE_first_tail_x2_r0_body.s321 PRE_first_tail_x2_r0_body.s322 PRE_first_tail_x2_r0_body.s323 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S321 PRE_first_tail_x2_r0_body.S322 PRE_first_tail_x2_r0_body.S323
    PRE_first_tail_x2_r0_body.ws14 PRE_first_tail_x2_r0_body.cws14 PRE_first_tail_x2_r0_body.nr14 PRE_first_tail_x2_r0_body.pl14 PRE_first_tail_x2_r0_body.cl14 2709122 1859 PRE_first_tail_x2_r0_body.kd14 PRE_first_tail_x2_r0_body.kappa14 PRE_first_tail_x2_r0_body.P14
    ⟨19038, 16115, 2707967, 1841⟩ ⟨19041, 16142, 2707973, 1859⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap14
  clean := bodyClean14
  cfix := PRE_first_tail_x2_r0_body.cfix14
  zpl := PRE_first_tail_x2_r0_body.zpl14
  zplnd := PRE_first_tail_x2_r0_body.zplnd14
  zn1 := PRE_first_tail_x2_r0_body.zn114
  zfirst := PRE_first_tail_x2_r0_body.zfirst14
  zscn := PRE_first_tail_x2_r0_body.zscn14
  zsmn := PRE_first_tail_x2_r0_body.zsmn14
  zgrow := PRE_first_tail_x2_r0_body.zgrow14
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab14
  zfresh := PRE_first_tail_x2_r0_body.zfresh14
  zcnd := PRE_first_tail_x2_r0_body.zcnd14
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi14
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt14
  zgP := PRE_first_tail_x2_r0_body.zg14_2665
  zkP := PRE_first_tail_x2_r0_body.zk14_2665
  zmP := PRE_first_tail_x2_r0_body.zm14_2665
  zgC := PRE_first_tail_x2_r0_body.zg14_2673467
  zkC := PRE_first_tail_x2_r0_body.zk14_2673467
  zmC := PRE_first_tail_x2_r0_body.zm14_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw14_2673472
  zwV := PRE_first_tail_x2_r0_body.zw14_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap14
  zclbd := PRE_first_tail_x2_r0_body.zclbd14
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap14 PRE_first_tail_x2_r0_body.stFoot14 PRE_first_tail_x2_r0_body.iso14 PRE_first_tail_x2_r0_body.zwr14
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP14
  csupp := PRE_first_tail_x2_r0_body.csupp14
  cbound := PRE_first_tail_x2_r0_body.cbound14
  zimg := PRE_first_tail_x2_r0_body.zimg14
  zctl := PRE_first_tail_x2_r0_body.zctl14
  zstack := PRE_first_tail_x2_r0_body.zstack14
  zjobs := PRE_first_tail_x2_r0_body.zjobs14
  zstores := PRE_first_tail_x2_r0_body.zstores14
  zroots := PRE_first_tail_x2_r0_body.zroots14
  znC := PRE_first_tail_x2_r0_body.znC14
  ctab := PRE_first_tail_x2_r0_body.ctab14
  zbin := PRE_first_tail_x2_r0_body.zbin14
  cbridge := PRE_first_tail_x2_r0_body.cbridge14
  sbridge := bodyBridge14
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj14
  cshiftR := fun h hNL => bodyCshift14 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN14
  raised := PRE_first_tail_x2_r0_body.raised14
  cbigs := PRE_first_tail_x2_r0_body.cbigs14
  cjcl := PRE_first_tail_x2_r0_body.cjcl14
  xnLe := Nat.le_of_ble_eq_true bodyXn14
  loLe := Nat.le_of_ble_eq_true bodyLo14
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB14
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
noncomputable def bodyEs14 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr14.map fun r => nth? PRE_first_tail_x2_r0_body.st14.S5.tab r
kernel_rfl bodyResChk14 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs14 bodyQs14) = true
kernel_rfl bodyLq14 : bodyQs14.length = PRE_first_tail_x2_r0_body.cws14.length
kernel_rfl bodyNrLo14 : PRE_first_tail_x2_r0_body.nr14.all (Nat.ble PRE_first_tail_x2_r0_body.S321.tab.length) = true
kernel_rfl bodySub14 : (Oracles.PRE_first_tail_x2_r0_body.map_site14.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost14 : postSubB bodyM PRE_first_tail_x2_r0_body.ws14 PRE_first_tail_x2_r0_body.cws14 bodyQs14 = true
kernel_rfl bodyDrop14 : Nat.ble (17803 + (PRE_first_tail_x2_r0_body.s322.next - PRE_first_tail_x2_r0_body.s323.next)) 18952 = true
kernel_rfl bodyDropH14 : Nat.ble (302 + ((mlxOf PRE_first_tail_x2_r0_body.s322.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s323.ffi).next)) 327 = true
kernel_rfl bodyDropN14 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s322.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s323.ffi).nnext)) 0 = true
kernel_rfl bodyDv14 : bodyΘ.1.take 243 = bodyΘ.1.take 225 ++ PRE_first_tail_x2_r0_body.cws14
kernel_rfl bodyDe14 : bodyΘ.2.take 243 = bodyΘ.2.take 225 ++ PRE_first_tail_x2_r0_body.nr14.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st14.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 225) (bodyΘ.2.take 225)))
kernel_rfl bodyDl14 : (bodyΘ.1.take 225).length = (bodyΘ.2.take 225).length
kernel_rfl bodyDold14 : (bodyΘ.1.take 225).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws14).isNone && !PRE_first_tail_x2_r0_body.ws14.contains v) = true
kernel_rfl bodyDfree14 : (bodyΘ.2.take 243).all (fun e => (PRE_first_tail_x2_r0_body.cws14 ++ PRE_first_tail_x2_r0_body.ws14).all fun w => e.noVar w) = true

theorem bodyStep14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 225⟩ bodyM PRE_first_tail_x2_r0_body.s321 PRE_first_tail_x2_r0_body.S321)
      (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 243⟩ bodyM PRE_first_tail_x2_r0_body.s323 PRE_first_tail_x2_r0_body.S323) (11334 + 1) :=
  bodySite bodyFacts14.cfix bodyFacts14.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st14.S5.tab) (Es := bodyEs14) (qs := bodyQs14)
    (ok := PRE_first_tail_x2_r0_body.st14.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site14 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts14
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site14 r hr) hi (MapOk.sub hm (sub_of_all bodySub14)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk14 r hr) hi hm ho hq)
    bodyLq14 rfl bodyNrLo14 (postSub_sound bodyPost14)
    (Nat.le_of_ble_eq_true bodyDrop14) (by decide) (Nat.le_of_ble_eq_true bodyDropH14) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN14) (by decide)
    bodyDv14 bodyDe14 bodyDl14 bodyDold14 bodyDfree14 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n), (1337, Q.n), (1338, Q.n), (1340, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1377, Q.n), (1378, Q.n), (1380, Q.n), (1381, Q.n), (1382, Q.n), (1383, Q.n), (1384, Q.n), (1387, Q.n), (1388, Q.n), (1390, Q.n), (1391, Q.n), (1392, Q.n), (1393, Q.n), (1394, Q.n), (1426, Q.n), (1427, Q.n), (1429, Q.n), (1430, Q.n), (1431, Q.n), (1432, Q.n), (1433, Q.n), (1436, Q.n), (1437, Q.n), (1439, Q.n), (1440, Q.n), (1441, Q.n), (1442, Q.n), (1443, Q.n), (1475, Q.n), (1476, Q.n), (1478, Q.n), (1479, Q.n), (1480, Q.n), (1481, Q.n), (1482, Q.n), (1485, Q.n), (1486, Q.n), (1488, Q.n), (1489, Q.n), (1490, Q.n), (1491, Q.n), (1492, Q.n), (1510, Q.n), (1511, Q.n), (1513, Q.n), (1515, Q.n), (1516, Q.n), (1517, Q.n), (1518, Q.n), (1550, Q.n), (1551, Q.n), (1553, Q.n), (1554, Q.n), (1555, Q.n), (1556, Q.n), (1557, Q.n), (1560, Q.n), (1561, Q.n), (1563, Q.n), (1564, Q.n), (1565, Q.n), (1566, Q.n), (1567, Q.n), (1599, Q.n), (1600, Q.n), (1602, Q.n), (1603, Q.n), (1604, Q.n), (1605, Q.n), (1606, Q.n), (1609, Q.n), (1610, Q.n), (1612, Q.n), (1613, Q.n), (1614, Q.n), (1615, Q.n), (1616, Q.n), (1648, Q.n), (1649, Q.n), (1651, Q.n), (1652, Q.n), (1653, Q.n), (1654, Q.n), (1655, Q.n), (1658, Q.n), (1659, Q.n), (1661, Q.n), (1662, Q.n), (1663, Q.n), (1664, Q.n), (1665, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site15 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st15.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site15
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st15.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st15.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s342 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s343 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S342 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws15 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st15.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st15.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso15
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_15
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st15.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot15
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup15
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound15
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace15
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged15
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws15.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st15.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S342.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_15]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen15.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh15
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl15 : Conv.NClean (⟨19101, 16187, 2710470, 1971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s342.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl15 (PRE_first_tail_x2_r0_body.cncl14 bodyNcl14)

theorem bodyClean15 : Conv.JClean (⟨19101, 16187, 2710470, 1971⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s342 :=
  PRE_first_tail_x2_r0_body.gjcl15 (PRE_first_tail_x2_r0_body.cjcl14 bodyClean14)

kernel_rfl bodyJsLe15 : Nat.ble PRE_first_tail_x2_r0_body.s321.next PRE_first_tail_x2_r0_body.s342.next = true
kernel_rfl bodyJsList15 : (PRE_first_tail_x2_r0_body.gjh15 ++ PRE_first_tail_x2_r0_body.cl15).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s342.next) PRE_first_tail_x2_r0_body.s344) = true
theorem bodyJs15 : JsHeapAbove PRE_first_tail_x2_r0_body.s342.next PRE_first_tail_x2_r0_body.s344 :=
  JsHeapAbove.glueSite bodyJs14 (Nat.le_of_ble_eq_true bodyJsLe15) PRE_first_tail_x2_r0_body.gjk15 PRE_first_tail_x2_r0_body.gjbd15 PRE_first_tail_x2_r0_body.cheap15 PRE_first_tail_x2_r0_body.zclbd15 bodyJsList15

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO323 : PRE_first_tail_x2_r0_body.S323.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S323.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr323 : bridgeOf PRE_first_tail_x2_r0_body.s323.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc323 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s323 PRE_first_tail_x2_r0_body.S323) = fun _ _ => true
kernel_rfl bodyAcc324 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s324 PRE_first_tail_x2_r0_body.S324) = fun _ _ => true
kernel_rfl bodyBr325 : bridgeOf PRE_first_tail_x2_r0_body.s325.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt324 : isHalt PRE_first_tail_x2_r0_body.s324.ctl = false
kernel_rfl bodyTop325 : noRetBlock PRE_first_tail_x2_r0_body.s325 = true
kernel_rfl bodyCnt323 : countersOkB PRE_first_tail_x2_r0_body.s323 PRE_first_tail_x2_r0_body.s325 = true
kernel_rfl bodyO325 : PRE_first_tail_x2_r0_body.S325.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S325.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr326 : bridgeOf PRE_first_tail_x2_r0_body.s326.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt325 : countersOkB PRE_first_tail_x2_r0_body.s325 PRE_first_tail_x2_r0_body.s326 = true
kernel_rfl bodyO326 : PRE_first_tail_x2_r0_body.S326.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S326.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc326 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s326 PRE_first_tail_x2_r0_body.S326) = fun _ _ => true
kernel_rfl bodyAcc330 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s330 PRE_first_tail_x2_r0_body.S330) = fun _ _ => true
kernel_rfl bodyBr331 : bridgeOf PRE_first_tail_x2_r0_body.s331.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt330 : isHalt PRE_first_tail_x2_r0_body.s330.ctl = false
kernel_rfl bodyTop331 : noRetBlock PRE_first_tail_x2_r0_body.s331 = true
kernel_rfl bodyCnt326 : countersOkB PRE_first_tail_x2_r0_body.s326 PRE_first_tail_x2_r0_body.s331 = true
kernel_rfl bodyO331 : PRE_first_tail_x2_r0_body.S331.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S331.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr332 : bridgeOf PRE_first_tail_x2_r0_body.s332.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt331 : countersOkB PRE_first_tail_x2_r0_body.s331 PRE_first_tail_x2_r0_body.s332 = true
kernel_rfl bodyO332 : PRE_first_tail_x2_r0_body.S332.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S332.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc332 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s332 PRE_first_tail_x2_r0_body.S332) = fun _ _ => true
kernel_rfl bodyAcc334 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s334 PRE_first_tail_x2_r0_body.S334) = fun _ _ => true
kernel_rfl bodyBr335 : bridgeOf PRE_first_tail_x2_r0_body.s335.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt334 : isHalt PRE_first_tail_x2_r0_body.s334.ctl = false
kernel_rfl bodyTop335 : noRetBlock PRE_first_tail_x2_r0_body.s335 = true
kernel_rfl bodyCnt332 : countersOkB PRE_first_tail_x2_r0_body.s332 PRE_first_tail_x2_r0_body.s335 = true
kernel_rfl bodyO335 : PRE_first_tail_x2_r0_body.S335.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S335.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr336 : bridgeOf PRE_first_tail_x2_r0_body.s336.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt335 : countersOkB PRE_first_tail_x2_r0_body.s335 PRE_first_tail_x2_r0_body.s336 = true
kernel_rfl bodyO336 : PRE_first_tail_x2_r0_body.S336.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S336.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc336 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s336 PRE_first_tail_x2_r0_body.S336) = fun _ _ => true
kernel_rfl bodyAcc337 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s337 PRE_first_tail_x2_r0_body.S337) = fun _ _ => true
kernel_rfl bodyBr338 : bridgeOf PRE_first_tail_x2_r0_body.s338.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt337 : isHalt PRE_first_tail_x2_r0_body.s337.ctl = false
kernel_rfl bodyTop338 : noRetBlock PRE_first_tail_x2_r0_body.s338 = true
kernel_rfl bodyCnt336 : countersOkB PRE_first_tail_x2_r0_body.s336 PRE_first_tail_x2_r0_body.s338 = true
kernel_rfl bodyO338 : PRE_first_tail_x2_r0_body.S338.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S338.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr339 : bridgeOf PRE_first_tail_x2_r0_body.s339.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt338 : countersOkB PRE_first_tail_x2_r0_body.s338 PRE_first_tail_x2_r0_body.s339 = true
kernel_rfl bodyO339 : PRE_first_tail_x2_r0_body.S339.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S339.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc339 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s339 PRE_first_tail_x2_r0_body.S339) = fun _ _ => true
kernel_rfl bodyAcc341 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s341 PRE_first_tail_x2_r0_body.S341) = fun _ _ => true
kernel_rfl bodyBr342 : bridgeOf PRE_first_tail_x2_r0_body.s342.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt341 : isHalt PRE_first_tail_x2_r0_body.s341.ctl = false
kernel_rfl bodyTop342 : noRetBlock PRE_first_tail_x2_r0_body.s342 = true
kernel_rfl bodyCnt339 : countersOkB PRE_first_tail_x2_r0_body.s339 PRE_first_tail_x2_r0_body.s342 = true

theorem bodyGlue15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 243⟩ bodyM PRE_first_tail_x2_r0_body.s323 PRE_first_tail_x2_r0_body.S323)
      (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 243⟩ bodyM PRE_first_tail_x2_r0_body.s342 PRE_first_tail_x2_r0_body.S342) 24692 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc323 PRE_first_tail_x2_r0_body.bodyRunSeg86 bodyAcc324 bodyHalt324 PRE_first_tail_x2_r0_body.bodyStepA87 bodyTop325 (fun _ hm => bodyO323 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr323).trans bodyInactive0) (bodyBr325.trans bodyBr323.symm) bodyCnt323 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) PRE_first_tail_x2_r0_body.sizeA87 PRE_first_tail_x2_r0_body.sizeArgsA87 PRE_first_tail_x2_r0_body.sizeSymA87 PRE_first_tail_x2_r0_body.sizeMlxA87 PRE_first_tail_x2_r0_body.sizePayA87 PRE_first_tail_x2_r0_body.sizeTaA87 PRE_first_tail_x2_r0_body.sizeDecA87 PRE_first_tail_x2_r0_body.sizePreA87 PRE_first_tail_x2_r0_body.bodyPatchB87 (fun _ hm => bodyO325 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr325).trans bodyInactive0) (bodyBr326.trans bodyBr325.symm) bodyCnt325 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc326 PRE_first_tail_x2_r0_body.bodyRunSeg87 bodyAcc330 bodyHalt330 PRE_first_tail_x2_r0_body.bodyStepA88 bodyTop331 (fun _ hm => bodyO326 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr326).trans bodyInactive0) (bodyBr331.trans bodyBr326.symm) bodyCnt326 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) PRE_first_tail_x2_r0_body.sizeA88 PRE_first_tail_x2_r0_body.sizeArgsA88 PRE_first_tail_x2_r0_body.sizeSymA88 PRE_first_tail_x2_r0_body.sizeMlxA88 PRE_first_tail_x2_r0_body.sizePayA88 PRE_first_tail_x2_r0_body.sizeTaA88 PRE_first_tail_x2_r0_body.sizeDecA88 PRE_first_tail_x2_r0_body.sizePreA88 PRE_first_tail_x2_r0_body.bodyPatchB88 (fun _ hm => bodyO331 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr331).trans bodyInactive0) (bodyBr332.trans bodyBr331.symm) bodyCnt331 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc332 PRE_first_tail_x2_r0_body.bodyRunSeg88 bodyAcc334 bodyHalt334 PRE_first_tail_x2_r0_body.bodyStepA89 bodyTop335 (fun _ hm => bodyO332 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr332).trans bodyInactive0) (bodyBr335.trans bodyBr332.symm) bodyCnt332 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) PRE_first_tail_x2_r0_body.sizeA89 PRE_first_tail_x2_r0_body.sizeArgsA89 PRE_first_tail_x2_r0_body.sizeSymA89 PRE_first_tail_x2_r0_body.sizeMlxA89 PRE_first_tail_x2_r0_body.sizePayA89 PRE_first_tail_x2_r0_body.sizeTaA89 PRE_first_tail_x2_r0_body.sizeDecA89 PRE_first_tail_x2_r0_body.sizePreA89 PRE_first_tail_x2_r0_body.bodyPatchB89 (fun _ hm => bodyO335 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr335).trans bodyInactive0) (bodyBr336.trans bodyBr335.symm) bodyCnt335 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc336 PRE_first_tail_x2_r0_body.bodyRunSeg89 bodyAcc337 bodyHalt337 PRE_first_tail_x2_r0_body.bodyStepA90 bodyTop338 (fun _ hm => bodyO336 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr336).trans bodyInactive0) (bodyBr338.trans bodyBr336.symm) bodyCnt336 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) PRE_first_tail_x2_r0_body.sizeA90 PRE_first_tail_x2_r0_body.sizeArgsA90 PRE_first_tail_x2_r0_body.sizeSymA90 PRE_first_tail_x2_r0_body.sizeMlxA90 PRE_first_tail_x2_r0_body.sizePayA90 PRE_first_tail_x2_r0_body.sizeTaA90 PRE_first_tail_x2_r0_body.sizeDecA90 PRE_first_tail_x2_r0_body.sizePreA90 PRE_first_tail_x2_r0_body.bodyPatchB90 (fun _ hm => bodyO338 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr338).trans bodyInactive0) (bodyBr339.trans bodyBr338.symm) bodyCnt338 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 243⟩) bodyAcc339 PRE_first_tail_x2_r0_body.bodyRunSeg90 bodyAcc341 bodyHalt341 PRE_first_tail_x2_r0_body.bodyStepA91 bodyTop342 (fun _ hm => bodyO339 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr339).trans bodyInactive0) (bodyBr342.trans bodyBr339.symm) bodyCnt339 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift15 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S342.tab.length PRE_first_tail_x2_r0_body.s342.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P15.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P15 1980 PRE_first_tail_x2_r0_body.kappa15 PRE_first_tail_x2_r0_body.s344.ffi PRE_first_tail_x2_r0_body.s343.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_15
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_15
  have hcl : SSt (· < 1980) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s344.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S342.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_15] <;> decide) PRE_first_tail_x2_r0_body.cnodesK15 PRE_first_tail_x2_r0_body.cobjsK15
      PRE_first_tail_x2_r0_body.citemsK15 PRE_first_tail_x2_r0_body.cbd15 PRE_first_tail_x2_r0_body.csst15
  exact PRE_first_tail_x2_r0_body.cshift15 bodyNcl15 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_15] at this; exact this)


kernel_rfl bodyFramesEmpty15 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s343 a).isEmpty) = true
kernel_rfl bodyJsRoots15 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s342.next) PRE_first_tail_x2_r0_body.s344.trace PRE_first_tail_x2_r0_body.s344 = true
kernel_rfl bodyJsNative15 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s344.ffi) = true
kernel_rfl bodyLow15 : (PRE_first_tail_x2_r0_body.cws15 ++ PRE_first_tail_x2_r0_body.ws15).all (Nat.ble 9) = true
kernel_rfl bodyCntM15 : countersOkB PRE_first_tail_x2_r0_body.s342 PRE_first_tail_x2_r0_body.s343 = true
kernel_rfl bodyHi15 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s344.ffi).next setupP.E = true
kernel_rfl bodyNhi15 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s344.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge15 : bridgeOf PRE_first_tail_x2_r0_body.s343.ffi = bridgeOf PRE_first_tail_x2_r0_body.s342.ffi
kernel_rfl bodyNN15 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s342.ffi).nnext PRE_first_tail_x2_r0_body.P15.NL = true
kernel_rfl bodyXn15 : Nat.ble (⟨19105, 16193, 2710485, 1980⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s344.ffi).next = true
kernel_rfl bodyLo15 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s344.ffi).next = true
theorem bodyFacts15 : BodySiteFacts PRE_first_tail_x2_r0_body.s342 PRE_first_tail_x2_r0_body.s343 PRE_first_tail_x2_r0_body.s344 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S342 PRE_first_tail_x2_r0_body.S343 PRE_first_tail_x2_r0_body.S344
    PRE_first_tail_x2_r0_body.ws15 PRE_first_tail_x2_r0_body.cws15 PRE_first_tail_x2_r0_body.nr15 PRE_first_tail_x2_r0_body.pl15 PRE_first_tail_x2_r0_body.cl15 2710835 1980 PRE_first_tail_x2_r0_body.kd15 PRE_first_tail_x2_r0_body.kappa15 PRE_first_tail_x2_r0_body.P15
    ⟨19101, 16187, 2710470, 1971⟩ ⟨19105, 16193, 2710485, 1980⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap15
  clean := bodyClean15
  cfix := PRE_first_tail_x2_r0_body.cfix15
  zpl := PRE_first_tail_x2_r0_body.zpl15
  zplnd := PRE_first_tail_x2_r0_body.zplnd15
  zn1 := PRE_first_tail_x2_r0_body.zn115
  zfirst := PRE_first_tail_x2_r0_body.zfirst15
  zscn := PRE_first_tail_x2_r0_body.zscn15
  zsmn := PRE_first_tail_x2_r0_body.zsmn15
  zgrow := PRE_first_tail_x2_r0_body.zgrow15
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab15
  zfresh := PRE_first_tail_x2_r0_body.zfresh15
  zcnd := PRE_first_tail_x2_r0_body.zcnd15
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi15
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt15
  zgP := PRE_first_tail_x2_r0_body.zg15_2665
  zkP := PRE_first_tail_x2_r0_body.zk15_2665
  zmP := PRE_first_tail_x2_r0_body.zm15_2665
  zgC := PRE_first_tail_x2_r0_body.zg15_2673467
  zkC := PRE_first_tail_x2_r0_body.zk15_2673467
  zmC := PRE_first_tail_x2_r0_body.zm15_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw15_2673472
  zwV := PRE_first_tail_x2_r0_body.zw15_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap15
  zclbd := PRE_first_tail_x2_r0_body.zclbd15
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap15 PRE_first_tail_x2_r0_body.stFoot15 PRE_first_tail_x2_r0_body.iso15 PRE_first_tail_x2_r0_body.zwr15
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP15
  csupp := PRE_first_tail_x2_r0_body.csupp15
  cbound := PRE_first_tail_x2_r0_body.cbound15
  zimg := PRE_first_tail_x2_r0_body.zimg15
  zctl := PRE_first_tail_x2_r0_body.zctl15
  zstack := PRE_first_tail_x2_r0_body.zstack15
  zjobs := PRE_first_tail_x2_r0_body.zjobs15
  zstores := PRE_first_tail_x2_r0_body.zstores15
  zroots := PRE_first_tail_x2_r0_body.zroots15
  znC := PRE_first_tail_x2_r0_body.znC15
  ctab := PRE_first_tail_x2_r0_body.ctab15
  zbin := PRE_first_tail_x2_r0_body.zbin15
  cbridge := PRE_first_tail_x2_r0_body.cbridge15
  sbridge := bodyBridge15
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj15
  cshiftR := fun h hNL => bodyCshift15 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN15
  raised := PRE_first_tail_x2_r0_body.raised15
  cbigs := PRE_first_tail_x2_r0_body.cbigs15
  cjcl := PRE_first_tail_x2_r0_body.cjcl15
  xnLe := Nat.le_of_ble_eq_true bodyXn15
  loLe := Nat.le_of_ble_eq_true bodyLo15
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB15
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
noncomputable def bodyEs15 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr15.map fun r => nth? PRE_first_tail_x2_r0_body.st15.S3.tab r
kernel_rfl bodyResChk15 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs15 bodyQs15) = true
kernel_rfl bodyLq15 : bodyQs15.length = PRE_first_tail_x2_r0_body.cws15.length
kernel_rfl bodyNrLo15 : PRE_first_tail_x2_r0_body.nr15.all (Nat.ble PRE_first_tail_x2_r0_body.S342.tab.length) = true
kernel_rfl bodySub15 : (Oracles.PRE_first_tail_x2_r0_body.map_site15.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost15 : postSubB bodyM PRE_first_tail_x2_r0_body.ws15 PRE_first_tail_x2_r0_body.cws15 bodyQs15 = true
kernel_rfl bodyDrop15 : Nat.ble (18952 + (PRE_first_tail_x2_r0_body.s343.next - PRE_first_tail_x2_r0_body.s344.next)) 19302 = true
kernel_rfl bodyDropH15 : Nat.ble (327 + ((mlxOf PRE_first_tail_x2_r0_body.s343.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s344.ffi).next)) 329 = true
kernel_rfl bodyDropN15 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s343.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s344.ffi).nnext)) 0 = true
kernel_rfl bodyDv15 : bodyΘ.1.take 252 = bodyΘ.1.take 243 ++ PRE_first_tail_x2_r0_body.cws15
kernel_rfl bodyDe15 : bodyΘ.2.take 252 = bodyΘ.2.take 243 ++ PRE_first_tail_x2_r0_body.nr15.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st15.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 243) (bodyΘ.2.take 243)))
kernel_rfl bodyDl15 : (bodyΘ.1.take 243).length = (bodyΘ.2.take 243).length
kernel_rfl bodyDold15 : (bodyΘ.1.take 243).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws15).isNone && !PRE_first_tail_x2_r0_body.ws15.contains v) = true
kernel_rfl bodyDfree15 : (bodyΘ.2.take 252).all (fun e => (PRE_first_tail_x2_r0_body.cws15 ++ PRE_first_tail_x2_r0_body.ws15).all fun w => e.noVar w) = true

theorem bodyStep15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 243⟩ bodyM PRE_first_tail_x2_r0_body.s342 PRE_first_tail_x2_r0_body.S342)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19302, 329, 0, 252⟩ bodyM PRE_first_tail_x2_r0_body.s344 PRE_first_tail_x2_r0_body.S344) (3452 + 1) :=
  bodySite bodyFacts15.cfix bodyFacts15.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x2_r0_body.st15.S3.tab) (Es := bodyEs15) (qs := bodyQs15)
    (ok := PRE_first_tail_x2_r0_body.st15.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site15 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts15
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site15 r hr) hi (MapOk.sub hm (sub_of_all bodySub15)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk15 r hr) hi hm ho hq)
    bodyLq15 rfl bodyNrLo15 (postSub_sound bodyPost15)
    (Nat.le_of_ble_eq_true bodyDrop15) (by decide) (Nat.le_of_ble_eq_true bodyDropH15) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN15) (by decide)
    bodyDv15 bodyDe15 bodyDl15 bodyDold15 bodyDfree15 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end
