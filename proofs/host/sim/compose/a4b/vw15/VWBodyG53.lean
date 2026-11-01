import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw15.VWBodyChain
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO515 : PRE_first_tail_x15_r0_body.S515.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S515.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr515 : bridgeOf PRE_first_tail_x15_r0_body.s515.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc515 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.S515) = fun _ _ => true
kernel_rfl bodyAcc516 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s516 PRE_first_tail_x15_r0_body.S516) = fun _ _ => true
kernel_rfl bodyBr517 : bridgeOf PRE_first_tail_x15_r0_body.s517.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt516 : isHalt PRE_first_tail_x15_r0_body.s516.ctl = false
kernel_rfl bodyTop517 : noRetBlock PRE_first_tail_x15_r0_body.s517 = true
kernel_rfl bodyCnt515 : countersOkB PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.s517 = true

theorem bodyGlue53 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21851, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.S515)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21851, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.S517) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21851, 379, 0, 288⟩) bodyAcc515 PRE_first_tail_x15_r0_body.bodyRunSeg139 bodyAcc516 bodyHalt516 PRE_first_tail_x15_r0_body.bodyStepA140 bodyTop517 (fun _ hm => bodyO515 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr515).trans bodyInactive0) (bodyBr517.trans bodyBr515.symm) bodyCnt515 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
