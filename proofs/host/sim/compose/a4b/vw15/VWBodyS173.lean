import host.sim.compose.a4b.vw15.VWBodyJ173
import host.sim.compose.a4b.vw15.VWBodySite173
import host.sim.compose.a4b.vw15.VWBodyOracles_43
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift173 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1667.tab.length PRE_first_tail_x15_r0_body.s1667.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P173.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P173 7450 PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.s1669.ffi PRE_first_tail_x15_r0_body.s1668.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_173
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_173
  have hcl : SSt (· < 7450) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1667.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_173] <;> decide) PRE_first_tail_x15_r0_body.cnodesK173 PRE_first_tail_x15_r0_body.cobjsK173
      PRE_first_tail_x15_r0_body.citemsK173 PRE_first_tail_x15_r0_body.cbd173 PRE_first_tail_x15_r0_body.csst173
  exact PRE_first_tail_x15_r0_body.cshift173 bodyNcl173 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_173] at this; exact this)


kernel_rfl bodyFramesEmpty173 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1668 a).isEmpty) = true
kernel_rfl bodyJsRoots173 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1667.next) PRE_first_tail_x15_r0_body.s1669.trace PRE_first_tail_x15_r0_body.s1669 = true
kernel_rfl bodyJsNative173 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1669.ffi) = true
kernel_rfl bodyLow173 : (PRE_first_tail_x15_r0_body.cws173 ++ PRE_first_tail_x15_r0_body.ws173).all (Nat.ble 9) = true
kernel_rfl bodyCntM173 : countersOkB PRE_first_tail_x15_r0_body.s1667 PRE_first_tail_x15_r0_body.s1668 = true
kernel_rfl bodyHi173 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1669.ffi).next setupP.E = true
kernel_rfl bodyNhi173 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1669.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge173 : bridgeOf PRE_first_tail_x15_r0_body.s1668.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1667.ffi
kernel_rfl bodyNN173 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1667.ffi).nnext PRE_first_tail_x15_r0_body.P173.NL = true
kernel_rfl bodyXn173 : Nat.ble (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1669.ffi).next = true
kernel_rfl bodyLo173 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1669.ffi).next = true
theorem bodyFacts173 : BodySiteFacts PRE_first_tail_x15_r0_body.s1667 PRE_first_tail_x15_r0_body.s1668 PRE_first_tail_x15_r0_body.s1669 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1667 PRE_first_tail_x15_r0_body.S1668 PRE_first_tail_x15_r0_body.S1669
    PRE_first_tail_x15_r0_body.ws173 PRE_first_tail_x15_r0_body.cws173 PRE_first_tail_x15_r0_body.nr173 PRE_first_tail_x15_r0_body.pl173 PRE_first_tail_x15_r0_body.cl173 2810363 7450 PRE_first_tail_x15_r0_body.kd173 PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.P173
    ⟨21600, 18703, 2810343, 7450⟩ ⟨21600, 18703, 2810344, 7450⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap173
  clean := bodyClean173
  cfix := PRE_first_tail_x15_r0_body.cfix173
  zpl := PRE_first_tail_x15_r0_body.zpl173
  zplnd := PRE_first_tail_x15_r0_body.zplnd173
  zn1 := PRE_first_tail_x15_r0_body.zn1173
  zfirst := PRE_first_tail_x15_r0_body.zfirst173
  zscn := PRE_first_tail_x15_r0_body.zscn173
  zsmn := PRE_first_tail_x15_r0_body.zsmn173
  zgrow := PRE_first_tail_x15_r0_body.zgrow173
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab173
  zfresh := PRE_first_tail_x15_r0_body.zfresh173
  zcnd := PRE_first_tail_x15_r0_body.zcnd173
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi173
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt173
  zgP := PRE_first_tail_x15_r0_body.zg173_2665
  zkP := PRE_first_tail_x15_r0_body.zk173_2665
  zmP := PRE_first_tail_x15_r0_body.zm173_2665
  zgC := PRE_first_tail_x15_r0_body.zg173_2673467
  zkC := PRE_first_tail_x15_r0_body.zk173_2673467
  zmC := PRE_first_tail_x15_r0_body.zm173_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw173_2673472
  zwV := PRE_first_tail_x15_r0_body.zw173_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap173
  zclbd := PRE_first_tail_x15_r0_body.zclbd173
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap173 PRE_first_tail_x15_r0_body.stFoot173 PRE_first_tail_x15_r0_body.iso173 PRE_first_tail_x15_r0_body.zwr173
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP173
  csupp := PRE_first_tail_x15_r0_body.csupp173
  cbound := PRE_first_tail_x15_r0_body.cbound173
  zimg := PRE_first_tail_x15_r0_body.zimg173
  zctl := PRE_first_tail_x15_r0_body.zctl173
  zstack := PRE_first_tail_x15_r0_body.zstack173
  zjobs := PRE_first_tail_x15_r0_body.zjobs173
  zstores := PRE_first_tail_x15_r0_body.zstores173
  zroots := PRE_first_tail_x15_r0_body.zroots173
  znC := PRE_first_tail_x15_r0_body.znC173
  ctab := PRE_first_tail_x15_r0_body.ctab173
  zbin := PRE_first_tail_x15_r0_body.zbin173
  cbridge := PRE_first_tail_x15_r0_body.cbridge173
  sbridge := bodyBridge173
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj173
  cshiftR := fun h hNL => bodyCshift173 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN173
  raised := PRE_first_tail_x15_r0_body.raised173
  cbigs := PRE_first_tail_x15_r0_body.cbigs173
  cjcl := PRE_first_tail_x15_r0_body.cjcl173
  xnLe := Nat.le_of_ble_eq_true bodyXn173
  loLe := Nat.le_of_ble_eq_true bodyLo173
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB173
  cntM := bodyCntM173
  hiLe := Nat.le_of_ble_eq_true bodyHi173
  nhiLe := Nat.le_of_ble_eq_true bodyNhi173
  jsHeap := bodyJs173
  jsRoots := bodyJsRoots173
  jsNative := bodyJsNative173
  framesEmpty := bodyFramesEmpty173
  trailOld := by decide
  lowVars := bodyLow173

def bodyQs173 : List (Option Q) := []
noncomputable def bodyEs173 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr173.map fun r => nth? PRE_first_tail_x15_r0_body.st173.S2.tab r
kernel_rfl bodyResChk173 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs173 bodyQs173) = true
kernel_rfl bodyLq173 : bodyQs173.length = PRE_first_tail_x15_r0_body.cws173.length
kernel_rfl bodyNrLo173 : PRE_first_tail_x15_r0_body.nr173.all (Nat.ble PRE_first_tail_x15_r0_body.S1667.tab.length) = true
kernel_rfl bodySub173 : (Oracles.PRE_first_tail_x15_r0_body.map_site173.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost173 : postSubB bodyM PRE_first_tail_x15_r0_body.ws173 PRE_first_tail_x15_r0_body.cws173 bodyQs173 = true
kernel_rfl bodyDrop173 : Nat.ble (60427 + (PRE_first_tail_x15_r0_body.s1668.next - PRE_first_tail_x15_r0_body.s1669.next)) 60446 = true
kernel_rfl bodyDropH173 : Nat.ble (1149 + ((mlxOf PRE_first_tail_x15_r0_body.s1668.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1669.ffi).next)) 1149 = true
kernel_rfl bodyDropN173 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1668.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1669.ffi).nnext)) 0 = true
kernel_rfl bodyDv173 : bodyΘ.1.take 918 = bodyΘ.1.take 918 ++ PRE_first_tail_x15_r0_body.cws173
kernel_rfl bodyDe173 : bodyΘ.2.take 918 = bodyΘ.2.take 918 ++ PRE_first_tail_x15_r0_body.nr173.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st173.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 918) (bodyΘ.2.take 918)))
kernel_rfl bodyDl173 : (bodyΘ.1.take 918).length = (bodyΘ.2.take 918).length
kernel_rfl bodyDold173 : (bodyΘ.1.take 918).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws173).isNone && !PRE_first_tail_x15_r0_body.ws173.contains v) = true
kernel_rfl bodyDfree173 : (bodyΘ.2.take 918).all (fun e => (PRE_first_tail_x15_r0_body.cws173 ++ PRE_first_tail_x15_r0_body.ws173).all fun w => e.noVar w) = true

theorem bodyStep173 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨60427, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1667 PRE_first_tail_x15_r0_body.S1667)
      (bodyCut NB T tk π i x0 bodyΘ ⟨60446, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1669 PRE_first_tail_x15_r0_body.S1669) (206 + 1) :=
  bodySite bodyFacts173.cfix bodyFacts173.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st173.S2.tab) (Es := bodyEs173) (qs := bodyQs173)
    (ok := PRE_first_tail_x15_r0_body.st173.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site173 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts173
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site173 r hr) hi (MapOk.sub hm (sub_of_all bodySub173)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk173 r hr) hi hm ho hq)
    bodyLq173 rfl bodyNrLo173 (postSub_sound bodyPost173)
    (Nat.le_of_ble_eq_true bodyDrop173) (by decide) (Nat.le_of_ble_eq_true bodyDropH173) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN173) (by decide)
    bodyDv173 bodyDe173 bodyDl173 bodyDold173 bodyDfree173 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
