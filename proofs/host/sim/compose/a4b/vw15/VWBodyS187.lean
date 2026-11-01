import host.sim.compose.a4b.vw15.VWBodyJ187
import host.sim.compose.a4b.vw15.VWBodySite187
import host.sim.compose.a4b.vw15.VWBodyOracles_46
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift187 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1807.tab.length PRE_first_tail_x15_r0_body.s1807.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P187.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P187 8075 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.s1809.ffi PRE_first_tail_x15_r0_body.s1808.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_187
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_187
  have hcl : SSt (· < 8075) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1807.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_187] <;> decide) PRE_first_tail_x15_r0_body.cnodesK187 PRE_first_tail_x15_r0_body.cobjsK187
      PRE_first_tail_x15_r0_body.citemsK187 PRE_first_tail_x15_r0_body.cbd187 PRE_first_tail_x15_r0_body.csst187
  exact PRE_first_tail_x15_r0_body.cshift187 bodyNcl187 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_187] at this; exact this)


kernel_rfl bodyFramesEmpty187 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1808 a).isEmpty) = true
kernel_rfl bodyJsRoots187 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1807.next) PRE_first_tail_x15_r0_body.s1809.trace PRE_first_tail_x15_r0_body.s1809 = true
kernel_rfl bodyJsNative187 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1809.ffi) = true
kernel_rfl bodyLow187 : (PRE_first_tail_x15_r0_body.cws187 ++ PRE_first_tail_x15_r0_body.ws187).all (Nat.ble 9) = true
kernel_rfl bodyCntM187 : countersOkB PRE_first_tail_x15_r0_body.s1807 PRE_first_tail_x15_r0_body.s1808 = true
kernel_rfl bodyHi187 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1809.ffi).next setupP.E = true
kernel_rfl bodyNhi187 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1809.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge187 : bridgeOf PRE_first_tail_x15_r0_body.s1808.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1807.ffi
kernel_rfl bodyNN187 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1807.ffi).nnext PRE_first_tail_x15_r0_body.P187.NL = true
kernel_rfl bodyXn187 : Nat.ble (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1809.ffi).next = true
kernel_rfl bodyLo187 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1809.ffi).next = true
theorem bodyFacts187 : BodySiteFacts PRE_first_tail_x15_r0_body.s1807 PRE_first_tail_x15_r0_body.s1808 PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1807 PRE_first_tail_x15_r0_body.S1808 PRE_first_tail_x15_r0_body.S1809
    PRE_first_tail_x15_r0_body.ws187 PRE_first_tail_x15_r0_body.cws187 PRE_first_tail_x15_r0_body.nr187 PRE_first_tail_x15_r0_body.pl187 PRE_first_tail_x15_r0_body.cl187 2821745 8075 PRE_first_tail_x15_r0_body.kd187 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.P187
    ⟨21886, 18999, 2821743, 8075⟩ ⟨21886, 18999, 2821743, 8075⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap187
  clean := bodyClean187
  cfix := PRE_first_tail_x15_r0_body.cfix187
  zpl := PRE_first_tail_x15_r0_body.zpl187
  zplnd := PRE_first_tail_x15_r0_body.zplnd187
  zn1 := PRE_first_tail_x15_r0_body.zn1187
  zfirst := PRE_first_tail_x15_r0_body.zfirst187
  zscn := PRE_first_tail_x15_r0_body.zscn187
  zsmn := PRE_first_tail_x15_r0_body.zsmn187
  zgrow := PRE_first_tail_x15_r0_body.zgrow187
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab187
  zfresh := PRE_first_tail_x15_r0_body.zfresh187
  zcnd := PRE_first_tail_x15_r0_body.zcnd187
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi187
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt187
  zgP := PRE_first_tail_x15_r0_body.zg187_2665
  zkP := PRE_first_tail_x15_r0_body.zk187_2665
  zmP := PRE_first_tail_x15_r0_body.zm187_2665
  zgC := PRE_first_tail_x15_r0_body.zg187_2673467
  zkC := PRE_first_tail_x15_r0_body.zk187_2673467
  zmC := PRE_first_tail_x15_r0_body.zm187_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw187_2673472
  zwV := PRE_first_tail_x15_r0_body.zw187_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap187
  zclbd := PRE_first_tail_x15_r0_body.zclbd187
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap187 PRE_first_tail_x15_r0_body.stFoot187 PRE_first_tail_x15_r0_body.iso187 PRE_first_tail_x15_r0_body.zwr187
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP187
  csupp := PRE_first_tail_x15_r0_body.csupp187
  cbound := PRE_first_tail_x15_r0_body.cbound187
  zimg := PRE_first_tail_x15_r0_body.zimg187
  zctl := PRE_first_tail_x15_r0_body.zctl187
  zstack := PRE_first_tail_x15_r0_body.zstack187
  zjobs := PRE_first_tail_x15_r0_body.zjobs187
  zstores := PRE_first_tail_x15_r0_body.zstores187
  zroots := PRE_first_tail_x15_r0_body.zroots187
  znC := PRE_first_tail_x15_r0_body.znC187
  ctab := PRE_first_tail_x15_r0_body.ctab187
  zbin := PRE_first_tail_x15_r0_body.zbin187
  cbridge := PRE_first_tail_x15_r0_body.cbridge187
  sbridge := bodyBridge187
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj187
  cshiftR := fun h hNL => bodyCshift187 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN187
  raised := PRE_first_tail_x15_r0_body.raised187
  cbigs := PRE_first_tail_x15_r0_body.cbigs187
  cjcl := PRE_first_tail_x15_r0_body.cjcl187
  xnLe := Nat.le_of_ble_eq_true bodyXn187
  loLe := Nat.le_of_ble_eq_true bodyLo187
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB187
  cntM := bodyCntM187
  hiLe := Nat.le_of_ble_eq_true bodyHi187
  nhiLe := Nat.le_of_ble_eq_true bodyNhi187
  jsHeap := bodyJs187
  jsRoots := bodyJsRoots187
  jsNative := bodyJsNative187
  framesEmpty := bodyFramesEmpty187
  trailOld := by decide
  lowVars := bodyLow187

def bodyQs187 : List (Option Q) := []
noncomputable def bodyEs187 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr187.map fun r => nth? PRE_first_tail_x15_r0_body.st187.S2.tab r
kernel_rfl bodyResChk187 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs187 bodyQs187) = true
kernel_rfl bodyLq187 : bodyQs187.length = PRE_first_tail_x15_r0_body.cws187.length
kernel_rfl bodyNrLo187 : PRE_first_tail_x15_r0_body.nr187.all (Nat.ble PRE_first_tail_x15_r0_body.S1807.tab.length) = true
kernel_rfl bodySub187 : (Oracles.PRE_first_tail_x15_r0_body.map_site187.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost187 : postSubB bodyM PRE_first_tail_x15_r0_body.ws187 PRE_first_tail_x15_r0_body.cws187 bodyQs187 = true
kernel_rfl bodyDrop187 : Nat.ble (65476 + (PRE_first_tail_x15_r0_body.s1808.next - PRE_first_tail_x15_r0_body.s1809.next)) 65478 = true
kernel_rfl bodyDropH187 : Nat.ble (1251 + ((mlxOf PRE_first_tail_x15_r0_body.s1808.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1809.ffi).next)) 1251 = true
kernel_rfl bodyDropN187 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1808.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1809.ffi).nnext)) 0 = true
kernel_rfl bodyDv187 : bodyΘ.1.take 999 = bodyΘ.1.take 999 ++ PRE_first_tail_x15_r0_body.cws187
kernel_rfl bodyDe187 : bodyΘ.2.take 999 = bodyΘ.2.take 999 ++ PRE_first_tail_x15_r0_body.nr187.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st187.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 999) (bodyΘ.2.take 999)))
kernel_rfl bodyDl187 : (bodyΘ.1.take 999).length = (bodyΘ.2.take 999).length
kernel_rfl bodyDold187 : (bodyΘ.1.take 999).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws187).isNone && !PRE_first_tail_x15_r0_body.ws187.contains v) = true
kernel_rfl bodyDfree187 : (bodyΘ.2.take 999).all (fun e => (PRE_first_tail_x15_r0_body.cws187 ++ PRE_first_tail_x15_r0_body.ws187).all fun w => e.noVar w) = true

theorem bodyStep187 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65476, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1807 PRE_first_tail_x15_r0_body.S1807)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65478, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.S1809) (27 + 1) :=
  bodySite bodyFacts187.cfix bodyFacts187.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st187.S2.tab) (Es := bodyEs187) (qs := bodyQs187)
    (ok := PRE_first_tail_x15_r0_body.st187.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site187 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts187
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site187 r hr) hi (MapOk.sub hm (sub_of_all bodySub187)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk187 r hr) hi hm ho hq)
    bodyLq187 rfl bodyNrLo187 (postSub_sound bodyPost187)
    (Nat.le_of_ble_eq_true bodyDrop187) (by decide) (Nat.le_of_ble_eq_true bodyDropH187) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN187) (by decide)
    bodyDv187 bodyDe187 bodyDl187 bodyDold187 bodyDfree187 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
