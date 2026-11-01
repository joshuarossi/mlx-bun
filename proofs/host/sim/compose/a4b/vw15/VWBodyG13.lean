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

kernel_rfl bodyO133 : PRE_first_tail_x15_r0_body.S133.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S133.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr133 : bridgeOf PRE_first_tail_x15_r0_body.s133.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc133 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s133 PRE_first_tail_x15_r0_body.S133) = fun _ _ => true
kernel_rfl bodyAcc134 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s134 PRE_first_tail_x15_r0_body.S134) = fun _ _ => true
kernel_rfl bodyBr135 : bridgeOf PRE_first_tail_x15_r0_body.s135.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt134 : isHalt PRE_first_tail_x15_r0_body.s134.ctl = false
kernel_rfl bodyTop135 : noRetBlock PRE_first_tail_x15_r0_body.s135 = true
kernel_rfl bodyCnt133 : countersOkB PRE_first_tail_x15_r0_body.s133 PRE_first_tail_x15_r0_body.s135 = true
kernel_rfl bodyO135 : PRE_first_tail_x15_r0_body.S135.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S135.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr136 : bridgeOf PRE_first_tail_x15_r0_body.s136.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt135 : countersOkB PRE_first_tail_x15_r0_body.s135 PRE_first_tail_x15_r0_body.s136 = true
kernel_rfl bodyO136 : PRE_first_tail_x15_r0_body.S136.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S136.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc136 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s136 PRE_first_tail_x15_r0_body.S136) = fun _ _ => true
kernel_rfl bodyAcc138 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s138 PRE_first_tail_x15_r0_body.S138) = fun _ _ => true
kernel_rfl bodyBr139 : bridgeOf PRE_first_tail_x15_r0_body.s139.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt138 : isHalt PRE_first_tail_x15_r0_body.s138.ctl = false
kernel_rfl bodyTop139 : noRetBlock PRE_first_tail_x15_r0_body.s139 = true
kernel_rfl bodyCnt136 : countersOkB PRE_first_tail_x15_r0_body.s136 PRE_first_tail_x15_r0_body.s139 = true

theorem bodyGlue13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9117, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s133 PRE_first_tail_x15_r0_body.S133)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9117, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s139 PRE_first_tail_x15_r0_body.S139) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9117, 123, 0, 81⟩) bodyAcc133 PRE_first_tail_x15_r0_body.bodyRunSeg36 bodyAcc134 bodyHalt134 PRE_first_tail_x15_r0_body.bodyStepA37 bodyTop135 (fun _ hm => bodyO133 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr133).trans bodyInactive0) (bodyBr135.trans bodyBr133.symm) bodyCnt133 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9117, 123, 0, 81⟩) PRE_first_tail_x15_r0_body.sizeA37 PRE_first_tail_x15_r0_body.sizeArgsA37 PRE_first_tail_x15_r0_body.sizeSymA37 PRE_first_tail_x15_r0_body.sizeMlxA37 PRE_first_tail_x15_r0_body.sizePayA37 PRE_first_tail_x15_r0_body.sizeTaA37 PRE_first_tail_x15_r0_body.sizeDecA37 PRE_first_tail_x15_r0_body.sizePreA37 PRE_first_tail_x15_r0_body.bodyPatchB37 (fun _ hm => bodyO135 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr135).trans bodyInactive0) (bodyBr136.trans bodyBr135.symm) bodyCnt135 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9117, 123, 0, 81⟩) bodyAcc136 PRE_first_tail_x15_r0_body.bodyRunSeg37 bodyAcc138 bodyHalt138 PRE_first_tail_x15_r0_body.bodyStepA38 bodyTop139 (fun _ hm => bodyO136 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr136).trans bodyInactive0) (bodyBr139.trans bodyBr136.symm) bodyCnt136 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
