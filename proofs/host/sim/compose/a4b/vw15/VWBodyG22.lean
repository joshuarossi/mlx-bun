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

kernel_rfl bodyO219 : PRE_first_tail_x15_r0_body.S219.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S219.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr219 : bridgeOf PRE_first_tail_x15_r0_body.s219.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc219 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.S219) = fun _ _ => true
kernel_rfl bodyAcc220 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s220 PRE_first_tail_x15_r0_body.S220) = fun _ _ => true
kernel_rfl bodyBr221 : bridgeOf PRE_first_tail_x15_r0_body.s221.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt220 : isHalt PRE_first_tail_x15_r0_body.s220.ctl = false
kernel_rfl bodyTop221 : noRetBlock PRE_first_tail_x15_r0_body.s221 = true
kernel_rfl bodyCnt219 : countersOkB PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.s221 = true
kernel_rfl bodyO221 : PRE_first_tail_x15_r0_body.S221.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S221.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr222 : bridgeOf PRE_first_tail_x15_r0_body.s222.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt221 : countersOkB PRE_first_tail_x15_r0_body.s221 PRE_first_tail_x15_r0_body.s222 = true
kernel_rfl bodyO222 : PRE_first_tail_x15_r0_body.S222.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S222.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc222 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s222 PRE_first_tail_x15_r0_body.S222) = fun _ _ => true
kernel_rfl bodyAcc224 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s224 PRE_first_tail_x15_r0_body.S224) = fun _ _ => true
kernel_rfl bodyBr225 : bridgeOf PRE_first_tail_x15_r0_body.s225.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt224 : isHalt PRE_first_tail_x15_r0_body.s224.ctl = false
kernel_rfl bodyTop225 : noRetBlock PRE_first_tail_x15_r0_body.s225 = true
kernel_rfl bodyCnt222 : countersOkB PRE_first_tail_x15_r0_body.s222 PRE_first_tail_x15_r0_body.s225 = true

theorem bodyGlue22 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11801, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.S219)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11801, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s225 PRE_first_tail_x15_r0_body.S225) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11801, 175, 0, 126⟩) bodyAcc219 PRE_first_tail_x15_r0_body.bodyRunSeg59 bodyAcc220 bodyHalt220 PRE_first_tail_x15_r0_body.bodyStepA60 bodyTop221 (fun _ hm => bodyO219 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr219).trans bodyInactive0) (bodyBr221.trans bodyBr219.symm) bodyCnt219 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11801, 175, 0, 126⟩) PRE_first_tail_x15_r0_body.sizeA60 PRE_first_tail_x15_r0_body.sizeArgsA60 PRE_first_tail_x15_r0_body.sizeSymA60 PRE_first_tail_x15_r0_body.sizeMlxA60 PRE_first_tail_x15_r0_body.sizePayA60 PRE_first_tail_x15_r0_body.sizeTaA60 PRE_first_tail_x15_r0_body.sizeDecA60 PRE_first_tail_x15_r0_body.sizePreA60 PRE_first_tail_x15_r0_body.bodyPatchB60 (fun _ hm => bodyO221 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr221).trans bodyInactive0) (bodyBr222.trans bodyBr221.symm) bodyCnt221 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11801, 175, 0, 126⟩) bodyAcc222 PRE_first_tail_x15_r0_body.bodyRunSeg60 bodyAcc224 bodyHalt224 PRE_first_tail_x15_r0_body.bodyStepA61 bodyTop225 (fun _ hm => bodyO222 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr222).trans bodyInactive0) (bodyBr225.trans bodyBr222.symm) bodyCnt222 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
