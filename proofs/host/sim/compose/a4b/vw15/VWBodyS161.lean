import host.sim.compose.a4b.vw15.VWBodyJ161
import host.sim.compose.a4b.vw15.VWBodySite161
import host.sim.compose.a4b.vw15.VWBodyOracles_40
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift161 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1552.tab.length PRE_first_tail_x15_r0_body.s1552.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P161.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P161 6937 PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.s1554.ffi PRE_first_tail_x15_r0_body.s1553.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_161
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_161
  have hcl : SSt (· < 6937) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1552.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_161] <;> decide) PRE_first_tail_x15_r0_body.cnodesK161 PRE_first_tail_x15_r0_body.cobjsK161
      PRE_first_tail_x15_r0_body.citemsK161 PRE_first_tail_x15_r0_body.cbd161 PRE_first_tail_x15_r0_body.csst161
  exact PRE_first_tail_x15_r0_body.cshift161 bodyNcl161 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_161] at this; exact this)


kernel_rfl bodyFramesEmpty161 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1553 a).isEmpty) = true
kernel_rfl bodyJsRoots161 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1552.next) PRE_first_tail_x15_r0_body.s1554.trace PRE_first_tail_x15_r0_body.s1554 = true
kernel_rfl bodyJsNative161 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1554.ffi) = true
kernel_rfl bodyLow161 : (PRE_first_tail_x15_r0_body.cws161 ++ PRE_first_tail_x15_r0_body.ws161).all (Nat.ble 9) = true
kernel_rfl bodyCntM161 : countersOkB PRE_first_tail_x15_r0_body.s1552 PRE_first_tail_x15_r0_body.s1553 = true
kernel_rfl bodyHi161 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1554.ffi).next setupP.E = true
kernel_rfl bodyNhi161 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1554.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge161 : bridgeOf PRE_first_tail_x15_r0_body.s1553.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1552.ffi
kernel_rfl bodyNN161 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1552.ffi).nnext PRE_first_tail_x15_r0_body.P161.NL = true
kernel_rfl bodyXn161 : Nat.ble (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1554.ffi).next = true
kernel_rfl bodyLo161 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1554.ffi).next = true
theorem bodyFacts161 : BodySiteFacts PRE_first_tail_x15_r0_body.s1552 PRE_first_tail_x15_r0_body.s1553 PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1552 PRE_first_tail_x15_r0_body.S1553 PRE_first_tail_x15_r0_body.S1554
    PRE_first_tail_x15_r0_body.ws161 PRE_first_tail_x15_r0_body.cws161 PRE_first_tail_x15_r0_body.nr161 PRE_first_tail_x15_r0_body.pl161 PRE_first_tail_x15_r0_body.cl161 2800930 6937 PRE_first_tail_x15_r0_body.kd161 PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.P161
    ⟨21364, 18466, 2800919, 6937⟩ ⟨21364, 18466, 2800920, 6937⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap161
  clean := bodyClean161
  cfix := PRE_first_tail_x15_r0_body.cfix161
  zpl := PRE_first_tail_x15_r0_body.zpl161
  zplnd := PRE_first_tail_x15_r0_body.zplnd161
  zn1 := PRE_first_tail_x15_r0_body.zn1161
  zfirst := PRE_first_tail_x15_r0_body.zfirst161
  zscn := PRE_first_tail_x15_r0_body.zscn161
  zsmn := PRE_first_tail_x15_r0_body.zsmn161
  zgrow := PRE_first_tail_x15_r0_body.zgrow161
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab161
  zfresh := PRE_first_tail_x15_r0_body.zfresh161
  zcnd := PRE_first_tail_x15_r0_body.zcnd161
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi161
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt161
  zgP := PRE_first_tail_x15_r0_body.zg161_2665
  zkP := PRE_first_tail_x15_r0_body.zk161_2665
  zmP := PRE_first_tail_x15_r0_body.zm161_2665
  zgC := PRE_first_tail_x15_r0_body.zg161_2673467
  zkC := PRE_first_tail_x15_r0_body.zk161_2673467
  zmC := PRE_first_tail_x15_r0_body.zm161_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw161_2673472
  zwV := PRE_first_tail_x15_r0_body.zw161_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap161
  zclbd := PRE_first_tail_x15_r0_body.zclbd161
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap161 PRE_first_tail_x15_r0_body.stFoot161 PRE_first_tail_x15_r0_body.iso161 PRE_first_tail_x15_r0_body.zwr161
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP161
  csupp := PRE_first_tail_x15_r0_body.csupp161
  cbound := PRE_first_tail_x15_r0_body.cbound161
  zimg := PRE_first_tail_x15_r0_body.zimg161
  zctl := PRE_first_tail_x15_r0_body.zctl161
  zstack := PRE_first_tail_x15_r0_body.zstack161
  zjobs := PRE_first_tail_x15_r0_body.zjobs161
  zstores := PRE_first_tail_x15_r0_body.zstores161
  zroots := PRE_first_tail_x15_r0_body.zroots161
  znC := PRE_first_tail_x15_r0_body.znC161
  ctab := PRE_first_tail_x15_r0_body.ctab161
  zbin := PRE_first_tail_x15_r0_body.zbin161
  cbridge := PRE_first_tail_x15_r0_body.cbridge161
  sbridge := bodyBridge161
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj161
  cshiftR := fun h hNL => bodyCshift161 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN161
  raised := PRE_first_tail_x15_r0_body.raised161
  cbigs := PRE_first_tail_x15_r0_body.cbigs161
  cjcl := PRE_first_tail_x15_r0_body.cjcl161
  xnLe := Nat.le_of_ble_eq_true bodyXn161
  loLe := Nat.le_of_ble_eq_true bodyLo161
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB161
  cntM := bodyCntM161
  hiLe := Nat.le_of_ble_eq_true bodyHi161
  nhiLe := Nat.le_of_ble_eq_true bodyNhi161
  jsHeap := bodyJs161
  jsRoots := bodyJsRoots161
  jsNative := bodyJsNative161
  framesEmpty := bodyFramesEmpty161
  trailOld := by decide
  lowVars := bodyLow161

def bodyQs161 : List (Option Q) := []
noncomputable def bodyEs161 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr161.map fun r => nth? PRE_first_tail_x15_r0_body.st161.S2.tab r
kernel_rfl bodyResChk161 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs161 bodyQs161) = true
kernel_rfl bodyLq161 : bodyQs161.length = PRE_first_tail_x15_r0_body.cws161.length
kernel_rfl bodyNrLo161 : PRE_first_tail_x15_r0_body.nr161.all (Nat.ble PRE_first_tail_x15_r0_body.S1552.tab.length) = true
kernel_rfl bodySub161 : (Oracles.PRE_first_tail_x15_r0_body.map_site161.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost161 : postSubB bodyM PRE_first_tail_x15_r0_body.ws161 PRE_first_tail_x15_r0_body.cws161 bodyQs161 = true
kernel_rfl bodyDrop161 : Nat.ble (56555 + (PRE_first_tail_x15_r0_body.s1553.next - PRE_first_tail_x15_r0_body.s1554.next)) 56565 = true
kernel_rfl bodyDropH161 : Nat.ble (1072 + ((mlxOf PRE_first_tail_x15_r0_body.s1553.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1554.ffi).next)) 1072 = true
kernel_rfl bodyDropN161 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1553.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1554.ffi).nnext)) 0 = true
kernel_rfl bodyDv161 : bodyΘ.1.take 855 = bodyΘ.1.take 855 ++ PRE_first_tail_x15_r0_body.cws161
kernel_rfl bodyDe161 : bodyΘ.2.take 855 = bodyΘ.2.take 855 ++ PRE_first_tail_x15_r0_body.nr161.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st161.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 855) (bodyΘ.2.take 855)))
kernel_rfl bodyDl161 : (bodyΘ.1.take 855).length = (bodyΘ.2.take 855).length
kernel_rfl bodyDold161 : (bodyΘ.1.take 855).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws161).isNone && !PRE_first_tail_x15_r0_body.ws161.contains v) = true
kernel_rfl bodyDfree161 : (bodyΘ.2.take 855).all (fun e => (PRE_first_tail_x15_r0_body.cws161 ++ PRE_first_tail_x15_r0_body.ws161).all fun w => e.noVar w) = true

theorem bodyStep161 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨56555, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1552 PRE_first_tail_x15_r0_body.S1552)
      (bodyCut NB T tk π i x0 bodyΘ ⟨56565, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.S1554) (98 + 1) :=
  bodySite bodyFacts161.cfix bodyFacts161.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st161.S2.tab) (Es := bodyEs161) (qs := bodyQs161)
    (ok := PRE_first_tail_x15_r0_body.st161.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site161 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts161
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site161 r hr) hi (MapOk.sub hm (sub_of_all bodySub161)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk161 r hr) hi hm ho hq)
    bodyLq161 rfl bodyNrLo161 (postSub_sound bodyPost161)
    (Nat.le_of_ble_eq_true bodyDrop161) (by decide) (Nat.le_of_ble_eq_true bodyDropH161) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN161) (by decide)
    bodyDv161 bodyDe161 bodyDl161 bodyDold161 bodyDfree161 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
