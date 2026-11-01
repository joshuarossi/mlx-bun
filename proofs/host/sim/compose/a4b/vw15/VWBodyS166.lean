import host.sim.compose.a4b.vw15.VWBodyJ166
import host.sim.compose.a4b.vw15.VWBodySite166
import host.sim.compose.a4b.vw15.VWBodyOracles_41
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift166 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1605.tab.length PRE_first_tail_x15_r0_body.s1605.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P166.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P166 7175 PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.s1607.ffi PRE_first_tail_x15_r0_body.s1606.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_166
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_166
  have hcl : SSt (· < 7175) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1605.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_166] <;> decide) PRE_first_tail_x15_r0_body.cnodesK166 PRE_first_tail_x15_r0_body.cobjsK166
      PRE_first_tail_x15_r0_body.citemsK166 PRE_first_tail_x15_r0_body.cbd166 PRE_first_tail_x15_r0_body.csst166
  exact PRE_first_tail_x15_r0_body.cshift166 bodyNcl166 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_166] at this; exact this)


kernel_rfl bodyFramesEmpty166 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1606 a).isEmpty) = true
kernel_rfl bodyJsRoots166 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1605.next) PRE_first_tail_x15_r0_body.s1607.trace PRE_first_tail_x15_r0_body.s1607 = true
kernel_rfl bodyJsNative166 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1607.ffi) = true
kernel_rfl bodyLow166 : (PRE_first_tail_x15_r0_body.cws166 ++ PRE_first_tail_x15_r0_body.ws166).all (Nat.ble 9) = true
kernel_rfl bodyCntM166 : countersOkB PRE_first_tail_x15_r0_body.s1605 PRE_first_tail_x15_r0_body.s1606 = true
kernel_rfl bodyHi166 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1607.ffi).next setupP.E = true
kernel_rfl bodyNhi166 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1607.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge166 : bridgeOf PRE_first_tail_x15_r0_body.s1606.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1605.ffi
kernel_rfl bodyNN166 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1605.ffi).nnext PRE_first_tail_x15_r0_body.P166.NL = true
kernel_rfl bodyXn166 : Nat.ble (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1607.ffi).next = true
kernel_rfl bodyLo166 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1607.ffi).next = true
theorem bodyFacts166 : BodySiteFacts PRE_first_tail_x15_r0_body.s1605 PRE_first_tail_x15_r0_body.s1606 PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1605 PRE_first_tail_x15_r0_body.S1606 PRE_first_tail_x15_r0_body.S1607
    PRE_first_tail_x15_r0_body.ws166 PRE_first_tail_x15_r0_body.cws166 PRE_first_tail_x15_r0_body.nr166 PRE_first_tail_x15_r0_body.pl166 PRE_first_tail_x15_r0_body.cl166 2805515 7175 PRE_first_tail_x15_r0_body.kd166 PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.P166
    ⟨21478, 18573, 2805513, 7175⟩ ⟨21478, 18573, 2805513, 7175⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap166
  clean := bodyClean166
  cfix := PRE_first_tail_x15_r0_body.cfix166
  zpl := PRE_first_tail_x15_r0_body.zpl166
  zplnd := PRE_first_tail_x15_r0_body.zplnd166
  zn1 := PRE_first_tail_x15_r0_body.zn1166
  zfirst := PRE_first_tail_x15_r0_body.zfirst166
  zscn := PRE_first_tail_x15_r0_body.zscn166
  zsmn := PRE_first_tail_x15_r0_body.zsmn166
  zgrow := PRE_first_tail_x15_r0_body.zgrow166
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab166
  zfresh := PRE_first_tail_x15_r0_body.zfresh166
  zcnd := PRE_first_tail_x15_r0_body.zcnd166
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi166
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt166
  zgP := PRE_first_tail_x15_r0_body.zg166_2665
  zkP := PRE_first_tail_x15_r0_body.zk166_2665
  zmP := PRE_first_tail_x15_r0_body.zm166_2665
  zgC := PRE_first_tail_x15_r0_body.zg166_2673467
  zkC := PRE_first_tail_x15_r0_body.zk166_2673467
  zmC := PRE_first_tail_x15_r0_body.zm166_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw166_2673472
  zwV := PRE_first_tail_x15_r0_body.zw166_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap166
  zclbd := PRE_first_tail_x15_r0_body.zclbd166
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap166 PRE_first_tail_x15_r0_body.stFoot166 PRE_first_tail_x15_r0_body.iso166 PRE_first_tail_x15_r0_body.zwr166
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP166
  csupp := PRE_first_tail_x15_r0_body.csupp166
  cbound := PRE_first_tail_x15_r0_body.cbound166
  zimg := PRE_first_tail_x15_r0_body.zimg166
  zctl := PRE_first_tail_x15_r0_body.zctl166
  zstack := PRE_first_tail_x15_r0_body.zstack166
  zjobs := PRE_first_tail_x15_r0_body.zjobs166
  zstores := PRE_first_tail_x15_r0_body.zstores166
  zroots := PRE_first_tail_x15_r0_body.zroots166
  znC := PRE_first_tail_x15_r0_body.znC166
  ctab := PRE_first_tail_x15_r0_body.ctab166
  zbin := PRE_first_tail_x15_r0_body.zbin166
  cbridge := PRE_first_tail_x15_r0_body.cbridge166
  sbridge := bodyBridge166
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj166
  cshiftR := fun h hNL => bodyCshift166 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN166
  raised := PRE_first_tail_x15_r0_body.raised166
  cbigs := PRE_first_tail_x15_r0_body.cbigs166
  cjcl := PRE_first_tail_x15_r0_body.cjcl166
  xnLe := Nat.le_of_ble_eq_true bodyXn166
  loLe := Nat.le_of_ble_eq_true bodyLo166
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB166
  cntM := bodyCntM166
  hiLe := Nat.le_of_ble_eq_true bodyHi166
  nhiLe := Nat.le_of_ble_eq_true bodyNhi166
  jsHeap := bodyJs166
  jsRoots := bodyJsRoots166
  jsNative := bodyJsNative166
  framesEmpty := bodyFramesEmpty166
  trailOld := by decide
  lowVars := bodyLow166

def bodyQs166 : List (Option Q) := []
noncomputable def bodyEs166 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr166.map fun r => nth? PRE_first_tail_x15_r0_body.st166.S2.tab r
kernel_rfl bodyResChk166 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs166 bodyQs166) = true
kernel_rfl bodyLq166 : bodyQs166.length = PRE_first_tail_x15_r0_body.cws166.length
kernel_rfl bodyNrLo166 : PRE_first_tail_x15_r0_body.nr166.all (Nat.ble PRE_first_tail_x15_r0_body.S1605.tab.length) = true
kernel_rfl bodySub166 : (Oracles.PRE_first_tail_x15_r0_body.map_site166.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost166 : postSubB bodyM PRE_first_tail_x15_r0_body.ws166 PRE_first_tail_x15_r0_body.cws166 bodyQs166 = true
kernel_rfl bodyDrop166 : Nat.ble (58085 + (PRE_first_tail_x15_r0_body.s1606.next - PRE_first_tail_x15_r0_body.s1607.next)) 58087 = true
kernel_rfl bodyDropH166 : Nat.ble (1099 + ((mlxOf PRE_first_tail_x15_r0_body.s1606.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1607.ffi).next)) 1099 = true
kernel_rfl bodyDropN166 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1606.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1607.ffi).nnext)) 0 = true
kernel_rfl bodyDv166 : bodyΘ.1.take 882 = bodyΘ.1.take 882 ++ PRE_first_tail_x15_r0_body.cws166
kernel_rfl bodyDe166 : bodyΘ.2.take 882 = bodyΘ.2.take 882 ++ PRE_first_tail_x15_r0_body.nr166.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st166.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 882) (bodyΘ.2.take 882)))
kernel_rfl bodyDl166 : (bodyΘ.1.take 882).length = (bodyΘ.2.take 882).length
kernel_rfl bodyDold166 : (bodyΘ.1.take 882).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws166).isNone && !PRE_first_tail_x15_r0_body.ws166.contains v) = true
kernel_rfl bodyDfree166 : (bodyΘ.2.take 882).all (fun e => (PRE_first_tail_x15_r0_body.cws166 ++ PRE_first_tail_x15_r0_body.ws166).all fun w => e.noVar w) = true

theorem bodyStep166 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨58085, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1605 PRE_first_tail_x15_r0_body.S1605)
      (bodyCut NB T tk π i x0 bodyΘ ⟨58087, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.S1607) (27 + 1) :=
  bodySite bodyFacts166.cfix bodyFacts166.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st166.S2.tab) (Es := bodyEs166) (qs := bodyQs166)
    (ok := PRE_first_tail_x15_r0_body.st166.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site166 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts166
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site166 r hr) hi (MapOk.sub hm (sub_of_all bodySub166)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk166 r hr) hi hm ho hq)
    bodyLq166 rfl bodyNrLo166 (postSub_sound bodyPost166)
    (Nat.le_of_ble_eq_true bodyDrop166) (by decide) (Nat.le_of_ble_eq_true bodyDropH166) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN166) (by decide)
    bodyDv166 bodyDe166 bodyDl166 bodyDold166 bodyDfree166 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
