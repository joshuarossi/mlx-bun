import host.sim.compose.a4b.vw15.VWBodyJ112
import host.sim.compose.a4b.vw15.VWBodySite112
import host.sim.compose.a4b.vw15.VWBodyOracles_28
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

theorem bodyCshift112 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1088.tab.length PRE_first_tail_x15_r0_body.s1088.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P112.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P112 4868 PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.s1090.ffi PRE_first_tail_x15_r0_body.s1089.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_112
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_112
  have hcl : SSt (· < 4868) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1090.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1088.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_112] <;> decide) PRE_first_tail_x15_r0_body.cnodesK112 PRE_first_tail_x15_r0_body.cobjsK112
      PRE_first_tail_x15_r0_body.citemsK112 PRE_first_tail_x15_r0_body.cbd112 PRE_first_tail_x15_r0_body.csst112
  exact PRE_first_tail_x15_r0_body.cshift112 bodyNcl112 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_112] at this; exact this)


kernel_rfl bodyFramesEmpty112 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1089 a).isEmpty) = true
kernel_rfl bodyJsRoots112 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1088.next) PRE_first_tail_x15_r0_body.s1090.trace PRE_first_tail_x15_r0_body.s1090 = true
kernel_rfl bodyJsNative112 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1090.ffi) = true
kernel_rfl bodyLow112 : (PRE_first_tail_x15_r0_body.cws112 ++ PRE_first_tail_x15_r0_body.ws112).all (Nat.ble 9) = true
kernel_rfl bodyCntM112 : countersOkB PRE_first_tail_x15_r0_body.s1088 PRE_first_tail_x15_r0_body.s1089 = true
kernel_rfl bodyHi112 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1090.ffi).next setupP.E = true
kernel_rfl bodyNhi112 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1090.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge112 : bridgeOf PRE_first_tail_x15_r0_body.s1089.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1088.ffi
kernel_rfl bodyNN112 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1088.ffi).nnext PRE_first_tail_x15_r0_body.P112.NL = true
kernel_rfl bodyXn112 : Nat.ble (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1090.ffi).next = true
kernel_rfl bodyLo112 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1090.ffi).next = true
theorem bodyFacts112 : BodySiteFacts PRE_first_tail_x15_r0_body.s1088 PRE_first_tail_x15_r0_body.s1089 PRE_first_tail_x15_r0_body.s1090 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1088 PRE_first_tail_x15_r0_body.S1089 PRE_first_tail_x15_r0_body.S1090
    PRE_first_tail_x15_r0_body.ws112 PRE_first_tail_x15_r0_body.cws112 PRE_first_tail_x15_r0_body.nr112 PRE_first_tail_x15_r0_body.pl112 PRE_first_tail_x15_r0_body.cl112 2762965 4868 PRE_first_tail_x15_r0_body.kd112 PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.P112
    ⟨20413, 17514, 2762963, 4868⟩ ⟨20413, 17514, 2762963, 4868⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap112
  clean := bodyClean112
  cfix := PRE_first_tail_x15_r0_body.cfix112
  zpl := PRE_first_tail_x15_r0_body.zpl112
  zplnd := PRE_first_tail_x15_r0_body.zplnd112
  zn1 := PRE_first_tail_x15_r0_body.zn1112
  zfirst := PRE_first_tail_x15_r0_body.zfirst112
  zscn := PRE_first_tail_x15_r0_body.zscn112
  zsmn := PRE_first_tail_x15_r0_body.zsmn112
  zgrow := PRE_first_tail_x15_r0_body.zgrow112
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab112
  zfresh := PRE_first_tail_x15_r0_body.zfresh112
  zcnd := PRE_first_tail_x15_r0_body.zcnd112
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi112
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt112
  zgP := PRE_first_tail_x15_r0_body.zg112_2665
  zkP := PRE_first_tail_x15_r0_body.zk112_2665
  zmP := PRE_first_tail_x15_r0_body.zm112_2665
  zgC := PRE_first_tail_x15_r0_body.zg112_2673467
  zkC := PRE_first_tail_x15_r0_body.zk112_2673467
  zmC := PRE_first_tail_x15_r0_body.zm112_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw112_2673472
  zwV := PRE_first_tail_x15_r0_body.zw112_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap112
  zclbd := PRE_first_tail_x15_r0_body.zclbd112
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap112 PRE_first_tail_x15_r0_body.stFoot112 PRE_first_tail_x15_r0_body.iso112 PRE_first_tail_x15_r0_body.zwr112
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP112
  csupp := PRE_first_tail_x15_r0_body.csupp112
  cbound := PRE_first_tail_x15_r0_body.cbound112
  zimg := PRE_first_tail_x15_r0_body.zimg112
  zctl := PRE_first_tail_x15_r0_body.zctl112
  zstack := PRE_first_tail_x15_r0_body.zstack112
  zjobs := PRE_first_tail_x15_r0_body.zjobs112
  zstores := PRE_first_tail_x15_r0_body.zstores112
  zroots := PRE_first_tail_x15_r0_body.zroots112
  znC := PRE_first_tail_x15_r0_body.znC112
  ctab := PRE_first_tail_x15_r0_body.ctab112
  zbin := PRE_first_tail_x15_r0_body.zbin112
  cbridge := PRE_first_tail_x15_r0_body.cbridge112
  sbridge := bodyBridge112
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj112
  cshiftR := fun h hNL => bodyCshift112 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN112
  raised := PRE_first_tail_x15_r0_body.raised112
  cbigs := PRE_first_tail_x15_r0_body.cbigs112
  cjcl := PRE_first_tail_x15_r0_body.cjcl112
  xnLe := Nat.le_of_ble_eq_true bodyXn112
  loLe := Nat.le_of_ble_eq_true bodyLo112
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB112
  cntM := bodyCntM112
  hiLe := Nat.le_of_ble_eq_true bodyHi112
  nhiLe := Nat.le_of_ble_eq_true bodyNhi112
  jsHeap := bodyJs112
  jsRoots := bodyJsRoots112
  jsNative := bodyJsNative112
  framesEmpty := bodyFramesEmpty112
  trailOld := by decide
  lowVars := bodyLow112

def bodyQs112 : List (Option Q) := []
noncomputable def bodyEs112 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr112.map fun r => nth? PRE_first_tail_x15_r0_body.st112.S2.tab r
kernel_rfl bodyResChk112 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs112 bodyQs112) = true
kernel_rfl bodyLq112 : bodyQs112.length = PRE_first_tail_x15_r0_body.cws112.length
kernel_rfl bodyNrLo112 : PRE_first_tail_x15_r0_body.nr112.all (Nat.ble PRE_first_tail_x15_r0_body.S1088.tab.length) = true
kernel_rfl bodySub112 : (Oracles.PRE_first_tail_x15_r0_body.map_site112.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost112 : postSubB bodyM PRE_first_tail_x15_r0_body.ws112 PRE_first_tail_x15_r0_body.cws112 bodyQs112 = true
kernel_rfl bodyDrop112 : Nat.ble (41128 + (PRE_first_tail_x15_r0_body.s1089.next - PRE_first_tail_x15_r0_body.s1090.next)) 41130 = true
kernel_rfl bodyDropH112 : Nat.ble (764 + ((mlxOf PRE_first_tail_x15_r0_body.s1089.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1090.ffi).next)) 764 = true
kernel_rfl bodyDropN112 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1089.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1090.ffi).nnext)) 0 = true
kernel_rfl bodyDv112 : bodyΘ.1.take 603 = bodyΘ.1.take 603 ++ PRE_first_tail_x15_r0_body.cws112
kernel_rfl bodyDe112 : bodyΘ.2.take 603 = bodyΘ.2.take 603 ++ PRE_first_tail_x15_r0_body.nr112.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st112.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 603) (bodyΘ.2.take 603)))
kernel_rfl bodyDl112 : (bodyΘ.1.take 603).length = (bodyΘ.2.take 603).length
kernel_rfl bodyDold112 : (bodyΘ.1.take 603).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws112).isNone && !PRE_first_tail_x15_r0_body.ws112.contains v) = true
kernel_rfl bodyDfree112 : (bodyΘ.2.take 603).all (fun e => (PRE_first_tail_x15_r0_body.cws112 ++ PRE_first_tail_x15_r0_body.ws112).all fun w => e.noVar w) = true

theorem bodyStep112 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨41128, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1088 PRE_first_tail_x15_r0_body.S1088)
      (bodyCut NB T tk π i x0 bodyΘ ⟨41130, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1090 PRE_first_tail_x15_r0_body.S1090) (27 + 1) :=
  bodySite bodyFacts112.cfix bodyFacts112.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st112.S2.tab) (Es := bodyEs112) (qs := bodyQs112)
    (ok := PRE_first_tail_x15_r0_body.st112.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site112 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts112
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site112 r hr) hi (MapOk.sub hm (sub_of_all bodySub112)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk112 r hr) hi hm ho hq)
    bodyLq112 rfl bodyNrLo112 (postSub_sound bodyPost112)
    (Nat.le_of_ble_eq_true bodyDrop112) (by decide) (Nat.le_of_ble_eq_true bodyDropH112) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN112) (by decide)
    bodyDv112 bodyDe112 bodyDl112 bodyDold112 bodyDfree112 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
