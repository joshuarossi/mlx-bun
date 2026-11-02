import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L7_r0_body.States
import host.sim.template.a4pre_first_tail_x4_L7_r0_body.m.B20
import host.sim.compose.a4b.x4_L7.B4
import host.sim.template.a4pre_first_tail_x4_L7_r0_body.m.B24
import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L7.VWBodyChain
import host.sim.compose.a4b.x4_L7.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L7_r0_body.m.B14
import host.sim.template.a4pre_first_tail_x4_L7_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x4_L7_r0_body.m.B13
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x4_L7_r0_body.m.B21

section -- VWBodyOracles_10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_g40 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_g40 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_g40) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.O))) = true

def PRE_first_tail_x4_L7_r0_body.map_site40 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site40 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site40) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st40.S0.oracle) = true

def PRE_first_tail_x4_L7_r0_body.map_g41 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_g41 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_g41) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.O))) = true

def PRE_first_tail_x4_L7_r0_body.map_site41 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site41 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site41) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st41.S0.oracle) = true

def PRE_first_tail_x4_L7_r0_body.map_g42 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_g42 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_g42) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.O))) = true

def PRE_first_tail_x4_L7_r0_body.map_site42 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site42 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site42) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st42.S0.oracle) = true

def PRE_first_tail_x4_L7_r0_body.map_g43 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_g43 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_g43) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.O))) = true

def PRE_first_tail_x4_L7_r0_body.map_site43 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site43 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site43) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st43.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_site40 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site40 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site40) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st40.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L7_r0_body.site40
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st40.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st40.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s906 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s907 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S906 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws40 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st40.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st40.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.iso40
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_40
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st40.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.stFoot40
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrNodup40
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrBound40
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.trace40
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.merged40
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws40.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st40.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S906.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_40]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.mergeLen40.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.fresh40
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl40 : Conv.NClean (⟨20706, 17778, 2775291, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s906.ffi).mlx :=
  PRE_first_tail_x4_L7_r0_body.gncl40 (PRE_first_tail_x4_L7_r0_body.cncl39 bodyNcl39)

theorem bodyClean40 : Conv.JClean (⟨20706, 17778, 2775291, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L7_r0_body.s906 :=
  PRE_first_tail_x4_L7_r0_body.gjcl40 (PRE_first_tail_x4_L7_r0_body.cjcl39 bodyClean39)

kernel_rfl bodyJsLe40 : Nat.ble PRE_first_tail_x4_L7_r0_body.s882.next PRE_first_tail_x4_L7_r0_body.s906.next = true
kernel_rfl bodyJsList40 : (PRE_first_tail_x4_L7_r0_body.gjh40 ++ PRE_first_tail_x4_L7_r0_body.cl40).all (noBigAtP (jsAboveB PRE_first_tail_x4_L7_r0_body.s906.next) PRE_first_tail_x4_L7_r0_body.s908) = true
theorem bodyJs40 : JsHeapAbove PRE_first_tail_x4_L7_r0_body.s906.next PRE_first_tail_x4_L7_r0_body.s908 :=
  JsHeapAbove.glueSite bodyJs39 (Nat.le_of_ble_eq_true bodyJsLe40) PRE_first_tail_x4_L7_r0_body.gjk40 PRE_first_tail_x4_L7_r0_body.gjbd40 PRE_first_tail_x4_L7_r0_body.cheap40 PRE_first_tail_x4_L7_r0_body.zclbd40 bodyJsList40

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyG40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO884 : PRE_first_tail_x4_L7_r0_body.S884.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S884.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr884 : bridgeOf PRE_first_tail_x4_L7_r0_body.s884.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyAcc884 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s884 PRE_first_tail_x4_L7_r0_body.S884) = fun _ _ => true
kernel_rfl bodyAcc887 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s887 PRE_first_tail_x4_L7_r0_body.S887) = fun _ _ => true
kernel_rfl bodyBr888 : bridgeOf PRE_first_tail_x4_L7_r0_body.s888.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt887 : isHalt PRE_first_tail_x4_L7_r0_body.s887.ctl = false
kernel_rfl bodyTop888 : noRetBlock PRE_first_tail_x4_L7_r0_body.s888 = true
kernel_rfl bodyCnt884 : countersOkB PRE_first_tail_x4_L7_r0_body.s884 PRE_first_tail_x4_L7_r0_body.s888 = true
kernel_rfl bodyO888 : PRE_first_tail_x4_L7_r0_body.S888.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S888.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr889 : bridgeOf PRE_first_tail_x4_L7_r0_body.s889.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt888 : countersOkB PRE_first_tail_x4_L7_r0_body.s888 PRE_first_tail_x4_L7_r0_body.s889 = true
kernel_rfl bodyO889 : PRE_first_tail_x4_L7_r0_body.S889.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S889.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc889 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s889 PRE_first_tail_x4_L7_r0_body.S889) = fun _ _ => true
kernel_rfl bodyAcc893 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s893 PRE_first_tail_x4_L7_r0_body.S893) = fun _ _ => true
kernel_rfl bodyBr894 : bridgeOf PRE_first_tail_x4_L7_r0_body.s894.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt893 : isHalt PRE_first_tail_x4_L7_r0_body.s893.ctl = false
kernel_rfl bodyTop894 : noRetBlock PRE_first_tail_x4_L7_r0_body.s894 = true
kernel_rfl bodyCnt889 : countersOkB PRE_first_tail_x4_L7_r0_body.s889 PRE_first_tail_x4_L7_r0_body.s894 = true
kernel_rfl bodyO894 : PRE_first_tail_x4_L7_r0_body.S894.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S894.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr895 : bridgeOf PRE_first_tail_x4_L7_r0_body.s895.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt894 : countersOkB PRE_first_tail_x4_L7_r0_body.s894 PRE_first_tail_x4_L7_r0_body.s895 = true
kernel_rfl bodyO895 : PRE_first_tail_x4_L7_r0_body.S895.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S895.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc895 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s895 PRE_first_tail_x4_L7_r0_body.S895) = fun _ _ => true
kernel_rfl bodyAcc896 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s896 PRE_first_tail_x4_L7_r0_body.S896) = fun _ _ => true
kernel_rfl bodyBr897 : bridgeOf PRE_first_tail_x4_L7_r0_body.s897.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt896 : isHalt PRE_first_tail_x4_L7_r0_body.s896.ctl = false
kernel_rfl bodyTop897 : noRetBlock PRE_first_tail_x4_L7_r0_body.s897 = true
kernel_rfl bodyCnt895 : countersOkB PRE_first_tail_x4_L7_r0_body.s895 PRE_first_tail_x4_L7_r0_body.s897 = true
kernel_rfl bodyO897 : PRE_first_tail_x4_L7_r0_body.S897.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S897.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr898 : bridgeOf PRE_first_tail_x4_L7_r0_body.s898.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt897 : countersOkB PRE_first_tail_x4_L7_r0_body.s897 PRE_first_tail_x4_L7_r0_body.s898 = true
kernel_rfl bodyO898 : PRE_first_tail_x4_L7_r0_body.S898.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S898.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc898 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s898 PRE_first_tail_x4_L7_r0_body.S898) = fun _ _ => true
kernel_rfl bodyAcc899 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s899 PRE_first_tail_x4_L7_r0_body.S899) = fun _ _ => true
kernel_rfl bodyBr900 : bridgeOf PRE_first_tail_x4_L7_r0_body.s900.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt899 : isHalt PRE_first_tail_x4_L7_r0_body.s899.ctl = false
kernel_rfl bodyTop900 : noRetBlock PRE_first_tail_x4_L7_r0_body.s900 = true
kernel_rfl bodyCnt898 : countersOkB PRE_first_tail_x4_L7_r0_body.s898 PRE_first_tail_x4_L7_r0_body.s900 = true
kernel_rfl bodyO900 : PRE_first_tail_x4_L7_r0_body.S900.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S900.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr901 : bridgeOf PRE_first_tail_x4_L7_r0_body.s901.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt900 : countersOkB PRE_first_tail_x4_L7_r0_body.s900 PRE_first_tail_x4_L7_r0_body.s901 = true
kernel_rfl bodyO901 : PRE_first_tail_x4_L7_r0_body.S901.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S901.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc901 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s901 PRE_first_tail_x4_L7_r0_body.S901) = fun _ _ => true
kernel_rfl bodyAcc902 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s902 PRE_first_tail_x4_L7_r0_body.S902) = fun _ _ => true
kernel_rfl bodyBr903 : bridgeOf PRE_first_tail_x4_L7_r0_body.s903.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt902 : isHalt PRE_first_tail_x4_L7_r0_body.s902.ctl = false
kernel_rfl bodyTop903 : noRetBlock PRE_first_tail_x4_L7_r0_body.s903 = true
kernel_rfl bodyCnt901 : countersOkB PRE_first_tail_x4_L7_r0_body.s901 PRE_first_tail_x4_L7_r0_body.s903 = true
kernel_rfl bodyO903 : PRE_first_tail_x4_L7_r0_body.S903.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S903.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr904 : bridgeOf PRE_first_tail_x4_L7_r0_body.s904.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt903 : countersOkB PRE_first_tail_x4_L7_r0_body.s903 PRE_first_tail_x4_L7_r0_body.s904 = true
kernel_rfl bodyO904 : PRE_first_tail_x4_L7_r0_body.S904.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S904.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc904 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s904 PRE_first_tail_x4_L7_r0_body.S904) = fun _ _ => true
kernel_rfl bodyAcc905 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s905 PRE_first_tail_x4_L7_r0_body.S905) = fun _ _ => true
kernel_rfl bodyBr906 : bridgeOf PRE_first_tail_x4_L7_r0_body.s906.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt905 : isHalt PRE_first_tail_x4_L7_r0_body.s905.ctl = false
kernel_rfl bodyTop906 : noRetBlock PRE_first_tail_x4_L7_r0_body.s906 = true
kernel_rfl bodyCnt904 : countersOkB PRE_first_tail_x4_L7_r0_body.s904 PRE_first_tail_x4_L7_r0_body.s906 = true

theorem bodyGlue40 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42084, 791, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s884 PRE_first_tail_x4_L7_r0_body.S884)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42084, 791, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s906 PRE_first_tail_x4_L7_r0_body.S906) 30169 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) bodyAcc884 PRE_first_tail_x4_L7_r0_body.bodyRunSeg229 bodyAcc887 bodyHalt887 PRE_first_tail_x4_L7_r0_body.bodyStepA230 bodyTop888 (fun _ hm => bodyO884 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr884).trans bodyInactive0) (bodyBr888.trans bodyBr884.symm) bodyCnt884 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA230 PRE_first_tail_x4_L7_r0_body.sizeArgsA230 PRE_first_tail_x4_L7_r0_body.sizeSymA230 PRE_first_tail_x4_L7_r0_body.sizeMlxA230 PRE_first_tail_x4_L7_r0_body.sizePayA230 PRE_first_tail_x4_L7_r0_body.sizeTaA230 PRE_first_tail_x4_L7_r0_body.sizeDecA230 PRE_first_tail_x4_L7_r0_body.sizePreA230 PRE_first_tail_x4_L7_r0_body.bodyPatchB230 (fun _ hm => bodyO888 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr888).trans bodyInactive0) (bodyBr889.trans bodyBr888.symm) bodyCnt888 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) bodyAcc889 PRE_first_tail_x4_L7_r0_body.bodyRunSeg230 bodyAcc893 bodyHalt893 PRE_first_tail_x4_L7_r0_body.bodyStepA231 bodyTop894 (fun _ hm => bodyO889 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr889).trans bodyInactive0) (bodyBr894.trans bodyBr889.symm) bodyCnt889 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA231 PRE_first_tail_x4_L7_r0_body.sizeArgsA231 PRE_first_tail_x4_L7_r0_body.sizeSymA231 PRE_first_tail_x4_L7_r0_body.sizeMlxA231 PRE_first_tail_x4_L7_r0_body.sizePayA231 PRE_first_tail_x4_L7_r0_body.sizeTaA231 PRE_first_tail_x4_L7_r0_body.sizeDecA231 PRE_first_tail_x4_L7_r0_body.sizePreA231 PRE_first_tail_x4_L7_r0_body.bodyPatchB231 (fun _ hm => bodyO894 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr894).trans bodyInactive0) (bodyBr895.trans bodyBr894.symm) bodyCnt894 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) bodyAcc895 PRE_first_tail_x4_L7_r0_body.bodyRunSeg231 bodyAcc896 bodyHalt896 PRE_first_tail_x4_L7_r0_body.bodyStepA232 bodyTop897 (fun _ hm => bodyO895 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr895).trans bodyInactive0) (bodyBr897.trans bodyBr895.symm) bodyCnt895 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA232 PRE_first_tail_x4_L7_r0_body.sizeArgsA232 PRE_first_tail_x4_L7_r0_body.sizeSymA232 PRE_first_tail_x4_L7_r0_body.sizeMlxA232 PRE_first_tail_x4_L7_r0_body.sizePayA232 PRE_first_tail_x4_L7_r0_body.sizeTaA232 PRE_first_tail_x4_L7_r0_body.sizeDecA232 PRE_first_tail_x4_L7_r0_body.sizePreA232 PRE_first_tail_x4_L7_r0_body.bodyPatchB232 (fun _ hm => bodyO897 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr897).trans bodyInactive0) (bodyBr898.trans bodyBr897.symm) bodyCnt897 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) bodyAcc898 PRE_first_tail_x4_L7_r0_body.bodyRunSeg232 bodyAcc899 bodyHalt899 PRE_first_tail_x4_L7_r0_body.bodyStepA233 bodyTop900 (fun _ hm => bodyO898 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr898).trans bodyInactive0) (bodyBr900.trans bodyBr898.symm) bodyCnt898 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA233 PRE_first_tail_x4_L7_r0_body.sizeArgsA233 PRE_first_tail_x4_L7_r0_body.sizeSymA233 PRE_first_tail_x4_L7_r0_body.sizeMlxA233 PRE_first_tail_x4_L7_r0_body.sizePayA233 PRE_first_tail_x4_L7_r0_body.sizeTaA233 PRE_first_tail_x4_L7_r0_body.sizeDecA233 PRE_first_tail_x4_L7_r0_body.sizePreA233 PRE_first_tail_x4_L7_r0_body.bodyPatchB233 (fun _ hm => bodyO900 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr900).trans bodyInactive0) (bodyBr901.trans bodyBr900.symm) bodyCnt900 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) bodyAcc901 PRE_first_tail_x4_L7_r0_body.bodyRunSeg233 bodyAcc902 bodyHalt902 PRE_first_tail_x4_L7_r0_body.bodyStepA234 bodyTop903 (fun _ hm => bodyO901 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr901).trans bodyInactive0) (bodyBr903.trans bodyBr901.symm) bodyCnt901 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA234 PRE_first_tail_x4_L7_r0_body.sizeArgsA234 PRE_first_tail_x4_L7_r0_body.sizeSymA234 PRE_first_tail_x4_L7_r0_body.sizeMlxA234 PRE_first_tail_x4_L7_r0_body.sizePayA234 PRE_first_tail_x4_L7_r0_body.sizeTaA234 PRE_first_tail_x4_L7_r0_body.sizeDecA234 PRE_first_tail_x4_L7_r0_body.sizePreA234 PRE_first_tail_x4_L7_r0_body.bodyPatchB234 (fun _ hm => bodyO903 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr903).trans bodyInactive0) (bodyBr904.trans bodyBr903.symm) bodyCnt903 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42084, 791, 0, 0⟩) bodyAcc904 PRE_first_tail_x4_L7_r0_body.bodyRunSeg234 bodyAcc905 bodyHalt905 PRE_first_tail_x4_L7_r0_body.bodyStepA235 bodyTop906 (fun _ hm => bodyO904 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr904).trans bodyInactive0) (bodyBr906.trans bodyBr904.symm) bodyCnt904 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyS40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift40 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L7_r0_body.S906.tab.length PRE_first_tail_x4_L7_r0_body.s906.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L7_r0_body.P40.NL) : Conv.FullShiftQ PRE_first_tail_x4_L7_r0_body.P40 15 PRE_first_tail_x4_L7_r0_body.kappa40 PRE_first_tail_x4_L7_r0_body.s908.ffi PRE_first_tail_x4_L7_r0_body.s907.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L7_r0_body.ofxC_40
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L7_r0_body.okrC_40
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s908.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L7_r0_body.S906.tab.length) hr.cl (by rw [PRE_first_tail_x4_L7_r0_body.n0_40] <;> decide) PRE_first_tail_x4_L7_r0_body.cnodesK40 PRE_first_tail_x4_L7_r0_body.cobjsK40
      PRE_first_tail_x4_L7_r0_body.citemsK40 PRE_first_tail_x4_L7_r0_body.cbd40 PRE_first_tail_x4_L7_r0_body.csst40
  exact PRE_first_tail_x4_L7_r0_body.cshift40 bodyNcl40 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L7_r0_body.n0_40] at this; exact this)


kernel_rfl bodyFramesEmpty40 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L7_r0_body.s907 a).isEmpty) = true
kernel_rfl bodyJsRoots40 : noBigRootsP (jsAboveB PRE_first_tail_x4_L7_r0_body.s906.next) PRE_first_tail_x4_L7_r0_body.s908.trace PRE_first_tail_x4_L7_r0_body.s908 = true
kernel_rfl bodyJsNative40 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L7_r0_body.s908.ffi) = true
kernel_rfl bodyLow40 : (PRE_first_tail_x4_L7_r0_body.cws40 ++ PRE_first_tail_x4_L7_r0_body.ws40).all (Nat.ble 9) = true
kernel_rfl bodyCntM40 : countersOkB PRE_first_tail_x4_L7_r0_body.s906 PRE_first_tail_x4_L7_r0_body.s907 = true
kernel_rfl bodyHi40 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s908.ffi).next setupP.E = true
kernel_rfl bodyNhi40 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s908.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge40 : bridgeOf PRE_first_tail_x4_L7_r0_body.s907.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s906.ffi
kernel_rfl bodyNN40 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s906.ffi).nnext PRE_first_tail_x4_L7_r0_body.P40.NL = true
kernel_rfl bodyXn40 : Nat.ble (⟨20709, 17805, 2775297, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L7_r0_body.s908.ffi).next = true
kernel_rfl bodyLo40 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L7_r0_body.s908.ffi).next = true
theorem bodyFacts40 : BodySiteFacts PRE_first_tail_x4_L7_r0_body.s906 PRE_first_tail_x4_L7_r0_body.s907 PRE_first_tail_x4_L7_r0_body.s908 PRE_first_tail_x4_L7_r0_body.s0 PRE_first_tail_x4_L7_r0_body.S906 PRE_first_tail_x4_L7_r0_body.S907 PRE_first_tail_x4_L7_r0_body.S908
    PRE_first_tail_x4_L7_r0_body.ws40 PRE_first_tail_x4_L7_r0_body.cws40 PRE_first_tail_x4_L7_r0_body.nr40 PRE_first_tail_x4_L7_r0_body.pl40 PRE_first_tail_x4_L7_r0_body.cl40 2776446 15 PRE_first_tail_x4_L7_r0_body.kd40 PRE_first_tail_x4_L7_r0_body.kappa40 PRE_first_tail_x4_L7_r0_body.P40
    ⟨20706, 17778, 2775291, 15⟩ ⟨20709, 17805, 2775297, 15⟩ where
  zkap := PRE_first_tail_x4_L7_r0_body.zkap40
  clean := bodyClean40
  cfix := PRE_first_tail_x4_L7_r0_body.cfix40
  zpl := PRE_first_tail_x4_L7_r0_body.zpl40
  zplnd := PRE_first_tail_x4_L7_r0_body.zplnd40
  zn1 := PRE_first_tail_x4_L7_r0_body.zn140
  zfirst := PRE_first_tail_x4_L7_r0_body.zfirst40
  zscn := PRE_first_tail_x4_L7_r0_body.zscn40
  zsmn := PRE_first_tail_x4_L7_r0_body.zsmn40
  zgrow := PRE_first_tail_x4_L7_r0_body.zgrow40
  mergeTab := PRE_first_tail_x4_L7_r0_body.mergeTab40
  zfresh := PRE_first_tail_x4_L7_r0_body.zfresh40
  zcnd := PRE_first_tail_x4_L7_r0_body.zcnd40
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L7_r0_body.znrHi40
  zfrlt := PRE_first_tail_x4_L7_r0_body.zfrlt40
  zgP := PRE_first_tail_x4_L7_r0_body.zg40_2665
  zkP := PRE_first_tail_x4_L7_r0_body.zk40_2665
  zmP := PRE_first_tail_x4_L7_r0_body.zm40_2665
  zgC := PRE_first_tail_x4_L7_r0_body.zg40_2673467
  zkC := PRE_first_tail_x4_L7_r0_body.zk40_2673467
  zmC := PRE_first_tail_x4_L7_r0_body.zm40_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L7_r0_body.zw40_2673472
  zwV := PRE_first_tail_x4_L7_r0_body.zw40_2673473
  cheap := PRE_first_tail_x4_L7_r0_body.cheap40
  zclbd := PRE_first_tail_x4_L7_r0_body.zclbd40
  hml := hoff_of PRE_first_tail_x4_L7_r0_body.mheap40 PRE_first_tail_x4_L7_r0_body.stFoot40 PRE_first_tail_x4_L7_r0_body.iso40 PRE_first_tail_x4_L7_r0_body.zwr40
  ckeepP := PRE_first_tail_x4_L7_r0_body.ckeepP40
  csupp := PRE_first_tail_x4_L7_r0_body.csupp40
  cbound := PRE_first_tail_x4_L7_r0_body.cbound40
  zimg := PRE_first_tail_x4_L7_r0_body.zimg40
  zctl := PRE_first_tail_x4_L7_r0_body.zctl40
  zstack := PRE_first_tail_x4_L7_r0_body.zstack40
  zjobs := PRE_first_tail_x4_L7_r0_body.zjobs40
  zstores := PRE_first_tail_x4_L7_r0_body.zstores40
  zroots := PRE_first_tail_x4_L7_r0_body.zroots40
  znC := PRE_first_tail_x4_L7_r0_body.znC40
  ctab := PRE_first_tail_x4_L7_r0_body.ctab40
  zbin := PRE_first_tail_x4_L7_r0_body.zbin40
  cbridge := PRE_first_tail_x4_L7_r0_body.cbridge40
  sbridge := bodyBridge40
  cwsDisj := PRE_first_tail_x4_L7_r0_body.cwsDisj40
  cshiftR := fun h hNL => bodyCshift40 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN40
  raised := PRE_first_tail_x4_L7_r0_body.raised40
  cbigs := PRE_first_tail_x4_L7_r0_body.cbigs40
  cjcl := PRE_first_tail_x4_L7_r0_body.cjcl40
  xnLe := Nat.le_of_ble_eq_true bodyXn40
  loLe := Nat.le_of_ble_eq_true bodyLo40
  zroots2 := PRE_first_tail_x4_L7_r0_body.zrootsB40
  cntM := bodyCntM40
  hiLe := Nat.le_of_ble_eq_true bodyHi40
  nhiLe := Nat.le_of_ble_eq_true bodyNhi40
  jsHeap := bodyJs40
  jsRoots := bodyJsRoots40
  jsNative := bodyJsNative40
  framesEmpty := bodyFramesEmpty40
  trailOld := by decide
  lowVars := bodyLow40

def bodyQs40 : List (Option Q) := []
noncomputable def bodyEs40 : List (Option SymE) := PRE_first_tail_x4_L7_r0_body.nr40.map fun r => nth? PRE_first_tail_x4_L7_r0_body.st40.S5.tab r
kernel_rfl bodyResChk40 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs40 bodyQs40) = true
kernel_rfl bodyLq40 : bodyQs40.length = PRE_first_tail_x4_L7_r0_body.cws40.length
kernel_rfl bodyNrLo40 : PRE_first_tail_x4_L7_r0_body.nr40.all (Nat.ble PRE_first_tail_x4_L7_r0_body.S906.tab.length) = true
kernel_rfl bodySub40 : (Oracles.PRE_first_tail_x4_L7_r0_body.map_site40.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost40 : postSubB bodyM PRE_first_tail_x4_L7_r0_body.ws40 PRE_first_tail_x4_L7_r0_body.cws40 bodyQs40 = true
kernel_rfl bodyDrop40 : Nat.ble (42084 + (PRE_first_tail_x4_L7_r0_body.s907.next - PRE_first_tail_x4_L7_r0_body.s908.next)) 43233 = true
kernel_rfl bodyDropH40 : Nat.ble (791 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s907.ffi).next - (mlxOf PRE_first_tail_x4_L7_r0_body.s908.ffi).next)) 816 = true
kernel_rfl bodyDropN40 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s907.ffi).nnext - (mlxOf PRE_first_tail_x4_L7_r0_body.s908.ffi).nnext)) 0 = true
kernel_rfl bodyDv40 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L7_r0_body.cws40
kernel_rfl bodyDe40 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L7_r0_body.nr40.map (fun r =>
  ((nth? PRE_first_tail_x4_L7_r0_body.st40.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl40 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold40 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L7_r0_body.cws40).isNone && !PRE_first_tail_x4_L7_r0_body.ws40.contains v) = true
kernel_rfl bodyDfree40 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L7_r0_body.cws40 ++ PRE_first_tail_x4_L7_r0_body.ws40).all fun w => e.noVar w) = true

theorem bodyStep40 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42084, 791, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s906 PRE_first_tail_x4_L7_r0_body.S906)
      (bodyCut NB T tk π i x0 bodyΘ ⟨43233, 816, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s908 PRE_first_tail_x4_L7_r0_body.S908) (11334 + 1) :=
  bodySite bodyFacts40.cfix bodyFacts40.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L7_r0_body.st40.S5.tab) (Es := bodyEs40) (qs := bodyQs40)
    (ok := PRE_first_tail_x4_L7_r0_body.st40.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L7_r0_body.site40 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts40
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L7_r0_body.chk_site40 r hr) hi (MapOk.sub hm (sub_of_all bodySub40)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk40 r hr) hi hm ho hq)
    bodyLq40 rfl bodyNrLo40 (postSub_sound bodyPost40)
    (Nat.le_of_ble_eq_true bodyDrop40) (by decide) (Nat.le_of_ble_eq_true bodyDropH40) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN40) (by decide)
    bodyDv40 bodyDe40 bodyDl40 bodyDold40 bodyDfree40 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodySite41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_site41 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site41 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site41) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st41.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L7_r0_body.site41
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st41.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st41.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s928 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s929 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S928 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws41 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st41.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st41.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.iso41
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_41
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st41.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.stFoot41
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrNodup41
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrBound41
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.trace41
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.merged41
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws41.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st41.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S928.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_41]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.mergeLen41.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.fresh41
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl41 : Conv.NClean (⟨20763, 17841, 2777529, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s928.ffi).mlx :=
  PRE_first_tail_x4_L7_r0_body.gncl41 (PRE_first_tail_x4_L7_r0_body.cncl40 bodyNcl40)

theorem bodyClean41 : Conv.JClean (⟨20763, 17841, 2777529, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L7_r0_body.s928 :=
  PRE_first_tail_x4_L7_r0_body.gjcl41 (PRE_first_tail_x4_L7_r0_body.cjcl40 bodyClean40)

kernel_rfl bodyJsLe41 : Nat.ble PRE_first_tail_x4_L7_r0_body.s906.next PRE_first_tail_x4_L7_r0_body.s928.next = true
kernel_rfl bodyJsList41 : (PRE_first_tail_x4_L7_r0_body.gjh41 ++ PRE_first_tail_x4_L7_r0_body.cl41).all (noBigAtP (jsAboveB PRE_first_tail_x4_L7_r0_body.s928.next) PRE_first_tail_x4_L7_r0_body.s930) = true
theorem bodyJs41 : JsHeapAbove PRE_first_tail_x4_L7_r0_body.s928.next PRE_first_tail_x4_L7_r0_body.s930 :=
  JsHeapAbove.glueSite bodyJs40 (Nat.le_of_ble_eq_true bodyJsLe41) PRE_first_tail_x4_L7_r0_body.gjk41 PRE_first_tail_x4_L7_r0_body.gjbd41 PRE_first_tail_x4_L7_r0_body.cheap41 PRE_first_tail_x4_L7_r0_body.zclbd41 bodyJsList41

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyG41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO908 : PRE_first_tail_x4_L7_r0_body.S908.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S908.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr908 : bridgeOf PRE_first_tail_x4_L7_r0_body.s908.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyAcc908 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s908 PRE_first_tail_x4_L7_r0_body.S908) = fun _ _ => true
kernel_rfl bodyAcc909 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s909 PRE_first_tail_x4_L7_r0_body.S909) = fun _ _ => true
kernel_rfl bodyBr910 : bridgeOf PRE_first_tail_x4_L7_r0_body.s910.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt909 : isHalt PRE_first_tail_x4_L7_r0_body.s909.ctl = false
kernel_rfl bodyTop910 : noRetBlock PRE_first_tail_x4_L7_r0_body.s910 = true
kernel_rfl bodyCnt908 : countersOkB PRE_first_tail_x4_L7_r0_body.s908 PRE_first_tail_x4_L7_r0_body.s910 = true
kernel_rfl bodyO910 : PRE_first_tail_x4_L7_r0_body.S910.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S910.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr911 : bridgeOf PRE_first_tail_x4_L7_r0_body.s911.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt910 : countersOkB PRE_first_tail_x4_L7_r0_body.s910 PRE_first_tail_x4_L7_r0_body.s911 = true
kernel_rfl bodyO911 : PRE_first_tail_x4_L7_r0_body.S911.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S911.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc911 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s911 PRE_first_tail_x4_L7_r0_body.S911) = fun _ _ => true
kernel_rfl bodyAcc915 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s915 PRE_first_tail_x4_L7_r0_body.S915) = fun _ _ => true
kernel_rfl bodyBr916 : bridgeOf PRE_first_tail_x4_L7_r0_body.s916.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt915 : isHalt PRE_first_tail_x4_L7_r0_body.s915.ctl = false
kernel_rfl bodyTop916 : noRetBlock PRE_first_tail_x4_L7_r0_body.s916 = true
kernel_rfl bodyCnt911 : countersOkB PRE_first_tail_x4_L7_r0_body.s911 PRE_first_tail_x4_L7_r0_body.s916 = true
kernel_rfl bodyO916 : PRE_first_tail_x4_L7_r0_body.S916.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S916.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr917 : bridgeOf PRE_first_tail_x4_L7_r0_body.s917.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt916 : countersOkB PRE_first_tail_x4_L7_r0_body.s916 PRE_first_tail_x4_L7_r0_body.s917 = true
kernel_rfl bodyO917 : PRE_first_tail_x4_L7_r0_body.S917.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S917.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc917 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s917 PRE_first_tail_x4_L7_r0_body.S917) = fun _ _ => true
kernel_rfl bodyAcc918 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s918 PRE_first_tail_x4_L7_r0_body.S918) = fun _ _ => true
kernel_rfl bodyBr919 : bridgeOf PRE_first_tail_x4_L7_r0_body.s919.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt918 : isHalt PRE_first_tail_x4_L7_r0_body.s918.ctl = false
kernel_rfl bodyTop919 : noRetBlock PRE_first_tail_x4_L7_r0_body.s919 = true
kernel_rfl bodyCnt917 : countersOkB PRE_first_tail_x4_L7_r0_body.s917 PRE_first_tail_x4_L7_r0_body.s919 = true
kernel_rfl bodyO919 : PRE_first_tail_x4_L7_r0_body.S919.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S919.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr920 : bridgeOf PRE_first_tail_x4_L7_r0_body.s920.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt919 : countersOkB PRE_first_tail_x4_L7_r0_body.s919 PRE_first_tail_x4_L7_r0_body.s920 = true
kernel_rfl bodyO920 : PRE_first_tail_x4_L7_r0_body.S920.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S920.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc920 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s920 PRE_first_tail_x4_L7_r0_body.S920) = fun _ _ => true
kernel_rfl bodyAcc921 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s921 PRE_first_tail_x4_L7_r0_body.S921) = fun _ _ => true
kernel_rfl bodyBr922 : bridgeOf PRE_first_tail_x4_L7_r0_body.s922.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt921 : isHalt PRE_first_tail_x4_L7_r0_body.s921.ctl = false
kernel_rfl bodyTop922 : noRetBlock PRE_first_tail_x4_L7_r0_body.s922 = true
kernel_rfl bodyCnt920 : countersOkB PRE_first_tail_x4_L7_r0_body.s920 PRE_first_tail_x4_L7_r0_body.s922 = true
kernel_rfl bodyO922 : PRE_first_tail_x4_L7_r0_body.S922.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S922.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr923 : bridgeOf PRE_first_tail_x4_L7_r0_body.s923.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt922 : countersOkB PRE_first_tail_x4_L7_r0_body.s922 PRE_first_tail_x4_L7_r0_body.s923 = true
kernel_rfl bodyO923 : PRE_first_tail_x4_L7_r0_body.S923.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S923.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc923 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s923 PRE_first_tail_x4_L7_r0_body.S923) = fun _ _ => true
kernel_rfl bodyAcc924 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s924 PRE_first_tail_x4_L7_r0_body.S924) = fun _ _ => true
kernel_rfl bodyBr925 : bridgeOf PRE_first_tail_x4_L7_r0_body.s925.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt924 : isHalt PRE_first_tail_x4_L7_r0_body.s924.ctl = false
kernel_rfl bodyTop925 : noRetBlock PRE_first_tail_x4_L7_r0_body.s925 = true
kernel_rfl bodyCnt923 : countersOkB PRE_first_tail_x4_L7_r0_body.s923 PRE_first_tail_x4_L7_r0_body.s925 = true
kernel_rfl bodyO925 : PRE_first_tail_x4_L7_r0_body.S925.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S925.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr926 : bridgeOf PRE_first_tail_x4_L7_r0_body.s926.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt925 : countersOkB PRE_first_tail_x4_L7_r0_body.s925 PRE_first_tail_x4_L7_r0_body.s926 = true
kernel_rfl bodyO926 : PRE_first_tail_x4_L7_r0_body.S926.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S926.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc926 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s926 PRE_first_tail_x4_L7_r0_body.S926) = fun _ _ => true
kernel_rfl bodyAcc927 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s927 PRE_first_tail_x4_L7_r0_body.S927) = fun _ _ => true
kernel_rfl bodyBr928 : bridgeOf PRE_first_tail_x4_L7_r0_body.s928.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt927 : isHalt PRE_first_tail_x4_L7_r0_body.s927.ctl = false
kernel_rfl bodyTop928 : noRetBlock PRE_first_tail_x4_L7_r0_body.s928 = true
kernel_rfl bodyCnt926 : countersOkB PRE_first_tail_x4_L7_r0_body.s926 PRE_first_tail_x4_L7_r0_body.s928 = true

theorem bodyGlue41 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨43233, 816, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s908 PRE_first_tail_x4_L7_r0_body.S908)
      (bodyCut NB T tk π i x0 bodyΘ ⟨43233, 816, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s928 PRE_first_tail_x4_L7_r0_body.S928) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) bodyAcc908 PRE_first_tail_x4_L7_r0_body.bodyRunSeg235 bodyAcc909 bodyHalt909 PRE_first_tail_x4_L7_r0_body.bodyStepA236 bodyTop910 (fun _ hm => bodyO908 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr908).trans bodyInactive0) (bodyBr910.trans bodyBr908.symm) bodyCnt908 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA236 PRE_first_tail_x4_L7_r0_body.sizeArgsA236 PRE_first_tail_x4_L7_r0_body.sizeSymA236 PRE_first_tail_x4_L7_r0_body.sizeMlxA236 PRE_first_tail_x4_L7_r0_body.sizePayA236 PRE_first_tail_x4_L7_r0_body.sizeTaA236 PRE_first_tail_x4_L7_r0_body.sizeDecA236 PRE_first_tail_x4_L7_r0_body.sizePreA236 PRE_first_tail_x4_L7_r0_body.bodyPatchB236 (fun _ hm => bodyO910 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr910).trans bodyInactive0) (bodyBr911.trans bodyBr910.symm) bodyCnt910 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) bodyAcc911 PRE_first_tail_x4_L7_r0_body.bodyRunSeg236 bodyAcc915 bodyHalt915 PRE_first_tail_x4_L7_r0_body.bodyStepA237 bodyTop916 (fun _ hm => bodyO911 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr911).trans bodyInactive0) (bodyBr916.trans bodyBr911.symm) bodyCnt911 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA237 PRE_first_tail_x4_L7_r0_body.sizeArgsA237 PRE_first_tail_x4_L7_r0_body.sizeSymA237 PRE_first_tail_x4_L7_r0_body.sizeMlxA237 PRE_first_tail_x4_L7_r0_body.sizePayA237 PRE_first_tail_x4_L7_r0_body.sizeTaA237 PRE_first_tail_x4_L7_r0_body.sizeDecA237 PRE_first_tail_x4_L7_r0_body.sizePreA237 PRE_first_tail_x4_L7_r0_body.bodyPatchB237 (fun _ hm => bodyO916 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr916).trans bodyInactive0) (bodyBr917.trans bodyBr916.symm) bodyCnt916 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) bodyAcc917 PRE_first_tail_x4_L7_r0_body.bodyRunSeg237 bodyAcc918 bodyHalt918 PRE_first_tail_x4_L7_r0_body.bodyStepA238 bodyTop919 (fun _ hm => bodyO917 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr917).trans bodyInactive0) (bodyBr919.trans bodyBr917.symm) bodyCnt917 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA238 PRE_first_tail_x4_L7_r0_body.sizeArgsA238 PRE_first_tail_x4_L7_r0_body.sizeSymA238 PRE_first_tail_x4_L7_r0_body.sizeMlxA238 PRE_first_tail_x4_L7_r0_body.sizePayA238 PRE_first_tail_x4_L7_r0_body.sizeTaA238 PRE_first_tail_x4_L7_r0_body.sizeDecA238 PRE_first_tail_x4_L7_r0_body.sizePreA238 PRE_first_tail_x4_L7_r0_body.bodyPatchB238 (fun _ hm => bodyO919 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr919).trans bodyInactive0) (bodyBr920.trans bodyBr919.symm) bodyCnt919 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) bodyAcc920 PRE_first_tail_x4_L7_r0_body.bodyRunSeg238 bodyAcc921 bodyHalt921 PRE_first_tail_x4_L7_r0_body.bodyStepA239 bodyTop922 (fun _ hm => bodyO920 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr920).trans bodyInactive0) (bodyBr922.trans bodyBr920.symm) bodyCnt920 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA239 PRE_first_tail_x4_L7_r0_body.sizeArgsA239 PRE_first_tail_x4_L7_r0_body.sizeSymA239 PRE_first_tail_x4_L7_r0_body.sizeMlxA239 PRE_first_tail_x4_L7_r0_body.sizePayA239 PRE_first_tail_x4_L7_r0_body.sizeTaA239 PRE_first_tail_x4_L7_r0_body.sizeDecA239 PRE_first_tail_x4_L7_r0_body.sizePreA239 PRE_first_tail_x4_L7_r0_body.bodyPatchB239 (fun _ hm => bodyO922 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr922).trans bodyInactive0) (bodyBr923.trans bodyBr922.symm) bodyCnt922 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) bodyAcc923 PRE_first_tail_x4_L7_r0_body.bodyRunSeg239 bodyAcc924 bodyHalt924 PRE_first_tail_x4_L7_r0_body.bodyStepA240 bodyTop925 (fun _ hm => bodyO923 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr923).trans bodyInactive0) (bodyBr925.trans bodyBr923.symm) bodyCnt923 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA240 PRE_first_tail_x4_L7_r0_body.sizeArgsA240 PRE_first_tail_x4_L7_r0_body.sizeSymA240 PRE_first_tail_x4_L7_r0_body.sizeMlxA240 PRE_first_tail_x4_L7_r0_body.sizePayA240 PRE_first_tail_x4_L7_r0_body.sizeTaA240 PRE_first_tail_x4_L7_r0_body.sizeDecA240 PRE_first_tail_x4_L7_r0_body.sizePreA240 PRE_first_tail_x4_L7_r0_body.bodyPatchB240 (fun _ hm => bodyO925 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr925).trans bodyInactive0) (bodyBr926.trans bodyBr925.symm) bodyCnt925 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43233, 816, 0, 0⟩) bodyAcc926 PRE_first_tail_x4_L7_r0_body.bodyRunSeg240 bodyAcc927 bodyHalt927 PRE_first_tail_x4_L7_r0_body.bodyStepA241 bodyTop928 (fun _ hm => bodyO926 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr926).trans bodyInactive0) (bodyBr928.trans bodyBr926.symm) bodyCnt926 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyS41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift41 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L7_r0_body.S928.tab.length PRE_first_tail_x4_L7_r0_body.s928.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L7_r0_body.P41.NL) : Conv.FullShiftQ PRE_first_tail_x4_L7_r0_body.P41 15 PRE_first_tail_x4_L7_r0_body.kappa41 PRE_first_tail_x4_L7_r0_body.s930.ffi PRE_first_tail_x4_L7_r0_body.s929.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L7_r0_body.ofxC_41
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L7_r0_body.okrC_41
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s930.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L7_r0_body.S928.tab.length) hr.cl (by rw [PRE_first_tail_x4_L7_r0_body.n0_41] <;> decide) PRE_first_tail_x4_L7_r0_body.cnodesK41 PRE_first_tail_x4_L7_r0_body.cobjsK41
      PRE_first_tail_x4_L7_r0_body.citemsK41 PRE_first_tail_x4_L7_r0_body.cbd41 PRE_first_tail_x4_L7_r0_body.csst41
  exact PRE_first_tail_x4_L7_r0_body.cshift41 bodyNcl41 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L7_r0_body.n0_41] at this; exact this)


kernel_rfl bodyFramesEmpty41 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L7_r0_body.s929 a).isEmpty) = true
kernel_rfl bodyJsRoots41 : noBigRootsP (jsAboveB PRE_first_tail_x4_L7_r0_body.s928.next) PRE_first_tail_x4_L7_r0_body.s930.trace PRE_first_tail_x4_L7_r0_body.s930 = true
kernel_rfl bodyJsNative41 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L7_r0_body.s930.ffi) = true
kernel_rfl bodyLow41 : (PRE_first_tail_x4_L7_r0_body.cws41 ++ PRE_first_tail_x4_L7_r0_body.ws41).all (Nat.ble 9) = true
kernel_rfl bodyCntM41 : countersOkB PRE_first_tail_x4_L7_r0_body.s928 PRE_first_tail_x4_L7_r0_body.s929 = true
kernel_rfl bodyHi41 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s930.ffi).next setupP.E = true
kernel_rfl bodyNhi41 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s930.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge41 : bridgeOf PRE_first_tail_x4_L7_r0_body.s929.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s928.ffi
kernel_rfl bodyNN41 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s928.ffi).nnext PRE_first_tail_x4_L7_r0_body.P41.NL = true
kernel_rfl bodyXn41 : Nat.ble (⟨20766, 17868, 2777535, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L7_r0_body.s930.ffi).next = true
kernel_rfl bodyLo41 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L7_r0_body.s930.ffi).next = true
theorem bodyFacts41 : BodySiteFacts PRE_first_tail_x4_L7_r0_body.s928 PRE_first_tail_x4_L7_r0_body.s929 PRE_first_tail_x4_L7_r0_body.s930 PRE_first_tail_x4_L7_r0_body.s0 PRE_first_tail_x4_L7_r0_body.S928 PRE_first_tail_x4_L7_r0_body.S929 PRE_first_tail_x4_L7_r0_body.S930
    PRE_first_tail_x4_L7_r0_body.ws41 PRE_first_tail_x4_L7_r0_body.cws41 PRE_first_tail_x4_L7_r0_body.nr41 PRE_first_tail_x4_L7_r0_body.pl41 PRE_first_tail_x4_L7_r0_body.cl41 2778684 15 PRE_first_tail_x4_L7_r0_body.kd41 PRE_first_tail_x4_L7_r0_body.kappa41 PRE_first_tail_x4_L7_r0_body.P41
    ⟨20763, 17841, 2777529, 15⟩ ⟨20766, 17868, 2777535, 15⟩ where
  zkap := PRE_first_tail_x4_L7_r0_body.zkap41
  clean := bodyClean41
  cfix := PRE_first_tail_x4_L7_r0_body.cfix41
  zpl := PRE_first_tail_x4_L7_r0_body.zpl41
  zplnd := PRE_first_tail_x4_L7_r0_body.zplnd41
  zn1 := PRE_first_tail_x4_L7_r0_body.zn141
  zfirst := PRE_first_tail_x4_L7_r0_body.zfirst41
  zscn := PRE_first_tail_x4_L7_r0_body.zscn41
  zsmn := PRE_first_tail_x4_L7_r0_body.zsmn41
  zgrow := PRE_first_tail_x4_L7_r0_body.zgrow41
  mergeTab := PRE_first_tail_x4_L7_r0_body.mergeTab41
  zfresh := PRE_first_tail_x4_L7_r0_body.zfresh41
  zcnd := PRE_first_tail_x4_L7_r0_body.zcnd41
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L7_r0_body.znrHi41
  zfrlt := PRE_first_tail_x4_L7_r0_body.zfrlt41
  zgP := PRE_first_tail_x4_L7_r0_body.zg41_2665
  zkP := PRE_first_tail_x4_L7_r0_body.zk41_2665
  zmP := PRE_first_tail_x4_L7_r0_body.zm41_2665
  zgC := PRE_first_tail_x4_L7_r0_body.zg41_2673467
  zkC := PRE_first_tail_x4_L7_r0_body.zk41_2673467
  zmC := PRE_first_tail_x4_L7_r0_body.zm41_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L7_r0_body.zw41_2673472
  zwV := PRE_first_tail_x4_L7_r0_body.zw41_2673473
  cheap := PRE_first_tail_x4_L7_r0_body.cheap41
  zclbd := PRE_first_tail_x4_L7_r0_body.zclbd41
  hml := hoff_of PRE_first_tail_x4_L7_r0_body.mheap41 PRE_first_tail_x4_L7_r0_body.stFoot41 PRE_first_tail_x4_L7_r0_body.iso41 PRE_first_tail_x4_L7_r0_body.zwr41
  ckeepP := PRE_first_tail_x4_L7_r0_body.ckeepP41
  csupp := PRE_first_tail_x4_L7_r0_body.csupp41
  cbound := PRE_first_tail_x4_L7_r0_body.cbound41
  zimg := PRE_first_tail_x4_L7_r0_body.zimg41
  zctl := PRE_first_tail_x4_L7_r0_body.zctl41
  zstack := PRE_first_tail_x4_L7_r0_body.zstack41
  zjobs := PRE_first_tail_x4_L7_r0_body.zjobs41
  zstores := PRE_first_tail_x4_L7_r0_body.zstores41
  zroots := PRE_first_tail_x4_L7_r0_body.zroots41
  znC := PRE_first_tail_x4_L7_r0_body.znC41
  ctab := PRE_first_tail_x4_L7_r0_body.ctab41
  zbin := PRE_first_tail_x4_L7_r0_body.zbin41
  cbridge := PRE_first_tail_x4_L7_r0_body.cbridge41
  sbridge := bodyBridge41
  cwsDisj := PRE_first_tail_x4_L7_r0_body.cwsDisj41
  cshiftR := fun h hNL => bodyCshift41 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN41
  raised := PRE_first_tail_x4_L7_r0_body.raised41
  cbigs := PRE_first_tail_x4_L7_r0_body.cbigs41
  cjcl := PRE_first_tail_x4_L7_r0_body.cjcl41
  xnLe := Nat.le_of_ble_eq_true bodyXn41
  loLe := Nat.le_of_ble_eq_true bodyLo41
  zroots2 := PRE_first_tail_x4_L7_r0_body.zrootsB41
  cntM := bodyCntM41
  hiLe := Nat.le_of_ble_eq_true bodyHi41
  nhiLe := Nat.le_of_ble_eq_true bodyNhi41
  jsHeap := bodyJs41
  jsRoots := bodyJsRoots41
  jsNative := bodyJsNative41
  framesEmpty := bodyFramesEmpty41
  trailOld := by decide
  lowVars := bodyLow41

def bodyQs41 : List (Option Q) := []
noncomputable def bodyEs41 : List (Option SymE) := PRE_first_tail_x4_L7_r0_body.nr41.map fun r => nth? PRE_first_tail_x4_L7_r0_body.st41.S5.tab r
kernel_rfl bodyResChk41 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs41 bodyQs41) = true
kernel_rfl bodyLq41 : bodyQs41.length = PRE_first_tail_x4_L7_r0_body.cws41.length
kernel_rfl bodyNrLo41 : PRE_first_tail_x4_L7_r0_body.nr41.all (Nat.ble PRE_first_tail_x4_L7_r0_body.S928.tab.length) = true
kernel_rfl bodySub41 : (Oracles.PRE_first_tail_x4_L7_r0_body.map_site41.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost41 : postSubB bodyM PRE_first_tail_x4_L7_r0_body.ws41 PRE_first_tail_x4_L7_r0_body.cws41 bodyQs41 = true
kernel_rfl bodyDrop41 : Nat.ble (43233 + (PRE_first_tail_x4_L7_r0_body.s929.next - PRE_first_tail_x4_L7_r0_body.s930.next)) 44382 = true
kernel_rfl bodyDropH41 : Nat.ble (816 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s929.ffi).next - (mlxOf PRE_first_tail_x4_L7_r0_body.s930.ffi).next)) 841 = true
kernel_rfl bodyDropN41 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s929.ffi).nnext - (mlxOf PRE_first_tail_x4_L7_r0_body.s930.ffi).nnext)) 0 = true
kernel_rfl bodyDv41 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L7_r0_body.cws41
kernel_rfl bodyDe41 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L7_r0_body.nr41.map (fun r =>
  ((nth? PRE_first_tail_x4_L7_r0_body.st41.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl41 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold41 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L7_r0_body.cws41).isNone && !PRE_first_tail_x4_L7_r0_body.ws41.contains v) = true
kernel_rfl bodyDfree41 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L7_r0_body.cws41 ++ PRE_first_tail_x4_L7_r0_body.ws41).all fun w => e.noVar w) = true

theorem bodyStep41 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨43233, 816, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s928 PRE_first_tail_x4_L7_r0_body.S928)
      (bodyCut NB T tk π i x0 bodyΘ ⟨44382, 841, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s930 PRE_first_tail_x4_L7_r0_body.S930) (11334 + 1) :=
  bodySite bodyFacts41.cfix bodyFacts41.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L7_r0_body.st41.S5.tab) (Es := bodyEs41) (qs := bodyQs41)
    (ok := PRE_first_tail_x4_L7_r0_body.st41.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L7_r0_body.site41 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts41
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L7_r0_body.chk_site41 r hr) hi (MapOk.sub hm (sub_of_all bodySub41)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk41 r hr) hi hm ho hq)
    bodyLq41 rfl bodyNrLo41 (postSub_sound bodyPost41)
    (Nat.le_of_ble_eq_true bodyDrop41) (by decide) (Nat.le_of_ble_eq_true bodyDropH41) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN41) (by decide)
    bodyDv41 bodyDe41 bodyDl41 bodyDold41 bodyDfree41 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodySite42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_site42 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site42 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site42) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st42.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L7_r0_body.site42
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st42.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st42.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s950 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s951 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S950 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws42 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st42.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st42.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.iso42
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_42
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st42.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.stFoot42
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrNodup42
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrBound42
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.trace42
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.merged42
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws42.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st42.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S950.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_42]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.mergeLen42.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.fresh42
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl42 : Conv.NClean (⟨20820, 17904, 2779767, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s950.ffi).mlx :=
  PRE_first_tail_x4_L7_r0_body.gncl42 (PRE_first_tail_x4_L7_r0_body.cncl41 bodyNcl41)

theorem bodyClean42 : Conv.JClean (⟨20820, 17904, 2779767, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L7_r0_body.s950 :=
  PRE_first_tail_x4_L7_r0_body.gjcl42 (PRE_first_tail_x4_L7_r0_body.cjcl41 bodyClean41)

kernel_rfl bodyJsLe42 : Nat.ble PRE_first_tail_x4_L7_r0_body.s928.next PRE_first_tail_x4_L7_r0_body.s950.next = true
kernel_rfl bodyJsList42 : (PRE_first_tail_x4_L7_r0_body.gjh42 ++ PRE_first_tail_x4_L7_r0_body.cl42).all (noBigAtP (jsAboveB PRE_first_tail_x4_L7_r0_body.s950.next) PRE_first_tail_x4_L7_r0_body.s952) = true
theorem bodyJs42 : JsHeapAbove PRE_first_tail_x4_L7_r0_body.s950.next PRE_first_tail_x4_L7_r0_body.s952 :=
  JsHeapAbove.glueSite bodyJs41 (Nat.le_of_ble_eq_true bodyJsLe42) PRE_first_tail_x4_L7_r0_body.gjk42 PRE_first_tail_x4_L7_r0_body.gjbd42 PRE_first_tail_x4_L7_r0_body.cheap42 PRE_first_tail_x4_L7_r0_body.zclbd42 bodyJsList42

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyG42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO930 : PRE_first_tail_x4_L7_r0_body.S930.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S930.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr930 : bridgeOf PRE_first_tail_x4_L7_r0_body.s930.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyAcc930 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s930 PRE_first_tail_x4_L7_r0_body.S930) = fun _ _ => true
kernel_rfl bodyAcc931 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s931 PRE_first_tail_x4_L7_r0_body.S931) = fun _ _ => true
kernel_rfl bodyBr932 : bridgeOf PRE_first_tail_x4_L7_r0_body.s932.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt931 : isHalt PRE_first_tail_x4_L7_r0_body.s931.ctl = false
kernel_rfl bodyTop932 : noRetBlock PRE_first_tail_x4_L7_r0_body.s932 = true
kernel_rfl bodyCnt930 : countersOkB PRE_first_tail_x4_L7_r0_body.s930 PRE_first_tail_x4_L7_r0_body.s932 = true
kernel_rfl bodyO932 : PRE_first_tail_x4_L7_r0_body.S932.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S932.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr933 : bridgeOf PRE_first_tail_x4_L7_r0_body.s933.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt932 : countersOkB PRE_first_tail_x4_L7_r0_body.s932 PRE_first_tail_x4_L7_r0_body.s933 = true
kernel_rfl bodyO933 : PRE_first_tail_x4_L7_r0_body.S933.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S933.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc933 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s933 PRE_first_tail_x4_L7_r0_body.S933) = fun _ _ => true
kernel_rfl bodyAcc937 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s937 PRE_first_tail_x4_L7_r0_body.S937) = fun _ _ => true
kernel_rfl bodyBr938 : bridgeOf PRE_first_tail_x4_L7_r0_body.s938.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt937 : isHalt PRE_first_tail_x4_L7_r0_body.s937.ctl = false
kernel_rfl bodyTop938 : noRetBlock PRE_first_tail_x4_L7_r0_body.s938 = true
kernel_rfl bodyCnt933 : countersOkB PRE_first_tail_x4_L7_r0_body.s933 PRE_first_tail_x4_L7_r0_body.s938 = true
kernel_rfl bodyO938 : PRE_first_tail_x4_L7_r0_body.S938.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S938.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr939 : bridgeOf PRE_first_tail_x4_L7_r0_body.s939.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt938 : countersOkB PRE_first_tail_x4_L7_r0_body.s938 PRE_first_tail_x4_L7_r0_body.s939 = true
kernel_rfl bodyO939 : PRE_first_tail_x4_L7_r0_body.S939.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S939.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc939 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s939 PRE_first_tail_x4_L7_r0_body.S939) = fun _ _ => true
kernel_rfl bodyAcc940 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s940 PRE_first_tail_x4_L7_r0_body.S940) = fun _ _ => true
kernel_rfl bodyBr941 : bridgeOf PRE_first_tail_x4_L7_r0_body.s941.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt940 : isHalt PRE_first_tail_x4_L7_r0_body.s940.ctl = false
kernel_rfl bodyTop941 : noRetBlock PRE_first_tail_x4_L7_r0_body.s941 = true
kernel_rfl bodyCnt939 : countersOkB PRE_first_tail_x4_L7_r0_body.s939 PRE_first_tail_x4_L7_r0_body.s941 = true
kernel_rfl bodyO941 : PRE_first_tail_x4_L7_r0_body.S941.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S941.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr942 : bridgeOf PRE_first_tail_x4_L7_r0_body.s942.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt941 : countersOkB PRE_first_tail_x4_L7_r0_body.s941 PRE_first_tail_x4_L7_r0_body.s942 = true
kernel_rfl bodyO942 : PRE_first_tail_x4_L7_r0_body.S942.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S942.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc942 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s942 PRE_first_tail_x4_L7_r0_body.S942) = fun _ _ => true
kernel_rfl bodyAcc943 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s943 PRE_first_tail_x4_L7_r0_body.S943) = fun _ _ => true
kernel_rfl bodyBr944 : bridgeOf PRE_first_tail_x4_L7_r0_body.s944.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt943 : isHalt PRE_first_tail_x4_L7_r0_body.s943.ctl = false
kernel_rfl bodyTop944 : noRetBlock PRE_first_tail_x4_L7_r0_body.s944 = true
kernel_rfl bodyCnt942 : countersOkB PRE_first_tail_x4_L7_r0_body.s942 PRE_first_tail_x4_L7_r0_body.s944 = true
kernel_rfl bodyO944 : PRE_first_tail_x4_L7_r0_body.S944.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S944.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr945 : bridgeOf PRE_first_tail_x4_L7_r0_body.s945.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt944 : countersOkB PRE_first_tail_x4_L7_r0_body.s944 PRE_first_tail_x4_L7_r0_body.s945 = true
kernel_rfl bodyO945 : PRE_first_tail_x4_L7_r0_body.S945.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S945.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc945 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s945 PRE_first_tail_x4_L7_r0_body.S945) = fun _ _ => true
kernel_rfl bodyAcc946 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s946 PRE_first_tail_x4_L7_r0_body.S946) = fun _ _ => true
kernel_rfl bodyBr947 : bridgeOf PRE_first_tail_x4_L7_r0_body.s947.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt946 : isHalt PRE_first_tail_x4_L7_r0_body.s946.ctl = false
kernel_rfl bodyTop947 : noRetBlock PRE_first_tail_x4_L7_r0_body.s947 = true
kernel_rfl bodyCnt945 : countersOkB PRE_first_tail_x4_L7_r0_body.s945 PRE_first_tail_x4_L7_r0_body.s947 = true
kernel_rfl bodyO947 : PRE_first_tail_x4_L7_r0_body.S947.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S947.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr948 : bridgeOf PRE_first_tail_x4_L7_r0_body.s948.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt947 : countersOkB PRE_first_tail_x4_L7_r0_body.s947 PRE_first_tail_x4_L7_r0_body.s948 = true
kernel_rfl bodyO948 : PRE_first_tail_x4_L7_r0_body.S948.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S948.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc948 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s948 PRE_first_tail_x4_L7_r0_body.S948) = fun _ _ => true
kernel_rfl bodyAcc949 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s949 PRE_first_tail_x4_L7_r0_body.S949) = fun _ _ => true
kernel_rfl bodyBr950 : bridgeOf PRE_first_tail_x4_L7_r0_body.s950.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt949 : isHalt PRE_first_tail_x4_L7_r0_body.s949.ctl = false
kernel_rfl bodyTop950 : noRetBlock PRE_first_tail_x4_L7_r0_body.s950 = true
kernel_rfl bodyCnt948 : countersOkB PRE_first_tail_x4_L7_r0_body.s948 PRE_first_tail_x4_L7_r0_body.s950 = true

theorem bodyGlue42 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨44382, 841, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s930 PRE_first_tail_x4_L7_r0_body.S930)
      (bodyCut NB T tk π i x0 bodyΘ ⟨44382, 841, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s950 PRE_first_tail_x4_L7_r0_body.S950) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) bodyAcc930 PRE_first_tail_x4_L7_r0_body.bodyRunSeg241 bodyAcc931 bodyHalt931 PRE_first_tail_x4_L7_r0_body.bodyStepA242 bodyTop932 (fun _ hm => bodyO930 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr930).trans bodyInactive0) (bodyBr932.trans bodyBr930.symm) bodyCnt930 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA242 PRE_first_tail_x4_L7_r0_body.sizeArgsA242 PRE_first_tail_x4_L7_r0_body.sizeSymA242 PRE_first_tail_x4_L7_r0_body.sizeMlxA242 PRE_first_tail_x4_L7_r0_body.sizePayA242 PRE_first_tail_x4_L7_r0_body.sizeTaA242 PRE_first_tail_x4_L7_r0_body.sizeDecA242 PRE_first_tail_x4_L7_r0_body.sizePreA242 PRE_first_tail_x4_L7_r0_body.bodyPatchB242 (fun _ hm => bodyO932 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr932).trans bodyInactive0) (bodyBr933.trans bodyBr932.symm) bodyCnt932 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) bodyAcc933 PRE_first_tail_x4_L7_r0_body.bodyRunSeg242 bodyAcc937 bodyHalt937 PRE_first_tail_x4_L7_r0_body.bodyStepA243 bodyTop938 (fun _ hm => bodyO933 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr933).trans bodyInactive0) (bodyBr938.trans bodyBr933.symm) bodyCnt933 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA243 PRE_first_tail_x4_L7_r0_body.sizeArgsA243 PRE_first_tail_x4_L7_r0_body.sizeSymA243 PRE_first_tail_x4_L7_r0_body.sizeMlxA243 PRE_first_tail_x4_L7_r0_body.sizePayA243 PRE_first_tail_x4_L7_r0_body.sizeTaA243 PRE_first_tail_x4_L7_r0_body.sizeDecA243 PRE_first_tail_x4_L7_r0_body.sizePreA243 PRE_first_tail_x4_L7_r0_body.bodyPatchB243 (fun _ hm => bodyO938 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr938).trans bodyInactive0) (bodyBr939.trans bodyBr938.symm) bodyCnt938 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) bodyAcc939 PRE_first_tail_x4_L7_r0_body.bodyRunSeg243 bodyAcc940 bodyHalt940 PRE_first_tail_x4_L7_r0_body.bodyStepA244 bodyTop941 (fun _ hm => bodyO939 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr939).trans bodyInactive0) (bodyBr941.trans bodyBr939.symm) bodyCnt939 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA244 PRE_first_tail_x4_L7_r0_body.sizeArgsA244 PRE_first_tail_x4_L7_r0_body.sizeSymA244 PRE_first_tail_x4_L7_r0_body.sizeMlxA244 PRE_first_tail_x4_L7_r0_body.sizePayA244 PRE_first_tail_x4_L7_r0_body.sizeTaA244 PRE_first_tail_x4_L7_r0_body.sizeDecA244 PRE_first_tail_x4_L7_r0_body.sizePreA244 PRE_first_tail_x4_L7_r0_body.bodyPatchB244 (fun _ hm => bodyO941 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr941).trans bodyInactive0) (bodyBr942.trans bodyBr941.symm) bodyCnt941 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) bodyAcc942 PRE_first_tail_x4_L7_r0_body.bodyRunSeg244 bodyAcc943 bodyHalt943 PRE_first_tail_x4_L7_r0_body.bodyStepA245 bodyTop944 (fun _ hm => bodyO942 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr942).trans bodyInactive0) (bodyBr944.trans bodyBr942.symm) bodyCnt942 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA245 PRE_first_tail_x4_L7_r0_body.sizeArgsA245 PRE_first_tail_x4_L7_r0_body.sizeSymA245 PRE_first_tail_x4_L7_r0_body.sizeMlxA245 PRE_first_tail_x4_L7_r0_body.sizePayA245 PRE_first_tail_x4_L7_r0_body.sizeTaA245 PRE_first_tail_x4_L7_r0_body.sizeDecA245 PRE_first_tail_x4_L7_r0_body.sizePreA245 PRE_first_tail_x4_L7_r0_body.bodyPatchB245 (fun _ hm => bodyO944 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr944).trans bodyInactive0) (bodyBr945.trans bodyBr944.symm) bodyCnt944 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) bodyAcc945 PRE_first_tail_x4_L7_r0_body.bodyRunSeg245 bodyAcc946 bodyHalt946 PRE_first_tail_x4_L7_r0_body.bodyStepA246 bodyTop947 (fun _ hm => bodyO945 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr945).trans bodyInactive0) (bodyBr947.trans bodyBr945.symm) bodyCnt945 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA246 PRE_first_tail_x4_L7_r0_body.sizeArgsA246 PRE_first_tail_x4_L7_r0_body.sizeSymA246 PRE_first_tail_x4_L7_r0_body.sizeMlxA246 PRE_first_tail_x4_L7_r0_body.sizePayA246 PRE_first_tail_x4_L7_r0_body.sizeTaA246 PRE_first_tail_x4_L7_r0_body.sizeDecA246 PRE_first_tail_x4_L7_r0_body.sizePreA246 PRE_first_tail_x4_L7_r0_body.bodyPatchB246 (fun _ hm => bodyO947 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr947).trans bodyInactive0) (bodyBr948.trans bodyBr947.symm) bodyCnt947 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44382, 841, 0, 0⟩) bodyAcc948 PRE_first_tail_x4_L7_r0_body.bodyRunSeg246 bodyAcc949 bodyHalt949 PRE_first_tail_x4_L7_r0_body.bodyStepA247 bodyTop950 (fun _ hm => bodyO948 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr948).trans bodyInactive0) (bodyBr950.trans bodyBr948.symm) bodyCnt948 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyS42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift42 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L7_r0_body.S950.tab.length PRE_first_tail_x4_L7_r0_body.s950.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L7_r0_body.P42.NL) : Conv.FullShiftQ PRE_first_tail_x4_L7_r0_body.P42 15 PRE_first_tail_x4_L7_r0_body.kappa42 PRE_first_tail_x4_L7_r0_body.s952.ffi PRE_first_tail_x4_L7_r0_body.s951.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L7_r0_body.ofxC_42
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L7_r0_body.okrC_42
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s952.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L7_r0_body.S950.tab.length) hr.cl (by rw [PRE_first_tail_x4_L7_r0_body.n0_42] <;> decide) PRE_first_tail_x4_L7_r0_body.cnodesK42 PRE_first_tail_x4_L7_r0_body.cobjsK42
      PRE_first_tail_x4_L7_r0_body.citemsK42 PRE_first_tail_x4_L7_r0_body.cbd42 PRE_first_tail_x4_L7_r0_body.csst42
  exact PRE_first_tail_x4_L7_r0_body.cshift42 bodyNcl42 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L7_r0_body.n0_42] at this; exact this)


kernel_rfl bodyFramesEmpty42 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L7_r0_body.s951 a).isEmpty) = true
kernel_rfl bodyJsRoots42 : noBigRootsP (jsAboveB PRE_first_tail_x4_L7_r0_body.s950.next) PRE_first_tail_x4_L7_r0_body.s952.trace PRE_first_tail_x4_L7_r0_body.s952 = true
kernel_rfl bodyJsNative42 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L7_r0_body.s952.ffi) = true
kernel_rfl bodyLow42 : (PRE_first_tail_x4_L7_r0_body.cws42 ++ PRE_first_tail_x4_L7_r0_body.ws42).all (Nat.ble 9) = true
kernel_rfl bodyCntM42 : countersOkB PRE_first_tail_x4_L7_r0_body.s950 PRE_first_tail_x4_L7_r0_body.s951 = true
kernel_rfl bodyHi42 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s952.ffi).next setupP.E = true
kernel_rfl bodyNhi42 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s952.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge42 : bridgeOf PRE_first_tail_x4_L7_r0_body.s951.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s950.ffi
kernel_rfl bodyNN42 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s950.ffi).nnext PRE_first_tail_x4_L7_r0_body.P42.NL = true
kernel_rfl bodyXn42 : Nat.ble (⟨20823, 17931, 2779773, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L7_r0_body.s952.ffi).next = true
kernel_rfl bodyLo42 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L7_r0_body.s952.ffi).next = true
theorem bodyFacts42 : BodySiteFacts PRE_first_tail_x4_L7_r0_body.s950 PRE_first_tail_x4_L7_r0_body.s951 PRE_first_tail_x4_L7_r0_body.s952 PRE_first_tail_x4_L7_r0_body.s0 PRE_first_tail_x4_L7_r0_body.S950 PRE_first_tail_x4_L7_r0_body.S951 PRE_first_tail_x4_L7_r0_body.S952
    PRE_first_tail_x4_L7_r0_body.ws42 PRE_first_tail_x4_L7_r0_body.cws42 PRE_first_tail_x4_L7_r0_body.nr42 PRE_first_tail_x4_L7_r0_body.pl42 PRE_first_tail_x4_L7_r0_body.cl42 2780922 15 PRE_first_tail_x4_L7_r0_body.kd42 PRE_first_tail_x4_L7_r0_body.kappa42 PRE_first_tail_x4_L7_r0_body.P42
    ⟨20820, 17904, 2779767, 15⟩ ⟨20823, 17931, 2779773, 15⟩ where
  zkap := PRE_first_tail_x4_L7_r0_body.zkap42
  clean := bodyClean42
  cfix := PRE_first_tail_x4_L7_r0_body.cfix42
  zpl := PRE_first_tail_x4_L7_r0_body.zpl42
  zplnd := PRE_first_tail_x4_L7_r0_body.zplnd42
  zn1 := PRE_first_tail_x4_L7_r0_body.zn142
  zfirst := PRE_first_tail_x4_L7_r0_body.zfirst42
  zscn := PRE_first_tail_x4_L7_r0_body.zscn42
  zsmn := PRE_first_tail_x4_L7_r0_body.zsmn42
  zgrow := PRE_first_tail_x4_L7_r0_body.zgrow42
  mergeTab := PRE_first_tail_x4_L7_r0_body.mergeTab42
  zfresh := PRE_first_tail_x4_L7_r0_body.zfresh42
  zcnd := PRE_first_tail_x4_L7_r0_body.zcnd42
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L7_r0_body.znrHi42
  zfrlt := PRE_first_tail_x4_L7_r0_body.zfrlt42
  zgP := PRE_first_tail_x4_L7_r0_body.zg42_2665
  zkP := PRE_first_tail_x4_L7_r0_body.zk42_2665
  zmP := PRE_first_tail_x4_L7_r0_body.zm42_2665
  zgC := PRE_first_tail_x4_L7_r0_body.zg42_2673467
  zkC := PRE_first_tail_x4_L7_r0_body.zk42_2673467
  zmC := PRE_first_tail_x4_L7_r0_body.zm42_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L7_r0_body.zw42_2673472
  zwV := PRE_first_tail_x4_L7_r0_body.zw42_2673473
  cheap := PRE_first_tail_x4_L7_r0_body.cheap42
  zclbd := PRE_first_tail_x4_L7_r0_body.zclbd42
  hml := hoff_of PRE_first_tail_x4_L7_r0_body.mheap42 PRE_first_tail_x4_L7_r0_body.stFoot42 PRE_first_tail_x4_L7_r0_body.iso42 PRE_first_tail_x4_L7_r0_body.zwr42
  ckeepP := PRE_first_tail_x4_L7_r0_body.ckeepP42
  csupp := PRE_first_tail_x4_L7_r0_body.csupp42
  cbound := PRE_first_tail_x4_L7_r0_body.cbound42
  zimg := PRE_first_tail_x4_L7_r0_body.zimg42
  zctl := PRE_first_tail_x4_L7_r0_body.zctl42
  zstack := PRE_first_tail_x4_L7_r0_body.zstack42
  zjobs := PRE_first_tail_x4_L7_r0_body.zjobs42
  zstores := PRE_first_tail_x4_L7_r0_body.zstores42
  zroots := PRE_first_tail_x4_L7_r0_body.zroots42
  znC := PRE_first_tail_x4_L7_r0_body.znC42
  ctab := PRE_first_tail_x4_L7_r0_body.ctab42
  zbin := PRE_first_tail_x4_L7_r0_body.zbin42
  cbridge := PRE_first_tail_x4_L7_r0_body.cbridge42
  sbridge := bodyBridge42
  cwsDisj := PRE_first_tail_x4_L7_r0_body.cwsDisj42
  cshiftR := fun h hNL => bodyCshift42 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN42
  raised := PRE_first_tail_x4_L7_r0_body.raised42
  cbigs := PRE_first_tail_x4_L7_r0_body.cbigs42
  cjcl := PRE_first_tail_x4_L7_r0_body.cjcl42
  xnLe := Nat.le_of_ble_eq_true bodyXn42
  loLe := Nat.le_of_ble_eq_true bodyLo42
  zroots2 := PRE_first_tail_x4_L7_r0_body.zrootsB42
  cntM := bodyCntM42
  hiLe := Nat.le_of_ble_eq_true bodyHi42
  nhiLe := Nat.le_of_ble_eq_true bodyNhi42
  jsHeap := bodyJs42
  jsRoots := bodyJsRoots42
  jsNative := bodyJsNative42
  framesEmpty := bodyFramesEmpty42
  trailOld := by decide
  lowVars := bodyLow42

def bodyQs42 : List (Option Q) := []
noncomputable def bodyEs42 : List (Option SymE) := PRE_first_tail_x4_L7_r0_body.nr42.map fun r => nth? PRE_first_tail_x4_L7_r0_body.st42.S5.tab r
kernel_rfl bodyResChk42 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs42 bodyQs42) = true
kernel_rfl bodyLq42 : bodyQs42.length = PRE_first_tail_x4_L7_r0_body.cws42.length
kernel_rfl bodyNrLo42 : PRE_first_tail_x4_L7_r0_body.nr42.all (Nat.ble PRE_first_tail_x4_L7_r0_body.S950.tab.length) = true
kernel_rfl bodySub42 : (Oracles.PRE_first_tail_x4_L7_r0_body.map_site42.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost42 : postSubB bodyM PRE_first_tail_x4_L7_r0_body.ws42 PRE_first_tail_x4_L7_r0_body.cws42 bodyQs42 = true
kernel_rfl bodyDrop42 : Nat.ble (44382 + (PRE_first_tail_x4_L7_r0_body.s951.next - PRE_first_tail_x4_L7_r0_body.s952.next)) 45531 = true
kernel_rfl bodyDropH42 : Nat.ble (841 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s951.ffi).next - (mlxOf PRE_first_tail_x4_L7_r0_body.s952.ffi).next)) 866 = true
kernel_rfl bodyDropN42 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s951.ffi).nnext - (mlxOf PRE_first_tail_x4_L7_r0_body.s952.ffi).nnext)) 0 = true
kernel_rfl bodyDv42 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L7_r0_body.cws42
kernel_rfl bodyDe42 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L7_r0_body.nr42.map (fun r =>
  ((nth? PRE_first_tail_x4_L7_r0_body.st42.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl42 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold42 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L7_r0_body.cws42).isNone && !PRE_first_tail_x4_L7_r0_body.ws42.contains v) = true
kernel_rfl bodyDfree42 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L7_r0_body.cws42 ++ PRE_first_tail_x4_L7_r0_body.ws42).all fun w => e.noVar w) = true

theorem bodyStep42 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨44382, 841, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s950 PRE_first_tail_x4_L7_r0_body.S950)
      (bodyCut NB T tk π i x0 bodyΘ ⟨45531, 866, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s952 PRE_first_tail_x4_L7_r0_body.S952) (11334 + 1) :=
  bodySite bodyFacts42.cfix bodyFacts42.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L7_r0_body.st42.S5.tab) (Es := bodyEs42) (qs := bodyQs42)
    (ok := PRE_first_tail_x4_L7_r0_body.st42.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L7_r0_body.site42 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts42
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L7_r0_body.chk_site42 r hr) hi (MapOk.sub hm (sub_of_all bodySub42)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk42 r hr) hi hm ho hq)
    bodyLq42 rfl bodyNrLo42 (postSub_sound bodyPost42)
    (Nat.le_of_ble_eq_true bodyDrop42) (by decide) (Nat.le_of_ble_eq_true bodyDropH42) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN42) (by decide)
    bodyDv42 bodyDe42 bodyDl42 bodyDold42 bodyDfree42 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodySite43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_site43 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site43 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site43) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st43.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L7_r0_body.site43
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st43.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st43.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s971 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s972 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S971 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws43 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st43.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st43.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.iso43
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_43
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st43.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.stFoot43
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrNodup43
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrBound43
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.trace43
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.merged43
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws43.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st43.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S971.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_43]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.mergeLen43.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.fresh43
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl43 : Conv.NClean (⟨20883, 17976, 2782270, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s971.ffi).mlx :=
  PRE_first_tail_x4_L7_r0_body.gncl43 (PRE_first_tail_x4_L7_r0_body.cncl42 bodyNcl42)

theorem bodyClean43 : Conv.JClean (⟨20883, 17976, 2782270, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L7_r0_body.s971 :=
  PRE_first_tail_x4_L7_r0_body.gjcl43 (PRE_first_tail_x4_L7_r0_body.cjcl42 bodyClean42)

kernel_rfl bodyJsLe43 : Nat.ble PRE_first_tail_x4_L7_r0_body.s950.next PRE_first_tail_x4_L7_r0_body.s971.next = true
kernel_rfl bodyJsList43 : (PRE_first_tail_x4_L7_r0_body.gjh43 ++ PRE_first_tail_x4_L7_r0_body.cl43).all (noBigAtP (jsAboveB PRE_first_tail_x4_L7_r0_body.s971.next) PRE_first_tail_x4_L7_r0_body.s973) = true
theorem bodyJs43 : JsHeapAbove PRE_first_tail_x4_L7_r0_body.s971.next PRE_first_tail_x4_L7_r0_body.s973 :=
  JsHeapAbove.glueSite bodyJs42 (Nat.le_of_ble_eq_true bodyJsLe43) PRE_first_tail_x4_L7_r0_body.gjk43 PRE_first_tail_x4_L7_r0_body.gjbd43 PRE_first_tail_x4_L7_r0_body.cheap43 PRE_first_tail_x4_L7_r0_body.zclbd43 bodyJsList43

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyG43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO952 : PRE_first_tail_x4_L7_r0_body.S952.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S952.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr952 : bridgeOf PRE_first_tail_x4_L7_r0_body.s952.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyAcc952 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s952 PRE_first_tail_x4_L7_r0_body.S952) = fun _ _ => true
kernel_rfl bodyAcc953 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s953 PRE_first_tail_x4_L7_r0_body.S953) = fun _ _ => true
kernel_rfl bodyBr954 : bridgeOf PRE_first_tail_x4_L7_r0_body.s954.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt953 : isHalt PRE_first_tail_x4_L7_r0_body.s953.ctl = false
kernel_rfl bodyTop954 : noRetBlock PRE_first_tail_x4_L7_r0_body.s954 = true
kernel_rfl bodyCnt952 : countersOkB PRE_first_tail_x4_L7_r0_body.s952 PRE_first_tail_x4_L7_r0_body.s954 = true
kernel_rfl bodyO954 : PRE_first_tail_x4_L7_r0_body.S954.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S954.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr955 : bridgeOf PRE_first_tail_x4_L7_r0_body.s955.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt954 : countersOkB PRE_first_tail_x4_L7_r0_body.s954 PRE_first_tail_x4_L7_r0_body.s955 = true
kernel_rfl bodyO955 : PRE_first_tail_x4_L7_r0_body.S955.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S955.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc955 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s955 PRE_first_tail_x4_L7_r0_body.S955) = fun _ _ => true
kernel_rfl bodyAcc959 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s959 PRE_first_tail_x4_L7_r0_body.S959) = fun _ _ => true
kernel_rfl bodyBr960 : bridgeOf PRE_first_tail_x4_L7_r0_body.s960.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt959 : isHalt PRE_first_tail_x4_L7_r0_body.s959.ctl = false
kernel_rfl bodyTop960 : noRetBlock PRE_first_tail_x4_L7_r0_body.s960 = true
kernel_rfl bodyCnt955 : countersOkB PRE_first_tail_x4_L7_r0_body.s955 PRE_first_tail_x4_L7_r0_body.s960 = true
kernel_rfl bodyO960 : PRE_first_tail_x4_L7_r0_body.S960.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S960.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr961 : bridgeOf PRE_first_tail_x4_L7_r0_body.s961.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt960 : countersOkB PRE_first_tail_x4_L7_r0_body.s960 PRE_first_tail_x4_L7_r0_body.s961 = true
kernel_rfl bodyO961 : PRE_first_tail_x4_L7_r0_body.S961.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S961.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc961 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s961 PRE_first_tail_x4_L7_r0_body.S961) = fun _ _ => true
kernel_rfl bodyAcc963 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s963 PRE_first_tail_x4_L7_r0_body.S963) = fun _ _ => true
kernel_rfl bodyBr964 : bridgeOf PRE_first_tail_x4_L7_r0_body.s964.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt963 : isHalt PRE_first_tail_x4_L7_r0_body.s963.ctl = false
kernel_rfl bodyTop964 : noRetBlock PRE_first_tail_x4_L7_r0_body.s964 = true
kernel_rfl bodyCnt961 : countersOkB PRE_first_tail_x4_L7_r0_body.s961 PRE_first_tail_x4_L7_r0_body.s964 = true
kernel_rfl bodyO964 : PRE_first_tail_x4_L7_r0_body.S964.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S964.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr965 : bridgeOf PRE_first_tail_x4_L7_r0_body.s965.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt964 : countersOkB PRE_first_tail_x4_L7_r0_body.s964 PRE_first_tail_x4_L7_r0_body.s965 = true
kernel_rfl bodyO965 : PRE_first_tail_x4_L7_r0_body.S965.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S965.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc965 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s965 PRE_first_tail_x4_L7_r0_body.S965) = fun _ _ => true
kernel_rfl bodyAcc966 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s966 PRE_first_tail_x4_L7_r0_body.S966) = fun _ _ => true
kernel_rfl bodyBr967 : bridgeOf PRE_first_tail_x4_L7_r0_body.s967.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt966 : isHalt PRE_first_tail_x4_L7_r0_body.s966.ctl = false
kernel_rfl bodyTop967 : noRetBlock PRE_first_tail_x4_L7_r0_body.s967 = true
kernel_rfl bodyCnt965 : countersOkB PRE_first_tail_x4_L7_r0_body.s965 PRE_first_tail_x4_L7_r0_body.s967 = true
kernel_rfl bodyO967 : PRE_first_tail_x4_L7_r0_body.S967.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S967.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr968 : bridgeOf PRE_first_tail_x4_L7_r0_body.s968.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt967 : countersOkB PRE_first_tail_x4_L7_r0_body.s967 PRE_first_tail_x4_L7_r0_body.s968 = true
kernel_rfl bodyO968 : PRE_first_tail_x4_L7_r0_body.S968.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S968.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc968 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s968 PRE_first_tail_x4_L7_r0_body.S968) = fun _ _ => true
kernel_rfl bodyAcc970 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s970 PRE_first_tail_x4_L7_r0_body.S970) = fun _ _ => true
kernel_rfl bodyBr971 : bridgeOf PRE_first_tail_x4_L7_r0_body.s971.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt970 : isHalt PRE_first_tail_x4_L7_r0_body.s970.ctl = false
kernel_rfl bodyTop971 : noRetBlock PRE_first_tail_x4_L7_r0_body.s971 = true
kernel_rfl bodyCnt968 : countersOkB PRE_first_tail_x4_L7_r0_body.s968 PRE_first_tail_x4_L7_r0_body.s971 = true

theorem bodyGlue43 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨45531, 866, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s952 PRE_first_tail_x4_L7_r0_body.S952)
      (bodyCut NB T tk π i x0 bodyΘ ⟨45531, 866, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s971 PRE_first_tail_x4_L7_r0_body.S971) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) bodyAcc952 PRE_first_tail_x4_L7_r0_body.bodyRunSeg247 bodyAcc953 bodyHalt953 PRE_first_tail_x4_L7_r0_body.bodyStepA248 bodyTop954 (fun _ hm => bodyO952 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr952).trans bodyInactive0) (bodyBr954.trans bodyBr952.symm) bodyCnt952 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA248 PRE_first_tail_x4_L7_r0_body.sizeArgsA248 PRE_first_tail_x4_L7_r0_body.sizeSymA248 PRE_first_tail_x4_L7_r0_body.sizeMlxA248 PRE_first_tail_x4_L7_r0_body.sizePayA248 PRE_first_tail_x4_L7_r0_body.sizeTaA248 PRE_first_tail_x4_L7_r0_body.sizeDecA248 PRE_first_tail_x4_L7_r0_body.sizePreA248 PRE_first_tail_x4_L7_r0_body.bodyPatchB248 (fun _ hm => bodyO954 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr954).trans bodyInactive0) (bodyBr955.trans bodyBr954.symm) bodyCnt954 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) bodyAcc955 PRE_first_tail_x4_L7_r0_body.bodyRunSeg248 bodyAcc959 bodyHalt959 PRE_first_tail_x4_L7_r0_body.bodyStepA249 bodyTop960 (fun _ hm => bodyO955 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr955).trans bodyInactive0) (bodyBr960.trans bodyBr955.symm) bodyCnt955 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA249 PRE_first_tail_x4_L7_r0_body.sizeArgsA249 PRE_first_tail_x4_L7_r0_body.sizeSymA249 PRE_first_tail_x4_L7_r0_body.sizeMlxA249 PRE_first_tail_x4_L7_r0_body.sizePayA249 PRE_first_tail_x4_L7_r0_body.sizeTaA249 PRE_first_tail_x4_L7_r0_body.sizeDecA249 PRE_first_tail_x4_L7_r0_body.sizePreA249 PRE_first_tail_x4_L7_r0_body.bodyPatchB249 (fun _ hm => bodyO960 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr960).trans bodyInactive0) (bodyBr961.trans bodyBr960.symm) bodyCnt960 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) bodyAcc961 PRE_first_tail_x4_L7_r0_body.bodyRunSeg249 bodyAcc963 bodyHalt963 PRE_first_tail_x4_L7_r0_body.bodyStepA250 bodyTop964 (fun _ hm => bodyO961 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr961).trans bodyInactive0) (bodyBr964.trans bodyBr961.symm) bodyCnt961 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA250 PRE_first_tail_x4_L7_r0_body.sizeArgsA250 PRE_first_tail_x4_L7_r0_body.sizeSymA250 PRE_first_tail_x4_L7_r0_body.sizeMlxA250 PRE_first_tail_x4_L7_r0_body.sizePayA250 PRE_first_tail_x4_L7_r0_body.sizeTaA250 PRE_first_tail_x4_L7_r0_body.sizeDecA250 PRE_first_tail_x4_L7_r0_body.sizePreA250 PRE_first_tail_x4_L7_r0_body.bodyPatchB250 (fun _ hm => bodyO964 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr964).trans bodyInactive0) (bodyBr965.trans bodyBr964.symm) bodyCnt964 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) bodyAcc965 PRE_first_tail_x4_L7_r0_body.bodyRunSeg250 bodyAcc966 bodyHalt966 PRE_first_tail_x4_L7_r0_body.bodyStepA251 bodyTop967 (fun _ hm => bodyO965 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr965).trans bodyInactive0) (bodyBr967.trans bodyBr965.symm) bodyCnt965 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA251 PRE_first_tail_x4_L7_r0_body.sizeArgsA251 PRE_first_tail_x4_L7_r0_body.sizeSymA251 PRE_first_tail_x4_L7_r0_body.sizeMlxA251 PRE_first_tail_x4_L7_r0_body.sizePayA251 PRE_first_tail_x4_L7_r0_body.sizeTaA251 PRE_first_tail_x4_L7_r0_body.sizeDecA251 PRE_first_tail_x4_L7_r0_body.sizePreA251 PRE_first_tail_x4_L7_r0_body.bodyPatchB251 (fun _ hm => bodyO967 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr967).trans bodyInactive0) (bodyBr968.trans bodyBr967.symm) bodyCnt967 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45531, 866, 0, 0⟩) bodyAcc968 PRE_first_tail_x4_L7_r0_body.bodyRunSeg251 bodyAcc970 bodyHalt970 PRE_first_tail_x4_L7_r0_body.bodyStepA252 bodyTop971 (fun _ hm => bodyO968 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr968).trans bodyInactive0) (bodyBr971.trans bodyBr968.symm) bodyCnt968 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyS43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift43 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L7_r0_body.S971.tab.length PRE_first_tail_x4_L7_r0_body.s971.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L7_r0_body.P43.NL) : Conv.FullShiftQ PRE_first_tail_x4_L7_r0_body.P43 15 PRE_first_tail_x4_L7_r0_body.kappa43 PRE_first_tail_x4_L7_r0_body.s973.ffi PRE_first_tail_x4_L7_r0_body.s972.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L7_r0_body.ofxC_43
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L7_r0_body.okrC_43
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s973.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L7_r0_body.S971.tab.length) hr.cl (by rw [PRE_first_tail_x4_L7_r0_body.n0_43] <;> decide) PRE_first_tail_x4_L7_r0_body.cnodesK43 PRE_first_tail_x4_L7_r0_body.cobjsK43
      PRE_first_tail_x4_L7_r0_body.citemsK43 PRE_first_tail_x4_L7_r0_body.cbd43 PRE_first_tail_x4_L7_r0_body.csst43
  exact PRE_first_tail_x4_L7_r0_body.cshift43 bodyNcl43 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L7_r0_body.n0_43] at this; exact this)


kernel_rfl bodyFramesEmpty43 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L7_r0_body.s972 a).isEmpty) = true
kernel_rfl bodyJsRoots43 : noBigRootsP (jsAboveB PRE_first_tail_x4_L7_r0_body.s971.next) PRE_first_tail_x4_L7_r0_body.s973.trace PRE_first_tail_x4_L7_r0_body.s973 = true
kernel_rfl bodyJsNative43 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L7_r0_body.s973.ffi) = true
kernel_rfl bodyLow43 : (PRE_first_tail_x4_L7_r0_body.cws43 ++ PRE_first_tail_x4_L7_r0_body.ws43).all (Nat.ble 9) = true
kernel_rfl bodyCntM43 : countersOkB PRE_first_tail_x4_L7_r0_body.s971 PRE_first_tail_x4_L7_r0_body.s972 = true
kernel_rfl bodyHi43 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s973.ffi).next setupP.E = true
kernel_rfl bodyNhi43 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s973.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge43 : bridgeOf PRE_first_tail_x4_L7_r0_body.s972.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s971.ffi
kernel_rfl bodyNN43 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s971.ffi).nnext PRE_first_tail_x4_L7_r0_body.P43.NL = true
kernel_rfl bodyXn43 : Nat.ble (⟨20887, 17982, 2782285, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L7_r0_body.s973.ffi).next = true
kernel_rfl bodyLo43 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L7_r0_body.s973.ffi).next = true
theorem bodyFacts43 : BodySiteFacts PRE_first_tail_x4_L7_r0_body.s971 PRE_first_tail_x4_L7_r0_body.s972 PRE_first_tail_x4_L7_r0_body.s973 PRE_first_tail_x4_L7_r0_body.s0 PRE_first_tail_x4_L7_r0_body.S971 PRE_first_tail_x4_L7_r0_body.S972 PRE_first_tail_x4_L7_r0_body.S973
    PRE_first_tail_x4_L7_r0_body.ws43 PRE_first_tail_x4_L7_r0_body.cws43 PRE_first_tail_x4_L7_r0_body.nr43 PRE_first_tail_x4_L7_r0_body.pl43 PRE_first_tail_x4_L7_r0_body.cl43 2782635 15 PRE_first_tail_x4_L7_r0_body.kd43 PRE_first_tail_x4_L7_r0_body.kappa43 PRE_first_tail_x4_L7_r0_body.P43
    ⟨20883, 17976, 2782270, 15⟩ ⟨20887, 17982, 2782285, 15⟩ where
  zkap := PRE_first_tail_x4_L7_r0_body.zkap43
  clean := bodyClean43
  cfix := PRE_first_tail_x4_L7_r0_body.cfix43
  zpl := PRE_first_tail_x4_L7_r0_body.zpl43
  zplnd := PRE_first_tail_x4_L7_r0_body.zplnd43
  zn1 := PRE_first_tail_x4_L7_r0_body.zn143
  zfirst := PRE_first_tail_x4_L7_r0_body.zfirst43
  zscn := PRE_first_tail_x4_L7_r0_body.zscn43
  zsmn := PRE_first_tail_x4_L7_r0_body.zsmn43
  zgrow := PRE_first_tail_x4_L7_r0_body.zgrow43
  mergeTab := PRE_first_tail_x4_L7_r0_body.mergeTab43
  zfresh := PRE_first_tail_x4_L7_r0_body.zfresh43
  zcnd := PRE_first_tail_x4_L7_r0_body.zcnd43
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L7_r0_body.znrHi43
  zfrlt := PRE_first_tail_x4_L7_r0_body.zfrlt43
  zgP := PRE_first_tail_x4_L7_r0_body.zg43_2665
  zkP := PRE_first_tail_x4_L7_r0_body.zk43_2665
  zmP := PRE_first_tail_x4_L7_r0_body.zm43_2665
  zgC := PRE_first_tail_x4_L7_r0_body.zg43_2673467
  zkC := PRE_first_tail_x4_L7_r0_body.zk43_2673467
  zmC := PRE_first_tail_x4_L7_r0_body.zm43_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L7_r0_body.zw43_2673472
  zwV := PRE_first_tail_x4_L7_r0_body.zw43_2673473
  cheap := PRE_first_tail_x4_L7_r0_body.cheap43
  zclbd := PRE_first_tail_x4_L7_r0_body.zclbd43
  hml := hoff_of PRE_first_tail_x4_L7_r0_body.mheap43 PRE_first_tail_x4_L7_r0_body.stFoot43 PRE_first_tail_x4_L7_r0_body.iso43 PRE_first_tail_x4_L7_r0_body.zwr43
  ckeepP := PRE_first_tail_x4_L7_r0_body.ckeepP43
  csupp := PRE_first_tail_x4_L7_r0_body.csupp43
  cbound := PRE_first_tail_x4_L7_r0_body.cbound43
  zimg := PRE_first_tail_x4_L7_r0_body.zimg43
  zctl := PRE_first_tail_x4_L7_r0_body.zctl43
  zstack := PRE_first_tail_x4_L7_r0_body.zstack43
  zjobs := PRE_first_tail_x4_L7_r0_body.zjobs43
  zstores := PRE_first_tail_x4_L7_r0_body.zstores43
  zroots := PRE_first_tail_x4_L7_r0_body.zroots43
  znC := PRE_first_tail_x4_L7_r0_body.znC43
  ctab := PRE_first_tail_x4_L7_r0_body.ctab43
  zbin := PRE_first_tail_x4_L7_r0_body.zbin43
  cbridge := PRE_first_tail_x4_L7_r0_body.cbridge43
  sbridge := bodyBridge43
  cwsDisj := PRE_first_tail_x4_L7_r0_body.cwsDisj43
  cshiftR := fun h hNL => bodyCshift43 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN43
  raised := PRE_first_tail_x4_L7_r0_body.raised43
  cbigs := PRE_first_tail_x4_L7_r0_body.cbigs43
  cjcl := PRE_first_tail_x4_L7_r0_body.cjcl43
  xnLe := Nat.le_of_ble_eq_true bodyXn43
  loLe := Nat.le_of_ble_eq_true bodyLo43
  zroots2 := PRE_first_tail_x4_L7_r0_body.zrootsB43
  cntM := bodyCntM43
  hiLe := Nat.le_of_ble_eq_true bodyHi43
  nhiLe := Nat.le_of_ble_eq_true bodyNhi43
  jsHeap := bodyJs43
  jsRoots := bodyJsRoots43
  jsNative := bodyJsNative43
  framesEmpty := bodyFramesEmpty43
  trailOld := by decide
  lowVars := bodyLow43

def bodyQs43 : List (Option Q) := []
noncomputable def bodyEs43 : List (Option SymE) := PRE_first_tail_x4_L7_r0_body.nr43.map fun r => nth? PRE_first_tail_x4_L7_r0_body.st43.S3.tab r
kernel_rfl bodyResChk43 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs43 bodyQs43) = true
kernel_rfl bodyLq43 : bodyQs43.length = PRE_first_tail_x4_L7_r0_body.cws43.length
kernel_rfl bodyNrLo43 : PRE_first_tail_x4_L7_r0_body.nr43.all (Nat.ble PRE_first_tail_x4_L7_r0_body.S971.tab.length) = true
kernel_rfl bodySub43 : (Oracles.PRE_first_tail_x4_L7_r0_body.map_site43.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost43 : postSubB bodyM PRE_first_tail_x4_L7_r0_body.ws43 PRE_first_tail_x4_L7_r0_body.cws43 bodyQs43 = true
kernel_rfl bodyDrop43 : Nat.ble (45531 + (PRE_first_tail_x4_L7_r0_body.s972.next - PRE_first_tail_x4_L7_r0_body.s973.next)) 45881 = true
kernel_rfl bodyDropH43 : Nat.ble (866 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s972.ffi).next - (mlxOf PRE_first_tail_x4_L7_r0_body.s973.ffi).next)) 868 = true
kernel_rfl bodyDropN43 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s972.ffi).nnext - (mlxOf PRE_first_tail_x4_L7_r0_body.s973.ffi).nnext)) 0 = true
kernel_rfl bodyDv43 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L7_r0_body.cws43
kernel_rfl bodyDe43 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L7_r0_body.nr43.map (fun r =>
  ((nth? PRE_first_tail_x4_L7_r0_body.st43.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl43 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold43 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L7_r0_body.cws43).isNone && !PRE_first_tail_x4_L7_r0_body.ws43.contains v) = true
kernel_rfl bodyDfree43 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L7_r0_body.cws43 ++ PRE_first_tail_x4_L7_r0_body.ws43).all fun w => e.noVar w) = true

theorem bodyStep43 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨45531, 866, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s971 PRE_first_tail_x4_L7_r0_body.S971)
      (bodyCut NB T tk π i x0 bodyΘ ⟨45881, 868, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s973 PRE_first_tail_x4_L7_r0_body.S973) (3452 + 1) :=
  bodySite bodyFacts43.cfix bodyFacts43.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L7_r0_body.st43.S3.tab) (Es := bodyEs43) (qs := bodyQs43)
    (ok := PRE_first_tail_x4_L7_r0_body.st43.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L7_r0_body.site43 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts43
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L7_r0_body.chk_site43 r hr) hi (MapOk.sub hm (sub_of_all bodySub43)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk43 r hr) hi hm ho hq)
    bodyLq43 rfl bodyNrLo43 (postSub_sound bodyPost43)
    (Nat.le_of_ble_eq_true bodyDrop43) (by decide) (Nat.le_of_ble_eq_true bodyDropH43) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN43) (by decide)
    bodyDv43 bodyDe43 bodyDl43 bodyDold43 bodyDfree43 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyOracles_11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_g44 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_g44 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_g44) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.O))) = true

def PRE_first_tail_x4_L7_r0_body.map_site44 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site44 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site44) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st44.S0.oracle) = true

def PRE_first_tail_x4_L7_r0_body.map_g45 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_g45 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_g45) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.O))) = true

def PRE_first_tail_x4_L7_r0_body.map_site45 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site45 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site45) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st45.S0.oracle) = true

def PRE_first_tail_x4_L7_r0_body.map_g46 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_g46 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_g46) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.O))) = true

def PRE_first_tail_x4_L7_r0_body.map_site46 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site46 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site46) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st46.S0.oracle) = true

def PRE_first_tail_x4_L7_r0_body.map_g47 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_g47 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_g47) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.O))) = true

def PRE_first_tail_x4_L7_r0_body.map_site47 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site47 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site47) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st47.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_site44 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site44 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site44) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st44.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L7_r0_body.site44
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st44.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st44.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s995 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s996 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S995 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws44 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st44.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st44.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.iso44
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_44
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st44.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.stFoot44
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrNodup44
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrBound44
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.trace44
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.merged44
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws44.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st44.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S995.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_44]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.mergeLen44.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.fresh44
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl44 : Conv.NClean (⟨20955, 18028, 2785270, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s995.ffi).mlx :=
  PRE_first_tail_x4_L7_r0_body.gncl44 (PRE_first_tail_x4_L7_r0_body.cncl43 bodyNcl43)

theorem bodyClean44 : Conv.JClean (⟨20955, 18028, 2785270, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L7_r0_body.s995 :=
  PRE_first_tail_x4_L7_r0_body.gjcl44 (PRE_first_tail_x4_L7_r0_body.cjcl43 bodyClean43)

kernel_rfl bodyJsLe44 : Nat.ble PRE_first_tail_x4_L7_r0_body.s971.next PRE_first_tail_x4_L7_r0_body.s995.next = true
kernel_rfl bodyJsList44 : (PRE_first_tail_x4_L7_r0_body.gjh44 ++ PRE_first_tail_x4_L7_r0_body.cl44).all (noBigAtP (jsAboveB PRE_first_tail_x4_L7_r0_body.s995.next) PRE_first_tail_x4_L7_r0_body.s997) = true
theorem bodyJs44 : JsHeapAbove PRE_first_tail_x4_L7_r0_body.s995.next PRE_first_tail_x4_L7_r0_body.s997 :=
  JsHeapAbove.glueSite bodyJs43 (Nat.le_of_ble_eq_true bodyJsLe44) PRE_first_tail_x4_L7_r0_body.gjk44 PRE_first_tail_x4_L7_r0_body.gjbd44 PRE_first_tail_x4_L7_r0_body.cheap44 PRE_first_tail_x4_L7_r0_body.zclbd44 bodyJsList44

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyG44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO973 : PRE_first_tail_x4_L7_r0_body.S973.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S973.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr973 : bridgeOf PRE_first_tail_x4_L7_r0_body.s973.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyAcc973 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s973 PRE_first_tail_x4_L7_r0_body.S973) = fun _ _ => true
kernel_rfl bodyAcc976 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s976 PRE_first_tail_x4_L7_r0_body.S976) = fun _ _ => true
kernel_rfl bodyBr977 : bridgeOf PRE_first_tail_x4_L7_r0_body.s977.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt976 : isHalt PRE_first_tail_x4_L7_r0_body.s976.ctl = false
kernel_rfl bodyTop977 : noRetBlock PRE_first_tail_x4_L7_r0_body.s977 = true
kernel_rfl bodyCnt973 : countersOkB PRE_first_tail_x4_L7_r0_body.s973 PRE_first_tail_x4_L7_r0_body.s977 = true
kernel_rfl bodyO977 : PRE_first_tail_x4_L7_r0_body.S977.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S977.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr978 : bridgeOf PRE_first_tail_x4_L7_r0_body.s978.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt977 : countersOkB PRE_first_tail_x4_L7_r0_body.s977 PRE_first_tail_x4_L7_r0_body.s978 = true
kernel_rfl bodyO978 : PRE_first_tail_x4_L7_r0_body.S978.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S978.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc978 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s978 PRE_first_tail_x4_L7_r0_body.S978) = fun _ _ => true
kernel_rfl bodyAcc982 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s982 PRE_first_tail_x4_L7_r0_body.S982) = fun _ _ => true
kernel_rfl bodyBr983 : bridgeOf PRE_first_tail_x4_L7_r0_body.s983.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt982 : isHalt PRE_first_tail_x4_L7_r0_body.s982.ctl = false
kernel_rfl bodyTop983 : noRetBlock PRE_first_tail_x4_L7_r0_body.s983 = true
kernel_rfl bodyCnt978 : countersOkB PRE_first_tail_x4_L7_r0_body.s978 PRE_first_tail_x4_L7_r0_body.s983 = true
kernel_rfl bodyO983 : PRE_first_tail_x4_L7_r0_body.S983.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S983.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr984 : bridgeOf PRE_first_tail_x4_L7_r0_body.s984.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt983 : countersOkB PRE_first_tail_x4_L7_r0_body.s983 PRE_first_tail_x4_L7_r0_body.s984 = true
kernel_rfl bodyO984 : PRE_first_tail_x4_L7_r0_body.S984.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S984.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc984 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s984 PRE_first_tail_x4_L7_r0_body.S984) = fun _ _ => true
kernel_rfl bodyAcc985 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s985 PRE_first_tail_x4_L7_r0_body.S985) = fun _ _ => true
kernel_rfl bodyBr986 : bridgeOf PRE_first_tail_x4_L7_r0_body.s986.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt985 : isHalt PRE_first_tail_x4_L7_r0_body.s985.ctl = false
kernel_rfl bodyTop986 : noRetBlock PRE_first_tail_x4_L7_r0_body.s986 = true
kernel_rfl bodyCnt984 : countersOkB PRE_first_tail_x4_L7_r0_body.s984 PRE_first_tail_x4_L7_r0_body.s986 = true
kernel_rfl bodyO986 : PRE_first_tail_x4_L7_r0_body.S986.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S986.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr987 : bridgeOf PRE_first_tail_x4_L7_r0_body.s987.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt986 : countersOkB PRE_first_tail_x4_L7_r0_body.s986 PRE_first_tail_x4_L7_r0_body.s987 = true
kernel_rfl bodyO987 : PRE_first_tail_x4_L7_r0_body.S987.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S987.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc987 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s987 PRE_first_tail_x4_L7_r0_body.S987) = fun _ _ => true
kernel_rfl bodyAcc988 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s988 PRE_first_tail_x4_L7_r0_body.S988) = fun _ _ => true
kernel_rfl bodyBr989 : bridgeOf PRE_first_tail_x4_L7_r0_body.s989.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt988 : isHalt PRE_first_tail_x4_L7_r0_body.s988.ctl = false
kernel_rfl bodyTop989 : noRetBlock PRE_first_tail_x4_L7_r0_body.s989 = true
kernel_rfl bodyCnt987 : countersOkB PRE_first_tail_x4_L7_r0_body.s987 PRE_first_tail_x4_L7_r0_body.s989 = true
kernel_rfl bodyO989 : PRE_first_tail_x4_L7_r0_body.S989.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S989.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr990 : bridgeOf PRE_first_tail_x4_L7_r0_body.s990.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt989 : countersOkB PRE_first_tail_x4_L7_r0_body.s989 PRE_first_tail_x4_L7_r0_body.s990 = true
kernel_rfl bodyO990 : PRE_first_tail_x4_L7_r0_body.S990.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S990.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc990 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s990 PRE_first_tail_x4_L7_r0_body.S990) = fun _ _ => true
kernel_rfl bodyAcc991 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s991 PRE_first_tail_x4_L7_r0_body.S991) = fun _ _ => true
kernel_rfl bodyBr992 : bridgeOf PRE_first_tail_x4_L7_r0_body.s992.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt991 : isHalt PRE_first_tail_x4_L7_r0_body.s991.ctl = false
kernel_rfl bodyTop992 : noRetBlock PRE_first_tail_x4_L7_r0_body.s992 = true
kernel_rfl bodyCnt990 : countersOkB PRE_first_tail_x4_L7_r0_body.s990 PRE_first_tail_x4_L7_r0_body.s992 = true
kernel_rfl bodyO992 : PRE_first_tail_x4_L7_r0_body.S992.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S992.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr993 : bridgeOf PRE_first_tail_x4_L7_r0_body.s993.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt992 : countersOkB PRE_first_tail_x4_L7_r0_body.s992 PRE_first_tail_x4_L7_r0_body.s993 = true
kernel_rfl bodyO993 : PRE_first_tail_x4_L7_r0_body.S993.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S993.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc993 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s993 PRE_first_tail_x4_L7_r0_body.S993) = fun _ _ => true
kernel_rfl bodyAcc994 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s994 PRE_first_tail_x4_L7_r0_body.S994) = fun _ _ => true
kernel_rfl bodyBr995 : bridgeOf PRE_first_tail_x4_L7_r0_body.s995.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt994 : isHalt PRE_first_tail_x4_L7_r0_body.s994.ctl = false
kernel_rfl bodyTop995 : noRetBlock PRE_first_tail_x4_L7_r0_body.s995 = true
kernel_rfl bodyCnt993 : countersOkB PRE_first_tail_x4_L7_r0_body.s993 PRE_first_tail_x4_L7_r0_body.s995 = true

theorem bodyGlue44 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨45881, 868, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s973 PRE_first_tail_x4_L7_r0_body.S973)
      (bodyCut NB T tk π i x0 bodyΘ ⟨45881, 868, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s995 PRE_first_tail_x4_L7_r0_body.S995) 30169 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) bodyAcc973 PRE_first_tail_x4_L7_r0_body.bodyRunSeg252 bodyAcc976 bodyHalt976 PRE_first_tail_x4_L7_r0_body.bodyStepA253 bodyTop977 (fun _ hm => bodyO973 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr973).trans bodyInactive0) (bodyBr977.trans bodyBr973.symm) bodyCnt973 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA253 PRE_first_tail_x4_L7_r0_body.sizeArgsA253 PRE_first_tail_x4_L7_r0_body.sizeSymA253 PRE_first_tail_x4_L7_r0_body.sizeMlxA253 PRE_first_tail_x4_L7_r0_body.sizePayA253 PRE_first_tail_x4_L7_r0_body.sizeTaA253 PRE_first_tail_x4_L7_r0_body.sizeDecA253 PRE_first_tail_x4_L7_r0_body.sizePreA253 PRE_first_tail_x4_L7_r0_body.bodyPatchB253 (fun _ hm => bodyO977 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr977).trans bodyInactive0) (bodyBr978.trans bodyBr977.symm) bodyCnt977 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) bodyAcc978 PRE_first_tail_x4_L7_r0_body.bodyRunSeg253 bodyAcc982 bodyHalt982 PRE_first_tail_x4_L7_r0_body.bodyStepA254 bodyTop983 (fun _ hm => bodyO978 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr978).trans bodyInactive0) (bodyBr983.trans bodyBr978.symm) bodyCnt978 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA254 PRE_first_tail_x4_L7_r0_body.sizeArgsA254 PRE_first_tail_x4_L7_r0_body.sizeSymA254 PRE_first_tail_x4_L7_r0_body.sizeMlxA254 PRE_first_tail_x4_L7_r0_body.sizePayA254 PRE_first_tail_x4_L7_r0_body.sizeTaA254 PRE_first_tail_x4_L7_r0_body.sizeDecA254 PRE_first_tail_x4_L7_r0_body.sizePreA254 PRE_first_tail_x4_L7_r0_body.bodyPatchB254 (fun _ hm => bodyO983 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr983).trans bodyInactive0) (bodyBr984.trans bodyBr983.symm) bodyCnt983 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) bodyAcc984 PRE_first_tail_x4_L7_r0_body.bodyRunSeg254 bodyAcc985 bodyHalt985 PRE_first_tail_x4_L7_r0_body.bodyStepA255 bodyTop986 (fun _ hm => bodyO984 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr984).trans bodyInactive0) (bodyBr986.trans bodyBr984.symm) bodyCnt984 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA255 PRE_first_tail_x4_L7_r0_body.sizeArgsA255 PRE_first_tail_x4_L7_r0_body.sizeSymA255 PRE_first_tail_x4_L7_r0_body.sizeMlxA255 PRE_first_tail_x4_L7_r0_body.sizePayA255 PRE_first_tail_x4_L7_r0_body.sizeTaA255 PRE_first_tail_x4_L7_r0_body.sizeDecA255 PRE_first_tail_x4_L7_r0_body.sizePreA255 PRE_first_tail_x4_L7_r0_body.bodyPatchB255 (fun _ hm => bodyO986 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr986).trans bodyInactive0) (bodyBr987.trans bodyBr986.symm) bodyCnt986 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) bodyAcc987 PRE_first_tail_x4_L7_r0_body.bodyRunSeg255 bodyAcc988 bodyHalt988 PRE_first_tail_x4_L7_r0_body.bodyStepA256 bodyTop989 (fun _ hm => bodyO987 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr987).trans bodyInactive0) (bodyBr989.trans bodyBr987.symm) bodyCnt987 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA256 PRE_first_tail_x4_L7_r0_body.sizeArgsA256 PRE_first_tail_x4_L7_r0_body.sizeSymA256 PRE_first_tail_x4_L7_r0_body.sizeMlxA256 PRE_first_tail_x4_L7_r0_body.sizePayA256 PRE_first_tail_x4_L7_r0_body.sizeTaA256 PRE_first_tail_x4_L7_r0_body.sizeDecA256 PRE_first_tail_x4_L7_r0_body.sizePreA256 PRE_first_tail_x4_L7_r0_body.bodyPatchB256 (fun _ hm => bodyO989 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr989).trans bodyInactive0) (bodyBr990.trans bodyBr989.symm) bodyCnt989 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) bodyAcc990 PRE_first_tail_x4_L7_r0_body.bodyRunSeg256 bodyAcc991 bodyHalt991 PRE_first_tail_x4_L7_r0_body.bodyStepA257 bodyTop992 (fun _ hm => bodyO990 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr990).trans bodyInactive0) (bodyBr992.trans bodyBr990.symm) bodyCnt990 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA257 PRE_first_tail_x4_L7_r0_body.sizeArgsA257 PRE_first_tail_x4_L7_r0_body.sizeSymA257 PRE_first_tail_x4_L7_r0_body.sizeMlxA257 PRE_first_tail_x4_L7_r0_body.sizePayA257 PRE_first_tail_x4_L7_r0_body.sizeTaA257 PRE_first_tail_x4_L7_r0_body.sizeDecA257 PRE_first_tail_x4_L7_r0_body.sizePreA257 PRE_first_tail_x4_L7_r0_body.bodyPatchB257 (fun _ hm => bodyO992 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr992).trans bodyInactive0) (bodyBr993.trans bodyBr992.symm) bodyCnt992 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨45881, 868, 0, 0⟩) bodyAcc993 PRE_first_tail_x4_L7_r0_body.bodyRunSeg257 bodyAcc994 bodyHalt994 PRE_first_tail_x4_L7_r0_body.bodyStepA258 bodyTop995 (fun _ hm => bodyO993 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr993).trans bodyInactive0) (bodyBr995.trans bodyBr993.symm) bodyCnt993 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyS44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift44 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L7_r0_body.S995.tab.length PRE_first_tail_x4_L7_r0_body.s995.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L7_r0_body.P44.NL) : Conv.FullShiftQ PRE_first_tail_x4_L7_r0_body.P44 15 PRE_first_tail_x4_L7_r0_body.kappa44 PRE_first_tail_x4_L7_r0_body.s997.ffi PRE_first_tail_x4_L7_r0_body.s996.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L7_r0_body.ofxC_44
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L7_r0_body.okrC_44
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s997.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L7_r0_body.S995.tab.length) hr.cl (by rw [PRE_first_tail_x4_L7_r0_body.n0_44] <;> decide) PRE_first_tail_x4_L7_r0_body.cnodesK44 PRE_first_tail_x4_L7_r0_body.cobjsK44
      PRE_first_tail_x4_L7_r0_body.citemsK44 PRE_first_tail_x4_L7_r0_body.cbd44 PRE_first_tail_x4_L7_r0_body.csst44
  exact PRE_first_tail_x4_L7_r0_body.cshift44 bodyNcl44 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L7_r0_body.n0_44] at this; exact this)


kernel_rfl bodyFramesEmpty44 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L7_r0_body.s996 a).isEmpty) = true
kernel_rfl bodyJsRoots44 : noBigRootsP (jsAboveB PRE_first_tail_x4_L7_r0_body.s995.next) PRE_first_tail_x4_L7_r0_body.s997.trace PRE_first_tail_x4_L7_r0_body.s997 = true
kernel_rfl bodyJsNative44 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L7_r0_body.s997.ffi) = true
kernel_rfl bodyLow44 : (PRE_first_tail_x4_L7_r0_body.cws44 ++ PRE_first_tail_x4_L7_r0_body.ws44).all (Nat.ble 9) = true
kernel_rfl bodyCntM44 : countersOkB PRE_first_tail_x4_L7_r0_body.s995 PRE_first_tail_x4_L7_r0_body.s996 = true
kernel_rfl bodyHi44 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s997.ffi).next setupP.E = true
kernel_rfl bodyNhi44 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s997.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge44 : bridgeOf PRE_first_tail_x4_L7_r0_body.s996.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s995.ffi
kernel_rfl bodyNN44 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s995.ffi).nnext PRE_first_tail_x4_L7_r0_body.P44.NL = true
kernel_rfl bodyXn44 : Nat.ble (⟨20958, 18055, 2785276, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L7_r0_body.s997.ffi).next = true
kernel_rfl bodyLo44 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L7_r0_body.s997.ffi).next = true
theorem bodyFacts44 : BodySiteFacts PRE_first_tail_x4_L7_r0_body.s995 PRE_first_tail_x4_L7_r0_body.s996 PRE_first_tail_x4_L7_r0_body.s997 PRE_first_tail_x4_L7_r0_body.s0 PRE_first_tail_x4_L7_r0_body.S995 PRE_first_tail_x4_L7_r0_body.S996 PRE_first_tail_x4_L7_r0_body.S997
    PRE_first_tail_x4_L7_r0_body.ws44 PRE_first_tail_x4_L7_r0_body.cws44 PRE_first_tail_x4_L7_r0_body.nr44 PRE_first_tail_x4_L7_r0_body.pl44 PRE_first_tail_x4_L7_r0_body.cl44 2786425 15 PRE_first_tail_x4_L7_r0_body.kd44 PRE_first_tail_x4_L7_r0_body.kappa44 PRE_first_tail_x4_L7_r0_body.P44
    ⟨20955, 18028, 2785270, 15⟩ ⟨20958, 18055, 2785276, 15⟩ where
  zkap := PRE_first_tail_x4_L7_r0_body.zkap44
  clean := bodyClean44
  cfix := PRE_first_tail_x4_L7_r0_body.cfix44
  zpl := PRE_first_tail_x4_L7_r0_body.zpl44
  zplnd := PRE_first_tail_x4_L7_r0_body.zplnd44
  zn1 := PRE_first_tail_x4_L7_r0_body.zn144
  zfirst := PRE_first_tail_x4_L7_r0_body.zfirst44
  zscn := PRE_first_tail_x4_L7_r0_body.zscn44
  zsmn := PRE_first_tail_x4_L7_r0_body.zsmn44
  zgrow := PRE_first_tail_x4_L7_r0_body.zgrow44
  mergeTab := PRE_first_tail_x4_L7_r0_body.mergeTab44
  zfresh := PRE_first_tail_x4_L7_r0_body.zfresh44
  zcnd := PRE_first_tail_x4_L7_r0_body.zcnd44
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L7_r0_body.znrHi44
  zfrlt := PRE_first_tail_x4_L7_r0_body.zfrlt44
  zgP := PRE_first_tail_x4_L7_r0_body.zg44_2665
  zkP := PRE_first_tail_x4_L7_r0_body.zk44_2665
  zmP := PRE_first_tail_x4_L7_r0_body.zm44_2665
  zgC := PRE_first_tail_x4_L7_r0_body.zg44_2673467
  zkC := PRE_first_tail_x4_L7_r0_body.zk44_2673467
  zmC := PRE_first_tail_x4_L7_r0_body.zm44_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L7_r0_body.zw44_2673472
  zwV := PRE_first_tail_x4_L7_r0_body.zw44_2673473
  cheap := PRE_first_tail_x4_L7_r0_body.cheap44
  zclbd := PRE_first_tail_x4_L7_r0_body.zclbd44
  hml := hoff_of PRE_first_tail_x4_L7_r0_body.mheap44 PRE_first_tail_x4_L7_r0_body.stFoot44 PRE_first_tail_x4_L7_r0_body.iso44 PRE_first_tail_x4_L7_r0_body.zwr44
  ckeepP := PRE_first_tail_x4_L7_r0_body.ckeepP44
  csupp := PRE_first_tail_x4_L7_r0_body.csupp44
  cbound := PRE_first_tail_x4_L7_r0_body.cbound44
  zimg := PRE_first_tail_x4_L7_r0_body.zimg44
  zctl := PRE_first_tail_x4_L7_r0_body.zctl44
  zstack := PRE_first_tail_x4_L7_r0_body.zstack44
  zjobs := PRE_first_tail_x4_L7_r0_body.zjobs44
  zstores := PRE_first_tail_x4_L7_r0_body.zstores44
  zroots := PRE_first_tail_x4_L7_r0_body.zroots44
  znC := PRE_first_tail_x4_L7_r0_body.znC44
  ctab := PRE_first_tail_x4_L7_r0_body.ctab44
  zbin := PRE_first_tail_x4_L7_r0_body.zbin44
  cbridge := PRE_first_tail_x4_L7_r0_body.cbridge44
  sbridge := bodyBridge44
  cwsDisj := PRE_first_tail_x4_L7_r0_body.cwsDisj44
  cshiftR := fun h hNL => bodyCshift44 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN44
  raised := PRE_first_tail_x4_L7_r0_body.raised44
  cbigs := PRE_first_tail_x4_L7_r0_body.cbigs44
  cjcl := PRE_first_tail_x4_L7_r0_body.cjcl44
  xnLe := Nat.le_of_ble_eq_true bodyXn44
  loLe := Nat.le_of_ble_eq_true bodyLo44
  zroots2 := PRE_first_tail_x4_L7_r0_body.zrootsB44
  cntM := bodyCntM44
  hiLe := Nat.le_of_ble_eq_true bodyHi44
  nhiLe := Nat.le_of_ble_eq_true bodyNhi44
  jsHeap := bodyJs44
  jsRoots := bodyJsRoots44
  jsNative := bodyJsNative44
  framesEmpty := bodyFramesEmpty44
  trailOld := by decide
  lowVars := bodyLow44

def bodyQs44 : List (Option Q) := []
noncomputable def bodyEs44 : List (Option SymE) := PRE_first_tail_x4_L7_r0_body.nr44.map fun r => nth? PRE_first_tail_x4_L7_r0_body.st44.S5.tab r
kernel_rfl bodyResChk44 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs44 bodyQs44) = true
kernel_rfl bodyLq44 : bodyQs44.length = PRE_first_tail_x4_L7_r0_body.cws44.length
kernel_rfl bodyNrLo44 : PRE_first_tail_x4_L7_r0_body.nr44.all (Nat.ble PRE_first_tail_x4_L7_r0_body.S995.tab.length) = true
kernel_rfl bodySub44 : (Oracles.PRE_first_tail_x4_L7_r0_body.map_site44.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost44 : postSubB bodyM PRE_first_tail_x4_L7_r0_body.ws44 PRE_first_tail_x4_L7_r0_body.cws44 bodyQs44 = true
kernel_rfl bodyDrop44 : Nat.ble (45881 + (PRE_first_tail_x4_L7_r0_body.s996.next - PRE_first_tail_x4_L7_r0_body.s997.next)) 47030 = true
kernel_rfl bodyDropH44 : Nat.ble (868 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s996.ffi).next - (mlxOf PRE_first_tail_x4_L7_r0_body.s997.ffi).next)) 893 = true
kernel_rfl bodyDropN44 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s996.ffi).nnext - (mlxOf PRE_first_tail_x4_L7_r0_body.s997.ffi).nnext)) 0 = true
kernel_rfl bodyDv44 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L7_r0_body.cws44
kernel_rfl bodyDe44 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L7_r0_body.nr44.map (fun r =>
  ((nth? PRE_first_tail_x4_L7_r0_body.st44.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl44 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold44 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L7_r0_body.cws44).isNone && !PRE_first_tail_x4_L7_r0_body.ws44.contains v) = true
kernel_rfl bodyDfree44 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L7_r0_body.cws44 ++ PRE_first_tail_x4_L7_r0_body.ws44).all fun w => e.noVar w) = true

theorem bodyStep44 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨45881, 868, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s995 PRE_first_tail_x4_L7_r0_body.S995)
      (bodyCut NB T tk π i x0 bodyΘ ⟨47030, 893, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s997 PRE_first_tail_x4_L7_r0_body.S997) (11334 + 1) :=
  bodySite bodyFacts44.cfix bodyFacts44.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L7_r0_body.st44.S5.tab) (Es := bodyEs44) (qs := bodyQs44)
    (ok := PRE_first_tail_x4_L7_r0_body.st44.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L7_r0_body.site44 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts44
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L7_r0_body.chk_site44 r hr) hi (MapOk.sub hm (sub_of_all bodySub44)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk44 r hr) hi hm ho hq)
    bodyLq44 rfl bodyNrLo44 (postSub_sound bodyPost44)
    (Nat.le_of_ble_eq_true bodyDrop44) (by decide) (Nat.le_of_ble_eq_true bodyDropH44) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN44) (by decide)
    bodyDv44 bodyDe44 bodyDl44 bodyDold44 bodyDfree44 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodySite45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_site45 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site45 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site45) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st45.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L7_r0_body.site45
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st45.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st45.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s1017 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s1018 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S1017 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws45 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st45.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st45.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.iso45
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_45
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st45.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.stFoot45
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrNodup45
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrBound45
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.trace45
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.merged45
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws45.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st45.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S1017.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_45]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.mergeLen45.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.fresh45
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl45 : Conv.NClean (⟨21012, 18091, 2787508, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s1017.ffi).mlx :=
  PRE_first_tail_x4_L7_r0_body.gncl45 (PRE_first_tail_x4_L7_r0_body.cncl44 bodyNcl44)

theorem bodyClean45 : Conv.JClean (⟨21012, 18091, 2787508, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L7_r0_body.s1017 :=
  PRE_first_tail_x4_L7_r0_body.gjcl45 (PRE_first_tail_x4_L7_r0_body.cjcl44 bodyClean44)

kernel_rfl bodyJsLe45 : Nat.ble PRE_first_tail_x4_L7_r0_body.s995.next PRE_first_tail_x4_L7_r0_body.s1017.next = true
kernel_rfl bodyJsList45 : (PRE_first_tail_x4_L7_r0_body.gjh45 ++ PRE_first_tail_x4_L7_r0_body.cl45).all (noBigAtP (jsAboveB PRE_first_tail_x4_L7_r0_body.s1017.next) PRE_first_tail_x4_L7_r0_body.s1019) = true
theorem bodyJs45 : JsHeapAbove PRE_first_tail_x4_L7_r0_body.s1017.next PRE_first_tail_x4_L7_r0_body.s1019 :=
  JsHeapAbove.glueSite bodyJs44 (Nat.le_of_ble_eq_true bodyJsLe45) PRE_first_tail_x4_L7_r0_body.gjk45 PRE_first_tail_x4_L7_r0_body.gjbd45 PRE_first_tail_x4_L7_r0_body.cheap45 PRE_first_tail_x4_L7_r0_body.zclbd45 bodyJsList45

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyG45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO997 : PRE_first_tail_x4_L7_r0_body.S997.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S997.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr997 : bridgeOf PRE_first_tail_x4_L7_r0_body.s997.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyAcc997 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s997 PRE_first_tail_x4_L7_r0_body.S997) = fun _ _ => true
kernel_rfl bodyAcc998 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s998 PRE_first_tail_x4_L7_r0_body.S998) = fun _ _ => true
kernel_rfl bodyBr999 : bridgeOf PRE_first_tail_x4_L7_r0_body.s999.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt998 : isHalt PRE_first_tail_x4_L7_r0_body.s998.ctl = false
kernel_rfl bodyTop999 : noRetBlock PRE_first_tail_x4_L7_r0_body.s999 = true
kernel_rfl bodyCnt997 : countersOkB PRE_first_tail_x4_L7_r0_body.s997 PRE_first_tail_x4_L7_r0_body.s999 = true
kernel_rfl bodyO999 : PRE_first_tail_x4_L7_r0_body.S999.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S999.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1000 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1000.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt999 : countersOkB PRE_first_tail_x4_L7_r0_body.s999 PRE_first_tail_x4_L7_r0_body.s1000 = true
kernel_rfl bodyO1000 : PRE_first_tail_x4_L7_r0_body.S1000.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1000.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1000 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1000 PRE_first_tail_x4_L7_r0_body.S1000) = fun _ _ => true
kernel_rfl bodyAcc1004 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1004 PRE_first_tail_x4_L7_r0_body.S1004) = fun _ _ => true
kernel_rfl bodyBr1005 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1005.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1004 : isHalt PRE_first_tail_x4_L7_r0_body.s1004.ctl = false
kernel_rfl bodyTop1005 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1005 = true
kernel_rfl bodyCnt1000 : countersOkB PRE_first_tail_x4_L7_r0_body.s1000 PRE_first_tail_x4_L7_r0_body.s1005 = true
kernel_rfl bodyO1005 : PRE_first_tail_x4_L7_r0_body.S1005.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1005.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1006 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1006.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1005 : countersOkB PRE_first_tail_x4_L7_r0_body.s1005 PRE_first_tail_x4_L7_r0_body.s1006 = true
kernel_rfl bodyO1006 : PRE_first_tail_x4_L7_r0_body.S1006.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1006.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1006 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1006 PRE_first_tail_x4_L7_r0_body.S1006) = fun _ _ => true
kernel_rfl bodyAcc1007 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1007 PRE_first_tail_x4_L7_r0_body.S1007) = fun _ _ => true
kernel_rfl bodyBr1008 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1008.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1007 : isHalt PRE_first_tail_x4_L7_r0_body.s1007.ctl = false
kernel_rfl bodyTop1008 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1008 = true
kernel_rfl bodyCnt1006 : countersOkB PRE_first_tail_x4_L7_r0_body.s1006 PRE_first_tail_x4_L7_r0_body.s1008 = true
kernel_rfl bodyO1008 : PRE_first_tail_x4_L7_r0_body.S1008.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1008.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1009 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1009.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1008 : countersOkB PRE_first_tail_x4_L7_r0_body.s1008 PRE_first_tail_x4_L7_r0_body.s1009 = true
kernel_rfl bodyO1009 : PRE_first_tail_x4_L7_r0_body.S1009.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1009.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1009 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1009 PRE_first_tail_x4_L7_r0_body.S1009) = fun _ _ => true
kernel_rfl bodyAcc1010 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1010 PRE_first_tail_x4_L7_r0_body.S1010) = fun _ _ => true
kernel_rfl bodyBr1011 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1011.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1010 : isHalt PRE_first_tail_x4_L7_r0_body.s1010.ctl = false
kernel_rfl bodyTop1011 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1011 = true
kernel_rfl bodyCnt1009 : countersOkB PRE_first_tail_x4_L7_r0_body.s1009 PRE_first_tail_x4_L7_r0_body.s1011 = true
kernel_rfl bodyO1011 : PRE_first_tail_x4_L7_r0_body.S1011.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1011.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1012 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1012.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1011 : countersOkB PRE_first_tail_x4_L7_r0_body.s1011 PRE_first_tail_x4_L7_r0_body.s1012 = true
kernel_rfl bodyO1012 : PRE_first_tail_x4_L7_r0_body.S1012.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1012.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1012 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1012 PRE_first_tail_x4_L7_r0_body.S1012) = fun _ _ => true
kernel_rfl bodyAcc1013 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1013 PRE_first_tail_x4_L7_r0_body.S1013) = fun _ _ => true
kernel_rfl bodyBr1014 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1014.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1013 : isHalt PRE_first_tail_x4_L7_r0_body.s1013.ctl = false
kernel_rfl bodyTop1014 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1014 = true
kernel_rfl bodyCnt1012 : countersOkB PRE_first_tail_x4_L7_r0_body.s1012 PRE_first_tail_x4_L7_r0_body.s1014 = true
kernel_rfl bodyO1014 : PRE_first_tail_x4_L7_r0_body.S1014.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1014.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1015 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1015.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1014 : countersOkB PRE_first_tail_x4_L7_r0_body.s1014 PRE_first_tail_x4_L7_r0_body.s1015 = true
kernel_rfl bodyO1015 : PRE_first_tail_x4_L7_r0_body.S1015.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1015.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1015 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1015 PRE_first_tail_x4_L7_r0_body.S1015) = fun _ _ => true
kernel_rfl bodyAcc1016 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1016 PRE_first_tail_x4_L7_r0_body.S1016) = fun _ _ => true
kernel_rfl bodyBr1017 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1017.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1016 : isHalt PRE_first_tail_x4_L7_r0_body.s1016.ctl = false
kernel_rfl bodyTop1017 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1017 = true
kernel_rfl bodyCnt1015 : countersOkB PRE_first_tail_x4_L7_r0_body.s1015 PRE_first_tail_x4_L7_r0_body.s1017 = true

theorem bodyGlue45 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨47030, 893, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s997 PRE_first_tail_x4_L7_r0_body.S997)
      (bodyCut NB T tk π i x0 bodyΘ ⟨47030, 893, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1017 PRE_first_tail_x4_L7_r0_body.S1017) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) bodyAcc997 PRE_first_tail_x4_L7_r0_body.bodyRunSeg258 bodyAcc998 bodyHalt998 PRE_first_tail_x4_L7_r0_body.bodyStepA259 bodyTop999 (fun _ hm => bodyO997 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr997).trans bodyInactive0) (bodyBr999.trans bodyBr997.symm) bodyCnt997 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA259 PRE_first_tail_x4_L7_r0_body.sizeArgsA259 PRE_first_tail_x4_L7_r0_body.sizeSymA259 PRE_first_tail_x4_L7_r0_body.sizeMlxA259 PRE_first_tail_x4_L7_r0_body.sizePayA259 PRE_first_tail_x4_L7_r0_body.sizeTaA259 PRE_first_tail_x4_L7_r0_body.sizeDecA259 PRE_first_tail_x4_L7_r0_body.sizePreA259 PRE_first_tail_x4_L7_r0_body.bodyPatchB259 (fun _ hm => bodyO999 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr999).trans bodyInactive0) (bodyBr1000.trans bodyBr999.symm) bodyCnt999 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) bodyAcc1000 PRE_first_tail_x4_L7_r0_body.bodyRunSeg259 bodyAcc1004 bodyHalt1004 PRE_first_tail_x4_L7_r0_body.bodyStepA260 bodyTop1005 (fun _ hm => bodyO1000 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1000).trans bodyInactive0) (bodyBr1005.trans bodyBr1000.symm) bodyCnt1000 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA260 PRE_first_tail_x4_L7_r0_body.sizeArgsA260 PRE_first_tail_x4_L7_r0_body.sizeSymA260 PRE_first_tail_x4_L7_r0_body.sizeMlxA260 PRE_first_tail_x4_L7_r0_body.sizePayA260 PRE_first_tail_x4_L7_r0_body.sizeTaA260 PRE_first_tail_x4_L7_r0_body.sizeDecA260 PRE_first_tail_x4_L7_r0_body.sizePreA260 PRE_first_tail_x4_L7_r0_body.bodyPatchB260 (fun _ hm => bodyO1005 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1005).trans bodyInactive0) (bodyBr1006.trans bodyBr1005.symm) bodyCnt1005 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) bodyAcc1006 PRE_first_tail_x4_L7_r0_body.bodyRunSeg260 bodyAcc1007 bodyHalt1007 PRE_first_tail_x4_L7_r0_body.bodyStepA261 bodyTop1008 (fun _ hm => bodyO1006 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1006).trans bodyInactive0) (bodyBr1008.trans bodyBr1006.symm) bodyCnt1006 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA261 PRE_first_tail_x4_L7_r0_body.sizeArgsA261 PRE_first_tail_x4_L7_r0_body.sizeSymA261 PRE_first_tail_x4_L7_r0_body.sizeMlxA261 PRE_first_tail_x4_L7_r0_body.sizePayA261 PRE_first_tail_x4_L7_r0_body.sizeTaA261 PRE_first_tail_x4_L7_r0_body.sizeDecA261 PRE_first_tail_x4_L7_r0_body.sizePreA261 PRE_first_tail_x4_L7_r0_body.bodyPatchB261 (fun _ hm => bodyO1008 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1008).trans bodyInactive0) (bodyBr1009.trans bodyBr1008.symm) bodyCnt1008 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) bodyAcc1009 PRE_first_tail_x4_L7_r0_body.bodyRunSeg261 bodyAcc1010 bodyHalt1010 PRE_first_tail_x4_L7_r0_body.bodyStepA262 bodyTop1011 (fun _ hm => bodyO1009 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1009).trans bodyInactive0) (bodyBr1011.trans bodyBr1009.symm) bodyCnt1009 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA262 PRE_first_tail_x4_L7_r0_body.sizeArgsA262 PRE_first_tail_x4_L7_r0_body.sizeSymA262 PRE_first_tail_x4_L7_r0_body.sizeMlxA262 PRE_first_tail_x4_L7_r0_body.sizePayA262 PRE_first_tail_x4_L7_r0_body.sizeTaA262 PRE_first_tail_x4_L7_r0_body.sizeDecA262 PRE_first_tail_x4_L7_r0_body.sizePreA262 PRE_first_tail_x4_L7_r0_body.bodyPatchB262 (fun _ hm => bodyO1011 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1011).trans bodyInactive0) (bodyBr1012.trans bodyBr1011.symm) bodyCnt1011 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) bodyAcc1012 PRE_first_tail_x4_L7_r0_body.bodyRunSeg262 bodyAcc1013 bodyHalt1013 PRE_first_tail_x4_L7_r0_body.bodyStepA263 bodyTop1014 (fun _ hm => bodyO1012 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1012).trans bodyInactive0) (bodyBr1014.trans bodyBr1012.symm) bodyCnt1012 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA263 PRE_first_tail_x4_L7_r0_body.sizeArgsA263 PRE_first_tail_x4_L7_r0_body.sizeSymA263 PRE_first_tail_x4_L7_r0_body.sizeMlxA263 PRE_first_tail_x4_L7_r0_body.sizePayA263 PRE_first_tail_x4_L7_r0_body.sizeTaA263 PRE_first_tail_x4_L7_r0_body.sizeDecA263 PRE_first_tail_x4_L7_r0_body.sizePreA263 PRE_first_tail_x4_L7_r0_body.bodyPatchB263 (fun _ hm => bodyO1014 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1014).trans bodyInactive0) (bodyBr1015.trans bodyBr1014.symm) bodyCnt1014 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47030, 893, 0, 0⟩) bodyAcc1015 PRE_first_tail_x4_L7_r0_body.bodyRunSeg263 bodyAcc1016 bodyHalt1016 PRE_first_tail_x4_L7_r0_body.bodyStepA264 bodyTop1017 (fun _ hm => bodyO1015 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1015).trans bodyInactive0) (bodyBr1017.trans bodyBr1015.symm) bodyCnt1015 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyS45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift45 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L7_r0_body.S1017.tab.length PRE_first_tail_x4_L7_r0_body.s1017.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L7_r0_body.P45.NL) : Conv.FullShiftQ PRE_first_tail_x4_L7_r0_body.P45 15 PRE_first_tail_x4_L7_r0_body.kappa45 PRE_first_tail_x4_L7_r0_body.s1019.ffi PRE_first_tail_x4_L7_r0_body.s1018.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L7_r0_body.ofxC_45
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L7_r0_body.okrC_45
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s1019.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L7_r0_body.S1017.tab.length) hr.cl (by rw [PRE_first_tail_x4_L7_r0_body.n0_45] <;> decide) PRE_first_tail_x4_L7_r0_body.cnodesK45 PRE_first_tail_x4_L7_r0_body.cobjsK45
      PRE_first_tail_x4_L7_r0_body.citemsK45 PRE_first_tail_x4_L7_r0_body.cbd45 PRE_first_tail_x4_L7_r0_body.csst45
  exact PRE_first_tail_x4_L7_r0_body.cshift45 bodyNcl45 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L7_r0_body.n0_45] at this; exact this)


kernel_rfl bodyFramesEmpty45 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L7_r0_body.s1018 a).isEmpty) = true
kernel_rfl bodyJsRoots45 : noBigRootsP (jsAboveB PRE_first_tail_x4_L7_r0_body.s1017.next) PRE_first_tail_x4_L7_r0_body.s1019.trace PRE_first_tail_x4_L7_r0_body.s1019 = true
kernel_rfl bodyJsNative45 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L7_r0_body.s1019.ffi) = true
kernel_rfl bodyLow45 : (PRE_first_tail_x4_L7_r0_body.cws45 ++ PRE_first_tail_x4_L7_r0_body.ws45).all (Nat.ble 9) = true
kernel_rfl bodyCntM45 : countersOkB PRE_first_tail_x4_L7_r0_body.s1017 PRE_first_tail_x4_L7_r0_body.s1018 = true
kernel_rfl bodyHi45 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1019.ffi).next setupP.E = true
kernel_rfl bodyNhi45 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1019.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge45 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1018.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s1017.ffi
kernel_rfl bodyNN45 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1017.ffi).nnext PRE_first_tail_x4_L7_r0_body.P45.NL = true
kernel_rfl bodyXn45 : Nat.ble (⟨21015, 18118, 2787514, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L7_r0_body.s1019.ffi).next = true
kernel_rfl bodyLo45 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L7_r0_body.s1019.ffi).next = true
theorem bodyFacts45 : BodySiteFacts PRE_first_tail_x4_L7_r0_body.s1017 PRE_first_tail_x4_L7_r0_body.s1018 PRE_first_tail_x4_L7_r0_body.s1019 PRE_first_tail_x4_L7_r0_body.s0 PRE_first_tail_x4_L7_r0_body.S1017 PRE_first_tail_x4_L7_r0_body.S1018 PRE_first_tail_x4_L7_r0_body.S1019
    PRE_first_tail_x4_L7_r0_body.ws45 PRE_first_tail_x4_L7_r0_body.cws45 PRE_first_tail_x4_L7_r0_body.nr45 PRE_first_tail_x4_L7_r0_body.pl45 PRE_first_tail_x4_L7_r0_body.cl45 2788663 15 PRE_first_tail_x4_L7_r0_body.kd45 PRE_first_tail_x4_L7_r0_body.kappa45 PRE_first_tail_x4_L7_r0_body.P45
    ⟨21012, 18091, 2787508, 15⟩ ⟨21015, 18118, 2787514, 15⟩ where
  zkap := PRE_first_tail_x4_L7_r0_body.zkap45
  clean := bodyClean45
  cfix := PRE_first_tail_x4_L7_r0_body.cfix45
  zpl := PRE_first_tail_x4_L7_r0_body.zpl45
  zplnd := PRE_first_tail_x4_L7_r0_body.zplnd45
  zn1 := PRE_first_tail_x4_L7_r0_body.zn145
  zfirst := PRE_first_tail_x4_L7_r0_body.zfirst45
  zscn := PRE_first_tail_x4_L7_r0_body.zscn45
  zsmn := PRE_first_tail_x4_L7_r0_body.zsmn45
  zgrow := PRE_first_tail_x4_L7_r0_body.zgrow45
  mergeTab := PRE_first_tail_x4_L7_r0_body.mergeTab45
  zfresh := PRE_first_tail_x4_L7_r0_body.zfresh45
  zcnd := PRE_first_tail_x4_L7_r0_body.zcnd45
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L7_r0_body.znrHi45
  zfrlt := PRE_first_tail_x4_L7_r0_body.zfrlt45
  zgP := PRE_first_tail_x4_L7_r0_body.zg45_2665
  zkP := PRE_first_tail_x4_L7_r0_body.zk45_2665
  zmP := PRE_first_tail_x4_L7_r0_body.zm45_2665
  zgC := PRE_first_tail_x4_L7_r0_body.zg45_2673467
  zkC := PRE_first_tail_x4_L7_r0_body.zk45_2673467
  zmC := PRE_first_tail_x4_L7_r0_body.zm45_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L7_r0_body.zw45_2673472
  zwV := PRE_first_tail_x4_L7_r0_body.zw45_2673473
  cheap := PRE_first_tail_x4_L7_r0_body.cheap45
  zclbd := PRE_first_tail_x4_L7_r0_body.zclbd45
  hml := hoff_of PRE_first_tail_x4_L7_r0_body.mheap45 PRE_first_tail_x4_L7_r0_body.stFoot45 PRE_first_tail_x4_L7_r0_body.iso45 PRE_first_tail_x4_L7_r0_body.zwr45
  ckeepP := PRE_first_tail_x4_L7_r0_body.ckeepP45
  csupp := PRE_first_tail_x4_L7_r0_body.csupp45
  cbound := PRE_first_tail_x4_L7_r0_body.cbound45
  zimg := PRE_first_tail_x4_L7_r0_body.zimg45
  zctl := PRE_first_tail_x4_L7_r0_body.zctl45
  zstack := PRE_first_tail_x4_L7_r0_body.zstack45
  zjobs := PRE_first_tail_x4_L7_r0_body.zjobs45
  zstores := PRE_first_tail_x4_L7_r0_body.zstores45
  zroots := PRE_first_tail_x4_L7_r0_body.zroots45
  znC := PRE_first_tail_x4_L7_r0_body.znC45
  ctab := PRE_first_tail_x4_L7_r0_body.ctab45
  zbin := PRE_first_tail_x4_L7_r0_body.zbin45
  cbridge := PRE_first_tail_x4_L7_r0_body.cbridge45
  sbridge := bodyBridge45
  cwsDisj := PRE_first_tail_x4_L7_r0_body.cwsDisj45
  cshiftR := fun h hNL => bodyCshift45 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN45
  raised := PRE_first_tail_x4_L7_r0_body.raised45
  cbigs := PRE_first_tail_x4_L7_r0_body.cbigs45
  cjcl := PRE_first_tail_x4_L7_r0_body.cjcl45
  xnLe := Nat.le_of_ble_eq_true bodyXn45
  loLe := Nat.le_of_ble_eq_true bodyLo45
  zroots2 := PRE_first_tail_x4_L7_r0_body.zrootsB45
  cntM := bodyCntM45
  hiLe := Nat.le_of_ble_eq_true bodyHi45
  nhiLe := Nat.le_of_ble_eq_true bodyNhi45
  jsHeap := bodyJs45
  jsRoots := bodyJsRoots45
  jsNative := bodyJsNative45
  framesEmpty := bodyFramesEmpty45
  trailOld := by decide
  lowVars := bodyLow45

def bodyQs45 : List (Option Q) := []
noncomputable def bodyEs45 : List (Option SymE) := PRE_first_tail_x4_L7_r0_body.nr45.map fun r => nth? PRE_first_tail_x4_L7_r0_body.st45.S5.tab r
kernel_rfl bodyResChk45 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs45 bodyQs45) = true
kernel_rfl bodyLq45 : bodyQs45.length = PRE_first_tail_x4_L7_r0_body.cws45.length
kernel_rfl bodyNrLo45 : PRE_first_tail_x4_L7_r0_body.nr45.all (Nat.ble PRE_first_tail_x4_L7_r0_body.S1017.tab.length) = true
kernel_rfl bodySub45 : (Oracles.PRE_first_tail_x4_L7_r0_body.map_site45.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost45 : postSubB bodyM PRE_first_tail_x4_L7_r0_body.ws45 PRE_first_tail_x4_L7_r0_body.cws45 bodyQs45 = true
kernel_rfl bodyDrop45 : Nat.ble (47030 + (PRE_first_tail_x4_L7_r0_body.s1018.next - PRE_first_tail_x4_L7_r0_body.s1019.next)) 48179 = true
kernel_rfl bodyDropH45 : Nat.ble (893 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s1018.ffi).next - (mlxOf PRE_first_tail_x4_L7_r0_body.s1019.ffi).next)) 918 = true
kernel_rfl bodyDropN45 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s1018.ffi).nnext - (mlxOf PRE_first_tail_x4_L7_r0_body.s1019.ffi).nnext)) 0 = true
kernel_rfl bodyDv45 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L7_r0_body.cws45
kernel_rfl bodyDe45 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L7_r0_body.nr45.map (fun r =>
  ((nth? PRE_first_tail_x4_L7_r0_body.st45.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl45 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold45 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L7_r0_body.cws45).isNone && !PRE_first_tail_x4_L7_r0_body.ws45.contains v) = true
kernel_rfl bodyDfree45 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L7_r0_body.cws45 ++ PRE_first_tail_x4_L7_r0_body.ws45).all fun w => e.noVar w) = true

theorem bodyStep45 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨47030, 893, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1017 PRE_first_tail_x4_L7_r0_body.S1017)
      (bodyCut NB T tk π i x0 bodyΘ ⟨48179, 918, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1019 PRE_first_tail_x4_L7_r0_body.S1019) (11334 + 1) :=
  bodySite bodyFacts45.cfix bodyFacts45.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L7_r0_body.st45.S5.tab) (Es := bodyEs45) (qs := bodyQs45)
    (ok := PRE_first_tail_x4_L7_r0_body.st45.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L7_r0_body.site45 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts45
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L7_r0_body.chk_site45 r hr) hi (MapOk.sub hm (sub_of_all bodySub45)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk45 r hr) hi hm ho hq)
    bodyLq45 rfl bodyNrLo45 (postSub_sound bodyPost45)
    (Nat.le_of_ble_eq_true bodyDrop45) (by decide) (Nat.le_of_ble_eq_true bodyDropH45) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN45) (by decide)
    bodyDv45 bodyDe45 bodyDl45 bodyDold45 bodyDfree45 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodySite46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_site46 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site46 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site46) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st46.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L7_r0_body.site46
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st46.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st46.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s1039 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s1040 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S1039 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws46 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st46.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st46.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.iso46
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_46
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st46.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.stFoot46
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrNodup46
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrBound46
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.trace46
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.merged46
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws46.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st46.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S1039.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_46]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.mergeLen46.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.fresh46
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl46 : Conv.NClean (⟨21069, 18154, 2789750, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s1039.ffi).mlx :=
  PRE_first_tail_x4_L7_r0_body.gncl46 (PRE_first_tail_x4_L7_r0_body.cncl45 bodyNcl45)

theorem bodyClean46 : Conv.JClean (⟨21069, 18154, 2789750, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L7_r0_body.s1039 :=
  PRE_first_tail_x4_L7_r0_body.gjcl46 (PRE_first_tail_x4_L7_r0_body.cjcl45 bodyClean45)

kernel_rfl bodyJsLe46 : Nat.ble PRE_first_tail_x4_L7_r0_body.s1017.next PRE_first_tail_x4_L7_r0_body.s1039.next = true
kernel_rfl bodyJsList46 : (PRE_first_tail_x4_L7_r0_body.gjh46 ++ PRE_first_tail_x4_L7_r0_body.cl46).all (noBigAtP (jsAboveB PRE_first_tail_x4_L7_r0_body.s1039.next) PRE_first_tail_x4_L7_r0_body.s1041) = true
theorem bodyJs46 : JsHeapAbove PRE_first_tail_x4_L7_r0_body.s1039.next PRE_first_tail_x4_L7_r0_body.s1041 :=
  JsHeapAbove.glueSite bodyJs45 (Nat.le_of_ble_eq_true bodyJsLe46) PRE_first_tail_x4_L7_r0_body.gjk46 PRE_first_tail_x4_L7_r0_body.gjbd46 PRE_first_tail_x4_L7_r0_body.cheap46 PRE_first_tail_x4_L7_r0_body.zclbd46 bodyJsList46

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyG46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1019 : PRE_first_tail_x4_L7_r0_body.S1019.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1019.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1019 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1019.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyAcc1019 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1019 PRE_first_tail_x4_L7_r0_body.S1019) = fun _ _ => true
kernel_rfl bodyAcc1020 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1020 PRE_first_tail_x4_L7_r0_body.S1020) = fun _ _ => true
kernel_rfl bodyBr1021 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1021.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1020 : isHalt PRE_first_tail_x4_L7_r0_body.s1020.ctl = false
kernel_rfl bodyTop1021 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1021 = true
kernel_rfl bodyCnt1019 : countersOkB PRE_first_tail_x4_L7_r0_body.s1019 PRE_first_tail_x4_L7_r0_body.s1021 = true
kernel_rfl bodyO1021 : PRE_first_tail_x4_L7_r0_body.S1021.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1021.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1022 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1022.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1021 : countersOkB PRE_first_tail_x4_L7_r0_body.s1021 PRE_first_tail_x4_L7_r0_body.s1022 = true
kernel_rfl bodyO1022 : PRE_first_tail_x4_L7_r0_body.S1022.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1022.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1022 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1022 PRE_first_tail_x4_L7_r0_body.S1022) = fun _ _ => true
kernel_rfl bodyAcc1026 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1026 PRE_first_tail_x4_L7_r0_body.S1026) = fun _ _ => true
kernel_rfl bodyBr1027 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1027.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1026 : isHalt PRE_first_tail_x4_L7_r0_body.s1026.ctl = false
kernel_rfl bodyTop1027 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1027 = true
kernel_rfl bodyCnt1022 : countersOkB PRE_first_tail_x4_L7_r0_body.s1022 PRE_first_tail_x4_L7_r0_body.s1027 = true
kernel_rfl bodyO1027 : PRE_first_tail_x4_L7_r0_body.S1027.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1027.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1028 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1028.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1027 : countersOkB PRE_first_tail_x4_L7_r0_body.s1027 PRE_first_tail_x4_L7_r0_body.s1028 = true
kernel_rfl bodyO1028 : PRE_first_tail_x4_L7_r0_body.S1028.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1028.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1028 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1028 PRE_first_tail_x4_L7_r0_body.S1028) = fun _ _ => true
kernel_rfl bodyAcc1029 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1029 PRE_first_tail_x4_L7_r0_body.S1029) = fun _ _ => true
kernel_rfl bodyBr1030 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1030.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1029 : isHalt PRE_first_tail_x4_L7_r0_body.s1029.ctl = false
kernel_rfl bodyTop1030 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1030 = true
kernel_rfl bodyCnt1028 : countersOkB PRE_first_tail_x4_L7_r0_body.s1028 PRE_first_tail_x4_L7_r0_body.s1030 = true
kernel_rfl bodyO1030 : PRE_first_tail_x4_L7_r0_body.S1030.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1030.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1031 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1031.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1030 : countersOkB PRE_first_tail_x4_L7_r0_body.s1030 PRE_first_tail_x4_L7_r0_body.s1031 = true
kernel_rfl bodyO1031 : PRE_first_tail_x4_L7_r0_body.S1031.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1031.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1031 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1031 PRE_first_tail_x4_L7_r0_body.S1031) = fun _ _ => true
kernel_rfl bodyAcc1032 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1032 PRE_first_tail_x4_L7_r0_body.S1032) = fun _ _ => true
kernel_rfl bodyBr1033 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1033.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1032 : isHalt PRE_first_tail_x4_L7_r0_body.s1032.ctl = false
kernel_rfl bodyTop1033 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1033 = true
kernel_rfl bodyCnt1031 : countersOkB PRE_first_tail_x4_L7_r0_body.s1031 PRE_first_tail_x4_L7_r0_body.s1033 = true
kernel_rfl bodyO1033 : PRE_first_tail_x4_L7_r0_body.S1033.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1033.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1034 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1034.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1033 : countersOkB PRE_first_tail_x4_L7_r0_body.s1033 PRE_first_tail_x4_L7_r0_body.s1034 = true
kernel_rfl bodyO1034 : PRE_first_tail_x4_L7_r0_body.S1034.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1034.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1034 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1034 PRE_first_tail_x4_L7_r0_body.S1034) = fun _ _ => true
kernel_rfl bodyAcc1035 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1035 PRE_first_tail_x4_L7_r0_body.S1035) = fun _ _ => true
kernel_rfl bodyBr1036 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1036.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1035 : isHalt PRE_first_tail_x4_L7_r0_body.s1035.ctl = false
kernel_rfl bodyTop1036 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1036 = true
kernel_rfl bodyCnt1034 : countersOkB PRE_first_tail_x4_L7_r0_body.s1034 PRE_first_tail_x4_L7_r0_body.s1036 = true
kernel_rfl bodyO1036 : PRE_first_tail_x4_L7_r0_body.S1036.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1036.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1037 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1037.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1036 : countersOkB PRE_first_tail_x4_L7_r0_body.s1036 PRE_first_tail_x4_L7_r0_body.s1037 = true
kernel_rfl bodyO1037 : PRE_first_tail_x4_L7_r0_body.S1037.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1037.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1037 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1037 PRE_first_tail_x4_L7_r0_body.S1037) = fun _ _ => true
kernel_rfl bodyAcc1038 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1038 PRE_first_tail_x4_L7_r0_body.S1038) = fun _ _ => true
kernel_rfl bodyBr1039 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1039.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1038 : isHalt PRE_first_tail_x4_L7_r0_body.s1038.ctl = false
kernel_rfl bodyTop1039 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1039 = true
kernel_rfl bodyCnt1037 : countersOkB PRE_first_tail_x4_L7_r0_body.s1037 PRE_first_tail_x4_L7_r0_body.s1039 = true

theorem bodyGlue46 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨48179, 918, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1019 PRE_first_tail_x4_L7_r0_body.S1019)
      (bodyCut NB T tk π i x0 bodyΘ ⟨48179, 918, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1039 PRE_first_tail_x4_L7_r0_body.S1039) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) bodyAcc1019 PRE_first_tail_x4_L7_r0_body.bodyRunSeg264 bodyAcc1020 bodyHalt1020 PRE_first_tail_x4_L7_r0_body.bodyStepA265 bodyTop1021 (fun _ hm => bodyO1019 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1019).trans bodyInactive0) (bodyBr1021.trans bodyBr1019.symm) bodyCnt1019 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA265 PRE_first_tail_x4_L7_r0_body.sizeArgsA265 PRE_first_tail_x4_L7_r0_body.sizeSymA265 PRE_first_tail_x4_L7_r0_body.sizeMlxA265 PRE_first_tail_x4_L7_r0_body.sizePayA265 PRE_first_tail_x4_L7_r0_body.sizeTaA265 PRE_first_tail_x4_L7_r0_body.sizeDecA265 PRE_first_tail_x4_L7_r0_body.sizePreA265 PRE_first_tail_x4_L7_r0_body.bodyPatchB265 (fun _ hm => bodyO1021 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1021).trans bodyInactive0) (bodyBr1022.trans bodyBr1021.symm) bodyCnt1021 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) bodyAcc1022 PRE_first_tail_x4_L7_r0_body.bodyRunSeg265 bodyAcc1026 bodyHalt1026 PRE_first_tail_x4_L7_r0_body.bodyStepA266 bodyTop1027 (fun _ hm => bodyO1022 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1022).trans bodyInactive0) (bodyBr1027.trans bodyBr1022.symm) bodyCnt1022 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA266 PRE_first_tail_x4_L7_r0_body.sizeArgsA266 PRE_first_tail_x4_L7_r0_body.sizeSymA266 PRE_first_tail_x4_L7_r0_body.sizeMlxA266 PRE_first_tail_x4_L7_r0_body.sizePayA266 PRE_first_tail_x4_L7_r0_body.sizeTaA266 PRE_first_tail_x4_L7_r0_body.sizeDecA266 PRE_first_tail_x4_L7_r0_body.sizePreA266 PRE_first_tail_x4_L7_r0_body.bodyPatchB266 (fun _ hm => bodyO1027 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1027).trans bodyInactive0) (bodyBr1028.trans bodyBr1027.symm) bodyCnt1027 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) bodyAcc1028 PRE_first_tail_x4_L7_r0_body.bodyRunSeg266 bodyAcc1029 bodyHalt1029 PRE_first_tail_x4_L7_r0_body.bodyStepA267 bodyTop1030 (fun _ hm => bodyO1028 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1028).trans bodyInactive0) (bodyBr1030.trans bodyBr1028.symm) bodyCnt1028 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA267 PRE_first_tail_x4_L7_r0_body.sizeArgsA267 PRE_first_tail_x4_L7_r0_body.sizeSymA267 PRE_first_tail_x4_L7_r0_body.sizeMlxA267 PRE_first_tail_x4_L7_r0_body.sizePayA267 PRE_first_tail_x4_L7_r0_body.sizeTaA267 PRE_first_tail_x4_L7_r0_body.sizeDecA267 PRE_first_tail_x4_L7_r0_body.sizePreA267 PRE_first_tail_x4_L7_r0_body.bodyPatchB267 (fun _ hm => bodyO1030 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1030).trans bodyInactive0) (bodyBr1031.trans bodyBr1030.symm) bodyCnt1030 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) bodyAcc1031 PRE_first_tail_x4_L7_r0_body.bodyRunSeg267 bodyAcc1032 bodyHalt1032 PRE_first_tail_x4_L7_r0_body.bodyStepA268 bodyTop1033 (fun _ hm => bodyO1031 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1031).trans bodyInactive0) (bodyBr1033.trans bodyBr1031.symm) bodyCnt1031 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA268 PRE_first_tail_x4_L7_r0_body.sizeArgsA268 PRE_first_tail_x4_L7_r0_body.sizeSymA268 PRE_first_tail_x4_L7_r0_body.sizeMlxA268 PRE_first_tail_x4_L7_r0_body.sizePayA268 PRE_first_tail_x4_L7_r0_body.sizeTaA268 PRE_first_tail_x4_L7_r0_body.sizeDecA268 PRE_first_tail_x4_L7_r0_body.sizePreA268 PRE_first_tail_x4_L7_r0_body.bodyPatchB268 (fun _ hm => bodyO1033 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1033).trans bodyInactive0) (bodyBr1034.trans bodyBr1033.symm) bodyCnt1033 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) bodyAcc1034 PRE_first_tail_x4_L7_r0_body.bodyRunSeg268 bodyAcc1035 bodyHalt1035 PRE_first_tail_x4_L7_r0_body.bodyStepA269 bodyTop1036 (fun _ hm => bodyO1034 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1034).trans bodyInactive0) (bodyBr1036.trans bodyBr1034.symm) bodyCnt1034 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA269 PRE_first_tail_x4_L7_r0_body.sizeArgsA269 PRE_first_tail_x4_L7_r0_body.sizeSymA269 PRE_first_tail_x4_L7_r0_body.sizeMlxA269 PRE_first_tail_x4_L7_r0_body.sizePayA269 PRE_first_tail_x4_L7_r0_body.sizeTaA269 PRE_first_tail_x4_L7_r0_body.sizeDecA269 PRE_first_tail_x4_L7_r0_body.sizePreA269 PRE_first_tail_x4_L7_r0_body.bodyPatchB269 (fun _ hm => bodyO1036 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1036).trans bodyInactive0) (bodyBr1037.trans bodyBr1036.symm) bodyCnt1036 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48179, 918, 0, 0⟩) bodyAcc1037 PRE_first_tail_x4_L7_r0_body.bodyRunSeg269 bodyAcc1038 bodyHalt1038 PRE_first_tail_x4_L7_r0_body.bodyStepA270 bodyTop1039 (fun _ hm => bodyO1037 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1037).trans bodyInactive0) (bodyBr1039.trans bodyBr1037.symm) bodyCnt1037 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyS46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift46 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L7_r0_body.S1039.tab.length PRE_first_tail_x4_L7_r0_body.s1039.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L7_r0_body.P46.NL) : Conv.FullShiftQ PRE_first_tail_x4_L7_r0_body.P46 15 PRE_first_tail_x4_L7_r0_body.kappa46 PRE_first_tail_x4_L7_r0_body.s1041.ffi PRE_first_tail_x4_L7_r0_body.s1040.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L7_r0_body.ofxC_46
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L7_r0_body.okrC_46
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s1041.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L7_r0_body.S1039.tab.length) hr.cl (by rw [PRE_first_tail_x4_L7_r0_body.n0_46] <;> decide) PRE_first_tail_x4_L7_r0_body.cnodesK46 PRE_first_tail_x4_L7_r0_body.cobjsK46
      PRE_first_tail_x4_L7_r0_body.citemsK46 PRE_first_tail_x4_L7_r0_body.cbd46 PRE_first_tail_x4_L7_r0_body.csst46
  exact PRE_first_tail_x4_L7_r0_body.cshift46 bodyNcl46 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L7_r0_body.n0_46] at this; exact this)


kernel_rfl bodyFramesEmpty46 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L7_r0_body.s1040 a).isEmpty) = true
kernel_rfl bodyJsRoots46 : noBigRootsP (jsAboveB PRE_first_tail_x4_L7_r0_body.s1039.next) PRE_first_tail_x4_L7_r0_body.s1041.trace PRE_first_tail_x4_L7_r0_body.s1041 = true
kernel_rfl bodyJsNative46 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L7_r0_body.s1041.ffi) = true
kernel_rfl bodyLow46 : (PRE_first_tail_x4_L7_r0_body.cws46 ++ PRE_first_tail_x4_L7_r0_body.ws46).all (Nat.ble 9) = true
kernel_rfl bodyCntM46 : countersOkB PRE_first_tail_x4_L7_r0_body.s1039 PRE_first_tail_x4_L7_r0_body.s1040 = true
kernel_rfl bodyHi46 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1041.ffi).next setupP.E = true
kernel_rfl bodyNhi46 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1041.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge46 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1040.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s1039.ffi
kernel_rfl bodyNN46 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1039.ffi).nnext PRE_first_tail_x4_L7_r0_body.P46.NL = true
kernel_rfl bodyXn46 : Nat.ble (⟨21072, 18181, 2789756, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L7_r0_body.s1041.ffi).next = true
kernel_rfl bodyLo46 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L7_r0_body.s1041.ffi).next = true
theorem bodyFacts46 : BodySiteFacts PRE_first_tail_x4_L7_r0_body.s1039 PRE_first_tail_x4_L7_r0_body.s1040 PRE_first_tail_x4_L7_r0_body.s1041 PRE_first_tail_x4_L7_r0_body.s0 PRE_first_tail_x4_L7_r0_body.S1039 PRE_first_tail_x4_L7_r0_body.S1040 PRE_first_tail_x4_L7_r0_body.S1041
    PRE_first_tail_x4_L7_r0_body.ws46 PRE_first_tail_x4_L7_r0_body.cws46 PRE_first_tail_x4_L7_r0_body.nr46 PRE_first_tail_x4_L7_r0_body.pl46 PRE_first_tail_x4_L7_r0_body.cl46 2790905 15 PRE_first_tail_x4_L7_r0_body.kd46 PRE_first_tail_x4_L7_r0_body.kappa46 PRE_first_tail_x4_L7_r0_body.P46
    ⟨21069, 18154, 2789750, 15⟩ ⟨21072, 18181, 2789756, 15⟩ where
  zkap := PRE_first_tail_x4_L7_r0_body.zkap46
  clean := bodyClean46
  cfix := PRE_first_tail_x4_L7_r0_body.cfix46
  zpl := PRE_first_tail_x4_L7_r0_body.zpl46
  zplnd := PRE_first_tail_x4_L7_r0_body.zplnd46
  zn1 := PRE_first_tail_x4_L7_r0_body.zn146
  zfirst := PRE_first_tail_x4_L7_r0_body.zfirst46
  zscn := PRE_first_tail_x4_L7_r0_body.zscn46
  zsmn := PRE_first_tail_x4_L7_r0_body.zsmn46
  zgrow := PRE_first_tail_x4_L7_r0_body.zgrow46
  mergeTab := PRE_first_tail_x4_L7_r0_body.mergeTab46
  zfresh := PRE_first_tail_x4_L7_r0_body.zfresh46
  zcnd := PRE_first_tail_x4_L7_r0_body.zcnd46
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L7_r0_body.znrHi46
  zfrlt := PRE_first_tail_x4_L7_r0_body.zfrlt46
  zgP := PRE_first_tail_x4_L7_r0_body.zg46_2665
  zkP := PRE_first_tail_x4_L7_r0_body.zk46_2665
  zmP := PRE_first_tail_x4_L7_r0_body.zm46_2665
  zgC := PRE_first_tail_x4_L7_r0_body.zg46_2673467
  zkC := PRE_first_tail_x4_L7_r0_body.zk46_2673467
  zmC := PRE_first_tail_x4_L7_r0_body.zm46_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L7_r0_body.zw46_2673472
  zwV := PRE_first_tail_x4_L7_r0_body.zw46_2673473
  cheap := PRE_first_tail_x4_L7_r0_body.cheap46
  zclbd := PRE_first_tail_x4_L7_r0_body.zclbd46
  hml := hoff_of PRE_first_tail_x4_L7_r0_body.mheap46 PRE_first_tail_x4_L7_r0_body.stFoot46 PRE_first_tail_x4_L7_r0_body.iso46 PRE_first_tail_x4_L7_r0_body.zwr46
  ckeepP := PRE_first_tail_x4_L7_r0_body.ckeepP46
  csupp := PRE_first_tail_x4_L7_r0_body.csupp46
  cbound := PRE_first_tail_x4_L7_r0_body.cbound46
  zimg := PRE_first_tail_x4_L7_r0_body.zimg46
  zctl := PRE_first_tail_x4_L7_r0_body.zctl46
  zstack := PRE_first_tail_x4_L7_r0_body.zstack46
  zjobs := PRE_first_tail_x4_L7_r0_body.zjobs46
  zstores := PRE_first_tail_x4_L7_r0_body.zstores46
  zroots := PRE_first_tail_x4_L7_r0_body.zroots46
  znC := PRE_first_tail_x4_L7_r0_body.znC46
  ctab := PRE_first_tail_x4_L7_r0_body.ctab46
  zbin := PRE_first_tail_x4_L7_r0_body.zbin46
  cbridge := PRE_first_tail_x4_L7_r0_body.cbridge46
  sbridge := bodyBridge46
  cwsDisj := PRE_first_tail_x4_L7_r0_body.cwsDisj46
  cshiftR := fun h hNL => bodyCshift46 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN46
  raised := PRE_first_tail_x4_L7_r0_body.raised46
  cbigs := PRE_first_tail_x4_L7_r0_body.cbigs46
  cjcl := PRE_first_tail_x4_L7_r0_body.cjcl46
  xnLe := Nat.le_of_ble_eq_true bodyXn46
  loLe := Nat.le_of_ble_eq_true bodyLo46
  zroots2 := PRE_first_tail_x4_L7_r0_body.zrootsB46
  cntM := bodyCntM46
  hiLe := Nat.le_of_ble_eq_true bodyHi46
  nhiLe := Nat.le_of_ble_eq_true bodyNhi46
  jsHeap := bodyJs46
  jsRoots := bodyJsRoots46
  jsNative := bodyJsNative46
  framesEmpty := bodyFramesEmpty46
  trailOld := by decide
  lowVars := bodyLow46

def bodyQs46 : List (Option Q) := []
noncomputable def bodyEs46 : List (Option SymE) := PRE_first_tail_x4_L7_r0_body.nr46.map fun r => nth? PRE_first_tail_x4_L7_r0_body.st46.S5.tab r
kernel_rfl bodyResChk46 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs46 bodyQs46) = true
kernel_rfl bodyLq46 : bodyQs46.length = PRE_first_tail_x4_L7_r0_body.cws46.length
kernel_rfl bodyNrLo46 : PRE_first_tail_x4_L7_r0_body.nr46.all (Nat.ble PRE_first_tail_x4_L7_r0_body.S1039.tab.length) = true
kernel_rfl bodySub46 : (Oracles.PRE_first_tail_x4_L7_r0_body.map_site46.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost46 : postSubB bodyM PRE_first_tail_x4_L7_r0_body.ws46 PRE_first_tail_x4_L7_r0_body.cws46 bodyQs46 = true
kernel_rfl bodyDrop46 : Nat.ble (48179 + (PRE_first_tail_x4_L7_r0_body.s1040.next - PRE_first_tail_x4_L7_r0_body.s1041.next)) 49328 = true
kernel_rfl bodyDropH46 : Nat.ble (918 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s1040.ffi).next - (mlxOf PRE_first_tail_x4_L7_r0_body.s1041.ffi).next)) 943 = true
kernel_rfl bodyDropN46 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s1040.ffi).nnext - (mlxOf PRE_first_tail_x4_L7_r0_body.s1041.ffi).nnext)) 0 = true
kernel_rfl bodyDv46 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L7_r0_body.cws46
kernel_rfl bodyDe46 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L7_r0_body.nr46.map (fun r =>
  ((nth? PRE_first_tail_x4_L7_r0_body.st46.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl46 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold46 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L7_r0_body.cws46).isNone && !PRE_first_tail_x4_L7_r0_body.ws46.contains v) = true
kernel_rfl bodyDfree46 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L7_r0_body.cws46 ++ PRE_first_tail_x4_L7_r0_body.ws46).all fun w => e.noVar w) = true

theorem bodyStep46 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨48179, 918, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1039 PRE_first_tail_x4_L7_r0_body.S1039)
      (bodyCut NB T tk π i x0 bodyΘ ⟨49328, 943, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1041 PRE_first_tail_x4_L7_r0_body.S1041) (11334 + 1) :=
  bodySite bodyFacts46.cfix bodyFacts46.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L7_r0_body.st46.S5.tab) (Es := bodyEs46) (qs := bodyQs46)
    (ok := PRE_first_tail_x4_L7_r0_body.st46.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L7_r0_body.site46 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts46
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L7_r0_body.chk_site46 r hr) hi (MapOk.sub hm (sub_of_all bodySub46)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk46 r hr) hi hm ho hq)
    bodyLq46 rfl bodyNrLo46 (postSub_sound bodyPost46)
    (Nat.le_of_ble_eq_true bodyDrop46) (by decide) (Nat.le_of_ble_eq_true bodyDropH46) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN46) (by decide)
    bodyDv46 bodyDe46 bodyDl46 bodyDold46 bodyDfree46 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodySite47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L7_r0_body.map_site47 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L7_r0_body.chk_site47 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L7_r0_body.map_site47) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st47.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L7_r0_body.site47
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st47.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st47.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s1060 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.s1061 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S1060 Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws47 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st47.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st47.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.iso47
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_47
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st47.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.stFoot47
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrNodup47
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.wrBound47
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.trace47
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.merged47
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.ws47.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.st47.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.S1060.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.tab0_47]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.mergeLen47.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0_body.fresh47
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl47 : Conv.NClean (⟨21132, 18226, 2792257, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s1060.ffi).mlx :=
  PRE_first_tail_x4_L7_r0_body.gncl47 (PRE_first_tail_x4_L7_r0_body.cncl46 bodyNcl46)

theorem bodyClean47 : Conv.JClean (⟨21132, 18226, 2792257, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L7_r0_body.s1060 :=
  PRE_first_tail_x4_L7_r0_body.gjcl47 (PRE_first_tail_x4_L7_r0_body.cjcl46 bodyClean46)

kernel_rfl bodyJsLe47 : Nat.ble PRE_first_tail_x4_L7_r0_body.s1039.next PRE_first_tail_x4_L7_r0_body.s1060.next = true
kernel_rfl bodyJsList47 : (PRE_first_tail_x4_L7_r0_body.gjh47 ++ PRE_first_tail_x4_L7_r0_body.cl47).all (noBigAtP (jsAboveB PRE_first_tail_x4_L7_r0_body.s1060.next) PRE_first_tail_x4_L7_r0_body.s1062) = true
theorem bodyJs47 : JsHeapAbove PRE_first_tail_x4_L7_r0_body.s1060.next PRE_first_tail_x4_L7_r0_body.s1062 :=
  JsHeapAbove.glueSite bodyJs46 (Nat.le_of_ble_eq_true bodyJsLe47) PRE_first_tail_x4_L7_r0_body.gjk47 PRE_first_tail_x4_L7_r0_body.gjbd47 PRE_first_tail_x4_L7_r0_body.cheap47 PRE_first_tail_x4_L7_r0_body.zclbd47 bodyJsList47

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyG47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1041 : PRE_first_tail_x4_L7_r0_body.S1041.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1041.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1041 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1041.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyAcc1041 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1041 PRE_first_tail_x4_L7_r0_body.S1041) = fun _ _ => true
kernel_rfl bodyAcc1042 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1042 PRE_first_tail_x4_L7_r0_body.S1042) = fun _ _ => true
kernel_rfl bodyBr1043 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1043.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1042 : isHalt PRE_first_tail_x4_L7_r0_body.s1042.ctl = false
kernel_rfl bodyTop1043 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1043 = true
kernel_rfl bodyCnt1041 : countersOkB PRE_first_tail_x4_L7_r0_body.s1041 PRE_first_tail_x4_L7_r0_body.s1043 = true
kernel_rfl bodyO1043 : PRE_first_tail_x4_L7_r0_body.S1043.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1043.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1044 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1044.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1043 : countersOkB PRE_first_tail_x4_L7_r0_body.s1043 PRE_first_tail_x4_L7_r0_body.s1044 = true
kernel_rfl bodyO1044 : PRE_first_tail_x4_L7_r0_body.S1044.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1044.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1044 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1044 PRE_first_tail_x4_L7_r0_body.S1044) = fun _ _ => true
kernel_rfl bodyAcc1048 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1048 PRE_first_tail_x4_L7_r0_body.S1048) = fun _ _ => true
kernel_rfl bodyBr1049 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1049.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1048 : isHalt PRE_first_tail_x4_L7_r0_body.s1048.ctl = false
kernel_rfl bodyTop1049 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1049 = true
kernel_rfl bodyCnt1044 : countersOkB PRE_first_tail_x4_L7_r0_body.s1044 PRE_first_tail_x4_L7_r0_body.s1049 = true
kernel_rfl bodyO1049 : PRE_first_tail_x4_L7_r0_body.S1049.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1049.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1050 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1050.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1049 : countersOkB PRE_first_tail_x4_L7_r0_body.s1049 PRE_first_tail_x4_L7_r0_body.s1050 = true
kernel_rfl bodyO1050 : PRE_first_tail_x4_L7_r0_body.S1050.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1050.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1050 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1050 PRE_first_tail_x4_L7_r0_body.S1050) = fun _ _ => true
kernel_rfl bodyAcc1052 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1052 PRE_first_tail_x4_L7_r0_body.S1052) = fun _ _ => true
kernel_rfl bodyBr1053 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1053.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1052 : isHalt PRE_first_tail_x4_L7_r0_body.s1052.ctl = false
kernel_rfl bodyTop1053 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1053 = true
kernel_rfl bodyCnt1050 : countersOkB PRE_first_tail_x4_L7_r0_body.s1050 PRE_first_tail_x4_L7_r0_body.s1053 = true
kernel_rfl bodyO1053 : PRE_first_tail_x4_L7_r0_body.S1053.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1053.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1054 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1054.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1053 : countersOkB PRE_first_tail_x4_L7_r0_body.s1053 PRE_first_tail_x4_L7_r0_body.s1054 = true
kernel_rfl bodyO1054 : PRE_first_tail_x4_L7_r0_body.S1054.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1054.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1054 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1054 PRE_first_tail_x4_L7_r0_body.S1054) = fun _ _ => true
kernel_rfl bodyAcc1055 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1055 PRE_first_tail_x4_L7_r0_body.S1055) = fun _ _ => true
kernel_rfl bodyBr1056 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1056.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1055 : isHalt PRE_first_tail_x4_L7_r0_body.s1055.ctl = false
kernel_rfl bodyTop1056 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1056 = true
kernel_rfl bodyCnt1054 : countersOkB PRE_first_tail_x4_L7_r0_body.s1054 PRE_first_tail_x4_L7_r0_body.s1056 = true
kernel_rfl bodyO1056 : PRE_first_tail_x4_L7_r0_body.S1056.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1056.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyBr1057 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1057.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyCnt1056 : countersOkB PRE_first_tail_x4_L7_r0_body.s1056 PRE_first_tail_x4_L7_r0_body.s1057 = true
kernel_rfl bodyO1057 : PRE_first_tail_x4_L7_r0_body.S1057.oracle = List.drop (PRE_first_tail_x4_L7_r0_body.O.length - PRE_first_tail_x4_L7_r0_body.S1057.oracle.length) PRE_first_tail_x4_L7_r0_body.O
kernel_rfl bodyAcc1057 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1057 PRE_first_tail_x4_L7_r0_body.S1057) = fun _ _ => true
kernel_rfl bodyAcc1059 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L7_r0_body.s1059 PRE_first_tail_x4_L7_r0_body.S1059) = fun _ _ => true
kernel_rfl bodyBr1060 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1060.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s0.ffi
kernel_rfl bodyHalt1059 : isHalt PRE_first_tail_x4_L7_r0_body.s1059.ctl = false
kernel_rfl bodyTop1060 : noRetBlock PRE_first_tail_x4_L7_r0_body.s1060 = true
kernel_rfl bodyCnt1057 : countersOkB PRE_first_tail_x4_L7_r0_body.s1057 PRE_first_tail_x4_L7_r0_body.s1060 = true

theorem bodyGlue47 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨49328, 943, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1041 PRE_first_tail_x4_L7_r0_body.S1041)
      (bodyCut NB T tk π i x0 bodyΘ ⟨49328, 943, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1060 PRE_first_tail_x4_L7_r0_body.S1060) 24727 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) bodyAcc1041 PRE_first_tail_x4_L7_r0_body.bodyRunSeg270 bodyAcc1042 bodyHalt1042 PRE_first_tail_x4_L7_r0_body.bodyStepA271 bodyTop1043 (fun _ hm => bodyO1041 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1041).trans bodyInactive0) (bodyBr1043.trans bodyBr1041.symm) bodyCnt1041 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA271 PRE_first_tail_x4_L7_r0_body.sizeArgsA271 PRE_first_tail_x4_L7_r0_body.sizeSymA271 PRE_first_tail_x4_L7_r0_body.sizeMlxA271 PRE_first_tail_x4_L7_r0_body.sizePayA271 PRE_first_tail_x4_L7_r0_body.sizeTaA271 PRE_first_tail_x4_L7_r0_body.sizeDecA271 PRE_first_tail_x4_L7_r0_body.sizePreA271 PRE_first_tail_x4_L7_r0_body.bodyPatchB271 (fun _ hm => bodyO1043 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1043).trans bodyInactive0) (bodyBr1044.trans bodyBr1043.symm) bodyCnt1043 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) bodyAcc1044 PRE_first_tail_x4_L7_r0_body.bodyRunSeg271 bodyAcc1048 bodyHalt1048 PRE_first_tail_x4_L7_r0_body.bodyStepA272 bodyTop1049 (fun _ hm => bodyO1044 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1044).trans bodyInactive0) (bodyBr1049.trans bodyBr1044.symm) bodyCnt1044 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA272 PRE_first_tail_x4_L7_r0_body.sizeArgsA272 PRE_first_tail_x4_L7_r0_body.sizeSymA272 PRE_first_tail_x4_L7_r0_body.sizeMlxA272 PRE_first_tail_x4_L7_r0_body.sizePayA272 PRE_first_tail_x4_L7_r0_body.sizeTaA272 PRE_first_tail_x4_L7_r0_body.sizeDecA272 PRE_first_tail_x4_L7_r0_body.sizePreA272 PRE_first_tail_x4_L7_r0_body.bodyPatchB272 (fun _ hm => bodyO1049 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1049).trans bodyInactive0) (bodyBr1050.trans bodyBr1049.symm) bodyCnt1049 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) bodyAcc1050 PRE_first_tail_x4_L7_r0_body.bodyRunSeg272 bodyAcc1052 bodyHalt1052 PRE_first_tail_x4_L7_r0_body.bodyStepA273 bodyTop1053 (fun _ hm => bodyO1050 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1050).trans bodyInactive0) (bodyBr1053.trans bodyBr1050.symm) bodyCnt1050 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA273 PRE_first_tail_x4_L7_r0_body.sizeArgsA273 PRE_first_tail_x4_L7_r0_body.sizeSymA273 PRE_first_tail_x4_L7_r0_body.sizeMlxA273 PRE_first_tail_x4_L7_r0_body.sizePayA273 PRE_first_tail_x4_L7_r0_body.sizeTaA273 PRE_first_tail_x4_L7_r0_body.sizeDecA273 PRE_first_tail_x4_L7_r0_body.sizePreA273 PRE_first_tail_x4_L7_r0_body.bodyPatchB273 (fun _ hm => bodyO1053 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1053).trans bodyInactive0) (bodyBr1054.trans bodyBr1053.symm) bodyCnt1053 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) bodyAcc1054 PRE_first_tail_x4_L7_r0_body.bodyRunSeg273 bodyAcc1055 bodyHalt1055 PRE_first_tail_x4_L7_r0_body.bodyStepA274 bodyTop1056 (fun _ hm => bodyO1054 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1054).trans bodyInactive0) (bodyBr1056.trans bodyBr1054.symm) bodyCnt1054 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) PRE_first_tail_x4_L7_r0_body.sizeA274 PRE_first_tail_x4_L7_r0_body.sizeArgsA274 PRE_first_tail_x4_L7_r0_body.sizeSymA274 PRE_first_tail_x4_L7_r0_body.sizeMlxA274 PRE_first_tail_x4_L7_r0_body.sizePayA274 PRE_first_tail_x4_L7_r0_body.sizeTaA274 PRE_first_tail_x4_L7_r0_body.sizeDecA274 PRE_first_tail_x4_L7_r0_body.sizePreA274 PRE_first_tail_x4_L7_r0_body.bodyPatchB274 (fun _ hm => bodyO1056 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1056).trans bodyInactive0) (bodyBr1057.trans bodyBr1056.symm) bodyCnt1056 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49328, 943, 0, 0⟩) bodyAcc1057 PRE_first_tail_x4_L7_r0_body.bodyRunSeg274 bodyAcc1059 bodyHalt1059 PRE_first_tail_x4_L7_r0_body.bodyStepA275 bodyTop1060 (fun _ hm => bodyO1057 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1057).trans bodyInactive0) (bodyBr1060.trans bodyBr1057.symm) bodyCnt1057 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end

section -- VWBodyS47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift47 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L7_r0_body.S1060.tab.length PRE_first_tail_x4_L7_r0_body.s1060.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L7_r0_body.P47.NL) : Conv.FullShiftQ PRE_first_tail_x4_L7_r0_body.P47 15 PRE_first_tail_x4_L7_r0_body.kappa47 PRE_first_tail_x4_L7_r0_body.s1062.ffi PRE_first_tail_x4_L7_r0_body.s1061.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L7_r0_body.ofxC_47
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L7_r0_body.okrC_47
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L7_r0_body.s1062.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L7_r0_body.S1060.tab.length) hr.cl (by rw [PRE_first_tail_x4_L7_r0_body.n0_47] <;> decide) PRE_first_tail_x4_L7_r0_body.cnodesK47 PRE_first_tail_x4_L7_r0_body.cobjsK47
      PRE_first_tail_x4_L7_r0_body.citemsK47 PRE_first_tail_x4_L7_r0_body.cbd47 PRE_first_tail_x4_L7_r0_body.csst47
  exact PRE_first_tail_x4_L7_r0_body.cshift47 bodyNcl47 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L7_r0_body.n0_47] at this; exact this)


kernel_rfl bodyFramesEmpty47 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L7_r0_body.s1061 a).isEmpty) = true
kernel_rfl bodyJsRoots47 : noBigRootsP (jsAboveB PRE_first_tail_x4_L7_r0_body.s1060.next) PRE_first_tail_x4_L7_r0_body.s1062.trace PRE_first_tail_x4_L7_r0_body.s1062 = true
kernel_rfl bodyJsNative47 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L7_r0_body.s1062.ffi) = true
kernel_rfl bodyLow47 : (PRE_first_tail_x4_L7_r0_body.cws47 ++ PRE_first_tail_x4_L7_r0_body.ws47).all (Nat.ble 9) = true
kernel_rfl bodyCntM47 : countersOkB PRE_first_tail_x4_L7_r0_body.s1060 PRE_first_tail_x4_L7_r0_body.s1061 = true
kernel_rfl bodyHi47 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1062.ffi).next setupP.E = true
kernel_rfl bodyNhi47 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1062.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge47 : bridgeOf PRE_first_tail_x4_L7_r0_body.s1061.ffi = bridgeOf PRE_first_tail_x4_L7_r0_body.s1060.ffi
kernel_rfl bodyNN47 : Nat.ble (mlxOf PRE_first_tail_x4_L7_r0_body.s1060.ffi).nnext PRE_first_tail_x4_L7_r0_body.P47.NL = true
kernel_rfl bodyXn47 : Nat.ble (⟨21136, 18232, 2792272, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L7_r0_body.s1062.ffi).next = true
kernel_rfl bodyLo47 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L7_r0_body.s1062.ffi).next = true
theorem bodyFacts47 : BodySiteFacts PRE_first_tail_x4_L7_r0_body.s1060 PRE_first_tail_x4_L7_r0_body.s1061 PRE_first_tail_x4_L7_r0_body.s1062 PRE_first_tail_x4_L7_r0_body.s0 PRE_first_tail_x4_L7_r0_body.S1060 PRE_first_tail_x4_L7_r0_body.S1061 PRE_first_tail_x4_L7_r0_body.S1062
    PRE_first_tail_x4_L7_r0_body.ws47 PRE_first_tail_x4_L7_r0_body.cws47 PRE_first_tail_x4_L7_r0_body.nr47 PRE_first_tail_x4_L7_r0_body.pl47 PRE_first_tail_x4_L7_r0_body.cl47 2792622 15 PRE_first_tail_x4_L7_r0_body.kd47 PRE_first_tail_x4_L7_r0_body.kappa47 PRE_first_tail_x4_L7_r0_body.P47
    ⟨21132, 18226, 2792257, 15⟩ ⟨21136, 18232, 2792272, 15⟩ where
  zkap := PRE_first_tail_x4_L7_r0_body.zkap47
  clean := bodyClean47
  cfix := PRE_first_tail_x4_L7_r0_body.cfix47
  zpl := PRE_first_tail_x4_L7_r0_body.zpl47
  zplnd := PRE_first_tail_x4_L7_r0_body.zplnd47
  zn1 := PRE_first_tail_x4_L7_r0_body.zn147
  zfirst := PRE_first_tail_x4_L7_r0_body.zfirst47
  zscn := PRE_first_tail_x4_L7_r0_body.zscn47
  zsmn := PRE_first_tail_x4_L7_r0_body.zsmn47
  zgrow := PRE_first_tail_x4_L7_r0_body.zgrow47
  mergeTab := PRE_first_tail_x4_L7_r0_body.mergeTab47
  zfresh := PRE_first_tail_x4_L7_r0_body.zfresh47
  zcnd := PRE_first_tail_x4_L7_r0_body.zcnd47
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L7_r0_body.znrHi47
  zfrlt := PRE_first_tail_x4_L7_r0_body.zfrlt47
  zgP := PRE_first_tail_x4_L7_r0_body.zg47_2665
  zkP := PRE_first_tail_x4_L7_r0_body.zk47_2665
  zmP := PRE_first_tail_x4_L7_r0_body.zm47_2665
  zgC := PRE_first_tail_x4_L7_r0_body.zg47_2673467
  zkC := PRE_first_tail_x4_L7_r0_body.zk47_2673467
  zmC := PRE_first_tail_x4_L7_r0_body.zm47_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L7_r0_body.zw47_2673472
  zwV := PRE_first_tail_x4_L7_r0_body.zw47_2673473
  cheap := PRE_first_tail_x4_L7_r0_body.cheap47
  zclbd := PRE_first_tail_x4_L7_r0_body.zclbd47
  hml := hoff_of PRE_first_tail_x4_L7_r0_body.mheap47 PRE_first_tail_x4_L7_r0_body.stFoot47 PRE_first_tail_x4_L7_r0_body.iso47 PRE_first_tail_x4_L7_r0_body.zwr47
  ckeepP := PRE_first_tail_x4_L7_r0_body.ckeepP47
  csupp := PRE_first_tail_x4_L7_r0_body.csupp47
  cbound := PRE_first_tail_x4_L7_r0_body.cbound47
  zimg := PRE_first_tail_x4_L7_r0_body.zimg47
  zctl := PRE_first_tail_x4_L7_r0_body.zctl47
  zstack := PRE_first_tail_x4_L7_r0_body.zstack47
  zjobs := PRE_first_tail_x4_L7_r0_body.zjobs47
  zstores := PRE_first_tail_x4_L7_r0_body.zstores47
  zroots := PRE_first_tail_x4_L7_r0_body.zroots47
  znC := PRE_first_tail_x4_L7_r0_body.znC47
  ctab := PRE_first_tail_x4_L7_r0_body.ctab47
  zbin := PRE_first_tail_x4_L7_r0_body.zbin47
  cbridge := PRE_first_tail_x4_L7_r0_body.cbridge47
  sbridge := bodyBridge47
  cwsDisj := PRE_first_tail_x4_L7_r0_body.cwsDisj47
  cshiftR := fun h hNL => bodyCshift47 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN47
  raised := PRE_first_tail_x4_L7_r0_body.raised47
  cbigs := PRE_first_tail_x4_L7_r0_body.cbigs47
  cjcl := PRE_first_tail_x4_L7_r0_body.cjcl47
  xnLe := Nat.le_of_ble_eq_true bodyXn47
  loLe := Nat.le_of_ble_eq_true bodyLo47
  zroots2 := PRE_first_tail_x4_L7_r0_body.zrootsB47
  cntM := bodyCntM47
  hiLe := Nat.le_of_ble_eq_true bodyHi47
  nhiLe := Nat.le_of_ble_eq_true bodyNhi47
  jsHeap := bodyJs47
  jsRoots := bodyJsRoots47
  jsNative := bodyJsNative47
  framesEmpty := bodyFramesEmpty47
  trailOld := by decide
  lowVars := bodyLow47

def bodyQs47 : List (Option Q) := []
noncomputable def bodyEs47 : List (Option SymE) := PRE_first_tail_x4_L7_r0_body.nr47.map fun r => nth? PRE_first_tail_x4_L7_r0_body.st47.S3.tab r
kernel_rfl bodyResChk47 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs47 bodyQs47) = true
kernel_rfl bodyLq47 : bodyQs47.length = PRE_first_tail_x4_L7_r0_body.cws47.length
kernel_rfl bodyNrLo47 : PRE_first_tail_x4_L7_r0_body.nr47.all (Nat.ble PRE_first_tail_x4_L7_r0_body.S1060.tab.length) = true
kernel_rfl bodySub47 : (Oracles.PRE_first_tail_x4_L7_r0_body.map_site47.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost47 : postSubB bodyM PRE_first_tail_x4_L7_r0_body.ws47 PRE_first_tail_x4_L7_r0_body.cws47 bodyQs47 = true
kernel_rfl bodyDrop47 : Nat.ble (49328 + (PRE_first_tail_x4_L7_r0_body.s1061.next - PRE_first_tail_x4_L7_r0_body.s1062.next)) 49678 = true
kernel_rfl bodyDropH47 : Nat.ble (943 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s1061.ffi).next - (mlxOf PRE_first_tail_x4_L7_r0_body.s1062.ffi).next)) 945 = true
kernel_rfl bodyDropN47 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L7_r0_body.s1061.ffi).nnext - (mlxOf PRE_first_tail_x4_L7_r0_body.s1062.ffi).nnext)) 0 = true
kernel_rfl bodyDv47 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L7_r0_body.cws47
kernel_rfl bodyDe47 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L7_r0_body.nr47.map (fun r =>
  ((nth? PRE_first_tail_x4_L7_r0_body.st47.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl47 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold47 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L7_r0_body.cws47).isNone && !PRE_first_tail_x4_L7_r0_body.ws47.contains v) = true
kernel_rfl bodyDfree47 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L7_r0_body.cws47 ++ PRE_first_tail_x4_L7_r0_body.ws47).all fun w => e.noVar w) = true

theorem bodyStep47 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨49328, 943, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1060 PRE_first_tail_x4_L7_r0_body.S1060)
      (bodyCut NB T tk π i x0 bodyΘ ⟨49678, 945, 0, 0⟩ bodyM PRE_first_tail_x4_L7_r0_body.s1062 PRE_first_tail_x4_L7_r0_body.S1062) (3452 + 1) :=
  bodySite bodyFacts47.cfix bodyFacts47.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L7_r0_body.st47.S3.tab) (Es := bodyEs47) (qs := bodyQs47)
    (ok := PRE_first_tail_x4_L7_r0_body.st47.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L7_r0_body.site47 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts47
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L7_r0_body.chk_site47 r hr) hi (MapOk.sub hm (sub_of_all bodySub47)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk47 r hr) hi hm ho hq)
    bodyLq47 rfl bodyNrLo47 (postSub_sound bodyPost47)
    (Nat.le_of_ble_eq_true bodyDrop47) (by decide) (Nat.le_of_ble_eq_true bodyDropH47) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN47) (by decide)
    bodyDv47 bodyDe47 bodyDl47 bodyDold47 bodyDfree47 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L7

end
