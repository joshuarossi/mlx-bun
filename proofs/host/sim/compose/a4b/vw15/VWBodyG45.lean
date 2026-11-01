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

kernel_rfl bodyO433 : PRE_first_tail_x15_r0_body.S433.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S433.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr433 : bridgeOf PRE_first_tail_x15_r0_body.s433.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc433 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.S433) = fun _ _ => true
kernel_rfl bodyAcc435 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s435 PRE_first_tail_x15_r0_body.S435) = fun _ _ => true
kernel_rfl bodyBr436 : bridgeOf PRE_first_tail_x15_r0_body.s436.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt435 : isHalt PRE_first_tail_x15_r0_body.s435.ctl = false
kernel_rfl bodyTop436 : noRetBlock PRE_first_tail_x15_r0_body.s436 = true
kernel_rfl bodyCnt433 : countersOkB PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.s436 = true
kernel_rfl bodyO436 : PRE_first_tail_x15_r0_body.S436.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S436.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr437 : bridgeOf PRE_first_tail_x15_r0_body.s437.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt436 : countersOkB PRE_first_tail_x15_r0_body.s436 PRE_first_tail_x15_r0_body.s437 = true
kernel_rfl bodyO437 : PRE_first_tail_x15_r0_body.S437.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S437.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc437 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s437 PRE_first_tail_x15_r0_body.S437) = fun _ _ => true
kernel_rfl bodyAcc439 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s439 PRE_first_tail_x15_r0_body.S439) = fun _ _ => true
kernel_rfl bodyBr440 : bridgeOf PRE_first_tail_x15_r0_body.s440.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt439 : isHalt PRE_first_tail_x15_r0_body.s439.ctl = false
kernel_rfl bodyTop440 : noRetBlock PRE_first_tail_x15_r0_body.s440 = true
kernel_rfl bodyCnt437 : countersOkB PRE_first_tail_x15_r0_body.s437 PRE_first_tail_x15_r0_body.s440 = true
kernel_rfl bodyO440 : PRE_first_tail_x15_r0_body.S440.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S440.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr441 : bridgeOf PRE_first_tail_x15_r0_body.s441.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt440 : countersOkB PRE_first_tail_x15_r0_body.s440 PRE_first_tail_x15_r0_body.s441 = true
kernel_rfl bodyO441 : PRE_first_tail_x15_r0_body.S441.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S441.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc441 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s441 PRE_first_tail_x15_r0_body.S441) = fun _ _ => true
kernel_rfl bodyAcc442 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s442 PRE_first_tail_x15_r0_body.S442) = fun _ _ => true
kernel_rfl bodyBr443 : bridgeOf PRE_first_tail_x15_r0_body.s443.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt442 : isHalt PRE_first_tail_x15_r0_body.s442.ctl = false
kernel_rfl bodyTop443 : noRetBlock PRE_first_tail_x15_r0_body.s443 = true
kernel_rfl bodyCnt441 : countersOkB PRE_first_tail_x15_r0_body.s441 PRE_first_tail_x15_r0_body.s443 = true
kernel_rfl bodyO443 : PRE_first_tail_x15_r0_body.S443.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S443.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr444 : bridgeOf PRE_first_tail_x15_r0_body.s444.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt443 : countersOkB PRE_first_tail_x15_r0_body.s443 PRE_first_tail_x15_r0_body.s444 = true
kernel_rfl bodyO444 : PRE_first_tail_x15_r0_body.S444.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S444.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc444 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s444 PRE_first_tail_x15_r0_body.S444) = fun _ _ => true
kernel_rfl bodyAcc446 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s446 PRE_first_tail_x15_r0_body.S446) = fun _ _ => true
kernel_rfl bodyBr447 : bridgeOf PRE_first_tail_x15_r0_body.s447.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt446 : isHalt PRE_first_tail_x15_r0_body.s446.ctl = false
kernel_rfl bodyTop447 : noRetBlock PRE_first_tail_x15_r0_body.s447 = true
kernel_rfl bodyCnt444 : countersOkB PRE_first_tail_x15_r0_body.s444 PRE_first_tail_x15_r0_body.s447 = true

theorem bodyGlue45 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19159, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.S433)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19159, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.S447) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) bodyAcc433 PRE_first_tail_x15_r0_body.bodyRunSeg117 bodyAcc435 bodyHalt435 PRE_first_tail_x15_r0_body.bodyStepA118 bodyTop436 (fun _ hm => bodyO433 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr433).trans bodyInactive0) (bodyBr436.trans bodyBr433.symm) bodyCnt433 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) PRE_first_tail_x15_r0_body.sizeA118 PRE_first_tail_x15_r0_body.sizeArgsA118 PRE_first_tail_x15_r0_body.sizeSymA118 PRE_first_tail_x15_r0_body.sizeMlxA118 PRE_first_tail_x15_r0_body.sizePayA118 PRE_first_tail_x15_r0_body.sizeTaA118 PRE_first_tail_x15_r0_body.sizeDecA118 PRE_first_tail_x15_r0_body.sizePreA118 PRE_first_tail_x15_r0_body.bodyPatchB118 (fun _ hm => bodyO436 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr436).trans bodyInactive0) (bodyBr437.trans bodyBr436.symm) bodyCnt436 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) bodyAcc437 PRE_first_tail_x15_r0_body.bodyRunSeg118 bodyAcc439 bodyHalt439 PRE_first_tail_x15_r0_body.bodyStepA119 bodyTop440 (fun _ hm => bodyO437 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr437).trans bodyInactive0) (bodyBr440.trans bodyBr437.symm) bodyCnt437 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) PRE_first_tail_x15_r0_body.sizeA119 PRE_first_tail_x15_r0_body.sizeArgsA119 PRE_first_tail_x15_r0_body.sizeSymA119 PRE_first_tail_x15_r0_body.sizeMlxA119 PRE_first_tail_x15_r0_body.sizePayA119 PRE_first_tail_x15_r0_body.sizeTaA119 PRE_first_tail_x15_r0_body.sizeDecA119 PRE_first_tail_x15_r0_body.sizePreA119 PRE_first_tail_x15_r0_body.bodyPatchB119 (fun _ hm => bodyO440 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr440).trans bodyInactive0) (bodyBr441.trans bodyBr440.symm) bodyCnt440 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) bodyAcc441 PRE_first_tail_x15_r0_body.bodyRunSeg119 bodyAcc442 bodyHalt442 PRE_first_tail_x15_r0_body.bodyStepA120 bodyTop443 (fun _ hm => bodyO441 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr441).trans bodyInactive0) (bodyBr443.trans bodyBr441.symm) bodyCnt441 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) PRE_first_tail_x15_r0_body.sizeA120 PRE_first_tail_x15_r0_body.sizeArgsA120 PRE_first_tail_x15_r0_body.sizeSymA120 PRE_first_tail_x15_r0_body.sizeMlxA120 PRE_first_tail_x15_r0_body.sizePayA120 PRE_first_tail_x15_r0_body.sizeTaA120 PRE_first_tail_x15_r0_body.sizeDecA120 PRE_first_tail_x15_r0_body.sizePreA120 PRE_first_tail_x15_r0_body.bodyPatchB120 (fun _ hm => bodyO443 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr443).trans bodyInactive0) (bodyBr444.trans bodyBr443.symm) bodyCnt443 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19159, 327, 0, 243⟩) bodyAcc444 PRE_first_tail_x15_r0_body.bodyRunSeg120 bodyAcc446 bodyHalt446 PRE_first_tail_x15_r0_body.bodyStepA121 bodyTop447 (fun _ hm => bodyO444 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr444).trans bodyInactive0) (bodyBr447.trans bodyBr444.symm) bodyCnt444 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
