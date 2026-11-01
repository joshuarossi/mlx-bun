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

kernel_rfl bodyO1094 : PRE_first_tail_x15_r0_body.S1094.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1094.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1094 : bridgeOf PRE_first_tail_x15_r0_body.s1094.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1094 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1094 PRE_first_tail_x15_r0_body.S1094) = fun _ _ => true
kernel_rfl bodyAcc1096 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1096 PRE_first_tail_x15_r0_body.S1096) = fun _ _ => true
kernel_rfl bodyBr1097 : bridgeOf PRE_first_tail_x15_r0_body.s1097.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1096 : isHalt PRE_first_tail_x15_r0_body.s1096.ctl = false
kernel_rfl bodyTop1097 : noRetBlock PRE_first_tail_x15_r0_body.s1097 = true
kernel_rfl bodyCnt1094 : countersOkB PRE_first_tail_x15_r0_body.s1094 PRE_first_tail_x15_r0_body.s1097 = true
kernel_rfl bodyO1097 : PRE_first_tail_x15_r0_body.S1097.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1097.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1098 : bridgeOf PRE_first_tail_x15_r0_body.s1098.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1097 : countersOkB PRE_first_tail_x15_r0_body.s1097 PRE_first_tail_x15_r0_body.s1098 = true
kernel_rfl bodyO1098 : PRE_first_tail_x15_r0_body.S1098.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1098.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1098 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1098 PRE_first_tail_x15_r0_body.S1098) = fun _ _ => true
kernel_rfl bodyAcc1099 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1099 PRE_first_tail_x15_r0_body.S1099) = fun _ _ => true
kernel_rfl bodyBr1100 : bridgeOf PRE_first_tail_x15_r0_body.s1100.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1099 : isHalt PRE_first_tail_x15_r0_body.s1099.ctl = false
kernel_rfl bodyTop1100 : noRetBlock PRE_first_tail_x15_r0_body.s1100 = true
kernel_rfl bodyCnt1098 : countersOkB PRE_first_tail_x15_r0_body.s1098 PRE_first_tail_x15_r0_body.s1100 = true
kernel_rfl bodyO1100 : PRE_first_tail_x15_r0_body.S1100.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1100.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1101 : bridgeOf PRE_first_tail_x15_r0_body.s1101.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1100 : countersOkB PRE_first_tail_x15_r0_body.s1100 PRE_first_tail_x15_r0_body.s1101 = true
kernel_rfl bodyO1101 : PRE_first_tail_x15_r0_body.S1101.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1101.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1101 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1101 PRE_first_tail_x15_r0_body.S1101) = fun _ _ => true
kernel_rfl bodyAcc1102 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1102 PRE_first_tail_x15_r0_body.S1102) = fun _ _ => true
kernel_rfl bodyBr1103 : bridgeOf PRE_first_tail_x15_r0_body.s1103.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1102 : isHalt PRE_first_tail_x15_r0_body.s1102.ctl = false
kernel_rfl bodyTop1103 : noRetBlock PRE_first_tail_x15_r0_body.s1103 = true
kernel_rfl bodyCnt1101 : countersOkB PRE_first_tail_x15_r0_body.s1101 PRE_first_tail_x15_r0_body.s1103 = true
kernel_rfl bodyO1103 : PRE_first_tail_x15_r0_body.S1103.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1103.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1104 : bridgeOf PRE_first_tail_x15_r0_body.s1104.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1103 : countersOkB PRE_first_tail_x15_r0_body.s1103 PRE_first_tail_x15_r0_body.s1104 = true
kernel_rfl bodyO1104 : PRE_first_tail_x15_r0_body.S1104.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1104.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1104 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1104 PRE_first_tail_x15_r0_body.S1104) = fun _ _ => true
kernel_rfl bodyAcc1105 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1105 PRE_first_tail_x15_r0_body.S1105) = fun _ _ => true
kernel_rfl bodyBr1106 : bridgeOf PRE_first_tail_x15_r0_body.s1106.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1105 : isHalt PRE_first_tail_x15_r0_body.s1105.ctl = false
kernel_rfl bodyTop1106 : noRetBlock PRE_first_tail_x15_r0_body.s1106 = true
kernel_rfl bodyCnt1104 : countersOkB PRE_first_tail_x15_r0_body.s1104 PRE_first_tail_x15_r0_body.s1106 = true
kernel_rfl bodyO1106 : PRE_first_tail_x15_r0_body.S1106.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1106.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1107 : bridgeOf PRE_first_tail_x15_r0_body.s1107.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1106 : countersOkB PRE_first_tail_x15_r0_body.s1106 PRE_first_tail_x15_r0_body.s1107 = true
kernel_rfl bodyO1107 : PRE_first_tail_x15_r0_body.S1107.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1107.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1107 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1107 PRE_first_tail_x15_r0_body.S1107) = fun _ _ => true
kernel_rfl bodyAcc1108 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1108 PRE_first_tail_x15_r0_body.S1108) = fun _ _ => true
kernel_rfl bodyBr1109 : bridgeOf PRE_first_tail_x15_r0_body.s1109.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1108 : isHalt PRE_first_tail_x15_r0_body.s1108.ctl = false
kernel_rfl bodyTop1109 : noRetBlock PRE_first_tail_x15_r0_body.s1109 = true
kernel_rfl bodyCnt1107 : countersOkB PRE_first_tail_x15_r0_body.s1107 PRE_first_tail_x15_r0_body.s1109 = true

theorem bodyGlue114 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨41140, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1094 PRE_first_tail_x15_r0_body.S1094)
      (bodyCut NB T tk π i x0 bodyΘ ⟨41140, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1109 PRE_first_tail_x15_r0_body.S1109) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) bodyAcc1094 PRE_first_tail_x15_r0_body.bodyRunSeg295 bodyAcc1096 bodyHalt1096 PRE_first_tail_x15_r0_body.bodyStepA296 bodyTop1097 (fun _ hm => bodyO1094 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1094).trans bodyInactive0) (bodyBr1097.trans bodyBr1094.symm) bodyCnt1094 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) PRE_first_tail_x15_r0_body.sizeA296 PRE_first_tail_x15_r0_body.sizeArgsA296 PRE_first_tail_x15_r0_body.sizeSymA296 PRE_first_tail_x15_r0_body.sizeMlxA296 PRE_first_tail_x15_r0_body.sizePayA296 PRE_first_tail_x15_r0_body.sizeTaA296 PRE_first_tail_x15_r0_body.sizeDecA296 PRE_first_tail_x15_r0_body.sizePreA296 PRE_first_tail_x15_r0_body.bodyPatchB296 (fun _ hm => bodyO1097 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1097).trans bodyInactive0) (bodyBr1098.trans bodyBr1097.symm) bodyCnt1097 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) bodyAcc1098 PRE_first_tail_x15_r0_body.bodyRunSeg296 bodyAcc1099 bodyHalt1099 PRE_first_tail_x15_r0_body.bodyStepA297 bodyTop1100 (fun _ hm => bodyO1098 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1098).trans bodyInactive0) (bodyBr1100.trans bodyBr1098.symm) bodyCnt1098 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) PRE_first_tail_x15_r0_body.sizeA297 PRE_first_tail_x15_r0_body.sizeArgsA297 PRE_first_tail_x15_r0_body.sizeSymA297 PRE_first_tail_x15_r0_body.sizeMlxA297 PRE_first_tail_x15_r0_body.sizePayA297 PRE_first_tail_x15_r0_body.sizeTaA297 PRE_first_tail_x15_r0_body.sizeDecA297 PRE_first_tail_x15_r0_body.sizePreA297 PRE_first_tail_x15_r0_body.bodyPatchB297 (fun _ hm => bodyO1100 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1100).trans bodyInactive0) (bodyBr1101.trans bodyBr1100.symm) bodyCnt1100 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) bodyAcc1101 PRE_first_tail_x15_r0_body.bodyRunSeg297 bodyAcc1102 bodyHalt1102 PRE_first_tail_x15_r0_body.bodyStepA298 bodyTop1103 (fun _ hm => bodyO1101 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1101).trans bodyInactive0) (bodyBr1103.trans bodyBr1101.symm) bodyCnt1101 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) PRE_first_tail_x15_r0_body.sizeA298 PRE_first_tail_x15_r0_body.sizeArgsA298 PRE_first_tail_x15_r0_body.sizeSymA298 PRE_first_tail_x15_r0_body.sizeMlxA298 PRE_first_tail_x15_r0_body.sizePayA298 PRE_first_tail_x15_r0_body.sizeTaA298 PRE_first_tail_x15_r0_body.sizeDecA298 PRE_first_tail_x15_r0_body.sizePreA298 PRE_first_tail_x15_r0_body.bodyPatchB298 (fun _ hm => bodyO1103 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1103).trans bodyInactive0) (bodyBr1104.trans bodyBr1103.symm) bodyCnt1103 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) bodyAcc1104 PRE_first_tail_x15_r0_body.bodyRunSeg298 bodyAcc1105 bodyHalt1105 PRE_first_tail_x15_r0_body.bodyStepA299 bodyTop1106 (fun _ hm => bodyO1104 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1104).trans bodyInactive0) (bodyBr1106.trans bodyBr1104.symm) bodyCnt1104 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) PRE_first_tail_x15_r0_body.sizeA299 PRE_first_tail_x15_r0_body.sizeArgsA299 PRE_first_tail_x15_r0_body.sizeSymA299 PRE_first_tail_x15_r0_body.sizeMlxA299 PRE_first_tail_x15_r0_body.sizePayA299 PRE_first_tail_x15_r0_body.sizeTaA299 PRE_first_tail_x15_r0_body.sizeDecA299 PRE_first_tail_x15_r0_body.sizePreA299 PRE_first_tail_x15_r0_body.bodyPatchB299 (fun _ hm => bodyO1106 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1106).trans bodyInactive0) (bodyBr1107.trans bodyBr1106.symm) bodyCnt1106 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41140, 764, 0, 603⟩) bodyAcc1107 PRE_first_tail_x15_r0_body.bodyRunSeg299 bodyAcc1108 bodyHalt1108 PRE_first_tail_x15_r0_body.bodyStepA300 bodyTop1109 (fun _ hm => bodyO1107 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1107).trans bodyInactive0) (bodyBr1109.trans bodyBr1107.symm) bodyCnt1107 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
