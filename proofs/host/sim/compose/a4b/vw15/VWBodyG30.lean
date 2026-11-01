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

kernel_rfl bodyO289 : PRE_first_tail_x15_r0_body.S289.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S289.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr289 : bridgeOf PRE_first_tail_x15_r0_body.s289.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc289 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.S289) = fun _ _ => true
kernel_rfl bodyAcc291 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s291 PRE_first_tail_x15_r0_body.S291) = fun _ _ => true
kernel_rfl bodyBr292 : bridgeOf PRE_first_tail_x15_r0_body.s292.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt291 : isHalt PRE_first_tail_x15_r0_body.s291.ctl = false
kernel_rfl bodyTop292 : noRetBlock PRE_first_tail_x15_r0_body.s292 = true
kernel_rfl bodyCnt289 : countersOkB PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.s292 = true
kernel_rfl bodyO292 : PRE_first_tail_x15_r0_body.S292.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S292.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr293 : bridgeOf PRE_first_tail_x15_r0_body.s293.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt292 : countersOkB PRE_first_tail_x15_r0_body.s292 PRE_first_tail_x15_r0_body.s293 = true
kernel_rfl bodyO293 : PRE_first_tail_x15_r0_body.S293.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S293.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc293 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s293 PRE_first_tail_x15_r0_body.S293) = fun _ _ => true
kernel_rfl bodyAcc294 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s294 PRE_first_tail_x15_r0_body.S294) = fun _ _ => true
kernel_rfl bodyBr295 : bridgeOf PRE_first_tail_x15_r0_body.s295.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt294 : isHalt PRE_first_tail_x15_r0_body.s294.ctl = false
kernel_rfl bodyTop295 : noRetBlock PRE_first_tail_x15_r0_body.s295 = true
kernel_rfl bodyCnt293 : countersOkB PRE_first_tail_x15_r0_body.s293 PRE_first_tail_x15_r0_body.s295 = true
kernel_rfl bodyO295 : PRE_first_tail_x15_r0_body.S295.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S295.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr296 : bridgeOf PRE_first_tail_x15_r0_body.s296.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt295 : countersOkB PRE_first_tail_x15_r0_body.s295 PRE_first_tail_x15_r0_body.s296 = true
kernel_rfl bodyO296 : PRE_first_tail_x15_r0_body.S296.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S296.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc296 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s296 PRE_first_tail_x15_r0_body.S296) = fun _ _ => true
kernel_rfl bodyAcc297 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s297 PRE_first_tail_x15_r0_body.S297) = fun _ _ => true
kernel_rfl bodyBr298 : bridgeOf PRE_first_tail_x15_r0_body.s298.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt297 : isHalt PRE_first_tail_x15_r0_body.s297.ctl = false
kernel_rfl bodyTop298 : noRetBlock PRE_first_tail_x15_r0_body.s298 = true
kernel_rfl bodyCnt296 : countersOkB PRE_first_tail_x15_r0_body.s296 PRE_first_tail_x15_r0_body.s298 = true
kernel_rfl bodyO298 : PRE_first_tail_x15_r0_body.S298.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S298.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr299 : bridgeOf PRE_first_tail_x15_r0_body.s299.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt298 : countersOkB PRE_first_tail_x15_r0_body.s298 PRE_first_tail_x15_r0_body.s299 = true
kernel_rfl bodyO299 : PRE_first_tail_x15_r0_body.S299.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S299.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc299 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s299 PRE_first_tail_x15_r0_body.S299) = fun _ _ => true
kernel_rfl bodyAcc300 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s300 PRE_first_tail_x15_r0_body.S300) = fun _ _ => true
kernel_rfl bodyBr301 : bridgeOf PRE_first_tail_x15_r0_body.s301.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt300 : isHalt PRE_first_tail_x15_r0_body.s300.ctl = false
kernel_rfl bodyTop301 : noRetBlock PRE_first_tail_x15_r0_body.s301 = true
kernel_rfl bodyCnt299 : countersOkB PRE_first_tail_x15_r0_body.s299 PRE_first_tail_x15_r0_body.s301 = true
kernel_rfl bodyO301 : PRE_first_tail_x15_r0_body.S301.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S301.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr302 : bridgeOf PRE_first_tail_x15_r0_body.s302.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt301 : countersOkB PRE_first_tail_x15_r0_body.s301 PRE_first_tail_x15_r0_body.s302 = true
kernel_rfl bodyO302 : PRE_first_tail_x15_r0_body.S302.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S302.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc302 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s302 PRE_first_tail_x15_r0_body.S302) = fun _ _ => true
kernel_rfl bodyAcc303 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s303 PRE_first_tail_x15_r0_body.S303) = fun _ _ => true
kernel_rfl bodyBr304 : bridgeOf PRE_first_tail_x15_r0_body.s304.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt303 : isHalt PRE_first_tail_x15_r0_body.s303.ctl = false
kernel_rfl bodyTop304 : noRetBlock PRE_first_tail_x15_r0_body.s304 = true
kernel_rfl bodyCnt302 : countersOkB PRE_first_tail_x15_r0_body.s302 PRE_first_tail_x15_r0_body.s304 = true

theorem bodyGlue30 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14135, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.S289)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14135, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.S304) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc289 PRE_first_tail_x15_r0_body.bodyRunSeg78 bodyAcc291 bodyHalt291 PRE_first_tail_x15_r0_body.bodyStepA79 bodyTop292 (fun _ hm => bodyO289 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr289).trans bodyInactive0) (bodyBr292.trans bodyBr289.symm) bodyCnt289 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) PRE_first_tail_x15_r0_body.sizeA79 PRE_first_tail_x15_r0_body.sizeArgsA79 PRE_first_tail_x15_r0_body.sizeSymA79 PRE_first_tail_x15_r0_body.sizeMlxA79 PRE_first_tail_x15_r0_body.sizePayA79 PRE_first_tail_x15_r0_body.sizeTaA79 PRE_first_tail_x15_r0_body.sizeDecA79 PRE_first_tail_x15_r0_body.sizePreA79 PRE_first_tail_x15_r0_body.bodyPatchB79 (fun _ hm => bodyO292 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr292).trans bodyInactive0) (bodyBr293.trans bodyBr292.symm) bodyCnt292 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc293 PRE_first_tail_x15_r0_body.bodyRunSeg79 bodyAcc294 bodyHalt294 PRE_first_tail_x15_r0_body.bodyStepA80 bodyTop295 (fun _ hm => bodyO293 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr293).trans bodyInactive0) (bodyBr295.trans bodyBr293.symm) bodyCnt293 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) PRE_first_tail_x15_r0_body.sizeA80 PRE_first_tail_x15_r0_body.sizeArgsA80 PRE_first_tail_x15_r0_body.sizeSymA80 PRE_first_tail_x15_r0_body.sizeMlxA80 PRE_first_tail_x15_r0_body.sizePayA80 PRE_first_tail_x15_r0_body.sizeTaA80 PRE_first_tail_x15_r0_body.sizeDecA80 PRE_first_tail_x15_r0_body.sizePreA80 PRE_first_tail_x15_r0_body.bodyPatchB80 (fun _ hm => bodyO295 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr295).trans bodyInactive0) (bodyBr296.trans bodyBr295.symm) bodyCnt295 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc296 PRE_first_tail_x15_r0_body.bodyRunSeg80 bodyAcc297 bodyHalt297 PRE_first_tail_x15_r0_body.bodyStepA81 bodyTop298 (fun _ hm => bodyO296 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr296).trans bodyInactive0) (bodyBr298.trans bodyBr296.symm) bodyCnt296 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) PRE_first_tail_x15_r0_body.sizeA81 PRE_first_tail_x15_r0_body.sizeArgsA81 PRE_first_tail_x15_r0_body.sizeSymA81 PRE_first_tail_x15_r0_body.sizeMlxA81 PRE_first_tail_x15_r0_body.sizePayA81 PRE_first_tail_x15_r0_body.sizeTaA81 PRE_first_tail_x15_r0_body.sizeDecA81 PRE_first_tail_x15_r0_body.sizePreA81 PRE_first_tail_x15_r0_body.bodyPatchB81 (fun _ hm => bodyO298 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr298).trans bodyInactive0) (bodyBr299.trans bodyBr298.symm) bodyCnt298 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc299 PRE_first_tail_x15_r0_body.bodyRunSeg81 bodyAcc300 bodyHalt300 PRE_first_tail_x15_r0_body.bodyStepA82 bodyTop301 (fun _ hm => bodyO299 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr299).trans bodyInactive0) (bodyBr301.trans bodyBr299.symm) bodyCnt299 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) PRE_first_tail_x15_r0_body.sizeA82 PRE_first_tail_x15_r0_body.sizeArgsA82 PRE_first_tail_x15_r0_body.sizeSymA82 PRE_first_tail_x15_r0_body.sizeMlxA82 PRE_first_tail_x15_r0_body.sizePayA82 PRE_first_tail_x15_r0_body.sizeTaA82 PRE_first_tail_x15_r0_body.sizeDecA82 PRE_first_tail_x15_r0_body.sizePreA82 PRE_first_tail_x15_r0_body.bodyPatchB82 (fun _ hm => bodyO301 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr301).trans bodyInactive0) (bodyBr302.trans bodyBr301.symm) bodyCnt301 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14135, 225, 0, 162⟩) bodyAcc302 PRE_first_tail_x15_r0_body.bodyRunSeg82 bodyAcc303 bodyHalt303 PRE_first_tail_x15_r0_body.bodyStepA83 bodyTop304 (fun _ hm => bodyO302 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr302).trans bodyInactive0) (bodyBr304.trans bodyBr302.symm) bodyCnt302 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
