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

kernel_rfl bodyO1226 : PRE_first_tail_x15_r0_body.S1226.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1226.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1226 : bridgeOf PRE_first_tail_x15_r0_body.s1226.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1226 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.S1226) = fun _ _ => true
kernel_rfl bodyAcc1227 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1227 PRE_first_tail_x15_r0_body.S1227) = fun _ _ => true
kernel_rfl bodyBr1228 : bridgeOf PRE_first_tail_x15_r0_body.s1228.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1227 : isHalt PRE_first_tail_x15_r0_body.s1227.ctl = false
kernel_rfl bodyTop1228 : noRetBlock PRE_first_tail_x15_r0_body.s1228 = true
kernel_rfl bodyCnt1226 : countersOkB PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.s1228 = true
kernel_rfl bodyO1228 : PRE_first_tail_x15_r0_body.S1228.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1228.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1229 : bridgeOf PRE_first_tail_x15_r0_body.s1229.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1228 : countersOkB PRE_first_tail_x15_r0_body.s1228 PRE_first_tail_x15_r0_body.s1229 = true
kernel_rfl bodyO1229 : PRE_first_tail_x15_r0_body.S1229.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1229.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1229 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1229 PRE_first_tail_x15_r0_body.S1229) = fun _ _ => true
kernel_rfl bodyAcc1231 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1231 PRE_first_tail_x15_r0_body.S1231) = fun _ _ => true
kernel_rfl bodyBr1232 : bridgeOf PRE_first_tail_x15_r0_body.s1232.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1231 : isHalt PRE_first_tail_x15_r0_body.s1231.ctl = false
kernel_rfl bodyTop1232 : noRetBlock PRE_first_tail_x15_r0_body.s1232 = true
kernel_rfl bodyCnt1229 : countersOkB PRE_first_tail_x15_r0_body.s1229 PRE_first_tail_x15_r0_body.s1232 = true

theorem bodyGlue127 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46134, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.S1226)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46134, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1232 PRE_first_tail_x15_r0_body.S1232) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46134, 866, 0, 684⟩) bodyAcc1226 PRE_first_tail_x15_r0_body.bodyRunSeg331 bodyAcc1227 bodyHalt1227 PRE_first_tail_x15_r0_body.bodyStepA332 bodyTop1228 (fun _ hm => bodyO1226 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1226).trans bodyInactive0) (bodyBr1228.trans bodyBr1226.symm) bodyCnt1226 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46134, 866, 0, 684⟩) PRE_first_tail_x15_r0_body.sizeA332 PRE_first_tail_x15_r0_body.sizeArgsA332 PRE_first_tail_x15_r0_body.sizeSymA332 PRE_first_tail_x15_r0_body.sizeMlxA332 PRE_first_tail_x15_r0_body.sizePayA332 PRE_first_tail_x15_r0_body.sizeTaA332 PRE_first_tail_x15_r0_body.sizeDecA332 PRE_first_tail_x15_r0_body.sizePreA332 PRE_first_tail_x15_r0_body.bodyPatchB332 (fun _ hm => bodyO1228 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1228).trans bodyInactive0) (bodyBr1229.trans bodyBr1228.symm) bodyCnt1228 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46134, 866, 0, 684⟩) bodyAcc1229 PRE_first_tail_x15_r0_body.bodyRunSeg332 bodyAcc1231 bodyHalt1231 PRE_first_tail_x15_r0_body.bodyStepA333 bodyTop1232 (fun _ hm => bodyO1229 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1229).trans bodyInactive0) (bodyBr1232.trans bodyBr1229.symm) bodyCnt1229 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
