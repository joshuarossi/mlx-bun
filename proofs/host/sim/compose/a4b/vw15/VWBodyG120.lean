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

kernel_rfl bodyO1151 : PRE_first_tail_x15_r0_body.S1151.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1151.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1151 : bridgeOf PRE_first_tail_x15_r0_body.s1151.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1151 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1151 PRE_first_tail_x15_r0_body.S1151) = fun _ _ => true
kernel_rfl bodyAcc1153 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1153 PRE_first_tail_x15_r0_body.S1153) = fun _ _ => true
kernel_rfl bodyBr1154 : bridgeOf PRE_first_tail_x15_r0_body.s1154.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1153 : isHalt PRE_first_tail_x15_r0_body.s1153.ctl = false
kernel_rfl bodyTop1154 : noRetBlock PRE_first_tail_x15_r0_body.s1154 = true
kernel_rfl bodyCnt1151 : countersOkB PRE_first_tail_x15_r0_body.s1151 PRE_first_tail_x15_r0_body.s1154 = true
kernel_rfl bodyO1154 : PRE_first_tail_x15_r0_body.S1154.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1154.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1155 : bridgeOf PRE_first_tail_x15_r0_body.s1155.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1154 : countersOkB PRE_first_tail_x15_r0_body.s1154 PRE_first_tail_x15_r0_body.s1155 = true
kernel_rfl bodyO1155 : PRE_first_tail_x15_r0_body.S1155.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1155.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1155 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1155 PRE_first_tail_x15_r0_body.S1155) = fun _ _ => true
kernel_rfl bodyAcc1156 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1156 PRE_first_tail_x15_r0_body.S1156) = fun _ _ => true
kernel_rfl bodyBr1157 : bridgeOf PRE_first_tail_x15_r0_body.s1157.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1156 : isHalt PRE_first_tail_x15_r0_body.s1156.ctl = false
kernel_rfl bodyTop1157 : noRetBlock PRE_first_tail_x15_r0_body.s1157 = true
kernel_rfl bodyCnt1155 : countersOkB PRE_first_tail_x15_r0_body.s1155 PRE_first_tail_x15_r0_body.s1157 = true
kernel_rfl bodyO1157 : PRE_first_tail_x15_r0_body.S1157.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1157.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1158 : bridgeOf PRE_first_tail_x15_r0_body.s1158.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1157 : countersOkB PRE_first_tail_x15_r0_body.s1157 PRE_first_tail_x15_r0_body.s1158 = true
kernel_rfl bodyO1158 : PRE_first_tail_x15_r0_body.S1158.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1158.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1158 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1158 PRE_first_tail_x15_r0_body.S1158) = fun _ _ => true
kernel_rfl bodyAcc1159 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1159 PRE_first_tail_x15_r0_body.S1159) = fun _ _ => true
kernel_rfl bodyBr1160 : bridgeOf PRE_first_tail_x15_r0_body.s1160.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1159 : isHalt PRE_first_tail_x15_r0_body.s1159.ctl = false
kernel_rfl bodyTop1160 : noRetBlock PRE_first_tail_x15_r0_body.s1160 = true
kernel_rfl bodyCnt1158 : countersOkB PRE_first_tail_x15_r0_body.s1158 PRE_first_tail_x15_r0_body.s1160 = true
kernel_rfl bodyO1160 : PRE_first_tail_x15_r0_body.S1160.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1160.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1161 : bridgeOf PRE_first_tail_x15_r0_body.s1161.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1160 : countersOkB PRE_first_tail_x15_r0_body.s1160 PRE_first_tail_x15_r0_body.s1161 = true
kernel_rfl bodyO1161 : PRE_first_tail_x15_r0_body.S1161.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1161.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1161 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1161 PRE_first_tail_x15_r0_body.S1161) = fun _ _ => true
kernel_rfl bodyAcc1162 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1162 PRE_first_tail_x15_r0_body.S1162) = fun _ _ => true
kernel_rfl bodyBr1163 : bridgeOf PRE_first_tail_x15_r0_body.s1163.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1162 : isHalt PRE_first_tail_x15_r0_body.s1162.ctl = false
kernel_rfl bodyTop1163 : noRetBlock PRE_first_tail_x15_r0_body.s1163 = true
kernel_rfl bodyCnt1161 : countersOkB PRE_first_tail_x15_r0_body.s1161 PRE_first_tail_x15_r0_body.s1163 = true
kernel_rfl bodyO1163 : PRE_first_tail_x15_r0_body.S1163.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1163.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1164 : bridgeOf PRE_first_tail_x15_r0_body.s1164.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1163 : countersOkB PRE_first_tail_x15_r0_body.s1163 PRE_first_tail_x15_r0_body.s1164 = true
kernel_rfl bodyO1164 : PRE_first_tail_x15_r0_body.S1164.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1164.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1164 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1164 PRE_first_tail_x15_r0_body.S1164) = fun _ _ => true
kernel_rfl bodyAcc1165 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1165 PRE_first_tail_x15_r0_body.S1165) = fun _ _ => true
kernel_rfl bodyBr1166 : bridgeOf PRE_first_tail_x15_r0_body.s1166.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1165 : isHalt PRE_first_tail_x15_r0_body.s1165.ctl = false
kernel_rfl bodyTop1166 : noRetBlock PRE_first_tail_x15_r0_body.s1166 = true
kernel_rfl bodyCnt1164 : countersOkB PRE_first_tail_x15_r0_body.s1164 PRE_first_tail_x15_r0_body.s1166 = true

theorem bodyGlue120 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42663, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1151 PRE_first_tail_x15_r0_body.S1151)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42663, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1166 PRE_first_tail_x15_r0_body.S1166) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) bodyAcc1151 PRE_first_tail_x15_r0_body.bodyRunSeg310 bodyAcc1153 bodyHalt1153 PRE_first_tail_x15_r0_body.bodyStepA311 bodyTop1154 (fun _ hm => bodyO1151 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1151).trans bodyInactive0) (bodyBr1154.trans bodyBr1151.symm) bodyCnt1151 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) PRE_first_tail_x15_r0_body.sizeA311 PRE_first_tail_x15_r0_body.sizeArgsA311 PRE_first_tail_x15_r0_body.sizeSymA311 PRE_first_tail_x15_r0_body.sizeMlxA311 PRE_first_tail_x15_r0_body.sizePayA311 PRE_first_tail_x15_r0_body.sizeTaA311 PRE_first_tail_x15_r0_body.sizeDecA311 PRE_first_tail_x15_r0_body.sizePreA311 PRE_first_tail_x15_r0_body.bodyPatchB311 (fun _ hm => bodyO1154 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1154).trans bodyInactive0) (bodyBr1155.trans bodyBr1154.symm) bodyCnt1154 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) bodyAcc1155 PRE_first_tail_x15_r0_body.bodyRunSeg311 bodyAcc1156 bodyHalt1156 PRE_first_tail_x15_r0_body.bodyStepA312 bodyTop1157 (fun _ hm => bodyO1155 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1155).trans bodyInactive0) (bodyBr1157.trans bodyBr1155.symm) bodyCnt1155 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) PRE_first_tail_x15_r0_body.sizeA312 PRE_first_tail_x15_r0_body.sizeArgsA312 PRE_first_tail_x15_r0_body.sizeSymA312 PRE_first_tail_x15_r0_body.sizeMlxA312 PRE_first_tail_x15_r0_body.sizePayA312 PRE_first_tail_x15_r0_body.sizeTaA312 PRE_first_tail_x15_r0_body.sizeDecA312 PRE_first_tail_x15_r0_body.sizePreA312 PRE_first_tail_x15_r0_body.bodyPatchB312 (fun _ hm => bodyO1157 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1157).trans bodyInactive0) (bodyBr1158.trans bodyBr1157.symm) bodyCnt1157 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) bodyAcc1158 PRE_first_tail_x15_r0_body.bodyRunSeg312 bodyAcc1159 bodyHalt1159 PRE_first_tail_x15_r0_body.bodyStepA313 bodyTop1160 (fun _ hm => bodyO1158 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1158).trans bodyInactive0) (bodyBr1160.trans bodyBr1158.symm) bodyCnt1158 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) PRE_first_tail_x15_r0_body.sizeA313 PRE_first_tail_x15_r0_body.sizeArgsA313 PRE_first_tail_x15_r0_body.sizeSymA313 PRE_first_tail_x15_r0_body.sizeMlxA313 PRE_first_tail_x15_r0_body.sizePayA313 PRE_first_tail_x15_r0_body.sizeTaA313 PRE_first_tail_x15_r0_body.sizeDecA313 PRE_first_tail_x15_r0_body.sizePreA313 PRE_first_tail_x15_r0_body.bodyPatchB313 (fun _ hm => bodyO1160 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1160).trans bodyInactive0) (bodyBr1161.trans bodyBr1160.symm) bodyCnt1160 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) bodyAcc1161 PRE_first_tail_x15_r0_body.bodyRunSeg313 bodyAcc1162 bodyHalt1162 PRE_first_tail_x15_r0_body.bodyStepA314 bodyTop1163 (fun _ hm => bodyO1161 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1161).trans bodyInactive0) (bodyBr1163.trans bodyBr1161.symm) bodyCnt1161 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) PRE_first_tail_x15_r0_body.sizeA314 PRE_first_tail_x15_r0_body.sizeArgsA314 PRE_first_tail_x15_r0_body.sizeSymA314 PRE_first_tail_x15_r0_body.sizeMlxA314 PRE_first_tail_x15_r0_body.sizePayA314 PRE_first_tail_x15_r0_body.sizeTaA314 PRE_first_tail_x15_r0_body.sizeDecA314 PRE_first_tail_x15_r0_body.sizePreA314 PRE_first_tail_x15_r0_body.bodyPatchB314 (fun _ hm => bodyO1163 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1163).trans bodyInactive0) (bodyBr1164.trans bodyBr1163.symm) bodyCnt1163 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42663, 791, 0, 630⟩) bodyAcc1164 PRE_first_tail_x15_r0_body.bodyRunSeg314 bodyAcc1165 bodyHalt1165 PRE_first_tail_x15_r0_body.bodyStepA315 bodyTop1166 (fun _ hm => bodyO1164 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1164).trans bodyInactive0) (bodyBr1166.trans bodyBr1164.symm) bodyCnt1164 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
