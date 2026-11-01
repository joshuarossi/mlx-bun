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

kernel_rfl bodyO1180 : PRE_first_tail_x15_r0_body.S1180.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1180.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1180 : bridgeOf PRE_first_tail_x15_r0_body.s1180.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1180 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.S1180) = fun _ _ => true
kernel_rfl bodyAcc1182 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1182 PRE_first_tail_x15_r0_body.S1182) = fun _ _ => true
kernel_rfl bodyBr1183 : bridgeOf PRE_first_tail_x15_r0_body.s1183.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1182 : isHalt PRE_first_tail_x15_r0_body.s1182.ctl = false
kernel_rfl bodyTop1183 : noRetBlock PRE_first_tail_x15_r0_body.s1183 = true
kernel_rfl bodyCnt1180 : countersOkB PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.s1183 = true
kernel_rfl bodyO1183 : PRE_first_tail_x15_r0_body.S1183.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1183.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1184 : bridgeOf PRE_first_tail_x15_r0_body.s1184.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1183 : countersOkB PRE_first_tail_x15_r0_body.s1183 PRE_first_tail_x15_r0_body.s1184 = true
kernel_rfl bodyO1184 : PRE_first_tail_x15_r0_body.S1184.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1184.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1184 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1184 PRE_first_tail_x15_r0_body.S1184) = fun _ _ => true
kernel_rfl bodyAcc1185 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1185 PRE_first_tail_x15_r0_body.S1185) = fun _ _ => true
kernel_rfl bodyBr1186 : bridgeOf PRE_first_tail_x15_r0_body.s1186.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1185 : isHalt PRE_first_tail_x15_r0_body.s1185.ctl = false
kernel_rfl bodyTop1186 : noRetBlock PRE_first_tail_x15_r0_body.s1186 = true
kernel_rfl bodyCnt1184 : countersOkB PRE_first_tail_x15_r0_body.s1184 PRE_first_tail_x15_r0_body.s1186 = true
kernel_rfl bodyO1186 : PRE_first_tail_x15_r0_body.S1186.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1186.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1187 : bridgeOf PRE_first_tail_x15_r0_body.s1187.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1186 : countersOkB PRE_first_tail_x15_r0_body.s1186 PRE_first_tail_x15_r0_body.s1187 = true
kernel_rfl bodyO1187 : PRE_first_tail_x15_r0_body.S1187.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1187.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1187 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1187 PRE_first_tail_x15_r0_body.S1187) = fun _ _ => true
kernel_rfl bodyAcc1188 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1188 PRE_first_tail_x15_r0_body.S1188) = fun _ _ => true
kernel_rfl bodyBr1189 : bridgeOf PRE_first_tail_x15_r0_body.s1189.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1188 : isHalt PRE_first_tail_x15_r0_body.s1188.ctl = false
kernel_rfl bodyTop1189 : noRetBlock PRE_first_tail_x15_r0_body.s1189 = true
kernel_rfl bodyCnt1187 : countersOkB PRE_first_tail_x15_r0_body.s1187 PRE_first_tail_x15_r0_body.s1189 = true
kernel_rfl bodyO1189 : PRE_first_tail_x15_r0_body.S1189.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1189.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1190 : bridgeOf PRE_first_tail_x15_r0_body.s1190.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1189 : countersOkB PRE_first_tail_x15_r0_body.s1189 PRE_first_tail_x15_r0_body.s1190 = true
kernel_rfl bodyO1190 : PRE_first_tail_x15_r0_body.S1190.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1190.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1190 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1190 PRE_first_tail_x15_r0_body.S1190) = fun _ _ => true
kernel_rfl bodyAcc1191 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1191 PRE_first_tail_x15_r0_body.S1191) = fun _ _ => true
kernel_rfl bodyBr1192 : bridgeOf PRE_first_tail_x15_r0_body.s1192.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1191 : isHalt PRE_first_tail_x15_r0_body.s1191.ctl = false
kernel_rfl bodyTop1192 : noRetBlock PRE_first_tail_x15_r0_body.s1192 = true
kernel_rfl bodyCnt1190 : countersOkB PRE_first_tail_x15_r0_body.s1190 PRE_first_tail_x15_r0_body.s1192 = true
kernel_rfl bodyO1192 : PRE_first_tail_x15_r0_body.S1192.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1192.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1193 : bridgeOf PRE_first_tail_x15_r0_body.s1193.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1192 : countersOkB PRE_first_tail_x15_r0_body.s1192 PRE_first_tail_x15_r0_body.s1193 = true
kernel_rfl bodyO1193 : PRE_first_tail_x15_r0_body.S1193.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1193.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1193 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1193 PRE_first_tail_x15_r0_body.S1193) = fun _ _ => true
kernel_rfl bodyAcc1194 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1194 PRE_first_tail_x15_r0_body.S1194) = fun _ _ => true
kernel_rfl bodyBr1195 : bridgeOf PRE_first_tail_x15_r0_body.s1195.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1194 : isHalt PRE_first_tail_x15_r0_body.s1194.ctl = false
kernel_rfl bodyTop1195 : noRetBlock PRE_first_tail_x15_r0_body.s1195 = true
kernel_rfl bodyCnt1193 : countersOkB PRE_first_tail_x15_r0_body.s1193 PRE_first_tail_x15_r0_body.s1195 = true

theorem bodyGlue123 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨43824, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.S1180)
      (bodyCut NB T tk π i x0 bodyΘ ⟨43824, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1195 PRE_first_tail_x15_r0_body.S1195) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) bodyAcc1180 PRE_first_tail_x15_r0_body.bodyRunSeg318 bodyAcc1182 bodyHalt1182 PRE_first_tail_x15_r0_body.bodyStepA319 bodyTop1183 (fun _ hm => bodyO1180 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1180).trans bodyInactive0) (bodyBr1183.trans bodyBr1180.symm) bodyCnt1180 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) PRE_first_tail_x15_r0_body.sizeA319 PRE_first_tail_x15_r0_body.sizeArgsA319 PRE_first_tail_x15_r0_body.sizeSymA319 PRE_first_tail_x15_r0_body.sizeMlxA319 PRE_first_tail_x15_r0_body.sizePayA319 PRE_first_tail_x15_r0_body.sizeTaA319 PRE_first_tail_x15_r0_body.sizeDecA319 PRE_first_tail_x15_r0_body.sizePreA319 PRE_first_tail_x15_r0_body.bodyPatchB319 (fun _ hm => bodyO1183 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1183).trans bodyInactive0) (bodyBr1184.trans bodyBr1183.symm) bodyCnt1183 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) bodyAcc1184 PRE_first_tail_x15_r0_body.bodyRunSeg319 bodyAcc1185 bodyHalt1185 PRE_first_tail_x15_r0_body.bodyStepA320 bodyTop1186 (fun _ hm => bodyO1184 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1184).trans bodyInactive0) (bodyBr1186.trans bodyBr1184.symm) bodyCnt1184 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) PRE_first_tail_x15_r0_body.sizeA320 PRE_first_tail_x15_r0_body.sizeArgsA320 PRE_first_tail_x15_r0_body.sizeSymA320 PRE_first_tail_x15_r0_body.sizeMlxA320 PRE_first_tail_x15_r0_body.sizePayA320 PRE_first_tail_x15_r0_body.sizeTaA320 PRE_first_tail_x15_r0_body.sizeDecA320 PRE_first_tail_x15_r0_body.sizePreA320 PRE_first_tail_x15_r0_body.bodyPatchB320 (fun _ hm => bodyO1186 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1186).trans bodyInactive0) (bodyBr1187.trans bodyBr1186.symm) bodyCnt1186 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) bodyAcc1187 PRE_first_tail_x15_r0_body.bodyRunSeg320 bodyAcc1188 bodyHalt1188 PRE_first_tail_x15_r0_body.bodyStepA321 bodyTop1189 (fun _ hm => bodyO1187 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1187).trans bodyInactive0) (bodyBr1189.trans bodyBr1187.symm) bodyCnt1187 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) PRE_first_tail_x15_r0_body.sizeA321 PRE_first_tail_x15_r0_body.sizeArgsA321 PRE_first_tail_x15_r0_body.sizeSymA321 PRE_first_tail_x15_r0_body.sizeMlxA321 PRE_first_tail_x15_r0_body.sizePayA321 PRE_first_tail_x15_r0_body.sizeTaA321 PRE_first_tail_x15_r0_body.sizeDecA321 PRE_first_tail_x15_r0_body.sizePreA321 PRE_first_tail_x15_r0_body.bodyPatchB321 (fun _ hm => bodyO1189 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1189).trans bodyInactive0) (bodyBr1190.trans bodyBr1189.symm) bodyCnt1189 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) bodyAcc1190 PRE_first_tail_x15_r0_body.bodyRunSeg321 bodyAcc1191 bodyHalt1191 PRE_first_tail_x15_r0_body.bodyStepA322 bodyTop1192 (fun _ hm => bodyO1190 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1190).trans bodyInactive0) (bodyBr1192.trans bodyBr1190.symm) bodyCnt1190 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) PRE_first_tail_x15_r0_body.sizeA322 PRE_first_tail_x15_r0_body.sizeArgsA322 PRE_first_tail_x15_r0_body.sizeSymA322 PRE_first_tail_x15_r0_body.sizeMlxA322 PRE_first_tail_x15_r0_body.sizePayA322 PRE_first_tail_x15_r0_body.sizeTaA322 PRE_first_tail_x15_r0_body.sizeDecA322 PRE_first_tail_x15_r0_body.sizePreA322 PRE_first_tail_x15_r0_body.bodyPatchB322 (fun _ hm => bodyO1192 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1192).trans bodyInactive0) (bodyBr1193.trans bodyBr1192.symm) bodyCnt1192 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43824, 816, 0, 648⟩) bodyAcc1193 PRE_first_tail_x15_r0_body.bodyRunSeg322 bodyAcc1194 bodyHalt1194 PRE_first_tail_x15_r0_body.bodyStepA323 bodyTop1195 (fun _ hm => bodyO1193 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1193).trans bodyInactive0) (bodyBr1195.trans bodyBr1193.symm) bodyCnt1193 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
