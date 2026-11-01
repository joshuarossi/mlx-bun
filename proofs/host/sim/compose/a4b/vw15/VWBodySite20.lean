import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x15_r0_body.map_site20 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n), (1284, Q.n), (1285, Q.n), (1287, Q.n), (1288, Q.n), (1289, Q.n), (1290, Q.n), (1291, Q.n), (1294, Q.n), (1295, Q.n), (1297, Q.n), (1298, Q.n), (1299, Q.n), (1300, Q.n), (1301, Q.n), (1338, Q.n), (1339, Q.n), (1341, Q.n), (1342, Q.n), (1343, Q.n), (1344, Q.n), (1345, Q.n), (1348, Q.n), (1349, Q.n), (1351, Q.n), (1352, Q.n), (1353, Q.n), (1354, Q.n), (1355, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st20.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site20 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site20) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st20.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site20
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st20.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st20.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s201 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s202 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S201 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws20 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st20.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st20.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso20
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_20
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st20.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot20
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup20
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound20
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace20
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged20
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws20.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st20.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S201.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_20]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen20.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh20
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose
