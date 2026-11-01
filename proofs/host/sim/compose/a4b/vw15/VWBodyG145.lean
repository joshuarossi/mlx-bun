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

kernel_rfl bodyO1398 : PRE_first_tail_x15_r0_body.S1398.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1398.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1398 : bridgeOf PRE_first_tail_x15_r0_body.s1398.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1398 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.S1398) = fun _ _ => true
kernel_rfl bodyAcc1399 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1399 PRE_first_tail_x15_r0_body.S1399) = fun _ _ => true
kernel_rfl bodyBr1400 : bridgeOf PRE_first_tail_x15_r0_body.s1400.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1399 : isHalt PRE_first_tail_x15_r0_body.s1399.ctl = false
kernel_rfl bodyTop1400 : noRetBlock PRE_first_tail_x15_r0_body.s1400 = true
kernel_rfl bodyCnt1398 : countersOkB PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.s1400 = true
kernel_rfl bodyO1400 : PRE_first_tail_x15_r0_body.S1400.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1400.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1401 : bridgeOf PRE_first_tail_x15_r0_body.s1401.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1400 : countersOkB PRE_first_tail_x15_r0_body.s1400 PRE_first_tail_x15_r0_body.s1401 = true
kernel_rfl bodyO1401 : PRE_first_tail_x15_r0_body.S1401.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1401.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1401 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1401 PRE_first_tail_x15_r0_body.S1401) = fun _ _ => true
kernel_rfl bodyAcc1403 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1403 PRE_first_tail_x15_r0_body.S1403) = fun _ _ => true
kernel_rfl bodyBr1404 : bridgeOf PRE_first_tail_x15_r0_body.s1404.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1403 : isHalt PRE_first_tail_x15_r0_body.s1403.ctl = false
kernel_rfl bodyTop1404 : noRetBlock PRE_first_tail_x15_r0_body.s1404 = true
kernel_rfl bodyCnt1401 : countersOkB PRE_first_tail_x15_r0_body.s1401 PRE_first_tail_x15_r0_body.s1404 = true

theorem bodyGlue145 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨51529, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.S1398)
      (bodyCut NB T tk π i x0 bodyΘ ⟨51529, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1404 PRE_first_tail_x15_r0_body.S1404) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51529, 970, 0, 774⟩) bodyAcc1398 PRE_first_tail_x15_r0_body.bodyRunSeg377 bodyAcc1399 bodyHalt1399 PRE_first_tail_x15_r0_body.bodyStepA378 bodyTop1400 (fun _ hm => bodyO1398 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1398).trans bodyInactive0) (bodyBr1400.trans bodyBr1398.symm) bodyCnt1398 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51529, 970, 0, 774⟩) PRE_first_tail_x15_r0_body.sizeA378 PRE_first_tail_x15_r0_body.sizeArgsA378 PRE_first_tail_x15_r0_body.sizeSymA378 PRE_first_tail_x15_r0_body.sizeMlxA378 PRE_first_tail_x15_r0_body.sizePayA378 PRE_first_tail_x15_r0_body.sizeTaA378 PRE_first_tail_x15_r0_body.sizeDecA378 PRE_first_tail_x15_r0_body.sizePreA378 PRE_first_tail_x15_r0_body.bodyPatchB378 (fun _ hm => bodyO1400 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1400).trans bodyInactive0) (bodyBr1401.trans bodyBr1400.symm) bodyCnt1400 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51529, 970, 0, 774⟩) bodyAcc1401 PRE_first_tail_x15_r0_body.bodyRunSeg378 bodyAcc1403 bodyHalt1403 PRE_first_tail_x15_r0_body.bodyStepA379 bodyTop1404 (fun _ hm => bodyO1401 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1401).trans bodyInactive0) (bodyBr1404.trans bodyBr1401.symm) bodyCnt1401 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
