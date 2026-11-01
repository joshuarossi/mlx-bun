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

kernel_rfl bodyO1254 : PRE_first_tail_x15_r0_body.S1254.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1254.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1254 : bridgeOf PRE_first_tail_x15_r0_body.s1254.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1254 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.S1254) = fun _ _ => true
kernel_rfl bodyAcc1255 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1255 PRE_first_tail_x15_r0_body.S1255) = fun _ _ => true
kernel_rfl bodyBr1256 : bridgeOf PRE_first_tail_x15_r0_body.s1256.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1255 : isHalt PRE_first_tail_x15_r0_body.s1255.ctl = false
kernel_rfl bodyTop1256 : noRetBlock PRE_first_tail_x15_r0_body.s1256 = true
kernel_rfl bodyCnt1254 : countersOkB PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.s1256 = true
kernel_rfl bodyO1256 : PRE_first_tail_x15_r0_body.S1256.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1256.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1257 : bridgeOf PRE_first_tail_x15_r0_body.s1257.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1256 : countersOkB PRE_first_tail_x15_r0_body.s1256 PRE_first_tail_x15_r0_body.s1257 = true
kernel_rfl bodyO1257 : PRE_first_tail_x15_r0_body.S1257.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1257.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1257 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1257 PRE_first_tail_x15_r0_body.S1257) = fun _ _ => true
kernel_rfl bodyAcc1259 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1259 PRE_first_tail_x15_r0_body.S1259) = fun _ _ => true
kernel_rfl bodyBr1260 : bridgeOf PRE_first_tail_x15_r0_body.s1260.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1259 : isHalt PRE_first_tail_x15_r0_body.s1259.ctl = false
kernel_rfl bodyTop1260 : noRetBlock PRE_first_tail_x15_r0_body.s1260 = true
kernel_rfl bodyCnt1257 : countersOkB PRE_first_tail_x15_r0_body.s1257 PRE_first_tail_x15_r0_body.s1260 = true

theorem bodyGlue130 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46496, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.S1254)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46496, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1260 PRE_first_tail_x15_r0_body.S1260) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46496, 868, 0, 693⟩) bodyAcc1254 PRE_first_tail_x15_r0_body.bodyRunSeg338 bodyAcc1255 bodyHalt1255 PRE_first_tail_x15_r0_body.bodyStepA339 bodyTop1256 (fun _ hm => bodyO1254 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1254).trans bodyInactive0) (bodyBr1256.trans bodyBr1254.symm) bodyCnt1254 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46496, 868, 0, 693⟩) PRE_first_tail_x15_r0_body.sizeA339 PRE_first_tail_x15_r0_body.sizeArgsA339 PRE_first_tail_x15_r0_body.sizeSymA339 PRE_first_tail_x15_r0_body.sizeMlxA339 PRE_first_tail_x15_r0_body.sizePayA339 PRE_first_tail_x15_r0_body.sizeTaA339 PRE_first_tail_x15_r0_body.sizeDecA339 PRE_first_tail_x15_r0_body.sizePreA339 PRE_first_tail_x15_r0_body.bodyPatchB339 (fun _ hm => bodyO1256 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1256).trans bodyInactive0) (bodyBr1257.trans bodyBr1256.symm) bodyCnt1256 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46496, 868, 0, 693⟩) bodyAcc1257 PRE_first_tail_x15_r0_body.bodyRunSeg339 bodyAcc1259 bodyHalt1259 PRE_first_tail_x15_r0_body.bodyStepA340 bodyTop1260 (fun _ hm => bodyO1257 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1257).trans bodyInactive0) (bodyBr1260.trans bodyBr1257.symm) bodyCnt1257 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
