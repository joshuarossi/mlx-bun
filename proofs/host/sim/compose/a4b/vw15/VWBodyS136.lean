import host.sim.compose.a4b.vw15.VWBodyJ136
import host.sim.compose.a4b.vw15.VWBodySite136
import host.sim.compose.a4b.vw15.VWBodyOracles_34
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift136 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1318.tab.length PRE_first_tail_x15_r0_body.s1318.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P136.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P136 5894 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.s1320.ffi PRE_first_tail_x15_r0_body.s1319.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_136
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_136
  have hcl : SSt (· < 5894) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1318.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_136] <;> decide) PRE_first_tail_x15_r0_body.cnodesK136 PRE_first_tail_x15_r0_body.cobjsK136
      PRE_first_tail_x15_r0_body.citemsK136 PRE_first_tail_x15_r0_body.cbd136 PRE_first_tail_x15_r0_body.csst136
  exact PRE_first_tail_x15_r0_body.cshift136 bodyNcl136 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_136] at this; exact this)


kernel_rfl bodyFramesEmpty136 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1319 a).isEmpty) = true
kernel_rfl bodyJsRoots136 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1318.next) PRE_first_tail_x15_r0_body.s1320.trace PRE_first_tail_x15_r0_body.s1320 = true
kernel_rfl bodyJsNative136 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1320.ffi) = true
kernel_rfl bodyLow136 : (PRE_first_tail_x15_r0_body.cws136 ++ PRE_first_tail_x15_r0_body.ws136).all (Nat.ble 9) = true
kernel_rfl bodyCntM136 : countersOkB PRE_first_tail_x15_r0_body.s1318 PRE_first_tail_x15_r0_body.s1319 = true
kernel_rfl bodyHi136 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1320.ffi).next setupP.E = true
kernel_rfl bodyNhi136 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1320.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge136 : bridgeOf PRE_first_tail_x15_r0_body.s1319.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1318.ffi
kernel_rfl bodyNN136 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1318.ffi).nnext PRE_first_tail_x15_r0_body.P136.NL = true
kernel_rfl bodyXn136 : Nat.ble (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1320.ffi).next = true
kernel_rfl bodyLo136 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1320.ffi).next = true
theorem bodyFacts136 : BodySiteFacts PRE_first_tail_x15_r0_body.s1318 PRE_first_tail_x15_r0_body.s1319 PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1318 PRE_first_tail_x15_r0_body.S1319 PRE_first_tail_x15_r0_body.S1320
    PRE_first_tail_x15_r0_body.ws136 PRE_first_tail_x15_r0_body.cws136 PRE_first_tail_x15_r0_body.nr136 PRE_first_tail_x15_r0_body.pl136 PRE_first_tail_x15_r0_body.cl136 2781789 5894 PRE_first_tail_x15_r0_body.kd136 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.P136
    ⟨20885, 17988, 2781787, 5894⟩ ⟨20885, 17988, 2781787, 5894⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap136
  clean := bodyClean136
  cfix := PRE_first_tail_x15_r0_body.cfix136
  zpl := PRE_first_tail_x15_r0_body.zpl136
  zplnd := PRE_first_tail_x15_r0_body.zplnd136
  zn1 := PRE_first_tail_x15_r0_body.zn1136
  zfirst := PRE_first_tail_x15_r0_body.zfirst136
  zscn := PRE_first_tail_x15_r0_body.zscn136
  zsmn := PRE_first_tail_x15_r0_body.zsmn136
  zgrow := PRE_first_tail_x15_r0_body.zgrow136
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab136
  zfresh := PRE_first_tail_x15_r0_body.zfresh136
  zcnd := PRE_first_tail_x15_r0_body.zcnd136
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi136
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt136
  zgP := PRE_first_tail_x15_r0_body.zg136_2665
  zkP := PRE_first_tail_x15_r0_body.zk136_2665
  zmP := PRE_first_tail_x15_r0_body.zm136_2665
  zgC := PRE_first_tail_x15_r0_body.zg136_2673467
  zkC := PRE_first_tail_x15_r0_body.zk136_2673467
  zmC := PRE_first_tail_x15_r0_body.zm136_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw136_2673472
  zwV := PRE_first_tail_x15_r0_body.zw136_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap136
  zclbd := PRE_first_tail_x15_r0_body.zclbd136
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap136 PRE_first_tail_x15_r0_body.stFoot136 PRE_first_tail_x15_r0_body.iso136 PRE_first_tail_x15_r0_body.zwr136
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP136
  csupp := PRE_first_tail_x15_r0_body.csupp136
  cbound := PRE_first_tail_x15_r0_body.cbound136
  zimg := PRE_first_tail_x15_r0_body.zimg136
  zctl := PRE_first_tail_x15_r0_body.zctl136
  zstack := PRE_first_tail_x15_r0_body.zstack136
  zjobs := PRE_first_tail_x15_r0_body.zjobs136
  zstores := PRE_first_tail_x15_r0_body.zstores136
  zroots := PRE_first_tail_x15_r0_body.zroots136
  znC := PRE_first_tail_x15_r0_body.znC136
  ctab := PRE_first_tail_x15_r0_body.ctab136
  zbin := PRE_first_tail_x15_r0_body.zbin136
  cbridge := PRE_first_tail_x15_r0_body.cbridge136
  sbridge := bodyBridge136
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj136
  cshiftR := fun h hNL => bodyCshift136 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN136
  raised := PRE_first_tail_x15_r0_body.raised136
  cbigs := PRE_first_tail_x15_r0_body.cbigs136
  cjcl := PRE_first_tail_x15_r0_body.cjcl136
  xnLe := Nat.le_of_ble_eq_true bodyXn136
  loLe := Nat.le_of_ble_eq_true bodyLo136
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB136
  cntM := bodyCntM136
  hiLe := Nat.le_of_ble_eq_true bodyHi136
  nhiLe := Nat.le_of_ble_eq_true bodyNhi136
  jsHeap := bodyJs136
  jsRoots := bodyJsRoots136
  jsNative := bodyJsNative136
  framesEmpty := bodyFramesEmpty136
  trailOld := by decide
  lowVars := bodyLow136

def bodyQs136 : List (Option Q) := []
noncomputable def bodyEs136 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr136.map fun r => nth? PRE_first_tail_x15_r0_body.st136.S2.tab r
kernel_rfl bodyResChk136 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs136 bodyQs136) = true
kernel_rfl bodyLq136 : bodyQs136.length = PRE_first_tail_x15_r0_body.cws136.length
kernel_rfl bodyNrLo136 : PRE_first_tail_x15_r0_body.nr136.all (Nat.ble PRE_first_tail_x15_r0_body.S1318.tab.length) = true
kernel_rfl bodySub136 : (Oracles.PRE_first_tail_x15_r0_body.map_site136.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost136 : postSubB bodyM PRE_first_tail_x15_r0_body.ws136 PRE_first_tail_x15_r0_body.cws136 bodyQs136 = true
kernel_rfl bodyDrop136 : Nat.ble (48818 + (PRE_first_tail_x15_r0_body.s1319.next - PRE_first_tail_x15_r0_body.s1320.next)) 48820 = true
kernel_rfl bodyDropH136 : Nat.ble (918 + ((mlxOf PRE_first_tail_x15_r0_body.s1319.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1320.ffi).next)) 918 = true
kernel_rfl bodyDropN136 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1319.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1320.ffi).nnext)) 0 = true
kernel_rfl bodyDv136 : bodyΘ.1.take 729 = bodyΘ.1.take 729 ++ PRE_first_tail_x15_r0_body.cws136
kernel_rfl bodyDe136 : bodyΘ.2.take 729 = bodyΘ.2.take 729 ++ PRE_first_tail_x15_r0_body.nr136.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st136.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 729) (bodyΘ.2.take 729)))
kernel_rfl bodyDl136 : (bodyΘ.1.take 729).length = (bodyΘ.2.take 729).length
kernel_rfl bodyDold136 : (bodyΘ.1.take 729).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws136).isNone && !PRE_first_tail_x15_r0_body.ws136.contains v) = true
kernel_rfl bodyDfree136 : (bodyΘ.2.take 729).all (fun e => (PRE_first_tail_x15_r0_body.cws136 ++ PRE_first_tail_x15_r0_body.ws136).all fun w => e.noVar w) = true

theorem bodyStep136 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨48818, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1318 PRE_first_tail_x15_r0_body.S1318)
      (bodyCut NB T tk π i x0 bodyΘ ⟨48820, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.S1320) (27 + 1) :=
  bodySite bodyFacts136.cfix bodyFacts136.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st136.S2.tab) (Es := bodyEs136) (qs := bodyQs136)
    (ok := PRE_first_tail_x15_r0_body.st136.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site136 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts136
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site136 r hr) hi (MapOk.sub hm (sub_of_all bodySub136)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk136 r hr) hi hm ho hq)
    bodyLq136 rfl bodyNrLo136 (postSub_sound bodyPost136)
    (Nat.le_of_ble_eq_true bodyDrop136) (by decide) (Nat.le_of_ble_eq_true bodyDropH136) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN136) (by decide)
    bodyDv136 bodyDe136 bodyDl136 bodyDold136 bodyDfree136 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
