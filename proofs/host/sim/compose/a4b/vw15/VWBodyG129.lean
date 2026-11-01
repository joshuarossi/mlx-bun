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

kernel_rfl bodyO1238 : PRE_first_tail_x15_r0_body.S1238.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1238.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1238 : bridgeOf PRE_first_tail_x15_r0_body.s1238.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1238 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.S1238) = fun _ _ => true
kernel_rfl bodyAcc1240 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1240 PRE_first_tail_x15_r0_body.S1240) = fun _ _ => true
kernel_rfl bodyBr1241 : bridgeOf PRE_first_tail_x15_r0_body.s1241.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1240 : isHalt PRE_first_tail_x15_r0_body.s1240.ctl = false
kernel_rfl bodyTop1241 : noRetBlock PRE_first_tail_x15_r0_body.s1241 = true
kernel_rfl bodyCnt1238 : countersOkB PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.s1241 = true
kernel_rfl bodyO1241 : PRE_first_tail_x15_r0_body.S1241.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1241.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1242 : bridgeOf PRE_first_tail_x15_r0_body.s1242.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1241 : countersOkB PRE_first_tail_x15_r0_body.s1241 PRE_first_tail_x15_r0_body.s1242 = true
kernel_rfl bodyO1242 : PRE_first_tail_x15_r0_body.S1242.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1242.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1242 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1242 PRE_first_tail_x15_r0_body.S1242) = fun _ _ => true
kernel_rfl bodyAcc1244 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1244 PRE_first_tail_x15_r0_body.S1244) = fun _ _ => true
kernel_rfl bodyBr1245 : bridgeOf PRE_first_tail_x15_r0_body.s1245.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1244 : isHalt PRE_first_tail_x15_r0_body.s1244.ctl = false
kernel_rfl bodyTop1245 : noRetBlock PRE_first_tail_x15_r0_body.s1245 = true
kernel_rfl bodyCnt1242 : countersOkB PRE_first_tail_x15_r0_body.s1242 PRE_first_tail_x15_r0_body.s1245 = true
kernel_rfl bodyO1245 : PRE_first_tail_x15_r0_body.S1245.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1245.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1246 : bridgeOf PRE_first_tail_x15_r0_body.s1246.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1245 : countersOkB PRE_first_tail_x15_r0_body.s1245 PRE_first_tail_x15_r0_body.s1246 = true
kernel_rfl bodyO1246 : PRE_first_tail_x15_r0_body.S1246.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1246.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1246 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1246 PRE_first_tail_x15_r0_body.S1246) = fun _ _ => true
kernel_rfl bodyAcc1247 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1247 PRE_first_tail_x15_r0_body.S1247) = fun _ _ => true
kernel_rfl bodyBr1248 : bridgeOf PRE_first_tail_x15_r0_body.s1248.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1247 : isHalt PRE_first_tail_x15_r0_body.s1247.ctl = false
kernel_rfl bodyTop1248 : noRetBlock PRE_first_tail_x15_r0_body.s1248 = true
kernel_rfl bodyCnt1246 : countersOkB PRE_first_tail_x15_r0_body.s1246 PRE_first_tail_x15_r0_body.s1248 = true
kernel_rfl bodyO1248 : PRE_first_tail_x15_r0_body.S1248.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1248.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1249 : bridgeOf PRE_first_tail_x15_r0_body.s1249.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1248 : countersOkB PRE_first_tail_x15_r0_body.s1248 PRE_first_tail_x15_r0_body.s1249 = true
kernel_rfl bodyO1249 : PRE_first_tail_x15_r0_body.S1249.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1249.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1249 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1249 PRE_first_tail_x15_r0_body.S1249) = fun _ _ => true
kernel_rfl bodyAcc1251 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1251 PRE_first_tail_x15_r0_body.S1251) = fun _ _ => true
kernel_rfl bodyBr1252 : bridgeOf PRE_first_tail_x15_r0_body.s1252.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1251 : isHalt PRE_first_tail_x15_r0_body.s1251.ctl = false
kernel_rfl bodyTop1252 : noRetBlock PRE_first_tail_x15_r0_body.s1252 = true
kernel_rfl bodyCnt1249 : countersOkB PRE_first_tail_x15_r0_body.s1249 PRE_first_tail_x15_r0_body.s1252 = true

theorem bodyGlue129 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46146, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.S1238)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46146, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1252 PRE_first_tail_x15_r0_body.S1252) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46146, 866, 0, 684⟩) bodyAcc1238 PRE_first_tail_x15_r0_body.bodyRunSeg334 bodyAcc1240 bodyHalt1240 PRE_first_tail_x15_r0_body.bodyStepA335 bodyTop1241 (fun _ hm => bodyO1238 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1238).trans bodyInactive0) (bodyBr1241.trans bodyBr1238.symm) bodyCnt1238 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46146, 866, 0, 684⟩) PRE_first_tail_x15_r0_body.sizeA335 PRE_first_tail_x15_r0_body.sizeArgsA335 PRE_first_tail_x15_r0_body.sizeSymA335 PRE_first_tail_x15_r0_body.sizeMlxA335 PRE_first_tail_x15_r0_body.sizePayA335 PRE_first_tail_x15_r0_body.sizeTaA335 PRE_first_tail_x15_r0_body.sizeDecA335 PRE_first_tail_x15_r0_body.sizePreA335 PRE_first_tail_x15_r0_body.bodyPatchB335 (fun _ hm => bodyO1241 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1241).trans bodyInactive0) (bodyBr1242.trans bodyBr1241.symm) bodyCnt1241 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46146, 866, 0, 684⟩) bodyAcc1242 PRE_first_tail_x15_r0_body.bodyRunSeg335 bodyAcc1244 bodyHalt1244 PRE_first_tail_x15_r0_body.bodyStepA336 bodyTop1245 (fun _ hm => bodyO1242 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1242).trans bodyInactive0) (bodyBr1245.trans bodyBr1242.symm) bodyCnt1242 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46146, 866, 0, 684⟩) PRE_first_tail_x15_r0_body.sizeA336 PRE_first_tail_x15_r0_body.sizeArgsA336 PRE_first_tail_x15_r0_body.sizeSymA336 PRE_first_tail_x15_r0_body.sizeMlxA336 PRE_first_tail_x15_r0_body.sizePayA336 PRE_first_tail_x15_r0_body.sizeTaA336 PRE_first_tail_x15_r0_body.sizeDecA336 PRE_first_tail_x15_r0_body.sizePreA336 PRE_first_tail_x15_r0_body.bodyPatchB336 (fun _ hm => bodyO1245 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1245).trans bodyInactive0) (bodyBr1246.trans bodyBr1245.symm) bodyCnt1245 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46146, 866, 0, 684⟩) bodyAcc1246 PRE_first_tail_x15_r0_body.bodyRunSeg336 bodyAcc1247 bodyHalt1247 PRE_first_tail_x15_r0_body.bodyStepA337 bodyTop1248 (fun _ hm => bodyO1246 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1246).trans bodyInactive0) (bodyBr1248.trans bodyBr1246.symm) bodyCnt1246 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46146, 866, 0, 684⟩) PRE_first_tail_x15_r0_body.sizeA337 PRE_first_tail_x15_r0_body.sizeArgsA337 PRE_first_tail_x15_r0_body.sizeSymA337 PRE_first_tail_x15_r0_body.sizeMlxA337 PRE_first_tail_x15_r0_body.sizePayA337 PRE_first_tail_x15_r0_body.sizeTaA337 PRE_first_tail_x15_r0_body.sizeDecA337 PRE_first_tail_x15_r0_body.sizePreA337 PRE_first_tail_x15_r0_body.bodyPatchB337 (fun _ hm => bodyO1248 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1248).trans bodyInactive0) (bodyBr1249.trans bodyBr1248.symm) bodyCnt1248 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46146, 866, 0, 684⟩) bodyAcc1249 PRE_first_tail_x15_r0_body.bodyRunSeg337 bodyAcc1251 bodyHalt1251 PRE_first_tail_x15_r0_body.bodyStepA338 bodyTop1252 (fun _ hm => bodyO1249 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1249).trans bodyInactive0) (bodyBr1252.trans bodyBr1249.symm) bodyCnt1249 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
