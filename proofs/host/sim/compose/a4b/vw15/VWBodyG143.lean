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

kernel_rfl bodyO1377 : PRE_first_tail_x15_r0_body.S1377.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1377.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1377 : bridgeOf PRE_first_tail_x15_r0_body.s1377.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1377 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.S1377) = fun _ _ => true
kernel_rfl bodyAcc1378 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1378 PRE_first_tail_x15_r0_body.S1378) = fun _ _ => true
kernel_rfl bodyBr1379 : bridgeOf PRE_first_tail_x15_r0_body.s1379.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1378 : isHalt PRE_first_tail_x15_r0_body.s1378.ctl = false
kernel_rfl bodyTop1379 : noRetBlock PRE_first_tail_x15_r0_body.s1379 = true
kernel_rfl bodyCnt1377 : countersOkB PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.s1379 = true

theorem bodyGlue143 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50361, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.S1377)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50361, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1379 PRE_first_tail_x15_r0_body.S1379) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50361, 945, 0, 756⟩) bodyAcc1377 PRE_first_tail_x15_r0_body.bodyRunSeg371 bodyAcc1378 bodyHalt1378 PRE_first_tail_x15_r0_body.bodyStepA372 bodyTop1379 (fun _ hm => bodyO1377 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1377).trans bodyInactive0) (bodyBr1379.trans bodyBr1377.symm) bodyCnt1377 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
