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

kernel_rfl bodyO622 : PRE_first_tail_x15_r0_body.S622.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S622.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr622 : bridgeOf PRE_first_tail_x15_r0_body.s622.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc622 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.S622) = fun _ _ => true
kernel_rfl bodyAcc623 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s623 PRE_first_tail_x15_r0_body.S623) = fun _ _ => true
kernel_rfl bodyBr624 : bridgeOf PRE_first_tail_x15_r0_body.s624.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt623 : isHalt PRE_first_tail_x15_r0_body.s623.ctl = false
kernel_rfl bodyTop624 : noRetBlock PRE_first_tail_x15_r0_body.s624 = true
kernel_rfl bodyCnt622 : countersOkB PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.s624 = true
kernel_rfl bodyO624 : PRE_first_tail_x15_r0_body.S624.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S624.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr625 : bridgeOf PRE_first_tail_x15_r0_body.s625.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt624 : countersOkB PRE_first_tail_x15_r0_body.s624 PRE_first_tail_x15_r0_body.s625 = true
kernel_rfl bodyO625 : PRE_first_tail_x15_r0_body.S625.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S625.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc625 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s625 PRE_first_tail_x15_r0_body.S625) = fun _ _ => true
kernel_rfl bodyAcc627 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s627 PRE_first_tail_x15_r0_body.S627) = fun _ _ => true
kernel_rfl bodyBr628 : bridgeOf PRE_first_tail_x15_r0_body.s628.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt627 : isHalt PRE_first_tail_x15_r0_body.s627.ctl = false
kernel_rfl bodyTop628 : noRetBlock PRE_first_tail_x15_r0_body.s628 = true
kernel_rfl bodyCnt625 : countersOkB PRE_first_tail_x15_r0_body.s625 PRE_first_tail_x15_r0_body.s628 = true

theorem bodyGlue64 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨25712, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.S622)
      (bodyCut NB T tk π i x0 bodyΘ ⟨25712, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s628 PRE_first_tail_x15_r0_body.S628) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25712, 456, 0, 351⟩) bodyAcc622 PRE_first_tail_x15_r0_body.bodyRunSeg168 bodyAcc623 bodyHalt623 PRE_first_tail_x15_r0_body.bodyStepA169 bodyTop624 (fun _ hm => bodyO622 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr622).trans bodyInactive0) (bodyBr624.trans bodyBr622.symm) bodyCnt622 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25712, 456, 0, 351⟩) PRE_first_tail_x15_r0_body.sizeA169 PRE_first_tail_x15_r0_body.sizeArgsA169 PRE_first_tail_x15_r0_body.sizeSymA169 PRE_first_tail_x15_r0_body.sizeMlxA169 PRE_first_tail_x15_r0_body.sizePayA169 PRE_first_tail_x15_r0_body.sizeTaA169 PRE_first_tail_x15_r0_body.sizeDecA169 PRE_first_tail_x15_r0_body.sizePreA169 PRE_first_tail_x15_r0_body.bodyPatchB169 (fun _ hm => bodyO624 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr624).trans bodyInactive0) (bodyBr625.trans bodyBr624.symm) bodyCnt624 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25712, 456, 0, 351⟩) bodyAcc625 PRE_first_tail_x15_r0_body.bodyRunSeg169 bodyAcc627 bodyHalt627 PRE_first_tail_x15_r0_body.bodyStepA170 bodyTop628 (fun _ hm => bodyO625 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr625).trans bodyInactive0) (bodyBr628.trans bodyBr625.symm) bodyCnt625 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
