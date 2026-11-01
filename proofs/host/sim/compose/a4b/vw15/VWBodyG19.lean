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

kernel_rfl bodyO191 : PRE_first_tail_x15_r0_body.S191.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S191.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr191 : bridgeOf PRE_first_tail_x15_r0_body.s191.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc191 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.S191) = fun _ _ => true
kernel_rfl bodyAcc192 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s192 PRE_first_tail_x15_r0_body.S192) = fun _ _ => true
kernel_rfl bodyBr193 : bridgeOf PRE_first_tail_x15_r0_body.s193.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt192 : isHalt PRE_first_tail_x15_r0_body.s192.ctl = false
kernel_rfl bodyTop193 : noRetBlock PRE_first_tail_x15_r0_body.s193 = true
kernel_rfl bodyCnt191 : countersOkB PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.s193 = true
kernel_rfl bodyO193 : PRE_first_tail_x15_r0_body.S193.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S193.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr194 : bridgeOf PRE_first_tail_x15_r0_body.s194.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt193 : countersOkB PRE_first_tail_x15_r0_body.s193 PRE_first_tail_x15_r0_body.s194 = true
kernel_rfl bodyO194 : PRE_first_tail_x15_r0_body.S194.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S194.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc194 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s194 PRE_first_tail_x15_r0_body.S194) = fun _ _ => true
kernel_rfl bodyAcc196 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s196 PRE_first_tail_x15_r0_body.S196) = fun _ _ => true
kernel_rfl bodyBr197 : bridgeOf PRE_first_tail_x15_r0_body.s197.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt196 : isHalt PRE_first_tail_x15_r0_body.s196.ctl = false
kernel_rfl bodyTop197 : noRetBlock PRE_first_tail_x15_r0_body.s197 = true
kernel_rfl bodyCnt194 : countersOkB PRE_first_tail_x15_r0_body.s194 PRE_first_tail_x15_r0_body.s197 = true

theorem bodyGlue19 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11439, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.S191)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11439, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s197 PRE_first_tail_x15_r0_body.S197) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11439, 173, 0, 117⟩) bodyAcc191 PRE_first_tail_x15_r0_body.bodyRunSeg52 bodyAcc192 bodyHalt192 PRE_first_tail_x15_r0_body.bodyStepA53 bodyTop193 (fun _ hm => bodyO191 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr191).trans bodyInactive0) (bodyBr193.trans bodyBr191.symm) bodyCnt191 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11439, 173, 0, 117⟩) PRE_first_tail_x15_r0_body.sizeA53 PRE_first_tail_x15_r0_body.sizeArgsA53 PRE_first_tail_x15_r0_body.sizeSymA53 PRE_first_tail_x15_r0_body.sizeMlxA53 PRE_first_tail_x15_r0_body.sizePayA53 PRE_first_tail_x15_r0_body.sizeTaA53 PRE_first_tail_x15_r0_body.sizeDecA53 PRE_first_tail_x15_r0_body.sizePreA53 PRE_first_tail_x15_r0_body.bodyPatchB53 (fun _ hm => bodyO193 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr193).trans bodyInactive0) (bodyBr194.trans bodyBr193.symm) bodyCnt193 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11439, 173, 0, 117⟩) bodyAcc194 PRE_first_tail_x15_r0_body.bodyRunSeg53 bodyAcc196 bodyHalt196 PRE_first_tail_x15_r0_body.bodyStepA54 bodyTop197 (fun _ hm => bodyO194 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr194).trans bodyInactive0) (bodyBr197.trans bodyBr194.symm) bodyCnt194 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
