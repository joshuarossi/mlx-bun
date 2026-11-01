import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site9 : ([first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st9.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site9
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st9.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st9.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s102 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s103 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S102 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws9 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st9.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st9.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso9
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_9
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st9.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot9
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup9
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound9
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace9
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged9
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws9.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st9.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S102.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_9]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen9.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh9
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose
