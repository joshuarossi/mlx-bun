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

kernel_rfl bodyO507 : PRE_first_tail_x15_r0_body.S507.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S507.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr507 : bridgeOf PRE_first_tail_x15_r0_body.s507.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc507 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.S507) = fun _ _ => true
kernel_rfl bodyAcc508 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s508 PRE_first_tail_x15_r0_body.S508) = fun _ _ => true
kernel_rfl bodyBr509 : bridgeOf PRE_first_tail_x15_r0_body.s509.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt508 : isHalt PRE_first_tail_x15_r0_body.s508.ctl = false
kernel_rfl bodyTop509 : noRetBlock PRE_first_tail_x15_r0_body.s509 = true
kernel_rfl bodyCnt507 : countersOkB PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.s509 = true
kernel_rfl bodyO509 : PRE_first_tail_x15_r0_body.S509.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S509.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr510 : bridgeOf PRE_first_tail_x15_r0_body.s510.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt509 : countersOkB PRE_first_tail_x15_r0_body.s509 PRE_first_tail_x15_r0_body.s510 = true
kernel_rfl bodyO510 : PRE_first_tail_x15_r0_body.S510.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S510.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc510 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s510 PRE_first_tail_x15_r0_body.S510) = fun _ _ => true
kernel_rfl bodyAcc512 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s512 PRE_first_tail_x15_r0_body.S512) = fun _ _ => true
kernel_rfl bodyBr513 : bridgeOf PRE_first_tail_x15_r0_body.s513.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt512 : isHalt PRE_first_tail_x15_r0_body.s512.ctl = false
kernel_rfl bodyTop513 : noRetBlock PRE_first_tail_x15_r0_body.s513 = true
kernel_rfl bodyCnt510 : countersOkB PRE_first_tail_x15_r0_body.s510 PRE_first_tail_x15_r0_body.s513 = true

theorem bodyGlue52 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21849, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.S507)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21849, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s513 PRE_first_tail_x15_r0_body.S513) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21849, 379, 0, 288⟩) bodyAcc507 PRE_first_tail_x15_r0_body.bodyRunSeg137 bodyAcc508 bodyHalt508 PRE_first_tail_x15_r0_body.bodyStepA138 bodyTop509 (fun _ hm => bodyO507 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr507).trans bodyInactive0) (bodyBr509.trans bodyBr507.symm) bodyCnt507 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21849, 379, 0, 288⟩) PRE_first_tail_x15_r0_body.sizeA138 PRE_first_tail_x15_r0_body.sizeArgsA138 PRE_first_tail_x15_r0_body.sizeSymA138 PRE_first_tail_x15_r0_body.sizeMlxA138 PRE_first_tail_x15_r0_body.sizePayA138 PRE_first_tail_x15_r0_body.sizeTaA138 PRE_first_tail_x15_r0_body.sizeDecA138 PRE_first_tail_x15_r0_body.sizePreA138 PRE_first_tail_x15_r0_body.bodyPatchB138 (fun _ hm => bodyO509 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr509).trans bodyInactive0) (bodyBr510.trans bodyBr509.symm) bodyCnt509 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨21849, 379, 0, 288⟩) bodyAcc510 PRE_first_tail_x15_r0_body.bodyRunSeg138 bodyAcc512 bodyHalt512 PRE_first_tail_x15_r0_body.bodyStepA139 bodyTop513 (fun _ hm => bodyO510 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr510).trans bodyInactive0) (bodyBr513.trans bodyBr510.symm) bodyCnt510 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
