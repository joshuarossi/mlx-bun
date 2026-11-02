import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.States
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B21
import host.sim.compose.a4b.x4_L8.B5
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B24
import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L8.VWBodyChain
import host.sim.compose.a4b.x4_L8.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B14
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B13
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B22

section -- VWBodyOracles_12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_g48 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g48 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g48) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site48 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site48 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site48) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st48.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g49 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g49 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g49) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site49 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site49 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site49) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st49.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g50 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g50 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g50) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site50 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site50 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site50) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st50.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g51 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g51 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g51) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site51 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site51 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site51) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st51.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site48 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site48 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site48) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st48.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site48
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st48.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st48.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1084 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1085 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1084 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws48 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st48.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st48.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso48
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_48
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st48.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot48
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup48
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound48
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace48
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged48
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws48.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st48.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1084.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_48]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen48.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh48
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl48 : Conv.NClean (⟨21204, 18278, 2795489, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1084.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl48 (PRE_first_tail_x4_L8_r0_body.cncl47 bodyNcl47)

theorem bodyClean48 : Conv.JClean (⟨21204, 18278, 2795489, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s1084 :=
  PRE_first_tail_x4_L8_r0_body.gjcl48 (PRE_first_tail_x4_L8_r0_body.cjcl47 bodyClean47)

kernel_rfl bodyJsLe48 : Nat.ble PRE_first_tail_x4_L8_r0_body.s1060.next PRE_first_tail_x4_L8_r0_body.s1084.next = true
kernel_rfl bodyJsList48 : (PRE_first_tail_x4_L8_r0_body.gjh48 ++ PRE_first_tail_x4_L8_r0_body.cl48).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1084.next) PRE_first_tail_x4_L8_r0_body.s1086) = true
theorem bodyJs48 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s1084.next PRE_first_tail_x4_L8_r0_body.s1086 :=
  JsHeapAbove.glueSite bodyJs47 (Nat.le_of_ble_eq_true bodyJsLe48) PRE_first_tail_x4_L8_r0_body.gjk48 PRE_first_tail_x4_L8_r0_body.gjbd48 PRE_first_tail_x4_L8_r0_body.cheap48 PRE_first_tail_x4_L8_r0_body.zclbd48 bodyJsList48

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1062 : PRE_first_tail_x4_L8_r0_body.S1062.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1062.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1062 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1062.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc1062 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1062 PRE_first_tail_x4_L8_r0_body.S1062) = fun _ _ => true
kernel_rfl bodyAcc1065 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1065 PRE_first_tail_x4_L8_r0_body.S1065) = fun _ _ => true
kernel_rfl bodyBr1066 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1066.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1065 : isHalt PRE_first_tail_x4_L8_r0_body.s1065.ctl = false
kernel_rfl bodyTop1066 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1066 = true
kernel_rfl bodyCnt1062 : countersOkB PRE_first_tail_x4_L8_r0_body.s1062 PRE_first_tail_x4_L8_r0_body.s1066 = true
kernel_rfl bodyO1066 : PRE_first_tail_x4_L8_r0_body.S1066.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1066.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1067 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1067.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1066 : countersOkB PRE_first_tail_x4_L8_r0_body.s1066 PRE_first_tail_x4_L8_r0_body.s1067 = true
kernel_rfl bodyO1067 : PRE_first_tail_x4_L8_r0_body.S1067.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1067.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1067 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1067 PRE_first_tail_x4_L8_r0_body.S1067) = fun _ _ => true
kernel_rfl bodyAcc1071 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1071 PRE_first_tail_x4_L8_r0_body.S1071) = fun _ _ => true
kernel_rfl bodyBr1072 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1072.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1071 : isHalt PRE_first_tail_x4_L8_r0_body.s1071.ctl = false
kernel_rfl bodyTop1072 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1072 = true
kernel_rfl bodyCnt1067 : countersOkB PRE_first_tail_x4_L8_r0_body.s1067 PRE_first_tail_x4_L8_r0_body.s1072 = true
kernel_rfl bodyO1072 : PRE_first_tail_x4_L8_r0_body.S1072.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1072.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1073 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1073.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1072 : countersOkB PRE_first_tail_x4_L8_r0_body.s1072 PRE_first_tail_x4_L8_r0_body.s1073 = true
kernel_rfl bodyO1073 : PRE_first_tail_x4_L8_r0_body.S1073.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1073.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1073 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1073 PRE_first_tail_x4_L8_r0_body.S1073) = fun _ _ => true
kernel_rfl bodyAcc1074 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1074 PRE_first_tail_x4_L8_r0_body.S1074) = fun _ _ => true
kernel_rfl bodyBr1075 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1075.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1074 : isHalt PRE_first_tail_x4_L8_r0_body.s1074.ctl = false
kernel_rfl bodyTop1075 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1075 = true
kernel_rfl bodyCnt1073 : countersOkB PRE_first_tail_x4_L8_r0_body.s1073 PRE_first_tail_x4_L8_r0_body.s1075 = true
kernel_rfl bodyO1075 : PRE_first_tail_x4_L8_r0_body.S1075.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1075.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1076 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1076.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1075 : countersOkB PRE_first_tail_x4_L8_r0_body.s1075 PRE_first_tail_x4_L8_r0_body.s1076 = true
kernel_rfl bodyO1076 : PRE_first_tail_x4_L8_r0_body.S1076.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1076.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1076 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1076 PRE_first_tail_x4_L8_r0_body.S1076) = fun _ _ => true
kernel_rfl bodyAcc1077 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1077 PRE_first_tail_x4_L8_r0_body.S1077) = fun _ _ => true
kernel_rfl bodyBr1078 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1078.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1077 : isHalt PRE_first_tail_x4_L8_r0_body.s1077.ctl = false
kernel_rfl bodyTop1078 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1078 = true
kernel_rfl bodyCnt1076 : countersOkB PRE_first_tail_x4_L8_r0_body.s1076 PRE_first_tail_x4_L8_r0_body.s1078 = true
kernel_rfl bodyO1078 : PRE_first_tail_x4_L8_r0_body.S1078.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1078.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1079 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1079.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1078 : countersOkB PRE_first_tail_x4_L8_r0_body.s1078 PRE_first_tail_x4_L8_r0_body.s1079 = true
kernel_rfl bodyO1079 : PRE_first_tail_x4_L8_r0_body.S1079.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1079.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1079 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1079 PRE_first_tail_x4_L8_r0_body.S1079) = fun _ _ => true
kernel_rfl bodyAcc1080 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1080 PRE_first_tail_x4_L8_r0_body.S1080) = fun _ _ => true
kernel_rfl bodyBr1081 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1081.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1080 : isHalt PRE_first_tail_x4_L8_r0_body.s1080.ctl = false
kernel_rfl bodyTop1081 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1081 = true
kernel_rfl bodyCnt1079 : countersOkB PRE_first_tail_x4_L8_r0_body.s1079 PRE_first_tail_x4_L8_r0_body.s1081 = true
kernel_rfl bodyO1081 : PRE_first_tail_x4_L8_r0_body.S1081.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1081.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1082 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1082.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1081 : countersOkB PRE_first_tail_x4_L8_r0_body.s1081 PRE_first_tail_x4_L8_r0_body.s1082 = true
kernel_rfl bodyO1082 : PRE_first_tail_x4_L8_r0_body.S1082.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1082.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1082 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1082 PRE_first_tail_x4_L8_r0_body.S1082) = fun _ _ => true
kernel_rfl bodyAcc1083 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1083 PRE_first_tail_x4_L8_r0_body.S1083) = fun _ _ => true
kernel_rfl bodyBr1084 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1084.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1083 : isHalt PRE_first_tail_x4_L8_r0_body.s1083.ctl = false
kernel_rfl bodyTop1084 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1084 = true
kernel_rfl bodyCnt1082 : countersOkB PRE_first_tail_x4_L8_r0_body.s1082 PRE_first_tail_x4_L8_r0_body.s1084 = true

theorem bodyGlue48 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨49678, 945, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1062 PRE_first_tail_x4_L8_r0_body.S1062)
      (bodyCut NB T tk π i x0 bodyΘ ⟨49678, 945, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1084 PRE_first_tail_x4_L8_r0_body.S1084) 30573 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) bodyAcc1062 PRE_first_tail_x4_L8_r0_body.bodyRunSeg275 bodyAcc1065 bodyHalt1065 PRE_first_tail_x4_L8_r0_body.bodyStepA276 bodyTop1066 (fun _ hm => bodyO1062 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1062).trans bodyInactive0) (bodyBr1066.trans bodyBr1062.symm) bodyCnt1062 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA276 PRE_first_tail_x4_L8_r0_body.sizeArgsA276 PRE_first_tail_x4_L8_r0_body.sizeSymA276 PRE_first_tail_x4_L8_r0_body.sizeMlxA276 PRE_first_tail_x4_L8_r0_body.sizePayA276 PRE_first_tail_x4_L8_r0_body.sizeTaA276 PRE_first_tail_x4_L8_r0_body.sizeDecA276 PRE_first_tail_x4_L8_r0_body.sizePreA276 PRE_first_tail_x4_L8_r0_body.bodyPatchB276 (fun _ hm => bodyO1066 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1066).trans bodyInactive0) (bodyBr1067.trans bodyBr1066.symm) bodyCnt1066 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) bodyAcc1067 PRE_first_tail_x4_L8_r0_body.bodyRunSeg276 bodyAcc1071 bodyHalt1071 PRE_first_tail_x4_L8_r0_body.bodyStepA277 bodyTop1072 (fun _ hm => bodyO1067 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1067).trans bodyInactive0) (bodyBr1072.trans bodyBr1067.symm) bodyCnt1067 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA277 PRE_first_tail_x4_L8_r0_body.sizeArgsA277 PRE_first_tail_x4_L8_r0_body.sizeSymA277 PRE_first_tail_x4_L8_r0_body.sizeMlxA277 PRE_first_tail_x4_L8_r0_body.sizePayA277 PRE_first_tail_x4_L8_r0_body.sizeTaA277 PRE_first_tail_x4_L8_r0_body.sizeDecA277 PRE_first_tail_x4_L8_r0_body.sizePreA277 PRE_first_tail_x4_L8_r0_body.bodyPatchB277 (fun _ hm => bodyO1072 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1072).trans bodyInactive0) (bodyBr1073.trans bodyBr1072.symm) bodyCnt1072 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) bodyAcc1073 PRE_first_tail_x4_L8_r0_body.bodyRunSeg277 bodyAcc1074 bodyHalt1074 PRE_first_tail_x4_L8_r0_body.bodyStepA278 bodyTop1075 (fun _ hm => bodyO1073 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1073).trans bodyInactive0) (bodyBr1075.trans bodyBr1073.symm) bodyCnt1073 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA278 PRE_first_tail_x4_L8_r0_body.sizeArgsA278 PRE_first_tail_x4_L8_r0_body.sizeSymA278 PRE_first_tail_x4_L8_r0_body.sizeMlxA278 PRE_first_tail_x4_L8_r0_body.sizePayA278 PRE_first_tail_x4_L8_r0_body.sizeTaA278 PRE_first_tail_x4_L8_r0_body.sizeDecA278 PRE_first_tail_x4_L8_r0_body.sizePreA278 PRE_first_tail_x4_L8_r0_body.bodyPatchB278 (fun _ hm => bodyO1075 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1075).trans bodyInactive0) (bodyBr1076.trans bodyBr1075.symm) bodyCnt1075 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) bodyAcc1076 PRE_first_tail_x4_L8_r0_body.bodyRunSeg278 bodyAcc1077 bodyHalt1077 PRE_first_tail_x4_L8_r0_body.bodyStepA279 bodyTop1078 (fun _ hm => bodyO1076 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1076).trans bodyInactive0) (bodyBr1078.trans bodyBr1076.symm) bodyCnt1076 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA279 PRE_first_tail_x4_L8_r0_body.sizeArgsA279 PRE_first_tail_x4_L8_r0_body.sizeSymA279 PRE_first_tail_x4_L8_r0_body.sizeMlxA279 PRE_first_tail_x4_L8_r0_body.sizePayA279 PRE_first_tail_x4_L8_r0_body.sizeTaA279 PRE_first_tail_x4_L8_r0_body.sizeDecA279 PRE_first_tail_x4_L8_r0_body.sizePreA279 PRE_first_tail_x4_L8_r0_body.bodyPatchB279 (fun _ hm => bodyO1078 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1078).trans bodyInactive0) (bodyBr1079.trans bodyBr1078.symm) bodyCnt1078 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) bodyAcc1079 PRE_first_tail_x4_L8_r0_body.bodyRunSeg279 bodyAcc1080 bodyHalt1080 PRE_first_tail_x4_L8_r0_body.bodyStepA280 bodyTop1081 (fun _ hm => bodyO1079 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1079).trans bodyInactive0) (bodyBr1081.trans bodyBr1079.symm) bodyCnt1079 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA280 PRE_first_tail_x4_L8_r0_body.sizeArgsA280 PRE_first_tail_x4_L8_r0_body.sizeSymA280 PRE_first_tail_x4_L8_r0_body.sizeMlxA280 PRE_first_tail_x4_L8_r0_body.sizePayA280 PRE_first_tail_x4_L8_r0_body.sizeTaA280 PRE_first_tail_x4_L8_r0_body.sizeDecA280 PRE_first_tail_x4_L8_r0_body.sizePreA280 PRE_first_tail_x4_L8_r0_body.bodyPatchB280 (fun _ hm => bodyO1081 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1081).trans bodyInactive0) (bodyBr1082.trans bodyBr1081.symm) bodyCnt1081 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49678, 945, 0, 0⟩) bodyAcc1082 PRE_first_tail_x4_L8_r0_body.bodyRunSeg280 bodyAcc1083 bodyHalt1083 PRE_first_tail_x4_L8_r0_body.bodyStepA281 bodyTop1084 (fun _ hm => bodyO1082 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1082).trans bodyInactive0) (bodyBr1084.trans bodyBr1082.symm) bodyCnt1082 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift48 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S1084.tab.length PRE_first_tail_x4_L8_r0_body.s1084.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P48.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P48 15 PRE_first_tail_x4_L8_r0_body.kappa48 PRE_first_tail_x4_L8_r0_body.s1086.ffi PRE_first_tail_x4_L8_r0_body.s1085.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_48
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_48
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1086.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S1084.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_48] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK48 PRE_first_tail_x4_L8_r0_body.cobjsK48
      PRE_first_tail_x4_L8_r0_body.citemsK48 PRE_first_tail_x4_L8_r0_body.cbd48 PRE_first_tail_x4_L8_r0_body.csst48
  exact PRE_first_tail_x4_L8_r0_body.cshift48 bodyNcl48 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_48] at this; exact this)


kernel_rfl bodyFramesEmpty48 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s1085 a).isEmpty) = true
kernel_rfl bodyJsRoots48 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1084.next) PRE_first_tail_x4_L8_r0_body.s1086.trace PRE_first_tail_x4_L8_r0_body.s1086 = true
kernel_rfl bodyJsNative48 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s1086.ffi) = true
kernel_rfl bodyLow48 : (PRE_first_tail_x4_L8_r0_body.cws48 ++ PRE_first_tail_x4_L8_r0_body.ws48).all (Nat.ble 9) = true
kernel_rfl bodyCntM48 : countersOkB PRE_first_tail_x4_L8_r0_body.s1084 PRE_first_tail_x4_L8_r0_body.s1085 = true
kernel_rfl bodyHi48 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1086.ffi).next setupP.E = true
kernel_rfl bodyNhi48 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1086.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge48 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1085.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s1084.ffi
kernel_rfl bodyNN48 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1084.ffi).nnext PRE_first_tail_x4_L8_r0_body.P48.NL = true
kernel_rfl bodyXn48 : Nat.ble (⟨21207, 18305, 2795495, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s1086.ffi).next = true
kernel_rfl bodyLo48 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s1086.ffi).next = true
theorem bodyFacts48 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s1084 PRE_first_tail_x4_L8_r0_body.s1085 PRE_first_tail_x4_L8_r0_body.s1086 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S1084 PRE_first_tail_x4_L8_r0_body.S1085 PRE_first_tail_x4_L8_r0_body.S1086
    PRE_first_tail_x4_L8_r0_body.ws48 PRE_first_tail_x4_L8_r0_body.cws48 PRE_first_tail_x4_L8_r0_body.nr48 PRE_first_tail_x4_L8_r0_body.pl48 PRE_first_tail_x4_L8_r0_body.cl48 2796644 15 PRE_first_tail_x4_L8_r0_body.kd48 PRE_first_tail_x4_L8_r0_body.kappa48 PRE_first_tail_x4_L8_r0_body.P48
    ⟨21204, 18278, 2795489, 15⟩ ⟨21207, 18305, 2795495, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap48
  clean := bodyClean48
  cfix := PRE_first_tail_x4_L8_r0_body.cfix48
  zpl := PRE_first_tail_x4_L8_r0_body.zpl48
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd48
  zn1 := PRE_first_tail_x4_L8_r0_body.zn148
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst48
  zscn := PRE_first_tail_x4_L8_r0_body.zscn48
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn48
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow48
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab48
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh48
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd48
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi48
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt48
  zgP := PRE_first_tail_x4_L8_r0_body.zg48_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk48_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm48_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg48_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk48_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm48_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw48_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw48_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap48
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd48
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap48 PRE_first_tail_x4_L8_r0_body.stFoot48 PRE_first_tail_x4_L8_r0_body.iso48 PRE_first_tail_x4_L8_r0_body.zwr48
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP48
  csupp := PRE_first_tail_x4_L8_r0_body.csupp48
  cbound := PRE_first_tail_x4_L8_r0_body.cbound48
  zimg := PRE_first_tail_x4_L8_r0_body.zimg48
  zctl := PRE_first_tail_x4_L8_r0_body.zctl48
  zstack := PRE_first_tail_x4_L8_r0_body.zstack48
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs48
  zstores := PRE_first_tail_x4_L8_r0_body.zstores48
  zroots := PRE_first_tail_x4_L8_r0_body.zroots48
  znC := PRE_first_tail_x4_L8_r0_body.znC48
  ctab := PRE_first_tail_x4_L8_r0_body.ctab48
  zbin := PRE_first_tail_x4_L8_r0_body.zbin48
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge48
  sbridge := bodyBridge48
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj48
  cshiftR := fun h hNL => bodyCshift48 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN48
  raised := PRE_first_tail_x4_L8_r0_body.raised48
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs48
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl48
  xnLe := Nat.le_of_ble_eq_true bodyXn48
  loLe := Nat.le_of_ble_eq_true bodyLo48
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB48
  cntM := bodyCntM48
  hiLe := Nat.le_of_ble_eq_true bodyHi48
  nhiLe := Nat.le_of_ble_eq_true bodyNhi48
  jsHeap := bodyJs48
  jsRoots := bodyJsRoots48
  jsNative := bodyJsNative48
  framesEmpty := bodyFramesEmpty48
  trailOld := by decide
  lowVars := bodyLow48

def bodyQs48 : List (Option Q) := []
noncomputable def bodyEs48 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr48.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st48.S5.tab r
kernel_rfl bodyResChk48 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs48 bodyQs48) = true
kernel_rfl bodyLq48 : bodyQs48.length = PRE_first_tail_x4_L8_r0_body.cws48.length
kernel_rfl bodyNrLo48 : PRE_first_tail_x4_L8_r0_body.nr48.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S1084.tab.length) = true
kernel_rfl bodySub48 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site48.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost48 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws48 PRE_first_tail_x4_L8_r0_body.cws48 bodyQs48 = true
kernel_rfl bodyDrop48 : Nat.ble (49678 + (PRE_first_tail_x4_L8_r0_body.s1085.next - PRE_first_tail_x4_L8_r0_body.s1086.next)) 50827 = true
kernel_rfl bodyDropH48 : Nat.ble (945 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1085.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s1086.ffi).next)) 970 = true
kernel_rfl bodyDropN48 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1085.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s1086.ffi).nnext)) 0 = true
kernel_rfl bodyDv48 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws48
kernel_rfl bodyDe48 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr48.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st48.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl48 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold48 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws48).isNone && !PRE_first_tail_x4_L8_r0_body.ws48.contains v) = true
kernel_rfl bodyDfree48 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws48 ++ PRE_first_tail_x4_L8_r0_body.ws48).all fun w => e.noVar w) = true

theorem bodyStep48 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨49678, 945, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1084 PRE_first_tail_x4_L8_r0_body.S1084)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50827, 970, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1086 PRE_first_tail_x4_L8_r0_body.S1086) (11334 + 1) :=
  bodySite bodyFacts48.cfix bodyFacts48.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st48.S5.tab) (Es := bodyEs48) (qs := bodyQs48)
    (ok := PRE_first_tail_x4_L8_r0_body.st48.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site48 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts48
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site48 r hr) hi (MapOk.sub hm (sub_of_all bodySub48)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk48 r hr) hi hm ho hq)
    bodyLq48 rfl bodyNrLo48 (postSub_sound bodyPost48)
    (Nat.le_of_ble_eq_true bodyDrop48) (by decide) (Nat.le_of_ble_eq_true bodyDropH48) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN48) (by decide)
    bodyDv48 bodyDe48 bodyDl48 bodyDold48 bodyDfree48 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site49 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site49 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site49) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st49.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site49
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st49.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st49.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1106 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1107 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1106 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws49 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st49.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st49.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso49
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_49
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st49.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot49
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup49
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound49
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace49
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged49
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws49.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st49.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1106.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_49]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen49.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh49
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl49 : Conv.NClean (⟨21261, 18341, 2797731, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1106.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl49 (PRE_first_tail_x4_L8_r0_body.cncl48 bodyNcl48)

theorem bodyClean49 : Conv.JClean (⟨21261, 18341, 2797731, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s1106 :=
  PRE_first_tail_x4_L8_r0_body.gjcl49 (PRE_first_tail_x4_L8_r0_body.cjcl48 bodyClean48)

kernel_rfl bodyJsLe49 : Nat.ble PRE_first_tail_x4_L8_r0_body.s1084.next PRE_first_tail_x4_L8_r0_body.s1106.next = true
kernel_rfl bodyJsList49 : (PRE_first_tail_x4_L8_r0_body.gjh49 ++ PRE_first_tail_x4_L8_r0_body.cl49).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1106.next) PRE_first_tail_x4_L8_r0_body.s1108) = true
theorem bodyJs49 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s1106.next PRE_first_tail_x4_L8_r0_body.s1108 :=
  JsHeapAbove.glueSite bodyJs48 (Nat.le_of_ble_eq_true bodyJsLe49) PRE_first_tail_x4_L8_r0_body.gjk49 PRE_first_tail_x4_L8_r0_body.gjbd49 PRE_first_tail_x4_L8_r0_body.cheap49 PRE_first_tail_x4_L8_r0_body.zclbd49 bodyJsList49

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1086 : PRE_first_tail_x4_L8_r0_body.S1086.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1086.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1086 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1086.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc1086 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1086 PRE_first_tail_x4_L8_r0_body.S1086) = fun _ _ => true
kernel_rfl bodyAcc1087 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1087 PRE_first_tail_x4_L8_r0_body.S1087) = fun _ _ => true
kernel_rfl bodyBr1088 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1088.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1087 : isHalt PRE_first_tail_x4_L8_r0_body.s1087.ctl = false
kernel_rfl bodyTop1088 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1088 = true
kernel_rfl bodyCnt1086 : countersOkB PRE_first_tail_x4_L8_r0_body.s1086 PRE_first_tail_x4_L8_r0_body.s1088 = true
kernel_rfl bodyO1088 : PRE_first_tail_x4_L8_r0_body.S1088.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1088.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1089 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1089.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1088 : countersOkB PRE_first_tail_x4_L8_r0_body.s1088 PRE_first_tail_x4_L8_r0_body.s1089 = true
kernel_rfl bodyO1089 : PRE_first_tail_x4_L8_r0_body.S1089.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1089.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1089 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1089 PRE_first_tail_x4_L8_r0_body.S1089) = fun _ _ => true
kernel_rfl bodyAcc1093 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1093 PRE_first_tail_x4_L8_r0_body.S1093) = fun _ _ => true
kernel_rfl bodyBr1094 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1094.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1093 : isHalt PRE_first_tail_x4_L8_r0_body.s1093.ctl = false
kernel_rfl bodyTop1094 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1094 = true
kernel_rfl bodyCnt1089 : countersOkB PRE_first_tail_x4_L8_r0_body.s1089 PRE_first_tail_x4_L8_r0_body.s1094 = true
kernel_rfl bodyO1094 : PRE_first_tail_x4_L8_r0_body.S1094.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1094.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1095 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1095.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1094 : countersOkB PRE_first_tail_x4_L8_r0_body.s1094 PRE_first_tail_x4_L8_r0_body.s1095 = true
kernel_rfl bodyO1095 : PRE_first_tail_x4_L8_r0_body.S1095.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1095.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1095 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1095 PRE_first_tail_x4_L8_r0_body.S1095) = fun _ _ => true
kernel_rfl bodyAcc1096 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1096 PRE_first_tail_x4_L8_r0_body.S1096) = fun _ _ => true
kernel_rfl bodyBr1097 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1097.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1096 : isHalt PRE_first_tail_x4_L8_r0_body.s1096.ctl = false
kernel_rfl bodyTop1097 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1097 = true
kernel_rfl bodyCnt1095 : countersOkB PRE_first_tail_x4_L8_r0_body.s1095 PRE_first_tail_x4_L8_r0_body.s1097 = true
kernel_rfl bodyO1097 : PRE_first_tail_x4_L8_r0_body.S1097.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1097.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1098 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1098.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1097 : countersOkB PRE_first_tail_x4_L8_r0_body.s1097 PRE_first_tail_x4_L8_r0_body.s1098 = true
kernel_rfl bodyO1098 : PRE_first_tail_x4_L8_r0_body.S1098.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1098.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1098 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1098 PRE_first_tail_x4_L8_r0_body.S1098) = fun _ _ => true
kernel_rfl bodyAcc1099 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1099 PRE_first_tail_x4_L8_r0_body.S1099) = fun _ _ => true
kernel_rfl bodyBr1100 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1100.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1099 : isHalt PRE_first_tail_x4_L8_r0_body.s1099.ctl = false
kernel_rfl bodyTop1100 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1100 = true
kernel_rfl bodyCnt1098 : countersOkB PRE_first_tail_x4_L8_r0_body.s1098 PRE_first_tail_x4_L8_r0_body.s1100 = true
kernel_rfl bodyO1100 : PRE_first_tail_x4_L8_r0_body.S1100.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1100.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1101 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1101.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1100 : countersOkB PRE_first_tail_x4_L8_r0_body.s1100 PRE_first_tail_x4_L8_r0_body.s1101 = true
kernel_rfl bodyO1101 : PRE_first_tail_x4_L8_r0_body.S1101.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1101.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1101 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1101 PRE_first_tail_x4_L8_r0_body.S1101) = fun _ _ => true
kernel_rfl bodyAcc1102 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1102 PRE_first_tail_x4_L8_r0_body.S1102) = fun _ _ => true
kernel_rfl bodyBr1103 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1103.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1102 : isHalt PRE_first_tail_x4_L8_r0_body.s1102.ctl = false
kernel_rfl bodyTop1103 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1103 = true
kernel_rfl bodyCnt1101 : countersOkB PRE_first_tail_x4_L8_r0_body.s1101 PRE_first_tail_x4_L8_r0_body.s1103 = true
kernel_rfl bodyO1103 : PRE_first_tail_x4_L8_r0_body.S1103.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1103.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1104 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1104.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1103 : countersOkB PRE_first_tail_x4_L8_r0_body.s1103 PRE_first_tail_x4_L8_r0_body.s1104 = true
kernel_rfl bodyO1104 : PRE_first_tail_x4_L8_r0_body.S1104.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1104.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1104 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1104 PRE_first_tail_x4_L8_r0_body.S1104) = fun _ _ => true
kernel_rfl bodyAcc1105 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1105 PRE_first_tail_x4_L8_r0_body.S1105) = fun _ _ => true
kernel_rfl bodyBr1106 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1106.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1105 : isHalt PRE_first_tail_x4_L8_r0_body.s1105.ctl = false
kernel_rfl bodyTop1106 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1106 = true
kernel_rfl bodyCnt1104 : countersOkB PRE_first_tail_x4_L8_r0_body.s1104 PRE_first_tail_x4_L8_r0_body.s1106 = true

theorem bodyGlue49 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50827, 970, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1086 PRE_first_tail_x4_L8_r0_body.S1086)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50827, 970, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1106 PRE_first_tail_x4_L8_r0_body.S1106) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) bodyAcc1086 PRE_first_tail_x4_L8_r0_body.bodyRunSeg281 bodyAcc1087 bodyHalt1087 PRE_first_tail_x4_L8_r0_body.bodyStepA282 bodyTop1088 (fun _ hm => bodyO1086 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1086).trans bodyInactive0) (bodyBr1088.trans bodyBr1086.symm) bodyCnt1086 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA282 PRE_first_tail_x4_L8_r0_body.sizeArgsA282 PRE_first_tail_x4_L8_r0_body.sizeSymA282 PRE_first_tail_x4_L8_r0_body.sizeMlxA282 PRE_first_tail_x4_L8_r0_body.sizePayA282 PRE_first_tail_x4_L8_r0_body.sizeTaA282 PRE_first_tail_x4_L8_r0_body.sizeDecA282 PRE_first_tail_x4_L8_r0_body.sizePreA282 PRE_first_tail_x4_L8_r0_body.bodyPatchB282 (fun _ hm => bodyO1088 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1088).trans bodyInactive0) (bodyBr1089.trans bodyBr1088.symm) bodyCnt1088 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) bodyAcc1089 PRE_first_tail_x4_L8_r0_body.bodyRunSeg282 bodyAcc1093 bodyHalt1093 PRE_first_tail_x4_L8_r0_body.bodyStepA283 bodyTop1094 (fun _ hm => bodyO1089 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1089).trans bodyInactive0) (bodyBr1094.trans bodyBr1089.symm) bodyCnt1089 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA283 PRE_first_tail_x4_L8_r0_body.sizeArgsA283 PRE_first_tail_x4_L8_r0_body.sizeSymA283 PRE_first_tail_x4_L8_r0_body.sizeMlxA283 PRE_first_tail_x4_L8_r0_body.sizePayA283 PRE_first_tail_x4_L8_r0_body.sizeTaA283 PRE_first_tail_x4_L8_r0_body.sizeDecA283 PRE_first_tail_x4_L8_r0_body.sizePreA283 PRE_first_tail_x4_L8_r0_body.bodyPatchB283 (fun _ hm => bodyO1094 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1094).trans bodyInactive0) (bodyBr1095.trans bodyBr1094.symm) bodyCnt1094 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) bodyAcc1095 PRE_first_tail_x4_L8_r0_body.bodyRunSeg283 bodyAcc1096 bodyHalt1096 PRE_first_tail_x4_L8_r0_body.bodyStepA284 bodyTop1097 (fun _ hm => bodyO1095 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1095).trans bodyInactive0) (bodyBr1097.trans bodyBr1095.symm) bodyCnt1095 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA284 PRE_first_tail_x4_L8_r0_body.sizeArgsA284 PRE_first_tail_x4_L8_r0_body.sizeSymA284 PRE_first_tail_x4_L8_r0_body.sizeMlxA284 PRE_first_tail_x4_L8_r0_body.sizePayA284 PRE_first_tail_x4_L8_r0_body.sizeTaA284 PRE_first_tail_x4_L8_r0_body.sizeDecA284 PRE_first_tail_x4_L8_r0_body.sizePreA284 PRE_first_tail_x4_L8_r0_body.bodyPatchB284 (fun _ hm => bodyO1097 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1097).trans bodyInactive0) (bodyBr1098.trans bodyBr1097.symm) bodyCnt1097 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) bodyAcc1098 PRE_first_tail_x4_L8_r0_body.bodyRunSeg284 bodyAcc1099 bodyHalt1099 PRE_first_tail_x4_L8_r0_body.bodyStepA285 bodyTop1100 (fun _ hm => bodyO1098 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1098).trans bodyInactive0) (bodyBr1100.trans bodyBr1098.symm) bodyCnt1098 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA285 PRE_first_tail_x4_L8_r0_body.sizeArgsA285 PRE_first_tail_x4_L8_r0_body.sizeSymA285 PRE_first_tail_x4_L8_r0_body.sizeMlxA285 PRE_first_tail_x4_L8_r0_body.sizePayA285 PRE_first_tail_x4_L8_r0_body.sizeTaA285 PRE_first_tail_x4_L8_r0_body.sizeDecA285 PRE_first_tail_x4_L8_r0_body.sizePreA285 PRE_first_tail_x4_L8_r0_body.bodyPatchB285 (fun _ hm => bodyO1100 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1100).trans bodyInactive0) (bodyBr1101.trans bodyBr1100.symm) bodyCnt1100 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) bodyAcc1101 PRE_first_tail_x4_L8_r0_body.bodyRunSeg285 bodyAcc1102 bodyHalt1102 PRE_first_tail_x4_L8_r0_body.bodyStepA286 bodyTop1103 (fun _ hm => bodyO1101 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1101).trans bodyInactive0) (bodyBr1103.trans bodyBr1101.symm) bodyCnt1101 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA286 PRE_first_tail_x4_L8_r0_body.sizeArgsA286 PRE_first_tail_x4_L8_r0_body.sizeSymA286 PRE_first_tail_x4_L8_r0_body.sizeMlxA286 PRE_first_tail_x4_L8_r0_body.sizePayA286 PRE_first_tail_x4_L8_r0_body.sizeTaA286 PRE_first_tail_x4_L8_r0_body.sizeDecA286 PRE_first_tail_x4_L8_r0_body.sizePreA286 PRE_first_tail_x4_L8_r0_body.bodyPatchB286 (fun _ hm => bodyO1103 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1103).trans bodyInactive0) (bodyBr1104.trans bodyBr1103.symm) bodyCnt1103 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50827, 970, 0, 0⟩) bodyAcc1104 PRE_first_tail_x4_L8_r0_body.bodyRunSeg286 bodyAcc1105 bodyHalt1105 PRE_first_tail_x4_L8_r0_body.bodyStepA287 bodyTop1106 (fun _ hm => bodyO1104 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1104).trans bodyInactive0) (bodyBr1106.trans bodyBr1104.symm) bodyCnt1104 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift49 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S1106.tab.length PRE_first_tail_x4_L8_r0_body.s1106.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P49.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P49 15 PRE_first_tail_x4_L8_r0_body.kappa49 PRE_first_tail_x4_L8_r0_body.s1108.ffi PRE_first_tail_x4_L8_r0_body.s1107.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_49
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_49
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1108.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S1106.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_49] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK49 PRE_first_tail_x4_L8_r0_body.cobjsK49
      PRE_first_tail_x4_L8_r0_body.citemsK49 PRE_first_tail_x4_L8_r0_body.cbd49 PRE_first_tail_x4_L8_r0_body.csst49
  exact PRE_first_tail_x4_L8_r0_body.cshift49 bodyNcl49 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_49] at this; exact this)


kernel_rfl bodyFramesEmpty49 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s1107 a).isEmpty) = true
kernel_rfl bodyJsRoots49 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1106.next) PRE_first_tail_x4_L8_r0_body.s1108.trace PRE_first_tail_x4_L8_r0_body.s1108 = true
kernel_rfl bodyJsNative49 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s1108.ffi) = true
kernel_rfl bodyLow49 : (PRE_first_tail_x4_L8_r0_body.cws49 ++ PRE_first_tail_x4_L8_r0_body.ws49).all (Nat.ble 9) = true
kernel_rfl bodyCntM49 : countersOkB PRE_first_tail_x4_L8_r0_body.s1106 PRE_first_tail_x4_L8_r0_body.s1107 = true
kernel_rfl bodyHi49 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1108.ffi).next setupP.E = true
kernel_rfl bodyNhi49 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1108.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge49 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1107.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s1106.ffi
kernel_rfl bodyNN49 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1106.ffi).nnext PRE_first_tail_x4_L8_r0_body.P49.NL = true
kernel_rfl bodyXn49 : Nat.ble (⟨21264, 18368, 2797737, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s1108.ffi).next = true
kernel_rfl bodyLo49 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s1108.ffi).next = true
theorem bodyFacts49 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s1106 PRE_first_tail_x4_L8_r0_body.s1107 PRE_first_tail_x4_L8_r0_body.s1108 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S1106 PRE_first_tail_x4_L8_r0_body.S1107 PRE_first_tail_x4_L8_r0_body.S1108
    PRE_first_tail_x4_L8_r0_body.ws49 PRE_first_tail_x4_L8_r0_body.cws49 PRE_first_tail_x4_L8_r0_body.nr49 PRE_first_tail_x4_L8_r0_body.pl49 PRE_first_tail_x4_L8_r0_body.cl49 2798886 15 PRE_first_tail_x4_L8_r0_body.kd49 PRE_first_tail_x4_L8_r0_body.kappa49 PRE_first_tail_x4_L8_r0_body.P49
    ⟨21261, 18341, 2797731, 15⟩ ⟨21264, 18368, 2797737, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap49
  clean := bodyClean49
  cfix := PRE_first_tail_x4_L8_r0_body.cfix49
  zpl := PRE_first_tail_x4_L8_r0_body.zpl49
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd49
  zn1 := PRE_first_tail_x4_L8_r0_body.zn149
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst49
  zscn := PRE_first_tail_x4_L8_r0_body.zscn49
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn49
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow49
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab49
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh49
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd49
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi49
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt49
  zgP := PRE_first_tail_x4_L8_r0_body.zg49_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk49_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm49_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg49_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk49_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm49_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw49_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw49_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap49
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd49
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap49 PRE_first_tail_x4_L8_r0_body.stFoot49 PRE_first_tail_x4_L8_r0_body.iso49 PRE_first_tail_x4_L8_r0_body.zwr49
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP49
  csupp := PRE_first_tail_x4_L8_r0_body.csupp49
  cbound := PRE_first_tail_x4_L8_r0_body.cbound49
  zimg := PRE_first_tail_x4_L8_r0_body.zimg49
  zctl := PRE_first_tail_x4_L8_r0_body.zctl49
  zstack := PRE_first_tail_x4_L8_r0_body.zstack49
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs49
  zstores := PRE_first_tail_x4_L8_r0_body.zstores49
  zroots := PRE_first_tail_x4_L8_r0_body.zroots49
  znC := PRE_first_tail_x4_L8_r0_body.znC49
  ctab := PRE_first_tail_x4_L8_r0_body.ctab49
  zbin := PRE_first_tail_x4_L8_r0_body.zbin49
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge49
  sbridge := bodyBridge49
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj49
  cshiftR := fun h hNL => bodyCshift49 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN49
  raised := PRE_first_tail_x4_L8_r0_body.raised49
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs49
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl49
  xnLe := Nat.le_of_ble_eq_true bodyXn49
  loLe := Nat.le_of_ble_eq_true bodyLo49
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB49
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
noncomputable def bodyEs49 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr49.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st49.S5.tab r
kernel_rfl bodyResChk49 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs49 bodyQs49) = true
kernel_rfl bodyLq49 : bodyQs49.length = PRE_first_tail_x4_L8_r0_body.cws49.length
kernel_rfl bodyNrLo49 : PRE_first_tail_x4_L8_r0_body.nr49.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S1106.tab.length) = true
kernel_rfl bodySub49 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site49.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost49 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws49 PRE_first_tail_x4_L8_r0_body.cws49 bodyQs49 = true
kernel_rfl bodyDrop49 : Nat.ble (50827 + (PRE_first_tail_x4_L8_r0_body.s1107.next - PRE_first_tail_x4_L8_r0_body.s1108.next)) 51976 = true
kernel_rfl bodyDropH49 : Nat.ble (970 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1107.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s1108.ffi).next)) 995 = true
kernel_rfl bodyDropN49 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1107.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s1108.ffi).nnext)) 0 = true
kernel_rfl bodyDv49 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws49
kernel_rfl bodyDe49 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr49.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st49.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl49 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold49 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws49).isNone && !PRE_first_tail_x4_L8_r0_body.ws49.contains v) = true
kernel_rfl bodyDfree49 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws49 ++ PRE_first_tail_x4_L8_r0_body.ws49).all fun w => e.noVar w) = true

theorem bodyStep49 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50827, 970, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1106 PRE_first_tail_x4_L8_r0_body.S1106)
      (bodyCut NB T tk π i x0 bodyΘ ⟨51976, 995, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1108 PRE_first_tail_x4_L8_r0_body.S1108) (11334 + 1) :=
  bodySite bodyFacts49.cfix bodyFacts49.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st49.S5.tab) (Es := bodyEs49) (qs := bodyQs49)
    (ok := PRE_first_tail_x4_L8_r0_body.st49.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site49 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts49
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site49 r hr) hi (MapOk.sub hm (sub_of_all bodySub49)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk49 r hr) hi hm ho hq)
    bodyLq49 rfl bodyNrLo49 (postSub_sound bodyPost49)
    (Nat.le_of_ble_eq_true bodyDrop49) (by decide) (Nat.le_of_ble_eq_true bodyDropH49) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN49) (by decide)
    bodyDv49 bodyDe49 bodyDl49 bodyDold49 bodyDfree49 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site50 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site50 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site50) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st50.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site50
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st50.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st50.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1128 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1129 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1128 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws50 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st50.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st50.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso50
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_50
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st50.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot50
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup50
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound50
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace50
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged50
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws50.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st50.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1128.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_50]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen50.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh50
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl50 : Conv.NClean (⟨21318, 18404, 2799973, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1128.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl50 (PRE_first_tail_x4_L8_r0_body.cncl49 bodyNcl49)

theorem bodyClean50 : Conv.JClean (⟨21318, 18404, 2799973, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s1128 :=
  PRE_first_tail_x4_L8_r0_body.gjcl50 (PRE_first_tail_x4_L8_r0_body.cjcl49 bodyClean49)

kernel_rfl bodyJsLe50 : Nat.ble PRE_first_tail_x4_L8_r0_body.s1106.next PRE_first_tail_x4_L8_r0_body.s1128.next = true
kernel_rfl bodyJsList50 : (PRE_first_tail_x4_L8_r0_body.gjh50 ++ PRE_first_tail_x4_L8_r0_body.cl50).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1128.next) PRE_first_tail_x4_L8_r0_body.s1130) = true
theorem bodyJs50 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s1128.next PRE_first_tail_x4_L8_r0_body.s1130 :=
  JsHeapAbove.glueSite bodyJs49 (Nat.le_of_ble_eq_true bodyJsLe50) PRE_first_tail_x4_L8_r0_body.gjk50 PRE_first_tail_x4_L8_r0_body.gjbd50 PRE_first_tail_x4_L8_r0_body.cheap50 PRE_first_tail_x4_L8_r0_body.zclbd50 bodyJsList50

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1108 : PRE_first_tail_x4_L8_r0_body.S1108.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1108.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1108 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1108.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc1108 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1108 PRE_first_tail_x4_L8_r0_body.S1108) = fun _ _ => true
kernel_rfl bodyAcc1109 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1109 PRE_first_tail_x4_L8_r0_body.S1109) = fun _ _ => true
kernel_rfl bodyBr1110 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1110.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1109 : isHalt PRE_first_tail_x4_L8_r0_body.s1109.ctl = false
kernel_rfl bodyTop1110 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1110 = true
kernel_rfl bodyCnt1108 : countersOkB PRE_first_tail_x4_L8_r0_body.s1108 PRE_first_tail_x4_L8_r0_body.s1110 = true
kernel_rfl bodyO1110 : PRE_first_tail_x4_L8_r0_body.S1110.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1110.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1111 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1111.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1110 : countersOkB PRE_first_tail_x4_L8_r0_body.s1110 PRE_first_tail_x4_L8_r0_body.s1111 = true
kernel_rfl bodyO1111 : PRE_first_tail_x4_L8_r0_body.S1111.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1111.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1111 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1111 PRE_first_tail_x4_L8_r0_body.S1111) = fun _ _ => true
kernel_rfl bodyAcc1115 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1115 PRE_first_tail_x4_L8_r0_body.S1115) = fun _ _ => true
kernel_rfl bodyBr1116 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1116.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1115 : isHalt PRE_first_tail_x4_L8_r0_body.s1115.ctl = false
kernel_rfl bodyTop1116 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1116 = true
kernel_rfl bodyCnt1111 : countersOkB PRE_first_tail_x4_L8_r0_body.s1111 PRE_first_tail_x4_L8_r0_body.s1116 = true
kernel_rfl bodyO1116 : PRE_first_tail_x4_L8_r0_body.S1116.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1116.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1117 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1117.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1116 : countersOkB PRE_first_tail_x4_L8_r0_body.s1116 PRE_first_tail_x4_L8_r0_body.s1117 = true
kernel_rfl bodyO1117 : PRE_first_tail_x4_L8_r0_body.S1117.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1117.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1117 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1117 PRE_first_tail_x4_L8_r0_body.S1117) = fun _ _ => true
kernel_rfl bodyAcc1118 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1118 PRE_first_tail_x4_L8_r0_body.S1118) = fun _ _ => true
kernel_rfl bodyBr1119 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1119.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1118 : isHalt PRE_first_tail_x4_L8_r0_body.s1118.ctl = false
kernel_rfl bodyTop1119 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1119 = true
kernel_rfl bodyCnt1117 : countersOkB PRE_first_tail_x4_L8_r0_body.s1117 PRE_first_tail_x4_L8_r0_body.s1119 = true
kernel_rfl bodyO1119 : PRE_first_tail_x4_L8_r0_body.S1119.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1119.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1120 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1120.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1119 : countersOkB PRE_first_tail_x4_L8_r0_body.s1119 PRE_first_tail_x4_L8_r0_body.s1120 = true
kernel_rfl bodyO1120 : PRE_first_tail_x4_L8_r0_body.S1120.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1120.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1120 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1120 PRE_first_tail_x4_L8_r0_body.S1120) = fun _ _ => true
kernel_rfl bodyAcc1121 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1121 PRE_first_tail_x4_L8_r0_body.S1121) = fun _ _ => true
kernel_rfl bodyBr1122 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1122.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1121 : isHalt PRE_first_tail_x4_L8_r0_body.s1121.ctl = false
kernel_rfl bodyTop1122 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1122 = true
kernel_rfl bodyCnt1120 : countersOkB PRE_first_tail_x4_L8_r0_body.s1120 PRE_first_tail_x4_L8_r0_body.s1122 = true
kernel_rfl bodyO1122 : PRE_first_tail_x4_L8_r0_body.S1122.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1122.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1123 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1123.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1122 : countersOkB PRE_first_tail_x4_L8_r0_body.s1122 PRE_first_tail_x4_L8_r0_body.s1123 = true
kernel_rfl bodyO1123 : PRE_first_tail_x4_L8_r0_body.S1123.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1123.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1123 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1123 PRE_first_tail_x4_L8_r0_body.S1123) = fun _ _ => true
kernel_rfl bodyAcc1124 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1124 PRE_first_tail_x4_L8_r0_body.S1124) = fun _ _ => true
kernel_rfl bodyBr1125 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1125.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1124 : isHalt PRE_first_tail_x4_L8_r0_body.s1124.ctl = false
kernel_rfl bodyTop1125 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1125 = true
kernel_rfl bodyCnt1123 : countersOkB PRE_first_tail_x4_L8_r0_body.s1123 PRE_first_tail_x4_L8_r0_body.s1125 = true
kernel_rfl bodyO1125 : PRE_first_tail_x4_L8_r0_body.S1125.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1125.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1126 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1126.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1125 : countersOkB PRE_first_tail_x4_L8_r0_body.s1125 PRE_first_tail_x4_L8_r0_body.s1126 = true
kernel_rfl bodyO1126 : PRE_first_tail_x4_L8_r0_body.S1126.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1126.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1126 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1126 PRE_first_tail_x4_L8_r0_body.S1126) = fun _ _ => true
kernel_rfl bodyAcc1127 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1127 PRE_first_tail_x4_L8_r0_body.S1127) = fun _ _ => true
kernel_rfl bodyBr1128 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1128.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1127 : isHalt PRE_first_tail_x4_L8_r0_body.s1127.ctl = false
kernel_rfl bodyTop1128 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1128 = true
kernel_rfl bodyCnt1126 : countersOkB PRE_first_tail_x4_L8_r0_body.s1126 PRE_first_tail_x4_L8_r0_body.s1128 = true

theorem bodyGlue50 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨51976, 995, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1108 PRE_first_tail_x4_L8_r0_body.S1108)
      (bodyCut NB T tk π i x0 bodyΘ ⟨51976, 995, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1128 PRE_first_tail_x4_L8_r0_body.S1128) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) bodyAcc1108 PRE_first_tail_x4_L8_r0_body.bodyRunSeg287 bodyAcc1109 bodyHalt1109 PRE_first_tail_x4_L8_r0_body.bodyStepA288 bodyTop1110 (fun _ hm => bodyO1108 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1108).trans bodyInactive0) (bodyBr1110.trans bodyBr1108.symm) bodyCnt1108 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA288 PRE_first_tail_x4_L8_r0_body.sizeArgsA288 PRE_first_tail_x4_L8_r0_body.sizeSymA288 PRE_first_tail_x4_L8_r0_body.sizeMlxA288 PRE_first_tail_x4_L8_r0_body.sizePayA288 PRE_first_tail_x4_L8_r0_body.sizeTaA288 PRE_first_tail_x4_L8_r0_body.sizeDecA288 PRE_first_tail_x4_L8_r0_body.sizePreA288 PRE_first_tail_x4_L8_r0_body.bodyPatchB288 (fun _ hm => bodyO1110 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1110).trans bodyInactive0) (bodyBr1111.trans bodyBr1110.symm) bodyCnt1110 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) bodyAcc1111 PRE_first_tail_x4_L8_r0_body.bodyRunSeg288 bodyAcc1115 bodyHalt1115 PRE_first_tail_x4_L8_r0_body.bodyStepA289 bodyTop1116 (fun _ hm => bodyO1111 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1111).trans bodyInactive0) (bodyBr1116.trans bodyBr1111.symm) bodyCnt1111 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA289 PRE_first_tail_x4_L8_r0_body.sizeArgsA289 PRE_first_tail_x4_L8_r0_body.sizeSymA289 PRE_first_tail_x4_L8_r0_body.sizeMlxA289 PRE_first_tail_x4_L8_r0_body.sizePayA289 PRE_first_tail_x4_L8_r0_body.sizeTaA289 PRE_first_tail_x4_L8_r0_body.sizeDecA289 PRE_first_tail_x4_L8_r0_body.sizePreA289 PRE_first_tail_x4_L8_r0_body.bodyPatchB289 (fun _ hm => bodyO1116 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1116).trans bodyInactive0) (bodyBr1117.trans bodyBr1116.symm) bodyCnt1116 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) bodyAcc1117 PRE_first_tail_x4_L8_r0_body.bodyRunSeg289 bodyAcc1118 bodyHalt1118 PRE_first_tail_x4_L8_r0_body.bodyStepA290 bodyTop1119 (fun _ hm => bodyO1117 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1117).trans bodyInactive0) (bodyBr1119.trans bodyBr1117.symm) bodyCnt1117 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA290 PRE_first_tail_x4_L8_r0_body.sizeArgsA290 PRE_first_tail_x4_L8_r0_body.sizeSymA290 PRE_first_tail_x4_L8_r0_body.sizeMlxA290 PRE_first_tail_x4_L8_r0_body.sizePayA290 PRE_first_tail_x4_L8_r0_body.sizeTaA290 PRE_first_tail_x4_L8_r0_body.sizeDecA290 PRE_first_tail_x4_L8_r0_body.sizePreA290 PRE_first_tail_x4_L8_r0_body.bodyPatchB290 (fun _ hm => bodyO1119 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1119).trans bodyInactive0) (bodyBr1120.trans bodyBr1119.symm) bodyCnt1119 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) bodyAcc1120 PRE_first_tail_x4_L8_r0_body.bodyRunSeg290 bodyAcc1121 bodyHalt1121 PRE_first_tail_x4_L8_r0_body.bodyStepA291 bodyTop1122 (fun _ hm => bodyO1120 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1120).trans bodyInactive0) (bodyBr1122.trans bodyBr1120.symm) bodyCnt1120 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA291 PRE_first_tail_x4_L8_r0_body.sizeArgsA291 PRE_first_tail_x4_L8_r0_body.sizeSymA291 PRE_first_tail_x4_L8_r0_body.sizeMlxA291 PRE_first_tail_x4_L8_r0_body.sizePayA291 PRE_first_tail_x4_L8_r0_body.sizeTaA291 PRE_first_tail_x4_L8_r0_body.sizeDecA291 PRE_first_tail_x4_L8_r0_body.sizePreA291 PRE_first_tail_x4_L8_r0_body.bodyPatchB291 (fun _ hm => bodyO1122 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1122).trans bodyInactive0) (bodyBr1123.trans bodyBr1122.symm) bodyCnt1122 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) bodyAcc1123 PRE_first_tail_x4_L8_r0_body.bodyRunSeg291 bodyAcc1124 bodyHalt1124 PRE_first_tail_x4_L8_r0_body.bodyStepA292 bodyTop1125 (fun _ hm => bodyO1123 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1123).trans bodyInactive0) (bodyBr1125.trans bodyBr1123.symm) bodyCnt1123 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA292 PRE_first_tail_x4_L8_r0_body.sizeArgsA292 PRE_first_tail_x4_L8_r0_body.sizeSymA292 PRE_first_tail_x4_L8_r0_body.sizeMlxA292 PRE_first_tail_x4_L8_r0_body.sizePayA292 PRE_first_tail_x4_L8_r0_body.sizeTaA292 PRE_first_tail_x4_L8_r0_body.sizeDecA292 PRE_first_tail_x4_L8_r0_body.sizePreA292 PRE_first_tail_x4_L8_r0_body.bodyPatchB292 (fun _ hm => bodyO1125 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1125).trans bodyInactive0) (bodyBr1126.trans bodyBr1125.symm) bodyCnt1125 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51976, 995, 0, 0⟩) bodyAcc1126 PRE_first_tail_x4_L8_r0_body.bodyRunSeg292 bodyAcc1127 bodyHalt1127 PRE_first_tail_x4_L8_r0_body.bodyStepA293 bodyTop1128 (fun _ hm => bodyO1126 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1126).trans bodyInactive0) (bodyBr1128.trans bodyBr1126.symm) bodyCnt1126 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift50 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S1128.tab.length PRE_first_tail_x4_L8_r0_body.s1128.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P50.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P50 15 PRE_first_tail_x4_L8_r0_body.kappa50 PRE_first_tail_x4_L8_r0_body.s1130.ffi PRE_first_tail_x4_L8_r0_body.s1129.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_50
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_50
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1130.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S1128.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_50] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK50 PRE_first_tail_x4_L8_r0_body.cobjsK50
      PRE_first_tail_x4_L8_r0_body.citemsK50 PRE_first_tail_x4_L8_r0_body.cbd50 PRE_first_tail_x4_L8_r0_body.csst50
  exact PRE_first_tail_x4_L8_r0_body.cshift50 bodyNcl50 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_50] at this; exact this)


kernel_rfl bodyFramesEmpty50 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s1129 a).isEmpty) = true
kernel_rfl bodyJsRoots50 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1128.next) PRE_first_tail_x4_L8_r0_body.s1130.trace PRE_first_tail_x4_L8_r0_body.s1130 = true
kernel_rfl bodyJsNative50 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s1130.ffi) = true
kernel_rfl bodyLow50 : (PRE_first_tail_x4_L8_r0_body.cws50 ++ PRE_first_tail_x4_L8_r0_body.ws50).all (Nat.ble 9) = true
kernel_rfl bodyCntM50 : countersOkB PRE_first_tail_x4_L8_r0_body.s1128 PRE_first_tail_x4_L8_r0_body.s1129 = true
kernel_rfl bodyHi50 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1130.ffi).next setupP.E = true
kernel_rfl bodyNhi50 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1130.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge50 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1129.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s1128.ffi
kernel_rfl bodyNN50 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1128.ffi).nnext PRE_first_tail_x4_L8_r0_body.P50.NL = true
kernel_rfl bodyXn50 : Nat.ble (⟨21321, 18431, 2799979, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s1130.ffi).next = true
kernel_rfl bodyLo50 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s1130.ffi).next = true
theorem bodyFacts50 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s1128 PRE_first_tail_x4_L8_r0_body.s1129 PRE_first_tail_x4_L8_r0_body.s1130 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S1128 PRE_first_tail_x4_L8_r0_body.S1129 PRE_first_tail_x4_L8_r0_body.S1130
    PRE_first_tail_x4_L8_r0_body.ws50 PRE_first_tail_x4_L8_r0_body.cws50 PRE_first_tail_x4_L8_r0_body.nr50 PRE_first_tail_x4_L8_r0_body.pl50 PRE_first_tail_x4_L8_r0_body.cl50 2801128 15 PRE_first_tail_x4_L8_r0_body.kd50 PRE_first_tail_x4_L8_r0_body.kappa50 PRE_first_tail_x4_L8_r0_body.P50
    ⟨21318, 18404, 2799973, 15⟩ ⟨21321, 18431, 2799979, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap50
  clean := bodyClean50
  cfix := PRE_first_tail_x4_L8_r0_body.cfix50
  zpl := PRE_first_tail_x4_L8_r0_body.zpl50
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd50
  zn1 := PRE_first_tail_x4_L8_r0_body.zn150
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst50
  zscn := PRE_first_tail_x4_L8_r0_body.zscn50
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn50
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow50
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab50
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh50
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd50
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi50
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt50
  zgP := PRE_first_tail_x4_L8_r0_body.zg50_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk50_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm50_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg50_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk50_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm50_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw50_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw50_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap50
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd50
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap50 PRE_first_tail_x4_L8_r0_body.stFoot50 PRE_first_tail_x4_L8_r0_body.iso50 PRE_first_tail_x4_L8_r0_body.zwr50
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP50
  csupp := PRE_first_tail_x4_L8_r0_body.csupp50
  cbound := PRE_first_tail_x4_L8_r0_body.cbound50
  zimg := PRE_first_tail_x4_L8_r0_body.zimg50
  zctl := PRE_first_tail_x4_L8_r0_body.zctl50
  zstack := PRE_first_tail_x4_L8_r0_body.zstack50
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs50
  zstores := PRE_first_tail_x4_L8_r0_body.zstores50
  zroots := PRE_first_tail_x4_L8_r0_body.zroots50
  znC := PRE_first_tail_x4_L8_r0_body.znC50
  ctab := PRE_first_tail_x4_L8_r0_body.ctab50
  zbin := PRE_first_tail_x4_L8_r0_body.zbin50
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge50
  sbridge := bodyBridge50
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj50
  cshiftR := fun h hNL => bodyCshift50 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN50
  raised := PRE_first_tail_x4_L8_r0_body.raised50
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs50
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl50
  xnLe := Nat.le_of_ble_eq_true bodyXn50
  loLe := Nat.le_of_ble_eq_true bodyLo50
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB50
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
noncomputable def bodyEs50 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr50.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st50.S5.tab r
kernel_rfl bodyResChk50 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs50 bodyQs50) = true
kernel_rfl bodyLq50 : bodyQs50.length = PRE_first_tail_x4_L8_r0_body.cws50.length
kernel_rfl bodyNrLo50 : PRE_first_tail_x4_L8_r0_body.nr50.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S1128.tab.length) = true
kernel_rfl bodySub50 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site50.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost50 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws50 PRE_first_tail_x4_L8_r0_body.cws50 bodyQs50 = true
kernel_rfl bodyDrop50 : Nat.ble (51976 + (PRE_first_tail_x4_L8_r0_body.s1129.next - PRE_first_tail_x4_L8_r0_body.s1130.next)) 53125 = true
kernel_rfl bodyDropH50 : Nat.ble (995 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1129.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s1130.ffi).next)) 1020 = true
kernel_rfl bodyDropN50 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1129.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s1130.ffi).nnext)) 0 = true
kernel_rfl bodyDv50 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws50
kernel_rfl bodyDe50 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr50.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st50.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl50 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold50 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws50).isNone && !PRE_first_tail_x4_L8_r0_body.ws50.contains v) = true
kernel_rfl bodyDfree50 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws50 ++ PRE_first_tail_x4_L8_r0_body.ws50).all fun w => e.noVar w) = true

theorem bodyStep50 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨51976, 995, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1128 PRE_first_tail_x4_L8_r0_body.S1128)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53125, 1020, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1130 PRE_first_tail_x4_L8_r0_body.S1130) (11334 + 1) :=
  bodySite bodyFacts50.cfix bodyFacts50.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st50.S5.tab) (Es := bodyEs50) (qs := bodyQs50)
    (ok := PRE_first_tail_x4_L8_r0_body.st50.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site50 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts50
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site50 r hr) hi (MapOk.sub hm (sub_of_all bodySub50)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk50 r hr) hi hm ho hq)
    bodyLq50 rfl bodyNrLo50 (postSub_sound bodyPost50)
    (Nat.le_of_ble_eq_true bodyDrop50) (by decide) (Nat.le_of_ble_eq_true bodyDropH50) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN50) (by decide)
    bodyDv50 bodyDe50 bodyDl50 bodyDold50 bodyDfree50 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site51 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site51 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site51) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st51.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site51
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st51.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st51.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1149 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1150 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1149 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws51 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st51.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st51.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso51
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_51
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st51.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot51
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup51
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound51
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace51
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged51
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws51.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st51.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1149.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_51]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen51.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh51
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl51 : Conv.NClean (⟨21381, 18476, 2802476, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1149.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl51 (PRE_first_tail_x4_L8_r0_body.cncl50 bodyNcl50)

theorem bodyClean51 : Conv.JClean (⟨21381, 18476, 2802476, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s1149 :=
  PRE_first_tail_x4_L8_r0_body.gjcl51 (PRE_first_tail_x4_L8_r0_body.cjcl50 bodyClean50)

kernel_rfl bodyJsLe51 : Nat.ble PRE_first_tail_x4_L8_r0_body.s1128.next PRE_first_tail_x4_L8_r0_body.s1149.next = true
kernel_rfl bodyJsList51 : (PRE_first_tail_x4_L8_r0_body.gjh51 ++ PRE_first_tail_x4_L8_r0_body.cl51).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1149.next) PRE_first_tail_x4_L8_r0_body.s1151) = true
theorem bodyJs51 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s1149.next PRE_first_tail_x4_L8_r0_body.s1151 :=
  JsHeapAbove.glueSite bodyJs50 (Nat.le_of_ble_eq_true bodyJsLe51) PRE_first_tail_x4_L8_r0_body.gjk51 PRE_first_tail_x4_L8_r0_body.gjbd51 PRE_first_tail_x4_L8_r0_body.cheap51 PRE_first_tail_x4_L8_r0_body.zclbd51 bodyJsList51

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1130 : PRE_first_tail_x4_L8_r0_body.S1130.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1130.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1130 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1130.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc1130 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1130 PRE_first_tail_x4_L8_r0_body.S1130) = fun _ _ => true
kernel_rfl bodyAcc1131 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1131 PRE_first_tail_x4_L8_r0_body.S1131) = fun _ _ => true
kernel_rfl bodyBr1132 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1132.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1131 : isHalt PRE_first_tail_x4_L8_r0_body.s1131.ctl = false
kernel_rfl bodyTop1132 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1132 = true
kernel_rfl bodyCnt1130 : countersOkB PRE_first_tail_x4_L8_r0_body.s1130 PRE_first_tail_x4_L8_r0_body.s1132 = true
kernel_rfl bodyO1132 : PRE_first_tail_x4_L8_r0_body.S1132.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1132.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1133 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1133.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1132 : countersOkB PRE_first_tail_x4_L8_r0_body.s1132 PRE_first_tail_x4_L8_r0_body.s1133 = true
kernel_rfl bodyO1133 : PRE_first_tail_x4_L8_r0_body.S1133.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1133.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1133 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1133 PRE_first_tail_x4_L8_r0_body.S1133) = fun _ _ => true
kernel_rfl bodyAcc1137 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1137 PRE_first_tail_x4_L8_r0_body.S1137) = fun _ _ => true
kernel_rfl bodyBr1138 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1138.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1137 : isHalt PRE_first_tail_x4_L8_r0_body.s1137.ctl = false
kernel_rfl bodyTop1138 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1138 = true
kernel_rfl bodyCnt1133 : countersOkB PRE_first_tail_x4_L8_r0_body.s1133 PRE_first_tail_x4_L8_r0_body.s1138 = true
kernel_rfl bodyO1138 : PRE_first_tail_x4_L8_r0_body.S1138.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1138.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1139 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1139.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1138 : countersOkB PRE_first_tail_x4_L8_r0_body.s1138 PRE_first_tail_x4_L8_r0_body.s1139 = true
kernel_rfl bodyO1139 : PRE_first_tail_x4_L8_r0_body.S1139.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1139.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1139 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1139 PRE_first_tail_x4_L8_r0_body.S1139) = fun _ _ => true
kernel_rfl bodyAcc1141 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1141 PRE_first_tail_x4_L8_r0_body.S1141) = fun _ _ => true
kernel_rfl bodyBr1142 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1142.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1141 : isHalt PRE_first_tail_x4_L8_r0_body.s1141.ctl = false
kernel_rfl bodyTop1142 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1142 = true
kernel_rfl bodyCnt1139 : countersOkB PRE_first_tail_x4_L8_r0_body.s1139 PRE_first_tail_x4_L8_r0_body.s1142 = true
kernel_rfl bodyO1142 : PRE_first_tail_x4_L8_r0_body.S1142.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1142.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1143 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1143.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1142 : countersOkB PRE_first_tail_x4_L8_r0_body.s1142 PRE_first_tail_x4_L8_r0_body.s1143 = true
kernel_rfl bodyO1143 : PRE_first_tail_x4_L8_r0_body.S1143.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1143.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1143 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1143 PRE_first_tail_x4_L8_r0_body.S1143) = fun _ _ => true
kernel_rfl bodyAcc1144 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1144 PRE_first_tail_x4_L8_r0_body.S1144) = fun _ _ => true
kernel_rfl bodyBr1145 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1145.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1144 : isHalt PRE_first_tail_x4_L8_r0_body.s1144.ctl = false
kernel_rfl bodyTop1145 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1145 = true
kernel_rfl bodyCnt1143 : countersOkB PRE_first_tail_x4_L8_r0_body.s1143 PRE_first_tail_x4_L8_r0_body.s1145 = true
kernel_rfl bodyO1145 : PRE_first_tail_x4_L8_r0_body.S1145.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1145.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1146 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1146.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1145 : countersOkB PRE_first_tail_x4_L8_r0_body.s1145 PRE_first_tail_x4_L8_r0_body.s1146 = true
kernel_rfl bodyO1146 : PRE_first_tail_x4_L8_r0_body.S1146.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1146.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1146 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1146 PRE_first_tail_x4_L8_r0_body.S1146) = fun _ _ => true
kernel_rfl bodyAcc1148 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1148 PRE_first_tail_x4_L8_r0_body.S1148) = fun _ _ => true
kernel_rfl bodyBr1149 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1149.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1148 : isHalt PRE_first_tail_x4_L8_r0_body.s1148.ctl = false
kernel_rfl bodyTop1149 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1149 = true
kernel_rfl bodyCnt1146 : countersOkB PRE_first_tail_x4_L8_r0_body.s1146 PRE_first_tail_x4_L8_r0_body.s1149 = true

theorem bodyGlue51 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53125, 1020, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1130 PRE_first_tail_x4_L8_r0_body.S1130)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53125, 1020, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1149 PRE_first_tail_x4_L8_r0_body.S1149) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) bodyAcc1130 PRE_first_tail_x4_L8_r0_body.bodyRunSeg293 bodyAcc1131 bodyHalt1131 PRE_first_tail_x4_L8_r0_body.bodyStepA294 bodyTop1132 (fun _ hm => bodyO1130 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1130).trans bodyInactive0) (bodyBr1132.trans bodyBr1130.symm) bodyCnt1130 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA294 PRE_first_tail_x4_L8_r0_body.sizeArgsA294 PRE_first_tail_x4_L8_r0_body.sizeSymA294 PRE_first_tail_x4_L8_r0_body.sizeMlxA294 PRE_first_tail_x4_L8_r0_body.sizePayA294 PRE_first_tail_x4_L8_r0_body.sizeTaA294 PRE_first_tail_x4_L8_r0_body.sizeDecA294 PRE_first_tail_x4_L8_r0_body.sizePreA294 PRE_first_tail_x4_L8_r0_body.bodyPatchB294 (fun _ hm => bodyO1132 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1132).trans bodyInactive0) (bodyBr1133.trans bodyBr1132.symm) bodyCnt1132 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) bodyAcc1133 PRE_first_tail_x4_L8_r0_body.bodyRunSeg294 bodyAcc1137 bodyHalt1137 PRE_first_tail_x4_L8_r0_body.bodyStepA295 bodyTop1138 (fun _ hm => bodyO1133 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1133).trans bodyInactive0) (bodyBr1138.trans bodyBr1133.symm) bodyCnt1133 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA295 PRE_first_tail_x4_L8_r0_body.sizeArgsA295 PRE_first_tail_x4_L8_r0_body.sizeSymA295 PRE_first_tail_x4_L8_r0_body.sizeMlxA295 PRE_first_tail_x4_L8_r0_body.sizePayA295 PRE_first_tail_x4_L8_r0_body.sizeTaA295 PRE_first_tail_x4_L8_r0_body.sizeDecA295 PRE_first_tail_x4_L8_r0_body.sizePreA295 PRE_first_tail_x4_L8_r0_body.bodyPatchB295 (fun _ hm => bodyO1138 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1138).trans bodyInactive0) (bodyBr1139.trans bodyBr1138.symm) bodyCnt1138 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) bodyAcc1139 PRE_first_tail_x4_L8_r0_body.bodyRunSeg295 bodyAcc1141 bodyHalt1141 PRE_first_tail_x4_L8_r0_body.bodyStepA296 bodyTop1142 (fun _ hm => bodyO1139 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1139).trans bodyInactive0) (bodyBr1142.trans bodyBr1139.symm) bodyCnt1139 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA296 PRE_first_tail_x4_L8_r0_body.sizeArgsA296 PRE_first_tail_x4_L8_r0_body.sizeSymA296 PRE_first_tail_x4_L8_r0_body.sizeMlxA296 PRE_first_tail_x4_L8_r0_body.sizePayA296 PRE_first_tail_x4_L8_r0_body.sizeTaA296 PRE_first_tail_x4_L8_r0_body.sizeDecA296 PRE_first_tail_x4_L8_r0_body.sizePreA296 PRE_first_tail_x4_L8_r0_body.bodyPatchB296 (fun _ hm => bodyO1142 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1142).trans bodyInactive0) (bodyBr1143.trans bodyBr1142.symm) bodyCnt1142 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) bodyAcc1143 PRE_first_tail_x4_L8_r0_body.bodyRunSeg296 bodyAcc1144 bodyHalt1144 PRE_first_tail_x4_L8_r0_body.bodyStepA297 bodyTop1145 (fun _ hm => bodyO1143 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1143).trans bodyInactive0) (bodyBr1145.trans bodyBr1143.symm) bodyCnt1143 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA297 PRE_first_tail_x4_L8_r0_body.sizeArgsA297 PRE_first_tail_x4_L8_r0_body.sizeSymA297 PRE_first_tail_x4_L8_r0_body.sizeMlxA297 PRE_first_tail_x4_L8_r0_body.sizePayA297 PRE_first_tail_x4_L8_r0_body.sizeTaA297 PRE_first_tail_x4_L8_r0_body.sizeDecA297 PRE_first_tail_x4_L8_r0_body.sizePreA297 PRE_first_tail_x4_L8_r0_body.bodyPatchB297 (fun _ hm => bodyO1145 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1145).trans bodyInactive0) (bodyBr1146.trans bodyBr1145.symm) bodyCnt1145 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53125, 1020, 0, 0⟩) bodyAcc1146 PRE_first_tail_x4_L8_r0_body.bodyRunSeg297 bodyAcc1148 bodyHalt1148 PRE_first_tail_x4_L8_r0_body.bodyStepA298 bodyTop1149 (fun _ hm => bodyO1146 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1146).trans bodyInactive0) (bodyBr1149.trans bodyBr1146.symm) bodyCnt1146 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift51 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S1149.tab.length PRE_first_tail_x4_L8_r0_body.s1149.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P51.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P51 15 PRE_first_tail_x4_L8_r0_body.kappa51 PRE_first_tail_x4_L8_r0_body.s1151.ffi PRE_first_tail_x4_L8_r0_body.s1150.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_51
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_51
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1151.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S1149.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_51] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK51 PRE_first_tail_x4_L8_r0_body.cobjsK51
      PRE_first_tail_x4_L8_r0_body.citemsK51 PRE_first_tail_x4_L8_r0_body.cbd51 PRE_first_tail_x4_L8_r0_body.csst51
  exact PRE_first_tail_x4_L8_r0_body.cshift51 bodyNcl51 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_51] at this; exact this)


kernel_rfl bodyFramesEmpty51 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s1150 a).isEmpty) = true
kernel_rfl bodyJsRoots51 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1149.next) PRE_first_tail_x4_L8_r0_body.s1151.trace PRE_first_tail_x4_L8_r0_body.s1151 = true
kernel_rfl bodyJsNative51 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s1151.ffi) = true
kernel_rfl bodyLow51 : (PRE_first_tail_x4_L8_r0_body.cws51 ++ PRE_first_tail_x4_L8_r0_body.ws51).all (Nat.ble 9) = true
kernel_rfl bodyCntM51 : countersOkB PRE_first_tail_x4_L8_r0_body.s1149 PRE_first_tail_x4_L8_r0_body.s1150 = true
kernel_rfl bodyHi51 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1151.ffi).next setupP.E = true
kernel_rfl bodyNhi51 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1151.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge51 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1150.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s1149.ffi
kernel_rfl bodyNN51 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1149.ffi).nnext PRE_first_tail_x4_L8_r0_body.P51.NL = true
kernel_rfl bodyXn51 : Nat.ble (⟨21385, 18482, 2802491, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s1151.ffi).next = true
kernel_rfl bodyLo51 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s1151.ffi).next = true
theorem bodyFacts51 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s1149 PRE_first_tail_x4_L8_r0_body.s1150 PRE_first_tail_x4_L8_r0_body.s1151 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S1149 PRE_first_tail_x4_L8_r0_body.S1150 PRE_first_tail_x4_L8_r0_body.S1151
    PRE_first_tail_x4_L8_r0_body.ws51 PRE_first_tail_x4_L8_r0_body.cws51 PRE_first_tail_x4_L8_r0_body.nr51 PRE_first_tail_x4_L8_r0_body.pl51 PRE_first_tail_x4_L8_r0_body.cl51 2802841 15 PRE_first_tail_x4_L8_r0_body.kd51 PRE_first_tail_x4_L8_r0_body.kappa51 PRE_first_tail_x4_L8_r0_body.P51
    ⟨21381, 18476, 2802476, 15⟩ ⟨21385, 18482, 2802491, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap51
  clean := bodyClean51
  cfix := PRE_first_tail_x4_L8_r0_body.cfix51
  zpl := PRE_first_tail_x4_L8_r0_body.zpl51
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd51
  zn1 := PRE_first_tail_x4_L8_r0_body.zn151
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst51
  zscn := PRE_first_tail_x4_L8_r0_body.zscn51
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn51
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow51
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab51
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh51
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd51
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi51
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt51
  zgP := PRE_first_tail_x4_L8_r0_body.zg51_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk51_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm51_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg51_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk51_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm51_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw51_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw51_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap51
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd51
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap51 PRE_first_tail_x4_L8_r0_body.stFoot51 PRE_first_tail_x4_L8_r0_body.iso51 PRE_first_tail_x4_L8_r0_body.zwr51
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP51
  csupp := PRE_first_tail_x4_L8_r0_body.csupp51
  cbound := PRE_first_tail_x4_L8_r0_body.cbound51
  zimg := PRE_first_tail_x4_L8_r0_body.zimg51
  zctl := PRE_first_tail_x4_L8_r0_body.zctl51
  zstack := PRE_first_tail_x4_L8_r0_body.zstack51
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs51
  zstores := PRE_first_tail_x4_L8_r0_body.zstores51
  zroots := PRE_first_tail_x4_L8_r0_body.zroots51
  znC := PRE_first_tail_x4_L8_r0_body.znC51
  ctab := PRE_first_tail_x4_L8_r0_body.ctab51
  zbin := PRE_first_tail_x4_L8_r0_body.zbin51
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge51
  sbridge := bodyBridge51
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj51
  cshiftR := fun h hNL => bodyCshift51 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN51
  raised := PRE_first_tail_x4_L8_r0_body.raised51
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs51
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl51
  xnLe := Nat.le_of_ble_eq_true bodyXn51
  loLe := Nat.le_of_ble_eq_true bodyLo51
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB51
  cntM := bodyCntM51
  hiLe := Nat.le_of_ble_eq_true bodyHi51
  nhiLe := Nat.le_of_ble_eq_true bodyNhi51
  jsHeap := bodyJs51
  jsRoots := bodyJsRoots51
  jsNative := bodyJsNative51
  framesEmpty := bodyFramesEmpty51
  trailOld := by decide
  lowVars := bodyLow51

def bodyQs51 : List (Option Q) := []
noncomputable def bodyEs51 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr51.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st51.S3.tab r
kernel_rfl bodyResChk51 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs51 bodyQs51) = true
kernel_rfl bodyLq51 : bodyQs51.length = PRE_first_tail_x4_L8_r0_body.cws51.length
kernel_rfl bodyNrLo51 : PRE_first_tail_x4_L8_r0_body.nr51.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S1149.tab.length) = true
kernel_rfl bodySub51 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site51.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost51 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws51 PRE_first_tail_x4_L8_r0_body.cws51 bodyQs51 = true
kernel_rfl bodyDrop51 : Nat.ble (53125 + (PRE_first_tail_x4_L8_r0_body.s1150.next - PRE_first_tail_x4_L8_r0_body.s1151.next)) 53475 = true
kernel_rfl bodyDropH51 : Nat.ble (1020 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1150.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s1151.ffi).next)) 1022 = true
kernel_rfl bodyDropN51 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1150.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s1151.ffi).nnext)) 0 = true
kernel_rfl bodyDv51 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws51
kernel_rfl bodyDe51 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr51.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st51.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl51 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold51 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws51).isNone && !PRE_first_tail_x4_L8_r0_body.ws51.contains v) = true
kernel_rfl bodyDfree51 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws51 ++ PRE_first_tail_x4_L8_r0_body.ws51).all fun w => e.noVar w) = true

theorem bodyStep51 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53125, 1020, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1149 PRE_first_tail_x4_L8_r0_body.S1149)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53475, 1022, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1151 PRE_first_tail_x4_L8_r0_body.S1151) (3452 + 1) :=
  bodySite bodyFacts51.cfix bodyFacts51.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L8_r0_body.st51.S3.tab) (Es := bodyEs51) (qs := bodyQs51)
    (ok := PRE_first_tail_x4_L8_r0_body.st51.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site51 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts51
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site51 r hr) hi (MapOk.sub hm (sub_of_all bodySub51)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk51 r hr) hi hm ho hq)
    bodyLq51 rfl bodyNrLo51 (postSub_sound bodyPost51)
    (Nat.le_of_ble_eq_true bodyDrop51) (by decide) (Nat.le_of_ble_eq_true bodyDropH51) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN51) (by decide)
    bodyDv51 bodyDe51 bodyDl51 bodyDold51 bodyDfree51 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyOracles_13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_g52 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g52 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g52) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site52 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site52 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site52) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st52.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g53 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g53 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g53) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site53 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site53 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site53) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st53.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g54 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g54 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g54) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site54 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site54 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site54) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st54.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g55 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g55 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g55) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site55 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site55 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site55) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st55.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site52 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site52 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site52) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st52.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site52
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st52.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st52.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1173 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1174 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1173 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws52 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st52.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st52.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso52
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_52
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st52.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot52
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup52
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound52
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace52
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged52
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws52.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st52.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1173.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_52]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen52.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh52
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl52 : Conv.NClean (⟨21453, 18528, 2805495, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1173.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl52 (PRE_first_tail_x4_L8_r0_body.cncl51 bodyNcl51)

theorem bodyClean52 : Conv.JClean (⟨21453, 18528, 2805495, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s1173 :=
  PRE_first_tail_x4_L8_r0_body.gjcl52 (PRE_first_tail_x4_L8_r0_body.cjcl51 bodyClean51)

kernel_rfl bodyJsLe52 : Nat.ble PRE_first_tail_x4_L8_r0_body.s1149.next PRE_first_tail_x4_L8_r0_body.s1173.next = true
kernel_rfl bodyJsList52 : (PRE_first_tail_x4_L8_r0_body.gjh52 ++ PRE_first_tail_x4_L8_r0_body.cl52).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1173.next) PRE_first_tail_x4_L8_r0_body.s1175) = true
theorem bodyJs52 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s1173.next PRE_first_tail_x4_L8_r0_body.s1175 :=
  JsHeapAbove.glueSite bodyJs51 (Nat.le_of_ble_eq_true bodyJsLe52) PRE_first_tail_x4_L8_r0_body.gjk52 PRE_first_tail_x4_L8_r0_body.gjbd52 PRE_first_tail_x4_L8_r0_body.cheap52 PRE_first_tail_x4_L8_r0_body.zclbd52 bodyJsList52

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1151 : PRE_first_tail_x4_L8_r0_body.S1151.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1151.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1151 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1151.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc1151 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1151 PRE_first_tail_x4_L8_r0_body.S1151) = fun _ _ => true
kernel_rfl bodyAcc1154 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1154 PRE_first_tail_x4_L8_r0_body.S1154) = fun _ _ => true
kernel_rfl bodyBr1155 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1155.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1154 : isHalt PRE_first_tail_x4_L8_r0_body.s1154.ctl = false
kernel_rfl bodyTop1155 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1155 = true
kernel_rfl bodyCnt1151 : countersOkB PRE_first_tail_x4_L8_r0_body.s1151 PRE_first_tail_x4_L8_r0_body.s1155 = true
kernel_rfl bodyO1155 : PRE_first_tail_x4_L8_r0_body.S1155.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1155.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1156 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1156.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1155 : countersOkB PRE_first_tail_x4_L8_r0_body.s1155 PRE_first_tail_x4_L8_r0_body.s1156 = true
kernel_rfl bodyO1156 : PRE_first_tail_x4_L8_r0_body.S1156.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1156.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1156 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1156 PRE_first_tail_x4_L8_r0_body.S1156) = fun _ _ => true
kernel_rfl bodyAcc1160 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1160 PRE_first_tail_x4_L8_r0_body.S1160) = fun _ _ => true
kernel_rfl bodyBr1161 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1161.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1160 : isHalt PRE_first_tail_x4_L8_r0_body.s1160.ctl = false
kernel_rfl bodyTop1161 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1161 = true
kernel_rfl bodyCnt1156 : countersOkB PRE_first_tail_x4_L8_r0_body.s1156 PRE_first_tail_x4_L8_r0_body.s1161 = true
kernel_rfl bodyO1161 : PRE_first_tail_x4_L8_r0_body.S1161.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1161.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1162 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1162.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1161 : countersOkB PRE_first_tail_x4_L8_r0_body.s1161 PRE_first_tail_x4_L8_r0_body.s1162 = true
kernel_rfl bodyO1162 : PRE_first_tail_x4_L8_r0_body.S1162.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1162.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1162 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1162 PRE_first_tail_x4_L8_r0_body.S1162) = fun _ _ => true
kernel_rfl bodyAcc1163 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1163 PRE_first_tail_x4_L8_r0_body.S1163) = fun _ _ => true
kernel_rfl bodyBr1164 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1164.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1163 : isHalt PRE_first_tail_x4_L8_r0_body.s1163.ctl = false
kernel_rfl bodyTop1164 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1164 = true
kernel_rfl bodyCnt1162 : countersOkB PRE_first_tail_x4_L8_r0_body.s1162 PRE_first_tail_x4_L8_r0_body.s1164 = true
kernel_rfl bodyO1164 : PRE_first_tail_x4_L8_r0_body.S1164.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1164.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1165 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1165.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1164 : countersOkB PRE_first_tail_x4_L8_r0_body.s1164 PRE_first_tail_x4_L8_r0_body.s1165 = true
kernel_rfl bodyO1165 : PRE_first_tail_x4_L8_r0_body.S1165.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1165.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1165 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1165 PRE_first_tail_x4_L8_r0_body.S1165) = fun _ _ => true
kernel_rfl bodyAcc1166 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1166 PRE_first_tail_x4_L8_r0_body.S1166) = fun _ _ => true
kernel_rfl bodyBr1167 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1167.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1166 : isHalt PRE_first_tail_x4_L8_r0_body.s1166.ctl = false
kernel_rfl bodyTop1167 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1167 = true
kernel_rfl bodyCnt1165 : countersOkB PRE_first_tail_x4_L8_r0_body.s1165 PRE_first_tail_x4_L8_r0_body.s1167 = true
kernel_rfl bodyO1167 : PRE_first_tail_x4_L8_r0_body.S1167.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1167.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1168 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1168.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1167 : countersOkB PRE_first_tail_x4_L8_r0_body.s1167 PRE_first_tail_x4_L8_r0_body.s1168 = true
kernel_rfl bodyO1168 : PRE_first_tail_x4_L8_r0_body.S1168.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1168.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1168 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1168 PRE_first_tail_x4_L8_r0_body.S1168) = fun _ _ => true
kernel_rfl bodyAcc1169 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1169 PRE_first_tail_x4_L8_r0_body.S1169) = fun _ _ => true
kernel_rfl bodyBr1170 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1170.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1169 : isHalt PRE_first_tail_x4_L8_r0_body.s1169.ctl = false
kernel_rfl bodyTop1170 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1170 = true
kernel_rfl bodyCnt1168 : countersOkB PRE_first_tail_x4_L8_r0_body.s1168 PRE_first_tail_x4_L8_r0_body.s1170 = true
kernel_rfl bodyO1170 : PRE_first_tail_x4_L8_r0_body.S1170.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1170.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1171 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1171.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1170 : countersOkB PRE_first_tail_x4_L8_r0_body.s1170 PRE_first_tail_x4_L8_r0_body.s1171 = true
kernel_rfl bodyO1171 : PRE_first_tail_x4_L8_r0_body.S1171.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1171.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1171 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1171 PRE_first_tail_x4_L8_r0_body.S1171) = fun _ _ => true
kernel_rfl bodyAcc1172 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1172 PRE_first_tail_x4_L8_r0_body.S1172) = fun _ _ => true
kernel_rfl bodyBr1173 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1173.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1172 : isHalt PRE_first_tail_x4_L8_r0_body.s1172.ctl = false
kernel_rfl bodyTop1173 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1173 = true
kernel_rfl bodyCnt1171 : countersOkB PRE_first_tail_x4_L8_r0_body.s1171 PRE_first_tail_x4_L8_r0_body.s1173 = true

theorem bodyGlue52 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53475, 1022, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1151 PRE_first_tail_x4_L8_r0_body.S1151)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53475, 1022, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1173 PRE_first_tail_x4_L8_r0_body.S1173) 30538 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) bodyAcc1151 PRE_first_tail_x4_L8_r0_body.bodyRunSeg298 bodyAcc1154 bodyHalt1154 PRE_first_tail_x4_L8_r0_body.bodyStepA299 bodyTop1155 (fun _ hm => bodyO1151 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1151).trans bodyInactive0) (bodyBr1155.trans bodyBr1151.symm) bodyCnt1151 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA299 PRE_first_tail_x4_L8_r0_body.sizeArgsA299 PRE_first_tail_x4_L8_r0_body.sizeSymA299 PRE_first_tail_x4_L8_r0_body.sizeMlxA299 PRE_first_tail_x4_L8_r0_body.sizePayA299 PRE_first_tail_x4_L8_r0_body.sizeTaA299 PRE_first_tail_x4_L8_r0_body.sizeDecA299 PRE_first_tail_x4_L8_r0_body.sizePreA299 PRE_first_tail_x4_L8_r0_body.bodyPatchB299 (fun _ hm => bodyO1155 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1155).trans bodyInactive0) (bodyBr1156.trans bodyBr1155.symm) bodyCnt1155 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) bodyAcc1156 PRE_first_tail_x4_L8_r0_body.bodyRunSeg299 bodyAcc1160 bodyHalt1160 PRE_first_tail_x4_L8_r0_body.bodyStepA300 bodyTop1161 (fun _ hm => bodyO1156 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1156).trans bodyInactive0) (bodyBr1161.trans bodyBr1156.symm) bodyCnt1156 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA300 PRE_first_tail_x4_L8_r0_body.sizeArgsA300 PRE_first_tail_x4_L8_r0_body.sizeSymA300 PRE_first_tail_x4_L8_r0_body.sizeMlxA300 PRE_first_tail_x4_L8_r0_body.sizePayA300 PRE_first_tail_x4_L8_r0_body.sizeTaA300 PRE_first_tail_x4_L8_r0_body.sizeDecA300 PRE_first_tail_x4_L8_r0_body.sizePreA300 PRE_first_tail_x4_L8_r0_body.bodyPatchB300 (fun _ hm => bodyO1161 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1161).trans bodyInactive0) (bodyBr1162.trans bodyBr1161.symm) bodyCnt1161 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) bodyAcc1162 PRE_first_tail_x4_L8_r0_body.bodyRunSeg300 bodyAcc1163 bodyHalt1163 PRE_first_tail_x4_L8_r0_body.bodyStepA301 bodyTop1164 (fun _ hm => bodyO1162 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1162).trans bodyInactive0) (bodyBr1164.trans bodyBr1162.symm) bodyCnt1162 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA301 PRE_first_tail_x4_L8_r0_body.sizeArgsA301 PRE_first_tail_x4_L8_r0_body.sizeSymA301 PRE_first_tail_x4_L8_r0_body.sizeMlxA301 PRE_first_tail_x4_L8_r0_body.sizePayA301 PRE_first_tail_x4_L8_r0_body.sizeTaA301 PRE_first_tail_x4_L8_r0_body.sizeDecA301 PRE_first_tail_x4_L8_r0_body.sizePreA301 PRE_first_tail_x4_L8_r0_body.bodyPatchB301 (fun _ hm => bodyO1164 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1164).trans bodyInactive0) (bodyBr1165.trans bodyBr1164.symm) bodyCnt1164 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) bodyAcc1165 PRE_first_tail_x4_L8_r0_body.bodyRunSeg301 bodyAcc1166 bodyHalt1166 PRE_first_tail_x4_L8_r0_body.bodyStepA302 bodyTop1167 (fun _ hm => bodyO1165 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1165).trans bodyInactive0) (bodyBr1167.trans bodyBr1165.symm) bodyCnt1165 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA302 PRE_first_tail_x4_L8_r0_body.sizeArgsA302 PRE_first_tail_x4_L8_r0_body.sizeSymA302 PRE_first_tail_x4_L8_r0_body.sizeMlxA302 PRE_first_tail_x4_L8_r0_body.sizePayA302 PRE_first_tail_x4_L8_r0_body.sizeTaA302 PRE_first_tail_x4_L8_r0_body.sizeDecA302 PRE_first_tail_x4_L8_r0_body.sizePreA302 PRE_first_tail_x4_L8_r0_body.bodyPatchB302 (fun _ hm => bodyO1167 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1167).trans bodyInactive0) (bodyBr1168.trans bodyBr1167.symm) bodyCnt1167 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) bodyAcc1168 PRE_first_tail_x4_L8_r0_body.bodyRunSeg302 bodyAcc1169 bodyHalt1169 PRE_first_tail_x4_L8_r0_body.bodyStepA303 bodyTop1170 (fun _ hm => bodyO1168 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1168).trans bodyInactive0) (bodyBr1170.trans bodyBr1168.symm) bodyCnt1168 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA303 PRE_first_tail_x4_L8_r0_body.sizeArgsA303 PRE_first_tail_x4_L8_r0_body.sizeSymA303 PRE_first_tail_x4_L8_r0_body.sizeMlxA303 PRE_first_tail_x4_L8_r0_body.sizePayA303 PRE_first_tail_x4_L8_r0_body.sizeTaA303 PRE_first_tail_x4_L8_r0_body.sizeDecA303 PRE_first_tail_x4_L8_r0_body.sizePreA303 PRE_first_tail_x4_L8_r0_body.bodyPatchB303 (fun _ hm => bodyO1170 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1170).trans bodyInactive0) (bodyBr1171.trans bodyBr1170.symm) bodyCnt1170 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53475, 1022, 0, 0⟩) bodyAcc1171 PRE_first_tail_x4_L8_r0_body.bodyRunSeg303 bodyAcc1172 bodyHalt1172 PRE_first_tail_x4_L8_r0_body.bodyStepA304 bodyTop1173 (fun _ hm => bodyO1171 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1171).trans bodyInactive0) (bodyBr1173.trans bodyBr1171.symm) bodyCnt1171 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift52 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S1173.tab.length PRE_first_tail_x4_L8_r0_body.s1173.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P52.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P52 15 PRE_first_tail_x4_L8_r0_body.kappa52 PRE_first_tail_x4_L8_r0_body.s1175.ffi PRE_first_tail_x4_L8_r0_body.s1174.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_52
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_52
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1175.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S1173.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_52] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK52 PRE_first_tail_x4_L8_r0_body.cobjsK52
      PRE_first_tail_x4_L8_r0_body.citemsK52 PRE_first_tail_x4_L8_r0_body.cbd52 PRE_first_tail_x4_L8_r0_body.csst52
  exact PRE_first_tail_x4_L8_r0_body.cshift52 bodyNcl52 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_52] at this; exact this)


kernel_rfl bodyFramesEmpty52 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s1174 a).isEmpty) = true
kernel_rfl bodyJsRoots52 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1173.next) PRE_first_tail_x4_L8_r0_body.s1175.trace PRE_first_tail_x4_L8_r0_body.s1175 = true
kernel_rfl bodyJsNative52 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s1175.ffi) = true
kernel_rfl bodyLow52 : (PRE_first_tail_x4_L8_r0_body.cws52 ++ PRE_first_tail_x4_L8_r0_body.ws52).all (Nat.ble 9) = true
kernel_rfl bodyCntM52 : countersOkB PRE_first_tail_x4_L8_r0_body.s1173 PRE_first_tail_x4_L8_r0_body.s1174 = true
kernel_rfl bodyHi52 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1175.ffi).next setupP.E = true
kernel_rfl bodyNhi52 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1175.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge52 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1174.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s1173.ffi
kernel_rfl bodyNN52 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1173.ffi).nnext PRE_first_tail_x4_L8_r0_body.P52.NL = true
kernel_rfl bodyXn52 : Nat.ble (⟨21456, 18555, 2805501, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s1175.ffi).next = true
kernel_rfl bodyLo52 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s1175.ffi).next = true
theorem bodyFacts52 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s1173 PRE_first_tail_x4_L8_r0_body.s1174 PRE_first_tail_x4_L8_r0_body.s1175 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S1173 PRE_first_tail_x4_L8_r0_body.S1174 PRE_first_tail_x4_L8_r0_body.S1175
    PRE_first_tail_x4_L8_r0_body.ws52 PRE_first_tail_x4_L8_r0_body.cws52 PRE_first_tail_x4_L8_r0_body.nr52 PRE_first_tail_x4_L8_r0_body.pl52 PRE_first_tail_x4_L8_r0_body.cl52 2806650 15 PRE_first_tail_x4_L8_r0_body.kd52 PRE_first_tail_x4_L8_r0_body.kappa52 PRE_first_tail_x4_L8_r0_body.P52
    ⟨21453, 18528, 2805495, 15⟩ ⟨21456, 18555, 2805501, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap52
  clean := bodyClean52
  cfix := PRE_first_tail_x4_L8_r0_body.cfix52
  zpl := PRE_first_tail_x4_L8_r0_body.zpl52
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd52
  zn1 := PRE_first_tail_x4_L8_r0_body.zn152
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst52
  zscn := PRE_first_tail_x4_L8_r0_body.zscn52
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn52
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow52
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab52
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh52
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd52
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi52
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt52
  zgP := PRE_first_tail_x4_L8_r0_body.zg52_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk52_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm52_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg52_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk52_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm52_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw52_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw52_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap52
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd52
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap52 PRE_first_tail_x4_L8_r0_body.stFoot52 PRE_first_tail_x4_L8_r0_body.iso52 PRE_first_tail_x4_L8_r0_body.zwr52
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP52
  csupp := PRE_first_tail_x4_L8_r0_body.csupp52
  cbound := PRE_first_tail_x4_L8_r0_body.cbound52
  zimg := PRE_first_tail_x4_L8_r0_body.zimg52
  zctl := PRE_first_tail_x4_L8_r0_body.zctl52
  zstack := PRE_first_tail_x4_L8_r0_body.zstack52
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs52
  zstores := PRE_first_tail_x4_L8_r0_body.zstores52
  zroots := PRE_first_tail_x4_L8_r0_body.zroots52
  znC := PRE_first_tail_x4_L8_r0_body.znC52
  ctab := PRE_first_tail_x4_L8_r0_body.ctab52
  zbin := PRE_first_tail_x4_L8_r0_body.zbin52
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge52
  sbridge := bodyBridge52
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj52
  cshiftR := fun h hNL => bodyCshift52 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN52
  raised := PRE_first_tail_x4_L8_r0_body.raised52
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs52
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl52
  xnLe := Nat.le_of_ble_eq_true bodyXn52
  loLe := Nat.le_of_ble_eq_true bodyLo52
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB52
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
noncomputable def bodyEs52 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr52.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st52.S5.tab r
kernel_rfl bodyResChk52 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs52 bodyQs52) = true
kernel_rfl bodyLq52 : bodyQs52.length = PRE_first_tail_x4_L8_r0_body.cws52.length
kernel_rfl bodyNrLo52 : PRE_first_tail_x4_L8_r0_body.nr52.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S1173.tab.length) = true
kernel_rfl bodySub52 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site52.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost52 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws52 PRE_first_tail_x4_L8_r0_body.cws52 bodyQs52 = true
kernel_rfl bodyDrop52 : Nat.ble (53475 + (PRE_first_tail_x4_L8_r0_body.s1174.next - PRE_first_tail_x4_L8_r0_body.s1175.next)) 54624 = true
kernel_rfl bodyDropH52 : Nat.ble (1022 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1174.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s1175.ffi).next)) 1047 = true
kernel_rfl bodyDropN52 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1174.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s1175.ffi).nnext)) 0 = true
kernel_rfl bodyDv52 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws52
kernel_rfl bodyDe52 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr52.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st52.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl52 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold52 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws52).isNone && !PRE_first_tail_x4_L8_r0_body.ws52.contains v) = true
kernel_rfl bodyDfree52 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws52 ++ PRE_first_tail_x4_L8_r0_body.ws52).all fun w => e.noVar w) = true

theorem bodyStep52 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53475, 1022, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1173 PRE_first_tail_x4_L8_r0_body.S1173)
      (bodyCut NB T tk π i x0 bodyΘ ⟨54624, 1047, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1175 PRE_first_tail_x4_L8_r0_body.S1175) (11334 + 1) :=
  bodySite bodyFacts52.cfix bodyFacts52.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st52.S5.tab) (Es := bodyEs52) (qs := bodyQs52)
    (ok := PRE_first_tail_x4_L8_r0_body.st52.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site52 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts52
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site52 r hr) hi (MapOk.sub hm (sub_of_all bodySub52)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk52 r hr) hi hm ho hq)
    bodyLq52 rfl bodyNrLo52 (postSub_sound bodyPost52)
    (Nat.le_of_ble_eq_true bodyDrop52) (by decide) (Nat.le_of_ble_eq_true bodyDropH52) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN52) (by decide)
    bodyDv52 bodyDe52 bodyDl52 bodyDold52 bodyDfree52 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site53 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site53 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site53) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st53.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site53
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st53.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st53.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1195 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1196 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1195 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws53 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st53.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st53.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso53
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_53
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st53.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot53
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup53
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound53
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace53
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged53
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws53.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st53.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1195.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_53]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen53.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh53
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl53 : Conv.NClean (⟨21510, 18591, 2807733, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1195.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl53 (PRE_first_tail_x4_L8_r0_body.cncl52 bodyNcl52)

theorem bodyClean53 : Conv.JClean (⟨21510, 18591, 2807733, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s1195 :=
  PRE_first_tail_x4_L8_r0_body.gjcl53 (PRE_first_tail_x4_L8_r0_body.cjcl52 bodyClean52)

kernel_rfl bodyJsLe53 : Nat.ble PRE_first_tail_x4_L8_r0_body.s1173.next PRE_first_tail_x4_L8_r0_body.s1195.next = true
kernel_rfl bodyJsList53 : (PRE_first_tail_x4_L8_r0_body.gjh53 ++ PRE_first_tail_x4_L8_r0_body.cl53).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1195.next) PRE_first_tail_x4_L8_r0_body.s1197) = true
theorem bodyJs53 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s1195.next PRE_first_tail_x4_L8_r0_body.s1197 :=
  JsHeapAbove.glueSite bodyJs52 (Nat.le_of_ble_eq_true bodyJsLe53) PRE_first_tail_x4_L8_r0_body.gjk53 PRE_first_tail_x4_L8_r0_body.gjbd53 PRE_first_tail_x4_L8_r0_body.cheap53 PRE_first_tail_x4_L8_r0_body.zclbd53 bodyJsList53

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1175 : PRE_first_tail_x4_L8_r0_body.S1175.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1175.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1175 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1175.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc1175 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1175 PRE_first_tail_x4_L8_r0_body.S1175) = fun _ _ => true
kernel_rfl bodyAcc1176 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1176 PRE_first_tail_x4_L8_r0_body.S1176) = fun _ _ => true
kernel_rfl bodyBr1177 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1177.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1176 : isHalt PRE_first_tail_x4_L8_r0_body.s1176.ctl = false
kernel_rfl bodyTop1177 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1177 = true
kernel_rfl bodyCnt1175 : countersOkB PRE_first_tail_x4_L8_r0_body.s1175 PRE_first_tail_x4_L8_r0_body.s1177 = true
kernel_rfl bodyO1177 : PRE_first_tail_x4_L8_r0_body.S1177.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1177.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1178 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1178.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1177 : countersOkB PRE_first_tail_x4_L8_r0_body.s1177 PRE_first_tail_x4_L8_r0_body.s1178 = true
kernel_rfl bodyO1178 : PRE_first_tail_x4_L8_r0_body.S1178.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1178.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1178 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1178 PRE_first_tail_x4_L8_r0_body.S1178) = fun _ _ => true
kernel_rfl bodyAcc1182 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1182 PRE_first_tail_x4_L8_r0_body.S1182) = fun _ _ => true
kernel_rfl bodyBr1183 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1183.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1182 : isHalt PRE_first_tail_x4_L8_r0_body.s1182.ctl = false
kernel_rfl bodyTop1183 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1183 = true
kernel_rfl bodyCnt1178 : countersOkB PRE_first_tail_x4_L8_r0_body.s1178 PRE_first_tail_x4_L8_r0_body.s1183 = true
kernel_rfl bodyO1183 : PRE_first_tail_x4_L8_r0_body.S1183.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1183.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1184 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1184.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1183 : countersOkB PRE_first_tail_x4_L8_r0_body.s1183 PRE_first_tail_x4_L8_r0_body.s1184 = true
kernel_rfl bodyO1184 : PRE_first_tail_x4_L8_r0_body.S1184.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1184.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1184 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1184 PRE_first_tail_x4_L8_r0_body.S1184) = fun _ _ => true
kernel_rfl bodyAcc1185 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1185 PRE_first_tail_x4_L8_r0_body.S1185) = fun _ _ => true
kernel_rfl bodyBr1186 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1186.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1185 : isHalt PRE_first_tail_x4_L8_r0_body.s1185.ctl = false
kernel_rfl bodyTop1186 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1186 = true
kernel_rfl bodyCnt1184 : countersOkB PRE_first_tail_x4_L8_r0_body.s1184 PRE_first_tail_x4_L8_r0_body.s1186 = true
kernel_rfl bodyO1186 : PRE_first_tail_x4_L8_r0_body.S1186.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1186.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1187 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1187.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1186 : countersOkB PRE_first_tail_x4_L8_r0_body.s1186 PRE_first_tail_x4_L8_r0_body.s1187 = true
kernel_rfl bodyO1187 : PRE_first_tail_x4_L8_r0_body.S1187.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1187.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1187 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1187 PRE_first_tail_x4_L8_r0_body.S1187) = fun _ _ => true
kernel_rfl bodyAcc1188 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1188 PRE_first_tail_x4_L8_r0_body.S1188) = fun _ _ => true
kernel_rfl bodyBr1189 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1189.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1188 : isHalt PRE_first_tail_x4_L8_r0_body.s1188.ctl = false
kernel_rfl bodyTop1189 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1189 = true
kernel_rfl bodyCnt1187 : countersOkB PRE_first_tail_x4_L8_r0_body.s1187 PRE_first_tail_x4_L8_r0_body.s1189 = true
kernel_rfl bodyO1189 : PRE_first_tail_x4_L8_r0_body.S1189.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1189.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1190 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1190.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1189 : countersOkB PRE_first_tail_x4_L8_r0_body.s1189 PRE_first_tail_x4_L8_r0_body.s1190 = true
kernel_rfl bodyO1190 : PRE_first_tail_x4_L8_r0_body.S1190.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1190.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1190 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1190 PRE_first_tail_x4_L8_r0_body.S1190) = fun _ _ => true
kernel_rfl bodyAcc1191 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1191 PRE_first_tail_x4_L8_r0_body.S1191) = fun _ _ => true
kernel_rfl bodyBr1192 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1192.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1191 : isHalt PRE_first_tail_x4_L8_r0_body.s1191.ctl = false
kernel_rfl bodyTop1192 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1192 = true
kernel_rfl bodyCnt1190 : countersOkB PRE_first_tail_x4_L8_r0_body.s1190 PRE_first_tail_x4_L8_r0_body.s1192 = true
kernel_rfl bodyO1192 : PRE_first_tail_x4_L8_r0_body.S1192.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1192.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1193 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1193.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1192 : countersOkB PRE_first_tail_x4_L8_r0_body.s1192 PRE_first_tail_x4_L8_r0_body.s1193 = true
kernel_rfl bodyO1193 : PRE_first_tail_x4_L8_r0_body.S1193.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1193.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1193 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1193 PRE_first_tail_x4_L8_r0_body.S1193) = fun _ _ => true
kernel_rfl bodyAcc1194 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1194 PRE_first_tail_x4_L8_r0_body.S1194) = fun _ _ => true
kernel_rfl bodyBr1195 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1195.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1194 : isHalt PRE_first_tail_x4_L8_r0_body.s1194.ctl = false
kernel_rfl bodyTop1195 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1195 = true
kernel_rfl bodyCnt1193 : countersOkB PRE_first_tail_x4_L8_r0_body.s1193 PRE_first_tail_x4_L8_r0_body.s1195 = true

theorem bodyGlue53 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨54624, 1047, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1175 PRE_first_tail_x4_L8_r0_body.S1175)
      (bodyCut NB T tk π i x0 bodyΘ ⟨54624, 1047, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1195 PRE_first_tail_x4_L8_r0_body.S1195) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) bodyAcc1175 PRE_first_tail_x4_L8_r0_body.bodyRunSeg304 bodyAcc1176 bodyHalt1176 PRE_first_tail_x4_L8_r0_body.bodyStepA305 bodyTop1177 (fun _ hm => bodyO1175 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1175).trans bodyInactive0) (bodyBr1177.trans bodyBr1175.symm) bodyCnt1175 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA305 PRE_first_tail_x4_L8_r0_body.sizeArgsA305 PRE_first_tail_x4_L8_r0_body.sizeSymA305 PRE_first_tail_x4_L8_r0_body.sizeMlxA305 PRE_first_tail_x4_L8_r0_body.sizePayA305 PRE_first_tail_x4_L8_r0_body.sizeTaA305 PRE_first_tail_x4_L8_r0_body.sizeDecA305 PRE_first_tail_x4_L8_r0_body.sizePreA305 PRE_first_tail_x4_L8_r0_body.bodyPatchB305 (fun _ hm => bodyO1177 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1177).trans bodyInactive0) (bodyBr1178.trans bodyBr1177.symm) bodyCnt1177 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) bodyAcc1178 PRE_first_tail_x4_L8_r0_body.bodyRunSeg305 bodyAcc1182 bodyHalt1182 PRE_first_tail_x4_L8_r0_body.bodyStepA306 bodyTop1183 (fun _ hm => bodyO1178 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1178).trans bodyInactive0) (bodyBr1183.trans bodyBr1178.symm) bodyCnt1178 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA306 PRE_first_tail_x4_L8_r0_body.sizeArgsA306 PRE_first_tail_x4_L8_r0_body.sizeSymA306 PRE_first_tail_x4_L8_r0_body.sizeMlxA306 PRE_first_tail_x4_L8_r0_body.sizePayA306 PRE_first_tail_x4_L8_r0_body.sizeTaA306 PRE_first_tail_x4_L8_r0_body.sizeDecA306 PRE_first_tail_x4_L8_r0_body.sizePreA306 PRE_first_tail_x4_L8_r0_body.bodyPatchB306 (fun _ hm => bodyO1183 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1183).trans bodyInactive0) (bodyBr1184.trans bodyBr1183.symm) bodyCnt1183 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) bodyAcc1184 PRE_first_tail_x4_L8_r0_body.bodyRunSeg306 bodyAcc1185 bodyHalt1185 PRE_first_tail_x4_L8_r0_body.bodyStepA307 bodyTop1186 (fun _ hm => bodyO1184 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1184).trans bodyInactive0) (bodyBr1186.trans bodyBr1184.symm) bodyCnt1184 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA307 PRE_first_tail_x4_L8_r0_body.sizeArgsA307 PRE_first_tail_x4_L8_r0_body.sizeSymA307 PRE_first_tail_x4_L8_r0_body.sizeMlxA307 PRE_first_tail_x4_L8_r0_body.sizePayA307 PRE_first_tail_x4_L8_r0_body.sizeTaA307 PRE_first_tail_x4_L8_r0_body.sizeDecA307 PRE_first_tail_x4_L8_r0_body.sizePreA307 PRE_first_tail_x4_L8_r0_body.bodyPatchB307 (fun _ hm => bodyO1186 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1186).trans bodyInactive0) (bodyBr1187.trans bodyBr1186.symm) bodyCnt1186 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) bodyAcc1187 PRE_first_tail_x4_L8_r0_body.bodyRunSeg307 bodyAcc1188 bodyHalt1188 PRE_first_tail_x4_L8_r0_body.bodyStepA308 bodyTop1189 (fun _ hm => bodyO1187 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1187).trans bodyInactive0) (bodyBr1189.trans bodyBr1187.symm) bodyCnt1187 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA308 PRE_first_tail_x4_L8_r0_body.sizeArgsA308 PRE_first_tail_x4_L8_r0_body.sizeSymA308 PRE_first_tail_x4_L8_r0_body.sizeMlxA308 PRE_first_tail_x4_L8_r0_body.sizePayA308 PRE_first_tail_x4_L8_r0_body.sizeTaA308 PRE_first_tail_x4_L8_r0_body.sizeDecA308 PRE_first_tail_x4_L8_r0_body.sizePreA308 PRE_first_tail_x4_L8_r0_body.bodyPatchB308 (fun _ hm => bodyO1189 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1189).trans bodyInactive0) (bodyBr1190.trans bodyBr1189.symm) bodyCnt1189 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) bodyAcc1190 PRE_first_tail_x4_L8_r0_body.bodyRunSeg308 bodyAcc1191 bodyHalt1191 PRE_first_tail_x4_L8_r0_body.bodyStepA309 bodyTop1192 (fun _ hm => bodyO1190 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1190).trans bodyInactive0) (bodyBr1192.trans bodyBr1190.symm) bodyCnt1190 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA309 PRE_first_tail_x4_L8_r0_body.sizeArgsA309 PRE_first_tail_x4_L8_r0_body.sizeSymA309 PRE_first_tail_x4_L8_r0_body.sizeMlxA309 PRE_first_tail_x4_L8_r0_body.sizePayA309 PRE_first_tail_x4_L8_r0_body.sizeTaA309 PRE_first_tail_x4_L8_r0_body.sizeDecA309 PRE_first_tail_x4_L8_r0_body.sizePreA309 PRE_first_tail_x4_L8_r0_body.bodyPatchB309 (fun _ hm => bodyO1192 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1192).trans bodyInactive0) (bodyBr1193.trans bodyBr1192.symm) bodyCnt1192 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54624, 1047, 0, 0⟩) bodyAcc1193 PRE_first_tail_x4_L8_r0_body.bodyRunSeg309 bodyAcc1194 bodyHalt1194 PRE_first_tail_x4_L8_r0_body.bodyStepA310 bodyTop1195 (fun _ hm => bodyO1193 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1193).trans bodyInactive0) (bodyBr1195.trans bodyBr1193.symm) bodyCnt1193 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift53 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S1195.tab.length PRE_first_tail_x4_L8_r0_body.s1195.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P53.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P53 15 PRE_first_tail_x4_L8_r0_body.kappa53 PRE_first_tail_x4_L8_r0_body.s1197.ffi PRE_first_tail_x4_L8_r0_body.s1196.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_53
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_53
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1197.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S1195.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_53] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK53 PRE_first_tail_x4_L8_r0_body.cobjsK53
      PRE_first_tail_x4_L8_r0_body.citemsK53 PRE_first_tail_x4_L8_r0_body.cbd53 PRE_first_tail_x4_L8_r0_body.csst53
  exact PRE_first_tail_x4_L8_r0_body.cshift53 bodyNcl53 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_53] at this; exact this)


kernel_rfl bodyFramesEmpty53 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s1196 a).isEmpty) = true
kernel_rfl bodyJsRoots53 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1195.next) PRE_first_tail_x4_L8_r0_body.s1197.trace PRE_first_tail_x4_L8_r0_body.s1197 = true
kernel_rfl bodyJsNative53 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s1197.ffi) = true
kernel_rfl bodyLow53 : (PRE_first_tail_x4_L8_r0_body.cws53 ++ PRE_first_tail_x4_L8_r0_body.ws53).all (Nat.ble 9) = true
kernel_rfl bodyCntM53 : countersOkB PRE_first_tail_x4_L8_r0_body.s1195 PRE_first_tail_x4_L8_r0_body.s1196 = true
kernel_rfl bodyHi53 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1197.ffi).next setupP.E = true
kernel_rfl bodyNhi53 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1197.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge53 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1196.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s1195.ffi
kernel_rfl bodyNN53 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1195.ffi).nnext PRE_first_tail_x4_L8_r0_body.P53.NL = true
kernel_rfl bodyXn53 : Nat.ble (⟨21513, 18618, 2807739, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s1197.ffi).next = true
kernel_rfl bodyLo53 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s1197.ffi).next = true
theorem bodyFacts53 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s1195 PRE_first_tail_x4_L8_r0_body.s1196 PRE_first_tail_x4_L8_r0_body.s1197 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S1195 PRE_first_tail_x4_L8_r0_body.S1196 PRE_first_tail_x4_L8_r0_body.S1197
    PRE_first_tail_x4_L8_r0_body.ws53 PRE_first_tail_x4_L8_r0_body.cws53 PRE_first_tail_x4_L8_r0_body.nr53 PRE_first_tail_x4_L8_r0_body.pl53 PRE_first_tail_x4_L8_r0_body.cl53 2808888 15 PRE_first_tail_x4_L8_r0_body.kd53 PRE_first_tail_x4_L8_r0_body.kappa53 PRE_first_tail_x4_L8_r0_body.P53
    ⟨21510, 18591, 2807733, 15⟩ ⟨21513, 18618, 2807739, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap53
  clean := bodyClean53
  cfix := PRE_first_tail_x4_L8_r0_body.cfix53
  zpl := PRE_first_tail_x4_L8_r0_body.zpl53
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd53
  zn1 := PRE_first_tail_x4_L8_r0_body.zn153
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst53
  zscn := PRE_first_tail_x4_L8_r0_body.zscn53
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn53
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow53
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab53
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh53
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd53
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi53
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt53
  zgP := PRE_first_tail_x4_L8_r0_body.zg53_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk53_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm53_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg53_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk53_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm53_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw53_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw53_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap53
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd53
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap53 PRE_first_tail_x4_L8_r0_body.stFoot53 PRE_first_tail_x4_L8_r0_body.iso53 PRE_first_tail_x4_L8_r0_body.zwr53
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP53
  csupp := PRE_first_tail_x4_L8_r0_body.csupp53
  cbound := PRE_first_tail_x4_L8_r0_body.cbound53
  zimg := PRE_first_tail_x4_L8_r0_body.zimg53
  zctl := PRE_first_tail_x4_L8_r0_body.zctl53
  zstack := PRE_first_tail_x4_L8_r0_body.zstack53
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs53
  zstores := PRE_first_tail_x4_L8_r0_body.zstores53
  zroots := PRE_first_tail_x4_L8_r0_body.zroots53
  znC := PRE_first_tail_x4_L8_r0_body.znC53
  ctab := PRE_first_tail_x4_L8_r0_body.ctab53
  zbin := PRE_first_tail_x4_L8_r0_body.zbin53
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge53
  sbridge := bodyBridge53
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj53
  cshiftR := fun h hNL => bodyCshift53 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN53
  raised := PRE_first_tail_x4_L8_r0_body.raised53
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs53
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl53
  xnLe := Nat.le_of_ble_eq_true bodyXn53
  loLe := Nat.le_of_ble_eq_true bodyLo53
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB53
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
noncomputable def bodyEs53 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr53.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st53.S5.tab r
kernel_rfl bodyResChk53 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs53 bodyQs53) = true
kernel_rfl bodyLq53 : bodyQs53.length = PRE_first_tail_x4_L8_r0_body.cws53.length
kernel_rfl bodyNrLo53 : PRE_first_tail_x4_L8_r0_body.nr53.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S1195.tab.length) = true
kernel_rfl bodySub53 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site53.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost53 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws53 PRE_first_tail_x4_L8_r0_body.cws53 bodyQs53 = true
kernel_rfl bodyDrop53 : Nat.ble (54624 + (PRE_first_tail_x4_L8_r0_body.s1196.next - PRE_first_tail_x4_L8_r0_body.s1197.next)) 55773 = true
kernel_rfl bodyDropH53 : Nat.ble (1047 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1196.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s1197.ffi).next)) 1072 = true
kernel_rfl bodyDropN53 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1196.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s1197.ffi).nnext)) 0 = true
kernel_rfl bodyDv53 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws53
kernel_rfl bodyDe53 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr53.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st53.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl53 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold53 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws53).isNone && !PRE_first_tail_x4_L8_r0_body.ws53.contains v) = true
kernel_rfl bodyDfree53 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws53 ++ PRE_first_tail_x4_L8_r0_body.ws53).all fun w => e.noVar w) = true

theorem bodyStep53 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨54624, 1047, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1195 PRE_first_tail_x4_L8_r0_body.S1195)
      (bodyCut NB T tk π i x0 bodyΘ ⟨55773, 1072, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1197 PRE_first_tail_x4_L8_r0_body.S1197) (11334 + 1) :=
  bodySite bodyFacts53.cfix bodyFacts53.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st53.S5.tab) (Es := bodyEs53) (qs := bodyQs53)
    (ok := PRE_first_tail_x4_L8_r0_body.st53.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site53 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts53
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site53 r hr) hi (MapOk.sub hm (sub_of_all bodySub53)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk53 r hr) hi hm ho hq)
    bodyLq53 rfl bodyNrLo53 (postSub_sound bodyPost53)
    (Nat.le_of_ble_eq_true bodyDrop53) (by decide) (Nat.le_of_ble_eq_true bodyDropH53) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN53) (by decide)
    bodyDv53 bodyDe53 bodyDl53 bodyDold53 bodyDfree53 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site54 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site54 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site54) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st54.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site54
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st54.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st54.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1217 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1218 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1217 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws54 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st54.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st54.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso54
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_54
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st54.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot54
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup54
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound54
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace54
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged54
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws54.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st54.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1217.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_54]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen54.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh54
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl54 : Conv.NClean (⟨21567, 18654, 2809971, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1217.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl54 (PRE_first_tail_x4_L8_r0_body.cncl53 bodyNcl53)

theorem bodyClean54 : Conv.JClean (⟨21567, 18654, 2809971, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s1217 :=
  PRE_first_tail_x4_L8_r0_body.gjcl54 (PRE_first_tail_x4_L8_r0_body.cjcl53 bodyClean53)

kernel_rfl bodyJsLe54 : Nat.ble PRE_first_tail_x4_L8_r0_body.s1195.next PRE_first_tail_x4_L8_r0_body.s1217.next = true
kernel_rfl bodyJsList54 : (PRE_first_tail_x4_L8_r0_body.gjh54 ++ PRE_first_tail_x4_L8_r0_body.cl54).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1217.next) PRE_first_tail_x4_L8_r0_body.s1219) = true
theorem bodyJs54 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s1217.next PRE_first_tail_x4_L8_r0_body.s1219 :=
  JsHeapAbove.glueSite bodyJs53 (Nat.le_of_ble_eq_true bodyJsLe54) PRE_first_tail_x4_L8_r0_body.gjk54 PRE_first_tail_x4_L8_r0_body.gjbd54 PRE_first_tail_x4_L8_r0_body.cheap54 PRE_first_tail_x4_L8_r0_body.zclbd54 bodyJsList54

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1197 : PRE_first_tail_x4_L8_r0_body.S1197.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1197.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1197 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1197.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc1197 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1197 PRE_first_tail_x4_L8_r0_body.S1197) = fun _ _ => true
kernel_rfl bodyAcc1198 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1198 PRE_first_tail_x4_L8_r0_body.S1198) = fun _ _ => true
kernel_rfl bodyBr1199 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1199.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1198 : isHalt PRE_first_tail_x4_L8_r0_body.s1198.ctl = false
kernel_rfl bodyTop1199 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1199 = true
kernel_rfl bodyCnt1197 : countersOkB PRE_first_tail_x4_L8_r0_body.s1197 PRE_first_tail_x4_L8_r0_body.s1199 = true
kernel_rfl bodyO1199 : PRE_first_tail_x4_L8_r0_body.S1199.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1199.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1200 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1200.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1199 : countersOkB PRE_first_tail_x4_L8_r0_body.s1199 PRE_first_tail_x4_L8_r0_body.s1200 = true
kernel_rfl bodyO1200 : PRE_first_tail_x4_L8_r0_body.S1200.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1200.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1200 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1200 PRE_first_tail_x4_L8_r0_body.S1200) = fun _ _ => true
kernel_rfl bodyAcc1204 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1204 PRE_first_tail_x4_L8_r0_body.S1204) = fun _ _ => true
kernel_rfl bodyBr1205 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1205.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1204 : isHalt PRE_first_tail_x4_L8_r0_body.s1204.ctl = false
kernel_rfl bodyTop1205 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1205 = true
kernel_rfl bodyCnt1200 : countersOkB PRE_first_tail_x4_L8_r0_body.s1200 PRE_first_tail_x4_L8_r0_body.s1205 = true
kernel_rfl bodyO1205 : PRE_first_tail_x4_L8_r0_body.S1205.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1205.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1206 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1206.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1205 : countersOkB PRE_first_tail_x4_L8_r0_body.s1205 PRE_first_tail_x4_L8_r0_body.s1206 = true
kernel_rfl bodyO1206 : PRE_first_tail_x4_L8_r0_body.S1206.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1206.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1206 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1206 PRE_first_tail_x4_L8_r0_body.S1206) = fun _ _ => true
kernel_rfl bodyAcc1207 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1207 PRE_first_tail_x4_L8_r0_body.S1207) = fun _ _ => true
kernel_rfl bodyBr1208 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1208.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1207 : isHalt PRE_first_tail_x4_L8_r0_body.s1207.ctl = false
kernel_rfl bodyTop1208 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1208 = true
kernel_rfl bodyCnt1206 : countersOkB PRE_first_tail_x4_L8_r0_body.s1206 PRE_first_tail_x4_L8_r0_body.s1208 = true
kernel_rfl bodyO1208 : PRE_first_tail_x4_L8_r0_body.S1208.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1208.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1209 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1209.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1208 : countersOkB PRE_first_tail_x4_L8_r0_body.s1208 PRE_first_tail_x4_L8_r0_body.s1209 = true
kernel_rfl bodyO1209 : PRE_first_tail_x4_L8_r0_body.S1209.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1209.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1209 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1209 PRE_first_tail_x4_L8_r0_body.S1209) = fun _ _ => true
kernel_rfl bodyAcc1210 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1210 PRE_first_tail_x4_L8_r0_body.S1210) = fun _ _ => true
kernel_rfl bodyBr1211 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1211.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1210 : isHalt PRE_first_tail_x4_L8_r0_body.s1210.ctl = false
kernel_rfl bodyTop1211 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1211 = true
kernel_rfl bodyCnt1209 : countersOkB PRE_first_tail_x4_L8_r0_body.s1209 PRE_first_tail_x4_L8_r0_body.s1211 = true
kernel_rfl bodyO1211 : PRE_first_tail_x4_L8_r0_body.S1211.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1211.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1212 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1212.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1211 : countersOkB PRE_first_tail_x4_L8_r0_body.s1211 PRE_first_tail_x4_L8_r0_body.s1212 = true
kernel_rfl bodyO1212 : PRE_first_tail_x4_L8_r0_body.S1212.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1212.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1212 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1212 PRE_first_tail_x4_L8_r0_body.S1212) = fun _ _ => true
kernel_rfl bodyAcc1213 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1213 PRE_first_tail_x4_L8_r0_body.S1213) = fun _ _ => true
kernel_rfl bodyBr1214 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1214.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1213 : isHalt PRE_first_tail_x4_L8_r0_body.s1213.ctl = false
kernel_rfl bodyTop1214 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1214 = true
kernel_rfl bodyCnt1212 : countersOkB PRE_first_tail_x4_L8_r0_body.s1212 PRE_first_tail_x4_L8_r0_body.s1214 = true
kernel_rfl bodyO1214 : PRE_first_tail_x4_L8_r0_body.S1214.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1214.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1215 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1215.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1214 : countersOkB PRE_first_tail_x4_L8_r0_body.s1214 PRE_first_tail_x4_L8_r0_body.s1215 = true
kernel_rfl bodyO1215 : PRE_first_tail_x4_L8_r0_body.S1215.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1215.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1215 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1215 PRE_first_tail_x4_L8_r0_body.S1215) = fun _ _ => true
kernel_rfl bodyAcc1216 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1216 PRE_first_tail_x4_L8_r0_body.S1216) = fun _ _ => true
kernel_rfl bodyBr1217 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1217.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1216 : isHalt PRE_first_tail_x4_L8_r0_body.s1216.ctl = false
kernel_rfl bodyTop1217 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1217 = true
kernel_rfl bodyCnt1215 : countersOkB PRE_first_tail_x4_L8_r0_body.s1215 PRE_first_tail_x4_L8_r0_body.s1217 = true

theorem bodyGlue54 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨55773, 1072, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1197 PRE_first_tail_x4_L8_r0_body.S1197)
      (bodyCut NB T tk π i x0 bodyΘ ⟨55773, 1072, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1217 PRE_first_tail_x4_L8_r0_body.S1217) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) bodyAcc1197 PRE_first_tail_x4_L8_r0_body.bodyRunSeg310 bodyAcc1198 bodyHalt1198 PRE_first_tail_x4_L8_r0_body.bodyStepA311 bodyTop1199 (fun _ hm => bodyO1197 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1197).trans bodyInactive0) (bodyBr1199.trans bodyBr1197.symm) bodyCnt1197 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA311 PRE_first_tail_x4_L8_r0_body.sizeArgsA311 PRE_first_tail_x4_L8_r0_body.sizeSymA311 PRE_first_tail_x4_L8_r0_body.sizeMlxA311 PRE_first_tail_x4_L8_r0_body.sizePayA311 PRE_first_tail_x4_L8_r0_body.sizeTaA311 PRE_first_tail_x4_L8_r0_body.sizeDecA311 PRE_first_tail_x4_L8_r0_body.sizePreA311 PRE_first_tail_x4_L8_r0_body.bodyPatchB311 (fun _ hm => bodyO1199 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1199).trans bodyInactive0) (bodyBr1200.trans bodyBr1199.symm) bodyCnt1199 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) bodyAcc1200 PRE_first_tail_x4_L8_r0_body.bodyRunSeg311 bodyAcc1204 bodyHalt1204 PRE_first_tail_x4_L8_r0_body.bodyStepA312 bodyTop1205 (fun _ hm => bodyO1200 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1200).trans bodyInactive0) (bodyBr1205.trans bodyBr1200.symm) bodyCnt1200 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA312 PRE_first_tail_x4_L8_r0_body.sizeArgsA312 PRE_first_tail_x4_L8_r0_body.sizeSymA312 PRE_first_tail_x4_L8_r0_body.sizeMlxA312 PRE_first_tail_x4_L8_r0_body.sizePayA312 PRE_first_tail_x4_L8_r0_body.sizeTaA312 PRE_first_tail_x4_L8_r0_body.sizeDecA312 PRE_first_tail_x4_L8_r0_body.sizePreA312 PRE_first_tail_x4_L8_r0_body.bodyPatchB312 (fun _ hm => bodyO1205 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1205).trans bodyInactive0) (bodyBr1206.trans bodyBr1205.symm) bodyCnt1205 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) bodyAcc1206 PRE_first_tail_x4_L8_r0_body.bodyRunSeg312 bodyAcc1207 bodyHalt1207 PRE_first_tail_x4_L8_r0_body.bodyStepA313 bodyTop1208 (fun _ hm => bodyO1206 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1206).trans bodyInactive0) (bodyBr1208.trans bodyBr1206.symm) bodyCnt1206 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA313 PRE_first_tail_x4_L8_r0_body.sizeArgsA313 PRE_first_tail_x4_L8_r0_body.sizeSymA313 PRE_first_tail_x4_L8_r0_body.sizeMlxA313 PRE_first_tail_x4_L8_r0_body.sizePayA313 PRE_first_tail_x4_L8_r0_body.sizeTaA313 PRE_first_tail_x4_L8_r0_body.sizeDecA313 PRE_first_tail_x4_L8_r0_body.sizePreA313 PRE_first_tail_x4_L8_r0_body.bodyPatchB313 (fun _ hm => bodyO1208 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1208).trans bodyInactive0) (bodyBr1209.trans bodyBr1208.symm) bodyCnt1208 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) bodyAcc1209 PRE_first_tail_x4_L8_r0_body.bodyRunSeg313 bodyAcc1210 bodyHalt1210 PRE_first_tail_x4_L8_r0_body.bodyStepA314 bodyTop1211 (fun _ hm => bodyO1209 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1209).trans bodyInactive0) (bodyBr1211.trans bodyBr1209.symm) bodyCnt1209 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA314 PRE_first_tail_x4_L8_r0_body.sizeArgsA314 PRE_first_tail_x4_L8_r0_body.sizeSymA314 PRE_first_tail_x4_L8_r0_body.sizeMlxA314 PRE_first_tail_x4_L8_r0_body.sizePayA314 PRE_first_tail_x4_L8_r0_body.sizeTaA314 PRE_first_tail_x4_L8_r0_body.sizeDecA314 PRE_first_tail_x4_L8_r0_body.sizePreA314 PRE_first_tail_x4_L8_r0_body.bodyPatchB314 (fun _ hm => bodyO1211 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1211).trans bodyInactive0) (bodyBr1212.trans bodyBr1211.symm) bodyCnt1211 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) bodyAcc1212 PRE_first_tail_x4_L8_r0_body.bodyRunSeg314 bodyAcc1213 bodyHalt1213 PRE_first_tail_x4_L8_r0_body.bodyStepA315 bodyTop1214 (fun _ hm => bodyO1212 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1212).trans bodyInactive0) (bodyBr1214.trans bodyBr1212.symm) bodyCnt1212 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA315 PRE_first_tail_x4_L8_r0_body.sizeArgsA315 PRE_first_tail_x4_L8_r0_body.sizeSymA315 PRE_first_tail_x4_L8_r0_body.sizeMlxA315 PRE_first_tail_x4_L8_r0_body.sizePayA315 PRE_first_tail_x4_L8_r0_body.sizeTaA315 PRE_first_tail_x4_L8_r0_body.sizeDecA315 PRE_first_tail_x4_L8_r0_body.sizePreA315 PRE_first_tail_x4_L8_r0_body.bodyPatchB315 (fun _ hm => bodyO1214 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1214).trans bodyInactive0) (bodyBr1215.trans bodyBr1214.symm) bodyCnt1214 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55773, 1072, 0, 0⟩) bodyAcc1215 PRE_first_tail_x4_L8_r0_body.bodyRunSeg315 bodyAcc1216 bodyHalt1216 PRE_first_tail_x4_L8_r0_body.bodyStepA316 bodyTop1217 (fun _ hm => bodyO1215 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1215).trans bodyInactive0) (bodyBr1217.trans bodyBr1215.symm) bodyCnt1215 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift54 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S1217.tab.length PRE_first_tail_x4_L8_r0_body.s1217.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P54.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P54 15 PRE_first_tail_x4_L8_r0_body.kappa54 PRE_first_tail_x4_L8_r0_body.s1219.ffi PRE_first_tail_x4_L8_r0_body.s1218.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_54
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_54
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1219.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S1217.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_54] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK54 PRE_first_tail_x4_L8_r0_body.cobjsK54
      PRE_first_tail_x4_L8_r0_body.citemsK54 PRE_first_tail_x4_L8_r0_body.cbd54 PRE_first_tail_x4_L8_r0_body.csst54
  exact PRE_first_tail_x4_L8_r0_body.cshift54 bodyNcl54 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_54] at this; exact this)


kernel_rfl bodyFramesEmpty54 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s1218 a).isEmpty) = true
kernel_rfl bodyJsRoots54 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1217.next) PRE_first_tail_x4_L8_r0_body.s1219.trace PRE_first_tail_x4_L8_r0_body.s1219 = true
kernel_rfl bodyJsNative54 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s1219.ffi) = true
kernel_rfl bodyLow54 : (PRE_first_tail_x4_L8_r0_body.cws54 ++ PRE_first_tail_x4_L8_r0_body.ws54).all (Nat.ble 9) = true
kernel_rfl bodyCntM54 : countersOkB PRE_first_tail_x4_L8_r0_body.s1217 PRE_first_tail_x4_L8_r0_body.s1218 = true
kernel_rfl bodyHi54 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1219.ffi).next setupP.E = true
kernel_rfl bodyNhi54 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1219.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge54 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1218.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s1217.ffi
kernel_rfl bodyNN54 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1217.ffi).nnext PRE_first_tail_x4_L8_r0_body.P54.NL = true
kernel_rfl bodyXn54 : Nat.ble (⟨21570, 18681, 2809977, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s1219.ffi).next = true
kernel_rfl bodyLo54 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s1219.ffi).next = true
theorem bodyFacts54 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s1217 PRE_first_tail_x4_L8_r0_body.s1218 PRE_first_tail_x4_L8_r0_body.s1219 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S1217 PRE_first_tail_x4_L8_r0_body.S1218 PRE_first_tail_x4_L8_r0_body.S1219
    PRE_first_tail_x4_L8_r0_body.ws54 PRE_first_tail_x4_L8_r0_body.cws54 PRE_first_tail_x4_L8_r0_body.nr54 PRE_first_tail_x4_L8_r0_body.pl54 PRE_first_tail_x4_L8_r0_body.cl54 2811126 15 PRE_first_tail_x4_L8_r0_body.kd54 PRE_first_tail_x4_L8_r0_body.kappa54 PRE_first_tail_x4_L8_r0_body.P54
    ⟨21567, 18654, 2809971, 15⟩ ⟨21570, 18681, 2809977, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap54
  clean := bodyClean54
  cfix := PRE_first_tail_x4_L8_r0_body.cfix54
  zpl := PRE_first_tail_x4_L8_r0_body.zpl54
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd54
  zn1 := PRE_first_tail_x4_L8_r0_body.zn154
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst54
  zscn := PRE_first_tail_x4_L8_r0_body.zscn54
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn54
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow54
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab54
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh54
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd54
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi54
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt54
  zgP := PRE_first_tail_x4_L8_r0_body.zg54_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk54_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm54_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg54_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk54_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm54_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw54_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw54_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap54
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd54
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap54 PRE_first_tail_x4_L8_r0_body.stFoot54 PRE_first_tail_x4_L8_r0_body.iso54 PRE_first_tail_x4_L8_r0_body.zwr54
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP54
  csupp := PRE_first_tail_x4_L8_r0_body.csupp54
  cbound := PRE_first_tail_x4_L8_r0_body.cbound54
  zimg := PRE_first_tail_x4_L8_r0_body.zimg54
  zctl := PRE_first_tail_x4_L8_r0_body.zctl54
  zstack := PRE_first_tail_x4_L8_r0_body.zstack54
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs54
  zstores := PRE_first_tail_x4_L8_r0_body.zstores54
  zroots := PRE_first_tail_x4_L8_r0_body.zroots54
  znC := PRE_first_tail_x4_L8_r0_body.znC54
  ctab := PRE_first_tail_x4_L8_r0_body.ctab54
  zbin := PRE_first_tail_x4_L8_r0_body.zbin54
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge54
  sbridge := bodyBridge54
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj54
  cshiftR := fun h hNL => bodyCshift54 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN54
  raised := PRE_first_tail_x4_L8_r0_body.raised54
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs54
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl54
  xnLe := Nat.le_of_ble_eq_true bodyXn54
  loLe := Nat.le_of_ble_eq_true bodyLo54
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB54
  cntM := bodyCntM54
  hiLe := Nat.le_of_ble_eq_true bodyHi54
  nhiLe := Nat.le_of_ble_eq_true bodyNhi54
  jsHeap := bodyJs54
  jsRoots := bodyJsRoots54
  jsNative := bodyJsNative54
  framesEmpty := bodyFramesEmpty54
  trailOld := by decide
  lowVars := bodyLow54

def bodyQs54 : List (Option Q) := []
noncomputable def bodyEs54 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr54.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st54.S5.tab r
kernel_rfl bodyResChk54 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs54 bodyQs54) = true
kernel_rfl bodyLq54 : bodyQs54.length = PRE_first_tail_x4_L8_r0_body.cws54.length
kernel_rfl bodyNrLo54 : PRE_first_tail_x4_L8_r0_body.nr54.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S1217.tab.length) = true
kernel_rfl bodySub54 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site54.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost54 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws54 PRE_first_tail_x4_L8_r0_body.cws54 bodyQs54 = true
kernel_rfl bodyDrop54 : Nat.ble (55773 + (PRE_first_tail_x4_L8_r0_body.s1218.next - PRE_first_tail_x4_L8_r0_body.s1219.next)) 56922 = true
kernel_rfl bodyDropH54 : Nat.ble (1072 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1218.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s1219.ffi).next)) 1097 = true
kernel_rfl bodyDropN54 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1218.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s1219.ffi).nnext)) 0 = true
kernel_rfl bodyDv54 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws54
kernel_rfl bodyDe54 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr54.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st54.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl54 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold54 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws54).isNone && !PRE_first_tail_x4_L8_r0_body.ws54.contains v) = true
kernel_rfl bodyDfree54 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws54 ++ PRE_first_tail_x4_L8_r0_body.ws54).all fun w => e.noVar w) = true

theorem bodyStep54 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨55773, 1072, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1217 PRE_first_tail_x4_L8_r0_body.S1217)
      (bodyCut NB T tk π i x0 bodyΘ ⟨56922, 1097, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1219 PRE_first_tail_x4_L8_r0_body.S1219) (11334 + 1) :=
  bodySite bodyFacts54.cfix bodyFacts54.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st54.S5.tab) (Es := bodyEs54) (qs := bodyQs54)
    (ok := PRE_first_tail_x4_L8_r0_body.st54.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site54 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts54
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site54 r hr) hi (MapOk.sub hm (sub_of_all bodySub54)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk54 r hr) hi hm ho hq)
    bodyLq54 rfl bodyNrLo54 (postSub_sound bodyPost54)
    (Nat.le_of_ble_eq_true bodyDrop54) (by decide) (Nat.le_of_ble_eq_true bodyDropH54) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN54) (by decide)
    bodyDv54 bodyDe54 bodyDl54 bodyDold54 bodyDfree54 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site55 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site55 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site55) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st55.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site55
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st55.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st55.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1238 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s1239 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1238 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws55 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st55.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st55.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso55
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_55
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st55.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot55
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup55
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound55
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace55
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged55
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws55.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st55.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S1238.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_55]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen55.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh55
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl55 : Conv.NClean (⟨21630, 18726, 2812478, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1238.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl55 (PRE_first_tail_x4_L8_r0_body.cncl54 bodyNcl54)

theorem bodyClean55 : Conv.JClean (⟨21630, 18726, 2812478, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s1238 :=
  PRE_first_tail_x4_L8_r0_body.gjcl55 (PRE_first_tail_x4_L8_r0_body.cjcl54 bodyClean54)

kernel_rfl bodyJsLe55 : Nat.ble PRE_first_tail_x4_L8_r0_body.s1217.next PRE_first_tail_x4_L8_r0_body.s1238.next = true
kernel_rfl bodyJsList55 : (PRE_first_tail_x4_L8_r0_body.gjh55 ++ PRE_first_tail_x4_L8_r0_body.cl55).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1238.next) PRE_first_tail_x4_L8_r0_body.s1240) = true
theorem bodyJs55 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s1238.next PRE_first_tail_x4_L8_r0_body.s1240 :=
  JsHeapAbove.glueSite bodyJs54 (Nat.le_of_ble_eq_true bodyJsLe55) PRE_first_tail_x4_L8_r0_body.gjk55 PRE_first_tail_x4_L8_r0_body.gjbd55 PRE_first_tail_x4_L8_r0_body.cheap55 PRE_first_tail_x4_L8_r0_body.zclbd55 bodyJsList55

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1219 : PRE_first_tail_x4_L8_r0_body.S1219.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1219.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1219 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1219.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc1219 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1219 PRE_first_tail_x4_L8_r0_body.S1219) = fun _ _ => true
kernel_rfl bodyAcc1220 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1220 PRE_first_tail_x4_L8_r0_body.S1220) = fun _ _ => true
kernel_rfl bodyBr1221 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1221.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1220 : isHalt PRE_first_tail_x4_L8_r0_body.s1220.ctl = false
kernel_rfl bodyTop1221 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1221 = true
kernel_rfl bodyCnt1219 : countersOkB PRE_first_tail_x4_L8_r0_body.s1219 PRE_first_tail_x4_L8_r0_body.s1221 = true
kernel_rfl bodyO1221 : PRE_first_tail_x4_L8_r0_body.S1221.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1221.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1222 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1222.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1221 : countersOkB PRE_first_tail_x4_L8_r0_body.s1221 PRE_first_tail_x4_L8_r0_body.s1222 = true
kernel_rfl bodyO1222 : PRE_first_tail_x4_L8_r0_body.S1222.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1222.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1222 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1222 PRE_first_tail_x4_L8_r0_body.S1222) = fun _ _ => true
kernel_rfl bodyAcc1226 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1226 PRE_first_tail_x4_L8_r0_body.S1226) = fun _ _ => true
kernel_rfl bodyBr1227 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1227.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1226 : isHalt PRE_first_tail_x4_L8_r0_body.s1226.ctl = false
kernel_rfl bodyTop1227 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1227 = true
kernel_rfl bodyCnt1222 : countersOkB PRE_first_tail_x4_L8_r0_body.s1222 PRE_first_tail_x4_L8_r0_body.s1227 = true
kernel_rfl bodyO1227 : PRE_first_tail_x4_L8_r0_body.S1227.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1227.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1228 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1228.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1227 : countersOkB PRE_first_tail_x4_L8_r0_body.s1227 PRE_first_tail_x4_L8_r0_body.s1228 = true
kernel_rfl bodyO1228 : PRE_first_tail_x4_L8_r0_body.S1228.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1228.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1228 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1228 PRE_first_tail_x4_L8_r0_body.S1228) = fun _ _ => true
kernel_rfl bodyAcc1230 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1230 PRE_first_tail_x4_L8_r0_body.S1230) = fun _ _ => true
kernel_rfl bodyBr1231 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1231.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1230 : isHalt PRE_first_tail_x4_L8_r0_body.s1230.ctl = false
kernel_rfl bodyTop1231 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1231 = true
kernel_rfl bodyCnt1228 : countersOkB PRE_first_tail_x4_L8_r0_body.s1228 PRE_first_tail_x4_L8_r0_body.s1231 = true
kernel_rfl bodyO1231 : PRE_first_tail_x4_L8_r0_body.S1231.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1231.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1232 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1232.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1231 : countersOkB PRE_first_tail_x4_L8_r0_body.s1231 PRE_first_tail_x4_L8_r0_body.s1232 = true
kernel_rfl bodyO1232 : PRE_first_tail_x4_L8_r0_body.S1232.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1232.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1232 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1232 PRE_first_tail_x4_L8_r0_body.S1232) = fun _ _ => true
kernel_rfl bodyAcc1233 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1233 PRE_first_tail_x4_L8_r0_body.S1233) = fun _ _ => true
kernel_rfl bodyBr1234 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1234.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1233 : isHalt PRE_first_tail_x4_L8_r0_body.s1233.ctl = false
kernel_rfl bodyTop1234 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1234 = true
kernel_rfl bodyCnt1232 : countersOkB PRE_first_tail_x4_L8_r0_body.s1232 PRE_first_tail_x4_L8_r0_body.s1234 = true
kernel_rfl bodyO1234 : PRE_first_tail_x4_L8_r0_body.S1234.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1234.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr1235 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1235.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt1234 : countersOkB PRE_first_tail_x4_L8_r0_body.s1234 PRE_first_tail_x4_L8_r0_body.s1235 = true
kernel_rfl bodyO1235 : PRE_first_tail_x4_L8_r0_body.S1235.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S1235.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc1235 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1235 PRE_first_tail_x4_L8_r0_body.S1235) = fun _ _ => true
kernel_rfl bodyAcc1237 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s1237 PRE_first_tail_x4_L8_r0_body.S1237) = fun _ _ => true
kernel_rfl bodyBr1238 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1238.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt1237 : isHalt PRE_first_tail_x4_L8_r0_body.s1237.ctl = false
kernel_rfl bodyTop1238 : noRetBlock PRE_first_tail_x4_L8_r0_body.s1238 = true
kernel_rfl bodyCnt1235 : countersOkB PRE_first_tail_x4_L8_r0_body.s1235 PRE_first_tail_x4_L8_r0_body.s1238 = true

theorem bodyGlue55 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨56922, 1097, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1219 PRE_first_tail_x4_L8_r0_body.S1219)
      (bodyCut NB T tk π i x0 bodyΘ ⟨56922, 1097, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1238 PRE_first_tail_x4_L8_r0_body.S1238) 24727 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) bodyAcc1219 PRE_first_tail_x4_L8_r0_body.bodyRunSeg316 bodyAcc1220 bodyHalt1220 PRE_first_tail_x4_L8_r0_body.bodyStepA317 bodyTop1221 (fun _ hm => bodyO1219 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1219).trans bodyInactive0) (bodyBr1221.trans bodyBr1219.symm) bodyCnt1219 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA317 PRE_first_tail_x4_L8_r0_body.sizeArgsA317 PRE_first_tail_x4_L8_r0_body.sizeSymA317 PRE_first_tail_x4_L8_r0_body.sizeMlxA317 PRE_first_tail_x4_L8_r0_body.sizePayA317 PRE_first_tail_x4_L8_r0_body.sizeTaA317 PRE_first_tail_x4_L8_r0_body.sizeDecA317 PRE_first_tail_x4_L8_r0_body.sizePreA317 PRE_first_tail_x4_L8_r0_body.bodyPatchB317 (fun _ hm => bodyO1221 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1221).trans bodyInactive0) (bodyBr1222.trans bodyBr1221.symm) bodyCnt1221 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) bodyAcc1222 PRE_first_tail_x4_L8_r0_body.bodyRunSeg317 bodyAcc1226 bodyHalt1226 PRE_first_tail_x4_L8_r0_body.bodyStepA318 bodyTop1227 (fun _ hm => bodyO1222 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1222).trans bodyInactive0) (bodyBr1227.trans bodyBr1222.symm) bodyCnt1222 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA318 PRE_first_tail_x4_L8_r0_body.sizeArgsA318 PRE_first_tail_x4_L8_r0_body.sizeSymA318 PRE_first_tail_x4_L8_r0_body.sizeMlxA318 PRE_first_tail_x4_L8_r0_body.sizePayA318 PRE_first_tail_x4_L8_r0_body.sizeTaA318 PRE_first_tail_x4_L8_r0_body.sizeDecA318 PRE_first_tail_x4_L8_r0_body.sizePreA318 PRE_first_tail_x4_L8_r0_body.bodyPatchB318 (fun _ hm => bodyO1227 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1227).trans bodyInactive0) (bodyBr1228.trans bodyBr1227.symm) bodyCnt1227 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) bodyAcc1228 PRE_first_tail_x4_L8_r0_body.bodyRunSeg318 bodyAcc1230 bodyHalt1230 PRE_first_tail_x4_L8_r0_body.bodyStepA319 bodyTop1231 (fun _ hm => bodyO1228 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1228).trans bodyInactive0) (bodyBr1231.trans bodyBr1228.symm) bodyCnt1228 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA319 PRE_first_tail_x4_L8_r0_body.sizeArgsA319 PRE_first_tail_x4_L8_r0_body.sizeSymA319 PRE_first_tail_x4_L8_r0_body.sizeMlxA319 PRE_first_tail_x4_L8_r0_body.sizePayA319 PRE_first_tail_x4_L8_r0_body.sizeTaA319 PRE_first_tail_x4_L8_r0_body.sizeDecA319 PRE_first_tail_x4_L8_r0_body.sizePreA319 PRE_first_tail_x4_L8_r0_body.bodyPatchB319 (fun _ hm => bodyO1231 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1231).trans bodyInactive0) (bodyBr1232.trans bodyBr1231.symm) bodyCnt1231 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) bodyAcc1232 PRE_first_tail_x4_L8_r0_body.bodyRunSeg319 bodyAcc1233 bodyHalt1233 PRE_first_tail_x4_L8_r0_body.bodyStepA320 bodyTop1234 (fun _ hm => bodyO1232 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1232).trans bodyInactive0) (bodyBr1234.trans bodyBr1232.symm) bodyCnt1232 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA320 PRE_first_tail_x4_L8_r0_body.sizeArgsA320 PRE_first_tail_x4_L8_r0_body.sizeSymA320 PRE_first_tail_x4_L8_r0_body.sizeMlxA320 PRE_first_tail_x4_L8_r0_body.sizePayA320 PRE_first_tail_x4_L8_r0_body.sizeTaA320 PRE_first_tail_x4_L8_r0_body.sizeDecA320 PRE_first_tail_x4_L8_r0_body.sizePreA320 PRE_first_tail_x4_L8_r0_body.bodyPatchB320 (fun _ hm => bodyO1234 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1234).trans bodyInactive0) (bodyBr1235.trans bodyBr1234.symm) bodyCnt1234 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56922, 1097, 0, 0⟩) bodyAcc1235 PRE_first_tail_x4_L8_r0_body.bodyRunSeg320 bodyAcc1237 bodyHalt1237 PRE_first_tail_x4_L8_r0_body.bodyStepA321 bodyTop1238 (fun _ hm => bodyO1235 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1235).trans bodyInactive0) (bodyBr1238.trans bodyBr1235.symm) bodyCnt1235 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift55 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S1238.tab.length PRE_first_tail_x4_L8_r0_body.s1238.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P55.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P55 15 PRE_first_tail_x4_L8_r0_body.kappa55 PRE_first_tail_x4_L8_r0_body.s1240.ffi PRE_first_tail_x4_L8_r0_body.s1239.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_55
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_55
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s1240.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S1238.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_55] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK55 PRE_first_tail_x4_L8_r0_body.cobjsK55
      PRE_first_tail_x4_L8_r0_body.citemsK55 PRE_first_tail_x4_L8_r0_body.cbd55 PRE_first_tail_x4_L8_r0_body.csst55
  exact PRE_first_tail_x4_L8_r0_body.cshift55 bodyNcl55 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_55] at this; exact this)


kernel_rfl bodyFramesEmpty55 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s1239 a).isEmpty) = true
kernel_rfl bodyJsRoots55 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s1238.next) PRE_first_tail_x4_L8_r0_body.s1240.trace PRE_first_tail_x4_L8_r0_body.s1240 = true
kernel_rfl bodyJsNative55 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s1240.ffi) = true
kernel_rfl bodyLow55 : (PRE_first_tail_x4_L8_r0_body.cws55 ++ PRE_first_tail_x4_L8_r0_body.ws55).all (Nat.ble 9) = true
kernel_rfl bodyCntM55 : countersOkB PRE_first_tail_x4_L8_r0_body.s1238 PRE_first_tail_x4_L8_r0_body.s1239 = true
kernel_rfl bodyHi55 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1240.ffi).next setupP.E = true
kernel_rfl bodyNhi55 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1240.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge55 : bridgeOf PRE_first_tail_x4_L8_r0_body.s1239.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s1238.ffi
kernel_rfl bodyNN55 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s1238.ffi).nnext PRE_first_tail_x4_L8_r0_body.P55.NL = true
kernel_rfl bodyXn55 : Nat.ble (⟨21634, 18732, 2812493, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s1240.ffi).next = true
kernel_rfl bodyLo55 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s1240.ffi).next = true
theorem bodyFacts55 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s1238 PRE_first_tail_x4_L8_r0_body.s1239 PRE_first_tail_x4_L8_r0_body.s1240 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S1238 PRE_first_tail_x4_L8_r0_body.S1239 PRE_first_tail_x4_L8_r0_body.S1240
    PRE_first_tail_x4_L8_r0_body.ws55 PRE_first_tail_x4_L8_r0_body.cws55 PRE_first_tail_x4_L8_r0_body.nr55 PRE_first_tail_x4_L8_r0_body.pl55 PRE_first_tail_x4_L8_r0_body.cl55 2812843 15 PRE_first_tail_x4_L8_r0_body.kd55 PRE_first_tail_x4_L8_r0_body.kappa55 PRE_first_tail_x4_L8_r0_body.P55
    ⟨21630, 18726, 2812478, 15⟩ ⟨21634, 18732, 2812493, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap55
  clean := bodyClean55
  cfix := PRE_first_tail_x4_L8_r0_body.cfix55
  zpl := PRE_first_tail_x4_L8_r0_body.zpl55
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd55
  zn1 := PRE_first_tail_x4_L8_r0_body.zn155
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst55
  zscn := PRE_first_tail_x4_L8_r0_body.zscn55
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn55
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow55
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab55
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh55
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd55
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi55
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt55
  zgP := PRE_first_tail_x4_L8_r0_body.zg55_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk55_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm55_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg55_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk55_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm55_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw55_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw55_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap55
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd55
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap55 PRE_first_tail_x4_L8_r0_body.stFoot55 PRE_first_tail_x4_L8_r0_body.iso55 PRE_first_tail_x4_L8_r0_body.zwr55
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP55
  csupp := PRE_first_tail_x4_L8_r0_body.csupp55
  cbound := PRE_first_tail_x4_L8_r0_body.cbound55
  zimg := PRE_first_tail_x4_L8_r0_body.zimg55
  zctl := PRE_first_tail_x4_L8_r0_body.zctl55
  zstack := PRE_first_tail_x4_L8_r0_body.zstack55
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs55
  zstores := PRE_first_tail_x4_L8_r0_body.zstores55
  zroots := PRE_first_tail_x4_L8_r0_body.zroots55
  znC := PRE_first_tail_x4_L8_r0_body.znC55
  ctab := PRE_first_tail_x4_L8_r0_body.ctab55
  zbin := PRE_first_tail_x4_L8_r0_body.zbin55
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge55
  sbridge := bodyBridge55
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj55
  cshiftR := fun h hNL => bodyCshift55 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN55
  raised := PRE_first_tail_x4_L8_r0_body.raised55
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs55
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl55
  xnLe := Nat.le_of_ble_eq_true bodyXn55
  loLe := Nat.le_of_ble_eq_true bodyLo55
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB55
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
noncomputable def bodyEs55 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr55.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st55.S3.tab r
kernel_rfl bodyResChk55 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs55 bodyQs55) = true
kernel_rfl bodyLq55 : bodyQs55.length = PRE_first_tail_x4_L8_r0_body.cws55.length
kernel_rfl bodyNrLo55 : PRE_first_tail_x4_L8_r0_body.nr55.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S1238.tab.length) = true
kernel_rfl bodySub55 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site55.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost55 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws55 PRE_first_tail_x4_L8_r0_body.cws55 bodyQs55 = true
kernel_rfl bodyDrop55 : Nat.ble (56922 + (PRE_first_tail_x4_L8_r0_body.s1239.next - PRE_first_tail_x4_L8_r0_body.s1240.next)) 57272 = true
kernel_rfl bodyDropH55 : Nat.ble (1097 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1239.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s1240.ffi).next)) 1099 = true
kernel_rfl bodyDropN55 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s1239.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s1240.ffi).nnext)) 0 = true
kernel_rfl bodyDv55 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws55
kernel_rfl bodyDe55 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr55.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st55.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl55 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold55 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws55).isNone && !PRE_first_tail_x4_L8_r0_body.ws55.contains v) = true
kernel_rfl bodyDfree55 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws55 ++ PRE_first_tail_x4_L8_r0_body.ws55).all fun w => e.noVar w) = true

theorem bodyStep55 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨56922, 1097, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1238 PRE_first_tail_x4_L8_r0_body.S1238)
      (bodyCut NB T tk π i x0 bodyΘ ⟨57272, 1099, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s1240 PRE_first_tail_x4_L8_r0_body.S1240) (3452 + 1) :=
  bodySite bodyFacts55.cfix bodyFacts55.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L8_r0_body.st55.S3.tab) (Es := bodyEs55) (qs := bodyQs55)
    (ok := PRE_first_tail_x4_L8_r0_body.st55.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site55 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts55
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site55 r hr) hi (MapOk.sub hm (sub_of_all bodySub55)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk55 r hr) hi hm ho hq)
    bodyLq55 rfl bodyNrLo55 (postSub_sound bodyPost55)
    (Nat.le_of_ble_eq_true bodyDrop55) (by decide) (Nat.le_of_ble_eq_true bodyDropH55) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN55) (by decide)
    bodyDv55 bodyDe55 bodyDl55 bodyDold55 bodyDfree55 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end
