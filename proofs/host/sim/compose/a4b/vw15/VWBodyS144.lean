import host.sim.compose.a4b.vw15.VWBodyJ144
import host.sim.compose.a4b.vw15.VWBodySite144
import host.sim.compose.a4b.vw15.VWBodyOracles_36
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift144 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1396.tab.length PRE_first_tail_x15_r0_body.s1396.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P144.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P144 6257 PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.s1398.ffi PRE_first_tail_x15_r0_body.s1397.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_144
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_144
  have hcl : SSt (· < 6257) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1396.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_144] <;> decide) PRE_first_tail_x15_r0_body.cnodesK144 PRE_first_tail_x15_r0_body.cobjsK144
      PRE_first_tail_x15_r0_body.citemsK144 PRE_first_tail_x15_r0_body.cbd144 PRE_first_tail_x15_r0_body.csst144
  exact PRE_first_tail_x15_r0_body.cshift144 bodyNcl144 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_144] at this; exact this)


kernel_rfl bodyFramesEmpty144 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1397 a).isEmpty) = true
kernel_rfl bodyJsRoots144 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1396.next) PRE_first_tail_x15_r0_body.s1398.trace PRE_first_tail_x15_r0_body.s1398 = true
kernel_rfl bodyJsNative144 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1398.ffi) = true
kernel_rfl bodyLow144 : (PRE_first_tail_x15_r0_body.cws144 ++ PRE_first_tail_x15_r0_body.ws144).all (Nat.ble 9) = true
kernel_rfl bodyCntM144 : countersOkB PRE_first_tail_x15_r0_body.s1396 PRE_first_tail_x15_r0_body.s1397 = true
kernel_rfl bodyHi144 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1398.ffi).next setupP.E = true
kernel_rfl bodyNhi144 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1398.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge144 : bridgeOf PRE_first_tail_x15_r0_body.s1397.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1396.ffi
kernel_rfl bodyNN144 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1396.ffi).nnext PRE_first_tail_x15_r0_body.P144.NL = true
kernel_rfl bodyXn144 : Nat.ble (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1398.ffi).next = true
kernel_rfl bodyLo144 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1398.ffi).next = true
theorem bodyFacts144 : BodySiteFacts PRE_first_tail_x15_r0_body.s1396 PRE_first_tail_x15_r0_body.s1397 PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1396 PRE_first_tail_x15_r0_body.S1397 PRE_first_tail_x15_r0_body.S1398
    PRE_first_tail_x15_r0_body.ws144 PRE_first_tail_x15_r0_body.cws144 PRE_first_tail_x15_r0_body.nr144 PRE_first_tail_x15_r0_body.pl144 PRE_first_tail_x15_r0_body.cl144 2789614 6257 PRE_first_tail_x15_r0_body.kd144 PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.P144
    ⟨21048, 18122, 2788459, 6239⟩ ⟨21051, 18149, 2788465, 6257⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap144
  clean := bodyClean144
  cfix := PRE_first_tail_x15_r0_body.cfix144
  zpl := PRE_first_tail_x15_r0_body.zpl144
  zplnd := PRE_first_tail_x15_r0_body.zplnd144
  zn1 := PRE_first_tail_x15_r0_body.zn1144
  zfirst := PRE_first_tail_x15_r0_body.zfirst144
  zscn := PRE_first_tail_x15_r0_body.zscn144
  zsmn := PRE_first_tail_x15_r0_body.zsmn144
  zgrow := PRE_first_tail_x15_r0_body.zgrow144
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab144
  zfresh := PRE_first_tail_x15_r0_body.zfresh144
  zcnd := PRE_first_tail_x15_r0_body.zcnd144
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi144
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt144
  zgP := PRE_first_tail_x15_r0_body.zg144_2665
  zkP := PRE_first_tail_x15_r0_body.zk144_2665
  zmP := PRE_first_tail_x15_r0_body.zm144_2665
  zgC := PRE_first_tail_x15_r0_body.zg144_2673467
  zkC := PRE_first_tail_x15_r0_body.zk144_2673467
  zmC := PRE_first_tail_x15_r0_body.zm144_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw144_2673472
  zwV := PRE_first_tail_x15_r0_body.zw144_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap144
  zclbd := PRE_first_tail_x15_r0_body.zclbd144
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap144 PRE_first_tail_x15_r0_body.stFoot144 PRE_first_tail_x15_r0_body.iso144 PRE_first_tail_x15_r0_body.zwr144
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP144
  csupp := PRE_first_tail_x15_r0_body.csupp144
  cbound := PRE_first_tail_x15_r0_body.cbound144
  zimg := PRE_first_tail_x15_r0_body.zimg144
  zctl := PRE_first_tail_x15_r0_body.zctl144
  zstack := PRE_first_tail_x15_r0_body.zstack144
  zjobs := PRE_first_tail_x15_r0_body.zjobs144
  zstores := PRE_first_tail_x15_r0_body.zstores144
  zroots := PRE_first_tail_x15_r0_body.zroots144
  znC := PRE_first_tail_x15_r0_body.znC144
  ctab := PRE_first_tail_x15_r0_body.ctab144
  zbin := PRE_first_tail_x15_r0_body.zbin144
  cbridge := PRE_first_tail_x15_r0_body.cbridge144
  sbridge := bodyBridge144
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj144
  cshiftR := fun h hNL => bodyCshift144 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN144
  raised := PRE_first_tail_x15_r0_body.raised144
  cbigs := PRE_first_tail_x15_r0_body.cbigs144
  cjcl := PRE_first_tail_x15_r0_body.cjcl144
  xnLe := Nat.le_of_ble_eq_true bodyXn144
  loLe := Nat.le_of_ble_eq_true bodyLo144
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB144
  cntM := bodyCntM144
  hiLe := Nat.le_of_ble_eq_true bodyHi144
  nhiLe := Nat.le_of_ble_eq_true bodyNhi144
  jsHeap := bodyJs144
  jsRoots := bodyJsRoots144
  jsNative := bodyJsNative144
  framesEmpty := bodyFramesEmpty144
  trailOld := by decide
  lowVars := bodyLow144

def bodyQs144 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs144 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr144.map fun r => nth? PRE_first_tail_x15_r0_body.st144.S5.tab r
kernel_rfl bodyResChk144 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs144 bodyQs144) = true
kernel_rfl bodyLq144 : bodyQs144.length = PRE_first_tail_x15_r0_body.cws144.length
kernel_rfl bodyNrLo144 : PRE_first_tail_x15_r0_body.nr144.all (Nat.ble PRE_first_tail_x15_r0_body.S1396.tab.length) = true
kernel_rfl bodySub144 : (Oracles.PRE_first_tail_x15_r0_body.map_site144.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost144 : postSubB bodyM PRE_first_tail_x15_r0_body.ws144 PRE_first_tail_x15_r0_body.cws144 bodyQs144 = true
kernel_rfl bodyDrop144 : Nat.ble (50380 + (PRE_first_tail_x15_r0_body.s1397.next - PRE_first_tail_x15_r0_body.s1398.next)) 51529 = true
kernel_rfl bodyDropH144 : Nat.ble (945 + ((mlxOf PRE_first_tail_x15_r0_body.s1397.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1398.ffi).next)) 970 = true
kernel_rfl bodyDropN144 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1397.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1398.ffi).nnext)) 0 = true
kernel_rfl bodyDv144 : bodyΘ.1.take 774 = bodyΘ.1.take 756 ++ PRE_first_tail_x15_r0_body.cws144
kernel_rfl bodyDe144 : bodyΘ.2.take 774 = bodyΘ.2.take 756 ++ PRE_first_tail_x15_r0_body.nr144.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st144.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 756) (bodyΘ.2.take 756)))
kernel_rfl bodyDl144 : (bodyΘ.1.take 756).length = (bodyΘ.2.take 756).length
kernel_rfl bodyDold144 : (bodyΘ.1.take 756).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws144).isNone && !PRE_first_tail_x15_r0_body.ws144.contains v) = true
kernel_rfl bodyDfree144 : (bodyΘ.2.take 774).all (fun e => (PRE_first_tail_x15_r0_body.cws144 ++ PRE_first_tail_x15_r0_body.ws144).all fun w => e.noVar w) = true

theorem bodyStep144 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50380, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1396 PRE_first_tail_x15_r0_body.S1396)
      (bodyCut NB T tk π i x0 bodyΘ ⟨51529, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.S1398) (11334 + 1) :=
  bodySite bodyFacts144.cfix bodyFacts144.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st144.S5.tab) (Es := bodyEs144) (qs := bodyQs144)
    (ok := PRE_first_tail_x15_r0_body.st144.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site144 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts144
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site144 r hr) hi (MapOk.sub hm (sub_of_all bodySub144)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk144 r hr) hi hm ho hq)
    bodyLq144 rfl bodyNrLo144 (postSub_sound bodyPost144)
    (Nat.le_of_ble_eq_true bodyDrop144) (by decide) (Nat.le_of_ble_eq_true bodyDropH144) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN144) (by decide)
    bodyDv144 bodyDe144 bodyDl144 bodyDold144 bodyDfree144 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
