import host.sim.compose.a4b.fd_x4_L8.NewDataFacts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L8.ND
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
theorem step {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Host.Ts.Sim.Ctx} {t : St FF.S} {C : CSrv} {bs : List Byte} {n : Nat}
    (h : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDX4L8Frames.typedW bs n) [] M ν K PRE_fd_x4_L8_r0.s16 ⟨PRE_fd_x4_L8_r0.S16.tab, []⟩ t C)
    (hkp : Disp.KpJ (FDX4L8Frames.typedJ bs n) 131072 K) (hv : VBOkF loopVB ν)
    (hg : Good ν PRE_fd_x4_L8_r0.S16.oracle) (hi : (bridgeOf PRE_fd_x4_L8_r0.s16.ffi).active = false)
    (hfb : K.fr FDX4L8Frames.buffer = some ([], [])) :
    ∃ M' t' C', runC FF 1 t C = some (t', C') ∧ Ext M M' PRE_fd_x4_L8_r0.S16.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
        (FDX4L8Frames.typedW bs n) [] M' ν
        ⟨K.fr, PRE_fd_x4_L8_r0.s17.trace, t'.trace, K.D, K.lo, K.hi⟩
        PRE_fd_x4_L8_r0.s17 ⟨PRE_fd_x4_L8_r0.S17.tab, []⟩ t' C' ∧
      ∃ asR ret, t'.trace = ⟨chars!"mlx_array_new_data", .jsPtr (M.a FDX4L8Frames.buffer) 0 bs :: asR, ret⟩ :: t.trace := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hs : RelB FF (Disp.FRJ (FullRXD P NB)) (FDX4L8Frames.typedW bs n) [] M ν K
      PRE_fd_x4_L8_r0.s16 PRE_fd_x4_L8_r0.S16 t C := h.withOracle hg
  have hsig : K.fr sig = none := by
    by_contra hn
    have hm := (hkp.1.2.2 sig).mp hn
    have hc : (2665 :: 4910 :: (ghostPf ++ [FDX4L8Frames.chunk, FDX4L8Frames.buffer, FDX4L8Frames.view])).contains sig = true :=
      List.contains_iff_mem.mpr hm
    rw [sigUnframed] at hc
    cases hc
  have hbuf : ∀ v ∈ ndRest, BufSim.ArgBufOK FF K (FDX4L8Frames.typedW bs n) PRE_fd_x4_L8_r0.s16 PRE_fd_x4_L8_r0.S16.tab.length v :=
    fun v hv => hkp.1.argBuf (FDX4L8Frames.typed_wp bs n) (Disp.allB_sound (congrFun (congrFun ndBuffers bs) n) v hv)
  have hok : G.dataOk P (mlxOf PRE_fd_x4_L8_r0.s16.ffi) ndArgs = true :=
    (D1Pre.dataOk_rest setupP (machReads T tk) (mlxOf PRE_fd_x4_L8_r0.s16.ffi) ndArgs).trans ndOk
  have hsmall : ∀ j ∈ G.dataRefs ndArgs, RefSmall ν ndSrv j :=
    D1Pre.small hv ndSmall
  have hpre : ∀ asR S1, interpS (decodeArgs FF PRE_fd_x4_L8_r0.s16 ndTys ndRest).run PRE_fd_x4_L8_r0.S16 =
      some (some asR, S1) → D1Data.Pre P ν S1 PRE_fd_x4_L8_r0.s16.ffi asR := by
    exact D1Decode.transport ndDecode
      (show D1Data.Pre P ν ndSrv PRE_fd_x4_L8_r0.s16.ffi ndArgs from
        ⟨hi, hok, hsmall⟩)
  have hc := Disp.bridge_newdata (fsym := sym) (ta := sig) (b := FDX4L8Frames.buffer)
    (fo := Host.Ts.Sim.Template.objOf PRE_fd_x4_L8_r0.s16 sym) (oa := Host.Ts.Sim.Template.objOf PRE_fd_x4_L8_r0.s16 sig)
    (bsT := []) (bs' := bs) hs (D1Data.laws P NB) (D1Data.ffi P NB)
    ctl fo kind signature types (by decide) hsig hfb (by rfl) hbuf (bools K) hpre
    (D1Data.dataCallSim P NB (by decide) (by decide) (by decide) FDX4L8Frames.buffer bs (Present PRE_fd_x4_L8_r0.s16))
  obtain ⟨M', t', C', hr, hgrow, hrel, hevent⟩ := hc.run PRE_fd_x4_L8_r0.s17 PRE_fd_x4_L8_r0.S17 sourceRun
  exact ⟨M', t', C', runC_one (by rw [hs.isHalt, ctl]; rfl) hr, hgrow.ext,
    hrel.withOracle (fun _ h => nomatch h), hevent⟩

end Host.Ts.Sim.Compose.FDX4L8.ND
