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

kernel_rfl bodyO1061 : PRE_first_tail_x15_r0_body.S1061.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1061.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1061 : bridgeOf PRE_first_tail_x15_r0_body.s1061.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1061 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.S1061) = fun _ _ => true
kernel_rfl bodyAcc1062 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1062 PRE_first_tail_x15_r0_body.S1062) = fun _ _ => true
kernel_rfl bodyBr1063 : bridgeOf PRE_first_tail_x15_r0_body.s1063.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1062 : isHalt PRE_first_tail_x15_r0_body.s1062.ctl = false
kernel_rfl bodyTop1063 : noRetBlock PRE_first_tail_x15_r0_body.s1063 = true
kernel_rfl bodyCnt1061 : countersOkB PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.s1063 = true

theorem bodyGlue110 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨39969, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.S1061)
      (bodyCut NB T tk π i x0 bodyΘ ⟨39969, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1063 PRE_first_tail_x15_r0_body.S1063) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨39969, 739, 0, 585⟩) bodyAcc1061 PRE_first_tail_x15_r0_body.bodyRunSeg286 bodyAcc1062 bodyHalt1062 PRE_first_tail_x15_r0_body.bodyStepA287 bodyTop1063 (fun _ hm => bodyO1061 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1061).trans bodyInactive0) (bodyBr1063.trans bodyBr1061.symm) bodyCnt1061 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
