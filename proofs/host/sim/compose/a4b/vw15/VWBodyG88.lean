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

kernel_rfl bodyO852 : PRE_first_tail_x15_r0_body.S852.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S852.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr852 : bridgeOf PRE_first_tail_x15_r0_body.s852.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc852 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s852 PRE_first_tail_x15_r0_body.S852) = fun _ _ => true
kernel_rfl bodyAcc853 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s853 PRE_first_tail_x15_r0_body.S853) = fun _ _ => true
kernel_rfl bodyBr854 : bridgeOf PRE_first_tail_x15_r0_body.s854.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt853 : isHalt PRE_first_tail_x15_r0_body.s853.ctl = false
kernel_rfl bodyTop854 : noRetBlock PRE_first_tail_x15_r0_body.s854 = true
kernel_rfl bodyCnt852 : countersOkB PRE_first_tail_x15_r0_body.s852 PRE_first_tail_x15_r0_body.s854 = true
kernel_rfl bodyO854 : PRE_first_tail_x15_r0_body.S854.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S854.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr855 : bridgeOf PRE_first_tail_x15_r0_body.s855.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt854 : countersOkB PRE_first_tail_x15_r0_body.s854 PRE_first_tail_x15_r0_body.s855 = true
kernel_rfl bodyO855 : PRE_first_tail_x15_r0_body.S855.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S855.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc855 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s855 PRE_first_tail_x15_r0_body.S855) = fun _ _ => true
kernel_rfl bodyAcc857 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s857 PRE_first_tail_x15_r0_body.S857) = fun _ _ => true
kernel_rfl bodyBr858 : bridgeOf PRE_first_tail_x15_r0_body.s858.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt857 : isHalt PRE_first_tail_x15_r0_body.s857.ctl = false
kernel_rfl bodyTop858 : noRetBlock PRE_first_tail_x15_r0_body.s858 = true
kernel_rfl bodyCnt855 : countersOkB PRE_first_tail_x15_r0_body.s855 PRE_first_tail_x15_r0_body.s858 = true

theorem bodyGlue88 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨33402, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s852 PRE_first_tail_x15_r0_body.S852)
      (bodyCut NB T tk π i x0 bodyΘ ⟨33402, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s858 PRE_first_tail_x15_r0_body.S858) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33402, 610, 0, 477⟩) bodyAcc852 PRE_first_tail_x15_r0_body.bodyRunSeg230 bodyAcc853 bodyHalt853 PRE_first_tail_x15_r0_body.bodyStepA231 bodyTop854 (fun _ hm => bodyO852 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr852).trans bodyInactive0) (bodyBr854.trans bodyBr852.symm) bodyCnt852 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33402, 610, 0, 477⟩) PRE_first_tail_x15_r0_body.sizeA231 PRE_first_tail_x15_r0_body.sizeArgsA231 PRE_first_tail_x15_r0_body.sizeSymA231 PRE_first_tail_x15_r0_body.sizeMlxA231 PRE_first_tail_x15_r0_body.sizePayA231 PRE_first_tail_x15_r0_body.sizeTaA231 PRE_first_tail_x15_r0_body.sizeDecA231 PRE_first_tail_x15_r0_body.sizePreA231 PRE_first_tail_x15_r0_body.bodyPatchB231 (fun _ hm => bodyO854 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr854).trans bodyInactive0) (bodyBr855.trans bodyBr854.symm) bodyCnt854 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33402, 610, 0, 477⟩) bodyAcc855 PRE_first_tail_x15_r0_body.bodyRunSeg231 bodyAcc857 bodyHalt857 PRE_first_tail_x15_r0_body.bodyStepA232 bodyTop858 (fun _ hm => bodyO855 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr855).trans bodyInactive0) (bodyBr858.trans bodyBr855.symm) bodyCnt855 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
