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

kernel_rfl bodyO1341 : PRE_first_tail_x15_r0_body.S1341.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1341.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1341 : bridgeOf PRE_first_tail_x15_r0_body.s1341.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1341 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.S1341) = fun _ _ => true
kernel_rfl bodyAcc1342 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1342 PRE_first_tail_x15_r0_body.S1342) = fun _ _ => true
kernel_rfl bodyBr1343 : bridgeOf PRE_first_tail_x15_r0_body.s1343.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1342 : isHalt PRE_first_tail_x15_r0_body.s1342.ctl = false
kernel_rfl bodyTop1343 : noRetBlock PRE_first_tail_x15_r0_body.s1343 = true
kernel_rfl bodyCnt1341 : countersOkB PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.s1343 = true
kernel_rfl bodyO1343 : PRE_first_tail_x15_r0_body.S1343.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1343.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1344 : bridgeOf PRE_first_tail_x15_r0_body.s1344.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1343 : countersOkB PRE_first_tail_x15_r0_body.s1343 PRE_first_tail_x15_r0_body.s1344 = true
kernel_rfl bodyO1344 : PRE_first_tail_x15_r0_body.S1344.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1344.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1344 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1344 PRE_first_tail_x15_r0_body.S1344) = fun _ _ => true
kernel_rfl bodyAcc1346 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1346 PRE_first_tail_x15_r0_body.S1346) = fun _ _ => true
kernel_rfl bodyBr1347 : bridgeOf PRE_first_tail_x15_r0_body.s1347.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1346 : isHalt PRE_first_tail_x15_r0_body.s1346.ctl = false
kernel_rfl bodyTop1347 : noRetBlock PRE_first_tail_x15_r0_body.s1347 = true
kernel_rfl bodyCnt1344 : countersOkB PRE_first_tail_x15_r0_body.s1344 PRE_first_tail_x15_r0_body.s1347 = true

theorem bodyGlue139 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨49988, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.S1341)
      (bodyCut NB T tk π i x0 bodyΘ ⟨49988, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1347 PRE_first_tail_x15_r0_body.S1347) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49988, 943, 0, 747⟩) bodyAcc1341 PRE_first_tail_x15_r0_body.bodyRunSeg362 bodyAcc1342 bodyHalt1342 PRE_first_tail_x15_r0_body.bodyStepA363 bodyTop1343 (fun _ hm => bodyO1341 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1341).trans bodyInactive0) (bodyBr1343.trans bodyBr1341.symm) bodyCnt1341 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49988, 943, 0, 747⟩) PRE_first_tail_x15_r0_body.sizeA363 PRE_first_tail_x15_r0_body.sizeArgsA363 PRE_first_tail_x15_r0_body.sizeSymA363 PRE_first_tail_x15_r0_body.sizeMlxA363 PRE_first_tail_x15_r0_body.sizePayA363 PRE_first_tail_x15_r0_body.sizeTaA363 PRE_first_tail_x15_r0_body.sizeDecA363 PRE_first_tail_x15_r0_body.sizePreA363 PRE_first_tail_x15_r0_body.bodyPatchB363 (fun _ hm => bodyO1343 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1343).trans bodyInactive0) (bodyBr1344.trans bodyBr1343.symm) bodyCnt1343 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49988, 943, 0, 747⟩) bodyAcc1344 PRE_first_tail_x15_r0_body.bodyRunSeg363 bodyAcc1346 bodyHalt1346 PRE_first_tail_x15_r0_body.bodyStepA364 bodyTop1347 (fun _ hm => bodyO1344 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1344).trans bodyInactive0) (bodyBr1347.trans bodyBr1344.symm) bodyCnt1344 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
