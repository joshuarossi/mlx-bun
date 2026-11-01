import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw15.VWBodyChain
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1837 : PRE_first_tail_x15_r0_body.S1837.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1837.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1837 : bridgeOf PRE_first_tail_x15_r0_body.s1837.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1837 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.S1837) = fun _ _ => true
kernel_rfl bodyAcc1838 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1838 PRE_first_tail_x15_r0_body.S1838) = fun _ _ => true
kernel_rfl bodyBr1839 : bridgeOf PRE_first_tail_x15_r0_body.s1839.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1838 : isHalt PRE_first_tail_x15_r0_body.s1838.ctl = false
kernel_rfl bodyTop1839 : noRetBlock PRE_first_tail_x15_r0_body.s1839 = true
kernel_rfl bodyCnt1837 : countersOkB PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.s1839 = true

theorem bodyGlue191 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65840, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.S1837)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65840, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1839 PRE_first_tail_x15_r0_body.S1839) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65840, 1253, 0, 1008⟩) bodyAcc1837 PRE_first_tail_x15_r0_body.bodyRunSeg495 bodyAcc1838 bodyHalt1838 PRE_first_tail_x15_r0_body.bodyStepA496 bodyTop1839 (fun _ hm => bodyO1837 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1837).trans bodyInactive0) (bodyBr1839.trans bodyBr1837.symm) bodyCnt1837 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
