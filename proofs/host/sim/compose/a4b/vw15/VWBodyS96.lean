import host.sim.compose.a4b.vw15.VWBodyJ96
import host.sim.compose.a4b.vw15.VWBodySite96
import host.sim.compose.a4b.vw15.VWBodyOracles_24
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift96 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S936.tab.length PRE_first_tail_x15_r0_body.s936.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P96.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P96 4205 PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.s938.ffi PRE_first_tail_x15_r0_body.s937.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_96
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_96
  have hcl : SSt (· < 4205) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S936.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_96] <;> decide) PRE_first_tail_x15_r0_body.cnodesK96 PRE_first_tail_x15_r0_body.cobjsK96
      PRE_first_tail_x15_r0_body.citemsK96 PRE_first_tail_x15_r0_body.cbd96 PRE_first_tail_x15_r0_body.csst96
  exact PRE_first_tail_x15_r0_body.cshift96 bodyNcl96 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_96] at this; exact this)


kernel_rfl bodyFramesEmpty96 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s937 a).isEmpty) = true
kernel_rfl bodyJsRoots96 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s936.next) PRE_first_tail_x15_r0_body.s938.trace PRE_first_tail_x15_r0_body.s938 = true
kernel_rfl bodyJsNative96 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s938.ffi) = true
kernel_rfl bodyLow96 : (PRE_first_tail_x15_r0_body.cws96 ++ PRE_first_tail_x15_r0_body.ws96).all (Nat.ble 9) = true
kernel_rfl bodyCntM96 : countersOkB PRE_first_tail_x15_r0_body.s936 PRE_first_tail_x15_r0_body.s937 = true
kernel_rfl bodyHi96 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s938.ffi).next setupP.E = true
kernel_rfl bodyNhi96 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s938.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge96 : bridgeOf PRE_first_tail_x15_r0_body.s937.ffi = bridgeOf PRE_first_tail_x15_r0_body.s936.ffi
kernel_rfl bodyNN96 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s936.ffi).nnext PRE_first_tail_x15_r0_body.P96.NL = true
kernel_rfl bodyXn96 : Nat.ble (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s938.ffi).next = true
kernel_rfl bodyLo96 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s938.ffi).next = true
theorem bodyFacts96 : BodySiteFacts PRE_first_tail_x15_r0_body.s936 PRE_first_tail_x15_r0_body.s937 PRE_first_tail_x15_r0_body.s938 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S936 PRE_first_tail_x15_r0_body.S937 PRE_first_tail_x15_r0_body.S938
    PRE_first_tail_x15_r0_body.ws96 PRE_first_tail_x15_r0_body.cws96 PRE_first_tail_x15_r0_body.nr96 PRE_first_tail_x15_r0_body.pl96 PRE_first_tail_x15_r0_body.cl96 2751946 4205 PRE_first_tail_x15_r0_body.kd96 PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.P96
    ⟨20104, 17174, 2750791, 4187⟩ ⟨20107, 17201, 2750797, 4205⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap96
  clean := bodyClean96
  cfix := PRE_first_tail_x15_r0_body.cfix96
  zpl := PRE_first_tail_x15_r0_body.zpl96
  zplnd := PRE_first_tail_x15_r0_body.zplnd96
  zn1 := PRE_first_tail_x15_r0_body.zn196
  zfirst := PRE_first_tail_x15_r0_body.zfirst96
  zscn := PRE_first_tail_x15_r0_body.zscn96
  zsmn := PRE_first_tail_x15_r0_body.zsmn96
  zgrow := PRE_first_tail_x15_r0_body.zgrow96
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab96
  zfresh := PRE_first_tail_x15_r0_body.zfresh96
  zcnd := PRE_first_tail_x15_r0_body.zcnd96
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi96
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt96
  zgP := PRE_first_tail_x15_r0_body.zg96_2665
  zkP := PRE_first_tail_x15_r0_body.zk96_2665
  zmP := PRE_first_tail_x15_r0_body.zm96_2665
  zgC := PRE_first_tail_x15_r0_body.zg96_2673467
  zkC := PRE_first_tail_x15_r0_body.zk96_2673467
  zmC := PRE_first_tail_x15_r0_body.zm96_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw96_2673472
  zwV := PRE_first_tail_x15_r0_body.zw96_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap96
  zclbd := PRE_first_tail_x15_r0_body.zclbd96
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap96 PRE_first_tail_x15_r0_body.stFoot96 PRE_first_tail_x15_r0_body.iso96 PRE_first_tail_x15_r0_body.zwr96
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP96
  csupp := PRE_first_tail_x15_r0_body.csupp96
  cbound := PRE_first_tail_x15_r0_body.cbound96
  zimg := PRE_first_tail_x15_r0_body.zimg96
  zctl := PRE_first_tail_x15_r0_body.zctl96
  zstack := PRE_first_tail_x15_r0_body.zstack96
  zjobs := PRE_first_tail_x15_r0_body.zjobs96
  zstores := PRE_first_tail_x15_r0_body.zstores96
  zroots := PRE_first_tail_x15_r0_body.zroots96
  znC := PRE_first_tail_x15_r0_body.znC96
  ctab := PRE_first_tail_x15_r0_body.ctab96
  zbin := PRE_first_tail_x15_r0_body.zbin96
  cbridge := PRE_first_tail_x15_r0_body.cbridge96
  sbridge := bodyBridge96
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj96
  cshiftR := fun h hNL => bodyCshift96 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN96
  raised := PRE_first_tail_x15_r0_body.raised96
  cbigs := PRE_first_tail_x15_r0_body.cbigs96
  cjcl := PRE_first_tail_x15_r0_body.cjcl96
  xnLe := Nat.le_of_ble_eq_true bodyXn96
  loLe := Nat.le_of_ble_eq_true bodyLo96
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB96
  cntM := bodyCntM96
  hiLe := Nat.le_of_ble_eq_true bodyHi96
  nhiLe := Nat.le_of_ble_eq_true bodyNhi96
  jsHeap := bodyJs96
  jsRoots := bodyJsRoots96
  jsNative := bodyJsNative96
  framesEmpty := bodyFramesEmpty96
  trailOld := by decide
  lowVars := bodyLow96

def bodyQs96 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs96 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr96.map fun r => nth? PRE_first_tail_x15_r0_body.st96.S5.tab r
kernel_rfl bodyResChk96 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs96 bodyQs96) = true
kernel_rfl bodyLq96 : bodyQs96.length = PRE_first_tail_x15_r0_body.cws96.length
kernel_rfl bodyNrLo96 : PRE_first_tail_x15_r0_body.nr96.all (Nat.ble PRE_first_tail_x15_r0_body.S936.tab.length) = true
kernel_rfl bodySub96 : (Oracles.PRE_first_tail_x15_r0_body.map_site96.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost96 : postSubB bodyM PRE_first_tail_x15_r0_body.ws96 PRE_first_tail_x15_r0_body.cws96 bodyQs96 = true
kernel_rfl bodyDrop96 : Nat.ble (34955 + (PRE_first_tail_x15_r0_body.s937.next - PRE_first_tail_x15_r0_body.s938.next)) 36104 = true
kernel_rfl bodyDropH96 : Nat.ble (637 + ((mlxOf PRE_first_tail_x15_r0_body.s937.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s938.ffi).next)) 662 = true
kernel_rfl bodyDropN96 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s937.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s938.ffi).nnext)) 0 = true
kernel_rfl bodyDv96 : bodyΘ.1.take 522 = bodyΘ.1.take 504 ++ PRE_first_tail_x15_r0_body.cws96
kernel_rfl bodyDe96 : bodyΘ.2.take 522 = bodyΘ.2.take 504 ++ PRE_first_tail_x15_r0_body.nr96.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st96.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 504) (bodyΘ.2.take 504)))
kernel_rfl bodyDl96 : (bodyΘ.1.take 504).length = (bodyΘ.2.take 504).length
kernel_rfl bodyDold96 : (bodyΘ.1.take 504).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws96).isNone && !PRE_first_tail_x15_r0_body.ws96.contains v) = true
kernel_rfl bodyDfree96 : (bodyΘ.2.take 522).all (fun e => (PRE_first_tail_x15_r0_body.cws96 ++ PRE_first_tail_x15_r0_body.ws96).all fun w => e.noVar w) = true

theorem bodyStep96 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34955, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s936 PRE_first_tail_x15_r0_body.S936)
      (bodyCut NB T tk π i x0 bodyΘ ⟨36104, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s938 PRE_first_tail_x15_r0_body.S938) (11334 + 1) :=
  bodySite bodyFacts96.cfix bodyFacts96.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st96.S5.tab) (Es := bodyEs96) (qs := bodyQs96)
    (ok := PRE_first_tail_x15_r0_body.st96.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site96 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts96
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site96 r hr) hi (MapOk.sub hm (sub_of_all bodySub96)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk96 r hr) hi hm ho hq)
    bodyLq96 rfl bodyNrLo96 (postSub_sound bodyPost96)
    (Nat.le_of_ble_eq_true bodyDrop96) (by decide) (Nat.le_of_ble_eq_true bodyDropH96) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN96) (by decide)
    bodyDv96 bodyDe96 bodyDl96 bodyDold96 bodyDfree96 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
