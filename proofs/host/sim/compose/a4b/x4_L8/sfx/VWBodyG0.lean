import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L8.sfx.VWBodyChain
import host.sim.compose.a4b.x4_L8.sfx.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L8_r0_suffix.m.B3
import host.sim.template.a4pre_first_tail_x4_L8_r0_suffix.m.B1
import host.sim.template.a4pre_first_tail_x4_L8_r0_suffix.m.B0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO0 : PRE_first_tail_x4_L8_r0_suffix.S0.oracle = List.drop (PRE_first_tail_x4_L8_r0_suffix.O.length - PRE_first_tail_x4_L8_r0_suffix.S0.oracle.length) PRE_first_tail_x4_L8_r0_suffix.O
kernel_rfl bodyBr0 : bridgeOf PRE_first_tail_x4_L8_r0_suffix.s0.ffi = bridgeOf PRE_first_tail_x4_L8_r0_suffix.s0.ffi
kernel_rfl bodyAcc0 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_suffix.s0 PRE_first_tail_x4_L8_r0_suffix.S0) = fun _ _ => true
kernel_rfl bodyAcc1 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_suffix.s1 PRE_first_tail_x4_L8_r0_suffix.S1) = fun _ _ => true
kernel_rfl bodyBr2 : bridgeOf PRE_first_tail_x4_L8_r0_suffix.s2.ffi = bridgeOf PRE_first_tail_x4_L8_r0_suffix.s0.ffi
kernel_rfl bodyHalt1 : isHalt PRE_first_tail_x4_L8_r0_suffix.s1.ctl = false
kernel_rfl bodyTop2 : noRetBlock PRE_first_tail_x4_L8_r0_suffix.s2 = true
kernel_rfl bodyCnt0 : countersOkB PRE_first_tail_x4_L8_r0_suffix.s0 PRE_first_tail_x4_L8_r0_suffix.s2 = true

theorem bodyGlue0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_suffix.s0 PRE_first_tail_x4_L8_r0_suffix.S0))
      (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_suffix.s2 PRE_first_tail_x4_L8_r0_suffix.S2)) 132 :=
  (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := Tr) (O := ⟨64866, 1253, 0, 0⟩) bodyAcc0 PRE_first_tail_x4_L8_r0_suffix.bodyRunSeg0 bodyAcc1 bodyHalt1 PRE_first_tail_x4_L8_r0_suffix.bodyStepA1 bodyTop2 (fun _ hm => bodyO0 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr0).trans bodyInactive0) (bodyBr2.trans bodyBr0.symm) bodyCnt0 hT).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx
