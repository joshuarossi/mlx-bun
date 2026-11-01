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

kernel_rfl bodyO1147 : PRE_first_tail_x15_r0_body.S1147.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1147.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1147 : bridgeOf PRE_first_tail_x15_r0_body.s1147.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1147 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1147 PRE_first_tail_x15_r0_body.S1147) = fun _ _ => true
kernel_rfl bodyAcc1148 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1148 PRE_first_tail_x15_r0_body.S1148) = fun _ _ => true
kernel_rfl bodyBr1149 : bridgeOf PRE_first_tail_x15_r0_body.s1149.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1148 : isHalt PRE_first_tail_x15_r0_body.s1148.ctl = false
kernel_rfl bodyTop1149 : noRetBlock PRE_first_tail_x15_r0_body.s1149 = true
kernel_rfl bodyCnt1147 : countersOkB PRE_first_tail_x15_r0_body.s1147 PRE_first_tail_x15_r0_body.s1149 = true

theorem bodyGlue119 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42653, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1147 PRE_first_tail_x15_r0_body.S1147)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42653, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1149 PRE_first_tail_x15_r0_body.S1149) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨42653, 791, 0, 630⟩) bodyAcc1147 PRE_first_tail_x15_r0_body.bodyRunSeg309 bodyAcc1148 bodyHalt1148 PRE_first_tail_x15_r0_body.bodyStepA310 bodyTop1149 (fun _ hm => bodyO1147 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1147).trans bodyInactive0) (bodyBr1149.trans bodyBr1147.symm) bodyCnt1147 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
