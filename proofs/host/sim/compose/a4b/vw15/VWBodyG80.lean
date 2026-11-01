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

kernel_rfl bodyO774 : PRE_first_tail_x15_r0_body.S774.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S774.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr774 : bridgeOf PRE_first_tail_x15_r0_body.s774.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc774 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s774 PRE_first_tail_x15_r0_body.S774) = fun _ _ => true
kernel_rfl bodyAcc775 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s775 PRE_first_tail_x15_r0_body.S775) = fun _ _ => true
kernel_rfl bodyBr776 : bridgeOf PRE_first_tail_x15_r0_body.s776.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt775 : isHalt PRE_first_tail_x15_r0_body.s775.ctl = false
kernel_rfl bodyTop776 : noRetBlock PRE_first_tail_x15_r0_body.s776 = true
kernel_rfl bodyCnt774 : countersOkB PRE_first_tail_x15_r0_body.s774 PRE_first_tail_x15_r0_body.s776 = true

theorem bodyGlue80 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30720, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s774 PRE_first_tail_x15_r0_body.S774)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30720, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s776 PRE_first_tail_x15_r0_body.S776) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30720, 558, 0, 432⟩) bodyAcc774 PRE_first_tail_x15_r0_body.bodyRunSeg209 bodyAcc775 bodyHalt775 PRE_first_tail_x15_r0_body.bodyStepA210 bodyTop776 (fun _ hm => bodyO774 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr774).trans bodyInactive0) (bodyBr776.trans bodyBr774.symm) bodyCnt774 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
