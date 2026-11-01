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

kernel_rfl bodyO967 : PRE_first_tail_x15_r0_body.S967.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S967.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr967 : bridgeOf PRE_first_tail_x15_r0_body.s967.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc967 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.S967) = fun _ _ => true
kernel_rfl bodyAcc968 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s968 PRE_first_tail_x15_r0_body.S968) = fun _ _ => true
kernel_rfl bodyBr969 : bridgeOf PRE_first_tail_x15_r0_body.s969.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt968 : isHalt PRE_first_tail_x15_r0_body.s968.ctl = false
kernel_rfl bodyTop969 : noRetBlock PRE_first_tail_x15_r0_body.s969 = true
kernel_rfl bodyCnt967 : countersOkB PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.s969 = true
kernel_rfl bodyO969 : PRE_first_tail_x15_r0_body.S969.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S969.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr970 : bridgeOf PRE_first_tail_x15_r0_body.s970.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt969 : countersOkB PRE_first_tail_x15_r0_body.s969 PRE_first_tail_x15_r0_body.s970 = true
kernel_rfl bodyO970 : PRE_first_tail_x15_r0_body.S970.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S970.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc970 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s970 PRE_first_tail_x15_r0_body.S970) = fun _ _ => true
kernel_rfl bodyAcc972 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s972 PRE_first_tail_x15_r0_body.S972) = fun _ _ => true
kernel_rfl bodyBr973 : bridgeOf PRE_first_tail_x15_r0_body.s973.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt972 : isHalt PRE_first_tail_x15_r0_body.s972.ctl = false
kernel_rfl bodyTop973 : noRetBlock PRE_first_tail_x15_r0_body.s973 = true
kernel_rfl bodyCnt970 : countersOkB PRE_first_tail_x15_r0_body.s970 PRE_first_tail_x15_r0_body.s973 = true

theorem bodyGlue100 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨37274, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.S967)
      (bodyCut NB T tk π i x0 bodyΘ ⟨37274, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s973 PRE_first_tail_x15_r0_body.S973) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37274, 687, 0, 540⟩) bodyAcc967 PRE_first_tail_x15_r0_body.bodyRunSeg261 bodyAcc968 bodyHalt968 PRE_first_tail_x15_r0_body.bodyStepA262 bodyTop969 (fun _ hm => bodyO967 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr967).trans bodyInactive0) (bodyBr969.trans bodyBr967.symm) bodyCnt967 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37274, 687, 0, 540⟩) PRE_first_tail_x15_r0_body.sizeA262 PRE_first_tail_x15_r0_body.sizeArgsA262 PRE_first_tail_x15_r0_body.sizeSymA262 PRE_first_tail_x15_r0_body.sizeMlxA262 PRE_first_tail_x15_r0_body.sizePayA262 PRE_first_tail_x15_r0_body.sizeTaA262 PRE_first_tail_x15_r0_body.sizeDecA262 PRE_first_tail_x15_r0_body.sizePreA262 PRE_first_tail_x15_r0_body.bodyPatchB262 (fun _ hm => bodyO969 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr969).trans bodyInactive0) (bodyBr970.trans bodyBr969.symm) bodyCnt969 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37274, 687, 0, 540⟩) bodyAcc970 PRE_first_tail_x15_r0_body.bodyRunSeg262 bodyAcc972 bodyHalt972 PRE_first_tail_x15_r0_body.bodyStepA263 bodyTop973 (fun _ hm => bodyO970 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr970).trans bodyInactive0) (bodyBr973.trans bodyBr970.symm) bodyCnt970 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
