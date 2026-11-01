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

kernel_rfl bodyO1312 : PRE_first_tail_x15_r0_body.S1312.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1312.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1312 : bridgeOf PRE_first_tail_x15_r0_body.s1312.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1312 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.S1312) = fun _ _ => true
kernel_rfl bodyAcc1313 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1313 PRE_first_tail_x15_r0_body.S1313) = fun _ _ => true
kernel_rfl bodyBr1314 : bridgeOf PRE_first_tail_x15_r0_body.s1314.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1313 : isHalt PRE_first_tail_x15_r0_body.s1313.ctl = false
kernel_rfl bodyTop1314 : noRetBlock PRE_first_tail_x15_r0_body.s1314 = true
kernel_rfl bodyCnt1312 : countersOkB PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.s1314 = true
kernel_rfl bodyO1314 : PRE_first_tail_x15_r0_body.S1314.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1314.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1315 : bridgeOf PRE_first_tail_x15_r0_body.s1315.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1314 : countersOkB PRE_first_tail_x15_r0_body.s1314 PRE_first_tail_x15_r0_body.s1315 = true
kernel_rfl bodyO1315 : PRE_first_tail_x15_r0_body.S1315.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1315.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1315 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1315 PRE_first_tail_x15_r0_body.S1315) = fun _ _ => true
kernel_rfl bodyAcc1317 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1317 PRE_first_tail_x15_r0_body.S1317) = fun _ _ => true
kernel_rfl bodyBr1318 : bridgeOf PRE_first_tail_x15_r0_body.s1318.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1317 : isHalt PRE_first_tail_x15_r0_body.s1317.ctl = false
kernel_rfl bodyTop1318 : noRetBlock PRE_first_tail_x15_r0_body.s1318 = true
kernel_rfl bodyCnt1315 : countersOkB PRE_first_tail_x15_r0_body.s1315 PRE_first_tail_x15_r0_body.s1318 = true

theorem bodyGlue136 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨48818, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.S1312)
      (bodyCut NB T tk π i x0 bodyΘ ⟨48818, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1318 PRE_first_tail_x15_r0_body.S1318) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48818, 918, 0, 729⟩) bodyAcc1312 PRE_first_tail_x15_r0_body.bodyRunSeg354 bodyAcc1313 bodyHalt1313 PRE_first_tail_x15_r0_body.bodyStepA355 bodyTop1314 (fun _ hm => bodyO1312 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1312).trans bodyInactive0) (bodyBr1314.trans bodyBr1312.symm) bodyCnt1312 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48818, 918, 0, 729⟩) PRE_first_tail_x15_r0_body.sizeA355 PRE_first_tail_x15_r0_body.sizeArgsA355 PRE_first_tail_x15_r0_body.sizeSymA355 PRE_first_tail_x15_r0_body.sizeMlxA355 PRE_first_tail_x15_r0_body.sizePayA355 PRE_first_tail_x15_r0_body.sizeTaA355 PRE_first_tail_x15_r0_body.sizeDecA355 PRE_first_tail_x15_r0_body.sizePreA355 PRE_first_tail_x15_r0_body.bodyPatchB355 (fun _ hm => bodyO1314 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1314).trans bodyInactive0) (bodyBr1315.trans bodyBr1314.symm) bodyCnt1314 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48818, 918, 0, 729⟩) bodyAcc1315 PRE_first_tail_x15_r0_body.bodyRunSeg355 bodyAcc1317 bodyHalt1317 PRE_first_tail_x15_r0_body.bodyStepA356 bodyTop1318 (fun _ hm => bodyO1315 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1315).trans bodyInactive0) (bodyBr1318.trans bodyBr1315.symm) bodyCnt1315 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
