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

kernel_rfl bodyO76 : PRE_first_tail_x15_r0_body.S76.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S76.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr76 : bridgeOf PRE_first_tail_x15_r0_body.s76.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc76 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.S76) = fun _ _ => true
kernel_rfl bodyAcc77 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s77 PRE_first_tail_x15_r0_body.S77) = fun _ _ => true
kernel_rfl bodyBr78 : bridgeOf PRE_first_tail_x15_r0_body.s78.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt77 : isHalt PRE_first_tail_x15_r0_body.s77.ctl = false
kernel_rfl bodyTop78 : noRetBlock PRE_first_tail_x15_r0_body.s78 = true
kernel_rfl bodyCnt76 : countersOkB PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.s78 = true
kernel_rfl bodyO78 : PRE_first_tail_x15_r0_body.S78.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S78.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr79 : bridgeOf PRE_first_tail_x15_r0_body.s79.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt78 : countersOkB PRE_first_tail_x15_r0_body.s78 PRE_first_tail_x15_r0_body.s79 = true
kernel_rfl bodyO79 : PRE_first_tail_x15_r0_body.S79.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S79.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc79 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s79 PRE_first_tail_x15_r0_body.S79) = fun _ _ => true
kernel_rfl bodyAcc81 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s81 PRE_first_tail_x15_r0_body.S81) = fun _ _ => true
kernel_rfl bodyBr82 : bridgeOf PRE_first_tail_x15_r0_body.s82.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt81 : isHalt PRE_first_tail_x15_r0_body.s81.ctl = false
kernel_rfl bodyTop82 : noRetBlock PRE_first_tail_x15_r0_body.s82 = true
kernel_rfl bodyCnt79 : countersOkB PRE_first_tail_x15_r0_body.s79 PRE_first_tail_x15_r0_body.s82 = true

theorem bodyGlue7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7594, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.S76)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7594, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s82 PRE_first_tail_x15_r0_body.S82) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7594, 96, 0, 54⟩) bodyAcc76 PRE_first_tail_x15_r0_body.bodyRunSeg21 bodyAcc77 bodyHalt77 PRE_first_tail_x15_r0_body.bodyStepA22 bodyTop78 (fun _ hm => bodyO76 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr76).trans bodyInactive0) (bodyBr78.trans bodyBr76.symm) bodyCnt76 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7594, 96, 0, 54⟩) PRE_first_tail_x15_r0_body.sizeA22 PRE_first_tail_x15_r0_body.sizeArgsA22 PRE_first_tail_x15_r0_body.sizeSymA22 PRE_first_tail_x15_r0_body.sizeMlxA22 PRE_first_tail_x15_r0_body.sizePayA22 PRE_first_tail_x15_r0_body.sizeTaA22 PRE_first_tail_x15_r0_body.sizeDecA22 PRE_first_tail_x15_r0_body.sizePreA22 PRE_first_tail_x15_r0_body.bodyPatchB22 (fun _ hm => bodyO78 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr78).trans bodyInactive0) (bodyBr79.trans bodyBr78.symm) bodyCnt78 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7594, 96, 0, 54⟩) bodyAcc79 PRE_first_tail_x15_r0_body.bodyRunSeg22 bodyAcc81 bodyHalt81 PRE_first_tail_x15_r0_body.bodyStepA23 bodyTop82 (fun _ hm => bodyO79 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr79).trans bodyInactive0) (bodyBr82.trans bodyBr79.symm) bodyCnt79 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
