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

kernel_rfl bodyO141 : PRE_first_tail_x15_r0_body.S141.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S141.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr141 : bridgeOf PRE_first_tail_x15_r0_body.s141.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc141 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s141 PRE_first_tail_x15_r0_body.S141) = fun _ _ => true
kernel_rfl bodyAcc142 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s142 PRE_first_tail_x15_r0_body.S142) = fun _ _ => true
kernel_rfl bodyBr143 : bridgeOf PRE_first_tail_x15_r0_body.s143.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt142 : isHalt PRE_first_tail_x15_r0_body.s142.ctl = false
kernel_rfl bodyTop143 : noRetBlock PRE_first_tail_x15_r0_body.s143 = true
kernel_rfl bodyCnt141 : countersOkB PRE_first_tail_x15_r0_body.s141 PRE_first_tail_x15_r0_body.s143 = true

theorem bodyGlue14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9119, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s141 PRE_first_tail_x15_r0_body.S141)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9119, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s143 PRE_first_tail_x15_r0_body.S143) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9119, 123, 0, 81⟩) bodyAcc141 PRE_first_tail_x15_r0_body.bodyRunSeg38 bodyAcc142 bodyHalt142 PRE_first_tail_x15_r0_body.bodyStepA39 bodyTop143 (fun _ hm => bodyO141 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr141).trans bodyInactive0) (bodyBr143.trans bodyBr141.symm) bodyCnt141 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
