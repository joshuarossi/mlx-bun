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

kernel_rfl bodyO1542 : PRE_first_tail_x15_r0_body.S1542.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1542.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1542 : bridgeOf PRE_first_tail_x15_r0_body.s1542.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1542 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1542 PRE_first_tail_x15_r0_body.S1542) = fun _ _ => true
kernel_rfl bodyAcc1543 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1543 PRE_first_tail_x15_r0_body.S1543) = fun _ _ => true
kernel_rfl bodyBr1544 : bridgeOf PRE_first_tail_x15_r0_body.s1544.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1543 : isHalt PRE_first_tail_x15_r0_body.s1543.ctl = false
kernel_rfl bodyTop1544 : noRetBlock PRE_first_tail_x15_r0_body.s1544 = true
kernel_rfl bodyCnt1542 : countersOkB PRE_first_tail_x15_r0_body.s1542 PRE_first_tail_x15_r0_body.s1544 = true
kernel_rfl bodyO1544 : PRE_first_tail_x15_r0_body.S1544.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1544.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1545 : bridgeOf PRE_first_tail_x15_r0_body.s1545.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1544 : countersOkB PRE_first_tail_x15_r0_body.s1544 PRE_first_tail_x15_r0_body.s1545 = true
kernel_rfl bodyO1545 : PRE_first_tail_x15_r0_body.S1545.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1545.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1545 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1545 PRE_first_tail_x15_r0_body.S1545) = fun _ _ => true
kernel_rfl bodyAcc1547 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1547 PRE_first_tail_x15_r0_body.S1547) = fun _ _ => true
kernel_rfl bodyBr1548 : bridgeOf PRE_first_tail_x15_r0_body.s1548.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1547 : isHalt PRE_first_tail_x15_r0_body.s1547.ctl = false
kernel_rfl bodyTop1548 : noRetBlock PRE_first_tail_x15_r0_body.s1548 = true
kernel_rfl bodyCnt1545 : countersOkB PRE_first_tail_x15_r0_body.s1545 PRE_first_tail_x15_r0_body.s1548 = true

theorem bodyGlue160 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨56553, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1542 PRE_first_tail_x15_r0_body.S1542)
      (bodyCut NB T tk π i x0 bodyΘ ⟨56553, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1548 PRE_first_tail_x15_r0_body.S1548) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56553, 1072, 0, 855⟩) bodyAcc1542 PRE_first_tail_x15_r0_body.bodyRunSeg416 bodyAcc1543 bodyHalt1543 PRE_first_tail_x15_r0_body.bodyStepA417 bodyTop1544 (fun _ hm => bodyO1542 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1542).trans bodyInactive0) (bodyBr1544.trans bodyBr1542.symm) bodyCnt1542 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56553, 1072, 0, 855⟩) PRE_first_tail_x15_r0_body.sizeA417 PRE_first_tail_x15_r0_body.sizeArgsA417 PRE_first_tail_x15_r0_body.sizeSymA417 PRE_first_tail_x15_r0_body.sizeMlxA417 PRE_first_tail_x15_r0_body.sizePayA417 PRE_first_tail_x15_r0_body.sizeTaA417 PRE_first_tail_x15_r0_body.sizeDecA417 PRE_first_tail_x15_r0_body.sizePreA417 PRE_first_tail_x15_r0_body.bodyPatchB417 (fun _ hm => bodyO1544 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1544).trans bodyInactive0) (bodyBr1545.trans bodyBr1544.symm) bodyCnt1544 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56553, 1072, 0, 855⟩) bodyAcc1545 PRE_first_tail_x15_r0_body.bodyRunSeg417 bodyAcc1547 bodyHalt1547 PRE_first_tail_x15_r0_body.bodyStepA418 bodyTop1548 (fun _ hm => bodyO1545 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1545).trans bodyInactive0) (bodyBr1548.trans bodyBr1545.symm) bodyCnt1545 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
