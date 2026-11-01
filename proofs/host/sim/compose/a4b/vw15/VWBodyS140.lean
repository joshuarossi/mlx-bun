import host.sim.compose.a4b.vw15.VWBodyJ140
import host.sim.compose.a4b.vw15.VWBodySite140
import host.sim.compose.a4b.vw15.VWBodyOracles_35
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

theorem bodyCshift140 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1351.tab.length PRE_first_tail_x15_r0_body.s1351.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P140.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P140 6040 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.s1353.ffi PRE_first_tail_x15_r0_body.s1352.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_140
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_140
  have hcl : SSt (· < 6040) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1351.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_140] <;> decide) PRE_first_tail_x15_r0_body.cnodesK140 PRE_first_tail_x15_r0_body.cobjsK140
      PRE_first_tail_x15_r0_body.citemsK140 PRE_first_tail_x15_r0_body.cbd140 PRE_first_tail_x15_r0_body.csst140
  exact PRE_first_tail_x15_r0_body.cshift140 bodyNcl140 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_140] at this; exact this)


kernel_rfl bodyFramesEmpty140 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1352 a).isEmpty) = true
kernel_rfl bodyJsRoots140 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1351.next) PRE_first_tail_x15_r0_body.s1353.trace PRE_first_tail_x15_r0_body.s1353 = true
kernel_rfl bodyJsNative140 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1353.ffi) = true
kernel_rfl bodyLow140 : (PRE_first_tail_x15_r0_body.cws140 ++ PRE_first_tail_x15_r0_body.ws140).all (Nat.ble 9) = true
kernel_rfl bodyCntM140 : countersOkB PRE_first_tail_x15_r0_body.s1351 PRE_first_tail_x15_r0_body.s1352 = true
kernel_rfl bodyHi140 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1353.ffi).next setupP.E = true
kernel_rfl bodyNhi140 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1353.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge140 : bridgeOf PRE_first_tail_x15_r0_body.s1352.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1351.ffi
kernel_rfl bodyNN140 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1351.ffi).nnext PRE_first_tail_x15_r0_body.P140.NL = true
kernel_rfl bodyXn140 : Nat.ble (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1353.ffi).next = true
kernel_rfl bodyLo140 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1353.ffi).next = true
theorem bodyFacts140 : BodySiteFacts PRE_first_tail_x15_r0_body.s1351 PRE_first_tail_x15_r0_body.s1352 PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1351 PRE_first_tail_x15_r0_body.S1352 PRE_first_tail_x15_r0_body.S1353
    PRE_first_tail_x15_r0_body.ws140 PRE_first_tail_x15_r0_body.cws140 PRE_first_tail_x15_r0_body.nr140 PRE_first_tail_x15_r0_body.pl140 PRE_first_tail_x15_r0_body.cl140 2784355 6040 PRE_first_tail_x15_r0_body.kd140 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.P140
    ⟨20949, 18055, 2784335, 6040⟩ ⟨20949, 18055, 2784336, 6040⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap140
  clean := bodyClean140
  cfix := PRE_first_tail_x15_r0_body.cfix140
  zpl := PRE_first_tail_x15_r0_body.zpl140
  zplnd := PRE_first_tail_x15_r0_body.zplnd140
  zn1 := PRE_first_tail_x15_r0_body.zn1140
  zfirst := PRE_first_tail_x15_r0_body.zfirst140
  zscn := PRE_first_tail_x15_r0_body.zscn140
  zsmn := PRE_first_tail_x15_r0_body.zsmn140
  zgrow := PRE_first_tail_x15_r0_body.zgrow140
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab140
  zfresh := PRE_first_tail_x15_r0_body.zfresh140
  zcnd := PRE_first_tail_x15_r0_body.zcnd140
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi140
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt140
  zgP := PRE_first_tail_x15_r0_body.zg140_2665
  zkP := PRE_first_tail_x15_r0_body.zk140_2665
  zmP := PRE_first_tail_x15_r0_body.zm140_2665
  zgC := PRE_first_tail_x15_r0_body.zg140_2673467
  zkC := PRE_first_tail_x15_r0_body.zk140_2673467
  zmC := PRE_first_tail_x15_r0_body.zm140_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw140_2673472
  zwV := PRE_first_tail_x15_r0_body.zw140_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap140
  zclbd := PRE_first_tail_x15_r0_body.zclbd140
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap140 PRE_first_tail_x15_r0_body.stFoot140 PRE_first_tail_x15_r0_body.iso140 PRE_first_tail_x15_r0_body.zwr140
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP140
  csupp := PRE_first_tail_x15_r0_body.csupp140
  cbound := PRE_first_tail_x15_r0_body.cbound140
  zimg := PRE_first_tail_x15_r0_body.zimg140
  zctl := PRE_first_tail_x15_r0_body.zctl140
  zstack := PRE_first_tail_x15_r0_body.zstack140
  zjobs := PRE_first_tail_x15_r0_body.zjobs140
  zstores := PRE_first_tail_x15_r0_body.zstores140
  zroots := PRE_first_tail_x15_r0_body.zroots140
  znC := PRE_first_tail_x15_r0_body.znC140
  ctab := PRE_first_tail_x15_r0_body.ctab140
  zbin := PRE_first_tail_x15_r0_body.zbin140
  cbridge := PRE_first_tail_x15_r0_body.cbridge140
  sbridge := bodyBridge140
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj140
  cshiftR := fun h hNL => bodyCshift140 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN140
  raised := PRE_first_tail_x15_r0_body.raised140
  cbigs := PRE_first_tail_x15_r0_body.cbigs140
  cjcl := PRE_first_tail_x15_r0_body.cjcl140
  xnLe := Nat.le_of_ble_eq_true bodyXn140
  loLe := Nat.le_of_ble_eq_true bodyLo140
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB140
  cntM := bodyCntM140
  hiLe := Nat.le_of_ble_eq_true bodyHi140
  nhiLe := Nat.le_of_ble_eq_true bodyNhi140
  jsHeap := bodyJs140
  jsRoots := bodyJsRoots140
  jsNative := bodyJsNative140
  framesEmpty := bodyFramesEmpty140
  trailOld := by decide
  lowVars := bodyLow140

def bodyQs140 : List (Option Q) := []
noncomputable def bodyEs140 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr140.map fun r => nth? PRE_first_tail_x15_r0_body.st140.S2.tab r
kernel_rfl bodyResChk140 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs140 bodyQs140) = true
kernel_rfl bodyLq140 : bodyQs140.length = PRE_first_tail_x15_r0_body.cws140.length
kernel_rfl bodyNrLo140 : PRE_first_tail_x15_r0_body.nr140.all (Nat.ble PRE_first_tail_x15_r0_body.S1351.tab.length) = true
kernel_rfl bodySub140 : (Oracles.PRE_first_tail_x15_r0_body.map_site140.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost140 : postSubB bodyM PRE_first_tail_x15_r0_body.ws140 PRE_first_tail_x15_r0_body.cws140 bodyQs140 = true
kernel_rfl bodyDrop140 : Nat.ble (49990 + (PRE_first_tail_x15_r0_body.s1352.next - PRE_first_tail_x15_r0_body.s1353.next)) 50009 = true
kernel_rfl bodyDropH140 : Nat.ble (943 + ((mlxOf PRE_first_tail_x15_r0_body.s1352.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1353.ffi).next)) 943 = true
kernel_rfl bodyDropN140 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1352.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1353.ffi).nnext)) 0 = true
kernel_rfl bodyDv140 : bodyΘ.1.take 747 = bodyΘ.1.take 747 ++ PRE_first_tail_x15_r0_body.cws140
kernel_rfl bodyDe140 : bodyΘ.2.take 747 = bodyΘ.2.take 747 ++ PRE_first_tail_x15_r0_body.nr140.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st140.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 747) (bodyΘ.2.take 747)))
kernel_rfl bodyDl140 : (bodyΘ.1.take 747).length = (bodyΘ.2.take 747).length
kernel_rfl bodyDold140 : (bodyΘ.1.take 747).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws140).isNone && !PRE_first_tail_x15_r0_body.ws140.contains v) = true
kernel_rfl bodyDfree140 : (bodyΘ.2.take 747).all (fun e => (PRE_first_tail_x15_r0_body.cws140 ++ PRE_first_tail_x15_r0_body.ws140).all fun w => e.noVar w) = true

theorem bodyStep140 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨49990, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1351 PRE_first_tail_x15_r0_body.S1351)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50009, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.S1353) (206 + 1) :=
  bodySite bodyFacts140.cfix bodyFacts140.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st140.S2.tab) (Es := bodyEs140) (qs := bodyQs140)
    (ok := PRE_first_tail_x15_r0_body.st140.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site140 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts140
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site140 r hr) hi (MapOk.sub hm (sub_of_all bodySub140)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk140 r hr) hi hm ho hq)
    bodyLq140 rfl bodyNrLo140 (postSub_sound bodyPost140)
    (Nat.le_of_ble_eq_true bodyDrop140) (by decide) (Nat.le_of_ble_eq_true bodyDropH140) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN140) (by decide)
    bodyDv140 bodyDe140 bodyDl140 bodyDold140 bodyDfree140 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
