import host.sim.compose.a4b.vw15.VWBodyJ189
import host.sim.compose.a4b.vw15.VWBodySite189
import host.sim.compose.a4b.vw15.VWBodyOracles_47
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift189 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1827.tab.length PRE_first_tail_x15_r0_body.s1827.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P189.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P189 8178 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.s1829.ffi PRE_first_tail_x15_r0_body.s1828.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_189
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_189
  have hcl : SSt (· < 8178) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1827.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_189] <;> decide) PRE_first_tail_x15_r0_body.cnodesK189 PRE_first_tail_x15_r0_body.cobjsK189
      PRE_first_tail_x15_r0_body.citemsK189 PRE_first_tail_x15_r0_body.cbd189 PRE_first_tail_x15_r0_body.csst189
  exact PRE_first_tail_x15_r0_body.cshift189 bodyNcl189 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_189] at this; exact this)


kernel_rfl bodyFramesEmpty189 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1828 a).isEmpty) = true
kernel_rfl bodyJsRoots189 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1827.next) PRE_first_tail_x15_r0_body.s1829.trace PRE_first_tail_x15_r0_body.s1829 = true
kernel_rfl bodyJsNative189 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1829.ffi) = true
kernel_rfl bodyLow189 : (PRE_first_tail_x15_r0_body.cws189 ++ PRE_first_tail_x15_r0_body.ws189).all (Nat.ble 9) = true
kernel_rfl bodyCntM189 : countersOkB PRE_first_tail_x15_r0_body.s1827 PRE_first_tail_x15_r0_body.s1828 = true
kernel_rfl bodyHi189 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1829.ffi).next setupP.E = true
kernel_rfl bodyNhi189 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1829.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge189 : bridgeOf PRE_first_tail_x15_r0_body.s1828.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1827.ffi
kernel_rfl bodyNN189 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1827.ffi).nnext PRE_first_tail_x15_r0_body.P189.NL = true
kernel_rfl bodyXn189 : Nat.ble (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1829.ffi).next = true
kernel_rfl bodyLo189 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1829.ffi).next = true
theorem bodyFacts189 : BodySiteFacts PRE_first_tail_x15_r0_body.s1827 PRE_first_tail_x15_r0_body.s1828 PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1827 PRE_first_tail_x15_r0_body.S1828 PRE_first_tail_x15_r0_body.S1829
    PRE_first_tail_x15_r0_body.ws189 PRE_first_tail_x15_r0_body.cws189 PRE_first_tail_x15_r0_body.nr189 PRE_first_tail_x15_r0_body.pl189 PRE_first_tail_x15_r0_body.cl189 2824133 8178 PRE_first_tail_x15_r0_body.kd189 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.P189
    ⟨21933, 19031, 2823768, 8169⟩ ⟨21937, 19037, 2823783, 8178⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap189
  clean := bodyClean189
  cfix := PRE_first_tail_x15_r0_body.cfix189
  zpl := PRE_first_tail_x15_r0_body.zpl189
  zplnd := PRE_first_tail_x15_r0_body.zplnd189
  zn1 := PRE_first_tail_x15_r0_body.zn1189
  zfirst := PRE_first_tail_x15_r0_body.zfirst189
  zscn := PRE_first_tail_x15_r0_body.zscn189
  zsmn := PRE_first_tail_x15_r0_body.zsmn189
  zgrow := PRE_first_tail_x15_r0_body.zgrow189
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab189
  zfresh := PRE_first_tail_x15_r0_body.zfresh189
  zcnd := PRE_first_tail_x15_r0_body.zcnd189
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi189
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt189
  zgP := PRE_first_tail_x15_r0_body.zg189_2665
  zkP := PRE_first_tail_x15_r0_body.zk189_2665
  zmP := PRE_first_tail_x15_r0_body.zm189_2665
  zgC := PRE_first_tail_x15_r0_body.zg189_2673467
  zkC := PRE_first_tail_x15_r0_body.zk189_2673467
  zmC := PRE_first_tail_x15_r0_body.zm189_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw189_2673472
  zwV := PRE_first_tail_x15_r0_body.zw189_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap189
  zclbd := PRE_first_tail_x15_r0_body.zclbd189
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap189 PRE_first_tail_x15_r0_body.stFoot189 PRE_first_tail_x15_r0_body.iso189 PRE_first_tail_x15_r0_body.zwr189
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP189
  csupp := PRE_first_tail_x15_r0_body.csupp189
  cbound := PRE_first_tail_x15_r0_body.cbound189
  zimg := PRE_first_tail_x15_r0_body.zimg189
  zctl := PRE_first_tail_x15_r0_body.zctl189
  zstack := PRE_first_tail_x15_r0_body.zstack189
  zjobs := PRE_first_tail_x15_r0_body.zjobs189
  zstores := PRE_first_tail_x15_r0_body.zstores189
  zroots := PRE_first_tail_x15_r0_body.zroots189
  znC := PRE_first_tail_x15_r0_body.znC189
  ctab := PRE_first_tail_x15_r0_body.ctab189
  zbin := PRE_first_tail_x15_r0_body.zbin189
  cbridge := PRE_first_tail_x15_r0_body.cbridge189
  sbridge := bodyBridge189
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj189
  cshiftR := fun h hNL => bodyCshift189 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN189
  raised := PRE_first_tail_x15_r0_body.raised189
  cbigs := PRE_first_tail_x15_r0_body.cbigs189
  cjcl := PRE_first_tail_x15_r0_body.cjcl189
  xnLe := Nat.le_of_ble_eq_true bodyXn189
  loLe := Nat.le_of_ble_eq_true bodyLo189
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB189
  cntM := bodyCntM189
  hiLe := Nat.le_of_ble_eq_true bodyHi189
  nhiLe := Nat.le_of_ble_eq_true bodyNhi189
  jsHeap := bodyJs189
  jsRoots := bodyJsRoots189
  jsNative := bodyJsNative189
  framesEmpty := bodyFramesEmpty189
  trailOld := by decide
  lowVars := bodyLow189

def bodyQs189 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs189 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr189.map fun r => nth? PRE_first_tail_x15_r0_body.st189.S3.tab r
kernel_rfl bodyResChk189 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs189 bodyQs189) = true
kernel_rfl bodyLq189 : bodyQs189.length = PRE_first_tail_x15_r0_body.cws189.length
kernel_rfl bodyNrLo189 : PRE_first_tail_x15_r0_body.nr189.all (Nat.ble PRE_first_tail_x15_r0_body.S1827.tab.length) = true
kernel_rfl bodySub189 : (Oracles.PRE_first_tail_x15_r0_body.map_site189.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost189 : postSubB bodyM PRE_first_tail_x15_r0_body.ws189 PRE_first_tail_x15_r0_body.cws189 bodyQs189 = true
kernel_rfl bodyDrop189 : Nat.ble (65488 + (PRE_first_tail_x15_r0_body.s1828.next - PRE_first_tail_x15_r0_body.s1829.next)) 65838 = true
kernel_rfl bodyDropH189 : Nat.ble (1251 + ((mlxOf PRE_first_tail_x15_r0_body.s1828.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1829.ffi).next)) 1253 = true
kernel_rfl bodyDropN189 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1828.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1829.ffi).nnext)) 0 = true
kernel_rfl bodyDv189 : bodyΘ.1.take 1008 = bodyΘ.1.take 999 ++ PRE_first_tail_x15_r0_body.cws189
kernel_rfl bodyDe189 : bodyΘ.2.take 1008 = bodyΘ.2.take 999 ++ PRE_first_tail_x15_r0_body.nr189.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st189.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 999) (bodyΘ.2.take 999)))
kernel_rfl bodyDl189 : (bodyΘ.1.take 999).length = (bodyΘ.2.take 999).length
kernel_rfl bodyDold189 : (bodyΘ.1.take 999).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws189).isNone && !PRE_first_tail_x15_r0_body.ws189.contains v) = true
kernel_rfl bodyDfree189 : (bodyΘ.2.take 1008).all (fun e => (PRE_first_tail_x15_r0_body.cws189 ++ PRE_first_tail_x15_r0_body.ws189).all fun w => e.noVar w) = true

theorem bodyStep189 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65488, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1827 PRE_first_tail_x15_r0_body.S1827)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65838, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.S1829) (3452 + 1) :=
  bodySite bodyFacts189.cfix bodyFacts189.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st189.S3.tab) (Es := bodyEs189) (qs := bodyQs189)
    (ok := PRE_first_tail_x15_r0_body.st189.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site189 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts189
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site189 r hr) hi (MapOk.sub hm (sub_of_all bodySub189)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk189 r hr) hi hm ho hq)
    bodyLq189 rfl bodyNrLo189 (postSub_sound bodyPost189)
    (Nat.le_of_ble_eq_true bodyDrop189) (by decide) (Nat.le_of_ble_eq_true bodyDropH189) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN189) (by decide)
    bodyDv189 bodyDe189 bodyDl189 bodyDold189 bodyDfree189 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
