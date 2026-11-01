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

kernel_rfl bodyO1829 : PRE_first_tail_x15_r0_body.S1829.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1829.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1829 : bridgeOf PRE_first_tail_x15_r0_body.s1829.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1829 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.S1829) = fun _ _ => true
kernel_rfl bodyAcc1830 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1830 PRE_first_tail_x15_r0_body.S1830) = fun _ _ => true
kernel_rfl bodyBr1831 : bridgeOf PRE_first_tail_x15_r0_body.s1831.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1830 : isHalt PRE_first_tail_x15_r0_body.s1830.ctl = false
kernel_rfl bodyTop1831 : noRetBlock PRE_first_tail_x15_r0_body.s1831 = true
kernel_rfl bodyCnt1829 : countersOkB PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.s1831 = true
kernel_rfl bodyO1831 : PRE_first_tail_x15_r0_body.S1831.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1831.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1832 : bridgeOf PRE_first_tail_x15_r0_body.s1832.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1831 : countersOkB PRE_first_tail_x15_r0_body.s1831 PRE_first_tail_x15_r0_body.s1832 = true
kernel_rfl bodyO1832 : PRE_first_tail_x15_r0_body.S1832.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1832.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1832 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1832 PRE_first_tail_x15_r0_body.S1832) = fun _ _ => true
kernel_rfl bodyAcc1834 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1834 PRE_first_tail_x15_r0_body.S1834) = fun _ _ => true
kernel_rfl bodyBr1835 : bridgeOf PRE_first_tail_x15_r0_body.s1835.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1834 : isHalt PRE_first_tail_x15_r0_body.s1834.ctl = false
kernel_rfl bodyTop1835 : noRetBlock PRE_first_tail_x15_r0_body.s1835 = true
kernel_rfl bodyCnt1832 : countersOkB PRE_first_tail_x15_r0_body.s1832 PRE_first_tail_x15_r0_body.s1835 = true

theorem bodyGlue190 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65838, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.S1829)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65838, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1835 PRE_first_tail_x15_r0_body.S1835) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65838, 1253, 0, 1008⟩) bodyAcc1829 PRE_first_tail_x15_r0_body.bodyRunSeg493 bodyAcc1830 bodyHalt1830 PRE_first_tail_x15_r0_body.bodyStepA494 bodyTop1831 (fun _ hm => bodyO1829 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1829).trans bodyInactive0) (bodyBr1831.trans bodyBr1829.symm) bodyCnt1829 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65838, 1253, 0, 1008⟩) PRE_first_tail_x15_r0_body.sizeA494 PRE_first_tail_x15_r0_body.sizeArgsA494 PRE_first_tail_x15_r0_body.sizeSymA494 PRE_first_tail_x15_r0_body.sizeMlxA494 PRE_first_tail_x15_r0_body.sizePayA494 PRE_first_tail_x15_r0_body.sizeTaA494 PRE_first_tail_x15_r0_body.sizeDecA494 PRE_first_tail_x15_r0_body.sizePreA494 PRE_first_tail_x15_r0_body.bodyPatchB494 (fun _ hm => bodyO1831 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1831).trans bodyInactive0) (bodyBr1832.trans bodyBr1831.symm) bodyCnt1831 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65838, 1253, 0, 1008⟩) bodyAcc1832 PRE_first_tail_x15_r0_body.bodyRunSeg494 bodyAcc1834 bodyHalt1834 PRE_first_tail_x15_r0_body.bodyStepA495 bodyTop1835 (fun _ hm => bodyO1832 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1832).trans bodyInactive0) (bodyBr1835.trans bodyBr1832.symm) bodyCnt1832 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
