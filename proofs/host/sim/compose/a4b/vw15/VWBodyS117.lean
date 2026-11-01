import host.sim.compose.a4b.vw15.VWBodyJ117
import host.sim.compose.a4b.vw15.VWBodySite117
import host.sim.compose.a4b.vw15.VWBodyOracles_29
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift117 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1137.tab.length PRE_first_tail_x15_r0_body.s1137.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P117.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P117 5100 PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.s1139.ffi PRE_first_tail_x15_r0_body.s1138.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_117
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_117
  have hcl : SSt (· < 5100) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1137.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_117] <;> decide) PRE_first_tail_x15_r0_body.cnodesK117 PRE_first_tail_x15_r0_body.cobjsK117
      PRE_first_tail_x15_r0_body.citemsK117 PRE_first_tail_x15_r0_body.cbd117 PRE_first_tail_x15_r0_body.csst117
  exact PRE_first_tail_x15_r0_body.cshift117 bodyNcl117 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_117] at this; exact this)


kernel_rfl bodyFramesEmpty117 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1138 a).isEmpty) = true
kernel_rfl bodyJsRoots117 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1137.next) PRE_first_tail_x15_r0_body.s1139.trace PRE_first_tail_x15_r0_body.s1139 = true
kernel_rfl bodyJsNative117 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1139.ffi) = true
kernel_rfl bodyLow117 : (PRE_first_tail_x15_r0_body.cws117 ++ PRE_first_tail_x15_r0_body.ws117).all (Nat.ble 9) = true
kernel_rfl bodyCntM117 : countersOkB PRE_first_tail_x15_r0_body.s1137 PRE_first_tail_x15_r0_body.s1138 = true
kernel_rfl bodyHi117 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1139.ffi).next setupP.E = true
kernel_rfl bodyNhi117 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1139.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge117 : bridgeOf PRE_first_tail_x15_r0_body.s1138.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1137.ffi
kernel_rfl bodyNN117 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1137.ffi).nnext PRE_first_tail_x15_r0_body.P117.NL = true
kernel_rfl bodyXn117 : Nat.ble (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1139.ffi).next = true
kernel_rfl bodyLo117 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1139.ffi).next = true
theorem bodyFacts117 : BodySiteFacts PRE_first_tail_x15_r0_body.s1137 PRE_first_tail_x15_r0_body.s1138 PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1137 PRE_first_tail_x15_r0_body.S1138 PRE_first_tail_x15_r0_body.S1139
    PRE_first_tail_x15_r0_body.ws117 PRE_first_tail_x15_r0_body.cws117 PRE_first_tail_x15_r0_body.nr117 PRE_first_tail_x15_r0_body.pl117 PRE_first_tail_x15_r0_body.cl117 2767609 5100 PRE_first_tail_x15_r0_body.kd117 PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.P117
    ⟨20517, 17609, 2767244, 5091⟩ ⟨20521, 17615, 2767259, 5100⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap117
  clean := bodyClean117
  cfix := PRE_first_tail_x15_r0_body.cfix117
  zpl := PRE_first_tail_x15_r0_body.zpl117
  zplnd := PRE_first_tail_x15_r0_body.zplnd117
  zn1 := PRE_first_tail_x15_r0_body.zn1117
  zfirst := PRE_first_tail_x15_r0_body.zfirst117
  zscn := PRE_first_tail_x15_r0_body.zscn117
  zsmn := PRE_first_tail_x15_r0_body.zsmn117
  zgrow := PRE_first_tail_x15_r0_body.zgrow117
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab117
  zfresh := PRE_first_tail_x15_r0_body.zfresh117
  zcnd := PRE_first_tail_x15_r0_body.zcnd117
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi117
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt117
  zgP := PRE_first_tail_x15_r0_body.zg117_2665
  zkP := PRE_first_tail_x15_r0_body.zk117_2665
  zmP := PRE_first_tail_x15_r0_body.zm117_2665
  zgC := PRE_first_tail_x15_r0_body.zg117_2673467
  zkC := PRE_first_tail_x15_r0_body.zk117_2673467
  zmC := PRE_first_tail_x15_r0_body.zm117_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw117_2673472
  zwV := PRE_first_tail_x15_r0_body.zw117_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap117
  zclbd := PRE_first_tail_x15_r0_body.zclbd117
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap117 PRE_first_tail_x15_r0_body.stFoot117 PRE_first_tail_x15_r0_body.iso117 PRE_first_tail_x15_r0_body.zwr117
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP117
  csupp := PRE_first_tail_x15_r0_body.csupp117
  cbound := PRE_first_tail_x15_r0_body.cbound117
  zimg := PRE_first_tail_x15_r0_body.zimg117
  zctl := PRE_first_tail_x15_r0_body.zctl117
  zstack := PRE_first_tail_x15_r0_body.zstack117
  zjobs := PRE_first_tail_x15_r0_body.zjobs117
  zstores := PRE_first_tail_x15_r0_body.zstores117
  zroots := PRE_first_tail_x15_r0_body.zroots117
  znC := PRE_first_tail_x15_r0_body.znC117
  ctab := PRE_first_tail_x15_r0_body.ctab117
  zbin := PRE_first_tail_x15_r0_body.zbin117
  cbridge := PRE_first_tail_x15_r0_body.cbridge117
  sbridge := bodyBridge117
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj117
  cshiftR := fun h hNL => bodyCshift117 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN117
  raised := PRE_first_tail_x15_r0_body.raised117
  cbigs := PRE_first_tail_x15_r0_body.cbigs117
  cjcl := PRE_first_tail_x15_r0_body.cjcl117
  xnLe := Nat.le_of_ble_eq_true bodyXn117
  loLe := Nat.le_of_ble_eq_true bodyLo117
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB117
  cntM := bodyCntM117
  hiLe := Nat.le_of_ble_eq_true bodyHi117
  nhiLe := Nat.le_of_ble_eq_true bodyNhi117
  jsHeap := bodyJs117
  jsRoots := bodyJsRoots117
  jsNative := bodyJsNative117
  framesEmpty := bodyFramesEmpty117
  trailOld := by decide
  lowVars := bodyLow117

def bodyQs117 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs117 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr117.map fun r => nth? PRE_first_tail_x15_r0_body.st117.S3.tab r
kernel_rfl bodyResChk117 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs117 bodyQs117) = true
kernel_rfl bodyLq117 : bodyQs117.length = PRE_first_tail_x15_r0_body.cws117.length
kernel_rfl bodyNrLo117 : PRE_first_tail_x15_r0_body.nr117.all (Nat.ble PRE_first_tail_x15_r0_body.S1137.tab.length) = true
kernel_rfl bodySub117 : (Oracles.PRE_first_tail_x15_r0_body.map_site117.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost117 : postSubB bodyM PRE_first_tail_x15_r0_body.ws117 PRE_first_tail_x15_r0_body.cws117 bodyQs117 = true
kernel_rfl bodyDrop117 : Nat.ble (42301 + (PRE_first_tail_x15_r0_body.s1138.next - PRE_first_tail_x15_r0_body.s1139.next)) 42651 = true
kernel_rfl bodyDropH117 : Nat.ble (789 + ((mlxOf PRE_first_tail_x15_r0_body.s1138.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1139.ffi).next)) 791 = true
kernel_rfl bodyDropN117 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1138.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1139.ffi).nnext)) 0 = true
kernel_rfl bodyDv117 : bodyΘ.1.take 630 = bodyΘ.1.take 621 ++ PRE_first_tail_x15_r0_body.cws117
kernel_rfl bodyDe117 : bodyΘ.2.take 630 = bodyΘ.2.take 621 ++ PRE_first_tail_x15_r0_body.nr117.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st117.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 621) (bodyΘ.2.take 621)))
kernel_rfl bodyDl117 : (bodyΘ.1.take 621).length = (bodyΘ.2.take 621).length
kernel_rfl bodyDold117 : (bodyΘ.1.take 621).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws117).isNone && !PRE_first_tail_x15_r0_body.ws117.contains v) = true
kernel_rfl bodyDfree117 : (bodyΘ.2.take 630).all (fun e => (PRE_first_tail_x15_r0_body.cws117 ++ PRE_first_tail_x15_r0_body.ws117).all fun w => e.noVar w) = true

theorem bodyStep117 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42301, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1137 PRE_first_tail_x15_r0_body.S1137)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42651, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.S1139) (3452 + 1) :=
  bodySite bodyFacts117.cfix bodyFacts117.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st117.S3.tab) (Es := bodyEs117) (qs := bodyQs117)
    (ok := PRE_first_tail_x15_r0_body.st117.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site117 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts117
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site117 r hr) hi (MapOk.sub hm (sub_of_all bodySub117)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk117 r hr) hi hm ho hq)
    bodyLq117 rfl bodyNrLo117 (postSub_sound bodyPost117)
    (Nat.le_of_ble_eq_true bodyDrop117) (by decide) (Nat.le_of_ble_eq_true bodyDropH117) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN117) (by decide)
    bodyDv117 bodyDe117 bodyDl117 bodyDold117 bodyDfree117 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
