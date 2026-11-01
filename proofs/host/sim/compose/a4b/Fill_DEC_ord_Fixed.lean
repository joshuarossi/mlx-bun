import host.sim.compose.a4b.FixedEnds
import host.sim.compose.a4b.Fill_DEC_ord
import host.sim.compose.StartBounded

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

/-- **Decode case `ord`'s pieces from chain `DEC_ord`** at the prompt route's instance (`addrPrompt`, `wideP`, the
frames `framesP DEC_ord.s0 q`, `fixP`), A4's end (`DEC_ord.iterEnd`). -/
noncomputable def DEC_ord.piecesFixed (q : List Val) (R : DEC_ord.Runs)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (hdJ : 148175 ≤ ΔJ) (hdH : 3771 ≤ ΔH) (hdN : 4754 ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).next + T * ΔH + B.H + (DEC_ord.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).nnext + T * ΔN + B.N + (DEC_ord.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).nnext) < 2 ^ 62) :
    DecPieces_DEC_ord (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_ord.Pw (Template.framesP Host.Load.Run.Tpl.DEC_ord.s0 q) Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      L T (DEC_ord.endFixed b0 NB) (DEC_ord.g3 b0 NB DEC_ord.eN) :=
  let θ := Host.Load.Run.Tpl.DEC_ord.θ
  let hW := DEC_ord.hW
  let Gw : DEC_ord.Grow b0 NB Template.wideP := DEC_ord.grow R hW
  { c1 := (fun i x0 => bdCut b0 NB DEC_ord.Pw DEC_ord.fr DEC_ord.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_ord.s0 q) Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) Host.Load.Run.Tpl.DEC_ord.s0) DEC_ord.m0 Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0 i x0)
    c2 := (fun i x0 => bdCut b0 NB DEC_ord.Pw DEC_ord.fr DEC_ord.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_ord.s0 q) Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_ord.g1 b0 NB DEC_ord.eN) DEC_ord.m0 Host.Load.Run.Tpl.DEC_ord.s2 Host.Load.Run.Tpl.DEC_ord.S2 i x0)
    c3 := (fun i x0 => bdCut b0 NB DEC_ord.Pw DEC_ord.fr DEC_ord.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_ord.s0 q) Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_ord.g1 b0 NB DEC_ord.eN) DEC_ord.m0 Host.Load.Run.Tpl.DEC_ord.s4 Host.Load.Run.Tpl.DEC_ord.S4 i x0)
    c4 := (fun i x0 => bdCut b0 NB DEC_ord.Pw DEC_ord.fr DEC_ord.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_ord.s0 q) Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_ord.g2 b0 NB DEC_ord.eN) DEC_ord.m1 Host.Load.Run.Tpl.DEC_ord.s6 Host.Load.Run.Tpl.DEC_ord.S6 i x0)
    c5 := (fun i x0 => bdCut b0 NB DEC_ord.Pw DEC_ord.fr DEC_ord.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_ord.s0 q) Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_ord.g2 b0 NB DEC_ord.eN) DEC_ord.m1 Host.Load.Run.Tpl.DEC_ord.s8 Host.Load.Run.Tpl.DEC_ord.S8 i x0)
    c6 := (fun i x0 => bdCut b0 NB DEC_ord.Pw DEC_ord.fr DEC_ord.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_ord.s0 q) Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_ord.g3 b0 NB DEC_ord.eN) DEC_ord.m1 Host.Load.Run.Tpl.DEC_ord.s10 Host.Load.Run.Tpl.DEC_ord.S10 i x0)
    start := startLinkBounded [] (by decide +kernel) rfl rfl (DEC_ord.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    rb__start__g1 := callLink Host.Load.Run.Tpl.DEC_ord.st0.tpl Host.Load.Run.Tpl.DEC_ord.st0.O hW DEC_ord.chk0 Host.Load.Run.Tpl.DEC_ord.srvO0 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_ord.iso0) (htab := Host.Load.Run.Tpl.DEC_ord.tab0_0) (hfoot := Host.Load.Run.Tpl.DEC_ord.stFoot0) (hnd := Host.Load.Run.Tpl.DEC_ord.wrNodup0)
      (hbd := Host.Load.Run.Tpl.DEC_ord.wrBound0) (htr := Host.Load.Run.Tpl.DEC_ord.trace0) (hmer := fun _ => Host.Load.Run.Tpl.DEC_ord.merged0) (hmtab := Host.Load.Run.Tpl.DEC_ord.mergeTab0)
      (hwsl := DEC_ord.wsl0) (hwsnd := (Template.nodupT_sound DEC_ord.wsnd0).2) (hfresh := noVar_of_all DEC_ord.fresh0)
      (hlen := Nat.le_of_ble_eq_true DEC_ord.len0) (hgtab := noVar_nth_of_all DEC_ord.gtab0)
      (hgθ := noVarθ_nth_of_all DEC_ord.gth0)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_ord.st0.tpl Host.Load.Run.Tpl.DEC_ord.iso0 Host.Load.Run.Tpl.DEC_ord.stFoot0 Host.Load.Run.Tpl.DEC_ord.wrNodup0 Host.Load.Run.Tpl.DEC_ord.wrBound0 Host.Load.Run.Tpl.DEC_ord.trace0)
      (hctab := Host.Load.Run.Tpl.DEC_ord.ctab0) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_ord.cwsDisj0) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_ord.ctab0 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_ord.zkap0
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_ord.jcl0) Host.Load.Run.Tpl.DEC_ord.cfix0 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_ord.zpl0 Host.Load.Run.Tpl.DEC_ord.zplnd0 Host.Load.Run.Tpl.DEC_ord.zn10 Host.Load.Run.Tpl.DEC_ord.zfirst0 Host.Load.Run.Tpl.DEC_ord.zscn0 Host.Load.Run.Tpl.DEC_ord.zsmn0 Host.Load.Run.Tpl.DEC_ord.zgrow0 Host.Load.Run.Tpl.DEC_ord.mergeTab0
        Host.Load.Run.Tpl.DEC_ord.zfresh0 Host.Load.Run.Tpl.DEC_ord.zcnd0 DEC_ord.lenc0 Host.Load.Run.Tpl.DEC_ord.znrHi0 Host.Load.Run.Tpl.DEC_ord.znC0 Host.Load.Run.Tpl.DEC_ord.zfrlt0 xs_wideP wfr_wideP (hX_framesP DEC_ord.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg0_2673448, Host.Load.Run.Tpl.DEC_ord.zk0_2673448, Host.Load.Run.Tpl.DEC_ord.zm0_2673448⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg0_12504, Host.Load.Run.Tpl.DEC_ord.zk0_12504, Host.Load.Run.Tpl.DEC_ord.zm0_12504⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg0_2665, Host.Load.Run.Tpl.DEC_ord.zk0_2665, Host.Load.Run.Tpl.DEC_ord.zm0_2665⟩)
        (wp_present Host.Load.Run.Tpl.DEC_ord.zw0_4910) wf_wideP Host.Load.Run.Tpl.DEC_ord.zclbd0 Host.Load.Run.Tpl.DEC_ord.cheap0
        (hoff_of Host.Load.Run.Tpl.DEC_ord.mheap0 Host.Load.Run.Tpl.DEC_ord.stFoot0 Host.Load.Run.Tpl.DEC_ord.iso0 Host.Load.Run.Tpl.DEC_ord.zwr0) Host.Load.Run.Tpl.DEC_ord.ckeepP0 Host.Load.Run.Tpl.DEC_ord.csupp0 Host.Load.Run.Tpl.DEC_ord.cbound0 Host.Load.Run.Tpl.DEC_ord.zimg0
        Host.Load.Run.Tpl.DEC_ord.zctl0 Host.Load.Run.Tpl.DEC_ord.zstack0 Host.Load.Run.Tpl.DEC_ord.zjobs0 Host.Load.Run.Tpl.DEC_ord.zstores0 Host.Load.Run.Tpl.DEC_ord.zroots0 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_ord.cshiftR0 h rfl)
      (hbig := DEC_ord.big0) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_ord.jcl2)
        (Nat.le_of_ble_eq_true DEC_ord.xn0) (by decide) Host.Load.Run.Tpl.DEC_ord.zroots20)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_ord.bandLo0) (Nat.le_of_ble_eq_true DEC_ord.bandHi) (by decide))
      (hκn := compact_num_of DEC_ord.kn0) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_ord.kappa0 (compact_fix_of DEC_ord.ka0) DEC.FixedCells.ord_kappa0_2586 DEC.FixedCells.ord_kappa0_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_ord.cfix0 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_ord.zhm0))
      (hfwd := Host.Load.Run.Tpl.DEC_ord.arr0_2673448) (hemit := Host.Load.Run.Tpl.DEC_ord.arr0_12504) (hkeep := Host.Load.Run.Tpl.DEC_ord.keep0 q)
      (heN := Host.Load.Run.Tpl.DEC_ord.arrR0_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_ord.cJm0) (hJc := Nat.le_of_ble_eq_true DEC_ord.cJc0)
      (hH := Nat.le_of_ble_eq_true DEC_ord.cHm0) (hHE := Nat.blt_eq.mp DEC_ord.cHE0)
      (hN := Nat.le_of_ble_eq_true DEC_ord.cNm0) (hm0 := m0_of_all DEC_ord.m0_0) (hndc := (Template.nodupT_sound DEC_ord.ndc0).2)
      (hlenc := DEC_ord.lenc0) (hnrLo := DEC_ord.nrLo0) (hder := rfl)
      (qs := DEC_ord.qs0) (hlq := DEC_ord.lq0) (hEs := hEs_of_all (by decide) DEC_ord.dq0)
      (hq := qs_le DEC_ord.qsOk0) (hR' := sub_of_all DEC_ord.R'0)
      (dJ := 148175) (dH := 3771) (dN := 4754) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_ord.cRJ0) (hcH := Nat.le_of_ble_eq_true DEC_ord.cRH0)
      (hcN := Nat.le_of_ble_eq_true DEC_ord.cRN0) (hs0E := Nat.le_of_ble_eq_true DEC_ord.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_ord.scE0) (hs0N := Nat.le_of_ble_eq_true DEC_ord.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_ord.scN0)
    g1 := glueLinkCall (List.drop 0 Host.Load.Run.Tpl.DEC_ord.O) hW DEC_ord.chk_g1 DEC_ord.srv2 DEC_ord.ok2 R.runSeg1
      (runOk_ok_end 899 R.runSeg1 DEC_ord.halt3) DEC_ord.halt3 R.stepA2 DEC_ord.top4
      (Nat.le_of_ble_eq_true DEC_ord.len2) (fun _ h => h) Gw.g1
    fwd_D1_warm_DFit__g1__g2 := callLink Host.Load.Run.Tpl.DEC_ord.st1.tpl Host.Load.Run.Tpl.DEC_ord.st1.O hW DEC_ord.chk1 Host.Load.Run.Tpl.DEC_ord.srvO1 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_ord.iso1) (htab := Host.Load.Run.Tpl.DEC_ord.tab0_1) (hfoot := Host.Load.Run.Tpl.DEC_ord.stFoot1) (hnd := Host.Load.Run.Tpl.DEC_ord.wrNodup1)
      (hbd := Host.Load.Run.Tpl.DEC_ord.wrBound1) (htr := Host.Load.Run.Tpl.DEC_ord.trace1) (hmer := fun _ => Host.Load.Run.Tpl.DEC_ord.merged1) (hmtab := Host.Load.Run.Tpl.DEC_ord.mergeTab1)
      (hwsl := DEC_ord.wsl1) (hwsnd := (Template.nodupT_sound DEC_ord.wsnd1).2) (hfresh := noVar_of_all DEC_ord.fresh1)
      (hlen := Nat.le_of_ble_eq_true DEC_ord.len4) (hgtab := noVar_nth_of_all DEC_ord.gtab1)
      (hgθ := noVarθ_nth_of_all DEC_ord.gth1)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_ord.st1.tpl Host.Load.Run.Tpl.DEC_ord.iso1 Host.Load.Run.Tpl.DEC_ord.stFoot1 Host.Load.Run.Tpl.DEC_ord.wrNodup1 Host.Load.Run.Tpl.DEC_ord.wrBound1 Host.Load.Run.Tpl.DEC_ord.trace1)
      (hctab := Host.Load.Run.Tpl.DEC_ord.ctab1) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_ord.cwsDisj1) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_ord.ctab1 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_ord.zkap1
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_ord.jcl4) Host.Load.Run.Tpl.DEC_ord.cfix1 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_ord.zpl1 Host.Load.Run.Tpl.DEC_ord.zplnd1 Host.Load.Run.Tpl.DEC_ord.zn11 Host.Load.Run.Tpl.DEC_ord.zfirst1 Host.Load.Run.Tpl.DEC_ord.zscn1 Host.Load.Run.Tpl.DEC_ord.zsmn1 Host.Load.Run.Tpl.DEC_ord.zgrow1 Host.Load.Run.Tpl.DEC_ord.mergeTab1
        Host.Load.Run.Tpl.DEC_ord.zfresh1 Host.Load.Run.Tpl.DEC_ord.zcnd1 DEC_ord.lenc1 Host.Load.Run.Tpl.DEC_ord.znrHi1 Host.Load.Run.Tpl.DEC_ord.znC1 Host.Load.Run.Tpl.DEC_ord.zfrlt1 xs_wideP wfr_wideP (hX_framesP DEC_ord.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg1_2673448, Host.Load.Run.Tpl.DEC_ord.zk1_2673448, Host.Load.Run.Tpl.DEC_ord.zm1_2673448⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg1_12504, Host.Load.Run.Tpl.DEC_ord.zk1_12504, Host.Load.Run.Tpl.DEC_ord.zm1_12504⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg1_2665, Host.Load.Run.Tpl.DEC_ord.zk1_2665, Host.Load.Run.Tpl.DEC_ord.zm1_2665⟩)
        (wp_present Host.Load.Run.Tpl.DEC_ord.zw1_4910) wf_wideP Host.Load.Run.Tpl.DEC_ord.zclbd1 Host.Load.Run.Tpl.DEC_ord.cheap1
        (hoff_of Host.Load.Run.Tpl.DEC_ord.mheap1 Host.Load.Run.Tpl.DEC_ord.stFoot1 Host.Load.Run.Tpl.DEC_ord.iso1 Host.Load.Run.Tpl.DEC_ord.zwr1) Host.Load.Run.Tpl.DEC_ord.ckeepP1 Host.Load.Run.Tpl.DEC_ord.csupp1 Host.Load.Run.Tpl.DEC_ord.cbound1 Host.Load.Run.Tpl.DEC_ord.zimg1
        Host.Load.Run.Tpl.DEC_ord.zctl1 Host.Load.Run.Tpl.DEC_ord.zstack1 Host.Load.Run.Tpl.DEC_ord.zjobs1 Host.Load.Run.Tpl.DEC_ord.zstores1 Host.Load.Run.Tpl.DEC_ord.zroots1 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_ord.cshiftR1 h rfl)
      (hbig := DEC_ord.big1) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_ord.jcl6)
        (Nat.le_of_ble_eq_true DEC_ord.xn1) (by decide) Host.Load.Run.Tpl.DEC_ord.zroots21)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_ord.bandLo1) (Nat.le_of_ble_eq_true DEC_ord.bandHi) (by decide))
      (hκn := compact_num_of DEC_ord.kn1) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_ord.kappa1 (compact_fix_of DEC_ord.ka1) DEC.FixedCells.ord_kappa1_2586 DEC.FixedCells.ord_kappa1_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_ord.cfix1 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_ord.zhm1))
      (hfwd := Host.Load.Run.Tpl.DEC_ord.arr1_2673448) (hemit := Host.Load.Run.Tpl.DEC_ord.arr1_12504) (hkeep := Host.Load.Run.Tpl.DEC_ord.keep1 q)
      (heN := Host.Load.Run.Tpl.DEC_ord.arrR1_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_ord.cJm1) (hJc := Nat.le_of_ble_eq_true DEC_ord.cJc1)
      (hH := Nat.le_of_ble_eq_true DEC_ord.cHm1) (hHE := Nat.blt_eq.mp DEC_ord.cHE1)
      (hN := Nat.le_of_ble_eq_true DEC_ord.cNm1) (hm0 := m0_of_all DEC_ord.m0_1) (hndc := (Template.nodupT_sound DEC_ord.ndc1).2)
      (hlenc := DEC_ord.lenc1) (hnrLo := DEC_ord.nrLo1) (hder := rfl)
      (qs := DEC_ord.qs1) (hlq := DEC_ord.lq1) (hEs := hEs_of_all (by decide) DEC_ord.dq1)
      (hq := qs_le DEC_ord.qsOk1) (hR' := sub_of_all DEC_ord.R'1)
      (dJ := 148175) (dH := 3771) (dN := 4754) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_ord.cRJ1) (hcH := Nat.le_of_ble_eq_true DEC_ord.cRH1)
      (hcN := Nat.le_of_ble_eq_true DEC_ord.cRN1) (hs0E := Nat.le_of_ble_eq_true DEC_ord.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_ord.scE1) (hs0N := Nat.le_of_ble_eq_true DEC_ord.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_ord.scN1)
    g2 := glueLinkCall (List.drop 5 Host.Load.Run.Tpl.DEC_ord.O) hW DEC_ord.chk_g2 DEC_ord.srv6 DEC_ord.ok6 R.runSeg2
      (runOk_ok_end 3657 R.runSeg2 DEC_ord.halt7) DEC_ord.halt7 R.stepA3 DEC_ord.top8
      (Nat.le_of_ble_eq_true DEC_ord.len6) (fun _ h => h) Gw.g2
    async__g2__g3 := callLink Host.Load.Run.Tpl.DEC_ord.st2.tpl Host.Load.Run.Tpl.DEC_ord.st2.O hW DEC_ord.chk2 Host.Load.Run.Tpl.DEC_ord.srvO2 (by decide +kernel)
      (hs0 := Host.Load.Run.Tpl.DEC_ord.iso2) (htab := Host.Load.Run.Tpl.DEC_ord.tab0_2) (hfoot := Host.Load.Run.Tpl.DEC_ord.stFoot2) (hnd := Host.Load.Run.Tpl.DEC_ord.wrNodup2)
      (hbd := Host.Load.Run.Tpl.DEC_ord.wrBound2) (htr := Host.Load.Run.Tpl.DEC_ord.trace2) (hmer := fun _ => Host.Load.Run.Tpl.DEC_ord.merged2) (hmtab := Host.Load.Run.Tpl.DEC_ord.mergeTab2)
      (hwsl := DEC_ord.wsl2) (hwsnd := (Template.nodupT_sound DEC_ord.wsnd2).2) (hfresh := noVar_of_all DEC_ord.fresh2)
      (hlen := Nat.le_of_ble_eq_true DEC_ord.len8) (hgtab := noVar_nth_of_all DEC_ord.gtab2)
      (hgθ := noVarθ_nth_of_all DEC_ord.gth2)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_ord.st2.tpl Host.Load.Run.Tpl.DEC_ord.iso2 Host.Load.Run.Tpl.DEC_ord.stFoot2 Host.Load.Run.Tpl.DEC_ord.wrNodup2 Host.Load.Run.Tpl.DEC_ord.wrBound2 Host.Load.Run.Tpl.DEC_ord.trace2)
      (hctab := Host.Load.Run.Tpl.DEC_ord.ctab2) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_ord.cwsDisj2) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_ord.ctab2 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_ord.zkap2
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_ord.jcl8) Host.Load.Run.Tpl.DEC_ord.cfix2 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_ord.zpl2 Host.Load.Run.Tpl.DEC_ord.zplnd2 Host.Load.Run.Tpl.DEC_ord.zn12 Host.Load.Run.Tpl.DEC_ord.zfirst2 Host.Load.Run.Tpl.DEC_ord.zscn2 Host.Load.Run.Tpl.DEC_ord.zsmn2 Host.Load.Run.Tpl.DEC_ord.zgrow2 Host.Load.Run.Tpl.DEC_ord.mergeTab2
        Host.Load.Run.Tpl.DEC_ord.zfresh2 Host.Load.Run.Tpl.DEC_ord.zcnd2 DEC_ord.lenc2 Host.Load.Run.Tpl.DEC_ord.znrHi2 Host.Load.Run.Tpl.DEC_ord.znC2 Host.Load.Run.Tpl.DEC_ord.zfrlt2 xs_wideP wfr_wideP (hX_framesP DEC_ord.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg2_2673448, Host.Load.Run.Tpl.DEC_ord.zk2_2673448, Host.Load.Run.Tpl.DEC_ord.zm2_2673448⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg2_12504, Host.Load.Run.Tpl.DEC_ord.zk2_12504, Host.Load.Run.Tpl.DEC_ord.zm2_12504⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_ord.zg2_2665, Host.Load.Run.Tpl.DEC_ord.zk2_2665, Host.Load.Run.Tpl.DEC_ord.zm2_2665⟩)
        (wp_present Host.Load.Run.Tpl.DEC_ord.zw2_4910) wf_wideP Host.Load.Run.Tpl.DEC_ord.zclbd2 Host.Load.Run.Tpl.DEC_ord.cheap2
        (hoff_of Host.Load.Run.Tpl.DEC_ord.mheap2 Host.Load.Run.Tpl.DEC_ord.stFoot2 Host.Load.Run.Tpl.DEC_ord.iso2 Host.Load.Run.Tpl.DEC_ord.zwr2) Host.Load.Run.Tpl.DEC_ord.ckeepP2 Host.Load.Run.Tpl.DEC_ord.csupp2 Host.Load.Run.Tpl.DEC_ord.cbound2 Host.Load.Run.Tpl.DEC_ord.zimg2
        Host.Load.Run.Tpl.DEC_ord.zctl2 Host.Load.Run.Tpl.DEC_ord.zstack2 Host.Load.Run.Tpl.DEC_ord.zjobs2 Host.Load.Run.Tpl.DEC_ord.zstores2 Host.Load.Run.Tpl.DEC_ord.zroots2 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_ord.cshiftR2 h rfl)
      (hbig := DEC_ord.big2) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_ord.jcl10)
        (Nat.le_of_ble_eq_true DEC_ord.xn2) (by decide) Host.Load.Run.Tpl.DEC_ord.zroots22)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_ord.bandLo2) (Nat.le_of_ble_eq_true DEC_ord.bandHi) (by decide))
      (hκn := compact_num_of DEC_ord.kn2) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_ord.kappa2 (compact_fix_of DEC_ord.ka2) DEC.FixedCells.ord_kappa2_2586 DEC.FixedCells.ord_kappa2_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_ord.cfix2 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_ord.zhm2))
      (hfwd := Host.Load.Run.Tpl.DEC_ord.arr2_2673448) (hemit := Host.Load.Run.Tpl.DEC_ord.arr2_12504) (hkeep := Host.Load.Run.Tpl.DEC_ord.keep2 q)
      (heN := Host.Load.Run.Tpl.DEC_ord.arrR2_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_ord.cJm2) (hJc := Nat.le_of_ble_eq_true DEC_ord.cJc2)
      (hH := Nat.le_of_ble_eq_true DEC_ord.cHm2) (hHE := Nat.blt_eq.mp DEC_ord.cHE2)
      (hN := Nat.le_of_ble_eq_true DEC_ord.cNm2) (hm0 := m0_of_all DEC_ord.m0_2) (hndc := (Template.nodupT_sound DEC_ord.ndc2).2)
      (hlenc := DEC_ord.lenc2) (hnrLo := DEC_ord.nrLo2) (hder := rfl)
      (qs := DEC_ord.qs2) (hlq := DEC_ord.lq2) (hEs := hEs_of_all (by decide) DEC_ord.dq2)
      (hq := qs_le DEC_ord.qsOk2) (hR' := sub_of_all DEC_ord.R'2)
      (dJ := 148175) (dH := 3771) (dN := 4754) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_ord.cRJ2) (hcH := Nat.le_of_ble_eq_true DEC_ord.cRH2)
      (hcN := Nat.le_of_ble_eq_true DEC_ord.cRN2) (hs0E := Nat.le_of_ble_eq_true DEC_ord.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_ord.scE2) (hs0N := Nat.le_of_ble_eq_true DEC_ord.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_ord.scN2)
    g3 := glueLinkEndD (List.drop 5 Host.Load.Run.Tpl.DEC_ord.O) hW DEC_ord.chk_g3 DEC_ord.srv10 DEC_ord.ok10 R.runSeg3
      DEC_ord.top11 Host.Load.Run.Tpl.DEC_ord.dvs Host.Load.Run.Tpl.DEC_ord.des (e := DEC_ord.endFixed b0 NB) rfl DEC_ord.hS1D
      (hde_of_dec DEC_ord.hvsB (by decide))
      (Nat.le_of_ble_eq_true DEC_ord.len10) Gw.g3
  }

/-- **Decode case `ord` from chain `DEC_ord`** (`IterCaseW`) at the prompt route's instance, A4's end facts
(`DEC_ord.iterEnd`, `DEC_ord.shiftFW`, `DEC_ord.keep`). -/
noncomputable def DEC_ord.caseFixed (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : 148175 ≤ ΔJ) (hH : 3771 ≤ ΔH) (hN : 4754 ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).next + T * ΔH + B.H + (DEC_ord.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).nnext + T * ΔN + B.N + (DEC_ord.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).nnext) < 2 ^ 62) :
    IterCaseW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_ord.Pw (Template.framesP Host.Load.Run.Tpl.DEC_ord.s0 q) Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .ord) where
  e := DEC_ord.endFixed b0 NB
  g := DEC_ord.g3 b0 NB DEC_ord.eN
  chain := (DEC_ord.piecesFixed (E0 := E0) (B := B) q DEC_ord.runs hVB hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := Host.Load.Run.Tpl.DEC_ord.shiftFW NB q
  keep := Host.Load.Run.Tpl.DEC_ord.keep q
  emit := DEC_ord.emitTok b0 NB
  within := DEC_ord.within (e := DEC_ord.endFixed b0 NB) DEC_ord.eN rfl hJ hH hN

end

end Host.Ts.Sim.Compose
