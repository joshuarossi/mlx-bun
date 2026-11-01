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

kernel_rfl bodyO306 : PRE_first_tail_x15_r0_body.S306.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S306.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr306 : bridgeOf PRE_first_tail_x15_r0_body.s306.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc306 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.S306) = fun _ _ => true
kernel_rfl bodyAcc307 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s307 PRE_first_tail_x15_r0_body.S307) = fun _ _ => true
kernel_rfl bodyBr308 : bridgeOf PRE_first_tail_x15_r0_body.s308.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt307 : isHalt PRE_first_tail_x15_r0_body.s307.ctl = false
kernel_rfl bodyTop308 : noRetBlock PRE_first_tail_x15_r0_body.s308 = true
kernel_rfl bodyCnt306 : countersOkB PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.s308 = true
kernel_rfl bodyO308 : PRE_first_tail_x15_r0_body.S308.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S308.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr309 : bridgeOf PRE_first_tail_x15_r0_body.s309.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt308 : countersOkB PRE_first_tail_x15_r0_body.s308 PRE_first_tail_x15_r0_body.s309 = true
kernel_rfl bodyO309 : PRE_first_tail_x15_r0_body.S309.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S309.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc309 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s309 PRE_first_tail_x15_r0_body.S309) = fun _ _ => true
kernel_rfl bodyAcc311 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s311 PRE_first_tail_x15_r0_body.S311) = fun _ _ => true
kernel_rfl bodyBr312 : bridgeOf PRE_first_tail_x15_r0_body.s312.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt311 : isHalt PRE_first_tail_x15_r0_body.s311.ctl = false
kernel_rfl bodyTop312 : noRetBlock PRE_first_tail_x15_r0_body.s312 = true
kernel_rfl bodyCnt309 : countersOkB PRE_first_tail_x15_r0_body.s309 PRE_first_tail_x15_r0_body.s312 = true

theorem bodyGlue31 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15284, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.S306)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15284, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s312 PRE_first_tail_x15_r0_body.S312) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15284, 250, 0, 180⟩) bodyAcc306 PRE_first_tail_x15_r0_body.bodyRunSeg83 bodyAcc307 bodyHalt307 PRE_first_tail_x15_r0_body.bodyStepA84 bodyTop308 (fun _ hm => bodyO306 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr306).trans bodyInactive0) (bodyBr308.trans bodyBr306.symm) bodyCnt306 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15284, 250, 0, 180⟩) PRE_first_tail_x15_r0_body.sizeA84 PRE_first_tail_x15_r0_body.sizeArgsA84 PRE_first_tail_x15_r0_body.sizeSymA84 PRE_first_tail_x15_r0_body.sizeMlxA84 PRE_first_tail_x15_r0_body.sizePayA84 PRE_first_tail_x15_r0_body.sizeTaA84 PRE_first_tail_x15_r0_body.sizeDecA84 PRE_first_tail_x15_r0_body.sizePreA84 PRE_first_tail_x15_r0_body.bodyPatchB84 (fun _ hm => bodyO308 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr308).trans bodyInactive0) (bodyBr309.trans bodyBr308.symm) bodyCnt308 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15284, 250, 0, 180⟩) bodyAcc309 PRE_first_tail_x15_r0_body.bodyRunSeg84 bodyAcc311 bodyHalt311 PRE_first_tail_x15_r0_body.bodyStepA85 bodyTop312 (fun _ hm => bodyO309 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr309).trans bodyInactive0) (bodyBr312.trans bodyBr309.symm) bodyCnt309 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
