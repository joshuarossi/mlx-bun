import host.sim.compose.a4b.vw15.VWBodyJ184
import host.sim.compose.a4b.vw15.VWBodySite184
import host.sim.compose.a4b.vw15.VWBodyOracles_46
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift184 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1778.tab.length PRE_first_tail_x15_r0_body.s1778.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P184.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P184 7946 PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.s1780.ffi PRE_first_tail_x15_r0_body.s1779.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_184
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_184
  have hcl : SSt (· < 7946) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1780.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1778.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_184] <;> decide) PRE_first_tail_x15_r0_body.cnodesK184 PRE_first_tail_x15_r0_body.cobjsK184
      PRE_first_tail_x15_r0_body.citemsK184 PRE_first_tail_x15_r0_body.cbd184 PRE_first_tail_x15_r0_body.csst184
  exact PRE_first_tail_x15_r0_body.cshift184 bodyNcl184 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_184] at this; exact this)


kernel_rfl bodyFramesEmpty184 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1779 a).isEmpty) = true
kernel_rfl bodyJsRoots184 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1778.next) PRE_first_tail_x15_r0_body.s1780.trace PRE_first_tail_x15_r0_body.s1780 = true
kernel_rfl bodyJsNative184 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1780.ffi) = true
kernel_rfl bodyLow184 : (PRE_first_tail_x15_r0_body.cws184 ++ PRE_first_tail_x15_r0_body.ws184).all (Nat.ble 9) = true
kernel_rfl bodyCntM184 : countersOkB PRE_first_tail_x15_r0_body.s1778 PRE_first_tail_x15_r0_body.s1779 = true
kernel_rfl bodyHi184 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1780.ffi).next setupP.E = true
kernel_rfl bodyNhi184 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1780.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge184 : bridgeOf PRE_first_tail_x15_r0_body.s1779.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1778.ffi
kernel_rfl bodyNN184 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1778.ffi).nnext PRE_first_tail_x15_r0_body.P184.NL = true
kernel_rfl bodyXn184 : Nat.ble (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1780.ffi).next = true
kernel_rfl bodyLo184 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1780.ffi).next = true
theorem bodyFacts184 : BodySiteFacts PRE_first_tail_x15_r0_body.s1778 PRE_first_tail_x15_r0_body.s1779 PRE_first_tail_x15_r0_body.s1780 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1778 PRE_first_tail_x15_r0_body.S1779 PRE_first_tail_x15_r0_body.S1780
    PRE_first_tail_x15_r0_body.ws184 PRE_first_tail_x15_r0_body.cws184 PRE_first_tail_x15_r0_body.nr184 PRE_first_tail_x15_r0_body.pl184 PRE_first_tail_x15_r0_body.cl184 2819485 7946 PRE_first_tail_x15_r0_body.kd184 PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.P184
    ⟨21829, 18936, 2819483, 7946⟩ ⟨21829, 18936, 2819483, 7946⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap184
  clean := bodyClean184
  cfix := PRE_first_tail_x15_r0_body.cfix184
  zpl := PRE_first_tail_x15_r0_body.zpl184
  zplnd := PRE_first_tail_x15_r0_body.zplnd184
  zn1 := PRE_first_tail_x15_r0_body.zn1184
  zfirst := PRE_first_tail_x15_r0_body.zfirst184
  zscn := PRE_first_tail_x15_r0_body.zscn184
  zsmn := PRE_first_tail_x15_r0_body.zsmn184
  zgrow := PRE_first_tail_x15_r0_body.zgrow184
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab184
  zfresh := PRE_first_tail_x15_r0_body.zfresh184
  zcnd := PRE_first_tail_x15_r0_body.zcnd184
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi184
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt184
  zgP := PRE_first_tail_x15_r0_body.zg184_2665
  zkP := PRE_first_tail_x15_r0_body.zk184_2665
  zmP := PRE_first_tail_x15_r0_body.zm184_2665
  zgC := PRE_first_tail_x15_r0_body.zg184_2673467
  zkC := PRE_first_tail_x15_r0_body.zk184_2673467
  zmC := PRE_first_tail_x15_r0_body.zm184_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw184_2673472
  zwV := PRE_first_tail_x15_r0_body.zw184_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap184
  zclbd := PRE_first_tail_x15_r0_body.zclbd184
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap184 PRE_first_tail_x15_r0_body.stFoot184 PRE_first_tail_x15_r0_body.iso184 PRE_first_tail_x15_r0_body.zwr184
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP184
  csupp := PRE_first_tail_x15_r0_body.csupp184
  cbound := PRE_first_tail_x15_r0_body.cbound184
  zimg := PRE_first_tail_x15_r0_body.zimg184
  zctl := PRE_first_tail_x15_r0_body.zctl184
  zstack := PRE_first_tail_x15_r0_body.zstack184
  zjobs := PRE_first_tail_x15_r0_body.zjobs184
  zstores := PRE_first_tail_x15_r0_body.zstores184
  zroots := PRE_first_tail_x15_r0_body.zroots184
  znC := PRE_first_tail_x15_r0_body.znC184
  ctab := PRE_first_tail_x15_r0_body.ctab184
  zbin := PRE_first_tail_x15_r0_body.zbin184
  cbridge := PRE_first_tail_x15_r0_body.cbridge184
  sbridge := bodyBridge184
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj184
  cshiftR := fun h hNL => bodyCshift184 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN184
  raised := PRE_first_tail_x15_r0_body.raised184
  cbigs := PRE_first_tail_x15_r0_body.cbigs184
  cjcl := PRE_first_tail_x15_r0_body.cjcl184
  xnLe := Nat.le_of_ble_eq_true bodyXn184
  loLe := Nat.le_of_ble_eq_true bodyLo184
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB184
  cntM := bodyCntM184
  hiLe := Nat.le_of_ble_eq_true bodyHi184
  nhiLe := Nat.le_of_ble_eq_true bodyNhi184
  jsHeap := bodyJs184
  jsRoots := bodyJsRoots184
  jsNative := bodyJsNative184
  framesEmpty := bodyFramesEmpty184
  trailOld := by decide
  lowVars := bodyLow184

def bodyQs184 : List (Option Q) := []
noncomputable def bodyEs184 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr184.map fun r => nth? PRE_first_tail_x15_r0_body.st184.S2.tab r
kernel_rfl bodyResChk184 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs184 bodyQs184) = true
kernel_rfl bodyLq184 : bodyQs184.length = PRE_first_tail_x15_r0_body.cws184.length
kernel_rfl bodyNrLo184 : PRE_first_tail_x15_r0_body.nr184.all (Nat.ble PRE_first_tail_x15_r0_body.S1778.tab.length) = true
kernel_rfl bodySub184 : (Oracles.PRE_first_tail_x15_r0_body.map_site184.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost184 : postSubB bodyM PRE_first_tail_x15_r0_body.ws184 PRE_first_tail_x15_r0_body.cws184 bodyQs184 = true
kernel_rfl bodyDrop184 : Nat.ble (64306 + (PRE_first_tail_x15_r0_body.s1779.next - PRE_first_tail_x15_r0_body.s1780.next)) 64308 = true
kernel_rfl bodyDropH184 : Nat.ble (1226 + ((mlxOf PRE_first_tail_x15_r0_body.s1779.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1780.ffi).next)) 1226 = true
kernel_rfl bodyDropN184 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1779.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1780.ffi).nnext)) 0 = true
kernel_rfl bodyDv184 : bodyΘ.1.take 981 = bodyΘ.1.take 981 ++ PRE_first_tail_x15_r0_body.cws184
kernel_rfl bodyDe184 : bodyΘ.2.take 981 = bodyΘ.2.take 981 ++ PRE_first_tail_x15_r0_body.nr184.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st184.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 981) (bodyΘ.2.take 981)))
kernel_rfl bodyDl184 : (bodyΘ.1.take 981).length = (bodyΘ.2.take 981).length
kernel_rfl bodyDold184 : (bodyΘ.1.take 981).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws184).isNone && !PRE_first_tail_x15_r0_body.ws184.contains v) = true
kernel_rfl bodyDfree184 : (bodyΘ.2.take 981).all (fun e => (PRE_first_tail_x15_r0_body.cws184 ++ PRE_first_tail_x15_r0_body.ws184).all fun w => e.noVar w) = true

theorem bodyStep184 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64306, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1778 PRE_first_tail_x15_r0_body.S1778)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64308, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1780 PRE_first_tail_x15_r0_body.S1780) (27 + 1) :=
  bodySite bodyFacts184.cfix bodyFacts184.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st184.S2.tab) (Es := bodyEs184) (qs := bodyQs184)
    (ok := PRE_first_tail_x15_r0_body.st184.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site184 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts184
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site184 r hr) hi (MapOk.sub hm (sub_of_all bodySub184)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk184 r hr) hi hm ho hq)
    bodyLq184 rfl bodyNrLo184 (postSub_sound bodyPost184)
    (Nat.le_of_ble_eq_true bodyDrop184) (by decide) (Nat.le_of_ble_eq_true bodyDropH184) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN184) (by decide)
    bodyDv184 bodyDe184 bodyDl184 bodyDold184 bodyDfree184 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
