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

kernel_rfl bodyO1090 : PRE_first_tail_x15_r0_body.S1090.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1090.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1090 : bridgeOf PRE_first_tail_x15_r0_body.s1090.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1090 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1090 PRE_first_tail_x15_r0_body.S1090) = fun _ _ => true
kernel_rfl bodyAcc1091 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1091 PRE_first_tail_x15_r0_body.S1091) = fun _ _ => true
kernel_rfl bodyBr1092 : bridgeOf PRE_first_tail_x15_r0_body.s1092.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1091 : isHalt PRE_first_tail_x15_r0_body.s1091.ctl = false
kernel_rfl bodyTop1092 : noRetBlock PRE_first_tail_x15_r0_body.s1092 = true
kernel_rfl bodyCnt1090 : countersOkB PRE_first_tail_x15_r0_body.s1090 PRE_first_tail_x15_r0_body.s1092 = true

theorem bodyGlue113 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨41130, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1090 PRE_first_tail_x15_r0_body.S1090)
      (bodyCut NB T tk π i x0 bodyΘ ⟨41130, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1092 PRE_first_tail_x15_r0_body.S1092) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨41130, 764, 0, 603⟩) bodyAcc1090 PRE_first_tail_x15_r0_body.bodyRunSeg294 bodyAcc1091 bodyHalt1091 PRE_first_tail_x15_r0_body.bodyStepA295 bodyTop1092 (fun _ hm => bodyO1090 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1090).trans bodyInactive0) (bodyBr1092.trans bodyBr1090.symm) bodyCnt1090 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
