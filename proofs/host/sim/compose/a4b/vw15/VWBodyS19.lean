import host.sim.compose.a4b.vw15.VWBodyJ19
import host.sim.compose.a4b.vw15.VWBodySite19
import host.sim.compose.a4b.vw15.VWBodyOracles_4
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift19 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S197.tab.length PRE_first_tail_x15_r0_body.s197.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P19.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P19 893 PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.s199.ffi PRE_first_tail_x15_r0_body.s198.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_19
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_19
  have hcl : SSt (· < 893) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S197.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_19] <;> decide) PRE_first_tail_x15_r0_body.cnodesK19 PRE_first_tail_x15_r0_body.cobjsK19
      PRE_first_tail_x15_r0_body.citemsK19 PRE_first_tail_x15_r0_body.cbd19 PRE_first_tail_x15_r0_body.csst19
  exact PRE_first_tail_x15_r0_body.cshift19 bodyNcl19 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_19] at this; exact this)


kernel_rfl bodyFramesEmpty19 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s198 a).isEmpty) = true
kernel_rfl bodyJsRoots19 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s197.next) PRE_first_tail_x15_r0_body.s199.trace PRE_first_tail_x15_r0_body.s199 = true
kernel_rfl bodyJsNative19 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s199.ffi) = true
kernel_rfl bodyLow19 : (PRE_first_tail_x15_r0_body.cws19 ++ PRE_first_tail_x15_r0_body.ws19).all (Nat.ble 9) = true
kernel_rfl bodyCntM19 : countersOkB PRE_first_tail_x15_r0_body.s197 PRE_first_tail_x15_r0_body.s198 = true
kernel_rfl bodyHi19 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s199.ffi).next setupP.E = true
kernel_rfl bodyNhi19 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s199.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge19 : bridgeOf PRE_first_tail_x15_r0_body.s198.ffi = bridgeOf PRE_first_tail_x15_r0_body.s197.ffi
kernel_rfl bodyNN19 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s197.ffi).nnext PRE_first_tail_x15_r0_body.P19.NL = true
kernel_rfl bodyXn19 : Nat.ble (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s199.ffi).next = true
kernel_rfl bodyLo19 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s199.ffi).next = true
theorem bodyFacts19 : BodySiteFacts PRE_first_tail_x15_r0_body.s197 PRE_first_tail_x15_r0_body.s198 PRE_first_tail_x15_r0_body.s199 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S197 PRE_first_tail_x15_r0_body.S198 PRE_first_tail_x15_r0_body.S199
    PRE_first_tail_x15_r0_body.ws19 PRE_first_tail_x15_r0_body.cws19 PRE_first_tail_x15_r0_body.nr19 PRE_first_tail_x15_r0_body.pl19 PRE_first_tail_x15_r0_body.cl19 2689885 893 PRE_first_tail_x15_r0_body.kd19 PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.P19
    ⟨18582, 15681, 2689883, 893⟩ ⟨18582, 15681, 2689883, 893⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap19
  clean := bodyClean19
  cfix := PRE_first_tail_x15_r0_body.cfix19
  zpl := PRE_first_tail_x15_r0_body.zpl19
  zplnd := PRE_first_tail_x15_r0_body.zplnd19
  zn1 := PRE_first_tail_x15_r0_body.zn119
  zfirst := PRE_first_tail_x15_r0_body.zfirst19
  zscn := PRE_first_tail_x15_r0_body.zscn19
  zsmn := PRE_first_tail_x15_r0_body.zsmn19
  zgrow := PRE_first_tail_x15_r0_body.zgrow19
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab19
  zfresh := PRE_first_tail_x15_r0_body.zfresh19
  zcnd := PRE_first_tail_x15_r0_body.zcnd19
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi19
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt19
  zgP := PRE_first_tail_x15_r0_body.zg19_2665
  zkP := PRE_first_tail_x15_r0_body.zk19_2665
  zmP := PRE_first_tail_x15_r0_body.zm19_2665
  zgC := PRE_first_tail_x15_r0_body.zg19_2673467
  zkC := PRE_first_tail_x15_r0_body.zk19_2673467
  zmC := PRE_first_tail_x15_r0_body.zm19_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw19_2673472
  zwV := PRE_first_tail_x15_r0_body.zw19_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap19
  zclbd := PRE_first_tail_x15_r0_body.zclbd19
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap19 PRE_first_tail_x15_r0_body.stFoot19 PRE_first_tail_x15_r0_body.iso19 PRE_first_tail_x15_r0_body.zwr19
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP19
  csupp := PRE_first_tail_x15_r0_body.csupp19
  cbound := PRE_first_tail_x15_r0_body.cbound19
  zimg := PRE_first_tail_x15_r0_body.zimg19
  zctl := PRE_first_tail_x15_r0_body.zctl19
  zstack := PRE_first_tail_x15_r0_body.zstack19
  zjobs := PRE_first_tail_x15_r0_body.zjobs19
  zstores := PRE_first_tail_x15_r0_body.zstores19
  zroots := PRE_first_tail_x15_r0_body.zroots19
  znC := PRE_first_tail_x15_r0_body.znC19
  ctab := PRE_first_tail_x15_r0_body.ctab19
  zbin := PRE_first_tail_x15_r0_body.zbin19
  cbridge := PRE_first_tail_x15_r0_body.cbridge19
  sbridge := bodyBridge19
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj19
  cshiftR := fun h hNL => bodyCshift19 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN19
  raised := PRE_first_tail_x15_r0_body.raised19
  cbigs := PRE_first_tail_x15_r0_body.cbigs19
  cjcl := PRE_first_tail_x15_r0_body.cjcl19
  xnLe := Nat.le_of_ble_eq_true bodyXn19
  loLe := Nat.le_of_ble_eq_true bodyLo19
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB19
  cntM := bodyCntM19
  hiLe := Nat.le_of_ble_eq_true bodyHi19
  nhiLe := Nat.le_of_ble_eq_true bodyNhi19
  jsHeap := bodyJs19
  jsRoots := bodyJsRoots19
  jsNative := bodyJsNative19
  framesEmpty := bodyFramesEmpty19
  trailOld := by decide
  lowVars := bodyLow19

def bodyQs19 : List (Option Q) := []
noncomputable def bodyEs19 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr19.map fun r => nth? PRE_first_tail_x15_r0_body.st19.S2.tab r
kernel_rfl bodyResChk19 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs19 bodyQs19) = true
kernel_rfl bodyLq19 : bodyQs19.length = PRE_first_tail_x15_r0_body.cws19.length
kernel_rfl bodyNrLo19 : PRE_first_tail_x15_r0_body.nr19.all (Nat.ble PRE_first_tail_x15_r0_body.S197.tab.length) = true
kernel_rfl bodySub19 : (Oracles.PRE_first_tail_x15_r0_body.map_site19.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost19 : postSubB bodyM PRE_first_tail_x15_r0_body.ws19 PRE_first_tail_x15_r0_body.cws19 bodyQs19 = true
kernel_rfl bodyDrop19 : Nat.ble (11439 + (PRE_first_tail_x15_r0_body.s198.next - PRE_first_tail_x15_r0_body.s199.next)) 11441 = true
kernel_rfl bodyDropH19 : Nat.ble (173 + ((mlxOf PRE_first_tail_x15_r0_body.s198.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s199.ffi).next)) 173 = true
kernel_rfl bodyDropN19 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s198.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s199.ffi).nnext)) 0 = true
kernel_rfl bodyDv19 : bodyΘ.1.take 117 = bodyΘ.1.take 117 ++ PRE_first_tail_x15_r0_body.cws19
kernel_rfl bodyDe19 : bodyΘ.2.take 117 = bodyΘ.2.take 117 ++ PRE_first_tail_x15_r0_body.nr19.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st19.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 117) (bodyΘ.2.take 117)))
kernel_rfl bodyDl19 : (bodyΘ.1.take 117).length = (bodyΘ.2.take 117).length
kernel_rfl bodyDold19 : (bodyΘ.1.take 117).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws19).isNone && !PRE_first_tail_x15_r0_body.ws19.contains v) = true
kernel_rfl bodyDfree19 : (bodyΘ.2.take 117).all (fun e => (PRE_first_tail_x15_r0_body.cws19 ++ PRE_first_tail_x15_r0_body.ws19).all fun w => e.noVar w) = true

theorem bodyStep19 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11439, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s197 PRE_first_tail_x15_r0_body.S197)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11441, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s199 PRE_first_tail_x15_r0_body.S199) (27 + 1) :=
  bodySite bodyFacts19.cfix bodyFacts19.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st19.S2.tab) (Es := bodyEs19) (qs := bodyQs19)
    (ok := PRE_first_tail_x15_r0_body.st19.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site19 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts19
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site19 r hr) hi (MapOk.sub hm (sub_of_all bodySub19)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk19 r hr) hi hm ho hq)
    bodyLq19 rfl bodyNrLo19 (postSub_sound bodyPost19)
    (Nat.le_of_ble_eq_true bodyDrop19) (by decide) (Nat.le_of_ble_eq_true bodyDropH19) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN19) (by decide)
    bodyDv19 bodyDe19 bodyDl19 bodyDold19 bodyDfree19 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
