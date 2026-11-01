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

kernel_rfl bodyO1197 : PRE_first_tail_x15_r0_body.S1197.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1197.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1197 : bridgeOf PRE_first_tail_x15_r0_body.s1197.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1197 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.S1197) = fun _ _ => true
kernel_rfl bodyAcc1198 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1198 PRE_first_tail_x15_r0_body.S1198) = fun _ _ => true
kernel_rfl bodyBr1199 : bridgeOf PRE_first_tail_x15_r0_body.s1199.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1198 : isHalt PRE_first_tail_x15_r0_body.s1198.ctl = false
kernel_rfl bodyTop1199 : noRetBlock PRE_first_tail_x15_r0_body.s1199 = true
kernel_rfl bodyCnt1197 : countersOkB PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.s1199 = true
kernel_rfl bodyO1199 : PRE_first_tail_x15_r0_body.S1199.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1199.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1200 : bridgeOf PRE_first_tail_x15_r0_body.s1200.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1199 : countersOkB PRE_first_tail_x15_r0_body.s1199 PRE_first_tail_x15_r0_body.s1200 = true
kernel_rfl bodyO1200 : PRE_first_tail_x15_r0_body.S1200.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1200.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1200 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1200 PRE_first_tail_x15_r0_body.S1200) = fun _ _ => true
kernel_rfl bodyAcc1202 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1202 PRE_first_tail_x15_r0_body.S1202) = fun _ _ => true
kernel_rfl bodyBr1203 : bridgeOf PRE_first_tail_x15_r0_body.s1203.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1202 : isHalt PRE_first_tail_x15_r0_body.s1202.ctl = false
kernel_rfl bodyTop1203 : noRetBlock PRE_first_tail_x15_r0_body.s1203 = true
kernel_rfl bodyCnt1200 : countersOkB PRE_first_tail_x15_r0_body.s1200 PRE_first_tail_x15_r0_body.s1203 = true

theorem bodyGlue124 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨44973, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.S1197)
      (bodyCut NB T tk π i x0 bodyΘ ⟨44973, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1203 PRE_first_tail_x15_r0_body.S1203) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44973, 841, 0, 666⟩) bodyAcc1197 PRE_first_tail_x15_r0_body.bodyRunSeg323 bodyAcc1198 bodyHalt1198 PRE_first_tail_x15_r0_body.bodyStepA324 bodyTop1199 (fun _ hm => bodyO1197 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1197).trans bodyInactive0) (bodyBr1199.trans bodyBr1197.symm) bodyCnt1197 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44973, 841, 0, 666⟩) PRE_first_tail_x15_r0_body.sizeA324 PRE_first_tail_x15_r0_body.sizeArgsA324 PRE_first_tail_x15_r0_body.sizeSymA324 PRE_first_tail_x15_r0_body.sizeMlxA324 PRE_first_tail_x15_r0_body.sizePayA324 PRE_first_tail_x15_r0_body.sizeTaA324 PRE_first_tail_x15_r0_body.sizeDecA324 PRE_first_tail_x15_r0_body.sizePreA324 PRE_first_tail_x15_r0_body.bodyPatchB324 (fun _ hm => bodyO1199 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1199).trans bodyInactive0) (bodyBr1200.trans bodyBr1199.symm) bodyCnt1199 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44973, 841, 0, 666⟩) bodyAcc1200 PRE_first_tail_x15_r0_body.bodyRunSeg324 bodyAcc1202 bodyHalt1202 PRE_first_tail_x15_r0_body.bodyStepA325 bodyTop1203 (fun _ hm => bodyO1200 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1200).trans bodyInactive0) (bodyBr1203.trans bodyBr1200.symm) bodyCnt1200 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
