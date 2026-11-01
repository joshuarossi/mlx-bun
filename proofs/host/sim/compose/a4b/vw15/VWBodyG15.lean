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

kernel_rfl bodyO145 : PRE_first_tail_x15_r0_body.S145.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S145.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr145 : bridgeOf PRE_first_tail_x15_r0_body.s145.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc145 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.S145) = fun _ _ => true
kernel_rfl bodyAcc147 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s147 PRE_first_tail_x15_r0_body.S147) = fun _ _ => true
kernel_rfl bodyBr148 : bridgeOf PRE_first_tail_x15_r0_body.s148.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt147 : isHalt PRE_first_tail_x15_r0_body.s147.ctl = false
kernel_rfl bodyTop148 : noRetBlock PRE_first_tail_x15_r0_body.s148 = true
kernel_rfl bodyCnt145 : countersOkB PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.s148 = true
kernel_rfl bodyO148 : PRE_first_tail_x15_r0_body.S148.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S148.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr149 : bridgeOf PRE_first_tail_x15_r0_body.s149.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt148 : countersOkB PRE_first_tail_x15_r0_body.s148 PRE_first_tail_x15_r0_body.s149 = true
kernel_rfl bodyO149 : PRE_first_tail_x15_r0_body.S149.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S149.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc149 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s149 PRE_first_tail_x15_r0_body.S149) = fun _ _ => true
kernel_rfl bodyAcc150 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s150 PRE_first_tail_x15_r0_body.S150) = fun _ _ => true
kernel_rfl bodyBr151 : bridgeOf PRE_first_tail_x15_r0_body.s151.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt150 : isHalt PRE_first_tail_x15_r0_body.s150.ctl = false
kernel_rfl bodyTop151 : noRetBlock PRE_first_tail_x15_r0_body.s151 = true
kernel_rfl bodyCnt149 : countersOkB PRE_first_tail_x15_r0_body.s149 PRE_first_tail_x15_r0_body.s151 = true
kernel_rfl bodyO151 : PRE_first_tail_x15_r0_body.S151.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S151.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr152 : bridgeOf PRE_first_tail_x15_r0_body.s152.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt151 : countersOkB PRE_first_tail_x15_r0_body.s151 PRE_first_tail_x15_r0_body.s152 = true
kernel_rfl bodyO152 : PRE_first_tail_x15_r0_body.S152.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S152.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc152 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s152 PRE_first_tail_x15_r0_body.S152) = fun _ _ => true
kernel_rfl bodyAcc153 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s153 PRE_first_tail_x15_r0_body.S153) = fun _ _ => true
kernel_rfl bodyBr154 : bridgeOf PRE_first_tail_x15_r0_body.s154.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt153 : isHalt PRE_first_tail_x15_r0_body.s153.ctl = false
kernel_rfl bodyTop154 : noRetBlock PRE_first_tail_x15_r0_body.s154 = true
kernel_rfl bodyCnt152 : countersOkB PRE_first_tail_x15_r0_body.s152 PRE_first_tail_x15_r0_body.s154 = true
kernel_rfl bodyO154 : PRE_first_tail_x15_r0_body.S154.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S154.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr155 : bridgeOf PRE_first_tail_x15_r0_body.s155.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt154 : countersOkB PRE_first_tail_x15_r0_body.s154 PRE_first_tail_x15_r0_body.s155 = true
kernel_rfl bodyO155 : PRE_first_tail_x15_r0_body.S155.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S155.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc155 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s155 PRE_first_tail_x15_r0_body.S155) = fun _ _ => true
kernel_rfl bodyAcc156 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s156 PRE_first_tail_x15_r0_body.S156) = fun _ _ => true
kernel_rfl bodyBr157 : bridgeOf PRE_first_tail_x15_r0_body.s157.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt156 : isHalt PRE_first_tail_x15_r0_body.s156.ctl = false
kernel_rfl bodyTop157 : noRetBlock PRE_first_tail_x15_r0_body.s157 = true
kernel_rfl bodyCnt155 : countersOkB PRE_first_tail_x15_r0_body.s155 PRE_first_tail_x15_r0_body.s157 = true
kernel_rfl bodyO157 : PRE_first_tail_x15_r0_body.S157.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S157.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr158 : bridgeOf PRE_first_tail_x15_r0_body.s158.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt157 : countersOkB PRE_first_tail_x15_r0_body.s157 PRE_first_tail_x15_r0_body.s158 = true
kernel_rfl bodyO158 : PRE_first_tail_x15_r0_body.S158.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S158.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc158 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s158 PRE_first_tail_x15_r0_body.S158) = fun _ _ => true
kernel_rfl bodyAcc159 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s159 PRE_first_tail_x15_r0_body.S159) = fun _ _ => true
kernel_rfl bodyBr160 : bridgeOf PRE_first_tail_x15_r0_body.s160.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt159 : isHalt PRE_first_tail_x15_r0_body.s159.ctl = false
kernel_rfl bodyTop160 : noRetBlock PRE_first_tail_x15_r0_body.s160 = true
kernel_rfl bodyCnt158 : countersOkB PRE_first_tail_x15_r0_body.s158 PRE_first_tail_x15_r0_body.s160 = true

theorem bodyGlue15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9129, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.S145)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9129, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s160 PRE_first_tail_x15_r0_body.S160) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc145 PRE_first_tail_x15_r0_body.bodyRunSeg39 bodyAcc147 bodyHalt147 PRE_first_tail_x15_r0_body.bodyStepA40 bodyTop148 (fun _ hm => bodyO145 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr145).trans bodyInactive0) (bodyBr148.trans bodyBr145.symm) bodyCnt145 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) PRE_first_tail_x15_r0_body.sizeA40 PRE_first_tail_x15_r0_body.sizeArgsA40 PRE_first_tail_x15_r0_body.sizeSymA40 PRE_first_tail_x15_r0_body.sizeMlxA40 PRE_first_tail_x15_r0_body.sizePayA40 PRE_first_tail_x15_r0_body.sizeTaA40 PRE_first_tail_x15_r0_body.sizeDecA40 PRE_first_tail_x15_r0_body.sizePreA40 PRE_first_tail_x15_r0_body.bodyPatchB40 (fun _ hm => bodyO148 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr148).trans bodyInactive0) (bodyBr149.trans bodyBr148.symm) bodyCnt148 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc149 PRE_first_tail_x15_r0_body.bodyRunSeg40 bodyAcc150 bodyHalt150 PRE_first_tail_x15_r0_body.bodyStepA41 bodyTop151 (fun _ hm => bodyO149 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr149).trans bodyInactive0) (bodyBr151.trans bodyBr149.symm) bodyCnt149 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) PRE_first_tail_x15_r0_body.sizeA41 PRE_first_tail_x15_r0_body.sizeArgsA41 PRE_first_tail_x15_r0_body.sizeSymA41 PRE_first_tail_x15_r0_body.sizeMlxA41 PRE_first_tail_x15_r0_body.sizePayA41 PRE_first_tail_x15_r0_body.sizeTaA41 PRE_first_tail_x15_r0_body.sizeDecA41 PRE_first_tail_x15_r0_body.sizePreA41 PRE_first_tail_x15_r0_body.bodyPatchB41 (fun _ hm => bodyO151 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr151).trans bodyInactive0) (bodyBr152.trans bodyBr151.symm) bodyCnt151 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc152 PRE_first_tail_x15_r0_body.bodyRunSeg41 bodyAcc153 bodyHalt153 PRE_first_tail_x15_r0_body.bodyStepA42 bodyTop154 (fun _ hm => bodyO152 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr152).trans bodyInactive0) (bodyBr154.trans bodyBr152.symm) bodyCnt152 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) PRE_first_tail_x15_r0_body.sizeA42 PRE_first_tail_x15_r0_body.sizeArgsA42 PRE_first_tail_x15_r0_body.sizeSymA42 PRE_first_tail_x15_r0_body.sizeMlxA42 PRE_first_tail_x15_r0_body.sizePayA42 PRE_first_tail_x15_r0_body.sizeTaA42 PRE_first_tail_x15_r0_body.sizeDecA42 PRE_first_tail_x15_r0_body.sizePreA42 PRE_first_tail_x15_r0_body.bodyPatchB42 (fun _ hm => bodyO154 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr154).trans bodyInactive0) (bodyBr155.trans bodyBr154.symm) bodyCnt154 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc155 PRE_first_tail_x15_r0_body.bodyRunSeg42 bodyAcc156 bodyHalt156 PRE_first_tail_x15_r0_body.bodyStepA43 bodyTop157 (fun _ hm => bodyO155 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr155).trans bodyInactive0) (bodyBr157.trans bodyBr155.symm) bodyCnt155 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) PRE_first_tail_x15_r0_body.sizeA43 PRE_first_tail_x15_r0_body.sizeArgsA43 PRE_first_tail_x15_r0_body.sizeSymA43 PRE_first_tail_x15_r0_body.sizeMlxA43 PRE_first_tail_x15_r0_body.sizePayA43 PRE_first_tail_x15_r0_body.sizeTaA43 PRE_first_tail_x15_r0_body.sizeDecA43 PRE_first_tail_x15_r0_body.sizePreA43 PRE_first_tail_x15_r0_body.bodyPatchB43 (fun _ hm => bodyO157 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr157).trans bodyInactive0) (bodyBr158.trans bodyBr157.symm) bodyCnt157 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨9129, 123, 0, 81⟩) bodyAcc158 PRE_first_tail_x15_r0_body.bodyRunSeg43 bodyAcc159 bodyHalt159 PRE_first_tail_x15_r0_body.bodyStepA44 bodyTop160 (fun _ hm => bodyO158 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr158).trans bodyInactive0) (bodyBr160.trans bodyBr158.symm) bodyCnt158 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
