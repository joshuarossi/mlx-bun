import host.sim.compose.a4b.vw15.VWBodyJ146
import host.sim.compose.a4b.vw15.VWBodySite146
import host.sim.compose.a4b.vw15.VWBodyOracles_36
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift146 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1408.tab.length PRE_first_tail_x15_r0_body.s1408.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P146.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P146 6295 PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.s1410.ffi PRE_first_tail_x15_r0_body.s1409.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_146
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_146
  have hcl : SSt (· < 6295) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1408.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_146] <;> decide) PRE_first_tail_x15_r0_body.cnodesK146 PRE_first_tail_x15_r0_body.cobjsK146
      PRE_first_tail_x15_r0_body.citemsK146 PRE_first_tail_x15_r0_body.cbd146 PRE_first_tail_x15_r0_body.csst146
  exact PRE_first_tail_x15_r0_body.cshift146 bodyNcl146 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_146] at this; exact this)


kernel_rfl bodyFramesEmpty146 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1409 a).isEmpty) = true
kernel_rfl bodyJsRoots146 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1408.next) PRE_first_tail_x15_r0_body.s1410.trace PRE_first_tail_x15_r0_body.s1410 = true
kernel_rfl bodyJsNative146 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1410.ffi) = true
kernel_rfl bodyLow146 : (PRE_first_tail_x15_r0_body.cws146 ++ PRE_first_tail_x15_r0_body.ws146).all (Nat.ble 9) = true
kernel_rfl bodyCntM146 : countersOkB PRE_first_tail_x15_r0_body.s1408 PRE_first_tail_x15_r0_body.s1409 = true
kernel_rfl bodyHi146 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1410.ffi).next setupP.E = true
kernel_rfl bodyNhi146 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1410.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge146 : bridgeOf PRE_first_tail_x15_r0_body.s1409.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1408.ffi
kernel_rfl bodyNN146 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1408.ffi).nnext PRE_first_tail_x15_r0_body.P146.NL = true
kernel_rfl bodyXn146 : Nat.ble (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1410.ffi).next = true
kernel_rfl bodyLo146 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1410.ffi).next = true
theorem bodyFacts146 : BodySiteFacts PRE_first_tail_x15_r0_body.s1408 PRE_first_tail_x15_r0_body.s1409 PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1408 PRE_first_tail_x15_r0_body.S1409 PRE_first_tail_x15_r0_body.S1410
    PRE_first_tail_x15_r0_body.ws146 PRE_first_tail_x15_r0_body.cws146 PRE_first_tail_x15_r0_body.nr146 PRE_first_tail_x15_r0_body.pl146 PRE_first_tail_x15_r0_body.cl146 2789263 6295 PRE_first_tail_x15_r0_body.kd146 PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.P146
    ⟨21071, 18166, 2789243, 6295⟩ ⟨21071, 18166, 2789244, 6295⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap146
  clean := bodyClean146
  cfix := PRE_first_tail_x15_r0_body.cfix146
  zpl := PRE_first_tail_x15_r0_body.zpl146
  zplnd := PRE_first_tail_x15_r0_body.zplnd146
  zn1 := PRE_first_tail_x15_r0_body.zn1146
  zfirst := PRE_first_tail_x15_r0_body.zfirst146
  zscn := PRE_first_tail_x15_r0_body.zscn146
  zsmn := PRE_first_tail_x15_r0_body.zsmn146
  zgrow := PRE_first_tail_x15_r0_body.zgrow146
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab146
  zfresh := PRE_first_tail_x15_r0_body.zfresh146
  zcnd := PRE_first_tail_x15_r0_body.zcnd146
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi146
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt146
  zgP := PRE_first_tail_x15_r0_body.zg146_2665
  zkP := PRE_first_tail_x15_r0_body.zk146_2665
  zmP := PRE_first_tail_x15_r0_body.zm146_2665
  zgC := PRE_first_tail_x15_r0_body.zg146_2673467
  zkC := PRE_first_tail_x15_r0_body.zk146_2673467
  zmC := PRE_first_tail_x15_r0_body.zm146_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw146_2673472
  zwV := PRE_first_tail_x15_r0_body.zw146_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap146
  zclbd := PRE_first_tail_x15_r0_body.zclbd146
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap146 PRE_first_tail_x15_r0_body.stFoot146 PRE_first_tail_x15_r0_body.iso146 PRE_first_tail_x15_r0_body.zwr146
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP146
  csupp := PRE_first_tail_x15_r0_body.csupp146
  cbound := PRE_first_tail_x15_r0_body.cbound146
  zimg := PRE_first_tail_x15_r0_body.zimg146
  zctl := PRE_first_tail_x15_r0_body.zctl146
  zstack := PRE_first_tail_x15_r0_body.zstack146
  zjobs := PRE_first_tail_x15_r0_body.zjobs146
  zstores := PRE_first_tail_x15_r0_body.zstores146
  zroots := PRE_first_tail_x15_r0_body.zroots146
  znC := PRE_first_tail_x15_r0_body.znC146
  ctab := PRE_first_tail_x15_r0_body.ctab146
  zbin := PRE_first_tail_x15_r0_body.zbin146
  cbridge := PRE_first_tail_x15_r0_body.cbridge146
  sbridge := bodyBridge146
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj146
  cshiftR := fun h hNL => bodyCshift146 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN146
  raised := PRE_first_tail_x15_r0_body.raised146
  cbigs := PRE_first_tail_x15_r0_body.cbigs146
  cjcl := PRE_first_tail_x15_r0_body.cjcl146
  xnLe := Nat.le_of_ble_eq_true bodyXn146
  loLe := Nat.le_of_ble_eq_true bodyLo146
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB146
  cntM := bodyCntM146
  hiLe := Nat.le_of_ble_eq_true bodyHi146
  nhiLe := Nat.le_of_ble_eq_true bodyNhi146
  jsHeap := bodyJs146
  jsRoots := bodyJsRoots146
  jsNative := bodyJsNative146
  framesEmpty := bodyFramesEmpty146
  trailOld := by decide
  lowVars := bodyLow146

def bodyQs146 : List (Option Q) := []
noncomputable def bodyEs146 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr146.map fun r => nth? PRE_first_tail_x15_r0_body.st146.S2.tab r
kernel_rfl bodyResChk146 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs146 bodyQs146) = true
kernel_rfl bodyLq146 : bodyQs146.length = PRE_first_tail_x15_r0_body.cws146.length
kernel_rfl bodyNrLo146 : PRE_first_tail_x15_r0_body.nr146.all (Nat.ble PRE_first_tail_x15_r0_body.S1408.tab.length) = true
kernel_rfl bodySub146 : (Oracles.PRE_first_tail_x15_r0_body.map_site146.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost146 : postSubB bodyM PRE_first_tail_x15_r0_body.ws146 PRE_first_tail_x15_r0_body.cws146 bodyQs146 = true
kernel_rfl bodyDrop146 : Nat.ble (51531 + (PRE_first_tail_x15_r0_body.s1409.next - PRE_first_tail_x15_r0_body.s1410.next)) 51550 = true
kernel_rfl bodyDropH146 : Nat.ble (970 + ((mlxOf PRE_first_tail_x15_r0_body.s1409.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1410.ffi).next)) 970 = true
kernel_rfl bodyDropN146 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1409.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1410.ffi).nnext)) 0 = true
kernel_rfl bodyDv146 : bodyΘ.1.take 774 = bodyΘ.1.take 774 ++ PRE_first_tail_x15_r0_body.cws146
kernel_rfl bodyDe146 : bodyΘ.2.take 774 = bodyΘ.2.take 774 ++ PRE_first_tail_x15_r0_body.nr146.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st146.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 774) (bodyΘ.2.take 774)))
kernel_rfl bodyDl146 : (bodyΘ.1.take 774).length = (bodyΘ.2.take 774).length
kernel_rfl bodyDold146 : (bodyΘ.1.take 774).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws146).isNone && !PRE_first_tail_x15_r0_body.ws146.contains v) = true
kernel_rfl bodyDfree146 : (bodyΘ.2.take 774).all (fun e => (PRE_first_tail_x15_r0_body.cws146 ++ PRE_first_tail_x15_r0_body.ws146).all fun w => e.noVar w) = true

theorem bodyStep146 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨51531, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1408 PRE_first_tail_x15_r0_body.S1408)
      (bodyCut NB T tk π i x0 bodyΘ ⟨51550, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.S1410) (206 + 1) :=
  bodySite bodyFacts146.cfix bodyFacts146.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st146.S2.tab) (Es := bodyEs146) (qs := bodyQs146)
    (ok := PRE_first_tail_x15_r0_body.st146.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site146 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts146
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site146 r hr) hi (MapOk.sub hm (sub_of_all bodySub146)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk146 r hr) hi hm ho hq)
    bodyLq146 rfl bodyNrLo146 (postSub_sound bodyPost146)
    (Nat.le_of_ble_eq_true bodyDrop146) (by decide) (Nat.le_of_ble_eq_true bodyDropH146) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN146) (by decide)
    bodyDv146 bodyDe146 bodyDl146 bodyDold146 bodyDfree146 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
