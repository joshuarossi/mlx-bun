import host.sim.compose.a4b.vw15.VWBodyJ157
import host.sim.compose.a4b.vw15.VWBodySite157
import host.sim.compose.a4b.vw15.VWBodyOracles_39
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

theorem bodyCshift157 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1519.tab.length PRE_first_tail_x15_r0_body.s1519.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P157.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P157 6791 PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.s1521.ffi PRE_first_tail_x15_r0_body.s1520.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_157
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_157
  have hcl : SSt (· < 6791) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1521.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1519.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_157] <;> decide) PRE_first_tail_x15_r0_body.cnodesK157 PRE_first_tail_x15_r0_body.cobjsK157
      PRE_first_tail_x15_r0_body.citemsK157 PRE_first_tail_x15_r0_body.cbd157 PRE_first_tail_x15_r0_body.csst157
  exact PRE_first_tail_x15_r0_body.cshift157 bodyNcl157 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_157] at this; exact this)


kernel_rfl bodyFramesEmpty157 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1520 a).isEmpty) = true
kernel_rfl bodyJsRoots157 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1519.next) PRE_first_tail_x15_r0_body.s1521.trace PRE_first_tail_x15_r0_body.s1521 = true
kernel_rfl bodyJsNative157 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1521.ffi) = true
kernel_rfl bodyLow157 : (PRE_first_tail_x15_r0_body.cws157 ++ PRE_first_tail_x15_r0_body.ws157).all (Nat.ble 9) = true
kernel_rfl bodyCntM157 : countersOkB PRE_first_tail_x15_r0_body.s1519 PRE_first_tail_x15_r0_body.s1520 = true
kernel_rfl bodyHi157 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1521.ffi).next setupP.E = true
kernel_rfl bodyNhi157 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1521.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge157 : bridgeOf PRE_first_tail_x15_r0_body.s1520.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1519.ffi
kernel_rfl bodyNN157 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1519.ffi).nnext PRE_first_tail_x15_r0_body.P157.NL = true
kernel_rfl bodyXn157 : Nat.ble (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1521.ffi).next = true
kernel_rfl bodyLo157 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1521.ffi).next = true
theorem bodyFacts157 : BodySiteFacts PRE_first_tail_x15_r0_body.s1519 PRE_first_tail_x15_r0_body.s1520 PRE_first_tail_x15_r0_body.s1521 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1519 PRE_first_tail_x15_r0_body.S1520 PRE_first_tail_x15_r0_body.S1521
    PRE_first_tail_x15_r0_body.ws157 PRE_first_tail_x15_r0_body.cws157 PRE_first_tail_x15_r0_body.nr157 PRE_first_tail_x15_r0_body.pl157 PRE_first_tail_x15_r0_body.cl157 2798377 6791 PRE_first_tail_x15_r0_body.kd157 PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.P157
    ⟨21300, 18399, 2798375, 6791⟩ ⟨21300, 18399, 2798375, 6791⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap157
  clean := bodyClean157
  cfix := PRE_first_tail_x15_r0_body.cfix157
  zpl := PRE_first_tail_x15_r0_body.zpl157
  zplnd := PRE_first_tail_x15_r0_body.zplnd157
  zn1 := PRE_first_tail_x15_r0_body.zn1157
  zfirst := PRE_first_tail_x15_r0_body.zfirst157
  zscn := PRE_first_tail_x15_r0_body.zscn157
  zsmn := PRE_first_tail_x15_r0_body.zsmn157
  zgrow := PRE_first_tail_x15_r0_body.zgrow157
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab157
  zfresh := PRE_first_tail_x15_r0_body.zfresh157
  zcnd := PRE_first_tail_x15_r0_body.zcnd157
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi157
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt157
  zgP := PRE_first_tail_x15_r0_body.zg157_2665
  zkP := PRE_first_tail_x15_r0_body.zk157_2665
  zmP := PRE_first_tail_x15_r0_body.zm157_2665
  zgC := PRE_first_tail_x15_r0_body.zg157_2673467
  zkC := PRE_first_tail_x15_r0_body.zk157_2673467
  zmC := PRE_first_tail_x15_r0_body.zm157_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw157_2673472
  zwV := PRE_first_tail_x15_r0_body.zw157_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap157
  zclbd := PRE_first_tail_x15_r0_body.zclbd157
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap157 PRE_first_tail_x15_r0_body.stFoot157 PRE_first_tail_x15_r0_body.iso157 PRE_first_tail_x15_r0_body.zwr157
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP157
  csupp := PRE_first_tail_x15_r0_body.csupp157
  cbound := PRE_first_tail_x15_r0_body.cbound157
  zimg := PRE_first_tail_x15_r0_body.zimg157
  zctl := PRE_first_tail_x15_r0_body.zctl157
  zstack := PRE_first_tail_x15_r0_body.zstack157
  zjobs := PRE_first_tail_x15_r0_body.zjobs157
  zstores := PRE_first_tail_x15_r0_body.zstores157
  zroots := PRE_first_tail_x15_r0_body.zroots157
  znC := PRE_first_tail_x15_r0_body.znC157
  ctab := PRE_first_tail_x15_r0_body.ctab157
  zbin := PRE_first_tail_x15_r0_body.zbin157
  cbridge := PRE_first_tail_x15_r0_body.cbridge157
  sbridge := bodyBridge157
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj157
  cshiftR := fun h hNL => bodyCshift157 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN157
  raised := PRE_first_tail_x15_r0_body.raised157
  cbigs := PRE_first_tail_x15_r0_body.cbigs157
  cjcl := PRE_first_tail_x15_r0_body.cjcl157
  xnLe := Nat.le_of_ble_eq_true bodyXn157
  loLe := Nat.le_of_ble_eq_true bodyLo157
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB157
  cntM := bodyCntM157
  hiLe := Nat.le_of_ble_eq_true bodyHi157
  nhiLe := Nat.le_of_ble_eq_true bodyNhi157
  jsHeap := bodyJs157
  jsRoots := bodyJsRoots157
  jsNative := bodyJsNative157
  framesEmpty := bodyFramesEmpty157
  trailOld := by decide
  lowVars := bodyLow157

def bodyQs157 : List (Option Q) := []
noncomputable def bodyEs157 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr157.map fun r => nth? PRE_first_tail_x15_r0_body.st157.S2.tab r
kernel_rfl bodyResChk157 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs157 bodyQs157) = true
kernel_rfl bodyLq157 : bodyQs157.length = PRE_first_tail_x15_r0_body.cws157.length
kernel_rfl bodyNrLo157 : PRE_first_tail_x15_r0_body.nr157.all (Nat.ble PRE_first_tail_x15_r0_body.S1519.tab.length) = true
kernel_rfl bodySub157 : (Oracles.PRE_first_tail_x15_r0_body.map_site157.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost157 : postSubB bodyM PRE_first_tail_x15_r0_body.ws157 PRE_first_tail_x15_r0_body.cws157 bodyQs157 = true
kernel_rfl bodyDrop157 : Nat.ble (55392 + (PRE_first_tail_x15_r0_body.s1520.next - PRE_first_tail_x15_r0_body.s1521.next)) 55394 = true
kernel_rfl bodyDropH157 : Nat.ble (1047 + ((mlxOf PRE_first_tail_x15_r0_body.s1520.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1521.ffi).next)) 1047 = true
kernel_rfl bodyDropN157 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1520.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1521.ffi).nnext)) 0 = true
kernel_rfl bodyDv157 : bodyΘ.1.take 837 = bodyΘ.1.take 837 ++ PRE_first_tail_x15_r0_body.cws157
kernel_rfl bodyDe157 : bodyΘ.2.take 837 = bodyΘ.2.take 837 ++ PRE_first_tail_x15_r0_body.nr157.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st157.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 837) (bodyΘ.2.take 837)))
kernel_rfl bodyDl157 : (bodyΘ.1.take 837).length = (bodyΘ.2.take 837).length
kernel_rfl bodyDold157 : (bodyΘ.1.take 837).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws157).isNone && !PRE_first_tail_x15_r0_body.ws157.contains v) = true
kernel_rfl bodyDfree157 : (bodyΘ.2.take 837).all (fun e => (PRE_first_tail_x15_r0_body.cws157 ++ PRE_first_tail_x15_r0_body.ws157).all fun w => e.noVar w) = true

theorem bodyStep157 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨55392, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1519 PRE_first_tail_x15_r0_body.S1519)
      (bodyCut NB T tk π i x0 bodyΘ ⟨55394, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1521 PRE_first_tail_x15_r0_body.S1521) (27 + 1) :=
  bodySite bodyFacts157.cfix bodyFacts157.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st157.S2.tab) (Es := bodyEs157) (qs := bodyQs157)
    (ok := PRE_first_tail_x15_r0_body.st157.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site157 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts157
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site157 r hr) hi (MapOk.sub hm (sub_of_all bodySub157)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk157 r hr) hi hm ho hq)
    bodyLq157 rfl bodyNrLo157 (postSub_sound bodyPost157)
    (Nat.le_of_ble_eq_true bodyDrop157) (by decide) (Nat.le_of_ble_eq_true bodyDropH157) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN157) (by decide)
    bodyDv157 bodyDe157 bodyDl157 bodyDold157 bodyDfree157 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
