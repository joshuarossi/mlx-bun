import host.sim.compose.a4b.vw15.VWBodyJ25
import host.sim.compose.a4b.vw15.VWBodySite25
import host.sim.compose.a4b.vw15.VWBodyOracles_6
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift25 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S254.tab.length PRE_first_tail_x15_r0_body.s254.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P25.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P25 1148 PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.s256.ffi PRE_first_tail_x15_r0_body.s255.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_25
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_25
  have hcl : SSt (· < 1148) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S254.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_25] <;> decide) PRE_first_tail_x15_r0_body.cnodesK25 PRE_first_tail_x15_r0_body.cobjsK25
      PRE_first_tail_x15_r0_body.citemsK25 PRE_first_tail_x15_r0_body.cbd25 PRE_first_tail_x15_r0_body.csst25
  exact PRE_first_tail_x15_r0_body.cshift25 bodyNcl25 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_25] at this; exact this)


kernel_rfl bodyFramesEmpty25 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s255 a).isEmpty) = true
kernel_rfl bodyJsRoots25 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s254.next) PRE_first_tail_x15_r0_body.s256.trace PRE_first_tail_x15_r0_body.s256 = true
kernel_rfl bodyJsNative25 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s256.ffi) = true
kernel_rfl bodyLow25 : (PRE_first_tail_x15_r0_body.cws25 ++ PRE_first_tail_x15_r0_body.ws25).all (Nat.ble 9) = true
kernel_rfl bodyCntM25 : countersOkB PRE_first_tail_x15_r0_body.s254 PRE_first_tail_x15_r0_body.s255 = true
kernel_rfl bodyHi25 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s256.ffi).next setupP.E = true
kernel_rfl bodyNhi25 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s256.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge25 : bridgeOf PRE_first_tail_x15_r0_body.s255.ffi = bridgeOf PRE_first_tail_x15_r0_body.s254.ffi
kernel_rfl bodyNN25 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s254.ffi).nnext PRE_first_tail_x15_r0_body.P25.NL = true
kernel_rfl bodyXn25 : Nat.ble (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s256.ffi).next = true
kernel_rfl bodyLo25 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s256.ffi).next = true
theorem bodyFacts25 : BodySiteFacts PRE_first_tail_x15_r0_body.s254 PRE_first_tail_x15_r0_body.s255 PRE_first_tail_x15_r0_body.s256 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S254 PRE_first_tail_x15_r0_body.S255 PRE_first_tail_x15_r0_body.S256
    PRE_first_tail_x15_r0_body.ws25 PRE_first_tail_x15_r0_body.cws25 PRE_first_tail_x15_r0_body.nr25 PRE_first_tail_x15_r0_body.pl25 PRE_first_tail_x15_r0_body.cl25 2694785 1148 PRE_first_tail_x15_r0_body.kd25 PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.P25
    ⟨18704, 15792, 2694783, 1148⟩ ⟨18704, 15792, 2694783, 1148⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap25
  clean := bodyClean25
  cfix := PRE_first_tail_x15_r0_body.cfix25
  zpl := PRE_first_tail_x15_r0_body.zpl25
  zplnd := PRE_first_tail_x15_r0_body.zplnd25
  zn1 := PRE_first_tail_x15_r0_body.zn125
  zfirst := PRE_first_tail_x15_r0_body.zfirst25
  zscn := PRE_first_tail_x15_r0_body.zscn25
  zsmn := PRE_first_tail_x15_r0_body.zsmn25
  zgrow := PRE_first_tail_x15_r0_body.zgrow25
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab25
  zfresh := PRE_first_tail_x15_r0_body.zfresh25
  zcnd := PRE_first_tail_x15_r0_body.zcnd25
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi25
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt25
  zgP := PRE_first_tail_x15_r0_body.zg25_2665
  zkP := PRE_first_tail_x15_r0_body.zk25_2665
  zmP := PRE_first_tail_x15_r0_body.zm25_2665
  zgC := PRE_first_tail_x15_r0_body.zg25_2673467
  zkC := PRE_first_tail_x15_r0_body.zk25_2673467
  zmC := PRE_first_tail_x15_r0_body.zm25_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw25_2673472
  zwV := PRE_first_tail_x15_r0_body.zw25_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap25
  zclbd := PRE_first_tail_x15_r0_body.zclbd25
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap25 PRE_first_tail_x15_r0_body.stFoot25 PRE_first_tail_x15_r0_body.iso25 PRE_first_tail_x15_r0_body.zwr25
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP25
  csupp := PRE_first_tail_x15_r0_body.csupp25
  cbound := PRE_first_tail_x15_r0_body.cbound25
  zimg := PRE_first_tail_x15_r0_body.zimg25
  zctl := PRE_first_tail_x15_r0_body.zctl25
  zstack := PRE_first_tail_x15_r0_body.zstack25
  zjobs := PRE_first_tail_x15_r0_body.zjobs25
  zstores := PRE_first_tail_x15_r0_body.zstores25
  zroots := PRE_first_tail_x15_r0_body.zroots25
  znC := PRE_first_tail_x15_r0_body.znC25
  ctab := PRE_first_tail_x15_r0_body.ctab25
  zbin := PRE_first_tail_x15_r0_body.zbin25
  cbridge := PRE_first_tail_x15_r0_body.cbridge25
  sbridge := bodyBridge25
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj25
  cshiftR := fun h hNL => bodyCshift25 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN25
  raised := PRE_first_tail_x15_r0_body.raised25
  cbigs := PRE_first_tail_x15_r0_body.cbigs25
  cjcl := PRE_first_tail_x15_r0_body.cjcl25
  xnLe := Nat.le_of_ble_eq_true bodyXn25
  loLe := Nat.le_of_ble_eq_true bodyLo25
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB25
  cntM := bodyCntM25
  hiLe := Nat.le_of_ble_eq_true bodyHi25
  nhiLe := Nat.le_of_ble_eq_true bodyNhi25
  jsHeap := bodyJs25
  jsRoots := bodyJsRoots25
  jsNative := bodyJsNative25
  framesEmpty := bodyFramesEmpty25
  trailOld := by decide
  lowVars := bodyLow25

def bodyQs25 : List (Option Q) := []
noncomputable def bodyEs25 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr25.map fun r => nth? PRE_first_tail_x15_r0_body.st25.S2.tab r
kernel_rfl bodyResChk25 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs25 bodyQs25) = true
kernel_rfl bodyLq25 : bodyQs25.length = PRE_first_tail_x15_r0_body.cws25.length
kernel_rfl bodyNrLo25 : PRE_first_tail_x15_r0_body.nr25.all (Nat.ble PRE_first_tail_x15_r0_body.S254.tab.length) = true
kernel_rfl bodySub25 : (Oracles.PRE_first_tail_x15_r0_body.map_site25.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost25 : postSubB bodyM PRE_first_tail_x15_r0_body.ws25 PRE_first_tail_x15_r0_body.cws25 bodyQs25 = true
kernel_rfl bodyDrop25 : Nat.ble (12962 + (PRE_first_tail_x15_r0_body.s255.next - PRE_first_tail_x15_r0_body.s256.next)) 12964 = true
kernel_rfl bodyDropH25 : Nat.ble (200 + ((mlxOf PRE_first_tail_x15_r0_body.s255.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s256.ffi).next)) 200 = true
kernel_rfl bodyDropN25 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s255.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s256.ffi).nnext)) 0 = true
kernel_rfl bodyDv25 : bodyΘ.1.take 144 = bodyΘ.1.take 144 ++ PRE_first_tail_x15_r0_body.cws25
kernel_rfl bodyDe25 : bodyΘ.2.take 144 = bodyΘ.2.take 144 ++ PRE_first_tail_x15_r0_body.nr25.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st25.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 144) (bodyΘ.2.take 144)))
kernel_rfl bodyDl25 : (bodyΘ.1.take 144).length = (bodyΘ.2.take 144).length
kernel_rfl bodyDold25 : (bodyΘ.1.take 144).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws25).isNone && !PRE_first_tail_x15_r0_body.ws25.contains v) = true
kernel_rfl bodyDfree25 : (bodyΘ.2.take 144).all (fun e => (PRE_first_tail_x15_r0_body.cws25 ++ PRE_first_tail_x15_r0_body.ws25).all fun w => e.noVar w) = true

theorem bodyStep25 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12962, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s254 PRE_first_tail_x15_r0_body.S254)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12964, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s256 PRE_first_tail_x15_r0_body.S256) (27 + 1) :=
  bodySite bodyFacts25.cfix bodyFacts25.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st25.S2.tab) (Es := bodyEs25) (qs := bodyQs25)
    (ok := PRE_first_tail_x15_r0_body.st25.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site25 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts25
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site25 r hr) hi (MapOk.sub hm (sub_of_all bodySub25)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk25 r hr) hi hm ho hq)
    bodyLq25 rfl bodyNrLo25 (postSub_sound bodyPost25)
    (Nat.le_of_ble_eq_true bodyDrop25) (by decide) (Nat.le_of_ble_eq_true bodyDropH25) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN25) (by decide)
    bodyDv25 bodyDe25 bodyDl25 bodyDold25 bodyDfree25 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
