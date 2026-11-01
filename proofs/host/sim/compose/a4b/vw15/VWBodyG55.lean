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

kernel_rfl bodyO536 : PRE_first_tail_x15_r0_body.S536.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S536.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr536 : bridgeOf PRE_first_tail_x15_r0_body.s536.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc536 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.S536) = fun _ _ => true
kernel_rfl bodyAcc537 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s537 PRE_first_tail_x15_r0_body.S537) = fun _ _ => true
kernel_rfl bodyBr538 : bridgeOf PRE_first_tail_x15_r0_body.s538.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt537 : isHalt PRE_first_tail_x15_r0_body.s537.ctl = false
kernel_rfl bodyTop538 : noRetBlock PRE_first_tail_x15_r0_body.s538 = true
kernel_rfl bodyCnt536 : countersOkB PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.s538 = true
kernel_rfl bodyO538 : PRE_first_tail_x15_r0_body.S538.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S538.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr539 : bridgeOf PRE_first_tail_x15_r0_body.s539.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt538 : countersOkB PRE_first_tail_x15_r0_body.s538 PRE_first_tail_x15_r0_body.s539 = true
kernel_rfl bodyO539 : PRE_first_tail_x15_r0_body.S539.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S539.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc539 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s539 PRE_first_tail_x15_r0_body.S539) = fun _ _ => true
kernel_rfl bodyAcc541 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s541 PRE_first_tail_x15_r0_body.S541) = fun _ _ => true
kernel_rfl bodyBr542 : bridgeOf PRE_first_tail_x15_r0_body.s542.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt541 : isHalt PRE_first_tail_x15_r0_body.s541.ctl = false
kernel_rfl bodyTop542 : noRetBlock PRE_first_tail_x15_r0_body.s542 = true
kernel_rfl bodyCnt539 : countersOkB PRE_first_tail_x15_r0_body.s539 PRE_first_tail_x15_r0_body.s542 = true

theorem bodyGlue55 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23019, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.S536)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23019, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.S542) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23019, 404, 0, 306⟩) bodyAcc536 PRE_first_tail_x15_r0_body.bodyRunSeg145 bodyAcc537 bodyHalt537 PRE_first_tail_x15_r0_body.bodyStepA146 bodyTop538 (fun _ hm => bodyO536 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr536).trans bodyInactive0) (bodyBr538.trans bodyBr536.symm) bodyCnt536 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23019, 404, 0, 306⟩) PRE_first_tail_x15_r0_body.sizeA146 PRE_first_tail_x15_r0_body.sizeArgsA146 PRE_first_tail_x15_r0_body.sizeSymA146 PRE_first_tail_x15_r0_body.sizeMlxA146 PRE_first_tail_x15_r0_body.sizePayA146 PRE_first_tail_x15_r0_body.sizeTaA146 PRE_first_tail_x15_r0_body.sizeDecA146 PRE_first_tail_x15_r0_body.sizePreA146 PRE_first_tail_x15_r0_body.bodyPatchB146 (fun _ hm => bodyO538 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr538).trans bodyInactive0) (bodyBr539.trans bodyBr538.symm) bodyCnt538 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23019, 404, 0, 306⟩) bodyAcc539 PRE_first_tail_x15_r0_body.bodyRunSeg146 bodyAcc541 bodyHalt541 PRE_first_tail_x15_r0_body.bodyStepA147 bodyTop542 (fun _ hm => bodyO539 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr539).trans bodyInactive0) (bodyBr542.trans bodyBr539.symm) bodyCnt539 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
