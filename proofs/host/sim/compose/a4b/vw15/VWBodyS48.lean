import host.sim.compose.a4b.vw15.VWBodyJ48
import host.sim.compose.a4b.vw15.VWBodySite48
import host.sim.compose.a4b.vw15.VWBodyOracles_12
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

theorem bodyCshift48 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S476.tab.length PRE_first_tail_x15_r0_body.s476.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P48.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.s478.ffi PRE_first_tail_x15_r0_body.s477.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_48
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_48
  have hcl : SSt (· < 2153) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S476.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_48] <;> decide) PRE_first_tail_x15_r0_body.cnodesK48 PRE_first_tail_x15_r0_body.cobjsK48
      PRE_first_tail_x15_r0_body.citemsK48 PRE_first_tail_x15_r0_body.cbd48 PRE_first_tail_x15_r0_body.csst48
  exact PRE_first_tail_x15_r0_body.cshift48 bodyNcl48 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_48] at this; exact this)


kernel_rfl bodyFramesEmpty48 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s477 a).isEmpty) = true
kernel_rfl bodyJsRoots48 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s476.next) PRE_first_tail_x15_r0_body.s478.trace PRE_first_tail_x15_r0_body.s478 = true
kernel_rfl bodyJsNative48 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s478.ffi) = true
kernel_rfl bodyLow48 : (PRE_first_tail_x15_r0_body.cws48 ++ PRE_first_tail_x15_r0_body.ws48).all (Nat.ble 9) = true
kernel_rfl bodyCntM48 : countersOkB PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.s477 = true
kernel_rfl bodyHi48 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).next setupP.E = true
kernel_rfl bodyNhi48 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge48 : bridgeOf PRE_first_tail_x15_r0_body.s477.ffi = bridgeOf PRE_first_tail_x15_r0_body.s476.ffi
kernel_rfl bodyNN48 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s476.ffi).nnext PRE_first_tail_x15_r0_body.P48.NL = true
kernel_rfl bodyXn48 : Nat.ble (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).next = true
kernel_rfl bodyLo48 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).next = true
theorem bodyFacts48 : BodySiteFacts PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.s477 PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S476 PRE_first_tail_x15_r0_body.S477 PRE_first_tail_x15_r0_body.S478
    PRE_first_tail_x15_r0_body.ws48 PRE_first_tail_x15_r0_body.cws48 PRE_first_tail_x15_r0_body.nr48 PRE_first_tail_x15_r0_body.pl48 PRE_first_tail_x15_r0_body.cl48 2714278 2153 PRE_first_tail_x15_r0_body.kd48 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.P48
    ⟨19160, 16226, 2713123, 2135⟩ ⟨19163, 16253, 2713129, 2153⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap48
  clean := bodyClean48
  cfix := PRE_first_tail_x15_r0_body.cfix48
  zpl := PRE_first_tail_x15_r0_body.zpl48
  zplnd := PRE_first_tail_x15_r0_body.zplnd48
  zn1 := PRE_first_tail_x15_r0_body.zn148
  zfirst := PRE_first_tail_x15_r0_body.zfirst48
  zscn := PRE_first_tail_x15_r0_body.zscn48
  zsmn := PRE_first_tail_x15_r0_body.zsmn48
  zgrow := PRE_first_tail_x15_r0_body.zgrow48
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab48
  zfresh := PRE_first_tail_x15_r0_body.zfresh48
  zcnd := PRE_first_tail_x15_r0_body.zcnd48
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi48
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt48
  zgP := PRE_first_tail_x15_r0_body.zg48_2665
  zkP := PRE_first_tail_x15_r0_body.zk48_2665
  zmP := PRE_first_tail_x15_r0_body.zm48_2665
  zgC := PRE_first_tail_x15_r0_body.zg48_2673467
  zkC := PRE_first_tail_x15_r0_body.zk48_2673467
  zmC := PRE_first_tail_x15_r0_body.zm48_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw48_2673472
  zwV := PRE_first_tail_x15_r0_body.zw48_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap48
  zclbd := PRE_first_tail_x15_r0_body.zclbd48
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap48 PRE_first_tail_x15_r0_body.stFoot48 PRE_first_tail_x15_r0_body.iso48 PRE_first_tail_x15_r0_body.zwr48
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP48
  csupp := PRE_first_tail_x15_r0_body.csupp48
  cbound := PRE_first_tail_x15_r0_body.cbound48
  zimg := PRE_first_tail_x15_r0_body.zimg48
  zctl := PRE_first_tail_x15_r0_body.zctl48
  zstack := PRE_first_tail_x15_r0_body.zstack48
  zjobs := PRE_first_tail_x15_r0_body.zjobs48
  zstores := PRE_first_tail_x15_r0_body.zstores48
  zroots := PRE_first_tail_x15_r0_body.zroots48
  znC := PRE_first_tail_x15_r0_body.znC48
  ctab := PRE_first_tail_x15_r0_body.ctab48
  zbin := PRE_first_tail_x15_r0_body.zbin48
  cbridge := PRE_first_tail_x15_r0_body.cbridge48
  sbridge := bodyBridge48
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj48
  cshiftR := fun h hNL => bodyCshift48 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN48
  raised := PRE_first_tail_x15_r0_body.raised48
  cbigs := PRE_first_tail_x15_r0_body.cbigs48
  cjcl := PRE_first_tail_x15_r0_body.cjcl48
  xnLe := Nat.le_of_ble_eq_true bodyXn48
  loLe := Nat.le_of_ble_eq_true bodyLo48
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB48
  cntM := bodyCntM48
  hiLe := Nat.le_of_ble_eq_true bodyHi48
  nhiLe := Nat.le_of_ble_eq_true bodyNhi48
  jsHeap := bodyJs48
  jsRoots := bodyJsRoots48
  jsNative := bodyJsNative48
  framesEmpty := bodyFramesEmpty48
  trailOld := by decide
  lowVars := bodyLow48

def bodyQs48 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs48 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr48.map fun r => nth? PRE_first_tail_x15_r0_body.st48.S5.tab r
kernel_rfl bodyResChk48 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs48 bodyQs48) = true
kernel_rfl bodyLq48 : bodyQs48.length = PRE_first_tail_x15_r0_body.cws48.length
kernel_rfl bodyNrLo48 : PRE_first_tail_x15_r0_body.nr48.all (Nat.ble PRE_first_tail_x15_r0_body.S476.tab.length) = true
kernel_rfl bodySub48 : (Oracles.PRE_first_tail_x15_r0_body.map_site48.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost48 : postSubB bodyM PRE_first_tail_x15_r0_body.ws48 PRE_first_tail_x15_r0_body.cws48 bodyQs48 = true
kernel_rfl bodyDrop48 : Nat.ble (19530 + (PRE_first_tail_x15_r0_body.s477.next - PRE_first_tail_x15_r0_body.s478.next)) 20679 = true
kernel_rfl bodyDropH48 : Nat.ble (329 + ((mlxOf PRE_first_tail_x15_r0_body.s477.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).next)) 354 = true
kernel_rfl bodyDropN48 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s477.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s478.ffi).nnext)) 0 = true
kernel_rfl bodyDv48 : bodyΘ.1.take 270 = bodyΘ.1.take 252 ++ PRE_first_tail_x15_r0_body.cws48
kernel_rfl bodyDe48 : bodyΘ.2.take 270 = bodyΘ.2.take 252 ++ PRE_first_tail_x15_r0_body.nr48.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st48.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 252) (bodyΘ.2.take 252)))
kernel_rfl bodyDl48 : (bodyΘ.1.take 252).length = (bodyΘ.2.take 252).length
kernel_rfl bodyDold48 : (bodyΘ.1.take 252).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws48).isNone && !PRE_first_tail_x15_r0_body.ws48.contains v) = true
kernel_rfl bodyDfree48 : (bodyΘ.2.take 270).all (fun e => (PRE_first_tail_x15_r0_body.cws48 ++ PRE_first_tail_x15_r0_body.ws48).all fun w => e.noVar w) = true

theorem bodyStep48 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19530, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.S476)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20679, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.S478) (11334 + 1) :=
  bodySite bodyFacts48.cfix bodyFacts48.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st48.S5.tab) (Es := bodyEs48) (qs := bodyQs48)
    (ok := PRE_first_tail_x15_r0_body.st48.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site48 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts48
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site48 r hr) hi (MapOk.sub hm (sub_of_all bodySub48)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk48 r hr) hi hm ho hq)
    bodyLq48 rfl bodyNrLo48 (postSub_sound bodyPost48)
    (Nat.le_of_ble_eq_true bodyDrop48) (by decide) (Nat.le_of_ble_eq_true bodyDropH48) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN48) (by decide)
    bodyDv48 bodyDe48 bodyDl48 bodyDold48 bodyDfree48 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
