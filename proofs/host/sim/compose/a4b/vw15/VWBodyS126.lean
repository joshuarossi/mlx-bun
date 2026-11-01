import host.sim.compose.a4b.vw15.VWBodyJ126
import host.sim.compose.a4b.vw15.VWBodySite126
import host.sim.compose.a4b.vw15.VWBodyOracles_31
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift126 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1224.tab.length PRE_first_tail_x15_r0_body.s1224.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P126.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P126 5489 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.s1226.ffi PRE_first_tail_x15_r0_body.s1225.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_126
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_126
  have hcl : SSt (· < 5489) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1224.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_126] <;> decide) PRE_first_tail_x15_r0_body.cnodesK126 PRE_first_tail_x15_r0_body.cobjsK126
      PRE_first_tail_x15_r0_body.citemsK126 PRE_first_tail_x15_r0_body.cbd126 PRE_first_tail_x15_r0_body.csst126
  exact PRE_first_tail_x15_r0_body.cshift126 bodyNcl126 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_126] at this; exact this)


kernel_rfl bodyFramesEmpty126 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1225 a).isEmpty) = true
kernel_rfl bodyJsRoots126 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1224.next) PRE_first_tail_x15_r0_body.s1226.trace PRE_first_tail_x15_r0_body.s1226 = true
kernel_rfl bodyJsNative126 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1226.ffi) = true
kernel_rfl bodyLow126 : (PRE_first_tail_x15_r0_body.cws126 ++ PRE_first_tail_x15_r0_body.ws126).all (Nat.ble 9) = true
kernel_rfl bodyCntM126 : countersOkB PRE_first_tail_x15_r0_body.s1224 PRE_first_tail_x15_r0_body.s1225 = true
kernel_rfl bodyHi126 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1226.ffi).next setupP.E = true
kernel_rfl bodyNhi126 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1226.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge126 : bridgeOf PRE_first_tail_x15_r0_body.s1225.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1224.ffi
kernel_rfl bodyNN126 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1224.ffi).nnext PRE_first_tail_x15_r0_body.P126.NL = true
kernel_rfl bodyXn126 : Nat.ble (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1226.ffi).next = true
kernel_rfl bodyLo126 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1226.ffi).next = true
theorem bodyFacts126 : BodySiteFacts PRE_first_tail_x15_r0_body.s1224 PRE_first_tail_x15_r0_body.s1225 PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1224 PRE_first_tail_x15_r0_body.S1225 PRE_first_tail_x15_r0_body.S1226
    PRE_first_tail_x15_r0_body.ws126 PRE_first_tail_x15_r0_body.cws126 PRE_first_tail_x15_r0_body.nr126 PRE_first_tail_x15_r0_body.pl126 PRE_first_tail_x15_r0_body.cl126 2775290 5489 PRE_first_tail_x15_r0_body.kd126 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.P126
    ⟨20690, 17774, 2774135, 5471⟩ ⟨20693, 17801, 2774141, 5489⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap126
  clean := bodyClean126
  cfix := PRE_first_tail_x15_r0_body.cfix126
  zpl := PRE_first_tail_x15_r0_body.zpl126
  zplnd := PRE_first_tail_x15_r0_body.zplnd126
  zn1 := PRE_first_tail_x15_r0_body.zn1126
  zfirst := PRE_first_tail_x15_r0_body.zfirst126
  zscn := PRE_first_tail_x15_r0_body.zscn126
  zsmn := PRE_first_tail_x15_r0_body.zsmn126
  zgrow := PRE_first_tail_x15_r0_body.zgrow126
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab126
  zfresh := PRE_first_tail_x15_r0_body.zfresh126
  zcnd := PRE_first_tail_x15_r0_body.zcnd126
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi126
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt126
  zgP := PRE_first_tail_x15_r0_body.zg126_2665
  zkP := PRE_first_tail_x15_r0_body.zk126_2665
  zmP := PRE_first_tail_x15_r0_body.zm126_2665
  zgC := PRE_first_tail_x15_r0_body.zg126_2673467
  zkC := PRE_first_tail_x15_r0_body.zk126_2673467
  zmC := PRE_first_tail_x15_r0_body.zm126_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw126_2673472
  zwV := PRE_first_tail_x15_r0_body.zw126_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap126
  zclbd := PRE_first_tail_x15_r0_body.zclbd126
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap126 PRE_first_tail_x15_r0_body.stFoot126 PRE_first_tail_x15_r0_body.iso126 PRE_first_tail_x15_r0_body.zwr126
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP126
  csupp := PRE_first_tail_x15_r0_body.csupp126
  cbound := PRE_first_tail_x15_r0_body.cbound126
  zimg := PRE_first_tail_x15_r0_body.zimg126
  zctl := PRE_first_tail_x15_r0_body.zctl126
  zstack := PRE_first_tail_x15_r0_body.zstack126
  zjobs := PRE_first_tail_x15_r0_body.zjobs126
  zstores := PRE_first_tail_x15_r0_body.zstores126
  zroots := PRE_first_tail_x15_r0_body.zroots126
  znC := PRE_first_tail_x15_r0_body.znC126
  ctab := PRE_first_tail_x15_r0_body.ctab126
  zbin := PRE_first_tail_x15_r0_body.zbin126
  cbridge := PRE_first_tail_x15_r0_body.cbridge126
  sbridge := bodyBridge126
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj126
  cshiftR := fun h hNL => bodyCshift126 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN126
  raised := PRE_first_tail_x15_r0_body.raised126
  cbigs := PRE_first_tail_x15_r0_body.cbigs126
  cjcl := PRE_first_tail_x15_r0_body.cjcl126
  xnLe := Nat.le_of_ble_eq_true bodyXn126
  loLe := Nat.le_of_ble_eq_true bodyLo126
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB126
  cntM := bodyCntM126
  hiLe := Nat.le_of_ble_eq_true bodyHi126
  nhiLe := Nat.le_of_ble_eq_true bodyNhi126
  jsHeap := bodyJs126
  jsRoots := bodyJsRoots126
  jsNative := bodyJsNative126
  framesEmpty := bodyFramesEmpty126
  trailOld := by decide
  lowVars := bodyLow126

def bodyQs126 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs126 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr126.map fun r => nth? PRE_first_tail_x15_r0_body.st126.S5.tab r
kernel_rfl bodyResChk126 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs126 bodyQs126) = true
kernel_rfl bodyLq126 : bodyQs126.length = PRE_first_tail_x15_r0_body.cws126.length
kernel_rfl bodyNrLo126 : PRE_first_tail_x15_r0_body.nr126.all (Nat.ble PRE_first_tail_x15_r0_body.S1224.tab.length) = true
kernel_rfl bodySub126 : (Oracles.PRE_first_tail_x15_r0_body.map_site126.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost126 : postSubB bodyM PRE_first_tail_x15_r0_body.ws126 PRE_first_tail_x15_r0_body.cws126 bodyQs126 = true
kernel_rfl bodyDrop126 : Nat.ble (44985 + (PRE_first_tail_x15_r0_body.s1225.next - PRE_first_tail_x15_r0_body.s1226.next)) 46134 = true
kernel_rfl bodyDropH126 : Nat.ble (841 + ((mlxOf PRE_first_tail_x15_r0_body.s1225.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1226.ffi).next)) 866 = true
kernel_rfl bodyDropN126 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1225.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1226.ffi).nnext)) 0 = true
kernel_rfl bodyDv126 : bodyΘ.1.take 684 = bodyΘ.1.take 666 ++ PRE_first_tail_x15_r0_body.cws126
kernel_rfl bodyDe126 : bodyΘ.2.take 684 = bodyΘ.2.take 666 ++ PRE_first_tail_x15_r0_body.nr126.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st126.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 666) (bodyΘ.2.take 666)))
kernel_rfl bodyDl126 : (bodyΘ.1.take 666).length = (bodyΘ.2.take 666).length
kernel_rfl bodyDold126 : (bodyΘ.1.take 666).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws126).isNone && !PRE_first_tail_x15_r0_body.ws126.contains v) = true
kernel_rfl bodyDfree126 : (bodyΘ.2.take 684).all (fun e => (PRE_first_tail_x15_r0_body.cws126 ++ PRE_first_tail_x15_r0_body.ws126).all fun w => e.noVar w) = true

theorem bodyStep126 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨44985, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1224 PRE_first_tail_x15_r0_body.S1224)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46134, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.S1226) (11334 + 1) :=
  bodySite bodyFacts126.cfix bodyFacts126.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st126.S5.tab) (Es := bodyEs126) (qs := bodyQs126)
    (ok := PRE_first_tail_x15_r0_body.st126.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site126 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts126
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site126 r hr) hi (MapOk.sub hm (sub_of_all bodySub126)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk126 r hr) hi hm ho hq)
    bodyLq126 rfl bodyNrLo126 (postSub_sound bodyPost126)
    (Nat.le_of_ble_eq_true bodyDrop126) (by decide) (Nat.le_of_ble_eq_true bodyDropH126) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN126) (by decide)
    bodyDv126 bodyDe126 bodyDl126 bodyDold126 bodyDfree126 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
