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

kernel_rfl bodyO1295 : PRE_first_tail_x15_r0_body.S1295.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1295.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1295 : bridgeOf PRE_first_tail_x15_r0_body.s1295.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1295 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.S1295) = fun _ _ => true
kernel_rfl bodyAcc1297 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1297 PRE_first_tail_x15_r0_body.S1297) = fun _ _ => true
kernel_rfl bodyBr1298 : bridgeOf PRE_first_tail_x15_r0_body.s1298.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1297 : isHalt PRE_first_tail_x15_r0_body.s1297.ctl = false
kernel_rfl bodyTop1298 : noRetBlock PRE_first_tail_x15_r0_body.s1298 = true
kernel_rfl bodyCnt1295 : countersOkB PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.s1298 = true
kernel_rfl bodyO1298 : PRE_first_tail_x15_r0_body.S1298.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1298.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1299 : bridgeOf PRE_first_tail_x15_r0_body.s1299.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1298 : countersOkB PRE_first_tail_x15_r0_body.s1298 PRE_first_tail_x15_r0_body.s1299 = true
kernel_rfl bodyO1299 : PRE_first_tail_x15_r0_body.S1299.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1299.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1299 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1299 PRE_first_tail_x15_r0_body.S1299) = fun _ _ => true
kernel_rfl bodyAcc1300 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1300 PRE_first_tail_x15_r0_body.S1300) = fun _ _ => true
kernel_rfl bodyBr1301 : bridgeOf PRE_first_tail_x15_r0_body.s1301.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1300 : isHalt PRE_first_tail_x15_r0_body.s1300.ctl = false
kernel_rfl bodyTop1301 : noRetBlock PRE_first_tail_x15_r0_body.s1301 = true
kernel_rfl bodyCnt1299 : countersOkB PRE_first_tail_x15_r0_body.s1299 PRE_first_tail_x15_r0_body.s1301 = true
kernel_rfl bodyO1301 : PRE_first_tail_x15_r0_body.S1301.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1301.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1302 : bridgeOf PRE_first_tail_x15_r0_body.s1302.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1301 : countersOkB PRE_first_tail_x15_r0_body.s1301 PRE_first_tail_x15_r0_body.s1302 = true
kernel_rfl bodyO1302 : PRE_first_tail_x15_r0_body.S1302.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1302.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1302 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1302 PRE_first_tail_x15_r0_body.S1302) = fun _ _ => true
kernel_rfl bodyAcc1303 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1303 PRE_first_tail_x15_r0_body.S1303) = fun _ _ => true
kernel_rfl bodyBr1304 : bridgeOf PRE_first_tail_x15_r0_body.s1304.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1303 : isHalt PRE_first_tail_x15_r0_body.s1303.ctl = false
kernel_rfl bodyTop1304 : noRetBlock PRE_first_tail_x15_r0_body.s1304 = true
kernel_rfl bodyCnt1302 : countersOkB PRE_first_tail_x15_r0_body.s1302 PRE_first_tail_x15_r0_body.s1304 = true
kernel_rfl bodyO1304 : PRE_first_tail_x15_r0_body.S1304.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1304.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1305 : bridgeOf PRE_first_tail_x15_r0_body.s1305.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1304 : countersOkB PRE_first_tail_x15_r0_body.s1304 PRE_first_tail_x15_r0_body.s1305 = true
kernel_rfl bodyO1305 : PRE_first_tail_x15_r0_body.S1305.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1305.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1305 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1305 PRE_first_tail_x15_r0_body.S1305) = fun _ _ => true
kernel_rfl bodyAcc1306 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1306 PRE_first_tail_x15_r0_body.S1306) = fun _ _ => true
kernel_rfl bodyBr1307 : bridgeOf PRE_first_tail_x15_r0_body.s1307.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1306 : isHalt PRE_first_tail_x15_r0_body.s1306.ctl = false
kernel_rfl bodyTop1307 : noRetBlock PRE_first_tail_x15_r0_body.s1307 = true
kernel_rfl bodyCnt1305 : countersOkB PRE_first_tail_x15_r0_body.s1305 PRE_first_tail_x15_r0_body.s1307 = true
kernel_rfl bodyO1307 : PRE_first_tail_x15_r0_body.S1307.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1307.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1308 : bridgeOf PRE_first_tail_x15_r0_body.s1308.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1307 : countersOkB PRE_first_tail_x15_r0_body.s1307 PRE_first_tail_x15_r0_body.s1308 = true
kernel_rfl bodyO1308 : PRE_first_tail_x15_r0_body.S1308.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1308.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1308 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1308 PRE_first_tail_x15_r0_body.S1308) = fun _ _ => true
kernel_rfl bodyAcc1309 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1309 PRE_first_tail_x15_r0_body.S1309) = fun _ _ => true
kernel_rfl bodyBr1310 : bridgeOf PRE_first_tail_x15_r0_body.s1310.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1309 : isHalt PRE_first_tail_x15_r0_body.s1309.ctl = false
kernel_rfl bodyTop1310 : noRetBlock PRE_first_tail_x15_r0_body.s1310 = true
kernel_rfl bodyCnt1308 : countersOkB PRE_first_tail_x15_r0_body.s1308 PRE_first_tail_x15_r0_body.s1310 = true

theorem bodyGlue135 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨47669, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.S1295)
      (bodyCut NB T tk π i x0 bodyΘ ⟨47669, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.S1310) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) bodyAcc1295 PRE_first_tail_x15_r0_body.bodyRunSeg349 bodyAcc1297 bodyHalt1297 PRE_first_tail_x15_r0_body.bodyStepA350 bodyTop1298 (fun _ hm => bodyO1295 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1295).trans bodyInactive0) (bodyBr1298.trans bodyBr1295.symm) bodyCnt1295 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) PRE_first_tail_x15_r0_body.sizeA350 PRE_first_tail_x15_r0_body.sizeArgsA350 PRE_first_tail_x15_r0_body.sizeSymA350 PRE_first_tail_x15_r0_body.sizeMlxA350 PRE_first_tail_x15_r0_body.sizePayA350 PRE_first_tail_x15_r0_body.sizeTaA350 PRE_first_tail_x15_r0_body.sizeDecA350 PRE_first_tail_x15_r0_body.sizePreA350 PRE_first_tail_x15_r0_body.bodyPatchB350 (fun _ hm => bodyO1298 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1298).trans bodyInactive0) (bodyBr1299.trans bodyBr1298.symm) bodyCnt1298 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) bodyAcc1299 PRE_first_tail_x15_r0_body.bodyRunSeg350 bodyAcc1300 bodyHalt1300 PRE_first_tail_x15_r0_body.bodyStepA351 bodyTop1301 (fun _ hm => bodyO1299 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1299).trans bodyInactive0) (bodyBr1301.trans bodyBr1299.symm) bodyCnt1299 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) PRE_first_tail_x15_r0_body.sizeA351 PRE_first_tail_x15_r0_body.sizeArgsA351 PRE_first_tail_x15_r0_body.sizeSymA351 PRE_first_tail_x15_r0_body.sizeMlxA351 PRE_first_tail_x15_r0_body.sizePayA351 PRE_first_tail_x15_r0_body.sizeTaA351 PRE_first_tail_x15_r0_body.sizeDecA351 PRE_first_tail_x15_r0_body.sizePreA351 PRE_first_tail_x15_r0_body.bodyPatchB351 (fun _ hm => bodyO1301 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1301).trans bodyInactive0) (bodyBr1302.trans bodyBr1301.symm) bodyCnt1301 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) bodyAcc1302 PRE_first_tail_x15_r0_body.bodyRunSeg351 bodyAcc1303 bodyHalt1303 PRE_first_tail_x15_r0_body.bodyStepA352 bodyTop1304 (fun _ hm => bodyO1302 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1302).trans bodyInactive0) (bodyBr1304.trans bodyBr1302.symm) bodyCnt1302 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) PRE_first_tail_x15_r0_body.sizeA352 PRE_first_tail_x15_r0_body.sizeArgsA352 PRE_first_tail_x15_r0_body.sizeSymA352 PRE_first_tail_x15_r0_body.sizeMlxA352 PRE_first_tail_x15_r0_body.sizePayA352 PRE_first_tail_x15_r0_body.sizeTaA352 PRE_first_tail_x15_r0_body.sizeDecA352 PRE_first_tail_x15_r0_body.sizePreA352 PRE_first_tail_x15_r0_body.bodyPatchB352 (fun _ hm => bodyO1304 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1304).trans bodyInactive0) (bodyBr1305.trans bodyBr1304.symm) bodyCnt1304 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) bodyAcc1305 PRE_first_tail_x15_r0_body.bodyRunSeg352 bodyAcc1306 bodyHalt1306 PRE_first_tail_x15_r0_body.bodyStepA353 bodyTop1307 (fun _ hm => bodyO1305 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1305).trans bodyInactive0) (bodyBr1307.trans bodyBr1305.symm) bodyCnt1305 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) PRE_first_tail_x15_r0_body.sizeA353 PRE_first_tail_x15_r0_body.sizeArgsA353 PRE_first_tail_x15_r0_body.sizeSymA353 PRE_first_tail_x15_r0_body.sizeMlxA353 PRE_first_tail_x15_r0_body.sizePayA353 PRE_first_tail_x15_r0_body.sizeTaA353 PRE_first_tail_x15_r0_body.sizeDecA353 PRE_first_tail_x15_r0_body.sizePreA353 PRE_first_tail_x15_r0_body.bodyPatchB353 (fun _ hm => bodyO1307 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1307).trans bodyInactive0) (bodyBr1308.trans bodyBr1307.symm) bodyCnt1307 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47669, 893, 0, 711⟩) bodyAcc1308 PRE_first_tail_x15_r0_body.bodyRunSeg353 bodyAcc1309 bodyHalt1309 PRE_first_tail_x15_r0_body.bodyStepA354 bodyTop1310 (fun _ hm => bodyO1308 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1308).trans bodyInactive0) (bodyBr1310.trans bodyBr1308.symm) bodyCnt1308 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
