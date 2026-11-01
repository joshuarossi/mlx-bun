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

kernel_rfl bodyO1119 : PRE_first_tail_x15_r0_body.S1119.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1119.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1119 : bridgeOf PRE_first_tail_x15_r0_body.s1119.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1119 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1119 PRE_first_tail_x15_r0_body.S1119) = fun _ _ => true
kernel_rfl bodyAcc1120 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1120 PRE_first_tail_x15_r0_body.S1120) = fun _ _ => true
kernel_rfl bodyBr1121 : bridgeOf PRE_first_tail_x15_r0_body.s1121.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1120 : isHalt PRE_first_tail_x15_r0_body.s1120.ctl = false
kernel_rfl bodyTop1121 : noRetBlock PRE_first_tail_x15_r0_body.s1121 = true
kernel_rfl bodyCnt1119 : countersOkB PRE_first_tail_x15_r0_body.s1119 PRE_first_tail_x15_r0_body.s1121 = true

theorem bodyGlue116 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42291, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1119 PRE_first_tail_x15_r0_body.S1119)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42291, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1121 PRE_first_tail_x15_r0_body.S1121) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42291, 789, 0, 621⟩) bodyAcc1119 PRE_first_tail_x15_r0_body.bodyRunSeg302 bodyAcc1120 bodyHalt1120 PRE_first_tail_x15_r0_body.bodyStepA303 bodyTop1121 (fun _ hm => bodyO1119 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1119).trans bodyInactive0) (bodyBr1121.trans bodyBr1119.symm) bodyCnt1119 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
