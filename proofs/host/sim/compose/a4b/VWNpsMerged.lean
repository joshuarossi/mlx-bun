import host.sim.compose.a4b.VWNpsData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def npsVal (ν : Nat → F64) := Conv.resVal ν PRE_first_tail_x15_r0.ws1
  (Conv.resF SymE.var PRE_first_tail_x15_r0.st1.S2.tab PRE_first_tail_x15_r0.S17.tab.length ν)
def mergedQ (L : Nat) (x : SegInst FF) : Prop := ∃ ν, x.ν = npsVal ν ∧
  VBOkF loopVB ν ∧ Disp.Kp setupJ x.K ∧ MapOk ν (setupI L) [(9, .L)]
def mergedBook (NB T L : Nat) (tk : Nat → Nat) (x : SegInst FF) : Prop :=
  SetupCommon.ChunkBook L x ∧ setupInputs T tk x ∧ fixedCells x ∧ baseNums ∧
  Conv.CallFacts PRE_first_tail_x15_r0.s17 PRE_first_tail_x15_r0.S17.tab.length ∧
  NB ≤ PRE_first_tail_x15_r0.P1.NL ∧ Conv.FullShiftQ PRE_first_tail_x15_r0.P1 15
    PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.s19.ffi PRE_first_tail_x15_r0.s18.ffi
noncomputable def mergedCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  (Cut.mk PRE_first_tail_x15_r0.s18 PRE_first_tail_x15_r0.S18.tab
    (Conv.relB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP [] (mergedQ L))).with
    (mergedBook NB T L tk)

theorem npsSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      PRE_first_tail_x15_r0.st1.okL (Disp.KpJ setupJ 4096) wideP r (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB setupJ 4096 hj rfl rfl rfl rfl rfl r setupW_ok
  apply hs.mono
  intro s S h
  change (Disp.okJSJ setupJ (okBackFXS setupP) 4096 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  simpa only [P, backRest] using h.1

theorem nps_merged {NB T L : Nat} {tk : Nat → Nat}
    (horacle : ∀ ν, MapOk ν (setupI L) [(9, .L)] → Good ν PRE_first_tail_x15_r0.st1.S0.oracle) :
    CutStep (npsCut NB T tk L) (mergedCut NB T tk L) (PRE_first_tail_x15_r0.st1.tpl.n + 1) := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hq⟩, hb, hins, hids, hbase⟩
  obtain ⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh⟩, hsmall⟩ := hb
  have h0 := hr.withOracle (horacle x.ν hq.2.2)
  change RelB FF _ wideP [] x.M x.ν x.K PRE_first_tail_x15_r0.s17
    ⟨PRE_first_tail_x15_r0.S17.tab, PRE_first_tail_x15_r0.st1.S0.oracle⟩ x.t x.C at h0
  rw [← PRE_first_tail_x15_r0.tab0_1] at h0
  let d := PRE_first_tail_x15_r0.site1 (npsSim NB T tk)
  obtain ⟨M', t', C', run, ext, rel⟩ := Conv.site_merge d.tpl d.start rfl d.sim d.localOk
    hk hq.1 d.foot d.nodup d.bound d.trace PRE_first_tail_x15_r0.S17.tab.length h0
  rw [d.tab] at ext
  have hm := d.merged rel
  have hm' := hm.resMerge (tab := PRE_first_tail_x15_r0.S17.tab) hr.srv.num ext (runC_le _ _ _ _ _ run) (d.tab ▸ d.tpl.len2)
    d.len d.freshNodup d.fresh
  have hi : (bridgeOf PRE_first_tail_x15_r0.s17.ffi).active = false :=
    (congrArg (fun b => b.active) npsBridge).trans (Host.Load.Boot.replay_active _)
  have hbr : bridgeOf PRE_first_tail_x15_r0.s18.ffi = bridgeOf PRE_first_tail_x15_r0.s17.ffi :=
    PRE_first_tail_x15_r0.cbridge1.trans (returnBridge.trans npsBridge.symm)
  have hi' : (bridgeOf PRE_first_tail_x15_r0.s18.ffi).active = false := by rw [hbr]; exact hi
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
      (mlxOf PRE_first_tail_x15_r0.s17.ffi).nnext).NL ≤ PRE_first_tail_x15_r0.P1.NL := by
    change (mlxOf PRE_first_tail_x15_r0.s17.ffi).nnext ≤ 15235
    rw [← PRE_first_tail_x15_r0.fcnn1]
  refine ⟨t', C', run, ⟨M', npsVal x.ν, x.K, t', C'⟩, rfl, rfl, ?_, ?_⟩
  · change RelB FF _ wideP [] M' (npsVal x.ν) x.K PRE_first_tail_x15_r0.s18
      ⟨PRE_first_tail_x15_r0.S18.tab, []⟩ t' C' ∧ _
    rw [PRE_first_tail_x15_r0.mergeTab1]
    exact ⟨hm', x.ν, rfl, hq⟩
  · refine ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, fresh⟩, hsmall⟩,
      ⟨?_, (congrFun ext.a 2590).trans hins.2⟩,
      ⟨(congrFun ext.a 2586).trans hids.1, (congrFun ext.a 2589).trans hids.2⟩,
      hbase, ⟨hr.presentBound, hr.heapSupp⟩, top.1.load.mlx.nbl.trans hNL,
      PRE_first_tail_x15_r0.cshiftR1 top.1 hNL⟩
    intro j hj
    change npsVal x.ν j = _
    rw [show npsVal x.ν j = x.ν j from Conv.resVal_off (by
      intro hm
      have h := Nat.le_of_ble_eq_true (List.all_eq_true.mp npsWsLow j hm)
      omega)]
    exact hins.1 j hj

end Host.Ts.Sim.Compose.VWFirst
