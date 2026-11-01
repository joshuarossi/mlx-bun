import host.sim.compose.a4b.vw15.VWBodyJ41
import host.sim.compose.a4b.vw15.VWBodySite41
import host.sim.compose.a4b.vw15.VWBodyOracles_10
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift41 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S402.tab.length PRE_first_tail_x15_r0_body.s402.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P41.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P41 1807 PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.s404.ffi PRE_first_tail_x15_r0_body.s403.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_41
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_41
  have hcl : SSt (· < 1807) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S402.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_41] <;> decide) PRE_first_tail_x15_r0_body.cnodesK41 PRE_first_tail_x15_r0_body.cobjsK41
      PRE_first_tail_x15_r0_body.citemsK41 PRE_first_tail_x15_r0_body.cbd41 PRE_first_tail_x15_r0_body.csst41
  exact PRE_first_tail_x15_r0_body.cshift41 bodyNcl41 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_41] at this; exact this)


kernel_rfl bodyFramesEmpty41 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s403 a).isEmpty) = true
kernel_rfl bodyJsRoots41 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s402.next) PRE_first_tail_x15_r0_body.s404.trace PRE_first_tail_x15_r0_body.s404 = true
kernel_rfl bodyJsNative41 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s404.ffi) = true
kernel_rfl bodyLow41 : (PRE_first_tail_x15_r0_body.cws41 ++ PRE_first_tail_x15_r0_body.ws41).all (Nat.ble 9) = true
kernel_rfl bodyCntM41 : countersOkB PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.s403 = true
kernel_rfl bodyHi41 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).next setupP.E = true
kernel_rfl bodyNhi41 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge41 : bridgeOf PRE_first_tail_x15_r0_body.s403.ffi = bridgeOf PRE_first_tail_x15_r0_body.s402.ffi
kernel_rfl bodyNN41 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s402.ffi).nnext PRE_first_tail_x15_r0_body.P41.NL = true
kernel_rfl bodyXn41 : Nat.ble (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).next = true
kernel_rfl bodyLo41 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).next = true
theorem bodyFacts41 : BodySiteFacts PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.s403 PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S402 PRE_first_tail_x15_r0_body.S403 PRE_first_tail_x15_r0_body.S404
    PRE_first_tail_x15_r0_body.ws41 PRE_first_tail_x15_r0_body.cws41 PRE_first_tail_x15_r0_body.nr41 PRE_first_tail_x15_r0_body.pl41 PRE_first_tail_x15_r0_body.cl41 2706763 1807 PRE_first_tail_x15_r0_body.kd41 PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.P41
    ⟨19004, 16096, 2706743, 1807⟩ ⟨19004, 16096, 2706744, 1807⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap41
  clean := bodyClean41
  cfix := PRE_first_tail_x15_r0_body.cfix41
  zpl := PRE_first_tail_x15_r0_body.zpl41
  zplnd := PRE_first_tail_x15_r0_body.zplnd41
  zn1 := PRE_first_tail_x15_r0_body.zn141
  zfirst := PRE_first_tail_x15_r0_body.zfirst41
  zscn := PRE_first_tail_x15_r0_body.zscn41
  zsmn := PRE_first_tail_x15_r0_body.zsmn41
  zgrow := PRE_first_tail_x15_r0_body.zgrow41
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab41
  zfresh := PRE_first_tail_x15_r0_body.zfresh41
  zcnd := PRE_first_tail_x15_r0_body.zcnd41
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi41
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt41
  zgP := PRE_first_tail_x15_r0_body.zg41_2665
  zkP := PRE_first_tail_x15_r0_body.zk41_2665
  zmP := PRE_first_tail_x15_r0_body.zm41_2665
  zgC := PRE_first_tail_x15_r0_body.zg41_2673467
  zkC := PRE_first_tail_x15_r0_body.zk41_2673467
  zmC := PRE_first_tail_x15_r0_body.zm41_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw41_2673472
  zwV := PRE_first_tail_x15_r0_body.zw41_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap41
  zclbd := PRE_first_tail_x15_r0_body.zclbd41
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap41 PRE_first_tail_x15_r0_body.stFoot41 PRE_first_tail_x15_r0_body.iso41 PRE_first_tail_x15_r0_body.zwr41
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP41
  csupp := PRE_first_tail_x15_r0_body.csupp41
  cbound := PRE_first_tail_x15_r0_body.cbound41
  zimg := PRE_first_tail_x15_r0_body.zimg41
  zctl := PRE_first_tail_x15_r0_body.zctl41
  zstack := PRE_first_tail_x15_r0_body.zstack41
  zjobs := PRE_first_tail_x15_r0_body.zjobs41
  zstores := PRE_first_tail_x15_r0_body.zstores41
  zroots := PRE_first_tail_x15_r0_body.zroots41
  znC := PRE_first_tail_x15_r0_body.znC41
  ctab := PRE_first_tail_x15_r0_body.ctab41
  zbin := PRE_first_tail_x15_r0_body.zbin41
  cbridge := PRE_first_tail_x15_r0_body.cbridge41
  sbridge := bodyBridge41
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj41
  cshiftR := fun h hNL => bodyCshift41 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN41
  raised := PRE_first_tail_x15_r0_body.raised41
  cbigs := PRE_first_tail_x15_r0_body.cbigs41
  cjcl := PRE_first_tail_x15_r0_body.cjcl41
  xnLe := Nat.le_of_ble_eq_true bodyXn41
  loLe := Nat.le_of_ble_eq_true bodyLo41
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB41
  cntM := bodyCntM41
  hiLe := Nat.le_of_ble_eq_true bodyHi41
  nhiLe := Nat.le_of_ble_eq_true bodyNhi41
  jsHeap := bodyJs41
  jsRoots := bodyJsRoots41
  jsNative := bodyJsNative41
  framesEmpty := bodyFramesEmpty41
  trailOld := by decide
  lowVars := bodyLow41

def bodyQs41 : List (Option Q) := []
noncomputable def bodyEs41 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr41.map fun r => nth? PRE_first_tail_x15_r0_body.st41.S2.tab r
kernel_rfl bodyResChk41 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs41 bodyQs41) = true
kernel_rfl bodyLq41 : bodyQs41.length = PRE_first_tail_x15_r0_body.cws41.length
kernel_rfl bodyNrLo41 : PRE_first_tail_x15_r0_body.nr41.all (Nat.ble PRE_first_tail_x15_r0_body.S402.tab.length) = true
kernel_rfl bodySub41 : (Oracles.PRE_first_tail_x15_r0_body.map_site41.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost41 : postSubB bodyM PRE_first_tail_x15_r0_body.ws41 PRE_first_tail_x15_r0_body.cws41 bodyQs41 = true
kernel_rfl bodyDrop41 : Nat.ble (17979 + (PRE_first_tail_x15_r0_body.s403.next - PRE_first_tail_x15_r0_body.s404.next)) 17998 = true
kernel_rfl bodyDropH41 : Nat.ble (302 + ((mlxOf PRE_first_tail_x15_r0_body.s403.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).next)) 302 = true
kernel_rfl bodyDropN41 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s403.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s404.ffi).nnext)) 0 = true
kernel_rfl bodyDv41 : bodyΘ.1.take 225 = bodyΘ.1.take 225 ++ PRE_first_tail_x15_r0_body.cws41
kernel_rfl bodyDe41 : bodyΘ.2.take 225 = bodyΘ.2.take 225 ++ PRE_first_tail_x15_r0_body.nr41.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st41.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 225) (bodyΘ.2.take 225)))
kernel_rfl bodyDl41 : (bodyΘ.1.take 225).length = (bodyΘ.2.take 225).length
kernel_rfl bodyDold41 : (bodyΘ.1.take 225).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws41).isNone && !PRE_first_tail_x15_r0_body.ws41.contains v) = true
kernel_rfl bodyDfree41 : (bodyΘ.2.take 225).all (fun e => (PRE_first_tail_x15_r0_body.cws41 ++ PRE_first_tail_x15_r0_body.ws41).all fun w => e.noVar w) = true

theorem bodyStep41 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.S402)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17998, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.S404) (206 + 1) :=
  bodySite bodyFacts41.cfix bodyFacts41.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st41.S2.tab) (Es := bodyEs41) (qs := bodyQs41)
    (ok := PRE_first_tail_x15_r0_body.st41.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site41 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts41
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site41 r hr) hi (MapOk.sub hm (sub_of_all bodySub41)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk41 r hr) hi hm ho hq)
    bodyLq41 rfl bodyNrLo41 (postSub_sound bodyPost41)
    (Nat.le_of_ble_eq_true bodyDrop41) (by decide) (Nat.le_of_ble_eq_true bodyDropH41) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN41) (by decide)
    bodyDv41 bodyDe41 bodyDl41 bodyDold41 bodyDfree41 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
