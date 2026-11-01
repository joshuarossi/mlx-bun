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

kernel_rfl bodyO716 : PRE_first_tail_x15_r0_body.S716.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S716.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr716 : bridgeOf PRE_first_tail_x15_r0_body.s716.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc716 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.S716) = fun _ _ => true
kernel_rfl bodyAcc717 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s717 PRE_first_tail_x15_r0_body.S717) = fun _ _ => true
kernel_rfl bodyBr718 : bridgeOf PRE_first_tail_x15_r0_body.s718.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt717 : isHalt PRE_first_tail_x15_r0_body.s717.ctl = false
kernel_rfl bodyTop718 : noRetBlock PRE_first_tail_x15_r0_body.s718 = true
kernel_rfl bodyCnt716 : countersOkB PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.s718 = true

theorem bodyGlue74 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨28398, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.S716)
      (bodyCut NB T tk π i x0 bodyΘ ⟨28398, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s718 PRE_first_tail_x15_r0_body.S718) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28398, 508, 0, 396⟩) bodyAcc716 PRE_first_tail_x15_r0_body.bodyRunSeg193 bodyAcc717 bodyHalt717 PRE_first_tail_x15_r0_body.bodyStepA194 bodyTop718 (fun _ hm => bodyO716 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr716).trans bodyInactive0) (bodyBr718.trans bodyBr716.symm) bodyCnt716 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
