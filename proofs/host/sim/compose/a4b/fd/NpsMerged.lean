import host.sim.compose.a4b.fd.NpsData
import host.sim.compose.PreGrow
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def npsVal (ν : Nat → F64) := Conv.resVal ν PRE_fd_vw_r0.ws0
  (Conv.resF SymE.var PRE_fd_vw_r0.st0.S2.tab PRE_fd_vw_r0.S0.tab.length ν)
def mergedQ (L : Nat) (x : SegInst FF) : Prop := ∃ ν, x.ν = npsVal ν ∧
  VBOkF loopVB ν ∧ Disp.Kp FDFrames.startJ x.K ∧ MapOk ν (setupI L) [(9, .L)]
def mergedBook (NB T L : Nat) (tk : Nat → Nat) (x : SegInst FF) : Prop :=
  SetupCommon.ChunkBook L x ∧ setupInputs T tk x ∧ fixedCells x ∧ baseNums ∧
  Conv.CallFacts PRE_fd_vw_r0.s0 PRE_fd_vw_r0.S0.tab.length ∧
  NB ≤ PRE_fd_vw_r0.P0.NL ∧ Conv.FullShiftQ PRE_fd_vw_r0.P0 15
    PRE_fd_vw_r0.kappa0 PRE_fd_vw_r0.s2.ffi PRE_fd_vw_r0.s1.ffi
noncomputable def mergedCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  (Cut.mk PRE_fd_vw_r0.s1 PRE_fd_vw_r0.S1.tab
    (Conv.relB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideGPf [] (mergedQ L))).with
    (mergedBook NB T L tk)

/-- The merged cut at the route's prompt. -/
noncomputable def mergedPinCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (L : Nat) : ICut FF :=
  { mergedCut NB T tk L with
    B := fun x => (mergedCut NB T tk L).B x ∧ PromptFr π x ∧ NativeAt 0 0 PRE_fd_vw_r0.s1 x.t }

kernel_rfl cnt1 : countersOkB PRE_fd_vw_r0.s0 PRE_fd_vw_r0.s1 = true

theorem npsSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      PRE_fd_vw_r0.st0.okL (Disp.KpJ FDFrames.startJ 131072) wideGPf r (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : FDFrames.startJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB FDFrames.startJ 131072 hj rfl rfl rfl rfl rfl r FDFrames.start_wp
  apply hs.mono
  intro s S h
  change (Disp.okJSJ FDFrames.startJ (okBackFXS setupP) 131072 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  simpa only [P, backRest] using h.1

theorem npsGrowSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      PRE_fd_vw_r0.st0.okL (Disp.KpJ FDFrames.startJ 131072) wideGPf r (VBOkF loopVB) := by
  apply (wideGrowSim NB T tk r y0).mono
  intro s S h
  change (Disp.okJSJ FDFrames.startJ (okBackFXS setupP) 131072 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  exact h.1

theorem nps_merged {NB T L : Nat} {tk : Nat → Nat} {ρ : List Nat} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y)
    (horacle : ∀ ν, MapOk ν (setupI L) [(9, .L)] → Good ν PRE_fd_vw_r0.st0.S0.oracle) :
    CutStep (withMem Mem (npsCut NB T tk ρ L)) (withMem Mem (mergedPinCut NB T tk ρ L)) (PRE_fd_vw_r0.st0.tpl.n + 1) := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hq⟩, ⟨hb, hins, hids, hbase, hp, hnat⟩, hmem⟩
  obtain ⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh⟩, hsmall⟩ := hb
  have h0 := hr.withOracle (horacle x.ν hq.2.2)
  change RelB FF _ wideGPf [] x.M x.ν x.K PRE_fd_vw_r0.s0
    ⟨PRE_fd_vw_r0.S0.tab, PRE_fd_vw_r0.st0.S0.oracle⟩ x.t x.C at h0
  rw [← PRE_fd_vw_r0.tab0_0] at h0
  let d := PRE_fd_vw_r0.site0 (npsSim NB T tk)
  obtain ⟨M', t', C', run, ext, rel⟩ := Conv.site_merge d.tpl d.start rfl d.sim d.localOk
    hk hq.1 d.foot d.nodup d.bound d.trace PRE_fd_vw_r0.S0.tab.length h0
  rw [d.tab] at ext
  have hm := d.merged rel
  have hm' := hm.resMerge (tab := PRE_fd_vw_r0.S0.tab) hr.srv.num ext (runC_le _ _ _ _ _ run) (d.tab ▸ d.tpl.len2)
    d.len d.freshNodup d.fresh
  have hi : (bridgeOf PRE_fd_vw_r0.s0.ffi).active = false :=
    (congrArg (fun b => b.active) npsBridge).trans (Host.Load.Boot.replay_active _)
  have hbr : bridgeOf PRE_fd_vw_r0.s1.ffi = bridgeOf PRE_fd_vw_r0.s0.ffi :=
    PRE_fd_vw_r0.cbridge0.trans (returnBridge.trans npsBridge.symm)
  have hi' : (bridgeOf PRE_fd_vw_r0.s1.ffi).active = false := by rw [hbr]; exact hi
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hm'.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi').bridge.1.trans (hbr.trans (r0.toR hi).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise
      (mlxOf PRE_fd_vw_r0.s0.ffi).nnext).NL ≤ PRE_fd_vw_r0.P0.NL := by
    change (mlxOf PRE_fd_vw_r0.s0.ffi).nnext ≤ 15235
    rw [← PRE_fd_vw_r0.fcnn0]
  refine ⟨t', C', run, ⟨M', npsVal x.ν, x.K, t', C'⟩, rfl, rfl, ?_, ?_⟩
  · change RelB FF _ wideGPf [] M' (npsVal x.ν) x.K PRE_fd_vw_r0.s1
      ⟨PRE_fd_vw_r0.S1.tab, []⟩ t' C' ∧ _
    rw [PRE_fd_vw_r0.mergeTab0]
    exact ⟨hm', x.ν, rfl, hq⟩
  · have hnat0 : NativeAt 0 0 PRE_fd_vw_r0.s0 x.t := by
      rw [PRE_fd_vw_r0.nps0_eq]
      exact hnat
    have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) :=
      d.ngrow (fun stk y0 => npsGrowSim NB T tk stk y0) hq.1 hk h0 run
    refine ⟨⟨⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, fresh⟩, hsmall⟩,
      ⟨?_, (congrFun ext.a 2590).trans hins.2⟩,
      ⟨(congrFun ext.a 2586).trans hids.1, (congrFun ext.a 2589).trans hids.2⟩,
      hbase, ⟨hr.presentBound, hr.heapSupp⟩, Nat.le_trans top.1.load.mlx.nbl hNL,
      PRE_fd_vw_r0.cshiftR0 top.1 hNL⟩, hp, hnat0.step (P := { setupP with rest := machReads T tk }) rfl hr hm' ext.big ext.node cnt1⟩,
      hMem x _ ⟨runC_le _ _ _ _ _ run, ext.node, ng, tokens_of_grow hr hm' ng (countersOkB_tokens cnt1), congrFun ext.a 12504⟩ hmem⟩
    intro j hj
    change npsVal x.ν j = _
    rw [show npsVal x.ν j = x.ν j from Conv.resVal_off (by
      intro hm
      have h := Nat.le_of_ble_eq_true (List.all_eq_true.mp npsWsLow j hm)
      omega)]
    exact hins.1 j hj

end Host.Ts.Sim.Compose.FDVW
