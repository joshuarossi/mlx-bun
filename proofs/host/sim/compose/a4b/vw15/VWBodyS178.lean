import host.sim.compose.a4b.vw15.VWBodyJ178
import host.sim.compose.a4b.vw15.VWBodySite178
import host.sim.compose.a4b.vw15.VWBodyOracles_44
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift178 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1720.tab.length PRE_first_tail_x15_r0_body.s1720.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P178.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P178 7688 PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.s1722.ffi PRE_first_tail_x15_r0_body.s1721.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_178
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_178
  have hcl : SSt (· < 7688) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1722.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1720.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_178] <;> decide) PRE_first_tail_x15_r0_body.cnodesK178 PRE_first_tail_x15_r0_body.cobjsK178
      PRE_first_tail_x15_r0_body.citemsK178 PRE_first_tail_x15_r0_body.cbd178 PRE_first_tail_x15_r0_body.csst178
  exact PRE_first_tail_x15_r0_body.cshift178 bodyNcl178 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_178] at this; exact this)


kernel_rfl bodyFramesEmpty178 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1721 a).isEmpty) = true
kernel_rfl bodyJsRoots178 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1720.next) PRE_first_tail_x15_r0_body.s1722.trace PRE_first_tail_x15_r0_body.s1722 = true
kernel_rfl bodyJsNative178 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1722.ffi) = true
kernel_rfl bodyLow178 : (PRE_first_tail_x15_r0_body.cws178 ++ PRE_first_tail_x15_r0_body.ws178).all (Nat.ble 9) = true
kernel_rfl bodyCntM178 : countersOkB PRE_first_tail_x15_r0_body.s1720 PRE_first_tail_x15_r0_body.s1721 = true
kernel_rfl bodyHi178 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1722.ffi).next setupP.E = true
kernel_rfl bodyNhi178 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1722.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge178 : bridgeOf PRE_first_tail_x15_r0_body.s1721.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1720.ffi
kernel_rfl bodyNN178 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1720.ffi).nnext PRE_first_tail_x15_r0_body.P178.NL = true
kernel_rfl bodyXn178 : Nat.ble (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1722.ffi).next = true
kernel_rfl bodyLo178 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1722.ffi).next = true
theorem bodyFacts178 : BodySiteFacts PRE_first_tail_x15_r0_body.s1720 PRE_first_tail_x15_r0_body.s1721 PRE_first_tail_x15_r0_body.s1722 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1720 PRE_first_tail_x15_r0_body.S1721 PRE_first_tail_x15_r0_body.S1722
    PRE_first_tail_x15_r0_body.ws178 PRE_first_tail_x15_r0_body.cws178 PRE_first_tail_x15_r0_body.nr178 PRE_first_tail_x15_r0_body.pl178 PRE_first_tail_x15_r0_body.cl178 2814943 7688 PRE_first_tail_x15_r0_body.kd178 PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.P178
    ⟨21714, 18810, 2814941, 7688⟩ ⟨21714, 18810, 2814941, 7688⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap178
  clean := bodyClean178
  cfix := PRE_first_tail_x15_r0_body.cfix178
  zpl := PRE_first_tail_x15_r0_body.zpl178
  zplnd := PRE_first_tail_x15_r0_body.zplnd178
  zn1 := PRE_first_tail_x15_r0_body.zn1178
  zfirst := PRE_first_tail_x15_r0_body.zfirst178
  zscn := PRE_first_tail_x15_r0_body.zscn178
  zsmn := PRE_first_tail_x15_r0_body.zsmn178
  zgrow := PRE_first_tail_x15_r0_body.zgrow178
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab178
  zfresh := PRE_first_tail_x15_r0_body.zfresh178
  zcnd := PRE_first_tail_x15_r0_body.zcnd178
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi178
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt178
  zgP := PRE_first_tail_x15_r0_body.zg178_2665
  zkP := PRE_first_tail_x15_r0_body.zk178_2665
  zmP := PRE_first_tail_x15_r0_body.zm178_2665
  zgC := PRE_first_tail_x15_r0_body.zg178_2673467
  zkC := PRE_first_tail_x15_r0_body.zk178_2673467
  zmC := PRE_first_tail_x15_r0_body.zm178_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw178_2673472
  zwV := PRE_first_tail_x15_r0_body.zw178_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap178
  zclbd := PRE_first_tail_x15_r0_body.zclbd178
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap178 PRE_first_tail_x15_r0_body.stFoot178 PRE_first_tail_x15_r0_body.iso178 PRE_first_tail_x15_r0_body.zwr178
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP178
  csupp := PRE_first_tail_x15_r0_body.csupp178
  cbound := PRE_first_tail_x15_r0_body.cbound178
  zimg := PRE_first_tail_x15_r0_body.zimg178
  zctl := PRE_first_tail_x15_r0_body.zctl178
  zstack := PRE_first_tail_x15_r0_body.zstack178
  zjobs := PRE_first_tail_x15_r0_body.zjobs178
  zstores := PRE_first_tail_x15_r0_body.zstores178
  zroots := PRE_first_tail_x15_r0_body.zroots178
  znC := PRE_first_tail_x15_r0_body.znC178
  ctab := PRE_first_tail_x15_r0_body.ctab178
  zbin := PRE_first_tail_x15_r0_body.zbin178
  cbridge := PRE_first_tail_x15_r0_body.cbridge178
  sbridge := bodyBridge178
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj178
  cshiftR := fun h hNL => bodyCshift178 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN178
  raised := PRE_first_tail_x15_r0_body.raised178
  cbigs := PRE_first_tail_x15_r0_body.cbigs178
  cjcl := PRE_first_tail_x15_r0_body.cjcl178
  xnLe := Nat.le_of_ble_eq_true bodyXn178
  loLe := Nat.le_of_ble_eq_true bodyLo178
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB178
  cntM := bodyCntM178
  hiLe := Nat.le_of_ble_eq_true bodyHi178
  nhiLe := Nat.le_of_ble_eq_true bodyNhi178
  jsHeap := bodyJs178
  jsRoots := bodyJsRoots178
  jsNative := bodyJsNative178
  framesEmpty := bodyFramesEmpty178
  trailOld := by decide
  lowVars := bodyLow178

def bodyQs178 : List (Option Q) := []
noncomputable def bodyEs178 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr178.map fun r => nth? PRE_first_tail_x15_r0_body.st178.S2.tab r
kernel_rfl bodyResChk178 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs178 bodyQs178) = true
kernel_rfl bodyLq178 : bodyQs178.length = PRE_first_tail_x15_r0_body.cws178.length
kernel_rfl bodyNrLo178 : PRE_first_tail_x15_r0_body.nr178.all (Nat.ble PRE_first_tail_x15_r0_body.S1720.tab.length) = true
kernel_rfl bodySub178 : (Oracles.PRE_first_tail_x15_r0_body.map_site178.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost178 : postSubB bodyM PRE_first_tail_x15_r0_body.ws178 PRE_first_tail_x15_r0_body.cws178 bodyQs178 = true
kernel_rfl bodyDrop178 : Nat.ble (61966 + (PRE_first_tail_x15_r0_body.s1721.next - PRE_first_tail_x15_r0_body.s1722.next)) 61968 = true
kernel_rfl bodyDropH178 : Nat.ble (1176 + ((mlxOf PRE_first_tail_x15_r0_body.s1721.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1722.ffi).next)) 1176 = true
kernel_rfl bodyDropN178 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1721.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1722.ffi).nnext)) 0 = true
kernel_rfl bodyDv178 : bodyΘ.1.take 945 = bodyΘ.1.take 945 ++ PRE_first_tail_x15_r0_body.cws178
kernel_rfl bodyDe178 : bodyΘ.2.take 945 = bodyΘ.2.take 945 ++ PRE_first_tail_x15_r0_body.nr178.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st178.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 945) (bodyΘ.2.take 945)))
kernel_rfl bodyDl178 : (bodyΘ.1.take 945).length = (bodyΘ.2.take 945).length
kernel_rfl bodyDold178 : (bodyΘ.1.take 945).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws178).isNone && !PRE_first_tail_x15_r0_body.ws178.contains v) = true
kernel_rfl bodyDfree178 : (bodyΘ.2.take 945).all (fun e => (PRE_first_tail_x15_r0_body.cws178 ++ PRE_first_tail_x15_r0_body.ws178).all fun w => e.noVar w) = true

theorem bodyStep178 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61966, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1720 PRE_first_tail_x15_r0_body.S1720)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61968, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1722 PRE_first_tail_x15_r0_body.S1722) (27 + 1) :=
  bodySite bodyFacts178.cfix bodyFacts178.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st178.S2.tab) (Es := bodyEs178) (qs := bodyQs178)
    (ok := PRE_first_tail_x15_r0_body.st178.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site178 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts178
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site178 r hr) hi (MapOk.sub hm (sub_of_all bodySub178)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk178 r hr) hi hm ho hq)
    bodyLq178 rfl bodyNrLo178 (postSub_sound bodyPost178)
    (Nat.le_of_ble_eq_true bodyDrop178) (by decide) (Nat.le_of_ble_eq_true bodyDropH178) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN178) (by decide)
    bodyDv178 bodyDe178 bodyDl178 bodyDold178 bodyDfree178 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
