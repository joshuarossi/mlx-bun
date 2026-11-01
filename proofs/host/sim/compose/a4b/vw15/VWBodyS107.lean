import host.sim.compose.a4b.vw15.VWBodyJ107
import host.sim.compose.a4b.vw15.VWBodySite107
import host.sim.compose.a4b.vw15.VWBodyOracles_26
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift107 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1034.tab.length PRE_first_tail_x15_r0_body.s1034.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P107.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P107 4627 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.s1036.ffi PRE_first_tail_x15_r0_body.s1035.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_107
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_107
  have hcl : SSt (· < 4627) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1034.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_107] <;> decide) PRE_first_tail_x15_r0_body.cnodesK107 PRE_first_tail_x15_r0_body.cobjsK107
      PRE_first_tail_x15_r0_body.citemsK107 PRE_first_tail_x15_r0_body.cbd107 PRE_first_tail_x15_r0_body.csst107
  exact PRE_first_tail_x15_r0_body.cshift107 bodyNcl107 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_107] at this; exact this)


kernel_rfl bodyFramesEmpty107 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1035 a).isEmpty) = true
kernel_rfl bodyJsRoots107 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1034.next) PRE_first_tail_x15_r0_body.s1036.trace PRE_first_tail_x15_r0_body.s1036 = true
kernel_rfl bodyJsNative107 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1036.ffi) = true
kernel_rfl bodyLow107 : (PRE_first_tail_x15_r0_body.cws107 ++ PRE_first_tail_x15_r0_body.ws107).all (Nat.ble 9) = true
kernel_rfl bodyCntM107 : countersOkB PRE_first_tail_x15_r0_body.s1034 PRE_first_tail_x15_r0_body.s1035 = true
kernel_rfl bodyHi107 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1036.ffi).next setupP.E = true
kernel_rfl bodyNhi107 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1036.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge107 : bridgeOf PRE_first_tail_x15_r0_body.s1035.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1034.ffi
kernel_rfl bodyNN107 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1034.ffi).nnext PRE_first_tail_x15_r0_body.P107.NL = true
kernel_rfl bodyXn107 : Nat.ble (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1036.ffi).next = true
kernel_rfl bodyLo107 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1036.ffi).next = true
theorem bodyFacts107 : BodySiteFacts PRE_first_tail_x15_r0_body.s1034 PRE_first_tail_x15_r0_body.s1035 PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1034 PRE_first_tail_x15_r0_body.S1035 PRE_first_tail_x15_r0_body.S1036
    PRE_first_tail_x15_r0_body.ws107 PRE_first_tail_x15_r0_body.cws107 PRE_first_tail_x15_r0_body.nr107 PRE_first_tail_x15_r0_body.pl107 PRE_first_tail_x15_r0_body.cl107 2758728 4627 PRE_first_tail_x15_r0_body.kd107 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.P107
    ⟨20305, 17392, 2758717, 4627⟩ ⟨20305, 17392, 2758718, 4627⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap107
  clean := bodyClean107
  cfix := PRE_first_tail_x15_r0_body.cfix107
  zpl := PRE_first_tail_x15_r0_body.zpl107
  zplnd := PRE_first_tail_x15_r0_body.zplnd107
  zn1 := PRE_first_tail_x15_r0_body.zn1107
  zfirst := PRE_first_tail_x15_r0_body.zfirst107
  zscn := PRE_first_tail_x15_r0_body.zscn107
  zsmn := PRE_first_tail_x15_r0_body.zsmn107
  zgrow := PRE_first_tail_x15_r0_body.zgrow107
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab107
  zfresh := PRE_first_tail_x15_r0_body.zfresh107
  zcnd := PRE_first_tail_x15_r0_body.zcnd107
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi107
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt107
  zgP := PRE_first_tail_x15_r0_body.zg107_2665
  zkP := PRE_first_tail_x15_r0_body.zk107_2665
  zmP := PRE_first_tail_x15_r0_body.zm107_2665
  zgC := PRE_first_tail_x15_r0_body.zg107_2673467
  zkC := PRE_first_tail_x15_r0_body.zk107_2673467
  zmC := PRE_first_tail_x15_r0_body.zm107_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw107_2673472
  zwV := PRE_first_tail_x15_r0_body.zw107_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap107
  zclbd := PRE_first_tail_x15_r0_body.zclbd107
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap107 PRE_first_tail_x15_r0_body.stFoot107 PRE_first_tail_x15_r0_body.iso107 PRE_first_tail_x15_r0_body.zwr107
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP107
  csupp := PRE_first_tail_x15_r0_body.csupp107
  cbound := PRE_first_tail_x15_r0_body.cbound107
  zimg := PRE_first_tail_x15_r0_body.zimg107
  zctl := PRE_first_tail_x15_r0_body.zctl107
  zstack := PRE_first_tail_x15_r0_body.zstack107
  zjobs := PRE_first_tail_x15_r0_body.zjobs107
  zstores := PRE_first_tail_x15_r0_body.zstores107
  zroots := PRE_first_tail_x15_r0_body.zroots107
  znC := PRE_first_tail_x15_r0_body.znC107
  ctab := PRE_first_tail_x15_r0_body.ctab107
  zbin := PRE_first_tail_x15_r0_body.zbin107
  cbridge := PRE_first_tail_x15_r0_body.cbridge107
  sbridge := bodyBridge107
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj107
  cshiftR := fun h hNL => bodyCshift107 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN107
  raised := PRE_first_tail_x15_r0_body.raised107
  cbigs := PRE_first_tail_x15_r0_body.cbigs107
  cjcl := PRE_first_tail_x15_r0_body.cjcl107
  xnLe := Nat.le_of_ble_eq_true bodyXn107
  loLe := Nat.le_of_ble_eq_true bodyLo107
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB107
  cntM := bodyCntM107
  hiLe := Nat.le_of_ble_eq_true bodyHi107
  nhiLe := Nat.le_of_ble_eq_true bodyNhi107
  jsHeap := bodyJs107
  jsRoots := bodyJsRoots107
  jsNative := bodyJsNative107
  framesEmpty := bodyFramesEmpty107
  trailOld := by decide
  lowVars := bodyLow107

def bodyQs107 : List (Option Q) := []
noncomputable def bodyEs107 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr107.map fun r => nth? PRE_first_tail_x15_r0_body.st107.S2.tab r
kernel_rfl bodyResChk107 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs107 bodyQs107) = true
kernel_rfl bodyLq107 : bodyQs107.length = PRE_first_tail_x15_r0_body.cws107.length
kernel_rfl bodyNrLo107 : PRE_first_tail_x15_r0_body.nr107.all (Nat.ble PRE_first_tail_x15_r0_body.S1034.tab.length) = true
kernel_rfl bodySub107 : (Oracles.PRE_first_tail_x15_r0_body.map_site107.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost107 : postSubB bodyM PRE_first_tail_x15_r0_body.ws107 PRE_first_tail_x15_r0_body.cws107 bodyQs107 = true
kernel_rfl bodyDrop107 : Nat.ble (38808 + (PRE_first_tail_x15_r0_body.s1035.next - PRE_first_tail_x15_r0_body.s1036.next)) 38818 = true
kernel_rfl bodyDropH107 : Nat.ble (714 + ((mlxOf PRE_first_tail_x15_r0_body.s1035.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1036.ffi).next)) 714 = true
kernel_rfl bodyDropN107 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1035.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1036.ffi).nnext)) 0 = true
kernel_rfl bodyDv107 : bodyΘ.1.take 567 = bodyΘ.1.take 567 ++ PRE_first_tail_x15_r0_body.cws107
kernel_rfl bodyDe107 : bodyΘ.2.take 567 = bodyΘ.2.take 567 ++ PRE_first_tail_x15_r0_body.nr107.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st107.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 567) (bodyΘ.2.take 567)))
kernel_rfl bodyDl107 : (bodyΘ.1.take 567).length = (bodyΘ.2.take 567).length
kernel_rfl bodyDold107 : (bodyΘ.1.take 567).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws107).isNone && !PRE_first_tail_x15_r0_body.ws107.contains v) = true
kernel_rfl bodyDfree107 : (bodyΘ.2.take 567).all (fun e => (PRE_first_tail_x15_r0_body.cws107 ++ PRE_first_tail_x15_r0_body.ws107).all fun w => e.noVar w) = true

theorem bodyStep107 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38808, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1034 PRE_first_tail_x15_r0_body.S1034)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38818, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.S1036) (98 + 1) :=
  bodySite bodyFacts107.cfix bodyFacts107.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st107.S2.tab) (Es := bodyEs107) (qs := bodyQs107)
    (ok := PRE_first_tail_x15_r0_body.st107.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site107 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts107
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site107 r hr) hi (MapOk.sub hm (sub_of_all bodySub107)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk107 r hr) hi hm ho hq)
    bodyLq107 rfl bodyNrLo107 (postSub_sound bodyPost107)
    (Nat.le_of_ble_eq_true bodyDrop107) (by decide) (Nat.le_of_ble_eq_true bodyDropH107) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN107) (by decide)
    bodyDv107 bodyDe107 bodyDl107 bodyDold107 bodyDfree107 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
