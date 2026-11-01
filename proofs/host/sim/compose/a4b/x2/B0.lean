import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x2_r0_body.States
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B14
import host.sim.compose.a4b.x2.VWBodyChain
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B23
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.x2.VWBodyMap
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B13
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B12
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x2_r0_body.m.B15

section -- VWBodyOracles_0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_g0 : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g0 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g0) (List.take 13 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site0 : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site0 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st0.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g1 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g1) (List.take 28 (List.drop 13 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site1 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site1) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st1.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g2 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g2 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g2) (List.take 27 (List.drop 41 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site2 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site2 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site2) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st2.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g3 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g3 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g3) (List.take 39 (List.drop 68 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site3 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site3 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site3) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st3.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site0 : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site0 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st0.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site0
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st0.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st0.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s15 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s16 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S15 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws0 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st0.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st0.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso0
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st0.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot0
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup0
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound0
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace0
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged0
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws0.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st0.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S15.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_0]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen0.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl0 : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s15.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl0 PRE_first_tail_x2_r0_body.ncl0

theorem bodyClean0 : Conv.JClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s15 :=
  PRE_first_tail_x2_r0_body.gjcl0 bodyStartClean

kernel_rfl bodyJsLe0 : Nat.ble 2673488 PRE_first_tail_x2_r0_body.s15.next = true
kernel_rfl bodyJsList0 : (PRE_first_tail_x2_r0_body.gjh0 ++ PRE_first_tail_x2_r0_body.cl0).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s15.next) PRE_first_tail_x2_r0_body.s17) = true
theorem bodyJs0 : JsHeapAbove PRE_first_tail_x2_r0_body.s15.next PRE_first_tail_x2_r0_body.s17 :=
  JsHeapAbove.glueSite bodyStartJs (Nat.le_of_ble_eq_true bodyJsLe0) PRE_first_tail_x2_r0_body.gjk0 PRE_first_tail_x2_r0_body.gjbd0 PRE_first_tail_x2_r0_body.cheap0 PRE_first_tail_x2_r0_body.zclbd0 bodyJsList0

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO0 : PRE_first_tail_x2_r0_body.S0.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S0.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr0 : bridgeOf PRE_first_tail_x2_r0_body.s0.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc0 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S0) = fun _ _ => true
kernel_rfl bodyAcc1 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s1 PRE_first_tail_x2_r0_body.S1) = fun _ _ => true
kernel_rfl bodyBr2 : bridgeOf PRE_first_tail_x2_r0_body.s2.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt1 : isHalt PRE_first_tail_x2_r0_body.s1.ctl = false
kernel_rfl bodyTop2 : noRetBlock PRE_first_tail_x2_r0_body.s2 = true
kernel_rfl bodyCnt0 : countersOkB PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.s2 = true
kernel_rfl bodyO2 : PRE_first_tail_x2_r0_body.S2.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S2.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr3 : bridgeOf PRE_first_tail_x2_r0_body.s3.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt2 : countersOkB PRE_first_tail_x2_r0_body.s2 PRE_first_tail_x2_r0_body.s3 = true
kernel_rfl bodyO3 : PRE_first_tail_x2_r0_body.S3.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S3.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc3 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s3 PRE_first_tail_x2_r0_body.S3) = fun _ _ => true
kernel_rfl bodyAcc5 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s5 PRE_first_tail_x2_r0_body.S5) = fun _ _ => true
kernel_rfl bodyBr6 : bridgeOf PRE_first_tail_x2_r0_body.s6.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt5 : isHalt PRE_first_tail_x2_r0_body.s5.ctl = false
kernel_rfl bodyTop6 : noRetBlock PRE_first_tail_x2_r0_body.s6 = true
kernel_rfl bodyCnt3 : countersOkB PRE_first_tail_x2_r0_body.s3 PRE_first_tail_x2_r0_body.s6 = true
kernel_rfl bodyO6 : PRE_first_tail_x2_r0_body.S6.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S6.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr7 : bridgeOf PRE_first_tail_x2_r0_body.s7.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt6 : countersOkB PRE_first_tail_x2_r0_body.s6 PRE_first_tail_x2_r0_body.s7 = true
kernel_rfl bodyO7 : PRE_first_tail_x2_r0_body.S7.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S7.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc7 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s7 PRE_first_tail_x2_r0_body.S7) = fun _ _ => true
kernel_rfl bodyAcc8 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s8 PRE_first_tail_x2_r0_body.S8) = fun _ _ => true
kernel_rfl bodyBr9 : bridgeOf PRE_first_tail_x2_r0_body.s9.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt8 : isHalt PRE_first_tail_x2_r0_body.s8.ctl = false
kernel_rfl bodyTop9 : noRetBlock PRE_first_tail_x2_r0_body.s9 = true
kernel_rfl bodyCnt7 : countersOkB PRE_first_tail_x2_r0_body.s7 PRE_first_tail_x2_r0_body.s9 = true
kernel_rfl bodyO9 : PRE_first_tail_x2_r0_body.S9.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S9.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr10 : bridgeOf PRE_first_tail_x2_r0_body.s10.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt9 : countersOkB PRE_first_tail_x2_r0_body.s9 PRE_first_tail_x2_r0_body.s10 = true
kernel_rfl bodyO10 : PRE_first_tail_x2_r0_body.S10.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S10.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc10 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s10 PRE_first_tail_x2_r0_body.S10) = fun _ _ => true
kernel_rfl bodyAcc11 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s11 PRE_first_tail_x2_r0_body.S11) = fun _ _ => true
kernel_rfl bodyBr12 : bridgeOf PRE_first_tail_x2_r0_body.s12.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt11 : isHalt PRE_first_tail_x2_r0_body.s11.ctl = false
kernel_rfl bodyTop12 : noRetBlock PRE_first_tail_x2_r0_body.s12 = true
kernel_rfl bodyCnt10 : countersOkB PRE_first_tail_x2_r0_body.s10 PRE_first_tail_x2_r0_body.s12 = true
kernel_rfl bodyO12 : PRE_first_tail_x2_r0_body.S12.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S12.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr13 : bridgeOf PRE_first_tail_x2_r0_body.s13.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt12 : countersOkB PRE_first_tail_x2_r0_body.s12 PRE_first_tail_x2_r0_body.s13 = true
kernel_rfl bodyO13 : PRE_first_tail_x2_r0_body.S13.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S13.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc13 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s13 PRE_first_tail_x2_r0_body.S13) = fun _ _ => true
kernel_rfl bodyAcc14 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s14 PRE_first_tail_x2_r0_body.S14) = fun _ _ => true
kernel_rfl bodyBr15 : bridgeOf PRE_first_tail_x2_r0_body.s15.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt14 : isHalt PRE_first_tail_x2_r0_body.s14.ctl = false
kernel_rfl bodyTop15 : noRetBlock PRE_first_tail_x2_r0_body.s15 = true
kernel_rfl bodyCnt13 : countersOkB PRE_first_tail_x2_r0_body.s13 PRE_first_tail_x2_r0_body.s15 = true

theorem bodyGlue0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S0)
      (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x2_r0_body.s15 PRE_first_tail_x2_r0_body.S15) 13512 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc0 PRE_first_tail_x2_r0_body.bodyRunSeg0 bodyAcc1 bodyHalt1 PRE_first_tail_x2_r0_body.bodyStepA1 bodyTop2 (fun _ hm => bodyO0 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr0).trans bodyInactive0) (bodyBr2.trans bodyBr0.symm) bodyCnt0 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x2_r0_body.sizeA1 PRE_first_tail_x2_r0_body.sizeArgsA1 PRE_first_tail_x2_r0_body.sizeSymA1 PRE_first_tail_x2_r0_body.sizeMlxA1 PRE_first_tail_x2_r0_body.sizePayA1 PRE_first_tail_x2_r0_body.sizeTaA1 PRE_first_tail_x2_r0_body.sizeDecA1 PRE_first_tail_x2_r0_body.sizePreA1 PRE_first_tail_x2_r0_body.bodyPatchB1 (fun _ hm => bodyO2 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr2).trans bodyInactive0) (bodyBr3.trans bodyBr2.symm) bodyCnt2 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc3 PRE_first_tail_x2_r0_body.bodyRunSeg1 bodyAcc5 bodyHalt5 PRE_first_tail_x2_r0_body.bodyStepA2 bodyTop6 (fun _ hm => bodyO3 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr3).trans bodyInactive0) (bodyBr6.trans bodyBr3.symm) bodyCnt3 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x2_r0_body.sizeA2 PRE_first_tail_x2_r0_body.sizeArgsA2 PRE_first_tail_x2_r0_body.sizeSymA2 PRE_first_tail_x2_r0_body.sizeMlxA2 PRE_first_tail_x2_r0_body.sizePayA2 PRE_first_tail_x2_r0_body.sizeTaA2 PRE_first_tail_x2_r0_body.sizeDecA2 PRE_first_tail_x2_r0_body.sizePreA2 PRE_first_tail_x2_r0_body.bodyPatchB2 (fun _ hm => bodyO6 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr6).trans bodyInactive0) (bodyBr7.trans bodyBr6.symm) bodyCnt6 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc7 PRE_first_tail_x2_r0_body.bodyRunSeg2 bodyAcc8 bodyHalt8 PRE_first_tail_x2_r0_body.bodyStepA3 bodyTop9 (fun _ hm => bodyO7 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr7).trans bodyInactive0) (bodyBr9.trans bodyBr7.symm) bodyCnt7 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x2_r0_body.sizeA3 PRE_first_tail_x2_r0_body.sizeArgsA3 PRE_first_tail_x2_r0_body.sizeSymA3 PRE_first_tail_x2_r0_body.sizeMlxA3 PRE_first_tail_x2_r0_body.sizePayA3 PRE_first_tail_x2_r0_body.sizeTaA3 PRE_first_tail_x2_r0_body.sizeDecA3 PRE_first_tail_x2_r0_body.sizePreA3 PRE_first_tail_x2_r0_body.bodyPatchB3 (fun _ hm => bodyO9 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr9).trans bodyInactive0) (bodyBr10.trans bodyBr9.symm) bodyCnt9 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc10 PRE_first_tail_x2_r0_body.bodyRunSeg3 bodyAcc11 bodyHalt11 PRE_first_tail_x2_r0_body.bodyStepA4 bodyTop12 (fun _ hm => bodyO10 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr10).trans bodyInactive0) (bodyBr12.trans bodyBr10.symm) bodyCnt10 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x2_r0_body.sizeA4 PRE_first_tail_x2_r0_body.sizeArgsA4 PRE_first_tail_x2_r0_body.sizeSymA4 PRE_first_tail_x2_r0_body.sizeMlxA4 PRE_first_tail_x2_r0_body.sizePayA4 PRE_first_tail_x2_r0_body.sizeTaA4 PRE_first_tail_x2_r0_body.sizeDecA4 PRE_first_tail_x2_r0_body.sizePreA4 PRE_first_tail_x2_r0_body.bodyPatchB4 (fun _ hm => bodyO12 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr12).trans bodyInactive0) (bodyBr13.trans bodyBr12.symm) bodyCnt12 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc13 PRE_first_tail_x2_r0_body.bodyRunSeg4 bodyAcc14 bodyHalt14 PRE_first_tail_x2_r0_body.bodyStepA5 bodyTop15 (fun _ hm => bodyO13 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr13).trans bodyInactive0) (bodyBr15.trans bodyBr13.symm) bodyCnt13 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift0 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S15.tab.length PRE_first_tail_x2_r0_body.s15.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P0.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P0 101 PRE_first_tail_x2_r0_body.kappa0 PRE_first_tail_x2_r0_body.s17.ffi PRE_first_tail_x2_r0_body.s16.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_0
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_0
  have hcl : SSt (· < 101) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s17.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S15.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_0] <;> decide) PRE_first_tail_x2_r0_body.cnodesK0 PRE_first_tail_x2_r0_body.cobjsK0
      PRE_first_tail_x2_r0_body.citemsK0 PRE_first_tail_x2_r0_body.cbd0 PRE_first_tail_x2_r0_body.csst0
  exact PRE_first_tail_x2_r0_body.cshift0 bodyNcl0 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_0] at this; exact this)


kernel_rfl bodyFramesEmpty0 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s16 a).isEmpty) = true
kernel_rfl bodyJsRoots0 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s15.next) PRE_first_tail_x2_r0_body.s17.trace PRE_first_tail_x2_r0_body.s17 = true
kernel_rfl bodyJsNative0 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s17.ffi) = true
kernel_rfl bodyLow0 : (PRE_first_tail_x2_r0_body.cws0 ++ PRE_first_tail_x2_r0_body.ws0).all (Nat.ble 9) = true
kernel_rfl bodyCntM0 : countersOkB PRE_first_tail_x2_r0_body.s15 PRE_first_tail_x2_r0_body.s16 = true
kernel_rfl bodyHi0 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s17.ffi).next setupP.E = true
kernel_rfl bodyNhi0 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s17.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge0 : bridgeOf PRE_first_tail_x2_r0_body.s16.ffi = bridgeOf PRE_first_tail_x2_r0_body.s15.ffi
kernel_rfl bodyNN0 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s15.ffi).nnext PRE_first_tail_x2_r0_body.P0.NL = true
kernel_rfl bodyXn0 : Nat.ble (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s17.ffi).next = true
kernel_rfl bodyLo0 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s17.ffi).next = true
theorem bodyFacts0 : BodySiteFacts PRE_first_tail_x2_r0_body.s15 PRE_first_tail_x2_r0_body.s16 PRE_first_tail_x2_r0_body.s17 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S15 PRE_first_tail_x2_r0_body.S16 PRE_first_tail_x2_r0_body.S17
    PRE_first_tail_x2_r0_body.ws0 PRE_first_tail_x2_r0_body.cws0 PRE_first_tail_x2_r0_body.nr0 PRE_first_tail_x2_r0_body.pl0 PRE_first_tail_x2_r0_body.cl0 2676612 101 PRE_first_tail_x2_r0_body.kd0 PRE_first_tail_x2_r0_body.kappa0 PRE_first_tail_x2_r0_body.P0
    ⟨18189, 15254, 2674897, 83⟩ ⟨18197, 15296, 2674920, 101⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap0
  clean := bodyClean0
  cfix := PRE_first_tail_x2_r0_body.cfix0
  zpl := PRE_first_tail_x2_r0_body.zpl0
  zplnd := PRE_first_tail_x2_r0_body.zplnd0
  zn1 := PRE_first_tail_x2_r0_body.zn10
  zfirst := PRE_first_tail_x2_r0_body.zfirst0
  zscn := PRE_first_tail_x2_r0_body.zscn0
  zsmn := PRE_first_tail_x2_r0_body.zsmn0
  zgrow := PRE_first_tail_x2_r0_body.zgrow0
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab0
  zfresh := PRE_first_tail_x2_r0_body.zfresh0
  zcnd := PRE_first_tail_x2_r0_body.zcnd0
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi0
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt0
  zgP := PRE_first_tail_x2_r0_body.zg0_2665
  zkP := PRE_first_tail_x2_r0_body.zk0_2665
  zmP := PRE_first_tail_x2_r0_body.zm0_2665
  zgC := PRE_first_tail_x2_r0_body.zg0_2673467
  zkC := PRE_first_tail_x2_r0_body.zk0_2673467
  zmC := PRE_first_tail_x2_r0_body.zm0_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw0_2673472
  zwV := PRE_first_tail_x2_r0_body.zw0_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap0
  zclbd := PRE_first_tail_x2_r0_body.zclbd0
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap0 PRE_first_tail_x2_r0_body.stFoot0 PRE_first_tail_x2_r0_body.iso0 PRE_first_tail_x2_r0_body.zwr0
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP0
  csupp := PRE_first_tail_x2_r0_body.csupp0
  cbound := PRE_first_tail_x2_r0_body.cbound0
  zimg := PRE_first_tail_x2_r0_body.zimg0
  zctl := PRE_first_tail_x2_r0_body.zctl0
  zstack := PRE_first_tail_x2_r0_body.zstack0
  zjobs := PRE_first_tail_x2_r0_body.zjobs0
  zstores := PRE_first_tail_x2_r0_body.zstores0
  zroots := PRE_first_tail_x2_r0_body.zroots0
  znC := PRE_first_tail_x2_r0_body.znC0
  ctab := PRE_first_tail_x2_r0_body.ctab0
  zbin := PRE_first_tail_x2_r0_body.zbin0
  cbridge := PRE_first_tail_x2_r0_body.cbridge0
  sbridge := bodyBridge0
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj0
  cshiftR := fun h hNL => bodyCshift0 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN0
  raised := PRE_first_tail_x2_r0_body.raised0
  cbigs := PRE_first_tail_x2_r0_body.cbigs0
  cjcl := PRE_first_tail_x2_r0_body.cjcl0
  xnLe := Nat.le_of_ble_eq_true bodyXn0
  loLe := Nat.le_of_ble_eq_true bodyLo0
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB0
  cntM := bodyCntM0
  hiLe := Nat.le_of_ble_eq_true bodyHi0
  nhiLe := Nat.le_of_ble_eq_true bodyNhi0
  jsHeap := bodyJs0
  jsRoots := bodyJsRoots0
  jsNative := bodyJsNative0
  framesEmpty := bodyFramesEmpty0
  trailOld := by decide
  lowVars := bodyLow0

def bodyQs0 : List (Option Q) := [some Q.n, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs0 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr0.map fun r => nth? PRE_first_tail_x2_r0_body.st0.S7.tab r
kernel_rfl bodyResChk0 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs0 bodyQs0) = true
kernel_rfl bodyLq0 : bodyQs0.length = PRE_first_tail_x2_r0_body.cws0.length
kernel_rfl bodyNrLo0 : PRE_first_tail_x2_r0_body.nr0.all (Nat.ble PRE_first_tail_x2_r0_body.S15.tab.length) = true
kernel_rfl bodySub0 : (Oracles.PRE_first_tail_x2_r0_body.map_site0.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost0 : postSubB bodyM PRE_first_tail_x2_r0_body.ws0 PRE_first_tail_x2_r0_body.cws0 bodyQs0 = true
kernel_rfl bodyDrop0 : Nat.ble (3571 + (PRE_first_tail_x2_r0_body.s16.next - PRE_first_tail_x2_r0_body.s17.next)) 5263 = true
kernel_rfl bodyDropH0 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s16.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s17.ffi).next)) 46 = true
kernel_rfl bodyDropN0 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s16.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s17.ffi).nnext)) 0 = true
kernel_rfl bodyDv0 : bodyΘ.1.take 18 = bodyΘ.1.take 0 ++ PRE_first_tail_x2_r0_body.cws0
kernel_rfl bodyDe0 : bodyΘ.2.take 18 = bodyΘ.2.take 0 ++ PRE_first_tail_x2_r0_body.nr0.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st0.S7.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl0 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold0 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws0).isNone && !PRE_first_tail_x2_r0_body.ws0.contains v) = true
kernel_rfl bodyDfree0 : (bodyΘ.2.take 18).all (fun e => (PRE_first_tail_x2_r0_body.cws0 ++ PRE_first_tail_x2_r0_body.ws0).all fun w => e.noVar w) = true

theorem bodyStep0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x2_r0_body.s15 PRE_first_tail_x2_r0_body.S15)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x2_r0_body.s17 PRE_first_tail_x2_r0_body.S17) (17040 + 1) :=
  bodySite bodyFacts0.cfix bodyFacts0.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 17040) (S2 := PRE_first_tail_x2_r0_body.st0.S7.tab) (Es := bodyEs0) (qs := bodyQs0)
    (ok := PRE_first_tail_x2_r0_body.st0.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site0 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts0
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site0 r hr) hi (MapOk.sub hm (sub_of_all bodySub0)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk0 r hr) hi hm ho hq)
    bodyLq0 rfl bodyNrLo0 (postSub_sound bodyPost0)
    (Nat.le_of_ble_eq_true bodyDrop0) (by decide) (Nat.le_of_ble_eq_true bodyDropH0) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN0) (by decide)
    bodyDv0 bodyDe0 bodyDl0 bodyDold0 bodyDfree0 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site1 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site1) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st1.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site1
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st1.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st1.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s38 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s39 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S38 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws1 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st1.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st1.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso1
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_1
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st1.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot1
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup1
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound1
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace1
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged1
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws1.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st1.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S38.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_1]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen1.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl1 : Conv.NClean (⟨18270, 15341, 2677605, 209⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s38.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl1 (PRE_first_tail_x2_r0_body.cncl0 bodyNcl0)

theorem bodyClean1 : Conv.JClean (⟨18270, 15341, 2677605, 209⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s38 :=
  PRE_first_tail_x2_r0_body.gjcl1 (PRE_first_tail_x2_r0_body.cjcl0 bodyClean0)

kernel_rfl bodyJsLe1 : Nat.ble PRE_first_tail_x2_r0_body.s15.next PRE_first_tail_x2_r0_body.s38.next = true
kernel_rfl bodyJsList1 : (PRE_first_tail_x2_r0_body.gjh1 ++ PRE_first_tail_x2_r0_body.cl1).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s38.next) PRE_first_tail_x2_r0_body.s40) = true
theorem bodyJs1 : JsHeapAbove PRE_first_tail_x2_r0_body.s38.next PRE_first_tail_x2_r0_body.s40 :=
  JsHeapAbove.glueSite bodyJs0 (Nat.le_of_ble_eq_true bodyJsLe1) PRE_first_tail_x2_r0_body.gjk1 PRE_first_tail_x2_r0_body.gjbd1 PRE_first_tail_x2_r0_body.cheap1 PRE_first_tail_x2_r0_body.zclbd1 bodyJsList1

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO17 : PRE_first_tail_x2_r0_body.S17.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S17.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr17 : bridgeOf PRE_first_tail_x2_r0_body.s17.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc17 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s17 PRE_first_tail_x2_r0_body.S17) = fun _ _ => true
kernel_rfl bodyAcc19 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s19 PRE_first_tail_x2_r0_body.S19) = fun _ _ => true
kernel_rfl bodyBr20 : bridgeOf PRE_first_tail_x2_r0_body.s20.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt19 : isHalt PRE_first_tail_x2_r0_body.s19.ctl = false
kernel_rfl bodyTop20 : noRetBlock PRE_first_tail_x2_r0_body.s20 = true
kernel_rfl bodyCnt17 : countersOkB PRE_first_tail_x2_r0_body.s17 PRE_first_tail_x2_r0_body.s20 = true
kernel_rfl bodyO20 : PRE_first_tail_x2_r0_body.S20.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S20.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr21 : bridgeOf PRE_first_tail_x2_r0_body.s21.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt20 : countersOkB PRE_first_tail_x2_r0_body.s20 PRE_first_tail_x2_r0_body.s21 = true
kernel_rfl bodyO21 : PRE_first_tail_x2_r0_body.S21.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S21.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc21 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s21 PRE_first_tail_x2_r0_body.S21) = fun _ _ => true
kernel_rfl bodyAcc25 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s25 PRE_first_tail_x2_r0_body.S25) = fun _ _ => true
kernel_rfl bodyBr26 : bridgeOf PRE_first_tail_x2_r0_body.s26.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt25 : isHalt PRE_first_tail_x2_r0_body.s25.ctl = false
kernel_rfl bodyTop26 : noRetBlock PRE_first_tail_x2_r0_body.s26 = true
kernel_rfl bodyCnt21 : countersOkB PRE_first_tail_x2_r0_body.s21 PRE_first_tail_x2_r0_body.s26 = true
kernel_rfl bodyO26 : PRE_first_tail_x2_r0_body.S26.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S26.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr27 : bridgeOf PRE_first_tail_x2_r0_body.s27.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt26 : countersOkB PRE_first_tail_x2_r0_body.s26 PRE_first_tail_x2_r0_body.s27 = true
kernel_rfl bodyO27 : PRE_first_tail_x2_r0_body.S27.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S27.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc27 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s27 PRE_first_tail_x2_r0_body.S27) = fun _ _ => true
kernel_rfl bodyAcc28 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s28 PRE_first_tail_x2_r0_body.S28) = fun _ _ => true
kernel_rfl bodyBr29 : bridgeOf PRE_first_tail_x2_r0_body.s29.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt28 : isHalt PRE_first_tail_x2_r0_body.s28.ctl = false
kernel_rfl bodyTop29 : noRetBlock PRE_first_tail_x2_r0_body.s29 = true
kernel_rfl bodyCnt27 : countersOkB PRE_first_tail_x2_r0_body.s27 PRE_first_tail_x2_r0_body.s29 = true
kernel_rfl bodyO29 : PRE_first_tail_x2_r0_body.S29.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S29.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr30 : bridgeOf PRE_first_tail_x2_r0_body.s30.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt29 : countersOkB PRE_first_tail_x2_r0_body.s29 PRE_first_tail_x2_r0_body.s30 = true
kernel_rfl bodyO30 : PRE_first_tail_x2_r0_body.S30.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S30.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc30 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s30 PRE_first_tail_x2_r0_body.S30) = fun _ _ => true
kernel_rfl bodyAcc31 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s31 PRE_first_tail_x2_r0_body.S31) = fun _ _ => true
kernel_rfl bodyBr32 : bridgeOf PRE_first_tail_x2_r0_body.s32.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt31 : isHalt PRE_first_tail_x2_r0_body.s31.ctl = false
kernel_rfl bodyTop32 : noRetBlock PRE_first_tail_x2_r0_body.s32 = true
kernel_rfl bodyCnt30 : countersOkB PRE_first_tail_x2_r0_body.s30 PRE_first_tail_x2_r0_body.s32 = true
kernel_rfl bodyO32 : PRE_first_tail_x2_r0_body.S32.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S32.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr33 : bridgeOf PRE_first_tail_x2_r0_body.s33.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt32 : countersOkB PRE_first_tail_x2_r0_body.s32 PRE_first_tail_x2_r0_body.s33 = true
kernel_rfl bodyO33 : PRE_first_tail_x2_r0_body.S33.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S33.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc33 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s33 PRE_first_tail_x2_r0_body.S33) = fun _ _ => true
kernel_rfl bodyAcc34 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s34 PRE_first_tail_x2_r0_body.S34) = fun _ _ => true
kernel_rfl bodyBr35 : bridgeOf PRE_first_tail_x2_r0_body.s35.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt34 : isHalt PRE_first_tail_x2_r0_body.s34.ctl = false
kernel_rfl bodyTop35 : noRetBlock PRE_first_tail_x2_r0_body.s35 = true
kernel_rfl bodyCnt33 : countersOkB PRE_first_tail_x2_r0_body.s33 PRE_first_tail_x2_r0_body.s35 = true
kernel_rfl bodyO35 : PRE_first_tail_x2_r0_body.S35.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S35.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr36 : bridgeOf PRE_first_tail_x2_r0_body.s36.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt35 : countersOkB PRE_first_tail_x2_r0_body.s35 PRE_first_tail_x2_r0_body.s36 = true
kernel_rfl bodyO36 : PRE_first_tail_x2_r0_body.S36.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S36.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc36 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s36 PRE_first_tail_x2_r0_body.S36) = fun _ _ => true
kernel_rfl bodyAcc37 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s37 PRE_first_tail_x2_r0_body.S37) = fun _ _ => true
kernel_rfl bodyBr38 : bridgeOf PRE_first_tail_x2_r0_body.s38.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt37 : isHalt PRE_first_tail_x2_r0_body.s37.ctl = false
kernel_rfl bodyTop38 : noRetBlock PRE_first_tail_x2_r0_body.s38 = true
kernel_rfl bodyCnt36 : countersOkB PRE_first_tail_x2_r0_body.s36 PRE_first_tail_x2_r0_body.s38 = true

theorem bodyGlue1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x2_r0_body.s17 PRE_first_tail_x2_r0_body.S17)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x2_r0_body.s38 PRE_first_tail_x2_r0_body.S38) 26804 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc17 PRE_first_tail_x2_r0_body.bodyRunSeg5 bodyAcc19 bodyHalt19 PRE_first_tail_x2_r0_body.bodyStepA6 bodyTop20 (fun _ hm => bodyO17 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr17).trans bodyInactive0) (bodyBr20.trans bodyBr17.symm) bodyCnt17 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) PRE_first_tail_x2_r0_body.sizeA6 PRE_first_tail_x2_r0_body.sizeArgsA6 PRE_first_tail_x2_r0_body.sizeSymA6 PRE_first_tail_x2_r0_body.sizeMlxA6 PRE_first_tail_x2_r0_body.sizePayA6 PRE_first_tail_x2_r0_body.sizeTaA6 PRE_first_tail_x2_r0_body.sizeDecA6 PRE_first_tail_x2_r0_body.sizePreA6 PRE_first_tail_x2_r0_body.bodyPatchB6 (fun _ hm => bodyO20 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr20).trans bodyInactive0) (bodyBr21.trans bodyBr20.symm) bodyCnt20 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc21 PRE_first_tail_x2_r0_body.bodyRunSeg6 bodyAcc25 bodyHalt25 PRE_first_tail_x2_r0_body.bodyStepA7 bodyTop26 (fun _ hm => bodyO21 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr21).trans bodyInactive0) (bodyBr26.trans bodyBr21.symm) bodyCnt21 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) PRE_first_tail_x2_r0_body.sizeA7 PRE_first_tail_x2_r0_body.sizeArgsA7 PRE_first_tail_x2_r0_body.sizeSymA7 PRE_first_tail_x2_r0_body.sizeMlxA7 PRE_first_tail_x2_r0_body.sizePayA7 PRE_first_tail_x2_r0_body.sizeTaA7 PRE_first_tail_x2_r0_body.sizeDecA7 PRE_first_tail_x2_r0_body.sizePreA7 PRE_first_tail_x2_r0_body.bodyPatchB7 (fun _ hm => bodyO26 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr26).trans bodyInactive0) (bodyBr27.trans bodyBr26.symm) bodyCnt26 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc27 PRE_first_tail_x2_r0_body.bodyRunSeg7 bodyAcc28 bodyHalt28 PRE_first_tail_x2_r0_body.bodyStepA8 bodyTop29 (fun _ hm => bodyO27 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr27).trans bodyInactive0) (bodyBr29.trans bodyBr27.symm) bodyCnt27 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) PRE_first_tail_x2_r0_body.sizeA8 PRE_first_tail_x2_r0_body.sizeArgsA8 PRE_first_tail_x2_r0_body.sizeSymA8 PRE_first_tail_x2_r0_body.sizeMlxA8 PRE_first_tail_x2_r0_body.sizePayA8 PRE_first_tail_x2_r0_body.sizeTaA8 PRE_first_tail_x2_r0_body.sizeDecA8 PRE_first_tail_x2_r0_body.sizePreA8 PRE_first_tail_x2_r0_body.bodyPatchB8 (fun _ hm => bodyO29 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr29).trans bodyInactive0) (bodyBr30.trans bodyBr29.symm) bodyCnt29 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc30 PRE_first_tail_x2_r0_body.bodyRunSeg8 bodyAcc31 bodyHalt31 PRE_first_tail_x2_r0_body.bodyStepA9 bodyTop32 (fun _ hm => bodyO30 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr30).trans bodyInactive0) (bodyBr32.trans bodyBr30.symm) bodyCnt30 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) PRE_first_tail_x2_r0_body.sizeA9 PRE_first_tail_x2_r0_body.sizeArgsA9 PRE_first_tail_x2_r0_body.sizeSymA9 PRE_first_tail_x2_r0_body.sizeMlxA9 PRE_first_tail_x2_r0_body.sizePayA9 PRE_first_tail_x2_r0_body.sizeTaA9 PRE_first_tail_x2_r0_body.sizeDecA9 PRE_first_tail_x2_r0_body.sizePreA9 PRE_first_tail_x2_r0_body.bodyPatchB9 (fun _ hm => bodyO32 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr32).trans bodyInactive0) (bodyBr33.trans bodyBr32.symm) bodyCnt32 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc33 PRE_first_tail_x2_r0_body.bodyRunSeg9 bodyAcc34 bodyHalt34 PRE_first_tail_x2_r0_body.bodyStepA10 bodyTop35 (fun _ hm => bodyO33 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr33).trans bodyInactive0) (bodyBr35.trans bodyBr33.symm) bodyCnt33 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) PRE_first_tail_x2_r0_body.sizeA10 PRE_first_tail_x2_r0_body.sizeArgsA10 PRE_first_tail_x2_r0_body.sizeSymA10 PRE_first_tail_x2_r0_body.sizeMlxA10 PRE_first_tail_x2_r0_body.sizePayA10 PRE_first_tail_x2_r0_body.sizeTaA10 PRE_first_tail_x2_r0_body.sizeDecA10 PRE_first_tail_x2_r0_body.sizePreA10 PRE_first_tail_x2_r0_body.bodyPatchB10 (fun _ hm => bodyO35 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr35).trans bodyInactive0) (bodyBr36.trans bodyBr35.symm) bodyCnt35 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc36 PRE_first_tail_x2_r0_body.bodyRunSeg10 bodyAcc37 bodyHalt37 PRE_first_tail_x2_r0_body.bodyStepA11 bodyTop38 (fun _ hm => bodyO36 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr36).trans bodyInactive0) (bodyBr38.trans bodyBr36.symm) bodyCnt36 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift1 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S38.tab.length PRE_first_tail_x2_r0_body.s38.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P1.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P1 227 PRE_first_tail_x2_r0_body.kappa1 PRE_first_tail_x2_r0_body.s40.ffi PRE_first_tail_x2_r0_body.s39.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_1
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_1
  have hcl : SSt (· < 227) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s40.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S38.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_1] <;> decide) PRE_first_tail_x2_r0_body.cnodesK1 PRE_first_tail_x2_r0_body.cobjsK1
      PRE_first_tail_x2_r0_body.citemsK1 PRE_first_tail_x2_r0_body.cbd1 PRE_first_tail_x2_r0_body.csst1
  exact PRE_first_tail_x2_r0_body.cshift1 bodyNcl1 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_1] at this; exact this)


kernel_rfl bodyFramesEmpty1 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s39 a).isEmpty) = true
kernel_rfl bodyJsRoots1 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s38.next) PRE_first_tail_x2_r0_body.s40.trace PRE_first_tail_x2_r0_body.s40 = true
kernel_rfl bodyJsNative1 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s40.ffi) = true
kernel_rfl bodyLow1 : (PRE_first_tail_x2_r0_body.cws1 ++ PRE_first_tail_x2_r0_body.ws1).all (Nat.ble 9) = true
kernel_rfl bodyCntM1 : countersOkB PRE_first_tail_x2_r0_body.s38 PRE_first_tail_x2_r0_body.s39 = true
kernel_rfl bodyHi1 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s40.ffi).next setupP.E = true
kernel_rfl bodyNhi1 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s40.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge1 : bridgeOf PRE_first_tail_x2_r0_body.s39.ffi = bridgeOf PRE_first_tail_x2_r0_body.s38.ffi
kernel_rfl bodyNN1 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s38.ffi).nnext PRE_first_tail_x2_r0_body.P1.NL = true
kernel_rfl bodyXn1 : Nat.ble (⟨18273, 15368, 2677611, 227⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s40.ffi).next = true
kernel_rfl bodyLo1 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s40.ffi).next = true
theorem bodyFacts1 : BodySiteFacts PRE_first_tail_x2_r0_body.s38 PRE_first_tail_x2_r0_body.s39 PRE_first_tail_x2_r0_body.s40 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S38 PRE_first_tail_x2_r0_body.S39 PRE_first_tail_x2_r0_body.S40
    PRE_first_tail_x2_r0_body.ws1 PRE_first_tail_x2_r0_body.cws1 PRE_first_tail_x2_r0_body.nr1 PRE_first_tail_x2_r0_body.pl1 PRE_first_tail_x2_r0_body.cl1 2678760 227 PRE_first_tail_x2_r0_body.kd1 PRE_first_tail_x2_r0_body.kappa1 PRE_first_tail_x2_r0_body.P1
    ⟨18270, 15341, 2677605, 209⟩ ⟨18273, 15368, 2677611, 227⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap1
  clean := bodyClean1
  cfix := PRE_first_tail_x2_r0_body.cfix1
  zpl := PRE_first_tail_x2_r0_body.zpl1
  zplnd := PRE_first_tail_x2_r0_body.zplnd1
  zn1 := PRE_first_tail_x2_r0_body.zn11
  zfirst := PRE_first_tail_x2_r0_body.zfirst1
  zscn := PRE_first_tail_x2_r0_body.zscn1
  zsmn := PRE_first_tail_x2_r0_body.zsmn1
  zgrow := PRE_first_tail_x2_r0_body.zgrow1
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab1
  zfresh := PRE_first_tail_x2_r0_body.zfresh1
  zcnd := PRE_first_tail_x2_r0_body.zcnd1
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi1
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt1
  zgP := PRE_first_tail_x2_r0_body.zg1_2665
  zkP := PRE_first_tail_x2_r0_body.zk1_2665
  zmP := PRE_first_tail_x2_r0_body.zm1_2665
  zgC := PRE_first_tail_x2_r0_body.zg1_2673467
  zkC := PRE_first_tail_x2_r0_body.zk1_2673467
  zmC := PRE_first_tail_x2_r0_body.zm1_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw1_2673472
  zwV := PRE_first_tail_x2_r0_body.zw1_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap1
  zclbd := PRE_first_tail_x2_r0_body.zclbd1
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap1 PRE_first_tail_x2_r0_body.stFoot1 PRE_first_tail_x2_r0_body.iso1 PRE_first_tail_x2_r0_body.zwr1
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP1
  csupp := PRE_first_tail_x2_r0_body.csupp1
  cbound := PRE_first_tail_x2_r0_body.cbound1
  zimg := PRE_first_tail_x2_r0_body.zimg1
  zctl := PRE_first_tail_x2_r0_body.zctl1
  zstack := PRE_first_tail_x2_r0_body.zstack1
  zjobs := PRE_first_tail_x2_r0_body.zjobs1
  zstores := PRE_first_tail_x2_r0_body.zstores1
  zroots := PRE_first_tail_x2_r0_body.zroots1
  znC := PRE_first_tail_x2_r0_body.znC1
  ctab := PRE_first_tail_x2_r0_body.ctab1
  zbin := PRE_first_tail_x2_r0_body.zbin1
  cbridge := PRE_first_tail_x2_r0_body.cbridge1
  sbridge := bodyBridge1
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj1
  cshiftR := fun h hNL => bodyCshift1 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN1
  raised := PRE_first_tail_x2_r0_body.raised1
  cbigs := PRE_first_tail_x2_r0_body.cbigs1
  cjcl := PRE_first_tail_x2_r0_body.cjcl1
  xnLe := Nat.le_of_ble_eq_true bodyXn1
  loLe := Nat.le_of_ble_eq_true bodyLo1
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB1
  cntM := bodyCntM1
  hiLe := Nat.le_of_ble_eq_true bodyHi1
  nhiLe := Nat.le_of_ble_eq_true bodyNhi1
  jsHeap := bodyJs1
  jsRoots := bodyJsRoots1
  jsNative := bodyJsNative1
  framesEmpty := bodyFramesEmpty1
  trailOld := by decide
  lowVars := bodyLow1

def bodyQs1 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs1 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr1.map fun r => nth? PRE_first_tail_x2_r0_body.st1.S5.tab r
kernel_rfl bodyResChk1 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs1 bodyQs1) = true
kernel_rfl bodyLq1 : bodyQs1.length = PRE_first_tail_x2_r0_body.cws1.length
kernel_rfl bodyNrLo1 : PRE_first_tail_x2_r0_body.nr1.all (Nat.ble PRE_first_tail_x2_r0_body.S38.tab.length) = true
kernel_rfl bodySub1 : (Oracles.PRE_first_tail_x2_r0_body.map_site1.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost1 : postSubB bodyM PRE_first_tail_x2_r0_body.ws1 PRE_first_tail_x2_r0_body.cws1 bodyQs1 = true
kernel_rfl bodyDrop1 : Nat.ble (5263 + (PRE_first_tail_x2_r0_body.s39.next - PRE_first_tail_x2_r0_body.s40.next)) 6412 = true
kernel_rfl bodyDropH1 : Nat.ble (46 + ((mlxOf PRE_first_tail_x2_r0_body.s39.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s40.ffi).next)) 71 = true
kernel_rfl bodyDropN1 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s39.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s40.ffi).nnext)) 0 = true
kernel_rfl bodyDv1 : bodyΘ.1.take 36 = bodyΘ.1.take 18 ++ PRE_first_tail_x2_r0_body.cws1
kernel_rfl bodyDe1 : bodyΘ.2.take 36 = bodyΘ.2.take 18 ++ PRE_first_tail_x2_r0_body.nr1.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st1.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 18) (bodyΘ.2.take 18)))
kernel_rfl bodyDl1 : (bodyΘ.1.take 18).length = (bodyΘ.2.take 18).length
kernel_rfl bodyDold1 : (bodyΘ.1.take 18).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws1).isNone && !PRE_first_tail_x2_r0_body.ws1.contains v) = true
kernel_rfl bodyDfree1 : (bodyΘ.2.take 36).all (fun e => (PRE_first_tail_x2_r0_body.cws1 ++ PRE_first_tail_x2_r0_body.ws1).all fun w => e.noVar w) = true

theorem bodyStep1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x2_r0_body.s38 PRE_first_tail_x2_r0_body.S38)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6412, 71, 0, 36⟩ bodyM PRE_first_tail_x2_r0_body.s40 PRE_first_tail_x2_r0_body.S40) (11334 + 1) :=
  bodySite bodyFacts1.cfix bodyFacts1.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st1.S5.tab) (Es := bodyEs1) (qs := bodyQs1)
    (ok := PRE_first_tail_x2_r0_body.st1.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site1 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts1
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site1 r hr) hi (MapOk.sub hm (sub_of_all bodySub1)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk1 r hr) hi hm ho hq)
    bodyLq1 rfl bodyNrLo1 (postSub_sound bodyPost1)
    (Nat.le_of_ble_eq_true bodyDrop1) (by decide) (Nat.le_of_ble_eq_true bodyDropH1) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN1) (by decide)
    bodyDv1 bodyDe1 bodyDl1 bodyDold1 bodyDfree1 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site2 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site2 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site2) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st2.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site2
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st2.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st2.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s60 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s61 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S60 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws2 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st2.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st2.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso2
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_2
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st2.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot2
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup2
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound2
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace2
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged2
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws2.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st2.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S60.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_2]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen2.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh2
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl2 : Conv.NClean (⟨18330, 15404, 2679937, 335⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s60.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl2 (PRE_first_tail_x2_r0_body.cncl1 bodyNcl1)

theorem bodyClean2 : Conv.JClean (⟨18330, 15404, 2679937, 335⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s60 :=
  PRE_first_tail_x2_r0_body.gjcl2 (PRE_first_tail_x2_r0_body.cjcl1 bodyClean1)

kernel_rfl bodyJsLe2 : Nat.ble PRE_first_tail_x2_r0_body.s38.next PRE_first_tail_x2_r0_body.s60.next = true
kernel_rfl bodyJsList2 : (PRE_first_tail_x2_r0_body.gjh2 ++ PRE_first_tail_x2_r0_body.cl2).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s60.next) PRE_first_tail_x2_r0_body.s62) = true
theorem bodyJs2 : JsHeapAbove PRE_first_tail_x2_r0_body.s60.next PRE_first_tail_x2_r0_body.s62 :=
  JsHeapAbove.glueSite bodyJs1 (Nat.le_of_ble_eq_true bodyJsLe2) PRE_first_tail_x2_r0_body.gjk2 PRE_first_tail_x2_r0_body.gjbd2 PRE_first_tail_x2_r0_body.cheap2 PRE_first_tail_x2_r0_body.zclbd2 bodyJsList2

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO40 : PRE_first_tail_x2_r0_body.S40.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S40.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr40 : bridgeOf PRE_first_tail_x2_r0_body.s40.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc40 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s40 PRE_first_tail_x2_r0_body.S40) = fun _ _ => true
kernel_rfl bodyAcc41 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s41 PRE_first_tail_x2_r0_body.S41) = fun _ _ => true
kernel_rfl bodyBr42 : bridgeOf PRE_first_tail_x2_r0_body.s42.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt41 : isHalt PRE_first_tail_x2_r0_body.s41.ctl = false
kernel_rfl bodyTop42 : noRetBlock PRE_first_tail_x2_r0_body.s42 = true
kernel_rfl bodyCnt40 : countersOkB PRE_first_tail_x2_r0_body.s40 PRE_first_tail_x2_r0_body.s42 = true
kernel_rfl bodyO42 : PRE_first_tail_x2_r0_body.S42.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S42.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr43 : bridgeOf PRE_first_tail_x2_r0_body.s43.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt42 : countersOkB PRE_first_tail_x2_r0_body.s42 PRE_first_tail_x2_r0_body.s43 = true
kernel_rfl bodyO43 : PRE_first_tail_x2_r0_body.S43.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S43.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc43 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s43 PRE_first_tail_x2_r0_body.S43) = fun _ _ => true
kernel_rfl bodyAcc47 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s47 PRE_first_tail_x2_r0_body.S47) = fun _ _ => true
kernel_rfl bodyBr48 : bridgeOf PRE_first_tail_x2_r0_body.s48.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt47 : isHalt PRE_first_tail_x2_r0_body.s47.ctl = false
kernel_rfl bodyTop48 : noRetBlock PRE_first_tail_x2_r0_body.s48 = true
kernel_rfl bodyCnt43 : countersOkB PRE_first_tail_x2_r0_body.s43 PRE_first_tail_x2_r0_body.s48 = true
kernel_rfl bodyO48 : PRE_first_tail_x2_r0_body.S48.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S48.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr49 : bridgeOf PRE_first_tail_x2_r0_body.s49.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt48 : countersOkB PRE_first_tail_x2_r0_body.s48 PRE_first_tail_x2_r0_body.s49 = true
kernel_rfl bodyO49 : PRE_first_tail_x2_r0_body.S49.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S49.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc49 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s49 PRE_first_tail_x2_r0_body.S49) = fun _ _ => true
kernel_rfl bodyAcc50 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s50 PRE_first_tail_x2_r0_body.S50) = fun _ _ => true
kernel_rfl bodyBr51 : bridgeOf PRE_first_tail_x2_r0_body.s51.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt50 : isHalt PRE_first_tail_x2_r0_body.s50.ctl = false
kernel_rfl bodyTop51 : noRetBlock PRE_first_tail_x2_r0_body.s51 = true
kernel_rfl bodyCnt49 : countersOkB PRE_first_tail_x2_r0_body.s49 PRE_first_tail_x2_r0_body.s51 = true
kernel_rfl bodyO51 : PRE_first_tail_x2_r0_body.S51.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S51.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr52 : bridgeOf PRE_first_tail_x2_r0_body.s52.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt51 : countersOkB PRE_first_tail_x2_r0_body.s51 PRE_first_tail_x2_r0_body.s52 = true
kernel_rfl bodyO52 : PRE_first_tail_x2_r0_body.S52.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S52.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc52 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s52 PRE_first_tail_x2_r0_body.S52) = fun _ _ => true
kernel_rfl bodyAcc53 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s53 PRE_first_tail_x2_r0_body.S53) = fun _ _ => true
kernel_rfl bodyBr54 : bridgeOf PRE_first_tail_x2_r0_body.s54.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt53 : isHalt PRE_first_tail_x2_r0_body.s53.ctl = false
kernel_rfl bodyTop54 : noRetBlock PRE_first_tail_x2_r0_body.s54 = true
kernel_rfl bodyCnt52 : countersOkB PRE_first_tail_x2_r0_body.s52 PRE_first_tail_x2_r0_body.s54 = true
kernel_rfl bodyO54 : PRE_first_tail_x2_r0_body.S54.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S54.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr55 : bridgeOf PRE_first_tail_x2_r0_body.s55.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt54 : countersOkB PRE_first_tail_x2_r0_body.s54 PRE_first_tail_x2_r0_body.s55 = true
kernel_rfl bodyO55 : PRE_first_tail_x2_r0_body.S55.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S55.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc55 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s55 PRE_first_tail_x2_r0_body.S55) = fun _ _ => true
kernel_rfl bodyAcc56 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s56 PRE_first_tail_x2_r0_body.S56) = fun _ _ => true
kernel_rfl bodyBr57 : bridgeOf PRE_first_tail_x2_r0_body.s57.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt56 : isHalt PRE_first_tail_x2_r0_body.s56.ctl = false
kernel_rfl bodyTop57 : noRetBlock PRE_first_tail_x2_r0_body.s57 = true
kernel_rfl bodyCnt55 : countersOkB PRE_first_tail_x2_r0_body.s55 PRE_first_tail_x2_r0_body.s57 = true
kernel_rfl bodyO57 : PRE_first_tail_x2_r0_body.S57.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S57.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr58 : bridgeOf PRE_first_tail_x2_r0_body.s58.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt57 : countersOkB PRE_first_tail_x2_r0_body.s57 PRE_first_tail_x2_r0_body.s58 = true
kernel_rfl bodyO58 : PRE_first_tail_x2_r0_body.S58.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S58.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc58 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s58 PRE_first_tail_x2_r0_body.S58) = fun _ _ => true
kernel_rfl bodyAcc59 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s59 PRE_first_tail_x2_r0_body.S59) = fun _ _ => true
kernel_rfl bodyBr60 : bridgeOf PRE_first_tail_x2_r0_body.s60.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt59 : isHalt PRE_first_tail_x2_r0_body.s59.ctl = false
kernel_rfl bodyTop60 : noRetBlock PRE_first_tail_x2_r0_body.s60 = true
kernel_rfl bodyCnt58 : countersOkB PRE_first_tail_x2_r0_body.s58 PRE_first_tail_x2_r0_body.s60 = true

theorem bodyGlue2 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6412, 71, 0, 36⟩ bodyM PRE_first_tail_x2_r0_body.s40 PRE_first_tail_x2_r0_body.S40)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6412, 71, 0, 36⟩ bodyM PRE_first_tail_x2_r0_body.s60 PRE_first_tail_x2_r0_body.S60) 23137 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) bodyAcc40 PRE_first_tail_x2_r0_body.bodyRunSeg11 bodyAcc41 bodyHalt41 PRE_first_tail_x2_r0_body.bodyStepA12 bodyTop42 (fun _ hm => bodyO40 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr40).trans bodyInactive0) (bodyBr42.trans bodyBr40.symm) bodyCnt40 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) PRE_first_tail_x2_r0_body.sizeA12 PRE_first_tail_x2_r0_body.sizeArgsA12 PRE_first_tail_x2_r0_body.sizeSymA12 PRE_first_tail_x2_r0_body.sizeMlxA12 PRE_first_tail_x2_r0_body.sizePayA12 PRE_first_tail_x2_r0_body.sizeTaA12 PRE_first_tail_x2_r0_body.sizeDecA12 PRE_first_tail_x2_r0_body.sizePreA12 PRE_first_tail_x2_r0_body.bodyPatchB12 (fun _ hm => bodyO42 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr42).trans bodyInactive0) (bodyBr43.trans bodyBr42.symm) bodyCnt42 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) bodyAcc43 PRE_first_tail_x2_r0_body.bodyRunSeg12 bodyAcc47 bodyHalt47 PRE_first_tail_x2_r0_body.bodyStepA13 bodyTop48 (fun _ hm => bodyO43 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr43).trans bodyInactive0) (bodyBr48.trans bodyBr43.symm) bodyCnt43 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) PRE_first_tail_x2_r0_body.sizeA13 PRE_first_tail_x2_r0_body.sizeArgsA13 PRE_first_tail_x2_r0_body.sizeSymA13 PRE_first_tail_x2_r0_body.sizeMlxA13 PRE_first_tail_x2_r0_body.sizePayA13 PRE_first_tail_x2_r0_body.sizeTaA13 PRE_first_tail_x2_r0_body.sizeDecA13 PRE_first_tail_x2_r0_body.sizePreA13 PRE_first_tail_x2_r0_body.bodyPatchB13 (fun _ hm => bodyO48 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr48).trans bodyInactive0) (bodyBr49.trans bodyBr48.symm) bodyCnt48 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) bodyAcc49 PRE_first_tail_x2_r0_body.bodyRunSeg13 bodyAcc50 bodyHalt50 PRE_first_tail_x2_r0_body.bodyStepA14 bodyTop51 (fun _ hm => bodyO49 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr49).trans bodyInactive0) (bodyBr51.trans bodyBr49.symm) bodyCnt49 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) PRE_first_tail_x2_r0_body.sizeA14 PRE_first_tail_x2_r0_body.sizeArgsA14 PRE_first_tail_x2_r0_body.sizeSymA14 PRE_first_tail_x2_r0_body.sizeMlxA14 PRE_first_tail_x2_r0_body.sizePayA14 PRE_first_tail_x2_r0_body.sizeTaA14 PRE_first_tail_x2_r0_body.sizeDecA14 PRE_first_tail_x2_r0_body.sizePreA14 PRE_first_tail_x2_r0_body.bodyPatchB14 (fun _ hm => bodyO51 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr51).trans bodyInactive0) (bodyBr52.trans bodyBr51.symm) bodyCnt51 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) bodyAcc52 PRE_first_tail_x2_r0_body.bodyRunSeg14 bodyAcc53 bodyHalt53 PRE_first_tail_x2_r0_body.bodyStepA15 bodyTop54 (fun _ hm => bodyO52 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr52).trans bodyInactive0) (bodyBr54.trans bodyBr52.symm) bodyCnt52 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) PRE_first_tail_x2_r0_body.sizeA15 PRE_first_tail_x2_r0_body.sizeArgsA15 PRE_first_tail_x2_r0_body.sizeSymA15 PRE_first_tail_x2_r0_body.sizeMlxA15 PRE_first_tail_x2_r0_body.sizePayA15 PRE_first_tail_x2_r0_body.sizeTaA15 PRE_first_tail_x2_r0_body.sizeDecA15 PRE_first_tail_x2_r0_body.sizePreA15 PRE_first_tail_x2_r0_body.bodyPatchB15 (fun _ hm => bodyO54 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr54).trans bodyInactive0) (bodyBr55.trans bodyBr54.symm) bodyCnt54 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) bodyAcc55 PRE_first_tail_x2_r0_body.bodyRunSeg15 bodyAcc56 bodyHalt56 PRE_first_tail_x2_r0_body.bodyStepA16 bodyTop57 (fun _ hm => bodyO55 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr55).trans bodyInactive0) (bodyBr57.trans bodyBr55.symm) bodyCnt55 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) PRE_first_tail_x2_r0_body.sizeA16 PRE_first_tail_x2_r0_body.sizeArgsA16 PRE_first_tail_x2_r0_body.sizeSymA16 PRE_first_tail_x2_r0_body.sizeMlxA16 PRE_first_tail_x2_r0_body.sizePayA16 PRE_first_tail_x2_r0_body.sizeTaA16 PRE_first_tail_x2_r0_body.sizeDecA16 PRE_first_tail_x2_r0_body.sizePreA16 PRE_first_tail_x2_r0_body.bodyPatchB16 (fun _ hm => bodyO57 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr57).trans bodyInactive0) (bodyBr58.trans bodyBr57.symm) bodyCnt57 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6412, 71, 0, 36⟩) bodyAcc58 PRE_first_tail_x2_r0_body.bodyRunSeg16 bodyAcc59 bodyHalt59 PRE_first_tail_x2_r0_body.bodyStepA17 bodyTop60 (fun _ hm => bodyO58 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr58).trans bodyInactive0) (bodyBr60.trans bodyBr58.symm) bodyCnt58 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift2 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S60.tab.length PRE_first_tail_x2_r0_body.s60.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P2.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P2 353 PRE_first_tail_x2_r0_body.kappa2 PRE_first_tail_x2_r0_body.s62.ffi PRE_first_tail_x2_r0_body.s61.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_2
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_2
  have hcl : SSt (· < 353) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s62.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S60.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_2] <;> decide) PRE_first_tail_x2_r0_body.cnodesK2 PRE_first_tail_x2_r0_body.cobjsK2
      PRE_first_tail_x2_r0_body.citemsK2 PRE_first_tail_x2_r0_body.cbd2 PRE_first_tail_x2_r0_body.csst2
  exact PRE_first_tail_x2_r0_body.cshift2 bodyNcl2 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_2] at this; exact this)


kernel_rfl bodyFramesEmpty2 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s61 a).isEmpty) = true
kernel_rfl bodyJsRoots2 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s60.next) PRE_first_tail_x2_r0_body.s62.trace PRE_first_tail_x2_r0_body.s62 = true
kernel_rfl bodyJsNative2 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s62.ffi) = true
kernel_rfl bodyLow2 : (PRE_first_tail_x2_r0_body.cws2 ++ PRE_first_tail_x2_r0_body.ws2).all (Nat.ble 9) = true
kernel_rfl bodyCntM2 : countersOkB PRE_first_tail_x2_r0_body.s60 PRE_first_tail_x2_r0_body.s61 = true
kernel_rfl bodyHi2 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s62.ffi).next setupP.E = true
kernel_rfl bodyNhi2 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s62.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge2 : bridgeOf PRE_first_tail_x2_r0_body.s61.ffi = bridgeOf PRE_first_tail_x2_r0_body.s60.ffi
kernel_rfl bodyNN2 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s60.ffi).nnext PRE_first_tail_x2_r0_body.P2.NL = true
kernel_rfl bodyXn2 : Nat.ble (⟨18333, 15431, 2679943, 353⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s62.ffi).next = true
kernel_rfl bodyLo2 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s62.ffi).next = true
theorem bodyFacts2 : BodySiteFacts PRE_first_tail_x2_r0_body.s60 PRE_first_tail_x2_r0_body.s61 PRE_first_tail_x2_r0_body.s62 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S60 PRE_first_tail_x2_r0_body.S61 PRE_first_tail_x2_r0_body.S62
    PRE_first_tail_x2_r0_body.ws2 PRE_first_tail_x2_r0_body.cws2 PRE_first_tail_x2_r0_body.nr2 PRE_first_tail_x2_r0_body.pl2 PRE_first_tail_x2_r0_body.cl2 2681092 353 PRE_first_tail_x2_r0_body.kd2 PRE_first_tail_x2_r0_body.kappa2 PRE_first_tail_x2_r0_body.P2
    ⟨18330, 15404, 2679937, 335⟩ ⟨18333, 15431, 2679943, 353⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap2
  clean := bodyClean2
  cfix := PRE_first_tail_x2_r0_body.cfix2
  zpl := PRE_first_tail_x2_r0_body.zpl2
  zplnd := PRE_first_tail_x2_r0_body.zplnd2
  zn1 := PRE_first_tail_x2_r0_body.zn12
  zfirst := PRE_first_tail_x2_r0_body.zfirst2
  zscn := PRE_first_tail_x2_r0_body.zscn2
  zsmn := PRE_first_tail_x2_r0_body.zsmn2
  zgrow := PRE_first_tail_x2_r0_body.zgrow2
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab2
  zfresh := PRE_first_tail_x2_r0_body.zfresh2
  zcnd := PRE_first_tail_x2_r0_body.zcnd2
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi2
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt2
  zgP := PRE_first_tail_x2_r0_body.zg2_2665
  zkP := PRE_first_tail_x2_r0_body.zk2_2665
  zmP := PRE_first_tail_x2_r0_body.zm2_2665
  zgC := PRE_first_tail_x2_r0_body.zg2_2673467
  zkC := PRE_first_tail_x2_r0_body.zk2_2673467
  zmC := PRE_first_tail_x2_r0_body.zm2_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw2_2673472
  zwV := PRE_first_tail_x2_r0_body.zw2_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap2
  zclbd := PRE_first_tail_x2_r0_body.zclbd2
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap2 PRE_first_tail_x2_r0_body.stFoot2 PRE_first_tail_x2_r0_body.iso2 PRE_first_tail_x2_r0_body.zwr2
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP2
  csupp := PRE_first_tail_x2_r0_body.csupp2
  cbound := PRE_first_tail_x2_r0_body.cbound2
  zimg := PRE_first_tail_x2_r0_body.zimg2
  zctl := PRE_first_tail_x2_r0_body.zctl2
  zstack := PRE_first_tail_x2_r0_body.zstack2
  zjobs := PRE_first_tail_x2_r0_body.zjobs2
  zstores := PRE_first_tail_x2_r0_body.zstores2
  zroots := PRE_first_tail_x2_r0_body.zroots2
  znC := PRE_first_tail_x2_r0_body.znC2
  ctab := PRE_first_tail_x2_r0_body.ctab2
  zbin := PRE_first_tail_x2_r0_body.zbin2
  cbridge := PRE_first_tail_x2_r0_body.cbridge2
  sbridge := bodyBridge2
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj2
  cshiftR := fun h hNL => bodyCshift2 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN2
  raised := PRE_first_tail_x2_r0_body.raised2
  cbigs := PRE_first_tail_x2_r0_body.cbigs2
  cjcl := PRE_first_tail_x2_r0_body.cjcl2
  xnLe := Nat.le_of_ble_eq_true bodyXn2
  loLe := Nat.le_of_ble_eq_true bodyLo2
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB2
  cntM := bodyCntM2
  hiLe := Nat.le_of_ble_eq_true bodyHi2
  nhiLe := Nat.le_of_ble_eq_true bodyNhi2
  jsHeap := bodyJs2
  jsRoots := bodyJsRoots2
  jsNative := bodyJsNative2
  framesEmpty := bodyFramesEmpty2
  trailOld := by decide
  lowVars := bodyLow2

def bodyQs2 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs2 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr2.map fun r => nth? PRE_first_tail_x2_r0_body.st2.S5.tab r
kernel_rfl bodyResChk2 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs2 bodyQs2) = true
kernel_rfl bodyLq2 : bodyQs2.length = PRE_first_tail_x2_r0_body.cws2.length
kernel_rfl bodyNrLo2 : PRE_first_tail_x2_r0_body.nr2.all (Nat.ble PRE_first_tail_x2_r0_body.S60.tab.length) = true
kernel_rfl bodySub2 : (Oracles.PRE_first_tail_x2_r0_body.map_site2.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost2 : postSubB bodyM PRE_first_tail_x2_r0_body.ws2 PRE_first_tail_x2_r0_body.cws2 bodyQs2 = true
kernel_rfl bodyDrop2 : Nat.ble (6412 + (PRE_first_tail_x2_r0_body.s61.next - PRE_first_tail_x2_r0_body.s62.next)) 7561 = true
kernel_rfl bodyDropH2 : Nat.ble (71 + ((mlxOf PRE_first_tail_x2_r0_body.s61.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s62.ffi).next)) 96 = true
kernel_rfl bodyDropN2 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s61.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s62.ffi).nnext)) 0 = true
kernel_rfl bodyDv2 : bodyΘ.1.take 54 = bodyΘ.1.take 36 ++ PRE_first_tail_x2_r0_body.cws2
kernel_rfl bodyDe2 : bodyΘ.2.take 54 = bodyΘ.2.take 36 ++ PRE_first_tail_x2_r0_body.nr2.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st2.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 36) (bodyΘ.2.take 36)))
kernel_rfl bodyDl2 : (bodyΘ.1.take 36).length = (bodyΘ.2.take 36).length
kernel_rfl bodyDold2 : (bodyΘ.1.take 36).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws2).isNone && !PRE_first_tail_x2_r0_body.ws2.contains v) = true
kernel_rfl bodyDfree2 : (bodyΘ.2.take 54).all (fun e => (PRE_first_tail_x2_r0_body.cws2 ++ PRE_first_tail_x2_r0_body.ws2).all fun w => e.noVar w) = true

theorem bodyStep2 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6412, 71, 0, 36⟩ bodyM PRE_first_tail_x2_r0_body.s60 PRE_first_tail_x2_r0_body.S60)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7561, 96, 0, 54⟩ bodyM PRE_first_tail_x2_r0_body.s62 PRE_first_tail_x2_r0_body.S62) (11334 + 1) :=
  bodySite bodyFacts2.cfix bodyFacts2.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st2.S5.tab) (Es := bodyEs2) (qs := bodyQs2)
    (ok := PRE_first_tail_x2_r0_body.st2.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site2 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts2
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site2 r hr) hi (MapOk.sub hm (sub_of_all bodySub2)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk2 r hr) hi hm ho hq)
    bodyLq2 rfl bodyNrLo2 (postSub_sound bodyPost2)
    (Nat.le_of_ble_eq_true bodyDrop2) (by decide) (Nat.le_of_ble_eq_true bodyDropH2) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN2) (by decide)
    bodyDv2 bodyDe2 bodyDl2 bodyDold2 bodyDfree2 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site3 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site3 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site3) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st3.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site3
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st3.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st3.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s81 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s82 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S81 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws3 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st3.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st3.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso3
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_3
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st3.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot3
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup3
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound3
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace3
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged3
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws3.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st3.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S81.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_3]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen3.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh3
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl3 : Conv.NClean (⟨18393, 15476, 2682440, 465⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s81.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl3 (PRE_first_tail_x2_r0_body.cncl2 bodyNcl2)

theorem bodyClean3 : Conv.JClean (⟨18393, 15476, 2682440, 465⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s81 :=
  PRE_first_tail_x2_r0_body.gjcl3 (PRE_first_tail_x2_r0_body.cjcl2 bodyClean2)

kernel_rfl bodyJsLe3 : Nat.ble PRE_first_tail_x2_r0_body.s60.next PRE_first_tail_x2_r0_body.s81.next = true
kernel_rfl bodyJsList3 : (PRE_first_tail_x2_r0_body.gjh3 ++ PRE_first_tail_x2_r0_body.cl3).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s81.next) PRE_first_tail_x2_r0_body.s83) = true
theorem bodyJs3 : JsHeapAbove PRE_first_tail_x2_r0_body.s81.next PRE_first_tail_x2_r0_body.s83 :=
  JsHeapAbove.glueSite bodyJs2 (Nat.le_of_ble_eq_true bodyJsLe3) PRE_first_tail_x2_r0_body.gjk3 PRE_first_tail_x2_r0_body.gjbd3 PRE_first_tail_x2_r0_body.cheap3 PRE_first_tail_x2_r0_body.zclbd3 bodyJsList3

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO62 : PRE_first_tail_x2_r0_body.S62.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S62.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr62 : bridgeOf PRE_first_tail_x2_r0_body.s62.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc62 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s62 PRE_first_tail_x2_r0_body.S62) = fun _ _ => true
kernel_rfl bodyAcc63 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s63 PRE_first_tail_x2_r0_body.S63) = fun _ _ => true
kernel_rfl bodyBr64 : bridgeOf PRE_first_tail_x2_r0_body.s64.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt63 : isHalt PRE_first_tail_x2_r0_body.s63.ctl = false
kernel_rfl bodyTop64 : noRetBlock PRE_first_tail_x2_r0_body.s64 = true
kernel_rfl bodyCnt62 : countersOkB PRE_first_tail_x2_r0_body.s62 PRE_first_tail_x2_r0_body.s64 = true
kernel_rfl bodyO64 : PRE_first_tail_x2_r0_body.S64.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S64.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr65 : bridgeOf PRE_first_tail_x2_r0_body.s65.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt64 : countersOkB PRE_first_tail_x2_r0_body.s64 PRE_first_tail_x2_r0_body.s65 = true
kernel_rfl bodyO65 : PRE_first_tail_x2_r0_body.S65.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S65.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc65 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s65 PRE_first_tail_x2_r0_body.S65) = fun _ _ => true
kernel_rfl bodyAcc69 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s69 PRE_first_tail_x2_r0_body.S69) = fun _ _ => true
kernel_rfl bodyBr70 : bridgeOf PRE_first_tail_x2_r0_body.s70.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt69 : isHalt PRE_first_tail_x2_r0_body.s69.ctl = false
kernel_rfl bodyTop70 : noRetBlock PRE_first_tail_x2_r0_body.s70 = true
kernel_rfl bodyCnt65 : countersOkB PRE_first_tail_x2_r0_body.s65 PRE_first_tail_x2_r0_body.s70 = true
kernel_rfl bodyO70 : PRE_first_tail_x2_r0_body.S70.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S70.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr71 : bridgeOf PRE_first_tail_x2_r0_body.s71.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt70 : countersOkB PRE_first_tail_x2_r0_body.s70 PRE_first_tail_x2_r0_body.s71 = true
kernel_rfl bodyO71 : PRE_first_tail_x2_r0_body.S71.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S71.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc71 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s71 PRE_first_tail_x2_r0_body.S71) = fun _ _ => true
kernel_rfl bodyAcc73 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s73 PRE_first_tail_x2_r0_body.S73) = fun _ _ => true
kernel_rfl bodyBr74 : bridgeOf PRE_first_tail_x2_r0_body.s74.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt73 : isHalt PRE_first_tail_x2_r0_body.s73.ctl = false
kernel_rfl bodyTop74 : noRetBlock PRE_first_tail_x2_r0_body.s74 = true
kernel_rfl bodyCnt71 : countersOkB PRE_first_tail_x2_r0_body.s71 PRE_first_tail_x2_r0_body.s74 = true
kernel_rfl bodyO74 : PRE_first_tail_x2_r0_body.S74.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S74.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr75 : bridgeOf PRE_first_tail_x2_r0_body.s75.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt74 : countersOkB PRE_first_tail_x2_r0_body.s74 PRE_first_tail_x2_r0_body.s75 = true
kernel_rfl bodyO75 : PRE_first_tail_x2_r0_body.S75.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S75.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc75 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s75 PRE_first_tail_x2_r0_body.S75) = fun _ _ => true
kernel_rfl bodyAcc76 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s76 PRE_first_tail_x2_r0_body.S76) = fun _ _ => true
kernel_rfl bodyBr77 : bridgeOf PRE_first_tail_x2_r0_body.s77.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt76 : isHalt PRE_first_tail_x2_r0_body.s76.ctl = false
kernel_rfl bodyTop77 : noRetBlock PRE_first_tail_x2_r0_body.s77 = true
kernel_rfl bodyCnt75 : countersOkB PRE_first_tail_x2_r0_body.s75 PRE_first_tail_x2_r0_body.s77 = true
kernel_rfl bodyO77 : PRE_first_tail_x2_r0_body.S77.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S77.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr78 : bridgeOf PRE_first_tail_x2_r0_body.s78.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt77 : countersOkB PRE_first_tail_x2_r0_body.s77 PRE_first_tail_x2_r0_body.s78 = true
kernel_rfl bodyO78 : PRE_first_tail_x2_r0_body.S78.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S78.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc78 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s78 PRE_first_tail_x2_r0_body.S78) = fun _ _ => true
kernel_rfl bodyAcc80 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s80 PRE_first_tail_x2_r0_body.S80) = fun _ _ => true
kernel_rfl bodyBr81 : bridgeOf PRE_first_tail_x2_r0_body.s81.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt80 : isHalt PRE_first_tail_x2_r0_body.s80.ctl = false
kernel_rfl bodyTop81 : noRetBlock PRE_first_tail_x2_r0_body.s81 = true
kernel_rfl bodyCnt78 : countersOkB PRE_first_tail_x2_r0_body.s78 PRE_first_tail_x2_r0_body.s81 = true

theorem bodyGlue3 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7561, 96, 0, 54⟩ bodyM PRE_first_tail_x2_r0_body.s62 PRE_first_tail_x2_r0_body.S62)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7561, 96, 0, 54⟩ bodyM PRE_first_tail_x2_r0_body.s81 PRE_first_tail_x2_r0_body.S81) 24692 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) bodyAcc62 PRE_first_tail_x2_r0_body.bodyRunSeg17 bodyAcc63 bodyHalt63 PRE_first_tail_x2_r0_body.bodyStepA18 bodyTop64 (fun _ hm => bodyO62 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr62).trans bodyInactive0) (bodyBr64.trans bodyBr62.symm) bodyCnt62 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) PRE_first_tail_x2_r0_body.sizeA18 PRE_first_tail_x2_r0_body.sizeArgsA18 PRE_first_tail_x2_r0_body.sizeSymA18 PRE_first_tail_x2_r0_body.sizeMlxA18 PRE_first_tail_x2_r0_body.sizePayA18 PRE_first_tail_x2_r0_body.sizeTaA18 PRE_first_tail_x2_r0_body.sizeDecA18 PRE_first_tail_x2_r0_body.sizePreA18 PRE_first_tail_x2_r0_body.bodyPatchB18 (fun _ hm => bodyO64 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr64).trans bodyInactive0) (bodyBr65.trans bodyBr64.symm) bodyCnt64 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) bodyAcc65 PRE_first_tail_x2_r0_body.bodyRunSeg18 bodyAcc69 bodyHalt69 PRE_first_tail_x2_r0_body.bodyStepA19 bodyTop70 (fun _ hm => bodyO65 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr65).trans bodyInactive0) (bodyBr70.trans bodyBr65.symm) bodyCnt65 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) PRE_first_tail_x2_r0_body.sizeA19 PRE_first_tail_x2_r0_body.sizeArgsA19 PRE_first_tail_x2_r0_body.sizeSymA19 PRE_first_tail_x2_r0_body.sizeMlxA19 PRE_first_tail_x2_r0_body.sizePayA19 PRE_first_tail_x2_r0_body.sizeTaA19 PRE_first_tail_x2_r0_body.sizeDecA19 PRE_first_tail_x2_r0_body.sizePreA19 PRE_first_tail_x2_r0_body.bodyPatchB19 (fun _ hm => bodyO70 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr70).trans bodyInactive0) (bodyBr71.trans bodyBr70.symm) bodyCnt70 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) bodyAcc71 PRE_first_tail_x2_r0_body.bodyRunSeg19 bodyAcc73 bodyHalt73 PRE_first_tail_x2_r0_body.bodyStepA20 bodyTop74 (fun _ hm => bodyO71 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr71).trans bodyInactive0) (bodyBr74.trans bodyBr71.symm) bodyCnt71 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) PRE_first_tail_x2_r0_body.sizeA20 PRE_first_tail_x2_r0_body.sizeArgsA20 PRE_first_tail_x2_r0_body.sizeSymA20 PRE_first_tail_x2_r0_body.sizeMlxA20 PRE_first_tail_x2_r0_body.sizePayA20 PRE_first_tail_x2_r0_body.sizeTaA20 PRE_first_tail_x2_r0_body.sizeDecA20 PRE_first_tail_x2_r0_body.sizePreA20 PRE_first_tail_x2_r0_body.bodyPatchB20 (fun _ hm => bodyO74 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr74).trans bodyInactive0) (bodyBr75.trans bodyBr74.symm) bodyCnt74 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) bodyAcc75 PRE_first_tail_x2_r0_body.bodyRunSeg20 bodyAcc76 bodyHalt76 PRE_first_tail_x2_r0_body.bodyStepA21 bodyTop77 (fun _ hm => bodyO75 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr75).trans bodyInactive0) (bodyBr77.trans bodyBr75.symm) bodyCnt75 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) PRE_first_tail_x2_r0_body.sizeA21 PRE_first_tail_x2_r0_body.sizeArgsA21 PRE_first_tail_x2_r0_body.sizeSymA21 PRE_first_tail_x2_r0_body.sizeMlxA21 PRE_first_tail_x2_r0_body.sizePayA21 PRE_first_tail_x2_r0_body.sizeTaA21 PRE_first_tail_x2_r0_body.sizeDecA21 PRE_first_tail_x2_r0_body.sizePreA21 PRE_first_tail_x2_r0_body.bodyPatchB21 (fun _ hm => bodyO77 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr77).trans bodyInactive0) (bodyBr78.trans bodyBr77.symm) bodyCnt77 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7561, 96, 0, 54⟩) bodyAcc78 PRE_first_tail_x2_r0_body.bodyRunSeg21 bodyAcc80 bodyHalt80 PRE_first_tail_x2_r0_body.bodyStepA22 bodyTop81 (fun _ hm => bodyO78 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr78).trans bodyInactive0) (bodyBr81.trans bodyBr78.symm) bodyCnt78 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift3 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S81.tab.length PRE_first_tail_x2_r0_body.s81.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P3.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P3 474 PRE_first_tail_x2_r0_body.kappa3 PRE_first_tail_x2_r0_body.s83.ffi PRE_first_tail_x2_r0_body.s82.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_3
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_3
  have hcl : SSt (· < 474) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s83.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S81.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_3] <;> decide) PRE_first_tail_x2_r0_body.cnodesK3 PRE_first_tail_x2_r0_body.cobjsK3
      PRE_first_tail_x2_r0_body.citemsK3 PRE_first_tail_x2_r0_body.cbd3 PRE_first_tail_x2_r0_body.csst3
  exact PRE_first_tail_x2_r0_body.cshift3 bodyNcl3 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_3] at this; exact this)


kernel_rfl bodyFramesEmpty3 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s82 a).isEmpty) = true
kernel_rfl bodyJsRoots3 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s81.next) PRE_first_tail_x2_r0_body.s83.trace PRE_first_tail_x2_r0_body.s83 = true
kernel_rfl bodyJsNative3 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s83.ffi) = true
kernel_rfl bodyLow3 : (PRE_first_tail_x2_r0_body.cws3 ++ PRE_first_tail_x2_r0_body.ws3).all (Nat.ble 9) = true
kernel_rfl bodyCntM3 : countersOkB PRE_first_tail_x2_r0_body.s81 PRE_first_tail_x2_r0_body.s82 = true
kernel_rfl bodyHi3 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s83.ffi).next setupP.E = true
kernel_rfl bodyNhi3 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s83.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge3 : bridgeOf PRE_first_tail_x2_r0_body.s82.ffi = bridgeOf PRE_first_tail_x2_r0_body.s81.ffi
kernel_rfl bodyNN3 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s81.ffi).nnext PRE_first_tail_x2_r0_body.P3.NL = true
kernel_rfl bodyXn3 : Nat.ble (⟨18397, 15482, 2682455, 474⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s83.ffi).next = true
kernel_rfl bodyLo3 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s83.ffi).next = true
theorem bodyFacts3 : BodySiteFacts PRE_first_tail_x2_r0_body.s81 PRE_first_tail_x2_r0_body.s82 PRE_first_tail_x2_r0_body.s83 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S81 PRE_first_tail_x2_r0_body.S82 PRE_first_tail_x2_r0_body.S83
    PRE_first_tail_x2_r0_body.ws3 PRE_first_tail_x2_r0_body.cws3 PRE_first_tail_x2_r0_body.nr3 PRE_first_tail_x2_r0_body.pl3 PRE_first_tail_x2_r0_body.cl3 2682805 474 PRE_first_tail_x2_r0_body.kd3 PRE_first_tail_x2_r0_body.kappa3 PRE_first_tail_x2_r0_body.P3
    ⟨18393, 15476, 2682440, 465⟩ ⟨18397, 15482, 2682455, 474⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap3
  clean := bodyClean3
  cfix := PRE_first_tail_x2_r0_body.cfix3
  zpl := PRE_first_tail_x2_r0_body.zpl3
  zplnd := PRE_first_tail_x2_r0_body.zplnd3
  zn1 := PRE_first_tail_x2_r0_body.zn13
  zfirst := PRE_first_tail_x2_r0_body.zfirst3
  zscn := PRE_first_tail_x2_r0_body.zscn3
  zsmn := PRE_first_tail_x2_r0_body.zsmn3
  zgrow := PRE_first_tail_x2_r0_body.zgrow3
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab3
  zfresh := PRE_first_tail_x2_r0_body.zfresh3
  zcnd := PRE_first_tail_x2_r0_body.zcnd3
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi3
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt3
  zgP := PRE_first_tail_x2_r0_body.zg3_2665
  zkP := PRE_first_tail_x2_r0_body.zk3_2665
  zmP := PRE_first_tail_x2_r0_body.zm3_2665
  zgC := PRE_first_tail_x2_r0_body.zg3_2673467
  zkC := PRE_first_tail_x2_r0_body.zk3_2673467
  zmC := PRE_first_tail_x2_r0_body.zm3_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw3_2673472
  zwV := PRE_first_tail_x2_r0_body.zw3_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap3
  zclbd := PRE_first_tail_x2_r0_body.zclbd3
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap3 PRE_first_tail_x2_r0_body.stFoot3 PRE_first_tail_x2_r0_body.iso3 PRE_first_tail_x2_r0_body.zwr3
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP3
  csupp := PRE_first_tail_x2_r0_body.csupp3
  cbound := PRE_first_tail_x2_r0_body.cbound3
  zimg := PRE_first_tail_x2_r0_body.zimg3
  zctl := PRE_first_tail_x2_r0_body.zctl3
  zstack := PRE_first_tail_x2_r0_body.zstack3
  zjobs := PRE_first_tail_x2_r0_body.zjobs3
  zstores := PRE_first_tail_x2_r0_body.zstores3
  zroots := PRE_first_tail_x2_r0_body.zroots3
  znC := PRE_first_tail_x2_r0_body.znC3
  ctab := PRE_first_tail_x2_r0_body.ctab3
  zbin := PRE_first_tail_x2_r0_body.zbin3
  cbridge := PRE_first_tail_x2_r0_body.cbridge3
  sbridge := bodyBridge3
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj3
  cshiftR := fun h hNL => bodyCshift3 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN3
  raised := PRE_first_tail_x2_r0_body.raised3
  cbigs := PRE_first_tail_x2_r0_body.cbigs3
  cjcl := PRE_first_tail_x2_r0_body.cjcl3
  xnLe := Nat.le_of_ble_eq_true bodyXn3
  loLe := Nat.le_of_ble_eq_true bodyLo3
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB3
  cntM := bodyCntM3
  hiLe := Nat.le_of_ble_eq_true bodyHi3
  nhiLe := Nat.le_of_ble_eq_true bodyNhi3
  jsHeap := bodyJs3
  jsRoots := bodyJsRoots3
  jsNative := bodyJsNative3
  framesEmpty := bodyFramesEmpty3
  trailOld := by decide
  lowVars := bodyLow3

def bodyQs3 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs3 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr3.map fun r => nth? PRE_first_tail_x2_r0_body.st3.S3.tab r
kernel_rfl bodyResChk3 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs3 bodyQs3) = true
kernel_rfl bodyLq3 : bodyQs3.length = PRE_first_tail_x2_r0_body.cws3.length
kernel_rfl bodyNrLo3 : PRE_first_tail_x2_r0_body.nr3.all (Nat.ble PRE_first_tail_x2_r0_body.S81.tab.length) = true
kernel_rfl bodySub3 : (Oracles.PRE_first_tail_x2_r0_body.map_site3.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost3 : postSubB bodyM PRE_first_tail_x2_r0_body.ws3 PRE_first_tail_x2_r0_body.cws3 bodyQs3 = true
kernel_rfl bodyDrop3 : Nat.ble (7561 + (PRE_first_tail_x2_r0_body.s82.next - PRE_first_tail_x2_r0_body.s83.next)) 7911 = true
kernel_rfl bodyDropH3 : Nat.ble (96 + ((mlxOf PRE_first_tail_x2_r0_body.s82.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s83.ffi).next)) 98 = true
kernel_rfl bodyDropN3 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s82.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s83.ffi).nnext)) 0 = true
kernel_rfl bodyDv3 : bodyΘ.1.take 63 = bodyΘ.1.take 54 ++ PRE_first_tail_x2_r0_body.cws3
kernel_rfl bodyDe3 : bodyΘ.2.take 63 = bodyΘ.2.take 54 ++ PRE_first_tail_x2_r0_body.nr3.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st3.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 54) (bodyΘ.2.take 54)))
kernel_rfl bodyDl3 : (bodyΘ.1.take 54).length = (bodyΘ.2.take 54).length
kernel_rfl bodyDold3 : (bodyΘ.1.take 54).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws3).isNone && !PRE_first_tail_x2_r0_body.ws3.contains v) = true
kernel_rfl bodyDfree3 : (bodyΘ.2.take 63).all (fun e => (PRE_first_tail_x2_r0_body.cws3 ++ PRE_first_tail_x2_r0_body.ws3).all fun w => e.noVar w) = true

theorem bodyStep3 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7561, 96, 0, 54⟩ bodyM PRE_first_tail_x2_r0_body.s81 PRE_first_tail_x2_r0_body.S81)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7911, 98, 0, 63⟩ bodyM PRE_first_tail_x2_r0_body.s83 PRE_first_tail_x2_r0_body.S83) (3452 + 1) :=
  bodySite bodyFacts3.cfix bodyFacts3.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x2_r0_body.st3.S3.tab) (Es := bodyEs3) (qs := bodyQs3)
    (ok := PRE_first_tail_x2_r0_body.st3.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site3 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts3
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site3 r hr) hi (MapOk.sub hm (sub_of_all bodySub3)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk3 r hr) hi hm ho hq)
    bodyLq3 rfl bodyNrLo3 (postSub_sound bodyPost3)
    (Nat.le_of_ble_eq_true bodyDrop3) (by decide) (Nat.le_of_ble_eq_true bodyDropH3) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN3) (by decide)
    bodyDv3 bodyDe3 bodyDl3 bodyDold3 bodyDfree3 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyOracles_1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_g4 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g4 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g4) (List.take 30 (List.drop 107 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site4 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site4 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site4) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st4.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g5 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g5 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g5) (List.take 27 (List.drop 137 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site5 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site5 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site5) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st5.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g6 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g6 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g6) (List.take 27 (List.drop 164 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site6 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site6 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site6) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st6.S0.oracle) = true

def PRE_first_tail_x2_r0_body.map_g7 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_g7 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_g7) (List.take 39 (List.drop 191 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.OR))) = true

def PRE_first_tail_x2_r0_body.map_site7 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site7 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site7) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st7.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site4 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site4 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site4) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st4.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site4
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st4.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st4.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s103 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s104 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S103 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws4 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st4.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st4.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso4
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_4
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st4.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot4
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup4
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound4
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace4
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged4
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws4.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st4.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S103.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_4]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen4.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh4
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl4 : Conv.NClean (⟨18452, 15515, 2684803, 585⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s103.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl4 (PRE_first_tail_x2_r0_body.cncl3 bodyNcl3)

theorem bodyClean4 : Conv.JClean (⟨18452, 15515, 2684803, 585⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s103 :=
  PRE_first_tail_x2_r0_body.gjcl4 (PRE_first_tail_x2_r0_body.cjcl3 bodyClean3)

kernel_rfl bodyJsLe4 : Nat.ble PRE_first_tail_x2_r0_body.s81.next PRE_first_tail_x2_r0_body.s103.next = true
kernel_rfl bodyJsList4 : (PRE_first_tail_x2_r0_body.gjh4 ++ PRE_first_tail_x2_r0_body.cl4).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s103.next) PRE_first_tail_x2_r0_body.s105) = true
theorem bodyJs4 : JsHeapAbove PRE_first_tail_x2_r0_body.s103.next PRE_first_tail_x2_r0_body.s105 :=
  JsHeapAbove.glueSite bodyJs3 (Nat.le_of_ble_eq_true bodyJsLe4) PRE_first_tail_x2_r0_body.gjk4 PRE_first_tail_x2_r0_body.gjbd4 PRE_first_tail_x2_r0_body.cheap4 PRE_first_tail_x2_r0_body.zclbd4 bodyJsList4

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO83 : PRE_first_tail_x2_r0_body.S83.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S83.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr83 : bridgeOf PRE_first_tail_x2_r0_body.s83.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc83 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s83 PRE_first_tail_x2_r0_body.S83) = fun _ _ => true
kernel_rfl bodyAcc84 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s84 PRE_first_tail_x2_r0_body.S84) = fun _ _ => true
kernel_rfl bodyBr85 : bridgeOf PRE_first_tail_x2_r0_body.s85.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt84 : isHalt PRE_first_tail_x2_r0_body.s84.ctl = false
kernel_rfl bodyTop85 : noRetBlock PRE_first_tail_x2_r0_body.s85 = true
kernel_rfl bodyCnt83 : countersOkB PRE_first_tail_x2_r0_body.s83 PRE_first_tail_x2_r0_body.s85 = true
kernel_rfl bodyO85 : PRE_first_tail_x2_r0_body.S85.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S85.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr86 : bridgeOf PRE_first_tail_x2_r0_body.s86.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt85 : countersOkB PRE_first_tail_x2_r0_body.s85 PRE_first_tail_x2_r0_body.s86 = true
kernel_rfl bodyO86 : PRE_first_tail_x2_r0_body.S86.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S86.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc86 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s86 PRE_first_tail_x2_r0_body.S86) = fun _ _ => true
kernel_rfl bodyAcc90 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s90 PRE_first_tail_x2_r0_body.S90) = fun _ _ => true
kernel_rfl bodyBr91 : bridgeOf PRE_first_tail_x2_r0_body.s91.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt90 : isHalt PRE_first_tail_x2_r0_body.s90.ctl = false
kernel_rfl bodyTop91 : noRetBlock PRE_first_tail_x2_r0_body.s91 = true
kernel_rfl bodyCnt86 : countersOkB PRE_first_tail_x2_r0_body.s86 PRE_first_tail_x2_r0_body.s91 = true
kernel_rfl bodyO91 : PRE_first_tail_x2_r0_body.S91.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S91.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr92 : bridgeOf PRE_first_tail_x2_r0_body.s92.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt91 : countersOkB PRE_first_tail_x2_r0_body.s91 PRE_first_tail_x2_r0_body.s92 = true
kernel_rfl bodyO92 : PRE_first_tail_x2_r0_body.S92.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S92.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc92 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s92 PRE_first_tail_x2_r0_body.S92) = fun _ _ => true
kernel_rfl bodyAcc93 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s93 PRE_first_tail_x2_r0_body.S93) = fun _ _ => true
kernel_rfl bodyBr94 : bridgeOf PRE_first_tail_x2_r0_body.s94.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt93 : isHalt PRE_first_tail_x2_r0_body.s93.ctl = false
kernel_rfl bodyTop94 : noRetBlock PRE_first_tail_x2_r0_body.s94 = true
kernel_rfl bodyCnt92 : countersOkB PRE_first_tail_x2_r0_body.s92 PRE_first_tail_x2_r0_body.s94 = true
kernel_rfl bodyO94 : PRE_first_tail_x2_r0_body.S94.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S94.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr95 : bridgeOf PRE_first_tail_x2_r0_body.s95.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt94 : countersOkB PRE_first_tail_x2_r0_body.s94 PRE_first_tail_x2_r0_body.s95 = true
kernel_rfl bodyO95 : PRE_first_tail_x2_r0_body.S95.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S95.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc95 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s95 PRE_first_tail_x2_r0_body.S95) = fun _ _ => true
kernel_rfl bodyAcc96 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s96 PRE_first_tail_x2_r0_body.S96) = fun _ _ => true
kernel_rfl bodyBr97 : bridgeOf PRE_first_tail_x2_r0_body.s97.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt96 : isHalt PRE_first_tail_x2_r0_body.s96.ctl = false
kernel_rfl bodyTop97 : noRetBlock PRE_first_tail_x2_r0_body.s97 = true
kernel_rfl bodyCnt95 : countersOkB PRE_first_tail_x2_r0_body.s95 PRE_first_tail_x2_r0_body.s97 = true
kernel_rfl bodyO97 : PRE_first_tail_x2_r0_body.S97.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S97.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr98 : bridgeOf PRE_first_tail_x2_r0_body.s98.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt97 : countersOkB PRE_first_tail_x2_r0_body.s97 PRE_first_tail_x2_r0_body.s98 = true
kernel_rfl bodyO98 : PRE_first_tail_x2_r0_body.S98.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S98.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc98 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s98 PRE_first_tail_x2_r0_body.S98) = fun _ _ => true
kernel_rfl bodyAcc99 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s99 PRE_first_tail_x2_r0_body.S99) = fun _ _ => true
kernel_rfl bodyBr100 : bridgeOf PRE_first_tail_x2_r0_body.s100.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt99 : isHalt PRE_first_tail_x2_r0_body.s99.ctl = false
kernel_rfl bodyTop100 : noRetBlock PRE_first_tail_x2_r0_body.s100 = true
kernel_rfl bodyCnt98 : countersOkB PRE_first_tail_x2_r0_body.s98 PRE_first_tail_x2_r0_body.s100 = true
kernel_rfl bodyO100 : PRE_first_tail_x2_r0_body.S100.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S100.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr101 : bridgeOf PRE_first_tail_x2_r0_body.s101.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt100 : countersOkB PRE_first_tail_x2_r0_body.s100 PRE_first_tail_x2_r0_body.s101 = true
kernel_rfl bodyO101 : PRE_first_tail_x2_r0_body.S101.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S101.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc101 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s101 PRE_first_tail_x2_r0_body.S101) = fun _ _ => true
kernel_rfl bodyAcc102 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s102 PRE_first_tail_x2_r0_body.S102) = fun _ _ => true
kernel_rfl bodyBr103 : bridgeOf PRE_first_tail_x2_r0_body.s103.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt102 : isHalt PRE_first_tail_x2_r0_body.s102.ctl = false
kernel_rfl bodyTop103 : noRetBlock PRE_first_tail_x2_r0_body.s103 = true
kernel_rfl bodyCnt101 : countersOkB PRE_first_tail_x2_r0_body.s101 PRE_first_tail_x2_r0_body.s103 = true

theorem bodyGlue4 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7911, 98, 0, 63⟩ bodyM PRE_first_tail_x2_r0_body.s83 PRE_first_tail_x2_r0_body.S83)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7911, 98, 0, 63⟩ bodyM PRE_first_tail_x2_r0_body.s103 PRE_first_tail_x2_r0_body.S103) 23361 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) bodyAcc83 PRE_first_tail_x2_r0_body.bodyRunSeg22 bodyAcc84 bodyHalt84 PRE_first_tail_x2_r0_body.bodyStepA23 bodyTop85 (fun _ hm => bodyO83 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr83).trans bodyInactive0) (bodyBr85.trans bodyBr83.symm) bodyCnt83 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) PRE_first_tail_x2_r0_body.sizeA23 PRE_first_tail_x2_r0_body.sizeArgsA23 PRE_first_tail_x2_r0_body.sizeSymA23 PRE_first_tail_x2_r0_body.sizeMlxA23 PRE_first_tail_x2_r0_body.sizePayA23 PRE_first_tail_x2_r0_body.sizeTaA23 PRE_first_tail_x2_r0_body.sizeDecA23 PRE_first_tail_x2_r0_body.sizePreA23 PRE_first_tail_x2_r0_body.bodyPatchB23 (fun _ hm => bodyO85 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr85).trans bodyInactive0) (bodyBr86.trans bodyBr85.symm) bodyCnt85 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) bodyAcc86 PRE_first_tail_x2_r0_body.bodyRunSeg23 bodyAcc90 bodyHalt90 PRE_first_tail_x2_r0_body.bodyStepA24 bodyTop91 (fun _ hm => bodyO86 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr86).trans bodyInactive0) (bodyBr91.trans bodyBr86.symm) bodyCnt86 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) PRE_first_tail_x2_r0_body.sizeA24 PRE_first_tail_x2_r0_body.sizeArgsA24 PRE_first_tail_x2_r0_body.sizeSymA24 PRE_first_tail_x2_r0_body.sizeMlxA24 PRE_first_tail_x2_r0_body.sizePayA24 PRE_first_tail_x2_r0_body.sizeTaA24 PRE_first_tail_x2_r0_body.sizeDecA24 PRE_first_tail_x2_r0_body.sizePreA24 PRE_first_tail_x2_r0_body.bodyPatchB24 (fun _ hm => bodyO91 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr91).trans bodyInactive0) (bodyBr92.trans bodyBr91.symm) bodyCnt91 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) bodyAcc92 PRE_first_tail_x2_r0_body.bodyRunSeg24 bodyAcc93 bodyHalt93 PRE_first_tail_x2_r0_body.bodyStepA25 bodyTop94 (fun _ hm => bodyO92 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr92).trans bodyInactive0) (bodyBr94.trans bodyBr92.symm) bodyCnt92 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) PRE_first_tail_x2_r0_body.sizeA25 PRE_first_tail_x2_r0_body.sizeArgsA25 PRE_first_tail_x2_r0_body.sizeSymA25 PRE_first_tail_x2_r0_body.sizeMlxA25 PRE_first_tail_x2_r0_body.sizePayA25 PRE_first_tail_x2_r0_body.sizeTaA25 PRE_first_tail_x2_r0_body.sizeDecA25 PRE_first_tail_x2_r0_body.sizePreA25 PRE_first_tail_x2_r0_body.bodyPatchB25 (fun _ hm => bodyO94 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr94).trans bodyInactive0) (bodyBr95.trans bodyBr94.symm) bodyCnt94 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) bodyAcc95 PRE_first_tail_x2_r0_body.bodyRunSeg25 bodyAcc96 bodyHalt96 PRE_first_tail_x2_r0_body.bodyStepA26 bodyTop97 (fun _ hm => bodyO95 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr95).trans bodyInactive0) (bodyBr97.trans bodyBr95.symm) bodyCnt95 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) PRE_first_tail_x2_r0_body.sizeA26 PRE_first_tail_x2_r0_body.sizeArgsA26 PRE_first_tail_x2_r0_body.sizeSymA26 PRE_first_tail_x2_r0_body.sizeMlxA26 PRE_first_tail_x2_r0_body.sizePayA26 PRE_first_tail_x2_r0_body.sizeTaA26 PRE_first_tail_x2_r0_body.sizeDecA26 PRE_first_tail_x2_r0_body.sizePreA26 PRE_first_tail_x2_r0_body.bodyPatchB26 (fun _ hm => bodyO97 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr97).trans bodyInactive0) (bodyBr98.trans bodyBr97.symm) bodyCnt97 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) bodyAcc98 PRE_first_tail_x2_r0_body.bodyRunSeg26 bodyAcc99 bodyHalt99 PRE_first_tail_x2_r0_body.bodyStepA27 bodyTop100 (fun _ hm => bodyO98 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr98).trans bodyInactive0) (bodyBr100.trans bodyBr98.symm) bodyCnt98 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) PRE_first_tail_x2_r0_body.sizeA27 PRE_first_tail_x2_r0_body.sizeArgsA27 PRE_first_tail_x2_r0_body.sizeSymA27 PRE_first_tail_x2_r0_body.sizeMlxA27 PRE_first_tail_x2_r0_body.sizePayA27 PRE_first_tail_x2_r0_body.sizeTaA27 PRE_first_tail_x2_r0_body.sizeDecA27 PRE_first_tail_x2_r0_body.sizePreA27 PRE_first_tail_x2_r0_body.bodyPatchB27 (fun _ hm => bodyO100 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr100).trans bodyInactive0) (bodyBr101.trans bodyBr100.symm) bodyCnt100 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7911, 98, 0, 63⟩) bodyAcc101 PRE_first_tail_x2_r0_body.bodyRunSeg27 bodyAcc102 bodyHalt102 PRE_first_tail_x2_r0_body.bodyStepA28 bodyTop103 (fun _ hm => bodyO101 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr101).trans bodyInactive0) (bodyBr103.trans bodyBr101.symm) bodyCnt101 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift4 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S103.tab.length PRE_first_tail_x2_r0_body.s103.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P4.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P4 603 PRE_first_tail_x2_r0_body.kappa4 PRE_first_tail_x2_r0_body.s105.ffi PRE_first_tail_x2_r0_body.s104.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_4
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_4
  have hcl : SSt (· < 603) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s105.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S103.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_4] <;> decide) PRE_first_tail_x2_r0_body.cnodesK4 PRE_first_tail_x2_r0_body.cobjsK4
      PRE_first_tail_x2_r0_body.citemsK4 PRE_first_tail_x2_r0_body.cbd4 PRE_first_tail_x2_r0_body.csst4
  exact PRE_first_tail_x2_r0_body.cshift4 bodyNcl4 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_4] at this; exact this)


kernel_rfl bodyFramesEmpty4 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s104 a).isEmpty) = true
kernel_rfl bodyJsRoots4 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s103.next) PRE_first_tail_x2_r0_body.s105.trace PRE_first_tail_x2_r0_body.s105 = true
kernel_rfl bodyJsNative4 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s105.ffi) = true
kernel_rfl bodyLow4 : (PRE_first_tail_x2_r0_body.cws4 ++ PRE_first_tail_x2_r0_body.ws4).all (Nat.ble 9) = true
kernel_rfl bodyCntM4 : countersOkB PRE_first_tail_x2_r0_body.s103 PRE_first_tail_x2_r0_body.s104 = true
kernel_rfl bodyHi4 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s105.ffi).next setupP.E = true
kernel_rfl bodyNhi4 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s105.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge4 : bridgeOf PRE_first_tail_x2_r0_body.s104.ffi = bridgeOf PRE_first_tail_x2_r0_body.s103.ffi
kernel_rfl bodyNN4 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s103.ffi).nnext PRE_first_tail_x2_r0_body.P4.NL = true
kernel_rfl bodyXn4 : Nat.ble (⟨18455, 15542, 2684809, 603⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s105.ffi).next = true
kernel_rfl bodyLo4 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s105.ffi).next = true
theorem bodyFacts4 : BodySiteFacts PRE_first_tail_x2_r0_body.s103 PRE_first_tail_x2_r0_body.s104 PRE_first_tail_x2_r0_body.s105 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S103 PRE_first_tail_x2_r0_body.S104 PRE_first_tail_x2_r0_body.S105
    PRE_first_tail_x2_r0_body.ws4 PRE_first_tail_x2_r0_body.cws4 PRE_first_tail_x2_r0_body.nr4 PRE_first_tail_x2_r0_body.pl4 PRE_first_tail_x2_r0_body.cl4 2685958 603 PRE_first_tail_x2_r0_body.kd4 PRE_first_tail_x2_r0_body.kappa4 PRE_first_tail_x2_r0_body.P4
    ⟨18452, 15515, 2684803, 585⟩ ⟨18455, 15542, 2684809, 603⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap4
  clean := bodyClean4
  cfix := PRE_first_tail_x2_r0_body.cfix4
  zpl := PRE_first_tail_x2_r0_body.zpl4
  zplnd := PRE_first_tail_x2_r0_body.zplnd4
  zn1 := PRE_first_tail_x2_r0_body.zn14
  zfirst := PRE_first_tail_x2_r0_body.zfirst4
  zscn := PRE_first_tail_x2_r0_body.zscn4
  zsmn := PRE_first_tail_x2_r0_body.zsmn4
  zgrow := PRE_first_tail_x2_r0_body.zgrow4
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab4
  zfresh := PRE_first_tail_x2_r0_body.zfresh4
  zcnd := PRE_first_tail_x2_r0_body.zcnd4
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi4
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt4
  zgP := PRE_first_tail_x2_r0_body.zg4_2665
  zkP := PRE_first_tail_x2_r0_body.zk4_2665
  zmP := PRE_first_tail_x2_r0_body.zm4_2665
  zgC := PRE_first_tail_x2_r0_body.zg4_2673467
  zkC := PRE_first_tail_x2_r0_body.zk4_2673467
  zmC := PRE_first_tail_x2_r0_body.zm4_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw4_2673472
  zwV := PRE_first_tail_x2_r0_body.zw4_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap4
  zclbd := PRE_first_tail_x2_r0_body.zclbd4
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap4 PRE_first_tail_x2_r0_body.stFoot4 PRE_first_tail_x2_r0_body.iso4 PRE_first_tail_x2_r0_body.zwr4
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP4
  csupp := PRE_first_tail_x2_r0_body.csupp4
  cbound := PRE_first_tail_x2_r0_body.cbound4
  zimg := PRE_first_tail_x2_r0_body.zimg4
  zctl := PRE_first_tail_x2_r0_body.zctl4
  zstack := PRE_first_tail_x2_r0_body.zstack4
  zjobs := PRE_first_tail_x2_r0_body.zjobs4
  zstores := PRE_first_tail_x2_r0_body.zstores4
  zroots := PRE_first_tail_x2_r0_body.zroots4
  znC := PRE_first_tail_x2_r0_body.znC4
  ctab := PRE_first_tail_x2_r0_body.ctab4
  zbin := PRE_first_tail_x2_r0_body.zbin4
  cbridge := PRE_first_tail_x2_r0_body.cbridge4
  sbridge := bodyBridge4
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj4
  cshiftR := fun h hNL => bodyCshift4 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN4
  raised := PRE_first_tail_x2_r0_body.raised4
  cbigs := PRE_first_tail_x2_r0_body.cbigs4
  cjcl := PRE_first_tail_x2_r0_body.cjcl4
  xnLe := Nat.le_of_ble_eq_true bodyXn4
  loLe := Nat.le_of_ble_eq_true bodyLo4
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB4
  cntM := bodyCntM4
  hiLe := Nat.le_of_ble_eq_true bodyHi4
  nhiLe := Nat.le_of_ble_eq_true bodyNhi4
  jsHeap := bodyJs4
  jsRoots := bodyJsRoots4
  jsNative := bodyJsNative4
  framesEmpty := bodyFramesEmpty4
  trailOld := by decide
  lowVars := bodyLow4

def bodyQs4 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs4 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr4.map fun r => nth? PRE_first_tail_x2_r0_body.st4.S5.tab r
kernel_rfl bodyResChk4 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs4 bodyQs4) = true
kernel_rfl bodyLq4 : bodyQs4.length = PRE_first_tail_x2_r0_body.cws4.length
kernel_rfl bodyNrLo4 : PRE_first_tail_x2_r0_body.nr4.all (Nat.ble PRE_first_tail_x2_r0_body.S103.tab.length) = true
kernel_rfl bodySub4 : (Oracles.PRE_first_tail_x2_r0_body.map_site4.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost4 : postSubB bodyM PRE_first_tail_x2_r0_body.ws4 PRE_first_tail_x2_r0_body.cws4 bodyQs4 = true
kernel_rfl bodyDrop4 : Nat.ble (7911 + (PRE_first_tail_x2_r0_body.s104.next - PRE_first_tail_x2_r0_body.s105.next)) 9060 = true
kernel_rfl bodyDropH4 : Nat.ble (98 + ((mlxOf PRE_first_tail_x2_r0_body.s104.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s105.ffi).next)) 123 = true
kernel_rfl bodyDropN4 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s104.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s105.ffi).nnext)) 0 = true
kernel_rfl bodyDv4 : bodyΘ.1.take 81 = bodyΘ.1.take 63 ++ PRE_first_tail_x2_r0_body.cws4
kernel_rfl bodyDe4 : bodyΘ.2.take 81 = bodyΘ.2.take 63 ++ PRE_first_tail_x2_r0_body.nr4.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st4.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 63) (bodyΘ.2.take 63)))
kernel_rfl bodyDl4 : (bodyΘ.1.take 63).length = (bodyΘ.2.take 63).length
kernel_rfl bodyDold4 : (bodyΘ.1.take 63).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws4).isNone && !PRE_first_tail_x2_r0_body.ws4.contains v) = true
kernel_rfl bodyDfree4 : (bodyΘ.2.take 81).all (fun e => (PRE_first_tail_x2_r0_body.cws4 ++ PRE_first_tail_x2_r0_body.ws4).all fun w => e.noVar w) = true

theorem bodyStep4 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7911, 98, 0, 63⟩ bodyM PRE_first_tail_x2_r0_body.s103 PRE_first_tail_x2_r0_body.S103)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9060, 123, 0, 81⟩ bodyM PRE_first_tail_x2_r0_body.s105 PRE_first_tail_x2_r0_body.S105) (11334 + 1) :=
  bodySite bodyFacts4.cfix bodyFacts4.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st4.S5.tab) (Es := bodyEs4) (qs := bodyQs4)
    (ok := PRE_first_tail_x2_r0_body.st4.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site4 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts4
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site4 r hr) hi (MapOk.sub hm (sub_of_all bodySub4)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk4 r hr) hi hm ho hq)
    bodyLq4 rfl bodyNrLo4 (postSub_sound bodyPost4)
    (Nat.le_of_ble_eq_true bodyDrop4) (by decide) (Nat.le_of_ble_eq_true bodyDropH4) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN4) (by decide)
    bodyDv4 bodyDe4 bodyDl4 bodyDold4 bodyDfree4 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site5 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site5 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site5) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st5.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site5
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st5.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st5.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s125 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s126 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S125 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws5 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st5.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st5.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso5
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_5
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st5.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot5
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup5
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound5
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace5
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged5
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws5.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st5.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S125.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_5]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen5.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh5
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl5 : Conv.NClean (⟨18509, 15578, 2687041, 711⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s125.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl5 (PRE_first_tail_x2_r0_body.cncl4 bodyNcl4)

theorem bodyClean5 : Conv.JClean (⟨18509, 15578, 2687041, 711⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s125 :=
  PRE_first_tail_x2_r0_body.gjcl5 (PRE_first_tail_x2_r0_body.cjcl4 bodyClean4)

kernel_rfl bodyJsLe5 : Nat.ble PRE_first_tail_x2_r0_body.s103.next PRE_first_tail_x2_r0_body.s125.next = true
kernel_rfl bodyJsList5 : (PRE_first_tail_x2_r0_body.gjh5 ++ PRE_first_tail_x2_r0_body.cl5).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s125.next) PRE_first_tail_x2_r0_body.s127) = true
theorem bodyJs5 : JsHeapAbove PRE_first_tail_x2_r0_body.s125.next PRE_first_tail_x2_r0_body.s127 :=
  JsHeapAbove.glueSite bodyJs4 (Nat.le_of_ble_eq_true bodyJsLe5) PRE_first_tail_x2_r0_body.gjk5 PRE_first_tail_x2_r0_body.gjbd5 PRE_first_tail_x2_r0_body.cheap5 PRE_first_tail_x2_r0_body.zclbd5 bodyJsList5

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO105 : PRE_first_tail_x2_r0_body.S105.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S105.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr105 : bridgeOf PRE_first_tail_x2_r0_body.s105.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc105 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s105 PRE_first_tail_x2_r0_body.S105) = fun _ _ => true
kernel_rfl bodyAcc106 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s106 PRE_first_tail_x2_r0_body.S106) = fun _ _ => true
kernel_rfl bodyBr107 : bridgeOf PRE_first_tail_x2_r0_body.s107.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt106 : isHalt PRE_first_tail_x2_r0_body.s106.ctl = false
kernel_rfl bodyTop107 : noRetBlock PRE_first_tail_x2_r0_body.s107 = true
kernel_rfl bodyCnt105 : countersOkB PRE_first_tail_x2_r0_body.s105 PRE_first_tail_x2_r0_body.s107 = true
kernel_rfl bodyO107 : PRE_first_tail_x2_r0_body.S107.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S107.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr108 : bridgeOf PRE_first_tail_x2_r0_body.s108.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt107 : countersOkB PRE_first_tail_x2_r0_body.s107 PRE_first_tail_x2_r0_body.s108 = true
kernel_rfl bodyO108 : PRE_first_tail_x2_r0_body.S108.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S108.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc108 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s108 PRE_first_tail_x2_r0_body.S108) = fun _ _ => true
kernel_rfl bodyAcc112 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s112 PRE_first_tail_x2_r0_body.S112) = fun _ _ => true
kernel_rfl bodyBr113 : bridgeOf PRE_first_tail_x2_r0_body.s113.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt112 : isHalt PRE_first_tail_x2_r0_body.s112.ctl = false
kernel_rfl bodyTop113 : noRetBlock PRE_first_tail_x2_r0_body.s113 = true
kernel_rfl bodyCnt108 : countersOkB PRE_first_tail_x2_r0_body.s108 PRE_first_tail_x2_r0_body.s113 = true
kernel_rfl bodyO113 : PRE_first_tail_x2_r0_body.S113.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S113.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr114 : bridgeOf PRE_first_tail_x2_r0_body.s114.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt113 : countersOkB PRE_first_tail_x2_r0_body.s113 PRE_first_tail_x2_r0_body.s114 = true
kernel_rfl bodyO114 : PRE_first_tail_x2_r0_body.S114.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S114.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc114 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s114 PRE_first_tail_x2_r0_body.S114) = fun _ _ => true
kernel_rfl bodyAcc115 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s115 PRE_first_tail_x2_r0_body.S115) = fun _ _ => true
kernel_rfl bodyBr116 : bridgeOf PRE_first_tail_x2_r0_body.s116.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt115 : isHalt PRE_first_tail_x2_r0_body.s115.ctl = false
kernel_rfl bodyTop116 : noRetBlock PRE_first_tail_x2_r0_body.s116 = true
kernel_rfl bodyCnt114 : countersOkB PRE_first_tail_x2_r0_body.s114 PRE_first_tail_x2_r0_body.s116 = true
kernel_rfl bodyO116 : PRE_first_tail_x2_r0_body.S116.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S116.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr117 : bridgeOf PRE_first_tail_x2_r0_body.s117.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt116 : countersOkB PRE_first_tail_x2_r0_body.s116 PRE_first_tail_x2_r0_body.s117 = true
kernel_rfl bodyO117 : PRE_first_tail_x2_r0_body.S117.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S117.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc117 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s117 PRE_first_tail_x2_r0_body.S117) = fun _ _ => true
kernel_rfl bodyAcc118 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s118 PRE_first_tail_x2_r0_body.S118) = fun _ _ => true
kernel_rfl bodyBr119 : bridgeOf PRE_first_tail_x2_r0_body.s119.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt118 : isHalt PRE_first_tail_x2_r0_body.s118.ctl = false
kernel_rfl bodyTop119 : noRetBlock PRE_first_tail_x2_r0_body.s119 = true
kernel_rfl bodyCnt117 : countersOkB PRE_first_tail_x2_r0_body.s117 PRE_first_tail_x2_r0_body.s119 = true
kernel_rfl bodyO119 : PRE_first_tail_x2_r0_body.S119.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S119.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr120 : bridgeOf PRE_first_tail_x2_r0_body.s120.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt119 : countersOkB PRE_first_tail_x2_r0_body.s119 PRE_first_tail_x2_r0_body.s120 = true
kernel_rfl bodyO120 : PRE_first_tail_x2_r0_body.S120.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S120.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc120 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s120 PRE_first_tail_x2_r0_body.S120) = fun _ _ => true
kernel_rfl bodyAcc121 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s121 PRE_first_tail_x2_r0_body.S121) = fun _ _ => true
kernel_rfl bodyBr122 : bridgeOf PRE_first_tail_x2_r0_body.s122.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt121 : isHalt PRE_first_tail_x2_r0_body.s121.ctl = false
kernel_rfl bodyTop122 : noRetBlock PRE_first_tail_x2_r0_body.s122 = true
kernel_rfl bodyCnt120 : countersOkB PRE_first_tail_x2_r0_body.s120 PRE_first_tail_x2_r0_body.s122 = true
kernel_rfl bodyO122 : PRE_first_tail_x2_r0_body.S122.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S122.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr123 : bridgeOf PRE_first_tail_x2_r0_body.s123.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt122 : countersOkB PRE_first_tail_x2_r0_body.s122 PRE_first_tail_x2_r0_body.s123 = true
kernel_rfl bodyO123 : PRE_first_tail_x2_r0_body.S123.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S123.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc123 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s123 PRE_first_tail_x2_r0_body.S123) = fun _ _ => true
kernel_rfl bodyAcc124 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s124 PRE_first_tail_x2_r0_body.S124) = fun _ _ => true
kernel_rfl bodyBr125 : bridgeOf PRE_first_tail_x2_r0_body.s125.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt124 : isHalt PRE_first_tail_x2_r0_body.s124.ctl = false
kernel_rfl bodyTop125 : noRetBlock PRE_first_tail_x2_r0_body.s125 = true
kernel_rfl bodyCnt123 : countersOkB PRE_first_tail_x2_r0_body.s123 PRE_first_tail_x2_r0_body.s125 = true

theorem bodyGlue5 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9060, 123, 0, 81⟩ bodyM PRE_first_tail_x2_r0_body.s105 PRE_first_tail_x2_r0_body.S105)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9060, 123, 0, 81⟩ bodyM PRE_first_tail_x2_r0_body.s125 PRE_first_tail_x2_r0_body.S125) 22217 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) bodyAcc105 PRE_first_tail_x2_r0_body.bodyRunSeg28 bodyAcc106 bodyHalt106 PRE_first_tail_x2_r0_body.bodyStepA29 bodyTop107 (fun _ hm => bodyO105 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr105).trans bodyInactive0) (bodyBr107.trans bodyBr105.symm) bodyCnt105 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) PRE_first_tail_x2_r0_body.sizeA29 PRE_first_tail_x2_r0_body.sizeArgsA29 PRE_first_tail_x2_r0_body.sizeSymA29 PRE_first_tail_x2_r0_body.sizeMlxA29 PRE_first_tail_x2_r0_body.sizePayA29 PRE_first_tail_x2_r0_body.sizeTaA29 PRE_first_tail_x2_r0_body.sizeDecA29 PRE_first_tail_x2_r0_body.sizePreA29 PRE_first_tail_x2_r0_body.bodyPatchB29 (fun _ hm => bodyO107 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr107).trans bodyInactive0) (bodyBr108.trans bodyBr107.symm) bodyCnt107 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) bodyAcc108 PRE_first_tail_x2_r0_body.bodyRunSeg29 bodyAcc112 bodyHalt112 PRE_first_tail_x2_r0_body.bodyStepA30 bodyTop113 (fun _ hm => bodyO108 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr108).trans bodyInactive0) (bodyBr113.trans bodyBr108.symm) bodyCnt108 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) PRE_first_tail_x2_r0_body.sizeA30 PRE_first_tail_x2_r0_body.sizeArgsA30 PRE_first_tail_x2_r0_body.sizeSymA30 PRE_first_tail_x2_r0_body.sizeMlxA30 PRE_first_tail_x2_r0_body.sizePayA30 PRE_first_tail_x2_r0_body.sizeTaA30 PRE_first_tail_x2_r0_body.sizeDecA30 PRE_first_tail_x2_r0_body.sizePreA30 PRE_first_tail_x2_r0_body.bodyPatchB30 (fun _ hm => bodyO113 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr113).trans bodyInactive0) (bodyBr114.trans bodyBr113.symm) bodyCnt113 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) bodyAcc114 PRE_first_tail_x2_r0_body.bodyRunSeg30 bodyAcc115 bodyHalt115 PRE_first_tail_x2_r0_body.bodyStepA31 bodyTop116 (fun _ hm => bodyO114 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr114).trans bodyInactive0) (bodyBr116.trans bodyBr114.symm) bodyCnt114 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) PRE_first_tail_x2_r0_body.sizeA31 PRE_first_tail_x2_r0_body.sizeArgsA31 PRE_first_tail_x2_r0_body.sizeSymA31 PRE_first_tail_x2_r0_body.sizeMlxA31 PRE_first_tail_x2_r0_body.sizePayA31 PRE_first_tail_x2_r0_body.sizeTaA31 PRE_first_tail_x2_r0_body.sizeDecA31 PRE_first_tail_x2_r0_body.sizePreA31 PRE_first_tail_x2_r0_body.bodyPatchB31 (fun _ hm => bodyO116 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr116).trans bodyInactive0) (bodyBr117.trans bodyBr116.symm) bodyCnt116 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) bodyAcc117 PRE_first_tail_x2_r0_body.bodyRunSeg31 bodyAcc118 bodyHalt118 PRE_first_tail_x2_r0_body.bodyStepA32 bodyTop119 (fun _ hm => bodyO117 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr117).trans bodyInactive0) (bodyBr119.trans bodyBr117.symm) bodyCnt117 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) PRE_first_tail_x2_r0_body.sizeA32 PRE_first_tail_x2_r0_body.sizeArgsA32 PRE_first_tail_x2_r0_body.sizeSymA32 PRE_first_tail_x2_r0_body.sizeMlxA32 PRE_first_tail_x2_r0_body.sizePayA32 PRE_first_tail_x2_r0_body.sizeTaA32 PRE_first_tail_x2_r0_body.sizeDecA32 PRE_first_tail_x2_r0_body.sizePreA32 PRE_first_tail_x2_r0_body.bodyPatchB32 (fun _ hm => bodyO119 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr119).trans bodyInactive0) (bodyBr120.trans bodyBr119.symm) bodyCnt119 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) bodyAcc120 PRE_first_tail_x2_r0_body.bodyRunSeg32 bodyAcc121 bodyHalt121 PRE_first_tail_x2_r0_body.bodyStepA33 bodyTop122 (fun _ hm => bodyO120 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr120).trans bodyInactive0) (bodyBr122.trans bodyBr120.symm) bodyCnt120 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) PRE_first_tail_x2_r0_body.sizeA33 PRE_first_tail_x2_r0_body.sizeArgsA33 PRE_first_tail_x2_r0_body.sizeSymA33 PRE_first_tail_x2_r0_body.sizeMlxA33 PRE_first_tail_x2_r0_body.sizePayA33 PRE_first_tail_x2_r0_body.sizeTaA33 PRE_first_tail_x2_r0_body.sizeDecA33 PRE_first_tail_x2_r0_body.sizePreA33 PRE_first_tail_x2_r0_body.bodyPatchB33 (fun _ hm => bodyO122 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr122).trans bodyInactive0) (bodyBr123.trans bodyBr122.symm) bodyCnt122 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9060, 123, 0, 81⟩) bodyAcc123 PRE_first_tail_x2_r0_body.bodyRunSeg33 bodyAcc124 bodyHalt124 PRE_first_tail_x2_r0_body.bodyStepA34 bodyTop125 (fun _ hm => bodyO123 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr123).trans bodyInactive0) (bodyBr125.trans bodyBr123.symm) bodyCnt123 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift5 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S125.tab.length PRE_first_tail_x2_r0_body.s125.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P5.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P5 729 PRE_first_tail_x2_r0_body.kappa5 PRE_first_tail_x2_r0_body.s127.ffi PRE_first_tail_x2_r0_body.s126.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_5
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_5
  have hcl : SSt (· < 729) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s127.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S125.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_5] <;> decide) PRE_first_tail_x2_r0_body.cnodesK5 PRE_first_tail_x2_r0_body.cobjsK5
      PRE_first_tail_x2_r0_body.citemsK5 PRE_first_tail_x2_r0_body.cbd5 PRE_first_tail_x2_r0_body.csst5
  exact PRE_first_tail_x2_r0_body.cshift5 bodyNcl5 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_5] at this; exact this)


kernel_rfl bodyFramesEmpty5 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s126 a).isEmpty) = true
kernel_rfl bodyJsRoots5 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s125.next) PRE_first_tail_x2_r0_body.s127.trace PRE_first_tail_x2_r0_body.s127 = true
kernel_rfl bodyJsNative5 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s127.ffi) = true
kernel_rfl bodyLow5 : (PRE_first_tail_x2_r0_body.cws5 ++ PRE_first_tail_x2_r0_body.ws5).all (Nat.ble 9) = true
kernel_rfl bodyCntM5 : countersOkB PRE_first_tail_x2_r0_body.s125 PRE_first_tail_x2_r0_body.s126 = true
kernel_rfl bodyHi5 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s127.ffi).next setupP.E = true
kernel_rfl bodyNhi5 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s127.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge5 : bridgeOf PRE_first_tail_x2_r0_body.s126.ffi = bridgeOf PRE_first_tail_x2_r0_body.s125.ffi
kernel_rfl bodyNN5 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s125.ffi).nnext PRE_first_tail_x2_r0_body.P5.NL = true
kernel_rfl bodyXn5 : Nat.ble (⟨18512, 15605, 2687047, 729⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s127.ffi).next = true
kernel_rfl bodyLo5 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s127.ffi).next = true
theorem bodyFacts5 : BodySiteFacts PRE_first_tail_x2_r0_body.s125 PRE_first_tail_x2_r0_body.s126 PRE_first_tail_x2_r0_body.s127 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S125 PRE_first_tail_x2_r0_body.S126 PRE_first_tail_x2_r0_body.S127
    PRE_first_tail_x2_r0_body.ws5 PRE_first_tail_x2_r0_body.cws5 PRE_first_tail_x2_r0_body.nr5 PRE_first_tail_x2_r0_body.pl5 PRE_first_tail_x2_r0_body.cl5 2688196 729 PRE_first_tail_x2_r0_body.kd5 PRE_first_tail_x2_r0_body.kappa5 PRE_first_tail_x2_r0_body.P5
    ⟨18509, 15578, 2687041, 711⟩ ⟨18512, 15605, 2687047, 729⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap5
  clean := bodyClean5
  cfix := PRE_first_tail_x2_r0_body.cfix5
  zpl := PRE_first_tail_x2_r0_body.zpl5
  zplnd := PRE_first_tail_x2_r0_body.zplnd5
  zn1 := PRE_first_tail_x2_r0_body.zn15
  zfirst := PRE_first_tail_x2_r0_body.zfirst5
  zscn := PRE_first_tail_x2_r0_body.zscn5
  zsmn := PRE_first_tail_x2_r0_body.zsmn5
  zgrow := PRE_first_tail_x2_r0_body.zgrow5
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab5
  zfresh := PRE_first_tail_x2_r0_body.zfresh5
  zcnd := PRE_first_tail_x2_r0_body.zcnd5
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi5
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt5
  zgP := PRE_first_tail_x2_r0_body.zg5_2665
  zkP := PRE_first_tail_x2_r0_body.zk5_2665
  zmP := PRE_first_tail_x2_r0_body.zm5_2665
  zgC := PRE_first_tail_x2_r0_body.zg5_2673467
  zkC := PRE_first_tail_x2_r0_body.zk5_2673467
  zmC := PRE_first_tail_x2_r0_body.zm5_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw5_2673472
  zwV := PRE_first_tail_x2_r0_body.zw5_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap5
  zclbd := PRE_first_tail_x2_r0_body.zclbd5
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap5 PRE_first_tail_x2_r0_body.stFoot5 PRE_first_tail_x2_r0_body.iso5 PRE_first_tail_x2_r0_body.zwr5
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP5
  csupp := PRE_first_tail_x2_r0_body.csupp5
  cbound := PRE_first_tail_x2_r0_body.cbound5
  zimg := PRE_first_tail_x2_r0_body.zimg5
  zctl := PRE_first_tail_x2_r0_body.zctl5
  zstack := PRE_first_tail_x2_r0_body.zstack5
  zjobs := PRE_first_tail_x2_r0_body.zjobs5
  zstores := PRE_first_tail_x2_r0_body.zstores5
  zroots := PRE_first_tail_x2_r0_body.zroots5
  znC := PRE_first_tail_x2_r0_body.znC5
  ctab := PRE_first_tail_x2_r0_body.ctab5
  zbin := PRE_first_tail_x2_r0_body.zbin5
  cbridge := PRE_first_tail_x2_r0_body.cbridge5
  sbridge := bodyBridge5
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj5
  cshiftR := fun h hNL => bodyCshift5 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN5
  raised := PRE_first_tail_x2_r0_body.raised5
  cbigs := PRE_first_tail_x2_r0_body.cbigs5
  cjcl := PRE_first_tail_x2_r0_body.cjcl5
  xnLe := Nat.le_of_ble_eq_true bodyXn5
  loLe := Nat.le_of_ble_eq_true bodyLo5
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB5
  cntM := bodyCntM5
  hiLe := Nat.le_of_ble_eq_true bodyHi5
  nhiLe := Nat.le_of_ble_eq_true bodyNhi5
  jsHeap := bodyJs5
  jsRoots := bodyJsRoots5
  jsNative := bodyJsNative5
  framesEmpty := bodyFramesEmpty5
  trailOld := by decide
  lowVars := bodyLow5

def bodyQs5 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs5 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr5.map fun r => nth? PRE_first_tail_x2_r0_body.st5.S5.tab r
kernel_rfl bodyResChk5 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs5 bodyQs5) = true
kernel_rfl bodyLq5 : bodyQs5.length = PRE_first_tail_x2_r0_body.cws5.length
kernel_rfl bodyNrLo5 : PRE_first_tail_x2_r0_body.nr5.all (Nat.ble PRE_first_tail_x2_r0_body.S125.tab.length) = true
kernel_rfl bodySub5 : (Oracles.PRE_first_tail_x2_r0_body.map_site5.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost5 : postSubB bodyM PRE_first_tail_x2_r0_body.ws5 PRE_first_tail_x2_r0_body.cws5 bodyQs5 = true
kernel_rfl bodyDrop5 : Nat.ble (9060 + (PRE_first_tail_x2_r0_body.s126.next - PRE_first_tail_x2_r0_body.s127.next)) 10209 = true
kernel_rfl bodyDropH5 : Nat.ble (123 + ((mlxOf PRE_first_tail_x2_r0_body.s126.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s127.ffi).next)) 148 = true
kernel_rfl bodyDropN5 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s126.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s127.ffi).nnext)) 0 = true
kernel_rfl bodyDv5 : bodyΘ.1.take 99 = bodyΘ.1.take 81 ++ PRE_first_tail_x2_r0_body.cws5
kernel_rfl bodyDe5 : bodyΘ.2.take 99 = bodyΘ.2.take 81 ++ PRE_first_tail_x2_r0_body.nr5.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st5.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 81) (bodyΘ.2.take 81)))
kernel_rfl bodyDl5 : (bodyΘ.1.take 81).length = (bodyΘ.2.take 81).length
kernel_rfl bodyDold5 : (bodyΘ.1.take 81).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws5).isNone && !PRE_first_tail_x2_r0_body.ws5.contains v) = true
kernel_rfl bodyDfree5 : (bodyΘ.2.take 99).all (fun e => (PRE_first_tail_x2_r0_body.cws5 ++ PRE_first_tail_x2_r0_body.ws5).all fun w => e.noVar w) = true

theorem bodyStep5 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9060, 123, 0, 81⟩ bodyM PRE_first_tail_x2_r0_body.s125 PRE_first_tail_x2_r0_body.S125)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10209, 148, 0, 99⟩ bodyM PRE_first_tail_x2_r0_body.s127 PRE_first_tail_x2_r0_body.S127) (11334 + 1) :=
  bodySite bodyFacts5.cfix bodyFacts5.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st5.S5.tab) (Es := bodyEs5) (qs := bodyQs5)
    (ok := PRE_first_tail_x2_r0_body.st5.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site5 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts5
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site5 r hr) hi (MapOk.sub hm (sub_of_all bodySub5)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk5 r hr) hi hm ho hq)
    bodyLq5 rfl bodyNrLo5 (postSub_sound bodyPost5)
    (Nat.le_of_ble_eq_true bodyDrop5) (by decide) (Nat.le_of_ble_eq_true bodyDropH5) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN5) (by decide)
    bodyDv5 bodyDe5 bodyDl5 bodyDold5 bodyDfree5 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site6 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site6 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site6) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st6.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site6
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st6.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st6.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s147 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s148 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S147 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws6 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st6.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st6.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso6
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_6
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st6.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot6
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup6
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound6
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace6
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged6
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws6.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st6.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S147.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_6]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen6.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh6
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl6 : Conv.NClean (⟨18566, 15641, 2689279, 837⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s147.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl6 (PRE_first_tail_x2_r0_body.cncl5 bodyNcl5)

theorem bodyClean6 : Conv.JClean (⟨18566, 15641, 2689279, 837⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s147 :=
  PRE_first_tail_x2_r0_body.gjcl6 (PRE_first_tail_x2_r0_body.cjcl5 bodyClean5)

kernel_rfl bodyJsLe6 : Nat.ble PRE_first_tail_x2_r0_body.s125.next PRE_first_tail_x2_r0_body.s147.next = true
kernel_rfl bodyJsList6 : (PRE_first_tail_x2_r0_body.gjh6 ++ PRE_first_tail_x2_r0_body.cl6).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s147.next) PRE_first_tail_x2_r0_body.s149) = true
theorem bodyJs6 : JsHeapAbove PRE_first_tail_x2_r0_body.s147.next PRE_first_tail_x2_r0_body.s149 :=
  JsHeapAbove.glueSite bodyJs5 (Nat.le_of_ble_eq_true bodyJsLe6) PRE_first_tail_x2_r0_body.gjk6 PRE_first_tail_x2_r0_body.gjbd6 PRE_first_tail_x2_r0_body.cheap6 PRE_first_tail_x2_r0_body.zclbd6 bodyJsList6

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO127 : PRE_first_tail_x2_r0_body.S127.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S127.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr127 : bridgeOf PRE_first_tail_x2_r0_body.s127.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc127 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s127 PRE_first_tail_x2_r0_body.S127) = fun _ _ => true
kernel_rfl bodyAcc128 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s128 PRE_first_tail_x2_r0_body.S128) = fun _ _ => true
kernel_rfl bodyBr129 : bridgeOf PRE_first_tail_x2_r0_body.s129.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt128 : isHalt PRE_first_tail_x2_r0_body.s128.ctl = false
kernel_rfl bodyTop129 : noRetBlock PRE_first_tail_x2_r0_body.s129 = true
kernel_rfl bodyCnt127 : countersOkB PRE_first_tail_x2_r0_body.s127 PRE_first_tail_x2_r0_body.s129 = true
kernel_rfl bodyO129 : PRE_first_tail_x2_r0_body.S129.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S129.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr130 : bridgeOf PRE_first_tail_x2_r0_body.s130.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt129 : countersOkB PRE_first_tail_x2_r0_body.s129 PRE_first_tail_x2_r0_body.s130 = true
kernel_rfl bodyO130 : PRE_first_tail_x2_r0_body.S130.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S130.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc130 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s130 PRE_first_tail_x2_r0_body.S130) = fun _ _ => true
kernel_rfl bodyAcc134 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s134 PRE_first_tail_x2_r0_body.S134) = fun _ _ => true
kernel_rfl bodyBr135 : bridgeOf PRE_first_tail_x2_r0_body.s135.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt134 : isHalt PRE_first_tail_x2_r0_body.s134.ctl = false
kernel_rfl bodyTop135 : noRetBlock PRE_first_tail_x2_r0_body.s135 = true
kernel_rfl bodyCnt130 : countersOkB PRE_first_tail_x2_r0_body.s130 PRE_first_tail_x2_r0_body.s135 = true
kernel_rfl bodyO135 : PRE_first_tail_x2_r0_body.S135.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S135.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr136 : bridgeOf PRE_first_tail_x2_r0_body.s136.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt135 : countersOkB PRE_first_tail_x2_r0_body.s135 PRE_first_tail_x2_r0_body.s136 = true
kernel_rfl bodyO136 : PRE_first_tail_x2_r0_body.S136.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S136.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc136 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s136 PRE_first_tail_x2_r0_body.S136) = fun _ _ => true
kernel_rfl bodyAcc137 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s137 PRE_first_tail_x2_r0_body.S137) = fun _ _ => true
kernel_rfl bodyBr138 : bridgeOf PRE_first_tail_x2_r0_body.s138.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt137 : isHalt PRE_first_tail_x2_r0_body.s137.ctl = false
kernel_rfl bodyTop138 : noRetBlock PRE_first_tail_x2_r0_body.s138 = true
kernel_rfl bodyCnt136 : countersOkB PRE_first_tail_x2_r0_body.s136 PRE_first_tail_x2_r0_body.s138 = true
kernel_rfl bodyO138 : PRE_first_tail_x2_r0_body.S138.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S138.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr139 : bridgeOf PRE_first_tail_x2_r0_body.s139.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt138 : countersOkB PRE_first_tail_x2_r0_body.s138 PRE_first_tail_x2_r0_body.s139 = true
kernel_rfl bodyO139 : PRE_first_tail_x2_r0_body.S139.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S139.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc139 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s139 PRE_first_tail_x2_r0_body.S139) = fun _ _ => true
kernel_rfl bodyAcc140 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s140 PRE_first_tail_x2_r0_body.S140) = fun _ _ => true
kernel_rfl bodyBr141 : bridgeOf PRE_first_tail_x2_r0_body.s141.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt140 : isHalt PRE_first_tail_x2_r0_body.s140.ctl = false
kernel_rfl bodyTop141 : noRetBlock PRE_first_tail_x2_r0_body.s141 = true
kernel_rfl bodyCnt139 : countersOkB PRE_first_tail_x2_r0_body.s139 PRE_first_tail_x2_r0_body.s141 = true
kernel_rfl bodyO141 : PRE_first_tail_x2_r0_body.S141.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S141.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr142 : bridgeOf PRE_first_tail_x2_r0_body.s142.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt141 : countersOkB PRE_first_tail_x2_r0_body.s141 PRE_first_tail_x2_r0_body.s142 = true
kernel_rfl bodyO142 : PRE_first_tail_x2_r0_body.S142.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S142.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc142 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s142 PRE_first_tail_x2_r0_body.S142) = fun _ _ => true
kernel_rfl bodyAcc143 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s143 PRE_first_tail_x2_r0_body.S143) = fun _ _ => true
kernel_rfl bodyBr144 : bridgeOf PRE_first_tail_x2_r0_body.s144.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt143 : isHalt PRE_first_tail_x2_r0_body.s143.ctl = false
kernel_rfl bodyTop144 : noRetBlock PRE_first_tail_x2_r0_body.s144 = true
kernel_rfl bodyCnt142 : countersOkB PRE_first_tail_x2_r0_body.s142 PRE_first_tail_x2_r0_body.s144 = true
kernel_rfl bodyO144 : PRE_first_tail_x2_r0_body.S144.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S144.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr145 : bridgeOf PRE_first_tail_x2_r0_body.s145.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt144 : countersOkB PRE_first_tail_x2_r0_body.s144 PRE_first_tail_x2_r0_body.s145 = true
kernel_rfl bodyO145 : PRE_first_tail_x2_r0_body.S145.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S145.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc145 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s145 PRE_first_tail_x2_r0_body.S145) = fun _ _ => true
kernel_rfl bodyAcc146 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s146 PRE_first_tail_x2_r0_body.S146) = fun _ _ => true
kernel_rfl bodyBr147 : bridgeOf PRE_first_tail_x2_r0_body.s147.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt146 : isHalt PRE_first_tail_x2_r0_body.s146.ctl = false
kernel_rfl bodyTop147 : noRetBlock PRE_first_tail_x2_r0_body.s147 = true
kernel_rfl bodyCnt145 : countersOkB PRE_first_tail_x2_r0_body.s145 PRE_first_tail_x2_r0_body.s147 = true

theorem bodyGlue6 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10209, 148, 0, 99⟩ bodyM PRE_first_tail_x2_r0_body.s127 PRE_first_tail_x2_r0_body.S127)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10209, 148, 0, 99⟩ bodyM PRE_first_tail_x2_r0_body.s147 PRE_first_tail_x2_r0_body.S147) 22217 :=
  (((((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) bodyAcc127 PRE_first_tail_x2_r0_body.bodyRunSeg34 bodyAcc128 bodyHalt128 PRE_first_tail_x2_r0_body.bodyStepA35 bodyTop129 (fun _ hm => bodyO127 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr127).trans bodyInactive0) (bodyBr129.trans bodyBr127.symm) bodyCnt127 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) PRE_first_tail_x2_r0_body.sizeA35 PRE_first_tail_x2_r0_body.sizeArgsA35 PRE_first_tail_x2_r0_body.sizeSymA35 PRE_first_tail_x2_r0_body.sizeMlxA35 PRE_first_tail_x2_r0_body.sizePayA35 PRE_first_tail_x2_r0_body.sizeTaA35 PRE_first_tail_x2_r0_body.sizeDecA35 PRE_first_tail_x2_r0_body.sizePreA35 PRE_first_tail_x2_r0_body.bodyPatchB35 (fun _ hm => bodyO129 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr129).trans bodyInactive0) (bodyBr130.trans bodyBr129.symm) bodyCnt129 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) bodyAcc130 PRE_first_tail_x2_r0_body.bodyRunSeg35 bodyAcc134 bodyHalt134 PRE_first_tail_x2_r0_body.bodyStepA36 bodyTop135 (fun _ hm => bodyO130 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr130).trans bodyInactive0) (bodyBr135.trans bodyBr130.symm) bodyCnt130 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) PRE_first_tail_x2_r0_body.sizeA36 PRE_first_tail_x2_r0_body.sizeArgsA36 PRE_first_tail_x2_r0_body.sizeSymA36 PRE_first_tail_x2_r0_body.sizeMlxA36 PRE_first_tail_x2_r0_body.sizePayA36 PRE_first_tail_x2_r0_body.sizeTaA36 PRE_first_tail_x2_r0_body.sizeDecA36 PRE_first_tail_x2_r0_body.sizePreA36 PRE_first_tail_x2_r0_body.bodyPatchB36 (fun _ hm => bodyO135 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr135).trans bodyInactive0) (bodyBr136.trans bodyBr135.symm) bodyCnt135 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) bodyAcc136 PRE_first_tail_x2_r0_body.bodyRunSeg36 bodyAcc137 bodyHalt137 PRE_first_tail_x2_r0_body.bodyStepA37 bodyTop138 (fun _ hm => bodyO136 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr136).trans bodyInactive0) (bodyBr138.trans bodyBr136.symm) bodyCnt136 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) PRE_first_tail_x2_r0_body.sizeA37 PRE_first_tail_x2_r0_body.sizeArgsA37 PRE_first_tail_x2_r0_body.sizeSymA37 PRE_first_tail_x2_r0_body.sizeMlxA37 PRE_first_tail_x2_r0_body.sizePayA37 PRE_first_tail_x2_r0_body.sizeTaA37 PRE_first_tail_x2_r0_body.sizeDecA37 PRE_first_tail_x2_r0_body.sizePreA37 PRE_first_tail_x2_r0_body.bodyPatchB37 (fun _ hm => bodyO138 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr138).trans bodyInactive0) (bodyBr139.trans bodyBr138.symm) bodyCnt138 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) bodyAcc139 PRE_first_tail_x2_r0_body.bodyRunSeg37 bodyAcc140 bodyHalt140 PRE_first_tail_x2_r0_body.bodyStepA38 bodyTop141 (fun _ hm => bodyO139 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr139).trans bodyInactive0) (bodyBr141.trans bodyBr139.symm) bodyCnt139 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) PRE_first_tail_x2_r0_body.sizeA38 PRE_first_tail_x2_r0_body.sizeArgsA38 PRE_first_tail_x2_r0_body.sizeSymA38 PRE_first_tail_x2_r0_body.sizeMlxA38 PRE_first_tail_x2_r0_body.sizePayA38 PRE_first_tail_x2_r0_body.sizeTaA38 PRE_first_tail_x2_r0_body.sizeDecA38 PRE_first_tail_x2_r0_body.sizePreA38 PRE_first_tail_x2_r0_body.bodyPatchB38 (fun _ hm => bodyO141 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr141).trans bodyInactive0) (bodyBr142.trans bodyBr141.symm) bodyCnt141 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) bodyAcc142 PRE_first_tail_x2_r0_body.bodyRunSeg38 bodyAcc143 bodyHalt143 PRE_first_tail_x2_r0_body.bodyStepA39 bodyTop144 (fun _ hm => bodyO142 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr142).trans bodyInactive0) (bodyBr144.trans bodyBr142.symm) bodyCnt142 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) PRE_first_tail_x2_r0_body.sizeA39 PRE_first_tail_x2_r0_body.sizeArgsA39 PRE_first_tail_x2_r0_body.sizeSymA39 PRE_first_tail_x2_r0_body.sizeMlxA39 PRE_first_tail_x2_r0_body.sizePayA39 PRE_first_tail_x2_r0_body.sizeTaA39 PRE_first_tail_x2_r0_body.sizeDecA39 PRE_first_tail_x2_r0_body.sizePreA39 PRE_first_tail_x2_r0_body.bodyPatchB39 (fun _ hm => bodyO144 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr144).trans bodyInactive0) (bodyBr145.trans bodyBr144.symm) bodyCnt144 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10209, 148, 0, 99⟩) bodyAcc145 PRE_first_tail_x2_r0_body.bodyRunSeg39 bodyAcc146 bodyHalt146 PRE_first_tail_x2_r0_body.bodyStepA40 bodyTop147 (fun _ hm => bodyO145 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr145).trans bodyInactive0) (bodyBr147.trans bodyBr145.symm) bodyCnt145 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift6 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S147.tab.length PRE_first_tail_x2_r0_body.s147.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P6.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P6 855 PRE_first_tail_x2_r0_body.kappa6 PRE_first_tail_x2_r0_body.s149.ffi PRE_first_tail_x2_r0_body.s148.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_6
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_6
  have hcl : SSt (· < 855) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s149.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S147.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_6] <;> decide) PRE_first_tail_x2_r0_body.cnodesK6 PRE_first_tail_x2_r0_body.cobjsK6
      PRE_first_tail_x2_r0_body.citemsK6 PRE_first_tail_x2_r0_body.cbd6 PRE_first_tail_x2_r0_body.csst6
  exact PRE_first_tail_x2_r0_body.cshift6 bodyNcl6 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_6] at this; exact this)


kernel_rfl bodyFramesEmpty6 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s148 a).isEmpty) = true
kernel_rfl bodyJsRoots6 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s147.next) PRE_first_tail_x2_r0_body.s149.trace PRE_first_tail_x2_r0_body.s149 = true
kernel_rfl bodyJsNative6 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s149.ffi) = true
kernel_rfl bodyLow6 : (PRE_first_tail_x2_r0_body.cws6 ++ PRE_first_tail_x2_r0_body.ws6).all (Nat.ble 9) = true
kernel_rfl bodyCntM6 : countersOkB PRE_first_tail_x2_r0_body.s147 PRE_first_tail_x2_r0_body.s148 = true
kernel_rfl bodyHi6 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s149.ffi).next setupP.E = true
kernel_rfl bodyNhi6 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s149.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge6 : bridgeOf PRE_first_tail_x2_r0_body.s148.ffi = bridgeOf PRE_first_tail_x2_r0_body.s147.ffi
kernel_rfl bodyNN6 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s147.ffi).nnext PRE_first_tail_x2_r0_body.P6.NL = true
kernel_rfl bodyXn6 : Nat.ble (⟨18569, 15668, 2689285, 855⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s149.ffi).next = true
kernel_rfl bodyLo6 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s149.ffi).next = true
theorem bodyFacts6 : BodySiteFacts PRE_first_tail_x2_r0_body.s147 PRE_first_tail_x2_r0_body.s148 PRE_first_tail_x2_r0_body.s149 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S147 PRE_first_tail_x2_r0_body.S148 PRE_first_tail_x2_r0_body.S149
    PRE_first_tail_x2_r0_body.ws6 PRE_first_tail_x2_r0_body.cws6 PRE_first_tail_x2_r0_body.nr6 PRE_first_tail_x2_r0_body.pl6 PRE_first_tail_x2_r0_body.cl6 2690434 855 PRE_first_tail_x2_r0_body.kd6 PRE_first_tail_x2_r0_body.kappa6 PRE_first_tail_x2_r0_body.P6
    ⟨18566, 15641, 2689279, 837⟩ ⟨18569, 15668, 2689285, 855⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap6
  clean := bodyClean6
  cfix := PRE_first_tail_x2_r0_body.cfix6
  zpl := PRE_first_tail_x2_r0_body.zpl6
  zplnd := PRE_first_tail_x2_r0_body.zplnd6
  zn1 := PRE_first_tail_x2_r0_body.zn16
  zfirst := PRE_first_tail_x2_r0_body.zfirst6
  zscn := PRE_first_tail_x2_r0_body.zscn6
  zsmn := PRE_first_tail_x2_r0_body.zsmn6
  zgrow := PRE_first_tail_x2_r0_body.zgrow6
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab6
  zfresh := PRE_first_tail_x2_r0_body.zfresh6
  zcnd := PRE_first_tail_x2_r0_body.zcnd6
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi6
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt6
  zgP := PRE_first_tail_x2_r0_body.zg6_2665
  zkP := PRE_first_tail_x2_r0_body.zk6_2665
  zmP := PRE_first_tail_x2_r0_body.zm6_2665
  zgC := PRE_first_tail_x2_r0_body.zg6_2673467
  zkC := PRE_first_tail_x2_r0_body.zk6_2673467
  zmC := PRE_first_tail_x2_r0_body.zm6_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw6_2673472
  zwV := PRE_first_tail_x2_r0_body.zw6_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap6
  zclbd := PRE_first_tail_x2_r0_body.zclbd6
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap6 PRE_first_tail_x2_r0_body.stFoot6 PRE_first_tail_x2_r0_body.iso6 PRE_first_tail_x2_r0_body.zwr6
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP6
  csupp := PRE_first_tail_x2_r0_body.csupp6
  cbound := PRE_first_tail_x2_r0_body.cbound6
  zimg := PRE_first_tail_x2_r0_body.zimg6
  zctl := PRE_first_tail_x2_r0_body.zctl6
  zstack := PRE_first_tail_x2_r0_body.zstack6
  zjobs := PRE_first_tail_x2_r0_body.zjobs6
  zstores := PRE_first_tail_x2_r0_body.zstores6
  zroots := PRE_first_tail_x2_r0_body.zroots6
  znC := PRE_first_tail_x2_r0_body.znC6
  ctab := PRE_first_tail_x2_r0_body.ctab6
  zbin := PRE_first_tail_x2_r0_body.zbin6
  cbridge := PRE_first_tail_x2_r0_body.cbridge6
  sbridge := bodyBridge6
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj6
  cshiftR := fun h hNL => bodyCshift6 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN6
  raised := PRE_first_tail_x2_r0_body.raised6
  cbigs := PRE_first_tail_x2_r0_body.cbigs6
  cjcl := PRE_first_tail_x2_r0_body.cjcl6
  xnLe := Nat.le_of_ble_eq_true bodyXn6
  loLe := Nat.le_of_ble_eq_true bodyLo6
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB6
  cntM := bodyCntM6
  hiLe := Nat.le_of_ble_eq_true bodyHi6
  nhiLe := Nat.le_of_ble_eq_true bodyNhi6
  jsHeap := bodyJs6
  jsRoots := bodyJsRoots6
  jsNative := bodyJsNative6
  framesEmpty := bodyFramesEmpty6
  trailOld := by decide
  lowVars := bodyLow6

def bodyQs6 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs6 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr6.map fun r => nth? PRE_first_tail_x2_r0_body.st6.S5.tab r
kernel_rfl bodyResChk6 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs6 bodyQs6) = true
kernel_rfl bodyLq6 : bodyQs6.length = PRE_first_tail_x2_r0_body.cws6.length
kernel_rfl bodyNrLo6 : PRE_first_tail_x2_r0_body.nr6.all (Nat.ble PRE_first_tail_x2_r0_body.S147.tab.length) = true
kernel_rfl bodySub6 : (Oracles.PRE_first_tail_x2_r0_body.map_site6.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost6 : postSubB bodyM PRE_first_tail_x2_r0_body.ws6 PRE_first_tail_x2_r0_body.cws6 bodyQs6 = true
kernel_rfl bodyDrop6 : Nat.ble (10209 + (PRE_first_tail_x2_r0_body.s148.next - PRE_first_tail_x2_r0_body.s149.next)) 11358 = true
kernel_rfl bodyDropH6 : Nat.ble (148 + ((mlxOf PRE_first_tail_x2_r0_body.s148.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s149.ffi).next)) 173 = true
kernel_rfl bodyDropN6 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s148.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s149.ffi).nnext)) 0 = true
kernel_rfl bodyDv6 : bodyΘ.1.take 117 = bodyΘ.1.take 99 ++ PRE_first_tail_x2_r0_body.cws6
kernel_rfl bodyDe6 : bodyΘ.2.take 117 = bodyΘ.2.take 99 ++ PRE_first_tail_x2_r0_body.nr6.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st6.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 99) (bodyΘ.2.take 99)))
kernel_rfl bodyDl6 : (bodyΘ.1.take 99).length = (bodyΘ.2.take 99).length
kernel_rfl bodyDold6 : (bodyΘ.1.take 99).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws6).isNone && !PRE_first_tail_x2_r0_body.ws6.contains v) = true
kernel_rfl bodyDfree6 : (bodyΘ.2.take 117).all (fun e => (PRE_first_tail_x2_r0_body.cws6 ++ PRE_first_tail_x2_r0_body.ws6).all fun w => e.noVar w) = true

theorem bodyStep6 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10209, 148, 0, 99⟩ bodyM PRE_first_tail_x2_r0_body.s147 PRE_first_tail_x2_r0_body.S147)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11358, 173, 0, 117⟩ bodyM PRE_first_tail_x2_r0_body.s149 PRE_first_tail_x2_r0_body.S149) (11334 + 1) :=
  bodySite bodyFacts6.cfix bodyFacts6.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x2_r0_body.st6.S5.tab) (Es := bodyEs6) (qs := bodyQs6)
    (ok := PRE_first_tail_x2_r0_body.st6.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site6 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts6
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site6 r hr) hi (MapOk.sub hm (sub_of_all bodySub6)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk6 r hr) hi hm ho hq)
    bodyLq6 rfl bodyNrLo6 (postSub_sound bodyPost6)
    (Nat.le_of_ble_eq_true bodyDrop6) (by decide) (Nat.le_of_ble_eq_true bodyDropH6) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN6) (by decide)
    bodyDv6 bodyDe6 bodyDl6 bodyDold6 bodyDfree6 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodySite7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x2_r0_body.map_site7 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1080, Q.n), (1081, Q.n), (1083, Q.n), (1084, Q.n), (1085, Q.n), (1086, Q.n), (1087, Q.n), (1090, Q.n), (1091, Q.n), (1093, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1129, Q.n), (1130, Q.n), (1132, Q.n), (1133, Q.n), (1134, Q.n), (1135, Q.n), (1136, Q.n), (1139, Q.n), (1140, Q.n), (1142, Q.n), (1143, Q.n), (1144, Q.n), (1145, Q.n), (1146, Q.n), (1164, Q.n), (1165, Q.n), (1167, Q.n), (1169, Q.n), (1170, Q.n), (1171, Q.n), (1172, Q.n), (1204, Q.n), (1205, Q.n), (1207, Q.n), (1208, Q.n), (1209, Q.n), (1210, Q.n), (1211, Q.n), (1214, Q.n), (1215, Q.n), (1217, Q.n), (1218, Q.n), (1219, Q.n), (1220, Q.n), (1221, Q.n), (1253, Q.n), (1254, Q.n), (1256, Q.n), (1257, Q.n), (1258, Q.n), (1259, Q.n), (1260, Q.n), (1263, Q.n), (1264, Q.n), (1266, Q.n), (1267, Q.n), (1268, Q.n), (1269, Q.n), (1270, Q.n), (1302, Q.n), (1303, Q.n), (1305, Q.n), (1306, Q.n), (1307, Q.n), (1308, Q.n), (1309, Q.n), (1312, Q.n), (1313, Q.n), (1315, Q.n), (1316, Q.n), (1317, Q.n), (1318, Q.n), (1319, Q.n)]

kernel_rfl PRE_first_tail_x2_r0_body.chk_site7 : ([first_tail_x2.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x2_r0_body.map_site7) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st7.S0.oracle) = true

noncomputable def PRE_first_tail_x2_r0_body.site7
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st7.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st7.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s168 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.s169 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S168 Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws7 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st7.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st7.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.iso7
  tab := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_7
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st7.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.stFoot7
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrNodup7
  bound := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.wrBound7
  trace := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.trace7
  merged := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.merged7
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.ws7.length = (Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.st7.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.S168.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.tab0_7]
    exact Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.mergeLen7.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x2_r0_body.fresh7
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl7 : Conv.NClean (⟨18629, 15713, 2691782, 967⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s168.ffi).mlx :=
  PRE_first_tail_x2_r0_body.gncl7 (PRE_first_tail_x2_r0_body.cncl6 bodyNcl6)

theorem bodyClean7 : Conv.JClean (⟨18629, 15713, 2691782, 967⟩ : Conv.Cnt) PRE_first_tail_x2_r0_body.s168 :=
  PRE_first_tail_x2_r0_body.gjcl7 (PRE_first_tail_x2_r0_body.cjcl6 bodyClean6)

kernel_rfl bodyJsLe7 : Nat.ble PRE_first_tail_x2_r0_body.s147.next PRE_first_tail_x2_r0_body.s168.next = true
kernel_rfl bodyJsList7 : (PRE_first_tail_x2_r0_body.gjh7 ++ PRE_first_tail_x2_r0_body.cl7).all (noBigAtP (jsAboveB PRE_first_tail_x2_r0_body.s168.next) PRE_first_tail_x2_r0_body.s170) = true
theorem bodyJs7 : JsHeapAbove PRE_first_tail_x2_r0_body.s168.next PRE_first_tail_x2_r0_body.s170 :=
  JsHeapAbove.glueSite bodyJs6 (Nat.le_of_ble_eq_true bodyJsLe7) PRE_first_tail_x2_r0_body.gjk7 PRE_first_tail_x2_r0_body.gjbd7 PRE_first_tail_x2_r0_body.cheap7 PRE_first_tail_x2_r0_body.zclbd7 bodyJsList7

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyG7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO149 : PRE_first_tail_x2_r0_body.S149.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S149.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr149 : bridgeOf PRE_first_tail_x2_r0_body.s149.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyAcc149 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s149 PRE_first_tail_x2_r0_body.S149) = fun _ _ => true
kernel_rfl bodyAcc150 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s150 PRE_first_tail_x2_r0_body.S150) = fun _ _ => true
kernel_rfl bodyBr151 : bridgeOf PRE_first_tail_x2_r0_body.s151.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt150 : isHalt PRE_first_tail_x2_r0_body.s150.ctl = false
kernel_rfl bodyTop151 : noRetBlock PRE_first_tail_x2_r0_body.s151 = true
kernel_rfl bodyCnt149 : countersOkB PRE_first_tail_x2_r0_body.s149 PRE_first_tail_x2_r0_body.s151 = true
kernel_rfl bodyO151 : PRE_first_tail_x2_r0_body.S151.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S151.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr152 : bridgeOf PRE_first_tail_x2_r0_body.s152.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt151 : countersOkB PRE_first_tail_x2_r0_body.s151 PRE_first_tail_x2_r0_body.s152 = true
kernel_rfl bodyO152 : PRE_first_tail_x2_r0_body.S152.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S152.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc152 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s152 PRE_first_tail_x2_r0_body.S152) = fun _ _ => true
kernel_rfl bodyAcc156 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s156 PRE_first_tail_x2_r0_body.S156) = fun _ _ => true
kernel_rfl bodyBr157 : bridgeOf PRE_first_tail_x2_r0_body.s157.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt156 : isHalt PRE_first_tail_x2_r0_body.s156.ctl = false
kernel_rfl bodyTop157 : noRetBlock PRE_first_tail_x2_r0_body.s157 = true
kernel_rfl bodyCnt152 : countersOkB PRE_first_tail_x2_r0_body.s152 PRE_first_tail_x2_r0_body.s157 = true
kernel_rfl bodyO157 : PRE_first_tail_x2_r0_body.S157.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S157.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr158 : bridgeOf PRE_first_tail_x2_r0_body.s158.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt157 : countersOkB PRE_first_tail_x2_r0_body.s157 PRE_first_tail_x2_r0_body.s158 = true
kernel_rfl bodyO158 : PRE_first_tail_x2_r0_body.S158.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S158.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc158 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s158 PRE_first_tail_x2_r0_body.S158) = fun _ _ => true
kernel_rfl bodyAcc160 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s160 PRE_first_tail_x2_r0_body.S160) = fun _ _ => true
kernel_rfl bodyBr161 : bridgeOf PRE_first_tail_x2_r0_body.s161.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt160 : isHalt PRE_first_tail_x2_r0_body.s160.ctl = false
kernel_rfl bodyTop161 : noRetBlock PRE_first_tail_x2_r0_body.s161 = true
kernel_rfl bodyCnt158 : countersOkB PRE_first_tail_x2_r0_body.s158 PRE_first_tail_x2_r0_body.s161 = true
kernel_rfl bodyO161 : PRE_first_tail_x2_r0_body.S161.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S161.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr162 : bridgeOf PRE_first_tail_x2_r0_body.s162.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt161 : countersOkB PRE_first_tail_x2_r0_body.s161 PRE_first_tail_x2_r0_body.s162 = true
kernel_rfl bodyO162 : PRE_first_tail_x2_r0_body.S162.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S162.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc162 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s162 PRE_first_tail_x2_r0_body.S162) = fun _ _ => true
kernel_rfl bodyAcc163 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s163 PRE_first_tail_x2_r0_body.S163) = fun _ _ => true
kernel_rfl bodyBr164 : bridgeOf PRE_first_tail_x2_r0_body.s164.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt163 : isHalt PRE_first_tail_x2_r0_body.s163.ctl = false
kernel_rfl bodyTop164 : noRetBlock PRE_first_tail_x2_r0_body.s164 = true
kernel_rfl bodyCnt162 : countersOkB PRE_first_tail_x2_r0_body.s162 PRE_first_tail_x2_r0_body.s164 = true
kernel_rfl bodyO164 : PRE_first_tail_x2_r0_body.S164.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S164.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyBr165 : bridgeOf PRE_first_tail_x2_r0_body.s165.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyCnt164 : countersOkB PRE_first_tail_x2_r0_body.s164 PRE_first_tail_x2_r0_body.s165 = true
kernel_rfl bodyO165 : PRE_first_tail_x2_r0_body.S165.oracle = List.drop (PRE_first_tail_x2_r0_body.OR.length - PRE_first_tail_x2_r0_body.S165.oracle.length) PRE_first_tail_x2_r0_body.OR
kernel_rfl bodyAcc165 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s165 PRE_first_tail_x2_r0_body.S165) = fun _ _ => true
kernel_rfl bodyAcc167 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x2_r0_body.s167 PRE_first_tail_x2_r0_body.S167) = fun _ _ => true
kernel_rfl bodyBr168 : bridgeOf PRE_first_tail_x2_r0_body.s168.ffi = bridgeOf PRE_first_tail_x2_r0_body.s0.ffi
kernel_rfl bodyHalt167 : isHalt PRE_first_tail_x2_r0_body.s167.ctl = false
kernel_rfl bodyTop168 : noRetBlock PRE_first_tail_x2_r0_body.s168 = true
kernel_rfl bodyCnt165 : countersOkB PRE_first_tail_x2_r0_body.s165 PRE_first_tail_x2_r0_body.s168 = true

theorem bodyGlue7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11358, 173, 0, 117⟩ bodyM PRE_first_tail_x2_r0_body.s149 PRE_first_tail_x2_r0_body.S149)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11358, 173, 0, 117⟩ bodyM PRE_first_tail_x2_r0_body.s168 PRE_first_tail_x2_r0_body.S168) 24692 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) bodyAcc149 PRE_first_tail_x2_r0_body.bodyRunSeg40 bodyAcc150 bodyHalt150 PRE_first_tail_x2_r0_body.bodyStepA41 bodyTop151 (fun _ hm => bodyO149 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr149).trans bodyInactive0) (bodyBr151.trans bodyBr149.symm) bodyCnt149 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) PRE_first_tail_x2_r0_body.sizeA41 PRE_first_tail_x2_r0_body.sizeArgsA41 PRE_first_tail_x2_r0_body.sizeSymA41 PRE_first_tail_x2_r0_body.sizeMlxA41 PRE_first_tail_x2_r0_body.sizePayA41 PRE_first_tail_x2_r0_body.sizeTaA41 PRE_first_tail_x2_r0_body.sizeDecA41 PRE_first_tail_x2_r0_body.sizePreA41 PRE_first_tail_x2_r0_body.bodyPatchB41 (fun _ hm => bodyO151 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr151).trans bodyInactive0) (bodyBr152.trans bodyBr151.symm) bodyCnt151 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) bodyAcc152 PRE_first_tail_x2_r0_body.bodyRunSeg41 bodyAcc156 bodyHalt156 PRE_first_tail_x2_r0_body.bodyStepA42 bodyTop157 (fun _ hm => bodyO152 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr152).trans bodyInactive0) (bodyBr157.trans bodyBr152.symm) bodyCnt152 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) PRE_first_tail_x2_r0_body.sizeA42 PRE_first_tail_x2_r0_body.sizeArgsA42 PRE_first_tail_x2_r0_body.sizeSymA42 PRE_first_tail_x2_r0_body.sizeMlxA42 PRE_first_tail_x2_r0_body.sizePayA42 PRE_first_tail_x2_r0_body.sizeTaA42 PRE_first_tail_x2_r0_body.sizeDecA42 PRE_first_tail_x2_r0_body.sizePreA42 PRE_first_tail_x2_r0_body.bodyPatchB42 (fun _ hm => bodyO157 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr157).trans bodyInactive0) (bodyBr158.trans bodyBr157.symm) bodyCnt157 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) bodyAcc158 PRE_first_tail_x2_r0_body.bodyRunSeg42 bodyAcc160 bodyHalt160 PRE_first_tail_x2_r0_body.bodyStepA43 bodyTop161 (fun _ hm => bodyO158 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr158).trans bodyInactive0) (bodyBr161.trans bodyBr158.symm) bodyCnt158 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) PRE_first_tail_x2_r0_body.sizeA43 PRE_first_tail_x2_r0_body.sizeArgsA43 PRE_first_tail_x2_r0_body.sizeSymA43 PRE_first_tail_x2_r0_body.sizeMlxA43 PRE_first_tail_x2_r0_body.sizePayA43 PRE_first_tail_x2_r0_body.sizeTaA43 PRE_first_tail_x2_r0_body.sizeDecA43 PRE_first_tail_x2_r0_body.sizePreA43 PRE_first_tail_x2_r0_body.bodyPatchB43 (fun _ hm => bodyO161 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr161).trans bodyInactive0) (bodyBr162.trans bodyBr161.symm) bodyCnt161 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) bodyAcc162 PRE_first_tail_x2_r0_body.bodyRunSeg43 bodyAcc163 bodyHalt163 PRE_first_tail_x2_r0_body.bodyStepA44 bodyTop164 (fun _ hm => bodyO162 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr162).trans bodyInactive0) (bodyBr164.trans bodyBr162.symm) bodyCnt162 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) PRE_first_tail_x2_r0_body.sizeA44 PRE_first_tail_x2_r0_body.sizeArgsA44 PRE_first_tail_x2_r0_body.sizeSymA44 PRE_first_tail_x2_r0_body.sizeMlxA44 PRE_first_tail_x2_r0_body.sizePayA44 PRE_first_tail_x2_r0_body.sizeTaA44 PRE_first_tail_x2_r0_body.sizeDecA44 PRE_first_tail_x2_r0_body.sizePreA44 PRE_first_tail_x2_r0_body.bodyPatchB44 (fun _ hm => bodyO164 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr164).trans bodyInactive0) (bodyBr165.trans bodyBr164.symm) bodyCnt164 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11358, 173, 0, 117⟩) bodyAcc165 PRE_first_tail_x2_r0_body.bodyRunSeg44 bodyAcc167 bodyHalt167 PRE_first_tail_x2_r0_body.bodyStepA45 bodyTop168 (fun _ hm => bodyO165 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr165).trans bodyInactive0) (bodyBr168.trans bodyBr165.symm) bodyCnt165 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X2

end

section -- VWBodyS7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift7 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x2_r0_body.S168.tab.length PRE_first_tail_x2_r0_body.s168.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x2_r0_body.P7.NL) : Conv.FullShiftQ PRE_first_tail_x2_r0_body.P7 976 PRE_first_tail_x2_r0_body.kappa7 PRE_first_tail_x2_r0_body.s170.ffi PRE_first_tail_x2_r0_body.s169.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x2_r0_body.ofxC_7
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x2_r0_body.okrC_7
  have hcl : SSt (· < 976) (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_body.s170.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x2_r0_body.S168.tab.length) hr.cl (by rw [PRE_first_tail_x2_r0_body.n0_7] <;> decide) PRE_first_tail_x2_r0_body.cnodesK7 PRE_first_tail_x2_r0_body.cobjsK7
      PRE_first_tail_x2_r0_body.citemsK7 PRE_first_tail_x2_r0_body.cbd7 PRE_first_tail_x2_r0_body.csst7
  exact PRE_first_tail_x2_r0_body.cshift7 bodyNcl7 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x2_r0_body.n0_7] at this; exact this)


kernel_rfl bodyFramesEmpty7 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x2_r0_body.s169 a).isEmpty) = true
kernel_rfl bodyJsRoots7 : noBigRootsP (jsAboveB PRE_first_tail_x2_r0_body.s168.next) PRE_first_tail_x2_r0_body.s170.trace PRE_first_tail_x2_r0_body.s170 = true
kernel_rfl bodyJsNative7 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x2_r0_body.s170.ffi) = true
kernel_rfl bodyLow7 : (PRE_first_tail_x2_r0_body.cws7 ++ PRE_first_tail_x2_r0_body.ws7).all (Nat.ble 9) = true
kernel_rfl bodyCntM7 : countersOkB PRE_first_tail_x2_r0_body.s168 PRE_first_tail_x2_r0_body.s169 = true
kernel_rfl bodyHi7 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s170.ffi).next setupP.E = true
kernel_rfl bodyNhi7 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s170.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge7 : bridgeOf PRE_first_tail_x2_r0_body.s169.ffi = bridgeOf PRE_first_tail_x2_r0_body.s168.ffi
kernel_rfl bodyNN7 : Nat.ble (mlxOf PRE_first_tail_x2_r0_body.s168.ffi).nnext PRE_first_tail_x2_r0_body.P7.NL = true
kernel_rfl bodyXn7 : Nat.ble (⟨18633, 15719, 2691797, 976⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x2_r0_body.s170.ffi).next = true
kernel_rfl bodyLo7 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x2_r0_body.s170.ffi).next = true
theorem bodyFacts7 : BodySiteFacts PRE_first_tail_x2_r0_body.s168 PRE_first_tail_x2_r0_body.s169 PRE_first_tail_x2_r0_body.s170 PRE_first_tail_x2_r0_body.s0 PRE_first_tail_x2_r0_body.S168 PRE_first_tail_x2_r0_body.S169 PRE_first_tail_x2_r0_body.S170
    PRE_first_tail_x2_r0_body.ws7 PRE_first_tail_x2_r0_body.cws7 PRE_first_tail_x2_r0_body.nr7 PRE_first_tail_x2_r0_body.pl7 PRE_first_tail_x2_r0_body.cl7 2692147 976 PRE_first_tail_x2_r0_body.kd7 PRE_first_tail_x2_r0_body.kappa7 PRE_first_tail_x2_r0_body.P7
    ⟨18629, 15713, 2691782, 967⟩ ⟨18633, 15719, 2691797, 976⟩ where
  zkap := PRE_first_tail_x2_r0_body.zkap7
  clean := bodyClean7
  cfix := PRE_first_tail_x2_r0_body.cfix7
  zpl := PRE_first_tail_x2_r0_body.zpl7
  zplnd := PRE_first_tail_x2_r0_body.zplnd7
  zn1 := PRE_first_tail_x2_r0_body.zn17
  zfirst := PRE_first_tail_x2_r0_body.zfirst7
  zscn := PRE_first_tail_x2_r0_body.zscn7
  zsmn := PRE_first_tail_x2_r0_body.zsmn7
  zgrow := PRE_first_tail_x2_r0_body.zgrow7
  mergeTab := PRE_first_tail_x2_r0_body.mergeTab7
  zfresh := PRE_first_tail_x2_r0_body.zfresh7
  zcnd := PRE_first_tail_x2_r0_body.zcnd7
  lenc := by rfl
  znrHi := PRE_first_tail_x2_r0_body.znrHi7
  zfrlt := PRE_first_tail_x2_r0_body.zfrlt7
  zgP := PRE_first_tail_x2_r0_body.zg7_2665
  zkP := PRE_first_tail_x2_r0_body.zk7_2665
  zmP := PRE_first_tail_x2_r0_body.zm7_2665
  zgC := PRE_first_tail_x2_r0_body.zg7_2673467
  zkC := PRE_first_tail_x2_r0_body.zk7_2673467
  zmC := PRE_first_tail_x2_r0_body.zm7_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x2_r0_body.zw7_2673472
  zwV := PRE_first_tail_x2_r0_body.zw7_2673473
  cheap := PRE_first_tail_x2_r0_body.cheap7
  zclbd := PRE_first_tail_x2_r0_body.zclbd7
  hml := hoff_of PRE_first_tail_x2_r0_body.mheap7 PRE_first_tail_x2_r0_body.stFoot7 PRE_first_tail_x2_r0_body.iso7 PRE_first_tail_x2_r0_body.zwr7
  ckeepP := PRE_first_tail_x2_r0_body.ckeepP7
  csupp := PRE_first_tail_x2_r0_body.csupp7
  cbound := PRE_first_tail_x2_r0_body.cbound7
  zimg := PRE_first_tail_x2_r0_body.zimg7
  zctl := PRE_first_tail_x2_r0_body.zctl7
  zstack := PRE_first_tail_x2_r0_body.zstack7
  zjobs := PRE_first_tail_x2_r0_body.zjobs7
  zstores := PRE_first_tail_x2_r0_body.zstores7
  zroots := PRE_first_tail_x2_r0_body.zroots7
  znC := PRE_first_tail_x2_r0_body.znC7
  ctab := PRE_first_tail_x2_r0_body.ctab7
  zbin := PRE_first_tail_x2_r0_body.zbin7
  cbridge := PRE_first_tail_x2_r0_body.cbridge7
  sbridge := bodyBridge7
  cwsDisj := PRE_first_tail_x2_r0_body.cwsDisj7
  cshiftR := fun h hNL => bodyCshift7 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN7
  raised := PRE_first_tail_x2_r0_body.raised7
  cbigs := PRE_first_tail_x2_r0_body.cbigs7
  cjcl := PRE_first_tail_x2_r0_body.cjcl7
  xnLe := Nat.le_of_ble_eq_true bodyXn7
  loLe := Nat.le_of_ble_eq_true bodyLo7
  zroots2 := PRE_first_tail_x2_r0_body.zrootsB7
  cntM := bodyCntM7
  hiLe := Nat.le_of_ble_eq_true bodyHi7
  nhiLe := Nat.le_of_ble_eq_true bodyNhi7
  jsHeap := bodyJs7
  jsRoots := bodyJsRoots7
  jsNative := bodyJsNative7
  framesEmpty := bodyFramesEmpty7
  trailOld := by decide
  lowVars := bodyLow7

def bodyQs7 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs7 : List (Option SymE) := PRE_first_tail_x2_r0_body.nr7.map fun r => nth? PRE_first_tail_x2_r0_body.st7.S3.tab r
kernel_rfl bodyResChk7 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs7 bodyQs7) = true
kernel_rfl bodyLq7 : bodyQs7.length = PRE_first_tail_x2_r0_body.cws7.length
kernel_rfl bodyNrLo7 : PRE_first_tail_x2_r0_body.nr7.all (Nat.ble PRE_first_tail_x2_r0_body.S168.tab.length) = true
kernel_rfl bodySub7 : (Oracles.PRE_first_tail_x2_r0_body.map_site7.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost7 : postSubB bodyM PRE_first_tail_x2_r0_body.ws7 PRE_first_tail_x2_r0_body.cws7 bodyQs7 = true
kernel_rfl bodyDrop7 : Nat.ble (11358 + (PRE_first_tail_x2_r0_body.s169.next - PRE_first_tail_x2_r0_body.s170.next)) 11708 = true
kernel_rfl bodyDropH7 : Nat.ble (173 + ((mlxOf PRE_first_tail_x2_r0_body.s169.ffi).next - (mlxOf PRE_first_tail_x2_r0_body.s170.ffi).next)) 175 = true
kernel_rfl bodyDropN7 : Nat.ble (0 + ((mlxOf PRE_first_tail_x2_r0_body.s169.ffi).nnext - (mlxOf PRE_first_tail_x2_r0_body.s170.ffi).nnext)) 0 = true
kernel_rfl bodyDv7 : bodyΘ.1.take 126 = bodyΘ.1.take 117 ++ PRE_first_tail_x2_r0_body.cws7
kernel_rfl bodyDe7 : bodyΘ.2.take 126 = bodyΘ.2.take 117 ++ PRE_first_tail_x2_r0_body.nr7.map (fun r =>
  ((nth? PRE_first_tail_x2_r0_body.st7.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 117) (bodyΘ.2.take 117)))
kernel_rfl bodyDl7 : (bodyΘ.1.take 117).length = (bodyΘ.2.take 117).length
kernel_rfl bodyDold7 : (bodyΘ.1.take 117).all (fun v => (Conv.idx? v PRE_first_tail_x2_r0_body.cws7).isNone && !PRE_first_tail_x2_r0_body.ws7.contains v) = true
kernel_rfl bodyDfree7 : (bodyΘ.2.take 126).all (fun e => (PRE_first_tail_x2_r0_body.cws7 ++ PRE_first_tail_x2_r0_body.ws7).all fun w => e.noVar w) = true

theorem bodyStep7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11358, 173, 0, 117⟩ bodyM PRE_first_tail_x2_r0_body.s168 PRE_first_tail_x2_r0_body.S168)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 126⟩ bodyM PRE_first_tail_x2_r0_body.s170 PRE_first_tail_x2_r0_body.S170) (3452 + 1) :=
  bodySite bodyFacts7.cfix bodyFacts7.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x2_r0_body.st7.S3.tab) (Es := bodyEs7) (qs := bodyQs7)
    (ok := PRE_first_tail_x2_r0_body.st7.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x2_r0_body.site7 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts7
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x2_r0_body.chk_site7 r hr) hi (MapOk.sub hm (sub_of_all bodySub7)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk7 r hr) hi hm ho hq)
    bodyLq7 rfl bodyNrLo7 (postSub_sound bodyPost7)
    (Nat.le_of_ble_eq_true bodyDrop7) (by decide) (Nat.le_of_ble_eq_true bodyDropH7) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN7) (by decide)
    bodyDv7 bodyDe7 bodyDl7 bodyDold7 bodyDfree7 hR hB

end Host.Ts.Sim.Compose.VWFirst.X2

end
