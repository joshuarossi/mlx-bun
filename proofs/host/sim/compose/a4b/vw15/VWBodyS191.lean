import host.sim.compose.a4b.vw15.VWBodyJ191
import host.sim.compose.a4b.vw15.VWBodySite191
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

theorem bodyCshift191 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1839.tab.length PRE_first_tail_x15_r0_body.s1839.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P191.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P191 8218 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.s1841.ffi PRE_first_tail_x15_r0_body.s1840.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_191
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_191
  have hcl : SSt (· < 8218) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1839.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_191] <;> decide) PRE_first_tail_x15_r0_body.cnodesK191 PRE_first_tail_x15_r0_body.cobjsK191
      PRE_first_tail_x15_r0_body.citemsK191 PRE_first_tail_x15_r0_body.cbd191 PRE_first_tail_x15_r0_body.csst191
  exact PRE_first_tail_x15_r0_body.cshift191 bodyNcl191 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_191] at this; exact this)


kernel_rfl bodyFramesEmpty191 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1840 a).isEmpty) = true
kernel_rfl bodyJsRoots191 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1839.next) PRE_first_tail_x15_r0_body.s1841.trace PRE_first_tail_x15_r0_body.s1841 = true
kernel_rfl bodyJsNative191 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1841.ffi) = true
kernel_rfl bodyLow191 : (PRE_first_tail_x15_r0_body.cws191 ++ PRE_first_tail_x15_r0_body.ws191).all (Nat.ble 9) = true
kernel_rfl bodyCntM191 : countersOkB PRE_first_tail_x15_r0_body.s1839 PRE_first_tail_x15_r0_body.s1840 = true
kernel_rfl bodyHi191 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1841.ffi).next setupP.E = true
kernel_rfl bodyNhi191 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1841.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge191 : bridgeOf PRE_first_tail_x15_r0_body.s1840.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1839.ffi
kernel_rfl bodyNN191 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1839.ffi).nnext PRE_first_tail_x15_r0_body.P191.NL = true
kernel_rfl bodyXn191 : Nat.ble (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1841.ffi).next = true
kernel_rfl bodyLo191 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1841.ffi).next = true
theorem bodyFacts191 : BodySiteFacts PRE_first_tail_x15_r0_body.s1839 PRE_first_tail_x15_r0_body.s1840 PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1839 PRE_first_tail_x15_r0_body.S1840 PRE_first_tail_x15_r0_body.S1841
    PRE_first_tail_x15_r0_body.ws191 PRE_first_tail_x15_r0_body.cws191 PRE_first_tail_x15_r0_body.nr191 PRE_first_tail_x15_r0_body.pl191 PRE_first_tail_x15_r0_body.cl191 2824664 8218 PRE_first_tail_x15_r0_body.kd191 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.P191
    ⟨21957, 19051, 2824653, 8218⟩ ⟨21957, 19051, 2824654, 8218⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap191
  clean := bodyClean191
  cfix := PRE_first_tail_x15_r0_body.cfix191
  zpl := PRE_first_tail_x15_r0_body.zpl191
  zplnd := PRE_first_tail_x15_r0_body.zplnd191
  zn1 := PRE_first_tail_x15_r0_body.zn1191
  zfirst := PRE_first_tail_x15_r0_body.zfirst191
  zscn := PRE_first_tail_x15_r0_body.zscn191
  zsmn := PRE_first_tail_x15_r0_body.zsmn191
  zgrow := PRE_first_tail_x15_r0_body.zgrow191
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab191
  zfresh := PRE_first_tail_x15_r0_body.zfresh191
  zcnd := PRE_first_tail_x15_r0_body.zcnd191
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi191
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt191
  zgP := PRE_first_tail_x15_r0_body.zg191_2665
  zkP := PRE_first_tail_x15_r0_body.zk191_2665
  zmP := PRE_first_tail_x15_r0_body.zm191_2665
  zgC := PRE_first_tail_x15_r0_body.zg191_2673467
  zkC := PRE_first_tail_x15_r0_body.zk191_2673467
  zmC := PRE_first_tail_x15_r0_body.zm191_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw191_2673472
  zwV := PRE_first_tail_x15_r0_body.zw191_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap191
  zclbd := PRE_first_tail_x15_r0_body.zclbd191
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap191 PRE_first_tail_x15_r0_body.stFoot191 PRE_first_tail_x15_r0_body.iso191 PRE_first_tail_x15_r0_body.zwr191
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP191
  csupp := PRE_first_tail_x15_r0_body.csupp191
  cbound := PRE_first_tail_x15_r0_body.cbound191
  zimg := PRE_first_tail_x15_r0_body.zimg191
  zctl := PRE_first_tail_x15_r0_body.zctl191
  zstack := PRE_first_tail_x15_r0_body.zstack191
  zjobs := PRE_first_tail_x15_r0_body.zjobs191
  zstores := PRE_first_tail_x15_r0_body.zstores191
  zroots := PRE_first_tail_x15_r0_body.zroots191
  znC := PRE_first_tail_x15_r0_body.znC191
  ctab := PRE_first_tail_x15_r0_body.ctab191
  zbin := PRE_first_tail_x15_r0_body.zbin191
  cbridge := PRE_first_tail_x15_r0_body.cbridge191
  sbridge := bodyBridge191
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj191
  cshiftR := fun h hNL => bodyCshift191 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN191
  raised := PRE_first_tail_x15_r0_body.raised191
  cbigs := PRE_first_tail_x15_r0_body.cbigs191
  cjcl := PRE_first_tail_x15_r0_body.cjcl191
  xnLe := Nat.le_of_ble_eq_true bodyXn191
  loLe := Nat.le_of_ble_eq_true bodyLo191
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB191
  cntM := bodyCntM191
  hiLe := Nat.le_of_ble_eq_true bodyHi191
  nhiLe := Nat.le_of_ble_eq_true bodyNhi191
  jsHeap := bodyJs191
  jsRoots := bodyJsRoots191
  jsNative := bodyJsNative191
  framesEmpty := bodyFramesEmpty191
  trailOld := by decide
  lowVars := bodyLow191

def bodyQs191 : List (Option Q) := []
noncomputable def bodyEs191 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr191.map fun r => nth? PRE_first_tail_x15_r0_body.st191.S2.tab r
kernel_rfl bodyResChk191 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs191 bodyQs191) = true
kernel_rfl bodyLq191 : bodyQs191.length = PRE_first_tail_x15_r0_body.cws191.length
kernel_rfl bodyNrLo191 : PRE_first_tail_x15_r0_body.nr191.all (Nat.ble PRE_first_tail_x15_r0_body.S1839.tab.length) = true
kernel_rfl bodySub191 : (Oracles.PRE_first_tail_x15_r0_body.map_site191.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost191 : postSubB bodyM PRE_first_tail_x15_r0_body.ws191 PRE_first_tail_x15_r0_body.cws191 bodyQs191 = true
kernel_rfl bodyDrop191 : Nat.ble (65840 + (PRE_first_tail_x15_r0_body.s1840.next - PRE_first_tail_x15_r0_body.s1841.next)) 65850 = true
kernel_rfl bodyDropH191 : Nat.ble (1253 + ((mlxOf PRE_first_tail_x15_r0_body.s1840.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1841.ffi).next)) 1253 = true
kernel_rfl bodyDropN191 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1840.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1841.ffi).nnext)) 0 = true
kernel_rfl bodyDv191 : bodyΘ.1.take 1008 = bodyΘ.1.take 1008 ++ PRE_first_tail_x15_r0_body.cws191
kernel_rfl bodyDe191 : bodyΘ.2.take 1008 = bodyΘ.2.take 1008 ++ PRE_first_tail_x15_r0_body.nr191.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st191.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 1008) (bodyΘ.2.take 1008)))
kernel_rfl bodyDl191 : (bodyΘ.1.take 1008).length = (bodyΘ.2.take 1008).length
kernel_rfl bodyDold191 : (bodyΘ.1.take 1008).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws191).isNone && !PRE_first_tail_x15_r0_body.ws191.contains v) = true
kernel_rfl bodyDfree191 : (bodyΘ.2.take 1008).all (fun e => (PRE_first_tail_x15_r0_body.cws191 ++ PRE_first_tail_x15_r0_body.ws191).all fun w => e.noVar w) = true

theorem bodyStep191 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65840, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1839 PRE_first_tail_x15_r0_body.S1839)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65850, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.S1841) (98 + 1) :=
  bodySite bodyFacts191.cfix bodyFacts191.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st191.S2.tab) (Es := bodyEs191) (qs := bodyQs191)
    (ok := PRE_first_tail_x15_r0_body.st191.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site191 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts191
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site191 r hr) hi (MapOk.sub hm (sub_of_all bodySub191)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk191 r hr) hi hm ho hq)
    bodyLq191 rfl bodyNrLo191 (postSub_sound bodyPost191)
    (Nat.le_of_ble_eq_true bodyDrop191) (by decide) (Nat.le_of_ble_eq_true bodyDropH191) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN191) (by decide)
    bodyDv191 bodyDe191 bodyDl191 bodyDold191 bodyDfree191 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
