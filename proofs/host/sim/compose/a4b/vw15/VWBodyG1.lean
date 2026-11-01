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

kernel_rfl bodyO17 : PRE_first_tail_x15_r0_body.S17.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S17.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr17 : bridgeOf PRE_first_tail_x15_r0_body.s17.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc17 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.S17) = fun _ _ => true
kernel_rfl bodyAcc19 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s19 PRE_first_tail_x15_r0_body.S19) = fun _ _ => true
kernel_rfl bodyBr20 : bridgeOf PRE_first_tail_x15_r0_body.s20.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt19 : isHalt PRE_first_tail_x15_r0_body.s19.ctl = false
kernel_rfl bodyTop20 : noRetBlock PRE_first_tail_x15_r0_body.s20 = true
kernel_rfl bodyCnt17 : countersOkB PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.s20 = true
kernel_rfl bodyO20 : PRE_first_tail_x15_r0_body.S20.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S20.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr21 : bridgeOf PRE_first_tail_x15_r0_body.s21.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt20 : countersOkB PRE_first_tail_x15_r0_body.s20 PRE_first_tail_x15_r0_body.s21 = true
kernel_rfl bodyO21 : PRE_first_tail_x15_r0_body.S21.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S21.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc21 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s21 PRE_first_tail_x15_r0_body.S21) = fun _ _ => true
kernel_rfl bodyAcc23 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s23 PRE_first_tail_x15_r0_body.S23) = fun _ _ => true
kernel_rfl bodyBr24 : bridgeOf PRE_first_tail_x15_r0_body.s24.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt23 : isHalt PRE_first_tail_x15_r0_body.s23.ctl = false
kernel_rfl bodyTop24 : noRetBlock PRE_first_tail_x15_r0_body.s24 = true
kernel_rfl bodyCnt21 : countersOkB PRE_first_tail_x15_r0_body.s21 PRE_first_tail_x15_r0_body.s24 = true

theorem bodyGlue1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.S17)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s24 PRE_first_tail_x15_r0_body.S24) 8541 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc17 PRE_first_tail_x15_r0_body.bodyRunSeg5 bodyAcc19 bodyHalt19 PRE_first_tail_x15_r0_body.bodyStepA6 bodyTop20 (fun _ hm => bodyO17 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr17).trans bodyInactive0) (bodyBr20.trans bodyBr17.symm) bodyCnt17 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) PRE_first_tail_x15_r0_body.sizeA6 PRE_first_tail_x15_r0_body.sizeArgsA6 PRE_first_tail_x15_r0_body.sizeSymA6 PRE_first_tail_x15_r0_body.sizeMlxA6 PRE_first_tail_x15_r0_body.sizePayA6 PRE_first_tail_x15_r0_body.sizeTaA6 PRE_first_tail_x15_r0_body.sizeDecA6 PRE_first_tail_x15_r0_body.sizePreA6 PRE_first_tail_x15_r0_body.bodyPatchB6 (fun _ hm => bodyO20 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr20).trans bodyInactive0) (bodyBr21.trans bodyBr20.symm) bodyCnt20 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc21 PRE_first_tail_x15_r0_body.bodyRunSeg6 bodyAcc23 bodyHalt23 PRE_first_tail_x15_r0_body.bodyStepA7 bodyTop24 (fun _ hm => bodyO21 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr21).trans bodyInactive0) (bodyBr24.trans bodyBr21.symm) bodyCnt21 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
