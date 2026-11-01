import host.sim.compose.a4b.vw15.VWBodyJ156
import host.sim.compose.a4b.vw15.VWBodySite156
import host.sim.compose.a4b.vw15.VWBodyOracles_39
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift156 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1511.tab.length PRE_first_tail_x15_r0_body.s1511.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P156.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P156 6770 PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.s1513.ffi PRE_first_tail_x15_r0_body.s1512.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_156
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_156
  have hcl : SSt (· < 6770) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1513.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1511.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_156] <;> decide) PRE_first_tail_x15_r0_body.cnodesK156 PRE_first_tail_x15_r0_body.cobjsK156
      PRE_first_tail_x15_r0_body.citemsK156 PRE_first_tail_x15_r0_body.cbd156 PRE_first_tail_x15_r0_body.csst156
  exact PRE_first_tail_x15_r0_body.cshift156 bodyNcl156 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_156] at this; exact this)


kernel_rfl bodyFramesEmpty156 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1512 a).isEmpty) = true
kernel_rfl bodyJsRoots156 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1511.next) PRE_first_tail_x15_r0_body.s1513.trace PRE_first_tail_x15_r0_body.s1513 = true
kernel_rfl bodyJsNative156 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1513.ffi) = true
kernel_rfl bodyLow156 : (PRE_first_tail_x15_r0_body.cws156 ++ PRE_first_tail_x15_r0_body.ws156).all (Nat.ble 9) = true
kernel_rfl bodyCntM156 : countersOkB PRE_first_tail_x15_r0_body.s1511 PRE_first_tail_x15_r0_body.s1512 = true
kernel_rfl bodyHi156 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1513.ffi).next setupP.E = true
kernel_rfl bodyNhi156 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1513.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge156 : bridgeOf PRE_first_tail_x15_r0_body.s1512.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1511.ffi
kernel_rfl bodyNN156 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1511.ffi).nnext PRE_first_tail_x15_r0_body.P156.NL = true
kernel_rfl bodyXn156 : Nat.ble (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1513.ffi).next = true
kernel_rfl bodyLo156 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1513.ffi).next = true
theorem bodyFacts156 : BodySiteFacts PRE_first_tail_x15_r0_body.s1511 PRE_first_tail_x15_r0_body.s1512 PRE_first_tail_x15_r0_body.s1513 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1511 PRE_first_tail_x15_r0_body.S1512 PRE_first_tail_x15_r0_body.S1513
    PRE_first_tail_x15_r0_body.ws156 PRE_first_tail_x15_r0_body.cws156 PRE_first_tail_x15_r0_body.nr156 PRE_first_tail_x15_r0_body.pl156 PRE_first_tail_x15_r0_body.cl156 2799034 6770 PRE_first_tail_x15_r0_body.kd156 PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.P156
    ⟨21284, 18359, 2797879, 6752⟩ ⟨21287, 18386, 2797885, 6770⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap156
  clean := bodyClean156
  cfix := PRE_first_tail_x15_r0_body.cfix156
  zpl := PRE_first_tail_x15_r0_body.zpl156
  zplnd := PRE_first_tail_x15_r0_body.zplnd156
  zn1 := PRE_first_tail_x15_r0_body.zn1156
  zfirst := PRE_first_tail_x15_r0_body.zfirst156
  zscn := PRE_first_tail_x15_r0_body.zscn156
  zsmn := PRE_first_tail_x15_r0_body.zsmn156
  zgrow := PRE_first_tail_x15_r0_body.zgrow156
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab156
  zfresh := PRE_first_tail_x15_r0_body.zfresh156
  zcnd := PRE_first_tail_x15_r0_body.zcnd156
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi156
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt156
  zgP := PRE_first_tail_x15_r0_body.zg156_2665
  zkP := PRE_first_tail_x15_r0_body.zk156_2665
  zmP := PRE_first_tail_x15_r0_body.zm156_2665
  zgC := PRE_first_tail_x15_r0_body.zg156_2673467
  zkC := PRE_first_tail_x15_r0_body.zk156_2673467
  zmC := PRE_first_tail_x15_r0_body.zm156_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw156_2673472
  zwV := PRE_first_tail_x15_r0_body.zw156_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap156
  zclbd := PRE_first_tail_x15_r0_body.zclbd156
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap156 PRE_first_tail_x15_r0_body.stFoot156 PRE_first_tail_x15_r0_body.iso156 PRE_first_tail_x15_r0_body.zwr156
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP156
  csupp := PRE_first_tail_x15_r0_body.csupp156
  cbound := PRE_first_tail_x15_r0_body.cbound156
  zimg := PRE_first_tail_x15_r0_body.zimg156
  zctl := PRE_first_tail_x15_r0_body.zctl156
  zstack := PRE_first_tail_x15_r0_body.zstack156
  zjobs := PRE_first_tail_x15_r0_body.zjobs156
  zstores := PRE_first_tail_x15_r0_body.zstores156
  zroots := PRE_first_tail_x15_r0_body.zroots156
  znC := PRE_first_tail_x15_r0_body.znC156
  ctab := PRE_first_tail_x15_r0_body.ctab156
  zbin := PRE_first_tail_x15_r0_body.zbin156
  cbridge := PRE_first_tail_x15_r0_body.cbridge156
  sbridge := bodyBridge156
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj156
  cshiftR := fun h hNL => bodyCshift156 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN156
  raised := PRE_first_tail_x15_r0_body.raised156
  cbigs := PRE_first_tail_x15_r0_body.cbigs156
  cjcl := PRE_first_tail_x15_r0_body.cjcl156
  xnLe := Nat.le_of_ble_eq_true bodyXn156
  loLe := Nat.le_of_ble_eq_true bodyLo156
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB156
  cntM := bodyCntM156
  hiLe := Nat.le_of_ble_eq_true bodyHi156
  nhiLe := Nat.le_of_ble_eq_true bodyNhi156
  jsHeap := bodyJs156
  jsRoots := bodyJsRoots156
  jsNative := bodyJsNative156
  framesEmpty := bodyFramesEmpty156
  trailOld := by decide
  lowVars := bodyLow156

def bodyQs156 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs156 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr156.map fun r => nth? PRE_first_tail_x15_r0_body.st156.S5.tab r
kernel_rfl bodyResChk156 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs156 bodyQs156) = true
kernel_rfl bodyLq156 : bodyQs156.length = PRE_first_tail_x15_r0_body.cws156.length
kernel_rfl bodyNrLo156 : PRE_first_tail_x15_r0_body.nr156.all (Nat.ble PRE_first_tail_x15_r0_body.S1511.tab.length) = true
kernel_rfl bodySub156 : (Oracles.PRE_first_tail_x15_r0_body.map_site156.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost156 : postSubB bodyM PRE_first_tail_x15_r0_body.ws156 PRE_first_tail_x15_r0_body.cws156 bodyQs156 = true
kernel_rfl bodyDrop156 : Nat.ble (54243 + (PRE_first_tail_x15_r0_body.s1512.next - PRE_first_tail_x15_r0_body.s1513.next)) 55392 = true
kernel_rfl bodyDropH156 : Nat.ble (1022 + ((mlxOf PRE_first_tail_x15_r0_body.s1512.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1513.ffi).next)) 1047 = true
kernel_rfl bodyDropN156 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1512.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1513.ffi).nnext)) 0 = true
kernel_rfl bodyDv156 : bodyΘ.1.take 837 = bodyΘ.1.take 819 ++ PRE_first_tail_x15_r0_body.cws156
kernel_rfl bodyDe156 : bodyΘ.2.take 837 = bodyΘ.2.take 819 ++ PRE_first_tail_x15_r0_body.nr156.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st156.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 819) (bodyΘ.2.take 819)))
kernel_rfl bodyDl156 : (bodyΘ.1.take 819).length = (bodyΘ.2.take 819).length
kernel_rfl bodyDold156 : (bodyΘ.1.take 819).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws156).isNone && !PRE_first_tail_x15_r0_body.ws156.contains v) = true
kernel_rfl bodyDfree156 : (bodyΘ.2.take 837).all (fun e => (PRE_first_tail_x15_r0_body.cws156 ++ PRE_first_tail_x15_r0_body.ws156).all fun w => e.noVar w) = true

theorem bodyStep156 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨54243, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1511 PRE_first_tail_x15_r0_body.S1511)
      (bodyCut NB T tk π i x0 bodyΘ ⟨55392, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1513 PRE_first_tail_x15_r0_body.S1513) (11334 + 1) :=
  bodySite bodyFacts156.cfix bodyFacts156.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st156.S5.tab) (Es := bodyEs156) (qs := bodyQs156)
    (ok := PRE_first_tail_x15_r0_body.st156.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site156 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts156
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site156 r hr) hi (MapOk.sub hm (sub_of_all bodySub156)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk156 r hr) hi hm ho hq)
    bodyLq156 rfl bodyNrLo156 (postSub_sound bodyPost156)
    (Nat.le_of_ble_eq_true bodyDrop156) (by decide) (Nat.le_of_ble_eq_true bodyDropH156) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN156) (by decide)
    bodyDv156 bodyDe156 bodyDl156 bodyDold156 bodyDfree156 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
