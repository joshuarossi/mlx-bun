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

kernel_rfl bodyO634 : PRE_first_tail_x15_r0_body.S634.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S634.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr634 : bridgeOf PRE_first_tail_x15_r0_body.s634.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc634 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.S634) = fun _ _ => true
kernel_rfl bodyAcc636 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s636 PRE_first_tail_x15_r0_body.S636) = fun _ _ => true
kernel_rfl bodyBr637 : bridgeOf PRE_first_tail_x15_r0_body.s637.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt636 : isHalt PRE_first_tail_x15_r0_body.s636.ctl = false
kernel_rfl bodyTop637 : noRetBlock PRE_first_tail_x15_r0_body.s637 = true
kernel_rfl bodyCnt634 : countersOkB PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.s637 = true
kernel_rfl bodyO637 : PRE_first_tail_x15_r0_body.S637.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S637.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr638 : bridgeOf PRE_first_tail_x15_r0_body.s638.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt637 : countersOkB PRE_first_tail_x15_r0_body.s637 PRE_first_tail_x15_r0_body.s638 = true
kernel_rfl bodyO638 : PRE_first_tail_x15_r0_body.S638.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S638.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc638 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s638 PRE_first_tail_x15_r0_body.S638) = fun _ _ => true
kernel_rfl bodyAcc639 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s639 PRE_first_tail_x15_r0_body.S639) = fun _ _ => true
kernel_rfl bodyBr640 : bridgeOf PRE_first_tail_x15_r0_body.s640.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt639 : isHalt PRE_first_tail_x15_r0_body.s639.ctl = false
kernel_rfl bodyTop640 : noRetBlock PRE_first_tail_x15_r0_body.s640 = true
kernel_rfl bodyCnt638 : countersOkB PRE_first_tail_x15_r0_body.s638 PRE_first_tail_x15_r0_body.s640 = true
kernel_rfl bodyO640 : PRE_first_tail_x15_r0_body.S640.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S640.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr641 : bridgeOf PRE_first_tail_x15_r0_body.s641.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt640 : countersOkB PRE_first_tail_x15_r0_body.s640 PRE_first_tail_x15_r0_body.s641 = true
kernel_rfl bodyO641 : PRE_first_tail_x15_r0_body.S641.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S641.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc641 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s641 PRE_first_tail_x15_r0_body.S641) = fun _ _ => true
kernel_rfl bodyAcc642 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s642 PRE_first_tail_x15_r0_body.S642) = fun _ _ => true
kernel_rfl bodyBr643 : bridgeOf PRE_first_tail_x15_r0_body.s643.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt642 : isHalt PRE_first_tail_x15_r0_body.s642.ctl = false
kernel_rfl bodyTop643 : noRetBlock PRE_first_tail_x15_r0_body.s643 = true
kernel_rfl bodyCnt641 : countersOkB PRE_first_tail_x15_r0_body.s641 PRE_first_tail_x15_r0_body.s643 = true
kernel_rfl bodyO643 : PRE_first_tail_x15_r0_body.S643.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S643.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr644 : bridgeOf PRE_first_tail_x15_r0_body.s644.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt643 : countersOkB PRE_first_tail_x15_r0_body.s643 PRE_first_tail_x15_r0_body.s644 = true
kernel_rfl bodyO644 : PRE_first_tail_x15_r0_body.S644.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S644.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc644 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s644 PRE_first_tail_x15_r0_body.S644) = fun _ _ => true
kernel_rfl bodyAcc645 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s645 PRE_first_tail_x15_r0_body.S645) = fun _ _ => true
kernel_rfl bodyBr646 : bridgeOf PRE_first_tail_x15_r0_body.s646.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt645 : isHalt PRE_first_tail_x15_r0_body.s645.ctl = false
kernel_rfl bodyTop646 : noRetBlock PRE_first_tail_x15_r0_body.s646 = true
kernel_rfl bodyCnt644 : countersOkB PRE_first_tail_x15_r0_body.s644 PRE_first_tail_x15_r0_body.s646 = true
kernel_rfl bodyO646 : PRE_first_tail_x15_r0_body.S646.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S646.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr647 : bridgeOf PRE_first_tail_x15_r0_body.s647.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt646 : countersOkB PRE_first_tail_x15_r0_body.s646 PRE_first_tail_x15_r0_body.s647 = true
kernel_rfl bodyO647 : PRE_first_tail_x15_r0_body.S647.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S647.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc647 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s647 PRE_first_tail_x15_r0_body.S647) = fun _ _ => true
kernel_rfl bodyAcc648 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s648 PRE_first_tail_x15_r0_body.S648) = fun _ _ => true
kernel_rfl bodyBr649 : bridgeOf PRE_first_tail_x15_r0_body.s649.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt648 : isHalt PRE_first_tail_x15_r0_body.s648.ctl = false
kernel_rfl bodyTop649 : noRetBlock PRE_first_tail_x15_r0_body.s649 = true
kernel_rfl bodyCnt647 : countersOkB PRE_first_tail_x15_r0_body.s647 PRE_first_tail_x15_r0_body.s649 = true

theorem bodyGlue66 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨25724, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.S634)
      (bodyCut NB T tk π i x0 bodyΘ ⟨25724, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s649 PRE_first_tail_x15_r0_body.S649) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) bodyAcc634 PRE_first_tail_x15_r0_body.bodyRunSeg171 bodyAcc636 bodyHalt636 PRE_first_tail_x15_r0_body.bodyStepA172 bodyTop637 (fun _ hm => bodyO634 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr634).trans bodyInactive0) (bodyBr637.trans bodyBr634.symm) bodyCnt634 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) PRE_first_tail_x15_r0_body.sizeA172 PRE_first_tail_x15_r0_body.sizeArgsA172 PRE_first_tail_x15_r0_body.sizeSymA172 PRE_first_tail_x15_r0_body.sizeMlxA172 PRE_first_tail_x15_r0_body.sizePayA172 PRE_first_tail_x15_r0_body.sizeTaA172 PRE_first_tail_x15_r0_body.sizeDecA172 PRE_first_tail_x15_r0_body.sizePreA172 PRE_first_tail_x15_r0_body.bodyPatchB172 (fun _ hm => bodyO637 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr637).trans bodyInactive0) (bodyBr638.trans bodyBr637.symm) bodyCnt637 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) bodyAcc638 PRE_first_tail_x15_r0_body.bodyRunSeg172 bodyAcc639 bodyHalt639 PRE_first_tail_x15_r0_body.bodyStepA173 bodyTop640 (fun _ hm => bodyO638 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr638).trans bodyInactive0) (bodyBr640.trans bodyBr638.symm) bodyCnt638 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) PRE_first_tail_x15_r0_body.sizeA173 PRE_first_tail_x15_r0_body.sizeArgsA173 PRE_first_tail_x15_r0_body.sizeSymA173 PRE_first_tail_x15_r0_body.sizeMlxA173 PRE_first_tail_x15_r0_body.sizePayA173 PRE_first_tail_x15_r0_body.sizeTaA173 PRE_first_tail_x15_r0_body.sizeDecA173 PRE_first_tail_x15_r0_body.sizePreA173 PRE_first_tail_x15_r0_body.bodyPatchB173 (fun _ hm => bodyO640 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr640).trans bodyInactive0) (bodyBr641.trans bodyBr640.symm) bodyCnt640 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) bodyAcc641 PRE_first_tail_x15_r0_body.bodyRunSeg173 bodyAcc642 bodyHalt642 PRE_first_tail_x15_r0_body.bodyStepA174 bodyTop643 (fun _ hm => bodyO641 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr641).trans bodyInactive0) (bodyBr643.trans bodyBr641.symm) bodyCnt641 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) PRE_first_tail_x15_r0_body.sizeA174 PRE_first_tail_x15_r0_body.sizeArgsA174 PRE_first_tail_x15_r0_body.sizeSymA174 PRE_first_tail_x15_r0_body.sizeMlxA174 PRE_first_tail_x15_r0_body.sizePayA174 PRE_first_tail_x15_r0_body.sizeTaA174 PRE_first_tail_x15_r0_body.sizeDecA174 PRE_first_tail_x15_r0_body.sizePreA174 PRE_first_tail_x15_r0_body.bodyPatchB174 (fun _ hm => bodyO643 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr643).trans bodyInactive0) (bodyBr644.trans bodyBr643.symm) bodyCnt643 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) bodyAcc644 PRE_first_tail_x15_r0_body.bodyRunSeg174 bodyAcc645 bodyHalt645 PRE_first_tail_x15_r0_body.bodyStepA175 bodyTop646 (fun _ hm => bodyO644 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr644).trans bodyInactive0) (bodyBr646.trans bodyBr644.symm) bodyCnt644 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) PRE_first_tail_x15_r0_body.sizeA175 PRE_first_tail_x15_r0_body.sizeArgsA175 PRE_first_tail_x15_r0_body.sizeSymA175 PRE_first_tail_x15_r0_body.sizeMlxA175 PRE_first_tail_x15_r0_body.sizePayA175 PRE_first_tail_x15_r0_body.sizeTaA175 PRE_first_tail_x15_r0_body.sizeDecA175 PRE_first_tail_x15_r0_body.sizePreA175 PRE_first_tail_x15_r0_body.bodyPatchB175 (fun _ hm => bodyO646 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr646).trans bodyInactive0) (bodyBr647.trans bodyBr646.symm) bodyCnt646 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨25724, 456, 0, 351⟩) bodyAcc647 PRE_first_tail_x15_r0_body.bodyRunSeg175 bodyAcc648 bodyHalt648 PRE_first_tail_x15_r0_body.bodyStepA176 bodyTop649 (fun _ hm => bodyO647 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr647).trans bodyInactive0) (bodyBr649.trans bodyBr647.symm) bodyCnt647 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
