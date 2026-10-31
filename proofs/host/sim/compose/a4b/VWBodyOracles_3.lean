import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.st12.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st13.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st14.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st15.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_g12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g12 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g12) (List.take 16 (List.drop 116 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site12 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st12.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g13 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g13) (List.take 7 (List.drop 132 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site13 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st13.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g14 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g14 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g14) (List.take 3 (List.drop 139 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

noncomputable def PRE_first_tail_x15_r0_body.map_site14 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st14.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site14 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st14.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g15 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g15) (List.take 16 (List.drop 142 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site15 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st15.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles
