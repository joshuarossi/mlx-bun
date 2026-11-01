import host.sim.compose.a4b.vw15.VWBodyJ3
import host.sim.compose.a4b.vw15.VWBodySite3
import host.sim.compose.a4b.vw15.VWBodyOracles_0
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift3 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S45.tab.length PRE_first_tail_x15_r0_body.s45.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P3.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P3 230 PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.s47.ffi PRE_first_tail_x15_r0_body.s46.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_3
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_3
  have hcl : SSt (· < 230) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S45.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_3] <;> decide) PRE_first_tail_x15_r0_body.cnodesK3 PRE_first_tail_x15_r0_body.cobjsK3
      PRE_first_tail_x15_r0_body.citemsK3 PRE_first_tail_x15_r0_body.cbd3 PRE_first_tail_x15_r0_body.csst3
  exact PRE_first_tail_x15_r0_body.cshift3 bodyNcl3 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_3] at this; exact this)


kernel_rfl bodyFramesEmpty3 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s46 a).isEmpty) = true
kernel_rfl bodyJsRoots3 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s45.next) PRE_first_tail_x15_r0_body.s47.trace PRE_first_tail_x15_r0_body.s47 = true
kernel_rfl bodyJsNative3 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s47.ffi) = true
kernel_rfl bodyLow3 : (PRE_first_tail_x15_r0_body.cws3 ++ PRE_first_tail_x15_r0_body.ws3).all (Nat.ble 9) = true
kernel_rfl bodyCntM3 : countersOkB PRE_first_tail_x15_r0_body.s45 PRE_first_tail_x15_r0_body.s46 = true
kernel_rfl bodyHi3 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s47.ffi).next setupP.E = true
kernel_rfl bodyNhi3 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s47.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge3 : bridgeOf PRE_first_tail_x15_r0_body.s46.ffi = bridgeOf PRE_first_tail_x15_r0_body.s45.ffi
kernel_rfl bodyNN3 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s45.ffi).nnext PRE_first_tail_x15_r0_body.P3.NL = true
kernel_rfl bodyXn3 : Nat.ble (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s47.ffi).next = true
kernel_rfl bodyLo3 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s47.ffi).next = true
theorem bodyFacts3 : BodySiteFacts PRE_first_tail_x15_r0_body.s45 PRE_first_tail_x15_r0_body.s46 PRE_first_tail_x15_r0_body.s47 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S45 PRE_first_tail_x15_r0_body.S46 PRE_first_tail_x15_r0_body.S47
    PRE_first_tail_x15_r0_body.ws3 PRE_first_tail_x15_r0_body.cws3 PRE_first_tail_x15_r0_body.nr3 PRE_first_tail_x15_r0_body.pl3 PRE_first_tail_x15_r0_body.cl3 2678778 230 PRE_first_tail_x15_r0_body.kd3 PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.P3
    ⟨18270, 15341, 2677623, 212⟩ ⟨18273, 15368, 2677629, 230⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap3
  clean := bodyClean3
  cfix := PRE_first_tail_x15_r0_body.cfix3
  zpl := PRE_first_tail_x15_r0_body.zpl3
  zplnd := PRE_first_tail_x15_r0_body.zplnd3
  zn1 := PRE_first_tail_x15_r0_body.zn13
  zfirst := PRE_first_tail_x15_r0_body.zfirst3
  zscn := PRE_first_tail_x15_r0_body.zscn3
  zsmn := PRE_first_tail_x15_r0_body.zsmn3
  zgrow := PRE_first_tail_x15_r0_body.zgrow3
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab3
  zfresh := PRE_first_tail_x15_r0_body.zfresh3
  zcnd := PRE_first_tail_x15_r0_body.zcnd3
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi3
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt3
  zgP := PRE_first_tail_x15_r0_body.zg3_2665
  zkP := PRE_first_tail_x15_r0_body.zk3_2665
  zmP := PRE_first_tail_x15_r0_body.zm3_2665
  zgC := PRE_first_tail_x15_r0_body.zg3_2673467
  zkC := PRE_first_tail_x15_r0_body.zk3_2673467
  zmC := PRE_first_tail_x15_r0_body.zm3_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw3_2673472
  zwV := PRE_first_tail_x15_r0_body.zw3_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap3
  zclbd := PRE_first_tail_x15_r0_body.zclbd3
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap3 PRE_first_tail_x15_r0_body.stFoot3 PRE_first_tail_x15_r0_body.iso3 PRE_first_tail_x15_r0_body.zwr3
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP3
  csupp := PRE_first_tail_x15_r0_body.csupp3
  cbound := PRE_first_tail_x15_r0_body.cbound3
  zimg := PRE_first_tail_x15_r0_body.zimg3
  zctl := PRE_first_tail_x15_r0_body.zctl3
  zstack := PRE_first_tail_x15_r0_body.zstack3
  zjobs := PRE_first_tail_x15_r0_body.zjobs3
  zstores := PRE_first_tail_x15_r0_body.zstores3
  zroots := PRE_first_tail_x15_r0_body.zroots3
  znC := PRE_first_tail_x15_r0_body.znC3
  ctab := PRE_first_tail_x15_r0_body.ctab3
  zbin := PRE_first_tail_x15_r0_body.zbin3
  cbridge := PRE_first_tail_x15_r0_body.cbridge3
  sbridge := bodyBridge3
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj3
  cshiftR := fun h hNL => bodyCshift3 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN3
  raised := PRE_first_tail_x15_r0_body.raised3
  cbigs := PRE_first_tail_x15_r0_body.cbigs3
  cjcl := PRE_first_tail_x15_r0_body.cjcl3
  xnLe := Nat.le_of_ble_eq_true bodyXn3
  loLe := Nat.le_of_ble_eq_true bodyLo3
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB3
  cntM := bodyCntM3
  hiLe := Nat.le_of_ble_eq_true bodyHi3
  nhiLe := Nat.le_of_ble_eq_true bodyNhi3
  jsHeap := bodyJs3
  jsRoots := bodyJsRoots3
  jsNative := bodyJsNative3
  framesEmpty := bodyFramesEmpty3
  trailOld := by decide
  lowVars := bodyLow3

def bodyQs3 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs3 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr3.map fun r => nth? PRE_first_tail_x15_r0_body.st3.S5.tab r
kernel_rfl bodyResChk3 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs3 bodyQs3) = true
kernel_rfl bodyLq3 : bodyQs3.length = PRE_first_tail_x15_r0_body.cws3.length
kernel_rfl bodyNrLo3 : PRE_first_tail_x15_r0_body.nr3.all (Nat.ble PRE_first_tail_x15_r0_body.S45.tab.length) = true
kernel_rfl bodySub3 : (Oracles.PRE_first_tail_x15_r0_body.map_site3.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost3 : postSubB bodyM PRE_first_tail_x15_r0_body.ws3 PRE_first_tail_x15_r0_body.cws3 bodyQs3 = true
kernel_rfl bodyDrop3 : Nat.ble (5284 + (PRE_first_tail_x15_r0_body.s46.next - PRE_first_tail_x15_r0_body.s47.next)) 6433 = true
kernel_rfl bodyDropH3 : Nat.ble (46 + ((mlxOf PRE_first_tail_x15_r0_body.s46.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s47.ffi).next)) 71 = true
kernel_rfl bodyDropN3 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s46.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s47.ffi).nnext)) 0 = true
kernel_rfl bodyDv3 : bodyΘ.1.take 36 = bodyΘ.1.take 18 ++ PRE_first_tail_x15_r0_body.cws3
kernel_rfl bodyDe3 : bodyΘ.2.take 36 = bodyΘ.2.take 18 ++ PRE_first_tail_x15_r0_body.nr3.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st3.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 18) (bodyΘ.2.take 18)))
kernel_rfl bodyDl3 : (bodyΘ.1.take 18).length = (bodyΘ.2.take 18).length
kernel_rfl bodyDold3 : (bodyΘ.1.take 18).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws3).isNone && !PRE_first_tail_x15_r0_body.ws3.contains v) = true
kernel_rfl bodyDfree3 : (bodyΘ.2.take 36).all (fun e => (PRE_first_tail_x15_r0_body.cws3 ++ PRE_first_tail_x15_r0_body.ws3).all fun w => e.noVar w) = true

theorem bodyStep3 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5284, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s45 PRE_first_tail_x15_r0_body.S45)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6433, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s47 PRE_first_tail_x15_r0_body.S47) (11334 + 1) :=
  bodySite bodyFacts3.cfix bodyFacts3.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st3.S5.tab) (Es := bodyEs3) (qs := bodyQs3)
    (ok := PRE_first_tail_x15_r0_body.st3.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site3 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts3
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site3 r hr) hi (MapOk.sub hm (sub_of_all bodySub3)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk3 r hr) hi hm ho hq)
    bodyLq3 rfl bodyNrLo3 (postSub_sound bodyPost3)
    (Nat.le_of_ble_eq_true bodyDrop3) (by decide) (Nat.le_of_ble_eq_true bodyDropH3) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN3) (by decide)
    bodyDv3 bodyDe3 bodyDl3 bodyDold3 bodyDfree3 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
