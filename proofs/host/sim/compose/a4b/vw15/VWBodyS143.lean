import host.sim.compose.a4b.vw15.VWBodyJ143
import host.sim.compose.a4b.vw15.VWBodySite143
import host.sim.compose.a4b.vw15.VWBodyOracles_35
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

theorem bodyCshift143 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1379.tab.length PRE_first_tail_x15_r0_body.s1379.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P143.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P143 6166 PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.s1381.ffi PRE_first_tail_x15_r0_body.s1380.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_143
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_143
  have hcl : SSt (· < 6166) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1379.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_143] <;> decide) PRE_first_tail_x15_r0_body.cnodesK143 PRE_first_tail_x15_r0_body.cobjsK143
      PRE_first_tail_x15_r0_body.citemsK143 PRE_first_tail_x15_r0_body.cbd143 PRE_first_tail_x15_r0_body.csst143
  exact PRE_first_tail_x15_r0_body.cshift143 bodyNcl143 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_143] at this; exact this)


kernel_rfl bodyFramesEmpty143 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1380 a).isEmpty) = true
kernel_rfl bodyJsRoots143 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1379.next) PRE_first_tail_x15_r0_body.s1381.trace PRE_first_tail_x15_r0_body.s1381 = true
kernel_rfl bodyJsNative143 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1381.ffi) = true
kernel_rfl bodyLow143 : (PRE_first_tail_x15_r0_body.cws143 ++ PRE_first_tail_x15_r0_body.ws143).all (Nat.ble 9) = true
kernel_rfl bodyCntM143 : countersOkB PRE_first_tail_x15_r0_body.s1379 PRE_first_tail_x15_r0_body.s1380 = true
kernel_rfl bodyHi143 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1381.ffi).next setupP.E = true
kernel_rfl bodyNhi143 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1381.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge143 : bridgeOf PRE_first_tail_x15_r0_body.s1380.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1379.ffi
kernel_rfl bodyNN143 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1379.ffi).nnext PRE_first_tail_x15_r0_body.P143.NL = true
kernel_rfl bodyXn143 : Nat.ble (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1381.ffi).next = true
kernel_rfl bodyLo143 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1381.ffi).next = true
theorem bodyFacts143 : BodySiteFacts PRE_first_tail_x15_r0_body.s1379 PRE_first_tail_x15_r0_body.s1380 PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1379 PRE_first_tail_x15_r0_body.S1380 PRE_first_tail_x15_r0_body.S1381
    PRE_first_tail_x15_r0_body.ws143 PRE_first_tail_x15_r0_body.cws143 PRE_first_tail_x15_r0_body.nr143 PRE_first_tail_x15_r0_body.pl143 PRE_first_tail_x15_r0_body.cl143 2786981 6166 PRE_first_tail_x15_r0_body.kd143 PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.P143
    ⟨21013, 18103, 2786961, 6166⟩ ⟨21013, 18103, 2786962, 6166⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap143
  clean := bodyClean143
  cfix := PRE_first_tail_x15_r0_body.cfix143
  zpl := PRE_first_tail_x15_r0_body.zpl143
  zplnd := PRE_first_tail_x15_r0_body.zplnd143
  zn1 := PRE_first_tail_x15_r0_body.zn1143
  zfirst := PRE_first_tail_x15_r0_body.zfirst143
  zscn := PRE_first_tail_x15_r0_body.zscn143
  zsmn := PRE_first_tail_x15_r0_body.zsmn143
  zgrow := PRE_first_tail_x15_r0_body.zgrow143
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab143
  zfresh := PRE_first_tail_x15_r0_body.zfresh143
  zcnd := PRE_first_tail_x15_r0_body.zcnd143
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi143
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt143
  zgP := PRE_first_tail_x15_r0_body.zg143_2665
  zkP := PRE_first_tail_x15_r0_body.zk143_2665
  zmP := PRE_first_tail_x15_r0_body.zm143_2665
  zgC := PRE_first_tail_x15_r0_body.zg143_2673467
  zkC := PRE_first_tail_x15_r0_body.zk143_2673467
  zmC := PRE_first_tail_x15_r0_body.zm143_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw143_2673472
  zwV := PRE_first_tail_x15_r0_body.zw143_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap143
  zclbd := PRE_first_tail_x15_r0_body.zclbd143
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap143 PRE_first_tail_x15_r0_body.stFoot143 PRE_first_tail_x15_r0_body.iso143 PRE_first_tail_x15_r0_body.zwr143
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP143
  csupp := PRE_first_tail_x15_r0_body.csupp143
  cbound := PRE_first_tail_x15_r0_body.cbound143
  zimg := PRE_first_tail_x15_r0_body.zimg143
  zctl := PRE_first_tail_x15_r0_body.zctl143
  zstack := PRE_first_tail_x15_r0_body.zstack143
  zjobs := PRE_first_tail_x15_r0_body.zjobs143
  zstores := PRE_first_tail_x15_r0_body.zstores143
  zroots := PRE_first_tail_x15_r0_body.zroots143
  znC := PRE_first_tail_x15_r0_body.znC143
  ctab := PRE_first_tail_x15_r0_body.ctab143
  zbin := PRE_first_tail_x15_r0_body.zbin143
  cbridge := PRE_first_tail_x15_r0_body.cbridge143
  sbridge := bodyBridge143
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj143
  cshiftR := fun h hNL => bodyCshift143 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN143
  raised := PRE_first_tail_x15_r0_body.raised143
  cbigs := PRE_first_tail_x15_r0_body.cbigs143
  cjcl := PRE_first_tail_x15_r0_body.cjcl143
  xnLe := Nat.le_of_ble_eq_true bodyXn143
  loLe := Nat.le_of_ble_eq_true bodyLo143
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB143
  cntM := bodyCntM143
  hiLe := Nat.le_of_ble_eq_true bodyHi143
  nhiLe := Nat.le_of_ble_eq_true bodyNhi143
  jsHeap := bodyJs143
  jsRoots := bodyJsRoots143
  jsNative := bodyJsNative143
  framesEmpty := bodyFramesEmpty143
  trailOld := by decide
  lowVars := bodyLow143

def bodyQs143 : List (Option Q) := []
noncomputable def bodyEs143 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr143.map fun r => nth? PRE_first_tail_x15_r0_body.st143.S2.tab r
kernel_rfl bodyResChk143 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs143 bodyQs143) = true
kernel_rfl bodyLq143 : bodyQs143.length = PRE_first_tail_x15_r0_body.cws143.length
kernel_rfl bodyNrLo143 : PRE_first_tail_x15_r0_body.nr143.all (Nat.ble PRE_first_tail_x15_r0_body.S1379.tab.length) = true
kernel_rfl bodySub143 : (Oracles.PRE_first_tail_x15_r0_body.map_site143.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost143 : postSubB bodyM PRE_first_tail_x15_r0_body.ws143 PRE_first_tail_x15_r0_body.cws143 bodyQs143 = true
kernel_rfl bodyDrop143 : Nat.ble (50361 + (PRE_first_tail_x15_r0_body.s1380.next - PRE_first_tail_x15_r0_body.s1381.next)) 50380 = true
kernel_rfl bodyDropH143 : Nat.ble (945 + ((mlxOf PRE_first_tail_x15_r0_body.s1380.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1381.ffi).next)) 945 = true
kernel_rfl bodyDropN143 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1380.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1381.ffi).nnext)) 0 = true
kernel_rfl bodyDv143 : bodyΘ.1.take 756 = bodyΘ.1.take 756 ++ PRE_first_tail_x15_r0_body.cws143
kernel_rfl bodyDe143 : bodyΘ.2.take 756 = bodyΘ.2.take 756 ++ PRE_first_tail_x15_r0_body.nr143.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st143.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 756) (bodyΘ.2.take 756)))
kernel_rfl bodyDl143 : (bodyΘ.1.take 756).length = (bodyΘ.2.take 756).length
kernel_rfl bodyDold143 : (bodyΘ.1.take 756).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws143).isNone && !PRE_first_tail_x15_r0_body.ws143.contains v) = true
kernel_rfl bodyDfree143 : (bodyΘ.2.take 756).all (fun e => (PRE_first_tail_x15_r0_body.cws143 ++ PRE_first_tail_x15_r0_body.ws143).all fun w => e.noVar w) = true

theorem bodyStep143 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50361, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1379 PRE_first_tail_x15_r0_body.S1379)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50380, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.S1381) (206 + 1) :=
  bodySite bodyFacts143.cfix bodyFacts143.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st143.S2.tab) (Es := bodyEs143) (qs := bodyQs143)
    (ok := PRE_first_tail_x15_r0_body.st143.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site143 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts143
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site143 r hr) hi (MapOk.sub hm (sub_of_all bodySub143)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk143 r hr) hi hm ho hq)
    bodyLq143 rfl bodyNrLo143 (postSub_sound bodyPost143)
    (Nat.le_of_ble_eq_true bodyDrop143) (by decide) (Nat.le_of_ble_eq_true bodyDropH143) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN143) (by decide)
    bodyDv143 bodyDe143 bodyDl143 bodyDold143 bodyDfree143 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
