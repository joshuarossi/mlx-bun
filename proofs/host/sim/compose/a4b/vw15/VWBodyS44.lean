import host.sim.compose.a4b.vw15.VWBodyJ44
import host.sim.compose.a4b.vw15.VWBodySite44
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

theorem bodyCshift44 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S431.tab.length PRE_first_tail_x15_r0_body.s431.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P44.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.s433.ffi PRE_first_tail_x15_r0_body.s432.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_44
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_44
  have hcl : SSt (· < 1936) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S431.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_44] <;> decide) PRE_first_tail_x15_r0_body.cnodesK44 PRE_first_tail_x15_r0_body.cobjsK44
      PRE_first_tail_x15_r0_body.citemsK44 PRE_first_tail_x15_r0_body.cbd44 PRE_first_tail_x15_r0_body.csst44
  exact PRE_first_tail_x15_r0_body.cshift44 bodyNcl44 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_44] at this; exact this)


kernel_rfl bodyFramesEmpty44 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s432 a).isEmpty) = true
kernel_rfl bodyJsRoots44 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s431.next) PRE_first_tail_x15_r0_body.s433.trace PRE_first_tail_x15_r0_body.s433 = true
kernel_rfl bodyJsNative44 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s433.ffi) = true
kernel_rfl bodyLow44 : (PRE_first_tail_x15_r0_body.cws44 ++ PRE_first_tail_x15_r0_body.ws44).all (Nat.ble 9) = true
kernel_rfl bodyCntM44 : countersOkB PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.s432 = true
kernel_rfl bodyHi44 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).next setupP.E = true
kernel_rfl bodyNhi44 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge44 : bridgeOf PRE_first_tail_x15_r0_body.s432.ffi = bridgeOf PRE_first_tail_x15_r0_body.s431.ffi
kernel_rfl bodyNN44 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s431.ffi).nnext PRE_first_tail_x15_r0_body.P44.NL = true
kernel_rfl bodyXn44 : Nat.ble (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).next = true
kernel_rfl bodyLo44 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).next = true
theorem bodyFacts44 : BodySiteFacts PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.s432 PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S431 PRE_first_tail_x15_r0_body.S432 PRE_first_tail_x15_r0_body.S433
    PRE_first_tail_x15_r0_body.ws44 PRE_first_tail_x15_r0_body.cws44 PRE_first_tail_x15_r0_body.nr44 PRE_first_tail_x15_r0_body.pl44 PRE_first_tail_x15_r0_body.cl44 2709014 1936 PRE_first_tail_x15_r0_body.kd44 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.P44
    ⟨19061, 16159, 2709003, 1936⟩ ⟨19061, 16159, 2709004, 1936⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap44
  clean := bodyClean44
  cfix := PRE_first_tail_x15_r0_body.cfix44
  zpl := PRE_first_tail_x15_r0_body.zpl44
  zplnd := PRE_first_tail_x15_r0_body.zplnd44
  zn1 := PRE_first_tail_x15_r0_body.zn144
  zfirst := PRE_first_tail_x15_r0_body.zfirst44
  zscn := PRE_first_tail_x15_r0_body.zscn44
  zsmn := PRE_first_tail_x15_r0_body.zsmn44
  zgrow := PRE_first_tail_x15_r0_body.zgrow44
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab44
  zfresh := PRE_first_tail_x15_r0_body.zfresh44
  zcnd := PRE_first_tail_x15_r0_body.zcnd44
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi44
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt44
  zgP := PRE_first_tail_x15_r0_body.zg44_2665
  zkP := PRE_first_tail_x15_r0_body.zk44_2665
  zmP := PRE_first_tail_x15_r0_body.zm44_2665
  zgC := PRE_first_tail_x15_r0_body.zg44_2673467
  zkC := PRE_first_tail_x15_r0_body.zk44_2673467
  zmC := PRE_first_tail_x15_r0_body.zm44_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw44_2673472
  zwV := PRE_first_tail_x15_r0_body.zw44_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap44
  zclbd := PRE_first_tail_x15_r0_body.zclbd44
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap44 PRE_first_tail_x15_r0_body.stFoot44 PRE_first_tail_x15_r0_body.iso44 PRE_first_tail_x15_r0_body.zwr44
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP44
  csupp := PRE_first_tail_x15_r0_body.csupp44
  cbound := PRE_first_tail_x15_r0_body.cbound44
  zimg := PRE_first_tail_x15_r0_body.zimg44
  zctl := PRE_first_tail_x15_r0_body.zctl44
  zstack := PRE_first_tail_x15_r0_body.zstack44
  zjobs := PRE_first_tail_x15_r0_body.zjobs44
  zstores := PRE_first_tail_x15_r0_body.zstores44
  zroots := PRE_first_tail_x15_r0_body.zroots44
  znC := PRE_first_tail_x15_r0_body.znC44
  ctab := PRE_first_tail_x15_r0_body.ctab44
  zbin := PRE_first_tail_x15_r0_body.zbin44
  cbridge := PRE_first_tail_x15_r0_body.cbridge44
  sbridge := bodyBridge44
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj44
  cshiftR := fun h hNL => bodyCshift44 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN44
  raised := PRE_first_tail_x15_r0_body.raised44
  cbigs := PRE_first_tail_x15_r0_body.cbigs44
  cjcl := PRE_first_tail_x15_r0_body.cjcl44
  xnLe := Nat.le_of_ble_eq_true bodyXn44
  loLe := Nat.le_of_ble_eq_true bodyLo44
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB44
  cntM := bodyCntM44
  hiLe := Nat.le_of_ble_eq_true bodyHi44
  nhiLe := Nat.le_of_ble_eq_true bodyNhi44
  jsHeap := bodyJs44
  jsRoots := bodyJsRoots44
  jsNative := bodyJsNative44
  framesEmpty := bodyFramesEmpty44
  trailOld := by decide
  lowVars := bodyLow44

def bodyQs44 : List (Option Q) := []
noncomputable def bodyEs44 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr44.map fun r => nth? PRE_first_tail_x15_r0_body.st44.S2.tab r
kernel_rfl bodyResChk44 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs44 bodyQs44) = true
kernel_rfl bodyLq44 : bodyQs44.length = PRE_first_tail_x15_r0_body.cws44.length
kernel_rfl bodyNrLo44 : PRE_first_tail_x15_r0_body.nr44.all (Nat.ble PRE_first_tail_x15_r0_body.S431.tab.length) = true
kernel_rfl bodySub44 : (Oracles.PRE_first_tail_x15_r0_body.map_site44.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost44 : postSubB bodyM PRE_first_tail_x15_r0_body.ws44 PRE_first_tail_x15_r0_body.cws44 bodyQs44 = true
kernel_rfl bodyDrop44 : Nat.ble (19149 + (PRE_first_tail_x15_r0_body.s432.next - PRE_first_tail_x15_r0_body.s433.next)) 19159 = true
kernel_rfl bodyDropH44 : Nat.ble (327 + ((mlxOf PRE_first_tail_x15_r0_body.s432.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).next)) 327 = true
kernel_rfl bodyDropN44 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s432.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s433.ffi).nnext)) 0 = true
kernel_rfl bodyDv44 : bodyΘ.1.take 243 = bodyΘ.1.take 243 ++ PRE_first_tail_x15_r0_body.cws44
kernel_rfl bodyDe44 : bodyΘ.2.take 243 = bodyΘ.2.take 243 ++ PRE_first_tail_x15_r0_body.nr44.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st44.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 243) (bodyΘ.2.take 243)))
kernel_rfl bodyDl44 : (bodyΘ.1.take 243).length = (bodyΘ.2.take 243).length
kernel_rfl bodyDold44 : (bodyΘ.1.take 243).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws44).isNone && !PRE_first_tail_x15_r0_body.ws44.contains v) = true
kernel_rfl bodyDfree44 : (bodyΘ.2.take 243).all (fun e => (PRE_first_tail_x15_r0_body.cws44 ++ PRE_first_tail_x15_r0_body.ws44).all fun w => e.noVar w) = true

theorem bodyStep44 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19149, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.S431)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19159, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.S433) (98 + 1) :=
  bodySite bodyFacts44.cfix bodyFacts44.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st44.S2.tab) (Es := bodyEs44) (qs := bodyQs44)
    (ok := PRE_first_tail_x15_r0_body.st44.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site44 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts44
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site44 r hr) hi (MapOk.sub hm (sub_of_all bodySub44)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk44 r hr) hi hm ho hq)
    bodyLq44 rfl bodyNrLo44 (postSub_sound bodyPost44)
    (Nat.le_of_ble_eq_true bodyDrop44) (by decide) (Nat.le_of_ble_eq_true bodyDropH44) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN44) (by decide)
    bodyDv44 bodyDe44 bodyDl44 bodyDold44 bodyDfree44 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
