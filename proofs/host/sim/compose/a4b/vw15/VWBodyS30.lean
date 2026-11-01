import host.sim.compose.a4b.vw15.VWBodyJ30
import host.sim.compose.a4b.vw15.VWBodySite30
import host.sim.compose.a4b.vw15.VWBodyOracles_7
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift30 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S304.tab.length PRE_first_tail_x15_r0_body.s304.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P30.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P30 1385 PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.s306.ffi PRE_first_tail_x15_r0_body.s305.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_30
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_30
  have hcl : SSt (· < 1385) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S304.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_30] <;> decide) PRE_first_tail_x15_r0_body.cnodesK30 PRE_first_tail_x15_r0_body.cobjsK30
      PRE_first_tail_x15_r0_body.citemsK30 PRE_first_tail_x15_r0_body.cbd30 PRE_first_tail_x15_r0_body.csst30
  exact PRE_first_tail_x15_r0_body.cshift30 bodyNcl30 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_30] at this; exact this)


kernel_rfl bodyFramesEmpty30 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s305 a).isEmpty) = true
kernel_rfl bodyJsRoots30 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s304.next) PRE_first_tail_x15_r0_body.s306.trace PRE_first_tail_x15_r0_body.s306 = true
kernel_rfl bodyJsNative30 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s306.ffi) = true
kernel_rfl bodyLow30 : (PRE_first_tail_x15_r0_body.cws30 ++ PRE_first_tail_x15_r0_body.ws30).all (Nat.ble 9) = true
kernel_rfl bodyCntM30 : countersOkB PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.s305 = true
kernel_rfl bodyHi30 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s306.ffi).next setupP.E = true
kernel_rfl bodyNhi30 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s306.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge30 : bridgeOf PRE_first_tail_x15_r0_body.s305.ffi = bridgeOf PRE_first_tail_x15_r0_body.s304.ffi
kernel_rfl bodyNN30 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s304.ffi).nnext PRE_first_tail_x15_r0_body.P30.NL = true
kernel_rfl bodyXn30 : Nat.ble (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s306.ffi).next = true
kernel_rfl bodyLo30 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s306.ffi).next = true
theorem bodyFacts30 : BodySiteFacts PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.s305 PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S304 PRE_first_tail_x15_r0_body.S305 PRE_first_tail_x15_r0_body.S306
    PRE_first_tail_x15_r0_body.ws30 PRE_first_tail_x15_r0_body.cws30 PRE_first_tail_x15_r0_body.nr30 PRE_first_tail_x15_r0_body.pl30 PRE_first_tail_x15_r0_body.cl30 2699954 1385 PRE_first_tail_x15_r0_body.kd30 PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.P30
    ⟨18802, 15878, 2698799, 1367⟩ ⟨18805, 15905, 2698805, 1385⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap30
  clean := bodyClean30
  cfix := PRE_first_tail_x15_r0_body.cfix30
  zpl := PRE_first_tail_x15_r0_body.zpl30
  zplnd := PRE_first_tail_x15_r0_body.zplnd30
  zn1 := PRE_first_tail_x15_r0_body.zn130
  zfirst := PRE_first_tail_x15_r0_body.zfirst30
  zscn := PRE_first_tail_x15_r0_body.zscn30
  zsmn := PRE_first_tail_x15_r0_body.zsmn30
  zgrow := PRE_first_tail_x15_r0_body.zgrow30
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab30
  zfresh := PRE_first_tail_x15_r0_body.zfresh30
  zcnd := PRE_first_tail_x15_r0_body.zcnd30
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi30
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt30
  zgP := PRE_first_tail_x15_r0_body.zg30_2665
  zkP := PRE_first_tail_x15_r0_body.zk30_2665
  zmP := PRE_first_tail_x15_r0_body.zm30_2665
  zgC := PRE_first_tail_x15_r0_body.zg30_2673467
  zkC := PRE_first_tail_x15_r0_body.zk30_2673467
  zmC := PRE_first_tail_x15_r0_body.zm30_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw30_2673472
  zwV := PRE_first_tail_x15_r0_body.zw30_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap30
  zclbd := PRE_first_tail_x15_r0_body.zclbd30
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap30 PRE_first_tail_x15_r0_body.stFoot30 PRE_first_tail_x15_r0_body.iso30 PRE_first_tail_x15_r0_body.zwr30
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP30
  csupp := PRE_first_tail_x15_r0_body.csupp30
  cbound := PRE_first_tail_x15_r0_body.cbound30
  zimg := PRE_first_tail_x15_r0_body.zimg30
  zctl := PRE_first_tail_x15_r0_body.zctl30
  zstack := PRE_first_tail_x15_r0_body.zstack30
  zjobs := PRE_first_tail_x15_r0_body.zjobs30
  zstores := PRE_first_tail_x15_r0_body.zstores30
  zroots := PRE_first_tail_x15_r0_body.zroots30
  znC := PRE_first_tail_x15_r0_body.znC30
  ctab := PRE_first_tail_x15_r0_body.ctab30
  zbin := PRE_first_tail_x15_r0_body.zbin30
  cbridge := PRE_first_tail_x15_r0_body.cbridge30
  sbridge := bodyBridge30
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj30
  cshiftR := fun h hNL => bodyCshift30 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN30
  raised := PRE_first_tail_x15_r0_body.raised30
  cbigs := PRE_first_tail_x15_r0_body.cbigs30
  cjcl := PRE_first_tail_x15_r0_body.cjcl30
  xnLe := Nat.le_of_ble_eq_true bodyXn30
  loLe := Nat.le_of_ble_eq_true bodyLo30
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB30
  cntM := bodyCntM30
  hiLe := Nat.le_of_ble_eq_true bodyHi30
  nhiLe := Nat.le_of_ble_eq_true bodyNhi30
  jsHeap := bodyJs30
  jsRoots := bodyJsRoots30
  jsNative := bodyJsNative30
  framesEmpty := bodyFramesEmpty30
  trailOld := by decide
  lowVars := bodyLow30

def bodyQs30 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs30 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr30.map fun r => nth? PRE_first_tail_x15_r0_body.st30.S5.tab r
kernel_rfl bodyResChk30 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs30 bodyQs30) = true
kernel_rfl bodyLq30 : bodyQs30.length = PRE_first_tail_x15_r0_body.cws30.length
kernel_rfl bodyNrLo30 : PRE_first_tail_x15_r0_body.nr30.all (Nat.ble PRE_first_tail_x15_r0_body.S304.tab.length) = true
kernel_rfl bodySub30 : (Oracles.PRE_first_tail_x15_r0_body.map_site30.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost30 : postSubB bodyM PRE_first_tail_x15_r0_body.ws30 PRE_first_tail_x15_r0_body.cws30 bodyQs30 = true
kernel_rfl bodyDrop30 : Nat.ble (14135 + (PRE_first_tail_x15_r0_body.s305.next - PRE_first_tail_x15_r0_body.s306.next)) 15284 = true
kernel_rfl bodyDropH30 : Nat.ble (225 + ((mlxOf PRE_first_tail_x15_r0_body.s305.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s306.ffi).next)) 250 = true
kernel_rfl bodyDropN30 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s305.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s306.ffi).nnext)) 0 = true
kernel_rfl bodyDv30 : bodyΘ.1.take 180 = bodyΘ.1.take 162 ++ PRE_first_tail_x15_r0_body.cws30
kernel_rfl bodyDe30 : bodyΘ.2.take 180 = bodyΘ.2.take 162 ++ PRE_first_tail_x15_r0_body.nr30.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st30.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 162) (bodyΘ.2.take 162)))
kernel_rfl bodyDl30 : (bodyΘ.1.take 162).length = (bodyΘ.2.take 162).length
kernel_rfl bodyDold30 : (bodyΘ.1.take 162).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws30).isNone && !PRE_first_tail_x15_r0_body.ws30.contains v) = true
kernel_rfl bodyDfree30 : (bodyΘ.2.take 180).all (fun e => (PRE_first_tail_x15_r0_body.cws30 ++ PRE_first_tail_x15_r0_body.ws30).all fun w => e.noVar w) = true

theorem bodyStep30 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14135, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.S304)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15284, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.S306) (11334 + 1) :=
  bodySite bodyFacts30.cfix bodyFacts30.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st30.S5.tab) (Es := bodyEs30) (qs := bodyQs30)
    (ok := PRE_first_tail_x15_r0_body.st30.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site30 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts30
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site30 r hr) hi (MapOk.sub hm (sub_of_all bodySub30)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk30 r hr) hi hm ho hq)
    bodyLq30 rfl bodyNrLo30 (postSub_sound bodyPost30)
    (Nat.le_of_ble_eq_true bodyDrop30) (by decide) (Nat.le_of_ble_eq_true bodyDropH30) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN30) (by decide)
    bodyDv30 bodyDe30 bodyDl30 bodyDold30 bodyDfree30 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
