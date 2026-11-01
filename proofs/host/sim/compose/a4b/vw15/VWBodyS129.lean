import host.sim.compose.a4b.vw15.VWBodyJ129
import host.sim.compose.a4b.vw15.VWBodySite129
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

theorem bodyCshift129 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1252.tab.length PRE_first_tail_x15_r0_body.s1252.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P129.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P129 5613 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.s1254.ffi PRE_first_tail_x15_r0_body.s1253.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_129
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_129
  have hcl : SSt (· < 5613) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1252.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_129] <;> decide) PRE_first_tail_x15_r0_body.cnodesK129 PRE_first_tail_x15_r0_body.cobjsK129
      PRE_first_tail_x15_r0_body.citemsK129 PRE_first_tail_x15_r0_body.cbd129 PRE_first_tail_x15_r0_body.csst129
  exact PRE_first_tail_x15_r0_body.cshift129 bodyNcl129 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_129] at this; exact this)


kernel_rfl bodyFramesEmpty129 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1253 a).isEmpty) = true
kernel_rfl bodyJsRoots129 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1252.next) PRE_first_tail_x15_r0_body.s1254.trace PRE_first_tail_x15_r0_body.s1254 = true
kernel_rfl bodyJsNative129 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1254.ffi) = true
kernel_rfl bodyLow129 : (PRE_first_tail_x15_r0_body.cws129 ++ PRE_first_tail_x15_r0_body.ws129).all (Nat.ble 9) = true
kernel_rfl bodyCntM129 : countersOkB PRE_first_tail_x15_r0_body.s1252 PRE_first_tail_x15_r0_body.s1253 = true
kernel_rfl bodyHi129 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1254.ffi).next setupP.E = true
kernel_rfl bodyNhi129 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1254.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge129 : bridgeOf PRE_first_tail_x15_r0_body.s1253.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1252.ffi
kernel_rfl bodyNN129 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1252.ffi).nnext PRE_first_tail_x15_r0_body.P129.NL = true
kernel_rfl bodyXn129 : Nat.ble (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1254.ffi).next = true
kernel_rfl bodyLo129 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1254.ffi).next = true
theorem bodyFacts129 : BodySiteFacts PRE_first_tail_x15_r0_body.s1252 PRE_first_tail_x15_r0_body.s1253 PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1252 PRE_first_tail_x15_r0_body.S1253 PRE_first_tail_x15_r0_body.S1254
    PRE_first_tail_x15_r0_body.ws129 PRE_first_tail_x15_r0_body.cws129 PRE_first_tail_x15_r0_body.nr129 PRE_first_tail_x15_r0_body.pl129 PRE_first_tail_x15_r0_body.cl129 2777021 5613 PRE_first_tail_x15_r0_body.kd129 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.P129
    ⟨20753, 17846, 2776656, 5604⟩ ⟨20757, 17852, 2776671, 5613⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap129
  clean := bodyClean129
  cfix := PRE_first_tail_x15_r0_body.cfix129
  zpl := PRE_first_tail_x15_r0_body.zpl129
  zplnd := PRE_first_tail_x15_r0_body.zplnd129
  zn1 := PRE_first_tail_x15_r0_body.zn1129
  zfirst := PRE_first_tail_x15_r0_body.zfirst129
  zscn := PRE_first_tail_x15_r0_body.zscn129
  zsmn := PRE_first_tail_x15_r0_body.zsmn129
  zgrow := PRE_first_tail_x15_r0_body.zgrow129
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab129
  zfresh := PRE_first_tail_x15_r0_body.zfresh129
  zcnd := PRE_first_tail_x15_r0_body.zcnd129
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi129
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt129
  zgP := PRE_first_tail_x15_r0_body.zg129_2665
  zkP := PRE_first_tail_x15_r0_body.zk129_2665
  zmP := PRE_first_tail_x15_r0_body.zm129_2665
  zgC := PRE_first_tail_x15_r0_body.zg129_2673467
  zkC := PRE_first_tail_x15_r0_body.zk129_2673467
  zmC := PRE_first_tail_x15_r0_body.zm129_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw129_2673472
  zwV := PRE_first_tail_x15_r0_body.zw129_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap129
  zclbd := PRE_first_tail_x15_r0_body.zclbd129
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap129 PRE_first_tail_x15_r0_body.stFoot129 PRE_first_tail_x15_r0_body.iso129 PRE_first_tail_x15_r0_body.zwr129
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP129
  csupp := PRE_first_tail_x15_r0_body.csupp129
  cbound := PRE_first_tail_x15_r0_body.cbound129
  zimg := PRE_first_tail_x15_r0_body.zimg129
  zctl := PRE_first_tail_x15_r0_body.zctl129
  zstack := PRE_first_tail_x15_r0_body.zstack129
  zjobs := PRE_first_tail_x15_r0_body.zjobs129
  zstores := PRE_first_tail_x15_r0_body.zstores129
  zroots := PRE_first_tail_x15_r0_body.zroots129
  znC := PRE_first_tail_x15_r0_body.znC129
  ctab := PRE_first_tail_x15_r0_body.ctab129
  zbin := PRE_first_tail_x15_r0_body.zbin129
  cbridge := PRE_first_tail_x15_r0_body.cbridge129
  sbridge := bodyBridge129
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj129
  cshiftR := fun h hNL => bodyCshift129 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN129
  raised := PRE_first_tail_x15_r0_body.raised129
  cbigs := PRE_first_tail_x15_r0_body.cbigs129
  cjcl := PRE_first_tail_x15_r0_body.cjcl129
  xnLe := Nat.le_of_ble_eq_true bodyXn129
  loLe := Nat.le_of_ble_eq_true bodyLo129
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB129
  cntM := bodyCntM129
  hiLe := Nat.le_of_ble_eq_true bodyHi129
  nhiLe := Nat.le_of_ble_eq_true bodyNhi129
  jsHeap := bodyJs129
  jsRoots := bodyJsRoots129
  jsNative := bodyJsNative129
  framesEmpty := bodyFramesEmpty129
  trailOld := by decide
  lowVars := bodyLow129

def bodyQs129 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs129 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr129.map fun r => nth? PRE_first_tail_x15_r0_body.st129.S3.tab r
kernel_rfl bodyResChk129 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs129 bodyQs129) = true
kernel_rfl bodyLq129 : bodyQs129.length = PRE_first_tail_x15_r0_body.cws129.length
kernel_rfl bodyNrLo129 : PRE_first_tail_x15_r0_body.nr129.all (Nat.ble PRE_first_tail_x15_r0_body.S1252.tab.length) = true
kernel_rfl bodySub129 : (Oracles.PRE_first_tail_x15_r0_body.map_site129.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost129 : postSubB bodyM PRE_first_tail_x15_r0_body.ws129 PRE_first_tail_x15_r0_body.cws129 bodyQs129 = true
kernel_rfl bodyDrop129 : Nat.ble (46146 + (PRE_first_tail_x15_r0_body.s1253.next - PRE_first_tail_x15_r0_body.s1254.next)) 46496 = true
kernel_rfl bodyDropH129 : Nat.ble (866 + ((mlxOf PRE_first_tail_x15_r0_body.s1253.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1254.ffi).next)) 868 = true
kernel_rfl bodyDropN129 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1253.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1254.ffi).nnext)) 0 = true
kernel_rfl bodyDv129 : bodyΘ.1.take 693 = bodyΘ.1.take 684 ++ PRE_first_tail_x15_r0_body.cws129
kernel_rfl bodyDe129 : bodyΘ.2.take 693 = bodyΘ.2.take 684 ++ PRE_first_tail_x15_r0_body.nr129.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st129.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 684) (bodyΘ.2.take 684)))
kernel_rfl bodyDl129 : (bodyΘ.1.take 684).length = (bodyΘ.2.take 684).length
kernel_rfl bodyDold129 : (bodyΘ.1.take 684).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws129).isNone && !PRE_first_tail_x15_r0_body.ws129.contains v) = true
kernel_rfl bodyDfree129 : (bodyΘ.2.take 693).all (fun e => (PRE_first_tail_x15_r0_body.cws129 ++ PRE_first_tail_x15_r0_body.ws129).all fun w => e.noVar w) = true

theorem bodyStep129 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46146, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1252 PRE_first_tail_x15_r0_body.S1252)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46496, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.S1254) (3452 + 1) :=
  bodySite bodyFacts129.cfix bodyFacts129.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st129.S3.tab) (Es := bodyEs129) (qs := bodyQs129)
    (ok := PRE_first_tail_x15_r0_body.st129.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site129 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts129
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site129 r hr) hi (MapOk.sub hm (sub_of_all bodySub129)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk129 r hr) hi hm ho hq)
    bodyLq129 rfl bodyNrLo129 (postSub_sound bodyPost129)
    (Nat.le_of_ble_eq_true bodyDrop129) (by decide) (Nat.le_of_ble_eq_true bodyDropH129) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN129) (by decide)
    bodyDv129 bodyDe129 bodyDl129 bodyDold129 bodyDfree129 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
