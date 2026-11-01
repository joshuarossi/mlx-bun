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

kernel_rfl bodyO519 : PRE_first_tail_x15_r0_body.S519.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S519.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr519 : bridgeOf PRE_first_tail_x15_r0_body.s519.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc519 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.S519) = fun _ _ => true
kernel_rfl bodyAcc521 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s521 PRE_first_tail_x15_r0_body.S521) = fun _ _ => true
kernel_rfl bodyBr522 : bridgeOf PRE_first_tail_x15_r0_body.s522.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt521 : isHalt PRE_first_tail_x15_r0_body.s521.ctl = false
kernel_rfl bodyTop522 : noRetBlock PRE_first_tail_x15_r0_body.s522 = true
kernel_rfl bodyCnt519 : countersOkB PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.s522 = true
kernel_rfl bodyO522 : PRE_first_tail_x15_r0_body.S522.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S522.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr523 : bridgeOf PRE_first_tail_x15_r0_body.s523.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt522 : countersOkB PRE_first_tail_x15_r0_body.s522 PRE_first_tail_x15_r0_body.s523 = true
kernel_rfl bodyO523 : PRE_first_tail_x15_r0_body.S523.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S523.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc523 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s523 PRE_first_tail_x15_r0_body.S523) = fun _ _ => true
kernel_rfl bodyAcc524 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s524 PRE_first_tail_x15_r0_body.S524) = fun _ _ => true
kernel_rfl bodyBr525 : bridgeOf PRE_first_tail_x15_r0_body.s525.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt524 : isHalt PRE_first_tail_x15_r0_body.s524.ctl = false
kernel_rfl bodyTop525 : noRetBlock PRE_first_tail_x15_r0_body.s525 = true
kernel_rfl bodyCnt523 : countersOkB PRE_first_tail_x15_r0_body.s523 PRE_first_tail_x15_r0_body.s525 = true
kernel_rfl bodyO525 : PRE_first_tail_x15_r0_body.S525.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S525.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr526 : bridgeOf PRE_first_tail_x15_r0_body.s526.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt525 : countersOkB PRE_first_tail_x15_r0_body.s525 PRE_first_tail_x15_r0_body.s526 = true
kernel_rfl bodyO526 : PRE_first_tail_x15_r0_body.S526.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S526.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc526 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s526 PRE_first_tail_x15_r0_body.S526) = fun _ _ => true
kernel_rfl bodyAcc527 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s527 PRE_first_tail_x15_r0_body.S527) = fun _ _ => true
kernel_rfl bodyBr528 : bridgeOf PRE_first_tail_x15_r0_body.s528.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt527 : isHalt PRE_first_tail_x15_r0_body.s527.ctl = false
kernel_rfl bodyTop528 : noRetBlock PRE_first_tail_x15_r0_body.s528 = true
kernel_rfl bodyCnt526 : countersOkB PRE_first_tail_x15_r0_body.s526 PRE_first_tail_x15_r0_body.s528 = true
kernel_rfl bodyO528 : PRE_first_tail_x15_r0_body.S528.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S528.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr529 : bridgeOf PRE_first_tail_x15_r0_body.s529.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt528 : countersOkB PRE_first_tail_x15_r0_body.s528 PRE_first_tail_x15_r0_body.s529 = true
kernel_rfl bodyO529 : PRE_first_tail_x15_r0_body.S529.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S529.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc529 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s529 PRE_first_tail_x15_r0_body.S529) = fun _ _ => true
kernel_rfl bodyAcc530 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s530 PRE_first_tail_x15_r0_body.S530) = fun _ _ => true
kernel_rfl bodyBr531 : bridgeOf PRE_first_tail_x15_r0_body.s531.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt530 : isHalt PRE_first_tail_x15_r0_body.s530.ctl = false
kernel_rfl bodyTop531 : noRetBlock PRE_first_tail_x15_r0_body.s531 = true
kernel_rfl bodyCnt529 : countersOkB PRE_first_tail_x15_r0_body.s529 PRE_first_tail_x15_r0_body.s531 = true
kernel_rfl bodyO531 : PRE_first_tail_x15_r0_body.S531.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S531.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr532 : bridgeOf PRE_first_tail_x15_r0_body.s532.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt531 : countersOkB PRE_first_tail_x15_r0_body.s531 PRE_first_tail_x15_r0_body.s532 = true
kernel_rfl bodyO532 : PRE_first_tail_x15_r0_body.S532.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S532.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc532 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s532 PRE_first_tail_x15_r0_body.S532) = fun _ _ => true
kernel_rfl bodyAcc533 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s533 PRE_first_tail_x15_r0_body.S533) = fun _ _ => true
kernel_rfl bodyBr534 : bridgeOf PRE_first_tail_x15_r0_body.s534.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt533 : isHalt PRE_first_tail_x15_r0_body.s533.ctl = false
kernel_rfl bodyTop534 : noRetBlock PRE_first_tail_x15_r0_body.s534 = true
kernel_rfl bodyCnt532 : countersOkB PRE_first_tail_x15_r0_body.s532 PRE_first_tail_x15_r0_body.s534 = true

theorem bodyGlue54 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21870, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.S519)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21870, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.S534) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc519 PRE_first_tail_x15_r0_body.bodyRunSeg140 bodyAcc521 bodyHalt521 PRE_first_tail_x15_r0_body.bodyStepA141 bodyTop522 (fun _ hm => bodyO519 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr519).trans bodyInactive0) (bodyBr522.trans bodyBr519.symm) bodyCnt519 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA141 PRE_first_tail_x15_r0_body.sizeArgsA141 PRE_first_tail_x15_r0_body.sizeSymA141 PRE_first_tail_x15_r0_body.sizeMlxA141 PRE_first_tail_x15_r0_body.sizePayA141 PRE_first_tail_x15_r0_body.sizeTaA141 PRE_first_tail_x15_r0_body.sizeDecA141 PRE_first_tail_x15_r0_body.sizePreA141 PRE_first_tail_x15_r0_body.bodyPatchB141 (fun _ hm => bodyO522 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr522).trans bodyInactive0) (bodyBr523.trans bodyBr522.symm) bodyCnt522 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc523 PRE_first_tail_x15_r0_body.bodyRunSeg141 bodyAcc524 bodyHalt524 PRE_first_tail_x15_r0_body.bodyStepA142 bodyTop525 (fun _ hm => bodyO523 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr523).trans bodyInactive0) (bodyBr525.trans bodyBr523.symm) bodyCnt523 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA142 PRE_first_tail_x15_r0_body.sizeArgsA142 PRE_first_tail_x15_r0_body.sizeSymA142 PRE_first_tail_x15_r0_body.sizeMlxA142 PRE_first_tail_x15_r0_body.sizePayA142 PRE_first_tail_x15_r0_body.sizeTaA142 PRE_first_tail_x15_r0_body.sizeDecA142 PRE_first_tail_x15_r0_body.sizePreA142 PRE_first_tail_x15_r0_body.bodyPatchB142 (fun _ hm => bodyO525 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr525).trans bodyInactive0) (bodyBr526.trans bodyBr525.symm) bodyCnt525 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc526 PRE_first_tail_x15_r0_body.bodyRunSeg142 bodyAcc527 bodyHalt527 PRE_first_tail_x15_r0_body.bodyStepA143 bodyTop528 (fun _ hm => bodyO526 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr526).trans bodyInactive0) (bodyBr528.trans bodyBr526.symm) bodyCnt526 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA143 PRE_first_tail_x15_r0_body.sizeArgsA143 PRE_first_tail_x15_r0_body.sizeSymA143 PRE_first_tail_x15_r0_body.sizeMlxA143 PRE_first_tail_x15_r0_body.sizePayA143 PRE_first_tail_x15_r0_body.sizeTaA143 PRE_first_tail_x15_r0_body.sizeDecA143 PRE_first_tail_x15_r0_body.sizePreA143 PRE_first_tail_x15_r0_body.bodyPatchB143 (fun _ hm => bodyO528 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr528).trans bodyInactive0) (bodyBr529.trans bodyBr528.symm) bodyCnt528 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc529 PRE_first_tail_x15_r0_body.bodyRunSeg143 bodyAcc530 bodyHalt530 PRE_first_tail_x15_r0_body.bodyStepA144 bodyTop531 (fun _ hm => bodyO529 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr529).trans bodyInactive0) (bodyBr531.trans bodyBr529.symm) bodyCnt529 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA144 PRE_first_tail_x15_r0_body.sizeArgsA144 PRE_first_tail_x15_r0_body.sizeSymA144 PRE_first_tail_x15_r0_body.sizeMlxA144 PRE_first_tail_x15_r0_body.sizePayA144 PRE_first_tail_x15_r0_body.sizeTaA144 PRE_first_tail_x15_r0_body.sizeDecA144 PRE_first_tail_x15_r0_body.sizePreA144 PRE_first_tail_x15_r0_body.bodyPatchB144 (fun _ hm => bodyO531 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr531).trans bodyInactive0) (bodyBr532.trans bodyBr531.symm) bodyCnt531 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21870, 379, 0, 288⟩) bodyAcc532 PRE_first_tail_x15_r0_body.bodyRunSeg144 bodyAcc533 bodyHalt533 PRE_first_tail_x15_r0_body.bodyStepA145 bodyTop534 (fun _ hm => bodyO532 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr532).trans bodyInactive0) (bodyBr534.trans bodyBr532.symm) bodyCnt532 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
