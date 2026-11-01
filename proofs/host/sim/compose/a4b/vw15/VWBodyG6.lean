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

kernel_rfl bodyO59 : PRE_first_tail_x15_r0_body.S59.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S59.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr59 : bridgeOf PRE_first_tail_x15_r0_body.s59.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc59 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.S59) = fun _ _ => true
kernel_rfl bodyAcc61 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s61 PRE_first_tail_x15_r0_body.S61) = fun _ _ => true
kernel_rfl bodyBr62 : bridgeOf PRE_first_tail_x15_r0_body.s62.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt61 : isHalt PRE_first_tail_x15_r0_body.s61.ctl = false
kernel_rfl bodyTop62 : noRetBlock PRE_first_tail_x15_r0_body.s62 = true
kernel_rfl bodyCnt59 : countersOkB PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.s62 = true
kernel_rfl bodyO62 : PRE_first_tail_x15_r0_body.S62.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S62.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr63 : bridgeOf PRE_first_tail_x15_r0_body.s63.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt62 : countersOkB PRE_first_tail_x15_r0_body.s62 PRE_first_tail_x15_r0_body.s63 = true
kernel_rfl bodyO63 : PRE_first_tail_x15_r0_body.S63.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S63.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc63 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s63 PRE_first_tail_x15_r0_body.S63) = fun _ _ => true
kernel_rfl bodyAcc64 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s64 PRE_first_tail_x15_r0_body.S64) = fun _ _ => true
kernel_rfl bodyBr65 : bridgeOf PRE_first_tail_x15_r0_body.s65.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt64 : isHalt PRE_first_tail_x15_r0_body.s64.ctl = false
kernel_rfl bodyTop65 : noRetBlock PRE_first_tail_x15_r0_body.s65 = true
kernel_rfl bodyCnt63 : countersOkB PRE_first_tail_x15_r0_body.s63 PRE_first_tail_x15_r0_body.s65 = true
kernel_rfl bodyO65 : PRE_first_tail_x15_r0_body.S65.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S65.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr66 : bridgeOf PRE_first_tail_x15_r0_body.s66.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt65 : countersOkB PRE_first_tail_x15_r0_body.s65 PRE_first_tail_x15_r0_body.s66 = true
kernel_rfl bodyO66 : PRE_first_tail_x15_r0_body.S66.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S66.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc66 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s66 PRE_first_tail_x15_r0_body.S66) = fun _ _ => true
kernel_rfl bodyAcc67 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s67 PRE_first_tail_x15_r0_body.S67) = fun _ _ => true
kernel_rfl bodyBr68 : bridgeOf PRE_first_tail_x15_r0_body.s68.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt67 : isHalt PRE_first_tail_x15_r0_body.s67.ctl = false
kernel_rfl bodyTop68 : noRetBlock PRE_first_tail_x15_r0_body.s68 = true
kernel_rfl bodyCnt66 : countersOkB PRE_first_tail_x15_r0_body.s66 PRE_first_tail_x15_r0_body.s68 = true
kernel_rfl bodyO68 : PRE_first_tail_x15_r0_body.S68.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S68.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr69 : bridgeOf PRE_first_tail_x15_r0_body.s69.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt68 : countersOkB PRE_first_tail_x15_r0_body.s68 PRE_first_tail_x15_r0_body.s69 = true
kernel_rfl bodyO69 : PRE_first_tail_x15_r0_body.S69.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S69.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc69 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s69 PRE_first_tail_x15_r0_body.S69) = fun _ _ => true
kernel_rfl bodyAcc70 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s70 PRE_first_tail_x15_r0_body.S70) = fun _ _ => true
kernel_rfl bodyBr71 : bridgeOf PRE_first_tail_x15_r0_body.s71.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt70 : isHalt PRE_first_tail_x15_r0_body.s70.ctl = false
kernel_rfl bodyTop71 : noRetBlock PRE_first_tail_x15_r0_body.s71 = true
kernel_rfl bodyCnt69 : countersOkB PRE_first_tail_x15_r0_body.s69 PRE_first_tail_x15_r0_body.s71 = true
kernel_rfl bodyO71 : PRE_first_tail_x15_r0_body.S71.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S71.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr72 : bridgeOf PRE_first_tail_x15_r0_body.s72.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt71 : countersOkB PRE_first_tail_x15_r0_body.s71 PRE_first_tail_x15_r0_body.s72 = true
kernel_rfl bodyO72 : PRE_first_tail_x15_r0_body.S72.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S72.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc72 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s72 PRE_first_tail_x15_r0_body.S72) = fun _ _ => true
kernel_rfl bodyAcc73 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s73 PRE_first_tail_x15_r0_body.S73) = fun _ _ => true
kernel_rfl bodyBr74 : bridgeOf PRE_first_tail_x15_r0_body.s74.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt73 : isHalt PRE_first_tail_x15_r0_body.s73.ctl = false
kernel_rfl bodyTop74 : noRetBlock PRE_first_tail_x15_r0_body.s74 = true
kernel_rfl bodyCnt72 : countersOkB PRE_first_tail_x15_r0_body.s72 PRE_first_tail_x15_r0_body.s74 = true

theorem bodyGlue6 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6445, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.S59)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6445, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s74 PRE_first_tail_x15_r0_body.S74) 15435 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc59 PRE_first_tail_x15_r0_body.bodyRunSeg16 bodyAcc61 bodyHalt61 PRE_first_tail_x15_r0_body.bodyStepA17 bodyTop62 (fun _ hm => bodyO59 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr59).trans bodyInactive0) (bodyBr62.trans bodyBr59.symm) bodyCnt59 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) PRE_first_tail_x15_r0_body.sizeA17 PRE_first_tail_x15_r0_body.sizeArgsA17 PRE_first_tail_x15_r0_body.sizeSymA17 PRE_first_tail_x15_r0_body.sizeMlxA17 PRE_first_tail_x15_r0_body.sizePayA17 PRE_first_tail_x15_r0_body.sizeTaA17 PRE_first_tail_x15_r0_body.sizeDecA17 PRE_first_tail_x15_r0_body.sizePreA17 PRE_first_tail_x15_r0_body.bodyPatchB17 (fun _ hm => bodyO62 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr62).trans bodyInactive0) (bodyBr63.trans bodyBr62.symm) bodyCnt62 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc63 PRE_first_tail_x15_r0_body.bodyRunSeg17 bodyAcc64 bodyHalt64 PRE_first_tail_x15_r0_body.bodyStepA18 bodyTop65 (fun _ hm => bodyO63 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr63).trans bodyInactive0) (bodyBr65.trans bodyBr63.symm) bodyCnt63 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) PRE_first_tail_x15_r0_body.sizeA18 PRE_first_tail_x15_r0_body.sizeArgsA18 PRE_first_tail_x15_r0_body.sizeSymA18 PRE_first_tail_x15_r0_body.sizeMlxA18 PRE_first_tail_x15_r0_body.sizePayA18 PRE_first_tail_x15_r0_body.sizeTaA18 PRE_first_tail_x15_r0_body.sizeDecA18 PRE_first_tail_x15_r0_body.sizePreA18 PRE_first_tail_x15_r0_body.bodyPatchB18 (fun _ hm => bodyO65 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr65).trans bodyInactive0) (bodyBr66.trans bodyBr65.symm) bodyCnt65 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc66 PRE_first_tail_x15_r0_body.bodyRunSeg18 bodyAcc67 bodyHalt67 PRE_first_tail_x15_r0_body.bodyStepA19 bodyTop68 (fun _ hm => bodyO66 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr66).trans bodyInactive0) (bodyBr68.trans bodyBr66.symm) bodyCnt66 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) PRE_first_tail_x15_r0_body.sizeA19 PRE_first_tail_x15_r0_body.sizeArgsA19 PRE_first_tail_x15_r0_body.sizeSymA19 PRE_first_tail_x15_r0_body.sizeMlxA19 PRE_first_tail_x15_r0_body.sizePayA19 PRE_first_tail_x15_r0_body.sizeTaA19 PRE_first_tail_x15_r0_body.sizeDecA19 PRE_first_tail_x15_r0_body.sizePreA19 PRE_first_tail_x15_r0_body.bodyPatchB19 (fun _ hm => bodyO68 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr68).trans bodyInactive0) (bodyBr69.trans bodyBr68.symm) bodyCnt68 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc69 PRE_first_tail_x15_r0_body.bodyRunSeg19 bodyAcc70 bodyHalt70 PRE_first_tail_x15_r0_body.bodyStepA20 bodyTop71 (fun _ hm => bodyO69 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr69).trans bodyInactive0) (bodyBr71.trans bodyBr69.symm) bodyCnt69 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) PRE_first_tail_x15_r0_body.sizeA20 PRE_first_tail_x15_r0_body.sizeArgsA20 PRE_first_tail_x15_r0_body.sizeSymA20 PRE_first_tail_x15_r0_body.sizeMlxA20 PRE_first_tail_x15_r0_body.sizePayA20 PRE_first_tail_x15_r0_body.sizeTaA20 PRE_first_tail_x15_r0_body.sizeDecA20 PRE_first_tail_x15_r0_body.sizePreA20 PRE_first_tail_x15_r0_body.bodyPatchB20 (fun _ hm => bodyO71 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr71).trans bodyInactive0) (bodyBr72.trans bodyBr71.symm) bodyCnt71 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc72 PRE_first_tail_x15_r0_body.bodyRunSeg20 bodyAcc73 bodyHalt73 PRE_first_tail_x15_r0_body.bodyStepA21 bodyTop74 (fun _ hm => bodyO72 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr72).trans bodyInactive0) (bodyBr74.trans bodyBr72.symm) bodyCnt72 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
