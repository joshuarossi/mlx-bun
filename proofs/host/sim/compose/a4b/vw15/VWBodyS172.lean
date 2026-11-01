import host.sim.compose.a4b.vw15.VWBodyJ172
import host.sim.compose.a4b.vw15.VWBodySite172
import host.sim.compose.a4b.vw15.VWBodyOracles_43
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

theorem bodyCshift172 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1663.tab.length PRE_first_tail_x15_r0_body.s1663.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P172.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P172 7433 PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.s1665.ffi PRE_first_tail_x15_r0_body.s1664.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_172
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_172
  have hcl : SSt (· < 7433) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1663.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_172] <;> decide) PRE_first_tail_x15_r0_body.cnodesK172 PRE_first_tail_x15_r0_body.cobjsK172
      PRE_first_tail_x15_r0_body.citemsK172 PRE_first_tail_x15_r0_body.cbd172 PRE_first_tail_x15_r0_body.csst172
  exact PRE_first_tail_x15_r0_body.cshift172 bodyNcl172 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_172] at this; exact this)


kernel_rfl bodyFramesEmpty172 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1664 a).isEmpty) = true
kernel_rfl bodyJsRoots172 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1663.next) PRE_first_tail_x15_r0_body.s1665.trace PRE_first_tail_x15_r0_body.s1665 = true
kernel_rfl bodyJsNative172 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1665.ffi) = true
kernel_rfl bodyLow172 : (PRE_first_tail_x15_r0_body.cws172 ++ PRE_first_tail_x15_r0_body.ws172).all (Nat.ble 9) = true
kernel_rfl bodyCntM172 : countersOkB PRE_first_tail_x15_r0_body.s1663 PRE_first_tail_x15_r0_body.s1664 = true
kernel_rfl bodyHi172 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1665.ffi).next setupP.E = true
kernel_rfl bodyNhi172 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1665.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge172 : bridgeOf PRE_first_tail_x15_r0_body.s1664.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1663.ffi
kernel_rfl bodyNN172 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1663.ffi).nnext PRE_first_tail_x15_r0_body.P172.NL = true
kernel_rfl bodyXn172 : Nat.ble (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1665.ffi).next = true
kernel_rfl bodyLo172 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1665.ffi).next = true
theorem bodyFacts172 : BodySiteFacts PRE_first_tail_x15_r0_body.s1663 PRE_first_tail_x15_r0_body.s1664 PRE_first_tail_x15_r0_body.s1665 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1663 PRE_first_tail_x15_r0_body.S1664 PRE_first_tail_x15_r0_body.S1665
    PRE_first_tail_x15_r0_body.ws172 PRE_first_tail_x15_r0_body.cws172 PRE_first_tail_x15_r0_body.nr172 PRE_first_tail_x15_r0_body.pl172 PRE_first_tail_x15_r0_body.cl172 2810057 7433 PRE_first_tail_x15_r0_body.kd172 PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.P172
    ⟨21593, 18699, 2810055, 7433⟩ ⟨21593, 18699, 2810055, 7433⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap172
  clean := bodyClean172
  cfix := PRE_first_tail_x15_r0_body.cfix172
  zpl := PRE_first_tail_x15_r0_body.zpl172
  zplnd := PRE_first_tail_x15_r0_body.zplnd172
  zn1 := PRE_first_tail_x15_r0_body.zn1172
  zfirst := PRE_first_tail_x15_r0_body.zfirst172
  zscn := PRE_first_tail_x15_r0_body.zscn172
  zsmn := PRE_first_tail_x15_r0_body.zsmn172
  zgrow := PRE_first_tail_x15_r0_body.zgrow172
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab172
  zfresh := PRE_first_tail_x15_r0_body.zfresh172
  zcnd := PRE_first_tail_x15_r0_body.zcnd172
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi172
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt172
  zgP := PRE_first_tail_x15_r0_body.zg172_2665
  zkP := PRE_first_tail_x15_r0_body.zk172_2665
  zmP := PRE_first_tail_x15_r0_body.zm172_2665
  zgC := PRE_first_tail_x15_r0_body.zg172_2673467
  zkC := PRE_first_tail_x15_r0_body.zk172_2673467
  zmC := PRE_first_tail_x15_r0_body.zm172_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw172_2673472
  zwV := PRE_first_tail_x15_r0_body.zw172_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap172
  zclbd := PRE_first_tail_x15_r0_body.zclbd172
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap172 PRE_first_tail_x15_r0_body.stFoot172 PRE_first_tail_x15_r0_body.iso172 PRE_first_tail_x15_r0_body.zwr172
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP172
  csupp := PRE_first_tail_x15_r0_body.csupp172
  cbound := PRE_first_tail_x15_r0_body.cbound172
  zimg := PRE_first_tail_x15_r0_body.zimg172
  zctl := PRE_first_tail_x15_r0_body.zctl172
  zstack := PRE_first_tail_x15_r0_body.zstack172
  zjobs := PRE_first_tail_x15_r0_body.zjobs172
  zstores := PRE_first_tail_x15_r0_body.zstores172
  zroots := PRE_first_tail_x15_r0_body.zroots172
  znC := PRE_first_tail_x15_r0_body.znC172
  ctab := PRE_first_tail_x15_r0_body.ctab172
  zbin := PRE_first_tail_x15_r0_body.zbin172
  cbridge := PRE_first_tail_x15_r0_body.cbridge172
  sbridge := bodyBridge172
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj172
  cshiftR := fun h hNL => bodyCshift172 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN172
  raised := PRE_first_tail_x15_r0_body.raised172
  cbigs := PRE_first_tail_x15_r0_body.cbigs172
  cjcl := PRE_first_tail_x15_r0_body.cjcl172
  xnLe := Nat.le_of_ble_eq_true bodyXn172
  loLe := Nat.le_of_ble_eq_true bodyLo172
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB172
  cntM := bodyCntM172
  hiLe := Nat.le_of_ble_eq_true bodyHi172
  nhiLe := Nat.le_of_ble_eq_true bodyNhi172
  jsHeap := bodyJs172
  jsRoots := bodyJsRoots172
  jsNative := bodyJsNative172
  framesEmpty := bodyFramesEmpty172
  trailOld := by decide
  lowVars := bodyLow172

def bodyQs172 : List (Option Q) := []
noncomputable def bodyEs172 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr172.map fun r => nth? PRE_first_tail_x15_r0_body.st172.S2.tab r
kernel_rfl bodyResChk172 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs172 bodyQs172) = true
kernel_rfl bodyLq172 : bodyQs172.length = PRE_first_tail_x15_r0_body.cws172.length
kernel_rfl bodyNrLo172 : PRE_first_tail_x15_r0_body.nr172.all (Nat.ble PRE_first_tail_x15_r0_body.S1663.tab.length) = true
kernel_rfl bodySub172 : (Oracles.PRE_first_tail_x15_r0_body.map_site172.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost172 : postSubB bodyM PRE_first_tail_x15_r0_body.ws172 PRE_first_tail_x15_r0_body.cws172 bodyQs172 = true
kernel_rfl bodyDrop172 : Nat.ble (60425 + (PRE_first_tail_x15_r0_body.s1664.next - PRE_first_tail_x15_r0_body.s1665.next)) 60427 = true
kernel_rfl bodyDropH172 : Nat.ble (1149 + ((mlxOf PRE_first_tail_x15_r0_body.s1664.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1665.ffi).next)) 1149 = true
kernel_rfl bodyDropN172 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1664.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1665.ffi).nnext)) 0 = true
kernel_rfl bodyDv172 : bodyΘ.1.take 918 = bodyΘ.1.take 918 ++ PRE_first_tail_x15_r0_body.cws172
kernel_rfl bodyDe172 : bodyΘ.2.take 918 = bodyΘ.2.take 918 ++ PRE_first_tail_x15_r0_body.nr172.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st172.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 918) (bodyΘ.2.take 918)))
kernel_rfl bodyDl172 : (bodyΘ.1.take 918).length = (bodyΘ.2.take 918).length
kernel_rfl bodyDold172 : (bodyΘ.1.take 918).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws172).isNone && !PRE_first_tail_x15_r0_body.ws172.contains v) = true
kernel_rfl bodyDfree172 : (bodyΘ.2.take 918).all (fun e => (PRE_first_tail_x15_r0_body.cws172 ++ PRE_first_tail_x15_r0_body.ws172).all fun w => e.noVar w) = true

theorem bodyStep172 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨60425, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1663 PRE_first_tail_x15_r0_body.S1663)
      (bodyCut NB T tk π i x0 bodyΘ ⟨60427, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1665 PRE_first_tail_x15_r0_body.S1665) (27 + 1) :=
  bodySite bodyFacts172.cfix bodyFacts172.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st172.S2.tab) (Es := bodyEs172) (qs := bodyQs172)
    (ok := PRE_first_tail_x15_r0_body.st172.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site172 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts172
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site172 r hr) hi (MapOk.sub hm (sub_of_all bodySub172)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk172 r hr) hi hm ho hq)
    bodyLq172 rfl bodyNrLo172 (postSub_sound bodyPost172)
    (Nat.le_of_ble_eq_true bodyDrop172) (by decide) (Nat.le_of_ble_eq_true bodyDropH172) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN172) (by decide)
    bodyDv172 bodyDe172 bodyDl172 bodyDold172 bodyDfree172 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
