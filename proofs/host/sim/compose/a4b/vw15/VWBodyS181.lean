import host.sim.compose.a4b.vw15.VWBodyJ181
import host.sim.compose.a4b.vw15.VWBodySite181
import host.sim.compose.a4b.vw15.VWBodyOracles_45
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift181 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1749.tab.length PRE_first_tail_x15_r0_body.s1749.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P181.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P181 7817 PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.s1751.ffi PRE_first_tail_x15_r0_body.s1750.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_181
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_181
  have hcl : SSt (· < 7817) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1749.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_181] <;> decide) PRE_first_tail_x15_r0_body.cnodesK181 PRE_first_tail_x15_r0_body.cobjsK181
      PRE_first_tail_x15_r0_body.citemsK181 PRE_first_tail_x15_r0_body.cbd181 PRE_first_tail_x15_r0_body.csst181
  exact PRE_first_tail_x15_r0_body.cshift181 bodyNcl181 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_181] at this; exact this)


kernel_rfl bodyFramesEmpty181 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1750 a).isEmpty) = true
kernel_rfl bodyJsRoots181 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1749.next) PRE_first_tail_x15_r0_body.s1751.trace PRE_first_tail_x15_r0_body.s1751 = true
kernel_rfl bodyJsNative181 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1751.ffi) = true
kernel_rfl bodyLow181 : (PRE_first_tail_x15_r0_body.cws181 ++ PRE_first_tail_x15_r0_body.ws181).all (Nat.ble 9) = true
kernel_rfl bodyCntM181 : countersOkB PRE_first_tail_x15_r0_body.s1749 PRE_first_tail_x15_r0_body.s1750 = true
kernel_rfl bodyHi181 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1751.ffi).next setupP.E = true
kernel_rfl bodyNhi181 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1751.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge181 : bridgeOf PRE_first_tail_x15_r0_body.s1750.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1749.ffi
kernel_rfl bodyNN181 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1749.ffi).nnext PRE_first_tail_x15_r0_body.P181.NL = true
kernel_rfl bodyXn181 : Nat.ble (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1751.ffi).next = true
kernel_rfl bodyLo181 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1751.ffi).next = true
theorem bodyFacts181 : BodySiteFacts PRE_first_tail_x15_r0_body.s1749 PRE_first_tail_x15_r0_body.s1750 PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1749 PRE_first_tail_x15_r0_body.S1750 PRE_first_tail_x15_r0_body.S1751
    PRE_first_tail_x15_r0_body.ws181 PRE_first_tail_x15_r0_body.cws181 PRE_first_tail_x15_r0_body.nr181 PRE_first_tail_x15_r0_body.pl181 PRE_first_tail_x15_r0_body.cl181 2817225 7817 PRE_first_tail_x15_r0_body.kd181 PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.P181
    ⟨21772, 18873, 2817223, 7817⟩ ⟨21772, 18873, 2817223, 7817⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap181
  clean := bodyClean181
  cfix := PRE_first_tail_x15_r0_body.cfix181
  zpl := PRE_first_tail_x15_r0_body.zpl181
  zplnd := PRE_first_tail_x15_r0_body.zplnd181
  zn1 := PRE_first_tail_x15_r0_body.zn1181
  zfirst := PRE_first_tail_x15_r0_body.zfirst181
  zscn := PRE_first_tail_x15_r0_body.zscn181
  zsmn := PRE_first_tail_x15_r0_body.zsmn181
  zgrow := PRE_first_tail_x15_r0_body.zgrow181
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab181
  zfresh := PRE_first_tail_x15_r0_body.zfresh181
  zcnd := PRE_first_tail_x15_r0_body.zcnd181
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi181
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt181
  zgP := PRE_first_tail_x15_r0_body.zg181_2665
  zkP := PRE_first_tail_x15_r0_body.zk181_2665
  zmP := PRE_first_tail_x15_r0_body.zm181_2665
  zgC := PRE_first_tail_x15_r0_body.zg181_2673467
  zkC := PRE_first_tail_x15_r0_body.zk181_2673467
  zmC := PRE_first_tail_x15_r0_body.zm181_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw181_2673472
  zwV := PRE_first_tail_x15_r0_body.zw181_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap181
  zclbd := PRE_first_tail_x15_r0_body.zclbd181
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap181 PRE_first_tail_x15_r0_body.stFoot181 PRE_first_tail_x15_r0_body.iso181 PRE_first_tail_x15_r0_body.zwr181
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP181
  csupp := PRE_first_tail_x15_r0_body.csupp181
  cbound := PRE_first_tail_x15_r0_body.cbound181
  zimg := PRE_first_tail_x15_r0_body.zimg181
  zctl := PRE_first_tail_x15_r0_body.zctl181
  zstack := PRE_first_tail_x15_r0_body.zstack181
  zjobs := PRE_first_tail_x15_r0_body.zjobs181
  zstores := PRE_first_tail_x15_r0_body.zstores181
  zroots := PRE_first_tail_x15_r0_body.zroots181
  znC := PRE_first_tail_x15_r0_body.znC181
  ctab := PRE_first_tail_x15_r0_body.ctab181
  zbin := PRE_first_tail_x15_r0_body.zbin181
  cbridge := PRE_first_tail_x15_r0_body.cbridge181
  sbridge := bodyBridge181
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj181
  cshiftR := fun h hNL => bodyCshift181 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN181
  raised := PRE_first_tail_x15_r0_body.raised181
  cbigs := PRE_first_tail_x15_r0_body.cbigs181
  cjcl := PRE_first_tail_x15_r0_body.cjcl181
  xnLe := Nat.le_of_ble_eq_true bodyXn181
  loLe := Nat.le_of_ble_eq_true bodyLo181
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB181
  cntM := bodyCntM181
  hiLe := Nat.le_of_ble_eq_true bodyHi181
  nhiLe := Nat.le_of_ble_eq_true bodyNhi181
  jsHeap := bodyJs181
  jsRoots := bodyJsRoots181
  jsNative := bodyJsNative181
  framesEmpty := bodyFramesEmpty181
  trailOld := by decide
  lowVars := bodyLow181

def bodyQs181 : List (Option Q) := []
noncomputable def bodyEs181 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr181.map fun r => nth? PRE_first_tail_x15_r0_body.st181.S2.tab r
kernel_rfl bodyResChk181 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs181 bodyQs181) = true
kernel_rfl bodyLq181 : bodyQs181.length = PRE_first_tail_x15_r0_body.cws181.length
kernel_rfl bodyNrLo181 : PRE_first_tail_x15_r0_body.nr181.all (Nat.ble PRE_first_tail_x15_r0_body.S1749.tab.length) = true
kernel_rfl bodySub181 : (Oracles.PRE_first_tail_x15_r0_body.map_site181.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost181 : postSubB bodyM PRE_first_tail_x15_r0_body.ws181 PRE_first_tail_x15_r0_body.cws181 bodyQs181 = true
kernel_rfl bodyDrop181 : Nat.ble (63136 + (PRE_first_tail_x15_r0_body.s1750.next - PRE_first_tail_x15_r0_body.s1751.next)) 63138 = true
kernel_rfl bodyDropH181 : Nat.ble (1201 + ((mlxOf PRE_first_tail_x15_r0_body.s1750.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1751.ffi).next)) 1201 = true
kernel_rfl bodyDropN181 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1750.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1751.ffi).nnext)) 0 = true
kernel_rfl bodyDv181 : bodyΘ.1.take 963 = bodyΘ.1.take 963 ++ PRE_first_tail_x15_r0_body.cws181
kernel_rfl bodyDe181 : bodyΘ.2.take 963 = bodyΘ.2.take 963 ++ PRE_first_tail_x15_r0_body.nr181.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st181.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 963) (bodyΘ.2.take 963)))
kernel_rfl bodyDl181 : (bodyΘ.1.take 963).length = (bodyΘ.2.take 963).length
kernel_rfl bodyDold181 : (bodyΘ.1.take 963).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws181).isNone && !PRE_first_tail_x15_r0_body.ws181.contains v) = true
kernel_rfl bodyDfree181 : (bodyΘ.2.take 963).all (fun e => (PRE_first_tail_x15_r0_body.cws181 ++ PRE_first_tail_x15_r0_body.ws181).all fun w => e.noVar w) = true

theorem bodyStep181 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨63136, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1749 PRE_first_tail_x15_r0_body.S1749)
      (bodyCut NB T tk π i x0 bodyΘ ⟨63138, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.S1751) (27 + 1) :=
  bodySite bodyFacts181.cfix bodyFacts181.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st181.S2.tab) (Es := bodyEs181) (qs := bodyQs181)
    (ok := PRE_first_tail_x15_r0_body.st181.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site181 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts181
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site181 r hr) hi (MapOk.sub hm (sub_of_all bodySub181)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk181 r hr) hi hm ho hq)
    bodyLq181 rfl bodyNrLo181 (postSub_sound bodyPost181)
    (Nat.le_of_ble_eq_true bodyDrop181) (by decide) (Nat.le_of_ble_eq_true bodyDropH181) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN181) (by decide)
    bodyDv181 bodyDe181 bodyDl181 bodyDold181 bodyDfree181 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
