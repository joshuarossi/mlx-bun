import host.sim.compose.a4b.vw15.VWBodyJ54
import host.sim.compose.a4b.vw15.VWBodySite54
import host.sim.compose.a4b.vw15.VWBodyOracles_13
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

theorem bodyCshift54 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S534.tab.length PRE_first_tail_x15_r0_body.s534.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P54.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.s536.ffi PRE_first_tail_x15_r0_body.s535.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_54
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_54
  have hcl : SSt (· < 2411) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S534.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_54] <;> decide) PRE_first_tail_x15_r0_body.cnodesK54 PRE_first_tail_x15_r0_body.cobjsK54
      PRE_first_tail_x15_r0_body.citemsK54 PRE_first_tail_x15_r0_body.cbd54 PRE_first_tail_x15_r0_body.csst54
  exact PRE_first_tail_x15_r0_body.cshift54 bodyNcl54 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_54] at this; exact this)


kernel_rfl bodyFramesEmpty54 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s535 a).isEmpty) = true
kernel_rfl bodyJsRoots54 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s534.next) PRE_first_tail_x15_r0_body.s536.trace PRE_first_tail_x15_r0_body.s536 = true
kernel_rfl bodyJsNative54 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s536.ffi) = true
kernel_rfl bodyLow54 : (PRE_first_tail_x15_r0_body.cws54 ++ PRE_first_tail_x15_r0_body.ws54).all (Nat.ble 9) = true
kernel_rfl bodyCntM54 : countersOkB PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.s535 = true
kernel_rfl bodyHi54 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).next setupP.E = true
kernel_rfl bodyNhi54 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge54 : bridgeOf PRE_first_tail_x15_r0_body.s535.ffi = bridgeOf PRE_first_tail_x15_r0_body.s534.ffi
kernel_rfl bodyNN54 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s534.ffi).nnext PRE_first_tail_x15_r0_body.P54.NL = true
kernel_rfl bodyXn54 : Nat.ble (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).next = true
kernel_rfl bodyLo54 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).next = true
theorem bodyFacts54 : BodySiteFacts PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.s535 PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S534 PRE_first_tail_x15_r0_body.S535 PRE_first_tail_x15_r0_body.S536
    PRE_first_tail_x15_r0_body.ws54 PRE_first_tail_x15_r0_body.cws54 PRE_first_tail_x15_r0_body.nr54 PRE_first_tail_x15_r0_body.pl54 PRE_first_tail_x15_r0_body.cl54 2718798 2411 PRE_first_tail_x15_r0_body.kd54 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.P54
    ⟨19274, 16352, 2717643, 2393⟩ ⟨19277, 16379, 2717649, 2411⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap54
  clean := bodyClean54
  cfix := PRE_first_tail_x15_r0_body.cfix54
  zpl := PRE_first_tail_x15_r0_body.zpl54
  zplnd := PRE_first_tail_x15_r0_body.zplnd54
  zn1 := PRE_first_tail_x15_r0_body.zn154
  zfirst := PRE_first_tail_x15_r0_body.zfirst54
  zscn := PRE_first_tail_x15_r0_body.zscn54
  zsmn := PRE_first_tail_x15_r0_body.zsmn54
  zgrow := PRE_first_tail_x15_r0_body.zgrow54
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab54
  zfresh := PRE_first_tail_x15_r0_body.zfresh54
  zcnd := PRE_first_tail_x15_r0_body.zcnd54
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi54
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt54
  zgP := PRE_first_tail_x15_r0_body.zg54_2665
  zkP := PRE_first_tail_x15_r0_body.zk54_2665
  zmP := PRE_first_tail_x15_r0_body.zm54_2665
  zgC := PRE_first_tail_x15_r0_body.zg54_2673467
  zkC := PRE_first_tail_x15_r0_body.zk54_2673467
  zmC := PRE_first_tail_x15_r0_body.zm54_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw54_2673472
  zwV := PRE_first_tail_x15_r0_body.zw54_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap54
  zclbd := PRE_first_tail_x15_r0_body.zclbd54
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap54 PRE_first_tail_x15_r0_body.stFoot54 PRE_first_tail_x15_r0_body.iso54 PRE_first_tail_x15_r0_body.zwr54
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP54
  csupp := PRE_first_tail_x15_r0_body.csupp54
  cbound := PRE_first_tail_x15_r0_body.cbound54
  zimg := PRE_first_tail_x15_r0_body.zimg54
  zctl := PRE_first_tail_x15_r0_body.zctl54
  zstack := PRE_first_tail_x15_r0_body.zstack54
  zjobs := PRE_first_tail_x15_r0_body.zjobs54
  zstores := PRE_first_tail_x15_r0_body.zstores54
  zroots := PRE_first_tail_x15_r0_body.zroots54
  znC := PRE_first_tail_x15_r0_body.znC54
  ctab := PRE_first_tail_x15_r0_body.ctab54
  zbin := PRE_first_tail_x15_r0_body.zbin54
  cbridge := PRE_first_tail_x15_r0_body.cbridge54
  sbridge := bodyBridge54
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj54
  cshiftR := fun h hNL => bodyCshift54 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN54
  raised := PRE_first_tail_x15_r0_body.raised54
  cbigs := PRE_first_tail_x15_r0_body.cbigs54
  cjcl := PRE_first_tail_x15_r0_body.cjcl54
  xnLe := Nat.le_of_ble_eq_true bodyXn54
  loLe := Nat.le_of_ble_eq_true bodyLo54
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB54
  cntM := bodyCntM54
  hiLe := Nat.le_of_ble_eq_true bodyHi54
  nhiLe := Nat.le_of_ble_eq_true bodyNhi54
  jsHeap := bodyJs54
  jsRoots := bodyJsRoots54
  jsNative := bodyJsNative54
  framesEmpty := bodyFramesEmpty54
  trailOld := by decide
  lowVars := bodyLow54

def bodyQs54 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs54 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr54.map fun r => nth? PRE_first_tail_x15_r0_body.st54.S5.tab r
kernel_rfl bodyResChk54 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs54 bodyQs54) = true
kernel_rfl bodyLq54 : bodyQs54.length = PRE_first_tail_x15_r0_body.cws54.length
kernel_rfl bodyNrLo54 : PRE_first_tail_x15_r0_body.nr54.all (Nat.ble PRE_first_tail_x15_r0_body.S534.tab.length) = true
kernel_rfl bodySub54 : (Oracles.PRE_first_tail_x15_r0_body.map_site54.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost54 : postSubB bodyM PRE_first_tail_x15_r0_body.ws54 PRE_first_tail_x15_r0_body.cws54 bodyQs54 = true
kernel_rfl bodyDrop54 : Nat.ble (21870 + (PRE_first_tail_x15_r0_body.s535.next - PRE_first_tail_x15_r0_body.s536.next)) 23019 = true
kernel_rfl bodyDropH54 : Nat.ble (379 + ((mlxOf PRE_first_tail_x15_r0_body.s535.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).next)) 404 = true
kernel_rfl bodyDropN54 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s535.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s536.ffi).nnext)) 0 = true
kernel_rfl bodyDv54 : bodyΘ.1.take 306 = bodyΘ.1.take 288 ++ PRE_first_tail_x15_r0_body.cws54
kernel_rfl bodyDe54 : bodyΘ.2.take 306 = bodyΘ.2.take 288 ++ PRE_first_tail_x15_r0_body.nr54.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st54.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 288) (bodyΘ.2.take 288)))
kernel_rfl bodyDl54 : (bodyΘ.1.take 288).length = (bodyΘ.2.take 288).length
kernel_rfl bodyDold54 : (bodyΘ.1.take 288).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws54).isNone && !PRE_first_tail_x15_r0_body.ws54.contains v) = true
kernel_rfl bodyDfree54 : (bodyΘ.2.take 306).all (fun e => (PRE_first_tail_x15_r0_body.cws54 ++ PRE_first_tail_x15_r0_body.ws54).all fun w => e.noVar w) = true

theorem bodyStep54 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21870, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.S534)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23019, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.S536) (11334 + 1) :=
  bodySite bodyFacts54.cfix bodyFacts54.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st54.S5.tab) (Es := bodyEs54) (qs := bodyQs54)
    (ok := PRE_first_tail_x15_r0_body.st54.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site54 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts54
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site54 r hr) hi (MapOk.sub hm (sub_of_all bodySub54)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk54 r hr) hi hm ho hq)
    bodyLq54 rfl bodyNrLo54 (postSub_sound bodyPost54)
    (Nat.le_of_ble_eq_true bodyDrop54) (by decide) (Nat.le_of_ble_eq_true bodyDropH54) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN54) (by decide)
    bodyDv54 bodyDe54 bodyDl54 bodyDold54 bodyDfree54 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
