import host.sim.compose.a4b.vw15.VWBodyJ47
import host.sim.compose.a4b.vw15.VWBodySite47
import host.sim.compose.a4b.vw15.VWBodyOracles_11
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

theorem bodyCshift47 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S459.tab.length PRE_first_tail_x15_r0_body.s459.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P47.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.s461.ffi PRE_first_tail_x15_r0_body.s460.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_47
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_47
  have hcl : SSt (· < 2062) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S459.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_47] <;> decide) PRE_first_tail_x15_r0_body.cnodesK47 PRE_first_tail_x15_r0_body.cobjsK47
      PRE_first_tail_x15_r0_body.citemsK47 PRE_first_tail_x15_r0_body.cbd47 PRE_first_tail_x15_r0_body.csst47
  exact PRE_first_tail_x15_r0_body.cshift47 bodyNcl47 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_47] at this; exact this)


kernel_rfl bodyFramesEmpty47 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s460 a).isEmpty) = true
kernel_rfl bodyJsRoots47 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s459.next) PRE_first_tail_x15_r0_body.s461.trace PRE_first_tail_x15_r0_body.s461 = true
kernel_rfl bodyJsNative47 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s461.ffi) = true
kernel_rfl bodyLow47 : (PRE_first_tail_x15_r0_body.cws47 ++ PRE_first_tail_x15_r0_body.ws47).all (Nat.ble 9) = true
kernel_rfl bodyCntM47 : countersOkB PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.s460 = true
kernel_rfl bodyHi47 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).next setupP.E = true
kernel_rfl bodyNhi47 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge47 : bridgeOf PRE_first_tail_x15_r0_body.s460.ffi = bridgeOf PRE_first_tail_x15_r0_body.s459.ffi
kernel_rfl bodyNN47 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s459.ffi).nnext PRE_first_tail_x15_r0_body.P47.NL = true
kernel_rfl bodyXn47 : Nat.ble (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).next = true
kernel_rfl bodyLo47 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).next = true
theorem bodyFacts47 : BodySiteFacts PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.s460 PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S459 PRE_first_tail_x15_r0_body.S460 PRE_first_tail_x15_r0_body.S461
    PRE_first_tail_x15_r0_body.ws47 PRE_first_tail_x15_r0_body.cws47 PRE_first_tail_x15_r0_body.nr47 PRE_first_tail_x15_r0_body.pl47 PRE_first_tail_x15_r0_body.cl47 2711645 2062 PRE_first_tail_x15_r0_body.kd47 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.P47
    ⟨19125, 16207, 2711625, 2062⟩ ⟨19125, 16207, 2711626, 2062⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap47
  clean := bodyClean47
  cfix := PRE_first_tail_x15_r0_body.cfix47
  zpl := PRE_first_tail_x15_r0_body.zpl47
  zplnd := PRE_first_tail_x15_r0_body.zplnd47
  zn1 := PRE_first_tail_x15_r0_body.zn147
  zfirst := PRE_first_tail_x15_r0_body.zfirst47
  zscn := PRE_first_tail_x15_r0_body.zscn47
  zsmn := PRE_first_tail_x15_r0_body.zsmn47
  zgrow := PRE_first_tail_x15_r0_body.zgrow47
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab47
  zfresh := PRE_first_tail_x15_r0_body.zfresh47
  zcnd := PRE_first_tail_x15_r0_body.zcnd47
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi47
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt47
  zgP := PRE_first_tail_x15_r0_body.zg47_2665
  zkP := PRE_first_tail_x15_r0_body.zk47_2665
  zmP := PRE_first_tail_x15_r0_body.zm47_2665
  zgC := PRE_first_tail_x15_r0_body.zg47_2673467
  zkC := PRE_first_tail_x15_r0_body.zk47_2673467
  zmC := PRE_first_tail_x15_r0_body.zm47_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw47_2673472
  zwV := PRE_first_tail_x15_r0_body.zw47_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap47
  zclbd := PRE_first_tail_x15_r0_body.zclbd47
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap47 PRE_first_tail_x15_r0_body.stFoot47 PRE_first_tail_x15_r0_body.iso47 PRE_first_tail_x15_r0_body.zwr47
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP47
  csupp := PRE_first_tail_x15_r0_body.csupp47
  cbound := PRE_first_tail_x15_r0_body.cbound47
  zimg := PRE_first_tail_x15_r0_body.zimg47
  zctl := PRE_first_tail_x15_r0_body.zctl47
  zstack := PRE_first_tail_x15_r0_body.zstack47
  zjobs := PRE_first_tail_x15_r0_body.zjobs47
  zstores := PRE_first_tail_x15_r0_body.zstores47
  zroots := PRE_first_tail_x15_r0_body.zroots47
  znC := PRE_first_tail_x15_r0_body.znC47
  ctab := PRE_first_tail_x15_r0_body.ctab47
  zbin := PRE_first_tail_x15_r0_body.zbin47
  cbridge := PRE_first_tail_x15_r0_body.cbridge47
  sbridge := bodyBridge47
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj47
  cshiftR := fun h hNL => bodyCshift47 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN47
  raised := PRE_first_tail_x15_r0_body.raised47
  cbigs := PRE_first_tail_x15_r0_body.cbigs47
  cjcl := PRE_first_tail_x15_r0_body.cjcl47
  xnLe := Nat.le_of_ble_eq_true bodyXn47
  loLe := Nat.le_of_ble_eq_true bodyLo47
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB47
  cntM := bodyCntM47
  hiLe := Nat.le_of_ble_eq_true bodyHi47
  nhiLe := Nat.le_of_ble_eq_true bodyNhi47
  jsHeap := bodyJs47
  jsRoots := bodyJsRoots47
  jsNative := bodyJsNative47
  framesEmpty := bodyFramesEmpty47
  trailOld := by decide
  lowVars := bodyLow47

def bodyQs47 : List (Option Q) := []
noncomputable def bodyEs47 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr47.map fun r => nth? PRE_first_tail_x15_r0_body.st47.S2.tab r
kernel_rfl bodyResChk47 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs47 bodyQs47) = true
kernel_rfl bodyLq47 : bodyQs47.length = PRE_first_tail_x15_r0_body.cws47.length
kernel_rfl bodyNrLo47 : PRE_first_tail_x15_r0_body.nr47.all (Nat.ble PRE_first_tail_x15_r0_body.S459.tab.length) = true
kernel_rfl bodySub47 : (Oracles.PRE_first_tail_x15_r0_body.map_site47.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost47 : postSubB bodyM PRE_first_tail_x15_r0_body.ws47 PRE_first_tail_x15_r0_body.cws47 bodyQs47 = true
kernel_rfl bodyDrop47 : Nat.ble (19511 + (PRE_first_tail_x15_r0_body.s460.next - PRE_first_tail_x15_r0_body.s461.next)) 19530 = true
kernel_rfl bodyDropH47 : Nat.ble (329 + ((mlxOf PRE_first_tail_x15_r0_body.s460.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).next)) 329 = true
kernel_rfl bodyDropN47 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s460.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s461.ffi).nnext)) 0 = true
kernel_rfl bodyDv47 : bodyΘ.1.take 252 = bodyΘ.1.take 252 ++ PRE_first_tail_x15_r0_body.cws47
kernel_rfl bodyDe47 : bodyΘ.2.take 252 = bodyΘ.2.take 252 ++ PRE_first_tail_x15_r0_body.nr47.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st47.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 252) (bodyΘ.2.take 252)))
kernel_rfl bodyDl47 : (bodyΘ.1.take 252).length = (bodyΘ.2.take 252).length
kernel_rfl bodyDold47 : (bodyΘ.1.take 252).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws47).isNone && !PRE_first_tail_x15_r0_body.ws47.contains v) = true
kernel_rfl bodyDfree47 : (bodyΘ.2.take 252).all (fun e => (PRE_first_tail_x15_r0_body.cws47 ++ PRE_first_tail_x15_r0_body.ws47).all fun w => e.noVar w) = true

theorem bodyStep47 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19511, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.S459)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19530, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.S461) (206 + 1) :=
  bodySite bodyFacts47.cfix bodyFacts47.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st47.S2.tab) (Es := bodyEs47) (qs := bodyQs47)
    (ok := PRE_first_tail_x15_r0_body.st47.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site47 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts47
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site47 r hr) hi (MapOk.sub hm (sub_of_all bodySub47)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk47 r hr) hi hm ho hq)
    bodyLq47 rfl bodyNrLo47 (postSub_sound bodyPost47)
    (Nat.le_of_ble_eq_true bodyDrop47) (by decide) (Nat.le_of_ble_eq_true bodyDropH47) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN47) (by decide)
    bodyDv47 bodyDe47 bodyDl47 bodyDold47 bodyDfree47 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
