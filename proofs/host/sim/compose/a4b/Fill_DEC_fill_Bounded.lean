import host.sim.compose.a4b.Fill_DEC_fill
import host.sim.compose.StartBounded

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

/-- **Decode case `fill`'s pieces from chain `DEC_fill`** at the prompt route's instance (`addrPrompt`, `wideP`, the
frames `framesP DEC_fill.s0 q`, `fixP`), A4's end (`DEC_fill.iterEnd`). -/
noncomputable def DEC_fill.piecesBounded (q : List Val) (R : DEC_fill.Runs)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (hdJ : 148175 ≤ ΔJ) (hdH : 3771 ≤ ΔH) (hdN : 4690 ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).next + T * ΔH + B.H + (DEC_fill.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).nnext + T * ΔN + B.N + (DEC_fill.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).nnext) < 2 ^ 62) :
    DecPieces_DEC_fill (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_fill.Pw (Template.framesP Host.Load.Run.Tpl.DEC_fill.s0 q) Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab Template.fixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      L T ((Host.Load.Run.Tpl.DEC_fill.iterEnd NB).toFb b0) (DEC_fill.g3 b0 NB DEC_fill.eN) :=
  let θ := Host.Load.Run.Tpl.DEC_fill.θ
  let hW := DEC_fill.hW
  let Gw : DEC_fill.Grow b0 NB Template.wideP := DEC_fill.grow R hW
  { c1 := (fun i x0 => bdCut b0 NB DEC_fill.Pw DEC_fill.fr DEC_fill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_fill.s0 q) Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) Host.Load.Run.Tpl.DEC_fill.s0) DEC_fill.m0 Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0 i x0)
    c2 := (fun i x0 => bdCut b0 NB DEC_fill.Pw DEC_fill.fr DEC_fill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_fill.s0 q) Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_fill.g1 b0 NB DEC_fill.eN) DEC_fill.m0 Host.Load.Run.Tpl.DEC_fill.s2 Host.Load.Run.Tpl.DEC_fill.S2 i x0)
    c3 := (fun i x0 => bdCut b0 NB DEC_fill.Pw DEC_fill.fr DEC_fill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_fill.s0 q) Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_fill.g1 b0 NB DEC_fill.eN) DEC_fill.m0 Host.Load.Run.Tpl.DEC_fill.s4 Host.Load.Run.Tpl.DEC_fill.S4 i x0)
    c4 := (fun i x0 => bdCut b0 NB DEC_fill.Pw DEC_fill.fr DEC_fill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_fill.s0 q) Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_fill.g2 b0 NB DEC_fill.eN) DEC_fill.m1 Host.Load.Run.Tpl.DEC_fill.s6 Host.Load.Run.Tpl.DEC_fill.S6 i x0)
    c5 := (fun i x0 => bdCut b0 NB DEC_fill.Pw DEC_fill.fr DEC_fill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_fill.s0 q) Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_fill.g2 b0 NB DEC_fill.eN) DEC_fill.m1 Host.Load.Run.Tpl.DEC_fill.s8 Host.Load.Run.Tpl.DEC_fill.S8 i x0)
    c6 := (fun i x0 => bdCut b0 NB DEC_fill.Pw DEC_fill.fr DEC_fill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_fill.s0 q) Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_fill.g3 b0 NB DEC_fill.eN) DEC_fill.m1 Host.Load.Run.Tpl.DEC_fill.s10 Host.Load.Run.Tpl.DEC_fill.S10 i x0)
    start := startLinkBounded [] (by decide +kernel) rfl rfl (DEC_fill.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    rb__start__g1 := callLink Host.Load.Run.Tpl.DEC_fill.st0.tpl Host.Load.Run.Tpl.DEC_fill.st0.O hW DEC_fill.chk0 Host.Load.Run.Tpl.DEC_fill.srvO0 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_fill.iso0) (htab := Host.Load.Run.Tpl.DEC_fill.tab0_0) (hfoot := Host.Load.Run.Tpl.DEC_fill.stFoot0) (hnd := Host.Load.Run.Tpl.DEC_fill.wrNodup0)
      (hbd := Host.Load.Run.Tpl.DEC_fill.wrBound0) (htr := Host.Load.Run.Tpl.DEC_fill.trace0) (hmer := fun _ => Host.Load.Run.Tpl.DEC_fill.merged0) (hmtab := Host.Load.Run.Tpl.DEC_fill.mergeTab0)
      (hwsl := DEC_fill.wsl0) (hwsnd := (Template.nodupT_sound DEC_fill.wsnd0).2) (hfresh := noVar_of_all DEC_fill.fresh0)
      (hlen := Nat.le_of_ble_eq_true DEC_fill.len0) (hgtab := noVar_nth_of_all DEC_fill.gtab0)
      (hgθ := noVarθ_nth_of_all DEC_fill.gth0)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_fill.st0.tpl Host.Load.Run.Tpl.DEC_fill.iso0 Host.Load.Run.Tpl.DEC_fill.stFoot0 Host.Load.Run.Tpl.DEC_fill.wrNodup0 Host.Load.Run.Tpl.DEC_fill.wrBound0 Host.Load.Run.Tpl.DEC_fill.trace0)
      (hctab := Host.Load.Run.Tpl.DEC_fill.ctab0) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_fill.cwsDisj0) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_fill.ctab0 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_fill.zkap0
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_fill.jcl0) Host.Load.Run.Tpl.DEC_fill.cfix0 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_fill.zpl0 Host.Load.Run.Tpl.DEC_fill.zplnd0 Host.Load.Run.Tpl.DEC_fill.zn10 Host.Load.Run.Tpl.DEC_fill.zfirst0 Host.Load.Run.Tpl.DEC_fill.zscn0 Host.Load.Run.Tpl.DEC_fill.zsmn0 Host.Load.Run.Tpl.DEC_fill.zgrow0 Host.Load.Run.Tpl.DEC_fill.mergeTab0
        Host.Load.Run.Tpl.DEC_fill.zfresh0 Host.Load.Run.Tpl.DEC_fill.zcnd0 DEC_fill.lenc0 Host.Load.Run.Tpl.DEC_fill.znrHi0 Host.Load.Run.Tpl.DEC_fill.znC0 Host.Load.Run.Tpl.DEC_fill.zfrlt0 xs_wideP wfr_wideP (hX_framesP DEC_fill.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_fill.zg0_2673448, Host.Load.Run.Tpl.DEC_fill.zk0_2673448, Host.Load.Run.Tpl.DEC_fill.zm0_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_fill.zg0_12504, Host.Load.Run.Tpl.DEC_fill.zk0_12504, Host.Load.Run.Tpl.DEC_fill.zm0_12504⟩, ⟨Host.Load.Run.Tpl.DEC_fill.zg0_2665, Host.Load.Run.Tpl.DEC_fill.zk0_2665, Host.Load.Run.Tpl.DEC_fill.zm0_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_fill.zw0_4910) wf_wideP Host.Load.Run.Tpl.DEC_fill.zclbd0 Host.Load.Run.Tpl.DEC_fill.cheap0
        (hoff_of Host.Load.Run.Tpl.DEC_fill.mheap0 Host.Load.Run.Tpl.DEC_fill.stFoot0 Host.Load.Run.Tpl.DEC_fill.iso0 Host.Load.Run.Tpl.DEC_fill.zwr0) Host.Load.Run.Tpl.DEC_fill.ckeepP0 Host.Load.Run.Tpl.DEC_fill.csupp0 Host.Load.Run.Tpl.DEC_fill.cbound0 Host.Load.Run.Tpl.DEC_fill.zimg0
        Host.Load.Run.Tpl.DEC_fill.zctl0 Host.Load.Run.Tpl.DEC_fill.zstack0 Host.Load.Run.Tpl.DEC_fill.zjobs0 Host.Load.Run.Tpl.DEC_fill.zstores0 Host.Load.Run.Tpl.DEC_fill.zroots0 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_fill.cshiftR0 h rfl)
      (hbig := DEC_fill.big0) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_fill.jcl2)
        (Nat.le_of_ble_eq_true DEC_fill.xn0) (by decide) Host.Load.Run.Tpl.DEC_fill.zroots20)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_fill.bandLo0) (Nat.le_of_ble_eq_true DEC_fill.bandHi) (by decide))
      (hκn := compact_num_of DEC_fill.kn0) (hκa := compact_fix_of DEC_fill.ka0) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_fill.cfix0 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_fill.zhm0))
      (hfwd := Host.Load.Run.Tpl.DEC_fill.arr0_2673448) (hemit := Host.Load.Run.Tpl.DEC_fill.arr0_12504) (hkeep := Host.Load.Run.Tpl.DEC_fill.keep0 q)
      (heN := Host.Load.Run.Tpl.DEC_fill.arrR0_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_fill.cJm0) (hJc := Nat.le_of_ble_eq_true DEC_fill.cJc0)
      (hH := Nat.le_of_ble_eq_true DEC_fill.cHm0) (hHE := Nat.blt_eq.mp DEC_fill.cHE0)
      (hN := Nat.le_of_ble_eq_true DEC_fill.cNm0) (hm0 := m0_of_all DEC_fill.m0_0) (hndc := (Template.nodupT_sound DEC_fill.ndc0).2)
      (hlenc := DEC_fill.lenc0) (hnrLo := DEC_fill.nrLo0) (hder := rfl)
      (qs := DEC_fill.qs0) (hlq := DEC_fill.lq0) (hEs := hEs_of_all (by decide) DEC_fill.dq0)
      (hq := qs_le DEC_fill.qsOk0) (hR' := sub_of_all DEC_fill.R'0)
      (dJ := 148175) (dH := 3771) (dN := 4690) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_fill.cRJ0) (hcH := Nat.le_of_ble_eq_true DEC_fill.cRH0)
      (hcN := Nat.le_of_ble_eq_true DEC_fill.cRN0) (hs0E := Nat.le_of_ble_eq_true DEC_fill.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_fill.scE0) (hs0N := Nat.le_of_ble_eq_true DEC_fill.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_fill.scN0)
    g1 := glueLinkCall (List.drop 0 Host.Load.Run.Tpl.DEC_fill.O) hW DEC_fill.chk_g1 DEC_fill.srv2 DEC_fill.ok2 R.runSeg1
      (runOk_ok_end 899 R.runSeg1 DEC_fill.halt3) DEC_fill.halt3 R.stepA2 DEC_fill.top4
      (Nat.le_of_ble_eq_true DEC_fill.len2) (fun _ h => h) Gw.g1
    fwd_D1_warm_DFill__g1__g2 := callLink Host.Load.Run.Tpl.DEC_fill.st1.tpl Host.Load.Run.Tpl.DEC_fill.st1.O hW DEC_fill.chk1 Host.Load.Run.Tpl.DEC_fill.srvO1 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_fill.iso1) (htab := Host.Load.Run.Tpl.DEC_fill.tab0_1) (hfoot := Host.Load.Run.Tpl.DEC_fill.stFoot1) (hnd := Host.Load.Run.Tpl.DEC_fill.wrNodup1)
      (hbd := Host.Load.Run.Tpl.DEC_fill.wrBound1) (htr := Host.Load.Run.Tpl.DEC_fill.trace1) (hmer := fun _ => Host.Load.Run.Tpl.DEC_fill.merged1) (hmtab := Host.Load.Run.Tpl.DEC_fill.mergeTab1)
      (hwsl := DEC_fill.wsl1) (hwsnd := (Template.nodupT_sound DEC_fill.wsnd1).2) (hfresh := noVar_of_all DEC_fill.fresh1)
      (hlen := Nat.le_of_ble_eq_true DEC_fill.len4) (hgtab := noVar_nth_of_all DEC_fill.gtab1)
      (hgθ := noVarθ_nth_of_all DEC_fill.gth1)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_fill.st1.tpl Host.Load.Run.Tpl.DEC_fill.iso1 Host.Load.Run.Tpl.DEC_fill.stFoot1 Host.Load.Run.Tpl.DEC_fill.wrNodup1 Host.Load.Run.Tpl.DEC_fill.wrBound1 Host.Load.Run.Tpl.DEC_fill.trace1)
      (hctab := Host.Load.Run.Tpl.DEC_fill.ctab1) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_fill.cwsDisj1) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_fill.ctab1 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_fill.zkap1
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_fill.jcl4) Host.Load.Run.Tpl.DEC_fill.cfix1 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_fill.zpl1 Host.Load.Run.Tpl.DEC_fill.zplnd1 Host.Load.Run.Tpl.DEC_fill.zn11 Host.Load.Run.Tpl.DEC_fill.zfirst1 Host.Load.Run.Tpl.DEC_fill.zscn1 Host.Load.Run.Tpl.DEC_fill.zsmn1 Host.Load.Run.Tpl.DEC_fill.zgrow1 Host.Load.Run.Tpl.DEC_fill.mergeTab1
        Host.Load.Run.Tpl.DEC_fill.zfresh1 Host.Load.Run.Tpl.DEC_fill.zcnd1 DEC_fill.lenc1 Host.Load.Run.Tpl.DEC_fill.znrHi1 Host.Load.Run.Tpl.DEC_fill.znC1 Host.Load.Run.Tpl.DEC_fill.zfrlt1 xs_wideP wfr_wideP (hX_framesP DEC_fill.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_fill.zg1_2673448, Host.Load.Run.Tpl.DEC_fill.zk1_2673448, Host.Load.Run.Tpl.DEC_fill.zm1_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_fill.zg1_12504, Host.Load.Run.Tpl.DEC_fill.zk1_12504, Host.Load.Run.Tpl.DEC_fill.zm1_12504⟩, ⟨Host.Load.Run.Tpl.DEC_fill.zg1_2665, Host.Load.Run.Tpl.DEC_fill.zk1_2665, Host.Load.Run.Tpl.DEC_fill.zm1_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_fill.zw1_4910) wf_wideP Host.Load.Run.Tpl.DEC_fill.zclbd1 Host.Load.Run.Tpl.DEC_fill.cheap1
        (hoff_of Host.Load.Run.Tpl.DEC_fill.mheap1 Host.Load.Run.Tpl.DEC_fill.stFoot1 Host.Load.Run.Tpl.DEC_fill.iso1 Host.Load.Run.Tpl.DEC_fill.zwr1) Host.Load.Run.Tpl.DEC_fill.ckeepP1 Host.Load.Run.Tpl.DEC_fill.csupp1 Host.Load.Run.Tpl.DEC_fill.cbound1 Host.Load.Run.Tpl.DEC_fill.zimg1
        Host.Load.Run.Tpl.DEC_fill.zctl1 Host.Load.Run.Tpl.DEC_fill.zstack1 Host.Load.Run.Tpl.DEC_fill.zjobs1 Host.Load.Run.Tpl.DEC_fill.zstores1 Host.Load.Run.Tpl.DEC_fill.zroots1 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_fill.cshiftR1 h rfl)
      (hbig := DEC_fill.big1) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_fill.jcl6)
        (Nat.le_of_ble_eq_true DEC_fill.xn1) (by decide) Host.Load.Run.Tpl.DEC_fill.zroots21)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_fill.bandLo1) (Nat.le_of_ble_eq_true DEC_fill.bandHi) (by decide))
      (hκn := compact_num_of DEC_fill.kn1) (hκa := compact_fix_of DEC_fill.ka1) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_fill.cfix1 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_fill.zhm1))
      (hfwd := Host.Load.Run.Tpl.DEC_fill.arr1_2673448) (hemit := Host.Load.Run.Tpl.DEC_fill.arr1_12504) (hkeep := Host.Load.Run.Tpl.DEC_fill.keep1 q)
      (heN := Host.Load.Run.Tpl.DEC_fill.arrR1_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_fill.cJm1) (hJc := Nat.le_of_ble_eq_true DEC_fill.cJc1)
      (hH := Nat.le_of_ble_eq_true DEC_fill.cHm1) (hHE := Nat.blt_eq.mp DEC_fill.cHE1)
      (hN := Nat.le_of_ble_eq_true DEC_fill.cNm1) (hm0 := m0_of_all DEC_fill.m0_1) (hndc := (Template.nodupT_sound DEC_fill.ndc1).2)
      (hlenc := DEC_fill.lenc1) (hnrLo := DEC_fill.nrLo1) (hder := rfl)
      (qs := DEC_fill.qs1) (hlq := DEC_fill.lq1) (hEs := hEs_of_all (by decide) DEC_fill.dq1)
      (hq := qs_le DEC_fill.qsOk1) (hR' := sub_of_all DEC_fill.R'1)
      (dJ := 148175) (dH := 3771) (dN := 4690) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_fill.cRJ1) (hcH := Nat.le_of_ble_eq_true DEC_fill.cRH1)
      (hcN := Nat.le_of_ble_eq_true DEC_fill.cRN1) (hs0E := Nat.le_of_ble_eq_true DEC_fill.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_fill.scE1) (hs0N := Nat.le_of_ble_eq_true DEC_fill.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_fill.scN1)
    g2 := glueLinkCall (List.drop 5 Host.Load.Run.Tpl.DEC_fill.O) hW DEC_fill.chk_g2 DEC_fill.srv6 DEC_fill.ok6 R.runSeg2
      (runOk_ok_end 3657 R.runSeg2 DEC_fill.halt7) DEC_fill.halt7 R.stepA3 DEC_fill.top8
      (Nat.le_of_ble_eq_true DEC_fill.len6) (fun _ h => h) Gw.g2
    async__g2__g3 := callLink Host.Load.Run.Tpl.DEC_fill.st2.tpl Host.Load.Run.Tpl.DEC_fill.st2.O hW DEC_fill.chk2 Host.Load.Run.Tpl.DEC_fill.srvO2 (by decide +kernel)
      (hs0 := Host.Load.Run.Tpl.DEC_fill.iso2) (htab := Host.Load.Run.Tpl.DEC_fill.tab0_2) (hfoot := Host.Load.Run.Tpl.DEC_fill.stFoot2) (hnd := Host.Load.Run.Tpl.DEC_fill.wrNodup2)
      (hbd := Host.Load.Run.Tpl.DEC_fill.wrBound2) (htr := Host.Load.Run.Tpl.DEC_fill.trace2) (hmer := fun _ => Host.Load.Run.Tpl.DEC_fill.merged2) (hmtab := Host.Load.Run.Tpl.DEC_fill.mergeTab2)
      (hwsl := DEC_fill.wsl2) (hwsnd := (Template.nodupT_sound DEC_fill.wsnd2).2) (hfresh := noVar_of_all DEC_fill.fresh2)
      (hlen := Nat.le_of_ble_eq_true DEC_fill.len8) (hgtab := noVar_nth_of_all DEC_fill.gtab2)
      (hgθ := noVarθ_nth_of_all DEC_fill.gth2)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_fill.st2.tpl Host.Load.Run.Tpl.DEC_fill.iso2 Host.Load.Run.Tpl.DEC_fill.stFoot2 Host.Load.Run.Tpl.DEC_fill.wrNodup2 Host.Load.Run.Tpl.DEC_fill.wrBound2 Host.Load.Run.Tpl.DEC_fill.trace2)
      (hctab := Host.Load.Run.Tpl.DEC_fill.ctab2) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_fill.cwsDisj2) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_fill.ctab2 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_fill.zkap2
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_fill.jcl8) Host.Load.Run.Tpl.DEC_fill.cfix2 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_fill.zpl2 Host.Load.Run.Tpl.DEC_fill.zplnd2 Host.Load.Run.Tpl.DEC_fill.zn12 Host.Load.Run.Tpl.DEC_fill.zfirst2 Host.Load.Run.Tpl.DEC_fill.zscn2 Host.Load.Run.Tpl.DEC_fill.zsmn2 Host.Load.Run.Tpl.DEC_fill.zgrow2 Host.Load.Run.Tpl.DEC_fill.mergeTab2
        Host.Load.Run.Tpl.DEC_fill.zfresh2 Host.Load.Run.Tpl.DEC_fill.zcnd2 DEC_fill.lenc2 Host.Load.Run.Tpl.DEC_fill.znrHi2 Host.Load.Run.Tpl.DEC_fill.znC2 Host.Load.Run.Tpl.DEC_fill.zfrlt2 xs_wideP wfr_wideP (hX_framesP DEC_fill.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_fill.zg2_2673448, Host.Load.Run.Tpl.DEC_fill.zk2_2673448, Host.Load.Run.Tpl.DEC_fill.zm2_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_fill.zg2_12504, Host.Load.Run.Tpl.DEC_fill.zk2_12504, Host.Load.Run.Tpl.DEC_fill.zm2_12504⟩, ⟨Host.Load.Run.Tpl.DEC_fill.zg2_2665, Host.Load.Run.Tpl.DEC_fill.zk2_2665, Host.Load.Run.Tpl.DEC_fill.zm2_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_fill.zw2_4910) wf_wideP Host.Load.Run.Tpl.DEC_fill.zclbd2 Host.Load.Run.Tpl.DEC_fill.cheap2
        (hoff_of Host.Load.Run.Tpl.DEC_fill.mheap2 Host.Load.Run.Tpl.DEC_fill.stFoot2 Host.Load.Run.Tpl.DEC_fill.iso2 Host.Load.Run.Tpl.DEC_fill.zwr2) Host.Load.Run.Tpl.DEC_fill.ckeepP2 Host.Load.Run.Tpl.DEC_fill.csupp2 Host.Load.Run.Tpl.DEC_fill.cbound2 Host.Load.Run.Tpl.DEC_fill.zimg2
        Host.Load.Run.Tpl.DEC_fill.zctl2 Host.Load.Run.Tpl.DEC_fill.zstack2 Host.Load.Run.Tpl.DEC_fill.zjobs2 Host.Load.Run.Tpl.DEC_fill.zstores2 Host.Load.Run.Tpl.DEC_fill.zroots2 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_fill.cshiftR2 h rfl)
      (hbig := DEC_fill.big2) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_fill.jcl10)
        (Nat.le_of_ble_eq_true DEC_fill.xn2) (by decide) Host.Load.Run.Tpl.DEC_fill.zroots22)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_fill.bandLo2) (Nat.le_of_ble_eq_true DEC_fill.bandHi) (by decide))
      (hκn := compact_num_of DEC_fill.kn2) (hκa := compact_fix_of DEC_fill.ka2) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_fill.cfix2 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_fill.zhm2))
      (hfwd := Host.Load.Run.Tpl.DEC_fill.arr2_2673448) (hemit := Host.Load.Run.Tpl.DEC_fill.arr2_12504) (hkeep := Host.Load.Run.Tpl.DEC_fill.keep2 q)
      (heN := Host.Load.Run.Tpl.DEC_fill.arrR2_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_fill.cJm2) (hJc := Nat.le_of_ble_eq_true DEC_fill.cJc2)
      (hH := Nat.le_of_ble_eq_true DEC_fill.cHm2) (hHE := Nat.blt_eq.mp DEC_fill.cHE2)
      (hN := Nat.le_of_ble_eq_true DEC_fill.cNm2) (hm0 := m0_of_all DEC_fill.m0_2) (hndc := (Template.nodupT_sound DEC_fill.ndc2).2)
      (hlenc := DEC_fill.lenc2) (hnrLo := DEC_fill.nrLo2) (hder := rfl)
      (qs := DEC_fill.qs2) (hlq := DEC_fill.lq2) (hEs := hEs_of_all (by decide) DEC_fill.dq2)
      (hq := qs_le DEC_fill.qsOk2) (hR' := sub_of_all DEC_fill.R'2)
      (dJ := 148175) (dH := 3771) (dN := 4690) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_fill.cRJ2) (hcH := Nat.le_of_ble_eq_true DEC_fill.cRH2)
      (hcN := Nat.le_of_ble_eq_true DEC_fill.cRN2) (hs0E := Nat.le_of_ble_eq_true DEC_fill.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_fill.scE2) (hs0N := Nat.le_of_ble_eq_true DEC_fill.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_fill.scN2)
    g3 := glueLinkEndD (List.drop 5 Host.Load.Run.Tpl.DEC_fill.O) hW DEC_fill.chk_g3 DEC_fill.srv10 DEC_fill.ok10 R.runSeg3
      DEC_fill.top11 Host.Load.Run.Tpl.DEC_fill.dvs Host.Load.Run.Tpl.DEC_fill.des (e := (Host.Load.Run.Tpl.DEC_fill.iterEnd NB).toFb b0) rfl DEC_fill.hS1D
      (hde_of_dec DEC_fill.hvsB (by decide))
      (Nat.le_of_ble_eq_true DEC_fill.len10) Gw.g3
  }

/-- **Decode case `fill` from chain `DEC_fill`** (`IterCaseW`) at the prompt route's instance, A4's end facts
(`DEC_fill.iterEnd`, `DEC_fill.shiftFW`, `DEC_fill.keep`). -/
noncomputable def DEC_fill.caseBounded (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : 148175 ≤ ΔJ) (hH : 3771 ≤ ΔH) (hN : 4690 ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).next + T * ΔH + B.H + (DEC_fill.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).nnext + T * ΔN + B.N + (DEC_fill.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).nnext) < 2 ^ 62) :
    IterCaseW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_fill.Pw (Template.framesP Host.Load.Run.Tpl.DEC_fill.s0 q) Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab Template.fixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .fill) where
  e := (Host.Load.Run.Tpl.DEC_fill.iterEnd NB).toFb b0
  g := DEC_fill.g3 b0 NB DEC_fill.eN
  chain := (DEC_fill.piecesBounded (E0 := E0) (B := B) q DEC_fill.runs hVB hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := Host.Load.Run.Tpl.DEC_fill.shiftFW NB q
  keep := Host.Load.Run.Tpl.DEC_fill.keep q
  emit := DEC_fill.emitTok b0 NB
  within := DEC_fill.within (e := (Host.Load.Run.Tpl.DEC_fill.iterEnd NB).toFb b0) DEC_fill.eN rfl hJ hH hN

end

end Host.Ts.Sim.Compose
