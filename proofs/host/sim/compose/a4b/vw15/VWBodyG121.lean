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

kernel_rfl bodyO1168 : PRE_first_tail_x15_r0_body.S1168.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1168.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1168 : bridgeOf PRE_first_tail_x15_r0_body.s1168.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1168 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1168 PRE_first_tail_x15_r0_body.S1168) = fun _ _ => true
kernel_rfl bodyAcc1169 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1169 PRE_first_tail_x15_r0_body.S1169) = fun _ _ => true
kernel_rfl bodyBr1170 : bridgeOf PRE_first_tail_x15_r0_body.s1170.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1169 : isHalt PRE_first_tail_x15_r0_body.s1169.ctl = false
kernel_rfl bodyTop1170 : noRetBlock PRE_first_tail_x15_r0_body.s1170 = true
kernel_rfl bodyCnt1168 : countersOkB PRE_first_tail_x15_r0_body.s1168 PRE_first_tail_x15_r0_body.s1170 = true
kernel_rfl bodyO1170 : PRE_first_tail_x15_r0_body.S1170.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1170.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1171 : bridgeOf PRE_first_tail_x15_r0_body.s1171.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1170 : countersOkB PRE_first_tail_x15_r0_body.s1170 PRE_first_tail_x15_r0_body.s1171 = true
kernel_rfl bodyO1171 : PRE_first_tail_x15_r0_body.S1171.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1171.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1171 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1171 PRE_first_tail_x15_r0_body.S1171) = fun _ _ => true
kernel_rfl bodyAcc1173 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1173 PRE_first_tail_x15_r0_body.S1173) = fun _ _ => true
kernel_rfl bodyBr1174 : bridgeOf PRE_first_tail_x15_r0_body.s1174.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1173 : isHalt PRE_first_tail_x15_r0_body.s1173.ctl = false
kernel_rfl bodyTop1174 : noRetBlock PRE_first_tail_x15_r0_body.s1174 = true
kernel_rfl bodyCnt1171 : countersOkB PRE_first_tail_x15_r0_body.s1171 PRE_first_tail_x15_r0_body.s1174 = true

theorem bodyGlue121 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨43812, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1168 PRE_first_tail_x15_r0_body.S1168)
      (bodyCut NB T tk π i x0 bodyΘ ⟨43812, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1174 PRE_first_tail_x15_r0_body.S1174) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43812, 816, 0, 648⟩) bodyAcc1168 PRE_first_tail_x15_r0_body.bodyRunSeg315 bodyAcc1169 bodyHalt1169 PRE_first_tail_x15_r0_body.bodyStepA316 bodyTop1170 (fun _ hm => bodyO1168 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1168).trans bodyInactive0) (bodyBr1170.trans bodyBr1168.symm) bodyCnt1168 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43812, 816, 0, 648⟩) PRE_first_tail_x15_r0_body.sizeA316 PRE_first_tail_x15_r0_body.sizeArgsA316 PRE_first_tail_x15_r0_body.sizeSymA316 PRE_first_tail_x15_r0_body.sizeMlxA316 PRE_first_tail_x15_r0_body.sizePayA316 PRE_first_tail_x15_r0_body.sizeTaA316 PRE_first_tail_x15_r0_body.sizeDecA316 PRE_first_tail_x15_r0_body.sizePreA316 PRE_first_tail_x15_r0_body.bodyPatchB316 (fun _ hm => bodyO1170 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1170).trans bodyInactive0) (bodyBr1171.trans bodyBr1170.symm) bodyCnt1170 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43812, 816, 0, 648⟩) bodyAcc1171 PRE_first_tail_x15_r0_body.bodyRunSeg316 bodyAcc1173 bodyHalt1173 PRE_first_tail_x15_r0_body.bodyStepA317 bodyTop1174 (fun _ hm => bodyO1171 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1171).trans bodyInactive0) (bodyBr1174.trans bodyBr1171.symm) bodyCnt1171 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
