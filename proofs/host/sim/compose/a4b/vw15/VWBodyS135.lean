import host.sim.compose.a4b.vw15.VWBodyJ135
import host.sim.compose.a4b.vw15.VWBodySite135
import host.sim.compose.a4b.vw15.VWBodyOracles_33
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift135 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1310.tab.length PRE_first_tail_x15_r0_body.s1310.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P135.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P135 5873 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.s1312.ffi PRE_first_tail_x15_r0_body.s1311.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_135
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_135
  have hcl : SSt (· < 5873) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1310.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_135] <;> decide) PRE_first_tail_x15_r0_body.cnodesK135 PRE_first_tail_x15_r0_body.cobjsK135
      PRE_first_tail_x15_r0_body.citemsK135 PRE_first_tail_x15_r0_body.cbd135 PRE_first_tail_x15_r0_body.csst135
  exact PRE_first_tail_x15_r0_body.cshift135 bodyNcl135 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_135] at this; exact this)


kernel_rfl bodyFramesEmpty135 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1311 a).isEmpty) = true
kernel_rfl bodyJsRoots135 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1310.next) PRE_first_tail_x15_r0_body.s1312.trace PRE_first_tail_x15_r0_body.s1312 = true
kernel_rfl bodyJsNative135 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1312.ffi) = true
kernel_rfl bodyLow135 : (PRE_first_tail_x15_r0_body.cws135 ++ PRE_first_tail_x15_r0_body.ws135).all (Nat.ble 9) = true
kernel_rfl bodyCntM135 : countersOkB PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.s1311 = true
kernel_rfl bodyHi135 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1312.ffi).next setupP.E = true
kernel_rfl bodyNhi135 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1312.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge135 : bridgeOf PRE_first_tail_x15_r0_body.s1311.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1310.ffi
kernel_rfl bodyNN135 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1310.ffi).nnext PRE_first_tail_x15_r0_body.P135.NL = true
kernel_rfl bodyXn135 : Nat.ble (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1312.ffi).next = true
kernel_rfl bodyLo135 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1312.ffi).next = true
theorem bodyFacts135 : BodySiteFacts PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.s1311 PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1310 PRE_first_tail_x15_r0_body.S1311 PRE_first_tail_x15_r0_body.S1312
    PRE_first_tail_x15_r0_body.ws135 PRE_first_tail_x15_r0_body.cws135 PRE_first_tail_x15_r0_body.nr135 PRE_first_tail_x15_r0_body.pl135 PRE_first_tail_x15_r0_body.cl135 2782446 5873 PRE_first_tail_x15_r0_body.kd135 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.P135
    ⟨20869, 17948, 2781291, 5855⟩ ⟨20872, 17975, 2781297, 5873⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap135
  clean := bodyClean135
  cfix := PRE_first_tail_x15_r0_body.cfix135
  zpl := PRE_first_tail_x15_r0_body.zpl135
  zplnd := PRE_first_tail_x15_r0_body.zplnd135
  zn1 := PRE_first_tail_x15_r0_body.zn1135
  zfirst := PRE_first_tail_x15_r0_body.zfirst135
  zscn := PRE_first_tail_x15_r0_body.zscn135
  zsmn := PRE_first_tail_x15_r0_body.zsmn135
  zgrow := PRE_first_tail_x15_r0_body.zgrow135
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab135
  zfresh := PRE_first_tail_x15_r0_body.zfresh135
  zcnd := PRE_first_tail_x15_r0_body.zcnd135
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi135
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt135
  zgP := PRE_first_tail_x15_r0_body.zg135_2665
  zkP := PRE_first_tail_x15_r0_body.zk135_2665
  zmP := PRE_first_tail_x15_r0_body.zm135_2665
  zgC := PRE_first_tail_x15_r0_body.zg135_2673467
  zkC := PRE_first_tail_x15_r0_body.zk135_2673467
  zmC := PRE_first_tail_x15_r0_body.zm135_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw135_2673472
  zwV := PRE_first_tail_x15_r0_body.zw135_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap135
  zclbd := PRE_first_tail_x15_r0_body.zclbd135
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap135 PRE_first_tail_x15_r0_body.stFoot135 PRE_first_tail_x15_r0_body.iso135 PRE_first_tail_x15_r0_body.zwr135
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP135
  csupp := PRE_first_tail_x15_r0_body.csupp135
  cbound := PRE_first_tail_x15_r0_body.cbound135
  zimg := PRE_first_tail_x15_r0_body.zimg135
  zctl := PRE_first_tail_x15_r0_body.zctl135
  zstack := PRE_first_tail_x15_r0_body.zstack135
  zjobs := PRE_first_tail_x15_r0_body.zjobs135
  zstores := PRE_first_tail_x15_r0_body.zstores135
  zroots := PRE_first_tail_x15_r0_body.zroots135
  znC := PRE_first_tail_x15_r0_body.znC135
  ctab := PRE_first_tail_x15_r0_body.ctab135
  zbin := PRE_first_tail_x15_r0_body.zbin135
  cbridge := PRE_first_tail_x15_r0_body.cbridge135
  sbridge := bodyBridge135
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj135
  cshiftR := fun h hNL => bodyCshift135 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN135
  raised := PRE_first_tail_x15_r0_body.raised135
  cbigs := PRE_first_tail_x15_r0_body.cbigs135
  cjcl := PRE_first_tail_x15_r0_body.cjcl135
  xnLe := Nat.le_of_ble_eq_true bodyXn135
  loLe := Nat.le_of_ble_eq_true bodyLo135
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB135
  cntM := bodyCntM135
  hiLe := Nat.le_of_ble_eq_true bodyHi135
  nhiLe := Nat.le_of_ble_eq_true bodyNhi135
  jsHeap := bodyJs135
  jsRoots := bodyJsRoots135
  jsNative := bodyJsNative135
  framesEmpty := bodyFramesEmpty135
  trailOld := by decide
  lowVars := bodyLow135

def bodyQs135 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs135 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr135.map fun r => nth? PRE_first_tail_x15_r0_body.st135.S5.tab r
kernel_rfl bodyResChk135 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs135 bodyQs135) = true
kernel_rfl bodyLq135 : bodyQs135.length = PRE_first_tail_x15_r0_body.cws135.length
kernel_rfl bodyNrLo135 : PRE_first_tail_x15_r0_body.nr135.all (Nat.ble PRE_first_tail_x15_r0_body.S1310.tab.length) = true
kernel_rfl bodySub135 : (Oracles.PRE_first_tail_x15_r0_body.map_site135.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost135 : postSubB bodyM PRE_first_tail_x15_r0_body.ws135 PRE_first_tail_x15_r0_body.cws135 bodyQs135 = true
kernel_rfl bodyDrop135 : Nat.ble (47669 + (PRE_first_tail_x15_r0_body.s1311.next - PRE_first_tail_x15_r0_body.s1312.next)) 48818 = true
kernel_rfl bodyDropH135 : Nat.ble (893 + ((mlxOf PRE_first_tail_x15_r0_body.s1311.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1312.ffi).next)) 918 = true
kernel_rfl bodyDropN135 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1311.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1312.ffi).nnext)) 0 = true
kernel_rfl bodyDv135 : bodyΘ.1.take 729 = bodyΘ.1.take 711 ++ PRE_first_tail_x15_r0_body.cws135
kernel_rfl bodyDe135 : bodyΘ.2.take 729 = bodyΘ.2.take 711 ++ PRE_first_tail_x15_r0_body.nr135.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st135.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 711) (bodyΘ.2.take 711)))
kernel_rfl bodyDl135 : (bodyΘ.1.take 711).length = (bodyΘ.2.take 711).length
kernel_rfl bodyDold135 : (bodyΘ.1.take 711).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws135).isNone && !PRE_first_tail_x15_r0_body.ws135.contains v) = true
kernel_rfl bodyDfree135 : (bodyΘ.2.take 729).all (fun e => (PRE_first_tail_x15_r0_body.cws135 ++ PRE_first_tail_x15_r0_body.ws135).all fun w => e.noVar w) = true

theorem bodyStep135 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨47669, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.S1310)
      (bodyCut NB T tk π i x0 bodyΘ ⟨48818, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.S1312) (11334 + 1) :=
  bodySite bodyFacts135.cfix bodyFacts135.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st135.S5.tab) (Es := bodyEs135) (qs := bodyQs135)
    (ok := PRE_first_tail_x15_r0_body.st135.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site135 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts135
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site135 r hr) hi (MapOk.sub hm (sub_of_all bodySub135)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk135 r hr) hi hm ho hq)
    bodyLq135 rfl bodyNrLo135 (postSub_sound bodyPost135)
    (Nat.le_of_ble_eq_true bodyDrop135) (by decide) (Nat.le_of_ble_eq_true bodyDropH135) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN135) (by decide)
    bodyDv135 bodyDe135 bodyDl135 bodyDold135 bodyDfree135 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
