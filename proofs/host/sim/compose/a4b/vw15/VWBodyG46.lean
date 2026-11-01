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

kernel_rfl bodyO449 : PRE_first_tail_x15_r0_body.S449.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S449.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr449 : bridgeOf PRE_first_tail_x15_r0_body.s449.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc449 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.S449) = fun _ _ => true
kernel_rfl bodyAcc450 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s450 PRE_first_tail_x15_r0_body.S450) = fun _ _ => true
kernel_rfl bodyBr451 : bridgeOf PRE_first_tail_x15_r0_body.s451.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt450 : isHalt PRE_first_tail_x15_r0_body.s450.ctl = false
kernel_rfl bodyTop451 : noRetBlock PRE_first_tail_x15_r0_body.s451 = true
kernel_rfl bodyCnt449 : countersOkB PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.s451 = true
kernel_rfl bodyO451 : PRE_first_tail_x15_r0_body.S451.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S451.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr452 : bridgeOf PRE_first_tail_x15_r0_body.s452.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt451 : countersOkB PRE_first_tail_x15_r0_body.s451 PRE_first_tail_x15_r0_body.s452 = true
kernel_rfl bodyO452 : PRE_first_tail_x15_r0_body.S452.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S452.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc452 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s452 PRE_first_tail_x15_r0_body.S452) = fun _ _ => true
kernel_rfl bodyAcc454 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s454 PRE_first_tail_x15_r0_body.S454) = fun _ _ => true
kernel_rfl bodyBr455 : bridgeOf PRE_first_tail_x15_r0_body.s455.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt454 : isHalt PRE_first_tail_x15_r0_body.s454.ctl = false
kernel_rfl bodyTop455 : noRetBlock PRE_first_tail_x15_r0_body.s455 = true
kernel_rfl bodyCnt452 : countersOkB PRE_first_tail_x15_r0_body.s452 PRE_first_tail_x15_r0_body.s455 = true

theorem bodyGlue46 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19509, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.S449)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19509, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.S455) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19509, 329, 0, 252⟩) bodyAcc449 PRE_first_tail_x15_r0_body.bodyRunSeg121 bodyAcc450 bodyHalt450 PRE_first_tail_x15_r0_body.bodyStepA122 bodyTop451 (fun _ hm => bodyO449 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr449).trans bodyInactive0) (bodyBr451.trans bodyBr449.symm) bodyCnt449 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19509, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA122 PRE_first_tail_x15_r0_body.sizeArgsA122 PRE_first_tail_x15_r0_body.sizeSymA122 PRE_first_tail_x15_r0_body.sizeMlxA122 PRE_first_tail_x15_r0_body.sizePayA122 PRE_first_tail_x15_r0_body.sizeTaA122 PRE_first_tail_x15_r0_body.sizeDecA122 PRE_first_tail_x15_r0_body.sizePreA122 PRE_first_tail_x15_r0_body.bodyPatchB122 (fun _ hm => bodyO451 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr451).trans bodyInactive0) (bodyBr452.trans bodyBr451.symm) bodyCnt451 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19509, 329, 0, 252⟩) bodyAcc452 PRE_first_tail_x15_r0_body.bodyRunSeg122 bodyAcc454 bodyHalt454 PRE_first_tail_x15_r0_body.bodyStepA123 bodyTop455 (fun _ hm => bodyO452 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr452).trans bodyInactive0) (bodyBr455.trans bodyBr452.symm) bodyCnt452 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
