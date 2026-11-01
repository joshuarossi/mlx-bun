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

kernel_rfl bodyO104 : PRE_first_tail_x15_r0_body.S104.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S104.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr104 : bridgeOf PRE_first_tail_x15_r0_body.s104.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc104 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.S104) = fun _ _ => true
kernel_rfl bodyAcc105 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s105 PRE_first_tail_x15_r0_body.S105) = fun _ _ => true
kernel_rfl bodyBr106 : bridgeOf PRE_first_tail_x15_r0_body.s106.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt105 : isHalt PRE_first_tail_x15_r0_body.s105.ctl = false
kernel_rfl bodyTop106 : noRetBlock PRE_first_tail_x15_r0_body.s106 = true
kernel_rfl bodyCnt104 : countersOkB PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.s106 = true
kernel_rfl bodyO106 : PRE_first_tail_x15_r0_body.S106.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S106.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr107 : bridgeOf PRE_first_tail_x15_r0_body.s107.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt106 : countersOkB PRE_first_tail_x15_r0_body.s106 PRE_first_tail_x15_r0_body.s107 = true
kernel_rfl bodyO107 : PRE_first_tail_x15_r0_body.S107.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S107.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc107 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s107 PRE_first_tail_x15_r0_body.S107) = fun _ _ => true
kernel_rfl bodyAcc109 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s109 PRE_first_tail_x15_r0_body.S109) = fun _ _ => true
kernel_rfl bodyBr110 : bridgeOf PRE_first_tail_x15_r0_body.s110.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt109 : isHalt PRE_first_tail_x15_r0_body.s109.ctl = false
kernel_rfl bodyTop110 : noRetBlock PRE_first_tail_x15_r0_body.s110 = true
kernel_rfl bodyCnt107 : countersOkB PRE_first_tail_x15_r0_body.s107 PRE_first_tail_x15_r0_body.s110 = true

theorem bodyGlue10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7956, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.S104)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7956, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s110 PRE_first_tail_x15_r0_body.S110) 5813 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7956, 98, 0, 63⟩) bodyAcc104 PRE_first_tail_x15_r0_body.bodyRunSeg28 bodyAcc105 bodyHalt105 PRE_first_tail_x15_r0_body.bodyStepA29 bodyTop106 (fun _ hm => bodyO104 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr104).trans bodyInactive0) (bodyBr106.trans bodyBr104.symm) bodyCnt104 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7956, 98, 0, 63⟩) PRE_first_tail_x15_r0_body.sizeA29 PRE_first_tail_x15_r0_body.sizeArgsA29 PRE_first_tail_x15_r0_body.sizeSymA29 PRE_first_tail_x15_r0_body.sizeMlxA29 PRE_first_tail_x15_r0_body.sizePayA29 PRE_first_tail_x15_r0_body.sizeTaA29 PRE_first_tail_x15_r0_body.sizeDecA29 PRE_first_tail_x15_r0_body.sizePreA29 PRE_first_tail_x15_r0_body.bodyPatchB29 (fun _ hm => bodyO106 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr106).trans bodyInactive0) (bodyBr107.trans bodyBr106.symm) bodyCnt106 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7956, 98, 0, 63⟩) bodyAcc107 PRE_first_tail_x15_r0_body.bodyRunSeg29 bodyAcc109 bodyHalt109 PRE_first_tail_x15_r0_body.bodyStepA30 bodyTop110 (fun _ hm => bodyO107 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr107).trans bodyInactive0) (bodyBr110.trans bodyBr107.symm) bodyCnt107 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
