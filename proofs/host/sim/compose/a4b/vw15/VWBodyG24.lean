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

kernel_rfl bodyO231 : PRE_first_tail_x15_r0_body.S231.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S231.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr231 : bridgeOf PRE_first_tail_x15_r0_body.s231.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc231 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s231 PRE_first_tail_x15_r0_body.S231) = fun _ _ => true
kernel_rfl bodyAcc233 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s233 PRE_first_tail_x15_r0_body.S233) = fun _ _ => true
kernel_rfl bodyBr234 : bridgeOf PRE_first_tail_x15_r0_body.s234.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt233 : isHalt PRE_first_tail_x15_r0_body.s233.ctl = false
kernel_rfl bodyTop234 : noRetBlock PRE_first_tail_x15_r0_body.s234 = true
kernel_rfl bodyCnt231 : countersOkB PRE_first_tail_x15_r0_body.s231 PRE_first_tail_x15_r0_body.s234 = true
kernel_rfl bodyO234 : PRE_first_tail_x15_r0_body.S234.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S234.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr235 : bridgeOf PRE_first_tail_x15_r0_body.s235.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt234 : countersOkB PRE_first_tail_x15_r0_body.s234 PRE_first_tail_x15_r0_body.s235 = true
kernel_rfl bodyO235 : PRE_first_tail_x15_r0_body.S235.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S235.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc235 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s235 PRE_first_tail_x15_r0_body.S235) = fun _ _ => true
kernel_rfl bodyAcc236 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s236 PRE_first_tail_x15_r0_body.S236) = fun _ _ => true
kernel_rfl bodyBr237 : bridgeOf PRE_first_tail_x15_r0_body.s237.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt236 : isHalt PRE_first_tail_x15_r0_body.s236.ctl = false
kernel_rfl bodyTop237 : noRetBlock PRE_first_tail_x15_r0_body.s237 = true
kernel_rfl bodyCnt235 : countersOkB PRE_first_tail_x15_r0_body.s235 PRE_first_tail_x15_r0_body.s237 = true
kernel_rfl bodyO237 : PRE_first_tail_x15_r0_body.S237.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S237.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr238 : bridgeOf PRE_first_tail_x15_r0_body.s238.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt237 : countersOkB PRE_first_tail_x15_r0_body.s237 PRE_first_tail_x15_r0_body.s238 = true
kernel_rfl bodyO238 : PRE_first_tail_x15_r0_body.S238.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S238.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc238 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s238 PRE_first_tail_x15_r0_body.S238) = fun _ _ => true
kernel_rfl bodyAcc239 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s239 PRE_first_tail_x15_r0_body.S239) = fun _ _ => true
kernel_rfl bodyBr240 : bridgeOf PRE_first_tail_x15_r0_body.s240.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt239 : isHalt PRE_first_tail_x15_r0_body.s239.ctl = false
kernel_rfl bodyTop240 : noRetBlock PRE_first_tail_x15_r0_body.s240 = true
kernel_rfl bodyCnt238 : countersOkB PRE_first_tail_x15_r0_body.s238 PRE_first_tail_x15_r0_body.s240 = true
kernel_rfl bodyO240 : PRE_first_tail_x15_r0_body.S240.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S240.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr241 : bridgeOf PRE_first_tail_x15_r0_body.s241.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt240 : countersOkB PRE_first_tail_x15_r0_body.s240 PRE_first_tail_x15_r0_body.s241 = true
kernel_rfl bodyO241 : PRE_first_tail_x15_r0_body.S241.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S241.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc241 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s241 PRE_first_tail_x15_r0_body.S241) = fun _ _ => true
kernel_rfl bodyAcc242 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s242 PRE_first_tail_x15_r0_body.S242) = fun _ _ => true
kernel_rfl bodyBr243 : bridgeOf PRE_first_tail_x15_r0_body.s243.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt242 : isHalt PRE_first_tail_x15_r0_body.s242.ctl = false
kernel_rfl bodyTop243 : noRetBlock PRE_first_tail_x15_r0_body.s243 = true
kernel_rfl bodyCnt241 : countersOkB PRE_first_tail_x15_r0_body.s241 PRE_first_tail_x15_r0_body.s243 = true
kernel_rfl bodyO243 : PRE_first_tail_x15_r0_body.S243.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S243.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr244 : bridgeOf PRE_first_tail_x15_r0_body.s244.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt243 : countersOkB PRE_first_tail_x15_r0_body.s243 PRE_first_tail_x15_r0_body.s244 = true
kernel_rfl bodyO244 : PRE_first_tail_x15_r0_body.S244.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S244.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc244 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s244 PRE_first_tail_x15_r0_body.S244) = fun _ _ => true
kernel_rfl bodyAcc245 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s245 PRE_first_tail_x15_r0_body.S245) = fun _ _ => true
kernel_rfl bodyBr246 : bridgeOf PRE_first_tail_x15_r0_body.s246.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt245 : isHalt PRE_first_tail_x15_r0_body.s245.ctl = false
kernel_rfl bodyTop246 : noRetBlock PRE_first_tail_x15_r0_body.s246 = true
kernel_rfl bodyCnt244 : countersOkB PRE_first_tail_x15_r0_body.s244 PRE_first_tail_x15_r0_body.s246 = true

theorem bodyGlue24 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11813, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s231 PRE_first_tail_x15_r0_body.S231)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11813, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s246 PRE_first_tail_x15_r0_body.S246) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc231 PRE_first_tail_x15_r0_body.bodyRunSeg62 bodyAcc233 bodyHalt233 PRE_first_tail_x15_r0_body.bodyStepA63 bodyTop234 (fun _ hm => bodyO231 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr231).trans bodyInactive0) (bodyBr234.trans bodyBr231.symm) bodyCnt231 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) PRE_first_tail_x15_r0_body.sizeA63 PRE_first_tail_x15_r0_body.sizeArgsA63 PRE_first_tail_x15_r0_body.sizeSymA63 PRE_first_tail_x15_r0_body.sizeMlxA63 PRE_first_tail_x15_r0_body.sizePayA63 PRE_first_tail_x15_r0_body.sizeTaA63 PRE_first_tail_x15_r0_body.sizeDecA63 PRE_first_tail_x15_r0_body.sizePreA63 PRE_first_tail_x15_r0_body.bodyPatchB63 (fun _ hm => bodyO234 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr234).trans bodyInactive0) (bodyBr235.trans bodyBr234.symm) bodyCnt234 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc235 PRE_first_tail_x15_r0_body.bodyRunSeg63 bodyAcc236 bodyHalt236 PRE_first_tail_x15_r0_body.bodyStepA64 bodyTop237 (fun _ hm => bodyO235 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr235).trans bodyInactive0) (bodyBr237.trans bodyBr235.symm) bodyCnt235 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) PRE_first_tail_x15_r0_body.sizeA64 PRE_first_tail_x15_r0_body.sizeArgsA64 PRE_first_tail_x15_r0_body.sizeSymA64 PRE_first_tail_x15_r0_body.sizeMlxA64 PRE_first_tail_x15_r0_body.sizePayA64 PRE_first_tail_x15_r0_body.sizeTaA64 PRE_first_tail_x15_r0_body.sizeDecA64 PRE_first_tail_x15_r0_body.sizePreA64 PRE_first_tail_x15_r0_body.bodyPatchB64 (fun _ hm => bodyO237 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr237).trans bodyInactive0) (bodyBr238.trans bodyBr237.symm) bodyCnt237 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc238 PRE_first_tail_x15_r0_body.bodyRunSeg64 bodyAcc239 bodyHalt239 PRE_first_tail_x15_r0_body.bodyStepA65 bodyTop240 (fun _ hm => bodyO238 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr238).trans bodyInactive0) (bodyBr240.trans bodyBr238.symm) bodyCnt238 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) PRE_first_tail_x15_r0_body.sizeA65 PRE_first_tail_x15_r0_body.sizeArgsA65 PRE_first_tail_x15_r0_body.sizeSymA65 PRE_first_tail_x15_r0_body.sizeMlxA65 PRE_first_tail_x15_r0_body.sizePayA65 PRE_first_tail_x15_r0_body.sizeTaA65 PRE_first_tail_x15_r0_body.sizeDecA65 PRE_first_tail_x15_r0_body.sizePreA65 PRE_first_tail_x15_r0_body.bodyPatchB65 (fun _ hm => bodyO240 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr240).trans bodyInactive0) (bodyBr241.trans bodyBr240.symm) bodyCnt240 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc241 PRE_first_tail_x15_r0_body.bodyRunSeg65 bodyAcc242 bodyHalt242 PRE_first_tail_x15_r0_body.bodyStepA66 bodyTop243 (fun _ hm => bodyO241 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr241).trans bodyInactive0) (bodyBr243.trans bodyBr241.symm) bodyCnt241 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) PRE_first_tail_x15_r0_body.sizeA66 PRE_first_tail_x15_r0_body.sizeArgsA66 PRE_first_tail_x15_r0_body.sizeSymA66 PRE_first_tail_x15_r0_body.sizeMlxA66 PRE_first_tail_x15_r0_body.sizePayA66 PRE_first_tail_x15_r0_body.sizeTaA66 PRE_first_tail_x15_r0_body.sizeDecA66 PRE_first_tail_x15_r0_body.sizePreA66 PRE_first_tail_x15_r0_body.bodyPatchB66 (fun _ hm => bodyO243 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr243).trans bodyInactive0) (bodyBr244.trans bodyBr243.symm) bodyCnt243 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11813, 175, 0, 126⟩) bodyAcc244 PRE_first_tail_x15_r0_body.bodyRunSeg66 bodyAcc245 bodyHalt245 PRE_first_tail_x15_r0_body.bodyStepA67 bodyTop246 (fun _ hm => bodyO244 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr244).trans bodyInactive0) (bodyBr246.trans bodyBr244.symm) bodyCnt244 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
