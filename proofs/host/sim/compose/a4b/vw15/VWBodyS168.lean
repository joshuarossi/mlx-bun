import host.sim.compose.a4b.vw15.VWBodyJ168
import host.sim.compose.a4b.vw15.VWBodySite168
import host.sim.compose.a4b.vw15.VWBodyOracles_42
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

theorem bodyCshift168 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1626.tab.length PRE_first_tail_x15_r0_body.s1626.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P168.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P168 7283 PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.s1628.ffi PRE_first_tail_x15_r0_body.s1627.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_168
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_168
  have hcl : SSt (· < 7283) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1626.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_168] <;> decide) PRE_first_tail_x15_r0_body.cnodesK168 PRE_first_tail_x15_r0_body.cobjsK168
      PRE_first_tail_x15_r0_body.citemsK168 PRE_first_tail_x15_r0_body.cbd168 PRE_first_tail_x15_r0_body.csst168
  exact PRE_first_tail_x15_r0_body.cshift168 bodyNcl168 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_168] at this; exact this)


kernel_rfl bodyFramesEmpty168 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1627 a).isEmpty) = true
kernel_rfl bodyJsRoots168 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1626.next) PRE_first_tail_x15_r0_body.s1628.trace PRE_first_tail_x15_r0_body.s1628 = true
kernel_rfl bodyJsNative168 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1628.ffi) = true
kernel_rfl bodyLow168 : (PRE_first_tail_x15_r0_body.cws168 ++ PRE_first_tail_x15_r0_body.ws168).all (Nat.ble 9) = true
kernel_rfl bodyCntM168 : countersOkB PRE_first_tail_x15_r0_body.s1626 PRE_first_tail_x15_r0_body.s1627 = true
kernel_rfl bodyHi168 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1628.ffi).next setupP.E = true
kernel_rfl bodyNhi168 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1628.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge168 : bridgeOf PRE_first_tail_x15_r0_body.s1627.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1626.ffi
kernel_rfl bodyNN168 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1626.ffi).nnext PRE_first_tail_x15_r0_body.P168.NL = true
kernel_rfl bodyXn168 : Nat.ble (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1628.ffi).next = true
kernel_rfl bodyLo168 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1628.ffi).next = true
theorem bodyFacts168 : BodySiteFacts PRE_first_tail_x15_r0_body.s1626 PRE_first_tail_x15_r0_body.s1627 PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1626 PRE_first_tail_x15_r0_body.S1627 PRE_first_tail_x15_r0_body.S1628
    PRE_first_tail_x15_r0_body.ws168 PRE_first_tail_x15_r0_body.cws168 PRE_first_tail_x15_r0_body.nr168 PRE_first_tail_x15_r0_body.pl168 PRE_first_tail_x15_r0_body.cl168 2808454 7283 PRE_first_tail_x15_r0_body.kd168 PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.P168
    ⟨21520, 18596, 2807299, 7265⟩ ⟨21523, 18623, 2807305, 7283⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap168
  clean := bodyClean168
  cfix := PRE_first_tail_x15_r0_body.cfix168
  zpl := PRE_first_tail_x15_r0_body.zpl168
  zplnd := PRE_first_tail_x15_r0_body.zplnd168
  zn1 := PRE_first_tail_x15_r0_body.zn1168
  zfirst := PRE_first_tail_x15_r0_body.zfirst168
  zscn := PRE_first_tail_x15_r0_body.zscn168
  zsmn := PRE_first_tail_x15_r0_body.zsmn168
  zgrow := PRE_first_tail_x15_r0_body.zgrow168
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab168
  zfresh := PRE_first_tail_x15_r0_body.zfresh168
  zcnd := PRE_first_tail_x15_r0_body.zcnd168
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi168
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt168
  zgP := PRE_first_tail_x15_r0_body.zg168_2665
  zkP := PRE_first_tail_x15_r0_body.zk168_2665
  zmP := PRE_first_tail_x15_r0_body.zm168_2665
  zgC := PRE_first_tail_x15_r0_body.zg168_2673467
  zkC := PRE_first_tail_x15_r0_body.zk168_2673467
  zmC := PRE_first_tail_x15_r0_body.zm168_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw168_2673472
  zwV := PRE_first_tail_x15_r0_body.zw168_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap168
  zclbd := PRE_first_tail_x15_r0_body.zclbd168
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap168 PRE_first_tail_x15_r0_body.stFoot168 PRE_first_tail_x15_r0_body.iso168 PRE_first_tail_x15_r0_body.zwr168
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP168
  csupp := PRE_first_tail_x15_r0_body.csupp168
  cbound := PRE_first_tail_x15_r0_body.cbound168
  zimg := PRE_first_tail_x15_r0_body.zimg168
  zctl := PRE_first_tail_x15_r0_body.zctl168
  zstack := PRE_first_tail_x15_r0_body.zstack168
  zjobs := PRE_first_tail_x15_r0_body.zjobs168
  zstores := PRE_first_tail_x15_r0_body.zstores168
  zroots := PRE_first_tail_x15_r0_body.zroots168
  znC := PRE_first_tail_x15_r0_body.znC168
  ctab := PRE_first_tail_x15_r0_body.ctab168
  zbin := PRE_first_tail_x15_r0_body.zbin168
  cbridge := PRE_first_tail_x15_r0_body.cbridge168
  sbridge := bodyBridge168
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj168
  cshiftR := fun h hNL => bodyCshift168 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN168
  raised := PRE_first_tail_x15_r0_body.raised168
  cbigs := PRE_first_tail_x15_r0_body.cbigs168
  cjcl := PRE_first_tail_x15_r0_body.cjcl168
  xnLe := Nat.le_of_ble_eq_true bodyXn168
  loLe := Nat.le_of_ble_eq_true bodyLo168
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB168
  cntM := bodyCntM168
  hiLe := Nat.le_of_ble_eq_true bodyHi168
  nhiLe := Nat.le_of_ble_eq_true bodyNhi168
  jsHeap := bodyJs168
  jsRoots := bodyJsRoots168
  jsNative := bodyJsNative168
  framesEmpty := bodyFramesEmpty168
  trailOld := by decide
  lowVars := bodyLow168

def bodyQs168 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs168 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr168.map fun r => nth? PRE_first_tail_x15_r0_body.st168.S5.tab r
kernel_rfl bodyResChk168 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs168 bodyQs168) = true
kernel_rfl bodyLq168 : bodyQs168.length = PRE_first_tail_x15_r0_body.cws168.length
kernel_rfl bodyNrLo168 : PRE_first_tail_x15_r0_body.nr168.all (Nat.ble PRE_first_tail_x15_r0_body.S1626.tab.length) = true
kernel_rfl bodySub168 : (Oracles.PRE_first_tail_x15_r0_body.map_site168.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost168 : postSubB bodyM PRE_first_tail_x15_r0_body.ws168 PRE_first_tail_x15_r0_body.cws168 bodyQs168 = true
kernel_rfl bodyDrop168 : Nat.ble (58106 + (PRE_first_tail_x15_r0_body.s1627.next - PRE_first_tail_x15_r0_body.s1628.next)) 59255 = true
kernel_rfl bodyDropH168 : Nat.ble (1099 + ((mlxOf PRE_first_tail_x15_r0_body.s1627.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1628.ffi).next)) 1124 = true
kernel_rfl bodyDropN168 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1627.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1628.ffi).nnext)) 0 = true
kernel_rfl bodyDv168 : bodyΘ.1.take 900 = bodyΘ.1.take 882 ++ PRE_first_tail_x15_r0_body.cws168
kernel_rfl bodyDe168 : bodyΘ.2.take 900 = bodyΘ.2.take 882 ++ PRE_first_tail_x15_r0_body.nr168.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st168.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 882) (bodyΘ.2.take 882)))
kernel_rfl bodyDl168 : (bodyΘ.1.take 882).length = (bodyΘ.2.take 882).length
kernel_rfl bodyDold168 : (bodyΘ.1.take 882).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws168).isNone && !PRE_first_tail_x15_r0_body.ws168.contains v) = true
kernel_rfl bodyDfree168 : (bodyΘ.2.take 900).all (fun e => (PRE_first_tail_x15_r0_body.cws168 ++ PRE_first_tail_x15_r0_body.ws168).all fun w => e.noVar w) = true

theorem bodyStep168 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨58106, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1626 PRE_first_tail_x15_r0_body.S1626)
      (bodyCut NB T tk π i x0 bodyΘ ⟨59255, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.S1628) (11334 + 1) :=
  bodySite bodyFacts168.cfix bodyFacts168.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st168.S5.tab) (Es := bodyEs168) (qs := bodyQs168)
    (ok := PRE_first_tail_x15_r0_body.st168.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site168 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts168
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site168 r hr) hi (MapOk.sub hm (sub_of_all bodySub168)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk168 r hr) hi hm ho hq)
    bodyLq168 rfl bodyNrLo168 (postSub_sound bodyPost168)
    (Nat.le_of_ble_eq_true bodyDrop168) (by decide) (Nat.le_of_ble_eq_true bodyDropH168) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN168) (by decide)
    bodyDv168 bodyDe168 bodyDl168 bodyDold168 bodyDfree168 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
