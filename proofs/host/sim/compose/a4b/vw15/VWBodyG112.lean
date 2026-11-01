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

kernel_rfl bodyO1082 : PRE_first_tail_x15_r0_body.S1082.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1082.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1082 : bridgeOf PRE_first_tail_x15_r0_body.s1082.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1082 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.S1082) = fun _ _ => true
kernel_rfl bodyAcc1083 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1083 PRE_first_tail_x15_r0_body.S1083) = fun _ _ => true
kernel_rfl bodyBr1084 : bridgeOf PRE_first_tail_x15_r0_body.s1084.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1083 : isHalt PRE_first_tail_x15_r0_body.s1083.ctl = false
kernel_rfl bodyTop1084 : noRetBlock PRE_first_tail_x15_r0_body.s1084 = true
kernel_rfl bodyCnt1082 : countersOkB PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.s1084 = true
kernel_rfl bodyO1084 : PRE_first_tail_x15_r0_body.S1084.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1084.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1085 : bridgeOf PRE_first_tail_x15_r0_body.s1085.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1084 : countersOkB PRE_first_tail_x15_r0_body.s1084 PRE_first_tail_x15_r0_body.s1085 = true
kernel_rfl bodyO1085 : PRE_first_tail_x15_r0_body.S1085.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1085.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1085 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1085 PRE_first_tail_x15_r0_body.S1085) = fun _ _ => true
kernel_rfl bodyAcc1087 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1087 PRE_first_tail_x15_r0_body.S1087) = fun _ _ => true
kernel_rfl bodyBr1088 : bridgeOf PRE_first_tail_x15_r0_body.s1088.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1087 : isHalt PRE_first_tail_x15_r0_body.s1087.ctl = false
kernel_rfl bodyTop1088 : noRetBlock PRE_first_tail_x15_r0_body.s1088 = true
kernel_rfl bodyCnt1085 : countersOkB PRE_first_tail_x15_r0_body.s1085 PRE_first_tail_x15_r0_body.s1088 = true

theorem bodyGlue112 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨41128, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.S1082)
      (bodyCut NB T tk π i x0 bodyΘ ⟨41128, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1088 PRE_first_tail_x15_r0_body.S1088) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41128, 764, 0, 603⟩) bodyAcc1082 PRE_first_tail_x15_r0_body.bodyRunSeg292 bodyAcc1083 bodyHalt1083 PRE_first_tail_x15_r0_body.bodyStepA293 bodyTop1084 (fun _ hm => bodyO1082 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1082).trans bodyInactive0) (bodyBr1084.trans bodyBr1082.symm) bodyCnt1082 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41128, 764, 0, 603⟩) PRE_first_tail_x15_r0_body.sizeA293 PRE_first_tail_x15_r0_body.sizeArgsA293 PRE_first_tail_x15_r0_body.sizeSymA293 PRE_first_tail_x15_r0_body.sizeMlxA293 PRE_first_tail_x15_r0_body.sizePayA293 PRE_first_tail_x15_r0_body.sizeTaA293 PRE_first_tail_x15_r0_body.sizeDecA293 PRE_first_tail_x15_r0_body.sizePreA293 PRE_first_tail_x15_r0_body.bodyPatchB293 (fun _ hm => bodyO1084 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1084).trans bodyInactive0) (bodyBr1085.trans bodyBr1084.symm) bodyCnt1084 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41128, 764, 0, 603⟩) bodyAcc1085 PRE_first_tail_x15_r0_body.bodyRunSeg293 bodyAcc1087 bodyHalt1087 PRE_first_tail_x15_r0_body.bodyStepA294 bodyTop1088 (fun _ hm => bodyO1085 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1085).trans bodyInactive0) (bodyBr1088.trans bodyBr1085.symm) bodyCnt1085 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
