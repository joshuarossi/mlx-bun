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

kernel_rfl bodyO708 : PRE_first_tail_x15_r0_body.S708.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S708.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr708 : bridgeOf PRE_first_tail_x15_r0_body.s708.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc708 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.S708) = fun _ _ => true
kernel_rfl bodyAcc709 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s709 PRE_first_tail_x15_r0_body.S709) = fun _ _ => true
kernel_rfl bodyBr710 : bridgeOf PRE_first_tail_x15_r0_body.s710.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt709 : isHalt PRE_first_tail_x15_r0_body.s709.ctl = false
kernel_rfl bodyTop710 : noRetBlock PRE_first_tail_x15_r0_body.s710 = true
kernel_rfl bodyCnt708 : countersOkB PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.s710 = true
kernel_rfl bodyO710 : PRE_first_tail_x15_r0_body.S710.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S710.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr711 : bridgeOf PRE_first_tail_x15_r0_body.s711.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt710 : countersOkB PRE_first_tail_x15_r0_body.s710 PRE_first_tail_x15_r0_body.s711 = true
kernel_rfl bodyO711 : PRE_first_tail_x15_r0_body.S711.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S711.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc711 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s711 PRE_first_tail_x15_r0_body.S711) = fun _ _ => true
kernel_rfl bodyAcc713 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s713 PRE_first_tail_x15_r0_body.S713) = fun _ _ => true
kernel_rfl bodyBr714 : bridgeOf PRE_first_tail_x15_r0_body.s714.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt713 : isHalt PRE_first_tail_x15_r0_body.s713.ctl = false
kernel_rfl bodyTop714 : noRetBlock PRE_first_tail_x15_r0_body.s714 = true
kernel_rfl bodyCnt711 : countersOkB PRE_first_tail_x15_r0_body.s711 PRE_first_tail_x15_r0_body.s714 = true

theorem bodyGlue73 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨28396, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.S708)
      (bodyCut NB T tk π i x0 bodyΘ ⟨28396, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s714 PRE_first_tail_x15_r0_body.S714) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28396, 508, 0, 396⟩) bodyAcc708 PRE_first_tail_x15_r0_body.bodyRunSeg191 bodyAcc709 bodyHalt709 PRE_first_tail_x15_r0_body.bodyStepA192 bodyTop710 (fun _ hm => bodyO708 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr708).trans bodyInactive0) (bodyBr710.trans bodyBr708.symm) bodyCnt708 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28396, 508, 0, 396⟩) PRE_first_tail_x15_r0_body.sizeA192 PRE_first_tail_x15_r0_body.sizeArgsA192 PRE_first_tail_x15_r0_body.sizeSymA192 PRE_first_tail_x15_r0_body.sizeMlxA192 PRE_first_tail_x15_r0_body.sizePayA192 PRE_first_tail_x15_r0_body.sizeTaA192 PRE_first_tail_x15_r0_body.sizeDecA192 PRE_first_tail_x15_r0_body.sizePreA192 PRE_first_tail_x15_r0_body.bodyPatchB192 (fun _ hm => bodyO710 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr710).trans bodyInactive0) (bodyBr711.trans bodyBr710.symm) bodyCnt710 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28396, 508, 0, 396⟩) bodyAcc711 PRE_first_tail_x15_r0_body.bodyRunSeg192 bodyAcc713 bodyHalt713 PRE_first_tail_x15_r0_body.bodyStepA193 bodyTop714 (fun _ hm => bodyO711 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr711).trans bodyInactive0) (bodyBr714.trans bodyBr711.symm) bodyCnt711 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
