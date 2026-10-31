import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.VWBodyBase
import host.sim.compose.a4b.VWBodyOracles_0
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

kernel_rfl bodyGood16 : (fwdRows.all fun r => goodLin r.ps (varsOf r.V Oracles.PRE_first_tail_x15_r0_body.map_g1) PRE_first_tail_x15_r0_body.S16.oracle) = true
kernel_rfl bodyBr16 : bridgeOf PRE_first_tail_x15_r0_body.s16.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc16 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s16 PRE_first_tail_x15_r0_body.S16) = fun _ _ => true
kernel_rfl bodyAcc17 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.S17) = fun _ _ => true
kernel_rfl bodyBr18 : bridgeOf PRE_first_tail_x15_r0_body.s18.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt17 : isHalt PRE_first_tail_x15_r0_body.s17.ctl = false
kernel_rfl bodyTop18 : noRetBlock PRE_first_tail_x15_r0_body.s18 = true
kernel_rfl bodyGood18 : (fwdRows.all fun r => goodLin r.ps (varsOf r.V Oracles.PRE_first_tail_x15_r0_body.map_g1) PRE_first_tail_x15_r0_body.S18.oracle) = true
kernel_rfl bodyBr19 : bridgeOf PRE_first_tail_x15_r0_body.s19.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyGood19 : (fwdRows.all fun r => goodLin r.ps (varsOf r.V Oracles.PRE_first_tail_x15_r0_body.map_g1) PRE_first_tail_x15_r0_body.S19.oracle) = true
kernel_rfl bodyAcc19 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s19 PRE_first_tail_x15_r0_body.S19) = fun _ _ => true
kernel_rfl bodyAcc20 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s20 PRE_first_tail_x15_r0_body.S20) = fun _ _ => true
kernel_rfl bodyBr21 : bridgeOf PRE_first_tail_x15_r0_body.s21.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt20 : isHalt PRE_first_tail_x15_r0_body.s20.ctl = false
kernel_rfl bodyTop21 : noRetBlock PRE_first_tail_x15_r0_body.s21 = true

theorem bodyGlue1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    ∃ n, CutStep (bodyCut NB T tk π i 5263 Oracles.PRE_first_tail_x15_r0_body.map_g1 PRE_first_tail_x15_r0_body.s16 PRE_first_tail_x15_r0_body.S16)
      (bodyCut NB T tk π i 5263 Oracles.PRE_first_tail_x15_r0_body.map_g1 PRE_first_tail_x15_r0_body.s21 PRE_first_tail_x15_r0_body.S21) n :=
  ⟨_, ((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Dmax := 5263) bodyAcc16 PRE_first_tail_x15_r0_body.bodyRunSeg5 bodyAcc17 bodyHalt17 PRE_first_tail_x15_r0_body.bodyStepA6 bodyTop18 (fun _ hm => good_of_row (List.all_eq_true.mp bodyGood16 r hr) hi hm) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr16).trans bodyInactive0) (bodyBr18.trans bodyBr16.symm)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Dmax := 5263) PRE_first_tail_x15_r0_body.sizeA6 PRE_first_tail_x15_r0_body.sizeArgsA6 PRE_first_tail_x15_r0_body.sizeSymA6 PRE_first_tail_x15_r0_body.sizeMlxA6 PRE_first_tail_x15_r0_body.sizePayA6 PRE_first_tail_x15_r0_body.sizeTaA6 PRE_first_tail_x15_r0_body.sizeDecA6 PRE_first_tail_x15_r0_body.sizePreA6 PRE_first_tail_x15_r0_body.bodyPatchB6 (fun _ hm => good_of_row (List.all_eq_true.mp bodyGood18 r hr) hi hm) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr18).trans bodyInactive0) (bodyBr19.trans bodyBr18.symm))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Dmax := 5263) bodyAcc19 PRE_first_tail_x15_r0_body.bodyRunSeg6 bodyAcc20 bodyHalt20 PRE_first_tail_x15_r0_body.bodyStepA7 bodyTop21 (fun _ hm => good_of_row (List.all_eq_true.mp bodyGood19 r hr) hi hm) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr19).trans bodyInactive0) (bodyBr21.trans bodyBr19.symm))⟩

end Host.Ts.Sim.Compose.VWFirst
