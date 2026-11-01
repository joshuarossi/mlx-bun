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

kernel_rfl bodyO1657 : PRE_first_tail_x15_r0_body.S1657.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1657.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1657 : bridgeOf PRE_first_tail_x15_r0_body.s1657.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1657 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.S1657) = fun _ _ => true
kernel_rfl bodyAcc1658 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1658 PRE_first_tail_x15_r0_body.S1658) = fun _ _ => true
kernel_rfl bodyBr1659 : bridgeOf PRE_first_tail_x15_r0_body.s1659.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1658 : isHalt PRE_first_tail_x15_r0_body.s1658.ctl = false
kernel_rfl bodyTop1659 : noRetBlock PRE_first_tail_x15_r0_body.s1659 = true
kernel_rfl bodyCnt1657 : countersOkB PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.s1659 = true
kernel_rfl bodyO1659 : PRE_first_tail_x15_r0_body.S1659.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1659.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1660 : bridgeOf PRE_first_tail_x15_r0_body.s1660.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1659 : countersOkB PRE_first_tail_x15_r0_body.s1659 PRE_first_tail_x15_r0_body.s1660 = true
kernel_rfl bodyO1660 : PRE_first_tail_x15_r0_body.S1660.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1660.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1660 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1660 PRE_first_tail_x15_r0_body.S1660) = fun _ _ => true
kernel_rfl bodyAcc1662 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1662 PRE_first_tail_x15_r0_body.S1662) = fun _ _ => true
kernel_rfl bodyBr1663 : bridgeOf PRE_first_tail_x15_r0_body.s1663.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1662 : isHalt PRE_first_tail_x15_r0_body.s1662.ctl = false
kernel_rfl bodyTop1663 : noRetBlock PRE_first_tail_x15_r0_body.s1663 = true
kernel_rfl bodyCnt1660 : countersOkB PRE_first_tail_x15_r0_body.s1660 PRE_first_tail_x15_r0_body.s1663 = true

theorem bodyGlue172 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨60425, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.S1657)
      (bodyCut NB T tk π i x0 bodyΘ ⟨60425, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1663 PRE_first_tail_x15_r0_body.S1663) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60425, 1149, 0, 918⟩) bodyAcc1657 PRE_first_tail_x15_r0_body.bodyRunSeg447 bodyAcc1658 bodyHalt1658 PRE_first_tail_x15_r0_body.bodyStepA448 bodyTop1659 (fun _ hm => bodyO1657 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1657).trans bodyInactive0) (bodyBr1659.trans bodyBr1657.symm) bodyCnt1657 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60425, 1149, 0, 918⟩) PRE_first_tail_x15_r0_body.sizeA448 PRE_first_tail_x15_r0_body.sizeArgsA448 PRE_first_tail_x15_r0_body.sizeSymA448 PRE_first_tail_x15_r0_body.sizeMlxA448 PRE_first_tail_x15_r0_body.sizePayA448 PRE_first_tail_x15_r0_body.sizeTaA448 PRE_first_tail_x15_r0_body.sizeDecA448 PRE_first_tail_x15_r0_body.sizePreA448 PRE_first_tail_x15_r0_body.bodyPatchB448 (fun _ hm => bodyO1659 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1659).trans bodyInactive0) (bodyBr1660.trans bodyBr1659.symm) bodyCnt1659 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60425, 1149, 0, 918⟩) bodyAcc1660 PRE_first_tail_x15_r0_body.bodyRunSeg448 bodyAcc1662 bodyHalt1662 PRE_first_tail_x15_r0_body.bodyStepA449 bodyTop1663 (fun _ hm => bodyO1660 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1660).trans bodyInactive0) (bodyBr1663.trans bodyBr1660.symm) bodyCnt1660 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
