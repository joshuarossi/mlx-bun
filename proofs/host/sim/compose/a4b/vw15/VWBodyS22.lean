import host.sim.compose.a4b.vw15.VWBodyJ22
import host.sim.compose.a4b.vw15.VWBodySite22
import host.sim.compose.a4b.vw15.VWBodyOracles_5
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift22 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S225.tab.length PRE_first_tail_x15_r0_body.s225.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P22.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P22 1019 PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.s227.ffi PRE_first_tail_x15_r0_body.s226.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_22
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_22
  have hcl : SSt (· < 1019) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s227.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S225.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_22] <;> decide) PRE_first_tail_x15_r0_body.cnodesK22 PRE_first_tail_x15_r0_body.cobjsK22
      PRE_first_tail_x15_r0_body.citemsK22 PRE_first_tail_x15_r0_body.cbd22 PRE_first_tail_x15_r0_body.csst22
  exact PRE_first_tail_x15_r0_body.cshift22 bodyNcl22 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_22] at this; exact this)


kernel_rfl bodyFramesEmpty22 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s226 a).isEmpty) = true
kernel_rfl bodyJsRoots22 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s225.next) PRE_first_tail_x15_r0_body.s227.trace PRE_first_tail_x15_r0_body.s227 = true
kernel_rfl bodyJsNative22 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s227.ffi) = true
kernel_rfl bodyLow22 : (PRE_first_tail_x15_r0_body.cws22 ++ PRE_first_tail_x15_r0_body.ws22).all (Nat.ble 9) = true
kernel_rfl bodyCntM22 : countersOkB PRE_first_tail_x15_r0_body.s225 PRE_first_tail_x15_r0_body.s226 = true
kernel_rfl bodyHi22 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s227.ffi).next setupP.E = true
kernel_rfl bodyNhi22 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s227.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge22 : bridgeOf PRE_first_tail_x15_r0_body.s226.ffi = bridgeOf PRE_first_tail_x15_r0_body.s225.ffi
kernel_rfl bodyNN22 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s225.ffi).nnext PRE_first_tail_x15_r0_body.P22.NL = true
kernel_rfl bodyXn22 : Nat.ble (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s227.ffi).next = true
kernel_rfl bodyLo22 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s227.ffi).next = true
theorem bodyFacts22 : BodySiteFacts PRE_first_tail_x15_r0_body.s225 PRE_first_tail_x15_r0_body.s226 PRE_first_tail_x15_r0_body.s227 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S225 PRE_first_tail_x15_r0_body.S226 PRE_first_tail_x15_r0_body.S227
    PRE_first_tail_x15_r0_body.ws22 PRE_first_tail_x15_r0_body.cws22 PRE_first_tail_x15_r0_body.nr22 PRE_first_tail_x15_r0_body.pl22 PRE_first_tail_x15_r0_body.cl22 2692507 1019 PRE_first_tail_x15_r0_body.kd22 PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.P22
    ⟨18646, 15729, 2692505, 1019⟩ ⟨18646, 15729, 2692505, 1019⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap22
  clean := bodyClean22
  cfix := PRE_first_tail_x15_r0_body.cfix22
  zpl := PRE_first_tail_x15_r0_body.zpl22
  zplnd := PRE_first_tail_x15_r0_body.zplnd22
  zn1 := PRE_first_tail_x15_r0_body.zn122
  zfirst := PRE_first_tail_x15_r0_body.zfirst22
  zscn := PRE_first_tail_x15_r0_body.zscn22
  zsmn := PRE_first_tail_x15_r0_body.zsmn22
  zgrow := PRE_first_tail_x15_r0_body.zgrow22
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab22
  zfresh := PRE_first_tail_x15_r0_body.zfresh22
  zcnd := PRE_first_tail_x15_r0_body.zcnd22
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi22
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt22
  zgP := PRE_first_tail_x15_r0_body.zg22_2665
  zkP := PRE_first_tail_x15_r0_body.zk22_2665
  zmP := PRE_first_tail_x15_r0_body.zm22_2665
  zgC := PRE_first_tail_x15_r0_body.zg22_2673467
  zkC := PRE_first_tail_x15_r0_body.zk22_2673467
  zmC := PRE_first_tail_x15_r0_body.zm22_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw22_2673472
  zwV := PRE_first_tail_x15_r0_body.zw22_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap22
  zclbd := PRE_first_tail_x15_r0_body.zclbd22
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap22 PRE_first_tail_x15_r0_body.stFoot22 PRE_first_tail_x15_r0_body.iso22 PRE_first_tail_x15_r0_body.zwr22
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP22
  csupp := PRE_first_tail_x15_r0_body.csupp22
  cbound := PRE_first_tail_x15_r0_body.cbound22
  zimg := PRE_first_tail_x15_r0_body.zimg22
  zctl := PRE_first_tail_x15_r0_body.zctl22
  zstack := PRE_first_tail_x15_r0_body.zstack22
  zjobs := PRE_first_tail_x15_r0_body.zjobs22
  zstores := PRE_first_tail_x15_r0_body.zstores22
  zroots := PRE_first_tail_x15_r0_body.zroots22
  znC := PRE_first_tail_x15_r0_body.znC22
  ctab := PRE_first_tail_x15_r0_body.ctab22
  zbin := PRE_first_tail_x15_r0_body.zbin22
  cbridge := PRE_first_tail_x15_r0_body.cbridge22
  sbridge := bodyBridge22
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj22
  cshiftR := fun h hNL => bodyCshift22 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN22
  raised := PRE_first_tail_x15_r0_body.raised22
  cbigs := PRE_first_tail_x15_r0_body.cbigs22
  cjcl := PRE_first_tail_x15_r0_body.cjcl22
  xnLe := Nat.le_of_ble_eq_true bodyXn22
  loLe := Nat.le_of_ble_eq_true bodyLo22
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB22
  cntM := bodyCntM22
  hiLe := Nat.le_of_ble_eq_true bodyHi22
  nhiLe := Nat.le_of_ble_eq_true bodyNhi22
  jsHeap := bodyJs22
  jsRoots := bodyJsRoots22
  jsNative := bodyJsNative22
  framesEmpty := bodyFramesEmpty22
  trailOld := by decide
  lowVars := bodyLow22

def bodyQs22 : List (Option Q) := []
noncomputable def bodyEs22 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr22.map fun r => nth? PRE_first_tail_x15_r0_body.st22.S2.tab r
kernel_rfl bodyResChk22 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs22 bodyQs22) = true
kernel_rfl bodyLq22 : bodyQs22.length = PRE_first_tail_x15_r0_body.cws22.length
kernel_rfl bodyNrLo22 : PRE_first_tail_x15_r0_body.nr22.all (Nat.ble PRE_first_tail_x15_r0_body.S225.tab.length) = true
kernel_rfl bodySub22 : (Oracles.PRE_first_tail_x15_r0_body.map_site22.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost22 : postSubB bodyM PRE_first_tail_x15_r0_body.ws22 PRE_first_tail_x15_r0_body.cws22 bodyQs22 = true
kernel_rfl bodyDrop22 : Nat.ble (11801 + (PRE_first_tail_x15_r0_body.s226.next - PRE_first_tail_x15_r0_body.s227.next)) 11803 = true
kernel_rfl bodyDropH22 : Nat.ble (175 + ((mlxOf PRE_first_tail_x15_r0_body.s226.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s227.ffi).next)) 175 = true
kernel_rfl bodyDropN22 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s226.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s227.ffi).nnext)) 0 = true
kernel_rfl bodyDv22 : bodyΘ.1.take 126 = bodyΘ.1.take 126 ++ PRE_first_tail_x15_r0_body.cws22
kernel_rfl bodyDe22 : bodyΘ.2.take 126 = bodyΘ.2.take 126 ++ PRE_first_tail_x15_r0_body.nr22.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st22.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 126) (bodyΘ.2.take 126)))
kernel_rfl bodyDl22 : (bodyΘ.1.take 126).length = (bodyΘ.2.take 126).length
kernel_rfl bodyDold22 : (bodyΘ.1.take 126).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws22).isNone && !PRE_first_tail_x15_r0_body.ws22.contains v) = true
kernel_rfl bodyDfree22 : (bodyΘ.2.take 126).all (fun e => (PRE_first_tail_x15_r0_body.cws22 ++ PRE_first_tail_x15_r0_body.ws22).all fun w => e.noVar w) = true

theorem bodyStep22 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11801, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s225 PRE_first_tail_x15_r0_body.S225)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11803, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s227 PRE_first_tail_x15_r0_body.S227) (27 + 1) :=
  bodySite bodyFacts22.cfix bodyFacts22.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st22.S2.tab) (Es := bodyEs22) (qs := bodyQs22)
    (ok := PRE_first_tail_x15_r0_body.st22.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site22 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts22
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site22 r hr) hi (MapOk.sub hm (sub_of_all bodySub22)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk22 r hr) hi hm ho hq)
    bodyLq22 rfl bodyNrLo22 (postSub_sound bodyPost22)
    (Nat.le_of_ble_eq_true bodyDrop22) (by decide) (Nat.le_of_ble_eq_true bodyDropH22) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN22) (by decide)
    bodyDv22 bodyDe22 bodyDl22 bodyDold22 bodyDfree22 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
