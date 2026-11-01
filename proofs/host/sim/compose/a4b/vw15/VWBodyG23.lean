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

kernel_rfl bodyO227 : PRE_first_tail_x15_r0_body.S227.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S227.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr227 : bridgeOf PRE_first_tail_x15_r0_body.s227.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc227 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s227 PRE_first_tail_x15_r0_body.S227) = fun _ _ => true
kernel_rfl bodyAcc228 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s228 PRE_first_tail_x15_r0_body.S228) = fun _ _ => true
kernel_rfl bodyBr229 : bridgeOf PRE_first_tail_x15_r0_body.s229.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt228 : isHalt PRE_first_tail_x15_r0_body.s228.ctl = false
kernel_rfl bodyTop229 : noRetBlock PRE_first_tail_x15_r0_body.s229 = true
kernel_rfl bodyCnt227 : countersOkB PRE_first_tail_x15_r0_body.s227 PRE_first_tail_x15_r0_body.s229 = true

theorem bodyGlue23 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11803, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s227 PRE_first_tail_x15_r0_body.S227)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11803, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s229 PRE_first_tail_x15_r0_body.S229) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨11803, 175, 0, 126⟩) bodyAcc227 PRE_first_tail_x15_r0_body.bodyRunSeg61 bodyAcc228 bodyHalt228 PRE_first_tail_x15_r0_body.bodyStepA62 bodyTop229 (fun _ hm => bodyO227 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr227).trans bodyInactive0) (bodyBr229.trans bodyBr227.symm) bodyCnt227 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
