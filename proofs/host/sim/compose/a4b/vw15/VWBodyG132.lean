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

kernel_rfl bodyO1266 : PRE_first_tail_x15_r0_body.S1266.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1266.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1266 : bridgeOf PRE_first_tail_x15_r0_body.s1266.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1266 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.S1266) = fun _ _ => true
kernel_rfl bodyAcc1268 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1268 PRE_first_tail_x15_r0_body.S1268) = fun _ _ => true
kernel_rfl bodyBr1269 : bridgeOf PRE_first_tail_x15_r0_body.s1269.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1268 : isHalt PRE_first_tail_x15_r0_body.s1268.ctl = false
kernel_rfl bodyTop1269 : noRetBlock PRE_first_tail_x15_r0_body.s1269 = true
kernel_rfl bodyCnt1266 : countersOkB PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.s1269 = true
kernel_rfl bodyO1269 : PRE_first_tail_x15_r0_body.S1269.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1269.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1270 : bridgeOf PRE_first_tail_x15_r0_body.s1270.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1269 : countersOkB PRE_first_tail_x15_r0_body.s1269 PRE_first_tail_x15_r0_body.s1270 = true
kernel_rfl bodyO1270 : PRE_first_tail_x15_r0_body.S1270.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1270.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1270 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1270 PRE_first_tail_x15_r0_body.S1270) = fun _ _ => true
kernel_rfl bodyAcc1271 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1271 PRE_first_tail_x15_r0_body.S1271) = fun _ _ => true
kernel_rfl bodyBr1272 : bridgeOf PRE_first_tail_x15_r0_body.s1272.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1271 : isHalt PRE_first_tail_x15_r0_body.s1271.ctl = false
kernel_rfl bodyTop1272 : noRetBlock PRE_first_tail_x15_r0_body.s1272 = true
kernel_rfl bodyCnt1270 : countersOkB PRE_first_tail_x15_r0_body.s1270 PRE_first_tail_x15_r0_body.s1272 = true
kernel_rfl bodyO1272 : PRE_first_tail_x15_r0_body.S1272.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1272.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1273 : bridgeOf PRE_first_tail_x15_r0_body.s1273.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1272 : countersOkB PRE_first_tail_x15_r0_body.s1272 PRE_first_tail_x15_r0_body.s1273 = true
kernel_rfl bodyO1273 : PRE_first_tail_x15_r0_body.S1273.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1273.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1273 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1273 PRE_first_tail_x15_r0_body.S1273) = fun _ _ => true
kernel_rfl bodyAcc1274 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1274 PRE_first_tail_x15_r0_body.S1274) = fun _ _ => true
kernel_rfl bodyBr1275 : bridgeOf PRE_first_tail_x15_r0_body.s1275.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1274 : isHalt PRE_first_tail_x15_r0_body.s1274.ctl = false
kernel_rfl bodyTop1275 : noRetBlock PRE_first_tail_x15_r0_body.s1275 = true
kernel_rfl bodyCnt1273 : countersOkB PRE_first_tail_x15_r0_body.s1273 PRE_first_tail_x15_r0_body.s1275 = true
kernel_rfl bodyO1275 : PRE_first_tail_x15_r0_body.S1275.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1275.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1276 : bridgeOf PRE_first_tail_x15_r0_body.s1276.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1275 : countersOkB PRE_first_tail_x15_r0_body.s1275 PRE_first_tail_x15_r0_body.s1276 = true
kernel_rfl bodyO1276 : PRE_first_tail_x15_r0_body.S1276.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1276.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1276 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1276 PRE_first_tail_x15_r0_body.S1276) = fun _ _ => true
kernel_rfl bodyAcc1277 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1277 PRE_first_tail_x15_r0_body.S1277) = fun _ _ => true
kernel_rfl bodyBr1278 : bridgeOf PRE_first_tail_x15_r0_body.s1278.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1277 : isHalt PRE_first_tail_x15_r0_body.s1277.ctl = false
kernel_rfl bodyTop1278 : noRetBlock PRE_first_tail_x15_r0_body.s1278 = true
kernel_rfl bodyCnt1276 : countersOkB PRE_first_tail_x15_r0_body.s1276 PRE_first_tail_x15_r0_body.s1278 = true
kernel_rfl bodyO1278 : PRE_first_tail_x15_r0_body.S1278.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1278.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1279 : bridgeOf PRE_first_tail_x15_r0_body.s1279.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1278 : countersOkB PRE_first_tail_x15_r0_body.s1278 PRE_first_tail_x15_r0_body.s1279 = true
kernel_rfl bodyO1279 : PRE_first_tail_x15_r0_body.S1279.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1279.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1279 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1279 PRE_first_tail_x15_r0_body.S1279) = fun _ _ => true
kernel_rfl bodyAcc1280 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1280 PRE_first_tail_x15_r0_body.S1280) = fun _ _ => true
kernel_rfl bodyBr1281 : bridgeOf PRE_first_tail_x15_r0_body.s1281.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1280 : isHalt PRE_first_tail_x15_r0_body.s1280.ctl = false
kernel_rfl bodyTop1281 : noRetBlock PRE_first_tail_x15_r0_body.s1281 = true
kernel_rfl bodyCnt1279 : countersOkB PRE_first_tail_x15_r0_body.s1279 PRE_first_tail_x15_r0_body.s1281 = true

theorem bodyGlue132 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46508, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.S1266)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46508, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1281 PRE_first_tail_x15_r0_body.S1281) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) bodyAcc1266 PRE_first_tail_x15_r0_body.bodyRunSeg341 bodyAcc1268 bodyHalt1268 PRE_first_tail_x15_r0_body.bodyStepA342 bodyTop1269 (fun _ hm => bodyO1266 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1266).trans bodyInactive0) (bodyBr1269.trans bodyBr1266.symm) bodyCnt1266 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) PRE_first_tail_x15_r0_body.sizeA342 PRE_first_tail_x15_r0_body.sizeArgsA342 PRE_first_tail_x15_r0_body.sizeSymA342 PRE_first_tail_x15_r0_body.sizeMlxA342 PRE_first_tail_x15_r0_body.sizePayA342 PRE_first_tail_x15_r0_body.sizeTaA342 PRE_first_tail_x15_r0_body.sizeDecA342 PRE_first_tail_x15_r0_body.sizePreA342 PRE_first_tail_x15_r0_body.bodyPatchB342 (fun _ hm => bodyO1269 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1269).trans bodyInactive0) (bodyBr1270.trans bodyBr1269.symm) bodyCnt1269 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) bodyAcc1270 PRE_first_tail_x15_r0_body.bodyRunSeg342 bodyAcc1271 bodyHalt1271 PRE_first_tail_x15_r0_body.bodyStepA343 bodyTop1272 (fun _ hm => bodyO1270 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1270).trans bodyInactive0) (bodyBr1272.trans bodyBr1270.symm) bodyCnt1270 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) PRE_first_tail_x15_r0_body.sizeA343 PRE_first_tail_x15_r0_body.sizeArgsA343 PRE_first_tail_x15_r0_body.sizeSymA343 PRE_first_tail_x15_r0_body.sizeMlxA343 PRE_first_tail_x15_r0_body.sizePayA343 PRE_first_tail_x15_r0_body.sizeTaA343 PRE_first_tail_x15_r0_body.sizeDecA343 PRE_first_tail_x15_r0_body.sizePreA343 PRE_first_tail_x15_r0_body.bodyPatchB343 (fun _ hm => bodyO1272 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1272).trans bodyInactive0) (bodyBr1273.trans bodyBr1272.symm) bodyCnt1272 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) bodyAcc1273 PRE_first_tail_x15_r0_body.bodyRunSeg343 bodyAcc1274 bodyHalt1274 PRE_first_tail_x15_r0_body.bodyStepA344 bodyTop1275 (fun _ hm => bodyO1273 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1273).trans bodyInactive0) (bodyBr1275.trans bodyBr1273.symm) bodyCnt1273 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) PRE_first_tail_x15_r0_body.sizeA344 PRE_first_tail_x15_r0_body.sizeArgsA344 PRE_first_tail_x15_r0_body.sizeSymA344 PRE_first_tail_x15_r0_body.sizeMlxA344 PRE_first_tail_x15_r0_body.sizePayA344 PRE_first_tail_x15_r0_body.sizeTaA344 PRE_first_tail_x15_r0_body.sizeDecA344 PRE_first_tail_x15_r0_body.sizePreA344 PRE_first_tail_x15_r0_body.bodyPatchB344 (fun _ hm => bodyO1275 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1275).trans bodyInactive0) (bodyBr1276.trans bodyBr1275.symm) bodyCnt1275 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) bodyAcc1276 PRE_first_tail_x15_r0_body.bodyRunSeg344 bodyAcc1277 bodyHalt1277 PRE_first_tail_x15_r0_body.bodyStepA345 bodyTop1278 (fun _ hm => bodyO1276 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1276).trans bodyInactive0) (bodyBr1278.trans bodyBr1276.symm) bodyCnt1276 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) PRE_first_tail_x15_r0_body.sizeA345 PRE_first_tail_x15_r0_body.sizeArgsA345 PRE_first_tail_x15_r0_body.sizeSymA345 PRE_first_tail_x15_r0_body.sizeMlxA345 PRE_first_tail_x15_r0_body.sizePayA345 PRE_first_tail_x15_r0_body.sizeTaA345 PRE_first_tail_x15_r0_body.sizeDecA345 PRE_first_tail_x15_r0_body.sizePreA345 PRE_first_tail_x15_r0_body.bodyPatchB345 (fun _ hm => bodyO1278 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1278).trans bodyInactive0) (bodyBr1279.trans bodyBr1278.symm) bodyCnt1278 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46508, 868, 0, 693⟩) bodyAcc1279 PRE_first_tail_x15_r0_body.bodyRunSeg345 bodyAcc1280 bodyHalt1280 PRE_first_tail_x15_r0_body.bodyStepA346 bodyTop1281 (fun _ hm => bodyO1279 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1279).trans bodyInactive0) (bodyBr1281.trans bodyBr1279.symm) bodyCnt1279 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
