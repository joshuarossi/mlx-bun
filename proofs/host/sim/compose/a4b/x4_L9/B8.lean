import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.States
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B00
import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L9.VWBodyChain
import host.sim.compose.a4b.x4_L9.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B24
import host.sim.template.a4pre_first_tail_x4_L9_r0_body.m.B14

section -- VWBodyOracles_16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_body.map_g64 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_body.chk_g64 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_body.map_g64) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_body.O))) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodyG64
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1418 : PRE_first_tail_x4_L9_r0_body.S1418.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1418.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1418 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1418.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyAcc1418 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1418 PRE_first_tail_x4_L9_r0_body.S1418) = fun _ _ => true
kernel_rfl bodyAcc1421 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1421 PRE_first_tail_x4_L9_r0_body.S1421) = fun _ _ => true
kernel_rfl bodyBr1422 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1422.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyHalt1421 : isHalt PRE_first_tail_x4_L9_r0_body.s1421.ctl = false
kernel_rfl bodyTop1422 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1422 = true
kernel_rfl bodyCnt1418 : countersOkB PRE_first_tail_x4_L9_r0_body.s1418 PRE_first_tail_x4_L9_r0_body.s1422 = true
kernel_rfl bodyO1422 : PRE_first_tail_x4_L9_r0_body.S1422.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1422.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyBr1423 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1423.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyCnt1422 : countersOkB PRE_first_tail_x4_L9_r0_body.s1422 PRE_first_tail_x4_L9_r0_body.s1423 = true
kernel_rfl bodyO1423 : PRE_first_tail_x4_L9_r0_body.S1423.oracle = List.drop (PRE_first_tail_x4_L9_r0_body.O.length - PRE_first_tail_x4_L9_r0_body.S1423.oracle.length) PRE_first_tail_x4_L9_r0_body.O
kernel_rfl bodyAcc1423 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_body.s1423 PRE_first_tail_x4_L9_r0_body.S1423) = fun _ _ => true
kernel_rfl bodyBr1427 : bridgeOf PRE_first_tail_x4_L9_r0_body.s1427.ffi = bridgeOf PRE_first_tail_x4_L9_r0_body.s0.ffi
kernel_rfl bodyTop1427 : noRetBlock PRE_first_tail_x4_L9_r0_body.s1427 = true
kernel_rfl bodyCnt1423 : countersOkB PRE_first_tail_x4_L9_r0_body.s1423 PRE_first_tail_x4_L9_r0_body.s1427 = true

theorem bodyGlue64 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1418 PRE_first_tail_x4_L9_r0_body.S1418)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_body.s1427 PRE_first_tail_x4_L9_r0_body.S1427) 20016 :=
  (((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64866, 1253, 0, 0⟩) bodyAcc1418 PRE_first_tail_x4_L9_r0_body.bodyRunSeg367 bodyAcc1421 bodyHalt1421 PRE_first_tail_x4_L9_r0_body.bodyStepA368 bodyTop1422 (fun _ hm => bodyO1418 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1418).trans bodyInactive0) (bodyBr1422.trans bodyBr1418.symm) bodyCnt1418 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64866, 1253, 0, 0⟩) PRE_first_tail_x4_L9_r0_body.sizeA368 PRE_first_tail_x4_L9_r0_body.sizeArgsA368 PRE_first_tail_x4_L9_r0_body.sizeSymA368 PRE_first_tail_x4_L9_r0_body.sizeMlxA368 PRE_first_tail_x4_L9_r0_body.sizePayA368 PRE_first_tail_x4_L9_r0_body.sizeTaA368 PRE_first_tail_x4_L9_r0_body.sizeDecA368 PRE_first_tail_x4_L9_r0_body.sizePreA368 PRE_first_tail_x4_L9_r0_body.bodyPatchB368 (fun _ hm => bodyO1422 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1422).trans bodyInactive0) (bodyBr1423.trans bodyBr1422.symm) bodyCnt1422 (BodyTrail.ofTrack x0))).trans (bodyLitGlue (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64866, 1253, 0, 0⟩) bodyAcc1423 PRE_first_tail_x4_L9_r0_body.bodyRunSeg368 bodyTop1427 (fun _ hm => bodyO1423 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1423).trans bodyInactive0) (bodyBr1427.trans bodyBr1423.symm) bodyCnt1423 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9

end
