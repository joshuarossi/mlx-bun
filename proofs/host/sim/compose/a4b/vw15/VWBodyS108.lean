import host.sim.compose.a4b.vw15.VWBodyJ108
import host.sim.compose.a4b.vw15.VWBodySite108
import host.sim.compose.a4b.vw15.VWBodyOracles_27
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

theorem bodyCshift108 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1051.tab.length PRE_first_tail_x15_r0_body.s1051.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P108.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P108 4718 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.s1053.ffi PRE_first_tail_x15_r0_body.s1052.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_108
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_108
  have hcl : SSt (· < 4718) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1051.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_108] <;> decide) PRE_first_tail_x15_r0_body.cnodesK108 PRE_first_tail_x15_r0_body.cobjsK108
      PRE_first_tail_x15_r0_body.citemsK108 PRE_first_tail_x15_r0_body.cbd108 PRE_first_tail_x15_r0_body.csst108
  exact PRE_first_tail_x15_r0_body.cshift108 bodyNcl108 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_108] at this; exact this)


kernel_rfl bodyFramesEmpty108 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1052 a).isEmpty) = true
kernel_rfl bodyJsRoots108 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1051.next) PRE_first_tail_x15_r0_body.s1053.trace PRE_first_tail_x15_r0_body.s1053 = true
kernel_rfl bodyJsNative108 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1053.ffi) = true
kernel_rfl bodyLow108 : (PRE_first_tail_x15_r0_body.cws108 ++ PRE_first_tail_x15_r0_body.ws108).all (Nat.ble 9) = true
kernel_rfl bodyCntM108 : countersOkB PRE_first_tail_x15_r0_body.s1051 PRE_first_tail_x15_r0_body.s1052 = true
kernel_rfl bodyHi108 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1053.ffi).next setupP.E = true
kernel_rfl bodyNhi108 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1053.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge108 : bridgeOf PRE_first_tail_x15_r0_body.s1052.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1051.ffi
kernel_rfl bodyNN108 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1051.ffi).nnext PRE_first_tail_x15_r0_body.P108.NL = true
kernel_rfl bodyXn108 : Nat.ble (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1053.ffi).next = true
kernel_rfl bodyLo108 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1053.ffi).next = true
theorem bodyFacts108 : BodySiteFacts PRE_first_tail_x15_r0_body.s1051 PRE_first_tail_x15_r0_body.s1052 PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1051 PRE_first_tail_x15_r0_body.S1052 PRE_first_tail_x15_r0_body.S1053
    PRE_first_tail_x15_r0_body.ws108 PRE_first_tail_x15_r0_body.cws108 PRE_first_tail_x15_r0_body.nr108 PRE_first_tail_x15_r0_body.pl108 PRE_first_tail_x15_r0_body.cl108 2761366 4718 PRE_first_tail_x15_r0_body.kd108 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.P108
    ⟨20340, 17411, 2760211, 4700⟩ ⟨20343, 17438, 2760217, 4718⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap108
  clean := bodyClean108
  cfix := PRE_first_tail_x15_r0_body.cfix108
  zpl := PRE_first_tail_x15_r0_body.zpl108
  zplnd := PRE_first_tail_x15_r0_body.zplnd108
  zn1 := PRE_first_tail_x15_r0_body.zn1108
  zfirst := PRE_first_tail_x15_r0_body.zfirst108
  zscn := PRE_first_tail_x15_r0_body.zscn108
  zsmn := PRE_first_tail_x15_r0_body.zsmn108
  zgrow := PRE_first_tail_x15_r0_body.zgrow108
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab108
  zfresh := PRE_first_tail_x15_r0_body.zfresh108
  zcnd := PRE_first_tail_x15_r0_body.zcnd108
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi108
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt108
  zgP := PRE_first_tail_x15_r0_body.zg108_2665
  zkP := PRE_first_tail_x15_r0_body.zk108_2665
  zmP := PRE_first_tail_x15_r0_body.zm108_2665
  zgC := PRE_first_tail_x15_r0_body.zg108_2673467
  zkC := PRE_first_tail_x15_r0_body.zk108_2673467
  zmC := PRE_first_tail_x15_r0_body.zm108_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw108_2673472
  zwV := PRE_first_tail_x15_r0_body.zw108_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap108
  zclbd := PRE_first_tail_x15_r0_body.zclbd108
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap108 PRE_first_tail_x15_r0_body.stFoot108 PRE_first_tail_x15_r0_body.iso108 PRE_first_tail_x15_r0_body.zwr108
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP108
  csupp := PRE_first_tail_x15_r0_body.csupp108
  cbound := PRE_first_tail_x15_r0_body.cbound108
  zimg := PRE_first_tail_x15_r0_body.zimg108
  zctl := PRE_first_tail_x15_r0_body.zctl108
  zstack := PRE_first_tail_x15_r0_body.zstack108
  zjobs := PRE_first_tail_x15_r0_body.zjobs108
  zstores := PRE_first_tail_x15_r0_body.zstores108
  zroots := PRE_first_tail_x15_r0_body.zroots108
  znC := PRE_first_tail_x15_r0_body.znC108
  ctab := PRE_first_tail_x15_r0_body.ctab108
  zbin := PRE_first_tail_x15_r0_body.zbin108
  cbridge := PRE_first_tail_x15_r0_body.cbridge108
  sbridge := bodyBridge108
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj108
  cshiftR := fun h hNL => bodyCshift108 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN108
  raised := PRE_first_tail_x15_r0_body.raised108
  cbigs := PRE_first_tail_x15_r0_body.cbigs108
  cjcl := PRE_first_tail_x15_r0_body.cjcl108
  xnLe := Nat.le_of_ble_eq_true bodyXn108
  loLe := Nat.le_of_ble_eq_true bodyLo108
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB108
  cntM := bodyCntM108
  hiLe := Nat.le_of_ble_eq_true bodyHi108
  nhiLe := Nat.le_of_ble_eq_true bodyNhi108
  jsHeap := bodyJs108
  jsRoots := bodyJsRoots108
  jsNative := bodyJsNative108
  framesEmpty := bodyFramesEmpty108
  trailOld := by decide
  lowVars := bodyLow108

def bodyQs108 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs108 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr108.map fun r => nth? PRE_first_tail_x15_r0_body.st108.S5.tab r
kernel_rfl bodyResChk108 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs108 bodyQs108) = true
kernel_rfl bodyLq108 : bodyQs108.length = PRE_first_tail_x15_r0_body.cws108.length
kernel_rfl bodyNrLo108 : PRE_first_tail_x15_r0_body.nr108.all (Nat.ble PRE_first_tail_x15_r0_body.S1051.tab.length) = true
kernel_rfl bodySub108 : (Oracles.PRE_first_tail_x15_r0_body.map_site108.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost108 : postSubB bodyM PRE_first_tail_x15_r0_body.ws108 PRE_first_tail_x15_r0_body.cws108 bodyQs108 = true
kernel_rfl bodyDrop108 : Nat.ble (38818 + (PRE_first_tail_x15_r0_body.s1052.next - PRE_first_tail_x15_r0_body.s1053.next)) 39967 = true
kernel_rfl bodyDropH108 : Nat.ble (714 + ((mlxOf PRE_first_tail_x15_r0_body.s1052.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1053.ffi).next)) 739 = true
kernel_rfl bodyDropN108 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1052.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1053.ffi).nnext)) 0 = true
kernel_rfl bodyDv108 : bodyΘ.1.take 585 = bodyΘ.1.take 567 ++ PRE_first_tail_x15_r0_body.cws108
kernel_rfl bodyDe108 : bodyΘ.2.take 585 = bodyΘ.2.take 567 ++ PRE_first_tail_x15_r0_body.nr108.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st108.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 567) (bodyΘ.2.take 567)))
kernel_rfl bodyDl108 : (bodyΘ.1.take 567).length = (bodyΘ.2.take 567).length
kernel_rfl bodyDold108 : (bodyΘ.1.take 567).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws108).isNone && !PRE_first_tail_x15_r0_body.ws108.contains v) = true
kernel_rfl bodyDfree108 : (bodyΘ.2.take 585).all (fun e => (PRE_first_tail_x15_r0_body.cws108 ++ PRE_first_tail_x15_r0_body.ws108).all fun w => e.noVar w) = true

theorem bodyStep108 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38818, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1051 PRE_first_tail_x15_r0_body.S1051)
      (bodyCut NB T tk π i x0 bodyΘ ⟨39967, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.S1053) (11334 + 1) :=
  bodySite bodyFacts108.cfix bodyFacts108.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st108.S5.tab) (Es := bodyEs108) (qs := bodyQs108)
    (ok := PRE_first_tail_x15_r0_body.st108.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site108 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts108
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site108 r hr) hi (MapOk.sub hm (sub_of_all bodySub108)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk108 r hr) hi hm ho hq)
    bodyLq108 rfl bodyNrLo108 (postSub_sound bodyPost108)
    (Nat.le_of_ble_eq_true bodyDrop108) (by decide) (Nat.le_of_ble_eq_true bodyDropH108) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN108) (by decide)
    bodyDv108 bodyDe108 bodyDl108 bodyDold108 bodyDfree108 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
