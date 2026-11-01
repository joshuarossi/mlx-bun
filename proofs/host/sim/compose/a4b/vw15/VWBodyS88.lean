import host.sim.compose.a4b.vw15.VWBodyJ88
import host.sim.compose.a4b.vw15.VWBodySite88
import host.sim.compose.a4b.vw15.VWBodyOracles_22
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

theorem bodyCshift88 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S858.tab.length PRE_first_tail_x15_r0_body.s858.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P88.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P88 3842 PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.s860.ffi PRE_first_tail_x15_r0_body.s859.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_88
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_88
  have hcl : SSt (· < 3842) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S858.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_88] <;> decide) PRE_first_tail_x15_r0_body.cnodesK88 PRE_first_tail_x15_r0_body.cobjsK88
      PRE_first_tail_x15_r0_body.citemsK88 PRE_first_tail_x15_r0_body.cbd88 PRE_first_tail_x15_r0_body.csst88
  exact PRE_first_tail_x15_r0_body.cshift88 bodyNcl88 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_88] at this; exact this)


kernel_rfl bodyFramesEmpty88 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s859 a).isEmpty) = true
kernel_rfl bodyJsRoots88 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s858.next) PRE_first_tail_x15_r0_body.s860.trace PRE_first_tail_x15_r0_body.s860 = true
kernel_rfl bodyJsNative88 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s860.ffi) = true
kernel_rfl bodyLow88 : (PRE_first_tail_x15_r0_body.cws88 ++ PRE_first_tail_x15_r0_body.ws88).all (Nat.ble 9) = true
kernel_rfl bodyCntM88 : countersOkB PRE_first_tail_x15_r0_body.s858 PRE_first_tail_x15_r0_body.s859 = true
kernel_rfl bodyHi88 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s860.ffi).next setupP.E = true
kernel_rfl bodyNhi88 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s860.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge88 : bridgeOf PRE_first_tail_x15_r0_body.s859.ffi = bridgeOf PRE_first_tail_x15_r0_body.s858.ffi
kernel_rfl bodyNN88 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s858.ffi).nnext PRE_first_tail_x15_r0_body.P88.NL = true
kernel_rfl bodyXn88 : Nat.ble (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s860.ffi).next = true
kernel_rfl bodyLo88 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s860.ffi).next = true
theorem bodyFacts88 : BodySiteFacts PRE_first_tail_x15_r0_body.s858 PRE_first_tail_x15_r0_body.s859 PRE_first_tail_x15_r0_body.s860 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S858 PRE_first_tail_x15_r0_body.S859 PRE_first_tail_x15_r0_body.S860
    PRE_first_tail_x15_r0_body.ws88 PRE_first_tail_x15_r0_body.cws88 PRE_first_tail_x15_r0_body.nr88 PRE_first_tail_x15_r0_body.pl88 PRE_first_tail_x15_r0_body.cl88 2744125 3842 PRE_first_tail_x15_r0_body.kd88 PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.P88
    ⟨19941, 17040, 2744123, 3842⟩ ⟨19941, 17040, 2744123, 3842⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap88
  clean := bodyClean88
  cfix := PRE_first_tail_x15_r0_body.cfix88
  zpl := PRE_first_tail_x15_r0_body.zpl88
  zplnd := PRE_first_tail_x15_r0_body.zplnd88
  zn1 := PRE_first_tail_x15_r0_body.zn188
  zfirst := PRE_first_tail_x15_r0_body.zfirst88
  zscn := PRE_first_tail_x15_r0_body.zscn88
  zsmn := PRE_first_tail_x15_r0_body.zsmn88
  zgrow := PRE_first_tail_x15_r0_body.zgrow88
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab88
  zfresh := PRE_first_tail_x15_r0_body.zfresh88
  zcnd := PRE_first_tail_x15_r0_body.zcnd88
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi88
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt88
  zgP := PRE_first_tail_x15_r0_body.zg88_2665
  zkP := PRE_first_tail_x15_r0_body.zk88_2665
  zmP := PRE_first_tail_x15_r0_body.zm88_2665
  zgC := PRE_first_tail_x15_r0_body.zg88_2673467
  zkC := PRE_first_tail_x15_r0_body.zk88_2673467
  zmC := PRE_first_tail_x15_r0_body.zm88_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw88_2673472
  zwV := PRE_first_tail_x15_r0_body.zw88_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap88
  zclbd := PRE_first_tail_x15_r0_body.zclbd88
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap88 PRE_first_tail_x15_r0_body.stFoot88 PRE_first_tail_x15_r0_body.iso88 PRE_first_tail_x15_r0_body.zwr88
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP88
  csupp := PRE_first_tail_x15_r0_body.csupp88
  cbound := PRE_first_tail_x15_r0_body.cbound88
  zimg := PRE_first_tail_x15_r0_body.zimg88
  zctl := PRE_first_tail_x15_r0_body.zctl88
  zstack := PRE_first_tail_x15_r0_body.zstack88
  zjobs := PRE_first_tail_x15_r0_body.zjobs88
  zstores := PRE_first_tail_x15_r0_body.zstores88
  zroots := PRE_first_tail_x15_r0_body.zroots88
  znC := PRE_first_tail_x15_r0_body.znC88
  ctab := PRE_first_tail_x15_r0_body.ctab88
  zbin := PRE_first_tail_x15_r0_body.zbin88
  cbridge := PRE_first_tail_x15_r0_body.cbridge88
  sbridge := bodyBridge88
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj88
  cshiftR := fun h hNL => bodyCshift88 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN88
  raised := PRE_first_tail_x15_r0_body.raised88
  cbigs := PRE_first_tail_x15_r0_body.cbigs88
  cjcl := PRE_first_tail_x15_r0_body.cjcl88
  xnLe := Nat.le_of_ble_eq_true bodyXn88
  loLe := Nat.le_of_ble_eq_true bodyLo88
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB88
  cntM := bodyCntM88
  hiLe := Nat.le_of_ble_eq_true bodyHi88
  nhiLe := Nat.le_of_ble_eq_true bodyNhi88
  jsHeap := bodyJs88
  jsRoots := bodyJsRoots88
  jsNative := bodyJsNative88
  framesEmpty := bodyFramesEmpty88
  trailOld := by decide
  lowVars := bodyLow88

def bodyQs88 : List (Option Q) := []
noncomputable def bodyEs88 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr88.map fun r => nth? PRE_first_tail_x15_r0_body.st88.S2.tab r
kernel_rfl bodyResChk88 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs88 bodyQs88) = true
kernel_rfl bodyLq88 : bodyQs88.length = PRE_first_tail_x15_r0_body.cws88.length
kernel_rfl bodyNrLo88 : PRE_first_tail_x15_r0_body.nr88.all (Nat.ble PRE_first_tail_x15_r0_body.S858.tab.length) = true
kernel_rfl bodySub88 : (Oracles.PRE_first_tail_x15_r0_body.map_site88.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost88 : postSubB bodyM PRE_first_tail_x15_r0_body.ws88 PRE_first_tail_x15_r0_body.cws88 bodyQs88 = true
kernel_rfl bodyDrop88 : Nat.ble (33402 + (PRE_first_tail_x15_r0_body.s859.next - PRE_first_tail_x15_r0_body.s860.next)) 33404 = true
kernel_rfl bodyDropH88 : Nat.ble (610 + ((mlxOf PRE_first_tail_x15_r0_body.s859.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s860.ffi).next)) 610 = true
kernel_rfl bodyDropN88 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s859.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s860.ffi).nnext)) 0 = true
kernel_rfl bodyDv88 : bodyΘ.1.take 477 = bodyΘ.1.take 477 ++ PRE_first_tail_x15_r0_body.cws88
kernel_rfl bodyDe88 : bodyΘ.2.take 477 = bodyΘ.2.take 477 ++ PRE_first_tail_x15_r0_body.nr88.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st88.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 477) (bodyΘ.2.take 477)))
kernel_rfl bodyDl88 : (bodyΘ.1.take 477).length = (bodyΘ.2.take 477).length
kernel_rfl bodyDold88 : (bodyΘ.1.take 477).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws88).isNone && !PRE_first_tail_x15_r0_body.ws88.contains v) = true
kernel_rfl bodyDfree88 : (bodyΘ.2.take 477).all (fun e => (PRE_first_tail_x15_r0_body.cws88 ++ PRE_first_tail_x15_r0_body.ws88).all fun w => e.noVar w) = true

theorem bodyStep88 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨33402, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s858 PRE_first_tail_x15_r0_body.S858)
      (bodyCut NB T tk π i x0 bodyΘ ⟨33404, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s860 PRE_first_tail_x15_r0_body.S860) (27 + 1) :=
  bodySite bodyFacts88.cfix bodyFacts88.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st88.S2.tab) (Es := bodyEs88) (qs := bodyQs88)
    (ok := PRE_first_tail_x15_r0_body.st88.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site88 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts88
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site88 r hr) hi (MapOk.sub hm (sub_of_all bodySub88)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk88 r hr) hi hm ho hq)
    bodyLq88 rfl bodyNrLo88 (postSub_sound bodyPost88)
    (Nat.le_of_ble_eq_true bodyDrop88) (by decide) (Nat.le_of_ble_eq_true bodyDropH88) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN88) (by decide)
    bodyDv88 bodyDe88 bodyDl88 bodyDold88 bodyDfree88 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
