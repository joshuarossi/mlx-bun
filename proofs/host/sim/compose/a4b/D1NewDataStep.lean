import host.sim.compose.a4b.D1NewDataFacts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split.ND
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
theorem step {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Host.Ts.Sim.Ctx} {t : St FF.S} {C : CSrv} {bs : List Byte}
    (h : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW bs) [] M ν K D1StageSplit.s15 ⟨D1StageSplit.S15.tab, []⟩ t C)
    (hkp : Disp.KpJ (D1Frames.typedJ bs) 4096 K) (hv : VBOkF loopVB ν)
    (hg : Good ν D1StageSplit.S15.oracle) (hi : (bridgeOf D1StageSplit.s15.ffi).active = false)
    (hfb : K.fr D1Frames.buffer = some ([], [])) :
    ∃ M' t' C', runC FF 1 t C = some (t', C') ∧ Ext M M' D1StageSplit.S15.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
        (D1Frames.typedW bs) [] M' ν
        ⟨K.fr, D1StageSplit.s16.trace, t'.trace, K.D, K.lo, K.hi⟩
        D1StageSplit.s16 ⟨D1StageSplit.S16.tab, []⟩ t' C' ∧
      ∃ asR ret, t'.trace = ⟨chars!"mlx_array_new_data", .jsPtr (M.a D1Frames.buffer) 0 bs :: asR, ret⟩ :: t.trace := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hs : RelB FF (Disp.FRJ (FullRXD P NB)) (D1Frames.typedW bs) [] M ν K
      D1StageSplit.s15 D1StageSplit.S15 t C := h.withOracle hg
  have hsig : K.fr sig = none := by
    by_contra hn
    have hm := (hkp.1.2.2 sig).mp hn
    have hc : [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view].contains sig = true :=
      List.contains_iff_mem.mpr hm
    rw [sigUnframed] at hc
    cases hc
  have hbuf : ∀ v ∈ ndRest, BufSim.ArgBufOK FF K (D1Frames.typedW bs) D1StageSplit.s15 D1StageSplit.S15.tab.length v :=
    fun v hv => hkp.1.argBuf (D1Frames.typed_wp bs) (Disp.allB_sound (congrFun ndBuffers bs) v hv)
  have hok : G.dataOk P (mlxOf D1StageSplit.s15.ffi) ndArgs = true :=
    (D1Pre.dataOk_rest setupP (machReads T tk) (mlxOf D1StageSplit.s15.ffi) ndArgs).trans ndOk
  have hsmall : ∀ j ∈ G.dataRefs ndArgs, RefSmall ν ndSrv j :=
    D1Pre.small hv ndSmall
  have hpre : ∀ asR S1, interpS (decodeArgs FF D1StageSplit.s15 ndTys ndRest).run D1StageSplit.S15 =
      some (some asR, S1) → D1Data.Pre P ν S1 D1StageSplit.s15.ffi asR := by
    exact D1Decode.transport ndDecode
      (show D1Data.Pre P ν ndSrv D1StageSplit.s15.ffi ndArgs from
        ⟨hi, hok, hsmall⟩)
  have hc := Disp.bridge_newdata (fsym := sym) (ta := sig) (b := D1Frames.buffer)
    (fo := Host.Ts.Sim.Template.objOf D1StageSplit.s15 sym) (oa := Host.Ts.Sim.Template.objOf D1StageSplit.s15 sig)
    (bsT := []) (bs' := bs) hs (D1Data.laws P NB) (D1Data.ffi P NB)
    ctl fo kind signature types (by decide) hsig hfb (by rfl) hbuf (bools K) hpre
    (D1Data.dataCallSim P NB (by decide) (by decide) (by decide) D1Frames.buffer bs (Present D1StageSplit.s15))
  obtain ⟨M', t', C', hr, hgrow, hrel, hevent⟩ := hc.run D1StageSplit.s16 D1StageSplit.S16 sourceRun
  exact ⟨M', t', C', runC_one (by rw [hs.isHalt, ctl]; rfl) hr, hgrow.ext,
    hrel.withOracle (fun _ h => nomatch h), hevent⟩

end Host.Ts.Sim.Compose.D1Split.ND
