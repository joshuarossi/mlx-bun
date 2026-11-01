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

kernel_rfl bodyO1369 : PRE_first_tail_x15_r0_body.S1369.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1369.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1369 : bridgeOf PRE_first_tail_x15_r0_body.s1369.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1369 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.S1369) = fun _ _ => true
kernel_rfl bodyAcc1370 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1370 PRE_first_tail_x15_r0_body.S1370) = fun _ _ => true
kernel_rfl bodyBr1371 : bridgeOf PRE_first_tail_x15_r0_body.s1371.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1370 : isHalt PRE_first_tail_x15_r0_body.s1370.ctl = false
kernel_rfl bodyTop1371 : noRetBlock PRE_first_tail_x15_r0_body.s1371 = true
kernel_rfl bodyCnt1369 : countersOkB PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.s1371 = true
kernel_rfl bodyO1371 : PRE_first_tail_x15_r0_body.S1371.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1371.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1372 : bridgeOf PRE_first_tail_x15_r0_body.s1372.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1371 : countersOkB PRE_first_tail_x15_r0_body.s1371 PRE_first_tail_x15_r0_body.s1372 = true
kernel_rfl bodyO1372 : PRE_first_tail_x15_r0_body.S1372.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1372.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1372 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1372 PRE_first_tail_x15_r0_body.S1372) = fun _ _ => true
kernel_rfl bodyAcc1374 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1374 PRE_first_tail_x15_r0_body.S1374) = fun _ _ => true
kernel_rfl bodyBr1375 : bridgeOf PRE_first_tail_x15_r0_body.s1375.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1374 : isHalt PRE_first_tail_x15_r0_body.s1374.ctl = false
kernel_rfl bodyTop1375 : noRetBlock PRE_first_tail_x15_r0_body.s1375 = true
kernel_rfl bodyCnt1372 : countersOkB PRE_first_tail_x15_r0_body.s1372 PRE_first_tail_x15_r0_body.s1375 = true

theorem bodyGlue142 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50359, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.S1369)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50359, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1375 PRE_first_tail_x15_r0_body.S1375) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50359, 945, 0, 756⟩) bodyAcc1369 PRE_first_tail_x15_r0_body.bodyRunSeg369 bodyAcc1370 bodyHalt1370 PRE_first_tail_x15_r0_body.bodyStepA370 bodyTop1371 (fun _ hm => bodyO1369 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1369).trans bodyInactive0) (bodyBr1371.trans bodyBr1369.symm) bodyCnt1369 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50359, 945, 0, 756⟩) PRE_first_tail_x15_r0_body.sizeA370 PRE_first_tail_x15_r0_body.sizeArgsA370 PRE_first_tail_x15_r0_body.sizeSymA370 PRE_first_tail_x15_r0_body.sizeMlxA370 PRE_first_tail_x15_r0_body.sizePayA370 PRE_first_tail_x15_r0_body.sizeTaA370 PRE_first_tail_x15_r0_body.sizeDecA370 PRE_first_tail_x15_r0_body.sizePreA370 PRE_first_tail_x15_r0_body.bodyPatchB370 (fun _ hm => bodyO1371 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1371).trans bodyInactive0) (bodyBr1372.trans bodyBr1371.symm) bodyCnt1371 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50359, 945, 0, 756⟩) bodyAcc1372 PRE_first_tail_x15_r0_body.bodyRunSeg370 bodyAcc1374 bodyHalt1374 PRE_first_tail_x15_r0_body.bodyStepA371 bodyTop1375 (fun _ hm => bodyO1372 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1372).trans bodyInactive0) (bodyBr1375.trans bodyBr1372.symm) bodyCnt1372 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
