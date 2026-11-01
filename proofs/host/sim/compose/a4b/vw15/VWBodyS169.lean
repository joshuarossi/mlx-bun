import host.sim.compose.a4b.vw15.VWBodyJ169
import host.sim.compose.a4b.vw15.VWBodySite169
import host.sim.compose.a4b.vw15.VWBodyOracles_42
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

theorem bodyCshift169 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1634.tab.length PRE_first_tail_x15_r0_body.s1634.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P169.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P169 7304 PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.s1636.ffi PRE_first_tail_x15_r0_body.s1635.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_169
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_169
  have hcl : SSt (· < 7304) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1634.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_169] <;> decide) PRE_first_tail_x15_r0_body.cnodesK169 PRE_first_tail_x15_r0_body.cobjsK169
      PRE_first_tail_x15_r0_body.citemsK169 PRE_first_tail_x15_r0_body.cbd169 PRE_first_tail_x15_r0_body.csst169
  exact PRE_first_tail_x15_r0_body.cshift169 bodyNcl169 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_169] at this; exact this)


kernel_rfl bodyFramesEmpty169 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1635 a).isEmpty) = true
kernel_rfl bodyJsRoots169 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1634.next) PRE_first_tail_x15_r0_body.s1636.trace PRE_first_tail_x15_r0_body.s1636 = true
kernel_rfl bodyJsNative169 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1636.ffi) = true
kernel_rfl bodyLow169 : (PRE_first_tail_x15_r0_body.cws169 ++ PRE_first_tail_x15_r0_body.ws169).all (Nat.ble 9) = true
kernel_rfl bodyCntM169 : countersOkB PRE_first_tail_x15_r0_body.s1634 PRE_first_tail_x15_r0_body.s1635 = true
kernel_rfl bodyHi169 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1636.ffi).next setupP.E = true
kernel_rfl bodyNhi169 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1636.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge169 : bridgeOf PRE_first_tail_x15_r0_body.s1635.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1634.ffi
kernel_rfl bodyNN169 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1634.ffi).nnext PRE_first_tail_x15_r0_body.P169.NL = true
kernel_rfl bodyXn169 : Nat.ble (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1636.ffi).next = true
kernel_rfl bodyLo169 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1636.ffi).next = true
theorem bodyFacts169 : BodySiteFacts PRE_first_tail_x15_r0_body.s1634 PRE_first_tail_x15_r0_body.s1635 PRE_first_tail_x15_r0_body.s1636 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1634 PRE_first_tail_x15_r0_body.S1635 PRE_first_tail_x15_r0_body.S1636
    PRE_first_tail_x15_r0_body.ws169 PRE_first_tail_x15_r0_body.cws169 PRE_first_tail_x15_r0_body.nr169 PRE_first_tail_x15_r0_body.pl169 PRE_first_tail_x15_r0_body.cl169 2807797 7304 PRE_first_tail_x15_r0_body.kd169 PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.P169
    ⟨21536, 18636, 2807795, 7304⟩ ⟨21536, 18636, 2807795, 7304⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap169
  clean := bodyClean169
  cfix := PRE_first_tail_x15_r0_body.cfix169
  zpl := PRE_first_tail_x15_r0_body.zpl169
  zplnd := PRE_first_tail_x15_r0_body.zplnd169
  zn1 := PRE_first_tail_x15_r0_body.zn1169
  zfirst := PRE_first_tail_x15_r0_body.zfirst169
  zscn := PRE_first_tail_x15_r0_body.zscn169
  zsmn := PRE_first_tail_x15_r0_body.zsmn169
  zgrow := PRE_first_tail_x15_r0_body.zgrow169
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab169
  zfresh := PRE_first_tail_x15_r0_body.zfresh169
  zcnd := PRE_first_tail_x15_r0_body.zcnd169
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi169
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt169
  zgP := PRE_first_tail_x15_r0_body.zg169_2665
  zkP := PRE_first_tail_x15_r0_body.zk169_2665
  zmP := PRE_first_tail_x15_r0_body.zm169_2665
  zgC := PRE_first_tail_x15_r0_body.zg169_2673467
  zkC := PRE_first_tail_x15_r0_body.zk169_2673467
  zmC := PRE_first_tail_x15_r0_body.zm169_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw169_2673472
  zwV := PRE_first_tail_x15_r0_body.zw169_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap169
  zclbd := PRE_first_tail_x15_r0_body.zclbd169
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap169 PRE_first_tail_x15_r0_body.stFoot169 PRE_first_tail_x15_r0_body.iso169 PRE_first_tail_x15_r0_body.zwr169
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP169
  csupp := PRE_first_tail_x15_r0_body.csupp169
  cbound := PRE_first_tail_x15_r0_body.cbound169
  zimg := PRE_first_tail_x15_r0_body.zimg169
  zctl := PRE_first_tail_x15_r0_body.zctl169
  zstack := PRE_first_tail_x15_r0_body.zstack169
  zjobs := PRE_first_tail_x15_r0_body.zjobs169
  zstores := PRE_first_tail_x15_r0_body.zstores169
  zroots := PRE_first_tail_x15_r0_body.zroots169
  znC := PRE_first_tail_x15_r0_body.znC169
  ctab := PRE_first_tail_x15_r0_body.ctab169
  zbin := PRE_first_tail_x15_r0_body.zbin169
  cbridge := PRE_first_tail_x15_r0_body.cbridge169
  sbridge := bodyBridge169
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj169
  cshiftR := fun h hNL => bodyCshift169 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN169
  raised := PRE_first_tail_x15_r0_body.raised169
  cbigs := PRE_first_tail_x15_r0_body.cbigs169
  cjcl := PRE_first_tail_x15_r0_body.cjcl169
  xnLe := Nat.le_of_ble_eq_true bodyXn169
  loLe := Nat.le_of_ble_eq_true bodyLo169
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB169
  cntM := bodyCntM169
  hiLe := Nat.le_of_ble_eq_true bodyHi169
  nhiLe := Nat.le_of_ble_eq_true bodyNhi169
  jsHeap := bodyJs169
  jsRoots := bodyJsRoots169
  jsNative := bodyJsNative169
  framesEmpty := bodyFramesEmpty169
  trailOld := by decide
  lowVars := bodyLow169

def bodyQs169 : List (Option Q) := []
noncomputable def bodyEs169 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr169.map fun r => nth? PRE_first_tail_x15_r0_body.st169.S2.tab r
kernel_rfl bodyResChk169 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs169 bodyQs169) = true
kernel_rfl bodyLq169 : bodyQs169.length = PRE_first_tail_x15_r0_body.cws169.length
kernel_rfl bodyNrLo169 : PRE_first_tail_x15_r0_body.nr169.all (Nat.ble PRE_first_tail_x15_r0_body.S1634.tab.length) = true
kernel_rfl bodySub169 : (Oracles.PRE_first_tail_x15_r0_body.map_site169.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost169 : postSubB bodyM PRE_first_tail_x15_r0_body.ws169 PRE_first_tail_x15_r0_body.cws169 bodyQs169 = true
kernel_rfl bodyDrop169 : Nat.ble (59255 + (PRE_first_tail_x15_r0_body.s1635.next - PRE_first_tail_x15_r0_body.s1636.next)) 59257 = true
kernel_rfl bodyDropH169 : Nat.ble (1124 + ((mlxOf PRE_first_tail_x15_r0_body.s1635.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1636.ffi).next)) 1124 = true
kernel_rfl bodyDropN169 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1635.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1636.ffi).nnext)) 0 = true
kernel_rfl bodyDv169 : bodyΘ.1.take 900 = bodyΘ.1.take 900 ++ PRE_first_tail_x15_r0_body.cws169
kernel_rfl bodyDe169 : bodyΘ.2.take 900 = bodyΘ.2.take 900 ++ PRE_first_tail_x15_r0_body.nr169.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st169.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 900) (bodyΘ.2.take 900)))
kernel_rfl bodyDl169 : (bodyΘ.1.take 900).length = (bodyΘ.2.take 900).length
kernel_rfl bodyDold169 : (bodyΘ.1.take 900).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws169).isNone && !PRE_first_tail_x15_r0_body.ws169.contains v) = true
kernel_rfl bodyDfree169 : (bodyΘ.2.take 900).all (fun e => (PRE_first_tail_x15_r0_body.cws169 ++ PRE_first_tail_x15_r0_body.ws169).all fun w => e.noVar w) = true

theorem bodyStep169 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨59255, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1634 PRE_first_tail_x15_r0_body.S1634)
      (bodyCut NB T tk π i x0 bodyΘ ⟨59257, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1636 PRE_first_tail_x15_r0_body.S1636) (27 + 1) :=
  bodySite bodyFacts169.cfix bodyFacts169.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st169.S2.tab) (Es := bodyEs169) (qs := bodyQs169)
    (ok := PRE_first_tail_x15_r0_body.st169.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site169 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts169
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site169 r hr) hi (MapOk.sub hm (sub_of_all bodySub169)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk169 r hr) hi hm ho hq)
    bodyLq169 rfl bodyNrLo169 (postSub_sound bodyPost169)
    (Nat.le_of_ble_eq_true bodyDrop169) (by decide) (Nat.le_of_ble_eq_true bodyDropH169) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN169) (by decide)
    bodyDv169 bodyDe169 bodyDl169 bodyDold169 bodyDfree169 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
