import host.sim.compose.CompactOffset
import host.sim.compose.a4b.VWG2
import host.sim.template.a4pre_first_tail_x15_r0_body.H52
import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl

noncomputable def bodyCompactionDrops : List Nat := [
  PRE_first_tail_x15_r0_body.s15.next - PRE_first_tail_x15_r0_body.s16.next,
  PRE_first_tail_x15_r0_body.s22.next - PRE_first_tail_x15_r0_body.s23.next,
  PRE_first_tail_x15_r0_body.s26.next - PRE_first_tail_x15_r0_body.s27.next,
  PRE_first_tail_x15_r0_body.s42.next - PRE_first_tail_x15_r0_body.s43.next,
  PRE_first_tail_x15_r0_body.s49.next - PRE_first_tail_x15_r0_body.s50.next,
  PRE_first_tail_x15_r0_body.s53.next - PRE_first_tail_x15_r0_body.s54.next,
  PRE_first_tail_x15_r0_body.s69.next - PRE_first_tail_x15_r0_body.s70.next,
  PRE_first_tail_x15_r0_body.s76.next - PRE_first_tail_x15_r0_body.s77.next,
  PRE_first_tail_x15_r0_body.s80.next - PRE_first_tail_x15_r0_body.s81.next,
  PRE_first_tail_x15_r0_body.s93.next - PRE_first_tail_x15_r0_body.s94.next,
  PRE_first_tail_x15_r0_body.s100.next - PRE_first_tail_x15_r0_body.s101.next,
  PRE_first_tail_x15_r0_body.s104.next - PRE_first_tail_x15_r0_body.s105.next,
  PRE_first_tail_x15_r0_body.s120.next - PRE_first_tail_x15_r0_body.s121.next,
  PRE_first_tail_x15_r0_body.s127.next - PRE_first_tail_x15_r0_body.s128.next,
  PRE_first_tail_x15_r0_body.s131.next - PRE_first_tail_x15_r0_body.s132.next,
  PRE_first_tail_x15_r0_body.s147.next - PRE_first_tail_x15_r0_body.s148.next,
  PRE_first_tail_x15_r0_body.s154.next - PRE_first_tail_x15_r0_body.s155.next,
  PRE_first_tail_x15_r0_body.s158.next - PRE_first_tail_x15_r0_body.s159.next,
  PRE_first_tail_x15_r0_body.s174.next - PRE_first_tail_x15_r0_body.s175.next,
  PRE_first_tail_x15_r0_body.s181.next - PRE_first_tail_x15_r0_body.s182.next,
  PRE_first_tail_x15_r0_body.s185.next - PRE_first_tail_x15_r0_body.s186.next,
  PRE_first_tail_x15_r0_body.s198.next - PRE_first_tail_x15_r0_body.s199.next,
  PRE_first_tail_x15_r0_body.s205.next - PRE_first_tail_x15_r0_body.s206.next,
  PRE_first_tail_x15_r0_body.s209.next - PRE_first_tail_x15_r0_body.s210.next,
  PRE_first_tail_x15_r0_body.s225.next - PRE_first_tail_x15_r0_body.s226.next,
  PRE_first_tail_x15_r0_body.s232.next - PRE_first_tail_x15_r0_body.s233.next,
  PRE_first_tail_x15_r0_body.s236.next - PRE_first_tail_x15_r0_body.s237.next,
  PRE_first_tail_x15_r0_body.s252.next - PRE_first_tail_x15_r0_body.s253.next,
  PRE_first_tail_x15_r0_body.s259.next - PRE_first_tail_x15_r0_body.s260.next,
  PRE_first_tail_x15_r0_body.s263.next - PRE_first_tail_x15_r0_body.s264.next,
  PRE_first_tail_x15_r0_body.s279.next - PRE_first_tail_x15_r0_body.s280.next,
  PRE_first_tail_x15_r0_body.s286.next - PRE_first_tail_x15_r0_body.s287.next,
  PRE_first_tail_x15_r0_body.s290.next - PRE_first_tail_x15_r0_body.s291.next,
  PRE_first_tail_x15_r0_body.s303.next - PRE_first_tail_x15_r0_body.s304.next,
  PRE_first_tail_x15_r0_body.s310.next - PRE_first_tail_x15_r0_body.s311.next,
  PRE_first_tail_x15_r0_body.s314.next - PRE_first_tail_x15_r0_body.s315.next,
  PRE_first_tail_x15_r0_body.s330.next - PRE_first_tail_x15_r0_body.s331.next,
  PRE_first_tail_x15_r0_body.s337.next - PRE_first_tail_x15_r0_body.s338.next,
  PRE_first_tail_x15_r0_body.s341.next - PRE_first_tail_x15_r0_body.s342.next,
  PRE_first_tail_x15_r0_body.s357.next - PRE_first_tail_x15_r0_body.s358.next,
  PRE_first_tail_x15_r0_body.s364.next - PRE_first_tail_x15_r0_body.s365.next,
  PRE_first_tail_x15_r0_body.s368.next - PRE_first_tail_x15_r0_body.s369.next,
  PRE_first_tail_x15_r0_body.s384.next - PRE_first_tail_x15_r0_body.s385.next,
  PRE_first_tail_x15_r0_body.s391.next - PRE_first_tail_x15_r0_body.s392.next,
  PRE_first_tail_x15_r0_body.s395.next - PRE_first_tail_x15_r0_body.s396.next,
  PRE_first_tail_x15_r0_body.s408.next - PRE_first_tail_x15_r0_body.s409.next,
  PRE_first_tail_x15_r0_body.s415.next - PRE_first_tail_x15_r0_body.s416.next,
  PRE_first_tail_x15_r0_body.s419.next - PRE_first_tail_x15_r0_body.s420.next,
  PRE_first_tail_x15_r0_body.s435.next - PRE_first_tail_x15_r0_body.s436.next,
  PRE_first_tail_x15_r0_body.s442.next - PRE_first_tail_x15_r0_body.s443.next,
  PRE_first_tail_x15_r0_body.s446.next - PRE_first_tail_x15_r0_body.s447.next,
  PRE_first_tail_x15_r0_body.s462.next - PRE_first_tail_x15_r0_body.s463.next,
  PRE_first_tail_x15_r0_body.s469.next - PRE_first_tail_x15_r0_body.s470.next,
  PRE_first_tail_x15_r0_body.s473.next - PRE_first_tail_x15_r0_body.s474.next,
  PRE_first_tail_x15_r0_body.s489.next - PRE_first_tail_x15_r0_body.s490.next,
  PRE_first_tail_x15_r0_body.s496.next - PRE_first_tail_x15_r0_body.s497.next,
  PRE_first_tail_x15_r0_body.s500.next - PRE_first_tail_x15_r0_body.s501.next,
  PRE_first_tail_x15_r0_body.s513.next - PRE_first_tail_x15_r0_body.s514.next,
  PRE_first_tail_x15_r0_body.s520.next - PRE_first_tail_x15_r0_body.s521.next,
  PRE_first_tail_x15_r0_body.s524.next - PRE_first_tail_x15_r0_body.s525.next,
  PRE_first_tail_x15_r0_body.s540.next - PRE_first_tail_x15_r0_body.s541.next,
  PRE_first_tail_x15_r0_body.s547.next - PRE_first_tail_x15_r0_body.s548.next,
  PRE_first_tail_x15_r0_body.s551.next - PRE_first_tail_x15_r0_body.s552.next,
  PRE_first_tail_x15_r0_body.s567.next - PRE_first_tail_x15_r0_body.s568.next,
  PRE_first_tail_x15_r0_body.s574.next - PRE_first_tail_x15_r0_body.s575.next,
  PRE_first_tail_x15_r0_body.s578.next - PRE_first_tail_x15_r0_body.s579.next,
  PRE_first_tail_x15_r0_body.s594.next - PRE_first_tail_x15_r0_body.s595.next,
  PRE_first_tail_x15_r0_body.s601.next - PRE_first_tail_x15_r0_body.s602.next,
  PRE_first_tail_x15_r0_body.s605.next - PRE_first_tail_x15_r0_body.s606.next,
  PRE_first_tail_x15_r0_body.s618.next - PRE_first_tail_x15_r0_body.s619.next,
  PRE_first_tail_x15_r0_body.s625.next - PRE_first_tail_x15_r0_body.s626.next,
  PRE_first_tail_x15_r0_body.s629.next - PRE_first_tail_x15_r0_body.s630.next,
  PRE_first_tail_x15_r0_body.s645.next - PRE_first_tail_x15_r0_body.s646.next,
  PRE_first_tail_x15_r0_body.s652.next - PRE_first_tail_x15_r0_body.s653.next,
  PRE_first_tail_x15_r0_body.s656.next - PRE_first_tail_x15_r0_body.s657.next,
  PRE_first_tail_x15_r0_body.s672.next - PRE_first_tail_x15_r0_body.s673.next,
  PRE_first_tail_x15_r0_body.s679.next - PRE_first_tail_x15_r0_body.s680.next,
  PRE_first_tail_x15_r0_body.s683.next - PRE_first_tail_x15_r0_body.s684.next,
  PRE_first_tail_x15_r0_body.s699.next - PRE_first_tail_x15_r0_body.s700.next,
  PRE_first_tail_x15_r0_body.s706.next - PRE_first_tail_x15_r0_body.s707.next,
  PRE_first_tail_x15_r0_body.s710.next - PRE_first_tail_x15_r0_body.s711.next,
  PRE_first_tail_x15_r0_body.s723.next - PRE_first_tail_x15_r0_body.s724.next,
  PRE_first_tail_x15_r0_body.s730.next - PRE_first_tail_x15_r0_body.s731.next,
  PRE_first_tail_x15_r0_body.s734.next - PRE_first_tail_x15_r0_body.s735.next,
  PRE_first_tail_x15_r0_body.s750.next - PRE_first_tail_x15_r0_body.s751.next,
  PRE_first_tail_x15_r0_body.s757.next - PRE_first_tail_x15_r0_body.s758.next,
  PRE_first_tail_x15_r0_body.s761.next - PRE_first_tail_x15_r0_body.s762.next,
  PRE_first_tail_x15_r0_body.s777.next - PRE_first_tail_x15_r0_body.s778.next,
  PRE_first_tail_x15_r0_body.s784.next - PRE_first_tail_x15_r0_body.s785.next,
  PRE_first_tail_x15_r0_body.s788.next - PRE_first_tail_x15_r0_body.s789.next,
  PRE_first_tail_x15_r0_body.s804.next - PRE_first_tail_x15_r0_body.s805.next,
  PRE_first_tail_x15_r0_body.s811.next - PRE_first_tail_x15_r0_body.s812.next,
  PRE_first_tail_x15_r0_body.s815.next - PRE_first_tail_x15_r0_body.s816.next,
  PRE_first_tail_x15_r0_body.s828.next - PRE_first_tail_x15_r0_body.s829.next,
  PRE_first_tail_x15_r0_body.s835.next - PRE_first_tail_x15_r0_body.s836.next,
  PRE_first_tail_x15_r0_body.s839.next - PRE_first_tail_x15_r0_body.s840.next,
  PRE_first_tail_x15_r0_body.s855.next - PRE_first_tail_x15_r0_body.s856.next,
  PRE_first_tail_x15_r0_body.s862.next - PRE_first_tail_x15_r0_body.s863.next,
  PRE_first_tail_x15_r0_body.s866.next - PRE_first_tail_x15_r0_body.s867.next,
  PRE_first_tail_x15_r0_body.s882.next - PRE_first_tail_x15_r0_body.s883.next,
  PRE_first_tail_x15_r0_body.s889.next - PRE_first_tail_x15_r0_body.s890.next,
  PRE_first_tail_x15_r0_body.s893.next - PRE_first_tail_x15_r0_body.s894.next,
  PRE_first_tail_x15_r0_body.s909.next - PRE_first_tail_x15_r0_body.s910.next,
  PRE_first_tail_x15_r0_body.s916.next - PRE_first_tail_x15_r0_body.s917.next,
  PRE_first_tail_x15_r0_body.s920.next - PRE_first_tail_x15_r0_body.s921.next,
  PRE_first_tail_x15_r0_body.s933.next - PRE_first_tail_x15_r0_body.s934.next,
  PRE_first_tail_x15_r0_body.s940.next - PRE_first_tail_x15_r0_body.s941.next,
  PRE_first_tail_x15_r0_body.s944.next - PRE_first_tail_x15_r0_body.s945.next,
  PRE_first_tail_x15_r0_body.s960.next - PRE_first_tail_x15_r0_body.s961.next,
  PRE_first_tail_x15_r0_body.s967.next - PRE_first_tail_x15_r0_body.s968.next,
  PRE_first_tail_x15_r0_body.s971.next - PRE_first_tail_x15_r0_body.s972.next,
  PRE_first_tail_x15_r0_body.s987.next - PRE_first_tail_x15_r0_body.s988.next,
  PRE_first_tail_x15_r0_body.s994.next - PRE_first_tail_x15_r0_body.s995.next,
  PRE_first_tail_x15_r0_body.s998.next - PRE_first_tail_x15_r0_body.s999.next,
  PRE_first_tail_x15_r0_body.s1014.next - PRE_first_tail_x15_r0_body.s1015.next,
  PRE_first_tail_x15_r0_body.s1021.next - PRE_first_tail_x15_r0_body.s1022.next,
  PRE_first_tail_x15_r0_body.s1025.next - PRE_first_tail_x15_r0_body.s1026.next,
  PRE_first_tail_x15_r0_body.s1038.next - PRE_first_tail_x15_r0_body.s1039.next,
  PRE_first_tail_x15_r0_body.s1045.next - PRE_first_tail_x15_r0_body.s1046.next,
  PRE_first_tail_x15_r0_body.s1049.next - PRE_first_tail_x15_r0_body.s1050.next,
  PRE_first_tail_x15_r0_body.s1065.next - PRE_first_tail_x15_r0_body.s1066.next,
  PRE_first_tail_x15_r0_body.s1072.next - PRE_first_tail_x15_r0_body.s1073.next,
  PRE_first_tail_x15_r0_body.s1076.next - PRE_first_tail_x15_r0_body.s1077.next,
  PRE_first_tail_x15_r0_body.s1092.next - PRE_first_tail_x15_r0_body.s1093.next,
  PRE_first_tail_x15_r0_body.s1099.next - PRE_first_tail_x15_r0_body.s1100.next,
  PRE_first_tail_x15_r0_body.s1103.next - PRE_first_tail_x15_r0_body.s1104.next,
  PRE_first_tail_x15_r0_body.s1119.next - PRE_first_tail_x15_r0_body.s1120.next,
  PRE_first_tail_x15_r0_body.s1126.next - PRE_first_tail_x15_r0_body.s1127.next,
  PRE_first_tail_x15_r0_body.s1130.next - PRE_first_tail_x15_r0_body.s1131.next,
  PRE_first_tail_x15_r0_body.s1143.next - PRE_first_tail_x15_r0_body.s1144.next,
  PRE_first_tail_x15_r0_body.s1150.next - PRE_first_tail_x15_r0_body.s1151.next,
  PRE_first_tail_x15_r0_body.s1154.next - PRE_first_tail_x15_r0_body.s1155.next,
  PRE_first_tail_x15_r0_body.s1170.next - PRE_first_tail_x15_r0_body.s1171.next,
  PRE_first_tail_x15_r0_body.s1177.next - PRE_first_tail_x15_r0_body.s1178.next,
  PRE_first_tail_x15_r0_body.s1181.next - PRE_first_tail_x15_r0_body.s1182.next,
  PRE_first_tail_x15_r0_body.s1197.next - PRE_first_tail_x15_r0_body.s1198.next,
  PRE_first_tail_x15_r0_body.s1204.next - PRE_first_tail_x15_r0_body.s1205.next,
  PRE_first_tail_x15_r0_body.s1208.next - PRE_first_tail_x15_r0_body.s1209.next,
  PRE_first_tail_x15_r0_body.s1224.next - PRE_first_tail_x15_r0_body.s1225.next,
  PRE_first_tail_x15_r0_body.s1231.next - PRE_first_tail_x15_r0_body.s1232.next,
  PRE_first_tail_x15_r0_body.s1235.next - PRE_first_tail_x15_r0_body.s1236.next,
  PRE_first_tail_x15_r0_body.s1248.next - PRE_first_tail_x15_r0_body.s1249.next,
  PRE_first_tail_x15_r0_body.s1255.next - PRE_first_tail_x15_r0_body.s1256.next,
  PRE_first_tail_x15_r0_body.s1259.next - PRE_first_tail_x15_r0_body.s1260.next,
  PRE_first_tail_x15_r0_body.s1275.next - PRE_first_tail_x15_r0_body.s1276.next,
  PRE_first_tail_x15_r0_body.s1282.next - PRE_first_tail_x15_r0_body.s1283.next,
  PRE_first_tail_x15_r0_body.s1286.next - PRE_first_tail_x15_r0_body.s1287.next,
  PRE_first_tail_x15_r0_body.s1302.next - PRE_first_tail_x15_r0_body.s1303.next,
  PRE_first_tail_x15_r0_body.s1309.next - PRE_first_tail_x15_r0_body.s1310.next,
  PRE_first_tail_x15_r0_body.s1313.next - PRE_first_tail_x15_r0_body.s1314.next,
  PRE_first_tail_x15_r0_body.s1329.next - PRE_first_tail_x15_r0_body.s1330.next,
  PRE_first_tail_x15_r0_body.s1336.next - PRE_first_tail_x15_r0_body.s1337.next,
  PRE_first_tail_x15_r0_body.s1340.next - PRE_first_tail_x15_r0_body.s1341.next,
  PRE_first_tail_x15_r0_body.s1353.next - PRE_first_tail_x15_r0_body.s1354.next,
  PRE_first_tail_x15_r0_body.s1360.next - PRE_first_tail_x15_r0_body.s1361.next,
  PRE_first_tail_x15_r0_body.s1364.next - PRE_first_tail_x15_r0_body.s1365.next,
  PRE_first_tail_x15_r0_body.s1380.next - PRE_first_tail_x15_r0_body.s1381.next,
  PRE_first_tail_x15_r0_body.s1387.next - PRE_first_tail_x15_r0_body.s1388.next,
  PRE_first_tail_x15_r0_body.s1391.next - PRE_first_tail_x15_r0_body.s1392.next,
  PRE_first_tail_x15_r0_body.s1407.next - PRE_first_tail_x15_r0_body.s1408.next,
  PRE_first_tail_x15_r0_body.s1414.next - PRE_first_tail_x15_r0_body.s1415.next,
  PRE_first_tail_x15_r0_body.s1418.next - PRE_first_tail_x15_r0_body.s1419.next,
  PRE_first_tail_x15_r0_body.s1434.next - PRE_first_tail_x15_r0_body.s1435.next,
  PRE_first_tail_x15_r0_body.s1441.next - PRE_first_tail_x15_r0_body.s1442.next,
  PRE_first_tail_x15_r0_body.s1445.next - PRE_first_tail_x15_r0_body.s1446.next,
  PRE_first_tail_x15_r0_body.s1458.next - PRE_first_tail_x15_r0_body.s1459.next,
  PRE_first_tail_x15_r0_body.s1465.next - PRE_first_tail_x15_r0_body.s1466.next,
  PRE_first_tail_x15_r0_body.s1469.next - PRE_first_tail_x15_r0_body.s1470.next,
  PRE_first_tail_x15_r0_body.s1485.next - PRE_first_tail_x15_r0_body.s1486.next,
  PRE_first_tail_x15_r0_body.s1492.next - PRE_first_tail_x15_r0_body.s1493.next,
  PRE_first_tail_x15_r0_body.s1496.next - PRE_first_tail_x15_r0_body.s1497.next,
  PRE_first_tail_x15_r0_body.s1512.next - PRE_first_tail_x15_r0_body.s1513.next,
  PRE_first_tail_x15_r0_body.s1519.next - PRE_first_tail_x15_r0_body.s1520.next,
  PRE_first_tail_x15_r0_body.s1523.next - PRE_first_tail_x15_r0_body.s1524.next,
  PRE_first_tail_x15_r0_body.s1539.next - PRE_first_tail_x15_r0_body.s1540.next,
  PRE_first_tail_x15_r0_body.s1546.next - PRE_first_tail_x15_r0_body.s1547.next,
  PRE_first_tail_x15_r0_body.s1550.next - PRE_first_tail_x15_r0_body.s1551.next,
  PRE_first_tail_x15_r0_body.s1563.next - PRE_first_tail_x15_r0_body.s1564.next,
  PRE_first_tail_x15_r0_body.s1570.next - PRE_first_tail_x15_r0_body.s1571.next,
  PRE_first_tail_x15_r0_body.s1574.next - PRE_first_tail_x15_r0_body.s1575.next,
  PRE_first_tail_x15_r0_body.s1590.next - PRE_first_tail_x15_r0_body.s1591.next,
  PRE_first_tail_x15_r0_body.s1597.next - PRE_first_tail_x15_r0_body.s1598.next,
  PRE_first_tail_x15_r0_body.s1601.next - PRE_first_tail_x15_r0_body.s1602.next,
  PRE_first_tail_x15_r0_body.s1617.next - PRE_first_tail_x15_r0_body.s1618.next,
  PRE_first_tail_x15_r0_body.s1624.next - PRE_first_tail_x15_r0_body.s1625.next,
  PRE_first_tail_x15_r0_body.s1628.next - PRE_first_tail_x15_r0_body.s1629.next,
  PRE_first_tail_x15_r0_body.s1644.next - PRE_first_tail_x15_r0_body.s1645.next,
  PRE_first_tail_x15_r0_body.s1651.next - PRE_first_tail_x15_r0_body.s1652.next,
  PRE_first_tail_x15_r0_body.s1655.next - PRE_first_tail_x15_r0_body.s1656.next,
  PRE_first_tail_x15_r0_body.s1668.next - PRE_first_tail_x15_r0_body.s1669.next,
  PRE_first_tail_x15_r0_body.s1675.next - PRE_first_tail_x15_r0_body.s1676.next,
  PRE_first_tail_x15_r0_body.s1679.next - PRE_first_tail_x15_r0_body.s1680.next
]

kernel_rfl bodyCompactionDrops_count : bodyCompactionDrops.length = 192
kernel_rfl bodyCompactionDrops_sum : bodyCompactionDrops.sum = 62279
kernel_rfl prefixNpsDrop : PRE_first_tail_x15_r0.s18.next - PRE_first_tail_x15_r0.s19.next = 14
kernel_rfl prefixDispatchDrop : PRE_first_tail_x15_r0.s39.next - PRE_first_tail_x15_r0.s40.next = 31
kernel_rfl suffixEvalDrop : PRE_first_tail_x15_r0_suffix.s3.next - PRE_first_tail_x15_r0_suffix.s4.next = 2983
kernel_rfl prefixNpsNext : PRE_first_tail_x15_r0.s17.next = 2673457
kernel_rfl prefixForwardNext : PRE_first_tail_x15_r0.s41.next = 2673488
kernel_rfl bodyStartNext : PRE_first_tail_x15_r0_body.s0.next = 2673488
kernel_rfl bodyEndNext : PRE_first_tail_x15_r0_body.s1681.next = 2825025
kernel_rfl suffixStartNext : PRE_first_tail_x15_r0_suffix.s0.next = 2825025
kernel_rfl suffixEndNext : PRE_first_tail_x15_r0_suffix.s8.next = 2825043

theorem compactionDrops_beforeRestart :
    (PRE_first_tail_x15_r0.s18.next - PRE_first_tail_x15_r0.s19.next) +
    (PRE_first_tail_x15_r0.s39.next - PRE_first_tail_x15_r0.s40.next) + bodyCompactionDrops.sum +
    (PRE_first_tail_x15_r0_suffix.s3.next - PRE_first_tail_x15_r0_suffix.s4.next) = 65307 := by
  rw [prefixNpsDrop, prefixDispatchDrop, bodyCompactionDrops_sum, suffixEvalDrop]

theorem suffixToNpsCounterDrop :
    PRE_first_tail_x15_r0_suffix.s8.next - PRE_first_tail_x15_r0.s17.next = 151586 := by
  rw [suffixEndNext, prefixNpsNext]

/-- The numerical cost if the checked suffix is restarted at the original next-step template.
The restart relation itself is a separate obligation. -/
theorem restartOffsetAtNps {Dstart Dend targetNext Dnext : Nat}
    (hend : Dend = Dstart + 65307)
    (htarget : targetNext = PRE_first_tail_x15_r0_suffix.s8.next + Dend)
    (hrestart : Dnext = targetNext - PRE_first_tail_x15_r0.s17.next) :
    Dnext = Dstart + 216893 := by
  rw [suffixEndNext] at htarget
  rw [prefixNpsNext] at hrestart
  omega

end Host.Ts.Sim.Compose.VWFirst
