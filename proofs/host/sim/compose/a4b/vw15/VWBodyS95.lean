import host.sim.compose.a4b.vw15.VWBodyJ95
import host.sim.compose.a4b.vw15.VWBodySite95
import host.sim.compose.a4b.vw15.VWBodyOracles_23
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

theorem bodyCshift95 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S919.tab.length PRE_first_tail_x15_r0_body.s919.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P95.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P95 4114 PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.s921.ffi PRE_first_tail_x15_r0_body.s920.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_95
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_95
  have hcl : SSt (· < 4114) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S919.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_95] <;> decide) PRE_first_tail_x15_r0_body.cnodesK95 PRE_first_tail_x15_r0_body.cobjsK95
      PRE_first_tail_x15_r0_body.citemsK95 PRE_first_tail_x15_r0_body.cbd95 PRE_first_tail_x15_r0_body.csst95
  exact PRE_first_tail_x15_r0_body.cshift95 bodyNcl95 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_95] at this; exact this)


kernel_rfl bodyFramesEmpty95 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s920 a).isEmpty) = true
kernel_rfl bodyJsRoots95 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s919.next) PRE_first_tail_x15_r0_body.s921.trace PRE_first_tail_x15_r0_body.s921 = true
kernel_rfl bodyJsNative95 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s921.ffi) = true
kernel_rfl bodyLow95 : (PRE_first_tail_x15_r0_body.cws95 ++ PRE_first_tail_x15_r0_body.ws95).all (Nat.ble 9) = true
kernel_rfl bodyCntM95 : countersOkB PRE_first_tail_x15_r0_body.s919 PRE_first_tail_x15_r0_body.s920 = true
kernel_rfl bodyHi95 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s921.ffi).next setupP.E = true
kernel_rfl bodyNhi95 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s921.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge95 : bridgeOf PRE_first_tail_x15_r0_body.s920.ffi = bridgeOf PRE_first_tail_x15_r0_body.s919.ffi
kernel_rfl bodyNN95 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s919.ffi).nnext PRE_first_tail_x15_r0_body.P95.NL = true
kernel_rfl bodyXn95 : Nat.ble (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s921.ffi).next = true
kernel_rfl bodyLo95 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s921.ffi).next = true
theorem bodyFacts95 : BodySiteFacts PRE_first_tail_x15_r0_body.s919 PRE_first_tail_x15_r0_body.s920 PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S919 PRE_first_tail_x15_r0_body.S920 PRE_first_tail_x15_r0_body.S921
    PRE_first_tail_x15_r0_body.ws95 PRE_first_tail_x15_r0_body.cws95 PRE_first_tail_x15_r0_body.nr95 PRE_first_tail_x15_r0_body.pl95 PRE_first_tail_x15_r0_body.cl95 2749313 4114 PRE_first_tail_x15_r0_body.kd95 PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.P95
    ⟨20069, 17155, 2749293, 4114⟩ ⟨20069, 17155, 2749294, 4114⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap95
  clean := bodyClean95
  cfix := PRE_first_tail_x15_r0_body.cfix95
  zpl := PRE_first_tail_x15_r0_body.zpl95
  zplnd := PRE_first_tail_x15_r0_body.zplnd95
  zn1 := PRE_first_tail_x15_r0_body.zn195
  zfirst := PRE_first_tail_x15_r0_body.zfirst95
  zscn := PRE_first_tail_x15_r0_body.zscn95
  zsmn := PRE_first_tail_x15_r0_body.zsmn95
  zgrow := PRE_first_tail_x15_r0_body.zgrow95
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab95
  zfresh := PRE_first_tail_x15_r0_body.zfresh95
  zcnd := PRE_first_tail_x15_r0_body.zcnd95
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi95
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt95
  zgP := PRE_first_tail_x15_r0_body.zg95_2665
  zkP := PRE_first_tail_x15_r0_body.zk95_2665
  zmP := PRE_first_tail_x15_r0_body.zm95_2665
  zgC := PRE_first_tail_x15_r0_body.zg95_2673467
  zkC := PRE_first_tail_x15_r0_body.zk95_2673467
  zmC := PRE_first_tail_x15_r0_body.zm95_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw95_2673472
  zwV := PRE_first_tail_x15_r0_body.zw95_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap95
  zclbd := PRE_first_tail_x15_r0_body.zclbd95
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap95 PRE_first_tail_x15_r0_body.stFoot95 PRE_first_tail_x15_r0_body.iso95 PRE_first_tail_x15_r0_body.zwr95
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP95
  csupp := PRE_first_tail_x15_r0_body.csupp95
  cbound := PRE_first_tail_x15_r0_body.cbound95
  zimg := PRE_first_tail_x15_r0_body.zimg95
  zctl := PRE_first_tail_x15_r0_body.zctl95
  zstack := PRE_first_tail_x15_r0_body.zstack95
  zjobs := PRE_first_tail_x15_r0_body.zjobs95
  zstores := PRE_first_tail_x15_r0_body.zstores95
  zroots := PRE_first_tail_x15_r0_body.zroots95
  znC := PRE_first_tail_x15_r0_body.znC95
  ctab := PRE_first_tail_x15_r0_body.ctab95
  zbin := PRE_first_tail_x15_r0_body.zbin95
  cbridge := PRE_first_tail_x15_r0_body.cbridge95
  sbridge := bodyBridge95
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj95
  cshiftR := fun h hNL => bodyCshift95 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN95
  raised := PRE_first_tail_x15_r0_body.raised95
  cbigs := PRE_first_tail_x15_r0_body.cbigs95
  cjcl := PRE_first_tail_x15_r0_body.cjcl95
  xnLe := Nat.le_of_ble_eq_true bodyXn95
  loLe := Nat.le_of_ble_eq_true bodyLo95
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB95
  cntM := bodyCntM95
  hiLe := Nat.le_of_ble_eq_true bodyHi95
  nhiLe := Nat.le_of_ble_eq_true bodyNhi95
  jsHeap := bodyJs95
  jsRoots := bodyJsRoots95
  jsNative := bodyJsNative95
  framesEmpty := bodyFramesEmpty95
  trailOld := by decide
  lowVars := bodyLow95

def bodyQs95 : List (Option Q) := []
noncomputable def bodyEs95 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr95.map fun r => nth? PRE_first_tail_x15_r0_body.st95.S2.tab r
kernel_rfl bodyResChk95 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs95 bodyQs95) = true
kernel_rfl bodyLq95 : bodyQs95.length = PRE_first_tail_x15_r0_body.cws95.length
kernel_rfl bodyNrLo95 : PRE_first_tail_x15_r0_body.nr95.all (Nat.ble PRE_first_tail_x15_r0_body.S919.tab.length) = true
kernel_rfl bodySub95 : (Oracles.PRE_first_tail_x15_r0_body.map_site95.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost95 : postSubB bodyM PRE_first_tail_x15_r0_body.ws95 PRE_first_tail_x15_r0_body.cws95 bodyQs95 = true
kernel_rfl bodyDrop95 : Nat.ble (34936 + (PRE_first_tail_x15_r0_body.s920.next - PRE_first_tail_x15_r0_body.s921.next)) 34955 = true
kernel_rfl bodyDropH95 : Nat.ble (637 + ((mlxOf PRE_first_tail_x15_r0_body.s920.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s921.ffi).next)) 637 = true
kernel_rfl bodyDropN95 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s920.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s921.ffi).nnext)) 0 = true
kernel_rfl bodyDv95 : bodyΘ.1.take 504 = bodyΘ.1.take 504 ++ PRE_first_tail_x15_r0_body.cws95
kernel_rfl bodyDe95 : bodyΘ.2.take 504 = bodyΘ.2.take 504 ++ PRE_first_tail_x15_r0_body.nr95.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st95.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 504) (bodyΘ.2.take 504)))
kernel_rfl bodyDl95 : (bodyΘ.1.take 504).length = (bodyΘ.2.take 504).length
kernel_rfl bodyDold95 : (bodyΘ.1.take 504).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws95).isNone && !PRE_first_tail_x15_r0_body.ws95.contains v) = true
kernel_rfl bodyDfree95 : (bodyΘ.2.take 504).all (fun e => (PRE_first_tail_x15_r0_body.cws95 ++ PRE_first_tail_x15_r0_body.ws95).all fun w => e.noVar w) = true

theorem bodyStep95 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34936, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s919 PRE_first_tail_x15_r0_body.S919)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34955, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.S921) (206 + 1) :=
  bodySite bodyFacts95.cfix bodyFacts95.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st95.S2.tab) (Es := bodyEs95) (qs := bodyQs95)
    (ok := PRE_first_tail_x15_r0_body.st95.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site95 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts95
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site95 r hr) hi (MapOk.sub hm (sub_of_all bodySub95)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk95 r hr) hi hm ho hq)
    bodyLq95 rfl bodyNrLo95 (postSub_sound bodyPost95)
    (Nat.le_of_ble_eq_true bodyDrop95) (by decide) (Nat.le_of_ble_eq_true bodyDropH95) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN95) (by decide)
    bodyDv95 bodyDe95 bodyDl95 bodyDold95 bodyDfree95 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
