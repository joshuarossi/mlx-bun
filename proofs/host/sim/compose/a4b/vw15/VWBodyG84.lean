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

kernel_rfl bodyO806 : PRE_first_tail_x15_r0_body.S806.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S806.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr806 : bridgeOf PRE_first_tail_x15_r0_body.s806.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc806 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s806 PRE_first_tail_x15_r0_body.S806) = fun _ _ => true
kernel_rfl bodyAcc808 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s808 PRE_first_tail_x15_r0_body.S808) = fun _ _ => true
kernel_rfl bodyBr809 : bridgeOf PRE_first_tail_x15_r0_body.s809.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt808 : isHalt PRE_first_tail_x15_r0_body.s808.ctl = false
kernel_rfl bodyTop809 : noRetBlock PRE_first_tail_x15_r0_body.s809 = true
kernel_rfl bodyCnt806 : countersOkB PRE_first_tail_x15_r0_body.s806 PRE_first_tail_x15_r0_body.s809 = true
kernel_rfl bodyO809 : PRE_first_tail_x15_r0_body.S809.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S809.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr810 : bridgeOf PRE_first_tail_x15_r0_body.s810.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt809 : countersOkB PRE_first_tail_x15_r0_body.s809 PRE_first_tail_x15_r0_body.s810 = true
kernel_rfl bodyO810 : PRE_first_tail_x15_r0_body.S810.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S810.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc810 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s810 PRE_first_tail_x15_r0_body.S810) = fun _ _ => true
kernel_rfl bodyAcc811 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s811 PRE_first_tail_x15_r0_body.S811) = fun _ _ => true
kernel_rfl bodyBr812 : bridgeOf PRE_first_tail_x15_r0_body.s812.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt811 : isHalt PRE_first_tail_x15_r0_body.s811.ctl = false
kernel_rfl bodyTop812 : noRetBlock PRE_first_tail_x15_r0_body.s812 = true
kernel_rfl bodyCnt810 : countersOkB PRE_first_tail_x15_r0_body.s810 PRE_first_tail_x15_r0_body.s812 = true
kernel_rfl bodyO812 : PRE_first_tail_x15_r0_body.S812.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S812.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr813 : bridgeOf PRE_first_tail_x15_r0_body.s813.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt812 : countersOkB PRE_first_tail_x15_r0_body.s812 PRE_first_tail_x15_r0_body.s813 = true
kernel_rfl bodyO813 : PRE_first_tail_x15_r0_body.S813.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S813.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc813 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s813 PRE_first_tail_x15_r0_body.S813) = fun _ _ => true
kernel_rfl bodyAcc814 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s814 PRE_first_tail_x15_r0_body.S814) = fun _ _ => true
kernel_rfl bodyBr815 : bridgeOf PRE_first_tail_x15_r0_body.s815.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt814 : isHalt PRE_first_tail_x15_r0_body.s814.ctl = false
kernel_rfl bodyTop815 : noRetBlock PRE_first_tail_x15_r0_body.s815 = true
kernel_rfl bodyCnt813 : countersOkB PRE_first_tail_x15_r0_body.s813 PRE_first_tail_x15_r0_body.s815 = true
kernel_rfl bodyO815 : PRE_first_tail_x15_r0_body.S815.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S815.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr816 : bridgeOf PRE_first_tail_x15_r0_body.s816.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt815 : countersOkB PRE_first_tail_x15_r0_body.s815 PRE_first_tail_x15_r0_body.s816 = true
kernel_rfl bodyO816 : PRE_first_tail_x15_r0_body.S816.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S816.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc816 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s816 PRE_first_tail_x15_r0_body.S816) = fun _ _ => true
kernel_rfl bodyAcc817 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s817 PRE_first_tail_x15_r0_body.S817) = fun _ _ => true
kernel_rfl bodyBr818 : bridgeOf PRE_first_tail_x15_r0_body.s818.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt817 : isHalt PRE_first_tail_x15_r0_body.s817.ctl = false
kernel_rfl bodyTop818 : noRetBlock PRE_first_tail_x15_r0_body.s818 = true
kernel_rfl bodyCnt816 : countersOkB PRE_first_tail_x15_r0_body.s816 PRE_first_tail_x15_r0_body.s818 = true
kernel_rfl bodyO818 : PRE_first_tail_x15_r0_body.S818.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S818.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr819 : bridgeOf PRE_first_tail_x15_r0_body.s819.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt818 : countersOkB PRE_first_tail_x15_r0_body.s818 PRE_first_tail_x15_r0_body.s819 = true
kernel_rfl bodyO819 : PRE_first_tail_x15_r0_body.S819.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S819.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc819 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s819 PRE_first_tail_x15_r0_body.S819) = fun _ _ => true
kernel_rfl bodyAcc820 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s820 PRE_first_tail_x15_r0_body.S820) = fun _ _ => true
kernel_rfl bodyBr821 : bridgeOf PRE_first_tail_x15_r0_body.s821.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt820 : isHalt PRE_first_tail_x15_r0_body.s820.ctl = false
kernel_rfl bodyTop821 : noRetBlock PRE_first_tail_x15_r0_body.s821 = true
kernel_rfl bodyCnt819 : countersOkB PRE_first_tail_x15_r0_body.s819 PRE_first_tail_x15_r0_body.s821 = true

theorem bodyGlue84 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨31092, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s806 PRE_first_tail_x15_r0_body.S806)
      (bodyCut NB T tk π i x0 bodyΘ ⟨31092, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s821 PRE_first_tail_x15_r0_body.S821) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) bodyAcc806 PRE_first_tail_x15_r0_body.bodyRunSeg217 bodyAcc808 bodyHalt808 PRE_first_tail_x15_r0_body.bodyStepA218 bodyTop809 (fun _ hm => bodyO806 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr806).trans bodyInactive0) (bodyBr809.trans bodyBr806.symm) bodyCnt806 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) PRE_first_tail_x15_r0_body.sizeA218 PRE_first_tail_x15_r0_body.sizeArgsA218 PRE_first_tail_x15_r0_body.sizeSymA218 PRE_first_tail_x15_r0_body.sizeMlxA218 PRE_first_tail_x15_r0_body.sizePayA218 PRE_first_tail_x15_r0_body.sizeTaA218 PRE_first_tail_x15_r0_body.sizeDecA218 PRE_first_tail_x15_r0_body.sizePreA218 PRE_first_tail_x15_r0_body.bodyPatchB218 (fun _ hm => bodyO809 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr809).trans bodyInactive0) (bodyBr810.trans bodyBr809.symm) bodyCnt809 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) bodyAcc810 PRE_first_tail_x15_r0_body.bodyRunSeg218 bodyAcc811 bodyHalt811 PRE_first_tail_x15_r0_body.bodyStepA219 bodyTop812 (fun _ hm => bodyO810 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr810).trans bodyInactive0) (bodyBr812.trans bodyBr810.symm) bodyCnt810 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) PRE_first_tail_x15_r0_body.sizeA219 PRE_first_tail_x15_r0_body.sizeArgsA219 PRE_first_tail_x15_r0_body.sizeSymA219 PRE_first_tail_x15_r0_body.sizeMlxA219 PRE_first_tail_x15_r0_body.sizePayA219 PRE_first_tail_x15_r0_body.sizeTaA219 PRE_first_tail_x15_r0_body.sizeDecA219 PRE_first_tail_x15_r0_body.sizePreA219 PRE_first_tail_x15_r0_body.bodyPatchB219 (fun _ hm => bodyO812 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr812).trans bodyInactive0) (bodyBr813.trans bodyBr812.symm) bodyCnt812 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) bodyAcc813 PRE_first_tail_x15_r0_body.bodyRunSeg219 bodyAcc814 bodyHalt814 PRE_first_tail_x15_r0_body.bodyStepA220 bodyTop815 (fun _ hm => bodyO813 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr813).trans bodyInactive0) (bodyBr815.trans bodyBr813.symm) bodyCnt813 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) PRE_first_tail_x15_r0_body.sizeA220 PRE_first_tail_x15_r0_body.sizeArgsA220 PRE_first_tail_x15_r0_body.sizeSymA220 PRE_first_tail_x15_r0_body.sizeMlxA220 PRE_first_tail_x15_r0_body.sizePayA220 PRE_first_tail_x15_r0_body.sizeTaA220 PRE_first_tail_x15_r0_body.sizeDecA220 PRE_first_tail_x15_r0_body.sizePreA220 PRE_first_tail_x15_r0_body.bodyPatchB220 (fun _ hm => bodyO815 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr815).trans bodyInactive0) (bodyBr816.trans bodyBr815.symm) bodyCnt815 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) bodyAcc816 PRE_first_tail_x15_r0_body.bodyRunSeg220 bodyAcc817 bodyHalt817 PRE_first_tail_x15_r0_body.bodyStepA221 bodyTop818 (fun _ hm => bodyO816 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr816).trans bodyInactive0) (bodyBr818.trans bodyBr816.symm) bodyCnt816 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) PRE_first_tail_x15_r0_body.sizeA221 PRE_first_tail_x15_r0_body.sizeArgsA221 PRE_first_tail_x15_r0_body.sizeSymA221 PRE_first_tail_x15_r0_body.sizeMlxA221 PRE_first_tail_x15_r0_body.sizePayA221 PRE_first_tail_x15_r0_body.sizeTaA221 PRE_first_tail_x15_r0_body.sizeDecA221 PRE_first_tail_x15_r0_body.sizePreA221 PRE_first_tail_x15_r0_body.bodyPatchB221 (fun _ hm => bodyO818 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr818).trans bodyInactive0) (bodyBr819.trans bodyBr818.symm) bodyCnt818 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31092, 560, 0, 441⟩) bodyAcc819 PRE_first_tail_x15_r0_body.bodyRunSeg221 bodyAcc820 bodyHalt820 PRE_first_tail_x15_r0_body.bodyStepA222 bodyTop821 (fun _ hm => bodyO819 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr819).trans bodyInactive0) (bodyBr821.trans bodyBr819.symm) bodyCnt819 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
