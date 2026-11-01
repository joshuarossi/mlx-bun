import host.sim.compose.a4b.vw15.VWBodyJ145
import host.sim.compose.a4b.vw15.VWBodySite145
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

theorem bodyCshift145 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1404.tab.length PRE_first_tail_x15_r0_body.s1404.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P145.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P145 6278 PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.s1406.ffi PRE_first_tail_x15_r0_body.s1405.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_145
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_145
  have hcl : SSt (· < 6278) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1404.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_145] <;> decide) PRE_first_tail_x15_r0_body.cnodesK145 PRE_first_tail_x15_r0_body.cobjsK145
      PRE_first_tail_x15_r0_body.citemsK145 PRE_first_tail_x15_r0_body.cbd145 PRE_first_tail_x15_r0_body.csst145
  exact PRE_first_tail_x15_r0_body.cshift145 bodyNcl145 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_145] at this; exact this)


kernel_rfl bodyFramesEmpty145 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1405 a).isEmpty) = true
kernel_rfl bodyJsRoots145 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1404.next) PRE_first_tail_x15_r0_body.s1406.trace PRE_first_tail_x15_r0_body.s1406 = true
kernel_rfl bodyJsNative145 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1406.ffi) = true
kernel_rfl bodyLow145 : (PRE_first_tail_x15_r0_body.cws145 ++ PRE_first_tail_x15_r0_body.ws145).all (Nat.ble 9) = true
kernel_rfl bodyCntM145 : countersOkB PRE_first_tail_x15_r0_body.s1404 PRE_first_tail_x15_r0_body.s1405 = true
kernel_rfl bodyHi145 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1406.ffi).next setupP.E = true
kernel_rfl bodyNhi145 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1406.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge145 : bridgeOf PRE_first_tail_x15_r0_body.s1405.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1404.ffi
kernel_rfl bodyNN145 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1404.ffi).nnext PRE_first_tail_x15_r0_body.P145.NL = true
kernel_rfl bodyXn145 : Nat.ble (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1406.ffi).next = true
kernel_rfl bodyLo145 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1406.ffi).next = true
theorem bodyFacts145 : BodySiteFacts PRE_first_tail_x15_r0_body.s1404 PRE_first_tail_x15_r0_body.s1405 PRE_first_tail_x15_r0_body.s1406 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1404 PRE_first_tail_x15_r0_body.S1405 PRE_first_tail_x15_r0_body.S1406
    PRE_first_tail_x15_r0_body.ws145 PRE_first_tail_x15_r0_body.cws145 PRE_first_tail_x15_r0_body.nr145 PRE_first_tail_x15_r0_body.pl145 PRE_first_tail_x15_r0_body.cl145 2788957 6278 PRE_first_tail_x15_r0_body.kd145 PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.P145
    ⟨21064, 18162, 2788955, 6278⟩ ⟨21064, 18162, 2788955, 6278⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap145
  clean := bodyClean145
  cfix := PRE_first_tail_x15_r0_body.cfix145
  zpl := PRE_first_tail_x15_r0_body.zpl145
  zplnd := PRE_first_tail_x15_r0_body.zplnd145
  zn1 := PRE_first_tail_x15_r0_body.zn1145
  zfirst := PRE_first_tail_x15_r0_body.zfirst145
  zscn := PRE_first_tail_x15_r0_body.zscn145
  zsmn := PRE_first_tail_x15_r0_body.zsmn145
  zgrow := PRE_first_tail_x15_r0_body.zgrow145
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab145
  zfresh := PRE_first_tail_x15_r0_body.zfresh145
  zcnd := PRE_first_tail_x15_r0_body.zcnd145
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi145
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt145
  zgP := PRE_first_tail_x15_r0_body.zg145_2665
  zkP := PRE_first_tail_x15_r0_body.zk145_2665
  zmP := PRE_first_tail_x15_r0_body.zm145_2665
  zgC := PRE_first_tail_x15_r0_body.zg145_2673467
  zkC := PRE_first_tail_x15_r0_body.zk145_2673467
  zmC := PRE_first_tail_x15_r0_body.zm145_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw145_2673472
  zwV := PRE_first_tail_x15_r0_body.zw145_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap145
  zclbd := PRE_first_tail_x15_r0_body.zclbd145
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap145 PRE_first_tail_x15_r0_body.stFoot145 PRE_first_tail_x15_r0_body.iso145 PRE_first_tail_x15_r0_body.zwr145
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP145
  csupp := PRE_first_tail_x15_r0_body.csupp145
  cbound := PRE_first_tail_x15_r0_body.cbound145
  zimg := PRE_first_tail_x15_r0_body.zimg145
  zctl := PRE_first_tail_x15_r0_body.zctl145
  zstack := PRE_first_tail_x15_r0_body.zstack145
  zjobs := PRE_first_tail_x15_r0_body.zjobs145
  zstores := PRE_first_tail_x15_r0_body.zstores145
  zroots := PRE_first_tail_x15_r0_body.zroots145
  znC := PRE_first_tail_x15_r0_body.znC145
  ctab := PRE_first_tail_x15_r0_body.ctab145
  zbin := PRE_first_tail_x15_r0_body.zbin145
  cbridge := PRE_first_tail_x15_r0_body.cbridge145
  sbridge := bodyBridge145
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj145
  cshiftR := fun h hNL => bodyCshift145 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN145
  raised := PRE_first_tail_x15_r0_body.raised145
  cbigs := PRE_first_tail_x15_r0_body.cbigs145
  cjcl := PRE_first_tail_x15_r0_body.cjcl145
  xnLe := Nat.le_of_ble_eq_true bodyXn145
  loLe := Nat.le_of_ble_eq_true bodyLo145
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB145
  cntM := bodyCntM145
  hiLe := Nat.le_of_ble_eq_true bodyHi145
  nhiLe := Nat.le_of_ble_eq_true bodyNhi145
  jsHeap := bodyJs145
  jsRoots := bodyJsRoots145
  jsNative := bodyJsNative145
  framesEmpty := bodyFramesEmpty145
  trailOld := by decide
  lowVars := bodyLow145

def bodyQs145 : List (Option Q) := []
noncomputable def bodyEs145 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr145.map fun r => nth? PRE_first_tail_x15_r0_body.st145.S2.tab r
kernel_rfl bodyResChk145 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs145 bodyQs145) = true
kernel_rfl bodyLq145 : bodyQs145.length = PRE_first_tail_x15_r0_body.cws145.length
kernel_rfl bodyNrLo145 : PRE_first_tail_x15_r0_body.nr145.all (Nat.ble PRE_first_tail_x15_r0_body.S1404.tab.length) = true
kernel_rfl bodySub145 : (Oracles.PRE_first_tail_x15_r0_body.map_site145.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost145 : postSubB bodyM PRE_first_tail_x15_r0_body.ws145 PRE_first_tail_x15_r0_body.cws145 bodyQs145 = true
kernel_rfl bodyDrop145 : Nat.ble (51529 + (PRE_first_tail_x15_r0_body.s1405.next - PRE_first_tail_x15_r0_body.s1406.next)) 51531 = true
kernel_rfl bodyDropH145 : Nat.ble (970 + ((mlxOf PRE_first_tail_x15_r0_body.s1405.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1406.ffi).next)) 970 = true
kernel_rfl bodyDropN145 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1405.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1406.ffi).nnext)) 0 = true
kernel_rfl bodyDv145 : bodyΘ.1.take 774 = bodyΘ.1.take 774 ++ PRE_first_tail_x15_r0_body.cws145
kernel_rfl bodyDe145 : bodyΘ.2.take 774 = bodyΘ.2.take 774 ++ PRE_first_tail_x15_r0_body.nr145.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st145.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 774) (bodyΘ.2.take 774)))
kernel_rfl bodyDl145 : (bodyΘ.1.take 774).length = (bodyΘ.2.take 774).length
kernel_rfl bodyDold145 : (bodyΘ.1.take 774).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws145).isNone && !PRE_first_tail_x15_r0_body.ws145.contains v) = true
kernel_rfl bodyDfree145 : (bodyΘ.2.take 774).all (fun e => (PRE_first_tail_x15_r0_body.cws145 ++ PRE_first_tail_x15_r0_body.ws145).all fun w => e.noVar w) = true

theorem bodyStep145 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨51529, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1404 PRE_first_tail_x15_r0_body.S1404)
      (bodyCut NB T tk π i x0 bodyΘ ⟨51531, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1406 PRE_first_tail_x15_r0_body.S1406) (27 + 1) :=
  bodySite bodyFacts145.cfix bodyFacts145.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st145.S2.tab) (Es := bodyEs145) (qs := bodyQs145)
    (ok := PRE_first_tail_x15_r0_body.st145.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site145 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts145
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site145 r hr) hi (MapOk.sub hm (sub_of_all bodySub145)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk145 r hr) hi hm ho hq)
    bodyLq145 rfl bodyNrLo145 (postSub_sound bodyPost145)
    (Nat.le_of_ble_eq_true bodyDrop145) (by decide) (Nat.le_of_ble_eq_true bodyDropH145) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN145) (by decide)
    bodyDv145 bodyDe145 bodyDl145 bodyDold145 bodyDfree145 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
