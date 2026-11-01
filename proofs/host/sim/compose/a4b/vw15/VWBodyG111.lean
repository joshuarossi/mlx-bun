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

kernel_rfl bodyO1065 : PRE_first_tail_x15_r0_body.S1065.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1065.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1065 : bridgeOf PRE_first_tail_x15_r0_body.s1065.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1065 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1065 PRE_first_tail_x15_r0_body.S1065) = fun _ _ => true
kernel_rfl bodyAcc1067 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1067 PRE_first_tail_x15_r0_body.S1067) = fun _ _ => true
kernel_rfl bodyBr1068 : bridgeOf PRE_first_tail_x15_r0_body.s1068.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1067 : isHalt PRE_first_tail_x15_r0_body.s1067.ctl = false
kernel_rfl bodyTop1068 : noRetBlock PRE_first_tail_x15_r0_body.s1068 = true
kernel_rfl bodyCnt1065 : countersOkB PRE_first_tail_x15_r0_body.s1065 PRE_first_tail_x15_r0_body.s1068 = true
kernel_rfl bodyO1068 : PRE_first_tail_x15_r0_body.S1068.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1068.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1069 : bridgeOf PRE_first_tail_x15_r0_body.s1069.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1068 : countersOkB PRE_first_tail_x15_r0_body.s1068 PRE_first_tail_x15_r0_body.s1069 = true
kernel_rfl bodyO1069 : PRE_first_tail_x15_r0_body.S1069.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1069.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1069 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1069 PRE_first_tail_x15_r0_body.S1069) = fun _ _ => true
kernel_rfl bodyAcc1070 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1070 PRE_first_tail_x15_r0_body.S1070) = fun _ _ => true
kernel_rfl bodyBr1071 : bridgeOf PRE_first_tail_x15_r0_body.s1071.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1070 : isHalt PRE_first_tail_x15_r0_body.s1070.ctl = false
kernel_rfl bodyTop1071 : noRetBlock PRE_first_tail_x15_r0_body.s1071 = true
kernel_rfl bodyCnt1069 : countersOkB PRE_first_tail_x15_r0_body.s1069 PRE_first_tail_x15_r0_body.s1071 = true
kernel_rfl bodyO1071 : PRE_first_tail_x15_r0_body.S1071.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1071.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1072 : bridgeOf PRE_first_tail_x15_r0_body.s1072.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1071 : countersOkB PRE_first_tail_x15_r0_body.s1071 PRE_first_tail_x15_r0_body.s1072 = true
kernel_rfl bodyO1072 : PRE_first_tail_x15_r0_body.S1072.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1072.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1072 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1072 PRE_first_tail_x15_r0_body.S1072) = fun _ _ => true
kernel_rfl bodyAcc1073 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1073 PRE_first_tail_x15_r0_body.S1073) = fun _ _ => true
kernel_rfl bodyBr1074 : bridgeOf PRE_first_tail_x15_r0_body.s1074.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1073 : isHalt PRE_first_tail_x15_r0_body.s1073.ctl = false
kernel_rfl bodyTop1074 : noRetBlock PRE_first_tail_x15_r0_body.s1074 = true
kernel_rfl bodyCnt1072 : countersOkB PRE_first_tail_x15_r0_body.s1072 PRE_first_tail_x15_r0_body.s1074 = true
kernel_rfl bodyO1074 : PRE_first_tail_x15_r0_body.S1074.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1074.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1075 : bridgeOf PRE_first_tail_x15_r0_body.s1075.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1074 : countersOkB PRE_first_tail_x15_r0_body.s1074 PRE_first_tail_x15_r0_body.s1075 = true
kernel_rfl bodyO1075 : PRE_first_tail_x15_r0_body.S1075.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1075.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1075 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1075 PRE_first_tail_x15_r0_body.S1075) = fun _ _ => true
kernel_rfl bodyAcc1076 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1076 PRE_first_tail_x15_r0_body.S1076) = fun _ _ => true
kernel_rfl bodyBr1077 : bridgeOf PRE_first_tail_x15_r0_body.s1077.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1076 : isHalt PRE_first_tail_x15_r0_body.s1076.ctl = false
kernel_rfl bodyTop1077 : noRetBlock PRE_first_tail_x15_r0_body.s1077 = true
kernel_rfl bodyCnt1075 : countersOkB PRE_first_tail_x15_r0_body.s1075 PRE_first_tail_x15_r0_body.s1077 = true
kernel_rfl bodyO1077 : PRE_first_tail_x15_r0_body.S1077.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1077.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1078 : bridgeOf PRE_first_tail_x15_r0_body.s1078.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1077 : countersOkB PRE_first_tail_x15_r0_body.s1077 PRE_first_tail_x15_r0_body.s1078 = true
kernel_rfl bodyO1078 : PRE_first_tail_x15_r0_body.S1078.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1078.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1078 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1078 PRE_first_tail_x15_r0_body.S1078) = fun _ _ => true
kernel_rfl bodyAcc1079 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1079 PRE_first_tail_x15_r0_body.S1079) = fun _ _ => true
kernel_rfl bodyBr1080 : bridgeOf PRE_first_tail_x15_r0_body.s1080.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1079 : isHalt PRE_first_tail_x15_r0_body.s1079.ctl = false
kernel_rfl bodyTop1080 : noRetBlock PRE_first_tail_x15_r0_body.s1080 = true
kernel_rfl bodyCnt1078 : countersOkB PRE_first_tail_x15_r0_body.s1078 PRE_first_tail_x15_r0_body.s1080 = true

theorem bodyGlue111 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨39979, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1065 PRE_first_tail_x15_r0_body.S1065)
      (bodyCut NB T tk π i x0 bodyΘ ⟨39979, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1080 PRE_first_tail_x15_r0_body.S1080) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) bodyAcc1065 PRE_first_tail_x15_r0_body.bodyRunSeg287 bodyAcc1067 bodyHalt1067 PRE_first_tail_x15_r0_body.bodyStepA288 bodyTop1068 (fun _ hm => bodyO1065 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1065).trans bodyInactive0) (bodyBr1068.trans bodyBr1065.symm) bodyCnt1065 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) PRE_first_tail_x15_r0_body.sizeA288 PRE_first_tail_x15_r0_body.sizeArgsA288 PRE_first_tail_x15_r0_body.sizeSymA288 PRE_first_tail_x15_r0_body.sizeMlxA288 PRE_first_tail_x15_r0_body.sizePayA288 PRE_first_tail_x15_r0_body.sizeTaA288 PRE_first_tail_x15_r0_body.sizeDecA288 PRE_first_tail_x15_r0_body.sizePreA288 PRE_first_tail_x15_r0_body.bodyPatchB288 (fun _ hm => bodyO1068 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1068).trans bodyInactive0) (bodyBr1069.trans bodyBr1068.symm) bodyCnt1068 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) bodyAcc1069 PRE_first_tail_x15_r0_body.bodyRunSeg288 bodyAcc1070 bodyHalt1070 PRE_first_tail_x15_r0_body.bodyStepA289 bodyTop1071 (fun _ hm => bodyO1069 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1069).trans bodyInactive0) (bodyBr1071.trans bodyBr1069.symm) bodyCnt1069 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) PRE_first_tail_x15_r0_body.sizeA289 PRE_first_tail_x15_r0_body.sizeArgsA289 PRE_first_tail_x15_r0_body.sizeSymA289 PRE_first_tail_x15_r0_body.sizeMlxA289 PRE_first_tail_x15_r0_body.sizePayA289 PRE_first_tail_x15_r0_body.sizeTaA289 PRE_first_tail_x15_r0_body.sizeDecA289 PRE_first_tail_x15_r0_body.sizePreA289 PRE_first_tail_x15_r0_body.bodyPatchB289 (fun _ hm => bodyO1071 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1071).trans bodyInactive0) (bodyBr1072.trans bodyBr1071.symm) bodyCnt1071 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) bodyAcc1072 PRE_first_tail_x15_r0_body.bodyRunSeg289 bodyAcc1073 bodyHalt1073 PRE_first_tail_x15_r0_body.bodyStepA290 bodyTop1074 (fun _ hm => bodyO1072 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1072).trans bodyInactive0) (bodyBr1074.trans bodyBr1072.symm) bodyCnt1072 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) PRE_first_tail_x15_r0_body.sizeA290 PRE_first_tail_x15_r0_body.sizeArgsA290 PRE_first_tail_x15_r0_body.sizeSymA290 PRE_first_tail_x15_r0_body.sizeMlxA290 PRE_first_tail_x15_r0_body.sizePayA290 PRE_first_tail_x15_r0_body.sizeTaA290 PRE_first_tail_x15_r0_body.sizeDecA290 PRE_first_tail_x15_r0_body.sizePreA290 PRE_first_tail_x15_r0_body.bodyPatchB290 (fun _ hm => bodyO1074 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1074).trans bodyInactive0) (bodyBr1075.trans bodyBr1074.symm) bodyCnt1074 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) bodyAcc1075 PRE_first_tail_x15_r0_body.bodyRunSeg290 bodyAcc1076 bodyHalt1076 PRE_first_tail_x15_r0_body.bodyStepA291 bodyTop1077 (fun _ hm => bodyO1075 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1075).trans bodyInactive0) (bodyBr1077.trans bodyBr1075.symm) bodyCnt1075 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) PRE_first_tail_x15_r0_body.sizeA291 PRE_first_tail_x15_r0_body.sizeArgsA291 PRE_first_tail_x15_r0_body.sizeSymA291 PRE_first_tail_x15_r0_body.sizeMlxA291 PRE_first_tail_x15_r0_body.sizePayA291 PRE_first_tail_x15_r0_body.sizeTaA291 PRE_first_tail_x15_r0_body.sizeDecA291 PRE_first_tail_x15_r0_body.sizePreA291 PRE_first_tail_x15_r0_body.bodyPatchB291 (fun _ hm => bodyO1077 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1077).trans bodyInactive0) (bodyBr1078.trans bodyBr1077.symm) bodyCnt1077 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39979, 739, 0, 585⟩) bodyAcc1078 PRE_first_tail_x15_r0_body.bodyRunSeg291 bodyAcc1079 bodyHalt1079 PRE_first_tail_x15_r0_body.bodyStepA292 bodyTop1080 (fun _ hm => bodyO1078 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1078).trans bodyInactive0) (bodyBr1080.trans bodyBr1078.symm) bodyCnt1078 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
