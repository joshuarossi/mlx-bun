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

kernel_rfl bodyO47 : PRE_first_tail_x15_r0_body.S47.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S47.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr47 : bridgeOf PRE_first_tail_x15_r0_body.s47.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc47 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s47 PRE_first_tail_x15_r0_body.S47) = fun _ _ => true
kernel_rfl bodyAcc48 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s48 PRE_first_tail_x15_r0_body.S48) = fun _ _ => true
kernel_rfl bodyBr49 : bridgeOf PRE_first_tail_x15_r0_body.s49.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt48 : isHalt PRE_first_tail_x15_r0_body.s48.ctl = false
kernel_rfl bodyTop49 : noRetBlock PRE_first_tail_x15_r0_body.s49 = true
kernel_rfl bodyCnt47 : countersOkB PRE_first_tail_x15_r0_body.s47 PRE_first_tail_x15_r0_body.s49 = true
kernel_rfl bodyO49 : PRE_first_tail_x15_r0_body.S49.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S49.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr50 : bridgeOf PRE_first_tail_x15_r0_body.s50.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt49 : countersOkB PRE_first_tail_x15_r0_body.s49 PRE_first_tail_x15_r0_body.s50 = true
kernel_rfl bodyO50 : PRE_first_tail_x15_r0_body.S50.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S50.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc50 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s50 PRE_first_tail_x15_r0_body.S50) = fun _ _ => true
kernel_rfl bodyAcc52 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s52 PRE_first_tail_x15_r0_body.S52) = fun _ _ => true
kernel_rfl bodyBr53 : bridgeOf PRE_first_tail_x15_r0_body.s53.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt52 : isHalt PRE_first_tail_x15_r0_body.s52.ctl = false
kernel_rfl bodyTop53 : noRetBlock PRE_first_tail_x15_r0_body.s53 = true
kernel_rfl bodyCnt50 : countersOkB PRE_first_tail_x15_r0_body.s50 PRE_first_tail_x15_r0_body.s53 = true

theorem bodyGlue4 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6433, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s47 PRE_first_tail_x15_r0_body.S47)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6433, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s53 PRE_first_tail_x15_r0_body.S53) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6433, 71, 0, 36⟩) bodyAcc47 PRE_first_tail_x15_r0_body.bodyRunSeg13 bodyAcc48 bodyHalt48 PRE_first_tail_x15_r0_body.bodyStepA14 bodyTop49 (fun _ hm => bodyO47 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr47).trans bodyInactive0) (bodyBr49.trans bodyBr47.symm) bodyCnt47 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6433, 71, 0, 36⟩) PRE_first_tail_x15_r0_body.sizeA14 PRE_first_tail_x15_r0_body.sizeArgsA14 PRE_first_tail_x15_r0_body.sizeSymA14 PRE_first_tail_x15_r0_body.sizeMlxA14 PRE_first_tail_x15_r0_body.sizePayA14 PRE_first_tail_x15_r0_body.sizeTaA14 PRE_first_tail_x15_r0_body.sizeDecA14 PRE_first_tail_x15_r0_body.sizePreA14 PRE_first_tail_x15_r0_body.bodyPatchB14 (fun _ hm => bodyO49 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr49).trans bodyInactive0) (bodyBr50.trans bodyBr49.symm) bodyCnt49 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6433, 71, 0, 36⟩) bodyAcc50 PRE_first_tail_x15_r0_body.bodyRunSeg14 bodyAcc52 bodyHalt52 PRE_first_tail_x15_r0_body.bodyStepA15 bodyTop53 (fun _ hm => bodyO50 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr50).trans bodyInactive0) (bodyBr53.trans bodyBr50.symm) bodyCnt50 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
