import host.sim.compose.a4b.vw15.VWBodyJ43
import host.sim.compose.a4b.vw15.VWBodySite43
import host.sim.compose.a4b.vw15.VWBodyOracles_10
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift43 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S427.tab.length PRE_first_tail_x15_r0_body.s427.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P43.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P43 1919 PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.s429.ffi PRE_first_tail_x15_r0_body.s428.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_43
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_43
  have hcl : SSt (· < 1919) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S427.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_43] <;> decide) PRE_first_tail_x15_r0_body.cnodesK43 PRE_first_tail_x15_r0_body.cobjsK43
      PRE_first_tail_x15_r0_body.citemsK43 PRE_first_tail_x15_r0_body.cbd43 PRE_first_tail_x15_r0_body.csst43
  exact PRE_first_tail_x15_r0_body.cshift43 bodyNcl43 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_43] at this; exact this)


kernel_rfl bodyFramesEmpty43 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s428 a).isEmpty) = true
kernel_rfl bodyJsRoots43 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s427.next) PRE_first_tail_x15_r0_body.s429.trace PRE_first_tail_x15_r0_body.s429 = true
kernel_rfl bodyJsNative43 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s429.ffi) = true
kernel_rfl bodyLow43 : (PRE_first_tail_x15_r0_body.cws43 ++ PRE_first_tail_x15_r0_body.ws43).all (Nat.ble 9) = true
kernel_rfl bodyCntM43 : countersOkB PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.s428 = true
kernel_rfl bodyHi43 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).next setupP.E = true
kernel_rfl bodyNhi43 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge43 : bridgeOf PRE_first_tail_x15_r0_body.s428.ffi = bridgeOf PRE_first_tail_x15_r0_body.s427.ffi
kernel_rfl bodyNN43 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s427.ffi).nnext PRE_first_tail_x15_r0_body.P43.NL = true
kernel_rfl bodyXn43 : Nat.ble (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).next = true
kernel_rfl bodyLo43 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).next = true
theorem bodyFacts43 : BodySiteFacts PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.s428 PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S427 PRE_first_tail_x15_r0_body.S428 PRE_first_tail_x15_r0_body.S429
    PRE_first_tail_x15_r0_body.ws43 PRE_first_tail_x15_r0_body.cws43 PRE_first_tail_x15_r0_body.nr43 PRE_first_tail_x15_r0_body.pl43 PRE_first_tail_x15_r0_body.cl43 2708717 1919 PRE_first_tail_x15_r0_body.kd43 PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.P43
    ⟨19054, 16155, 2708715, 1919⟩ ⟨19054, 16155, 2708715, 1919⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap43
  clean := bodyClean43
  cfix := PRE_first_tail_x15_r0_body.cfix43
  zpl := PRE_first_tail_x15_r0_body.zpl43
  zplnd := PRE_first_tail_x15_r0_body.zplnd43
  zn1 := PRE_first_tail_x15_r0_body.zn143
  zfirst := PRE_first_tail_x15_r0_body.zfirst43
  zscn := PRE_first_tail_x15_r0_body.zscn43
  zsmn := PRE_first_tail_x15_r0_body.zsmn43
  zgrow := PRE_first_tail_x15_r0_body.zgrow43
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab43
  zfresh := PRE_first_tail_x15_r0_body.zfresh43
  zcnd := PRE_first_tail_x15_r0_body.zcnd43
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi43
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt43
  zgP := PRE_first_tail_x15_r0_body.zg43_2665
  zkP := PRE_first_tail_x15_r0_body.zk43_2665
  zmP := PRE_first_tail_x15_r0_body.zm43_2665
  zgC := PRE_first_tail_x15_r0_body.zg43_2673467
  zkC := PRE_first_tail_x15_r0_body.zk43_2673467
  zmC := PRE_first_tail_x15_r0_body.zm43_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw43_2673472
  zwV := PRE_first_tail_x15_r0_body.zw43_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap43
  zclbd := PRE_first_tail_x15_r0_body.zclbd43
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap43 PRE_first_tail_x15_r0_body.stFoot43 PRE_first_tail_x15_r0_body.iso43 PRE_first_tail_x15_r0_body.zwr43
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP43
  csupp := PRE_first_tail_x15_r0_body.csupp43
  cbound := PRE_first_tail_x15_r0_body.cbound43
  zimg := PRE_first_tail_x15_r0_body.zimg43
  zctl := PRE_first_tail_x15_r0_body.zctl43
  zstack := PRE_first_tail_x15_r0_body.zstack43
  zjobs := PRE_first_tail_x15_r0_body.zjobs43
  zstores := PRE_first_tail_x15_r0_body.zstores43
  zroots := PRE_first_tail_x15_r0_body.zroots43
  znC := PRE_first_tail_x15_r0_body.znC43
  ctab := PRE_first_tail_x15_r0_body.ctab43
  zbin := PRE_first_tail_x15_r0_body.zbin43
  cbridge := PRE_first_tail_x15_r0_body.cbridge43
  sbridge := bodyBridge43
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj43
  cshiftR := fun h hNL => bodyCshift43 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN43
  raised := PRE_first_tail_x15_r0_body.raised43
  cbigs := PRE_first_tail_x15_r0_body.cbigs43
  cjcl := PRE_first_tail_x15_r0_body.cjcl43
  xnLe := Nat.le_of_ble_eq_true bodyXn43
  loLe := Nat.le_of_ble_eq_true bodyLo43
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB43
  cntM := bodyCntM43
  hiLe := Nat.le_of_ble_eq_true bodyHi43
  nhiLe := Nat.le_of_ble_eq_true bodyNhi43
  jsHeap := bodyJs43
  jsRoots := bodyJsRoots43
  jsNative := bodyJsNative43
  framesEmpty := bodyFramesEmpty43
  trailOld := by decide
  lowVars := bodyLow43

def bodyQs43 : List (Option Q) := []
noncomputable def bodyEs43 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr43.map fun r => nth? PRE_first_tail_x15_r0_body.st43.S2.tab r
kernel_rfl bodyResChk43 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs43 bodyQs43) = true
kernel_rfl bodyLq43 : bodyQs43.length = PRE_first_tail_x15_r0_body.cws43.length
kernel_rfl bodyNrLo43 : PRE_first_tail_x15_r0_body.nr43.all (Nat.ble PRE_first_tail_x15_r0_body.S427.tab.length) = true
kernel_rfl bodySub43 : (Oracles.PRE_first_tail_x15_r0_body.map_site43.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost43 : postSubB bodyM PRE_first_tail_x15_r0_body.ws43 PRE_first_tail_x15_r0_body.cws43 bodyQs43 = true
kernel_rfl bodyDrop43 : Nat.ble (19147 + (PRE_first_tail_x15_r0_body.s428.next - PRE_first_tail_x15_r0_body.s429.next)) 19149 = true
kernel_rfl bodyDropH43 : Nat.ble (327 + ((mlxOf PRE_first_tail_x15_r0_body.s428.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).next)) 327 = true
kernel_rfl bodyDropN43 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s428.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s429.ffi).nnext)) 0 = true
kernel_rfl bodyDv43 : bodyΘ.1.take 243 = bodyΘ.1.take 243 ++ PRE_first_tail_x15_r0_body.cws43
kernel_rfl bodyDe43 : bodyΘ.2.take 243 = bodyΘ.2.take 243 ++ PRE_first_tail_x15_r0_body.nr43.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st43.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 243) (bodyΘ.2.take 243)))
kernel_rfl bodyDl43 : (bodyΘ.1.take 243).length = (bodyΘ.2.take 243).length
kernel_rfl bodyDold43 : (bodyΘ.1.take 243).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws43).isNone && !PRE_first_tail_x15_r0_body.ws43.contains v) = true
kernel_rfl bodyDfree43 : (bodyΘ.2.take 243).all (fun e => (PRE_first_tail_x15_r0_body.cws43 ++ PRE_first_tail_x15_r0_body.ws43).all fun w => e.noVar w) = true

theorem bodyStep43 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19147, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.S427)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19149, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.S429) (27 + 1) :=
  bodySite bodyFacts43.cfix bodyFacts43.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st43.S2.tab) (Es := bodyEs43) (qs := bodyQs43)
    (ok := PRE_first_tail_x15_r0_body.st43.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site43 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts43
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site43 r hr) hi (MapOk.sub hm (sub_of_all bodySub43)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk43 r hr) hi hm ho hq)
    bodyLq43 rfl bodyNrLo43 (postSub_sound bodyPost43)
    (Nat.le_of_ble_eq_true bodyDrop43) (by decide) (Nat.le_of_ble_eq_true bodyDropH43) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN43) (by decide)
    bodyDv43 bodyDe43 bodyDl43 bodyDold43 bodyDfree43 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
