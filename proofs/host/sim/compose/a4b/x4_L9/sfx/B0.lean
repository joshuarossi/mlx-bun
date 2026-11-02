import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.States
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B2
import host.sim.compose.a4b.x4_L9.sfx.VWBodyChain
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B3
import host.sim.compose.a4b.VWBodyLit
import host.sim.compose.a4b.x4_L9.sfx.VWBodyMap
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B1
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B0
import host.sim.template.CallGen

section -- VWBodyOracles_0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_suffix.map_g3d_first : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_suffix.chk_g3d_first : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_suffix.map_g3d_first) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.O))) = true

def PRE_first_tail_x4_L9_r0_suffix.map_site0 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_suffix.chk_site0 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_suffix.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_suffix.map_g4_pf_first : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_suffix.chk_g4_pf_first : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_suffix.map_g4_pf_first) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.O))) = true


end Host.Ts.Sim.Compose.Oracles

end

section -- VWBodySite0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_suffix.map_site0 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_suffix.chk_site0 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_suffix.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_suffix.site0
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.s2 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.s3 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.S2 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.ws0 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.iso0
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.stFoot0
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.wrNodup0
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.wrBound0
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.trace0
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.merged0
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.ws0.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.S2.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.tab0_0]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.mergeLen0.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose

end

section -- VWBodyJ0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl0 : Conv.NClean (⟨22174, 19265, 2834708, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_suffix.s2.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_suffix.gncl0 PRE_first_tail_x4_L9_r0_suffix.ncl0

theorem bodyClean0 : Conv.JClean (⟨22174, 19265, 2834708, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_suffix.s2 :=
  PRE_first_tail_x4_L9_r0_suffix.gjcl0 bodyStartClean

kernel_rfl bodyJsLe0 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1416.next PRE_first_tail_x4_L9_r0_suffix.s2.next = true
kernel_rfl bodyJsList0 : (PRE_first_tail_x4_L9_r0_suffix.gjh0 ++ PRE_first_tail_x4_L9_r0_suffix.cl0).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_suffix.s2.next) PRE_first_tail_x4_L9_r0_suffix.s4) = true
theorem bodyJs0 : JsHeapAbove PRE_first_tail_x4_L9_r0_suffix.s2.next PRE_first_tail_x4_L9_r0_suffix.s4 :=
  JsHeapAbove.glueSite bodyStartJs (Nat.le_of_ble_eq_true bodyJsLe0) PRE_first_tail_x4_L9_r0_suffix.gjk0 PRE_first_tail_x4_L9_r0_suffix.gjbd0 PRE_first_tail_x4_L9_r0_suffix.cheap0 PRE_first_tail_x4_L9_r0_suffix.zclbd0 bodyJsList0

end Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx

end

section -- VWBodyG0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO0 : PRE_first_tail_x4_L9_r0_suffix.S0.oracle = List.drop (PRE_first_tail_x4_L9_r0_suffix.O.length - PRE_first_tail_x4_L9_r0_suffix.S0.oracle.length) PRE_first_tail_x4_L9_r0_suffix.O
kernel_rfl bodyBr0 : bridgeOf PRE_first_tail_x4_L9_r0_suffix.s0.ffi = bridgeOf PRE_first_tail_x4_L9_r0_suffix.s0.ffi
kernel_rfl bodyAcc0 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_suffix.s0 PRE_first_tail_x4_L9_r0_suffix.S0) = fun _ _ => true
kernel_rfl bodyAcc1 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_suffix.s1 PRE_first_tail_x4_L9_r0_suffix.S1) = fun _ _ => true
kernel_rfl bodyBr2 : bridgeOf PRE_first_tail_x4_L9_r0_suffix.s2.ffi = bridgeOf PRE_first_tail_x4_L9_r0_suffix.s0.ffi
kernel_rfl bodyHalt1 : isHalt PRE_first_tail_x4_L9_r0_suffix.s1.ctl = false
kernel_rfl bodyTop2 : noRetBlock PRE_first_tail_x4_L9_r0_suffix.s2 = true
kernel_rfl bodyCnt0 : countersOkB PRE_first_tail_x4_L9_r0_suffix.s0 PRE_first_tail_x4_L9_r0_suffix.s2 = true

theorem bodyGlue0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_suffix.s0 PRE_first_tail_x4_L9_r0_suffix.S0))
      (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_suffix.s2 PRE_first_tail_x4_L9_r0_suffix.S2)) 132 :=
  (bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := Tr) (O := ⟨64866, 1253, 0, 0⟩) bodyAcc0 PRE_first_tail_x4_L9_r0_suffix.bodyRunSeg0 bodyAcc1 bodyHalt1 PRE_first_tail_x4_L9_r0_suffix.bodyStepA1 bodyTop2 (fun _ hm => bodyO0 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr0).trans bodyInactive0) (bodyBr2.trans bodyBr0.symm) bodyCnt0 hT).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx

end

section -- VWBodyS0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift0 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x4_L9_r0_suffix.S2.tab.length PRE_first_tail_x4_L9_r0_suffix.s2.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x4_L9_r0_suffix.P0.NL) : Conv.FullShiftQ PRE_first_tail_x4_L9_r0_suffix.P0 15 PRE_first_tail_x4_L9_r0_suffix.kappa0 PRE_first_tail_x4_L9_r0_suffix.s4.ffi PRE_first_tail_x4_L9_r0_suffix.s3.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x4_L9_r0_suffix.ofxC_0
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x4_L9_r0_suffix.okrC_0
  have hcl : SSt (· < 15) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_suffix.s4.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x4_L9_r0_suffix.S2.tab.length) hr.cl (by rw [PRE_first_tail_x4_L9_r0_suffix.n0_0] <;> decide) PRE_first_tail_x4_L9_r0_suffix.cnodesK0 PRE_first_tail_x4_L9_r0_suffix.cobjsK0
      PRE_first_tail_x4_L9_r0_suffix.citemsK0 PRE_first_tail_x4_L9_r0_suffix.cbd0 PRE_first_tail_x4_L9_r0_suffix.csst0
  exact PRE_first_tail_x4_L9_r0_suffix.cshift0 bodyNcl0 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x4_L9_r0_suffix.n0_0] at this; exact this)


kernel_rfl bodyFramesEmpty0 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x4_L9_r0_suffix.s3 a).isEmpty) = true
kernel_rfl bodyJsRoots0 : noBigRootsP (jsAboveB PRE_first_tail_x4_L9_r0_suffix.s2.next) PRE_first_tail_x4_L9_r0_suffix.s4.trace PRE_first_tail_x4_L9_r0_suffix.s4 = true
kernel_rfl bodyJsNative0 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x4_L9_r0_suffix.s4.ffi) = true
kernel_rfl bodyLow0 : (PRE_first_tail_x4_L9_r0_suffix.cws0 ++ PRE_first_tail_x4_L9_r0_suffix.ws0).all (Nat.ble 9) = true
kernel_rfl bodyCntM0 : countersOkB PRE_first_tail_x4_L9_r0_suffix.s2 PRE_first_tail_x4_L9_r0_suffix.s3 = true
kernel_rfl bodyHi0 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_suffix.s4.ffi).next setupP.E = true
kernel_rfl bodyNhi0 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_suffix.s4.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge0 : bridgeOf PRE_first_tail_x4_L9_r0_suffix.s3.ffi = bridgeOf PRE_first_tail_x4_L9_r0_suffix.s2.ffi
kernel_rfl bodyNN0 : Nat.ble (mlxOf PRE_first_tail_x4_L9_r0_suffix.s2.ffi).nnext PRE_first_tail_x4_L9_r0_suffix.P0.NL = true
kernel_rfl bodyXn0 : Nat.ble (⟨22174, 19265, 2834708, 15⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x4_L9_r0_suffix.s4.ffi).next = true
kernel_rfl bodyLo0 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x4_L9_r0_suffix.s4.ffi).next = true
theorem bodyFacts0 : BodySiteFacts PRE_first_tail_x4_L9_r0_suffix.s2 PRE_first_tail_x4_L9_r0_suffix.s3 PRE_first_tail_x4_L9_r0_suffix.s4 PRE_first_tail_x4_L9_r0_suffix.s0 PRE_first_tail_x4_L9_r0_suffix.S2 PRE_first_tail_x4_L9_r0_suffix.S3 PRE_first_tail_x4_L9_r0_suffix.S4
    PRE_first_tail_x4_L9_r0_suffix.ws0 PRE_first_tail_x4_L9_r0_suffix.cws0 PRE_first_tail_x4_L9_r0_suffix.nr0 PRE_first_tail_x4_L9_r0_suffix.pl0 PRE_first_tail_x4_L9_r0_suffix.cl0 2837691 15 PRE_first_tail_x4_L9_r0_suffix.kd0 PRE_first_tail_x4_L9_r0_suffix.kappa0 PRE_first_tail_x4_L9_r0_suffix.P0
    ⟨22174, 19265, 2834708, 15⟩ ⟨22174, 19265, 2834708, 15⟩ where
  zkap := PRE_first_tail_x4_L9_r0_suffix.zkap0
  clean := bodyClean0
  cfix := PRE_first_tail_x4_L9_r0_suffix.cfix0
  zpl := PRE_first_tail_x4_L9_r0_suffix.zpl0
  zplnd := PRE_first_tail_x4_L9_r0_suffix.zplnd0
  zn1 := PRE_first_tail_x4_L9_r0_suffix.zn10
  zfirst := PRE_first_tail_x4_L9_r0_suffix.zfirst0
  zscn := PRE_first_tail_x4_L9_r0_suffix.zscn0
  zsmn := PRE_first_tail_x4_L9_r0_suffix.zsmn0
  zgrow := PRE_first_tail_x4_L9_r0_suffix.zgrow0
  mergeTab := PRE_first_tail_x4_L9_r0_suffix.mergeTab0
  zfresh := PRE_first_tail_x4_L9_r0_suffix.zfresh0
  zcnd := PRE_first_tail_x4_L9_r0_suffix.zcnd0
  lenc := by rfl
  znrHi := PRE_first_tail_x4_L9_r0_suffix.znrHi0
  zfrlt := PRE_first_tail_x4_L9_r0_suffix.zfrlt0
  zgP := PRE_first_tail_x4_L9_r0_suffix.zg0_2665
  zkP := PRE_first_tail_x4_L9_r0_suffix.zk0_2665
  zmP := PRE_first_tail_x4_L9_r0_suffix.zm0_2665
  zgC := PRE_first_tail_x4_L9_r0_suffix.zg0_2673467
  zkC := PRE_first_tail_x4_L9_r0_suffix.zk0_2673467
  zmC := PRE_first_tail_x4_L9_r0_suffix.zm0_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x4_L9_r0_suffix.zw0_2673472
  zwV := PRE_first_tail_x4_L9_r0_suffix.zw0_2673473
  cheap := PRE_first_tail_x4_L9_r0_suffix.cheap0
  zclbd := PRE_first_tail_x4_L9_r0_suffix.zclbd0
  hml := hoff_of PRE_first_tail_x4_L9_r0_suffix.mheap0 PRE_first_tail_x4_L9_r0_suffix.stFoot0 PRE_first_tail_x4_L9_r0_suffix.iso0 PRE_first_tail_x4_L9_r0_suffix.zwr0
  ckeepP := PRE_first_tail_x4_L9_r0_suffix.ckeepP0
  csupp := PRE_first_tail_x4_L9_r0_suffix.csupp0
  cbound := PRE_first_tail_x4_L9_r0_suffix.cbound0
  zimg := PRE_first_tail_x4_L9_r0_suffix.zimg0
  zctl := PRE_first_tail_x4_L9_r0_suffix.zctl0
  zstack := PRE_first_tail_x4_L9_r0_suffix.zstack0
  zjobs := PRE_first_tail_x4_L9_r0_suffix.zjobs0
  zstores := PRE_first_tail_x4_L9_r0_suffix.zstores0
  zroots := PRE_first_tail_x4_L9_r0_suffix.zroots0
  znC := PRE_first_tail_x4_L9_r0_suffix.znC0
  ctab := PRE_first_tail_x4_L9_r0_suffix.ctab0
  zbin := PRE_first_tail_x4_L9_r0_suffix.zbin0
  cbridge := PRE_first_tail_x4_L9_r0_suffix.cbridge0
  sbridge := bodyBridge0
  cwsDisj := PRE_first_tail_x4_L9_r0_suffix.cwsDisj0
  cshiftR := fun h hNL => bodyCshift0 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN0
  raised := PRE_first_tail_x4_L9_r0_suffix.raised0
  cbigs := PRE_first_tail_x4_L9_r0_suffix.cbigs0
  cjcl := PRE_first_tail_x4_L9_r0_suffix.cjcl0
  xnLe := Nat.le_of_ble_eq_true bodyXn0
  loLe := Nat.le_of_ble_eq_true bodyLo0
  zroots2 := PRE_first_tail_x4_L9_r0_suffix.zroots20
  cntM := bodyCntM0
  hiLe := Nat.le_of_ble_eq_true bodyHi0
  nhiLe := Nat.le_of_ble_eq_true bodyNhi0
  jsHeap := bodyJs0
  jsRoots := bodyJsRoots0
  jsNative := bodyJsNative0
  framesEmpty := bodyFramesEmpty0
  trailOld := by decide
  lowVars := bodyLow0

def bodyQs0 : List (Option Q) := []
noncomputable def bodyEs0 : List (Option SymE) := PRE_first_tail_x4_L9_r0_suffix.nr0.map fun r => nth? PRE_first_tail_x4_L9_r0_suffix.st0.S5.tab r
kernel_rfl bodyResChk0 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs0 bodyQs0) = true
kernel_rfl bodyLq0 : bodyQs0.length = PRE_first_tail_x4_L9_r0_suffix.cws0.length
kernel_rfl bodyNrLo0 : PRE_first_tail_x4_L9_r0_suffix.nr0.all (Nat.ble PRE_first_tail_x4_L9_r0_suffix.S2.tab.length) = true
kernel_rfl bodySub0 : (Oracles.PRE_first_tail_x4_L9_r0_suffix.map_site0.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost0 : postSubB bodyM PRE_first_tail_x4_L9_r0_suffix.ws0 PRE_first_tail_x4_L9_r0_suffix.cws0 bodyQs0 = true
kernel_rfl bodyDrop0 : Nat.ble (64866 + (PRE_first_tail_x4_L9_r0_suffix.s3.next - PRE_first_tail_x4_L9_r0_suffix.s4.next)) 67849 = true
kernel_rfl bodyDropH0 : Nat.ble (1253 + ((mlxOf PRE_first_tail_x4_L9_r0_suffix.s3.ffi).next - (mlxOf PRE_first_tail_x4_L9_r0_suffix.s4.ffi).next)) 1254 = true
kernel_rfl bodyDropN0 : Nat.ble (0 + ((mlxOf PRE_first_tail_x4_L9_r0_suffix.s3.ffi).nnext - (mlxOf PRE_first_tail_x4_L9_r0_suffix.s4.ffi).nnext)) 0 = true
kernel_rfl bodyDv0 : bodyΘ.1.take 0 = bodyΘ.1.take 0 ++ PRE_first_tail_x4_L9_r0_suffix.cws0
kernel_rfl bodyDe0 : bodyΘ.2.take 0 = bodyΘ.2.take 0 ++ PRE_first_tail_x4_L9_r0_suffix.nr0.map (fun r =>
  ((nth? PRE_first_tail_x4_L9_r0_suffix.st0.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 0) (bodyΘ.2.take 0)))
kernel_rfl bodyDl0 : (bodyΘ.1.take 0).length = (bodyΘ.2.take 0).length
kernel_rfl bodyDold0 : (bodyΘ.1.take 0).all (fun v => (Conv.idx? v PRE_first_tail_x4_L9_r0_suffix.cws0).isNone && !PRE_first_tail_x4_L9_r0_suffix.ws0.contains v) = true
kernel_rfl bodyDfree0 : (bodyΘ.2.take 0).all (fun e => (PRE_first_tail_x4_L9_r0_suffix.cws0 ++ PRE_first_tail_x4_L9_r0_suffix.ws0).all fun w => e.noVar w) = true

kernel_rfl bodyKeepNN0 : PRE_first_tail_x4_L9_r0_suffix.kd0.nn0 = PRE_first_tail_x4_L9_r0_suffix.kd0.nn1
kernel_rfl bodyKeepNK0 : PTrie.keys PRE_first_tail_x4_L9_r0_suffix.kd0.node = []

theorem bodyStep0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨64866, 1253, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_suffix.s2 PRE_first_tail_x4_L9_r0_suffix.S2))
      (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨67849, 1254, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_suffix.s4 PRE_first_tail_x4_L9_r0_suffix.S4)) (31188 + 1) :=
  memSite hT (fun j => by rw [PRE_first_tail_x4_L9_r0_suffix.zkap0]; exact compact_node_id bodyKeepNN0 bodyKeepNK0 j) fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 31188) (S2 := PRE_first_tail_x4_L9_r0_suffix.st0.S5.tab) (Es := bodyEs0) (qs := bodyQs0)
    (ok := PRE_first_tail_x4_L9_r0_suffix.st0.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x4_L9_r0_suffix.site0 bs rows (bodyLitLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyLitGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts0
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x4_L9_r0_suffix.chk_site0 r hr) hi (MapOk.sub hm (sub_of_all bodySub0)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk0 r hr) hi hm ho hq)
    bodyLq0 rfl bodyNrLo0 (postSub_sound bodyPost0)
    (Nat.le_of_ble_eq_true bodyDrop0) (by decide) (Nat.le_of_ble_eq_true bodyDropH0) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN0) (by decide)
    bodyDv0 bodyDe0 bodyDl0 bodyDold0 bodyDfree0 hR hB

end Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx

end

section -- VWBodyG1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO4 : PRE_first_tail_x4_L9_r0_suffix.S4.oracle = List.drop (PRE_first_tail_x4_L9_r0_suffix.O.length - PRE_first_tail_x4_L9_r0_suffix.S4.oracle.length) PRE_first_tail_x4_L9_r0_suffix.O
kernel_rfl bodyBr4 : bridgeOf PRE_first_tail_x4_L9_r0_suffix.s4.ffi = bridgeOf PRE_first_tail_x4_L9_r0_suffix.s0.ffi
kernel_rfl bodyAcc4 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_suffix.s4 PRE_first_tail_x4_L9_r0_suffix.S4) = fun _ _ => true
kernel_rfl bodyAcc5 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_suffix.s5 PRE_first_tail_x4_L9_r0_suffix.S5) = fun _ _ => true
kernel_rfl bodyBr6 : bridgeOf PRE_first_tail_x4_L9_r0_suffix.s6.ffi = bridgeOf PRE_first_tail_x4_L9_r0_suffix.s0.ffi
kernel_rfl bodyHalt5 : isHalt PRE_first_tail_x4_L9_r0_suffix.s5.ctl = false
kernel_rfl bodyTop6 : noRetBlock PRE_first_tail_x4_L9_r0_suffix.s6 = true
kernel_rfl bodyCnt4 : countersOkB PRE_first_tail_x4_L9_r0_suffix.s4 PRE_first_tail_x4_L9_r0_suffix.s6 = true
kernel_rfl bodyO6 : PRE_first_tail_x4_L9_r0_suffix.S6.oracle = List.drop (PRE_first_tail_x4_L9_r0_suffix.O.length - PRE_first_tail_x4_L9_r0_suffix.S6.oracle.length) PRE_first_tail_x4_L9_r0_suffix.O
kernel_rfl bodyBr7 : bridgeOf PRE_first_tail_x4_L9_r0_suffix.s7.ffi = bridgeOf PRE_first_tail_x4_L9_r0_suffix.s0.ffi
kernel_rfl bodyLenSt6 : PRE_first_tail_x4_L9_r0_suffix.s6.stack = .e (.member kLength false) :: PRE_first_tail_x4_L9_r0_suffix.s6.stack.tail
kernel_rfl bodyLenArr6 : arrOf PRE_first_tail_x4_L9_r0_suffix.s6 2665 = []
kernel_rfl bodyCnt6 : countersOkB PRE_first_tail_x4_L9_r0_suffix.s6 PRE_first_tail_x4_L9_r0_suffix.s7 = true
kernel_rfl bodyO7 : PRE_first_tail_x4_L9_r0_suffix.S7.oracle = List.drop (PRE_first_tail_x4_L9_r0_suffix.O.length - PRE_first_tail_x4_L9_r0_suffix.S7.oracle.length) PRE_first_tail_x4_L9_r0_suffix.O
kernel_rfl bodyAcc7 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows PRE_first_tail_x4_L9_r0_suffix.s7 PRE_first_tail_x4_L9_r0_suffix.S7) = fun _ _ => true
kernel_rfl bodyBr8 : bridgeOf PRE_first_tail_x4_L9_r0_suffix.s8.ffi = bridgeOf PRE_first_tail_x4_L9_r0_suffix.s0.ffi
kernel_rfl bodyTop8 : noRetBlock PRE_first_tail_x4_L9_r0_suffix.s8 = true
kernel_rfl bodyCnt7 : countersOkB PRE_first_tail_x4_L9_r0_suffix.s7 PRE_first_tail_x4_L9_r0_suffix.s8 = true

theorem bodyGlue1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨67849, 1254, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_suffix.s4 PRE_first_tail_x4_L9_r0_suffix.S4))
      (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨67849, 1254, 0, 0⟩ bodyM PRE_first_tail_x4_L9_r0_suffix.s8 PRE_first_tail_x4_L9_r0_suffix.S8)) 139 :=
  (((bodyLitToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := Tr) (O := ⟨67849, 1254, 0, 0⟩) bodyAcc4 PRE_first_tail_x4_L9_r0_suffix.bodyRunSeg1 bodyAcc5 bodyHalt5 PRE_first_tail_x4_L9_r0_suffix.bodyStepA2 bodyTop6 (fun _ hm => bodyO4 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr4).trans bodyInactive0) (bodyBr6.trans bodyBr4.symm) bodyCnt4 hT).trans (bodyLen (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := Tr) (O := ⟨67849, 1254, 0, 0⟩) (by simp [bodyM]) PRE_first_tail_x4_L9_r0_suffix.ctlA2 bodyLenSt6 PRE_first_tail_x4_L9_r0_suffix.objA2 (by rw [PRE_first_tail_x4_L9_r0_suffix.kindA2, bodyLenArr6]; rfl) (Option.some.inj PRE_first_tail_x4_L9_r0_suffix.bodyPatchB2) (fun _ hm => bodyO6 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr6).trans bodyInactive0) (bodyBr7.trans bodyBr6.symm) bodyCnt6 hT)).trans (bodyLitGlue (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := Tr) (O := ⟨67849, 1254, 0, 0⟩) bodyAcc7 PRE_first_tail_x4_L9_r0_suffix.bodyRunSeg2 bodyTop8 (fun _ hm => bodyO7 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr7).trans bodyInactive0) (bodyBr8.trans bodyBr7.symm) bodyCnt7 hT)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx

end
