import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.States
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B16
import host.sim.compose.a4b.x4_L8.B0
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B24
import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L8.VWBodyChain
import host.sim.compose.a4b.x4_L8.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B14
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B13
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B17

section -- VWBodyOracles_2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_g8 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g8 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g8) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site8 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site8 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site8) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st8.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g9 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g9 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g9) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site9 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st9.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g10 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g10 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g10) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site10 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site10 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site10) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st10.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g11 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g11 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g11) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site11 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site11 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site11) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st11.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site8 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site8 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site8) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st8.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site8
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st8.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st8.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s194 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s195 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S194 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws8 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st8.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st8.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso8
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_8
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st8.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot8
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup8
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound8
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace8
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged8
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws8.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st8.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S194.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_8]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen8.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh8
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl8 : Conv.NClean (⟨18714, 15778, 2695457, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s194.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl8 (PRE_first_tail_x4_L8_r0_body.cncl7 bodyNcl7)

theorem bodyClean8 : Conv.JClean (⟨18714, 15778, 2695457, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s194 :=
  PRE_first_tail_x4_L8_r0_body.gjcl8 (PRE_first_tail_x4_L8_r0_body.cjcl7 bodyClean7)

kernel_rfl bodyJsLe8 : Nat.ble PRE_first_tail_x4_L8_r0_body.s170.next PRE_first_tail_x4_L8_r0_body.s194.next = true
kernel_rfl bodyJsList8 : (PRE_first_tail_x4_L8_r0_body.gjh8 ++ PRE_first_tail_x4_L8_r0_body.cl8).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s194.next) PRE_first_tail_x4_L8_r0_body.s196) = true
theorem bodyJs8 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s194.next PRE_first_tail_x4_L8_r0_body.s196 :=
  JsHeapAbove.glueSite bodyJs7 (Nat.le_of_ble_eq_true bodyJsLe8) PRE_first_tail_x4_L8_r0_body.gjk8 PRE_first_tail_x4_L8_r0_body.gjbd8 PRE_first_tail_x4_L8_r0_body.cheap8 PRE_first_tail_x4_L8_r0_body.zclbd8 bodyJsList8

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO172 : PRE_first_tail_x4_L8_r0_body.S172.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S172.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr172 : bridgeOf PRE_first_tail_x4_L8_r0_body.s172.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc172 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s172 PRE_first_tail_x4_L8_r0_body.S172) = fun _ _ => true
kernel_rfl bodyAcc175 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s175 PRE_first_tail_x4_L8_r0_body.S175) = fun _ _ => true
kernel_rfl bodyBr176 : bridgeOf PRE_first_tail_x4_L8_r0_body.s176.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt175 : isHalt PRE_first_tail_x4_L8_r0_body.s175.ctl = false
kernel_rfl bodyTop176 : noRetBlock PRE_first_tail_x4_L8_r0_body.s176 = true
kernel_rfl bodyCnt172 : countersOkB PRE_first_tail_x4_L8_r0_body.s172 PRE_first_tail_x4_L8_r0_body.s176 = true
kernel_rfl bodyO176 : PRE_first_tail_x4_L8_r0_body.S176.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S176.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr177 : bridgeOf PRE_first_tail_x4_L8_r0_body.s177.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt176 : countersOkB PRE_first_tail_x4_L8_r0_body.s176 PRE_first_tail_x4_L8_r0_body.s177 = true
kernel_rfl bodyO177 : PRE_first_tail_x4_L8_r0_body.S177.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S177.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc177 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s177 PRE_first_tail_x4_L8_r0_body.S177) = fun _ _ => true
kernel_rfl bodyAcc181 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s181 PRE_first_tail_x4_L8_r0_body.S181) = fun _ _ => true
kernel_rfl bodyBr182 : bridgeOf PRE_first_tail_x4_L8_r0_body.s182.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt181 : isHalt PRE_first_tail_x4_L8_r0_body.s181.ctl = false
kernel_rfl bodyTop182 : noRetBlock PRE_first_tail_x4_L8_r0_body.s182 = true
kernel_rfl bodyCnt177 : countersOkB PRE_first_tail_x4_L8_r0_body.s177 PRE_first_tail_x4_L8_r0_body.s182 = true
kernel_rfl bodyO182 : PRE_first_tail_x4_L8_r0_body.S182.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S182.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr183 : bridgeOf PRE_first_tail_x4_L8_r0_body.s183.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt182 : countersOkB PRE_first_tail_x4_L8_r0_body.s182 PRE_first_tail_x4_L8_r0_body.s183 = true
kernel_rfl bodyO183 : PRE_first_tail_x4_L8_r0_body.S183.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S183.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc183 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s183 PRE_first_tail_x4_L8_r0_body.S183) = fun _ _ => true
kernel_rfl bodyAcc184 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s184 PRE_first_tail_x4_L8_r0_body.S184) = fun _ _ => true
kernel_rfl bodyBr185 : bridgeOf PRE_first_tail_x4_L8_r0_body.s185.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt184 : isHalt PRE_first_tail_x4_L8_r0_body.s184.ctl = false
kernel_rfl bodyTop185 : noRetBlock PRE_first_tail_x4_L8_r0_body.s185 = true
kernel_rfl bodyCnt183 : countersOkB PRE_first_tail_x4_L8_r0_body.s183 PRE_first_tail_x4_L8_r0_body.s185 = true
kernel_rfl bodyO185 : PRE_first_tail_x4_L8_r0_body.S185.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S185.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr186 : bridgeOf PRE_first_tail_x4_L8_r0_body.s186.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt185 : countersOkB PRE_first_tail_x4_L8_r0_body.s185 PRE_first_tail_x4_L8_r0_body.s186 = true
kernel_rfl bodyO186 : PRE_first_tail_x4_L8_r0_body.S186.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S186.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc186 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s186 PRE_first_tail_x4_L8_r0_body.S186) = fun _ _ => true
kernel_rfl bodyAcc187 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s187 PRE_first_tail_x4_L8_r0_body.S187) = fun _ _ => true
kernel_rfl bodyBr188 : bridgeOf PRE_first_tail_x4_L8_r0_body.s188.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt187 : isHalt PRE_first_tail_x4_L8_r0_body.s187.ctl = false
kernel_rfl bodyTop188 : noRetBlock PRE_first_tail_x4_L8_r0_body.s188 = true
kernel_rfl bodyCnt186 : countersOkB PRE_first_tail_x4_L8_r0_body.s186 PRE_first_tail_x4_L8_r0_body.s188 = true
kernel_rfl bodyO188 : PRE_first_tail_x4_L8_r0_body.S188.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S188.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr189 : bridgeOf PRE_first_tail_x4_L8_r0_body.s189.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt188 : countersOkB PRE_first_tail_x4_L8_r0_body.s188 PRE_first_tail_x4_L8_r0_body.s189 = true
kernel_rfl bodyO189 : PRE_first_tail_x4_L8_r0_body.S189.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S189.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc189 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s189 PRE_first_tail_x4_L8_r0_body.S189) = fun _ _ => true
kernel_rfl bodyAcc190 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s190 PRE_first_tail_x4_L8_r0_body.S190) = fun _ _ => true
kernel_rfl bodyBr191 : bridgeOf PRE_first_tail_x4_L8_r0_body.s191.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt190 : isHalt PRE_first_tail_x4_L8_r0_body.s190.ctl = false
kernel_rfl bodyTop191 : noRetBlock PRE_first_tail_x4_L8_r0_body.s191 = true
kernel_rfl bodyCnt189 : countersOkB PRE_first_tail_x4_L8_r0_body.s189 PRE_first_tail_x4_L8_r0_body.s191 = true
kernel_rfl bodyO191 : PRE_first_tail_x4_L8_r0_body.S191.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S191.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr192 : bridgeOf PRE_first_tail_x4_L8_r0_body.s192.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt191 : countersOkB PRE_first_tail_x4_L8_r0_body.s191 PRE_first_tail_x4_L8_r0_body.s192 = true
kernel_rfl bodyO192 : PRE_first_tail_x4_L8_r0_body.S192.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S192.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc192 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s192 PRE_first_tail_x4_L8_r0_body.S192) = fun _ _ => true
kernel_rfl bodyAcc193 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s193 PRE_first_tail_x4_L8_r0_body.S193) = fun _ _ => true
kernel_rfl bodyBr194 : bridgeOf PRE_first_tail_x4_L8_r0_body.s194.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt193 : isHalt PRE_first_tail_x4_L8_r0_body.s193.ctl = false
kernel_rfl bodyTop194 : noRetBlock PRE_first_tail_x4_L8_r0_body.s194 = true
kernel_rfl bodyCnt192 : countersOkB PRE_first_tail_x4_L8_r0_body.s192 PRE_first_tail_x4_L8_r0_body.s194 = true

theorem bodyGlue8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s172 PRE_first_tail_x4_L8_r0_body.S172)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s194 PRE_first_tail_x4_L8_r0_body.S194) 30538 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) bodyAcc172 PRE_first_tail_x4_L8_r0_body.bodyRunSeg45 bodyAcc175 bodyHalt175 PRE_first_tail_x4_L8_r0_body.bodyStepA46 bodyTop176 (fun _ hm => bodyO172 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr172).trans bodyInactive0) (bodyBr176.trans bodyBr172.symm) bodyCnt172 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA46 PRE_first_tail_x4_L8_r0_body.sizeArgsA46 PRE_first_tail_x4_L8_r0_body.sizeSymA46 PRE_first_tail_x4_L8_r0_body.sizeMlxA46 PRE_first_tail_x4_L8_r0_body.sizePayA46 PRE_first_tail_x4_L8_r0_body.sizeTaA46 PRE_first_tail_x4_L8_r0_body.sizeDecA46 PRE_first_tail_x4_L8_r0_body.sizePreA46 PRE_first_tail_x4_L8_r0_body.bodyPatchB46 (fun _ hm => bodyO176 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr176).trans bodyInactive0) (bodyBr177.trans bodyBr176.symm) bodyCnt176 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) bodyAcc177 PRE_first_tail_x4_L8_r0_body.bodyRunSeg46 bodyAcc181 bodyHalt181 PRE_first_tail_x4_L8_r0_body.bodyStepA47 bodyTop182 (fun _ hm => bodyO177 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr177).trans bodyInactive0) (bodyBr182.trans bodyBr177.symm) bodyCnt177 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA47 PRE_first_tail_x4_L8_r0_body.sizeArgsA47 PRE_first_tail_x4_L8_r0_body.sizeSymA47 PRE_first_tail_x4_L8_r0_body.sizeMlxA47 PRE_first_tail_x4_L8_r0_body.sizePayA47 PRE_first_tail_x4_L8_r0_body.sizeTaA47 PRE_first_tail_x4_L8_r0_body.sizeDecA47 PRE_first_tail_x4_L8_r0_body.sizePreA47 PRE_first_tail_x4_L8_r0_body.bodyPatchB47 (fun _ hm => bodyO182 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr182).trans bodyInactive0) (bodyBr183.trans bodyBr182.symm) bodyCnt182 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) bodyAcc183 PRE_first_tail_x4_L8_r0_body.bodyRunSeg47 bodyAcc184 bodyHalt184 PRE_first_tail_x4_L8_r0_body.bodyStepA48 bodyTop185 (fun _ hm => bodyO183 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr183).trans bodyInactive0) (bodyBr185.trans bodyBr183.symm) bodyCnt183 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA48 PRE_first_tail_x4_L8_r0_body.sizeArgsA48 PRE_first_tail_x4_L8_r0_body.sizeSymA48 PRE_first_tail_x4_L8_r0_body.sizeMlxA48 PRE_first_tail_x4_L8_r0_body.sizePayA48 PRE_first_tail_x4_L8_r0_body.sizeTaA48 PRE_first_tail_x4_L8_r0_body.sizeDecA48 PRE_first_tail_x4_L8_r0_body.sizePreA48 PRE_first_tail_x4_L8_r0_body.bodyPatchB48 (fun _ hm => bodyO185 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr185).trans bodyInactive0) (bodyBr186.trans bodyBr185.symm) bodyCnt185 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) bodyAcc186 PRE_first_tail_x4_L8_r0_body.bodyRunSeg48 bodyAcc187 bodyHalt187 PRE_first_tail_x4_L8_r0_body.bodyStepA49 bodyTop188 (fun _ hm => bodyO186 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr186).trans bodyInactive0) (bodyBr188.trans bodyBr186.symm) bodyCnt186 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA49 PRE_first_tail_x4_L8_r0_body.sizeArgsA49 PRE_first_tail_x4_L8_r0_body.sizeSymA49 PRE_first_tail_x4_L8_r0_body.sizeMlxA49 PRE_first_tail_x4_L8_r0_body.sizePayA49 PRE_first_tail_x4_L8_r0_body.sizeTaA49 PRE_first_tail_x4_L8_r0_body.sizeDecA49 PRE_first_tail_x4_L8_r0_body.sizePreA49 PRE_first_tail_x4_L8_r0_body.bodyPatchB49 (fun _ hm => bodyO188 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr188).trans bodyInactive0) (bodyBr189.trans bodyBr188.symm) bodyCnt188 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) bodyAcc189 PRE_first_tail_x4_L8_r0_body.bodyRunSeg49 bodyAcc190 bodyHalt190 PRE_first_tail_x4_L8_r0_body.bodyStepA50 bodyTop191 (fun _ hm => bodyO189 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr189).trans bodyInactive0) (bodyBr191.trans bodyBr189.symm) bodyCnt189 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA50 PRE_first_tail_x4_L8_r0_body.sizeArgsA50 PRE_first_tail_x4_L8_r0_body.sizeSymA50 PRE_first_tail_x4_L8_r0_body.sizeMlxA50 PRE_first_tail_x4_L8_r0_body.sizePayA50 PRE_first_tail_x4_L8_r0_body.sizeTaA50 PRE_first_tail_x4_L8_r0_body.sizeDecA50 PRE_first_tail_x4_L8_r0_body.sizePreA50 PRE_first_tail_x4_L8_r0_body.bodyPatchB50 (fun _ hm => bodyO191 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr191).trans bodyInactive0) (bodyBr192.trans bodyBr191.symm) bodyCnt191 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11708, 175, 0, 0⟩) bodyAcc192 PRE_first_tail_x4_L8_r0_body.bodyRunSeg50 bodyAcc193 bodyHalt193 PRE_first_tail_x4_L8_r0_body.bodyStepA51 bodyTop194 (fun _ hm => bodyO192 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr192).trans bodyInactive0) (bodyBr194.trans bodyBr192.symm) bodyCnt192 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift8 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S194.tab.length PRE_first_tail_x4_L8_r0_body.s194.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P8.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P8 15 PRE_first_tail_x4_L8_r0_body.kappa8 PRE_first_tail_x4_L8_r0_body.s196.ffi PRE_first_tail_x4_L8_r0_body.s195.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_8
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_8
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s196.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S194.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_8] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK8 PRE_first_tail_x4_L8_r0_body.cobjsK8
      PRE_first_tail_x4_L8_r0_body.citemsK8 PRE_first_tail_x4_L8_r0_body.cbd8 PRE_first_tail_x4_L8_r0_body.csst8
  exact PRE_first_tail_x4_L8_r0_body.cshift8 bodyNcl8 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_8] at this; exact this)


kernel_rfl bodyFramesEmpty8 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s195 a).isEmpty) = true
kernel_rfl bodyJsRoots8 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s194.next) PRE_first_tail_x4_L8_r0_body.s196.trace PRE_first_tail_x4_L8_r0_body.s196 = true
kernel_rfl bodyJsNative8 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s196.ffi) = true
kernel_rfl bodyLow8 : (PRE_first_tail_x4_L8_r0_body.cws8 ++ PRE_first_tail_x4_L8_r0_body.ws8).all (Nat.ble 9) = true
kernel_rfl bodyCntM8 : countersOkB PRE_first_tail_x4_L8_r0_body.s194 PRE_first_tail_x4_L8_r0_body.s195 = true
kernel_rfl bodyHi8 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s196.ffi).next setupP.E = true
kernel_rfl bodyNhi8 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s196.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge8 : bridgeOf PRE_first_tail_x4_L8_r0_body.s195.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s194.ffi
kernel_rfl bodyNN8 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s194.ffi).nnext PRE_first_tail_x4_L8_r0_body.P8.NL = true
kernel_rfl bodyXn8 : Nat.ble (⟨18717, 15805, 2695463, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s196.ffi).next = true
kernel_rfl bodyLo8 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s196.ffi).next = true
theorem bodyFacts8 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s194 PRE_first_tail_x4_L8_r0_body.s195 PRE_first_tail_x4_L8_r0_body.s196 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S194 PRE_first_tail_x4_L8_r0_body.S195 PRE_first_tail_x4_L8_r0_body.S196
    PRE_first_tail_x4_L8_r0_body.ws8 PRE_first_tail_x4_L8_r0_body.cws8 PRE_first_tail_x4_L8_r0_body.nr8 PRE_first_tail_x4_L8_r0_body.pl8 PRE_first_tail_x4_L8_r0_body.cl8 2696612 15 PRE_first_tail_x4_L8_r0_body.kd8 PRE_first_tail_x4_L8_r0_body.kappa8 PRE_first_tail_x4_L8_r0_body.P8
    ⟨18714, 15778, 2695457, 15⟩ ⟨18717, 15805, 2695463, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap8
  clean := bodyClean8
  cfix := PRE_first_tail_x4_L8_r0_body.cfix8
  zpl := PRE_first_tail_x4_L8_r0_body.zpl8
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd8
  zn1 := PRE_first_tail_x4_L8_r0_body.zn18
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst8
  zscn := PRE_first_tail_x4_L8_r0_body.zscn8
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn8
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow8
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab8
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh8
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd8
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi8
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt8
  zgP := PRE_first_tail_x4_L8_r0_body.zg8_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk8_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm8_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg8_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk8_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm8_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw8_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw8_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap8
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd8
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap8 PRE_first_tail_x4_L8_r0_body.stFoot8 PRE_first_tail_x4_L8_r0_body.iso8 PRE_first_tail_x4_L8_r0_body.zwr8
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP8
  csupp := PRE_first_tail_x4_L8_r0_body.csupp8
  cbound := PRE_first_tail_x4_L8_r0_body.cbound8
  zimg := PRE_first_tail_x4_L8_r0_body.zimg8
  zctl := PRE_first_tail_x4_L8_r0_body.zctl8
  zstack := PRE_first_tail_x4_L8_r0_body.zstack8
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs8
  zstores := PRE_first_tail_x4_L8_r0_body.zstores8
  zroots := PRE_first_tail_x4_L8_r0_body.zroots8
  znC := PRE_first_tail_x4_L8_r0_body.znC8
  ctab := PRE_first_tail_x4_L8_r0_body.ctab8
  zbin := PRE_first_tail_x4_L8_r0_body.zbin8
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge8
  sbridge := bodyBridge8
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj8
  cshiftR := fun h hNL => bodyCshift8 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN8
  raised := PRE_first_tail_x4_L8_r0_body.raised8
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs8
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl8
  xnLe := Nat.le_of_ble_eq_true bodyXn8
  loLe := Nat.le_of_ble_eq_true bodyLo8
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB8
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
noncomputable def bodyEs8 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr8.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st8.S5.tab r
kernel_rfl bodyResChk8 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs8 bodyQs8) = true
kernel_rfl bodyLq8 : bodyQs8.length = PRE_first_tail_x4_L8_r0_body.cws8.length
kernel_rfl bodyNrLo8 : PRE_first_tail_x4_L8_r0_body.nr8.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S194.tab.length) = true
kernel_rfl bodySub8 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site8.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost8 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws8 PRE_first_tail_x4_L8_r0_body.cws8 bodyQs8 = true
kernel_rfl bodyDrop8 : Nat.ble (11708 + (PRE_first_tail_x4_L8_r0_body.s195.next - PRE_first_tail_x4_L8_r0_body.s196.next)) 12857 = true
kernel_rfl bodyDropH8 : Nat.ble (175 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s195.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s196.ffi).next)) 200 = true
kernel_rfl bodyDropN8 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s195.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s196.ffi).nnext)) 0 = true
kernel_rfl bodyDv8 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws8
kernel_rfl bodyDe8 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr8.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st8.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl8 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold8 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws8).isNone && !PRE_first_tail_x4_L8_r0_body.ws8.contains v) = true
kernel_rfl bodyDfree8 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws8 ++ PRE_first_tail_x4_L8_r0_body.ws8).all fun w => e.noVar w) = true

theorem bodyStep8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11708, 175, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s194 PRE_first_tail_x4_L8_r0_body.S194)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s196 PRE_first_tail_x4_L8_r0_body.S196) (11334 + 1) :=
  bodySite bodyFacts8.cfix bodyFacts8.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st8.S5.tab) (Es := bodyEs8) (qs := bodyQs8)
    (ok := PRE_first_tail_x4_L8_r0_body.st8.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site8 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts8
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site8 r hr) hi (MapOk.sub hm (sub_of_all bodySub8)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk8 r hr) hi hm ho hq)
    bodyLq8 rfl bodyNrLo8 (postSub_sound bodyPost8)
    (Nat.le_of_ble_eq_true bodyDrop8) (by decide) (Nat.le_of_ble_eq_true bodyDropH8) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN8) (by decide)
    bodyDv8 bodyDe8 bodyDl8 bodyDold8 bodyDfree8 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site9 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site9 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site9) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st9.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site9
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st9.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st9.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s216 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s217 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S216 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws9 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st9.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st9.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso9
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_9
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st9.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot9
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup9
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound9
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace9
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged9
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws9.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st9.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S216.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_9]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen9.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh9
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl9 : Conv.NClean (⟨18771, 15841, 2697695, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s216.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl9 (PRE_first_tail_x4_L8_r0_body.cncl8 bodyNcl8)

theorem bodyClean9 : Conv.JClean (⟨18771, 15841, 2697695, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s216 :=
  PRE_first_tail_x4_L8_r0_body.gjcl9 (PRE_first_tail_x4_L8_r0_body.cjcl8 bodyClean8)

kernel_rfl bodyJsLe9 : Nat.ble PRE_first_tail_x4_L8_r0_body.s194.next PRE_first_tail_x4_L8_r0_body.s216.next = true
kernel_rfl bodyJsList9 : (PRE_first_tail_x4_L8_r0_body.gjh9 ++ PRE_first_tail_x4_L8_r0_body.cl9).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s216.next) PRE_first_tail_x4_L8_r0_body.s218) = true
theorem bodyJs9 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s216.next PRE_first_tail_x4_L8_r0_body.s218 :=
  JsHeapAbove.glueSite bodyJs8 (Nat.le_of_ble_eq_true bodyJsLe9) PRE_first_tail_x4_L8_r0_body.gjk9 PRE_first_tail_x4_L8_r0_body.gjbd9 PRE_first_tail_x4_L8_r0_body.cheap9 PRE_first_tail_x4_L8_r0_body.zclbd9 bodyJsList9

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO196 : PRE_first_tail_x4_L8_r0_body.S196.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S196.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr196 : bridgeOf PRE_first_tail_x4_L8_r0_body.s196.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc196 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s196 PRE_first_tail_x4_L8_r0_body.S196) = fun _ _ => true
kernel_rfl bodyAcc197 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s197 PRE_first_tail_x4_L8_r0_body.S197) = fun _ _ => true
kernel_rfl bodyBr198 : bridgeOf PRE_first_tail_x4_L8_r0_body.s198.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt197 : isHalt PRE_first_tail_x4_L8_r0_body.s197.ctl = false
kernel_rfl bodyTop198 : noRetBlock PRE_first_tail_x4_L8_r0_body.s198 = true
kernel_rfl bodyCnt196 : countersOkB PRE_first_tail_x4_L8_r0_body.s196 PRE_first_tail_x4_L8_r0_body.s198 = true
kernel_rfl bodyO198 : PRE_first_tail_x4_L8_r0_body.S198.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S198.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr199 : bridgeOf PRE_first_tail_x4_L8_r0_body.s199.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt198 : countersOkB PRE_first_tail_x4_L8_r0_body.s198 PRE_first_tail_x4_L8_r0_body.s199 = true
kernel_rfl bodyO199 : PRE_first_tail_x4_L8_r0_body.S199.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S199.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc199 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s199 PRE_first_tail_x4_L8_r0_body.S199) = fun _ _ => true
kernel_rfl bodyAcc203 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s203 PRE_first_tail_x4_L8_r0_body.S203) = fun _ _ => true
kernel_rfl bodyBr204 : bridgeOf PRE_first_tail_x4_L8_r0_body.s204.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt203 : isHalt PRE_first_tail_x4_L8_r0_body.s203.ctl = false
kernel_rfl bodyTop204 : noRetBlock PRE_first_tail_x4_L8_r0_body.s204 = true
kernel_rfl bodyCnt199 : countersOkB PRE_first_tail_x4_L8_r0_body.s199 PRE_first_tail_x4_L8_r0_body.s204 = true
kernel_rfl bodyO204 : PRE_first_tail_x4_L8_r0_body.S204.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S204.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr205 : bridgeOf PRE_first_tail_x4_L8_r0_body.s205.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt204 : countersOkB PRE_first_tail_x4_L8_r0_body.s204 PRE_first_tail_x4_L8_r0_body.s205 = true
kernel_rfl bodyO205 : PRE_first_tail_x4_L8_r0_body.S205.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S205.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc205 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s205 PRE_first_tail_x4_L8_r0_body.S205) = fun _ _ => true
kernel_rfl bodyAcc206 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s206 PRE_first_tail_x4_L8_r0_body.S206) = fun _ _ => true
kernel_rfl bodyBr207 : bridgeOf PRE_first_tail_x4_L8_r0_body.s207.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt206 : isHalt PRE_first_tail_x4_L8_r0_body.s206.ctl = false
kernel_rfl bodyTop207 : noRetBlock PRE_first_tail_x4_L8_r0_body.s207 = true
kernel_rfl bodyCnt205 : countersOkB PRE_first_tail_x4_L8_r0_body.s205 PRE_first_tail_x4_L8_r0_body.s207 = true
kernel_rfl bodyO207 : PRE_first_tail_x4_L8_r0_body.S207.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S207.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr208 : bridgeOf PRE_first_tail_x4_L8_r0_body.s208.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt207 : countersOkB PRE_first_tail_x4_L8_r0_body.s207 PRE_first_tail_x4_L8_r0_body.s208 = true
kernel_rfl bodyO208 : PRE_first_tail_x4_L8_r0_body.S208.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S208.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc208 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s208 PRE_first_tail_x4_L8_r0_body.S208) = fun _ _ => true
kernel_rfl bodyAcc209 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s209 PRE_first_tail_x4_L8_r0_body.S209) = fun _ _ => true
kernel_rfl bodyBr210 : bridgeOf PRE_first_tail_x4_L8_r0_body.s210.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt209 : isHalt PRE_first_tail_x4_L8_r0_body.s209.ctl = false
kernel_rfl bodyTop210 : noRetBlock PRE_first_tail_x4_L8_r0_body.s210 = true
kernel_rfl bodyCnt208 : countersOkB PRE_first_tail_x4_L8_r0_body.s208 PRE_first_tail_x4_L8_r0_body.s210 = true
kernel_rfl bodyO210 : PRE_first_tail_x4_L8_r0_body.S210.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S210.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr211 : bridgeOf PRE_first_tail_x4_L8_r0_body.s211.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt210 : countersOkB PRE_first_tail_x4_L8_r0_body.s210 PRE_first_tail_x4_L8_r0_body.s211 = true
kernel_rfl bodyO211 : PRE_first_tail_x4_L8_r0_body.S211.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S211.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc211 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s211 PRE_first_tail_x4_L8_r0_body.S211) = fun _ _ => true
kernel_rfl bodyAcc212 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s212 PRE_first_tail_x4_L8_r0_body.S212) = fun _ _ => true
kernel_rfl bodyBr213 : bridgeOf PRE_first_tail_x4_L8_r0_body.s213.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt212 : isHalt PRE_first_tail_x4_L8_r0_body.s212.ctl = false
kernel_rfl bodyTop213 : noRetBlock PRE_first_tail_x4_L8_r0_body.s213 = true
kernel_rfl bodyCnt211 : countersOkB PRE_first_tail_x4_L8_r0_body.s211 PRE_first_tail_x4_L8_r0_body.s213 = true
kernel_rfl bodyO213 : PRE_first_tail_x4_L8_r0_body.S213.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S213.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr214 : bridgeOf PRE_first_tail_x4_L8_r0_body.s214.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt213 : countersOkB PRE_first_tail_x4_L8_r0_body.s213 PRE_first_tail_x4_L8_r0_body.s214 = true
kernel_rfl bodyO214 : PRE_first_tail_x4_L8_r0_body.S214.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S214.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc214 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s214 PRE_first_tail_x4_L8_r0_body.S214) = fun _ _ => true
kernel_rfl bodyAcc215 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s215 PRE_first_tail_x4_L8_r0_body.S215) = fun _ _ => true
kernel_rfl bodyBr216 : bridgeOf PRE_first_tail_x4_L8_r0_body.s216.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt215 : isHalt PRE_first_tail_x4_L8_r0_body.s215.ctl = false
kernel_rfl bodyTop216 : noRetBlock PRE_first_tail_x4_L8_r0_body.s216 = true
kernel_rfl bodyCnt214 : countersOkB PRE_first_tail_x4_L8_r0_body.s214 PRE_first_tail_x4_L8_r0_body.s216 = true

theorem bodyGlue9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s196 PRE_first_tail_x4_L8_r0_body.S196)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s216 PRE_first_tail_x4_L8_r0_body.S216) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) bodyAcc196 PRE_first_tail_x4_L8_r0_body.bodyRunSeg51 bodyAcc197 bodyHalt197 PRE_first_tail_x4_L8_r0_body.bodyStepA52 bodyTop198 (fun _ hm => bodyO196 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr196).trans bodyInactive0) (bodyBr198.trans bodyBr196.symm) bodyCnt196 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA52 PRE_first_tail_x4_L8_r0_body.sizeArgsA52 PRE_first_tail_x4_L8_r0_body.sizeSymA52 PRE_first_tail_x4_L8_r0_body.sizeMlxA52 PRE_first_tail_x4_L8_r0_body.sizePayA52 PRE_first_tail_x4_L8_r0_body.sizeTaA52 PRE_first_tail_x4_L8_r0_body.sizeDecA52 PRE_first_tail_x4_L8_r0_body.sizePreA52 PRE_first_tail_x4_L8_r0_body.bodyPatchB52 (fun _ hm => bodyO198 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr198).trans bodyInactive0) (bodyBr199.trans bodyBr198.symm) bodyCnt198 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) bodyAcc199 PRE_first_tail_x4_L8_r0_body.bodyRunSeg52 bodyAcc203 bodyHalt203 PRE_first_tail_x4_L8_r0_body.bodyStepA53 bodyTop204 (fun _ hm => bodyO199 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr199).trans bodyInactive0) (bodyBr204.trans bodyBr199.symm) bodyCnt199 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA53 PRE_first_tail_x4_L8_r0_body.sizeArgsA53 PRE_first_tail_x4_L8_r0_body.sizeSymA53 PRE_first_tail_x4_L8_r0_body.sizeMlxA53 PRE_first_tail_x4_L8_r0_body.sizePayA53 PRE_first_tail_x4_L8_r0_body.sizeTaA53 PRE_first_tail_x4_L8_r0_body.sizeDecA53 PRE_first_tail_x4_L8_r0_body.sizePreA53 PRE_first_tail_x4_L8_r0_body.bodyPatchB53 (fun _ hm => bodyO204 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr204).trans bodyInactive0) (bodyBr205.trans bodyBr204.symm) bodyCnt204 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) bodyAcc205 PRE_first_tail_x4_L8_r0_body.bodyRunSeg53 bodyAcc206 bodyHalt206 PRE_first_tail_x4_L8_r0_body.bodyStepA54 bodyTop207 (fun _ hm => bodyO205 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr205).trans bodyInactive0) (bodyBr207.trans bodyBr205.symm) bodyCnt205 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA54 PRE_first_tail_x4_L8_r0_body.sizeArgsA54 PRE_first_tail_x4_L8_r0_body.sizeSymA54 PRE_first_tail_x4_L8_r0_body.sizeMlxA54 PRE_first_tail_x4_L8_r0_body.sizePayA54 PRE_first_tail_x4_L8_r0_body.sizeTaA54 PRE_first_tail_x4_L8_r0_body.sizeDecA54 PRE_first_tail_x4_L8_r0_body.sizePreA54 PRE_first_tail_x4_L8_r0_body.bodyPatchB54 (fun _ hm => bodyO207 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr207).trans bodyInactive0) (bodyBr208.trans bodyBr207.symm) bodyCnt207 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) bodyAcc208 PRE_first_tail_x4_L8_r0_body.bodyRunSeg54 bodyAcc209 bodyHalt209 PRE_first_tail_x4_L8_r0_body.bodyStepA55 bodyTop210 (fun _ hm => bodyO208 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr208).trans bodyInactive0) (bodyBr210.trans bodyBr208.symm) bodyCnt208 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA55 PRE_first_tail_x4_L8_r0_body.sizeArgsA55 PRE_first_tail_x4_L8_r0_body.sizeSymA55 PRE_first_tail_x4_L8_r0_body.sizeMlxA55 PRE_first_tail_x4_L8_r0_body.sizePayA55 PRE_first_tail_x4_L8_r0_body.sizeTaA55 PRE_first_tail_x4_L8_r0_body.sizeDecA55 PRE_first_tail_x4_L8_r0_body.sizePreA55 PRE_first_tail_x4_L8_r0_body.bodyPatchB55 (fun _ hm => bodyO210 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr210).trans bodyInactive0) (bodyBr211.trans bodyBr210.symm) bodyCnt210 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) bodyAcc211 PRE_first_tail_x4_L8_r0_body.bodyRunSeg55 bodyAcc212 bodyHalt212 PRE_first_tail_x4_L8_r0_body.bodyStepA56 bodyTop213 (fun _ hm => bodyO211 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr211).trans bodyInactive0) (bodyBr213.trans bodyBr211.symm) bodyCnt211 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA56 PRE_first_tail_x4_L8_r0_body.sizeArgsA56 PRE_first_tail_x4_L8_r0_body.sizeSymA56 PRE_first_tail_x4_L8_r0_body.sizeMlxA56 PRE_first_tail_x4_L8_r0_body.sizePayA56 PRE_first_tail_x4_L8_r0_body.sizeTaA56 PRE_first_tail_x4_L8_r0_body.sizeDecA56 PRE_first_tail_x4_L8_r0_body.sizePreA56 PRE_first_tail_x4_L8_r0_body.bodyPatchB56 (fun _ hm => bodyO213 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr213).trans bodyInactive0) (bodyBr214.trans bodyBr213.symm) bodyCnt213 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12857, 200, 0, 0⟩) bodyAcc214 PRE_first_tail_x4_L8_r0_body.bodyRunSeg56 bodyAcc215 bodyHalt215 PRE_first_tail_x4_L8_r0_body.bodyStepA57 bodyTop216 (fun _ hm => bodyO214 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr214).trans bodyInactive0) (bodyBr216.trans bodyBr214.symm) bodyCnt214 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift9 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S216.tab.length PRE_first_tail_x4_L8_r0_body.s216.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P9.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P9 15 PRE_first_tail_x4_L8_r0_body.kappa9 PRE_first_tail_x4_L8_r0_body.s218.ffi PRE_first_tail_x4_L8_r0_body.s217.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_9
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_9
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s218.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S216.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_9] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK9 PRE_first_tail_x4_L8_r0_body.cobjsK9
      PRE_first_tail_x4_L8_r0_body.citemsK9 PRE_first_tail_x4_L8_r0_body.cbd9 PRE_first_tail_x4_L8_r0_body.csst9
  exact PRE_first_tail_x4_L8_r0_body.cshift9 bodyNcl9 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_9] at this; exact this)


kernel_rfl bodyFramesEmpty9 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s217 a).isEmpty) = true
kernel_rfl bodyJsRoots9 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s216.next) PRE_first_tail_x4_L8_r0_body.s218.trace PRE_first_tail_x4_L8_r0_body.s218 = true
kernel_rfl bodyJsNative9 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s218.ffi) = true
kernel_rfl bodyLow9 : (PRE_first_tail_x4_L8_r0_body.cws9 ++ PRE_first_tail_x4_L8_r0_body.ws9).all (Nat.ble 9) = true
kernel_rfl bodyCntM9 : countersOkB PRE_first_tail_x4_L8_r0_body.s216 PRE_first_tail_x4_L8_r0_body.s217 = true
kernel_rfl bodyHi9 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s218.ffi).next setupP.E = true
kernel_rfl bodyNhi9 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s218.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge9 : bridgeOf PRE_first_tail_x4_L8_r0_body.s217.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s216.ffi
kernel_rfl bodyNN9 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s216.ffi).nnext PRE_first_tail_x4_L8_r0_body.P9.NL = true
kernel_rfl bodyXn9 : Nat.ble (⟨18774, 15868, 2697701, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s218.ffi).next = true
kernel_rfl bodyLo9 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s218.ffi).next = true
theorem bodyFacts9 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s216 PRE_first_tail_x4_L8_r0_body.s217 PRE_first_tail_x4_L8_r0_body.s218 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S216 PRE_first_tail_x4_L8_r0_body.S217 PRE_first_tail_x4_L8_r0_body.S218
    PRE_first_tail_x4_L8_r0_body.ws9 PRE_first_tail_x4_L8_r0_body.cws9 PRE_first_tail_x4_L8_r0_body.nr9 PRE_first_tail_x4_L8_r0_body.pl9 PRE_first_tail_x4_L8_r0_body.cl9 2698850 15 PRE_first_tail_x4_L8_r0_body.kd9 PRE_first_tail_x4_L8_r0_body.kappa9 PRE_first_tail_x4_L8_r0_body.P9
    ⟨18771, 15841, 2697695, 15⟩ ⟨18774, 15868, 2697701, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap9
  clean := bodyClean9
  cfix := PRE_first_tail_x4_L8_r0_body.cfix9
  zpl := PRE_first_tail_x4_L8_r0_body.zpl9
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd9
  zn1 := PRE_first_tail_x4_L8_r0_body.zn19
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst9
  zscn := PRE_first_tail_x4_L8_r0_body.zscn9
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn9
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow9
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab9
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh9
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd9
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi9
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt9
  zgP := PRE_first_tail_x4_L8_r0_body.zg9_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk9_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm9_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg9_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk9_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm9_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw9_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw9_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap9
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd9
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap9 PRE_first_tail_x4_L8_r0_body.stFoot9 PRE_first_tail_x4_L8_r0_body.iso9 PRE_first_tail_x4_L8_r0_body.zwr9
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP9
  csupp := PRE_first_tail_x4_L8_r0_body.csupp9
  cbound := PRE_first_tail_x4_L8_r0_body.cbound9
  zimg := PRE_first_tail_x4_L8_r0_body.zimg9
  zctl := PRE_first_tail_x4_L8_r0_body.zctl9
  zstack := PRE_first_tail_x4_L8_r0_body.zstack9
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs9
  zstores := PRE_first_tail_x4_L8_r0_body.zstores9
  zroots := PRE_first_tail_x4_L8_r0_body.zroots9
  znC := PRE_first_tail_x4_L8_r0_body.znC9
  ctab := PRE_first_tail_x4_L8_r0_body.ctab9
  zbin := PRE_first_tail_x4_L8_r0_body.zbin9
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge9
  sbridge := bodyBridge9
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj9
  cshiftR := fun h hNL => bodyCshift9 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN9
  raised := PRE_first_tail_x4_L8_r0_body.raised9
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs9
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl9
  xnLe := Nat.le_of_ble_eq_true bodyXn9
  loLe := Nat.le_of_ble_eq_true bodyLo9
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB9
  cntM := bodyCntM9
  hiLe := Nat.le_of_ble_eq_true bodyHi9
  nhiLe := Nat.le_of_ble_eq_true bodyNhi9
  jsHeap := bodyJs9
  jsRoots := bodyJsRoots9
  jsNative := bodyJsNative9
  framesEmpty := bodyFramesEmpty9
  trailOld := by decide
  lowVars := bodyLow9

def bodyQs9 : List (Option Q) := []
noncomputable def bodyEs9 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr9.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st9.S5.tab r
kernel_rfl bodyResChk9 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs9 bodyQs9) = true
kernel_rfl bodyLq9 : bodyQs9.length = PRE_first_tail_x4_L8_r0_body.cws9.length
kernel_rfl bodyNrLo9 : PRE_first_tail_x4_L8_r0_body.nr9.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S216.tab.length) = true
kernel_rfl bodySub9 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site9.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost9 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws9 PRE_first_tail_x4_L8_r0_body.cws9 bodyQs9 = true
kernel_rfl bodyDrop9 : Nat.ble (12857 + (PRE_first_tail_x4_L8_r0_body.s217.next - PRE_first_tail_x4_L8_r0_body.s218.next)) 14006 = true
kernel_rfl bodyDropH9 : Nat.ble (200 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s217.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s218.ffi).next)) 225 = true
kernel_rfl bodyDropN9 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s217.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s218.ffi).nnext)) 0 = true
kernel_rfl bodyDv9 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws9
kernel_rfl bodyDe9 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr9.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st9.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl9 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold9 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws9).isNone && !PRE_first_tail_x4_L8_r0_body.ws9.contains v) = true
kernel_rfl bodyDfree9 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws9 ++ PRE_first_tail_x4_L8_r0_body.ws9).all fun w => e.noVar w) = true

theorem bodyStep9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12857, 200, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s216 PRE_first_tail_x4_L8_r0_body.S216)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s218 PRE_first_tail_x4_L8_r0_body.S218) (11334 + 1) :=
  bodySite bodyFacts9.cfix bodyFacts9.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st9.S5.tab) (Es := bodyEs9) (qs := bodyQs9)
    (ok := PRE_first_tail_x4_L8_r0_body.st9.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site9 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts9
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site9 r hr) hi (MapOk.sub hm (sub_of_all bodySub9)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk9 r hr) hi hm ho hq)
    bodyLq9 rfl bodyNrLo9 (postSub_sound bodyPost9)
    (Nat.le_of_ble_eq_true bodyDrop9) (by decide) (Nat.le_of_ble_eq_true bodyDropH9) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN9) (by decide)
    bodyDv9 bodyDe9 bodyDl9 bodyDold9 bodyDfree9 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site10 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site10 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site10) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st10.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site10
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st10.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st10.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s238 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s239 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S238 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws10 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st10.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st10.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso10
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_10
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st10.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot10
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup10
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound10
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace10
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged10
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws10.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st10.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S238.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_10]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen10.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh10
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl10 : Conv.NClean (⟨18828, 15904, 2699933, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s238.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl10 (PRE_first_tail_x4_L8_r0_body.cncl9 bodyNcl9)

theorem bodyClean10 : Conv.JClean (⟨18828, 15904, 2699933, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s238 :=
  PRE_first_tail_x4_L8_r0_body.gjcl10 (PRE_first_tail_x4_L8_r0_body.cjcl9 bodyClean9)

kernel_rfl bodyJsLe10 : Nat.ble PRE_first_tail_x4_L8_r0_body.s216.next PRE_first_tail_x4_L8_r0_body.s238.next = true
kernel_rfl bodyJsList10 : (PRE_first_tail_x4_L8_r0_body.gjh10 ++ PRE_first_tail_x4_L8_r0_body.cl10).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s238.next) PRE_first_tail_x4_L8_r0_body.s240) = true
theorem bodyJs10 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s238.next PRE_first_tail_x4_L8_r0_body.s240 :=
  JsHeapAbove.glueSite bodyJs9 (Nat.le_of_ble_eq_true bodyJsLe10) PRE_first_tail_x4_L8_r0_body.gjk10 PRE_first_tail_x4_L8_r0_body.gjbd10 PRE_first_tail_x4_L8_r0_body.cheap10 PRE_first_tail_x4_L8_r0_body.zclbd10 bodyJsList10

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO218 : PRE_first_tail_x4_L8_r0_body.S218.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S218.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr218 : bridgeOf PRE_first_tail_x4_L8_r0_body.s218.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc218 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s218 PRE_first_tail_x4_L8_r0_body.S218) = fun _ _ => true
kernel_rfl bodyAcc219 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s219 PRE_first_tail_x4_L8_r0_body.S219) = fun _ _ => true
kernel_rfl bodyBr220 : bridgeOf PRE_first_tail_x4_L8_r0_body.s220.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt219 : isHalt PRE_first_tail_x4_L8_r0_body.s219.ctl = false
kernel_rfl bodyTop220 : noRetBlock PRE_first_tail_x4_L8_r0_body.s220 = true
kernel_rfl bodyCnt218 : countersOkB PRE_first_tail_x4_L8_r0_body.s218 PRE_first_tail_x4_L8_r0_body.s220 = true
kernel_rfl bodyO220 : PRE_first_tail_x4_L8_r0_body.S220.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S220.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr221 : bridgeOf PRE_first_tail_x4_L8_r0_body.s221.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt220 : countersOkB PRE_first_tail_x4_L8_r0_body.s220 PRE_first_tail_x4_L8_r0_body.s221 = true
kernel_rfl bodyO221 : PRE_first_tail_x4_L8_r0_body.S221.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S221.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc221 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s221 PRE_first_tail_x4_L8_r0_body.S221) = fun _ _ => true
kernel_rfl bodyAcc225 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s225 PRE_first_tail_x4_L8_r0_body.S225) = fun _ _ => true
kernel_rfl bodyBr226 : bridgeOf PRE_first_tail_x4_L8_r0_body.s226.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt225 : isHalt PRE_first_tail_x4_L8_r0_body.s225.ctl = false
kernel_rfl bodyTop226 : noRetBlock PRE_first_tail_x4_L8_r0_body.s226 = true
kernel_rfl bodyCnt221 : countersOkB PRE_first_tail_x4_L8_r0_body.s221 PRE_first_tail_x4_L8_r0_body.s226 = true
kernel_rfl bodyO226 : PRE_first_tail_x4_L8_r0_body.S226.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S226.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr227 : bridgeOf PRE_first_tail_x4_L8_r0_body.s227.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt226 : countersOkB PRE_first_tail_x4_L8_r0_body.s226 PRE_first_tail_x4_L8_r0_body.s227 = true
kernel_rfl bodyO227 : PRE_first_tail_x4_L8_r0_body.S227.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S227.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc227 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s227 PRE_first_tail_x4_L8_r0_body.S227) = fun _ _ => true
kernel_rfl bodyAcc228 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s228 PRE_first_tail_x4_L8_r0_body.S228) = fun _ _ => true
kernel_rfl bodyBr229 : bridgeOf PRE_first_tail_x4_L8_r0_body.s229.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt228 : isHalt PRE_first_tail_x4_L8_r0_body.s228.ctl = false
kernel_rfl bodyTop229 : noRetBlock PRE_first_tail_x4_L8_r0_body.s229 = true
kernel_rfl bodyCnt227 : countersOkB PRE_first_tail_x4_L8_r0_body.s227 PRE_first_tail_x4_L8_r0_body.s229 = true
kernel_rfl bodyO229 : PRE_first_tail_x4_L8_r0_body.S229.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S229.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr230 : bridgeOf PRE_first_tail_x4_L8_r0_body.s230.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt229 : countersOkB PRE_first_tail_x4_L8_r0_body.s229 PRE_first_tail_x4_L8_r0_body.s230 = true
kernel_rfl bodyO230 : PRE_first_tail_x4_L8_r0_body.S230.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S230.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc230 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s230 PRE_first_tail_x4_L8_r0_body.S230) = fun _ _ => true
kernel_rfl bodyAcc231 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s231 PRE_first_tail_x4_L8_r0_body.S231) = fun _ _ => true
kernel_rfl bodyBr232 : bridgeOf PRE_first_tail_x4_L8_r0_body.s232.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt231 : isHalt PRE_first_tail_x4_L8_r0_body.s231.ctl = false
kernel_rfl bodyTop232 : noRetBlock PRE_first_tail_x4_L8_r0_body.s232 = true
kernel_rfl bodyCnt230 : countersOkB PRE_first_tail_x4_L8_r0_body.s230 PRE_first_tail_x4_L8_r0_body.s232 = true
kernel_rfl bodyO232 : PRE_first_tail_x4_L8_r0_body.S232.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S232.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr233 : bridgeOf PRE_first_tail_x4_L8_r0_body.s233.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt232 : countersOkB PRE_first_tail_x4_L8_r0_body.s232 PRE_first_tail_x4_L8_r0_body.s233 = true
kernel_rfl bodyO233 : PRE_first_tail_x4_L8_r0_body.S233.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S233.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc233 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s233 PRE_first_tail_x4_L8_r0_body.S233) = fun _ _ => true
kernel_rfl bodyAcc234 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s234 PRE_first_tail_x4_L8_r0_body.S234) = fun _ _ => true
kernel_rfl bodyBr235 : bridgeOf PRE_first_tail_x4_L8_r0_body.s235.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt234 : isHalt PRE_first_tail_x4_L8_r0_body.s234.ctl = false
kernel_rfl bodyTop235 : noRetBlock PRE_first_tail_x4_L8_r0_body.s235 = true
kernel_rfl bodyCnt233 : countersOkB PRE_first_tail_x4_L8_r0_body.s233 PRE_first_tail_x4_L8_r0_body.s235 = true
kernel_rfl bodyO235 : PRE_first_tail_x4_L8_r0_body.S235.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S235.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr236 : bridgeOf PRE_first_tail_x4_L8_r0_body.s236.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt235 : countersOkB PRE_first_tail_x4_L8_r0_body.s235 PRE_first_tail_x4_L8_r0_body.s236 = true
kernel_rfl bodyO236 : PRE_first_tail_x4_L8_r0_body.S236.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S236.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc236 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s236 PRE_first_tail_x4_L8_r0_body.S236) = fun _ _ => true
kernel_rfl bodyAcc237 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s237 PRE_first_tail_x4_L8_r0_body.S237) = fun _ _ => true
kernel_rfl bodyBr238 : bridgeOf PRE_first_tail_x4_L8_r0_body.s238.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt237 : isHalt PRE_first_tail_x4_L8_r0_body.s237.ctl = false
kernel_rfl bodyTop238 : noRetBlock PRE_first_tail_x4_L8_r0_body.s238 = true
kernel_rfl bodyCnt236 : countersOkB PRE_first_tail_x4_L8_r0_body.s236 PRE_first_tail_x4_L8_r0_body.s238 = true

theorem bodyGlue10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s218 PRE_first_tail_x4_L8_r0_body.S218)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s238 PRE_first_tail_x4_L8_r0_body.S238) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) bodyAcc218 PRE_first_tail_x4_L8_r0_body.bodyRunSeg57 bodyAcc219 bodyHalt219 PRE_first_tail_x4_L8_r0_body.bodyStepA58 bodyTop220 (fun _ hm => bodyO218 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr218).trans bodyInactive0) (bodyBr220.trans bodyBr218.symm) bodyCnt218 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA58 PRE_first_tail_x4_L8_r0_body.sizeArgsA58 PRE_first_tail_x4_L8_r0_body.sizeSymA58 PRE_first_tail_x4_L8_r0_body.sizeMlxA58 PRE_first_tail_x4_L8_r0_body.sizePayA58 PRE_first_tail_x4_L8_r0_body.sizeTaA58 PRE_first_tail_x4_L8_r0_body.sizeDecA58 PRE_first_tail_x4_L8_r0_body.sizePreA58 PRE_first_tail_x4_L8_r0_body.bodyPatchB58 (fun _ hm => bodyO220 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr220).trans bodyInactive0) (bodyBr221.trans bodyBr220.symm) bodyCnt220 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) bodyAcc221 PRE_first_tail_x4_L8_r0_body.bodyRunSeg58 bodyAcc225 bodyHalt225 PRE_first_tail_x4_L8_r0_body.bodyStepA59 bodyTop226 (fun _ hm => bodyO221 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr221).trans bodyInactive0) (bodyBr226.trans bodyBr221.symm) bodyCnt221 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA59 PRE_first_tail_x4_L8_r0_body.sizeArgsA59 PRE_first_tail_x4_L8_r0_body.sizeSymA59 PRE_first_tail_x4_L8_r0_body.sizeMlxA59 PRE_first_tail_x4_L8_r0_body.sizePayA59 PRE_first_tail_x4_L8_r0_body.sizeTaA59 PRE_first_tail_x4_L8_r0_body.sizeDecA59 PRE_first_tail_x4_L8_r0_body.sizePreA59 PRE_first_tail_x4_L8_r0_body.bodyPatchB59 (fun _ hm => bodyO226 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr226).trans bodyInactive0) (bodyBr227.trans bodyBr226.symm) bodyCnt226 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) bodyAcc227 PRE_first_tail_x4_L8_r0_body.bodyRunSeg59 bodyAcc228 bodyHalt228 PRE_first_tail_x4_L8_r0_body.bodyStepA60 bodyTop229 (fun _ hm => bodyO227 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr227).trans bodyInactive0) (bodyBr229.trans bodyBr227.symm) bodyCnt227 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA60 PRE_first_tail_x4_L8_r0_body.sizeArgsA60 PRE_first_tail_x4_L8_r0_body.sizeSymA60 PRE_first_tail_x4_L8_r0_body.sizeMlxA60 PRE_first_tail_x4_L8_r0_body.sizePayA60 PRE_first_tail_x4_L8_r0_body.sizeTaA60 PRE_first_tail_x4_L8_r0_body.sizeDecA60 PRE_first_tail_x4_L8_r0_body.sizePreA60 PRE_first_tail_x4_L8_r0_body.bodyPatchB60 (fun _ hm => bodyO229 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr229).trans bodyInactive0) (bodyBr230.trans bodyBr229.symm) bodyCnt229 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) bodyAcc230 PRE_first_tail_x4_L8_r0_body.bodyRunSeg60 bodyAcc231 bodyHalt231 PRE_first_tail_x4_L8_r0_body.bodyStepA61 bodyTop232 (fun _ hm => bodyO230 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr230).trans bodyInactive0) (bodyBr232.trans bodyBr230.symm) bodyCnt230 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA61 PRE_first_tail_x4_L8_r0_body.sizeArgsA61 PRE_first_tail_x4_L8_r0_body.sizeSymA61 PRE_first_tail_x4_L8_r0_body.sizeMlxA61 PRE_first_tail_x4_L8_r0_body.sizePayA61 PRE_first_tail_x4_L8_r0_body.sizeTaA61 PRE_first_tail_x4_L8_r0_body.sizeDecA61 PRE_first_tail_x4_L8_r0_body.sizePreA61 PRE_first_tail_x4_L8_r0_body.bodyPatchB61 (fun _ hm => bodyO232 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr232).trans bodyInactive0) (bodyBr233.trans bodyBr232.symm) bodyCnt232 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) bodyAcc233 PRE_first_tail_x4_L8_r0_body.bodyRunSeg61 bodyAcc234 bodyHalt234 PRE_first_tail_x4_L8_r0_body.bodyStepA62 bodyTop235 (fun _ hm => bodyO233 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr233).trans bodyInactive0) (bodyBr235.trans bodyBr233.symm) bodyCnt233 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA62 PRE_first_tail_x4_L8_r0_body.sizeArgsA62 PRE_first_tail_x4_L8_r0_body.sizeSymA62 PRE_first_tail_x4_L8_r0_body.sizeMlxA62 PRE_first_tail_x4_L8_r0_body.sizePayA62 PRE_first_tail_x4_L8_r0_body.sizeTaA62 PRE_first_tail_x4_L8_r0_body.sizeDecA62 PRE_first_tail_x4_L8_r0_body.sizePreA62 PRE_first_tail_x4_L8_r0_body.bodyPatchB62 (fun _ hm => bodyO235 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr235).trans bodyInactive0) (bodyBr236.trans bodyBr235.symm) bodyCnt235 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14006, 225, 0, 0⟩) bodyAcc236 PRE_first_tail_x4_L8_r0_body.bodyRunSeg62 bodyAcc237 bodyHalt237 PRE_first_tail_x4_L8_r0_body.bodyStepA63 bodyTop238 (fun _ hm => bodyO236 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr236).trans bodyInactive0) (bodyBr238.trans bodyBr236.symm) bodyCnt236 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift10 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S238.tab.length PRE_first_tail_x4_L8_r0_body.s238.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P10.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P10 15 PRE_first_tail_x4_L8_r0_body.kappa10 PRE_first_tail_x4_L8_r0_body.s240.ffi PRE_first_tail_x4_L8_r0_body.s239.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_10
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_10
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s240.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S238.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_10] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK10 PRE_first_tail_x4_L8_r0_body.cobjsK10
      PRE_first_tail_x4_L8_r0_body.citemsK10 PRE_first_tail_x4_L8_r0_body.cbd10 PRE_first_tail_x4_L8_r0_body.csst10
  exact PRE_first_tail_x4_L8_r0_body.cshift10 bodyNcl10 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_10] at this; exact this)


kernel_rfl bodyFramesEmpty10 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s239 a).isEmpty) = true
kernel_rfl bodyJsRoots10 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s238.next) PRE_first_tail_x4_L8_r0_body.s240.trace PRE_first_tail_x4_L8_r0_body.s240 = true
kernel_rfl bodyJsNative10 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s240.ffi) = true
kernel_rfl bodyLow10 : (PRE_first_tail_x4_L8_r0_body.cws10 ++ PRE_first_tail_x4_L8_r0_body.ws10).all (Nat.ble 9) = true
kernel_rfl bodyCntM10 : countersOkB PRE_first_tail_x4_L8_r0_body.s238 PRE_first_tail_x4_L8_r0_body.s239 = true
kernel_rfl bodyHi10 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s240.ffi).next setupP.E = true
kernel_rfl bodyNhi10 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s240.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge10 : bridgeOf PRE_first_tail_x4_L8_r0_body.s239.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s238.ffi
kernel_rfl bodyNN10 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s238.ffi).nnext PRE_first_tail_x4_L8_r0_body.P10.NL = true
kernel_rfl bodyXn10 : Nat.ble (⟨18831, 15931, 2699939, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s240.ffi).next = true
kernel_rfl bodyLo10 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s240.ffi).next = true
theorem bodyFacts10 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s238 PRE_first_tail_x4_L8_r0_body.s239 PRE_first_tail_x4_L8_r0_body.s240 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S238 PRE_first_tail_x4_L8_r0_body.S239 PRE_first_tail_x4_L8_r0_body.S240
    PRE_first_tail_x4_L8_r0_body.ws10 PRE_first_tail_x4_L8_r0_body.cws10 PRE_first_tail_x4_L8_r0_body.nr10 PRE_first_tail_x4_L8_r0_body.pl10 PRE_first_tail_x4_L8_r0_body.cl10 2701088 15 PRE_first_tail_x4_L8_r0_body.kd10 PRE_first_tail_x4_L8_r0_body.kappa10 PRE_first_tail_x4_L8_r0_body.P10
    ⟨18828, 15904, 2699933, 15⟩ ⟨18831, 15931, 2699939, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap10
  clean := bodyClean10
  cfix := PRE_first_tail_x4_L8_r0_body.cfix10
  zpl := PRE_first_tail_x4_L8_r0_body.zpl10
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd10
  zn1 := PRE_first_tail_x4_L8_r0_body.zn110
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst10
  zscn := PRE_first_tail_x4_L8_r0_body.zscn10
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn10
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow10
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab10
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh10
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd10
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi10
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt10
  zgP := PRE_first_tail_x4_L8_r0_body.zg10_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk10_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm10_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg10_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk10_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm10_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw10_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw10_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap10
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd10
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap10 PRE_first_tail_x4_L8_r0_body.stFoot10 PRE_first_tail_x4_L8_r0_body.iso10 PRE_first_tail_x4_L8_r0_body.zwr10
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP10
  csupp := PRE_first_tail_x4_L8_r0_body.csupp10
  cbound := PRE_first_tail_x4_L8_r0_body.cbound10
  zimg := PRE_first_tail_x4_L8_r0_body.zimg10
  zctl := PRE_first_tail_x4_L8_r0_body.zctl10
  zstack := PRE_first_tail_x4_L8_r0_body.zstack10
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs10
  zstores := PRE_first_tail_x4_L8_r0_body.zstores10
  zroots := PRE_first_tail_x4_L8_r0_body.zroots10
  znC := PRE_first_tail_x4_L8_r0_body.znC10
  ctab := PRE_first_tail_x4_L8_r0_body.ctab10
  zbin := PRE_first_tail_x4_L8_r0_body.zbin10
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge10
  sbridge := bodyBridge10
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj10
  cshiftR := fun h hNL => bodyCshift10 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN10
  raised := PRE_first_tail_x4_L8_r0_body.raised10
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs10
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl10
  xnLe := Nat.le_of_ble_eq_true bodyXn10
  loLe := Nat.le_of_ble_eq_true bodyLo10
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB10
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
noncomputable def bodyEs10 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr10.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st10.S5.tab r
kernel_rfl bodyResChk10 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs10 bodyQs10) = true
kernel_rfl bodyLq10 : bodyQs10.length = PRE_first_tail_x4_L8_r0_body.cws10.length
kernel_rfl bodyNrLo10 : PRE_first_tail_x4_L8_r0_body.nr10.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S238.tab.length) = true
kernel_rfl bodySub10 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site10.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost10 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws10 PRE_first_tail_x4_L8_r0_body.cws10 bodyQs10 = true
kernel_rfl bodyDrop10 : Nat.ble (14006 + (PRE_first_tail_x4_L8_r0_body.s239.next - PRE_first_tail_x4_L8_r0_body.s240.next)) 15155 = true
kernel_rfl bodyDropH10 : Nat.ble (225 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s239.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s240.ffi).next)) 250 = true
kernel_rfl bodyDropN10 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s239.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s240.ffi).nnext)) 0 = true
kernel_rfl bodyDv10 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws10
kernel_rfl bodyDe10 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr10.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st10.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl10 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold10 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws10).isNone && !PRE_first_tail_x4_L8_r0_body.ws10.contains v) = true
kernel_rfl bodyDfree10 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws10 ++ PRE_first_tail_x4_L8_r0_body.ws10).all fun w => e.noVar w) = true

theorem bodyStep10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14006, 225, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s238 PRE_first_tail_x4_L8_r0_body.S238)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s240 PRE_first_tail_x4_L8_r0_body.S240) (11334 + 1) :=
  bodySite bodyFacts10.cfix bodyFacts10.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st10.S5.tab) (Es := bodyEs10) (qs := bodyQs10)
    (ok := PRE_first_tail_x4_L8_r0_body.st10.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site10 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts10
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site10 r hr) hi (MapOk.sub hm (sub_of_all bodySub10)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk10 r hr) hi hm ho hq)
    bodyLq10 rfl bodyNrLo10 (postSub_sound bodyPost10)
    (Nat.le_of_ble_eq_true bodyDrop10) (by decide) (Nat.le_of_ble_eq_true bodyDropH10) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN10) (by decide)
    bodyDv10 bodyDe10 bodyDl10 bodyDold10 bodyDfree10 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site11 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site11 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site11) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st11.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site11
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st11.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st11.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s259 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s260 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S259 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws11 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st11.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st11.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso11
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_11
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st11.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot11
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup11
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound11
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace11
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged11
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws11.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st11.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S259.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_11]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen11.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh11
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl11 : Conv.NClean (⟨18891, 15976, 2702436, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s259.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl11 (PRE_first_tail_x4_L8_r0_body.cncl10 bodyNcl10)

theorem bodyClean11 : Conv.JClean (⟨18891, 15976, 2702436, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s259 :=
  PRE_first_tail_x4_L8_r0_body.gjcl11 (PRE_first_tail_x4_L8_r0_body.cjcl10 bodyClean10)

kernel_rfl bodyJsLe11 : Nat.ble PRE_first_tail_x4_L8_r0_body.s238.next PRE_first_tail_x4_L8_r0_body.s259.next = true
kernel_rfl bodyJsList11 : (PRE_first_tail_x4_L8_r0_body.gjh11 ++ PRE_first_tail_x4_L8_r0_body.cl11).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s259.next) PRE_first_tail_x4_L8_r0_body.s261) = true
theorem bodyJs11 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s259.next PRE_first_tail_x4_L8_r0_body.s261 :=
  JsHeapAbove.glueSite bodyJs10 (Nat.le_of_ble_eq_true bodyJsLe11) PRE_first_tail_x4_L8_r0_body.gjk11 PRE_first_tail_x4_L8_r0_body.gjbd11 PRE_first_tail_x4_L8_r0_body.cheap11 PRE_first_tail_x4_L8_r0_body.zclbd11 bodyJsList11

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO240 : PRE_first_tail_x4_L8_r0_body.S240.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S240.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr240 : bridgeOf PRE_first_tail_x4_L8_r0_body.s240.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc240 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s240 PRE_first_tail_x4_L8_r0_body.S240) = fun _ _ => true
kernel_rfl bodyAcc241 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s241 PRE_first_tail_x4_L8_r0_body.S241) = fun _ _ => true
kernel_rfl bodyBr242 : bridgeOf PRE_first_tail_x4_L8_r0_body.s242.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt241 : isHalt PRE_first_tail_x4_L8_r0_body.s241.ctl = false
kernel_rfl bodyTop242 : noRetBlock PRE_first_tail_x4_L8_r0_body.s242 = true
kernel_rfl bodyCnt240 : countersOkB PRE_first_tail_x4_L8_r0_body.s240 PRE_first_tail_x4_L8_r0_body.s242 = true
kernel_rfl bodyO242 : PRE_first_tail_x4_L8_r0_body.S242.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S242.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr243 : bridgeOf PRE_first_tail_x4_L8_r0_body.s243.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt242 : countersOkB PRE_first_tail_x4_L8_r0_body.s242 PRE_first_tail_x4_L8_r0_body.s243 = true
kernel_rfl bodyO243 : PRE_first_tail_x4_L8_r0_body.S243.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S243.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc243 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s243 PRE_first_tail_x4_L8_r0_body.S243) = fun _ _ => true
kernel_rfl bodyAcc247 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s247 PRE_first_tail_x4_L8_r0_body.S247) = fun _ _ => true
kernel_rfl bodyBr248 : bridgeOf PRE_first_tail_x4_L8_r0_body.s248.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt247 : isHalt PRE_first_tail_x4_L8_r0_body.s247.ctl = false
kernel_rfl bodyTop248 : noRetBlock PRE_first_tail_x4_L8_r0_body.s248 = true
kernel_rfl bodyCnt243 : countersOkB PRE_first_tail_x4_L8_r0_body.s243 PRE_first_tail_x4_L8_r0_body.s248 = true
kernel_rfl bodyO248 : PRE_first_tail_x4_L8_r0_body.S248.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S248.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr249 : bridgeOf PRE_first_tail_x4_L8_r0_body.s249.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt248 : countersOkB PRE_first_tail_x4_L8_r0_body.s248 PRE_first_tail_x4_L8_r0_body.s249 = true
kernel_rfl bodyO249 : PRE_first_tail_x4_L8_r0_body.S249.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S249.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc249 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s249 PRE_first_tail_x4_L8_r0_body.S249) = fun _ _ => true
kernel_rfl bodyAcc251 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s251 PRE_first_tail_x4_L8_r0_body.S251) = fun _ _ => true
kernel_rfl bodyBr252 : bridgeOf PRE_first_tail_x4_L8_r0_body.s252.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt251 : isHalt PRE_first_tail_x4_L8_r0_body.s251.ctl = false
kernel_rfl bodyTop252 : noRetBlock PRE_first_tail_x4_L8_r0_body.s252 = true
kernel_rfl bodyCnt249 : countersOkB PRE_first_tail_x4_L8_r0_body.s249 PRE_first_tail_x4_L8_r0_body.s252 = true
kernel_rfl bodyO252 : PRE_first_tail_x4_L8_r0_body.S252.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S252.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr253 : bridgeOf PRE_first_tail_x4_L8_r0_body.s253.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt252 : countersOkB PRE_first_tail_x4_L8_r0_body.s252 PRE_first_tail_x4_L8_r0_body.s253 = true
kernel_rfl bodyO253 : PRE_first_tail_x4_L8_r0_body.S253.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S253.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc253 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s253 PRE_first_tail_x4_L8_r0_body.S253) = fun _ _ => true
kernel_rfl bodyAcc254 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s254 PRE_first_tail_x4_L8_r0_body.S254) = fun _ _ => true
kernel_rfl bodyBr255 : bridgeOf PRE_first_tail_x4_L8_r0_body.s255.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt254 : isHalt PRE_first_tail_x4_L8_r0_body.s254.ctl = false
kernel_rfl bodyTop255 : noRetBlock PRE_first_tail_x4_L8_r0_body.s255 = true
kernel_rfl bodyCnt253 : countersOkB PRE_first_tail_x4_L8_r0_body.s253 PRE_first_tail_x4_L8_r0_body.s255 = true
kernel_rfl bodyO255 : PRE_first_tail_x4_L8_r0_body.S255.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S255.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr256 : bridgeOf PRE_first_tail_x4_L8_r0_body.s256.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt255 : countersOkB PRE_first_tail_x4_L8_r0_body.s255 PRE_first_tail_x4_L8_r0_body.s256 = true
kernel_rfl bodyO256 : PRE_first_tail_x4_L8_r0_body.S256.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S256.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc256 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s256 PRE_first_tail_x4_L8_r0_body.S256) = fun _ _ => true
kernel_rfl bodyAcc258 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s258 PRE_first_tail_x4_L8_r0_body.S258) = fun _ _ => true
kernel_rfl bodyBr259 : bridgeOf PRE_first_tail_x4_L8_r0_body.s259.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt258 : isHalt PRE_first_tail_x4_L8_r0_body.s258.ctl = false
kernel_rfl bodyTop259 : noRetBlock PRE_first_tail_x4_L8_r0_body.s259 = true
kernel_rfl bodyCnt256 : countersOkB PRE_first_tail_x4_L8_r0_body.s256 PRE_first_tail_x4_L8_r0_body.s259 = true

theorem bodyGlue11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s240 PRE_first_tail_x4_L8_r0_body.S240)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s259 PRE_first_tail_x4_L8_r0_body.S259) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) bodyAcc240 PRE_first_tail_x4_L8_r0_body.bodyRunSeg63 bodyAcc241 bodyHalt241 PRE_first_tail_x4_L8_r0_body.bodyStepA64 bodyTop242 (fun _ hm => bodyO240 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr240).trans bodyInactive0) (bodyBr242.trans bodyBr240.symm) bodyCnt240 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA64 PRE_first_tail_x4_L8_r0_body.sizeArgsA64 PRE_first_tail_x4_L8_r0_body.sizeSymA64 PRE_first_tail_x4_L8_r0_body.sizeMlxA64 PRE_first_tail_x4_L8_r0_body.sizePayA64 PRE_first_tail_x4_L8_r0_body.sizeTaA64 PRE_first_tail_x4_L8_r0_body.sizeDecA64 PRE_first_tail_x4_L8_r0_body.sizePreA64 PRE_first_tail_x4_L8_r0_body.bodyPatchB64 (fun _ hm => bodyO242 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr242).trans bodyInactive0) (bodyBr243.trans bodyBr242.symm) bodyCnt242 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) bodyAcc243 PRE_first_tail_x4_L8_r0_body.bodyRunSeg64 bodyAcc247 bodyHalt247 PRE_first_tail_x4_L8_r0_body.bodyStepA65 bodyTop248 (fun _ hm => bodyO243 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr243).trans bodyInactive0) (bodyBr248.trans bodyBr243.symm) bodyCnt243 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA65 PRE_first_tail_x4_L8_r0_body.sizeArgsA65 PRE_first_tail_x4_L8_r0_body.sizeSymA65 PRE_first_tail_x4_L8_r0_body.sizeMlxA65 PRE_first_tail_x4_L8_r0_body.sizePayA65 PRE_first_tail_x4_L8_r0_body.sizeTaA65 PRE_first_tail_x4_L8_r0_body.sizeDecA65 PRE_first_tail_x4_L8_r0_body.sizePreA65 PRE_first_tail_x4_L8_r0_body.bodyPatchB65 (fun _ hm => bodyO248 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr248).trans bodyInactive0) (bodyBr249.trans bodyBr248.symm) bodyCnt248 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) bodyAcc249 PRE_first_tail_x4_L8_r0_body.bodyRunSeg65 bodyAcc251 bodyHalt251 PRE_first_tail_x4_L8_r0_body.bodyStepA66 bodyTop252 (fun _ hm => bodyO249 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr249).trans bodyInactive0) (bodyBr252.trans bodyBr249.symm) bodyCnt249 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA66 PRE_first_tail_x4_L8_r0_body.sizeArgsA66 PRE_first_tail_x4_L8_r0_body.sizeSymA66 PRE_first_tail_x4_L8_r0_body.sizeMlxA66 PRE_first_tail_x4_L8_r0_body.sizePayA66 PRE_first_tail_x4_L8_r0_body.sizeTaA66 PRE_first_tail_x4_L8_r0_body.sizeDecA66 PRE_first_tail_x4_L8_r0_body.sizePreA66 PRE_first_tail_x4_L8_r0_body.bodyPatchB66 (fun _ hm => bodyO252 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr252).trans bodyInactive0) (bodyBr253.trans bodyBr252.symm) bodyCnt252 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) bodyAcc253 PRE_first_tail_x4_L8_r0_body.bodyRunSeg66 bodyAcc254 bodyHalt254 PRE_first_tail_x4_L8_r0_body.bodyStepA67 bodyTop255 (fun _ hm => bodyO253 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr253).trans bodyInactive0) (bodyBr255.trans bodyBr253.symm) bodyCnt253 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA67 PRE_first_tail_x4_L8_r0_body.sizeArgsA67 PRE_first_tail_x4_L8_r0_body.sizeSymA67 PRE_first_tail_x4_L8_r0_body.sizeMlxA67 PRE_first_tail_x4_L8_r0_body.sizePayA67 PRE_first_tail_x4_L8_r0_body.sizeTaA67 PRE_first_tail_x4_L8_r0_body.sizeDecA67 PRE_first_tail_x4_L8_r0_body.sizePreA67 PRE_first_tail_x4_L8_r0_body.bodyPatchB67 (fun _ hm => bodyO255 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr255).trans bodyInactive0) (bodyBr256.trans bodyBr255.symm) bodyCnt255 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15155, 250, 0, 0⟩) bodyAcc256 PRE_first_tail_x4_L8_r0_body.bodyRunSeg67 bodyAcc258 bodyHalt258 PRE_first_tail_x4_L8_r0_body.bodyStepA68 bodyTop259 (fun _ hm => bodyO256 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr256).trans bodyInactive0) (bodyBr259.trans bodyBr256.symm) bodyCnt256 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift11 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S259.tab.length PRE_first_tail_x4_L8_r0_body.s259.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P11.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P11 15 PRE_first_tail_x4_L8_r0_body.kappa11 PRE_first_tail_x4_L8_r0_body.s261.ffi PRE_first_tail_x4_L8_r0_body.s260.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_11
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_11
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s261.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S259.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_11] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK11 PRE_first_tail_x4_L8_r0_body.cobjsK11
      PRE_first_tail_x4_L8_r0_body.citemsK11 PRE_first_tail_x4_L8_r0_body.cbd11 PRE_first_tail_x4_L8_r0_body.csst11
  exact PRE_first_tail_x4_L8_r0_body.cshift11 bodyNcl11 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_11] at this; exact this)


kernel_rfl bodyFramesEmpty11 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s260 a).isEmpty) = true
kernel_rfl bodyJsRoots11 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s259.next) PRE_first_tail_x4_L8_r0_body.s261.trace PRE_first_tail_x4_L8_r0_body.s261 = true
kernel_rfl bodyJsNative11 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s261.ffi) = true
kernel_rfl bodyLow11 : (PRE_first_tail_x4_L8_r0_body.cws11 ++ PRE_first_tail_x4_L8_r0_body.ws11).all (Nat.ble 9) = true
kernel_rfl bodyCntM11 : countersOkB PRE_first_tail_x4_L8_r0_body.s259 PRE_first_tail_x4_L8_r0_body.s260 = true
kernel_rfl bodyHi11 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s261.ffi).next setupP.E = true
kernel_rfl bodyNhi11 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s261.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge11 : bridgeOf PRE_first_tail_x4_L8_r0_body.s260.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s259.ffi
kernel_rfl bodyNN11 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s259.ffi).nnext PRE_first_tail_x4_L8_r0_body.P11.NL = true
kernel_rfl bodyXn11 : Nat.ble (⟨18895, 15982, 2702451, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s261.ffi).next = true
kernel_rfl bodyLo11 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s261.ffi).next = true
theorem bodyFacts11 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s259 PRE_first_tail_x4_L8_r0_body.s260 PRE_first_tail_x4_L8_r0_body.s261 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S259 PRE_first_tail_x4_L8_r0_body.S260 PRE_first_tail_x4_L8_r0_body.S261
    PRE_first_tail_x4_L8_r0_body.ws11 PRE_first_tail_x4_L8_r0_body.cws11 PRE_first_tail_x4_L8_r0_body.nr11 PRE_first_tail_x4_L8_r0_body.pl11 PRE_first_tail_x4_L8_r0_body.cl11 2702801 15 PRE_first_tail_x4_L8_r0_body.kd11 PRE_first_tail_x4_L8_r0_body.kappa11 PRE_first_tail_x4_L8_r0_body.P11
    ⟨18891, 15976, 2702436, 15⟩ ⟨18895, 15982, 2702451, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap11
  clean := bodyClean11
  cfix := PRE_first_tail_x4_L8_r0_body.cfix11
  zpl := PRE_first_tail_x4_L8_r0_body.zpl11
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd11
  zn1 := PRE_first_tail_x4_L8_r0_body.zn111
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst11
  zscn := PRE_first_tail_x4_L8_r0_body.zscn11
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn11
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow11
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab11
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh11
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd11
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi11
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt11
  zgP := PRE_first_tail_x4_L8_r0_body.zg11_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk11_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm11_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg11_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk11_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm11_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw11_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw11_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap11
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd11
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap11 PRE_first_tail_x4_L8_r0_body.stFoot11 PRE_first_tail_x4_L8_r0_body.iso11 PRE_first_tail_x4_L8_r0_body.zwr11
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP11
  csupp := PRE_first_tail_x4_L8_r0_body.csupp11
  cbound := PRE_first_tail_x4_L8_r0_body.cbound11
  zimg := PRE_first_tail_x4_L8_r0_body.zimg11
  zctl := PRE_first_tail_x4_L8_r0_body.zctl11
  zstack := PRE_first_tail_x4_L8_r0_body.zstack11
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs11
  zstores := PRE_first_tail_x4_L8_r0_body.zstores11
  zroots := PRE_first_tail_x4_L8_r0_body.zroots11
  znC := PRE_first_tail_x4_L8_r0_body.znC11
  ctab := PRE_first_tail_x4_L8_r0_body.ctab11
  zbin := PRE_first_tail_x4_L8_r0_body.zbin11
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge11
  sbridge := bodyBridge11
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj11
  cshiftR := fun h hNL => bodyCshift11 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN11
  raised := PRE_first_tail_x4_L8_r0_body.raised11
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs11
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl11
  xnLe := Nat.le_of_ble_eq_true bodyXn11
  loLe := Nat.le_of_ble_eq_true bodyLo11
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB11
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
noncomputable def bodyEs11 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr11.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st11.S3.tab r
kernel_rfl bodyResChk11 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs11 bodyQs11) = true
kernel_rfl bodyLq11 : bodyQs11.length = PRE_first_tail_x4_L8_r0_body.cws11.length
kernel_rfl bodyNrLo11 : PRE_first_tail_x4_L8_r0_body.nr11.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S259.tab.length) = true
kernel_rfl bodySub11 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site11.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost11 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws11 PRE_first_tail_x4_L8_r0_body.cws11 bodyQs11 = true
kernel_rfl bodyDrop11 : Nat.ble (15155 + (PRE_first_tail_x4_L8_r0_body.s260.next - PRE_first_tail_x4_L8_r0_body.s261.next)) 15505 = true
kernel_rfl bodyDropH11 : Nat.ble (250 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s260.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s261.ffi).next)) 252 = true
kernel_rfl bodyDropN11 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s260.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s261.ffi).nnext)) 0 = true
kernel_rfl bodyDv11 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws11
kernel_rfl bodyDe11 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr11.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st11.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl11 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold11 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws11).isNone && !PRE_first_tail_x4_L8_r0_body.ws11.contains v) = true
kernel_rfl bodyDfree11 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws11 ++ PRE_first_tail_x4_L8_r0_body.ws11).all fun w => e.noVar w) = true

theorem bodyStep11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15155, 250, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s259 PRE_first_tail_x4_L8_r0_body.S259)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s261 PRE_first_tail_x4_L8_r0_body.S261) (3452 + 1) :=
  bodySite bodyFacts11.cfix bodyFacts11.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L8_r0_body.st11.S3.tab) (Es := bodyEs11) (qs := bodyQs11)
    (ok := PRE_first_tail_x4_L8_r0_body.st11.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site11 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts11
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site11 r hr) hi (MapOk.sub hm (sub_of_all bodySub11)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk11 r hr) hi hm ho hq)
    bodyLq11 rfl bodyNrLo11 (postSub_sound bodyPost11)
    (Nat.le_of_ble_eq_true bodyDrop11) (by decide) (Nat.le_of_ble_eq_true bodyDropH11) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN11) (by decide)
    bodyDv11 bodyDe11 bodyDl11 bodyDold11 bodyDfree11 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyOracles_3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_g12 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g12 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g12) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site12 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st12.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g13 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g13 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g13) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site13 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st13.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g14 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g14 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g14) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site14 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site14 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st14.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g15 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g15 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g15) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site15 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st15.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site12 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site12 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site12) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st12.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site12
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st12.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st12.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s283 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s284 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S283 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws12 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st12.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st12.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso12
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_12
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st12.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot12
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup12
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound12
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace12
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged12
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws12.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st12.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S283.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_12]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen12.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh12
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl12 : Conv.NClean (⟨18963, 16028, 2705459, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s283.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl12 (PRE_first_tail_x4_L8_r0_body.cncl11 bodyNcl11)

theorem bodyClean12 : Conv.JClean (⟨18963, 16028, 2705459, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s283 :=
  PRE_first_tail_x4_L8_r0_body.gjcl12 (PRE_first_tail_x4_L8_r0_body.cjcl11 bodyClean11)

kernel_rfl bodyJsLe12 : Nat.ble PRE_first_tail_x4_L8_r0_body.s259.next PRE_first_tail_x4_L8_r0_body.s283.next = true
kernel_rfl bodyJsList12 : (PRE_first_tail_x4_L8_r0_body.gjh12 ++ PRE_first_tail_x4_L8_r0_body.cl12).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s283.next) PRE_first_tail_x4_L8_r0_body.s285) = true
theorem bodyJs12 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s283.next PRE_first_tail_x4_L8_r0_body.s285 :=
  JsHeapAbove.glueSite bodyJs11 (Nat.le_of_ble_eq_true bodyJsLe12) PRE_first_tail_x4_L8_r0_body.gjk12 PRE_first_tail_x4_L8_r0_body.gjbd12 PRE_first_tail_x4_L8_r0_body.cheap12 PRE_first_tail_x4_L8_r0_body.zclbd12 bodyJsList12

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO261 : PRE_first_tail_x4_L8_r0_body.S261.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S261.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr261 : bridgeOf PRE_first_tail_x4_L8_r0_body.s261.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc261 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s261 PRE_first_tail_x4_L8_r0_body.S261) = fun _ _ => true
kernel_rfl bodyAcc264 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s264 PRE_first_tail_x4_L8_r0_body.S264) = fun _ _ => true
kernel_rfl bodyBr265 : bridgeOf PRE_first_tail_x4_L8_r0_body.s265.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt264 : isHalt PRE_first_tail_x4_L8_r0_body.s264.ctl = false
kernel_rfl bodyTop265 : noRetBlock PRE_first_tail_x4_L8_r0_body.s265 = true
kernel_rfl bodyCnt261 : countersOkB PRE_first_tail_x4_L8_r0_body.s261 PRE_first_tail_x4_L8_r0_body.s265 = true
kernel_rfl bodyO265 : PRE_first_tail_x4_L8_r0_body.S265.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S265.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr266 : bridgeOf PRE_first_tail_x4_L8_r0_body.s266.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt265 : countersOkB PRE_first_tail_x4_L8_r0_body.s265 PRE_first_tail_x4_L8_r0_body.s266 = true
kernel_rfl bodyO266 : PRE_first_tail_x4_L8_r0_body.S266.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S266.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc266 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s266 PRE_first_tail_x4_L8_r0_body.S266) = fun _ _ => true
kernel_rfl bodyAcc270 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s270 PRE_first_tail_x4_L8_r0_body.S270) = fun _ _ => true
kernel_rfl bodyBr271 : bridgeOf PRE_first_tail_x4_L8_r0_body.s271.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt270 : isHalt PRE_first_tail_x4_L8_r0_body.s270.ctl = false
kernel_rfl bodyTop271 : noRetBlock PRE_first_tail_x4_L8_r0_body.s271 = true
kernel_rfl bodyCnt266 : countersOkB PRE_first_tail_x4_L8_r0_body.s266 PRE_first_tail_x4_L8_r0_body.s271 = true
kernel_rfl bodyO271 : PRE_first_tail_x4_L8_r0_body.S271.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S271.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr272 : bridgeOf PRE_first_tail_x4_L8_r0_body.s272.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt271 : countersOkB PRE_first_tail_x4_L8_r0_body.s271 PRE_first_tail_x4_L8_r0_body.s272 = true
kernel_rfl bodyO272 : PRE_first_tail_x4_L8_r0_body.S272.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S272.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc272 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s272 PRE_first_tail_x4_L8_r0_body.S272) = fun _ _ => true
kernel_rfl bodyAcc273 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s273 PRE_first_tail_x4_L8_r0_body.S273) = fun _ _ => true
kernel_rfl bodyBr274 : bridgeOf PRE_first_tail_x4_L8_r0_body.s274.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt273 : isHalt PRE_first_tail_x4_L8_r0_body.s273.ctl = false
kernel_rfl bodyTop274 : noRetBlock PRE_first_tail_x4_L8_r0_body.s274 = true
kernel_rfl bodyCnt272 : countersOkB PRE_first_tail_x4_L8_r0_body.s272 PRE_first_tail_x4_L8_r0_body.s274 = true
kernel_rfl bodyO274 : PRE_first_tail_x4_L8_r0_body.S274.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S274.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr275 : bridgeOf PRE_first_tail_x4_L8_r0_body.s275.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt274 : countersOkB PRE_first_tail_x4_L8_r0_body.s274 PRE_first_tail_x4_L8_r0_body.s275 = true
kernel_rfl bodyO275 : PRE_first_tail_x4_L8_r0_body.S275.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S275.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc275 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s275 PRE_first_tail_x4_L8_r0_body.S275) = fun _ _ => true
kernel_rfl bodyAcc276 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s276 PRE_first_tail_x4_L8_r0_body.S276) = fun _ _ => true
kernel_rfl bodyBr277 : bridgeOf PRE_first_tail_x4_L8_r0_body.s277.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt276 : isHalt PRE_first_tail_x4_L8_r0_body.s276.ctl = false
kernel_rfl bodyTop277 : noRetBlock PRE_first_tail_x4_L8_r0_body.s277 = true
kernel_rfl bodyCnt275 : countersOkB PRE_first_tail_x4_L8_r0_body.s275 PRE_first_tail_x4_L8_r0_body.s277 = true
kernel_rfl bodyO277 : PRE_first_tail_x4_L8_r0_body.S277.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S277.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr278 : bridgeOf PRE_first_tail_x4_L8_r0_body.s278.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt277 : countersOkB PRE_first_tail_x4_L8_r0_body.s277 PRE_first_tail_x4_L8_r0_body.s278 = true
kernel_rfl bodyO278 : PRE_first_tail_x4_L8_r0_body.S278.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S278.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc278 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s278 PRE_first_tail_x4_L8_r0_body.S278) = fun _ _ => true
kernel_rfl bodyAcc279 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s279 PRE_first_tail_x4_L8_r0_body.S279) = fun _ _ => true
kernel_rfl bodyBr280 : bridgeOf PRE_first_tail_x4_L8_r0_body.s280.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt279 : isHalt PRE_first_tail_x4_L8_r0_body.s279.ctl = false
kernel_rfl bodyTop280 : noRetBlock PRE_first_tail_x4_L8_r0_body.s280 = true
kernel_rfl bodyCnt278 : countersOkB PRE_first_tail_x4_L8_r0_body.s278 PRE_first_tail_x4_L8_r0_body.s280 = true
kernel_rfl bodyO280 : PRE_first_tail_x4_L8_r0_body.S280.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S280.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr281 : bridgeOf PRE_first_tail_x4_L8_r0_body.s281.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt280 : countersOkB PRE_first_tail_x4_L8_r0_body.s280 PRE_first_tail_x4_L8_r0_body.s281 = true
kernel_rfl bodyO281 : PRE_first_tail_x4_L8_r0_body.S281.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S281.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc281 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s281 PRE_first_tail_x4_L8_r0_body.S281) = fun _ _ => true
kernel_rfl bodyAcc282 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s282 PRE_first_tail_x4_L8_r0_body.S282) = fun _ _ => true
kernel_rfl bodyBr283 : bridgeOf PRE_first_tail_x4_L8_r0_body.s283.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt282 : isHalt PRE_first_tail_x4_L8_r0_body.s282.ctl = false
kernel_rfl bodyTop283 : noRetBlock PRE_first_tail_x4_L8_r0_body.s283 = true
kernel_rfl bodyCnt281 : countersOkB PRE_first_tail_x4_L8_r0_body.s281 PRE_first_tail_x4_L8_r0_body.s283 = true

theorem bodyGlue12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s261 PRE_first_tail_x4_L8_r0_body.S261)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s283 PRE_first_tail_x4_L8_r0_body.S283) 30573 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) bodyAcc261 PRE_first_tail_x4_L8_r0_body.bodyRunSeg68 bodyAcc264 bodyHalt264 PRE_first_tail_x4_L8_r0_body.bodyStepA69 bodyTop265 (fun _ hm => bodyO261 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr261).trans bodyInactive0) (bodyBr265.trans bodyBr261.symm) bodyCnt261 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA69 PRE_first_tail_x4_L8_r0_body.sizeArgsA69 PRE_first_tail_x4_L8_r0_body.sizeSymA69 PRE_first_tail_x4_L8_r0_body.sizeMlxA69 PRE_first_tail_x4_L8_r0_body.sizePayA69 PRE_first_tail_x4_L8_r0_body.sizeTaA69 PRE_first_tail_x4_L8_r0_body.sizeDecA69 PRE_first_tail_x4_L8_r0_body.sizePreA69 PRE_first_tail_x4_L8_r0_body.bodyPatchB69 (fun _ hm => bodyO265 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr265).trans bodyInactive0) (bodyBr266.trans bodyBr265.symm) bodyCnt265 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) bodyAcc266 PRE_first_tail_x4_L8_r0_body.bodyRunSeg69 bodyAcc270 bodyHalt270 PRE_first_tail_x4_L8_r0_body.bodyStepA70 bodyTop271 (fun _ hm => bodyO266 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr266).trans bodyInactive0) (bodyBr271.trans bodyBr266.symm) bodyCnt266 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA70 PRE_first_tail_x4_L8_r0_body.sizeArgsA70 PRE_first_tail_x4_L8_r0_body.sizeSymA70 PRE_first_tail_x4_L8_r0_body.sizeMlxA70 PRE_first_tail_x4_L8_r0_body.sizePayA70 PRE_first_tail_x4_L8_r0_body.sizeTaA70 PRE_first_tail_x4_L8_r0_body.sizeDecA70 PRE_first_tail_x4_L8_r0_body.sizePreA70 PRE_first_tail_x4_L8_r0_body.bodyPatchB70 (fun _ hm => bodyO271 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr271).trans bodyInactive0) (bodyBr272.trans bodyBr271.symm) bodyCnt271 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) bodyAcc272 PRE_first_tail_x4_L8_r0_body.bodyRunSeg70 bodyAcc273 bodyHalt273 PRE_first_tail_x4_L8_r0_body.bodyStepA71 bodyTop274 (fun _ hm => bodyO272 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr272).trans bodyInactive0) (bodyBr274.trans bodyBr272.symm) bodyCnt272 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA71 PRE_first_tail_x4_L8_r0_body.sizeArgsA71 PRE_first_tail_x4_L8_r0_body.sizeSymA71 PRE_first_tail_x4_L8_r0_body.sizeMlxA71 PRE_first_tail_x4_L8_r0_body.sizePayA71 PRE_first_tail_x4_L8_r0_body.sizeTaA71 PRE_first_tail_x4_L8_r0_body.sizeDecA71 PRE_first_tail_x4_L8_r0_body.sizePreA71 PRE_first_tail_x4_L8_r0_body.bodyPatchB71 (fun _ hm => bodyO274 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr274).trans bodyInactive0) (bodyBr275.trans bodyBr274.symm) bodyCnt274 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) bodyAcc275 PRE_first_tail_x4_L8_r0_body.bodyRunSeg71 bodyAcc276 bodyHalt276 PRE_first_tail_x4_L8_r0_body.bodyStepA72 bodyTop277 (fun _ hm => bodyO275 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr275).trans bodyInactive0) (bodyBr277.trans bodyBr275.symm) bodyCnt275 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA72 PRE_first_tail_x4_L8_r0_body.sizeArgsA72 PRE_first_tail_x4_L8_r0_body.sizeSymA72 PRE_first_tail_x4_L8_r0_body.sizeMlxA72 PRE_first_tail_x4_L8_r0_body.sizePayA72 PRE_first_tail_x4_L8_r0_body.sizeTaA72 PRE_first_tail_x4_L8_r0_body.sizeDecA72 PRE_first_tail_x4_L8_r0_body.sizePreA72 PRE_first_tail_x4_L8_r0_body.bodyPatchB72 (fun _ hm => bodyO277 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr277).trans bodyInactive0) (bodyBr278.trans bodyBr277.symm) bodyCnt277 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) bodyAcc278 PRE_first_tail_x4_L8_r0_body.bodyRunSeg72 bodyAcc279 bodyHalt279 PRE_first_tail_x4_L8_r0_body.bodyStepA73 bodyTop280 (fun _ hm => bodyO278 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr278).trans bodyInactive0) (bodyBr280.trans bodyBr278.symm) bodyCnt278 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA73 PRE_first_tail_x4_L8_r0_body.sizeArgsA73 PRE_first_tail_x4_L8_r0_body.sizeSymA73 PRE_first_tail_x4_L8_r0_body.sizeMlxA73 PRE_first_tail_x4_L8_r0_body.sizePayA73 PRE_first_tail_x4_L8_r0_body.sizeTaA73 PRE_first_tail_x4_L8_r0_body.sizeDecA73 PRE_first_tail_x4_L8_r0_body.sizePreA73 PRE_first_tail_x4_L8_r0_body.bodyPatchB73 (fun _ hm => bodyO280 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr280).trans bodyInactive0) (bodyBr281.trans bodyBr280.symm) bodyCnt280 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15505, 252, 0, 0⟩) bodyAcc281 PRE_first_tail_x4_L8_r0_body.bodyRunSeg73 bodyAcc282 bodyHalt282 PRE_first_tail_x4_L8_r0_body.bodyStepA74 bodyTop283 (fun _ hm => bodyO281 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr281).trans bodyInactive0) (bodyBr283.trans bodyBr281.symm) bodyCnt281 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift12 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S283.tab.length PRE_first_tail_x4_L8_r0_body.s283.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P12.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P12 15 PRE_first_tail_x4_L8_r0_body.kappa12 PRE_first_tail_x4_L8_r0_body.s285.ffi PRE_first_tail_x4_L8_r0_body.s284.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_12
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_12
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s285.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S283.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_12] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK12 PRE_first_tail_x4_L8_r0_body.cobjsK12
      PRE_first_tail_x4_L8_r0_body.citemsK12 PRE_first_tail_x4_L8_r0_body.cbd12 PRE_first_tail_x4_L8_r0_body.csst12
  exact PRE_first_tail_x4_L8_r0_body.cshift12 bodyNcl12 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_12] at this; exact this)


kernel_rfl bodyFramesEmpty12 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s284 a).isEmpty) = true
kernel_rfl bodyJsRoots12 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s283.next) PRE_first_tail_x4_L8_r0_body.s285.trace PRE_first_tail_x4_L8_r0_body.s285 = true
kernel_rfl bodyJsNative12 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s285.ffi) = true
kernel_rfl bodyLow12 : (PRE_first_tail_x4_L8_r0_body.cws12 ++ PRE_first_tail_x4_L8_r0_body.ws12).all (Nat.ble 9) = true
kernel_rfl bodyCntM12 : countersOkB PRE_first_tail_x4_L8_r0_body.s283 PRE_first_tail_x4_L8_r0_body.s284 = true
kernel_rfl bodyHi12 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s285.ffi).next setupP.E = true
kernel_rfl bodyNhi12 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s285.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge12 : bridgeOf PRE_first_tail_x4_L8_r0_body.s284.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s283.ffi
kernel_rfl bodyNN12 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s283.ffi).nnext PRE_first_tail_x4_L8_r0_body.P12.NL = true
kernel_rfl bodyXn12 : Nat.ble (⟨18966, 16055, 2705465, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s285.ffi).next = true
kernel_rfl bodyLo12 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s285.ffi).next = true
theorem bodyFacts12 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s283 PRE_first_tail_x4_L8_r0_body.s284 PRE_first_tail_x4_L8_r0_body.s285 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S283 PRE_first_tail_x4_L8_r0_body.S284 PRE_first_tail_x4_L8_r0_body.S285
    PRE_first_tail_x4_L8_r0_body.ws12 PRE_first_tail_x4_L8_r0_body.cws12 PRE_first_tail_x4_L8_r0_body.nr12 PRE_first_tail_x4_L8_r0_body.pl12 PRE_first_tail_x4_L8_r0_body.cl12 2706614 15 PRE_first_tail_x4_L8_r0_body.kd12 PRE_first_tail_x4_L8_r0_body.kappa12 PRE_first_tail_x4_L8_r0_body.P12
    ⟨18963, 16028, 2705459, 15⟩ ⟨18966, 16055, 2705465, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap12
  clean := bodyClean12
  cfix := PRE_first_tail_x4_L8_r0_body.cfix12
  zpl := PRE_first_tail_x4_L8_r0_body.zpl12
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd12
  zn1 := PRE_first_tail_x4_L8_r0_body.zn112
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst12
  zscn := PRE_first_tail_x4_L8_r0_body.zscn12
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn12
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow12
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab12
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh12
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd12
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi12
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt12
  zgP := PRE_first_tail_x4_L8_r0_body.zg12_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk12_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm12_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg12_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk12_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm12_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw12_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw12_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap12
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd12
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap12 PRE_first_tail_x4_L8_r0_body.stFoot12 PRE_first_tail_x4_L8_r0_body.iso12 PRE_first_tail_x4_L8_r0_body.zwr12
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP12
  csupp := PRE_first_tail_x4_L8_r0_body.csupp12
  cbound := PRE_first_tail_x4_L8_r0_body.cbound12
  zimg := PRE_first_tail_x4_L8_r0_body.zimg12
  zctl := PRE_first_tail_x4_L8_r0_body.zctl12
  zstack := PRE_first_tail_x4_L8_r0_body.zstack12
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs12
  zstores := PRE_first_tail_x4_L8_r0_body.zstores12
  zroots := PRE_first_tail_x4_L8_r0_body.zroots12
  znC := PRE_first_tail_x4_L8_r0_body.znC12
  ctab := PRE_first_tail_x4_L8_r0_body.ctab12
  zbin := PRE_first_tail_x4_L8_r0_body.zbin12
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge12
  sbridge := bodyBridge12
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj12
  cshiftR := fun h hNL => bodyCshift12 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN12
  raised := PRE_first_tail_x4_L8_r0_body.raised12
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs12
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl12
  xnLe := Nat.le_of_ble_eq_true bodyXn12
  loLe := Nat.le_of_ble_eq_true bodyLo12
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB12
  cntM := bodyCntM12
  hiLe := Nat.le_of_ble_eq_true bodyHi12
  nhiLe := Nat.le_of_ble_eq_true bodyNhi12
  jsHeap := bodyJs12
  jsRoots := bodyJsRoots12
  jsNative := bodyJsNative12
  framesEmpty := bodyFramesEmpty12
  trailOld := by decide
  lowVars := bodyLow12

def bodyQs12 : List (Option Q) := []
noncomputable def bodyEs12 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr12.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st12.S5.tab r
kernel_rfl bodyResChk12 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs12 bodyQs12) = true
kernel_rfl bodyLq12 : bodyQs12.length = PRE_first_tail_x4_L8_r0_body.cws12.length
kernel_rfl bodyNrLo12 : PRE_first_tail_x4_L8_r0_body.nr12.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S283.tab.length) = true
kernel_rfl bodySub12 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site12.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost12 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws12 PRE_first_tail_x4_L8_r0_body.cws12 bodyQs12 = true
kernel_rfl bodyDrop12 : Nat.ble (15505 + (PRE_first_tail_x4_L8_r0_body.s284.next - PRE_first_tail_x4_L8_r0_body.s285.next)) 16654 = true
kernel_rfl bodyDropH12 : Nat.ble (252 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s284.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s285.ffi).next)) 277 = true
kernel_rfl bodyDropN12 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s284.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s285.ffi).nnext)) 0 = true
kernel_rfl bodyDv12 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws12
kernel_rfl bodyDe12 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr12.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st12.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl12 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold12 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws12).isNone && !PRE_first_tail_x4_L8_r0_body.ws12.contains v) = true
kernel_rfl bodyDfree12 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws12 ++ PRE_first_tail_x4_L8_r0_body.ws12).all fun w => e.noVar w) = true

theorem bodyStep12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15505, 252, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s283 PRE_first_tail_x4_L8_r0_body.S283)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s285 PRE_first_tail_x4_L8_r0_body.S285) (11334 + 1) :=
  bodySite bodyFacts12.cfix bodyFacts12.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st12.S5.tab) (Es := bodyEs12) (qs := bodyQs12)
    (ok := PRE_first_tail_x4_L8_r0_body.st12.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site12 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts12
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site12 r hr) hi (MapOk.sub hm (sub_of_all bodySub12)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk12 r hr) hi hm ho hq)
    bodyLq12 rfl bodyNrLo12 (postSub_sound bodyPost12)
    (Nat.le_of_ble_eq_true bodyDrop12) (by decide) (Nat.le_of_ble_eq_true bodyDropH12) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN12) (by decide)
    bodyDv12 bodyDe12 bodyDl12 bodyDold12 bodyDfree12 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site13 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site13 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site13) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st13.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site13
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st13.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st13.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s305 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s306 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S305 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws13 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st13.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st13.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso13
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_13
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st13.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot13
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup13
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound13
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace13
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged13
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws13.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st13.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S305.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_13]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen13.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh13
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl13 : Conv.NClean (⟨19020, 16091, 2707697, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s305.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl13 (PRE_first_tail_x4_L8_r0_body.cncl12 bodyNcl12)

theorem bodyClean13 : Conv.JClean (⟨19020, 16091, 2707697, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s305 :=
  PRE_first_tail_x4_L8_r0_body.gjcl13 (PRE_first_tail_x4_L8_r0_body.cjcl12 bodyClean12)

kernel_rfl bodyJsLe13 : Nat.ble PRE_first_tail_x4_L8_r0_body.s283.next PRE_first_tail_x4_L8_r0_body.s305.next = true
kernel_rfl bodyJsList13 : (PRE_first_tail_x4_L8_r0_body.gjh13 ++ PRE_first_tail_x4_L8_r0_body.cl13).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s305.next) PRE_first_tail_x4_L8_r0_body.s307) = true
theorem bodyJs13 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s305.next PRE_first_tail_x4_L8_r0_body.s307 :=
  JsHeapAbove.glueSite bodyJs12 (Nat.le_of_ble_eq_true bodyJsLe13) PRE_first_tail_x4_L8_r0_body.gjk13 PRE_first_tail_x4_L8_r0_body.gjbd13 PRE_first_tail_x4_L8_r0_body.cheap13 PRE_first_tail_x4_L8_r0_body.zclbd13 bodyJsList13

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO285 : PRE_first_tail_x4_L8_r0_body.S285.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S285.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr285 : bridgeOf PRE_first_tail_x4_L8_r0_body.s285.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc285 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s285 PRE_first_tail_x4_L8_r0_body.S285) = fun _ _ => true
kernel_rfl bodyAcc286 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s286 PRE_first_tail_x4_L8_r0_body.S286) = fun _ _ => true
kernel_rfl bodyBr287 : bridgeOf PRE_first_tail_x4_L8_r0_body.s287.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt286 : isHalt PRE_first_tail_x4_L8_r0_body.s286.ctl = false
kernel_rfl bodyTop287 : noRetBlock PRE_first_tail_x4_L8_r0_body.s287 = true
kernel_rfl bodyCnt285 : countersOkB PRE_first_tail_x4_L8_r0_body.s285 PRE_first_tail_x4_L8_r0_body.s287 = true
kernel_rfl bodyO287 : PRE_first_tail_x4_L8_r0_body.S287.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S287.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr288 : bridgeOf PRE_first_tail_x4_L8_r0_body.s288.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt287 : countersOkB PRE_first_tail_x4_L8_r0_body.s287 PRE_first_tail_x4_L8_r0_body.s288 = true
kernel_rfl bodyO288 : PRE_first_tail_x4_L8_r0_body.S288.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S288.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc288 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s288 PRE_first_tail_x4_L8_r0_body.S288) = fun _ _ => true
kernel_rfl bodyAcc292 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s292 PRE_first_tail_x4_L8_r0_body.S292) = fun _ _ => true
kernel_rfl bodyBr293 : bridgeOf PRE_first_tail_x4_L8_r0_body.s293.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt292 : isHalt PRE_first_tail_x4_L8_r0_body.s292.ctl = false
kernel_rfl bodyTop293 : noRetBlock PRE_first_tail_x4_L8_r0_body.s293 = true
kernel_rfl bodyCnt288 : countersOkB PRE_first_tail_x4_L8_r0_body.s288 PRE_first_tail_x4_L8_r0_body.s293 = true
kernel_rfl bodyO293 : PRE_first_tail_x4_L8_r0_body.S293.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S293.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr294 : bridgeOf PRE_first_tail_x4_L8_r0_body.s294.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt293 : countersOkB PRE_first_tail_x4_L8_r0_body.s293 PRE_first_tail_x4_L8_r0_body.s294 = true
kernel_rfl bodyO294 : PRE_first_tail_x4_L8_r0_body.S294.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S294.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc294 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s294 PRE_first_tail_x4_L8_r0_body.S294) = fun _ _ => true
kernel_rfl bodyAcc295 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s295 PRE_first_tail_x4_L8_r0_body.S295) = fun _ _ => true
kernel_rfl bodyBr296 : bridgeOf PRE_first_tail_x4_L8_r0_body.s296.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt295 : isHalt PRE_first_tail_x4_L8_r0_body.s295.ctl = false
kernel_rfl bodyTop296 : noRetBlock PRE_first_tail_x4_L8_r0_body.s296 = true
kernel_rfl bodyCnt294 : countersOkB PRE_first_tail_x4_L8_r0_body.s294 PRE_first_tail_x4_L8_r0_body.s296 = true
kernel_rfl bodyO296 : PRE_first_tail_x4_L8_r0_body.S296.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S296.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr297 : bridgeOf PRE_first_tail_x4_L8_r0_body.s297.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt296 : countersOkB PRE_first_tail_x4_L8_r0_body.s296 PRE_first_tail_x4_L8_r0_body.s297 = true
kernel_rfl bodyO297 : PRE_first_tail_x4_L8_r0_body.S297.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S297.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc297 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s297 PRE_first_tail_x4_L8_r0_body.S297) = fun _ _ => true
kernel_rfl bodyAcc298 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s298 PRE_first_tail_x4_L8_r0_body.S298) = fun _ _ => true
kernel_rfl bodyBr299 : bridgeOf PRE_first_tail_x4_L8_r0_body.s299.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt298 : isHalt PRE_first_tail_x4_L8_r0_body.s298.ctl = false
kernel_rfl bodyTop299 : noRetBlock PRE_first_tail_x4_L8_r0_body.s299 = true
kernel_rfl bodyCnt297 : countersOkB PRE_first_tail_x4_L8_r0_body.s297 PRE_first_tail_x4_L8_r0_body.s299 = true
kernel_rfl bodyO299 : PRE_first_tail_x4_L8_r0_body.S299.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S299.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr300 : bridgeOf PRE_first_tail_x4_L8_r0_body.s300.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt299 : countersOkB PRE_first_tail_x4_L8_r0_body.s299 PRE_first_tail_x4_L8_r0_body.s300 = true
kernel_rfl bodyO300 : PRE_first_tail_x4_L8_r0_body.S300.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S300.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc300 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s300 PRE_first_tail_x4_L8_r0_body.S300) = fun _ _ => true
kernel_rfl bodyAcc301 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s301 PRE_first_tail_x4_L8_r0_body.S301) = fun _ _ => true
kernel_rfl bodyBr302 : bridgeOf PRE_first_tail_x4_L8_r0_body.s302.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt301 : isHalt PRE_first_tail_x4_L8_r0_body.s301.ctl = false
kernel_rfl bodyTop302 : noRetBlock PRE_first_tail_x4_L8_r0_body.s302 = true
kernel_rfl bodyCnt300 : countersOkB PRE_first_tail_x4_L8_r0_body.s300 PRE_first_tail_x4_L8_r0_body.s302 = true
kernel_rfl bodyO302 : PRE_first_tail_x4_L8_r0_body.S302.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S302.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr303 : bridgeOf PRE_first_tail_x4_L8_r0_body.s303.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt302 : countersOkB PRE_first_tail_x4_L8_r0_body.s302 PRE_first_tail_x4_L8_r0_body.s303 = true
kernel_rfl bodyO303 : PRE_first_tail_x4_L8_r0_body.S303.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S303.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc303 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s303 PRE_first_tail_x4_L8_r0_body.S303) = fun _ _ => true
kernel_rfl bodyAcc304 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s304 PRE_first_tail_x4_L8_r0_body.S304) = fun _ _ => true
kernel_rfl bodyBr305 : bridgeOf PRE_first_tail_x4_L8_r0_body.s305.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt304 : isHalt PRE_first_tail_x4_L8_r0_body.s304.ctl = false
kernel_rfl bodyTop305 : noRetBlock PRE_first_tail_x4_L8_r0_body.s305 = true
kernel_rfl bodyCnt303 : countersOkB PRE_first_tail_x4_L8_r0_body.s303 PRE_first_tail_x4_L8_r0_body.s305 = true

theorem bodyGlue13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s285 PRE_first_tail_x4_L8_r0_body.S285)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s305 PRE_first_tail_x4_L8_r0_body.S305) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) bodyAcc285 PRE_first_tail_x4_L8_r0_body.bodyRunSeg74 bodyAcc286 bodyHalt286 PRE_first_tail_x4_L8_r0_body.bodyStepA75 bodyTop287 (fun _ hm => bodyO285 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr285).trans bodyInactive0) (bodyBr287.trans bodyBr285.symm) bodyCnt285 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA75 PRE_first_tail_x4_L8_r0_body.sizeArgsA75 PRE_first_tail_x4_L8_r0_body.sizeSymA75 PRE_first_tail_x4_L8_r0_body.sizeMlxA75 PRE_first_tail_x4_L8_r0_body.sizePayA75 PRE_first_tail_x4_L8_r0_body.sizeTaA75 PRE_first_tail_x4_L8_r0_body.sizeDecA75 PRE_first_tail_x4_L8_r0_body.sizePreA75 PRE_first_tail_x4_L8_r0_body.bodyPatchB75 (fun _ hm => bodyO287 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr287).trans bodyInactive0) (bodyBr288.trans bodyBr287.symm) bodyCnt287 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) bodyAcc288 PRE_first_tail_x4_L8_r0_body.bodyRunSeg75 bodyAcc292 bodyHalt292 PRE_first_tail_x4_L8_r0_body.bodyStepA76 bodyTop293 (fun _ hm => bodyO288 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr288).trans bodyInactive0) (bodyBr293.trans bodyBr288.symm) bodyCnt288 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA76 PRE_first_tail_x4_L8_r0_body.sizeArgsA76 PRE_first_tail_x4_L8_r0_body.sizeSymA76 PRE_first_tail_x4_L8_r0_body.sizeMlxA76 PRE_first_tail_x4_L8_r0_body.sizePayA76 PRE_first_tail_x4_L8_r0_body.sizeTaA76 PRE_first_tail_x4_L8_r0_body.sizeDecA76 PRE_first_tail_x4_L8_r0_body.sizePreA76 PRE_first_tail_x4_L8_r0_body.bodyPatchB76 (fun _ hm => bodyO293 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr293).trans bodyInactive0) (bodyBr294.trans bodyBr293.symm) bodyCnt293 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) bodyAcc294 PRE_first_tail_x4_L8_r0_body.bodyRunSeg76 bodyAcc295 bodyHalt295 PRE_first_tail_x4_L8_r0_body.bodyStepA77 bodyTop296 (fun _ hm => bodyO294 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr294).trans bodyInactive0) (bodyBr296.trans bodyBr294.symm) bodyCnt294 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA77 PRE_first_tail_x4_L8_r0_body.sizeArgsA77 PRE_first_tail_x4_L8_r0_body.sizeSymA77 PRE_first_tail_x4_L8_r0_body.sizeMlxA77 PRE_first_tail_x4_L8_r0_body.sizePayA77 PRE_first_tail_x4_L8_r0_body.sizeTaA77 PRE_first_tail_x4_L8_r0_body.sizeDecA77 PRE_first_tail_x4_L8_r0_body.sizePreA77 PRE_first_tail_x4_L8_r0_body.bodyPatchB77 (fun _ hm => bodyO296 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr296).trans bodyInactive0) (bodyBr297.trans bodyBr296.symm) bodyCnt296 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) bodyAcc297 PRE_first_tail_x4_L8_r0_body.bodyRunSeg77 bodyAcc298 bodyHalt298 PRE_first_tail_x4_L8_r0_body.bodyStepA78 bodyTop299 (fun _ hm => bodyO297 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr297).trans bodyInactive0) (bodyBr299.trans bodyBr297.symm) bodyCnt297 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA78 PRE_first_tail_x4_L8_r0_body.sizeArgsA78 PRE_first_tail_x4_L8_r0_body.sizeSymA78 PRE_first_tail_x4_L8_r0_body.sizeMlxA78 PRE_first_tail_x4_L8_r0_body.sizePayA78 PRE_first_tail_x4_L8_r0_body.sizeTaA78 PRE_first_tail_x4_L8_r0_body.sizeDecA78 PRE_first_tail_x4_L8_r0_body.sizePreA78 PRE_first_tail_x4_L8_r0_body.bodyPatchB78 (fun _ hm => bodyO299 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr299).trans bodyInactive0) (bodyBr300.trans bodyBr299.symm) bodyCnt299 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) bodyAcc300 PRE_first_tail_x4_L8_r0_body.bodyRunSeg78 bodyAcc301 bodyHalt301 PRE_first_tail_x4_L8_r0_body.bodyStepA79 bodyTop302 (fun _ hm => bodyO300 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr300).trans bodyInactive0) (bodyBr302.trans bodyBr300.symm) bodyCnt300 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA79 PRE_first_tail_x4_L8_r0_body.sizeArgsA79 PRE_first_tail_x4_L8_r0_body.sizeSymA79 PRE_first_tail_x4_L8_r0_body.sizeMlxA79 PRE_first_tail_x4_L8_r0_body.sizePayA79 PRE_first_tail_x4_L8_r0_body.sizeTaA79 PRE_first_tail_x4_L8_r0_body.sizeDecA79 PRE_first_tail_x4_L8_r0_body.sizePreA79 PRE_first_tail_x4_L8_r0_body.bodyPatchB79 (fun _ hm => bodyO302 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr302).trans bodyInactive0) (bodyBr303.trans bodyBr302.symm) bodyCnt302 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16654, 277, 0, 0⟩) bodyAcc303 PRE_first_tail_x4_L8_r0_body.bodyRunSeg79 bodyAcc304 bodyHalt304 PRE_first_tail_x4_L8_r0_body.bodyStepA80 bodyTop305 (fun _ hm => bodyO303 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr303).trans bodyInactive0) (bodyBr305.trans bodyBr303.symm) bodyCnt303 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift13 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S305.tab.length PRE_first_tail_x4_L8_r0_body.s305.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P13.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P13 15 PRE_first_tail_x4_L8_r0_body.kappa13 PRE_first_tail_x4_L8_r0_body.s307.ffi PRE_first_tail_x4_L8_r0_body.s306.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_13
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_13
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s307.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S305.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_13] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK13 PRE_first_tail_x4_L8_r0_body.cobjsK13
      PRE_first_tail_x4_L8_r0_body.citemsK13 PRE_first_tail_x4_L8_r0_body.cbd13 PRE_first_tail_x4_L8_r0_body.csst13
  exact PRE_first_tail_x4_L8_r0_body.cshift13 bodyNcl13 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_13] at this; exact this)


kernel_rfl bodyFramesEmpty13 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s306 a).isEmpty) = true
kernel_rfl bodyJsRoots13 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s305.next) PRE_first_tail_x4_L8_r0_body.s307.trace PRE_first_tail_x4_L8_r0_body.s307 = true
kernel_rfl bodyJsNative13 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s307.ffi) = true
kernel_rfl bodyLow13 : (PRE_first_tail_x4_L8_r0_body.cws13 ++ PRE_first_tail_x4_L8_r0_body.ws13).all (Nat.ble 9) = true
kernel_rfl bodyCntM13 : countersOkB PRE_first_tail_x4_L8_r0_body.s305 PRE_first_tail_x4_L8_r0_body.s306 = true
kernel_rfl bodyHi13 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s307.ffi).next setupP.E = true
kernel_rfl bodyNhi13 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s307.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge13 : bridgeOf PRE_first_tail_x4_L8_r0_body.s306.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s305.ffi
kernel_rfl bodyNN13 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s305.ffi).nnext PRE_first_tail_x4_L8_r0_body.P13.NL = true
kernel_rfl bodyXn13 : Nat.ble (⟨19023, 16118, 2707703, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s307.ffi).next = true
kernel_rfl bodyLo13 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s307.ffi).next = true
theorem bodyFacts13 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s305 PRE_first_tail_x4_L8_r0_body.s306 PRE_first_tail_x4_L8_r0_body.s307 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S305 PRE_first_tail_x4_L8_r0_body.S306 PRE_first_tail_x4_L8_r0_body.S307
    PRE_first_tail_x4_L8_r0_body.ws13 PRE_first_tail_x4_L8_r0_body.cws13 PRE_first_tail_x4_L8_r0_body.nr13 PRE_first_tail_x4_L8_r0_body.pl13 PRE_first_tail_x4_L8_r0_body.cl13 2708852 15 PRE_first_tail_x4_L8_r0_body.kd13 PRE_first_tail_x4_L8_r0_body.kappa13 PRE_first_tail_x4_L8_r0_body.P13
    ⟨19020, 16091, 2707697, 15⟩ ⟨19023, 16118, 2707703, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap13
  clean := bodyClean13
  cfix := PRE_first_tail_x4_L8_r0_body.cfix13
  zpl := PRE_first_tail_x4_L8_r0_body.zpl13
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd13
  zn1 := PRE_first_tail_x4_L8_r0_body.zn113
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst13
  zscn := PRE_first_tail_x4_L8_r0_body.zscn13
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn13
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow13
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab13
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh13
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd13
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi13
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt13
  zgP := PRE_first_tail_x4_L8_r0_body.zg13_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk13_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm13_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg13_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk13_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm13_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw13_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw13_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap13
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd13
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap13 PRE_first_tail_x4_L8_r0_body.stFoot13 PRE_first_tail_x4_L8_r0_body.iso13 PRE_first_tail_x4_L8_r0_body.zwr13
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP13
  csupp := PRE_first_tail_x4_L8_r0_body.csupp13
  cbound := PRE_first_tail_x4_L8_r0_body.cbound13
  zimg := PRE_first_tail_x4_L8_r0_body.zimg13
  zctl := PRE_first_tail_x4_L8_r0_body.zctl13
  zstack := PRE_first_tail_x4_L8_r0_body.zstack13
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs13
  zstores := PRE_first_tail_x4_L8_r0_body.zstores13
  zroots := PRE_first_tail_x4_L8_r0_body.zroots13
  znC := PRE_first_tail_x4_L8_r0_body.znC13
  ctab := PRE_first_tail_x4_L8_r0_body.ctab13
  zbin := PRE_first_tail_x4_L8_r0_body.zbin13
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge13
  sbridge := bodyBridge13
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj13
  cshiftR := fun h hNL => bodyCshift13 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN13
  raised := PRE_first_tail_x4_L8_r0_body.raised13
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs13
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl13
  xnLe := Nat.le_of_ble_eq_true bodyXn13
  loLe := Nat.le_of_ble_eq_true bodyLo13
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB13
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
noncomputable def bodyEs13 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr13.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st13.S5.tab r
kernel_rfl bodyResChk13 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs13 bodyQs13) = true
kernel_rfl bodyLq13 : bodyQs13.length = PRE_first_tail_x4_L8_r0_body.cws13.length
kernel_rfl bodyNrLo13 : PRE_first_tail_x4_L8_r0_body.nr13.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S305.tab.length) = true
kernel_rfl bodySub13 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site13.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost13 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws13 PRE_first_tail_x4_L8_r0_body.cws13 bodyQs13 = true
kernel_rfl bodyDrop13 : Nat.ble (16654 + (PRE_first_tail_x4_L8_r0_body.s306.next - PRE_first_tail_x4_L8_r0_body.s307.next)) 17803 = true
kernel_rfl bodyDropH13 : Nat.ble (277 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s306.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s307.ffi).next)) 302 = true
kernel_rfl bodyDropN13 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s306.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s307.ffi).nnext)) 0 = true
kernel_rfl bodyDv13 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws13
kernel_rfl bodyDe13 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr13.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st13.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl13 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold13 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws13).isNone && !PRE_first_tail_x4_L8_r0_body.ws13.contains v) = true
kernel_rfl bodyDfree13 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws13 ++ PRE_first_tail_x4_L8_r0_body.ws13).all fun w => e.noVar w) = true

theorem bodyStep13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16654, 277, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s305 PRE_first_tail_x4_L8_r0_body.S305)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s307 PRE_first_tail_x4_L8_r0_body.S307) (11334 + 1) :=
  bodySite bodyFacts13.cfix bodyFacts13.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st13.S5.tab) (Es := bodyEs13) (qs := bodyQs13)
    (ok := PRE_first_tail_x4_L8_r0_body.st13.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site13 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts13
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site13 r hr) hi (MapOk.sub hm (sub_of_all bodySub13)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk13 r hr) hi hm ho hq)
    bodyLq13 rfl bodyNrLo13 (postSub_sound bodyPost13)
    (Nat.le_of_ble_eq_true bodyDrop13) (by decide) (Nat.le_of_ble_eq_true bodyDropH13) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN13) (by decide)
    bodyDv13 bodyDe13 bodyDl13 bodyDold13 bodyDfree13 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site14 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site14 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site14) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st14.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site14
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st14.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st14.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s327 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s328 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S327 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws14 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st14.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st14.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso14
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_14
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st14.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot14
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup14
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound14
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace14
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged14
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws14.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st14.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S327.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_14]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen14.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh14
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl14 : Conv.NClean (⟨19077, 16154, 2709939, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s327.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl14 (PRE_first_tail_x4_L8_r0_body.cncl13 bodyNcl13)

theorem bodyClean14 : Conv.JClean (⟨19077, 16154, 2709939, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s327 :=
  PRE_first_tail_x4_L8_r0_body.gjcl14 (PRE_first_tail_x4_L8_r0_body.cjcl13 bodyClean13)

kernel_rfl bodyJsLe14 : Nat.ble PRE_first_tail_x4_L8_r0_body.s305.next PRE_first_tail_x4_L8_r0_body.s327.next = true
kernel_rfl bodyJsList14 : (PRE_first_tail_x4_L8_r0_body.gjh14 ++ PRE_first_tail_x4_L8_r0_body.cl14).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s327.next) PRE_first_tail_x4_L8_r0_body.s329) = true
theorem bodyJs14 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s327.next PRE_first_tail_x4_L8_r0_body.s329 :=
  JsHeapAbove.glueSite bodyJs13 (Nat.le_of_ble_eq_true bodyJsLe14) PRE_first_tail_x4_L8_r0_body.gjk14 PRE_first_tail_x4_L8_r0_body.gjbd14 PRE_first_tail_x4_L8_r0_body.cheap14 PRE_first_tail_x4_L8_r0_body.zclbd14 bodyJsList14

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO307 : PRE_first_tail_x4_L8_r0_body.S307.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S307.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr307 : bridgeOf PRE_first_tail_x4_L8_r0_body.s307.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc307 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s307 PRE_first_tail_x4_L8_r0_body.S307) = fun _ _ => true
kernel_rfl bodyAcc308 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s308 PRE_first_tail_x4_L8_r0_body.S308) = fun _ _ => true
kernel_rfl bodyBr309 : bridgeOf PRE_first_tail_x4_L8_r0_body.s309.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt308 : isHalt PRE_first_tail_x4_L8_r0_body.s308.ctl = false
kernel_rfl bodyTop309 : noRetBlock PRE_first_tail_x4_L8_r0_body.s309 = true
kernel_rfl bodyCnt307 : countersOkB PRE_first_tail_x4_L8_r0_body.s307 PRE_first_tail_x4_L8_r0_body.s309 = true
kernel_rfl bodyO309 : PRE_first_tail_x4_L8_r0_body.S309.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S309.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr310 : bridgeOf PRE_first_tail_x4_L8_r0_body.s310.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt309 : countersOkB PRE_first_tail_x4_L8_r0_body.s309 PRE_first_tail_x4_L8_r0_body.s310 = true
kernel_rfl bodyO310 : PRE_first_tail_x4_L8_r0_body.S310.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S310.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc310 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s310 PRE_first_tail_x4_L8_r0_body.S310) = fun _ _ => true
kernel_rfl bodyAcc314 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s314 PRE_first_tail_x4_L8_r0_body.S314) = fun _ _ => true
kernel_rfl bodyBr315 : bridgeOf PRE_first_tail_x4_L8_r0_body.s315.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt314 : isHalt PRE_first_tail_x4_L8_r0_body.s314.ctl = false
kernel_rfl bodyTop315 : noRetBlock PRE_first_tail_x4_L8_r0_body.s315 = true
kernel_rfl bodyCnt310 : countersOkB PRE_first_tail_x4_L8_r0_body.s310 PRE_first_tail_x4_L8_r0_body.s315 = true
kernel_rfl bodyO315 : PRE_first_tail_x4_L8_r0_body.S315.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S315.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr316 : bridgeOf PRE_first_tail_x4_L8_r0_body.s316.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt315 : countersOkB PRE_first_tail_x4_L8_r0_body.s315 PRE_first_tail_x4_L8_r0_body.s316 = true
kernel_rfl bodyO316 : PRE_first_tail_x4_L8_r0_body.S316.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S316.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc316 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s316 PRE_first_tail_x4_L8_r0_body.S316) = fun _ _ => true
kernel_rfl bodyAcc317 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s317 PRE_first_tail_x4_L8_r0_body.S317) = fun _ _ => true
kernel_rfl bodyBr318 : bridgeOf PRE_first_tail_x4_L8_r0_body.s318.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt317 : isHalt PRE_first_tail_x4_L8_r0_body.s317.ctl = false
kernel_rfl bodyTop318 : noRetBlock PRE_first_tail_x4_L8_r0_body.s318 = true
kernel_rfl bodyCnt316 : countersOkB PRE_first_tail_x4_L8_r0_body.s316 PRE_first_tail_x4_L8_r0_body.s318 = true
kernel_rfl bodyO318 : PRE_first_tail_x4_L8_r0_body.S318.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S318.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr319 : bridgeOf PRE_first_tail_x4_L8_r0_body.s319.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt318 : countersOkB PRE_first_tail_x4_L8_r0_body.s318 PRE_first_tail_x4_L8_r0_body.s319 = true
kernel_rfl bodyO319 : PRE_first_tail_x4_L8_r0_body.S319.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S319.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc319 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s319 PRE_first_tail_x4_L8_r0_body.S319) = fun _ _ => true
kernel_rfl bodyAcc320 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s320 PRE_first_tail_x4_L8_r0_body.S320) = fun _ _ => true
kernel_rfl bodyBr321 : bridgeOf PRE_first_tail_x4_L8_r0_body.s321.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt320 : isHalt PRE_first_tail_x4_L8_r0_body.s320.ctl = false
kernel_rfl bodyTop321 : noRetBlock PRE_first_tail_x4_L8_r0_body.s321 = true
kernel_rfl bodyCnt319 : countersOkB PRE_first_tail_x4_L8_r0_body.s319 PRE_first_tail_x4_L8_r0_body.s321 = true
kernel_rfl bodyO321 : PRE_first_tail_x4_L8_r0_body.S321.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S321.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr322 : bridgeOf PRE_first_tail_x4_L8_r0_body.s322.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt321 : countersOkB PRE_first_tail_x4_L8_r0_body.s321 PRE_first_tail_x4_L8_r0_body.s322 = true
kernel_rfl bodyO322 : PRE_first_tail_x4_L8_r0_body.S322.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S322.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc322 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s322 PRE_first_tail_x4_L8_r0_body.S322) = fun _ _ => true
kernel_rfl bodyAcc323 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s323 PRE_first_tail_x4_L8_r0_body.S323) = fun _ _ => true
kernel_rfl bodyBr324 : bridgeOf PRE_first_tail_x4_L8_r0_body.s324.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt323 : isHalt PRE_first_tail_x4_L8_r0_body.s323.ctl = false
kernel_rfl bodyTop324 : noRetBlock PRE_first_tail_x4_L8_r0_body.s324 = true
kernel_rfl bodyCnt322 : countersOkB PRE_first_tail_x4_L8_r0_body.s322 PRE_first_tail_x4_L8_r0_body.s324 = true
kernel_rfl bodyO324 : PRE_first_tail_x4_L8_r0_body.S324.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S324.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr325 : bridgeOf PRE_first_tail_x4_L8_r0_body.s325.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt324 : countersOkB PRE_first_tail_x4_L8_r0_body.s324 PRE_first_tail_x4_L8_r0_body.s325 = true
kernel_rfl bodyO325 : PRE_first_tail_x4_L8_r0_body.S325.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S325.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc325 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s325 PRE_first_tail_x4_L8_r0_body.S325) = fun _ _ => true
kernel_rfl bodyAcc326 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s326 PRE_first_tail_x4_L8_r0_body.S326) = fun _ _ => true
kernel_rfl bodyBr327 : bridgeOf PRE_first_tail_x4_L8_r0_body.s327.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt326 : isHalt PRE_first_tail_x4_L8_r0_body.s326.ctl = false
kernel_rfl bodyTop327 : noRetBlock PRE_first_tail_x4_L8_r0_body.s327 = true
kernel_rfl bodyCnt325 : countersOkB PRE_first_tail_x4_L8_r0_body.s325 PRE_first_tail_x4_L8_r0_body.s327 = true

theorem bodyGlue14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s307 PRE_first_tail_x4_L8_r0_body.S307)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s327 PRE_first_tail_x4_L8_r0_body.S327) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) bodyAcc307 PRE_first_tail_x4_L8_r0_body.bodyRunSeg80 bodyAcc308 bodyHalt308 PRE_first_tail_x4_L8_r0_body.bodyStepA81 bodyTop309 (fun _ hm => bodyO307 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr307).trans bodyInactive0) (bodyBr309.trans bodyBr307.symm) bodyCnt307 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA81 PRE_first_tail_x4_L8_r0_body.sizeArgsA81 PRE_first_tail_x4_L8_r0_body.sizeSymA81 PRE_first_tail_x4_L8_r0_body.sizeMlxA81 PRE_first_tail_x4_L8_r0_body.sizePayA81 PRE_first_tail_x4_L8_r0_body.sizeTaA81 PRE_first_tail_x4_L8_r0_body.sizeDecA81 PRE_first_tail_x4_L8_r0_body.sizePreA81 PRE_first_tail_x4_L8_r0_body.bodyPatchB81 (fun _ hm => bodyO309 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr309).trans bodyInactive0) (bodyBr310.trans bodyBr309.symm) bodyCnt309 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) bodyAcc310 PRE_first_tail_x4_L8_r0_body.bodyRunSeg81 bodyAcc314 bodyHalt314 PRE_first_tail_x4_L8_r0_body.bodyStepA82 bodyTop315 (fun _ hm => bodyO310 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr310).trans bodyInactive0) (bodyBr315.trans bodyBr310.symm) bodyCnt310 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA82 PRE_first_tail_x4_L8_r0_body.sizeArgsA82 PRE_first_tail_x4_L8_r0_body.sizeSymA82 PRE_first_tail_x4_L8_r0_body.sizeMlxA82 PRE_first_tail_x4_L8_r0_body.sizePayA82 PRE_first_tail_x4_L8_r0_body.sizeTaA82 PRE_first_tail_x4_L8_r0_body.sizeDecA82 PRE_first_tail_x4_L8_r0_body.sizePreA82 PRE_first_tail_x4_L8_r0_body.bodyPatchB82 (fun _ hm => bodyO315 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr315).trans bodyInactive0) (bodyBr316.trans bodyBr315.symm) bodyCnt315 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) bodyAcc316 PRE_first_tail_x4_L8_r0_body.bodyRunSeg82 bodyAcc317 bodyHalt317 PRE_first_tail_x4_L8_r0_body.bodyStepA83 bodyTop318 (fun _ hm => bodyO316 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr316).trans bodyInactive0) (bodyBr318.trans bodyBr316.symm) bodyCnt316 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA83 PRE_first_tail_x4_L8_r0_body.sizeArgsA83 PRE_first_tail_x4_L8_r0_body.sizeSymA83 PRE_first_tail_x4_L8_r0_body.sizeMlxA83 PRE_first_tail_x4_L8_r0_body.sizePayA83 PRE_first_tail_x4_L8_r0_body.sizeTaA83 PRE_first_tail_x4_L8_r0_body.sizeDecA83 PRE_first_tail_x4_L8_r0_body.sizePreA83 PRE_first_tail_x4_L8_r0_body.bodyPatchB83 (fun _ hm => bodyO318 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr318).trans bodyInactive0) (bodyBr319.trans bodyBr318.symm) bodyCnt318 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) bodyAcc319 PRE_first_tail_x4_L8_r0_body.bodyRunSeg83 bodyAcc320 bodyHalt320 PRE_first_tail_x4_L8_r0_body.bodyStepA84 bodyTop321 (fun _ hm => bodyO319 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr319).trans bodyInactive0) (bodyBr321.trans bodyBr319.symm) bodyCnt319 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA84 PRE_first_tail_x4_L8_r0_body.sizeArgsA84 PRE_first_tail_x4_L8_r0_body.sizeSymA84 PRE_first_tail_x4_L8_r0_body.sizeMlxA84 PRE_first_tail_x4_L8_r0_body.sizePayA84 PRE_first_tail_x4_L8_r0_body.sizeTaA84 PRE_first_tail_x4_L8_r0_body.sizeDecA84 PRE_first_tail_x4_L8_r0_body.sizePreA84 PRE_first_tail_x4_L8_r0_body.bodyPatchB84 (fun _ hm => bodyO321 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr321).trans bodyInactive0) (bodyBr322.trans bodyBr321.symm) bodyCnt321 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) bodyAcc322 PRE_first_tail_x4_L8_r0_body.bodyRunSeg84 bodyAcc323 bodyHalt323 PRE_first_tail_x4_L8_r0_body.bodyStepA85 bodyTop324 (fun _ hm => bodyO322 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr322).trans bodyInactive0) (bodyBr324.trans bodyBr322.symm) bodyCnt322 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA85 PRE_first_tail_x4_L8_r0_body.sizeArgsA85 PRE_first_tail_x4_L8_r0_body.sizeSymA85 PRE_first_tail_x4_L8_r0_body.sizeMlxA85 PRE_first_tail_x4_L8_r0_body.sizePayA85 PRE_first_tail_x4_L8_r0_body.sizeTaA85 PRE_first_tail_x4_L8_r0_body.sizeDecA85 PRE_first_tail_x4_L8_r0_body.sizePreA85 PRE_first_tail_x4_L8_r0_body.bodyPatchB85 (fun _ hm => bodyO324 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr324).trans bodyInactive0) (bodyBr325.trans bodyBr324.symm) bodyCnt324 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17803, 302, 0, 0⟩) bodyAcc325 PRE_first_tail_x4_L8_r0_body.bodyRunSeg85 bodyAcc326 bodyHalt326 PRE_first_tail_x4_L8_r0_body.bodyStepA86 bodyTop327 (fun _ hm => bodyO325 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr325).trans bodyInactive0) (bodyBr327.trans bodyBr325.symm) bodyCnt325 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift14 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S327.tab.length PRE_first_tail_x4_L8_r0_body.s327.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P14.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P14 15 PRE_first_tail_x4_L8_r0_body.kappa14 PRE_first_tail_x4_L8_r0_body.s329.ffi PRE_first_tail_x4_L8_r0_body.s328.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_14
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_14
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s329.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S327.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_14] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK14 PRE_first_tail_x4_L8_r0_body.cobjsK14
      PRE_first_tail_x4_L8_r0_body.citemsK14 PRE_first_tail_x4_L8_r0_body.cbd14 PRE_first_tail_x4_L8_r0_body.csst14
  exact PRE_first_tail_x4_L8_r0_body.cshift14 bodyNcl14 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_14] at this; exact this)


kernel_rfl bodyFramesEmpty14 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s328 a).isEmpty) = true
kernel_rfl bodyJsRoots14 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s327.next) PRE_first_tail_x4_L8_r0_body.s329.trace PRE_first_tail_x4_L8_r0_body.s329 = true
kernel_rfl bodyJsNative14 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s329.ffi) = true
kernel_rfl bodyLow14 : (PRE_first_tail_x4_L8_r0_body.cws14 ++ PRE_first_tail_x4_L8_r0_body.ws14).all (Nat.ble 9) = true
kernel_rfl bodyCntM14 : countersOkB PRE_first_tail_x4_L8_r0_body.s327 PRE_first_tail_x4_L8_r0_body.s328 = true
kernel_rfl bodyHi14 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s329.ffi).next setupP.E = true
kernel_rfl bodyNhi14 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s329.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge14 : bridgeOf PRE_first_tail_x4_L8_r0_body.s328.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s327.ffi
kernel_rfl bodyNN14 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s327.ffi).nnext PRE_first_tail_x4_L8_r0_body.P14.NL = true
kernel_rfl bodyXn14 : Nat.ble (⟨19080, 16181, 2709945, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s329.ffi).next = true
kernel_rfl bodyLo14 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s329.ffi).next = true
theorem bodyFacts14 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s327 PRE_first_tail_x4_L8_r0_body.s328 PRE_first_tail_x4_L8_r0_body.s329 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S327 PRE_first_tail_x4_L8_r0_body.S328 PRE_first_tail_x4_L8_r0_body.S329
    PRE_first_tail_x4_L8_r0_body.ws14 PRE_first_tail_x4_L8_r0_body.cws14 PRE_first_tail_x4_L8_r0_body.nr14 PRE_first_tail_x4_L8_r0_body.pl14 PRE_first_tail_x4_L8_r0_body.cl14 2711094 15 PRE_first_tail_x4_L8_r0_body.kd14 PRE_first_tail_x4_L8_r0_body.kappa14 PRE_first_tail_x4_L8_r0_body.P14
    ⟨19077, 16154, 2709939, 15⟩ ⟨19080, 16181, 2709945, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap14
  clean := bodyClean14
  cfix := PRE_first_tail_x4_L8_r0_body.cfix14
  zpl := PRE_first_tail_x4_L8_r0_body.zpl14
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd14
  zn1 := PRE_first_tail_x4_L8_r0_body.zn114
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst14
  zscn := PRE_first_tail_x4_L8_r0_body.zscn14
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn14
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow14
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab14
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh14
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd14
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi14
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt14
  zgP := PRE_first_tail_x4_L8_r0_body.zg14_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk14_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm14_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg14_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk14_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm14_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw14_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw14_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap14
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd14
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap14 PRE_first_tail_x4_L8_r0_body.stFoot14 PRE_first_tail_x4_L8_r0_body.iso14 PRE_first_tail_x4_L8_r0_body.zwr14
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP14
  csupp := PRE_first_tail_x4_L8_r0_body.csupp14
  cbound := PRE_first_tail_x4_L8_r0_body.cbound14
  zimg := PRE_first_tail_x4_L8_r0_body.zimg14
  zctl := PRE_first_tail_x4_L8_r0_body.zctl14
  zstack := PRE_first_tail_x4_L8_r0_body.zstack14
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs14
  zstores := PRE_first_tail_x4_L8_r0_body.zstores14
  zroots := PRE_first_tail_x4_L8_r0_body.zroots14
  znC := PRE_first_tail_x4_L8_r0_body.znC14
  ctab := PRE_first_tail_x4_L8_r0_body.ctab14
  zbin := PRE_first_tail_x4_L8_r0_body.zbin14
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge14
  sbridge := bodyBridge14
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj14
  cshiftR := fun h hNL => bodyCshift14 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN14
  raised := PRE_first_tail_x4_L8_r0_body.raised14
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs14
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl14
  xnLe := Nat.le_of_ble_eq_true bodyXn14
  loLe := Nat.le_of_ble_eq_true bodyLo14
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB14
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
noncomputable def bodyEs14 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr14.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st14.S5.tab r
kernel_rfl bodyResChk14 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs14 bodyQs14) = true
kernel_rfl bodyLq14 : bodyQs14.length = PRE_first_tail_x4_L8_r0_body.cws14.length
kernel_rfl bodyNrLo14 : PRE_first_tail_x4_L8_r0_body.nr14.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S327.tab.length) = true
kernel_rfl bodySub14 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site14.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost14 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws14 PRE_first_tail_x4_L8_r0_body.cws14 bodyQs14 = true
kernel_rfl bodyDrop14 : Nat.ble (17803 + (PRE_first_tail_x4_L8_r0_body.s328.next - PRE_first_tail_x4_L8_r0_body.s329.next)) 18952 = true
kernel_rfl bodyDropH14 : Nat.ble (302 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s328.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s329.ffi).next)) 327 = true
kernel_rfl bodyDropN14 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s328.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s329.ffi).nnext)) 0 = true
kernel_rfl bodyDv14 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws14
kernel_rfl bodyDe14 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr14.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st14.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl14 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold14 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws14).isNone && !PRE_first_tail_x4_L8_r0_body.ws14.contains v) = true
kernel_rfl bodyDfree14 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws14 ++ PRE_first_tail_x4_L8_r0_body.ws14).all fun w => e.noVar w) = true

theorem bodyStep14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17803, 302, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s327 PRE_first_tail_x4_L8_r0_body.S327)
      (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s329 PRE_first_tail_x4_L8_r0_body.S329) (11334 + 1) :=
  bodySite bodyFacts14.cfix bodyFacts14.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st14.S5.tab) (Es := bodyEs14) (qs := bodyQs14)
    (ok := PRE_first_tail_x4_L8_r0_body.st14.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site14 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts14
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site14 r hr) hi (MapOk.sub hm (sub_of_all bodySub14)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk14 r hr) hi hm ho hq)
    bodyLq14 rfl bodyNrLo14 (postSub_sound bodyPost14)
    (Nat.le_of_ble_eq_true bodyDrop14) (by decide) (Nat.le_of_ble_eq_true bodyDropH14) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN14) (by decide)
    bodyDv14 bodyDe14 bodyDl14 bodyDold14 bodyDfree14 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site15 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site15 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site15) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st15.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site15
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st15.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st15.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s348 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s349 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S348 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws15 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st15.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st15.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso15
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_15
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st15.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot15
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup15
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound15
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace15
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged15
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws15.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st15.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S348.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_15]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen15.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh15
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl15 : Conv.NClean (⟨19140, 16226, 2712442, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s348.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl15 (PRE_first_tail_x4_L8_r0_body.cncl14 bodyNcl14)

theorem bodyClean15 : Conv.JClean (⟨19140, 16226, 2712442, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s348 :=
  PRE_first_tail_x4_L8_r0_body.gjcl15 (PRE_first_tail_x4_L8_r0_body.cjcl14 bodyClean14)

kernel_rfl bodyJsLe15 : Nat.ble PRE_first_tail_x4_L8_r0_body.s327.next PRE_first_tail_x4_L8_r0_body.s348.next = true
kernel_rfl bodyJsList15 : (PRE_first_tail_x4_L8_r0_body.gjh15 ++ PRE_first_tail_x4_L8_r0_body.cl15).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s348.next) PRE_first_tail_x4_L8_r0_body.s350) = true
theorem bodyJs15 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s348.next PRE_first_tail_x4_L8_r0_body.s350 :=
  JsHeapAbove.glueSite bodyJs14 (Nat.le_of_ble_eq_true bodyJsLe15) PRE_first_tail_x4_L8_r0_body.gjk15 PRE_first_tail_x4_L8_r0_body.gjbd15 PRE_first_tail_x4_L8_r0_body.cheap15 PRE_first_tail_x4_L8_r0_body.zclbd15 bodyJsList15

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO329 : PRE_first_tail_x4_L8_r0_body.S329.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S329.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr329 : bridgeOf PRE_first_tail_x4_L8_r0_body.s329.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc329 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s329 PRE_first_tail_x4_L8_r0_body.S329) = fun _ _ => true
kernel_rfl bodyAcc330 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s330 PRE_first_tail_x4_L8_r0_body.S330) = fun _ _ => true
kernel_rfl bodyBr331 : bridgeOf PRE_first_tail_x4_L8_r0_body.s331.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt330 : isHalt PRE_first_tail_x4_L8_r0_body.s330.ctl = false
kernel_rfl bodyTop331 : noRetBlock PRE_first_tail_x4_L8_r0_body.s331 = true
kernel_rfl bodyCnt329 : countersOkB PRE_first_tail_x4_L8_r0_body.s329 PRE_first_tail_x4_L8_r0_body.s331 = true
kernel_rfl bodyO331 : PRE_first_tail_x4_L8_r0_body.S331.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S331.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr332 : bridgeOf PRE_first_tail_x4_L8_r0_body.s332.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt331 : countersOkB PRE_first_tail_x4_L8_r0_body.s331 PRE_first_tail_x4_L8_r0_body.s332 = true
kernel_rfl bodyO332 : PRE_first_tail_x4_L8_r0_body.S332.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S332.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc332 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s332 PRE_first_tail_x4_L8_r0_body.S332) = fun _ _ => true
kernel_rfl bodyAcc336 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s336 PRE_first_tail_x4_L8_r0_body.S336) = fun _ _ => true
kernel_rfl bodyBr337 : bridgeOf PRE_first_tail_x4_L8_r0_body.s337.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt336 : isHalt PRE_first_tail_x4_L8_r0_body.s336.ctl = false
kernel_rfl bodyTop337 : noRetBlock PRE_first_tail_x4_L8_r0_body.s337 = true
kernel_rfl bodyCnt332 : countersOkB PRE_first_tail_x4_L8_r0_body.s332 PRE_first_tail_x4_L8_r0_body.s337 = true
kernel_rfl bodyO337 : PRE_first_tail_x4_L8_r0_body.S337.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S337.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr338 : bridgeOf PRE_first_tail_x4_L8_r0_body.s338.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt337 : countersOkB PRE_first_tail_x4_L8_r0_body.s337 PRE_first_tail_x4_L8_r0_body.s338 = true
kernel_rfl bodyO338 : PRE_first_tail_x4_L8_r0_body.S338.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S338.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc338 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s338 PRE_first_tail_x4_L8_r0_body.S338) = fun _ _ => true
kernel_rfl bodyAcc340 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s340 PRE_first_tail_x4_L8_r0_body.S340) = fun _ _ => true
kernel_rfl bodyBr341 : bridgeOf PRE_first_tail_x4_L8_r0_body.s341.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt340 : isHalt PRE_first_tail_x4_L8_r0_body.s340.ctl = false
kernel_rfl bodyTop341 : noRetBlock PRE_first_tail_x4_L8_r0_body.s341 = true
kernel_rfl bodyCnt338 : countersOkB PRE_first_tail_x4_L8_r0_body.s338 PRE_first_tail_x4_L8_r0_body.s341 = true
kernel_rfl bodyO341 : PRE_first_tail_x4_L8_r0_body.S341.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S341.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr342 : bridgeOf PRE_first_tail_x4_L8_r0_body.s342.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt341 : countersOkB PRE_first_tail_x4_L8_r0_body.s341 PRE_first_tail_x4_L8_r0_body.s342 = true
kernel_rfl bodyO342 : PRE_first_tail_x4_L8_r0_body.S342.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S342.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc342 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s342 PRE_first_tail_x4_L8_r0_body.S342) = fun _ _ => true
kernel_rfl bodyAcc343 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s343 PRE_first_tail_x4_L8_r0_body.S343) = fun _ _ => true
kernel_rfl bodyBr344 : bridgeOf PRE_first_tail_x4_L8_r0_body.s344.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt343 : isHalt PRE_first_tail_x4_L8_r0_body.s343.ctl = false
kernel_rfl bodyTop344 : noRetBlock PRE_first_tail_x4_L8_r0_body.s344 = true
kernel_rfl bodyCnt342 : countersOkB PRE_first_tail_x4_L8_r0_body.s342 PRE_first_tail_x4_L8_r0_body.s344 = true
kernel_rfl bodyO344 : PRE_first_tail_x4_L8_r0_body.S344.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S344.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr345 : bridgeOf PRE_first_tail_x4_L8_r0_body.s345.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt344 : countersOkB PRE_first_tail_x4_L8_r0_body.s344 PRE_first_tail_x4_L8_r0_body.s345 = true
kernel_rfl bodyO345 : PRE_first_tail_x4_L8_r0_body.S345.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S345.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc345 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s345 PRE_first_tail_x4_L8_r0_body.S345) = fun _ _ => true
kernel_rfl bodyAcc347 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s347 PRE_first_tail_x4_L8_r0_body.S347) = fun _ _ => true
kernel_rfl bodyBr348 : bridgeOf PRE_first_tail_x4_L8_r0_body.s348.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt347 : isHalt PRE_first_tail_x4_L8_r0_body.s347.ctl = false
kernel_rfl bodyTop348 : noRetBlock PRE_first_tail_x4_L8_r0_body.s348 = true
kernel_rfl bodyCnt345 : countersOkB PRE_first_tail_x4_L8_r0_body.s345 PRE_first_tail_x4_L8_r0_body.s348 = true

theorem bodyGlue15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s329 PRE_first_tail_x4_L8_r0_body.S329)
      (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s348 PRE_first_tail_x4_L8_r0_body.S348) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) bodyAcc329 PRE_first_tail_x4_L8_r0_body.bodyRunSeg86 bodyAcc330 bodyHalt330 PRE_first_tail_x4_L8_r0_body.bodyStepA87 bodyTop331 (fun _ hm => bodyO329 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr329).trans bodyInactive0) (bodyBr331.trans bodyBr329.symm) bodyCnt329 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA87 PRE_first_tail_x4_L8_r0_body.sizeArgsA87 PRE_first_tail_x4_L8_r0_body.sizeSymA87 PRE_first_tail_x4_L8_r0_body.sizeMlxA87 PRE_first_tail_x4_L8_r0_body.sizePayA87 PRE_first_tail_x4_L8_r0_body.sizeTaA87 PRE_first_tail_x4_L8_r0_body.sizeDecA87 PRE_first_tail_x4_L8_r0_body.sizePreA87 PRE_first_tail_x4_L8_r0_body.bodyPatchB87 (fun _ hm => bodyO331 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr331).trans bodyInactive0) (bodyBr332.trans bodyBr331.symm) bodyCnt331 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) bodyAcc332 PRE_first_tail_x4_L8_r0_body.bodyRunSeg87 bodyAcc336 bodyHalt336 PRE_first_tail_x4_L8_r0_body.bodyStepA88 bodyTop337 (fun _ hm => bodyO332 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr332).trans bodyInactive0) (bodyBr337.trans bodyBr332.symm) bodyCnt332 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA88 PRE_first_tail_x4_L8_r0_body.sizeArgsA88 PRE_first_tail_x4_L8_r0_body.sizeSymA88 PRE_first_tail_x4_L8_r0_body.sizeMlxA88 PRE_first_tail_x4_L8_r0_body.sizePayA88 PRE_first_tail_x4_L8_r0_body.sizeTaA88 PRE_first_tail_x4_L8_r0_body.sizeDecA88 PRE_first_tail_x4_L8_r0_body.sizePreA88 PRE_first_tail_x4_L8_r0_body.bodyPatchB88 (fun _ hm => bodyO337 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr337).trans bodyInactive0) (bodyBr338.trans bodyBr337.symm) bodyCnt337 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) bodyAcc338 PRE_first_tail_x4_L8_r0_body.bodyRunSeg88 bodyAcc340 bodyHalt340 PRE_first_tail_x4_L8_r0_body.bodyStepA89 bodyTop341 (fun _ hm => bodyO338 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr338).trans bodyInactive0) (bodyBr341.trans bodyBr338.symm) bodyCnt338 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA89 PRE_first_tail_x4_L8_r0_body.sizeArgsA89 PRE_first_tail_x4_L8_r0_body.sizeSymA89 PRE_first_tail_x4_L8_r0_body.sizeMlxA89 PRE_first_tail_x4_L8_r0_body.sizePayA89 PRE_first_tail_x4_L8_r0_body.sizeTaA89 PRE_first_tail_x4_L8_r0_body.sizeDecA89 PRE_first_tail_x4_L8_r0_body.sizePreA89 PRE_first_tail_x4_L8_r0_body.bodyPatchB89 (fun _ hm => bodyO341 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr341).trans bodyInactive0) (bodyBr342.trans bodyBr341.symm) bodyCnt341 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) bodyAcc342 PRE_first_tail_x4_L8_r0_body.bodyRunSeg89 bodyAcc343 bodyHalt343 PRE_first_tail_x4_L8_r0_body.bodyStepA90 bodyTop344 (fun _ hm => bodyO342 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr342).trans bodyInactive0) (bodyBr344.trans bodyBr342.symm) bodyCnt342 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA90 PRE_first_tail_x4_L8_r0_body.sizeArgsA90 PRE_first_tail_x4_L8_r0_body.sizeSymA90 PRE_first_tail_x4_L8_r0_body.sizeMlxA90 PRE_first_tail_x4_L8_r0_body.sizePayA90 PRE_first_tail_x4_L8_r0_body.sizeTaA90 PRE_first_tail_x4_L8_r0_body.sizeDecA90 PRE_first_tail_x4_L8_r0_body.sizePreA90 PRE_first_tail_x4_L8_r0_body.bodyPatchB90 (fun _ hm => bodyO344 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr344).trans bodyInactive0) (bodyBr345.trans bodyBr344.symm) bodyCnt344 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨18952, 327, 0, 0⟩) bodyAcc345 PRE_first_tail_x4_L8_r0_body.bodyRunSeg90 bodyAcc347 bodyHalt347 PRE_first_tail_x4_L8_r0_body.bodyStepA91 bodyTop348 (fun _ hm => bodyO345 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr345).trans bodyInactive0) (bodyBr348.trans bodyBr345.symm) bodyCnt345 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift15 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S348.tab.length PRE_first_tail_x4_L8_r0_body.s348.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P15.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P15 15 PRE_first_tail_x4_L8_r0_body.kappa15 PRE_first_tail_x4_L8_r0_body.s350.ffi PRE_first_tail_x4_L8_r0_body.s349.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_15
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_15
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s350.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S348.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_15] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK15 PRE_first_tail_x4_L8_r0_body.cobjsK15
      PRE_first_tail_x4_L8_r0_body.citemsK15 PRE_first_tail_x4_L8_r0_body.cbd15 PRE_first_tail_x4_L8_r0_body.csst15
  exact PRE_first_tail_x4_L8_r0_body.cshift15 bodyNcl15 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_15] at this; exact this)


kernel_rfl bodyFramesEmpty15 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s349 a).isEmpty) = true
kernel_rfl bodyJsRoots15 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s348.next) PRE_first_tail_x4_L8_r0_body.s350.trace PRE_first_tail_x4_L8_r0_body.s350 = true
kernel_rfl bodyJsNative15 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s350.ffi) = true
kernel_rfl bodyLow15 : (PRE_first_tail_x4_L8_r0_body.cws15 ++ PRE_first_tail_x4_L8_r0_body.ws15).all (Nat.ble 9) = true
kernel_rfl bodyCntM15 : countersOkB PRE_first_tail_x4_L8_r0_body.s348 PRE_first_tail_x4_L8_r0_body.s349 = true
kernel_rfl bodyHi15 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s350.ffi).next setupP.E = true
kernel_rfl bodyNhi15 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s350.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge15 : bridgeOf PRE_first_tail_x4_L8_r0_body.s349.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s348.ffi
kernel_rfl bodyNN15 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s348.ffi).nnext PRE_first_tail_x4_L8_r0_body.P15.NL = true
kernel_rfl bodyXn15 : Nat.ble (⟨19144, 16232, 2712457, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s350.ffi).next = true
kernel_rfl bodyLo15 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s350.ffi).next = true
theorem bodyFacts15 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s348 PRE_first_tail_x4_L8_r0_body.s349 PRE_first_tail_x4_L8_r0_body.s350 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S348 PRE_first_tail_x4_L8_r0_body.S349 PRE_first_tail_x4_L8_r0_body.S350
    PRE_first_tail_x4_L8_r0_body.ws15 PRE_first_tail_x4_L8_r0_body.cws15 PRE_first_tail_x4_L8_r0_body.nr15 PRE_first_tail_x4_L8_r0_body.pl15 PRE_first_tail_x4_L8_r0_body.cl15 2712807 15 PRE_first_tail_x4_L8_r0_body.kd15 PRE_first_tail_x4_L8_r0_body.kappa15 PRE_first_tail_x4_L8_r0_body.P15
    ⟨19140, 16226, 2712442, 15⟩ ⟨19144, 16232, 2712457, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap15
  clean := bodyClean15
  cfix := PRE_first_tail_x4_L8_r0_body.cfix15
  zpl := PRE_first_tail_x4_L8_r0_body.zpl15
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd15
  zn1 := PRE_first_tail_x4_L8_r0_body.zn115
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst15
  zscn := PRE_first_tail_x4_L8_r0_body.zscn15
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn15
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow15
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab15
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh15
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd15
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi15
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt15
  zgP := PRE_first_tail_x4_L8_r0_body.zg15_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk15_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm15_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg15_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk15_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm15_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw15_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw15_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap15
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd15
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap15 PRE_first_tail_x4_L8_r0_body.stFoot15 PRE_first_tail_x4_L8_r0_body.iso15 PRE_first_tail_x4_L8_r0_body.zwr15
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP15
  csupp := PRE_first_tail_x4_L8_r0_body.csupp15
  cbound := PRE_first_tail_x4_L8_r0_body.cbound15
  zimg := PRE_first_tail_x4_L8_r0_body.zimg15
  zctl := PRE_first_tail_x4_L8_r0_body.zctl15
  zstack := PRE_first_tail_x4_L8_r0_body.zstack15
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs15
  zstores := PRE_first_tail_x4_L8_r0_body.zstores15
  zroots := PRE_first_tail_x4_L8_r0_body.zroots15
  znC := PRE_first_tail_x4_L8_r0_body.znC15
  ctab := PRE_first_tail_x4_L8_r0_body.ctab15
  zbin := PRE_first_tail_x4_L8_r0_body.zbin15
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge15
  sbridge := bodyBridge15
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj15
  cshiftR := fun h hNL => bodyCshift15 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN15
  raised := PRE_first_tail_x4_L8_r0_body.raised15
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs15
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl15
  xnLe := Nat.le_of_ble_eq_true bodyXn15
  loLe := Nat.le_of_ble_eq_true bodyLo15
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB15
  cntM := bodyCntM15
  hiLe := Nat.le_of_ble_eq_true bodyHi15
  nhiLe := Nat.le_of_ble_eq_true bodyNhi15
  jsHeap := bodyJs15
  jsRoots := bodyJsRoots15
  jsNative := bodyJsNative15
  framesEmpty := bodyFramesEmpty15
  trailOld := by decide
  lowVars := bodyLow15

def bodyQs15 : List (Option Q) := []
noncomputable def bodyEs15 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr15.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st15.S3.tab r
kernel_rfl bodyResChk15 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs15 bodyQs15) = true
kernel_rfl bodyLq15 : bodyQs15.length = PRE_first_tail_x4_L8_r0_body.cws15.length
kernel_rfl bodyNrLo15 : PRE_first_tail_x4_L8_r0_body.nr15.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S348.tab.length) = true
kernel_rfl bodySub15 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site15.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost15 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws15 PRE_first_tail_x4_L8_r0_body.cws15 bodyQs15 = true
kernel_rfl bodyDrop15 : Nat.ble (18952 + (PRE_first_tail_x4_L8_r0_body.s349.next - PRE_first_tail_x4_L8_r0_body.s350.next)) 19302 = true
kernel_rfl bodyDropH15 : Nat.ble (327 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s349.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s350.ffi).next)) 329 = true
kernel_rfl bodyDropN15 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s349.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s350.ffi).nnext)) 0 = true
kernel_rfl bodyDv15 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws15
kernel_rfl bodyDe15 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr15.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st15.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl15 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold15 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws15).isNone && !PRE_first_tail_x4_L8_r0_body.ws15.contains v) = true
kernel_rfl bodyDfree15 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws15 ++ PRE_first_tail_x4_L8_r0_body.ws15).all fun w => e.noVar w) = true

theorem bodyStep15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨18952, 327, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s348 PRE_first_tail_x4_L8_r0_body.S348)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19302, 329, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s350 PRE_first_tail_x4_L8_r0_body.S350) (3452 + 1) :=
  bodySite bodyFacts15.cfix bodyFacts15.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L8_r0_body.st15.S3.tab) (Es := bodyEs15) (qs := bodyQs15)
    (ok := PRE_first_tail_x4_L8_r0_body.st15.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site15 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts15
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site15 r hr) hi (MapOk.sub hm (sub_of_all bodySub15)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk15 r hr) hi hm ho hq)
    bodyLq15 rfl bodyNrLo15 (postSub_sound bodyPost15)
    (Nat.le_of_ble_eq_true bodyDrop15) (by decide) (Nat.le_of_ble_eq_true bodyDropH15) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN15) (by decide)
    bodyDv15 bodyDe15 bodyDl15 bodyDold15 bodyDfree15 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end
