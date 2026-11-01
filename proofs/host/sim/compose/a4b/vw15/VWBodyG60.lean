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

kernel_rfl bodyO576 : PRE_first_tail_x15_r0_body.S576.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S576.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr576 : bridgeOf PRE_first_tail_x15_r0_body.s576.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc576 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.S576) = fun _ _ => true
kernel_rfl bodyAcc578 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s578 PRE_first_tail_x15_r0_body.S578) = fun _ _ => true
kernel_rfl bodyBr579 : bridgeOf PRE_first_tail_x15_r0_body.s579.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt578 : isHalt PRE_first_tail_x15_r0_body.s578.ctl = false
kernel_rfl bodyTop579 : noRetBlock PRE_first_tail_x15_r0_body.s579 = true
kernel_rfl bodyCnt576 : countersOkB PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.s579 = true
kernel_rfl bodyO579 : PRE_first_tail_x15_r0_body.S579.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S579.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr580 : bridgeOf PRE_first_tail_x15_r0_body.s580.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt579 : countersOkB PRE_first_tail_x15_r0_body.s579 PRE_first_tail_x15_r0_body.s580 = true
kernel_rfl bodyO580 : PRE_first_tail_x15_r0_body.S580.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S580.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc580 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s580 PRE_first_tail_x15_r0_body.S580) = fun _ _ => true
kernel_rfl bodyAcc581 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s581 PRE_first_tail_x15_r0_body.S581) = fun _ _ => true
kernel_rfl bodyBr582 : bridgeOf PRE_first_tail_x15_r0_body.s582.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt581 : isHalt PRE_first_tail_x15_r0_body.s581.ctl = false
kernel_rfl bodyTop582 : noRetBlock PRE_first_tail_x15_r0_body.s582 = true
kernel_rfl bodyCnt580 : countersOkB PRE_first_tail_x15_r0_body.s580 PRE_first_tail_x15_r0_body.s582 = true
kernel_rfl bodyO582 : PRE_first_tail_x15_r0_body.S582.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S582.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr583 : bridgeOf PRE_first_tail_x15_r0_body.s583.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt582 : countersOkB PRE_first_tail_x15_r0_body.s582 PRE_first_tail_x15_r0_body.s583 = true
kernel_rfl bodyO583 : PRE_first_tail_x15_r0_body.S583.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S583.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc583 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s583 PRE_first_tail_x15_r0_body.S583) = fun _ _ => true
kernel_rfl bodyAcc584 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s584 PRE_first_tail_x15_r0_body.S584) = fun _ _ => true
kernel_rfl bodyBr585 : bridgeOf PRE_first_tail_x15_r0_body.s585.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt584 : isHalt PRE_first_tail_x15_r0_body.s584.ctl = false
kernel_rfl bodyTop585 : noRetBlock PRE_first_tail_x15_r0_body.s585 = true
kernel_rfl bodyCnt583 : countersOkB PRE_first_tail_x15_r0_body.s583 PRE_first_tail_x15_r0_body.s585 = true
kernel_rfl bodyO585 : PRE_first_tail_x15_r0_body.S585.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S585.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr586 : bridgeOf PRE_first_tail_x15_r0_body.s586.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt585 : countersOkB PRE_first_tail_x15_r0_body.s585 PRE_first_tail_x15_r0_body.s586 = true
kernel_rfl bodyO586 : PRE_first_tail_x15_r0_body.S586.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S586.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc586 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s586 PRE_first_tail_x15_r0_body.S586) = fun _ _ => true
kernel_rfl bodyAcc587 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s587 PRE_first_tail_x15_r0_body.S587) = fun _ _ => true
kernel_rfl bodyBr588 : bridgeOf PRE_first_tail_x15_r0_body.s588.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt587 : isHalt PRE_first_tail_x15_r0_body.s587.ctl = false
kernel_rfl bodyTop588 : noRetBlock PRE_first_tail_x15_r0_body.s588 = true
kernel_rfl bodyCnt586 : countersOkB PRE_first_tail_x15_r0_body.s586 PRE_first_tail_x15_r0_body.s588 = true
kernel_rfl bodyO588 : PRE_first_tail_x15_r0_body.S588.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S588.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr589 : bridgeOf PRE_first_tail_x15_r0_body.s589.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt588 : countersOkB PRE_first_tail_x15_r0_body.s588 PRE_first_tail_x15_r0_body.s589 = true
kernel_rfl bodyO589 : PRE_first_tail_x15_r0_body.S589.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S589.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc589 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s589 PRE_first_tail_x15_r0_body.S589) = fun _ _ => true
kernel_rfl bodyAcc590 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s590 PRE_first_tail_x15_r0_body.S590) = fun _ _ => true
kernel_rfl bodyBr591 : bridgeOf PRE_first_tail_x15_r0_body.s591.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt590 : isHalt PRE_first_tail_x15_r0_body.s590.ctl = false
kernel_rfl bodyTop591 : noRetBlock PRE_first_tail_x15_r0_body.s591 = true
kernel_rfl bodyCnt589 : countersOkB PRE_first_tail_x15_r0_body.s589 PRE_first_tail_x15_r0_body.s591 = true

theorem bodyGlue60 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23402, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.S576)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23402, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s591 PRE_first_tail_x15_r0_body.S591) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) bodyAcc576 PRE_first_tail_x15_r0_body.bodyRunSeg155 bodyAcc578 bodyHalt578 PRE_first_tail_x15_r0_body.bodyStepA156 bodyTop579 (fun _ hm => bodyO576 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr576).trans bodyInactive0) (bodyBr579.trans bodyBr576.symm) bodyCnt576 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) PRE_first_tail_x15_r0_body.sizeA156 PRE_first_tail_x15_r0_body.sizeArgsA156 PRE_first_tail_x15_r0_body.sizeSymA156 PRE_first_tail_x15_r0_body.sizeMlxA156 PRE_first_tail_x15_r0_body.sizePayA156 PRE_first_tail_x15_r0_body.sizeTaA156 PRE_first_tail_x15_r0_body.sizeDecA156 PRE_first_tail_x15_r0_body.sizePreA156 PRE_first_tail_x15_r0_body.bodyPatchB156 (fun _ hm => bodyO579 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr579).trans bodyInactive0) (bodyBr580.trans bodyBr579.symm) bodyCnt579 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) bodyAcc580 PRE_first_tail_x15_r0_body.bodyRunSeg156 bodyAcc581 bodyHalt581 PRE_first_tail_x15_r0_body.bodyStepA157 bodyTop582 (fun _ hm => bodyO580 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr580).trans bodyInactive0) (bodyBr582.trans bodyBr580.symm) bodyCnt580 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) PRE_first_tail_x15_r0_body.sizeA157 PRE_first_tail_x15_r0_body.sizeArgsA157 PRE_first_tail_x15_r0_body.sizeSymA157 PRE_first_tail_x15_r0_body.sizeMlxA157 PRE_first_tail_x15_r0_body.sizePayA157 PRE_first_tail_x15_r0_body.sizeTaA157 PRE_first_tail_x15_r0_body.sizeDecA157 PRE_first_tail_x15_r0_body.sizePreA157 PRE_first_tail_x15_r0_body.bodyPatchB157 (fun _ hm => bodyO582 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr582).trans bodyInactive0) (bodyBr583.trans bodyBr582.symm) bodyCnt582 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) bodyAcc583 PRE_first_tail_x15_r0_body.bodyRunSeg157 bodyAcc584 bodyHalt584 PRE_first_tail_x15_r0_body.bodyStepA158 bodyTop585 (fun _ hm => bodyO583 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr583).trans bodyInactive0) (bodyBr585.trans bodyBr583.symm) bodyCnt583 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) PRE_first_tail_x15_r0_body.sizeA158 PRE_first_tail_x15_r0_body.sizeArgsA158 PRE_first_tail_x15_r0_body.sizeSymA158 PRE_first_tail_x15_r0_body.sizeMlxA158 PRE_first_tail_x15_r0_body.sizePayA158 PRE_first_tail_x15_r0_body.sizeTaA158 PRE_first_tail_x15_r0_body.sizeDecA158 PRE_first_tail_x15_r0_body.sizePreA158 PRE_first_tail_x15_r0_body.bodyPatchB158 (fun _ hm => bodyO585 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr585).trans bodyInactive0) (bodyBr586.trans bodyBr585.symm) bodyCnt585 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) bodyAcc586 PRE_first_tail_x15_r0_body.bodyRunSeg158 bodyAcc587 bodyHalt587 PRE_first_tail_x15_r0_body.bodyStepA159 bodyTop588 (fun _ hm => bodyO586 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr586).trans bodyInactive0) (bodyBr588.trans bodyBr586.symm) bodyCnt586 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) PRE_first_tail_x15_r0_body.sizeA159 PRE_first_tail_x15_r0_body.sizeArgsA159 PRE_first_tail_x15_r0_body.sizeSymA159 PRE_first_tail_x15_r0_body.sizeMlxA159 PRE_first_tail_x15_r0_body.sizePayA159 PRE_first_tail_x15_r0_body.sizeTaA159 PRE_first_tail_x15_r0_body.sizeDecA159 PRE_first_tail_x15_r0_body.sizePreA159 PRE_first_tail_x15_r0_body.bodyPatchB159 (fun _ hm => bodyO588 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr588).trans bodyInactive0) (bodyBr589.trans bodyBr588.symm) bodyCnt588 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23402, 406, 0, 315⟩) bodyAcc589 PRE_first_tail_x15_r0_body.bodyRunSeg159 bodyAcc590 bodyHalt590 PRE_first_tail_x15_r0_body.bodyStepA160 bodyTop591 (fun _ hm => bodyO589 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr589).trans bodyInactive0) (bodyBr591.trans bodyBr589.symm) bodyCnt589 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
