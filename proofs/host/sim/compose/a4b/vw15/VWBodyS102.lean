import host.sim.compose.a4b.vw15.VWBodyJ102
import host.sim.compose.a4b.vw15.VWBodySite102
import host.sim.compose.a4b.vw15.VWBodyOracles_25
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift102 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S994.tab.length PRE_first_tail_x15_r0_body.s994.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P102.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P102 4463 PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.s996.ffi PRE_first_tail_x15_r0_body.s995.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_102
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_102
  have hcl : SSt (· < 4463) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S994.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_102] <;> decide) PRE_first_tail_x15_r0_body.cnodesK102 PRE_first_tail_x15_r0_body.cobjsK102
      PRE_first_tail_x15_r0_body.citemsK102 PRE_first_tail_x15_r0_body.cbd102 PRE_first_tail_x15_r0_body.csst102
  exact PRE_first_tail_x15_r0_body.cshift102 bodyNcl102 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_102] at this; exact this)


kernel_rfl bodyFramesEmpty102 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s995 a).isEmpty) = true
kernel_rfl bodyJsRoots102 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s994.next) PRE_first_tail_x15_r0_body.s996.trace PRE_first_tail_x15_r0_body.s996 = true
kernel_rfl bodyJsNative102 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s996.ffi) = true
kernel_rfl bodyLow102 : (PRE_first_tail_x15_r0_body.cws102 ++ PRE_first_tail_x15_r0_body.ws102).all (Nat.ble 9) = true
kernel_rfl bodyCntM102 : countersOkB PRE_first_tail_x15_r0_body.s994 PRE_first_tail_x15_r0_body.s995 = true
kernel_rfl bodyHi102 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s996.ffi).next setupP.E = true
kernel_rfl bodyNhi102 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s996.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge102 : bridgeOf PRE_first_tail_x15_r0_body.s995.ffi = bridgeOf PRE_first_tail_x15_r0_body.s994.ffi
kernel_rfl bodyNN102 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s994.ffi).nnext PRE_first_tail_x15_r0_body.P102.NL = true
kernel_rfl bodyXn102 : Nat.ble (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s996.ffi).next = true
kernel_rfl bodyLo102 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s996.ffi).next = true
theorem bodyFacts102 : BodySiteFacts PRE_first_tail_x15_r0_body.s994 PRE_first_tail_x15_r0_body.s995 PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S994 PRE_first_tail_x15_r0_body.S995 PRE_first_tail_x15_r0_body.S996
    PRE_first_tail_x15_r0_body.ws102 PRE_first_tail_x15_r0_body.cws102 PRE_first_tail_x15_r0_body.nr102 PRE_first_tail_x15_r0_body.pl102 PRE_first_tail_x15_r0_body.cl102 2756466 4463 PRE_first_tail_x15_r0_body.kd102 PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.P102
    ⟨20218, 17300, 2755311, 4445⟩ ⟨20221, 17327, 2755317, 4463⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap102
  clean := bodyClean102
  cfix := PRE_first_tail_x15_r0_body.cfix102
  zpl := PRE_first_tail_x15_r0_body.zpl102
  zplnd := PRE_first_tail_x15_r0_body.zplnd102
  zn1 := PRE_first_tail_x15_r0_body.zn1102
  zfirst := PRE_first_tail_x15_r0_body.zfirst102
  zscn := PRE_first_tail_x15_r0_body.zscn102
  zsmn := PRE_first_tail_x15_r0_body.zsmn102
  zgrow := PRE_first_tail_x15_r0_body.zgrow102
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab102
  zfresh := PRE_first_tail_x15_r0_body.zfresh102
  zcnd := PRE_first_tail_x15_r0_body.zcnd102
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi102
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt102
  zgP := PRE_first_tail_x15_r0_body.zg102_2665
  zkP := PRE_first_tail_x15_r0_body.zk102_2665
  zmP := PRE_first_tail_x15_r0_body.zm102_2665
  zgC := PRE_first_tail_x15_r0_body.zg102_2673467
  zkC := PRE_first_tail_x15_r0_body.zk102_2673467
  zmC := PRE_first_tail_x15_r0_body.zm102_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw102_2673472
  zwV := PRE_first_tail_x15_r0_body.zw102_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap102
  zclbd := PRE_first_tail_x15_r0_body.zclbd102
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap102 PRE_first_tail_x15_r0_body.stFoot102 PRE_first_tail_x15_r0_body.iso102 PRE_first_tail_x15_r0_body.zwr102
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP102
  csupp := PRE_first_tail_x15_r0_body.csupp102
  cbound := PRE_first_tail_x15_r0_body.cbound102
  zimg := PRE_first_tail_x15_r0_body.zimg102
  zctl := PRE_first_tail_x15_r0_body.zctl102
  zstack := PRE_first_tail_x15_r0_body.zstack102
  zjobs := PRE_first_tail_x15_r0_body.zjobs102
  zstores := PRE_first_tail_x15_r0_body.zstores102
  zroots := PRE_first_tail_x15_r0_body.zroots102
  znC := PRE_first_tail_x15_r0_body.znC102
  ctab := PRE_first_tail_x15_r0_body.ctab102
  zbin := PRE_first_tail_x15_r0_body.zbin102
  cbridge := PRE_first_tail_x15_r0_body.cbridge102
  sbridge := bodyBridge102
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj102
  cshiftR := fun h hNL => bodyCshift102 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN102
  raised := PRE_first_tail_x15_r0_body.raised102
  cbigs := PRE_first_tail_x15_r0_body.cbigs102
  cjcl := PRE_first_tail_x15_r0_body.cjcl102
  xnLe := Nat.le_of_ble_eq_true bodyXn102
  loLe := Nat.le_of_ble_eq_true bodyLo102
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB102
  cntM := bodyCntM102
  hiLe := Nat.le_of_ble_eq_true bodyHi102
  nhiLe := Nat.le_of_ble_eq_true bodyNhi102
  jsHeap := bodyJs102
  jsRoots := bodyJsRoots102
  jsNative := bodyJsNative102
  framesEmpty := bodyFramesEmpty102
  trailOld := by decide
  lowVars := bodyLow102

def bodyQs102 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs102 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr102.map fun r => nth? PRE_first_tail_x15_r0_body.st102.S5.tab r
kernel_rfl bodyResChk102 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs102 bodyQs102) = true
kernel_rfl bodyLq102 : bodyQs102.length = PRE_first_tail_x15_r0_body.cws102.length
kernel_rfl bodyNrLo102 : PRE_first_tail_x15_r0_body.nr102.all (Nat.ble PRE_first_tail_x15_r0_body.S994.tab.length) = true
kernel_rfl bodySub102 : (Oracles.PRE_first_tail_x15_r0_body.map_site102.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost102 : postSubB bodyM PRE_first_tail_x15_r0_body.ws102 PRE_first_tail_x15_r0_body.cws102 bodyQs102 = true
kernel_rfl bodyDrop102 : Nat.ble (37295 + (PRE_first_tail_x15_r0_body.s995.next - PRE_first_tail_x15_r0_body.s996.next)) 38444 = true
kernel_rfl bodyDropH102 : Nat.ble (687 + ((mlxOf PRE_first_tail_x15_r0_body.s995.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s996.ffi).next)) 712 = true
kernel_rfl bodyDropN102 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s995.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s996.ffi).nnext)) 0 = true
kernel_rfl bodyDv102 : bodyΘ.1.take 558 = bodyΘ.1.take 540 ++ PRE_first_tail_x15_r0_body.cws102
kernel_rfl bodyDe102 : bodyΘ.2.take 558 = bodyΘ.2.take 540 ++ PRE_first_tail_x15_r0_body.nr102.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st102.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 540) (bodyΘ.2.take 540)))
kernel_rfl bodyDl102 : (bodyΘ.1.take 540).length = (bodyΘ.2.take 540).length
kernel_rfl bodyDold102 : (bodyΘ.1.take 540).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws102).isNone && !PRE_first_tail_x15_r0_body.ws102.contains v) = true
kernel_rfl bodyDfree102 : (bodyΘ.2.take 558).all (fun e => (PRE_first_tail_x15_r0_body.cws102 ++ PRE_first_tail_x15_r0_body.ws102).all fun w => e.noVar w) = true

theorem bodyStep102 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨37295, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s994 PRE_first_tail_x15_r0_body.S994)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38444, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.S996) (11334 + 1) :=
  bodySite bodyFacts102.cfix bodyFacts102.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st102.S5.tab) (Es := bodyEs102) (qs := bodyQs102)
    (ok := PRE_first_tail_x15_r0_body.st102.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site102 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts102
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site102 r hr) hi (MapOk.sub hm (sub_of_all bodySub102)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk102 r hr) hi hm ho hq)
    bodyLq102 rfl bodyNrLo102 (postSub_sound bodyPost102)
    (Nat.le_of_ble_eq_true bodyDrop102) (by decide) (Nat.le_of_ble_eq_true bodyDropH102) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN102) (by decide)
    bodyDv102 bodyDe102 bodyDl102 bodyDold102 bodyDfree102 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
