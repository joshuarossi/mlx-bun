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

kernel_rfl bodyO203 : PRE_first_tail_x15_r0_body.S203.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S203.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr203 : bridgeOf PRE_first_tail_x15_r0_body.s203.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc203 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.S203) = fun _ _ => true
kernel_rfl bodyAcc205 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s205 PRE_first_tail_x15_r0_body.S205) = fun _ _ => true
kernel_rfl bodyBr206 : bridgeOf PRE_first_tail_x15_r0_body.s206.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt205 : isHalt PRE_first_tail_x15_r0_body.s205.ctl = false
kernel_rfl bodyTop206 : noRetBlock PRE_first_tail_x15_r0_body.s206 = true
kernel_rfl bodyCnt203 : countersOkB PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.s206 = true
kernel_rfl bodyO206 : PRE_first_tail_x15_r0_body.S206.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S206.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr207 : bridgeOf PRE_first_tail_x15_r0_body.s207.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt206 : countersOkB PRE_first_tail_x15_r0_body.s206 PRE_first_tail_x15_r0_body.s207 = true
kernel_rfl bodyO207 : PRE_first_tail_x15_r0_body.S207.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S207.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc207 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s207 PRE_first_tail_x15_r0_body.S207) = fun _ _ => true
kernel_rfl bodyAcc209 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s209 PRE_first_tail_x15_r0_body.S209) = fun _ _ => true
kernel_rfl bodyBr210 : bridgeOf PRE_first_tail_x15_r0_body.s210.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt209 : isHalt PRE_first_tail_x15_r0_body.s209.ctl = false
kernel_rfl bodyTop210 : noRetBlock PRE_first_tail_x15_r0_body.s210 = true
kernel_rfl bodyCnt207 : countersOkB PRE_first_tail_x15_r0_body.s207 PRE_first_tail_x15_r0_body.s210 = true
kernel_rfl bodyO210 : PRE_first_tail_x15_r0_body.S210.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S210.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr211 : bridgeOf PRE_first_tail_x15_r0_body.s211.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt210 : countersOkB PRE_first_tail_x15_r0_body.s210 PRE_first_tail_x15_r0_body.s211 = true
kernel_rfl bodyO211 : PRE_first_tail_x15_r0_body.S211.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S211.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc211 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s211 PRE_first_tail_x15_r0_body.S211) = fun _ _ => true
kernel_rfl bodyAcc212 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s212 PRE_first_tail_x15_r0_body.S212) = fun _ _ => true
kernel_rfl bodyBr213 : bridgeOf PRE_first_tail_x15_r0_body.s213.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt212 : isHalt PRE_first_tail_x15_r0_body.s212.ctl = false
kernel_rfl bodyTop213 : noRetBlock PRE_first_tail_x15_r0_body.s213 = true
kernel_rfl bodyCnt211 : countersOkB PRE_first_tail_x15_r0_body.s211 PRE_first_tail_x15_r0_body.s213 = true
kernel_rfl bodyO213 : PRE_first_tail_x15_r0_body.S213.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S213.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr214 : bridgeOf PRE_first_tail_x15_r0_body.s214.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt213 : countersOkB PRE_first_tail_x15_r0_body.s213 PRE_first_tail_x15_r0_body.s214 = true
kernel_rfl bodyO214 : PRE_first_tail_x15_r0_body.S214.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S214.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc214 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s214 PRE_first_tail_x15_r0_body.S214) = fun _ _ => true
kernel_rfl bodyAcc216 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s216 PRE_first_tail_x15_r0_body.S216) = fun _ _ => true
kernel_rfl bodyBr217 : bridgeOf PRE_first_tail_x15_r0_body.s217.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt216 : isHalt PRE_first_tail_x15_r0_body.s216.ctl = false
kernel_rfl bodyTop217 : noRetBlock PRE_first_tail_x15_r0_body.s217 = true
kernel_rfl bodyCnt214 : countersOkB PRE_first_tail_x15_r0_body.s214 PRE_first_tail_x15_r0_body.s217 = true

theorem bodyGlue21 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11451, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.S203)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11451, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s217 PRE_first_tail_x15_r0_body.S217) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11451, 173, 0, 117⟩) bodyAcc203 PRE_first_tail_x15_r0_body.bodyRunSeg55 bodyAcc205 bodyHalt205 PRE_first_tail_x15_r0_body.bodyStepA56 bodyTop206 (fun _ hm => bodyO203 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr203).trans bodyInactive0) (bodyBr206.trans bodyBr203.symm) bodyCnt203 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11451, 173, 0, 117⟩) PRE_first_tail_x15_r0_body.sizeA56 PRE_first_tail_x15_r0_body.sizeArgsA56 PRE_first_tail_x15_r0_body.sizeSymA56 PRE_first_tail_x15_r0_body.sizeMlxA56 PRE_first_tail_x15_r0_body.sizePayA56 PRE_first_tail_x15_r0_body.sizeTaA56 PRE_first_tail_x15_r0_body.sizeDecA56 PRE_first_tail_x15_r0_body.sizePreA56 PRE_first_tail_x15_r0_body.bodyPatchB56 (fun _ hm => bodyO206 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr206).trans bodyInactive0) (bodyBr207.trans bodyBr206.symm) bodyCnt206 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11451, 173, 0, 117⟩) bodyAcc207 PRE_first_tail_x15_r0_body.bodyRunSeg56 bodyAcc209 bodyHalt209 PRE_first_tail_x15_r0_body.bodyStepA57 bodyTop210 (fun _ hm => bodyO207 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr207).trans bodyInactive0) (bodyBr210.trans bodyBr207.symm) bodyCnt207 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11451, 173, 0, 117⟩) PRE_first_tail_x15_r0_body.sizeA57 PRE_first_tail_x15_r0_body.sizeArgsA57 PRE_first_tail_x15_r0_body.sizeSymA57 PRE_first_tail_x15_r0_body.sizeMlxA57 PRE_first_tail_x15_r0_body.sizePayA57 PRE_first_tail_x15_r0_body.sizeTaA57 PRE_first_tail_x15_r0_body.sizeDecA57 PRE_first_tail_x15_r0_body.sizePreA57 PRE_first_tail_x15_r0_body.bodyPatchB57 (fun _ hm => bodyO210 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr210).trans bodyInactive0) (bodyBr211.trans bodyBr210.symm) bodyCnt210 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11451, 173, 0, 117⟩) bodyAcc211 PRE_first_tail_x15_r0_body.bodyRunSeg57 bodyAcc212 bodyHalt212 PRE_first_tail_x15_r0_body.bodyStepA58 bodyTop213 (fun _ hm => bodyO211 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr211).trans bodyInactive0) (bodyBr213.trans bodyBr211.symm) bodyCnt211 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11451, 173, 0, 117⟩) PRE_first_tail_x15_r0_body.sizeA58 PRE_first_tail_x15_r0_body.sizeArgsA58 PRE_first_tail_x15_r0_body.sizeSymA58 PRE_first_tail_x15_r0_body.sizeMlxA58 PRE_first_tail_x15_r0_body.sizePayA58 PRE_first_tail_x15_r0_body.sizeTaA58 PRE_first_tail_x15_r0_body.sizeDecA58 PRE_first_tail_x15_r0_body.sizePreA58 PRE_first_tail_x15_r0_body.bodyPatchB58 (fun _ hm => bodyO213 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr213).trans bodyInactive0) (bodyBr214.trans bodyBr213.symm) bodyCnt213 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11451, 173, 0, 117⟩) bodyAcc214 PRE_first_tail_x15_r0_body.bodyRunSeg58 bodyAcc216 bodyHalt216 PRE_first_tail_x15_r0_body.bodyStepA59 bodyTop217 (fun _ hm => bodyO214 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr214).trans bodyInactive0) (bodyBr217.trans bodyBr214.symm) bodyCnt214 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
