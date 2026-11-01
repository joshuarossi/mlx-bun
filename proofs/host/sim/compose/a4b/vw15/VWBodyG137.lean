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

kernel_rfl bodyO1320 : PRE_first_tail_x15_r0_body.S1320.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1320.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1320 : bridgeOf PRE_first_tail_x15_r0_body.s1320.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1320 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.S1320) = fun _ _ => true
kernel_rfl bodyAcc1321 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1321 PRE_first_tail_x15_r0_body.S1321) = fun _ _ => true
kernel_rfl bodyBr1322 : bridgeOf PRE_first_tail_x15_r0_body.s1322.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1321 : isHalt PRE_first_tail_x15_r0_body.s1321.ctl = false
kernel_rfl bodyTop1322 : noRetBlock PRE_first_tail_x15_r0_body.s1322 = true
kernel_rfl bodyCnt1320 : countersOkB PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.s1322 = true

theorem bodyGlue137 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨48820, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.S1320)
      (bodyCut NB T tk π i x0 bodyΘ ⟨48820, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1322 PRE_first_tail_x15_r0_body.S1322) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48820, 918, 0, 729⟩) bodyAcc1320 PRE_first_tail_x15_r0_body.bodyRunSeg356 bodyAcc1321 bodyHalt1321 PRE_first_tail_x15_r0_body.bodyStepA357 bodyTop1322 (fun _ hm => bodyO1320 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1320).trans bodyInactive0) (bodyBr1322.trans bodyBr1320.symm) bodyCnt1320 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
