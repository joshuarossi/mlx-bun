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

kernel_rfl bodyO564 : PRE_first_tail_x15_r0_body.S564.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S564.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr564 : bridgeOf PRE_first_tail_x15_r0_body.s564.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc564 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.S564) = fun _ _ => true
kernel_rfl bodyAcc565 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s565 PRE_first_tail_x15_r0_body.S565) = fun _ _ => true
kernel_rfl bodyBr566 : bridgeOf PRE_first_tail_x15_r0_body.s566.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt565 : isHalt PRE_first_tail_x15_r0_body.s565.ctl = false
kernel_rfl bodyTop566 : noRetBlock PRE_first_tail_x15_r0_body.s566 = true
kernel_rfl bodyCnt564 : countersOkB PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.s566 = true
kernel_rfl bodyO566 : PRE_first_tail_x15_r0_body.S566.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S566.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr567 : bridgeOf PRE_first_tail_x15_r0_body.s567.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt566 : countersOkB PRE_first_tail_x15_r0_body.s566 PRE_first_tail_x15_r0_body.s567 = true
kernel_rfl bodyO567 : PRE_first_tail_x15_r0_body.S567.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S567.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc567 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s567 PRE_first_tail_x15_r0_body.S567) = fun _ _ => true
kernel_rfl bodyAcc569 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s569 PRE_first_tail_x15_r0_body.S569) = fun _ _ => true
kernel_rfl bodyBr570 : bridgeOf PRE_first_tail_x15_r0_body.s570.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt569 : isHalt PRE_first_tail_x15_r0_body.s569.ctl = false
kernel_rfl bodyTop570 : noRetBlock PRE_first_tail_x15_r0_body.s570 = true
kernel_rfl bodyCnt567 : countersOkB PRE_first_tail_x15_r0_body.s567 PRE_first_tail_x15_r0_body.s570 = true

theorem bodyGlue58 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23390, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.S564)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23390, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s570 PRE_first_tail_x15_r0_body.S570) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23390, 406, 0, 315⟩) bodyAcc564 PRE_first_tail_x15_r0_body.bodyRunSeg152 bodyAcc565 bodyHalt565 PRE_first_tail_x15_r0_body.bodyStepA153 bodyTop566 (fun _ hm => bodyO564 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr564).trans bodyInactive0) (bodyBr566.trans bodyBr564.symm) bodyCnt564 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23390, 406, 0, 315⟩) PRE_first_tail_x15_r0_body.sizeA153 PRE_first_tail_x15_r0_body.sizeArgsA153 PRE_first_tail_x15_r0_body.sizeSymA153 PRE_first_tail_x15_r0_body.sizeMlxA153 PRE_first_tail_x15_r0_body.sizePayA153 PRE_first_tail_x15_r0_body.sizeTaA153 PRE_first_tail_x15_r0_body.sizeDecA153 PRE_first_tail_x15_r0_body.sizePreA153 PRE_first_tail_x15_r0_body.bodyPatchB153 (fun _ hm => bodyO566 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr566).trans bodyInactive0) (bodyBr567.trans bodyBr566.symm) bodyCnt566 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23390, 406, 0, 315⟩) bodyAcc567 PRE_first_tail_x15_r0_body.bodyRunSeg153 bodyAcc569 bodyHalt569 PRE_first_tail_x15_r0_body.bodyStepA154 bodyTop570 (fun _ hm => bodyO567 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr567).trans bodyInactive0) (bodyBr570.trans bodyBr567.symm) bodyCnt567 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
