import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.VWBodyBase
import host.sim.compose.a4b.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.Bridge
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSteps1
import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSeg5
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSeg6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO16 : PRE_first_tail_x15_r0_body.S16.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S16.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr16 : bridgeOf PRE_first_tail_x15_r0_body.s16.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc16 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s16 PRE_first_tail_x15_r0_body.S16) = fun _ _ => true
kernel_rfl bodyAcc17 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.S17) = fun _ _ => true
kernel_rfl bodyBr18 : bridgeOf PRE_first_tail_x15_r0_body.s18.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt17 : isHalt PRE_first_tail_x15_r0_body.s17.ctl = false
kernel_rfl bodyTop18 : noRetBlock PRE_first_tail_x15_r0_body.s18 = true
kernel_rfl bodyCnt16 : countersOkB PRE_first_tail_x15_r0_body.s16 PRE_first_tail_x15_r0_body.s18 = true
kernel_rfl bodyO18 : PRE_first_tail_x15_r0_body.S18.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S18.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr19 : bridgeOf PRE_first_tail_x15_r0_body.s19.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt18 : countersOkB PRE_first_tail_x15_r0_body.s18 PRE_first_tail_x15_r0_body.s19 = true
kernel_rfl bodyO19 : PRE_first_tail_x15_r0_body.S19.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S19.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc19 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s19 PRE_first_tail_x15_r0_body.S19) = fun _ _ => true
kernel_rfl bodyAcc20 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s20 PRE_first_tail_x15_r0_body.S20) = fun _ _ => true
kernel_rfl bodyBr21 : bridgeOf PRE_first_tail_x15_r0_body.s21.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt20 : isHalt PRE_first_tail_x15_r0_body.s20.ctl = false
kernel_rfl bodyTop21 : noRetBlock PRE_first_tail_x15_r0_body.s21 = true
kernel_rfl bodyCnt19 : countersOkB PRE_first_tail_x15_r0_body.s19 PRE_first_tail_x15_r0_body.s21 = true

theorem bodyGlue1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    ∃ n, CutStep (bodyCut NB T tk π i ⟨5263, 46, 0⟩ bodyM PRE_first_tail_x15_r0_body.s16 PRE_first_tail_x15_r0_body.S16)
      (bodyCut NB T tk π i ⟨5263, 46, 0⟩ bodyM PRE_first_tail_x15_r0_body.s21 PRE_first_tail_x15_r0_body.S21) n :=
  ⟨_, ((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨5263, 46, 0⟩) bodyAcc16 PRE_first_tail_x15_r0_body.bodyRunSeg5 bodyAcc17 bodyHalt17 PRE_first_tail_x15_r0_body.bodyStepA6 bodyTop18 (fun _ hm => bodyO16 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr16).trans bodyInactive0) (bodyBr18.trans bodyBr16.symm) bodyCnt16).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨5263, 46, 0⟩) PRE_first_tail_x15_r0_body.sizeA6 PRE_first_tail_x15_r0_body.sizeArgsA6 PRE_first_tail_x15_r0_body.sizeSymA6 PRE_first_tail_x15_r0_body.sizeMlxA6 PRE_first_tail_x15_r0_body.sizePayA6 PRE_first_tail_x15_r0_body.sizeTaA6 PRE_first_tail_x15_r0_body.sizeDecA6 PRE_first_tail_x15_r0_body.sizePreA6 PRE_first_tail_x15_r0_body.bodyPatchB6 (fun _ hm => bodyO18 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr18).trans bodyInactive0) (bodyBr19.trans bodyBr18.symm) bodyCnt18)).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨5263, 46, 0⟩) bodyAcc19 PRE_first_tail_x15_r0_body.bodyRunSeg6 bodyAcc20 bodyHalt20 PRE_first_tail_x15_r0_body.bodyStepA7 bodyTop21 (fun _ hm => bodyO19 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr19).trans bodyInactive0) (bodyBr21.trans bodyBr19.symm) bodyCnt19)⟩

end Host.Ts.Sim.Compose.VWFirst
