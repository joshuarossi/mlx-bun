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

kernel_rfl bodyO1205 : PRE_first_tail_x15_r0_body.S1205.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1205.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1205 : bridgeOf PRE_first_tail_x15_r0_body.s1205.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1205 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.S1205) = fun _ _ => true
kernel_rfl bodyAcc1206 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1206 PRE_first_tail_x15_r0_body.S1206) = fun _ _ => true
kernel_rfl bodyBr1207 : bridgeOf PRE_first_tail_x15_r0_body.s1207.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1206 : isHalt PRE_first_tail_x15_r0_body.s1206.ctl = false
kernel_rfl bodyTop1207 : noRetBlock PRE_first_tail_x15_r0_body.s1207 = true
kernel_rfl bodyCnt1205 : countersOkB PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.s1207 = true

theorem bodyGlue125 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨44975, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.S1205)
      (bodyCut NB T tk π i x0 bodyΘ ⟨44975, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1207 PRE_first_tail_x15_r0_body.S1207) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨44975, 841, 0, 666⟩) bodyAcc1205 PRE_first_tail_x15_r0_body.bodyRunSeg325 bodyAcc1206 bodyHalt1206 PRE_first_tail_x15_r0_body.bodyStepA326 bodyTop1207 (fun _ hm => bodyO1205 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1205).trans bodyInactive0) (bodyBr1207.trans bodyBr1205.symm) bodyCnt1205 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
