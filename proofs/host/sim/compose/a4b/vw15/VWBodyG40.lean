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

kernel_rfl bodyO392 : PRE_first_tail_x15_r0_body.S392.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S392.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr392 : bridgeOf PRE_first_tail_x15_r0_body.s392.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc392 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.S392) = fun _ _ => true
kernel_rfl bodyAcc393 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s393 PRE_first_tail_x15_r0_body.S393) = fun _ _ => true
kernel_rfl bodyBr394 : bridgeOf PRE_first_tail_x15_r0_body.s394.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt393 : isHalt PRE_first_tail_x15_r0_body.s393.ctl = false
kernel_rfl bodyTop394 : noRetBlock PRE_first_tail_x15_r0_body.s394 = true
kernel_rfl bodyCnt392 : countersOkB PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.s394 = true
kernel_rfl bodyO394 : PRE_first_tail_x15_r0_body.S394.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S394.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr395 : bridgeOf PRE_first_tail_x15_r0_body.s395.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt394 : countersOkB PRE_first_tail_x15_r0_body.s394 PRE_first_tail_x15_r0_body.s395 = true
kernel_rfl bodyO395 : PRE_first_tail_x15_r0_body.S395.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S395.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc395 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s395 PRE_first_tail_x15_r0_body.S395) = fun _ _ => true
kernel_rfl bodyAcc397 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s397 PRE_first_tail_x15_r0_body.S397) = fun _ _ => true
kernel_rfl bodyBr398 : bridgeOf PRE_first_tail_x15_r0_body.s398.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt397 : isHalt PRE_first_tail_x15_r0_body.s397.ctl = false
kernel_rfl bodyTop398 : noRetBlock PRE_first_tail_x15_r0_body.s398 = true
kernel_rfl bodyCnt395 : countersOkB PRE_first_tail_x15_r0_body.s395 PRE_first_tail_x15_r0_body.s398 = true

theorem bodyGlue40 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17977, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.S392)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17977, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.S398) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17977, 302, 0, 225⟩) bodyAcc392 PRE_first_tail_x15_r0_body.bodyRunSeg106 bodyAcc393 bodyHalt393 PRE_first_tail_x15_r0_body.bodyStepA107 bodyTop394 (fun _ hm => bodyO392 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr392).trans bodyInactive0) (bodyBr394.trans bodyBr392.symm) bodyCnt392 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17977, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA107 PRE_first_tail_x15_r0_body.sizeArgsA107 PRE_first_tail_x15_r0_body.sizeSymA107 PRE_first_tail_x15_r0_body.sizeMlxA107 PRE_first_tail_x15_r0_body.sizePayA107 PRE_first_tail_x15_r0_body.sizeTaA107 PRE_first_tail_x15_r0_body.sizeDecA107 PRE_first_tail_x15_r0_body.sizePreA107 PRE_first_tail_x15_r0_body.bodyPatchB107 (fun _ hm => bodyO394 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr394).trans bodyInactive0) (bodyBr395.trans bodyBr394.symm) bodyCnt394 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17977, 302, 0, 225⟩) bodyAcc395 PRE_first_tail_x15_r0_body.bodyRunSeg107 bodyAcc397 bodyHalt397 PRE_first_tail_x15_r0_body.bodyStepA108 bodyTop398 (fun _ hm => bodyO395 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr395).trans bodyInactive0) (bodyBr398.trans bodyBr395.symm) bodyCnt395 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
