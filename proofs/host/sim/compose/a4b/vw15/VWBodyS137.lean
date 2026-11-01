import host.sim.compose.a4b.vw15.VWBodyJ137
import host.sim.compose.a4b.vw15.VWBodySite137
import host.sim.compose.a4b.vw15.VWBodyOracles_34
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

theorem bodyCshift137 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1322.tab.length PRE_first_tail_x15_r0_body.s1322.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P137.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P137 5911 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.s1324.ffi PRE_first_tail_x15_r0_body.s1323.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_137
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_137
  have hcl : SSt (· < 5911) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1322.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_137] <;> decide) PRE_first_tail_x15_r0_body.cnodesK137 PRE_first_tail_x15_r0_body.cobjsK137
      PRE_first_tail_x15_r0_body.citemsK137 PRE_first_tail_x15_r0_body.cbd137 PRE_first_tail_x15_r0_body.csst137
  exact PRE_first_tail_x15_r0_body.cshift137 bodyNcl137 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_137] at this; exact this)


kernel_rfl bodyFramesEmpty137 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1323 a).isEmpty) = true
kernel_rfl bodyJsRoots137 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1322.next) PRE_first_tail_x15_r0_body.s1324.trace PRE_first_tail_x15_r0_body.s1324 = true
kernel_rfl bodyJsNative137 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1324.ffi) = true
kernel_rfl bodyLow137 : (PRE_first_tail_x15_r0_body.cws137 ++ PRE_first_tail_x15_r0_body.ws137).all (Nat.ble 9) = true
kernel_rfl bodyCntM137 : countersOkB PRE_first_tail_x15_r0_body.s1322 PRE_first_tail_x15_r0_body.s1323 = true
kernel_rfl bodyHi137 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1324.ffi).next setupP.E = true
kernel_rfl bodyNhi137 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1324.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge137 : bridgeOf PRE_first_tail_x15_r0_body.s1323.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1322.ffi
kernel_rfl bodyNN137 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1322.ffi).nnext PRE_first_tail_x15_r0_body.P137.NL = true
kernel_rfl bodyXn137 : Nat.ble (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1324.ffi).next = true
kernel_rfl bodyLo137 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1324.ffi).next = true
theorem bodyFacts137 : BodySiteFacts PRE_first_tail_x15_r0_body.s1322 PRE_first_tail_x15_r0_body.s1323 PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1322 PRE_first_tail_x15_r0_body.S1323 PRE_first_tail_x15_r0_body.S1324
    PRE_first_tail_x15_r0_body.ws137 PRE_first_tail_x15_r0_body.cws137 PRE_first_tail_x15_r0_body.nr137 PRE_first_tail_x15_r0_body.pl137 PRE_first_tail_x15_r0_body.cl137 2782095 5911 PRE_first_tail_x15_r0_body.kd137 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.P137
    ⟨20892, 17992, 2782075, 5911⟩ ⟨20892, 17992, 2782076, 5911⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap137
  clean := bodyClean137
  cfix := PRE_first_tail_x15_r0_body.cfix137
  zpl := PRE_first_tail_x15_r0_body.zpl137
  zplnd := PRE_first_tail_x15_r0_body.zplnd137
  zn1 := PRE_first_tail_x15_r0_body.zn1137
  zfirst := PRE_first_tail_x15_r0_body.zfirst137
  zscn := PRE_first_tail_x15_r0_body.zscn137
  zsmn := PRE_first_tail_x15_r0_body.zsmn137
  zgrow := PRE_first_tail_x15_r0_body.zgrow137
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab137
  zfresh := PRE_first_tail_x15_r0_body.zfresh137
  zcnd := PRE_first_tail_x15_r0_body.zcnd137
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi137
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt137
  zgP := PRE_first_tail_x15_r0_body.zg137_2665
  zkP := PRE_first_tail_x15_r0_body.zk137_2665
  zmP := PRE_first_tail_x15_r0_body.zm137_2665
  zgC := PRE_first_tail_x15_r0_body.zg137_2673467
  zkC := PRE_first_tail_x15_r0_body.zk137_2673467
  zmC := PRE_first_tail_x15_r0_body.zm137_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw137_2673472
  zwV := PRE_first_tail_x15_r0_body.zw137_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap137
  zclbd := PRE_first_tail_x15_r0_body.zclbd137
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap137 PRE_first_tail_x15_r0_body.stFoot137 PRE_first_tail_x15_r0_body.iso137 PRE_first_tail_x15_r0_body.zwr137
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP137
  csupp := PRE_first_tail_x15_r0_body.csupp137
  cbound := PRE_first_tail_x15_r0_body.cbound137
  zimg := PRE_first_tail_x15_r0_body.zimg137
  zctl := PRE_first_tail_x15_r0_body.zctl137
  zstack := PRE_first_tail_x15_r0_body.zstack137
  zjobs := PRE_first_tail_x15_r0_body.zjobs137
  zstores := PRE_first_tail_x15_r0_body.zstores137
  zroots := PRE_first_tail_x15_r0_body.zroots137
  znC := PRE_first_tail_x15_r0_body.znC137
  ctab := PRE_first_tail_x15_r0_body.ctab137
  zbin := PRE_first_tail_x15_r0_body.zbin137
  cbridge := PRE_first_tail_x15_r0_body.cbridge137
  sbridge := bodyBridge137
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj137
  cshiftR := fun h hNL => bodyCshift137 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN137
  raised := PRE_first_tail_x15_r0_body.raised137
  cbigs := PRE_first_tail_x15_r0_body.cbigs137
  cjcl := PRE_first_tail_x15_r0_body.cjcl137
  xnLe := Nat.le_of_ble_eq_true bodyXn137
  loLe := Nat.le_of_ble_eq_true bodyLo137
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB137
  cntM := bodyCntM137
  hiLe := Nat.le_of_ble_eq_true bodyHi137
  nhiLe := Nat.le_of_ble_eq_true bodyNhi137
  jsHeap := bodyJs137
  jsRoots := bodyJsRoots137
  jsNative := bodyJsNative137
  framesEmpty := bodyFramesEmpty137
  trailOld := by decide
  lowVars := bodyLow137

def bodyQs137 : List (Option Q) := []
noncomputable def bodyEs137 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr137.map fun r => nth? PRE_first_tail_x15_r0_body.st137.S2.tab r
kernel_rfl bodyResChk137 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs137 bodyQs137) = true
kernel_rfl bodyLq137 : bodyQs137.length = PRE_first_tail_x15_r0_body.cws137.length
kernel_rfl bodyNrLo137 : PRE_first_tail_x15_r0_body.nr137.all (Nat.ble PRE_first_tail_x15_r0_body.S1322.tab.length) = true
kernel_rfl bodySub137 : (Oracles.PRE_first_tail_x15_r0_body.map_site137.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost137 : postSubB bodyM PRE_first_tail_x15_r0_body.ws137 PRE_first_tail_x15_r0_body.cws137 bodyQs137 = true
kernel_rfl bodyDrop137 : Nat.ble (48820 + (PRE_first_tail_x15_r0_body.s1323.next - PRE_first_tail_x15_r0_body.s1324.next)) 48839 = true
kernel_rfl bodyDropH137 : Nat.ble (918 + ((mlxOf PRE_first_tail_x15_r0_body.s1323.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1324.ffi).next)) 918 = true
kernel_rfl bodyDropN137 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1323.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1324.ffi).nnext)) 0 = true
kernel_rfl bodyDv137 : bodyΘ.1.take 729 = bodyΘ.1.take 729 ++ PRE_first_tail_x15_r0_body.cws137
kernel_rfl bodyDe137 : bodyΘ.2.take 729 = bodyΘ.2.take 729 ++ PRE_first_tail_x15_r0_body.nr137.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st137.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 729) (bodyΘ.2.take 729)))
kernel_rfl bodyDl137 : (bodyΘ.1.take 729).length = (bodyΘ.2.take 729).length
kernel_rfl bodyDold137 : (bodyΘ.1.take 729).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws137).isNone && !PRE_first_tail_x15_r0_body.ws137.contains v) = true
kernel_rfl bodyDfree137 : (bodyΘ.2.take 729).all (fun e => (PRE_first_tail_x15_r0_body.cws137 ++ PRE_first_tail_x15_r0_body.ws137).all fun w => e.noVar w) = true

theorem bodyStep137 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨48820, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1322 PRE_first_tail_x15_r0_body.S1322)
      (bodyCut NB T tk π i x0 bodyΘ ⟨48839, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.S1324) (206 + 1) :=
  bodySite bodyFacts137.cfix bodyFacts137.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st137.S2.tab) (Es := bodyEs137) (qs := bodyQs137)
    (ok := PRE_first_tail_x15_r0_body.st137.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site137 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts137
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site137 r hr) hi (MapOk.sub hm (sub_of_all bodySub137)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk137 r hr) hi hm ho hq)
    bodyLq137 rfl bodyNrLo137 (postSub_sound bodyPost137)
    (Nat.le_of_ble_eq_true bodyDrop137) (by decide) (Nat.le_of_ble_eq_true bodyDropH137) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN137) (by decide)
    bodyDv137 bodyDe137 bodyDl137 bodyDold137 bodyDfree137 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
