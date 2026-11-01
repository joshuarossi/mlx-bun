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

kernel_rfl bodyO950 : PRE_first_tail_x15_r0_body.S950.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S950.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr950 : bridgeOf PRE_first_tail_x15_r0_body.s950.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc950 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.S950) = fun _ _ => true
kernel_rfl bodyAcc952 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s952 PRE_first_tail_x15_r0_body.S952) = fun _ _ => true
kernel_rfl bodyBr953 : bridgeOf PRE_first_tail_x15_r0_body.s953.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt952 : isHalt PRE_first_tail_x15_r0_body.s952.ctl = false
kernel_rfl bodyTop953 : noRetBlock PRE_first_tail_x15_r0_body.s953 = true
kernel_rfl bodyCnt950 : countersOkB PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.s953 = true
kernel_rfl bodyO953 : PRE_first_tail_x15_r0_body.S953.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S953.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr954 : bridgeOf PRE_first_tail_x15_r0_body.s954.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt953 : countersOkB PRE_first_tail_x15_r0_body.s953 PRE_first_tail_x15_r0_body.s954 = true
kernel_rfl bodyO954 : PRE_first_tail_x15_r0_body.S954.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S954.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc954 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s954 PRE_first_tail_x15_r0_body.S954) = fun _ _ => true
kernel_rfl bodyAcc955 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s955 PRE_first_tail_x15_r0_body.S955) = fun _ _ => true
kernel_rfl bodyBr956 : bridgeOf PRE_first_tail_x15_r0_body.s956.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt955 : isHalt PRE_first_tail_x15_r0_body.s955.ctl = false
kernel_rfl bodyTop956 : noRetBlock PRE_first_tail_x15_r0_body.s956 = true
kernel_rfl bodyCnt954 : countersOkB PRE_first_tail_x15_r0_body.s954 PRE_first_tail_x15_r0_body.s956 = true
kernel_rfl bodyO956 : PRE_first_tail_x15_r0_body.S956.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S956.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr957 : bridgeOf PRE_first_tail_x15_r0_body.s957.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt956 : countersOkB PRE_first_tail_x15_r0_body.s956 PRE_first_tail_x15_r0_body.s957 = true
kernel_rfl bodyO957 : PRE_first_tail_x15_r0_body.S957.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S957.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc957 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s957 PRE_first_tail_x15_r0_body.S957) = fun _ _ => true
kernel_rfl bodyAcc958 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s958 PRE_first_tail_x15_r0_body.S958) = fun _ _ => true
kernel_rfl bodyBr959 : bridgeOf PRE_first_tail_x15_r0_body.s959.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt958 : isHalt PRE_first_tail_x15_r0_body.s958.ctl = false
kernel_rfl bodyTop959 : noRetBlock PRE_first_tail_x15_r0_body.s959 = true
kernel_rfl bodyCnt957 : countersOkB PRE_first_tail_x15_r0_body.s957 PRE_first_tail_x15_r0_body.s959 = true
kernel_rfl bodyO959 : PRE_first_tail_x15_r0_body.S959.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S959.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr960 : bridgeOf PRE_first_tail_x15_r0_body.s960.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt959 : countersOkB PRE_first_tail_x15_r0_body.s959 PRE_first_tail_x15_r0_body.s960 = true
kernel_rfl bodyO960 : PRE_first_tail_x15_r0_body.S960.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S960.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc960 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s960 PRE_first_tail_x15_r0_body.S960) = fun _ _ => true
kernel_rfl bodyAcc961 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s961 PRE_first_tail_x15_r0_body.S961) = fun _ _ => true
kernel_rfl bodyBr962 : bridgeOf PRE_first_tail_x15_r0_body.s962.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt961 : isHalt PRE_first_tail_x15_r0_body.s961.ctl = false
kernel_rfl bodyTop962 : noRetBlock PRE_first_tail_x15_r0_body.s962 = true
kernel_rfl bodyCnt960 : countersOkB PRE_first_tail_x15_r0_body.s960 PRE_first_tail_x15_r0_body.s962 = true
kernel_rfl bodyO962 : PRE_first_tail_x15_r0_body.S962.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S962.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr963 : bridgeOf PRE_first_tail_x15_r0_body.s963.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt962 : countersOkB PRE_first_tail_x15_r0_body.s962 PRE_first_tail_x15_r0_body.s963 = true
kernel_rfl bodyO963 : PRE_first_tail_x15_r0_body.S963.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S963.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc963 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s963 PRE_first_tail_x15_r0_body.S963) = fun _ _ => true
kernel_rfl bodyAcc964 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s964 PRE_first_tail_x15_r0_body.S964) = fun _ _ => true
kernel_rfl bodyBr965 : bridgeOf PRE_first_tail_x15_r0_body.s965.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt964 : isHalt PRE_first_tail_x15_r0_body.s964.ctl = false
kernel_rfl bodyTop965 : noRetBlock PRE_first_tail_x15_r0_body.s965 = true
kernel_rfl bodyCnt963 : countersOkB PRE_first_tail_x15_r0_body.s963 PRE_first_tail_x15_r0_body.s965 = true

theorem bodyGlue99 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨36125, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.S950)
      (bodyCut NB T tk π i x0 bodyΘ ⟨36125, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s965 PRE_first_tail_x15_r0_body.S965) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) bodyAcc950 PRE_first_tail_x15_r0_body.bodyRunSeg256 bodyAcc952 bodyHalt952 PRE_first_tail_x15_r0_body.bodyStepA257 bodyTop953 (fun _ hm => bodyO950 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr950).trans bodyInactive0) (bodyBr953.trans bodyBr950.symm) bodyCnt950 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) PRE_first_tail_x15_r0_body.sizeA257 PRE_first_tail_x15_r0_body.sizeArgsA257 PRE_first_tail_x15_r0_body.sizeSymA257 PRE_first_tail_x15_r0_body.sizeMlxA257 PRE_first_tail_x15_r0_body.sizePayA257 PRE_first_tail_x15_r0_body.sizeTaA257 PRE_first_tail_x15_r0_body.sizeDecA257 PRE_first_tail_x15_r0_body.sizePreA257 PRE_first_tail_x15_r0_body.bodyPatchB257 (fun _ hm => bodyO953 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr953).trans bodyInactive0) (bodyBr954.trans bodyBr953.symm) bodyCnt953 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) bodyAcc954 PRE_first_tail_x15_r0_body.bodyRunSeg257 bodyAcc955 bodyHalt955 PRE_first_tail_x15_r0_body.bodyStepA258 bodyTop956 (fun _ hm => bodyO954 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr954).trans bodyInactive0) (bodyBr956.trans bodyBr954.symm) bodyCnt954 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) PRE_first_tail_x15_r0_body.sizeA258 PRE_first_tail_x15_r0_body.sizeArgsA258 PRE_first_tail_x15_r0_body.sizeSymA258 PRE_first_tail_x15_r0_body.sizeMlxA258 PRE_first_tail_x15_r0_body.sizePayA258 PRE_first_tail_x15_r0_body.sizeTaA258 PRE_first_tail_x15_r0_body.sizeDecA258 PRE_first_tail_x15_r0_body.sizePreA258 PRE_first_tail_x15_r0_body.bodyPatchB258 (fun _ hm => bodyO956 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr956).trans bodyInactive0) (bodyBr957.trans bodyBr956.symm) bodyCnt956 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) bodyAcc957 PRE_first_tail_x15_r0_body.bodyRunSeg258 bodyAcc958 bodyHalt958 PRE_first_tail_x15_r0_body.bodyStepA259 bodyTop959 (fun _ hm => bodyO957 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr957).trans bodyInactive0) (bodyBr959.trans bodyBr957.symm) bodyCnt957 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) PRE_first_tail_x15_r0_body.sizeA259 PRE_first_tail_x15_r0_body.sizeArgsA259 PRE_first_tail_x15_r0_body.sizeSymA259 PRE_first_tail_x15_r0_body.sizeMlxA259 PRE_first_tail_x15_r0_body.sizePayA259 PRE_first_tail_x15_r0_body.sizeTaA259 PRE_first_tail_x15_r0_body.sizeDecA259 PRE_first_tail_x15_r0_body.sizePreA259 PRE_first_tail_x15_r0_body.bodyPatchB259 (fun _ hm => bodyO959 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr959).trans bodyInactive0) (bodyBr960.trans bodyBr959.symm) bodyCnt959 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) bodyAcc960 PRE_first_tail_x15_r0_body.bodyRunSeg259 bodyAcc961 bodyHalt961 PRE_first_tail_x15_r0_body.bodyStepA260 bodyTop962 (fun _ hm => bodyO960 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr960).trans bodyInactive0) (bodyBr962.trans bodyBr960.symm) bodyCnt960 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) PRE_first_tail_x15_r0_body.sizeA260 PRE_first_tail_x15_r0_body.sizeArgsA260 PRE_first_tail_x15_r0_body.sizeSymA260 PRE_first_tail_x15_r0_body.sizeMlxA260 PRE_first_tail_x15_r0_body.sizePayA260 PRE_first_tail_x15_r0_body.sizeTaA260 PRE_first_tail_x15_r0_body.sizeDecA260 PRE_first_tail_x15_r0_body.sizePreA260 PRE_first_tail_x15_r0_body.bodyPatchB260 (fun _ hm => bodyO962 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr962).trans bodyInactive0) (bodyBr963.trans bodyBr962.symm) bodyCnt962 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36125, 662, 0, 522⟩) bodyAcc963 PRE_first_tail_x15_r0_body.bodyRunSeg260 bodyAcc964 bodyHalt964 PRE_first_tail_x15_r0_body.bodyStepA261 bodyTop965 (fun _ hm => bodyO963 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr963).trans bodyInactive0) (bodyBr965.trans bodyBr963.symm) bodyCnt963 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
