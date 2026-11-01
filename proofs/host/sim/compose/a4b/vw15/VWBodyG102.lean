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

kernel_rfl bodyO979 : PRE_first_tail_x15_r0_body.S979.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S979.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr979 : bridgeOf PRE_first_tail_x15_r0_body.s979.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc979 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.S979) = fun _ _ => true
kernel_rfl bodyAcc981 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s981 PRE_first_tail_x15_r0_body.S981) = fun _ _ => true
kernel_rfl bodyBr982 : bridgeOf PRE_first_tail_x15_r0_body.s982.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt981 : isHalt PRE_first_tail_x15_r0_body.s981.ctl = false
kernel_rfl bodyTop982 : noRetBlock PRE_first_tail_x15_r0_body.s982 = true
kernel_rfl bodyCnt979 : countersOkB PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.s982 = true
kernel_rfl bodyO982 : PRE_first_tail_x15_r0_body.S982.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S982.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr983 : bridgeOf PRE_first_tail_x15_r0_body.s983.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt982 : countersOkB PRE_first_tail_x15_r0_body.s982 PRE_first_tail_x15_r0_body.s983 = true
kernel_rfl bodyO983 : PRE_first_tail_x15_r0_body.S983.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S983.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc983 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s983 PRE_first_tail_x15_r0_body.S983) = fun _ _ => true
kernel_rfl bodyAcc984 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s984 PRE_first_tail_x15_r0_body.S984) = fun _ _ => true
kernel_rfl bodyBr985 : bridgeOf PRE_first_tail_x15_r0_body.s985.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt984 : isHalt PRE_first_tail_x15_r0_body.s984.ctl = false
kernel_rfl bodyTop985 : noRetBlock PRE_first_tail_x15_r0_body.s985 = true
kernel_rfl bodyCnt983 : countersOkB PRE_first_tail_x15_r0_body.s983 PRE_first_tail_x15_r0_body.s985 = true
kernel_rfl bodyO985 : PRE_first_tail_x15_r0_body.S985.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S985.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr986 : bridgeOf PRE_first_tail_x15_r0_body.s986.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt985 : countersOkB PRE_first_tail_x15_r0_body.s985 PRE_first_tail_x15_r0_body.s986 = true
kernel_rfl bodyO986 : PRE_first_tail_x15_r0_body.S986.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S986.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc986 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s986 PRE_first_tail_x15_r0_body.S986) = fun _ _ => true
kernel_rfl bodyAcc987 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s987 PRE_first_tail_x15_r0_body.S987) = fun _ _ => true
kernel_rfl bodyBr988 : bridgeOf PRE_first_tail_x15_r0_body.s988.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt987 : isHalt PRE_first_tail_x15_r0_body.s987.ctl = false
kernel_rfl bodyTop988 : noRetBlock PRE_first_tail_x15_r0_body.s988 = true
kernel_rfl bodyCnt986 : countersOkB PRE_first_tail_x15_r0_body.s986 PRE_first_tail_x15_r0_body.s988 = true
kernel_rfl bodyO988 : PRE_first_tail_x15_r0_body.S988.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S988.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr989 : bridgeOf PRE_first_tail_x15_r0_body.s989.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt988 : countersOkB PRE_first_tail_x15_r0_body.s988 PRE_first_tail_x15_r0_body.s989 = true
kernel_rfl bodyO989 : PRE_first_tail_x15_r0_body.S989.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S989.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc989 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s989 PRE_first_tail_x15_r0_body.S989) = fun _ _ => true
kernel_rfl bodyAcc990 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s990 PRE_first_tail_x15_r0_body.S990) = fun _ _ => true
kernel_rfl bodyBr991 : bridgeOf PRE_first_tail_x15_r0_body.s991.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt990 : isHalt PRE_first_tail_x15_r0_body.s990.ctl = false
kernel_rfl bodyTop991 : noRetBlock PRE_first_tail_x15_r0_body.s991 = true
kernel_rfl bodyCnt989 : countersOkB PRE_first_tail_x15_r0_body.s989 PRE_first_tail_x15_r0_body.s991 = true
kernel_rfl bodyO991 : PRE_first_tail_x15_r0_body.S991.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S991.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr992 : bridgeOf PRE_first_tail_x15_r0_body.s992.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt991 : countersOkB PRE_first_tail_x15_r0_body.s991 PRE_first_tail_x15_r0_body.s992 = true
kernel_rfl bodyO992 : PRE_first_tail_x15_r0_body.S992.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S992.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc992 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s992 PRE_first_tail_x15_r0_body.S992) = fun _ _ => true
kernel_rfl bodyAcc993 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s993 PRE_first_tail_x15_r0_body.S993) = fun _ _ => true
kernel_rfl bodyBr994 : bridgeOf PRE_first_tail_x15_r0_body.s994.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt993 : isHalt PRE_first_tail_x15_r0_body.s993.ctl = false
kernel_rfl bodyTop994 : noRetBlock PRE_first_tail_x15_r0_body.s994 = true
kernel_rfl bodyCnt992 : countersOkB PRE_first_tail_x15_r0_body.s992 PRE_first_tail_x15_r0_body.s994 = true

theorem bodyGlue102 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨37295, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.S979)
      (bodyCut NB T tk π i x0 bodyΘ ⟨37295, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s994 PRE_first_tail_x15_r0_body.S994) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) bodyAcc979 PRE_first_tail_x15_r0_body.bodyRunSeg264 bodyAcc981 bodyHalt981 PRE_first_tail_x15_r0_body.bodyStepA265 bodyTop982 (fun _ hm => bodyO979 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr979).trans bodyInactive0) (bodyBr982.trans bodyBr979.symm) bodyCnt979 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) PRE_first_tail_x15_r0_body.sizeA265 PRE_first_tail_x15_r0_body.sizeArgsA265 PRE_first_tail_x15_r0_body.sizeSymA265 PRE_first_tail_x15_r0_body.sizeMlxA265 PRE_first_tail_x15_r0_body.sizePayA265 PRE_first_tail_x15_r0_body.sizeTaA265 PRE_first_tail_x15_r0_body.sizeDecA265 PRE_first_tail_x15_r0_body.sizePreA265 PRE_first_tail_x15_r0_body.bodyPatchB265 (fun _ hm => bodyO982 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr982).trans bodyInactive0) (bodyBr983.trans bodyBr982.symm) bodyCnt982 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) bodyAcc983 PRE_first_tail_x15_r0_body.bodyRunSeg265 bodyAcc984 bodyHalt984 PRE_first_tail_x15_r0_body.bodyStepA266 bodyTop985 (fun _ hm => bodyO983 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr983).trans bodyInactive0) (bodyBr985.trans bodyBr983.symm) bodyCnt983 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) PRE_first_tail_x15_r0_body.sizeA266 PRE_first_tail_x15_r0_body.sizeArgsA266 PRE_first_tail_x15_r0_body.sizeSymA266 PRE_first_tail_x15_r0_body.sizeMlxA266 PRE_first_tail_x15_r0_body.sizePayA266 PRE_first_tail_x15_r0_body.sizeTaA266 PRE_first_tail_x15_r0_body.sizeDecA266 PRE_first_tail_x15_r0_body.sizePreA266 PRE_first_tail_x15_r0_body.bodyPatchB266 (fun _ hm => bodyO985 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr985).trans bodyInactive0) (bodyBr986.trans bodyBr985.symm) bodyCnt985 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) bodyAcc986 PRE_first_tail_x15_r0_body.bodyRunSeg266 bodyAcc987 bodyHalt987 PRE_first_tail_x15_r0_body.bodyStepA267 bodyTop988 (fun _ hm => bodyO986 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr986).trans bodyInactive0) (bodyBr988.trans bodyBr986.symm) bodyCnt986 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) PRE_first_tail_x15_r0_body.sizeA267 PRE_first_tail_x15_r0_body.sizeArgsA267 PRE_first_tail_x15_r0_body.sizeSymA267 PRE_first_tail_x15_r0_body.sizeMlxA267 PRE_first_tail_x15_r0_body.sizePayA267 PRE_first_tail_x15_r0_body.sizeTaA267 PRE_first_tail_x15_r0_body.sizeDecA267 PRE_first_tail_x15_r0_body.sizePreA267 PRE_first_tail_x15_r0_body.bodyPatchB267 (fun _ hm => bodyO988 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr988).trans bodyInactive0) (bodyBr989.trans bodyBr988.symm) bodyCnt988 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) bodyAcc989 PRE_first_tail_x15_r0_body.bodyRunSeg267 bodyAcc990 bodyHalt990 PRE_first_tail_x15_r0_body.bodyStepA268 bodyTop991 (fun _ hm => bodyO989 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr989).trans bodyInactive0) (bodyBr991.trans bodyBr989.symm) bodyCnt989 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) PRE_first_tail_x15_r0_body.sizeA268 PRE_first_tail_x15_r0_body.sizeArgsA268 PRE_first_tail_x15_r0_body.sizeSymA268 PRE_first_tail_x15_r0_body.sizeMlxA268 PRE_first_tail_x15_r0_body.sizePayA268 PRE_first_tail_x15_r0_body.sizeTaA268 PRE_first_tail_x15_r0_body.sizeDecA268 PRE_first_tail_x15_r0_body.sizePreA268 PRE_first_tail_x15_r0_body.bodyPatchB268 (fun _ hm => bodyO991 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr991).trans bodyInactive0) (bodyBr992.trans bodyBr991.symm) bodyCnt991 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37295, 687, 0, 540⟩) bodyAcc992 PRE_first_tail_x15_r0_body.bodyRunSeg268 bodyAcc993 bodyHalt993 PRE_first_tail_x15_r0_body.bodyStepA269 bodyTop994 (fun _ hm => bodyO992 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr992).trans bodyInactive0) (bodyBr994.trans bodyBr992.symm) bodyCnt992 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
