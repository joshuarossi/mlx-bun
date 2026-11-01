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

kernel_rfl bodyO1036 : PRE_first_tail_x15_r0_body.S1036.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1036.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1036 : bridgeOf PRE_first_tail_x15_r0_body.s1036.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1036 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.S1036) = fun _ _ => true
kernel_rfl bodyAcc1038 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1038 PRE_first_tail_x15_r0_body.S1038) = fun _ _ => true
kernel_rfl bodyBr1039 : bridgeOf PRE_first_tail_x15_r0_body.s1039.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1038 : isHalt PRE_first_tail_x15_r0_body.s1038.ctl = false
kernel_rfl bodyTop1039 : noRetBlock PRE_first_tail_x15_r0_body.s1039 = true
kernel_rfl bodyCnt1036 : countersOkB PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.s1039 = true
kernel_rfl bodyO1039 : PRE_first_tail_x15_r0_body.S1039.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1039.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1040 : bridgeOf PRE_first_tail_x15_r0_body.s1040.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1039 : countersOkB PRE_first_tail_x15_r0_body.s1039 PRE_first_tail_x15_r0_body.s1040 = true
kernel_rfl bodyO1040 : PRE_first_tail_x15_r0_body.S1040.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1040.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1040 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1040 PRE_first_tail_x15_r0_body.S1040) = fun _ _ => true
kernel_rfl bodyAcc1041 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1041 PRE_first_tail_x15_r0_body.S1041) = fun _ _ => true
kernel_rfl bodyBr1042 : bridgeOf PRE_first_tail_x15_r0_body.s1042.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1041 : isHalt PRE_first_tail_x15_r0_body.s1041.ctl = false
kernel_rfl bodyTop1042 : noRetBlock PRE_first_tail_x15_r0_body.s1042 = true
kernel_rfl bodyCnt1040 : countersOkB PRE_first_tail_x15_r0_body.s1040 PRE_first_tail_x15_r0_body.s1042 = true
kernel_rfl bodyO1042 : PRE_first_tail_x15_r0_body.S1042.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1042.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1043 : bridgeOf PRE_first_tail_x15_r0_body.s1043.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1042 : countersOkB PRE_first_tail_x15_r0_body.s1042 PRE_first_tail_x15_r0_body.s1043 = true
kernel_rfl bodyO1043 : PRE_first_tail_x15_r0_body.S1043.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1043.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1043 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1043 PRE_first_tail_x15_r0_body.S1043) = fun _ _ => true
kernel_rfl bodyAcc1044 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1044 PRE_first_tail_x15_r0_body.S1044) = fun _ _ => true
kernel_rfl bodyBr1045 : bridgeOf PRE_first_tail_x15_r0_body.s1045.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1044 : isHalt PRE_first_tail_x15_r0_body.s1044.ctl = false
kernel_rfl bodyTop1045 : noRetBlock PRE_first_tail_x15_r0_body.s1045 = true
kernel_rfl bodyCnt1043 : countersOkB PRE_first_tail_x15_r0_body.s1043 PRE_first_tail_x15_r0_body.s1045 = true
kernel_rfl bodyO1045 : PRE_first_tail_x15_r0_body.S1045.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1045.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1046 : bridgeOf PRE_first_tail_x15_r0_body.s1046.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1045 : countersOkB PRE_first_tail_x15_r0_body.s1045 PRE_first_tail_x15_r0_body.s1046 = true
kernel_rfl bodyO1046 : PRE_first_tail_x15_r0_body.S1046.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1046.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1046 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1046 PRE_first_tail_x15_r0_body.S1046) = fun _ _ => true
kernel_rfl bodyAcc1047 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1047 PRE_first_tail_x15_r0_body.S1047) = fun _ _ => true
kernel_rfl bodyBr1048 : bridgeOf PRE_first_tail_x15_r0_body.s1048.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1047 : isHalt PRE_first_tail_x15_r0_body.s1047.ctl = false
kernel_rfl bodyTop1048 : noRetBlock PRE_first_tail_x15_r0_body.s1048 = true
kernel_rfl bodyCnt1046 : countersOkB PRE_first_tail_x15_r0_body.s1046 PRE_first_tail_x15_r0_body.s1048 = true
kernel_rfl bodyO1048 : PRE_first_tail_x15_r0_body.S1048.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1048.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1049 : bridgeOf PRE_first_tail_x15_r0_body.s1049.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1048 : countersOkB PRE_first_tail_x15_r0_body.s1048 PRE_first_tail_x15_r0_body.s1049 = true
kernel_rfl bodyO1049 : PRE_first_tail_x15_r0_body.S1049.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1049.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1049 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1049 PRE_first_tail_x15_r0_body.S1049) = fun _ _ => true
kernel_rfl bodyAcc1050 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1050 PRE_first_tail_x15_r0_body.S1050) = fun _ _ => true
kernel_rfl bodyBr1051 : bridgeOf PRE_first_tail_x15_r0_body.s1051.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1050 : isHalt PRE_first_tail_x15_r0_body.s1050.ctl = false
kernel_rfl bodyTop1051 : noRetBlock PRE_first_tail_x15_r0_body.s1051 = true
kernel_rfl bodyCnt1049 : countersOkB PRE_first_tail_x15_r0_body.s1049 PRE_first_tail_x15_r0_body.s1051 = true

theorem bodyGlue108 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38818, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.S1036)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38818, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1051 PRE_first_tail_x15_r0_body.S1051) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) bodyAcc1036 PRE_first_tail_x15_r0_body.bodyRunSeg279 bodyAcc1038 bodyHalt1038 PRE_first_tail_x15_r0_body.bodyStepA280 bodyTop1039 (fun _ hm => bodyO1036 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1036).trans bodyInactive0) (bodyBr1039.trans bodyBr1036.symm) bodyCnt1036 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) PRE_first_tail_x15_r0_body.sizeA280 PRE_first_tail_x15_r0_body.sizeArgsA280 PRE_first_tail_x15_r0_body.sizeSymA280 PRE_first_tail_x15_r0_body.sizeMlxA280 PRE_first_tail_x15_r0_body.sizePayA280 PRE_first_tail_x15_r0_body.sizeTaA280 PRE_first_tail_x15_r0_body.sizeDecA280 PRE_first_tail_x15_r0_body.sizePreA280 PRE_first_tail_x15_r0_body.bodyPatchB280 (fun _ hm => bodyO1039 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1039).trans bodyInactive0) (bodyBr1040.trans bodyBr1039.symm) bodyCnt1039 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) bodyAcc1040 PRE_first_tail_x15_r0_body.bodyRunSeg280 bodyAcc1041 bodyHalt1041 PRE_first_tail_x15_r0_body.bodyStepA281 bodyTop1042 (fun _ hm => bodyO1040 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1040).trans bodyInactive0) (bodyBr1042.trans bodyBr1040.symm) bodyCnt1040 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) PRE_first_tail_x15_r0_body.sizeA281 PRE_first_tail_x15_r0_body.sizeArgsA281 PRE_first_tail_x15_r0_body.sizeSymA281 PRE_first_tail_x15_r0_body.sizeMlxA281 PRE_first_tail_x15_r0_body.sizePayA281 PRE_first_tail_x15_r0_body.sizeTaA281 PRE_first_tail_x15_r0_body.sizeDecA281 PRE_first_tail_x15_r0_body.sizePreA281 PRE_first_tail_x15_r0_body.bodyPatchB281 (fun _ hm => bodyO1042 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1042).trans bodyInactive0) (bodyBr1043.trans bodyBr1042.symm) bodyCnt1042 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) bodyAcc1043 PRE_first_tail_x15_r0_body.bodyRunSeg281 bodyAcc1044 bodyHalt1044 PRE_first_tail_x15_r0_body.bodyStepA282 bodyTop1045 (fun _ hm => bodyO1043 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1043).trans bodyInactive0) (bodyBr1045.trans bodyBr1043.symm) bodyCnt1043 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) PRE_first_tail_x15_r0_body.sizeA282 PRE_first_tail_x15_r0_body.sizeArgsA282 PRE_first_tail_x15_r0_body.sizeSymA282 PRE_first_tail_x15_r0_body.sizeMlxA282 PRE_first_tail_x15_r0_body.sizePayA282 PRE_first_tail_x15_r0_body.sizeTaA282 PRE_first_tail_x15_r0_body.sizeDecA282 PRE_first_tail_x15_r0_body.sizePreA282 PRE_first_tail_x15_r0_body.bodyPatchB282 (fun _ hm => bodyO1045 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1045).trans bodyInactive0) (bodyBr1046.trans bodyBr1045.symm) bodyCnt1045 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) bodyAcc1046 PRE_first_tail_x15_r0_body.bodyRunSeg282 bodyAcc1047 bodyHalt1047 PRE_first_tail_x15_r0_body.bodyStepA283 bodyTop1048 (fun _ hm => bodyO1046 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1046).trans bodyInactive0) (bodyBr1048.trans bodyBr1046.symm) bodyCnt1046 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) PRE_first_tail_x15_r0_body.sizeA283 PRE_first_tail_x15_r0_body.sizeArgsA283 PRE_first_tail_x15_r0_body.sizeSymA283 PRE_first_tail_x15_r0_body.sizeMlxA283 PRE_first_tail_x15_r0_body.sizePayA283 PRE_first_tail_x15_r0_body.sizeTaA283 PRE_first_tail_x15_r0_body.sizeDecA283 PRE_first_tail_x15_r0_body.sizePreA283 PRE_first_tail_x15_r0_body.bodyPatchB283 (fun _ hm => bodyO1048 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1048).trans bodyInactive0) (bodyBr1049.trans bodyBr1048.symm) bodyCnt1048 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38818, 714, 0, 567⟩) bodyAcc1049 PRE_first_tail_x15_r0_body.bodyRunSeg283 bodyAcc1050 bodyHalt1050 PRE_first_tail_x15_r0_body.bodyStepA284 bodyTop1051 (fun _ hm => bodyO1049 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1049).trans bodyInactive0) (bodyBr1051.trans bodyBr1049.symm) bodyCnt1049 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
