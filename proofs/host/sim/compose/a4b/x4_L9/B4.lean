import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.States
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B19
import host.sim.compose.a4b.x4_L9.B3
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B24
import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L9.VWBodyChain
import host.sim.compose.a4b.x4_L9.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B14
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B13
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B20

section -- VWBodyOracles_8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_g32 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g32 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g32) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site32 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site32 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site32) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st32.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g33 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g33 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g33) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site33 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site33 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site33) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st33.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g34 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g34 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g34) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site34 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site34 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site34) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st34.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g35 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g35 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g35) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site35 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site35 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site35) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st35.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site32 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site32 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site32) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st32.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site32
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st32.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st32.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s728 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s729 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S728 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws32 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st32.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st32.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso32
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_32
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st32.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot32
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup32
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound32
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace32
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged32
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws32.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st32.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S728.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_32]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen32.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh32
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl32 : Conv.NClean (⟨20208, 17278, 2755629, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s728.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl32 (PRE_first_tail_x4_L9_r0_body.cncl31 bodyNcl31)

theorem bodyClean32 : Conv.JClean (⟨20208, 17278, 2755629, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s728 :=
  PRE_first_tail_x4_L9_r0_body.gjcl32 (PRE_first_tail_x4_L9_r0_body.cjcl31 bodyClean31)

kernel_rfl bodyJsLe32 : Nat.ble PRE_first_tail_x4_L9_r0_body.s704.next PRE_first_tail_x4_L9_r0_body.s728.next = true
kernel_rfl bodyJsList32 : (PRE_first_tail_x4_L9_r0_body.gjh32 ++ PRE_first_tail_x4_L9_r0_body.cl32).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s728.next) PRE_first_tail_x4_L9_r0_body.s730) = true
theorem bodyJs32 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s728.next PRE_first_tail_x4_L9_r0_body.s730 :=
  JsHeapAbove.glueSite bodyJs31 (Nat.le_of_ble_eq_true bodyJsLe32) PRE_first_tail_x4_L9_r0_body.gjk32 PRE_first_tail_x4_L9_r0_body.gjbd32 PRE_first_tail_x4_L9_r0_body.cheap32 PRE_first_tail_x4_L9_r0_body.zclbd32 bodyJsList32

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO706 : PRE_first_tail_x4_L9_r0_body.S706.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S706.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr706 : bridgeOf PRE_first_tail_x4_L9_r0_body.s706.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc706 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s706 PRE_first_tail_x4_L9_r0_body.S706) = fun _ _ => true
kernel_rfl bodyAcc709 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s709 PRE_first_tail_x4_L9_r0_body.S709) = fun _ _ => true
kernel_rfl bodyBr710 : bridgeOf PRE_first_tail_x4_L9_r0_body.s710.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt709 : isHalt PRE_first_tail_x4_L9_r0_body.s709.ctl = false
kernel_rfl bodyTop710 : noRetBlock PRE_first_tail_x4_L9_r0_body.s710 = true
kernel_rfl bodyCnt706 : countersOkB PRE_first_tail_x4_L9_r0_body.s706 PRE_first_tail_x4_L9_r0_body.s710 = true
kernel_rfl bodyO710 : PRE_first_tail_x4_L9_r0_body.S710.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S710.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr711 : bridgeOf PRE_first_tail_x4_L9_r0_body.s711.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt710 : countersOkB PRE_first_tail_x4_L9_r0_body.s710 PRE_first_tail_x4_L9_r0_body.s711 = true
kernel_rfl bodyO711 : PRE_first_tail_x4_L9_r0_body.S711.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S711.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc711 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s711 PRE_first_tail_x4_L9_r0_body.S711) = fun _ _ => true
kernel_rfl bodyAcc715 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s715 PRE_first_tail_x4_L9_r0_body.S715) = fun _ _ => true
kernel_rfl bodyBr716 : bridgeOf PRE_first_tail_x4_L9_r0_body.s716.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt715 : isHalt PRE_first_tail_x4_L9_r0_body.s715.ctl = false
kernel_rfl bodyTop716 : noRetBlock PRE_first_tail_x4_L9_r0_body.s716 = true
kernel_rfl bodyCnt711 : countersOkB PRE_first_tail_x4_L9_r0_body.s711 PRE_first_tail_x4_L9_r0_body.s716 = true
kernel_rfl bodyO716 : PRE_first_tail_x4_L9_r0_body.S716.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S716.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr717 : bridgeOf PRE_first_tail_x4_L9_r0_body.s717.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt716 : countersOkB PRE_first_tail_x4_L9_r0_body.s716 PRE_first_tail_x4_L9_r0_body.s717 = true
kernel_rfl bodyO717 : PRE_first_tail_x4_L9_r0_body.S717.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S717.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc717 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s717 PRE_first_tail_x4_L9_r0_body.S717) = fun _ _ => true
kernel_rfl bodyAcc718 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s718 PRE_first_tail_x4_L9_r0_body.S718) = fun _ _ => true
kernel_rfl bodyBr719 : bridgeOf PRE_first_tail_x4_L9_r0_body.s719.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt718 : isHalt PRE_first_tail_x4_L9_r0_body.s718.ctl = false
kernel_rfl bodyTop719 : noRetBlock PRE_first_tail_x4_L9_r0_body.s719 = true
kernel_rfl bodyCnt717 : countersOkB PRE_first_tail_x4_L9_r0_body.s717 PRE_first_tail_x4_L9_r0_body.s719 = true
kernel_rfl bodyO719 : PRE_first_tail_x4_L9_r0_body.S719.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S719.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr720 : bridgeOf PRE_first_tail_x4_L9_r0_body.s720.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt719 : countersOkB PRE_first_tail_x4_L9_r0_body.s719 PRE_first_tail_x4_L9_r0_body.s720 = true
kernel_rfl bodyO720 : PRE_first_tail_x4_L9_r0_body.S720.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S720.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc720 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s720 PRE_first_tail_x4_L9_r0_body.S720) = fun _ _ => true
kernel_rfl bodyAcc721 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s721 PRE_first_tail_x4_L9_r0_body.S721) = fun _ _ => true
kernel_rfl bodyBr722 : bridgeOf PRE_first_tail_x4_L9_r0_body.s722.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt721 : isHalt PRE_first_tail_x4_L9_r0_body.s721.ctl = false
kernel_rfl bodyTop722 : noRetBlock PRE_first_tail_x4_L9_r0_body.s722 = true
kernel_rfl bodyCnt720 : countersOkB PRE_first_tail_x4_L9_r0_body.s720 PRE_first_tail_x4_L9_r0_body.s722 = true
kernel_rfl bodyO722 : PRE_first_tail_x4_L9_r0_body.S722.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S722.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr723 : bridgeOf PRE_first_tail_x4_L9_r0_body.s723.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt722 : countersOkB PRE_first_tail_x4_L9_r0_body.s722 PRE_first_tail_x4_L9_r0_body.s723 = true
kernel_rfl bodyO723 : PRE_first_tail_x4_L9_r0_body.S723.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S723.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc723 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s723 PRE_first_tail_x4_L9_r0_body.S723) = fun _ _ => true
kernel_rfl bodyAcc724 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s724 PRE_first_tail_x4_L9_r0_body.S724) = fun _ _ => true
kernel_rfl bodyBr725 : bridgeOf PRE_first_tail_x4_L9_r0_body.s725.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt724 : isHalt PRE_first_tail_x4_L9_r0_body.s724.ctl = false
kernel_rfl bodyTop725 : noRetBlock PRE_first_tail_x4_L9_r0_body.s725 = true
kernel_rfl bodyCnt723 : countersOkB PRE_first_tail_x4_L9_r0_body.s723 PRE_first_tail_x4_L9_r0_body.s725 = true
kernel_rfl bodyO725 : PRE_first_tail_x4_L9_r0_body.S725.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S725.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr726 : bridgeOf PRE_first_tail_x4_L9_r0_body.s726.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt725 : countersOkB PRE_first_tail_x4_L9_r0_body.s725 PRE_first_tail_x4_L9_r0_body.s726 = true
kernel_rfl bodyO726 : PRE_first_tail_x4_L9_r0_body.S726.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S726.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc726 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s726 PRE_first_tail_x4_L9_r0_body.S726) = fun _ _ => true
kernel_rfl bodyAcc727 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s727 PRE_first_tail_x4_L9_r0_body.S727) = fun _ _ => true
kernel_rfl bodyBr728 : bridgeOf PRE_first_tail_x4_L9_r0_body.s728.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt727 : isHalt PRE_first_tail_x4_L9_r0_body.s727.ctl = false
kernel_rfl bodyTop728 : noRetBlock PRE_first_tail_x4_L9_r0_body.s728 = true
kernel_rfl bodyCnt726 : countersOkB PRE_first_tail_x4_L9_r0_body.s726 PRE_first_tail_x4_L9_r0_body.s728 = true

theorem bodyGlue32 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34490, 637, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s706 PRE_first_tail_x4_L9_r0_body.S706)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34490, 637, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s728 PRE_first_tail_x4_L9_r0_body.S728) 30942 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) bodyAcc706 PRE_first_tail_x4_L9_r0_body.bodyRunSeg183 bodyAcc709 bodyHalt709 PRE_first_tail_x4_L9_r0_body.bodyStepA184 bodyTop710 (fun _ hm => bodyO706 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr706).trans bodyInactive0) (bodyBr710.trans bodyBr706.symm) bodyCnt706 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA184 PRE_first_tail_x4_L9_r0_body.sizeArgsA184 PRE_first_tail_x4_L9_r0_body.sizeSymA184 PRE_first_tail_x4_L9_r0_body.sizeMlxA184 PRE_first_tail_x4_L9_r0_body.sizePayA184 PRE_first_tail_x4_L9_r0_body.sizeTaA184 PRE_first_tail_x4_L9_r0_body.sizeDecA184 PRE_first_tail_x4_L9_r0_body.sizePreA184 PRE_first_tail_x4_L9_r0_body.bodyPatchB184 (fun _ hm => bodyO710 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr710).trans bodyInactive0) (bodyBr711.trans bodyBr710.symm) bodyCnt710 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) bodyAcc711 PRE_first_tail_x4_L9_r0_body.bodyRunSeg184 bodyAcc715 bodyHalt715 PRE_first_tail_x4_L9_r0_body.bodyStepA185 bodyTop716 (fun _ hm => bodyO711 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr711).trans bodyInactive0) (bodyBr716.trans bodyBr711.symm) bodyCnt711 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA185 PRE_first_tail_x4_L9_r0_body.sizeArgsA185 PRE_first_tail_x4_L9_r0_body.sizeSymA185 PRE_first_tail_x4_L9_r0_body.sizeMlxA185 PRE_first_tail_x4_L9_r0_body.sizePayA185 PRE_first_tail_x4_L9_r0_body.sizeTaA185 PRE_first_tail_x4_L9_r0_body.sizeDecA185 PRE_first_tail_x4_L9_r0_body.sizePreA185 PRE_first_tail_x4_L9_r0_body.bodyPatchB185 (fun _ hm => bodyO716 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr716).trans bodyInactive0) (bodyBr717.trans bodyBr716.symm) bodyCnt716 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) bodyAcc717 PRE_first_tail_x4_L9_r0_body.bodyRunSeg185 bodyAcc718 bodyHalt718 PRE_first_tail_x4_L9_r0_body.bodyStepA186 bodyTop719 (fun _ hm => bodyO717 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr717).trans bodyInactive0) (bodyBr719.trans bodyBr717.symm) bodyCnt717 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA186 PRE_first_tail_x4_L9_r0_body.sizeArgsA186 PRE_first_tail_x4_L9_r0_body.sizeSymA186 PRE_first_tail_x4_L9_r0_body.sizeMlxA186 PRE_first_tail_x4_L9_r0_body.sizePayA186 PRE_first_tail_x4_L9_r0_body.sizeTaA186 PRE_first_tail_x4_L9_r0_body.sizeDecA186 PRE_first_tail_x4_L9_r0_body.sizePreA186 PRE_first_tail_x4_L9_r0_body.bodyPatchB186 (fun _ hm => bodyO719 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr719).trans bodyInactive0) (bodyBr720.trans bodyBr719.symm) bodyCnt719 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) bodyAcc720 PRE_first_tail_x4_L9_r0_body.bodyRunSeg186 bodyAcc721 bodyHalt721 PRE_first_tail_x4_L9_r0_body.bodyStepA187 bodyTop722 (fun _ hm => bodyO720 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr720).trans bodyInactive0) (bodyBr722.trans bodyBr720.symm) bodyCnt720 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA187 PRE_first_tail_x4_L9_r0_body.sizeArgsA187 PRE_first_tail_x4_L9_r0_body.sizeSymA187 PRE_first_tail_x4_L9_r0_body.sizeMlxA187 PRE_first_tail_x4_L9_r0_body.sizePayA187 PRE_first_tail_x4_L9_r0_body.sizeTaA187 PRE_first_tail_x4_L9_r0_body.sizeDecA187 PRE_first_tail_x4_L9_r0_body.sizePreA187 PRE_first_tail_x4_L9_r0_body.bodyPatchB187 (fun _ hm => bodyO722 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr722).trans bodyInactive0) (bodyBr723.trans bodyBr722.symm) bodyCnt722 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) bodyAcc723 PRE_first_tail_x4_L9_r0_body.bodyRunSeg187 bodyAcc724 bodyHalt724 PRE_first_tail_x4_L9_r0_body.bodyStepA188 bodyTop725 (fun _ hm => bodyO723 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr723).trans bodyInactive0) (bodyBr725.trans bodyBr723.symm) bodyCnt723 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA188 PRE_first_tail_x4_L9_r0_body.sizeArgsA188 PRE_first_tail_x4_L9_r0_body.sizeSymA188 PRE_first_tail_x4_L9_r0_body.sizeMlxA188 PRE_first_tail_x4_L9_r0_body.sizePayA188 PRE_first_tail_x4_L9_r0_body.sizeTaA188 PRE_first_tail_x4_L9_r0_body.sizeDecA188 PRE_first_tail_x4_L9_r0_body.sizePreA188 PRE_first_tail_x4_L9_r0_body.bodyPatchB188 (fun _ hm => bodyO725 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr725).trans bodyInactive0) (bodyBr726.trans bodyBr725.symm) bodyCnt725 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34490, 637, 0, 0⟩) bodyAcc726 PRE_first_tail_x4_L9_r0_body.bodyRunSeg188 bodyAcc727 bodyHalt727 PRE_first_tail_x4_L9_r0_body.bodyStepA189 bodyTop728 (fun _ hm => bodyO726 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr726).trans bodyInactive0) (bodyBr728.trans bodyBr726.symm) bodyCnt726 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift32 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S728.tab.length PRE_first_tail_x4_L9_r0_body.s728.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P32.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P32 15 PRE_first_tail_x4_L9_r0_body.kappa32 PRE_first_tail_x4_L9_r0_body.s730.ffi PRE_first_tail_x4_L9_r0_body.s729.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_32
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_32
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s730.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S728.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_32] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK32 PRE_first_tail_x4_L9_r0_body.cobjsK32
      PRE_first_tail_x4_L9_r0_body.citemsK32 PRE_first_tail_x4_L9_r0_body.cbd32 PRE_first_tail_x4_L9_r0_body.csst32
  exact PRE_first_tail_x4_L9_r0_body.cshift32 bodyNcl32 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_32] at this; exact this)


kernel_rfl bodyFramesEmpty32 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s729 a).isEmpty) = true
kernel_rfl bodyJsRoots32 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s728.next) PRE_first_tail_x4_L9_r0_body.s730.trace PRE_first_tail_x4_L9_r0_body.s730 = true
kernel_rfl bodyJsNative32 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s730.ffi) = true
kernel_rfl bodyLow32 : (PRE_first_tail_x4_L9_r0_body.cws32 ++ PRE_first_tail_x4_L9_r0_body.ws32).all (Nat.ble 9) = true
kernel_rfl bodyCntM32 : countersOkB PRE_first_tail_x4_L9_r0_body.s728 PRE_first_tail_x4_L9_r0_body.s729 = true
kernel_rfl bodyHi32 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s730.ffi).next setupP.E = true
kernel_rfl bodyNhi32 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s730.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge32 : bridgeOf PRE_first_tail_x4_L9_r0_body.s729.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s728.ffi
kernel_rfl bodyNN32 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s728.ffi).nnext PRE_first_tail_x4_L9_r0_body.P32.NL = true
kernel_rfl bodyXn32 : Nat.ble (⟨20211, 17305, 2755635, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s730.ffi).next = true
kernel_rfl bodyLo32 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s730.ffi).next = true
theorem bodyFacts32 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s728 PRE_first_tail_x4_L9_r0_body.s729 PRE_first_tail_x4_L9_r0_body.s730 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S728 PRE_first_tail_x4_L9_r0_body.S729 PRE_first_tail_x4_L9_r0_body.S730
    PRE_first_tail_x4_L9_r0_body.ws32 PRE_first_tail_x4_L9_r0_body.cws32 PRE_first_tail_x4_L9_r0_body.nr32 PRE_first_tail_x4_L9_r0_body.pl32 PRE_first_tail_x4_L9_r0_body.cl32 2756784 15 PRE_first_tail_x4_L9_r0_body.kd32 PRE_first_tail_x4_L9_r0_body.kappa32 PRE_first_tail_x4_L9_r0_body.P32
    ⟨20208, 17278, 2755629, 15⟩ ⟨20211, 17305, 2755635, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap32
  clean := bodyClean32
  cfix := PRE_first_tail_x4_L9_r0_body.cfix32
  zpl := PRE_first_tail_x4_L9_r0_body.zpl32
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd32
  zn1 := PRE_first_tail_x4_L9_r0_body.zn132
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst32
  zscn := PRE_first_tail_x4_L9_r0_body.zscn32
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn32
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow32
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab32
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh32
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd32
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi32
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt32
  zgP := PRE_first_tail_x4_L9_r0_body.zg32_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk32_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm32_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg32_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk32_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm32_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw32_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw32_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap32
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd32
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap32 PRE_first_tail_x4_L9_r0_body.stFoot32 PRE_first_tail_x4_L9_r0_body.iso32 PRE_first_tail_x4_L9_r0_body.zwr32
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP32
  csupp := PRE_first_tail_x4_L9_r0_body.csupp32
  cbound := PRE_first_tail_x4_L9_r0_body.cbound32
  zimg := PRE_first_tail_x4_L9_r0_body.zimg32
  zctl := PRE_first_tail_x4_L9_r0_body.zctl32
  zstack := PRE_first_tail_x4_L9_r0_body.zstack32
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs32
  zstores := PRE_first_tail_x4_L9_r0_body.zstores32
  zroots := PRE_first_tail_x4_L9_r0_body.zroots32
  znC := PRE_first_tail_x4_L9_r0_body.znC32
  ctab := PRE_first_tail_x4_L9_r0_body.ctab32
  zbin := PRE_first_tail_x4_L9_r0_body.zbin32
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge32
  sbridge := bodyBridge32
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj32
  cshiftR := fun h hNL => bodyCshift32 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN32
  raised := PRE_first_tail_x4_L9_r0_body.raised32
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs32
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl32
  xnLe := Nat.le_of_ble_eq_true bodyXn32
  loLe := Nat.le_of_ble_eq_true bodyLo32
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB32
  cntM := bodyCntM32
  hiLe := Nat.le_of_ble_eq_true bodyHi32
  nhiLe := Nat.le_of_ble_eq_true bodyNhi32
  jsHeap := bodyJs32
  jsRoots := bodyJsRoots32
  jsNative := bodyJsNative32
  framesEmpty := bodyFramesEmpty32
  trailOld := by decide
  lowVars := bodyLow32

def bodyQs32 : List (Option Q) := []
noncomputable def bodyEs32 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr32.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st32.S5.tab r
kernel_rfl bodyResChk32 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs32 bodyQs32) = true
kernel_rfl bodyLq32 : bodyQs32.length = PRE_first_tail_x4_L9_r0_body.cws32.length
kernel_rfl bodyNrLo32 : PRE_first_tail_x4_L9_r0_body.nr32.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S728.tab.length) = true
kernel_rfl bodySub32 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site32.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost32 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws32 PRE_first_tail_x4_L9_r0_body.cws32 bodyQs32 = true
kernel_rfl bodyDrop32 : Nat.ble (34490 + (PRE_first_tail_x4_L9_r0_body.s729.next - PRE_first_tail_x4_L9_r0_body.s730.next)) 35639 = true
kernel_rfl bodyDropH32 : Nat.ble (637 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s729.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s730.ffi).next)) 662 = true
kernel_rfl bodyDropN32 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s729.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s730.ffi).nnext)) 0 = true
kernel_rfl bodyDv32 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws32
kernel_rfl bodyDe32 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr32.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st32.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl32 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold32 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws32).isNone && !PRE_first_tail_x4_L9_r0_body.ws32.contains v) = true
kernel_rfl bodyDfree32 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws32 ++ PRE_first_tail_x4_L9_r0_body.ws32).all fun w => e.noVar w) = true

theorem bodyStep32 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34490, 637, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s728 PRE_first_tail_x4_L9_r0_body.S728)
      (bodyCut NB T tk π i x0 bodyΘ ⟨35639, 662, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s730 PRE_first_tail_x4_L9_r0_body.S730) (11334 + 1) :=
  bodySite bodyFacts32.cfix bodyFacts32.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st32.S5.tab) (Es := bodyEs32) (qs := bodyQs32)
    (ok := PRE_first_tail_x4_L9_r0_body.st32.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site32 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts32
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site32 r hr) hi (MapOk.sub hm (sub_of_all bodySub32)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk32 r hr) hi hm ho hq)
    bodyLq32 rfl bodyNrLo32 (postSub_sound bodyPost32)
    (Nat.le_of_ble_eq_true bodyDrop32) (by decide) (Nat.le_of_ble_eq_true bodyDropH32) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN32) (by decide)
    bodyDv32 bodyDe32 bodyDl32 bodyDold32 bodyDfree32 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site33 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site33 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site33) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st33.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site33
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st33.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st33.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s750 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s751 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S750 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws33 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st33.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st33.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso33
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_33
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st33.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot33
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup33
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound33
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace33
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged33
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws33.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st33.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S750.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_33]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen33.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh33
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl33 : Conv.NClean (⟨20265, 17341, 2757871, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s750.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl33 (PRE_first_tail_x4_L9_r0_body.cncl32 bodyNcl32)

theorem bodyClean33 : Conv.JClean (⟨20265, 17341, 2757871, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s750 :=
  PRE_first_tail_x4_L9_r0_body.gjcl33 (PRE_first_tail_x4_L9_r0_body.cjcl32 bodyClean32)

kernel_rfl bodyJsLe33 : Nat.ble PRE_first_tail_x4_L9_r0_body.s728.next PRE_first_tail_x4_L9_r0_body.s750.next = true
kernel_rfl bodyJsList33 : (PRE_first_tail_x4_L9_r0_body.gjh33 ++ PRE_first_tail_x4_L9_r0_body.cl33).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s750.next) PRE_first_tail_x4_L9_r0_body.s752) = true
theorem bodyJs33 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s750.next PRE_first_tail_x4_L9_r0_body.s752 :=
  JsHeapAbove.glueSite bodyJs32 (Nat.le_of_ble_eq_true bodyJsLe33) PRE_first_tail_x4_L9_r0_body.gjk33 PRE_first_tail_x4_L9_r0_body.gjbd33 PRE_first_tail_x4_L9_r0_body.cheap33 PRE_first_tail_x4_L9_r0_body.zclbd33 bodyJsList33

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO730 : PRE_first_tail_x4_L9_r0_body.S730.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S730.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr730 : bridgeOf PRE_first_tail_x4_L9_r0_body.s730.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc730 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s730 PRE_first_tail_x4_L9_r0_body.S730) = fun _ _ => true
kernel_rfl bodyAcc731 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s731 PRE_first_tail_x4_L9_r0_body.S731) = fun _ _ => true
kernel_rfl bodyBr732 : bridgeOf PRE_first_tail_x4_L9_r0_body.s732.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt731 : isHalt PRE_first_tail_x4_L9_r0_body.s731.ctl = false
kernel_rfl bodyTop732 : noRetBlock PRE_first_tail_x4_L9_r0_body.s732 = true
kernel_rfl bodyCnt730 : countersOkB PRE_first_tail_x4_L9_r0_body.s730 PRE_first_tail_x4_L9_r0_body.s732 = true
kernel_rfl bodyO732 : PRE_first_tail_x4_L9_r0_body.S732.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S732.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr733 : bridgeOf PRE_first_tail_x4_L9_r0_body.s733.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt732 : countersOkB PRE_first_tail_x4_L9_r0_body.s732 PRE_first_tail_x4_L9_r0_body.s733 = true
kernel_rfl bodyO733 : PRE_first_tail_x4_L9_r0_body.S733.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S733.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc733 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s733 PRE_first_tail_x4_L9_r0_body.S733) = fun _ _ => true
kernel_rfl bodyAcc737 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s737 PRE_first_tail_x4_L9_r0_body.S737) = fun _ _ => true
kernel_rfl bodyBr738 : bridgeOf PRE_first_tail_x4_L9_r0_body.s738.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt737 : isHalt PRE_first_tail_x4_L9_r0_body.s737.ctl = false
kernel_rfl bodyTop738 : noRetBlock PRE_first_tail_x4_L9_r0_body.s738 = true
kernel_rfl bodyCnt733 : countersOkB PRE_first_tail_x4_L9_r0_body.s733 PRE_first_tail_x4_L9_r0_body.s738 = true
kernel_rfl bodyO738 : PRE_first_tail_x4_L9_r0_body.S738.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S738.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr739 : bridgeOf PRE_first_tail_x4_L9_r0_body.s739.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt738 : countersOkB PRE_first_tail_x4_L9_r0_body.s738 PRE_first_tail_x4_L9_r0_body.s739 = true
kernel_rfl bodyO739 : PRE_first_tail_x4_L9_r0_body.S739.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S739.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc739 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s739 PRE_first_tail_x4_L9_r0_body.S739) = fun _ _ => true
kernel_rfl bodyAcc740 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s740 PRE_first_tail_x4_L9_r0_body.S740) = fun _ _ => true
kernel_rfl bodyBr741 : bridgeOf PRE_first_tail_x4_L9_r0_body.s741.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt740 : isHalt PRE_first_tail_x4_L9_r0_body.s740.ctl = false
kernel_rfl bodyTop741 : noRetBlock PRE_first_tail_x4_L9_r0_body.s741 = true
kernel_rfl bodyCnt739 : countersOkB PRE_first_tail_x4_L9_r0_body.s739 PRE_first_tail_x4_L9_r0_body.s741 = true
kernel_rfl bodyO741 : PRE_first_tail_x4_L9_r0_body.S741.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S741.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr742 : bridgeOf PRE_first_tail_x4_L9_r0_body.s742.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt741 : countersOkB PRE_first_tail_x4_L9_r0_body.s741 PRE_first_tail_x4_L9_r0_body.s742 = true
kernel_rfl bodyO742 : PRE_first_tail_x4_L9_r0_body.S742.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S742.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc742 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s742 PRE_first_tail_x4_L9_r0_body.S742) = fun _ _ => true
kernel_rfl bodyAcc743 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s743 PRE_first_tail_x4_L9_r0_body.S743) = fun _ _ => true
kernel_rfl bodyBr744 : bridgeOf PRE_first_tail_x4_L9_r0_body.s744.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt743 : isHalt PRE_first_tail_x4_L9_r0_body.s743.ctl = false
kernel_rfl bodyTop744 : noRetBlock PRE_first_tail_x4_L9_r0_body.s744 = true
kernel_rfl bodyCnt742 : countersOkB PRE_first_tail_x4_L9_r0_body.s742 PRE_first_tail_x4_L9_r0_body.s744 = true
kernel_rfl bodyO744 : PRE_first_tail_x4_L9_r0_body.S744.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S744.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr745 : bridgeOf PRE_first_tail_x4_L9_r0_body.s745.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt744 : countersOkB PRE_first_tail_x4_L9_r0_body.s744 PRE_first_tail_x4_L9_r0_body.s745 = true
kernel_rfl bodyO745 : PRE_first_tail_x4_L9_r0_body.S745.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S745.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc745 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s745 PRE_first_tail_x4_L9_r0_body.S745) = fun _ _ => true
kernel_rfl bodyAcc746 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s746 PRE_first_tail_x4_L9_r0_body.S746) = fun _ _ => true
kernel_rfl bodyBr747 : bridgeOf PRE_first_tail_x4_L9_r0_body.s747.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt746 : isHalt PRE_first_tail_x4_L9_r0_body.s746.ctl = false
kernel_rfl bodyTop747 : noRetBlock PRE_first_tail_x4_L9_r0_body.s747 = true
kernel_rfl bodyCnt745 : countersOkB PRE_first_tail_x4_L9_r0_body.s745 PRE_first_tail_x4_L9_r0_body.s747 = true
kernel_rfl bodyO747 : PRE_first_tail_x4_L9_r0_body.S747.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S747.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr748 : bridgeOf PRE_first_tail_x4_L9_r0_body.s748.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt747 : countersOkB PRE_first_tail_x4_L9_r0_body.s747 PRE_first_tail_x4_L9_r0_body.s748 = true
kernel_rfl bodyO748 : PRE_first_tail_x4_L9_r0_body.S748.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S748.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc748 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s748 PRE_first_tail_x4_L9_r0_body.S748) = fun _ _ => true
kernel_rfl bodyAcc749 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s749 PRE_first_tail_x4_L9_r0_body.S749) = fun _ _ => true
kernel_rfl bodyBr750 : bridgeOf PRE_first_tail_x4_L9_r0_body.s750.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt749 : isHalt PRE_first_tail_x4_L9_r0_body.s749.ctl = false
kernel_rfl bodyTop750 : noRetBlock PRE_first_tail_x4_L9_r0_body.s750 = true
kernel_rfl bodyCnt748 : countersOkB PRE_first_tail_x4_L9_r0_body.s748 PRE_first_tail_x4_L9_r0_body.s750 = true

theorem bodyGlue33 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨35639, 662, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s730 PRE_first_tail_x4_L9_r0_body.S730)
      (bodyCut NB T tk π i x0 bodyΘ ⟨35639, 662, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s750 PRE_first_tail_x4_L9_r0_body.S750) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) bodyAcc730 PRE_first_tail_x4_L9_r0_body.bodyRunSeg189 bodyAcc731 bodyHalt731 PRE_first_tail_x4_L9_r0_body.bodyStepA190 bodyTop732 (fun _ hm => bodyO730 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr730).trans bodyInactive0) (bodyBr732.trans bodyBr730.symm) bodyCnt730 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA190 PRE_first_tail_x4_L9_r0_body.sizeArgsA190 PRE_first_tail_x4_L9_r0_body.sizeSymA190 PRE_first_tail_x4_L9_r0_body.sizeMlxA190 PRE_first_tail_x4_L9_r0_body.sizePayA190 PRE_first_tail_x4_L9_r0_body.sizeTaA190 PRE_first_tail_x4_L9_r0_body.sizeDecA190 PRE_first_tail_x4_L9_r0_body.sizePreA190 PRE_first_tail_x4_L9_r0_body.bodyPatchB190 (fun _ hm => bodyO732 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr732).trans bodyInactive0) (bodyBr733.trans bodyBr732.symm) bodyCnt732 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) bodyAcc733 PRE_first_tail_x4_L9_r0_body.bodyRunSeg190 bodyAcc737 bodyHalt737 PRE_first_tail_x4_L9_r0_body.bodyStepA191 bodyTop738 (fun _ hm => bodyO733 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr733).trans bodyInactive0) (bodyBr738.trans bodyBr733.symm) bodyCnt733 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA191 PRE_first_tail_x4_L9_r0_body.sizeArgsA191 PRE_first_tail_x4_L9_r0_body.sizeSymA191 PRE_first_tail_x4_L9_r0_body.sizeMlxA191 PRE_first_tail_x4_L9_r0_body.sizePayA191 PRE_first_tail_x4_L9_r0_body.sizeTaA191 PRE_first_tail_x4_L9_r0_body.sizeDecA191 PRE_first_tail_x4_L9_r0_body.sizePreA191 PRE_first_tail_x4_L9_r0_body.bodyPatchB191 (fun _ hm => bodyO738 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr738).trans bodyInactive0) (bodyBr739.trans bodyBr738.symm) bodyCnt738 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) bodyAcc739 PRE_first_tail_x4_L9_r0_body.bodyRunSeg191 bodyAcc740 bodyHalt740 PRE_first_tail_x4_L9_r0_body.bodyStepA192 bodyTop741 (fun _ hm => bodyO739 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr739).trans bodyInactive0) (bodyBr741.trans bodyBr739.symm) bodyCnt739 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA192 PRE_first_tail_x4_L9_r0_body.sizeArgsA192 PRE_first_tail_x4_L9_r0_body.sizeSymA192 PRE_first_tail_x4_L9_r0_body.sizeMlxA192 PRE_first_tail_x4_L9_r0_body.sizePayA192 PRE_first_tail_x4_L9_r0_body.sizeTaA192 PRE_first_tail_x4_L9_r0_body.sizeDecA192 PRE_first_tail_x4_L9_r0_body.sizePreA192 PRE_first_tail_x4_L9_r0_body.bodyPatchB192 (fun _ hm => bodyO741 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr741).trans bodyInactive0) (bodyBr742.trans bodyBr741.symm) bodyCnt741 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) bodyAcc742 PRE_first_tail_x4_L9_r0_body.bodyRunSeg192 bodyAcc743 bodyHalt743 PRE_first_tail_x4_L9_r0_body.bodyStepA193 bodyTop744 (fun _ hm => bodyO742 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr742).trans bodyInactive0) (bodyBr744.trans bodyBr742.symm) bodyCnt742 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA193 PRE_first_tail_x4_L9_r0_body.sizeArgsA193 PRE_first_tail_x4_L9_r0_body.sizeSymA193 PRE_first_tail_x4_L9_r0_body.sizeMlxA193 PRE_first_tail_x4_L9_r0_body.sizePayA193 PRE_first_tail_x4_L9_r0_body.sizeTaA193 PRE_first_tail_x4_L9_r0_body.sizeDecA193 PRE_first_tail_x4_L9_r0_body.sizePreA193 PRE_first_tail_x4_L9_r0_body.bodyPatchB193 (fun _ hm => bodyO744 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr744).trans bodyInactive0) (bodyBr745.trans bodyBr744.symm) bodyCnt744 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) bodyAcc745 PRE_first_tail_x4_L9_r0_body.bodyRunSeg193 bodyAcc746 bodyHalt746 PRE_first_tail_x4_L9_r0_body.bodyStepA194 bodyTop747 (fun _ hm => bodyO745 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr745).trans bodyInactive0) (bodyBr747.trans bodyBr745.symm) bodyCnt745 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA194 PRE_first_tail_x4_L9_r0_body.sizeArgsA194 PRE_first_tail_x4_L9_r0_body.sizeSymA194 PRE_first_tail_x4_L9_r0_body.sizeMlxA194 PRE_first_tail_x4_L9_r0_body.sizePayA194 PRE_first_tail_x4_L9_r0_body.sizeTaA194 PRE_first_tail_x4_L9_r0_body.sizeDecA194 PRE_first_tail_x4_L9_r0_body.sizePreA194 PRE_first_tail_x4_L9_r0_body.bodyPatchB194 (fun _ hm => bodyO747 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr747).trans bodyInactive0) (bodyBr748.trans bodyBr747.symm) bodyCnt747 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨35639, 662, 0, 0⟩) bodyAcc748 PRE_first_tail_x4_L9_r0_body.bodyRunSeg194 bodyAcc749 bodyHalt749 PRE_first_tail_x4_L9_r0_body.bodyStepA195 bodyTop750 (fun _ hm => bodyO748 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr748).trans bodyInactive0) (bodyBr750.trans bodyBr748.symm) bodyCnt748 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift33 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S750.tab.length PRE_first_tail_x4_L9_r0_body.s750.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P33.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P33 15 PRE_first_tail_x4_L9_r0_body.kappa33 PRE_first_tail_x4_L9_r0_body.s752.ffi PRE_first_tail_x4_L9_r0_body.s751.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_33
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_33
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s752.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S750.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_33] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK33 PRE_first_tail_x4_L9_r0_body.cobjsK33
      PRE_first_tail_x4_L9_r0_body.citemsK33 PRE_first_tail_x4_L9_r0_body.cbd33 PRE_first_tail_x4_L9_r0_body.csst33
  exact PRE_first_tail_x4_L9_r0_body.cshift33 bodyNcl33 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_33] at this; exact this)


kernel_rfl bodyFramesEmpty33 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s751 a).isEmpty) = true
kernel_rfl bodyJsRoots33 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s750.next) PRE_first_tail_x4_L9_r0_body.s752.trace PRE_first_tail_x4_L9_r0_body.s752 = true
kernel_rfl bodyJsNative33 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s752.ffi) = true
kernel_rfl bodyLow33 : (PRE_first_tail_x4_L9_r0_body.cws33 ++ PRE_first_tail_x4_L9_r0_body.ws33).all (Nat.ble 9) = true
kernel_rfl bodyCntM33 : countersOkB PRE_first_tail_x4_L9_r0_body.s750 PRE_first_tail_x4_L9_r0_body.s751 = true
kernel_rfl bodyHi33 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s752.ffi).next setupP.E = true
kernel_rfl bodyNhi33 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s752.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge33 : bridgeOf PRE_first_tail_x4_L9_r0_body.s751.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s750.ffi
kernel_rfl bodyNN33 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s750.ffi).nnext PRE_first_tail_x4_L9_r0_body.P33.NL = true
kernel_rfl bodyXn33 : Nat.ble (⟨20268, 17368, 2757877, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s752.ffi).next = true
kernel_rfl bodyLo33 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s752.ffi).next = true
theorem bodyFacts33 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s750 PRE_first_tail_x4_L9_r0_body.s751 PRE_first_tail_x4_L9_r0_body.s752 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S750 PRE_first_tail_x4_L9_r0_body.S751 PRE_first_tail_x4_L9_r0_body.S752
    PRE_first_tail_x4_L9_r0_body.ws33 PRE_first_tail_x4_L9_r0_body.cws33 PRE_first_tail_x4_L9_r0_body.nr33 PRE_first_tail_x4_L9_r0_body.pl33 PRE_first_tail_x4_L9_r0_body.cl33 2759026 15 PRE_first_tail_x4_L9_r0_body.kd33 PRE_first_tail_x4_L9_r0_body.kappa33 PRE_first_tail_x4_L9_r0_body.P33
    ⟨20265, 17341, 2757871, 15⟩ ⟨20268, 17368, 2757877, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap33
  clean := bodyClean33
  cfix := PRE_first_tail_x4_L9_r0_body.cfix33
  zpl := PRE_first_tail_x4_L9_r0_body.zpl33
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd33
  zn1 := PRE_first_tail_x4_L9_r0_body.zn133
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst33
  zscn := PRE_first_tail_x4_L9_r0_body.zscn33
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn33
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow33
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab33
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh33
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd33
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi33
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt33
  zgP := PRE_first_tail_x4_L9_r0_body.zg33_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk33_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm33_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg33_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk33_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm33_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw33_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw33_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap33
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd33
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap33 PRE_first_tail_x4_L9_r0_body.stFoot33 PRE_first_tail_x4_L9_r0_body.iso33 PRE_first_tail_x4_L9_r0_body.zwr33
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP33
  csupp := PRE_first_tail_x4_L9_r0_body.csupp33
  cbound := PRE_first_tail_x4_L9_r0_body.cbound33
  zimg := PRE_first_tail_x4_L9_r0_body.zimg33
  zctl := PRE_first_tail_x4_L9_r0_body.zctl33
  zstack := PRE_first_tail_x4_L9_r0_body.zstack33
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs33
  zstores := PRE_first_tail_x4_L9_r0_body.zstores33
  zroots := PRE_first_tail_x4_L9_r0_body.zroots33
  znC := PRE_first_tail_x4_L9_r0_body.znC33
  ctab := PRE_first_tail_x4_L9_r0_body.ctab33
  zbin := PRE_first_tail_x4_L9_r0_body.zbin33
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge33
  sbridge := bodyBridge33
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj33
  cshiftR := fun h hNL => bodyCshift33 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN33
  raised := PRE_first_tail_x4_L9_r0_body.raised33
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs33
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl33
  xnLe := Nat.le_of_ble_eq_true bodyXn33
  loLe := Nat.le_of_ble_eq_true bodyLo33
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB33
  cntM := bodyCntM33
  hiLe := Nat.le_of_ble_eq_true bodyHi33
  nhiLe := Nat.le_of_ble_eq_true bodyNhi33
  jsHeap := bodyJs33
  jsRoots := bodyJsRoots33
  jsNative := bodyJsNative33
  framesEmpty := bodyFramesEmpty33
  trailOld := by decide
  lowVars := bodyLow33

def bodyQs33 : List (Option Q) := []
noncomputable def bodyEs33 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr33.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st33.S5.tab r
kernel_rfl bodyResChk33 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs33 bodyQs33) = true
kernel_rfl bodyLq33 : bodyQs33.length = PRE_first_tail_x4_L9_r0_body.cws33.length
kernel_rfl bodyNrLo33 : PRE_first_tail_x4_L9_r0_body.nr33.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S750.tab.length) = true
kernel_rfl bodySub33 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site33.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost33 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws33 PRE_first_tail_x4_L9_r0_body.cws33 bodyQs33 = true
kernel_rfl bodyDrop33 : Nat.ble (35639 + (PRE_first_tail_x4_L9_r0_body.s751.next - PRE_first_tail_x4_L9_r0_body.s752.next)) 36788 = true
kernel_rfl bodyDropH33 : Nat.ble (662 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s751.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s752.ffi).next)) 687 = true
kernel_rfl bodyDropN33 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s751.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s752.ffi).nnext)) 0 = true
kernel_rfl bodyDv33 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws33
kernel_rfl bodyDe33 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr33.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st33.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl33 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold33 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws33).isNone && !PRE_first_tail_x4_L9_r0_body.ws33.contains v) = true
kernel_rfl bodyDfree33 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws33 ++ PRE_first_tail_x4_L9_r0_body.ws33).all fun w => e.noVar w) = true

theorem bodyStep33 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨35639, 662, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s750 PRE_first_tail_x4_L9_r0_body.S750)
      (bodyCut NB T tk π i x0 bodyΘ ⟨36788, 687, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s752 PRE_first_tail_x4_L9_r0_body.S752) (11334 + 1) :=
  bodySite bodyFacts33.cfix bodyFacts33.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st33.S5.tab) (Es := bodyEs33) (qs := bodyQs33)
    (ok := PRE_first_tail_x4_L9_r0_body.st33.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site33 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts33
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site33 r hr) hi (MapOk.sub hm (sub_of_all bodySub33)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk33 r hr) hi hm ho hq)
    bodyLq33 rfl bodyNrLo33 (postSub_sound bodyPost33)
    (Nat.le_of_ble_eq_true bodyDrop33) (by decide) (Nat.le_of_ble_eq_true bodyDropH33) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN33) (by decide)
    bodyDv33 bodyDe33 bodyDl33 bodyDold33 bodyDfree33 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site34 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site34 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site34) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st34.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site34
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st34.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st34.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s772 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s773 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S772 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws34 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st34.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st34.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso34
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_34
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st34.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot34
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup34
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound34
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace34
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged34
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws34.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st34.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S772.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_34]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen34.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh34
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl34 : Conv.NClean (⟨20322, 17404, 2760113, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s772.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl34 (PRE_first_tail_x4_L9_r0_body.cncl33 bodyNcl33)

theorem bodyClean34 : Conv.JClean (⟨20322, 17404, 2760113, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s772 :=
  PRE_first_tail_x4_L9_r0_body.gjcl34 (PRE_first_tail_x4_L9_r0_body.cjcl33 bodyClean33)

kernel_rfl bodyJsLe34 : Nat.ble PRE_first_tail_x4_L9_r0_body.s750.next PRE_first_tail_x4_L9_r0_body.s772.next = true
kernel_rfl bodyJsList34 : (PRE_first_tail_x4_L9_r0_body.gjh34 ++ PRE_first_tail_x4_L9_r0_body.cl34).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s772.next) PRE_first_tail_x4_L9_r0_body.s774) = true
theorem bodyJs34 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s772.next PRE_first_tail_x4_L9_r0_body.s774 :=
  JsHeapAbove.glueSite bodyJs33 (Nat.le_of_ble_eq_true bodyJsLe34) PRE_first_tail_x4_L9_r0_body.gjk34 PRE_first_tail_x4_L9_r0_body.gjbd34 PRE_first_tail_x4_L9_r0_body.cheap34 PRE_first_tail_x4_L9_r0_body.zclbd34 bodyJsList34

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO752 : PRE_first_tail_x4_L9_r0_body.S752.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S752.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr752 : bridgeOf PRE_first_tail_x4_L9_r0_body.s752.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc752 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s752 PRE_first_tail_x4_L9_r0_body.S752) = fun _ _ => true
kernel_rfl bodyAcc753 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s753 PRE_first_tail_x4_L9_r0_body.S753) = fun _ _ => true
kernel_rfl bodyBr754 : bridgeOf PRE_first_tail_x4_L9_r0_body.s754.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt753 : isHalt PRE_first_tail_x4_L9_r0_body.s753.ctl = false
kernel_rfl bodyTop754 : noRetBlock PRE_first_tail_x4_L9_r0_body.s754 = true
kernel_rfl bodyCnt752 : countersOkB PRE_first_tail_x4_L9_r0_body.s752 PRE_first_tail_x4_L9_r0_body.s754 = true
kernel_rfl bodyO754 : PRE_first_tail_x4_L9_r0_body.S754.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S754.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr755 : bridgeOf PRE_first_tail_x4_L9_r0_body.s755.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt754 : countersOkB PRE_first_tail_x4_L9_r0_body.s754 PRE_first_tail_x4_L9_r0_body.s755 = true
kernel_rfl bodyO755 : PRE_first_tail_x4_L9_r0_body.S755.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S755.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc755 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s755 PRE_first_tail_x4_L9_r0_body.S755) = fun _ _ => true
kernel_rfl bodyAcc759 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s759 PRE_first_tail_x4_L9_r0_body.S759) = fun _ _ => true
kernel_rfl bodyBr760 : bridgeOf PRE_first_tail_x4_L9_r0_body.s760.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt759 : isHalt PRE_first_tail_x4_L9_r0_body.s759.ctl = false
kernel_rfl bodyTop760 : noRetBlock PRE_first_tail_x4_L9_r0_body.s760 = true
kernel_rfl bodyCnt755 : countersOkB PRE_first_tail_x4_L9_r0_body.s755 PRE_first_tail_x4_L9_r0_body.s760 = true
kernel_rfl bodyO760 : PRE_first_tail_x4_L9_r0_body.S760.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S760.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr761 : bridgeOf PRE_first_tail_x4_L9_r0_body.s761.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt760 : countersOkB PRE_first_tail_x4_L9_r0_body.s760 PRE_first_tail_x4_L9_r0_body.s761 = true
kernel_rfl bodyO761 : PRE_first_tail_x4_L9_r0_body.S761.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S761.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc761 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s761 PRE_first_tail_x4_L9_r0_body.S761) = fun _ _ => true
kernel_rfl bodyAcc762 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s762 PRE_first_tail_x4_L9_r0_body.S762) = fun _ _ => true
kernel_rfl bodyBr763 : bridgeOf PRE_first_tail_x4_L9_r0_body.s763.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt762 : isHalt PRE_first_tail_x4_L9_r0_body.s762.ctl = false
kernel_rfl bodyTop763 : noRetBlock PRE_first_tail_x4_L9_r0_body.s763 = true
kernel_rfl bodyCnt761 : countersOkB PRE_first_tail_x4_L9_r0_body.s761 PRE_first_tail_x4_L9_r0_body.s763 = true
kernel_rfl bodyO763 : PRE_first_tail_x4_L9_r0_body.S763.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S763.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr764 : bridgeOf PRE_first_tail_x4_L9_r0_body.s764.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt763 : countersOkB PRE_first_tail_x4_L9_r0_body.s763 PRE_first_tail_x4_L9_r0_body.s764 = true
kernel_rfl bodyO764 : PRE_first_tail_x4_L9_r0_body.S764.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S764.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc764 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s764 PRE_first_tail_x4_L9_r0_body.S764) = fun _ _ => true
kernel_rfl bodyAcc765 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s765 PRE_first_tail_x4_L9_r0_body.S765) = fun _ _ => true
kernel_rfl bodyBr766 : bridgeOf PRE_first_tail_x4_L9_r0_body.s766.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt765 : isHalt PRE_first_tail_x4_L9_r0_body.s765.ctl = false
kernel_rfl bodyTop766 : noRetBlock PRE_first_tail_x4_L9_r0_body.s766 = true
kernel_rfl bodyCnt764 : countersOkB PRE_first_tail_x4_L9_r0_body.s764 PRE_first_tail_x4_L9_r0_body.s766 = true
kernel_rfl bodyO766 : PRE_first_tail_x4_L9_r0_body.S766.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S766.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr767 : bridgeOf PRE_first_tail_x4_L9_r0_body.s767.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt766 : countersOkB PRE_first_tail_x4_L9_r0_body.s766 PRE_first_tail_x4_L9_r0_body.s767 = true
kernel_rfl bodyO767 : PRE_first_tail_x4_L9_r0_body.S767.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S767.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc767 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s767 PRE_first_tail_x4_L9_r0_body.S767) = fun _ _ => true
kernel_rfl bodyAcc768 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s768 PRE_first_tail_x4_L9_r0_body.S768) = fun _ _ => true
kernel_rfl bodyBr769 : bridgeOf PRE_first_tail_x4_L9_r0_body.s769.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt768 : isHalt PRE_first_tail_x4_L9_r0_body.s768.ctl = false
kernel_rfl bodyTop769 : noRetBlock PRE_first_tail_x4_L9_r0_body.s769 = true
kernel_rfl bodyCnt767 : countersOkB PRE_first_tail_x4_L9_r0_body.s767 PRE_first_tail_x4_L9_r0_body.s769 = true
kernel_rfl bodyO769 : PRE_first_tail_x4_L9_r0_body.S769.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S769.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr770 : bridgeOf PRE_first_tail_x4_L9_r0_body.s770.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt769 : countersOkB PRE_first_tail_x4_L9_r0_body.s769 PRE_first_tail_x4_L9_r0_body.s770 = true
kernel_rfl bodyO770 : PRE_first_tail_x4_L9_r0_body.S770.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S770.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc770 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s770 PRE_first_tail_x4_L9_r0_body.S770) = fun _ _ => true
kernel_rfl bodyAcc771 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s771 PRE_first_tail_x4_L9_r0_body.S771) = fun _ _ => true
kernel_rfl bodyBr772 : bridgeOf PRE_first_tail_x4_L9_r0_body.s772.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt771 : isHalt PRE_first_tail_x4_L9_r0_body.s771.ctl = false
kernel_rfl bodyTop772 : noRetBlock PRE_first_tail_x4_L9_r0_body.s772 = true
kernel_rfl bodyCnt770 : countersOkB PRE_first_tail_x4_L9_r0_body.s770 PRE_first_tail_x4_L9_r0_body.s772 = true

theorem bodyGlue34 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨36788, 687, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s752 PRE_first_tail_x4_L9_r0_body.S752)
      (bodyCut NB T tk π i x0 bodyΘ ⟨36788, 687, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s772 PRE_first_tail_x4_L9_r0_body.S772) 22252 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) bodyAcc752 PRE_first_tail_x4_L9_r0_body.bodyRunSeg195 bodyAcc753 bodyHalt753 PRE_first_tail_x4_L9_r0_body.bodyStepA196 bodyTop754 (fun _ hm => bodyO752 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr752).trans bodyInactive0) (bodyBr754.trans bodyBr752.symm) bodyCnt752 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA196 PRE_first_tail_x4_L9_r0_body.sizeArgsA196 PRE_first_tail_x4_L9_r0_body.sizeSymA196 PRE_first_tail_x4_L9_r0_body.sizeMlxA196 PRE_first_tail_x4_L9_r0_body.sizePayA196 PRE_first_tail_x4_L9_r0_body.sizeTaA196 PRE_first_tail_x4_L9_r0_body.sizeDecA196 PRE_first_tail_x4_L9_r0_body.sizePreA196 PRE_first_tail_x4_L9_r0_body.bodyPatchB196 (fun _ hm => bodyO754 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr754).trans bodyInactive0) (bodyBr755.trans bodyBr754.symm) bodyCnt754 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) bodyAcc755 PRE_first_tail_x4_L9_r0_body.bodyRunSeg196 bodyAcc759 bodyHalt759 PRE_first_tail_x4_L9_r0_body.bodyStepA197 bodyTop760 (fun _ hm => bodyO755 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr755).trans bodyInactive0) (bodyBr760.trans bodyBr755.symm) bodyCnt755 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA197 PRE_first_tail_x4_L9_r0_body.sizeArgsA197 PRE_first_tail_x4_L9_r0_body.sizeSymA197 PRE_first_tail_x4_L9_r0_body.sizeMlxA197 PRE_first_tail_x4_L9_r0_body.sizePayA197 PRE_first_tail_x4_L9_r0_body.sizeTaA197 PRE_first_tail_x4_L9_r0_body.sizeDecA197 PRE_first_tail_x4_L9_r0_body.sizePreA197 PRE_first_tail_x4_L9_r0_body.bodyPatchB197 (fun _ hm => bodyO760 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr760).trans bodyInactive0) (bodyBr761.trans bodyBr760.symm) bodyCnt760 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) bodyAcc761 PRE_first_tail_x4_L9_r0_body.bodyRunSeg197 bodyAcc762 bodyHalt762 PRE_first_tail_x4_L9_r0_body.bodyStepA198 bodyTop763 (fun _ hm => bodyO761 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr761).trans bodyInactive0) (bodyBr763.trans bodyBr761.symm) bodyCnt761 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA198 PRE_first_tail_x4_L9_r0_body.sizeArgsA198 PRE_first_tail_x4_L9_r0_body.sizeSymA198 PRE_first_tail_x4_L9_r0_body.sizeMlxA198 PRE_first_tail_x4_L9_r0_body.sizePayA198 PRE_first_tail_x4_L9_r0_body.sizeTaA198 PRE_first_tail_x4_L9_r0_body.sizeDecA198 PRE_first_tail_x4_L9_r0_body.sizePreA198 PRE_first_tail_x4_L9_r0_body.bodyPatchB198 (fun _ hm => bodyO763 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr763).trans bodyInactive0) (bodyBr764.trans bodyBr763.symm) bodyCnt763 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) bodyAcc764 PRE_first_tail_x4_L9_r0_body.bodyRunSeg198 bodyAcc765 bodyHalt765 PRE_first_tail_x4_L9_r0_body.bodyStepA199 bodyTop766 (fun _ hm => bodyO764 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr764).trans bodyInactive0) (bodyBr766.trans bodyBr764.symm) bodyCnt764 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA199 PRE_first_tail_x4_L9_r0_body.sizeArgsA199 PRE_first_tail_x4_L9_r0_body.sizeSymA199 PRE_first_tail_x4_L9_r0_body.sizeMlxA199 PRE_first_tail_x4_L9_r0_body.sizePayA199 PRE_first_tail_x4_L9_r0_body.sizeTaA199 PRE_first_tail_x4_L9_r0_body.sizeDecA199 PRE_first_tail_x4_L9_r0_body.sizePreA199 PRE_first_tail_x4_L9_r0_body.bodyPatchB199 (fun _ hm => bodyO766 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr766).trans bodyInactive0) (bodyBr767.trans bodyBr766.symm) bodyCnt766 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) bodyAcc767 PRE_first_tail_x4_L9_r0_body.bodyRunSeg199 bodyAcc768 bodyHalt768 PRE_first_tail_x4_L9_r0_body.bodyStepA200 bodyTop769 (fun _ hm => bodyO767 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr767).trans bodyInactive0) (bodyBr769.trans bodyBr767.symm) bodyCnt767 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA200 PRE_first_tail_x4_L9_r0_body.sizeArgsA200 PRE_first_tail_x4_L9_r0_body.sizeSymA200 PRE_first_tail_x4_L9_r0_body.sizeMlxA200 PRE_first_tail_x4_L9_r0_body.sizePayA200 PRE_first_tail_x4_L9_r0_body.sizeTaA200 PRE_first_tail_x4_L9_r0_body.sizeDecA200 PRE_first_tail_x4_L9_r0_body.sizePreA200 PRE_first_tail_x4_L9_r0_body.bodyPatchB200 (fun _ hm => bodyO769 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr769).trans bodyInactive0) (bodyBr770.trans bodyBr769.symm) bodyCnt769 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36788, 687, 0, 0⟩) bodyAcc770 PRE_first_tail_x4_L9_r0_body.bodyRunSeg200 bodyAcc771 bodyHalt771 PRE_first_tail_x4_L9_r0_body.bodyStepA201 bodyTop772 (fun _ hm => bodyO770 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr770).trans bodyInactive0) (bodyBr772.trans bodyBr770.symm) bodyCnt770 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift34 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S772.tab.length PRE_first_tail_x4_L9_r0_body.s772.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P34.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P34 15 PRE_first_tail_x4_L9_r0_body.kappa34 PRE_first_tail_x4_L9_r0_body.s774.ffi PRE_first_tail_x4_L9_r0_body.s773.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_34
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_34
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s774.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S772.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_34] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK34 PRE_first_tail_x4_L9_r0_body.cobjsK34
      PRE_first_tail_x4_L9_r0_body.citemsK34 PRE_first_tail_x4_L9_r0_body.cbd34 PRE_first_tail_x4_L9_r0_body.csst34
  exact PRE_first_tail_x4_L9_r0_body.cshift34 bodyNcl34 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_34] at this; exact this)


kernel_rfl bodyFramesEmpty34 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s773 a).isEmpty) = true
kernel_rfl bodyJsRoots34 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s772.next) PRE_first_tail_x4_L9_r0_body.s774.trace PRE_first_tail_x4_L9_r0_body.s774 = true
kernel_rfl bodyJsNative34 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s774.ffi) = true
kernel_rfl bodyLow34 : (PRE_first_tail_x4_L9_r0_body.cws34 ++ PRE_first_tail_x4_L9_r0_body.ws34).all (Nat.ble 9) = true
kernel_rfl bodyCntM34 : countersOkB PRE_first_tail_x4_L9_r0_body.s772 PRE_first_tail_x4_L9_r0_body.s773 = true
kernel_rfl bodyHi34 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s774.ffi).next setupP.E = true
kernel_rfl bodyNhi34 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s774.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge34 : bridgeOf PRE_first_tail_x4_L9_r0_body.s773.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s772.ffi
kernel_rfl bodyNN34 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s772.ffi).nnext PRE_first_tail_x4_L9_r0_body.P34.NL = true
kernel_rfl bodyXn34 : Nat.ble (⟨20325, 17431, 2760119, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s774.ffi).next = true
kernel_rfl bodyLo34 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s774.ffi).next = true
theorem bodyFacts34 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s772 PRE_first_tail_x4_L9_r0_body.s773 PRE_first_tail_x4_L9_r0_body.s774 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S772 PRE_first_tail_x4_L9_r0_body.S773 PRE_first_tail_x4_L9_r0_body.S774
    PRE_first_tail_x4_L9_r0_body.ws34 PRE_first_tail_x4_L9_r0_body.cws34 PRE_first_tail_x4_L9_r0_body.nr34 PRE_first_tail_x4_L9_r0_body.pl34 PRE_first_tail_x4_L9_r0_body.cl34 2761268 15 PRE_first_tail_x4_L9_r0_body.kd34 PRE_first_tail_x4_L9_r0_body.kappa34 PRE_first_tail_x4_L9_r0_body.P34
    ⟨20322, 17404, 2760113, 15⟩ ⟨20325, 17431, 2760119, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap34
  clean := bodyClean34
  cfix := PRE_first_tail_x4_L9_r0_body.cfix34
  zpl := PRE_first_tail_x4_L9_r0_body.zpl34
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd34
  zn1 := PRE_first_tail_x4_L9_r0_body.zn134
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst34
  zscn := PRE_first_tail_x4_L9_r0_body.zscn34
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn34
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow34
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab34
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh34
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd34
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi34
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt34
  zgP := PRE_first_tail_x4_L9_r0_body.zg34_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk34_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm34_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg34_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk34_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm34_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw34_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw34_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap34
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd34
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap34 PRE_first_tail_x4_L9_r0_body.stFoot34 PRE_first_tail_x4_L9_r0_body.iso34 PRE_first_tail_x4_L9_r0_body.zwr34
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP34
  csupp := PRE_first_tail_x4_L9_r0_body.csupp34
  cbound := PRE_first_tail_x4_L9_r0_body.cbound34
  zimg := PRE_first_tail_x4_L9_r0_body.zimg34
  zctl := PRE_first_tail_x4_L9_r0_body.zctl34
  zstack := PRE_first_tail_x4_L9_r0_body.zstack34
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs34
  zstores := PRE_first_tail_x4_L9_r0_body.zstores34
  zroots := PRE_first_tail_x4_L9_r0_body.zroots34
  znC := PRE_first_tail_x4_L9_r0_body.znC34
  ctab := PRE_first_tail_x4_L9_r0_body.ctab34
  zbin := PRE_first_tail_x4_L9_r0_body.zbin34
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge34
  sbridge := bodyBridge34
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj34
  cshiftR := fun h hNL => bodyCshift34 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN34
  raised := PRE_first_tail_x4_L9_r0_body.raised34
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs34
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl34
  xnLe := Nat.le_of_ble_eq_true bodyXn34
  loLe := Nat.le_of_ble_eq_true bodyLo34
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB34
  cntM := bodyCntM34
  hiLe := Nat.le_of_ble_eq_true bodyHi34
  nhiLe := Nat.le_of_ble_eq_true bodyNhi34
  jsHeap := bodyJs34
  jsRoots := bodyJsRoots34
  jsNative := bodyJsNative34
  framesEmpty := bodyFramesEmpty34
  trailOld := by decide
  lowVars := bodyLow34

def bodyQs34 : List (Option Q) := []
noncomputable def bodyEs34 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr34.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st34.S5.tab r
kernel_rfl bodyResChk34 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs34 bodyQs34) = true
kernel_rfl bodyLq34 : bodyQs34.length = PRE_first_tail_x4_L9_r0_body.cws34.length
kernel_rfl bodyNrLo34 : PRE_first_tail_x4_L9_r0_body.nr34.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S772.tab.length) = true
kernel_rfl bodySub34 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site34.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost34 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws34 PRE_first_tail_x4_L9_r0_body.cws34 bodyQs34 = true
kernel_rfl bodyDrop34 : Nat.ble (36788 + (PRE_first_tail_x4_L9_r0_body.s773.next - PRE_first_tail_x4_L9_r0_body.s774.next)) 37937 = true
kernel_rfl bodyDropH34 : Nat.ble (687 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s773.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s774.ffi).next)) 712 = true
kernel_rfl bodyDropN34 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s773.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s774.ffi).nnext)) 0 = true
kernel_rfl bodyDv34 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws34
kernel_rfl bodyDe34 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr34.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st34.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl34 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold34 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws34).isNone && !PRE_first_tail_x4_L9_r0_body.ws34.contains v) = true
kernel_rfl bodyDfree34 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws34 ++ PRE_first_tail_x4_L9_r0_body.ws34).all fun w => e.noVar w) = true

theorem bodyStep34 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨36788, 687, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s772 PRE_first_tail_x4_L9_r0_body.S772)
      (bodyCut NB T tk π i x0 bodyΘ ⟨37937, 712, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s774 PRE_first_tail_x4_L9_r0_body.S774) (11334 + 1) :=
  bodySite bodyFacts34.cfix bodyFacts34.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st34.S5.tab) (Es := bodyEs34) (qs := bodyQs34)
    (ok := PRE_first_tail_x4_L9_r0_body.st34.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site34 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts34
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site34 r hr) hi (MapOk.sub hm (sub_of_all bodySub34)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk34 r hr) hi hm ho hq)
    bodyLq34 rfl bodyNrLo34 (postSub_sound bodyPost34)
    (Nat.le_of_ble_eq_true bodyDrop34) (by decide) (Nat.le_of_ble_eq_true bodyDropH34) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN34) (by decide)
    bodyDv34 bodyDe34 bodyDl34 bodyDold34 bodyDfree34 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site35 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site35 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site35) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st35.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site35
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st35.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st35.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s793 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s794 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S793 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws35 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st35.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st35.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso35
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_35
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st35.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot35
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup35
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound35
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace35
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged35
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws35.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st35.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S793.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_35]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen35.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh35
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl35 : Conv.NClean (⟨20385, 17476, 2762616, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s793.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl35 (PRE_first_tail_x4_L9_r0_body.cncl34 bodyNcl34)

theorem bodyClean35 : Conv.JClean (⟨20385, 17476, 2762616, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s793 :=
  PRE_first_tail_x4_L9_r0_body.gjcl35 (PRE_first_tail_x4_L9_r0_body.cjcl34 bodyClean34)

kernel_rfl bodyJsLe35 : Nat.ble PRE_first_tail_x4_L9_r0_body.s772.next PRE_first_tail_x4_L9_r0_body.s793.next = true
kernel_rfl bodyJsList35 : (PRE_first_tail_x4_L9_r0_body.gjh35 ++ PRE_first_tail_x4_L9_r0_body.cl35).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s793.next) PRE_first_tail_x4_L9_r0_body.s795) = true
theorem bodyJs35 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s793.next PRE_first_tail_x4_L9_r0_body.s795 :=
  JsHeapAbove.glueSite bodyJs34 (Nat.le_of_ble_eq_true bodyJsLe35) PRE_first_tail_x4_L9_r0_body.gjk35 PRE_first_tail_x4_L9_r0_body.gjbd35 PRE_first_tail_x4_L9_r0_body.cheap35 PRE_first_tail_x4_L9_r0_body.zclbd35 bodyJsList35

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO774 : PRE_first_tail_x4_L9_r0_body.S774.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S774.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr774 : bridgeOf PRE_first_tail_x4_L9_r0_body.s774.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc774 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s774 PRE_first_tail_x4_L9_r0_body.S774) = fun _ _ => true
kernel_rfl bodyAcc775 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s775 PRE_first_tail_x4_L9_r0_body.S775) = fun _ _ => true
kernel_rfl bodyBr776 : bridgeOf PRE_first_tail_x4_L9_r0_body.s776.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt775 : isHalt PRE_first_tail_x4_L9_r0_body.s775.ctl = false
kernel_rfl bodyTop776 : noRetBlock PRE_first_tail_x4_L9_r0_body.s776 = true
kernel_rfl bodyCnt774 : countersOkB PRE_first_tail_x4_L9_r0_body.s774 PRE_first_tail_x4_L9_r0_body.s776 = true
kernel_rfl bodyO776 : PRE_first_tail_x4_L9_r0_body.S776.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S776.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr777 : bridgeOf PRE_first_tail_x4_L9_r0_body.s777.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt776 : countersOkB PRE_first_tail_x4_L9_r0_body.s776 PRE_first_tail_x4_L9_r0_body.s777 = true
kernel_rfl bodyO777 : PRE_first_tail_x4_L9_r0_body.S777.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S777.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc777 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s777 PRE_first_tail_x4_L9_r0_body.S777) = fun _ _ => true
kernel_rfl bodyAcc781 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s781 PRE_first_tail_x4_L9_r0_body.S781) = fun _ _ => true
kernel_rfl bodyBr782 : bridgeOf PRE_first_tail_x4_L9_r0_body.s782.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt781 : isHalt PRE_first_tail_x4_L9_r0_body.s781.ctl = false
kernel_rfl bodyTop782 : noRetBlock PRE_first_tail_x4_L9_r0_body.s782 = true
kernel_rfl bodyCnt777 : countersOkB PRE_first_tail_x4_L9_r0_body.s777 PRE_first_tail_x4_L9_r0_body.s782 = true
kernel_rfl bodyO782 : PRE_first_tail_x4_L9_r0_body.S782.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S782.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr783 : bridgeOf PRE_first_tail_x4_L9_r0_body.s783.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt782 : countersOkB PRE_first_tail_x4_L9_r0_body.s782 PRE_first_tail_x4_L9_r0_body.s783 = true
kernel_rfl bodyO783 : PRE_first_tail_x4_L9_r0_body.S783.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S783.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc783 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s783 PRE_first_tail_x4_L9_r0_body.S783) = fun _ _ => true
kernel_rfl bodyAcc785 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s785 PRE_first_tail_x4_L9_r0_body.S785) = fun _ _ => true
kernel_rfl bodyBr786 : bridgeOf PRE_first_tail_x4_L9_r0_body.s786.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt785 : isHalt PRE_first_tail_x4_L9_r0_body.s785.ctl = false
kernel_rfl bodyTop786 : noRetBlock PRE_first_tail_x4_L9_r0_body.s786 = true
kernel_rfl bodyCnt783 : countersOkB PRE_first_tail_x4_L9_r0_body.s783 PRE_first_tail_x4_L9_r0_body.s786 = true
kernel_rfl bodyO786 : PRE_first_tail_x4_L9_r0_body.S786.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S786.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr787 : bridgeOf PRE_first_tail_x4_L9_r0_body.s787.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt786 : countersOkB PRE_first_tail_x4_L9_r0_body.s786 PRE_first_tail_x4_L9_r0_body.s787 = true
kernel_rfl bodyO787 : PRE_first_tail_x4_L9_r0_body.S787.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S787.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc787 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s787 PRE_first_tail_x4_L9_r0_body.S787) = fun _ _ => true
kernel_rfl bodyAcc788 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s788 PRE_first_tail_x4_L9_r0_body.S788) = fun _ _ => true
kernel_rfl bodyBr789 : bridgeOf PRE_first_tail_x4_L9_r0_body.s789.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt788 : isHalt PRE_first_tail_x4_L9_r0_body.s788.ctl = false
kernel_rfl bodyTop789 : noRetBlock PRE_first_tail_x4_L9_r0_body.s789 = true
kernel_rfl bodyCnt787 : countersOkB PRE_first_tail_x4_L9_r0_body.s787 PRE_first_tail_x4_L9_r0_body.s789 = true
kernel_rfl bodyO789 : PRE_first_tail_x4_L9_r0_body.S789.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S789.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr790 : bridgeOf PRE_first_tail_x4_L9_r0_body.s790.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt789 : countersOkB PRE_first_tail_x4_L9_r0_body.s789 PRE_first_tail_x4_L9_r0_body.s790 = true
kernel_rfl bodyO790 : PRE_first_tail_x4_L9_r0_body.S790.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S790.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc790 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s790 PRE_first_tail_x4_L9_r0_body.S790) = fun _ _ => true
kernel_rfl bodyAcc792 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s792 PRE_first_tail_x4_L9_r0_body.S792) = fun _ _ => true
kernel_rfl bodyBr793 : bridgeOf PRE_first_tail_x4_L9_r0_body.s793.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt792 : isHalt PRE_first_tail_x4_L9_r0_body.s792.ctl = false
kernel_rfl bodyTop793 : noRetBlock PRE_first_tail_x4_L9_r0_body.s793 = true
kernel_rfl bodyCnt790 : countersOkB PRE_first_tail_x4_L9_r0_body.s790 PRE_first_tail_x4_L9_r0_body.s793 = true

theorem bodyGlue35 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨37937, 712, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s774 PRE_first_tail_x4_L9_r0_body.S774)
      (bodyCut NB T tk π i x0 bodyΘ ⟨37937, 712, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s793 PRE_first_tail_x4_L9_r0_body.S793) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) bodyAcc774 PRE_first_tail_x4_L9_r0_body.bodyRunSeg201 bodyAcc775 bodyHalt775 PRE_first_tail_x4_L9_r0_body.bodyStepA202 bodyTop776 (fun _ hm => bodyO774 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr774).trans bodyInactive0) (bodyBr776.trans bodyBr774.symm) bodyCnt774 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA202 PRE_first_tail_x4_L9_r0_body.sizeArgsA202 PRE_first_tail_x4_L9_r0_body.sizeSymA202 PRE_first_tail_x4_L9_r0_body.sizeMlxA202 PRE_first_tail_x4_L9_r0_body.sizePayA202 PRE_first_tail_x4_L9_r0_body.sizeTaA202 PRE_first_tail_x4_L9_r0_body.sizeDecA202 PRE_first_tail_x4_L9_r0_body.sizePreA202 PRE_first_tail_x4_L9_r0_body.bodyPatchB202 (fun _ hm => bodyO776 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr776).trans bodyInactive0) (bodyBr777.trans bodyBr776.symm) bodyCnt776 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) bodyAcc777 PRE_first_tail_x4_L9_r0_body.bodyRunSeg202 bodyAcc781 bodyHalt781 PRE_first_tail_x4_L9_r0_body.bodyStepA203 bodyTop782 (fun _ hm => bodyO777 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr777).trans bodyInactive0) (bodyBr782.trans bodyBr777.symm) bodyCnt777 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA203 PRE_first_tail_x4_L9_r0_body.sizeArgsA203 PRE_first_tail_x4_L9_r0_body.sizeSymA203 PRE_first_tail_x4_L9_r0_body.sizeMlxA203 PRE_first_tail_x4_L9_r0_body.sizePayA203 PRE_first_tail_x4_L9_r0_body.sizeTaA203 PRE_first_tail_x4_L9_r0_body.sizeDecA203 PRE_first_tail_x4_L9_r0_body.sizePreA203 PRE_first_tail_x4_L9_r0_body.bodyPatchB203 (fun _ hm => bodyO782 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr782).trans bodyInactive0) (bodyBr783.trans bodyBr782.symm) bodyCnt782 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) bodyAcc783 PRE_first_tail_x4_L9_r0_body.bodyRunSeg203 bodyAcc785 bodyHalt785 PRE_first_tail_x4_L9_r0_body.bodyStepA204 bodyTop786 (fun _ hm => bodyO783 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr783).trans bodyInactive0) (bodyBr786.trans bodyBr783.symm) bodyCnt783 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA204 PRE_first_tail_x4_L9_r0_body.sizeArgsA204 PRE_first_tail_x4_L9_r0_body.sizeSymA204 PRE_first_tail_x4_L9_r0_body.sizeMlxA204 PRE_first_tail_x4_L9_r0_body.sizePayA204 PRE_first_tail_x4_L9_r0_body.sizeTaA204 PRE_first_tail_x4_L9_r0_body.sizeDecA204 PRE_first_tail_x4_L9_r0_body.sizePreA204 PRE_first_tail_x4_L9_r0_body.bodyPatchB204 (fun _ hm => bodyO786 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr786).trans bodyInactive0) (bodyBr787.trans bodyBr786.symm) bodyCnt786 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) bodyAcc787 PRE_first_tail_x4_L9_r0_body.bodyRunSeg204 bodyAcc788 bodyHalt788 PRE_first_tail_x4_L9_r0_body.bodyStepA205 bodyTop789 (fun _ hm => bodyO787 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr787).trans bodyInactive0) (bodyBr789.trans bodyBr787.symm) bodyCnt787 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA205 PRE_first_tail_x4_L9_r0_body.sizeArgsA205 PRE_first_tail_x4_L9_r0_body.sizeSymA205 PRE_first_tail_x4_L9_r0_body.sizeMlxA205 PRE_first_tail_x4_L9_r0_body.sizePayA205 PRE_first_tail_x4_L9_r0_body.sizeTaA205 PRE_first_tail_x4_L9_r0_body.sizeDecA205 PRE_first_tail_x4_L9_r0_body.sizePreA205 PRE_first_tail_x4_L9_r0_body.bodyPatchB205 (fun _ hm => bodyO789 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr789).trans bodyInactive0) (bodyBr790.trans bodyBr789.symm) bodyCnt789 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37937, 712, 0, 0⟩) bodyAcc790 PRE_first_tail_x4_L9_r0_body.bodyRunSeg205 bodyAcc792 bodyHalt792 PRE_first_tail_x4_L9_r0_body.bodyStepA206 bodyTop793 (fun _ hm => bodyO790 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr790).trans bodyInactive0) (bodyBr793.trans bodyBr790.symm) bodyCnt790 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift35 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S793.tab.length PRE_first_tail_x4_L9_r0_body.s793.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P35.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P35 15 PRE_first_tail_x4_L9_r0_body.kappa35 PRE_first_tail_x4_L9_r0_body.s795.ffi PRE_first_tail_x4_L9_r0_body.s794.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_35
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_35
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s795.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S793.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_35] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK35 PRE_first_tail_x4_L9_r0_body.cobjsK35
      PRE_first_tail_x4_L9_r0_body.citemsK35 PRE_first_tail_x4_L9_r0_body.cbd35 PRE_first_tail_x4_L9_r0_body.csst35
  exact PRE_first_tail_x4_L9_r0_body.cshift35 bodyNcl35 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_35] at this; exact this)


kernel_rfl bodyFramesEmpty35 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s794 a).isEmpty) = true
kernel_rfl bodyJsRoots35 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s793.next) PRE_first_tail_x4_L9_r0_body.s795.trace PRE_first_tail_x4_L9_r0_body.s795 = true
kernel_rfl bodyJsNative35 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s795.ffi) = true
kernel_rfl bodyLow35 : (PRE_first_tail_x4_L9_r0_body.cws35 ++ PRE_first_tail_x4_L9_r0_body.ws35).all (Nat.ble 9) = true
kernel_rfl bodyCntM35 : countersOkB PRE_first_tail_x4_L9_r0_body.s793 PRE_first_tail_x4_L9_r0_body.s794 = true
kernel_rfl bodyHi35 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s795.ffi).next setupP.E = true
kernel_rfl bodyNhi35 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s795.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge35 : bridgeOf PRE_first_tail_x4_L9_r0_body.s794.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s793.ffi
kernel_rfl bodyNN35 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s793.ffi).nnext PRE_first_tail_x4_L9_r0_body.P35.NL = true
kernel_rfl bodyXn35 : Nat.ble (⟨20389, 17482, 2762631, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s795.ffi).next = true
kernel_rfl bodyLo35 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s795.ffi).next = true
theorem bodyFacts35 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s793 PRE_first_tail_x4_L9_r0_body.s794 PRE_first_tail_x4_L9_r0_body.s795 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S793 PRE_first_tail_x4_L9_r0_body.S794 PRE_first_tail_x4_L9_r0_body.S795
    PRE_first_tail_x4_L9_r0_body.ws35 PRE_first_tail_x4_L9_r0_body.cws35 PRE_first_tail_x4_L9_r0_body.nr35 PRE_first_tail_x4_L9_r0_body.pl35 PRE_first_tail_x4_L9_r0_body.cl35 2762981 15 PRE_first_tail_x4_L9_r0_body.kd35 PRE_first_tail_x4_L9_r0_body.kappa35 PRE_first_tail_x4_L9_r0_body.P35
    ⟨20385, 17476, 2762616, 15⟩ ⟨20389, 17482, 2762631, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap35
  clean := bodyClean35
  cfix := PRE_first_tail_x4_L9_r0_body.cfix35
  zpl := PRE_first_tail_x4_L9_r0_body.zpl35
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd35
  zn1 := PRE_first_tail_x4_L9_r0_body.zn135
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst35
  zscn := PRE_first_tail_x4_L9_r0_body.zscn35
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn35
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow35
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab35
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh35
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd35
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi35
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt35
  zgP := PRE_first_tail_x4_L9_r0_body.zg35_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk35_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm35_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg35_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk35_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm35_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw35_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw35_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap35
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd35
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap35 PRE_first_tail_x4_L9_r0_body.stFoot35 PRE_first_tail_x4_L9_r0_body.iso35 PRE_first_tail_x4_L9_r0_body.zwr35
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP35
  csupp := PRE_first_tail_x4_L9_r0_body.csupp35
  cbound := PRE_first_tail_x4_L9_r0_body.cbound35
  zimg := PRE_first_tail_x4_L9_r0_body.zimg35
  zctl := PRE_first_tail_x4_L9_r0_body.zctl35
  zstack := PRE_first_tail_x4_L9_r0_body.zstack35
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs35
  zstores := PRE_first_tail_x4_L9_r0_body.zstores35
  zroots := PRE_first_tail_x4_L9_r0_body.zroots35
  znC := PRE_first_tail_x4_L9_r0_body.znC35
  ctab := PRE_first_tail_x4_L9_r0_body.ctab35
  zbin := PRE_first_tail_x4_L9_r0_body.zbin35
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge35
  sbridge := bodyBridge35
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj35
  cshiftR := fun h hNL => bodyCshift35 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN35
  raised := PRE_first_tail_x4_L9_r0_body.raised35
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs35
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl35
  xnLe := Nat.le_of_ble_eq_true bodyXn35
  loLe := Nat.le_of_ble_eq_true bodyLo35
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB35
  cntM := bodyCntM35
  hiLe := Nat.le_of_ble_eq_true bodyHi35
  nhiLe := Nat.le_of_ble_eq_true bodyNhi35
  jsHeap := bodyJs35
  jsRoots := bodyJsRoots35
  jsNative := bodyJsNative35
  framesEmpty := bodyFramesEmpty35
  trailOld := by decide
  lowVars := bodyLow35

def bodyQs35 : List (Option Q) := []
noncomputable def bodyEs35 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr35.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st35.S3.tab r
kernel_rfl bodyResChk35 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs35 bodyQs35) = true
kernel_rfl bodyLq35 : bodyQs35.length = PRE_first_tail_x4_L9_r0_body.cws35.length
kernel_rfl bodyNrLo35 : PRE_first_tail_x4_L9_r0_body.nr35.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S793.tab.length) = true
kernel_rfl bodySub35 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site35.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost35 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws35 PRE_first_tail_x4_L9_r0_body.cws35 bodyQs35 = true
kernel_rfl bodyDrop35 : Nat.ble (37937 + (PRE_first_tail_x4_L9_r0_body.s794.next - PRE_first_tail_x4_L9_r0_body.s795.next)) 38287 = true
kernel_rfl bodyDropH35 : Nat.ble (712 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s794.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s795.ffi).next)) 714 = true
kernel_rfl bodyDropN35 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s794.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s795.ffi).nnext)) 0 = true
kernel_rfl bodyDv35 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws35
kernel_rfl bodyDe35 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr35.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st35.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl35 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold35 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws35).isNone && !PRE_first_tail_x4_L9_r0_body.ws35.contains v) = true
kernel_rfl bodyDfree35 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws35 ++ PRE_first_tail_x4_L9_r0_body.ws35).all fun w => e.noVar w) = true

theorem bodyStep35 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨37937, 712, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s793 PRE_first_tail_x4_L9_r0_body.S793)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38287, 714, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s795 PRE_first_tail_x4_L9_r0_body.S795) (3452 + 1) :=
  bodySite bodyFacts35.cfix bodyFacts35.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L9_r0_body.st35.S3.tab) (Es := bodyEs35) (qs := bodyQs35)
    (ok := PRE_first_tail_x4_L9_r0_body.st35.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site35 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts35
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site35 r hr) hi (MapOk.sub hm (sub_of_all bodySub35)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk35 r hr) hi hm ho hq)
    bodyLq35 rfl bodyNrLo35 (postSub_sound bodyPost35)
    (Nat.le_of_ble_eq_true bodyDrop35) (by decide) (Nat.le_of_ble_eq_true bodyDropH35) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN35) (by decide)
    bodyDv35 bodyDe35 bodyDl35 bodyDold35 bodyDfree35 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyOracles_9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_g36 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g36 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g36) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site36 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site36 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site36) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st36.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g37 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g37 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g37) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site37 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site37 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site37) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st37.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g38 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g38 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g38) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site38 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site38 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site38) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st38.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_body.map_g39 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g39 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g39) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true

def PRE_first_tail_x4_L9_r0_body.map_site39 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site39 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site39) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st39.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site36 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site36 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site36) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st36.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site36
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st36.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st36.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s817 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s818 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S817 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws36 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st36.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st36.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso36
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_36
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st36.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot36
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup36
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound36
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace36
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged36
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws36.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st36.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S817.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_36]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen36.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh36
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl36 : Conv.NClean (⟨20457, 17528, 2765654, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s817.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl36 (PRE_first_tail_x4_L9_r0_body.cncl35 bodyNcl35)

theorem bodyClean36 : Conv.JClean (⟨20457, 17528, 2765654, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s817 :=
  PRE_first_tail_x4_L9_r0_body.gjcl36 (PRE_first_tail_x4_L9_r0_body.cjcl35 bodyClean35)

kernel_rfl bodyJsLe36 : Nat.ble PRE_first_tail_x4_L9_r0_body.s793.next PRE_first_tail_x4_L9_r0_body.s817.next = true
kernel_rfl bodyJsList36 : (PRE_first_tail_x4_L9_r0_body.gjh36 ++ PRE_first_tail_x4_L9_r0_body.cl36).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s817.next) PRE_first_tail_x4_L9_r0_body.s819) = true
theorem bodyJs36 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s817.next PRE_first_tail_x4_L9_r0_body.s819 :=
  JsHeapAbove.glueSite bodyJs35 (Nat.le_of_ble_eq_true bodyJsLe36) PRE_first_tail_x4_L9_r0_body.gjk36 PRE_first_tail_x4_L9_r0_body.gjbd36 PRE_first_tail_x4_L9_r0_body.cheap36 PRE_first_tail_x4_L9_r0_body.zclbd36 bodyJsList36

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO795 : PRE_first_tail_x4_L9_r0_body.S795.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S795.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr795 : bridgeOf PRE_first_tail_x4_L9_r0_body.s795.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc795 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s795 PRE_first_tail_x4_L9_r0_body.S795) = fun _ _ => true
kernel_rfl bodyAcc798 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s798 PRE_first_tail_x4_L9_r0_body.S798) = fun _ _ => true
kernel_rfl bodyBr799 : bridgeOf PRE_first_tail_x4_L9_r0_body.s799.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt798 : isHalt PRE_first_tail_x4_L9_r0_body.s798.ctl = false
kernel_rfl bodyTop799 : noRetBlock PRE_first_tail_x4_L9_r0_body.s799 = true
kernel_rfl bodyCnt795 : countersOkB PRE_first_tail_x4_L9_r0_body.s795 PRE_first_tail_x4_L9_r0_body.s799 = true
kernel_rfl bodyO799 : PRE_first_tail_x4_L9_r0_body.S799.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S799.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr800 : bridgeOf PRE_first_tail_x4_L9_r0_body.s800.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt799 : countersOkB PRE_first_tail_x4_L9_r0_body.s799 PRE_first_tail_x4_L9_r0_body.s800 = true
kernel_rfl bodyO800 : PRE_first_tail_x4_L9_r0_body.S800.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S800.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc800 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s800 PRE_first_tail_x4_L9_r0_body.S800) = fun _ _ => true
kernel_rfl bodyAcc804 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s804 PRE_first_tail_x4_L9_r0_body.S804) = fun _ _ => true
kernel_rfl bodyBr805 : bridgeOf PRE_first_tail_x4_L9_r0_body.s805.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt804 : isHalt PRE_first_tail_x4_L9_r0_body.s804.ctl = false
kernel_rfl bodyTop805 : noRetBlock PRE_first_tail_x4_L9_r0_body.s805 = true
kernel_rfl bodyCnt800 : countersOkB PRE_first_tail_x4_L9_r0_body.s800 PRE_first_tail_x4_L9_r0_body.s805 = true
kernel_rfl bodyO805 : PRE_first_tail_x4_L9_r0_body.S805.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S805.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr806 : bridgeOf PRE_first_tail_x4_L9_r0_body.s806.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt805 : countersOkB PRE_first_tail_x4_L9_r0_body.s805 PRE_first_tail_x4_L9_r0_body.s806 = true
kernel_rfl bodyO806 : PRE_first_tail_x4_L9_r0_body.S806.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S806.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc806 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s806 PRE_first_tail_x4_L9_r0_body.S806) = fun _ _ => true
kernel_rfl bodyAcc807 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s807 PRE_first_tail_x4_L9_r0_body.S807) = fun _ _ => true
kernel_rfl bodyBr808 : bridgeOf PRE_first_tail_x4_L9_r0_body.s808.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt807 : isHalt PRE_first_tail_x4_L9_r0_body.s807.ctl = false
kernel_rfl bodyTop808 : noRetBlock PRE_first_tail_x4_L9_r0_body.s808 = true
kernel_rfl bodyCnt806 : countersOkB PRE_first_tail_x4_L9_r0_body.s806 PRE_first_tail_x4_L9_r0_body.s808 = true
kernel_rfl bodyO808 : PRE_first_tail_x4_L9_r0_body.S808.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S808.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr809 : bridgeOf PRE_first_tail_x4_L9_r0_body.s809.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt808 : countersOkB PRE_first_tail_x4_L9_r0_body.s808 PRE_first_tail_x4_L9_r0_body.s809 = true
kernel_rfl bodyO809 : PRE_first_tail_x4_L9_r0_body.S809.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S809.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc809 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s809 PRE_first_tail_x4_L9_r0_body.S809) = fun _ _ => true
kernel_rfl bodyAcc810 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s810 PRE_first_tail_x4_L9_r0_body.S810) = fun _ _ => true
kernel_rfl bodyBr811 : bridgeOf PRE_first_tail_x4_L9_r0_body.s811.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt810 : isHalt PRE_first_tail_x4_L9_r0_body.s810.ctl = false
kernel_rfl bodyTop811 : noRetBlock PRE_first_tail_x4_L9_r0_body.s811 = true
kernel_rfl bodyCnt809 : countersOkB PRE_first_tail_x4_L9_r0_body.s809 PRE_first_tail_x4_L9_r0_body.s811 = true
kernel_rfl bodyO811 : PRE_first_tail_x4_L9_r0_body.S811.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S811.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr812 : bridgeOf PRE_first_tail_x4_L9_r0_body.s812.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt811 : countersOkB PRE_first_tail_x4_L9_r0_body.s811 PRE_first_tail_x4_L9_r0_body.s812 = true
kernel_rfl bodyO812 : PRE_first_tail_x4_L9_r0_body.S812.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S812.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc812 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s812 PRE_first_tail_x4_L9_r0_body.S812) = fun _ _ => true
kernel_rfl bodyAcc813 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s813 PRE_first_tail_x4_L9_r0_body.S813) = fun _ _ => true
kernel_rfl bodyBr814 : bridgeOf PRE_first_tail_x4_L9_r0_body.s814.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt813 : isHalt PRE_first_tail_x4_L9_r0_body.s813.ctl = false
kernel_rfl bodyTop814 : noRetBlock PRE_first_tail_x4_L9_r0_body.s814 = true
kernel_rfl bodyCnt812 : countersOkB PRE_first_tail_x4_L9_r0_body.s812 PRE_first_tail_x4_L9_r0_body.s814 = true
kernel_rfl bodyO814 : PRE_first_tail_x4_L9_r0_body.S814.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S814.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr815 : bridgeOf PRE_first_tail_x4_L9_r0_body.s815.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt814 : countersOkB PRE_first_tail_x4_L9_r0_body.s814 PRE_first_tail_x4_L9_r0_body.s815 = true
kernel_rfl bodyO815 : PRE_first_tail_x4_L9_r0_body.S815.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S815.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc815 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s815 PRE_first_tail_x4_L9_r0_body.S815) = fun _ _ => true
kernel_rfl bodyAcc816 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s816 PRE_first_tail_x4_L9_r0_body.S816) = fun _ _ => true
kernel_rfl bodyBr817 : bridgeOf PRE_first_tail_x4_L9_r0_body.s817.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt816 : isHalt PRE_first_tail_x4_L9_r0_body.s816.ctl = false
kernel_rfl bodyTop817 : noRetBlock PRE_first_tail_x4_L9_r0_body.s817 = true
kernel_rfl bodyCnt815 : countersOkB PRE_first_tail_x4_L9_r0_body.s815 PRE_first_tail_x4_L9_r0_body.s817 = true

theorem bodyGlue36 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38287, 714, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s795 PRE_first_tail_x4_L9_r0_body.S795)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38287, 714, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s817 PRE_first_tail_x4_L9_r0_body.S817) 30907 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) bodyAcc795 PRE_first_tail_x4_L9_r0_body.bodyRunSeg206 bodyAcc798 bodyHalt798 PRE_first_tail_x4_L9_r0_body.bodyStepA207 bodyTop799 (fun _ hm => bodyO795 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr795).trans bodyInactive0) (bodyBr799.trans bodyBr795.symm) bodyCnt795 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA207 PRE_first_tail_x4_L9_r0_body.sizeArgsA207 PRE_first_tail_x4_L9_r0_body.sizeSymA207 PRE_first_tail_x4_L9_r0_body.sizeMlxA207 PRE_first_tail_x4_L9_r0_body.sizePayA207 PRE_first_tail_x4_L9_r0_body.sizeTaA207 PRE_first_tail_x4_L9_r0_body.sizeDecA207 PRE_first_tail_x4_L9_r0_body.sizePreA207 PRE_first_tail_x4_L9_r0_body.bodyPatchB207 (fun _ hm => bodyO799 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr799).trans bodyInactive0) (bodyBr800.trans bodyBr799.symm) bodyCnt799 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) bodyAcc800 PRE_first_tail_x4_L9_r0_body.bodyRunSeg207 bodyAcc804 bodyHalt804 PRE_first_tail_x4_L9_r0_body.bodyStepA208 bodyTop805 (fun _ hm => bodyO800 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr800).trans bodyInactive0) (bodyBr805.trans bodyBr800.symm) bodyCnt800 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA208 PRE_first_tail_x4_L9_r0_body.sizeArgsA208 PRE_first_tail_x4_L9_r0_body.sizeSymA208 PRE_first_tail_x4_L9_r0_body.sizeMlxA208 PRE_first_tail_x4_L9_r0_body.sizePayA208 PRE_first_tail_x4_L9_r0_body.sizeTaA208 PRE_first_tail_x4_L9_r0_body.sizeDecA208 PRE_first_tail_x4_L9_r0_body.sizePreA208 PRE_first_tail_x4_L9_r0_body.bodyPatchB208 (fun _ hm => bodyO805 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr805).trans bodyInactive0) (bodyBr806.trans bodyBr805.symm) bodyCnt805 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) bodyAcc806 PRE_first_tail_x4_L9_r0_body.bodyRunSeg208 bodyAcc807 bodyHalt807 PRE_first_tail_x4_L9_r0_body.bodyStepA209 bodyTop808 (fun _ hm => bodyO806 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr806).trans bodyInactive0) (bodyBr808.trans bodyBr806.symm) bodyCnt806 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA209 PRE_first_tail_x4_L9_r0_body.sizeArgsA209 PRE_first_tail_x4_L9_r0_body.sizeSymA209 PRE_first_tail_x4_L9_r0_body.sizeMlxA209 PRE_first_tail_x4_L9_r0_body.sizePayA209 PRE_first_tail_x4_L9_r0_body.sizeTaA209 PRE_first_tail_x4_L9_r0_body.sizeDecA209 PRE_first_tail_x4_L9_r0_body.sizePreA209 PRE_first_tail_x4_L9_r0_body.bodyPatchB209 (fun _ hm => bodyO808 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr808).trans bodyInactive0) (bodyBr809.trans bodyBr808.symm) bodyCnt808 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) bodyAcc809 PRE_first_tail_x4_L9_r0_body.bodyRunSeg209 bodyAcc810 bodyHalt810 PRE_first_tail_x4_L9_r0_body.bodyStepA210 bodyTop811 (fun _ hm => bodyO809 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr809).trans bodyInactive0) (bodyBr811.trans bodyBr809.symm) bodyCnt809 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA210 PRE_first_tail_x4_L9_r0_body.sizeArgsA210 PRE_first_tail_x4_L9_r0_body.sizeSymA210 PRE_first_tail_x4_L9_r0_body.sizeMlxA210 PRE_first_tail_x4_L9_r0_body.sizePayA210 PRE_first_tail_x4_L9_r0_body.sizeTaA210 PRE_first_tail_x4_L9_r0_body.sizeDecA210 PRE_first_tail_x4_L9_r0_body.sizePreA210 PRE_first_tail_x4_L9_r0_body.bodyPatchB210 (fun _ hm => bodyO811 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr811).trans bodyInactive0) (bodyBr812.trans bodyBr811.symm) bodyCnt811 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) bodyAcc812 PRE_first_tail_x4_L9_r0_body.bodyRunSeg210 bodyAcc813 bodyHalt813 PRE_first_tail_x4_L9_r0_body.bodyStepA211 bodyTop814 (fun _ hm => bodyO812 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr812).trans bodyInactive0) (bodyBr814.trans bodyBr812.symm) bodyCnt812 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA211 PRE_first_tail_x4_L9_r0_body.sizeArgsA211 PRE_first_tail_x4_L9_r0_body.sizeSymA211 PRE_first_tail_x4_L9_r0_body.sizeMlxA211 PRE_first_tail_x4_L9_r0_body.sizePayA211 PRE_first_tail_x4_L9_r0_body.sizeTaA211 PRE_first_tail_x4_L9_r0_body.sizeDecA211 PRE_first_tail_x4_L9_r0_body.sizePreA211 PRE_first_tail_x4_L9_r0_body.bodyPatchB211 (fun _ hm => bodyO814 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr814).trans bodyInactive0) (bodyBr815.trans bodyBr814.symm) bodyCnt814 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38287, 714, 0, 0⟩) bodyAcc815 PRE_first_tail_x4_L9_r0_body.bodyRunSeg211 bodyAcc816 bodyHalt816 PRE_first_tail_x4_L9_r0_body.bodyStepA212 bodyTop817 (fun _ hm => bodyO815 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr815).trans bodyInactive0) (bodyBr817.trans bodyBr815.symm) bodyCnt815 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift36 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S817.tab.length PRE_first_tail_x4_L9_r0_body.s817.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P36.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P36 15 PRE_first_tail_x4_L9_r0_body.kappa36 PRE_first_tail_x4_L9_r0_body.s819.ffi PRE_first_tail_x4_L9_r0_body.s818.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_36
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_36
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s819.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S817.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_36] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK36 PRE_first_tail_x4_L9_r0_body.cobjsK36
      PRE_first_tail_x4_L9_r0_body.citemsK36 PRE_first_tail_x4_L9_r0_body.cbd36 PRE_first_tail_x4_L9_r0_body.csst36
  exact PRE_first_tail_x4_L9_r0_body.cshift36 bodyNcl36 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_36] at this; exact this)


kernel_rfl bodyFramesEmpty36 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s818 a).isEmpty) = true
kernel_rfl bodyJsRoots36 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s817.next) PRE_first_tail_x4_L9_r0_body.s819.trace PRE_first_tail_x4_L9_r0_body.s819 = true
kernel_rfl bodyJsNative36 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s819.ffi) = true
kernel_rfl bodyLow36 : (PRE_first_tail_x4_L9_r0_body.cws36 ++ PRE_first_tail_x4_L9_r0_body.ws36).all (Nat.ble 9) = true
kernel_rfl bodyCntM36 : countersOkB PRE_first_tail_x4_L9_r0_body.s817 PRE_first_tail_x4_L9_r0_body.s818 = true
kernel_rfl bodyHi36 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s819.ffi).next setupP.E = true
kernel_rfl bodyNhi36 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s819.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge36 : bridgeOf PRE_first_tail_x4_L9_r0_body.s818.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s817.ffi
kernel_rfl bodyNN36 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s817.ffi).nnext PRE_first_tail_x4_L9_r0_body.P36.NL = true
kernel_rfl bodyXn36 : Nat.ble (⟨20460, 17555, 2765660, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s819.ffi).next = true
kernel_rfl bodyLo36 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s819.ffi).next = true
theorem bodyFacts36 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s817 PRE_first_tail_x4_L9_r0_body.s818 PRE_first_tail_x4_L9_r0_body.s819 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S817 PRE_first_tail_x4_L9_r0_body.S818 PRE_first_tail_x4_L9_r0_body.S819
    PRE_first_tail_x4_L9_r0_body.ws36 PRE_first_tail_x4_L9_r0_body.cws36 PRE_first_tail_x4_L9_r0_body.nr36 PRE_first_tail_x4_L9_r0_body.pl36 PRE_first_tail_x4_L9_r0_body.cl36 2766809 15 PRE_first_tail_x4_L9_r0_body.kd36 PRE_first_tail_x4_L9_r0_body.kappa36 PRE_first_tail_x4_L9_r0_body.P36
    ⟨20457, 17528, 2765654, 15⟩ ⟨20460, 17555, 2765660, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap36
  clean := bodyClean36
  cfix := PRE_first_tail_x4_L9_r0_body.cfix36
  zpl := PRE_first_tail_x4_L9_r0_body.zpl36
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd36
  zn1 := PRE_first_tail_x4_L9_r0_body.zn136
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst36
  zscn := PRE_first_tail_x4_L9_r0_body.zscn36
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn36
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow36
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab36
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh36
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd36
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi36
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt36
  zgP := PRE_first_tail_x4_L9_r0_body.zg36_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk36_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm36_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg36_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk36_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm36_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw36_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw36_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap36
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd36
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap36 PRE_first_tail_x4_L9_r0_body.stFoot36 PRE_first_tail_x4_L9_r0_body.iso36 PRE_first_tail_x4_L9_r0_body.zwr36
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP36
  csupp := PRE_first_tail_x4_L9_r0_body.csupp36
  cbound := PRE_first_tail_x4_L9_r0_body.cbound36
  zimg := PRE_first_tail_x4_L9_r0_body.zimg36
  zctl := PRE_first_tail_x4_L9_r0_body.zctl36
  zstack := PRE_first_tail_x4_L9_r0_body.zstack36
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs36
  zstores := PRE_first_tail_x4_L9_r0_body.zstores36
  zroots := PRE_first_tail_x4_L9_r0_body.zroots36
  znC := PRE_first_tail_x4_L9_r0_body.znC36
  ctab := PRE_first_tail_x4_L9_r0_body.ctab36
  zbin := PRE_first_tail_x4_L9_r0_body.zbin36
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge36
  sbridge := bodyBridge36
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj36
  cshiftR := fun h hNL => bodyCshift36 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN36
  raised := PRE_first_tail_x4_L9_r0_body.raised36
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs36
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl36
  xnLe := Nat.le_of_ble_eq_true bodyXn36
  loLe := Nat.le_of_ble_eq_true bodyLo36
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB36
  cntM := bodyCntM36
  hiLe := Nat.le_of_ble_eq_true bodyHi36
  nhiLe := Nat.le_of_ble_eq_true bodyNhi36
  jsHeap := bodyJs36
  jsRoots := bodyJsRoots36
  jsNative := bodyJsNative36
  framesEmpty := bodyFramesEmpty36
  trailOld := by decide
  lowVars := bodyLow36

def bodyQs36 : List (Option Q) := []
noncomputable def bodyEs36 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr36.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st36.S5.tab r
kernel_rfl bodyResChk36 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs36 bodyQs36) = true
kernel_rfl bodyLq36 : bodyQs36.length = PRE_first_tail_x4_L9_r0_body.cws36.length
kernel_rfl bodyNrLo36 : PRE_first_tail_x4_L9_r0_body.nr36.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S817.tab.length) = true
kernel_rfl bodySub36 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site36.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost36 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws36 PRE_first_tail_x4_L9_r0_body.cws36 bodyQs36 = true
kernel_rfl bodyDrop36 : Nat.ble (38287 + (PRE_first_tail_x4_L9_r0_body.s818.next - PRE_first_tail_x4_L9_r0_body.s819.next)) 39436 = true
kernel_rfl bodyDropH36 : Nat.ble (714 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s818.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s819.ffi).next)) 739 = true
kernel_rfl bodyDropN36 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s818.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s819.ffi).nnext)) 0 = true
kernel_rfl bodyDv36 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws36
kernel_rfl bodyDe36 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr36.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st36.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl36 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold36 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws36).isNone && !PRE_first_tail_x4_L9_r0_body.ws36.contains v) = true
kernel_rfl bodyDfree36 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws36 ++ PRE_first_tail_x4_L9_r0_body.ws36).all fun w => e.noVar w) = true

theorem bodyStep36 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38287, 714, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s817 PRE_first_tail_x4_L9_r0_body.S817)
      (bodyCut NB T tk π i x0 bodyΘ ⟨39436, 739, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s819 PRE_first_tail_x4_L9_r0_body.S819) (11334 + 1) :=
  bodySite bodyFacts36.cfix bodyFacts36.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st36.S5.tab) (Es := bodyEs36) (qs := bodyQs36)
    (ok := PRE_first_tail_x4_L9_r0_body.st36.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site36 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts36
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site36 r hr) hi (MapOk.sub hm (sub_of_all bodySub36)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk36 r hr) hi hm ho hq)
    bodyLq36 rfl bodyNrLo36 (postSub_sound bodyPost36)
    (Nat.le_of_ble_eq_true bodyDrop36) (by decide) (Nat.le_of_ble_eq_true bodyDropH36) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN36) (by decide)
    bodyDv36 bodyDe36 bodyDl36 bodyDold36 bodyDfree36 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site37 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site37 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site37) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st37.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site37
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st37.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st37.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s839 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s840 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S839 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws37 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st37.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st37.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso37
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_37
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st37.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot37
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup37
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound37
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace37
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged37
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws37.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st37.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S839.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_37]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen37.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh37
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl37 : Conv.NClean (⟨20514, 17591, 2767892, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s839.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl37 (PRE_first_tail_x4_L9_r0_body.cncl36 bodyNcl36)

theorem bodyClean37 : Conv.JClean (⟨20514, 17591, 2767892, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s839 :=
  PRE_first_tail_x4_L9_r0_body.gjcl37 (PRE_first_tail_x4_L9_r0_body.cjcl36 bodyClean36)

kernel_rfl bodyJsLe37 : Nat.ble PRE_first_tail_x4_L9_r0_body.s817.next PRE_first_tail_x4_L9_r0_body.s839.next = true
kernel_rfl bodyJsList37 : (PRE_first_tail_x4_L9_r0_body.gjh37 ++ PRE_first_tail_x4_L9_r0_body.cl37).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s839.next) PRE_first_tail_x4_L9_r0_body.s841) = true
theorem bodyJs37 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s839.next PRE_first_tail_x4_L9_r0_body.s841 :=
  JsHeapAbove.glueSite bodyJs36 (Nat.le_of_ble_eq_true bodyJsLe37) PRE_first_tail_x4_L9_r0_body.gjk37 PRE_first_tail_x4_L9_r0_body.gjbd37 PRE_first_tail_x4_L9_r0_body.cheap37 PRE_first_tail_x4_L9_r0_body.zclbd37 bodyJsList37

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO819 : PRE_first_tail_x4_L9_r0_body.S819.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S819.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr819 : bridgeOf PRE_first_tail_x4_L9_r0_body.s819.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc819 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s819 PRE_first_tail_x4_L9_r0_body.S819) = fun _ _ => true
kernel_rfl bodyAcc820 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s820 PRE_first_tail_x4_L9_r0_body.S820) = fun _ _ => true
kernel_rfl bodyBr821 : bridgeOf PRE_first_tail_x4_L9_r0_body.s821.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt820 : isHalt PRE_first_tail_x4_L9_r0_body.s820.ctl = false
kernel_rfl bodyTop821 : noRetBlock PRE_first_tail_x4_L9_r0_body.s821 = true
kernel_rfl bodyCnt819 : countersOkB PRE_first_tail_x4_L9_r0_body.s819 PRE_first_tail_x4_L9_r0_body.s821 = true
kernel_rfl bodyO821 : PRE_first_tail_x4_L9_r0_body.S821.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S821.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr822 : bridgeOf PRE_first_tail_x4_L9_r0_body.s822.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt821 : countersOkB PRE_first_tail_x4_L9_r0_body.s821 PRE_first_tail_x4_L9_r0_body.s822 = true
kernel_rfl bodyO822 : PRE_first_tail_x4_L9_r0_body.S822.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S822.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc822 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s822 PRE_first_tail_x4_L9_r0_body.S822) = fun _ _ => true
kernel_rfl bodyAcc826 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s826 PRE_first_tail_x4_L9_r0_body.S826) = fun _ _ => true
kernel_rfl bodyBr827 : bridgeOf PRE_first_tail_x4_L9_r0_body.s827.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt826 : isHalt PRE_first_tail_x4_L9_r0_body.s826.ctl = false
kernel_rfl bodyTop827 : noRetBlock PRE_first_tail_x4_L9_r0_body.s827 = true
kernel_rfl bodyCnt822 : countersOkB PRE_first_tail_x4_L9_r0_body.s822 PRE_first_tail_x4_L9_r0_body.s827 = true
kernel_rfl bodyO827 : PRE_first_tail_x4_L9_r0_body.S827.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S827.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr828 : bridgeOf PRE_first_tail_x4_L9_r0_body.s828.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt827 : countersOkB PRE_first_tail_x4_L9_r0_body.s827 PRE_first_tail_x4_L9_r0_body.s828 = true
kernel_rfl bodyO828 : PRE_first_tail_x4_L9_r0_body.S828.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S828.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc828 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s828 PRE_first_tail_x4_L9_r0_body.S828) = fun _ _ => true
kernel_rfl bodyAcc829 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s829 PRE_first_tail_x4_L9_r0_body.S829) = fun _ _ => true
kernel_rfl bodyBr830 : bridgeOf PRE_first_tail_x4_L9_r0_body.s830.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt829 : isHalt PRE_first_tail_x4_L9_r0_body.s829.ctl = false
kernel_rfl bodyTop830 : noRetBlock PRE_first_tail_x4_L9_r0_body.s830 = true
kernel_rfl bodyCnt828 : countersOkB PRE_first_tail_x4_L9_r0_body.s828 PRE_first_tail_x4_L9_r0_body.s830 = true
kernel_rfl bodyO830 : PRE_first_tail_x4_L9_r0_body.S830.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S830.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr831 : bridgeOf PRE_first_tail_x4_L9_r0_body.s831.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt830 : countersOkB PRE_first_tail_x4_L9_r0_body.s830 PRE_first_tail_x4_L9_r0_body.s831 = true
kernel_rfl bodyO831 : PRE_first_tail_x4_L9_r0_body.S831.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S831.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc831 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s831 PRE_first_tail_x4_L9_r0_body.S831) = fun _ _ => true
kernel_rfl bodyAcc832 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s832 PRE_first_tail_x4_L9_r0_body.S832) = fun _ _ => true
kernel_rfl bodyBr833 : bridgeOf PRE_first_tail_x4_L9_r0_body.s833.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt832 : isHalt PRE_first_tail_x4_L9_r0_body.s832.ctl = false
kernel_rfl bodyTop833 : noRetBlock PRE_first_tail_x4_L9_r0_body.s833 = true
kernel_rfl bodyCnt831 : countersOkB PRE_first_tail_x4_L9_r0_body.s831 PRE_first_tail_x4_L9_r0_body.s833 = true
kernel_rfl bodyO833 : PRE_first_tail_x4_L9_r0_body.S833.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S833.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr834 : bridgeOf PRE_first_tail_x4_L9_r0_body.s834.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt833 : countersOkB PRE_first_tail_x4_L9_r0_body.s833 PRE_first_tail_x4_L9_r0_body.s834 = true
kernel_rfl bodyO834 : PRE_first_tail_x4_L9_r0_body.S834.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S834.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc834 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s834 PRE_first_tail_x4_L9_r0_body.S834) = fun _ _ => true
kernel_rfl bodyAcc835 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s835 PRE_first_tail_x4_L9_r0_body.S835) = fun _ _ => true
kernel_rfl bodyBr836 : bridgeOf PRE_first_tail_x4_L9_r0_body.s836.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt835 : isHalt PRE_first_tail_x4_L9_r0_body.s835.ctl = false
kernel_rfl bodyTop836 : noRetBlock PRE_first_tail_x4_L9_r0_body.s836 = true
kernel_rfl bodyCnt834 : countersOkB PRE_first_tail_x4_L9_r0_body.s834 PRE_first_tail_x4_L9_r0_body.s836 = true
kernel_rfl bodyO836 : PRE_first_tail_x4_L9_r0_body.S836.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S836.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr837 : bridgeOf PRE_first_tail_x4_L9_r0_body.s837.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt836 : countersOkB PRE_first_tail_x4_L9_r0_body.s836 PRE_first_tail_x4_L9_r0_body.s837 = true
kernel_rfl bodyO837 : PRE_first_tail_x4_L9_r0_body.S837.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S837.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc837 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s837 PRE_first_tail_x4_L9_r0_body.S837) = fun _ _ => true
kernel_rfl bodyAcc838 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s838 PRE_first_tail_x4_L9_r0_body.S838) = fun _ _ => true
kernel_rfl bodyBr839 : bridgeOf PRE_first_tail_x4_L9_r0_body.s839.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt838 : isHalt PRE_first_tail_x4_L9_r0_body.s838.ctl = false
kernel_rfl bodyTop839 : noRetBlock PRE_first_tail_x4_L9_r0_body.s839 = true
kernel_rfl bodyCnt837 : countersOkB PRE_first_tail_x4_L9_r0_body.s837 PRE_first_tail_x4_L9_r0_body.s839 = true

theorem bodyGlue37 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨39436, 739, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s819 PRE_first_tail_x4_L9_r0_body.S819)
      (bodyCut NB T tk π i x0 bodyΘ ⟨39436, 739, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s839 PRE_first_tail_x4_L9_r0_body.S839) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) bodyAcc819 PRE_first_tail_x4_L9_r0_body.bodyRunSeg212 bodyAcc820 bodyHalt820 PRE_first_tail_x4_L9_r0_body.bodyStepA213 bodyTop821 (fun _ hm => bodyO819 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr819).trans bodyInactive0) (bodyBr821.trans bodyBr819.symm) bodyCnt819 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA213 PRE_first_tail_x4_L9_r0_body.sizeArgsA213 PRE_first_tail_x4_L9_r0_body.sizeSymA213 PRE_first_tail_x4_L9_r0_body.sizeMlxA213 PRE_first_tail_x4_L9_r0_body.sizePayA213 PRE_first_tail_x4_L9_r0_body.sizeTaA213 PRE_first_tail_x4_L9_r0_body.sizeDecA213 PRE_first_tail_x4_L9_r0_body.sizePreA213 PRE_first_tail_x4_L9_r0_body.bodyPatchB213 (fun _ hm => bodyO821 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr821).trans bodyInactive0) (bodyBr822.trans bodyBr821.symm) bodyCnt821 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) bodyAcc822 PRE_first_tail_x4_L9_r0_body.bodyRunSeg213 bodyAcc826 bodyHalt826 PRE_first_tail_x4_L9_r0_body.bodyStepA214 bodyTop827 (fun _ hm => bodyO822 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr822).trans bodyInactive0) (bodyBr827.trans bodyBr822.symm) bodyCnt822 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA214 PRE_first_tail_x4_L9_r0_body.sizeArgsA214 PRE_first_tail_x4_L9_r0_body.sizeSymA214 PRE_first_tail_x4_L9_r0_body.sizeMlxA214 PRE_first_tail_x4_L9_r0_body.sizePayA214 PRE_first_tail_x4_L9_r0_body.sizeTaA214 PRE_first_tail_x4_L9_r0_body.sizeDecA214 PRE_first_tail_x4_L9_r0_body.sizePreA214 PRE_first_tail_x4_L9_r0_body.bodyPatchB214 (fun _ hm => bodyO827 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr827).trans bodyInactive0) (bodyBr828.trans bodyBr827.symm) bodyCnt827 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) bodyAcc828 PRE_first_tail_x4_L9_r0_body.bodyRunSeg214 bodyAcc829 bodyHalt829 PRE_first_tail_x4_L9_r0_body.bodyStepA215 bodyTop830 (fun _ hm => bodyO828 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr828).trans bodyInactive0) (bodyBr830.trans bodyBr828.symm) bodyCnt828 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA215 PRE_first_tail_x4_L9_r0_body.sizeArgsA215 PRE_first_tail_x4_L9_r0_body.sizeSymA215 PRE_first_tail_x4_L9_r0_body.sizeMlxA215 PRE_first_tail_x4_L9_r0_body.sizePayA215 PRE_first_tail_x4_L9_r0_body.sizeTaA215 PRE_first_tail_x4_L9_r0_body.sizeDecA215 PRE_first_tail_x4_L9_r0_body.sizePreA215 PRE_first_tail_x4_L9_r0_body.bodyPatchB215 (fun _ hm => bodyO830 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr830).trans bodyInactive0) (bodyBr831.trans bodyBr830.symm) bodyCnt830 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) bodyAcc831 PRE_first_tail_x4_L9_r0_body.bodyRunSeg215 bodyAcc832 bodyHalt832 PRE_first_tail_x4_L9_r0_body.bodyStepA216 bodyTop833 (fun _ hm => bodyO831 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr831).trans bodyInactive0) (bodyBr833.trans bodyBr831.symm) bodyCnt831 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA216 PRE_first_tail_x4_L9_r0_body.sizeArgsA216 PRE_first_tail_x4_L9_r0_body.sizeSymA216 PRE_first_tail_x4_L9_r0_body.sizeMlxA216 PRE_first_tail_x4_L9_r0_body.sizePayA216 PRE_first_tail_x4_L9_r0_body.sizeTaA216 PRE_first_tail_x4_L9_r0_body.sizeDecA216 PRE_first_tail_x4_L9_r0_body.sizePreA216 PRE_first_tail_x4_L9_r0_body.bodyPatchB216 (fun _ hm => bodyO833 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr833).trans bodyInactive0) (bodyBr834.trans bodyBr833.symm) bodyCnt833 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) bodyAcc834 PRE_first_tail_x4_L9_r0_body.bodyRunSeg216 bodyAcc835 bodyHalt835 PRE_first_tail_x4_L9_r0_body.bodyStepA217 bodyTop836 (fun _ hm => bodyO834 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr834).trans bodyInactive0) (bodyBr836.trans bodyBr834.symm) bodyCnt834 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA217 PRE_first_tail_x4_L9_r0_body.sizeArgsA217 PRE_first_tail_x4_L9_r0_body.sizeSymA217 PRE_first_tail_x4_L9_r0_body.sizeMlxA217 PRE_first_tail_x4_L9_r0_body.sizePayA217 PRE_first_tail_x4_L9_r0_body.sizeTaA217 PRE_first_tail_x4_L9_r0_body.sizeDecA217 PRE_first_tail_x4_L9_r0_body.sizePreA217 PRE_first_tail_x4_L9_r0_body.bodyPatchB217 (fun _ hm => bodyO836 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr836).trans bodyInactive0) (bodyBr837.trans bodyBr836.symm) bodyCnt836 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39436, 739, 0, 0⟩) bodyAcc837 PRE_first_tail_x4_L9_r0_body.bodyRunSeg217 bodyAcc838 bodyHalt838 PRE_first_tail_x4_L9_r0_body.bodyStepA218 bodyTop839 (fun _ hm => bodyO837 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr837).trans bodyInactive0) (bodyBr839.trans bodyBr837.symm) bodyCnt837 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift37 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S839.tab.length PRE_first_tail_x4_L9_r0_body.s839.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P37.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P37 15 PRE_first_tail_x4_L9_r0_body.kappa37 PRE_first_tail_x4_L9_r0_body.s841.ffi PRE_first_tail_x4_L9_r0_body.s840.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_37
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_37
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s841.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S839.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_37] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK37 PRE_first_tail_x4_L9_r0_body.cobjsK37
      PRE_first_tail_x4_L9_r0_body.citemsK37 PRE_first_tail_x4_L9_r0_body.cbd37 PRE_first_tail_x4_L9_r0_body.csst37
  exact PRE_first_tail_x4_L9_r0_body.cshift37 bodyNcl37 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_37] at this; exact this)


kernel_rfl bodyFramesEmpty37 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s840 a).isEmpty) = true
kernel_rfl bodyJsRoots37 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s839.next) PRE_first_tail_x4_L9_r0_body.s841.trace PRE_first_tail_x4_L9_r0_body.s841 = true
kernel_rfl bodyJsNative37 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s841.ffi) = true
kernel_rfl bodyLow37 : (PRE_first_tail_x4_L9_r0_body.cws37 ++ PRE_first_tail_x4_L9_r0_body.ws37).all (Nat.ble 9) = true
kernel_rfl bodyCntM37 : countersOkB PRE_first_tail_x4_L9_r0_body.s839 PRE_first_tail_x4_L9_r0_body.s840 = true
kernel_rfl bodyHi37 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s841.ffi).next setupP.E = true
kernel_rfl bodyNhi37 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s841.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge37 : bridgeOf PRE_first_tail_x4_L9_r0_body.s840.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s839.ffi
kernel_rfl bodyNN37 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s839.ffi).nnext PRE_first_tail_x4_L9_r0_body.P37.NL = true
kernel_rfl bodyXn37 : Nat.ble (⟨20517, 17618, 2767898, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s841.ffi).next = true
kernel_rfl bodyLo37 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s841.ffi).next = true
theorem bodyFacts37 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s839 PRE_first_tail_x4_L9_r0_body.s840 PRE_first_tail_x4_L9_r0_body.s841 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S839 PRE_first_tail_x4_L9_r0_body.S840 PRE_first_tail_x4_L9_r0_body.S841
    PRE_first_tail_x4_L9_r0_body.ws37 PRE_first_tail_x4_L9_r0_body.cws37 PRE_first_tail_x4_L9_r0_body.nr37 PRE_first_tail_x4_L9_r0_body.pl37 PRE_first_tail_x4_L9_r0_body.cl37 2769047 15 PRE_first_tail_x4_L9_r0_body.kd37 PRE_first_tail_x4_L9_r0_body.kappa37 PRE_first_tail_x4_L9_r0_body.P37
    ⟨20514, 17591, 2767892, 15⟩ ⟨20517, 17618, 2767898, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap37
  clean := bodyClean37
  cfix := PRE_first_tail_x4_L9_r0_body.cfix37
  zpl := PRE_first_tail_x4_L9_r0_body.zpl37
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd37
  zn1 := PRE_first_tail_x4_L9_r0_body.zn137
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst37
  zscn := PRE_first_tail_x4_L9_r0_body.zscn37
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn37
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow37
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab37
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh37
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd37
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi37
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt37
  zgP := PRE_first_tail_x4_L9_r0_body.zg37_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk37_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm37_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg37_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk37_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm37_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw37_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw37_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap37
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd37
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap37 PRE_first_tail_x4_L9_r0_body.stFoot37 PRE_first_tail_x4_L9_r0_body.iso37 PRE_first_tail_x4_L9_r0_body.zwr37
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP37
  csupp := PRE_first_tail_x4_L9_r0_body.csupp37
  cbound := PRE_first_tail_x4_L9_r0_body.cbound37
  zimg := PRE_first_tail_x4_L9_r0_body.zimg37
  zctl := PRE_first_tail_x4_L9_r0_body.zctl37
  zstack := PRE_first_tail_x4_L9_r0_body.zstack37
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs37
  zstores := PRE_first_tail_x4_L9_r0_body.zstores37
  zroots := PRE_first_tail_x4_L9_r0_body.zroots37
  znC := PRE_first_tail_x4_L9_r0_body.znC37
  ctab := PRE_first_tail_x4_L9_r0_body.ctab37
  zbin := PRE_first_tail_x4_L9_r0_body.zbin37
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge37
  sbridge := bodyBridge37
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj37
  cshiftR := fun h hNL => bodyCshift37 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN37
  raised := PRE_first_tail_x4_L9_r0_body.raised37
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs37
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl37
  xnLe := Nat.le_of_ble_eq_true bodyXn37
  loLe := Nat.le_of_ble_eq_true bodyLo37
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB37
  cntM := bodyCntM37
  hiLe := Nat.le_of_ble_eq_true bodyHi37
  nhiLe := Nat.le_of_ble_eq_true bodyNhi37
  jsHeap := bodyJs37
  jsRoots := bodyJsRoots37
  jsNative := bodyJsNative37
  framesEmpty := bodyFramesEmpty37
  trailOld := by decide
  lowVars := bodyLow37

def bodyQs37 : List (Option Q) := []
noncomputable def bodyEs37 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr37.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st37.S5.tab r
kernel_rfl bodyResChk37 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs37 bodyQs37) = true
kernel_rfl bodyLq37 : bodyQs37.length = PRE_first_tail_x4_L9_r0_body.cws37.length
kernel_rfl bodyNrLo37 : PRE_first_tail_x4_L9_r0_body.nr37.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S839.tab.length) = true
kernel_rfl bodySub37 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site37.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost37 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws37 PRE_first_tail_x4_L9_r0_body.cws37 bodyQs37 = true
kernel_rfl bodyDrop37 : Nat.ble (39436 + (PRE_first_tail_x4_L9_r0_body.s840.next - PRE_first_tail_x4_L9_r0_body.s841.next)) 40585 = true
kernel_rfl bodyDropH37 : Nat.ble (739 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s840.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s841.ffi).next)) 764 = true
kernel_rfl bodyDropN37 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s840.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s841.ffi).nnext)) 0 = true
kernel_rfl bodyDv37 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws37
kernel_rfl bodyDe37 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr37.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st37.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl37 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold37 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws37).isNone && !PRE_first_tail_x4_L9_r0_body.ws37.contains v) = true
kernel_rfl bodyDfree37 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws37 ++ PRE_first_tail_x4_L9_r0_body.ws37).all fun w => e.noVar w) = true

theorem bodyStep37 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨39436, 739, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s839 PRE_first_tail_x4_L9_r0_body.S839)
      (bodyCut NB T tk π i x0 bodyΘ ⟨40585, 764, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s841 PRE_first_tail_x4_L9_r0_body.S841) (11334 + 1) :=
  bodySite bodyFacts37.cfix bodyFacts37.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st37.S5.tab) (Es := bodyEs37) (qs := bodyQs37)
    (ok := PRE_first_tail_x4_L9_r0_body.st37.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site37 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts37
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site37 r hr) hi (MapOk.sub hm (sub_of_all bodySub37)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk37 r hr) hi hm ho hq)
    bodyLq37 rfl bodyNrLo37 (postSub_sound bodyPost37)
    (Nat.le_of_ble_eq_true bodyDrop37) (by decide) (Nat.le_of_ble_eq_true bodyDropH37) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN37) (by decide)
    bodyDv37 bodyDe37 bodyDl37 bodyDold37 bodyDfree37 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site38 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site38 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site38) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st38.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site38
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st38.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st38.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s861 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s862 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S861 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws38 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st38.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st38.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso38
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_38
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st38.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot38
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup38
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound38
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace38
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged38
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws38.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st38.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S861.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_38]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen38.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh38
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl38 : Conv.NClean (⟨20571, 17654, 2770130, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s861.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl38 (PRE_first_tail_x4_L9_r0_body.cncl37 bodyNcl37)

theorem bodyClean38 : Conv.JClean (⟨20571, 17654, 2770130, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s861 :=
  PRE_first_tail_x4_L9_r0_body.gjcl38 (PRE_first_tail_x4_L9_r0_body.cjcl37 bodyClean37)

kernel_rfl bodyJsLe38 : Nat.ble PRE_first_tail_x4_L9_r0_body.s839.next PRE_first_tail_x4_L9_r0_body.s861.next = true
kernel_rfl bodyJsList38 : (PRE_first_tail_x4_L9_r0_body.gjh38 ++ PRE_first_tail_x4_L9_r0_body.cl38).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s861.next) PRE_first_tail_x4_L9_r0_body.s863) = true
theorem bodyJs38 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s861.next PRE_first_tail_x4_L9_r0_body.s863 :=
  JsHeapAbove.glueSite bodyJs37 (Nat.le_of_ble_eq_true bodyJsLe38) PRE_first_tail_x4_L9_r0_body.gjk38 PRE_first_tail_x4_L9_r0_body.gjbd38 PRE_first_tail_x4_L9_r0_body.cheap38 PRE_first_tail_x4_L9_r0_body.zclbd38 bodyJsList38

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO841 : PRE_first_tail_x4_L9_r0_body.S841.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S841.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr841 : bridgeOf PRE_first_tail_x4_L9_r0_body.s841.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc841 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s841 PRE_first_tail_x4_L9_r0_body.S841) = fun _ _ => true
kernel_rfl bodyAcc842 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s842 PRE_first_tail_x4_L9_r0_body.S842) = fun _ _ => true
kernel_rfl bodyBr843 : bridgeOf PRE_first_tail_x4_L9_r0_body.s843.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt842 : isHalt PRE_first_tail_x4_L9_r0_body.s842.ctl = false
kernel_rfl bodyTop843 : noRetBlock PRE_first_tail_x4_L9_r0_body.s843 = true
kernel_rfl bodyCnt841 : countersOkB PRE_first_tail_x4_L9_r0_body.s841 PRE_first_tail_x4_L9_r0_body.s843 = true
kernel_rfl bodyO843 : PRE_first_tail_x4_L9_r0_body.S843.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S843.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr844 : bridgeOf PRE_first_tail_x4_L9_r0_body.s844.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt843 : countersOkB PRE_first_tail_x4_L9_r0_body.s843 PRE_first_tail_x4_L9_r0_body.s844 = true
kernel_rfl bodyO844 : PRE_first_tail_x4_L9_r0_body.S844.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S844.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc844 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s844 PRE_first_tail_x4_L9_r0_body.S844) = fun _ _ => true
kernel_rfl bodyAcc848 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s848 PRE_first_tail_x4_L9_r0_body.S848) = fun _ _ => true
kernel_rfl bodyBr849 : bridgeOf PRE_first_tail_x4_L9_r0_body.s849.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt848 : isHalt PRE_first_tail_x4_L9_r0_body.s848.ctl = false
kernel_rfl bodyTop849 : noRetBlock PRE_first_tail_x4_L9_r0_body.s849 = true
kernel_rfl bodyCnt844 : countersOkB PRE_first_tail_x4_L9_r0_body.s844 PRE_first_tail_x4_L9_r0_body.s849 = true
kernel_rfl bodyO849 : PRE_first_tail_x4_L9_r0_body.S849.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S849.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr850 : bridgeOf PRE_first_tail_x4_L9_r0_body.s850.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt849 : countersOkB PRE_first_tail_x4_L9_r0_body.s849 PRE_first_tail_x4_L9_r0_body.s850 = true
kernel_rfl bodyO850 : PRE_first_tail_x4_L9_r0_body.S850.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S850.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc850 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s850 PRE_first_tail_x4_L9_r0_body.S850) = fun _ _ => true
kernel_rfl bodyAcc851 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s851 PRE_first_tail_x4_L9_r0_body.S851) = fun _ _ => true
kernel_rfl bodyBr852 : bridgeOf PRE_first_tail_x4_L9_r0_body.s852.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt851 : isHalt PRE_first_tail_x4_L9_r0_body.s851.ctl = false
kernel_rfl bodyTop852 : noRetBlock PRE_first_tail_x4_L9_r0_body.s852 = true
kernel_rfl bodyCnt850 : countersOkB PRE_first_tail_x4_L9_r0_body.s850 PRE_first_tail_x4_L9_r0_body.s852 = true
kernel_rfl bodyO852 : PRE_first_tail_x4_L9_r0_body.S852.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S852.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr853 : bridgeOf PRE_first_tail_x4_L9_r0_body.s853.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt852 : countersOkB PRE_first_tail_x4_L9_r0_body.s852 PRE_first_tail_x4_L9_r0_body.s853 = true
kernel_rfl bodyO853 : PRE_first_tail_x4_L9_r0_body.S853.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S853.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc853 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s853 PRE_first_tail_x4_L9_r0_body.S853) = fun _ _ => true
kernel_rfl bodyAcc854 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s854 PRE_first_tail_x4_L9_r0_body.S854) = fun _ _ => true
kernel_rfl bodyBr855 : bridgeOf PRE_first_tail_x4_L9_r0_body.s855.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt854 : isHalt PRE_first_tail_x4_L9_r0_body.s854.ctl = false
kernel_rfl bodyTop855 : noRetBlock PRE_first_tail_x4_L9_r0_body.s855 = true
kernel_rfl bodyCnt853 : countersOkB PRE_first_tail_x4_L9_r0_body.s853 PRE_first_tail_x4_L9_r0_body.s855 = true
kernel_rfl bodyO855 : PRE_first_tail_x4_L9_r0_body.S855.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S855.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr856 : bridgeOf PRE_first_tail_x4_L9_r0_body.s856.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt855 : countersOkB PRE_first_tail_x4_L9_r0_body.s855 PRE_first_tail_x4_L9_r0_body.s856 = true
kernel_rfl bodyO856 : PRE_first_tail_x4_L9_r0_body.S856.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S856.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc856 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s856 PRE_first_tail_x4_L9_r0_body.S856) = fun _ _ => true
kernel_rfl bodyAcc857 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s857 PRE_first_tail_x4_L9_r0_body.S857) = fun _ _ => true
kernel_rfl bodyBr858 : bridgeOf PRE_first_tail_x4_L9_r0_body.s858.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt857 : isHalt PRE_first_tail_x4_L9_r0_body.s857.ctl = false
kernel_rfl bodyTop858 : noRetBlock PRE_first_tail_x4_L9_r0_body.s858 = true
kernel_rfl bodyCnt856 : countersOkB PRE_first_tail_x4_L9_r0_body.s856 PRE_first_tail_x4_L9_r0_body.s858 = true
kernel_rfl bodyO858 : PRE_first_tail_x4_L9_r0_body.S858.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S858.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr859 : bridgeOf PRE_first_tail_x4_L9_r0_body.s859.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt858 : countersOkB PRE_first_tail_x4_L9_r0_body.s858 PRE_first_tail_x4_L9_r0_body.s859 = true
kernel_rfl bodyO859 : PRE_first_tail_x4_L9_r0_body.S859.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S859.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc859 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s859 PRE_first_tail_x4_L9_r0_body.S859) = fun _ _ => true
kernel_rfl bodyAcc860 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s860 PRE_first_tail_x4_L9_r0_body.S860) = fun _ _ => true
kernel_rfl bodyBr861 : bridgeOf PRE_first_tail_x4_L9_r0_body.s861.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt860 : isHalt PRE_first_tail_x4_L9_r0_body.s860.ctl = false
kernel_rfl bodyTop861 : noRetBlock PRE_first_tail_x4_L9_r0_body.s861 = true
kernel_rfl bodyCnt859 : countersOkB PRE_first_tail_x4_L9_r0_body.s859 PRE_first_tail_x4_L9_r0_body.s861 = true

theorem bodyGlue38 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨40585, 764, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s841 PRE_first_tail_x4_L9_r0_body.S841)
      (bodyCut NB T tk π i x0 bodyΘ ⟨40585, 764, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s861 PRE_first_tail_x4_L9_r0_body.S861) 22217 :=
  (((((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) bodyAcc841 PRE_first_tail_x4_L9_r0_body.bodyRunSeg218 bodyAcc842 bodyHalt842 PRE_first_tail_x4_L9_r0_body.bodyStepA219 bodyTop843 (fun _ hm => bodyO841 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr841).trans bodyInactive0) (bodyBr843.trans bodyBr841.symm) bodyCnt841 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA219 PRE_first_tail_x4_L9_r0_body.sizeArgsA219 PRE_first_tail_x4_L9_r0_body.sizeSymA219 PRE_first_tail_x4_L9_r0_body.sizeMlxA219 PRE_first_tail_x4_L9_r0_body.sizePayA219 PRE_first_tail_x4_L9_r0_body.sizeTaA219 PRE_first_tail_x4_L9_r0_body.sizeDecA219 PRE_first_tail_x4_L9_r0_body.sizePreA219 PRE_first_tail_x4_L9_r0_body.bodyPatchB219 (fun _ hm => bodyO843 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr843).trans bodyInactive0) (bodyBr844.trans bodyBr843.symm) bodyCnt843 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) bodyAcc844 PRE_first_tail_x4_L9_r0_body.bodyRunSeg219 bodyAcc848 bodyHalt848 PRE_first_tail_x4_L9_r0_body.bodyStepA220 bodyTop849 (fun _ hm => bodyO844 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr844).trans bodyInactive0) (bodyBr849.trans bodyBr844.symm) bodyCnt844 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA220 PRE_first_tail_x4_L9_r0_body.sizeArgsA220 PRE_first_tail_x4_L9_r0_body.sizeSymA220 PRE_first_tail_x4_L9_r0_body.sizeMlxA220 PRE_first_tail_x4_L9_r0_body.sizePayA220 PRE_first_tail_x4_L9_r0_body.sizeTaA220 PRE_first_tail_x4_L9_r0_body.sizeDecA220 PRE_first_tail_x4_L9_r0_body.sizePreA220 PRE_first_tail_x4_L9_r0_body.bodyPatchB220 (fun _ hm => bodyO849 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr849).trans bodyInactive0) (bodyBr850.trans bodyBr849.symm) bodyCnt849 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) bodyAcc850 PRE_first_tail_x4_L9_r0_body.bodyRunSeg220 bodyAcc851 bodyHalt851 PRE_first_tail_x4_L9_r0_body.bodyStepA221 bodyTop852 (fun _ hm => bodyO850 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr850).trans bodyInactive0) (bodyBr852.trans bodyBr850.symm) bodyCnt850 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA221 PRE_first_tail_x4_L9_r0_body.sizeArgsA221 PRE_first_tail_x4_L9_r0_body.sizeSymA221 PRE_first_tail_x4_L9_r0_body.sizeMlxA221 PRE_first_tail_x4_L9_r0_body.sizePayA221 PRE_first_tail_x4_L9_r0_body.sizeTaA221 PRE_first_tail_x4_L9_r0_body.sizeDecA221 PRE_first_tail_x4_L9_r0_body.sizePreA221 PRE_first_tail_x4_L9_r0_body.bodyPatchB221 (fun _ hm => bodyO852 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr852).trans bodyInactive0) (bodyBr853.trans bodyBr852.symm) bodyCnt852 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) bodyAcc853 PRE_first_tail_x4_L9_r0_body.bodyRunSeg221 bodyAcc854 bodyHalt854 PRE_first_tail_x4_L9_r0_body.bodyStepA222 bodyTop855 (fun _ hm => bodyO853 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr853).trans bodyInactive0) (bodyBr855.trans bodyBr853.symm) bodyCnt853 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA222 PRE_first_tail_x4_L9_r0_body.sizeArgsA222 PRE_first_tail_x4_L9_r0_body.sizeSymA222 PRE_first_tail_x4_L9_r0_body.sizeMlxA222 PRE_first_tail_x4_L9_r0_body.sizePayA222 PRE_first_tail_x4_L9_r0_body.sizeTaA222 PRE_first_tail_x4_L9_r0_body.sizeDecA222 PRE_first_tail_x4_L9_r0_body.sizePreA222 PRE_first_tail_x4_L9_r0_body.bodyPatchB222 (fun _ hm => bodyO855 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr855).trans bodyInactive0) (bodyBr856.trans bodyBr855.symm) bodyCnt855 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) bodyAcc856 PRE_first_tail_x4_L9_r0_body.bodyRunSeg222 bodyAcc857 bodyHalt857 PRE_first_tail_x4_L9_r0_body.bodyStepA223 bodyTop858 (fun _ hm => bodyO856 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr856).trans bodyInactive0) (bodyBr858.trans bodyBr856.symm) bodyCnt856 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA223 PRE_first_tail_x4_L9_r0_body.sizeArgsA223 PRE_first_tail_x4_L9_r0_body.sizeSymA223 PRE_first_tail_x4_L9_r0_body.sizeMlxA223 PRE_first_tail_x4_L9_r0_body.sizePayA223 PRE_first_tail_x4_L9_r0_body.sizeTaA223 PRE_first_tail_x4_L9_r0_body.sizeDecA223 PRE_first_tail_x4_L9_r0_body.sizePreA223 PRE_first_tail_x4_L9_r0_body.bodyPatchB223 (fun _ hm => bodyO858 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr858).trans bodyInactive0) (bodyBr859.trans bodyBr858.symm) bodyCnt858 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨40585, 764, 0, 0⟩) bodyAcc859 PRE_first_tail_x4_L9_r0_body.bodyRunSeg223 bodyAcc860 bodyHalt860 PRE_first_tail_x4_L9_r0_body.bodyStepA224 bodyTop861 (fun _ hm => bodyO859 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr859).trans bodyInactive0) (bodyBr861.trans bodyBr859.symm) bodyCnt859 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift38 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S861.tab.length PRE_first_tail_x4_L9_r0_body.s861.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P38.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P38 15 PRE_first_tail_x4_L9_r0_body.kappa38 PRE_first_tail_x4_L9_r0_body.s863.ffi PRE_first_tail_x4_L9_r0_body.s862.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_38
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_38
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s863.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S861.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_38] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK38 PRE_first_tail_x4_L9_r0_body.cobjsK38
      PRE_first_tail_x4_L9_r0_body.citemsK38 PRE_first_tail_x4_L9_r0_body.cbd38 PRE_first_tail_x4_L9_r0_body.csst38
  exact PRE_first_tail_x4_L9_r0_body.cshift38 bodyNcl38 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_38] at this; exact this)


kernel_rfl bodyFramesEmpty38 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s862 a).isEmpty) = true
kernel_rfl bodyJsRoots38 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s861.next) PRE_first_tail_x4_L9_r0_body.s863.trace PRE_first_tail_x4_L9_r0_body.s863 = true
kernel_rfl bodyJsNative38 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s863.ffi) = true
kernel_rfl bodyLow38 : (PRE_first_tail_x4_L9_r0_body.cws38 ++ PRE_first_tail_x4_L9_r0_body.ws38).all (Nat.ble 9) = true
kernel_rfl bodyCntM38 : countersOkB PRE_first_tail_x4_L9_r0_body.s861 PRE_first_tail_x4_L9_r0_body.s862 = true
kernel_rfl bodyHi38 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s863.ffi).next setupP.E = true
kernel_rfl bodyNhi38 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s863.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge38 : bridgeOf PRE_first_tail_x4_L9_r0_body.s862.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s861.ffi
kernel_rfl bodyNN38 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s861.ffi).nnext PRE_first_tail_x4_L9_r0_body.P38.NL = true
kernel_rfl bodyXn38 : Nat.ble (⟨20574, 17681, 2770136, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s863.ffi).next = true
kernel_rfl bodyLo38 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s863.ffi).next = true
theorem bodyFacts38 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s861 PRE_first_tail_x4_L9_r0_body.s862 PRE_first_tail_x4_L9_r0_body.s863 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S861 PRE_first_tail_x4_L9_r0_body.S862 PRE_first_tail_x4_L9_r0_body.S863
    PRE_first_tail_x4_L9_r0_body.ws38 PRE_first_tail_x4_L9_r0_body.cws38 PRE_first_tail_x4_L9_r0_body.nr38 PRE_first_tail_x4_L9_r0_body.pl38 PRE_first_tail_x4_L9_r0_body.cl38 2771285 15 PRE_first_tail_x4_L9_r0_body.kd38 PRE_first_tail_x4_L9_r0_body.kappa38 PRE_first_tail_x4_L9_r0_body.P38
    ⟨20571, 17654, 2770130, 15⟩ ⟨20574, 17681, 2770136, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap38
  clean := bodyClean38
  cfix := PRE_first_tail_x4_L9_r0_body.cfix38
  zpl := PRE_first_tail_x4_L9_r0_body.zpl38
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd38
  zn1 := PRE_first_tail_x4_L9_r0_body.zn138
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst38
  zscn := PRE_first_tail_x4_L9_r0_body.zscn38
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn38
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow38
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab38
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh38
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd38
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi38
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt38
  zgP := PRE_first_tail_x4_L9_r0_body.zg38_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk38_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm38_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg38_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk38_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm38_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw38_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw38_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap38
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd38
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap38 PRE_first_tail_x4_L9_r0_body.stFoot38 PRE_first_tail_x4_L9_r0_body.iso38 PRE_first_tail_x4_L9_r0_body.zwr38
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP38
  csupp := PRE_first_tail_x4_L9_r0_body.csupp38
  cbound := PRE_first_tail_x4_L9_r0_body.cbound38
  zimg := PRE_first_tail_x4_L9_r0_body.zimg38
  zctl := PRE_first_tail_x4_L9_r0_body.zctl38
  zstack := PRE_first_tail_x4_L9_r0_body.zstack38
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs38
  zstores := PRE_first_tail_x4_L9_r0_body.zstores38
  zroots := PRE_first_tail_x4_L9_r0_body.zroots38
  znC := PRE_first_tail_x4_L9_r0_body.znC38
  ctab := PRE_first_tail_x4_L9_r0_body.ctab38
  zbin := PRE_first_tail_x4_L9_r0_body.zbin38
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge38
  sbridge := bodyBridge38
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj38
  cshiftR := fun h hNL => bodyCshift38 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN38
  raised := PRE_first_tail_x4_L9_r0_body.raised38
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs38
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl38
  xnLe := Nat.le_of_ble_eq_true bodyXn38
  loLe := Nat.le_of_ble_eq_true bodyLo38
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB38
  cntM := bodyCntM38
  hiLe := Nat.le_of_ble_eq_true bodyHi38
  nhiLe := Nat.le_of_ble_eq_true bodyNhi38
  jsHeap := bodyJs38
  jsRoots := bodyJsRoots38
  jsNative := bodyJsNative38
  framesEmpty := bodyFramesEmpty38
  trailOld := by decide
  lowVars := bodyLow38

def bodyQs38 : List (Option Q) := []
noncomputable def bodyEs38 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr38.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st38.S5.tab r
kernel_rfl bodyResChk38 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs38 bodyQs38) = true
kernel_rfl bodyLq38 : bodyQs38.length = PRE_first_tail_x4_L9_r0_body.cws38.length
kernel_rfl bodyNrLo38 : PRE_first_tail_x4_L9_r0_body.nr38.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S861.tab.length) = true
kernel_rfl bodySub38 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site38.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost38 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws38 PRE_first_tail_x4_L9_r0_body.cws38 bodyQs38 = true
kernel_rfl bodyDrop38 : Nat.ble (40585 + (PRE_first_tail_x4_L9_r0_body.s862.next - PRE_first_tail_x4_L9_r0_body.s863.next)) 41734 = true
kernel_rfl bodyDropH38 : Nat.ble (764 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s862.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s863.ffi).next)) 789 = true
kernel_rfl bodyDropN38 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s862.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s863.ffi).nnext)) 0 = true
kernel_rfl bodyDv38 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws38
kernel_rfl bodyDe38 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr38.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st38.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl38 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold38 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws38).isNone && !PRE_first_tail_x4_L9_r0_body.ws38.contains v) = true
kernel_rfl bodyDfree38 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws38 ++ PRE_first_tail_x4_L9_r0_body.ws38).all fun w => e.noVar w) = true

theorem bodyStep38 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨40585, 764, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s861 PRE_first_tail_x4_L9_r0_body.S861)
      (bodyCut NB T tk π i x0 bodyΘ ⟨41734, 789, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s863 PRE_first_tail_x4_L9_r0_body.S863) (11334 + 1) :=
  bodySite bodyFacts38.cfix bodyFacts38.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x4_L9_r0_body.st38.S5.tab) (Es := bodyEs38) (qs := bodyQs38)
    (ok := PRE_first_tail_x4_L9_r0_body.st38.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site38 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts38
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site38 r hr) hi (MapOk.sub hm (sub_of_all bodySub38)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk38 r hr) hi hm ho hq)
    bodyLq38 rfl bodyNrLo38 (postSub_sound bodyPost38)
    (Nat.le_of_ble_eq_true bodyDrop38) (by decide) (Nat.le_of_ble_eq_true bodyDropH38) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN38) (by decide)
    bodyDv38 bodyDe38 bodyDl38 bodyDold38 bodyDfree38 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodySite39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_site39 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_site39 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_site39) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st39.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_body.site39
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st39.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st39.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s882 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.s883 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S882 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws39 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st39.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st39.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.iso39
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_39
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st39.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.stFoot39
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrNodup39
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.wrBound39
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.trace39
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.merged39
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.ws39.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.st39.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.S882.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.tab0_39]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.mergeLen39.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.fresh39
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl39 : Conv.NClean (⟨20634, 17726, 2772633, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s882.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_body.gncl39 (PRE_first_tail_x4_L9_r0_body.cncl38 bodyNcl38)

theorem bodyClean39 : Conv.JClean (⟨20634, 17726, 2772633, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_body.s882 :=
  PRE_first_tail_x4_L9_r0_body.gjcl39 (PRE_first_tail_x4_L9_r0_body.cjcl38 bodyClean38)

kernel_rfl bodyJsLe39 : Nat.ble PRE_first_tail_x4_L9_r0_body.s861.next PRE_first_tail_x4_L9_r0_body.s882.next = true
kernel_rfl bodyJsList39 : (PRE_first_tail_x4_L9_r0_body.gjh39 ++ PRE_first_tail_x4_L9_r0_body.cl39).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_body.s882.next) PRE_first_tail_x4_L9_r0_body.s884) = true
theorem bodyJs39 : JsHeapAbove PRE_first_tail_x4_L9_r0_body.s882.next PRE_first_tail_x4_L9_r0_body.s884 :=
  JsHeapAbove.glueSite bodyJs38 (Nat.le_of_ble_eq_true bodyJsLe39) PRE_first_tail_x4_L9_r0_body.gjk39 PRE_first_tail_x4_L9_r0_body.gjbd39 PRE_first_tail_x4_L9_r0_body.cheap39 PRE_first_tail_x4_L9_r0_body.zclbd39 bodyJsList39

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyG39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO863 : PRE_first_tail_x4_L9_r0_body.S863.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S863.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr863 : bridgeOf PRE_first_tail_x4_L9_r0_body.s863.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc863 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s863 PRE_first_tail_x4_L9_r0_body.S863) = fun _ _ => true
kernel_rfl bodyAcc864 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s864 PRE_first_tail_x4_L9_r0_body.S864) = fun _ _ => true
kernel_rfl bodyBr865 : bridgeOf PRE_first_tail_x4_L9_r0_body.s865.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt864 : isHalt PRE_first_tail_x4_L9_r0_body.s864.ctl = false
kernel_rfl bodyTop865 : noRetBlock PRE_first_tail_x4_L9_r0_body.s865 = true
kernel_rfl bodyCnt863 : countersOkB PRE_first_tail_x4_L9_r0_body.s863 PRE_first_tail_x4_L9_r0_body.s865 = true
kernel_rfl bodyO865 : PRE_first_tail_x4_L9_r0_body.S865.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S865.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr866 : bridgeOf PRE_first_tail_x4_L9_r0_body.s866.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt865 : countersOkB PRE_first_tail_x4_L9_r0_body.s865 PRE_first_tail_x4_L9_r0_body.s866 = true
kernel_rfl bodyO866 : PRE_first_tail_x4_L9_r0_body.S866.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S866.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc866 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s866 PRE_first_tail_x4_L9_r0_body.S866) = fun _ _ => true
kernel_rfl bodyAcc870 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s870 PRE_first_tail_x4_L9_r0_body.S870) = fun _ _ => true
kernel_rfl bodyBr871 : bridgeOf PRE_first_tail_x4_L9_r0_body.s871.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt870 : isHalt PRE_first_tail_x4_L9_r0_body.s870.ctl = false
kernel_rfl bodyTop871 : noRetBlock PRE_first_tail_x4_L9_r0_body.s871 = true
kernel_rfl bodyCnt866 : countersOkB PRE_first_tail_x4_L9_r0_body.s866 PRE_first_tail_x4_L9_r0_body.s871 = true
kernel_rfl bodyO871 : PRE_first_tail_x4_L9_r0_body.S871.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S871.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr872 : bridgeOf PRE_first_tail_x4_L9_r0_body.s872.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt871 : countersOkB PRE_first_tail_x4_L9_r0_body.s871 PRE_first_tail_x4_L9_r0_body.s872 = true
kernel_rfl bodyO872 : PRE_first_tail_x4_L9_r0_body.S872.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S872.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc872 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s872 PRE_first_tail_x4_L9_r0_body.S872) = fun _ _ => true
kernel_rfl bodyAcc874 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s874 PRE_first_tail_x4_L9_r0_body.S874) = fun _ _ => true
kernel_rfl bodyBr875 : bridgeOf PRE_first_tail_x4_L9_r0_body.s875.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt874 : isHalt PRE_first_tail_x4_L9_r0_body.s874.ctl = false
kernel_rfl bodyTop875 : noRetBlock PRE_first_tail_x4_L9_r0_body.s875 = true
kernel_rfl bodyCnt872 : countersOkB PRE_first_tail_x4_L9_r0_body.s872 PRE_first_tail_x4_L9_r0_body.s875 = true
kernel_rfl bodyO875 : PRE_first_tail_x4_L9_r0_body.S875.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S875.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr876 : bridgeOf PRE_first_tail_x4_L9_r0_body.s876.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt875 : countersOkB PRE_first_tail_x4_L9_r0_body.s875 PRE_first_tail_x4_L9_r0_body.s876 = true
kernel_rfl bodyO876 : PRE_first_tail_x4_L9_r0_body.S876.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S876.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc876 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s876 PRE_first_tail_x4_L9_r0_body.S876) = fun _ _ => true
kernel_rfl bodyAcc877 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s877 PRE_first_tail_x4_L9_r0_body.S877) = fun _ _ => true
kernel_rfl bodyBr878 : bridgeOf PRE_first_tail_x4_L9_r0_body.s878.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt877 : isHalt PRE_first_tail_x4_L9_r0_body.s877.ctl = false
kernel_rfl bodyTop878 : noRetBlock PRE_first_tail_x4_L9_r0_body.s878 = true
kernel_rfl bodyCnt876 : countersOkB PRE_first_tail_x4_L9_r0_body.s876 PRE_first_tail_x4_L9_r0_body.s878 = true
kernel_rfl bodyO878 : PRE_first_tail_x4_L9_r0_body.S878.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S878.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr879 : bridgeOf PRE_first_tail_x4_L9_r0_body.s879.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt878 : countersOkB PRE_first_tail_x4_L9_r0_body.s878 PRE_first_tail_x4_L9_r0_body.s879 = true
kernel_rfl bodyO879 : PRE_first_tail_x4_L9_r0_body.S879.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S879.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc879 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s879 PRE_first_tail_x4_L9_r0_body.S879) = fun _ _ => true
kernel_rfl bodyAcc881 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s881 PRE_first_tail_x4_L9_r0_body.S881) = fun _ _ => true
kernel_rfl bodyBr882 : bridgeOf PRE_first_tail_x4_L9_r0_body.s882.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt881 : isHalt PRE_first_tail_x4_L9_r0_body.s881.ctl = false
kernel_rfl bodyTop882 : noRetBlock PRE_first_tail_x4_L9_r0_body.s882 = true
kernel_rfl bodyCnt879 : countersOkB PRE_first_tail_x4_L9_r0_body.s879 PRE_first_tail_x4_L9_r0_body.s882 = true

theorem bodyGlue39 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨41734, 789, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s863 PRE_first_tail_x4_L9_r0_body.S863)
      (bodyCut NB T tk π i x0 bodyΘ ⟨41734, 789, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s882 PRE_first_tail_x4_L9_r0_body.S882) 24692 :=
  (((((((((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) bodyAcc863 PRE_first_tail_x4_L9_r0_body.bodyRunSeg224 bodyAcc864 bodyHalt864 PRE_first_tail_x4_L9_r0_body.bodyStepA225 bodyTop865 (fun _ hm => bodyO863 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr863).trans bodyInactive0) (bodyBr865.trans bodyBr863.symm) bodyCnt863 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA225 PRE_first_tail_x4_L9_r0_body.sizeArgsA225 PRE_first_tail_x4_L9_r0_body.sizeSymA225 PRE_first_tail_x4_L9_r0_body.sizeMlxA225 PRE_first_tail_x4_L9_r0_body.sizePayA225 PRE_first_tail_x4_L9_r0_body.sizeTaA225 PRE_first_tail_x4_L9_r0_body.sizeDecA225 PRE_first_tail_x4_L9_r0_body.sizePreA225 PRE_first_tail_x4_L9_r0_body.bodyPatchB225 (fun _ hm => bodyO865 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr865).trans bodyInactive0) (bodyBr866.trans bodyBr865.symm) bodyCnt865 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) bodyAcc866 PRE_first_tail_x4_L9_r0_body.bodyRunSeg225 bodyAcc870 bodyHalt870 PRE_first_tail_x4_L9_r0_body.bodyStepA226 bodyTop871 (fun _ hm => bodyO866 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr866).trans bodyInactive0) (bodyBr871.trans bodyBr866.symm) bodyCnt866 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA226 PRE_first_tail_x4_L9_r0_body.sizeArgsA226 PRE_first_tail_x4_L9_r0_body.sizeSymA226 PRE_first_tail_x4_L9_r0_body.sizeMlxA226 PRE_first_tail_x4_L9_r0_body.sizePayA226 PRE_first_tail_x4_L9_r0_body.sizeTaA226 PRE_first_tail_x4_L9_r0_body.sizeDecA226 PRE_first_tail_x4_L9_r0_body.sizePreA226 PRE_first_tail_x4_L9_r0_body.bodyPatchB226 (fun _ hm => bodyO871 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr871).trans bodyInactive0) (bodyBr872.trans bodyBr871.symm) bodyCnt871 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) bodyAcc872 PRE_first_tail_x4_L9_r0_body.bodyRunSeg226 bodyAcc874 bodyHalt874 PRE_first_tail_x4_L9_r0_body.bodyStepA227 bodyTop875 (fun _ hm => bodyO872 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr872).trans bodyInactive0) (bodyBr875.trans bodyBr872.symm) bodyCnt872 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA227 PRE_first_tail_x4_L9_r0_body.sizeArgsA227 PRE_first_tail_x4_L9_r0_body.sizeSymA227 PRE_first_tail_x4_L9_r0_body.sizeMlxA227 PRE_first_tail_x4_L9_r0_body.sizePayA227 PRE_first_tail_x4_L9_r0_body.sizeTaA227 PRE_first_tail_x4_L9_r0_body.sizeDecA227 PRE_first_tail_x4_L9_r0_body.sizePreA227 PRE_first_tail_x4_L9_r0_body.bodyPatchB227 (fun _ hm => bodyO875 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr875).trans bodyInactive0) (bodyBr876.trans bodyBr875.symm) bodyCnt875 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) bodyAcc876 PRE_first_tail_x4_L9_r0_body.bodyRunSeg227 bodyAcc877 bodyHalt877 PRE_first_tail_x4_L9_r0_body.bodyStepA228 bodyTop878 (fun _ hm => bodyO876 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr876).trans bodyInactive0) (bodyBr878.trans bodyBr876.symm) bodyCnt876 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA228 PRE_first_tail_x4_L9_r0_body.sizeArgsA228 PRE_first_tail_x4_L9_r0_body.sizeSymA228 PRE_first_tail_x4_L9_r0_body.sizeMlxA228 PRE_first_tail_x4_L9_r0_body.sizePayA228 PRE_first_tail_x4_L9_r0_body.sizeTaA228 PRE_first_tail_x4_L9_r0_body.sizeDecA228 PRE_first_tail_x4_L9_r0_body.sizePreA228 PRE_first_tail_x4_L9_r0_body.bodyPatchB228 (fun _ hm => bodyO878 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr878).trans bodyInactive0) (bodyBr879.trans bodyBr878.symm) bodyCnt878 (BodyTrail.ofTrack x0))).trans (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41734, 789, 0, 0⟩) bodyAcc879 PRE_first_tail_x4_L9_r0_body.bodyRunSeg228 bodyAcc881 bodyHalt881 PRE_first_tail_x4_L9_r0_body.bodyStepA229 bodyTop882 (fun _ hm => bodyO879 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr879).trans bodyInactive0) (bodyBr882.trans bodyBr879.symm) bodyCnt879 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end

section -- VWBodyS39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift39 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_body.S882.tab.length PRE_first_tail_x4_L9_r0_body.s882.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_body.P39.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_body.P39 15 PRE_first_tail_x4_L9_r0_body.kappa39 PRE_first_tail_x4_L9_r0_body.s884.ffi PRE_first_tail_x4_L9_r0_body.s883.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_body.ofxC_39
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_body.okrC_39
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_body.s884.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_body.S882.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_body.n0_39] <;> decide) PRE_first_tail_x4_L9_r0_body.cnodesK39 PRE_first_tail_x4_L9_r0_body.cobjsK39
      PRE_first_tail_x4_L9_r0_body.citemsK39 PRE_first_tail_x4_L9_r0_body.cbd39 PRE_first_tail_x4_L9_r0_body.csst39
  exact PRE_first_tail_x4_L9_r0_body.cshift39 bodyNcl39 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_body.n0_39] at this; exact this)


kernel_rfl bodyFramesEmpty39 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_body.s883 a).isEmpty) = true
kernel_rfl bodyJsRoots39 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_body.s882.next) PRE_first_tail_x4_L9_r0_body.s884.trace PRE_first_tail_x4_L9_r0_body.s884 = true
kernel_rfl bodyJsNative39 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_body.s884.ffi) = true
kernel_rfl bodyLow39 : (PRE_first_tail_x4_L9_r0_body.cws39 ++ PRE_first_tail_x4_L9_r0_body.ws39).all (Nat.ble 9) = true
kernel_rfl bodyCntM39 : countersOkB PRE_first_tail_x4_L9_r0_body.s882 PRE_first_tail_x4_L9_r0_body.s883 = true
kernel_rfl bodyHi39 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s884.ffi).next setupP.E = true
kernel_rfl bodyNhi39 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s884.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge39 : bridgeOf PRE_first_tail_x4_L9_r0_body.s883.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s882.ffi
kernel_rfl bodyNN39 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_body.s882.ffi).nnext PRE_first_tail_x4_L9_r0_body.P39.NL = true
kernel_rfl bodyXn39 : Nat.ble (⟨20638, 17732, 2772648, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_body.s884.ffi).next = true
kernel_rfl bodyLo39 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_body.s884.ffi).next = true
theorem bodyFacts39 : BodySiteFacts PRE_first_tail_x4_L9_r0_body.s882 PRE_first_tail_x4_L9_r0_body.s883 PRE_first_tail_x4_L9_r0_body.s884 PRE_first_tail_x4_L9_r0_body.s0 PRE_first_tail_x4_L9_r0_body.S882 PRE_first_tail_x4_L9_r0_body.S883 PRE_first_tail_x4_L9_r0_body.S884
    PRE_first_tail_x4_L9_r0_body.ws39 PRE_first_tail_x4_L9_r0_body.cws39 PRE_first_tail_x4_L9_r0_body.nr39 PRE_first_tail_x4_L9_r0_body.pl39 PRE_first_tail_x4_L9_r0_body.cl39 2772998 15 PRE_first_tail_x4_L9_r0_body.kd39 PRE_first_tail_x4_L9_r0_body.kappa39 PRE_first_tail_x4_L9_r0_body.P39
    ⟨20634, 17726, 2772633, 15⟩ ⟨20638, 17732, 2772648, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_body.zkap39
  clean := bodyClean39
  cfix := PRE_first_tail_x4_L9_r0_body.cfix39
  zpl := PRE_first_tail_x4_L9_r0_body.zpl39
  zplnd := PRE_first_tail_x4_L9_r0_body.zplnd39
  zn1 := PRE_first_tail_x4_L9_r0_body.zn139
  zfirst := PRE_first_tail_x4_L9_r0_body.zfirst39
  zscn := PRE_first_tail_x4_L9_r0_body.zscn39
  zsmn := PRE_first_tail_x4_L9_r0_body.zsmn39
  zgrow := PRE_first_tail_x4_L9_r0_body.zgrow39
  mergeTab := PRE_first_tail_x4_L9_r0_body.mergeTab39
  zfresh := PRE_first_tail_x4_L9_r0_body.zfresh39
  zcnd := PRE_first_tail_x4_L9_r0_body.zcnd39
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_body.znrHi39
  zfrlt := PRE_first_tail_x4_L9_r0_body.zfrlt39
  zgP := PRE_first_tail_x4_L9_r0_body.zg39_2665
  zkP := PRE_first_tail_x4_L9_r0_body.zk39_2665
  zmP := PRE_first_tail_x4_L9_r0_body.zm39_2665
  zgC := PRE_first_tail_x4_L9_r0_body.zg39_2673467
  zkC := PRE_first_tail_x4_L9_r0_body.zk39_2673467
  zmC := PRE_first_tail_x4_L9_r0_body.zm39_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_body.zw39_2673472
  zwV := PRE_first_tail_x4_L9_r0_body.zw39_2673473
  cheap := PRE_first_tail_x4_L9_r0_body.cheap39
  zclbd := PRE_first_tail_x4_L9_r0_body.zclbd39
  hml := hoff_of PRE_first_tail_x4_L9_r0_body.mheap39 PRE_first_tail_x4_L9_r0_body.stFoot39 PRE_first_tail_x4_L9_r0_body.iso39 PRE_first_tail_x4_L9_r0_body.zwr39
  ckeepP := PRE_first_tail_x4_L9_r0_body.ckeepP39
  csupp := PRE_first_tail_x4_L9_r0_body.csupp39
  cbound := PRE_first_tail_x4_L9_r0_body.cbound39
  zimg := PRE_first_tail_x4_L9_r0_body.zimg39
  zctl := PRE_first_tail_x4_L9_r0_body.zctl39
  zstack := PRE_first_tail_x4_L9_r0_body.zstack39
  zjobs := PRE_first_tail_x4_L9_r0_body.zjobs39
  zstores := PRE_first_tail_x4_L9_r0_body.zstores39
  zroots := PRE_first_tail_x4_L9_r0_body.zroots39
  znC := PRE_first_tail_x4_L9_r0_body.znC39
  ctab := PRE_first_tail_x4_L9_r0_body.ctab39
  zbin := PRE_first_tail_x4_L9_r0_body.zbin39
  cbridge := PRE_first_tail_x4_L9_r0_body.cbridge39
  sbridge := bodyBridge39
  cwsDisj := PRE_first_tail_x4_L9_r0_body.cwsDisj39
  cshiftR := fun h hNL => bodyCshift39 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN39
  raised := PRE_first_tail_x4_L9_r0_body.raised39
  cbigs := PRE_first_tail_x4_L9_r0_body.cbigs39
  cjcl := PRE_first_tail_x4_L9_r0_body.cjcl39
  xnLe := Nat.le_of_ble_eq_true bodyXn39
  loLe := Nat.le_of_ble_eq_true bodyLo39
  zroots2 := PRE_first_tail_x4_L9_r0_body.zrootsB39
  cntM := bodyCntM39
  hiLe := Nat.le_of_ble_eq_true bodyHi39
  nhiLe := Nat.le_of_ble_eq_true bodyNhi39
  jsHeap := bodyJs39
  jsRoots := bodyJsRoots39
  jsNative := bodyJsNative39
  framesEmpty := bodyFramesEmpty39
  trailOld := by decide
  lowVars := bodyLow39

def bodyQs39 : List (Option Q) := []
noncomputable def bodyEs39 : List (Option SymE) := PRE_first_tail_x4_L9_r0_body.nr39.map fun r => nth? PRE_first_tail_x4_L9_r0_body.st39.S3.tab r
kernel_rfl bodyResChk39 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs39 bodyQs39) = true
kernel_rfl bodyLq39 : bodyQs39.length = PRE_first_tail_x4_L9_r0_body.cws39.length
kernel_rfl bodyNrLo39 : PRE_first_tail_x4_L9_r0_body.nr39.all (Nat.ble PRE_first_tail_x4_L9_r0_body.S882.tab.length) = true
kernel_rfl bodySub39 : (Oracles.PRE_first_tail_x4_L9_r0_body.map_site39.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost39 : postSubB bodyM PRE_first_tail_x4_L9_r0_body.ws39 PRE_first_tail_x4_L9_r0_body.cws39 bodyQs39 = true
kernel_rfl bodyDrop39 : Nat.ble (41734 + (PRE_first_tail_x4_L9_r0_body.s883.next - PRE_first_tail_x4_L9_r0_body.s884.next)) 42084 = true
kernel_rfl bodyDropH39 : Nat.ble (789 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s883.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_body.s884.ffi).next)) 791 = true
kernel_rfl bodyDropN39 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_body.s883.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_body.s884.ffi).nnext)) 0 = true
kernel_rfl bodyDv39 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_body.cws39
kernel_rfl bodyDe39 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_body.nr39.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_body.st39.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl39 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold39 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_body.cws39).isNone && !PRE_first_tail_x4_L9_r0_body.ws39.contains v) = true
kernel_rfl bodyDfree39 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_body.cws39 ++ PRE_first_tail_x4_L9_r0_body.ws39).all fun w => e.noVar w) = true

theorem bodyStep39 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨41734, 789, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s882 PRE_first_tail_x4_L9_r0_body.S882)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42084, 791, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s884 PRE_first_tail_x4_L9_r0_body.S884) (3452 + 1) :=
  bodySite bodyFacts39.cfix bodyFacts39.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x4_L9_r0_body.st39.S3.tab) (Es := bodyEs39) (qs := bodyQs39)
    (ok := PRE_first_tail_x4_L9_r0_body.st39.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_body.site39 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts39
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_body.chk_site39 r hr) hi (MapOk.sub hm (sub_of_all bodySub39)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk39 r hr) hi hm ho hq)
    bodyLq39 rfl bodyNrLo39 (postSub_sound bodyPost39)
    (Nat.le_of_ble_eq_true bodyDrop39) (by decide) (Nat.le_of_ble_eq_true bodyDropH39) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN39) (by decide)
    bodyDv39 bodyDe39 bodyDl39 bodyDold39 bodyDfree39 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end
