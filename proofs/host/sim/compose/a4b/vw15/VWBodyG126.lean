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

kernel_rfl bodyO1209 : PRE_first_tail_x15_r0_body.S1209.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1209.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1209 : bridgeOf PRE_first_tail_x15_r0_body.s1209.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1209 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.S1209) = fun _ _ => true
kernel_rfl bodyAcc1211 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1211 PRE_first_tail_x15_r0_body.S1211) = fun _ _ => true
kernel_rfl bodyBr1212 : bridgeOf PRE_first_tail_x15_r0_body.s1212.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1211 : isHalt PRE_first_tail_x15_r0_body.s1211.ctl = false
kernel_rfl bodyTop1212 : noRetBlock PRE_first_tail_x15_r0_body.s1212 = true
kernel_rfl bodyCnt1209 : countersOkB PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.s1212 = true
kernel_rfl bodyO1212 : PRE_first_tail_x15_r0_body.S1212.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1212.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1213 : bridgeOf PRE_first_tail_x15_r0_body.s1213.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1212 : countersOkB PRE_first_tail_x15_r0_body.s1212 PRE_first_tail_x15_r0_body.s1213 = true
kernel_rfl bodyO1213 : PRE_first_tail_x15_r0_body.S1213.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1213.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1213 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1213 PRE_first_tail_x15_r0_body.S1213) = fun _ _ => true
kernel_rfl bodyAcc1214 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1214 PRE_first_tail_x15_r0_body.S1214) = fun _ _ => true
kernel_rfl bodyBr1215 : bridgeOf PRE_first_tail_x15_r0_body.s1215.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1214 : isHalt PRE_first_tail_x15_r0_body.s1214.ctl = false
kernel_rfl bodyTop1215 : noRetBlock PRE_first_tail_x15_r0_body.s1215 = true
kernel_rfl bodyCnt1213 : countersOkB PRE_first_tail_x15_r0_body.s1213 PRE_first_tail_x15_r0_body.s1215 = true
kernel_rfl bodyO1215 : PRE_first_tail_x15_r0_body.S1215.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1215.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1216 : bridgeOf PRE_first_tail_x15_r0_body.s1216.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1215 : countersOkB PRE_first_tail_x15_r0_body.s1215 PRE_first_tail_x15_r0_body.s1216 = true
kernel_rfl bodyO1216 : PRE_first_tail_x15_r0_body.S1216.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1216.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1216 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1216 PRE_first_tail_x15_r0_body.S1216) = fun _ _ => true
kernel_rfl bodyAcc1217 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1217 PRE_first_tail_x15_r0_body.S1217) = fun _ _ => true
kernel_rfl bodyBr1218 : bridgeOf PRE_first_tail_x15_r0_body.s1218.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1217 : isHalt PRE_first_tail_x15_r0_body.s1217.ctl = false
kernel_rfl bodyTop1218 : noRetBlock PRE_first_tail_x15_r0_body.s1218 = true
kernel_rfl bodyCnt1216 : countersOkB PRE_first_tail_x15_r0_body.s1216 PRE_first_tail_x15_r0_body.s1218 = true
kernel_rfl bodyO1218 : PRE_first_tail_x15_r0_body.S1218.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1218.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1219 : bridgeOf PRE_first_tail_x15_r0_body.s1219.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1218 : countersOkB PRE_first_tail_x15_r0_body.s1218 PRE_first_tail_x15_r0_body.s1219 = true
kernel_rfl bodyO1219 : PRE_first_tail_x15_r0_body.S1219.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1219.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1219 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1219 PRE_first_tail_x15_r0_body.S1219) = fun _ _ => true
kernel_rfl bodyAcc1220 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1220 PRE_first_tail_x15_r0_body.S1220) = fun _ _ => true
kernel_rfl bodyBr1221 : bridgeOf PRE_first_tail_x15_r0_body.s1221.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1220 : isHalt PRE_first_tail_x15_r0_body.s1220.ctl = false
kernel_rfl bodyTop1221 : noRetBlock PRE_first_tail_x15_r0_body.s1221 = true
kernel_rfl bodyCnt1219 : countersOkB PRE_first_tail_x15_r0_body.s1219 PRE_first_tail_x15_r0_body.s1221 = true
kernel_rfl bodyO1221 : PRE_first_tail_x15_r0_body.S1221.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1221.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1222 : bridgeOf PRE_first_tail_x15_r0_body.s1222.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1221 : countersOkB PRE_first_tail_x15_r0_body.s1221 PRE_first_tail_x15_r0_body.s1222 = true
kernel_rfl bodyO1222 : PRE_first_tail_x15_r0_body.S1222.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1222.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1222 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1222 PRE_first_tail_x15_r0_body.S1222) = fun _ _ => true
kernel_rfl bodyAcc1223 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1223 PRE_first_tail_x15_r0_body.S1223) = fun _ _ => true
kernel_rfl bodyBr1224 : bridgeOf PRE_first_tail_x15_r0_body.s1224.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1223 : isHalt PRE_first_tail_x15_r0_body.s1223.ctl = false
kernel_rfl bodyTop1224 : noRetBlock PRE_first_tail_x15_r0_body.s1224 = true
kernel_rfl bodyCnt1222 : countersOkB PRE_first_tail_x15_r0_body.s1222 PRE_first_tail_x15_r0_body.s1224 = true

theorem bodyGlue126 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨44985, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.S1209)
      (bodyCut NB T tk π i x0 bodyΘ ⟨44985, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1224 PRE_first_tail_x15_r0_body.S1224) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) bodyAcc1209 PRE_first_tail_x15_r0_body.bodyRunSeg326 bodyAcc1211 bodyHalt1211 PRE_first_tail_x15_r0_body.bodyStepA327 bodyTop1212 (fun _ hm => bodyO1209 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1209).trans bodyInactive0) (bodyBr1212.trans bodyBr1209.symm) bodyCnt1209 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) PRE_first_tail_x15_r0_body.sizeA327 PRE_first_tail_x15_r0_body.sizeArgsA327 PRE_first_tail_x15_r0_body.sizeSymA327 PRE_first_tail_x15_r0_body.sizeMlxA327 PRE_first_tail_x15_r0_body.sizePayA327 PRE_first_tail_x15_r0_body.sizeTaA327 PRE_first_tail_x15_r0_body.sizeDecA327 PRE_first_tail_x15_r0_body.sizePreA327 PRE_first_tail_x15_r0_body.bodyPatchB327 (fun _ hm => bodyO1212 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1212).trans bodyInactive0) (bodyBr1213.trans bodyBr1212.symm) bodyCnt1212 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) bodyAcc1213 PRE_first_tail_x15_r0_body.bodyRunSeg327 bodyAcc1214 bodyHalt1214 PRE_first_tail_x15_r0_body.bodyStepA328 bodyTop1215 (fun _ hm => bodyO1213 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1213).trans bodyInactive0) (bodyBr1215.trans bodyBr1213.symm) bodyCnt1213 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) PRE_first_tail_x15_r0_body.sizeA328 PRE_first_tail_x15_r0_body.sizeArgsA328 PRE_first_tail_x15_r0_body.sizeSymA328 PRE_first_tail_x15_r0_body.sizeMlxA328 PRE_first_tail_x15_r0_body.sizePayA328 PRE_first_tail_x15_r0_body.sizeTaA328 PRE_first_tail_x15_r0_body.sizeDecA328 PRE_first_tail_x15_r0_body.sizePreA328 PRE_first_tail_x15_r0_body.bodyPatchB328 (fun _ hm => bodyO1215 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1215).trans bodyInactive0) (bodyBr1216.trans bodyBr1215.symm) bodyCnt1215 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) bodyAcc1216 PRE_first_tail_x15_r0_body.bodyRunSeg328 bodyAcc1217 bodyHalt1217 PRE_first_tail_x15_r0_body.bodyStepA329 bodyTop1218 (fun _ hm => bodyO1216 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1216).trans bodyInactive0) (bodyBr1218.trans bodyBr1216.symm) bodyCnt1216 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) PRE_first_tail_x15_r0_body.sizeA329 PRE_first_tail_x15_r0_body.sizeArgsA329 PRE_first_tail_x15_r0_body.sizeSymA329 PRE_first_tail_x15_r0_body.sizeMlxA329 PRE_first_tail_x15_r0_body.sizePayA329 PRE_first_tail_x15_r0_body.sizeTaA329 PRE_first_tail_x15_r0_body.sizeDecA329 PRE_first_tail_x15_r0_body.sizePreA329 PRE_first_tail_x15_r0_body.bodyPatchB329 (fun _ hm => bodyO1218 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1218).trans bodyInactive0) (bodyBr1219.trans bodyBr1218.symm) bodyCnt1218 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) bodyAcc1219 PRE_first_tail_x15_r0_body.bodyRunSeg329 bodyAcc1220 bodyHalt1220 PRE_first_tail_x15_r0_body.bodyStepA330 bodyTop1221 (fun _ hm => bodyO1219 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1219).trans bodyInactive0) (bodyBr1221.trans bodyBr1219.symm) bodyCnt1219 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) PRE_first_tail_x15_r0_body.sizeA330 PRE_first_tail_x15_r0_body.sizeArgsA330 PRE_first_tail_x15_r0_body.sizeSymA330 PRE_first_tail_x15_r0_body.sizeMlxA330 PRE_first_tail_x15_r0_body.sizePayA330 PRE_first_tail_x15_r0_body.sizeTaA330 PRE_first_tail_x15_r0_body.sizeDecA330 PRE_first_tail_x15_r0_body.sizePreA330 PRE_first_tail_x15_r0_body.bodyPatchB330 (fun _ hm => bodyO1221 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1221).trans bodyInactive0) (bodyBr1222.trans bodyBr1221.symm) bodyCnt1221 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44985, 841, 0, 666⟩) bodyAcc1222 PRE_first_tail_x15_r0_body.bodyRunSeg330 bodyAcc1223 bodyHalt1223 PRE_first_tail_x15_r0_body.bodyStepA331 bodyTop1224 (fun _ hm => bodyO1222 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1222).trans bodyInactive0) (bodyBr1224.trans bodyBr1222.symm) bodyCnt1222 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
