import host.sim.compose.a4b.vw15.VWBodyJ55
import host.sim.compose.a4b.vw15.VWBodySite55
import host.sim.compose.a4b.vw15.VWBodyOracles_13
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift55 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S542.tab.length PRE_first_tail_x15_r0_body.s542.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P55.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.s544.ffi PRE_first_tail_x15_r0_body.s543.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_55
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_55
  have hcl : SSt (· < 2432) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S542.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_55] <;> decide) PRE_first_tail_x15_r0_body.cnodesK55 PRE_first_tail_x15_r0_body.cobjsK55
      PRE_first_tail_x15_r0_body.citemsK55 PRE_first_tail_x15_r0_body.cbd55 PRE_first_tail_x15_r0_body.csst55
  exact PRE_first_tail_x15_r0_body.cshift55 bodyNcl55 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_55] at this; exact this)


kernel_rfl bodyFramesEmpty55 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s543 a).isEmpty) = true
kernel_rfl bodyJsRoots55 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s542.next) PRE_first_tail_x15_r0_body.s544.trace PRE_first_tail_x15_r0_body.s544 = true
kernel_rfl bodyJsNative55 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s544.ffi) = true
kernel_rfl bodyLow55 : (PRE_first_tail_x15_r0_body.cws55 ++ PRE_first_tail_x15_r0_body.ws55).all (Nat.ble 9) = true
kernel_rfl bodyCntM55 : countersOkB PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.s543 = true
kernel_rfl bodyHi55 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).next setupP.E = true
kernel_rfl bodyNhi55 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge55 : bridgeOf PRE_first_tail_x15_r0_body.s543.ffi = bridgeOf PRE_first_tail_x15_r0_body.s542.ffi
kernel_rfl bodyNN55 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s542.ffi).nnext PRE_first_tail_x15_r0_body.P55.NL = true
kernel_rfl bodyXn55 : Nat.ble (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).next = true
kernel_rfl bodyLo55 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).next = true
theorem bodyFacts55 : BodySiteFacts PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.s543 PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S542 PRE_first_tail_x15_r0_body.S543 PRE_first_tail_x15_r0_body.S544
    PRE_first_tail_x15_r0_body.ws55 PRE_first_tail_x15_r0_body.cws55 PRE_first_tail_x15_r0_body.nr55 PRE_first_tail_x15_r0_body.pl55 PRE_first_tail_x15_r0_body.cl55 2718141 2432 PRE_first_tail_x15_r0_body.kd55 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.P55
    ⟨19290, 16392, 2718139, 2432⟩ ⟨19290, 16392, 2718139, 2432⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap55
  clean := bodyClean55
  cfix := PRE_first_tail_x15_r0_body.cfix55
  zpl := PRE_first_tail_x15_r0_body.zpl55
  zplnd := PRE_first_tail_x15_r0_body.zplnd55
  zn1 := PRE_first_tail_x15_r0_body.zn155
  zfirst := PRE_first_tail_x15_r0_body.zfirst55
  zscn := PRE_first_tail_x15_r0_body.zscn55
  zsmn := PRE_first_tail_x15_r0_body.zsmn55
  zgrow := PRE_first_tail_x15_r0_body.zgrow55
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab55
  zfresh := PRE_first_tail_x15_r0_body.zfresh55
  zcnd := PRE_first_tail_x15_r0_body.zcnd55
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi55
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt55
  zgP := PRE_first_tail_x15_r0_body.zg55_2665
  zkP := PRE_first_tail_x15_r0_body.zk55_2665
  zmP := PRE_first_tail_x15_r0_body.zm55_2665
  zgC := PRE_first_tail_x15_r0_body.zg55_2673467
  zkC := PRE_first_tail_x15_r0_body.zk55_2673467
  zmC := PRE_first_tail_x15_r0_body.zm55_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw55_2673472
  zwV := PRE_first_tail_x15_r0_body.zw55_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap55
  zclbd := PRE_first_tail_x15_r0_body.zclbd55
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap55 PRE_first_tail_x15_r0_body.stFoot55 PRE_first_tail_x15_r0_body.iso55 PRE_first_tail_x15_r0_body.zwr55
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP55
  csupp := PRE_first_tail_x15_r0_body.csupp55
  cbound := PRE_first_tail_x15_r0_body.cbound55
  zimg := PRE_first_tail_x15_r0_body.zimg55
  zctl := PRE_first_tail_x15_r0_body.zctl55
  zstack := PRE_first_tail_x15_r0_body.zstack55
  zjobs := PRE_first_tail_x15_r0_body.zjobs55
  zstores := PRE_first_tail_x15_r0_body.zstores55
  zroots := PRE_first_tail_x15_r0_body.zroots55
  znC := PRE_first_tail_x15_r0_body.znC55
  ctab := PRE_first_tail_x15_r0_body.ctab55
  zbin := PRE_first_tail_x15_r0_body.zbin55
  cbridge := PRE_first_tail_x15_r0_body.cbridge55
  sbridge := bodyBridge55
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj55
  cshiftR := fun h hNL => bodyCshift55 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN55
  raised := PRE_first_tail_x15_r0_body.raised55
  cbigs := PRE_first_tail_x15_r0_body.cbigs55
  cjcl := PRE_first_tail_x15_r0_body.cjcl55
  xnLe := Nat.le_of_ble_eq_true bodyXn55
  loLe := Nat.le_of_ble_eq_true bodyLo55
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB55
  cntM := bodyCntM55
  hiLe := Nat.le_of_ble_eq_true bodyHi55
  nhiLe := Nat.le_of_ble_eq_true bodyNhi55
  jsHeap := bodyJs55
  jsRoots := bodyJsRoots55
  jsNative := bodyJsNative55
  framesEmpty := bodyFramesEmpty55
  trailOld := by decide
  lowVars := bodyLow55

def bodyQs55 : List (Option Q) := []
noncomputable def bodyEs55 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr55.map fun r => nth? PRE_first_tail_x15_r0_body.st55.S2.tab r
kernel_rfl bodyResChk55 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs55 bodyQs55) = true
kernel_rfl bodyLq55 : bodyQs55.length = PRE_first_tail_x15_r0_body.cws55.length
kernel_rfl bodyNrLo55 : PRE_first_tail_x15_r0_body.nr55.all (Nat.ble PRE_first_tail_x15_r0_body.S542.tab.length) = true
kernel_rfl bodySub55 : (Oracles.PRE_first_tail_x15_r0_body.map_site55.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost55 : postSubB bodyM PRE_first_tail_x15_r0_body.ws55 PRE_first_tail_x15_r0_body.cws55 bodyQs55 = true
kernel_rfl bodyDrop55 : Nat.ble (23019 + (PRE_first_tail_x15_r0_body.s543.next - PRE_first_tail_x15_r0_body.s544.next)) 23021 = true
kernel_rfl bodyDropH55 : Nat.ble (404 + ((mlxOf PRE_first_tail_x15_r0_body.s543.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).next)) 404 = true
kernel_rfl bodyDropN55 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s543.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s544.ffi).nnext)) 0 = true
kernel_rfl bodyDv55 : bodyΘ.1.take 306 = bodyΘ.1.take 306 ++ PRE_first_tail_x15_r0_body.cws55
kernel_rfl bodyDe55 : bodyΘ.2.take 306 = bodyΘ.2.take 306 ++ PRE_first_tail_x15_r0_body.nr55.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st55.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 306) (bodyΘ.2.take 306)))
kernel_rfl bodyDl55 : (bodyΘ.1.take 306).length = (bodyΘ.2.take 306).length
kernel_rfl bodyDold55 : (bodyΘ.1.take 306).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws55).isNone && !PRE_first_tail_x15_r0_body.ws55.contains v) = true
kernel_rfl bodyDfree55 : (bodyΘ.2.take 306).all (fun e => (PRE_first_tail_x15_r0_body.cws55 ++ PRE_first_tail_x15_r0_body.ws55).all fun w => e.noVar w) = true

theorem bodyStep55 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23019, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.S542)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23021, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.S544) (27 + 1) :=
  bodySite bodyFacts55.cfix bodyFacts55.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st55.S2.tab) (Es := bodyEs55) (qs := bodyQs55)
    (ok := PRE_first_tail_x15_r0_body.st55.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site55 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts55
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site55 r hr) hi (MapOk.sub hm (sub_of_all bodySub55)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk55 r hr) hi hm ho hq)
    bodyLq55 rfl bodyNrLo55 (postSub_sound bodyPost55)
    (Nat.le_of_ble_eq_true bodyDrop55) (by decide) (Nat.le_of_ble_eq_true bodyDropH55) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN55) (by decide)
    bodyDv55 bodyDe55 bodyDl55 bodyDold55 bodyDfree55 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
