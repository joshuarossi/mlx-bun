import host.sim.compose.a4b.vw15.VWBodyJ119
import host.sim.compose.a4b.vw15.VWBodySite119
import host.sim.compose.a4b.vw15.VWBodyOracles_29
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift119 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1149.tab.length PRE_first_tail_x15_r0_body.s1149.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P119.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P119 5140 PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.s1151.ffi PRE_first_tail_x15_r0_body.s1150.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_119
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_119
  have hcl : SSt (· < 5140) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1149.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_119] <;> decide) PRE_first_tail_x15_r0_body.cnodesK119 PRE_first_tail_x15_r0_body.cobjsK119
      PRE_first_tail_x15_r0_body.citemsK119 PRE_first_tail_x15_r0_body.cbd119 PRE_first_tail_x15_r0_body.csst119
  exact PRE_first_tail_x15_r0_body.cshift119 bodyNcl119 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_119] at this; exact this)


kernel_rfl bodyFramesEmpty119 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1150 a).isEmpty) = true
kernel_rfl bodyJsRoots119 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1149.next) PRE_first_tail_x15_r0_body.s1151.trace PRE_first_tail_x15_r0_body.s1151 = true
kernel_rfl bodyJsNative119 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1151.ffi) = true
kernel_rfl bodyLow119 : (PRE_first_tail_x15_r0_body.cws119 ++ PRE_first_tail_x15_r0_body.ws119).all (Nat.ble 9) = true
kernel_rfl bodyCntM119 : countersOkB PRE_first_tail_x15_r0_body.s1149 PRE_first_tail_x15_r0_body.s1150 = true
kernel_rfl bodyHi119 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1151.ffi).next setupP.E = true
kernel_rfl bodyNhi119 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1151.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge119 : bridgeOf PRE_first_tail_x15_r0_body.s1150.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1149.ffi
kernel_rfl bodyNN119 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1149.ffi).nnext PRE_first_tail_x15_r0_body.P119.NL = true
kernel_rfl bodyXn119 : Nat.ble (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1151.ffi).next = true
kernel_rfl bodyLo119 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1151.ffi).next = true
theorem bodyFacts119 : BodySiteFacts PRE_first_tail_x15_r0_body.s1149 PRE_first_tail_x15_r0_body.s1150 PRE_first_tail_x15_r0_body.s1151 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1149 PRE_first_tail_x15_r0_body.S1150 PRE_first_tail_x15_r0_body.S1151
    PRE_first_tail_x15_r0_body.ws119 PRE_first_tail_x15_r0_body.cws119 PRE_first_tail_x15_r0_body.nr119 PRE_first_tail_x15_r0_body.pl119 PRE_first_tail_x15_r0_body.cl119 2768140 5140 PRE_first_tail_x15_r0_body.kd119 PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.P119
    ⟨20541, 17629, 2768129, 5140⟩ ⟨20541, 17629, 2768130, 5140⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap119
  clean := bodyClean119
  cfix := PRE_first_tail_x15_r0_body.cfix119
  zpl := PRE_first_tail_x15_r0_body.zpl119
  zplnd := PRE_first_tail_x15_r0_body.zplnd119
  zn1 := PRE_first_tail_x15_r0_body.zn1119
  zfirst := PRE_first_tail_x15_r0_body.zfirst119
  zscn := PRE_first_tail_x15_r0_body.zscn119
  zsmn := PRE_first_tail_x15_r0_body.zsmn119
  zgrow := PRE_first_tail_x15_r0_body.zgrow119
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab119
  zfresh := PRE_first_tail_x15_r0_body.zfresh119
  zcnd := PRE_first_tail_x15_r0_body.zcnd119
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi119
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt119
  zgP := PRE_first_tail_x15_r0_body.zg119_2665
  zkP := PRE_first_tail_x15_r0_body.zk119_2665
  zmP := PRE_first_tail_x15_r0_body.zm119_2665
  zgC := PRE_first_tail_x15_r0_body.zg119_2673467
  zkC := PRE_first_tail_x15_r0_body.zk119_2673467
  zmC := PRE_first_tail_x15_r0_body.zm119_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw119_2673472
  zwV := PRE_first_tail_x15_r0_body.zw119_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap119
  zclbd := PRE_first_tail_x15_r0_body.zclbd119
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap119 PRE_first_tail_x15_r0_body.stFoot119 PRE_first_tail_x15_r0_body.iso119 PRE_first_tail_x15_r0_body.zwr119
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP119
  csupp := PRE_first_tail_x15_r0_body.csupp119
  cbound := PRE_first_tail_x15_r0_body.cbound119
  zimg := PRE_first_tail_x15_r0_body.zimg119
  zctl := PRE_first_tail_x15_r0_body.zctl119
  zstack := PRE_first_tail_x15_r0_body.zstack119
  zjobs := PRE_first_tail_x15_r0_body.zjobs119
  zstores := PRE_first_tail_x15_r0_body.zstores119
  zroots := PRE_first_tail_x15_r0_body.zroots119
  znC := PRE_first_tail_x15_r0_body.znC119
  ctab := PRE_first_tail_x15_r0_body.ctab119
  zbin := PRE_first_tail_x15_r0_body.zbin119
  cbridge := PRE_first_tail_x15_r0_body.cbridge119
  sbridge := bodyBridge119
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj119
  cshiftR := fun h hNL => bodyCshift119 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN119
  raised := PRE_first_tail_x15_r0_body.raised119
  cbigs := PRE_first_tail_x15_r0_body.cbigs119
  cjcl := PRE_first_tail_x15_r0_body.cjcl119
  xnLe := Nat.le_of_ble_eq_true bodyXn119
  loLe := Nat.le_of_ble_eq_true bodyLo119
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB119
  cntM := bodyCntM119
  hiLe := Nat.le_of_ble_eq_true bodyHi119
  nhiLe := Nat.le_of_ble_eq_true bodyNhi119
  jsHeap := bodyJs119
  jsRoots := bodyJsRoots119
  jsNative := bodyJsNative119
  framesEmpty := bodyFramesEmpty119
  trailOld := by decide
  lowVars := bodyLow119

def bodyQs119 : List (Option Q) := []
noncomputable def bodyEs119 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr119.map fun r => nth? PRE_first_tail_x15_r0_body.st119.S2.tab r
kernel_rfl bodyResChk119 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs119 bodyQs119) = true
kernel_rfl bodyLq119 : bodyQs119.length = PRE_first_tail_x15_r0_body.cws119.length
kernel_rfl bodyNrLo119 : PRE_first_tail_x15_r0_body.nr119.all (Nat.ble PRE_first_tail_x15_r0_body.S1149.tab.length) = true
kernel_rfl bodySub119 : (Oracles.PRE_first_tail_x15_r0_body.map_site119.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost119 : postSubB bodyM PRE_first_tail_x15_r0_body.ws119 PRE_first_tail_x15_r0_body.cws119 bodyQs119 = true
kernel_rfl bodyDrop119 : Nat.ble (42653 + (PRE_first_tail_x15_r0_body.s1150.next - PRE_first_tail_x15_r0_body.s1151.next)) 42663 = true
kernel_rfl bodyDropH119 : Nat.ble (791 + ((mlxOf PRE_first_tail_x15_r0_body.s1150.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1151.ffi).next)) 791 = true
kernel_rfl bodyDropN119 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1150.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1151.ffi).nnext)) 0 = true
kernel_rfl bodyDv119 : bodyΘ.1.take 630 = bodyΘ.1.take 630 ++ PRE_first_tail_x15_r0_body.cws119
kernel_rfl bodyDe119 : bodyΘ.2.take 630 = bodyΘ.2.take 630 ++ PRE_first_tail_x15_r0_body.nr119.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st119.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 630) (bodyΘ.2.take 630)))
kernel_rfl bodyDl119 : (bodyΘ.1.take 630).length = (bodyΘ.2.take 630).length
kernel_rfl bodyDold119 : (bodyΘ.1.take 630).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws119).isNone && !PRE_first_tail_x15_r0_body.ws119.contains v) = true
kernel_rfl bodyDfree119 : (bodyΘ.2.take 630).all (fun e => (PRE_first_tail_x15_r0_body.cws119 ++ PRE_first_tail_x15_r0_body.ws119).all fun w => e.noVar w) = true

theorem bodyStep119 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42653, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1149 PRE_first_tail_x15_r0_body.S1149)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42663, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1151 PRE_first_tail_x15_r0_body.S1151) (98 + 1) :=
  bodySite bodyFacts119.cfix bodyFacts119.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st119.S2.tab) (Es := bodyEs119) (qs := bodyQs119)
    (ok := PRE_first_tail_x15_r0_body.st119.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site119 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts119
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site119 r hr) hi (MapOk.sub hm (sub_of_all bodySub119)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk119 r hr) hi hm ho hq)
    bodyLq119 rfl bodyNrLo119 (postSub_sound bodyPost119)
    (Nat.le_of_ble_eq_true bodyDrop119) (by decide) (Nat.le_of_ble_eq_true bodyDropH119) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN119) (by decide)
    bodyDv119 bodyDe119 bodyDl119 bodyDold119 bodyDfree119 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
