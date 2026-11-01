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

kernel_rfl bodyO174 : PRE_first_tail_x15_r0_body.S174.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S174.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr174 : bridgeOf PRE_first_tail_x15_r0_body.s174.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc174 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.S174) = fun _ _ => true
kernel_rfl bodyAcc176 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s176 PRE_first_tail_x15_r0_body.S176) = fun _ _ => true
kernel_rfl bodyBr177 : bridgeOf PRE_first_tail_x15_r0_body.s177.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt176 : isHalt PRE_first_tail_x15_r0_body.s176.ctl = false
kernel_rfl bodyTop177 : noRetBlock PRE_first_tail_x15_r0_body.s177 = true
kernel_rfl bodyCnt174 : countersOkB PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.s177 = true
kernel_rfl bodyO177 : PRE_first_tail_x15_r0_body.S177.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S177.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr178 : bridgeOf PRE_first_tail_x15_r0_body.s178.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt177 : countersOkB PRE_first_tail_x15_r0_body.s177 PRE_first_tail_x15_r0_body.s178 = true
kernel_rfl bodyO178 : PRE_first_tail_x15_r0_body.S178.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S178.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc178 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s178 PRE_first_tail_x15_r0_body.S178) = fun _ _ => true
kernel_rfl bodyAcc179 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s179 PRE_first_tail_x15_r0_body.S179) = fun _ _ => true
kernel_rfl bodyBr180 : bridgeOf PRE_first_tail_x15_r0_body.s180.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt179 : isHalt PRE_first_tail_x15_r0_body.s179.ctl = false
kernel_rfl bodyTop180 : noRetBlock PRE_first_tail_x15_r0_body.s180 = true
kernel_rfl bodyCnt178 : countersOkB PRE_first_tail_x15_r0_body.s178 PRE_first_tail_x15_r0_body.s180 = true
kernel_rfl bodyO180 : PRE_first_tail_x15_r0_body.S180.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S180.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr181 : bridgeOf PRE_first_tail_x15_r0_body.s181.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt180 : countersOkB PRE_first_tail_x15_r0_body.s180 PRE_first_tail_x15_r0_body.s181 = true
kernel_rfl bodyO181 : PRE_first_tail_x15_r0_body.S181.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S181.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc181 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s181 PRE_first_tail_x15_r0_body.S181) = fun _ _ => true
kernel_rfl bodyAcc182 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s182 PRE_first_tail_x15_r0_body.S182) = fun _ _ => true
kernel_rfl bodyBr183 : bridgeOf PRE_first_tail_x15_r0_body.s183.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt182 : isHalt PRE_first_tail_x15_r0_body.s182.ctl = false
kernel_rfl bodyTop183 : noRetBlock PRE_first_tail_x15_r0_body.s183 = true
kernel_rfl bodyCnt181 : countersOkB PRE_first_tail_x15_r0_body.s181 PRE_first_tail_x15_r0_body.s183 = true
kernel_rfl bodyO183 : PRE_first_tail_x15_r0_body.S183.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S183.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr184 : bridgeOf PRE_first_tail_x15_r0_body.s184.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt183 : countersOkB PRE_first_tail_x15_r0_body.s183 PRE_first_tail_x15_r0_body.s184 = true
kernel_rfl bodyO184 : PRE_first_tail_x15_r0_body.S184.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S184.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc184 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s184 PRE_first_tail_x15_r0_body.S184) = fun _ _ => true
kernel_rfl bodyAcc185 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s185 PRE_first_tail_x15_r0_body.S185) = fun _ _ => true
kernel_rfl bodyBr186 : bridgeOf PRE_first_tail_x15_r0_body.s186.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt185 : isHalt PRE_first_tail_x15_r0_body.s185.ctl = false
kernel_rfl bodyTop186 : noRetBlock PRE_first_tail_x15_r0_body.s186 = true
kernel_rfl bodyCnt184 : countersOkB PRE_first_tail_x15_r0_body.s184 PRE_first_tail_x15_r0_body.s186 = true
kernel_rfl bodyO186 : PRE_first_tail_x15_r0_body.S186.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S186.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr187 : bridgeOf PRE_first_tail_x15_r0_body.s187.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt186 : countersOkB PRE_first_tail_x15_r0_body.s186 PRE_first_tail_x15_r0_body.s187 = true
kernel_rfl bodyO187 : PRE_first_tail_x15_r0_body.S187.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S187.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc187 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s187 PRE_first_tail_x15_r0_body.S187) = fun _ _ => true
kernel_rfl bodyAcc188 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s188 PRE_first_tail_x15_r0_body.S188) = fun _ _ => true
kernel_rfl bodyBr189 : bridgeOf PRE_first_tail_x15_r0_body.s189.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt188 : isHalt PRE_first_tail_x15_r0_body.s188.ctl = false
kernel_rfl bodyTop189 : noRetBlock PRE_first_tail_x15_r0_body.s189 = true
kernel_rfl bodyCnt187 : countersOkB PRE_first_tail_x15_r0_body.s187 PRE_first_tail_x15_r0_body.s189 = true

theorem bodyGlue18 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10290, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.S174)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10290, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s189 PRE_first_tail_x15_r0_body.S189) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) bodyAcc174 PRE_first_tail_x15_r0_body.bodyRunSeg47 bodyAcc176 bodyHalt176 PRE_first_tail_x15_r0_body.bodyStepA48 bodyTop177 (fun _ hm => bodyO174 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr174).trans bodyInactive0) (bodyBr177.trans bodyBr174.symm) bodyCnt174 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) PRE_first_tail_x15_r0_body.sizeA48 PRE_first_tail_x15_r0_body.sizeArgsA48 PRE_first_tail_x15_r0_body.sizeSymA48 PRE_first_tail_x15_r0_body.sizeMlxA48 PRE_first_tail_x15_r0_body.sizePayA48 PRE_first_tail_x15_r0_body.sizeTaA48 PRE_first_tail_x15_r0_body.sizeDecA48 PRE_first_tail_x15_r0_body.sizePreA48 PRE_first_tail_x15_r0_body.bodyPatchB48 (fun _ hm => bodyO177 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr177).trans bodyInactive0) (bodyBr178.trans bodyBr177.symm) bodyCnt177 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) bodyAcc178 PRE_first_tail_x15_r0_body.bodyRunSeg48 bodyAcc179 bodyHalt179 PRE_first_tail_x15_r0_body.bodyStepA49 bodyTop180 (fun _ hm => bodyO178 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr178).trans bodyInactive0) (bodyBr180.trans bodyBr178.symm) bodyCnt178 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) PRE_first_tail_x15_r0_body.sizeA49 PRE_first_tail_x15_r0_body.sizeArgsA49 PRE_first_tail_x15_r0_body.sizeSymA49 PRE_first_tail_x15_r0_body.sizeMlxA49 PRE_first_tail_x15_r0_body.sizePayA49 PRE_first_tail_x15_r0_body.sizeTaA49 PRE_first_tail_x15_r0_body.sizeDecA49 PRE_first_tail_x15_r0_body.sizePreA49 PRE_first_tail_x15_r0_body.bodyPatchB49 (fun _ hm => bodyO180 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr180).trans bodyInactive0) (bodyBr181.trans bodyBr180.symm) bodyCnt180 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) bodyAcc181 PRE_first_tail_x15_r0_body.bodyRunSeg49 bodyAcc182 bodyHalt182 PRE_first_tail_x15_r0_body.bodyStepA50 bodyTop183 (fun _ hm => bodyO181 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr181).trans bodyInactive0) (bodyBr183.trans bodyBr181.symm) bodyCnt181 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) PRE_first_tail_x15_r0_body.sizeA50 PRE_first_tail_x15_r0_body.sizeArgsA50 PRE_first_tail_x15_r0_body.sizeSymA50 PRE_first_tail_x15_r0_body.sizeMlxA50 PRE_first_tail_x15_r0_body.sizePayA50 PRE_first_tail_x15_r0_body.sizeTaA50 PRE_first_tail_x15_r0_body.sizeDecA50 PRE_first_tail_x15_r0_body.sizePreA50 PRE_first_tail_x15_r0_body.bodyPatchB50 (fun _ hm => bodyO183 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr183).trans bodyInactive0) (bodyBr184.trans bodyBr183.symm) bodyCnt183 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) bodyAcc184 PRE_first_tail_x15_r0_body.bodyRunSeg50 bodyAcc185 bodyHalt185 PRE_first_tail_x15_r0_body.bodyStepA51 bodyTop186 (fun _ hm => bodyO184 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr184).trans bodyInactive0) (bodyBr186.trans bodyBr184.symm) bodyCnt184 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) PRE_first_tail_x15_r0_body.sizeA51 PRE_first_tail_x15_r0_body.sizeArgsA51 PRE_first_tail_x15_r0_body.sizeSymA51 PRE_first_tail_x15_r0_body.sizeMlxA51 PRE_first_tail_x15_r0_body.sizePayA51 PRE_first_tail_x15_r0_body.sizeTaA51 PRE_first_tail_x15_r0_body.sizeDecA51 PRE_first_tail_x15_r0_body.sizePreA51 PRE_first_tail_x15_r0_body.bodyPatchB51 (fun _ hm => bodyO186 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr186).trans bodyInactive0) (bodyBr187.trans bodyBr186.symm) bodyCnt186 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10290, 148, 0, 99⟩) bodyAcc187 PRE_first_tail_x15_r0_body.bodyRunSeg51 bodyAcc188 bodyHalt188 PRE_first_tail_x15_r0_body.bodyStepA52 bodyTop189 (fun _ hm => bodyO187 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr187).trans bodyInactive0) (bodyBr189.trans bodyBr187.symm) bodyCnt187 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
