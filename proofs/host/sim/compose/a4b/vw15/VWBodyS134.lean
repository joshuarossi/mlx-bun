import host.sim.compose.a4b.vw15.VWBodyJ134
import host.sim.compose.a4b.vw15.VWBodySite134
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

theorem bodyCshift134 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1293.tab.length PRE_first_tail_x15_r0_body.s1293.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P134.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P134 5782 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.s1295.ffi PRE_first_tail_x15_r0_body.s1294.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_134
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_134
  have hcl : SSt (· < 5782) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1293.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_134] <;> decide) PRE_first_tail_x15_r0_body.cnodesK134 PRE_first_tail_x15_r0_body.cobjsK134
      PRE_first_tail_x15_r0_body.citemsK134 PRE_first_tail_x15_r0_body.cbd134 PRE_first_tail_x15_r0_body.csst134
  exact PRE_first_tail_x15_r0_body.cshift134 bodyNcl134 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_134] at this; exact this)


kernel_rfl bodyFramesEmpty134 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1294 a).isEmpty) = true
kernel_rfl bodyJsRoots134 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1293.next) PRE_first_tail_x15_r0_body.s1295.trace PRE_first_tail_x15_r0_body.s1295 = true
kernel_rfl bodyJsNative134 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1295.ffi) = true
kernel_rfl bodyLow134 : (PRE_first_tail_x15_r0_body.cws134 ++ PRE_first_tail_x15_r0_body.ws134).all (Nat.ble 9) = true
kernel_rfl bodyCntM134 : countersOkB PRE_first_tail_x15_r0_body.s1293 PRE_first_tail_x15_r0_body.s1294 = true
kernel_rfl bodyHi134 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1295.ffi).next setupP.E = true
kernel_rfl bodyNhi134 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1295.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge134 : bridgeOf PRE_first_tail_x15_r0_body.s1294.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1293.ffi
kernel_rfl bodyNN134 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1293.ffi).nnext PRE_first_tail_x15_r0_body.P134.NL = true
kernel_rfl bodyXn134 : Nat.ble (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1295.ffi).next = true
kernel_rfl bodyLo134 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1295.ffi).next = true
theorem bodyFacts134 : BodySiteFacts PRE_first_tail_x15_r0_body.s1293 PRE_first_tail_x15_r0_body.s1294 PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1293 PRE_first_tail_x15_r0_body.S1294 PRE_first_tail_x15_r0_body.S1295
    PRE_first_tail_x15_r0_body.ws134 PRE_first_tail_x15_r0_body.cws134 PRE_first_tail_x15_r0_body.nr134 PRE_first_tail_x15_r0_body.pl134 PRE_first_tail_x15_r0_body.cl134 2779830 5782 PRE_first_tail_x15_r0_body.kd134 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.P134
    ⟨20835, 17929, 2779819, 5782⟩ ⟨20835, 17929, 2779820, 5782⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap134
  clean := bodyClean134
  cfix := PRE_first_tail_x15_r0_body.cfix134
  zpl := PRE_first_tail_x15_r0_body.zpl134
  zplnd := PRE_first_tail_x15_r0_body.zplnd134
  zn1 := PRE_first_tail_x15_r0_body.zn1134
  zfirst := PRE_first_tail_x15_r0_body.zfirst134
  zscn := PRE_first_tail_x15_r0_body.zscn134
  zsmn := PRE_first_tail_x15_r0_body.zsmn134
  zgrow := PRE_first_tail_x15_r0_body.zgrow134
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab134
  zfresh := PRE_first_tail_x15_r0_body.zfresh134
  zcnd := PRE_first_tail_x15_r0_body.zcnd134
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi134
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt134
  zgP := PRE_first_tail_x15_r0_body.zg134_2665
  zkP := PRE_first_tail_x15_r0_body.zk134_2665
  zmP := PRE_first_tail_x15_r0_body.zm134_2665
  zgC := PRE_first_tail_x15_r0_body.zg134_2673467
  zkC := PRE_first_tail_x15_r0_body.zk134_2673467
  zmC := PRE_first_tail_x15_r0_body.zm134_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw134_2673472
  zwV := PRE_first_tail_x15_r0_body.zw134_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap134
  zclbd := PRE_first_tail_x15_r0_body.zclbd134
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap134 PRE_first_tail_x15_r0_body.stFoot134 PRE_first_tail_x15_r0_body.iso134 PRE_first_tail_x15_r0_body.zwr134
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP134
  csupp := PRE_first_tail_x15_r0_body.csupp134
  cbound := PRE_first_tail_x15_r0_body.cbound134
  zimg := PRE_first_tail_x15_r0_body.zimg134
  zctl := PRE_first_tail_x15_r0_body.zctl134
  zstack := PRE_first_tail_x15_r0_body.zstack134
  zjobs := PRE_first_tail_x15_r0_body.zjobs134
  zstores := PRE_first_tail_x15_r0_body.zstores134
  zroots := PRE_first_tail_x15_r0_body.zroots134
  znC := PRE_first_tail_x15_r0_body.znC134
  ctab := PRE_first_tail_x15_r0_body.ctab134
  zbin := PRE_first_tail_x15_r0_body.zbin134
  cbridge := PRE_first_tail_x15_r0_body.cbridge134
  sbridge := bodyBridge134
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj134
  cshiftR := fun h hNL => bodyCshift134 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN134
  raised := PRE_first_tail_x15_r0_body.raised134
  cbigs := PRE_first_tail_x15_r0_body.cbigs134
  cjcl := PRE_first_tail_x15_r0_body.cjcl134
  xnLe := Nat.le_of_ble_eq_true bodyXn134
  loLe := Nat.le_of_ble_eq_true bodyLo134
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB134
  cntM := bodyCntM134
  hiLe := Nat.le_of_ble_eq_true bodyHi134
  nhiLe := Nat.le_of_ble_eq_true bodyNhi134
  jsHeap := bodyJs134
  jsRoots := bodyJsRoots134
  jsNative := bodyJsNative134
  framesEmpty := bodyFramesEmpty134
  trailOld := by decide
  lowVars := bodyLow134

def bodyQs134 : List (Option Q) := []
noncomputable def bodyEs134 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr134.map fun r => nth? PRE_first_tail_x15_r0_body.st134.S2.tab r
kernel_rfl bodyResChk134 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs134 bodyQs134) = true
kernel_rfl bodyLq134 : bodyQs134.length = PRE_first_tail_x15_r0_body.cws134.length
kernel_rfl bodyNrLo134 : PRE_first_tail_x15_r0_body.nr134.all (Nat.ble PRE_first_tail_x15_r0_body.S1293.tab.length) = true
kernel_rfl bodySub134 : (Oracles.PRE_first_tail_x15_r0_body.map_site134.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost134 : postSubB bodyM PRE_first_tail_x15_r0_body.ws134 PRE_first_tail_x15_r0_body.cws134 bodyQs134 = true
kernel_rfl bodyDrop134 : Nat.ble (47659 + (PRE_first_tail_x15_r0_body.s1294.next - PRE_first_tail_x15_r0_body.s1295.next)) 47669 = true
kernel_rfl bodyDropH134 : Nat.ble (893 + ((mlxOf PRE_first_tail_x15_r0_body.s1294.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1295.ffi).next)) 893 = true
kernel_rfl bodyDropN134 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1294.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1295.ffi).nnext)) 0 = true
kernel_rfl bodyDv134 : bodyΘ.1.take 711 = bodyΘ.1.take 711 ++ PRE_first_tail_x15_r0_body.cws134
kernel_rfl bodyDe134 : bodyΘ.2.take 711 = bodyΘ.2.take 711 ++ PRE_first_tail_x15_r0_body.nr134.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st134.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 711) (bodyΘ.2.take 711)))
kernel_rfl bodyDl134 : (bodyΘ.1.take 711).length = (bodyΘ.2.take 711).length
kernel_rfl bodyDold134 : (bodyΘ.1.take 711).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws134).isNone && !PRE_first_tail_x15_r0_body.ws134.contains v) = true
kernel_rfl bodyDfree134 : (bodyΘ.2.take 711).all (fun e => (PRE_first_tail_x15_r0_body.cws134 ++ PRE_first_tail_x15_r0_body.ws134).all fun w => e.noVar w) = true

theorem bodyStep134 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨47659, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1293 PRE_first_tail_x15_r0_body.S1293)
      (bodyCut NB T tk π i x0 bodyΘ ⟨47669, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.S1295) (98 + 1) :=
  bodySite bodyFacts134.cfix bodyFacts134.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st134.S2.tab) (Es := bodyEs134) (qs := bodyQs134)
    (ok := PRE_first_tail_x15_r0_body.st134.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site134 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts134
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site134 r hr) hi (MapOk.sub hm (sub_of_all bodySub134)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk134 r hr) hi hm ho hq)
    bodyLq134 rfl bodyNrLo134 (postSub_sound bodyPost134)
    (Nat.le_of_ble_eq_true bodyDrop134) (by decide) (Nat.le_of_ble_eq_true bodyDropH134) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN134) (by decide)
    bodyDv134 bodyDe134 bodyDl134 bodyDold134 bodyDfree134 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
