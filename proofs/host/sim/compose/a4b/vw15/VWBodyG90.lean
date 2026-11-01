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

kernel_rfl bodyO864 : PRE_first_tail_x15_r0_body.S864.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S864.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr864 : bridgeOf PRE_first_tail_x15_r0_body.s864.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc864 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.S864) = fun _ _ => true
kernel_rfl bodyAcc866 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s866 PRE_first_tail_x15_r0_body.S866) = fun _ _ => true
kernel_rfl bodyBr867 : bridgeOf PRE_first_tail_x15_r0_body.s867.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt866 : isHalt PRE_first_tail_x15_r0_body.s866.ctl = false
kernel_rfl bodyTop867 : noRetBlock PRE_first_tail_x15_r0_body.s867 = true
kernel_rfl bodyCnt864 : countersOkB PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.s867 = true
kernel_rfl bodyO867 : PRE_first_tail_x15_r0_body.S867.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S867.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr868 : bridgeOf PRE_first_tail_x15_r0_body.s868.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt867 : countersOkB PRE_first_tail_x15_r0_body.s867 PRE_first_tail_x15_r0_body.s868 = true
kernel_rfl bodyO868 : PRE_first_tail_x15_r0_body.S868.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S868.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc868 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s868 PRE_first_tail_x15_r0_body.S868) = fun _ _ => true
kernel_rfl bodyAcc869 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s869 PRE_first_tail_x15_r0_body.S869) = fun _ _ => true
kernel_rfl bodyBr870 : bridgeOf PRE_first_tail_x15_r0_body.s870.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt869 : isHalt PRE_first_tail_x15_r0_body.s869.ctl = false
kernel_rfl bodyTop870 : noRetBlock PRE_first_tail_x15_r0_body.s870 = true
kernel_rfl bodyCnt868 : countersOkB PRE_first_tail_x15_r0_body.s868 PRE_first_tail_x15_r0_body.s870 = true
kernel_rfl bodyO870 : PRE_first_tail_x15_r0_body.S870.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S870.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr871 : bridgeOf PRE_first_tail_x15_r0_body.s871.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt870 : countersOkB PRE_first_tail_x15_r0_body.s870 PRE_first_tail_x15_r0_body.s871 = true
kernel_rfl bodyO871 : PRE_first_tail_x15_r0_body.S871.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S871.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc871 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s871 PRE_first_tail_x15_r0_body.S871) = fun _ _ => true
kernel_rfl bodyAcc872 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s872 PRE_first_tail_x15_r0_body.S872) = fun _ _ => true
kernel_rfl bodyBr873 : bridgeOf PRE_first_tail_x15_r0_body.s873.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt872 : isHalt PRE_first_tail_x15_r0_body.s872.ctl = false
kernel_rfl bodyTop873 : noRetBlock PRE_first_tail_x15_r0_body.s873 = true
kernel_rfl bodyCnt871 : countersOkB PRE_first_tail_x15_r0_body.s871 PRE_first_tail_x15_r0_body.s873 = true
kernel_rfl bodyO873 : PRE_first_tail_x15_r0_body.S873.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S873.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr874 : bridgeOf PRE_first_tail_x15_r0_body.s874.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt873 : countersOkB PRE_first_tail_x15_r0_body.s873 PRE_first_tail_x15_r0_body.s874 = true
kernel_rfl bodyO874 : PRE_first_tail_x15_r0_body.S874.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S874.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc874 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s874 PRE_first_tail_x15_r0_body.S874) = fun _ _ => true
kernel_rfl bodyAcc875 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s875 PRE_first_tail_x15_r0_body.S875) = fun _ _ => true
kernel_rfl bodyBr876 : bridgeOf PRE_first_tail_x15_r0_body.s876.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt875 : isHalt PRE_first_tail_x15_r0_body.s875.ctl = false
kernel_rfl bodyTop876 : noRetBlock PRE_first_tail_x15_r0_body.s876 = true
kernel_rfl bodyCnt874 : countersOkB PRE_first_tail_x15_r0_body.s874 PRE_first_tail_x15_r0_body.s876 = true
kernel_rfl bodyO876 : PRE_first_tail_x15_r0_body.S876.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S876.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr877 : bridgeOf PRE_first_tail_x15_r0_body.s877.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt876 : countersOkB PRE_first_tail_x15_r0_body.s876 PRE_first_tail_x15_r0_body.s877 = true
kernel_rfl bodyO877 : PRE_first_tail_x15_r0_body.S877.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S877.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc877 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s877 PRE_first_tail_x15_r0_body.S877) = fun _ _ => true
kernel_rfl bodyAcc878 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s878 PRE_first_tail_x15_r0_body.S878) = fun _ _ => true
kernel_rfl bodyBr879 : bridgeOf PRE_first_tail_x15_r0_body.s879.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt878 : isHalt PRE_first_tail_x15_r0_body.s878.ctl = false
kernel_rfl bodyTop879 : noRetBlock PRE_first_tail_x15_r0_body.s879 = true
kernel_rfl bodyCnt877 : countersOkB PRE_first_tail_x15_r0_body.s877 PRE_first_tail_x15_r0_body.s879 = true

theorem bodyGlue90 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨33423, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.S864)
      (bodyCut NB T tk π i x0 bodyΘ ⟨33423, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s879 PRE_first_tail_x15_r0_body.S879) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) bodyAcc864 PRE_first_tail_x15_r0_body.bodyRunSeg233 bodyAcc866 bodyHalt866 PRE_first_tail_x15_r0_body.bodyStepA234 bodyTop867 (fun _ hm => bodyO864 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr864).trans bodyInactive0) (bodyBr867.trans bodyBr864.symm) bodyCnt864 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) PRE_first_tail_x15_r0_body.sizeA234 PRE_first_tail_x15_r0_body.sizeArgsA234 PRE_first_tail_x15_r0_body.sizeSymA234 PRE_first_tail_x15_r0_body.sizeMlxA234 PRE_first_tail_x15_r0_body.sizePayA234 PRE_first_tail_x15_r0_body.sizeTaA234 PRE_first_tail_x15_r0_body.sizeDecA234 PRE_first_tail_x15_r0_body.sizePreA234 PRE_first_tail_x15_r0_body.bodyPatchB234 (fun _ hm => bodyO867 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr867).trans bodyInactive0) (bodyBr868.trans bodyBr867.symm) bodyCnt867 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) bodyAcc868 PRE_first_tail_x15_r0_body.bodyRunSeg234 bodyAcc869 bodyHalt869 PRE_first_tail_x15_r0_body.bodyStepA235 bodyTop870 (fun _ hm => bodyO868 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr868).trans bodyInactive0) (bodyBr870.trans bodyBr868.symm) bodyCnt868 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) PRE_first_tail_x15_r0_body.sizeA235 PRE_first_tail_x15_r0_body.sizeArgsA235 PRE_first_tail_x15_r0_body.sizeSymA235 PRE_first_tail_x15_r0_body.sizeMlxA235 PRE_first_tail_x15_r0_body.sizePayA235 PRE_first_tail_x15_r0_body.sizeTaA235 PRE_first_tail_x15_r0_body.sizeDecA235 PRE_first_tail_x15_r0_body.sizePreA235 PRE_first_tail_x15_r0_body.bodyPatchB235 (fun _ hm => bodyO870 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr870).trans bodyInactive0) (bodyBr871.trans bodyBr870.symm) bodyCnt870 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) bodyAcc871 PRE_first_tail_x15_r0_body.bodyRunSeg235 bodyAcc872 bodyHalt872 PRE_first_tail_x15_r0_body.bodyStepA236 bodyTop873 (fun _ hm => bodyO871 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr871).trans bodyInactive0) (bodyBr873.trans bodyBr871.symm) bodyCnt871 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) PRE_first_tail_x15_r0_body.sizeA236 PRE_first_tail_x15_r0_body.sizeArgsA236 PRE_first_tail_x15_r0_body.sizeSymA236 PRE_first_tail_x15_r0_body.sizeMlxA236 PRE_first_tail_x15_r0_body.sizePayA236 PRE_first_tail_x15_r0_body.sizeTaA236 PRE_first_tail_x15_r0_body.sizeDecA236 PRE_first_tail_x15_r0_body.sizePreA236 PRE_first_tail_x15_r0_body.bodyPatchB236 (fun _ hm => bodyO873 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr873).trans bodyInactive0) (bodyBr874.trans bodyBr873.symm) bodyCnt873 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) bodyAcc874 PRE_first_tail_x15_r0_body.bodyRunSeg236 bodyAcc875 bodyHalt875 PRE_first_tail_x15_r0_body.bodyStepA237 bodyTop876 (fun _ hm => bodyO874 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr874).trans bodyInactive0) (bodyBr876.trans bodyBr874.symm) bodyCnt874 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) PRE_first_tail_x15_r0_body.sizeA237 PRE_first_tail_x15_r0_body.sizeArgsA237 PRE_first_tail_x15_r0_body.sizeSymA237 PRE_first_tail_x15_r0_body.sizeMlxA237 PRE_first_tail_x15_r0_body.sizePayA237 PRE_first_tail_x15_r0_body.sizeTaA237 PRE_first_tail_x15_r0_body.sizeDecA237 PRE_first_tail_x15_r0_body.sizePreA237 PRE_first_tail_x15_r0_body.bodyPatchB237 (fun _ hm => bodyO876 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr876).trans bodyInactive0) (bodyBr877.trans bodyBr876.symm) bodyCnt876 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33423, 610, 0, 477⟩) bodyAcc877 PRE_first_tail_x15_r0_body.bodyRunSeg237 bodyAcc878 bodyHalt878 PRE_first_tail_x15_r0_body.bodyStepA238 bodyTop879 (fun _ hm => bodyO877 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr877).trans bodyInactive0) (bodyBr879.trans bodyBr877.symm) bodyCnt877 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
