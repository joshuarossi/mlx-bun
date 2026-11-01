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

kernel_rfl bodyO1513 : PRE_first_tail_x15_r0_body.S1513.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1513.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1513 : bridgeOf PRE_first_tail_x15_r0_body.s1513.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1513 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1513 PRE_first_tail_x15_r0_body.S1513) = fun _ _ => true
kernel_rfl bodyAcc1514 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1514 PRE_first_tail_x15_r0_body.S1514) = fun _ _ => true
kernel_rfl bodyBr1515 : bridgeOf PRE_first_tail_x15_r0_body.s1515.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1514 : isHalt PRE_first_tail_x15_r0_body.s1514.ctl = false
kernel_rfl bodyTop1515 : noRetBlock PRE_first_tail_x15_r0_body.s1515 = true
kernel_rfl bodyCnt1513 : countersOkB PRE_first_tail_x15_r0_body.s1513 PRE_first_tail_x15_r0_body.s1515 = true
kernel_rfl bodyO1515 : PRE_first_tail_x15_r0_body.S1515.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1515.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1516 : bridgeOf PRE_first_tail_x15_r0_body.s1516.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1515 : countersOkB PRE_first_tail_x15_r0_body.s1515 PRE_first_tail_x15_r0_body.s1516 = true
kernel_rfl bodyO1516 : PRE_first_tail_x15_r0_body.S1516.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1516.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1516 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1516 PRE_first_tail_x15_r0_body.S1516) = fun _ _ => true
kernel_rfl bodyAcc1518 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1518 PRE_first_tail_x15_r0_body.S1518) = fun _ _ => true
kernel_rfl bodyBr1519 : bridgeOf PRE_first_tail_x15_r0_body.s1519.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1518 : isHalt PRE_first_tail_x15_r0_body.s1518.ctl = false
kernel_rfl bodyTop1519 : noRetBlock PRE_first_tail_x15_r0_body.s1519 = true
kernel_rfl bodyCnt1516 : countersOkB PRE_first_tail_x15_r0_body.s1516 PRE_first_tail_x15_r0_body.s1519 = true

theorem bodyGlue157 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨55392, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1513 PRE_first_tail_x15_r0_body.S1513)
      (bodyCut NB T tk π i x0 bodyΘ ⟨55392, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1519 PRE_first_tail_x15_r0_body.S1519) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55392, 1047, 0, 837⟩) bodyAcc1513 PRE_first_tail_x15_r0_body.bodyRunSeg408 bodyAcc1514 bodyHalt1514 PRE_first_tail_x15_r0_body.bodyStepA409 bodyTop1515 (fun _ hm => bodyO1513 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1513).trans bodyInactive0) (bodyBr1515.trans bodyBr1513.symm) bodyCnt1513 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55392, 1047, 0, 837⟩) PRE_first_tail_x15_r0_body.sizeA409 PRE_first_tail_x15_r0_body.sizeArgsA409 PRE_first_tail_x15_r0_body.sizeSymA409 PRE_first_tail_x15_r0_body.sizeMlxA409 PRE_first_tail_x15_r0_body.sizePayA409 PRE_first_tail_x15_r0_body.sizeTaA409 PRE_first_tail_x15_r0_body.sizeDecA409 PRE_first_tail_x15_r0_body.sizePreA409 PRE_first_tail_x15_r0_body.bodyPatchB409 (fun _ hm => bodyO1515 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1515).trans bodyInactive0) (bodyBr1516.trans bodyBr1515.symm) bodyCnt1515 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55392, 1047, 0, 837⟩) bodyAcc1516 PRE_first_tail_x15_r0_body.bodyRunSeg409 bodyAcc1518 bodyHalt1518 PRE_first_tail_x15_r0_body.bodyStepA410 bodyTop1519 (fun _ hm => bodyO1516 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1516).trans bodyInactive0) (bodyBr1519.trans bodyBr1516.symm) bodyCnt1516 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
