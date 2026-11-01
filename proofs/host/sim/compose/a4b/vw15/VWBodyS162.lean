import host.sim.compose.a4b.vw15.VWBodyJ162
import host.sim.compose.a4b.vw15.VWBodySite162
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

theorem bodyCshift162 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1569.tab.length PRE_first_tail_x15_r0_body.s1569.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P162.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P162 7028 PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.s1571.ffi PRE_first_tail_x15_r0_body.s1570.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_162
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_162
  have hcl : SSt (· < 7028) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1569.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_162] <;> decide) PRE_first_tail_x15_r0_body.cnodesK162 PRE_first_tail_x15_r0_body.cobjsK162
      PRE_first_tail_x15_r0_body.citemsK162 PRE_first_tail_x15_r0_body.cbd162 PRE_first_tail_x15_r0_body.csst162
  exact PRE_first_tail_x15_r0_body.cshift162 bodyNcl162 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_162] at this; exact this)


kernel_rfl bodyFramesEmpty162 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1570 a).isEmpty) = true
kernel_rfl bodyJsRoots162 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1569.next) PRE_first_tail_x15_r0_body.s1571.trace PRE_first_tail_x15_r0_body.s1571 = true
kernel_rfl bodyJsNative162 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1571.ffi) = true
kernel_rfl bodyLow162 : (PRE_first_tail_x15_r0_body.cws162 ++ PRE_first_tail_x15_r0_body.ws162).all (Nat.ble 9) = true
kernel_rfl bodyCntM162 : countersOkB PRE_first_tail_x15_r0_body.s1569 PRE_first_tail_x15_r0_body.s1570 = true
kernel_rfl bodyHi162 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1571.ffi).next setupP.E = true
kernel_rfl bodyNhi162 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1571.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge162 : bridgeOf PRE_first_tail_x15_r0_body.s1570.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1569.ffi
kernel_rfl bodyNN162 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1569.ffi).nnext PRE_first_tail_x15_r0_body.P162.NL = true
kernel_rfl bodyXn162 : Nat.ble (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1571.ffi).next = true
kernel_rfl bodyLo162 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1571.ffi).next = true
theorem bodyFacts162 : BodySiteFacts PRE_first_tail_x15_r0_body.s1569 PRE_first_tail_x15_r0_body.s1570 PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1569 PRE_first_tail_x15_r0_body.S1570 PRE_first_tail_x15_r0_body.S1571
    PRE_first_tail_x15_r0_body.ws162 PRE_first_tail_x15_r0_body.cws162 PRE_first_tail_x15_r0_body.nr162 PRE_first_tail_x15_r0_body.pl162 PRE_first_tail_x15_r0_body.cl162 2803546 7028 PRE_first_tail_x15_r0_body.kd162 PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.P162
    ⟨21398, 18485, 2802391, 7010⟩ ⟨21401, 18512, 2802397, 7028⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap162
  clean := bodyClean162
  cfix := PRE_first_tail_x15_r0_body.cfix162
  zpl := PRE_first_tail_x15_r0_body.zpl162
  zplnd := PRE_first_tail_x15_r0_body.zplnd162
  zn1 := PRE_first_tail_x15_r0_body.zn1162
  zfirst := PRE_first_tail_x15_r0_body.zfirst162
  zscn := PRE_first_tail_x15_r0_body.zscn162
  zsmn := PRE_first_tail_x15_r0_body.zsmn162
  zgrow := PRE_first_tail_x15_r0_body.zgrow162
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab162
  zfresh := PRE_first_tail_x15_r0_body.zfresh162
  zcnd := PRE_first_tail_x15_r0_body.zcnd162
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi162
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt162
  zgP := PRE_first_tail_x15_r0_body.zg162_2665
  zkP := PRE_first_tail_x15_r0_body.zk162_2665
  zmP := PRE_first_tail_x15_r0_body.zm162_2665
  zgC := PRE_first_tail_x15_r0_body.zg162_2673467
  zkC := PRE_first_tail_x15_r0_body.zk162_2673467
  zmC := PRE_first_tail_x15_r0_body.zm162_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw162_2673472
  zwV := PRE_first_tail_x15_r0_body.zw162_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap162
  zclbd := PRE_first_tail_x15_r0_body.zclbd162
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap162 PRE_first_tail_x15_r0_body.stFoot162 PRE_first_tail_x15_r0_body.iso162 PRE_first_tail_x15_r0_body.zwr162
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP162
  csupp := PRE_first_tail_x15_r0_body.csupp162
  cbound := PRE_first_tail_x15_r0_body.cbound162
  zimg := PRE_first_tail_x15_r0_body.zimg162
  zctl := PRE_first_tail_x15_r0_body.zctl162
  zstack := PRE_first_tail_x15_r0_body.zstack162
  zjobs := PRE_first_tail_x15_r0_body.zjobs162
  zstores := PRE_first_tail_x15_r0_body.zstores162
  zroots := PRE_first_tail_x15_r0_body.zroots162
  znC := PRE_first_tail_x15_r0_body.znC162
  ctab := PRE_first_tail_x15_r0_body.ctab162
  zbin := PRE_first_tail_x15_r0_body.zbin162
  cbridge := PRE_first_tail_x15_r0_body.cbridge162
  sbridge := bodyBridge162
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj162
  cshiftR := fun h hNL => bodyCshift162 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN162
  raised := PRE_first_tail_x15_r0_body.raised162
  cbigs := PRE_first_tail_x15_r0_body.cbigs162
  cjcl := PRE_first_tail_x15_r0_body.cjcl162
  xnLe := Nat.le_of_ble_eq_true bodyXn162
  loLe := Nat.le_of_ble_eq_true bodyLo162
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB162
  cntM := bodyCntM162
  hiLe := Nat.le_of_ble_eq_true bodyHi162
  nhiLe := Nat.le_of_ble_eq_true bodyNhi162
  jsHeap := bodyJs162
  jsRoots := bodyJsRoots162
  jsNative := bodyJsNative162
  framesEmpty := bodyFramesEmpty162
  trailOld := by decide
  lowVars := bodyLow162

def bodyQs162 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs162 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr162.map fun r => nth? PRE_first_tail_x15_r0_body.st162.S5.tab r
kernel_rfl bodyResChk162 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs162 bodyQs162) = true
kernel_rfl bodyLq162 : bodyQs162.length = PRE_first_tail_x15_r0_body.cws162.length
kernel_rfl bodyNrLo162 : PRE_first_tail_x15_r0_body.nr162.all (Nat.ble PRE_first_tail_x15_r0_body.S1569.tab.length) = true
kernel_rfl bodySub162 : (Oracles.PRE_first_tail_x15_r0_body.map_site162.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost162 : postSubB bodyM PRE_first_tail_x15_r0_body.ws162 PRE_first_tail_x15_r0_body.cws162 bodyQs162 = true
kernel_rfl bodyDrop162 : Nat.ble (56565 + (PRE_first_tail_x15_r0_body.s1570.next - PRE_first_tail_x15_r0_body.s1571.next)) 57714 = true
kernel_rfl bodyDropH162 : Nat.ble (1072 + ((mlxOf PRE_first_tail_x15_r0_body.s1570.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1571.ffi).next)) 1097 = true
kernel_rfl bodyDropN162 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1570.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1571.ffi).nnext)) 0 = true
kernel_rfl bodyDv162 : bodyΘ.1.take 873 = bodyΘ.1.take 855 ++ PRE_first_tail_x15_r0_body.cws162
kernel_rfl bodyDe162 : bodyΘ.2.take 873 = bodyΘ.2.take 855 ++ PRE_first_tail_x15_r0_body.nr162.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st162.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 855) (bodyΘ.2.take 855)))
kernel_rfl bodyDl162 : (bodyΘ.1.take 855).length = (bodyΘ.2.take 855).length
kernel_rfl bodyDold162 : (bodyΘ.1.take 855).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws162).isNone && !PRE_first_tail_x15_r0_body.ws162.contains v) = true
kernel_rfl bodyDfree162 : (bodyΘ.2.take 873).all (fun e => (PRE_first_tail_x15_r0_body.cws162 ++ PRE_first_tail_x15_r0_body.ws162).all fun w => e.noVar w) = true

theorem bodyStep162 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨56565, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1569 PRE_first_tail_x15_r0_body.S1569)
      (bodyCut NB T tk π i x0 bodyΘ ⟨57714, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.S1571) (11334 + 1) :=
  bodySite bodyFacts162.cfix bodyFacts162.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st162.S5.tab) (Es := bodyEs162) (qs := bodyQs162)
    (ok := PRE_first_tail_x15_r0_body.st162.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site162 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts162
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site162 r hr) hi (MapOk.sub hm (sub_of_all bodySub162)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk162 r hr) hi hm ho hq)
    bodyLq162 rfl bodyNrLo162 (postSub_sound bodyPost162)
    (Nat.le_of_ble_eq_true bodyDrop162) (by decide) (Nat.le_of_ble_eq_true bodyDropH162) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN162) (by decide)
    bodyDv162 bodyDe162 bodyDl162 bodyDold162 bodyDfree162 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
