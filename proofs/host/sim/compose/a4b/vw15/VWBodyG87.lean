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

kernel_rfl bodyO835 : PRE_first_tail_x15_r0_body.S835.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S835.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr835 : bridgeOf PRE_first_tail_x15_r0_body.s835.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc835 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s835 PRE_first_tail_x15_r0_body.S835) = fun _ _ => true
kernel_rfl bodyAcc837 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s837 PRE_first_tail_x15_r0_body.S837) = fun _ _ => true
kernel_rfl bodyBr838 : bridgeOf PRE_first_tail_x15_r0_body.s838.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt837 : isHalt PRE_first_tail_x15_r0_body.s837.ctl = false
kernel_rfl bodyTop838 : noRetBlock PRE_first_tail_x15_r0_body.s838 = true
kernel_rfl bodyCnt835 : countersOkB PRE_first_tail_x15_r0_body.s835 PRE_first_tail_x15_r0_body.s838 = true
kernel_rfl bodyO838 : PRE_first_tail_x15_r0_body.S838.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S838.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr839 : bridgeOf PRE_first_tail_x15_r0_body.s839.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt838 : countersOkB PRE_first_tail_x15_r0_body.s838 PRE_first_tail_x15_r0_body.s839 = true
kernel_rfl bodyO839 : PRE_first_tail_x15_r0_body.S839.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S839.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc839 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s839 PRE_first_tail_x15_r0_body.S839) = fun _ _ => true
kernel_rfl bodyAcc840 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s840 PRE_first_tail_x15_r0_body.S840) = fun _ _ => true
kernel_rfl bodyBr841 : bridgeOf PRE_first_tail_x15_r0_body.s841.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt840 : isHalt PRE_first_tail_x15_r0_body.s840.ctl = false
kernel_rfl bodyTop841 : noRetBlock PRE_first_tail_x15_r0_body.s841 = true
kernel_rfl bodyCnt839 : countersOkB PRE_first_tail_x15_r0_body.s839 PRE_first_tail_x15_r0_body.s841 = true
kernel_rfl bodyO841 : PRE_first_tail_x15_r0_body.S841.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S841.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr842 : bridgeOf PRE_first_tail_x15_r0_body.s842.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt841 : countersOkB PRE_first_tail_x15_r0_body.s841 PRE_first_tail_x15_r0_body.s842 = true
kernel_rfl bodyO842 : PRE_first_tail_x15_r0_body.S842.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S842.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc842 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s842 PRE_first_tail_x15_r0_body.S842) = fun _ _ => true
kernel_rfl bodyAcc843 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s843 PRE_first_tail_x15_r0_body.S843) = fun _ _ => true
kernel_rfl bodyBr844 : bridgeOf PRE_first_tail_x15_r0_body.s844.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt843 : isHalt PRE_first_tail_x15_r0_body.s843.ctl = false
kernel_rfl bodyTop844 : noRetBlock PRE_first_tail_x15_r0_body.s844 = true
kernel_rfl bodyCnt842 : countersOkB PRE_first_tail_x15_r0_body.s842 PRE_first_tail_x15_r0_body.s844 = true
kernel_rfl bodyO844 : PRE_first_tail_x15_r0_body.S844.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S844.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr845 : bridgeOf PRE_first_tail_x15_r0_body.s845.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt844 : countersOkB PRE_first_tail_x15_r0_body.s844 PRE_first_tail_x15_r0_body.s845 = true
kernel_rfl bodyO845 : PRE_first_tail_x15_r0_body.S845.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S845.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc845 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s845 PRE_first_tail_x15_r0_body.S845) = fun _ _ => true
kernel_rfl bodyAcc846 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s846 PRE_first_tail_x15_r0_body.S846) = fun _ _ => true
kernel_rfl bodyBr847 : bridgeOf PRE_first_tail_x15_r0_body.s847.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt846 : isHalt PRE_first_tail_x15_r0_body.s846.ctl = false
kernel_rfl bodyTop847 : noRetBlock PRE_first_tail_x15_r0_body.s847 = true
kernel_rfl bodyCnt845 : countersOkB PRE_first_tail_x15_r0_body.s845 PRE_first_tail_x15_r0_body.s847 = true
kernel_rfl bodyO847 : PRE_first_tail_x15_r0_body.S847.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S847.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr848 : bridgeOf PRE_first_tail_x15_r0_body.s848.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt847 : countersOkB PRE_first_tail_x15_r0_body.s847 PRE_first_tail_x15_r0_body.s848 = true
kernel_rfl bodyO848 : PRE_first_tail_x15_r0_body.S848.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S848.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc848 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s848 PRE_first_tail_x15_r0_body.S848) = fun _ _ => true
kernel_rfl bodyAcc849 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s849 PRE_first_tail_x15_r0_body.S849) = fun _ _ => true
kernel_rfl bodyBr850 : bridgeOf PRE_first_tail_x15_r0_body.s850.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt849 : isHalt PRE_first_tail_x15_r0_body.s849.ctl = false
kernel_rfl bodyTop850 : noRetBlock PRE_first_tail_x15_r0_body.s850 = true
kernel_rfl bodyCnt848 : countersOkB PRE_first_tail_x15_r0_body.s848 PRE_first_tail_x15_r0_body.s850 = true

theorem bodyGlue87 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨32253, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s835 PRE_first_tail_x15_r0_body.S835)
      (bodyCut NB T tk π i x0 bodyΘ ⟨32253, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s850 PRE_first_tail_x15_r0_body.S850) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) bodyAcc835 PRE_first_tail_x15_r0_body.bodyRunSeg225 bodyAcc837 bodyHalt837 PRE_first_tail_x15_r0_body.bodyStepA226 bodyTop838 (fun _ hm => bodyO835 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr835).trans bodyInactive0) (bodyBr838.trans bodyBr835.symm) bodyCnt835 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) PRE_first_tail_x15_r0_body.sizeA226 PRE_first_tail_x15_r0_body.sizeArgsA226 PRE_first_tail_x15_r0_body.sizeSymA226 PRE_first_tail_x15_r0_body.sizeMlxA226 PRE_first_tail_x15_r0_body.sizePayA226 PRE_first_tail_x15_r0_body.sizeTaA226 PRE_first_tail_x15_r0_body.sizeDecA226 PRE_first_tail_x15_r0_body.sizePreA226 PRE_first_tail_x15_r0_body.bodyPatchB226 (fun _ hm => bodyO838 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr838).trans bodyInactive0) (bodyBr839.trans bodyBr838.symm) bodyCnt838 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) bodyAcc839 PRE_first_tail_x15_r0_body.bodyRunSeg226 bodyAcc840 bodyHalt840 PRE_first_tail_x15_r0_body.bodyStepA227 bodyTop841 (fun _ hm => bodyO839 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr839).trans bodyInactive0) (bodyBr841.trans bodyBr839.symm) bodyCnt839 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) PRE_first_tail_x15_r0_body.sizeA227 PRE_first_tail_x15_r0_body.sizeArgsA227 PRE_first_tail_x15_r0_body.sizeSymA227 PRE_first_tail_x15_r0_body.sizeMlxA227 PRE_first_tail_x15_r0_body.sizePayA227 PRE_first_tail_x15_r0_body.sizeTaA227 PRE_first_tail_x15_r0_body.sizeDecA227 PRE_first_tail_x15_r0_body.sizePreA227 PRE_first_tail_x15_r0_body.bodyPatchB227 (fun _ hm => bodyO841 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr841).trans bodyInactive0) (bodyBr842.trans bodyBr841.symm) bodyCnt841 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) bodyAcc842 PRE_first_tail_x15_r0_body.bodyRunSeg227 bodyAcc843 bodyHalt843 PRE_first_tail_x15_r0_body.bodyStepA228 bodyTop844 (fun _ hm => bodyO842 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr842).trans bodyInactive0) (bodyBr844.trans bodyBr842.symm) bodyCnt842 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) PRE_first_tail_x15_r0_body.sizeA228 PRE_first_tail_x15_r0_body.sizeArgsA228 PRE_first_tail_x15_r0_body.sizeSymA228 PRE_first_tail_x15_r0_body.sizeMlxA228 PRE_first_tail_x15_r0_body.sizePayA228 PRE_first_tail_x15_r0_body.sizeTaA228 PRE_first_tail_x15_r0_body.sizeDecA228 PRE_first_tail_x15_r0_body.sizePreA228 PRE_first_tail_x15_r0_body.bodyPatchB228 (fun _ hm => bodyO844 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr844).trans bodyInactive0) (bodyBr845.trans bodyBr844.symm) bodyCnt844 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) bodyAcc845 PRE_first_tail_x15_r0_body.bodyRunSeg228 bodyAcc846 bodyHalt846 PRE_first_tail_x15_r0_body.bodyStepA229 bodyTop847 (fun _ hm => bodyO845 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr845).trans bodyInactive0) (bodyBr847.trans bodyBr845.symm) bodyCnt845 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) PRE_first_tail_x15_r0_body.sizeA229 PRE_first_tail_x15_r0_body.sizeArgsA229 PRE_first_tail_x15_r0_body.sizeSymA229 PRE_first_tail_x15_r0_body.sizeMlxA229 PRE_first_tail_x15_r0_body.sizePayA229 PRE_first_tail_x15_r0_body.sizeTaA229 PRE_first_tail_x15_r0_body.sizeDecA229 PRE_first_tail_x15_r0_body.sizePreA229 PRE_first_tail_x15_r0_body.bodyPatchB229 (fun _ hm => bodyO847 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr847).trans bodyInactive0) (bodyBr848.trans bodyBr847.symm) bodyCnt847 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32253, 585, 0, 459⟩) bodyAcc848 PRE_first_tail_x15_r0_body.bodyRunSeg229 bodyAcc849 bodyHalt849 PRE_first_tail_x15_r0_body.bodyStepA230 bodyTop850 (fun _ hm => bodyO848 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr848).trans bodyInactive0) (bodyBr850.trans bodyBr848.symm) bodyCnt848 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
