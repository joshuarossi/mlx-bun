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

kernel_rfl bodyO429 : PRE_first_tail_x15_r0_body.S429.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S429.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr429 : bridgeOf PRE_first_tail_x15_r0_body.s429.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc429 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.S429) = fun _ _ => true
kernel_rfl bodyAcc430 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s430 PRE_first_tail_x15_r0_body.S430) = fun _ _ => true
kernel_rfl bodyBr431 : bridgeOf PRE_first_tail_x15_r0_body.s431.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt430 : isHalt PRE_first_tail_x15_r0_body.s430.ctl = false
kernel_rfl bodyTop431 : noRetBlock PRE_first_tail_x15_r0_body.s431 = true
kernel_rfl bodyCnt429 : countersOkB PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.s431 = true

theorem bodyGlue44 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19149, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.S429)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19149, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.S431) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19149, 327, 0, 243⟩) bodyAcc429 PRE_first_tail_x15_r0_body.bodyRunSeg116 bodyAcc430 bodyHalt430 PRE_first_tail_x15_r0_body.bodyStepA117 bodyTop431 (fun _ hm => bodyO429 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr429).trans bodyInactive0) (bodyBr431.trans bodyBr429.symm) bodyCnt429 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
