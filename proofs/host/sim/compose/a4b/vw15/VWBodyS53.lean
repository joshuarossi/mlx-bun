import host.sim.compose.a4b.vw15.VWBodyJ53
import host.sim.compose.a4b.vw15.VWBodySite53
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

theorem bodyCshift53 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S517.tab.length PRE_first_tail_x15_r0_body.s517.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P53.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.s519.ffi PRE_first_tail_x15_r0_body.s518.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_53
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_53
  have hcl : SSt (· < 2320) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S517.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_53] <;> decide) PRE_first_tail_x15_r0_body.cnodesK53 PRE_first_tail_x15_r0_body.cobjsK53
      PRE_first_tail_x15_r0_body.citemsK53 PRE_first_tail_x15_r0_body.cbd53 PRE_first_tail_x15_r0_body.csst53
  exact PRE_first_tail_x15_r0_body.cshift53 bodyNcl53 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_53] at this; exact this)


kernel_rfl bodyFramesEmpty53 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s518 a).isEmpty) = true
kernel_rfl bodyJsRoots53 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s517.next) PRE_first_tail_x15_r0_body.s519.trace PRE_first_tail_x15_r0_body.s519 = true
kernel_rfl bodyJsNative53 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s519.ffi) = true
kernel_rfl bodyLow53 : (PRE_first_tail_x15_r0_body.cws53 ++ PRE_first_tail_x15_r0_body.ws53).all (Nat.ble 9) = true
kernel_rfl bodyCntM53 : countersOkB PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.s518 = true
kernel_rfl bodyHi53 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).next setupP.E = true
kernel_rfl bodyNhi53 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge53 : bridgeOf PRE_first_tail_x15_r0_body.s518.ffi = bridgeOf PRE_first_tail_x15_r0_body.s517.ffi
kernel_rfl bodyNN53 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s517.ffi).nnext PRE_first_tail_x15_r0_body.P53.NL = true
kernel_rfl bodyXn53 : Nat.ble (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).next = true
kernel_rfl bodyLo53 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).next = true
theorem bodyFacts53 : BodySiteFacts PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.s518 PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S517 PRE_first_tail_x15_r0_body.S518 PRE_first_tail_x15_r0_body.S519
    PRE_first_tail_x15_r0_body.ws53 PRE_first_tail_x15_r0_body.cws53 PRE_first_tail_x15_r0_body.nr53 PRE_first_tail_x15_r0_body.pl53 PRE_first_tail_x15_r0_body.cl53 2716187 2320 PRE_first_tail_x15_r0_body.kd53 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.P53
    ⟨19240, 16333, 2716167, 2320⟩ ⟨19240, 16333, 2716168, 2320⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap53
  clean := bodyClean53
  cfix := PRE_first_tail_x15_r0_body.cfix53
  zpl := PRE_first_tail_x15_r0_body.zpl53
  zplnd := PRE_first_tail_x15_r0_body.zplnd53
  zn1 := PRE_first_tail_x15_r0_body.zn153
  zfirst := PRE_first_tail_x15_r0_body.zfirst53
  zscn := PRE_first_tail_x15_r0_body.zscn53
  zsmn := PRE_first_tail_x15_r0_body.zsmn53
  zgrow := PRE_first_tail_x15_r0_body.zgrow53
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab53
  zfresh := PRE_first_tail_x15_r0_body.zfresh53
  zcnd := PRE_first_tail_x15_r0_body.zcnd53
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi53
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt53
  zgP := PRE_first_tail_x15_r0_body.zg53_2665
  zkP := PRE_first_tail_x15_r0_body.zk53_2665
  zmP := PRE_first_tail_x15_r0_body.zm53_2665
  zgC := PRE_first_tail_x15_r0_body.zg53_2673467
  zkC := PRE_first_tail_x15_r0_body.zk53_2673467
  zmC := PRE_first_tail_x15_r0_body.zm53_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw53_2673472
  zwV := PRE_first_tail_x15_r0_body.zw53_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap53
  zclbd := PRE_first_tail_x15_r0_body.zclbd53
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap53 PRE_first_tail_x15_r0_body.stFoot53 PRE_first_tail_x15_r0_body.iso53 PRE_first_tail_x15_r0_body.zwr53
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP53
  csupp := PRE_first_tail_x15_r0_body.csupp53
  cbound := PRE_first_tail_x15_r0_body.cbound53
  zimg := PRE_first_tail_x15_r0_body.zimg53
  zctl := PRE_first_tail_x15_r0_body.zctl53
  zstack := PRE_first_tail_x15_r0_body.zstack53
  zjobs := PRE_first_tail_x15_r0_body.zjobs53
  zstores := PRE_first_tail_x15_r0_body.zstores53
  zroots := PRE_first_tail_x15_r0_body.zroots53
  znC := PRE_first_tail_x15_r0_body.znC53
  ctab := PRE_first_tail_x15_r0_body.ctab53
  zbin := PRE_first_tail_x15_r0_body.zbin53
  cbridge := PRE_first_tail_x15_r0_body.cbridge53
  sbridge := bodyBridge53
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj53
  cshiftR := fun h hNL => bodyCshift53 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN53
  raised := PRE_first_tail_x15_r0_body.raised53
  cbigs := PRE_first_tail_x15_r0_body.cbigs53
  cjcl := PRE_first_tail_x15_r0_body.cjcl53
  xnLe := Nat.le_of_ble_eq_true bodyXn53
  loLe := Nat.le_of_ble_eq_true bodyLo53
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB53
  cntM := bodyCntM53
  hiLe := Nat.le_of_ble_eq_true bodyHi53
  nhiLe := Nat.le_of_ble_eq_true bodyNhi53
  jsHeap := bodyJs53
  jsRoots := bodyJsRoots53
  jsNative := bodyJsNative53
  framesEmpty := bodyFramesEmpty53
  trailOld := by decide
  lowVars := bodyLow53

def bodyQs53 : List (Option Q) := []
noncomputable def bodyEs53 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr53.map fun r => nth? PRE_first_tail_x15_r0_body.st53.S2.tab r
kernel_rfl bodyResChk53 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs53 bodyQs53) = true
kernel_rfl bodyLq53 : bodyQs53.length = PRE_first_tail_x15_r0_body.cws53.length
kernel_rfl bodyNrLo53 : PRE_first_tail_x15_r0_body.nr53.all (Nat.ble PRE_first_tail_x15_r0_body.S517.tab.length) = true
kernel_rfl bodySub53 : (Oracles.PRE_first_tail_x15_r0_body.map_site53.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost53 : postSubB bodyM PRE_first_tail_x15_r0_body.ws53 PRE_first_tail_x15_r0_body.cws53 bodyQs53 = true
kernel_rfl bodyDrop53 : Nat.ble (21851 + (PRE_first_tail_x15_r0_body.s518.next - PRE_first_tail_x15_r0_body.s519.next)) 21870 = true
kernel_rfl bodyDropH53 : Nat.ble (379 + ((mlxOf PRE_first_tail_x15_r0_body.s518.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).next)) 379 = true
kernel_rfl bodyDropN53 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s518.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s519.ffi).nnext)) 0 = true
kernel_rfl bodyDv53 : bodyΘ.1.take 288 = bodyΘ.1.take 288 ++ PRE_first_tail_x15_r0_body.cws53
kernel_rfl bodyDe53 : bodyΘ.2.take 288 = bodyΘ.2.take 288 ++ PRE_first_tail_x15_r0_body.nr53.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st53.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 288) (bodyΘ.2.take 288)))
kernel_rfl bodyDl53 : (bodyΘ.1.take 288).length = (bodyΘ.2.take 288).length
kernel_rfl bodyDold53 : (bodyΘ.1.take 288).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws53).isNone && !PRE_first_tail_x15_r0_body.ws53.contains v) = true
kernel_rfl bodyDfree53 : (bodyΘ.2.take 288).all (fun e => (PRE_first_tail_x15_r0_body.cws53 ++ PRE_first_tail_x15_r0_body.ws53).all fun w => e.noVar w) = true

theorem bodyStep53 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨21851, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.S517)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21870, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.S519) (206 + 1) :=
  bodySite bodyFacts53.cfix bodyFacts53.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st53.S2.tab) (Es := bodyEs53) (qs := bodyQs53)
    (ok := PRE_first_tail_x15_r0_body.st53.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site53 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts53
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site53 r hr) hi (MapOk.sub hm (sub_of_all bodySub53)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk53 r hr) hi hm ho hq)
    bodyLq53 rfl bodyNrLo53 (postSub_sound bodyPost53)
    (Nat.le_of_ble_eq_true bodyDrop53) (by decide) (Nat.le_of_ble_eq_true bodyDropH53) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN53) (by decide)
    bodyDv53 bodyDe53 bodyDl53 bodyDold53 bodyDfree53 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
