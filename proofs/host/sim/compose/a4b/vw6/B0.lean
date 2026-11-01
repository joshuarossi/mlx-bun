import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x6_r0_body.States
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B16
import host.sim.compose.a4b.vw6.VWBodyChain
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B34
import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw6.VWBodyMap
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B14
import host.sim.template.CallGen

section -- VWBodyOracles_0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_g0 : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g0 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g0) (List.take 13 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site0 : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site0 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st0.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g1 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g1) (List.take 8 (List.drop 13 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site1 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site1) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st1.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g2 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g2 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g2) (List.take 3 (List.drop 21 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

noncomputable def PRE_first_tail_x6_r0_body.map_site2 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site2 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site2) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g3 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g3 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g3) (List.take 16 (List.drop 24 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site3 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site3 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site3) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st3.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site0 : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site0 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st0.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site0
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s15 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s16 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S15 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws0 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st0.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st0.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso0
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st0.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot0
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup0
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound0
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace0
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged0
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws0.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st0.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S15.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_0]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen0.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl0 : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl0 PRE_first_tail_x6_r0_body.ncl0

theorem bodyClean0 : Conv.JClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s15 :=
  PRE_first_tail_x6_r0_body.gjcl0 bodyStartClean

kernel_rfl bodyJsLe0 : Nat.ble 2673488 PRE_first_tail_x6_r0_body.s15.next = true
kernel_rfl bodyJsList0 : (PRE_first_tail_x6_r0_body.gjh0 ++ PRE_first_tail_x6_r0_body.cl0).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s15.next) PRE_first_tail_x6_r0_body.s17) = true
theorem bodyJs0 : JsHeapAbove PRE_first_tail_x6_r0_body.s15.next PRE_first_tail_x6_r0_body.s17 :=
  JsHeapAbove.glueSite bodyStartJs (Nat.le_of_ble_eq_true bodyJsLe0) PRE_first_tail_x6_r0_body.gjk0 PRE_first_tail_x6_r0_body.gjbd0 PRE_first_tail_x6_r0_body.cheap0 PRE_first_tail_x6_r0_body.zclbd0 bodyJsList0

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO0 : PRE_first_tail_x6_r0_body.S0.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S0.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr0 : bridgeOf PRE_first_tail_x6_r0_body.s0.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc0 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S0) = fun _ _ => true
kernel_rfl bodyAcc1 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s1 PRE_first_tail_x6_r0_body.S1) = fun _ _ => true
kernel_rfl bodyBr2 : bridgeOf PRE_first_tail_x6_r0_body.s2.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt1 : isHalt PRE_first_tail_x6_r0_body.s1.ctl = false
kernel_rfl bodyTop2 : noRetBlock PRE_first_tail_x6_r0_body.s2 = true
kernel_rfl bodyCnt0 : countersOkB PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.s2 = true
kernel_rfl bodyO2 : PRE_first_tail_x6_r0_body.S2.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S2.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr3 : bridgeOf PRE_first_tail_x6_r0_body.s3.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt2 : countersOkB PRE_first_tail_x6_r0_body.s2 PRE_first_tail_x6_r0_body.s3 = true
kernel_rfl bodyO3 : PRE_first_tail_x6_r0_body.S3.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S3.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc3 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s3 PRE_first_tail_x6_r0_body.S3) = fun _ _ => true
kernel_rfl bodyAcc5 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s5 PRE_first_tail_x6_r0_body.S5) = fun _ _ => true
kernel_rfl bodyBr6 : bridgeOf PRE_first_tail_x6_r0_body.s6.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt5 : isHalt PRE_first_tail_x6_r0_body.s5.ctl = false
kernel_rfl bodyTop6 : noRetBlock PRE_first_tail_x6_r0_body.s6 = true
kernel_rfl bodyCnt3 : countersOkB PRE_first_tail_x6_r0_body.s3 PRE_first_tail_x6_r0_body.s6 = true
kernel_rfl bodyO6 : PRE_first_tail_x6_r0_body.S6.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S6.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr7 : bridgeOf PRE_first_tail_x6_r0_body.s7.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt6 : countersOkB PRE_first_tail_x6_r0_body.s6 PRE_first_tail_x6_r0_body.s7 = true
kernel_rfl bodyO7 : PRE_first_tail_x6_r0_body.S7.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S7.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc7 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s7 PRE_first_tail_x6_r0_body.S7) = fun _ _ => true
kernel_rfl bodyAcc8 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s8 PRE_first_tail_x6_r0_body.S8) = fun _ _ => true
kernel_rfl bodyBr9 : bridgeOf PRE_first_tail_x6_r0_body.s9.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt8 : isHalt PRE_first_tail_x6_r0_body.s8.ctl = false
kernel_rfl bodyTop9 : noRetBlock PRE_first_tail_x6_r0_body.s9 = true
kernel_rfl bodyCnt7 : countersOkB PRE_first_tail_x6_r0_body.s7 PRE_first_tail_x6_r0_body.s9 = true
kernel_rfl bodyO9 : PRE_first_tail_x6_r0_body.S9.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S9.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr10 : bridgeOf PRE_first_tail_x6_r0_body.s10.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt9 : countersOkB PRE_first_tail_x6_r0_body.s9 PRE_first_tail_x6_r0_body.s10 = true
kernel_rfl bodyO10 : PRE_first_tail_x6_r0_body.S10.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S10.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc10 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s10 PRE_first_tail_x6_r0_body.S10) = fun _ _ => true
kernel_rfl bodyAcc11 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s11 PRE_first_tail_x6_r0_body.S11) = fun _ _ => true
kernel_rfl bodyBr12 : bridgeOf PRE_first_tail_x6_r0_body.s12.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt11 : isHalt PRE_first_tail_x6_r0_body.s11.ctl = false
kernel_rfl bodyTop12 : noRetBlock PRE_first_tail_x6_r0_body.s12 = true
kernel_rfl bodyCnt10 : countersOkB PRE_first_tail_x6_r0_body.s10 PRE_first_tail_x6_r0_body.s12 = true
kernel_rfl bodyO12 : PRE_first_tail_x6_r0_body.S12.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S12.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr13 : bridgeOf PRE_first_tail_x6_r0_body.s13.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt12 : countersOkB PRE_first_tail_x6_r0_body.s12 PRE_first_tail_x6_r0_body.s13 = true
kernel_rfl bodyO13 : PRE_first_tail_x6_r0_body.S13.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S13.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc13 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s13 PRE_first_tail_x6_r0_body.S13) = fun _ _ => true
kernel_rfl bodyAcc14 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s14 PRE_first_tail_x6_r0_body.S14) = fun _ _ => true
kernel_rfl bodyBr15 : bridgeOf PRE_first_tail_x6_r0_body.s15.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt14 : isHalt PRE_first_tail_x6_r0_body.s14.ctl = false
kernel_rfl bodyTop15 : noRetBlock PRE_first_tail_x6_r0_body.s15 = true
kernel_rfl bodyCnt13 : countersOkB PRE_first_tail_x6_r0_body.s13 PRE_first_tail_x6_r0_body.s15 = true

theorem bodyGlue0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S0)
      (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x6_r0_body.s15 PRE_first_tail_x6_r0_body.S15) 13512 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc0 PRE_first_tail_x6_r0_body.bodyRunSeg0 bodyAcc1 bodyHalt1 PRE_first_tail_x6_r0_body.bodyStepA1 bodyTop2 (fun _ hm => bodyO0 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr0).trans bodyInactive0) (bodyBr2.trans bodyBr0.symm) bodyCnt0 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x6_r0_body.sizeA1 PRE_first_tail_x6_r0_body.sizeArgsA1 PRE_first_tail_x6_r0_body.sizeSymA1 PRE_first_tail_x6_r0_body.sizeMlxA1 PRE_first_tail_x6_r0_body.sizePayA1 PRE_first_tail_x6_r0_body.sizeTaA1 PRE_first_tail_x6_r0_body.sizeDecA1 PRE_first_tail_x6_r0_body.sizePreA1 PRE_first_tail_x6_r0_body.bodyPatchB1 (fun _ hm => bodyO2 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr2).trans bodyInactive0) (bodyBr3.trans bodyBr2.symm) bodyCnt2 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc3 PRE_first_tail_x6_r0_body.bodyRunSeg1 bodyAcc5 bodyHalt5 PRE_first_tail_x6_r0_body.bodyStepA2 bodyTop6 (fun _ hm => bodyO3 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr3).trans bodyInactive0) (bodyBr6.trans bodyBr3.symm) bodyCnt3 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x6_r0_body.sizeA2 PRE_first_tail_x6_r0_body.sizeArgsA2 PRE_first_tail_x6_r0_body.sizeSymA2 PRE_first_tail_x6_r0_body.sizeMlxA2 PRE_first_tail_x6_r0_body.sizePayA2 PRE_first_tail_x6_r0_body.sizeTaA2 PRE_first_tail_x6_r0_body.sizeDecA2 PRE_first_tail_x6_r0_body.sizePreA2 PRE_first_tail_x6_r0_body.bodyPatchB2 (fun _ hm => bodyO6 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr6).trans bodyInactive0) (bodyBr7.trans bodyBr6.symm) bodyCnt6 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc7 PRE_first_tail_x6_r0_body.bodyRunSeg2 bodyAcc8 bodyHalt8 PRE_first_tail_x6_r0_body.bodyStepA3 bodyTop9 (fun _ hm => bodyO7 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr7).trans bodyInactive0) (bodyBr9.trans bodyBr7.symm) bodyCnt7 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x6_r0_body.sizeA3 PRE_first_tail_x6_r0_body.sizeArgsA3 PRE_first_tail_x6_r0_body.sizeSymA3 PRE_first_tail_x6_r0_body.sizeMlxA3 PRE_first_tail_x6_r0_body.sizePayA3 PRE_first_tail_x6_r0_body.sizeTaA3 PRE_first_tail_x6_r0_body.sizeDecA3 PRE_first_tail_x6_r0_body.sizePreA3 PRE_first_tail_x6_r0_body.bodyPatchB3 (fun _ hm => bodyO9 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr9).trans bodyInactive0) (bodyBr10.trans bodyBr9.symm) bodyCnt9 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc10 PRE_first_tail_x6_r0_body.bodyRunSeg3 bodyAcc11 bodyHalt11 PRE_first_tail_x6_r0_body.bodyStepA4 bodyTop12 (fun _ hm => bodyO10 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr10).trans bodyInactive0) (bodyBr12.trans bodyBr10.symm) bodyCnt10 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x6_r0_body.sizeA4 PRE_first_tail_x6_r0_body.sizeArgsA4 PRE_first_tail_x6_r0_body.sizeSymA4 PRE_first_tail_x6_r0_body.sizeMlxA4 PRE_first_tail_x6_r0_body.sizePayA4 PRE_first_tail_x6_r0_body.sizeTaA4 PRE_first_tail_x6_r0_body.sizeDecA4 PRE_first_tail_x6_r0_body.sizePreA4 PRE_first_tail_x6_r0_body.bodyPatchB4 (fun _ hm => bodyO12 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr12).trans bodyInactive0) (bodyBr13.trans bodyBr12.symm) bodyCnt12 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc13 PRE_first_tail_x6_r0_body.bodyRunSeg4 bodyAcc14 bodyHalt14 PRE_first_tail_x6_r0_body.bodyStepA5 bodyTop15 (fun _ hm => bodyO13 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr13).trans bodyInactive0) (bodyBr15.trans bodyBr13.symm) bodyCnt13 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift0 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S15.tab.length PRE_first_tail_x6_r0_body.s15.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P0.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P0 101 PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.s17.ffi PRE_first_tail_x6_r0_body.s16.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_0
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_0
  have hcl : SSt (· < 101) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S15.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_0] <;> decide) PRE_first_tail_x6_r0_body.cnodesK0 PRE_first_tail_x6_r0_body.cobjsK0
      PRE_first_tail_x6_r0_body.citemsK0 PRE_first_tail_x6_r0_body.cbd0 PRE_first_tail_x6_r0_body.csst0
  exact PRE_first_tail_x6_r0_body.cshift0 bodyNcl0 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_0] at this; exact this)


kernel_rfl bodyFramesEmpty0 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s16 a).isEmpty) = true
kernel_rfl bodyJsRoots0 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s15.next) PRE_first_tail_x6_r0_body.s17.trace PRE_first_tail_x6_r0_body.s17 = true
kernel_rfl bodyJsNative0 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s17.ffi) = true
kernel_rfl bodyLow0 : (PRE_first_tail_x6_r0_body.cws0 ++ PRE_first_tail_x6_r0_body.ws0).all (Nat.ble 9) = true
kernel_rfl bodyCntM0 : countersOkB PRE_first_tail_x6_r0_body.s15 PRE_first_tail_x6_r0_body.s16 = true
kernel_rfl bodyHi0 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s17.ffi).next setupP.E = true
kernel_rfl bodyNhi0 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s17.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge0 : bridgeOf PRE_first_tail_x6_r0_body.s16.ffi = bridgeOf PRE_first_tail_x6_r0_body.s15.ffi
kernel_rfl bodyNN0 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s15.ffi).nnext PRE_first_tail_x6_r0_body.P0.NL = true
kernel_rfl bodyXn0 : Nat.ble (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s17.ffi).next = true
kernel_rfl bodyLo0 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s17.ffi).next = true
theorem bodyFacts0 : BodySiteFacts PRE_first_tail_x6_r0_body.s15 PRE_first_tail_x6_r0_body.s16 PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S15 PRE_first_tail_x6_r0_body.S16 PRE_first_tail_x6_r0_body.S17
    PRE_first_tail_x6_r0_body.ws0 PRE_first_tail_x6_r0_body.cws0 PRE_first_tail_x6_r0_body.nr0 PRE_first_tail_x6_r0_body.pl0 PRE_first_tail_x6_r0_body.cl0 2676612 101 PRE_first_tail_x6_r0_body.kd0 PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.P0
    ⟨18189, 15254, 2674897, 83⟩ ⟨18197, 15296, 2674920, 101⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap0
  clean := bodyClean0
  cfix := PRE_first_tail_x6_r0_body.cfix0
  zpl := PRE_first_tail_x6_r0_body.zpl0
  zplnd := PRE_first_tail_x6_r0_body.zplnd0
  zn1 := PRE_first_tail_x6_r0_body.zn10
  zfirst := PRE_first_tail_x6_r0_body.zfirst0
  zscn := PRE_first_tail_x6_r0_body.zscn0
  zsmn := PRE_first_tail_x6_r0_body.zsmn0
  zgrow := PRE_first_tail_x6_r0_body.zgrow0
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab0
  zfresh := PRE_first_tail_x6_r0_body.zfresh0
  zcnd := PRE_first_tail_x6_r0_body.zcnd0
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi0
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt0
  zgP := PRE_first_tail_x6_r0_body.zg0_2665
  zkP := PRE_first_tail_x6_r0_body.zk0_2665
  zmP := PRE_first_tail_x6_r0_body.zm0_2665
  zgC := PRE_first_tail_x6_r0_body.zg0_2673467
  zkC := PRE_first_tail_x6_r0_body.zk0_2673467
  zmC := PRE_first_tail_x6_r0_body.zm0_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw0_2673472
  zwV := PRE_first_tail_x6_r0_body.zw0_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap0
  zclbd := PRE_first_tail_x6_r0_body.zclbd0
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap0 PRE_first_tail_x6_r0_body.stFoot0 PRE_first_tail_x6_r0_body.iso0 PRE_first_tail_x6_r0_body.zwr0
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP0
  csupp := PRE_first_tail_x6_r0_body.csupp0
  cbound := PRE_first_tail_x6_r0_body.cbound0
  zimg := PRE_first_tail_x6_r0_body.zimg0
  zctl := PRE_first_tail_x6_r0_body.zctl0
  zstack := PRE_first_tail_x6_r0_body.zstack0
  zjobs := PRE_first_tail_x6_r0_body.zjobs0
  zstores := PRE_first_tail_x6_r0_body.zstores0
  zroots := PRE_first_tail_x6_r0_body.zroots0
  znC := PRE_first_tail_x6_r0_body.znC0
  ctab := PRE_first_tail_x6_r0_body.ctab0
  zbin := PRE_first_tail_x6_r0_body.zbin0
  cbridge := PRE_first_tail_x6_r0_body.cbridge0
  sbridge := bodyBridge0
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj0
  cshiftR := fun h hNL => bodyCshift0 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN0
  raised := PRE_first_tail_x6_r0_body.raised0
  cbigs := PRE_first_tail_x6_r0_body.cbigs0
  cjcl := PRE_first_tail_x6_r0_body.cjcl0
  xnLe := Nat.le_of_ble_eq_true bodyXn0
  loLe := Nat.le_of_ble_eq_true bodyLo0
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB0
  cntM := bodyCntM0
  hiLe := Nat.le_of_ble_eq_true bodyHi0
  nhiLe := Nat.le_of_ble_eq_true bodyNhi0
  jsHeap := bodyJs0
  jsRoots := bodyJsRoots0
  jsNative := bodyJsNative0
  framesEmpty := bodyFramesEmpty0
  trailOld := by decide
  lowVars := bodyLow0

def bodyQs0 : List (Option Q) := [some Q.n, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs0 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr0.map fun r => nth? PRE_first_tail_x6_r0_body.st0.S7.tab r
kernel_rfl bodyResChk0 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs0 bodyQs0) = true
kernel_rfl bodyLq0 : bodyQs0.length = PRE_first_tail_x6_r0_body.cws0.length
kernel_rfl bodyNrLo0 : PRE_first_tail_x6_r0_body.nr0.all (Nat.ble PRE_first_tail_x6_r0_body.S15.tab.length) = true
kernel_rfl bodySub0 : (Oracles.PRE_first_tail_x6_r0_body.map_site0.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost0 : postSubB bodyM PRE_first_tail_x6_r0_body.ws0 PRE_first_tail_x6_r0_body.cws0 bodyQs0 = true
kernel_rfl bodyDrop0 : Nat.ble (3571 + (PRE_first_tail_x6_r0_body.s16.next - PRE_first_tail_x6_r0_body.s17.next)) 5263 = true
kernel_rfl bodyDropH0 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s16.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s17.ffi).next)) 46 = true
kernel_rfl bodyDropN0 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s16.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s17.ffi).nnext)) 0 = true
kernel_rfl bodyDv0 : bodyΘ.1.take 18 = bodyΘ.1.take 0 ++ PRE_first_tail_x6_r0_body.cws0
kernel_rfl bodyDe0 : bodyΘ.2.take 18 = bodyΘ.2.take 0 ++ PRE_first_tail_x6_r0_body.nr0.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st0.S7.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl0 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold0 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws0).isNone && !PRE_first_tail_x6_r0_body.ws0.contains v) = true
kernel_rfl bodyDfree0 : (bodyΘ.2.take 18).all (fun e => (PRE_first_tail_x6_r0_body.cws0 ++ PRE_first_tail_x6_r0_body.ws0).all fun w => e.noVar w) = true

theorem bodyStep0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x6_r0_body.s15 PRE_first_tail_x6_r0_body.S15)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.S17) (17040 + 1) :=
  bodySite bodyFacts0.cfix bodyFacts0.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 17040) (S2 := PRE_first_tail_x6_r0_body.st0.S7.tab) (Es := bodyEs0) (qs := bodyQs0)
    (ok := PRE_first_tail_x6_r0_body.st0.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site0 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts0
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site0 r hr) hi (MapOk.sub hm (sub_of_all bodySub0)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk0 r hr) hi hm ho hq)
    bodyLq0 rfl bodyNrLo0 (postSub_sound bodyPost0)
    (Nat.le_of_ble_eq_true bodyDrop0) (by decide) (Nat.le_of_ble_eq_true bodyDropH0) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN0) (by decide)
    bodyDv0 bodyDe0 bodyDl0 bodyDold0 bodyDfree0 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site1 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site1) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st1.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site1
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s24 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s25 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S24 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws1 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st1.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st1.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso1
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_1
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st1.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot1
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup1
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound1
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace1
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged1
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws1.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st1.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S24.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_1]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen1.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl1 : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl1 (PRE_first_tail_x6_r0_body.cncl0 bodyNcl0)

theorem bodyClean1 : Conv.JClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s24 :=
  PRE_first_tail_x6_r0_body.gjcl1 (PRE_first_tail_x6_r0_body.cjcl0 bodyClean0)

kernel_rfl bodyJsLe1 : Nat.ble PRE_first_tail_x6_r0_body.s15.next PRE_first_tail_x6_r0_body.s24.next = true
kernel_rfl bodyJsList1 : (PRE_first_tail_x6_r0_body.gjh1 ++ PRE_first_tail_x6_r0_body.cl1).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s24.next) PRE_first_tail_x6_r0_body.s26) = true
theorem bodyJs1 : JsHeapAbove PRE_first_tail_x6_r0_body.s24.next PRE_first_tail_x6_r0_body.s26 :=
  JsHeapAbove.glueSite bodyJs0 (Nat.le_of_ble_eq_true bodyJsLe1) PRE_first_tail_x6_r0_body.gjk1 PRE_first_tail_x6_r0_body.gjbd1 PRE_first_tail_x6_r0_body.cheap1 PRE_first_tail_x6_r0_body.zclbd1 bodyJsList1

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO17 : PRE_first_tail_x6_r0_body.S17.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S17.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr17 : bridgeOf PRE_first_tail_x6_r0_body.s17.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc17 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.S17) = fun _ _ => true
kernel_rfl bodyAcc19 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s19 PRE_first_tail_x6_r0_body.S19) = fun _ _ => true
kernel_rfl bodyBr20 : bridgeOf PRE_first_tail_x6_r0_body.s20.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt19 : isHalt PRE_first_tail_x6_r0_body.s19.ctl = false
kernel_rfl bodyTop20 : noRetBlock PRE_first_tail_x6_r0_body.s20 = true
kernel_rfl bodyCnt17 : countersOkB PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.s20 = true
kernel_rfl bodyO20 : PRE_first_tail_x6_r0_body.S20.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S20.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr21 : bridgeOf PRE_first_tail_x6_r0_body.s21.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt20 : countersOkB PRE_first_tail_x6_r0_body.s20 PRE_first_tail_x6_r0_body.s21 = true
kernel_rfl bodyO21 : PRE_first_tail_x6_r0_body.S21.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S21.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc21 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s21 PRE_first_tail_x6_r0_body.S21) = fun _ _ => true
kernel_rfl bodyAcc23 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s23 PRE_first_tail_x6_r0_body.S23) = fun _ _ => true
kernel_rfl bodyBr24 : bridgeOf PRE_first_tail_x6_r0_body.s24.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt23 : isHalt PRE_first_tail_x6_r0_body.s23.ctl = false
kernel_rfl bodyTop24 : noRetBlock PRE_first_tail_x6_r0_body.s24 = true
kernel_rfl bodyCnt21 : countersOkB PRE_first_tail_x6_r0_body.s21 PRE_first_tail_x6_r0_body.s24 = true

theorem bodyGlue1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.S17)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s24 PRE_first_tail_x6_r0_body.S24) 8541 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc17 PRE_first_tail_x6_r0_body.bodyRunSeg5 bodyAcc19 bodyHalt19 PRE_first_tail_x6_r0_body.bodyStepA6 bodyTop20 (fun _ hm => bodyO17 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr17).trans bodyInactive0) (bodyBr20.trans bodyBr17.symm) bodyCnt17 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) PRE_first_tail_x6_r0_body.sizeA6 PRE_first_tail_x6_r0_body.sizeArgsA6 PRE_first_tail_x6_r0_body.sizeSymA6 PRE_first_tail_x6_r0_body.sizeMlxA6 PRE_first_tail_x6_r0_body.sizePayA6 PRE_first_tail_x6_r0_body.sizeTaA6 PRE_first_tail_x6_r0_body.sizeDecA6 PRE_first_tail_x6_r0_body.sizePreA6 PRE_first_tail_x6_r0_body.bodyPatchB6 (fun _ hm => bodyO20 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr20).trans bodyInactive0) (bodyBr21.trans bodyBr20.symm) bodyCnt20 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5263, 46, 0, 18⟩) bodyAcc21 PRE_first_tail_x6_r0_body.bodyRunSeg6 bodyAcc23 bodyHalt23 PRE_first_tail_x6_r0_body.bodyStepA7 bodyTop24 (fun _ hm => bodyO21 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr21).trans bodyInactive0) (bodyBr24.trans bodyBr21.symm) bodyCnt21 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift1 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S24.tab.length PRE_first_tail_x6_r0_body.s24.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P1.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P1 122 PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.s26.ffi PRE_first_tail_x6_r0_body.s25.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_1
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_1
  have hcl : SSt (· < 122) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S24.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_1] <;> decide) PRE_first_tail_x6_r0_body.cnodesK1 PRE_first_tail_x6_r0_body.cobjsK1
      PRE_first_tail_x6_r0_body.citemsK1 PRE_first_tail_x6_r0_body.cbd1 PRE_first_tail_x6_r0_body.csst1
  exact PRE_first_tail_x6_r0_body.cshift1 bodyNcl1 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_1] at this; exact this)


kernel_rfl bodyFramesEmpty1 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s25 a).isEmpty) = true
kernel_rfl bodyJsRoots1 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s24.next) PRE_first_tail_x6_r0_body.s26.trace PRE_first_tail_x6_r0_body.s26 = true
kernel_rfl bodyJsNative1 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s26.ffi) = true
kernel_rfl bodyLow1 : (PRE_first_tail_x6_r0_body.cws1 ++ PRE_first_tail_x6_r0_body.ws1).all (Nat.ble 9) = true
kernel_rfl bodyCntM1 : countersOkB PRE_first_tail_x6_r0_body.s24 PRE_first_tail_x6_r0_body.s25 = true
kernel_rfl bodyHi1 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s26.ffi).next setupP.E = true
kernel_rfl bodyNhi1 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s26.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge1 : bridgeOf PRE_first_tail_x6_r0_body.s25.ffi = bridgeOf PRE_first_tail_x6_r0_body.s24.ffi
kernel_rfl bodyNN1 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s24.ffi).nnext PRE_first_tail_x6_r0_body.P1.NL = true
kernel_rfl bodyXn1 : Nat.ble (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s26.ffi).next = true
kernel_rfl bodyLo1 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s26.ffi).next = true
theorem bodyFacts1 : BodySiteFacts PRE_first_tail_x6_r0_body.s24 PRE_first_tail_x6_r0_body.s25 PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S24 PRE_first_tail_x6_r0_body.S25 PRE_first_tail_x6_r0_body.S26
    PRE_first_tail_x6_r0_body.ws1 PRE_first_tail_x6_r0_body.cws1 PRE_first_tail_x6_r0_body.nr1 PRE_first_tail_x6_r0_body.pl1 PRE_first_tail_x6_r0_body.cl1 2675767 122 PRE_first_tail_x6_r0_body.kd1 PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.P1
    ⟨18226, 15318, 2675765, 122⟩ ⟨18226, 15318, 2675765, 122⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap1
  clean := bodyClean1
  cfix := PRE_first_tail_x6_r0_body.cfix1
  zpl := PRE_first_tail_x6_r0_body.zpl1
  zplnd := PRE_first_tail_x6_r0_body.zplnd1
  zn1 := PRE_first_tail_x6_r0_body.zn11
  zfirst := PRE_first_tail_x6_r0_body.zfirst1
  zscn := PRE_first_tail_x6_r0_body.zscn1
  zsmn := PRE_first_tail_x6_r0_body.zsmn1
  zgrow := PRE_first_tail_x6_r0_body.zgrow1
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab1
  zfresh := PRE_first_tail_x6_r0_body.zfresh1
  zcnd := PRE_first_tail_x6_r0_body.zcnd1
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi1
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt1
  zgP := PRE_first_tail_x6_r0_body.zg1_2665
  zkP := PRE_first_tail_x6_r0_body.zk1_2665
  zmP := PRE_first_tail_x6_r0_body.zm1_2665
  zgC := PRE_first_tail_x6_r0_body.zg1_2673467
  zkC := PRE_first_tail_x6_r0_body.zk1_2673467
  zmC := PRE_first_tail_x6_r0_body.zm1_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw1_2673472
  zwV := PRE_first_tail_x6_r0_body.zw1_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap1
  zclbd := PRE_first_tail_x6_r0_body.zclbd1
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap1 PRE_first_tail_x6_r0_body.stFoot1 PRE_first_tail_x6_r0_body.iso1 PRE_first_tail_x6_r0_body.zwr1
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP1
  csupp := PRE_first_tail_x6_r0_body.csupp1
  cbound := PRE_first_tail_x6_r0_body.cbound1
  zimg := PRE_first_tail_x6_r0_body.zimg1
  zctl := PRE_first_tail_x6_r0_body.zctl1
  zstack := PRE_first_tail_x6_r0_body.zstack1
  zjobs := PRE_first_tail_x6_r0_body.zjobs1
  zstores := PRE_first_tail_x6_r0_body.zstores1
  zroots := PRE_first_tail_x6_r0_body.zroots1
  znC := PRE_first_tail_x6_r0_body.znC1
  ctab := PRE_first_tail_x6_r0_body.ctab1
  zbin := PRE_first_tail_x6_r0_body.zbin1
  cbridge := PRE_first_tail_x6_r0_body.cbridge1
  sbridge := bodyBridge1
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj1
  cshiftR := fun h hNL => bodyCshift1 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN1
  raised := PRE_first_tail_x6_r0_body.raised1
  cbigs := PRE_first_tail_x6_r0_body.cbigs1
  cjcl := PRE_first_tail_x6_r0_body.cjcl1
  xnLe := Nat.le_of_ble_eq_true bodyXn1
  loLe := Nat.le_of_ble_eq_true bodyLo1
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB1
  cntM := bodyCntM1
  hiLe := Nat.le_of_ble_eq_true bodyHi1
  nhiLe := Nat.le_of_ble_eq_true bodyNhi1
  jsHeap := bodyJs1
  jsRoots := bodyJsRoots1
  jsNative := bodyJsNative1
  framesEmpty := bodyFramesEmpty1
  trailOld := by decide
  lowVars := bodyLow1

def bodyQs1 : List (Option Q) := []
noncomputable def bodyEs1 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr1.map fun r => nth? PRE_first_tail_x6_r0_body.st1.S2.tab r
kernel_rfl bodyResChk1 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs1 bodyQs1) = true
kernel_rfl bodyLq1 : bodyQs1.length = PRE_first_tail_x6_r0_body.cws1.length
kernel_rfl bodyNrLo1 : PRE_first_tail_x6_r0_body.nr1.all (Nat.ble PRE_first_tail_x6_r0_body.S24.tab.length) = true
kernel_rfl bodySub1 : (Oracles.PRE_first_tail_x6_r0_body.map_site1.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost1 : postSubB bodyM PRE_first_tail_x6_r0_body.ws1 PRE_first_tail_x6_r0_body.cws1 bodyQs1 = true
kernel_rfl bodyDrop1 : Nat.ble (5263 + (PRE_first_tail_x6_r0_body.s25.next - PRE_first_tail_x6_r0_body.s26.next)) 5265 = true
kernel_rfl bodyDropH1 : Nat.ble (46 + ((mlxOf PRE_first_tail_x6_r0_body.s25.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s26.ffi).next)) 46 = true
kernel_rfl bodyDropN1 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s25.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s26.ffi).nnext)) 0 = true
kernel_rfl bodyDv1 : bodyΘ.1.take 18 = bodyΘ.1.take 18 ++ PRE_first_tail_x6_r0_body.cws1
kernel_rfl bodyDe1 : bodyΘ.2.take 18 = bodyΘ.2.take 18 ++ PRE_first_tail_x6_r0_body.nr1.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st1.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 18) (bodyΘ.2.take 18)))
kernel_rfl bodyDl1 : (bodyΘ.1.take 18).length = (bodyΘ.2.take 18).length
kernel_rfl bodyDold1 : (bodyΘ.1.take 18).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws1).isNone && !PRE_first_tail_x6_r0_body.ws1.contains v) = true
kernel_rfl bodyDfree1 : (bodyΘ.2.take 18).all (fun e => (PRE_first_tail_x6_r0_body.cws1 ++ PRE_first_tail_x6_r0_body.ws1).all fun w => e.noVar w) = true

theorem bodyStep1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s24 PRE_first_tail_x6_r0_body.S24)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5265, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.S26) (27 + 1) :=
  bodySite bodyFacts1.cfix bodyFacts1.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x6_r0_body.st1.S2.tab) (Es := bodyEs1) (qs := bodyQs1)
    (ok := PRE_first_tail_x6_r0_body.st1.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site1 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts1
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site1 r hr) hi (MapOk.sub hm (sub_of_all bodySub1)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk1 r hr) hi hm ho hq)
    bodyLq1 rfl bodyNrLo1 (postSub_sound bodyPost1)
    (Nat.le_of_ble_eq_true bodyDrop1) (by decide) (Nat.le_of_ble_eq_true bodyDropH1) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN1) (by decide)
    bodyDv1 bodyDe1 bodyDl1 bodyDold1 bodyDfree1 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x6_r0_body.map_site2 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site2 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site2) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site2
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s28 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s29 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S28 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws2 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso2
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_2
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot2
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup2
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound2
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace2
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged2
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws2.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st2.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S28.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_2]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen2.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh2
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl2 : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl2 (PRE_first_tail_x6_r0_body.cncl1 bodyNcl1)

theorem bodyClean2 : Conv.JClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s28 :=
  PRE_first_tail_x6_r0_body.gjcl2 (PRE_first_tail_x6_r0_body.cjcl1 bodyClean1)

kernel_rfl bodyJsLe2 : Nat.ble PRE_first_tail_x6_r0_body.s24.next PRE_first_tail_x6_r0_body.s28.next = true
kernel_rfl bodyJsList2 : (PRE_first_tail_x6_r0_body.gjh2 ++ PRE_first_tail_x6_r0_body.cl2).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s28.next) PRE_first_tail_x6_r0_body.s30) = true
theorem bodyJs2 : JsHeapAbove PRE_first_tail_x6_r0_body.s28.next PRE_first_tail_x6_r0_body.s30 :=
  JsHeapAbove.glueSite bodyJs1 (Nat.le_of_ble_eq_true bodyJsLe2) PRE_first_tail_x6_r0_body.gjk2 PRE_first_tail_x6_r0_body.gjbd2 PRE_first_tail_x6_r0_body.cheap2 PRE_first_tail_x6_r0_body.zclbd2 bodyJsList2

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO26 : PRE_first_tail_x6_r0_body.S26.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S26.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr26 : bridgeOf PRE_first_tail_x6_r0_body.s26.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc26 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.S26) = fun _ _ => true
kernel_rfl bodyAcc27 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s27 PRE_first_tail_x6_r0_body.S27) = fun _ _ => true
kernel_rfl bodyBr28 : bridgeOf PRE_first_tail_x6_r0_body.s28.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt27 : isHalt PRE_first_tail_x6_r0_body.s27.ctl = false
kernel_rfl bodyTop28 : noRetBlock PRE_first_tail_x6_r0_body.s28 = true
kernel_rfl bodyCnt26 : countersOkB PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.s28 = true

theorem bodyGlue2 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5265, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.S26)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5265, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s28 PRE_first_tail_x6_r0_body.S28) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5265, 46, 0, 18⟩) bodyAcc26 PRE_first_tail_x6_r0_body.bodyRunSeg7 bodyAcc27 bodyHalt27 PRE_first_tail_x6_r0_body.bodyStepA8 bodyTop28 (fun _ hm => bodyO26 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr26).trans bodyInactive0) (bodyBr28.trans bodyBr26.symm) bodyCnt26 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift2 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S28.tab.length PRE_first_tail_x6_r0_body.s28.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P2.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P2 139 PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.s30.ffi PRE_first_tail_x6_r0_body.s29.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_2
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_2
  have hcl : SSt (· < 139) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S28.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_2] <;> decide) PRE_first_tail_x6_r0_body.cnodesK2 PRE_first_tail_x6_r0_body.cobjsK2
      PRE_first_tail_x6_r0_body.citemsK2 PRE_first_tail_x6_r0_body.cbd2 PRE_first_tail_x6_r0_body.csst2
  exact PRE_first_tail_x6_r0_body.cshift2 bodyNcl2 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_2] at this; exact this)


kernel_rfl bodyFramesEmpty2 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s29 a).isEmpty) = true
kernel_rfl bodyJsRoots2 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s28.next) PRE_first_tail_x6_r0_body.s30.trace PRE_first_tail_x6_r0_body.s30 = true
kernel_rfl bodyJsNative2 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s30.ffi) = true
kernel_rfl bodyLow2 : (PRE_first_tail_x6_r0_body.cws2 ++ PRE_first_tail_x6_r0_body.ws2).all (Nat.ble 9) = true
kernel_rfl bodyCntM2 : countersOkB PRE_first_tail_x6_r0_body.s28 PRE_first_tail_x6_r0_body.s29 = true
kernel_rfl bodyHi2 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s30.ffi).next setupP.E = true
kernel_rfl bodyNhi2 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s30.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge2 : bridgeOf PRE_first_tail_x6_r0_body.s29.ffi = bridgeOf PRE_first_tail_x6_r0_body.s28.ffi
kernel_rfl bodyNN2 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s28.ffi).nnext PRE_first_tail_x6_r0_body.P2.NL = true
kernel_rfl bodyXn2 : Nat.ble (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s30.ffi).next = true
kernel_rfl bodyLo2 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s30.ffi).next = true
theorem bodyFacts2 : BodySiteFacts PRE_first_tail_x6_r0_body.s28 PRE_first_tail_x6_r0_body.s29 PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S28 PRE_first_tail_x6_r0_body.S29 PRE_first_tail_x6_r0_body.S30
    PRE_first_tail_x6_r0_body.ws2 PRE_first_tail_x6_r0_body.cws2 PRE_first_tail_x6_r0_body.nr2 PRE_first_tail_x6_r0_body.pl2 PRE_first_tail_x6_r0_body.cl2 2676073 139 PRE_first_tail_x6_r0_body.kd2 PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.P2
    ⟨18233, 15322, 2676053, 139⟩ ⟨18233, 15322, 2676054, 139⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap2
  clean := bodyClean2
  cfix := PRE_first_tail_x6_r0_body.cfix2
  zpl := PRE_first_tail_x6_r0_body.zpl2
  zplnd := PRE_first_tail_x6_r0_body.zplnd2
  zn1 := PRE_first_tail_x6_r0_body.zn12
  zfirst := PRE_first_tail_x6_r0_body.zfirst2
  zscn := PRE_first_tail_x6_r0_body.zscn2
  zsmn := PRE_first_tail_x6_r0_body.zsmn2
  zgrow := PRE_first_tail_x6_r0_body.zgrow2
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab2
  zfresh := PRE_first_tail_x6_r0_body.zfresh2
  zcnd := PRE_first_tail_x6_r0_body.zcnd2
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi2
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt2
  zgP := PRE_first_tail_x6_r0_body.zg2_2665
  zkP := PRE_first_tail_x6_r0_body.zk2_2665
  zmP := PRE_first_tail_x6_r0_body.zm2_2665
  zgC := PRE_first_tail_x6_r0_body.zg2_2673467
  zkC := PRE_first_tail_x6_r0_body.zk2_2673467
  zmC := PRE_first_tail_x6_r0_body.zm2_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw2_2673472
  zwV := PRE_first_tail_x6_r0_body.zw2_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap2
  zclbd := PRE_first_tail_x6_r0_body.zclbd2
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap2 PRE_first_tail_x6_r0_body.stFoot2 PRE_first_tail_x6_r0_body.iso2 PRE_first_tail_x6_r0_body.zwr2
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP2
  csupp := PRE_first_tail_x6_r0_body.csupp2
  cbound := PRE_first_tail_x6_r0_body.cbound2
  zimg := PRE_first_tail_x6_r0_body.zimg2
  zctl := PRE_first_tail_x6_r0_body.zctl2
  zstack := PRE_first_tail_x6_r0_body.zstack2
  zjobs := PRE_first_tail_x6_r0_body.zjobs2
  zstores := PRE_first_tail_x6_r0_body.zstores2
  zroots := PRE_first_tail_x6_r0_body.zroots2
  znC := PRE_first_tail_x6_r0_body.znC2
  ctab := PRE_first_tail_x6_r0_body.ctab2
  zbin := PRE_first_tail_x6_r0_body.zbin2
  cbridge := PRE_first_tail_x6_r0_body.cbridge2
  sbridge := bodyBridge2
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj2
  cshiftR := fun h hNL => bodyCshift2 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN2
  raised := PRE_first_tail_x6_r0_body.raised2
  cbigs := PRE_first_tail_x6_r0_body.cbigs2
  cjcl := PRE_first_tail_x6_r0_body.cjcl2
  xnLe := Nat.le_of_ble_eq_true bodyXn2
  loLe := Nat.le_of_ble_eq_true bodyLo2
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB2
  cntM := bodyCntM2
  hiLe := Nat.le_of_ble_eq_true bodyHi2
  nhiLe := Nat.le_of_ble_eq_true bodyNhi2
  jsHeap := bodyJs2
  jsRoots := bodyJsRoots2
  jsNative := bodyJsNative2
  framesEmpty := bodyFramesEmpty2
  trailOld := by decide
  lowVars := bodyLow2

def bodyQs2 : List (Option Q) := []
noncomputable def bodyEs2 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr2.map fun r => nth? PRE_first_tail_x6_r0_body.st2.S2.tab r
kernel_rfl bodyResChk2 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs2 bodyQs2) = true
kernel_rfl bodyLq2 : bodyQs2.length = PRE_first_tail_x6_r0_body.cws2.length
kernel_rfl bodyNrLo2 : PRE_first_tail_x6_r0_body.nr2.all (Nat.ble PRE_first_tail_x6_r0_body.S28.tab.length) = true
kernel_rfl bodySub2 : (Oracles.PRE_first_tail_x6_r0_body.map_site2.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost2 : postSubB bodyM PRE_first_tail_x6_r0_body.ws2 PRE_first_tail_x6_r0_body.cws2 bodyQs2 = true
kernel_rfl bodyDrop2 : Nat.ble (5265 + (PRE_first_tail_x6_r0_body.s29.next - PRE_first_tail_x6_r0_body.s30.next)) 5284 = true
kernel_rfl bodyDropH2 : Nat.ble (46 + ((mlxOf PRE_first_tail_x6_r0_body.s29.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s30.ffi).next)) 46 = true
kernel_rfl bodyDropN2 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s29.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s30.ffi).nnext)) 0 = true
kernel_rfl bodyDv2 : bodyΘ.1.take 18 = bodyΘ.1.take 18 ++ PRE_first_tail_x6_r0_body.cws2
kernel_rfl bodyDe2 : bodyΘ.2.take 18 = bodyΘ.2.take 18 ++ PRE_first_tail_x6_r0_body.nr2.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st2.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 18) (bodyΘ.2.take 18)))
kernel_rfl bodyDl2 : (bodyΘ.1.take 18).length = (bodyΘ.2.take 18).length
kernel_rfl bodyDold2 : (bodyΘ.1.take 18).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws2).isNone && !PRE_first_tail_x6_r0_body.ws2.contains v) = true
kernel_rfl bodyDfree2 : (bodyΘ.2.take 18).all (fun e => (PRE_first_tail_x6_r0_body.cws2 ++ PRE_first_tail_x6_r0_body.ws2).all fun w => e.noVar w) = true

theorem bodyStep2 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5265, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s28 PRE_first_tail_x6_r0_body.S28)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5284, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.S30) (206 + 1) :=
  bodySite bodyFacts2.cfix bodyFacts2.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x6_r0_body.st2.S2.tab) (Es := bodyEs2) (qs := bodyQs2)
    (ok := PRE_first_tail_x6_r0_body.st2.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site2 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts2
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site2 r hr) hi (MapOk.sub hm (sub_of_all bodySub2)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk2 r hr) hi hm ho hq)
    bodyLq2 rfl bodyNrLo2 (postSub_sound bodyPost2)
    (Nat.le_of_ble_eq_true bodyDrop2) (by decide) (Nat.le_of_ble_eq_true bodyDropH2) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN2) (by decide)
    bodyDv2 bodyDe2 bodyDl2 bodyDold2 bodyDfree2 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site3 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site3 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site3) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st3.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site3
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s45 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s46 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S45 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws3 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st3.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st3.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso3
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_3
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st3.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot3
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup3
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound3
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace3
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged3
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws3.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st3.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S45.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_3]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen3.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh3
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl3 : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl3 (PRE_first_tail_x6_r0_body.cncl2 bodyNcl2)

theorem bodyClean3 : Conv.JClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s45 :=
  PRE_first_tail_x6_r0_body.gjcl3 (PRE_first_tail_x6_r0_body.cjcl2 bodyClean2)

kernel_rfl bodyJsLe3 : Nat.ble PRE_first_tail_x6_r0_body.s28.next PRE_first_tail_x6_r0_body.s45.next = true
kernel_rfl bodyJsList3 : (PRE_first_tail_x6_r0_body.gjh3 ++ PRE_first_tail_x6_r0_body.cl3).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s45.next) PRE_first_tail_x6_r0_body.s47) = true
theorem bodyJs3 : JsHeapAbove PRE_first_tail_x6_r0_body.s45.next PRE_first_tail_x6_r0_body.s47 :=
  JsHeapAbove.glueSite bodyJs2 (Nat.le_of_ble_eq_true bodyJsLe3) PRE_first_tail_x6_r0_body.gjk3 PRE_first_tail_x6_r0_body.gjbd3 PRE_first_tail_x6_r0_body.cheap3 PRE_first_tail_x6_r0_body.zclbd3 bodyJsList3

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO30 : PRE_first_tail_x6_r0_body.S30.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S30.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr30 : bridgeOf PRE_first_tail_x6_r0_body.s30.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc30 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.S30) = fun _ _ => true
kernel_rfl bodyAcc32 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s32 PRE_first_tail_x6_r0_body.S32) = fun _ _ => true
kernel_rfl bodyBr33 : bridgeOf PRE_first_tail_x6_r0_body.s33.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt32 : isHalt PRE_first_tail_x6_r0_body.s32.ctl = false
kernel_rfl bodyTop33 : noRetBlock PRE_first_tail_x6_r0_body.s33 = true
kernel_rfl bodyCnt30 : countersOkB PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.s33 = true
kernel_rfl bodyO33 : PRE_first_tail_x6_r0_body.S33.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S33.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr34 : bridgeOf PRE_first_tail_x6_r0_body.s34.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt33 : countersOkB PRE_first_tail_x6_r0_body.s33 PRE_first_tail_x6_r0_body.s34 = true
kernel_rfl bodyO34 : PRE_first_tail_x6_r0_body.S34.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S34.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc34 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s34 PRE_first_tail_x6_r0_body.S34) = fun _ _ => true
kernel_rfl bodyAcc35 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s35 PRE_first_tail_x6_r0_body.S35) = fun _ _ => true
kernel_rfl bodyBr36 : bridgeOf PRE_first_tail_x6_r0_body.s36.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt35 : isHalt PRE_first_tail_x6_r0_body.s35.ctl = false
kernel_rfl bodyTop36 : noRetBlock PRE_first_tail_x6_r0_body.s36 = true
kernel_rfl bodyCnt34 : countersOkB PRE_first_tail_x6_r0_body.s34 PRE_first_tail_x6_r0_body.s36 = true
kernel_rfl bodyO36 : PRE_first_tail_x6_r0_body.S36.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S36.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr37 : bridgeOf PRE_first_tail_x6_r0_body.s37.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt36 : countersOkB PRE_first_tail_x6_r0_body.s36 PRE_first_tail_x6_r0_body.s37 = true
kernel_rfl bodyO37 : PRE_first_tail_x6_r0_body.S37.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S37.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc37 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s37 PRE_first_tail_x6_r0_body.S37) = fun _ _ => true
kernel_rfl bodyAcc38 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s38 PRE_first_tail_x6_r0_body.S38) = fun _ _ => true
kernel_rfl bodyBr39 : bridgeOf PRE_first_tail_x6_r0_body.s39.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt38 : isHalt PRE_first_tail_x6_r0_body.s38.ctl = false
kernel_rfl bodyTop39 : noRetBlock PRE_first_tail_x6_r0_body.s39 = true
kernel_rfl bodyCnt37 : countersOkB PRE_first_tail_x6_r0_body.s37 PRE_first_tail_x6_r0_body.s39 = true
kernel_rfl bodyO39 : PRE_first_tail_x6_r0_body.S39.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S39.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr40 : bridgeOf PRE_first_tail_x6_r0_body.s40.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt39 : countersOkB PRE_first_tail_x6_r0_body.s39 PRE_first_tail_x6_r0_body.s40 = true
kernel_rfl bodyO40 : PRE_first_tail_x6_r0_body.S40.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S40.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc40 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s40 PRE_first_tail_x6_r0_body.S40) = fun _ _ => true
kernel_rfl bodyAcc41 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s41 PRE_first_tail_x6_r0_body.S41) = fun _ _ => true
kernel_rfl bodyBr42 : bridgeOf PRE_first_tail_x6_r0_body.s42.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt41 : isHalt PRE_first_tail_x6_r0_body.s41.ctl = false
kernel_rfl bodyTop42 : noRetBlock PRE_first_tail_x6_r0_body.s42 = true
kernel_rfl bodyCnt40 : countersOkB PRE_first_tail_x6_r0_body.s40 PRE_first_tail_x6_r0_body.s42 = true
kernel_rfl bodyO42 : PRE_first_tail_x6_r0_body.S42.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S42.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr43 : bridgeOf PRE_first_tail_x6_r0_body.s43.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt42 : countersOkB PRE_first_tail_x6_r0_body.s42 PRE_first_tail_x6_r0_body.s43 = true
kernel_rfl bodyO43 : PRE_first_tail_x6_r0_body.S43.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S43.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc43 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s43 PRE_first_tail_x6_r0_body.S43) = fun _ _ => true
kernel_rfl bodyAcc44 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s44 PRE_first_tail_x6_r0_body.S44) = fun _ _ => true
kernel_rfl bodyBr45 : bridgeOf PRE_first_tail_x6_r0_body.s45.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt44 : isHalt PRE_first_tail_x6_r0_body.s44.ctl = false
kernel_rfl bodyTop45 : noRetBlock PRE_first_tail_x6_r0_body.s45 = true
kernel_rfl bodyCnt43 : countersOkB PRE_first_tail_x6_r0_body.s43 PRE_first_tail_x6_r0_body.s45 = true

theorem bodyGlue3 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5284, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.S30)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5284, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s45 PRE_first_tail_x6_r0_body.S45) 15470 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc30 PRE_first_tail_x6_r0_body.bodyRunSeg8 bodyAcc32 bodyHalt32 PRE_first_tail_x6_r0_body.bodyStepA9 bodyTop33 (fun _ hm => bodyO30 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr30).trans bodyInactive0) (bodyBr33.trans bodyBr30.symm) bodyCnt30 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) PRE_first_tail_x6_r0_body.sizeA9 PRE_first_tail_x6_r0_body.sizeArgsA9 PRE_first_tail_x6_r0_body.sizeSymA9 PRE_first_tail_x6_r0_body.sizeMlxA9 PRE_first_tail_x6_r0_body.sizePayA9 PRE_first_tail_x6_r0_body.sizeTaA9 PRE_first_tail_x6_r0_body.sizeDecA9 PRE_first_tail_x6_r0_body.sizePreA9 PRE_first_tail_x6_r0_body.bodyPatchB9 (fun _ hm => bodyO33 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr33).trans bodyInactive0) (bodyBr34.trans bodyBr33.symm) bodyCnt33 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc34 PRE_first_tail_x6_r0_body.bodyRunSeg9 bodyAcc35 bodyHalt35 PRE_first_tail_x6_r0_body.bodyStepA10 bodyTop36 (fun _ hm => bodyO34 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr34).trans bodyInactive0) (bodyBr36.trans bodyBr34.symm) bodyCnt34 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) PRE_first_tail_x6_r0_body.sizeA10 PRE_first_tail_x6_r0_body.sizeArgsA10 PRE_first_tail_x6_r0_body.sizeSymA10 PRE_first_tail_x6_r0_body.sizeMlxA10 PRE_first_tail_x6_r0_body.sizePayA10 PRE_first_tail_x6_r0_body.sizeTaA10 PRE_first_tail_x6_r0_body.sizeDecA10 PRE_first_tail_x6_r0_body.sizePreA10 PRE_first_tail_x6_r0_body.bodyPatchB10 (fun _ hm => bodyO36 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr36).trans bodyInactive0) (bodyBr37.trans bodyBr36.symm) bodyCnt36 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc37 PRE_first_tail_x6_r0_body.bodyRunSeg10 bodyAcc38 bodyHalt38 PRE_first_tail_x6_r0_body.bodyStepA11 bodyTop39 (fun _ hm => bodyO37 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr37).trans bodyInactive0) (bodyBr39.trans bodyBr37.symm) bodyCnt37 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) PRE_first_tail_x6_r0_body.sizeA11 PRE_first_tail_x6_r0_body.sizeArgsA11 PRE_first_tail_x6_r0_body.sizeSymA11 PRE_first_tail_x6_r0_body.sizeMlxA11 PRE_first_tail_x6_r0_body.sizePayA11 PRE_first_tail_x6_r0_body.sizeTaA11 PRE_first_tail_x6_r0_body.sizeDecA11 PRE_first_tail_x6_r0_body.sizePreA11 PRE_first_tail_x6_r0_body.bodyPatchB11 (fun _ hm => bodyO39 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr39).trans bodyInactive0) (bodyBr40.trans bodyBr39.symm) bodyCnt39 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc40 PRE_first_tail_x6_r0_body.bodyRunSeg11 bodyAcc41 bodyHalt41 PRE_first_tail_x6_r0_body.bodyStepA12 bodyTop42 (fun _ hm => bodyO40 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr40).trans bodyInactive0) (bodyBr42.trans bodyBr40.symm) bodyCnt40 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) PRE_first_tail_x6_r0_body.sizeA12 PRE_first_tail_x6_r0_body.sizeArgsA12 PRE_first_tail_x6_r0_body.sizeSymA12 PRE_first_tail_x6_r0_body.sizeMlxA12 PRE_first_tail_x6_r0_body.sizePayA12 PRE_first_tail_x6_r0_body.sizeTaA12 PRE_first_tail_x6_r0_body.sizeDecA12 PRE_first_tail_x6_r0_body.sizePreA12 PRE_first_tail_x6_r0_body.bodyPatchB12 (fun _ hm => bodyO42 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr42).trans bodyInactive0) (bodyBr43.trans bodyBr42.symm) bodyCnt42 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc43 PRE_first_tail_x6_r0_body.bodyRunSeg12 bodyAcc44 bodyHalt44 PRE_first_tail_x6_r0_body.bodyStepA13 bodyTop45 (fun _ hm => bodyO43 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr43).trans bodyInactive0) (bodyBr45.trans bodyBr43.symm) bodyCnt43 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift3 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S45.tab.length PRE_first_tail_x6_r0_body.s45.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P3.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P3 230 PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.s47.ffi PRE_first_tail_x6_r0_body.s46.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_3
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_3
  have hcl : SSt (· < 230) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S45.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_3] <;> decide) PRE_first_tail_x6_r0_body.cnodesK3 PRE_first_tail_x6_r0_body.cobjsK3
      PRE_first_tail_x6_r0_body.citemsK3 PRE_first_tail_x6_r0_body.cbd3 PRE_first_tail_x6_r0_body.csst3
  exact PRE_first_tail_x6_r0_body.cshift3 bodyNcl3 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_3] at this; exact this)


kernel_rfl bodyFramesEmpty3 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s46 a).isEmpty) = true
kernel_rfl bodyJsRoots3 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s45.next) PRE_first_tail_x6_r0_body.s47.trace PRE_first_tail_x6_r0_body.s47 = true
kernel_rfl bodyJsNative3 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s47.ffi) = true
kernel_rfl bodyLow3 : (PRE_first_tail_x6_r0_body.cws3 ++ PRE_first_tail_x6_r0_body.ws3).all (Nat.ble 9) = true
kernel_rfl bodyCntM3 : countersOkB PRE_first_tail_x6_r0_body.s45 PRE_first_tail_x6_r0_body.s46 = true
kernel_rfl bodyHi3 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s47.ffi).next setupP.E = true
kernel_rfl bodyNhi3 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s47.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge3 : bridgeOf PRE_first_tail_x6_r0_body.s46.ffi = bridgeOf PRE_first_tail_x6_r0_body.s45.ffi
kernel_rfl bodyNN3 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s45.ffi).nnext PRE_first_tail_x6_r0_body.P3.NL = true
kernel_rfl bodyXn3 : Nat.ble (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s47.ffi).next = true
kernel_rfl bodyLo3 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s47.ffi).next = true
theorem bodyFacts3 : BodySiteFacts PRE_first_tail_x6_r0_body.s45 PRE_first_tail_x6_r0_body.s46 PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S45 PRE_first_tail_x6_r0_body.S46 PRE_first_tail_x6_r0_body.S47
    PRE_first_tail_x6_r0_body.ws3 PRE_first_tail_x6_r0_body.cws3 PRE_first_tail_x6_r0_body.nr3 PRE_first_tail_x6_r0_body.pl3 PRE_first_tail_x6_r0_body.cl3 2678778 230 PRE_first_tail_x6_r0_body.kd3 PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.P3
    ⟨18270, 15341, 2677623, 212⟩ ⟨18273, 15368, 2677629, 230⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap3
  clean := bodyClean3
  cfix := PRE_first_tail_x6_r0_body.cfix3
  zpl := PRE_first_tail_x6_r0_body.zpl3
  zplnd := PRE_first_tail_x6_r0_body.zplnd3
  zn1 := PRE_first_tail_x6_r0_body.zn13
  zfirst := PRE_first_tail_x6_r0_body.zfirst3
  zscn := PRE_first_tail_x6_r0_body.zscn3
  zsmn := PRE_first_tail_x6_r0_body.zsmn3
  zgrow := PRE_first_tail_x6_r0_body.zgrow3
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab3
  zfresh := PRE_first_tail_x6_r0_body.zfresh3
  zcnd := PRE_first_tail_x6_r0_body.zcnd3
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi3
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt3
  zgP := PRE_first_tail_x6_r0_body.zg3_2665
  zkP := PRE_first_tail_x6_r0_body.zk3_2665
  zmP := PRE_first_tail_x6_r0_body.zm3_2665
  zgC := PRE_first_tail_x6_r0_body.zg3_2673467
  zkC := PRE_first_tail_x6_r0_body.zk3_2673467
  zmC := PRE_first_tail_x6_r0_body.zm3_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw3_2673472
  zwV := PRE_first_tail_x6_r0_body.zw3_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap3
  zclbd := PRE_first_tail_x6_r0_body.zclbd3
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap3 PRE_first_tail_x6_r0_body.stFoot3 PRE_first_tail_x6_r0_body.iso3 PRE_first_tail_x6_r0_body.zwr3
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP3
  csupp := PRE_first_tail_x6_r0_body.csupp3
  cbound := PRE_first_tail_x6_r0_body.cbound3
  zimg := PRE_first_tail_x6_r0_body.zimg3
  zctl := PRE_first_tail_x6_r0_body.zctl3
  zstack := PRE_first_tail_x6_r0_body.zstack3
  zjobs := PRE_first_tail_x6_r0_body.zjobs3
  zstores := PRE_first_tail_x6_r0_body.zstores3
  zroots := PRE_first_tail_x6_r0_body.zroots3
  znC := PRE_first_tail_x6_r0_body.znC3
  ctab := PRE_first_tail_x6_r0_body.ctab3
  zbin := PRE_first_tail_x6_r0_body.zbin3
  cbridge := PRE_first_tail_x6_r0_body.cbridge3
  sbridge := bodyBridge3
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj3
  cshiftR := fun h hNL => bodyCshift3 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN3
  raised := PRE_first_tail_x6_r0_body.raised3
  cbigs := PRE_first_tail_x6_r0_body.cbigs3
  cjcl := PRE_first_tail_x6_r0_body.cjcl3
  xnLe := Nat.le_of_ble_eq_true bodyXn3
  loLe := Nat.le_of_ble_eq_true bodyLo3
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB3
  cntM := bodyCntM3
  hiLe := Nat.le_of_ble_eq_true bodyHi3
  nhiLe := Nat.le_of_ble_eq_true bodyNhi3
  jsHeap := bodyJs3
  jsRoots := bodyJsRoots3
  jsNative := bodyJsNative3
  framesEmpty := bodyFramesEmpty3
  trailOld := by decide
  lowVars := bodyLow3

def bodyQs3 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs3 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr3.map fun r => nth? PRE_first_tail_x6_r0_body.st3.S5.tab r
kernel_rfl bodyResChk3 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs3 bodyQs3) = true
kernel_rfl bodyLq3 : bodyQs3.length = PRE_first_tail_x6_r0_body.cws3.length
kernel_rfl bodyNrLo3 : PRE_first_tail_x6_r0_body.nr3.all (Nat.ble PRE_first_tail_x6_r0_body.S45.tab.length) = true
kernel_rfl bodySub3 : (Oracles.PRE_first_tail_x6_r0_body.map_site3.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost3 : postSubB bodyM PRE_first_tail_x6_r0_body.ws3 PRE_first_tail_x6_r0_body.cws3 bodyQs3 = true
kernel_rfl bodyDrop3 : Nat.ble (5284 + (PRE_first_tail_x6_r0_body.s46.next - PRE_first_tail_x6_r0_body.s47.next)) 6433 = true
kernel_rfl bodyDropH3 : Nat.ble (46 + ((mlxOf PRE_first_tail_x6_r0_body.s46.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s47.ffi).next)) 71 = true
kernel_rfl bodyDropN3 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s46.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s47.ffi).nnext)) 0 = true
kernel_rfl bodyDv3 : bodyΘ.1.take 36 = bodyΘ.1.take 18 ++ PRE_first_tail_x6_r0_body.cws3
kernel_rfl bodyDe3 : bodyΘ.2.take 36 = bodyΘ.2.take 18 ++ PRE_first_tail_x6_r0_body.nr3.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st3.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 18) (bodyΘ.2.take 18)))
kernel_rfl bodyDl3 : (bodyΘ.1.take 18).length = (bodyΘ.2.take 18).length
kernel_rfl bodyDold3 : (bodyΘ.1.take 18).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws3).isNone && !PRE_first_tail_x6_r0_body.ws3.contains v) = true
kernel_rfl bodyDfree3 : (bodyΘ.2.take 36).all (fun e => (PRE_first_tail_x6_r0_body.cws3 ++ PRE_first_tail_x6_r0_body.ws3).all fun w => e.noVar w) = true

theorem bodyStep3 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5284, 46, 0, 18⟩ bodyM PRE_first_tail_x6_r0_body.s45 PRE_first_tail_x6_r0_body.S45)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6433, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.S47) (11334 + 1) :=
  bodySite bodyFacts3.cfix bodyFacts3.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x6_r0_body.st3.S5.tab) (Es := bodyEs3) (qs := bodyQs3)
    (ok := PRE_first_tail_x6_r0_body.st3.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site3 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts3
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site3 r hr) hi (MapOk.sub hm (sub_of_all bodySub3)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk3 r hr) hi hm ho hq)
    bodyLq3 rfl bodyNrLo3 (postSub_sound bodyPost3)
    (Nat.le_of_ble_eq_true bodyDrop3) (by decide) (Nat.le_of_ble_eq_true bodyDropH3) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN3) (by decide)
    bodyDv3 bodyDe3 bodyDl3 bodyDold3 bodyDfree3 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyOracles_1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_g4 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g4 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g4) (List.take 7 (List.drop 40 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site4 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site4 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site4) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st4.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g5 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g5 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g5) (List.take 3 (List.drop 47 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

noncomputable def PRE_first_tail_x6_r0_body.map_site5 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site5 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site5) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g6 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g6 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g6) (List.take 16 (List.drop 50 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site6 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site6 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site6) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st6.S0.oracle) = true

def PRE_first_tail_x6_r0_body.map_g7 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_g7 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_g7) (List.take 7 (List.drop 66 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.OR))) = true

def PRE_first_tail_x6_r0_body.map_site7 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site7 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site7) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st7.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site4 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site4 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site4) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st4.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site4
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s53 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s54 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S53 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws4 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st4.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st4.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso4
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_4
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st4.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot4
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup4
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound4
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace4
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged4
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws4.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st4.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S53.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_4]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen4.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh4
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl4 : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl4 (PRE_first_tail_x6_r0_body.cncl3 bodyNcl3)

theorem bodyClean4 : Conv.JClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s53 :=
  PRE_first_tail_x6_r0_body.gjcl4 (PRE_first_tail_x6_r0_body.cjcl3 bodyClean3)

kernel_rfl bodyJsLe4 : Nat.ble PRE_first_tail_x6_r0_body.s45.next PRE_first_tail_x6_r0_body.s53.next = true
kernel_rfl bodyJsList4 : (PRE_first_tail_x6_r0_body.gjh4 ++ PRE_first_tail_x6_r0_body.cl4).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s53.next) PRE_first_tail_x6_r0_body.s55) = true
theorem bodyJs4 : JsHeapAbove PRE_first_tail_x6_r0_body.s53.next PRE_first_tail_x6_r0_body.s55 :=
  JsHeapAbove.glueSite bodyJs3 (Nat.le_of_ble_eq_true bodyJsLe4) PRE_first_tail_x6_r0_body.gjk4 PRE_first_tail_x6_r0_body.gjbd4 PRE_first_tail_x6_r0_body.cheap4 PRE_first_tail_x6_r0_body.zclbd4 bodyJsList4

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO47 : PRE_first_tail_x6_r0_body.S47.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S47.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr47 : bridgeOf PRE_first_tail_x6_r0_body.s47.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc47 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.S47) = fun _ _ => true
kernel_rfl bodyAcc48 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s48 PRE_first_tail_x6_r0_body.S48) = fun _ _ => true
kernel_rfl bodyBr49 : bridgeOf PRE_first_tail_x6_r0_body.s49.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt48 : isHalt PRE_first_tail_x6_r0_body.s48.ctl = false
kernel_rfl bodyTop49 : noRetBlock PRE_first_tail_x6_r0_body.s49 = true
kernel_rfl bodyCnt47 : countersOkB PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.s49 = true
kernel_rfl bodyO49 : PRE_first_tail_x6_r0_body.S49.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S49.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr50 : bridgeOf PRE_first_tail_x6_r0_body.s50.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt49 : countersOkB PRE_first_tail_x6_r0_body.s49 PRE_first_tail_x6_r0_body.s50 = true
kernel_rfl bodyO50 : PRE_first_tail_x6_r0_body.S50.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S50.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc50 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s50 PRE_first_tail_x6_r0_body.S50) = fun _ _ => true
kernel_rfl bodyAcc52 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s52 PRE_first_tail_x6_r0_body.S52) = fun _ _ => true
kernel_rfl bodyBr53 : bridgeOf PRE_first_tail_x6_r0_body.s53.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt52 : isHalt PRE_first_tail_x6_r0_body.s52.ctl = false
kernel_rfl bodyTop53 : noRetBlock PRE_first_tail_x6_r0_body.s53 = true
kernel_rfl bodyCnt50 : countersOkB PRE_first_tail_x6_r0_body.s50 PRE_first_tail_x6_r0_body.s53 = true

theorem bodyGlue4 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6433, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.S47)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6433, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s53 PRE_first_tail_x6_r0_body.S53) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6433, 71, 0, 36⟩) bodyAcc47 PRE_first_tail_x6_r0_body.bodyRunSeg13 bodyAcc48 bodyHalt48 PRE_first_tail_x6_r0_body.bodyStepA14 bodyTop49 (fun _ hm => bodyO47 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr47).trans bodyInactive0) (bodyBr49.trans bodyBr47.symm) bodyCnt47 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6433, 71, 0, 36⟩) PRE_first_tail_x6_r0_body.sizeA14 PRE_first_tail_x6_r0_body.sizeArgsA14 PRE_first_tail_x6_r0_body.sizeSymA14 PRE_first_tail_x6_r0_body.sizeMlxA14 PRE_first_tail_x6_r0_body.sizePayA14 PRE_first_tail_x6_r0_body.sizeTaA14 PRE_first_tail_x6_r0_body.sizeDecA14 PRE_first_tail_x6_r0_body.sizePreA14 PRE_first_tail_x6_r0_body.bodyPatchB14 (fun _ hm => bodyO49 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr49).trans bodyInactive0) (bodyBr50.trans bodyBr49.symm) bodyCnt49 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6433, 71, 0, 36⟩) bodyAcc50 PRE_first_tail_x6_r0_body.bodyRunSeg14 bodyAcc52 bodyHalt52 PRE_first_tail_x6_r0_body.bodyStepA15 bodyTop53 (fun _ hm => bodyO50 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr50).trans bodyInactive0) (bodyBr53.trans bodyBr50.symm) bodyCnt50 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift4 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S53.tab.length PRE_first_tail_x6_r0_body.s53.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P4.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P4 251 PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.s55.ffi PRE_first_tail_x6_r0_body.s54.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_4
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_4
  have hcl : SSt (· < 251) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S53.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_4] <;> decide) PRE_first_tail_x6_r0_body.cnodesK4 PRE_first_tail_x6_r0_body.cobjsK4
      PRE_first_tail_x6_r0_body.citemsK4 PRE_first_tail_x6_r0_body.cbd4 PRE_first_tail_x6_r0_body.csst4
  exact PRE_first_tail_x6_r0_body.cshift4 bodyNcl4 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_4] at this; exact this)


kernel_rfl bodyFramesEmpty4 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s54 a).isEmpty) = true
kernel_rfl bodyJsRoots4 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s53.next) PRE_first_tail_x6_r0_body.s55.trace PRE_first_tail_x6_r0_body.s55 = true
kernel_rfl bodyJsNative4 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s55.ffi) = true
kernel_rfl bodyLow4 : (PRE_first_tail_x6_r0_body.cws4 ++ PRE_first_tail_x6_r0_body.ws4).all (Nat.ble 9) = true
kernel_rfl bodyCntM4 : countersOkB PRE_first_tail_x6_r0_body.s53 PRE_first_tail_x6_r0_body.s54 = true
kernel_rfl bodyHi4 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s55.ffi).next setupP.E = true
kernel_rfl bodyNhi4 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s55.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge4 : bridgeOf PRE_first_tail_x6_r0_body.s54.ffi = bridgeOf PRE_first_tail_x6_r0_body.s53.ffi
kernel_rfl bodyNN4 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s53.ffi).nnext PRE_first_tail_x6_r0_body.P4.NL = true
kernel_rfl bodyXn4 : Nat.ble (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s55.ffi).next = true
kernel_rfl bodyLo4 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s55.ffi).next = true
theorem bodyFacts4 : BodySiteFacts PRE_first_tail_x6_r0_body.s53 PRE_first_tail_x6_r0_body.s54 PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S53 PRE_first_tail_x6_r0_body.S54 PRE_first_tail_x6_r0_body.S55
    PRE_first_tail_x6_r0_body.ws4 PRE_first_tail_x6_r0_body.cws4 PRE_first_tail_x6_r0_body.nr4 PRE_first_tail_x6_r0_body.pl4 PRE_first_tail_x6_r0_body.cl4 2678121 251 PRE_first_tail_x6_r0_body.kd4 PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.P4
    ⟨18286, 15381, 2678119, 251⟩ ⟨18286, 15381, 2678119, 251⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap4
  clean := bodyClean4
  cfix := PRE_first_tail_x6_r0_body.cfix4
  zpl := PRE_first_tail_x6_r0_body.zpl4
  zplnd := PRE_first_tail_x6_r0_body.zplnd4
  zn1 := PRE_first_tail_x6_r0_body.zn14
  zfirst := PRE_first_tail_x6_r0_body.zfirst4
  zscn := PRE_first_tail_x6_r0_body.zscn4
  zsmn := PRE_first_tail_x6_r0_body.zsmn4
  zgrow := PRE_first_tail_x6_r0_body.zgrow4
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab4
  zfresh := PRE_first_tail_x6_r0_body.zfresh4
  zcnd := PRE_first_tail_x6_r0_body.zcnd4
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi4
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt4
  zgP := PRE_first_tail_x6_r0_body.zg4_2665
  zkP := PRE_first_tail_x6_r0_body.zk4_2665
  zmP := PRE_first_tail_x6_r0_body.zm4_2665
  zgC := PRE_first_tail_x6_r0_body.zg4_2673467
  zkC := PRE_first_tail_x6_r0_body.zk4_2673467
  zmC := PRE_first_tail_x6_r0_body.zm4_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw4_2673472
  zwV := PRE_first_tail_x6_r0_body.zw4_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap4
  zclbd := PRE_first_tail_x6_r0_body.zclbd4
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap4 PRE_first_tail_x6_r0_body.stFoot4 PRE_first_tail_x6_r0_body.iso4 PRE_first_tail_x6_r0_body.zwr4
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP4
  csupp := PRE_first_tail_x6_r0_body.csupp4
  cbound := PRE_first_tail_x6_r0_body.cbound4
  zimg := PRE_first_tail_x6_r0_body.zimg4
  zctl := PRE_first_tail_x6_r0_body.zctl4
  zstack := PRE_first_tail_x6_r0_body.zstack4
  zjobs := PRE_first_tail_x6_r0_body.zjobs4
  zstores := PRE_first_tail_x6_r0_body.zstores4
  zroots := PRE_first_tail_x6_r0_body.zroots4
  znC := PRE_first_tail_x6_r0_body.znC4
  ctab := PRE_first_tail_x6_r0_body.ctab4
  zbin := PRE_first_tail_x6_r0_body.zbin4
  cbridge := PRE_first_tail_x6_r0_body.cbridge4
  sbridge := bodyBridge4
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj4
  cshiftR := fun h hNL => bodyCshift4 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN4
  raised := PRE_first_tail_x6_r0_body.raised4
  cbigs := PRE_first_tail_x6_r0_body.cbigs4
  cjcl := PRE_first_tail_x6_r0_body.cjcl4
  xnLe := Nat.le_of_ble_eq_true bodyXn4
  loLe := Nat.le_of_ble_eq_true bodyLo4
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB4
  cntM := bodyCntM4
  hiLe := Nat.le_of_ble_eq_true bodyHi4
  nhiLe := Nat.le_of_ble_eq_true bodyNhi4
  jsHeap := bodyJs4
  jsRoots := bodyJsRoots4
  jsNative := bodyJsNative4
  framesEmpty := bodyFramesEmpty4
  trailOld := by decide
  lowVars := bodyLow4

def bodyQs4 : List (Option Q) := []
noncomputable def bodyEs4 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr4.map fun r => nth? PRE_first_tail_x6_r0_body.st4.S2.tab r
kernel_rfl bodyResChk4 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs4 bodyQs4) = true
kernel_rfl bodyLq4 : bodyQs4.length = PRE_first_tail_x6_r0_body.cws4.length
kernel_rfl bodyNrLo4 : PRE_first_tail_x6_r0_body.nr4.all (Nat.ble PRE_first_tail_x6_r0_body.S53.tab.length) = true
kernel_rfl bodySub4 : (Oracles.PRE_first_tail_x6_r0_body.map_site4.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost4 : postSubB bodyM PRE_first_tail_x6_r0_body.ws4 PRE_first_tail_x6_r0_body.cws4 bodyQs4 = true
kernel_rfl bodyDrop4 : Nat.ble (6433 + (PRE_first_tail_x6_r0_body.s54.next - PRE_first_tail_x6_r0_body.s55.next)) 6435 = true
kernel_rfl bodyDropH4 : Nat.ble (71 + ((mlxOf PRE_first_tail_x6_r0_body.s54.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s55.ffi).next)) 71 = true
kernel_rfl bodyDropN4 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s54.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s55.ffi).nnext)) 0 = true
kernel_rfl bodyDv4 : bodyΘ.1.take 36 = bodyΘ.1.take 36 ++ PRE_first_tail_x6_r0_body.cws4
kernel_rfl bodyDe4 : bodyΘ.2.take 36 = bodyΘ.2.take 36 ++ PRE_first_tail_x6_r0_body.nr4.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st4.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 36) (bodyΘ.2.take 36)))
kernel_rfl bodyDl4 : (bodyΘ.1.take 36).length = (bodyΘ.2.take 36).length
kernel_rfl bodyDold4 : (bodyΘ.1.take 36).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws4).isNone && !PRE_first_tail_x6_r0_body.ws4.contains v) = true
kernel_rfl bodyDfree4 : (bodyΘ.2.take 36).all (fun e => (PRE_first_tail_x6_r0_body.cws4 ++ PRE_first_tail_x6_r0_body.ws4).all fun w => e.noVar w) = true

theorem bodyStep4 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6433, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s53 PRE_first_tail_x6_r0_body.S53)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6435, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.S55) (27 + 1) :=
  bodySite bodyFacts4.cfix bodyFacts4.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x6_r0_body.st4.S2.tab) (Es := bodyEs4) (qs := bodyQs4)
    (ok := PRE_first_tail_x6_r0_body.st4.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site4 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts4
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site4 r hr) hi (MapOk.sub hm (sub_of_all bodySub4)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk4 r hr) hi hm ho hq)
    bodyLq4 rfl bodyNrLo4 (postSub_sound bodyPost4)
    (Nat.le_of_ble_eq_true bodyDrop4) (by decide) (Nat.le_of_ble_eq_true bodyDropH4) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN4) (by decide)
    bodyDv4 bodyDe4 bodyDl4 bodyDold4 bodyDfree4 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def PRE_first_tail_x6_r0_body.map_site5 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x6_r0_body.chk_site5 : ([first_tail_x6.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site5) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site5
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s57 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s58 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S57 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws5 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso5
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_5
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot5
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup5
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound5
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace5
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged5
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws5.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st5.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S57.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_5]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen5.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh5
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl5 : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl5 (PRE_first_tail_x6_r0_body.cncl4 bodyNcl4)

theorem bodyClean5 : Conv.JClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s57 :=
  PRE_first_tail_x6_r0_body.gjcl5 (PRE_first_tail_x6_r0_body.cjcl4 bodyClean4)

kernel_rfl bodyJsLe5 : Nat.ble PRE_first_tail_x6_r0_body.s53.next PRE_first_tail_x6_r0_body.s57.next = true
kernel_rfl bodyJsList5 : (PRE_first_tail_x6_r0_body.gjh5 ++ PRE_first_tail_x6_r0_body.cl5).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s57.next) PRE_first_tail_x6_r0_body.s59) = true
theorem bodyJs5 : JsHeapAbove PRE_first_tail_x6_r0_body.s57.next PRE_first_tail_x6_r0_body.s59 :=
  JsHeapAbove.glueSite bodyJs4 (Nat.le_of_ble_eq_true bodyJsLe5) PRE_first_tail_x6_r0_body.gjk5 PRE_first_tail_x6_r0_body.gjbd5 PRE_first_tail_x6_r0_body.cheap5 PRE_first_tail_x6_r0_body.zclbd5 bodyJsList5

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO55 : PRE_first_tail_x6_r0_body.S55.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S55.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr55 : bridgeOf PRE_first_tail_x6_r0_body.s55.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc55 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.S55) = fun _ _ => true
kernel_rfl bodyAcc56 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s56 PRE_first_tail_x6_r0_body.S56) = fun _ _ => true
kernel_rfl bodyBr57 : bridgeOf PRE_first_tail_x6_r0_body.s57.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt56 : isHalt PRE_first_tail_x6_r0_body.s56.ctl = false
kernel_rfl bodyTop57 : noRetBlock PRE_first_tail_x6_r0_body.s57 = true
kernel_rfl bodyCnt55 : countersOkB PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.s57 = true

theorem bodyGlue5 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6435, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.S55)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6435, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s57 PRE_first_tail_x6_r0_body.S57) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6435, 71, 0, 36⟩) bodyAcc55 PRE_first_tail_x6_r0_body.bodyRunSeg15 bodyAcc56 bodyHalt56 PRE_first_tail_x6_r0_body.bodyStepA16 bodyTop57 (fun _ hm => bodyO55 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr55).trans bodyInactive0) (bodyBr57.trans bodyBr55.symm) bodyCnt55 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift5 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S57.tab.length PRE_first_tail_x6_r0_body.s57.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P5.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P5 268 PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.s59.ffi PRE_first_tail_x6_r0_body.s58.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_5
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_5
  have hcl : SSt (· < 268) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S57.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_5] <;> decide) PRE_first_tail_x6_r0_body.cnodesK5 PRE_first_tail_x6_r0_body.cobjsK5
      PRE_first_tail_x6_r0_body.citemsK5 PRE_first_tail_x6_r0_body.cbd5 PRE_first_tail_x6_r0_body.csst5
  exact PRE_first_tail_x6_r0_body.cshift5 bodyNcl5 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_5] at this; exact this)


kernel_rfl bodyFramesEmpty5 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s58 a).isEmpty) = true
kernel_rfl bodyJsRoots5 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s57.next) PRE_first_tail_x6_r0_body.s59.trace PRE_first_tail_x6_r0_body.s59 = true
kernel_rfl bodyJsNative5 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s59.ffi) = true
kernel_rfl bodyLow5 : (PRE_first_tail_x6_r0_body.cws5 ++ PRE_first_tail_x6_r0_body.ws5).all (Nat.ble 9) = true
kernel_rfl bodyCntM5 : countersOkB PRE_first_tail_x6_r0_body.s57 PRE_first_tail_x6_r0_body.s58 = true
kernel_rfl bodyHi5 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s59.ffi).next setupP.E = true
kernel_rfl bodyNhi5 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s59.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge5 : bridgeOf PRE_first_tail_x6_r0_body.s58.ffi = bridgeOf PRE_first_tail_x6_r0_body.s57.ffi
kernel_rfl bodyNN5 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s57.ffi).nnext PRE_first_tail_x6_r0_body.P5.NL = true
kernel_rfl bodyXn5 : Nat.ble (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s59.ffi).next = true
kernel_rfl bodyLo5 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s59.ffi).next = true
theorem bodyFacts5 : BodySiteFacts PRE_first_tail_x6_r0_body.s57 PRE_first_tail_x6_r0_body.s58 PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S57 PRE_first_tail_x6_r0_body.S58 PRE_first_tail_x6_r0_body.S59
    PRE_first_tail_x6_r0_body.ws5 PRE_first_tail_x6_r0_body.cws5 PRE_first_tail_x6_r0_body.nr5 PRE_first_tail_x6_r0_body.pl5 PRE_first_tail_x6_r0_body.cl5 2678418 268 PRE_first_tail_x6_r0_body.kd5 PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.P5
    ⟨18293, 15385, 2678407, 268⟩ ⟨18293, 15385, 2678408, 268⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap5
  clean := bodyClean5
  cfix := PRE_first_tail_x6_r0_body.cfix5
  zpl := PRE_first_tail_x6_r0_body.zpl5
  zplnd := PRE_first_tail_x6_r0_body.zplnd5
  zn1 := PRE_first_tail_x6_r0_body.zn15
  zfirst := PRE_first_tail_x6_r0_body.zfirst5
  zscn := PRE_first_tail_x6_r0_body.zscn5
  zsmn := PRE_first_tail_x6_r0_body.zsmn5
  zgrow := PRE_first_tail_x6_r0_body.zgrow5
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab5
  zfresh := PRE_first_tail_x6_r0_body.zfresh5
  zcnd := PRE_first_tail_x6_r0_body.zcnd5
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi5
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt5
  zgP := PRE_first_tail_x6_r0_body.zg5_2665
  zkP := PRE_first_tail_x6_r0_body.zk5_2665
  zmP := PRE_first_tail_x6_r0_body.zm5_2665
  zgC := PRE_first_tail_x6_r0_body.zg5_2673467
  zkC := PRE_first_tail_x6_r0_body.zk5_2673467
  zmC := PRE_first_tail_x6_r0_body.zm5_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw5_2673472
  zwV := PRE_first_tail_x6_r0_body.zw5_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap5
  zclbd := PRE_first_tail_x6_r0_body.zclbd5
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap5 PRE_first_tail_x6_r0_body.stFoot5 PRE_first_tail_x6_r0_body.iso5 PRE_first_tail_x6_r0_body.zwr5
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP5
  csupp := PRE_first_tail_x6_r0_body.csupp5
  cbound := PRE_first_tail_x6_r0_body.cbound5
  zimg := PRE_first_tail_x6_r0_body.zimg5
  zctl := PRE_first_tail_x6_r0_body.zctl5
  zstack := PRE_first_tail_x6_r0_body.zstack5
  zjobs := PRE_first_tail_x6_r0_body.zjobs5
  zstores := PRE_first_tail_x6_r0_body.zstores5
  zroots := PRE_first_tail_x6_r0_body.zroots5
  znC := PRE_first_tail_x6_r0_body.znC5
  ctab := PRE_first_tail_x6_r0_body.ctab5
  zbin := PRE_first_tail_x6_r0_body.zbin5
  cbridge := PRE_first_tail_x6_r0_body.cbridge5
  sbridge := bodyBridge5
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj5
  cshiftR := fun h hNL => bodyCshift5 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN5
  raised := PRE_first_tail_x6_r0_body.raised5
  cbigs := PRE_first_tail_x6_r0_body.cbigs5
  cjcl := PRE_first_tail_x6_r0_body.cjcl5
  xnLe := Nat.le_of_ble_eq_true bodyXn5
  loLe := Nat.le_of_ble_eq_true bodyLo5
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB5
  cntM := bodyCntM5
  hiLe := Nat.le_of_ble_eq_true bodyHi5
  nhiLe := Nat.le_of_ble_eq_true bodyNhi5
  jsHeap := bodyJs5
  jsRoots := bodyJsRoots5
  jsNative := bodyJsNative5
  framesEmpty := bodyFramesEmpty5
  trailOld := by decide
  lowVars := bodyLow5

def bodyQs5 : List (Option Q) := []
noncomputable def bodyEs5 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr5.map fun r => nth? PRE_first_tail_x6_r0_body.st5.S2.tab r
kernel_rfl bodyResChk5 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs5 bodyQs5) = true
kernel_rfl bodyLq5 : bodyQs5.length = PRE_first_tail_x6_r0_body.cws5.length
kernel_rfl bodyNrLo5 : PRE_first_tail_x6_r0_body.nr5.all (Nat.ble PRE_first_tail_x6_r0_body.S57.tab.length) = true
kernel_rfl bodySub5 : (Oracles.PRE_first_tail_x6_r0_body.map_site5.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost5 : postSubB bodyM PRE_first_tail_x6_r0_body.ws5 PRE_first_tail_x6_r0_body.cws5 bodyQs5 = true
kernel_rfl bodyDrop5 : Nat.ble (6435 + (PRE_first_tail_x6_r0_body.s58.next - PRE_first_tail_x6_r0_body.s59.next)) 6445 = true
kernel_rfl bodyDropH5 : Nat.ble (71 + ((mlxOf PRE_first_tail_x6_r0_body.s58.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s59.ffi).next)) 71 = true
kernel_rfl bodyDropN5 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s58.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s59.ffi).nnext)) 0 = true
kernel_rfl bodyDv5 : bodyΘ.1.take 36 = bodyΘ.1.take 36 ++ PRE_first_tail_x6_r0_body.cws5
kernel_rfl bodyDe5 : bodyΘ.2.take 36 = bodyΘ.2.take 36 ++ PRE_first_tail_x6_r0_body.nr5.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st5.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 36) (bodyΘ.2.take 36)))
kernel_rfl bodyDl5 : (bodyΘ.1.take 36).length = (bodyΘ.2.take 36).length
kernel_rfl bodyDold5 : (bodyΘ.1.take 36).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws5).isNone && !PRE_first_tail_x6_r0_body.ws5.contains v) = true
kernel_rfl bodyDfree5 : (bodyΘ.2.take 36).all (fun e => (PRE_first_tail_x6_r0_body.cws5 ++ PRE_first_tail_x6_r0_body.ws5).all fun w => e.noVar w) = true

theorem bodyStep5 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6435, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s57 PRE_first_tail_x6_r0_body.S57)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6445, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.S59) (98 + 1) :=
  bodySite bodyFacts5.cfix bodyFacts5.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x6_r0_body.st5.S2.tab) (Es := bodyEs5) (qs := bodyQs5)
    (ok := PRE_first_tail_x6_r0_body.st5.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site5 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts5
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site5 r hr) hi (MapOk.sub hm (sub_of_all bodySub5)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk5 r hr) hi hm ho hq)
    bodyLq5 rfl bodyNrLo5 (postSub_sound bodyPost5)
    (Nat.le_of_ble_eq_true bodyDrop5) (by decide) (Nat.le_of_ble_eq_true bodyDropH5) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN5) (by decide)
    bodyDv5 bodyDe5 bodyDl5 bodyDold5 bodyDfree5 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site6 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site6 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site6) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st6.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site6
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s74 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s75 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S74 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws6 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st6.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st6.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso6
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_6
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st6.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot6
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup6
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound6
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace6
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged6
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws6.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st6.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S74.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_6]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen6.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh6
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl6 : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl6 (PRE_first_tail_x6_r0_body.cncl5 bodyNcl5)

theorem bodyClean6 : Conv.JClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s74 :=
  PRE_first_tail_x6_r0_body.gjcl6 (PRE_first_tail_x6_r0_body.cjcl5 bodyClean5)

kernel_rfl bodyJsLe6 : Nat.ble PRE_first_tail_x6_r0_body.s57.next PRE_first_tail_x6_r0_body.s74.next = true
kernel_rfl bodyJsList6 : (PRE_first_tail_x6_r0_body.gjh6 ++ PRE_first_tail_x6_r0_body.cl6).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s74.next) PRE_first_tail_x6_r0_body.s76) = true
theorem bodyJs6 : JsHeapAbove PRE_first_tail_x6_r0_body.s74.next PRE_first_tail_x6_r0_body.s76 :=
  JsHeapAbove.glueSite bodyJs5 (Nat.le_of_ble_eq_true bodyJsLe6) PRE_first_tail_x6_r0_body.gjk6 PRE_first_tail_x6_r0_body.gjbd6 PRE_first_tail_x6_r0_body.cheap6 PRE_first_tail_x6_r0_body.zclbd6 bodyJsList6

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO59 : PRE_first_tail_x6_r0_body.S59.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S59.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr59 : bridgeOf PRE_first_tail_x6_r0_body.s59.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc59 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.S59) = fun _ _ => true
kernel_rfl bodyAcc61 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s61 PRE_first_tail_x6_r0_body.S61) = fun _ _ => true
kernel_rfl bodyBr62 : bridgeOf PRE_first_tail_x6_r0_body.s62.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt61 : isHalt PRE_first_tail_x6_r0_body.s61.ctl = false
kernel_rfl bodyTop62 : noRetBlock PRE_first_tail_x6_r0_body.s62 = true
kernel_rfl bodyCnt59 : countersOkB PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.s62 = true
kernel_rfl bodyO62 : PRE_first_tail_x6_r0_body.S62.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S62.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr63 : bridgeOf PRE_first_tail_x6_r0_body.s63.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt62 : countersOkB PRE_first_tail_x6_r0_body.s62 PRE_first_tail_x6_r0_body.s63 = true
kernel_rfl bodyO63 : PRE_first_tail_x6_r0_body.S63.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S63.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc63 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s63 PRE_first_tail_x6_r0_body.S63) = fun _ _ => true
kernel_rfl bodyAcc64 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s64 PRE_first_tail_x6_r0_body.S64) = fun _ _ => true
kernel_rfl bodyBr65 : bridgeOf PRE_first_tail_x6_r0_body.s65.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt64 : isHalt PRE_first_tail_x6_r0_body.s64.ctl = false
kernel_rfl bodyTop65 : noRetBlock PRE_first_tail_x6_r0_body.s65 = true
kernel_rfl bodyCnt63 : countersOkB PRE_first_tail_x6_r0_body.s63 PRE_first_tail_x6_r0_body.s65 = true
kernel_rfl bodyO65 : PRE_first_tail_x6_r0_body.S65.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S65.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr66 : bridgeOf PRE_first_tail_x6_r0_body.s66.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt65 : countersOkB PRE_first_tail_x6_r0_body.s65 PRE_first_tail_x6_r0_body.s66 = true
kernel_rfl bodyO66 : PRE_first_tail_x6_r0_body.S66.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S66.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc66 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s66 PRE_first_tail_x6_r0_body.S66) = fun _ _ => true
kernel_rfl bodyAcc67 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s67 PRE_first_tail_x6_r0_body.S67) = fun _ _ => true
kernel_rfl bodyBr68 : bridgeOf PRE_first_tail_x6_r0_body.s68.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt67 : isHalt PRE_first_tail_x6_r0_body.s67.ctl = false
kernel_rfl bodyTop68 : noRetBlock PRE_first_tail_x6_r0_body.s68 = true
kernel_rfl bodyCnt66 : countersOkB PRE_first_tail_x6_r0_body.s66 PRE_first_tail_x6_r0_body.s68 = true
kernel_rfl bodyO68 : PRE_first_tail_x6_r0_body.S68.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S68.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr69 : bridgeOf PRE_first_tail_x6_r0_body.s69.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt68 : countersOkB PRE_first_tail_x6_r0_body.s68 PRE_first_tail_x6_r0_body.s69 = true
kernel_rfl bodyO69 : PRE_first_tail_x6_r0_body.S69.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S69.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc69 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s69 PRE_first_tail_x6_r0_body.S69) = fun _ _ => true
kernel_rfl bodyAcc70 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s70 PRE_first_tail_x6_r0_body.S70) = fun _ _ => true
kernel_rfl bodyBr71 : bridgeOf PRE_first_tail_x6_r0_body.s71.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt70 : isHalt PRE_first_tail_x6_r0_body.s70.ctl = false
kernel_rfl bodyTop71 : noRetBlock PRE_first_tail_x6_r0_body.s71 = true
kernel_rfl bodyCnt69 : countersOkB PRE_first_tail_x6_r0_body.s69 PRE_first_tail_x6_r0_body.s71 = true
kernel_rfl bodyO71 : PRE_first_tail_x6_r0_body.S71.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S71.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr72 : bridgeOf PRE_first_tail_x6_r0_body.s72.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt71 : countersOkB PRE_first_tail_x6_r0_body.s71 PRE_first_tail_x6_r0_body.s72 = true
kernel_rfl bodyO72 : PRE_first_tail_x6_r0_body.S72.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S72.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc72 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s72 PRE_first_tail_x6_r0_body.S72) = fun _ _ => true
kernel_rfl bodyAcc73 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s73 PRE_first_tail_x6_r0_body.S73) = fun _ _ => true
kernel_rfl bodyBr74 : bridgeOf PRE_first_tail_x6_r0_body.s74.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt73 : isHalt PRE_first_tail_x6_r0_body.s73.ctl = false
kernel_rfl bodyTop74 : noRetBlock PRE_first_tail_x6_r0_body.s74 = true
kernel_rfl bodyCnt72 : countersOkB PRE_first_tail_x6_r0_body.s72 PRE_first_tail_x6_r0_body.s74 = true

theorem bodyGlue6 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6445, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.S59)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6445, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s74 PRE_first_tail_x6_r0_body.S74) 15435 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc59 PRE_first_tail_x6_r0_body.bodyRunSeg16 bodyAcc61 bodyHalt61 PRE_first_tail_x6_r0_body.bodyStepA17 bodyTop62 (fun _ hm => bodyO59 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr59).trans bodyInactive0) (bodyBr62.trans bodyBr59.symm) bodyCnt59 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) PRE_first_tail_x6_r0_body.sizeA17 PRE_first_tail_x6_r0_body.sizeArgsA17 PRE_first_tail_x6_r0_body.sizeSymA17 PRE_first_tail_x6_r0_body.sizeMlxA17 PRE_first_tail_x6_r0_body.sizePayA17 PRE_first_tail_x6_r0_body.sizeTaA17 PRE_first_tail_x6_r0_body.sizeDecA17 PRE_first_tail_x6_r0_body.sizePreA17 PRE_first_tail_x6_r0_body.bodyPatchB17 (fun _ hm => bodyO62 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr62).trans bodyInactive0) (bodyBr63.trans bodyBr62.symm) bodyCnt62 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc63 PRE_first_tail_x6_r0_body.bodyRunSeg17 bodyAcc64 bodyHalt64 PRE_first_tail_x6_r0_body.bodyStepA18 bodyTop65 (fun _ hm => bodyO63 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr63).trans bodyInactive0) (bodyBr65.trans bodyBr63.symm) bodyCnt63 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) PRE_first_tail_x6_r0_body.sizeA18 PRE_first_tail_x6_r0_body.sizeArgsA18 PRE_first_tail_x6_r0_body.sizeSymA18 PRE_first_tail_x6_r0_body.sizeMlxA18 PRE_first_tail_x6_r0_body.sizePayA18 PRE_first_tail_x6_r0_body.sizeTaA18 PRE_first_tail_x6_r0_body.sizeDecA18 PRE_first_tail_x6_r0_body.sizePreA18 PRE_first_tail_x6_r0_body.bodyPatchB18 (fun _ hm => bodyO65 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr65).trans bodyInactive0) (bodyBr66.trans bodyBr65.symm) bodyCnt65 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc66 PRE_first_tail_x6_r0_body.bodyRunSeg18 bodyAcc67 bodyHalt67 PRE_first_tail_x6_r0_body.bodyStepA19 bodyTop68 (fun _ hm => bodyO66 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr66).trans bodyInactive0) (bodyBr68.trans bodyBr66.symm) bodyCnt66 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) PRE_first_tail_x6_r0_body.sizeA19 PRE_first_tail_x6_r0_body.sizeArgsA19 PRE_first_tail_x6_r0_body.sizeSymA19 PRE_first_tail_x6_r0_body.sizeMlxA19 PRE_first_tail_x6_r0_body.sizePayA19 PRE_first_tail_x6_r0_body.sizeTaA19 PRE_first_tail_x6_r0_body.sizeDecA19 PRE_first_tail_x6_r0_body.sizePreA19 PRE_first_tail_x6_r0_body.bodyPatchB19 (fun _ hm => bodyO68 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr68).trans bodyInactive0) (bodyBr69.trans bodyBr68.symm) bodyCnt68 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc69 PRE_first_tail_x6_r0_body.bodyRunSeg19 bodyAcc70 bodyHalt70 PRE_first_tail_x6_r0_body.bodyStepA20 bodyTop71 (fun _ hm => bodyO69 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr69).trans bodyInactive0) (bodyBr71.trans bodyBr69.symm) bodyCnt69 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) PRE_first_tail_x6_r0_body.sizeA20 PRE_first_tail_x6_r0_body.sizeArgsA20 PRE_first_tail_x6_r0_body.sizeSymA20 PRE_first_tail_x6_r0_body.sizeMlxA20 PRE_first_tail_x6_r0_body.sizePayA20 PRE_first_tail_x6_r0_body.sizeTaA20 PRE_first_tail_x6_r0_body.sizeDecA20 PRE_first_tail_x6_r0_body.sizePreA20 PRE_first_tail_x6_r0_body.bodyPatchB20 (fun _ hm => bodyO71 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr71).trans bodyInactive0) (bodyBr72.trans bodyBr71.symm) bodyCnt71 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6445, 71, 0, 36⟩) bodyAcc72 PRE_first_tail_x6_r0_body.bodyRunSeg20 bodyAcc73 bodyHalt73 PRE_first_tail_x6_r0_body.bodyStepA21 bodyTop74 (fun _ hm => bodyO72 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr72).trans bodyInactive0) (bodyBr74.trans bodyBr72.symm) bodyCnt72 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift6 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S74.tab.length PRE_first_tail_x6_r0_body.s74.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P6.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P6 359 PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.s76.ffi PRE_first_tail_x6_r0_body.s75.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_6
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_6
  have hcl : SSt (· < 359) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S74.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_6] <;> decide) PRE_first_tail_x6_r0_body.cnodesK6 PRE_first_tail_x6_r0_body.cobjsK6
      PRE_first_tail_x6_r0_body.citemsK6 PRE_first_tail_x6_r0_body.cbd6 PRE_first_tail_x6_r0_body.csst6
  exact PRE_first_tail_x6_r0_body.cshift6 bodyNcl6 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_6] at this; exact this)


kernel_rfl bodyFramesEmpty6 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s75 a).isEmpty) = true
kernel_rfl bodyJsRoots6 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s74.next) PRE_first_tail_x6_r0_body.s76.trace PRE_first_tail_x6_r0_body.s76 = true
kernel_rfl bodyJsNative6 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s76.ffi) = true
kernel_rfl bodyLow6 : (PRE_first_tail_x6_r0_body.cws6 ++ PRE_first_tail_x6_r0_body.ws6).all (Nat.ble 9) = true
kernel_rfl bodyCntM6 : countersOkB PRE_first_tail_x6_r0_body.s74 PRE_first_tail_x6_r0_body.s75 = true
kernel_rfl bodyHi6 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s76.ffi).next setupP.E = true
kernel_rfl bodyNhi6 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s76.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge6 : bridgeOf PRE_first_tail_x6_r0_body.s75.ffi = bridgeOf PRE_first_tail_x6_r0_body.s74.ffi
kernel_rfl bodyNN6 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s74.ffi).nnext PRE_first_tail_x6_r0_body.P6.NL = true
kernel_rfl bodyXn6 : Nat.ble (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s76.ffi).next = true
kernel_rfl bodyLo6 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s76.ffi).next = true
theorem bodyFacts6 : BodySiteFacts PRE_first_tail_x6_r0_body.s74 PRE_first_tail_x6_r0_body.s75 PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S74 PRE_first_tail_x6_r0_body.S75 PRE_first_tail_x6_r0_body.S76
    PRE_first_tail_x6_r0_body.ws6 PRE_first_tail_x6_r0_body.cws6 PRE_first_tail_x6_r0_body.nr6 PRE_first_tail_x6_r0_body.pl6 PRE_first_tail_x6_r0_body.cl6 2681128 359 PRE_first_tail_x6_r0_body.kd6 PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.P6
    ⟨18330, 15404, 2679973, 341⟩ ⟨18333, 15431, 2679979, 359⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap6
  clean := bodyClean6
  cfix := PRE_first_tail_x6_r0_body.cfix6
  zpl := PRE_first_tail_x6_r0_body.zpl6
  zplnd := PRE_first_tail_x6_r0_body.zplnd6
  zn1 := PRE_first_tail_x6_r0_body.zn16
  zfirst := PRE_first_tail_x6_r0_body.zfirst6
  zscn := PRE_first_tail_x6_r0_body.zscn6
  zsmn := PRE_first_tail_x6_r0_body.zsmn6
  zgrow := PRE_first_tail_x6_r0_body.zgrow6
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab6
  zfresh := PRE_first_tail_x6_r0_body.zfresh6
  zcnd := PRE_first_tail_x6_r0_body.zcnd6
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi6
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt6
  zgP := PRE_first_tail_x6_r0_body.zg6_2665
  zkP := PRE_first_tail_x6_r0_body.zk6_2665
  zmP := PRE_first_tail_x6_r0_body.zm6_2665
  zgC := PRE_first_tail_x6_r0_body.zg6_2673467
  zkC := PRE_first_tail_x6_r0_body.zk6_2673467
  zmC := PRE_first_tail_x6_r0_body.zm6_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw6_2673472
  zwV := PRE_first_tail_x6_r0_body.zw6_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap6
  zclbd := PRE_first_tail_x6_r0_body.zclbd6
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap6 PRE_first_tail_x6_r0_body.stFoot6 PRE_first_tail_x6_r0_body.iso6 PRE_first_tail_x6_r0_body.zwr6
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP6
  csupp := PRE_first_tail_x6_r0_body.csupp6
  cbound := PRE_first_tail_x6_r0_body.cbound6
  zimg := PRE_first_tail_x6_r0_body.zimg6
  zctl := PRE_first_tail_x6_r0_body.zctl6
  zstack := PRE_first_tail_x6_r0_body.zstack6
  zjobs := PRE_first_tail_x6_r0_body.zjobs6
  zstores := PRE_first_tail_x6_r0_body.zstores6
  zroots := PRE_first_tail_x6_r0_body.zroots6
  znC := PRE_first_tail_x6_r0_body.znC6
  ctab := PRE_first_tail_x6_r0_body.ctab6
  zbin := PRE_first_tail_x6_r0_body.zbin6
  cbridge := PRE_first_tail_x6_r0_body.cbridge6
  sbridge := bodyBridge6
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj6
  cshiftR := fun h hNL => bodyCshift6 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN6
  raised := PRE_first_tail_x6_r0_body.raised6
  cbigs := PRE_first_tail_x6_r0_body.cbigs6
  cjcl := PRE_first_tail_x6_r0_body.cjcl6
  xnLe := Nat.le_of_ble_eq_true bodyXn6
  loLe := Nat.le_of_ble_eq_true bodyLo6
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB6
  cntM := bodyCntM6
  hiLe := Nat.le_of_ble_eq_true bodyHi6
  nhiLe := Nat.le_of_ble_eq_true bodyNhi6
  jsHeap := bodyJs6
  jsRoots := bodyJsRoots6
  jsNative := bodyJsNative6
  framesEmpty := bodyFramesEmpty6
  trailOld := by decide
  lowVars := bodyLow6

def bodyQs6 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs6 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr6.map fun r => nth? PRE_first_tail_x6_r0_body.st6.S5.tab r
kernel_rfl bodyResChk6 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs6 bodyQs6) = true
kernel_rfl bodyLq6 : bodyQs6.length = PRE_first_tail_x6_r0_body.cws6.length
kernel_rfl bodyNrLo6 : PRE_first_tail_x6_r0_body.nr6.all (Nat.ble PRE_first_tail_x6_r0_body.S74.tab.length) = true
kernel_rfl bodySub6 : (Oracles.PRE_first_tail_x6_r0_body.map_site6.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost6 : postSubB bodyM PRE_first_tail_x6_r0_body.ws6 PRE_first_tail_x6_r0_body.cws6 bodyQs6 = true
kernel_rfl bodyDrop6 : Nat.ble (6445 + (PRE_first_tail_x6_r0_body.s75.next - PRE_first_tail_x6_r0_body.s76.next)) 7594 = true
kernel_rfl bodyDropH6 : Nat.ble (71 + ((mlxOf PRE_first_tail_x6_r0_body.s75.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s76.ffi).next)) 96 = true
kernel_rfl bodyDropN6 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s75.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s76.ffi).nnext)) 0 = true
kernel_rfl bodyDv6 : bodyΘ.1.take 54 = bodyΘ.1.take 36 ++ PRE_first_tail_x6_r0_body.cws6
kernel_rfl bodyDe6 : bodyΘ.2.take 54 = bodyΘ.2.take 36 ++ PRE_first_tail_x6_r0_body.nr6.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st6.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 36) (bodyΘ.2.take 36)))
kernel_rfl bodyDl6 : (bodyΘ.1.take 36).length = (bodyΘ.2.take 36).length
kernel_rfl bodyDold6 : (bodyΘ.1.take 36).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws6).isNone && !PRE_first_tail_x6_r0_body.ws6.contains v) = true
kernel_rfl bodyDfree6 : (bodyΘ.2.take 54).all (fun e => (PRE_first_tail_x6_r0_body.cws6 ++ PRE_first_tail_x6_r0_body.ws6).all fun w => e.noVar w) = true

theorem bodyStep6 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6445, 71, 0, 36⟩ bodyM PRE_first_tail_x6_r0_body.s74 PRE_first_tail_x6_r0_body.S74)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7594, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.S76) (11334 + 1) :=
  bodySite bodyFacts6.cfix bodyFacts6.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x6_r0_body.st6.S5.tab) (Es := bodyEs6) (qs := bodyQs6)
    (ok := PRE_first_tail_x6_r0_body.st6.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site6 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts6
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site6 r hr) hi (MapOk.sub hm (sub_of_all bodySub6)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk6 r hr) hi hm ho hq)
    bodyLq6 rfl bodyNrLo6 (postSub_sound bodyPost6)
    (Nat.le_of_ble_eq_true bodyDrop6) (by decide) (Nat.le_of_ble_eq_true bodyDropH6) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN6) (by decide)
    bodyDv6 bodyDe6 bodyDl6 bodyDold6 bodyDfree6 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodySite7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x6_r0_body.map_site7 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n), (1091, Q.n), (1092, Q.n), (1094, Q.n), (1095, Q.n), (1096, Q.n), (1097, Q.n), (1098, Q.n), (1101, Q.n), (1102, Q.n), (1104, Q.n), (1105, Q.n), (1106, Q.n), (1107, Q.n), (1108, Q.n), (1145, Q.n), (1146, Q.n), (1148, Q.n), (1149, Q.n), (1150, Q.n), (1151, Q.n), (1152, Q.n), (1155, Q.n), (1156, Q.n), (1158, Q.n), (1159, Q.n), (1160, Q.n), (1161, Q.n), (1162, Q.n)]

kernel_rfl PRE_first_tail_x6_r0_body.chk_site7 : ([first_tail_x6.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x6_r0_body.map_site7) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st7.S0.oracle) = true

noncomputable def PRE_first_tail_x6_r0_body.site7
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s82 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.s83 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S82 Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws7 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st7.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st7.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.iso7
  tab := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_7
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st7.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.stFoot7
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrNodup7
  bound := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.wrBound7
  trace := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.trace7
  merged := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.merged7
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.ws7.length = (Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.st7.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.S82.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.tab0_7]
    exact Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.mergeLen7.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x6_r0_body.fresh7
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl7 : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx :=
  PRE_first_tail_x6_r0_body.gncl7 (PRE_first_tail_x6_r0_body.cncl6 bodyNcl6)

theorem bodyClean7 : Conv.JClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s82 :=
  PRE_first_tail_x6_r0_body.gjcl7 (PRE_first_tail_x6_r0_body.cjcl6 bodyClean6)

kernel_rfl bodyJsLe7 : Nat.ble PRE_first_tail_x6_r0_body.s74.next PRE_first_tail_x6_r0_body.s82.next = true
kernel_rfl bodyJsList7 : (PRE_first_tail_x6_r0_body.gjh7 ++ PRE_first_tail_x6_r0_body.cl7).all (noBigAtP (jsAboveB PRE_first_tail_x6_r0_body.s82.next) PRE_first_tail_x6_r0_body.s84) = true
theorem bodyJs7 : JsHeapAbove PRE_first_tail_x6_r0_body.s82.next PRE_first_tail_x6_r0_body.s84 :=
  JsHeapAbove.glueSite bodyJs6 (Nat.le_of_ble_eq_true bodyJsLe7) PRE_first_tail_x6_r0_body.gjk7 PRE_first_tail_x6_r0_body.gjbd7 PRE_first_tail_x6_r0_body.cheap7 PRE_first_tail_x6_r0_body.zclbd7 bodyJsList7

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyG7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO76 : PRE_first_tail_x6_r0_body.S76.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S76.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr76 : bridgeOf PRE_first_tail_x6_r0_body.s76.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyAcc76 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.S76) = fun _ _ => true
kernel_rfl bodyAcc77 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s77 PRE_first_tail_x6_r0_body.S77) = fun _ _ => true
kernel_rfl bodyBr78 : bridgeOf PRE_first_tail_x6_r0_body.s78.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt77 : isHalt PRE_first_tail_x6_r0_body.s77.ctl = false
kernel_rfl bodyTop78 : noRetBlock PRE_first_tail_x6_r0_body.s78 = true
kernel_rfl bodyCnt76 : countersOkB PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.s78 = true
kernel_rfl bodyO78 : PRE_first_tail_x6_r0_body.S78.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S78.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyBr79 : bridgeOf PRE_first_tail_x6_r0_body.s79.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyCnt78 : countersOkB PRE_first_tail_x6_r0_body.s78 PRE_first_tail_x6_r0_body.s79 = true
kernel_rfl bodyO79 : PRE_first_tail_x6_r0_body.S79.oracle = List.drop (PRE_first_tail_x6_r0_body.OR.length - PRE_first_tail_x6_r0_body.S79.oracle.length) PRE_first_tail_x6_r0_body.OR
kernel_rfl bodyAcc79 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s79 PRE_first_tail_x6_r0_body.S79) = fun _ _ => true
kernel_rfl bodyAcc81 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x6_r0_body.s81 PRE_first_tail_x6_r0_body.S81) = fun _ _ => true
kernel_rfl bodyBr82 : bridgeOf PRE_first_tail_x6_r0_body.s82.ffi = bridgeOf PRE_first_tail_x6_r0_body.s0.ffi
kernel_rfl bodyHalt81 : isHalt PRE_first_tail_x6_r0_body.s81.ctl = false
kernel_rfl bodyTop82 : noRetBlock PRE_first_tail_x6_r0_body.s82 = true
kernel_rfl bodyCnt79 : countersOkB PRE_first_tail_x6_r0_body.s79 PRE_first_tail_x6_r0_body.s82 = true

theorem bodyGlue7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7594, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.S76)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7594, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s82 PRE_first_tail_x6_r0_body.S82) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7594, 96, 0, 54⟩) bodyAcc76 PRE_first_tail_x6_r0_body.bodyRunSeg21 bodyAcc77 bodyHalt77 PRE_first_tail_x6_r0_body.bodyStepA22 bodyTop78 (fun _ hm => bodyO76 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr76).trans bodyInactive0) (bodyBr78.trans bodyBr76.symm) bodyCnt76 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7594, 96, 0, 54⟩) PRE_first_tail_x6_r0_body.sizeA22 PRE_first_tail_x6_r0_body.sizeArgsA22 PRE_first_tail_x6_r0_body.sizeSymA22 PRE_first_tail_x6_r0_body.sizeMlxA22 PRE_first_tail_x6_r0_body.sizePayA22 PRE_first_tail_x6_r0_body.sizeTaA22 PRE_first_tail_x6_r0_body.sizeDecA22 PRE_first_tail_x6_r0_body.sizePreA22 PRE_first_tail_x6_r0_body.bodyPatchB22 (fun _ hm => bodyO78 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr78).trans bodyInactive0) (bodyBr79.trans bodyBr78.symm) bodyCnt78 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7594, 96, 0, 54⟩) bodyAcc79 PRE_first_tail_x6_r0_body.bodyRunSeg22 bodyAcc81 bodyHalt81 PRE_first_tail_x6_r0_body.bodyStepA23 bodyTop82 (fun _ hm => bodyO79 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr79).trans bodyInactive0) (bodyBr82.trans bodyBr79.symm) bodyCnt79 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW6

end

section -- VWBodyS7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift7 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x6_r0_body.S82.tab.length PRE_first_tail_x6_r0_body.s82.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x6_r0_body.P7.NL) : Conv.FullShiftQ PRE_first_tail_x6_r0_body.P7 380 PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.s84.ffi PRE_first_tail_x6_r0_body.s83.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x6_r0_body.ofxC_7
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x6_r0_body.okrC_7
  have hcl : SSt (· < 380) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x6_r0_body.S82.tab.length) hr.cl (by rw [PRE_first_tail_x6_r0_body.n0_7] <;> decide) PRE_first_tail_x6_r0_body.cnodesK7 PRE_first_tail_x6_r0_body.cobjsK7
      PRE_first_tail_x6_r0_body.citemsK7 PRE_first_tail_x6_r0_body.cbd7 PRE_first_tail_x6_r0_body.csst7
  exact PRE_first_tail_x6_r0_body.cshift7 bodyNcl7 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x6_r0_body.n0_7] at this; exact this)


kernel_rfl bodyFramesEmpty7 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x6_r0_body.s83 a).isEmpty) = true
kernel_rfl bodyJsRoots7 : noBigRootsP (jsAboveB PRE_first_tail_x6_r0_body.s82.next) PRE_first_tail_x6_r0_body.s84.trace PRE_first_tail_x6_r0_body.s84 = true
kernel_rfl bodyJsNative7 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x6_r0_body.s84.ffi) = true
kernel_rfl bodyLow7 : (PRE_first_tail_x6_r0_body.cws7 ++ PRE_first_tail_x6_r0_body.ws7).all (Nat.ble 9) = true
kernel_rfl bodyCntM7 : countersOkB PRE_first_tail_x6_r0_body.s82 PRE_first_tail_x6_r0_body.s83 = true
kernel_rfl bodyHi7 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s84.ffi).next setupP.E = true
kernel_rfl bodyNhi7 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s84.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge7 : bridgeOf PRE_first_tail_x6_r0_body.s83.ffi = bridgeOf PRE_first_tail_x6_r0_body.s82.ffi
kernel_rfl bodyNN7 : Nat.ble (mlxOf PRE_first_tail_x6_r0_body.s82.ffi).nnext PRE_first_tail_x6_r0_body.P7.NL = true
kernel_rfl bodyXn7 : Nat.ble (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x6_r0_body.s84.ffi).next = true
kernel_rfl bodyLo7 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x6_r0_body.s84.ffi).next = true
theorem bodyFacts7 : BodySiteFacts PRE_first_tail_x6_r0_body.s82 PRE_first_tail_x6_r0_body.s83 PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.s0 PRE_first_tail_x6_r0_body.S82 PRE_first_tail_x6_r0_body.S83 PRE_first_tail_x6_r0_body.S84
    PRE_first_tail_x6_r0_body.ws7 PRE_first_tail_x6_r0_body.cws7 PRE_first_tail_x6_r0_body.nr7 PRE_first_tail_x6_r0_body.pl7 PRE_first_tail_x6_r0_body.cl7 2680471 380 PRE_first_tail_x6_r0_body.kd7 PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.P7
    ⟨18346, 15444, 2680469, 380⟩ ⟨18346, 15444, 2680469, 380⟩ where
  zkap := PRE_first_tail_x6_r0_body.zkap7
  clean := bodyClean7
  cfix := PRE_first_tail_x6_r0_body.cfix7
  zpl := PRE_first_tail_x6_r0_body.zpl7
  zplnd := PRE_first_tail_x6_r0_body.zplnd7
  zn1 := PRE_first_tail_x6_r0_body.zn17
  zfirst := PRE_first_tail_x6_r0_body.zfirst7
  zscn := PRE_first_tail_x6_r0_body.zscn7
  zsmn := PRE_first_tail_x6_r0_body.zsmn7
  zgrow := PRE_first_tail_x6_r0_body.zgrow7
  mergeTab := PRE_first_tail_x6_r0_body.mergeTab7
  zfresh := PRE_first_tail_x6_r0_body.zfresh7
  zcnd := PRE_first_tail_x6_r0_body.zcnd7
  lenc := by rfl
  znrHi := PRE_first_tail_x6_r0_body.znrHi7
  zfrlt := PRE_first_tail_x6_r0_body.zfrlt7
  zgP := PRE_first_tail_x6_r0_body.zg7_2665
  zkP := PRE_first_tail_x6_r0_body.zk7_2665
  zmP := PRE_first_tail_x6_r0_body.zm7_2665
  zgC := PRE_first_tail_x6_r0_body.zg7_2673467
  zkC := PRE_first_tail_x6_r0_body.zk7_2673467
  zmC := PRE_first_tail_x6_r0_body.zm7_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x6_r0_body.zw7_2673472
  zwV := PRE_first_tail_x6_r0_body.zw7_2673473
  cheap := PRE_first_tail_x6_r0_body.cheap7
  zclbd := PRE_first_tail_x6_r0_body.zclbd7
  hml := hoff_of PRE_first_tail_x6_r0_body.mheap7 PRE_first_tail_x6_r0_body.stFoot7 PRE_first_tail_x6_r0_body.iso7 PRE_first_tail_x6_r0_body.zwr7
  ckeepP := PRE_first_tail_x6_r0_body.ckeepP7
  csupp := PRE_first_tail_x6_r0_body.csupp7
  cbound := PRE_first_tail_x6_r0_body.cbound7
  zimg := PRE_first_tail_x6_r0_body.zimg7
  zctl := PRE_first_tail_x6_r0_body.zctl7
  zstack := PRE_first_tail_x6_r0_body.zstack7
  zjobs := PRE_first_tail_x6_r0_body.zjobs7
  zstores := PRE_first_tail_x6_r0_body.zstores7
  zroots := PRE_first_tail_x6_r0_body.zroots7
  znC := PRE_first_tail_x6_r0_body.znC7
  ctab := PRE_first_tail_x6_r0_body.ctab7
  zbin := PRE_first_tail_x6_r0_body.zbin7
  cbridge := PRE_first_tail_x6_r0_body.cbridge7
  sbridge := bodyBridge7
  cwsDisj := PRE_first_tail_x6_r0_body.cwsDisj7
  cshiftR := fun h hNL => bodyCshift7 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN7
  raised := PRE_first_tail_x6_r0_body.raised7
  cbigs := PRE_first_tail_x6_r0_body.cbigs7
  cjcl := PRE_first_tail_x6_r0_body.cjcl7
  xnLe := Nat.le_of_ble_eq_true bodyXn7
  loLe := Nat.le_of_ble_eq_true bodyLo7
  zroots2 := PRE_first_tail_x6_r0_body.zrootsB7
  cntM := bodyCntM7
  hiLe := Nat.le_of_ble_eq_true bodyHi7
  nhiLe := Nat.le_of_ble_eq_true bodyNhi7
  jsHeap := bodyJs7
  jsRoots := bodyJsRoots7
  jsNative := bodyJsNative7
  framesEmpty := bodyFramesEmpty7
  trailOld := by decide
  lowVars := bodyLow7

def bodyQs7 : List (Option Q) := []
noncomputable def bodyEs7 : List (Option SymE) := PRE_first_tail_x6_r0_body.nr7.map fun r => nth? PRE_first_tail_x6_r0_body.st7.S2.tab r
kernel_rfl bodyResChk7 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs7 bodyQs7) = true
kernel_rfl bodyLq7 : bodyQs7.length = PRE_first_tail_x6_r0_body.cws7.length
kernel_rfl bodyNrLo7 : PRE_first_tail_x6_r0_body.nr7.all (Nat.ble PRE_first_tail_x6_r0_body.S82.tab.length) = true
kernel_rfl bodySub7 : (Oracles.PRE_first_tail_x6_r0_body.map_site7.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost7 : postSubB bodyM PRE_first_tail_x6_r0_body.ws7 PRE_first_tail_x6_r0_body.cws7 bodyQs7 = true
kernel_rfl bodyDrop7 : Nat.ble (7594 + (PRE_first_tail_x6_r0_body.s83.next - PRE_first_tail_x6_r0_body.s84.next)) 7596 = true
kernel_rfl bodyDropH7 : Nat.ble (96 + ((mlxOf PRE_first_tail_x6_r0_body.s83.ffi).next - (mlxOf PRE_first_tail_x6_r0_body.s84.ffi).next)) 96 = true
kernel_rfl bodyDropN7 : Nat.ble (0 + ((mlxOf PRE_first_tail_x6_r0_body.s83.ffi).nnext - (mlxOf PRE_first_tail_x6_r0_body.s84.ffi).nnext)) 0 = true
kernel_rfl bodyDv7 : bodyΘ.1.take 54 = bodyΘ.1.take 54 ++ PRE_first_tail_x6_r0_body.cws7
kernel_rfl bodyDe7 : bodyΘ.2.take 54 = bodyΘ.2.take 54 ++ PRE_first_tail_x6_r0_body.nr7.map (fun r =>
  ((nth? PRE_first_tail_x6_r0_body.st7.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 54) (bodyΘ.2.take 54)))
kernel_rfl bodyDl7 : (bodyΘ.1.take 54).length = (bodyΘ.2.take 54).length
kernel_rfl bodyDold7 : (bodyΘ.1.take 54).all (fun v => (Conv.idx? v PRE_first_tail_x6_r0_body.cws7).isNone && !PRE_first_tail_x6_r0_body.ws7.contains v) = true
kernel_rfl bodyDfree7 : (bodyΘ.2.take 54).all (fun e => (PRE_first_tail_x6_r0_body.cws7 ++ PRE_first_tail_x6_r0_body.ws7).all fun w => e.noVar w) = true

theorem bodyStep7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7594, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s82 PRE_first_tail_x6_r0_body.S82)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7596, 96, 0, 54⟩ bodyM PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.S84) (27 + 1) :=
  bodySite bodyFacts7.cfix bodyFacts7.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x6_r0_body.st7.S2.tab) (Es := bodyEs7) (qs := bodyQs7)
    (ok := PRE_first_tail_x6_r0_body.st7.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x6_r0_body.site7 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts7
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x6_r0_body.chk_site7 r hr) hi (MapOk.sub hm (sub_of_all bodySub7)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk7 r hr) hi hm ho hq)
    bodyLq7 rfl bodyNrLo7 (postSub_sound bodyPost7)
    (Nat.le_of_ble_eq_true bodyDrop7) (by decide) (Nat.le_of_ble_eq_true bodyDropH7) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN7) (by decide)
    bodyDv7 bodyDe7 bodyDl7 bodyDold7 bodyDfree7 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW6

end
