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

kernel_rfl bodyO921 : PRE_first_tail_x15_r0_body.S921.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S921.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr921 : bridgeOf PRE_first_tail_x15_r0_body.s921.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc921 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.S921) = fun _ _ => true
kernel_rfl bodyAcc923 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s923 PRE_first_tail_x15_r0_body.S923) = fun _ _ => true
kernel_rfl bodyBr924 : bridgeOf PRE_first_tail_x15_r0_body.s924.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt923 : isHalt PRE_first_tail_x15_r0_body.s923.ctl = false
kernel_rfl bodyTop924 : noRetBlock PRE_first_tail_x15_r0_body.s924 = true
kernel_rfl bodyCnt921 : countersOkB PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.s924 = true
kernel_rfl bodyO924 : PRE_first_tail_x15_r0_body.S924.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S924.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr925 : bridgeOf PRE_first_tail_x15_r0_body.s925.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt924 : countersOkB PRE_first_tail_x15_r0_body.s924 PRE_first_tail_x15_r0_body.s925 = true
kernel_rfl bodyO925 : PRE_first_tail_x15_r0_body.S925.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S925.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc925 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s925 PRE_first_tail_x15_r0_body.S925) = fun _ _ => true
kernel_rfl bodyAcc926 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s926 PRE_first_tail_x15_r0_body.S926) = fun _ _ => true
kernel_rfl bodyBr927 : bridgeOf PRE_first_tail_x15_r0_body.s927.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt926 : isHalt PRE_first_tail_x15_r0_body.s926.ctl = false
kernel_rfl bodyTop927 : noRetBlock PRE_first_tail_x15_r0_body.s927 = true
kernel_rfl bodyCnt925 : countersOkB PRE_first_tail_x15_r0_body.s925 PRE_first_tail_x15_r0_body.s927 = true
kernel_rfl bodyO927 : PRE_first_tail_x15_r0_body.S927.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S927.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr928 : bridgeOf PRE_first_tail_x15_r0_body.s928.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt927 : countersOkB PRE_first_tail_x15_r0_body.s927 PRE_first_tail_x15_r0_body.s928 = true
kernel_rfl bodyO928 : PRE_first_tail_x15_r0_body.S928.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S928.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc928 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s928 PRE_first_tail_x15_r0_body.S928) = fun _ _ => true
kernel_rfl bodyAcc929 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s929 PRE_first_tail_x15_r0_body.S929) = fun _ _ => true
kernel_rfl bodyBr930 : bridgeOf PRE_first_tail_x15_r0_body.s930.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt929 : isHalt PRE_first_tail_x15_r0_body.s929.ctl = false
kernel_rfl bodyTop930 : noRetBlock PRE_first_tail_x15_r0_body.s930 = true
kernel_rfl bodyCnt928 : countersOkB PRE_first_tail_x15_r0_body.s928 PRE_first_tail_x15_r0_body.s930 = true
kernel_rfl bodyO930 : PRE_first_tail_x15_r0_body.S930.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S930.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr931 : bridgeOf PRE_first_tail_x15_r0_body.s931.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt930 : countersOkB PRE_first_tail_x15_r0_body.s930 PRE_first_tail_x15_r0_body.s931 = true
kernel_rfl bodyO931 : PRE_first_tail_x15_r0_body.S931.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S931.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc931 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s931 PRE_first_tail_x15_r0_body.S931) = fun _ _ => true
kernel_rfl bodyAcc932 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s932 PRE_first_tail_x15_r0_body.S932) = fun _ _ => true
kernel_rfl bodyBr933 : bridgeOf PRE_first_tail_x15_r0_body.s933.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt932 : isHalt PRE_first_tail_x15_r0_body.s932.ctl = false
kernel_rfl bodyTop933 : noRetBlock PRE_first_tail_x15_r0_body.s933 = true
kernel_rfl bodyCnt931 : countersOkB PRE_first_tail_x15_r0_body.s931 PRE_first_tail_x15_r0_body.s933 = true
kernel_rfl bodyO933 : PRE_first_tail_x15_r0_body.S933.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S933.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr934 : bridgeOf PRE_first_tail_x15_r0_body.s934.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt933 : countersOkB PRE_first_tail_x15_r0_body.s933 PRE_first_tail_x15_r0_body.s934 = true
kernel_rfl bodyO934 : PRE_first_tail_x15_r0_body.S934.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S934.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc934 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s934 PRE_first_tail_x15_r0_body.S934) = fun _ _ => true
kernel_rfl bodyAcc935 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s935 PRE_first_tail_x15_r0_body.S935) = fun _ _ => true
kernel_rfl bodyBr936 : bridgeOf PRE_first_tail_x15_r0_body.s936.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt935 : isHalt PRE_first_tail_x15_r0_body.s935.ctl = false
kernel_rfl bodyTop936 : noRetBlock PRE_first_tail_x15_r0_body.s936 = true
kernel_rfl bodyCnt934 : countersOkB PRE_first_tail_x15_r0_body.s934 PRE_first_tail_x15_r0_body.s936 = true

theorem bodyGlue96 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34955, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.S921)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34955, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s936 PRE_first_tail_x15_r0_body.S936) 14768 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) bodyAcc921 PRE_first_tail_x15_r0_body.bodyRunSeg248 bodyAcc923 bodyHalt923 PRE_first_tail_x15_r0_body.bodyStepA249 bodyTop924 (fun _ hm => bodyO921 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr921).trans bodyInactive0) (bodyBr924.trans bodyBr921.symm) bodyCnt921 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) PRE_first_tail_x15_r0_body.sizeA249 PRE_first_tail_x15_r0_body.sizeArgsA249 PRE_first_tail_x15_r0_body.sizeSymA249 PRE_first_tail_x15_r0_body.sizeMlxA249 PRE_first_tail_x15_r0_body.sizePayA249 PRE_first_tail_x15_r0_body.sizeTaA249 PRE_first_tail_x15_r0_body.sizeDecA249 PRE_first_tail_x15_r0_body.sizePreA249 PRE_first_tail_x15_r0_body.bodyPatchB249 (fun _ hm => bodyO924 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr924).trans bodyInactive0) (bodyBr925.trans bodyBr924.symm) bodyCnt924 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) bodyAcc925 PRE_first_tail_x15_r0_body.bodyRunSeg249 bodyAcc926 bodyHalt926 PRE_first_tail_x15_r0_body.bodyStepA250 bodyTop927 (fun _ hm => bodyO925 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr925).trans bodyInactive0) (bodyBr927.trans bodyBr925.symm) bodyCnt925 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) PRE_first_tail_x15_r0_body.sizeA250 PRE_first_tail_x15_r0_body.sizeArgsA250 PRE_first_tail_x15_r0_body.sizeSymA250 PRE_first_tail_x15_r0_body.sizeMlxA250 PRE_first_tail_x15_r0_body.sizePayA250 PRE_first_tail_x15_r0_body.sizeTaA250 PRE_first_tail_x15_r0_body.sizeDecA250 PRE_first_tail_x15_r0_body.sizePreA250 PRE_first_tail_x15_r0_body.bodyPatchB250 (fun _ hm => bodyO927 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr927).trans bodyInactive0) (bodyBr928.trans bodyBr927.symm) bodyCnt927 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) bodyAcc928 PRE_first_tail_x15_r0_body.bodyRunSeg250 bodyAcc929 bodyHalt929 PRE_first_tail_x15_r0_body.bodyStepA251 bodyTop930 (fun _ hm => bodyO928 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr928).trans bodyInactive0) (bodyBr930.trans bodyBr928.symm) bodyCnt928 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) PRE_first_tail_x15_r0_body.sizeA251 PRE_first_tail_x15_r0_body.sizeArgsA251 PRE_first_tail_x15_r0_body.sizeSymA251 PRE_first_tail_x15_r0_body.sizeMlxA251 PRE_first_tail_x15_r0_body.sizePayA251 PRE_first_tail_x15_r0_body.sizeTaA251 PRE_first_tail_x15_r0_body.sizeDecA251 PRE_first_tail_x15_r0_body.sizePreA251 PRE_first_tail_x15_r0_body.bodyPatchB251 (fun _ hm => bodyO930 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr930).trans bodyInactive0) (bodyBr931.trans bodyBr930.symm) bodyCnt930 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) bodyAcc931 PRE_first_tail_x15_r0_body.bodyRunSeg251 bodyAcc932 bodyHalt932 PRE_first_tail_x15_r0_body.bodyStepA252 bodyTop933 (fun _ hm => bodyO931 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr931).trans bodyInactive0) (bodyBr933.trans bodyBr931.symm) bodyCnt931 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) PRE_first_tail_x15_r0_body.sizeA252 PRE_first_tail_x15_r0_body.sizeArgsA252 PRE_first_tail_x15_r0_body.sizeSymA252 PRE_first_tail_x15_r0_body.sizeMlxA252 PRE_first_tail_x15_r0_body.sizePayA252 PRE_first_tail_x15_r0_body.sizeTaA252 PRE_first_tail_x15_r0_body.sizeDecA252 PRE_first_tail_x15_r0_body.sizePreA252 PRE_first_tail_x15_r0_body.bodyPatchB252 (fun _ hm => bodyO933 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr933).trans bodyInactive0) (bodyBr934.trans bodyBr933.symm) bodyCnt933 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34955, 637, 0, 504⟩) bodyAcc934 PRE_first_tail_x15_r0_body.bodyRunSeg252 bodyAcc935 bodyHalt935 PRE_first_tail_x15_r0_body.bodyStepA253 bodyTop936 (fun _ hm => bodyO934 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr934).trans bodyInactive0) (bodyBr936.trans bodyBr934.symm) bodyCnt934 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
