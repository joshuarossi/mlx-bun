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

kernel_rfl bodyO651 : PRE_first_tail_x15_r0_body.S651.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S651.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr651 : bridgeOf PRE_first_tail_x15_r0_body.s651.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc651 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.S651) = fun _ _ => true
kernel_rfl bodyAcc652 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s652 PRE_first_tail_x15_r0_body.S652) = fun _ _ => true
kernel_rfl bodyBr653 : bridgeOf PRE_first_tail_x15_r0_body.s653.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt652 : isHalt PRE_first_tail_x15_r0_body.s652.ctl = false
kernel_rfl bodyTop653 : noRetBlock PRE_first_tail_x15_r0_body.s653 = true
kernel_rfl bodyCnt651 : countersOkB PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.s653 = true
kernel_rfl bodyO653 : PRE_first_tail_x15_r0_body.S653.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S653.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr654 : bridgeOf PRE_first_tail_x15_r0_body.s654.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt653 : countersOkB PRE_first_tail_x15_r0_body.s653 PRE_first_tail_x15_r0_body.s654 = true
kernel_rfl bodyO654 : PRE_first_tail_x15_r0_body.S654.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S654.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc654 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s654 PRE_first_tail_x15_r0_body.S654) = fun _ _ => true
kernel_rfl bodyAcc656 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s656 PRE_first_tail_x15_r0_body.S656) = fun _ _ => true
kernel_rfl bodyBr657 : bridgeOf PRE_first_tail_x15_r0_body.s657.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt656 : isHalt PRE_first_tail_x15_r0_body.s656.ctl = false
kernel_rfl bodyTop657 : noRetBlock PRE_first_tail_x15_r0_body.s657 = true
kernel_rfl bodyCnt654 : countersOkB PRE_first_tail_x15_r0_body.s654 PRE_first_tail_x15_r0_body.s657 = true

theorem bodyGlue67 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26873, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.S651)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26873, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.S657) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26873, 481, 0, 369⟩) bodyAcc651 PRE_first_tail_x15_r0_body.bodyRunSeg176 bodyAcc652 bodyHalt652 PRE_first_tail_x15_r0_body.bodyStepA177 bodyTop653 (fun _ hm => bodyO651 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr651).trans bodyInactive0) (bodyBr653.trans bodyBr651.symm) bodyCnt651 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26873, 481, 0, 369⟩) PRE_first_tail_x15_r0_body.sizeA177 PRE_first_tail_x15_r0_body.sizeArgsA177 PRE_first_tail_x15_r0_body.sizeSymA177 PRE_first_tail_x15_r0_body.sizeMlxA177 PRE_first_tail_x15_r0_body.sizePayA177 PRE_first_tail_x15_r0_body.sizeTaA177 PRE_first_tail_x15_r0_body.sizeDecA177 PRE_first_tail_x15_r0_body.sizePreA177 PRE_first_tail_x15_r0_body.bodyPatchB177 (fun _ hm => bodyO653 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr653).trans bodyInactive0) (bodyBr654.trans bodyBr653.symm) bodyCnt653 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26873, 481, 0, 369⟩) bodyAcc654 PRE_first_tail_x15_r0_body.bodyRunSeg177 bodyAcc656 bodyHalt656 PRE_first_tail_x15_r0_body.bodyStepA178 bodyTop657 (fun _ hm => bodyO654 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr654).trans bodyInactive0) (bodyBr657.trans bodyBr654.symm) bodyCnt654 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
