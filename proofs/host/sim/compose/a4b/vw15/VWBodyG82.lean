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

kernel_rfl bodyO794 : PRE_first_tail_x15_r0_body.S794.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S794.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr794 : bridgeOf PRE_first_tail_x15_r0_body.s794.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc794 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s794 PRE_first_tail_x15_r0_body.S794) = fun _ _ => true
kernel_rfl bodyAcc795 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s795 PRE_first_tail_x15_r0_body.S795) = fun _ _ => true
kernel_rfl bodyBr796 : bridgeOf PRE_first_tail_x15_r0_body.s796.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt795 : isHalt PRE_first_tail_x15_r0_body.s795.ctl = false
kernel_rfl bodyTop796 : noRetBlock PRE_first_tail_x15_r0_body.s796 = true
kernel_rfl bodyCnt794 : countersOkB PRE_first_tail_x15_r0_body.s794 PRE_first_tail_x15_r0_body.s796 = true
kernel_rfl bodyO796 : PRE_first_tail_x15_r0_body.S796.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S796.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr797 : bridgeOf PRE_first_tail_x15_r0_body.s797.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt796 : countersOkB PRE_first_tail_x15_r0_body.s796 PRE_first_tail_x15_r0_body.s797 = true
kernel_rfl bodyO797 : PRE_first_tail_x15_r0_body.S797.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S797.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc797 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s797 PRE_first_tail_x15_r0_body.S797) = fun _ _ => true
kernel_rfl bodyAcc799 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s799 PRE_first_tail_x15_r0_body.S799) = fun _ _ => true
kernel_rfl bodyBr800 : bridgeOf PRE_first_tail_x15_r0_body.s800.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt799 : isHalt PRE_first_tail_x15_r0_body.s799.ctl = false
kernel_rfl bodyTop800 : noRetBlock PRE_first_tail_x15_r0_body.s800 = true
kernel_rfl bodyCnt797 : countersOkB PRE_first_tail_x15_r0_body.s797 PRE_first_tail_x15_r0_body.s800 = true

theorem bodyGlue82 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨31080, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s794 PRE_first_tail_x15_r0_body.S794)
      (bodyCut NB T tk π i x0 bodyΘ ⟨31080, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s800 PRE_first_tail_x15_r0_body.S800) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31080, 560, 0, 441⟩) bodyAcc794 PRE_first_tail_x15_r0_body.bodyRunSeg214 bodyAcc795 bodyHalt795 PRE_first_tail_x15_r0_body.bodyStepA215 bodyTop796 (fun _ hm => bodyO794 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr794).trans bodyInactive0) (bodyBr796.trans bodyBr794.symm) bodyCnt794 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31080, 560, 0, 441⟩) PRE_first_tail_x15_r0_body.sizeA215 PRE_first_tail_x15_r0_body.sizeArgsA215 PRE_first_tail_x15_r0_body.sizeSymA215 PRE_first_tail_x15_r0_body.sizeMlxA215 PRE_first_tail_x15_r0_body.sizePayA215 PRE_first_tail_x15_r0_body.sizeTaA215 PRE_first_tail_x15_r0_body.sizeDecA215 PRE_first_tail_x15_r0_body.sizePreA215 PRE_first_tail_x15_r0_body.bodyPatchB215 (fun _ hm => bodyO796 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr796).trans bodyInactive0) (bodyBr797.trans bodyBr796.symm) bodyCnt796 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31080, 560, 0, 441⟩) bodyAcc797 PRE_first_tail_x15_r0_body.bodyRunSeg215 bodyAcc799 bodyHalt799 PRE_first_tail_x15_r0_body.bodyStepA216 bodyTop800 (fun _ hm => bodyO797 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr797).trans bodyInactive0) (bodyBr800.trans bodyBr797.symm) bodyCnt797 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
