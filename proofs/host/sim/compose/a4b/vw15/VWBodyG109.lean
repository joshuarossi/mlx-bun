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

kernel_rfl bodyO1053 : PRE_first_tail_x15_r0_body.S1053.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1053.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1053 : bridgeOf PRE_first_tail_x15_r0_body.s1053.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1053 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.S1053) = fun _ _ => true
kernel_rfl bodyAcc1054 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1054 PRE_first_tail_x15_r0_body.S1054) = fun _ _ => true
kernel_rfl bodyBr1055 : bridgeOf PRE_first_tail_x15_r0_body.s1055.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1054 : isHalt PRE_first_tail_x15_r0_body.s1054.ctl = false
kernel_rfl bodyTop1055 : noRetBlock PRE_first_tail_x15_r0_body.s1055 = true
kernel_rfl bodyCnt1053 : countersOkB PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.s1055 = true
kernel_rfl bodyO1055 : PRE_first_tail_x15_r0_body.S1055.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1055.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1056 : bridgeOf PRE_first_tail_x15_r0_body.s1056.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1055 : countersOkB PRE_first_tail_x15_r0_body.s1055 PRE_first_tail_x15_r0_body.s1056 = true
kernel_rfl bodyO1056 : PRE_first_tail_x15_r0_body.S1056.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1056.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1056 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1056 PRE_first_tail_x15_r0_body.S1056) = fun _ _ => true
kernel_rfl bodyAcc1058 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1058 PRE_first_tail_x15_r0_body.S1058) = fun _ _ => true
kernel_rfl bodyBr1059 : bridgeOf PRE_first_tail_x15_r0_body.s1059.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1058 : isHalt PRE_first_tail_x15_r0_body.s1058.ctl = false
kernel_rfl bodyTop1059 : noRetBlock PRE_first_tail_x15_r0_body.s1059 = true
kernel_rfl bodyCnt1056 : countersOkB PRE_first_tail_x15_r0_body.s1056 PRE_first_tail_x15_r0_body.s1059 = true

theorem bodyGlue109 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨39967, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.S1053)
      (bodyCut NB T tk π i x0 bodyΘ ⟨39967, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1059 PRE_first_tail_x15_r0_body.S1059) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39967, 739, 0, 585⟩) bodyAcc1053 PRE_first_tail_x15_r0_body.bodyRunSeg284 bodyAcc1054 bodyHalt1054 PRE_first_tail_x15_r0_body.bodyStepA285 bodyTop1055 (fun _ hm => bodyO1053 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1053).trans bodyInactive0) (bodyBr1055.trans bodyBr1053.symm) bodyCnt1053 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39967, 739, 0, 585⟩) PRE_first_tail_x15_r0_body.sizeA285 PRE_first_tail_x15_r0_body.sizeArgsA285 PRE_first_tail_x15_r0_body.sizeSymA285 PRE_first_tail_x15_r0_body.sizeMlxA285 PRE_first_tail_x15_r0_body.sizePayA285 PRE_first_tail_x15_r0_body.sizeTaA285 PRE_first_tail_x15_r0_body.sizeDecA285 PRE_first_tail_x15_r0_body.sizePreA285 PRE_first_tail_x15_r0_body.bodyPatchB285 (fun _ hm => bodyO1055 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1055).trans bodyInactive0) (bodyBr1056.trans bodyBr1055.symm) bodyCnt1055 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39967, 739, 0, 585⟩) bodyAcc1056 PRE_first_tail_x15_r0_body.bodyRunSeg285 bodyAcc1058 bodyHalt1058 PRE_first_tail_x15_r0_body.bodyStepA286 bodyTop1059 (fun _ hm => bodyO1056 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1056).trans bodyInactive0) (bodyBr1059.trans bodyBr1056.symm) bodyCnt1056 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
