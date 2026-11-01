import host.sim.compose.a4b.vw15.VWBodyJ72
import host.sim.compose.a4b.vw15.VWBodySite72
import host.sim.compose.a4b.vw15.VWBodyOracles_18
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift72 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S706.tab.length PRE_first_tail_x15_r0_body.s706.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P72.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P72 3179 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.s708.ffi PRE_first_tail_x15_r0_body.s707.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_72
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_72
  have hcl : SSt (· < 3179) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S706.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_72] <;> decide) PRE_first_tail_x15_r0_body.cnodesK72 PRE_first_tail_x15_r0_body.cobjsK72
      PRE_first_tail_x15_r0_body.citemsK72 PRE_first_tail_x15_r0_body.cbd72 PRE_first_tail_x15_r0_body.csst72
  exact PRE_first_tail_x15_r0_body.cshift72 bodyNcl72 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_72] at this; exact this)


kernel_rfl bodyFramesEmpty72 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s707 a).isEmpty) = true
kernel_rfl bodyJsRoots72 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s706.next) PRE_first_tail_x15_r0_body.s708.trace PRE_first_tail_x15_r0_body.s708 = true
kernel_rfl bodyJsNative72 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s708.ffi) = true
kernel_rfl bodyLow72 : (PRE_first_tail_x15_r0_body.cws72 ++ PRE_first_tail_x15_r0_body.ws72).all (Nat.ble 9) = true
kernel_rfl bodyCntM72 : countersOkB PRE_first_tail_x15_r0_body.s706 PRE_first_tail_x15_r0_body.s707 = true
kernel_rfl bodyHi72 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s708.ffi).next setupP.E = true
kernel_rfl bodyNhi72 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s708.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge72 : bridgeOf PRE_first_tail_x15_r0_body.s707.ffi = bridgeOf PRE_first_tail_x15_r0_body.s706.ffi
kernel_rfl bodyNN72 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s706.ffi).nnext PRE_first_tail_x15_r0_body.P72.NL = true
kernel_rfl bodyXn72 : Nat.ble (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s708.ffi).next = true
kernel_rfl bodyLo72 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s708.ffi).next = true
theorem bodyFacts72 : BodySiteFacts PRE_first_tail_x15_r0_body.s706 PRE_first_tail_x15_r0_body.s707 PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S706 PRE_first_tail_x15_r0_body.S707 PRE_first_tail_x15_r0_body.S708
    PRE_first_tail_x15_r0_body.ws72 PRE_first_tail_x15_r0_body.cws72 PRE_first_tail_x15_r0_body.nr72 PRE_first_tail_x15_r0_body.pl72 PRE_first_tail_x15_r0_body.cl72 2733114 3179 PRE_first_tail_x15_r0_body.kd72 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.P72
    ⟨19632, 16700, 2731959, 3161⟩ ⟨19635, 16727, 2731965, 3179⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap72
  clean := bodyClean72
  cfix := PRE_first_tail_x15_r0_body.cfix72
  zpl := PRE_first_tail_x15_r0_body.zpl72
  zplnd := PRE_first_tail_x15_r0_body.zplnd72
  zn1 := PRE_first_tail_x15_r0_body.zn172
  zfirst := PRE_first_tail_x15_r0_body.zfirst72
  zscn := PRE_first_tail_x15_r0_body.zscn72
  zsmn := PRE_first_tail_x15_r0_body.zsmn72
  zgrow := PRE_first_tail_x15_r0_body.zgrow72
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab72
  zfresh := PRE_first_tail_x15_r0_body.zfresh72
  zcnd := PRE_first_tail_x15_r0_body.zcnd72
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi72
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt72
  zgP := PRE_first_tail_x15_r0_body.zg72_2665
  zkP := PRE_first_tail_x15_r0_body.zk72_2665
  zmP := PRE_first_tail_x15_r0_body.zm72_2665
  zgC := PRE_first_tail_x15_r0_body.zg72_2673467
  zkC := PRE_first_tail_x15_r0_body.zk72_2673467
  zmC := PRE_first_tail_x15_r0_body.zm72_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw72_2673472
  zwV := PRE_first_tail_x15_r0_body.zw72_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap72
  zclbd := PRE_first_tail_x15_r0_body.zclbd72
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap72 PRE_first_tail_x15_r0_body.stFoot72 PRE_first_tail_x15_r0_body.iso72 PRE_first_tail_x15_r0_body.zwr72
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP72
  csupp := PRE_first_tail_x15_r0_body.csupp72
  cbound := PRE_first_tail_x15_r0_body.cbound72
  zimg := PRE_first_tail_x15_r0_body.zimg72
  zctl := PRE_first_tail_x15_r0_body.zctl72
  zstack := PRE_first_tail_x15_r0_body.zstack72
  zjobs := PRE_first_tail_x15_r0_body.zjobs72
  zstores := PRE_first_tail_x15_r0_body.zstores72
  zroots := PRE_first_tail_x15_r0_body.zroots72
  znC := PRE_first_tail_x15_r0_body.znC72
  ctab := PRE_first_tail_x15_r0_body.ctab72
  zbin := PRE_first_tail_x15_r0_body.zbin72
  cbridge := PRE_first_tail_x15_r0_body.cbridge72
  sbridge := bodyBridge72
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj72
  cshiftR := fun h hNL => bodyCshift72 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN72
  raised := PRE_first_tail_x15_r0_body.raised72
  cbigs := PRE_first_tail_x15_r0_body.cbigs72
  cjcl := PRE_first_tail_x15_r0_body.cjcl72
  xnLe := Nat.le_of_ble_eq_true bodyXn72
  loLe := Nat.le_of_ble_eq_true bodyLo72
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB72
  cntM := bodyCntM72
  hiLe := Nat.le_of_ble_eq_true bodyHi72
  nhiLe := Nat.le_of_ble_eq_true bodyNhi72
  jsHeap := bodyJs72
  jsRoots := bodyJsRoots72
  jsNative := bodyJsNative72
  framesEmpty := bodyFramesEmpty72
  trailOld := by decide
  lowVars := bodyLow72

def bodyQs72 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs72 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr72.map fun r => nth? PRE_first_tail_x15_r0_body.st72.S5.tab r
kernel_rfl bodyResChk72 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs72 bodyQs72) = true
kernel_rfl bodyLq72 : bodyQs72.length = PRE_first_tail_x15_r0_body.cws72.length
kernel_rfl bodyNrLo72 : PRE_first_tail_x15_r0_body.nr72.all (Nat.ble PRE_first_tail_x15_r0_body.S706.tab.length) = true
kernel_rfl bodySub72 : (Oracles.PRE_first_tail_x15_r0_body.map_site72.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost72 : postSubB bodyM PRE_first_tail_x15_r0_body.ws72 PRE_first_tail_x15_r0_body.cws72 bodyQs72 = true
kernel_rfl bodyDrop72 : Nat.ble (27247 + (PRE_first_tail_x15_r0_body.s707.next - PRE_first_tail_x15_r0_body.s708.next)) 28396 = true
kernel_rfl bodyDropH72 : Nat.ble (483 + ((mlxOf PRE_first_tail_x15_r0_body.s707.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s708.ffi).next)) 508 = true
kernel_rfl bodyDropN72 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s707.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s708.ffi).nnext)) 0 = true
kernel_rfl bodyDv72 : bodyΘ.1.take 396 = bodyΘ.1.take 378 ++ PRE_first_tail_x15_r0_body.cws72
kernel_rfl bodyDe72 : bodyΘ.2.take 396 = bodyΘ.2.take 378 ++ PRE_first_tail_x15_r0_body.nr72.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st72.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 378) (bodyΘ.2.take 378)))
kernel_rfl bodyDl72 : (bodyΘ.1.take 378).length = (bodyΘ.2.take 378).length
kernel_rfl bodyDold72 : (bodyΘ.1.take 378).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws72).isNone && !PRE_first_tail_x15_r0_body.ws72.contains v) = true
kernel_rfl bodyDfree72 : (bodyΘ.2.take 396).all (fun e => (PRE_first_tail_x15_r0_body.cws72 ++ PRE_first_tail_x15_r0_body.ws72).all fun w => e.noVar w) = true

theorem bodyStep72 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨27247, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s706 PRE_first_tail_x15_r0_body.S706)
      (bodyCut NB T tk π i x0 bodyΘ ⟨28396, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.S708) (11334 + 1) :=
  bodySite bodyFacts72.cfix bodyFacts72.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st72.S5.tab) (Es := bodyEs72) (qs := bodyQs72)
    (ok := PRE_first_tail_x15_r0_body.st72.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site72 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts72
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site72 r hr) hi (MapOk.sub hm (sub_of_all bodySub72)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk72 r hr) hi hm ho hq)
    bodyLq72 rfl bodyNrLo72 (postSub_sound bodyPost72)
    (Nat.le_of_ble_eq_true bodyDrop72) (by decide) (Nat.le_of_ble_eq_true bodyDropH72) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN72) (by decide)
    bodyDv72 bodyDe72 bodyDl72 bodyDold72 bodyDfree72 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
