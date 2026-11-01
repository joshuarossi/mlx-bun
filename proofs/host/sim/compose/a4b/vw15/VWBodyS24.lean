import host.sim.compose.a4b.vw15.VWBodyJ24
import host.sim.compose.a4b.vw15.VWBodySite24
import host.sim.compose.a4b.vw15.VWBodyOracles_6
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift24 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S246.tab.length PRE_first_tail_x15_r0_body.s246.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P24.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P24 1127 PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.s248.ffi PRE_first_tail_x15_r0_body.s247.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_24
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_24
  have hcl : SSt (· < 1127) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S246.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_24] <;> decide) PRE_first_tail_x15_r0_body.cnodesK24 PRE_first_tail_x15_r0_body.cobjsK24
      PRE_first_tail_x15_r0_body.citemsK24 PRE_first_tail_x15_r0_body.cbd24 PRE_first_tail_x15_r0_body.csst24
  exact PRE_first_tail_x15_r0_body.cshift24 bodyNcl24 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_24] at this; exact this)


kernel_rfl bodyFramesEmpty24 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s247 a).isEmpty) = true
kernel_rfl bodyJsRoots24 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s246.next) PRE_first_tail_x15_r0_body.s248.trace PRE_first_tail_x15_r0_body.s248 = true
kernel_rfl bodyJsNative24 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s248.ffi) = true
kernel_rfl bodyLow24 : (PRE_first_tail_x15_r0_body.cws24 ++ PRE_first_tail_x15_r0_body.ws24).all (Nat.ble 9) = true
kernel_rfl bodyCntM24 : countersOkB PRE_first_tail_x15_r0_body.s246 PRE_first_tail_x15_r0_body.s247 = true
kernel_rfl bodyHi24 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s248.ffi).next setupP.E = true
kernel_rfl bodyNhi24 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s248.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge24 : bridgeOf PRE_first_tail_x15_r0_body.s247.ffi = bridgeOf PRE_first_tail_x15_r0_body.s246.ffi
kernel_rfl bodyNN24 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s246.ffi).nnext PRE_first_tail_x15_r0_body.P24.NL = true
kernel_rfl bodyXn24 : Nat.ble (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s248.ffi).next = true
kernel_rfl bodyLo24 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s248.ffi).next = true
theorem bodyFacts24 : BodySiteFacts PRE_first_tail_x15_r0_body.s246 PRE_first_tail_x15_r0_body.s247 PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S246 PRE_first_tail_x15_r0_body.S247 PRE_first_tail_x15_r0_body.S248
    PRE_first_tail_x15_r0_body.ws24 PRE_first_tail_x15_r0_body.cws24 PRE_first_tail_x15_r0_body.nr24 PRE_first_tail_x15_r0_body.pl24 PRE_first_tail_x15_r0_body.cl24 2695442 1127 PRE_first_tail_x15_r0_body.kd24 PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.P24
    ⟨18688, 15752, 2694287, 1109⟩ ⟨18691, 15779, 2694293, 1127⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap24
  clean := bodyClean24
  cfix := PRE_first_tail_x15_r0_body.cfix24
  zpl := PRE_first_tail_x15_r0_body.zpl24
  zplnd := PRE_first_tail_x15_r0_body.zplnd24
  zn1 := PRE_first_tail_x15_r0_body.zn124
  zfirst := PRE_first_tail_x15_r0_body.zfirst24
  zscn := PRE_first_tail_x15_r0_body.zscn24
  zsmn := PRE_first_tail_x15_r0_body.zsmn24
  zgrow := PRE_first_tail_x15_r0_body.zgrow24
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab24
  zfresh := PRE_first_tail_x15_r0_body.zfresh24
  zcnd := PRE_first_tail_x15_r0_body.zcnd24
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi24
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt24
  zgP := PRE_first_tail_x15_r0_body.zg24_2665
  zkP := PRE_first_tail_x15_r0_body.zk24_2665
  zmP := PRE_first_tail_x15_r0_body.zm24_2665
  zgC := PRE_first_tail_x15_r0_body.zg24_2673467
  zkC := PRE_first_tail_x15_r0_body.zk24_2673467
  zmC := PRE_first_tail_x15_r0_body.zm24_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw24_2673472
  zwV := PRE_first_tail_x15_r0_body.zw24_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap24
  zclbd := PRE_first_tail_x15_r0_body.zclbd24
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap24 PRE_first_tail_x15_r0_body.stFoot24 PRE_first_tail_x15_r0_body.iso24 PRE_first_tail_x15_r0_body.zwr24
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP24
  csupp := PRE_first_tail_x15_r0_body.csupp24
  cbound := PRE_first_tail_x15_r0_body.cbound24
  zimg := PRE_first_tail_x15_r0_body.zimg24
  zctl := PRE_first_tail_x15_r0_body.zctl24
  zstack := PRE_first_tail_x15_r0_body.zstack24
  zjobs := PRE_first_tail_x15_r0_body.zjobs24
  zstores := PRE_first_tail_x15_r0_body.zstores24
  zroots := PRE_first_tail_x15_r0_body.zroots24
  znC := PRE_first_tail_x15_r0_body.znC24
  ctab := PRE_first_tail_x15_r0_body.ctab24
  zbin := PRE_first_tail_x15_r0_body.zbin24
  cbridge := PRE_first_tail_x15_r0_body.cbridge24
  sbridge := bodyBridge24
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj24
  cshiftR := fun h hNL => bodyCshift24 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN24
  raised := PRE_first_tail_x15_r0_body.raised24
  cbigs := PRE_first_tail_x15_r0_body.cbigs24
  cjcl := PRE_first_tail_x15_r0_body.cjcl24
  xnLe := Nat.le_of_ble_eq_true bodyXn24
  loLe := Nat.le_of_ble_eq_true bodyLo24
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB24
  cntM := bodyCntM24
  hiLe := Nat.le_of_ble_eq_true bodyHi24
  nhiLe := Nat.le_of_ble_eq_true bodyNhi24
  jsHeap := bodyJs24
  jsRoots := bodyJsRoots24
  jsNative := bodyJsNative24
  framesEmpty := bodyFramesEmpty24
  trailOld := by decide
  lowVars := bodyLow24

def bodyQs24 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs24 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr24.map fun r => nth? PRE_first_tail_x15_r0_body.st24.S5.tab r
kernel_rfl bodyResChk24 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs24 bodyQs24) = true
kernel_rfl bodyLq24 : bodyQs24.length = PRE_first_tail_x15_r0_body.cws24.length
kernel_rfl bodyNrLo24 : PRE_first_tail_x15_r0_body.nr24.all (Nat.ble PRE_first_tail_x15_r0_body.S246.tab.length) = true
kernel_rfl bodySub24 : (Oracles.PRE_first_tail_x15_r0_body.map_site24.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost24 : postSubB bodyM PRE_first_tail_x15_r0_body.ws24 PRE_first_tail_x15_r0_body.cws24 bodyQs24 = true
kernel_rfl bodyDrop24 : Nat.ble (11813 + (PRE_first_tail_x15_r0_body.s247.next - PRE_first_tail_x15_r0_body.s248.next)) 12962 = true
kernel_rfl bodyDropH24 : Nat.ble (175 + ((mlxOf PRE_first_tail_x15_r0_body.s247.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s248.ffi).next)) 200 = true
kernel_rfl bodyDropN24 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s247.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s248.ffi).nnext)) 0 = true
kernel_rfl bodyDv24 : bodyΘ.1.take 144 = bodyΘ.1.take 126 ++ PRE_first_tail_x15_r0_body.cws24
kernel_rfl bodyDe24 : bodyΘ.2.take 144 = bodyΘ.2.take 126 ++ PRE_first_tail_x15_r0_body.nr24.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st24.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 126) (bodyΘ.2.take 126)))
kernel_rfl bodyDl24 : (bodyΘ.1.take 126).length = (bodyΘ.2.take 126).length
kernel_rfl bodyDold24 : (bodyΘ.1.take 126).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws24).isNone && !PRE_first_tail_x15_r0_body.ws24.contains v) = true
kernel_rfl bodyDfree24 : (bodyΘ.2.take 144).all (fun e => (PRE_first_tail_x15_r0_body.cws24 ++ PRE_first_tail_x15_r0_body.ws24).all fun w => e.noVar w) = true

theorem bodyStep24 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11813, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s246 PRE_first_tail_x15_r0_body.S246)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12962, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.S248) (11334 + 1) :=
  bodySite bodyFacts24.cfix bodyFacts24.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st24.S5.tab) (Es := bodyEs24) (qs := bodyQs24)
    (ok := PRE_first_tail_x15_r0_body.st24.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site24 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts24
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site24 r hr) hi (MapOk.sub hm (sub_of_all bodySub24)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk24 r hr) hi hm ho hq)
    bodyLq24 rfl bodyNrLo24 (postSub_sound bodyPost24)
    (Nat.le_of_ble_eq_true bodyDrop24) (by decide) (Nat.le_of_ble_eq_true bodyDropH24) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN24) (by decide)
    bodyDv24 bodyDe24 bodyDl24 bodyDold24 bodyDfree24 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
