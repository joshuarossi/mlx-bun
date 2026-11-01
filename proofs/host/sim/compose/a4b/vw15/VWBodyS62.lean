import host.sim.compose.a4b.vw15.VWBodyJ62
import host.sim.compose.a4b.vw15.VWBodySite62
import host.sim.compose.a4b.vw15.VWBodyOracles_15
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift62 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S603.tab.length PRE_first_tail_x15_r0_body.s603.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P62.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P62 2704 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.s605.ffi PRE_first_tail_x15_r0_body.s604.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_62
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_62
  have hcl : SSt (· < 2704) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S603.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_62] <;> decide) PRE_first_tail_x15_r0_body.cnodesK62 PRE_first_tail_x15_r0_body.cobjsK62
      PRE_first_tail_x15_r0_body.citemsK62 PRE_first_tail_x15_r0_body.cbd62 PRE_first_tail_x15_r0_body.csst62
  exact PRE_first_tail_x15_r0_body.cshift62 bodyNcl62 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_62] at this; exact this)


kernel_rfl bodyFramesEmpty62 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s604 a).isEmpty) = true
kernel_rfl bodyJsRoots62 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s603.next) PRE_first_tail_x15_r0_body.s605.trace PRE_first_tail_x15_r0_body.s605 = true
kernel_rfl bodyJsNative62 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s605.ffi) = true
kernel_rfl bodyLow62 : (PRE_first_tail_x15_r0_body.cws62 ++ PRE_first_tail_x15_r0_body.ws62).all (Nat.ble 9) = true
kernel_rfl bodyCntM62 : countersOkB PRE_first_tail_x15_r0_body.s603 PRE_first_tail_x15_r0_body.s604 = true
kernel_rfl bodyHi62 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s605.ffi).next setupP.E = true
kernel_rfl bodyNhi62 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s605.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge62 : bridgeOf PRE_first_tail_x15_r0_body.s604.ffi = bridgeOf PRE_first_tail_x15_r0_body.s603.ffi
kernel_rfl bodyNN62 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s603.ffi).nnext PRE_first_tail_x15_r0_body.P62.NL = true
kernel_rfl bodyXn62 : Nat.ble (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s605.ffi).next = true
kernel_rfl bodyLo62 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s605.ffi).next = true
theorem bodyFacts62 : BodySiteFacts PRE_first_tail_x15_r0_body.s603 PRE_first_tail_x15_r0_body.s604 PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S603 PRE_first_tail_x15_r0_body.S604 PRE_first_tail_x15_r0_body.S605
    PRE_first_tail_x15_r0_body.ws62 PRE_first_tail_x15_r0_body.cws62 PRE_first_tail_x15_r0_body.nr62 PRE_first_tail_x15_r0_body.pl62 PRE_first_tail_x15_r0_body.cl62 2723342 2704 PRE_first_tail_x15_r0_body.kd62 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.P62
    ⟨19419, 16507, 2723331, 2704⟩ ⟨19419, 16507, 2723332, 2704⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap62
  clean := bodyClean62
  cfix := PRE_first_tail_x15_r0_body.cfix62
  zpl := PRE_first_tail_x15_r0_body.zpl62
  zplnd := PRE_first_tail_x15_r0_body.zplnd62
  zn1 := PRE_first_tail_x15_r0_body.zn162
  zfirst := PRE_first_tail_x15_r0_body.zfirst62
  zscn := PRE_first_tail_x15_r0_body.zscn62
  zsmn := PRE_first_tail_x15_r0_body.zsmn62
  zgrow := PRE_first_tail_x15_r0_body.zgrow62
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab62
  zfresh := PRE_first_tail_x15_r0_body.zfresh62
  zcnd := PRE_first_tail_x15_r0_body.zcnd62
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi62
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt62
  zgP := PRE_first_tail_x15_r0_body.zg62_2665
  zkP := PRE_first_tail_x15_r0_body.zk62_2665
  zmP := PRE_first_tail_x15_r0_body.zm62_2665
  zgC := PRE_first_tail_x15_r0_body.zg62_2673467
  zkC := PRE_first_tail_x15_r0_body.zk62_2673467
  zmC := PRE_first_tail_x15_r0_body.zm62_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw62_2673472
  zwV := PRE_first_tail_x15_r0_body.zw62_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap62
  zclbd := PRE_first_tail_x15_r0_body.zclbd62
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap62 PRE_first_tail_x15_r0_body.stFoot62 PRE_first_tail_x15_r0_body.iso62 PRE_first_tail_x15_r0_body.zwr62
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP62
  csupp := PRE_first_tail_x15_r0_body.csupp62
  cbound := PRE_first_tail_x15_r0_body.cbound62
  zimg := PRE_first_tail_x15_r0_body.zimg62
  zctl := PRE_first_tail_x15_r0_body.zctl62
  zstack := PRE_first_tail_x15_r0_body.zstack62
  zjobs := PRE_first_tail_x15_r0_body.zjobs62
  zstores := PRE_first_tail_x15_r0_body.zstores62
  zroots := PRE_first_tail_x15_r0_body.zroots62
  znC := PRE_first_tail_x15_r0_body.znC62
  ctab := PRE_first_tail_x15_r0_body.ctab62
  zbin := PRE_first_tail_x15_r0_body.zbin62
  cbridge := PRE_first_tail_x15_r0_body.cbridge62
  sbridge := bodyBridge62
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj62
  cshiftR := fun h hNL => bodyCshift62 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN62
  raised := PRE_first_tail_x15_r0_body.raised62
  cbigs := PRE_first_tail_x15_r0_body.cbigs62
  cjcl := PRE_first_tail_x15_r0_body.cjcl62
  xnLe := Nat.le_of_ble_eq_true bodyXn62
  loLe := Nat.le_of_ble_eq_true bodyLo62
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB62
  cntM := bodyCntM62
  hiLe := Nat.le_of_ble_eq_true bodyHi62
  nhiLe := Nat.le_of_ble_eq_true bodyNhi62
  jsHeap := bodyJs62
  jsRoots := bodyJsRoots62
  jsNative := bodyJsNative62
  framesEmpty := bodyFramesEmpty62
  trailOld := by decide
  lowVars := bodyLow62

def bodyQs62 : List (Option Q) := []
noncomputable def bodyEs62 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr62.map fun r => nth? PRE_first_tail_x15_r0_body.st62.S2.tab r
kernel_rfl bodyResChk62 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs62 bodyQs62) = true
kernel_rfl bodyLq62 : bodyQs62.length = PRE_first_tail_x15_r0_body.cws62.length
kernel_rfl bodyNrLo62 : PRE_first_tail_x15_r0_body.nr62.all (Nat.ble PRE_first_tail_x15_r0_body.S603.tab.length) = true
kernel_rfl bodySub62 : (Oracles.PRE_first_tail_x15_r0_body.map_site62.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost62 : postSubB bodyM PRE_first_tail_x15_r0_body.ws62 PRE_first_tail_x15_r0_body.cws62 bodyQs62 = true
kernel_rfl bodyDrop62 : Nat.ble (24553 + (PRE_first_tail_x15_r0_body.s604.next - PRE_first_tail_x15_r0_body.s605.next)) 24563 = true
kernel_rfl bodyDropH62 : Nat.ble (431 + ((mlxOf PRE_first_tail_x15_r0_body.s604.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s605.ffi).next)) 431 = true
kernel_rfl bodyDropN62 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s604.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s605.ffi).nnext)) 0 = true
kernel_rfl bodyDv62 : bodyΘ.1.take 333 = bodyΘ.1.take 333 ++ PRE_first_tail_x15_r0_body.cws62
kernel_rfl bodyDe62 : bodyΘ.2.take 333 = bodyΘ.2.take 333 ++ PRE_first_tail_x15_r0_body.nr62.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st62.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 333) (bodyΘ.2.take 333)))
kernel_rfl bodyDl62 : (bodyΘ.1.take 333).length = (bodyΘ.2.take 333).length
kernel_rfl bodyDold62 : (bodyΘ.1.take 333).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws62).isNone && !PRE_first_tail_x15_r0_body.ws62.contains v) = true
kernel_rfl bodyDfree62 : (bodyΘ.2.take 333).all (fun e => (PRE_first_tail_x15_r0_body.cws62 ++ PRE_first_tail_x15_r0_body.ws62).all fun w => e.noVar w) = true

theorem bodyStep62 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24553, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s603 PRE_first_tail_x15_r0_body.S603)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24563, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.S605) (98 + 1) :=
  bodySite bodyFacts62.cfix bodyFacts62.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st62.S2.tab) (Es := bodyEs62) (qs := bodyQs62)
    (ok := PRE_first_tail_x15_r0_body.st62.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site62 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts62
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site62 r hr) hi (MapOk.sub hm (sub_of_all bodySub62)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk62 r hr) hi hm ho hq)
    bodyLq62 rfl bodyNrLo62 (postSub_sound bodyPost62)
    (Nat.le_of_ble_eq_true bodyDrop62) (by decide) (Nat.le_of_ble_eq_true bodyDropH62) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN62) (by decide)
    bodyDv62 bodyDe62 bodyDl62 bodyDold62 bodyDfree62 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
