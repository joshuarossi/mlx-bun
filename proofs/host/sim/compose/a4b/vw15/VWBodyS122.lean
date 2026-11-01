import host.sim.compose.a4b.vw15.VWBodyJ122
import host.sim.compose.a4b.vw15.VWBodySite122
import host.sim.compose.a4b.vw15.VWBodyOracles_30
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift122 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1178.tab.length PRE_first_tail_x15_r0_body.s1178.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P122.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P122 5269 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.s1180.ffi PRE_first_tail_x15_r0_body.s1179.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_122
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_122
  have hcl : SSt (· < 5269) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1178.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_122] <;> decide) PRE_first_tail_x15_r0_body.cnodesK122 PRE_first_tail_x15_r0_body.cobjsK122
      PRE_first_tail_x15_r0_body.citemsK122 PRE_first_tail_x15_r0_body.cbd122 PRE_first_tail_x15_r0_body.csst122
  exact PRE_first_tail_x15_r0_body.cshift122 bodyNcl122 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_122] at this; exact this)


kernel_rfl bodyFramesEmpty122 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1179 a).isEmpty) = true
kernel_rfl bodyJsRoots122 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1178.next) PRE_first_tail_x15_r0_body.s1180.trace PRE_first_tail_x15_r0_body.s1180 = true
kernel_rfl bodyJsNative122 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1180.ffi) = true
kernel_rfl bodyLow122 : (PRE_first_tail_x15_r0_body.cws122 ++ PRE_first_tail_x15_r0_body.ws122).all (Nat.ble 9) = true
kernel_rfl bodyCntM122 : countersOkB PRE_first_tail_x15_r0_body.s1178 PRE_first_tail_x15_r0_body.s1179 = true
kernel_rfl bodyHi122 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1180.ffi).next setupP.E = true
kernel_rfl bodyNhi122 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1180.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge122 : bridgeOf PRE_first_tail_x15_r0_body.s1179.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1178.ffi
kernel_rfl bodyNN122 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1178.ffi).nnext PRE_first_tail_x15_r0_body.P122.NL = true
kernel_rfl bodyXn122 : Nat.ble (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1180.ffi).next = true
kernel_rfl bodyLo122 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1180.ffi).next = true
theorem bodyFacts122 : BodySiteFacts PRE_first_tail_x15_r0_body.s1178 PRE_first_tail_x15_r0_body.s1179 PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1178 PRE_first_tail_x15_r0_body.S1179 PRE_first_tail_x15_r0_body.S1180
    PRE_first_tail_x15_r0_body.ws122 PRE_first_tail_x15_r0_body.cws122 PRE_first_tail_x15_r0_body.nr122 PRE_first_tail_x15_r0_body.pl122 PRE_first_tail_x15_r0_body.cl122 2770418 5269 PRE_first_tail_x15_r0_body.kd122 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.P122
    ⟨20599, 17692, 2770407, 5269⟩ ⟨20599, 17692, 2770408, 5269⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap122
  clean := bodyClean122
  cfix := PRE_first_tail_x15_r0_body.cfix122
  zpl := PRE_first_tail_x15_r0_body.zpl122
  zplnd := PRE_first_tail_x15_r0_body.zplnd122
  zn1 := PRE_first_tail_x15_r0_body.zn1122
  zfirst := PRE_first_tail_x15_r0_body.zfirst122
  zscn := PRE_first_tail_x15_r0_body.zscn122
  zsmn := PRE_first_tail_x15_r0_body.zsmn122
  zgrow := PRE_first_tail_x15_r0_body.zgrow122
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab122
  zfresh := PRE_first_tail_x15_r0_body.zfresh122
  zcnd := PRE_first_tail_x15_r0_body.zcnd122
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi122
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt122
  zgP := PRE_first_tail_x15_r0_body.zg122_2665
  zkP := PRE_first_tail_x15_r0_body.zk122_2665
  zmP := PRE_first_tail_x15_r0_body.zm122_2665
  zgC := PRE_first_tail_x15_r0_body.zg122_2673467
  zkC := PRE_first_tail_x15_r0_body.zk122_2673467
  zmC := PRE_first_tail_x15_r0_body.zm122_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw122_2673472
  zwV := PRE_first_tail_x15_r0_body.zw122_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap122
  zclbd := PRE_first_tail_x15_r0_body.zclbd122
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap122 PRE_first_tail_x15_r0_body.stFoot122 PRE_first_tail_x15_r0_body.iso122 PRE_first_tail_x15_r0_body.zwr122
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP122
  csupp := PRE_first_tail_x15_r0_body.csupp122
  cbound := PRE_first_tail_x15_r0_body.cbound122
  zimg := PRE_first_tail_x15_r0_body.zimg122
  zctl := PRE_first_tail_x15_r0_body.zctl122
  zstack := PRE_first_tail_x15_r0_body.zstack122
  zjobs := PRE_first_tail_x15_r0_body.zjobs122
  zstores := PRE_first_tail_x15_r0_body.zstores122
  zroots := PRE_first_tail_x15_r0_body.zroots122
  znC := PRE_first_tail_x15_r0_body.znC122
  ctab := PRE_first_tail_x15_r0_body.ctab122
  zbin := PRE_first_tail_x15_r0_body.zbin122
  cbridge := PRE_first_tail_x15_r0_body.cbridge122
  sbridge := bodyBridge122
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj122
  cshiftR := fun h hNL => bodyCshift122 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN122
  raised := PRE_first_tail_x15_r0_body.raised122
  cbigs := PRE_first_tail_x15_r0_body.cbigs122
  cjcl := PRE_first_tail_x15_r0_body.cjcl122
  xnLe := Nat.le_of_ble_eq_true bodyXn122
  loLe := Nat.le_of_ble_eq_true bodyLo122
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB122
  cntM := bodyCntM122
  hiLe := Nat.le_of_ble_eq_true bodyHi122
  nhiLe := Nat.le_of_ble_eq_true bodyNhi122
  jsHeap := bodyJs122
  jsRoots := bodyJsRoots122
  jsNative := bodyJsNative122
  framesEmpty := bodyFramesEmpty122
  trailOld := by decide
  lowVars := bodyLow122

def bodyQs122 : List (Option Q) := []
noncomputable def bodyEs122 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr122.map fun r => nth? PRE_first_tail_x15_r0_body.st122.S2.tab r
kernel_rfl bodyResChk122 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs122 bodyQs122) = true
kernel_rfl bodyLq122 : bodyQs122.length = PRE_first_tail_x15_r0_body.cws122.length
kernel_rfl bodyNrLo122 : PRE_first_tail_x15_r0_body.nr122.all (Nat.ble PRE_first_tail_x15_r0_body.S1178.tab.length) = true
kernel_rfl bodySub122 : (Oracles.PRE_first_tail_x15_r0_body.map_site122.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost122 : postSubB bodyM PRE_first_tail_x15_r0_body.ws122 PRE_first_tail_x15_r0_body.cws122 bodyQs122 = true
kernel_rfl bodyDrop122 : Nat.ble (43814 + (PRE_first_tail_x15_r0_body.s1179.next - PRE_first_tail_x15_r0_body.s1180.next)) 43824 = true
kernel_rfl bodyDropH122 : Nat.ble (816 + ((mlxOf PRE_first_tail_x15_r0_body.s1179.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1180.ffi).next)) 816 = true
kernel_rfl bodyDropN122 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1179.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1180.ffi).nnext)) 0 = true
kernel_rfl bodyDv122 : bodyΘ.1.take 648 = bodyΘ.1.take 648 ++ PRE_first_tail_x15_r0_body.cws122
kernel_rfl bodyDe122 : bodyΘ.2.take 648 = bodyΘ.2.take 648 ++ PRE_first_tail_x15_r0_body.nr122.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st122.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 648) (bodyΘ.2.take 648)))
kernel_rfl bodyDl122 : (bodyΘ.1.take 648).length = (bodyΘ.2.take 648).length
kernel_rfl bodyDold122 : (bodyΘ.1.take 648).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws122).isNone && !PRE_first_tail_x15_r0_body.ws122.contains v) = true
kernel_rfl bodyDfree122 : (bodyΘ.2.take 648).all (fun e => (PRE_first_tail_x15_r0_body.cws122 ++ PRE_first_tail_x15_r0_body.ws122).all fun w => e.noVar w) = true

theorem bodyStep122 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨43814, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1178 PRE_first_tail_x15_r0_body.S1178)
      (bodyCut NB T tk π i x0 bodyΘ ⟨43824, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.S1180) (98 + 1) :=
  bodySite bodyFacts122.cfix bodyFacts122.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st122.S2.tab) (Es := bodyEs122) (qs := bodyQs122)
    (ok := PRE_first_tail_x15_r0_body.st122.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site122 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts122
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site122 r hr) hi (MapOk.sub hm (sub_of_all bodySub122)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk122 r hr) hi hm ho hq)
    bodyLq122 rfl bodyNrLo122 (postSub_sound bodyPost122)
    (Nat.le_of_ble_eq_true bodyDrop122) (by decide) (Nat.le_of_ble_eq_true bodyDropH122) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN122) (by decide)
    bodyDv122 bodyDe122 bodyDl122 bodyDold122 bodyDfree122 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
