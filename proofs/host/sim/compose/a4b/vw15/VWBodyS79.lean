import host.sim.compose.a4b.vw15.VWBodyJ79
import host.sim.compose.a4b.vw15.VWBodySite79
import host.sim.compose.a4b.vw15.VWBodyOracles_19
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift79 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S772.tab.length PRE_first_tail_x15_r0_body.s772.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P79.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P79 3458 PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.s774.ffi PRE_first_tail_x15_r0_body.s773.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_79
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_79
  have hcl : SSt (· < 3458) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S772.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_79] <;> decide) PRE_first_tail_x15_r0_body.cnodesK79 PRE_first_tail_x15_r0_body.cobjsK79
      PRE_first_tail_x15_r0_body.citemsK79 PRE_first_tail_x15_r0_body.cbd79 PRE_first_tail_x15_r0_body.csst79
  exact PRE_first_tail_x15_r0_body.cshift79 bodyNcl79 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_79] at this; exact this)


kernel_rfl bodyFramesEmpty79 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s773 a).isEmpty) = true
kernel_rfl bodyJsRoots79 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s772.next) PRE_first_tail_x15_r0_body.s774.trace PRE_first_tail_x15_r0_body.s774 = true
kernel_rfl bodyJsNative79 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s774.ffi) = true
kernel_rfl bodyLow79 : (PRE_first_tail_x15_r0_body.cws79 ++ PRE_first_tail_x15_r0_body.ws79).all (Nat.ble 9) = true
kernel_rfl bodyCntM79 : countersOkB PRE_first_tail_x15_r0_body.s772 PRE_first_tail_x15_r0_body.s773 = true
kernel_rfl bodyHi79 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s774.ffi).next setupP.E = true
kernel_rfl bodyNhi79 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s774.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge79 : bridgeOf PRE_first_tail_x15_r0_body.s773.ffi = bridgeOf PRE_first_tail_x15_r0_body.s772.ffi
kernel_rfl bodyNN79 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s772.ffi).nnext PRE_first_tail_x15_r0_body.P79.NL = true
kernel_rfl bodyXn79 : Nat.ble (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s774.ffi).next = true
kernel_rfl bodyLo79 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s774.ffi).next = true
theorem bodyFacts79 : BodySiteFacts PRE_first_tail_x15_r0_body.s772 PRE_first_tail_x15_r0_body.s773 PRE_first_tail_x15_r0_body.s774 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S772 PRE_first_tail_x15_r0_body.S773 PRE_first_tail_x15_r0_body.S774
    PRE_first_tail_x15_r0_body.ws79 PRE_first_tail_x15_r0_body.cws79 PRE_first_tail_x15_r0_body.nr79 PRE_first_tail_x15_r0_body.pl79 PRE_first_tail_x15_r0_body.cl79 2736969 3458 PRE_first_tail_x15_r0_body.kd79 PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.P79
    ⟨19762, 16866, 2736967, 3458⟩ ⟨19762, 16866, 2736967, 3458⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap79
  clean := bodyClean79
  cfix := PRE_first_tail_x15_r0_body.cfix79
  zpl := PRE_first_tail_x15_r0_body.zpl79
  zplnd := PRE_first_tail_x15_r0_body.zplnd79
  zn1 := PRE_first_tail_x15_r0_body.zn179
  zfirst := PRE_first_tail_x15_r0_body.zfirst79
  zscn := PRE_first_tail_x15_r0_body.zscn79
  zsmn := PRE_first_tail_x15_r0_body.zsmn79
  zgrow := PRE_first_tail_x15_r0_body.zgrow79
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab79
  zfresh := PRE_first_tail_x15_r0_body.zfresh79
  zcnd := PRE_first_tail_x15_r0_body.zcnd79
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi79
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt79
  zgP := PRE_first_tail_x15_r0_body.zg79_2665
  zkP := PRE_first_tail_x15_r0_body.zk79_2665
  zmP := PRE_first_tail_x15_r0_body.zm79_2665
  zgC := PRE_first_tail_x15_r0_body.zg79_2673467
  zkC := PRE_first_tail_x15_r0_body.zk79_2673467
  zmC := PRE_first_tail_x15_r0_body.zm79_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw79_2673472
  zwV := PRE_first_tail_x15_r0_body.zw79_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap79
  zclbd := PRE_first_tail_x15_r0_body.zclbd79
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap79 PRE_first_tail_x15_r0_body.stFoot79 PRE_first_tail_x15_r0_body.iso79 PRE_first_tail_x15_r0_body.zwr79
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP79
  csupp := PRE_first_tail_x15_r0_body.csupp79
  cbound := PRE_first_tail_x15_r0_body.cbound79
  zimg := PRE_first_tail_x15_r0_body.zimg79
  zctl := PRE_first_tail_x15_r0_body.zctl79
  zstack := PRE_first_tail_x15_r0_body.zstack79
  zjobs := PRE_first_tail_x15_r0_body.zjobs79
  zstores := PRE_first_tail_x15_r0_body.zstores79
  zroots := PRE_first_tail_x15_r0_body.zroots79
  znC := PRE_first_tail_x15_r0_body.znC79
  ctab := PRE_first_tail_x15_r0_body.ctab79
  zbin := PRE_first_tail_x15_r0_body.zbin79
  cbridge := PRE_first_tail_x15_r0_body.cbridge79
  sbridge := bodyBridge79
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj79
  cshiftR := fun h hNL => bodyCshift79 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN79
  raised := PRE_first_tail_x15_r0_body.raised79
  cbigs := PRE_first_tail_x15_r0_body.cbigs79
  cjcl := PRE_first_tail_x15_r0_body.cjcl79
  xnLe := Nat.le_of_ble_eq_true bodyXn79
  loLe := Nat.le_of_ble_eq_true bodyLo79
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB79
  cntM := bodyCntM79
  hiLe := Nat.le_of_ble_eq_true bodyHi79
  nhiLe := Nat.le_of_ble_eq_true bodyNhi79
  jsHeap := bodyJs79
  jsRoots := bodyJsRoots79
  jsNative := bodyJsNative79
  framesEmpty := bodyFramesEmpty79
  trailOld := by decide
  lowVars := bodyLow79

def bodyQs79 : List (Option Q) := []
noncomputable def bodyEs79 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr79.map fun r => nth? PRE_first_tail_x15_r0_body.st79.S2.tab r
kernel_rfl bodyResChk79 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs79 bodyQs79) = true
kernel_rfl bodyLq79 : bodyQs79.length = PRE_first_tail_x15_r0_body.cws79.length
kernel_rfl bodyNrLo79 : PRE_first_tail_x15_r0_body.nr79.all (Nat.ble PRE_first_tail_x15_r0_body.S772.tab.length) = true
kernel_rfl bodySub79 : (Oracles.PRE_first_tail_x15_r0_body.map_site79.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost79 : postSubB bodyM PRE_first_tail_x15_r0_body.ws79 PRE_first_tail_x15_r0_body.cws79 bodyQs79 = true
kernel_rfl bodyDrop79 : Nat.ble (30718 + (PRE_first_tail_x15_r0_body.s773.next - PRE_first_tail_x15_r0_body.s774.next)) 30720 = true
kernel_rfl bodyDropH79 : Nat.ble (558 + ((mlxOf PRE_first_tail_x15_r0_body.s773.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s774.ffi).next)) 558 = true
kernel_rfl bodyDropN79 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s773.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s774.ffi).nnext)) 0 = true
kernel_rfl bodyDv79 : bodyΘ.1.take 432 = bodyΘ.1.take 432 ++ PRE_first_tail_x15_r0_body.cws79
kernel_rfl bodyDe79 : bodyΘ.2.take 432 = bodyΘ.2.take 432 ++ PRE_first_tail_x15_r0_body.nr79.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st79.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 432) (bodyΘ.2.take 432)))
kernel_rfl bodyDl79 : (bodyΘ.1.take 432).length = (bodyΘ.2.take 432).length
kernel_rfl bodyDold79 : (bodyΘ.1.take 432).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws79).isNone && !PRE_first_tail_x15_r0_body.ws79.contains v) = true
kernel_rfl bodyDfree79 : (bodyΘ.2.take 432).all (fun e => (PRE_first_tail_x15_r0_body.cws79 ++ PRE_first_tail_x15_r0_body.ws79).all fun w => e.noVar w) = true

theorem bodyStep79 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30718, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s772 PRE_first_tail_x15_r0_body.S772)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30720, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s774 PRE_first_tail_x15_r0_body.S774) (27 + 1) :=
  bodySite bodyFacts79.cfix bodyFacts79.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st79.S2.tab) (Es := bodyEs79) (qs := bodyQs79)
    (ok := PRE_first_tail_x15_r0_body.st79.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site79 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts79
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site79 r hr) hi (MapOk.sub hm (sub_of_all bodySub79)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk79 r hr) hi hm ho hq)
    bodyLq79 rfl bodyNrLo79 (postSub_sound bodyPost79)
    (Nat.le_of_ble_eq_true bodyDrop79) (by decide) (Nat.le_of_ble_eq_true bodyDropH79) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN79) (by decide)
    bodyDv79 bodyDe79 bodyDl79 bodyDold79 bodyDfree79 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
