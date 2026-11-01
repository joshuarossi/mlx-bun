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

kernel_rfl bodyO1607 : PRE_first_tail_x15_r0_body.S1607.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1607.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1607 : bridgeOf PRE_first_tail_x15_r0_body.s1607.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1607 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.S1607) = fun _ _ => true
kernel_rfl bodyAcc1608 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1608 PRE_first_tail_x15_r0_body.S1608) = fun _ _ => true
kernel_rfl bodyBr1609 : bridgeOf PRE_first_tail_x15_r0_body.s1609.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1608 : isHalt PRE_first_tail_x15_r0_body.s1608.ctl = false
kernel_rfl bodyTop1609 : noRetBlock PRE_first_tail_x15_r0_body.s1609 = true
kernel_rfl bodyCnt1607 : countersOkB PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.s1609 = true

theorem bodyGlue167 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨58087, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.S1607)
      (bodyCut NB T tk π i x0 bodyΘ ⟨58087, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1609 PRE_first_tail_x15_r0_body.S1609) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58087, 1099, 0, 882⟩) bodyAcc1607 PRE_first_tail_x15_r0_body.bodyRunSeg433 bodyAcc1608 bodyHalt1608 PRE_first_tail_x15_r0_body.bodyStepA434 bodyTop1609 (fun _ hm => bodyO1607 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1607).trans bodyInactive0) (bodyBr1609.trans bodyBr1607.symm) bodyCnt1607 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
