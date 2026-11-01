import host.sim.compose.a4b.vw15.VWBodyJ128
import host.sim.compose.a4b.vw15.VWBodySite128
import host.sim.compose.a4b.vw15.VWBodyOracles_32
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift128 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1236.tab.length PRE_first_tail_x15_r0_body.s1236.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P128.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P128 5527 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.s1238.ffi PRE_first_tail_x15_r0_body.s1237.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_128
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_128
  have hcl : SSt (· < 5527) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1236.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_128] <;> decide) PRE_first_tail_x15_r0_body.cnodesK128 PRE_first_tail_x15_r0_body.cobjsK128
      PRE_first_tail_x15_r0_body.citemsK128 PRE_first_tail_x15_r0_body.cbd128 PRE_first_tail_x15_r0_body.csst128
  exact PRE_first_tail_x15_r0_body.cshift128 bodyNcl128 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_128] at this; exact this)


kernel_rfl bodyFramesEmpty128 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1237 a).isEmpty) = true
kernel_rfl bodyJsRoots128 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1236.next) PRE_first_tail_x15_r0_body.s1238.trace PRE_first_tail_x15_r0_body.s1238 = true
kernel_rfl bodyJsNative128 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1238.ffi) = true
kernel_rfl bodyLow128 : (PRE_first_tail_x15_r0_body.cws128 ++ PRE_first_tail_x15_r0_body.ws128).all (Nat.ble 9) = true
kernel_rfl bodyCntM128 : countersOkB PRE_first_tail_x15_r0_body.s1236 PRE_first_tail_x15_r0_body.s1237 = true
kernel_rfl bodyHi128 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1238.ffi).next setupP.E = true
kernel_rfl bodyNhi128 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1238.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge128 : bridgeOf PRE_first_tail_x15_r0_body.s1237.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1236.ffi
kernel_rfl bodyNN128 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1236.ffi).nnext PRE_first_tail_x15_r0_body.P128.NL = true
kernel_rfl bodyXn128 : Nat.ble (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1238.ffi).next = true
kernel_rfl bodyLo128 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1238.ffi).next = true
theorem bodyFacts128 : BodySiteFacts PRE_first_tail_x15_r0_body.s1236 PRE_first_tail_x15_r0_body.s1237 PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1236 PRE_first_tail_x15_r0_body.S1237 PRE_first_tail_x15_r0_body.S1238
    PRE_first_tail_x15_r0_body.ws128 PRE_first_tail_x15_r0_body.cws128 PRE_first_tail_x15_r0_body.nr128 PRE_first_tail_x15_r0_body.pl128 PRE_first_tail_x15_r0_body.cl128 2774930 5527 PRE_first_tail_x15_r0_body.kd128 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.P128
    ⟨20713, 17818, 2774919, 5527⟩ ⟨20713, 17818, 2774920, 5527⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap128
  clean := bodyClean128
  cfix := PRE_first_tail_x15_r0_body.cfix128
  zpl := PRE_first_tail_x15_r0_body.zpl128
  zplnd := PRE_first_tail_x15_r0_body.zplnd128
  zn1 := PRE_first_tail_x15_r0_body.zn1128
  zfirst := PRE_first_tail_x15_r0_body.zfirst128
  zscn := PRE_first_tail_x15_r0_body.zscn128
  zsmn := PRE_first_tail_x15_r0_body.zsmn128
  zgrow := PRE_first_tail_x15_r0_body.zgrow128
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab128
  zfresh := PRE_first_tail_x15_r0_body.zfresh128
  zcnd := PRE_first_tail_x15_r0_body.zcnd128
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi128
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt128
  zgP := PRE_first_tail_x15_r0_body.zg128_2665
  zkP := PRE_first_tail_x15_r0_body.zk128_2665
  zmP := PRE_first_tail_x15_r0_body.zm128_2665
  zgC := PRE_first_tail_x15_r0_body.zg128_2673467
  zkC := PRE_first_tail_x15_r0_body.zk128_2673467
  zmC := PRE_first_tail_x15_r0_body.zm128_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw128_2673472
  zwV := PRE_first_tail_x15_r0_body.zw128_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap128
  zclbd := PRE_first_tail_x15_r0_body.zclbd128
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap128 PRE_first_tail_x15_r0_body.stFoot128 PRE_first_tail_x15_r0_body.iso128 PRE_first_tail_x15_r0_body.zwr128
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP128
  csupp := PRE_first_tail_x15_r0_body.csupp128
  cbound := PRE_first_tail_x15_r0_body.cbound128
  zimg := PRE_first_tail_x15_r0_body.zimg128
  zctl := PRE_first_tail_x15_r0_body.zctl128
  zstack := PRE_first_tail_x15_r0_body.zstack128
  zjobs := PRE_first_tail_x15_r0_body.zjobs128
  zstores := PRE_first_tail_x15_r0_body.zstores128
  zroots := PRE_first_tail_x15_r0_body.zroots128
  znC := PRE_first_tail_x15_r0_body.znC128
  ctab := PRE_first_tail_x15_r0_body.ctab128
  zbin := PRE_first_tail_x15_r0_body.zbin128
  cbridge := PRE_first_tail_x15_r0_body.cbridge128
  sbridge := bodyBridge128
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj128
  cshiftR := fun h hNL => bodyCshift128 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN128
  raised := PRE_first_tail_x15_r0_body.raised128
  cbigs := PRE_first_tail_x15_r0_body.cbigs128
  cjcl := PRE_first_tail_x15_r0_body.cjcl128
  xnLe := Nat.le_of_ble_eq_true bodyXn128
  loLe := Nat.le_of_ble_eq_true bodyLo128
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB128
  cntM := bodyCntM128
  hiLe := Nat.le_of_ble_eq_true bodyHi128
  nhiLe := Nat.le_of_ble_eq_true bodyNhi128
  jsHeap := bodyJs128
  jsRoots := bodyJsRoots128
  jsNative := bodyJsNative128
  framesEmpty := bodyFramesEmpty128
  trailOld := by decide
  lowVars := bodyLow128

def bodyQs128 : List (Option Q) := []
noncomputable def bodyEs128 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr128.map fun r => nth? PRE_first_tail_x15_r0_body.st128.S2.tab r
kernel_rfl bodyResChk128 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs128 bodyQs128) = true
kernel_rfl bodyLq128 : bodyQs128.length = PRE_first_tail_x15_r0_body.cws128.length
kernel_rfl bodyNrLo128 : PRE_first_tail_x15_r0_body.nr128.all (Nat.ble PRE_first_tail_x15_r0_body.S1236.tab.length) = true
kernel_rfl bodySub128 : (Oracles.PRE_first_tail_x15_r0_body.map_site128.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost128 : postSubB bodyM PRE_first_tail_x15_r0_body.ws128 PRE_first_tail_x15_r0_body.cws128 bodyQs128 = true
kernel_rfl bodyDrop128 : Nat.ble (46136 + (PRE_first_tail_x15_r0_body.s1237.next - PRE_first_tail_x15_r0_body.s1238.next)) 46146 = true
kernel_rfl bodyDropH128 : Nat.ble (866 + ((mlxOf PRE_first_tail_x15_r0_body.s1237.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1238.ffi).next)) 866 = true
kernel_rfl bodyDropN128 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1237.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1238.ffi).nnext)) 0 = true
kernel_rfl bodyDv128 : bodyΘ.1.take 684 = bodyΘ.1.take 684 ++ PRE_first_tail_x15_r0_body.cws128
kernel_rfl bodyDe128 : bodyΘ.2.take 684 = bodyΘ.2.take 684 ++ PRE_first_tail_x15_r0_body.nr128.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st128.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 684) (bodyΘ.2.take 684)))
kernel_rfl bodyDl128 : (bodyΘ.1.take 684).length = (bodyΘ.2.take 684).length
kernel_rfl bodyDold128 : (bodyΘ.1.take 684).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws128).isNone && !PRE_first_tail_x15_r0_body.ws128.contains v) = true
kernel_rfl bodyDfree128 : (bodyΘ.2.take 684).all (fun e => (PRE_first_tail_x15_r0_body.cws128 ++ PRE_first_tail_x15_r0_body.ws128).all fun w => e.noVar w) = true

theorem bodyStep128 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46136, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1236 PRE_first_tail_x15_r0_body.S1236)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46146, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.S1238) (98 + 1) :=
  bodySite bodyFacts128.cfix bodyFacts128.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st128.S2.tab) (Es := bodyEs128) (qs := bodyQs128)
    (ok := PRE_first_tail_x15_r0_body.st128.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site128 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts128
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site128 r hr) hi (MapOk.sub hm (sub_of_all bodySub128)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk128 r hr) hi hm ho hq)
    bodyLq128 rfl bodyNrLo128 (postSub_sound bodyPost128)
    (Nat.le_of_ble_eq_true bodyDrop128) (by decide) (Nat.le_of_ble_eq_true bodyDropH128) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN128) (by decide)
    bodyDv128 bodyDe128 bodyDl128 bodyDold128 bodyDfree128 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
