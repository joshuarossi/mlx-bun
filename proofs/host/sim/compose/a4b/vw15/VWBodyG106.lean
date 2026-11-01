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

kernel_rfl bodyO1024 : PRE_first_tail_x15_r0_body.S1024.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1024.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1024 : bridgeOf PRE_first_tail_x15_r0_body.s1024.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1024 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.S1024) = fun _ _ => true
kernel_rfl bodyAcc1025 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1025 PRE_first_tail_x15_r0_body.S1025) = fun _ _ => true
kernel_rfl bodyBr1026 : bridgeOf PRE_first_tail_x15_r0_body.s1026.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1025 : isHalt PRE_first_tail_x15_r0_body.s1025.ctl = false
kernel_rfl bodyTop1026 : noRetBlock PRE_first_tail_x15_r0_body.s1026 = true
kernel_rfl bodyCnt1024 : countersOkB PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.s1026 = true
kernel_rfl bodyO1026 : PRE_first_tail_x15_r0_body.S1026.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1026.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1027 : bridgeOf PRE_first_tail_x15_r0_body.s1027.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1026 : countersOkB PRE_first_tail_x15_r0_body.s1026 PRE_first_tail_x15_r0_body.s1027 = true
kernel_rfl bodyO1027 : PRE_first_tail_x15_r0_body.S1027.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1027.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1027 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1027 PRE_first_tail_x15_r0_body.S1027) = fun _ _ => true
kernel_rfl bodyAcc1029 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1029 PRE_first_tail_x15_r0_body.S1029) = fun _ _ => true
kernel_rfl bodyBr1030 : bridgeOf PRE_first_tail_x15_r0_body.s1030.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1029 : isHalt PRE_first_tail_x15_r0_body.s1029.ctl = false
kernel_rfl bodyTop1030 : noRetBlock PRE_first_tail_x15_r0_body.s1030 = true
kernel_rfl bodyCnt1027 : countersOkB PRE_first_tail_x15_r0_body.s1027 PRE_first_tail_x15_r0_body.s1030 = true

theorem bodyGlue106 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38806, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.S1024)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38806, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1030 PRE_first_tail_x15_r0_body.S1030) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38806, 714, 0, 567⟩) bodyAcc1024 PRE_first_tail_x15_r0_body.bodyRunSeg276 bodyAcc1025 bodyHalt1025 PRE_first_tail_x15_r0_body.bodyStepA277 bodyTop1026 (fun _ hm => bodyO1024 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1024).trans bodyInactive0) (bodyBr1026.trans bodyBr1024.symm) bodyCnt1024 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38806, 714, 0, 567⟩) PRE_first_tail_x15_r0_body.sizeA277 PRE_first_tail_x15_r0_body.sizeArgsA277 PRE_first_tail_x15_r0_body.sizeSymA277 PRE_first_tail_x15_r0_body.sizeMlxA277 PRE_first_tail_x15_r0_body.sizePayA277 PRE_first_tail_x15_r0_body.sizeTaA277 PRE_first_tail_x15_r0_body.sizeDecA277 PRE_first_tail_x15_r0_body.sizePreA277 PRE_first_tail_x15_r0_body.bodyPatchB277 (fun _ hm => bodyO1026 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1026).trans bodyInactive0) (bodyBr1027.trans bodyBr1026.symm) bodyCnt1026 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38806, 714, 0, 567⟩) bodyAcc1027 PRE_first_tail_x15_r0_body.bodyRunSeg277 bodyAcc1029 bodyHalt1029 PRE_first_tail_x15_r0_body.bodyStepA278 bodyTop1030 (fun _ hm => bodyO1027 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1027).trans bodyInactive0) (bodyBr1030.trans bodyBr1027.symm) bodyCnt1027 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
