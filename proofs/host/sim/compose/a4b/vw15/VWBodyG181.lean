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

kernel_rfl bodyO1743 : PRE_first_tail_x15_r0_body.S1743.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1743.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1743 : bridgeOf PRE_first_tail_x15_r0_body.s1743.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1743 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1743 PRE_first_tail_x15_r0_body.S1743) = fun _ _ => true
kernel_rfl bodyAcc1744 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1744 PRE_first_tail_x15_r0_body.S1744) = fun _ _ => true
kernel_rfl bodyBr1745 : bridgeOf PRE_first_tail_x15_r0_body.s1745.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1744 : isHalt PRE_first_tail_x15_r0_body.s1744.ctl = false
kernel_rfl bodyTop1745 : noRetBlock PRE_first_tail_x15_r0_body.s1745 = true
kernel_rfl bodyCnt1743 : countersOkB PRE_first_tail_x15_r0_body.s1743 PRE_first_tail_x15_r0_body.s1745 = true
kernel_rfl bodyO1745 : PRE_first_tail_x15_r0_body.S1745.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1745.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1746 : bridgeOf PRE_first_tail_x15_r0_body.s1746.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1745 : countersOkB PRE_first_tail_x15_r0_body.s1745 PRE_first_tail_x15_r0_body.s1746 = true
kernel_rfl bodyO1746 : PRE_first_tail_x15_r0_body.S1746.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1746.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1746 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1746 PRE_first_tail_x15_r0_body.S1746) = fun _ _ => true
kernel_rfl bodyAcc1748 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1748 PRE_first_tail_x15_r0_body.S1748) = fun _ _ => true
kernel_rfl bodyBr1749 : bridgeOf PRE_first_tail_x15_r0_body.s1749.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1748 : isHalt PRE_first_tail_x15_r0_body.s1748.ctl = false
kernel_rfl bodyTop1749 : noRetBlock PRE_first_tail_x15_r0_body.s1749 = true
kernel_rfl bodyCnt1746 : countersOkB PRE_first_tail_x15_r0_body.s1746 PRE_first_tail_x15_r0_body.s1749 = true

theorem bodyGlue181 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨63136, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1743 PRE_first_tail_x15_r0_body.S1743)
      (bodyCut NB T tk π i x0 bodyΘ ⟨63136, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1749 PRE_first_tail_x15_r0_body.S1749) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63136, 1201, 0, 963⟩) bodyAcc1743 PRE_first_tail_x15_r0_body.bodyRunSeg470 bodyAcc1744 bodyHalt1744 PRE_first_tail_x15_r0_body.bodyStepA471 bodyTop1745 (fun _ hm => bodyO1743 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1743).trans bodyInactive0) (bodyBr1745.trans bodyBr1743.symm) bodyCnt1743 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63136, 1201, 0, 963⟩) PRE_first_tail_x15_r0_body.sizeA471 PRE_first_tail_x15_r0_body.sizeArgsA471 PRE_first_tail_x15_r0_body.sizeSymA471 PRE_first_tail_x15_r0_body.sizeMlxA471 PRE_first_tail_x15_r0_body.sizePayA471 PRE_first_tail_x15_r0_body.sizeTaA471 PRE_first_tail_x15_r0_body.sizeDecA471 PRE_first_tail_x15_r0_body.sizePreA471 PRE_first_tail_x15_r0_body.bodyPatchB471 (fun _ hm => bodyO1745 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1745).trans bodyInactive0) (bodyBr1746.trans bodyBr1745.symm) bodyCnt1745 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63136, 1201, 0, 963⟩) bodyAcc1746 PRE_first_tail_x15_r0_body.bodyRunSeg471 bodyAcc1748 bodyHalt1748 PRE_first_tail_x15_r0_body.bodyStepA472 bodyTop1749 (fun _ hm => bodyO1746 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1746).trans bodyInactive0) (bodyBr1749.trans bodyBr1746.symm) bodyCnt1746 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
