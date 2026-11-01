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

kernel_rfl bodyO1262 : PRE_first_tail_x15_r0_body.S1262.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1262.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1262 : bridgeOf PRE_first_tail_x15_r0_body.s1262.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1262 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.S1262) = fun _ _ => true
kernel_rfl bodyAcc1263 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1263 PRE_first_tail_x15_r0_body.S1263) = fun _ _ => true
kernel_rfl bodyBr1264 : bridgeOf PRE_first_tail_x15_r0_body.s1264.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1263 : isHalt PRE_first_tail_x15_r0_body.s1263.ctl = false
kernel_rfl bodyTop1264 : noRetBlock PRE_first_tail_x15_r0_body.s1264 = true
kernel_rfl bodyCnt1262 : countersOkB PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.s1264 = true

theorem bodyGlue131 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46498, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.S1262)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46498, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1264 PRE_first_tail_x15_r0_body.S1264) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46498, 868, 0, 693⟩) bodyAcc1262 PRE_first_tail_x15_r0_body.bodyRunSeg340 bodyAcc1263 bodyHalt1263 PRE_first_tail_x15_r0_body.bodyStepA341 bodyTop1264 (fun _ hm => bodyO1262 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1262).trans bodyInactive0) (bodyBr1264.trans bodyBr1262.symm) bodyCnt1262 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
