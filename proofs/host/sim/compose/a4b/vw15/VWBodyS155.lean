import host.sim.compose.a4b.vw15.VWBodyJ155
import host.sim.compose.a4b.vw15.VWBodySite155
import host.sim.compose.a4b.vw15.VWBodyOracles_38
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

theorem bodyCshift155 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1494.tab.length PRE_first_tail_x15_r0_body.s1494.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P155.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P155 6679 PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.s1496.ffi PRE_first_tail_x15_r0_body.s1495.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_155
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_155
  have hcl : SSt (· < 6679) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1496.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1494.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_155] <;> decide) PRE_first_tail_x15_r0_body.cnodesK155 PRE_first_tail_x15_r0_body.cobjsK155
      PRE_first_tail_x15_r0_body.citemsK155 PRE_first_tail_x15_r0_body.cbd155 PRE_first_tail_x15_r0_body.csst155
  exact PRE_first_tail_x15_r0_body.cshift155 bodyNcl155 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_155] at this; exact this)


kernel_rfl bodyFramesEmpty155 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1495 a).isEmpty) = true
kernel_rfl bodyJsRoots155 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1494.next) PRE_first_tail_x15_r0_body.s1496.trace PRE_first_tail_x15_r0_body.s1496 = true
kernel_rfl bodyJsNative155 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1496.ffi) = true
kernel_rfl bodyLow155 : (PRE_first_tail_x15_r0_body.cws155 ++ PRE_first_tail_x15_r0_body.ws155).all (Nat.ble 9) = true
kernel_rfl bodyCntM155 : countersOkB PRE_first_tail_x15_r0_body.s1494 PRE_first_tail_x15_r0_body.s1495 = true
kernel_rfl bodyHi155 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1496.ffi).next setupP.E = true
kernel_rfl bodyNhi155 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1496.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge155 : bridgeOf PRE_first_tail_x15_r0_body.s1495.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1494.ffi
kernel_rfl bodyNN155 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1494.ffi).nnext PRE_first_tail_x15_r0_body.P155.NL = true
kernel_rfl bodyXn155 : Nat.ble (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1496.ffi).next = true
kernel_rfl bodyLo155 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1496.ffi).next = true
theorem bodyFacts155 : BodySiteFacts PRE_first_tail_x15_r0_body.s1494 PRE_first_tail_x15_r0_body.s1495 PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1494 PRE_first_tail_x15_r0_body.S1495 PRE_first_tail_x15_r0_body.S1496
    PRE_first_tail_x15_r0_body.ws155 PRE_first_tail_x15_r0_body.cws155 PRE_first_tail_x15_r0_body.nr155 PRE_first_tail_x15_r0_body.pl155 PRE_first_tail_x15_r0_body.cl155 2796396 6679 PRE_first_tail_x15_r0_body.kd155 PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.P155
    ⟨21249, 18340, 2796385, 6679⟩ ⟨21249, 18340, 2796386, 6679⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap155
  clean := bodyClean155
  cfix := PRE_first_tail_x15_r0_body.cfix155
  zpl := PRE_first_tail_x15_r0_body.zpl155
  zplnd := PRE_first_tail_x15_r0_body.zplnd155
  zn1 := PRE_first_tail_x15_r0_body.zn1155
  zfirst := PRE_first_tail_x15_r0_body.zfirst155
  zscn := PRE_first_tail_x15_r0_body.zscn155
  zsmn := PRE_first_tail_x15_r0_body.zsmn155
  zgrow := PRE_first_tail_x15_r0_body.zgrow155
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab155
  zfresh := PRE_first_tail_x15_r0_body.zfresh155
  zcnd := PRE_first_tail_x15_r0_body.zcnd155
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi155
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt155
  zgP := PRE_first_tail_x15_r0_body.zg155_2665
  zkP := PRE_first_tail_x15_r0_body.zk155_2665
  zmP := PRE_first_tail_x15_r0_body.zm155_2665
  zgC := PRE_first_tail_x15_r0_body.zg155_2673467
  zkC := PRE_first_tail_x15_r0_body.zk155_2673467
  zmC := PRE_first_tail_x15_r0_body.zm155_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw155_2673472
  zwV := PRE_first_tail_x15_r0_body.zw155_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap155
  zclbd := PRE_first_tail_x15_r0_body.zclbd155
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap155 PRE_first_tail_x15_r0_body.stFoot155 PRE_first_tail_x15_r0_body.iso155 PRE_first_tail_x15_r0_body.zwr155
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP155
  csupp := PRE_first_tail_x15_r0_body.csupp155
  cbound := PRE_first_tail_x15_r0_body.cbound155
  zimg := PRE_first_tail_x15_r0_body.zimg155
  zctl := PRE_first_tail_x15_r0_body.zctl155
  zstack := PRE_first_tail_x15_r0_body.zstack155
  zjobs := PRE_first_tail_x15_r0_body.zjobs155
  zstores := PRE_first_tail_x15_r0_body.zstores155
  zroots := PRE_first_tail_x15_r0_body.zroots155
  znC := PRE_first_tail_x15_r0_body.znC155
  ctab := PRE_first_tail_x15_r0_body.ctab155
  zbin := PRE_first_tail_x15_r0_body.zbin155
  cbridge := PRE_first_tail_x15_r0_body.cbridge155
  sbridge := bodyBridge155
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj155
  cshiftR := fun h hNL => bodyCshift155 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN155
  raised := PRE_first_tail_x15_r0_body.raised155
  cbigs := PRE_first_tail_x15_r0_body.cbigs155
  cjcl := PRE_first_tail_x15_r0_body.cjcl155
  xnLe := Nat.le_of_ble_eq_true bodyXn155
  loLe := Nat.le_of_ble_eq_true bodyLo155
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB155
  cntM := bodyCntM155
  hiLe := Nat.le_of_ble_eq_true bodyHi155
  nhiLe := Nat.le_of_ble_eq_true bodyNhi155
  jsHeap := bodyJs155
  jsRoots := bodyJsRoots155
  jsNative := bodyJsNative155
  framesEmpty := bodyFramesEmpty155
  trailOld := by decide
  lowVars := bodyLow155

def bodyQs155 : List (Option Q) := []
noncomputable def bodyEs155 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr155.map fun r => nth? PRE_first_tail_x15_r0_body.st155.S2.tab r
kernel_rfl bodyResChk155 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs155 bodyQs155) = true
kernel_rfl bodyLq155 : bodyQs155.length = PRE_first_tail_x15_r0_body.cws155.length
kernel_rfl bodyNrLo155 : PRE_first_tail_x15_r0_body.nr155.all (Nat.ble PRE_first_tail_x15_r0_body.S1494.tab.length) = true
kernel_rfl bodySub155 : (Oracles.PRE_first_tail_x15_r0_body.map_site155.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost155 : postSubB bodyM PRE_first_tail_x15_r0_body.ws155 PRE_first_tail_x15_r0_body.cws155 bodyQs155 = true
kernel_rfl bodyDrop155 : Nat.ble (54233 + (PRE_first_tail_x15_r0_body.s1495.next - PRE_first_tail_x15_r0_body.s1496.next)) 54243 = true
kernel_rfl bodyDropH155 : Nat.ble (1022 + ((mlxOf PRE_first_tail_x15_r0_body.s1495.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1496.ffi).next)) 1022 = true
kernel_rfl bodyDropN155 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1495.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1496.ffi).nnext)) 0 = true
kernel_rfl bodyDv155 : bodyΘ.1.take 819 = bodyΘ.1.take 819 ++ PRE_first_tail_x15_r0_body.cws155
kernel_rfl bodyDe155 : bodyΘ.2.take 819 = bodyΘ.2.take 819 ++ PRE_first_tail_x15_r0_body.nr155.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st155.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 819) (bodyΘ.2.take 819)))
kernel_rfl bodyDl155 : (bodyΘ.1.take 819).length = (bodyΘ.2.take 819).length
kernel_rfl bodyDold155 : (bodyΘ.1.take 819).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws155).isNone && !PRE_first_tail_x15_r0_body.ws155.contains v) = true
kernel_rfl bodyDfree155 : (bodyΘ.2.take 819).all (fun e => (PRE_first_tail_x15_r0_body.cws155 ++ PRE_first_tail_x15_r0_body.ws155).all fun w => e.noVar w) = true

theorem bodyStep155 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨54233, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1494 PRE_first_tail_x15_r0_body.S1494)
      (bodyCut NB T tk π i x0 bodyΘ ⟨54243, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.S1496) (98 + 1) :=
  bodySite bodyFacts155.cfix bodyFacts155.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st155.S2.tab) (Es := bodyEs155) (qs := bodyQs155)
    (ok := PRE_first_tail_x15_r0_body.st155.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site155 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts155
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site155 r hr) hi (MapOk.sub hm (sub_of_all bodySub155)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk155 r hr) hi hm ho hq)
    bodyLq155 rfl bodyNrLo155 (postSub_sound bodyPost155)
    (Nat.le_of_ble_eq_true bodyDrop155) (by decide) (Nat.le_of_ble_eq_true bodyDropH155) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN155) (by decide)
    bodyDv155 bodyDe155 bodyDl155 bodyDold155 bodyDfree155 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
