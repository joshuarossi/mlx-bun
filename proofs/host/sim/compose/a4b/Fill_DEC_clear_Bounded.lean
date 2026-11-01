import host.sim.compose.a4b.Fill_DEC_clear
import host.sim.compose.StartBounded

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

/-- **Decode case `clear`'s pieces from chain `DEC_clear`** at the prompt route's instance (`addrPrompt`, `wideP`, the
frames `framesP DEC_clear.s0 q`, `fixP`), A4's end (`DEC_clear.iterEnd`). -/
noncomputable def DEC_clear.piecesBounded (q : List Val) (R : DEC_clear.Runs)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (hdJ : 148176 ≤ ΔJ) (hdH : 3771 ≤ ΔH) (hdN : 4754 ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).next + T * ΔH + B.H + (DEC_clear.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).nnext + T * ΔN + B.N + (DEC_clear.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).nnext) < 2 ^ 62) :
    DecPieces_DEC_clear (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_clear.Pw (Template.framesP Host.Load.Run.Tpl.DEC_clear.s0 q) Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab Template.fixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      L T ((Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0) (DEC_clear.g3 b0 NB DEC_clear.eN) :=
  let θ := Host.Load.Run.Tpl.DEC_clear.θ
  let hW := DEC_clear.hW
  let Gw : DEC_clear.Grow b0 NB Template.wideP := DEC_clear.grow R hW
  { c1 := (fun i x0 => bdCut b0 NB DEC_clear.Pw DEC_clear.fr DEC_clear.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clear.s0 q) Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) Host.Load.Run.Tpl.DEC_clear.s0) DEC_clear.m0 Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0 i x0)
    c2 := (fun i x0 => bdCut b0 NB DEC_clear.Pw DEC_clear.fr DEC_clear.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clear.s0 q) Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clear.g1 b0 NB DEC_clear.eN) DEC_clear.m0 Host.Load.Run.Tpl.DEC_clear.s2 Host.Load.Run.Tpl.DEC_clear.S2 i x0)
    c3 := (fun i x0 => bdCut b0 NB DEC_clear.Pw DEC_clear.fr DEC_clear.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clear.s0 q) Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clear.g1 b0 NB DEC_clear.eN) DEC_clear.m0 Host.Load.Run.Tpl.DEC_clear.s4 Host.Load.Run.Tpl.DEC_clear.S4 i x0)
    c4 := (fun i x0 => bdCut b0 NB DEC_clear.Pw DEC_clear.fr DEC_clear.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clear.s0 q) Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clear.g2 b0 NB DEC_clear.eN) DEC_clear.m1 Host.Load.Run.Tpl.DEC_clear.s6 Host.Load.Run.Tpl.DEC_clear.S6 i x0)
    c5 := (fun i x0 => bdCut b0 NB DEC_clear.Pw DEC_clear.fr DEC_clear.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clear.s0 q) Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clear.g2 b0 NB DEC_clear.eN) DEC_clear.m1 Host.Load.Run.Tpl.DEC_clear.s8 Host.Load.Run.Tpl.DEC_clear.S8 i x0)
    c6 := (fun i x0 => bdCut b0 NB DEC_clear.Pw DEC_clear.fr DEC_clear.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clear.s0 q) Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clear.g3 b0 NB DEC_clear.eN) DEC_clear.m1 Host.Load.Run.Tpl.DEC_clear.s10 Host.Load.Run.Tpl.DEC_clear.S10 i x0)
    start := startLinkBounded [] (by decide +kernel) rfl rfl (DEC_clear.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    rb__start__g1 := callLink Host.Load.Run.Tpl.DEC_clear.st0.tpl Host.Load.Run.Tpl.DEC_clear.st0.O hW DEC_clear.chk0 Host.Load.Run.Tpl.DEC_clear.srvO0 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_clear.iso0) (htab := Host.Load.Run.Tpl.DEC_clear.tab0_0) (hfoot := Host.Load.Run.Tpl.DEC_clear.stFoot0) (hnd := Host.Load.Run.Tpl.DEC_clear.wrNodup0)
      (hbd := Host.Load.Run.Tpl.DEC_clear.wrBound0) (htr := Host.Load.Run.Tpl.DEC_clear.trace0) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clear.merged0) (hmtab := Host.Load.Run.Tpl.DEC_clear.mergeTab0)
      (hwsl := DEC_clear.wsl0) (hwsnd := (Template.nodupT_sound DEC_clear.wsnd0).2) (hfresh := noVar_of_all DEC_clear.fresh0)
      (hlen := Nat.le_of_ble_eq_true DEC_clear.len0) (hgtab := noVar_nth_of_all DEC_clear.gtab0)
      (hgθ := noVarθ_nth_of_all DEC_clear.gth0)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clear.st0.tpl Host.Load.Run.Tpl.DEC_clear.iso0 Host.Load.Run.Tpl.DEC_clear.stFoot0 Host.Load.Run.Tpl.DEC_clear.wrNodup0 Host.Load.Run.Tpl.DEC_clear.wrBound0 Host.Load.Run.Tpl.DEC_clear.trace0)
      (hctab := Host.Load.Run.Tpl.DEC_clear.ctab0) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clear.cwsDisj0) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clear.ctab0 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clear.zkap0
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clear.jcl0) Host.Load.Run.Tpl.DEC_clear.cfix0 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clear.zpl0 Host.Load.Run.Tpl.DEC_clear.zplnd0 Host.Load.Run.Tpl.DEC_clear.zn10 Host.Load.Run.Tpl.DEC_clear.zfirst0 Host.Load.Run.Tpl.DEC_clear.zscn0 Host.Load.Run.Tpl.DEC_clear.zsmn0 Host.Load.Run.Tpl.DEC_clear.zgrow0 Host.Load.Run.Tpl.DEC_clear.mergeTab0
        Host.Load.Run.Tpl.DEC_clear.zfresh0 Host.Load.Run.Tpl.DEC_clear.zcnd0 DEC_clear.lenc0 Host.Load.Run.Tpl.DEC_clear.znrHi0 Host.Load.Run.Tpl.DEC_clear.znC0 Host.Load.Run.Tpl.DEC_clear.zfrlt0 xs_wideP wfr_wideP (hX_framesP DEC_clear.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg0_2673448, Host.Load.Run.Tpl.DEC_clear.zk0_2673448, Host.Load.Run.Tpl.DEC_clear.zm0_2673448⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg0_12504, Host.Load.Run.Tpl.DEC_clear.zk0_12504, Host.Load.Run.Tpl.DEC_clear.zm0_12504⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg0_2665, Host.Load.Run.Tpl.DEC_clear.zk0_2665, Host.Load.Run.Tpl.DEC_clear.zm0_2665⟩)
        (wp_present Host.Load.Run.Tpl.DEC_clear.zw0_4910) wf_wideP Host.Load.Run.Tpl.DEC_clear.zclbd0 Host.Load.Run.Tpl.DEC_clear.cheap0
        (hoff_of Host.Load.Run.Tpl.DEC_clear.mheap0 Host.Load.Run.Tpl.DEC_clear.stFoot0 Host.Load.Run.Tpl.DEC_clear.iso0 Host.Load.Run.Tpl.DEC_clear.zwr0) Host.Load.Run.Tpl.DEC_clear.ckeepP0 Host.Load.Run.Tpl.DEC_clear.csupp0 Host.Load.Run.Tpl.DEC_clear.cbound0 Host.Load.Run.Tpl.DEC_clear.zimg0
        Host.Load.Run.Tpl.DEC_clear.zctl0 Host.Load.Run.Tpl.DEC_clear.zstack0 Host.Load.Run.Tpl.DEC_clear.zjobs0 Host.Load.Run.Tpl.DEC_clear.zstores0 Host.Load.Run.Tpl.DEC_clear.zroots0 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clear.cshiftR0 h rfl)
      (hbig := DEC_clear.big0) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clear.jcl2)
        (Nat.le_of_ble_eq_true DEC_clear.xn0) (by decide) Host.Load.Run.Tpl.DEC_clear.zroots20)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clear.bandLo0) (Nat.le_of_ble_eq_true DEC_clear.bandHi) (by decide))
      (hκn := compact_num_of DEC_clear.kn0) (hκa := compact_fix_of DEC_clear.ka0) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clear.cfix0 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clear.zhm0))
      (hfwd := Host.Load.Run.Tpl.DEC_clear.arr0_2673448) (hemit := Host.Load.Run.Tpl.DEC_clear.arr0_12504) (hkeep := Host.Load.Run.Tpl.DEC_clear.keep0 q)
      (heN := Host.Load.Run.Tpl.DEC_clear.arrR0_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clear.cJm0) (hJc := Nat.le_of_ble_eq_true DEC_clear.cJc0)
      (hH := Nat.le_of_ble_eq_true DEC_clear.cHm0) (hHE := Nat.blt_eq.mp DEC_clear.cHE0)
      (hN := Nat.le_of_ble_eq_true DEC_clear.cNm0) (hm0 := m0_of_all DEC_clear.m0_0) (hndc := (Template.nodupT_sound DEC_clear.ndc0).2)
      (hlenc := DEC_clear.lenc0) (hnrLo := DEC_clear.nrLo0) (hder := rfl)
      (qs := DEC_clear.qs0) (hlq := DEC_clear.lq0) (hEs := hEs_of_all (by decide) DEC_clear.dq0)
      (hq := qs_le DEC_clear.qsOk0) (hR' := sub_of_all DEC_clear.R'0)
      (dJ := 148176) (dH := 3771) (dN := 4754) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clear.cRJ0) (hcH := Nat.le_of_ble_eq_true DEC_clear.cRH0)
      (hcN := Nat.le_of_ble_eq_true DEC_clear.cRN0) (hs0E := Nat.le_of_ble_eq_true DEC_clear.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clear.scE0) (hs0N := Nat.le_of_ble_eq_true DEC_clear.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clear.scN0)
    g1 := glueLinkCall (List.drop 0 Host.Load.Run.Tpl.DEC_clear.O) hW DEC_clear.chk_g1 DEC_clear.srv2 DEC_clear.ok2 R.runSeg1
      (runOk_ok_end 915 R.runSeg1 DEC_clear.halt3) DEC_clear.halt3 R.stepA2 DEC_clear.top4
      (Nat.le_of_ble_eq_true DEC_clear.len2) (fun _ h => h) Gw.g1
    fwd_D1_warm_DFit__g1__g2 := callLink Host.Load.Run.Tpl.DEC_clear.st1.tpl Host.Load.Run.Tpl.DEC_clear.st1.O hW DEC_clear.chk1 Host.Load.Run.Tpl.DEC_clear.srvO1 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_clear.iso1) (htab := Host.Load.Run.Tpl.DEC_clear.tab0_1) (hfoot := Host.Load.Run.Tpl.DEC_clear.stFoot1) (hnd := Host.Load.Run.Tpl.DEC_clear.wrNodup1)
      (hbd := Host.Load.Run.Tpl.DEC_clear.wrBound1) (htr := Host.Load.Run.Tpl.DEC_clear.trace1) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clear.merged1) (hmtab := Host.Load.Run.Tpl.DEC_clear.mergeTab1)
      (hwsl := DEC_clear.wsl1) (hwsnd := (Template.nodupT_sound DEC_clear.wsnd1).2) (hfresh := noVar_of_all DEC_clear.fresh1)
      (hlen := Nat.le_of_ble_eq_true DEC_clear.len4) (hgtab := noVar_nth_of_all DEC_clear.gtab1)
      (hgθ := noVarθ_nth_of_all DEC_clear.gth1)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clear.st1.tpl Host.Load.Run.Tpl.DEC_clear.iso1 Host.Load.Run.Tpl.DEC_clear.stFoot1 Host.Load.Run.Tpl.DEC_clear.wrNodup1 Host.Load.Run.Tpl.DEC_clear.wrBound1 Host.Load.Run.Tpl.DEC_clear.trace1)
      (hctab := Host.Load.Run.Tpl.DEC_clear.ctab1) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clear.cwsDisj1) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clear.ctab1 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clear.zkap1
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clear.jcl4) Host.Load.Run.Tpl.DEC_clear.cfix1 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clear.zpl1 Host.Load.Run.Tpl.DEC_clear.zplnd1 Host.Load.Run.Tpl.DEC_clear.zn11 Host.Load.Run.Tpl.DEC_clear.zfirst1 Host.Load.Run.Tpl.DEC_clear.zscn1 Host.Load.Run.Tpl.DEC_clear.zsmn1 Host.Load.Run.Tpl.DEC_clear.zgrow1 Host.Load.Run.Tpl.DEC_clear.mergeTab1
        Host.Load.Run.Tpl.DEC_clear.zfresh1 Host.Load.Run.Tpl.DEC_clear.zcnd1 DEC_clear.lenc1 Host.Load.Run.Tpl.DEC_clear.znrHi1 Host.Load.Run.Tpl.DEC_clear.znC1 Host.Load.Run.Tpl.DEC_clear.zfrlt1 xs_wideP wfr_wideP (hX_framesP DEC_clear.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg1_2673448, Host.Load.Run.Tpl.DEC_clear.zk1_2673448, Host.Load.Run.Tpl.DEC_clear.zm1_2673448⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg1_12504, Host.Load.Run.Tpl.DEC_clear.zk1_12504, Host.Load.Run.Tpl.DEC_clear.zm1_12504⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg1_2665, Host.Load.Run.Tpl.DEC_clear.zk1_2665, Host.Load.Run.Tpl.DEC_clear.zm1_2665⟩)
        (wp_present Host.Load.Run.Tpl.DEC_clear.zw1_4910) wf_wideP Host.Load.Run.Tpl.DEC_clear.zclbd1 Host.Load.Run.Tpl.DEC_clear.cheap1
        (hoff_of Host.Load.Run.Tpl.DEC_clear.mheap1 Host.Load.Run.Tpl.DEC_clear.stFoot1 Host.Load.Run.Tpl.DEC_clear.iso1 Host.Load.Run.Tpl.DEC_clear.zwr1) Host.Load.Run.Tpl.DEC_clear.ckeepP1 Host.Load.Run.Tpl.DEC_clear.csupp1 Host.Load.Run.Tpl.DEC_clear.cbound1 Host.Load.Run.Tpl.DEC_clear.zimg1
        Host.Load.Run.Tpl.DEC_clear.zctl1 Host.Load.Run.Tpl.DEC_clear.zstack1 Host.Load.Run.Tpl.DEC_clear.zjobs1 Host.Load.Run.Tpl.DEC_clear.zstores1 Host.Load.Run.Tpl.DEC_clear.zroots1 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clear.cshiftR1 h rfl)
      (hbig := DEC_clear.big1) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clear.jcl6)
        (Nat.le_of_ble_eq_true DEC_clear.xn1) (by decide) Host.Load.Run.Tpl.DEC_clear.zroots21)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clear.bandLo1) (Nat.le_of_ble_eq_true DEC_clear.bandHi) (by decide))
      (hκn := compact_num_of DEC_clear.kn1) (hκa := compact_fix_of DEC_clear.ka1) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clear.cfix1 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clear.zhm1))
      (hfwd := Host.Load.Run.Tpl.DEC_clear.arr1_2673448) (hemit := Host.Load.Run.Tpl.DEC_clear.arr1_12504) (hkeep := Host.Load.Run.Tpl.DEC_clear.keep1 q)
      (heN := Host.Load.Run.Tpl.DEC_clear.arrR1_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clear.cJm1) (hJc := Nat.le_of_ble_eq_true DEC_clear.cJc1)
      (hH := Nat.le_of_ble_eq_true DEC_clear.cHm1) (hHE := Nat.blt_eq.mp DEC_clear.cHE1)
      (hN := Nat.le_of_ble_eq_true DEC_clear.cNm1) (hm0 := m0_of_all DEC_clear.m0_1) (hndc := (Template.nodupT_sound DEC_clear.ndc1).2)
      (hlenc := DEC_clear.lenc1) (hnrLo := DEC_clear.nrLo1) (hder := rfl)
      (qs := DEC_clear.qs1) (hlq := DEC_clear.lq1) (hEs := hEs_of_all (by decide) DEC_clear.dq1)
      (hq := qs_le DEC_clear.qsOk1) (hR' := sub_of_all DEC_clear.R'1)
      (dJ := 148176) (dH := 3771) (dN := 4754) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clear.cRJ1) (hcH := Nat.le_of_ble_eq_true DEC_clear.cRH1)
      (hcN := Nat.le_of_ble_eq_true DEC_clear.cRN1) (hs0E := Nat.le_of_ble_eq_true DEC_clear.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clear.scE1) (hs0N := Nat.le_of_ble_eq_true DEC_clear.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clear.scN1)
    g2 := glueLinkCall (List.drop 5 Host.Load.Run.Tpl.DEC_clear.O) hW DEC_clear.chk_g2 DEC_clear.srv6 DEC_clear.ok6 R.runSeg2
      (runOk_ok_end 3657 R.runSeg2 DEC_clear.halt7) DEC_clear.halt7 R.stepA3 DEC_clear.top8
      (Nat.le_of_ble_eq_true DEC_clear.len6) (fun _ h => h) Gw.g2
    async__g2__g3 := callLink Host.Load.Run.Tpl.DEC_clear.st2.tpl Host.Load.Run.Tpl.DEC_clear.st2.O hW DEC_clear.chk2 Host.Load.Run.Tpl.DEC_clear.srvO2 (by decide +kernel)
      (hs0 := Host.Load.Run.Tpl.DEC_clear.iso2) (htab := Host.Load.Run.Tpl.DEC_clear.tab0_2) (hfoot := Host.Load.Run.Tpl.DEC_clear.stFoot2) (hnd := Host.Load.Run.Tpl.DEC_clear.wrNodup2)
      (hbd := Host.Load.Run.Tpl.DEC_clear.wrBound2) (htr := Host.Load.Run.Tpl.DEC_clear.trace2) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clear.merged2) (hmtab := Host.Load.Run.Tpl.DEC_clear.mergeTab2)
      (hwsl := DEC_clear.wsl2) (hwsnd := (Template.nodupT_sound DEC_clear.wsnd2).2) (hfresh := noVar_of_all DEC_clear.fresh2)
      (hlen := Nat.le_of_ble_eq_true DEC_clear.len8) (hgtab := noVar_nth_of_all DEC_clear.gtab2)
      (hgθ := noVarθ_nth_of_all DEC_clear.gth2)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clear.st2.tpl Host.Load.Run.Tpl.DEC_clear.iso2 Host.Load.Run.Tpl.DEC_clear.stFoot2 Host.Load.Run.Tpl.DEC_clear.wrNodup2 Host.Load.Run.Tpl.DEC_clear.wrBound2 Host.Load.Run.Tpl.DEC_clear.trace2)
      (hctab := Host.Load.Run.Tpl.DEC_clear.ctab2) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clear.cwsDisj2) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clear.ctab2 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clear.zkap2
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clear.jcl8) Host.Load.Run.Tpl.DEC_clear.cfix2 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clear.zpl2 Host.Load.Run.Tpl.DEC_clear.zplnd2 Host.Load.Run.Tpl.DEC_clear.zn12 Host.Load.Run.Tpl.DEC_clear.zfirst2 Host.Load.Run.Tpl.DEC_clear.zscn2 Host.Load.Run.Tpl.DEC_clear.zsmn2 Host.Load.Run.Tpl.DEC_clear.zgrow2 Host.Load.Run.Tpl.DEC_clear.mergeTab2
        Host.Load.Run.Tpl.DEC_clear.zfresh2 Host.Load.Run.Tpl.DEC_clear.zcnd2 DEC_clear.lenc2 Host.Load.Run.Tpl.DEC_clear.znrHi2 Host.Load.Run.Tpl.DEC_clear.znC2 Host.Load.Run.Tpl.DEC_clear.zfrlt2 xs_wideP wfr_wideP (hX_framesP DEC_clear.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg2_2673448, Host.Load.Run.Tpl.DEC_clear.zk2_2673448, Host.Load.Run.Tpl.DEC_clear.zm2_2673448⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg2_12504, Host.Load.Run.Tpl.DEC_clear.zk2_12504, Host.Load.Run.Tpl.DEC_clear.zm2_12504⟩
          · exact ⟨Host.Load.Run.Tpl.DEC_clear.zg2_2665, Host.Load.Run.Tpl.DEC_clear.zk2_2665, Host.Load.Run.Tpl.DEC_clear.zm2_2665⟩)
        (wp_present Host.Load.Run.Tpl.DEC_clear.zw2_4910) wf_wideP Host.Load.Run.Tpl.DEC_clear.zclbd2 Host.Load.Run.Tpl.DEC_clear.cheap2
        (hoff_of Host.Load.Run.Tpl.DEC_clear.mheap2 Host.Load.Run.Tpl.DEC_clear.stFoot2 Host.Load.Run.Tpl.DEC_clear.iso2 Host.Load.Run.Tpl.DEC_clear.zwr2) Host.Load.Run.Tpl.DEC_clear.ckeepP2 Host.Load.Run.Tpl.DEC_clear.csupp2 Host.Load.Run.Tpl.DEC_clear.cbound2 Host.Load.Run.Tpl.DEC_clear.zimg2
        Host.Load.Run.Tpl.DEC_clear.zctl2 Host.Load.Run.Tpl.DEC_clear.zstack2 Host.Load.Run.Tpl.DEC_clear.zjobs2 Host.Load.Run.Tpl.DEC_clear.zstores2 Host.Load.Run.Tpl.DEC_clear.zroots2 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clear.cshiftR2 h rfl)
      (hbig := DEC_clear.big2) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clear.jcl10)
        (Nat.le_of_ble_eq_true DEC_clear.xn2) (by decide) Host.Load.Run.Tpl.DEC_clear.zroots22)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clear.bandLo2) (Nat.le_of_ble_eq_true DEC_clear.bandHi) (by decide))
      (hκn := compact_num_of DEC_clear.kn2) (hκa := compact_fix_of DEC_clear.ka2) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clear.cfix2 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clear.zhm2))
      (hfwd := Host.Load.Run.Tpl.DEC_clear.arr2_2673448) (hemit := Host.Load.Run.Tpl.DEC_clear.arr2_12504) (hkeep := Host.Load.Run.Tpl.DEC_clear.keep2 q)
      (heN := Host.Load.Run.Tpl.DEC_clear.arrR2_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clear.cJm2) (hJc := Nat.le_of_ble_eq_true DEC_clear.cJc2)
      (hH := Nat.le_of_ble_eq_true DEC_clear.cHm2) (hHE := Nat.blt_eq.mp DEC_clear.cHE2)
      (hN := Nat.le_of_ble_eq_true DEC_clear.cNm2) (hm0 := m0_of_all DEC_clear.m0_2) (hndc := (Template.nodupT_sound DEC_clear.ndc2).2)
      (hlenc := DEC_clear.lenc2) (hnrLo := DEC_clear.nrLo2) (hder := rfl)
      (qs := DEC_clear.qs2) (hlq := DEC_clear.lq2) (hEs := hEs_of_all (by decide) DEC_clear.dq2)
      (hq := qs_le DEC_clear.qsOk2) (hR' := sub_of_all DEC_clear.R'2)
      (dJ := 148176) (dH := 3771) (dN := 4754) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clear.cRJ2) (hcH := Nat.le_of_ble_eq_true DEC_clear.cRH2)
      (hcN := Nat.le_of_ble_eq_true DEC_clear.cRN2) (hs0E := Nat.le_of_ble_eq_true DEC_clear.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clear.scE2) (hs0N := Nat.le_of_ble_eq_true DEC_clear.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clear.scN2)
    g3 := glueLinkEndD (List.drop 5 Host.Load.Run.Tpl.DEC_clear.O) hW DEC_clear.chk_g3 DEC_clear.srv10 DEC_clear.ok10 R.runSeg3
      DEC_clear.top11 Host.Load.Run.Tpl.DEC_clear.dvs Host.Load.Run.Tpl.DEC_clear.des (e := (Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0) rfl DEC_clear.hS1D
      (hde_of_dec DEC_clear.hvsB (by decide))
      (Nat.le_of_ble_eq_true DEC_clear.len10) Gw.g3
  }

/-- **Decode case `clear` from chain `DEC_clear`** (`IterCaseW`) at the prompt route's instance, A4's end facts
(`DEC_clear.iterEnd`, `DEC_clear.shiftFW`, `DEC_clear.keep`). -/
noncomputable def DEC_clear.caseBounded (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : 148176 ≤ ΔJ) (hH : 3771 ≤ ΔH) (hN : 4754 ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).next + T * ΔH + B.H + (DEC_clear.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).nnext + T * ΔN + B.N + (DEC_clear.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).nnext) < 2 ^ 62) :
    IterCaseW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_clear.Pw (Template.framesP Host.Load.Run.Tpl.DEC_clear.s0 q) Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab Template.fixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .clear) where
  e := (Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0
  g := DEC_clear.g3 b0 NB DEC_clear.eN
  chain := (DEC_clear.piecesBounded (E0 := E0) (B := B) q DEC_clear.runs hVB hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := Host.Load.Run.Tpl.DEC_clear.shiftFW NB q
  keep := Host.Load.Run.Tpl.DEC_clear.keep q
  emit := DEC_clear.emitTok b0 NB
  within := DEC_clear.within (e := (Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0) DEC_clear.eN rfl hJ hH hN

end

end Host.Ts.Sim.Compose
