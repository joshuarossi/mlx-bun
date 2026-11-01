import host.sim.compose.a4b.vw15.VWBodyJ89
import host.sim.compose.a4b.vw15.VWBodySite89
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

theorem bodyCshift89 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S862.tab.length PRE_first_tail_x15_r0_body.s862.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P89.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P89 3859 PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.s864.ffi PRE_first_tail_x15_r0_body.s863.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_89
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_89
  have hcl : SSt (· < 3859) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S862.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_89] <;> decide) PRE_first_tail_x15_r0_body.cnodesK89 PRE_first_tail_x15_r0_body.cobjsK89
      PRE_first_tail_x15_r0_body.citemsK89 PRE_first_tail_x15_r0_body.cbd89 PRE_first_tail_x15_r0_body.csst89
  exact PRE_first_tail_x15_r0_body.cshift89 bodyNcl89 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_89] at this; exact this)


kernel_rfl bodyFramesEmpty89 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s863 a).isEmpty) = true
kernel_rfl bodyJsRoots89 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s862.next) PRE_first_tail_x15_r0_body.s864.trace PRE_first_tail_x15_r0_body.s864 = true
kernel_rfl bodyJsNative89 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s864.ffi) = true
kernel_rfl bodyLow89 : (PRE_first_tail_x15_r0_body.cws89 ++ PRE_first_tail_x15_r0_body.ws89).all (Nat.ble 9) = true
kernel_rfl bodyCntM89 : countersOkB PRE_first_tail_x15_r0_body.s862 PRE_first_tail_x15_r0_body.s863 = true
kernel_rfl bodyHi89 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s864.ffi).next setupP.E = true
kernel_rfl bodyNhi89 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s864.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge89 : bridgeOf PRE_first_tail_x15_r0_body.s863.ffi = bridgeOf PRE_first_tail_x15_r0_body.s862.ffi
kernel_rfl bodyNN89 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s862.ffi).nnext PRE_first_tail_x15_r0_body.P89.NL = true
kernel_rfl bodyXn89 : Nat.ble (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s864.ffi).next = true
kernel_rfl bodyLo89 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s864.ffi).next = true
theorem bodyFacts89 : BodySiteFacts PRE_first_tail_x15_r0_body.s862 PRE_first_tail_x15_r0_body.s863 PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S862 PRE_first_tail_x15_r0_body.S863 PRE_first_tail_x15_r0_body.S864
    PRE_first_tail_x15_r0_body.ws89 PRE_first_tail_x15_r0_body.cws89 PRE_first_tail_x15_r0_body.nr89 PRE_first_tail_x15_r0_body.pl89 PRE_first_tail_x15_r0_body.cl89 2744431 3859 PRE_first_tail_x15_r0_body.kd89 PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.P89
    ⟨19948, 17044, 2744411, 3859⟩ ⟨19948, 17044, 2744412, 3859⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap89
  clean := bodyClean89
  cfix := PRE_first_tail_x15_r0_body.cfix89
  zpl := PRE_first_tail_x15_r0_body.zpl89
  zplnd := PRE_first_tail_x15_r0_body.zplnd89
  zn1 := PRE_first_tail_x15_r0_body.zn189
  zfirst := PRE_first_tail_x15_r0_body.zfirst89
  zscn := PRE_first_tail_x15_r0_body.zscn89
  zsmn := PRE_first_tail_x15_r0_body.zsmn89
  zgrow := PRE_first_tail_x15_r0_body.zgrow89
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab89
  zfresh := PRE_first_tail_x15_r0_body.zfresh89
  zcnd := PRE_first_tail_x15_r0_body.zcnd89
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi89
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt89
  zgP := PRE_first_tail_x15_r0_body.zg89_2665
  zkP := PRE_first_tail_x15_r0_body.zk89_2665
  zmP := PRE_first_tail_x15_r0_body.zm89_2665
  zgC := PRE_first_tail_x15_r0_body.zg89_2673467
  zkC := PRE_first_tail_x15_r0_body.zk89_2673467
  zmC := PRE_first_tail_x15_r0_body.zm89_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw89_2673472
  zwV := PRE_first_tail_x15_r0_body.zw89_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap89
  zclbd := PRE_first_tail_x15_r0_body.zclbd89
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap89 PRE_first_tail_x15_r0_body.stFoot89 PRE_first_tail_x15_r0_body.iso89 PRE_first_tail_x15_r0_body.zwr89
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP89
  csupp := PRE_first_tail_x15_r0_body.csupp89
  cbound := PRE_first_tail_x15_r0_body.cbound89
  zimg := PRE_first_tail_x15_r0_body.zimg89
  zctl := PRE_first_tail_x15_r0_body.zctl89
  zstack := PRE_first_tail_x15_r0_body.zstack89
  zjobs := PRE_first_tail_x15_r0_body.zjobs89
  zstores := PRE_first_tail_x15_r0_body.zstores89
  zroots := PRE_first_tail_x15_r0_body.zroots89
  znC := PRE_first_tail_x15_r0_body.znC89
  ctab := PRE_first_tail_x15_r0_body.ctab89
  zbin := PRE_first_tail_x15_r0_body.zbin89
  cbridge := PRE_first_tail_x15_r0_body.cbridge89
  sbridge := bodyBridge89
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj89
  cshiftR := fun h hNL => bodyCshift89 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN89
  raised := PRE_first_tail_x15_r0_body.raised89
  cbigs := PRE_first_tail_x15_r0_body.cbigs89
  cjcl := PRE_first_tail_x15_r0_body.cjcl89
  xnLe := Nat.le_of_ble_eq_true bodyXn89
  loLe := Nat.le_of_ble_eq_true bodyLo89
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB89
  cntM := bodyCntM89
  hiLe := Nat.le_of_ble_eq_true bodyHi89
  nhiLe := Nat.le_of_ble_eq_true bodyNhi89
  jsHeap := bodyJs89
  jsRoots := bodyJsRoots89
  jsNative := bodyJsNative89
  framesEmpty := bodyFramesEmpty89
  trailOld := by decide
  lowVars := bodyLow89

def bodyQs89 : List (Option Q) := []
noncomputable def bodyEs89 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr89.map fun r => nth? PRE_first_tail_x15_r0_body.st89.S2.tab r
kernel_rfl bodyResChk89 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs89 bodyQs89) = true
kernel_rfl bodyLq89 : bodyQs89.length = PRE_first_tail_x15_r0_body.cws89.length
kernel_rfl bodyNrLo89 : PRE_first_tail_x15_r0_body.nr89.all (Nat.ble PRE_first_tail_x15_r0_body.S862.tab.length) = true
kernel_rfl bodySub89 : (Oracles.PRE_first_tail_x15_r0_body.map_site89.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost89 : postSubB bodyM PRE_first_tail_x15_r0_body.ws89 PRE_first_tail_x15_r0_body.cws89 bodyQs89 = true
kernel_rfl bodyDrop89 : Nat.ble (33404 + (PRE_first_tail_x15_r0_body.s863.next - PRE_first_tail_x15_r0_body.s864.next)) 33423 = true
kernel_rfl bodyDropH89 : Nat.ble (610 + ((mlxOf PRE_first_tail_x15_r0_body.s863.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s864.ffi).next)) 610 = true
kernel_rfl bodyDropN89 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s863.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s864.ffi).nnext)) 0 = true
kernel_rfl bodyDv89 : bodyΘ.1.take 477 = bodyΘ.1.take 477 ++ PRE_first_tail_x15_r0_body.cws89
kernel_rfl bodyDe89 : bodyΘ.2.take 477 = bodyΘ.2.take 477 ++ PRE_first_tail_x15_r0_body.nr89.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st89.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 477) (bodyΘ.2.take 477)))
kernel_rfl bodyDl89 : (bodyΘ.1.take 477).length = (bodyΘ.2.take 477).length
kernel_rfl bodyDold89 : (bodyΘ.1.take 477).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws89).isNone && !PRE_first_tail_x15_r0_body.ws89.contains v) = true
kernel_rfl bodyDfree89 : (bodyΘ.2.take 477).all (fun e => (PRE_first_tail_x15_r0_body.cws89 ++ PRE_first_tail_x15_r0_body.ws89).all fun w => e.noVar w) = true

theorem bodyStep89 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨33404, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s862 PRE_first_tail_x15_r0_body.S862)
      (bodyCut NB T tk π i x0 bodyΘ ⟨33423, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.S864) (206 + 1) :=
  bodySite bodyFacts89.cfix bodyFacts89.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st89.S2.tab) (Es := bodyEs89) (qs := bodyQs89)
    (ok := PRE_first_tail_x15_r0_body.st89.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site89 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts89
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site89 r hr) hi (MapOk.sub hm (sub_of_all bodySub89)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk89 r hr) hi hm ho hq)
    bodyLq89 rfl bodyNrLo89 (postSub_sound bodyPost89)
    (Nat.le_of_ble_eq_true bodyDrop89) (by decide) (Nat.le_of_ble_eq_true bodyDropH89) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN89) (by decide)
    bodyDv89 bodyDe89 bodyDl89 bodyDold89 bodyDfree89 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
