import host.sim.compose.a4b.vw15.VWBodyJ75
import host.sim.compose.a4b.vw15.VWBodySite75
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

theorem bodyCshift75 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S735.tab.length PRE_first_tail_x15_r0_body.s735.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P75.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P75 3308 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.s737.ffi PRE_first_tail_x15_r0_body.s736.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_75
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_75
  have hcl : SSt (· < 3308) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S735.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_75] <;> decide) PRE_first_tail_x15_r0_body.cnodesK75 PRE_first_tail_x15_r0_body.cobjsK75
      PRE_first_tail_x15_r0_body.citemsK75 PRE_first_tail_x15_r0_body.cbd75 PRE_first_tail_x15_r0_body.csst75
  exact PRE_first_tail_x15_r0_body.cshift75 bodyNcl75 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_75] at this; exact this)


kernel_rfl bodyFramesEmpty75 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s736 a).isEmpty) = true
kernel_rfl bodyJsRoots75 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s735.next) PRE_first_tail_x15_r0_body.s737.trace PRE_first_tail_x15_r0_body.s737 = true
kernel_rfl bodyJsNative75 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s737.ffi) = true
kernel_rfl bodyLow75 : (PRE_first_tail_x15_r0_body.cws75 ++ PRE_first_tail_x15_r0_body.ws75).all (Nat.ble 9) = true
kernel_rfl bodyCntM75 : countersOkB PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.s736 = true
kernel_rfl bodyHi75 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s737.ffi).next setupP.E = true
kernel_rfl bodyNhi75 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s737.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge75 : bridgeOf PRE_first_tail_x15_r0_body.s736.ffi = bridgeOf PRE_first_tail_x15_r0_body.s735.ffi
kernel_rfl bodyNN75 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s735.ffi).nnext PRE_first_tail_x15_r0_body.P75.NL = true
kernel_rfl bodyXn75 : Nat.ble (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s737.ffi).next = true
kernel_rfl bodyLo75 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s737.ffi).next = true
theorem bodyFacts75 : BodySiteFacts PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.s736 PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S735 PRE_first_tail_x15_r0_body.S736 PRE_first_tail_x15_r0_body.S737
    PRE_first_tail_x15_r0_body.ws75 PRE_first_tail_x15_r0_body.cws75 PRE_first_tail_x15_r0_body.nr75 PRE_first_tail_x15_r0_body.pl75 PRE_first_tail_x15_r0_body.cl75 2735370 3308 PRE_first_tail_x15_r0_body.kd75 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.P75
    ⟨19689, 16763, 2734215, 3290⟩ ⟨19692, 16790, 2734221, 3308⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap75
  clean := bodyClean75
  cfix := PRE_first_tail_x15_r0_body.cfix75
  zpl := PRE_first_tail_x15_r0_body.zpl75
  zplnd := PRE_first_tail_x15_r0_body.zplnd75
  zn1 := PRE_first_tail_x15_r0_body.zn175
  zfirst := PRE_first_tail_x15_r0_body.zfirst75
  zscn := PRE_first_tail_x15_r0_body.zscn75
  zsmn := PRE_first_tail_x15_r0_body.zsmn75
  zgrow := PRE_first_tail_x15_r0_body.zgrow75
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab75
  zfresh := PRE_first_tail_x15_r0_body.zfresh75
  zcnd := PRE_first_tail_x15_r0_body.zcnd75
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi75
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt75
  zgP := PRE_first_tail_x15_r0_body.zg75_2665
  zkP := PRE_first_tail_x15_r0_body.zk75_2665
  zmP := PRE_first_tail_x15_r0_body.zm75_2665
  zgC := PRE_first_tail_x15_r0_body.zg75_2673467
  zkC := PRE_first_tail_x15_r0_body.zk75_2673467
  zmC := PRE_first_tail_x15_r0_body.zm75_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw75_2673472
  zwV := PRE_first_tail_x15_r0_body.zw75_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap75
  zclbd := PRE_first_tail_x15_r0_body.zclbd75
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap75 PRE_first_tail_x15_r0_body.stFoot75 PRE_first_tail_x15_r0_body.iso75 PRE_first_tail_x15_r0_body.zwr75
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP75
  csupp := PRE_first_tail_x15_r0_body.csupp75
  cbound := PRE_first_tail_x15_r0_body.cbound75
  zimg := PRE_first_tail_x15_r0_body.zimg75
  zctl := PRE_first_tail_x15_r0_body.zctl75
  zstack := PRE_first_tail_x15_r0_body.zstack75
  zjobs := PRE_first_tail_x15_r0_body.zjobs75
  zstores := PRE_first_tail_x15_r0_body.zstores75
  zroots := PRE_first_tail_x15_r0_body.zroots75
  znC := PRE_first_tail_x15_r0_body.znC75
  ctab := PRE_first_tail_x15_r0_body.ctab75
  zbin := PRE_first_tail_x15_r0_body.zbin75
  cbridge := PRE_first_tail_x15_r0_body.cbridge75
  sbridge := bodyBridge75
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj75
  cshiftR := fun h hNL => bodyCshift75 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN75
  raised := PRE_first_tail_x15_r0_body.raised75
  cbigs := PRE_first_tail_x15_r0_body.cbigs75
  cjcl := PRE_first_tail_x15_r0_body.cjcl75
  xnLe := Nat.le_of_ble_eq_true bodyXn75
  loLe := Nat.le_of_ble_eq_true bodyLo75
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB75
  cntM := bodyCntM75
  hiLe := Nat.le_of_ble_eq_true bodyHi75
  nhiLe := Nat.le_of_ble_eq_true bodyNhi75
  jsHeap := bodyJs75
  jsRoots := bodyJsRoots75
  jsNative := bodyJsNative75
  framesEmpty := bodyFramesEmpty75
  trailOld := by decide
  lowVars := bodyLow75

def bodyQs75 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs75 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr75.map fun r => nth? PRE_first_tail_x15_r0_body.st75.S5.tab r
kernel_rfl bodyResChk75 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs75 bodyQs75) = true
kernel_rfl bodyLq75 : bodyQs75.length = PRE_first_tail_x15_r0_body.cws75.length
kernel_rfl bodyNrLo75 : PRE_first_tail_x15_r0_body.nr75.all (Nat.ble PRE_first_tail_x15_r0_body.S735.tab.length) = true
kernel_rfl bodySub75 : (Oracles.PRE_first_tail_x15_r0_body.map_site75.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost75 : postSubB bodyM PRE_first_tail_x15_r0_body.ws75 PRE_first_tail_x15_r0_body.cws75 bodyQs75 = true
kernel_rfl bodyDrop75 : Nat.ble (28408 + (PRE_first_tail_x15_r0_body.s736.next - PRE_first_tail_x15_r0_body.s737.next)) 29557 = true
kernel_rfl bodyDropH75 : Nat.ble (508 + ((mlxOf PRE_first_tail_x15_r0_body.s736.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s737.ffi).next)) 533 = true
kernel_rfl bodyDropN75 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s736.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s737.ffi).nnext)) 0 = true
kernel_rfl bodyDv75 : bodyΘ.1.take 414 = bodyΘ.1.take 396 ++ PRE_first_tail_x15_r0_body.cws75
kernel_rfl bodyDe75 : bodyΘ.2.take 414 = bodyΘ.2.take 396 ++ PRE_first_tail_x15_r0_body.nr75.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st75.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 396) (bodyΘ.2.take 396)))
kernel_rfl bodyDl75 : (bodyΘ.1.take 396).length = (bodyΘ.2.take 396).length
kernel_rfl bodyDold75 : (bodyΘ.1.take 396).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws75).isNone && !PRE_first_tail_x15_r0_body.ws75.contains v) = true
kernel_rfl bodyDfree75 : (bodyΘ.2.take 414).all (fun e => (PRE_first_tail_x15_r0_body.cws75 ++ PRE_first_tail_x15_r0_body.ws75).all fun w => e.noVar w) = true

theorem bodyStep75 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨28408, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.S735)
      (bodyCut NB T tk π i x0 bodyΘ ⟨29557, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.S737) (11334 + 1) :=
  bodySite bodyFacts75.cfix bodyFacts75.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st75.S5.tab) (Es := bodyEs75) (qs := bodyQs75)
    (ok := PRE_first_tail_x15_r0_body.st75.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site75 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts75
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site75 r hr) hi (MapOk.sub hm (sub_of_all bodySub75)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk75 r hr) hi hm ho hq)
    bodyLq75 rfl bodyNrLo75 (postSub_sound bodyPost75)
    (Nat.le_of_ble_eq_true bodyDrop75) (by decide) (Nat.le_of_ble_eq_true bodyDropH75) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN75) (by decide)
    bodyDv75 bodyDe75 bodyDl75 bodyDold75 bodyDfree75 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
