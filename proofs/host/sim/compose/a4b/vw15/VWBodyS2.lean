import host.sim.compose.a4b.vw15.VWBodyJ2
import host.sim.compose.a4b.vw15.VWBodySite2
import host.sim.compose.a4b.vw15.VWBodyOracles_0
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift2 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S28.tab.length PRE_first_tail_x15_r0_body.s28.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P2.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P2 139 PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.s30.ffi PRE_first_tail_x15_r0_body.s29.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_2
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_2
  have hcl : SSt (· < 139) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S28.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_2] <;> decide) PRE_first_tail_x15_r0_body.cnodesK2 PRE_first_tail_x15_r0_body.cobjsK2
      PRE_first_tail_x15_r0_body.citemsK2 PRE_first_tail_x15_r0_body.cbd2 PRE_first_tail_x15_r0_body.csst2
  exact PRE_first_tail_x15_r0_body.cshift2 bodyNcl2 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_2] at this; exact this)


kernel_rfl bodyFramesEmpty2 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s29 a).isEmpty) = true
kernel_rfl bodyJsRoots2 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s28.next) PRE_first_tail_x15_r0_body.s30.trace PRE_first_tail_x15_r0_body.s30 = true
kernel_rfl bodyJsNative2 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s30.ffi) = true
kernel_rfl bodyLow2 : (PRE_first_tail_x15_r0_body.cws2 ++ PRE_first_tail_x15_r0_body.ws2).all (Nat.ble 9) = true
kernel_rfl bodyCntM2 : countersOkB PRE_first_tail_x15_r0_body.s28 PRE_first_tail_x15_r0_body.s29 = true
kernel_rfl bodyHi2 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s30.ffi).next setupP.E = true
kernel_rfl bodyNhi2 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s30.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge2 : bridgeOf PRE_first_tail_x15_r0_body.s29.ffi = bridgeOf PRE_first_tail_x15_r0_body.s28.ffi
kernel_rfl bodyNN2 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s28.ffi).nnext PRE_first_tail_x15_r0_body.P2.NL = true
kernel_rfl bodyXn2 : Nat.ble (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s30.ffi).next = true
kernel_rfl bodyLo2 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s30.ffi).next = true
theorem bodyFacts2 : BodySiteFacts PRE_first_tail_x15_r0_body.s28 PRE_first_tail_x15_r0_body.s29 PRE_first_tail_x15_r0_body.s30 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S28 PRE_first_tail_x15_r0_body.S29 PRE_first_tail_x15_r0_body.S30
    PRE_first_tail_x15_r0_body.ws2 PRE_first_tail_x15_r0_body.cws2 PRE_first_tail_x15_r0_body.nr2 PRE_first_tail_x15_r0_body.pl2 PRE_first_tail_x15_r0_body.cl2 2676073 139 PRE_first_tail_x15_r0_body.kd2 PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.P2
    ⟨18233, 15322, 2676053, 139⟩ ⟨18233, 15322, 2676054, 139⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap2
  clean := bodyClean2
  cfix := PRE_first_tail_x15_r0_body.cfix2
  zpl := PRE_first_tail_x15_r0_body.zpl2
  zplnd := PRE_first_tail_x15_r0_body.zplnd2
  zn1 := PRE_first_tail_x15_r0_body.zn12
  zfirst := PRE_first_tail_x15_r0_body.zfirst2
  zscn := PRE_first_tail_x15_r0_body.zscn2
  zsmn := PRE_first_tail_x15_r0_body.zsmn2
  zgrow := PRE_first_tail_x15_r0_body.zgrow2
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab2
  zfresh := PRE_first_tail_x15_r0_body.zfresh2
  zcnd := PRE_first_tail_x15_r0_body.zcnd2
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi2
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt2
  zgP := PRE_first_tail_x15_r0_body.zg2_2665
  zkP := PRE_first_tail_x15_r0_body.zk2_2665
  zmP := PRE_first_tail_x15_r0_body.zm2_2665
  zgC := PRE_first_tail_x15_r0_body.zg2_2673467
  zkC := PRE_first_tail_x15_r0_body.zk2_2673467
  zmC := PRE_first_tail_x15_r0_body.zm2_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw2_2673472
  zwV := PRE_first_tail_x15_r0_body.zw2_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap2
  zclbd := PRE_first_tail_x15_r0_body.zclbd2
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap2 PRE_first_tail_x15_r0_body.stFoot2 PRE_first_tail_x15_r0_body.iso2 PRE_first_tail_x15_r0_body.zwr2
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP2
  csupp := PRE_first_tail_x15_r0_body.csupp2
  cbound := PRE_first_tail_x15_r0_body.cbound2
  zimg := PRE_first_tail_x15_r0_body.zimg2
  zctl := PRE_first_tail_x15_r0_body.zctl2
  zstack := PRE_first_tail_x15_r0_body.zstack2
  zjobs := PRE_first_tail_x15_r0_body.zjobs2
  zstores := PRE_first_tail_x15_r0_body.zstores2
  zroots := PRE_first_tail_x15_r0_body.zroots2
  znC := PRE_first_tail_x15_r0_body.znC2
  ctab := PRE_first_tail_x15_r0_body.ctab2
  zbin := PRE_first_tail_x15_r0_body.zbin2
  cbridge := PRE_first_tail_x15_r0_body.cbridge2
  sbridge := bodyBridge2
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj2
  cshiftR := fun h hNL => bodyCshift2 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN2
  raised := PRE_first_tail_x15_r0_body.raised2
  cbigs := PRE_first_tail_x15_r0_body.cbigs2
  cjcl := PRE_first_tail_x15_r0_body.cjcl2
  xnLe := Nat.le_of_ble_eq_true bodyXn2
  loLe := Nat.le_of_ble_eq_true bodyLo2
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB2
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
noncomputable def bodyEs2 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr2.map fun r => nth? PRE_first_tail_x15_r0_body.st2.S2.tab r
kernel_rfl bodyResChk2 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs2 bodyQs2) = true
kernel_rfl bodyLq2 : bodyQs2.length = PRE_first_tail_x15_r0_body.cws2.length
kernel_rfl bodyNrLo2 : PRE_first_tail_x15_r0_body.nr2.all (Nat.ble PRE_first_tail_x15_r0_body.S28.tab.length) = true
kernel_rfl bodySub2 : (Oracles.PRE_first_tail_x15_r0_body.map_site2.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost2 : postSubB bodyM PRE_first_tail_x15_r0_body.ws2 PRE_first_tail_x15_r0_body.cws2 bodyQs2 = true
kernel_rfl bodyDrop2 : Nat.ble (5265 + (PRE_first_tail_x15_r0_body.s29.next - PRE_first_tail_x15_r0_body.s30.next)) 5284 = true
kernel_rfl bodyDropH2 : Nat.ble (46 + ((mlxOf PRE_first_tail_x15_r0_body.s29.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s30.ffi).next)) 46 = true
kernel_rfl bodyDropN2 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s29.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s30.ffi).nnext)) 0 = true
kernel_rfl bodyDv2 : bodyΘ.1.take 18 = bodyΘ.1.take 18 ++ PRE_first_tail_x15_r0_body.cws2
kernel_rfl bodyDe2 : bodyΘ.2.take 18 = bodyΘ.2.take 18 ++ PRE_first_tail_x15_r0_body.nr2.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st2.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 18) (bodyΘ.2.take 18)))
kernel_rfl bodyDl2 : (bodyΘ.1.take 18).length = (bodyΘ.2.take 18).length
kernel_rfl bodyDold2 : (bodyΘ.1.take 18).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws2).isNone && !PRE_first_tail_x15_r0_body.ws2.contains v) = true
kernel_rfl bodyDfree2 : (bodyΘ.2.take 18).all (fun e => (PRE_first_tail_x15_r0_body.cws2 ++ PRE_first_tail_x15_r0_body.ws2).all fun w => e.noVar w) = true

theorem bodyStep2 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5265, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s28 PRE_first_tail_x15_r0_body.S28)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5284, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s30 PRE_first_tail_x15_r0_body.S30) (206 + 1) :=
  bodySite bodyFacts2.cfix bodyFacts2.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st2.S2.tab) (Es := bodyEs2) (qs := bodyQs2)
    (ok := PRE_first_tail_x15_r0_body.st2.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site2 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts2
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site2 r hr) hi (MapOk.sub hm (sub_of_all bodySub2)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk2 r hr) hi hm ho hq)
    bodyLq2 rfl bodyNrLo2 (postSub_sound bodyPost2)
    (Nat.le_of_ble_eq_true bodyDrop2) (by decide) (Nat.le_of_ble_eq_true bodyDropH2) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN2) (by decide)
    bodyDv2 bodyDe2 bodyDl2 bodyDold2 bodyDfree2 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
