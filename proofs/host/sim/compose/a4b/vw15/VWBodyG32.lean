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

kernel_rfl bodyO314 : PRE_first_tail_x15_r0_body.S314.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S314.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr314 : bridgeOf PRE_first_tail_x15_r0_body.s314.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc314 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s314 PRE_first_tail_x15_r0_body.S314) = fun _ _ => true
kernel_rfl bodyAcc315 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s315 PRE_first_tail_x15_r0_body.S315) = fun _ _ => true
kernel_rfl bodyBr316 : bridgeOf PRE_first_tail_x15_r0_body.s316.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt315 : isHalt PRE_first_tail_x15_r0_body.s315.ctl = false
kernel_rfl bodyTop316 : noRetBlock PRE_first_tail_x15_r0_body.s316 = true
kernel_rfl bodyCnt314 : countersOkB PRE_first_tail_x15_r0_body.s314 PRE_first_tail_x15_r0_body.s316 = true

theorem bodyGlue32 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15286, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s314 PRE_first_tail_x15_r0_body.S314)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15286, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s316 PRE_first_tail_x15_r0_body.S316) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15286, 250, 0, 180⟩) bodyAcc314 PRE_first_tail_x15_r0_body.bodyRunSeg85 bodyAcc315 bodyHalt315 PRE_first_tail_x15_r0_body.bodyStepA86 bodyTop316 (fun _ hm => bodyO314 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr314).trans bodyInactive0) (bodyBr316.trans bodyBr314.symm) bodyCnt314 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
