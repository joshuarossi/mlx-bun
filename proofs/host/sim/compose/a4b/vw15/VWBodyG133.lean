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

kernel_rfl bodyO1283 : PRE_first_tail_x15_r0_body.S1283.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1283.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1283 : bridgeOf PRE_first_tail_x15_r0_body.s1283.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1283 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.S1283) = fun _ _ => true
kernel_rfl bodyAcc1284 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1284 PRE_first_tail_x15_r0_body.S1284) = fun _ _ => true
kernel_rfl bodyBr1285 : bridgeOf PRE_first_tail_x15_r0_body.s1285.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1284 : isHalt PRE_first_tail_x15_r0_body.s1284.ctl = false
kernel_rfl bodyTop1285 : noRetBlock PRE_first_tail_x15_r0_body.s1285 = true
kernel_rfl bodyCnt1283 : countersOkB PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.s1285 = true
kernel_rfl bodyO1285 : PRE_first_tail_x15_r0_body.S1285.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1285.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1286 : bridgeOf PRE_first_tail_x15_r0_body.s1286.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1285 : countersOkB PRE_first_tail_x15_r0_body.s1285 PRE_first_tail_x15_r0_body.s1286 = true
kernel_rfl bodyO1286 : PRE_first_tail_x15_r0_body.S1286.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1286.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1286 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1286 PRE_first_tail_x15_r0_body.S1286) = fun _ _ => true
kernel_rfl bodyAcc1288 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1288 PRE_first_tail_x15_r0_body.S1288) = fun _ _ => true
kernel_rfl bodyBr1289 : bridgeOf PRE_first_tail_x15_r0_body.s1289.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1288 : isHalt PRE_first_tail_x15_r0_body.s1288.ctl = false
kernel_rfl bodyTop1289 : noRetBlock PRE_first_tail_x15_r0_body.s1289 = true
kernel_rfl bodyCnt1286 : countersOkB PRE_first_tail_x15_r0_body.s1286 PRE_first_tail_x15_r0_body.s1289 = true

theorem bodyGlue133 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨47657, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.S1283)
      (bodyCut NB T tk π i x0 bodyΘ ⟨47657, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.S1289) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47657, 893, 0, 711⟩) bodyAcc1283 PRE_first_tail_x15_r0_body.bodyRunSeg346 bodyAcc1284 bodyHalt1284 PRE_first_tail_x15_r0_body.bodyStepA347 bodyTop1285 (fun _ hm => bodyO1283 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1283).trans bodyInactive0) (bodyBr1285.trans bodyBr1283.symm) bodyCnt1283 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47657, 893, 0, 711⟩) PRE_first_tail_x15_r0_body.sizeA347 PRE_first_tail_x15_r0_body.sizeArgsA347 PRE_first_tail_x15_r0_body.sizeSymA347 PRE_first_tail_x15_r0_body.sizeMlxA347 PRE_first_tail_x15_r0_body.sizePayA347 PRE_first_tail_x15_r0_body.sizeTaA347 PRE_first_tail_x15_r0_body.sizeDecA347 PRE_first_tail_x15_r0_body.sizePreA347 PRE_first_tail_x15_r0_body.bodyPatchB347 (fun _ hm => bodyO1285 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1285).trans bodyInactive0) (bodyBr1286.trans bodyBr1285.symm) bodyCnt1285 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47657, 893, 0, 711⟩) bodyAcc1286 PRE_first_tail_x15_r0_body.bodyRunSeg347 bodyAcc1288 bodyHalt1288 PRE_first_tail_x15_r0_body.bodyStepA348 bodyTop1289 (fun _ hm => bodyO1286 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1286).trans bodyInactive0) (bodyBr1289.trans bodyBr1286.symm) bodyCnt1286 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
