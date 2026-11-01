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

kernel_rfl bodyO1008 : PRE_first_tail_x15_r0_body.S1008.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1008.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1008 : bridgeOf PRE_first_tail_x15_r0_body.s1008.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1008 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.S1008) = fun _ _ => true
kernel_rfl bodyAcc1010 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1010 PRE_first_tail_x15_r0_body.S1010) = fun _ _ => true
kernel_rfl bodyBr1011 : bridgeOf PRE_first_tail_x15_r0_body.s1011.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1010 : isHalt PRE_first_tail_x15_r0_body.s1010.ctl = false
kernel_rfl bodyTop1011 : noRetBlock PRE_first_tail_x15_r0_body.s1011 = true
kernel_rfl bodyCnt1008 : countersOkB PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.s1011 = true
kernel_rfl bodyO1011 : PRE_first_tail_x15_r0_body.S1011.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1011.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1012 : bridgeOf PRE_first_tail_x15_r0_body.s1012.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1011 : countersOkB PRE_first_tail_x15_r0_body.s1011 PRE_first_tail_x15_r0_body.s1012 = true
kernel_rfl bodyO1012 : PRE_first_tail_x15_r0_body.S1012.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1012.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1012 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1012 PRE_first_tail_x15_r0_body.S1012) = fun _ _ => true
kernel_rfl bodyAcc1014 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1014 PRE_first_tail_x15_r0_body.S1014) = fun _ _ => true
kernel_rfl bodyBr1015 : bridgeOf PRE_first_tail_x15_r0_body.s1015.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1014 : isHalt PRE_first_tail_x15_r0_body.s1014.ctl = false
kernel_rfl bodyTop1015 : noRetBlock PRE_first_tail_x15_r0_body.s1015 = true
kernel_rfl bodyCnt1012 : countersOkB PRE_first_tail_x15_r0_body.s1012 PRE_first_tail_x15_r0_body.s1015 = true
kernel_rfl bodyO1015 : PRE_first_tail_x15_r0_body.S1015.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1015.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1016 : bridgeOf PRE_first_tail_x15_r0_body.s1016.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1015 : countersOkB PRE_first_tail_x15_r0_body.s1015 PRE_first_tail_x15_r0_body.s1016 = true
kernel_rfl bodyO1016 : PRE_first_tail_x15_r0_body.S1016.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1016.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1016 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1016 PRE_first_tail_x15_r0_body.S1016) = fun _ _ => true
kernel_rfl bodyAcc1017 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1017 PRE_first_tail_x15_r0_body.S1017) = fun _ _ => true
kernel_rfl bodyBr1018 : bridgeOf PRE_first_tail_x15_r0_body.s1018.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1017 : isHalt PRE_first_tail_x15_r0_body.s1017.ctl = false
kernel_rfl bodyTop1018 : noRetBlock PRE_first_tail_x15_r0_body.s1018 = true
kernel_rfl bodyCnt1016 : countersOkB PRE_first_tail_x15_r0_body.s1016 PRE_first_tail_x15_r0_body.s1018 = true
kernel_rfl bodyO1018 : PRE_first_tail_x15_r0_body.S1018.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1018.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1019 : bridgeOf PRE_first_tail_x15_r0_body.s1019.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1018 : countersOkB PRE_first_tail_x15_r0_body.s1018 PRE_first_tail_x15_r0_body.s1019 = true
kernel_rfl bodyO1019 : PRE_first_tail_x15_r0_body.S1019.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1019.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1019 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1019 PRE_first_tail_x15_r0_body.S1019) = fun _ _ => true
kernel_rfl bodyAcc1021 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1021 PRE_first_tail_x15_r0_body.S1021) = fun _ _ => true
kernel_rfl bodyBr1022 : bridgeOf PRE_first_tail_x15_r0_body.s1022.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1021 : isHalt PRE_first_tail_x15_r0_body.s1021.ctl = false
kernel_rfl bodyTop1022 : noRetBlock PRE_first_tail_x15_r0_body.s1022 = true
kernel_rfl bodyCnt1019 : countersOkB PRE_first_tail_x15_r0_body.s1019 PRE_first_tail_x15_r0_body.s1022 = true

theorem bodyGlue105 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38456, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.S1008)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38456, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.S1022) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38456, 712, 0, 558⟩) bodyAcc1008 PRE_first_tail_x15_r0_body.bodyRunSeg272 bodyAcc1010 bodyHalt1010 PRE_first_tail_x15_r0_body.bodyStepA273 bodyTop1011 (fun _ hm => bodyO1008 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1008).trans bodyInactive0) (bodyBr1011.trans bodyBr1008.symm) bodyCnt1008 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38456, 712, 0, 558⟩) PRE_first_tail_x15_r0_body.sizeA273 PRE_first_tail_x15_r0_body.sizeArgsA273 PRE_first_tail_x15_r0_body.sizeSymA273 PRE_first_tail_x15_r0_body.sizeMlxA273 PRE_first_tail_x15_r0_body.sizePayA273 PRE_first_tail_x15_r0_body.sizeTaA273 PRE_first_tail_x15_r0_body.sizeDecA273 PRE_first_tail_x15_r0_body.sizePreA273 PRE_first_tail_x15_r0_body.bodyPatchB273 (fun _ hm => bodyO1011 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1011).trans bodyInactive0) (bodyBr1012.trans bodyBr1011.symm) bodyCnt1011 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38456, 712, 0, 558⟩) bodyAcc1012 PRE_first_tail_x15_r0_body.bodyRunSeg273 bodyAcc1014 bodyHalt1014 PRE_first_tail_x15_r0_body.bodyStepA274 bodyTop1015 (fun _ hm => bodyO1012 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1012).trans bodyInactive0) (bodyBr1015.trans bodyBr1012.symm) bodyCnt1012 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38456, 712, 0, 558⟩) PRE_first_tail_x15_r0_body.sizeA274 PRE_first_tail_x15_r0_body.sizeArgsA274 PRE_first_tail_x15_r0_body.sizeSymA274 PRE_first_tail_x15_r0_body.sizeMlxA274 PRE_first_tail_x15_r0_body.sizePayA274 PRE_first_tail_x15_r0_body.sizeTaA274 PRE_first_tail_x15_r0_body.sizeDecA274 PRE_first_tail_x15_r0_body.sizePreA274 PRE_first_tail_x15_r0_body.bodyPatchB274 (fun _ hm => bodyO1015 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1015).trans bodyInactive0) (bodyBr1016.trans bodyBr1015.symm) bodyCnt1015 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38456, 712, 0, 558⟩) bodyAcc1016 PRE_first_tail_x15_r0_body.bodyRunSeg274 bodyAcc1017 bodyHalt1017 PRE_first_tail_x15_r0_body.bodyStepA275 bodyTop1018 (fun _ hm => bodyO1016 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1016).trans bodyInactive0) (bodyBr1018.trans bodyBr1016.symm) bodyCnt1016 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38456, 712, 0, 558⟩) PRE_first_tail_x15_r0_body.sizeA275 PRE_first_tail_x15_r0_body.sizeArgsA275 PRE_first_tail_x15_r0_body.sizeSymA275 PRE_first_tail_x15_r0_body.sizeMlxA275 PRE_first_tail_x15_r0_body.sizePayA275 PRE_first_tail_x15_r0_body.sizeTaA275 PRE_first_tail_x15_r0_body.sizeDecA275 PRE_first_tail_x15_r0_body.sizePreA275 PRE_first_tail_x15_r0_body.bodyPatchB275 (fun _ hm => bodyO1018 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1018).trans bodyInactive0) (bodyBr1019.trans bodyBr1018.symm) bodyCnt1018 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38456, 712, 0, 558⟩) bodyAcc1019 PRE_first_tail_x15_r0_body.bodyRunSeg275 bodyAcc1021 bodyHalt1021 PRE_first_tail_x15_r0_body.bodyStepA276 bodyTop1022 (fun _ hm => bodyO1019 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1019).trans bodyInactive0) (bodyBr1022.trans bodyBr1019.symm) bodyCnt1019 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
