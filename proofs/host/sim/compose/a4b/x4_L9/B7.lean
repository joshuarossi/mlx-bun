import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.States
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B22
import host.sim.compose.a4b.x4_L9.B6
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B24
import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L9.VWBodyChain
import host.sim.compose.a4b.x4_L9.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B14
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B00
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B23

section -- VWBodyOracles_14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_g56 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g56 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g56) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site56 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site56 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site56) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st56.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g57 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g57 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g57) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site57 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site57 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site57) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st57.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g58 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g58 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g58) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site58 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site58 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site58) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st58.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g59 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g59 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g59) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site59 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site59 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site59) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st59.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site56 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site56 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site56) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st56.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site56
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st56.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st56.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1262 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1263 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1262 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws56 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st56.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st56.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso56
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_56
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st56.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot56
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup56
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound56
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace56
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged56
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws56.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st56.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1262.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_56]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen56.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh56
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl56 : Conv.NClean (⟨21702, 18778, 2815767, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1262.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl56 (PRE_first_tail_x4_L9_r0_body.cncl55 bodyNcl55)

theorem bodyClean56 : Conv.JClean (⟨21702, 18778, 2815767, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s1262 :=
  PRE_first_tail_x4_L9_r0_body.gjcl56 (PRE_first_tail_x4_L9_r0_body.cjcl55 bodyClean55)

kernel_rfl bodyJsLe56 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1238.next PRE_first_tail_x4_L9_r0_body.s1262.next = true
kernel_rfl bodyJsList56 : (PRE_first_tail_x4_L9_r0_body.gjh56 ++ PRE_first_tail_x4_L9_r0_body.cl56).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1262.next) PRE_first_tail_x4_L9_r0_body.s1264) = true
theorem bodyJs56 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s1262.next PRE_first_tail_x4_L9_r0_body.s1264 :=
  JsHeapAbove.glueSite bodyJs55 (Nat.le_of_ble_eq_true bodyJsLe56) PRE_first_tail_x4_L9_r0_body.gjk56 PRE_first_tail_x4_L9_r0_body.gjbd56 PRE_first_tail_x4_L9_r0_body.cheap56 PRE_first_tail_x4_L9_r0_body.zclbd56 bodyJsList56

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1240 : PRE_first_tail_x4_L9_r0_body.S1240.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1240.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1240 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1240.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1240 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1240 PRE_first_tail_x4_L9_r0_body.S1240) = fun _ _ => true
kernel_rfl bodyAcc1243 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1243 PRE_first_tail_x4_L9_r0_body.S1243) = fun _ _ => true
kernel_rfl bodyBr1244 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1244.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1243 : isHalt PRE_first_tail_x4_L9_r0_body.s1243.ctl = false
kernel_rfl bodyTop1244 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1244 = true
kernel_rfl bodyCnt1240 : countersOkB PRE_first_tail_x4_L9_r0_body.s1240 PRE_first_tail_x4_L9_r0_body.s1244 = true
kernel_rfl bodyO1244 : PRE_first_tail_x4_L9_r0_body.S1244.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1244.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1245 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1245.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1244 : countersOkB PRE_first_tail_x4_L9_r0_body.s1244 PRE_first_tail_x4_L9_r0_body.s1245 = true
kernel_rfl bodyO1245 : PRE_first_tail_x4_L9_r0_body.S1245.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1245.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1245 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1245 PRE_first_tail_x4_L9_r0_body.S1245) = fun _ _ => true
kernel_rfl bodyAcc1249 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1249 PRE_first_tail_x4_L9_r0_body.S1249) = fun _ _ => true
kernel_rfl bodyBr1250 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1250.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1249 : isHalt PRE_first_tail_x4_L9_r0_body.s1249.ctl = false
kernel_rfl bodyTop1250 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1250 = true
kernel_rfl bodyCnt1245 : countersOkB PRE_first_tail_x4_L9_r0_body.s1245 PRE_first_tail_x4_L9_r0_body.s1250 = true
kernel_rfl bodyO1250 : PRE_first_tail_x4_L9_r0_body.S1250.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1250.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1251 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1251.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1250 : countersOkB PRE_first_tail_x4_L9_r0_body.s1250 PRE_first_tail_x4_L9_r0_body.s1251 = true
kernel_rfl bodyO1251 : PRE_first_tail_x4_L9_r0_body.S1251.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1251.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1251 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1251 PRE_first_tail_x4_L9_r0_body.S1251) = fun _ _ => true
kernel_rfl bodyAcc1252 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1252 PRE_first_tail_x4_L9_r0_body.S1252) = fun _ _ => true
kernel_rfl bodyBr1253 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1253.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1252 : isHalt PRE_first_tail_x4_L9_r0_body.s1252.ctl = false
kernel_rfl bodyTop1253 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1253 = true
kernel_rfl bodyCnt1251 : countersOkB PRE_first_tail_x4_L9_r0_body.s1251 PRE_first_tail_x4_L9_r0_body.s1253 = true
kernel_rfl bodyO1253 : PRE_first_tail_x4_L9_r0_body.S1253.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1253.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1254 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1254.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1253 : countersOkB PRE_first_tail_x4_L9_r0_body.s1253 PRE_first_tail_x4_L9_r0_body.s1254 = true
kernel_rfl bodyO1254 : PRE_first_tail_x4_L9_r0_body.S1254.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1254.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1254 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1254 PRE_first_tail_x4_L9_r0_body.S1254) = fun _ _ => true
kernel_rfl bodyAcc1255 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1255 PRE_first_tail_x4_L9_r0_body.S1255) = fun _ _ => true
kernel_rfl bodyBr1256 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1256.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1255 : isHalt PRE_first_tail_x4_L9_r0_body.s1255.ctl = false
kernel_rfl bodyTop1256 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1256 = true
kernel_rfl bodyCnt1254 : countersOkB PRE_first_tail_x4_L9_r0_body.s1254 PRE_first_tail_x4_L9_r0_body.s1256 = true
kernel_rfl bodyO1256 : PRE_first_tail_x4_L9_r0_body.S1256.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1256.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1257 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1257.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1256 : countersOkB PRE_first_tail_x4_L9_r0_body.s1256 PRE_first_tail_x4_L9_r0_body.s1257 = true
kernel_rfl bodyO1257 : PRE_first_tail_x4_L9_r0_body.S1257.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1257.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1257 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1257 PRE_first_tail_x4_L9_r0_body.S1257) = fun _ _ => true
kernel_rfl bodyAcc1258 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1258 PRE_first_tail_x4_L9_r0_body.S1258) = fun _ _ => true
kernel_rfl bodyBr1259 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1259.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1258 : isHalt PRE_first_tail_x4_L9_r0_body.s1258.ctl = false
kernel_rfl bodyTop1259 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1259 = true
kernel_rfl bodyCnt1257 : countersOkB PRE_first_tail_x4_L9_r0_body.s1257 PRE_first_tail_x4_L9_r0_body.s1259 = true
kernel_rfl bodyO1259 : PRE_first_tail_x4_L9_r0_body.S1259.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1259.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1260 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1260.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1259 : countersOkB PRE_first_tail_x4_L9_r0_body.s1259 PRE_first_tail_x4_L9_r0_body.s1260 = true
kernel_rfl bodyO1260 : PRE_first_tail_x4_L9_r0_body.S1260.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1260.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1260 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1260 PRE_first_tail_x4_L9_r0_body.S1260) = fun _ _ => true
kernel_rfl bodyAcc1261 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1261 PRE_first_tail_x4_L9_r0_body.S1261) = fun _ _ => true
kernel_rfl bodyBr1262 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1262.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1261 : isHalt PRE_first_tail_x4_L9_r0_body.s1261.ctl = false
kernel_rfl bodyTop1262 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1262 = true
kernel_rfl bodyCnt1260 : countersOkB PRE_first_tail_x4_L9_r0_body.s1260 PRE_first_tail_x4_L9_r0_body.s1262 = true

theorem bodyGlue56 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨57272, 1099, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1240 PRE_first_tail_x4_L9_r0_body.S1240)
      (bodyCut NB T tk π i x0 bodyΘ ⟨57272, 1099, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1262 PRE_first_tail_x4_L9_r0_body.S1262) 30942 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) bodyAcc1240 PRE_first_tail_x4_L9_r0_body.bodyRunSeg321 bodyAcc1243 bodyHalt1243 PRE_first_tail_x4_L9_r0_body.bodyStepA322 bodyTop1244 (fun _ hm => bodyO1240 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1240).trans bodyInactive0) (bodyBr1244.trans bodyBr1240.symm) bodyCnt1240 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA322 PRE_first_tail_x4_L9_r0_body.sizeArgsA322 PRE_first_tail_x4_L9_r0_body.sizeSymA322 PRE_first_tail_x4_L9_r0_body.sizeMlxA322 PRE_first_tail_x4_L9_r0_body.sizePayA322 PRE_first_tail_x4_L9_r0_body.sizeTaA322 PRE_first_tail_x4_L9_r0_body.sizeDecA322 PRE_first_tail_x4_L9_r0_body.sizePreA322 PRE_first_tail_x4_L9_r0_body.bodyPatchB322 (fun _ hm => bodyO1244 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1244).trans bodyInactive0) (bodyBr1245.trans bodyBr1244.symm) bodyCnt1244 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) bodyAcc1245 PRE_first_tail_x4_L9_r0_body.bodyRunSeg322 bodyAcc1249 bodyHalt1249 PRE_first_tail_x4_L9_r0_body.bodyStepA323 bodyTop1250 (fun _ hm => bodyO1245 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1245).trans bodyInactive0) (bodyBr1250.trans bodyBr1245.symm) bodyCnt1245 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA323 PRE_first_tail_x4_L9_r0_body.sizeArgsA323 PRE_first_tail_x4_L9_r0_body.sizeSymA323 PRE_first_tail_x4_L9_r0_body.sizeMlxA323 PRE_first_tail_x4_L9_r0_body.sizePayA323 PRE_first_tail_x4_L9_r0_body.sizeTaA323 PRE_first_tail_x4_L9_r0_body.sizeDecA323 PRE_first_tail_x4_L9_r0_body.sizePreA323 PRE_first_tail_x4_L9_r0_body.bodyPatchB323 (fun _ hm => bodyO1250 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1250).trans bodyInactive0) (bodyBr1251.trans bodyBr1250.symm) bodyCnt1250 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) bodyAcc1251 PRE_first_tail_x4_L9_r0_body.bodyRunSeg323 bodyAcc1252 bodyHalt1252 PRE_first_tail_x4_L9_r0_body.bodyStepA324 bodyTop1253 (fun _ hm => bodyO1251 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1251).trans bodyInactive0) (bodyBr1253.trans bodyBr1251.symm) bodyCnt1251 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA324 PRE_first_tail_x4_L9_r0_body.sizeArgsA324 PRE_first_tail_x4_L9_r0_body.sizeSymA324 PRE_first_tail_x4_L9_r0_body.sizeMlxA324 PRE_first_tail_x4_L9_r0_body.sizePayA324 PRE_first_tail_x4_L9_r0_body.sizeTaA324 PRE_first_tail_x4_L9_r0_body.sizeDecA324 PRE_first_tail_x4_L9_r0_body.sizePreA324 PRE_first_tail_x4_L9_r0_body.bodyPatchB324 (fun _ hm => bodyO1253 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1253).trans bodyInactive0) (bodyBr1254.trans bodyBr1253.symm) bodyCnt1253 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) bodyAcc1254 PRE_first_tail_x4_L9_r0_body.bodyRunSeg324 bodyAcc1255 bodyHalt1255 PRE_first_tail_x4_L9_r0_body.bodyStepA325 bodyTop1256 (fun _ hm => bodyO1254 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1254).trans bodyInactive0) (bodyBr1256.trans bodyBr1254.symm) bodyCnt1254 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA325 PRE_first_tail_x4_L9_r0_body.sizeArgsA325 PRE_first_tail_x4_L9_r0_body.sizeSymA325 PRE_first_tail_x4_L9_r0_body.sizeMlxA325 PRE_first_tail_x4_L9_r0_body.sizePayA325 PRE_first_tail_x4_L9_r0_body.sizeTaA325 PRE_first_tail_x4_L9_r0_body.sizeDecA325 PRE_first_tail_x4_L9_r0_body.sizePreA325 PRE_first_tail_x4_L9_r0_body.bodyPatchB325 (fun _ hm => bodyO1256 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1256).trans bodyInactive0) (bodyBr1257.trans bodyBr1256.symm) bodyCnt1256 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) bodyAcc1257 PRE_first_tail_x4_L9_r0_body.bodyRunSeg325 bodyAcc1258 bodyHalt1258 PRE_first_tail_x4_L9_r0_body.bodyStepA326 bodyTop1259 (fun _ hm => bodyO1257 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1257).trans bodyInactive0) (bodyBr1259.trans bodyBr1257.symm) bodyCnt1257 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA326 PRE_first_tail_x4_L9_r0_body.sizeArgsA326 PRE_first_tail_x4_L9_r0_body.sizeSymA326 PRE_first_tail_x4_L9_r0_body.sizeMlxA326 PRE_first_tail_x4_L9_r0_body.sizePayA326 PRE_first_tail_x4_L9_r0_body.sizeTaA326 PRE_first_tail_x4_L9_r0_body.sizeDecA326 PRE_first_tail_x4_L9_r0_body.sizePreA326 PRE_first_tail_x4_L9_r0_body.bodyPatchB326 (fun _ hm => bodyO1259 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1259).trans bodyInactive0) (bodyBr1260.trans bodyBr1259.symm) bodyCnt1259 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57272, 1099, 0, 0⟩) bodyAcc1260 PRE_first_tail_x4_L9_r0_body.bodyRunSeg326 bodyAcc1261 bodyHalt1261 PRE_first_tail_x4_L9_r0_body.bodyStepA327 bodyTop1262 (fun _ hm => bodyO1260 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1260).trans bodyInactive0) (bodyBr1262.trans bodyBr1260.symm) bodyCnt1260 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift56 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S1262.tab.length PRE_first_tail_x4_L9_r0_body.s1262.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P56.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P56 15 PRE_first_tail_x4_L9_r0_body.kappa56 PRE_first_tail_x4_L9_r0_body.s1264.ffi PRE_first_tail_x4_L9_r0_body.s1263.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_56
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_56
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1264.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S1262.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_56] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK56 PRE_first_tail_x4_L9_r0_body.cobjsK56
      PRE_first_tail_x4_L9_r0_body.citemsK56 PRE_first_tail_x4_L9_r0_body.cbd56 PRE_first_tail_x4_L9_r0_body.csst56
  exact PRE_first_tail_x4_L9_r0_body.cshift56 bodyNcl56 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_56] at this; exact this)


kernel_rfl bodyFramesEmpty56 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s1263 a).isEmpty) = true
kernel_rfl bodyJsRoots56 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1262.next) PRE_first_tail_x4_L9_r0_body.s1264.trace PRE_first_tail_x4_L9_r0_body.s1264 = true
kernel_rfl bodyJsNative56 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s1264.ffi) = true
kernel_rfl bodyLow56 : (PRE_first_tail_x4_L9_r0_body.cws56 ++ PRE_first_tail_x4_L9_r0_body.ws56).all (Nat.ble 9) = true
kernel_rfl bodyCntM56 : countersOkB PRE_first_tail_x4_L9_r0_body.s1262 PRE_first_tail_x4_L9_r0_body.s1263 = true
kernel_rfl bodyHi56 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1264.ffi).next setupP.E = true
kernel_rfl bodyNhi56 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1264.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge56 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1263.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s1262.ffi
kernel_rfl bodyNN56 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1262.ffi).nnext PRE_first_tail_x4_L9_r0_body.P56.NL = true
kernel_rfl bodyXn56 : Nat.ble (⟨21705, 18805, 2815773, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s1264.ffi).next = true
kernel_rfl bodyLo56 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s1264.ffi).next = true
theorem bodyFacts56 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s1262 PRE_first_tail_x4_L9_r0_body.s1263 PRE_first_tail_x4_L9_r0_body.s1264 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S1262 PRE_first_tail_x4_L9_r0_body.S1263 PRE_first_tail_x4_L9_r0_body.S1264
    PRE_first_tail_x4_L9_r0_body.ws56 PRE_first_tail_x4_L9_r0_body.cws56 PRE_first_tail_x4_L9_r0_body.nr56 PRE_first_tail_x4_L9_r0_body.pl56 PRE_first_tail_x4_L9_r0_body.cl56 2816922 15 PRE_first_tail_x4_L9_r0_body.kd56 PRE_first_tail_x4_L9_r0_body.kappa56 PRE_first_tail_x4_L9_r0_body.P56
    ⟨21702, 18778, 2815767, 15⟩ ⟨21705, 18805, 2815773, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap56
  clean := bodyClean56
  cfix := PRE_first_tail_x4_L9_r0_body.cfix56
  zpl := PRE_first_tail_x4_L9_r0_body.zpl56
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd56
  zn1 := PRE_first_tail_x4_L9_r0_body.zn156
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst56
  zscn := PRE_first_tail_x4_L9_r0_body.zscn56
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn56
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow56
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab56
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh56
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd56
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi56
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt56
  zgP := PRE_first_tail_x4_L9_r0_body.zg56_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk56_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm56_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg56_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk56_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm56_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw56_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw56_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap56
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd56
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap56 PRE_first_tail_x4_L9_r0_body.stFoot56 PRE_first_tail_x4_L9_r0_body.iso56 PRE_first_tail_x4_L9_r0_body.zwr56
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP56
  csupp := PRE_first_tail_x4_L9_r0_body.csupp56
  cbound := PRE_first_tail_x4_L9_r0_body.cbound56
  zimg := PRE_first_tail_x4_L9_r0_body.zimg56
  zctl := PRE_first_tail_x4_L9_r0_body.zctl56
  zstack := PRE_first_tail_x4_L9_r0_body.zstack56
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs56
  zstores := PRE_first_tail_x4_L9_r0_body.zstores56
  zroots := PRE_first_tail_x4_L9_r0_body.zroots56
  znC := PRE_first_tail_x4_L9_r0_body.znC56
  ctab := PRE_first_tail_x4_L9_r0_body.ctab56
  zbin := PRE_first_tail_x4_L9_r0_body.zbin56
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge56
  sbridge := bodyBridge56
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj56
  cshiftR := fun h hNL => bodyCshift56 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN56
  raised := PRE_first_tail_x4_L9_r0_body.raised56
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs56
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl56
  xnLe := Nat.le_of_ble_eq_true bodyXn56
  loLe := Nat.le_of_ble_eq_true bodyLo56
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB56
  cntM := bodyCntM56
  hiLe := Nat.le_of_ble_eq_true bodyHi56
  nhiLe := Nat.le_of_ble_eq_true bodyNhi56
  jsHeap := bodyJs56
  jsRoots := bodyJsRoots56
  jsNative := bodyJsNative56
  framesEmpty := bodyFramesEmpty56
  trailOld := by decide
  lowVars := bodyLow56

def bodyQs56 : List (Option Q) := []
noncomputable def bodyEs56 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr56.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st56.S5.tab r
kernel_rfl bodyResChk56 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs56 bodyQs56) = true
kernel_rfl bodyLq56 : bodyQs56.length = PRE_first_tail_x4_L9_r0_body.cws56.length
kernel_rfl bodyNrLo56 : PRE_first_tail_x4_L9_r0_body.nr56.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S1262.tab.length) = true
kernel_rfl bodySub56 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site56.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost56 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws56 PRE_first_tail_x4_L9_r0_body.cws56 bodyQs56 = true
kernel_rfl bodyDrop56 : Nat.ble (57272 + (PRE_first_tail_x4_L9_r0_body.s1263.next - PRE_first_tail_x4_L9_r0_body.s1264.next)) 58421 = true
kernel_rfl bodyDropH56 : Nat.ble (1099 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1263.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s1264.ffi).next)) 1124 = true
kernel_rfl bodyDropN56 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1263.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s1264.ffi).nnext)) 0 = true
kernel_rfl bodyDv56 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws56
kernel_rfl bodyDe56 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr56.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st56.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl56 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold56 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws56).isNone && !PRE_first_tail_x4_L9_r0_body.ws56.contains v) = true
kernel_rfl bodyDfree56 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws56 ++ PRE_first_tail_x4_L9_r0_body.ws56).all fun w => e.noVar w) = true

theorem bodyStep56 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨57272, 1099, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1262 PRE_first_tail_x4_L9_r0_body.S1262)
      (bodyCut NB T tk π i x0 bodyΘ ⟨58421, 1124, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1264 PRE_first_tail_x4_L9_r0_body.S1264) (11334 + 1) :=
  bodySite bodyFacts56.cfix bodyFacts56.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st56.S5.tab) (Es := bodyEs56) (qs := bodyQs56)
    (ok := PRE_first_tail_x4_L9_r0_body.st56.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site56 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts56
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site56 r hr) hi (MapOk.sub hm (sub_of_all bodySub56)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk56 r hr) hi hm ho hq)
    bodyLq56 rfl bodyNrLo56 (postSub_sound bodyPost56)
    (Nat.le_of_ble_eq_true bodyDrop56) (by decide) (Nat.le_of_ble_eq_true bodyDropH56) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN56) (by decide)
    bodyDv56 bodyDe56 bodyDl56 bodyDold56 bodyDfree56 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site57 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site57 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site57) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st57.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site57
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st57.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st57.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1284 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1285 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1284 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws57 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st57.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st57.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso57
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_57
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st57.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot57
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup57
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound57
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace57
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged57
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws57.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st57.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1284.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_57]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen57.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh57
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl57 : Conv.NClean (⟨21759, 18841, 2818009, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1284.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl57 (PRE_first_tail_x4_L9_r0_body.cncl56 bodyNcl56)

theorem bodyClean57 : Conv.JClean (⟨21759, 18841, 2818009, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s1284 :=
  PRE_first_tail_x4_L9_r0_body.gjcl57 (PRE_first_tail_x4_L9_r0_body.cjcl56 bodyClean56)

kernel_rfl bodyJsLe57 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1262.next PRE_first_tail_x4_L9_r0_body.s1284.next = true
kernel_rfl bodyJsList57 : (PRE_first_tail_x4_L9_r0_body.gjh57 ++ PRE_first_tail_x4_L9_r0_body.cl57).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1284.next) PRE_first_tail_x4_L9_r0_body.s1286) = true
theorem bodyJs57 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s1284.next PRE_first_tail_x4_L9_r0_body.s1286 :=
  JsHeapAbove.glueSite bodyJs56 (Nat.le_of_ble_eq_true bodyJsLe57) PRE_first_tail_x4_L9_r0_body.gjk57 PRE_first_tail_x4_L9_r0_body.gjbd57 PRE_first_tail_x4_L9_r0_body.cheap57 PRE_first_tail_x4_L9_r0_body.zclbd57 bodyJsList57

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1264 : PRE_first_tail_x4_L9_r0_body.S1264.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1264.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1264 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1264.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1264 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1264 PRE_first_tail_x4_L9_r0_body.S1264) = fun _ _ => true
kernel_rfl bodyAcc1265 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1265 PRE_first_tail_x4_L9_r0_body.S1265) = fun _ _ => true
kernel_rfl bodyBr1266 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1266.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1265 : isHalt PRE_first_tail_x4_L9_r0_body.s1265.ctl = false
kernel_rfl bodyTop1266 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1266 = true
kernel_rfl bodyCnt1264 : countersOkB PRE_first_tail_x4_L9_r0_body.s1264 PRE_first_tail_x4_L9_r0_body.s1266 = true
kernel_rfl bodyO1266 : PRE_first_tail_x4_L9_r0_body.S1266.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1266.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1267 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1267.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1266 : countersOkB PRE_first_tail_x4_L9_r0_body.s1266 PRE_first_tail_x4_L9_r0_body.s1267 = true
kernel_rfl bodyO1267 : PRE_first_tail_x4_L9_r0_body.S1267.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1267.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1267 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1267 PRE_first_tail_x4_L9_r0_body.S1267) = fun _ _ => true
kernel_rfl bodyAcc1271 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1271 PRE_first_tail_x4_L9_r0_body.S1271) = fun _ _ => true
kernel_rfl bodyBr1272 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1272.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1271 : isHalt PRE_first_tail_x4_L9_r0_body.s1271.ctl = false
kernel_rfl bodyTop1272 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1272 = true
kernel_rfl bodyCnt1267 : countersOkB PRE_first_tail_x4_L9_r0_body.s1267 PRE_first_tail_x4_L9_r0_body.s1272 = true
kernel_rfl bodyO1272 : PRE_first_tail_x4_L9_r0_body.S1272.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1272.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1273 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1273.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1272 : countersOkB PRE_first_tail_x4_L9_r0_body.s1272 PRE_first_tail_x4_L9_r0_body.s1273 = true
kernel_rfl bodyO1273 : PRE_first_tail_x4_L9_r0_body.S1273.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1273.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1273 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1273 PRE_first_tail_x4_L9_r0_body.S1273) = fun _ _ => true
kernel_rfl bodyAcc1274 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1274 PRE_first_tail_x4_L9_r0_body.S1274) = fun _ _ => true
kernel_rfl bodyBr1275 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1275.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1274 : isHalt PRE_first_tail_x4_L9_r0_body.s1274.ctl = false
kernel_rfl bodyTop1275 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1275 = true
kernel_rfl bodyCnt1273 : countersOkB PRE_first_tail_x4_L9_r0_body.s1273 PRE_first_tail_x4_L9_r0_body.s1275 = true
kernel_rfl bodyO1275 : PRE_first_tail_x4_L9_r0_body.S1275.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1275.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1276 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1276.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1275 : countersOkB PRE_first_tail_x4_L9_r0_body.s1275 PRE_first_tail_x4_L9_r0_body.s1276 = true
kernel_rfl bodyO1276 : PRE_first_tail_x4_L9_r0_body.S1276.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1276.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1276 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1276 PRE_first_tail_x4_L9_r0_body.S1276) = fun _ _ => true
kernel_rfl bodyAcc1277 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1277 PRE_first_tail_x4_L9_r0_body.S1277) = fun _ _ => true
kernel_rfl bodyBr1278 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1278.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1277 : isHalt PRE_first_tail_x4_L9_r0_body.s1277.ctl = false
kernel_rfl bodyTop1278 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1278 = true
kernel_rfl bodyCnt1276 : countersOkB PRE_first_tail_x4_L9_r0_body.s1276 PRE_first_tail_x4_L9_r0_body.s1278 = true
kernel_rfl bodyO1278 : PRE_first_tail_x4_L9_r0_body.S1278.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1278.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1279 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1279.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1278 : countersOkB PRE_first_tail_x4_L9_r0_body.s1278 PRE_first_tail_x4_L9_r0_body.s1279 = true
kernel_rfl bodyO1279 : PRE_first_tail_x4_L9_r0_body.S1279.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1279.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1279 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1279 PRE_first_tail_x4_L9_r0_body.S1279) = fun _ _ => true
kernel_rfl bodyAcc1280 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1280 PRE_first_tail_x4_L9_r0_body.S1280) = fun _ _ => true
kernel_rfl bodyBr1281 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1281.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1280 : isHalt PRE_first_tail_x4_L9_r0_body.s1280.ctl = false
kernel_rfl bodyTop1281 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1281 = true
kernel_rfl bodyCnt1279 : countersOkB PRE_first_tail_x4_L9_r0_body.s1279 PRE_first_tail_x4_L9_r0_body.s1281 = true
kernel_rfl bodyO1281 : PRE_first_tail_x4_L9_r0_body.S1281.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1281.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1282 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1282.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1281 : countersOkB PRE_first_tail_x4_L9_r0_body.s1281 PRE_first_tail_x4_L9_r0_body.s1282 = true
kernel_rfl bodyO1282 : PRE_first_tail_x4_L9_r0_body.S1282.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1282.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1282 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1282 PRE_first_tail_x4_L9_r0_body.S1282) = fun _ _ => true
kernel_rfl bodyAcc1283 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1283 PRE_first_tail_x4_L9_r0_body.S1283) = fun _ _ => true
kernel_rfl bodyBr1284 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1284.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1283 : isHalt PRE_first_tail_x4_L9_r0_body.s1283.ctl = false
kernel_rfl bodyTop1284 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1284 = true
kernel_rfl bodyCnt1282 : countersOkB PRE_first_tail_x4_L9_r0_body.s1282 PRE_first_tail_x4_L9_r0_body.s1284 = true

theorem bodyGlue57 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨58421, 1124, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1264 PRE_first_tail_x4_L9_r0_body.S1264)
      (bodyCut NB T tk π i x0 bodyΘ ⟨58421, 1124, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1284 PRE_first_tail_x4_L9_r0_body.S1284) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) bodyAcc1264 PRE_first_tail_x4_L9_r0_body.bodyRunSeg327 bodyAcc1265 bodyHalt1265 PRE_first_tail_x4_L9_r0_body.bodyStepA328 bodyTop1266 (fun _ hm => bodyO1264 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1264).trans bodyInactive0) (bodyBr1266.trans bodyBr1264.symm) bodyCnt1264 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA328 PRE_first_tail_x4_L9_r0_body.sizeArgsA328 PRE_first_tail_x4_L9_r0_body.sizeSymA328 PRE_first_tail_x4_L9_r0_body.sizeMlxA328 PRE_first_tail_x4_L9_r0_body.sizePayA328 PRE_first_tail_x4_L9_r0_body.sizeTaA328 PRE_first_tail_x4_L9_r0_body.sizeDecA328 PRE_first_tail_x4_L9_r0_body.sizePreA328 PRE_first_tail_x4_L9_r0_body.bodyPatchB328 (fun _ hm => bodyO1266 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1266).trans bodyInactive0) (bodyBr1267.trans bodyBr1266.symm) bodyCnt1266 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) bodyAcc1267 PRE_first_tail_x4_L9_r0_body.bodyRunSeg328 bodyAcc1271 bodyHalt1271 PRE_first_tail_x4_L9_r0_body.bodyStepA329 bodyTop1272 (fun _ hm => bodyO1267 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1267).trans bodyInactive0) (bodyBr1272.trans bodyBr1267.symm) bodyCnt1267 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA329 PRE_first_tail_x4_L9_r0_body.sizeArgsA329 PRE_first_tail_x4_L9_r0_body.sizeSymA329 PRE_first_tail_x4_L9_r0_body.sizeMlxA329 PRE_first_tail_x4_L9_r0_body.sizePayA329 PRE_first_tail_x4_L9_r0_body.sizeTaA329 PRE_first_tail_x4_L9_r0_body.sizeDecA329 PRE_first_tail_x4_L9_r0_body.sizePreA329 PRE_first_tail_x4_L9_r0_body.bodyPatchB329 (fun _ hm => bodyO1272 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1272).trans bodyInactive0) (bodyBr1273.trans bodyBr1272.symm) bodyCnt1272 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) bodyAcc1273 PRE_first_tail_x4_L9_r0_body.bodyRunSeg329 bodyAcc1274 bodyHalt1274 PRE_first_tail_x4_L9_r0_body.bodyStepA330 bodyTop1275 (fun _ hm => bodyO1273 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1273).trans bodyInactive0) (bodyBr1275.trans bodyBr1273.symm) bodyCnt1273 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA330 PRE_first_tail_x4_L9_r0_body.sizeArgsA330 PRE_first_tail_x4_L9_r0_body.sizeSymA330 PRE_first_tail_x4_L9_r0_body.sizeMlxA330 PRE_first_tail_x4_L9_r0_body.sizePayA330 PRE_first_tail_x4_L9_r0_body.sizeTaA330 PRE_first_tail_x4_L9_r0_body.sizeDecA330 PRE_first_tail_x4_L9_r0_body.sizePreA330 PRE_first_tail_x4_L9_r0_body.bodyPatchB330 (fun _ hm => bodyO1275 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1275).trans bodyInactive0) (bodyBr1276.trans bodyBr1275.symm) bodyCnt1275 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) bodyAcc1276 PRE_first_tail_x4_L9_r0_body.bodyRunSeg330 bodyAcc1277 bodyHalt1277 PRE_first_tail_x4_L9_r0_body.bodyStepA331 bodyTop1278 (fun _ hm => bodyO1276 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1276).trans bodyInactive0) (bodyBr1278.trans bodyBr1276.symm) bodyCnt1276 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA331 PRE_first_tail_x4_L9_r0_body.sizeArgsA331 PRE_first_tail_x4_L9_r0_body.sizeSymA331 PRE_first_tail_x4_L9_r0_body.sizeMlxA331 PRE_first_tail_x4_L9_r0_body.sizePayA331 PRE_first_tail_x4_L9_r0_body.sizeTaA331 PRE_first_tail_x4_L9_r0_body.sizeDecA331 PRE_first_tail_x4_L9_r0_body.sizePreA331 PRE_first_tail_x4_L9_r0_body.bodyPatchB331 (fun _ hm => bodyO1278 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1278).trans bodyInactive0) (bodyBr1279.trans bodyBr1278.symm) bodyCnt1278 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) bodyAcc1279 PRE_first_tail_x4_L9_r0_body.bodyRunSeg331 bodyAcc1280 bodyHalt1280 PRE_first_tail_x4_L9_r0_body.bodyStepA332 bodyTop1281 (fun _ hm => bodyO1279 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1279).trans bodyInactive0) (bodyBr1281.trans bodyBr1279.symm) bodyCnt1279 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA332 PRE_first_tail_x4_L9_r0_body.sizeArgsA332 PRE_first_tail_x4_L9_r0_body.sizeSymA332 PRE_first_tail_x4_L9_r0_body.sizeMlxA332 PRE_first_tail_x4_L9_r0_body.sizePayA332 PRE_first_tail_x4_L9_r0_body.sizeTaA332 PRE_first_tail_x4_L9_r0_body.sizeDecA332 PRE_first_tail_x4_L9_r0_body.sizePreA332 PRE_first_tail_x4_L9_r0_body.bodyPatchB332 (fun _ hm => bodyO1281 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1281).trans bodyInactive0) (bodyBr1282.trans bodyBr1281.symm) bodyCnt1281 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58421, 1124, 0, 0⟩) bodyAcc1282 PRE_first_tail_x4_L9_r0_body.bodyRunSeg332 bodyAcc1283 bodyHalt1283 PRE_first_tail_x4_L9_r0_body.bodyStepA333 bodyTop1284 (fun _ hm => bodyO1282 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1282).trans bodyInactive0) (bodyBr1284.trans bodyBr1282.symm) bodyCnt1282 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift57 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S1284.tab.length PRE_first_tail_x4_L9_r0_body.s1284.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P57.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P57 15 PRE_first_tail_x4_L9_r0_body.kappa57 PRE_first_tail_x4_L9_r0_body.s1286.ffi PRE_first_tail_x4_L9_r0_body.s1285.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_57
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_57
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1286.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S1284.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_57] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK57 PRE_first_tail_x4_L9_r0_body.cobjsK57
      PRE_first_tail_x4_L9_r0_body.citemsK57 PRE_first_tail_x4_L9_r0_body.cbd57 PRE_first_tail_x4_L9_r0_body.csst57
  exact PRE_first_tail_x4_L9_r0_body.cshift57 bodyNcl57 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_57] at this; exact this)


kernel_rfl bodyFramesEmpty57 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s1285 a).isEmpty) = true
kernel_rfl bodyJsRoots57 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1284.next) PRE_first_tail_x4_L9_r0_body.s1286.trace PRE_first_tail_x4_L9_r0_body.s1286 = true
kernel_rfl bodyJsNative57 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s1286.ffi) = true
kernel_rfl bodyLow57 : (PRE_first_tail_x4_L9_r0_body.cws57 ++ PRE_first_tail_x4_L9_r0_body.ws57).all (Nat.ble 9) = true
kernel_rfl bodyCntM57 : countersOkB PRE_first_tail_x4_L9_r0_body.s1284 PRE_first_tail_x4_L9_r0_body.s1285 = true
kernel_rfl bodyHi57 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1286.ffi).next setupP.E = true
kernel_rfl bodyNhi57 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1286.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge57 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1285.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s1284.ffi
kernel_rfl bodyNN57 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1284.ffi).nnext PRE_first_tail_x4_L9_r0_body.P57.NL = true
kernel_rfl bodyXn57 : Nat.ble (⟨21762, 18868, 2818015, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s1286.ffi).next = true
kernel_rfl bodyLo57 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s1286.ffi).next = true
theorem bodyFacts57 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s1284 PRE_first_tail_x4_L9_r0_body.s1285 PRE_first_tail_x4_L9_r0_body.s1286 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S1284 PRE_first_tail_x4_L9_r0_body.S1285 PRE_first_tail_x4_L9_r0_body.S1286
    PRE_first_tail_x4_L9_r0_body.ws57 PRE_first_tail_x4_L9_r0_body.cws57 PRE_first_tail_x4_L9_r0_body.nr57 PRE_first_tail_x4_L9_r0_body.pl57 PRE_first_tail_x4_L9_r0_body.cl57 2819164 15 PRE_first_tail_x4_L9_r0_body.kd57 PRE_first_tail_x4_L9_r0_body.kappa57 PRE_first_tail_x4_L9_r0_body.P57
    ⟨21759, 18841, 2818009, 15⟩ ⟨21762, 18868, 2818015, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap57
  clean := bodyClean57
  cfix := PRE_first_tail_x4_L9_r0_body.cfix57
  zpl := PRE_first_tail_x4_L9_r0_body.zpl57
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd57
  zn1 := PRE_first_tail_x4_L9_r0_body.zn157
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst57
  zscn := PRE_first_tail_x4_L9_r0_body.zscn57
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn57
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow57
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab57
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh57
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd57
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi57
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt57
  zgP := PRE_first_tail_x4_L9_r0_body.zg57_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk57_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm57_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg57_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk57_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm57_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw57_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw57_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap57
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd57
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap57 PRE_first_tail_x4_L9_r0_body.stFoot57 PRE_first_tail_x4_L9_r0_body.iso57 PRE_first_tail_x4_L9_r0_body.zwr57
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP57
  csupp := PRE_first_tail_x4_L9_r0_body.csupp57
  cbound := PRE_first_tail_x4_L9_r0_body.cbound57
  zimg := PRE_first_tail_x4_L9_r0_body.zimg57
  zctl := PRE_first_tail_x4_L9_r0_body.zctl57
  zstack := PRE_first_tail_x4_L9_r0_body.zstack57
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs57
  zstores := PRE_first_tail_x4_L9_r0_body.zstores57
  zroots := PRE_first_tail_x4_L9_r0_body.zroots57
  znC := PRE_first_tail_x4_L9_r0_body.znC57
  ctab := PRE_first_tail_x4_L9_r0_body.ctab57
  zbin := PRE_first_tail_x4_L9_r0_body.zbin57
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge57
  sbridge := bodyBridge57
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj57
  cshiftR := fun h hNL => bodyCshift57 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN57
  raised := PRE_first_tail_x4_L9_r0_body.raised57
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs57
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl57
  xnLe := Nat.le_of_ble_eq_true bodyXn57
  loLe := Nat.le_of_ble_eq_true bodyLo57
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB57
  cntM := bodyCntM57
  hiLe := Nat.le_of_ble_eq_true bodyHi57
  nhiLe := Nat.le_of_ble_eq_true bodyNhi57
  jsHeap := bodyJs57
  jsRoots := bodyJsRoots57
  jsNative := bodyJsNative57
  framesEmpty := bodyFramesEmpty57
  trailOld := by decide
  lowVars := bodyLow57

def bodyQs57 : List (Option Q) := []
noncomputable def bodyEs57 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr57.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st57.S5.tab r
kernel_rfl bodyResChk57 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs57 bodyQs57) = true
kernel_rfl bodyLq57 : bodyQs57.length = PRE_first_tail_x4_L9_r0_body.cws57.length
kernel_rfl bodyNrLo57 : PRE_first_tail_x4_L9_r0_body.nr57.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S1284.tab.length) = true
kernel_rfl bodySub57 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site57.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost57 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws57 PRE_first_tail_x4_L9_r0_body.cws57 bodyQs57 = true
kernel_rfl bodyDrop57 : Nat.ble (58421 + (PRE_first_tail_x4_L9_r0_body.s1285.next - PRE_first_tail_x4_L9_r0_body.s1286.next)) 59570 = true
kernel_rfl bodyDropH57 : Nat.ble (1124 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1285.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s1286.ffi).next)) 1149 = true
kernel_rfl bodyDropN57 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1285.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s1286.ffi).nnext)) 0 = true
kernel_rfl bodyDv57 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws57
kernel_rfl bodyDe57 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr57.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st57.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl57 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold57 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws57).isNone && !PRE_first_tail_x4_L9_r0_body.ws57.contains v) = true
kernel_rfl bodyDfree57 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws57 ++ PRE_first_tail_x4_L9_r0_body.ws57).all fun w => e.noVar w) = true

theorem bodyStep57 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨58421, 1124, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1284 PRE_first_tail_x4_L9_r0_body.S1284)
      (bodyCut NB T tk π i x0 bodyΘ ⟨59570, 1149, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1286 PRE_first_tail_x4_L9_r0_body.S1286) (11334 + 1) :=
  bodySite bodyFacts57.cfix bodyFacts57.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st57.S5.tab) (Es := bodyEs57) (qs := bodyQs57)
    (ok := PRE_first_tail_x4_L9_r0_body.st57.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site57 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts57
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site57 r hr) hi (MapOk.sub hm (sub_of_all bodySub57)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk57 r hr) hi hm ho hq)
    bodyLq57 rfl bodyNrLo57 (postSub_sound bodyPost57)
    (Nat.le_of_ble_eq_true bodyDrop57) (by decide) (Nat.le_of_ble_eq_true bodyDropH57) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN57) (by decide)
    bodyDv57 bodyDe57 bodyDl57 bodyDold57 bodyDfree57 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site58 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site58 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site58) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st58.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site58
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st58.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st58.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1306 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1307 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1306 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws58 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st58.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st58.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso58
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_58
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st58.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot58
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup58
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound58
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace58
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged58
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws58.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st58.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1306.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_58]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen58.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh58
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl58 : Conv.NClean (⟨21816, 18904, 2820251, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1306.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl58 (PRE_first_tail_x4_L9_r0_body.cncl57 bodyNcl57)

theorem bodyClean58 : Conv.JClean (⟨21816, 18904, 2820251, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s1306 :=
  PRE_first_tail_x4_L9_r0_body.gjcl58 (PRE_first_tail_x4_L9_r0_body.cjcl57 bodyClean57)

kernel_rfl bodyJsLe58 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1284.next PRE_first_tail_x4_L9_r0_body.s1306.next = true
kernel_rfl bodyJsList58 : (PRE_first_tail_x4_L9_r0_body.gjh58 ++ PRE_first_tail_x4_L9_r0_body.cl58).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1306.next) PRE_first_tail_x4_L9_r0_body.s1308) = true
theorem bodyJs58 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s1306.next PRE_first_tail_x4_L9_r0_body.s1308 :=
  JsHeapAbove.glueSite bodyJs57 (Nat.le_of_ble_eq_true bodyJsLe58) PRE_first_tail_x4_L9_r0_body.gjk58 PRE_first_tail_x4_L9_r0_body.gjbd58 PRE_first_tail_x4_L9_r0_body.cheap58 PRE_first_tail_x4_L9_r0_body.zclbd58 bodyJsList58

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1286 : PRE_first_tail_x4_L9_r0_body.S1286.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1286.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1286 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1286.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1286 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1286 PRE_first_tail_x4_L9_r0_body.S1286) = fun _ _ => true
kernel_rfl bodyAcc1287 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1287 PRE_first_tail_x4_L9_r0_body.S1287) = fun _ _ => true
kernel_rfl bodyBr1288 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1288.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1287 : isHalt PRE_first_tail_x4_L9_r0_body.s1287.ctl = false
kernel_rfl bodyTop1288 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1288 = true
kernel_rfl bodyCnt1286 : countersOkB PRE_first_tail_x4_L9_r0_body.s1286 PRE_first_tail_x4_L9_r0_body.s1288 = true
kernel_rfl bodyO1288 : PRE_first_tail_x4_L9_r0_body.S1288.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1288.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1289 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1289.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1288 : countersOkB PRE_first_tail_x4_L9_r0_body.s1288 PRE_first_tail_x4_L9_r0_body.s1289 = true
kernel_rfl bodyO1289 : PRE_first_tail_x4_L9_r0_body.S1289.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1289.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1289 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1289 PRE_first_tail_x4_L9_r0_body.S1289) = fun _ _ => true
kernel_rfl bodyAcc1293 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1293 PRE_first_tail_x4_L9_r0_body.S1293) = fun _ _ => true
kernel_rfl bodyBr1294 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1294.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1293 : isHalt PRE_first_tail_x4_L9_r0_body.s1293.ctl = false
kernel_rfl bodyTop1294 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1294 = true
kernel_rfl bodyCnt1289 : countersOkB PRE_first_tail_x4_L9_r0_body.s1289 PRE_first_tail_x4_L9_r0_body.s1294 = true
kernel_rfl bodyO1294 : PRE_first_tail_x4_L9_r0_body.S1294.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1294.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1295 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1295.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1294 : countersOkB PRE_first_tail_x4_L9_r0_body.s1294 PRE_first_tail_x4_L9_r0_body.s1295 = true
kernel_rfl bodyO1295 : PRE_first_tail_x4_L9_r0_body.S1295.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1295.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1295 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1295 PRE_first_tail_x4_L9_r0_body.S1295) = fun _ _ => true
kernel_rfl bodyAcc1296 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1296 PRE_first_tail_x4_L9_r0_body.S1296) = fun _ _ => true
kernel_rfl bodyBr1297 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1297.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1296 : isHalt PRE_first_tail_x4_L9_r0_body.s1296.ctl = false
kernel_rfl bodyTop1297 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1297 = true
kernel_rfl bodyCnt1295 : countersOkB PRE_first_tail_x4_L9_r0_body.s1295 PRE_first_tail_x4_L9_r0_body.s1297 = true
kernel_rfl bodyO1297 : PRE_first_tail_x4_L9_r0_body.S1297.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1297.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1298 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1298.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1297 : countersOkB PRE_first_tail_x4_L9_r0_body.s1297 PRE_first_tail_x4_L9_r0_body.s1298 = true
kernel_rfl bodyO1298 : PRE_first_tail_x4_L9_r0_body.S1298.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1298.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1298 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1298 PRE_first_tail_x4_L9_r0_body.S1298) = fun _ _ => true
kernel_rfl bodyAcc1299 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1299 PRE_first_tail_x4_L9_r0_body.S1299) = fun _ _ => true
kernel_rfl bodyBr1300 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1300.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1299 : isHalt PRE_first_tail_x4_L9_r0_body.s1299.ctl = false
kernel_rfl bodyTop1300 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1300 = true
kernel_rfl bodyCnt1298 : countersOkB PRE_first_tail_x4_L9_r0_body.s1298 PRE_first_tail_x4_L9_r0_body.s1300 = true
kernel_rfl bodyO1300 : PRE_first_tail_x4_L9_r0_body.S1300.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1300.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1301 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1301.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1300 : countersOkB PRE_first_tail_x4_L9_r0_body.s1300 PRE_first_tail_x4_L9_r0_body.s1301 = true
kernel_rfl bodyO1301 : PRE_first_tail_x4_L9_r0_body.S1301.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1301.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1301 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1301 PRE_first_tail_x4_L9_r0_body.S1301) = fun _ _ => true
kernel_rfl bodyAcc1302 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1302 PRE_first_tail_x4_L9_r0_body.S1302) = fun _ _ => true
kernel_rfl bodyBr1303 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1303.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1302 : isHalt PRE_first_tail_x4_L9_r0_body.s1302.ctl = false
kernel_rfl bodyTop1303 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1303 = true
kernel_rfl bodyCnt1301 : countersOkB PRE_first_tail_x4_L9_r0_body.s1301 PRE_first_tail_x4_L9_r0_body.s1303 = true
kernel_rfl bodyO1303 : PRE_first_tail_x4_L9_r0_body.S1303.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1303.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1304 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1304.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1303 : countersOkB PRE_first_tail_x4_L9_r0_body.s1303 PRE_first_tail_x4_L9_r0_body.s1304 = true
kernel_rfl bodyO1304 : PRE_first_tail_x4_L9_r0_body.S1304.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1304.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1304 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1304 PRE_first_tail_x4_L9_r0_body.S1304) = fun _ _ => true
kernel_rfl bodyAcc1305 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1305 PRE_first_tail_x4_L9_r0_body.S1305) = fun _ _ => true
kernel_rfl bodyBr1306 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1306.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1305 : isHalt PRE_first_tail_x4_L9_r0_body.s1305.ctl = false
kernel_rfl bodyTop1306 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1306 = true
kernel_rfl bodyCnt1304 : countersOkB PRE_first_tail_x4_L9_r0_body.s1304 PRE_first_tail_x4_L9_r0_body.s1306 = true

theorem bodyGlue58 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨59570, 1149, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1286 PRE_first_tail_x4_L9_r0_body.S1286)
      (bodyCut NB T tk π i x0 bodyΘ ⟨59570, 1149, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1306 PRE_first_tail_x4_L9_r0_body.S1306) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) bodyAcc1286 PRE_first_tail_x4_L9_r0_body.bodyRunSeg333 bodyAcc1287 bodyHalt1287 PRE_first_tail_x4_L9_r0_body.bodyStepA334 bodyTop1288 (fun _ hm => bodyO1286 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1286).trans bodyInactive0) (bodyBr1288.trans bodyBr1286.symm) bodyCnt1286 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA334 PRE_first_tail_x4_L9_r0_body.sizeArgsA334 PRE_first_tail_x4_L9_r0_body.sizeSymA334 PRE_first_tail_x4_L9_r0_body.sizeMlxA334 PRE_first_tail_x4_L9_r0_body.sizePayA334 PRE_first_tail_x4_L9_r0_body.sizeTaA334 PRE_first_tail_x4_L9_r0_body.sizeDecA334 PRE_first_tail_x4_L9_r0_body.sizePreA334 PRE_first_tail_x4_L9_r0_body.bodyPatchB334 (fun _ hm => bodyO1288 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1288).trans bodyInactive0) (bodyBr1289.trans bodyBr1288.symm) bodyCnt1288 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) bodyAcc1289 PRE_first_tail_x4_L9_r0_body.bodyRunSeg334 bodyAcc1293 bodyHalt1293 PRE_first_tail_x4_L9_r0_body.bodyStepA335 bodyTop1294 (fun _ hm => bodyO1289 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1289).trans bodyInactive0) (bodyBr1294.trans bodyBr1289.symm) bodyCnt1289 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA335 PRE_first_tail_x4_L9_r0_body.sizeArgsA335 PRE_first_tail_x4_L9_r0_body.sizeSymA335 PRE_first_tail_x4_L9_r0_body.sizeMlxA335 PRE_first_tail_x4_L9_r0_body.sizePayA335 PRE_first_tail_x4_L9_r0_body.sizeTaA335 PRE_first_tail_x4_L9_r0_body.sizeDecA335 PRE_first_tail_x4_L9_r0_body.sizePreA335 PRE_first_tail_x4_L9_r0_body.bodyPatchB335 (fun _ hm => bodyO1294 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1294).trans bodyInactive0) (bodyBr1295.trans bodyBr1294.symm) bodyCnt1294 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) bodyAcc1295 PRE_first_tail_x4_L9_r0_body.bodyRunSeg335 bodyAcc1296 bodyHalt1296 PRE_first_tail_x4_L9_r0_body.bodyStepA336 bodyTop1297 (fun _ hm => bodyO1295 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1295).trans bodyInactive0) (bodyBr1297.trans bodyBr1295.symm) bodyCnt1295 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA336 PRE_first_tail_x4_L9_r0_body.sizeArgsA336 PRE_first_tail_x4_L9_r0_body.sizeSymA336 PRE_first_tail_x4_L9_r0_body.sizeMlxA336 PRE_first_tail_x4_L9_r0_body.sizePayA336 PRE_first_tail_x4_L9_r0_body.sizeTaA336 PRE_first_tail_x4_L9_r0_body.sizeDecA336 PRE_first_tail_x4_L9_r0_body.sizePreA336 PRE_first_tail_x4_L9_r0_body.bodyPatchB336 (fun _ hm => bodyO1297 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1297).trans bodyInactive0) (bodyBr1298.trans bodyBr1297.symm) bodyCnt1297 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) bodyAcc1298 PRE_first_tail_x4_L9_r0_body.bodyRunSeg336 bodyAcc1299 bodyHalt1299 PRE_first_tail_x4_L9_r0_body.bodyStepA337 bodyTop1300 (fun _ hm => bodyO1298 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1298).trans bodyInactive0) (bodyBr1300.trans bodyBr1298.symm) bodyCnt1298 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA337 PRE_first_tail_x4_L9_r0_body.sizeArgsA337 PRE_first_tail_x4_L9_r0_body.sizeSymA337 PRE_first_tail_x4_L9_r0_body.sizeMlxA337 PRE_first_tail_x4_L9_r0_body.sizePayA337 PRE_first_tail_x4_L9_r0_body.sizeTaA337 PRE_first_tail_x4_L9_r0_body.sizeDecA337 PRE_first_tail_x4_L9_r0_body.sizePreA337 PRE_first_tail_x4_L9_r0_body.bodyPatchB337 (fun _ hm => bodyO1300 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1300).trans bodyInactive0) (bodyBr1301.trans bodyBr1300.symm) bodyCnt1300 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) bodyAcc1301 PRE_first_tail_x4_L9_r0_body.bodyRunSeg337 bodyAcc1302 bodyHalt1302 PRE_first_tail_x4_L9_r0_body.bodyStepA338 bodyTop1303 (fun _ hm => bodyO1301 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1301).trans bodyInactive0) (bodyBr1303.trans bodyBr1301.symm) bodyCnt1301 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA338 PRE_first_tail_x4_L9_r0_body.sizeArgsA338 PRE_first_tail_x4_L9_r0_body.sizeSymA338 PRE_first_tail_x4_L9_r0_body.sizeMlxA338 PRE_first_tail_x4_L9_r0_body.sizePayA338 PRE_first_tail_x4_L9_r0_body.sizeTaA338 PRE_first_tail_x4_L9_r0_body.sizeDecA338 PRE_first_tail_x4_L9_r0_body.sizePreA338 PRE_first_tail_x4_L9_r0_body.bodyPatchB338 (fun _ hm => bodyO1303 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1303).trans bodyInactive0) (bodyBr1304.trans bodyBr1303.symm) bodyCnt1303 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59570, 1149, 0, 0⟩) bodyAcc1304 PRE_first_tail_x4_L9_r0_body.bodyRunSeg338 bodyAcc1305 bodyHalt1305 PRE_first_tail_x4_L9_r0_body.bodyStepA339 bodyTop1306 (fun _ hm => bodyO1304 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1304).trans bodyInactive0) (bodyBr1306.trans bodyBr1304.symm) bodyCnt1304 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift58 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S1306.tab.length PRE_first_tail_x4_L9_r0_body.s1306.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P58.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P58 15 PRE_first_tail_x4_L9_r0_body.kappa58 PRE_first_tail_x4_L9_r0_body.s1308.ffi PRE_first_tail_x4_L9_r0_body.s1307.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_58
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_58
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1308.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S1306.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_58] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK58 PRE_first_tail_x4_L9_r0_body.cobjsK58
      PRE_first_tail_x4_L9_r0_body.citemsK58 PRE_first_tail_x4_L9_r0_body.cbd58 PRE_first_tail_x4_L9_r0_body.csst58
  exact PRE_first_tail_x4_L9_r0_body.cshift58 bodyNcl58 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_58] at this; exact this)


kernel_rfl bodyFramesEmpty58 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s1307 a).isEmpty) = true
kernel_rfl bodyJsRoots58 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1306.next) PRE_first_tail_x4_L9_r0_body.s1308.trace PRE_first_tail_x4_L9_r0_body.s1308 = true
kernel_rfl bodyJsNative58 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s1308.ffi) = true
kernel_rfl bodyLow58 : (PRE_first_tail_x4_L9_r0_body.cws58 ++ PRE_first_tail_x4_L9_r0_body.ws58).all (Nat.ble 9) = true
kernel_rfl bodyCntM58 : countersOkB PRE_first_tail_x4_L9_r0_body.s1306 PRE_first_tail_x4_L9_r0_body.s1307 = true
kernel_rfl bodyHi58 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1308.ffi).next setupP.E = true
kernel_rfl bodyNhi58 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1308.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge58 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1307.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s1306.ffi
kernel_rfl bodyNN58 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1306.ffi).nnext PRE_first_tail_x4_L9_r0_body.P58.NL = true
kernel_rfl bodyXn58 : Nat.ble (⟨21819, 18931, 2820257, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s1308.ffi).next = true
kernel_rfl bodyLo58 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s1308.ffi).next = true
theorem bodyFacts58 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s1306 PRE_first_tail_x4_L9_r0_body.s1307 PRE_first_tail_x4_L9_r0_body.s1308 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S1306 PRE_first_tail_x4_L9_r0_body.S1307 PRE_first_tail_x4_L9_r0_body.S1308
    PRE_first_tail_x4_L9_r0_body.ws58 PRE_first_tail_x4_L9_r0_body.cws58 PRE_first_tail_x4_L9_r0_body.nr58 PRE_first_tail_x4_L9_r0_body.pl58 PRE_first_tail_x4_L9_r0_body.cl58 2821406 15 PRE_first_tail_x4_L9_r0_body.kd58 PRE_first_tail_x4_L9_r0_body.kappa58 PRE_first_tail_x4_L9_r0_body.P58
    ⟨21816, 18904, 2820251, 15⟩ ⟨21819, 18931, 2820257, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap58
  clean := bodyClean58
  cfix := PRE_first_tail_x4_L9_r0_body.cfix58
  zpl := PRE_first_tail_x4_L9_r0_body.zpl58
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd58
  zn1 := PRE_first_tail_x4_L9_r0_body.zn158
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst58
  zscn := PRE_first_tail_x4_L9_r0_body.zscn58
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn58
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow58
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab58
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh58
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd58
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi58
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt58
  zgP := PRE_first_tail_x4_L9_r0_body.zg58_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk58_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm58_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg58_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk58_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm58_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw58_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw58_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap58
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd58
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap58 PRE_first_tail_x4_L9_r0_body.stFoot58 PRE_first_tail_x4_L9_r0_body.iso58 PRE_first_tail_x4_L9_r0_body.zwr58
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP58
  csupp := PRE_first_tail_x4_L9_r0_body.csupp58
  cbound := PRE_first_tail_x4_L9_r0_body.cbound58
  zimg := PRE_first_tail_x4_L9_r0_body.zimg58
  zctl := PRE_first_tail_x4_L9_r0_body.zctl58
  zstack := PRE_first_tail_x4_L9_r0_body.zstack58
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs58
  zstores := PRE_first_tail_x4_L9_r0_body.zstores58
  zroots := PRE_first_tail_x4_L9_r0_body.zroots58
  znC := PRE_first_tail_x4_L9_r0_body.znC58
  ctab := PRE_first_tail_x4_L9_r0_body.ctab58
  zbin := PRE_first_tail_x4_L9_r0_body.zbin58
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge58
  sbridge := bodyBridge58
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj58
  cshiftR := fun h hNL => bodyCshift58 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN58
  raised := PRE_first_tail_x4_L9_r0_body.raised58
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs58
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl58
  xnLe := Nat.le_of_ble_eq_true bodyXn58
  loLe := Nat.le_of_ble_eq_true bodyLo58
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB58
  cntM := bodyCntM58
  hiLe := Nat.le_of_ble_eq_true bodyHi58
  nhiLe := Nat.le_of_ble_eq_true bodyNhi58
  jsHeap := bodyJs58
  jsRoots := bodyJsRoots58
  jsNative := bodyJsNative58
  framesEmpty := bodyFramesEmpty58
  trailOld := by decide
  lowVars := bodyLow58

def bodyQs58 : List (Option Q) := []
noncomputable def bodyEs58 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr58.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st58.S5.tab r
kernel_rfl bodyResChk58 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs58 bodyQs58) = true
kernel_rfl bodyLq58 : bodyQs58.length = PRE_first_tail_x4_L9_r0_body.cws58.length
kernel_rfl bodyNrLo58 : PRE_first_tail_x4_L9_r0_body.nr58.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S1306.tab.length) = true
kernel_rfl bodySub58 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site58.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost58 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws58 PRE_first_tail_x4_L9_r0_body.cws58 bodyQs58 = true
kernel_rfl bodyDrop58 : Nat.ble (59570 + (PRE_first_tail_x4_L9_r0_body.s1307.next - PRE_first_tail_x4_L9_r0_body.s1308.next)) 60719 = true
kernel_rfl bodyDropH58 : Nat.ble (1149 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1307.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s1308.ffi).next)) 1174 = true
kernel_rfl bodyDropN58 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1307.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s1308.ffi).nnext)) 0 = true
kernel_rfl bodyDv58 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws58
kernel_rfl bodyDe58 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr58.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st58.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl58 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold58 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws58).isNone && !PRE_first_tail_x4_L9_r0_body.ws58.contains v) = true
kernel_rfl bodyDfree58 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws58 ++ PRE_first_tail_x4_L9_r0_body.ws58).all fun w => e.noVar w) = true

theorem bodyStep58 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨59570, 1149, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1306 PRE_first_tail_x4_L9_r0_body.S1306)
      (bodyCut NB T tk π i x0 bodyΘ ⟨60719, 1174, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1308 PRE_first_tail_x4_L9_r0_body.S1308) (11334 + 1) :=
  bodySite bodyFacts58.cfix bodyFacts58.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st58.S5.tab) (Es := bodyEs58) (qs := bodyQs58)
    (ok := PRE_first_tail_x4_L9_r0_body.st58.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site58 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts58
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site58 r hr) hi (MapOk.sub hm (sub_of_all bodySub58)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk58 r hr) hi hm ho hq)
    bodyLq58 rfl bodyNrLo58 (postSub_sound bodyPost58)
    (Nat.le_of_ble_eq_true bodyDrop58) (by decide) (Nat.le_of_ble_eq_true bodyDropH58) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN58) (by decide)
    bodyDv58 bodyDe58 bodyDl58 bodyDold58 bodyDfree58 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site59 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site59 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site59) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st59.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site59
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st59.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st59.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1327 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1328 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1327 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws59 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st59.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st59.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso59
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_59
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st59.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot59
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup59
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound59
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace59
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged59
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws59.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st59.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1327.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_59]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen59.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh59
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl59 : Conv.NClean (⟨21879, 18976, 2822758, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1327.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl59 (PRE_first_tail_x4_L9_r0_body.cncl58 bodyNcl58)

theorem bodyClean59 : Conv.JClean (⟨21879, 18976, 2822758, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s1327 :=
  PRE_first_tail_x4_L9_r0_body.gjcl59 (PRE_first_tail_x4_L9_r0_body.cjcl58 bodyClean58)

kernel_rfl bodyJsLe59 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1306.next PRE_first_tail_x4_L9_r0_body.s1327.next = true
kernel_rfl bodyJsList59 : (PRE_first_tail_x4_L9_r0_body.gjh59 ++ PRE_first_tail_x4_L9_r0_body.cl59).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1327.next) PRE_first_tail_x4_L9_r0_body.s1329) = true
theorem bodyJs59 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s1327.next PRE_first_tail_x4_L9_r0_body.s1329 :=
  JsHeapAbove.glueSite bodyJs58 (Nat.le_of_ble_eq_true bodyJsLe59) PRE_first_tail_x4_L9_r0_body.gjk59 PRE_first_tail_x4_L9_r0_body.gjbd59 PRE_first_tail_x4_L9_r0_body.cheap59 PRE_first_tail_x4_L9_r0_body.zclbd59 bodyJsList59

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1308 : PRE_first_tail_x4_L9_r0_body.S1308.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1308.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1308 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1308.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1308 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1308 PRE_first_tail_x4_L9_r0_body.S1308) = fun _ _ => true
kernel_rfl bodyAcc1309 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1309 PRE_first_tail_x4_L9_r0_body.S1309) = fun _ _ => true
kernel_rfl bodyBr1310 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1310.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1309 : isHalt PRE_first_tail_x4_L9_r0_body.s1309.ctl = false
kernel_rfl bodyTop1310 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1310 = true
kernel_rfl bodyCnt1308 : countersOkB PRE_first_tail_x4_L9_r0_body.s1308 PRE_first_tail_x4_L9_r0_body.s1310 = true
kernel_rfl bodyO1310 : PRE_first_tail_x4_L9_r0_body.S1310.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1310.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1311 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1311.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1310 : countersOkB PRE_first_tail_x4_L9_r0_body.s1310 PRE_first_tail_x4_L9_r0_body.s1311 = true
kernel_rfl bodyO1311 : PRE_first_tail_x4_L9_r0_body.S1311.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1311.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1311 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1311 PRE_first_tail_x4_L9_r0_body.S1311) = fun _ _ => true
kernel_rfl bodyAcc1315 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1315 PRE_first_tail_x4_L9_r0_body.S1315) = fun _ _ => true
kernel_rfl bodyBr1316 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1316.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1315 : isHalt PRE_first_tail_x4_L9_r0_body.s1315.ctl = false
kernel_rfl bodyTop1316 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1316 = true
kernel_rfl bodyCnt1311 : countersOkB PRE_first_tail_x4_L9_r0_body.s1311 PRE_first_tail_x4_L9_r0_body.s1316 = true
kernel_rfl bodyO1316 : PRE_first_tail_x4_L9_r0_body.S1316.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1316.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1317 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1317.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1316 : countersOkB PRE_first_tail_x4_L9_r0_body.s1316 PRE_first_tail_x4_L9_r0_body.s1317 = true
kernel_rfl bodyO1317 : PRE_first_tail_x4_L9_r0_body.S1317.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1317.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1317 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1317 PRE_first_tail_x4_L9_r0_body.S1317) = fun _ _ => true
kernel_rfl bodyAcc1319 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1319 PRE_first_tail_x4_L9_r0_body.S1319) = fun _ _ => true
kernel_rfl bodyBr1320 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1320.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1319 : isHalt PRE_first_tail_x4_L9_r0_body.s1319.ctl = false
kernel_rfl bodyTop1320 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1320 = true
kernel_rfl bodyCnt1317 : countersOkB PRE_first_tail_x4_L9_r0_body.s1317 PRE_first_tail_x4_L9_r0_body.s1320 = true
kernel_rfl bodyO1320 : PRE_first_tail_x4_L9_r0_body.S1320.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1320.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1321 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1321.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1320 : countersOkB PRE_first_tail_x4_L9_r0_body.s1320 PRE_first_tail_x4_L9_r0_body.s1321 = true
kernel_rfl bodyO1321 : PRE_first_tail_x4_L9_r0_body.S1321.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1321.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1321 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1321 PRE_first_tail_x4_L9_r0_body.S1321) = fun _ _ => true
kernel_rfl bodyAcc1322 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1322 PRE_first_tail_x4_L9_r0_body.S1322) = fun _ _ => true
kernel_rfl bodyBr1323 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1323.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1322 : isHalt PRE_first_tail_x4_L9_r0_body.s1322.ctl = false
kernel_rfl bodyTop1323 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1323 = true
kernel_rfl bodyCnt1321 : countersOkB PRE_first_tail_x4_L9_r0_body.s1321 PRE_first_tail_x4_L9_r0_body.s1323 = true
kernel_rfl bodyO1323 : PRE_first_tail_x4_L9_r0_body.S1323.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1323.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1324 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1324.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1323 : countersOkB PRE_first_tail_x4_L9_r0_body.s1323 PRE_first_tail_x4_L9_r0_body.s1324 = true
kernel_rfl bodyO1324 : PRE_first_tail_x4_L9_r0_body.S1324.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1324.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1324 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1324 PRE_first_tail_x4_L9_r0_body.S1324) = fun _ _ => true
kernel_rfl bodyAcc1326 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1326 PRE_first_tail_x4_L9_r0_body.S1326) = fun _ _ => true
kernel_rfl bodyBr1327 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1327.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1326 : isHalt PRE_first_tail_x4_L9_r0_body.s1326.ctl = false
kernel_rfl bodyTop1327 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1327 = true
kernel_rfl bodyCnt1324 : countersOkB PRE_first_tail_x4_L9_r0_body.s1324 PRE_first_tail_x4_L9_r0_body.s1327 = true

theorem bodyGlue59 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨60719, 1174, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1308 PRE_first_tail_x4_L9_r0_body.S1308)
      (bodyCut NB T tk π i x0 bodyΘ ⟨60719, 1174, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1327 PRE_first_tail_x4_L9_r0_body.S1327) 24727 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) bodyAcc1308 PRE_first_tail_x4_L9_r0_body.bodyRunSeg339 bodyAcc1309 bodyHalt1309 PRE_first_tail_x4_L9_r0_body.bodyStepA340 bodyTop1310 (fun _ hm => bodyO1308 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1308).trans bodyInactive0) (bodyBr1310.trans bodyBr1308.symm) bodyCnt1308 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA340 PRE_first_tail_x4_L9_r0_body.sizeArgsA340 PRE_first_tail_x4_L9_r0_body.sizeSymA340 PRE_first_tail_x4_L9_r0_body.sizeMlxA340 PRE_first_tail_x4_L9_r0_body.sizePayA340 PRE_first_tail_x4_L9_r0_body.sizeTaA340 PRE_first_tail_x4_L9_r0_body.sizeDecA340 PRE_first_tail_x4_L9_r0_body.sizePreA340 PRE_first_tail_x4_L9_r0_body.bodyPatchB340 (fun _ hm => bodyO1310 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1310).trans bodyInactive0) (bodyBr1311.trans bodyBr1310.symm) bodyCnt1310 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) bodyAcc1311 PRE_first_tail_x4_L9_r0_body.bodyRunSeg340 bodyAcc1315 bodyHalt1315 PRE_first_tail_x4_L9_r0_body.bodyStepA341 bodyTop1316 (fun _ hm => bodyO1311 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1311).trans bodyInactive0) (bodyBr1316.trans bodyBr1311.symm) bodyCnt1311 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA341 PRE_first_tail_x4_L9_r0_body.sizeArgsA341 PRE_first_tail_x4_L9_r0_body.sizeSymA341 PRE_first_tail_x4_L9_r0_body.sizeMlxA341 PRE_first_tail_x4_L9_r0_body.sizePayA341 PRE_first_tail_x4_L9_r0_body.sizeTaA341 PRE_first_tail_x4_L9_r0_body.sizeDecA341 PRE_first_tail_x4_L9_r0_body.sizePreA341 PRE_first_tail_x4_L9_r0_body.bodyPatchB341 (fun _ hm => bodyO1316 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1316).trans bodyInactive0) (bodyBr1317.trans bodyBr1316.symm) bodyCnt1316 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) bodyAcc1317 PRE_first_tail_x4_L9_r0_body.bodyRunSeg341 bodyAcc1319 bodyHalt1319 PRE_first_tail_x4_L9_r0_body.bodyStepA342 bodyTop1320 (fun _ hm => bodyO1317 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1317).trans bodyInactive0) (bodyBr1320.trans bodyBr1317.symm) bodyCnt1317 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA342 PRE_first_tail_x4_L9_r0_body.sizeArgsA342 PRE_first_tail_x4_L9_r0_body.sizeSymA342 PRE_first_tail_x4_L9_r0_body.sizeMlxA342 PRE_first_tail_x4_L9_r0_body.sizePayA342 PRE_first_tail_x4_L9_r0_body.sizeTaA342 PRE_first_tail_x4_L9_r0_body.sizeDecA342 PRE_first_tail_x4_L9_r0_body.sizePreA342 PRE_first_tail_x4_L9_r0_body.bodyPatchB342 (fun _ hm => bodyO1320 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1320).trans bodyInactive0) (bodyBr1321.trans bodyBr1320.symm) bodyCnt1320 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) bodyAcc1321 PRE_first_tail_x4_L9_r0_body.bodyRunSeg342 bodyAcc1322 bodyHalt1322 PRE_first_tail_x4_L9_r0_body.bodyStepA343 bodyTop1323 (fun _ hm => bodyO1321 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1321).trans bodyInactive0) (bodyBr1323.trans bodyBr1321.symm) bodyCnt1321 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA343 PRE_first_tail_x4_L9_r0_body.sizeArgsA343 PRE_first_tail_x4_L9_r0_body.sizeSymA343 PRE_first_tail_x4_L9_r0_body.sizeMlxA343 PRE_first_tail_x4_L9_r0_body.sizePayA343 PRE_first_tail_x4_L9_r0_body.sizeTaA343 PRE_first_tail_x4_L9_r0_body.sizeDecA343 PRE_first_tail_x4_L9_r0_body.sizePreA343 PRE_first_tail_x4_L9_r0_body.bodyPatchB343 (fun _ hm => bodyO1323 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1323).trans bodyInactive0) (bodyBr1324.trans bodyBr1323.symm) bodyCnt1323 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60719, 1174, 0, 0⟩) bodyAcc1324 PRE_first_tail_x4_L9_r0_body.bodyRunSeg343 bodyAcc1326 bodyHalt1326 PRE_first_tail_x4_L9_r0_body.bodyStepA344 bodyTop1327 (fun _ hm => bodyO1324 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1324).trans bodyInactive0) (bodyBr1327.trans bodyBr1324.symm) bodyCnt1324 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift59 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S1327.tab.length PRE_first_tail_x4_L9_r0_body.s1327.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P59.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P59 15 PRE_first_tail_x4_L9_r0_body.kappa59 PRE_first_tail_x4_L9_r0_body.s1329.ffi PRE_first_tail_x4_L9_r0_body.s1328.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_59
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_59
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1329.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S1327.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_59] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK59 PRE_first_tail_x4_L9_r0_body.cobjsK59
      PRE_first_tail_x4_L9_r0_body.citemsK59 PRE_first_tail_x4_L9_r0_body.cbd59 PRE_first_tail_x4_L9_r0_body.csst59
  exact PRE_first_tail_x4_L9_r0_body.cshift59 bodyNcl59 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_59] at this; exact this)


kernel_rfl bodyFramesEmpty59 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s1328 a).isEmpty) = true
kernel_rfl bodyJsRoots59 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1327.next) PRE_first_tail_x4_L9_r0_body.s1329.trace PRE_first_tail_x4_L9_r0_body.s1329 = true
kernel_rfl bodyJsNative59 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s1329.ffi) = true
kernel_rfl bodyLow59 : (PRE_first_tail_x4_L9_r0_body.cws59 ++ PRE_first_tail_x4_L9_r0_body.ws59).all (Nat.ble 9) = true
kernel_rfl bodyCntM59 : countersOkB PRE_first_tail_x4_L9_r0_body.s1327 PRE_first_tail_x4_L9_r0_body.s1328 = true
kernel_rfl bodyHi59 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1329.ffi).next setupP.E = true
kernel_rfl bodyNhi59 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1329.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge59 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1328.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s1327.ffi
kernel_rfl bodyNN59 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1327.ffi).nnext PRE_first_tail_x4_L9_r0_body.P59.NL = true
kernel_rfl bodyXn59 : Nat.ble (⟨21883, 18982, 2822773, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s1329.ffi).next = true
kernel_rfl bodyLo59 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s1329.ffi).next = true
theorem bodyFacts59 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s1327 PRE_first_tail_x4_L9_r0_body.s1328 PRE_first_tail_x4_L9_r0_body.s1329 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S1327 PRE_first_tail_x4_L9_r0_body.S1328 PRE_first_tail_x4_L9_r0_body.S1329
    PRE_first_tail_x4_L9_r0_body.ws59 PRE_first_tail_x4_L9_r0_body.cws59 PRE_first_tail_x4_L9_r0_body.nr59 PRE_first_tail_x4_L9_r0_body.pl59 PRE_first_tail_x4_L9_r0_body.cl59 2823123 15 PRE_first_tail_x4_L9_r0_body.kd59 PRE_first_tail_x4_L9_r0_body.kappa59 PRE_first_tail_x4_L9_r0_body.P59
    ⟨21879, 18976, 2822758, 15⟩ ⟨21883, 18982, 2822773, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap59
  clean := bodyClean59
  cfix := PRE_first_tail_x4_L9_r0_body.cfix59
  zpl := PRE_first_tail_x4_L9_r0_body.zpl59
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd59
  zn1 := PRE_first_tail_x4_L9_r0_body.zn159
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst59
  zscn := PRE_first_tail_x4_L9_r0_body.zscn59
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn59
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow59
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab59
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh59
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd59
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi59
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt59
  zgP := PRE_first_tail_x4_L9_r0_body.zg59_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk59_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm59_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg59_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk59_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm59_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw59_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw59_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap59
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd59
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap59 PRE_first_tail_x4_L9_r0_body.stFoot59 PRE_first_tail_x4_L9_r0_body.iso59 PRE_first_tail_x4_L9_r0_body.zwr59
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP59
  csupp := PRE_first_tail_x4_L9_r0_body.csupp59
  cbound := PRE_first_tail_x4_L9_r0_body.cbound59
  zimg := PRE_first_tail_x4_L9_r0_body.zimg59
  zctl := PRE_first_tail_x4_L9_r0_body.zctl59
  zstack := PRE_first_tail_x4_L9_r0_body.zstack59
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs59
  zstores := PRE_first_tail_x4_L9_r0_body.zstores59
  zroots := PRE_first_tail_x4_L9_r0_body.zroots59
  znC := PRE_first_tail_x4_L9_r0_body.znC59
  ctab := PRE_first_tail_x4_L9_r0_body.ctab59
  zbin := PRE_first_tail_x4_L9_r0_body.zbin59
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge59
  sbridge := bodyBridge59
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj59
  cshiftR := fun h hNL => bodyCshift59 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN59
  raised := PRE_first_tail_x4_L9_r0_body.raised59
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs59
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl59
  xnLe := Nat.le_of_ble_eq_true bodyXn59
  loLe := Nat.le_of_ble_eq_true bodyLo59
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB59
  cntM := bodyCntM59
  hiLe := Nat.le_of_ble_eq_true bodyHi59
  nhiLe := Nat.le_of_ble_eq_true bodyNhi59
  jsHeap := bodyJs59
  jsRoots := bodyJsRoots59
  jsNative := bodyJsNative59
  framesEmpty := bodyFramesEmpty59
  trailOld := by decide
  lowVars := bodyLow59

def bodyQs59 : List (Option Q) := []
noncomputable def bodyEs59 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr59.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st59.S3.tab r
kernel_rfl bodyResChk59 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs59 bodyQs59) = true
kernel_rfl bodyLq59 : bodyQs59.length = PRE_first_tail_x4_L9_r0_body.cws59.length
kernel_rfl bodyNrLo59 : PRE_first_tail_x4_L9_r0_body.nr59.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S1327.tab.length) = true
kernel_rfl bodySub59 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site59.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost59 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws59 PRE_first_tail_x4_L9_r0_body.cws59 bodyQs59 = true
kernel_rfl bodyDrop59 : Nat.ble (60719 + (PRE_first_tail_x4_L9_r0_body.s1328.next - PRE_first_tail_x4_L9_r0_body.s1329.next)) 61069 = true
kernel_rfl bodyDropH59 : Nat.ble (1174 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1328.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s1329.ffi).next)) 1176 = true
kernel_rfl bodyDropN59 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1328.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s1329.ffi).nnext)) 0 = true
kernel_rfl bodyDv59 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws59
kernel_rfl bodyDe59 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr59.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st59.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl59 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold59 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws59).isNone && !PRE_first_tail_x4_L9_r0_body.ws59.contains v) = true
kernel_rfl bodyDfree59 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws59 ++ PRE_first_tail_x4_L9_r0_body.ws59).all fun w => e.noVar w) = true

theorem bodyStep59 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨60719, 1174, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1327 PRE_first_tail_x4_L9_r0_body.S1327)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61069, 1176, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1329 PRE_first_tail_x4_L9_r0_body.S1329) (3452 + 1) :=
  bodySite bodyFacts59.cfix bodyFacts59.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L9_r0_body.st59.S3.tab) (Es := bodyEs59) (qs := bodyQs59)
    (ok := PRE_first_tail_x4_L9_r0_body.st59.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site59 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts59
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site59 r hr) hi (MapOk.sub hm (sub_of_all bodySub59)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk59 r hr) hi hm ho hq)
    bodyLq59 rfl bodyNrLo59 (postSub_sound bodyPost59)
    (Nat.le_of_ble_eq_true bodyDrop59) (by decide) (Nat.le_of_ble_eq_true bodyDropH59) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN59) (by decide)
    bodyDv59 bodyDe59 bodyDl59 bodyDold59 bodyDfree59 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyOracles_15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_g60 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g60 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g60) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site60 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site60 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site60) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st60.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g61 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g61 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g61) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site61 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site61 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site61) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st61.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g62 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g62 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g62) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site62 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site62 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site62) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st62.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g63 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g63 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g63) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site63 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site63 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site63) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st63.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site60 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site60 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site60) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st60.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site60
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st60.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st60.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1351 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1352 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1351 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws60 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st60.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st60.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso60
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_60
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st60.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot60
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup60
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound60
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace60
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged60
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws60.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st60.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1351.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_60]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen60.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh60
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl60 : Conv.NClean (⟨21951, 19028, 2825800, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1351.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl60 (PRE_first_tail_x4_L9_r0_body.cncl59 bodyNcl59)

theorem bodyClean60 : Conv.JClean (⟨21951, 19028, 2825800, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s1351 :=
  PRE_first_tail_x4_L9_r0_body.gjcl60 (PRE_first_tail_x4_L9_r0_body.cjcl59 bodyClean59)

kernel_rfl bodyJsLe60 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1327.next PRE_first_tail_x4_L9_r0_body.s1351.next = true
kernel_rfl bodyJsList60 : (PRE_first_tail_x4_L9_r0_body.gjh60 ++ PRE_first_tail_x4_L9_r0_body.cl60).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1351.next) PRE_first_tail_x4_L9_r0_body.s1353) = true
theorem bodyJs60 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s1351.next PRE_first_tail_x4_L9_r0_body.s1353 :=
  JsHeapAbove.glueSite bodyJs59 (Nat.le_of_ble_eq_true bodyJsLe60) PRE_first_tail_x4_L9_r0_body.gjk60 PRE_first_tail_x4_L9_r0_body.gjbd60 PRE_first_tail_x4_L9_r0_body.cheap60 PRE_first_tail_x4_L9_r0_body.zclbd60 bodyJsList60

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1329 : PRE_first_tail_x4_L9_r0_body.S1329.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1329.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1329 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1329.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1329 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1329 PRE_first_tail_x4_L9_r0_body.S1329) = fun _ _ => true
kernel_rfl bodyAcc1332 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1332 PRE_first_tail_x4_L9_r0_body.S1332) = fun _ _ => true
kernel_rfl bodyBr1333 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1333.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1332 : isHalt PRE_first_tail_x4_L9_r0_body.s1332.ctl = false
kernel_rfl bodyTop1333 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1333 = true
kernel_rfl bodyCnt1329 : countersOkB PRE_first_tail_x4_L9_r0_body.s1329 PRE_first_tail_x4_L9_r0_body.s1333 = true
kernel_rfl bodyO1333 : PRE_first_tail_x4_L9_r0_body.S1333.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1333.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1334 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1334.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1333 : countersOkB PRE_first_tail_x4_L9_r0_body.s1333 PRE_first_tail_x4_L9_r0_body.s1334 = true
kernel_rfl bodyO1334 : PRE_first_tail_x4_L9_r0_body.S1334.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1334.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1334 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1334 PRE_first_tail_x4_L9_r0_body.S1334) = fun _ _ => true
kernel_rfl bodyAcc1338 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1338 PRE_first_tail_x4_L9_r0_body.S1338) = fun _ _ => true
kernel_rfl bodyBr1339 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1339.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1338 : isHalt PRE_first_tail_x4_L9_r0_body.s1338.ctl = false
kernel_rfl bodyTop1339 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1339 = true
kernel_rfl bodyCnt1334 : countersOkB PRE_first_tail_x4_L9_r0_body.s1334 PRE_first_tail_x4_L9_r0_body.s1339 = true
kernel_rfl bodyO1339 : PRE_first_tail_x4_L9_r0_body.S1339.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1339.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1340 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1340.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1339 : countersOkB PRE_first_tail_x4_L9_r0_body.s1339 PRE_first_tail_x4_L9_r0_body.s1340 = true
kernel_rfl bodyO1340 : PRE_first_tail_x4_L9_r0_body.S1340.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1340.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1340 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1340 PRE_first_tail_x4_L9_r0_body.S1340) = fun _ _ => true
kernel_rfl bodyAcc1341 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1341 PRE_first_tail_x4_L9_r0_body.S1341) = fun _ _ => true
kernel_rfl bodyBr1342 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1342.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1341 : isHalt PRE_first_tail_x4_L9_r0_body.s1341.ctl = false
kernel_rfl bodyTop1342 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1342 = true
kernel_rfl bodyCnt1340 : countersOkB PRE_first_tail_x4_L9_r0_body.s1340 PRE_first_tail_x4_L9_r0_body.s1342 = true
kernel_rfl bodyO1342 : PRE_first_tail_x4_L9_r0_body.S1342.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1342.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1343 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1343.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1342 : countersOkB PRE_first_tail_x4_L9_r0_body.s1342 PRE_first_tail_x4_L9_r0_body.s1343 = true
kernel_rfl bodyO1343 : PRE_first_tail_x4_L9_r0_body.S1343.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1343.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1343 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1343 PRE_first_tail_x4_L9_r0_body.S1343) = fun _ _ => true
kernel_rfl bodyAcc1344 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1344 PRE_first_tail_x4_L9_r0_body.S1344) = fun _ _ => true
kernel_rfl bodyBr1345 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1345.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1344 : isHalt PRE_first_tail_x4_L9_r0_body.s1344.ctl = false
kernel_rfl bodyTop1345 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1345 = true
kernel_rfl bodyCnt1343 : countersOkB PRE_first_tail_x4_L9_r0_body.s1343 PRE_first_tail_x4_L9_r0_body.s1345 = true
kernel_rfl bodyO1345 : PRE_first_tail_x4_L9_r0_body.S1345.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1345.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1346 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1346.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1345 : countersOkB PRE_first_tail_x4_L9_r0_body.s1345 PRE_first_tail_x4_L9_r0_body.s1346 = true
kernel_rfl bodyO1346 : PRE_first_tail_x4_L9_r0_body.S1346.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1346.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1346 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1346 PRE_first_tail_x4_L9_r0_body.S1346) = fun _ _ => true
kernel_rfl bodyAcc1347 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1347 PRE_first_tail_x4_L9_r0_body.S1347) = fun _ _ => true
kernel_rfl bodyBr1348 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1348.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1347 : isHalt PRE_first_tail_x4_L9_r0_body.s1347.ctl = false
kernel_rfl bodyTop1348 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1348 = true
kernel_rfl bodyCnt1346 : countersOkB PRE_first_tail_x4_L9_r0_body.s1346 PRE_first_tail_x4_L9_r0_body.s1348 = true
kernel_rfl bodyO1348 : PRE_first_tail_x4_L9_r0_body.S1348.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1348.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1349 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1349.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1348 : countersOkB PRE_first_tail_x4_L9_r0_body.s1348 PRE_first_tail_x4_L9_r0_body.s1349 = true
kernel_rfl bodyO1349 : PRE_first_tail_x4_L9_r0_body.S1349.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1349.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1349 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1349 PRE_first_tail_x4_L9_r0_body.S1349) = fun _ _ => true
kernel_rfl bodyAcc1350 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1350 PRE_first_tail_x4_L9_r0_body.S1350) = fun _ _ => true
kernel_rfl bodyBr1351 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1351.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1350 : isHalt PRE_first_tail_x4_L9_r0_body.s1350.ctl = false
kernel_rfl bodyTop1351 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1351 = true
kernel_rfl bodyCnt1349 : countersOkB PRE_first_tail_x4_L9_r0_body.s1349 PRE_first_tail_x4_L9_r0_body.s1351 = true

theorem bodyGlue60 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61069, 1176, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1329 PRE_first_tail_x4_L9_r0_body.S1329)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61069, 1176, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1351 PRE_first_tail_x4_L9_r0_body.S1351) 30942 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) bodyAcc1329 PRE_first_tail_x4_L9_r0_body.bodyRunSeg344 bodyAcc1332 bodyHalt1332 PRE_first_tail_x4_L9_r0_body.bodyStepA345 bodyTop1333 (fun _ hm => bodyO1329 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1329).trans bodyInactive0) (bodyBr1333.trans bodyBr1329.symm) bodyCnt1329 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA345 PRE_first_tail_x4_L9_r0_body.sizeArgsA345 PRE_first_tail_x4_L9_r0_body.sizeSymA345 PRE_first_tail_x4_L9_r0_body.sizeMlxA345 PRE_first_tail_x4_L9_r0_body.sizePayA345 PRE_first_tail_x4_L9_r0_body.sizeTaA345 PRE_first_tail_x4_L9_r0_body.sizeDecA345 PRE_first_tail_x4_L9_r0_body.sizePreA345 PRE_first_tail_x4_L9_r0_body.bodyPatchB345 (fun _ hm => bodyO1333 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1333).trans bodyInactive0) (bodyBr1334.trans bodyBr1333.symm) bodyCnt1333 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) bodyAcc1334 PRE_first_tail_x4_L9_r0_body.bodyRunSeg345 bodyAcc1338 bodyHalt1338 PRE_first_tail_x4_L9_r0_body.bodyStepA346 bodyTop1339 (fun _ hm => bodyO1334 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1334).trans bodyInactive0) (bodyBr1339.trans bodyBr1334.symm) bodyCnt1334 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA346 PRE_first_tail_x4_L9_r0_body.sizeArgsA346 PRE_first_tail_x4_L9_r0_body.sizeSymA346 PRE_first_tail_x4_L9_r0_body.sizeMlxA346 PRE_first_tail_x4_L9_r0_body.sizePayA346 PRE_first_tail_x4_L9_r0_body.sizeTaA346 PRE_first_tail_x4_L9_r0_body.sizeDecA346 PRE_first_tail_x4_L9_r0_body.sizePreA346 PRE_first_tail_x4_L9_r0_body.bodyPatchB346 (fun _ hm => bodyO1339 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1339).trans bodyInactive0) (bodyBr1340.trans bodyBr1339.symm) bodyCnt1339 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) bodyAcc1340 PRE_first_tail_x4_L9_r0_body.bodyRunSeg346 bodyAcc1341 bodyHalt1341 PRE_first_tail_x4_L9_r0_body.bodyStepA347 bodyTop1342 (fun _ hm => bodyO1340 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1340).trans bodyInactive0) (bodyBr1342.trans bodyBr1340.symm) bodyCnt1340 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA347 PRE_first_tail_x4_L9_r0_body.sizeArgsA347 PRE_first_tail_x4_L9_r0_body.sizeSymA347 PRE_first_tail_x4_L9_r0_body.sizeMlxA347 PRE_first_tail_x4_L9_r0_body.sizePayA347 PRE_first_tail_x4_L9_r0_body.sizeTaA347 PRE_first_tail_x4_L9_r0_body.sizeDecA347 PRE_first_tail_x4_L9_r0_body.sizePreA347 PRE_first_tail_x4_L9_r0_body.bodyPatchB347 (fun _ hm => bodyO1342 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1342).trans bodyInactive0) (bodyBr1343.trans bodyBr1342.symm) bodyCnt1342 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) bodyAcc1343 PRE_first_tail_x4_L9_r0_body.bodyRunSeg347 bodyAcc1344 bodyHalt1344 PRE_first_tail_x4_L9_r0_body.bodyStepA348 bodyTop1345 (fun _ hm => bodyO1343 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1343).trans bodyInactive0) (bodyBr1345.trans bodyBr1343.symm) bodyCnt1343 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA348 PRE_first_tail_x4_L9_r0_body.sizeArgsA348 PRE_first_tail_x4_L9_r0_body.sizeSymA348 PRE_first_tail_x4_L9_r0_body.sizeMlxA348 PRE_first_tail_x4_L9_r0_body.sizePayA348 PRE_first_tail_x4_L9_r0_body.sizeTaA348 PRE_first_tail_x4_L9_r0_body.sizeDecA348 PRE_first_tail_x4_L9_r0_body.sizePreA348 PRE_first_tail_x4_L9_r0_body.bodyPatchB348 (fun _ hm => bodyO1345 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1345).trans bodyInactive0) (bodyBr1346.trans bodyBr1345.symm) bodyCnt1345 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) bodyAcc1346 PRE_first_tail_x4_L9_r0_body.bodyRunSeg348 bodyAcc1347 bodyHalt1347 PRE_first_tail_x4_L9_r0_body.bodyStepA349 bodyTop1348 (fun _ hm => bodyO1346 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1346).trans bodyInactive0) (bodyBr1348.trans bodyBr1346.symm) bodyCnt1346 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA349 PRE_first_tail_x4_L9_r0_body.sizeArgsA349 PRE_first_tail_x4_L9_r0_body.sizeSymA349 PRE_first_tail_x4_L9_r0_body.sizeMlxA349 PRE_first_tail_x4_L9_r0_body.sizePayA349 PRE_first_tail_x4_L9_r0_body.sizeTaA349 PRE_first_tail_x4_L9_r0_body.sizeDecA349 PRE_first_tail_x4_L9_r0_body.sizePreA349 PRE_first_tail_x4_L9_r0_body.bodyPatchB349 (fun _ hm => bodyO1348 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1348).trans bodyInactive0) (bodyBr1349.trans bodyBr1348.symm) bodyCnt1348 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61069, 1176, 0, 0⟩) bodyAcc1349 PRE_first_tail_x4_L9_r0_body.bodyRunSeg349 bodyAcc1350 bodyHalt1350 PRE_first_tail_x4_L9_r0_body.bodyStepA350 bodyTop1351 (fun _ hm => bodyO1349 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1349).trans bodyInactive0) (bodyBr1351.trans bodyBr1349.symm) bodyCnt1349 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift60 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S1351.tab.length PRE_first_tail_x4_L9_r0_body.s1351.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P60.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P60 15 PRE_first_tail_x4_L9_r0_body.kappa60 PRE_first_tail_x4_L9_r0_body.s1353.ffi PRE_first_tail_x4_L9_r0_body.s1352.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_60
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_60
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1353.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S1351.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_60] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK60 PRE_first_tail_x4_L9_r0_body.cobjsK60
      PRE_first_tail_x4_L9_r0_body.citemsK60 PRE_first_tail_x4_L9_r0_body.cbd60 PRE_first_tail_x4_L9_r0_body.csst60
  exact PRE_first_tail_x4_L9_r0_body.cshift60 bodyNcl60 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_60] at this; exact this)


kernel_rfl bodyFramesEmpty60 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s1352 a).isEmpty) = true
kernel_rfl bodyJsRoots60 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1351.next) PRE_first_tail_x4_L9_r0_body.s1353.trace PRE_first_tail_x4_L9_r0_body.s1353 = true
kernel_rfl bodyJsNative60 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s1353.ffi) = true
kernel_rfl bodyLow60 : (PRE_first_tail_x4_L9_r0_body.cws60 ++ PRE_first_tail_x4_L9_r0_body.ws60).all (Nat.ble 9) = true
kernel_rfl bodyCntM60 : countersOkB PRE_first_tail_x4_L9_r0_body.s1351 PRE_first_tail_x4_L9_r0_body.s1352 = true
kernel_rfl bodyHi60 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1353.ffi).next setupP.E = true
kernel_rfl bodyNhi60 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1353.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge60 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1352.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s1351.ffi
kernel_rfl bodyNN60 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1351.ffi).nnext PRE_first_tail_x4_L9_r0_body.P60.NL = true
kernel_rfl bodyXn60 : Nat.ble (⟨21954, 19055, 2825806, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s1353.ffi).next = true
kernel_rfl bodyLo60 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s1353.ffi).next = true
theorem bodyFacts60 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s1351 PRE_first_tail_x4_L9_r0_body.s1352 PRE_first_tail_x4_L9_r0_body.s1353 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S1351 PRE_first_tail_x4_L9_r0_body.S1352 PRE_first_tail_x4_L9_r0_body.S1353
    PRE_first_tail_x4_L9_r0_body.ws60 PRE_first_tail_x4_L9_r0_body.cws60 PRE_first_tail_x4_L9_r0_body.nr60 PRE_first_tail_x4_L9_r0_body.pl60 PRE_first_tail_x4_L9_r0_body.cl60 2826955 15 PRE_first_tail_x4_L9_r0_body.kd60 PRE_first_tail_x4_L9_r0_body.kappa60 PRE_first_tail_x4_L9_r0_body.P60
    ⟨21951, 19028, 2825800, 15⟩ ⟨21954, 19055, 2825806, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap60
  clean := bodyClean60
  cfix := PRE_first_tail_x4_L9_r0_body.cfix60
  zpl := PRE_first_tail_x4_L9_r0_body.zpl60
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd60
  zn1 := PRE_first_tail_x4_L9_r0_body.zn160
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst60
  zscn := PRE_first_tail_x4_L9_r0_body.zscn60
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn60
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow60
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab60
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh60
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd60
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi60
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt60
  zgP := PRE_first_tail_x4_L9_r0_body.zg60_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk60_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm60_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg60_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk60_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm60_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw60_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw60_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap60
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd60
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap60 PRE_first_tail_x4_L9_r0_body.stFoot60 PRE_first_tail_x4_L9_r0_body.iso60 PRE_first_tail_x4_L9_r0_body.zwr60
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP60
  csupp := PRE_first_tail_x4_L9_r0_body.csupp60
  cbound := PRE_first_tail_x4_L9_r0_body.cbound60
  zimg := PRE_first_tail_x4_L9_r0_body.zimg60
  zctl := PRE_first_tail_x4_L9_r0_body.zctl60
  zstack := PRE_first_tail_x4_L9_r0_body.zstack60
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs60
  zstores := PRE_first_tail_x4_L9_r0_body.zstores60
  zroots := PRE_first_tail_x4_L9_r0_body.zroots60
  znC := PRE_first_tail_x4_L9_r0_body.znC60
  ctab := PRE_first_tail_x4_L9_r0_body.ctab60
  zbin := PRE_first_tail_x4_L9_r0_body.zbin60
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge60
  sbridge := bodyBridge60
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj60
  cshiftR := fun h hNL => bodyCshift60 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN60
  raised := PRE_first_tail_x4_L9_r0_body.raised60
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs60
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl60
  xnLe := Nat.le_of_ble_eq_true bodyXn60
  loLe := Nat.le_of_ble_eq_true bodyLo60
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB60
  cntM := bodyCntM60
  hiLe := Nat.le_of_ble_eq_true bodyHi60
  nhiLe := Nat.le_of_ble_eq_true bodyNhi60
  jsHeap := bodyJs60
  jsRoots := bodyJsRoots60
  jsNative := bodyJsNative60
  framesEmpty := bodyFramesEmpty60
  trailOld := by decide
  lowVars := bodyLow60

def bodyQs60 : List (Option Q) := []
noncomputable def bodyEs60 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr60.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st60.S5.tab r
kernel_rfl bodyResChk60 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs60 bodyQs60) = true
kernel_rfl bodyLq60 : bodyQs60.length = PRE_first_tail_x4_L9_r0_body.cws60.length
kernel_rfl bodyNrLo60 : PRE_first_tail_x4_L9_r0_body.nr60.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S1351.tab.length) = true
kernel_rfl bodySub60 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site60.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost60 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws60 PRE_first_tail_x4_L9_r0_body.cws60 bodyQs60 = true
kernel_rfl bodyDrop60 : Nat.ble (61069 + (PRE_first_tail_x4_L9_r0_body.s1352.next - PRE_first_tail_x4_L9_r0_body.s1353.next)) 62218 = true
kernel_rfl bodyDropH60 : Nat.ble (1176 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1352.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s1353.ffi).next)) 1201 = true
kernel_rfl bodyDropN60 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1352.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s1353.ffi).nnext)) 0 = true
kernel_rfl bodyDv60 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws60
kernel_rfl bodyDe60 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr60.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st60.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl60 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold60 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws60).isNone && !PRE_first_tail_x4_L9_r0_body.ws60.contains v) = true
kernel_rfl bodyDfree60 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws60 ++ PRE_first_tail_x4_L9_r0_body.ws60).all fun w => e.noVar w) = true

theorem bodyStep60 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61069, 1176, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1351 PRE_first_tail_x4_L9_r0_body.S1351)
      (bodyCut NB T tk π i x0 bodyΘ ⟨62218, 1201, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1353 PRE_first_tail_x4_L9_r0_body.S1353) (11334 + 1) :=
  bodySite bodyFacts60.cfix bodyFacts60.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st60.S5.tab) (Es := bodyEs60) (qs := bodyQs60)
    (ok := PRE_first_tail_x4_L9_r0_body.st60.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site60 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts60
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site60 r hr) hi (MapOk.sub hm (sub_of_all bodySub60)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk60 r hr) hi hm ho hq)
    bodyLq60 rfl bodyNrLo60 (postSub_sound bodyPost60)
    (Nat.le_of_ble_eq_true bodyDrop60) (by decide) (Nat.le_of_ble_eq_true bodyDropH60) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN60) (by decide)
    bodyDv60 bodyDe60 bodyDl60 bodyDold60 bodyDfree60 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site61 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site61 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site61) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st61.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site61
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st61.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st61.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1373 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1374 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1373 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws61 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st61.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st61.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso61
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_61
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st61.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot61
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup61
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound61
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace61
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged61
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws61.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st61.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1373.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_61]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen61.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh61
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl61 : Conv.NClean (⟨22008, 19091, 2828042, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1373.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl61 (PRE_first_tail_x4_L9_r0_body.cncl60 bodyNcl60)

theorem bodyClean61 : Conv.JClean (⟨22008, 19091, 2828042, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s1373 :=
  PRE_first_tail_x4_L9_r0_body.gjcl61 (PRE_first_tail_x4_L9_r0_body.cjcl60 bodyClean60)

kernel_rfl bodyJsLe61 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1351.next PRE_first_tail_x4_L9_r0_body.s1373.next = true
kernel_rfl bodyJsList61 : (PRE_first_tail_x4_L9_r0_body.gjh61 ++ PRE_first_tail_x4_L9_r0_body.cl61).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1373.next) PRE_first_tail_x4_L9_r0_body.s1375) = true
theorem bodyJs61 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s1373.next PRE_first_tail_x4_L9_r0_body.s1375 :=
  JsHeapAbove.glueSite bodyJs60 (Nat.le_of_ble_eq_true bodyJsLe61) PRE_first_tail_x4_L9_r0_body.gjk61 PRE_first_tail_x4_L9_r0_body.gjbd61 PRE_first_tail_x4_L9_r0_body.cheap61 PRE_first_tail_x4_L9_r0_body.zclbd61 bodyJsList61

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1353 : PRE_first_tail_x4_L9_r0_body.S1353.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1353.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1353 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1353.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1353 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1353 PRE_first_tail_x4_L9_r0_body.S1353) = fun _ _ => true
kernel_rfl bodyAcc1354 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1354 PRE_first_tail_x4_L9_r0_body.S1354) = fun _ _ => true
kernel_rfl bodyBr1355 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1355.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1354 : isHalt PRE_first_tail_x4_L9_r0_body.s1354.ctl = false
kernel_rfl bodyTop1355 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1355 = true
kernel_rfl bodyCnt1353 : countersOkB PRE_first_tail_x4_L9_r0_body.s1353 PRE_first_tail_x4_L9_r0_body.s1355 = true
kernel_rfl bodyO1355 : PRE_first_tail_x4_L9_r0_body.S1355.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1355.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1356 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1356.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1355 : countersOkB PRE_first_tail_x4_L9_r0_body.s1355 PRE_first_tail_x4_L9_r0_body.s1356 = true
kernel_rfl bodyO1356 : PRE_first_tail_x4_L9_r0_body.S1356.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1356.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1356 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1356 PRE_first_tail_x4_L9_r0_body.S1356) = fun _ _ => true
kernel_rfl bodyAcc1360 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1360 PRE_first_tail_x4_L9_r0_body.S1360) = fun _ _ => true
kernel_rfl bodyBr1361 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1361.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1360 : isHalt PRE_first_tail_x4_L9_r0_body.s1360.ctl = false
kernel_rfl bodyTop1361 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1361 = true
kernel_rfl bodyCnt1356 : countersOkB PRE_first_tail_x4_L9_r0_body.s1356 PRE_first_tail_x4_L9_r0_body.s1361 = true
kernel_rfl bodyO1361 : PRE_first_tail_x4_L9_r0_body.S1361.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1361.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1362 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1362.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1361 : countersOkB PRE_first_tail_x4_L9_r0_body.s1361 PRE_first_tail_x4_L9_r0_body.s1362 = true
kernel_rfl bodyO1362 : PRE_first_tail_x4_L9_r0_body.S1362.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1362.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1362 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1362 PRE_first_tail_x4_L9_r0_body.S1362) = fun _ _ => true
kernel_rfl bodyAcc1363 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1363 PRE_first_tail_x4_L9_r0_body.S1363) = fun _ _ => true
kernel_rfl bodyBr1364 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1364.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1363 : isHalt PRE_first_tail_x4_L9_r0_body.s1363.ctl = false
kernel_rfl bodyTop1364 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1364 = true
kernel_rfl bodyCnt1362 : countersOkB PRE_first_tail_x4_L9_r0_body.s1362 PRE_first_tail_x4_L9_r0_body.s1364 = true
kernel_rfl bodyO1364 : PRE_first_tail_x4_L9_r0_body.S1364.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1364.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1365 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1365.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1364 : countersOkB PRE_first_tail_x4_L9_r0_body.s1364 PRE_first_tail_x4_L9_r0_body.s1365 = true
kernel_rfl bodyO1365 : PRE_first_tail_x4_L9_r0_body.S1365.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1365.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1365 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1365 PRE_first_tail_x4_L9_r0_body.S1365) = fun _ _ => true
kernel_rfl bodyAcc1366 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1366 PRE_first_tail_x4_L9_r0_body.S1366) = fun _ _ => true
kernel_rfl bodyBr1367 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1367.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1366 : isHalt PRE_first_tail_x4_L9_r0_body.s1366.ctl = false
kernel_rfl bodyTop1367 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1367 = true
kernel_rfl bodyCnt1365 : countersOkB PRE_first_tail_x4_L9_r0_body.s1365 PRE_first_tail_x4_L9_r0_body.s1367 = true
kernel_rfl bodyO1367 : PRE_first_tail_x4_L9_r0_body.S1367.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1367.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1368 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1368.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1367 : countersOkB PRE_first_tail_x4_L9_r0_body.s1367 PRE_first_tail_x4_L9_r0_body.s1368 = true
kernel_rfl bodyO1368 : PRE_first_tail_x4_L9_r0_body.S1368.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1368.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1368 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1368 PRE_first_tail_x4_L9_r0_body.S1368) = fun _ _ => true
kernel_rfl bodyAcc1369 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1369 PRE_first_tail_x4_L9_r0_body.S1369) = fun _ _ => true
kernel_rfl bodyBr1370 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1370.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1369 : isHalt PRE_first_tail_x4_L9_r0_body.s1369.ctl = false
kernel_rfl bodyTop1370 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1370 = true
kernel_rfl bodyCnt1368 : countersOkB PRE_first_tail_x4_L9_r0_body.s1368 PRE_first_tail_x4_L9_r0_body.s1370 = true
kernel_rfl bodyO1370 : PRE_first_tail_x4_L9_r0_body.S1370.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1370.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1371 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1371.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1370 : countersOkB PRE_first_tail_x4_L9_r0_body.s1370 PRE_first_tail_x4_L9_r0_body.s1371 = true
kernel_rfl bodyO1371 : PRE_first_tail_x4_L9_r0_body.S1371.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1371.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1371 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1371 PRE_first_tail_x4_L9_r0_body.S1371) = fun _ _ => true
kernel_rfl bodyAcc1372 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1372 PRE_first_tail_x4_L9_r0_body.S1372) = fun _ _ => true
kernel_rfl bodyBr1373 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1373.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1372 : isHalt PRE_first_tail_x4_L9_r0_body.s1372.ctl = false
kernel_rfl bodyTop1373 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1373 = true
kernel_rfl bodyCnt1371 : countersOkB PRE_first_tail_x4_L9_r0_body.s1371 PRE_first_tail_x4_L9_r0_body.s1373 = true

theorem bodyGlue61 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨62218, 1201, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1353 PRE_first_tail_x4_L9_r0_body.S1353)
      (bodyCut NB T tk π i x0 bodyΘ ⟨62218, 1201, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1373 PRE_first_tail_x4_L9_r0_body.S1373) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) bodyAcc1353 PRE_first_tail_x4_L9_r0_body.bodyRunSeg350 bodyAcc1354 bodyHalt1354 PRE_first_tail_x4_L9_r0_body.bodyStepA351 bodyTop1355 (fun _ hm => bodyO1353 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1353).trans bodyInactive0) (bodyBr1355.trans bodyBr1353.symm) bodyCnt1353 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA351 PRE_first_tail_x4_L9_r0_body.sizeArgsA351 PRE_first_tail_x4_L9_r0_body.sizeSymA351 PRE_first_tail_x4_L9_r0_body.sizeMlxA351 PRE_first_tail_x4_L9_r0_body.sizePayA351 PRE_first_tail_x4_L9_r0_body.sizeTaA351 PRE_first_tail_x4_L9_r0_body.sizeDecA351 PRE_first_tail_x4_L9_r0_body.sizePreA351 PRE_first_tail_x4_L9_r0_body.bodyPatchB351 (fun _ hm => bodyO1355 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1355).trans bodyInactive0) (bodyBr1356.trans bodyBr1355.symm) bodyCnt1355 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) bodyAcc1356 PRE_first_tail_x4_L9_r0_body.bodyRunSeg351 bodyAcc1360 bodyHalt1360 PRE_first_tail_x4_L9_r0_body.bodyStepA352 bodyTop1361 (fun _ hm => bodyO1356 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1356).trans bodyInactive0) (bodyBr1361.trans bodyBr1356.symm) bodyCnt1356 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA352 PRE_first_tail_x4_L9_r0_body.sizeArgsA352 PRE_first_tail_x4_L9_r0_body.sizeSymA352 PRE_first_tail_x4_L9_r0_body.sizeMlxA352 PRE_first_tail_x4_L9_r0_body.sizePayA352 PRE_first_tail_x4_L9_r0_body.sizeTaA352 PRE_first_tail_x4_L9_r0_body.sizeDecA352 PRE_first_tail_x4_L9_r0_body.sizePreA352 PRE_first_tail_x4_L9_r0_body.bodyPatchB352 (fun _ hm => bodyO1361 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1361).trans bodyInactive0) (bodyBr1362.trans bodyBr1361.symm) bodyCnt1361 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) bodyAcc1362 PRE_first_tail_x4_L9_r0_body.bodyRunSeg352 bodyAcc1363 bodyHalt1363 PRE_first_tail_x4_L9_r0_body.bodyStepA353 bodyTop1364 (fun _ hm => bodyO1362 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1362).trans bodyInactive0) (bodyBr1364.trans bodyBr1362.symm) bodyCnt1362 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA353 PRE_first_tail_x4_L9_r0_body.sizeArgsA353 PRE_first_tail_x4_L9_r0_body.sizeSymA353 PRE_first_tail_x4_L9_r0_body.sizeMlxA353 PRE_first_tail_x4_L9_r0_body.sizePayA353 PRE_first_tail_x4_L9_r0_body.sizeTaA353 PRE_first_tail_x4_L9_r0_body.sizeDecA353 PRE_first_tail_x4_L9_r0_body.sizePreA353 PRE_first_tail_x4_L9_r0_body.bodyPatchB353 (fun _ hm => bodyO1364 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1364).trans bodyInactive0) (bodyBr1365.trans bodyBr1364.symm) bodyCnt1364 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) bodyAcc1365 PRE_first_tail_x4_L9_r0_body.bodyRunSeg353 bodyAcc1366 bodyHalt1366 PRE_first_tail_x4_L9_r0_body.bodyStepA354 bodyTop1367 (fun _ hm => bodyO1365 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1365).trans bodyInactive0) (bodyBr1367.trans bodyBr1365.symm) bodyCnt1365 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA354 PRE_first_tail_x4_L9_r0_body.sizeArgsA354 PRE_first_tail_x4_L9_r0_body.sizeSymA354 PRE_first_tail_x4_L9_r0_body.sizeMlxA354 PRE_first_tail_x4_L9_r0_body.sizePayA354 PRE_first_tail_x4_L9_r0_body.sizeTaA354 PRE_first_tail_x4_L9_r0_body.sizeDecA354 PRE_first_tail_x4_L9_r0_body.sizePreA354 PRE_first_tail_x4_L9_r0_body.bodyPatchB354 (fun _ hm => bodyO1367 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1367).trans bodyInactive0) (bodyBr1368.trans bodyBr1367.symm) bodyCnt1367 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) bodyAcc1368 PRE_first_tail_x4_L9_r0_body.bodyRunSeg354 bodyAcc1369 bodyHalt1369 PRE_first_tail_x4_L9_r0_body.bodyStepA355 bodyTop1370 (fun _ hm => bodyO1368 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1368).trans bodyInactive0) (bodyBr1370.trans bodyBr1368.symm) bodyCnt1368 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA355 PRE_first_tail_x4_L9_r0_body.sizeArgsA355 PRE_first_tail_x4_L9_r0_body.sizeSymA355 PRE_first_tail_x4_L9_r0_body.sizeMlxA355 PRE_first_tail_x4_L9_r0_body.sizePayA355 PRE_first_tail_x4_L9_r0_body.sizeTaA355 PRE_first_tail_x4_L9_r0_body.sizeDecA355 PRE_first_tail_x4_L9_r0_body.sizePreA355 PRE_first_tail_x4_L9_r0_body.bodyPatchB355 (fun _ hm => bodyO1370 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1370).trans bodyInactive0) (bodyBr1371.trans bodyBr1370.symm) bodyCnt1370 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨62218, 1201, 0, 0⟩) bodyAcc1371 PRE_first_tail_x4_L9_r0_body.bodyRunSeg355 bodyAcc1372 bodyHalt1372 PRE_first_tail_x4_L9_r0_body.bodyStepA356 bodyTop1373 (fun _ hm => bodyO1371 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1371).trans bodyInactive0) (bodyBr1373.trans bodyBr1371.symm) bodyCnt1371 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift61 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S1373.tab.length PRE_first_tail_x4_L9_r0_body.s1373.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P61.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P61 15 PRE_first_tail_x4_L9_r0_body.kappa61 PRE_first_tail_x4_L9_r0_body.s1375.ffi PRE_first_tail_x4_L9_r0_body.s1374.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_61
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_61
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1375.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S1373.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_61] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK61 PRE_first_tail_x4_L9_r0_body.cobjsK61
      PRE_first_tail_x4_L9_r0_body.citemsK61 PRE_first_tail_x4_L9_r0_body.cbd61 PRE_first_tail_x4_L9_r0_body.csst61
  exact PRE_first_tail_x4_L9_r0_body.cshift61 bodyNcl61 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_61] at this; exact this)


kernel_rfl bodyFramesEmpty61 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s1374 a).isEmpty) = true
kernel_rfl bodyJsRoots61 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1373.next) PRE_first_tail_x4_L9_r0_body.s1375.trace PRE_first_tail_x4_L9_r0_body.s1375 = true
kernel_rfl bodyJsNative61 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s1375.ffi) = true
kernel_rfl bodyLow61 : (PRE_first_tail_x4_L9_r0_body.cws61 ++ PRE_first_tail_x4_L9_r0_body.ws61).all (Nat.ble 9) = true
kernel_rfl bodyCntM61 : countersOkB PRE_first_tail_x4_L9_r0_body.s1373 PRE_first_tail_x4_L9_r0_body.s1374 = true
kernel_rfl bodyHi61 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1375.ffi).next setupP.E = true
kernel_rfl bodyNhi61 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1375.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge61 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1374.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s1373.ffi
kernel_rfl bodyNN61 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1373.ffi).nnext PRE_first_tail_x4_L9_r0_body.P61.NL = true
kernel_rfl bodyXn61 : Nat.ble (⟨22011, 19118, 2828048, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s1375.ffi).next = true
kernel_rfl bodyLo61 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s1375.ffi).next = true
theorem bodyFacts61 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s1373 PRE_first_tail_x4_L9_r0_body.s1374 PRE_first_tail_x4_L9_r0_body.s1375 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S1373 PRE_first_tail_x4_L9_r0_body.S1374 PRE_first_tail_x4_L9_r0_body.S1375
    PRE_first_tail_x4_L9_r0_body.ws61 PRE_first_tail_x4_L9_r0_body.cws61 PRE_first_tail_x4_L9_r0_body.nr61 PRE_first_tail_x4_L9_r0_body.pl61 PRE_first_tail_x4_L9_r0_body.cl61 2829197 15 PRE_first_tail_x4_L9_r0_body.kd61 PRE_first_tail_x4_L9_r0_body.kappa61 PRE_first_tail_x4_L9_r0_body.P61
    ⟨22008, 19091, 2828042, 15⟩ ⟨22011, 19118, 2828048, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap61
  clean := bodyClean61
  cfix := PRE_first_tail_x4_L9_r0_body.cfix61
  zpl := PRE_first_tail_x4_L9_r0_body.zpl61
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd61
  zn1 := PRE_first_tail_x4_L9_r0_body.zn161
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst61
  zscn := PRE_first_tail_x4_L9_r0_body.zscn61
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn61
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow61
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab61
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh61
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd61
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi61
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt61
  zgP := PRE_first_tail_x4_L9_r0_body.zg61_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk61_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm61_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg61_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk61_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm61_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw61_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw61_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap61
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd61
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap61 PRE_first_tail_x4_L9_r0_body.stFoot61 PRE_first_tail_x4_L9_r0_body.iso61 PRE_first_tail_x4_L9_r0_body.zwr61
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP61
  csupp := PRE_first_tail_x4_L9_r0_body.csupp61
  cbound := PRE_first_tail_x4_L9_r0_body.cbound61
  zimg := PRE_first_tail_x4_L9_r0_body.zimg61
  zctl := PRE_first_tail_x4_L9_r0_body.zctl61
  zstack := PRE_first_tail_x4_L9_r0_body.zstack61
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs61
  zstores := PRE_first_tail_x4_L9_r0_body.zstores61
  zroots := PRE_first_tail_x4_L9_r0_body.zroots61
  znC := PRE_first_tail_x4_L9_r0_body.znC61
  ctab := PRE_first_tail_x4_L9_r0_body.ctab61
  zbin := PRE_first_tail_x4_L9_r0_body.zbin61
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge61
  sbridge := bodyBridge61
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj61
  cshiftR := fun h hNL => bodyCshift61 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN61
  raised := PRE_first_tail_x4_L9_r0_body.raised61
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs61
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl61
  xnLe := Nat.le_of_ble_eq_true bodyXn61
  loLe := Nat.le_of_ble_eq_true bodyLo61
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB61
  cntM := bodyCntM61
  hiLe := Nat.le_of_ble_eq_true bodyHi61
  nhiLe := Nat.le_of_ble_eq_true bodyNhi61
  jsHeap := bodyJs61
  jsRoots := bodyJsRoots61
  jsNative := bodyJsNative61
  framesEmpty := bodyFramesEmpty61
  trailOld := by decide
  lowVars := bodyLow61

def bodyQs61 : List (Option Q) := []
noncomputable def bodyEs61 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr61.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st61.S5.tab r
kernel_rfl bodyResChk61 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs61 bodyQs61) = true
kernel_rfl bodyLq61 : bodyQs61.length = PRE_first_tail_x4_L9_r0_body.cws61.length
kernel_rfl bodyNrLo61 : PRE_first_tail_x4_L9_r0_body.nr61.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S1373.tab.length) = true
kernel_rfl bodySub61 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site61.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost61 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws61 PRE_first_tail_x4_L9_r0_body.cws61 bodyQs61 = true
kernel_rfl bodyDrop61 : Nat.ble (62218 + (PRE_first_tail_x4_L9_r0_body.s1374.next - PRE_first_tail_x4_L9_r0_body.s1375.next)) 63367 = true
kernel_rfl bodyDropH61 : Nat.ble (1201 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1374.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s1375.ffi).next)) 1226 = true
kernel_rfl bodyDropN61 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1374.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s1375.ffi).nnext)) 0 = true
kernel_rfl bodyDv61 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws61
kernel_rfl bodyDe61 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr61.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st61.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl61 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold61 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws61).isNone && !PRE_first_tail_x4_L9_r0_body.ws61.contains v) = true
kernel_rfl bodyDfree61 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws61 ++ PRE_first_tail_x4_L9_r0_body.ws61).all fun w => e.noVar w) = true

theorem bodyStep61 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨62218, 1201, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1373 PRE_first_tail_x4_L9_r0_body.S1373)
      (bodyCut NB T tk π i x0 bodyΘ ⟨63367, 1226, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1375 PRE_first_tail_x4_L9_r0_body.S1375) (11334 + 1) :=
  bodySite bodyFacts61.cfix bodyFacts61.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st61.S5.tab) (Es := bodyEs61) (qs := bodyQs61)
    (ok := PRE_first_tail_x4_L9_r0_body.st61.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site61 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts61
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site61 r hr) hi (MapOk.sub hm (sub_of_all bodySub61)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk61 r hr) hi hm ho hq)
    bodyLq61 rfl bodyNrLo61 (postSub_sound bodyPost61)
    (Nat.le_of_ble_eq_true bodyDrop61) (by decide) (Nat.le_of_ble_eq_true bodyDropH61) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN61) (by decide)
    bodyDv61 bodyDe61 bodyDl61 bodyDold61 bodyDfree61 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site62 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site62 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site62) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st62.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site62
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st62.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st62.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1395 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1396 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1395 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws62 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st62.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st62.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso62
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_62
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st62.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot62
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup62
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound62
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace62
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged62
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws62.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st62.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1395.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_62]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen62.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh62
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl62 : Conv.NClean (⟨22065, 19154, 2830284, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1395.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl62 (PRE_first_tail_x4_L9_r0_body.cncl61 bodyNcl61)

theorem bodyClean62 : Conv.JClean (⟨22065, 19154, 2830284, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s1395 :=
  PRE_first_tail_x4_L9_r0_body.gjcl62 (PRE_first_tail_x4_L9_r0_body.cjcl61 bodyClean61)

kernel_rfl bodyJsLe62 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1373.next PRE_first_tail_x4_L9_r0_body.s1395.next = true
kernel_rfl bodyJsList62 : (PRE_first_tail_x4_L9_r0_body.gjh62 ++ PRE_first_tail_x4_L9_r0_body.cl62).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1395.next) PRE_first_tail_x4_L9_r0_body.s1397) = true
theorem bodyJs62 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s1395.next PRE_first_tail_x4_L9_r0_body.s1397 :=
  JsHeapAbove.glueSite bodyJs61 (Nat.le_of_ble_eq_true bodyJsLe62) PRE_first_tail_x4_L9_r0_body.gjk62 PRE_first_tail_x4_L9_r0_body.gjbd62 PRE_first_tail_x4_L9_r0_body.cheap62 PRE_first_tail_x4_L9_r0_body.zclbd62 bodyJsList62

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1375 : PRE_first_tail_x4_L9_r0_body.S1375.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1375.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1375 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1375.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1375 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1375 PRE_first_tail_x4_L9_r0_body.S1375) = fun _ _ => true
kernel_rfl bodyAcc1376 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1376 PRE_first_tail_x4_L9_r0_body.S1376) = fun _ _ => true
kernel_rfl bodyBr1377 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1377.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1376 : isHalt PRE_first_tail_x4_L9_r0_body.s1376.ctl = false
kernel_rfl bodyTop1377 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1377 = true
kernel_rfl bodyCnt1375 : countersOkB PRE_first_tail_x4_L9_r0_body.s1375 PRE_first_tail_x4_L9_r0_body.s1377 = true
kernel_rfl bodyO1377 : PRE_first_tail_x4_L9_r0_body.S1377.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1377.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1378 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1378.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1377 : countersOkB PRE_first_tail_x4_L9_r0_body.s1377 PRE_first_tail_x4_L9_r0_body.s1378 = true
kernel_rfl bodyO1378 : PRE_first_tail_x4_L9_r0_body.S1378.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1378.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1378 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1378 PRE_first_tail_x4_L9_r0_body.S1378) = fun _ _ => true
kernel_rfl bodyAcc1382 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1382 PRE_first_tail_x4_L9_r0_body.S1382) = fun _ _ => true
kernel_rfl bodyBr1383 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1383.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1382 : isHalt PRE_first_tail_x4_L9_r0_body.s1382.ctl = false
kernel_rfl bodyTop1383 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1383 = true
kernel_rfl bodyCnt1378 : countersOkB PRE_first_tail_x4_L9_r0_body.s1378 PRE_first_tail_x4_L9_r0_body.s1383 = true
kernel_rfl bodyO1383 : PRE_first_tail_x4_L9_r0_body.S1383.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1383.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1384 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1384.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1383 : countersOkB PRE_first_tail_x4_L9_r0_body.s1383 PRE_first_tail_x4_L9_r0_body.s1384 = true
kernel_rfl bodyO1384 : PRE_first_tail_x4_L9_r0_body.S1384.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1384.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1384 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1384 PRE_first_tail_x4_L9_r0_body.S1384) = fun _ _ => true
kernel_rfl bodyAcc1385 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1385 PRE_first_tail_x4_L9_r0_body.S1385) = fun _ _ => true
kernel_rfl bodyBr1386 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1386.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1385 : isHalt PRE_first_tail_x4_L9_r0_body.s1385.ctl = false
kernel_rfl bodyTop1386 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1386 = true
kernel_rfl bodyCnt1384 : countersOkB PRE_first_tail_x4_L9_r0_body.s1384 PRE_first_tail_x4_L9_r0_body.s1386 = true
kernel_rfl bodyO1386 : PRE_first_tail_x4_L9_r0_body.S1386.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1386.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1387 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1387.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1386 : countersOkB PRE_first_tail_x4_L9_r0_body.s1386 PRE_first_tail_x4_L9_r0_body.s1387 = true
kernel_rfl bodyO1387 : PRE_first_tail_x4_L9_r0_body.S1387.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1387.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1387 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1387 PRE_first_tail_x4_L9_r0_body.S1387) = fun _ _ => true
kernel_rfl bodyAcc1388 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1388 PRE_first_tail_x4_L9_r0_body.S1388) = fun _ _ => true
kernel_rfl bodyBr1389 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1389.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1388 : isHalt PRE_first_tail_x4_L9_r0_body.s1388.ctl = false
kernel_rfl bodyTop1389 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1389 = true
kernel_rfl bodyCnt1387 : countersOkB PRE_first_tail_x4_L9_r0_body.s1387 PRE_first_tail_x4_L9_r0_body.s1389 = true
kernel_rfl bodyO1389 : PRE_first_tail_x4_L9_r0_body.S1389.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1389.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1390 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1390.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1389 : countersOkB PRE_first_tail_x4_L9_r0_body.s1389 PRE_first_tail_x4_L9_r0_body.s1390 = true
kernel_rfl bodyO1390 : PRE_first_tail_x4_L9_r0_body.S1390.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1390.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1390 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1390 PRE_first_tail_x4_L9_r0_body.S1390) = fun _ _ => true
kernel_rfl bodyAcc1391 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1391 PRE_first_tail_x4_L9_r0_body.S1391) = fun _ _ => true
kernel_rfl bodyBr1392 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1392.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1391 : isHalt PRE_first_tail_x4_L9_r0_body.s1391.ctl = false
kernel_rfl bodyTop1392 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1392 = true
kernel_rfl bodyCnt1390 : countersOkB PRE_first_tail_x4_L9_r0_body.s1390 PRE_first_tail_x4_L9_r0_body.s1392 = true
kernel_rfl bodyO1392 : PRE_first_tail_x4_L9_r0_body.S1392.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1392.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1393 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1393.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1392 : countersOkB PRE_first_tail_x4_L9_r0_body.s1392 PRE_first_tail_x4_L9_r0_body.s1393 = true
kernel_rfl bodyO1393 : PRE_first_tail_x4_L9_r0_body.S1393.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1393.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1393 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1393 PRE_first_tail_x4_L9_r0_body.S1393) = fun _ _ => true
kernel_rfl bodyAcc1394 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1394 PRE_first_tail_x4_L9_r0_body.S1394) = fun _ _ => true
kernel_rfl bodyBr1395 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1395.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1394 : isHalt PRE_first_tail_x4_L9_r0_body.s1394.ctl = false
kernel_rfl bodyTop1395 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1395 = true
kernel_rfl bodyCnt1393 : countersOkB PRE_first_tail_x4_L9_r0_body.s1393 PRE_first_tail_x4_L9_r0_body.s1395 = true

theorem bodyGlue62 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨63367, 1226, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1375 PRE_first_tail_x4_L9_r0_body.S1375)
      (bodyCut NB T tk π i x0 bodyΘ ⟨63367, 1226, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1395 PRE_first_tail_x4_L9_r0_body.S1395) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) bodyAcc1375 PRE_first_tail_x4_L9_r0_body.bodyRunSeg356 bodyAcc1376 bodyHalt1376 PRE_first_tail_x4_L9_r0_body.bodyStepA357 bodyTop1377 (fun _ hm => bodyO1375 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1375).trans bodyInactive0) (bodyBr1377.trans bodyBr1375.symm) bodyCnt1375 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA357 PRE_first_tail_x4_L9_r0_body.sizeArgsA357 PRE_first_tail_x4_L9_r0_body.sizeSymA357 PRE_first_tail_x4_L9_r0_body.sizeMlxA357 PRE_first_tail_x4_L9_r0_body.sizePayA357 PRE_first_tail_x4_L9_r0_body.sizeTaA357 PRE_first_tail_x4_L9_r0_body.sizeDecA357 PRE_first_tail_x4_L9_r0_body.sizePreA357 PRE_first_tail_x4_L9_r0_body.bodyPatchB357 (fun _ hm => bodyO1377 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1377).trans bodyInactive0) (bodyBr1378.trans bodyBr1377.symm) bodyCnt1377 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) bodyAcc1378 PRE_first_tail_x4_L9_r0_body.bodyRunSeg357 bodyAcc1382 bodyHalt1382 PRE_first_tail_x4_L9_r0_body.bodyStepA358 bodyTop1383 (fun _ hm => bodyO1378 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1378).trans bodyInactive0) (bodyBr1383.trans bodyBr1378.symm) bodyCnt1378 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA358 PRE_first_tail_x4_L9_r0_body.sizeArgsA358 PRE_first_tail_x4_L9_r0_body.sizeSymA358 PRE_first_tail_x4_L9_r0_body.sizeMlxA358 PRE_first_tail_x4_L9_r0_body.sizePayA358 PRE_first_tail_x4_L9_r0_body.sizeTaA358 PRE_first_tail_x4_L9_r0_body.sizeDecA358 PRE_first_tail_x4_L9_r0_body.sizePreA358 PRE_first_tail_x4_L9_r0_body.bodyPatchB358 (fun _ hm => bodyO1383 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1383).trans bodyInactive0) (bodyBr1384.trans bodyBr1383.symm) bodyCnt1383 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) bodyAcc1384 PRE_first_tail_x4_L9_r0_body.bodyRunSeg358 bodyAcc1385 bodyHalt1385 PRE_first_tail_x4_L9_r0_body.bodyStepA359 bodyTop1386 (fun _ hm => bodyO1384 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1384).trans bodyInactive0) (bodyBr1386.trans bodyBr1384.symm) bodyCnt1384 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA359 PRE_first_tail_x4_L9_r0_body.sizeArgsA359 PRE_first_tail_x4_L9_r0_body.sizeSymA359 PRE_first_tail_x4_L9_r0_body.sizeMlxA359 PRE_first_tail_x4_L9_r0_body.sizePayA359 PRE_first_tail_x4_L9_r0_body.sizeTaA359 PRE_first_tail_x4_L9_r0_body.sizeDecA359 PRE_first_tail_x4_L9_r0_body.sizePreA359 PRE_first_tail_x4_L9_r0_body.bodyPatchB359 (fun _ hm => bodyO1386 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1386).trans bodyInactive0) (bodyBr1387.trans bodyBr1386.symm) bodyCnt1386 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) bodyAcc1387 PRE_first_tail_x4_L9_r0_body.bodyRunSeg359 bodyAcc1388 bodyHalt1388 PRE_first_tail_x4_L9_r0_body.bodyStepA360 bodyTop1389 (fun _ hm => bodyO1387 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1387).trans bodyInactive0) (bodyBr1389.trans bodyBr1387.symm) bodyCnt1387 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA360 PRE_first_tail_x4_L9_r0_body.sizeArgsA360 PRE_first_tail_x4_L9_r0_body.sizeSymA360 PRE_first_tail_x4_L9_r0_body.sizeMlxA360 PRE_first_tail_x4_L9_r0_body.sizePayA360 PRE_first_tail_x4_L9_r0_body.sizeTaA360 PRE_first_tail_x4_L9_r0_body.sizeDecA360 PRE_first_tail_x4_L9_r0_body.sizePreA360 PRE_first_tail_x4_L9_r0_body.bodyPatchB360 (fun _ hm => bodyO1389 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1389).trans bodyInactive0) (bodyBr1390.trans bodyBr1389.symm) bodyCnt1389 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) bodyAcc1390 PRE_first_tail_x4_L9_r0_body.bodyRunSeg360 bodyAcc1391 bodyHalt1391 PRE_first_tail_x4_L9_r0_body.bodyStepA361 bodyTop1392 (fun _ hm => bodyO1390 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1390).trans bodyInactive0) (bodyBr1392.trans bodyBr1390.symm) bodyCnt1390 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA361 PRE_first_tail_x4_L9_r0_body.sizeArgsA361 PRE_first_tail_x4_L9_r0_body.sizeSymA361 PRE_first_tail_x4_L9_r0_body.sizeMlxA361 PRE_first_tail_x4_L9_r0_body.sizePayA361 PRE_first_tail_x4_L9_r0_body.sizeTaA361 PRE_first_tail_x4_L9_r0_body.sizeDecA361 PRE_first_tail_x4_L9_r0_body.sizePreA361 PRE_first_tail_x4_L9_r0_body.bodyPatchB361 (fun _ hm => bodyO1392 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1392).trans bodyInactive0) (bodyBr1393.trans bodyBr1392.symm) bodyCnt1392 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63367, 1226, 0, 0⟩) bodyAcc1393 PRE_first_tail_x4_L9_r0_body.bodyRunSeg361 bodyAcc1394 bodyHalt1394 PRE_first_tail_x4_L9_r0_body.bodyStepA362 bodyTop1395 (fun _ hm => bodyO1393 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1393).trans bodyInactive0) (bodyBr1395.trans bodyBr1393.symm) bodyCnt1393 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift62 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S1395.tab.length PRE_first_tail_x4_L9_r0_body.s1395.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P62.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P62 15 PRE_first_tail_x4_L9_r0_body.kappa62 PRE_first_tail_x4_L9_r0_body.s1397.ffi PRE_first_tail_x4_L9_r0_body.s1396.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_62
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_62
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1397.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S1395.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_62] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK62 PRE_first_tail_x4_L9_r0_body.cobjsK62
      PRE_first_tail_x4_L9_r0_body.citemsK62 PRE_first_tail_x4_L9_r0_body.cbd62 PRE_first_tail_x4_L9_r0_body.csst62
  exact PRE_first_tail_x4_L9_r0_body.cshift62 bodyNcl62 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_62] at this; exact this)


kernel_rfl bodyFramesEmpty62 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s1396 a).isEmpty) = true
kernel_rfl bodyJsRoots62 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1395.next) PRE_first_tail_x4_L9_r0_body.s1397.trace PRE_first_tail_x4_L9_r0_body.s1397 = true
kernel_rfl bodyJsNative62 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s1397.ffi) = true
kernel_rfl bodyLow62 : (PRE_first_tail_x4_L9_r0_body.cws62 ++ PRE_first_tail_x4_L9_r0_body.ws62).all (Nat.ble 9) = true
kernel_rfl bodyCntM62 : countersOkB PRE_first_tail_x4_L9_r0_body.s1395 PRE_first_tail_x4_L9_r0_body.s1396 = true
kernel_rfl bodyHi62 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1397.ffi).next setupP.E = true
kernel_rfl bodyNhi62 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1397.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge62 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1396.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s1395.ffi
kernel_rfl bodyNN62 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1395.ffi).nnext PRE_first_tail_x4_L9_r0_body.P62.NL = true
kernel_rfl bodyXn62 : Nat.ble (⟨22068, 19181, 2830290, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s1397.ffi).next = true
kernel_rfl bodyLo62 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s1397.ffi).next = true
theorem bodyFacts62 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s1395 PRE_first_tail_x4_L9_r0_body.s1396 PRE_first_tail_x4_L9_r0_body.s1397 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S1395 PRE_first_tail_x4_L9_r0_body.S1396 PRE_first_tail_x4_L9_r0_body.S1397
    PRE_first_tail_x4_L9_r0_body.ws62 PRE_first_tail_x4_L9_r0_body.cws62 PRE_first_tail_x4_L9_r0_body.nr62 PRE_first_tail_x4_L9_r0_body.pl62 PRE_first_tail_x4_L9_r0_body.cl62 2831439 15 PRE_first_tail_x4_L9_r0_body.kd62 PRE_first_tail_x4_L9_r0_body.kappa62 PRE_first_tail_x4_L9_r0_body.P62
    ⟨22065, 19154, 2830284, 15⟩ ⟨22068, 19181, 2830290, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap62
  clean := bodyClean62
  cfix := PRE_first_tail_x4_L9_r0_body.cfix62
  zpl := PRE_first_tail_x4_L9_r0_body.zpl62
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd62
  zn1 := PRE_first_tail_x4_L9_r0_body.zn162
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst62
  zscn := PRE_first_tail_x4_L9_r0_body.zscn62
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn62
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow62
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab62
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh62
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd62
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi62
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt62
  zgP := PRE_first_tail_x4_L9_r0_body.zg62_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk62_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm62_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg62_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk62_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm62_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw62_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw62_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap62
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd62
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap62 PRE_first_tail_x4_L9_r0_body.stFoot62 PRE_first_tail_x4_L9_r0_body.iso62 PRE_first_tail_x4_L9_r0_body.zwr62
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP62
  csupp := PRE_first_tail_x4_L9_r0_body.csupp62
  cbound := PRE_first_tail_x4_L9_r0_body.cbound62
  zimg := PRE_first_tail_x4_L9_r0_body.zimg62
  zctl := PRE_first_tail_x4_L9_r0_body.zctl62
  zstack := PRE_first_tail_x4_L9_r0_body.zstack62
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs62
  zstores := PRE_first_tail_x4_L9_r0_body.zstores62
  zroots := PRE_first_tail_x4_L9_r0_body.zroots62
  znC := PRE_first_tail_x4_L9_r0_body.znC62
  ctab := PRE_first_tail_x4_L9_r0_body.ctab62
  zbin := PRE_first_tail_x4_L9_r0_body.zbin62
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge62
  sbridge := bodyBridge62
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj62
  cshiftR := fun h hNL => bodyCshift62 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN62
  raised := PRE_first_tail_x4_L9_r0_body.raised62
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs62
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl62
  xnLe := Nat.le_of_ble_eq_true bodyXn62
  loLe := Nat.le_of_ble_eq_true bodyLo62
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB62
  cntM := bodyCntM62
  hiLe := Nat.le_of_ble_eq_true bodyHi62
  nhiLe := Nat.le_of_ble_eq_true bodyNhi62
  jsHeap := bodyJs62
  jsRoots := bodyJsRoots62
  jsNative := bodyJsNative62
  framesEmpty := bodyFramesEmpty62
  trailOld := by decide
  lowVars := bodyLow62

def bodyQs62 : List (Option Q) := []
noncomputable def bodyEs62 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr62.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st62.S5.tab r
kernel_rfl bodyResChk62 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs62 bodyQs62) = true
kernel_rfl bodyLq62 : bodyQs62.length = PRE_first_tail_x4_L9_r0_body.cws62.length
kernel_rfl bodyNrLo62 : PRE_first_tail_x4_L9_r0_body.nr62.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S1395.tab.length) = true
kernel_rfl bodySub62 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site62.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost62 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws62 PRE_first_tail_x4_L9_r0_body.cws62 bodyQs62 = true
kernel_rfl bodyDrop62 : Nat.ble (63367 + (PRE_first_tail_x4_L9_r0_body.s1396.next - PRE_first_tail_x4_L9_r0_body.s1397.next)) 64516 = true
kernel_rfl bodyDropH62 : Nat.ble (1226 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1396.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s1397.ffi).next)) 1251 = true
kernel_rfl bodyDropN62 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1396.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s1397.ffi).nnext)) 0 = true
kernel_rfl bodyDv62 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws62
kernel_rfl bodyDe62 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr62.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st62.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl62 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold62 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws62).isNone && !PRE_first_tail_x4_L9_r0_body.ws62.contains v) = true
kernel_rfl bodyDfree62 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws62 ++ PRE_first_tail_x4_L9_r0_body.ws62).all fun w => e.noVar w) = true

theorem bodyStep62 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨63367, 1226, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1395 PRE_first_tail_x4_L9_r0_body.S1395)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64516, 1251, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1397 PRE_first_tail_x4_L9_r0_body.S1397) (11334 + 1) :=
  bodySite bodyFacts62.cfix bodyFacts62.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st62.S5.tab) (Es := bodyEs62) (qs := bodyQs62)
    (ok := PRE_first_tail_x4_L9_r0_body.st62.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site62 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts62
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site62 r hr) hi (MapOk.sub hm (sub_of_all bodySub62)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk62 r hr) hi hm ho hq)
    bodyLq62 rfl bodyNrLo62 (postSub_sound bodyPost62)
    (Nat.le_of_ble_eq_true bodyDrop62) (by decide) (Nat.le_of_ble_eq_true bodyDropH62) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN62) (by decide)
    bodyDv62 bodyDe62 bodyDl62 bodyDold62 bodyDfree62 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site63 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site63 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site63) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st63.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site63
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st63.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st63.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1416 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s1417 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1416 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws63 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st63.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st63.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso63
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_63
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st63.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot63
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup63
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound63
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace63
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged63
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws63.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st63.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S1416.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_63]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen63.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh63
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl63 : Conv.NClean (⟨22128, 19226, 2832787, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1416.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl63 (PRE_first_tail_x4_L9_r0_body.cncl62 bodyNcl62)

theorem bodyClean63 : Conv.JClean (⟨22128, 19226, 2832787, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s1416 :=
  PRE_first_tail_x4_L9_r0_body.gjcl63 (PRE_first_tail_x4_L9_r0_body.cjcl62 bodyClean62)

kernel_rfl bodyJsLe63 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1395.next PRE_first_tail_x4_L9_r0_body.s1416.next = true
kernel_rfl bodyJsList63 : (PRE_first_tail_x4_L9_r0_body.gjh63 ++ PRE_first_tail_x4_L9_r0_body.cl63).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1416.next) PRE_first_tail_x4_L9_r0_body.s1418) = true
theorem bodyJs63 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s1416.next PRE_first_tail_x4_L9_r0_body.s1418 :=
  JsHeapAbove.glueSite bodyJs62 (Nat.le_of_ble_eq_true bodyJsLe63) PRE_first_tail_x4_L9_r0_body.gjk63 PRE_first_tail_x4_L9_r0_body.gjbd63 PRE_first_tail_x4_L9_r0_body.cheap63 PRE_first_tail_x4_L9_r0_body.zclbd63 bodyJsList63

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1397 : PRE_first_tail_x4_L9_r0_body.S1397.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1397.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1397 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1397.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1397 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1397 PRE_first_tail_x4_L9_r0_body.S1397) = fun _ _ => true
kernel_rfl bodyAcc1398 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1398 PRE_first_tail_x4_L9_r0_body.S1398) = fun _ _ => true
kernel_rfl bodyBr1399 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1399.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1398 : isHalt PRE_first_tail_x4_L9_r0_body.s1398.ctl = false
kernel_rfl bodyTop1399 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1399 = true
kernel_rfl bodyCnt1397 : countersOkB PRE_first_tail_x4_L9_r0_body.s1397 PRE_first_tail_x4_L9_r0_body.s1399 = true
kernel_rfl bodyO1399 : PRE_first_tail_x4_L9_r0_body.S1399.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1399.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1400 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1400.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1399 : countersOkB PRE_first_tail_x4_L9_r0_body.s1399 PRE_first_tail_x4_L9_r0_body.s1400 = true
kernel_rfl bodyO1400 : PRE_first_tail_x4_L9_r0_body.S1400.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1400.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1400 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1400 PRE_first_tail_x4_L9_r0_body.S1400) = fun _ _ => true
kernel_rfl bodyAcc1404 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1404 PRE_first_tail_x4_L9_r0_body.S1404) = fun _ _ => true
kernel_rfl bodyBr1405 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1405.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1404 : isHalt PRE_first_tail_x4_L9_r0_body.s1404.ctl = false
kernel_rfl bodyTop1405 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1405 = true
kernel_rfl bodyCnt1400 : countersOkB PRE_first_tail_x4_L9_r0_body.s1400 PRE_first_tail_x4_L9_r0_body.s1405 = true
kernel_rfl bodyO1405 : PRE_first_tail_x4_L9_r0_body.S1405.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1405.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1406 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1406.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1405 : countersOkB PRE_first_tail_x4_L9_r0_body.s1405 PRE_first_tail_x4_L9_r0_body.s1406 = true
kernel_rfl bodyO1406 : PRE_first_tail_x4_L9_r0_body.S1406.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1406.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1406 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1406 PRE_first_tail_x4_L9_r0_body.S1406) = fun _ _ => true
kernel_rfl bodyAcc1408 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1408 PRE_first_tail_x4_L9_r0_body.S1408) = fun _ _ => true
kernel_rfl bodyBr1409 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1409.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1408 : isHalt PRE_first_tail_x4_L9_r0_body.s1408.ctl = false
kernel_rfl bodyTop1409 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1409 = true
kernel_rfl bodyCnt1406 : countersOkB PRE_first_tail_x4_L9_r0_body.s1406 PRE_first_tail_x4_L9_r0_body.s1409 = true
kernel_rfl bodyO1409 : PRE_first_tail_x4_L9_r0_body.S1409.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1409.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1410 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1410.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1409 : countersOkB PRE_first_tail_x4_L9_r0_body.s1409 PRE_first_tail_x4_L9_r0_body.s1410 = true
kernel_rfl bodyO1410 : PRE_first_tail_x4_L9_r0_body.S1410.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1410.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1410 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1410 PRE_first_tail_x4_L9_r0_body.S1410) = fun _ _ => true
kernel_rfl bodyAcc1411 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1411 PRE_first_tail_x4_L9_r0_body.S1411) = fun _ _ => true
kernel_rfl bodyBr1412 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1412.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1411 : isHalt PRE_first_tail_x4_L9_r0_body.s1411.ctl = false
kernel_rfl bodyTop1412 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1412 = true
kernel_rfl bodyCnt1410 : countersOkB PRE_first_tail_x4_L9_r0_body.s1410 PRE_first_tail_x4_L9_r0_body.s1412 = true
kernel_rfl bodyO1412 : PRE_first_tail_x4_L9_r0_body.S1412.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1412.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1413 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1413.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1412 : countersOkB PRE_first_tail_x4_L9_r0_body.s1412 PRE_first_tail_x4_L9_r0_body.s1413 = true
kernel_rfl bodyO1413 : PRE_first_tail_x4_L9_r0_body.S1413.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1413.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1413 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1413 PRE_first_tail_x4_L9_r0_body.S1413) = fun _ _ => true
kernel_rfl bodyAcc1415 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1415 PRE_first_tail_x4_L9_r0_body.S1415) = fun _ _ => true
kernel_rfl bodyBr1416 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1416.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1415 : isHalt PRE_first_tail_x4_L9_r0_body.s1415.ctl = false
kernel_rfl bodyTop1416 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1416 = true
kernel_rfl bodyCnt1413 : countersOkB PRE_first_tail_x4_L9_r0_body.s1413 PRE_first_tail_x4_L9_r0_body.s1416 = true

theorem bodyGlue63 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64516, 1251, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1397 PRE_first_tail_x4_L9_r0_body.S1397)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64516, 1251, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1416 PRE_first_tail_x4_L9_r0_body.S1416) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) bodyAcc1397 PRE_first_tail_x4_L9_r0_body.bodyRunSeg362 bodyAcc1398 bodyHalt1398 PRE_first_tail_x4_L9_r0_body.bodyStepA363 bodyTop1399 (fun _ hm => bodyO1397 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1397).trans bodyInactive0) (bodyBr1399.trans bodyBr1397.symm) bodyCnt1397 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA363 PRE_first_tail_x4_L9_r0_body.sizeArgsA363 PRE_first_tail_x4_L9_r0_body.sizeSymA363 PRE_first_tail_x4_L9_r0_body.sizeMlxA363 PRE_first_tail_x4_L9_r0_body.sizePayA363 PRE_first_tail_x4_L9_r0_body.sizeTaA363 PRE_first_tail_x4_L9_r0_body.sizeDecA363 PRE_first_tail_x4_L9_r0_body.sizePreA363 PRE_first_tail_x4_L9_r0_body.bodyPatchB363 (fun _ hm => bodyO1399 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1399).trans bodyInactive0) (bodyBr1400.trans bodyBr1399.symm) bodyCnt1399 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) bodyAcc1400 PRE_first_tail_x4_L9_r0_body.bodyRunSeg363 bodyAcc1404 bodyHalt1404 PRE_first_tail_x4_L9_r0_body.bodyStepA364 bodyTop1405 (fun _ hm => bodyO1400 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1400).trans bodyInactive0) (bodyBr1405.trans bodyBr1400.symm) bodyCnt1400 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA364 PRE_first_tail_x4_L9_r0_body.sizeArgsA364 PRE_first_tail_x4_L9_r0_body.sizeSymA364 PRE_first_tail_x4_L9_r0_body.sizeMlxA364 PRE_first_tail_x4_L9_r0_body.sizePayA364 PRE_first_tail_x4_L9_r0_body.sizeTaA364 PRE_first_tail_x4_L9_r0_body.sizeDecA364 PRE_first_tail_x4_L9_r0_body.sizePreA364 PRE_first_tail_x4_L9_r0_body.bodyPatchB364 (fun _ hm => bodyO1405 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1405).trans bodyInactive0) (bodyBr1406.trans bodyBr1405.symm) bodyCnt1405 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) bodyAcc1406 PRE_first_tail_x4_L9_r0_body.bodyRunSeg364 bodyAcc1408 bodyHalt1408 PRE_first_tail_x4_L9_r0_body.bodyStepA365 bodyTop1409 (fun _ hm => bodyO1406 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1406).trans bodyInactive0) (bodyBr1409.trans bodyBr1406.symm) bodyCnt1406 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA365 PRE_first_tail_x4_L9_r0_body.sizeArgsA365 PRE_first_tail_x4_L9_r0_body.sizeSymA365 PRE_first_tail_x4_L9_r0_body.sizeMlxA365 PRE_first_tail_x4_L9_r0_body.sizePayA365 PRE_first_tail_x4_L9_r0_body.sizeTaA365 PRE_first_tail_x4_L9_r0_body.sizeDecA365 PRE_first_tail_x4_L9_r0_body.sizePreA365 PRE_first_tail_x4_L9_r0_body.bodyPatchB365 (fun _ hm => bodyO1409 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1409).trans bodyInactive0) (bodyBr1410.trans bodyBr1409.symm) bodyCnt1409 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) bodyAcc1410 PRE_first_tail_x4_L9_r0_body.bodyRunSeg365 bodyAcc1411 bodyHalt1411 PRE_first_tail_x4_L9_r0_body.bodyStepA366 bodyTop1412 (fun _ hm => bodyO1410 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1410).trans bodyInactive0) (bodyBr1412.trans bodyBr1410.symm) bodyCnt1410 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA366 PRE_first_tail_x4_L9_r0_body.sizeArgsA366 PRE_first_tail_x4_L9_r0_body.sizeSymA366 PRE_first_tail_x4_L9_r0_body.sizeMlxA366 PRE_first_tail_x4_L9_r0_body.sizePayA366 PRE_first_tail_x4_L9_r0_body.sizeTaA366 PRE_first_tail_x4_L9_r0_body.sizeDecA366 PRE_first_tail_x4_L9_r0_body.sizePreA366 PRE_first_tail_x4_L9_r0_body.bodyPatchB366 (fun _ hm => bodyO1412 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1412).trans bodyInactive0) (bodyBr1413.trans bodyBr1412.symm) bodyCnt1412 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64516, 1251, 0, 0⟩) bodyAcc1413 PRE_first_tail_x4_L9_r0_body.bodyRunSeg366 bodyAcc1415 bodyHalt1415 PRE_first_tail_x4_L9_r0_body.bodyStepA367 bodyTop1416 (fun _ hm => bodyO1413 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1413).trans bodyInactive0) (bodyBr1416.trans bodyBr1413.symm) bodyCnt1413 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift63 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S1416.tab.length PRE_first_tail_x4_L9_r0_body.s1416.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P63.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P63 15 PRE_first_tail_x4_L9_r0_body.kappa63 PRE_first_tail_x4_L9_r0_body.s1418.ffi PRE_first_tail_x4_L9_r0_body.s1417.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_63
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_63
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s1418.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S1416.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_63] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK63 PRE_first_tail_x4_L9_r0_body.cobjsK63
      PRE_first_tail_x4_L9_r0_body.citemsK63 PRE_first_tail_x4_L9_r0_body.cbd63 PRE_first_tail_x4_L9_r0_body.csst63
  exact PRE_first_tail_x4_L9_r0_body.cshift63 bodyNcl63 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_63] at this; exact this)


kernel_rfl bodyFramesEmpty63 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s1417 a).isEmpty) = true
kernel_rfl bodyJsRoots63 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s1416.next) PRE_first_tail_x4_L9_r0_body.s1418.trace PRE_first_tail_x4_L9_r0_body.s1418 = true
kernel_rfl bodyJsNative63 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s1418.ffi) = true
kernel_rfl bodyLow63 : (PRE_first_tail_x4_L9_r0_body.cws63 ++ PRE_first_tail_x4_L9_r0_body.ws63).all (Nat.ble 9) = true
kernel_rfl bodyCntM63 : countersOkB PRE_first_tail_x4_L9_r0_body.s1416 PRE_first_tail_x4_L9_r0_body.s1417 = true
kernel_rfl bodyHi63 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1418.ffi).next setupP.E = true
kernel_rfl bodyNhi63 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1418.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge63 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1417.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s1416.ffi
kernel_rfl bodyNN63 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s1416.ffi).nnext PRE_first_tail_x4_L9_r0_body.P63.NL = true
kernel_rfl bodyXn63 : Nat.ble (⟨22132, 19232, 2832802, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s1418.ffi).next = true
kernel_rfl bodyLo63 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s1418.ffi).next = true
theorem bodyFacts63 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s1416 PRE_first_tail_x4_L9_r0_body.s1417 PRE_first_tail_x4_L9_r0_body.s1418 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S1416 PRE_first_tail_x4_L9_r0_body.S1417 PRE_first_tail_x4_L9_r0_body.S1418
    PRE_first_tail_x4_L9_r0_body.ws63 PRE_first_tail_x4_L9_r0_body.cws63 PRE_first_tail_x4_L9_r0_body.nr63 PRE_first_tail_x4_L9_r0_body.pl63 PRE_first_tail_x4_L9_r0_body.cl63 2833152 15 PRE_first_tail_x4_L9_r0_body.kd63 PRE_first_tail_x4_L9_r0_body.kappa63 PRE_first_tail_x4_L9_r0_body.P63
    ⟨22128, 19226, 2832787, 15⟩ ⟨22132, 19232, 2832802, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap63
  clean := bodyClean63
  cfix := PRE_first_tail_x4_L9_r0_body.cfix63
  zpl := PRE_first_tail_x4_L9_r0_body.zpl63
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd63
  zn1 := PRE_first_tail_x4_L9_r0_body.zn163
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst63
  zscn := PRE_first_tail_x4_L9_r0_body.zscn63
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn63
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow63
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab63
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh63
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd63
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi63
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt63
  zgP := PRE_first_tail_x4_L9_r0_body.zg63_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk63_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm63_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg63_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk63_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm63_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw63_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw63_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap63
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd63
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap63 PRE_first_tail_x4_L9_r0_body.stFoot63 PRE_first_tail_x4_L9_r0_body.iso63 PRE_first_tail_x4_L9_r0_body.zwr63
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP63
  csupp := PRE_first_tail_x4_L9_r0_body.csupp63
  cbound := PRE_first_tail_x4_L9_r0_body.cbound63
  zimg := PRE_first_tail_x4_L9_r0_body.zimg63
  zctl := PRE_first_tail_x4_L9_r0_body.zctl63
  zstack := PRE_first_tail_x4_L9_r0_body.zstack63
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs63
  zstores := PRE_first_tail_x4_L9_r0_body.zstores63
  zroots := PRE_first_tail_x4_L9_r0_body.zroots63
  znC := PRE_first_tail_x4_L9_r0_body.znC63
  ctab := PRE_first_tail_x4_L9_r0_body.ctab63
  zbin := PRE_first_tail_x4_L9_r0_body.zbin63
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge63
  sbridge := bodyBridge63
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj63
  cshiftR := fun h hNL => bodyCshift63 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN63
  raised := PRE_first_tail_x4_L9_r0_body.raised63
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs63
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl63
  xnLe := Nat.le_of_ble_eq_true bodyXn63
  loLe := Nat.le_of_ble_eq_true bodyLo63
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB63
  cntM := bodyCntM63
  hiLe := Nat.le_of_ble_eq_true bodyHi63
  nhiLe := Nat.le_of_ble_eq_true bodyNhi63
  jsHeap := bodyJs63
  jsRoots := bodyJsRoots63
  jsNative := bodyJsNative63
  framesEmpty := bodyFramesEmpty63
  trailOld := by decide
  lowVars := bodyLow63

def bodyQs63 : List (Option Q) := []
noncomputable def bodyEs63 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr63.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st63.S3.tab r
kernel_rfl bodyResChk63 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs63 bodyQs63) = true
kernel_rfl bodyLq63 : bodyQs63.length = PRE_first_tail_x4_L9_r0_body.cws63.length
kernel_rfl bodyNrLo63 : PRE_first_tail_x4_L9_r0_body.nr63.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S1416.tab.length) = true
kernel_rfl bodySub63 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site63.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost63 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws63 PRE_first_tail_x4_L9_r0_body.cws63 bodyQs63 = true
kernel_rfl bodyDrop63 : Nat.ble (64516 + (PRE_first_tail_x4_L9_r0_body.s1417.next - PRE_first_tail_x4_L9_r0_body.s1418.next)) 64866 = true
kernel_rfl bodyDropH63 : Nat.ble (1251 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1417.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s1418.ffi).next)) 1253 = true
kernel_rfl bodyDropN63 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s1417.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s1418.ffi).nnext)) 0 = true
kernel_rfl bodyDv63 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws63
kernel_rfl bodyDe63 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr63.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st63.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl63 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold63 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws63).isNone && !PRE_first_tail_x4_L9_r0_body.ws63.contains v) = true
kernel_rfl bodyDfree63 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws63 ++ PRE_first_tail_x4_L9_r0_body.ws63).all fun w => e.noVar w) = true

theorem bodyStep63 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64516, 1251, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1416 PRE_first_tail_x4_L9_r0_body.S1416)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1418 PRE_first_tail_x4_L9_r0_body.S1418) (3452 + 1) :=
  bodySite bodyFacts63.cfix bodyFacts63.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L9_r0_body.st63.S3.tab) (Es := bodyEs63) (qs := bodyQs63)
    (ok := PRE_first_tail_x4_L9_r0_body.st63.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site63 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts63
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site63 r hr) hi (MapOk.sub hm (sub_of_all bodySub63)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk63 r hr) hi hm ho hq)
    bodyLq63 rfl bodyNrLo63 (postSub_sound bodyPost63)
    (Nat.le_of_ble_eq_true bodyDrop63) (by decide) (Nat.le_of_ble_eq_true bodyDropH63) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN63) (by decide)
    bodyDv63 bodyDe63 bodyDl63 bodyDold63 bodyDfree63 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end
