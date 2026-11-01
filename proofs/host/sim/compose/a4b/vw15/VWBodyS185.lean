import host.sim.compose.a4b.vw15.VWBodyJ185
import host.sim.compose.a4b.vw15.VWBodySite185
import host.sim.compose.a4b.vw15.VWBodyOracles_46
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

theorem bodyCshift185 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1782.tab.length PRE_first_tail_x15_r0_body.s1782.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P185.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P185 7963 PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.s1784.ffi PRE_first_tail_x15_r0_body.s1783.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_185
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_185
  have hcl : SSt (· < 7963) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1782.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_185] <;> decide) PRE_first_tail_x15_r0_body.cnodesK185 PRE_first_tail_x15_r0_body.cobjsK185
      PRE_first_tail_x15_r0_body.citemsK185 PRE_first_tail_x15_r0_body.cbd185 PRE_first_tail_x15_r0_body.csst185
  exact PRE_first_tail_x15_r0_body.cshift185 bodyNcl185 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_185] at this; exact this)


kernel_rfl bodyFramesEmpty185 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1783 a).isEmpty) = true
kernel_rfl bodyJsRoots185 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1782.next) PRE_first_tail_x15_r0_body.s1784.trace PRE_first_tail_x15_r0_body.s1784 = true
kernel_rfl bodyJsNative185 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1784.ffi) = true
kernel_rfl bodyLow185 : (PRE_first_tail_x15_r0_body.cws185 ++ PRE_first_tail_x15_r0_body.ws185).all (Nat.ble 9) = true
kernel_rfl bodyCntM185 : countersOkB PRE_first_tail_x15_r0_body.s1782 PRE_first_tail_x15_r0_body.s1783 = true
kernel_rfl bodyHi185 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1784.ffi).next setupP.E = true
kernel_rfl bodyNhi185 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1784.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge185 : bridgeOf PRE_first_tail_x15_r0_body.s1783.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1782.ffi
kernel_rfl bodyNN185 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1782.ffi).nnext PRE_first_tail_x15_r0_body.P185.NL = true
kernel_rfl bodyXn185 : Nat.ble (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1784.ffi).next = true
kernel_rfl bodyLo185 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1784.ffi).next = true
theorem bodyFacts185 : BodySiteFacts PRE_first_tail_x15_r0_body.s1782 PRE_first_tail_x15_r0_body.s1783 PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1782 PRE_first_tail_x15_r0_body.S1783 PRE_first_tail_x15_r0_body.S1784
    PRE_first_tail_x15_r0_body.ws185 PRE_first_tail_x15_r0_body.cws185 PRE_first_tail_x15_r0_body.nr185 PRE_first_tail_x15_r0_body.pl185 PRE_first_tail_x15_r0_body.cl185 2819791 7963 PRE_first_tail_x15_r0_body.kd185 PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.P185
    ⟨21836, 18940, 2819771, 7963⟩ ⟨21836, 18940, 2819772, 7963⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap185
  clean := bodyClean185
  cfix := PRE_first_tail_x15_r0_body.cfix185
  zpl := PRE_first_tail_x15_r0_body.zpl185
  zplnd := PRE_first_tail_x15_r0_body.zplnd185
  zn1 := PRE_first_tail_x15_r0_body.zn1185
  zfirst := PRE_first_tail_x15_r0_body.zfirst185
  zscn := PRE_first_tail_x15_r0_body.zscn185
  zsmn := PRE_first_tail_x15_r0_body.zsmn185
  zgrow := PRE_first_tail_x15_r0_body.zgrow185
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab185
  zfresh := PRE_first_tail_x15_r0_body.zfresh185
  zcnd := PRE_first_tail_x15_r0_body.zcnd185
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi185
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt185
  zgP := PRE_first_tail_x15_r0_body.zg185_2665
  zkP := PRE_first_tail_x15_r0_body.zk185_2665
  zmP := PRE_first_tail_x15_r0_body.zm185_2665
  zgC := PRE_first_tail_x15_r0_body.zg185_2673467
  zkC := PRE_first_tail_x15_r0_body.zk185_2673467
  zmC := PRE_first_tail_x15_r0_body.zm185_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw185_2673472
  zwV := PRE_first_tail_x15_r0_body.zw185_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap185
  zclbd := PRE_first_tail_x15_r0_body.zclbd185
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap185 PRE_first_tail_x15_r0_body.stFoot185 PRE_first_tail_x15_r0_body.iso185 PRE_first_tail_x15_r0_body.zwr185
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP185
  csupp := PRE_first_tail_x15_r0_body.csupp185
  cbound := PRE_first_tail_x15_r0_body.cbound185
  zimg := PRE_first_tail_x15_r0_body.zimg185
  zctl := PRE_first_tail_x15_r0_body.zctl185
  zstack := PRE_first_tail_x15_r0_body.zstack185
  zjobs := PRE_first_tail_x15_r0_body.zjobs185
  zstores := PRE_first_tail_x15_r0_body.zstores185
  zroots := PRE_first_tail_x15_r0_body.zroots185
  znC := PRE_first_tail_x15_r0_body.znC185
  ctab := PRE_first_tail_x15_r0_body.ctab185
  zbin := PRE_first_tail_x15_r0_body.zbin185
  cbridge := PRE_first_tail_x15_r0_body.cbridge185
  sbridge := bodyBridge185
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj185
  cshiftR := fun h hNL => bodyCshift185 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN185
  raised := PRE_first_tail_x15_r0_body.raised185
  cbigs := PRE_first_tail_x15_r0_body.cbigs185
  cjcl := PRE_first_tail_x15_r0_body.cjcl185
  xnLe := Nat.le_of_ble_eq_true bodyXn185
  loLe := Nat.le_of_ble_eq_true bodyLo185
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB185
  cntM := bodyCntM185
  hiLe := Nat.le_of_ble_eq_true bodyHi185
  nhiLe := Nat.le_of_ble_eq_true bodyNhi185
  jsHeap := bodyJs185
  jsRoots := bodyJsRoots185
  jsNative := bodyJsNative185
  framesEmpty := bodyFramesEmpty185
  trailOld := by decide
  lowVars := bodyLow185

def bodyQs185 : List (Option Q) := []
noncomputable def bodyEs185 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr185.map fun r => nth? PRE_first_tail_x15_r0_body.st185.S2.tab r
kernel_rfl bodyResChk185 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs185 bodyQs185) = true
kernel_rfl bodyLq185 : bodyQs185.length = PRE_first_tail_x15_r0_body.cws185.length
kernel_rfl bodyNrLo185 : PRE_first_tail_x15_r0_body.nr185.all (Nat.ble PRE_first_tail_x15_r0_body.S1782.tab.length) = true
kernel_rfl bodySub185 : (Oracles.PRE_first_tail_x15_r0_body.map_site185.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost185 : postSubB bodyM PRE_first_tail_x15_r0_body.ws185 PRE_first_tail_x15_r0_body.cws185 bodyQs185 = true
kernel_rfl bodyDrop185 : Nat.ble (64308 + (PRE_first_tail_x15_r0_body.s1783.next - PRE_first_tail_x15_r0_body.s1784.next)) 64327 = true
kernel_rfl bodyDropH185 : Nat.ble (1226 + ((mlxOf PRE_first_tail_x15_r0_body.s1783.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1784.ffi).next)) 1226 = true
kernel_rfl bodyDropN185 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1783.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1784.ffi).nnext)) 0 = true
kernel_rfl bodyDv185 : bodyΘ.1.take 981 = bodyΘ.1.take 981 ++ PRE_first_tail_x15_r0_body.cws185
kernel_rfl bodyDe185 : bodyΘ.2.take 981 = bodyΘ.2.take 981 ++ PRE_first_tail_x15_r0_body.nr185.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st185.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 981) (bodyΘ.2.take 981)))
kernel_rfl bodyDl185 : (bodyΘ.1.take 981).length = (bodyΘ.2.take 981).length
kernel_rfl bodyDold185 : (bodyΘ.1.take 981).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws185).isNone && !PRE_first_tail_x15_r0_body.ws185.contains v) = true
kernel_rfl bodyDfree185 : (bodyΘ.2.take 981).all (fun e => (PRE_first_tail_x15_r0_body.cws185 ++ PRE_first_tail_x15_r0_body.ws185).all fun w => e.noVar w) = true

theorem bodyStep185 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64308, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1782 PRE_first_tail_x15_r0_body.S1782)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64327, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.S1784) (206 + 1) :=
  bodySite bodyFacts185.cfix bodyFacts185.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st185.S2.tab) (Es := bodyEs185) (qs := bodyQs185)
    (ok := PRE_first_tail_x15_r0_body.st185.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site185 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts185
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site185 r hr) hi (MapOk.sub hm (sub_of_all bodySub185)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk185 r hr) hi hm ho hq)
    bodyLq185 rfl bodyNrLo185 (postSub_sound bodyPost185)
    (Nat.le_of_ble_eq_true bodyDrop185) (by decide) (Nat.le_of_ble_eq_true bodyDropH185) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN185) (by decide)
    bodyDv185 bodyDe185 bodyDl185 bodyDold185 bodyDfree185 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
