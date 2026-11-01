import host.sim.compose.a4b.vw15.VWBodyJ73
import host.sim.compose.a4b.vw15.VWBodySite73
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

theorem bodyCshift73 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S714.tab.length PRE_first_tail_x15_r0_body.s714.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P73.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P73 3200 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.s716.ffi PRE_first_tail_x15_r0_body.s715.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_73
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_73
  have hcl : SSt (· < 3200) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S714.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_73] <;> decide) PRE_first_tail_x15_r0_body.cnodesK73 PRE_first_tail_x15_r0_body.cobjsK73
      PRE_first_tail_x15_r0_body.citemsK73 PRE_first_tail_x15_r0_body.cbd73 PRE_first_tail_x15_r0_body.csst73
  exact PRE_first_tail_x15_r0_body.cshift73 bodyNcl73 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_73] at this; exact this)


kernel_rfl bodyFramesEmpty73 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s715 a).isEmpty) = true
kernel_rfl bodyJsRoots73 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s714.next) PRE_first_tail_x15_r0_body.s716.trace PRE_first_tail_x15_r0_body.s716 = true
kernel_rfl bodyJsNative73 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s716.ffi) = true
kernel_rfl bodyLow73 : (PRE_first_tail_x15_r0_body.cws73 ++ PRE_first_tail_x15_r0_body.ws73).all (Nat.ble 9) = true
kernel_rfl bodyCntM73 : countersOkB PRE_first_tail_x15_r0_body.s714 PRE_first_tail_x15_r0_body.s715 = true
kernel_rfl bodyHi73 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s716.ffi).next setupP.E = true
kernel_rfl bodyNhi73 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s716.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge73 : bridgeOf PRE_first_tail_x15_r0_body.s715.ffi = bridgeOf PRE_first_tail_x15_r0_body.s714.ffi
kernel_rfl bodyNN73 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s714.ffi).nnext PRE_first_tail_x15_r0_body.P73.NL = true
kernel_rfl bodyXn73 : Nat.ble (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s716.ffi).next = true
kernel_rfl bodyLo73 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s716.ffi).next = true
theorem bodyFacts73 : BodySiteFacts PRE_first_tail_x15_r0_body.s714 PRE_first_tail_x15_r0_body.s715 PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S714 PRE_first_tail_x15_r0_body.S715 PRE_first_tail_x15_r0_body.S716
    PRE_first_tail_x15_r0_body.ws73 PRE_first_tail_x15_r0_body.cws73 PRE_first_tail_x15_r0_body.nr73 PRE_first_tail_x15_r0_body.pl73 PRE_first_tail_x15_r0_body.cl73 2732457 3200 PRE_first_tail_x15_r0_body.kd73 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.P73
    ⟨19648, 16740, 2732455, 3200⟩ ⟨19648, 16740, 2732455, 3200⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap73
  clean := bodyClean73
  cfix := PRE_first_tail_x15_r0_body.cfix73
  zpl := PRE_first_tail_x15_r0_body.zpl73
  zplnd := PRE_first_tail_x15_r0_body.zplnd73
  zn1 := PRE_first_tail_x15_r0_body.zn173
  zfirst := PRE_first_tail_x15_r0_body.zfirst73
  zscn := PRE_first_tail_x15_r0_body.zscn73
  zsmn := PRE_first_tail_x15_r0_body.zsmn73
  zgrow := PRE_first_tail_x15_r0_body.zgrow73
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab73
  zfresh := PRE_first_tail_x15_r0_body.zfresh73
  zcnd := PRE_first_tail_x15_r0_body.zcnd73
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi73
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt73
  zgP := PRE_first_tail_x15_r0_body.zg73_2665
  zkP := PRE_first_tail_x15_r0_body.zk73_2665
  zmP := PRE_first_tail_x15_r0_body.zm73_2665
  zgC := PRE_first_tail_x15_r0_body.zg73_2673467
  zkC := PRE_first_tail_x15_r0_body.zk73_2673467
  zmC := PRE_first_tail_x15_r0_body.zm73_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw73_2673472
  zwV := PRE_first_tail_x15_r0_body.zw73_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap73
  zclbd := PRE_first_tail_x15_r0_body.zclbd73
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap73 PRE_first_tail_x15_r0_body.stFoot73 PRE_first_tail_x15_r0_body.iso73 PRE_first_tail_x15_r0_body.zwr73
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP73
  csupp := PRE_first_tail_x15_r0_body.csupp73
  cbound := PRE_first_tail_x15_r0_body.cbound73
  zimg := PRE_first_tail_x15_r0_body.zimg73
  zctl := PRE_first_tail_x15_r0_body.zctl73
  zstack := PRE_first_tail_x15_r0_body.zstack73
  zjobs := PRE_first_tail_x15_r0_body.zjobs73
  zstores := PRE_first_tail_x15_r0_body.zstores73
  zroots := PRE_first_tail_x15_r0_body.zroots73
  znC := PRE_first_tail_x15_r0_body.znC73
  ctab := PRE_first_tail_x15_r0_body.ctab73
  zbin := PRE_first_tail_x15_r0_body.zbin73
  cbridge := PRE_first_tail_x15_r0_body.cbridge73
  sbridge := bodyBridge73
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj73
  cshiftR := fun h hNL => bodyCshift73 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN73
  raised := PRE_first_tail_x15_r0_body.raised73
  cbigs := PRE_first_tail_x15_r0_body.cbigs73
  cjcl := PRE_first_tail_x15_r0_body.cjcl73
  xnLe := Nat.le_of_ble_eq_true bodyXn73
  loLe := Nat.le_of_ble_eq_true bodyLo73
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB73
  cntM := bodyCntM73
  hiLe := Nat.le_of_ble_eq_true bodyHi73
  nhiLe := Nat.le_of_ble_eq_true bodyNhi73
  jsHeap := bodyJs73
  jsRoots := bodyJsRoots73
  jsNative := bodyJsNative73
  framesEmpty := bodyFramesEmpty73
  trailOld := by decide
  lowVars := bodyLow73

def bodyQs73 : List (Option Q) := []
noncomputable def bodyEs73 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr73.map fun r => nth? PRE_first_tail_x15_r0_body.st73.S2.tab r
kernel_rfl bodyResChk73 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs73 bodyQs73) = true
kernel_rfl bodyLq73 : bodyQs73.length = PRE_first_tail_x15_r0_body.cws73.length
kernel_rfl bodyNrLo73 : PRE_first_tail_x15_r0_body.nr73.all (Nat.ble PRE_first_tail_x15_r0_body.S714.tab.length) = true
kernel_rfl bodySub73 : (Oracles.PRE_first_tail_x15_r0_body.map_site73.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost73 : postSubB bodyM PRE_first_tail_x15_r0_body.ws73 PRE_first_tail_x15_r0_body.cws73 bodyQs73 = true
kernel_rfl bodyDrop73 : Nat.ble (28396 + (PRE_first_tail_x15_r0_body.s715.next - PRE_first_tail_x15_r0_body.s716.next)) 28398 = true
kernel_rfl bodyDropH73 : Nat.ble (508 + ((mlxOf PRE_first_tail_x15_r0_body.s715.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s716.ffi).next)) 508 = true
kernel_rfl bodyDropN73 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s715.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s716.ffi).nnext)) 0 = true
kernel_rfl bodyDv73 : bodyΘ.1.take 396 = bodyΘ.1.take 396 ++ PRE_first_tail_x15_r0_body.cws73
kernel_rfl bodyDe73 : bodyΘ.2.take 396 = bodyΘ.2.take 396 ++ PRE_first_tail_x15_r0_body.nr73.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st73.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 396) (bodyΘ.2.take 396)))
kernel_rfl bodyDl73 : (bodyΘ.1.take 396).length = (bodyΘ.2.take 396).length
kernel_rfl bodyDold73 : (bodyΘ.1.take 396).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws73).isNone && !PRE_first_tail_x15_r0_body.ws73.contains v) = true
kernel_rfl bodyDfree73 : (bodyΘ.2.take 396).all (fun e => (PRE_first_tail_x15_r0_body.cws73 ++ PRE_first_tail_x15_r0_body.ws73).all fun w => e.noVar w) = true

theorem bodyStep73 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨28396, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s714 PRE_first_tail_x15_r0_body.S714)
      (bodyCut NB T tk π i x0 bodyΘ ⟨28398, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.S716) (27 + 1) :=
  bodySite bodyFacts73.cfix bodyFacts73.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st73.S2.tab) (Es := bodyEs73) (qs := bodyQs73)
    (ok := PRE_first_tail_x15_r0_body.st73.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site73 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts73
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site73 r hr) hi (MapOk.sub hm (sub_of_all bodySub73)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk73 r hr) hi hm ho hq)
    bodyLq73 rfl bodyNrLo73 (postSub_sound bodyPost73)
    (Nat.le_of_ble_eq_true bodyDrop73) (by decide) (Nat.le_of_ble_eq_true bodyDropH73) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN73) (by decide)
    bodyDv73 bodyDe73 bodyDl73 bodyDold73 bodyDfree73 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
