import host.sim.compose.a4b.vw15.VWBodyJ32
import host.sim.compose.a4b.vw15.VWBodySite32
import host.sim.compose.a4b.vw15.VWBodyOracles_8
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift32 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S316.tab.length PRE_first_tail_x15_r0_body.s316.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P32.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P32 1423 PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.s318.ffi PRE_first_tail_x15_r0_body.s317.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_32
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_32
  have hcl : SSt (· < 1423) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S316.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_32] <;> decide) PRE_first_tail_x15_r0_body.cnodesK32 PRE_first_tail_x15_r0_body.cobjsK32
      PRE_first_tail_x15_r0_body.citemsK32 PRE_first_tail_x15_r0_body.cbd32 PRE_first_tail_x15_r0_body.csst32
  exact PRE_first_tail_x15_r0_body.cshift32 bodyNcl32 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_32] at this; exact this)


kernel_rfl bodyFramesEmpty32 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s317 a).isEmpty) = true
kernel_rfl bodyJsRoots32 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s316.next) PRE_first_tail_x15_r0_body.s318.trace PRE_first_tail_x15_r0_body.s318 = true
kernel_rfl bodyJsNative32 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s318.ffi) = true
kernel_rfl bodyLow32 : (PRE_first_tail_x15_r0_body.cws32 ++ PRE_first_tail_x15_r0_body.ws32).all (Nat.ble 9) = true
kernel_rfl bodyCntM32 : countersOkB PRE_first_tail_x15_r0_body.s316 PRE_first_tail_x15_r0_body.s317 = true
kernel_rfl bodyHi32 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s318.ffi).next setupP.E = true
kernel_rfl bodyNhi32 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s318.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge32 : bridgeOf PRE_first_tail_x15_r0_body.s317.ffi = bridgeOf PRE_first_tail_x15_r0_body.s316.ffi
kernel_rfl bodyNN32 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s316.ffi).nnext PRE_first_tail_x15_r0_body.P32.NL = true
kernel_rfl bodyXn32 : Nat.ble (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s318.ffi).next = true
kernel_rfl bodyLo32 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s318.ffi).next = true
theorem bodyFacts32 : BodySiteFacts PRE_first_tail_x15_r0_body.s316 PRE_first_tail_x15_r0_body.s317 PRE_first_tail_x15_r0_body.s318 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S316 PRE_first_tail_x15_r0_body.S317 PRE_first_tail_x15_r0_body.S318
    PRE_first_tail_x15_r0_body.ws32 PRE_first_tail_x15_r0_body.cws32 PRE_first_tail_x15_r0_body.nr32 PRE_first_tail_x15_r0_body.pl32 PRE_first_tail_x15_r0_body.cl32 2699594 1423 PRE_first_tail_x15_r0_body.kd32 PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.P32
    ⟨18825, 15922, 2699583, 1423⟩ ⟨18825, 15922, 2699584, 1423⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap32
  clean := bodyClean32
  cfix := PRE_first_tail_x15_r0_body.cfix32
  zpl := PRE_first_tail_x15_r0_body.zpl32
  zplnd := PRE_first_tail_x15_r0_body.zplnd32
  zn1 := PRE_first_tail_x15_r0_body.zn132
  zfirst := PRE_first_tail_x15_r0_body.zfirst32
  zscn := PRE_first_tail_x15_r0_body.zscn32
  zsmn := PRE_first_tail_x15_r0_body.zsmn32
  zgrow := PRE_first_tail_x15_r0_body.zgrow32
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab32
  zfresh := PRE_first_tail_x15_r0_body.zfresh32
  zcnd := PRE_first_tail_x15_r0_body.zcnd32
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi32
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt32
  zgP := PRE_first_tail_x15_r0_body.zg32_2665
  zkP := PRE_first_tail_x15_r0_body.zk32_2665
  zmP := PRE_first_tail_x15_r0_body.zm32_2665
  zgC := PRE_first_tail_x15_r0_body.zg32_2673467
  zkC := PRE_first_tail_x15_r0_body.zk32_2673467
  zmC := PRE_first_tail_x15_r0_body.zm32_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw32_2673472
  zwV := PRE_first_tail_x15_r0_body.zw32_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap32
  zclbd := PRE_first_tail_x15_r0_body.zclbd32
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap32 PRE_first_tail_x15_r0_body.stFoot32 PRE_first_tail_x15_r0_body.iso32 PRE_first_tail_x15_r0_body.zwr32
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP32
  csupp := PRE_first_tail_x15_r0_body.csupp32
  cbound := PRE_first_tail_x15_r0_body.cbound32
  zimg := PRE_first_tail_x15_r0_body.zimg32
  zctl := PRE_first_tail_x15_r0_body.zctl32
  zstack := PRE_first_tail_x15_r0_body.zstack32
  zjobs := PRE_first_tail_x15_r0_body.zjobs32
  zstores := PRE_first_tail_x15_r0_body.zstores32
  zroots := PRE_first_tail_x15_r0_body.zroots32
  znC := PRE_first_tail_x15_r0_body.znC32
  ctab := PRE_first_tail_x15_r0_body.ctab32
  zbin := PRE_first_tail_x15_r0_body.zbin32
  cbridge := PRE_first_tail_x15_r0_body.cbridge32
  sbridge := bodyBridge32
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj32
  cshiftR := fun h hNL => bodyCshift32 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN32
  raised := PRE_first_tail_x15_r0_body.raised32
  cbigs := PRE_first_tail_x15_r0_body.cbigs32
  cjcl := PRE_first_tail_x15_r0_body.cjcl32
  xnLe := Nat.le_of_ble_eq_true bodyXn32
  loLe := Nat.le_of_ble_eq_true bodyLo32
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB32
  cntM := bodyCntM32
  hiLe := Nat.le_of_ble_eq_true bodyHi32
  nhiLe := Nat.le_of_ble_eq_true bodyNhi32
  jsHeap := bodyJs32
  jsRoots := bodyJsRoots32
  jsNative := bodyJsNative32
  framesEmpty := bodyFramesEmpty32
  trailOld := by decide
  lowVars := bodyLow32

def bodyQs32 : List (Option Q) := []
noncomputable def bodyEs32 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr32.map fun r => nth? PRE_first_tail_x15_r0_body.st32.S2.tab r
kernel_rfl bodyResChk32 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs32 bodyQs32) = true
kernel_rfl bodyLq32 : bodyQs32.length = PRE_first_tail_x15_r0_body.cws32.length
kernel_rfl bodyNrLo32 : PRE_first_tail_x15_r0_body.nr32.all (Nat.ble PRE_first_tail_x15_r0_body.S316.tab.length) = true
kernel_rfl bodySub32 : (Oracles.PRE_first_tail_x15_r0_body.map_site32.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost32 : postSubB bodyM PRE_first_tail_x15_r0_body.ws32 PRE_first_tail_x15_r0_body.cws32 bodyQs32 = true
kernel_rfl bodyDrop32 : Nat.ble (15286 + (PRE_first_tail_x15_r0_body.s317.next - PRE_first_tail_x15_r0_body.s318.next)) 15296 = true
kernel_rfl bodyDropH32 : Nat.ble (250 + ((mlxOf PRE_first_tail_x15_r0_body.s317.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s318.ffi).next)) 250 = true
kernel_rfl bodyDropN32 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s317.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s318.ffi).nnext)) 0 = true
kernel_rfl bodyDv32 : bodyΘ.1.take 180 = bodyΘ.1.take 180 ++ PRE_first_tail_x15_r0_body.cws32
kernel_rfl bodyDe32 : bodyΘ.2.take 180 = bodyΘ.2.take 180 ++ PRE_first_tail_x15_r0_body.nr32.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st32.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 180) (bodyΘ.2.take 180)))
kernel_rfl bodyDl32 : (bodyΘ.1.take 180).length = (bodyΘ.2.take 180).length
kernel_rfl bodyDold32 : (bodyΘ.1.take 180).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws32).isNone && !PRE_first_tail_x15_r0_body.ws32.contains v) = true
kernel_rfl bodyDfree32 : (bodyΘ.2.take 180).all (fun e => (PRE_first_tail_x15_r0_body.cws32 ++ PRE_first_tail_x15_r0_body.ws32).all fun w => e.noVar w) = true

theorem bodyStep32 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15286, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s316 PRE_first_tail_x15_r0_body.S316)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15296, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s318 PRE_first_tail_x15_r0_body.S318) (98 + 1) :=
  bodySite bodyFacts32.cfix bodyFacts32.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st32.S2.tab) (Es := bodyEs32) (qs := bodyQs32)
    (ok := PRE_first_tail_x15_r0_body.st32.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site32 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts32
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site32 r hr) hi (MapOk.sub hm (sub_of_all bodySub32)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk32 r hr) hi hm ho hq)
    bodyLq32 rfl bodyNrLo32 (postSub_sound bodyPost32)
    (Nat.le_of_ble_eq_true bodyDrop32) (by decide) (Nat.le_of_ble_eq_true bodyDropH32) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN32) (by decide)
    bodyDv32 bodyDe32 bodyDl32 bodyDold32 bodyDfree32 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
