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

kernel_rfl bodyO1809 : PRE_first_tail_x15_r0_body.S1809.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1809.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1809 : bridgeOf PRE_first_tail_x15_r0_body.s1809.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1809 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.S1809) = fun _ _ => true
kernel_rfl bodyAcc1810 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1810 PRE_first_tail_x15_r0_body.S1810) = fun _ _ => true
kernel_rfl bodyBr1811 : bridgeOf PRE_first_tail_x15_r0_body.s1811.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1810 : isHalt PRE_first_tail_x15_r0_body.s1810.ctl = false
kernel_rfl bodyTop1811 : noRetBlock PRE_first_tail_x15_r0_body.s1811 = true
kernel_rfl bodyCnt1809 : countersOkB PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.s1811 = true

theorem bodyGlue188 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65478, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.S1809)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65478, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1811 PRE_first_tail_x15_r0_body.S1811) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65478, 1251, 0, 999⟩) bodyAcc1809 PRE_first_tail_x15_r0_body.bodyRunSeg488 bodyAcc1810 bodyHalt1810 PRE_first_tail_x15_r0_body.bodyStepA489 bodyTop1811 (fun _ hm => bodyO1809 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1809).trans bodyInactive0) (bodyBr1811.trans bodyBr1809.symm) bodyCnt1809 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
