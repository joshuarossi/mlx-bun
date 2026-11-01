import host.sim.compose.a4b.vw15.VWBodyJ91
import host.sim.compose.a4b.vw15.VWBodySite91
import host.sim.compose.a4b.vw15.VWBodyOracles_22
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift91 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S887.tab.length PRE_first_tail_x15_r0_body.s887.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P91.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P91 3971 PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.s889.ffi PRE_first_tail_x15_r0_body.s888.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_91
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_91
  have hcl : SSt (· < 3971) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s889.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S887.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_91] <;> decide) PRE_first_tail_x15_r0_body.cnodesK91 PRE_first_tail_x15_r0_body.cobjsK91
      PRE_first_tail_x15_r0_body.citemsK91 PRE_first_tail_x15_r0_body.cbd91 PRE_first_tail_x15_r0_body.csst91
  exact PRE_first_tail_x15_r0_body.cshift91 bodyNcl91 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_91] at this; exact this)


kernel_rfl bodyFramesEmpty91 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s888 a).isEmpty) = true
kernel_rfl bodyJsRoots91 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s887.next) PRE_first_tail_x15_r0_body.s889.trace PRE_first_tail_x15_r0_body.s889 = true
kernel_rfl bodyJsNative91 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s889.ffi) = true
kernel_rfl bodyLow91 : (PRE_first_tail_x15_r0_body.cws91 ++ PRE_first_tail_x15_r0_body.ws91).all (Nat.ble 9) = true
kernel_rfl bodyCntM91 : countersOkB PRE_first_tail_x15_r0_body.s887 PRE_first_tail_x15_r0_body.s888 = true
kernel_rfl bodyHi91 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s889.ffi).next setupP.E = true
kernel_rfl bodyNhi91 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s889.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge91 : bridgeOf PRE_first_tail_x15_r0_body.s888.ffi = bridgeOf PRE_first_tail_x15_r0_body.s887.ffi
kernel_rfl bodyNN91 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s887.ffi).nnext PRE_first_tail_x15_r0_body.P91.NL = true
kernel_rfl bodyXn91 : Nat.ble (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s889.ffi).next = true
kernel_rfl bodyLo91 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s889.ffi).next = true
theorem bodyFacts91 : BodySiteFacts PRE_first_tail_x15_r0_body.s887 PRE_first_tail_x15_r0_body.s888 PRE_first_tail_x15_r0_body.s889 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S887 PRE_first_tail_x15_r0_body.S888 PRE_first_tail_x15_r0_body.S889
    PRE_first_tail_x15_r0_body.ws91 PRE_first_tail_x15_r0_body.cws91 PRE_first_tail_x15_r0_body.nr91 PRE_first_tail_x15_r0_body.pl91 PRE_first_tail_x15_r0_body.cl91 2746385 3971 PRE_first_tail_x15_r0_body.kd91 PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.P91
    ⟨19998, 17103, 2746383, 3971⟩ ⟨19998, 17103, 2746383, 3971⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap91
  clean := bodyClean91
  cfix := PRE_first_tail_x15_r0_body.cfix91
  zpl := PRE_first_tail_x15_r0_body.zpl91
  zplnd := PRE_first_tail_x15_r0_body.zplnd91
  zn1 := PRE_first_tail_x15_r0_body.zn191
  zfirst := PRE_first_tail_x15_r0_body.zfirst91
  zscn := PRE_first_tail_x15_r0_body.zscn91
  zsmn := PRE_first_tail_x15_r0_body.zsmn91
  zgrow := PRE_first_tail_x15_r0_body.zgrow91
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab91
  zfresh := PRE_first_tail_x15_r0_body.zfresh91
  zcnd := PRE_first_tail_x15_r0_body.zcnd91
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi91
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt91
  zgP := PRE_first_tail_x15_r0_body.zg91_2665
  zkP := PRE_first_tail_x15_r0_body.zk91_2665
  zmP := PRE_first_tail_x15_r0_body.zm91_2665
  zgC := PRE_first_tail_x15_r0_body.zg91_2673467
  zkC := PRE_first_tail_x15_r0_body.zk91_2673467
  zmC := PRE_first_tail_x15_r0_body.zm91_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw91_2673472
  zwV := PRE_first_tail_x15_r0_body.zw91_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap91
  zclbd := PRE_first_tail_x15_r0_body.zclbd91
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap91 PRE_first_tail_x15_r0_body.stFoot91 PRE_first_tail_x15_r0_body.iso91 PRE_first_tail_x15_r0_body.zwr91
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP91
  csupp := PRE_first_tail_x15_r0_body.csupp91
  cbound := PRE_first_tail_x15_r0_body.cbound91
  zimg := PRE_first_tail_x15_r0_body.zimg91
  zctl := PRE_first_tail_x15_r0_body.zctl91
  zstack := PRE_first_tail_x15_r0_body.zstack91
  zjobs := PRE_first_tail_x15_r0_body.zjobs91
  zstores := PRE_first_tail_x15_r0_body.zstores91
  zroots := PRE_first_tail_x15_r0_body.zroots91
  znC := PRE_first_tail_x15_r0_body.znC91
  ctab := PRE_first_tail_x15_r0_body.ctab91
  zbin := PRE_first_tail_x15_r0_body.zbin91
  cbridge := PRE_first_tail_x15_r0_body.cbridge91
  sbridge := bodyBridge91
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj91
  cshiftR := fun h hNL => bodyCshift91 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN91
  raised := PRE_first_tail_x15_r0_body.raised91
  cbigs := PRE_first_tail_x15_r0_body.cbigs91
  cjcl := PRE_first_tail_x15_r0_body.cjcl91
  xnLe := Nat.le_of_ble_eq_true bodyXn91
  loLe := Nat.le_of_ble_eq_true bodyLo91
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB91
  cntM := bodyCntM91
  hiLe := Nat.le_of_ble_eq_true bodyHi91
  nhiLe := Nat.le_of_ble_eq_true bodyNhi91
  jsHeap := bodyJs91
  jsRoots := bodyJsRoots91
  jsNative := bodyJsNative91
  framesEmpty := bodyFramesEmpty91
  trailOld := by decide
  lowVars := bodyLow91

def bodyQs91 : List (Option Q) := []
noncomputable def bodyEs91 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr91.map fun r => nth? PRE_first_tail_x15_r0_body.st91.S2.tab r
kernel_rfl bodyResChk91 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs91 bodyQs91) = true
kernel_rfl bodyLq91 : bodyQs91.length = PRE_first_tail_x15_r0_body.cws91.length
kernel_rfl bodyNrLo91 : PRE_first_tail_x15_r0_body.nr91.all (Nat.ble PRE_first_tail_x15_r0_body.S887.tab.length) = true
kernel_rfl bodySub91 : (Oracles.PRE_first_tail_x15_r0_body.map_site91.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost91 : postSubB bodyM PRE_first_tail_x15_r0_body.ws91 PRE_first_tail_x15_r0_body.cws91 bodyQs91 = true
kernel_rfl bodyDrop91 : Nat.ble (34572 + (PRE_first_tail_x15_r0_body.s888.next - PRE_first_tail_x15_r0_body.s889.next)) 34574 = true
kernel_rfl bodyDropH91 : Nat.ble (635 + ((mlxOf PRE_first_tail_x15_r0_body.s888.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s889.ffi).next)) 635 = true
kernel_rfl bodyDropN91 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s888.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s889.ffi).nnext)) 0 = true
kernel_rfl bodyDv91 : bodyΘ.1.take 495 = bodyΘ.1.take 495 ++ PRE_first_tail_x15_r0_body.cws91
kernel_rfl bodyDe91 : bodyΘ.2.take 495 = bodyΘ.2.take 495 ++ PRE_first_tail_x15_r0_body.nr91.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st91.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 495) (bodyΘ.2.take 495)))
kernel_rfl bodyDl91 : (bodyΘ.1.take 495).length = (bodyΘ.2.take 495).length
kernel_rfl bodyDold91 : (bodyΘ.1.take 495).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws91).isNone && !PRE_first_tail_x15_r0_body.ws91.contains v) = true
kernel_rfl bodyDfree91 : (bodyΘ.2.take 495).all (fun e => (PRE_first_tail_x15_r0_body.cws91 ++ PRE_first_tail_x15_r0_body.ws91).all fun w => e.noVar w) = true

theorem bodyStep91 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34572, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s887 PRE_first_tail_x15_r0_body.S887)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34574, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s889 PRE_first_tail_x15_r0_body.S889) (27 + 1) :=
  bodySite bodyFacts91.cfix bodyFacts91.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st91.S2.tab) (Es := bodyEs91) (qs := bodyQs91)
    (ok := PRE_first_tail_x15_r0_body.st91.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site91 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts91
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site91 r hr) hi (MapOk.sub hm (sub_of_all bodySub91)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk91 r hr) hi hm ho hq)
    bodyLq91 rfl bodyNrLo91 (postSub_sound bodyPost91)
    (Nat.le_of_ble_eq_true bodyDrop91) (by decide) (Nat.le_of_ble_eq_true bodyDropH91) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN91) (by decide)
    bodyDv91 bodyDe91 bodyDl91 bodyDold91 bodyDfree91 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
