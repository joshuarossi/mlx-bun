import host.sim.compose.a4b.vw15.VWBodyJ64
import host.sim.compose.a4b.vw15.VWBodySite64
import host.sim.compose.a4b.vw15.VWBodyOracles_16
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift64 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S628.tab.length PRE_first_tail_x15_r0_body.s628.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P64.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P64 2816 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.s630.ffi PRE_first_tail_x15_r0_body.s629.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_64
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_64
  have hcl : SSt (· < 2816) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S628.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_64] <;> decide) PRE_first_tail_x15_r0_body.cnodesK64 PRE_first_tail_x15_r0_body.cobjsK64
      PRE_first_tail_x15_r0_body.citemsK64 PRE_first_tail_x15_r0_body.cbd64 PRE_first_tail_x15_r0_body.csst64
  exact PRE_first_tail_x15_r0_body.cshift64 bodyNcl64 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_64] at this; exact this)


kernel_rfl bodyFramesEmpty64 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s629 a).isEmpty) = true
kernel_rfl bodyJsRoots64 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s628.next) PRE_first_tail_x15_r0_body.s630.trace PRE_first_tail_x15_r0_body.s630 = true
kernel_rfl bodyJsNative64 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s630.ffi) = true
kernel_rfl bodyLow64 : (PRE_first_tail_x15_r0_body.cws64 ++ PRE_first_tail_x15_r0_body.ws64).all (Nat.ble 9) = true
kernel_rfl bodyCntM64 : countersOkB PRE_first_tail_x15_r0_body.s628 PRE_first_tail_x15_r0_body.s629 = true
kernel_rfl bodyHi64 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s630.ffi).next setupP.E = true
kernel_rfl bodyNhi64 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s630.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge64 : bridgeOf PRE_first_tail_x15_r0_body.s629.ffi = bridgeOf PRE_first_tail_x15_r0_body.s628.ffi
kernel_rfl bodyNN64 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s628.ffi).nnext PRE_first_tail_x15_r0_body.P64.NL = true
kernel_rfl bodyXn64 : Nat.ble (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s630.ffi).next = true
kernel_rfl bodyLo64 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s630.ffi).next = true
theorem bodyFacts64 : BodySiteFacts PRE_first_tail_x15_r0_body.s628 PRE_first_tail_x15_r0_body.s629 PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S628 PRE_first_tail_x15_r0_body.S629 PRE_first_tail_x15_r0_body.S630
    PRE_first_tail_x15_r0_body.ws64 PRE_first_tail_x15_r0_body.cws64 PRE_first_tail_x15_r0_body.nr64 PRE_first_tail_x15_r0_body.pl64 PRE_first_tail_x15_r0_body.cl64 2725301 2816 PRE_first_tail_x15_r0_body.kd64 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.P64
    ⟨19469, 16566, 2725299, 2816⟩ ⟨19469, 16566, 2725299, 2816⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap64
  clean := bodyClean64
  cfix := PRE_first_tail_x15_r0_body.cfix64
  zpl := PRE_first_tail_x15_r0_body.zpl64
  zplnd := PRE_first_tail_x15_r0_body.zplnd64
  zn1 := PRE_first_tail_x15_r0_body.zn164
  zfirst := PRE_first_tail_x15_r0_body.zfirst64
  zscn := PRE_first_tail_x15_r0_body.zscn64
  zsmn := PRE_first_tail_x15_r0_body.zsmn64
  zgrow := PRE_first_tail_x15_r0_body.zgrow64
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab64
  zfresh := PRE_first_tail_x15_r0_body.zfresh64
  zcnd := PRE_first_tail_x15_r0_body.zcnd64
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi64
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt64
  zgP := PRE_first_tail_x15_r0_body.zg64_2665
  zkP := PRE_first_tail_x15_r0_body.zk64_2665
  zmP := PRE_first_tail_x15_r0_body.zm64_2665
  zgC := PRE_first_tail_x15_r0_body.zg64_2673467
  zkC := PRE_first_tail_x15_r0_body.zk64_2673467
  zmC := PRE_first_tail_x15_r0_body.zm64_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw64_2673472
  zwV := PRE_first_tail_x15_r0_body.zw64_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap64
  zclbd := PRE_first_tail_x15_r0_body.zclbd64
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap64 PRE_first_tail_x15_r0_body.stFoot64 PRE_first_tail_x15_r0_body.iso64 PRE_first_tail_x15_r0_body.zwr64
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP64
  csupp := PRE_first_tail_x15_r0_body.csupp64
  cbound := PRE_first_tail_x15_r0_body.cbound64
  zimg := PRE_first_tail_x15_r0_body.zimg64
  zctl := PRE_first_tail_x15_r0_body.zctl64
  zstack := PRE_first_tail_x15_r0_body.zstack64
  zjobs := PRE_first_tail_x15_r0_body.zjobs64
  zstores := PRE_first_tail_x15_r0_body.zstores64
  zroots := PRE_first_tail_x15_r0_body.zroots64
  znC := PRE_first_tail_x15_r0_body.znC64
  ctab := PRE_first_tail_x15_r0_body.ctab64
  zbin := PRE_first_tail_x15_r0_body.zbin64
  cbridge := PRE_first_tail_x15_r0_body.cbridge64
  sbridge := bodyBridge64
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj64
  cshiftR := fun h hNL => bodyCshift64 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN64
  raised := PRE_first_tail_x15_r0_body.raised64
  cbigs := PRE_first_tail_x15_r0_body.cbigs64
  cjcl := PRE_first_tail_x15_r0_body.cjcl64
  xnLe := Nat.le_of_ble_eq_true bodyXn64
  loLe := Nat.le_of_ble_eq_true bodyLo64
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB64
  cntM := bodyCntM64
  hiLe := Nat.le_of_ble_eq_true bodyHi64
  nhiLe := Nat.le_of_ble_eq_true bodyNhi64
  jsHeap := bodyJs64
  jsRoots := bodyJsRoots64
  jsNative := bodyJsNative64
  framesEmpty := bodyFramesEmpty64
  trailOld := by decide
  lowVars := bodyLow64

def bodyQs64 : List (Option Q) := []
noncomputable def bodyEs64 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr64.map fun r => nth? PRE_first_tail_x15_r0_body.st64.S2.tab r
kernel_rfl bodyResChk64 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs64 bodyQs64) = true
kernel_rfl bodyLq64 : bodyQs64.length = PRE_first_tail_x15_r0_body.cws64.length
kernel_rfl bodyNrLo64 : PRE_first_tail_x15_r0_body.nr64.all (Nat.ble PRE_first_tail_x15_r0_body.S628.tab.length) = true
kernel_rfl bodySub64 : (Oracles.PRE_first_tail_x15_r0_body.map_site64.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost64 : postSubB bodyM PRE_first_tail_x15_r0_body.ws64 PRE_first_tail_x15_r0_body.cws64 bodyQs64 = true
kernel_rfl bodyDrop64 : Nat.ble (25712 + (PRE_first_tail_x15_r0_body.s629.next - PRE_first_tail_x15_r0_body.s630.next)) 25714 = true
kernel_rfl bodyDropH64 : Nat.ble (456 + ((mlxOf PRE_first_tail_x15_r0_body.s629.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s630.ffi).next)) 456 = true
kernel_rfl bodyDropN64 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s629.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s630.ffi).nnext)) 0 = true
kernel_rfl bodyDv64 : bodyΘ.1.take 351 = bodyΘ.1.take 351 ++ PRE_first_tail_x15_r0_body.cws64
kernel_rfl bodyDe64 : bodyΘ.2.take 351 = bodyΘ.2.take 351 ++ PRE_first_tail_x15_r0_body.nr64.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st64.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 351) (bodyΘ.2.take 351)))
kernel_rfl bodyDl64 : (bodyΘ.1.take 351).length = (bodyΘ.2.take 351).length
kernel_rfl bodyDold64 : (bodyΘ.1.take 351).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws64).isNone && !PRE_first_tail_x15_r0_body.ws64.contains v) = true
kernel_rfl bodyDfree64 : (bodyΘ.2.take 351).all (fun e => (PRE_first_tail_x15_r0_body.cws64 ++ PRE_first_tail_x15_r0_body.ws64).all fun w => e.noVar w) = true

theorem bodyStep64 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨25712, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s628 PRE_first_tail_x15_r0_body.S628)
      (bodyCut NB T tk π i x0 bodyΘ ⟨25714, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.S630) (27 + 1) :=
  bodySite bodyFacts64.cfix bodyFacts64.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st64.S2.tab) (Es := bodyEs64) (qs := bodyQs64)
    (ok := PRE_first_tail_x15_r0_body.st64.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site64 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts64
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site64 r hr) hi (MapOk.sub hm (sub_of_all bodySub64)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk64 r hr) hi hm ho hq)
    bodyLq64 rfl bodyNrLo64 (postSub_sound bodyPost64)
    (Nat.le_of_ble_eq_true bodyDrop64) (by decide) (Nat.le_of_ble_eq_true bodyDropH64) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN64) (by decide)
    bodyDv64 bodyDe64 bodyDl64 bodyDold64 bodyDfree64 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
