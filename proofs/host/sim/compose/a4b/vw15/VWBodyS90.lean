import host.sim.compose.a4b.vw15.VWBodyJ90
import host.sim.compose.a4b.vw15.VWBodySite90
import host.sim.compose.a4b.vw15.VWBodyOracles_22
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift90 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S879.tab.length PRE_first_tail_x15_r0_body.s879.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P90.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P90 3950 PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.s881.ffi PRE_first_tail_x15_r0_body.s880.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_90
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_90
  have hcl : SSt (· < 3950) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S879.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_90] <;> decide) PRE_first_tail_x15_r0_body.cnodesK90 PRE_first_tail_x15_r0_body.cobjsK90
      PRE_first_tail_x15_r0_body.citemsK90 PRE_first_tail_x15_r0_body.cbd90 PRE_first_tail_x15_r0_body.csst90
  exact PRE_first_tail_x15_r0_body.cshift90 bodyNcl90 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_90] at this; exact this)


kernel_rfl bodyFramesEmpty90 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s880 a).isEmpty) = true
kernel_rfl bodyJsRoots90 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s879.next) PRE_first_tail_x15_r0_body.s881.trace PRE_first_tail_x15_r0_body.s881 = true
kernel_rfl bodyJsNative90 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s881.ffi) = true
kernel_rfl bodyLow90 : (PRE_first_tail_x15_r0_body.cws90 ++ PRE_first_tail_x15_r0_body.ws90).all (Nat.ble 9) = true
kernel_rfl bodyCntM90 : countersOkB PRE_first_tail_x15_r0_body.s879 PRE_first_tail_x15_r0_body.s880 = true
kernel_rfl bodyHi90 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s881.ffi).next setupP.E = true
kernel_rfl bodyNhi90 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s881.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge90 : bridgeOf PRE_first_tail_x15_r0_body.s880.ffi = bridgeOf PRE_first_tail_x15_r0_body.s879.ffi
kernel_rfl bodyNN90 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s879.ffi).nnext PRE_first_tail_x15_r0_body.P90.NL = true
kernel_rfl bodyXn90 : Nat.ble (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s881.ffi).next = true
kernel_rfl bodyLo90 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s881.ffi).next = true
theorem bodyFacts90 : BodySiteFacts PRE_first_tail_x15_r0_body.s879 PRE_first_tail_x15_r0_body.s880 PRE_first_tail_x15_r0_body.s881 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S879 PRE_first_tail_x15_r0_body.S880 PRE_first_tail_x15_r0_body.S881
    PRE_first_tail_x15_r0_body.ws90 PRE_first_tail_x15_r0_body.cws90 PRE_first_tail_x15_r0_body.nr90 PRE_first_tail_x15_r0_body.pl90 PRE_first_tail_x15_r0_body.cl90 2747042 3950 PRE_first_tail_x15_r0_body.kd90 PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.P90
    ⟨19982, 17063, 2745887, 3932⟩ ⟨19985, 17090, 2745893, 3950⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap90
  clean := bodyClean90
  cfix := PRE_first_tail_x15_r0_body.cfix90
  zpl := PRE_first_tail_x15_r0_body.zpl90
  zplnd := PRE_first_tail_x15_r0_body.zplnd90
  zn1 := PRE_first_tail_x15_r0_body.zn190
  zfirst := PRE_first_tail_x15_r0_body.zfirst90
  zscn := PRE_first_tail_x15_r0_body.zscn90
  zsmn := PRE_first_tail_x15_r0_body.zsmn90
  zgrow := PRE_first_tail_x15_r0_body.zgrow90
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab90
  zfresh := PRE_first_tail_x15_r0_body.zfresh90
  zcnd := PRE_first_tail_x15_r0_body.zcnd90
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi90
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt90
  zgP := PRE_first_tail_x15_r0_body.zg90_2665
  zkP := PRE_first_tail_x15_r0_body.zk90_2665
  zmP := PRE_first_tail_x15_r0_body.zm90_2665
  zgC := PRE_first_tail_x15_r0_body.zg90_2673467
  zkC := PRE_first_tail_x15_r0_body.zk90_2673467
  zmC := PRE_first_tail_x15_r0_body.zm90_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw90_2673472
  zwV := PRE_first_tail_x15_r0_body.zw90_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap90
  zclbd := PRE_first_tail_x15_r0_body.zclbd90
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap90 PRE_first_tail_x15_r0_body.stFoot90 PRE_first_tail_x15_r0_body.iso90 PRE_first_tail_x15_r0_body.zwr90
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP90
  csupp := PRE_first_tail_x15_r0_body.csupp90
  cbound := PRE_first_tail_x15_r0_body.cbound90
  zimg := PRE_first_tail_x15_r0_body.zimg90
  zctl := PRE_first_tail_x15_r0_body.zctl90
  zstack := PRE_first_tail_x15_r0_body.zstack90
  zjobs := PRE_first_tail_x15_r0_body.zjobs90
  zstores := PRE_first_tail_x15_r0_body.zstores90
  zroots := PRE_first_tail_x15_r0_body.zroots90
  znC := PRE_first_tail_x15_r0_body.znC90
  ctab := PRE_first_tail_x15_r0_body.ctab90
  zbin := PRE_first_tail_x15_r0_body.zbin90
  cbridge := PRE_first_tail_x15_r0_body.cbridge90
  sbridge := bodyBridge90
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj90
  cshiftR := fun h hNL => bodyCshift90 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN90
  raised := PRE_first_tail_x15_r0_body.raised90
  cbigs := PRE_first_tail_x15_r0_body.cbigs90
  cjcl := PRE_first_tail_x15_r0_body.cjcl90
  xnLe := Nat.le_of_ble_eq_true bodyXn90
  loLe := Nat.le_of_ble_eq_true bodyLo90
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB90
  cntM := bodyCntM90
  hiLe := Nat.le_of_ble_eq_true bodyHi90
  nhiLe := Nat.le_of_ble_eq_true bodyNhi90
  jsHeap := bodyJs90
  jsRoots := bodyJsRoots90
  jsNative := bodyJsNative90
  framesEmpty := bodyFramesEmpty90
  trailOld := by decide
  lowVars := bodyLow90

def bodyQs90 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs90 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr90.map fun r => nth? PRE_first_tail_x15_r0_body.st90.S5.tab r
kernel_rfl bodyResChk90 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs90 bodyQs90) = true
kernel_rfl bodyLq90 : bodyQs90.length = PRE_first_tail_x15_r0_body.cws90.length
kernel_rfl bodyNrLo90 : PRE_first_tail_x15_r0_body.nr90.all (Nat.ble PRE_first_tail_x15_r0_body.S879.tab.length) = true
kernel_rfl bodySub90 : (Oracles.PRE_first_tail_x15_r0_body.map_site90.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost90 : postSubB bodyM PRE_first_tail_x15_r0_body.ws90 PRE_first_tail_x15_r0_body.cws90 bodyQs90 = true
kernel_rfl bodyDrop90 : Nat.ble (33423 + (PRE_first_tail_x15_r0_body.s880.next - PRE_first_tail_x15_r0_body.s881.next)) 34572 = true
kernel_rfl bodyDropH90 : Nat.ble (610 + ((mlxOf PRE_first_tail_x15_r0_body.s880.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s881.ffi).next)) 635 = true
kernel_rfl bodyDropN90 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s880.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s881.ffi).nnext)) 0 = true
kernel_rfl bodyDv90 : bodyΘ.1.take 495 = bodyΘ.1.take 477 ++ PRE_first_tail_x15_r0_body.cws90
kernel_rfl bodyDe90 : bodyΘ.2.take 495 = bodyΘ.2.take 477 ++ PRE_first_tail_x15_r0_body.nr90.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st90.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 477) (bodyΘ.2.take 477)))
kernel_rfl bodyDl90 : (bodyΘ.1.take 477).length = (bodyΘ.2.take 477).length
kernel_rfl bodyDold90 : (bodyΘ.1.take 477).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws90).isNone && !PRE_first_tail_x15_r0_body.ws90.contains v) = true
kernel_rfl bodyDfree90 : (bodyΘ.2.take 495).all (fun e => (PRE_first_tail_x15_r0_body.cws90 ++ PRE_first_tail_x15_r0_body.ws90).all fun w => e.noVar w) = true

theorem bodyStep90 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨33423, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s879 PRE_first_tail_x15_r0_body.S879)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34572, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s881 PRE_first_tail_x15_r0_body.S881) (11334 + 1) :=
  bodySite bodyFacts90.cfix bodyFacts90.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st90.S5.tab) (Es := bodyEs90) (qs := bodyQs90)
    (ok := PRE_first_tail_x15_r0_body.st90.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site90 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts90
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site90 r hr) hi (MapOk.sub hm (sub_of_all bodySub90)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk90 r hr) hi hm ho hq)
    bodyLq90 rfl bodyNrLo90 (postSub_sound bodyPost90)
    (Nat.le_of_ble_eq_true bodyDrop90) (by decide) (Nat.le_of_ble_eq_true bodyDropH90) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN90) (by decide)
    bodyDv90 bodyDe90 bodyDl90 bodyDold90 bodyDfree90 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
