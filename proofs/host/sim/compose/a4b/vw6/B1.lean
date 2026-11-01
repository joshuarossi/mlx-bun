import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x6_r0_body.States
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B16
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B17
import host.sim.compose.a4b.vw6.B0
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B34
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw6.VWBodyChain
import host.sim.compose.a4b.vw6.VWBodyMap
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B14
import host.sim.template.CallGen

section -- VWBodyOracles_2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_g8 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g8 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g8) (List.take 3 (List.drop 73 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

noncomputable def PRE_first_tail_x6_r0_body.map_site8 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site8 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site8) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g9 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g9) (List.take 28 (List.drop 76 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site9 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st9.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g10 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g10) (List.take 9 (List.drop 104 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site10 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site10) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st10.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g11 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g11 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g11) (List.take 3 (List.drop 113 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

noncomputable def PRE_first_tail_x6_r0_body.map_site11 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site11 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site11) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x6_r0_body.map_site8 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site8 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site8) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site8
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s86 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s87 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S86 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws8 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso8
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_8
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot8
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup8
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound8
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace8
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged8
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws8.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st8.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S86.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_8]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen8.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh8
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl8 : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl8 (PRE_first_tail_x6_r0_body.cncl7 bodyNcl7)

theorem bodyClean8 : Conv.JClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s86 :=
  PRE_first_tail_x6_r0_body.gjcl8 (PRE_first_tail_x6_r0_body.cjcl7 bodyClean7)

kernel_rfl bodyJsLe8 : Nat.ble PRE_first_tail_x6_r0_body.s82.next PRE_first_tail_x6_r0_body.s86.next = true
kernel_rfl bodyJsList8 : (PRE_first_tail_x6_r0_body.gjh8 ++ PRE_first_tail_x6_r0_body.cl8).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s86.next) PRE_first_tail_x6_r0_body.s88) = true
theorem bodyJs8 : JsHeapAbove PRE_first_tail_x6_r0_body.s86.next PRE_first_tail_x6_r0_body.s88 :=
  JsHeapAbove.glueSite bodyJs7 (Nat.le_of_ble_eq_true bodyJsLe8) PRE_first_tail_x6_r0_body.gjk8 PRE_first_tail_x6_r0_body.gjbd8 PRE_first_tail_x6_r0_body.cheap8 PRE_first_tail_x6_r0_body.zclbd8 bodyJsList8

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO84 : PRE_first_tail_x6_r0_body.S84.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S84.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr84 : bridgeOf PRE_first_tail_x6_r0_body.s84.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc84 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.S84) = fun _ _ => true
kernel_rfl bodyAcc85 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s85 PRE_first_tail_x6_r0_body.S85) = fun _ _ => true
kernel_rfl bodyBr86 : bridgeOf PRE_first_tail_x6_r0_body.s86.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt85 : isHalt PRE_first_tail_x6_r0_body.s85.ctl = false
kernel_rfl bodyTop86 : noRetBlock PRE_first_tail_x6_r0_body.s86 = true
kernel_rfl bodyCnt84 : countersOkB PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.s86 = true

theorem bodyGlue8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7596, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.S84)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7596, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s86 PRE_first_tail_x6_r0_body.S86) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7596, 96, 0, 54⟩) bodyAcc84 PRE_first_tail_x6_r0_body.bodyRunSeg23 bodyAcc85 bodyHalt85 PRE_first_tail_x6_r0_body.bodyStepA24 bodyTop86 (fun _ hm => bodyO84 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr84).trans bodyInactive0) (bodyBr86.trans bodyBr84.symm) bodyCnt84 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift8 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S86.tab.length PRE_first_tail_x6_r0_body.s86.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P8.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P8 397 PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.s88.ffi PRE_first_tail_x6_r0_body.s87.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_8
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_8
  have hcl : SSt (· < 397) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S86.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_8] <;> decide) PRE_first_tail_x6_r0_body.cnodesK8 PRE_first_tail_x6_r0_body.cobjsK8
      PRE_first_tail_x6_r0_body.citemsK8 PRE_first_tail_x6_r0_body.cbd8 PRE_first_tail_x6_r0_body.csst8
  exact PRE_first_tail_x6_r0_body.cshift8 bodyNcl8 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_8] at this; exact this)


kernel_rfl bodyFramesEmpty8 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s87 a).isEmpty) = true
kernel_rfl bodyJsRoots8 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s86.next) PRE_first_tail_x6_r0_body.s88.trace PRE_first_tail_x6_r0_body.s88 = true
kernel_rfl bodyJsNative8 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s88.ffi) = true
kernel_rfl bodyLow8 : (PRE_first_tail_x6_r0_body.cws8 ++ PRE_first_tail_x6_r0_body.ws8).all (Nat.ble 9) = true
kernel_rfl bodyCntM8 : countersOkB PRE_first_tail_x6_r0_body.s86 PRE_first_tail_x6_r0_body.s87 = true
kernel_rfl bodyHi8 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s88.ffi).next setupP.E = true
kernel_rfl bodyNhi8 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s88.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge8 : bridgeOf PRE_first_tail_x6_r0_body.s87.ffi = bridgeOf PRE_first_tail_x6_r0_body.s86.ffi
kernel_rfl bodyNN8 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s86.ffi).nnext PRE_first_tail_x6_r0_body.P8.NL = true
kernel_rfl bodyXn8 : Nat.ble (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s88.ffi).next = true
kernel_rfl bodyLo8 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s88.ffi).next = true
theorem bodyFacts8 : BodySiteFacts PRE_first_tail_x6_r0_body.s86 PRE_first_tail_x6_r0_body.s87 PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S86 PRE_first_tail_x6_r0_body.S87 PRE_first_tail_x6_r0_body.S88
    PRE_first_tail_x6_r0_body.ws8 PRE_first_tail_x6_r0_body.cws8 PRE_first_tail_x6_r0_body.nr8 PRE_first_tail_x6_r0_body.pl8 PRE_first_tail_x6_r0_body.cl8 2680768 397 PRE_first_tail_x6_r0_body.kd8 PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.P8
    ⟨18353, 15448, 2680757, 397⟩ ⟨18353, 15448, 2680758, 397⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap8
  clean := bodyClean8
  cfix := PRE_first_tail_x6_r0_body.cfix8
  zpl := PRE_first_tail_x6_r0_body.zpl8
  zplnd := PRE_first_tail_x6_r0_body.zplnd8
  zn1 := PRE_first_tail_x6_r0_body.zn18
  zfirst := PRE_first_tail_x6_r0_body.zfirst8
  zscn := PRE_first_tail_x6_r0_body.zscn8
  zsmn := PRE_first_tail_x6_r0_body.zsmn8
  zgrow := PRE_first_tail_x6_r0_body.zgrow8
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab8
  zfresh := PRE_first_tail_x6_r0_body.zfresh8
  zcnd := PRE_first_tail_x6_r0_body.zcnd8
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi8
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt8
  zgP := PRE_first_tail_x6_r0_body.zg8_2665
  zkP := PRE_first_tail_x6_r0_body.zk8_2665
  zmP := PRE_first_tail_x6_r0_body.zm8_2665
  zgC := PRE_first_tail_x6_r0_body.zg8_2673467
  zkC := PRE_first_tail_x6_r0_body.zk8_2673467
  zmC := PRE_first_tail_x6_r0_body.zm8_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw8_2673472
  zwV := PRE_first_tail_x6_r0_body.zw8_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap8
  zclbd := PRE_first_tail_x6_r0_body.zclbd8
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap8 PRE_first_tail_x6_r0_body.stFoot8 PRE_first_tail_x6_r0_body.iso8 PRE_first_tail_x6_r0_body.zwr8
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP8
  csupp := PRE_first_tail_x6_r0_body.csupp8
  cbound := PRE_first_tail_x6_r0_body.cbound8
  zimg := PRE_first_tail_x6_r0_body.zimg8
  zctl := PRE_first_tail_x6_r0_body.zctl8
  zstack := PRE_first_tail_x6_r0_body.zstack8
  zjobs := PRE_first_tail_x6_r0_body.zjobs8
  zstores := PRE_first_tail_x6_r0_body.zstores8
  zroots := PRE_first_tail_x6_r0_body.zroots8
  znC := PRE_first_tail_x6_r0_body.znC8
  ctab := PRE_first_tail_x6_r0_body.ctab8
  zbin := PRE_first_tail_x6_r0_body.zbin8
  cbridge := PRE_first_tail_x6_r0_body.cbridge8
  sbridge := bodyBridge8
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj8
  cshiftR := fun h hNL => bodyCshift8 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN8
  raised := PRE_first_tail_x6_r0_body.raised8
  cbigs := PRE_first_tail_x6_r0_body.cbigs8
  cjcl := PRE_first_tail_x6_r0_body.cjcl8
  xnLe := Nat.le_of_ble_eq_true bodyXn8
  loLe := Nat.le_of_ble_eq_true bodyLo8
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB8
  cntM := bodyCntM8
  hiLe := Nat.le_of_ble_eq_true bodyHi8
  nhiLe := Nat.le_of_ble_eq_true bodyNhi8
  jsHeap := bodyJs8
  jsRoots := bodyJsRoots8
  jsNative := bodyJsNative8
  framesEmpty := bodyFramesEmpty8
  trailOld := by decide
  lowVars := bodyLow8

def bodyQs8 : List (Option Q) := []
noncomputable def bodyEs8 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr8.map fun r => nth? PRE_first_tail_x6_r0_body.st8.S2.tab r
kernel_rfl bodyResChk8 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs8 bodyQs8) = true
kernel_rfl bodyLq8 : bodyQs8.length = PRE_first_tail_x6_r0_body.cws8.length
kernel_rfl bodyNrLo8 : PRE_first_tail_x6_r0_body.nr8.all (Nat.ble PRE_first_tail_x6_r0_body.S86.tab.length) = true
kernel_rfl bodySub8 : (Oracles.PRE_first_tail_x6_r0_body.map_site8.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost8 : postSubB bodyM PRE_first_tail_x6_r0_body.ws8 PRE_first_tail_x6_r0_body.cws8 bodyQs8 = true
kernel_rfl bodyDrop8 : Nat.ble (7596 + (PRE_first_tail_x6_r0_body.s87.next - PRE_first_tail_x6_r0_body.s88.next)) 7606 = true
kernel_rfl bodyDropH8 : Nat.ble (96 + ((mlxOf PRE_first_tail_x6_r0_body.s87.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s88.ffi).next)) 96 = true
kernel_rfl bodyDropN8 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s87.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s88.ffi).nnext)) 0 = true
kernel_rfl bodyDv8 : bodyΘ.1.take 54 = bodyΘ.1.take 54 ++ PRE_first_tail_x6_r0_body.cws8
kernel_rfl bodyDe8 : bodyΘ.2.take 54 = bodyΘ.2.take 54 ++ PRE_first_tail_x6_r0_body.nr8.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st8.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 54) (bodyΘ.2.take 54)))
kernel_rfl bodyDl8 : (bodyΘ.1.take 54).length = (bodyΘ.2.take 54).length
kernel_rfl bodyDold8 : (bodyΘ.1.take 54).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws8).isNone && !PRE_first_tail_x6_r0_body.ws8.contains v) = true
kernel_rfl bodyDfree8 : (bodyΘ.2.take 54).all (fun e => (PRE_first_tail_x6_r0_body.cws8 ++ PRE_first_tail_x6_r0_body.ws8).all fun w => e.noVar w) = true

theorem bodyStep8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7596, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s86 PRE_first_tail_x6_r0_body.S86)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7606, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.S88) (98 + 1) :=
  bodySite bodyFacts8.cfix bodyFacts8.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x6_r0_body.st8.S2.tab) (Es := bodyEs8) (qs := bodyQs8)
    (ok := PRE_first_tail_x6_r0_body.st8.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site8 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts8
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site8 r hr) hi (MapOk.sub hm (sub_of_all bodySub8)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk8 r hr) hi hm ho hq)
    bodyLq8 rfl bodyNrLo8 (postSub_sound bodyPost8)
    (Nat.le_of_ble_eq_true bodyDrop8) (by decide) (Nat.le_of_ble_eq_true bodyDropH8) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN8) (by decide)
    bodyDv8 bodyDe8 bodyDl8 bodyDold8 bodyDfree8 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site9 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st9.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site9
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s102 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s103 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S102 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws9 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st9.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st9.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso9
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_9
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st9.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot9
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup9
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound9
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace9
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged9
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws9.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st9.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S102.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_9]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen9.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh9
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl9 : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl9 (PRE_first_tail_x6_r0_body.cncl8 bodyNcl8)

theorem bodyClean9 : Conv.JClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s102 :=
  PRE_first_tail_x6_r0_body.gjcl9 (PRE_first_tail_x6_r0_body.cjcl8 bodyClean8)

kernel_rfl bodyJsLe9 : Nat.ble PRE_first_tail_x6_r0_body.s86.next PRE_first_tail_x6_r0_body.s102.next = true
kernel_rfl bodyJsList9 : (PRE_first_tail_x6_r0_body.gjh9 ++ PRE_first_tail_x6_r0_body.cl9).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s102.next) PRE_first_tail_x6_r0_body.s104) = true
theorem bodyJs9 : JsHeapAbove PRE_first_tail_x6_r0_body.s102.next PRE_first_tail_x6_r0_body.s104 :=
  JsHeapAbove.glueSite bodyJs8 (Nat.le_of_ble_eq_true bodyJsLe9) PRE_first_tail_x6_r0_body.gjk9 PRE_first_tail_x6_r0_body.gjbd9 PRE_first_tail_x6_r0_body.cheap9 PRE_first_tail_x6_r0_body.zclbd9 bodyJsList9

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO88 : PRE_first_tail_x6_r0_body.S88.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S88.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr88 : bridgeOf PRE_first_tail_x6_r0_body.s88.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc88 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.S88) = fun _ _ => true
kernel_rfl bodyAcc90 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s90 PRE_first_tail_x6_r0_body.S90) = fun _ _ => true
kernel_rfl bodyBr91 : bridgeOf PRE_first_tail_x6_r0_body.s91.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt90 : isHalt PRE_first_tail_x6_r0_body.s90.ctl = false
kernel_rfl bodyTop91 : noRetBlock PRE_first_tail_x6_r0_body.s91 = true
kernel_rfl bodyCnt88 : countersOkB PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.s91 = true
kernel_rfl bodyO91 : PRE_first_tail_x6_r0_body.S91.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S91.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr92 : bridgeOf PRE_first_tail_x6_r0_body.s92.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt91 : countersOkB PRE_first_tail_x6_r0_body.s91 PRE_first_tail_x6_r0_body.s92 = true
kernel_rfl bodyO92 : PRE_first_tail_x6_r0_body.S92.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S92.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc92 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s92 PRE_first_tail_x6_r0_body.S92) = fun _ _ => true
kernel_rfl bodyAcc94 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s94 PRE_first_tail_x6_r0_body.S94) = fun _ _ => true
kernel_rfl bodyBr95 : bridgeOf PRE_first_tail_x6_r0_body.s95.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt94 : isHalt PRE_first_tail_x6_r0_body.s94.ctl = false
kernel_rfl bodyTop95 : noRetBlock PRE_first_tail_x6_r0_body.s95 = true
kernel_rfl bodyCnt92 : countersOkB PRE_first_tail_x6_r0_body.s92 PRE_first_tail_x6_r0_body.s95 = true
kernel_rfl bodyO95 : PRE_first_tail_x6_r0_body.S95.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S95.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr96 : bridgeOf PRE_first_tail_x6_r0_body.s96.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt95 : countersOkB PRE_first_tail_x6_r0_body.s95 PRE_first_tail_x6_r0_body.s96 = true
kernel_rfl bodyO96 : PRE_first_tail_x6_r0_body.S96.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S96.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc96 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s96 PRE_first_tail_x6_r0_body.S96) = fun _ _ => true
kernel_rfl bodyAcc97 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s97 PRE_first_tail_x6_r0_body.S97) = fun _ _ => true
kernel_rfl bodyBr98 : bridgeOf PRE_first_tail_x6_r0_body.s98.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt97 : isHalt PRE_first_tail_x6_r0_body.s97.ctl = false
kernel_rfl bodyTop98 : noRetBlock PRE_first_tail_x6_r0_body.s98 = true
kernel_rfl bodyCnt96 : countersOkB PRE_first_tail_x6_r0_body.s96 PRE_first_tail_x6_r0_body.s98 = true
kernel_rfl bodyO98 : PRE_first_tail_x6_r0_body.S98.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S98.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr99 : bridgeOf PRE_first_tail_x6_r0_body.s99.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt98 : countersOkB PRE_first_tail_x6_r0_body.s98 PRE_first_tail_x6_r0_body.s99 = true
kernel_rfl bodyO99 : PRE_first_tail_x6_r0_body.S99.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S99.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc99 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s99 PRE_first_tail_x6_r0_body.S99) = fun _ _ => true
kernel_rfl bodyAcc101 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s101 PRE_first_tail_x6_r0_body.S101) = fun _ _ => true
kernel_rfl bodyBr102 : bridgeOf PRE_first_tail_x6_r0_body.s102.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt101 : isHalt PRE_first_tail_x6_r0_body.s101.ctl = false
kernel_rfl bodyTop102 : noRetBlock PRE_first_tail_x6_r0_body.s102 = true
kernel_rfl bodyCnt99 : countersOkB PRE_first_tail_x6_r0_body.s99 PRE_first_tail_x6_r0_body.s102 = true

theorem bodyGlue9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7606, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.S88)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7606, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s102 PRE_first_tail_x6_r0_body.S102) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) bodyAcc88 PRE_first_tail_x6_r0_body.bodyRunSeg24 bodyAcc90 bodyHalt90 PRE_first_tail_x6_r0_body.bodyStepA25 bodyTop91 (fun _ hm => bodyO88 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr88).trans bodyInactive0) (bodyBr91.trans bodyBr88.symm) bodyCnt88 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) PRE_first_tail_x6_r0_body.sizeA25 PRE_first_tail_x6_r0_body.sizeArgsA25 PRE_first_tail_x6_r0_body.sizeSymA25 PRE_first_tail_x6_r0_body.sizeMlxA25 PRE_first_tail_x6_r0_body.sizePayA25 PRE_first_tail_x6_r0_body.sizeTaA25 PRE_first_tail_x6_r0_body.sizeDecA25 PRE_first_tail_x6_r0_body.sizePreA25 PRE_first_tail_x6_r0_body.bodyPatchB25 (fun _ hm => bodyO91 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr91).trans bodyInactive0) (bodyBr92.trans bodyBr91.symm) bodyCnt91 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) bodyAcc92 PRE_first_tail_x6_r0_body.bodyRunSeg25 bodyAcc94 bodyHalt94 PRE_first_tail_x6_r0_body.bodyStepA26 bodyTop95 (fun _ hm => bodyO92 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr92).trans bodyInactive0) (bodyBr95.trans bodyBr92.symm) bodyCnt92 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) PRE_first_tail_x6_r0_body.sizeA26 PRE_first_tail_x6_r0_body.sizeArgsA26 PRE_first_tail_x6_r0_body.sizeSymA26 PRE_first_tail_x6_r0_body.sizeMlxA26 PRE_first_tail_x6_r0_body.sizePayA26 PRE_first_tail_x6_r0_body.sizeTaA26 PRE_first_tail_x6_r0_body.sizeDecA26 PRE_first_tail_x6_r0_body.sizePreA26 PRE_first_tail_x6_r0_body.bodyPatchB26 (fun _ hm => bodyO95 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr95).trans bodyInactive0) (bodyBr96.trans bodyBr95.symm) bodyCnt95 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) bodyAcc96 PRE_first_tail_x6_r0_body.bodyRunSeg26 bodyAcc97 bodyHalt97 PRE_first_tail_x6_r0_body.bodyStepA27 bodyTop98 (fun _ hm => bodyO96 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr96).trans bodyInactive0) (bodyBr98.trans bodyBr96.symm) bodyCnt96 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) PRE_first_tail_x6_r0_body.sizeA27 PRE_first_tail_x6_r0_body.sizeArgsA27 PRE_first_tail_x6_r0_body.sizeSymA27 PRE_first_tail_x6_r0_body.sizeMlxA27 PRE_first_tail_x6_r0_body.sizePayA27 PRE_first_tail_x6_r0_body.sizeTaA27 PRE_first_tail_x6_r0_body.sizeDecA27 PRE_first_tail_x6_r0_body.sizePreA27 PRE_first_tail_x6_r0_body.bodyPatchB27 (fun _ hm => bodyO98 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr98).trans bodyInactive0) (bodyBr99.trans bodyBr98.symm) bodyCnt98 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) bodyAcc99 PRE_first_tail_x6_r0_body.bodyRunSeg27 bodyAcc101 bodyHalt101 PRE_first_tail_x6_r0_body.bodyStepA28 bodyTop102 (fun _ hm => bodyO99 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr99).trans bodyInactive0) (bodyBr102.trans bodyBr99.symm) bodyCnt99 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift9 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S102.tab.length PRE_first_tail_x6_r0_body.s102.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P9.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P9 483 PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.s104.ffi PRE_first_tail_x6_r0_body.s103.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_9
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_9
  have hcl : SSt (· < 483) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S102.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_9] <;> decide) PRE_first_tail_x6_r0_body.cnodesK9 PRE_first_tail_x6_r0_body.cobjsK9
      PRE_first_tail_x6_r0_body.citemsK9 PRE_first_tail_x6_r0_body.cbd9 PRE_first_tail_x6_r0_body.csst9
  exact PRE_first_tail_x6_r0_body.cshift9 bodyNcl9 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_9] at this; exact this)


kernel_rfl bodyFramesEmpty9 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s103 a).isEmpty) = true
kernel_rfl bodyJsRoots9 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s102.next) PRE_first_tail_x6_r0_body.s104.trace PRE_first_tail_x6_r0_body.s104 = true
kernel_rfl bodyJsNative9 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s104.ffi) = true
kernel_rfl bodyLow9 : (PRE_first_tail_x6_r0_body.cws9 ++ PRE_first_tail_x6_r0_body.ws9).all (Nat.ble 9) = true
kernel_rfl bodyCntM9 : countersOkB PRE_first_tail_x6_r0_body.s102 PRE_first_tail_x6_r0_body.s103 = true
kernel_rfl bodyHi9 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s104.ffi).next setupP.E = true
kernel_rfl bodyNhi9 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s104.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge9 : bridgeOf PRE_first_tail_x6_r0_body.s103.ffi = bridgeOf PRE_first_tail_x6_r0_body.s102.ffi
kernel_rfl bodyNN9 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s102.ffi).nnext PRE_first_tail_x6_r0_body.P9.NL = true
kernel_rfl bodyXn9 : Nat.ble (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s104.ffi).next = true
kernel_rfl bodyLo9 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s104.ffi).next = true
theorem bodyFacts9 : BodySiteFacts PRE_first_tail_x6_r0_body.s102 PRE_first_tail_x6_r0_body.s103 PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S102 PRE_first_tail_x6_r0_body.S103 PRE_first_tail_x6_r0_body.S104
    PRE_first_tail_x6_r0_body.ws9 PRE_first_tail_x6_r0_body.cws9 PRE_first_tail_x6_r0_body.nr9 PRE_first_tail_x6_r0_body.pl9 PRE_first_tail_x6_r0_body.cl9 2682859 483 PRE_first_tail_x6_r0_body.kd9 PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.P9
    ⟨18393, 15476, 2682494, 474⟩ ⟨18397, 15482, 2682509, 483⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap9
  clean := bodyClean9
  cfix := PRE_first_tail_x6_r0_body.cfix9
  zpl := PRE_first_tail_x6_r0_body.zpl9
  zplnd := PRE_first_tail_x6_r0_body.zplnd9
  zn1 := PRE_first_tail_x6_r0_body.zn19
  zfirst := PRE_first_tail_x6_r0_body.zfirst9
  zscn := PRE_first_tail_x6_r0_body.zscn9
  zsmn := PRE_first_tail_x6_r0_body.zsmn9
  zgrow := PRE_first_tail_x6_r0_body.zgrow9
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab9
  zfresh := PRE_first_tail_x6_r0_body.zfresh9
  zcnd := PRE_first_tail_x6_r0_body.zcnd9
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi9
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt9
  zgP := PRE_first_tail_x6_r0_body.zg9_2665
  zkP := PRE_first_tail_x6_r0_body.zk9_2665
  zmP := PRE_first_tail_x6_r0_body.zm9_2665
  zgC := PRE_first_tail_x6_r0_body.zg9_2673467
  zkC := PRE_first_tail_x6_r0_body.zk9_2673467
  zmC := PRE_first_tail_x6_r0_body.zm9_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw9_2673472
  zwV := PRE_first_tail_x6_r0_body.zw9_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap9
  zclbd := PRE_first_tail_x6_r0_body.zclbd9
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap9 PRE_first_tail_x6_r0_body.stFoot9 PRE_first_tail_x6_r0_body.iso9 PRE_first_tail_x6_r0_body.zwr9
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP9
  csupp := PRE_first_tail_x6_r0_body.csupp9
  cbound := PRE_first_tail_x6_r0_body.cbound9
  zimg := PRE_first_tail_x6_r0_body.zimg9
  zctl := PRE_first_tail_x6_r0_body.zctl9
  zstack := PRE_first_tail_x6_r0_body.zstack9
  zjobs := PRE_first_tail_x6_r0_body.zjobs9
  zstores := PRE_first_tail_x6_r0_body.zstores9
  zroots := PRE_first_tail_x6_r0_body.zroots9
  znC := PRE_first_tail_x6_r0_body.znC9
  ctab := PRE_first_tail_x6_r0_body.ctab9
  zbin := PRE_first_tail_x6_r0_body.zbin9
  cbridge := PRE_first_tail_x6_r0_body.cbridge9
  sbridge := bodyBridge9
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj9
  cshiftR := fun h hNL => bodyCshift9 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN9
  raised := PRE_first_tail_x6_r0_body.raised9
  cbigs := PRE_first_tail_x6_r0_body.cbigs9
  cjcl := PRE_first_tail_x6_r0_body.cjcl9
  xnLe := Nat.le_of_ble_eq_true bodyXn9
  loLe := Nat.le_of_ble_eq_true bodyLo9
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB9
  cntM := bodyCntM9
  hiLe := Nat.le_of_ble_eq_true bodyHi9
  nhiLe := Nat.le_of_ble_eq_true bodyNhi9
  jsHeap := bodyJs9
  jsRoots := bodyJsRoots9
  jsNative := bodyJsNative9
  framesEmpty := bodyFramesEmpty9
  trailOld := by decide
  lowVars := bodyLow9

def bodyQs9 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs9 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr9.map fun r => nth? PRE_first_tail_x6_r0_body.st9.S3.tab r
kernel_rfl bodyResChk9 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs9 bodyQs9) = true
kernel_rfl bodyLq9 : bodyQs9.length = PRE_first_tail_x6_r0_body.cws9.length
kernel_rfl bodyNrLo9 : PRE_first_tail_x6_r0_body.nr9.all (Nat.ble PRE_first_tail_x6_r0_body.S102.tab.length) = true
kernel_rfl bodySub9 : (Oracles.PRE_first_tail_x6_r0_body.map_site9.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost9 : postSubB bodyM PRE_first_tail_x6_r0_body.ws9 PRE_first_tail_x6_r0_body.cws9 bodyQs9 = true
kernel_rfl bodyDrop9 : Nat.ble (7606 + (PRE_first_tail_x6_r0_body.s103.next - PRE_first_tail_x6_r0_body.s104.next)) 7956 = true
kernel_rfl bodyDropH9 : Nat.ble (96 + ((mlxOf PRE_first_tail_x6_r0_body.s103.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s104.ffi).next)) 98 = true
kernel_rfl bodyDropN9 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s103.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s104.ffi).nnext)) 0 = true
kernel_rfl bodyDv9 : bodyΘ.1.take 63 = bodyΘ.1.take 54 ++ PRE_first_tail_x6_r0_body.cws9
kernel_rfl bodyDe9 : bodyΘ.2.take 63 = bodyΘ.2.take 54 ++ PRE_first_tail_x6_r0_body.nr9.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st9.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 54) (bodyΘ.2.take 54)))
kernel_rfl bodyDl9 : (bodyΘ.1.take 54).length = (bodyΘ.2.take 54).length
kernel_rfl bodyDold9 : (bodyΘ.1.take 54).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws9).isNone && !PRE_first_tail_x6_r0_body.ws9.contains v) = true
kernel_rfl bodyDfree9 : (bodyΘ.2.take 63).all (fun e => (PRE_first_tail_x6_r0_body.cws9 ++ PRE_first_tail_x6_r0_body.ws9).all fun w => e.noVar w) = true

theorem bodyStep9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7606, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s102 PRE_first_tail_x6_r0_body.S102)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7956, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.S104) (3452 + 1) :=
  bodySite bodyFacts9.cfix bodyFacts9.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x6_r0_body.st9.S3.tab) (Es := bodyEs9) (qs := bodyQs9)
    (ok := PRE_first_tail_x6_r0_body.st9.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site9 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts9
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site9 r hr) hi (MapOk.sub hm (sub_of_all bodySub9)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk9 r hr) hi hm ho hq)
    bodyLq9 rfl bodyNrLo9 (postSub_sound bodyPost9)
    (Nat.le_of_ble_eq_true bodyDrop9) (by decide) (Nat.le_of_ble_eq_true bodyDropH9) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN9) (by decide)
    bodyDv9 bodyDe9 bodyDl9 bodyDold9 bodyDfree9 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site10 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site10 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site10) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st10.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site10
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s110 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s111 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S110 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws10 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st10.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st10.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso10
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_10
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st10.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot10
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup10
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound10
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace10
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged10
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws10.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st10.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S110.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_10]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen10.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh10
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl10 : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl10 (PRE_first_tail_x6_r0_body.cncl9 bodyNcl9)

theorem bodyClean10 : Conv.JClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s110 :=
  PRE_first_tail_x6_r0_body.gjcl10 (PRE_first_tail_x6_r0_body.cjcl9 bodyClean9)

kernel_rfl bodyJsLe10 : Nat.ble PRE_first_tail_x6_r0_body.s102.next PRE_first_tail_x6_r0_body.s110.next = true
kernel_rfl bodyJsList10 : (PRE_first_tail_x6_r0_body.gjh10 ++ PRE_first_tail_x6_r0_body.cl10).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s110.next) PRE_first_tail_x6_r0_body.s112) = true
theorem bodyJs10 : JsHeapAbove PRE_first_tail_x6_r0_body.s110.next PRE_first_tail_x6_r0_body.s112 :=
  JsHeapAbove.glueSite bodyJs9 (Nat.le_of_ble_eq_true bodyJsLe10) PRE_first_tail_x6_r0_body.gjk10 PRE_first_tail_x6_r0_body.gjbd10 PRE_first_tail_x6_r0_body.cheap10 PRE_first_tail_x6_r0_body.zclbd10 bodyJsList10

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO104 : PRE_first_tail_x6_r0_body.S104.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S104.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr104 : bridgeOf PRE_first_tail_x6_r0_body.s104.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc104 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.S104) = fun _ _ => true
kernel_rfl bodyAcc105 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s105 PRE_first_tail_x6_r0_body.S105) = fun _ _ => true
kernel_rfl bodyBr106 : bridgeOf PRE_first_tail_x6_r0_body.s106.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt105 : isHalt PRE_first_tail_x6_r0_body.s105.ctl = false
kernel_rfl bodyTop106 : noRetBlock PRE_first_tail_x6_r0_body.s106 = true
kernel_rfl bodyCnt104 : countersOkB PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.s106 = true
kernel_rfl bodyO106 : PRE_first_tail_x6_r0_body.S106.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S106.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr107 : bridgeOf PRE_first_tail_x6_r0_body.s107.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt106 : countersOkB PRE_first_tail_x6_r0_body.s106 PRE_first_tail_x6_r0_body.s107 = true
kernel_rfl bodyO107 : PRE_first_tail_x6_r0_body.S107.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S107.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc107 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s107 PRE_first_tail_x6_r0_body.S107) = fun _ _ => true
kernel_rfl bodyAcc109 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s109 PRE_first_tail_x6_r0_body.S109) = fun _ _ => true
kernel_rfl bodyBr110 : bridgeOf PRE_first_tail_x6_r0_body.s110.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt109 : isHalt PRE_first_tail_x6_r0_body.s109.ctl = false
kernel_rfl bodyTop110 : noRetBlock PRE_first_tail_x6_r0_body.s110 = true
kernel_rfl bodyCnt107 : countersOkB PRE_first_tail_x6_r0_body.s107 PRE_first_tail_x6_r0_body.s110 = true

theorem bodyGlue10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7956, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.S104)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7956, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s110 PRE_first_tail_x6_r0_body.S110) 5813 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7956, 98, 0, 63⟩) bodyAcc104 PRE_first_tail_x6_r0_body.bodyRunSeg28 bodyAcc105 bodyHalt105 PRE_first_tail_x6_r0_body.bodyStepA29 bodyTop106 (fun _ hm => bodyO104 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr104).trans bodyInactive0) (bodyBr106.trans bodyBr104.symm) bodyCnt104 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7956, 98, 0, 63⟩) PRE_first_tail_x6_r0_body.sizeA29 PRE_first_tail_x6_r0_body.sizeArgsA29 PRE_first_tail_x6_r0_body.sizeSymA29 PRE_first_tail_x6_r0_body.sizeMlxA29 PRE_first_tail_x6_r0_body.sizePayA29 PRE_first_tail_x6_r0_body.sizeTaA29 PRE_first_tail_x6_r0_body.sizeDecA29 PRE_first_tail_x6_r0_body.sizePreA29 PRE_first_tail_x6_r0_body.bodyPatchB29 (fun _ hm => bodyO106 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr106).trans bodyInactive0) (bodyBr107.trans bodyBr106.symm) bodyCnt106 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7956, 98, 0, 63⟩) bodyAcc107 PRE_first_tail_x6_r0_body.bodyRunSeg29 bodyAcc109 bodyHalt109 PRE_first_tail_x6_r0_body.bodyStepA30 bodyTop110 (fun _ hm => bodyO107 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr107).trans bodyInactive0) (bodyBr110.trans bodyBr107.symm) bodyCnt107 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift10 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S110.tab.length PRE_first_tail_x6_r0_body.s110.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P10.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P10 506 PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.s112.ffi PRE_first_tail_x6_r0_body.s111.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_10
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_10
  have hcl : SSt (· < 506) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S110.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_10] <;> decide) PRE_first_tail_x6_r0_body.cnodesK10 PRE_first_tail_x6_r0_body.cobjsK10
      PRE_first_tail_x6_r0_body.citemsK10 PRE_first_tail_x6_r0_body.cbd10 PRE_first_tail_x6_r0_body.csst10
  exact PRE_first_tail_x6_r0_body.cshift10 bodyNcl10 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_10] at this; exact this)


kernel_rfl bodyFramesEmpty10 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s111 a).isEmpty) = true
kernel_rfl bodyJsRoots10 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s110.next) PRE_first_tail_x6_r0_body.s112.trace PRE_first_tail_x6_r0_body.s112 = true
kernel_rfl bodyJsNative10 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s112.ffi) = true
kernel_rfl bodyLow10 : (PRE_first_tail_x6_r0_body.cws10 ++ PRE_first_tail_x6_r0_body.ws10).all (Nat.ble 9) = true
kernel_rfl bodyCntM10 : countersOkB PRE_first_tail_x6_r0_body.s110 PRE_first_tail_x6_r0_body.s111 = true
kernel_rfl bodyHi10 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s112.ffi).next setupP.E = true
kernel_rfl bodyNhi10 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s112.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge10 : bridgeOf PRE_first_tail_x6_r0_body.s111.ffi = bridgeOf PRE_first_tail_x6_r0_body.s110.ffi
kernel_rfl bodyNN10 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s110.ffi).nnext PRE_first_tail_x6_r0_body.P10.NL = true
kernel_rfl bodyXn10 : Nat.ble (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s112.ffi).next = true
kernel_rfl bodyLo10 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s112.ffi).next = true
theorem bodyFacts10 : BodySiteFacts PRE_first_tail_x6_r0_body.s110 PRE_first_tail_x6_r0_body.s111 PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S110 PRE_first_tail_x6_r0_body.S111 PRE_first_tail_x6_r0_body.S112
    PRE_first_tail_x6_r0_body.ws10 PRE_first_tail_x6_r0_body.cws10 PRE_first_tail_x6_r0_body.nr10 PRE_first_tail_x6_r0_body.pl10 PRE_first_tail_x6_r0_body.cl10 2683095 506 PRE_first_tail_x6_r0_body.kd10 PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.P10
    ⟨18410, 15492, 2683093, 506⟩ ⟨18410, 15492, 2683093, 506⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap10
  clean := bodyClean10
  cfix := PRE_first_tail_x6_r0_body.cfix10
  zpl := PRE_first_tail_x6_r0_body.zpl10
  zplnd := PRE_first_tail_x6_r0_body.zplnd10
  zn1 := PRE_first_tail_x6_r0_body.zn110
  zfirst := PRE_first_tail_x6_r0_body.zfirst10
  zscn := PRE_first_tail_x6_r0_body.zscn10
  zsmn := PRE_first_tail_x6_r0_body.zsmn10
  zgrow := PRE_first_tail_x6_r0_body.zgrow10
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab10
  zfresh := PRE_first_tail_x6_r0_body.zfresh10
  zcnd := PRE_first_tail_x6_r0_body.zcnd10
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi10
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt10
  zgP := PRE_first_tail_x6_r0_body.zg10_2665
  zkP := PRE_first_tail_x6_r0_body.zk10_2665
  zmP := PRE_first_tail_x6_r0_body.zm10_2665
  zgC := PRE_first_tail_x6_r0_body.zg10_2673467
  zkC := PRE_first_tail_x6_r0_body.zk10_2673467
  zmC := PRE_first_tail_x6_r0_body.zm10_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw10_2673472
  zwV := PRE_first_tail_x6_r0_body.zw10_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap10
  zclbd := PRE_first_tail_x6_r0_body.zclbd10
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap10 PRE_first_tail_x6_r0_body.stFoot10 PRE_first_tail_x6_r0_body.iso10 PRE_first_tail_x6_r0_body.zwr10
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP10
  csupp := PRE_first_tail_x6_r0_body.csupp10
  cbound := PRE_first_tail_x6_r0_body.cbound10
  zimg := PRE_first_tail_x6_r0_body.zimg10
  zctl := PRE_first_tail_x6_r0_body.zctl10
  zstack := PRE_first_tail_x6_r0_body.zstack10
  zjobs := PRE_first_tail_x6_r0_body.zjobs10
  zstores := PRE_first_tail_x6_r0_body.zstores10
  zroots := PRE_first_tail_x6_r0_body.zroots10
  znC := PRE_first_tail_x6_r0_body.znC10
  ctab := PRE_first_tail_x6_r0_body.ctab10
  zbin := PRE_first_tail_x6_r0_body.zbin10
  cbridge := PRE_first_tail_x6_r0_body.cbridge10
  sbridge := bodyBridge10
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj10
  cshiftR := fun h hNL => bodyCshift10 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN10
  raised := PRE_first_tail_x6_r0_body.raised10
  cbigs := PRE_first_tail_x6_r0_body.cbigs10
  cjcl := PRE_first_tail_x6_r0_body.cjcl10
  xnLe := Nat.le_of_ble_eq_true bodyXn10
  loLe := Nat.le_of_ble_eq_true bodyLo10
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB10
  cntM := bodyCntM10
  hiLe := Nat.le_of_ble_eq_true bodyHi10
  nhiLe := Nat.le_of_ble_eq_true bodyNhi10
  jsHeap := bodyJs10
  jsRoots := bodyJsRoots10
  jsNative := bodyJsNative10
  framesEmpty := bodyFramesEmpty10
  trailOld := by decide
  lowVars := bodyLow10

def bodyQs10 : List (Option Q) := []
noncomputable def bodyEs10 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr10.map fun r => nth? PRE_first_tail_x6_r0_body.st10.S2.tab r
kernel_rfl bodyResChk10 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs10 bodyQs10) = true
kernel_rfl bodyLq10 : bodyQs10.length = PRE_first_tail_x6_r0_body.cws10.length
kernel_rfl bodyNrLo10 : PRE_first_tail_x6_r0_body.nr10.all (Nat.ble PRE_first_tail_x6_r0_body.S110.tab.length) = true
kernel_rfl bodySub10 : (Oracles.PRE_first_tail_x6_r0_body.map_site10.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost10 : postSubB bodyM PRE_first_tail_x6_r0_body.ws10 PRE_first_tail_x6_r0_body.cws10 bodyQs10 = true
kernel_rfl bodyDrop10 : Nat.ble (7956 + (PRE_first_tail_x6_r0_body.s111.next - PRE_first_tail_x6_r0_body.s112.next)) 7958 = true
kernel_rfl bodyDropH10 : Nat.ble (98 + ((mlxOf PRE_first_tail_x6_r0_body.s111.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s112.ffi).next)) 98 = true
kernel_rfl bodyDropN10 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s111.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s112.ffi).nnext)) 0 = true
kernel_rfl bodyDv10 : bodyΘ.1.take 63 = bodyΘ.1.take 63 ++ PRE_first_tail_x6_r0_body.cws10
kernel_rfl bodyDe10 : bodyΘ.2.take 63 = bodyΘ.2.take 63 ++ PRE_first_tail_x6_r0_body.nr10.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st10.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 63) (bodyΘ.2.take 63)))
kernel_rfl bodyDl10 : (bodyΘ.1.take 63).length = (bodyΘ.2.take 63).length
kernel_rfl bodyDold10 : (bodyΘ.1.take 63).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws10).isNone && !PRE_first_tail_x6_r0_body.ws10.contains v) = true
kernel_rfl bodyDfree10 : (bodyΘ.2.take 63).all (fun e => (PRE_first_tail_x6_r0_body.cws10 ++ PRE_first_tail_x6_r0_body.ws10).all fun w => e.noVar w) = true

theorem bodyStep10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7956, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s110 PRE_first_tail_x6_r0_body.S110)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7958, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.S112) (27 + 1) :=
  bodySite bodyFacts10.cfix bodyFacts10.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x6_r0_body.st10.S2.tab) (Es := bodyEs10) (qs := bodyQs10)
    (ok := PRE_first_tail_x6_r0_body.st10.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site10 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts10
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site10 r hr) hi (MapOk.sub hm (sub_of_all bodySub10)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk10 r hr) hi hm ho hq)
    bodyLq10 rfl bodyNrLo10 (postSub_sound bodyPost10)
    (Nat.le_of_ble_eq_true bodyDrop10) (by decide) (Nat.le_of_ble_eq_true bodyDropH10) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN10) (by decide)
    bodyDv10 bodyDe10 bodyDl10 bodyDold10 bodyDfree10 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x6_r0_body.map_site11 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site11 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site11) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site11
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s114 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s115 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S114 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws11 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso11
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_11
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot11
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup11
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound11
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace11
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged11
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws11.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st11.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S114.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_11]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen11.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh11
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl11 : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl11 (PRE_first_tail_x6_r0_body.cncl10 bodyNcl10)

theorem bodyClean11 : Conv.JClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s114 :=
  PRE_first_tail_x6_r0_body.gjcl11 (PRE_first_tail_x6_r0_body.cjcl10 bodyClean10)

kernel_rfl bodyJsLe11 : Nat.ble PRE_first_tail_x6_r0_body.s110.next PRE_first_tail_x6_r0_body.s114.next = true
kernel_rfl bodyJsList11 : (PRE_first_tail_x6_r0_body.gjh11 ++ PRE_first_tail_x6_r0_body.cl11).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s114.next) PRE_first_tail_x6_r0_body.s116) = true
theorem bodyJs11 : JsHeapAbove PRE_first_tail_x6_r0_body.s114.next PRE_first_tail_x6_r0_body.s116 :=
  JsHeapAbove.glueSite bodyJs10 (Nat.le_of_ble_eq_true bodyJsLe11) PRE_first_tail_x6_r0_body.gjk11 PRE_first_tail_x6_r0_body.gjbd11 PRE_first_tail_x6_r0_body.cheap11 PRE_first_tail_x6_r0_body.zclbd11 bodyJsList11

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO112 : PRE_first_tail_x6_r0_body.S112.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S112.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr112 : bridgeOf PRE_first_tail_x6_r0_body.s112.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc112 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.S112) = fun _ _ => true
kernel_rfl bodyAcc113 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s113 PRE_first_tail_x6_r0_body.S113) = fun _ _ => true
kernel_rfl bodyBr114 : bridgeOf PRE_first_tail_x6_r0_body.s114.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt113 : isHalt PRE_first_tail_x6_r0_body.s113.ctl = false
kernel_rfl bodyTop114 : noRetBlock PRE_first_tail_x6_r0_body.s114 = true
kernel_rfl bodyCnt112 : countersOkB PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.s114 = true

theorem bodyGlue11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7958, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.S112)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7958, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s114 PRE_first_tail_x6_r0_body.S114) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7958, 98, 0, 63⟩) bodyAcc112 PRE_first_tail_x6_r0_body.bodyRunSeg30 bodyAcc113 bodyHalt113 PRE_first_tail_x6_r0_body.bodyStepA31 bodyTop114 (fun _ hm => bodyO112 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr112).trans bodyInactive0) (bodyBr114.trans bodyBr112.symm) bodyCnt112 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift11 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S114.tab.length PRE_first_tail_x6_r0_body.s114.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P11.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P11 523 PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.s116.ffi PRE_first_tail_x6_r0_body.s115.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_11
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_11
  have hcl : SSt (· < 523) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S114.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_11] <;> decide) PRE_first_tail_x6_r0_body.cnodesK11 PRE_first_tail_x6_r0_body.cobjsK11
      PRE_first_tail_x6_r0_body.citemsK11 PRE_first_tail_x6_r0_body.cbd11 PRE_first_tail_x6_r0_body.csst11
  exact PRE_first_tail_x6_r0_body.cshift11 bodyNcl11 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_11] at this; exact this)


kernel_rfl bodyFramesEmpty11 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s115 a).isEmpty) = true
kernel_rfl bodyJsRoots11 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s114.next) PRE_first_tail_x6_r0_body.s116.trace PRE_first_tail_x6_r0_body.s116 = true
kernel_rfl bodyJsNative11 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s116.ffi) = true
kernel_rfl bodyLow11 : (PRE_first_tail_x6_r0_body.cws11 ++ PRE_first_tail_x6_r0_body.ws11).all (Nat.ble 9) = true
kernel_rfl bodyCntM11 : countersOkB PRE_first_tail_x6_r0_body.s114 PRE_first_tail_x6_r0_body.s115 = true
kernel_rfl bodyHi11 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s116.ffi).next setupP.E = true
kernel_rfl bodyNhi11 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s116.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge11 : bridgeOf PRE_first_tail_x6_r0_body.s115.ffi = bridgeOf PRE_first_tail_x6_r0_body.s114.ffi
kernel_rfl bodyNN11 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s114.ffi).nnext PRE_first_tail_x6_r0_body.P11.NL = true
kernel_rfl bodyXn11 : Nat.ble (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s116.ffi).next = true
kernel_rfl bodyLo11 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s116.ffi).next = true
theorem bodyFacts11 : BodySiteFacts PRE_first_tail_x6_r0_body.s114 PRE_first_tail_x6_r0_body.s115 PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S114 PRE_first_tail_x6_r0_body.S115 PRE_first_tail_x6_r0_body.S116
    PRE_first_tail_x6_r0_body.ws11 PRE_first_tail_x6_r0_body.cws11 PRE_first_tail_x6_r0_body.nr11 PRE_first_tail_x6_r0_body.pl11 PRE_first_tail_x6_r0_body.cl11 2683392 523 PRE_first_tail_x6_r0_body.kd11 PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.P11
    ⟨18417, 15496, 2683381, 523⟩ ⟨18417, 15496, 2683382, 523⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap11
  clean := bodyClean11
  cfix := PRE_first_tail_x6_r0_body.cfix11
  zpl := PRE_first_tail_x6_r0_body.zpl11
  zplnd := PRE_first_tail_x6_r0_body.zplnd11
  zn1 := PRE_first_tail_x6_r0_body.zn111
  zfirst := PRE_first_tail_x6_r0_body.zfirst11
  zscn := PRE_first_tail_x6_r0_body.zscn11
  zsmn := PRE_first_tail_x6_r0_body.zsmn11
  zgrow := PRE_first_tail_x6_r0_body.zgrow11
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab11
  zfresh := PRE_first_tail_x6_r0_body.zfresh11
  zcnd := PRE_first_tail_x6_r0_body.zcnd11
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi11
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt11
  zgP := PRE_first_tail_x6_r0_body.zg11_2665
  zkP := PRE_first_tail_x6_r0_body.zk11_2665
  zmP := PRE_first_tail_x6_r0_body.zm11_2665
  zgC := PRE_first_tail_x6_r0_body.zg11_2673467
  zkC := PRE_first_tail_x6_r0_body.zk11_2673467
  zmC := PRE_first_tail_x6_r0_body.zm11_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw11_2673472
  zwV := PRE_first_tail_x6_r0_body.zw11_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap11
  zclbd := PRE_first_tail_x6_r0_body.zclbd11
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap11 PRE_first_tail_x6_r0_body.stFoot11 PRE_first_tail_x6_r0_body.iso11 PRE_first_tail_x6_r0_body.zwr11
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP11
  csupp := PRE_first_tail_x6_r0_body.csupp11
  cbound := PRE_first_tail_x6_r0_body.cbound11
  zimg := PRE_first_tail_x6_r0_body.zimg11
  zctl := PRE_first_tail_x6_r0_body.zctl11
  zstack := PRE_first_tail_x6_r0_body.zstack11
  zjobs := PRE_first_tail_x6_r0_body.zjobs11
  zstores := PRE_first_tail_x6_r0_body.zstores11
  zroots := PRE_first_tail_x6_r0_body.zroots11
  znC := PRE_first_tail_x6_r0_body.znC11
  ctab := PRE_first_tail_x6_r0_body.ctab11
  zbin := PRE_first_tail_x6_r0_body.zbin11
  cbridge := PRE_first_tail_x6_r0_body.cbridge11
  sbridge := bodyBridge11
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj11
  cshiftR := fun h hNL => bodyCshift11 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN11
  raised := PRE_first_tail_x6_r0_body.raised11
  cbigs := PRE_first_tail_x6_r0_body.cbigs11
  cjcl := PRE_first_tail_x6_r0_body.cjcl11
  xnLe := Nat.le_of_ble_eq_true bodyXn11
  loLe := Nat.le_of_ble_eq_true bodyLo11
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB11
  cntM := bodyCntM11
  hiLe := Nat.le_of_ble_eq_true bodyHi11
  nhiLe := Nat.le_of_ble_eq_true bodyNhi11
  jsHeap := bodyJs11
  jsRoots := bodyJsRoots11
  jsNative := bodyJsNative11
  framesEmpty := bodyFramesEmpty11
  trailOld := by decide
  lowVars := bodyLow11

def bodyQs11 : List (Option Q) := []
noncomputable def bodyEs11 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr11.map fun r => nth? PRE_first_tail_x6_r0_body.st11.S2.tab r
kernel_rfl bodyResChk11 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs11 bodyQs11) = true
kernel_rfl bodyLq11 : bodyQs11.length = PRE_first_tail_x6_r0_body.cws11.length
kernel_rfl bodyNrLo11 : PRE_first_tail_x6_r0_body.nr11.all (Nat.ble PRE_first_tail_x6_r0_body.S114.tab.length) = true
kernel_rfl bodySub11 : (Oracles.PRE_first_tail_x6_r0_body.map_site11.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost11 : postSubB bodyM PRE_first_tail_x6_r0_body.ws11 PRE_first_tail_x6_r0_body.cws11 bodyQs11 = true
kernel_rfl bodyDrop11 : Nat.ble (7958 + (PRE_first_tail_x6_r0_body.s115.next - PRE_first_tail_x6_r0_body.s116.next)) 7968 = true
kernel_rfl bodyDropH11 : Nat.ble (98 + ((mlxOf PRE_first_tail_x6_r0_body.s115.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s116.ffi).next)) 98 = true
kernel_rfl bodyDropN11 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s115.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s116.ffi).nnext)) 0 = true
kernel_rfl bodyDv11 : bodyΘ.1.take 63 = bodyΘ.1.take 63 ++ PRE_first_tail_x6_r0_body.cws11
kernel_rfl bodyDe11 : bodyΘ.2.take 63 = bodyΘ.2.take 63 ++ PRE_first_tail_x6_r0_body.nr11.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st11.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 63) (bodyΘ.2.take 63)))
kernel_rfl bodyDl11 : (bodyΘ.1.take 63).length = (bodyΘ.2.take 63).length
kernel_rfl bodyDold11 : (bodyΘ.1.take 63).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws11).isNone && !PRE_first_tail_x6_r0_body.ws11.contains v) = true
kernel_rfl bodyDfree11 : (bodyΘ.2.take 63).all (fun e => (PRE_first_tail_x6_r0_body.cws11 ++ PRE_first_tail_x6_r0_body.ws11).all fun w => e.noVar w) = true

theorem bodyStep11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7958, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s114 PRE_first_tail_x6_r0_body.S114)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7968, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.S116) (98 + 1) :=
  bodySite bodyFacts11.cfix bodyFacts11.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x6_r0_body.st11.S2.tab) (Es := bodyEs11) (qs := bodyQs11)
    (ok := PRE_first_tail_x6_r0_body.st11.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site11 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts11
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site11 r hr) hi (MapOk.sub hm (sub_of_all bodySub11)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk11 r hr) hi hm ho hq)
    bodyLq11 rfl bodyNrLo11 (postSub_sound bodyPost11)
    (Nat.le_of_ble_eq_true bodyDrop11) (by decide) (Nat.le_of_ble_eq_true bodyDropH11) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN11) (by decide)
    bodyDv11 bodyDe11 bodyDl11 bodyDold11 bodyDfree11 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyOracles_3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_g12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g12 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g12) (List.take 16 (List.drop 116 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site12 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st12.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g13 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g13) (List.take 7 (List.drop 132 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site13 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st13.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g14 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g14 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g14) (List.take 3 (List.drop 139 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

noncomputable def PRE_first_tail_x6_r0_body.map_site14 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site14 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g15 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g15) (List.take 16 (List.drop 142 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site15 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st15.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site12 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st12.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site12
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s131 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s132 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S131 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws12 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st12.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st12.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso12
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_12
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st12.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot12
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup12
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound12
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace12
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged12
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws12.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st12.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S131.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_12]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen12.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh12
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl12 : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl12 (PRE_first_tail_x6_r0_body.cncl11 bodyNcl11)

theorem bodyClean12 : Conv.JClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s131 :=
  PRE_first_tail_x6_r0_body.gjcl12 (PRE_first_tail_x6_r0_body.cjcl11 bodyClean11)

kernel_rfl bodyJsLe12 : Nat.ble PRE_first_tail_x6_r0_body.s114.next PRE_first_tail_x6_r0_body.s131.next = true
kernel_rfl bodyJsList12 : (PRE_first_tail_x6_r0_body.gjh12 ++ PRE_first_tail_x6_r0_body.cl12).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s131.next) PRE_first_tail_x6_r0_body.s133) = true
theorem bodyJs12 : JsHeapAbove PRE_first_tail_x6_r0_body.s131.next PRE_first_tail_x6_r0_body.s133 :=
  JsHeapAbove.glueSite bodyJs11 (Nat.le_of_ble_eq_true bodyJsLe12) PRE_first_tail_x6_r0_body.gjk12 PRE_first_tail_x6_r0_body.gjbd12 PRE_first_tail_x6_r0_body.cheap12 PRE_first_tail_x6_r0_body.zclbd12 bodyJsList12

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO116 : PRE_first_tail_x6_r0_body.S116.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S116.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr116 : bridgeOf PRE_first_tail_x6_r0_body.s116.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc116 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.S116) = fun _ _ => true
kernel_rfl bodyAcc118 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s118 PRE_first_tail_x6_r0_body.S118) = fun _ _ => true
kernel_rfl bodyBr119 : bridgeOf PRE_first_tail_x6_r0_body.s119.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt118 : isHalt PRE_first_tail_x6_r0_body.s118.ctl = false
kernel_rfl bodyTop119 : noRetBlock PRE_first_tail_x6_r0_body.s119 = true
kernel_rfl bodyCnt116 : countersOkB PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.s119 = true
kernel_rfl bodyO119 : PRE_first_tail_x6_r0_body.S119.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S119.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr120 : bridgeOf PRE_first_tail_x6_r0_body.s120.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt119 : countersOkB PRE_first_tail_x6_r0_body.s119 PRE_first_tail_x6_r0_body.s120 = true
kernel_rfl bodyO120 : PRE_first_tail_x6_r0_body.S120.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S120.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc120 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s120 PRE_first_tail_x6_r0_body.S120) = fun _ _ => true
kernel_rfl bodyAcc121 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s121 PRE_first_tail_x6_r0_body.S121) = fun _ _ => true
kernel_rfl bodyBr122 : bridgeOf PRE_first_tail_x6_r0_body.s122.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt121 : isHalt PRE_first_tail_x6_r0_body.s121.ctl = false
kernel_rfl bodyTop122 : noRetBlock PRE_first_tail_x6_r0_body.s122 = true
kernel_rfl bodyCnt120 : countersOkB PRE_first_tail_x6_r0_body.s120 PRE_first_tail_x6_r0_body.s122 = true
kernel_rfl bodyO122 : PRE_first_tail_x6_r0_body.S122.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S122.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr123 : bridgeOf PRE_first_tail_x6_r0_body.s123.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt122 : countersOkB PRE_first_tail_x6_r0_body.s122 PRE_first_tail_x6_r0_body.s123 = true
kernel_rfl bodyO123 : PRE_first_tail_x6_r0_body.S123.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S123.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc123 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s123 PRE_first_tail_x6_r0_body.S123) = fun _ _ => true
kernel_rfl bodyAcc124 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s124 PRE_first_tail_x6_r0_body.S124) = fun _ _ => true
kernel_rfl bodyBr125 : bridgeOf PRE_first_tail_x6_r0_body.s125.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt124 : isHalt PRE_first_tail_x6_r0_body.s124.ctl = false
kernel_rfl bodyTop125 : noRetBlock PRE_first_tail_x6_r0_body.s125 = true
kernel_rfl bodyCnt123 : countersOkB PRE_first_tail_x6_r0_body.s123 PRE_first_tail_x6_r0_body.s125 = true
kernel_rfl bodyO125 : PRE_first_tail_x6_r0_body.S125.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S125.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr126 : bridgeOf PRE_first_tail_x6_r0_body.s126.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt125 : countersOkB PRE_first_tail_x6_r0_body.s125 PRE_first_tail_x6_r0_body.s126 = true
kernel_rfl bodyO126 : PRE_first_tail_x6_r0_body.S126.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S126.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc126 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s126 PRE_first_tail_x6_r0_body.S126) = fun _ _ => true
kernel_rfl bodyAcc127 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s127 PRE_first_tail_x6_r0_body.S127) = fun _ _ => true
kernel_rfl bodyBr128 : bridgeOf PRE_first_tail_x6_r0_body.s128.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt127 : isHalt PRE_first_tail_x6_r0_body.s127.ctl = false
kernel_rfl bodyTop128 : noRetBlock PRE_first_tail_x6_r0_body.s128 = true
kernel_rfl bodyCnt126 : countersOkB PRE_first_tail_x6_r0_body.s126 PRE_first_tail_x6_r0_body.s128 = true
kernel_rfl bodyO128 : PRE_first_tail_x6_r0_body.S128.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S128.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr129 : bridgeOf PRE_first_tail_x6_r0_body.s129.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt128 : countersOkB PRE_first_tail_x6_r0_body.s128 PRE_first_tail_x6_r0_body.s129 = true
kernel_rfl bodyO129 : PRE_first_tail_x6_r0_body.S129.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S129.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc129 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s129 PRE_first_tail_x6_r0_body.S129) = fun _ _ => true
kernel_rfl bodyAcc130 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s130 PRE_first_tail_x6_r0_body.S130) = fun _ _ => true
kernel_rfl bodyBr131 : bridgeOf PRE_first_tail_x6_r0_body.s131.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt130 : isHalt PRE_first_tail_x6_r0_body.s130.ctl = false
kernel_rfl bodyTop131 : noRetBlock PRE_first_tail_x6_r0_body.s131 = true
kernel_rfl bodyCnt129 : countersOkB PRE_first_tail_x6_r0_body.s129 PRE_first_tail_x6_r0_body.s131 = true

theorem bodyGlue12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7968, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.S116)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7968, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s131 PRE_first_tail_x6_r0_body.S131) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc116 PRE_first_tail_x6_r0_body.bodyRunSeg31 bodyAcc118 bodyHalt118 PRE_first_tail_x6_r0_body.bodyStepA32 bodyTop119 (fun _ hm => bodyO116 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr116).trans bodyInactive0) (bodyBr119.trans bodyBr116.symm) bodyCnt116 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) PRE_first_tail_x6_r0_body.sizeA32 PRE_first_tail_x6_r0_body.sizeArgsA32 PRE_first_tail_x6_r0_body.sizeSymA32 PRE_first_tail_x6_r0_body.sizeMlxA32 PRE_first_tail_x6_r0_body.sizePayA32 PRE_first_tail_x6_r0_body.sizeTaA32 PRE_first_tail_x6_r0_body.sizeDecA32 PRE_first_tail_x6_r0_body.sizePreA32 PRE_first_tail_x6_r0_body.bodyPatchB32 (fun _ hm => bodyO119 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr119).trans bodyInactive0) (bodyBr120.trans bodyBr119.symm) bodyCnt119 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc120 PRE_first_tail_x6_r0_body.bodyRunSeg32 bodyAcc121 bodyHalt121 PRE_first_tail_x6_r0_body.bodyStepA33 bodyTop122 (fun _ hm => bodyO120 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr120).trans bodyInactive0) (bodyBr122.trans bodyBr120.symm) bodyCnt120 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) PRE_first_tail_x6_r0_body.sizeA33 PRE_first_tail_x6_r0_body.sizeArgsA33 PRE_first_tail_x6_r0_body.sizeSymA33 PRE_first_tail_x6_r0_body.sizeMlxA33 PRE_first_tail_x6_r0_body.sizePayA33 PRE_first_tail_x6_r0_body.sizeTaA33 PRE_first_tail_x6_r0_body.sizeDecA33 PRE_first_tail_x6_r0_body.sizePreA33 PRE_first_tail_x6_r0_body.bodyPatchB33 (fun _ hm => bodyO122 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr122).trans bodyInactive0) (bodyBr123.trans bodyBr122.symm) bodyCnt122 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc123 PRE_first_tail_x6_r0_body.bodyRunSeg33 bodyAcc124 bodyHalt124 PRE_first_tail_x6_r0_body.bodyStepA34 bodyTop125 (fun _ hm => bodyO123 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr123).trans bodyInactive0) (bodyBr125.trans bodyBr123.symm) bodyCnt123 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) PRE_first_tail_x6_r0_body.sizeA34 PRE_first_tail_x6_r0_body.sizeArgsA34 PRE_first_tail_x6_r0_body.sizeSymA34 PRE_first_tail_x6_r0_body.sizeMlxA34 PRE_first_tail_x6_r0_body.sizePayA34 PRE_first_tail_x6_r0_body.sizeTaA34 PRE_first_tail_x6_r0_body.sizeDecA34 PRE_first_tail_x6_r0_body.sizePreA34 PRE_first_tail_x6_r0_body.bodyPatchB34 (fun _ hm => bodyO125 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr125).trans bodyInactive0) (bodyBr126.trans bodyBr125.symm) bodyCnt125 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc126 PRE_first_tail_x6_r0_body.bodyRunSeg34 bodyAcc127 bodyHalt127 PRE_first_tail_x6_r0_body.bodyStepA35 bodyTop128 (fun _ hm => bodyO126 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr126).trans bodyInactive0) (bodyBr128.trans bodyBr126.symm) bodyCnt126 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) PRE_first_tail_x6_r0_body.sizeA35 PRE_first_tail_x6_r0_body.sizeArgsA35 PRE_first_tail_x6_r0_body.sizeSymA35 PRE_first_tail_x6_r0_body.sizeMlxA35 PRE_first_tail_x6_r0_body.sizePayA35 PRE_first_tail_x6_r0_body.sizeTaA35 PRE_first_tail_x6_r0_body.sizeDecA35 PRE_first_tail_x6_r0_body.sizePreA35 PRE_first_tail_x6_r0_body.bodyPatchB35 (fun _ hm => bodyO128 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr128).trans bodyInactive0) (bodyBr129.trans bodyBr128.symm) bodyCnt128 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc129 PRE_first_tail_x6_r0_body.bodyRunSeg35 bodyAcc130 bodyHalt130 PRE_first_tail_x6_r0_body.bodyStepA36 bodyTop131 (fun _ hm => bodyO129 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr129).trans bodyInactive0) (bodyBr131.trans bodyBr129.symm) bodyCnt129 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift12 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S131.tab.length PRE_first_tail_x6_r0_body.s131.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P12.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P12 614 PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.s133.ffi PRE_first_tail_x6_r0_body.s132.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_12
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_12
  have hcl : SSt (· < 614) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S131.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_12] <;> decide) PRE_first_tail_x6_r0_body.cnodesK12 PRE_first_tail_x6_r0_body.cobjsK12
      PRE_first_tail_x6_r0_body.citemsK12 PRE_first_tail_x6_r0_body.cbd12 PRE_first_tail_x6_r0_body.csst12
  exact PRE_first_tail_x6_r0_body.cshift12 bodyNcl12 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_12] at this; exact this)


kernel_rfl bodyFramesEmpty12 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s132 a).isEmpty) = true
kernel_rfl bodyJsRoots12 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s131.next) PRE_first_tail_x6_r0_body.s133.trace PRE_first_tail_x6_r0_body.s133 = true
kernel_rfl bodyJsNative12 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s133.ffi) = true
kernel_rfl bodyLow12 : (PRE_first_tail_x6_r0_body.cws12 ++ PRE_first_tail_x6_r0_body.ws12).all (Nat.ble 9) = true
kernel_rfl bodyCntM12 : countersOkB PRE_first_tail_x6_r0_body.s131 PRE_first_tail_x6_r0_body.s132 = true
kernel_rfl bodyHi12 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s133.ffi).next setupP.E = true
kernel_rfl bodyNhi12 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s133.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge12 : bridgeOf PRE_first_tail_x6_r0_body.s132.ffi = bridgeOf PRE_first_tail_x6_r0_body.s131.ffi
kernel_rfl bodyNN12 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s131.ffi).nnext PRE_first_tail_x6_r0_body.P12.NL = true
kernel_rfl bodyXn12 : Nat.ble (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s133.ffi).next = true
kernel_rfl bodyLo12 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s133.ffi).next = true
theorem bodyFacts12 : BodySiteFacts PRE_first_tail_x6_r0_body.s131 PRE_first_tail_x6_r0_body.s132 PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S131 PRE_first_tail_x6_r0_body.S132 PRE_first_tail_x6_r0_body.S133
    PRE_first_tail_x6_r0_body.ws12 PRE_first_tail_x6_r0_body.cws12 PRE_first_tail_x6_r0_body.nr12 PRE_first_tail_x6_r0_body.pl12 PRE_first_tail_x6_r0_body.cl12 2686030 614 PRE_first_tail_x6_r0_body.kd12 PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.P12
    ⟨18452, 15515, 2684875, 596⟩ ⟨18455, 15542, 2684881, 614⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap12
  clean := bodyClean12
  cfix := PRE_first_tail_x6_r0_body.cfix12
  zpl := PRE_first_tail_x6_r0_body.zpl12
  zplnd := PRE_first_tail_x6_r0_body.zplnd12
  zn1 := PRE_first_tail_x6_r0_body.zn112
  zfirst := PRE_first_tail_x6_r0_body.zfirst12
  zscn := PRE_first_tail_x6_r0_body.zscn12
  zsmn := PRE_first_tail_x6_r0_body.zsmn12
  zgrow := PRE_first_tail_x6_r0_body.zgrow12
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab12
  zfresh := PRE_first_tail_x6_r0_body.zfresh12
  zcnd := PRE_first_tail_x6_r0_body.zcnd12
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi12
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt12
  zgP := PRE_first_tail_x6_r0_body.zg12_2665
  zkP := PRE_first_tail_x6_r0_body.zk12_2665
  zmP := PRE_first_tail_x6_r0_body.zm12_2665
  zgC := PRE_first_tail_x6_r0_body.zg12_2673467
  zkC := PRE_first_tail_x6_r0_body.zk12_2673467
  zmC := PRE_first_tail_x6_r0_body.zm12_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw12_2673472
  zwV := PRE_first_tail_x6_r0_body.zw12_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap12
  zclbd := PRE_first_tail_x6_r0_body.zclbd12
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap12 PRE_first_tail_x6_r0_body.stFoot12 PRE_first_tail_x6_r0_body.iso12 PRE_first_tail_x6_r0_body.zwr12
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP12
  csupp := PRE_first_tail_x6_r0_body.csupp12
  cbound := PRE_first_tail_x6_r0_body.cbound12
  zimg := PRE_first_tail_x6_r0_body.zimg12
  zctl := PRE_first_tail_x6_r0_body.zctl12
  zstack := PRE_first_tail_x6_r0_body.zstack12
  zjobs := PRE_first_tail_x6_r0_body.zjobs12
  zstores := PRE_first_tail_x6_r0_body.zstores12
  zroots := PRE_first_tail_x6_r0_body.zroots12
  znC := PRE_first_tail_x6_r0_body.znC12
  ctab := PRE_first_tail_x6_r0_body.ctab12
  zbin := PRE_first_tail_x6_r0_body.zbin12
  cbridge := PRE_first_tail_x6_r0_body.cbridge12
  sbridge := bodyBridge12
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj12
  cshiftR := fun h hNL => bodyCshift12 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN12
  raised := PRE_first_tail_x6_r0_body.raised12
  cbigs := PRE_first_tail_x6_r0_body.cbigs12
  cjcl := PRE_first_tail_x6_r0_body.cjcl12
  xnLe := Nat.le_of_ble_eq_true bodyXn12
  loLe := Nat.le_of_ble_eq_true bodyLo12
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB12
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
noncomputable def bodyEs12 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr12.map fun r => nth? PRE_first_tail_x6_r0_body.st12.S5.tab r
kernel_rfl bodyResChk12 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs12 bodyQs12) = true
kernel_rfl bodyLq12 : bodyQs12.length = PRE_first_tail_x6_r0_body.cws12.length
kernel_rfl bodyNrLo12 : PRE_first_tail_x6_r0_body.nr12.all (Nat.ble PRE_first_tail_x6_r0_body.S131.tab.length) = true
kernel_rfl bodySub12 : (Oracles.PRE_first_tail_x6_r0_body.map_site12.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost12 : postSubB bodyM PRE_first_tail_x6_r0_body.ws12 PRE_first_tail_x6_r0_body.cws12 bodyQs12 = true
kernel_rfl bodyDrop12 : Nat.ble (7968 + (PRE_first_tail_x6_r0_body.s132.next - PRE_first_tail_x6_r0_body.s133.next)) 9117 = true
kernel_rfl bodyDropH12 : Nat.ble (98 + ((mlxOf PRE_first_tail_x6_r0_body.s132.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s133.ffi).next)) 123 = true
kernel_rfl bodyDropN12 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s132.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s133.ffi).nnext)) 0 = true
kernel_rfl bodyDv12 : bodyΘ.1.take 81 = bodyΘ.1.take 63 ++ PRE_first_tail_x6_r0_body.cws12
kernel_rfl bodyDe12 : bodyΘ.2.take 81 = bodyΘ.2.take 63 ++ PRE_first_tail_x6_r0_body.nr12.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st12.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 63) (bodyΘ.2.take 63)))
kernel_rfl bodyDl12 : (bodyΘ.1.take 63).length = (bodyΘ.2.take 63).length
kernel_rfl bodyDold12 : (bodyΘ.1.take 63).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws12).isNone && !PRE_first_tail_x6_r0_body.ws12.contains v) = true
kernel_rfl bodyDfree12 : (bodyΘ.2.take 81).all (fun e => (PRE_first_tail_x6_r0_body.cws12 ++ PRE_first_tail_x6_r0_body.ws12).all fun w => e.noVar w) = true

theorem bodyStep12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7968, 98, 0, 63⟩ bodyM PRE_first_tail_x6_r0_body.s131 PRE_first_tail_x6_r0_body.S131)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9117, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.S133) (11334 + 1) :=
  bodySite bodyFacts12.cfix bodyFacts12.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x6_r0_body.st12.S5.tab) (Es := bodyEs12) (qs := bodyQs12)
    (ok := PRE_first_tail_x6_r0_body.st12.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site12 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts12
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site12 r hr) hi (MapOk.sub hm (sub_of_all bodySub12)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk12 r hr) hi hm ho hq)
    bodyLq12 rfl bodyNrLo12 (postSub_sound bodyPost12)
    (Nat.le_of_ble_eq_true bodyDrop12) (by decide) (Nat.le_of_ble_eq_true bodyDropH12) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN12) (by decide)
    bodyDv12 bodyDe12 bodyDl12 bodyDold12 bodyDfree12 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site13 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st13.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site13
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s139 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s140 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S139 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws13 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st13.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st13.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso13
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_13
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st13.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot13
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup13
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound13
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace13
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged13
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws13.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st13.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S139.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_13]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen13.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh13
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl13 : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl13 (PRE_first_tail_x6_r0_body.cncl12 bodyNcl12)

theorem bodyClean13 : Conv.JClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s139 :=
  PRE_first_tail_x6_r0_body.gjcl13 (PRE_first_tail_x6_r0_body.cjcl12 bodyClean12)

kernel_rfl bodyJsLe13 : Nat.ble PRE_first_tail_x6_r0_body.s131.next PRE_first_tail_x6_r0_body.s139.next = true
kernel_rfl bodyJsList13 : (PRE_first_tail_x6_r0_body.gjh13 ++ PRE_first_tail_x6_r0_body.cl13).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s139.next) PRE_first_tail_x6_r0_body.s141) = true
theorem bodyJs13 : JsHeapAbove PRE_first_tail_x6_r0_body.s139.next PRE_first_tail_x6_r0_body.s141 :=
  JsHeapAbove.glueSite bodyJs12 (Nat.le_of_ble_eq_true bodyJsLe13) PRE_first_tail_x6_r0_body.gjk13 PRE_first_tail_x6_r0_body.gjbd13 PRE_first_tail_x6_r0_body.cheap13 PRE_first_tail_x6_r0_body.zclbd13 bodyJsList13

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO133 : PRE_first_tail_x6_r0_body.S133.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S133.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr133 : bridgeOf PRE_first_tail_x6_r0_body.s133.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc133 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.S133) = fun _ _ => true
kernel_rfl bodyAcc134 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s134 PRE_first_tail_x6_r0_body.S134) = fun _ _ => true
kernel_rfl bodyBr135 : bridgeOf PRE_first_tail_x6_r0_body.s135.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt134 : isHalt PRE_first_tail_x6_r0_body.s134.ctl = false
kernel_rfl bodyTop135 : noRetBlock PRE_first_tail_x6_r0_body.s135 = true
kernel_rfl bodyCnt133 : countersOkB PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.s135 = true
kernel_rfl bodyO135 : PRE_first_tail_x6_r0_body.S135.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S135.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr136 : bridgeOf PRE_first_tail_x6_r0_body.s136.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt135 : countersOkB PRE_first_tail_x6_r0_body.s135 PRE_first_tail_x6_r0_body.s136 = true
kernel_rfl bodyO136 : PRE_first_tail_x6_r0_body.S136.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S136.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc136 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s136 PRE_first_tail_x6_r0_body.S136) = fun _ _ => true
kernel_rfl bodyAcc138 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s138 PRE_first_tail_x6_r0_body.S138) = fun _ _ => true
kernel_rfl bodyBr139 : bridgeOf PRE_first_tail_x6_r0_body.s139.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt138 : isHalt PRE_first_tail_x6_r0_body.s138.ctl = false
kernel_rfl bodyTop139 : noRetBlock PRE_first_tail_x6_r0_body.s139 = true
kernel_rfl bodyCnt136 : countersOkB PRE_first_tail_x6_r0_body.s136 PRE_first_tail_x6_r0_body.s139 = true

theorem bodyGlue13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9117, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.S133)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9117, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s139 PRE_first_tail_x6_r0_body.S139) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9117, 123, 0, 81⟩) bodyAcc133 PRE_first_tail_x6_r0_body.bodyRunSeg36 bodyAcc134 bodyHalt134 PRE_first_tail_x6_r0_body.bodyStepA37 bodyTop135 (fun _ hm => bodyO133 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr133).trans bodyInactive0) (bodyBr135.trans bodyBr133.symm) bodyCnt133 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9117, 123, 0, 81⟩) PRE_first_tail_x6_r0_body.sizeA37 PRE_first_tail_x6_r0_body.sizeArgsA37 PRE_first_tail_x6_r0_body.sizeSymA37 PRE_first_tail_x6_r0_body.sizeMlxA37 PRE_first_tail_x6_r0_body.sizePayA37 PRE_first_tail_x6_r0_body.sizeTaA37 PRE_first_tail_x6_r0_body.sizeDecA37 PRE_first_tail_x6_r0_body.sizePreA37 PRE_first_tail_x6_r0_body.bodyPatchB37 (fun _ hm => bodyO135 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr135).trans bodyInactive0) (bodyBr136.trans bodyBr135.symm) bodyCnt135 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9117, 123, 0, 81⟩) bodyAcc136 PRE_first_tail_x6_r0_body.bodyRunSeg37 bodyAcc138 bodyHalt138 PRE_first_tail_x6_r0_body.bodyStepA38 bodyTop139 (fun _ hm => bodyO136 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr136).trans bodyInactive0) (bodyBr139.trans bodyBr136.symm) bodyCnt136 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift13 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S139.tab.length PRE_first_tail_x6_r0_body.s139.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P13.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P13 635 PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.s141.ffi PRE_first_tail_x6_r0_body.s140.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_13
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_13
  have hcl : SSt (· < 635) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S139.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_13] <;> decide) PRE_first_tail_x6_r0_body.cnodesK13 PRE_first_tail_x6_r0_body.cobjsK13
      PRE_first_tail_x6_r0_body.citemsK13 PRE_first_tail_x6_r0_body.cbd13 PRE_first_tail_x6_r0_body.csst13
  exact PRE_first_tail_x6_r0_body.cshift13 bodyNcl13 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_13] at this; exact this)


kernel_rfl bodyFramesEmpty13 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s140 a).isEmpty) = true
kernel_rfl bodyJsRoots13 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s139.next) PRE_first_tail_x6_r0_body.s141.trace PRE_first_tail_x6_r0_body.s141 = true
kernel_rfl bodyJsNative13 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s141.ffi) = true
kernel_rfl bodyLow13 : (PRE_first_tail_x6_r0_body.cws13 ++ PRE_first_tail_x6_r0_body.ws13).all (Nat.ble 9) = true
kernel_rfl bodyCntM13 : countersOkB PRE_first_tail_x6_r0_body.s139 PRE_first_tail_x6_r0_body.s140 = true
kernel_rfl bodyHi13 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s141.ffi).next setupP.E = true
kernel_rfl bodyNhi13 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s141.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge13 : bridgeOf PRE_first_tail_x6_r0_body.s140.ffi = bridgeOf PRE_first_tail_x6_r0_body.s139.ffi
kernel_rfl bodyNN13 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s139.ffi).nnext PRE_first_tail_x6_r0_body.P13.NL = true
kernel_rfl bodyXn13 : Nat.ble (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s141.ffi).next = true
kernel_rfl bodyLo13 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s141.ffi).next = true
theorem bodyFacts13 : BodySiteFacts PRE_first_tail_x6_r0_body.s139 PRE_first_tail_x6_r0_body.s140 PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S139 PRE_first_tail_x6_r0_body.S140 PRE_first_tail_x6_r0_body.S141
    PRE_first_tail_x6_r0_body.ws13 PRE_first_tail_x6_r0_body.cws13 PRE_first_tail_x6_r0_body.nr13 PRE_first_tail_x6_r0_body.pl13 PRE_first_tail_x6_r0_body.cl13 2685373 635 PRE_first_tail_x6_r0_body.kd13 PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.P13
    ⟨18468, 15555, 2685371, 635⟩ ⟨18468, 15555, 2685371, 635⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap13
  clean := bodyClean13
  cfix := PRE_first_tail_x6_r0_body.cfix13
  zpl := PRE_first_tail_x6_r0_body.zpl13
  zplnd := PRE_first_tail_x6_r0_body.zplnd13
  zn1 := PRE_first_tail_x6_r0_body.zn113
  zfirst := PRE_first_tail_x6_r0_body.zfirst13
  zscn := PRE_first_tail_x6_r0_body.zscn13
  zsmn := PRE_first_tail_x6_r0_body.zsmn13
  zgrow := PRE_first_tail_x6_r0_body.zgrow13
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab13
  zfresh := PRE_first_tail_x6_r0_body.zfresh13
  zcnd := PRE_first_tail_x6_r0_body.zcnd13
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi13
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt13
  zgP := PRE_first_tail_x6_r0_body.zg13_2665
  zkP := PRE_first_tail_x6_r0_body.zk13_2665
  zmP := PRE_first_tail_x6_r0_body.zm13_2665
  zgC := PRE_first_tail_x6_r0_body.zg13_2673467
  zkC := PRE_first_tail_x6_r0_body.zk13_2673467
  zmC := PRE_first_tail_x6_r0_body.zm13_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw13_2673472
  zwV := PRE_first_tail_x6_r0_body.zw13_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap13
  zclbd := PRE_first_tail_x6_r0_body.zclbd13
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap13 PRE_first_tail_x6_r0_body.stFoot13 PRE_first_tail_x6_r0_body.iso13 PRE_first_tail_x6_r0_body.zwr13
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP13
  csupp := PRE_first_tail_x6_r0_body.csupp13
  cbound := PRE_first_tail_x6_r0_body.cbound13
  zimg := PRE_first_tail_x6_r0_body.zimg13
  zctl := PRE_first_tail_x6_r0_body.zctl13
  zstack := PRE_first_tail_x6_r0_body.zstack13
  zjobs := PRE_first_tail_x6_r0_body.zjobs13
  zstores := PRE_first_tail_x6_r0_body.zstores13
  zroots := PRE_first_tail_x6_r0_body.zroots13
  znC := PRE_first_tail_x6_r0_body.znC13
  ctab := PRE_first_tail_x6_r0_body.ctab13
  zbin := PRE_first_tail_x6_r0_body.zbin13
  cbridge := PRE_first_tail_x6_r0_body.cbridge13
  sbridge := bodyBridge13
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj13
  cshiftR := fun h hNL => bodyCshift13 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN13
  raised := PRE_first_tail_x6_r0_body.raised13
  cbigs := PRE_first_tail_x6_r0_body.cbigs13
  cjcl := PRE_first_tail_x6_r0_body.cjcl13
  xnLe := Nat.le_of_ble_eq_true bodyXn13
  loLe := Nat.le_of_ble_eq_true bodyLo13
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB13
  cntM := bodyCntM13
  hiLe := Nat.le_of_ble_eq_true bodyHi13
  nhiLe := Nat.le_of_ble_eq_true bodyNhi13
  jsHeap := bodyJs13
  jsRoots := bodyJsRoots13
  jsNative := bodyJsNative13
  framesEmpty := bodyFramesEmpty13
  trailOld := by decide
  lowVars := bodyLow13

def bodyQs13 : List (Option Q) := []
noncomputable def bodyEs13 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr13.map fun r => nth? PRE_first_tail_x6_r0_body.st13.S2.tab r
kernel_rfl bodyResChk13 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs13 bodyQs13) = true
kernel_rfl bodyLq13 : bodyQs13.length = PRE_first_tail_x6_r0_body.cws13.length
kernel_rfl bodyNrLo13 : PRE_first_tail_x6_r0_body.nr13.all (Nat.ble PRE_first_tail_x6_r0_body.S139.tab.length) = true
kernel_rfl bodySub13 : (Oracles.PRE_first_tail_x6_r0_body.map_site13.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost13 : postSubB bodyM PRE_first_tail_x6_r0_body.ws13 PRE_first_tail_x6_r0_body.cws13 bodyQs13 = true
kernel_rfl bodyDrop13 : Nat.ble (9117 + (PRE_first_tail_x6_r0_body.s140.next - PRE_first_tail_x6_r0_body.s141.next)) 9119 = true
kernel_rfl bodyDropH13 : Nat.ble (123 + ((mlxOf PRE_first_tail_x6_r0_body.s140.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s141.ffi).next)) 123 = true
kernel_rfl bodyDropN13 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s140.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s141.ffi).nnext)) 0 = true
kernel_rfl bodyDv13 : bodyΘ.1.take 81 = bodyΘ.1.take 81 ++ PRE_first_tail_x6_r0_body.cws13
kernel_rfl bodyDe13 : bodyΘ.2.take 81 = bodyΘ.2.take 81 ++ PRE_first_tail_x6_r0_body.nr13.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st13.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 81) (bodyΘ.2.take 81)))
kernel_rfl bodyDl13 : (bodyΘ.1.take 81).length = (bodyΘ.2.take 81).length
kernel_rfl bodyDold13 : (bodyΘ.1.take 81).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws13).isNone && !PRE_first_tail_x6_r0_body.ws13.contains v) = true
kernel_rfl bodyDfree13 : (bodyΘ.2.take 81).all (fun e => (PRE_first_tail_x6_r0_body.cws13 ++ PRE_first_tail_x6_r0_body.ws13).all fun w => e.noVar w) = true

theorem bodyStep13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9117, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s139 PRE_first_tail_x6_r0_body.S139)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9119, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.S141) (27 + 1) :=
  bodySite bodyFacts13.cfix bodyFacts13.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x6_r0_body.st13.S2.tab) (Es := bodyEs13) (qs := bodyQs13)
    (ok := PRE_first_tail_x6_r0_body.st13.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site13 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts13
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site13 r hr) hi (MapOk.sub hm (sub_of_all bodySub13)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk13 r hr) hi hm ho hq)
    bodyLq13 rfl bodyNrLo13 (postSub_sound bodyPost13)
    (Nat.le_of_ble_eq_true bodyDrop13) (by decide) (Nat.le_of_ble_eq_true bodyDropH13) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN13) (by decide)
    bodyDv13 bodyDe13 bodyDl13 bodyDold13 bodyDfree13 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x6_r0_body.map_site14 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site14 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site14
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s143 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s144 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S143 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws14 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso14
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_14
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot14
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup14
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound14
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace14
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged14
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws14.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st14.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S143.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_14]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen14.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh14
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl14 : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl14 (PRE_first_tail_x6_r0_body.cncl13 bodyNcl13)

theorem bodyClean14 : Conv.JClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s143 :=
  PRE_first_tail_x6_r0_body.gjcl14 (PRE_first_tail_x6_r0_body.cjcl13 bodyClean13)

kernel_rfl bodyJsLe14 : Nat.ble PRE_first_tail_x6_r0_body.s139.next PRE_first_tail_x6_r0_body.s143.next = true
kernel_rfl bodyJsList14 : (PRE_first_tail_x6_r0_body.gjh14 ++ PRE_first_tail_x6_r0_body.cl14).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s143.next) PRE_first_tail_x6_r0_body.s145) = true
theorem bodyJs14 : JsHeapAbove PRE_first_tail_x6_r0_body.s143.next PRE_first_tail_x6_r0_body.s145 :=
  JsHeapAbove.glueSite bodyJs13 (Nat.le_of_ble_eq_true bodyJsLe14) PRE_first_tail_x6_r0_body.gjk14 PRE_first_tail_x6_r0_body.gjbd14 PRE_first_tail_x6_r0_body.cheap14 PRE_first_tail_x6_r0_body.zclbd14 bodyJsList14

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO141 : PRE_first_tail_x6_r0_body.S141.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S141.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr141 : bridgeOf PRE_first_tail_x6_r0_body.s141.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc141 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.S141) = fun _ _ => true
kernel_rfl bodyAcc142 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s142 PRE_first_tail_x6_r0_body.S142) = fun _ _ => true
kernel_rfl bodyBr143 : bridgeOf PRE_first_tail_x6_r0_body.s143.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt142 : isHalt PRE_first_tail_x6_r0_body.s142.ctl = false
kernel_rfl bodyTop143 : noRetBlock PRE_first_tail_x6_r0_body.s143 = true
kernel_rfl bodyCnt141 : countersOkB PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.s143 = true

theorem bodyGlue14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9119, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.S141)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9119, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s143 PRE_first_tail_x6_r0_body.S143) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9119, 123, 0, 81⟩) bodyAcc141 PRE_first_tail_x6_r0_body.bodyRunSeg38 bodyAcc142 bodyHalt142 PRE_first_tail_x6_r0_body.bodyStepA39 bodyTop143 (fun _ hm => bodyO141 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr141).trans bodyInactive0) (bodyBr143.trans bodyBr141.symm) bodyCnt141 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift14 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S143.tab.length PRE_first_tail_x6_r0_body.s143.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P14.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P14 652 PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.s145.ffi PRE_first_tail_x6_r0_body.s144.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_14
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_14
  have hcl : SSt (· < 652) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S143.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_14] <;> decide) PRE_first_tail_x6_r0_body.cnodesK14 PRE_first_tail_x6_r0_body.cobjsK14
      PRE_first_tail_x6_r0_body.citemsK14 PRE_first_tail_x6_r0_body.cbd14 PRE_first_tail_x6_r0_body.csst14
  exact PRE_first_tail_x6_r0_body.cshift14 bodyNcl14 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_14] at this; exact this)


kernel_rfl bodyFramesEmpty14 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s144 a).isEmpty) = true
kernel_rfl bodyJsRoots14 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s143.next) PRE_first_tail_x6_r0_body.s145.trace PRE_first_tail_x6_r0_body.s145 = true
kernel_rfl bodyJsNative14 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s145.ffi) = true
kernel_rfl bodyLow14 : (PRE_first_tail_x6_r0_body.cws14 ++ PRE_first_tail_x6_r0_body.ws14).all (Nat.ble 9) = true
kernel_rfl bodyCntM14 : countersOkB PRE_first_tail_x6_r0_body.s143 PRE_first_tail_x6_r0_body.s144 = true
kernel_rfl bodyHi14 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s145.ffi).next setupP.E = true
kernel_rfl bodyNhi14 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s145.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge14 : bridgeOf PRE_first_tail_x6_r0_body.s144.ffi = bridgeOf PRE_first_tail_x6_r0_body.s143.ffi
kernel_rfl bodyNN14 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s143.ffi).nnext PRE_first_tail_x6_r0_body.P14.NL = true
kernel_rfl bodyXn14 : Nat.ble (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s145.ffi).next = true
kernel_rfl bodyLo14 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s145.ffi).next = true
theorem bodyFacts14 : BodySiteFacts PRE_first_tail_x6_r0_body.s143 PRE_first_tail_x6_r0_body.s144 PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S143 PRE_first_tail_x6_r0_body.S144 PRE_first_tail_x6_r0_body.S145
    PRE_first_tail_x6_r0_body.ws14 PRE_first_tail_x6_r0_body.cws14 PRE_first_tail_x6_r0_body.nr14 PRE_first_tail_x6_r0_body.pl14 PRE_first_tail_x6_r0_body.cl14 2685670 652 PRE_first_tail_x6_r0_body.kd14 PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.P14
    ⟨18475, 15559, 2685659, 652⟩ ⟨18475, 15559, 2685660, 652⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap14
  clean := bodyClean14
  cfix := PRE_first_tail_x6_r0_body.cfix14
  zpl := PRE_first_tail_x6_r0_body.zpl14
  zplnd := PRE_first_tail_x6_r0_body.zplnd14
  zn1 := PRE_first_tail_x6_r0_body.zn114
  zfirst := PRE_first_tail_x6_r0_body.zfirst14
  zscn := PRE_first_tail_x6_r0_body.zscn14
  zsmn := PRE_first_tail_x6_r0_body.zsmn14
  zgrow := PRE_first_tail_x6_r0_body.zgrow14
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab14
  zfresh := PRE_first_tail_x6_r0_body.zfresh14
  zcnd := PRE_first_tail_x6_r0_body.zcnd14
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi14
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt14
  zgP := PRE_first_tail_x6_r0_body.zg14_2665
  zkP := PRE_first_tail_x6_r0_body.zk14_2665
  zmP := PRE_first_tail_x6_r0_body.zm14_2665
  zgC := PRE_first_tail_x6_r0_body.zg14_2673467
  zkC := PRE_first_tail_x6_r0_body.zk14_2673467
  zmC := PRE_first_tail_x6_r0_body.zm14_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw14_2673472
  zwV := PRE_first_tail_x6_r0_body.zw14_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap14
  zclbd := PRE_first_tail_x6_r0_body.zclbd14
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap14 PRE_first_tail_x6_r0_body.stFoot14 PRE_first_tail_x6_r0_body.iso14 PRE_first_tail_x6_r0_body.zwr14
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP14
  csupp := PRE_first_tail_x6_r0_body.csupp14
  cbound := PRE_first_tail_x6_r0_body.cbound14
  zimg := PRE_first_tail_x6_r0_body.zimg14
  zctl := PRE_first_tail_x6_r0_body.zctl14
  zstack := PRE_first_tail_x6_r0_body.zstack14
  zjobs := PRE_first_tail_x6_r0_body.zjobs14
  zstores := PRE_first_tail_x6_r0_body.zstores14
  zroots := PRE_first_tail_x6_r0_body.zroots14
  znC := PRE_first_tail_x6_r0_body.znC14
  ctab := PRE_first_tail_x6_r0_body.ctab14
  zbin := PRE_first_tail_x6_r0_body.zbin14
  cbridge := PRE_first_tail_x6_r0_body.cbridge14
  sbridge := bodyBridge14
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj14
  cshiftR := fun h hNL => bodyCshift14 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN14
  raised := PRE_first_tail_x6_r0_body.raised14
  cbigs := PRE_first_tail_x6_r0_body.cbigs14
  cjcl := PRE_first_tail_x6_r0_body.cjcl14
  xnLe := Nat.le_of_ble_eq_true bodyXn14
  loLe := Nat.le_of_ble_eq_true bodyLo14
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB14
  cntM := bodyCntM14
  hiLe := Nat.le_of_ble_eq_true bodyHi14
  nhiLe := Nat.le_of_ble_eq_true bodyNhi14
  jsHeap := bodyJs14
  jsRoots := bodyJsRoots14
  jsNative := bodyJsNative14
  framesEmpty := bodyFramesEmpty14
  trailOld := by decide
  lowVars := bodyLow14

def bodyQs14 : List (Option Q) := []
noncomputable def bodyEs14 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr14.map fun r => nth? PRE_first_tail_x6_r0_body.st14.S2.tab r
kernel_rfl bodyResChk14 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs14 bodyQs14) = true
kernel_rfl bodyLq14 : bodyQs14.length = PRE_first_tail_x6_r0_body.cws14.length
kernel_rfl bodyNrLo14 : PRE_first_tail_x6_r0_body.nr14.all (Nat.ble PRE_first_tail_x6_r0_body.S143.tab.length) = true
kernel_rfl bodySub14 : (Oracles.PRE_first_tail_x6_r0_body.map_site14.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost14 : postSubB bodyM PRE_first_tail_x6_r0_body.ws14 PRE_first_tail_x6_r0_body.cws14 bodyQs14 = true
kernel_rfl bodyDrop14 : Nat.ble (9119 + (PRE_first_tail_x6_r0_body.s144.next - PRE_first_tail_x6_r0_body.s145.next)) 9129 = true
kernel_rfl bodyDropH14 : Nat.ble (123 + ((mlxOf PRE_first_tail_x6_r0_body.s144.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s145.ffi).next)) 123 = true
kernel_rfl bodyDropN14 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s144.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s145.ffi).nnext)) 0 = true
kernel_rfl bodyDv14 : bodyΘ.1.take 81 = bodyΘ.1.take 81 ++ PRE_first_tail_x6_r0_body.cws14
kernel_rfl bodyDe14 : bodyΘ.2.take 81 = bodyΘ.2.take 81 ++ PRE_first_tail_x6_r0_body.nr14.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st14.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 81) (bodyΘ.2.take 81)))
kernel_rfl bodyDl14 : (bodyΘ.1.take 81).length = (bodyΘ.2.take 81).length
kernel_rfl bodyDold14 : (bodyΘ.1.take 81).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws14).isNone && !PRE_first_tail_x6_r0_body.ws14.contains v) = true
kernel_rfl bodyDfree14 : (bodyΘ.2.take 81).all (fun e => (PRE_first_tail_x6_r0_body.cws14 ++ PRE_first_tail_x6_r0_body.ws14).all fun w => e.noVar w) = true

theorem bodyStep14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9119, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s143 PRE_first_tail_x6_r0_body.S143)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9129, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.S145) (98 + 1) :=
  bodySite bodyFacts14.cfix bodyFacts14.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x6_r0_body.st14.S2.tab) (Es := bodyEs14) (qs := bodyQs14)
    (ok := PRE_first_tail_x6_r0_body.st14.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site14 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts14
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site14 r hr) hi (MapOk.sub hm (sub_of_all bodySub14)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk14 r hr) hi hm ho hq)
    bodyLq14 rfl bodyNrLo14 (postSub_sound bodyPost14)
    (Nat.le_of_ble_eq_true bodyDrop14) (by decide) (Nat.le_of_ble_eq_true bodyDropH14) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN14) (by decide)
    bodyDv14 bodyDe14 bodyDl14 bodyDold14 bodyDfree14 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n), (1185, Q.n), (1186, Q.n), (1188, Q.n), (1190, Q.n), (1191, Q.n), (1192, Q.n), (1193, Q.n), (1230, Q.n), (1231, Q.n), (1233, Q.n), (1234, Q.n), (1235, Q.n), (1236, Q.n), (1237, Q.n), (1240, Q.n), (1241, Q.n), (1243, Q.n), (1244, Q.n), (1245, Q.n), (1246, Q.n), (1247, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site15 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st15.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site15
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s160 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s161 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S160 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws15 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st15.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st15.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso15
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_15
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st15.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot15
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup15
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound15
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace15
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged15
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws15.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st15.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S160.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_15]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen15.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh15
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl15 : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl15 (PRE_first_tail_x6_r0_body.cncl14 bodyNcl14)

theorem bodyClean15 : Conv.JClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s160 :=
  PRE_first_tail_x6_r0_body.gjcl15 (PRE_first_tail_x6_r0_body.cjcl14 bodyClean14)

kernel_rfl bodyJsLe15 : Nat.ble PRE_first_tail_x6_r0_body.s143.next PRE_first_tail_x6_r0_body.s160.next = true
kernel_rfl bodyJsList15 : (PRE_first_tail_x6_r0_body.gjh15 ++ PRE_first_tail_x6_r0_body.cl15).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s160.next) PRE_first_tail_x6_r0_body.s162) = true
theorem bodyJs15 : JsHeapAbove PRE_first_tail_x6_r0_body.s160.next PRE_first_tail_x6_r0_body.s162 :=
  JsHeapAbove.glueSite bodyJs14 (Nat.le_of_ble_eq_true bodyJsLe15) PRE_first_tail_x6_r0_body.gjk15 PRE_first_tail_x6_r0_body.gjbd15 PRE_first_tail_x6_r0_body.cheap15 PRE_first_tail_x6_r0_body.zclbd15 bodyJsList15

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO145 : PRE_first_tail_x6_r0_body.S145.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S145.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr145 : bridgeOf PRE_first_tail_x6_r0_body.s145.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc145 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.S145) = fun _ _ => true
kernel_rfl bodyAcc147 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s147 PRE_first_tail_x6_r0_body.S147) = fun _ _ => true
kernel_rfl bodyBr148 : bridgeOf PRE_first_tail_x6_r0_body.s148.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt147 : isHalt PRE_first_tail_x6_r0_body.s147.ctl = false
kernel_rfl bodyTop148 : noRetBlock PRE_first_tail_x6_r0_body.s148 = true
kernel_rfl bodyCnt145 : countersOkB PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.s148 = true
kernel_rfl bodyO148 : PRE_first_tail_x6_r0_body.S148.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S148.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr149 : bridgeOf PRE_first_tail_x6_r0_body.s149.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt148 : countersOkB PRE_first_tail_x6_r0_body.s148 PRE_first_tail_x6_r0_body.s149 = true
kernel_rfl bodyO149 : PRE_first_tail_x6_r0_body.S149.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S149.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc149 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s149 PRE_first_tail_x6_r0_body.S149) = fun _ _ => true
kernel_rfl bodyAcc150 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s150 PRE_first_tail_x6_r0_body.S150) = fun _ _ => true
kernel_rfl bodyBr151 : bridgeOf PRE_first_tail_x6_r0_body.s151.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt150 : isHalt PRE_first_tail_x6_r0_body.s150.ctl = false
kernel_rfl bodyTop151 : noRetBlock PRE_first_tail_x6_r0_body.s151 = true
kernel_rfl bodyCnt149 : countersOkB PRE_first_tail_x6_r0_body.s149 PRE_first_tail_x6_r0_body.s151 = true
kernel_rfl bodyO151 : PRE_first_tail_x6_r0_body.S151.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S151.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr152 : bridgeOf PRE_first_tail_x6_r0_body.s152.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt151 : countersOkB PRE_first_tail_x6_r0_body.s151 PRE_first_tail_x6_r0_body.s152 = true
kernel_rfl bodyO152 : PRE_first_tail_x6_r0_body.S152.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S152.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc152 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s152 PRE_first_tail_x6_r0_body.S152) = fun _ _ => true
kernel_rfl bodyAcc153 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s153 PRE_first_tail_x6_r0_body.S153) = fun _ _ => true
kernel_rfl bodyBr154 : bridgeOf PRE_first_tail_x6_r0_body.s154.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt153 : isHalt PRE_first_tail_x6_r0_body.s153.ctl = false
kernel_rfl bodyTop154 : noRetBlock PRE_first_tail_x6_r0_body.s154 = true
kernel_rfl bodyCnt152 : countersOkB PRE_first_tail_x6_r0_body.s152 PRE_first_tail_x6_r0_body.s154 = true
kernel_rfl bodyO154 : PRE_first_tail_x6_r0_body.S154.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S154.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr155 : bridgeOf PRE_first_tail_x6_r0_body.s155.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt154 : countersOkB PRE_first_tail_x6_r0_body.s154 PRE_first_tail_x6_r0_body.s155 = true
kernel_rfl bodyO155 : PRE_first_tail_x6_r0_body.S155.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S155.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc155 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s155 PRE_first_tail_x6_r0_body.S155) = fun _ _ => true
kernel_rfl bodyAcc156 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s156 PRE_first_tail_x6_r0_body.S156) = fun _ _ => true
kernel_rfl bodyBr157 : bridgeOf PRE_first_tail_x6_r0_body.s157.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt156 : isHalt PRE_first_tail_x6_r0_body.s156.ctl = false
kernel_rfl bodyTop157 : noRetBlock PRE_first_tail_x6_r0_body.s157 = true
kernel_rfl bodyCnt155 : countersOkB PRE_first_tail_x6_r0_body.s155 PRE_first_tail_x6_r0_body.s157 = true
kernel_rfl bodyO157 : PRE_first_tail_x6_r0_body.S157.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S157.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr158 : bridgeOf PRE_first_tail_x6_r0_body.s158.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt157 : countersOkB PRE_first_tail_x6_r0_body.s157 PRE_first_tail_x6_r0_body.s158 = true
kernel_rfl bodyO158 : PRE_first_tail_x6_r0_body.S158.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S158.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc158 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s158 PRE_first_tail_x6_r0_body.S158) = fun _ _ => true
kernel_rfl bodyAcc159 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s159 PRE_first_tail_x6_r0_body.S159) = fun _ _ => true
kernel_rfl bodyBr160 : bridgeOf PRE_first_tail_x6_r0_body.s160.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt159 : isHalt PRE_first_tail_x6_r0_body.s159.ctl = false
kernel_rfl bodyTop160 : noRetBlock PRE_first_tail_x6_r0_body.s160 = true
kernel_rfl bodyCnt158 : countersOkB PRE_first_tail_x6_r0_body.s158 PRE_first_tail_x6_r0_body.s160 = true

theorem bodyGlue15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9129, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.S145)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9129, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s160 PRE_first_tail_x6_r0_body.S160) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc145 PRE_first_tail_x6_r0_body.bodyRunSeg39 bodyAcc147 bodyHalt147 PRE_first_tail_x6_r0_body.bodyStepA40 bodyTop148 (fun _ hm => bodyO145 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr145).trans bodyInactive0) (bodyBr148.trans bodyBr145.symm) bodyCnt145 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) PRE_first_tail_x6_r0_body.sizeA40 PRE_first_tail_x6_r0_body.sizeArgsA40 PRE_first_tail_x6_r0_body.sizeSymA40 PRE_first_tail_x6_r0_body.sizeMlxA40 PRE_first_tail_x6_r0_body.sizePayA40 PRE_first_tail_x6_r0_body.sizeTaA40 PRE_first_tail_x6_r0_body.sizeDecA40 PRE_first_tail_x6_r0_body.sizePreA40 PRE_first_tail_x6_r0_body.bodyPatchB40 (fun _ hm => bodyO148 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr148).trans bodyInactive0) (bodyBr149.trans bodyBr148.symm) bodyCnt148 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc149 PRE_first_tail_x6_r0_body.bodyRunSeg40 bodyAcc150 bodyHalt150 PRE_first_tail_x6_r0_body.bodyStepA41 bodyTop151 (fun _ hm => bodyO149 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr149).trans bodyInactive0) (bodyBr151.trans bodyBr149.symm) bodyCnt149 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) PRE_first_tail_x6_r0_body.sizeA41 PRE_first_tail_x6_r0_body.sizeArgsA41 PRE_first_tail_x6_r0_body.sizeSymA41 PRE_first_tail_x6_r0_body.sizeMlxA41 PRE_first_tail_x6_r0_body.sizePayA41 PRE_first_tail_x6_r0_body.sizeTaA41 PRE_first_tail_x6_r0_body.sizeDecA41 PRE_first_tail_x6_r0_body.sizePreA41 PRE_first_tail_x6_r0_body.bodyPatchB41 (fun _ hm => bodyO151 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr151).trans bodyInactive0) (bodyBr152.trans bodyBr151.symm) bodyCnt151 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc152 PRE_first_tail_x6_r0_body.bodyRunSeg41 bodyAcc153 bodyHalt153 PRE_first_tail_x6_r0_body.bodyStepA42 bodyTop154 (fun _ hm => bodyO152 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr152).trans bodyInactive0) (bodyBr154.trans bodyBr152.symm) bodyCnt152 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) PRE_first_tail_x6_r0_body.sizeA42 PRE_first_tail_x6_r0_body.sizeArgsA42 PRE_first_tail_x6_r0_body.sizeSymA42 PRE_first_tail_x6_r0_body.sizeMlxA42 PRE_first_tail_x6_r0_body.sizePayA42 PRE_first_tail_x6_r0_body.sizeTaA42 PRE_first_tail_x6_r0_body.sizeDecA42 PRE_first_tail_x6_r0_body.sizePreA42 PRE_first_tail_x6_r0_body.bodyPatchB42 (fun _ hm => bodyO154 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr154).trans bodyInactive0) (bodyBr155.trans bodyBr154.symm) bodyCnt154 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc155 PRE_first_tail_x6_r0_body.bodyRunSeg42 bodyAcc156 bodyHalt156 PRE_first_tail_x6_r0_body.bodyStepA43 bodyTop157 (fun _ hm => bodyO155 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr155).trans bodyInactive0) (bodyBr157.trans bodyBr155.symm) bodyCnt155 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) PRE_first_tail_x6_r0_body.sizeA43 PRE_first_tail_x6_r0_body.sizeArgsA43 PRE_first_tail_x6_r0_body.sizeSymA43 PRE_first_tail_x6_r0_body.sizeMlxA43 PRE_first_tail_x6_r0_body.sizePayA43 PRE_first_tail_x6_r0_body.sizeTaA43 PRE_first_tail_x6_r0_body.sizeDecA43 PRE_first_tail_x6_r0_body.sizePreA43 PRE_first_tail_x6_r0_body.bodyPatchB43 (fun _ hm => bodyO157 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr157).trans bodyInactive0) (bodyBr158.trans bodyBr157.symm) bodyCnt157 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc158 PRE_first_tail_x6_r0_body.bodyRunSeg43 bodyAcc159 bodyHalt159 PRE_first_tail_x6_r0_body.bodyStepA44 bodyTop160 (fun _ hm => bodyO158 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr158).trans bodyInactive0) (bodyBr160.trans bodyBr158.symm) bodyCnt158 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift15 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S160.tab.length PRE_first_tail_x6_r0_body.s160.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P15.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P15 743 PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.s162.ffi PRE_first_tail_x6_r0_body.s161.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_15
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_15
  have hcl : SSt (· < 743) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S160.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_15] <;> decide) PRE_first_tail_x6_r0_body.cnodesK15 PRE_first_tail_x6_r0_body.cobjsK15
      PRE_first_tail_x6_r0_body.citemsK15 PRE_first_tail_x6_r0_body.cbd15 PRE_first_tail_x6_r0_body.csst15
  exact PRE_first_tail_x6_r0_body.cshift15 bodyNcl15 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_15] at this; exact this)


kernel_rfl bodyFramesEmpty15 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s161 a).isEmpty) = true
kernel_rfl bodyJsRoots15 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s160.next) PRE_first_tail_x6_r0_body.s162.trace PRE_first_tail_x6_r0_body.s162 = true
kernel_rfl bodyJsNative15 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s162.ffi) = true
kernel_rfl bodyLow15 : (PRE_first_tail_x6_r0_body.cws15 ++ PRE_first_tail_x6_r0_body.ws15).all (Nat.ble 9) = true
kernel_rfl bodyCntM15 : countersOkB PRE_first_tail_x6_r0_body.s160 PRE_first_tail_x6_r0_body.s161 = true
kernel_rfl bodyHi15 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s162.ffi).next setupP.E = true
kernel_rfl bodyNhi15 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s162.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge15 : bridgeOf PRE_first_tail_x6_r0_body.s161.ffi = bridgeOf PRE_first_tail_x6_r0_body.s160.ffi
kernel_rfl bodyNN15 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s160.ffi).nnext PRE_first_tail_x6_r0_body.P15.NL = true
kernel_rfl bodyXn15 : Nat.ble (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s162.ffi).next = true
kernel_rfl bodyLo15 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s162.ffi).next = true
theorem bodyFacts15 : BodySiteFacts PRE_first_tail_x6_r0_body.s160 PRE_first_tail_x6_r0_body.s161 PRE_first_tail_x6_r0_body.s162 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S160 PRE_first_tail_x6_r0_body.S161 PRE_first_tail_x6_r0_body.S162
    PRE_first_tail_x6_r0_body.ws15 PRE_first_tail_x6_r0_body.cws15 PRE_first_tail_x6_r0_body.nr15 PRE_first_tail_x6_r0_body.pl15 PRE_first_tail_x6_r0_body.cl15 2688286 743 PRE_first_tail_x6_r0_body.kd15 PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.P15
    ⟨18509, 15578, 2687131, 725⟩ ⟨18512, 15605, 2687137, 743⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap15
  clean := bodyClean15
  cfix := PRE_first_tail_x6_r0_body.cfix15
  zpl := PRE_first_tail_x6_r0_body.zpl15
  zplnd := PRE_first_tail_x6_r0_body.zplnd15
  zn1 := PRE_first_tail_x6_r0_body.zn115
  zfirst := PRE_first_tail_x6_r0_body.zfirst15
  zscn := PRE_first_tail_x6_r0_body.zscn15
  zsmn := PRE_first_tail_x6_r0_body.zsmn15
  zgrow := PRE_first_tail_x6_r0_body.zgrow15
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab15
  zfresh := PRE_first_tail_x6_r0_body.zfresh15
  zcnd := PRE_first_tail_x6_r0_body.zcnd15
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi15
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt15
  zgP := PRE_first_tail_x6_r0_body.zg15_2665
  zkP := PRE_first_tail_x6_r0_body.zk15_2665
  zmP := PRE_first_tail_x6_r0_body.zm15_2665
  zgC := PRE_first_tail_x6_r0_body.zg15_2673467
  zkC := PRE_first_tail_x6_r0_body.zk15_2673467
  zmC := PRE_first_tail_x6_r0_body.zm15_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw15_2673472
  zwV := PRE_first_tail_x6_r0_body.zw15_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap15
  zclbd := PRE_first_tail_x6_r0_body.zclbd15
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap15 PRE_first_tail_x6_r0_body.stFoot15 PRE_first_tail_x6_r0_body.iso15 PRE_first_tail_x6_r0_body.zwr15
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP15
  csupp := PRE_first_tail_x6_r0_body.csupp15
  cbound := PRE_first_tail_x6_r0_body.cbound15
  zimg := PRE_first_tail_x6_r0_body.zimg15
  zctl := PRE_first_tail_x6_r0_body.zctl15
  zstack := PRE_first_tail_x6_r0_body.zstack15
  zjobs := PRE_first_tail_x6_r0_body.zjobs15
  zstores := PRE_first_tail_x6_r0_body.zstores15
  zroots := PRE_first_tail_x6_r0_body.zroots15
  znC := PRE_first_tail_x6_r0_body.znC15
  ctab := PRE_first_tail_x6_r0_body.ctab15
  zbin := PRE_first_tail_x6_r0_body.zbin15
  cbridge := PRE_first_tail_x6_r0_body.cbridge15
  sbridge := bodyBridge15
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj15
  cshiftR := fun h hNL => bodyCshift15 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN15
  raised := PRE_first_tail_x6_r0_body.raised15
  cbigs := PRE_first_tail_x6_r0_body.cbigs15
  cjcl := PRE_first_tail_x6_r0_body.cjcl15
  xnLe := Nat.le_of_ble_eq_true bodyXn15
  loLe := Nat.le_of_ble_eq_true bodyLo15
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB15
  cntM := bodyCntM15
  hiLe := Nat.le_of_ble_eq_true bodyHi15
  nhiLe := Nat.le_of_ble_eq_true bodyNhi15
  jsHeap := bodyJs15
  jsRoots := bodyJsRoots15
  jsNative := bodyJsNative15
  framesEmpty := bodyFramesEmpty15
  trailOld := by decide
  lowVars := bodyLow15

def bodyQs15 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs15 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr15.map fun r => nth? PRE_first_tail_x6_r0_body.st15.S5.tab r
kernel_rfl bodyResChk15 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs15 bodyQs15) = true
kernel_rfl bodyLq15 : bodyQs15.length = PRE_first_tail_x6_r0_body.cws15.length
kernel_rfl bodyNrLo15 : PRE_first_tail_x6_r0_body.nr15.all (Nat.ble PRE_first_tail_x6_r0_body.S160.tab.length) = true
kernel_rfl bodySub15 : (Oracles.PRE_first_tail_x6_r0_body.map_site15.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost15 : postSubB bodyM PRE_first_tail_x6_r0_body.ws15 PRE_first_tail_x6_r0_body.cws15 bodyQs15 = true
kernel_rfl bodyDrop15 : Nat.ble (9129 + (PRE_first_tail_x6_r0_body.s161.next - PRE_first_tail_x6_r0_body.s162.next)) 10278 = true
kernel_rfl bodyDropH15 : Nat.ble (123 + ((mlxOf PRE_first_tail_x6_r0_body.s161.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s162.ffi).next)) 148 = true
kernel_rfl bodyDropN15 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s161.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s162.ffi).nnext)) 0 = true
kernel_rfl bodyDv15 : bodyΘ.1.take 99 = bodyΘ.1.take 81 ++ PRE_first_tail_x6_r0_body.cws15
kernel_rfl bodyDe15 : bodyΘ.2.take 99 = bodyΘ.2.take 81 ++ PRE_first_tail_x6_r0_body.nr15.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st15.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 81) (bodyΘ.2.take 81)))
kernel_rfl bodyDl15 : (bodyΘ.1.take 81).length = (bodyΘ.2.take 81).length
kernel_rfl bodyDold15 : (bodyΘ.1.take 81).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws15).isNone && !PRE_first_tail_x6_r0_body.ws15.contains v) = true
kernel_rfl bodyDfree15 : (bodyΘ.2.take 99).all (fun e => (PRE_first_tail_x6_r0_body.cws15 ++ PRE_first_tail_x6_r0_body.ws15).all fun w => e.noVar w) = true

theorem bodyStep15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9129, 123, 0, 81⟩ bodyM PRE_first_tail_x6_r0_body.s160 PRE_first_tail_x6_r0_body.S160)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10278, 148, 0, 99⟩ bodyM PRE_first_tail_x6_r0_body.s162 PRE_first_tail_x6_r0_body.S162) (11334 + 1) :=
  bodySite bodyFacts15.cfix bodyFacts15.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x6_r0_body.st15.S5.tab) (Es := bodyEs15) (qs := bodyQs15)
    (ok := PRE_first_tail_x6_r0_body.st15.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site15 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts15
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site15 r hr) hi (MapOk.sub hm (sub_of_all bodySub15)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk15 r hr) hi hm ho hq)
    bodyLq15 rfl bodyNrLo15 (postSub_sound bodyPost15)
    (Nat.le_of_ble_eq_true bodyDrop15) (by decide) (Nat.le_of_ble_eq_true bodyDropH15) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN15) (by decide)
    bodyDv15 bodyDe15 bodyDl15 bodyDold15 bodyDfree15 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end
