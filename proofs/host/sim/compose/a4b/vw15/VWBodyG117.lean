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

kernel_rfl bodyO1123 : PRE_first_tail_x15_r0_body.S1123.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1123.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1123 : bridgeOf PRE_first_tail_x15_r0_body.s1123.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1123 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.S1123) = fun _ _ => true
kernel_rfl bodyAcc1125 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1125 PRE_first_tail_x15_r0_body.S1125) = fun _ _ => true
kernel_rfl bodyBr1126 : bridgeOf PRE_first_tail_x15_r0_body.s1126.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1125 : isHalt PRE_first_tail_x15_r0_body.s1125.ctl = false
kernel_rfl bodyTop1126 : noRetBlock PRE_first_tail_x15_r0_body.s1126 = true
kernel_rfl bodyCnt1123 : countersOkB PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.s1126 = true
kernel_rfl bodyO1126 : PRE_first_tail_x15_r0_body.S1126.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1126.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1127 : bridgeOf PRE_first_tail_x15_r0_body.s1127.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1126 : countersOkB PRE_first_tail_x15_r0_body.s1126 PRE_first_tail_x15_r0_body.s1127 = true
kernel_rfl bodyO1127 : PRE_first_tail_x15_r0_body.S1127.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1127.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1127 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1127 PRE_first_tail_x15_r0_body.S1127) = fun _ _ => true
kernel_rfl bodyAcc1129 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1129 PRE_first_tail_x15_r0_body.S1129) = fun _ _ => true
kernel_rfl bodyBr1130 : bridgeOf PRE_first_tail_x15_r0_body.s1130.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1129 : isHalt PRE_first_tail_x15_r0_body.s1129.ctl = false
kernel_rfl bodyTop1130 : noRetBlock PRE_first_tail_x15_r0_body.s1130 = true
kernel_rfl bodyCnt1127 : countersOkB PRE_first_tail_x15_r0_body.s1127 PRE_first_tail_x15_r0_body.s1130 = true
kernel_rfl bodyO1130 : PRE_first_tail_x15_r0_body.S1130.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1130.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1131 : bridgeOf PRE_first_tail_x15_r0_body.s1131.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1130 : countersOkB PRE_first_tail_x15_r0_body.s1130 PRE_first_tail_x15_r0_body.s1131 = true
kernel_rfl bodyO1131 : PRE_first_tail_x15_r0_body.S1131.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1131.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1131 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1131 PRE_first_tail_x15_r0_body.S1131) = fun _ _ => true
kernel_rfl bodyAcc1132 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1132 PRE_first_tail_x15_r0_body.S1132) = fun _ _ => true
kernel_rfl bodyBr1133 : bridgeOf PRE_first_tail_x15_r0_body.s1133.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1132 : isHalt PRE_first_tail_x15_r0_body.s1132.ctl = false
kernel_rfl bodyTop1133 : noRetBlock PRE_first_tail_x15_r0_body.s1133 = true
kernel_rfl bodyCnt1131 : countersOkB PRE_first_tail_x15_r0_body.s1131 PRE_first_tail_x15_r0_body.s1133 = true
kernel_rfl bodyO1133 : PRE_first_tail_x15_r0_body.S1133.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1133.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1134 : bridgeOf PRE_first_tail_x15_r0_body.s1134.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1133 : countersOkB PRE_first_tail_x15_r0_body.s1133 PRE_first_tail_x15_r0_body.s1134 = true
kernel_rfl bodyO1134 : PRE_first_tail_x15_r0_body.S1134.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1134.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1134 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1134 PRE_first_tail_x15_r0_body.S1134) = fun _ _ => true
kernel_rfl bodyAcc1136 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1136 PRE_first_tail_x15_r0_body.S1136) = fun _ _ => true
kernel_rfl bodyBr1137 : bridgeOf PRE_first_tail_x15_r0_body.s1137.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1136 : isHalt PRE_first_tail_x15_r0_body.s1136.ctl = false
kernel_rfl bodyTop1137 : noRetBlock PRE_first_tail_x15_r0_body.s1137 = true
kernel_rfl bodyCnt1134 : countersOkB PRE_first_tail_x15_r0_body.s1134 PRE_first_tail_x15_r0_body.s1137 = true

theorem bodyGlue117 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42301, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.S1123)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42301, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1137 PRE_first_tail_x15_r0_body.S1137) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42301, 789, 0, 621⟩) bodyAcc1123 PRE_first_tail_x15_r0_body.bodyRunSeg303 bodyAcc1125 bodyHalt1125 PRE_first_tail_x15_r0_body.bodyStepA304 bodyTop1126 (fun _ hm => bodyO1123 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1123).trans bodyInactive0) (bodyBr1126.trans bodyBr1123.symm) bodyCnt1123 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42301, 789, 0, 621⟩) PRE_first_tail_x15_r0_body.sizeA304 PRE_first_tail_x15_r0_body.sizeArgsA304 PRE_first_tail_x15_r0_body.sizeSymA304 PRE_first_tail_x15_r0_body.sizeMlxA304 PRE_first_tail_x15_r0_body.sizePayA304 PRE_first_tail_x15_r0_body.sizeTaA304 PRE_first_tail_x15_r0_body.sizeDecA304 PRE_first_tail_x15_r0_body.sizePreA304 PRE_first_tail_x15_r0_body.bodyPatchB304 (fun _ hm => bodyO1126 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1126).trans bodyInactive0) (bodyBr1127.trans bodyBr1126.symm) bodyCnt1126 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42301, 789, 0, 621⟩) bodyAcc1127 PRE_first_tail_x15_r0_body.bodyRunSeg304 bodyAcc1129 bodyHalt1129 PRE_first_tail_x15_r0_body.bodyStepA305 bodyTop1130 (fun _ hm => bodyO1127 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1127).trans bodyInactive0) (bodyBr1130.trans bodyBr1127.symm) bodyCnt1127 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42301, 789, 0, 621⟩) PRE_first_tail_x15_r0_body.sizeA305 PRE_first_tail_x15_r0_body.sizeArgsA305 PRE_first_tail_x15_r0_body.sizeSymA305 PRE_first_tail_x15_r0_body.sizeMlxA305 PRE_first_tail_x15_r0_body.sizePayA305 PRE_first_tail_x15_r0_body.sizeTaA305 PRE_first_tail_x15_r0_body.sizeDecA305 PRE_first_tail_x15_r0_body.sizePreA305 PRE_first_tail_x15_r0_body.bodyPatchB305 (fun _ hm => bodyO1130 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1130).trans bodyInactive0) (bodyBr1131.trans bodyBr1130.symm) bodyCnt1130 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42301, 789, 0, 621⟩) bodyAcc1131 PRE_first_tail_x15_r0_body.bodyRunSeg305 bodyAcc1132 bodyHalt1132 PRE_first_tail_x15_r0_body.bodyStepA306 bodyTop1133 (fun _ hm => bodyO1131 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1131).trans bodyInactive0) (bodyBr1133.trans bodyBr1131.symm) bodyCnt1131 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42301, 789, 0, 621⟩) PRE_first_tail_x15_r0_body.sizeA306 PRE_first_tail_x15_r0_body.sizeArgsA306 PRE_first_tail_x15_r0_body.sizeSymA306 PRE_first_tail_x15_r0_body.sizeMlxA306 PRE_first_tail_x15_r0_body.sizePayA306 PRE_first_tail_x15_r0_body.sizeTaA306 PRE_first_tail_x15_r0_body.sizeDecA306 PRE_first_tail_x15_r0_body.sizePreA306 PRE_first_tail_x15_r0_body.bodyPatchB306 (fun _ hm => bodyO1133 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1133).trans bodyInactive0) (bodyBr1134.trans bodyBr1133.symm) bodyCnt1133 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42301, 789, 0, 621⟩) bodyAcc1134 PRE_first_tail_x15_r0_body.bodyRunSeg306 bodyAcc1136 bodyHalt1136 PRE_first_tail_x15_r0_body.bodyStepA307 bodyTop1137 (fun _ hm => bodyO1134 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1134).trans bodyInactive0) (bodyBr1137.trans bodyBr1134.symm) bodyCnt1134 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
