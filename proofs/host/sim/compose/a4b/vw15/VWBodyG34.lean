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

kernel_rfl bodyO334 : PRE_first_tail_x15_r0_body.S334.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S334.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr334 : bridgeOf PRE_first_tail_x15_r0_body.s334.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc334 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s334 PRE_first_tail_x15_r0_body.S334) = fun _ _ => true
kernel_rfl bodyAcc335 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s335 PRE_first_tail_x15_r0_body.S335) = fun _ _ => true
kernel_rfl bodyBr336 : bridgeOf PRE_first_tail_x15_r0_body.s336.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt335 : isHalt PRE_first_tail_x15_r0_body.s335.ctl = false
kernel_rfl bodyTop336 : noRetBlock PRE_first_tail_x15_r0_body.s336 = true
kernel_rfl bodyCnt334 : countersOkB PRE_first_tail_x15_r0_body.s334 PRE_first_tail_x15_r0_body.s336 = true
kernel_rfl bodyO336 : PRE_first_tail_x15_r0_body.S336.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S336.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr337 : bridgeOf PRE_first_tail_x15_r0_body.s337.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt336 : countersOkB PRE_first_tail_x15_r0_body.s336 PRE_first_tail_x15_r0_body.s337 = true
kernel_rfl bodyO337 : PRE_first_tail_x15_r0_body.S337.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S337.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc337 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s337 PRE_first_tail_x15_r0_body.S337) = fun _ _ => true
kernel_rfl bodyAcc339 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s339 PRE_first_tail_x15_r0_body.S339) = fun _ _ => true
kernel_rfl bodyBr340 : bridgeOf PRE_first_tail_x15_r0_body.s340.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt339 : isHalt PRE_first_tail_x15_r0_body.s339.ctl = false
kernel_rfl bodyTop340 : noRetBlock PRE_first_tail_x15_r0_body.s340 = true
kernel_rfl bodyCnt337 : countersOkB PRE_first_tail_x15_r0_body.s337 PRE_first_tail_x15_r0_body.s340 = true

theorem bodyGlue34 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15646, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s334 PRE_first_tail_x15_r0_body.S334)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15646, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s340 PRE_first_tail_x15_r0_body.S340) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15646, 252, 0, 189⟩) bodyAcc334 PRE_first_tail_x15_r0_body.bodyRunSeg90 bodyAcc335 bodyHalt335 PRE_first_tail_x15_r0_body.bodyStepA91 bodyTop336 (fun _ hm => bodyO334 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr334).trans bodyInactive0) (bodyBr336.trans bodyBr334.symm) bodyCnt334 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15646, 252, 0, 189⟩) PRE_first_tail_x15_r0_body.sizeA91 PRE_first_tail_x15_r0_body.sizeArgsA91 PRE_first_tail_x15_r0_body.sizeSymA91 PRE_first_tail_x15_r0_body.sizeMlxA91 PRE_first_tail_x15_r0_body.sizePayA91 PRE_first_tail_x15_r0_body.sizeTaA91 PRE_first_tail_x15_r0_body.sizeDecA91 PRE_first_tail_x15_r0_body.sizePreA91 PRE_first_tail_x15_r0_body.bodyPatchB91 (fun _ hm => bodyO336 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr336).trans bodyInactive0) (bodyBr337.trans bodyBr336.symm) bodyCnt336 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15646, 252, 0, 189⟩) bodyAcc337 PRE_first_tail_x15_r0_body.bodyRunSeg91 bodyAcc339 bodyHalt339 PRE_first_tail_x15_r0_body.bodyStepA92 bodyTop340 (fun _ hm => bodyO337 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr337).trans bodyInactive0) (bodyBr340.trans bodyBr337.symm) bodyCnt337 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
