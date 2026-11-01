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

kernel_rfl bodyO1550 : PRE_first_tail_x15_r0_body.S1550.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1550.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1550 : bridgeOf PRE_first_tail_x15_r0_body.s1550.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1550 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1550 PRE_first_tail_x15_r0_body.S1550) = fun _ _ => true
kernel_rfl bodyAcc1551 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1551 PRE_first_tail_x15_r0_body.S1551) = fun _ _ => true
kernel_rfl bodyBr1552 : bridgeOf PRE_first_tail_x15_r0_body.s1552.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1551 : isHalt PRE_first_tail_x15_r0_body.s1551.ctl = false
kernel_rfl bodyTop1552 : noRetBlock PRE_first_tail_x15_r0_body.s1552 = true
kernel_rfl bodyCnt1550 : countersOkB PRE_first_tail_x15_r0_body.s1550 PRE_first_tail_x15_r0_body.s1552 = true

theorem bodyGlue161 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨56555, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1550 PRE_first_tail_x15_r0_body.S1550)
      (bodyCut NB T tk π i x0 bodyΘ ⟨56555, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1552 PRE_first_tail_x15_r0_body.S1552) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56555, 1072, 0, 855⟩) bodyAcc1550 PRE_first_tail_x15_r0_body.bodyRunSeg418 bodyAcc1551 bodyHalt1551 PRE_first_tail_x15_r0_body.bodyStepA419 bodyTop1552 (fun _ hm => bodyO1550 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1550).trans bodyInactive0) (bodyBr1552.trans bodyBr1550.symm) bodyCnt1550 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
