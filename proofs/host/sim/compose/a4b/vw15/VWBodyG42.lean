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

kernel_rfl bodyO404 : PRE_first_tail_x15_r0_body.S404.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S404.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr404 : bridgeOf PRE_first_tail_x15_r0_body.s404.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc404 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.S404) = fun _ _ => true
kernel_rfl bodyAcc406 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s406 PRE_first_tail_x15_r0_body.S406) = fun _ _ => true
kernel_rfl bodyBr407 : bridgeOf PRE_first_tail_x15_r0_body.s407.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt406 : isHalt PRE_first_tail_x15_r0_body.s406.ctl = false
kernel_rfl bodyTop407 : noRetBlock PRE_first_tail_x15_r0_body.s407 = true
kernel_rfl bodyCnt404 : countersOkB PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.s407 = true
kernel_rfl bodyO407 : PRE_first_tail_x15_r0_body.S407.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S407.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr408 : bridgeOf PRE_first_tail_x15_r0_body.s408.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt407 : countersOkB PRE_first_tail_x15_r0_body.s407 PRE_first_tail_x15_r0_body.s408 = true
kernel_rfl bodyO408 : PRE_first_tail_x15_r0_body.S408.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S408.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc408 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s408 PRE_first_tail_x15_r0_body.S408) = fun _ _ => true
kernel_rfl bodyAcc409 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s409 PRE_first_tail_x15_r0_body.S409) = fun _ _ => true
kernel_rfl bodyBr410 : bridgeOf PRE_first_tail_x15_r0_body.s410.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt409 : isHalt PRE_first_tail_x15_r0_body.s409.ctl = false
kernel_rfl bodyTop410 : noRetBlock PRE_first_tail_x15_r0_body.s410 = true
kernel_rfl bodyCnt408 : countersOkB PRE_first_tail_x15_r0_body.s408 PRE_first_tail_x15_r0_body.s410 = true
kernel_rfl bodyO410 : PRE_first_tail_x15_r0_body.S410.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S410.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr411 : bridgeOf PRE_first_tail_x15_r0_body.s411.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt410 : countersOkB PRE_first_tail_x15_r0_body.s410 PRE_first_tail_x15_r0_body.s411 = true
kernel_rfl bodyO411 : PRE_first_tail_x15_r0_body.S411.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S411.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc411 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s411 PRE_first_tail_x15_r0_body.S411) = fun _ _ => true
kernel_rfl bodyAcc412 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s412 PRE_first_tail_x15_r0_body.S412) = fun _ _ => true
kernel_rfl bodyBr413 : bridgeOf PRE_first_tail_x15_r0_body.s413.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt412 : isHalt PRE_first_tail_x15_r0_body.s412.ctl = false
kernel_rfl bodyTop413 : noRetBlock PRE_first_tail_x15_r0_body.s413 = true
kernel_rfl bodyCnt411 : countersOkB PRE_first_tail_x15_r0_body.s411 PRE_first_tail_x15_r0_body.s413 = true
kernel_rfl bodyO413 : PRE_first_tail_x15_r0_body.S413.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S413.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr414 : bridgeOf PRE_first_tail_x15_r0_body.s414.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt413 : countersOkB PRE_first_tail_x15_r0_body.s413 PRE_first_tail_x15_r0_body.s414 = true
kernel_rfl bodyO414 : PRE_first_tail_x15_r0_body.S414.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S414.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc414 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s414 PRE_first_tail_x15_r0_body.S414) = fun _ _ => true
kernel_rfl bodyAcc415 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s415 PRE_first_tail_x15_r0_body.S415) = fun _ _ => true
kernel_rfl bodyBr416 : bridgeOf PRE_first_tail_x15_r0_body.s416.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt415 : isHalt PRE_first_tail_x15_r0_body.s415.ctl = false
kernel_rfl bodyTop416 : noRetBlock PRE_first_tail_x15_r0_body.s416 = true
kernel_rfl bodyCnt414 : countersOkB PRE_first_tail_x15_r0_body.s414 PRE_first_tail_x15_r0_body.s416 = true
kernel_rfl bodyO416 : PRE_first_tail_x15_r0_body.S416.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S416.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr417 : bridgeOf PRE_first_tail_x15_r0_body.s417.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt416 : countersOkB PRE_first_tail_x15_r0_body.s416 PRE_first_tail_x15_r0_body.s417 = true
kernel_rfl bodyO417 : PRE_first_tail_x15_r0_body.S417.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S417.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc417 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s417 PRE_first_tail_x15_r0_body.S417) = fun _ _ => true
kernel_rfl bodyAcc418 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s418 PRE_first_tail_x15_r0_body.S418) = fun _ _ => true
kernel_rfl bodyBr419 : bridgeOf PRE_first_tail_x15_r0_body.s419.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt418 : isHalt PRE_first_tail_x15_r0_body.s418.ctl = false
kernel_rfl bodyTop419 : noRetBlock PRE_first_tail_x15_r0_body.s419 = true
kernel_rfl bodyCnt417 : countersOkB PRE_first_tail_x15_r0_body.s417 PRE_first_tail_x15_r0_body.s419 = true

theorem bodyGlue42 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17998, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.S404)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17998, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s419 PRE_first_tail_x15_r0_body.S419) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc404 PRE_first_tail_x15_r0_body.bodyRunSeg109 bodyAcc406 bodyHalt406 PRE_first_tail_x15_r0_body.bodyStepA110 bodyTop407 (fun _ hm => bodyO404 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr404).trans bodyInactive0) (bodyBr407.trans bodyBr404.symm) bodyCnt404 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA110 PRE_first_tail_x15_r0_body.sizeArgsA110 PRE_first_tail_x15_r0_body.sizeSymA110 PRE_first_tail_x15_r0_body.sizeMlxA110 PRE_first_tail_x15_r0_body.sizePayA110 PRE_first_tail_x15_r0_body.sizeTaA110 PRE_first_tail_x15_r0_body.sizeDecA110 PRE_first_tail_x15_r0_body.sizePreA110 PRE_first_tail_x15_r0_body.bodyPatchB110 (fun _ hm => bodyO407 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr407).trans bodyInactive0) (bodyBr408.trans bodyBr407.symm) bodyCnt407 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc408 PRE_first_tail_x15_r0_body.bodyRunSeg110 bodyAcc409 bodyHalt409 PRE_first_tail_x15_r0_body.bodyStepA111 bodyTop410 (fun _ hm => bodyO408 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr408).trans bodyInactive0) (bodyBr410.trans bodyBr408.symm) bodyCnt408 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA111 PRE_first_tail_x15_r0_body.sizeArgsA111 PRE_first_tail_x15_r0_body.sizeSymA111 PRE_first_tail_x15_r0_body.sizeMlxA111 PRE_first_tail_x15_r0_body.sizePayA111 PRE_first_tail_x15_r0_body.sizeTaA111 PRE_first_tail_x15_r0_body.sizeDecA111 PRE_first_tail_x15_r0_body.sizePreA111 PRE_first_tail_x15_r0_body.bodyPatchB111 (fun _ hm => bodyO410 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr410).trans bodyInactive0) (bodyBr411.trans bodyBr410.symm) bodyCnt410 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc411 PRE_first_tail_x15_r0_body.bodyRunSeg111 bodyAcc412 bodyHalt412 PRE_first_tail_x15_r0_body.bodyStepA112 bodyTop413 (fun _ hm => bodyO411 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr411).trans bodyInactive0) (bodyBr413.trans bodyBr411.symm) bodyCnt411 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA112 PRE_first_tail_x15_r0_body.sizeArgsA112 PRE_first_tail_x15_r0_body.sizeSymA112 PRE_first_tail_x15_r0_body.sizeMlxA112 PRE_first_tail_x15_r0_body.sizePayA112 PRE_first_tail_x15_r0_body.sizeTaA112 PRE_first_tail_x15_r0_body.sizeDecA112 PRE_first_tail_x15_r0_body.sizePreA112 PRE_first_tail_x15_r0_body.bodyPatchB112 (fun _ hm => bodyO413 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr413).trans bodyInactive0) (bodyBr414.trans bodyBr413.symm) bodyCnt413 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc414 PRE_first_tail_x15_r0_body.bodyRunSeg112 bodyAcc415 bodyHalt415 PRE_first_tail_x15_r0_body.bodyStepA113 bodyTop416 (fun _ hm => bodyO414 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr414).trans bodyInactive0) (bodyBr416.trans bodyBr414.symm) bodyCnt414 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) PRE_first_tail_x15_r0_body.sizeA113 PRE_first_tail_x15_r0_body.sizeArgsA113 PRE_first_tail_x15_r0_body.sizeSymA113 PRE_first_tail_x15_r0_body.sizeMlxA113 PRE_first_tail_x15_r0_body.sizePayA113 PRE_first_tail_x15_r0_body.sizeTaA113 PRE_first_tail_x15_r0_body.sizeDecA113 PRE_first_tail_x15_r0_body.sizePreA113 PRE_first_tail_x15_r0_body.bodyPatchB113 (fun _ hm => bodyO416 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr416).trans bodyInactive0) (bodyBr417.trans bodyBr416.symm) bodyCnt416 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17998, 302, 0, 225⟩) bodyAcc417 PRE_first_tail_x15_r0_body.bodyRunSeg113 bodyAcc418 bodyHalt418 PRE_first_tail_x15_r0_body.bodyStepA114 bodyTop419 (fun _ hm => bodyO417 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr417).trans bodyInactive0) (bodyBr419.trans bodyBr417.symm) bodyCnt417 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
