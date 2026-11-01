import host.sim.compose.a4b.vw15.VWBodyJ15
import host.sim.compose.a4b.vw15.VWBodySite15
import host.sim.compose.a4b.vw15.VWBodyOracles_3
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift15 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S160.tab.length PRE_first_tail_x15_r0_body.s160.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P15.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P15 743 PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.s162.ffi PRE_first_tail_x15_r0_body.s161.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_15
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_15
  have hcl : SSt (· < 743) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S160.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_15] <;> decide) PRE_first_tail_x15_r0_body.cnodesK15 PRE_first_tail_x15_r0_body.cobjsK15
      PRE_first_tail_x15_r0_body.citemsK15 PRE_first_tail_x15_r0_body.cbd15 PRE_first_tail_x15_r0_body.csst15
  exact PRE_first_tail_x15_r0_body.cshift15 bodyNcl15 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_15] at this; exact this)


kernel_rfl bodyFramesEmpty15 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s161 a).isEmpty) = true
kernel_rfl bodyJsRoots15 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s160.next) PRE_first_tail_x15_r0_body.s162.trace PRE_first_tail_x15_r0_body.s162 = true
kernel_rfl bodyJsNative15 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s162.ffi) = true
kernel_rfl bodyLow15 : (PRE_first_tail_x15_r0_body.cws15 ++ PRE_first_tail_x15_r0_body.ws15).all (Nat.ble 9) = true
kernel_rfl bodyCntM15 : countersOkB PRE_first_tail_x15_r0_body.s160 PRE_first_tail_x15_r0_body.s161 = true
kernel_rfl bodyHi15 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s162.ffi).next setupP.E = true
kernel_rfl bodyNhi15 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s162.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge15 : bridgeOf PRE_first_tail_x15_r0_body.s161.ffi = bridgeOf PRE_first_tail_x15_r0_body.s160.ffi
kernel_rfl bodyNN15 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s160.ffi).nnext PRE_first_tail_x15_r0_body.P15.NL = true
kernel_rfl bodyXn15 : Nat.ble (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s162.ffi).next = true
kernel_rfl bodyLo15 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s162.ffi).next = true
theorem bodyFacts15 : BodySiteFacts PRE_first_tail_x15_r0_body.s160 PRE_first_tail_x15_r0_body.s161 PRE_first_tail_x15_r0_body.s162 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S160 PRE_first_tail_x15_r0_body.S161 PRE_first_tail_x15_r0_body.S162
    PRE_first_tail_x15_r0_body.ws15 PRE_first_tail_x15_r0_body.cws15 PRE_first_tail_x15_r0_body.nr15 PRE_first_tail_x15_r0_body.pl15 PRE_first_tail_x15_r0_body.cl15 2688286 743 PRE_first_tail_x15_r0_body.kd15 PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.P15
    ⟨18509, 15578, 2687131, 725⟩ ⟨18512, 15605, 2687137, 743⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap15
  clean := bodyClean15
  cfix := PRE_first_tail_x15_r0_body.cfix15
  zpl := PRE_first_tail_x15_r0_body.zpl15
  zplnd := PRE_first_tail_x15_r0_body.zplnd15
  zn1 := PRE_first_tail_x15_r0_body.zn115
  zfirst := PRE_first_tail_x15_r0_body.zfirst15
  zscn := PRE_first_tail_x15_r0_body.zscn15
  zsmn := PRE_first_tail_x15_r0_body.zsmn15
  zgrow := PRE_first_tail_x15_r0_body.zgrow15
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab15
  zfresh := PRE_first_tail_x15_r0_body.zfresh15
  zcnd := PRE_first_tail_x15_r0_body.zcnd15
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi15
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt15
  zgP := PRE_first_tail_x15_r0_body.zg15_2665
  zkP := PRE_first_tail_x15_r0_body.zk15_2665
  zmP := PRE_first_tail_x15_r0_body.zm15_2665
  zgC := PRE_first_tail_x15_r0_body.zg15_2673467
  zkC := PRE_first_tail_x15_r0_body.zk15_2673467
  zmC := PRE_first_tail_x15_r0_body.zm15_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw15_2673472
  zwV := PRE_first_tail_x15_r0_body.zw15_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap15
  zclbd := PRE_first_tail_x15_r0_body.zclbd15
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap15 PRE_first_tail_x15_r0_body.stFoot15 PRE_first_tail_x15_r0_body.iso15 PRE_first_tail_x15_r0_body.zwr15
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP15
  csupp := PRE_first_tail_x15_r0_body.csupp15
  cbound := PRE_first_tail_x15_r0_body.cbound15
  zimg := PRE_first_tail_x15_r0_body.zimg15
  zctl := PRE_first_tail_x15_r0_body.zctl15
  zstack := PRE_first_tail_x15_r0_body.zstack15
  zjobs := PRE_first_tail_x15_r0_body.zjobs15
  zstores := PRE_first_tail_x15_r0_body.zstores15
  zroots := PRE_first_tail_x15_r0_body.zroots15
  znC := PRE_first_tail_x15_r0_body.znC15
  ctab := PRE_first_tail_x15_r0_body.ctab15
  zbin := PRE_first_tail_x15_r0_body.zbin15
  cbridge := PRE_first_tail_x15_r0_body.cbridge15
  sbridge := bodyBridge15
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj15
  cshiftR := fun h hNL => bodyCshift15 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN15
  raised := PRE_first_tail_x15_r0_body.raised15
  cbigs := PRE_first_tail_x15_r0_body.cbigs15
  cjcl := PRE_first_tail_x15_r0_body.cjcl15
  xnLe := Nat.le_of_ble_eq_true bodyXn15
  loLe := Nat.le_of_ble_eq_true bodyLo15
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB15
  cntM := bodyCntM15
  hiLe := Nat.le_of_ble_eq_true bodyHi15
  nhiLe := Nat.le_of_ble_eq_true bodyNhi15
  jsHeap := bodyJs15
  jsRoots := bodyJsRoots15
  jsNative := bodyJsNative15
  framesEmpty := bodyFramesEmpty15
  trailOld := by decide
  lowVars := bodyLow15

def bodyQs15 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs15 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr15.map fun r => nth? PRE_first_tail_x15_r0_body.st15.S5.tab r
kernel_rfl bodyResChk15 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs15 bodyQs15) = true
kernel_rfl bodyLq15 : bodyQs15.length = PRE_first_tail_x15_r0_body.cws15.length
kernel_rfl bodyNrLo15 : PRE_first_tail_x15_r0_body.nr15.all (Nat.ble PRE_first_tail_x15_r0_body.S160.tab.length) = true
kernel_rfl bodySub15 : (Oracles.PRE_first_tail_x15_r0_body.map_site15.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost15 : postSubB bodyM PRE_first_tail_x15_r0_body.ws15 PRE_first_tail_x15_r0_body.cws15 bodyQs15 = true
kernel_rfl bodyDrop15 : Nat.ble (9129 + (PRE_first_tail_x15_r0_body.s161.next - PRE_first_tail_x15_r0_body.s162.next)) 10278 = true
kernel_rfl bodyDropH15 : Nat.ble (123 + ((mlxOf PRE_first_tail_x15_r0_body.s161.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s162.ffi).next)) 148 = true
kernel_rfl bodyDropN15 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s161.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s162.ffi).nnext)) 0 = true
kernel_rfl bodyDv15 : bodyΘ.1.take 99 = bodyΘ.1.take 81 ++ PRE_first_tail_x15_r0_body.cws15
kernel_rfl bodyDe15 : bodyΘ.2.take 99 = bodyΘ.2.take 81 ++ PRE_first_tail_x15_r0_body.nr15.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st15.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 81) (bodyΘ.2.take 81)))
kernel_rfl bodyDl15 : (bodyΘ.1.take 81).length = (bodyΘ.2.take 81).length
kernel_rfl bodyDold15 : (bodyΘ.1.take 81).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws15).isNone && !PRE_first_tail_x15_r0_body.ws15.contains v) = true
kernel_rfl bodyDfree15 : (bodyΘ.2.take 99).all (fun e => (PRE_first_tail_x15_r0_body.cws15 ++ PRE_first_tail_x15_r0_body.ws15).all fun w => e.noVar w) = true

theorem bodyStep15 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9129, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s160 PRE_first_tail_x15_r0_body.S160)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10278, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s162 PRE_first_tail_x15_r0_body.S162) (11334 + 1) :=
  bodySite bodyFacts15.cfix bodyFacts15.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st15.S5.tab) (Es := bodyEs15) (qs := bodyQs15)
    (ok := PRE_first_tail_x15_r0_body.st15.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site15 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts15
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site15 r hr) hi (MapOk.sub hm (sub_of_all bodySub15)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk15 r hr) hi hm ho hq)
    bodyLq15 rfl bodyNrLo15 (postSub_sound bodyPost15)
    (Nat.le_of_ble_eq_true bodyDrop15) (by decide) (Nat.le_of_ble_eq_true bodyDropH15) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN15) (by decide)
    bodyDv15 bodyDe15 bodyDl15 bodyDold15 bodyDfree15 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
