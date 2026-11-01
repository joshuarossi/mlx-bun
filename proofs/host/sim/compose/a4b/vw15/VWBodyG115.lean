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

kernel_rfl bodyO1111 : PRE_first_tail_x15_r0_body.S1111.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1111.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1111 : bridgeOf PRE_first_tail_x15_r0_body.s1111.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1111 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1111 PRE_first_tail_x15_r0_body.S1111) = fun _ _ => true
kernel_rfl bodyAcc1112 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1112 PRE_first_tail_x15_r0_body.S1112) = fun _ _ => true
kernel_rfl bodyBr1113 : bridgeOf PRE_first_tail_x15_r0_body.s1113.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1112 : isHalt PRE_first_tail_x15_r0_body.s1112.ctl = false
kernel_rfl bodyTop1113 : noRetBlock PRE_first_tail_x15_r0_body.s1113 = true
kernel_rfl bodyCnt1111 : countersOkB PRE_first_tail_x15_r0_body.s1111 PRE_first_tail_x15_r0_body.s1113 = true
kernel_rfl bodyO1113 : PRE_first_tail_x15_r0_body.S1113.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1113.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1114 : bridgeOf PRE_first_tail_x15_r0_body.s1114.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1113 : countersOkB PRE_first_tail_x15_r0_body.s1113 PRE_first_tail_x15_r0_body.s1114 = true
kernel_rfl bodyO1114 : PRE_first_tail_x15_r0_body.S1114.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1114.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1114 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1114 PRE_first_tail_x15_r0_body.S1114) = fun _ _ => true
kernel_rfl bodyAcc1116 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1116 PRE_first_tail_x15_r0_body.S1116) = fun _ _ => true
kernel_rfl bodyBr1117 : bridgeOf PRE_first_tail_x15_r0_body.s1117.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1116 : isHalt PRE_first_tail_x15_r0_body.s1116.ctl = false
kernel_rfl bodyTop1117 : noRetBlock PRE_first_tail_x15_r0_body.s1117 = true
kernel_rfl bodyCnt1114 : countersOkB PRE_first_tail_x15_r0_body.s1114 PRE_first_tail_x15_r0_body.s1117 = true

theorem bodyGlue115 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42289, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1111 PRE_first_tail_x15_r0_body.S1111)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42289, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1117 PRE_first_tail_x15_r0_body.S1117) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42289, 789, 0, 621⟩) bodyAcc1111 PRE_first_tail_x15_r0_body.bodyRunSeg300 bodyAcc1112 bodyHalt1112 PRE_first_tail_x15_r0_body.bodyStepA301 bodyTop1113 (fun _ hm => bodyO1111 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1111).trans bodyInactive0) (bodyBr1113.trans bodyBr1111.symm) bodyCnt1111 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42289, 789, 0, 621⟩) PRE_first_tail_x15_r0_body.sizeA301 PRE_first_tail_x15_r0_body.sizeArgsA301 PRE_first_tail_x15_r0_body.sizeSymA301 PRE_first_tail_x15_r0_body.sizeMlxA301 PRE_first_tail_x15_r0_body.sizePayA301 PRE_first_tail_x15_r0_body.sizeTaA301 PRE_first_tail_x15_r0_body.sizeDecA301 PRE_first_tail_x15_r0_body.sizePreA301 PRE_first_tail_x15_r0_body.bodyPatchB301 (fun _ hm => bodyO1113 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1113).trans bodyInactive0) (bodyBr1114.trans bodyBr1113.symm) bodyCnt1113 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42289, 789, 0, 621⟩) bodyAcc1114 PRE_first_tail_x15_r0_body.bodyRunSeg301 bodyAcc1116 bodyHalt1116 PRE_first_tail_x15_r0_body.bodyStepA302 bodyTop1117 (fun _ hm => bodyO1114 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1114).trans bodyInactive0) (bodyBr1117.trans bodyBr1114.symm) bodyCnt1114 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
