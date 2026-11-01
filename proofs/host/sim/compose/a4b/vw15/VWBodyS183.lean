import host.sim.compose.a4b.vw15.VWBodyJ183
import host.sim.compose.a4b.vw15.VWBodySite183
import host.sim.compose.a4b.vw15.VWBodyOracles_45
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

theorem bodyCshift183 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1770.tab.length PRE_first_tail_x15_r0_body.s1770.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P183.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P183 7925 PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.s1772.ffi PRE_first_tail_x15_r0_body.s1771.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_183
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_183
  have hcl : SSt (· < 7925) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1770.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_183] <;> decide) PRE_first_tail_x15_r0_body.cnodesK183 PRE_first_tail_x15_r0_body.cobjsK183
      PRE_first_tail_x15_r0_body.citemsK183 PRE_first_tail_x15_r0_body.cbd183 PRE_first_tail_x15_r0_body.csst183
  exact PRE_first_tail_x15_r0_body.cshift183 bodyNcl183 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_183] at this; exact this)


kernel_rfl bodyFramesEmpty183 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1771 a).isEmpty) = true
kernel_rfl bodyJsRoots183 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1770.next) PRE_first_tail_x15_r0_body.s1772.trace PRE_first_tail_x15_r0_body.s1772 = true
kernel_rfl bodyJsNative183 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1772.ffi) = true
kernel_rfl bodyLow183 : (PRE_first_tail_x15_r0_body.cws183 ++ PRE_first_tail_x15_r0_body.ws183).all (Nat.ble 9) = true
kernel_rfl bodyCntM183 : countersOkB PRE_first_tail_x15_r0_body.s1770 PRE_first_tail_x15_r0_body.s1771 = true
kernel_rfl bodyHi183 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1772.ffi).next setupP.E = true
kernel_rfl bodyNhi183 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1772.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge183 : bridgeOf PRE_first_tail_x15_r0_body.s1771.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1770.ffi
kernel_rfl bodyNN183 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1770.ffi).nnext PRE_first_tail_x15_r0_body.P183.NL = true
kernel_rfl bodyXn183 : Nat.ble (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1772.ffi).next = true
kernel_rfl bodyLo183 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1772.ffi).next = true
theorem bodyFacts183 : BodySiteFacts PRE_first_tail_x15_r0_body.s1770 PRE_first_tail_x15_r0_body.s1771 PRE_first_tail_x15_r0_body.s1772 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1770 PRE_first_tail_x15_r0_body.S1771 PRE_first_tail_x15_r0_body.S1772
    PRE_first_tail_x15_r0_body.ws183 PRE_first_tail_x15_r0_body.cws183 PRE_first_tail_x15_r0_body.nr183 PRE_first_tail_x15_r0_body.pl183 PRE_first_tail_x15_r0_body.cl183 2820142 7925 PRE_first_tail_x15_r0_body.kd183 PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.P183
    ⟨21813, 18896, 2818987, 7907⟩ ⟨21816, 18923, 2818993, 7925⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap183
  clean := bodyClean183
  cfix := PRE_first_tail_x15_r0_body.cfix183
  zpl := PRE_first_tail_x15_r0_body.zpl183
  zplnd := PRE_first_tail_x15_r0_body.zplnd183
  zn1 := PRE_first_tail_x15_r0_body.zn1183
  zfirst := PRE_first_tail_x15_r0_body.zfirst183
  zscn := PRE_first_tail_x15_r0_body.zscn183
  zsmn := PRE_first_tail_x15_r0_body.zsmn183
  zgrow := PRE_first_tail_x15_r0_body.zgrow183
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab183
  zfresh := PRE_first_tail_x15_r0_body.zfresh183
  zcnd := PRE_first_tail_x15_r0_body.zcnd183
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi183
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt183
  zgP := PRE_first_tail_x15_r0_body.zg183_2665
  zkP := PRE_first_tail_x15_r0_body.zk183_2665
  zmP := PRE_first_tail_x15_r0_body.zm183_2665
  zgC := PRE_first_tail_x15_r0_body.zg183_2673467
  zkC := PRE_first_tail_x15_r0_body.zk183_2673467
  zmC := PRE_first_tail_x15_r0_body.zm183_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw183_2673472
  zwV := PRE_first_tail_x15_r0_body.zw183_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap183
  zclbd := PRE_first_tail_x15_r0_body.zclbd183
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap183 PRE_first_tail_x15_r0_body.stFoot183 PRE_first_tail_x15_r0_body.iso183 PRE_first_tail_x15_r0_body.zwr183
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP183
  csupp := PRE_first_tail_x15_r0_body.csupp183
  cbound := PRE_first_tail_x15_r0_body.cbound183
  zimg := PRE_first_tail_x15_r0_body.zimg183
  zctl := PRE_first_tail_x15_r0_body.zctl183
  zstack := PRE_first_tail_x15_r0_body.zstack183
  zjobs := PRE_first_tail_x15_r0_body.zjobs183
  zstores := PRE_first_tail_x15_r0_body.zstores183
  zroots := PRE_first_tail_x15_r0_body.zroots183
  znC := PRE_first_tail_x15_r0_body.znC183
  ctab := PRE_first_tail_x15_r0_body.ctab183
  zbin := PRE_first_tail_x15_r0_body.zbin183
  cbridge := PRE_first_tail_x15_r0_body.cbridge183
  sbridge := bodyBridge183
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj183
  cshiftR := fun h hNL => bodyCshift183 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN183
  raised := PRE_first_tail_x15_r0_body.raised183
  cbigs := PRE_first_tail_x15_r0_body.cbigs183
  cjcl := PRE_first_tail_x15_r0_body.cjcl183
  xnLe := Nat.le_of_ble_eq_true bodyXn183
  loLe := Nat.le_of_ble_eq_true bodyLo183
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB183
  cntM := bodyCntM183
  hiLe := Nat.le_of_ble_eq_true bodyHi183
  nhiLe := Nat.le_of_ble_eq_true bodyNhi183
  jsHeap := bodyJs183
  jsRoots := bodyJsRoots183
  jsNative := bodyJsNative183
  framesEmpty := bodyFramesEmpty183
  trailOld := by decide
  lowVars := bodyLow183

def bodyQs183 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs183 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr183.map fun r => nth? PRE_first_tail_x15_r0_body.st183.S5.tab r
kernel_rfl bodyResChk183 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs183 bodyQs183) = true
kernel_rfl bodyLq183 : bodyQs183.length = PRE_first_tail_x15_r0_body.cws183.length
kernel_rfl bodyNrLo183 : PRE_first_tail_x15_r0_body.nr183.all (Nat.ble PRE_first_tail_x15_r0_body.S1770.tab.length) = true
kernel_rfl bodySub183 : (Oracles.PRE_first_tail_x15_r0_body.map_site183.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost183 : postSubB bodyM PRE_first_tail_x15_r0_body.ws183 PRE_first_tail_x15_r0_body.cws183 bodyQs183 = true
kernel_rfl bodyDrop183 : Nat.ble (63157 + (PRE_first_tail_x15_r0_body.s1771.next - PRE_first_tail_x15_r0_body.s1772.next)) 64306 = true
kernel_rfl bodyDropH183 : Nat.ble (1201 + ((mlxOf PRE_first_tail_x15_r0_body.s1771.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1772.ffi).next)) 1226 = true
kernel_rfl bodyDropN183 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1771.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1772.ffi).nnext)) 0 = true
kernel_rfl bodyDv183 : bodyΘ.1.take 981 = bodyΘ.1.take 963 ++ PRE_first_tail_x15_r0_body.cws183
kernel_rfl bodyDe183 : bodyΘ.2.take 981 = bodyΘ.2.take 963 ++ PRE_first_tail_x15_r0_body.nr183.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st183.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 963) (bodyΘ.2.take 963)))
kernel_rfl bodyDl183 : (bodyΘ.1.take 963).length = (bodyΘ.2.take 963).length
kernel_rfl bodyDold183 : (bodyΘ.1.take 963).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws183).isNone && !PRE_first_tail_x15_r0_body.ws183.contains v) = true
kernel_rfl bodyDfree183 : (bodyΘ.2.take 981).all (fun e => (PRE_first_tail_x15_r0_body.cws183 ++ PRE_first_tail_x15_r0_body.ws183).all fun w => e.noVar w) = true

theorem bodyStep183 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨63157, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1770 PRE_first_tail_x15_r0_body.S1770)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64306, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1772 PRE_first_tail_x15_r0_body.S1772) (11334 + 1) :=
  bodySite bodyFacts183.cfix bodyFacts183.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st183.S5.tab) (Es := bodyEs183) (qs := bodyQs183)
    (ok := PRE_first_tail_x15_r0_body.st183.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site183 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts183
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site183 r hr) hi (MapOk.sub hm (sub_of_all bodySub183)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk183 r hr) hi hm ho hq)
    bodyLq183 rfl bodyNrLo183 (postSub_sound bodyPost183)
    (Nat.le_of_ble_eq_true bodyDrop183) (by decide) (Nat.le_of_ble_eq_true bodyDropH183) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN183) (by decide)
    bodyDv183 bodyDe183 bodyDl183 bodyDold183 bodyDfree183 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
