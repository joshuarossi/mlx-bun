import host.sim.compose.a4b.vw15.VWBodyJ188
import host.sim.compose.a4b.vw15.VWBodySite188
import host.sim.compose.a4b.vw15.VWBodyOracles_47
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift188 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1811.tab.length PRE_first_tail_x15_r0_body.s1811.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P188.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P188 8092 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.s1813.ffi PRE_first_tail_x15_r0_body.s1812.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_188
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_188
  have hcl : SSt (· < 8092) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1811.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_188] <;> decide) PRE_first_tail_x15_r0_body.cnodesK188 PRE_first_tail_x15_r0_body.cobjsK188
      PRE_first_tail_x15_r0_body.citemsK188 PRE_first_tail_x15_r0_body.cbd188 PRE_first_tail_x15_r0_body.csst188
  exact PRE_first_tail_x15_r0_body.cshift188 bodyNcl188 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_188] at this; exact this)


kernel_rfl bodyFramesEmpty188 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1812 a).isEmpty) = true
kernel_rfl bodyJsRoots188 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1811.next) PRE_first_tail_x15_r0_body.s1813.trace PRE_first_tail_x15_r0_body.s1813 = true
kernel_rfl bodyJsNative188 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1813.ffi) = true
kernel_rfl bodyLow188 : (PRE_first_tail_x15_r0_body.cws188 ++ PRE_first_tail_x15_r0_body.ws188).all (Nat.ble 9) = true
kernel_rfl bodyCntM188 : countersOkB PRE_first_tail_x15_r0_body.s1811 PRE_first_tail_x15_r0_body.s1812 = true
kernel_rfl bodyHi188 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1813.ffi).next setupP.E = true
kernel_rfl bodyNhi188 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1813.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge188 : bridgeOf PRE_first_tail_x15_r0_body.s1812.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1811.ffi
kernel_rfl bodyNN188 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1811.ffi).nnext PRE_first_tail_x15_r0_body.P188.NL = true
kernel_rfl bodyXn188 : Nat.ble (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1813.ffi).next = true
kernel_rfl bodyLo188 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1813.ffi).next = true
theorem bodyFacts188 : BodySiteFacts PRE_first_tail_x15_r0_body.s1811 PRE_first_tail_x15_r0_body.s1812 PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1811 PRE_first_tail_x15_r0_body.S1812 PRE_first_tail_x15_r0_body.S1813
    PRE_first_tail_x15_r0_body.ws188 PRE_first_tail_x15_r0_body.cws188 PRE_first_tail_x15_r0_body.nr188 PRE_first_tail_x15_r0_body.pl188 PRE_first_tail_x15_r0_body.cl188 2822042 8092 PRE_first_tail_x15_r0_body.kd188 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.P188
    ⟨21893, 19003, 2822031, 8092⟩ ⟨21893, 19003, 2822032, 8092⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap188
  clean := bodyClean188
  cfix := PRE_first_tail_x15_r0_body.cfix188
  zpl := PRE_first_tail_x15_r0_body.zpl188
  zplnd := PRE_first_tail_x15_r0_body.zplnd188
  zn1 := PRE_first_tail_x15_r0_body.zn1188
  zfirst := PRE_first_tail_x15_r0_body.zfirst188
  zscn := PRE_first_tail_x15_r0_body.zscn188
  zsmn := PRE_first_tail_x15_r0_body.zsmn188
  zgrow := PRE_first_tail_x15_r0_body.zgrow188
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab188
  zfresh := PRE_first_tail_x15_r0_body.zfresh188
  zcnd := PRE_first_tail_x15_r0_body.zcnd188
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi188
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt188
  zgP := PRE_first_tail_x15_r0_body.zg188_2665
  zkP := PRE_first_tail_x15_r0_body.zk188_2665
  zmP := PRE_first_tail_x15_r0_body.zm188_2665
  zgC := PRE_first_tail_x15_r0_body.zg188_2673467
  zkC := PRE_first_tail_x15_r0_body.zk188_2673467
  zmC := PRE_first_tail_x15_r0_body.zm188_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw188_2673472
  zwV := PRE_first_tail_x15_r0_body.zw188_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap188
  zclbd := PRE_first_tail_x15_r0_body.zclbd188
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap188 PRE_first_tail_x15_r0_body.stFoot188 PRE_first_tail_x15_r0_body.iso188 PRE_first_tail_x15_r0_body.zwr188
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP188
  csupp := PRE_first_tail_x15_r0_body.csupp188
  cbound := PRE_first_tail_x15_r0_body.cbound188
  zimg := PRE_first_tail_x15_r0_body.zimg188
  zctl := PRE_first_tail_x15_r0_body.zctl188
  zstack := PRE_first_tail_x15_r0_body.zstack188
  zjobs := PRE_first_tail_x15_r0_body.zjobs188
  zstores := PRE_first_tail_x15_r0_body.zstores188
  zroots := PRE_first_tail_x15_r0_body.zroots188
  znC := PRE_first_tail_x15_r0_body.znC188
  ctab := PRE_first_tail_x15_r0_body.ctab188
  zbin := PRE_first_tail_x15_r0_body.zbin188
  cbridge := PRE_first_tail_x15_r0_body.cbridge188
  sbridge := bodyBridge188
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj188
  cshiftR := fun h hNL => bodyCshift188 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN188
  raised := PRE_first_tail_x15_r0_body.raised188
  cbigs := PRE_first_tail_x15_r0_body.cbigs188
  cjcl := PRE_first_tail_x15_r0_body.cjcl188
  xnLe := Nat.le_of_ble_eq_true bodyXn188
  loLe := Nat.le_of_ble_eq_true bodyLo188
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB188
  cntM := bodyCntM188
  hiLe := Nat.le_of_ble_eq_true bodyHi188
  nhiLe := Nat.le_of_ble_eq_true bodyNhi188
  jsHeap := bodyJs188
  jsRoots := bodyJsRoots188
  jsNative := bodyJsNative188
  framesEmpty := bodyFramesEmpty188
  trailOld := by decide
  lowVars := bodyLow188

def bodyQs188 : List (Option Q) := []
noncomputable def bodyEs188 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr188.map fun r => nth? PRE_first_tail_x15_r0_body.st188.S2.tab r
kernel_rfl bodyResChk188 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs188 bodyQs188) = true
kernel_rfl bodyLq188 : bodyQs188.length = PRE_first_tail_x15_r0_body.cws188.length
kernel_rfl bodyNrLo188 : PRE_first_tail_x15_r0_body.nr188.all (Nat.ble PRE_first_tail_x15_r0_body.S1811.tab.length) = true
kernel_rfl bodySub188 : (Oracles.PRE_first_tail_x15_r0_body.map_site188.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost188 : postSubB bodyM PRE_first_tail_x15_r0_body.ws188 PRE_first_tail_x15_r0_body.cws188 bodyQs188 = true
kernel_rfl bodyDrop188 : Nat.ble (65478 + (PRE_first_tail_x15_r0_body.s1812.next - PRE_first_tail_x15_r0_body.s1813.next)) 65488 = true
kernel_rfl bodyDropH188 : Nat.ble (1251 + ((mlxOf PRE_first_tail_x15_r0_body.s1812.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1813.ffi).next)) 1251 = true
kernel_rfl bodyDropN188 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1812.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1813.ffi).nnext)) 0 = true
kernel_rfl bodyDv188 : bodyΘ.1.take 999 = bodyΘ.1.take 999 ++ PRE_first_tail_x15_r0_body.cws188
kernel_rfl bodyDe188 : bodyΘ.2.take 999 = bodyΘ.2.take 999 ++ PRE_first_tail_x15_r0_body.nr188.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st188.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 999) (bodyΘ.2.take 999)))
kernel_rfl bodyDl188 : (bodyΘ.1.take 999).length = (bodyΘ.2.take 999).length
kernel_rfl bodyDold188 : (bodyΘ.1.take 999).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws188).isNone && !PRE_first_tail_x15_r0_body.ws188.contains v) = true
kernel_rfl bodyDfree188 : (bodyΘ.2.take 999).all (fun e => (PRE_first_tail_x15_r0_body.cws188 ++ PRE_first_tail_x15_r0_body.ws188).all fun w => e.noVar w) = true

theorem bodyStep188 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65478, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1811 PRE_first_tail_x15_r0_body.S1811)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65488, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.S1813) (98 + 1) :=
  bodySite bodyFacts188.cfix bodyFacts188.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st188.S2.tab) (Es := bodyEs188) (qs := bodyQs188)
    (ok := PRE_first_tail_x15_r0_body.st188.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site188 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts188
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site188 r hr) hi (MapOk.sub hm (sub_of_all bodySub188)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk188 r hr) hi hm ho hq)
    bodyLq188 rfl bodyNrLo188 (postSub_sound bodyPost188)
    (Nat.le_of_ble_eq_true bodyDrop188) (by decide) (Nat.le_of_ble_eq_true bodyDropH188) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN188) (by decide)
    bodyDv188 bodyDe188 bodyDl188 bodyDold188 bodyDfree188 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
