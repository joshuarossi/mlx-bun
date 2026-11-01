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

kernel_rfl bodyO1427 : PRE_first_tail_x15_r0_body.S1427.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1427.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1427 : bridgeOf PRE_first_tail_x15_r0_body.s1427.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1427 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.S1427) = fun _ _ => true
kernel_rfl bodyAcc1428 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1428 PRE_first_tail_x15_r0_body.S1428) = fun _ _ => true
kernel_rfl bodyBr1429 : bridgeOf PRE_first_tail_x15_r0_body.s1429.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1428 : isHalt PRE_first_tail_x15_r0_body.s1428.ctl = false
kernel_rfl bodyTop1429 : noRetBlock PRE_first_tail_x15_r0_body.s1429 = true
kernel_rfl bodyCnt1427 : countersOkB PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.s1429 = true
kernel_rfl bodyO1429 : PRE_first_tail_x15_r0_body.S1429.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1429.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1430 : bridgeOf PRE_first_tail_x15_r0_body.s1430.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1429 : countersOkB PRE_first_tail_x15_r0_body.s1429 PRE_first_tail_x15_r0_body.s1430 = true
kernel_rfl bodyO1430 : PRE_first_tail_x15_r0_body.S1430.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1430.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1430 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1430 PRE_first_tail_x15_r0_body.S1430) = fun _ _ => true
kernel_rfl bodyAcc1432 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1432 PRE_first_tail_x15_r0_body.S1432) = fun _ _ => true
kernel_rfl bodyBr1433 : bridgeOf PRE_first_tail_x15_r0_body.s1433.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1432 : isHalt PRE_first_tail_x15_r0_body.s1432.ctl = false
kernel_rfl bodyTop1433 : noRetBlock PRE_first_tail_x15_r0_body.s1433 = true
kernel_rfl bodyCnt1430 : countersOkB PRE_first_tail_x15_r0_body.s1430 PRE_first_tail_x15_r0_body.s1433 = true

theorem bodyGlue148 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨52699, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.S1427)
      (bodyCut NB T tk π i x0 bodyΘ ⟨52699, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1433 PRE_first_tail_x15_r0_body.S1433) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52699, 995, 0, 792⟩) bodyAcc1427 PRE_first_tail_x15_r0_body.bodyRunSeg385 bodyAcc1428 bodyHalt1428 PRE_first_tail_x15_r0_body.bodyStepA386 bodyTop1429 (fun _ hm => bodyO1427 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1427).trans bodyInactive0) (bodyBr1429.trans bodyBr1427.symm) bodyCnt1427 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52699, 995, 0, 792⟩) PRE_first_tail_x15_r0_body.sizeA386 PRE_first_tail_x15_r0_body.sizeArgsA386 PRE_first_tail_x15_r0_body.sizeSymA386 PRE_first_tail_x15_r0_body.sizeMlxA386 PRE_first_tail_x15_r0_body.sizePayA386 PRE_first_tail_x15_r0_body.sizeTaA386 PRE_first_tail_x15_r0_body.sizeDecA386 PRE_first_tail_x15_r0_body.sizePreA386 PRE_first_tail_x15_r0_body.bodyPatchB386 (fun _ hm => bodyO1429 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1429).trans bodyInactive0) (bodyBr1430.trans bodyBr1429.symm) bodyCnt1429 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52699, 995, 0, 792⟩) bodyAcc1430 PRE_first_tail_x15_r0_body.bodyRunSeg386 bodyAcc1432 bodyHalt1432 PRE_first_tail_x15_r0_body.bodyStepA387 bodyTop1433 (fun _ hm => bodyO1430 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1430).trans bodyInactive0) (bodyBr1433.trans bodyBr1430.symm) bodyCnt1430 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
