import host.sim.compose.a4b.vw15.VWBodyJ92
import host.sim.compose.a4b.vw15.VWBodySite92
import host.sim.compose.a4b.vw15.VWBodyOracles_23
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift92 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S891.tab.length PRE_first_tail_x15_r0_body.s891.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P92.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P92 3988 PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.s893.ffi PRE_first_tail_x15_r0_body.s892.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_92
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_92
  have hcl : SSt (· < 3988) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s893.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S891.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_92] <;> decide) PRE_first_tail_x15_r0_body.cnodesK92 PRE_first_tail_x15_r0_body.cobjsK92
      PRE_first_tail_x15_r0_body.citemsK92 PRE_first_tail_x15_r0_body.cbd92 PRE_first_tail_x15_r0_body.csst92
  exact PRE_first_tail_x15_r0_body.cshift92 bodyNcl92 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_92] at this; exact this)


kernel_rfl bodyFramesEmpty92 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s892 a).isEmpty) = true
kernel_rfl bodyJsRoots92 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s891.next) PRE_first_tail_x15_r0_body.s893.trace PRE_first_tail_x15_r0_body.s893 = true
kernel_rfl bodyJsNative92 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s893.ffi) = true
kernel_rfl bodyLow92 : (PRE_first_tail_x15_r0_body.cws92 ++ PRE_first_tail_x15_r0_body.ws92).all (Nat.ble 9) = true
kernel_rfl bodyCntM92 : countersOkB PRE_first_tail_x15_r0_body.s891 PRE_first_tail_x15_r0_body.s892 = true
kernel_rfl bodyHi92 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s893.ffi).next setupP.E = true
kernel_rfl bodyNhi92 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s893.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge92 : bridgeOf PRE_first_tail_x15_r0_body.s892.ffi = bridgeOf PRE_first_tail_x15_r0_body.s891.ffi
kernel_rfl bodyNN92 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s891.ffi).nnext PRE_first_tail_x15_r0_body.P92.NL = true
kernel_rfl bodyXn92 : Nat.ble (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s893.ffi).next = true
kernel_rfl bodyLo92 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s893.ffi).next = true
theorem bodyFacts92 : BodySiteFacts PRE_first_tail_x15_r0_body.s891 PRE_first_tail_x15_r0_body.s892 PRE_first_tail_x15_r0_body.s893 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S891 PRE_first_tail_x15_r0_body.S892 PRE_first_tail_x15_r0_body.S893
    PRE_first_tail_x15_r0_body.ws92 PRE_first_tail_x15_r0_body.cws92 PRE_first_tail_x15_r0_body.nr92 PRE_first_tail_x15_r0_body.pl92 PRE_first_tail_x15_r0_body.cl92 2746682 3988 PRE_first_tail_x15_r0_body.kd92 PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.P92
    ⟨20005, 17107, 2746671, 3988⟩ ⟨20005, 17107, 2746672, 3988⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap92
  clean := bodyClean92
  cfix := PRE_first_tail_x15_r0_body.cfix92
  zpl := PRE_first_tail_x15_r0_body.zpl92
  zplnd := PRE_first_tail_x15_r0_body.zplnd92
  zn1 := PRE_first_tail_x15_r0_body.zn192
  zfirst := PRE_first_tail_x15_r0_body.zfirst92
  zscn := PRE_first_tail_x15_r0_body.zscn92
  zsmn := PRE_first_tail_x15_r0_body.zsmn92
  zgrow := PRE_first_tail_x15_r0_body.zgrow92
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab92
  zfresh := PRE_first_tail_x15_r0_body.zfresh92
  zcnd := PRE_first_tail_x15_r0_body.zcnd92
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi92
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt92
  zgP := PRE_first_tail_x15_r0_body.zg92_2665
  zkP := PRE_first_tail_x15_r0_body.zk92_2665
  zmP := PRE_first_tail_x15_r0_body.zm92_2665
  zgC := PRE_first_tail_x15_r0_body.zg92_2673467
  zkC := PRE_first_tail_x15_r0_body.zk92_2673467
  zmC := PRE_first_tail_x15_r0_body.zm92_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw92_2673472
  zwV := PRE_first_tail_x15_r0_body.zw92_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap92
  zclbd := PRE_first_tail_x15_r0_body.zclbd92
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap92 PRE_first_tail_x15_r0_body.stFoot92 PRE_first_tail_x15_r0_body.iso92 PRE_first_tail_x15_r0_body.zwr92
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP92
  csupp := PRE_first_tail_x15_r0_body.csupp92
  cbound := PRE_first_tail_x15_r0_body.cbound92
  zimg := PRE_first_tail_x15_r0_body.zimg92
  zctl := PRE_first_tail_x15_r0_body.zctl92
  zstack := PRE_first_tail_x15_r0_body.zstack92
  zjobs := PRE_first_tail_x15_r0_body.zjobs92
  zstores := PRE_first_tail_x15_r0_body.zstores92
  zroots := PRE_first_tail_x15_r0_body.zroots92
  znC := PRE_first_tail_x15_r0_body.znC92
  ctab := PRE_first_tail_x15_r0_body.ctab92
  zbin := PRE_first_tail_x15_r0_body.zbin92
  cbridge := PRE_first_tail_x15_r0_body.cbridge92
  sbridge := bodyBridge92
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj92
  cshiftR := fun h hNL => bodyCshift92 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN92
  raised := PRE_first_tail_x15_r0_body.raised92
  cbigs := PRE_first_tail_x15_r0_body.cbigs92
  cjcl := PRE_first_tail_x15_r0_body.cjcl92
  xnLe := Nat.le_of_ble_eq_true bodyXn92
  loLe := Nat.le_of_ble_eq_true bodyLo92
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB92
  cntM := bodyCntM92
  hiLe := Nat.le_of_ble_eq_true bodyHi92
  nhiLe := Nat.le_of_ble_eq_true bodyNhi92
  jsHeap := bodyJs92
  jsRoots := bodyJsRoots92
  jsNative := bodyJsNative92
  framesEmpty := bodyFramesEmpty92
  trailOld := by decide
  lowVars := bodyLow92

def bodyQs92 : List (Option Q) := []
noncomputable def bodyEs92 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr92.map fun r => nth? PRE_first_tail_x15_r0_body.st92.S2.tab r
kernel_rfl bodyResChk92 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs92 bodyQs92) = true
kernel_rfl bodyLq92 : bodyQs92.length = PRE_first_tail_x15_r0_body.cws92.length
kernel_rfl bodyNrLo92 : PRE_first_tail_x15_r0_body.nr92.all (Nat.ble PRE_first_tail_x15_r0_body.S891.tab.length) = true
kernel_rfl bodySub92 : (Oracles.PRE_first_tail_x15_r0_body.map_site92.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost92 : postSubB bodyM PRE_first_tail_x15_r0_body.ws92 PRE_first_tail_x15_r0_body.cws92 bodyQs92 = true
kernel_rfl bodyDrop92 : Nat.ble (34574 + (PRE_first_tail_x15_r0_body.s892.next - PRE_first_tail_x15_r0_body.s893.next)) 34584 = true
kernel_rfl bodyDropH92 : Nat.ble (635 + ((mlxOf PRE_first_tail_x15_r0_body.s892.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s893.ffi).next)) 635 = true
kernel_rfl bodyDropN92 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s892.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s893.ffi).nnext)) 0 = true
kernel_rfl bodyDv92 : bodyΘ.1.take 495 = bodyΘ.1.take 495 ++ PRE_first_tail_x15_r0_body.cws92
kernel_rfl bodyDe92 : bodyΘ.2.take 495 = bodyΘ.2.take 495 ++ PRE_first_tail_x15_r0_body.nr92.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st92.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 495) (bodyΘ.2.take 495)))
kernel_rfl bodyDl92 : (bodyΘ.1.take 495).length = (bodyΘ.2.take 495).length
kernel_rfl bodyDold92 : (bodyΘ.1.take 495).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws92).isNone && !PRE_first_tail_x15_r0_body.ws92.contains v) = true
kernel_rfl bodyDfree92 : (bodyΘ.2.take 495).all (fun e => (PRE_first_tail_x15_r0_body.cws92 ++ PRE_first_tail_x15_r0_body.ws92).all fun w => e.noVar w) = true

theorem bodyStep92 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34574, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s891 PRE_first_tail_x15_r0_body.S891)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34584, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s893 PRE_first_tail_x15_r0_body.S893) (98 + 1) :=
  bodySite bodyFacts92.cfix bodyFacts92.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st92.S2.tab) (Es := bodyEs92) (qs := bodyQs92)
    (ok := PRE_first_tail_x15_r0_body.st92.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site92 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts92
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site92 r hr) hi (MapOk.sub hm (sub_of_all bodySub92)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk92 r hr) hi hm ho hq)
    bodyLq92 rfl bodyNrLo92 (postSub_sound bodyPost92)
    (Nat.le_of_ble_eq_true bodyDrop92) (by decide) (Nat.le_of_ble_eq_true bodyDropH92) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN92) (by decide)
    bodyDv92 bodyDe92 bodyDl92 bodyDold92 bodyDfree92 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
