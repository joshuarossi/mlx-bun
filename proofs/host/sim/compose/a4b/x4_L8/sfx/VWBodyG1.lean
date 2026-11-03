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

kernel_rfl bodyO4 : PRE_first_tail_x4_L8_r0_suffix.S4.oracle = List.drop (PRE_first_tail_x4_L8_r0_suffix.O.length - PRE_first_tail_x4_L8_r0_suffix.S4.oracle.length) PRE_first_tail_x4_L8_r0_suffix.O
kernel_rfl bodyBr4 : bridgeOf PRE_first_tail_x4_L8_r0_suffix.s4.ffi = bridgeOf PRE_first_tail_x4_L8_r0_suffix.s0.ffi
kernel_rfl bodyAcc4 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_suffix.s4 PRE_first_tail_x4_L8_r0_suffix.S4) = fun _ _ => true
kernel_rfl bodyAcc5 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_suffix.s5 PRE_first_tail_x4_L8_r0_suffix.S5) = fun _ _ => true
kernel_rfl bodyBr6 : bridgeOf PRE_first_tail_x4_L8_r0_suffix.s6.ffi = bridgeOf PRE_first_tail_x4_L8_r0_suffix.s0.ffi
kernel_rfl bodyHalt5 : isHalt PRE_first_tail_x4_L8_r0_suffix.s5.ctl = false
kernel_rfl bodyTop6 : noRetBlock PRE_first_tail_x4_L8_r0_suffix.s6 = true
kernel_rfl bodyCnt4 : countersOkB PRE_first_tail_x4_L8_r0_suffix.s4 PRE_first_tail_x4_L8_r0_suffix.s6 = true
kernel_rfl bodyO6 : PRE_first_tail_x4_L8_r0_suffix.S6.oracle = List.drop (PRE_first_tail_x4_L8_r0_suffix.O.length - PRE_first_tail_x4_L8_r0_suffix.S6.oracle.length) PRE_first_tail_x4_L8_r0_suffix.O
kernel_rfl bodyBr7 : bridgeOf PRE_first_tail_x4_L8_r0_suffix.s7.ffi = bridgeOf PRE_first_tail_x4_L8_r0_suffix.s0.ffi
kernel_rfl bodyLenSt6 : PRE_first_tail_x4_L8_r0_suffix.s6.stack = .e (.member kLength false) :: PRE_first_tail_x4_L8_r0_suffix.s6.stack.tail
kernel_rfl bodyLenArr6 : arrOf PRE_first_tail_x4_L8_r0_suffix.s6 2665 = []
kernel_rfl bodyCnt6 : countersOkB PRE_first_tail_x4_L8_r0_suffix.s6 PRE_first_tail_x4_L8_r0_suffix.s7 = true
kernel_rfl bodyO7 : PRE_first_tail_x4_L8_r0_suffix.S7.oracle = List.drop (PRE_first_tail_x4_L8_r0_suffix.O.length - PRE_first_tail_x4_L8_r0_suffix.S7.oracle.length) PRE_first_tail_x4_L8_r0_suffix.O
kernel_rfl bodyAcc7 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L8_r0_suffix.s7 PRE_first_tail_x4_L8_r0_suffix.S7) = fun _ _ => true
kernel_rfl bodyBr8 : bridgeOf PRE_first_tail_x4_L8_r0_suffix.s8.ffi = bridgeOf PRE_first_tail_x4_L8_r0_suffix.s0.ffi
kernel_rfl bodyTop8 : noRetBlock PRE_first_tail_x4_L8_r0_suffix.s8 = true
kernel_rfl bodyCnt7 : countersOkB PRE_first_tail_x4_L8_r0_suffix.s7 PRE_first_tail_x4_L8_r0_suffix.s8 = true

theorem bodyGlue1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨67849, 1254, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_suffix.s4 PRE_first_tail_x4_L8_r0_suffix.S4))
      (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨67849, 1254, 0, 0⟩ bodyM PRE_first_tail_x4_L8_r0_suffix.s8 PRE_first_tail_x4_L8_r0_suffix.S8)) 139 :=
  (((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := Tr) (O := ⟨67849, 1254, 0, 0⟩) bodyAcc4 PRE_first_tail_x4_L8_r0_suffix.bodyRunSeg1 bodyAcc5 bodyHalt5 PRE_first_tail_x4_L8_r0_suffix.bodyStepA2 bodyTop6 (fun _ hm => bodyO4 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr4).trans bodyInactive0) (bodyBr6.trans bodyBr4.symm) bodyCnt4 hT).trans (bodyLen (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := Tr) (O := ⟨67849, 1254, 0, 0⟩) (by simp [bodyM]) PRE_first_tail_x4_L8_r0_suffix.ctlA2 bodyLenSt6 PRE_first_tail_x4_L8_r0_suffix.objA2 (by rw [PRE_first_tail_x4_L8_r0_suffix.kindA2, bodyLenArr6]; rfl) (Option.some.inj PRE_first_tail_x4_L8_r0_suffix.bodyPatchB2) (fun _ hm => bodyO6 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr6).trans bodyInactive0) (bodyBr7.trans bodyBr6.symm) bodyCnt6 hT)).trans (bodyLitGlue (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := Tr) (O := ⟨67849, 1254, 0, 0⟩) bodyAcc7 PRE_first_tail_x4_L8_r0_suffix.bodyRunSeg2 bodyTop8 (fun _ hm => bodyO7 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr7).trans bodyInactive0) (bodyBr8.trans bodyBr7.symm) bodyCnt7 hT)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8.Sfx
