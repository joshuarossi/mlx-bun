import host.sim.compose.a4b.vw15.VWBodyJ40
import host.sim.compose.a4b.vw15.VWBodySite40
import host.sim.compose.a4b.vw15.VWBodyOracles_10
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift40 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S398.tab.length PRE_first_tail_x15_r0_body.s398.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P40.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P40 1790 PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.s400.ffi PRE_first_tail_x15_r0_body.s399.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_40
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_40
  have hcl : SSt (· < 1790) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s400.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S398.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_40] <;> decide) PRE_first_tail_x15_r0_body.cnodesK40 PRE_first_tail_x15_r0_body.cobjsK40
      PRE_first_tail_x15_r0_body.citemsK40 PRE_first_tail_x15_r0_body.cbd40 PRE_first_tail_x15_r0_body.csst40
  exact PRE_first_tail_x15_r0_body.cshift40 bodyNcl40 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_40] at this; exact this)


kernel_rfl bodyFramesEmpty40 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s399 a).isEmpty) = true
kernel_rfl bodyJsRoots40 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s398.next) PRE_first_tail_x15_r0_body.s400.trace PRE_first_tail_x15_r0_body.s400 = true
kernel_rfl bodyJsNative40 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s400.ffi) = true
kernel_rfl bodyLow40 : (PRE_first_tail_x15_r0_body.cws40 ++ PRE_first_tail_x15_r0_body.ws40).all (Nat.ble 9) = true
kernel_rfl bodyCntM40 : countersOkB PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.s399 = true
kernel_rfl bodyHi40 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).next setupP.E = true
kernel_rfl bodyNhi40 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge40 : bridgeOf PRE_first_tail_x15_r0_body.s399.ffi = bridgeOf PRE_first_tail_x15_r0_body.s398.ffi
kernel_rfl bodyNN40 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s398.ffi).nnext PRE_first_tail_x15_r0_body.P40.NL = true
kernel_rfl bodyXn40 : Nat.ble (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).next = true
kernel_rfl bodyLo40 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).next = true
theorem bodyFacts40 : BodySiteFacts PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.s399 PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S398 PRE_first_tail_x15_r0_body.S399 PRE_first_tail_x15_r0_body.S400
    PRE_first_tail_x15_r0_body.ws40 PRE_first_tail_x15_r0_body.cws40 PRE_first_tail_x15_r0_body.nr40 PRE_first_tail_x15_r0_body.pl40 PRE_first_tail_x15_r0_body.cl40 2706457 1790 PRE_first_tail_x15_r0_body.kd40 PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.P40
    ⟨18997, 16092, 2706455, 1790⟩ ⟨18997, 16092, 2706455, 1790⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap40
  clean := bodyClean40
  cfix := PRE_first_tail_x15_r0_body.cfix40
  zpl := PRE_first_tail_x15_r0_body.zpl40
  zplnd := PRE_first_tail_x15_r0_body.zplnd40
  zn1 := PRE_first_tail_x15_r0_body.zn140
  zfirst := PRE_first_tail_x15_r0_body.zfirst40
  zscn := PRE_first_tail_x15_r0_body.zscn40
  zsmn := PRE_first_tail_x15_r0_body.zsmn40
  zgrow := PRE_first_tail_x15_r0_body.zgrow40
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab40
  zfresh := PRE_first_tail_x15_r0_body.zfresh40
  zcnd := PRE_first_tail_x15_r0_body.zcnd40
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi40
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt40
  zgP := PRE_first_tail_x15_r0_body.zg40_2665
  zkP := PRE_first_tail_x15_r0_body.zk40_2665
  zmP := PRE_first_tail_x15_r0_body.zm40_2665
  zgC := PRE_first_tail_x15_r0_body.zg40_2673467
  zkC := PRE_first_tail_x15_r0_body.zk40_2673467
  zmC := PRE_first_tail_x15_r0_body.zm40_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw40_2673472
  zwV := PRE_first_tail_x15_r0_body.zw40_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap40
  zclbd := PRE_first_tail_x15_r0_body.zclbd40
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap40 PRE_first_tail_x15_r0_body.stFoot40 PRE_first_tail_x15_r0_body.iso40 PRE_first_tail_x15_r0_body.zwr40
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP40
  csupp := PRE_first_tail_x15_r0_body.csupp40
  cbound := PRE_first_tail_x15_r0_body.cbound40
  zimg := PRE_first_tail_x15_r0_body.zimg40
  zctl := PRE_first_tail_x15_r0_body.zctl40
  zstack := PRE_first_tail_x15_r0_body.zstack40
  zjobs := PRE_first_tail_x15_r0_body.zjobs40
  zstores := PRE_first_tail_x15_r0_body.zstores40
  zroots := PRE_first_tail_x15_r0_body.zroots40
  znC := PRE_first_tail_x15_r0_body.znC40
  ctab := PRE_first_tail_x15_r0_body.ctab40
  zbin := PRE_first_tail_x15_r0_body.zbin40
  cbridge := PRE_first_tail_x15_r0_body.cbridge40
  sbridge := bodyBridge40
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj40
  cshiftR := fun h hNL => bodyCshift40 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN40
  raised := PRE_first_tail_x15_r0_body.raised40
  cbigs := PRE_first_tail_x15_r0_body.cbigs40
  cjcl := PRE_first_tail_x15_r0_body.cjcl40
  xnLe := Nat.le_of_ble_eq_true bodyXn40
  loLe := Nat.le_of_ble_eq_true bodyLo40
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB40
  cntM := bodyCntM40
  hiLe := Nat.le_of_ble_eq_true bodyHi40
  nhiLe := Nat.le_of_ble_eq_true bodyNhi40
  jsHeap := bodyJs40
  jsRoots := bodyJsRoots40
  jsNative := bodyJsNative40
  framesEmpty := bodyFramesEmpty40
  trailOld := by decide
  lowVars := bodyLow40

def bodyQs40 : List (Option Q) := []
noncomputable def bodyEs40 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr40.map fun r => nth? PRE_first_tail_x15_r0_body.st40.S2.tab r
kernel_rfl bodyResChk40 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs40 bodyQs40) = true
kernel_rfl bodyLq40 : bodyQs40.length = PRE_first_tail_x15_r0_body.cws40.length
kernel_rfl bodyNrLo40 : PRE_first_tail_x15_r0_body.nr40.all (Nat.ble PRE_first_tail_x15_r0_body.S398.tab.length) = true
kernel_rfl bodySub40 : (Oracles.PRE_first_tail_x15_r0_body.map_site40.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost40 : postSubB bodyM PRE_first_tail_x15_r0_body.ws40 PRE_first_tail_x15_r0_body.cws40 bodyQs40 = true
kernel_rfl bodyDrop40 : Nat.ble (17977 + (PRE_first_tail_x15_r0_body.s399.next - PRE_first_tail_x15_r0_body.s400.next)) 17979 = true
kernel_rfl bodyDropH40 : Nat.ble (302 + ((mlxOf PRE_first_tail_x15_r0_body.s399.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).next)) 302 = true
kernel_rfl bodyDropN40 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s399.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s400.ffi).nnext)) 0 = true
kernel_rfl bodyDv40 : bodyΘ.1.take 225 = bodyΘ.1.take 225 ++ PRE_first_tail_x15_r0_body.cws40
kernel_rfl bodyDe40 : bodyΘ.2.take 225 = bodyΘ.2.take 225 ++ PRE_first_tail_x15_r0_body.nr40.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st40.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 225) (bodyΘ.2.take 225)))
kernel_rfl bodyDl40 : (bodyΘ.1.take 225).length = (bodyΘ.2.take 225).length
kernel_rfl bodyDold40 : (bodyΘ.1.take 225).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws40).isNone && !PRE_first_tail_x15_r0_body.ws40.contains v) = true
kernel_rfl bodyDfree40 : (bodyΘ.2.take 225).all (fun e => (PRE_first_tail_x15_r0_body.cws40 ++ PRE_first_tail_x15_r0_body.ws40).all fun w => e.noVar w) = true

theorem bodyStep40 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17977, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.S398)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.S400) (27 + 1) :=
  bodySite bodyFacts40.cfix bodyFacts40.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st40.S2.tab) (Es := bodyEs40) (qs := bodyQs40)
    (ok := PRE_first_tail_x15_r0_body.st40.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site40 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts40
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site40 r hr) hi (MapOk.sub hm (sub_of_all bodySub40)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk40 r hr) hi hm ho hq)
    bodyLq40 rfl bodyNrLo40 (postSub_sound bodyPost40)
    (Nat.le_of_ble_eq_true bodyDrop40) (by decide) (Nat.le_of_ble_eq_true bodyDropH40) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN40) (by decide)
    bodyDv40 bodyDe40 bodyDl40 bodyDold40 bodyDfree40 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
