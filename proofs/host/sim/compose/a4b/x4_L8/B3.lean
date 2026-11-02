import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.States
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B18
import host.sim.compose.a4b.x4_L8.B2
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B24
import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L8.VWBodyChain
import host.sim.compose.a4b.x4_L8.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B14
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B13
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x4_L8_r0_body.m.B19

section -- VWBodyOracles_6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_g24 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g24 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g24) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site24 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site24 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site24) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st24.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g25 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g25 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g25) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site25 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site25 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site25) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st25.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g26 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g26 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g26) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site26 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site26 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site26) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st26.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g27 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g27 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g27) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site27 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site27 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site27) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st27.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site24 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site24 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site24) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st24.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site24
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st24.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st24.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s550 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s551 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S550 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws24 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st24.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st24.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso24
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_24
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st24.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot24
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup24
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound24
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace24
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged24
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws24.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st24.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S550.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_24]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen24.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh24
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl24 : Conv.NClean (⟨19710, 16778, 2735473, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s550.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl24 (PRE_first_tail_x4_L8_r0_body.cncl23 bodyNcl23)

theorem bodyClean24 : Conv.JClean (⟨19710, 16778, 2735473, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s550 :=
  PRE_first_tail_x4_L8_r0_body.gjcl24 (PRE_first_tail_x4_L8_r0_body.cjcl23 bodyClean23)

kernel_rfl bodyJsLe24 : Nat.ble PRE_first_tail_x4_L8_r0_body.s526.next PRE_first_tail_x4_L8_r0_body.s550.next = true
kernel_rfl bodyJsList24 : (PRE_first_tail_x4_L8_r0_body.gjh24 ++ PRE_first_tail_x4_L8_r0_body.cl24).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s550.next) PRE_first_tail_x4_L8_r0_body.s552) = true
theorem bodyJs24 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s550.next PRE_first_tail_x4_L8_r0_body.s552 :=
  JsHeapAbove.glueSite bodyJs23 (Nat.le_of_ble_eq_true bodyJsLe24) PRE_first_tail_x4_L8_r0_body.gjk24 PRE_first_tail_x4_L8_r0_body.gjbd24 PRE_first_tail_x4_L8_r0_body.cheap24 PRE_first_tail_x4_L8_r0_body.zclbd24 bodyJsList24

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO528 : PRE_first_tail_x4_L8_r0_body.S528.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S528.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr528 : bridgeOf PRE_first_tail_x4_L8_r0_body.s528.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc528 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s528 PRE_first_tail_x4_L8_r0_body.S528) = fun _ _ => true
kernel_rfl bodyAcc531 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s531 PRE_first_tail_x4_L8_r0_body.S531) = fun _ _ => true
kernel_rfl bodyBr532 : bridgeOf PRE_first_tail_x4_L8_r0_body.s532.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt531 : isHalt PRE_first_tail_x4_L8_r0_body.s531.ctl = false
kernel_rfl bodyTop532 : noRetBlock PRE_first_tail_x4_L8_r0_body.s532 = true
kernel_rfl bodyCnt528 : countersOkB PRE_first_tail_x4_L8_r0_body.s528 PRE_first_tail_x4_L8_r0_body.s532 = true
kernel_rfl bodyO532 : PRE_first_tail_x4_L8_r0_body.S532.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S532.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr533 : bridgeOf PRE_first_tail_x4_L8_r0_body.s533.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt532 : countersOkB PRE_first_tail_x4_L8_r0_body.s532 PRE_first_tail_x4_L8_r0_body.s533 = true
kernel_rfl bodyO533 : PRE_first_tail_x4_L8_r0_body.S533.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S533.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc533 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s533 PRE_first_tail_x4_L8_r0_body.S533) = fun _ _ => true
kernel_rfl bodyAcc537 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s537 PRE_first_tail_x4_L8_r0_body.S537) = fun _ _ => true
kernel_rfl bodyBr538 : bridgeOf PRE_first_tail_x4_L8_r0_body.s538.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt537 : isHalt PRE_first_tail_x4_L8_r0_body.s537.ctl = false
kernel_rfl bodyTop538 : noRetBlock PRE_first_tail_x4_L8_r0_body.s538 = true
kernel_rfl bodyCnt533 : countersOkB PRE_first_tail_x4_L8_r0_body.s533 PRE_first_tail_x4_L8_r0_body.s538 = true
kernel_rfl bodyO538 : PRE_first_tail_x4_L8_r0_body.S538.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S538.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr539 : bridgeOf PRE_first_tail_x4_L8_r0_body.s539.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt538 : countersOkB PRE_first_tail_x4_L8_r0_body.s538 PRE_first_tail_x4_L8_r0_body.s539 = true
kernel_rfl bodyO539 : PRE_first_tail_x4_L8_r0_body.S539.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S539.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc539 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s539 PRE_first_tail_x4_L8_r0_body.S539) = fun _ _ => true
kernel_rfl bodyAcc540 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s540 PRE_first_tail_x4_L8_r0_body.S540) = fun _ _ => true
kernel_rfl bodyBr541 : bridgeOf PRE_first_tail_x4_L8_r0_body.s541.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt540 : isHalt PRE_first_tail_x4_L8_r0_body.s540.ctl = false
kernel_rfl bodyTop541 : noRetBlock PRE_first_tail_x4_L8_r0_body.s541 = true
kernel_rfl bodyCnt539 : countersOkB PRE_first_tail_x4_L8_r0_body.s539 PRE_first_tail_x4_L8_r0_body.s541 = true
kernel_rfl bodyO541 : PRE_first_tail_x4_L8_r0_body.S541.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S541.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr542 : bridgeOf PRE_first_tail_x4_L8_r0_body.s542.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt541 : countersOkB PRE_first_tail_x4_L8_r0_body.s541 PRE_first_tail_x4_L8_r0_body.s542 = true
kernel_rfl bodyO542 : PRE_first_tail_x4_L8_r0_body.S542.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S542.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc542 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s542 PRE_first_tail_x4_L8_r0_body.S542) = fun _ _ => true
kernel_rfl bodyAcc543 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s543 PRE_first_tail_x4_L8_r0_body.S543) = fun _ _ => true
kernel_rfl bodyBr544 : bridgeOf PRE_first_tail_x4_L8_r0_body.s544.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt543 : isHalt PRE_first_tail_x4_L8_r0_body.s543.ctl = false
kernel_rfl bodyTop544 : noRetBlock PRE_first_tail_x4_L8_r0_body.s544 = true
kernel_rfl bodyCnt542 : countersOkB PRE_first_tail_x4_L8_r0_body.s542 PRE_first_tail_x4_L8_r0_body.s544 = true
kernel_rfl bodyO544 : PRE_first_tail_x4_L8_r0_body.S544.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S544.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr545 : bridgeOf PRE_first_tail_x4_L8_r0_body.s545.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt544 : countersOkB PRE_first_tail_x4_L8_r0_body.s544 PRE_first_tail_x4_L8_r0_body.s545 = true
kernel_rfl bodyO545 : PRE_first_tail_x4_L8_r0_body.S545.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S545.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc545 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s545 PRE_first_tail_x4_L8_r0_body.S545) = fun _ _ => true
kernel_rfl bodyAcc546 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s546 PRE_first_tail_x4_L8_r0_body.S546) = fun _ _ => true
kernel_rfl bodyBr547 : bridgeOf PRE_first_tail_x4_L8_r0_body.s547.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt546 : isHalt PRE_first_tail_x4_L8_r0_body.s546.ctl = false
kernel_rfl bodyTop547 : noRetBlock PRE_first_tail_x4_L8_r0_body.s547 = true
kernel_rfl bodyCnt545 : countersOkB PRE_first_tail_x4_L8_r0_body.s545 PRE_first_tail_x4_L8_r0_body.s547 = true
kernel_rfl bodyO547 : PRE_first_tail_x4_L8_r0_body.S547.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S547.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr548 : bridgeOf PRE_first_tail_x4_L8_r0_body.s548.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt547 : countersOkB PRE_first_tail_x4_L8_r0_body.s547 PRE_first_tail_x4_L8_r0_body.s548 = true
kernel_rfl bodyO548 : PRE_first_tail_x4_L8_r0_body.S548.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S548.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc548 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s548 PRE_first_tail_x4_L8_r0_body.S548) = fun _ _ => true
kernel_rfl bodyAcc549 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s549 PRE_first_tail_x4_L8_r0_body.S549) = fun _ _ => true
kernel_rfl bodyBr550 : bridgeOf PRE_first_tail_x4_L8_r0_body.s550.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt549 : isHalt PRE_first_tail_x4_L8_r0_body.s549.ctl = false
kernel_rfl bodyTop550 : noRetBlock PRE_first_tail_x4_L8_r0_body.s550 = true
kernel_rfl bodyCnt548 : countersOkB PRE_first_tail_x4_L8_r0_body.s548 PRE_first_tail_x4_L8_r0_body.s550 = true

theorem bodyGlue24 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26896, 483, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s528 PRE_first_tail_x4_L8_r0_body.S528)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26896, 483, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s550 PRE_first_tail_x4_L8_r0_body.S550) 30538 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) bodyAcc528 PRE_first_tail_x4_L8_r0_body.bodyRunSeg137 bodyAcc531 bodyHalt531 PRE_first_tail_x4_L8_r0_body.bodyStepA138 bodyTop532 (fun _ hm => bodyO528 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr528).trans bodyInactive0) (bodyBr532.trans bodyBr528.symm) bodyCnt528 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA138 PRE_first_tail_x4_L8_r0_body.sizeArgsA138 PRE_first_tail_x4_L8_r0_body.sizeSymA138 PRE_first_tail_x4_L8_r0_body.sizeMlxA138 PRE_first_tail_x4_L8_r0_body.sizePayA138 PRE_first_tail_x4_L8_r0_body.sizeTaA138 PRE_first_tail_x4_L8_r0_body.sizeDecA138 PRE_first_tail_x4_L8_r0_body.sizePreA138 PRE_first_tail_x4_L8_r0_body.bodyPatchB138 (fun _ hm => bodyO532 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr532).trans bodyInactive0) (bodyBr533.trans bodyBr532.symm) bodyCnt532 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) bodyAcc533 PRE_first_tail_x4_L8_r0_body.bodyRunSeg138 bodyAcc537 bodyHalt537 PRE_first_tail_x4_L8_r0_body.bodyStepA139 bodyTop538 (fun _ hm => bodyO533 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr533).trans bodyInactive0) (bodyBr538.trans bodyBr533.symm) bodyCnt533 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA139 PRE_first_tail_x4_L8_r0_body.sizeArgsA139 PRE_first_tail_x4_L8_r0_body.sizeSymA139 PRE_first_tail_x4_L8_r0_body.sizeMlxA139 PRE_first_tail_x4_L8_r0_body.sizePayA139 PRE_first_tail_x4_L8_r0_body.sizeTaA139 PRE_first_tail_x4_L8_r0_body.sizeDecA139 PRE_first_tail_x4_L8_r0_body.sizePreA139 PRE_first_tail_x4_L8_r0_body.bodyPatchB139 (fun _ hm => bodyO538 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr538).trans bodyInactive0) (bodyBr539.trans bodyBr538.symm) bodyCnt538 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) bodyAcc539 PRE_first_tail_x4_L8_r0_body.bodyRunSeg139 bodyAcc540 bodyHalt540 PRE_first_tail_x4_L8_r0_body.bodyStepA140 bodyTop541 (fun _ hm => bodyO539 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr539).trans bodyInactive0) (bodyBr541.trans bodyBr539.symm) bodyCnt539 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA140 PRE_first_tail_x4_L8_r0_body.sizeArgsA140 PRE_first_tail_x4_L8_r0_body.sizeSymA140 PRE_first_tail_x4_L8_r0_body.sizeMlxA140 PRE_first_tail_x4_L8_r0_body.sizePayA140 PRE_first_tail_x4_L8_r0_body.sizeTaA140 PRE_first_tail_x4_L8_r0_body.sizeDecA140 PRE_first_tail_x4_L8_r0_body.sizePreA140 PRE_first_tail_x4_L8_r0_body.bodyPatchB140 (fun _ hm => bodyO541 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr541).trans bodyInactive0) (bodyBr542.trans bodyBr541.symm) bodyCnt541 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) bodyAcc542 PRE_first_tail_x4_L8_r0_body.bodyRunSeg140 bodyAcc543 bodyHalt543 PRE_first_tail_x4_L8_r0_body.bodyStepA141 bodyTop544 (fun _ hm => bodyO542 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr542).trans bodyInactive0) (bodyBr544.trans bodyBr542.symm) bodyCnt542 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA141 PRE_first_tail_x4_L8_r0_body.sizeArgsA141 PRE_first_tail_x4_L8_r0_body.sizeSymA141 PRE_first_tail_x4_L8_r0_body.sizeMlxA141 PRE_first_tail_x4_L8_r0_body.sizePayA141 PRE_first_tail_x4_L8_r0_body.sizeTaA141 PRE_first_tail_x4_L8_r0_body.sizeDecA141 PRE_first_tail_x4_L8_r0_body.sizePreA141 PRE_first_tail_x4_L8_r0_body.bodyPatchB141 (fun _ hm => bodyO544 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr544).trans bodyInactive0) (bodyBr545.trans bodyBr544.symm) bodyCnt544 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) bodyAcc545 PRE_first_tail_x4_L8_r0_body.bodyRunSeg141 bodyAcc546 bodyHalt546 PRE_first_tail_x4_L8_r0_body.bodyStepA142 bodyTop547 (fun _ hm => bodyO545 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr545).trans bodyInactive0) (bodyBr547.trans bodyBr545.symm) bodyCnt545 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA142 PRE_first_tail_x4_L8_r0_body.sizeArgsA142 PRE_first_tail_x4_L8_r0_body.sizeSymA142 PRE_first_tail_x4_L8_r0_body.sizeMlxA142 PRE_first_tail_x4_L8_r0_body.sizePayA142 PRE_first_tail_x4_L8_r0_body.sizeTaA142 PRE_first_tail_x4_L8_r0_body.sizeDecA142 PRE_first_tail_x4_L8_r0_body.sizePreA142 PRE_first_tail_x4_L8_r0_body.bodyPatchB142 (fun _ hm => bodyO547 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr547).trans bodyInactive0) (bodyBr548.trans bodyBr547.symm) bodyCnt547 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26896, 483, 0, 0⟩) bodyAcc548 PRE_first_tail_x4_L8_r0_body.bodyRunSeg142 bodyAcc549 bodyHalt549 PRE_first_tail_x4_L8_r0_body.bodyStepA143 bodyTop550 (fun _ hm => bodyO548 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr548).trans bodyInactive0) (bodyBr550.trans bodyBr548.symm) bodyCnt548 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift24 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S550.tab.length PRE_first_tail_x4_L8_r0_body.s550.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P24.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P24 15 PRE_first_tail_x4_L8_r0_body.kappa24 PRE_first_tail_x4_L8_r0_body.s552.ffi PRE_first_tail_x4_L8_r0_body.s551.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_24
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_24
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s552.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S550.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_24] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK24 PRE_first_tail_x4_L8_r0_body.cobjsK24
      PRE_first_tail_x4_L8_r0_body.citemsK24 PRE_first_tail_x4_L8_r0_body.cbd24 PRE_first_tail_x4_L8_r0_body.csst24
  exact PRE_first_tail_x4_L8_r0_body.cshift24 bodyNcl24 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_24] at this; exact this)


kernel_rfl bodyFramesEmpty24 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s551 a).isEmpty) = true
kernel_rfl bodyJsRoots24 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s550.next) PRE_first_tail_x4_L8_r0_body.s552.trace PRE_first_tail_x4_L8_r0_body.s552 = true
kernel_rfl bodyJsNative24 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s552.ffi) = true
kernel_rfl bodyLow24 : (PRE_first_tail_x4_L8_r0_body.cws24 ++ PRE_first_tail_x4_L8_r0_body.ws24).all (Nat.ble 9) = true
kernel_rfl bodyCntM24 : countersOkB PRE_first_tail_x4_L8_r0_body.s550 PRE_first_tail_x4_L8_r0_body.s551 = true
kernel_rfl bodyHi24 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s552.ffi).next setupP.E = true
kernel_rfl bodyNhi24 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s552.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge24 : bridgeOf PRE_first_tail_x4_L8_r0_body.s551.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s550.ffi
kernel_rfl bodyNN24 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s550.ffi).nnext PRE_first_tail_x4_L8_r0_body.P24.NL = true
kernel_rfl bodyXn24 : Nat.ble (⟨19713, 16805, 2735479, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s552.ffi).next = true
kernel_rfl bodyLo24 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s552.ffi).next = true
theorem bodyFacts24 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s550 PRE_first_tail_x4_L8_r0_body.s551 PRE_first_tail_x4_L8_r0_body.s552 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S550 PRE_first_tail_x4_L8_r0_body.S551 PRE_first_tail_x4_L8_r0_body.S552
    PRE_first_tail_x4_L8_r0_body.ws24 PRE_first_tail_x4_L8_r0_body.cws24 PRE_first_tail_x4_L8_r0_body.nr24 PRE_first_tail_x4_L8_r0_body.pl24 PRE_first_tail_x4_L8_r0_body.cl24 2736628 15 PRE_first_tail_x4_L8_r0_body.kd24 PRE_first_tail_x4_L8_r0_body.kappa24 PRE_first_tail_x4_L8_r0_body.P24
    ⟨19710, 16778, 2735473, 15⟩ ⟨19713, 16805, 2735479, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap24
  clean := bodyClean24
  cfix := PRE_first_tail_x4_L8_r0_body.cfix24
  zpl := PRE_first_tail_x4_L8_r0_body.zpl24
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd24
  zn1 := PRE_first_tail_x4_L8_r0_body.zn124
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst24
  zscn := PRE_first_tail_x4_L8_r0_body.zscn24
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn24
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow24
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab24
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh24
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd24
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi24
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt24
  zgP := PRE_first_tail_x4_L8_r0_body.zg24_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk24_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm24_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg24_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk24_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm24_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw24_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw24_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap24
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd24
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap24 PRE_first_tail_x4_L8_r0_body.stFoot24 PRE_first_tail_x4_L8_r0_body.iso24 PRE_first_tail_x4_L8_r0_body.zwr24
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP24
  csupp := PRE_first_tail_x4_L8_r0_body.csupp24
  cbound := PRE_first_tail_x4_L8_r0_body.cbound24
  zimg := PRE_first_tail_x4_L8_r0_body.zimg24
  zctl := PRE_first_tail_x4_L8_r0_body.zctl24
  zstack := PRE_first_tail_x4_L8_r0_body.zstack24
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs24
  zstores := PRE_first_tail_x4_L8_r0_body.zstores24
  zroots := PRE_first_tail_x4_L8_r0_body.zroots24
  znC := PRE_first_tail_x4_L8_r0_body.znC24
  ctab := PRE_first_tail_x4_L8_r0_body.ctab24
  zbin := PRE_first_tail_x4_L8_r0_body.zbin24
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge24
  sbridge := bodyBridge24
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj24
  cshiftR := fun h hNL => bodyCshift24 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN24
  raised := PRE_first_tail_x4_L8_r0_body.raised24
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs24
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl24
  xnLe := Nat.le_of_ble_eq_true bodyXn24
  loLe := Nat.le_of_ble_eq_true bodyLo24
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB24
  cntM := bodyCntM24
  hiLe := Nat.le_of_ble_eq_true bodyHi24
  nhiLe := Nat.le_of_ble_eq_true bodyNhi24
  jsHeap := bodyJs24
  jsRoots := bodyJsRoots24
  jsNative := bodyJsNative24
  framesEmpty := bodyFramesEmpty24
  trailOld := by decide
  lowVars := bodyLow24

def bodyQs24 : List (Option Q) := []
noncomputable def bodyEs24 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr24.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st24.S5.tab r
kernel_rfl bodyResChk24 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs24 bodyQs24) = true
kernel_rfl bodyLq24 : bodyQs24.length = PRE_first_tail_x4_L8_r0_body.cws24.length
kernel_rfl bodyNrLo24 : PRE_first_tail_x4_L8_r0_body.nr24.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S550.tab.length) = true
kernel_rfl bodySub24 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site24.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost24 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws24 PRE_first_tail_x4_L8_r0_body.cws24 bodyQs24 = true
kernel_rfl bodyDrop24 : Nat.ble (26896 + (PRE_first_tail_x4_L8_r0_body.s551.next - PRE_first_tail_x4_L8_r0_body.s552.next)) 28045 = true
kernel_rfl bodyDropH24 : Nat.ble (483 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s551.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s552.ffi).next)) 508 = true
kernel_rfl bodyDropN24 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s551.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s552.ffi).nnext)) 0 = true
kernel_rfl bodyDv24 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws24
kernel_rfl bodyDe24 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr24.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st24.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl24 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold24 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws24).isNone && !PRE_first_tail_x4_L8_r0_body.ws24.contains v) = true
kernel_rfl bodyDfree24 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws24 ++ PRE_first_tail_x4_L8_r0_body.ws24).all fun w => e.noVar w) = true

theorem bodyStep24 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26896, 483, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s550 PRE_first_tail_x4_L8_r0_body.S550)
      (bodyCut NB T tk π i x0 bodyΘ ⟨28045, 508, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s552 PRE_first_tail_x4_L8_r0_body.S552) (11334 + 1) :=
  bodySite bodyFacts24.cfix bodyFacts24.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st24.S5.tab) (Es := bodyEs24) (qs := bodyQs24)
    (ok := PRE_first_tail_x4_L8_r0_body.st24.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site24 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts24
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site24 r hr) hi (MapOk.sub hm (sub_of_all bodySub24)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk24 r hr) hi hm ho hq)
    bodyLq24 rfl bodyNrLo24 (postSub_sound bodyPost24)
    (Nat.le_of_ble_eq_true bodyDrop24) (by decide) (Nat.le_of_ble_eq_true bodyDropH24) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN24) (by decide)
    bodyDv24 bodyDe24 bodyDl24 bodyDold24 bodyDfree24 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site25 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site25 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site25) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st25.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site25
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st25.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st25.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s572 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s573 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S572 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws25 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st25.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st25.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso25
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_25
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st25.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot25
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup25
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound25
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace25
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged25
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws25.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st25.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S572.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_25]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen25.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh25
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl25 : Conv.NClean (⟨19767, 16841, 2737711, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s572.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl25 (PRE_first_tail_x4_L8_r0_body.cncl24 bodyNcl24)

theorem bodyClean25 : Conv.JClean (⟨19767, 16841, 2737711, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s572 :=
  PRE_first_tail_x4_L8_r0_body.gjcl25 (PRE_first_tail_x4_L8_r0_body.cjcl24 bodyClean24)

kernel_rfl bodyJsLe25 : Nat.ble PRE_first_tail_x4_L8_r0_body.s550.next PRE_first_tail_x4_L8_r0_body.s572.next = true
kernel_rfl bodyJsList25 : (PRE_first_tail_x4_L8_r0_body.gjh25 ++ PRE_first_tail_x4_L8_r0_body.cl25).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s572.next) PRE_first_tail_x4_L8_r0_body.s574) = true
theorem bodyJs25 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s572.next PRE_first_tail_x4_L8_r0_body.s574 :=
  JsHeapAbove.glueSite bodyJs24 (Nat.le_of_ble_eq_true bodyJsLe25) PRE_first_tail_x4_L8_r0_body.gjk25 PRE_first_tail_x4_L8_r0_body.gjbd25 PRE_first_tail_x4_L8_r0_body.cheap25 PRE_first_tail_x4_L8_r0_body.zclbd25 bodyJsList25

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO552 : PRE_first_tail_x4_L8_r0_body.S552.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S552.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr552 : bridgeOf PRE_first_tail_x4_L8_r0_body.s552.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc552 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s552 PRE_first_tail_x4_L8_r0_body.S552) = fun _ _ => true
kernel_rfl bodyAcc553 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s553 PRE_first_tail_x4_L8_r0_body.S553) = fun _ _ => true
kernel_rfl bodyBr554 : bridgeOf PRE_first_tail_x4_L8_r0_body.s554.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt553 : isHalt PRE_first_tail_x4_L8_r0_body.s553.ctl = false
kernel_rfl bodyTop554 : noRetBlock PRE_first_tail_x4_L8_r0_body.s554 = true
kernel_rfl bodyCnt552 : countersOkB PRE_first_tail_x4_L8_r0_body.s552 PRE_first_tail_x4_L8_r0_body.s554 = true
kernel_rfl bodyO554 : PRE_first_tail_x4_L8_r0_body.S554.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S554.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr555 : bridgeOf PRE_first_tail_x4_L8_r0_body.s555.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt554 : countersOkB PRE_first_tail_x4_L8_r0_body.s554 PRE_first_tail_x4_L8_r0_body.s555 = true
kernel_rfl bodyO555 : PRE_first_tail_x4_L8_r0_body.S555.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S555.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc555 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s555 PRE_first_tail_x4_L8_r0_body.S555) = fun _ _ => true
kernel_rfl bodyAcc559 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s559 PRE_first_tail_x4_L8_r0_body.S559) = fun _ _ => true
kernel_rfl bodyBr560 : bridgeOf PRE_first_tail_x4_L8_r0_body.s560.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt559 : isHalt PRE_first_tail_x4_L8_r0_body.s559.ctl = false
kernel_rfl bodyTop560 : noRetBlock PRE_first_tail_x4_L8_r0_body.s560 = true
kernel_rfl bodyCnt555 : countersOkB PRE_first_tail_x4_L8_r0_body.s555 PRE_first_tail_x4_L8_r0_body.s560 = true
kernel_rfl bodyO560 : PRE_first_tail_x4_L8_r0_body.S560.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S560.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr561 : bridgeOf PRE_first_tail_x4_L8_r0_body.s561.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt560 : countersOkB PRE_first_tail_x4_L8_r0_body.s560 PRE_first_tail_x4_L8_r0_body.s561 = true
kernel_rfl bodyO561 : PRE_first_tail_x4_L8_r0_body.S561.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S561.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc561 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s561 PRE_first_tail_x4_L8_r0_body.S561) = fun _ _ => true
kernel_rfl bodyAcc562 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s562 PRE_first_tail_x4_L8_r0_body.S562) = fun _ _ => true
kernel_rfl bodyBr563 : bridgeOf PRE_first_tail_x4_L8_r0_body.s563.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt562 : isHalt PRE_first_tail_x4_L8_r0_body.s562.ctl = false
kernel_rfl bodyTop563 : noRetBlock PRE_first_tail_x4_L8_r0_body.s563 = true
kernel_rfl bodyCnt561 : countersOkB PRE_first_tail_x4_L8_r0_body.s561 PRE_first_tail_x4_L8_r0_body.s563 = true
kernel_rfl bodyO563 : PRE_first_tail_x4_L8_r0_body.S563.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S563.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr564 : bridgeOf PRE_first_tail_x4_L8_r0_body.s564.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt563 : countersOkB PRE_first_tail_x4_L8_r0_body.s563 PRE_first_tail_x4_L8_r0_body.s564 = true
kernel_rfl bodyO564 : PRE_first_tail_x4_L8_r0_body.S564.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S564.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc564 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s564 PRE_first_tail_x4_L8_r0_body.S564) = fun _ _ => true
kernel_rfl bodyAcc565 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s565 PRE_first_tail_x4_L8_r0_body.S565) = fun _ _ => true
kernel_rfl bodyBr566 : bridgeOf PRE_first_tail_x4_L8_r0_body.s566.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt565 : isHalt PRE_first_tail_x4_L8_r0_body.s565.ctl = false
kernel_rfl bodyTop566 : noRetBlock PRE_first_tail_x4_L8_r0_body.s566 = true
kernel_rfl bodyCnt564 : countersOkB PRE_first_tail_x4_L8_r0_body.s564 PRE_first_tail_x4_L8_r0_body.s566 = true
kernel_rfl bodyO566 : PRE_first_tail_x4_L8_r0_body.S566.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S566.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr567 : bridgeOf PRE_first_tail_x4_L8_r0_body.s567.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt566 : countersOkB PRE_first_tail_x4_L8_r0_body.s566 PRE_first_tail_x4_L8_r0_body.s567 = true
kernel_rfl bodyO567 : PRE_first_tail_x4_L8_r0_body.S567.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S567.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc567 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s567 PRE_first_tail_x4_L8_r0_body.S567) = fun _ _ => true
kernel_rfl bodyAcc568 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s568 PRE_first_tail_x4_L8_r0_body.S568) = fun _ _ => true
kernel_rfl bodyBr569 : bridgeOf PRE_first_tail_x4_L8_r0_body.s569.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt568 : isHalt PRE_first_tail_x4_L8_r0_body.s568.ctl = false
kernel_rfl bodyTop569 : noRetBlock PRE_first_tail_x4_L8_r0_body.s569 = true
kernel_rfl bodyCnt567 : countersOkB PRE_first_tail_x4_L8_r0_body.s567 PRE_first_tail_x4_L8_r0_body.s569 = true
kernel_rfl bodyO569 : PRE_first_tail_x4_L8_r0_body.S569.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S569.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr570 : bridgeOf PRE_first_tail_x4_L8_r0_body.s570.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt569 : countersOkB PRE_first_tail_x4_L8_r0_body.s569 PRE_first_tail_x4_L8_r0_body.s570 = true
kernel_rfl bodyO570 : PRE_first_tail_x4_L8_r0_body.S570.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S570.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc570 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s570 PRE_first_tail_x4_L8_r0_body.S570) = fun _ _ => true
kernel_rfl bodyAcc571 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s571 PRE_first_tail_x4_L8_r0_body.S571) = fun _ _ => true
kernel_rfl bodyBr572 : bridgeOf PRE_first_tail_x4_L8_r0_body.s572.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt571 : isHalt PRE_first_tail_x4_L8_r0_body.s571.ctl = false
kernel_rfl bodyTop572 : noRetBlock PRE_first_tail_x4_L8_r0_body.s572 = true
kernel_rfl bodyCnt570 : countersOkB PRE_first_tail_x4_L8_r0_body.s570 PRE_first_tail_x4_L8_r0_body.s572 = true

theorem bodyGlue25 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨28045, 508, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s552 PRE_first_tail_x4_L8_r0_body.S552)
      (bodyCut NB T tk π i x0 bodyΘ ⟨28045, 508, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s572 PRE_first_tail_x4_L8_r0_body.S572) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) bodyAcc552 PRE_first_tail_x4_L8_r0_body.bodyRunSeg143 bodyAcc553 bodyHalt553 PRE_first_tail_x4_L8_r0_body.bodyStepA144 bodyTop554 (fun _ hm => bodyO552 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr552).trans bodyInactive0) (bodyBr554.trans bodyBr552.symm) bodyCnt552 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA144 PRE_first_tail_x4_L8_r0_body.sizeArgsA144 PRE_first_tail_x4_L8_r0_body.sizeSymA144 PRE_first_tail_x4_L8_r0_body.sizeMlxA144 PRE_first_tail_x4_L8_r0_body.sizePayA144 PRE_first_tail_x4_L8_r0_body.sizeTaA144 PRE_first_tail_x4_L8_r0_body.sizeDecA144 PRE_first_tail_x4_L8_r0_body.sizePreA144 PRE_first_tail_x4_L8_r0_body.bodyPatchB144 (fun _ hm => bodyO554 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr554).trans bodyInactive0) (bodyBr555.trans bodyBr554.symm) bodyCnt554 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) bodyAcc555 PRE_first_tail_x4_L8_r0_body.bodyRunSeg144 bodyAcc559 bodyHalt559 PRE_first_tail_x4_L8_r0_body.bodyStepA145 bodyTop560 (fun _ hm => bodyO555 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr555).trans bodyInactive0) (bodyBr560.trans bodyBr555.symm) bodyCnt555 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA145 PRE_first_tail_x4_L8_r0_body.sizeArgsA145 PRE_first_tail_x4_L8_r0_body.sizeSymA145 PRE_first_tail_x4_L8_r0_body.sizeMlxA145 PRE_first_tail_x4_L8_r0_body.sizePayA145 PRE_first_tail_x4_L8_r0_body.sizeTaA145 PRE_first_tail_x4_L8_r0_body.sizeDecA145 PRE_first_tail_x4_L8_r0_body.sizePreA145 PRE_first_tail_x4_L8_r0_body.bodyPatchB145 (fun _ hm => bodyO560 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr560).trans bodyInactive0) (bodyBr561.trans bodyBr560.symm) bodyCnt560 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) bodyAcc561 PRE_first_tail_x4_L8_r0_body.bodyRunSeg145 bodyAcc562 bodyHalt562 PRE_first_tail_x4_L8_r0_body.bodyStepA146 bodyTop563 (fun _ hm => bodyO561 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr561).trans bodyInactive0) (bodyBr563.trans bodyBr561.symm) bodyCnt561 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA146 PRE_first_tail_x4_L8_r0_body.sizeArgsA146 PRE_first_tail_x4_L8_r0_body.sizeSymA146 PRE_first_tail_x4_L8_r0_body.sizeMlxA146 PRE_first_tail_x4_L8_r0_body.sizePayA146 PRE_first_tail_x4_L8_r0_body.sizeTaA146 PRE_first_tail_x4_L8_r0_body.sizeDecA146 PRE_first_tail_x4_L8_r0_body.sizePreA146 PRE_first_tail_x4_L8_r0_body.bodyPatchB146 (fun _ hm => bodyO563 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr563).trans bodyInactive0) (bodyBr564.trans bodyBr563.symm) bodyCnt563 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) bodyAcc564 PRE_first_tail_x4_L8_r0_body.bodyRunSeg146 bodyAcc565 bodyHalt565 PRE_first_tail_x4_L8_r0_body.bodyStepA147 bodyTop566 (fun _ hm => bodyO564 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr564).trans bodyInactive0) (bodyBr566.trans bodyBr564.symm) bodyCnt564 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA147 PRE_first_tail_x4_L8_r0_body.sizeArgsA147 PRE_first_tail_x4_L8_r0_body.sizeSymA147 PRE_first_tail_x4_L8_r0_body.sizeMlxA147 PRE_first_tail_x4_L8_r0_body.sizePayA147 PRE_first_tail_x4_L8_r0_body.sizeTaA147 PRE_first_tail_x4_L8_r0_body.sizeDecA147 PRE_first_tail_x4_L8_r0_body.sizePreA147 PRE_first_tail_x4_L8_r0_body.bodyPatchB147 (fun _ hm => bodyO566 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr566).trans bodyInactive0) (bodyBr567.trans bodyBr566.symm) bodyCnt566 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) bodyAcc567 PRE_first_tail_x4_L8_r0_body.bodyRunSeg147 bodyAcc568 bodyHalt568 PRE_first_tail_x4_L8_r0_body.bodyStepA148 bodyTop569 (fun _ hm => bodyO567 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr567).trans bodyInactive0) (bodyBr569.trans bodyBr567.symm) bodyCnt567 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA148 PRE_first_tail_x4_L8_r0_body.sizeArgsA148 PRE_first_tail_x4_L8_r0_body.sizeSymA148 PRE_first_tail_x4_L8_r0_body.sizeMlxA148 PRE_first_tail_x4_L8_r0_body.sizePayA148 PRE_first_tail_x4_L8_r0_body.sizeTaA148 PRE_first_tail_x4_L8_r0_body.sizeDecA148 PRE_first_tail_x4_L8_r0_body.sizePreA148 PRE_first_tail_x4_L8_r0_body.bodyPatchB148 (fun _ hm => bodyO569 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr569).trans bodyInactive0) (bodyBr570.trans bodyBr569.symm) bodyCnt569 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28045, 508, 0, 0⟩) bodyAcc570 PRE_first_tail_x4_L8_r0_body.bodyRunSeg148 bodyAcc571 bodyHalt571 PRE_first_tail_x4_L8_r0_body.bodyStepA149 bodyTop572 (fun _ hm => bodyO570 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr570).trans bodyInactive0) (bodyBr572.trans bodyBr570.symm) bodyCnt570 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift25 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S572.tab.length PRE_first_tail_x4_L8_r0_body.s572.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P25.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P25 15 PRE_first_tail_x4_L8_r0_body.kappa25 PRE_first_tail_x4_L8_r0_body.s574.ffi PRE_first_tail_x4_L8_r0_body.s573.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_25
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_25
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s574.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S572.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_25] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK25 PRE_first_tail_x4_L8_r0_body.cobjsK25
      PRE_first_tail_x4_L8_r0_body.citemsK25 PRE_first_tail_x4_L8_r0_body.cbd25 PRE_first_tail_x4_L8_r0_body.csst25
  exact PRE_first_tail_x4_L8_r0_body.cshift25 bodyNcl25 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_25] at this; exact this)


kernel_rfl bodyFramesEmpty25 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s573 a).isEmpty) = true
kernel_rfl bodyJsRoots25 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s572.next) PRE_first_tail_x4_L8_r0_body.s574.trace PRE_first_tail_x4_L8_r0_body.s574 = true
kernel_rfl bodyJsNative25 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s574.ffi) = true
kernel_rfl bodyLow25 : (PRE_first_tail_x4_L8_r0_body.cws25 ++ PRE_first_tail_x4_L8_r0_body.ws25).all (Nat.ble 9) = true
kernel_rfl bodyCntM25 : countersOkB PRE_first_tail_x4_L8_r0_body.s572 PRE_first_tail_x4_L8_r0_body.s573 = true
kernel_rfl bodyHi25 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s574.ffi).next setupP.E = true
kernel_rfl bodyNhi25 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s574.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge25 : bridgeOf PRE_first_tail_x4_L8_r0_body.s573.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s572.ffi
kernel_rfl bodyNN25 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s572.ffi).nnext PRE_first_tail_x4_L8_r0_body.P25.NL = true
kernel_rfl bodyXn25 : Nat.ble (⟨19770, 16868, 2737717, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s574.ffi).next = true
kernel_rfl bodyLo25 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s574.ffi).next = true
theorem bodyFacts25 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s572 PRE_first_tail_x4_L8_r0_body.s573 PRE_first_tail_x4_L8_r0_body.s574 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S572 PRE_first_tail_x4_L8_r0_body.S573 PRE_first_tail_x4_L8_r0_body.S574
    PRE_first_tail_x4_L8_r0_body.ws25 PRE_first_tail_x4_L8_r0_body.cws25 PRE_first_tail_x4_L8_r0_body.nr25 PRE_first_tail_x4_L8_r0_body.pl25 PRE_first_tail_x4_L8_r0_body.cl25 2738866 15 PRE_first_tail_x4_L8_r0_body.kd25 PRE_first_tail_x4_L8_r0_body.kappa25 PRE_first_tail_x4_L8_r0_body.P25
    ⟨19767, 16841, 2737711, 15⟩ ⟨19770, 16868, 2737717, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap25
  clean := bodyClean25
  cfix := PRE_first_tail_x4_L8_r0_body.cfix25
  zpl := PRE_first_tail_x4_L8_r0_body.zpl25
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd25
  zn1 := PRE_first_tail_x4_L8_r0_body.zn125
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst25
  zscn := PRE_first_tail_x4_L8_r0_body.zscn25
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn25
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow25
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab25
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh25
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd25
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi25
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt25
  zgP := PRE_first_tail_x4_L8_r0_body.zg25_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk25_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm25_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg25_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk25_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm25_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw25_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw25_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap25
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd25
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap25 PRE_first_tail_x4_L8_r0_body.stFoot25 PRE_first_tail_x4_L8_r0_body.iso25 PRE_first_tail_x4_L8_r0_body.zwr25
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP25
  csupp := PRE_first_tail_x4_L8_r0_body.csupp25
  cbound := PRE_first_tail_x4_L8_r0_body.cbound25
  zimg := PRE_first_tail_x4_L8_r0_body.zimg25
  zctl := PRE_first_tail_x4_L8_r0_body.zctl25
  zstack := PRE_first_tail_x4_L8_r0_body.zstack25
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs25
  zstores := PRE_first_tail_x4_L8_r0_body.zstores25
  zroots := PRE_first_tail_x4_L8_r0_body.zroots25
  znC := PRE_first_tail_x4_L8_r0_body.znC25
  ctab := PRE_first_tail_x4_L8_r0_body.ctab25
  zbin := PRE_first_tail_x4_L8_r0_body.zbin25
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge25
  sbridge := bodyBridge25
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj25
  cshiftR := fun h hNL => bodyCshift25 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN25
  raised := PRE_first_tail_x4_L8_r0_body.raised25
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs25
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl25
  xnLe := Nat.le_of_ble_eq_true bodyXn25
  loLe := Nat.le_of_ble_eq_true bodyLo25
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB25
  cntM := bodyCntM25
  hiLe := Nat.le_of_ble_eq_true bodyHi25
  nhiLe := Nat.le_of_ble_eq_true bodyNhi25
  jsHeap := bodyJs25
  jsRoots := bodyJsRoots25
  jsNative := bodyJsNative25
  framesEmpty := bodyFramesEmpty25
  trailOld := by decide
  lowVars := bodyLow25

def bodyQs25 : List (Option Q) := []
noncomputable def bodyEs25 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr25.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st25.S5.tab r
kernel_rfl bodyResChk25 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs25 bodyQs25) = true
kernel_rfl bodyLq25 : bodyQs25.length = PRE_first_tail_x4_L8_r0_body.cws25.length
kernel_rfl bodyNrLo25 : PRE_first_tail_x4_L8_r0_body.nr25.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S572.tab.length) = true
kernel_rfl bodySub25 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site25.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost25 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws25 PRE_first_tail_x4_L8_r0_body.cws25 bodyQs25 = true
kernel_rfl bodyDrop25 : Nat.ble (28045 + (PRE_first_tail_x4_L8_r0_body.s573.next - PRE_first_tail_x4_L8_r0_body.s574.next)) 29194 = true
kernel_rfl bodyDropH25 : Nat.ble (508 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s573.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s574.ffi).next)) 533 = true
kernel_rfl bodyDropN25 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s573.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s574.ffi).nnext)) 0 = true
kernel_rfl bodyDv25 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws25
kernel_rfl bodyDe25 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr25.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st25.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl25 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold25 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws25).isNone && !PRE_first_tail_x4_L8_r0_body.ws25.contains v) = true
kernel_rfl bodyDfree25 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws25 ++ PRE_first_tail_x4_L8_r0_body.ws25).all fun w => e.noVar w) = true

theorem bodyStep25 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨28045, 508, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s572 PRE_first_tail_x4_L8_r0_body.S572)
      (bodyCut NB T tk π i x0 bodyΘ ⟨29194, 533, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s574 PRE_first_tail_x4_L8_r0_body.S574) (11334 + 1) :=
  bodySite bodyFacts25.cfix bodyFacts25.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st25.S5.tab) (Es := bodyEs25) (qs := bodyQs25)
    (ok := PRE_first_tail_x4_L8_r0_body.st25.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site25 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts25
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site25 r hr) hi (MapOk.sub hm (sub_of_all bodySub25)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk25 r hr) hi hm ho hq)
    bodyLq25 rfl bodyNrLo25 (postSub_sound bodyPost25)
    (Nat.le_of_ble_eq_true bodyDrop25) (by decide) (Nat.le_of_ble_eq_true bodyDropH25) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN25) (by decide)
    bodyDv25 bodyDe25 bodyDl25 bodyDold25 bodyDfree25 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site26 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site26 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site26) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st26.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site26
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st26.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st26.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s594 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s595 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S594 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws26 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st26.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st26.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso26
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_26
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st26.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot26
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup26
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound26
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace26
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged26
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws26.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st26.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S594.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_26]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen26.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh26
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl26 : Conv.NClean (⟨19824, 16904, 2739949, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s594.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl26 (PRE_first_tail_x4_L8_r0_body.cncl25 bodyNcl25)

theorem bodyClean26 : Conv.JClean (⟨19824, 16904, 2739949, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s594 :=
  PRE_first_tail_x4_L8_r0_body.gjcl26 (PRE_first_tail_x4_L8_r0_body.cjcl25 bodyClean25)

kernel_rfl bodyJsLe26 : Nat.ble PRE_first_tail_x4_L8_r0_body.s572.next PRE_first_tail_x4_L8_r0_body.s594.next = true
kernel_rfl bodyJsList26 : (PRE_first_tail_x4_L8_r0_body.gjh26 ++ PRE_first_tail_x4_L8_r0_body.cl26).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s594.next) PRE_first_tail_x4_L8_r0_body.s596) = true
theorem bodyJs26 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s594.next PRE_first_tail_x4_L8_r0_body.s596 :=
  JsHeapAbove.glueSite bodyJs25 (Nat.le_of_ble_eq_true bodyJsLe26) PRE_first_tail_x4_L8_r0_body.gjk26 PRE_first_tail_x4_L8_r0_body.gjbd26 PRE_first_tail_x4_L8_r0_body.cheap26 PRE_first_tail_x4_L8_r0_body.zclbd26 bodyJsList26

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO574 : PRE_first_tail_x4_L8_r0_body.S574.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S574.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr574 : bridgeOf PRE_first_tail_x4_L8_r0_body.s574.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc574 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s574 PRE_first_tail_x4_L8_r0_body.S574) = fun _ _ => true
kernel_rfl bodyAcc575 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s575 PRE_first_tail_x4_L8_r0_body.S575) = fun _ _ => true
kernel_rfl bodyBr576 : bridgeOf PRE_first_tail_x4_L8_r0_body.s576.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt575 : isHalt PRE_first_tail_x4_L8_r0_body.s575.ctl = false
kernel_rfl bodyTop576 : noRetBlock PRE_first_tail_x4_L8_r0_body.s576 = true
kernel_rfl bodyCnt574 : countersOkB PRE_first_tail_x4_L8_r0_body.s574 PRE_first_tail_x4_L8_r0_body.s576 = true
kernel_rfl bodyO576 : PRE_first_tail_x4_L8_r0_body.S576.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S576.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr577 : bridgeOf PRE_first_tail_x4_L8_r0_body.s577.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt576 : countersOkB PRE_first_tail_x4_L8_r0_body.s576 PRE_first_tail_x4_L8_r0_body.s577 = true
kernel_rfl bodyO577 : PRE_first_tail_x4_L8_r0_body.S577.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S577.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc577 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s577 PRE_first_tail_x4_L8_r0_body.S577) = fun _ _ => true
kernel_rfl bodyAcc581 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s581 PRE_first_tail_x4_L8_r0_body.S581) = fun _ _ => true
kernel_rfl bodyBr582 : bridgeOf PRE_first_tail_x4_L8_r0_body.s582.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt581 : isHalt PRE_first_tail_x4_L8_r0_body.s581.ctl = false
kernel_rfl bodyTop582 : noRetBlock PRE_first_tail_x4_L8_r0_body.s582 = true
kernel_rfl bodyCnt577 : countersOkB PRE_first_tail_x4_L8_r0_body.s577 PRE_first_tail_x4_L8_r0_body.s582 = true
kernel_rfl bodyO582 : PRE_first_tail_x4_L8_r0_body.S582.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S582.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr583 : bridgeOf PRE_first_tail_x4_L8_r0_body.s583.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt582 : countersOkB PRE_first_tail_x4_L8_r0_body.s582 PRE_first_tail_x4_L8_r0_body.s583 = true
kernel_rfl bodyO583 : PRE_first_tail_x4_L8_r0_body.S583.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S583.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc583 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s583 PRE_first_tail_x4_L8_r0_body.S583) = fun _ _ => true
kernel_rfl bodyAcc584 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s584 PRE_first_tail_x4_L8_r0_body.S584) = fun _ _ => true
kernel_rfl bodyBr585 : bridgeOf PRE_first_tail_x4_L8_r0_body.s585.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt584 : isHalt PRE_first_tail_x4_L8_r0_body.s584.ctl = false
kernel_rfl bodyTop585 : noRetBlock PRE_first_tail_x4_L8_r0_body.s585 = true
kernel_rfl bodyCnt583 : countersOkB PRE_first_tail_x4_L8_r0_body.s583 PRE_first_tail_x4_L8_r0_body.s585 = true
kernel_rfl bodyO585 : PRE_first_tail_x4_L8_r0_body.S585.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S585.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr586 : bridgeOf PRE_first_tail_x4_L8_r0_body.s586.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt585 : countersOkB PRE_first_tail_x4_L8_r0_body.s585 PRE_first_tail_x4_L8_r0_body.s586 = true
kernel_rfl bodyO586 : PRE_first_tail_x4_L8_r0_body.S586.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S586.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc586 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s586 PRE_first_tail_x4_L8_r0_body.S586) = fun _ _ => true
kernel_rfl bodyAcc587 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s587 PRE_first_tail_x4_L8_r0_body.S587) = fun _ _ => true
kernel_rfl bodyBr588 : bridgeOf PRE_first_tail_x4_L8_r0_body.s588.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt587 : isHalt PRE_first_tail_x4_L8_r0_body.s587.ctl = false
kernel_rfl bodyTop588 : noRetBlock PRE_first_tail_x4_L8_r0_body.s588 = true
kernel_rfl bodyCnt586 : countersOkB PRE_first_tail_x4_L8_r0_body.s586 PRE_first_tail_x4_L8_r0_body.s588 = true
kernel_rfl bodyO588 : PRE_first_tail_x4_L8_r0_body.S588.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S588.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr589 : bridgeOf PRE_first_tail_x4_L8_r0_body.s589.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt588 : countersOkB PRE_first_tail_x4_L8_r0_body.s588 PRE_first_tail_x4_L8_r0_body.s589 = true
kernel_rfl bodyO589 : PRE_first_tail_x4_L8_r0_body.S589.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S589.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc589 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s589 PRE_first_tail_x4_L8_r0_body.S589) = fun _ _ => true
kernel_rfl bodyAcc590 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s590 PRE_first_tail_x4_L8_r0_body.S590) = fun _ _ => true
kernel_rfl bodyBr591 : bridgeOf PRE_first_tail_x4_L8_r0_body.s591.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt590 : isHalt PRE_first_tail_x4_L8_r0_body.s590.ctl = false
kernel_rfl bodyTop591 : noRetBlock PRE_first_tail_x4_L8_r0_body.s591 = true
kernel_rfl bodyCnt589 : countersOkB PRE_first_tail_x4_L8_r0_body.s589 PRE_first_tail_x4_L8_r0_body.s591 = true
kernel_rfl bodyO591 : PRE_first_tail_x4_L8_r0_body.S591.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S591.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr592 : bridgeOf PRE_first_tail_x4_L8_r0_body.s592.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt591 : countersOkB PRE_first_tail_x4_L8_r0_body.s591 PRE_first_tail_x4_L8_r0_body.s592 = true
kernel_rfl bodyO592 : PRE_first_tail_x4_L8_r0_body.S592.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S592.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc592 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s592 PRE_first_tail_x4_L8_r0_body.S592) = fun _ _ => true
kernel_rfl bodyAcc593 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s593 PRE_first_tail_x4_L8_r0_body.S593) = fun _ _ => true
kernel_rfl bodyBr594 : bridgeOf PRE_first_tail_x4_L8_r0_body.s594.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt593 : isHalt PRE_first_tail_x4_L8_r0_body.s593.ctl = false
kernel_rfl bodyTop594 : noRetBlock PRE_first_tail_x4_L8_r0_body.s594 = true
kernel_rfl bodyCnt592 : countersOkB PRE_first_tail_x4_L8_r0_body.s592 PRE_first_tail_x4_L8_r0_body.s594 = true

theorem bodyGlue26 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨29194, 533, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s574 PRE_first_tail_x4_L8_r0_body.S574)
      (bodyCut NB T tk π i x0 bodyΘ ⟨29194, 533, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s594 PRE_first_tail_x4_L8_r0_body.S594) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) bodyAcc574 PRE_first_tail_x4_L8_r0_body.bodyRunSeg149 bodyAcc575 bodyHalt575 PRE_first_tail_x4_L8_r0_body.bodyStepA150 bodyTop576 (fun _ hm => bodyO574 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr574).trans bodyInactive0) (bodyBr576.trans bodyBr574.symm) bodyCnt574 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA150 PRE_first_tail_x4_L8_r0_body.sizeArgsA150 PRE_first_tail_x4_L8_r0_body.sizeSymA150 PRE_first_tail_x4_L8_r0_body.sizeMlxA150 PRE_first_tail_x4_L8_r0_body.sizePayA150 PRE_first_tail_x4_L8_r0_body.sizeTaA150 PRE_first_tail_x4_L8_r0_body.sizeDecA150 PRE_first_tail_x4_L8_r0_body.sizePreA150 PRE_first_tail_x4_L8_r0_body.bodyPatchB150 (fun _ hm => bodyO576 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr576).trans bodyInactive0) (bodyBr577.trans bodyBr576.symm) bodyCnt576 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) bodyAcc577 PRE_first_tail_x4_L8_r0_body.bodyRunSeg150 bodyAcc581 bodyHalt581 PRE_first_tail_x4_L8_r0_body.bodyStepA151 bodyTop582 (fun _ hm => bodyO577 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr577).trans bodyInactive0) (bodyBr582.trans bodyBr577.symm) bodyCnt577 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA151 PRE_first_tail_x4_L8_r0_body.sizeArgsA151 PRE_first_tail_x4_L8_r0_body.sizeSymA151 PRE_first_tail_x4_L8_r0_body.sizeMlxA151 PRE_first_tail_x4_L8_r0_body.sizePayA151 PRE_first_tail_x4_L8_r0_body.sizeTaA151 PRE_first_tail_x4_L8_r0_body.sizeDecA151 PRE_first_tail_x4_L8_r0_body.sizePreA151 PRE_first_tail_x4_L8_r0_body.bodyPatchB151 (fun _ hm => bodyO582 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr582).trans bodyInactive0) (bodyBr583.trans bodyBr582.symm) bodyCnt582 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) bodyAcc583 PRE_first_tail_x4_L8_r0_body.bodyRunSeg151 bodyAcc584 bodyHalt584 PRE_first_tail_x4_L8_r0_body.bodyStepA152 bodyTop585 (fun _ hm => bodyO583 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr583).trans bodyInactive0) (bodyBr585.trans bodyBr583.symm) bodyCnt583 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA152 PRE_first_tail_x4_L8_r0_body.sizeArgsA152 PRE_first_tail_x4_L8_r0_body.sizeSymA152 PRE_first_tail_x4_L8_r0_body.sizeMlxA152 PRE_first_tail_x4_L8_r0_body.sizePayA152 PRE_first_tail_x4_L8_r0_body.sizeTaA152 PRE_first_tail_x4_L8_r0_body.sizeDecA152 PRE_first_tail_x4_L8_r0_body.sizePreA152 PRE_first_tail_x4_L8_r0_body.bodyPatchB152 (fun _ hm => bodyO585 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr585).trans bodyInactive0) (bodyBr586.trans bodyBr585.symm) bodyCnt585 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) bodyAcc586 PRE_first_tail_x4_L8_r0_body.bodyRunSeg152 bodyAcc587 bodyHalt587 PRE_first_tail_x4_L8_r0_body.bodyStepA153 bodyTop588 (fun _ hm => bodyO586 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr586).trans bodyInactive0) (bodyBr588.trans bodyBr586.symm) bodyCnt586 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA153 PRE_first_tail_x4_L8_r0_body.sizeArgsA153 PRE_first_tail_x4_L8_r0_body.sizeSymA153 PRE_first_tail_x4_L8_r0_body.sizeMlxA153 PRE_first_tail_x4_L8_r0_body.sizePayA153 PRE_first_tail_x4_L8_r0_body.sizeTaA153 PRE_first_tail_x4_L8_r0_body.sizeDecA153 PRE_first_tail_x4_L8_r0_body.sizePreA153 PRE_first_tail_x4_L8_r0_body.bodyPatchB153 (fun _ hm => bodyO588 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr588).trans bodyInactive0) (bodyBr589.trans bodyBr588.symm) bodyCnt588 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) bodyAcc589 PRE_first_tail_x4_L8_r0_body.bodyRunSeg153 bodyAcc590 bodyHalt590 PRE_first_tail_x4_L8_r0_body.bodyStepA154 bodyTop591 (fun _ hm => bodyO589 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr589).trans bodyInactive0) (bodyBr591.trans bodyBr589.symm) bodyCnt589 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA154 PRE_first_tail_x4_L8_r0_body.sizeArgsA154 PRE_first_tail_x4_L8_r0_body.sizeSymA154 PRE_first_tail_x4_L8_r0_body.sizeMlxA154 PRE_first_tail_x4_L8_r0_body.sizePayA154 PRE_first_tail_x4_L8_r0_body.sizeTaA154 PRE_first_tail_x4_L8_r0_body.sizeDecA154 PRE_first_tail_x4_L8_r0_body.sizePreA154 PRE_first_tail_x4_L8_r0_body.bodyPatchB154 (fun _ hm => bodyO591 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr591).trans bodyInactive0) (bodyBr592.trans bodyBr591.symm) bodyCnt591 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29194, 533, 0, 0⟩) bodyAcc592 PRE_first_tail_x4_L8_r0_body.bodyRunSeg154 bodyAcc593 bodyHalt593 PRE_first_tail_x4_L8_r0_body.bodyStepA155 bodyTop594 (fun _ hm => bodyO592 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr592).trans bodyInactive0) (bodyBr594.trans bodyBr592.symm) bodyCnt592 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift26 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S594.tab.length PRE_first_tail_x4_L8_r0_body.s594.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P26.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P26 15 PRE_first_tail_x4_L8_r0_body.kappa26 PRE_first_tail_x4_L8_r0_body.s596.ffi PRE_first_tail_x4_L8_r0_body.s595.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_26
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_26
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s596.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S594.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_26] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK26 PRE_first_tail_x4_L8_r0_body.cobjsK26
      PRE_first_tail_x4_L8_r0_body.citemsK26 PRE_first_tail_x4_L8_r0_body.cbd26 PRE_first_tail_x4_L8_r0_body.csst26
  exact PRE_first_tail_x4_L8_r0_body.cshift26 bodyNcl26 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_26] at this; exact this)


kernel_rfl bodyFramesEmpty26 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s595 a).isEmpty) = true
kernel_rfl bodyJsRoots26 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s594.next) PRE_first_tail_x4_L8_r0_body.s596.trace PRE_first_tail_x4_L8_r0_body.s596 = true
kernel_rfl bodyJsNative26 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s596.ffi) = true
kernel_rfl bodyLow26 : (PRE_first_tail_x4_L8_r0_body.cws26 ++ PRE_first_tail_x4_L8_r0_body.ws26).all (Nat.ble 9) = true
kernel_rfl bodyCntM26 : countersOkB PRE_first_tail_x4_L8_r0_body.s594 PRE_first_tail_x4_L8_r0_body.s595 = true
kernel_rfl bodyHi26 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s596.ffi).next setupP.E = true
kernel_rfl bodyNhi26 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s596.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge26 : bridgeOf PRE_first_tail_x4_L8_r0_body.s595.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s594.ffi
kernel_rfl bodyNN26 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s594.ffi).nnext PRE_first_tail_x4_L8_r0_body.P26.NL = true
kernel_rfl bodyXn26 : Nat.ble (⟨19827, 16931, 2739955, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s596.ffi).next = true
kernel_rfl bodyLo26 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s596.ffi).next = true
theorem bodyFacts26 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s594 PRE_first_tail_x4_L8_r0_body.s595 PRE_first_tail_x4_L8_r0_body.s596 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S594 PRE_first_tail_x4_L8_r0_body.S595 PRE_first_tail_x4_L8_r0_body.S596
    PRE_first_tail_x4_L8_r0_body.ws26 PRE_first_tail_x4_L8_r0_body.cws26 PRE_first_tail_x4_L8_r0_body.nr26 PRE_first_tail_x4_L8_r0_body.pl26 PRE_first_tail_x4_L8_r0_body.cl26 2741104 15 PRE_first_tail_x4_L8_r0_body.kd26 PRE_first_tail_x4_L8_r0_body.kappa26 PRE_first_tail_x4_L8_r0_body.P26
    ⟨19824, 16904, 2739949, 15⟩ ⟨19827, 16931, 2739955, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap26
  clean := bodyClean26
  cfix := PRE_first_tail_x4_L8_r0_body.cfix26
  zpl := PRE_first_tail_x4_L8_r0_body.zpl26
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd26
  zn1 := PRE_first_tail_x4_L8_r0_body.zn126
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst26
  zscn := PRE_first_tail_x4_L8_r0_body.zscn26
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn26
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow26
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab26
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh26
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd26
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi26
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt26
  zgP := PRE_first_tail_x4_L8_r0_body.zg26_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk26_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm26_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg26_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk26_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm26_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw26_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw26_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap26
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd26
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap26 PRE_first_tail_x4_L8_r0_body.stFoot26 PRE_first_tail_x4_L8_r0_body.iso26 PRE_first_tail_x4_L8_r0_body.zwr26
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP26
  csupp := PRE_first_tail_x4_L8_r0_body.csupp26
  cbound := PRE_first_tail_x4_L8_r0_body.cbound26
  zimg := PRE_first_tail_x4_L8_r0_body.zimg26
  zctl := PRE_first_tail_x4_L8_r0_body.zctl26
  zstack := PRE_first_tail_x4_L8_r0_body.zstack26
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs26
  zstores := PRE_first_tail_x4_L8_r0_body.zstores26
  zroots := PRE_first_tail_x4_L8_r0_body.zroots26
  znC := PRE_first_tail_x4_L8_r0_body.znC26
  ctab := PRE_first_tail_x4_L8_r0_body.ctab26
  zbin := PRE_first_tail_x4_L8_r0_body.zbin26
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge26
  sbridge := bodyBridge26
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj26
  cshiftR := fun h hNL => bodyCshift26 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN26
  raised := PRE_first_tail_x4_L8_r0_body.raised26
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs26
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl26
  xnLe := Nat.le_of_ble_eq_true bodyXn26
  loLe := Nat.le_of_ble_eq_true bodyLo26
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB26
  cntM := bodyCntM26
  hiLe := Nat.le_of_ble_eq_true bodyHi26
  nhiLe := Nat.le_of_ble_eq_true bodyNhi26
  jsHeap := bodyJs26
  jsRoots := bodyJsRoots26
  jsNative := bodyJsNative26
  framesEmpty := bodyFramesEmpty26
  trailOld := by decide
  lowVars := bodyLow26

def bodyQs26 : List (Option Q) := []
noncomputable def bodyEs26 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr26.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st26.S5.tab r
kernel_rfl bodyResChk26 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs26 bodyQs26) = true
kernel_rfl bodyLq26 : bodyQs26.length = PRE_first_tail_x4_L8_r0_body.cws26.length
kernel_rfl bodyNrLo26 : PRE_first_tail_x4_L8_r0_body.nr26.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S594.tab.length) = true
kernel_rfl bodySub26 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site26.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost26 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws26 PRE_first_tail_x4_L8_r0_body.cws26 bodyQs26 = true
kernel_rfl bodyDrop26 : Nat.ble (29194 + (PRE_first_tail_x4_L8_r0_body.s595.next - PRE_first_tail_x4_L8_r0_body.s596.next)) 30343 = true
kernel_rfl bodyDropH26 : Nat.ble (533 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s595.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s596.ffi).next)) 558 = true
kernel_rfl bodyDropN26 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s595.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s596.ffi).nnext)) 0 = true
kernel_rfl bodyDv26 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws26
kernel_rfl bodyDe26 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr26.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st26.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl26 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold26 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws26).isNone && !PRE_first_tail_x4_L8_r0_body.ws26.contains v) = true
kernel_rfl bodyDfree26 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws26 ++ PRE_first_tail_x4_L8_r0_body.ws26).all fun w => e.noVar w) = true

theorem bodyStep26 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨29194, 533, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s594 PRE_first_tail_x4_L8_r0_body.S594)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30343, 558, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s596 PRE_first_tail_x4_L8_r0_body.S596) (11334 + 1) :=
  bodySite bodyFacts26.cfix bodyFacts26.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st26.S5.tab) (Es := bodyEs26) (qs := bodyQs26)
    (ok := PRE_first_tail_x4_L8_r0_body.st26.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site26 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts26
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site26 r hr) hi (MapOk.sub hm (sub_of_all bodySub26)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk26 r hr) hi hm ho hq)
    bodyLq26 rfl bodyNrLo26 (postSub_sound bodyPost26)
    (Nat.le_of_ble_eq_true bodyDrop26) (by decide) (Nat.le_of_ble_eq_true bodyDropH26) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN26) (by decide)
    bodyDv26 bodyDe26 bodyDl26 bodyDold26 bodyDfree26 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site27 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site27 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site27) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st27.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site27
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st27.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st27.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s615 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s616 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S615 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws27 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st27.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st27.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso27
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_27
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st27.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot27
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup27
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound27
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace27
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged27
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws27.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st27.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S615.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_27]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen27.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh27
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl27 : Conv.NClean (⟨19887, 16976, 2742452, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s615.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl27 (PRE_first_tail_x4_L8_r0_body.cncl26 bodyNcl26)

theorem bodyClean27 : Conv.JClean (⟨19887, 16976, 2742452, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s615 :=
  PRE_first_tail_x4_L8_r0_body.gjcl27 (PRE_first_tail_x4_L8_r0_body.cjcl26 bodyClean26)

kernel_rfl bodyJsLe27 : Nat.ble PRE_first_tail_x4_L8_r0_body.s594.next PRE_first_tail_x4_L8_r0_body.s615.next = true
kernel_rfl bodyJsList27 : (PRE_first_tail_x4_L8_r0_body.gjh27 ++ PRE_first_tail_x4_L8_r0_body.cl27).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s615.next) PRE_first_tail_x4_L8_r0_body.s617) = true
theorem bodyJs27 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s615.next PRE_first_tail_x4_L8_r0_body.s617 :=
  JsHeapAbove.glueSite bodyJs26 (Nat.le_of_ble_eq_true bodyJsLe27) PRE_first_tail_x4_L8_r0_body.gjk27 PRE_first_tail_x4_L8_r0_body.gjbd27 PRE_first_tail_x4_L8_r0_body.cheap27 PRE_first_tail_x4_L8_r0_body.zclbd27 bodyJsList27

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO596 : PRE_first_tail_x4_L8_r0_body.S596.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S596.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr596 : bridgeOf PRE_first_tail_x4_L8_r0_body.s596.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc596 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s596 PRE_first_tail_x4_L8_r0_body.S596) = fun _ _ => true
kernel_rfl bodyAcc597 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s597 PRE_first_tail_x4_L8_r0_body.S597) = fun _ _ => true
kernel_rfl bodyBr598 : bridgeOf PRE_first_tail_x4_L8_r0_body.s598.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt597 : isHalt PRE_first_tail_x4_L8_r0_body.s597.ctl = false
kernel_rfl bodyTop598 : noRetBlock PRE_first_tail_x4_L8_r0_body.s598 = true
kernel_rfl bodyCnt596 : countersOkB PRE_first_tail_x4_L8_r0_body.s596 PRE_first_tail_x4_L8_r0_body.s598 = true
kernel_rfl bodyO598 : PRE_first_tail_x4_L8_r0_body.S598.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S598.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr599 : bridgeOf PRE_first_tail_x4_L8_r0_body.s599.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt598 : countersOkB PRE_first_tail_x4_L8_r0_body.s598 PRE_first_tail_x4_L8_r0_body.s599 = true
kernel_rfl bodyO599 : PRE_first_tail_x4_L8_r0_body.S599.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S599.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc599 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s599 PRE_first_tail_x4_L8_r0_body.S599) = fun _ _ => true
kernel_rfl bodyAcc603 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s603 PRE_first_tail_x4_L8_r0_body.S603) = fun _ _ => true
kernel_rfl bodyBr604 : bridgeOf PRE_first_tail_x4_L8_r0_body.s604.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt603 : isHalt PRE_first_tail_x4_L8_r0_body.s603.ctl = false
kernel_rfl bodyTop604 : noRetBlock PRE_first_tail_x4_L8_r0_body.s604 = true
kernel_rfl bodyCnt599 : countersOkB PRE_first_tail_x4_L8_r0_body.s599 PRE_first_tail_x4_L8_r0_body.s604 = true
kernel_rfl bodyO604 : PRE_first_tail_x4_L8_r0_body.S604.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S604.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr605 : bridgeOf PRE_first_tail_x4_L8_r0_body.s605.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt604 : countersOkB PRE_first_tail_x4_L8_r0_body.s604 PRE_first_tail_x4_L8_r0_body.s605 = true
kernel_rfl bodyO605 : PRE_first_tail_x4_L8_r0_body.S605.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S605.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc605 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s605 PRE_first_tail_x4_L8_r0_body.S605) = fun _ _ => true
kernel_rfl bodyAcc607 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s607 PRE_first_tail_x4_L8_r0_body.S607) = fun _ _ => true
kernel_rfl bodyBr608 : bridgeOf PRE_first_tail_x4_L8_r0_body.s608.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt607 : isHalt PRE_first_tail_x4_L8_r0_body.s607.ctl = false
kernel_rfl bodyTop608 : noRetBlock PRE_first_tail_x4_L8_r0_body.s608 = true
kernel_rfl bodyCnt605 : countersOkB PRE_first_tail_x4_L8_r0_body.s605 PRE_first_tail_x4_L8_r0_body.s608 = true
kernel_rfl bodyO608 : PRE_first_tail_x4_L8_r0_body.S608.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S608.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr609 : bridgeOf PRE_first_tail_x4_L8_r0_body.s609.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt608 : countersOkB PRE_first_tail_x4_L8_r0_body.s608 PRE_first_tail_x4_L8_r0_body.s609 = true
kernel_rfl bodyO609 : PRE_first_tail_x4_L8_r0_body.S609.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S609.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc609 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s609 PRE_first_tail_x4_L8_r0_body.S609) = fun _ _ => true
kernel_rfl bodyAcc610 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s610 PRE_first_tail_x4_L8_r0_body.S610) = fun _ _ => true
kernel_rfl bodyBr611 : bridgeOf PRE_first_tail_x4_L8_r0_body.s611.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt610 : isHalt PRE_first_tail_x4_L8_r0_body.s610.ctl = false
kernel_rfl bodyTop611 : noRetBlock PRE_first_tail_x4_L8_r0_body.s611 = true
kernel_rfl bodyCnt609 : countersOkB PRE_first_tail_x4_L8_r0_body.s609 PRE_first_tail_x4_L8_r0_body.s611 = true
kernel_rfl bodyO611 : PRE_first_tail_x4_L8_r0_body.S611.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S611.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr612 : bridgeOf PRE_first_tail_x4_L8_r0_body.s612.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt611 : countersOkB PRE_first_tail_x4_L8_r0_body.s611 PRE_first_tail_x4_L8_r0_body.s612 = true
kernel_rfl bodyO612 : PRE_first_tail_x4_L8_r0_body.S612.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S612.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc612 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s612 PRE_first_tail_x4_L8_r0_body.S612) = fun _ _ => true
kernel_rfl bodyAcc614 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s614 PRE_first_tail_x4_L8_r0_body.S614) = fun _ _ => true
kernel_rfl bodyBr615 : bridgeOf PRE_first_tail_x4_L8_r0_body.s615.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt614 : isHalt PRE_first_tail_x4_L8_r0_body.s614.ctl = false
kernel_rfl bodyTop615 : noRetBlock PRE_first_tail_x4_L8_r0_body.s615 = true
kernel_rfl bodyCnt612 : countersOkB PRE_first_tail_x4_L8_r0_body.s612 PRE_first_tail_x4_L8_r0_body.s615 = true

theorem bodyGlue27 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30343, 558, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s596 PRE_first_tail_x4_L8_r0_body.S596)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30343, 558, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s615 PRE_first_tail_x4_L8_r0_body.S615) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) bodyAcc596 PRE_first_tail_x4_L8_r0_body.bodyRunSeg155 bodyAcc597 bodyHalt597 PRE_first_tail_x4_L8_r0_body.bodyStepA156 bodyTop598 (fun _ hm => bodyO596 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr596).trans bodyInactive0) (bodyBr598.trans bodyBr596.symm) bodyCnt596 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA156 PRE_first_tail_x4_L8_r0_body.sizeArgsA156 PRE_first_tail_x4_L8_r0_body.sizeSymA156 PRE_first_tail_x4_L8_r0_body.sizeMlxA156 PRE_first_tail_x4_L8_r0_body.sizePayA156 PRE_first_tail_x4_L8_r0_body.sizeTaA156 PRE_first_tail_x4_L8_r0_body.sizeDecA156 PRE_first_tail_x4_L8_r0_body.sizePreA156 PRE_first_tail_x4_L8_r0_body.bodyPatchB156 (fun _ hm => bodyO598 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr598).trans bodyInactive0) (bodyBr599.trans bodyBr598.symm) bodyCnt598 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) bodyAcc599 PRE_first_tail_x4_L8_r0_body.bodyRunSeg156 bodyAcc603 bodyHalt603 PRE_first_tail_x4_L8_r0_body.bodyStepA157 bodyTop604 (fun _ hm => bodyO599 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr599).trans bodyInactive0) (bodyBr604.trans bodyBr599.symm) bodyCnt599 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA157 PRE_first_tail_x4_L8_r0_body.sizeArgsA157 PRE_first_tail_x4_L8_r0_body.sizeSymA157 PRE_first_tail_x4_L8_r0_body.sizeMlxA157 PRE_first_tail_x4_L8_r0_body.sizePayA157 PRE_first_tail_x4_L8_r0_body.sizeTaA157 PRE_first_tail_x4_L8_r0_body.sizeDecA157 PRE_first_tail_x4_L8_r0_body.sizePreA157 PRE_first_tail_x4_L8_r0_body.bodyPatchB157 (fun _ hm => bodyO604 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr604).trans bodyInactive0) (bodyBr605.trans bodyBr604.symm) bodyCnt604 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) bodyAcc605 PRE_first_tail_x4_L8_r0_body.bodyRunSeg157 bodyAcc607 bodyHalt607 PRE_first_tail_x4_L8_r0_body.bodyStepA158 bodyTop608 (fun _ hm => bodyO605 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr605).trans bodyInactive0) (bodyBr608.trans bodyBr605.symm) bodyCnt605 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA158 PRE_first_tail_x4_L8_r0_body.sizeArgsA158 PRE_first_tail_x4_L8_r0_body.sizeSymA158 PRE_first_tail_x4_L8_r0_body.sizeMlxA158 PRE_first_tail_x4_L8_r0_body.sizePayA158 PRE_first_tail_x4_L8_r0_body.sizeTaA158 PRE_first_tail_x4_L8_r0_body.sizeDecA158 PRE_first_tail_x4_L8_r0_body.sizePreA158 PRE_first_tail_x4_L8_r0_body.bodyPatchB158 (fun _ hm => bodyO608 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr608).trans bodyInactive0) (bodyBr609.trans bodyBr608.symm) bodyCnt608 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) bodyAcc609 PRE_first_tail_x4_L8_r0_body.bodyRunSeg158 bodyAcc610 bodyHalt610 PRE_first_tail_x4_L8_r0_body.bodyStepA159 bodyTop611 (fun _ hm => bodyO609 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr609).trans bodyInactive0) (bodyBr611.trans bodyBr609.symm) bodyCnt609 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA159 PRE_first_tail_x4_L8_r0_body.sizeArgsA159 PRE_first_tail_x4_L8_r0_body.sizeSymA159 PRE_first_tail_x4_L8_r0_body.sizeMlxA159 PRE_first_tail_x4_L8_r0_body.sizePayA159 PRE_first_tail_x4_L8_r0_body.sizeTaA159 PRE_first_tail_x4_L8_r0_body.sizeDecA159 PRE_first_tail_x4_L8_r0_body.sizePreA159 PRE_first_tail_x4_L8_r0_body.bodyPatchB159 (fun _ hm => bodyO611 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr611).trans bodyInactive0) (bodyBr612.trans bodyBr611.symm) bodyCnt611 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30343, 558, 0, 0⟩) bodyAcc612 PRE_first_tail_x4_L8_r0_body.bodyRunSeg159 bodyAcc614 bodyHalt614 PRE_first_tail_x4_L8_r0_body.bodyStepA160 bodyTop615 (fun _ hm => bodyO612 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr612).trans bodyInactive0) (bodyBr615.trans bodyBr612.symm) bodyCnt612 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift27 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S615.tab.length PRE_first_tail_x4_L8_r0_body.s615.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P27.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P27 15 PRE_first_tail_x4_L8_r0_body.kappa27 PRE_first_tail_x4_L8_r0_body.s617.ffi PRE_first_tail_x4_L8_r0_body.s616.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_27
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_27
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s617.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S615.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_27] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK27 PRE_first_tail_x4_L8_r0_body.cobjsK27
      PRE_first_tail_x4_L8_r0_body.citemsK27 PRE_first_tail_x4_L8_r0_body.cbd27 PRE_first_tail_x4_L8_r0_body.csst27
  exact PRE_first_tail_x4_L8_r0_body.cshift27 bodyNcl27 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_27] at this; exact this)


kernel_rfl bodyFramesEmpty27 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s616 a).isEmpty) = true
kernel_rfl bodyJsRoots27 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s615.next) PRE_first_tail_x4_L8_r0_body.s617.trace PRE_first_tail_x4_L8_r0_body.s617 = true
kernel_rfl bodyJsNative27 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s617.ffi) = true
kernel_rfl bodyLow27 : (PRE_first_tail_x4_L8_r0_body.cws27 ++ PRE_first_tail_x4_L8_r0_body.ws27).all (Nat.ble 9) = true
kernel_rfl bodyCntM27 : countersOkB PRE_first_tail_x4_L8_r0_body.s615 PRE_first_tail_x4_L8_r0_body.s616 = true
kernel_rfl bodyHi27 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s617.ffi).next setupP.E = true
kernel_rfl bodyNhi27 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s617.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge27 : bridgeOf PRE_first_tail_x4_L8_r0_body.s616.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s615.ffi
kernel_rfl bodyNN27 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s615.ffi).nnext PRE_first_tail_x4_L8_r0_body.P27.NL = true
kernel_rfl bodyXn27 : Nat.ble (⟨19891, 16982, 2742467, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s617.ffi).next = true
kernel_rfl bodyLo27 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s617.ffi).next = true
theorem bodyFacts27 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s615 PRE_first_tail_x4_L8_r0_body.s616 PRE_first_tail_x4_L8_r0_body.s617 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S615 PRE_first_tail_x4_L8_r0_body.S616 PRE_first_tail_x4_L8_r0_body.S617
    PRE_first_tail_x4_L8_r0_body.ws27 PRE_first_tail_x4_L8_r0_body.cws27 PRE_first_tail_x4_L8_r0_body.nr27 PRE_first_tail_x4_L8_r0_body.pl27 PRE_first_tail_x4_L8_r0_body.cl27 2742817 15 PRE_first_tail_x4_L8_r0_body.kd27 PRE_first_tail_x4_L8_r0_body.kappa27 PRE_first_tail_x4_L8_r0_body.P27
    ⟨19887, 16976, 2742452, 15⟩ ⟨19891, 16982, 2742467, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap27
  clean := bodyClean27
  cfix := PRE_first_tail_x4_L8_r0_body.cfix27
  zpl := PRE_first_tail_x4_L8_r0_body.zpl27
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd27
  zn1 := PRE_first_tail_x4_L8_r0_body.zn127
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst27
  zscn := PRE_first_tail_x4_L8_r0_body.zscn27
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn27
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow27
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab27
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh27
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd27
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi27
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt27
  zgP := PRE_first_tail_x4_L8_r0_body.zg27_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk27_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm27_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg27_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk27_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm27_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw27_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw27_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap27
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd27
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap27 PRE_first_tail_x4_L8_r0_body.stFoot27 PRE_first_tail_x4_L8_r0_body.iso27 PRE_first_tail_x4_L8_r0_body.zwr27
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP27
  csupp := PRE_first_tail_x4_L8_r0_body.csupp27
  cbound := PRE_first_tail_x4_L8_r0_body.cbound27
  zimg := PRE_first_tail_x4_L8_r0_body.zimg27
  zctl := PRE_first_tail_x4_L8_r0_body.zctl27
  zstack := PRE_first_tail_x4_L8_r0_body.zstack27
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs27
  zstores := PRE_first_tail_x4_L8_r0_body.zstores27
  zroots := PRE_first_tail_x4_L8_r0_body.zroots27
  znC := PRE_first_tail_x4_L8_r0_body.znC27
  ctab := PRE_first_tail_x4_L8_r0_body.ctab27
  zbin := PRE_first_tail_x4_L8_r0_body.zbin27
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge27
  sbridge := bodyBridge27
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj27
  cshiftR := fun h hNL => bodyCshift27 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN27
  raised := PRE_first_tail_x4_L8_r0_body.raised27
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs27
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl27
  xnLe := Nat.le_of_ble_eq_true bodyXn27
  loLe := Nat.le_of_ble_eq_true bodyLo27
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB27
  cntM := bodyCntM27
  hiLe := Nat.le_of_ble_eq_true bodyHi27
  nhiLe := Nat.le_of_ble_eq_true bodyNhi27
  jsHeap := bodyJs27
  jsRoots := bodyJsRoots27
  jsNative := bodyJsNative27
  framesEmpty := bodyFramesEmpty27
  trailOld := by decide
  lowVars := bodyLow27

def bodyQs27 : List (Option Q) := []
noncomputable def bodyEs27 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr27.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st27.S3.tab r
kernel_rfl bodyResChk27 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs27 bodyQs27) = true
kernel_rfl bodyLq27 : bodyQs27.length = PRE_first_tail_x4_L8_r0_body.cws27.length
kernel_rfl bodyNrLo27 : PRE_first_tail_x4_L8_r0_body.nr27.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S615.tab.length) = true
kernel_rfl bodySub27 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site27.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost27 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws27 PRE_first_tail_x4_L8_r0_body.cws27 bodyQs27 = true
kernel_rfl bodyDrop27 : Nat.ble (30343 + (PRE_first_tail_x4_L8_r0_body.s616.next - PRE_first_tail_x4_L8_r0_body.s617.next)) 30693 = true
kernel_rfl bodyDropH27 : Nat.ble (558 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s616.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s617.ffi).next)) 560 = true
kernel_rfl bodyDropN27 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s616.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s617.ffi).nnext)) 0 = true
kernel_rfl bodyDv27 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws27
kernel_rfl bodyDe27 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr27.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st27.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl27 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold27 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws27).isNone && !PRE_first_tail_x4_L8_r0_body.ws27.contains v) = true
kernel_rfl bodyDfree27 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws27 ++ PRE_first_tail_x4_L8_r0_body.ws27).all fun w => e.noVar w) = true

theorem bodyStep27 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30343, 558, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s615 PRE_first_tail_x4_L8_r0_body.S615)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30693, 560, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s617 PRE_first_tail_x4_L8_r0_body.S617) (3452 + 1) :=
  bodySite bodyFacts27.cfix bodyFacts27.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L8_r0_body.st27.S3.tab) (Es := bodyEs27) (qs := bodyQs27)
    (ok := PRE_first_tail_x4_L8_r0_body.st27.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site27 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts27
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site27 r hr) hi (MapOk.sub hm (sub_of_all bodySub27)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk27 r hr) hi hm ho hq)
    bodyLq27 rfl bodyNrLo27 (postSub_sound bodyPost27)
    (Nat.le_of_ble_eq_true bodyDrop27) (by decide) (Nat.le_of_ble_eq_true bodyDropH27) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN27) (by decide)
    bodyDv27 bodyDe27 bodyDl27 bodyDold27 bodyDfree27 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyOracles_7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_g28 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g28 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g28) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site28 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site28 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site28) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st28.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g29 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g29 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g29) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site29 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site29 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site29) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st29.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g30 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g30 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g30) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site30 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site30 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site30) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st30.S0.oracle) = true

def PRE_first_tail_x4_L8_r0_body.map_g31 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_g31 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_g31) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.O))) = true

def PRE_first_tail_x4_L8_r0_body.map_site31 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site31 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site31) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st31.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site28 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site28 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site28) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st28.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site28
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st28.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st28.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s639 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s640 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S639 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws28 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st28.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st28.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso28
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_28
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st28.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot28
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup28
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound28
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace28
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged28
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws28.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st28.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S639.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_28]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen28.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh28
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl28 : Conv.NClean (⟨19959, 17028, 2745471, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s639.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl28 (PRE_first_tail_x4_L8_r0_body.cncl27 bodyNcl27)

theorem bodyClean28 : Conv.JClean (⟨19959, 17028, 2745471, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s639 :=
  PRE_first_tail_x4_L8_r0_body.gjcl28 (PRE_first_tail_x4_L8_r0_body.cjcl27 bodyClean27)

kernel_rfl bodyJsLe28 : Nat.ble PRE_first_tail_x4_L8_r0_body.s615.next PRE_first_tail_x4_L8_r0_body.s639.next = true
kernel_rfl bodyJsList28 : (PRE_first_tail_x4_L8_r0_body.gjh28 ++ PRE_first_tail_x4_L8_r0_body.cl28).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s639.next) PRE_first_tail_x4_L8_r0_body.s641) = true
theorem bodyJs28 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s639.next PRE_first_tail_x4_L8_r0_body.s641 :=
  JsHeapAbove.glueSite bodyJs27 (Nat.le_of_ble_eq_true bodyJsLe28) PRE_first_tail_x4_L8_r0_body.gjk28 PRE_first_tail_x4_L8_r0_body.gjbd28 PRE_first_tail_x4_L8_r0_body.cheap28 PRE_first_tail_x4_L8_r0_body.zclbd28 bodyJsList28

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO617 : PRE_first_tail_x4_L8_r0_body.S617.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S617.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr617 : bridgeOf PRE_first_tail_x4_L8_r0_body.s617.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc617 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s617 PRE_first_tail_x4_L8_r0_body.S617) = fun _ _ => true
kernel_rfl bodyAcc620 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s620 PRE_first_tail_x4_L8_r0_body.S620) = fun _ _ => true
kernel_rfl bodyBr621 : bridgeOf PRE_first_tail_x4_L8_r0_body.s621.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt620 : isHalt PRE_first_tail_x4_L8_r0_body.s620.ctl = false
kernel_rfl bodyTop621 : noRetBlock PRE_first_tail_x4_L8_r0_body.s621 = true
kernel_rfl bodyCnt617 : countersOkB PRE_first_tail_x4_L8_r0_body.s617 PRE_first_tail_x4_L8_r0_body.s621 = true
kernel_rfl bodyO621 : PRE_first_tail_x4_L8_r0_body.S621.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S621.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr622 : bridgeOf PRE_first_tail_x4_L8_r0_body.s622.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt621 : countersOkB PRE_first_tail_x4_L8_r0_body.s621 PRE_first_tail_x4_L8_r0_body.s622 = true
kernel_rfl bodyO622 : PRE_first_tail_x4_L8_r0_body.S622.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S622.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc622 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s622 PRE_first_tail_x4_L8_r0_body.S622) = fun _ _ => true
kernel_rfl bodyAcc626 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s626 PRE_first_tail_x4_L8_r0_body.S626) = fun _ _ => true
kernel_rfl bodyBr627 : bridgeOf PRE_first_tail_x4_L8_r0_body.s627.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt626 : isHalt PRE_first_tail_x4_L8_r0_body.s626.ctl = false
kernel_rfl bodyTop627 : noRetBlock PRE_first_tail_x4_L8_r0_body.s627 = true
kernel_rfl bodyCnt622 : countersOkB PRE_first_tail_x4_L8_r0_body.s622 PRE_first_tail_x4_L8_r0_body.s627 = true
kernel_rfl bodyO627 : PRE_first_tail_x4_L8_r0_body.S627.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S627.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr628 : bridgeOf PRE_first_tail_x4_L8_r0_body.s628.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt627 : countersOkB PRE_first_tail_x4_L8_r0_body.s627 PRE_first_tail_x4_L8_r0_body.s628 = true
kernel_rfl bodyO628 : PRE_first_tail_x4_L8_r0_body.S628.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S628.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc628 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s628 PRE_first_tail_x4_L8_r0_body.S628) = fun _ _ => true
kernel_rfl bodyAcc629 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s629 PRE_first_tail_x4_L8_r0_body.S629) = fun _ _ => true
kernel_rfl bodyBr630 : bridgeOf PRE_first_tail_x4_L8_r0_body.s630.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt629 : isHalt PRE_first_tail_x4_L8_r0_body.s629.ctl = false
kernel_rfl bodyTop630 : noRetBlock PRE_first_tail_x4_L8_r0_body.s630 = true
kernel_rfl bodyCnt628 : countersOkB PRE_first_tail_x4_L8_r0_body.s628 PRE_first_tail_x4_L8_r0_body.s630 = true
kernel_rfl bodyO630 : PRE_first_tail_x4_L8_r0_body.S630.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S630.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr631 : bridgeOf PRE_first_tail_x4_L8_r0_body.s631.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt630 : countersOkB PRE_first_tail_x4_L8_r0_body.s630 PRE_first_tail_x4_L8_r0_body.s631 = true
kernel_rfl bodyO631 : PRE_first_tail_x4_L8_r0_body.S631.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S631.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc631 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s631 PRE_first_tail_x4_L8_r0_body.S631) = fun _ _ => true
kernel_rfl bodyAcc632 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s632 PRE_first_tail_x4_L8_r0_body.S632) = fun _ _ => true
kernel_rfl bodyBr633 : bridgeOf PRE_first_tail_x4_L8_r0_body.s633.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt632 : isHalt PRE_first_tail_x4_L8_r0_body.s632.ctl = false
kernel_rfl bodyTop633 : noRetBlock PRE_first_tail_x4_L8_r0_body.s633 = true
kernel_rfl bodyCnt631 : countersOkB PRE_first_tail_x4_L8_r0_body.s631 PRE_first_tail_x4_L8_r0_body.s633 = true
kernel_rfl bodyO633 : PRE_first_tail_x4_L8_r0_body.S633.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S633.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr634 : bridgeOf PRE_first_tail_x4_L8_r0_body.s634.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt633 : countersOkB PRE_first_tail_x4_L8_r0_body.s633 PRE_first_tail_x4_L8_r0_body.s634 = true
kernel_rfl bodyO634 : PRE_first_tail_x4_L8_r0_body.S634.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S634.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc634 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s634 PRE_first_tail_x4_L8_r0_body.S634) = fun _ _ => true
kernel_rfl bodyAcc635 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s635 PRE_first_tail_x4_L8_r0_body.S635) = fun _ _ => true
kernel_rfl bodyBr636 : bridgeOf PRE_first_tail_x4_L8_r0_body.s636.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt635 : isHalt PRE_first_tail_x4_L8_r0_body.s635.ctl = false
kernel_rfl bodyTop636 : noRetBlock PRE_first_tail_x4_L8_r0_body.s636 = true
kernel_rfl bodyCnt634 : countersOkB PRE_first_tail_x4_L8_r0_body.s634 PRE_first_tail_x4_L8_r0_body.s636 = true
kernel_rfl bodyO636 : PRE_first_tail_x4_L8_r0_body.S636.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S636.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr637 : bridgeOf PRE_first_tail_x4_L8_r0_body.s637.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt636 : countersOkB PRE_first_tail_x4_L8_r0_body.s636 PRE_first_tail_x4_L8_r0_body.s637 = true
kernel_rfl bodyO637 : PRE_first_tail_x4_L8_r0_body.S637.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S637.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc637 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s637 PRE_first_tail_x4_L8_r0_body.S637) = fun _ _ => true
kernel_rfl bodyAcc638 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s638 PRE_first_tail_x4_L8_r0_body.S638) = fun _ _ => true
kernel_rfl bodyBr639 : bridgeOf PRE_first_tail_x4_L8_r0_body.s639.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt638 : isHalt PRE_first_tail_x4_L8_r0_body.s638.ctl = false
kernel_rfl bodyTop639 : noRetBlock PRE_first_tail_x4_L8_r0_body.s639 = true
kernel_rfl bodyCnt637 : countersOkB PRE_first_tail_x4_L8_r0_body.s637 PRE_first_tail_x4_L8_r0_body.s639 = true

theorem bodyGlue28 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30693, 560, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s617 PRE_first_tail_x4_L8_r0_body.S617)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30693, 560, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s639 PRE_first_tail_x4_L8_r0_body.S639) 30538 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) bodyAcc617 PRE_first_tail_x4_L8_r0_body.bodyRunSeg160 bodyAcc620 bodyHalt620 PRE_first_tail_x4_L8_r0_body.bodyStepA161 bodyTop621 (fun _ hm => bodyO617 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr617).trans bodyInactive0) (bodyBr621.trans bodyBr617.symm) bodyCnt617 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA161 PRE_first_tail_x4_L8_r0_body.sizeArgsA161 PRE_first_tail_x4_L8_r0_body.sizeSymA161 PRE_first_tail_x4_L8_r0_body.sizeMlxA161 PRE_first_tail_x4_L8_r0_body.sizePayA161 PRE_first_tail_x4_L8_r0_body.sizeTaA161 PRE_first_tail_x4_L8_r0_body.sizeDecA161 PRE_first_tail_x4_L8_r0_body.sizePreA161 PRE_first_tail_x4_L8_r0_body.bodyPatchB161 (fun _ hm => bodyO621 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr621).trans bodyInactive0) (bodyBr622.trans bodyBr621.symm) bodyCnt621 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) bodyAcc622 PRE_first_tail_x4_L8_r0_body.bodyRunSeg161 bodyAcc626 bodyHalt626 PRE_first_tail_x4_L8_r0_body.bodyStepA162 bodyTop627 (fun _ hm => bodyO622 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr622).trans bodyInactive0) (bodyBr627.trans bodyBr622.symm) bodyCnt622 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA162 PRE_first_tail_x4_L8_r0_body.sizeArgsA162 PRE_first_tail_x4_L8_r0_body.sizeSymA162 PRE_first_tail_x4_L8_r0_body.sizeMlxA162 PRE_first_tail_x4_L8_r0_body.sizePayA162 PRE_first_tail_x4_L8_r0_body.sizeTaA162 PRE_first_tail_x4_L8_r0_body.sizeDecA162 PRE_first_tail_x4_L8_r0_body.sizePreA162 PRE_first_tail_x4_L8_r0_body.bodyPatchB162 (fun _ hm => bodyO627 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr627).trans bodyInactive0) (bodyBr628.trans bodyBr627.symm) bodyCnt627 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) bodyAcc628 PRE_first_tail_x4_L8_r0_body.bodyRunSeg162 bodyAcc629 bodyHalt629 PRE_first_tail_x4_L8_r0_body.bodyStepA163 bodyTop630 (fun _ hm => bodyO628 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr628).trans bodyInactive0) (bodyBr630.trans bodyBr628.symm) bodyCnt628 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA163 PRE_first_tail_x4_L8_r0_body.sizeArgsA163 PRE_first_tail_x4_L8_r0_body.sizeSymA163 PRE_first_tail_x4_L8_r0_body.sizeMlxA163 PRE_first_tail_x4_L8_r0_body.sizePayA163 PRE_first_tail_x4_L8_r0_body.sizeTaA163 PRE_first_tail_x4_L8_r0_body.sizeDecA163 PRE_first_tail_x4_L8_r0_body.sizePreA163 PRE_first_tail_x4_L8_r0_body.bodyPatchB163 (fun _ hm => bodyO630 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr630).trans bodyInactive0) (bodyBr631.trans bodyBr630.symm) bodyCnt630 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) bodyAcc631 PRE_first_tail_x4_L8_r0_body.bodyRunSeg163 bodyAcc632 bodyHalt632 PRE_first_tail_x4_L8_r0_body.bodyStepA164 bodyTop633 (fun _ hm => bodyO631 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr631).trans bodyInactive0) (bodyBr633.trans bodyBr631.symm) bodyCnt631 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA164 PRE_first_tail_x4_L8_r0_body.sizeArgsA164 PRE_first_tail_x4_L8_r0_body.sizeSymA164 PRE_first_tail_x4_L8_r0_body.sizeMlxA164 PRE_first_tail_x4_L8_r0_body.sizePayA164 PRE_first_tail_x4_L8_r0_body.sizeTaA164 PRE_first_tail_x4_L8_r0_body.sizeDecA164 PRE_first_tail_x4_L8_r0_body.sizePreA164 PRE_first_tail_x4_L8_r0_body.bodyPatchB164 (fun _ hm => bodyO633 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr633).trans bodyInactive0) (bodyBr634.trans bodyBr633.symm) bodyCnt633 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) bodyAcc634 PRE_first_tail_x4_L8_r0_body.bodyRunSeg164 bodyAcc635 bodyHalt635 PRE_first_tail_x4_L8_r0_body.bodyStepA165 bodyTop636 (fun _ hm => bodyO634 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr634).trans bodyInactive0) (bodyBr636.trans bodyBr634.symm) bodyCnt634 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA165 PRE_first_tail_x4_L8_r0_body.sizeArgsA165 PRE_first_tail_x4_L8_r0_body.sizeSymA165 PRE_first_tail_x4_L8_r0_body.sizeMlxA165 PRE_first_tail_x4_L8_r0_body.sizePayA165 PRE_first_tail_x4_L8_r0_body.sizeTaA165 PRE_first_tail_x4_L8_r0_body.sizeDecA165 PRE_first_tail_x4_L8_r0_body.sizePreA165 PRE_first_tail_x4_L8_r0_body.bodyPatchB165 (fun _ hm => bodyO636 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr636).trans bodyInactive0) (bodyBr637.trans bodyBr636.symm) bodyCnt636 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30693, 560, 0, 0⟩) bodyAcc637 PRE_first_tail_x4_L8_r0_body.bodyRunSeg165 bodyAcc638 bodyHalt638 PRE_first_tail_x4_L8_r0_body.bodyStepA166 bodyTop639 (fun _ hm => bodyO637 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr637).trans bodyInactive0) (bodyBr639.trans bodyBr637.symm) bodyCnt637 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift28 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S639.tab.length PRE_first_tail_x4_L8_r0_body.s639.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P28.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P28 15 PRE_first_tail_x4_L8_r0_body.kappa28 PRE_first_tail_x4_L8_r0_body.s641.ffi PRE_first_tail_x4_L8_r0_body.s640.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_28
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_28
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s641.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S639.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_28] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK28 PRE_first_tail_x4_L8_r0_body.cobjsK28
      PRE_first_tail_x4_L8_r0_body.citemsK28 PRE_first_tail_x4_L8_r0_body.cbd28 PRE_first_tail_x4_L8_r0_body.csst28
  exact PRE_first_tail_x4_L8_r0_body.cshift28 bodyNcl28 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_28] at this; exact this)


kernel_rfl bodyFramesEmpty28 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s640 a).isEmpty) = true
kernel_rfl bodyJsRoots28 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s639.next) PRE_first_tail_x4_L8_r0_body.s641.trace PRE_first_tail_x4_L8_r0_body.s641 = true
kernel_rfl bodyJsNative28 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s641.ffi) = true
kernel_rfl bodyLow28 : (PRE_first_tail_x4_L8_r0_body.cws28 ++ PRE_first_tail_x4_L8_r0_body.ws28).all (Nat.ble 9) = true
kernel_rfl bodyCntM28 : countersOkB PRE_first_tail_x4_L8_r0_body.s639 PRE_first_tail_x4_L8_r0_body.s640 = true
kernel_rfl bodyHi28 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s641.ffi).next setupP.E = true
kernel_rfl bodyNhi28 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s641.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge28 : bridgeOf PRE_first_tail_x4_L8_r0_body.s640.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s639.ffi
kernel_rfl bodyNN28 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s639.ffi).nnext PRE_first_tail_x4_L8_r0_body.P28.NL = true
kernel_rfl bodyXn28 : Nat.ble (⟨19962, 17055, 2745477, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s641.ffi).next = true
kernel_rfl bodyLo28 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s641.ffi).next = true
theorem bodyFacts28 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s639 PRE_first_tail_x4_L8_r0_body.s640 PRE_first_tail_x4_L8_r0_body.s641 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S639 PRE_first_tail_x4_L8_r0_body.S640 PRE_first_tail_x4_L8_r0_body.S641
    PRE_first_tail_x4_L8_r0_body.ws28 PRE_first_tail_x4_L8_r0_body.cws28 PRE_first_tail_x4_L8_r0_body.nr28 PRE_first_tail_x4_L8_r0_body.pl28 PRE_first_tail_x4_L8_r0_body.cl28 2746626 15 PRE_first_tail_x4_L8_r0_body.kd28 PRE_first_tail_x4_L8_r0_body.kappa28 PRE_first_tail_x4_L8_r0_body.P28
    ⟨19959, 17028, 2745471, 15⟩ ⟨19962, 17055, 2745477, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap28
  clean := bodyClean28
  cfix := PRE_first_tail_x4_L8_r0_body.cfix28
  zpl := PRE_first_tail_x4_L8_r0_body.zpl28
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd28
  zn1 := PRE_first_tail_x4_L8_r0_body.zn128
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst28
  zscn := PRE_first_tail_x4_L8_r0_body.zscn28
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn28
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow28
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab28
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh28
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd28
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi28
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt28
  zgP := PRE_first_tail_x4_L8_r0_body.zg28_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk28_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm28_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg28_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk28_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm28_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw28_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw28_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap28
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd28
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap28 PRE_first_tail_x4_L8_r0_body.stFoot28 PRE_first_tail_x4_L8_r0_body.iso28 PRE_first_tail_x4_L8_r0_body.zwr28
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP28
  csupp := PRE_first_tail_x4_L8_r0_body.csupp28
  cbound := PRE_first_tail_x4_L8_r0_body.cbound28
  zimg := PRE_first_tail_x4_L8_r0_body.zimg28
  zctl := PRE_first_tail_x4_L8_r0_body.zctl28
  zstack := PRE_first_tail_x4_L8_r0_body.zstack28
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs28
  zstores := PRE_first_tail_x4_L8_r0_body.zstores28
  zroots := PRE_first_tail_x4_L8_r0_body.zroots28
  znC := PRE_first_tail_x4_L8_r0_body.znC28
  ctab := PRE_first_tail_x4_L8_r0_body.ctab28
  zbin := PRE_first_tail_x4_L8_r0_body.zbin28
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge28
  sbridge := bodyBridge28
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj28
  cshiftR := fun h hNL => bodyCshift28 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN28
  raised := PRE_first_tail_x4_L8_r0_body.raised28
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs28
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl28
  xnLe := Nat.le_of_ble_eq_true bodyXn28
  loLe := Nat.le_of_ble_eq_true bodyLo28
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB28
  cntM := bodyCntM28
  hiLe := Nat.le_of_ble_eq_true bodyHi28
  nhiLe := Nat.le_of_ble_eq_true bodyNhi28
  jsHeap := bodyJs28
  jsRoots := bodyJsRoots28
  jsNative := bodyJsNative28
  framesEmpty := bodyFramesEmpty28
  trailOld := by decide
  lowVars := bodyLow28

def bodyQs28 : List (Option Q) := []
noncomputable def bodyEs28 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr28.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st28.S5.tab r
kernel_rfl bodyResChk28 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs28 bodyQs28) = true
kernel_rfl bodyLq28 : bodyQs28.length = PRE_first_tail_x4_L8_r0_body.cws28.length
kernel_rfl bodyNrLo28 : PRE_first_tail_x4_L8_r0_body.nr28.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S639.tab.length) = true
kernel_rfl bodySub28 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site28.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost28 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws28 PRE_first_tail_x4_L8_r0_body.cws28 bodyQs28 = true
kernel_rfl bodyDrop28 : Nat.ble (30693 + (PRE_first_tail_x4_L8_r0_body.s640.next - PRE_first_tail_x4_L8_r0_body.s641.next)) 31842 = true
kernel_rfl bodyDropH28 : Nat.ble (560 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s640.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s641.ffi).next)) 585 = true
kernel_rfl bodyDropN28 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s640.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s641.ffi).nnext)) 0 = true
kernel_rfl bodyDv28 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws28
kernel_rfl bodyDe28 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr28.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st28.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl28 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold28 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws28).isNone && !PRE_first_tail_x4_L8_r0_body.ws28.contains v) = true
kernel_rfl bodyDfree28 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws28 ++ PRE_first_tail_x4_L8_r0_body.ws28).all fun w => e.noVar w) = true

theorem bodyStep28 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30693, 560, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s639 PRE_first_tail_x4_L8_r0_body.S639)
      (bodyCut NB T tk π i x0 bodyΘ ⟨31842, 585, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s641 PRE_first_tail_x4_L8_r0_body.S641) (11334 + 1) :=
  bodySite bodyFacts28.cfix bodyFacts28.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st28.S5.tab) (Es := bodyEs28) (qs := bodyQs28)
    (ok := PRE_first_tail_x4_L8_r0_body.st28.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site28 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts28
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site28 r hr) hi (MapOk.sub hm (sub_of_all bodySub28)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk28 r hr) hi hm ho hq)
    bodyLq28 rfl bodyNrLo28 (postSub_sound bodyPost28)
    (Nat.le_of_ble_eq_true bodyDrop28) (by decide) (Nat.le_of_ble_eq_true bodyDropH28) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN28) (by decide)
    bodyDv28 bodyDe28 bodyDl28 bodyDold28 bodyDfree28 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site29 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site29 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site29) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st29.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site29
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st29.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st29.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s661 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s662 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S661 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws29 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st29.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st29.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso29
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_29
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st29.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot29
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup29
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound29
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace29
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged29
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws29.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st29.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S661.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_29]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen29.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh29
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl29 : Conv.NClean (⟨20016, 17091, 2747709, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s661.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl29 (PRE_first_tail_x4_L8_r0_body.cncl28 bodyNcl28)

theorem bodyClean29 : Conv.JClean (⟨20016, 17091, 2747709, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s661 :=
  PRE_first_tail_x4_L8_r0_body.gjcl29 (PRE_first_tail_x4_L8_r0_body.cjcl28 bodyClean28)

kernel_rfl bodyJsLe29 : Nat.ble PRE_first_tail_x4_L8_r0_body.s639.next PRE_first_tail_x4_L8_r0_body.s661.next = true
kernel_rfl bodyJsList29 : (PRE_first_tail_x4_L8_r0_body.gjh29 ++ PRE_first_tail_x4_L8_r0_body.cl29).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s661.next) PRE_first_tail_x4_L8_r0_body.s663) = true
theorem bodyJs29 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s661.next PRE_first_tail_x4_L8_r0_body.s663 :=
  JsHeapAbove.glueSite bodyJs28 (Nat.le_of_ble_eq_true bodyJsLe29) PRE_first_tail_x4_L8_r0_body.gjk29 PRE_first_tail_x4_L8_r0_body.gjbd29 PRE_first_tail_x4_L8_r0_body.cheap29 PRE_first_tail_x4_L8_r0_body.zclbd29 bodyJsList29

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO641 : PRE_first_tail_x4_L8_r0_body.S641.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S641.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr641 : bridgeOf PRE_first_tail_x4_L8_r0_body.s641.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc641 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s641 PRE_first_tail_x4_L8_r0_body.S641) = fun _ _ => true
kernel_rfl bodyAcc642 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s642 PRE_first_tail_x4_L8_r0_body.S642) = fun _ _ => true
kernel_rfl bodyBr643 : bridgeOf PRE_first_tail_x4_L8_r0_body.s643.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt642 : isHalt PRE_first_tail_x4_L8_r0_body.s642.ctl = false
kernel_rfl bodyTop643 : noRetBlock PRE_first_tail_x4_L8_r0_body.s643 = true
kernel_rfl bodyCnt641 : countersOkB PRE_first_tail_x4_L8_r0_body.s641 PRE_first_tail_x4_L8_r0_body.s643 = true
kernel_rfl bodyO643 : PRE_first_tail_x4_L8_r0_body.S643.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S643.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr644 : bridgeOf PRE_first_tail_x4_L8_r0_body.s644.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt643 : countersOkB PRE_first_tail_x4_L8_r0_body.s643 PRE_first_tail_x4_L8_r0_body.s644 = true
kernel_rfl bodyO644 : PRE_first_tail_x4_L8_r0_body.S644.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S644.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc644 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s644 PRE_first_tail_x4_L8_r0_body.S644) = fun _ _ => true
kernel_rfl bodyAcc648 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s648 PRE_first_tail_x4_L8_r0_body.S648) = fun _ _ => true
kernel_rfl bodyBr649 : bridgeOf PRE_first_tail_x4_L8_r0_body.s649.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt648 : isHalt PRE_first_tail_x4_L8_r0_body.s648.ctl = false
kernel_rfl bodyTop649 : noRetBlock PRE_first_tail_x4_L8_r0_body.s649 = true
kernel_rfl bodyCnt644 : countersOkB PRE_first_tail_x4_L8_r0_body.s644 PRE_first_tail_x4_L8_r0_body.s649 = true
kernel_rfl bodyO649 : PRE_first_tail_x4_L8_r0_body.S649.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S649.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr650 : bridgeOf PRE_first_tail_x4_L8_r0_body.s650.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt649 : countersOkB PRE_first_tail_x4_L8_r0_body.s649 PRE_first_tail_x4_L8_r0_body.s650 = true
kernel_rfl bodyO650 : PRE_first_tail_x4_L8_r0_body.S650.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S650.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc650 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s650 PRE_first_tail_x4_L8_r0_body.S650) = fun _ _ => true
kernel_rfl bodyAcc651 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s651 PRE_first_tail_x4_L8_r0_body.S651) = fun _ _ => true
kernel_rfl bodyBr652 : bridgeOf PRE_first_tail_x4_L8_r0_body.s652.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt651 : isHalt PRE_first_tail_x4_L8_r0_body.s651.ctl = false
kernel_rfl bodyTop652 : noRetBlock PRE_first_tail_x4_L8_r0_body.s652 = true
kernel_rfl bodyCnt650 : countersOkB PRE_first_tail_x4_L8_r0_body.s650 PRE_first_tail_x4_L8_r0_body.s652 = true
kernel_rfl bodyO652 : PRE_first_tail_x4_L8_r0_body.S652.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S652.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr653 : bridgeOf PRE_first_tail_x4_L8_r0_body.s653.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt652 : countersOkB PRE_first_tail_x4_L8_r0_body.s652 PRE_first_tail_x4_L8_r0_body.s653 = true
kernel_rfl bodyO653 : PRE_first_tail_x4_L8_r0_body.S653.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S653.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc653 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s653 PRE_first_tail_x4_L8_r0_body.S653) = fun _ _ => true
kernel_rfl bodyAcc654 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s654 PRE_first_tail_x4_L8_r0_body.S654) = fun _ _ => true
kernel_rfl bodyBr655 : bridgeOf PRE_first_tail_x4_L8_r0_body.s655.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt654 : isHalt PRE_first_tail_x4_L8_r0_body.s654.ctl = false
kernel_rfl bodyTop655 : noRetBlock PRE_first_tail_x4_L8_r0_body.s655 = true
kernel_rfl bodyCnt653 : countersOkB PRE_first_tail_x4_L8_r0_body.s653 PRE_first_tail_x4_L8_r0_body.s655 = true
kernel_rfl bodyO655 : PRE_first_tail_x4_L8_r0_body.S655.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S655.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr656 : bridgeOf PRE_first_tail_x4_L8_r0_body.s656.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt655 : countersOkB PRE_first_tail_x4_L8_r0_body.s655 PRE_first_tail_x4_L8_r0_body.s656 = true
kernel_rfl bodyO656 : PRE_first_tail_x4_L8_r0_body.S656.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S656.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc656 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s656 PRE_first_tail_x4_L8_r0_body.S656) = fun _ _ => true
kernel_rfl bodyAcc657 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s657 PRE_first_tail_x4_L8_r0_body.S657) = fun _ _ => true
kernel_rfl bodyBr658 : bridgeOf PRE_first_tail_x4_L8_r0_body.s658.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt657 : isHalt PRE_first_tail_x4_L8_r0_body.s657.ctl = false
kernel_rfl bodyTop658 : noRetBlock PRE_first_tail_x4_L8_r0_body.s658 = true
kernel_rfl bodyCnt656 : countersOkB PRE_first_tail_x4_L8_r0_body.s656 PRE_first_tail_x4_L8_r0_body.s658 = true
kernel_rfl bodyO658 : PRE_first_tail_x4_L8_r0_body.S658.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S658.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr659 : bridgeOf PRE_first_tail_x4_L8_r0_body.s659.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt658 : countersOkB PRE_first_tail_x4_L8_r0_body.s658 PRE_first_tail_x4_L8_r0_body.s659 = true
kernel_rfl bodyO659 : PRE_first_tail_x4_L8_r0_body.S659.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S659.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc659 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s659 PRE_first_tail_x4_L8_r0_body.S659) = fun _ _ => true
kernel_rfl bodyAcc660 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s660 PRE_first_tail_x4_L8_r0_body.S660) = fun _ _ => true
kernel_rfl bodyBr661 : bridgeOf PRE_first_tail_x4_L8_r0_body.s661.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt660 : isHalt PRE_first_tail_x4_L8_r0_body.s660.ctl = false
kernel_rfl bodyTop661 : noRetBlock PRE_first_tail_x4_L8_r0_body.s661 = true
kernel_rfl bodyCnt659 : countersOkB PRE_first_tail_x4_L8_r0_body.s659 PRE_first_tail_x4_L8_r0_body.s661 = true

theorem bodyGlue29 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨31842, 585, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s641 PRE_first_tail_x4_L8_r0_body.S641)
      (bodyCut NB T tk π i x0 bodyΘ ⟨31842, 585, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s661 PRE_first_tail_x4_L8_r0_body.S661) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) bodyAcc641 PRE_first_tail_x4_L8_r0_body.bodyRunSeg166 bodyAcc642 bodyHalt642 PRE_first_tail_x4_L8_r0_body.bodyStepA167 bodyTop643 (fun _ hm => bodyO641 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr641).trans bodyInactive0) (bodyBr643.trans bodyBr641.symm) bodyCnt641 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA167 PRE_first_tail_x4_L8_r0_body.sizeArgsA167 PRE_first_tail_x4_L8_r0_body.sizeSymA167 PRE_first_tail_x4_L8_r0_body.sizeMlxA167 PRE_first_tail_x4_L8_r0_body.sizePayA167 PRE_first_tail_x4_L8_r0_body.sizeTaA167 PRE_first_tail_x4_L8_r0_body.sizeDecA167 PRE_first_tail_x4_L8_r0_body.sizePreA167 PRE_first_tail_x4_L8_r0_body.bodyPatchB167 (fun _ hm => bodyO643 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr643).trans bodyInactive0) (bodyBr644.trans bodyBr643.symm) bodyCnt643 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) bodyAcc644 PRE_first_tail_x4_L8_r0_body.bodyRunSeg167 bodyAcc648 bodyHalt648 PRE_first_tail_x4_L8_r0_body.bodyStepA168 bodyTop649 (fun _ hm => bodyO644 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr644).trans bodyInactive0) (bodyBr649.trans bodyBr644.symm) bodyCnt644 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA168 PRE_first_tail_x4_L8_r0_body.sizeArgsA168 PRE_first_tail_x4_L8_r0_body.sizeSymA168 PRE_first_tail_x4_L8_r0_body.sizeMlxA168 PRE_first_tail_x4_L8_r0_body.sizePayA168 PRE_first_tail_x4_L8_r0_body.sizeTaA168 PRE_first_tail_x4_L8_r0_body.sizeDecA168 PRE_first_tail_x4_L8_r0_body.sizePreA168 PRE_first_tail_x4_L8_r0_body.bodyPatchB168 (fun _ hm => bodyO649 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr649).trans bodyInactive0) (bodyBr650.trans bodyBr649.symm) bodyCnt649 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) bodyAcc650 PRE_first_tail_x4_L8_r0_body.bodyRunSeg168 bodyAcc651 bodyHalt651 PRE_first_tail_x4_L8_r0_body.bodyStepA169 bodyTop652 (fun _ hm => bodyO650 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr650).trans bodyInactive0) (bodyBr652.trans bodyBr650.symm) bodyCnt650 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA169 PRE_first_tail_x4_L8_r0_body.sizeArgsA169 PRE_first_tail_x4_L8_r0_body.sizeSymA169 PRE_first_tail_x4_L8_r0_body.sizeMlxA169 PRE_first_tail_x4_L8_r0_body.sizePayA169 PRE_first_tail_x4_L8_r0_body.sizeTaA169 PRE_first_tail_x4_L8_r0_body.sizeDecA169 PRE_first_tail_x4_L8_r0_body.sizePreA169 PRE_first_tail_x4_L8_r0_body.bodyPatchB169 (fun _ hm => bodyO652 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr652).trans bodyInactive0) (bodyBr653.trans bodyBr652.symm) bodyCnt652 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) bodyAcc653 PRE_first_tail_x4_L8_r0_body.bodyRunSeg169 bodyAcc654 bodyHalt654 PRE_first_tail_x4_L8_r0_body.bodyStepA170 bodyTop655 (fun _ hm => bodyO653 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr653).trans bodyInactive0) (bodyBr655.trans bodyBr653.symm) bodyCnt653 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA170 PRE_first_tail_x4_L8_r0_body.sizeArgsA170 PRE_first_tail_x4_L8_r0_body.sizeSymA170 PRE_first_tail_x4_L8_r0_body.sizeMlxA170 PRE_first_tail_x4_L8_r0_body.sizePayA170 PRE_first_tail_x4_L8_r0_body.sizeTaA170 PRE_first_tail_x4_L8_r0_body.sizeDecA170 PRE_first_tail_x4_L8_r0_body.sizePreA170 PRE_first_tail_x4_L8_r0_body.bodyPatchB170 (fun _ hm => bodyO655 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr655).trans bodyInactive0) (bodyBr656.trans bodyBr655.symm) bodyCnt655 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) bodyAcc656 PRE_first_tail_x4_L8_r0_body.bodyRunSeg170 bodyAcc657 bodyHalt657 PRE_first_tail_x4_L8_r0_body.bodyStepA171 bodyTop658 (fun _ hm => bodyO656 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr656).trans bodyInactive0) (bodyBr658.trans bodyBr656.symm) bodyCnt656 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA171 PRE_first_tail_x4_L8_r0_body.sizeArgsA171 PRE_first_tail_x4_L8_r0_body.sizeSymA171 PRE_first_tail_x4_L8_r0_body.sizeMlxA171 PRE_first_tail_x4_L8_r0_body.sizePayA171 PRE_first_tail_x4_L8_r0_body.sizeTaA171 PRE_first_tail_x4_L8_r0_body.sizeDecA171 PRE_first_tail_x4_L8_r0_body.sizePreA171 PRE_first_tail_x4_L8_r0_body.bodyPatchB171 (fun _ hm => bodyO658 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr658).trans bodyInactive0) (bodyBr659.trans bodyBr658.symm) bodyCnt658 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31842, 585, 0, 0⟩) bodyAcc659 PRE_first_tail_x4_L8_r0_body.bodyRunSeg171 bodyAcc660 bodyHalt660 PRE_first_tail_x4_L8_r0_body.bodyStepA172 bodyTop661 (fun _ hm => bodyO659 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr659).trans bodyInactive0) (bodyBr661.trans bodyBr659.symm) bodyCnt659 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift29 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S661.tab.length PRE_first_tail_x4_L8_r0_body.s661.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P29.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P29 15 PRE_first_tail_x4_L8_r0_body.kappa29 PRE_first_tail_x4_L8_r0_body.s663.ffi PRE_first_tail_x4_L8_r0_body.s662.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_29
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_29
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s663.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S661.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_29] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK29 PRE_first_tail_x4_L8_r0_body.cobjsK29
      PRE_first_tail_x4_L8_r0_body.citemsK29 PRE_first_tail_x4_L8_r0_body.cbd29 PRE_first_tail_x4_L8_r0_body.csst29
  exact PRE_first_tail_x4_L8_r0_body.cshift29 bodyNcl29 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_29] at this; exact this)


kernel_rfl bodyFramesEmpty29 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s662 a).isEmpty) = true
kernel_rfl bodyJsRoots29 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s661.next) PRE_first_tail_x4_L8_r0_body.s663.trace PRE_first_tail_x4_L8_r0_body.s663 = true
kernel_rfl bodyJsNative29 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s663.ffi) = true
kernel_rfl bodyLow29 : (PRE_first_tail_x4_L8_r0_body.cws29 ++ PRE_first_tail_x4_L8_r0_body.ws29).all (Nat.ble 9) = true
kernel_rfl bodyCntM29 : countersOkB PRE_first_tail_x4_L8_r0_body.s661 PRE_first_tail_x4_L8_r0_body.s662 = true
kernel_rfl bodyHi29 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s663.ffi).next setupP.E = true
kernel_rfl bodyNhi29 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s663.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge29 : bridgeOf PRE_first_tail_x4_L8_r0_body.s662.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s661.ffi
kernel_rfl bodyNN29 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s661.ffi).nnext PRE_first_tail_x4_L8_r0_body.P29.NL = true
kernel_rfl bodyXn29 : Nat.ble (⟨20019, 17118, 2747715, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s663.ffi).next = true
kernel_rfl bodyLo29 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s663.ffi).next = true
theorem bodyFacts29 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s661 PRE_first_tail_x4_L8_r0_body.s662 PRE_first_tail_x4_L8_r0_body.s663 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S661 PRE_first_tail_x4_L8_r0_body.S662 PRE_first_tail_x4_L8_r0_body.S663
    PRE_first_tail_x4_L8_r0_body.ws29 PRE_first_tail_x4_L8_r0_body.cws29 PRE_first_tail_x4_L8_r0_body.nr29 PRE_first_tail_x4_L8_r0_body.pl29 PRE_first_tail_x4_L8_r0_body.cl29 2748864 15 PRE_first_tail_x4_L8_r0_body.kd29 PRE_first_tail_x4_L8_r0_body.kappa29 PRE_first_tail_x4_L8_r0_body.P29
    ⟨20016, 17091, 2747709, 15⟩ ⟨20019, 17118, 2747715, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap29
  clean := bodyClean29
  cfix := PRE_first_tail_x4_L8_r0_body.cfix29
  zpl := PRE_first_tail_x4_L8_r0_body.zpl29
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd29
  zn1 := PRE_first_tail_x4_L8_r0_body.zn129
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst29
  zscn := PRE_first_tail_x4_L8_r0_body.zscn29
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn29
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow29
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab29
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh29
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd29
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi29
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt29
  zgP := PRE_first_tail_x4_L8_r0_body.zg29_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk29_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm29_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg29_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk29_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm29_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw29_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw29_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap29
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd29
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap29 PRE_first_tail_x4_L8_r0_body.stFoot29 PRE_first_tail_x4_L8_r0_body.iso29 PRE_first_tail_x4_L8_r0_body.zwr29
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP29
  csupp := PRE_first_tail_x4_L8_r0_body.csupp29
  cbound := PRE_first_tail_x4_L8_r0_body.cbound29
  zimg := PRE_first_tail_x4_L8_r0_body.zimg29
  zctl := PRE_first_tail_x4_L8_r0_body.zctl29
  zstack := PRE_first_tail_x4_L8_r0_body.zstack29
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs29
  zstores := PRE_first_tail_x4_L8_r0_body.zstores29
  zroots := PRE_first_tail_x4_L8_r0_body.zroots29
  znC := PRE_first_tail_x4_L8_r0_body.znC29
  ctab := PRE_first_tail_x4_L8_r0_body.ctab29
  zbin := PRE_first_tail_x4_L8_r0_body.zbin29
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge29
  sbridge := bodyBridge29
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj29
  cshiftR := fun h hNL => bodyCshift29 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN29
  raised := PRE_first_tail_x4_L8_r0_body.raised29
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs29
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl29
  xnLe := Nat.le_of_ble_eq_true bodyXn29
  loLe := Nat.le_of_ble_eq_true bodyLo29
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB29
  cntM := bodyCntM29
  hiLe := Nat.le_of_ble_eq_true bodyHi29
  nhiLe := Nat.le_of_ble_eq_true bodyNhi29
  jsHeap := bodyJs29
  jsRoots := bodyJsRoots29
  jsNative := bodyJsNative29
  framesEmpty := bodyFramesEmpty29
  trailOld := by decide
  lowVars := bodyLow29

def bodyQs29 : List (Option Q) := []
noncomputable def bodyEs29 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr29.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st29.S5.tab r
kernel_rfl bodyResChk29 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs29 bodyQs29) = true
kernel_rfl bodyLq29 : bodyQs29.length = PRE_first_tail_x4_L8_r0_body.cws29.length
kernel_rfl bodyNrLo29 : PRE_first_tail_x4_L8_r0_body.nr29.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S661.tab.length) = true
kernel_rfl bodySub29 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site29.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost29 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws29 PRE_first_tail_x4_L8_r0_body.cws29 bodyQs29 = true
kernel_rfl bodyDrop29 : Nat.ble (31842 + (PRE_first_tail_x4_L8_r0_body.s662.next - PRE_first_tail_x4_L8_r0_body.s663.next)) 32991 = true
kernel_rfl bodyDropH29 : Nat.ble (585 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s662.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s663.ffi).next)) 610 = true
kernel_rfl bodyDropN29 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s662.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s663.ffi).nnext)) 0 = true
kernel_rfl bodyDv29 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws29
kernel_rfl bodyDe29 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr29.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st29.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl29 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold29 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws29).isNone && !PRE_first_tail_x4_L8_r0_body.ws29.contains v) = true
kernel_rfl bodyDfree29 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws29 ++ PRE_first_tail_x4_L8_r0_body.ws29).all fun w => e.noVar w) = true

theorem bodyStep29 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨31842, 585, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s661 PRE_first_tail_x4_L8_r0_body.S661)
      (bodyCut NB T tk π i x0 bodyΘ ⟨32991, 610, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s663 PRE_first_tail_x4_L8_r0_body.S663) (11334 + 1) :=
  bodySite bodyFacts29.cfix bodyFacts29.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st29.S5.tab) (Es := bodyEs29) (qs := bodyQs29)
    (ok := PRE_first_tail_x4_L8_r0_body.st29.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site29 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts29
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site29 r hr) hi (MapOk.sub hm (sub_of_all bodySub29)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk29 r hr) hi hm ho hq)
    bodyLq29 rfl bodyNrLo29 (postSub_sound bodyPost29)
    (Nat.le_of_ble_eq_true bodyDrop29) (by decide) (Nat.le_of_ble_eq_true bodyDropH29) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN29) (by decide)
    bodyDv29 bodyDe29 bodyDl29 bodyDold29 bodyDfree29 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site30 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site30 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site30) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st30.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site30
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st30.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st30.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s683 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s684 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S683 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws30 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st30.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st30.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso30
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_30
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st30.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot30
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup30
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound30
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace30
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged30
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws30.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st30.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S683.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_30]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen30.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh30
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl30 : Conv.NClean (⟨20073, 17154, 2749951, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s683.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl30 (PRE_first_tail_x4_L8_r0_body.cncl29 bodyNcl29)

theorem bodyClean30 : Conv.JClean (⟨20073, 17154, 2749951, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s683 :=
  PRE_first_tail_x4_L8_r0_body.gjcl30 (PRE_first_tail_x4_L8_r0_body.cjcl29 bodyClean29)

kernel_rfl bodyJsLe30 : Nat.ble PRE_first_tail_x4_L8_r0_body.s661.next PRE_first_tail_x4_L8_r0_body.s683.next = true
kernel_rfl bodyJsList30 : (PRE_first_tail_x4_L8_r0_body.gjh30 ++ PRE_first_tail_x4_L8_r0_body.cl30).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s683.next) PRE_first_tail_x4_L8_r0_body.s685) = true
theorem bodyJs30 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s683.next PRE_first_tail_x4_L8_r0_body.s685 :=
  JsHeapAbove.glueSite bodyJs29 (Nat.le_of_ble_eq_true bodyJsLe30) PRE_first_tail_x4_L8_r0_body.gjk30 PRE_first_tail_x4_L8_r0_body.gjbd30 PRE_first_tail_x4_L8_r0_body.cheap30 PRE_first_tail_x4_L8_r0_body.zclbd30 bodyJsList30

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO663 : PRE_first_tail_x4_L8_r0_body.S663.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S663.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr663 : bridgeOf PRE_first_tail_x4_L8_r0_body.s663.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc663 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s663 PRE_first_tail_x4_L8_r0_body.S663) = fun _ _ => true
kernel_rfl bodyAcc664 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s664 PRE_first_tail_x4_L8_r0_body.S664) = fun _ _ => true
kernel_rfl bodyBr665 : bridgeOf PRE_first_tail_x4_L8_r0_body.s665.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt664 : isHalt PRE_first_tail_x4_L8_r0_body.s664.ctl = false
kernel_rfl bodyTop665 : noRetBlock PRE_first_tail_x4_L8_r0_body.s665 = true
kernel_rfl bodyCnt663 : countersOkB PRE_first_tail_x4_L8_r0_body.s663 PRE_first_tail_x4_L8_r0_body.s665 = true
kernel_rfl bodyO665 : PRE_first_tail_x4_L8_r0_body.S665.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S665.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr666 : bridgeOf PRE_first_tail_x4_L8_r0_body.s666.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt665 : countersOkB PRE_first_tail_x4_L8_r0_body.s665 PRE_first_tail_x4_L8_r0_body.s666 = true
kernel_rfl bodyO666 : PRE_first_tail_x4_L8_r0_body.S666.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S666.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc666 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s666 PRE_first_tail_x4_L8_r0_body.S666) = fun _ _ => true
kernel_rfl bodyAcc670 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s670 PRE_first_tail_x4_L8_r0_body.S670) = fun _ _ => true
kernel_rfl bodyBr671 : bridgeOf PRE_first_tail_x4_L8_r0_body.s671.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt670 : isHalt PRE_first_tail_x4_L8_r0_body.s670.ctl = false
kernel_rfl bodyTop671 : noRetBlock PRE_first_tail_x4_L8_r0_body.s671 = true
kernel_rfl bodyCnt666 : countersOkB PRE_first_tail_x4_L8_r0_body.s666 PRE_first_tail_x4_L8_r0_body.s671 = true
kernel_rfl bodyO671 : PRE_first_tail_x4_L8_r0_body.S671.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S671.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr672 : bridgeOf PRE_first_tail_x4_L8_r0_body.s672.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt671 : countersOkB PRE_first_tail_x4_L8_r0_body.s671 PRE_first_tail_x4_L8_r0_body.s672 = true
kernel_rfl bodyO672 : PRE_first_tail_x4_L8_r0_body.S672.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S672.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc672 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s672 PRE_first_tail_x4_L8_r0_body.S672) = fun _ _ => true
kernel_rfl bodyAcc673 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s673 PRE_first_tail_x4_L8_r0_body.S673) = fun _ _ => true
kernel_rfl bodyBr674 : bridgeOf PRE_first_tail_x4_L8_r0_body.s674.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt673 : isHalt PRE_first_tail_x4_L8_r0_body.s673.ctl = false
kernel_rfl bodyTop674 : noRetBlock PRE_first_tail_x4_L8_r0_body.s674 = true
kernel_rfl bodyCnt672 : countersOkB PRE_first_tail_x4_L8_r0_body.s672 PRE_first_tail_x4_L8_r0_body.s674 = true
kernel_rfl bodyO674 : PRE_first_tail_x4_L8_r0_body.S674.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S674.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr675 : bridgeOf PRE_first_tail_x4_L8_r0_body.s675.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt674 : countersOkB PRE_first_tail_x4_L8_r0_body.s674 PRE_first_tail_x4_L8_r0_body.s675 = true
kernel_rfl bodyO675 : PRE_first_tail_x4_L8_r0_body.S675.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S675.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc675 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s675 PRE_first_tail_x4_L8_r0_body.S675) = fun _ _ => true
kernel_rfl bodyAcc676 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s676 PRE_first_tail_x4_L8_r0_body.S676) = fun _ _ => true
kernel_rfl bodyBr677 : bridgeOf PRE_first_tail_x4_L8_r0_body.s677.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt676 : isHalt PRE_first_tail_x4_L8_r0_body.s676.ctl = false
kernel_rfl bodyTop677 : noRetBlock PRE_first_tail_x4_L8_r0_body.s677 = true
kernel_rfl bodyCnt675 : countersOkB PRE_first_tail_x4_L8_r0_body.s675 PRE_first_tail_x4_L8_r0_body.s677 = true
kernel_rfl bodyO677 : PRE_first_tail_x4_L8_r0_body.S677.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S677.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr678 : bridgeOf PRE_first_tail_x4_L8_r0_body.s678.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt677 : countersOkB PRE_first_tail_x4_L8_r0_body.s677 PRE_first_tail_x4_L8_r0_body.s678 = true
kernel_rfl bodyO678 : PRE_first_tail_x4_L8_r0_body.S678.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S678.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc678 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s678 PRE_first_tail_x4_L8_r0_body.S678) = fun _ _ => true
kernel_rfl bodyAcc679 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s679 PRE_first_tail_x4_L8_r0_body.S679) = fun _ _ => true
kernel_rfl bodyBr680 : bridgeOf PRE_first_tail_x4_L8_r0_body.s680.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt679 : isHalt PRE_first_tail_x4_L8_r0_body.s679.ctl = false
kernel_rfl bodyTop680 : noRetBlock PRE_first_tail_x4_L8_r0_body.s680 = true
kernel_rfl bodyCnt678 : countersOkB PRE_first_tail_x4_L8_r0_body.s678 PRE_first_tail_x4_L8_r0_body.s680 = true
kernel_rfl bodyO680 : PRE_first_tail_x4_L8_r0_body.S680.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S680.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr681 : bridgeOf PRE_first_tail_x4_L8_r0_body.s681.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt680 : countersOkB PRE_first_tail_x4_L8_r0_body.s680 PRE_first_tail_x4_L8_r0_body.s681 = true
kernel_rfl bodyO681 : PRE_first_tail_x4_L8_r0_body.S681.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S681.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc681 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s681 PRE_first_tail_x4_L8_r0_body.S681) = fun _ _ => true
kernel_rfl bodyAcc682 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s682 PRE_first_tail_x4_L8_r0_body.S682) = fun _ _ => true
kernel_rfl bodyBr683 : bridgeOf PRE_first_tail_x4_L8_r0_body.s683.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt682 : isHalt PRE_first_tail_x4_L8_r0_body.s682.ctl = false
kernel_rfl bodyTop683 : noRetBlock PRE_first_tail_x4_L8_r0_body.s683 = true
kernel_rfl bodyCnt681 : countersOkB PRE_first_tail_x4_L8_r0_body.s681 PRE_first_tail_x4_L8_r0_body.s683 = true

theorem bodyGlue30 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨32991, 610, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s663 PRE_first_tail_x4_L8_r0_body.S663)
      (bodyCut NB T tk π i x0 bodyΘ ⟨32991, 610, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s683 PRE_first_tail_x4_L8_r0_body.S683) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) bodyAcc663 PRE_first_tail_x4_L8_r0_body.bodyRunSeg172 bodyAcc664 bodyHalt664 PRE_first_tail_x4_L8_r0_body.bodyStepA173 bodyTop665 (fun _ hm => bodyO663 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr663).trans bodyInactive0) (bodyBr665.trans bodyBr663.symm) bodyCnt663 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA173 PRE_first_tail_x4_L8_r0_body.sizeArgsA173 PRE_first_tail_x4_L8_r0_body.sizeSymA173 PRE_first_tail_x4_L8_r0_body.sizeMlxA173 PRE_first_tail_x4_L8_r0_body.sizePayA173 PRE_first_tail_x4_L8_r0_body.sizeTaA173 PRE_first_tail_x4_L8_r0_body.sizeDecA173 PRE_first_tail_x4_L8_r0_body.sizePreA173 PRE_first_tail_x4_L8_r0_body.bodyPatchB173 (fun _ hm => bodyO665 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr665).trans bodyInactive0) (bodyBr666.trans bodyBr665.symm) bodyCnt665 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) bodyAcc666 PRE_first_tail_x4_L8_r0_body.bodyRunSeg173 bodyAcc670 bodyHalt670 PRE_first_tail_x4_L8_r0_body.bodyStepA174 bodyTop671 (fun _ hm => bodyO666 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr666).trans bodyInactive0) (bodyBr671.trans bodyBr666.symm) bodyCnt666 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA174 PRE_first_tail_x4_L8_r0_body.sizeArgsA174 PRE_first_tail_x4_L8_r0_body.sizeSymA174 PRE_first_tail_x4_L8_r0_body.sizeMlxA174 PRE_first_tail_x4_L8_r0_body.sizePayA174 PRE_first_tail_x4_L8_r0_body.sizeTaA174 PRE_first_tail_x4_L8_r0_body.sizeDecA174 PRE_first_tail_x4_L8_r0_body.sizePreA174 PRE_first_tail_x4_L8_r0_body.bodyPatchB174 (fun _ hm => bodyO671 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr671).trans bodyInactive0) (bodyBr672.trans bodyBr671.symm) bodyCnt671 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) bodyAcc672 PRE_first_tail_x4_L8_r0_body.bodyRunSeg174 bodyAcc673 bodyHalt673 PRE_first_tail_x4_L8_r0_body.bodyStepA175 bodyTop674 (fun _ hm => bodyO672 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr672).trans bodyInactive0) (bodyBr674.trans bodyBr672.symm) bodyCnt672 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA175 PRE_first_tail_x4_L8_r0_body.sizeArgsA175 PRE_first_tail_x4_L8_r0_body.sizeSymA175 PRE_first_tail_x4_L8_r0_body.sizeMlxA175 PRE_first_tail_x4_L8_r0_body.sizePayA175 PRE_first_tail_x4_L8_r0_body.sizeTaA175 PRE_first_tail_x4_L8_r0_body.sizeDecA175 PRE_first_tail_x4_L8_r0_body.sizePreA175 PRE_first_tail_x4_L8_r0_body.bodyPatchB175 (fun _ hm => bodyO674 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr674).trans bodyInactive0) (bodyBr675.trans bodyBr674.symm) bodyCnt674 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) bodyAcc675 PRE_first_tail_x4_L8_r0_body.bodyRunSeg175 bodyAcc676 bodyHalt676 PRE_first_tail_x4_L8_r0_body.bodyStepA176 bodyTop677 (fun _ hm => bodyO675 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr675).trans bodyInactive0) (bodyBr677.trans bodyBr675.symm) bodyCnt675 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA176 PRE_first_tail_x4_L8_r0_body.sizeArgsA176 PRE_first_tail_x4_L8_r0_body.sizeSymA176 PRE_first_tail_x4_L8_r0_body.sizeMlxA176 PRE_first_tail_x4_L8_r0_body.sizePayA176 PRE_first_tail_x4_L8_r0_body.sizeTaA176 PRE_first_tail_x4_L8_r0_body.sizeDecA176 PRE_first_tail_x4_L8_r0_body.sizePreA176 PRE_first_tail_x4_L8_r0_body.bodyPatchB176 (fun _ hm => bodyO677 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr677).trans bodyInactive0) (bodyBr678.trans bodyBr677.symm) bodyCnt677 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) bodyAcc678 PRE_first_tail_x4_L8_r0_body.bodyRunSeg176 bodyAcc679 bodyHalt679 PRE_first_tail_x4_L8_r0_body.bodyStepA177 bodyTop680 (fun _ hm => bodyO678 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr678).trans bodyInactive0) (bodyBr680.trans bodyBr678.symm) bodyCnt678 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA177 PRE_first_tail_x4_L8_r0_body.sizeArgsA177 PRE_first_tail_x4_L8_r0_body.sizeSymA177 PRE_first_tail_x4_L8_r0_body.sizeMlxA177 PRE_first_tail_x4_L8_r0_body.sizePayA177 PRE_first_tail_x4_L8_r0_body.sizeTaA177 PRE_first_tail_x4_L8_r0_body.sizeDecA177 PRE_first_tail_x4_L8_r0_body.sizePreA177 PRE_first_tail_x4_L8_r0_body.bodyPatchB177 (fun _ hm => bodyO680 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr680).trans bodyInactive0) (bodyBr681.trans bodyBr680.symm) bodyCnt680 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32991, 610, 0, 0⟩) bodyAcc681 PRE_first_tail_x4_L8_r0_body.bodyRunSeg177 bodyAcc682 bodyHalt682 PRE_first_tail_x4_L8_r0_body.bodyStepA178 bodyTop683 (fun _ hm => bodyO681 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr681).trans bodyInactive0) (bodyBr683.trans bodyBr681.symm) bodyCnt681 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift30 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S683.tab.length PRE_first_tail_x4_L8_r0_body.s683.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P30.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P30 15 PRE_first_tail_x4_L8_r0_body.kappa30 PRE_first_tail_x4_L8_r0_body.s685.ffi PRE_first_tail_x4_L8_r0_body.s684.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_30
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_30
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s685.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S683.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_30] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK30 PRE_first_tail_x4_L8_r0_body.cobjsK30
      PRE_first_tail_x4_L8_r0_body.citemsK30 PRE_first_tail_x4_L8_r0_body.cbd30 PRE_first_tail_x4_L8_r0_body.csst30
  exact PRE_first_tail_x4_L8_r0_body.cshift30 bodyNcl30 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_30] at this; exact this)


kernel_rfl bodyFramesEmpty30 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s684 a).isEmpty) = true
kernel_rfl bodyJsRoots30 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s683.next) PRE_first_tail_x4_L8_r0_body.s685.trace PRE_first_tail_x4_L8_r0_body.s685 = true
kernel_rfl bodyJsNative30 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s685.ffi) = true
kernel_rfl bodyLow30 : (PRE_first_tail_x4_L8_r0_body.cws30 ++ PRE_first_tail_x4_L8_r0_body.ws30).all (Nat.ble 9) = true
kernel_rfl bodyCntM30 : countersOkB PRE_first_tail_x4_L8_r0_body.s683 PRE_first_tail_x4_L8_r0_body.s684 = true
kernel_rfl bodyHi30 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s685.ffi).next setupP.E = true
kernel_rfl bodyNhi30 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s685.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge30 : bridgeOf PRE_first_tail_x4_L8_r0_body.s684.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s683.ffi
kernel_rfl bodyNN30 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s683.ffi).nnext PRE_first_tail_x4_L8_r0_body.P30.NL = true
kernel_rfl bodyXn30 : Nat.ble (⟨20076, 17181, 2749957, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s685.ffi).next = true
kernel_rfl bodyLo30 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s685.ffi).next = true
theorem bodyFacts30 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s683 PRE_first_tail_x4_L8_r0_body.s684 PRE_first_tail_x4_L8_r0_body.s685 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S683 PRE_first_tail_x4_L8_r0_body.S684 PRE_first_tail_x4_L8_r0_body.S685
    PRE_first_tail_x4_L8_r0_body.ws30 PRE_first_tail_x4_L8_r0_body.cws30 PRE_first_tail_x4_L8_r0_body.nr30 PRE_first_tail_x4_L8_r0_body.pl30 PRE_first_tail_x4_L8_r0_body.cl30 2751106 15 PRE_first_tail_x4_L8_r0_body.kd30 PRE_first_tail_x4_L8_r0_body.kappa30 PRE_first_tail_x4_L8_r0_body.P30
    ⟨20073, 17154, 2749951, 15⟩ ⟨20076, 17181, 2749957, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap30
  clean := bodyClean30
  cfix := PRE_first_tail_x4_L8_r0_body.cfix30
  zpl := PRE_first_tail_x4_L8_r0_body.zpl30
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd30
  zn1 := PRE_first_tail_x4_L8_r0_body.zn130
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst30
  zscn := PRE_first_tail_x4_L8_r0_body.zscn30
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn30
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow30
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab30
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh30
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd30
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi30
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt30
  zgP := PRE_first_tail_x4_L8_r0_body.zg30_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk30_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm30_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg30_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk30_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm30_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw30_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw30_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap30
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd30
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap30 PRE_first_tail_x4_L8_r0_body.stFoot30 PRE_first_tail_x4_L8_r0_body.iso30 PRE_first_tail_x4_L8_r0_body.zwr30
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP30
  csupp := PRE_first_tail_x4_L8_r0_body.csupp30
  cbound := PRE_first_tail_x4_L8_r0_body.cbound30
  zimg := PRE_first_tail_x4_L8_r0_body.zimg30
  zctl := PRE_first_tail_x4_L8_r0_body.zctl30
  zstack := PRE_first_tail_x4_L8_r0_body.zstack30
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs30
  zstores := PRE_first_tail_x4_L8_r0_body.zstores30
  zroots := PRE_first_tail_x4_L8_r0_body.zroots30
  znC := PRE_first_tail_x4_L8_r0_body.znC30
  ctab := PRE_first_tail_x4_L8_r0_body.ctab30
  zbin := PRE_first_tail_x4_L8_r0_body.zbin30
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge30
  sbridge := bodyBridge30
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj30
  cshiftR := fun h hNL => bodyCshift30 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN30
  raised := PRE_first_tail_x4_L8_r0_body.raised30
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs30
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl30
  xnLe := Nat.le_of_ble_eq_true bodyXn30
  loLe := Nat.le_of_ble_eq_true bodyLo30
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB30
  cntM := bodyCntM30
  hiLe := Nat.le_of_ble_eq_true bodyHi30
  nhiLe := Nat.le_of_ble_eq_true bodyNhi30
  jsHeap := bodyJs30
  jsRoots := bodyJsRoots30
  jsNative := bodyJsNative30
  framesEmpty := bodyFramesEmpty30
  trailOld := by decide
  lowVars := bodyLow30

def bodyQs30 : List (Option Q) := []
noncomputable def bodyEs30 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr30.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st30.S5.tab r
kernel_rfl bodyResChk30 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs30 bodyQs30) = true
kernel_rfl bodyLq30 : bodyQs30.length = PRE_first_tail_x4_L8_r0_body.cws30.length
kernel_rfl bodyNrLo30 : PRE_first_tail_x4_L8_r0_body.nr30.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S683.tab.length) = true
kernel_rfl bodySub30 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site30.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost30 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws30 PRE_first_tail_x4_L8_r0_body.cws30 bodyQs30 = true
kernel_rfl bodyDrop30 : Nat.ble (32991 + (PRE_first_tail_x4_L8_r0_body.s684.next - PRE_first_tail_x4_L8_r0_body.s685.next)) 34140 = true
kernel_rfl bodyDropH30 : Nat.ble (610 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s684.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s685.ffi).next)) 635 = true
kernel_rfl bodyDropN30 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s684.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s685.ffi).nnext)) 0 = true
kernel_rfl bodyDv30 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws30
kernel_rfl bodyDe30 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr30.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st30.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl30 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold30 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws30).isNone && !PRE_first_tail_x4_L8_r0_body.ws30.contains v) = true
kernel_rfl bodyDfree30 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws30 ++ PRE_first_tail_x4_L8_r0_body.ws30).all fun w => e.noVar w) = true

theorem bodyStep30 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨32991, 610, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s683 PRE_first_tail_x4_L8_r0_body.S683)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34140, 635, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s685 PRE_first_tail_x4_L8_r0_body.S685) (11334 + 1) :=
  bodySite bodyFacts30.cfix bodyFacts30.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L8_r0_body.st30.S5.tab) (Es := bodyEs30) (qs := bodyQs30)
    (ok := PRE_first_tail_x4_L8_r0_body.st30.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site30 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts30
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site30 r hr) hi (MapOk.sub hm (sub_of_all bodySub30)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk30 r hr) hi hm ho hq)
    bodyLq30 rfl bodyNrLo30 (postSub_sound bodyPost30)
    (Nat.le_of_ble_eq_true bodyDrop30) (by decide) (Nat.le_of_ble_eq_true bodyDropH30) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN30) (by decide)
    bodyDv30 bodyDe30 bodyDl30 bodyDold30 bodyDfree30 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodySite31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L8_r0_body.map_site31 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L8_r0_body.chk_site31 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L8_r0_body.map_site31) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st31.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L8_r0_body.site31
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st31.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st31.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s704 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.s705 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S704 Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws31 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st31.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st31.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.iso31
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_31
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st31.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.stFoot31
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrNodup31
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.wrBound31
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.trace31
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.merged31
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.ws31.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.st31.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.S704.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.tab0_31]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.mergeLen31.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0_body.fresh31
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl31 : Conv.NClean (⟨20136, 17226, 2752454, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s704.ffi).mlx :=
  PRE_first_tail_x4_L8_r0_body.gncl31 (PRE_first_tail_x4_L8_r0_body.cncl30 bodyNcl30)

theorem bodyClean31 : Conv.JClean (⟨20136, 17226, 2752454, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L8_r0_body.s704 :=
  PRE_first_tail_x4_L8_r0_body.gjcl31 (PRE_first_tail_x4_L8_r0_body.cjcl30 bodyClean30)

kernel_rfl bodyJsLe31 : Nat.ble PRE_first_tail_x4_L8_r0_body.s683.next PRE_first_tail_x4_L8_r0_body.s704.next = true
kernel_rfl bodyJsList31 : (PRE_first_tail_x4_L8_r0_body.gjh31 ++ PRE_first_tail_x4_L8_r0_body.cl31).all (noBigAtP (jsAboveB PRE_first_tail_x4_L8_r0_body.s704.next) PRE_first_tail_x4_L8_r0_body.s706) = true
theorem bodyJs31 : JsHeapAbove PRE_first_tail_x4_L8_r0_body.s704.next PRE_first_tail_x4_L8_r0_body.s706 :=
  JsHeapAbove.glueSite bodyJs30 (Nat.le_of_ble_eq_true bodyJsLe31) PRE_first_tail_x4_L8_r0_body.gjk31 PRE_first_tail_x4_L8_r0_body.gjbd31 PRE_first_tail_x4_L8_r0_body.cheap31 PRE_first_tail_x4_L8_r0_body.zclbd31 bodyJsList31

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyG31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO685 : PRE_first_tail_x4_L8_r0_body.S685.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S685.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr685 : bridgeOf PRE_first_tail_x4_L8_r0_body.s685.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyAcc685 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s685 PRE_first_tail_x4_L8_r0_body.S685) = fun _ _ => true
kernel_rfl bodyAcc686 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s686 PRE_first_tail_x4_L8_r0_body.S686) = fun _ _ => true
kernel_rfl bodyBr687 : bridgeOf PRE_first_tail_x4_L8_r0_body.s687.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt686 : isHalt PRE_first_tail_x4_L8_r0_body.s686.ctl = false
kernel_rfl bodyTop687 : noRetBlock PRE_first_tail_x4_L8_r0_body.s687 = true
kernel_rfl bodyCnt685 : countersOkB PRE_first_tail_x4_L8_r0_body.s685 PRE_first_tail_x4_L8_r0_body.s687 = true
kernel_rfl bodyO687 : PRE_first_tail_x4_L8_r0_body.S687.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S687.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr688 : bridgeOf PRE_first_tail_x4_L8_r0_body.s688.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt687 : countersOkB PRE_first_tail_x4_L8_r0_body.s687 PRE_first_tail_x4_L8_r0_body.s688 = true
kernel_rfl bodyO688 : PRE_first_tail_x4_L8_r0_body.S688.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S688.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc688 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s688 PRE_first_tail_x4_L8_r0_body.S688) = fun _ _ => true
kernel_rfl bodyAcc692 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s692 PRE_first_tail_x4_L8_r0_body.S692) = fun _ _ => true
kernel_rfl bodyBr693 : bridgeOf PRE_first_tail_x4_L8_r0_body.s693.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt692 : isHalt PRE_first_tail_x4_L8_r0_body.s692.ctl = false
kernel_rfl bodyTop693 : noRetBlock PRE_first_tail_x4_L8_r0_body.s693 = true
kernel_rfl bodyCnt688 : countersOkB PRE_first_tail_x4_L8_r0_body.s688 PRE_first_tail_x4_L8_r0_body.s693 = true
kernel_rfl bodyO693 : PRE_first_tail_x4_L8_r0_body.S693.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S693.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr694 : bridgeOf PRE_first_tail_x4_L8_r0_body.s694.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt693 : countersOkB PRE_first_tail_x4_L8_r0_body.s693 PRE_first_tail_x4_L8_r0_body.s694 = true
kernel_rfl bodyO694 : PRE_first_tail_x4_L8_r0_body.S694.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S694.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc694 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s694 PRE_first_tail_x4_L8_r0_body.S694) = fun _ _ => true
kernel_rfl bodyAcc696 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s696 PRE_first_tail_x4_L8_r0_body.S696) = fun _ _ => true
kernel_rfl bodyBr697 : bridgeOf PRE_first_tail_x4_L8_r0_body.s697.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt696 : isHalt PRE_first_tail_x4_L8_r0_body.s696.ctl = false
kernel_rfl bodyTop697 : noRetBlock PRE_first_tail_x4_L8_r0_body.s697 = true
kernel_rfl bodyCnt694 : countersOkB PRE_first_tail_x4_L8_r0_body.s694 PRE_first_tail_x4_L8_r0_body.s697 = true
kernel_rfl bodyO697 : PRE_first_tail_x4_L8_r0_body.S697.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S697.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr698 : bridgeOf PRE_first_tail_x4_L8_r0_body.s698.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt697 : countersOkB PRE_first_tail_x4_L8_r0_body.s697 PRE_first_tail_x4_L8_r0_body.s698 = true
kernel_rfl bodyO698 : PRE_first_tail_x4_L8_r0_body.S698.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S698.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc698 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s698 PRE_first_tail_x4_L8_r0_body.S698) = fun _ _ => true
kernel_rfl bodyAcc699 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s699 PRE_first_tail_x4_L8_r0_body.S699) = fun _ _ => true
kernel_rfl bodyBr700 : bridgeOf PRE_first_tail_x4_L8_r0_body.s700.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt699 : isHalt PRE_first_tail_x4_L8_r0_body.s699.ctl = false
kernel_rfl bodyTop700 : noRetBlock PRE_first_tail_x4_L8_r0_body.s700 = true
kernel_rfl bodyCnt698 : countersOkB PRE_first_tail_x4_L8_r0_body.s698 PRE_first_tail_x4_L8_r0_body.s700 = true
kernel_rfl bodyO700 : PRE_first_tail_x4_L8_r0_body.S700.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S700.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyBr701 : bridgeOf PRE_first_tail_x4_L8_r0_body.s701.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyCnt700 : countersOkB PRE_first_tail_x4_L8_r0_body.s700 PRE_first_tail_x4_L8_r0_body.s701 = true
kernel_rfl bodyO701 : PRE_first_tail_x4_L8_r0_body.S701.oracle = List.drop (PRE_first_tail_x4_L8_r0_body.O.length - PRE_first_tail_x4_L8_r0_body.S701.oracle.length) PRE_first_tail_x4_L8_r0_body.O
kernel_rfl bodyAcc701 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s701 PRE_first_tail_x4_L8_r0_body.S701) = fun _ _ => true
kernel_rfl bodyAcc703 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_body.s703 PRE_first_tail_x4_L8_r0_body.S703) = fun _ _ => true
kernel_rfl bodyBr704 : bridgeOf PRE_first_tail_x4_L8_r0_body.s704.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s0.ffi
kernel_rfl bodyHalt703 : isHalt PRE_first_tail_x4_L8_r0_body.s703.ctl = false
kernel_rfl bodyTop704 : noRetBlock PRE_first_tail_x4_L8_r0_body.s704 = true
kernel_rfl bodyCnt701 : countersOkB PRE_first_tail_x4_L8_r0_body.s701 PRE_first_tail_x4_L8_r0_body.s704 = true

theorem bodyGlue31 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34140, 635, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s685 PRE_first_tail_x4_L8_r0_body.S685)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34140, 635, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s704 PRE_first_tail_x4_L8_r0_body.S704) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) bodyAcc685 PRE_first_tail_x4_L8_r0_body.bodyRunSeg178 bodyAcc686 bodyHalt686 PRE_first_tail_x4_L8_r0_body.bodyStepA179 bodyTop687 (fun _ hm => bodyO685 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr685).trans bodyInactive0) (bodyBr687.trans bodyBr685.symm) bodyCnt685 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA179 PRE_first_tail_x4_L8_r0_body.sizeArgsA179 PRE_first_tail_x4_L8_r0_body.sizeSymA179 PRE_first_tail_x4_L8_r0_body.sizeMlxA179 PRE_first_tail_x4_L8_r0_body.sizePayA179 PRE_first_tail_x4_L8_r0_body.sizeTaA179 PRE_first_tail_x4_L8_r0_body.sizeDecA179 PRE_first_tail_x4_L8_r0_body.sizePreA179 PRE_first_tail_x4_L8_r0_body.bodyPatchB179 (fun _ hm => bodyO687 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr687).trans bodyInactive0) (bodyBr688.trans bodyBr687.symm) bodyCnt687 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) bodyAcc688 PRE_first_tail_x4_L8_r0_body.bodyRunSeg179 bodyAcc692 bodyHalt692 PRE_first_tail_x4_L8_r0_body.bodyStepA180 bodyTop693 (fun _ hm => bodyO688 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr688).trans bodyInactive0) (bodyBr693.trans bodyBr688.symm) bodyCnt688 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA180 PRE_first_tail_x4_L8_r0_body.sizeArgsA180 PRE_first_tail_x4_L8_r0_body.sizeSymA180 PRE_first_tail_x4_L8_r0_body.sizeMlxA180 PRE_first_tail_x4_L8_r0_body.sizePayA180 PRE_first_tail_x4_L8_r0_body.sizeTaA180 PRE_first_tail_x4_L8_r0_body.sizeDecA180 PRE_first_tail_x4_L8_r0_body.sizePreA180 PRE_first_tail_x4_L8_r0_body.bodyPatchB180 (fun _ hm => bodyO693 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr693).trans bodyInactive0) (bodyBr694.trans bodyBr693.symm) bodyCnt693 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) bodyAcc694 PRE_first_tail_x4_L8_r0_body.bodyRunSeg180 bodyAcc696 bodyHalt696 PRE_first_tail_x4_L8_r0_body.bodyStepA181 bodyTop697 (fun _ hm => bodyO694 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr694).trans bodyInactive0) (bodyBr697.trans bodyBr694.symm) bodyCnt694 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA181 PRE_first_tail_x4_L8_r0_body.sizeArgsA181 PRE_first_tail_x4_L8_r0_body.sizeSymA181 PRE_first_tail_x4_L8_r0_body.sizeMlxA181 PRE_first_tail_x4_L8_r0_body.sizePayA181 PRE_first_tail_x4_L8_r0_body.sizeTaA181 PRE_first_tail_x4_L8_r0_body.sizeDecA181 PRE_first_tail_x4_L8_r0_body.sizePreA181 PRE_first_tail_x4_L8_r0_body.bodyPatchB181 (fun _ hm => bodyO697 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr697).trans bodyInactive0) (bodyBr698.trans bodyBr697.symm) bodyCnt697 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) bodyAcc698 PRE_first_tail_x4_L8_r0_body.bodyRunSeg181 bodyAcc699 bodyHalt699 PRE_first_tail_x4_L8_r0_body.bodyStepA182 bodyTop700 (fun _ hm => bodyO698 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr698).trans bodyInactive0) (bodyBr700.trans bodyBr698.symm) bodyCnt698 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) PRE_first_tail_x4_L8_r0_body.sizeA182 PRE_first_tail_x4_L8_r0_body.sizeArgsA182 PRE_first_tail_x4_L8_r0_body.sizeSymA182 PRE_first_tail_x4_L8_r0_body.sizeMlxA182 PRE_first_tail_x4_L8_r0_body.sizePayA182 PRE_first_tail_x4_L8_r0_body.sizeTaA182 PRE_first_tail_x4_L8_r0_body.sizeDecA182 PRE_first_tail_x4_L8_r0_body.sizePreA182 PRE_first_tail_x4_L8_r0_body.bodyPatchB182 (fun _ hm => bodyO700 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr700).trans bodyInactive0) (bodyBr701.trans bodyBr700.symm) bodyCnt700 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34140, 635, 0, 0⟩) bodyAcc701 PRE_first_tail_x4_L8_r0_body.bodyRunSeg182 bodyAcc703 bodyHalt703 PRE_first_tail_x4_L8_r0_body.bodyStepA183 bodyTop704 (fun _ hm => bodyO701 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr701).trans bodyInactive0) (bodyBr704.trans bodyBr701.symm) bodyCnt701 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end

section -- VWBodyS31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift31 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L8_r0_body.S704.tab.length PRE_first_tail_x4_L8_r0_body.s704.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L8_r0_body.P31.NL) : Conv.FullShiftQ PRE_first_tail_x4_L8_r0_body.P31 15 PRE_first_tail_x4_L8_r0_body.kappa31 PRE_first_tail_x4_L8_r0_body.s706.ffi PRE_first_tail_x4_L8_r0_body.s705.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L8_r0_body.ofxC_31
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L8_r0_body.okrC_31
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_body.s706.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L8_r0_body.S704.tab.length) hr.cl (by rw [PRE_first_tail_x4_L8_r0_body.n0_31] <;> decide) PRE_first_tail_x4_L8_r0_body.cnodesK31 PRE_first_tail_x4_L8_r0_body.cobjsK31
      PRE_first_tail_x4_L8_r0_body.citemsK31 PRE_first_tail_x4_L8_r0_body.cbd31 PRE_first_tail_x4_L8_r0_body.csst31
  exact PRE_first_tail_x4_L8_r0_body.cshift31 bodyNcl31 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L8_r0_body.n0_31] at this; exact this)


kernel_rfl bodyFramesEmpty31 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L8_r0_body.s705 a).isEmpty) = true
kernel_rfl bodyJsRoots31 : noBigRootsP (jsAboveB PRE_first_tail_x4_L8_r0_body.s704.next) PRE_first_tail_x4_L8_r0_body.s706.trace PRE_first_tail_x4_L8_r0_body.s706 = true
kernel_rfl bodyJsNative31 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L8_r0_body.s706.ffi) = true
kernel_rfl bodyLow31 : (PRE_first_tail_x4_L8_r0_body.cws31 ++ PRE_first_tail_x4_L8_r0_body.ws31).all (Nat.ble 9) = true
kernel_rfl bodyCntM31 : countersOkB PRE_first_tail_x4_L8_r0_body.s704 PRE_first_tail_x4_L8_r0_body.s705 = true
kernel_rfl bodyHi31 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s706.ffi).next setupP.E = true
kernel_rfl bodyNhi31 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s706.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge31 : bridgeOf PRE_first_tail_x4_L8_r0_body.s705.ffi = bridgeOf PRE_first_tail_x4_L8_r0_body.s704.ffi
kernel_rfl bodyNN31 : Nat.ble (mlxOf PRE_first_tail_x4_L8_r0_body.s704.ffi).nnext PRE_first_tail_x4_L8_r0_body.P31.NL = true
kernel_rfl bodyXn31 : Nat.ble (⟨20140, 17232, 2752469, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L8_r0_body.s706.ffi).next = true
kernel_rfl bodyLo31 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L8_r0_body.s706.ffi).next = true
theorem bodyFacts31 : BodySiteFacts PRE_first_tail_x4_L8_r0_body.s704 PRE_first_tail_x4_L8_r0_body.s705 PRE_first_tail_x4_L8_r0_body.s706 PRE_first_tail_x4_L8_r0_body.s0 PRE_first_tail_x4_L8_r0_body.S704 PRE_first_tail_x4_L8_r0_body.S705 PRE_first_tail_x4_L8_r0_body.S706
    PRE_first_tail_x4_L8_r0_body.ws31 PRE_first_tail_x4_L8_r0_body.cws31 PRE_first_tail_x4_L8_r0_body.nr31 PRE_first_tail_x4_L8_r0_body.pl31 PRE_first_tail_x4_L8_r0_body.cl31 2752819 15 PRE_first_tail_x4_L8_r0_body.kd31 PRE_first_tail_x4_L8_r0_body.kappa31 PRE_first_tail_x4_L8_r0_body.P31
    ⟨20136, 17226, 2752454, 15⟩ ⟨20140, 17232, 2752469, 15⟩ where
  zkap := PRE_first_tail_x4_L8_r0_body.zkap31
  clean := bodyClean31
  cfix := PRE_first_tail_x4_L8_r0_body.cfix31
  zpl := PRE_first_tail_x4_L8_r0_body.zpl31
  zplnd := PRE_first_tail_x4_L8_r0_body.zplnd31
  zn1 := PRE_first_tail_x4_L8_r0_body.zn131
  zfirst := PRE_first_tail_x4_L8_r0_body.zfirst31
  zscn := PRE_first_tail_x4_L8_r0_body.zscn31
  zsmn := PRE_first_tail_x4_L8_r0_body.zsmn31
  zgrow := PRE_first_tail_x4_L8_r0_body.zgrow31
  mergeTab := PRE_first_tail_x4_L8_r0_body.mergeTab31
  zfresh := PRE_first_tail_x4_L8_r0_body.zfresh31
  zcnd := PRE_first_tail_x4_L8_r0_body.zcnd31
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L8_r0_body.znrHi31
  zfrlt := PRE_first_tail_x4_L8_r0_body.zfrlt31
  zgP := PRE_first_tail_x4_L8_r0_body.zg31_2665
  zkP := PRE_first_tail_x4_L8_r0_body.zk31_2665
  zmP := PRE_first_tail_x4_L8_r0_body.zm31_2665
  zgC := PRE_first_tail_x4_L8_r0_body.zg31_2673467
  zkC := PRE_first_tail_x4_L8_r0_body.zk31_2673467
  zmC := PRE_first_tail_x4_L8_r0_body.zm31_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L8_r0_body.zw31_2673472
  zwV := PRE_first_tail_x4_L8_r0_body.zw31_2673473
  cheap := PRE_first_tail_x4_L8_r0_body.cheap31
  zclbd := PRE_first_tail_x4_L8_r0_body.zclbd31
  hml := hoff_of PRE_first_tail_x4_L8_r0_body.mheap31 PRE_first_tail_x4_L8_r0_body.stFoot31 PRE_first_tail_x4_L8_r0_body.iso31 PRE_first_tail_x4_L8_r0_body.zwr31
  ckeepP := PRE_first_tail_x4_L8_r0_body.ckeepP31
  csupp := PRE_first_tail_x4_L8_r0_body.csupp31
  cbound := PRE_first_tail_x4_L8_r0_body.cbound31
  zimg := PRE_first_tail_x4_L8_r0_body.zimg31
  zctl := PRE_first_tail_x4_L8_r0_body.zctl31
  zstack := PRE_first_tail_x4_L8_r0_body.zstack31
  zjobs := PRE_first_tail_x4_L8_r0_body.zjobs31
  zstores := PRE_first_tail_x4_L8_r0_body.zstores31
  zroots := PRE_first_tail_x4_L8_r0_body.zroots31
  znC := PRE_first_tail_x4_L8_r0_body.znC31
  ctab := PRE_first_tail_x4_L8_r0_body.ctab31
  zbin := PRE_first_tail_x4_L8_r0_body.zbin31
  cbridge := PRE_first_tail_x4_L8_r0_body.cbridge31
  sbridge := bodyBridge31
  cwsDisj := PRE_first_tail_x4_L8_r0_body.cwsDisj31
  cshiftR := fun h hNL => bodyCshift31 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN31
  raised := PRE_first_tail_x4_L8_r0_body.raised31
  cbigs := PRE_first_tail_x4_L8_r0_body.cbigs31
  cjcl := PRE_first_tail_x4_L8_r0_body.cjcl31
  xnLe := Nat.le_of_ble_eq_true bodyXn31
  loLe := Nat.le_of_ble_eq_true bodyLo31
  zroots2 := PRE_first_tail_x4_L8_r0_body.zrootsB31
  cntM := bodyCntM31
  hiLe := Nat.le_of_ble_eq_true bodyHi31
  nhiLe := Nat.le_of_ble_eq_true bodyNhi31
  jsHeap := bodyJs31
  jsRoots := bodyJsRoots31
  jsNative := bodyJsNative31
  framesEmpty := bodyFramesEmpty31
  trailOld := by decide
  lowVars := bodyLow31

def bodyQs31 : List (Option Q) := []
noncomputable def bodyEs31 : List (Option SymE) := PRE_first_tail_x4_L8_r0_body.nr31.map fun r => nth? PRE_first_tail_x4_L8_r0_body.st31.S3.tab r
kernel_rfl bodyResChk31 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs31 bodyQs31) = true
kernel_rfl bodyLq31 : bodyQs31.length = PRE_first_tail_x4_L8_r0_body.cws31.length
kernel_rfl bodyNrLo31 : PRE_first_tail_x4_L8_r0_body.nr31.all (Nat.ble PRE_first_tail_x4_L8_r0_body.S704.tab.length) = true
kernel_rfl bodySub31 : (Oracles.PRE_first_tail_x4_L8_r0_body.map_site31.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost31 : postSubB bodyM PRE_first_tail_x4_L8_r0_body.ws31 PRE_first_tail_x4_L8_r0_body.cws31 bodyQs31 = true
kernel_rfl bodyDrop31 : Nat.ble (34140 + (PRE_first_tail_x4_L8_r0_body.s705.next - PRE_first_tail_x4_L8_r0_body.s706.next)) 34490 = true
kernel_rfl bodyDropH31 : Nat.ble (635 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s705.ffi).next - (mlxOf PRE_first_tail_x4_L8_r0_body.s706.ffi).next)) 637 = true
kernel_rfl bodyDropN31 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L8_r0_body.s705.ffi).nnext - (mlxOf PRE_first_tail_x4_L8_r0_body.s706.ffi).nnext)) 0 = true
kernel_rfl bodyDv31 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L8_r0_body.cws31
kernel_rfl bodyDe31 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L8_r0_body.nr31.map (fun r =>
  ((nth? PRE_first_tail_x4_L8_r0_body.st31.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl31 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold31 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L8_r0_body.cws31).isNone && !PRE_first_tail_x4_L8_r0_body.ws31.contains v) = true
kernel_rfl bodyDfree31 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L8_r0_body.cws31 ++ PRE_first_tail_x4_L8_r0_body.ws31).all fun w => e.noVar w) = true

theorem bodyStep31 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34140, 635, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s704 PRE_first_tail_x4_L8_r0_body.S704)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34490, 637, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_body.s706 PRE_first_tail_x4_L8_r0_body.S706) (3452 + 1) :=
  bodySite bodyFacts31.cfix bodyFacts31.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L8_r0_body.st31.S3.tab) (Es := bodyEs31) (qs := bodyQs31)
    (ok := PRE_first_tail_x4_L8_r0_body.st31.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L8_r0_body.site31 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts31
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L8_r0_body.chk_site31 r hr) hi (MapOk.sub hm (sub_of_all bodySub31)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk31 r hr) hi hm ho hq)
    bodyLq31 rfl bodyNrLo31 (postSub_sound bodyPost31)
    (Nat.le_of_ble_eq_true bodyDrop31) (by decide) (Nat.le_of_ble_eq_true bodyDropH31) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN31) (by decide)
    bodyDv31 bodyDe31 bodyDl31 bodyDold31 bodyDfree31 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L8

end
