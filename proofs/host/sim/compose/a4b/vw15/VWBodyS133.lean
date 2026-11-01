import host.sim.compose.a4b.vw15.VWBodyJ133
import host.sim.compose.a4b.vw15.VWBodySite133
import host.sim.compose.a4b.vw15.VWBodyOracles_33
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

theorem bodyCshift133 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1289.tab.length PRE_first_tail_x15_r0_body.s1289.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P133.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P133 5765 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.s1291.ffi PRE_first_tail_x15_r0_body.s1290.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_133
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_133
  have hcl : SSt (· < 5765) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1289.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_133] <;> decide) PRE_first_tail_x15_r0_body.cnodesK133 PRE_first_tail_x15_r0_body.cobjsK133
      PRE_first_tail_x15_r0_body.citemsK133 PRE_first_tail_x15_r0_body.cbd133 PRE_first_tail_x15_r0_body.csst133
  exact PRE_first_tail_x15_r0_body.cshift133 bodyNcl133 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_133] at this; exact this)


kernel_rfl bodyFramesEmpty133 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1290 a).isEmpty) = true
kernel_rfl bodyJsRoots133 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1289.next) PRE_first_tail_x15_r0_body.s1291.trace PRE_first_tail_x15_r0_body.s1291 = true
kernel_rfl bodyJsNative133 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1291.ffi) = true
kernel_rfl bodyLow133 : (PRE_first_tail_x15_r0_body.cws133 ++ PRE_first_tail_x15_r0_body.ws133).all (Nat.ble 9) = true
kernel_rfl bodyCntM133 : countersOkB PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.s1290 = true
kernel_rfl bodyHi133 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1291.ffi).next setupP.E = true
kernel_rfl bodyNhi133 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1291.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge133 : bridgeOf PRE_first_tail_x15_r0_body.s1290.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1289.ffi
kernel_rfl bodyNN133 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1289.ffi).nnext PRE_first_tail_x15_r0_body.P133.NL = true
kernel_rfl bodyXn133 : Nat.ble (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1291.ffi).next = true
kernel_rfl bodyLo133 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1291.ffi).next = true
theorem bodyFacts133 : BodySiteFacts PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.s1290 PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1289 PRE_first_tail_x15_r0_body.S1290 PRE_first_tail_x15_r0_body.S1291
    PRE_first_tail_x15_r0_body.ws133 PRE_first_tail_x15_r0_body.cws133 PRE_first_tail_x15_r0_body.nr133 PRE_first_tail_x15_r0_body.pl133 PRE_first_tail_x15_r0_body.cl133 2779533 5765 PRE_first_tail_x15_r0_body.kd133 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.P133
    ⟨20828, 17925, 2779531, 5765⟩ ⟨20828, 17925, 2779531, 5765⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap133
  clean := bodyClean133
  cfix := PRE_first_tail_x15_r0_body.cfix133
  zpl := PRE_first_tail_x15_r0_body.zpl133
  zplnd := PRE_first_tail_x15_r0_body.zplnd133
  zn1 := PRE_first_tail_x15_r0_body.zn1133
  zfirst := PRE_first_tail_x15_r0_body.zfirst133
  zscn := PRE_first_tail_x15_r0_body.zscn133
  zsmn := PRE_first_tail_x15_r0_body.zsmn133
  zgrow := PRE_first_tail_x15_r0_body.zgrow133
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab133
  zfresh := PRE_first_tail_x15_r0_body.zfresh133
  zcnd := PRE_first_tail_x15_r0_body.zcnd133
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi133
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt133
  zgP := PRE_first_tail_x15_r0_body.zg133_2665
  zkP := PRE_first_tail_x15_r0_body.zk133_2665
  zmP := PRE_first_tail_x15_r0_body.zm133_2665
  zgC := PRE_first_tail_x15_r0_body.zg133_2673467
  zkC := PRE_first_tail_x15_r0_body.zk133_2673467
  zmC := PRE_first_tail_x15_r0_body.zm133_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw133_2673472
  zwV := PRE_first_tail_x15_r0_body.zw133_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap133
  zclbd := PRE_first_tail_x15_r0_body.zclbd133
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap133 PRE_first_tail_x15_r0_body.stFoot133 PRE_first_tail_x15_r0_body.iso133 PRE_first_tail_x15_r0_body.zwr133
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP133
  csupp := PRE_first_tail_x15_r0_body.csupp133
  cbound := PRE_first_tail_x15_r0_body.cbound133
  zimg := PRE_first_tail_x15_r0_body.zimg133
  zctl := PRE_first_tail_x15_r0_body.zctl133
  zstack := PRE_first_tail_x15_r0_body.zstack133
  zjobs := PRE_first_tail_x15_r0_body.zjobs133
  zstores := PRE_first_tail_x15_r0_body.zstores133
  zroots := PRE_first_tail_x15_r0_body.zroots133
  znC := PRE_first_tail_x15_r0_body.znC133
  ctab := PRE_first_tail_x15_r0_body.ctab133
  zbin := PRE_first_tail_x15_r0_body.zbin133
  cbridge := PRE_first_tail_x15_r0_body.cbridge133
  sbridge := bodyBridge133
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj133
  cshiftR := fun h hNL => bodyCshift133 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN133
  raised := PRE_first_tail_x15_r0_body.raised133
  cbigs := PRE_first_tail_x15_r0_body.cbigs133
  cjcl := PRE_first_tail_x15_r0_body.cjcl133
  xnLe := Nat.le_of_ble_eq_true bodyXn133
  loLe := Nat.le_of_ble_eq_true bodyLo133
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB133
  cntM := bodyCntM133
  hiLe := Nat.le_of_ble_eq_true bodyHi133
  nhiLe := Nat.le_of_ble_eq_true bodyNhi133
  jsHeap := bodyJs133
  jsRoots := bodyJsRoots133
  jsNative := bodyJsNative133
  framesEmpty := bodyFramesEmpty133
  trailOld := by decide
  lowVars := bodyLow133

def bodyQs133 : List (Option Q) := []
noncomputable def bodyEs133 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr133.map fun r => nth? PRE_first_tail_x15_r0_body.st133.S2.tab r
kernel_rfl bodyResChk133 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs133 bodyQs133) = true
kernel_rfl bodyLq133 : bodyQs133.length = PRE_first_tail_x15_r0_body.cws133.length
kernel_rfl bodyNrLo133 : PRE_first_tail_x15_r0_body.nr133.all (Nat.ble PRE_first_tail_x15_r0_body.S1289.tab.length) = true
kernel_rfl bodySub133 : (Oracles.PRE_first_tail_x15_r0_body.map_site133.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost133 : postSubB bodyM PRE_first_tail_x15_r0_body.ws133 PRE_first_tail_x15_r0_body.cws133 bodyQs133 = true
kernel_rfl bodyDrop133 : Nat.ble (47657 + (PRE_first_tail_x15_r0_body.s1290.next - PRE_first_tail_x15_r0_body.s1291.next)) 47659 = true
kernel_rfl bodyDropH133 : Nat.ble (893 + ((mlxOf PRE_first_tail_x15_r0_body.s1290.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1291.ffi).next)) 893 = true
kernel_rfl bodyDropN133 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1290.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1291.ffi).nnext)) 0 = true
kernel_rfl bodyDv133 : bodyΘ.1.take 711 = bodyΘ.1.take 711 ++ PRE_first_tail_x15_r0_body.cws133
kernel_rfl bodyDe133 : bodyΘ.2.take 711 = bodyΘ.2.take 711 ++ PRE_first_tail_x15_r0_body.nr133.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st133.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 711) (bodyΘ.2.take 711)))
kernel_rfl bodyDl133 : (bodyΘ.1.take 711).length = (bodyΘ.2.take 711).length
kernel_rfl bodyDold133 : (bodyΘ.1.take 711).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws133).isNone && !PRE_first_tail_x15_r0_body.ws133.contains v) = true
kernel_rfl bodyDfree133 : (bodyΘ.2.take 711).all (fun e => (PRE_first_tail_x15_r0_body.cws133 ++ PRE_first_tail_x15_r0_body.ws133).all fun w => e.noVar w) = true

theorem bodyStep133 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨47657, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.S1289)
      (bodyCut NB T tk π i x0 bodyΘ ⟨47659, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.S1291) (27 + 1) :=
  bodySite bodyFacts133.cfix bodyFacts133.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st133.S2.tab) (Es := bodyEs133) (qs := bodyQs133)
    (ok := PRE_first_tail_x15_r0_body.st133.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site133 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts133
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site133 r hr) hi (MapOk.sub hm (sub_of_all bodySub133)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk133 r hr) hi hm ho hq)
    bodyLq133 rfl bodyNrLo133 (postSub_sound bodyPost133)
    (Nat.le_of_ble_eq_true bodyDrop133) (by decide) (Nat.le_of_ble_eq_true bodyDropH133) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN133) (by decide)
    bodyDv133 bodyDe133 bodyDl133 bodyDold133 bodyDfree133 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
