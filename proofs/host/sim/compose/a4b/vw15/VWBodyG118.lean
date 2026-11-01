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

kernel_rfl bodyO1139 : PRE_first_tail_x15_r0_body.S1139.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1139.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1139 : bridgeOf PRE_first_tail_x15_r0_body.s1139.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1139 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.S1139) = fun _ _ => true
kernel_rfl bodyAcc1140 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1140 PRE_first_tail_x15_r0_body.S1140) = fun _ _ => true
kernel_rfl bodyBr1141 : bridgeOf PRE_first_tail_x15_r0_body.s1141.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1140 : isHalt PRE_first_tail_x15_r0_body.s1140.ctl = false
kernel_rfl bodyTop1141 : noRetBlock PRE_first_tail_x15_r0_body.s1141 = true
kernel_rfl bodyCnt1139 : countersOkB PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.s1141 = true
kernel_rfl bodyO1141 : PRE_first_tail_x15_r0_body.S1141.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1141.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1142 : bridgeOf PRE_first_tail_x15_r0_body.s1142.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1141 : countersOkB PRE_first_tail_x15_r0_body.s1141 PRE_first_tail_x15_r0_body.s1142 = true
kernel_rfl bodyO1142 : PRE_first_tail_x15_r0_body.S1142.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1142.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1142 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1142 PRE_first_tail_x15_r0_body.S1142) = fun _ _ => true
kernel_rfl bodyAcc1144 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1144 PRE_first_tail_x15_r0_body.S1144) = fun _ _ => true
kernel_rfl bodyBr1145 : bridgeOf PRE_first_tail_x15_r0_body.s1145.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1144 : isHalt PRE_first_tail_x15_r0_body.s1144.ctl = false
kernel_rfl bodyTop1145 : noRetBlock PRE_first_tail_x15_r0_body.s1145 = true
kernel_rfl bodyCnt1142 : countersOkB PRE_first_tail_x15_r0_body.s1142 PRE_first_tail_x15_r0_body.s1145 = true

theorem bodyGlue118 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42651, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.S1139)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42651, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1145 PRE_first_tail_x15_r0_body.S1145) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42651, 791, 0, 630⟩) bodyAcc1139 PRE_first_tail_x15_r0_body.bodyRunSeg307 bodyAcc1140 bodyHalt1140 PRE_first_tail_x15_r0_body.bodyStepA308 bodyTop1141 (fun _ hm => bodyO1139 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1139).trans bodyInactive0) (bodyBr1141.trans bodyBr1139.symm) bodyCnt1139 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42651, 791, 0, 630⟩) PRE_first_tail_x15_r0_body.sizeA308 PRE_first_tail_x15_r0_body.sizeArgsA308 PRE_first_tail_x15_r0_body.sizeSymA308 PRE_first_tail_x15_r0_body.sizeMlxA308 PRE_first_tail_x15_r0_body.sizePayA308 PRE_first_tail_x15_r0_body.sizeTaA308 PRE_first_tail_x15_r0_body.sizeDecA308 PRE_first_tail_x15_r0_body.sizePreA308 PRE_first_tail_x15_r0_body.bodyPatchB308 (fun _ hm => bodyO1141 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1141).trans bodyInactive0) (bodyBr1142.trans bodyBr1141.symm) bodyCnt1141 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42651, 791, 0, 630⟩) bodyAcc1142 PRE_first_tail_x15_r0_body.bodyRunSeg308 bodyAcc1144 bodyHalt1144 PRE_first_tail_x15_r0_body.bodyStepA309 bodyTop1145 (fun _ hm => bodyO1142 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1142).trans bodyInactive0) (bodyBr1145.trans bodyBr1142.symm) bodyCnt1142 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
