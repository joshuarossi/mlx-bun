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

kernel_rfl bodyO909 : PRE_first_tail_x15_r0_body.S909.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S909.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr909 : bridgeOf PRE_first_tail_x15_r0_body.s909.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc909 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.S909) = fun _ _ => true
kernel_rfl bodyAcc910 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s910 PRE_first_tail_x15_r0_body.S910) = fun _ _ => true
kernel_rfl bodyBr911 : bridgeOf PRE_first_tail_x15_r0_body.s911.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt910 : isHalt PRE_first_tail_x15_r0_body.s910.ctl = false
kernel_rfl bodyTop911 : noRetBlock PRE_first_tail_x15_r0_body.s911 = true
kernel_rfl bodyCnt909 : countersOkB PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.s911 = true
kernel_rfl bodyO911 : PRE_first_tail_x15_r0_body.S911.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S911.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr912 : bridgeOf PRE_first_tail_x15_r0_body.s912.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt911 : countersOkB PRE_first_tail_x15_r0_body.s911 PRE_first_tail_x15_r0_body.s912 = true
kernel_rfl bodyO912 : PRE_first_tail_x15_r0_body.S912.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S912.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc912 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s912 PRE_first_tail_x15_r0_body.S912) = fun _ _ => true
kernel_rfl bodyAcc914 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s914 PRE_first_tail_x15_r0_body.S914) = fun _ _ => true
kernel_rfl bodyBr915 : bridgeOf PRE_first_tail_x15_r0_body.s915.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt914 : isHalt PRE_first_tail_x15_r0_body.s914.ctl = false
kernel_rfl bodyTop915 : noRetBlock PRE_first_tail_x15_r0_body.s915 = true
kernel_rfl bodyCnt912 : countersOkB PRE_first_tail_x15_r0_body.s912 PRE_first_tail_x15_r0_body.s915 = true

theorem bodyGlue94 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34934, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.S909)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34934, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s915 PRE_first_tail_x15_r0_body.S915) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34934, 637, 0, 504⟩) bodyAcc909 PRE_first_tail_x15_r0_body.bodyRunSeg245 bodyAcc910 bodyHalt910 PRE_first_tail_x15_r0_body.bodyStepA246 bodyTop911 (fun _ hm => bodyO909 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr909).trans bodyInactive0) (bodyBr911.trans bodyBr909.symm) bodyCnt909 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34934, 637, 0, 504⟩) PRE_first_tail_x15_r0_body.sizeA246 PRE_first_tail_x15_r0_body.sizeArgsA246 PRE_first_tail_x15_r0_body.sizeSymA246 PRE_first_tail_x15_r0_body.sizeMlxA246 PRE_first_tail_x15_r0_body.sizePayA246 PRE_first_tail_x15_r0_body.sizeTaA246 PRE_first_tail_x15_r0_body.sizeDecA246 PRE_first_tail_x15_r0_body.sizePreA246 PRE_first_tail_x15_r0_body.bodyPatchB246 (fun _ hm => bodyO911 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr911).trans bodyInactive0) (bodyBr912.trans bodyBr911.symm) bodyCnt911 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34934, 637, 0, 504⟩) bodyAcc912 PRE_first_tail_x15_r0_body.bodyRunSeg246 bodyAcc914 bodyHalt914 PRE_first_tail_x15_r0_body.bodyStepA247 bodyTop915 (fun _ hm => bodyO912 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr912).trans bodyInactive0) (bodyBr915.trans bodyBr912.symm) bodyCnt912 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
