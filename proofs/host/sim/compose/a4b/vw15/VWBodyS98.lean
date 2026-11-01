import host.sim.compose.a4b.vw15.VWBodyJ98
import host.sim.compose.a4b.vw15.VWBodySite98
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

theorem bodyCshift98 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S948.tab.length PRE_first_tail_x15_r0_body.s948.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P98.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P98 4243 PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.s950.ffi PRE_first_tail_x15_r0_body.s949.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_98
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_98
  have hcl : SSt (· < 4243) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s950.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S948.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_98] <;> decide) PRE_first_tail_x15_r0_body.cnodesK98 PRE_first_tail_x15_r0_body.cobjsK98
      PRE_first_tail_x15_r0_body.citemsK98 PRE_first_tail_x15_r0_body.cbd98 PRE_first_tail_x15_r0_body.csst98
  exact PRE_first_tail_x15_r0_body.cshift98 bodyNcl98 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_98] at this; exact this)


kernel_rfl bodyFramesEmpty98 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s949 a).isEmpty) = true
kernel_rfl bodyJsRoots98 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s948.next) PRE_first_tail_x15_r0_body.s950.trace PRE_first_tail_x15_r0_body.s950 = true
kernel_rfl bodyJsNative98 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s950.ffi) = true
kernel_rfl bodyLow98 : (PRE_first_tail_x15_r0_body.cws98 ++ PRE_first_tail_x15_r0_body.ws98).all (Nat.ble 9) = true
kernel_rfl bodyCntM98 : countersOkB PRE_first_tail_x15_r0_body.s948 PRE_first_tail_x15_r0_body.s949 = true
kernel_rfl bodyHi98 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s950.ffi).next setupP.E = true
kernel_rfl bodyNhi98 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s950.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge98 : bridgeOf PRE_first_tail_x15_r0_body.s949.ffi = bridgeOf PRE_first_tail_x15_r0_body.s948.ffi
kernel_rfl bodyNN98 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s948.ffi).nnext PRE_first_tail_x15_r0_body.P98.NL = true
kernel_rfl bodyXn98 : Nat.ble (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s950.ffi).next = true
kernel_rfl bodyLo98 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s950.ffi).next = true
theorem bodyFacts98 : BodySiteFacts PRE_first_tail_x15_r0_body.s948 PRE_first_tail_x15_r0_body.s949 PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S948 PRE_first_tail_x15_r0_body.S949 PRE_first_tail_x15_r0_body.S950
    PRE_first_tail_x15_r0_body.ws98 PRE_first_tail_x15_r0_body.cws98 PRE_first_tail_x15_r0_body.nr98 PRE_first_tail_x15_r0_body.pl98 PRE_first_tail_x15_r0_body.cl98 2751595 4243 PRE_first_tail_x15_r0_body.kd98 PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.P98
    ⟨20127, 17218, 2751575, 4243⟩ ⟨20127, 17218, 2751576, 4243⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap98
  clean := bodyClean98
  cfix := PRE_first_tail_x15_r0_body.cfix98
  zpl := PRE_first_tail_x15_r0_body.zpl98
  zplnd := PRE_first_tail_x15_r0_body.zplnd98
  zn1 := PRE_first_tail_x15_r0_body.zn198
  zfirst := PRE_first_tail_x15_r0_body.zfirst98
  zscn := PRE_first_tail_x15_r0_body.zscn98
  zsmn := PRE_first_tail_x15_r0_body.zsmn98
  zgrow := PRE_first_tail_x15_r0_body.zgrow98
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab98
  zfresh := PRE_first_tail_x15_r0_body.zfresh98
  zcnd := PRE_first_tail_x15_r0_body.zcnd98
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi98
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt98
  zgP := PRE_first_tail_x15_r0_body.zg98_2665
  zkP := PRE_first_tail_x15_r0_body.zk98_2665
  zmP := PRE_first_tail_x15_r0_body.zm98_2665
  zgC := PRE_first_tail_x15_r0_body.zg98_2673467
  zkC := PRE_first_tail_x15_r0_body.zk98_2673467
  zmC := PRE_first_tail_x15_r0_body.zm98_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw98_2673472
  zwV := PRE_first_tail_x15_r0_body.zw98_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap98
  zclbd := PRE_first_tail_x15_r0_body.zclbd98
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap98 PRE_first_tail_x15_r0_body.stFoot98 PRE_first_tail_x15_r0_body.iso98 PRE_first_tail_x15_r0_body.zwr98
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP98
  csupp := PRE_first_tail_x15_r0_body.csupp98
  cbound := PRE_first_tail_x15_r0_body.cbound98
  zimg := PRE_first_tail_x15_r0_body.zimg98
  zctl := PRE_first_tail_x15_r0_body.zctl98
  zstack := PRE_first_tail_x15_r0_body.zstack98
  zjobs := PRE_first_tail_x15_r0_body.zjobs98
  zstores := PRE_first_tail_x15_r0_body.zstores98
  zroots := PRE_first_tail_x15_r0_body.zroots98
  znC := PRE_first_tail_x15_r0_body.znC98
  ctab := PRE_first_tail_x15_r0_body.ctab98
  zbin := PRE_first_tail_x15_r0_body.zbin98
  cbridge := PRE_first_tail_x15_r0_body.cbridge98
  sbridge := bodyBridge98
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj98
  cshiftR := fun h hNL => bodyCshift98 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN98
  raised := PRE_first_tail_x15_r0_body.raised98
  cbigs := PRE_first_tail_x15_r0_body.cbigs98
  cjcl := PRE_first_tail_x15_r0_body.cjcl98
  xnLe := Nat.le_of_ble_eq_true bodyXn98
  loLe := Nat.le_of_ble_eq_true bodyLo98
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB98
  cntM := bodyCntM98
  hiLe := Nat.le_of_ble_eq_true bodyHi98
  nhiLe := Nat.le_of_ble_eq_true bodyNhi98
  jsHeap := bodyJs98
  jsRoots := bodyJsRoots98
  jsNative := bodyJsNative98
  framesEmpty := bodyFramesEmpty98
  trailOld := by decide
  lowVars := bodyLow98

def bodyQs98 : List (Option Q) := []
noncomputable def bodyEs98 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr98.map fun r => nth? PRE_first_tail_x15_r0_body.st98.S2.tab r
kernel_rfl bodyResChk98 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs98 bodyQs98) = true
kernel_rfl bodyLq98 : bodyQs98.length = PRE_first_tail_x15_r0_body.cws98.length
kernel_rfl bodyNrLo98 : PRE_first_tail_x15_r0_body.nr98.all (Nat.ble PRE_first_tail_x15_r0_body.S948.tab.length) = true
kernel_rfl bodySub98 : (Oracles.PRE_first_tail_x15_r0_body.map_site98.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost98 : postSubB bodyM PRE_first_tail_x15_r0_body.ws98 PRE_first_tail_x15_r0_body.cws98 bodyQs98 = true
kernel_rfl bodyDrop98 : Nat.ble (36106 + (PRE_first_tail_x15_r0_body.s949.next - PRE_first_tail_x15_r0_body.s950.next)) 36125 = true
kernel_rfl bodyDropH98 : Nat.ble (662 + ((mlxOf PRE_first_tail_x15_r0_body.s949.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s950.ffi).next)) 662 = true
kernel_rfl bodyDropN98 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s949.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s950.ffi).nnext)) 0 = true
kernel_rfl bodyDv98 : bodyΘ.1.take 522 = bodyΘ.1.take 522 ++ PRE_first_tail_x15_r0_body.cws98
kernel_rfl bodyDe98 : bodyΘ.2.take 522 = bodyΘ.2.take 522 ++ PRE_first_tail_x15_r0_body.nr98.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st98.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 522) (bodyΘ.2.take 522)))
kernel_rfl bodyDl98 : (bodyΘ.1.take 522).length = (bodyΘ.2.take 522).length
kernel_rfl bodyDold98 : (bodyΘ.1.take 522).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws98).isNone && !PRE_first_tail_x15_r0_body.ws98.contains v) = true
kernel_rfl bodyDfree98 : (bodyΘ.2.take 522).all (fun e => (PRE_first_tail_x15_r0_body.cws98 ++ PRE_first_tail_x15_r0_body.ws98).all fun w => e.noVar w) = true

theorem bodyStep98 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨36106, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s948 PRE_first_tail_x15_r0_body.S948)
      (bodyCut NB T tk π i x0 bodyΘ ⟨36125, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.S950) (206 + 1) :=
  bodySite bodyFacts98.cfix bodyFacts98.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st98.S2.tab) (Es := bodyEs98) (qs := bodyQs98)
    (ok := PRE_first_tail_x15_r0_body.st98.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site98 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts98
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site98 r hr) hi (MapOk.sub hm (sub_of_all bodySub98)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk98 r hr) hi hm ho hq)
    bodyLq98 rfl bodyNrLo98 (postSub_sound bodyPost98)
    (Nat.le_of_ble_eq_true bodyDrop98) (by decide) (Nat.le_of_ble_eq_true bodyDropH98) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN98) (by decide)
    bodyDv98 bodyDe98 bodyDl98 bodyDold98 bodyDfree98 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
