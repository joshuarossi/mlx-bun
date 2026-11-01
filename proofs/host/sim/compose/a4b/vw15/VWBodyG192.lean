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

kernel_rfl bodyO1841 : PRE_first_tail_x15_r0_body.S1841.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1841.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1841 : bridgeOf PRE_first_tail_x15_r0_body.s1841.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1841 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.S1841) = fun _ _ => true
kernel_rfl bodyBr1843 : bridgeOf PRE_first_tail_x15_r0_body.s1843.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyTop1843 : noRetBlock PRE_first_tail_x15_r0_body.s1843 = true
kernel_rfl bodyCnt1841 : countersOkB PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.s1843 = true

theorem bodyGlue192 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65850, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.S1841)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65850, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1843 PRE_first_tail_x15_r0_body.S1843) 3842 :=
  (bodyGlue (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65850, 1253, 0, 1008⟩) bodyAcc1841 PRE_first_tail_x15_r0_body.bodyRunSeg496 bodyTop1843 (fun _ hm => bodyO1841 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1841).trans bodyInactive0) (bodyBr1843.trans bodyBr1841.symm) bodyCnt1841 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
