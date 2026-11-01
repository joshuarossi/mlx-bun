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

kernel_rfl bodyO421 : PRE_first_tail_x15_r0_body.S421.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S421.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr421 : bridgeOf PRE_first_tail_x15_r0_body.s421.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc421 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.S421) = fun _ _ => true
kernel_rfl bodyAcc422 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s422 PRE_first_tail_x15_r0_body.S422) = fun _ _ => true
kernel_rfl bodyBr423 : bridgeOf PRE_first_tail_x15_r0_body.s423.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt422 : isHalt PRE_first_tail_x15_r0_body.s422.ctl = false
kernel_rfl bodyTop423 : noRetBlock PRE_first_tail_x15_r0_body.s423 = true
kernel_rfl bodyCnt421 : countersOkB PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.s423 = true
kernel_rfl bodyO423 : PRE_first_tail_x15_r0_body.S423.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S423.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr424 : bridgeOf PRE_first_tail_x15_r0_body.s424.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt423 : countersOkB PRE_first_tail_x15_r0_body.s423 PRE_first_tail_x15_r0_body.s424 = true
kernel_rfl bodyO424 : PRE_first_tail_x15_r0_body.S424.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S424.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc424 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s424 PRE_first_tail_x15_r0_body.S424) = fun _ _ => true
kernel_rfl bodyAcc426 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s426 PRE_first_tail_x15_r0_body.S426) = fun _ _ => true
kernel_rfl bodyBr427 : bridgeOf PRE_first_tail_x15_r0_body.s427.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt426 : isHalt PRE_first_tail_x15_r0_body.s426.ctl = false
kernel_rfl bodyTop427 : noRetBlock PRE_first_tail_x15_r0_body.s427 = true
kernel_rfl bodyCnt424 : countersOkB PRE_first_tail_x15_r0_body.s424 PRE_first_tail_x15_r0_body.s427 = true

theorem bodyGlue43 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19147, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.S421)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19147, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.S427) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19147, 327, 0, 243⟩) bodyAcc421 PRE_first_tail_x15_r0_body.bodyRunSeg114 bodyAcc422 bodyHalt422 PRE_first_tail_x15_r0_body.bodyStepA115 bodyTop423 (fun _ hm => bodyO421 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr421).trans bodyInactive0) (bodyBr423.trans bodyBr421.symm) bodyCnt421 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19147, 327, 0, 243⟩) PRE_first_tail_x15_r0_body.sizeA115 PRE_first_tail_x15_r0_body.sizeArgsA115 PRE_first_tail_x15_r0_body.sizeSymA115 PRE_first_tail_x15_r0_body.sizeMlxA115 PRE_first_tail_x15_r0_body.sizePayA115 PRE_first_tail_x15_r0_body.sizeTaA115 PRE_first_tail_x15_r0_body.sizeDecA115 PRE_first_tail_x15_r0_body.sizePreA115 PRE_first_tail_x15_r0_body.bodyPatchB115 (fun _ hm => bodyO423 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr423).trans bodyInactive0) (bodyBr424.trans bodyBr423.symm) bodyCnt423 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19147, 327, 0, 243⟩) bodyAcc424 PRE_first_tail_x15_r0_body.bodyRunSeg115 bodyAcc426 bodyHalt426 PRE_first_tail_x15_r0_body.bodyStepA116 bodyTop427 (fun _ hm => bodyO424 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr424).trans bodyInactive0) (bodyBr427.trans bodyBr424.symm) bodyCnt424 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
