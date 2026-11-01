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

kernel_rfl bodyO593 : PRE_first_tail_x15_r0_body.S593.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S593.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr593 : bridgeOf PRE_first_tail_x15_r0_body.s593.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc593 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.S593) = fun _ _ => true
kernel_rfl bodyAcc594 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s594 PRE_first_tail_x15_r0_body.S594) = fun _ _ => true
kernel_rfl bodyBr595 : bridgeOf PRE_first_tail_x15_r0_body.s595.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt594 : isHalt PRE_first_tail_x15_r0_body.s594.ctl = false
kernel_rfl bodyTop595 : noRetBlock PRE_first_tail_x15_r0_body.s595 = true
kernel_rfl bodyCnt593 : countersOkB PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.s595 = true
kernel_rfl bodyO595 : PRE_first_tail_x15_r0_body.S595.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S595.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr596 : bridgeOf PRE_first_tail_x15_r0_body.s596.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt595 : countersOkB PRE_first_tail_x15_r0_body.s595 PRE_first_tail_x15_r0_body.s596 = true
kernel_rfl bodyO596 : PRE_first_tail_x15_r0_body.S596.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S596.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc596 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s596 PRE_first_tail_x15_r0_body.S596) = fun _ _ => true
kernel_rfl bodyAcc598 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s598 PRE_first_tail_x15_r0_body.S598) = fun _ _ => true
kernel_rfl bodyBr599 : bridgeOf PRE_first_tail_x15_r0_body.s599.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt598 : isHalt PRE_first_tail_x15_r0_body.s598.ctl = false
kernel_rfl bodyTop599 : noRetBlock PRE_first_tail_x15_r0_body.s599 = true
kernel_rfl bodyCnt596 : countersOkB PRE_first_tail_x15_r0_body.s596 PRE_first_tail_x15_r0_body.s599 = true

theorem bodyGlue61 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24551, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.S593)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24551, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s599 PRE_first_tail_x15_r0_body.S599) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24551, 431, 0, 333⟩) bodyAcc593 PRE_first_tail_x15_r0_body.bodyRunSeg160 bodyAcc594 bodyHalt594 PRE_first_tail_x15_r0_body.bodyStepA161 bodyTop595 (fun _ hm => bodyO593 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr593).trans bodyInactive0) (bodyBr595.trans bodyBr593.symm) bodyCnt593 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24551, 431, 0, 333⟩) PRE_first_tail_x15_r0_body.sizeA161 PRE_first_tail_x15_r0_body.sizeArgsA161 PRE_first_tail_x15_r0_body.sizeSymA161 PRE_first_tail_x15_r0_body.sizeMlxA161 PRE_first_tail_x15_r0_body.sizePayA161 PRE_first_tail_x15_r0_body.sizeTaA161 PRE_first_tail_x15_r0_body.sizeDecA161 PRE_first_tail_x15_r0_body.sizePreA161 PRE_first_tail_x15_r0_body.bodyPatchB161 (fun _ hm => bodyO595 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr595).trans bodyInactive0) (bodyBr596.trans bodyBr595.symm) bodyCnt595 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24551, 431, 0, 333⟩) bodyAcc596 PRE_first_tail_x15_r0_body.bodyRunSeg161 bodyAcc598 bodyHalt598 PRE_first_tail_x15_r0_body.bodyStepA162 bodyTop599 (fun _ hm => bodyO596 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr596).trans bodyInactive0) (bodyBr599.trans bodyBr596.symm) bodyCnt596 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
