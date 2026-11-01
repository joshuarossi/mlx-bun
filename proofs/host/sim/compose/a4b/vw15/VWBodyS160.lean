import host.sim.compose.a4b.vw15.VWBodyJ160
import host.sim.compose.a4b.vw15.VWBodySite160
import host.sim.compose.a4b.vw15.VWBodyOracles_40
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift160 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1548.tab.length PRE_first_tail_x15_r0_body.s1548.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P160.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P160 6920 PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.s1550.ffi PRE_first_tail_x15_r0_body.s1549.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_160
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_160
  have hcl : SSt (· < 6920) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1550.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1548.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_160] <;> decide) PRE_first_tail_x15_r0_body.cnodesK160 PRE_first_tail_x15_r0_body.cobjsK160
      PRE_first_tail_x15_r0_body.citemsK160 PRE_first_tail_x15_r0_body.cbd160 PRE_first_tail_x15_r0_body.csst160
  exact PRE_first_tail_x15_r0_body.cshift160 bodyNcl160 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_160] at this; exact this)


kernel_rfl bodyFramesEmpty160 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1549 a).isEmpty) = true
kernel_rfl bodyJsRoots160 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1548.next) PRE_first_tail_x15_r0_body.s1550.trace PRE_first_tail_x15_r0_body.s1550 = true
kernel_rfl bodyJsNative160 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1550.ffi) = true
kernel_rfl bodyLow160 : (PRE_first_tail_x15_r0_body.cws160 ++ PRE_first_tail_x15_r0_body.ws160).all (Nat.ble 9) = true
kernel_rfl bodyCntM160 : countersOkB PRE_first_tail_x15_r0_body.s1548 PRE_first_tail_x15_r0_body.s1549 = true
kernel_rfl bodyHi160 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1550.ffi).next setupP.E = true
kernel_rfl bodyNhi160 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1550.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge160 : bridgeOf PRE_first_tail_x15_r0_body.s1549.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1548.ffi
kernel_rfl bodyNN160 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1548.ffi).nnext PRE_first_tail_x15_r0_body.P160.NL = true
kernel_rfl bodyXn160 : Nat.ble (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1550.ffi).next = true
kernel_rfl bodyLo160 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1550.ffi).next = true
theorem bodyFacts160 : BodySiteFacts PRE_first_tail_x15_r0_body.s1548 PRE_first_tail_x15_r0_body.s1549 PRE_first_tail_x15_r0_body.s1550 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1548 PRE_first_tail_x15_r0_body.S1549 PRE_first_tail_x15_r0_body.S1550
    PRE_first_tail_x15_r0_body.ws160 PRE_first_tail_x15_r0_body.cws160 PRE_first_tail_x15_r0_body.nr160 PRE_first_tail_x15_r0_body.pl160 PRE_first_tail_x15_r0_body.cl160 2800633 6920 PRE_first_tail_x15_r0_body.kd160 PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.P160
    ⟨21357, 18462, 2800631, 6920⟩ ⟨21357, 18462, 2800631, 6920⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap160
  clean := bodyClean160
  cfix := PRE_first_tail_x15_r0_body.cfix160
  zpl := PRE_first_tail_x15_r0_body.zpl160
  zplnd := PRE_first_tail_x15_r0_body.zplnd160
  zn1 := PRE_first_tail_x15_r0_body.zn1160
  zfirst := PRE_first_tail_x15_r0_body.zfirst160
  zscn := PRE_first_tail_x15_r0_body.zscn160
  zsmn := PRE_first_tail_x15_r0_body.zsmn160
  zgrow := PRE_first_tail_x15_r0_body.zgrow160
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab160
  zfresh := PRE_first_tail_x15_r0_body.zfresh160
  zcnd := PRE_first_tail_x15_r0_body.zcnd160
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi160
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt160
  zgP := PRE_first_tail_x15_r0_body.zg160_2665
  zkP := PRE_first_tail_x15_r0_body.zk160_2665
  zmP := PRE_first_tail_x15_r0_body.zm160_2665
  zgC := PRE_first_tail_x15_r0_body.zg160_2673467
  zkC := PRE_first_tail_x15_r0_body.zk160_2673467
  zmC := PRE_first_tail_x15_r0_body.zm160_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw160_2673472
  zwV := PRE_first_tail_x15_r0_body.zw160_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap160
  zclbd := PRE_first_tail_x15_r0_body.zclbd160
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap160 PRE_first_tail_x15_r0_body.stFoot160 PRE_first_tail_x15_r0_body.iso160 PRE_first_tail_x15_r0_body.zwr160
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP160
  csupp := PRE_first_tail_x15_r0_body.csupp160
  cbound := PRE_first_tail_x15_r0_body.cbound160
  zimg := PRE_first_tail_x15_r0_body.zimg160
  zctl := PRE_first_tail_x15_r0_body.zctl160
  zstack := PRE_first_tail_x15_r0_body.zstack160
  zjobs := PRE_first_tail_x15_r0_body.zjobs160
  zstores := PRE_first_tail_x15_r0_body.zstores160
  zroots := PRE_first_tail_x15_r0_body.zroots160
  znC := PRE_first_tail_x15_r0_body.znC160
  ctab := PRE_first_tail_x15_r0_body.ctab160
  zbin := PRE_first_tail_x15_r0_body.zbin160
  cbridge := PRE_first_tail_x15_r0_body.cbridge160
  sbridge := bodyBridge160
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj160
  cshiftR := fun h hNL => bodyCshift160 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN160
  raised := PRE_first_tail_x15_r0_body.raised160
  cbigs := PRE_first_tail_x15_r0_body.cbigs160
  cjcl := PRE_first_tail_x15_r0_body.cjcl160
  xnLe := Nat.le_of_ble_eq_true bodyXn160
  loLe := Nat.le_of_ble_eq_true bodyLo160
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB160
  cntM := bodyCntM160
  hiLe := Nat.le_of_ble_eq_true bodyHi160
  nhiLe := Nat.le_of_ble_eq_true bodyNhi160
  jsHeap := bodyJs160
  jsRoots := bodyJsRoots160
  jsNative := bodyJsNative160
  framesEmpty := bodyFramesEmpty160
  trailOld := by decide
  lowVars := bodyLow160

def bodyQs160 : List (Option Q) := []
noncomputable def bodyEs160 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr160.map fun r => nth? PRE_first_tail_x15_r0_body.st160.S2.tab r
kernel_rfl bodyResChk160 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs160 bodyQs160) = true
kernel_rfl bodyLq160 : bodyQs160.length = PRE_first_tail_x15_r0_body.cws160.length
kernel_rfl bodyNrLo160 : PRE_first_tail_x15_r0_body.nr160.all (Nat.ble PRE_first_tail_x15_r0_body.S1548.tab.length) = true
kernel_rfl bodySub160 : (Oracles.PRE_first_tail_x15_r0_body.map_site160.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost160 : postSubB bodyM PRE_first_tail_x15_r0_body.ws160 PRE_first_tail_x15_r0_body.cws160 bodyQs160 = true
kernel_rfl bodyDrop160 : Nat.ble (56553 + (PRE_first_tail_x15_r0_body.s1549.next - PRE_first_tail_x15_r0_body.s1550.next)) 56555 = true
kernel_rfl bodyDropH160 : Nat.ble (1072 + ((mlxOf PRE_first_tail_x15_r0_body.s1549.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1550.ffi).next)) 1072 = true
kernel_rfl bodyDropN160 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1549.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1550.ffi).nnext)) 0 = true
kernel_rfl bodyDv160 : bodyΘ.1.take 855 = bodyΘ.1.take 855 ++ PRE_first_tail_x15_r0_body.cws160
kernel_rfl bodyDe160 : bodyΘ.2.take 855 = bodyΘ.2.take 855 ++ PRE_first_tail_x15_r0_body.nr160.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st160.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 855) (bodyΘ.2.take 855)))
kernel_rfl bodyDl160 : (bodyΘ.1.take 855).length = (bodyΘ.2.take 855).length
kernel_rfl bodyDold160 : (bodyΘ.1.take 855).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws160).isNone && !PRE_first_tail_x15_r0_body.ws160.contains v) = true
kernel_rfl bodyDfree160 : (bodyΘ.2.take 855).all (fun e => (PRE_first_tail_x15_r0_body.cws160 ++ PRE_first_tail_x15_r0_body.ws160).all fun w => e.noVar w) = true

theorem bodyStep160 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨56553, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1548 PRE_first_tail_x15_r0_body.S1548)
      (bodyCut NB T tk π i x0 bodyΘ ⟨56555, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1550 PRE_first_tail_x15_r0_body.S1550) (27 + 1) :=
  bodySite bodyFacts160.cfix bodyFacts160.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st160.S2.tab) (Es := bodyEs160) (qs := bodyQs160)
    (ok := PRE_first_tail_x15_r0_body.st160.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site160 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts160
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site160 r hr) hi (MapOk.sub hm (sub_of_all bodySub160)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk160 r hr) hi hm ho hq)
    bodyLq160 rfl bodyNrLo160 (postSub_sound bodyPost160)
    (Nat.le_of_ble_eq_true bodyDrop160) (by decide) (Nat.le_of_ble_eq_true bodyDropH160) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN160) (by decide)
    bodyDv160 bodyDe160 bodyDl160 bodyDold160 bodyDfree160 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
