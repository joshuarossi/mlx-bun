import host.sim.compose.a4b.vw15.VWBodyJ16
import host.sim.compose.a4b.vw15.VWBodySite16
import host.sim.compose.a4b.vw15.VWBodyOracles_4
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift16 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S168.tab.length PRE_first_tail_x15_r0_body.s168.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P16.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P16 764 PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.s170.ffi PRE_first_tail_x15_r0_body.s169.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_16
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_16
  have hcl : SSt (· < 764) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S168.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_16] <;> decide) PRE_first_tail_x15_r0_body.cnodesK16 PRE_first_tail_x15_r0_body.cobjsK16
      PRE_first_tail_x15_r0_body.citemsK16 PRE_first_tail_x15_r0_body.cbd16 PRE_first_tail_x15_r0_body.csst16
  exact PRE_first_tail_x15_r0_body.cshift16 bodyNcl16 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_16] at this; exact this)


kernel_rfl bodyFramesEmpty16 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s169 a).isEmpty) = true
kernel_rfl bodyJsRoots16 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s168.next) PRE_first_tail_x15_r0_body.s170.trace PRE_first_tail_x15_r0_body.s170 = true
kernel_rfl bodyJsNative16 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s170.ffi) = true
kernel_rfl bodyLow16 : (PRE_first_tail_x15_r0_body.cws16 ++ PRE_first_tail_x15_r0_body.ws16).all (Nat.ble 9) = true
kernel_rfl bodyCntM16 : countersOkB PRE_first_tail_x15_r0_body.s168 PRE_first_tail_x15_r0_body.s169 = true
kernel_rfl bodyHi16 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s170.ffi).next setupP.E = true
kernel_rfl bodyNhi16 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s170.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge16 : bridgeOf PRE_first_tail_x15_r0_body.s169.ffi = bridgeOf PRE_first_tail_x15_r0_body.s168.ffi
kernel_rfl bodyNN16 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s168.ffi).nnext PRE_first_tail_x15_r0_body.P16.NL = true
kernel_rfl bodyXn16 : Nat.ble (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s170.ffi).next = true
kernel_rfl bodyLo16 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s170.ffi).next = true
theorem bodyFacts16 : BodySiteFacts PRE_first_tail_x15_r0_body.s168 PRE_first_tail_x15_r0_body.s169 PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S168 PRE_first_tail_x15_r0_body.S169 PRE_first_tail_x15_r0_body.S170
    PRE_first_tail_x15_r0_body.ws16 PRE_first_tail_x15_r0_body.cws16 PRE_first_tail_x15_r0_body.nr16 PRE_first_tail_x15_r0_body.pl16 PRE_first_tail_x15_r0_body.cl16 2687629 764 PRE_first_tail_x15_r0_body.kd16 PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.P16
    ⟨18525, 15618, 2687627, 764⟩ ⟨18525, 15618, 2687627, 764⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap16
  clean := bodyClean16
  cfix := PRE_first_tail_x15_r0_body.cfix16
  zpl := PRE_first_tail_x15_r0_body.zpl16
  zplnd := PRE_first_tail_x15_r0_body.zplnd16
  zn1 := PRE_first_tail_x15_r0_body.zn116
  zfirst := PRE_first_tail_x15_r0_body.zfirst16
  zscn := PRE_first_tail_x15_r0_body.zscn16
  zsmn := PRE_first_tail_x15_r0_body.zsmn16
  zgrow := PRE_first_tail_x15_r0_body.zgrow16
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab16
  zfresh := PRE_first_tail_x15_r0_body.zfresh16
  zcnd := PRE_first_tail_x15_r0_body.zcnd16
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi16
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt16
  zgP := PRE_first_tail_x15_r0_body.zg16_2665
  zkP := PRE_first_tail_x15_r0_body.zk16_2665
  zmP := PRE_first_tail_x15_r0_body.zm16_2665
  zgC := PRE_first_tail_x15_r0_body.zg16_2673467
  zkC := PRE_first_tail_x15_r0_body.zk16_2673467
  zmC := PRE_first_tail_x15_r0_body.zm16_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw16_2673472
  zwV := PRE_first_tail_x15_r0_body.zw16_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap16
  zclbd := PRE_first_tail_x15_r0_body.zclbd16
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap16 PRE_first_tail_x15_r0_body.stFoot16 PRE_first_tail_x15_r0_body.iso16 PRE_first_tail_x15_r0_body.zwr16
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP16
  csupp := PRE_first_tail_x15_r0_body.csupp16
  cbound := PRE_first_tail_x15_r0_body.cbound16
  zimg := PRE_first_tail_x15_r0_body.zimg16
  zctl := PRE_first_tail_x15_r0_body.zctl16
  zstack := PRE_first_tail_x15_r0_body.zstack16
  zjobs := PRE_first_tail_x15_r0_body.zjobs16
  zstores := PRE_first_tail_x15_r0_body.zstores16
  zroots := PRE_first_tail_x15_r0_body.zroots16
  znC := PRE_first_tail_x15_r0_body.znC16
  ctab := PRE_first_tail_x15_r0_body.ctab16
  zbin := PRE_first_tail_x15_r0_body.zbin16
  cbridge := PRE_first_tail_x15_r0_body.cbridge16
  sbridge := bodyBridge16
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj16
  cshiftR := fun h hNL => bodyCshift16 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN16
  raised := PRE_first_tail_x15_r0_body.raised16
  cbigs := PRE_first_tail_x15_r0_body.cbigs16
  cjcl := PRE_first_tail_x15_r0_body.cjcl16
  xnLe := Nat.le_of_ble_eq_true bodyXn16
  loLe := Nat.le_of_ble_eq_true bodyLo16
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB16
  cntM := bodyCntM16
  hiLe := Nat.le_of_ble_eq_true bodyHi16
  nhiLe := Nat.le_of_ble_eq_true bodyNhi16
  jsHeap := bodyJs16
  jsRoots := bodyJsRoots16
  jsNative := bodyJsNative16
  framesEmpty := bodyFramesEmpty16
  trailOld := by decide
  lowVars := bodyLow16

def bodyQs16 : List (Option Q) := []
noncomputable def bodyEs16 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr16.map fun r => nth? PRE_first_tail_x15_r0_body.st16.S2.tab r
kernel_rfl bodyResChk16 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs16 bodyQs16) = true
kernel_rfl bodyLq16 : bodyQs16.length = PRE_first_tail_x15_r0_body.cws16.length
kernel_rfl bodyNrLo16 : PRE_first_tail_x15_r0_body.nr16.all (Nat.ble PRE_first_tail_x15_r0_body.S168.tab.length) = true
kernel_rfl bodySub16 : (Oracles.PRE_first_tail_x15_r0_body.map_site16.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost16 : postSubB bodyM PRE_first_tail_x15_r0_body.ws16 PRE_first_tail_x15_r0_body.cws16 bodyQs16 = true
kernel_rfl bodyDrop16 : Nat.ble (10278 + (PRE_first_tail_x15_r0_body.s169.next - PRE_first_tail_x15_r0_body.s170.next)) 10280 = true
kernel_rfl bodyDropH16 : Nat.ble (148 + ((mlxOf PRE_first_tail_x15_r0_body.s169.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s170.ffi).next)) 148 = true
kernel_rfl bodyDropN16 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s169.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s170.ffi).nnext)) 0 = true
kernel_rfl bodyDv16 : bodyΘ.1.take 99 = bodyΘ.1.take 99 ++ PRE_first_tail_x15_r0_body.cws16
kernel_rfl bodyDe16 : bodyΘ.2.take 99 = bodyΘ.2.take 99 ++ PRE_first_tail_x15_r0_body.nr16.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st16.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 99) (bodyΘ.2.take 99)))
kernel_rfl bodyDl16 : (bodyΘ.1.take 99).length = (bodyΘ.2.take 99).length
kernel_rfl bodyDold16 : (bodyΘ.1.take 99).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws16).isNone && !PRE_first_tail_x15_r0_body.ws16.contains v) = true
kernel_rfl bodyDfree16 : (bodyΘ.2.take 99).all (fun e => (PRE_first_tail_x15_r0_body.cws16 ++ PRE_first_tail_x15_r0_body.ws16).all fun w => e.noVar w) = true

theorem bodyStep16 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10278, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s168 PRE_first_tail_x15_r0_body.S168)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10280, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.S170) (27 + 1) :=
  bodySite bodyFacts16.cfix bodyFacts16.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st16.S2.tab) (Es := bodyEs16) (qs := bodyQs16)
    (ok := PRE_first_tail_x15_r0_body.st16.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site16 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts16
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site16 r hr) hi (MapOk.sub hm (sub_of_all bodySub16)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk16 r hr) hi hm ho hq)
    bodyLq16 rfl bodyNrLo16 (postSub_sound bodyPost16)
    (Nat.le_of_ble_eq_true bodyDrop16) (by decide) (Nat.le_of_ble_eq_true bodyDropH16) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN16) (by decide)
    bodyDv16 bodyDe16 bodyDl16 bodyDold16 bodyDfree16 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
