import host.sim.compose.a4b.vw15.VWBodyJ125
import host.sim.compose.a4b.vw15.VWBodySite125
import host.sim.compose.a4b.vw15.VWBodyOracles_31
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift125 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1207.tab.length PRE_first_tail_x15_r0_body.s1207.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P125.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P125 5398 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.s1209.ffi PRE_first_tail_x15_r0_body.s1208.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_125
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_125
  have hcl : SSt (· < 5398) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1207.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_125] <;> decide) PRE_first_tail_x15_r0_body.cnodesK125 PRE_first_tail_x15_r0_body.cobjsK125
      PRE_first_tail_x15_r0_body.citemsK125 PRE_first_tail_x15_r0_body.cbd125 PRE_first_tail_x15_r0_body.csst125
  exact PRE_first_tail_x15_r0_body.cshift125 bodyNcl125 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_125] at this; exact this)


kernel_rfl bodyFramesEmpty125 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1208 a).isEmpty) = true
kernel_rfl bodyJsRoots125 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1207.next) PRE_first_tail_x15_r0_body.s1209.trace PRE_first_tail_x15_r0_body.s1209 = true
kernel_rfl bodyJsNative125 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1209.ffi) = true
kernel_rfl bodyLow125 : (PRE_first_tail_x15_r0_body.cws125 ++ PRE_first_tail_x15_r0_body.ws125).all (Nat.ble 9) = true
kernel_rfl bodyCntM125 : countersOkB PRE_first_tail_x15_r0_body.s1207 PRE_first_tail_x15_r0_body.s1208 = true
kernel_rfl bodyHi125 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1209.ffi).next setupP.E = true
kernel_rfl bodyNhi125 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1209.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge125 : bridgeOf PRE_first_tail_x15_r0_body.s1208.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1207.ffi
kernel_rfl bodyNN125 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1207.ffi).nnext PRE_first_tail_x15_r0_body.P125.NL = true
kernel_rfl bodyXn125 : Nat.ble (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1209.ffi).next = true
kernel_rfl bodyLo125 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1209.ffi).next = true
theorem bodyFacts125 : BodySiteFacts PRE_first_tail_x15_r0_body.s1207 PRE_first_tail_x15_r0_body.s1208 PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1207 PRE_first_tail_x15_r0_body.S1208 PRE_first_tail_x15_r0_body.S1209
    PRE_first_tail_x15_r0_body.ws125 PRE_first_tail_x15_r0_body.cws125 PRE_first_tail_x15_r0_body.nr125 PRE_first_tail_x15_r0_body.pl125 PRE_first_tail_x15_r0_body.cl125 2772674 5398 PRE_first_tail_x15_r0_body.kd125 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.P125
    ⟨20656, 17755, 2772663, 5398⟩ ⟨20656, 17755, 2772664, 5398⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap125
  clean := bodyClean125
  cfix := PRE_first_tail_x15_r0_body.cfix125
  zpl := PRE_first_tail_x15_r0_body.zpl125
  zplnd := PRE_first_tail_x15_r0_body.zplnd125
  zn1 := PRE_first_tail_x15_r0_body.zn1125
  zfirst := PRE_first_tail_x15_r0_body.zfirst125
  zscn := PRE_first_tail_x15_r0_body.zscn125
  zsmn := PRE_first_tail_x15_r0_body.zsmn125
  zgrow := PRE_first_tail_x15_r0_body.zgrow125
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab125
  zfresh := PRE_first_tail_x15_r0_body.zfresh125
  zcnd := PRE_first_tail_x15_r0_body.zcnd125
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi125
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt125
  zgP := PRE_first_tail_x15_r0_body.zg125_2665
  zkP := PRE_first_tail_x15_r0_body.zk125_2665
  zmP := PRE_first_tail_x15_r0_body.zm125_2665
  zgC := PRE_first_tail_x15_r0_body.zg125_2673467
  zkC := PRE_first_tail_x15_r0_body.zk125_2673467
  zmC := PRE_first_tail_x15_r0_body.zm125_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw125_2673472
  zwV := PRE_first_tail_x15_r0_body.zw125_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap125
  zclbd := PRE_first_tail_x15_r0_body.zclbd125
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap125 PRE_first_tail_x15_r0_body.stFoot125 PRE_first_tail_x15_r0_body.iso125 PRE_first_tail_x15_r0_body.zwr125
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP125
  csupp := PRE_first_tail_x15_r0_body.csupp125
  cbound := PRE_first_tail_x15_r0_body.cbound125
  zimg := PRE_first_tail_x15_r0_body.zimg125
  zctl := PRE_first_tail_x15_r0_body.zctl125
  zstack := PRE_first_tail_x15_r0_body.zstack125
  zjobs := PRE_first_tail_x15_r0_body.zjobs125
  zstores := PRE_first_tail_x15_r0_body.zstores125
  zroots := PRE_first_tail_x15_r0_body.zroots125
  znC := PRE_first_tail_x15_r0_body.znC125
  ctab := PRE_first_tail_x15_r0_body.ctab125
  zbin := PRE_first_tail_x15_r0_body.zbin125
  cbridge := PRE_first_tail_x15_r0_body.cbridge125
  sbridge := bodyBridge125
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj125
  cshiftR := fun h hNL => bodyCshift125 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN125
  raised := PRE_first_tail_x15_r0_body.raised125
  cbigs := PRE_first_tail_x15_r0_body.cbigs125
  cjcl := PRE_first_tail_x15_r0_body.cjcl125
  xnLe := Nat.le_of_ble_eq_true bodyXn125
  loLe := Nat.le_of_ble_eq_true bodyLo125
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB125
  cntM := bodyCntM125
  hiLe := Nat.le_of_ble_eq_true bodyHi125
  nhiLe := Nat.le_of_ble_eq_true bodyNhi125
  jsHeap := bodyJs125
  jsRoots := bodyJsRoots125
  jsNative := bodyJsNative125
  framesEmpty := bodyFramesEmpty125
  trailOld := by decide
  lowVars := bodyLow125

def bodyQs125 : List (Option Q) := []
noncomputable def bodyEs125 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr125.map fun r => nth? PRE_first_tail_x15_r0_body.st125.S2.tab r
kernel_rfl bodyResChk125 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs125 bodyQs125) = true
kernel_rfl bodyLq125 : bodyQs125.length = PRE_first_tail_x15_r0_body.cws125.length
kernel_rfl bodyNrLo125 : PRE_first_tail_x15_r0_body.nr125.all (Nat.ble PRE_first_tail_x15_r0_body.S1207.tab.length) = true
kernel_rfl bodySub125 : (Oracles.PRE_first_tail_x15_r0_body.map_site125.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost125 : postSubB bodyM PRE_first_tail_x15_r0_body.ws125 PRE_first_tail_x15_r0_body.cws125 bodyQs125 = true
kernel_rfl bodyDrop125 : Nat.ble (44975 + (PRE_first_tail_x15_r0_body.s1208.next - PRE_first_tail_x15_r0_body.s1209.next)) 44985 = true
kernel_rfl bodyDropH125 : Nat.ble (841 + ((mlxOf PRE_first_tail_x15_r0_body.s1208.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1209.ffi).next)) 841 = true
kernel_rfl bodyDropN125 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1208.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1209.ffi).nnext)) 0 = true
kernel_rfl bodyDv125 : bodyΘ.1.take 666 = bodyΘ.1.take 666 ++ PRE_first_tail_x15_r0_body.cws125
kernel_rfl bodyDe125 : bodyΘ.2.take 666 = bodyΘ.2.take 666 ++ PRE_first_tail_x15_r0_body.nr125.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st125.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 666) (bodyΘ.2.take 666)))
kernel_rfl bodyDl125 : (bodyΘ.1.take 666).length = (bodyΘ.2.take 666).length
kernel_rfl bodyDold125 : (bodyΘ.1.take 666).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws125).isNone && !PRE_first_tail_x15_r0_body.ws125.contains v) = true
kernel_rfl bodyDfree125 : (bodyΘ.2.take 666).all (fun e => (PRE_first_tail_x15_r0_body.cws125 ++ PRE_first_tail_x15_r0_body.ws125).all fun w => e.noVar w) = true

theorem bodyStep125 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨44975, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1207 PRE_first_tail_x15_r0_body.S1207)
      (bodyCut NB T tk π i x0 bodyΘ ⟨44985, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.S1209) (98 + 1) :=
  bodySite bodyFacts125.cfix bodyFacts125.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st125.S2.tab) (Es := bodyEs125) (qs := bodyQs125)
    (ok := PRE_first_tail_x15_r0_body.st125.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site125 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts125
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site125 r hr) hi (MapOk.sub hm (sub_of_all bodySub125)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk125 r hr) hi hm ho hq)
    bodyLq125 rfl bodyNrLo125 (postSub_sound bodyPost125)
    (Nat.le_of_ble_eq_true bodyDrop125) (by decide) (Nat.le_of_ble_eq_true bodyDropH125) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN125) (by decide)
    bodyDv125 bodyDe125 bodyDl125 bodyDold125 bodyDfree125 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
