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

kernel_rfl bodyO938 : PRE_first_tail_x15_r0_body.S938.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S938.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr938 : bridgeOf PRE_first_tail_x15_r0_body.s938.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc938 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s938 PRE_first_tail_x15_r0_body.S938) = fun _ _ => true
kernel_rfl bodyAcc939 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s939 PRE_first_tail_x15_r0_body.S939) = fun _ _ => true
kernel_rfl bodyBr940 : bridgeOf PRE_first_tail_x15_r0_body.s940.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt939 : isHalt PRE_first_tail_x15_r0_body.s939.ctl = false
kernel_rfl bodyTop940 : noRetBlock PRE_first_tail_x15_r0_body.s940 = true
kernel_rfl bodyCnt938 : countersOkB PRE_first_tail_x15_r0_body.s938 PRE_first_tail_x15_r0_body.s940 = true
kernel_rfl bodyO940 : PRE_first_tail_x15_r0_body.S940.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S940.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr941 : bridgeOf PRE_first_tail_x15_r0_body.s941.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt940 : countersOkB PRE_first_tail_x15_r0_body.s940 PRE_first_tail_x15_r0_body.s941 = true
kernel_rfl bodyO941 : PRE_first_tail_x15_r0_body.S941.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S941.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc941 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s941 PRE_first_tail_x15_r0_body.S941) = fun _ _ => true
kernel_rfl bodyAcc943 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s943 PRE_first_tail_x15_r0_body.S943) = fun _ _ => true
kernel_rfl bodyBr944 : bridgeOf PRE_first_tail_x15_r0_body.s944.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt943 : isHalt PRE_first_tail_x15_r0_body.s943.ctl = false
kernel_rfl bodyTop944 : noRetBlock PRE_first_tail_x15_r0_body.s944 = true
kernel_rfl bodyCnt941 : countersOkB PRE_first_tail_x15_r0_body.s941 PRE_first_tail_x15_r0_body.s944 = true

theorem bodyGlue97 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨36104, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s938 PRE_first_tail_x15_r0_body.S938)
      (bodyCut NB T tk π i x0 bodyΘ ⟨36104, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s944 PRE_first_tail_x15_r0_body.S944) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36104, 662, 0, 522⟩) bodyAcc938 PRE_first_tail_x15_r0_body.bodyRunSeg253 bodyAcc939 bodyHalt939 PRE_first_tail_x15_r0_body.bodyStepA254 bodyTop940 (fun _ hm => bodyO938 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr938).trans bodyInactive0) (bodyBr940.trans bodyBr938.symm) bodyCnt938 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36104, 662, 0, 522⟩) PRE_first_tail_x15_r0_body.sizeA254 PRE_first_tail_x15_r0_body.sizeArgsA254 PRE_first_tail_x15_r0_body.sizeSymA254 PRE_first_tail_x15_r0_body.sizeMlxA254 PRE_first_tail_x15_r0_body.sizePayA254 PRE_first_tail_x15_r0_body.sizeTaA254 PRE_first_tail_x15_r0_body.sizeDecA254 PRE_first_tail_x15_r0_body.sizePreA254 PRE_first_tail_x15_r0_body.bodyPatchB254 (fun _ hm => bodyO940 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr940).trans bodyInactive0) (bodyBr941.trans bodyBr940.symm) bodyCnt940 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36104, 662, 0, 522⟩) bodyAcc941 PRE_first_tail_x15_r0_body.bodyRunSeg254 bodyAcc943 bodyHalt943 PRE_first_tail_x15_r0_body.bodyStepA255 bodyTop944 (fun _ hm => bodyO941 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr941).trans bodyInactive0) (bodyBr944.trans bodyBr941.symm) bodyCnt941 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
