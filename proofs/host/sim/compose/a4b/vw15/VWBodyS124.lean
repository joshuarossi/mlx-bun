import host.sim.compose.a4b.vw15.VWBodyJ124
import host.sim.compose.a4b.vw15.VWBodySite124
import host.sim.compose.a4b.vw15.VWBodyOracles_31
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift124 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1203.tab.length PRE_first_tail_x15_r0_body.s1203.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P124.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P124 5381 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.s1205.ffi PRE_first_tail_x15_r0_body.s1204.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_124
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_124
  have hcl : SSt (· < 5381) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1203.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_124] <;> decide) PRE_first_tail_x15_r0_body.cnodesK124 PRE_first_tail_x15_r0_body.cobjsK124
      PRE_first_tail_x15_r0_body.citemsK124 PRE_first_tail_x15_r0_body.cbd124 PRE_first_tail_x15_r0_body.csst124
  exact PRE_first_tail_x15_r0_body.cshift124 bodyNcl124 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_124] at this; exact this)


kernel_rfl bodyFramesEmpty124 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1204 a).isEmpty) = true
kernel_rfl bodyJsRoots124 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1203.next) PRE_first_tail_x15_r0_body.s1205.trace PRE_first_tail_x15_r0_body.s1205 = true
kernel_rfl bodyJsNative124 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1205.ffi) = true
kernel_rfl bodyLow124 : (PRE_first_tail_x15_r0_body.cws124 ++ PRE_first_tail_x15_r0_body.ws124).all (Nat.ble 9) = true
kernel_rfl bodyCntM124 : countersOkB PRE_first_tail_x15_r0_body.s1203 PRE_first_tail_x15_r0_body.s1204 = true
kernel_rfl bodyHi124 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1205.ffi).next setupP.E = true
kernel_rfl bodyNhi124 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1205.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge124 : bridgeOf PRE_first_tail_x15_r0_body.s1204.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1203.ffi
kernel_rfl bodyNN124 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1203.ffi).nnext PRE_first_tail_x15_r0_body.P124.NL = true
kernel_rfl bodyXn124 : Nat.ble (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1205.ffi).next = true
kernel_rfl bodyLo124 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1205.ffi).next = true
theorem bodyFacts124 : BodySiteFacts PRE_first_tail_x15_r0_body.s1203 PRE_first_tail_x15_r0_body.s1204 PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1203 PRE_first_tail_x15_r0_body.S1204 PRE_first_tail_x15_r0_body.S1205
    PRE_first_tail_x15_r0_body.ws124 PRE_first_tail_x15_r0_body.cws124 PRE_first_tail_x15_r0_body.nr124 PRE_first_tail_x15_r0_body.pl124 PRE_first_tail_x15_r0_body.cl124 2772377 5381 PRE_first_tail_x15_r0_body.kd124 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.P124
    ⟨20649, 17751, 2772375, 5381⟩ ⟨20649, 17751, 2772375, 5381⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap124
  clean := bodyClean124
  cfix := PRE_first_tail_x15_r0_body.cfix124
  zpl := PRE_first_tail_x15_r0_body.zpl124
  zplnd := PRE_first_tail_x15_r0_body.zplnd124
  zn1 := PRE_first_tail_x15_r0_body.zn1124
  zfirst := PRE_first_tail_x15_r0_body.zfirst124
  zscn := PRE_first_tail_x15_r0_body.zscn124
  zsmn := PRE_first_tail_x15_r0_body.zsmn124
  zgrow := PRE_first_tail_x15_r0_body.zgrow124
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab124
  zfresh := PRE_first_tail_x15_r0_body.zfresh124
  zcnd := PRE_first_tail_x15_r0_body.zcnd124
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi124
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt124
  zgP := PRE_first_tail_x15_r0_body.zg124_2665
  zkP := PRE_first_tail_x15_r0_body.zk124_2665
  zmP := PRE_first_tail_x15_r0_body.zm124_2665
  zgC := PRE_first_tail_x15_r0_body.zg124_2673467
  zkC := PRE_first_tail_x15_r0_body.zk124_2673467
  zmC := PRE_first_tail_x15_r0_body.zm124_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw124_2673472
  zwV := PRE_first_tail_x15_r0_body.zw124_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap124
  zclbd := PRE_first_tail_x15_r0_body.zclbd124
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap124 PRE_first_tail_x15_r0_body.stFoot124 PRE_first_tail_x15_r0_body.iso124 PRE_first_tail_x15_r0_body.zwr124
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP124
  csupp := PRE_first_tail_x15_r0_body.csupp124
  cbound := PRE_first_tail_x15_r0_body.cbound124
  zimg := PRE_first_tail_x15_r0_body.zimg124
  zctl := PRE_first_tail_x15_r0_body.zctl124
  zstack := PRE_first_tail_x15_r0_body.zstack124
  zjobs := PRE_first_tail_x15_r0_body.zjobs124
  zstores := PRE_first_tail_x15_r0_body.zstores124
  zroots := PRE_first_tail_x15_r0_body.zroots124
  znC := PRE_first_tail_x15_r0_body.znC124
  ctab := PRE_first_tail_x15_r0_body.ctab124
  zbin := PRE_first_tail_x15_r0_body.zbin124
  cbridge := PRE_first_tail_x15_r0_body.cbridge124
  sbridge := bodyBridge124
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj124
  cshiftR := fun h hNL => bodyCshift124 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN124
  raised := PRE_first_tail_x15_r0_body.raised124
  cbigs := PRE_first_tail_x15_r0_body.cbigs124
  cjcl := PRE_first_tail_x15_r0_body.cjcl124
  xnLe := Nat.le_of_ble_eq_true bodyXn124
  loLe := Nat.le_of_ble_eq_true bodyLo124
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB124
  cntM := bodyCntM124
  hiLe := Nat.le_of_ble_eq_true bodyHi124
  nhiLe := Nat.le_of_ble_eq_true bodyNhi124
  jsHeap := bodyJs124
  jsRoots := bodyJsRoots124
  jsNative := bodyJsNative124
  framesEmpty := bodyFramesEmpty124
  trailOld := by decide
  lowVars := bodyLow124

def bodyQs124 : List (Option Q) := []
noncomputable def bodyEs124 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr124.map fun r => nth? PRE_first_tail_x15_r0_body.st124.S2.tab r
kernel_rfl bodyResChk124 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs124 bodyQs124) = true
kernel_rfl bodyLq124 : bodyQs124.length = PRE_first_tail_x15_r0_body.cws124.length
kernel_rfl bodyNrLo124 : PRE_first_tail_x15_r0_body.nr124.all (Nat.ble PRE_first_tail_x15_r0_body.S1203.tab.length) = true
kernel_rfl bodySub124 : (Oracles.PRE_first_tail_x15_r0_body.map_site124.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost124 : postSubB bodyM PRE_first_tail_x15_r0_body.ws124 PRE_first_tail_x15_r0_body.cws124 bodyQs124 = true
kernel_rfl bodyDrop124 : Nat.ble (44973 + (PRE_first_tail_x15_r0_body.s1204.next - PRE_first_tail_x15_r0_body.s1205.next)) 44975 = true
kernel_rfl bodyDropH124 : Nat.ble (841 + ((mlxOf PRE_first_tail_x15_r0_body.s1204.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1205.ffi).next)) 841 = true
kernel_rfl bodyDropN124 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1204.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1205.ffi).nnext)) 0 = true
kernel_rfl bodyDv124 : bodyΘ.1.take 666 = bodyΘ.1.take 666 ++ PRE_first_tail_x15_r0_body.cws124
kernel_rfl bodyDe124 : bodyΘ.2.take 666 = bodyΘ.2.take 666 ++ PRE_first_tail_x15_r0_body.nr124.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st124.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 666) (bodyΘ.2.take 666)))
kernel_rfl bodyDl124 : (bodyΘ.1.take 666).length = (bodyΘ.2.take 666).length
kernel_rfl bodyDold124 : (bodyΘ.1.take 666).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws124).isNone && !PRE_first_tail_x15_r0_body.ws124.contains v) = true
kernel_rfl bodyDfree124 : (bodyΘ.2.take 666).all (fun e => (PRE_first_tail_x15_r0_body.cws124 ++ PRE_first_tail_x15_r0_body.ws124).all fun w => e.noVar w) = true

theorem bodyStep124 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨44973, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1203 PRE_first_tail_x15_r0_body.S1203)
      (bodyCut NB T tk π i x0 bodyΘ ⟨44975, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.S1205) (27 + 1) :=
  bodySite bodyFacts124.cfix bodyFacts124.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st124.S2.tab) (Es := bodyEs124) (qs := bodyQs124)
    (ok := PRE_first_tail_x15_r0_body.st124.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site124 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts124
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site124 r hr) hi (MapOk.sub hm (sub_of_all bodySub124)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk124 r hr) hi hm ho hq)
    bodyLq124 rfl bodyNrLo124 (postSub_sound bodyPost124)
    (Nat.le_of_ble_eq_true bodyDrop124) (by decide) (Nat.le_of_ble_eq_true bodyDropH124) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN124) (by decide)
    bodyDv124 bodyDe124 bodyDl124 bodyDold124 bodyDfree124 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
