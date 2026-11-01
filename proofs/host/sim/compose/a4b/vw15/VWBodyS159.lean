import host.sim.compose.a4b.vw15.VWBodyJ159
import host.sim.compose.a4b.vw15.VWBodySite159
import host.sim.compose.a4b.vw15.VWBodyOracles_39
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

theorem bodyCshift159 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1540.tab.length PRE_first_tail_x15_r0_body.s1540.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P159.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P159 6899 PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.s1542.ffi PRE_first_tail_x15_r0_body.s1541.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_159
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_159
  have hcl : SSt (· < 6899) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1542.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1540.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_159] <;> decide) PRE_first_tail_x15_r0_body.cnodesK159 PRE_first_tail_x15_r0_body.cobjsK159
      PRE_first_tail_x15_r0_body.citemsK159 PRE_first_tail_x15_r0_body.cbd159 PRE_first_tail_x15_r0_body.csst159
  exact PRE_first_tail_x15_r0_body.cshift159 bodyNcl159 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_159] at this; exact this)


kernel_rfl bodyFramesEmpty159 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1541 a).isEmpty) = true
kernel_rfl bodyJsRoots159 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1540.next) PRE_first_tail_x15_r0_body.s1542.trace PRE_first_tail_x15_r0_body.s1542 = true
kernel_rfl bodyJsNative159 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1542.ffi) = true
kernel_rfl bodyLow159 : (PRE_first_tail_x15_r0_body.cws159 ++ PRE_first_tail_x15_r0_body.ws159).all (Nat.ble 9) = true
kernel_rfl bodyCntM159 : countersOkB PRE_first_tail_x15_r0_body.s1540 PRE_first_tail_x15_r0_body.s1541 = true
kernel_rfl bodyHi159 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1542.ffi).next setupP.E = true
kernel_rfl bodyNhi159 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1542.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge159 : bridgeOf PRE_first_tail_x15_r0_body.s1541.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1540.ffi
kernel_rfl bodyNN159 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1540.ffi).nnext PRE_first_tail_x15_r0_body.P159.NL = true
kernel_rfl bodyXn159 : Nat.ble (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1542.ffi).next = true
kernel_rfl bodyLo159 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1542.ffi).next = true
theorem bodyFacts159 : BodySiteFacts PRE_first_tail_x15_r0_body.s1540 PRE_first_tail_x15_r0_body.s1541 PRE_first_tail_x15_r0_body.s1542 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1540 PRE_first_tail_x15_r0_body.S1541 PRE_first_tail_x15_r0_body.S1542
    PRE_first_tail_x15_r0_body.ws159 PRE_first_tail_x15_r0_body.cws159 PRE_first_tail_x15_r0_body.nr159 PRE_first_tail_x15_r0_body.pl159 PRE_first_tail_x15_r0_body.cl159 2801290 6899 PRE_first_tail_x15_r0_body.kd159 PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.P159
    ⟨21341, 18422, 2800135, 6881⟩ ⟨21344, 18449, 2800141, 6899⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap159
  clean := bodyClean159
  cfix := PRE_first_tail_x15_r0_body.cfix159
  zpl := PRE_first_tail_x15_r0_body.zpl159
  zplnd := PRE_first_tail_x15_r0_body.zplnd159
  zn1 := PRE_first_tail_x15_r0_body.zn1159
  zfirst := PRE_first_tail_x15_r0_body.zfirst159
  zscn := PRE_first_tail_x15_r0_body.zscn159
  zsmn := PRE_first_tail_x15_r0_body.zsmn159
  zgrow := PRE_first_tail_x15_r0_body.zgrow159
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab159
  zfresh := PRE_first_tail_x15_r0_body.zfresh159
  zcnd := PRE_first_tail_x15_r0_body.zcnd159
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi159
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt159
  zgP := PRE_first_tail_x15_r0_body.zg159_2665
  zkP := PRE_first_tail_x15_r0_body.zk159_2665
  zmP := PRE_first_tail_x15_r0_body.zm159_2665
  zgC := PRE_first_tail_x15_r0_body.zg159_2673467
  zkC := PRE_first_tail_x15_r0_body.zk159_2673467
  zmC := PRE_first_tail_x15_r0_body.zm159_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw159_2673472
  zwV := PRE_first_tail_x15_r0_body.zw159_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap159
  zclbd := PRE_first_tail_x15_r0_body.zclbd159
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap159 PRE_first_tail_x15_r0_body.stFoot159 PRE_first_tail_x15_r0_body.iso159 PRE_first_tail_x15_r0_body.zwr159
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP159
  csupp := PRE_first_tail_x15_r0_body.csupp159
  cbound := PRE_first_tail_x15_r0_body.cbound159
  zimg := PRE_first_tail_x15_r0_body.zimg159
  zctl := PRE_first_tail_x15_r0_body.zctl159
  zstack := PRE_first_tail_x15_r0_body.zstack159
  zjobs := PRE_first_tail_x15_r0_body.zjobs159
  zstores := PRE_first_tail_x15_r0_body.zstores159
  zroots := PRE_first_tail_x15_r0_body.zroots159
  znC := PRE_first_tail_x15_r0_body.znC159
  ctab := PRE_first_tail_x15_r0_body.ctab159
  zbin := PRE_first_tail_x15_r0_body.zbin159
  cbridge := PRE_first_tail_x15_r0_body.cbridge159
  sbridge := bodyBridge159
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj159
  cshiftR := fun h hNL => bodyCshift159 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN159
  raised := PRE_first_tail_x15_r0_body.raised159
  cbigs := PRE_first_tail_x15_r0_body.cbigs159
  cjcl := PRE_first_tail_x15_r0_body.cjcl159
  xnLe := Nat.le_of_ble_eq_true bodyXn159
  loLe := Nat.le_of_ble_eq_true bodyLo159
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB159
  cntM := bodyCntM159
  hiLe := Nat.le_of_ble_eq_true bodyHi159
  nhiLe := Nat.le_of_ble_eq_true bodyNhi159
  jsHeap := bodyJs159
  jsRoots := bodyJsRoots159
  jsNative := bodyJsNative159
  framesEmpty := bodyFramesEmpty159
  trailOld := by decide
  lowVars := bodyLow159

def bodyQs159 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs159 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr159.map fun r => nth? PRE_first_tail_x15_r0_body.st159.S5.tab r
kernel_rfl bodyResChk159 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs159 bodyQs159) = true
kernel_rfl bodyLq159 : bodyQs159.length = PRE_first_tail_x15_r0_body.cws159.length
kernel_rfl bodyNrLo159 : PRE_first_tail_x15_r0_body.nr159.all (Nat.ble PRE_first_tail_x15_r0_body.S1540.tab.length) = true
kernel_rfl bodySub159 : (Oracles.PRE_first_tail_x15_r0_body.map_site159.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost159 : postSubB bodyM PRE_first_tail_x15_r0_body.ws159 PRE_first_tail_x15_r0_body.cws159 bodyQs159 = true
kernel_rfl bodyDrop159 : Nat.ble (55404 + (PRE_first_tail_x15_r0_body.s1541.next - PRE_first_tail_x15_r0_body.s1542.next)) 56553 = true
kernel_rfl bodyDropH159 : Nat.ble (1047 + ((mlxOf PRE_first_tail_x15_r0_body.s1541.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1542.ffi).next)) 1072 = true
kernel_rfl bodyDropN159 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1541.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1542.ffi).nnext)) 0 = true
kernel_rfl bodyDv159 : bodyΘ.1.take 855 = bodyΘ.1.take 837 ++ PRE_first_tail_x15_r0_body.cws159
kernel_rfl bodyDe159 : bodyΘ.2.take 855 = bodyΘ.2.take 837 ++ PRE_first_tail_x15_r0_body.nr159.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st159.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 837) (bodyΘ.2.take 837)))
kernel_rfl bodyDl159 : (bodyΘ.1.take 837).length = (bodyΘ.2.take 837).length
kernel_rfl bodyDold159 : (bodyΘ.1.take 837).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws159).isNone && !PRE_first_tail_x15_r0_body.ws159.contains v) = true
kernel_rfl bodyDfree159 : (bodyΘ.2.take 855).all (fun e => (PRE_first_tail_x15_r0_body.cws159 ++ PRE_first_tail_x15_r0_body.ws159).all fun w => e.noVar w) = true

theorem bodyStep159 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨55404, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1540 PRE_first_tail_x15_r0_body.S1540)
      (bodyCut NB T tk π i x0 bodyΘ ⟨56553, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1542 PRE_first_tail_x15_r0_body.S1542) (11334 + 1) :=
  bodySite bodyFacts159.cfix bodyFacts159.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st159.S5.tab) (Es := bodyEs159) (qs := bodyQs159)
    (ok := PRE_first_tail_x15_r0_body.st159.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site159 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts159
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site159 r hr) hi (MapOk.sub hm (sub_of_all bodySub159)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk159 r hr) hi hm ho hq)
    bodyLq159 rfl bodyNrLo159 (postSub_sound bodyPost159)
    (Nat.le_of_ble_eq_true bodyDrop159) (by decide) (Nat.le_of_ble_eq_true bodyDropH159) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN159) (by decide)
    bodyDv159 bodyDe159 bodyDl159 bodyDold159 bodyDfree159 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
