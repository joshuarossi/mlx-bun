import host.sim.compose.a4b.vw15.VWBodyJ138
import host.sim.compose.a4b.vw15.VWBodySite138
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

theorem bodyCshift138 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1339.tab.length PRE_first_tail_x15_r0_body.s1339.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P138.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P138 6002 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.s1341.ffi PRE_first_tail_x15_r0_body.s1340.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_138
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_138
  have hcl : SSt (· < 6002) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1339.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_138] <;> decide) PRE_first_tail_x15_r0_body.cnodesK138 PRE_first_tail_x15_r0_body.cobjsK138
      PRE_first_tail_x15_r0_body.citemsK138 PRE_first_tail_x15_r0_body.cbd138 PRE_first_tail_x15_r0_body.csst138
  exact PRE_first_tail_x15_r0_body.cshift138 bodyNcl138 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_138] at this; exact this)


kernel_rfl bodyFramesEmpty138 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1340 a).isEmpty) = true
kernel_rfl bodyJsRoots138 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1339.next) PRE_first_tail_x15_r0_body.s1341.trace PRE_first_tail_x15_r0_body.s1341 = true
kernel_rfl bodyJsNative138 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1341.ffi) = true
kernel_rfl bodyLow138 : (PRE_first_tail_x15_r0_body.cws138 ++ PRE_first_tail_x15_r0_body.ws138).all (Nat.ble 9) = true
kernel_rfl bodyCntM138 : countersOkB PRE_first_tail_x15_r0_body.s1339 PRE_first_tail_x15_r0_body.s1340 = true
kernel_rfl bodyHi138 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1341.ffi).next setupP.E = true
kernel_rfl bodyNhi138 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1341.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge138 : bridgeOf PRE_first_tail_x15_r0_body.s1340.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1339.ffi
kernel_rfl bodyNN138 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1339.ffi).nnext PRE_first_tail_x15_r0_body.P138.NL = true
kernel_rfl bodyXn138 : Nat.ble (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1341.ffi).next = true
kernel_rfl bodyLo138 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1341.ffi).next = true
theorem bodyFacts138 : BodySiteFacts PRE_first_tail_x15_r0_body.s1339 PRE_first_tail_x15_r0_body.s1340 PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1339 PRE_first_tail_x15_r0_body.S1340 PRE_first_tail_x15_r0_body.S1341
    PRE_first_tail_x15_r0_body.ws138 PRE_first_tail_x15_r0_body.cws138 PRE_first_tail_x15_r0_body.nr138 PRE_first_tail_x15_r0_body.pl138 PRE_first_tail_x15_r0_body.cl138 2784706 6002 PRE_first_tail_x15_r0_body.kd138 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.P138
    ⟨20926, 18011, 2783551, 5984⟩ ⟨20929, 18038, 2783557, 6002⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap138
  clean := bodyClean138
  cfix := PRE_first_tail_x15_r0_body.cfix138
  zpl := PRE_first_tail_x15_r0_body.zpl138
  zplnd := PRE_first_tail_x15_r0_body.zplnd138
  zn1 := PRE_first_tail_x15_r0_body.zn1138
  zfirst := PRE_first_tail_x15_r0_body.zfirst138
  zscn := PRE_first_tail_x15_r0_body.zscn138
  zsmn := PRE_first_tail_x15_r0_body.zsmn138
  zgrow := PRE_first_tail_x15_r0_body.zgrow138
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab138
  zfresh := PRE_first_tail_x15_r0_body.zfresh138
  zcnd := PRE_first_tail_x15_r0_body.zcnd138
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi138
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt138
  zgP := PRE_first_tail_x15_r0_body.zg138_2665
  zkP := PRE_first_tail_x15_r0_body.zk138_2665
  zmP := PRE_first_tail_x15_r0_body.zm138_2665
  zgC := PRE_first_tail_x15_r0_body.zg138_2673467
  zkC := PRE_first_tail_x15_r0_body.zk138_2673467
  zmC := PRE_first_tail_x15_r0_body.zm138_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw138_2673472
  zwV := PRE_first_tail_x15_r0_body.zw138_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap138
  zclbd := PRE_first_tail_x15_r0_body.zclbd138
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap138 PRE_first_tail_x15_r0_body.stFoot138 PRE_first_tail_x15_r0_body.iso138 PRE_first_tail_x15_r0_body.zwr138
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP138
  csupp := PRE_first_tail_x15_r0_body.csupp138
  cbound := PRE_first_tail_x15_r0_body.cbound138
  zimg := PRE_first_tail_x15_r0_body.zimg138
  zctl := PRE_first_tail_x15_r0_body.zctl138
  zstack := PRE_first_tail_x15_r0_body.zstack138
  zjobs := PRE_first_tail_x15_r0_body.zjobs138
  zstores := PRE_first_tail_x15_r0_body.zstores138
  zroots := PRE_first_tail_x15_r0_body.zroots138
  znC := PRE_first_tail_x15_r0_body.znC138
  ctab := PRE_first_tail_x15_r0_body.ctab138
  zbin := PRE_first_tail_x15_r0_body.zbin138
  cbridge := PRE_first_tail_x15_r0_body.cbridge138
  sbridge := bodyBridge138
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj138
  cshiftR := fun h hNL => bodyCshift138 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN138
  raised := PRE_first_tail_x15_r0_body.raised138
  cbigs := PRE_first_tail_x15_r0_body.cbigs138
  cjcl := PRE_first_tail_x15_r0_body.cjcl138
  xnLe := Nat.le_of_ble_eq_true bodyXn138
  loLe := Nat.le_of_ble_eq_true bodyLo138
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB138
  cntM := bodyCntM138
  hiLe := Nat.le_of_ble_eq_true bodyHi138
  nhiLe := Nat.le_of_ble_eq_true bodyNhi138
  jsHeap := bodyJs138
  jsRoots := bodyJsRoots138
  jsNative := bodyJsNative138
  framesEmpty := bodyFramesEmpty138
  trailOld := by decide
  lowVars := bodyLow138

def bodyQs138 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs138 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr138.map fun r => nth? PRE_first_tail_x15_r0_body.st138.S5.tab r
kernel_rfl bodyResChk138 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs138 bodyQs138) = true
kernel_rfl bodyLq138 : bodyQs138.length = PRE_first_tail_x15_r0_body.cws138.length
kernel_rfl bodyNrLo138 : PRE_first_tail_x15_r0_body.nr138.all (Nat.ble PRE_first_tail_x15_r0_body.S1339.tab.length) = true
kernel_rfl bodySub138 : (Oracles.PRE_first_tail_x15_r0_body.map_site138.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost138 : postSubB bodyM PRE_first_tail_x15_r0_body.ws138 PRE_first_tail_x15_r0_body.cws138 bodyQs138 = true
kernel_rfl bodyDrop138 : Nat.ble (48839 + (PRE_first_tail_x15_r0_body.s1340.next - PRE_first_tail_x15_r0_body.s1341.next)) 49988 = true
kernel_rfl bodyDropH138 : Nat.ble (918 + ((mlxOf PRE_first_tail_x15_r0_body.s1340.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1341.ffi).next)) 943 = true
kernel_rfl bodyDropN138 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1340.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1341.ffi).nnext)) 0 = true
kernel_rfl bodyDv138 : bodyΘ.1.take 747 = bodyΘ.1.take 729 ++ PRE_first_tail_x15_r0_body.cws138
kernel_rfl bodyDe138 : bodyΘ.2.take 747 = bodyΘ.2.take 729 ++ PRE_first_tail_x15_r0_body.nr138.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st138.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 729) (bodyΘ.2.take 729)))
kernel_rfl bodyDl138 : (bodyΘ.1.take 729).length = (bodyΘ.2.take 729).length
kernel_rfl bodyDold138 : (bodyΘ.1.take 729).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws138).isNone && !PRE_first_tail_x15_r0_body.ws138.contains v) = true
kernel_rfl bodyDfree138 : (bodyΘ.2.take 747).all (fun e => (PRE_first_tail_x15_r0_body.cws138 ++ PRE_first_tail_x15_r0_body.ws138).all fun w => e.noVar w) = true

theorem bodyStep138 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨48839, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1339 PRE_first_tail_x15_r0_body.S1339)
      (bodyCut NB T tk π i x0 bodyΘ ⟨49988, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.S1341) (11334 + 1) :=
  bodySite bodyFacts138.cfix bodyFacts138.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st138.S5.tab) (Es := bodyEs138) (qs := bodyQs138)
    (ok := PRE_first_tail_x15_r0_body.st138.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site138 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts138
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site138 r hr) hi (MapOk.sub hm (sub_of_all bodySub138)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk138 r hr) hi hm ho hq)
    bodyLq138 rfl bodyNrLo138 (postSub_sound bodyPost138)
    (Nat.le_of_ble_eq_true bodyDrop138) (by decide) (Nat.le_of_ble_eq_true bodyDropH138) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN138) (by decide)
    bodyDv138 bodyDe138 bodyDl138 bodyDold138 bodyDfree138 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
