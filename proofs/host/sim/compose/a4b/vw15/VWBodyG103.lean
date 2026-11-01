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

kernel_rfl bodyO996 : PRE_first_tail_x15_r0_body.S996.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S996.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr996 : bridgeOf PRE_first_tail_x15_r0_body.s996.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc996 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.S996) = fun _ _ => true
kernel_rfl bodyAcc997 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s997 PRE_first_tail_x15_r0_body.S997) = fun _ _ => true
kernel_rfl bodyBr998 : bridgeOf PRE_first_tail_x15_r0_body.s998.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt997 : isHalt PRE_first_tail_x15_r0_body.s997.ctl = false
kernel_rfl bodyTop998 : noRetBlock PRE_first_tail_x15_r0_body.s998 = true
kernel_rfl bodyCnt996 : countersOkB PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.s998 = true
kernel_rfl bodyO998 : PRE_first_tail_x15_r0_body.S998.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S998.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr999 : bridgeOf PRE_first_tail_x15_r0_body.s999.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt998 : countersOkB PRE_first_tail_x15_r0_body.s998 PRE_first_tail_x15_r0_body.s999 = true
kernel_rfl bodyO999 : PRE_first_tail_x15_r0_body.S999.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S999.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc999 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s999 PRE_first_tail_x15_r0_body.S999) = fun _ _ => true
kernel_rfl bodyAcc1001 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1001 PRE_first_tail_x15_r0_body.S1001) = fun _ _ => true
kernel_rfl bodyBr1002 : bridgeOf PRE_first_tail_x15_r0_body.s1002.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1001 : isHalt PRE_first_tail_x15_r0_body.s1001.ctl = false
kernel_rfl bodyTop1002 : noRetBlock PRE_first_tail_x15_r0_body.s1002 = true
kernel_rfl bodyCnt999 : countersOkB PRE_first_tail_x15_r0_body.s999 PRE_first_tail_x15_r0_body.s1002 = true

theorem bodyGlue103 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38444, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.S996)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38444, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1002 PRE_first_tail_x15_r0_body.S1002) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38444, 712, 0, 558⟩) bodyAcc996 PRE_first_tail_x15_r0_body.bodyRunSeg269 bodyAcc997 bodyHalt997 PRE_first_tail_x15_r0_body.bodyStepA270 bodyTop998 (fun _ hm => bodyO996 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr996).trans bodyInactive0) (bodyBr998.trans bodyBr996.symm) bodyCnt996 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38444, 712, 0, 558⟩) PRE_first_tail_x15_r0_body.sizeA270 PRE_first_tail_x15_r0_body.sizeArgsA270 PRE_first_tail_x15_r0_body.sizeSymA270 PRE_first_tail_x15_r0_body.sizeMlxA270 PRE_first_tail_x15_r0_body.sizePayA270 PRE_first_tail_x15_r0_body.sizeTaA270 PRE_first_tail_x15_r0_body.sizeDecA270 PRE_first_tail_x15_r0_body.sizePreA270 PRE_first_tail_x15_r0_body.bodyPatchB270 (fun _ hm => bodyO998 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr998).trans bodyInactive0) (bodyBr999.trans bodyBr998.symm) bodyCnt998 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38444, 712, 0, 558⟩) bodyAcc999 PRE_first_tail_x15_r0_body.bodyRunSeg270 bodyAcc1001 bodyHalt1001 PRE_first_tail_x15_r0_body.bodyStepA271 bodyTop1002 (fun _ hm => bodyO999 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr999).trans bodyInactive0) (bodyBr1002.trans bodyBr999.symm) bodyCnt999 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
