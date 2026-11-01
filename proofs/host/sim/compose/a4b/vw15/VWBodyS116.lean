import host.sim.compose.a4b.vw15.VWBodyJ116
import host.sim.compose.a4b.vw15.VWBodySite116
import host.sim.compose.a4b.vw15.VWBodyOracles_29
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift116 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1121.tab.length PRE_first_tail_x15_r0_body.s1121.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P116.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P116 5014 PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.s1123.ffi PRE_first_tail_x15_r0_body.s1122.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_116
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_116
  have hcl : SSt (· < 5014) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1121.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_116] <;> decide) PRE_first_tail_x15_r0_body.cnodesK116 PRE_first_tail_x15_r0_body.cobjsK116
      PRE_first_tail_x15_r0_body.citemsK116 PRE_first_tail_x15_r0_body.cbd116 PRE_first_tail_x15_r0_body.csst116
  exact PRE_first_tail_x15_r0_body.cshift116 bodyNcl116 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_116] at this; exact this)


kernel_rfl bodyFramesEmpty116 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1122 a).isEmpty) = true
kernel_rfl bodyJsRoots116 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1121.next) PRE_first_tail_x15_r0_body.s1123.trace PRE_first_tail_x15_r0_body.s1123 = true
kernel_rfl bodyJsNative116 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1123.ffi) = true
kernel_rfl bodyLow116 : (PRE_first_tail_x15_r0_body.cws116 ++ PRE_first_tail_x15_r0_body.ws116).all (Nat.ble 9) = true
kernel_rfl bodyCntM116 : countersOkB PRE_first_tail_x15_r0_body.s1121 PRE_first_tail_x15_r0_body.s1122 = true
kernel_rfl bodyHi116 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1123.ffi).next setupP.E = true
kernel_rfl bodyNhi116 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1123.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge116 : bridgeOf PRE_first_tail_x15_r0_body.s1122.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1121.ffi
kernel_rfl bodyNN116 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1121.ffi).nnext PRE_first_tail_x15_r0_body.P116.NL = true
kernel_rfl bodyXn116 : Nat.ble (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1123.ffi).next = true
kernel_rfl bodyLo116 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1123.ffi).next = true
theorem bodyFacts116 : BodySiteFacts PRE_first_tail_x15_r0_body.s1121 PRE_first_tail_x15_r0_body.s1122 PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1121 PRE_first_tail_x15_r0_body.S1122 PRE_first_tail_x15_r0_body.S1123
    PRE_first_tail_x15_r0_body.ws116 PRE_first_tail_x15_r0_body.cws116 PRE_first_tail_x15_r0_body.nr116 PRE_first_tail_x15_r0_body.pl116 PRE_first_tail_x15_r0_body.cl116 2765518 5014 PRE_first_tail_x15_r0_body.kd116 PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.P116
    ⟨20477, 17581, 2765507, 5014⟩ ⟨20477, 17581, 2765508, 5014⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap116
  clean := bodyClean116
  cfix := PRE_first_tail_x15_r0_body.cfix116
  zpl := PRE_first_tail_x15_r0_body.zpl116
  zplnd := PRE_first_tail_x15_r0_body.zplnd116
  zn1 := PRE_first_tail_x15_r0_body.zn1116
  zfirst := PRE_first_tail_x15_r0_body.zfirst116
  zscn := PRE_first_tail_x15_r0_body.zscn116
  zsmn := PRE_first_tail_x15_r0_body.zsmn116
  zgrow := PRE_first_tail_x15_r0_body.zgrow116
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab116
  zfresh := PRE_first_tail_x15_r0_body.zfresh116
  zcnd := PRE_first_tail_x15_r0_body.zcnd116
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi116
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt116
  zgP := PRE_first_tail_x15_r0_body.zg116_2665
  zkP := PRE_first_tail_x15_r0_body.zk116_2665
  zmP := PRE_first_tail_x15_r0_body.zm116_2665
  zgC := PRE_first_tail_x15_r0_body.zg116_2673467
  zkC := PRE_first_tail_x15_r0_body.zk116_2673467
  zmC := PRE_first_tail_x15_r0_body.zm116_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw116_2673472
  zwV := PRE_first_tail_x15_r0_body.zw116_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap116
  zclbd := PRE_first_tail_x15_r0_body.zclbd116
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap116 PRE_first_tail_x15_r0_body.stFoot116 PRE_first_tail_x15_r0_body.iso116 PRE_first_tail_x15_r0_body.zwr116
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP116
  csupp := PRE_first_tail_x15_r0_body.csupp116
  cbound := PRE_first_tail_x15_r0_body.cbound116
  zimg := PRE_first_tail_x15_r0_body.zimg116
  zctl := PRE_first_tail_x15_r0_body.zctl116
  zstack := PRE_first_tail_x15_r0_body.zstack116
  zjobs := PRE_first_tail_x15_r0_body.zjobs116
  zstores := PRE_first_tail_x15_r0_body.zstores116
  zroots := PRE_first_tail_x15_r0_body.zroots116
  znC := PRE_first_tail_x15_r0_body.znC116
  ctab := PRE_first_tail_x15_r0_body.ctab116
  zbin := PRE_first_tail_x15_r0_body.zbin116
  cbridge := PRE_first_tail_x15_r0_body.cbridge116
  sbridge := bodyBridge116
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj116
  cshiftR := fun h hNL => bodyCshift116 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN116
  raised := PRE_first_tail_x15_r0_body.raised116
  cbigs := PRE_first_tail_x15_r0_body.cbigs116
  cjcl := PRE_first_tail_x15_r0_body.cjcl116
  xnLe := Nat.le_of_ble_eq_true bodyXn116
  loLe := Nat.le_of_ble_eq_true bodyLo116
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB116
  cntM := bodyCntM116
  hiLe := Nat.le_of_ble_eq_true bodyHi116
  nhiLe := Nat.le_of_ble_eq_true bodyNhi116
  jsHeap := bodyJs116
  jsRoots := bodyJsRoots116
  jsNative := bodyJsNative116
  framesEmpty := bodyFramesEmpty116
  trailOld := by decide
  lowVars := bodyLow116

def bodyQs116 : List (Option Q) := []
noncomputable def bodyEs116 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr116.map fun r => nth? PRE_first_tail_x15_r0_body.st116.S2.tab r
kernel_rfl bodyResChk116 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs116 bodyQs116) = true
kernel_rfl bodyLq116 : bodyQs116.length = PRE_first_tail_x15_r0_body.cws116.length
kernel_rfl bodyNrLo116 : PRE_first_tail_x15_r0_body.nr116.all (Nat.ble PRE_first_tail_x15_r0_body.S1121.tab.length) = true
kernel_rfl bodySub116 : (Oracles.PRE_first_tail_x15_r0_body.map_site116.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost116 : postSubB bodyM PRE_first_tail_x15_r0_body.ws116 PRE_first_tail_x15_r0_body.cws116 bodyQs116 = true
kernel_rfl bodyDrop116 : Nat.ble (42291 + (PRE_first_tail_x15_r0_body.s1122.next - PRE_first_tail_x15_r0_body.s1123.next)) 42301 = true
kernel_rfl bodyDropH116 : Nat.ble (789 + ((mlxOf PRE_first_tail_x15_r0_body.s1122.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1123.ffi).next)) 789 = true
kernel_rfl bodyDropN116 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1122.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1123.ffi).nnext)) 0 = true
kernel_rfl bodyDv116 : bodyΘ.1.take 621 = bodyΘ.1.take 621 ++ PRE_first_tail_x15_r0_body.cws116
kernel_rfl bodyDe116 : bodyΘ.2.take 621 = bodyΘ.2.take 621 ++ PRE_first_tail_x15_r0_body.nr116.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st116.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 621) (bodyΘ.2.take 621)))
kernel_rfl bodyDl116 : (bodyΘ.1.take 621).length = (bodyΘ.2.take 621).length
kernel_rfl bodyDold116 : (bodyΘ.1.take 621).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws116).isNone && !PRE_first_tail_x15_r0_body.ws116.contains v) = true
kernel_rfl bodyDfree116 : (bodyΘ.2.take 621).all (fun e => (PRE_first_tail_x15_r0_body.cws116 ++ PRE_first_tail_x15_r0_body.ws116).all fun w => e.noVar w) = true

theorem bodyStep116 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42291, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1121 PRE_first_tail_x15_r0_body.S1121)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42301, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.S1123) (98 + 1) :=
  bodySite bodyFacts116.cfix bodyFacts116.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st116.S2.tab) (Es := bodyEs116) (qs := bodyQs116)
    (ok := PRE_first_tail_x15_r0_body.st116.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site116 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts116
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site116 r hr) hi (MapOk.sub hm (sub_of_all bodySub116)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk116 r hr) hi hm ho hq)
    bodyLq116 rfl bodyNrLo116 (postSub_sound bodyPost116)
    (Nat.le_of_ble_eq_true bodyDrop116) (by decide) (Nat.le_of_ble_eq_true bodyDropH116) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN116) (by decide)
    bodyDv116 bodyDe116 bodyDl116 bodyDold116 bodyDfree116 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
