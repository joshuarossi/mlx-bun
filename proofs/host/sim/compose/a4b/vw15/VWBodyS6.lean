import host.sim.compose.a4b.vw15.VWBodyJ6
import host.sim.compose.a4b.vw15.VWBodySite6
import host.sim.compose.a4b.vw15.VWBodyOracles_1
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift6 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S74.tab.length PRE_first_tail_x15_r0_body.s74.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P6.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P6 359 PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.s76.ffi PRE_first_tail_x15_r0_body.s75.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_6
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_6
  have hcl : SSt (· < 359) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S74.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_6] <;> decide) PRE_first_tail_x15_r0_body.cnodesK6 PRE_first_tail_x15_r0_body.cobjsK6
      PRE_first_tail_x15_r0_body.citemsK6 PRE_first_tail_x15_r0_body.cbd6 PRE_first_tail_x15_r0_body.csst6
  exact PRE_first_tail_x15_r0_body.cshift6 bodyNcl6 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_6] at this; exact this)


kernel_rfl bodyFramesEmpty6 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s75 a).isEmpty) = true
kernel_rfl bodyJsRoots6 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s74.next) PRE_first_tail_x15_r0_body.s76.trace PRE_first_tail_x15_r0_body.s76 = true
kernel_rfl bodyJsNative6 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s76.ffi) = true
kernel_rfl bodyLow6 : (PRE_first_tail_x15_r0_body.cws6 ++ PRE_first_tail_x15_r0_body.ws6).all (Nat.ble 9) = true
kernel_rfl bodyCntM6 : countersOkB PRE_first_tail_x15_r0_body.s74 PRE_first_tail_x15_r0_body.s75 = true
kernel_rfl bodyHi6 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s76.ffi).next setupP.E = true
kernel_rfl bodyNhi6 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s76.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge6 : bridgeOf PRE_first_tail_x15_r0_body.s75.ffi = bridgeOf PRE_first_tail_x15_r0_body.s74.ffi
kernel_rfl bodyNN6 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s74.ffi).nnext PRE_first_tail_x15_r0_body.P6.NL = true
kernel_rfl bodyXn6 : Nat.ble (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s76.ffi).next = true
kernel_rfl bodyLo6 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s76.ffi).next = true
theorem bodyFacts6 : BodySiteFacts PRE_first_tail_x15_r0_body.s74 PRE_first_tail_x15_r0_body.s75 PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S74 PRE_first_tail_x15_r0_body.S75 PRE_first_tail_x15_r0_body.S76
    PRE_first_tail_x15_r0_body.ws6 PRE_first_tail_x15_r0_body.cws6 PRE_first_tail_x15_r0_body.nr6 PRE_first_tail_x15_r0_body.pl6 PRE_first_tail_x15_r0_body.cl6 2681128 359 PRE_first_tail_x15_r0_body.kd6 PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.P6
    ⟨18330, 15404, 2679973, 341⟩ ⟨18333, 15431, 2679979, 359⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap6
  clean := bodyClean6
  cfix := PRE_first_tail_x15_r0_body.cfix6
  zpl := PRE_first_tail_x15_r0_body.zpl6
  zplnd := PRE_first_tail_x15_r0_body.zplnd6
  zn1 := PRE_first_tail_x15_r0_body.zn16
  zfirst := PRE_first_tail_x15_r0_body.zfirst6
  zscn := PRE_first_tail_x15_r0_body.zscn6
  zsmn := PRE_first_tail_x15_r0_body.zsmn6
  zgrow := PRE_first_tail_x15_r0_body.zgrow6
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab6
  zfresh := PRE_first_tail_x15_r0_body.zfresh6
  zcnd := PRE_first_tail_x15_r0_body.zcnd6
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi6
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt6
  zgP := PRE_first_tail_x15_r0_body.zg6_2665
  zkP := PRE_first_tail_x15_r0_body.zk6_2665
  zmP := PRE_first_tail_x15_r0_body.zm6_2665
  zgC := PRE_first_tail_x15_r0_body.zg6_2673467
  zkC := PRE_first_tail_x15_r0_body.zk6_2673467
  zmC := PRE_first_tail_x15_r0_body.zm6_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw6_2673472
  zwV := PRE_first_tail_x15_r0_body.zw6_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap6
  zclbd := PRE_first_tail_x15_r0_body.zclbd6
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap6 PRE_first_tail_x15_r0_body.stFoot6 PRE_first_tail_x15_r0_body.iso6 PRE_first_tail_x15_r0_body.zwr6
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP6
  csupp := PRE_first_tail_x15_r0_body.csupp6
  cbound := PRE_first_tail_x15_r0_body.cbound6
  zimg := PRE_first_tail_x15_r0_body.zimg6
  zctl := PRE_first_tail_x15_r0_body.zctl6
  zstack := PRE_first_tail_x15_r0_body.zstack6
  zjobs := PRE_first_tail_x15_r0_body.zjobs6
  zstores := PRE_first_tail_x15_r0_body.zstores6
  zroots := PRE_first_tail_x15_r0_body.zroots6
  znC := PRE_first_tail_x15_r0_body.znC6
  ctab := PRE_first_tail_x15_r0_body.ctab6
  zbin := PRE_first_tail_x15_r0_body.zbin6
  cbridge := PRE_first_tail_x15_r0_body.cbridge6
  sbridge := bodyBridge6
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj6
  cshiftR := fun h hNL => bodyCshift6 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN6
  raised := PRE_first_tail_x15_r0_body.raised6
  cbigs := PRE_first_tail_x15_r0_body.cbigs6
  cjcl := PRE_first_tail_x15_r0_body.cjcl6
  xnLe := Nat.le_of_ble_eq_true bodyXn6
  loLe := Nat.le_of_ble_eq_true bodyLo6
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB6
  cntM := bodyCntM6
  hiLe := Nat.le_of_ble_eq_true bodyHi6
  nhiLe := Nat.le_of_ble_eq_true bodyNhi6
  jsHeap := bodyJs6
  jsRoots := bodyJsRoots6
  jsNative := bodyJsNative6
  framesEmpty := bodyFramesEmpty6
  trailOld := by decide
  lowVars := bodyLow6

def bodyQs6 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs6 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr6.map fun r => nth? PRE_first_tail_x15_r0_body.st6.S5.tab r
kernel_rfl bodyResChk6 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs6 bodyQs6) = true
kernel_rfl bodyLq6 : bodyQs6.length = PRE_first_tail_x15_r0_body.cws6.length
kernel_rfl bodyNrLo6 : PRE_first_tail_x15_r0_body.nr6.all (Nat.ble PRE_first_tail_x15_r0_body.S74.tab.length) = true
kernel_rfl bodySub6 : (Oracles.PRE_first_tail_x15_r0_body.map_site6.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost6 : postSubB bodyM PRE_first_tail_x15_r0_body.ws6 PRE_first_tail_x15_r0_body.cws6 bodyQs6 = true
kernel_rfl bodyDrop6 : Nat.ble (6445 + (PRE_first_tail_x15_r0_body.s75.next - PRE_first_tail_x15_r0_body.s76.next)) 7594 = true
kernel_rfl bodyDropH6 : Nat.ble (71 + ((mlxOf PRE_first_tail_x15_r0_body.s75.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s76.ffi).next)) 96 = true
kernel_rfl bodyDropN6 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s75.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s76.ffi).nnext)) 0 = true
kernel_rfl bodyDv6 : bodyΘ.1.take 54 = bodyΘ.1.take 36 ++ PRE_first_tail_x15_r0_body.cws6
kernel_rfl bodyDe6 : bodyΘ.2.take 54 = bodyΘ.2.take 36 ++ PRE_first_tail_x15_r0_body.nr6.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st6.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 36) (bodyΘ.2.take 36)))
kernel_rfl bodyDl6 : (bodyΘ.1.take 36).length = (bodyΘ.2.take 36).length
kernel_rfl bodyDold6 : (bodyΘ.1.take 36).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws6).isNone && !PRE_first_tail_x15_r0_body.ws6.contains v) = true
kernel_rfl bodyDfree6 : (bodyΘ.2.take 54).all (fun e => (PRE_first_tail_x15_r0_body.cws6 ++ PRE_first_tail_x15_r0_body.ws6).all fun w => e.noVar w) = true

theorem bodyStep6 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6445, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s74 PRE_first_tail_x15_r0_body.S74)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7594, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.S76) (11334 + 1) :=
  bodySite bodyFacts6.cfix bodyFacts6.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st6.S5.tab) (Es := bodyEs6) (qs := bodyQs6)
    (ok := PRE_first_tail_x15_r0_body.st6.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site6 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts6
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site6 r hr) hi (MapOk.sub hm (sub_of_all bodySub6)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk6 r hr) hi hm ho hq)
    bodyLq6 rfl bodyNrLo6 (postSub_sound bodyPost6)
    (Nat.le_of_ble_eq_true bodyDrop6) (by decide) (Nat.le_of_ble_eq_true bodyDropH6) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN6) (by decide)
    bodyDv6 bodyDe6 bodyDl6 bodyDold6 bodyDfree6 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
