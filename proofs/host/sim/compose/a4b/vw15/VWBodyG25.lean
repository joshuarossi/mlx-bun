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

kernel_rfl bodyO248 : PRE_first_tail_x15_r0_body.S248.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S248.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr248 : bridgeOf PRE_first_tail_x15_r0_body.s248.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc248 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.S248) = fun _ _ => true
kernel_rfl bodyAcc249 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s249 PRE_first_tail_x15_r0_body.S249) = fun _ _ => true
kernel_rfl bodyBr250 : bridgeOf PRE_first_tail_x15_r0_body.s250.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt249 : isHalt PRE_first_tail_x15_r0_body.s249.ctl = false
kernel_rfl bodyTop250 : noRetBlock PRE_first_tail_x15_r0_body.s250 = true
kernel_rfl bodyCnt248 : countersOkB PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.s250 = true
kernel_rfl bodyO250 : PRE_first_tail_x15_r0_body.S250.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S250.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr251 : bridgeOf PRE_first_tail_x15_r0_body.s251.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt250 : countersOkB PRE_first_tail_x15_r0_body.s250 PRE_first_tail_x15_r0_body.s251 = true
kernel_rfl bodyO251 : PRE_first_tail_x15_r0_body.S251.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S251.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc251 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s251 PRE_first_tail_x15_r0_body.S251) = fun _ _ => true
kernel_rfl bodyAcc253 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s253 PRE_first_tail_x15_r0_body.S253) = fun _ _ => true
kernel_rfl bodyBr254 : bridgeOf PRE_first_tail_x15_r0_body.s254.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt253 : isHalt PRE_first_tail_x15_r0_body.s253.ctl = false
kernel_rfl bodyTop254 : noRetBlock PRE_first_tail_x15_r0_body.s254 = true
kernel_rfl bodyCnt251 : countersOkB PRE_first_tail_x15_r0_body.s251 PRE_first_tail_x15_r0_body.s254 = true

theorem bodyGlue25 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12962, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.S248)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12962, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s254 PRE_first_tail_x15_r0_body.S254) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12962, 200, 0, 144⟩) bodyAcc248 PRE_first_tail_x15_r0_body.bodyRunSeg67 bodyAcc249 bodyHalt249 PRE_first_tail_x15_r0_body.bodyStepA68 bodyTop250 (fun _ hm => bodyO248 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr248).trans bodyInactive0) (bodyBr250.trans bodyBr248.symm) bodyCnt248 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12962, 200, 0, 144⟩) PRE_first_tail_x15_r0_body.sizeA68 PRE_first_tail_x15_r0_body.sizeArgsA68 PRE_first_tail_x15_r0_body.sizeSymA68 PRE_first_tail_x15_r0_body.sizeMlxA68 PRE_first_tail_x15_r0_body.sizePayA68 PRE_first_tail_x15_r0_body.sizeTaA68 PRE_first_tail_x15_r0_body.sizeDecA68 PRE_first_tail_x15_r0_body.sizePreA68 PRE_first_tail_x15_r0_body.bodyPatchB68 (fun _ hm => bodyO250 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr250).trans bodyInactive0) (bodyBr251.trans bodyBr250.symm) bodyCnt250 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12962, 200, 0, 144⟩) bodyAcc251 PRE_first_tail_x15_r0_body.bodyRunSeg68 bodyAcc253 bodyHalt253 PRE_first_tail_x15_r0_body.bodyStepA69 bodyTop254 (fun _ hm => bodyO251 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr251).trans bodyInactive0) (bodyBr254.trans bodyBr251.symm) bodyCnt251 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
