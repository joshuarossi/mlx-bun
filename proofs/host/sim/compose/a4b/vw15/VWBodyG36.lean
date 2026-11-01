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

kernel_rfl bodyO346 : PRE_first_tail_x15_r0_body.S346.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S346.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr346 : bridgeOf PRE_first_tail_x15_r0_body.s346.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc346 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s346 PRE_first_tail_x15_r0_body.S346) = fun _ _ => true
kernel_rfl bodyAcc348 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s348 PRE_first_tail_x15_r0_body.S348) = fun _ _ => true
kernel_rfl bodyBr349 : bridgeOf PRE_first_tail_x15_r0_body.s349.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt348 : isHalt PRE_first_tail_x15_r0_body.s348.ctl = false
kernel_rfl bodyTop349 : noRetBlock PRE_first_tail_x15_r0_body.s349 = true
kernel_rfl bodyCnt346 : countersOkB PRE_first_tail_x15_r0_body.s346 PRE_first_tail_x15_r0_body.s349 = true
kernel_rfl bodyO349 : PRE_first_tail_x15_r0_body.S349.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S349.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr350 : bridgeOf PRE_first_tail_x15_r0_body.s350.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt349 : countersOkB PRE_first_tail_x15_r0_body.s349 PRE_first_tail_x15_r0_body.s350 = true
kernel_rfl bodyO350 : PRE_first_tail_x15_r0_body.S350.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S350.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc350 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s350 PRE_first_tail_x15_r0_body.S350) = fun _ _ => true
kernel_rfl bodyAcc351 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s351 PRE_first_tail_x15_r0_body.S351) = fun _ _ => true
kernel_rfl bodyBr352 : bridgeOf PRE_first_tail_x15_r0_body.s352.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt351 : isHalt PRE_first_tail_x15_r0_body.s351.ctl = false
kernel_rfl bodyTop352 : noRetBlock PRE_first_tail_x15_r0_body.s352 = true
kernel_rfl bodyCnt350 : countersOkB PRE_first_tail_x15_r0_body.s350 PRE_first_tail_x15_r0_body.s352 = true
kernel_rfl bodyO352 : PRE_first_tail_x15_r0_body.S352.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S352.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr353 : bridgeOf PRE_first_tail_x15_r0_body.s353.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt352 : countersOkB PRE_first_tail_x15_r0_body.s352 PRE_first_tail_x15_r0_body.s353 = true
kernel_rfl bodyO353 : PRE_first_tail_x15_r0_body.S353.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S353.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc353 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s353 PRE_first_tail_x15_r0_body.S353) = fun _ _ => true
kernel_rfl bodyAcc354 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s354 PRE_first_tail_x15_r0_body.S354) = fun _ _ => true
kernel_rfl bodyBr355 : bridgeOf PRE_first_tail_x15_r0_body.s355.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt354 : isHalt PRE_first_tail_x15_r0_body.s354.ctl = false
kernel_rfl bodyTop355 : noRetBlock PRE_first_tail_x15_r0_body.s355 = true
kernel_rfl bodyCnt353 : countersOkB PRE_first_tail_x15_r0_body.s353 PRE_first_tail_x15_r0_body.s355 = true
kernel_rfl bodyO355 : PRE_first_tail_x15_r0_body.S355.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S355.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr356 : bridgeOf PRE_first_tail_x15_r0_body.s356.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt355 : countersOkB PRE_first_tail_x15_r0_body.s355 PRE_first_tail_x15_r0_body.s356 = true
kernel_rfl bodyO356 : PRE_first_tail_x15_r0_body.S356.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S356.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc356 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s356 PRE_first_tail_x15_r0_body.S356) = fun _ _ => true
kernel_rfl bodyAcc357 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s357 PRE_first_tail_x15_r0_body.S357) = fun _ _ => true
kernel_rfl bodyBr358 : bridgeOf PRE_first_tail_x15_r0_body.s358.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt357 : isHalt PRE_first_tail_x15_r0_body.s357.ctl = false
kernel_rfl bodyTop358 : noRetBlock PRE_first_tail_x15_r0_body.s358 = true
kernel_rfl bodyCnt356 : countersOkB PRE_first_tail_x15_r0_body.s356 PRE_first_tail_x15_r0_body.s358 = true
kernel_rfl bodyO358 : PRE_first_tail_x15_r0_body.S358.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S358.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr359 : bridgeOf PRE_first_tail_x15_r0_body.s359.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt358 : countersOkB PRE_first_tail_x15_r0_body.s358 PRE_first_tail_x15_r0_body.s359 = true
kernel_rfl bodyO359 : PRE_first_tail_x15_r0_body.S359.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S359.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc359 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s359 PRE_first_tail_x15_r0_body.S359) = fun _ _ => true
kernel_rfl bodyAcc360 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s360 PRE_first_tail_x15_r0_body.S360) = fun _ _ => true
kernel_rfl bodyBr361 : bridgeOf PRE_first_tail_x15_r0_body.s361.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt360 : isHalt PRE_first_tail_x15_r0_body.s360.ctl = false
kernel_rfl bodyTop361 : noRetBlock PRE_first_tail_x15_r0_body.s361 = true
kernel_rfl bodyCnt359 : countersOkB PRE_first_tail_x15_r0_body.s359 PRE_first_tail_x15_r0_body.s361 = true

theorem bodyGlue36 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15667, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s346 PRE_first_tail_x15_r0_body.S346)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15667, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s361 PRE_first_tail_x15_r0_body.S361) 14768 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) bodyAcc346 PRE_first_tail_x15_r0_body.bodyRunSeg93 bodyAcc348 bodyHalt348 PRE_first_tail_x15_r0_body.bodyStepA94 bodyTop349 (fun _ hm => bodyO346 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr346).trans bodyInactive0) (bodyBr349.trans bodyBr346.symm) bodyCnt346 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) PRE_first_tail_x15_r0_body.sizeA94 PRE_first_tail_x15_r0_body.sizeArgsA94 PRE_first_tail_x15_r0_body.sizeSymA94 PRE_first_tail_x15_r0_body.sizeMlxA94 PRE_first_tail_x15_r0_body.sizePayA94 PRE_first_tail_x15_r0_body.sizeTaA94 PRE_first_tail_x15_r0_body.sizeDecA94 PRE_first_tail_x15_r0_body.sizePreA94 PRE_first_tail_x15_r0_body.bodyPatchB94 (fun _ hm => bodyO349 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr349).trans bodyInactive0) (bodyBr350.trans bodyBr349.symm) bodyCnt349 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) bodyAcc350 PRE_first_tail_x15_r0_body.bodyRunSeg94 bodyAcc351 bodyHalt351 PRE_first_tail_x15_r0_body.bodyStepA95 bodyTop352 (fun _ hm => bodyO350 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr350).trans bodyInactive0) (bodyBr352.trans bodyBr350.symm) bodyCnt350 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) PRE_first_tail_x15_r0_body.sizeA95 PRE_first_tail_x15_r0_body.sizeArgsA95 PRE_first_tail_x15_r0_body.sizeSymA95 PRE_first_tail_x15_r0_body.sizeMlxA95 PRE_first_tail_x15_r0_body.sizePayA95 PRE_first_tail_x15_r0_body.sizeTaA95 PRE_first_tail_x15_r0_body.sizeDecA95 PRE_first_tail_x15_r0_body.sizePreA95 PRE_first_tail_x15_r0_body.bodyPatchB95 (fun _ hm => bodyO352 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr352).trans bodyInactive0) (bodyBr353.trans bodyBr352.symm) bodyCnt352 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) bodyAcc353 PRE_first_tail_x15_r0_body.bodyRunSeg95 bodyAcc354 bodyHalt354 PRE_first_tail_x15_r0_body.bodyStepA96 bodyTop355 (fun _ hm => bodyO353 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr353).trans bodyInactive0) (bodyBr355.trans bodyBr353.symm) bodyCnt353 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) PRE_first_tail_x15_r0_body.sizeA96 PRE_first_tail_x15_r0_body.sizeArgsA96 PRE_first_tail_x15_r0_body.sizeSymA96 PRE_first_tail_x15_r0_body.sizeMlxA96 PRE_first_tail_x15_r0_body.sizePayA96 PRE_first_tail_x15_r0_body.sizeTaA96 PRE_first_tail_x15_r0_body.sizeDecA96 PRE_first_tail_x15_r0_body.sizePreA96 PRE_first_tail_x15_r0_body.bodyPatchB96 (fun _ hm => bodyO355 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr355).trans bodyInactive0) (bodyBr356.trans bodyBr355.symm) bodyCnt355 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) bodyAcc356 PRE_first_tail_x15_r0_body.bodyRunSeg96 bodyAcc357 bodyHalt357 PRE_first_tail_x15_r0_body.bodyStepA97 bodyTop358 (fun _ hm => bodyO356 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr356).trans bodyInactive0) (bodyBr358.trans bodyBr356.symm) bodyCnt356 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) PRE_first_tail_x15_r0_body.sizeA97 PRE_first_tail_x15_r0_body.sizeArgsA97 PRE_first_tail_x15_r0_body.sizeSymA97 PRE_first_tail_x15_r0_body.sizeMlxA97 PRE_first_tail_x15_r0_body.sizePayA97 PRE_first_tail_x15_r0_body.sizeTaA97 PRE_first_tail_x15_r0_body.sizeDecA97 PRE_first_tail_x15_r0_body.sizePreA97 PRE_first_tail_x15_r0_body.bodyPatchB97 (fun _ hm => bodyO358 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr358).trans bodyInactive0) (bodyBr359.trans bodyBr358.symm) bodyCnt358 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15667, 252, 0, 189⟩) bodyAcc359 PRE_first_tail_x15_r0_body.bodyRunSeg97 bodyAcc360 bodyHalt360 PRE_first_tail_x15_r0_body.bodyStepA98 bodyTop361 (fun _ hm => bodyO359 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr359).trans bodyInactive0) (bodyBr361.trans bodyBr359.symm) bodyCnt359 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
