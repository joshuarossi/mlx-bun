import host.sim.compose.a4b.vw15.VWBodyJ38
import host.sim.compose.a4b.vw15.VWBodySite38
import host.sim.compose.a4b.vw15.VWBodyOracles_9
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift38 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S373.tab.length PRE_first_tail_x15_r0_body.s373.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P38.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P38 1678 PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.s375.ffi PRE_first_tail_x15_r0_body.s374.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_38
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_38
  have hcl : SSt (· < 1678) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S373.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_38] <;> decide) PRE_first_tail_x15_r0_body.cnodesK38 PRE_first_tail_x15_r0_body.cobjsK38
      PRE_first_tail_x15_r0_body.citemsK38 PRE_first_tail_x15_r0_body.cbd38 PRE_first_tail_x15_r0_body.csst38
  exact PRE_first_tail_x15_r0_body.cshift38 bodyNcl38 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_38] at this; exact this)


kernel_rfl bodyFramesEmpty38 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s374 a).isEmpty) = true
kernel_rfl bodyJsRoots38 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s373.next) PRE_first_tail_x15_r0_body.s375.trace PRE_first_tail_x15_r0_body.s375 = true
kernel_rfl bodyJsNative38 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s375.ffi) = true
kernel_rfl bodyLow38 : (PRE_first_tail_x15_r0_body.cws38 ++ PRE_first_tail_x15_r0_body.ws38).all (Nat.ble 9) = true
kernel_rfl bodyCntM38 : countersOkB PRE_first_tail_x15_r0_body.s373 PRE_first_tail_x15_r0_body.s374 = true
kernel_rfl bodyHi38 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s375.ffi).next setupP.E = true
kernel_rfl bodyNhi38 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s375.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge38 : bridgeOf PRE_first_tail_x15_r0_body.s374.ffi = bridgeOf PRE_first_tail_x15_r0_body.s373.ffi
kernel_rfl bodyNN38 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s373.ffi).nnext PRE_first_tail_x15_r0_body.P38.NL = true
kernel_rfl bodyXn38 : Nat.ble (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s375.ffi).next = true
kernel_rfl bodyLo38 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s375.ffi).next = true
theorem bodyFacts38 : BodySiteFacts PRE_first_tail_x15_r0_body.s373 PRE_first_tail_x15_r0_body.s374 PRE_first_tail_x15_r0_body.s375 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S373 PRE_first_tail_x15_r0_body.S374 PRE_first_tail_x15_r0_body.S375
    PRE_first_tail_x15_r0_body.ws38 PRE_first_tail_x15_r0_body.cws38 PRE_first_tail_x15_r0_body.nr38 PRE_first_tail_x15_r0_body.pl38 PRE_first_tail_x15_r0_body.cl38 2704498 1678 PRE_first_tail_x15_r0_body.kd38 PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.P38
    ⟨18947, 16033, 2704487, 1678⟩ ⟨18947, 16033, 2704488, 1678⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap38
  clean := bodyClean38
  cfix := PRE_first_tail_x15_r0_body.cfix38
  zpl := PRE_first_tail_x15_r0_body.zpl38
  zplnd := PRE_first_tail_x15_r0_body.zplnd38
  zn1 := PRE_first_tail_x15_r0_body.zn138
  zfirst := PRE_first_tail_x15_r0_body.zfirst38
  zscn := PRE_first_tail_x15_r0_body.zscn38
  zsmn := PRE_first_tail_x15_r0_body.zsmn38
  zgrow := PRE_first_tail_x15_r0_body.zgrow38
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab38
  zfresh := PRE_first_tail_x15_r0_body.zfresh38
  zcnd := PRE_first_tail_x15_r0_body.zcnd38
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi38
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt38
  zgP := PRE_first_tail_x15_r0_body.zg38_2665
  zkP := PRE_first_tail_x15_r0_body.zk38_2665
  zmP := PRE_first_tail_x15_r0_body.zm38_2665
  zgC := PRE_first_tail_x15_r0_body.zg38_2673467
  zkC := PRE_first_tail_x15_r0_body.zk38_2673467
  zmC := PRE_first_tail_x15_r0_body.zm38_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw38_2673472
  zwV := PRE_first_tail_x15_r0_body.zw38_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap38
  zclbd := PRE_first_tail_x15_r0_body.zclbd38
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap38 PRE_first_tail_x15_r0_body.stFoot38 PRE_first_tail_x15_r0_body.iso38 PRE_first_tail_x15_r0_body.zwr38
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP38
  csupp := PRE_first_tail_x15_r0_body.csupp38
  cbound := PRE_first_tail_x15_r0_body.cbound38
  zimg := PRE_first_tail_x15_r0_body.zimg38
  zctl := PRE_first_tail_x15_r0_body.zctl38
  zstack := PRE_first_tail_x15_r0_body.zstack38
  zjobs := PRE_first_tail_x15_r0_body.zjobs38
  zstores := PRE_first_tail_x15_r0_body.zstores38
  zroots := PRE_first_tail_x15_r0_body.zroots38
  znC := PRE_first_tail_x15_r0_body.znC38
  ctab := PRE_first_tail_x15_r0_body.ctab38
  zbin := PRE_first_tail_x15_r0_body.zbin38
  cbridge := PRE_first_tail_x15_r0_body.cbridge38
  sbridge := bodyBridge38
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj38
  cshiftR := fun h hNL => bodyCshift38 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN38
  raised := PRE_first_tail_x15_r0_body.raised38
  cbigs := PRE_first_tail_x15_r0_body.cbigs38
  cjcl := PRE_first_tail_x15_r0_body.cjcl38
  xnLe := Nat.le_of_ble_eq_true bodyXn38
  loLe := Nat.le_of_ble_eq_true bodyLo38
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB38
  cntM := bodyCntM38
  hiLe := Nat.le_of_ble_eq_true bodyHi38
  nhiLe := Nat.le_of_ble_eq_true bodyNhi38
  jsHeap := bodyJs38
  jsRoots := bodyJsRoots38
  jsNative := bodyJsNative38
  framesEmpty := bodyFramesEmpty38
  trailOld := by decide
  lowVars := bodyLow38

def bodyQs38 : List (Option Q) := []
noncomputable def bodyEs38 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr38.map fun r => nth? PRE_first_tail_x15_r0_body.st38.S2.tab r
kernel_rfl bodyResChk38 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs38 bodyQs38) = true
kernel_rfl bodyLq38 : bodyQs38.length = PRE_first_tail_x15_r0_body.cws38.length
kernel_rfl bodyNrLo38 : PRE_first_tail_x15_r0_body.nr38.all (Nat.ble PRE_first_tail_x15_r0_body.S373.tab.length) = true
kernel_rfl bodySub38 : (Oracles.PRE_first_tail_x15_r0_body.map_site38.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost38 : postSubB bodyM PRE_first_tail_x15_r0_body.ws38 PRE_first_tail_x15_r0_body.cws38 bodyQs38 = true
kernel_rfl bodyDrop38 : Nat.ble (16818 + (PRE_first_tail_x15_r0_body.s374.next - PRE_first_tail_x15_r0_body.s375.next)) 16828 = true
kernel_rfl bodyDropH38 : Nat.ble (277 + ((mlxOf PRE_first_tail_x15_r0_body.s374.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s375.ffi).next)) 277 = true
kernel_rfl bodyDropN38 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s374.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s375.ffi).nnext)) 0 = true
kernel_rfl bodyDv38 : bodyΘ.1.take 207 = bodyΘ.1.take 207 ++ PRE_first_tail_x15_r0_body.cws38
kernel_rfl bodyDe38 : bodyΘ.2.take 207 = bodyΘ.2.take 207 ++ PRE_first_tail_x15_r0_body.nr38.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st38.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 207) (bodyΘ.2.take 207)))
kernel_rfl bodyDl38 : (bodyΘ.1.take 207).length = (bodyΘ.2.take 207).length
kernel_rfl bodyDold38 : (bodyΘ.1.take 207).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws38).isNone && !PRE_first_tail_x15_r0_body.ws38.contains v) = true
kernel_rfl bodyDfree38 : (bodyΘ.2.take 207).all (fun e => (PRE_first_tail_x15_r0_body.cws38 ++ PRE_first_tail_x15_r0_body.ws38).all fun w => e.noVar w) = true

theorem bodyStep38 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16818, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s373 PRE_first_tail_x15_r0_body.S373)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16828, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s375 PRE_first_tail_x15_r0_body.S375) (98 + 1) :=
  bodySite bodyFacts38.cfix bodyFacts38.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st38.S2.tab) (Es := bodyEs38) (qs := bodyQs38)
    (ok := PRE_first_tail_x15_r0_body.st38.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site38 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts38
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site38 r hr) hi (MapOk.sub hm (sub_of_all bodySub38)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk38 r hr) hi hm ho hq)
    bodyLq38 rfl bodyNrLo38 (postSub_sound bodyPost38)
    (Nat.le_of_ble_eq_true bodyDrop38) (by decide) (Nat.le_of_ble_eq_true bodyDropH38) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN38) (by decide)
    bodyDv38 bodyDe38 bodyDl38 bodyDold38 bodyDfree38 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
