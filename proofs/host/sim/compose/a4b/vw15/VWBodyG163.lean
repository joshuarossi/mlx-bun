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

kernel_rfl bodyO1571 : PRE_first_tail_x15_r0_body.S1571.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1571.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1571 : bridgeOf PRE_first_tail_x15_r0_body.s1571.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1571 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.S1571) = fun _ _ => true
kernel_rfl bodyAcc1572 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1572 PRE_first_tail_x15_r0_body.S1572) = fun _ _ => true
kernel_rfl bodyBr1573 : bridgeOf PRE_first_tail_x15_r0_body.s1573.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1572 : isHalt PRE_first_tail_x15_r0_body.s1572.ctl = false
kernel_rfl bodyTop1573 : noRetBlock PRE_first_tail_x15_r0_body.s1573 = true
kernel_rfl bodyCnt1571 : countersOkB PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.s1573 = true
kernel_rfl bodyO1573 : PRE_first_tail_x15_r0_body.S1573.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1573.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1574 : bridgeOf PRE_first_tail_x15_r0_body.s1574.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1573 : countersOkB PRE_first_tail_x15_r0_body.s1573 PRE_first_tail_x15_r0_body.s1574 = true
kernel_rfl bodyO1574 : PRE_first_tail_x15_r0_body.S1574.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1574.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1574 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1574 PRE_first_tail_x15_r0_body.S1574) = fun _ _ => true
kernel_rfl bodyAcc1576 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1576 PRE_first_tail_x15_r0_body.S1576) = fun _ _ => true
kernel_rfl bodyBr1577 : bridgeOf PRE_first_tail_x15_r0_body.s1577.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1576 : isHalt PRE_first_tail_x15_r0_body.s1576.ctl = false
kernel_rfl bodyTop1577 : noRetBlock PRE_first_tail_x15_r0_body.s1577 = true
kernel_rfl bodyCnt1574 : countersOkB PRE_first_tail_x15_r0_body.s1574 PRE_first_tail_x15_r0_body.s1577 = true

theorem bodyGlue163 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨57714, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.S1571)
      (bodyCut NB T tk π i x0 bodyΘ ⟨57714, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1577 PRE_first_tail_x15_r0_body.S1577) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57714, 1097, 0, 873⟩) bodyAcc1571 PRE_first_tail_x15_r0_body.bodyRunSeg424 bodyAcc1572 bodyHalt1572 PRE_first_tail_x15_r0_body.bodyStepA425 bodyTop1573 (fun _ hm => bodyO1571 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1571).trans bodyInactive0) (bodyBr1573.trans bodyBr1571.symm) bodyCnt1571 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57714, 1097, 0, 873⟩) PRE_first_tail_x15_r0_body.sizeA425 PRE_first_tail_x15_r0_body.sizeArgsA425 PRE_first_tail_x15_r0_body.sizeSymA425 PRE_first_tail_x15_r0_body.sizeMlxA425 PRE_first_tail_x15_r0_body.sizePayA425 PRE_first_tail_x15_r0_body.sizeTaA425 PRE_first_tail_x15_r0_body.sizeDecA425 PRE_first_tail_x15_r0_body.sizePreA425 PRE_first_tail_x15_r0_body.bodyPatchB425 (fun _ hm => bodyO1573 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1573).trans bodyInactive0) (bodyBr1574.trans bodyBr1573.symm) bodyCnt1573 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57714, 1097, 0, 873⟩) bodyAcc1574 PRE_first_tail_x15_r0_body.bodyRunSeg425 bodyAcc1576 bodyHalt1576 PRE_first_tail_x15_r0_body.bodyStepA426 bodyTop1577 (fun _ hm => bodyO1574 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1574).trans bodyInactive0) (bodyBr1577.trans bodyBr1574.symm) bodyCnt1574 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
