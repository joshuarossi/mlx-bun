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

kernel_rfl bodyO318 : PRE_first_tail_x15_r0_body.S318.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S318.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr318 : bridgeOf PRE_first_tail_x15_r0_body.s318.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc318 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s318 PRE_first_tail_x15_r0_body.S318) = fun _ _ => true
kernel_rfl bodyAcc320 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s320 PRE_first_tail_x15_r0_body.S320) = fun _ _ => true
kernel_rfl bodyBr321 : bridgeOf PRE_first_tail_x15_r0_body.s321.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt320 : isHalt PRE_first_tail_x15_r0_body.s320.ctl = false
kernel_rfl bodyTop321 : noRetBlock PRE_first_tail_x15_r0_body.s321 = true
kernel_rfl bodyCnt318 : countersOkB PRE_first_tail_x15_r0_body.s318 PRE_first_tail_x15_r0_body.s321 = true
kernel_rfl bodyO321 : PRE_first_tail_x15_r0_body.S321.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S321.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr322 : bridgeOf PRE_first_tail_x15_r0_body.s322.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt321 : countersOkB PRE_first_tail_x15_r0_body.s321 PRE_first_tail_x15_r0_body.s322 = true
kernel_rfl bodyO322 : PRE_first_tail_x15_r0_body.S322.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S322.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc322 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s322 PRE_first_tail_x15_r0_body.S322) = fun _ _ => true
kernel_rfl bodyAcc324 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s324 PRE_first_tail_x15_r0_body.S324) = fun _ _ => true
kernel_rfl bodyBr325 : bridgeOf PRE_first_tail_x15_r0_body.s325.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt324 : isHalt PRE_first_tail_x15_r0_body.s324.ctl = false
kernel_rfl bodyTop325 : noRetBlock PRE_first_tail_x15_r0_body.s325 = true
kernel_rfl bodyCnt322 : countersOkB PRE_first_tail_x15_r0_body.s322 PRE_first_tail_x15_r0_body.s325 = true
kernel_rfl bodyO325 : PRE_first_tail_x15_r0_body.S325.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S325.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr326 : bridgeOf PRE_first_tail_x15_r0_body.s326.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt325 : countersOkB PRE_first_tail_x15_r0_body.s325 PRE_first_tail_x15_r0_body.s326 = true
kernel_rfl bodyO326 : PRE_first_tail_x15_r0_body.S326.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S326.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc326 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s326 PRE_first_tail_x15_r0_body.S326) = fun _ _ => true
kernel_rfl bodyAcc327 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s327 PRE_first_tail_x15_r0_body.S327) = fun _ _ => true
kernel_rfl bodyBr328 : bridgeOf PRE_first_tail_x15_r0_body.s328.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt327 : isHalt PRE_first_tail_x15_r0_body.s327.ctl = false
kernel_rfl bodyTop328 : noRetBlock PRE_first_tail_x15_r0_body.s328 = true
kernel_rfl bodyCnt326 : countersOkB PRE_first_tail_x15_r0_body.s326 PRE_first_tail_x15_r0_body.s328 = true
kernel_rfl bodyO328 : PRE_first_tail_x15_r0_body.S328.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S328.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr329 : bridgeOf PRE_first_tail_x15_r0_body.s329.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt328 : countersOkB PRE_first_tail_x15_r0_body.s328 PRE_first_tail_x15_r0_body.s329 = true
kernel_rfl bodyO329 : PRE_first_tail_x15_r0_body.S329.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S329.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc329 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s329 PRE_first_tail_x15_r0_body.S329) = fun _ _ => true
kernel_rfl bodyAcc331 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s331 PRE_first_tail_x15_r0_body.S331) = fun _ _ => true
kernel_rfl bodyBr332 : bridgeOf PRE_first_tail_x15_r0_body.s332.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt331 : isHalt PRE_first_tail_x15_r0_body.s331.ctl = false
kernel_rfl bodyTop332 : noRetBlock PRE_first_tail_x15_r0_body.s332 = true
kernel_rfl bodyCnt329 : countersOkB PRE_first_tail_x15_r0_body.s329 PRE_first_tail_x15_r0_body.s332 = true

theorem bodyGlue33 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15296, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s318 PRE_first_tail_x15_r0_body.S318)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15296, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s332 PRE_first_tail_x15_r0_body.S332) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15296, 250, 0, 180⟩) bodyAcc318 PRE_first_tail_x15_r0_body.bodyRunSeg86 bodyAcc320 bodyHalt320 PRE_first_tail_x15_r0_body.bodyStepA87 bodyTop321 (fun _ hm => bodyO318 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr318).trans bodyInactive0) (bodyBr321.trans bodyBr318.symm) bodyCnt318 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15296, 250, 0, 180⟩) PRE_first_tail_x15_r0_body.sizeA87 PRE_first_tail_x15_r0_body.sizeArgsA87 PRE_first_tail_x15_r0_body.sizeSymA87 PRE_first_tail_x15_r0_body.sizeMlxA87 PRE_first_tail_x15_r0_body.sizePayA87 PRE_first_tail_x15_r0_body.sizeTaA87 PRE_first_tail_x15_r0_body.sizeDecA87 PRE_first_tail_x15_r0_body.sizePreA87 PRE_first_tail_x15_r0_body.bodyPatchB87 (fun _ hm => bodyO321 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr321).trans bodyInactive0) (bodyBr322.trans bodyBr321.symm) bodyCnt321 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15296, 250, 0, 180⟩) bodyAcc322 PRE_first_tail_x15_r0_body.bodyRunSeg87 bodyAcc324 bodyHalt324 PRE_first_tail_x15_r0_body.bodyStepA88 bodyTop325 (fun _ hm => bodyO322 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr322).trans bodyInactive0) (bodyBr325.trans bodyBr322.symm) bodyCnt322 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15296, 250, 0, 180⟩) PRE_first_tail_x15_r0_body.sizeA88 PRE_first_tail_x15_r0_body.sizeArgsA88 PRE_first_tail_x15_r0_body.sizeSymA88 PRE_first_tail_x15_r0_body.sizeMlxA88 PRE_first_tail_x15_r0_body.sizePayA88 PRE_first_tail_x15_r0_body.sizeTaA88 PRE_first_tail_x15_r0_body.sizeDecA88 PRE_first_tail_x15_r0_body.sizePreA88 PRE_first_tail_x15_r0_body.bodyPatchB88 (fun _ hm => bodyO325 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr325).trans bodyInactive0) (bodyBr326.trans bodyBr325.symm) bodyCnt325 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15296, 250, 0, 180⟩) bodyAcc326 PRE_first_tail_x15_r0_body.bodyRunSeg88 bodyAcc327 bodyHalt327 PRE_first_tail_x15_r0_body.bodyStepA89 bodyTop328 (fun _ hm => bodyO326 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr326).trans bodyInactive0) (bodyBr328.trans bodyBr326.symm) bodyCnt326 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15296, 250, 0, 180⟩) PRE_first_tail_x15_r0_body.sizeA89 PRE_first_tail_x15_r0_body.sizeArgsA89 PRE_first_tail_x15_r0_body.sizeSymA89 PRE_first_tail_x15_r0_body.sizeMlxA89 PRE_first_tail_x15_r0_body.sizePayA89 PRE_first_tail_x15_r0_body.sizeTaA89 PRE_first_tail_x15_r0_body.sizeDecA89 PRE_first_tail_x15_r0_body.sizePreA89 PRE_first_tail_x15_r0_body.bodyPatchB89 (fun _ hm => bodyO328 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr328).trans bodyInactive0) (bodyBr329.trans bodyBr328.symm) bodyCnt328 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15296, 250, 0, 180⟩) bodyAcc329 PRE_first_tail_x15_r0_body.bodyRunSeg89 bodyAcc331 bodyHalt331 PRE_first_tail_x15_r0_body.bodyStepA90 bodyTop332 (fun _ hm => bodyO329 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr329).trans bodyInactive0) (bodyBr332.trans bodyBr329.symm) bodyCnt329 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
