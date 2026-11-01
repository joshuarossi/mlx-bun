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

kernel_rfl bodyO1751 : PRE_first_tail_x15_r0_body.S1751.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1751.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1751 : bridgeOf PRE_first_tail_x15_r0_body.s1751.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1751 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.S1751) = fun _ _ => true
kernel_rfl bodyAcc1752 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1752 PRE_first_tail_x15_r0_body.S1752) = fun _ _ => true
kernel_rfl bodyBr1753 : bridgeOf PRE_first_tail_x15_r0_body.s1753.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1752 : isHalt PRE_first_tail_x15_r0_body.s1752.ctl = false
kernel_rfl bodyTop1753 : noRetBlock PRE_first_tail_x15_r0_body.s1753 = true
kernel_rfl bodyCnt1751 : countersOkB PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.s1753 = true

theorem bodyGlue182 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨63138, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.S1751)
      (bodyCut NB T tk π i x0 bodyΘ ⟨63138, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1753 PRE_first_tail_x15_r0_body.S1753) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63138, 1201, 0, 963⟩) bodyAcc1751 PRE_first_tail_x15_r0_body.bodyRunSeg472 bodyAcc1752 bodyHalt1752 PRE_first_tail_x15_r0_body.bodyStepA473 bodyTop1753 (fun _ hm => bodyO1751 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1751).trans bodyInactive0) (bodyBr1753.trans bodyBr1751.symm) bodyCnt1751 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
