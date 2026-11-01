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

kernel_rfl bodyO1521 : PRE_first_tail_x15_r0_body.S1521.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1521.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1521 : bridgeOf PRE_first_tail_x15_r0_body.s1521.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1521 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1521 PRE_first_tail_x15_r0_body.S1521) = fun _ _ => true
kernel_rfl bodyAcc1522 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1522 PRE_first_tail_x15_r0_body.S1522) = fun _ _ => true
kernel_rfl bodyBr1523 : bridgeOf PRE_first_tail_x15_r0_body.s1523.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1522 : isHalt PRE_first_tail_x15_r0_body.s1522.ctl = false
kernel_rfl bodyTop1523 : noRetBlock PRE_first_tail_x15_r0_body.s1523 = true
kernel_rfl bodyCnt1521 : countersOkB PRE_first_tail_x15_r0_body.s1521 PRE_first_tail_x15_r0_body.s1523 = true

theorem bodyGlue158 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨55394, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1521 PRE_first_tail_x15_r0_body.S1521)
      (bodyCut NB T tk π i x0 bodyΘ ⟨55394, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1523 PRE_first_tail_x15_r0_body.S1523) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55394, 1047, 0, 837⟩) bodyAcc1521 PRE_first_tail_x15_r0_body.bodyRunSeg410 bodyAcc1522 bodyHalt1522 PRE_first_tail_x15_r0_body.bodyStepA411 bodyTop1523 (fun _ hm => bodyO1521 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1521).trans bodyInactive0) (bodyBr1523.trans bodyBr1521.symm) bodyCnt1521 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
