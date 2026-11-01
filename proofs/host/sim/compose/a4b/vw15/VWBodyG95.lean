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

kernel_rfl bodyO917 : PRE_first_tail_x15_r0_body.S917.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S917.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr917 : bridgeOf PRE_first_tail_x15_r0_body.s917.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc917 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.S917) = fun _ _ => true
kernel_rfl bodyAcc918 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s918 PRE_first_tail_x15_r0_body.S918) = fun _ _ => true
kernel_rfl bodyBr919 : bridgeOf PRE_first_tail_x15_r0_body.s919.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt918 : isHalt PRE_first_tail_x15_r0_body.s918.ctl = false
kernel_rfl bodyTop919 : noRetBlock PRE_first_tail_x15_r0_body.s919 = true
kernel_rfl bodyCnt917 : countersOkB PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.s919 = true

theorem bodyGlue95 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34936, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.S917)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34936, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s919 PRE_first_tail_x15_r0_body.S919) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34936, 637, 0, 504⟩) bodyAcc917 PRE_first_tail_x15_r0_body.bodyRunSeg247 bodyAcc918 bodyHalt918 PRE_first_tail_x15_r0_body.bodyStepA248 bodyTop919 (fun _ hm => bodyO917 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr917).trans bodyInactive0) (bodyBr919.trans bodyBr917.symm) bodyCnt917 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
