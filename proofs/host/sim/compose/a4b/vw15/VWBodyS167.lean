import host.sim.compose.a4b.vw15.VWBodyJ167
import host.sim.compose.a4b.vw15.VWBodySite167
import host.sim.compose.a4b.vw15.VWBodyOracles_41
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

theorem bodyCshift167 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1609.tab.length PRE_first_tail_x15_r0_body.s1609.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P167.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P167 7192 PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.s1611.ffi PRE_first_tail_x15_r0_body.s1610.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_167
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_167
  have hcl : SSt (· < 7192) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1609.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_167] <;> decide) PRE_first_tail_x15_r0_body.cnodesK167 PRE_first_tail_x15_r0_body.cobjsK167
      PRE_first_tail_x15_r0_body.citemsK167 PRE_first_tail_x15_r0_body.cbd167 PRE_first_tail_x15_r0_body.csst167
  exact PRE_first_tail_x15_r0_body.cshift167 bodyNcl167 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_167] at this; exact this)


kernel_rfl bodyFramesEmpty167 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1610 a).isEmpty) = true
kernel_rfl bodyJsRoots167 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1609.next) PRE_first_tail_x15_r0_body.s1611.trace PRE_first_tail_x15_r0_body.s1611 = true
kernel_rfl bodyJsNative167 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1611.ffi) = true
kernel_rfl bodyLow167 : (PRE_first_tail_x15_r0_body.cws167 ++ PRE_first_tail_x15_r0_body.ws167).all (Nat.ble 9) = true
kernel_rfl bodyCntM167 : countersOkB PRE_first_tail_x15_r0_body.s1609 PRE_first_tail_x15_r0_body.s1610 = true
kernel_rfl bodyHi167 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1611.ffi).next setupP.E = true
kernel_rfl bodyNhi167 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1611.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge167 : bridgeOf PRE_first_tail_x15_r0_body.s1610.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1609.ffi
kernel_rfl bodyNN167 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1609.ffi).nnext PRE_first_tail_x15_r0_body.P167.NL = true
kernel_rfl bodyXn167 : Nat.ble (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1611.ffi).next = true
kernel_rfl bodyLo167 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1611.ffi).next = true
theorem bodyFacts167 : BodySiteFacts PRE_first_tail_x15_r0_body.s1609 PRE_first_tail_x15_r0_body.s1610 PRE_first_tail_x15_r0_body.s1611 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1609 PRE_first_tail_x15_r0_body.S1610 PRE_first_tail_x15_r0_body.S1611
    PRE_first_tail_x15_r0_body.ws167 PRE_first_tail_x15_r0_body.cws167 PRE_first_tail_x15_r0_body.nr167 PRE_first_tail_x15_r0_body.pl167 PRE_first_tail_x15_r0_body.cl167 2805821 7192 PRE_first_tail_x15_r0_body.kd167 PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.P167
    ⟨21485, 18577, 2805801, 7192⟩ ⟨21485, 18577, 2805802, 7192⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap167
  clean := bodyClean167
  cfix := PRE_first_tail_x15_r0_body.cfix167
  zpl := PRE_first_tail_x15_r0_body.zpl167
  zplnd := PRE_first_tail_x15_r0_body.zplnd167
  zn1 := PRE_first_tail_x15_r0_body.zn1167
  zfirst := PRE_first_tail_x15_r0_body.zfirst167
  zscn := PRE_first_tail_x15_r0_body.zscn167
  zsmn := PRE_first_tail_x15_r0_body.zsmn167
  zgrow := PRE_first_tail_x15_r0_body.zgrow167
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab167
  zfresh := PRE_first_tail_x15_r0_body.zfresh167
  zcnd := PRE_first_tail_x15_r0_body.zcnd167
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi167
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt167
  zgP := PRE_first_tail_x15_r0_body.zg167_2665
  zkP := PRE_first_tail_x15_r0_body.zk167_2665
  zmP := PRE_first_tail_x15_r0_body.zm167_2665
  zgC := PRE_first_tail_x15_r0_body.zg167_2673467
  zkC := PRE_first_tail_x15_r0_body.zk167_2673467
  zmC := PRE_first_tail_x15_r0_body.zm167_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw167_2673472
  zwV := PRE_first_tail_x15_r0_body.zw167_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap167
  zclbd := PRE_first_tail_x15_r0_body.zclbd167
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap167 PRE_first_tail_x15_r0_body.stFoot167 PRE_first_tail_x15_r0_body.iso167 PRE_first_tail_x15_r0_body.zwr167
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP167
  csupp := PRE_first_tail_x15_r0_body.csupp167
  cbound := PRE_first_tail_x15_r0_body.cbound167
  zimg := PRE_first_tail_x15_r0_body.zimg167
  zctl := PRE_first_tail_x15_r0_body.zctl167
  zstack := PRE_first_tail_x15_r0_body.zstack167
  zjobs := PRE_first_tail_x15_r0_body.zjobs167
  zstores := PRE_first_tail_x15_r0_body.zstores167
  zroots := PRE_first_tail_x15_r0_body.zroots167
  znC := PRE_first_tail_x15_r0_body.znC167
  ctab := PRE_first_tail_x15_r0_body.ctab167
  zbin := PRE_first_tail_x15_r0_body.zbin167
  cbridge := PRE_first_tail_x15_r0_body.cbridge167
  sbridge := bodyBridge167
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj167
  cshiftR := fun h hNL => bodyCshift167 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN167
  raised := PRE_first_tail_x15_r0_body.raised167
  cbigs := PRE_first_tail_x15_r0_body.cbigs167
  cjcl := PRE_first_tail_x15_r0_body.cjcl167
  xnLe := Nat.le_of_ble_eq_true bodyXn167
  loLe := Nat.le_of_ble_eq_true bodyLo167
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB167
  cntM := bodyCntM167
  hiLe := Nat.le_of_ble_eq_true bodyHi167
  nhiLe := Nat.le_of_ble_eq_true bodyNhi167
  jsHeap := bodyJs167
  jsRoots := bodyJsRoots167
  jsNative := bodyJsNative167
  framesEmpty := bodyFramesEmpty167
  trailOld := by decide
  lowVars := bodyLow167

def bodyQs167 : List (Option Q) := []
noncomputable def bodyEs167 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr167.map fun r => nth? PRE_first_tail_x15_r0_body.st167.S2.tab r
kernel_rfl bodyResChk167 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs167 bodyQs167) = true
kernel_rfl bodyLq167 : bodyQs167.length = PRE_first_tail_x15_r0_body.cws167.length
kernel_rfl bodyNrLo167 : PRE_first_tail_x15_r0_body.nr167.all (Nat.ble PRE_first_tail_x15_r0_body.S1609.tab.length) = true
kernel_rfl bodySub167 : (Oracles.PRE_first_tail_x15_r0_body.map_site167.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost167 : postSubB bodyM PRE_first_tail_x15_r0_body.ws167 PRE_first_tail_x15_r0_body.cws167 bodyQs167 = true
kernel_rfl bodyDrop167 : Nat.ble (58087 + (PRE_first_tail_x15_r0_body.s1610.next - PRE_first_tail_x15_r0_body.s1611.next)) 58106 = true
kernel_rfl bodyDropH167 : Nat.ble (1099 + ((mlxOf PRE_first_tail_x15_r0_body.s1610.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1611.ffi).next)) 1099 = true
kernel_rfl bodyDropN167 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1610.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1611.ffi).nnext)) 0 = true
kernel_rfl bodyDv167 : bodyΘ.1.take 882 = bodyΘ.1.take 882 ++ PRE_first_tail_x15_r0_body.cws167
kernel_rfl bodyDe167 : bodyΘ.2.take 882 = bodyΘ.2.take 882 ++ PRE_first_tail_x15_r0_body.nr167.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st167.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 882) (bodyΘ.2.take 882)))
kernel_rfl bodyDl167 : (bodyΘ.1.take 882).length = (bodyΘ.2.take 882).length
kernel_rfl bodyDold167 : (bodyΘ.1.take 882).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws167).isNone && !PRE_first_tail_x15_r0_body.ws167.contains v) = true
kernel_rfl bodyDfree167 : (bodyΘ.2.take 882).all (fun e => (PRE_first_tail_x15_r0_body.cws167 ++ PRE_first_tail_x15_r0_body.ws167).all fun w => e.noVar w) = true

theorem bodyStep167 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨58087, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1609 PRE_first_tail_x15_r0_body.S1609)
      (bodyCut NB T tk π i x0 bodyΘ ⟨58106, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1611 PRE_first_tail_x15_r0_body.S1611) (206 + 1) :=
  bodySite bodyFacts167.cfix bodyFacts167.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st167.S2.tab) (Es := bodyEs167) (qs := bodyQs167)
    (ok := PRE_first_tail_x15_r0_body.st167.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site167 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts167
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site167 r hr) hi (MapOk.sub hm (sub_of_all bodySub167)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk167 r hr) hi hm ho hq)
    bodyLq167 rfl bodyNrLo167 (postSub_sound bodyPost167)
    (Nat.le_of_ble_eq_true bodyDrop167) (by decide) (Nat.le_of_ble_eq_true bodyDropH167) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN167) (by decide)
    bodyDv167 bodyDe167 bodyDl167 bodyDold167 bodyDfree167 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
