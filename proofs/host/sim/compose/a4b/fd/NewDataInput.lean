import host.sim.compose.a4b.fd.InputNative
import host.sim.template.a4pre_d1_input.Bridge
import host.sim.full.TargetGrowD
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW.ND
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
private theorem dataOk_raise (P : LoadP) (k : Nat) (x : NSt) (args : List Arg) :
    G.dataOk (P.raise k) x args = G.dataOk P x args := rfl

theorem step_input {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Host.Ts.Sim.Ctx} {t : St FF.S} {C : CSrv} {π : List Nat}
    (h : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDFrames.typedW (tokenBytes π) π.length) [] M ν K PRE_fd_vw_r0.s16 ⟨PRE_fd_vw_r0.S16.tab, []⟩ t C)
    (hkp : Disp.KpJ (FDFrames.typedJ (tokenBytes π) π.length) 131072 K) (hv : VBOkF loopVB ν)
    (hg : Good ν PRE_fd_vw_r0.S16.oracle) (hi : (bridgeOf PRE_fd_vw_r0.s16.ffi).active = false)
    (hfb : K.fr FDFrames.buffer = some ([], []))
    (hvc : ∀ k ∈ π, k < 248320) (hlenN : π.length = 1) :
    ∃ M' t' C', runC FF 1 t C = some (t', C') ∧ Ext M M' PRE_fd_vw_r0.S16.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
        (FDFrames.typedW (tokenBytes π) π.length) [] M' ν
        ⟨K.fr, PRE_fd_vw_r0.s17.trace, t'.trace, K.D, K.lo, K.hi⟩
        PRE_fd_vw_r0.s17 ⟨PRE_fd_vw_r0.S17.tab, []⟩ t' C' ∧
      (∃ asR ret, t'.trace = ⟨chars!"mlx_array_new_data", .jsPtr (M.a FDFrames.buffer) 0 (tokenBytes π) :: asR, ret⟩ :: t.trace) ∧
      Host.Ts.Sim.Compose.FDVW.InputAt π (M'.node 15235) t' C' ∧ Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hs : RelB FF (Disp.FRJ (FullRXD P NB)) (FDFrames.typedW (tokenBytes π) π.length) [] M ν K
      PRE_fd_vw_r0.s16 PRE_fd_vw_r0.S16 t C := h.withOracle hg
  have hsig : K.fr sig = none := by
    by_contra hn
    have hm := (hkp.1.2.2 sig).mp hn
    have hc : [2665, FDFrames.chunk, FDFrames.buffer, FDFrames.view].contains sig = true :=
      List.contains_iff_mem.mpr hm
    rw [sigUnframed] at hc
    cases hc
  have hbuf : ∀ v ∈ ndRest, BufSim.ArgBufOK FF K (FDFrames.typedW (tokenBytes π) π.length) PRE_fd_vw_r0.s16 PRE_fd_vw_r0.S16.tab.length v :=
    fun v hv => hkp.1.argBuf (FDFrames.typed_wp (tokenBytes π) π.length) (Disp.allB_sound (congrFun (congrFun ndBuffers (tokenBytes π)) π.length) v hv)
  have hok : G.dataOk P (mlxOf PRE_fd_vw_r0.s16.ffi) ndArgs = true :=
    (D1Pre.dataOk_rest setupP (machReads T tk) (mlxOf PRE_fd_vw_r0.s16.ffi) ndArgs).trans ndOk
  have hsmall : ∀ j ∈ G.dataRefs ndArgs, RefSmall ν ndSrv j :=
    D1Pre.small hv ndSmall
  let Pre := fun (ν : Nat → F64) (S : SSrv) (x : FF.S) (asR : List Arg) =>
    D1Data.Pre P ν S x asR ∧ S = ndSrv ∧ x = PRE_fd_vw_r0.s16.ffi ∧ asR = ndArgs
  have hpre : ∀ asR S1, interpS (decodeArgs FF PRE_fd_vw_r0.s16 ndTys ndRest).run PRE_fd_vw_r0.S16 =
      some (some asR, S1) → Pre ν S1 PRE_fd_vw_r0.s16.ffi asR := by
    exact D1Decode.transport ndDecode
      (show Pre ν ndSrv PRE_fd_vw_r0.s16.ffi ndArgs from
        ⟨⟨hi, hok, hsmall⟩, rfl, rfl, rfl⟩)
  have hcall : ∀ M ν S C x y (asR : List Arg), Srv M ν S C →
      Disp.FRJ (FullRXD P NB) M S.tab.length x y →
      (∀ a ∈ asR, Supp.arg (Present PRE_fd_vw_r0.s16) S.tab.length a) → Pre ν S x asR →
      MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧
        Disp.DataR (Disp.FRJ (FullRXD P NB)) M' S'.tab.length (Present PRE_fd_vw_r0.s16) r r' ∧
        ∀ y' ret ws, r' = some (y', ret, ws) →
          M'.node 15235 < (mlxOf y').nnext ∧ Host.Mlx.SimGraph.HostInt32
            (Host.Mlx.FfiEval.concrete C'.val) (mlxOf y') (M'.node 15235) (π.map Int.ofNat) [1, π.length]) S C
        (FF.call x chars!"mlx_array_new_data" (.jsPtr FDFrames.buffer 0 [] :: asR))
        (FF.call y chars!"mlx_array_new_data" (.jsPtr (M.a FDFrames.buffer) 0 (tokenBytes π) :: asR.map M.arg)) := by
    intro M ν S C x y asR hS hR hsup hp
    obtain ⟨hp, rfl, rfl, rfl, hv9⟩ := hp
    have hd := D1Data.dataCallSim (name := chars!"mlx_array_new_data") P NB (by decide) (by decide) (by decide)
      FDFrames.buffer (tokenBytes π) (Present PRE_fd_vw_r0.s16) M ν ndSrv C PRE_fd_vw_r0.s16.ffi y
      ndArgs hS hR hsup hp
    apply MSim.mono (MSim.withRunT hd (fullLawful.call _ _ _) (fullLawful.call _ _ _))
    intro M' S' C' r r' hh
    obtain ⟨⟨hg, hd⟩, ht⟩ := hh
    refine ⟨hg, hd, ?_⟩
    intro y' ret ws he
    obtain ⟨⟨P', hP, hr⟩, hjs⟩ := hR
    have hr := hr.toR hp.1
    have hiy : (bridgeOf y).active = false := by rw [hr.bridge.1]; exact hp.1
    have hok' : G.dataOk P' (mlxOf PRE_fd_vw_r0.s16.ffi) ndArgs = true := by
      rcases hP with rfl | ⟨k, _, _, rfl⟩
      · exact hp.2.1
      · rw [dataOk_raise]; exact hp.2.1
    have hvv := Input.call_input hS hr.load.mlx hiy hok' hlenN hvc (by rw [he] at ht; exact ht)
    rw [hg.ext.node]
    exact hvv
  have hninv : ∀ M n x y, Disp.FRJ (FullRXD P NB) M n x y → Host.Mlx.Ffi.NGrowCall.NInv (mlxOf y) :=
    fun M n x y hr => fullRXD_ninv M n x y hr.1
  have hQ : TargetPres FF (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf y)) :=
    fullTargetPres hninv (mlxOf t.ffi)
  have hcallQ : ∀ M ν S C x y (asR : List Arg), Srv M ν S C →
      FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf y)) M S.tab.length x y →
      (∀ a ∈ asR, Supp.arg (Present PRE_fd_vw_r0.s16) S.tab.length a) → Pre ν S x asR →
      MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧
        Disp.DataR (FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf y)))
          M' S'.tab.length (Present PRE_fd_vw_r0.s16) r r' ∧
        ∀ y' ret ws, r' = some (y', ret, ws) →
          M'.node 15235 < (mlxOf y').nnext ∧ Host.Mlx.SimGraph.HostInt32
            (Host.Mlx.FfiEval.concrete C'.val) (mlxOf y') (M'.node 15235) (π.map Int.ofNat) [1, π.length]) S C
        (FF.call x chars!"mlx_array_new_data" (.jsPtr FDFrames.buffer 0 [] :: asR))
        (FF.call y chars!"mlx_array_new_data" (.jsPtr (M.a FDFrames.buffer) 0 (tokenBytes π) :: asR.map M.arg)) := by
    intro M ν S C x y asR hS hR hsup hp
    apply MSim.mono (MSim.withRunT (hcall M ν S C x y asR hS hR.1 hsup hp) (fullLawful.call _ _ _) (fullLawful.call _ _ _))
    rintro M' S' C' r r' ⟨⟨hg, hd, hin⟩, ht⟩
    refine ⟨hg, ?_, hin⟩
    cases r with
    | none => trivial
    | some p =>
      obtain ⟨x', ret, ws⟩ := p
      cases r' with
      | none => exact hd
      | some p' =>
        obtain ⟨y', ret', ws'⟩ := p'
        obtain ⟨hf, hrest⟩ := hd
        exact ⟨⟨hf, hQ.call M _ x y _ _ C y' ret' ws' C' hR.1 hR.2 ht⟩, hrest⟩
  have hc := D1InputBridge.bridge_input (FR := FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf y))) (fsym := sym) (ta := sig) (b := FDFrames.buffer)
    (fo := Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s16 sym) (oa := Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s16 sig)
    (bsT := []) (bs' := tokenBytes π) (relB_withQ hs (Host.Mlx.Ffi.NGrow.refl _)) (D1Data.laws P NB).liftQ
    ((D1Data.ffi P NB).liftQ fullLawful hQ)
    ctl fo kind signature types (by decide) hsig hfb (by rfl) hbuf (bools K) hpre
    hcallQ
  obtain ⟨M', t', C', hr, hgrow, hrel, hevent, hinput⟩ := hc.run PRE_fd_vw_r0.s17 PRE_fd_vw_r0.S17 sourceRun
  exact ⟨M', t', C', runC_one (by rw [hs.isHalt, ctl]; rfl) hr, hgrow.ext,
    (({ hrel with ffi := hrel.ffi.1 } : RelB FF (Disp.FRJ (FullRXD P NB)) _ [] M' ν _ _ _ t' C')).withOracle (fun _ h => nomatch h),
    hevent, hinput, hrel.ffi.2⟩
end Host.Ts.Sim.Compose.FDVW.ND
