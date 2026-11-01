import host.sim.compose.a4b.vw15.VWBodyJ83
import host.sim.compose.a4b.vw15.VWBodySite83
import host.sim.compose.a4b.vw15.VWBodyOracles_20
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift83 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S804.tab.length PRE_first_tail_x15_r0_body.s804.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P83.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P83 3601 PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.s806.ffi PRE_first_tail_x15_r0_body.s805.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_83
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_83
  have hcl : SSt (· < 3601) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S804.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_83] <;> decide) PRE_first_tail_x15_r0_body.cnodesK83 PRE_first_tail_x15_r0_body.cobjsK83
      PRE_first_tail_x15_r0_body.citemsK83 PRE_first_tail_x15_r0_body.cbd83 PRE_first_tail_x15_r0_body.csst83
  exact PRE_first_tail_x15_r0_body.cshift83 bodyNcl83 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_83] at this; exact this)


kernel_rfl bodyFramesEmpty83 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s805 a).isEmpty) = true
kernel_rfl bodyJsRoots83 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s804.next) PRE_first_tail_x15_r0_body.s806.trace PRE_first_tail_x15_r0_body.s806 = true
kernel_rfl bodyJsNative83 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s806.ffi) = true
kernel_rfl bodyLow83 : (PRE_first_tail_x15_r0_body.cws83 ++ PRE_first_tail_x15_r0_body.ws83).all (Nat.ble 9) = true
kernel_rfl bodyCntM83 : countersOkB PRE_first_tail_x15_r0_body.s804 PRE_first_tail_x15_r0_body.s805 = true
kernel_rfl bodyHi83 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s806.ffi).next setupP.E = true
kernel_rfl bodyNhi83 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s806.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge83 : bridgeOf PRE_first_tail_x15_r0_body.s805.ffi = bridgeOf PRE_first_tail_x15_r0_body.s804.ffi
kernel_rfl bodyNN83 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s804.ffi).nnext PRE_first_tail_x15_r0_body.P83.NL = true
kernel_rfl bodyXn83 : Nat.ble (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s806.ffi).next = true
kernel_rfl bodyLo83 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s806.ffi).next = true
theorem bodyFacts83 : BodySiteFacts PRE_first_tail_x15_r0_body.s804 PRE_first_tail_x15_r0_body.s805 PRE_first_tail_x15_r0_body.s806 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S804 PRE_first_tail_x15_r0_body.S805 PRE_first_tail_x15_r0_body.S806
    PRE_first_tail_x15_r0_body.ws83 PRE_first_tail_x15_r0_body.cws83 PRE_first_tail_x15_r0_body.nr83 PRE_first_tail_x15_r0_body.pl83 PRE_first_tail_x15_r0_body.cl83 2739888 3601 PRE_first_tail_x15_r0_body.kd83 PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.P83
    ⟨19833, 16918, 2739877, 3601⟩ ⟨19833, 16918, 2739878, 3601⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap83
  clean := bodyClean83
  cfix := PRE_first_tail_x15_r0_body.cfix83
  zpl := PRE_first_tail_x15_r0_body.zpl83
  zplnd := PRE_first_tail_x15_r0_body.zplnd83
  zn1 := PRE_first_tail_x15_r0_body.zn183
  zfirst := PRE_first_tail_x15_r0_body.zfirst83
  zscn := PRE_first_tail_x15_r0_body.zscn83
  zsmn := PRE_first_tail_x15_r0_body.zsmn83
  zgrow := PRE_first_tail_x15_r0_body.zgrow83
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab83
  zfresh := PRE_first_tail_x15_r0_body.zfresh83
  zcnd := PRE_first_tail_x15_r0_body.zcnd83
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi83
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt83
  zgP := PRE_first_tail_x15_r0_body.zg83_2665
  zkP := PRE_first_tail_x15_r0_body.zk83_2665
  zmP := PRE_first_tail_x15_r0_body.zm83_2665
  zgC := PRE_first_tail_x15_r0_body.zg83_2673467
  zkC := PRE_first_tail_x15_r0_body.zk83_2673467
  zmC := PRE_first_tail_x15_r0_body.zm83_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw83_2673472
  zwV := PRE_first_tail_x15_r0_body.zw83_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap83
  zclbd := PRE_first_tail_x15_r0_body.zclbd83
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap83 PRE_first_tail_x15_r0_body.stFoot83 PRE_first_tail_x15_r0_body.iso83 PRE_first_tail_x15_r0_body.zwr83
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP83
  csupp := PRE_first_tail_x15_r0_body.csupp83
  cbound := PRE_first_tail_x15_r0_body.cbound83
  zimg := PRE_first_tail_x15_r0_body.zimg83
  zctl := PRE_first_tail_x15_r0_body.zctl83
  zstack := PRE_first_tail_x15_r0_body.zstack83
  zjobs := PRE_first_tail_x15_r0_body.zjobs83
  zstores := PRE_first_tail_x15_r0_body.zstores83
  zroots := PRE_first_tail_x15_r0_body.zroots83
  znC := PRE_first_tail_x15_r0_body.znC83
  ctab := PRE_first_tail_x15_r0_body.ctab83
  zbin := PRE_first_tail_x15_r0_body.zbin83
  cbridge := PRE_first_tail_x15_r0_body.cbridge83
  sbridge := bodyBridge83
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj83
  cshiftR := fun h hNL => bodyCshift83 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN83
  raised := PRE_first_tail_x15_r0_body.raised83
  cbigs := PRE_first_tail_x15_r0_body.cbigs83
  cjcl := PRE_first_tail_x15_r0_body.cjcl83
  xnLe := Nat.le_of_ble_eq_true bodyXn83
  loLe := Nat.le_of_ble_eq_true bodyLo83
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB83
  cntM := bodyCntM83
  hiLe := Nat.le_of_ble_eq_true bodyHi83
  nhiLe := Nat.le_of_ble_eq_true bodyNhi83
  jsHeap := bodyJs83
  jsRoots := bodyJsRoots83
  jsNative := bodyJsNative83
  framesEmpty := bodyFramesEmpty83
  trailOld := by decide
  lowVars := bodyLow83

def bodyQs83 : List (Option Q) := []
noncomputable def bodyEs83 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr83.map fun r => nth? PRE_first_tail_x15_r0_body.st83.S2.tab r
kernel_rfl bodyResChk83 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs83 bodyQs83) = true
kernel_rfl bodyLq83 : bodyQs83.length = PRE_first_tail_x15_r0_body.cws83.length
kernel_rfl bodyNrLo83 : PRE_first_tail_x15_r0_body.nr83.all (Nat.ble PRE_first_tail_x15_r0_body.S804.tab.length) = true
kernel_rfl bodySub83 : (Oracles.PRE_first_tail_x15_r0_body.map_site83.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost83 : postSubB bodyM PRE_first_tail_x15_r0_body.ws83 PRE_first_tail_x15_r0_body.cws83 bodyQs83 = true
kernel_rfl bodyDrop83 : Nat.ble (31082 + (PRE_first_tail_x15_r0_body.s805.next - PRE_first_tail_x15_r0_body.s806.next)) 31092 = true
kernel_rfl bodyDropH83 : Nat.ble (560 + ((mlxOf PRE_first_tail_x15_r0_body.s805.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s806.ffi).next)) 560 = true
kernel_rfl bodyDropN83 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s805.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s806.ffi).nnext)) 0 = true
kernel_rfl bodyDv83 : bodyΘ.1.take 441 = bodyΘ.1.take 441 ++ PRE_first_tail_x15_r0_body.cws83
kernel_rfl bodyDe83 : bodyΘ.2.take 441 = bodyΘ.2.take 441 ++ PRE_first_tail_x15_r0_body.nr83.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st83.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 441) (bodyΘ.2.take 441)))
kernel_rfl bodyDl83 : (bodyΘ.1.take 441).length = (bodyΘ.2.take 441).length
kernel_rfl bodyDold83 : (bodyΘ.1.take 441).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws83).isNone && !PRE_first_tail_x15_r0_body.ws83.contains v) = true
kernel_rfl bodyDfree83 : (bodyΘ.2.take 441).all (fun e => (PRE_first_tail_x15_r0_body.cws83 ++ PRE_first_tail_x15_r0_body.ws83).all fun w => e.noVar w) = true

theorem bodyStep83 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨31082, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s804 PRE_first_tail_x15_r0_body.S804)
      (bodyCut NB T tk π i x0 bodyΘ ⟨31092, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s806 PRE_first_tail_x15_r0_body.S806) (98 + 1) :=
  bodySite bodyFacts83.cfix bodyFacts83.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st83.S2.tab) (Es := bodyEs83) (qs := bodyQs83)
    (ok := PRE_first_tail_x15_r0_body.st83.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site83 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts83
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site83 r hr) hi (MapOk.sub hm (sub_of_all bodySub83)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk83 r hr) hi hm ho hq)
    bodyLq83 rfl bodyNrLo83 (postSub_sound bodyPost83)
    (Nat.le_of_ble_eq_true bodyDrop83) (by decide) (Nat.le_of_ble_eq_true bodyDropH83) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN83) (by decide)
    bodyDv83 bodyDe83 bodyDl83 bodyDold83 bodyDfree83 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
