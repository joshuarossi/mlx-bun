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

kernel_rfl bodyO601 : PRE_first_tail_x15_r0_body.S601.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S601.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr601 : bridgeOf PRE_first_tail_x15_r0_body.s601.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc601 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.S601) = fun _ _ => true
kernel_rfl bodyAcc602 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s602 PRE_first_tail_x15_r0_body.S602) = fun _ _ => true
kernel_rfl bodyBr603 : bridgeOf PRE_first_tail_x15_r0_body.s603.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt602 : isHalt PRE_first_tail_x15_r0_body.s602.ctl = false
kernel_rfl bodyTop603 : noRetBlock PRE_first_tail_x15_r0_body.s603 = true
kernel_rfl bodyCnt601 : countersOkB PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.s603 = true

theorem bodyGlue62 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24553, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.S601)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24553, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s603 PRE_first_tail_x15_r0_body.S603) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24553, 431, 0, 333⟩) bodyAcc601 PRE_first_tail_x15_r0_body.bodyRunSeg162 bodyAcc602 bodyHalt602 PRE_first_tail_x15_r0_body.bodyStepA163 bodyTop603 (fun _ hm => bodyO601 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr601).trans bodyInactive0) (bodyBr603.trans bodyBr601.symm) bodyCnt601 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
