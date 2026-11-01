import host.sim.compose.a4b.vw15.VWBodyJ111
import host.sim.compose.a4b.vw15.VWBodySite111
import host.sim.compose.a4b.vw15.VWBodyOracles_27
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift111 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1080.tab.length PRE_first_tail_x15_r0_body.s1080.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P111.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P111 4847 PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.s1082.ffi PRE_first_tail_x15_r0_body.s1081.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_111
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_111
  have hcl : SSt (· < 4847) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1080.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_111] <;> decide) PRE_first_tail_x15_r0_body.cnodesK111 PRE_first_tail_x15_r0_body.cobjsK111
      PRE_first_tail_x15_r0_body.citemsK111 PRE_first_tail_x15_r0_body.cbd111 PRE_first_tail_x15_r0_body.csst111
  exact PRE_first_tail_x15_r0_body.cshift111 bodyNcl111 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_111] at this; exact this)


kernel_rfl bodyFramesEmpty111 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1081 a).isEmpty) = true
kernel_rfl bodyJsRoots111 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1080.next) PRE_first_tail_x15_r0_body.s1082.trace PRE_first_tail_x15_r0_body.s1082 = true
kernel_rfl bodyJsNative111 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1082.ffi) = true
kernel_rfl bodyLow111 : (PRE_first_tail_x15_r0_body.cws111 ++ PRE_first_tail_x15_r0_body.ws111).all (Nat.ble 9) = true
kernel_rfl bodyCntM111 : countersOkB PRE_first_tail_x15_r0_body.s1080 PRE_first_tail_x15_r0_body.s1081 = true
kernel_rfl bodyHi111 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1082.ffi).next setupP.E = true
kernel_rfl bodyNhi111 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1082.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge111 : bridgeOf PRE_first_tail_x15_r0_body.s1081.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1080.ffi
kernel_rfl bodyNN111 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1080.ffi).nnext PRE_first_tail_x15_r0_body.P111.NL = true
kernel_rfl bodyXn111 : Nat.ble (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1082.ffi).next = true
kernel_rfl bodyLo111 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1082.ffi).next = true
theorem bodyFacts111 : BodySiteFacts PRE_first_tail_x15_r0_body.s1080 PRE_first_tail_x15_r0_body.s1081 PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1080 PRE_first_tail_x15_r0_body.S1081 PRE_first_tail_x15_r0_body.S1082
    PRE_first_tail_x15_r0_body.ws111 PRE_first_tail_x15_r0_body.cws111 PRE_first_tail_x15_r0_body.nr111 PRE_first_tail_x15_r0_body.pl111 PRE_first_tail_x15_r0_body.cl111 2763622 4847 PRE_first_tail_x15_r0_body.kd111 PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.P111
    ⟨20397, 17474, 2762467, 4829⟩ ⟨20400, 17501, 2762473, 4847⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap111
  clean := bodyClean111
  cfix := PRE_first_tail_x15_r0_body.cfix111
  zpl := PRE_first_tail_x15_r0_body.zpl111
  zplnd := PRE_first_tail_x15_r0_body.zplnd111
  zn1 := PRE_first_tail_x15_r0_body.zn1111
  zfirst := PRE_first_tail_x15_r0_body.zfirst111
  zscn := PRE_first_tail_x15_r0_body.zscn111
  zsmn := PRE_first_tail_x15_r0_body.zsmn111
  zgrow := PRE_first_tail_x15_r0_body.zgrow111
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab111
  zfresh := PRE_first_tail_x15_r0_body.zfresh111
  zcnd := PRE_first_tail_x15_r0_body.zcnd111
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi111
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt111
  zgP := PRE_first_tail_x15_r0_body.zg111_2665
  zkP := PRE_first_tail_x15_r0_body.zk111_2665
  zmP := PRE_first_tail_x15_r0_body.zm111_2665
  zgC := PRE_first_tail_x15_r0_body.zg111_2673467
  zkC := PRE_first_tail_x15_r0_body.zk111_2673467
  zmC := PRE_first_tail_x15_r0_body.zm111_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw111_2673472
  zwV := PRE_first_tail_x15_r0_body.zw111_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap111
  zclbd := PRE_first_tail_x15_r0_body.zclbd111
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap111 PRE_first_tail_x15_r0_body.stFoot111 PRE_first_tail_x15_r0_body.iso111 PRE_first_tail_x15_r0_body.zwr111
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP111
  csupp := PRE_first_tail_x15_r0_body.csupp111
  cbound := PRE_first_tail_x15_r0_body.cbound111
  zimg := PRE_first_tail_x15_r0_body.zimg111
  zctl := PRE_first_tail_x15_r0_body.zctl111
  zstack := PRE_first_tail_x15_r0_body.zstack111
  zjobs := PRE_first_tail_x15_r0_body.zjobs111
  zstores := PRE_first_tail_x15_r0_body.zstores111
  zroots := PRE_first_tail_x15_r0_body.zroots111
  znC := PRE_first_tail_x15_r0_body.znC111
  ctab := PRE_first_tail_x15_r0_body.ctab111
  zbin := PRE_first_tail_x15_r0_body.zbin111
  cbridge := PRE_first_tail_x15_r0_body.cbridge111
  sbridge := bodyBridge111
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj111
  cshiftR := fun h hNL => bodyCshift111 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN111
  raised := PRE_first_tail_x15_r0_body.raised111
  cbigs := PRE_first_tail_x15_r0_body.cbigs111
  cjcl := PRE_first_tail_x15_r0_body.cjcl111
  xnLe := Nat.le_of_ble_eq_true bodyXn111
  loLe := Nat.le_of_ble_eq_true bodyLo111
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB111
  cntM := bodyCntM111
  hiLe := Nat.le_of_ble_eq_true bodyHi111
  nhiLe := Nat.le_of_ble_eq_true bodyNhi111
  jsHeap := bodyJs111
  jsRoots := bodyJsRoots111
  jsNative := bodyJsNative111
  framesEmpty := bodyFramesEmpty111
  trailOld := by decide
  lowVars := bodyLow111

def bodyQs111 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs111 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr111.map fun r => nth? PRE_first_tail_x15_r0_body.st111.S5.tab r
kernel_rfl bodyResChk111 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs111 bodyQs111) = true
kernel_rfl bodyLq111 : bodyQs111.length = PRE_first_tail_x15_r0_body.cws111.length
kernel_rfl bodyNrLo111 : PRE_first_tail_x15_r0_body.nr111.all (Nat.ble PRE_first_tail_x15_r0_body.S1080.tab.length) = true
kernel_rfl bodySub111 : (Oracles.PRE_first_tail_x15_r0_body.map_site111.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost111 : postSubB bodyM PRE_first_tail_x15_r0_body.ws111 PRE_first_tail_x15_r0_body.cws111 bodyQs111 = true
kernel_rfl bodyDrop111 : Nat.ble (39979 + (PRE_first_tail_x15_r0_body.s1081.next - PRE_first_tail_x15_r0_body.s1082.next)) 41128 = true
kernel_rfl bodyDropH111 : Nat.ble (739 + ((mlxOf PRE_first_tail_x15_r0_body.s1081.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1082.ffi).next)) 764 = true
kernel_rfl bodyDropN111 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1081.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1082.ffi).nnext)) 0 = true
kernel_rfl bodyDv111 : bodyΘ.1.take 603 = bodyΘ.1.take 585 ++ PRE_first_tail_x15_r0_body.cws111
kernel_rfl bodyDe111 : bodyΘ.2.take 603 = bodyΘ.2.take 585 ++ PRE_first_tail_x15_r0_body.nr111.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st111.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 585) (bodyΘ.2.take 585)))
kernel_rfl bodyDl111 : (bodyΘ.1.take 585).length = (bodyΘ.2.take 585).length
kernel_rfl bodyDold111 : (bodyΘ.1.take 585).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws111).isNone && !PRE_first_tail_x15_r0_body.ws111.contains v) = true
kernel_rfl bodyDfree111 : (bodyΘ.2.take 603).all (fun e => (PRE_first_tail_x15_r0_body.cws111 ++ PRE_first_tail_x15_r0_body.ws111).all fun w => e.noVar w) = true

theorem bodyStep111 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨39979, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1080 PRE_first_tail_x15_r0_body.S1080)
      (bodyCut NB T tk π i x0 bodyΘ ⟨41128, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.S1082) (11334 + 1) :=
  bodySite bodyFacts111.cfix bodyFacts111.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st111.S5.tab) (Es := bodyEs111) (qs := bodyQs111)
    (ok := PRE_first_tail_x15_r0_body.st111.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site111 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts111
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site111 r hr) hi (MapOk.sub hm (sub_of_all bodySub111)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk111 r hr) hi hm ho hq)
    bodyLq111 rfl bodyNrLo111 (postSub_sound bodyPost111)
    (Nat.le_of_ble_eq_true bodyDrop111) (by decide) (Nat.le_of_ble_eq_true bodyDropH111) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN111) (by decide)
    bodyDv111 bodyDe111 bodyDl111 bodyDold111 bodyDfree111 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
