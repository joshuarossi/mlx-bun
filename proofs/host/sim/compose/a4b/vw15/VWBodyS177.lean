import host.sim.compose.a4b.vw15.VWBodyJ177
import host.sim.compose.a4b.vw15.VWBodySite177
import host.sim.compose.a4b.vw15.VWBodyOracles_44
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

theorem bodyCshift177 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1712.tab.length PRE_first_tail_x15_r0_body.s1712.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P177.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P177 7665 PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.s1714.ffi PRE_first_tail_x15_r0_body.s1713.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_177
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_177
  have hcl : SSt (· < 7665) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1712.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_177] <;> decide) PRE_first_tail_x15_r0_body.cnodesK177 PRE_first_tail_x15_r0_body.cobjsK177
      PRE_first_tail_x15_r0_body.citemsK177 PRE_first_tail_x15_r0_body.cbd177 PRE_first_tail_x15_r0_body.csst177
  exact PRE_first_tail_x15_r0_body.cshift177 bodyNcl177 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_177] at this; exact this)


kernel_rfl bodyFramesEmpty177 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1713 a).isEmpty) = true
kernel_rfl bodyJsRoots177 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1712.next) PRE_first_tail_x15_r0_body.s1714.trace PRE_first_tail_x15_r0_body.s1714 = true
kernel_rfl bodyJsNative177 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1714.ffi) = true
kernel_rfl bodyLow177 : (PRE_first_tail_x15_r0_body.cws177 ++ PRE_first_tail_x15_r0_body.ws177).all (Nat.ble 9) = true
kernel_rfl bodyCntM177 : countersOkB PRE_first_tail_x15_r0_body.s1712 PRE_first_tail_x15_r0_body.s1713 = true
kernel_rfl bodyHi177 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1714.ffi).next setupP.E = true
kernel_rfl bodyNhi177 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1714.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge177 : bridgeOf PRE_first_tail_x15_r0_body.s1713.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1712.ffi
kernel_rfl bodyNN177 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1712.ffi).nnext PRE_first_tail_x15_r0_body.P177.NL = true
kernel_rfl bodyXn177 : Nat.ble (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1714.ffi).next = true
kernel_rfl bodyLo177 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1714.ffi).next = true
theorem bodyFacts177 : BodySiteFacts PRE_first_tail_x15_r0_body.s1712 PRE_first_tail_x15_r0_body.s1713 PRE_first_tail_x15_r0_body.s1714 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1712 PRE_first_tail_x15_r0_body.S1713 PRE_first_tail_x15_r0_body.S1714
    PRE_first_tail_x15_r0_body.ws177 PRE_first_tail_x15_r0_body.cws177 PRE_first_tail_x15_r0_body.nr177 PRE_first_tail_x15_r0_body.pl177 PRE_first_tail_x15_r0_body.cl177 2814709 7665 PRE_first_tail_x15_r0_body.kd177 PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.P177
    ⟨21697, 18794, 2814344, 7656⟩ ⟨21701, 18800, 2814359, 7665⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap177
  clean := bodyClean177
  cfix := PRE_first_tail_x15_r0_body.cfix177
  zpl := PRE_first_tail_x15_r0_body.zpl177
  zplnd := PRE_first_tail_x15_r0_body.zplnd177
  zn1 := PRE_first_tail_x15_r0_body.zn1177
  zfirst := PRE_first_tail_x15_r0_body.zfirst177
  zscn := PRE_first_tail_x15_r0_body.zscn177
  zsmn := PRE_first_tail_x15_r0_body.zsmn177
  zgrow := PRE_first_tail_x15_r0_body.zgrow177
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab177
  zfresh := PRE_first_tail_x15_r0_body.zfresh177
  zcnd := PRE_first_tail_x15_r0_body.zcnd177
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi177
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt177
  zgP := PRE_first_tail_x15_r0_body.zg177_2665
  zkP := PRE_first_tail_x15_r0_body.zk177_2665
  zmP := PRE_first_tail_x15_r0_body.zm177_2665
  zgC := PRE_first_tail_x15_r0_body.zg177_2673467
  zkC := PRE_first_tail_x15_r0_body.zk177_2673467
  zmC := PRE_first_tail_x15_r0_body.zm177_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw177_2673472
  zwV := PRE_first_tail_x15_r0_body.zw177_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap177
  zclbd := PRE_first_tail_x15_r0_body.zclbd177
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap177 PRE_first_tail_x15_r0_body.stFoot177 PRE_first_tail_x15_r0_body.iso177 PRE_first_tail_x15_r0_body.zwr177
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP177
  csupp := PRE_first_tail_x15_r0_body.csupp177
  cbound := PRE_first_tail_x15_r0_body.cbound177
  zimg := PRE_first_tail_x15_r0_body.zimg177
  zctl := PRE_first_tail_x15_r0_body.zctl177
  zstack := PRE_first_tail_x15_r0_body.zstack177
  zjobs := PRE_first_tail_x15_r0_body.zjobs177
  zstores := PRE_first_tail_x15_r0_body.zstores177
  zroots := PRE_first_tail_x15_r0_body.zroots177
  znC := PRE_first_tail_x15_r0_body.znC177
  ctab := PRE_first_tail_x15_r0_body.ctab177
  zbin := PRE_first_tail_x15_r0_body.zbin177
  cbridge := PRE_first_tail_x15_r0_body.cbridge177
  sbridge := bodyBridge177
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj177
  cshiftR := fun h hNL => bodyCshift177 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN177
  raised := PRE_first_tail_x15_r0_body.raised177
  cbigs := PRE_first_tail_x15_r0_body.cbigs177
  cjcl := PRE_first_tail_x15_r0_body.cjcl177
  xnLe := Nat.le_of_ble_eq_true bodyXn177
  loLe := Nat.le_of_ble_eq_true bodyLo177
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB177
  cntM := bodyCntM177
  hiLe := Nat.le_of_ble_eq_true bodyHi177
  nhiLe := Nat.le_of_ble_eq_true bodyNhi177
  jsHeap := bodyJs177
  jsRoots := bodyJsRoots177
  jsNative := bodyJsNative177
  framesEmpty := bodyFramesEmpty177
  trailOld := by decide
  lowVars := bodyLow177

def bodyQs177 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs177 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr177.map fun r => nth? PRE_first_tail_x15_r0_body.st177.S3.tab r
kernel_rfl bodyResChk177 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs177 bodyQs177) = true
kernel_rfl bodyLq177 : bodyQs177.length = PRE_first_tail_x15_r0_body.cws177.length
kernel_rfl bodyNrLo177 : PRE_first_tail_x15_r0_body.nr177.all (Nat.ble PRE_first_tail_x15_r0_body.S1712.tab.length) = true
kernel_rfl bodySub177 : (Oracles.PRE_first_tail_x15_r0_body.map_site177.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost177 : postSubB bodyM PRE_first_tail_x15_r0_body.ws177 PRE_first_tail_x15_r0_body.cws177 bodyQs177 = true
kernel_rfl bodyDrop177 : Nat.ble (61616 + (PRE_first_tail_x15_r0_body.s1713.next - PRE_first_tail_x15_r0_body.s1714.next)) 61966 = true
kernel_rfl bodyDropH177 : Nat.ble (1174 + ((mlxOf PRE_first_tail_x15_r0_body.s1713.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1714.ffi).next)) 1176 = true
kernel_rfl bodyDropN177 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1713.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1714.ffi).nnext)) 0 = true
kernel_rfl bodyDv177 : bodyΘ.1.take 945 = bodyΘ.1.take 936 ++ PRE_first_tail_x15_r0_body.cws177
kernel_rfl bodyDe177 : bodyΘ.2.take 945 = bodyΘ.2.take 936 ++ PRE_first_tail_x15_r0_body.nr177.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st177.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 936) (bodyΘ.2.take 936)))
kernel_rfl bodyDl177 : (bodyΘ.1.take 936).length = (bodyΘ.2.take 936).length
kernel_rfl bodyDold177 : (bodyΘ.1.take 936).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws177).isNone && !PRE_first_tail_x15_r0_body.ws177.contains v) = true
kernel_rfl bodyDfree177 : (bodyΘ.2.take 945).all (fun e => (PRE_first_tail_x15_r0_body.cws177 ++ PRE_first_tail_x15_r0_body.ws177).all fun w => e.noVar w) = true

theorem bodyStep177 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61616, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1712 PRE_first_tail_x15_r0_body.S1712)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61966, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1714 PRE_first_tail_x15_r0_body.S1714) (3452 + 1) :=
  bodySite bodyFacts177.cfix bodyFacts177.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st177.S3.tab) (Es := bodyEs177) (qs := bodyQs177)
    (ok := PRE_first_tail_x15_r0_body.st177.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site177 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts177
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site177 r hr) hi (MapOk.sub hm (sub_of_all bodySub177)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk177 r hr) hi hm ho hq)
    bodyLq177 rfl bodyNrLo177 (postSub_sound bodyPost177)
    (Nat.le_of_ble_eq_true bodyDrop177) (by decide) (Nat.le_of_ble_eq_true bodyDropH177) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN177) (by decide)
    bodyDv177 bodyDe177 bodyDl177 bodyDold177 bodyDfree177 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
